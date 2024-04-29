--------------------------------------------------------
--  DDL for Package Body INVUPD2B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVUPD2B" AS
/* $Header: INVUPD2B.pls 120.28.12010000.21 2011/11/25 07:23:07 jewen ship $ */
   -- GlobalVar to hold control level for each attribute Bug Fix 3005880

       A_ALLOWED_UNITS_LOOKUP_CODE      NUMBER := 2;
      A_INVENTORY_ITEM_STATUS_CODE      NUMBER := 2;
                       A_ITEM_TYPE      NUMBER := 2;
         A_PRIMARY_UNIT_OF_MEASURE      NUMBER := 2;
                    A_BASE_ITEM_ID      NUMBER := 2;
                A_BOM_ENABLED_FLAG      NUMBER := 2;
                   A_BOM_ITEM_TYPE      NUMBER := 2;
            A_ENGINEERING_ECN_CODE      NUMBER := 2;
             A_ENGINEERING_ITEM_ID      NUMBER := 2;
                   A_ENG_ITEM_FLAG      NUMBER := 2;
            A_COSTING_ENABLED_FLAG      NUMBER := 2;
           A_COST_OF_SALES_ACCOUNT      NUMBER := 2;
         A_DEF_INCL_IN_ROLLUP_FLAG      NUMBER := 2;
            A_INVENTORY_ASSET_FLAG      NUMBER := 2;
                    A_STD_LOT_SIZE      NUMBER := 2;
     A_ALLOW_ITEM_DESC_UPDATE_FLAG      NUMBER := 2;
               A_ASSET_CATEGORY_ID      NUMBER := 2;
                        A_BUYER_ID      NUMBER := 2;
             A_ENCUMBRANCE_ACCOUNT      NUMBER := 2;
                 A_EXPENSE_ACCOUNT      NUMBER := 2;
                 A_HAZARD_CLASS_ID      NUMBER := 2;
             A_LIST_PRICE_PER_UNIT      NUMBER := 2;
                    A_MARKET_PRICE      NUMBER := 2;
           A_MU_APPRVD_VENDOR_FLAG      NUMBER := 2;
          A_OUTSIDE_OPERATION_FLAG      NUMBER := 2;
      A_OUTSIDE_OPERATION_UOM_TYPE      NUMBER := 2;
         A_PRICE_TOLERANCE_PERCENT      NUMBER := 2;
         A_PURCHASING_ENABLED_FLAG      NUMBER := 2;
            A_PURCHASING_ITEM_FLAG      NUMBER := 2;
               A_RFQ_REQUIRED_FLAG      NUMBER := 2;
                 A_ROUNDING_FACTOR      NUMBER := 2;
                    A_TAXABLE_FLAG      NUMBER := 2;
                   A_UNIT_OF_ISSUE      NUMBER := 2;
                    A_UN_NUMBER_ID      NUMBER := 2;
     A_ALLOW_EXPRESS_DELIVERY_FLAG      NUMBER := 2;
        A_ALLOW_SUBS_RECEIPTS_FLAG      NUMBER := 2;
       A_ALLOW_UNORD_RECEIPTS_FLAG      NUMBER := 2;
      A_DAYS_EARLY_RECEIPT_ALLOWED      NUMBER := 2;
       A_DAYS_LATE_RECEIPT_ALLOWED      NUMBER := 2;
        A_ENFORCE_SHIP_TO_LOC_CODE      NUMBER := 2;
        A_INSPECTION_REQUIRED_FLAG      NUMBER := 2;
         A_INVOICE_CLOSE_TOLERANCE      NUMBER := 2;
          A_QTY_RCV_EXCEPTION_CODE      NUMBER := 2;
               A_QTY_RCV_TOLERANCE      NUMBER := 2;
     A_RECEIPT_DAYS_EXCEPTION_CODE      NUMBER := 2;
           A_RECEIPT_REQUIRED_FLAG      NUMBER := 2;
         A_RECEIVE_CLOSE_TOLERANCE      NUMBER := 2;
            A_RECEIVING_ROUTING_ID      NUMBER := 2;
           A_AUTO_LOT_ALPHA_PREFIX      NUMBER := 2;
        A_AUTO_SERIAL_ALPHA_PREFIX      NUMBER := 2;
        A_CYCLE_COUNT_ENABLED_FLAG      NUMBER := 2;
             A_INVENTORY_ITEM_FLAG      NUMBER := 2;
           A_LOCATION_CONTROL_CODE      NUMBER := 2;
                A_LOT_CONTROL_CODE      NUMBER := 2;
        A_MTL_TRANSAC_ENABLED_FLAG      NUMBER := 2;
      A_NEGATIVE_MEASUREMENT_ERROR      NUMBER := 2;
                 A_RESERVABLE_TYPE      NUMBER := 2;
          A_RESTRICT_LOCATORS_CODE      NUMBER := 2;
    A_RESTRICT_SUBINVENTORIES_CODE      NUMBER := 2;
       A_REVISION_QTY_CONTROL_CODE      NUMBER := 2;
      A_SERIAL_NUMBER_CONTROL_CODE      NUMBER := 2;
                 A_SHELF_LIFE_CODE      NUMBER := 2;
                 A_SHELF_LIFE_DAYS      NUMBER := 2;
           A_START_AUTO_LOT_NUMBER      NUMBER := 2;
        A_START_AUTO_SERIAL_NUMBER      NUMBER := 2;
              A_STOCK_ENABLED_FLAG      NUMBER := 2;
                     A_UNIT_VOLUME      NUMBER := 2;
                     A_UNIT_WEIGHT      NUMBER := 2;
                 A_VOLUME_UOM_CODE      NUMBER := 2;
                 A_WEIGHT_UOM_CODE      NUMBER := 2;
                   A_CARRYING_COST      NUMBER := 2;
               A_FIXED_DAYS_SUPPLY      NUMBER := 2;
            A_FIXED_LOT_MULTIPLIER      NUMBER := 2;
            A_FIXED_ORDER_QUANTITY      NUMBER := 2;
         A_INVENTORY_PLANNING_CODE      NUMBER := 2;
          A_MAXIMUM_ORDER_QUANTITY      NUMBER := 2;
             A_MAX_MINMAX_QUANTITY      NUMBER := 2;
          A_MINIMUM_ORDER_QUANTITY      NUMBER := 2;
             A_MIN_MINMAX_QUANTITY      NUMBER := 2;
           A_MRP_SAFETY_STOCK_CODE      NUMBER := 2;
        A_MRP_SAFETY_STOCK_PERCENT      NUMBER := 2;
                      A_ORDER_COST      NUMBER := 2;
                    A_PLANNER_CODE      NUMBER := 2;
        A_SAFETY_STOCK_BUCKET_DAYS      NUMBER := 2;
          A_SOURCE_ORGANIZATION_ID      NUMBER := 2;
             A_SOURCE_SUBINVENTORY      NUMBER := 2;
                     A_SOURCE_TYPE      NUMBER := 2;
           A_ACCEPTABLE_EARLY_DAYS      NUMBER := 2;
        A_ACCEPTABLE_RATE_DECREASE      NUMBER := 2;
        A_ACCEPTABLE_RATE_INCREASE      NUMBER := 2;
                 A_AUTO_REDUCE_MPS      NUMBER := 2;
          A_DEMAND_TIME_FENCE_CODE      NUMBER := 2;
          A_DEMAND_TIME_FENCE_DAYS      NUMBER := 2;
       A_END_ASSEMBLY_PEGGING_FLAG      NUMBER := 2;
          A_MRP_CALCULATE_ATP_FLAG      NUMBER := 2;
               A_MRP_PLANNING_CODE      NUMBER := 2;
              A_OVERRUN_PERCENTAGE      NUMBER := 2;
          A_PLANNING_EXCEPTION_SET      NUMBER := 2;
          A_PLANNING_MAKE_BUY_CODE      NUMBER := 2;
        A_PLANNING_TIME_FENCE_CODE      NUMBER := 2;
        A_PLANNING_TIME_FENCE_DAYS      NUMBER := 2;
        A_REPETITIVE_PLANNING_FLAG      NUMBER := 2;
           A_ROUNDING_CONTROL_TYPE      NUMBER := 2;
                  A_SHRINKAGE_RATE      NUMBER := 2;
      A_CUMULATIVE_TOTAL_LEAD_TIME      NUMBER := 2;
     A_CUM_MANUFACTURING_LEAD_TIME      NUMBER := 2;
                 A_FIXED_LEAD_TIME      NUMBER := 2;
                  A_FULL_LEAD_TIME      NUMBER := 2;
        A_POSTPROCESSING_LEAD_TIME      NUMBER := 2;
         A_PREPROCESSING_LEAD_TIME      NUMBER := 2;
              A_VARIABLE_LEAD_TIME      NUMBER := 2;
               A_BUILD_IN_WIP_FLAG      NUMBER := 2;
           A_WIP_SUPPLY_LOCATOR_ID      NUMBER := 2;
         A_WIP_SUPPLY_SUBINVENTORY      NUMBER := 2;
                 A_WIP_SUPPLY_TYPE      NUMBER := 2;
             A_ATP_COMPONENTS_FLAG      NUMBER := 2;
                        A_ATP_FLAG      NUMBER := 2;
                     A_ATP_RULE_ID      NUMBER := 2;
                 A_COLLATERAL_FLAG      NUMBER := 2;
     A_CUSTOMER_ORDER_ENABLED_FLAG      NUMBER := 2;
             A_CUSTOMER_ORDER_FLAG      NUMBER := 2;
            A_DEFAULT_SHIPPING_ORG      NUMBER := 2;
     A_INTERNAL_ORDER_ENABLED_FLAG      NUMBER := 2;
             A_INTERNAL_ORDER_FLAG      NUMBER := 2;
                 A_PICKING_RULE_ID      NUMBER := 2;
            A_PICK_COMPONENTS_FLAG      NUMBER := 2;
         A_REPLENISH_TO_ORDER_FLAG      NUMBER := 2;
                 A_RETURNABLE_FLAG      NUMBER := 2;
         A_RETURN_INSPECTION_REQMT      NUMBER := 2;
             A_SHIPPABLE_ITEM_FLAG      NUMBER := 2;
        A_SHIP_MODEL_COMPLETE_FLAG      NUMBER := 2;
            A_SO_TRANSACTIONS_FLAG      NUMBER := 2;
              A_ACCOUNTING_RULE_ID      NUMBER := 2;
           A_INVOICEABLE_ITEM_FLAG      NUMBER := 2;
            A_INVOICE_ENABLED_FLAG      NUMBER := 2;
                A_ENGINEERING_DATE      NUMBER := 2;
               A_INVOICING_RULE_ID      NUMBER := 2;
                A_PAYMENT_TERMS_ID      NUMBER := 2;
                   A_SALES_ACCOUNT      NUMBER := 2;
                        A_TAX_CODE      NUMBER := 2;
            A_COVERAGE_SCHEDULE_ID      NUMBER := 2;
             A_PURCHASING_TAX_CODE      NUMBER := 2;
          A_MATERIAL_BILLABLE_FLAG      NUMBER := 2;
             A_MAX_WARRANTY_AMOUNT      NUMBER := 2;
     A_PREVENTIVE_MAINTENANCE_FLAG      NUMBER := 2;
            A_PRORATE_SERVICE_FLAG      NUMBER := 2;
       A_RESPONSE_TIME_PERIOD_CODE      NUMBER := 2;
             A_RESPONSE_TIME_VALUE      NUMBER := 2;
                A_SERVICE_DURATION      NUMBER := 2;
    A_SERVICE_DURATION_PERIOD_CODE      NUMBER := 2;
              A_WARRANTY_VENDOR_ID      NUMBER := 2;
        A_BASE_WARRANTY_SERVICE_ID      NUMBER := 2;
               A_NEW_REVISION_CODE      NUMBER := 2;
           A_PRIMARY_SPECIALIST_ID      NUMBER := 2;
         A_SECONDARY_SPECIALIST_ID      NUMBER := 2;
      A_SERVICEABLE_COMPONENT_FLAG      NUMBER := 2;
       A_SERVICEABLE_ITEM_CLASS_ID      NUMBER := 2;
        A_SERVICEABLE_PRODUCT_FLAG      NUMBER := 2;
          A_SERVICE_STARTING_DELAY      NUMBER := 2;
            A_ATO_FORECAST_CONTROL      NUMBER := 2;
                     A_DESCRIPTION      NUMBER := 2;
                A_LONG_DESCRIPTION      NUMBER := 2;
              A_LEAD_TIME_LOT_SIZE      NUMBER := 2;
      A_POSITIVE_MEASUREMENT_ERROR      NUMBER := 2;
         A_RELEASE_TIME_FENCE_CODE      NUMBER := 2;
         A_RELEASE_TIME_FENCE_DAYS      NUMBER := 2;
             A_CONTAINER_ITEM_FLAG      NUMBER := 2;
               A_VEHICLE_ITEM_FLAG      NUMBER := 2;
             A_MAXIMUM_LOAD_WEIGHT      NUMBER := 2;
            A_MINIMUM_FILL_PERCENT      NUMBER := 2;
                 A_INTERNAL_VOLUME      NUMBER := 2;
             A_CONTAINER_TYPE_CODE      NUMBER := 2;
        A_CHECK_SHORTAGES_FLAG             number  :=  2;
     A_EFFECTIVITY_CONTROL              NUMBER  :=  2;
   A_OVERCOMPLETION_TOLERANCE_TYP   NUMBER  :=  2;
   A_OVERCOMPLETION_TOLERANCE_VAL   NUMBER  :=  2;
   A_OVER_SHIPMENT_TOLERANCE          NUMBER  :=  2;
   A_UNDER_SHIPMENT_TOLERANCE         NUMBER  :=  2;
   A_OVER_RETURN_TOLERANCE            NUMBER  :=  2;
   A_UNDER_RETURN_TOLERANCE           NUMBER  :=  2;
   A_EQUIPMENT_TYPE                   NUMBER  :=  2;
   A_RECOVERED_PART_DISP_CODE         NUMBER  :=  2;
   A_DEFECT_TRACKING_ON_FLAG          NUMBER  :=  2;
   A_EVENT_FLAG                       NUMBER  :=  2;
   A_ELECTRONIC_FLAG                  NUMBER  :=  2;
   A_DOWNLOADABLE_FLAG                NUMBER  :=  2;
   A_VOL_DISCOUNT_EXEMPT_FLAG         NUMBER  :=  2;
   A_COUPON_EXEMPT_FLAG               NUMBER  :=  2;
   A_COMMS_NL_TRACKABLE_FLAG          NUMBER  :=  2;
   A_ASSET_CREATION_CODE              NUMBER  :=  2;
   A_COMMS_ACTIVATION_REQD_FLAG       NUMBER  :=  2;
   A_ORDERABLE_ON_WEB_FLAG            NUMBER  :=  2;
   A_BACK_ORDERABLE_FLAG              NUMBER  :=  2;
     A_WEB_STATUS                       NUMBER  :=  2;
     A_INDIVISIBLE_FLAG                 NUMBER  :=  2;
   A_DIMENSION_UOM_CODE               NUMBER  :=  2;
   A_UNIT_LENGTH                      NUMBER  :=  2;
   A_UNIT_WIDTH                       NUMBER  :=  2;
   A_UNIT_HEIGHT                      NUMBER  :=  2;
   A_BULK_PICKED_FLAG                 NUMBER  :=  2;
   A_LOT_STATUS_ENABLED               NUMBER  :=  2;
   A_DEFAULT_LOT_STATUS_ID            NUMBER  :=  2;
   A_SERIAL_STATUS_ENABLED            NUMBER  :=  2;
   A_DEFAULT_SERIAL_STATUS_ID         NUMBER  :=  2;
   A_LOT_SPLIT_ENABLED                NUMBER  :=  2;
   A_LOT_MERGE_ENABLED                NUMBER  :=  2;
   A_INVENTORY_CARRY_PENALTY          NUMBER  :=  2;
   A_OPERATION_SLACK_PENALTY          NUMBER  :=  2;
   A_FINANCING_ALLOWED_FLAG           NUMBER  :=  2;

   A_EAM_ITEM_TYPE                    NUMBER  :=  2;
   A_EAM_ACTIVITY_TYPE_CODE           NUMBER  :=  2;
   A_EAM_ACTIVITY_CAUSE_CODE          NUMBER  :=  2;
   A_EAM_ACT_NOTIFICATION_FLAG        NUMBER  :=  2;
   A_EAM_ACT_SHUTDOWN_STATUS          NUMBER  :=  2;
   A_DUAL_UOM_CONTROL                 NUMBER  :=  2;
   A_SECONDARY_UOM_CODE               NUMBER  :=  2;
   A_DUAL_UOM_DEVIATION_HIGH          NUMBER  :=  2;
   A_DUAL_UOM_DEVIATION_LOW           NUMBER  :=  2;

   A_CONTRACT_ITEM_TYPE_CODE          NUMBER  :=  2;
--11.5.10   A_SUBSCRIPTION_DEPEND_FLAG         NUMBER  :=  2;

   A_SERV_REQ_ENABLED_CODE            NUMBER  :=  2;
   A_SERV_BILLING_ENABLED_FLAG        NUMBER  :=  2;
--11.5.10   A_SERV_IMPORTANCE_LEVEL            NUMBER  :=  2;
   A_PLANNED_INV_POINT_FLAG           NUMBER  :=  2;
   A_LOT_TRANSLATE_ENABLED            NUMBER  :=  2;
   A_DEFAULT_SO_SOURCE_TYPE           NUMBER  :=  2;
   A_CREATE_SUPPLY_FLAG               NUMBER  :=  2;
   A_SUBSTITUTION_WINDOW_CODE         NUMBER  :=  2;
   A_SUBSTITUTION_WINDOW_DAYS         NUMBER  :=  2;
   A_LOT_SUBSTITUTION_ENABLED         NUMBER  :=  2;
   A_MINIMUM_LICENSE_QUANTITY         NUMBER  :=  2;
   A_EAM_ACTIVITY_SOURCE_CODE         NUMBER  :=  2;
   A_IB_ITEM_INSTANCE_CLASS           NUMBER  :=  2;
   A_CONFIG_MODEL_TYPE                NUMBER  :=  2;
-- added for 11.5.10
   A_TRACKING_QUANTITY_IND            NUMBER  :=  2;
   A_ONT_PRICING_QTY_SOURCE           NUMBER  :=  2;
   A_SECONDARY_DEFAULT_IND            NUMBER  :=  2;
   A_AUTO_CREATED_CONFIG_FLAG         NUMBER  :=  2;
   A_CONFIG_ORGS                      NUMBER  :=  2;
   A_CONFIG_MATCH                     NUMBER  :=  2;
   A_VMI_MINIMUM_UNITS         NUMBER  := 2;
   A_VMI_MINIMUM_DAYS          NUMBER  := 2;
   A_VMI_MAXIMUM_UNITS         NUMBER  := 2;
   A_VMI_MAXIMUM_DAYS          NUMBER  := 2;
   A_VMI_FIXED_ORDER_QUANTITY  NUMBER  := 2;
   A_SO_AUTHORIZATION_FLAG     NUMBER  := 2;
   A_CONSIGNED_FLAG            NUMBER  := 2;
   A_ASN_AUTOEXPIRE_FLAG       NUMBER  := 2;
   A_VMI_FORECAST_TYPE         NUMBER  := 2;
   A_FORECAST_HORIZON          NUMBER  := 2;
   A_EXCLUDE_FROM_BUDGET_FLAG  NUMBER  := 2;
   A_DAYS_TGT_INV_SUPPLY       NUMBER  := 2;
   A_DAYS_TGT_INV_WINDOW       NUMBER  := 2;
   A_DAYS_MAX_INV_SUPPLY       NUMBER  := 2;
   A_DAYS_MAX_INV_WINDOW       NUMBER  := 2;
   A_DRP_PLANNED_FLAG          NUMBER  := 2;
   A_CRITICAL_COMPONENT_FLAG   NUMBER  := 2;
   A_CONTINOUS_TRANSFER        NUMBER  := 2;
   A_CONVERGENCE               NUMBER  := 2;
   A_DIVERGENCE                NUMBER  := 2;

   /* Start Bug 3713912 */
   A_LOT_DIVISIBLE_FLAG                 NUMBER  := 2;
   A_GRADE_CONTROL_FLAG                 NUMBER  := 2;
   A_DEFAULT_GRADE                      NUMBER  := 2;
   A_CHILD_LOT_FLAG                     NUMBER  := 2;
   A_PARENT_CHILD_GENERATION_FLAG       NUMBER  := 2;
   A_CHILD_LOT_PREFIX                   NUMBER  := 2;
   A_CHILD_LOT_STARTING_NUMBER          NUMBER  := 2;
   A_CHILD_LOT_VALIDATION_FLAG          NUMBER  := 2;
   A_COPY_LOT_ATTRIBUTE_FLAG            NUMBER  := 2;
   A_RECIPE_ENABLED_FLAG                NUMBER  := 2;
   A_PROCESS_QUALITY_ENABLED_FLAG       NUMBER  := 2;
   A_PROCESS_EXEC_ENABLED_FLAG          NUMBER  := 2;
   A_PROCESS_COSTING_ENABLED_FLAG       NUMBER  := 2;
   A_PROCESS_SUPPLY_SUBINVENTORY        NUMBER  := 2;
   A_PROCESS_SUPPLY_LOCATOR_ID          NUMBER  := 2;
   A_PROCESS_YIELD_SUBINVENTORY         NUMBER  := 2;
   A_PROCESS_YIELD_LOCATOR_ID           NUMBER  := 2;
   A_HAZARDOUS_MATERIAL_FLAG            NUMBER  := 2;
   A_CAS_NUMBER                         NUMBER  := 2;
   A_RETEST_INTERVAL                    NUMBER  := 2;
   A_EXPIRATION_ACTION_INTERVAL         NUMBER  := 2;
   A_EXPIRATION_ACTION_CODE             NUMBER  := 2;
   A_MATURITY_DAYS                      NUMBER  := 2;
   A_HOLD_DAYS                          NUMBER  := 2;
   --R12 Enahancement
   A_CHARGE_PERIODICITY_CODE            NUMBER  := 2;
   A_REPAIR_LEADTIME                    NUMBER  := 2;
   A_REPAIR_YIELD                       NUMBER  := 2;
   A_PREPOSITION_POINT                  NUMBER  := 2;
   A_REPAIR_PROGRAM                     NUMBER  := 2;
   A_SUBCONTRACTING_COMPONENT           NUMBER  := 2;
   A_OUTSOURCED_ASSEMBLY                NUMBER  := 2;

   /* End Bug 3713912 */

     g_attribute_code           dbms_sql.varchar2_table;    -- Bug 10404086

--Bug: 5437967 This procedure prevents insertion of child records
--             in msii if no Master Controlled Attribute is changed in Master Org
PROCEDURE Check_create_child_records
(
   mast_rowid                    ROWID,
   item_id                       NUMBER,
   org_id                        NUMBER,
   check_create_child OUT NOCOPY BOOLEAN
);


FUNCTION validate_item_update_master
(
        org_id          NUMBER,
        all_org         NUMBER          := 2,
        prog_appid      NUMBER          := -1,
        prog_id         NUMBER          := -1,
        request_id      NUMBER          := -1,
        user_id         NUMBER          := -1,
        login_id        NUMBER          := -1,
        err_text IN OUT NOCOPY VARCHAR2,
        xset_id  IN     NUMBER          DEFAULT NULL
)
RETURN INTEGER
IS

  /* Bug 4460686. Dont pick up master records when AUTO_CHILD already exists as
     this will create duplicate AUTO_CHILD records */

   CURSOR C_msii_master_records
   IS
      SELECT
        ROWID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        TRANSACTION_ID
      FROM
         MTL_SYSTEM_ITEMS_INTERFACE
      WHERE
             process_flag = 4
         AND set_process_id = xset_id
         AND ( (organization_id = org_id) or (all_org = 1) )
         AND organization_id IN
             ( select organization_id
               from MTL_PARAMETERS
               where organization_id = master_organization_id
             )
     AND not exists
        (select 1 from mtl_system_items_interface
         where set_process_id = xset_id + 1000000000000
           and transaction_type = 'AUTO_CHILD'
           and process_flag = 4
        );

-- Bug fix 3005880 Moved cursor code from FUNCTION copy_master_to_child
-- so that this cursor will be executed only twice once for updation of master
-- record and once for updation of all child records.

   CURSOR C_item_attributes
   IS
      SELECT  attribute_name
           ,  control_level
      FROM  mtl_item_attributes
      WHERE
             control_level = 1
         AND attribute_group_id_gui IN
             (20, 25, 30, 31, 35, 40, 41, 51,
              60, 62, 65, 70, 80, 90, 100, 120, 130);  /* Bug 3713912 Added 130*/

        ret_code                NUMBER  := 1;
        ret_code_update         NUMBER;
        dumm_status             NUMBER;
        error_text              VARCHAR2(250);
        l_process_flag_3        NUMBER  := 3;
        m_process_flag          NUMBER;
        t_trans_id              NUMBER;
        t_organization_id       NUMBER;
        t_inventory_item_id     NUMBER;
    l_attribute_name        VARCHAR2(100);

    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

    tmp_xset_id             NUMBER ; --5351611

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside validate_item_update_master'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

   -- Set the attribute level for those attributes under master control.
   -- Bug fix 3005880
   FOR rec IN C_item_attributes loop -- {

      l_attribute_name := substr(rec.attribute_name, 18);

      IF    l_attribute_name = 'ALLOWED_UNITS_LOOKUP_CODE'        THEN    A_ALLOWED_UNITS_LOOKUP_CODE := rec.control_level;
      ELSIF l_attribute_name = 'INVENTORY_ITEM_STATUS_CODE'       THEN    A_INVENTORY_ITEM_STATUS_CODE := rec.control_level;
      ELSIF l_attribute_name = 'ITEM_TYPE'                        THEN    A_ITEM_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'PRIMARY_UNIT_OF_MEASURE'          THEN    A_PRIMARY_UNIT_OF_MEASURE := rec.control_level;
      ELSIF l_attribute_name = 'BASE_ITEM_ID'                     THEN    A_BASE_ITEM_ID := rec.control_level;
      ELSIF l_attribute_name = 'BOM_ENABLED_FLAG'                 THEN    A_BOM_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'BOM_ITEM_TYPE'                    THEN    A_BOM_ITEM_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'ENGINEERING_ECN_CODE'             THEN    A_ENGINEERING_ECN_CODE := rec.control_level;
      ELSIF l_attribute_name = 'ENGINEERING_ITEM_ID'              THEN    A_ENGINEERING_ITEM_ID := rec.control_level;
      ELSIF l_attribute_name = 'ENG_ITEM_FLAG'                    THEN    A_ENG_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'COSTING_ENABLED_FLAG'             THEN    A_COSTING_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'COST_OF_SALES_ACCOUNT'            THEN    A_COST_OF_SALES_ACCOUNT := rec.control_level;
      ELSIF l_attribute_name = 'DEFAULT_INCLUDE_IN_ROLLUP_FLAG'   THEN    A_DEF_INCL_IN_ROLLUP_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'INVENTORY_ASSET_FLAG'             THEN    A_INVENTORY_ASSET_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'STD_LOT_SIZE'                     THEN    A_STD_LOT_SIZE := rec.control_level;
      ELSIF l_attribute_name = 'ALLOW_ITEM_DESC_UPDATE_FLAG'      THEN    A_ALLOW_ITEM_DESC_UPDATE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ASSET_CATEGORY_ID'                THEN    A_ASSET_CATEGORY_ID := rec.control_level;
      ELSIF l_attribute_name = 'BUYER_ID'                         THEN    A_BUYER_ID := rec.control_level;
      ELSIF l_attribute_name = 'ENCUMBRANCE_ACCOUNT'              THEN    A_ENCUMBRANCE_ACCOUNT := rec.control_level;
      ELSIF l_attribute_name = 'EXPENSE_ACCOUNT'                  THEN    A_EXPENSE_ACCOUNT := rec.control_level;
      ELSIF l_attribute_name = 'HAZARD_CLASS_ID'                  THEN    A_HAZARD_CLASS_ID := rec.control_level;
      ELSIF l_attribute_name = 'LIST_PRICE_PER_UNIT'              THEN    A_LIST_PRICE_PER_UNIT := rec.control_level;
      ELSIF l_attribute_name = 'MARKET_PRICE'                     THEN    A_MARKET_PRICE := rec.control_level;
      ELSIF l_attribute_name = 'MUST_USE_APPROVED_VENDOR_FLAG'    THEN    A_MU_APPRVD_VENDOR_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'OUTSIDE_OPERATION_FLAG'           THEN    A_OUTSIDE_OPERATION_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'OUTSIDE_OPERATION_UOM_TYPE'       THEN    A_OUTSIDE_OPERATION_UOM_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'PRICE_TOLERANCE_PERCENT'          THEN    A_PRICE_TOLERANCE_PERCENT := rec.control_level;
      ELSIF l_attribute_name = 'PURCHASING_ENABLED_FLAG'          THEN    A_PURCHASING_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'PURCHASING_ITEM_FLAG'             THEN    A_PURCHASING_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'RFQ_REQUIRED_FLAG'                THEN    A_RFQ_REQUIRED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ROUNDING_FACTOR'                  THEN    A_ROUNDING_FACTOR := rec.control_level;
      ELSIF l_attribute_name = 'TAXABLE_FLAG'                     THEN    A_TAXABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_OF_ISSUE'                    THEN    A_UNIT_OF_ISSUE := rec.control_level;
      ELSIF l_attribute_name = 'UN_NUMBER_ID'                     THEN    A_UN_NUMBER_ID := rec.control_level;
      ELSIF l_attribute_name = 'ALLOW_EXPRESS_DELIVERY_FLAG'      THEN    A_ALLOW_EXPRESS_DELIVERY_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG'   THEN    A_ALLOW_SUBS_RECEIPTS_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ALLOW_UNORDERED_RECEIPTS_FLAG'    THEN    A_ALLOW_UNORD_RECEIPTS_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_EARLY_RECEIPT_ALLOWED'       THEN    A_DAYS_EARLY_RECEIPT_ALLOWED := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_LATE_RECEIPT_ALLOWED'        THEN    A_DAYS_LATE_RECEIPT_ALLOWED := rec.control_level;
      ELSIF l_attribute_name = 'ENFORCE_SHIP_TO_LOCATION_CODE'    THEN    A_ENFORCE_SHIP_TO_LOC_CODE := rec.control_level;
      ELSIF l_attribute_name = 'INSPECTION_REQUIRED_FLAG'         THEN    A_INSPECTION_REQUIRED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'INVOICE_CLOSE_TOLERANCE'          THEN    A_INVOICE_CLOSE_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'QTY_RCV_EXCEPTION_CODE'           THEN    A_QTY_RCV_EXCEPTION_CODE := rec.control_level;
      ELSIF l_attribute_name = 'QTY_RCV_TOLERANCE'                THEN    A_QTY_RCV_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'RECEIPT_DAYS_EXCEPTION_CODE'      THEN    A_RECEIPT_DAYS_EXCEPTION_CODE := rec.control_level;
      ELSIF l_attribute_name = 'RECEIPT_REQUIRED_FLAG'            THEN    A_RECEIPT_REQUIRED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'RECEIVE_CLOSE_TOLERANCE'          THEN    A_RECEIVE_CLOSE_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'RECEIVING_ROUTING_ID'             THEN    A_RECEIVING_ROUTING_ID := rec.control_level;
      ELSIF l_attribute_name = 'AUTO_LOT_ALPHA_PREFIX'            THEN    A_AUTO_LOT_ALPHA_PREFIX := rec.control_level;
      ELSIF l_attribute_name = 'AUTO_SERIAL_ALPHA_PREFIX'         THEN    A_AUTO_SERIAL_ALPHA_PREFIX := rec.control_level;
      ELSIF l_attribute_name = 'CYCLE_COUNT_ENABLED_FLAG'         THEN    A_CYCLE_COUNT_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'INVENTORY_ITEM_FLAG'              THEN    A_INVENTORY_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'LOCATION_CONTROL_CODE'            THEN    A_LOCATION_CONTROL_CODE := rec.control_level;
      ELSIF l_attribute_name = 'LOT_CONTROL_CODE'                 THEN    A_LOT_CONTROL_CODE := rec.control_level;
      ELSIF l_attribute_name = 'MTL_TRANSACTIONS_ENABLED_FLAG'    THEN    A_MTL_TRANSAC_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'NEGATIVE_MEASUREMENT_ERROR'       THEN    A_NEGATIVE_MEASUREMENT_ERROR := rec.control_level;
      ELSIF l_attribute_name = 'RESERVABLE_TYPE'                  THEN    A_RESERVABLE_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'RESTRICT_LOCATORS_CODE'           THEN    A_RESTRICT_LOCATORS_CODE := rec.control_level;
      ELSIF l_attribute_name = 'RESTRICT_SUBINVENTORIES_CODE'     THEN    A_RESTRICT_SUBINVENTORIES_CODE := rec.control_level;
      ELSIF l_attribute_name = 'REVISION_QTY_CONTROL_CODE'        THEN    A_REVISION_QTY_CONTROL_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SERIAL_NUMBER_CONTROL_CODE'       THEN    A_SERIAL_NUMBER_CONTROL_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SHELF_LIFE_CODE'                  THEN    A_SHELF_LIFE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SHELF_LIFE_DAYS'                  THEN    A_SHELF_LIFE_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'START_AUTO_LOT_NUMBER'            THEN    A_START_AUTO_LOT_NUMBER := rec.control_level;
      ELSIF l_attribute_name = 'START_AUTO_SERIAL_NUMBER'         THEN    A_START_AUTO_SERIAL_NUMBER := rec.control_level;
      ELSIF l_attribute_name = 'STOCK_ENABLED_FLAG'               THEN    A_STOCK_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_VOLUME'                      THEN    A_UNIT_VOLUME := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_WEIGHT'                      THEN    A_UNIT_WEIGHT := rec.control_level;
      ELSIF l_attribute_name = 'VOLUME_UOM_CODE'                  THEN    A_VOLUME_UOM_CODE := rec.control_level;
      ELSIF l_attribute_name = 'WEIGHT_UOM_CODE'                  THEN    A_WEIGHT_UOM_CODE := rec.control_level;
      ELSIF l_attribute_name = 'CARRYING_COST'                    THEN    A_CARRYING_COST := rec.control_level;
      ELSIF l_attribute_name = 'FIXED_DAYS_SUPPLY'                THEN    A_FIXED_DAYS_SUPPLY := rec.control_level;
      ELSIF l_attribute_name = 'FIXED_LOT_MULTIPLIER'             THEN    A_FIXED_LOT_MULTIPLIER := rec.control_level;
      ELSIF l_attribute_name = 'FIXED_ORDER_QUANTITY'             THEN    A_FIXED_ORDER_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'INVENTORY_PLANNING_CODE'          THEN    A_INVENTORY_PLANNING_CODE := rec.control_level;
      ELSIF l_attribute_name = 'MAXIMUM_ORDER_QUANTITY'           THEN    A_MAXIMUM_ORDER_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'MAX_MINMAX_QUANTITY'              THEN    A_MAX_MINMAX_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'MINIMUM_ORDER_QUANTITY'           THEN    A_MINIMUM_ORDER_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'MIN_MINMAX_QUANTITY'              THEN    A_MIN_MINMAX_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'MRP_SAFETY_STOCK_CODE'            THEN    A_MRP_SAFETY_STOCK_CODE := rec.control_level;
      ELSIF l_attribute_name = 'MRP_SAFETY_STOCK_PERCENT'         THEN    A_MRP_SAFETY_STOCK_PERCENT := rec.control_level;
      ELSIF l_attribute_name = 'ORDER_COST'                       THEN    A_ORDER_COST := rec.control_level;
      ELSIF l_attribute_name = 'PLANNER_CODE'                     THEN    A_PLANNER_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SAFETY_STOCK_BUCKET_DAYS'         THEN    A_SAFETY_STOCK_BUCKET_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'SOURCE_ORGANIZATION_ID'           THEN    A_SOURCE_ORGANIZATION_ID := rec.control_level;
      ELSIF l_attribute_name = 'SOURCE_SUBINVENTORY'              THEN    A_SOURCE_SUBINVENTORY := rec.control_level;
      ELSIF l_attribute_name = 'SOURCE_TYPE'                      THEN    A_SOURCE_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'ACCEPTABLE_EARLY_DAYS'            THEN    A_ACCEPTABLE_EARLY_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'ACCEPTABLE_RATE_DECREASE'         THEN    A_ACCEPTABLE_RATE_DECREASE := rec.control_level;
      ELSIF l_attribute_name = 'ACCEPTABLE_RATE_INCREASE'         THEN    A_ACCEPTABLE_RATE_INCREASE := rec.control_level;
      ELSIF l_attribute_name = 'AUTO_REDUCE_MPS'                  THEN    A_AUTO_REDUCE_MPS := rec.control_level;
      ELSIF l_attribute_name = 'DEMAND_TIME_FENCE_CODE'           THEN    A_DEMAND_TIME_FENCE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'DEMAND_TIME_FENCE_DAYS'           THEN    A_DEMAND_TIME_FENCE_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'END_ASSEMBLY_PEGGING_FLAG'        THEN    A_END_ASSEMBLY_PEGGING_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'MRP_CALCULATE_ATP_FLAG'           THEN    A_MRP_CALCULATE_ATP_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'MRP_PLANNING_CODE'                THEN    A_MRP_PLANNING_CODE := rec.control_level;
      ELSIF l_attribute_name = 'OVERRUN_PERCENTAGE'               THEN    A_OVERRUN_PERCENTAGE := rec.control_level;
      ELSIF l_attribute_name = 'PLANNING_EXCEPTION_SET'           THEN    A_PLANNING_EXCEPTION_SET := rec.control_level;
      ELSIF l_attribute_name = 'PLANNING_MAKE_BUY_CODE'           THEN    A_PLANNING_MAKE_BUY_CODE := rec.control_level;
      ELSIF l_attribute_name = 'PLANNING_TIME_FENCE_CODE'         THEN    A_PLANNING_TIME_FENCE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'PLANNING_TIME_FENCE_DAYS'         THEN    A_PLANNING_TIME_FENCE_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'REPETITIVE_PLANNING_FLAG'         THEN    A_REPETITIVE_PLANNING_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ROUNDING_CONTROL_TYPE'            THEN    A_ROUNDING_CONTROL_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'SHRINKAGE_RATE'                   THEN    A_SHRINKAGE_RATE := rec.control_level;
      ELSIF l_attribute_name = 'CUMULATIVE_TOTAL_LEAD_TIME'       THEN    A_CUMULATIVE_TOTAL_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'CUM_MANUFACTURING_LEAD_TIME'      THEN    A_CUM_MANUFACTURING_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'FIXED_LEAD_TIME'                  THEN    A_FIXED_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'FULL_LEAD_TIME'                   THEN    A_FULL_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'POSTPROCESSING_LEAD_TIME'         THEN    A_POSTPROCESSING_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'PREPROCESSING_LEAD_TIME'          THEN    A_PREPROCESSING_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'VARIABLE_LEAD_TIME'               THEN    A_VARIABLE_LEAD_TIME := rec.control_level;
      ELSIF l_attribute_name = 'BUILD_IN_WIP_FLAG'                THEN    A_BUILD_IN_WIP_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'WIP_SUPPLY_LOCATOR_ID'            THEN    A_WIP_SUPPLY_LOCATOR_ID := rec.control_level;
      ELSIF l_attribute_name = 'WIP_SUPPLY_SUBINVENTORY'          THEN    A_WIP_SUPPLY_SUBINVENTORY := rec.control_level;
      ELSIF l_attribute_name = 'WIP_SUPPLY_TYPE'                  THEN    A_WIP_SUPPLY_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'ATP_COMPONENTS_FLAG'              THEN    A_ATP_COMPONENTS_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ATP_FLAG'                         THEN    A_ATP_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ATP_RULE_ID'                      THEN    A_ATP_RULE_ID := rec.control_level;
      ELSIF l_attribute_name = 'COLLATERAL_FLAG'                  THEN    A_COLLATERAL_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CUSTOMER_ORDER_ENABLED_FLAG'      THEN    A_CUSTOMER_ORDER_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CUSTOMER_ORDER_FLAG'              THEN    A_CUSTOMER_ORDER_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'DEFAULT_SHIPPING_ORG'             THEN    A_DEFAULT_SHIPPING_ORG := rec.control_level;
      ELSIF l_attribute_name = 'INTERNAL_ORDER_ENABLED_FLAG'      THEN    A_INTERNAL_ORDER_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'INTERNAL_ORDER_FLAG'              THEN    A_INTERNAL_ORDER_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'PICKING_RULE_ID'                  THEN    A_PICKING_RULE_ID := rec.control_level;
      ELSIF l_attribute_name = 'PICK_COMPONENTS_FLAG'             THEN    A_PICK_COMPONENTS_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'REPLENISH_TO_ORDER_FLAG'          THEN    A_REPLENISH_TO_ORDER_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'RETURNABLE_FLAG'                  THEN    A_RETURNABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'RETURN_INSPECTION_REQUIREMENT'    THEN    A_RETURN_INSPECTION_REQMT := rec.control_level;
      ELSIF l_attribute_name = 'SHIPPABLE_ITEM_FLAG'              THEN    A_SHIPPABLE_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'SHIP_MODEL_COMPLETE_FLAG'         THEN    A_SHIP_MODEL_COMPLETE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'SO_TRANSACTIONS_FLAG'             THEN    A_SO_TRANSACTIONS_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ACCOUNTING_RULE_ID'               THEN    A_ACCOUNTING_RULE_ID := rec.control_level;
      ELSIF l_attribute_name = 'INVOICEABLE_ITEM_FLAG'            THEN    A_INVOICEABLE_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'INVOICE_ENABLED_FLAG'             THEN    A_INVOICE_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ENGINEERING_DATE'                 THEN    A_ENGINEERING_DATE := rec.control_level;
      ELSIF l_attribute_name = 'INVOICING_RULE_ID'                THEN    A_INVOICING_RULE_ID := rec.control_level;
      ELSIF l_attribute_name = 'PAYMENT_TERMS_ID'                 THEN    A_PAYMENT_TERMS_ID := rec.control_level;
      ELSIF l_attribute_name = 'SALES_ACCOUNT'                    THEN    A_SALES_ACCOUNT := rec.control_level;
      ELSIF l_attribute_name = 'TAX_CODE'                         THEN    A_TAX_CODE := rec.control_level;
      ELSIF l_attribute_name = 'COVERAGE_SCHEDULE_ID'             THEN    A_COVERAGE_SCHEDULE_ID := rec.control_level;
      ELSIF l_attribute_name = 'PURCHASING_TAX_CODE'              THEN    A_PURCHASING_TAX_CODE := rec.control_level;
      ELSIF l_attribute_name = 'MATERIAL_BILLABLE_FLAG'           THEN    A_MATERIAL_BILLABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'MAX_WARRANTY_AMOUNT'              THEN    A_MAX_WARRANTY_AMOUNT := rec.control_level;
      ELSIF l_attribute_name = 'PREVENTIVE_MAINTENANCE_FLAG'      THEN    A_PREVENTIVE_MAINTENANCE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'PRORATE_SERVICE_FLAG'             THEN    A_PRORATE_SERVICE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'RESPONSE_TIME_PERIOD_CODE'        THEN    A_RESPONSE_TIME_PERIOD_CODE := rec.control_level;
      ELSIF l_attribute_name = 'RESPONSE_TIME_VALUE'              THEN    A_RESPONSE_TIME_VALUE := rec.control_level;
      ELSIF l_attribute_name = 'SERVICE_DURATION'                 THEN    A_SERVICE_DURATION := rec.control_level;
      ELSIF l_attribute_name = 'SERVICE_DURATION_PERIOD_CODE'     THEN    A_SERVICE_DURATION_PERIOD_CODE := rec.control_level;
      ELSIF l_attribute_name = 'WARRANTY_VENDOR_ID'               THEN    A_WARRANTY_VENDOR_ID := rec.control_level;
      ELSIF l_attribute_name = 'BASE_WARRANTY_SERVICE_ID'         THEN    A_BASE_WARRANTY_SERVICE_ID := rec.control_level;
      ELSIF l_attribute_name = 'NEW_REVISION_CODE'                THEN    A_NEW_REVISION_CODE := rec.control_level;
      ELSIF l_attribute_name = 'PRIMARY_SPECIALIST_ID'            THEN    A_PRIMARY_SPECIALIST_ID := rec.control_level;
      ELSIF l_attribute_name = 'SECONDARY_SPECIALIST_ID'          THEN    A_SECONDARY_SPECIALIST_ID := rec.control_level;
      ELSIF l_attribute_name = 'SERVICEABLE_COMPONENT_FLAG'       THEN    A_SERVICEABLE_COMPONENT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'SERVICEABLE_ITEM_CLASS_ID'        THEN    A_SERVICEABLE_ITEM_CLASS_ID := rec.control_level;
      ELSIF l_attribute_name = 'SERVICEABLE_PRODUCT_FLAG'         THEN    A_SERVICEABLE_PRODUCT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'SERVICE_STARTING_DELAY'           THEN    A_SERVICE_STARTING_DELAY := rec.control_level;
      ELSIF l_attribute_name = 'ATO_FORECAST_CONTROL'             THEN    A_ATO_FORECAST_CONTROL := rec.control_level;
      ELSIF l_attribute_name = 'DESCRIPTION'                      THEN    A_DESCRIPTION := rec.control_level;
      ELSIF l_attribute_name = 'LONG_DESCRIPTION'                 THEN    A_LONG_DESCRIPTION := rec.control_level;
      ELSIF l_attribute_name = 'LEAD_TIME_LOT_SIZE'               THEN    A_LEAD_TIME_LOT_SIZE := rec.control_level;
      ELSIF l_attribute_name = 'POSITIVE_MEASUREMENT_ERROR'       THEN    A_POSITIVE_MEASUREMENT_ERROR := rec.control_level;
      ELSIF l_attribute_name = 'RELEASE_TIME_FENCE_CODE'          THEN    A_RELEASE_TIME_FENCE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'RELEASE_TIME_FENCE_DAYS'          THEN    A_RELEASE_TIME_FENCE_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'CONTAINER_ITEM_FLAG'              THEN    A_CONTAINER_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'VEHICLE_ITEM_FLAG'                THEN    A_VEHICLE_ITEM_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'MAXIMUM_LOAD_WEIGHT'              THEN    A_MAXIMUM_LOAD_WEIGHT := rec.control_level;
      ELSIF l_attribute_name = 'MINIMUM_FILL_PERCENT'             THEN    A_MINIMUM_FILL_PERCENT := rec.control_level;
      ELSIF l_attribute_name = 'INTERNAL_VOLUME'                  THEN    A_INTERNAL_VOLUME := rec.control_level;
      ELSIF l_attribute_name = 'CONTAINER_TYPE_CODE'              THEN    A_CONTAINER_TYPE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'CHECK_SHORTAGES_FLAG'             THEN    A_CHECK_SHORTAGES_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'EFFECTIVITY_CONTROL'              THEN    A_EFFECTIVITY_CONTROL := rec.control_level;
      ELSIF l_attribute_name = 'OVERCOMPLETION_TOLERANCE_TYPE'    THEN    A_OVERCOMPLETION_TOLERANCE_TYP := rec.control_level;
      ELSIF l_attribute_name = 'OVERCOMPLETION_TOLERANCE_VALUE'   THEN    A_OVERCOMPLETION_TOLERANCE_VAL := rec.control_level;
      ELSIF l_attribute_name = 'OVER_SHIPMENT_TOLERANCE'          THEN    A_OVER_SHIPMENT_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'UNDER_SHIPMENT_TOLERANCE'         THEN    A_UNDER_SHIPMENT_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'OVER_RETURN_TOLERANCE'            THEN    A_OVER_RETURN_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'UNDER_RETURN_TOLERANCE'           THEN    A_UNDER_RETURN_TOLERANCE := rec.control_level;
      ELSIF l_attribute_name = 'EQUIPMENT_TYPE'                   THEN    A_EQUIPMENT_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'RECOVERED_PART_DISP_CODE'         THEN    A_RECOVERED_PART_DISP_CODE := rec.control_level;
      ELSIF l_attribute_name = 'DEFECT_TRACKING_ON_FLAG'          THEN    A_DEFECT_TRACKING_ON_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'EVENT_FLAG'                       THEN    A_EVENT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ELECTRONIC_FLAG'                  THEN    A_ELECTRONIC_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'DOWNLOADABLE_FLAG'                THEN    A_DOWNLOADABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'VOL_DISCOUNT_EXEMPT_FLAG'         THEN    A_VOL_DISCOUNT_EXEMPT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'COUPON_EXEMPT_FLAG'               THEN    A_COUPON_EXEMPT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'COMMS_NL_TRACKABLE_FLAG'          THEN    A_COMMS_NL_TRACKABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ASSET_CREATION_CODE'              THEN    A_ASSET_CREATION_CODE := rec.control_level;
      ELSIF l_attribute_name = 'COMMS_ACTIVATION_REQD_FLAG'       THEN    A_COMMS_ACTIVATION_REQD_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ORDERABLE_ON_WEB_FLAG'            THEN    A_ORDERABLE_ON_WEB_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'BACK_ORDERABLE_FLAG'              THEN    A_BACK_ORDERABLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'WEB_STATUS'                       THEN    A_WEB_STATUS := rec.control_level;
      ELSIF l_attribute_name = 'INDIVISIBLE_FLAG'                 THEN    A_INDIVISIBLE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'DIMENSION_UOM_CODE'               THEN    A_DIMENSION_UOM_CODE := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_LENGTH'                      THEN    A_UNIT_LENGTH := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_WIDTH'                       THEN    A_UNIT_WIDTH := rec.control_level;
      ELSIF l_attribute_name = 'UNIT_HEIGHT'                      THEN    A_UNIT_HEIGHT := rec.control_level;
      ELSIF l_attribute_name = 'BULK_PICKED_FLAG'                 THEN    A_BULK_PICKED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'LOT_STATUS_ENABLED'               THEN    A_LOT_STATUS_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'DEFAULT_LOT_STATUS_ID'            THEN    A_DEFAULT_LOT_STATUS_ID := rec.control_level;
      ELSIF l_attribute_name = 'SERIAL_STATUS_ENABLED'            THEN    A_SERIAL_STATUS_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'DEFAULT_SERIAL_STATUS_ID'         THEN    A_DEFAULT_SERIAL_STATUS_ID := rec.control_level;
      ELSIF l_attribute_name = 'LOT_SPLIT_ENABLED'                THEN    A_LOT_SPLIT_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'LOT_MERGE_ENABLED'                THEN    A_LOT_MERGE_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'INVENTORY_CARRY_PENALTY'          THEN    A_INVENTORY_CARRY_PENALTY := rec.control_level;
      ELSIF l_attribute_name = 'OPERATION_SLACK_PENALTY'          THEN    A_OPERATION_SLACK_PENALTY := rec.control_level;
      ELSIF l_attribute_name = 'FINANCING_ALLOWED_FLAG'           THEN    A_FINANCING_ALLOWED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ITEM_TYPE'                    THEN    A_EAM_ITEM_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ACTIVITY_TYPE_CODE'           THEN    A_EAM_ACTIVITY_TYPE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ACTIVITY_CAUSE_CODE'          THEN    A_EAM_ACTIVITY_CAUSE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ACT_NOTIFICATION_FLAG'        THEN    A_EAM_ACT_NOTIFICATION_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ACT_SHUTDOWN_STATUS'          THEN    A_EAM_ACT_SHUTDOWN_STATUS := rec.control_level;
      ELSIF l_attribute_name = 'DUAL_UOM_CONTROL'                 THEN    A_DUAL_UOM_CONTROL := rec.control_level;
      ELSIF l_attribute_name = 'SECONDARY_UOM_CODE'               THEN    A_SECONDARY_UOM_CODE := rec.control_level;
      ELSIF l_attribute_name = 'DUAL_UOM_DEVIATION_HIGH'          THEN    A_DUAL_UOM_DEVIATION_HIGH := rec.control_level;
      ELSIF l_attribute_name = 'DUAL_UOM_DEVIATION_LOW'           THEN    A_DUAL_UOM_DEVIATION_LOW := rec.control_level;
      ELSIF l_attribute_name = 'CONTRACT_ITEM_TYPE_CODE'          THEN    A_CONTRACT_ITEM_TYPE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SERV_REQ_ENABLED_CODE'            THEN    A_SERV_REQ_ENABLED_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SERV_BILLING_ENABLED_FLAG'        THEN    A_SERV_BILLING_ENABLED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'PLANNED_INV_POINT_FLAG'           THEN    A_PLANNED_INV_POINT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'LOT_TRANSLATE_ENABLED'            THEN    A_LOT_TRANSLATE_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'DEFAULT_SO_SOURCE_TYPE'           THEN    A_DEFAULT_SO_SOURCE_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'CREATE_SUPPLY_FLAG'               THEN    A_CREATE_SUPPLY_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'SUBSTITUTION_WINDOW_CODE'         THEN    A_SUBSTITUTION_WINDOW_CODE := rec.control_level;
      ELSIF l_attribute_name = 'SUBSTITUTION_WINDOW_DAYS'         THEN    A_SUBSTITUTION_WINDOW_DAYS := rec.control_level;
      --Added as part of 11.5.9
      ELSIF l_attribute_name = 'LOT_SUBSTITUTION_ENABLED'         THEN    A_LOT_SUBSTITUTION_ENABLED := rec.control_level;
      ELSIF l_attribute_name = 'MINIMUM_LICENSE_QUANTITY'         THEN    A_MINIMUM_LICENSE_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'EAM_ACTIVITY_SOURCE_CODE'         THEN    A_EAM_ACTIVITY_SOURCE_CODE := rec.control_level;
      ELSIF l_attribute_name = 'IB_ITEM_INSTANCE_CLASS'           THEN    A_IB_ITEM_INSTANCE_CLASS := rec.control_level;
      ELSIF l_attribute_name = 'CONFIG_MODEL_TYPE'                THEN    A_CONFIG_MODEL_TYPE := rec.control_level;
      --Added as part of 11.5.10
      ELSIF l_attribute_name = 'TRACKING_QUANTITY_IND'            THEN    A_TRACKING_QUANTITY_IND := rec.control_level;
      ELSIF l_attribute_name = 'ONT_PRICING_QTY_SOURCE'           THEN    A_ONT_PRICING_QTY_SOURCE := rec.control_level;
      ELSIF l_attribute_name = 'SECONDARY_DEFAULT_IND'            THEN    A_SECONDARY_DEFAULT_IND := rec.control_level;
      ELSIF l_attribute_name = 'AUTO_CREATED_CONFIG_FLAG'         THEN    A_AUTO_CREATED_CONFIG_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CONFIG_ORGS'                      THEN    A_CONFIG_ORGS := rec.control_level;
      ELSIF l_attribute_name = 'CONFIG_MATCH'                     THEN    A_CONFIG_MATCH := rec.control_level;
      ELSIF l_attribute_name = 'VMI_MINIMUM_UNITS'                THEN    A_VMI_MINIMUM_UNITS := rec.control_level;
      ELSIF l_attribute_name = 'VMI_MINIMUM_DAYS'                 THEN    A_VMI_MINIMUM_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'VMI_MAXIMUM_UNITS'                THEN    A_VMI_MAXIMUM_UNITS := rec.control_level;
      ELSIF l_attribute_name = 'VMI_MAXIMUM_DAYS'                 THEN    A_VMI_MAXIMUM_DAYS := rec.control_level;
      ELSIF l_attribute_name = 'VMI_FIXED_ORDER_QUANTITY'         THEN    A_VMI_FIXED_ORDER_QUANTITY := rec.control_level;
      ELSIF l_attribute_name = 'SO_AUTHORIZATION_FLAG'            THEN    A_SO_AUTHORIZATION_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CONSIGNED_FLAG'                   THEN    A_CONSIGNED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'ASN_AUTOEXPIRE_FLAG'              THEN    A_ASN_AUTOEXPIRE_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'VMI_FORECAST_TYPE'                THEN    A_VMI_FORECAST_TYPE := rec.control_level;
      ELSIF l_attribute_name = 'FORECAST_HORIZON'                 THEN    A_FORECAST_HORIZON := rec.control_level;
      ELSIF l_attribute_name = 'EXCLUDE_FROM_BUDGET_FLAG'         THEN    A_EXCLUDE_FROM_BUDGET_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_TGT_INV_SUPPLY'              THEN    A_DAYS_TGT_INV_SUPPLY := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_TGT_INV_WINDOW'              THEN    A_DAYS_TGT_INV_WINDOW := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_MAX_INV_SUPPLY'              THEN    A_DAYS_MAX_INV_SUPPLY := rec.control_level;
      ELSIF l_attribute_name = 'DAYS_MAX_INV_WINDOW'              THEN    A_DAYS_MAX_INV_WINDOW := rec.control_level;
      ELSIF l_attribute_name = 'DRP_PLANNED_FLAG'                 THEN    A_DRP_PLANNED_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CRITICAL_COMPONENT_FLAG'          THEN    A_CRITICAL_COMPONENT_FLAG := rec.control_level;
      ELSIF l_attribute_name = 'CONTINOUS_TRANSFER'               THEN    A_CONTINOUS_TRANSFER:= rec.control_level;
      ELSIF l_attribute_name = 'CONVERGENCE'                      THEN    A_CONVERGENCE:= rec.control_level;
      ELSIF l_attribute_name = 'DIVERGENCE'                       THEN    A_DIVERGENCE:= rec.control_level;
      ---Begin Bug 3713912
       ELSIF l_attribute_name = 'LOT_DIVISIBLE_FLAG'              THEN    A_LOT_DIVISIBLE_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'GRADE_CONTROL_FLAG'              THEN    A_GRADE_CONTROL_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'DEFAULT_GRADE'                   THEN    A_DEFAULT_GRADE := rec.control_level;
       ELSIF l_attribute_name = 'CHILD_LOT_FLAG'                  THEN    A_CHILD_LOT_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'PARENT_CHILD_GENERATION_FLAG'    THEN    A_PARENT_CHILD_GENERATION_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'CHILD_LOT_PREFIX'                THEN    A_CHILD_LOT_PREFIX := rec.control_level;
       ELSIF l_attribute_name = 'CHILD_LOT_STARTING_NUMBER'       THEN    A_CHILD_LOT_STARTING_NUMBER := rec.control_level;
       ELSIF l_attribute_name = 'CHILD_LOT_VALIDATION_FLAG'       THEN    A_CHILD_LOT_VALIDATION_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'COPY_LOT_ATTRIBUTE_FLAG'         THEN    A_COPY_LOT_ATTRIBUTE_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'RECIPE_ENABLED_FLAG'             THEN    A_RECIPE_ENABLED_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_QUALITY_ENABLED_FLAG'    THEN    A_PROCESS_QUALITY_ENABLED_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_EXECUTION_ENABLED_FLAG'  THEN    A_PROCESS_EXEC_ENABLED_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_COSTING_ENABLED_FLAG'    THEN    A_PROCESS_COSTING_ENABLED_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_SUPPLY_SUBINVENTORY'     THEN    A_PROCESS_SUPPLY_SUBINVENTORY := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_SUPPLY_LOCATOR_ID'       THEN    A_PROCESS_SUPPLY_LOCATOR_ID := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_YIELD_SUBINVENTORY'      THEN    A_PROCESS_YIELD_SUBINVENTORY := rec.control_level;
       ELSIF l_attribute_name = 'PROCESS_YIELD_LOCATOR_ID'        THEN    A_PROCESS_YIELD_LOCATOR_ID := rec.control_level;
       ELSIF l_attribute_name = 'HAZARDOUS_MATERIAL_FLAG'         THEN    A_HAZARDOUS_MATERIAL_FLAG := rec.control_level;
       ELSIF l_attribute_name = 'CAS_NUMBER'                      THEN    A_CAS_NUMBER := rec.control_level;
       ELSIF l_attribute_name = 'RETEST_INTERVAL'                 THEN    A_RETEST_INTERVAL := rec.control_level;
       ELSIF l_attribute_name = 'EXPIRATION_ACTION_INTERVAL'      THEN    A_EXPIRATION_ACTION_INTERVAL := rec.control_level;
       ELSIF l_attribute_name = 'EXPIRATION_ACTION_CODE'          THEN    A_EXPIRATION_ACTION_CODE := rec.control_level;
       ELSIF l_attribute_name = 'MATURITY_DAYS'                   THEN    A_MATURITY_DAYS := rec.control_level;
       ELSIF l_attribute_name = 'HOLD_DAYS'                       THEN    A_HOLD_DAYS := rec.control_level;
       -- End Bug 3713912
       --R12 Enhancement
       ELSIF l_attribute_name = 'CHARGE_PERIODICITY_CODE'         THEN    A_CHARGE_PERIODICITY_CODE := rec.control_level;
       ELSIF l_attribute_name = 'REPAIR_LEADTIME'                 THEN    A_REPAIR_LEADTIME := rec.control_level;
       ELSIF l_attribute_name = 'REPAIR_YIELD'                    THEN    A_REPAIR_YIELD := rec.control_level;
       ELSIF l_attribute_name = 'PREPOSITION_POINT'               THEN    A_PREPOSITION_POINT := rec.control_level;
       ELSIF l_attribute_name = 'REPAIR_PROGRAM'                  THEN    A_REPAIR_PROGRAM := rec.control_level;
       ELSIF l_attribute_name = 'SUBCONTRACTING_COMPONENT'        THEN    A_SUBCONTRACTING_COMPONENT := rec.control_level;
       ELSIF l_attribute_name = 'OUTSOURCED_ASSEMBLY'             THEN    A_OUTSOURCED_ASSEMBLY := rec.control_level;
       END IF;

    End loop;
-- End of bug fix 3005880

     --5351611
    tmp_xset_id := xset_id ;

        for rec in C_msii_master_records loop

                t_trans_id := rec.transaction_id;
                -- master record validation here

        tmp_xset_id := tmp_xset_id +1 ; --5351611

        -- call additional update validations on master record
                ret_code_update :=  INVUPD2B.update_validations(
                                                rec.ROWID,
                                                rec.ORGANIZATION_ID,
                                                t_trans_id,
                                                user_id,
                                                login_id,
                                                prog_appid,
                                                prog_id,
                                                request_id);
--Bug3994245 If validations fail on the master item then AUTO_CHILD records should not be created-Anmurali
               SELECT process_flag into m_process_flag
               FROM mtl_system_items_interface
               WHERE rowid = rec.rowid;


                if (ret_code_update = 0 AND m_process_flag=4) THEN
                        ret_code := INVUPD2B.check_child_records(
                                        rec.ROWID,
                                        rec.INVENTORY_ITEM_ID,
                                        rec.ORGANIZATION_ID,
                                        t_trans_id,
                                        prog_appid,
                                        prog_id,
                                        request_id,
                                        user_id,
                                        login_id,
                                        err_text,
                    tmp_xset_id); --5351611
                    -- xset_id);

             --5351611
             -- Bug 10404086 : Added below hint
             update /*+ first_rows index(MTL_SYSTEM_ITEMS_INTERFACE,MTL_SYSTEM_ITEMS_INTERFACE_N3) */
             mtl_system_items_interface
             set set_process_id = xset_id + 1000000000000
                     where set_process_id = tmp_xset_id + 1000000000000 ; --5405867

                        if (ret_code = 0) then
                                update mtl_system_items_interface
                                   set process_flag = 4
                                 where inventory_item_id = rec.inventory_item_id
                                   and SET_PROCESS_ID = xset_id + 1000000000000
                                   and TRANSACTION_TYPE = 'AUTO_CHILD';

                        else
                                -- flag error in master msii record as child record validation is violated by master record update request
                                dumm_status  := INVPUOPI.mtl_log_interface_err(
                                        rec.ORGANIZATION_ID,
                                        user_id,
                                        login_id,
                                        prog_appid,
                                        prog_id,
                                        request_id,
                                        t_trans_id,
                                        error_text,
                                        null,
                                        'MTL_SYSTEM_ITEMS_INTERFACE',
                                        'INV_CHILD_VIOLATION_ERROR',
                                        err_text);
                                dumm_status := INVUPD2B.set_process_flag3(rec.ROWID,user_id,login_id,prog_appid,prog_id,request_id);
                        end if;

                end if;

        end loop;  -- msii_master loop

   RETURN (0);

EXCEPTION

   when NO_DATA_FOUND then
      return (0);

   -- No master record updates found
   when OTHERS then
      --bug #4251913: Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
                   Substr(
                  'When OTHERS exception raised in validate_item_update_master ' ||
                   SQLCODE ||
                   ' - '   ||
                   SQLERRM,1,240));
      END IF;
      return (1);

END validate_item_update_master;

--Bug: 5437967 This procedure prevents insertion of child records
--             in msii if no Master Controlled Attribute is changed in Master Org
PROCEDURE Check_create_child_records
(
   mast_rowid                    ROWID,
   item_id                       NUMBER,
   org_id                        NUMBER,
   check_create_child OUT NOCOPY BOOLEAN
) IS

   -- Bug 10404086 : Start
   /*
   CURSOR c_master_attributes IS
      SELECT SUBSTR(ATTRIBUTE_NAME,18) Attribute_Code
      FROM MTL_ITEM_ATTRIBUTES
      WHERE CONTROL_LEVEL = 1
        AND (ATTRIBUTE_GROUP_ID_GUI IN
                    (20, 25, 30, 31, 35, 40, 41, 51, 60,
                     62, 65, 70, 80, 90, 100, 120, 130));

   l_Attribute_Code           mtl_item_attributes.attribute_name%TYPE;
   */
   m_Item_rec                 MTL_SYSTEM_ITEMS_INTERFACE%ROWTYPE;
   l_Item_rec                 MTL_SYSTEM_ITEMS_VL%ROWTYPE;
   l_create_child             BOOLEAN := FALSE;

BEGIN

   INVPUTLI.info('INVUPD2 : Begin Check create auto child ' );
   SELECT * INTO m_Item_rec
   FROM mtl_system_items_interface
   WHERE rowid = mast_rowid;

   SELECT * INTO l_Item_rec
   FROM mtl_system_items_vl
   WHERE inventory_item_id = item_id
     AND organization_id = org_id;


   -- Bug 10404086 : Start - Changed the cusror into bulk collect.
   IF (g_attribute_code IS NULL OR g_attribute_code.Count = 0) THEN
      SELECT SUBSTR(ATTRIBUTE_NAME,18)
      BULK COLLECT INTO  g_attribute_code
      FROM MTL_ITEM_ATTRIBUTES
      WHERE CONTROL_LEVEL = 1
      AND (ATTRIBUTE_GROUP_ID_GUI IN
          (20, 25, 30, 31, 35, 40, 41, 51, 60,
          62, 65, 70, 80, 90, 100, 120, 130));
    END IF;

   /*
   OPEN c_master_attributes;
   LOOP
      FETCH c_master_attributes INTO l_Attribute_Code;
      EXIT WHEN (c_master_attributes%NOTFOUND OR l_create_child=TRUE);
   */

    IF(g_attribute_code.Count > 0) THEN
      FOR i IN g_attribute_code.FIRST .. g_attribute_code.LAST
      LOOP
        IF l_create_child = TRUE THEN
          EXIT;
        END IF;

         IF ( g_attribute_code(i) = 'INVENTORY_ITEM_STATUS_CODE' AND (NVL(l_item_rec.INVENTORY_ITEM_STATUS_CODE,'!') <> NVL(m_item_rec.INVENTORY_ITEM_STATUS_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'HAZARD_CLASS_ID' AND (NVL(l_item_rec.HAZARD_CLASS_ID,-999999) <> NVL(m_item_rec.HAZARD_CLASS_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OUTSIDE_OPERATION_UOM_TYPE' AND (NVL(l_item_rec.OUTSIDE_OPERATION_UOM_TYPE,'!') <> NVL(m_item_rec.OUTSIDE_OPERATION_UOM_TYPE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'AUTO_LOT_ALPHA_PREFIX' AND (NVL(l_item_rec.AUTO_LOT_ALPHA_PREFIX,'!') <> NVL(m_item_rec.AUTO_LOT_ALPHA_PREFIX,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RESTRICT_LOCATORS_CODE' AND (NVL(l_item_rec.RESTRICT_LOCATORS_CODE,-999999) <> NVL(m_item_rec.RESTRICT_LOCATORS_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RESTRICT_SUBINVENTORIES_CODE' AND (NVL(l_item_rec.RESTRICT_SUBINVENTORIES_CODE,-999999) <> NVL(m_item_rec.RESTRICT_SUBINVENTORIES_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SHELF_LIFE_DAYS' AND (NVL(l_item_rec.SHELF_LIFE_DAYS,-999999) <> NVL(m_item_rec.SHELF_LIFE_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'START_AUTO_LOT_NUMBER' AND (NVL(l_item_rec.START_AUTO_LOT_NUMBER,'!') <> NVL(m_item_rec.START_AUTO_LOT_NUMBER,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'START_AUTO_SERIAL_NUMBER' AND (NVL(l_item_rec.START_AUTO_SERIAL_NUMBER,'!') <> NVL(m_item_rec.START_AUTO_SERIAL_NUMBER,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'STOCK_ENABLED_FLAG' AND (NVL(l_item_rec.STOCK_ENABLED_FLAG,'!') <> NVL(m_item_rec.STOCK_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_WEIGHT' AND (NVL(l_item_rec.UNIT_WEIGHT,-999999) <> NVL(m_item_rec.UNIT_WEIGHT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVENTORY_PLANNING_CODE' AND (NVL(l_item_rec.INVENTORY_PLANNING_CODE,-999999) <> NVL(m_item_rec.INVENTORY_PLANNING_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MIN_MINMAX_QUANTITY' AND (NVL(l_item_rec.MIN_MINMAX_QUANTITY,-999999) <> NVL(m_item_rec.MIN_MINMAX_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ACCEPTABLE_RATE_DECREASE' AND (NVL(l_item_rec.ACCEPTABLE_RATE_DECREASE,-999999) <> NVL(m_item_rec.ACCEPTABLE_RATE_DECREASE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNING_TIME_FENCE_DAYS' AND (NVL(l_item_rec.PLANNING_TIME_FENCE_DAYS,-999999) <> NVL(m_item_rec.PLANNING_TIME_FENCE_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FIXED_LEAD_TIME' AND (NVL(l_item_rec.FIXED_LEAD_TIME,-999999) <> NVL(m_item_rec.FIXED_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BUILD_IN_WIP_FLAG' AND (NVL(l_item_rec.BUILD_IN_WIP_FLAG,'!') <> NVL(m_item_rec.BUILD_IN_WIP_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ATP_FLAG' AND (NVL(l_item_rec.ATP_FLAG,'!') <> NVL(m_item_rec.ATP_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COLLATERAL_FLAG' AND (NVL(l_item_rec.COLLATERAL_FLAG,'!') <> NVL(m_item_rec.COLLATERAL_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PICK_COMPONENTS_FLAG' AND (NVL(l_item_rec.PICK_COMPONENTS_FLAG,'!') <> NVL(m_item_rec.PICK_COMPONENTS_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ACCOUNTING_RULE_ID' AND (NVL(l_item_rec.ACCOUNTING_RULE_ID,-999999) <> NVL(m_item_rec.ACCOUNTING_RULE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVOICING_RULE_ID' AND (NVL(l_item_rec.INVOICING_RULE_ID,-999999) <> NVL(m_item_rec.INVOICING_RULE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SALES_ACCOUNT' AND (NVL(l_item_rec.SALES_ACCOUNT,-999999) <> NVL(m_item_rec.SALES_ACCOUNT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PREVENTIVE_MAINTENANCE_FLAG' AND (NVL(l_item_rec.PREVENTIVE_MAINTENANCE_FLAG,'!') <> NVL(m_item_rec.PREVENTIVE_MAINTENANCE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RELEASE_TIME_FENCE_DAYS' AND (NVL(l_item_rec.RELEASE_TIME_FENCE_DAYS,-999999) <> NVL(m_item_rec.RELEASE_TIME_FENCE_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICE_STARTING_DELAY' AND (NVL(l_item_rec.SERVICE_STARTING_DELAY,-999999) <> NVL(m_item_rec.SERVICE_STARTING_DELAY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BASE_WARRANTY_SERVICE_ID' AND (NVL(l_item_rec.BASE_WARRANTY_SERVICE_ID,-999999) <> NVL(m_item_rec.BASE_WARRANTY_SERVICE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OVERCOMPLETION_TOLERANCE_TYPE' AND (NVL(l_item_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999) <> NVL(m_item_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OVER_SHIPMENT_TOLERANCE' AND (NVL(l_item_rec.OVER_SHIPMENT_TOLERANCE,-999999) <> NVL(m_item_rec.OVER_SHIPMENT_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNDER_SHIPMENT_TOLERANCE' AND (NVL(l_item_rec.UNDER_SHIPMENT_TOLERANCE,-999999) <> NVL(m_item_rec.UNDER_SHIPMENT_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_STATUS_ENABLED' AND (NVL(l_item_rec.LOT_STATUS_ENABLED,'!') <> NVL(m_item_rec.LOT_STATUS_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BULK_PICKED_FLAG' AND (NVL(l_item_rec.BULK_PICKED_FLAG,'!') <> NVL(m_item_rec.BULK_PICKED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVENTORY_CARRY_PENALTY' AND (NVL(l_item_rec.INVENTORY_CARRY_PENALTY,-999999) <> NVL(m_item_rec.INVENTORY_CARRY_PENALTY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNED_INV_POINT_FLAG' AND (NVL(l_item_rec.PLANNED_INV_POINT_FLAG,'!') <> NVL(m_item_rec.PLANNED_INV_POINT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ACTIVITY_SOURCE_CODE' AND (NVL(l_item_rec.EAM_ACTIVITY_SOURCE_CODE,'!') <> NVL(m_item_rec.EAM_ACTIVITY_SOURCE_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONFIG_MATCH' AND (NVL(l_item_rec.CONFIG_MATCH,'!') <> NVL(m_item_rec.CONFIG_MATCH,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_MINIMUM_DAYS' AND (NVL(l_item_rec.VMI_MINIMUM_DAYS,-999999) <> NVL(m_item_rec.VMI_MINIMUM_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_FORECAST_TYPE' AND (NVL(l_item_rec.VMI_FORECAST_TYPE,-999999) <> NVL(m_item_rec.VMI_FORECAST_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_TGT_INV_SUPPLY' AND (NVL(l_item_rec.DAYS_TGT_INV_SUPPLY,-999999) <> NVL(m_item_rec.DAYS_TGT_INV_SUPPLY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONVERGENCE' AND (NVL(l_item_rec.CONVERGENCE,-999999) <> NVL(m_item_rec.CONVERGENCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHILD_LOT_PREFIX' AND (NVL(l_item_rec.CHILD_LOT_PREFIX,'!') <> NVL(m_item_rec.CHILD_LOT_PREFIX,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PREPOSITION_POINT' AND (NVL(l_item_rec.PREPOSITION_POINT,'!') <> NVL(m_item_rec.PREPOSITION_POINT,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_YIELD_SUBINVENTORY' AND (NVL(l_item_rec.PROCESS_YIELD_SUBINVENTORY,'!') <> NVL(m_item_rec.PROCESS_YIELD_SUBINVENTORY,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DESCRIPTION' AND (NVL(l_item_rec.DESCRIPTION,'!') <> NVL(m_item_rec.DESCRIPTION,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ALLOWED_UNITS_LOOKUP_CODE' AND (NVL(l_item_rec.ALLOWED_UNITS_LOOKUP_CODE,-999999) <> NVL(m_item_rec.ALLOWED_UNITS_LOOKUP_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COSTING_ENABLED_FLAG' AND (NVL(l_item_rec.COSTING_ENABLED_FLAG,'!') <> NVL(m_item_rec.COSTING_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_INCLUDE_IN_ROLLUP_FLAG' AND (NVL(l_item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!') <> NVL(m_item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PRICE_TOLERANCE_PERCENT' AND (NVL(l_item_rec.PRICE_TOLERANCE_PERCENT,-999999) <> NVL(m_item_rec.PRICE_TOLERANCE_PERCENT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ROUNDING_FACTOR' AND (NVL(l_item_rec.ROUNDING_FACTOR,-999999) <> NVL(m_item_rec.ROUNDING_FACTOR,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_OF_ISSUE' AND (NVL(l_item_rec.UNIT_OF_ISSUE,'!') <> NVL(m_item_rec.UNIT_OF_ISSUE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INSPECTION_REQUIRED_FLAG' AND (NVL(l_item_rec.INSPECTION_REQUIRED_FLAG,'!') <> NVL(m_item_rec.INSPECTION_REQUIRED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVOICE_CLOSE_TOLERANCE' AND (NVL(l_item_rec.INVOICE_CLOSE_TOLERANCE,-999999) <> NVL(m_item_rec.INVOICE_CLOSE_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SHELF_LIFE_CODE' AND (NVL(l_item_rec.SHELF_LIFE_CODE,-999999) <> NVL(m_item_rec.SHELF_LIFE_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CUMULATIVE_TOTAL_LEAD_TIME' AND (NVL(l_item_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999) <> NVL(m_item_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'POSTPROCESSING_LEAD_TIME' AND (NVL(l_item_rec.POSTPROCESSING_LEAD_TIME,-999999) <> NVL(m_item_rec.POSTPROCESSING_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INTERNAL_ORDER_FLAG' AND (NVL(l_item_rec.INTERNAL_ORDER_FLAG,'!') <> NVL(m_item_rec.INTERNAL_ORDER_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SO_TRANSACTIONS_FLAG' AND (NVL(l_item_rec.SO_TRANSACTIONS_FLAG,'!') <> NVL(m_item_rec.SO_TRANSACTIONS_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WARRANTY_VENDOR_ID' AND (NVL(l_item_rec.WARRANTY_VENDOR_ID,-999999) <> NVL(m_item_rec.WARRANTY_VENDOR_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'NEW_REVISION_CODE' AND (NVL(l_item_rec.NEW_REVISION_CODE,'!') <> NVL(m_item_rec.NEW_REVISION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PRIMARY_SPECIALIST_ID' AND (NVL(l_item_rec.PRIMARY_SPECIALIST_ID,-999999) <> NVL(m_item_rec.PRIMARY_SPECIALIST_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PURCHASING_TAX_CODE' AND (NVL(l_item_rec.PURCHASING_TAX_CODE,'!') <> NVL(m_item_rec.PURCHASING_TAX_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EVENT_FLAG' AND (NVL(l_item_rec.EVENT_FLAG,'!') <> NVL(m_item_rec.EVENT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BACK_ORDERABLE_FLAG' AND (NVL(l_item_rec.BACK_ORDERABLE_FLAG,'!') <> NVL(m_item_rec.BACK_ORDERABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INDIVISIBLE_FLAG' AND (NVL(l_item_rec.INDIVISIBLE_FLAG,'!') <> NVL(m_item_rec.INDIVISIBLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DIMENSION_UOM_CODE' AND (NVL(l_item_rec.DIMENSION_UOM_CODE,'!') <> NVL(m_item_rec.DIMENSION_UOM_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ITEM_TYPE' AND (NVL(l_item_rec.EAM_ITEM_TYPE,-999999) <> NVL(m_item_rec.EAM_ITEM_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_SO_SOURCE_TYPE' AND (NVL(l_item_rec.DEFAULT_SO_SOURCE_TYPE,'!') <> NVL(m_item_rec.DEFAULT_SO_SOURCE_TYPE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERV_BILLING_ENABLED_FLAG' AND (NVL(l_item_rec.SERV_BILLING_ENABLED_FLAG,'!') <> NVL(m_item_rec.SERV_BILLING_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_SUBSTITUTION_ENABLED' AND (NVL(l_item_rec.LOT_SUBSTITUTION_ENABLED,'!') <> NVL(m_item_rec.LOT_SUBSTITUTION_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_FIXED_ORDER_QUANTITY' AND (NVL(l_item_rec.VMI_FIXED_ORDER_QUANTITY,-999999) <> NVL(m_item_rec.VMI_FIXED_ORDER_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EXCLUDE_FROM_BUDGET_FLAG' AND (NVL(l_item_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999) <> NVL(m_item_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_DIVISIBLE_FLAG' AND (NVL(l_item_rec.LOT_DIVISIBLE_FLAG,'!') <> NVL(m_item_rec.LOT_DIVISIBLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OUTSOURCED_ASSEMBLY' AND (NVL(l_item_rec.OUTSOURCED_ASSEMBLY,-999999) <> NVL(m_item_rec.OUTSOURCED_ASSEMBLY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REPAIR_YIELD' AND (NVL(l_item_rec.REPAIR_YIELD,-999999) <> NVL(m_item_rec.REPAIR_YIELD,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_QUALITY_ENABLED_FLAG' AND (NVL(l_item_rec.PROCESS_QUALITY_ENABLED_FLAG,'!') <> NVL(m_item_rec.PROCESS_QUALITY_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CAS_NUMBER' AND (NVL(l_item_rec.CAS_NUMBER,'!') <> NVL(m_item_rec.CAS_NUMBER,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ENG_ITEM_FLAG' AND (NVL(l_item_rec.ENG_ITEM_FLAG,'!') <> NVL(m_item_rec.ENG_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COST_OF_SALES_ACCOUNT' AND (NVL(l_item_rec.COST_OF_SALES_ACCOUNT,-999999) <> NVL(m_item_rec.COST_OF_SALES_ACCOUNT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ALLOW_EXPRESS_DELIVERY_FLAG' AND (NVL(l_item_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!') <> NVL(m_item_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECEIPT_DAYS_EXCEPTION_CODE' AND (NVL(l_item_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!') <> NVL(m_item_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECEIPT_REQUIRED_FLAG' AND (NVL(l_item_rec.RECEIPT_REQUIRED_FLAG,'!') <> NVL(m_item_rec.RECEIPT_REQUIRED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECEIVING_ROUTING_ID' AND (NVL(l_item_rec.RECEIVING_ROUTING_ID,-999999) <> NVL(m_item_rec.RECEIVING_ROUTING_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVENTORY_ITEM_FLAG' AND (NVL(l_item_rec.INVENTORY_ITEM_FLAG,'!') <> NVL(m_item_rec.INVENTORY_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOCATION_CONTROL_CODE' AND (NVL(l_item_rec.LOCATION_CONTROL_CODE,-999999) <> NVL(m_item_rec.LOCATION_CONTROL_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REVISION_QTY_CONTROL_CODE' AND (NVL(l_item_rec.REVISION_QTY_CONTROL_CODE,-999999) <> NVL(m_item_rec.REVISION_QTY_CONTROL_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MRP_SAFETY_STOCK_PERCENT' AND (NVL(l_item_rec.MRP_SAFETY_STOCK_PERCENT,-999999) <> NVL(m_item_rec.MRP_SAFETY_STOCK_PERCENT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SAFETY_STOCK_BUCKET_DAYS' AND (NVL(l_item_rec.SAFETY_STOCK_BUCKET_DAYS,-999999) <> NVL(m_item_rec.SAFETY_STOCK_BUCKET_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OVERRUN_PERCENTAGE' AND (NVL(l_item_rec.OVERRUN_PERCENTAGE,-999999) <> NVL(m_item_rec.OVERRUN_PERCENTAGE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNING_EXCEPTION_SET' AND (NVL(l_item_rec.PLANNING_EXCEPTION_SET,'!') <> NVL(m_item_rec.PLANNING_EXCEPTION_SET,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNING_TIME_FENCE_CODE' AND (NVL(l_item_rec.PLANNING_TIME_FENCE_CODE,-999999) <> NVL(m_item_rec.PLANNING_TIME_FENCE_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ROUNDING_CONTROL_TYPE' AND (NVL(l_item_rec.ROUNDING_CONTROL_TYPE,-999999) <> NVL(m_item_rec.ROUNDING_CONTROL_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SHIP_MODEL_COMPLETE_FLAG' AND (NVL(l_item_rec.SHIP_MODEL_COMPLETE_FLAG,'!') <> NVL(m_item_rec.SHIP_MODEL_COMPLETE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVOICEABLE_ITEM_FLAG' AND (NVL(l_item_rec.INVOICEABLE_ITEM_FLAG,'!') <> NVL(m_item_rec.INVOICEABLE_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COVERAGE_SCHEDULE_ID' AND (NVL(l_item_rec.COVERAGE_SCHEDULE_ID,-999999) <> NVL(m_item_rec.COVERAGE_SCHEDULE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PRORATE_SERVICE_FLAG' AND (NVL(l_item_rec.PRORATE_SERVICE_FLAG,'!') <> NVL(m_item_rec.PRORATE_SERVICE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICE_DURATION_PERIOD_CODE' AND (NVL(l_item_rec.SERVICE_DURATION_PERIOD_CODE,'!') <> NVL(m_item_rec.SERVICE_DURATION_PERIOD_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ATO_FORECAST_CONTROL' AND (NVL(l_item_rec.ATO_FORECAST_CONTROL,-999999) <> NVL(m_item_rec.ATO_FORECAST_CONTROL,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OUTSIDE_OPERATION_FLAG' AND (NVL(l_item_rec.OUTSIDE_OPERATION_FLAG,'!') <> NVL(m_item_rec.OUTSIDE_OPERATION_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CARRYING_COST' AND (NVL(l_item_rec.CARRYING_COST,-999999) <> NVL(m_item_rec.CARRYING_COST,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MRP_SAFETY_STOCK_CODE' AND (NVL(l_item_rec.MRP_SAFETY_STOCK_CODE,-999999) <> NVL(m_item_rec.MRP_SAFETY_STOCK_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SOURCE_ORGANIZATION_ID' AND (NVL(l_item_rec.SOURCE_ORGANIZATION_ID,-999999) <> NVL(m_item_rec.SOURCE_ORGANIZATION_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OVER_RETURN_TOLERANCE' AND (NVL(l_item_rec.OVER_RETURN_TOLERANCE,-999999) <> NVL(m_item_rec.OVER_RETURN_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ASSET_CREATION_CODE' AND (NVL(l_item_rec.ASSET_CREATION_CODE,'!') <> NVL(m_item_rec.ASSET_CREATION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COMMS_ACTIVATION_REQD_FLAG' AND (NVL(l_item_rec.COMMS_ACTIVATION_REQD_FLAG,'!') <> NVL(m_item_rec.COMMS_ACTIVATION_REQD_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHECK_SHORTAGES_FLAG' AND (NVL(l_item_rec.CHECK_SHORTAGES_FLAG,'!') <> NVL(m_item_rec.CHECK_SHORTAGES_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_MERGE_ENABLED' AND (NVL(l_item_rec.LOT_MERGE_ENABLED,'!') <> NVL(m_item_rec.LOT_MERGE_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_LENGTH' AND (NVL(l_item_rec.UNIT_LENGTH,-999999) <> NVL(m_item_rec.UNIT_LENGTH,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ACT_NOTIFICATION_FLAG' AND (NVL(l_item_rec.EAM_ACT_NOTIFICATION_FLAG,'!') <> NVL(m_item_rec.EAM_ACT_NOTIFICATION_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SUBSTITUTION_WINDOW_CODE' AND (NVL(l_item_rec.SUBSTITUTION_WINDOW_CODE,-999999) <> NVL(m_item_rec.SUBSTITUTION_WINDOW_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHILD_LOT_STARTING_NUMBER' AND (NVL(l_item_rec.CHILD_LOT_STARTING_NUMBER,-999999) <> NVL(m_item_rec.CHILD_LOT_STARTING_NUMBER,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EXPIRATION_ACTION_INTERVAL' AND (NVL(l_item_rec.EXPIRATION_ACTION_INTERVAL,-999999) <> NVL(m_item_rec.EXPIRATION_ACTION_INTERVAL,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SUBCONTRACTING_COMPONENT' AND (NVL(l_item_rec.SUBCONTRACTING_COMPONENT,-999999) <> NVL(m_item_rec.SUBCONTRACTING_COMPONENT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'HAZARDOUS_MATERIAL_FLAG' AND (NVL(l_item_rec.HAZARDOUS_MATERIAL_FLAG,'!') <> NVL(m_item_rec.HAZARDOUS_MATERIAL_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ITEM_TYPE' AND (NVL(l_item_rec.ITEM_TYPE,'!') <> NVL(m_item_rec.ITEM_TYPE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ENCUMBRANCE_ACCOUNT' AND (NVL(l_item_rec.ENCUMBRANCE_ACCOUNT,-999999) <> NVL(m_item_rec.ENCUMBRANCE_ACCOUNT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MARKET_PRICE' AND (NVL(l_item_rec.MARKET_PRICE,-999999) <> NVL(m_item_rec.MARKET_PRICE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'TAXABLE_FLAG' AND (NVL(l_item_rec.TAXABLE_FLAG,'!') <> NVL(m_item_rec.TAXABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'QTY_RCV_TOLERANCE' AND (NVL(l_item_rec.QTY_RCV_TOLERANCE,-999999) <> NVL(m_item_rec.QTY_RCV_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'NEGATIVE_MEASUREMENT_ERROR' AND (NVL(l_item_rec.NEGATIVE_MEASUREMENT_ERROR,-999999) <> NVL(m_item_rec.NEGATIVE_MEASUREMENT_ERROR,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'POSITIVE_MEASUREMENT_ERROR' AND (NVL(l_item_rec.POSITIVE_MEASUREMENT_ERROR,-999999) <> NVL(m_item_rec.POSITIVE_MEASUREMENT_ERROR,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MAXIMUM_ORDER_QUANTITY' AND (NVL(l_item_rec.MAXIMUM_ORDER_QUANTITY,-999999) <> NVL(m_item_rec.MAXIMUM_ORDER_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'AUTO_REDUCE_MPS' AND (NVL(l_item_rec.AUTO_REDUCE_MPS,-999999) <> NVL(m_item_rec.AUTO_REDUCE_MPS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FULL_LEAD_TIME' AND (NVL(l_item_rec.FULL_LEAD_TIME,-999999) <> NVL(m_item_rec.FULL_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WIP_SUPPLY_LOCATOR_ID' AND (NVL(l_item_rec.WIP_SUPPLY_LOCATOR_ID,-999999) <> NVL(m_item_rec.WIP_SUPPLY_LOCATOR_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVOICE_ENABLED_FLAG' AND (NVL(l_item_rec.INVOICE_ENABLED_FLAG,'!') <> NVL(m_item_rec.INVOICE_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MATERIAL_BILLABLE_FLAG' AND (NVL(l_item_rec.MATERIAL_BILLABLE_FLAG,'!') <> NVL(m_item_rec.MATERIAL_BILLABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICEABLE_PRODUCT_FLAG' AND (NVL(l_item_rec.SERVICEABLE_PRODUCT_FLAG,'!') <> NVL(m_item_rec.SERVICEABLE_PRODUCT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OVERCOMPLETION_TOLERANCE_VALUE' AND (NVL(l_item_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999) <> NVL(m_item_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONTRACT_ITEM_TYPE_CODE' AND (NVL(l_item_rec.CONTRACT_ITEM_TYPE_CODE,'!') <> NVL(m_item_rec.CONTRACT_ITEM_TYPE_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MINIMUM_LICENSE_QUANTITY' AND (NVL(l_item_rec.MINIMUM_LICENSE_QUANTITY,-999999) <> NVL(m_item_rec.MINIMUM_LICENSE_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONFIG_ORGS' AND (NVL(l_item_rec.CONFIG_ORGS,'!') <> NVL(m_item_rec.CONFIG_ORGS,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_MAXIMUM_DAYS' AND (NVL(l_item_rec.VMI_MAXIMUM_DAYS,-999999) <> NVL(m_item_rec.VMI_MAXIMUM_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONTINOUS_TRANSFER' AND (NVL(l_item_rec.CONTINOUS_TRANSFER,-999999) <> NVL(m_item_rec.CONTINOUS_TRANSFER,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_GRADE' AND (NVL(l_item_rec.DEFAULT_GRADE,'!') <> NVL(m_item_rec.DEFAULT_GRADE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MATURITY_DAYS' AND (NVL(l_item_rec.MATURITY_DAYS,-999999) <> NVL(m_item_rec.MATURITY_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'HOLD_DAYS' AND (NVL(l_item_rec.HOLD_DAYS,-999999) <> NVL(m_item_rec.HOLD_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REPAIR_LEADTIME' AND (NVL(l_item_rec.REPAIR_LEADTIME,-999999) <> NVL(m_item_rec.REPAIR_LEADTIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECIPE_ENABLED_FLAG' AND (NVL(l_item_rec.RECIPE_ENABLED_FLAG,'!') <> NVL(m_item_rec.RECIPE_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_SUPPLY_LOCATOR_ID' AND (NVL(l_item_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999) <> NVL(m_item_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BASE_ITEM_ID' AND (NVL(l_item_rec.BASE_ITEM_ID,-999999) <> NVL(m_item_rec.BASE_ITEM_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'STD_LOT_SIZE' AND (NVL(l_item_rec.STD_LOT_SIZE,-999999) <> NVL(m_item_rec.STD_LOT_SIZE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ALLOW_ITEM_DESC_UPDATE_FLAG' AND (NVL(l_item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!') <> NVL(m_item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LIST_PRICE_PER_UNIT' AND (NVL(l_item_rec.LIST_PRICE_PER_UNIT,-999999) <> NVL(m_item_rec.LIST_PRICE_PER_UNIT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PURCHASING_ITEM_FLAG' AND (NVL(l_item_rec.PURCHASING_ITEM_FLAG,'!') <> NVL(m_item_rec.PURCHASING_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG' AND (NVL(l_item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!') <> NVL(m_item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ORDER_COST' AND (NVL(l_item_rec.ORDER_COST,-999999) <> NVL(m_item_rec.ORDER_COST,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEMAND_TIME_FENCE_DAYS' AND (NVL(l_item_rec.DEMAND_TIME_FENCE_DAYS,-999999) <> NVL(m_item_rec.DEMAND_TIME_FENCE_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MRP_CALCULATE_ATP_FLAG' AND (NVL(l_item_rec.MRP_CALCULATE_ATP_FLAG,'!') <> NVL(m_item_rec.MRP_CALCULATE_ATP_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CUM_MANUFACTURING_LEAD_TIME' AND (NVL(l_item_rec.CUM_MANUFACTURING_LEAD_TIME,-999999) <> NVL(m_item_rec.CUM_MANUFACTURING_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WIP_SUPPLY_SUBINVENTORY' AND (NVL(l_item_rec.WIP_SUPPLY_SUBINVENTORY,'!') <> NVL(m_item_rec.WIP_SUPPLY_SUBINVENTORY,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CUSTOMER_ORDER_ENABLED_FLAG' AND (NVL(l_item_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!') <> NVL(m_item_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_SHIPPING_ORG' AND (NVL(l_item_rec.DEFAULT_SHIPPING_ORG,-999999) <> NVL(m_item_rec.DEFAULT_SHIPPING_ORG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RETURNABLE_FLAG' AND (NVL(l_item_rec.RETURNABLE_FLAG,'!') <> NVL(m_item_rec.RETURNABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PAYMENT_TERMS_ID' AND (NVL(l_item_rec.PAYMENT_TERMS_ID,-999999) <> NVL(m_item_rec.PAYMENT_TERMS_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'TAX_CODE' AND (NVL(l_item_rec.TAX_CODE,'!') <> NVL(m_item_rec.TAX_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICE_DURATION' AND (NVL(l_item_rec.SERVICE_DURATION,-999999) <> NVL(m_item_rec.SERVICE_DURATION,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MAXIMUM_LOAD_WEIGHT' AND (NVL(l_item_rec.MAXIMUM_LOAD_WEIGHT,-999999) <> NVL(m_item_rec.MAXIMUM_LOAD_WEIGHT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MINIMUM_FILL_PERCENT' AND (NVL(l_item_rec.MINIMUM_FILL_PERCENT,-999999) <> NVL(m_item_rec.MINIMUM_FILL_PERCENT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_LATE_RECEIPT_ALLOWED' AND (NVL(l_item_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999) <> NVL(m_item_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REPLENISH_TO_ORDER_FLAG' AND (NVL(l_item_rec.REPLENISH_TO_ORDER_FLAG,'!') <> NVL(m_item_rec.REPLENISH_TO_ORDER_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONTAINER_TYPE_CODE' AND (NVL(l_item_rec.CONTAINER_TYPE_CODE,'!') <> NVL(m_item_rec.CONTAINER_TYPE_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFECT_TRACKING_ON_FLAG' AND (NVL(l_item_rec.DEFECT_TRACKING_ON_FLAG,'!') <> NVL(m_item_rec.DEFECT_TRACKING_ON_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ELECTRONIC_FLAG' AND (NVL(l_item_rec.ELECTRONIC_FLAG,'!') <> NVL(m_item_rec.ELECTRONIC_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VOL_DISCOUNT_EXEMPT_FLAG' AND (NVL(l_item_rec.VOL_DISCOUNT_EXEMPT_FLAG,'!') <> NVL(m_item_rec.VOL_DISCOUNT_EXEMPT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WEB_STATUS' AND (NVL(l_item_rec.WEB_STATUS,'!') <> NVL(m_item_rec.WEB_STATUS,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERIAL_STATUS_ENABLED' AND (NVL(l_item_rec.SERIAL_STATUS_ENABLED,'!') <> NVL(m_item_rec.SERIAL_STATUS_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_SERIAL_STATUS_ID' AND (NVL(l_item_rec.DEFAULT_SERIAL_STATUS_ID,-999999) <> NVL(m_item_rec.DEFAULT_SERIAL_STATUS_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_WIDTH' AND (NVL(l_item_rec.UNIT_WIDTH,-999999) <> NVL(m_item_rec.UNIT_WIDTH,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'OPERATION_SLACK_PENALTY' AND (NVL(l_item_rec.OPERATION_SLACK_PENALTY,-999999) <> NVL(m_item_rec.OPERATION_SLACK_PENALTY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LONG_DESCRIPTION' AND (NVL(l_item_rec.LONG_DESCRIPTION,'!') <> NVL(m_item_rec.LONG_DESCRIPTION,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ACTIVITY_TYPE_CODE' AND (NVL(l_item_rec.EAM_ACTIVITY_TYPE_CODE,'!') <> NVL(m_item_rec.EAM_ACTIVITY_TYPE_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CREATE_SUPPLY_FLAG' AND (NVL(l_item_rec.CREATE_SUPPLY_FLAG,'!') <> NVL(m_item_rec.CREATE_SUPPLY_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERV_REQ_ENABLED_CODE' AND (NVL(l_item_rec.SERV_REQ_ENABLED_CODE,'!') <> NVL(m_item_rec.SERV_REQ_ENABLED_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'IB_ITEM_INSTANCE_CLASS' AND (NVL(l_item_rec.IB_ITEM_INSTANCE_CLASS,'!') <> NVL(m_item_rec.IB_ITEM_INSTANCE_CLASS,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONSIGNED_FLAG' AND (NVL(l_item_rec.CONSIGNED_FLAG,-999999) <> NVL(m_item_rec.CONSIGNED_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CRITICAL_COMPONENT_FLAG' AND (NVL(l_item_rec.CRITICAL_COMPONENT_FLAG,-999999) <> NVL(m_item_rec.CRITICAL_COMPONENT_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHILD_LOT_VALIDATION_FLAG' AND (NVL(l_item_rec.CHILD_LOT_VALIDATION_FLAG,'!') <> NVL(m_item_rec.CHILD_LOT_VALIDATION_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_YIELD_LOCATOR_ID' AND (NVL(l_item_rec.PROCESS_YIELD_LOCATOR_ID,-999999) <> NVL(m_item_rec.PROCESS_YIELD_LOCATOR_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BOM_ENABLED_FLAG' AND (NVL(l_item_rec.BOM_ENABLED_FLAG,'!') <> NVL(m_item_rec.BOM_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ASSET_CATEGORY_ID' AND (NVL(l_item_rec.ASSET_CATEGORY_ID,-999999) <> NVL(m_item_rec.ASSET_CATEGORY_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BUYER_ID' AND (NVL(l_item_rec.BUYER_ID,-999999) <> NVL(m_item_rec.BUYER_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RFQ_REQUIRED_FLAG' AND (NVL(l_item_rec.RFQ_REQUIRED_FLAG,'!') <> NVL(m_item_rec.RFQ_REQUIRED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ALLOW_UNORDERED_RECEIPTS_FLAG' AND (NVL(l_item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!') <> NVL(m_item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_EARLY_RECEIPT_ALLOWED' AND (NVL(l_item_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999) <> NVL(m_item_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CYCLE_COUNT_ENABLED_FLAG' AND (NVL(l_item_rec.CYCLE_COUNT_ENABLED_FLAG,'!') <> NVL(m_item_rec.CYCLE_COUNT_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WEIGHT_UOM_CODE' AND (NVL(l_item_rec.WEIGHT_UOM_CODE,'!') <> NVL(m_item_rec.WEIGHT_UOM_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FIXED_ORDER_QUANTITY' AND (NVL(l_item_rec.FIXED_ORDER_QUANTITY,-999999) <> NVL(m_item_rec.FIXED_ORDER_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MAX_MINMAX_QUANTITY' AND (NVL(l_item_rec.MAX_MINMAX_QUANTITY,-999999) <> NVL(m_item_rec.MAX_MINMAX_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SOURCE_SUBINVENTORY' AND (NVL(l_item_rec.SOURCE_SUBINVENTORY,'!') <> NVL(m_item_rec.SOURCE_SUBINVENTORY,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REPETITIVE_PLANNING_FLAG' AND (NVL(l_item_rec.REPETITIVE_PLANNING_FLAG,'!') <> NVL(m_item_rec.REPETITIVE_PLANNING_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INTERNAL_ORDER_ENABLED_FLAG' AND (NVL(l_item_rec.INTERNAL_ORDER_ENABLED_FLAG,'!') <> NVL(m_item_rec.INTERNAL_ORDER_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PICKING_RULE_ID' AND (NVL(l_item_rec.PICKING_RULE_ID,-999999) <> NVL(m_item_rec.PICKING_RULE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SHIPPABLE_ITEM_FLAG' AND (NVL(l_item_rec.SHIPPABLE_ITEM_FLAG,'!') <> NVL(m_item_rec.SHIPPABLE_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MAX_WARRANTY_AMOUNT' AND (NVL(l_item_rec.MAX_WARRANTY_AMOUNT,-999999) <> NVL(m_item_rec.MAX_WARRANTY_AMOUNT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RESPONSE_TIME_VALUE' AND (NVL(l_item_rec.RESPONSE_TIME_VALUE,-999999) <> NVL(m_item_rec.RESPONSE_TIME_VALUE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INVENTORY_ASSET_FLAG' AND (NVL(l_item_rec.INVENTORY_ASSET_FLAG,'!') <> NVL(m_item_rec.INVENTORY_ASSET_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_VOLUME' AND (NVL(l_item_rec.UNIT_VOLUME,-999999) <> NVL(m_item_rec.UNIT_VOLUME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'END_ASSEMBLY_PEGGING_FLAG' AND (NVL(l_item_rec.END_ASSEMBLY_PEGGING_FLAG,'!') <> NVL(m_item_rec.END_ASSEMBLY_PEGGING_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VARIABLE_LEAD_TIME' AND (NVL(l_item_rec.VARIABLE_LEAD_TIME,-999999) <> NVL(m_item_rec.VARIABLE_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICEABLE_ITEM_CLASS_ID' AND (NVL(l_item_rec.SERVICEABLE_ITEM_CLASS_ID,-999999) <> NVL(m_item_rec.SERVICEABLE_ITEM_CLASS_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECOVERED_PART_DISP_CODE' AND (NVL(l_item_rec.RECOVERED_PART_DISP_CODE,'!') <> NVL(m_item_rec.RECOVERED_PART_DISP_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DOWNLOADABLE_FLAG' AND (NVL(l_item_rec.DOWNLOADABLE_FLAG,'!') <> NVL(m_item_rec.DOWNLOADABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_SPLIT_ENABLED' AND (NVL(l_item_rec.LOT_SPLIT_ENABLED,'!') <> NVL(m_item_rec.LOT_SPLIT_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNIT_HEIGHT' AND (NVL(l_item_rec.UNIT_HEIGHT,-999999) <> NVL(m_item_rec.UNIT_HEIGHT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ACT_SHUTDOWN_STATUS' AND (NVL(l_item_rec.EAM_ACT_SHUTDOWN_STATUS,'!') <> NVL(m_item_rec.EAM_ACT_SHUTDOWN_STATUS,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_TRANSLATE_ENABLED' AND (NVL(l_item_rec.LOT_TRANSLATE_ENABLED,'!') <> NVL(m_item_rec.LOT_TRANSLATE_ENABLED,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_MINIMUM_UNITS' AND (NVL(l_item_rec.VMI_MINIMUM_UNITS,-999999) <> NVL(m_item_rec.VMI_MINIMUM_UNITS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VMI_MAXIMUM_UNITS' AND (NVL(l_item_rec.VMI_MAXIMUM_UNITS,-999999) <> NVL(m_item_rec.VMI_MAXIMUM_UNITS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SO_AUTHORIZATION_FLAG' AND (NVL(l_item_rec.SO_AUTHORIZATION_FLAG,-999999) <> NVL(m_item_rec.SO_AUTHORIZATION_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_MAX_INV_WINDOW' AND (NVL(l_item_rec.DAYS_MAX_INV_WINDOW,-999999) <> NVL(m_item_rec.DAYS_MAX_INV_WINDOW,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_TGT_INV_WINDOW' AND (NVL(l_item_rec.DAYS_TGT_INV_WINDOW,-999999) <> NVL(m_item_rec.DAYS_TGT_INV_WINDOW,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'GRADE_CONTROL_FLAG' AND (NVL(l_item_rec.GRADE_CONTROL_FLAG,'!') <> NVL(m_item_rec.GRADE_CONTROL_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHILD_LOT_FLAG' AND (NVL(l_item_rec.CHILD_LOT_FLAG,'!') <> NVL(m_item_rec.CHILD_LOT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RETEST_INTERVAL' AND (NVL(l_item_rec.RETEST_INTERVAL,-999999) <> NVL(m_item_rec.RETEST_INTERVAL,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CHARGE_PERIODICITY_CODE' AND (NVL(l_item_rec.CHARGE_PERIODICITY_CODE,'!') <> NVL(m_item_rec.CHARGE_PERIODICITY_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'BOM_ITEM_TYPE' AND (NVL(l_item_rec.BOM_ITEM_TYPE,-999999) <> NVL(m_item_rec.BOM_ITEM_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MUST_USE_APPROVED_VENDOR_FLAG' AND (NVL(l_item_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!') <> NVL(m_item_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PURCHASING_ENABLED_FLAG' AND (NVL(l_item_rec.PURCHASING_ENABLED_FLAG,'!') <> NVL(m_item_rec.PURCHASING_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ENFORCE_SHIP_TO_LOCATION_CODE' AND (NVL(l_item_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!') <> NVL(m_item_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RESERVABLE_TYPE' AND (NVL(l_item_rec.RESERVABLE_TYPE,-999999) <> NVL(m_item_rec.RESERVABLE_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERIAL_NUMBER_CONTROL_CODE' AND (NVL(l_item_rec.SERIAL_NUMBER_CONTROL_CODE,-999999) <> NVL(m_item_rec.SERIAL_NUMBER_CONTROL_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FIXED_DAYS_SUPPLY' AND (NVL(l_item_rec.FIXED_DAYS_SUPPLY,-999999) <> NVL(m_item_rec.FIXED_DAYS_SUPPLY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FIXED_LOT_MULTIPLIER' AND (NVL(l_item_rec.FIXED_LOT_MULTIPLIER,-999999) <> NVL(m_item_rec.FIXED_LOT_MULTIPLIER,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MINIMUM_ORDER_QUANTITY' AND (NVL(l_item_rec.MINIMUM_ORDER_QUANTITY,-999999) <> NVL(m_item_rec.MINIMUM_ORDER_QUANTITY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNER_CODE' AND (NVL(l_item_rec.PLANNER_CODE,'!') <> NVL(m_item_rec.PLANNER_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SOURCE_TYPE' AND (NVL(l_item_rec.SOURCE_TYPE,-999999) <> NVL(m_item_rec.SOURCE_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MRP_PLANNING_CODE' AND (NVL(l_item_rec.MRP_PLANNING_CODE,-999999) <> NVL(m_item_rec.MRP_PLANNING_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SHRINKAGE_RATE' AND (NVL(l_item_rec.SHRINKAGE_RATE,-999999) <> NVL(m_item_rec.SHRINKAGE_RATE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PREPROCESSING_LEAD_TIME' AND (NVL(l_item_rec.PREPROCESSING_LEAD_TIME,-999999) <> NVL(m_item_rec.PREPROCESSING_LEAD_TIME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'WIP_SUPPLY_TYPE' AND (NVL(l_item_rec.WIP_SUPPLY_TYPE,-999999) <> NVL(m_item_rec.WIP_SUPPLY_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ATP_RULE_ID' AND (NVL(l_item_rec.ATP_RULE_ID,-999999) <> NVL(m_item_rec.ATP_RULE_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CUSTOMER_ORDER_FLAG' AND (NVL(l_item_rec.CUSTOMER_ORDER_FLAG,'!') <> NVL(m_item_rec.CUSTOMER_ORDER_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SECONDARY_SPECIALIST_ID' AND (NVL(l_item_rec.SECONDARY_SPECIALIST_ID,-999999) <> NVL(m_item_rec.SECONDARY_SPECIALIST_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'QTY_RCV_EXCEPTION_CODE' AND (NVL(l_item_rec.QTY_RCV_EXCEPTION_CODE,'!') <> NVL(m_item_rec.QTY_RCV_EXCEPTION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LOT_CONTROL_CODE' AND (NVL(l_item_rec.LOT_CONTROL_CODE,-999999) <> NVL(m_item_rec.LOT_CONTROL_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PLANNING_MAKE_BUY_CODE' AND (NVL(l_item_rec.PLANNING_MAKE_BUY_CODE,-999999) <> NVL(m_item_rec.PLANNING_MAKE_BUY_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'LEAD_TIME_LOT_SIZE' AND (NVL(l_item_rec.LEAD_TIME_LOT_SIZE,-999999) <> NVL(m_item_rec.LEAD_TIME_LOT_SIZE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SERVICEABLE_COMPONENT_FLAG' AND (NVL(l_item_rec.SERVICEABLE_COMPONENT_FLAG,'!') <> NVL(m_item_rec.SERVICEABLE_COMPONENT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UNDER_RETURN_TOLERANCE' AND (NVL(l_item_rec.UNDER_RETURN_TOLERANCE,-999999) <> NVL(m_item_rec.UNDER_RETURN_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EQUIPMENT_TYPE' AND (NVL(l_item_rec.EQUIPMENT_TYPE,-999999) <> NVL(m_item_rec.EQUIPMENT_TYPE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEFAULT_LOT_STATUS_ID' AND (NVL(l_item_rec.DEFAULT_LOT_STATUS_ID,-999999) <> NVL(m_item_rec.DEFAULT_LOT_STATUS_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FINANCING_ALLOWED_FLAG' AND (NVL(l_item_rec.FINANCING_ALLOWED_FLAG,'!') <> NVL(m_item_rec.FINANCING_ALLOWED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DUAL_UOM_CONTROL' AND (NVL(l_item_rec.DUAL_UOM_CONTROL,-999999) <> NVL(m_item_rec.DUAL_UOM_CONTROL,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EAM_ACTIVITY_CAUSE_CODE' AND (NVL(l_item_rec.EAM_ACTIVITY_CAUSE_CODE,'!') <> NVL(m_item_rec.EAM_ACTIVITY_CAUSE_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'SUBSTITUTION_WINDOW_DAYS' AND (NVL(l_item_rec.SUBSTITUTION_WINDOW_DAYS,-999999) <> NVL(m_item_rec.SUBSTITUTION_WINDOW_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'AUTO_CREATED_CONFIG_FLAG' AND (NVL(l_item_rec.AUTO_CREATED_CONFIG_FLAG,'!') <> NVL(m_item_rec.AUTO_CREATED_CONFIG_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'FORECAST_HORIZON' AND (NVL(l_item_rec.FORECAST_HORIZON,-999999) <> NVL(m_item_rec.FORECAST_HORIZON,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DAYS_MAX_INV_SUPPLY' AND (NVL(l_item_rec.DAYS_MAX_INV_SUPPLY,-999999) <> NVL(m_item_rec.DAYS_MAX_INV_SUPPLY,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DIVERGENCE' AND (NVL(l_item_rec.DIVERGENCE,-999999) <> NVL(m_item_rec.DIVERGENCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PARENT_CHILD_GENERATION_FLAG' AND (NVL(l_item_rec.PARENT_CHILD_GENERATION_FLAG,'!') <> NVL(m_item_rec.PARENT_CHILD_GENERATION_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EXPIRATION_ACTION_CODE' AND (NVL(l_item_rec.EXPIRATION_ACTION_CODE,'!') <> NVL(m_item_rec.EXPIRATION_ACTION_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_COSTING_ENABLED_FLAG' AND (NVL(l_item_rec.PROCESS_COSTING_ENABLED_FLAG,'!') <> NVL(m_item_rec.PROCESS_COSTING_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_SUPPLY_SUBINVENTORY' AND (NVL(l_item_rec.PROCESS_SUPPLY_SUBINVENTORY,'!') <> NVL(m_item_rec.PROCESS_SUPPLY_SUBINVENTORY,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EXPENSE_ACCOUNT' AND (NVL(l_item_rec.EXPENSE_ACCOUNT,-999999) <> NVL(m_item_rec.EXPENSE_ACCOUNT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'UN_NUMBER_ID' AND (NVL(l_item_rec.UN_NUMBER_ID,-999999) <> NVL(m_item_rec.UN_NUMBER_ID,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RECEIVE_CLOSE_TOLERANCE' AND (NVL(l_item_rec.RECEIVE_CLOSE_TOLERANCE,-999999) <> NVL(m_item_rec.RECEIVE_CLOSE_TOLERANCE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'AUTO_SERIAL_ALPHA_PREFIX' AND (NVL(l_item_rec.AUTO_SERIAL_ALPHA_PREFIX,'!') <> NVL(m_item_rec.AUTO_SERIAL_ALPHA_PREFIX,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'MTL_TRANSACTIONS_ENABLED_FLAG' AND (NVL(l_item_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!') <> NVL(m_item_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VOLUME_UOM_CODE' AND (NVL(l_item_rec.VOLUME_UOM_CODE,'!') <> NVL(m_item_rec.VOLUME_UOM_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ACCEPTABLE_EARLY_DAYS' AND (NVL(l_item_rec.ACCEPTABLE_EARLY_DAYS,-999999) <> NVL(m_item_rec.ACCEPTABLE_EARLY_DAYS,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ACCEPTABLE_RATE_INCREASE' AND (NVL(l_item_rec.ACCEPTABLE_RATE_INCREASE,-999999) <> NVL(m_item_rec.ACCEPTABLE_RATE_INCREASE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DEMAND_TIME_FENCE_CODE' AND (NVL(l_item_rec.DEMAND_TIME_FENCE_CODE,-999999) <> NVL(m_item_rec.DEMAND_TIME_FENCE_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ATP_COMPONENTS_FLAG' AND (NVL(l_item_rec.ATP_COMPONENTS_FLAG,'!') <> NVL(m_item_rec.ATP_COMPONENTS_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RETURN_INSPECTION_REQUIREMENT' AND (NVL(l_item_rec.RETURN_INSPECTION_REQUIREMENT,-999999) <> NVL(m_item_rec.RETURN_INSPECTION_REQUIREMENT,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RESPONSE_TIME_PERIOD_CODE' AND (NVL(l_item_rec.RESPONSE_TIME_PERIOD_CODE,'!') <> NVL(m_item_rec.RESPONSE_TIME_PERIOD_CODE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'VEHICLE_ITEM_FLAG' AND (NVL(l_item_rec.VEHICLE_ITEM_FLAG,'!') <> NVL(m_item_rec.VEHICLE_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONTAINER_ITEM_FLAG' AND (NVL(l_item_rec.CONTAINER_ITEM_FLAG,'!') <> NVL(m_item_rec.CONTAINER_ITEM_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'RELEASE_TIME_FENCE_CODE' AND (NVL(l_item_rec.RELEASE_TIME_FENCE_CODE,-999999) <> NVL(m_item_rec.RELEASE_TIME_FENCE_CODE,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'INTERNAL_VOLUME' AND (NVL(l_item_rec.INTERNAL_VOLUME,-999999) <> NVL(m_item_rec.INTERNAL_VOLUME,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'EFFECTIVITY_CONTROL' AND (NVL(l_item_rec.EFFECTIVITY_CONTROL,-999999) <> NVL(m_item_rec.EFFECTIVITY_CONTROL,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COUPON_EXEMPT_FLAG' AND (NVL(l_item_rec.COUPON_EXEMPT_FLAG,'!') <> NVL(m_item_rec.COUPON_EXEMPT_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COMMS_NL_TRACKABLE_FLAG' AND (NVL(l_item_rec.COMMS_NL_TRACKABLE_FLAG,'!') <> NVL(m_item_rec.COMMS_NL_TRACKABLE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ORDERABLE_ON_WEB_FLAG' AND (NVL(l_item_rec.ORDERABLE_ON_WEB_FLAG,'!') <> NVL(m_item_rec.ORDERABLE_ON_WEB_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'CONFIG_MODEL_TYPE' AND (NVL(l_item_rec.CONFIG_MODEL_TYPE,'!') <> NVL(m_item_rec.CONFIG_MODEL_TYPE,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'ASN_AUTOEXPIRE_FLAG' AND (NVL(l_item_rec.ASN_AUTOEXPIRE_FLAG,-999999) <> NVL(m_item_rec.ASN_AUTOEXPIRE_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'DRP_PLANNED_FLAG' AND (NVL(l_item_rec.DRP_PLANNED_FLAG,-999999) <> NVL(m_item_rec.DRP_PLANNED_FLAG,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'COPY_LOT_ATTRIBUTE_FLAG' AND (NVL(l_item_rec.COPY_LOT_ATTRIBUTE_FLAG,'!') <> NVL(m_item_rec.COPY_LOT_ATTRIBUTE_FLAG,'!'))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'REPAIR_PROGRAM' AND (NVL(l_item_rec.REPAIR_PROGRAM,-999999) <> NVL(m_item_rec.REPAIR_PROGRAM,-999999))) THEN
            l_create_child := TRUE;
         ELSIF ( g_attribute_code(i) = 'PROCESS_EXECUTION_ENABLED_FLAG' AND (NVL(l_item_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!') <> NVL(m_item_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!'))) THEN
            l_create_child := TRUE;
                 END IF;

            END LOOP;
   END IF;
   -- CLOSE c_master_attributes; -- Bug 10404086

   check_create_child := l_create_child ;

EXCEPTION
   WHEN OTHERS THEN
            -- Bug 10404086 - Commenting below code.
      /*IF (c_master_attributes%ISOPEN) THEN
         CLOSE c_master_attributes;
      END IF;
            */
      check_create_child := TRUE;
      INVPUTLI.info('INVUPD2B.check_create_child_records : Exception ' || SQLERRM );

END Check_create_child_records;

FUNCTION check_child_records
(
        master_row_id   ROWID,
        inv_item_id     NUMBER,
        org_id          NUMBER,
        trans_id        NUMBER,
        prog_appid      NUMBER          := -1,
        prog_id         NUMBER          := -1,
        request_id      NUMBER          := -1,
        user_id         NUMBER          := -1,
        login_id        NUMBER          := -1,
        err_text IN OUT NOCOPY VARCHAR2,
        xset_id  IN     NUMBER          DEFAULT NULL
)
return NUMBER
IS

        CURSOR C_msi_child_records is
        select
        MSI.INVENTORY_ITEM_ID,
        MSI.ORGANIZATION_ID
        from MTL_SYSTEM_ITEMS_B MSI, MTL_PARAMETERS MP
        where MP.master_organization_id = org_id
        and MP.organization_id = MSI.organization_id
        and MSI.inventory_item_id = inv_item_id
        and MSI.organization_id <> MP.master_organization_id;

        CURSOR C_msii_forupdate_records is
        select
        ROWID, ORGANIZATION_ID
        from MTL_SYSTEM_ITEMS_INTERFACE
        where SET_PROCESS_ID = xset_id + 1000000000000
        and PROCESS_FLAG = 4
        and INVENTORY_ITEM_ID = inv_item_id;

        ret_code_create         NUMBER := 0;
        ret_code_update         NUMBER := 0;
        ret_code                NUMBER;
        org_id_temp             NUMBER;

        l_created_child         BOOLEAN := FALSE;

    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
    l_check_create_child    BOOLEAN; --Bug: 5437967

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside check_child_records'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

     -- Bug 10404086 : Start
     Check_create_child_records(mast_rowid         => master_row_id,
                                item_id            => inv_item_id,
                                                            org_id             => org_id,       -- Pass master org id
                                                            check_create_child => l_check_create_child);

     -- Create the child records only if any master controlled attrs for the master are being changed.
     IF l_check_create_child = TRUE THEN -- Bug 10404086

            -- for each record in msi which is a child record of the item
            for crec in C_msi_child_records loop -- {
                --Bug: 5437967 Added call to Check_create_child_records
                -- Bug 10404086 : Moving the below api call out of the loop,
                -- this need to be executed only for master records but not for child records.
                /*
                Check_create_child_records(mast_rowid         => master_row_id,
                                                                    item_id            => crec.inventory_item_id,
                                org_id             => crec.organization_id,
                                check_create_child => l_check_create_child);
                IF l_check_create_child = TRUE THEN
                */ -- Bug 10404086.

                ret_code := INVUPD2B.create_child_update_mast_attr(master_row_id, crec.INVENTORY_ITEM_ID, crec.ORGANIZATION_ID, xset_id);
                l_created_child := TRUE;
                -- END IF;
            end loop; -- }  -- msi_child loop

        END IF; -- Bug 10404086

        --3515652: Should call only when child recods are inserted.
        -- validate the inserted records in msii with SET_PROCESS_ID = xset_id + 1000000000000
        IF l_created_child THEN

           ret_code_create := INVNIRIS.change_policy_check (
                                 org_id     => org_id,
                                 all_org    => 1,
                                 prog_appid => prog_appid,
                                 prog_id    => prog_id,
                                 request_id => request_id,
                                 user_id    => user_id,
                                 login_id   => login_id,
                                 err_text   => err_text,
                                 xset_id    => xset_id + 1000000000000);

           ret_code_create := INVPVALI.mtl_pr_validate_item(
                                org_id,
                                1,
                                prog_appid,
                                prog_id,
                                request_id,
                                user_id,
                                login_id,
                                err_text,
                                xset_id + 1000000000000);

           for rec in C_msii_forupdate_records loop
              ret_code_update :=  INVUPD2B.update_validations(
                                                rec.ROWID,
                                                rec.ORGANIZATION_ID,
                                                trans_id,
                                                user_id,
                                                login_id,
                                                prog_appid,
                                                prog_id,
                                                request_id);
              exit when ret_code_update = 1;
           end loop;
        END IF;

        if (ret_code_create = 1 OR ret_code_update = 1) then
           return (1);
        else
           return (0);
        end if;

EXCEPTION

   when NO_DATA_FOUND then
      -- there are no child records in msi
      return (0);

   when OTHERS then
      --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
             Substr('When OTHERS exception raised in check_child_records '||
                 SQLCODE ||
             ' - '   ||
             SQLERRM,1,240));
      END IF;
      return (1);

END check_child_records;

-------------------------------------------------------------

FUNCTION create_child_update_mast_attr
(
        master_row_id   ROWID,
        inv_item_id     NUMBER,
        org_id          NUMBER,
        xset_id IN      NUMBER
)
return INTEGER
IS
   ret_code    NUMBER;

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside create_child_update_mast_attr'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;
   -- Insert msi data onto MSII for child record.
   -- Need to verify these attributes.
   --
   INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
   (
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      SET_PROCESS_ID,
      TRANSACTION_TYPE,
                SUMMARY_FLAG,
                ENABLED_FLAG,
                START_DATE_ACTIVE,
                END_DATE_ACTIVE,
                DESCRIPTION,
                LONG_DESCRIPTION,
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
        ATTRIBUTE16 ,
        ATTRIBUTE17 ,
        ATTRIBUTE18 ,
        ATTRIBUTE19 ,
        ATTRIBUTE20 ,
        ATTRIBUTE21 ,
        ATTRIBUTE22 ,
        ATTRIBUTE23 ,
        ATTRIBUTE24 ,
        ATTRIBUTE25 ,
        ATTRIBUTE26 ,
        ATTRIBUTE27 ,
        ATTRIBUTE28 ,
        ATTRIBUTE29 ,
        ATTRIBUTE30 ,
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
                QTY_RCV_EXCEPTION_CODE,
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
                RELEASE_TIME_FENCE_CODE,
                LEAD_TIME_LOT_SIZE,
                STD_LOT_SIZE,
                CUM_MANUFACTURING_LEAD_TIME,
                OVERRUN_PERCENTAGE,
                MRP_CALCULATE_ATP_FLAG,
                ACCEPTABLE_RATE_INCREASE,
                ACCEPTABLE_RATE_DECREASE,
                CUMULATIVE_TOTAL_LEAD_TIME,
                PLANNING_TIME_FENCE_DAYS,
                DEMAND_TIME_FENCE_DAYS,
                RELEASE_TIME_FENCE_DAYS,
                END_ASSEMBLY_PEGGING_FLAG,
                REPETITIVE_PLANNING_FLAG,
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
                WARRANTY_VENDOR_ID,
                MAX_WARRANTY_AMOUNT,
                RESPONSE_TIME_PERIOD_CODE,
                RESPONSE_TIME_VALUE,
                NEW_REVISION_CODE,
                INVOICEABLE_ITEM_FLAG,
                TAX_CODE,
                INVOICE_ENABLED_FLAG,
                MUST_USE_APPROVED_VENDOR_FLAG,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                OUTSIDE_OPERATION_FLAG,
                OUTSIDE_OPERATION_UOM_TYPE,
                SAFETY_STOCK_BUCKET_DAYS,
                AUTO_REDUCE_MPS,
                COSTING_ENABLED_FLAG,
                AUTO_CREATED_CONFIG_FLAG,
                CYCLE_COUNT_ENABLED_FLAG,
                ITEM_TYPE,
                MODEL_CONFIG_CLAUSE_NAME,
                SHIP_MODEL_COMPLETE_FLAG,
                MRP_PLANNING_CODE,
                RETURN_INSPECTION_REQUIREMENT,
                ATO_FORECAST_CONTROL,
                CONTAINER_ITEM_FLAG,
                VEHICLE_ITEM_FLAG,
                MAXIMUM_LOAD_WEIGHT,
                MINIMUM_FILL_PERCENT,
                CONTAINER_TYPE_CODE,
                INTERNAL_VOLUME,
      CHECK_SHORTAGES_FLAG
   ,  EFFECTIVITY_CONTROL
   ,   OVERCOMPLETION_TOLERANCE_TYPE
   ,   OVERCOMPLETION_TOLERANCE_VALUE
   ,   OVER_SHIPMENT_TOLERANCE
   ,   UNDER_SHIPMENT_TOLERANCE
   ,   OVER_RETURN_TOLERANCE
   ,   UNDER_RETURN_TOLERANCE
   ,   EQUIPMENT_TYPE
   ,   RECOVERED_PART_DISP_CODE
   ,   DEFECT_TRACKING_ON_FLAG
   ,   EVENT_FLAG
   ,   ELECTRONIC_FLAG
   ,   DOWNLOADABLE_FLAG
   ,   VOL_DISCOUNT_EXEMPT_FLAG
   ,   COUPON_EXEMPT_FLAG
   ,   COMMS_NL_TRACKABLE_FLAG
   ,   ASSET_CREATION_CODE
   ,   COMMS_ACTIVATION_REQD_FLAG
   ,   ORDERABLE_ON_WEB_FLAG
   ,   BACK_ORDERABLE_FLAG
   ,  WEB_STATUS
   ,  INDIVISIBLE_FLAG
   ,   DIMENSION_UOM_CODE
   ,   UNIT_LENGTH
   ,   UNIT_WIDTH
   ,   UNIT_HEIGHT
   ,   BULK_PICKED_FLAG
   ,   LOT_STATUS_ENABLED
   ,   DEFAULT_LOT_STATUS_ID
   ,   SERIAL_STATUS_ENABLED
   ,   DEFAULT_SERIAL_STATUS_ID
   ,   LOT_SPLIT_ENABLED
   ,   LOT_MERGE_ENABLED
   ,   INVENTORY_CARRY_PENALTY
   ,   OPERATION_SLACK_PENALTY
   ,   FINANCING_ALLOWED_FLAG
   ,  EAM_ITEM_TYPE
   ,  EAM_ACTIVITY_TYPE_CODE
   ,  EAM_ACTIVITY_CAUSE_CODE
   ,  EAM_ACT_NOTIFICATION_FLAG
   ,  EAM_ACT_SHUTDOWN_STATUS
   ,  DUAL_UOM_CONTROL
   ,  SECONDARY_UOM_CODE
   ,  DUAL_UOM_DEVIATION_HIGH
   ,  DUAL_UOM_DEVIATION_LOW
   --,  SERVICE_ITEM_FLAG
   --,  VENDOR_WARRANTY_FLAG
   --,  USAGE_ITEM_FLAG
   ,  CONTRACT_ITEM_TYPE_CODE
--   ,  SUBSCRIPTION_DEPEND_FLAG
   --
   ,  SERV_REQ_ENABLED_CODE
   ,  SERV_BILLING_ENABLED_FLAG
--   ,  SERV_IMPORTANCE_LEVEL
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
        ,DIVERGENCE ,
        /* Start Bug 3713912 */
        LOT_DIVISIBLE_FLAG                   ,
        GRADE_CONTROL_FLAG                   ,
        DEFAULT_GRADE                ,
        CHILD_LOT_FLAG               ,
        PARENT_CHILD_GENERATION_FLAG    ,
        CHILD_LOT_PREFIX                     ,
        CHILD_LOT_STARTING_NUMBER            ,
        CHILD_LOT_VALIDATION_FLAG            ,
        COPY_LOT_ATTRIBUTE_FLAG      ,
        RECIPE_ENABLED_FLAG          ,
        PROCESS_QUALITY_ENABLED_FLAG    ,
        PROCESS_EXECUTION_ENABLED_FLAG  ,
        PROCESS_COSTING_ENABLED_FLAG    ,
        PROCESS_SUPPLY_SUBINVENTORY     ,
        PROCESS_SUPPLY_LOCATOR_ID            ,
        PROCESS_YIELD_SUBINVENTORY           ,
        PROCESS_YIELD_LOCATOR_ID             ,
        HAZARDOUS_MATERIAL_FLAG      ,
        CAS_NUMBER                           ,
        RETEST_INTERVAL              ,
        EXPIRATION_ACTION_INTERVAL           ,
        EXPIRATION_ACTION_CODE       ,
        MATURITY_DAYS                ,
        HOLD_DAYS,
        /* End Bug 3713912 */
    --R12 Enhancement
    CHARGE_PERIODICITY_CODE,
        REPAIR_LEADTIME,
        REPAIR_YIELD,
        PREPOSITION_POINT,
        REPAIR_PROGRAM,
        SUBCONTRACTING_COMPONENT,
        OUTSOURCED_ASSEMBLY,
        CURRENT_PHASE_ID, -- added for bug 7589826 based on 7587702
    /* Bug 6397416*/
        GDSN_OUTBOUND_ENABLED_FLAG,
        TRADE_ITEM_DESCRIPTOR,
        STYLE_ITEM_FLAG,
        STYLE_ITEM_ID)
   SELECT
      MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL,
      inv_item_id,
      org_id,
      xset_id + 1000000000000,
      'AUTO_CHILD',
                MSI.SUMMARY_FLAG,
                MSI.ENABLED_FLAG,
                MSI.START_DATE_ACTIVE,
                MSI.END_DATE_ACTIVE,
                MSI.DESCRIPTION,
                MSI.LONG_DESCRIPTION,
                MSI.BUYER_ID,
                MSI.ACCOUNTING_RULE_ID,
                MSI.INVOICING_RULE_ID,
                MSI.SEGMENT1,
                MSI.SEGMENT2,
                MSI.SEGMENT3,
                MSI.SEGMENT4,
                MSI.SEGMENT5,
                MSI.SEGMENT6,
                MSI.SEGMENT7,
                MSI.SEGMENT8,
                MSI.SEGMENT9,
                MSI.SEGMENT10,
                MSI.SEGMENT11,
                MSI.SEGMENT12,
                MSI.SEGMENT13,
                MSI.SEGMENT14,
                MSI.SEGMENT15,
                MSI.SEGMENT16,
                MSI.SEGMENT17,
                MSI.SEGMENT18,
                MSI.SEGMENT19,
                MSI.SEGMENT20,
        MSI.ATTRIBUTE_CATEGORY,
        MSI.ATTRIBUTE1,
        MSI.ATTRIBUTE2,
        MSI.ATTRIBUTE3,
        MSI.ATTRIBUTE4,
        MSI.ATTRIBUTE5,
        MSI.ATTRIBUTE6,
        MSI.ATTRIBUTE7,
        MSI.ATTRIBUTE8,
        MSI.ATTRIBUTE9,
        MSI.ATTRIBUTE10,
        MSI.ATTRIBUTE11,
        MSI.ATTRIBUTE12,
        MSI.ATTRIBUTE13,
        MSI.ATTRIBUTE14,
        MSI.ATTRIBUTE15,
        /* Start Bug 3713912 */
        MSI.ATTRIBUTE16 ,
        MSI.ATTRIBUTE17 ,
        MSI.ATTRIBUTE18 ,
        MSI.ATTRIBUTE19 ,
        MSI.ATTRIBUTE20 ,
        MSI.ATTRIBUTE21 ,
        MSI.ATTRIBUTE22 ,
        MSI.ATTRIBUTE23 ,
        MSI.ATTRIBUTE24 ,
        MSI.ATTRIBUTE25 ,
        MSI.ATTRIBUTE26 ,
        MSI.ATTRIBUTE27 ,
        MSI.ATTRIBUTE28 ,
        MSI.ATTRIBUTE29 ,
        MSI.ATTRIBUTE30 ,
        /* End Bug 3713912 */
                MSI.GLOBAL_ATTRIBUTE_CATEGORY,
                MSI.GLOBAL_ATTRIBUTE1,
                MSI.GLOBAL_ATTRIBUTE2,
                MSI.GLOBAL_ATTRIBUTE3,
                MSI.GLOBAL_ATTRIBUTE4,
                MSI.GLOBAL_ATTRIBUTE5,
                MSI.GLOBAL_ATTRIBUTE6,
                MSI.GLOBAL_ATTRIBUTE7,
                MSI.GLOBAL_ATTRIBUTE8,
                MSI.GLOBAL_ATTRIBUTE9,
                MSI.GLOBAL_ATTRIBUTE10,
                MSI.GLOBAL_ATTRIBUTE11,
                MSI.GLOBAL_ATTRIBUTE12,
                MSI.GLOBAL_ATTRIBUTE13,
                MSI.GLOBAL_ATTRIBUTE14,
                MSI.GLOBAL_ATTRIBUTE15,
                MSI.GLOBAL_ATTRIBUTE16,
                MSI.GLOBAL_ATTRIBUTE17,
                MSI.GLOBAL_ATTRIBUTE18,
                MSI.GLOBAL_ATTRIBUTE19,
                MSI.GLOBAL_ATTRIBUTE20,
                MSI.PURCHASING_ITEM_FLAG,
                MSI.SHIPPABLE_ITEM_FLAG,
                MSI.CUSTOMER_ORDER_FLAG,
                MSI.INTERNAL_ORDER_FLAG,
                MSI.INVENTORY_ITEM_FLAG,
                MSI.ENG_ITEM_FLAG,
                MSI.INVENTORY_ASSET_FLAG,
                MSI.PURCHASING_ENABLED_FLAG,
                MSI.CUSTOMER_ORDER_ENABLED_FLAG,
                MSI.INTERNAL_ORDER_ENABLED_FLAG,
                MSI.SO_TRANSACTIONS_FLAG,
                MSI.MTL_TRANSACTIONS_ENABLED_FLAG,
                MSI.STOCK_ENABLED_FLAG,
                MSI.BOM_ENABLED_FLAG,
                MSI.BUILD_IN_WIP_FLAG,
                MSI.REVISION_QTY_CONTROL_CODE,
                MSI.ITEM_CATALOG_GROUP_ID,
                MSI.CATALOG_STATUS_FLAG,
                MSI.RETURNABLE_FLAG,
                MSI.DEFAULT_SHIPPING_ORG,
                MSI.COLLATERAL_FLAG,
                MSI.TAXABLE_FLAG,
                MSI.PURCHASING_TAX_CODE,
                MSI.QTY_RCV_EXCEPTION_CODE,
                MSI.ALLOW_ITEM_DESC_UPDATE_FLAG,
                MSI.INSPECTION_REQUIRED_FLAG,
                MSI.RECEIPT_REQUIRED_FLAG,
                MSI.MARKET_PRICE,
                MSI.HAZARD_CLASS_ID,
                MSI.RFQ_REQUIRED_FLAG,
                MSI.QTY_RCV_TOLERANCE,
                MSI.LIST_PRICE_PER_UNIT,
                MSI.UN_NUMBER_ID,
                MSI.PRICE_TOLERANCE_PERCENT,
                MSI.ASSET_CATEGORY_ID,
                MSI.ROUNDING_FACTOR,
                MSI.UNIT_OF_ISSUE,
                MSI.ENFORCE_SHIP_TO_LOCATION_CODE,
                MSI.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
                MSI.ALLOW_UNORDERED_RECEIPTS_FLAG,
                MSI.ALLOW_EXPRESS_DELIVERY_FLAG,
                MSI.DAYS_EARLY_RECEIPT_ALLOWED,
                MSI.DAYS_LATE_RECEIPT_ALLOWED,
                MSI.RECEIPT_DAYS_EXCEPTION_CODE,
                MSI.RECEIVING_ROUTING_ID,
                MSI.INVOICE_CLOSE_TOLERANCE,
                MSI.RECEIVE_CLOSE_TOLERANCE,
                MSI.AUTO_LOT_ALPHA_PREFIX,
                MSI.START_AUTO_LOT_NUMBER,
                MSI.LOT_CONTROL_CODE,
                MSI.SHELF_LIFE_CODE,
                MSI.SHELF_LIFE_DAYS,
                MSI.SERIAL_NUMBER_CONTROL_CODE,
                MSI.START_AUTO_SERIAL_NUMBER,
                MSI.AUTO_SERIAL_ALPHA_PREFIX,
                MSI.SOURCE_TYPE,
                MSI.SOURCE_ORGANIZATION_ID,
                MSI.SOURCE_SUBINVENTORY,
                MSI.EXPENSE_ACCOUNT,
                MSI.ENCUMBRANCE_ACCOUNT,
                MSI.RESTRICT_SUBINVENTORIES_CODE,
                MSI.UNIT_WEIGHT,
                MSI.WEIGHT_UOM_CODE,
                MSI.VOLUME_UOM_CODE,
                MSI.UNIT_VOLUME,
                MSI.RESTRICT_LOCATORS_CODE,
                MSI.LOCATION_CONTROL_CODE,
                MSI.SHRINKAGE_RATE,
                MSI.ACCEPTABLE_EARLY_DAYS,
                MSI.PLANNING_TIME_FENCE_CODE,
                MSI.DEMAND_TIME_FENCE_CODE,
                MSI.RELEASE_TIME_FENCE_CODE,
                MSI.LEAD_TIME_LOT_SIZE,
                MSI.STD_LOT_SIZE,
                MSI.CUM_MANUFACTURING_LEAD_TIME,
                MSI.OVERRUN_PERCENTAGE,
                MSI.MRP_CALCULATE_ATP_FLAG,
                MSI.ACCEPTABLE_RATE_INCREASE,
                MSI.ACCEPTABLE_RATE_DECREASE,
                MSI.CUMULATIVE_TOTAL_LEAD_TIME,
                MSI.PLANNING_TIME_FENCE_DAYS,
                MSI.DEMAND_TIME_FENCE_DAYS,
                MSI.RELEASE_TIME_FENCE_DAYS,
                MSI.END_ASSEMBLY_PEGGING_FLAG,
                MSI.REPETITIVE_PLANNING_FLAG,
                MSI.PLANNING_EXCEPTION_SET,
                MSI.BOM_ITEM_TYPE,
                MSI.PICK_COMPONENTS_FLAG,
                MSI.REPLENISH_TO_ORDER_FLAG,
                MSI.BASE_ITEM_ID,
                MSI.ATP_COMPONENTS_FLAG,
                MSI.ATP_FLAG,
                MSI.FIXED_LEAD_TIME,
                MSI.VARIABLE_LEAD_TIME,
                MSI.WIP_SUPPLY_LOCATOR_ID,
                MSI.WIP_SUPPLY_TYPE,
                MSI.WIP_SUPPLY_SUBINVENTORY,
                MSI.PRIMARY_UOM_CODE,
                MSI.PRIMARY_UNIT_OF_MEASURE,
                MSI.ALLOWED_UNITS_LOOKUP_CODE,
                MSI.COST_OF_SALES_ACCOUNT,
                MSI.SALES_ACCOUNT,
                MSI.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
                MSI.INVENTORY_ITEM_STATUS_CODE,
                MSI.INVENTORY_PLANNING_CODE,
                MSI.PLANNER_CODE,
                MSI.PLANNING_MAKE_BUY_CODE,
                MSI.FIXED_LOT_MULTIPLIER,
                MSI.ROUNDING_CONTROL_TYPE,
                MSI.CARRYING_COST,
                MSI.POSTPROCESSING_LEAD_TIME,
                MSI.PREPROCESSING_LEAD_TIME,
                MSI.FULL_LEAD_TIME,
                MSI.ORDER_COST,
                MSI.MRP_SAFETY_STOCK_PERCENT,
                MSI.MRP_SAFETY_STOCK_CODE,
                MSI.MIN_MINMAX_QUANTITY,
                MSI.MAX_MINMAX_QUANTITY,
                MSI.MINIMUM_ORDER_QUANTITY,
                MSI.FIXED_ORDER_QUANTITY,
                MSI.FIXED_DAYS_SUPPLY,
                MSI.MAXIMUM_ORDER_QUANTITY,
                MSI.ATP_RULE_ID,
                MSI.PICKING_RULE_ID,
                MSI.RESERVABLE_TYPE,
                MSI.POSITIVE_MEASUREMENT_ERROR,
                MSI.NEGATIVE_MEASUREMENT_ERROR,
                MSI.ENGINEERING_ECN_CODE,
                MSI.ENGINEERING_ITEM_ID,
                MSI.ENGINEERING_DATE,
                MSI.SERVICE_STARTING_DELAY,
                MSI.SERVICEABLE_COMPONENT_FLAG,
                MSI.SERVICEABLE_PRODUCT_FLAG,
                MSI.BASE_WARRANTY_SERVICE_ID,
                MSI.PAYMENT_TERMS_ID,
                MSI.PREVENTIVE_MAINTENANCE_FLAG,
                MSI.PRIMARY_SPECIALIST_ID,
                MSI.SECONDARY_SPECIALIST_ID,
                MSI.SERVICEABLE_ITEM_CLASS_ID,
                MSI.TIME_BILLABLE_FLAG,
                MSI.MATERIAL_BILLABLE_FLAG,
                MSI.EXPENSE_BILLABLE_FLAG,
                MSI.PRORATE_SERVICE_FLAG,
                MSI.COVERAGE_SCHEDULE_ID,
                MSI.SERVICE_DURATION_PERIOD_CODE,
                MSI.SERVICE_DURATION,
                MSI.WARRANTY_VENDOR_ID,
                MSI.MAX_WARRANTY_AMOUNT,
                MSI.RESPONSE_TIME_PERIOD_CODE,
                MSI.RESPONSE_TIME_VALUE,
                MSI.NEW_REVISION_CODE,
                MSI.INVOICEABLE_ITEM_FLAG,
                MSI.TAX_CODE,
                MSI.INVOICE_ENABLED_FLAG,
                MSI.MUST_USE_APPROVED_VENDOR_FLAG,
                MSI.REQUEST_ID,
                MSI.PROGRAM_APPLICATION_ID,
                MSI.PROGRAM_ID,
                MSI.PROGRAM_UPDATE_DATE,
                MSI.OUTSIDE_OPERATION_FLAG,
                MSI.OUTSIDE_OPERATION_UOM_TYPE,
                MSI.SAFETY_STOCK_BUCKET_DAYS,
                MSI.AUTO_REDUCE_MPS,
                MSI.COSTING_ENABLED_FLAG,
                MSI.AUTO_CREATED_CONFIG_FLAG,
                MSI.CYCLE_COUNT_ENABLED_FLAG,
                MSI.ITEM_TYPE,
                MSI.MODEL_CONFIG_CLAUSE_NAME,
                MSI.SHIP_MODEL_COMPLETE_FLAG,
                MSI.MRP_PLANNING_CODE,
                MSI.RETURN_INSPECTION_REQUIREMENT,
                MSI.ATO_FORECAST_CONTROL,
                MSI.CONTAINER_ITEM_FLAG,
                MSI.VEHICLE_ITEM_FLAG,
                MSI.MAXIMUM_LOAD_WEIGHT,
                MSI.MINIMUM_FILL_PERCENT,
                MSI.CONTAINER_TYPE_CODE,
                MSI.INTERNAL_VOLUME,
      MSI.CHECK_SHORTAGES_FLAG
   ,  MSI.EFFECTIVITY_CONTROL
   ,   MSI.OVERCOMPLETION_TOLERANCE_TYPE
   ,   MSI.OVERCOMPLETION_TOLERANCE_VALUE
   ,   MSI.OVER_SHIPMENT_TOLERANCE
   ,   MSI.UNDER_SHIPMENT_TOLERANCE
   ,   MSI.OVER_RETURN_TOLERANCE
   ,   MSI.UNDER_RETURN_TOLERANCE
   ,   MSI.EQUIPMENT_TYPE
   ,   MSI.RECOVERED_PART_DISP_CODE
   ,   MSI.DEFECT_TRACKING_ON_FLAG
   ,   MSI.EVENT_FLAG
   ,   MSI.ELECTRONIC_FLAG
   ,   MSI.DOWNLOADABLE_FLAG
   ,   MSI.VOL_DISCOUNT_EXEMPT_FLAG
   ,   MSI.COUPON_EXEMPT_FLAG
   ,   MSI.COMMS_NL_TRACKABLE_FLAG
   ,   MSI.ASSET_CREATION_CODE
   ,   MSI.COMMS_ACTIVATION_REQD_FLAG
   ,   MSI.ORDERABLE_ON_WEB_FLAG
   ,   MSI.BACK_ORDERABLE_FLAG
   ,  MSI.WEB_STATUS
   ,  MSI.INDIVISIBLE_FLAG
   ,   MSI.DIMENSION_UOM_CODE
   ,   MSI.UNIT_LENGTH
   ,   MSI.UNIT_WIDTH
   ,   MSI.UNIT_HEIGHT
   ,   MSI.BULK_PICKED_FLAG
   ,   MSI.LOT_STATUS_ENABLED
   ,   MSI.DEFAULT_LOT_STATUS_ID
   ,   MSI.SERIAL_STATUS_ENABLED
   ,   MSI.DEFAULT_SERIAL_STATUS_ID
   ,   MSI.LOT_SPLIT_ENABLED
   ,   MSI.LOT_MERGE_ENABLED
   ,   MSI.INVENTORY_CARRY_PENALTY
   ,   MSI.OPERATION_SLACK_PENALTY
   ,   MSI.FINANCING_ALLOWED_FLAG
   ,  MSI.EAM_ITEM_TYPE
   ,  MSI.EAM_ACTIVITY_TYPE_CODE
   ,  MSI.EAM_ACTIVITY_CAUSE_CODE
   ,  MSI.EAM_ACT_NOTIFICATION_FLAG
   ,  MSI.EAM_ACT_SHUTDOWN_STATUS
   ,  MSI.DUAL_UOM_CONTROL
   ,  MSI.SECONDARY_UOM_CODE
   ,  MSI.DUAL_UOM_DEVIATION_HIGH
   ,  MSI.DUAL_UOM_DEVIATION_LOW
   --,  MSI.SERVICE_ITEM_FLAG
   --,  MSI.VENDOR_WARRANTY_FLAG
   --,  MSI.USAGE_ITEM_FLAG
   ,  MSI.CONTRACT_ITEM_TYPE_CODE
--   ,  MSI.SUBSCRIPTION_DEPEND_FLAG
   --
   ,  MSI.SERV_REQ_ENABLED_CODE
   ,  MSI.SERV_BILLING_ENABLED_FLAG
--   ,  MSI.SERV_IMPORTANCE_LEVEL
   ,  MSI.PLANNED_INV_POINT_FLAG
   ,  MSI.LOT_TRANSLATE_ENABLED
   ,  MSI.DEFAULT_SO_SOURCE_TYPE
   ,  MSI.CREATE_SUPPLY_FLAG
   ,  MSI.SUBSTITUTION_WINDOW_CODE
   ,  MSI.SUBSTITUTION_WINDOW_DAYS
--Added as part of 11.5.9
   ,  MSI.LOT_SUBSTITUTION_ENABLED
   ,  MSI.MINIMUM_LICENSE_QUANTITY
   ,  MSI.EAM_ACTIVITY_SOURCE_CODE
   ,  MSI.IB_ITEM_INSTANCE_CLASS
   ,  MSI.CONFIG_MODEL_TYPE
--Added as part of 11.5.10
   ,  MSI.TRACKING_QUANTITY_IND
   ,  MSI.ONT_PRICING_QTY_SOURCE
   ,  MSI.SECONDARY_DEFAULT_IND
   ,  MSI.CONFIG_ORGS
   ,  MSI.CONFIG_MATCH
        ,MSI.VMI_MINIMUM_UNITS
        ,MSI.VMI_MINIMUM_DAYS
        ,MSI.VMI_MAXIMUM_UNITS
        ,MSI.VMI_MAXIMUM_DAYS
        ,MSI.VMI_FIXED_ORDER_QUANTITY
        ,MSI.SO_AUTHORIZATION_FLAG
        ,MSI.CONSIGNED_FLAG
        ,MSI.ASN_AUTOEXPIRE_FLAG
        ,MSI.VMI_FORECAST_TYPE
        ,MSI.FORECAST_HORIZON
        ,MSI.EXCLUDE_FROM_BUDGET_FLAG
        ,MSI.DAYS_TGT_INV_SUPPLY
        ,MSI.DAYS_TGT_INV_WINDOW
        ,MSI.DAYS_MAX_INV_SUPPLY
        ,MSI.DAYS_MAX_INV_WINDOW
        ,MSI.DRP_PLANNED_FLAG
        ,MSI.CRITICAL_COMPONENT_FLAG
        ,MSI.CONTINOUS_TRANSFER
        ,MSI.CONVERGENCE
        ,MSI.DIVERGENCE   ,
        /* Start Bug 3713912 */
        MSI.LOT_DIVISIBLE_FLAG               ,
        MSI.GRADE_CONTROL_FLAG               ,
        MSI.DEFAULT_GRADE                    ,
        MSI.CHILD_LOT_FLAG                   ,
        MSI.PARENT_CHILD_GENERATION_FLAG    ,
        MSI.CHILD_LOT_PREFIX                 ,
        MSI.CHILD_LOT_STARTING_NUMBER        ,
        MSI.CHILD_LOT_VALIDATION_FLAG        ,
        MSI.COPY_LOT_ATTRIBUTE_FLAG          ,
        MSI.RECIPE_ENABLED_FLAG      ,
        MSI.PROCESS_QUALITY_ENABLED_FLAG    ,
        MSI.PROCESS_EXECUTION_ENABLED_FLAG  ,
        MSI.PROCESS_COSTING_ENABLED_FLAG    ,
        MSI.PROCESS_SUPPLY_SUBINVENTORY     ,
        MSI.PROCESS_SUPPLY_LOCATOR_ID        ,
        MSI.PROCESS_YIELD_SUBINVENTORY       ,
        MSI.PROCESS_YIELD_LOCATOR_ID         ,
        MSI.HAZARDOUS_MATERIAL_FLAG          ,
        MSI.CAS_NUMBER                       ,
        MSI.RETEST_INTERVAL                  ,
        MSI.EXPIRATION_ACTION_INTERVAL       ,
        MSI.EXPIRATION_ACTION_CODE           ,
        MSI.MATURITY_DAYS                    ,
        MSI.HOLD_DAYS                        ,
        /* End Bug 3713912 */
    --R12 Enhancement
    MSI.CHARGE_PERIODICITY_CODE,
    MSI.REPAIR_LEADTIME,
    MSI.REPAIR_YIELD,
    MSI.PREPOSITION_POINT,
    MSI.REPAIR_PROGRAM,
    MSI.SUBCONTRACTING_COMPONENT,
    MSI.OUTSOURCED_ASSEMBLY,
    MSI.CURRENT_PHASE_ID, -- Added for bug 7589826, FP of 7587702
        MSI.GDSN_OUTBOUND_ENABLED_FLAG,
        MSI.TRADE_ITEM_DESCRIPTOR,
        MSI.STYLE_ITEM_FLAG,
        MSI.STYLE_ITEM_ID
   FROM
      MTL_SYSTEM_ITEMS_VL  MSI
   WHERE
          MSI.inventory_item_id = inv_item_id
      AND MSI.organization_id   = org_id;

        --commit;

        -- copy master item data to child record created in msii
        ret_code := INVUPD2B.copy_master_to_child(master_row_id, inv_item_id, org_id, xset_id);

        --commit;

   RETURN (ret_code);

EXCEPTION

   when OTHERS then
   --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info(
           Substr(
             'when OTHERS exception raised in create_child_update_mast_attr ' ||
              SQLCODE ||
              ' - '   ||
              SQLERRM, 1, 240));
   END IF;
   return (1);

END create_child_update_mast_attr; -- }


FUNCTION copy_master_to_child
(
   master_row_id       ROWID
,  inv_item_id         NUMBER
,  org_id              NUMBER
,  xset_id        IN   NUMBER
)
RETURN INTEGER
IS

   -- temprec to hold master record data from msii
   --
   msii_master_temp     mtl_system_items_interface%ROWTYPE;

   l_process_flag_2     NUMBER  :=  2;

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside copy_master_to_child'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

   -- Get master record info into msii_master_temp
   --
   select *
     into msii_master_temp
   from
      MTL_SYSTEM_ITEMS_INTERFACE MSII
   where
      MSII.ROWID = master_row_id;

   -- Update child record with master record data for attributes
   -- under master control.
   --
   UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
   SET    MSII.ALLOWED_UNITS_LOOKUP_CODE     =  decode( A_ALLOWED_UNITS_LOOKUP_CODE,1,msii_master_temp.ALLOWED_UNITS_LOOKUP_CODE,MSII.ALLOWED_UNITS_LOOKUP_CODE ),
          MSII.INVENTORY_ITEM_STATUS_CODE    =  decode( A_INVENTORY_ITEM_STATUS_CODE,1, msii_master_temp.INVENTORY_ITEM_STATUS_CODE,MSII.INVENTORY_ITEM_STATUS_CODE ),
          MSII.ITEM_TYPE                     =  decode( A_ITEM_TYPE,1,msii_master_temp.ITEM_TYPE,MSII.ITEM_TYPE ),
      MSII.PRIMARY_UNIT_OF_MEASURE       =  decode( A_PRIMARY_UNIT_OF_MEASURE,1,msii_master_temp.PRIMARY_UNIT_OF_MEASURE,MSII.PRIMARY_UNIT_OF_MEASURE ),
          MSII.BASE_ITEM_ID                  =  decode( A_BASE_ITEM_ID,1,msii_master_temp.BASE_ITEM_ID,MSII.BASE_ITEM_ID ),
          MSII.BOM_ENABLED_FLAG              =  decode( A_BOM_ENABLED_FLAG,1,msii_master_temp.BOM_ENABLED_FLAG,MSII.BOM_ENABLED_FLAG ),
          MSII.BOM_ITEM_TYPE                 =  decode( A_BOM_ITEM_TYPE,1,msii_master_temp.BOM_ITEM_TYPE,MSII.BOM_ITEM_TYPE ),
          MSII.ENGINEERING_ECN_CODE          =  decode( A_ENGINEERING_ECN_CODE,1,msii_master_temp.ENGINEERING_ECN_CODE,MSII.ENGINEERING_ECN_CODE ),
          MSII.ENGINEERING_ITEM_ID           =  decode( A_ENGINEERING_ITEM_ID,1,msii_master_temp.ENGINEERING_ITEM_ID,MSII.ENGINEERING_ITEM_ID ),
          MSII.ENG_ITEM_FLAG                 =  decode( A_ENG_ITEM_FLAG,1,msii_master_temp.ENG_ITEM_FLAG,MSII.ENG_ITEM_FLAG ),
          MSII.COSTING_ENABLED_FLAG          =  decode( A_COSTING_ENABLED_FLAG,1,msii_master_temp.COSTING_ENABLED_FLAG,MSII.COSTING_ENABLED_FLAG ),
          MSII.COST_OF_SALES_ACCOUNT         =  decode( A_COST_OF_SALES_ACCOUNT,1,msii_master_temp.COST_OF_SALES_ACCOUNT,MSII.COST_OF_SALES_ACCOUNT ),
          MSII.DEFAULT_INCLUDE_IN_ROLLUP_FLAG=  decode( A_DEF_INCL_IN_ROLLUP_FLAG,1,msii_master_temp.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,MSII.DEFAULT_INCLUDE_IN_ROLLUP_FLAG ),
          MSII.INVENTORY_ASSET_FLAG          =  decode( A_INVENTORY_ASSET_FLAG,1,msii_master_temp.INVENTORY_ASSET_FLAG,MSII.INVENTORY_ASSET_FLAG ),
          MSII.STD_LOT_SIZE                  =  decode( A_STD_LOT_SIZE,1,msii_master_temp.STD_LOT_SIZE,MSII.STD_LOT_SIZE ),
          MSII.ALLOW_ITEM_DESC_UPDATE_FLAG   =  decode( A_ALLOW_ITEM_DESC_UPDATE_FLAG,1,msii_master_temp.ALLOW_ITEM_DESC_UPDATE_FLAG,MSII.ALLOW_ITEM_DESC_UPDATE_FLAG ),
          MSII.ASSET_CATEGORY_ID             =  decode( A_ASSET_CATEGORY_ID,1, msii_master_temp.ASSET_CATEGORY_ID,MSII.ASSET_CATEGORY_ID ),
          MSII.BUYER_ID                      =  decode( A_BUYER_ID,1,msii_master_temp.BUYER_ID,MSII.BUYER_ID ),
          MSII.ENCUMBRANCE_ACCOUNT           =  decode( A_ENCUMBRANCE_ACCOUNT,1,msii_master_temp.ENCUMBRANCE_ACCOUNT,MSII.ENCUMBRANCE_ACCOUNT ),
          MSII.EXPENSE_ACCOUNT               =  decode( A_EXPENSE_ACCOUNT,1,msii_master_temp.EXPENSE_ACCOUNT,MSII.EXPENSE_ACCOUNT ),
          MSII.HAZARD_CLASS_ID               =  decode( A_HAZARD_CLASS_ID,1,msii_master_temp.HAZARD_CLASS_ID,MSII.HAZARD_CLASS_ID ),
          MSII.LIST_PRICE_PER_UNIT           =  decode( A_LIST_PRICE_PER_UNIT,1,msii_master_temp.LIST_PRICE_PER_UNIT,MSII.LIST_PRICE_PER_UNIT ),
          MSII.MARKET_PRICE                  =  decode( A_MARKET_PRICE,1,msii_master_temp.MARKET_PRICE,MSII.MARKET_PRICE ),
          MSII.MUST_USE_APPROVED_VENDOR_FLAG =  decode( A_MU_APPRVD_VENDOR_FLAG,1,msii_master_temp.MUST_USE_APPROVED_VENDOR_FLAG,MSII.MUST_USE_APPROVED_VENDOR_FLAG ),
          MSII.OUTSIDE_OPERATION_FLAG        =  decode( A_OUTSIDE_OPERATION_FLAG,1,msii_master_temp.OUTSIDE_OPERATION_FLAG,MSII.OUTSIDE_OPERATION_FLAG ),
          MSII.OUTSIDE_OPERATION_UOM_TYPE    =  decode( A_OUTSIDE_OPERATION_UOM_TYPE,1,msii_master_temp.OUTSIDE_OPERATION_UOM_TYPE,MSII.OUTSIDE_OPERATION_UOM_TYPE ),
          MSII.PRICE_TOLERANCE_PERCENT       =  decode( A_PRICE_TOLERANCE_PERCENT,1,msii_master_temp.PRICE_TOLERANCE_PERCENT,MSII.PRICE_TOLERANCE_PERCENT ),
          MSII.PURCHASING_ENABLED_FLAG       =  decode( A_PURCHASING_ENABLED_FLAG,1,msii_master_temp.PURCHASING_ENABLED_FLAG,MSII.PURCHASING_ENABLED_FLAG ),
          MSII.PURCHASING_ITEM_FLAG          =  decode( A_PURCHASING_ITEM_FLAG,1,msii_master_temp.PURCHASING_ITEM_FLAG,MSII.PURCHASING_ITEM_FLAG ),
          MSII.RFQ_REQUIRED_FLAG             =  decode( A_RFQ_REQUIRED_FLAG,1,msii_master_temp.RFQ_REQUIRED_FLAG,MSII.RFQ_REQUIRED_FLAG ),
          MSII.ROUNDING_FACTOR               =  decode( A_ROUNDING_FACTOR,1,msii_master_temp.ROUNDING_FACTOR,MSII.ROUNDING_FACTOR ),
          MSII.TAXABLE_FLAG                  =  decode( A_TAXABLE_FLAG,1,msii_master_temp.TAXABLE_FLAG,MSII.TAXABLE_FLAG ),
          MSII.PURCHASING_TAX_CODE           =  decode( A_PURCHASING_TAX_CODE,1,msii_master_temp.PURCHASING_TAX_CODE,MSII.PURCHASING_TAX_CODE ),
          MSII.UNIT_OF_ISSUE                 =  decode( A_UNIT_OF_ISSUE,1,msii_master_temp.UNIT_OF_ISSUE,MSII.UNIT_OF_ISSUE ),
          MSII.UN_NUMBER_ID                  =  decode( A_UN_NUMBER_ID,1,msii_master_temp.UN_NUMBER_ID,MSII.UN_NUMBER_ID ),
          MSII.ALLOW_EXPRESS_DELIVERY_FLAG   =  decode( A_ALLOW_EXPRESS_DELIVERY_FLAG,1,msii_master_temp.ALLOW_EXPRESS_DELIVERY_FLAG,MSII.ALLOW_EXPRESS_DELIVERY_FLAG ),
          MSII.ALLOW_SUBSTITUTE_RECEIPTS_FLAG=  decode( A_ALLOW_SUBS_RECEIPTS_FLAG,1,msii_master_temp.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,MSII.ALLOW_SUBSTITUTE_RECEIPTS_FLAG ),
          MSII.ALLOW_UNORDERED_RECEIPTS_FLAG =  decode( A_ALLOW_UNORD_RECEIPTS_FLAG,1,msii_master_temp.ALLOW_UNORDERED_RECEIPTS_FLAG,MSII.ALLOW_UNORDERED_RECEIPTS_FLAG ),
          MSII.DAYS_EARLY_RECEIPT_ALLOWED    =  decode( A_DAYS_EARLY_RECEIPT_ALLOWED,1,msii_master_temp.DAYS_EARLY_RECEIPT_ALLOWED,MSII.DAYS_EARLY_RECEIPT_ALLOWED ),
          MSII.DAYS_LATE_RECEIPT_ALLOWED     =  decode( A_DAYS_LATE_RECEIPT_ALLOWED,1,msii_master_temp.DAYS_LATE_RECEIPT_ALLOWED,MSII.DAYS_LATE_RECEIPT_ALLOWED ),
          MSII.ENFORCE_SHIP_TO_LOCATION_CODE =  decode( A_ENFORCE_SHIP_TO_LOC_CODE,1,msii_master_temp.ENFORCE_SHIP_TO_LOCATION_CODE,MSII.ENFORCE_SHIP_TO_LOCATION_CODE ),
          MSII.INSPECTION_REQUIRED_FLAG      =  decode( A_INSPECTION_REQUIRED_FLAG,1,msii_master_temp.INSPECTION_REQUIRED_FLAG,MSII.INSPECTION_REQUIRED_FLAG ),
          MSII.INVOICE_CLOSE_TOLERANCE       =  decode( A_INVOICE_CLOSE_TOLERANCE,1,msii_master_temp.INVOICE_CLOSE_TOLERANCE,MSII.INVOICE_CLOSE_TOLERANCE ),
          MSII.QTY_RCV_EXCEPTION_CODE        =  decode( A_QTY_RCV_EXCEPTION_CODE,1,msii_master_temp.QTY_RCV_EXCEPTION_CODE,MSII.QTY_RCV_EXCEPTION_CODE ),
          MSII.QTY_RCV_TOLERANCE             =  decode( A_QTY_RCV_TOLERANCE,1,msii_master_temp.QTY_RCV_TOLERANCE,MSII.QTY_RCV_TOLERANCE ),
          MSII.RECEIPT_DAYS_EXCEPTION_CODE   =  decode( A_RECEIPT_DAYS_EXCEPTION_CODE,1,msii_master_temp.RECEIPT_DAYS_EXCEPTION_CODE,MSII.RECEIPT_DAYS_EXCEPTION_CODE ),
          MSII.RECEIPT_REQUIRED_FLAG         =  decode( A_RECEIPT_REQUIRED_FLAG,1,msii_master_temp.RECEIPT_REQUIRED_FLAG,MSII.RECEIPT_REQUIRED_FLAG ),
          MSII.RECEIVE_CLOSE_TOLERANCE       =  decode( A_RECEIVE_CLOSE_TOLERANCE,1,msii_master_temp.RECEIVE_CLOSE_TOLERANCE,MSII.RECEIVE_CLOSE_TOLERANCE ),
          MSII.RECEIVING_ROUTING_ID          =  decode( A_RECEIVING_ROUTING_ID,1,msii_master_temp.RECEIVING_ROUTING_ID,MSII.RECEIVING_ROUTING_ID ),
          MSII.AUTO_LOT_ALPHA_PREFIX         =  decode( A_AUTO_LOT_ALPHA_PREFIX,1,msii_master_temp.AUTO_LOT_ALPHA_PREFIX,MSII.AUTO_LOT_ALPHA_PREFIX ),
          MSII.AUTO_SERIAL_ALPHA_PREFIX      =  decode( A_AUTO_SERIAL_ALPHA_PREFIX,1,msii_master_temp.AUTO_SERIAL_ALPHA_PREFIX,MSII.AUTO_SERIAL_ALPHA_PREFIX ),
          MSII.CYCLE_COUNT_ENABLED_FLAG      =  decode( A_CYCLE_COUNT_ENABLED_FLAG,1,msii_master_temp.CYCLE_COUNT_ENABLED_FLAG,MSII.CYCLE_COUNT_ENABLED_FLAG ),
          MSII.INVENTORY_ITEM_FLAG           =  decode( A_INVENTORY_ITEM_FLAG,1,msii_master_temp.INVENTORY_ITEM_FLAG,MSII.INVENTORY_ITEM_FLAG ),
          MSII.LOCATION_CONTROL_CODE         =  decode( A_LOCATION_CONTROL_CODE,1,msii_master_temp.LOCATION_CONTROL_CODE,MSII.LOCATION_CONTROL_CODE ),
          MSII.LOT_CONTROL_CODE              =  decode( A_LOT_CONTROL_CODE,1,msii_master_temp.LOT_CONTROL_CODE,MSII.LOT_CONTROL_CODE ),
          MSII.MTL_TRANSACTIONS_ENABLED_FLAG =  decode( A_MTL_TRANSAC_ENABLED_FLAG,1,msii_master_temp.MTL_TRANSACTIONS_ENABLED_FLAG,MSII.MTL_TRANSACTIONS_ENABLED_FLAG ),
          MSII.NEGATIVE_MEASUREMENT_ERROR    =  decode( A_NEGATIVE_MEASUREMENT_ERROR,1,msii_master_temp.NEGATIVE_MEASUREMENT_ERROR,MSII.NEGATIVE_MEASUREMENT_ERROR ),
          MSII.RESERVABLE_TYPE               =  decode( A_RESERVABLE_TYPE,1,msii_master_temp.RESERVABLE_TYPE,MSII.RESERVABLE_TYPE ),
          MSII.RESTRICT_LOCATORS_CODE        =  decode( A_RESTRICT_LOCATORS_CODE,1,msii_master_temp.RESTRICT_LOCATORS_CODE,MSII.RESTRICT_LOCATORS_CODE ),
          MSII.RESTRICT_SUBINVENTORIES_CODE  =  decode( A_RESTRICT_SUBINVENTORIES_CODE,1,msii_master_temp.RESTRICT_SUBINVENTORIES_CODE,MSII.RESTRICT_SUBINVENTORIES_CODE ),
          MSII.REVISION_QTY_CONTROL_CODE     =  decode( A_REVISION_QTY_CONTROL_CODE,1,msii_master_temp.REVISION_QTY_CONTROL_CODE,MSII.REVISION_QTY_CONTROL_CODE ),
          MSII.SERIAL_NUMBER_CONTROL_CODE    =  decode( A_SERIAL_NUMBER_CONTROL_CODE,1,msii_master_temp.SERIAL_NUMBER_CONTROL_CODE,MSII.SERIAL_NUMBER_CONTROL_CODE ),
          MSII.SHELF_LIFE_CODE               =  decode( A_SHELF_LIFE_CODE,1,msii_master_temp.SHELF_LIFE_CODE,MSII.SHELF_LIFE_CODE ),
          MSII.SHELF_LIFE_DAYS               =  decode( A_SHELF_LIFE_DAYS,1,msii_master_temp.SHELF_LIFE_DAYS,MSII.SHELF_LIFE_DAYS ),
          MSII.START_AUTO_LOT_NUMBER         =  decode( A_START_AUTO_LOT_NUMBER,1,msii_master_temp.START_AUTO_LOT_NUMBER,MSII.START_AUTO_LOT_NUMBER ),
          MSII.START_AUTO_SERIAL_NUMBER      =  decode( A_START_AUTO_SERIAL_NUMBER,1,msii_master_temp.START_AUTO_SERIAL_NUMBER,MSII.START_AUTO_SERIAL_NUMBER ),
          MSII.STOCK_ENABLED_FLAG            =  decode( A_STOCK_ENABLED_FLAG,1,msii_master_temp.STOCK_ENABLED_FLAG,MSII.STOCK_ENABLED_FLAG ),
          MSII.UNIT_VOLUME                   =  decode( A_UNIT_VOLUME,1,msii_master_temp.UNIT_VOLUME,MSII.UNIT_VOLUME ),
          MSII.UNIT_WEIGHT                   =  decode( A_UNIT_WEIGHT,1,msii_master_temp.UNIT_WEIGHT,MSII.UNIT_WEIGHT ),
          MSII.VOLUME_UOM_CODE               =  decode( A_VOLUME_UOM_CODE,1,msii_master_temp.VOLUME_UOM_CODE,MSII.VOLUME_UOM_CODE ),
          MSII.WEIGHT_UOM_CODE               =  decode( A_WEIGHT_UOM_CODE,1,msii_master_temp.WEIGHT_UOM_CODE,MSII.WEIGHT_UOM_CODE ),
          MSII.CARRYING_COST                 =  decode( A_CARRYING_COST,1,msii_master_temp.CARRYING_COST,MSII.CARRYING_COST ),
          MSII.FIXED_DAYS_SUPPLY             =  decode( A_FIXED_DAYS_SUPPLY,1,msii_master_temp.FIXED_DAYS_SUPPLY,MSII.FIXED_DAYS_SUPPLY ),
          MSII.FIXED_LOT_MULTIPLIER          =  decode( A_FIXED_LOT_MULTIPLIER,1,msii_master_temp.FIXED_LOT_MULTIPLIER,MSII.FIXED_LOT_MULTIPLIER ),
          MSII.FIXED_ORDER_QUANTITY          =  decode( A_FIXED_ORDER_QUANTITY,1, msii_master_temp.FIXED_ORDER_QUANTITY,MSII.FIXED_ORDER_QUANTITY ),
          MSII.INVENTORY_PLANNING_CODE       =  decode( A_INVENTORY_PLANNING_CODE,1,msii_master_temp.INVENTORY_PLANNING_CODE,MSII.INVENTORY_PLANNING_CODE ),
          MSII.MAXIMUM_ORDER_QUANTITY        =  decode( A_MAXIMUM_ORDER_QUANTITY,1,msii_master_temp.MAXIMUM_ORDER_QUANTITY,MSII.MAXIMUM_ORDER_QUANTITY ),
          MSII.MAX_MINMAX_QUANTITY           =  decode( A_MAX_MINMAX_QUANTITY,1,msii_master_temp.MAX_MINMAX_QUANTITY,MSII.MAX_MINMAX_QUANTITY ),
          MSII.MINIMUM_ORDER_QUANTITY        =  decode( A_MINIMUM_ORDER_QUANTITY,1,msii_master_temp.MINIMUM_ORDER_QUANTITY,MSII.MINIMUM_ORDER_QUANTITY ),
          MSII.MIN_MINMAX_QUANTITY           =  decode( A_MIN_MINMAX_QUANTITY,1,msii_master_temp.MIN_MINMAX_QUANTITY,MSII.MIN_MINMAX_QUANTITY ),
          MSII.MRP_SAFETY_STOCK_CODE         =  decode( A_MRP_SAFETY_STOCK_CODE,1,msii_master_temp.MRP_SAFETY_STOCK_CODE,MSII.MRP_SAFETY_STOCK_CODE ),
          MSII.MRP_SAFETY_STOCK_PERCENT      =  decode( A_MRP_SAFETY_STOCK_PERCENT,1, msii_master_temp.MRP_SAFETY_STOCK_PERCENT,MSII.MRP_SAFETY_STOCK_PERCENT ),
          MSII.ORDER_COST                    =  decode( A_ORDER_COST,1,msii_master_temp.ORDER_COST,MSII.ORDER_COST ),
          MSII.PLANNER_CODE                  =  decode( A_PLANNER_CODE,1,msii_master_temp.PLANNER_CODE,MSII.PLANNER_CODE ),
          MSII.SAFETY_STOCK_BUCKET_DAYS      =  decode( A_SAFETY_STOCK_BUCKET_DAYS,1,msii_master_temp.SAFETY_STOCK_BUCKET_DAYS,MSII.SAFETY_STOCK_BUCKET_DAYS ),
          MSII.SOURCE_ORGANIZATION_ID        =  decode( A_SOURCE_ORGANIZATION_ID,1,msii_master_temp.SOURCE_ORGANIZATION_ID,MSII.SOURCE_ORGANIZATION_ID ),
          MSII.SOURCE_SUBINVENTORY           =  decode( A_SOURCE_SUBINVENTORY,1,msii_master_temp.SOURCE_SUBINVENTORY,MSII.SOURCE_SUBINVENTORY ),
          MSII.SOURCE_TYPE                   =  decode( A_SOURCE_TYPE,1,msii_master_temp.SOURCE_TYPE,MSII.SOURCE_TYPE ),
          MSII.ACCEPTABLE_EARLY_DAYS         =  decode( A_ACCEPTABLE_EARLY_DAYS,1,msii_master_temp.ACCEPTABLE_EARLY_DAYS,MSII.ACCEPTABLE_EARLY_DAYS ),
          MSII.ACCEPTABLE_RATE_DECREASE      =  decode( A_ACCEPTABLE_RATE_DECREASE,1,msii_master_temp.ACCEPTABLE_RATE_DECREASE,MSII.ACCEPTABLE_RATE_DECREASE ),
          MSII.ACCEPTABLE_RATE_INCREASE      =  decode( A_ACCEPTABLE_RATE_INCREASE,1,msii_master_temp.ACCEPTABLE_RATE_INCREASE,MSII.ACCEPTABLE_RATE_INCREASE ),
          MSII.AUTO_REDUCE_MPS               =  decode( A_AUTO_REDUCE_MPS,1,msii_master_temp.AUTO_REDUCE_MPS,MSII.AUTO_REDUCE_MPS ),
          MSII.DEMAND_TIME_FENCE_CODE        =  decode( A_DEMAND_TIME_FENCE_CODE,1,msii_master_temp.DEMAND_TIME_FENCE_CODE,MSII.DEMAND_TIME_FENCE_CODE ),
          MSII.DEMAND_TIME_FENCE_DAYS        =  decode( A_DEMAND_TIME_FENCE_DAYS,1,msii_master_temp.DEMAND_TIME_FENCE_DAYS,MSII.DEMAND_TIME_FENCE_DAYS ),
          MSII.END_ASSEMBLY_PEGGING_FLAG     =  decode( A_END_ASSEMBLY_PEGGING_FLAG,1,msii_master_temp.END_ASSEMBLY_PEGGING_FLAG,MSII.END_ASSEMBLY_PEGGING_FLAG ),
          MSII.MRP_CALCULATE_ATP_FLAG        =  decode( A_MRP_CALCULATE_ATP_FLAG,1,msii_master_temp.MRP_CALCULATE_ATP_FLAG,MSII.MRP_CALCULATE_ATP_FLAG ),
          MSII.MRP_PLANNING_CODE             =  decode( A_MRP_PLANNING_CODE,1,msii_master_temp.MRP_PLANNING_CODE,MSII.MRP_PLANNING_CODE ),
          MSII.OVERRUN_PERCENTAGE            =  decode( A_OVERRUN_PERCENTAGE,1,msii_master_temp.OVERRUN_PERCENTAGE,MSII.OVERRUN_PERCENTAGE ),
          MSII.PLANNING_EXCEPTION_SET        =  decode( A_PLANNING_EXCEPTION_SET,1,msii_master_temp.PLANNING_EXCEPTION_SET,MSII.PLANNING_EXCEPTION_SET ),
          MSII.PLANNING_MAKE_BUY_CODE        =  decode( A_PLANNING_MAKE_BUY_CODE,1,msii_master_temp.PLANNING_MAKE_BUY_CODE,MSII.PLANNING_MAKE_BUY_CODE ),
          MSII.PLANNING_TIME_FENCE_CODE      =  decode( A_PLANNING_TIME_FENCE_CODE,1,msii_master_temp.PLANNING_TIME_FENCE_CODE,MSII.PLANNING_TIME_FENCE_CODE ),
          MSII.PLANNING_TIME_FENCE_DAYS      =  decode( A_PLANNING_TIME_FENCE_DAYS,1,msii_master_temp.PLANNING_TIME_FENCE_DAYS,MSII.PLANNING_TIME_FENCE_DAYS ),
          -- Bug #1052111
          MSII.RELEASE_TIME_FENCE_CODE       =  decode( A_RELEASE_TIME_FENCE_CODE,1,msii_master_temp.RELEASE_TIME_FENCE_CODE,MSII.RELEASE_TIME_FENCE_CODE ),
          MSII.RELEASE_TIME_FENCE_DAYS       =  decode( A_RELEASE_TIME_FENCE_DAYS,1,msii_master_temp.RELEASE_TIME_FENCE_DAYS,MSII.RELEASE_TIME_FENCE_DAYS ),
          MSII.REPETITIVE_PLANNING_FLAG      =  decode( A_REPETITIVE_PLANNING_FLAG,1,msii_master_temp.REPETITIVE_PLANNING_FLAG,MSII.REPETITIVE_PLANNING_FLAG ),
          MSII.ROUNDING_CONTROL_TYPE         =  decode( A_ROUNDING_CONTROL_TYPE,1, msii_master_temp.ROUNDING_CONTROL_TYPE,MSII.ROUNDING_CONTROL_TYPE ),
          MSII.SHRINKAGE_RATE                =  decode( A_SHRINKAGE_RATE,1,msii_master_temp.SHRINKAGE_RATE,MSII.SHRINKAGE_RATE ),
          MSII.CUMULATIVE_TOTAL_LEAD_TIME    =  decode( A_CUMULATIVE_TOTAL_LEAD_TIME,1,msii_master_temp.CUMULATIVE_TOTAL_LEAD_TIME,MSII.CUMULATIVE_TOTAL_LEAD_TIME ),
          MSII.CUM_MANUFACTURING_LEAD_TIME   =  decode( A_CUM_MANUFACTURING_LEAD_TIME,1,msii_master_temp.CUM_MANUFACTURING_LEAD_TIME,MSII.CUM_MANUFACTURING_LEAD_TIME ),
          MSII.FIXED_LEAD_TIME               =  decode( A_FIXED_LEAD_TIME,1,msii_master_temp.FIXED_LEAD_TIME,MSII.FIXED_LEAD_TIME ),
          MSII.FULL_LEAD_TIME                =  decode( A_FULL_LEAD_TIME,1,msii_master_temp.FULL_LEAD_TIME,MSII.FULL_LEAD_TIME ),
          MSII.POSTPROCESSING_LEAD_TIME      =  decode( A_POSTPROCESSING_LEAD_TIME,1,msii_master_temp.POSTPROCESSING_LEAD_TIME,MSII.POSTPROCESSING_LEAD_TIME ),
          MSII.PREPROCESSING_LEAD_TIME       =  decode( A_PREPROCESSING_LEAD_TIME,1,msii_master_temp.PREPROCESSING_LEAD_TIME,MSII.PREPROCESSING_LEAD_TIME ),
          MSII.VARIABLE_LEAD_TIME            =  decode( A_VARIABLE_LEAD_TIME,1,msii_master_temp.VARIABLE_LEAD_TIME,MSII.VARIABLE_LEAD_TIME ),
          MSII.BUILD_IN_WIP_FLAG             =  decode( A_BUILD_IN_WIP_FLAG,1,msii_master_temp.BUILD_IN_WIP_FLAG,MSII.BUILD_IN_WIP_FLAG ),
          MSII.WIP_SUPPLY_LOCATOR_ID         =  decode( A_WIP_SUPPLY_LOCATOR_ID,1,msii_master_temp.WIP_SUPPLY_LOCATOR_ID,MSII.WIP_SUPPLY_LOCATOR_ID ),
          MSII.WIP_SUPPLY_SUBINVENTORY       =  decode( A_WIP_SUPPLY_SUBINVENTORY,1,msii_master_temp.WIP_SUPPLY_SUBINVENTORY,MSII.WIP_SUPPLY_SUBINVENTORY ),
          MSII.WIP_SUPPLY_TYPE               =  decode( A_WIP_SUPPLY_TYPE,1,msii_master_temp.WIP_SUPPLY_TYPE,MSII.WIP_SUPPLY_TYPE ),
          MSII.ATP_COMPONENTS_FLAG           =  decode( A_ATP_COMPONENTS_FLAG,1,msii_master_temp.ATP_COMPONENTS_FLAG,MSII.ATP_COMPONENTS_FLAG ),
          MSII.ATP_FLAG                      =  decode( A_ATP_FLAG,1,msii_master_temp.ATP_FLAG,MSII.ATP_FLAG ),
          MSII.ATP_RULE_ID                   =  decode( A_ATP_RULE_ID,1,msii_master_temp.ATP_RULE_ID,MSII.ATP_RULE_ID ),
          MSII.COLLATERAL_FLAG               =  decode( A_COLLATERAL_FLAG,1,msii_master_temp.COLLATERAL_FLAG,MSII.COLLATERAL_FLAG ),
          MSII.CUSTOMER_ORDER_ENABLED_FLAG   =  decode( A_CUSTOMER_ORDER_ENABLED_FLAG,1,msii_master_temp.CUSTOMER_ORDER_ENABLED_FLAG,MSII.CUSTOMER_ORDER_ENABLED_FLAG ),
          MSII.CUSTOMER_ORDER_FLAG           =  decode( A_CUSTOMER_ORDER_FLAG,1,msii_master_temp.CUSTOMER_ORDER_FLAG,MSII.CUSTOMER_ORDER_FLAG ),
          MSII.DEFAULT_SHIPPING_ORG          =  decode( A_DEFAULT_SHIPPING_ORG,1,msii_master_temp.DEFAULT_SHIPPING_ORG,MSII.DEFAULT_SHIPPING_ORG ),
          MSII.INTERNAL_ORDER_ENABLED_FLAG   =  decode( A_INTERNAL_ORDER_ENABLED_FLAG,1,msii_master_temp.INTERNAL_ORDER_ENABLED_FLAG,MSII.INTERNAL_ORDER_ENABLED_FLAG ),

                MSII.INTERNAL_ORDER_FLAG =
                decode( A_INTERNAL_ORDER_FLAG,
                        1,
                        msii_master_temp.INTERNAL_ORDER_FLAG,
                        MSII.INTERNAL_ORDER_FLAG ),

                MSII.PICKING_RULE_ID =
                decode( A_PICKING_RULE_ID,
                        1,
                        msii_master_temp.PICKING_RULE_ID,
                        MSII.PICKING_RULE_ID ),

                MSII.PICK_COMPONENTS_FLAG =
                decode( A_PICK_COMPONENTS_FLAG,
                        1,
                        msii_master_temp.PICK_COMPONENTS_FLAG,
                        MSII.PICK_COMPONENTS_FLAG ),

                MSII.REPLENISH_TO_ORDER_FLAG =
                decode( A_REPLENISH_TO_ORDER_FLAG,
                        1,
                        msii_master_temp.REPLENISH_TO_ORDER_FLAG,
                        MSII.REPLENISH_TO_ORDER_FLAG ),

                MSII.RETURNABLE_FLAG =
                decode( A_RETURNABLE_FLAG,
                        1,
                        msii_master_temp.RETURNABLE_FLAG,
                        MSII.RETURNABLE_FLAG ),

                MSII.RETURN_INSPECTION_REQUIREMENT =
                decode( A_RETURN_INSPECTION_REQMT,
                        1,
                        msii_master_temp.RETURN_INSPECTION_REQUIREMENT,
                        MSII.RETURN_INSPECTION_REQUIREMENT ),

                MSII.SHIPPABLE_ITEM_FLAG =
                decode( A_SHIPPABLE_ITEM_FLAG,
                        1,
                        msii_master_temp.SHIPPABLE_ITEM_FLAG,
                        MSII.SHIPPABLE_ITEM_FLAG ),

                MSII.SHIP_MODEL_COMPLETE_FLAG =
                decode( A_SHIP_MODEL_COMPLETE_FLAG,
                        1,
                        msii_master_temp.SHIP_MODEL_COMPLETE_FLAG,
                        MSII.SHIP_MODEL_COMPLETE_FLAG ),

                MSII.SO_TRANSACTIONS_FLAG =
                decode( A_SO_TRANSACTIONS_FLAG,
                        1,
                        msii_master_temp.SO_TRANSACTIONS_FLAG,
                        MSII.SO_TRANSACTIONS_FLAG ),

                MSII.ACCOUNTING_RULE_ID =
                decode( A_ACCOUNTING_RULE_ID,
                        1,
                        msii_master_temp.ACCOUNTING_RULE_ID,
                        MSII.ACCOUNTING_RULE_ID ),

                MSII.INVOICEABLE_ITEM_FLAG =
                decode( A_INVOICEABLE_ITEM_FLAG,
                        1,
                        msii_master_temp.INVOICEABLE_ITEM_FLAG,
                        MSII.INVOICEABLE_ITEM_FLAG ),

                MSII.INVOICE_ENABLED_FLAG =
                decode( A_INVOICE_ENABLED_FLAG,
                        1,
                        msii_master_temp.INVOICE_ENABLED_FLAG,
                        MSII.INVOICE_ENABLED_FLAG ),

                MSII.ENGINEERING_DATE =
                decode( A_ENGINEERING_DATE,
                        1,
                        msii_master_temp.ENGINEERING_DATE,
                        MSII.ENGINEERING_DATE ),

                MSII.INVOICING_RULE_ID =
                decode( A_INVOICING_RULE_ID,
                        1,
                        msii_master_temp.INVOICING_RULE_ID,
                        MSII.INVOICING_RULE_ID ),

                MSII.PAYMENT_TERMS_ID =
                decode( A_PAYMENT_TERMS_ID,
                        1,
                        msii_master_temp.PAYMENT_TERMS_ID,
                        MSII.PAYMENT_TERMS_ID ),

                MSII.SALES_ACCOUNT =
                decode( A_SALES_ACCOUNT,
                        1,
                        msii_master_temp.SALES_ACCOUNT,
                        MSII.SALES_ACCOUNT ),

                MSII.TAX_CODE =
                decode( A_TAX_CODE,
                        1,
                        msii_master_temp.TAX_CODE,
                        MSII.TAX_CODE ),

                MSII.COVERAGE_SCHEDULE_ID =
                decode( A_COVERAGE_SCHEDULE_ID,
                        1,
                        msii_master_temp.COVERAGE_SCHEDULE_ID,
                        MSII.COVERAGE_SCHEDULE_ID ),

                MSII.MATERIAL_BILLABLE_FLAG =
                decode( A_MATERIAL_BILLABLE_FLAG,
                        1,
                        msii_master_temp.MATERIAL_BILLABLE_FLAG,
                        MSII.MATERIAL_BILLABLE_FLAG ),

                MSII.MAX_WARRANTY_AMOUNT =
                decode( A_MAX_WARRANTY_AMOUNT,
                        1,
                        msii_master_temp.MAX_WARRANTY_AMOUNT,
                        MSII.MAX_WARRANTY_AMOUNT ),

                MSII.PREVENTIVE_MAINTENANCE_FLAG =
                decode( A_PREVENTIVE_MAINTENANCE_FLAG,
                        1,
                        msii_master_temp.PREVENTIVE_MAINTENANCE_FLAG,
                        MSII.PREVENTIVE_MAINTENANCE_FLAG ),

                MSII.PRORATE_SERVICE_FLAG =
                decode( A_PRORATE_SERVICE_FLAG,
                        1,
                        msii_master_temp.PRORATE_SERVICE_FLAG,
                        MSII.PRORATE_SERVICE_FLAG ),

                MSII.RESPONSE_TIME_PERIOD_CODE =
                decode( A_RESPONSE_TIME_PERIOD_CODE,
                        1,
                        msii_master_temp.RESPONSE_TIME_PERIOD_CODE,
                        MSII.RESPONSE_TIME_PERIOD_CODE ),

                MSII.RESPONSE_TIME_VALUE =
                decode( A_RESPONSE_TIME_VALUE,
                        1,
                        msii_master_temp.RESPONSE_TIME_VALUE,
                        MSII.RESPONSE_TIME_VALUE ),

                MSII.SERVICE_DURATION =
                decode( A_SERVICE_DURATION,
                        1,
                        msii_master_temp.SERVICE_DURATION,
                        MSII.SERVICE_DURATION ),

                MSII.SERVICE_DURATION_PERIOD_CODE =
                decode( A_SERVICE_DURATION_PERIOD_CODE,
                        1,
                        msii_master_temp.SERVICE_DURATION_PERIOD_CODE,
                        MSII.SERVICE_DURATION_PERIOD_CODE ),

                MSII.WARRANTY_VENDOR_ID =
                decode( A_WARRANTY_VENDOR_ID,
                        1,
                        msii_master_temp.WARRANTY_VENDOR_ID,
                        MSII.WARRANTY_VENDOR_ID ),

                MSII.BASE_WARRANTY_SERVICE_ID =
                decode( A_BASE_WARRANTY_SERVICE_ID,
                        1,
                        msii_master_temp.BASE_WARRANTY_SERVICE_ID,
                        MSII.BASE_WARRANTY_SERVICE_ID ),

                MSII.NEW_REVISION_CODE =
                decode( A_NEW_REVISION_CODE,
                        1,
                        msii_master_temp.NEW_REVISION_CODE,
                        MSII.NEW_REVISION_CODE ),

                MSII.PRIMARY_SPECIALIST_ID =
                decode( A_PRIMARY_SPECIALIST_ID,
                        1,
                        msii_master_temp.PRIMARY_SPECIALIST_ID,
                        MSII.PRIMARY_SPECIALIST_ID ),

                MSII.SECONDARY_SPECIALIST_ID =
                decode( A_SECONDARY_SPECIALIST_ID,
                        1,
                        msii_master_temp.SECONDARY_SPECIALIST_ID,
                        MSII.SECONDARY_SPECIALIST_ID ),

                MSII.SERVICEABLE_COMPONENT_FLAG =
                decode( A_SERVICEABLE_COMPONENT_FLAG,
                        1,
                        msii_master_temp.SERVICEABLE_COMPONENT_FLAG,
                        MSII.SERVICEABLE_COMPONENT_FLAG ),

                MSII.SERVICEABLE_ITEM_CLASS_ID =
                decode( A_SERVICEABLE_ITEM_CLASS_ID,
                        1,
                        msii_master_temp.SERVICEABLE_ITEM_CLASS_ID,
                        MSII.SERVICEABLE_ITEM_CLASS_ID ),

                MSII.SERVICEABLE_PRODUCT_FLAG =
                decode( A_SERVICEABLE_PRODUCT_FLAG,
                        1,
                        msii_master_temp.SERVICEABLE_PRODUCT_FLAG,
                        MSII.SERVICEABLE_PRODUCT_FLAG ),

                MSII.SERVICE_STARTING_DELAY =
                decode( A_SERVICE_STARTING_DELAY,
                        1,
                        msii_master_temp.SERVICE_STARTING_DELAY,
                        MSII.SERVICE_STARTING_DELAY ),

                MSII.ATO_FORECAST_CONTROL =
                decode( A_ATO_FORECAST_CONTROL,
                        1,
                        msii_master_temp.ATO_FORECAST_CONTROL,
                        MSII.ATO_FORECAST_CONTROL ),

                MSII.DESCRIPTION =
                decode( A_DESCRIPTION,
                        1,
                        msii_master_temp.DESCRIPTION,
                        MSII.DESCRIPTION ),

                MSII.LONG_DESCRIPTION =
                decode( A_LONG_DESCRIPTION,
                        1,
                        msii_master_temp.LONG_DESCRIPTION,
                        MSII.LONG_DESCRIPTION ),

                MSII.LEAD_TIME_LOT_SIZE =
                decode( A_LEAD_TIME_LOT_SIZE,
                        1,
                        msii_master_temp.LEAD_TIME_LOT_SIZE,
                        MSII.LEAD_TIME_LOT_SIZE ),

                MSII.POSITIVE_MEASUREMENT_ERROR =
                decode( A_POSITIVE_MEASUREMENT_ERROR,
                        1,
                        msii_master_temp.POSITIVE_MEASUREMENT_ERROR,
                        MSII.POSITIVE_MEASUREMENT_ERROR ),


                MSII.CONTAINER_ITEM_FLAG =
                decode( A_CONTAINER_ITEM_FLAG,
                        1,
                        msii_master_temp.CONTAINER_ITEM_FLAG,
                        MSII.CONTAINER_ITEM_FLAG ),
                MSII.VEHICLE_ITEM_FLAG =
                decode( A_VEHICLE_ITEM_FLAG,
                        1,
                        msii_master_temp.VEHICLE_ITEM_FLAG,
                        MSII.VEHICLE_ITEM_FLAG ),

                MSII.MAXIMUM_LOAD_WEIGHT =
                decode( A_MAXIMUM_LOAD_WEIGHT,
                        1,
                        msii_master_temp.MAXIMUM_LOAD_WEIGHT,
                        MSII.MAXIMUM_LOAD_WEIGHT ),

                MSII.MINIMUM_FILL_PERCENT =
                decode( A_MINIMUM_FILL_PERCENT,
                        1,
                        msii_master_temp.MINIMUM_FILL_PERCENT,
                        MSII.MINIMUM_FILL_PERCENT ),

                MSII.INTERNAL_VOLUME =
                decode( A_INTERNAL_VOLUME,
                        1,
                        msii_master_temp.INTERNAL_VOLUME,
                        MSII.INTERNAL_VOLUME ),

                MSII.CONTAINER_TYPE_CODE =
                decode( A_CONTAINER_TYPE_CODE,
                        1,
                        msii_master_temp.CONTAINER_TYPE_CODE,
                        MSII.CONTAINER_TYPE_CODE ),

         MSII.CHECK_SHORTAGES_FLAG =
         decode( A_CHECK_SHORTAGES_FLAG,
                 1, msii_master_temp.CHECK_SHORTAGES_FLAG,
                 MSII.CHECK_SHORTAGES_FLAG ),

         MSII.EFFECTIVITY_CONTROL =
         decode( A_EFFECTIVITY_CONTROL,
                 1, msii_master_temp.EFFECTIVITY_CONTROL,
                 MSII.EFFECTIVITY_CONTROL ),

         MSII.OVERCOMPLETION_TOLERANCE_TYPE =
         decode( A_OVERCOMPLETION_TOLERANCE_TYP,
                 1, msii_master_temp.OVERCOMPLETION_TOLERANCE_TYPE,
                 MSII.OVERCOMPLETION_TOLERANCE_TYPE ),

         MSII.OVERCOMPLETION_TOLERANCE_VALUE =
         decode( A_OVERCOMPLETION_TOLERANCE_VAL,
                 1, msii_master_temp.OVERCOMPLETION_TOLERANCE_VALUE,
                 MSII.OVERCOMPLETION_TOLERANCE_VALUE ),

         MSII.OVER_SHIPMENT_TOLERANCE =
         decode( A_OVER_SHIPMENT_TOLERANCE,
                 1, msii_master_temp.OVER_SHIPMENT_TOLERANCE,
                 MSII.OVER_SHIPMENT_TOLERANCE ),

         MSII.UNDER_SHIPMENT_TOLERANCE =
         decode( A_UNDER_SHIPMENT_TOLERANCE,
                 1, msii_master_temp.UNDER_SHIPMENT_TOLERANCE,
                 MSII.UNDER_SHIPMENT_TOLERANCE ),

         MSII.OVER_RETURN_TOLERANCE =
         decode( A_OVER_RETURN_TOLERANCE,
                 1, msii_master_temp.OVER_RETURN_TOLERANCE,
                 MSII.OVER_RETURN_TOLERANCE ),

         MSII.UNDER_RETURN_TOLERANCE =
         decode( A_UNDER_RETURN_TOLERANCE,
                 1, msii_master_temp.UNDER_RETURN_TOLERANCE,
                 MSII.UNDER_RETURN_TOLERANCE ),

         MSII.EQUIPMENT_TYPE =
         decode( A_EQUIPMENT_TYPE,
                 1, msii_master_temp.EQUIPMENT_TYPE,
                 MSII.EQUIPMENT_TYPE ),

         MSII.RECOVERED_PART_DISP_CODE =
         decode( A_RECOVERED_PART_DISP_CODE,
                 1, msii_master_temp.RECOVERED_PART_DISP_CODE,
                 MSII.RECOVERED_PART_DISP_CODE ),

         MSII.DEFECT_TRACKING_ON_FLAG =
         decode( A_DEFECT_TRACKING_ON_FLAG,
                 1, msii_master_temp.DEFECT_TRACKING_ON_FLAG,
                 MSII.DEFECT_TRACKING_ON_FLAG ),

         MSII.EVENT_FLAG =
         decode( A_EVENT_FLAG,
                 1, msii_master_temp.EVENT_FLAG,
                 MSII.EVENT_FLAG ),

         MSII.ELECTRONIC_FLAG =
         decode( A_ELECTRONIC_FLAG,
                 1, msii_master_temp.ELECTRONIC_FLAG,
                 MSII.ELECTRONIC_FLAG ),

         MSII. DOWNLOADABLE_FLAG=
         decode( A_DOWNLOADABLE_FLAG,
                 1, msii_master_temp.DOWNLOADABLE_FLAG,
                 MSII.DOWNLOADABLE_FLAG ),

         MSII.VOL_DISCOUNT_EXEMPT_FLAG =
         decode( A_VOL_DISCOUNT_EXEMPT_FLAG,
                 1, msii_master_temp.VOL_DISCOUNT_EXEMPT_FLAG,
                 MSII.VOL_DISCOUNT_EXEMPT_FLAG ),

         MSII.COUPON_EXEMPT_FLAG =
         decode( A_COUPON_EXEMPT_FLAG,
                 1, msii_master_temp.COUPON_EXEMPT_FLAG,
                 MSII.COUPON_EXEMPT_FLAG ),

         MSII.COMMS_NL_TRACKABLE_FLAG =
         decode( A_COMMS_NL_TRACKABLE_FLAG,
                 1, msii_master_temp.COMMS_NL_TRACKABLE_FLAG,
                 MSII.COMMS_NL_TRACKABLE_FLAG ),

         MSII.ASSET_CREATION_CODE =
         decode( A_ASSET_CREATION_CODE,
                 1, msii_master_temp.ASSET_CREATION_CODE,
                 MSII.ASSET_CREATION_CODE ),

         MSII.COMMS_ACTIVATION_REQD_FLAG =
         decode( A_COMMS_ACTIVATION_REQD_FLAG,
                 1, msii_master_temp.COMMS_ACTIVATION_REQD_FLAG,
                 MSII.COMMS_ACTIVATION_REQD_FLAG ),

         MSII.ORDERABLE_ON_WEB_FLAG =
         decode( A_ORDERABLE_ON_WEB_FLAG,
                 1, msii_master_temp.ORDERABLE_ON_WEB_FLAG,
                 MSII.ORDERABLE_ON_WEB_FLAG ),

         MSII.BACK_ORDERABLE_FLAG =
         decode( A_BACK_ORDERABLE_FLAG,
                 1, msii_master_temp.BACK_ORDERABLE_FLAG,
                 MSII.BACK_ORDERABLE_FLAG ),

      MSII.WEB_STATUS =
      decode( A_WEB_STATUS,
              1, msii_master_temp.WEB_STATUS,
              MSII.WEB_STATUS ),

      MSII.INDIVISIBLE_FLAG =
      decode( A_INDIVISIBLE_FLAG,
              1, msii_master_temp.INDIVISIBLE_FLAG,
              MSII.INDIVISIBLE_FLAG ),

         MSII.DIMENSION_UOM_CODE =
         decode( A_DIMENSION_UOM_CODE,
                 1, msii_master_temp.DIMENSION_UOM_CODE,
                 MSII.DIMENSION_UOM_CODE ),

         MSII.UNIT_LENGTH =
         decode( A_UNIT_LENGTH,
                 1, msii_master_temp.UNIT_LENGTH,
                 MSII.UNIT_LENGTH ),

         MSII.UNIT_WIDTH =
         decode( A_UNIT_WIDTH,
                 1, msii_master_temp.UNIT_WIDTH,
                 MSII.UNIT_WIDTH ),

         MSII.UNIT_HEIGHT =
         decode( A_UNIT_HEIGHT,
                 1, msii_master_temp.UNIT_HEIGHT,
                 MSII.UNIT_HEIGHT ),

         MSII.BULK_PICKED_FLAG =
         decode( A_BULK_PICKED_FLAG,
                 1, msii_master_temp.BULK_PICKED_FLAG,
                 MSII.BULK_PICKED_FLAG ),

         MSII. LOT_STATUS_ENABLED=
         decode( A_LOT_STATUS_ENABLED,
                 1, msii_master_temp.LOT_STATUS_ENABLED,
                 MSII.LOT_STATUS_ENABLED ),

         MSII.DEFAULT_LOT_STATUS_ID =
         decode( A_DEFAULT_LOT_STATUS_ID,
                 1, msii_master_temp.DEFAULT_LOT_STATUS_ID,
                 MSII.DEFAULT_LOT_STATUS_ID ),

         MSII.SERIAL_STATUS_ENABLED =
         decode( A_SERIAL_STATUS_ENABLED,
                 1, msii_master_temp.SERIAL_STATUS_ENABLED,
                 MSII.SERIAL_STATUS_ENABLED ),

         MSII.DEFAULT_SERIAL_STATUS_ID =
         decode( A_DEFAULT_SERIAL_STATUS_ID,
                 1, msii_master_temp.DEFAULT_SERIAL_STATUS_ID,
                 MSII.DEFAULT_SERIAL_STATUS_ID ),

         MSII.LOT_SPLIT_ENABLED =
         decode( A_LOT_SPLIT_ENABLED,
                 1, msii_master_temp.LOT_SPLIT_ENABLED,
                 MSII.LOT_SPLIT_ENABLED ),

         MSII.LOT_MERGE_ENABLED =
         decode( A_LOT_MERGE_ENABLED,
                 1, msii_master_temp.LOT_MERGE_ENABLED,
                 MSII.LOT_MERGE_ENABLED ),

         MSII.INVENTORY_CARRY_PENALTY =
         decode( A_INVENTORY_CARRY_PENALTY,
                 1, msii_master_temp.INVENTORY_CARRY_PENALTY,
                 MSII.INVENTORY_CARRY_PENALTY ),

         MSII.OPERATION_SLACK_PENALTY =
         decode( A_OPERATION_SLACK_PENALTY,
                 1, msii_master_temp.OPERATION_SLACK_PENALTY,
                 MSII.OPERATION_SLACK_PENALTY ),

         MSII.FINANCING_ALLOWED_FLAG =
         decode( A_FINANCING_ALLOWED_FLAG,
                 1, msii_master_temp.FINANCING_ALLOWED_FLAG,
                 MSII.FINANCING_ALLOWED_FLAG ),

         MSII.EAM_ITEM_TYPE =
         decode( A_EAM_ITEM_TYPE,
                 1, msii_master_temp.EAM_ITEM_TYPE,
                 MSII.EAM_ITEM_TYPE ),

         MSII.EAM_ACTIVITY_TYPE_CODE =
         decode( A_EAM_ACTIVITY_TYPE_CODE,
                 1, msii_master_temp.EAM_ACTIVITY_TYPE_CODE,
                 MSII.EAM_ACTIVITY_TYPE_CODE ),

         MSII.EAM_ACTIVITY_CAUSE_CODE =
         decode( A_EAM_ACTIVITY_CAUSE_CODE,
                 1, msii_master_temp.EAM_ACTIVITY_CAUSE_CODE,
                 MSII.EAM_ACTIVITY_CAUSE_CODE ),

         MSII.EAM_ACT_NOTIFICATION_FLAG =
         decode( A_EAM_ACT_NOTIFICATION_FLAG,
                 1, msii_master_temp.EAM_ACT_NOTIFICATION_FLAG,
                 MSII.EAM_ACT_NOTIFICATION_FLAG ),

         MSII.EAM_ACT_SHUTDOWN_STATUS =
         decode( A_EAM_ACT_SHUTDOWN_STATUS,
                 1, msii_master_temp.EAM_ACT_SHUTDOWN_STATUS,
                 MSII.EAM_ACT_SHUTDOWN_STATUS ),

         MSII.DUAL_UOM_CONTROL =
         decode( A_DUAL_UOM_CONTROL,
                 1, msii_master_temp.DUAL_UOM_CONTROL,
                 MSII.DUAL_UOM_CONTROL ),

         MSII.SECONDARY_UOM_CODE =
         decode( A_SECONDARY_UOM_CODE,
                 1, msii_master_temp.SECONDARY_UOM_CODE,
                 MSII.SECONDARY_UOM_CODE ),

         MSII.DUAL_UOM_DEVIATION_HIGH =
         decode( A_DUAL_UOM_DEVIATION_HIGH,
                 1, msii_master_temp.DUAL_UOM_DEVIATION_HIGH,
                 MSII.DUAL_UOM_DEVIATION_HIGH ),

         MSII.DUAL_UOM_DEVIATION_LOW =
         decode( A_DUAL_UOM_DEVIATION_LOW,
                 1, msii_master_temp.DUAL_UOM_DEVIATION_LOW,
                 MSII.DUAL_UOM_DEVIATION_LOW ),
         MSII.CONTRACT_ITEM_TYPE_CODE =
         decode( A_CONTRACT_ITEM_TYPE_CODE,
                 1, msii_master_temp.CONTRACT_ITEM_TYPE_CODE,
                 MSII.CONTRACT_ITEM_TYPE_CODE ),
/* Removed 11.5.10
         MSII.SUBSCRIPTION_DEPEND_FLAG =
         decode( A_SUBSCRIPTION_DEPEND_FLAG,
                 1, msii_master_temp.SUBSCRIPTION_DEPEND_FLAG,
                 MSII.SUBSCRIPTION_DEPEND_FLAG ),
*/
      MSII.SERV_REQ_ENABLED_CODE =
      DECODE( A_SERV_REQ_ENABLED_CODE,
              1, msii_master_temp.SERV_REQ_ENABLED_CODE,
              MSII.SERV_REQ_ENABLED_CODE ),

      MSII.SERV_BILLING_ENABLED_FLAG =
      DECODE( A_SERV_BILLING_ENABLED_FLAG,
              1, msii_master_temp.SERV_BILLING_ENABLED_FLAG,
              MSII.SERV_BILLING_ENABLED_FLAG ),
      MSII.PLANNED_INV_POINT_FLAG =
      DECODE( A_PLANNED_INV_POINT_FLAG,
              1, msii_master_temp.PLANNED_INV_POINT_FLAG,
              MSII.PLANNED_INV_POINT_FLAG ),

      MSII.LOT_TRANSLATE_ENABLED =
      DECODE( A_LOT_TRANSLATE_ENABLED,
              1, msii_master_temp.LOT_TRANSLATE_ENABLED,
              MSII.LOT_TRANSLATE_ENABLED ),

      MSII.DEFAULT_SO_SOURCE_TYPE =
      DECODE( A_DEFAULT_SO_SOURCE_TYPE,
              1, msii_master_temp.DEFAULT_SO_SOURCE_TYPE,
              MSII.DEFAULT_SO_SOURCE_TYPE ),

      MSII.CREATE_SUPPLY_FLAG =
      DECODE( A_CREATE_SUPPLY_FLAG,
              1, msii_master_temp.CREATE_SUPPLY_FLAG,
              MSII.CREATE_SUPPLY_FLAG ),

      MSII.SUBSTITUTION_WINDOW_CODE =
      DECODE( A_SUBSTITUTION_WINDOW_CODE,
              1, msii_master_temp.SUBSTITUTION_WINDOW_CODE,
              MSII.SUBSTITUTION_WINDOW_CODE ),

      MSII.SUBSTITUTION_WINDOW_DAYS =
      DECODE( A_SUBSTITUTION_WINDOW_DAYS,
              1, msii_master_temp.SUBSTITUTION_WINDOW_DAYS,
              MSII.SUBSTITUTION_WINDOW_DAYS ),
--Added as part of 11.5.9 ENH
      MSII.LOT_SUBSTITUTION_ENABLED =
      DECODE( A_LOT_SUBSTITUTION_ENABLED,
              1, msii_master_temp.LOT_SUBSTITUTION_ENABLED,
              MSII.LOT_SUBSTITUTION_ENABLED ),

      MSII.MINIMUM_LICENSE_QUANTITY =
      DECODE( A_MINIMUM_LICENSE_QUANTITY,
              1, msii_master_temp.MINIMUM_LICENSE_QUANTITY,
              MSII.MINIMUM_LICENSE_QUANTITY ),

      MSII.EAM_ACTIVITY_SOURCE_CODE =
      DECODE( A_EAM_ACTIVITY_SOURCE_CODE,
              1, msii_master_temp.EAM_ACTIVITY_SOURCE_CODE,
              MSII.EAM_ACTIVITY_SOURCE_CODE ),

      MSII.IB_ITEM_INSTANCE_CLASS =
      DECODE( A_IB_ITEM_INSTANCE_CLASS,
              1, msii_master_temp.IB_ITEM_INSTANCE_CLASS,
              MSII.IB_ITEM_INSTANCE_CLASS ),

      MSII.CONFIG_MODEL_TYPE =
      DECODE( A_CONFIG_MODEL_TYPE,
              1, msii_master_temp.CONFIG_MODEL_TYPE,
              MSII.CONFIG_MODEL_TYPE ),
--Added as part of 11.5.10 ENH
      MSII.TRACKING_QUANTITY_IND =
      DECODE( A_TRACKING_QUANTITY_IND,
              1, msii_master_temp.TRACKING_QUANTITY_IND,
              MSII.TRACKING_QUANTITY_IND ),

      MSII.ONT_PRICING_QTY_SOURCE =
      DECODE( A_ONT_PRICING_QTY_SOURCE,
              1, msii_master_temp.ONT_PRICING_QTY_SOURCE,
              MSII.ONT_PRICING_QTY_SOURCE ),

      MSII.SECONDARY_DEFAULT_IND =
      DECODE( A_SECONDARY_DEFAULT_IND,
              1, msii_master_temp.SECONDARY_DEFAULT_IND,
              MSII.SECONDARY_DEFAULT_IND ),

      MSII.AUTO_CREATED_CONFIG_FLAG =
      DECODE( A_AUTO_CREATED_CONFIG_FLAG,
              1, msii_master_temp.AUTO_CREATED_CONFIG_FLAG,
              MSII.AUTO_CREATED_CONFIG_FLAG ),

      MSII.CONFIG_ORGS =
      DECODE( A_CONFIG_ORGS,
              1, msii_master_temp.CONFIG_ORGS,
              MSII.CONFIG_ORGS ),

      MSII.CONFIG_MATCH =
      DECODE( A_CONFIG_MATCH,
              1, msii_master_temp.CONFIG_MATCH,
              MSII.CONFIG_MATCH ),

      MSII.VMI_MINIMUM_UNITS =
      DECODE( A_VMI_MINIMUM_UNITS,
              1, msii_master_temp.VMI_MINIMUM_UNITS,
              MSII.VMI_MINIMUM_UNITS ),

      MSII.VMI_MINIMUM_DAYS =
      DECODE( A_VMI_MINIMUM_DAYS,
              1, msii_master_temp.VMI_MINIMUM_DAYS,
              MSII.VMI_MINIMUM_DAYS ),

      MSII.VMI_MAXIMUM_UNITS =
      DECODE( A_VMI_MAXIMUM_UNITS,
              1, msii_master_temp.VMI_MAXIMUM_UNITS,
              MSII.VMI_MAXIMUM_UNITS ),

      MSII.VMI_MAXIMUM_DAYS =
      DECODE( A_VMI_MAXIMUM_DAYS,
              1, msii_master_temp.VMI_MAXIMUM_DAYS,
              MSII.VMI_MAXIMUM_DAYS ),

      MSII.VMI_FIXED_ORDER_QUANTITY =
      DECODE( A_VMI_FIXED_ORDER_QUANTITY,
              1, msii_master_temp.VMI_FIXED_ORDER_QUANTITY,
              MSII.VMI_FIXED_ORDER_QUANTITY ),

      MSII.SO_AUTHORIZATION_FLAG =
      DECODE( A_SO_AUTHORIZATION_FLAG,
              1, msii_master_temp.SO_AUTHORIZATION_FLAG,
              MSII.SO_AUTHORIZATION_FLAG ),

      MSII.CONSIGNED_FLAG =
      DECODE( A_CONSIGNED_FLAG,
              1, msii_master_temp.CONSIGNED_FLAG,
              MSII.CONSIGNED_FLAG ),

      MSII.ASN_AUTOEXPIRE_FLAG =
      DECODE( A_ASN_AUTOEXPIRE_FLAG,
              1, msii_master_temp.ASN_AUTOEXPIRE_FLAG,
              MSII.ASN_AUTOEXPIRE_FLAG ),

      MSII.VMI_FORECAST_TYPE =
      DECODE( A_VMI_FORECAST_TYPE,
              1, msii_master_temp.VMI_FORECAST_TYPE,
              MSII.VMI_FORECAST_TYPE ),

      MSII.FORECAST_HORIZON =
      DECODE( A_FORECAST_HORIZON,
              1, msii_master_temp.FORECAST_HORIZON,
              MSII.FORECAST_HORIZON ),

      MSII.EXCLUDE_FROM_BUDGET_FLAG =
      DECODE( A_EXCLUDE_FROM_BUDGET_FLAG,
              1, msii_master_temp.EXCLUDE_FROM_BUDGET_FLAG,
              MSII.EXCLUDE_FROM_BUDGET_FLAG ),

      MSII.DAYS_TGT_INV_SUPPLY =
      DECODE( A_DAYS_TGT_INV_SUPPLY,
              1, msii_master_temp.DAYS_TGT_INV_SUPPLY,
              MSII.DAYS_TGT_INV_SUPPLY ),

      MSII.DAYS_TGT_INV_WINDOW =
      DECODE( A_DAYS_TGT_INV_WINDOW,
              1, msii_master_temp.DAYS_TGT_INV_WINDOW,
              MSII.DAYS_TGT_INV_WINDOW ),

      MSII.DAYS_MAX_INV_SUPPLY =
      DECODE( A_DAYS_MAX_INV_SUPPLY,
              1, msii_master_temp.DAYS_MAX_INV_SUPPLY,
              MSII.DAYS_MAX_INV_SUPPLY ),

      MSII.DAYS_MAX_INV_WINDOW =
      DECODE( A_DAYS_MAX_INV_WINDOW,
              1, msii_master_temp.DAYS_MAX_INV_WINDOW,
              MSII.DAYS_MAX_INV_WINDOW ),

      MSII.DRP_PLANNED_FLAG =
      DECODE( A_DRP_PLANNED_FLAG,
              1, msii_master_temp.DRP_PLANNED_FLAG,
              MSII.DRP_PLANNED_FLAG ),

      MSII.CRITICAL_COMPONENT_FLAG =
      DECODE( A_CRITICAL_COMPONENT_FLAG,
              1, msii_master_temp.CRITICAL_COMPONENT_FLAG,
              MSII.CRITICAL_COMPONENT_FLAG ),

      MSII.CONTINOUS_TRANSFER =
      DECODE( A_CONTINOUS_TRANSFER,
              1, msii_master_temp.CONTINOUS_TRANSFER,
              MSII.CONTINOUS_TRANSFER ),

      MSII.CONVERGENCE =
      DECODE( A_CONVERGENCE,
              1, msii_master_temp.CONVERGENCE,
              MSII.CONVERGENCE ),

      MSII.DIVERGENCE =
      DECODE( A_DIVERGENCE,
              1, msii_master_temp.DIVERGENCE,
              MSII.DIVERGENCE ),
/* Start Bug 3713912 */
      MSII.LOT_DIVISIBLE_FLAG                =
      DECODE( A_LOT_DIVISIBLE_FLAG,
              1, msii_master_temp.LOT_DIVISIBLE_FLAG,
              MSII.LOT_DIVISIBLE_FLAG ),


      MSII.GRADE_CONTROL_FLAG                =
      DECODE( A_GRADE_CONTROL_FLAG,
              1, msii_master_temp.GRADE_CONTROL_FLAG,
              MSII.GRADE_CONTROL_FLAG    ),

      MSII.DEFAULT_GRADE                     =
      DECODE( A_DEFAULT_GRADE,
              1, msii_master_temp.DEFAULT_GRADE,
              MSII.DEFAULT_GRADE ),

      MSII.CHILD_LOT_FLAG                    =
      DECODE( A_CHILD_LOT_FLAG,
              1, msii_master_temp.CHILD_LOT_FLAG,
              MSII.CHILD_LOT_FLAG ),

      MSII.PARENT_CHILD_GENERATION_FLAG    =
      DECODE( A_PARENT_CHILD_GENERATION_FLAG,
              1, msii_master_temp.PARENT_CHILD_GENERATION_FLAG,
              MSII.PARENT_CHILD_GENERATION_FLAG ),

      MSII.CHILD_LOT_PREFIX                  =
      DECODE( A_CHILD_LOT_PREFIX,
              1, msii_master_temp.CHILD_LOT_PREFIX,
              MSII.CHILD_LOT_PREFIX ),

      MSII.CHILD_LOT_STARTING_NUMBER         =
      DECODE( A_CHILD_LOT_STARTING_NUMBER,
              1, msii_master_temp.CHILD_LOT_STARTING_NUMBER,
              MSII.CHILD_LOT_STARTING_NUMBER  ),

      MSII.CHILD_LOT_VALIDATION_FLAG         =
      DECODE( A_CHILD_LOT_VALIDATION_FLAG,
              1, msii_master_temp.CHILD_LOT_VALIDATION_FLAG,
              MSII.CHILD_LOT_VALIDATION_FLAG ),

      MSII.COPY_LOT_ATTRIBUTE_FLAG           =
      DECODE( A_COPY_LOT_ATTRIBUTE_FLAG,
              1, msii_master_temp.COPY_LOT_ATTRIBUTE_FLAG,
              MSII.COPY_LOT_ATTRIBUTE_FLAG ),

      MSII.RECIPE_ENABLED_FLAG       =
      DECODE( A_RECIPE_ENABLED_FLAG,
              1, msii_master_temp.RECIPE_ENABLED_FLAG,
              MSII.RECIPE_ENABLED_FLAG ),

      MSII.PROCESS_QUALITY_ENABLED_FLAG    =
      DECODE( A_PROCESS_QUALITY_ENABLED_FLAG,
              1, msii_master_temp.PROCESS_QUALITY_ENABLED_FLAG,
              MSII.PROCESS_QUALITY_ENABLED_FLAG ),

      MSII.PROCESS_EXECUTION_ENABLED_FLAG  =
      DECODE( A_PROCESS_EXEC_ENABLED_FLAG,
              1, msii_master_temp.PROCESS_EXECUTION_ENABLED_FLAG,
              MSII.PROCESS_EXECUTION_ENABLED_FLAG ),

      MSII.PROCESS_COSTING_ENABLED_FLAG    =
      DECODE( A_PROCESS_COSTING_ENABLED_FLAG,
              1, msii_master_temp.PROCESS_COSTING_ENABLED_FLAG,
              MSII.PROCESS_COSTING_ENABLED_FLAG ),

      MSII.HAZARDOUS_MATERIAL_FLAG           =
      DECODE( A_HAZARDOUS_MATERIAL_FLAG,
              1, msii_master_temp.HAZARDOUS_MATERIAL_FLAG,
              MSII.HAZARDOUS_MATERIAL_FLAG ),

      MSII.CAS_NUMBER                        =
      DECODE( A_CAS_NUMBER,
              1, msii_master_temp.CAS_NUMBER,
              MSII.CAS_NUMBER ),

      MSII.RETEST_INTERVAL                   =
      DECODE( A_RETEST_INTERVAL,
              1, msii_master_temp.RETEST_INTERVAL,
              MSII.RETEST_INTERVAL ),

      MSII.EXPIRATION_ACTION_INTERVAL        =
      DECODE( A_EXPIRATION_ACTION_INTERVAL,
              1, msii_master_temp.EXPIRATION_ACTION_INTERVAL,
              MSII.EXPIRATION_ACTION_INTERVAL ),

      MSII.EXPIRATION_ACTION_CODE            =
      DECODE( A_EXPIRATION_ACTION_CODE,
              1, msii_master_temp.EXPIRATION_ACTION_CODE,
              MSII.EXPIRATION_ACTION_CODE ),

      MSII.MATURITY_DAYS                     =
      DECODE( A_MATURITY_DAYS,
              1, msii_master_temp.MATURITY_DAYS,
              MSII.MATURITY_DAYS ),

      MSII.HOLD_DAYS                         =
      DECODE( A_HOLD_DAYS,
              1, msii_master_temp.HOLD_DAYS,
              MSII.HOLD_DAYS ),
/* End Bug 3713912 */
      --R12 Enhancement
      MSII.CHARGE_PERIODICITY_CODE           =   DECODE( A_CHARGE_PERIODICITY_CODE,1, msii_master_temp.CHARGE_PERIODICITY_CODE,MSII.CHARGE_PERIODICITY_CODE ),
      MSII.REPAIR_LEADTIME                   =   DECODE( A_REPAIR_LEADTIME,1, msii_master_temp.REPAIR_LEADTIME,MSII.REPAIR_LEADTIME),
      MSII.REPAIR_YIELD                      =   DECODE( A_REPAIR_YIELD,1, msii_master_temp.REPAIR_YIELD,MSII.REPAIR_YIELD),
      MSII.PREPOSITION_POINT                 =   DECODE( A_PREPOSITION_POINT, 1, msii_master_temp.PREPOSITION_POINT, MSII.PREPOSITION_POINT),
      MSII.REPAIR_PROGRAM                    =   DECODE( A_REPAIR_PROGRAM,1, msii_master_temp.REPAIR_PROGRAM,MSII.REPAIR_PROGRAM),
      MSII.SUBCONTRACTING_COMPONENT          =   DECODE( A_SUBCONTRACTING_COMPONENT,1, msii_master_temp.SUBCONTRACTING_COMPONENT,MSII.SUBCONTRACTING_COMPONENT ),
      MSII.OUTSOURCED_ASSEMBLY               =   DECODE( A_OUTSOURCED_ASSEMBLY,1, msii_master_temp.OUTSOURCED_ASSEMBLY,MSII.OUTSOURCED_ASSEMBLY),
      MSII.ITEM_CATALOG_GROUP_ID             =   msii_master_temp.ITEM_CATALOG_GROUP_ID,--Bug: 3074458
      --3637854 Should carry masters' lifecycle.
      MSII.LIFECYCLE_ID                      =   msii_master_temp.LIFECYCLE_ID,
      --******************* -- For bug 7589826 based on 7587702
      -- MSII.CURRENT_PHASE_ID                  =   DECODE(MSII.LIFECYCLE_ID,msii_master_temp.LIFECYCLE_ID,MSII.CURRENT_PHASE_ID,msii_master_temp.CURRENT_PHASE_ID),
      --commented out for 7589826 based on 7587702
      MSII.CURRENT_PHASE_ID                  =  DECODE( A_INVENTORY_ITEM_STATUS_CODE,2,MSII.CURRENT_PHASE_ID,msii_master_temp.CURRENT_PHASE_ID),
      --added for bug 7589826 based on 7587702. If item status is org controlled, so is Phase.
      --******************* -- For bug 7589826 based on 7587702
      MSII.PROCESS_FLAG                      =   l_process_flag_2,
      MSII.GDSN_OUTBOUND_ENABLED_FLAG        =   msii_master_temp.GDSN_OUTBOUND_ENABLED_FLAG,
      MSII.TRADE_ITEM_DESCRIPTOR             =   msii_master_temp.TRADE_ITEM_DESCRIPTOR

   WHERE  MSII.inventory_item_id = inv_item_id
      AND MSII.organization_id = org_id
      AND MSII.set_process_id = xset_id + 1000000000000;

   /* commit for debugging ONLY */
   -- commit;

   RETURN (0);

EXCEPTION

   when NO_DATA_FOUND then
      -- No master controlled attributes
      return (0);

   when OTHERS then
      --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
                  Substr(
                'when OTHERS exception raised in copy_master_to_child ' ||
             SQLCODE ||
             ' - '   ||
             SQLERRM,1,240));
      END IF;
      return (1);

END copy_master_to_child; -- }


FUNCTION validate_item_update_child
(
        org_id          NUMBER,
        all_org         NUMBER          := 2,
        prog_appid      NUMBER          := -1,
        prog_id         NUMBER          := -1,
        request_id      NUMBER          := -1,
        user_id         NUMBER          := -1,
        login_id        NUMBER          := -1,
        err_text IN OUT NOCOPY VARCHAR2,
        xset_id  IN     NUMBER          DEFAULT NULL
)
RETURN INTEGER
IS
   CURSOR C_msii_child_records is
        select
        ROWID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        TRANSACTION_ID
        from MTL_SYSTEM_ITEMS_INTERFACE
        where process_flag = 4
        and set_process_id = xset_id
        and ((organization_id = org_id) or (all_org = 1))
        and organization_id in
        (select organization_id
        from MTL_PARAMETERS MP
        where MP.organization_id <> MP.master_organization_id);

        ret_code_update         NUMBER          := 1;

    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN -- {

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside validate_item_update_child'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;

        for crec in C_msii_child_records loop -- {
                -- child record validation here
                ret_code_update := INVUPD2B.update_validations(
                                                crec.ROWID,
                                                crec.ORGANIZATION_ID,
                                                crec.TRANSACTION_ID,
                                                user_id,
                                                login_id,
                                                prog_appid,
                                                prog_id,
                                                request_id);

        end loop; -- }  -- msii loop

   return (0);

EXCEPTION

   when NO_DATA_FOUND then
      return (0);

   -- No child record updates found
   when OTHERS then
      --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
             Substr(
                'when OTHERS exception raised in validate_item_update_child ' ||
             SQLCODE ||
             ' - '   ||
             SQLERRM,1,240));
      END IF;
      return (1);

END validate_item_update_child;


FUNCTION update_validations
(
   row_id               ROWID,
   org_id               NUMBER,
   trans_id     NUMBER,
   user_id         NUMBER          := -1,
   login_id        NUMBER          := -1,
   prog_appid      NUMBER          := -1,
   prog_id         NUMBER          := -1,
   request_id      NUMBER          := -1
)
RETURN INTEGER
IS
   msii_temp            mtl_system_items_interface%ROWTYPE;
   msi_temp             mtl_system_items_b%ROWTYPE;

   dumm_status          NUMBER;
   status               NUMBER;

   onhand_lot NUMBER;
   onhand_serial NUMBER;
   onhand_shelf NUMBER;
   onhand_rev NUMBER;
   onhand_loc NUMBER;
   onhand_all  NUMBER;
   onhand_trackable  NUMBER;
   wip_repetitive_item  NUMBER;
   rsv_exists NUMBER;
   so_rsv NUMBER;
   so_ship NUMBER;
   so_txn NUMBER;
   demand_exists NUMBER;
   uom_conv NUMBER;
   comp_atp NUMBER;
   bom_exists NUMBER;
   cost_txn NUMBER;
   bom_item NUMBER;
   mrp_schedule NUMBER;
   null_elem_exists NUMBER;
   so_open_exists NUMBER;
   fte_vehicle_exists NUMBER;
   pendadj_lot NUMBER;
   pendadj_loc NUMBER;
   pendadj_rev NUMBER;
   so_ato NUMBER;
   morgid NUMBER;
   err_text VARCHAR2(250);
   vmiorconsign_enabled  NUMBER;
   consign_enabled       NUMBER;
   process_enabled       NUMBER;

   /* Start Bug 3713912 */
   onhand_tracking_qty_ind            NUMBER;
   pendadj_tracking_qty_ind           NUMBER;
   onhand_primary_uom                 NUMBER;
   pendadj_primary_uom                NUMBER;
   onhand_secondary_uom               NUMBER;
   pendadj_secondary_uom              NUMBER;
   onhand_sec_default_ind             NUMBER;
   pendadj_sec_default_ind            NUMBER;
   onhand_deviation_high              NUMBER;
   pendadj_deviation_high             NUMBER;
   onhand_deviation_low               NUMBER;
   pendadj_deviation_low              NUMBER;
   onhand_child_lot         NUMBER;
   pendadj_child_lot        NUMBER;
   onhand_lot_divisible         NUMBER;
   pendadj_lot_divisible        NUMBER;
   onhand_grade             NUMBER;
   pendadj_grade            NUMBER;
   /* End Bug 3713912 */
   l_column_name         VARCHAR2(1000);
/* Bug: 4569555 Commenting out ib_rtn_status and ib_rtn_msg
   -- For bug 3580698
   ib_rtn_status        VARCHAR2(1);
   ib_rtn_msg           VARCHAR2(2000);
   -- For bug 3580698
   End Bug: 4569555   */
   intr_ship_lot      NUMBER;  -- Bug 4387538
   intr_ship_serial  NUMBER;  -- Bug 4387538
   revision_control  NUMBER;   -- Bug 6501149
   stockable         NUMBER;   -- Bug 6501149
   lot_control       NUMBER;   -- Bug 6501149
   serial_control    NUMBER;   -- Bug 6501149
   open_shipment_lot     NUMBER;   -- Bug 9043779
   open_shipment_serial  NUMBER;   -- Bug 9043779

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
   l_item_has_lot_comp  NUMBER;
BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside update_validations'|| '***orgid: ' || TO_CHAR(org_id));
   END IF;
   -- initialize status = 0
   status := 0;

   -- msii (updated to)
   select *
     into msii_temp
     from MTL_SYSTEM_ITEMS_INTERFACE MSII
    where MSII.rowid = row_id;

   -- msi (updated from)
   select *
     into msi_temp
     from MTL_SYSTEM_ITEMS_B MSI
     where MSI.organization_id = msii_temp.organization_id
      and msi.inventory_item_id = msii_temp.inventory_item_id ;

        select master_organization_id
        into morgid
        from MTL_PARAMETERS
        where organization_id = msii_temp.organization_id;

   -- Start : 6531911
    IF msi_temp.lot_control_code <> msii_temp.lot_control_code THEN
       onhand_lot := 0;
    ELSE
       onhand_lot := NULL;
    END IF;

    IF msi_temp.lot_control_code <> msii_temp.lot_control_code THEN
       onhand_lot    := 0;
       intr_ship_lot := 0;
    ELSE
       onhand_lot    := NULL;
       intr_ship_lot := NULL;
    END IF;


    IF msi_temp.child_lot_flag <> msii_temp.child_lot_flag THEN
       onhand_child_lot  := 0;
       pendadj_child_lot := 0;
    ELSE
       onhand_child_lot  := NULL;
       pendadj_child_lot := NULL;
    END IF;


    IF msi_temp.grade_control_flag <> msii_temp.grade_control_flag THEN
       onhand_grade  := 0;
       pendadj_grade := 0;
    ELSE
       onhand_grade  := NULL;
       pendadj_grade := NULL;
    END IF;

    IF msi_temp.lot_divisible_flag <> msii_temp.lot_divisible_flag THEN
       onhand_lot_divisible  := 0;
       pendadj_lot_divisible :=0;
    ELSE
       onhand_lot_divisible  := NULL;
       pendadj_lot_divisible := NULL;
    END IF;

    IF  (msi_temp.SHELF_LIFE_CODE <> msii_temp.SHELF_LIFE_CODE)
    AND ((msi_temp.SHELF_LIFE_CODE  = 1) OR (msii_temp.SHELF_LIFE_CODE = 1))
    THEN
       onhand_shelf := 0;
    ELSE
       onhand_shelf := NULL;
    END IF;

    IF msi_temp.LOCATION_CONTROL_CODE <> msii_temp.LOCATION_CONTROL_CODE THEN
      onhand_loc  := 0;
      pendadj_loc := 0;
    ELSE
      onhand_loc  := NULL;
      pendadj_loc := NULL;
    END IF;

    IF ((msi_temp.reservable_type = 1) and (msii_temp.reservable_type <> 1))
    OR ((msi_temp.reservable_type = 2) and (msii_temp.reservable_type = 1))
    THEN
        rsv_exists := 0;
    ELSE
        rsv_exists := NULL;
    END IF;

    IF msi_temp.SHIPPABLE_ITEM_FLAG <> msii_temp.SHIPPABLE_ITEM_FLAG THEN
       so_ship := 0;
    ELSE
       so_ship := NULL;
    END IF;

    IF msi_temp.REPLENISH_TO_ORDER_FLAG <> msii_temp.REPLENISH_TO_ORDER_FLAG THEN
       so_ato := 0;
    ELSE
       so_ato := NULL;
    END IF;

    IF msi_temp.REVISION_QTY_CONTROL_CODE <> msii_temp.REVISION_QTY_CONTROL_CODE THEN
       onhand_rev  := 0;
       pendadj_rev := 0;
    ELSE
       onhand_rev  := NULL;
       pendadj_rev := NULL;
    END IF;

    IF ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5))
    OR (msi_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6)))
    THEN
       onhand_serial    := 0;
       intr_ship_serial := 0;
    ELSE
       onhand_serial := NULL;
       intr_ship_serial := NULL;
    END IF;

-- bug# 8824605 Begin
    IF msii_temp.bom_item_type = 5 THEN
       bom_exists     := 0;
       so_open_exists := 0;
    ELSE
       bom_exists      := NULL;
       so_open_exists  := NULL;
    END IF;

    IF msi_temp.bom_item_type <> msii_temp.bom_item_type
    OR msi_temp.effectivity_control <> msii_temp.effectivity_control
    THEN
       bom_item := 0;
       bom_exists := 0;
    ELSE
       bom_item := NULL;
    END IF;
-- bug# 8824605 End

/** -- Comment out for bug# 8824605
    IF msi_temp.bom_item_type <> msii_temp.bom_item_type
    OR msi_temp.effectivity_control <> msii_temp.effectivity_control
    THEN
       bom_item := 0;
    ELSE
       bom_item := NULL;
    END IF;

    IF msii_temp.bom_item_type = 5 THEN
       bom_exists     := 0;
       so_open_exists := 0;
    ELSE
       bom_exists      := NULL;
       so_open_exists  := NULL;
    END IF;
**/

    IF msi_temp.costing_enabled_flag <> msii_temp.costing_enabled_flag
    OR msi_temp.inventory_asset_flag <> msii_temp.inventory_asset_flag
    THEN
       cost_txn := 0;
    ELSE
       cost_txn := NULL;
    END IF;

    IF msi_temp.effectivity_control <> msii_temp.effectivity_control THEN
       onhand_all := 0;
    ELSE
       onhand_all := NULL;
    END IF;

    IF msii_temp.vehicle_item_flag <> 'Y' THEN
      fte_vehicle_exists := 0;
    ELSE
      fte_vehicle_exists := NULL;
    END IF;

    IF NVL(msii_temp.COMMS_NL_TRACKABLE_FLAG,'N') <> NVL(msi_temp.COMMS_NL_TRACKABLE_FLAG,'N') THEN
       onhand_trackable := 0;
    ELSE
       onhand_trackable := NULL;
    END IF;
    vmiorconsign_enabled := 0;
    IF msi_temp.TRACKING_QUANTITY_IND <> msii_temp.TRACKING_QUANTITY_IND THEN
       onhand_tracking_qty_ind  := 0;
       pendadj_tracking_qty_ind := 0;
    ELSE
       onhand_tracking_qty_ind  := NULL;
       pendadj_tracking_qty_ind := NULL;
    END IF;

    IF msi_temp.SECONDARY_UOM_CODE <> msii_temp.SECONDARY_UOM_CODE THEN
       onhand_secondary_uom    := 0;
       pendadj_secondary_uom   := 0;
    ELSE
       onhand_secondary_uom    := NULL;
       pendadj_secondary_uom   := NULL;
    END IF;

    IF msi_temp.SECONDARY_DEFAULT_IND <> msii_temp.SECONDARY_DEFAULT_IND THEN
       onhand_sec_default_ind  := 0;
       pendadj_sec_default_ind := 0;
    ELSE
       onhand_sec_default_ind  := NULL;
       pendadj_sec_default_ind := NULL;
    END IF;

    IF msi_temp.PRIMARY_UOM_CODE <> msii_temp.PRIMARY_UOM_CODE THEN
       onhand_primary_uom  := 0;
       pendadj_primary_uom := 0;
    ELSE
       onhand_primary_uom  := NULL;
       pendadj_primary_uom := NULL;
    END IF;

    IF msi_temp.DUAL_UOM_DEVIATION_HIGH <> msii_temp.DUAL_UOM_DEVIATION_HIGH THEN
       onhand_deviation_high  :=0;
       pendadj_deviation_high :=0;
    ELSE
       onhand_deviation_high  :=NULL;
       pendadj_deviation_high :=NULL;
    END IF;

    IF msi_temp.DUAL_UOM_DEVIATION_LOW <> msii_temp.DUAL_UOM_DEVIATION_LOW THEN
       onhand_deviation_low  := 0;
       pendadj_deviation_low := 0;
    ELSE
       onhand_deviation_low  := NULL;
       pendadj_deviation_low := NULL;
    END IF;
   -- END   : 6531911

   -- bug 9043779
   IF (msi_temp.lot_control_code <> msii_temp.lot_control_code
      or msi_temp.serial_number_control_code <> msii_temp.serial_number_control_code) THEN
       open_shipment_lot    := 0;
       open_shipment_serial := 0;
   else
       open_shipment_lot    := NULL;
       open_shipment_serial := NULL;
   END IF;
   -- end, bug 9043779

   INVIDIT3.Table_Queries(
        p_org_id                     => msii_temp.organization_id,
        p_item_id                    => msii_temp.inventory_item_id,
        p_master_org                 => morgid,
        p_primary_uom_code           => msii_temp.primary_uom_code,
        p_catalog_group_id           => msii_temp.item_catalog_group_id,
        p_calling_routine            => 'IOI',
        X_onhand_lot                 => onhand_lot,
        X_onhand_serial              => onhand_serial,
        X_onhand_shelf               => onhand_shelf,
        X_onhand_rev                 => onhand_rev,
        X_onhand_loc                 => onhand_loc,
        X_onhand_all                 => onhand_all,
        X_onhand_trackable           => onhand_trackable,
        X_wip_repetitive_item        => wip_repetitive_item,
        X_rsv_exists                 => rsv_exists,
        X_so_rsv                     => so_rsv,
        X_so_ship                    => so_ship,
        X_so_txn                     => so_txn,
        X_demand_exists              => demand_exists,
        X_uom_conv                   => uom_conv,
        X_comp_atp                   => comp_atp,
        X_bom_exists                 => bom_exists,
        X_cost_txn                   => cost_txn,
        X_bom_item                   => bom_item,
        X_mrp_schedule               => mrp_schedule,
        X_null_elem_exists           => null_elem_exists,
        X_so_open_exists             => so_open_exists,
        X_fte_vechicle_exists        => fte_vehicle_exists,    --Bug:2691174
        X_pendadj_lot                => pendadj_lot ,           -- Bug 3058650
        X_pendadj_rev                => pendadj_rev,           -- Bug 3058650
        X_pendadj_loc                => pendadj_loc,           -- Bug 3058650
        X_so_ato                     => so_ato,           -- Bug 3058650
        X_vmiorconsign_enabled       => vmiorconsign_enabled,
        X_consign_enabled            => consign_enabled,
        X_process_enabled            => process_enabled,
        X_onhand_tracking_qty_ind    => onhand_tracking_qty_ind,
        X_pendadj_tracking_qty_ind   => pendadj_tracking_qty_ind,
        X_onhand_primary_uom         => onhand_primary_uom,
        X_pendadj_primary_uom        => pendadj_primary_uom,
        X_onhand_secondary_uom       => onhand_secondary_uom,
        X_pendadj_secondary_uom      => pendadj_secondary_uom,
        X_onhand_sec_default_ind     => onhand_sec_default_ind,
        X_pendadj_sec_default_ind    => pendadj_sec_default_ind,
        X_onhand_deviation_high      => onhand_deviation_high,
        X_pendadj_deviation_high     => pendadj_deviation_high,
        X_onhand_deviation_low       => onhand_deviation_low,
        X_pendadj_deviation_low      => pendadj_deviation_low,
        X_onhand_child_lot           => onhand_child_lot,
        X_pendadj_child_lot          => pendadj_child_lot,
        X_onhand_lot_divisible       => onhand_lot_divisible,
        X_pendadj_lot_divisible      => pendadj_lot_divisible,
        X_onhand_grade               => onhand_grade,
        X_pendadj_grade              => pendadj_grade,
        X_intr_ship_lot              => intr_ship_lot,
        X_intr_ship_serial           => intr_ship_serial,
        X_revision_control           => revision_control,  -- Bug 6501149
        X_stockable                  => stockable,         -- Bug 6501149
        X_lot_control                => lot_control,       -- Bug 6501149
        X_serial_control             => serial_control,    -- Bug 6501149
        X_open_shipment_lot          => open_shipment_lot,   -- Bug 9043779
        X_open_shipment_serial       => open_shipment_serial -- Bug 9043779
        );

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside update_validations: After Table Quries');
   END IF;
   -- validate LOT_CONTROL_CODE
   -- cannot update if there is onhand or transactions pending or lots exist
   if (msi_temp.lot_control_code <> msii_temp.lot_control_code) AND (onhand_lot = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOT_CONTROL_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOT_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

/* Bug 3058650 : Validation added as part of Item attribute checks ER */
   elsif (msi_temp.lot_control_code <> msii_temp.lot_control_code) AND (pendadj_lot = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOT_CONTROL_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

/* End Bug 3058650 */
   elsif (msi_temp.lot_control_code <> msii_temp.lot_control_code) AND (intr_ship_lot = 1) then -- Bug 4387538
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOT_CONTROL_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_INTRANSIT_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
     /*Bug 6501149 Added code */
   elsif (msi_temp.lot_control_code <> msii_temp.lot_control_code) AND (lot_control = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                      org_id,
                                                      user_id,
                                                      login_id,
                                                      prog_appid,
                                                      prog_id,
                                                      request_id,
                                                      trans_id,
                                                      err_text,
                                                      'LOT_CONTROL_CODE',
                                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                                      'INV_DELIVER_CANNOT_UPDATE',
                                                      err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
     /* Bug 6501149 Code ended */
   end if;
   -- Bug 9043779
   if (msi_temp.lot_control_code <> msii_temp.lot_control_code) and (open_shipment_lot = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                      org_id,
                                                      user_id,
                                                      login_id,
                                                      prog_appid,
                                                      prog_id,
                                                      request_id,
                                                      trans_id,
                                                      err_text,
                                                      'LOT_CONTROL_CODE',
                                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                                      'INV_RECORG_SHIPSUPP_RO_LOT',
                                                      err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
   if (msi_temp.serial_number_control_code <> msii_temp.serial_number_control_code) and (open_shipment_serial = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                      org_id,
                                                      user_id,
                                                      login_id,
                                                      prog_appid,
                                                      prog_id,
                                                      request_id,
                                                      trans_id,
                                                      err_text,
                                                      'SERIAL_NUMBER_CONTROL_CODE',
                                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                                      'INV_RECORG_SHIPSUPP_RO_SERL',
                                                      err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
    end if;
    -- end, bug 9043779

   /* Start Bug 3713912 */
   -- validate CHILD_LOT_FLAG
   -- cannot update if there is onhand or transactions pending or lots exist
   if (msi_temp.child_lot_flag <> msii_temp.child_lot_flag) AND (onhand_child_lot = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'CHILD_LOT_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOT_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.child_lot_flag <> msii_temp.child_lot_flag) AND (pendadj_child_lot = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'CHILD_LOT_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate GRADE_CONTROL_FLAG
   -- cannot update if there is onhand or transactions pending or lots exist
   if (msi_temp.grade_control_flag <> msii_temp.grade_control_flag) AND (onhand_grade = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'GRADE_CONTROL_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOT_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.grade_control_flag <> msii_temp.grade_control_flag) AND (pendadj_grade = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'GRADE_CONTROL_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate LOT_DIVISIBLE_FLAG
   -- cannot update if there is onhand or transactions pending or lots exist
   if (msi_temp.lot_divisible_flag <> msii_temp.lot_divisible_flag) AND (onhand_lot_divisible = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOT_DIVISIBLE_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOT_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.lot_divisible_flag <> msii_temp.lot_divisible_flag) AND (pendadj_lot_divisible = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOT_DIVISIBLE_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate SHELF_LIFE_CODE
   -- cannot update if there is onhand or transactions pending or lots exist
   -- cannot change from 1 (no control) if qty onhand or txns pending
   -- cannot change from 2, 4 to 1 if qty onhand or txns pending
   -- ok to change between 2 and 4
   if     (msi_temp.SHELF_LIFE_CODE <> msii_temp.SHELF_LIFE_CODE)
      AND (    (msi_temp.SHELF_LIFE_CODE  = 1)
            OR (msii_temp.SHELF_LIFE_CODE = 1)
          )
      AND (onhand_shelf = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SHELF_LIFE_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOT_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   /* End Bug 3713912 */

/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   -- validate LOCATOR_CONTROL_CODE
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.LOCATION_CONTROL_CODE <> msii_temp.LOCATION_CONTROL_CODE) AND (onhand_loc = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOCATION_CONTROL_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_LOC_CONTROL_CODE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.LOCATION_CONTROL_CODE <> msii_temp.LOCATION_CONTROL_CODE) AND (pendadj_loc = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'LOCATION_CONTROL_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

/* End Bug 3058650 */

   end if;

   -- validate RESERVABLE_TYPE
   -- cannot update from 1 (reservable) if rows exist in mtl_demand

   if (msi_temp.reservable_type = 1) and (msii_temp.reservable_type <> 1) and (rsv_exists = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'RESERVABLE_TYPE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_RESERVABLE_TYPE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   if (msi_temp.reservable_type = 2) and (msii_temp.reservable_type = 1) and (rsv_exists <> 1) then

      if (INV_ATTRIBUTE_CONTROL_PVT.reservable_check(msii_temp.organization_id,
                                  msii_temp.inventory_item_id)) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'RESERVABLE_TYPE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_RESERVABLE_NO_YES',
                                                     err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
   end if;


/* End Bug 3058650 */

/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   -- validate TRANSACTIONS_ENABLED_FLAG
   -- cannot update if there are Open sales order lines

   if (msi_temp.mtl_transactions_enabled_flag = 'Y') and (msii_temp.mtl_transactions_enabled_flag = 'N')  then

      if (INV_ATTRIBUTE_CONTROL_PVT.transactable_uncheck(msii_temp.organization_id, msii_temp.inventory_item_id)) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'TRANSACTIONS_ENABLED_FLAG',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_TRANSACTABLE_YES_NO',
                                                     err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   end if;
/* End Bug 3058650 */

/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   -- validate SHIPPABLE_ITEM_FLAG
   -- cannot update if there are Open sales order lines

   if (msi_temp.SHIPPABLE_ITEM_FLAG <> msii_temp.SHIPPABLE_ITEM_FLAG) and
      (so_ship = 1)  then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'SHIPPABLE_ITEM_FLAG',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_OPEN_SO',
                                             err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
  elsif (msi_temp.SHIPPABLE_ITEM_FLAG = 'N' ) and (msii_temp.SHIPPABLE_ITEM_FLAG = 'Y') then
      if (INV_ATTRIBUTE_CONTROL_PVT.shippable_check(msii_temp.organization_id,
                                  msii_temp.inventory_item_id)) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'SHIPPABLE_ITEM_FLAG',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_TRANSACTABLE_NO_YES',
                                                     err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
      end if;
  end if;

/* End Bug 3058650 */

/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   -- validate REPLENISH_TO_ORDER_FLAG
   -- cannot update if there are Open sales order lines

   if (msi_temp.REPLENISH_TO_ORDER_FLAG <> msii_temp.REPLENISH_TO_ORDER_FLAG) and (so_ato = 1)  then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'REPLENISH_TO_ORDER_FLAG',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_ATO_YES_NO',
                                             err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

/* End Bug 3058650 */

   -- validate REVISION_QTY_CONTROL_CODE
   -- cannot update if there is onhand or transactions pending

   if (msi_temp.REVISION_QTY_CONTROL_CODE <> msii_temp.REVISION_QTY_CONTROL_CODE) AND (onhand_rev = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'REVISION_QTY_CONTROL_CODE',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_REV_QTY_CNTRL_CODE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
 /*Bug 6501149 Code starts */
   elsif (msi_temp.REVISION_QTY_CONTROL_CODE <> msii_temp.REVISION_QTY_CONTROL_CODE) AND (revision_control = 1) then
         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                        org_id,
                                                        user_id,
                                                        login_id,
                                                        prog_appid,
                                                        prog_id,
                                                        request_id,
                                                        trans_id,
                                                        err_text,
                                                'REVISION_QTY_CONTROL_CODE',
                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                'INV_DELIVER_CANNOT_UPDATE',
                                                        err_text);
    dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   /*Bug 6501149 Code ends */

/* Bug 3058650 : Validation added as part of Item attribute checks ER */
   elsif (msi_temp.REVISION_QTY_CONTROL_CODE <> msii_temp.REVISION_QTY_CONTROL_CODE) AND (pendadj_rev = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'REVISION_QTY_CONTROL_CODE',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
/* End Bug 3058650 */
   end if;


/* Bug 3058650 : Validation added as part of Item attribute checks ER */

   -- validate SERIAL_NUMBER_CONTROL_CODE
   -- cannot change from 1,6 to 2,5  if there is On hand
   -- Cannot change from 1 to 2,5,6 if there are Sales order lines
   -- or when there are open internal order or interorg intransit shipments - Bug 4387538
   if ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6) and
      msii_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5)) and
      (onhand_serial = 1))or
      ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6)) and
      (onhand_serial = 1))  then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'SERIAL_NUMBER_CONTROL_CODE',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_QTY_ON_HAND',
                                             err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   elsif (msi_temp.SERIAL_NUMBER_CONTROL_CODE  = 1 and
      msii_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5,6))then

      if (INV_ATTRIBUTE_CONTROL_PVT.serial_check(msii_temp.organization_id,
                                  msii_temp.inventory_item_id)) then
         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                             'SERIAL_NUMBER_CONTROL_CODE',
                                             'MTL_SYSTEM_ITEMS_INTERFACE',
                                             'INV_SERIAL_NO_YES',
                                                     err_text);
         dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
      end if;
/* End Bug 3058650 */

/* Start Bug 4387538 */
   elsif ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5)) and
          (intr_ship_serial = 1)) or
         ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6)) and
          (intr_ship_serial = 1))  then

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                             org_id,
                             user_id,
                             login_id,
                             prog_appid,
                             prog_id,
                             request_id,
                             trans_id,
                             err_text,
                         'SERIAL_NUMBER_CONTROL_CODE',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INTRANSIT_CANNOT_UPDATE',
                         err_text);

         dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   /* Bug 6501149 Code start */
       elsif ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5)) and
         (serial_control = 1)) or
         ((msi_temp.SERIAL_NUMBER_CONTROL_CODE in (2,5) and msii_temp.SERIAL_NUMBER_CONTROL_CODE in (1,6)) and
         (serial_control = 1))  then

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                        org_id,
                                                        user_id,
                                                        login_id,
                                                        prog_appid,
                                                        prog_id,
                                                        request_id,
                                                        trans_id,
                                                        err_text,
                                                'SERIAL_NUMBER_CONTROL_CODE',
                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                'INV_DELIVER_CANNOT_UPDATE',
                                                err_text);
         dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
     /* Bug 6501149 Code ended */
   end if;
/* End Bug 4387538 */

   -- validate BOM_ENABLED_FLAG
   -- Must =Y when bom_item_type = 5

   if (msii_temp.bom_item_type = 5) and
     (msii_temp.bom_enabled_flag = 'N') then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BOM_ENABLED_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_BOM_ENABLED_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   -- validate BOM_ITEM_TYPE (1)
   -- Not updateable when row exists in bom_substitute_components or
   --     bom_bill_of_materials or bom_inventory_components
   -- or item is a Product Family with a bill defined

   if (msi_temp.bom_item_type <> msii_temp.bom_item_type) and
     ( (bom_item = 1) or
       (msii_temp.bom_item_type = 5 and bom_exists = 1) ) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BOM_ITEM_TYPE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_BOM_ITEM_TYPE_ERR1',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   -- Start : 3436435 Item in BOM,BOM Enabled cannot be N
   /* commented for bug 5479302
   if (msii_temp.bom_enabled_flag = 'N' and bom_exists = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BOM_ENABLED_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_IOI_ITEM_BOM_EXISTS',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if; */
   -- End   : 3436435 Item in BOM,BOM Enabled cannot be N

   -- validate BOM_ITEM_TYPE (2)
   -- If bom_item_type <> 4 then
   --                 build_in_wip = 'N',
   --                 base_item_id is NULL,
   --                 internal_order_flag = 'N',
   --                 vendor_warranty_flag = 'N'
/*  Bug 967374. If the bom item type is not standard, then build in wip flag
    must be N */

--ToDo (vendor_warranty_flag) :

/*
   if (msii_temp.bom_item_type <> 4) and
     (msii_temp.build_in_wip_flag <> 'N' OR
      msii_temp.base_item_id IS NOT NULL OR
      msii_temp.internal_order_flag <> 'N' OR
      msii_temp.vendor_warranty_flag <> 'N') then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BOM_ITEM_TYPE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_BOM_ITEM_TYPE_ERR2',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;
*/

   -- validate BOM_ITEM_TYPE (3)
   -- Must not=5 when open shipping orders exist

   if (msii_temp.bom_item_type = 5 and
       so_open_exists = 1) then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BOM_ITEM_TYPE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_BOM_ITEM_TYPE_ERR3',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   -- Added for Bug 5143614
   -- Validate update of pick_components flag
   -- If item has a bill defined on it with components on lot basis
   -- then pick_components cannot be TRUE

   if  (msii_temp.pick_components_flag  = 'Y'
        OR  msii_temp.pick_components_flag  = 'y') then
     begin
        SELECT 1 INTO l_item_has_lot_comp
          FROM bom_components_b bic, bom_structures_b bbom
          WHERE bic.basis_type =2
            and bic.bill_sequence_id=bbom.common_bill_sequence_id
            and bbom.assembly_item_id=msii_temp.inventory_item_id
            and bbom.organization_id =msii_temp.organization_id
            and ROWNUM = 1;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            l_item_has_lot_comp := 0;
     end;
     IF l_item_has_lot_comp = 1 THEN
       dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'PICK_COMPONENTS_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_ITEM_LOT_COMP',
                                                     err_text);
       dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
     END IF;
   end if;

   -- validate COSTING_ENABLED_FLAG
   -- Not updateable if onhand or txn pending or uncosted txn
   --  (determined from :cost_txn)
   --  (don't need to worry about Item vs. Item/org because SQL checks
   --  for orgs where costing_org = :org)
   --
   if (msi_temp.costing_enabled_flag <> msii_temp.costing_enabled_flag) and
     (cost_txn = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'COSTING_ENABLED_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_COSTING_ENABLED_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate INVENTORY_ASSET_FLAG
   -- Not updateable if onhand or txn pending or uncosted txn
   --  (determined from cost_txn)
   --  (dont need to worry about Item vs. Item/org because SQL checks
   --  for orgs where costing_org = org)

   if (msi_temp.inventory_asset_flag <> msii_temp.inventory_asset_flag) and
     (cost_txn = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'INVENTORY_ASSET_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_INVENTORY_ASSET_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate FIXED_ORDER_QUANTITY
   -- must be > 0

   if (msii_temp.fixed_order_quantity <=0 ) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'FIXED_ORDER_QUANTITY',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_FIXED_ORDER_QUANTITY_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate PLANNING_MAKE_BUY_CODE
   -- Must be 1 if bom_item_type = 5 (product family)
   --
   if (msii_temp.planning_make_buy_code <> 1) AND
     (msii_temp.bom_item_type = 5) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'PLANNING_MAKE_BUY_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PLANNING_MAKE_BUY_CODE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate ACCEPTABLE_EARLY_DAYS
   -- must be > 0

   if (msii_temp.acceptable_early_days <= 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'ACCEPTABLE_EARLY_DAYS',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_ACCEPTABLE_EARLY_DAYS_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate ACCEPTABLE_RATE_INCREASE
   -- must be >= 0

   if (msii_temp.acceptable_rate_increase < 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'ACCEPTABLE_RATE_INCREASE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_ACCEPT_RATE_INCREASE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate ACCEPTABLE_RATE_DECREASE
   -- must be >= 0

   if (msii_temp.acceptable_rate_decrease < 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'ACCEPTABLE_RATE_DECREASE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_ACCEPT_RATE_DECREASE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate DEMAND_TIME_FENCE_DAYS
   -- updateable only if DEMAND_TIME_FENCE_CODE = 4

   if( msii_temp.demand_time_fence_days <> msi_temp.demand_time_fence_days) AND
     (msii_temp.demand_time_fence_code <> 4) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'DEMAND_TIME_FENCE_DAYS',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_DEMAND_TIME_FENCE_DAYS_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate PLANNING_TIME_FENCE_DAYS
   -- updateable only if PLANNING_TIME_FENCE_CODE = 4

   if( msii_temp.planning_time_fence_days <> msi_temp.planning_time_fence_days) AND
     (msii_temp.planning_time_fence_code <> 4) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'PLANNING_TIME_FENCE_DAYS',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PLAN_TIME_FENCE_DAYS_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate REPETITIVE_PLANNING_FLAG
   -- not updateable if row exists in mrp_schedule_items for item and org

   if (msii_temp.repetitive_planning_flag <> msi_temp.repetitive_planning_flag) and
     (mrp_schedule = 1) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'REPETITIVE_PLANNING_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_REPET_PLANNING_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate SHRINKAGE_RATE
   -- must be 0 <= SHRINKAGE_RATE < 1

   if (msii_temp.shrinkage_rate >= 1) or
      (msii_temp.shrinkage_rate < 0) then

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SHRINKAGE_RATE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_SHRINKAGE_RATE_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;


   -- validate FULL_LEAD_TIME
   -- must be 0 when BOM_ITEM_TYPE = 5

   if (msii_temp.full_lead_time <> 0) and
     (msii_temp.bom_item_type = 5) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'FULL_LEAD_TIME',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_FULL_LEAD_TIME_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate LEAD_TIME_LOT_SIZE
   -- if null, set to std_lot_size

   if (msii_temp.lead_time_lot_size IS null) then
      UPDATE mtl_system_items_interface
        SET lead_time_lot_size = msii_temp.std_lot_size
        WHERE rowid = row_id;

      /* commit for debugging ONLY */
      -- COMMIT;

      status := 0;
   end if;


   -- validate POSTPROCESSING_LEAD_TIME
   -- not updateable and = 0 if PLANNING_MAKE_BUY_CODE = 1

   if (msii_temp.planning_make_buy_code = 1) and
      (msii_temp.postprocessing_lead_time <> 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'POSTPROCESSING_LEAD_TIME',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_POSTPROC_LEAD_TIME_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;


   -- validate VARIABLE_LEAD_TIME
   -- must be > 0

   if (msii_temp.variable_lead_time < 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'VARIABLE_LEAD_TIME',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_VARIABLE_LEAD_TIME_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

    /* Validation added for Bug 4139304 - Anmurali */
   if ((msi_temp.effectivity_control <> msii_temp.effectivity_control) AND (bom_item = 1 OR onhand_all = 1)) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'EFFECTIVITY_CONTROL',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'ITM-EFFC-ITEM IS BILL OR COMP',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
/* End of validation for Bug 4139304 */

--ToDo (SERVICE_ITEM_FLAG) :

   -- validate BUILD_IN_WIP_FLAG
   -- must be 'N' when SERVICE_ITEM_FLAG = 'Y'
/*
   if (msii_temp.build_in_wip_flag <> 'N') and
     (msii_temp.service_item_flag = 'Y') then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'BUILD_IN_WIP_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_BUILD_IN_WIP_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
*/

   -- validate SERVICE_ITEM_FLAG
   -- must be 'N' when MATERIAL_BILLABLE_FLAG <> null
/*
   if (msii_temp.service_item_flag <> 'N') and
     (msii_temp.material_billable_flag IS NOT NULL) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SERVICE_ITEM_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_SERVICE_ITEM_FLAG_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
*/

   -- validate SERVICE_STARTING_DELAY
   -- must be >= 0

   if (msii_temp.service_starting_delay < 0) then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SERVICE_STARTING_DELAY',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_SERVICE_STARTING_DELAY_ERR',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   -- validate VEHICLE_ITEM_FLAG
   -- Not updateable when row exists in FTE_VEHICLE_TYPES

   if (msii_temp.vehicle_item_flag <> 'Y' and  fte_vehicle_exists = 1)  then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'VEHICLE_ITEM_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_VEHICLE_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
   -- Bug: 2710463
   -- validate COMMS_NL_TRACKABLE_FLAG
   -- Not updateable when Onhand Trackable exists

   if ( NVL(msii_temp.COMMS_NL_TRACKABLE_FLAG,'N') <> NVL(msi_temp.COMMS_NL_TRACKABLE_FLAG,'N') and  onhand_trackable = 1)  then
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'COMMS_NL_TRACKABLE_FLAG',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_ONHAND_TRACKABLE_EXIST',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside update_validations: 11.5.10 validations started');
   END IF;
   -- Added for 11.5.10
   -- validate OUTSIDE_OPERATION_FLAG, EAM_ITEM_TYPE, MTL_TRANSACTIONS_ENABLED_FLAG, STOCK_ENABLED_FLAG and INVENTORY_ASSET_FLAG
   -- validate Not updateable fields
    /*Bug 6501149 Code starts */
   if ((msi_temp.STOCK_ENABLED_FLAG <> msii_temp.STOCK_ENABLED_FLAG) AND (stockable = 1) AND msii_temp.STOCK_ENABLED_FLAG = 'N') then
             dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                        org_id,
                                                        user_id,
                                                        login_id,
                                                        prog_appid,
                                                        prog_id,
                                                        request_id,
                                                        trans_id,
                                                        err_text,
                                                   'STOCK_ENABLED_FLAG',
                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                'INV_DELIVER_CANNOT_UPDATE',
                                                        err_text);
         dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
    end if;
    /*Bug 6501149 code ends */

    /* BUG 9135696 code starts */
    if (msi_temp.STOCK_ENABLED_FLAG = 'Y') AND (msii_temp.STOCK_ENABLED_FLAG = 'N') then
      if (INV_ATTRIBUTE_CONTROL_PVT.check_pending_adjustments(msii_temp.organization_id, msii_temp.inventory_item_id, 'STOCK_ENABLED_FLAG')) then
         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                        org_id,
                                                        user_id,
                                                        login_id,
                                                        prog_appid,
                                                        prog_id,
                                                        request_id,
                                                        trans_id,
                                                        err_text,
                                                        'STOCK_ENABLED_FLAG',
                                                        'MTL_SYSTEM_ITEMS_INTERFACE',
                                                        'INV_PENDING_ADJUSTMENT',
                                                        err_text);
         dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
      end if;
    end if;
    /* BUG 9135696 code ends */

   l_column_name := NULL;
   if (vmiorconsign_enabled = 1 ) then
       if (NVL(msii_temp.OUTSIDE_OPERATION_FLAG,'N') = 'Y' ) then
            l_column_name := 'OUTSIDE_OPERATION_FLAG';
       elsif( msii_temp.EAM_ITEM_TYPE IS NOT NULL ) then
           l_column_name := 'EAM_ITEM_TYPE';
       elsif (NVL(msii_temp.MTL_TRANSACTIONS_ENABLED_FLAG,'N') = 'N' )then
           l_column_name := 'MTL_TRANSACTIONS_ENABLED_FLAG';
       elsif (NVL(msii_temp.STOCK_ENABLED_FLAG,'N') = 'N') then
           l_column_name := 'STOCK_ENABLED_FLAG';
       end if;
   end if;
   if(consign_enabled = 1 AND NVL(msii_temp.INVENTORY_ASSET_FLAG,'N') = 'N')  then
           l_column_name := 'INVENTORY_ASSET_FLAG';
   end if;
   if (l_column_name IS NOT NULL) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: VMI validations failed');
      END IF;

      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     l_column_name,
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_VMI_ENABLED_ITEM',
                                                     err_text);
      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);
   end if;
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Inside update_validations: 11.5.10 validations Ended');
   END IF;

   /* Start Bug 3713912 */
   -- validate TRACKING_QUANTITY_IND
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.TRACKING_QUANTITY_IND <> msii_temp.TRACKING_QUANTITY_IND) AND (onhand_tracking_qty_ind = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: TRACKING_QUANTITY_IND onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'TRACKING_QUANTITY_IND',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.TRACKING_QUANTITY_IND <> msii_temp.TRACKING_QUANTITY_IND) AND (pendadj_tracking_qty_ind = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: TRACKING_QUANTITY_IND pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'TRACKING_QUANTITY_IND',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate SECONDARY_UOM_CODE
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.SECONDARY_UOM_CODE <> msii_temp.SECONDARY_UOM_CODE) AND (onhand_secondary_uom = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: SECONDARY_UOM_CODE onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SECONDARY_UOM_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.SECONDARY_UOM_CODE <> msii_temp.SECONDARY_UOM_CODE) AND (pendadj_secondary_uom = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: SECONDARY_UOM_CODE pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SECONDARY_UOM_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate SECONDARY_DEFAULT_IND
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.SECONDARY_DEFAULT_IND <> msii_temp.SECONDARY_DEFAULT_IND) AND (onhand_sec_default_ind = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('INVUPD2B: Inside update_validations: SECONDARY_DEFAULT_IND onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SECONDARY_DEFAULT_IND',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.SECONDARY_DEFAULT_IND <> msii_temp.SECONDARY_DEFAULT_IND) AND (pendadj_sec_default_ind = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: SECONDARY_DEFAULT_IND pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'SECONDARY_DEFAULT_IND',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate PRIMARY_UOM_CODE
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.PRIMARY_UOM_CODE <> msii_temp.PRIMARY_UOM_CODE) AND (onhand_primary_uom = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: PRIMARY_UOM_CODE onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'PRIMARY_UOM_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.PRIMARY_UOM_CODE <> msii_temp.PRIMARY_UOM_CODE) AND (pendadj_primary_uom = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: PRIMARY_UOM_CODE pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'PRIMARY_UOM_CODE',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate DUAL_UOM_DEVIATION_HIGH
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.DUAL_UOM_DEVIATION_HIGH <> msii_temp.DUAL_UOM_DEVIATION_HIGH) AND (onhand_deviation_high = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: DUAL_UOM_DEVIATION_HIGH onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'DUAL_UOM_DEVIATION_HIGH',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.DUAL_UOM_DEVIATION_HIGH <> msii_temp.DUAL_UOM_DEVIATION_HIGH) AND (pendadj_deviation_high = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: DUAL_UOM_DEVIATION_HIGH pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'DUAL_UOM_DEVIATION_HIGH',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   -- validate DUAL_UOM_DEVIATION_LOW
   -- cannot update if there is onhand or transactions pending
   if (msi_temp.DUAL_UOM_DEVIATION_LOW <> msii_temp.DUAL_UOM_DEVIATION_LOW) AND (onhand_deviation_low = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: DUAL_UOM_DEVIATION_LOW onhand validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'DUAL_UOM_DEVIATION_LOW',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_QOH_CANNOT_UPDATE',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   elsif (msi_temp.DUAL_UOM_DEVIATION_LOW <> msii_temp.DUAL_UOM_DEVIATION_LOW) AND (pendadj_deviation_low = 1) then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVUPD2B: Inside update_validations: DUAL_UOM_DEVIATION_LOW pending validations failed');
      END IF;
      dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                     org_id,
                                                     user_id,
                                                     login_id,
                                                     prog_appid,
                                                     prog_id,
                                                     request_id,
                                                     trans_id,
                                                     err_text,
                                                     'DUAL_UOM_DEVIATION_LOW',
                                                     'MTL_SYSTEM_ITEMS_INTERFACE',
                                                     'INV_PENDING_ADJUSTMENT',
                                                     err_text);

      dumm_status := INVUPD2B.set_process_flag3(row_id,user_id,login_id,prog_appid,prog_id,request_id);

   end if;

   /* End Bug 3713912 */

   RETURN (status);

EXCEPTION

   when OTHERS then
      --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
             Substr(
           'when OTHERS exception raised in update_validations ' ||
            SQLCODE ||
            ' - '   ||
            SQLERRM,1,240));
      END IF;
      return (1);

END update_validations;


FUNCTION inproit_process_item_update
(
        prg_appid  IN   NUMBER,
        prg_id     IN   NUMBER,
        req_id     IN   NUMBER,
        user_id    IN   NUMBER,
        login_id   IN   NUMBER,
        error_message  OUT NOCOPY VARCHAR2,
        message_name   OUT NOCOPY VARCHAR2,
        table_name     OUT NOCOPY VARCHAR2,
        xset_id    IN   NUMBER DEFAULT NULL,
    commit_flag   IN     NUMBER       DEFAULT 1   /*Added to Fix Bug 8359046*/
)
RETURN INTEGER
IS
   --Fix bug 6974062(7442071,7001285)
   CURSOR C_msii_processed_records
   IS
      SELECT distinct msii.inventory_item_id
      FROM MTL_SYSTEM_ITEMS_INTERFACE msii
      WHERE
         ( set_process_id = xset_id OR
           set_process_id = xset_id + 1000000000000 )
         AND transaction_type IN ('UPDATE', 'AUTO_CHILD')
         AND process_flag = 4;

   CURSOR C_msii_processed_records_dup
   IS
      SELECT distinct msii.inventory_item_id, organization_id, item_number
      FROM MTL_SYSTEM_ITEMS_INTERFACE msii
      WHERE
         ( set_process_id = xset_id OR
           set_process_id = xset_id + 1000000000000 )
         AND transaction_type IN ('UPDATE', 'AUTO_CHILD')
         AND process_flag = 4;

   --2808277 : Revision update support
   CURSOR C_rev_processed_records
   IS
      SELECT rev.*, rev.rowid
      FROM   mtl_item_revisions_interface rev
      WHERE( rev.set_process_id = xset_id
             OR rev.set_process_id = xset_id + 1000000000000 )
      AND rev.transaction_type = 'UPDATE'
      AND rev.process_flag = 4;
   --2808277 : Revision update support

   -- Bug 5190184
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
         AND(msii.set_process_id = xset_id OR
             msii.set_process_id = xset_id + 1000000000000)
         AND muom.uom_code = msii.primary_uom_code
         AND NOT EXISTS
             ( select 'x'
               from mtl_uom_conversions
               where inventory_item_id = msii.inventory_item_id
                 and uom_code = msii.primary_uom_code
             );

      CURSOR c_ego_intf_rows
      IS
         SELECT msii.transaction_id,
                tl.language,
                tl.column_value,
                msii.inventory_item_id,
                msii.organization_id
           FROM mtl_system_items_interface msii,
                ego_interface_tl tl,
                mtl_system_items item
          WHERE item.inventory_item_id = msii.inventory_item_id
            AND item.organization_id = msii.organization_id
            AND msii.transaction_type in ('UPDATE','AUTO_CHILD')
            AND msii.process_flag = 4
            AND (msii.set_process_id = xset_id or msii.set_process_id = xset_id + 1000000000000)
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

      CURSOR get_organization_code (cp_org_id VARCHAR2) IS
        SELECT name
           FROM hr_organization_units
          WHERE organization_id = cp_org_id;

      -- Start fix for bug 7017691(7435552,7147893) Issue #2 Replacing COUNT(*) with CURSOR
      CURSOR c_duplicate_check(p_set_id NUMBER, p_inventory_item_id NUMBER,
        p_organization_id NUMBER) IS
        SELECT 1
        FROM   MTL_SYSTEM_ITEMS_INTERFACE
        WHERE  inventory_item_id = p_inventory_item_id
               AND organization_id = p_organization_id
               AND process_flag = 4
               AND set_process_id  = p_set_id
               AND transaction_type IN ('UPDATE', 'AUTO_CHILD');
      -- End fix for bug 7017691 Issue #2

      -- Start fix for bug 7017691(7435552,7147893) Issue #3 Move out of the
      -- C_msii_processed_records loop
      CURSOR c_item_number_updated
      IS
        SELECT msik.inventory_item_id,
               msii.segment1,msii.segment2,msii.segment3,msii.segment4,msii.segment5,
               msii.segment6,msii.segment7,msii.segment8,msii.segment9,msii.segment10,
               msii.segment11,msii.segment12,msii.segment13,msii.segment14,msii.segment15,
               msii.segment16,msii.segment17,msii.segment18,msii.segment19,msii.segment20
          FROM mtl_system_items_b_kfv msik,
               mtl_system_items_interface msii,
               mtl_parameters mp
         WHERE msii.set_process_id    = xset_id
           AND msii.transaction_type  = 'UPDATE'
           AND msii.process_flag      = 4
           AND msii.organization_id   = mp.master_organization_id
           AND mp.organization_id = mp.master_organization_id
           AND msii.inventory_item_id = msik.inventory_item_id
           AND msii.organization_id   = msik.organization_id
           AND msii.item_number      <> msik.concatenated_segments
           AND msik.concatenated_segments IS NOT NULL;
      -- End fix for bug 7017691 Issue #3

      TYPE transaction_type IS TABLE OF mtl_system_items_interface.transaction_id%TYPE
      INDEX BY BINARY_INTEGER;
       /* bug 10064010 as no case of delete will be there in update case
       --serial_tagging enh -- bug 9913552

       CURSOR serial_tag_del IS
       SELECT inventory_item_id,organization_id
       FROM  MTL_SYSTEM_ITEMS_INTERFACE
       where process_flag <> 4
       and transaction_type in ('UPDATE','AUTO_CHILD')
       and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000);
       */
        -- added this to copy assignment for successfull records and having template id

	/* Fix for bug 11654417 - In the below cursor, modified the
	   filter on template_id to exclude both -1 and FND_API.G_MISS_NUM */
       CURSOR copy_assignment_frm_temp IS
       SELECT inventory_item_id,organization_id,template_id
       FROM  MTL_SYSTEM_ITEMS_INTERFACE
       where process_flag =4
       and transaction_type in ('UPDATE','AUTO_CHILD')
       AND template_id IS NOT NULL
       AND template_id NOT IN (-1,FND_API.G_MISS_NUM)
       and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000);

       x_ret_sts VARCHAR(1);

        --bug 10065810
         l_temp_org_id number;

        transaction_table transaction_type;

        l_sysdate          date  :=  SYSDATE;
        l_transaction_type varchar2(10)  :=  'UPDATE';
        l_last_updated_by  number;
        l_created_by       number;
        l_default_conversion_flag varchar2(1);
    conversion_rate_temp NUMBER;
        temp_rowid         rowid;
        temp_status_code   varchar2(50);
        dumm_status        number;
        err_text           varchar2(250);
        l_INSTALLED_FLAG   VARCHAR2(1);

    l_return_status   VARCHAR2(1);
    l_msg_text        VARCHAR2(2000);
    l_cst_item_type   NUMBER;

    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
    l_is_gdsn_batch     NUMBER;
    org_name            VARCHAR2(1000);
    error_msg            VARCHAR2(1000);
    ext_flag            NUMBER := 0;

    l_dummy           NUMBER;  --7017691

     -- Bug 12669090 : Start
     l_co_control_level                NUMBER;
     l_io_control_level                NUMBER;
     -- Bug 12669090 : End
BEGIN
   -- calling UCCnet attribute updates
   -- added by Devendra for UCCnet functionality (11.5.10+)
   INV_EGO_REVISION_VALIDATE.Process_UCCnet_Attributes(
     P_Prog_AppId  => prg_appid
    ,P_Prog_Id     => prg_id
    ,P_Request_Id  => req_id
    ,P_User_Id     => user_id
    ,P_Login_Id    => login_id
    ,P_Set_id      => xset_id);
   -- added by Devendra for UCCnet functionality (11.5.10+)

   -- Start 3637854 : Pending ECO check and sync lifecycles
   INV_EGO_REVISION_VALIDATE.Pending_Eco_Check_Sync_Ids(
         P_Prog_AppId  => prg_appid
        ,P_Prog_Id     => prg_id
        ,P_Request_Id  => req_id
        ,P_User_Id     => user_id
        ,P_Login_Id    => login_id
        ,P_Set_id      => xset_id);
   -- End 3637854 : Pending ECO check and sync lifecycles

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B.inproit_process_item_update : begin');
   END IF;

   -- Identify the current session language as Base ('B') or Installed ('I')
   --
   select INSTALLED_FLAG
     into l_INSTALLED_FLAG
   from  FND_LANGUAGES
   where  LANGUAGE_CODE = userenv('LANG');

   -- Start fix for bug 7017691(7435552,7147893) Issue #1
   l_is_gdsn_batch := 0;
   OPEN  is_gdsn_batch(xset_id);
   FETCH is_gdsn_batch INTO l_is_gdsn_batch;
   CLOSE is_gdsn_batch;
   -- Start fix for bug 7017691 Issue #1

   FOR item_rec IN C_msii_processed_records_dup LOOP
     ext_flag        := 0;

     --Performing duplicate check validation for GDSN batches
     IF l_is_gdsn_batch = 1 THEN
       -- Start Fix for bug 7017691(7435552,7147893) Issue #2 Replacing
       -- COUNT(*) with CURSOR
        OPEN c_duplicate_check(xset_id, item_rec.inventory_item_id,
          item_rec.organization_id);
        FETCH c_duplicate_check INTO l_dummy;

        IF c_duplicate_check%FOUND THEN
          FETCH c_duplicate_check INTO l_dummy;
          IF c_duplicate_check%FOUND THEN
              ext_flag := 2;
          END IF;
        END IF;

        CLOSE c_duplicate_check;
      -- End Fix for bug 7017691 Issue #2

        IF ext_flag > 1 THEN
           UPDATE MTL_SYSTEM_ITEMS_INTERFACE
              SET process_flag = 3
            WHERE inventory_item_id = item_rec.inventory_item_id
              AND organization_id = item_rec.organization_id
              AND process_flag = 4
              AND set_process_id  = xset_id
              AND transaction_type IN ('UPDATE', 'AUTO_CHILD')
           RETURNING transaction_id BULK COLLECT INTO transaction_table;

             OPEN  get_organization_code(item_rec.organization_id);
             FETCH get_organization_code Into org_name;
             CLOSE get_organization_code;

           FND_MESSAGE.SET_NAME  ('INV', 'INV_IOI_DUPLICATE_REC_MSII');
           FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', item_rec.item_number);
           FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
           error_msg := FND_MESSAGE.GET;

           IF transaction_table.COUNT > 0 THEN
              FOR j IN transaction_table.FIRST .. transaction_table.LAST LOOP
                 dumm_status := INVPUOPI.mtl_log_interface_err(
                                      item_rec.organization_id,
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
                                      err_text);
              END LOOP;
           END IF;
        END IF;
     END IF;
   END LOOP;
   /* bug 10064010
    -- serial_Tagging enh -- bug 9913552
   FOR I IN serial_tag_del LOOP
      inv_serial_number_pub.delete_serial_tag_assignments(
                                      p_inventory_item_id=> i.inventory_item_id,
                                      p_organization_id=>i.organization_id,
                                      x_return_status=>x_ret_sts);
   END LOOP;
   */

   FOR I IN copy_assignment_frm_temp LOOP
      -- bug 10065810
       begin
         SELECT  CONTEXT_ORGANIZATION_ID into l_temp_org_id
         FROM mtl_item_templates
         WHERE  template_id=i.template_id;
       end;

      IF  (INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_template_id => i.template_id
                                                  -- bug 10065810
                                                      , p_organization_id => l_temp_org_id
                                                      )=2) THEN
              INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
                                            p_from_template_id => i.template_id,
                                            --  bug 10065810
                                                p_from_org_id      => l_temp_org_id,
                            p_to_item_id       => i.inventory_item_id,
                                            p_to_org_id        => i.organization_id,
                                            x_return_status    =>  x_ret_sts);


           END IF ;
   END LOOP;



   FOR item_rec IN C_msii_processed_records LOOP

/* All updates and inserts that happen for a given Item to production tables
   must ALL occur or NONE must occur. Also ALL Master-Child updates must happen
   or NONE.  Therefore defining a cursor that tries to lock all required
   records before proceeding.
*/

   DECLARE

      CURSOR C_lock_msi_records
      IS
         select /*+ first_rows index(MSII, MTL_SYSTEM_ITEMS_INTERFACE_N1) */
        msi.ROWID msi_rowid,
                msi.inventory_item_status_code msi_status_code,
                msi.lifecycle_id   msi_lifecycle_id,
                msi.current_phase_id msi_current_phase_id,
                msi.item_catalog_group_id msi_catalog_group_id,
                msi.INVENTORY_ITEM_FLAG inv_item_flag,
                msi.PURCHASING_ITEM_FLAG purchasing_flag,
                msi.INTERNAL_ORDER_FLAG int_order_flag,
                msi.MRP_PLANNING_CODE planning_code,
                msi.SERVICE_ITEM_FLAG serv_item_flag,
                msi.CUSTOMER_ORDER_FLAG cust_ord_flag,
                msi.COSTING_ENABLED_FLAG cost_flag,
                msi.ENG_ITEM_FLAG eng_flag,
                 /* Adding GDSN Changes - R12 FPC */
                  msi.GDSN_OUTBOUND_ENABLED_FLAG gdsn_flag,
                msi.EAM_ITEM_TYPE eam_type,
                msi.CONTRACT_ITEM_TYPE_CODE contract_type,
                msi.INVENTORY_ASSET_FLAG inv_asset_flag,--Bug:3899614
                msi.OBJECT_VERSION_NUMBER obj_ver_num,
                msii.ROWID msii_rowid, msii.*
         from MTL_SYSTEM_ITEMS_B msi, MTL_SYSTEM_ITEMS_INTERFACE msii
         where item_rec.inventory_item_id = msii.inventory_item_id
           and item_rec.inventory_item_id = msi.inventory_item_id
           and msii.transaction_type in ('UPDATE','AUTO_CHILD')
           and msi.organization_id = msii.organization_id
           and msii.process_flag = 4
           and (msii.set_process_id = xset_id or msii.set_process_id = xset_id + 1000000000000)
         for update of msi.inventory_item_id nowait;

      resource_busy    EXCEPTION;
      -- Bug 5997870
      obj_version_error EXCEPTION;
      PRAGMA EXCEPTION_INIT (resource_busy, -54);

      -- 2810346: Lock failed record details into log
      l_org_id         mtl_system_items_interface.organization_id%TYPE;
      l_transaction_id mtl_system_items_interface.transaction_id%TYPE;

      l_target_lc_id   mtl_system_items_b.lifecycle_id%TYPE;

   BEGIN
      SAVEPOINT before_lock; -- Bug 5997870
      FOR rec IN C_lock_msi_records LOOP

        ---------- Coding changes for bug 5870114 starts------------
        -- If the current inventory item id and organization id matches with that set
        IF(obj_ver_rec.inventory_item_id IS NOT NULL AND
           obj_ver_rec.org_id IS NOT NULL) THEN    -- Check 1 some value is set..
          IF(rec.inventory_item_id = obj_ver_rec.inventory_item_id   AND
             rec.organization_id = obj_ver_rec.org_id) THEN   -- Check 2 , item id and org id matches
            IF( Nvl(rec.obj_ver_num,1) <> Nvl(obj_ver_rec.Object_Version_Number,1)) THEN -- Check 3, object version no. is not same...
               --Clear the values so that it does not persist to another call..
               obj_ver_rec.inventory_item_id := NULL;
               obj_ver_rec.org_id := NULL;
               obj_ver_rec.Object_Version_Number := NULL;

               ROLLBACK TO before_lock;  --Rollback and throw the error.
               RAISE   obj_version_error;
            END IF;
          END IF;
        END IF;
        --Clear the values so that it does not persist to another call..
        obj_ver_rec.inventory_item_id := NULL;
        obj_ver_rec.org_id := NULL;
        obj_ver_rec.Object_Version_Number := NULL;

        ---------- Coding changes for bug 5870114 ends------------

        /* Bug 2665114
          Add following condition to avoid performance issue */

         IF  (rec.inv_item_flag <> rec.INVENTORY_ITEM_FLAG )  or
             (rec.purchasing_flag <> rec.PURCHASING_ITEM_FLAG) or
             (rec.int_order_flag <> rec.INTERNAL_ORDER_FLAG) or
             (rec.planning_code <> rec.MRP_PLANNING_CODE ) or
             (rec.serv_item_flag <> rec.SERVICE_ITEM_FLAG) or
             (rec.cust_ord_flag <> rec.CUSTOMER_ORDER_FLAG) or
             (rec.cost_flag <> rec.COSTING_ENABLED_FLAG) or
             (rec.eng_flag <> rec.ENG_ITEM_FLAG) or
             (rec.eam_type <> rec.EAM_ITEM_TYPE) or
              ((rec.gdsn_flag <> rec.GDSN_OUTBOUND_ENABLED_FLAG) AND
                (NVL(INV_EGO_REVISION_VALIDATE.Get_Process_Control(),'X')<> 'PLM_UI:Y') ) or
             (rec.contract_type <> rec.CONTRACT_ITEM_TYPE_CODE) then

         IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVUPD2B: inserting the item category assignments for default category sets ');
         END IF;

         -- Creating item category assignments for the default category sets
         -- for the functional areas having the defining attribute enabled.

         insert into mtl_item_categories
         (
            inventory_item_id,
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
         select
            rec.inventory_item_id,
                        s.category_set_id,
                        s.default_category_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        -1,
                        -1,
                        sysdate,
                        -1,
                        rec.organization_id
         from  mtl_category_sets  s
         where  s.category_set_id in
                   ( select  d.category_set_id
                     from  mtl_default_category_sets  d
                     where  (d.functional_area_id =
                             decode(rec.INVENTORY_ITEM_FLAG,'Y',1,0)
                        or  d.functional_area_id =
                             decode(rec.PURCHASING_ITEM_FLAG,'Y',2,0)
                        or  d.functional_area_id =
                             decode(rec.INTERNAL_ORDER_FLAG,'Y',2,0)
                        or  d.functional_area_id =
                             decode(rec.MRP_PLANNING_CODE,6,0,3)
                        or  d.functional_area_id =
                             decode(rec.SERVICE_ITEM_FLAG,'Y',4,0)
                        or  d.functional_area_id =
                             decode(rec.CUSTOMER_ORDER_FLAG,'Y',7,0)
                        or  d.functional_area_id =
                             decode(rec.COSTING_ENABLED_FLAG,'Y',5,0)
                        or  d.functional_area_id =
                            decode(rec.ENG_ITEM_FLAG,'Y',6,0)
                        /* Default vategory Assignment for GDSN Syndicated Items - R12 FPC */
                           or  d.functional_area_id =
                               decode(rec.GDSN_OUTBOUND_ENABLED_FLAG, 'Y', 12,0)
                   or d.functional_area_id =
                        decode( NVL(rec.EAM_ITEM_TYPE, 0), 0, 0, 9 )
                   or d.functional_area_id =
                        decode( rec.CONTRACT_ITEM_TYPE_CODE,
                                 'SERVICE'      , 10,
                                 'WARRANTY'     , 10,
                                 'SUBSCRIPTION' , 10,
                                 'USAGE'        , 10, 0 )
           -- These Contract Item types also imply an item belonging to the Service functional area
                   or d.functional_area_id =
                         decode( rec.CONTRACT_ITEM_TYPE_CODE,
                                 'SERVICE'      , 4,
                                 'WARRANTY'     , 4, 0 )
                              )
                    )
              and  not exists
                   ( select 'already_exists'
                     from mtl_item_categories mic
                     where mic.inventory_item_id = rec.inventory_item_id
                       and mic.organization_id = rec.organization_id
                       and mic.category_set_id = s.category_set_id
                   );


           END IF;                      --- Bug 2665114

-- 2433351,new functional area Product Reporting Looping through all the Orgs
            IF ( rec.transaction_type = 'UPDATE') THEN
             -- Bug 12669090 : Start : Similar to the code change done in the bug 9833451 (12.1)
 	               select count(1) into l_co_control_level
 	               from mtl_item_attributes
 	               WHERE attribute_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG'
 	                 and control_level = 1
 	                 and rec.CUSTOMER_ORDER_FLAG = 'Y';

 	               select count(1) into l_io_control_level
 	               from mtl_item_attributes
 	               WHERE attribute_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG'
 	                 and control_level = 1
 	                 and rec.INTERNAL_ORDER_FLAG = 'Y';

 	               IF (l_co_control_level = 1 OR l_io_control_level = 1) THEN
 	                 /*Inserts for all the child Orgs if either IO or CO is master controlled and their value is 'Y'*/
             /*Modified for Bug 9833451 */
                    /*Inserts for all the child Orgs if either IO or CO is master controlled and their value is 'Y'*/
                    insert into mtl_item_categories
                         (
                            inventory_item_id,
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
                         select
                            rec.inventory_item_id,
                                s.category_set_id,
                                s.default_category_id,
                                sysdate,
                                -1,
                                sysdate,
                                -1,
                                -1,
                                -1,
                                -1,
                                sysdate,
                                -1,
                                mp.organization_id
                         from  mtl_category_sets  s,
                               mtl_parameters mp
                         where mp.master_organization_id = (select master_organization_id
                                                                                FROM mtl_parameters m
                                                                                                                where m.organization_id = rec.organization_id)
                                         and mp.organization_id <> mp.master_organization_id
                         and s.default_category_id IS NOT NULL --Bug: 2801594
                         and s.category_set_id in
                                   ( select  d.category_set_id
                                     from  mtl_default_category_sets  d
                                     where  d.functional_area_id =
                                         decode( rec.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )
                                            or d.functional_area_id =
                                         decode( rec.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
                                    )
                         and  EXISTS
                                ( SELECT 'x'
                                  FROM  mtl_system_items_b  i
                                  WHERE      i.inventory_item_id = rec.inventory_item_id
                                     AND i.organization_id   = mp.organization_id
                                )
                -- Check if the item already has any category assignment
                         and  not exists
                                ( select 'already_exists'
                                     from mtl_item_categories mic
                                     where mic.inventory_item_id = rec.inventory_item_id
                                       --Bug 4089984. Modified following 'and' condition to
                                       --  pick up rows from mtl_parameters table
                                       and mic.organization_id = mp.organization_id
                                       and mic.category_set_id = s.category_set_id
                                 )
                         and (exists
                                     (select 'co_mst_controlled'
                                      from mtl_item_attributes
                                      WHERE attribute_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG'
                                      and control_level = 1
                                      and rec.CUSTOMER_ORDER_FLAG = 'Y')
                                   or exists
                                     (select 'io_mst_controlled'
                                      from mtl_item_attributes
                                      WHERE attribute_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG'
                                      and control_level = 1
                                      and rec.INTERNAL_ORDER_FLAG = 'Y')
                                   );
                          END IF;
                          /*Inserts for specific orgs including master orgs*/
                          insert into mtl_item_categories
                         (
                            inventory_item_id,
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
                         select
                            rec.inventory_item_id,
                                s.category_set_id,
                                s.default_category_id,
                                sysdate,
                                -1,
                                sysdate,
                                -1,
                                -1,
                                -1,
                                -1,
                                sysdate,
                                -1,
                                rec.organization_id
                         from  mtl_category_sets  s
                         where s.default_category_id IS NOT NULL --Bug: 2801594
                         and s.category_set_id in
                                   ( select  d.category_set_id
                                     from  mtl_default_category_sets  d
                                     where  d.functional_area_id =
                                         decode( rec.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )
                                            or d.functional_area_id =
                                         decode( rec.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
                                    )
                         and  EXISTS
                                ( SELECT 'x'
                                  FROM  mtl_system_items_b  i
                                  WHERE      i.inventory_item_id = rec.inventory_item_id
                                     AND i.organization_id   = rec.organization_id
                                )
                -- Check if the item already has any category assignment
                         and  not exists
                                ( select 'already_exists'
                                     from mtl_item_categories mic
                                     where mic.inventory_item_id = rec.inventory_item_id
                                       --Bug 4089984. Modified following 'and' condition to
                                       --  pick up rows from mtl_parameters table
                                       and mic.organization_id = rec.organization_id
                                       and mic.category_set_id = s.category_set_id
                                 );
                              /*end of bug 9833451*/

              END IF;



      IF ( nvl(rec.msi_catalog_group_id,-999) <> nvl(rec.item_catalog_group_id,-999) ) THEN

         delete from mtl_descr_element_values
         where
                inventory_item_id = rec.inventory_item_id
            and rec.item_catalog_group_id is not null
            and exists
                ( select 'x'
                  from mtl_parameters MP
                  where MP.organization_id = rec.organization_id
                    and MP.master_organization_id = rec.organization_id
                );

         insert into MTL_DESCR_ELEMENT_VALUES
         (
            inventory_item_id,
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
                 element_sequence
         )
         select
            rec.inventory_item_id,
             MDE.ELEMENT_NAME,
             MDE.default_element_flag,
             l_sysdate,
             user_id,       /* last_updated_by */
             l_sysdate,
             user_id,       /* created_by */
             login_id,      /* last_update_login */
             req_id,
             prg_appid,
             prg_id,
             l_sysdate,
             MDE.ELEMENT_SEQUENCE
         from
            mtl_descriptive_elements  MDE
         ,  mtl_parameters            MP
         where
                rec.organization_id = MP.master_organization_id
            and rec.organization_id = MP.organization_id
            and MDE.item_catalog_group_id = nvl(rec.item_catalog_group_id,-999);

      END IF;
--Bug:4132663 Not inserting if call from PLM UI
 IF (NVL(INV_EGO_REVISION_VALIDATE.Get_Process_Control(),'X')<> 'PLM_UI:Y' AND
          (( rec.msi_status_code <> rec.inventory_item_status_code )
          OR (NVL(rec.msi_lifecycle_id,1) <> NVL(rec.lifecycle_id,NVL(rec.msi_lifecycle_id,1)))
          OR (NVL(rec.msi_current_phase_id,1) <> NVL(rec.current_phase_id,NVL(rec.msi_current_phase_id,1)))))
      THEN
         insert into mtl_pending_item_status
         (  INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            STATUS_CODE,
            LIFECYCLE_ID,
            PHASE_ID,
            EFFECTIVE_DATE,
            IMPLEMENTED_DATE,
            PENDING_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY
         )
         values
         (  rec.inventory_item_id,
            rec.organization_id,
            rec.inventory_item_status_code,
            rec.lifecycle_id,
            rec.current_phase_id,
            l_sysdate,
            l_sysdate,
            'N',
            l_sysdate,
            user_id,
            l_sysdate,
            user_id
         );

      END IF;

      -- bug 10373720 , set last_update_date = sysdate
      -- old  Modified l_sysdate => Nvl(rec.LAST_UPDATE_DATE,l_sysdate) for Bug - 3313863
      UPDATE  MTL_SYSTEM_ITEMS_B  MTLSYSI
      SET
                LAST_UPDATE_DATE               =        l_sysdate,
                LAST_UPDATED_BY                =        user_id,
                LAST_UPDATE_LOGIN               =        login_id,
                SUMMARY_FLAG                    =        rec.SUMMARY_FLAG,
                ENABLED_FLAG                    =        rec.ENABLED_FLAG,
--                START_DATE_ACTIVE               =        rec.START_DATE_ACTIVE,      Commented for Bug: 4457440
--                END_DATE_ACTIVE                 =        rec.END_DATE_ACTIVE,        Commented for Bug: 4457440
                DESCRIPTION             =  decode(l_INSTALLED_FLAG, 'B', rec.DESCRIPTION, DESCRIPTION),
                BUYER_ID                        =        rec.BUYER_ID,
                ACCOUNTING_RULE_ID              =        rec.ACCOUNTING_RULE_ID,
                INVOICING_RULE_ID               =        rec.INVOICING_RULE_ID,
                ATTRIBUTE1                      =        rec.ATTRIBUTE1,
                ATTRIBUTE2                      =        rec.ATTRIBUTE2,
                ATTRIBUTE3                      =        rec.ATTRIBUTE3,
                ATTRIBUTE4                      =        rec.ATTRIBUTE4,
                ATTRIBUTE5                      =        rec.ATTRIBUTE5,
                ATTRIBUTE6                      =        rec.ATTRIBUTE6,
                ATTRIBUTE7                      =        rec.ATTRIBUTE7,
                ATTRIBUTE8                      =        rec.ATTRIBUTE8,
                ATTRIBUTE9                      =        rec.ATTRIBUTE9,
                ATTRIBUTE10                     =        rec.ATTRIBUTE10,
                ATTRIBUTE11                     =        rec.ATTRIBUTE11,
                ATTRIBUTE12                     =        rec.ATTRIBUTE12,
                ATTRIBUTE13                     =        rec.ATTRIBUTE13,
                ATTRIBUTE14                     =        rec.ATTRIBUTE14,
                ATTRIBUTE15                     =        rec.ATTRIBUTE15,
                /* Start Bug 3713912 */
                ATTRIBUTE16                     =        rec.ATTRIBUTE16,
                ATTRIBUTE17                     =        rec.ATTRIBUTE17,
                ATTRIBUTE18                     =        rec.ATTRIBUTE18,
                ATTRIBUTE19                     =        rec.ATTRIBUTE19,
                ATTRIBUTE20                     =        rec.ATTRIBUTE20,
                ATTRIBUTE21                     =        rec.ATTRIBUTE21,
                ATTRIBUTE22                     =        rec.ATTRIBUTE22,
                ATTRIBUTE23                     =        rec.ATTRIBUTE23,
                ATTRIBUTE24                     =        rec.ATTRIBUTE24,
                ATTRIBUTE25                     =        rec.ATTRIBUTE25,
                ATTRIBUTE26                     =        rec.ATTRIBUTE26,
                ATTRIBUTE27                     =        rec.ATTRIBUTE27,
                ATTRIBUTE28                     =        rec.ATTRIBUTE28,
                ATTRIBUTE29                     =        rec.ATTRIBUTE29,
                ATTRIBUTE30                     =        rec.ATTRIBUTE30,
                /* End Bug 3713912 */
                ATTRIBUTE_CATEGORY      =        rec.ATTRIBUTE_CATEGORY,
                GLOBAL_ATTRIBUTE_CATEGORY       =        rec.GLOBAL_ATTRIBUTE_CATEGORY,
                GLOBAL_ATTRIBUTE1               =        rec.GLOBAL_ATTRIBUTE1,
                GLOBAL_ATTRIBUTE2               =        rec.GLOBAL_ATTRIBUTE2,
                GLOBAL_ATTRIBUTE3               =        rec.GLOBAL_ATTRIBUTE3,
                GLOBAL_ATTRIBUTE4               =        rec.GLOBAL_ATTRIBUTE4,
                GLOBAL_ATTRIBUTE5               =        rec.GLOBAL_ATTRIBUTE5,
                GLOBAL_ATTRIBUTE6               =        rec.GLOBAL_ATTRIBUTE6,
                GLOBAL_ATTRIBUTE7               =        rec.GLOBAL_ATTRIBUTE7,
                GLOBAL_ATTRIBUTE8               =        rec.GLOBAL_ATTRIBUTE8,
                GLOBAL_ATTRIBUTE9               =        rec.GLOBAL_ATTRIBUTE9,
                GLOBAL_ATTRIBUTE10              =        rec.GLOBAL_ATTRIBUTE10,
                GLOBAL_ATTRIBUTE11               =        rec.GLOBAL_ATTRIBUTE11,
                GLOBAL_ATTRIBUTE12               =        rec.GLOBAL_ATTRIBUTE12,
                GLOBAL_ATTRIBUTE13               =        rec.GLOBAL_ATTRIBUTE13,
                GLOBAL_ATTRIBUTE14               =        rec.GLOBAL_ATTRIBUTE14,
                GLOBAL_ATTRIBUTE15               =        rec.GLOBAL_ATTRIBUTE15,
                GLOBAL_ATTRIBUTE16               =        rec.GLOBAL_ATTRIBUTE16,
                GLOBAL_ATTRIBUTE17               =        rec.GLOBAL_ATTRIBUTE17,
                GLOBAL_ATTRIBUTE18               =        rec.GLOBAL_ATTRIBUTE18,
                GLOBAL_ATTRIBUTE19               =        rec.GLOBAL_ATTRIBUTE19,
                GLOBAL_ATTRIBUTE20              =        rec.GLOBAL_ATTRIBUTE20,
                PURCHASING_ITEM_FLAG            =        rec.PURCHASING_ITEM_FLAG,
                SHIPPABLE_ITEM_FLAG             =        rec.SHIPPABLE_ITEM_FLAG,
                CUSTOMER_ORDER_FLAG             =        rec.CUSTOMER_ORDER_FLAG,
                INTERNAL_ORDER_FLAG             =        rec.INTERNAL_ORDER_FLAG,
                INVENTORY_ITEM_FLAG             =        rec.INVENTORY_ITEM_FLAG,
                ENG_ITEM_FLAG                   =        rec.ENG_ITEM_FLAG,
                INVENTORY_ASSET_FLAG            =        rec.INVENTORY_ASSET_FLAG,
                PURCHASING_ENABLED_FLAG         =        rec.PURCHASING_ENABLED_FLAG,
                CUSTOMER_ORDER_ENABLED_FLAG     =        rec.CUSTOMER_ORDER_ENABLED_FLAG,
                INTERNAL_ORDER_ENABLED_FLAG     =        rec.INTERNAL_ORDER_ENABLED_FLAG,
                SO_TRANSACTIONS_FLAG            =        rec.SO_TRANSACTIONS_FLAG,
                MTL_TRANSACTIONS_ENABLED_FLAG   =        rec.MTL_TRANSACTIONS_ENABLED_FLAG,
                STOCK_ENABLED_FLAG              =        rec.STOCK_ENABLED_FLAG,
                BOM_ENABLED_FLAG                =        rec.BOM_ENABLED_FLAG,
                BUILD_IN_WIP_FLAG               =        rec.BUILD_IN_WIP_FLAG,
                REVISION_QTY_CONTROL_CODE       =        rec.REVISION_QTY_CONTROL_CODE,
                ITEM_CATALOG_GROUP_ID           =        rec.ITEM_CATALOG_GROUP_ID,
                CATALOG_STATUS_FLAG             =        rec.CATALOG_STATUS_FLAG,
                RETURNABLE_FLAG                 =        rec.RETURNABLE_FLAG,
                DEFAULT_SHIPPING_ORG            =        rec.DEFAULT_SHIPPING_ORG,
                COLLATERAL_FLAG                 =        rec.COLLATERAL_FLAG,
                TAXABLE_FLAG                    =        rec.TAXABLE_FLAG,
                PURCHASING_TAX_CODE             =        rec.PURCHASING_TAX_CODE,
                ALLOW_ITEM_DESC_UPDATE_FLAG     =        rec.ALLOW_ITEM_DESC_UPDATE_FLAG,
                INSPECTION_REQUIRED_FLAG        =        rec.INSPECTION_REQUIRED_FLAG,
                RECEIPT_REQUIRED_FLAG           =        rec.RECEIPT_REQUIRED_FLAG,
                MARKET_PRICE                    =        rec.MARKET_PRICE,
                HAZARD_CLASS_ID                 =        rec.HAZARD_CLASS_ID,
                RFQ_REQUIRED_FLAG               =        rec.RFQ_REQUIRED_FLAG,
                QTY_RCV_TOLERANCE               =        rec.QTY_RCV_TOLERANCE,
                LIST_PRICE_PER_UNIT             =        rec.LIST_PRICE_PER_UNIT,
                UN_NUMBER_ID                    =        rec.UN_NUMBER_ID,
                PRICE_TOLERANCE_PERCENT         =        rec.PRICE_TOLERANCE_PERCENT,
                ASSET_CATEGORY_ID               =        rec.ASSET_CATEGORY_ID,
                ROUNDING_FACTOR                 =        rec.ROUNDING_FACTOR,
                UNIT_OF_ISSUE                   =        rec.UNIT_OF_ISSUE,
                ENFORCE_SHIP_TO_LOCATION_CODE   =        rec.ENFORCE_SHIP_TO_LOCATION_CODE,
                ALLOW_SUBSTITUTE_RECEIPTS_FLAG  =        rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
                ALLOW_UNORDERED_RECEIPTS_FLAG   =        rec.ALLOW_UNORDERED_RECEIPTS_FLAG,
                ALLOW_EXPRESS_DELIVERY_FLAG     =        rec.ALLOW_EXPRESS_DELIVERY_FLAG,
                DAYS_EARLY_RECEIPT_ALLOWED      =        rec.DAYS_EARLY_RECEIPT_ALLOWED,
                DAYS_LATE_RECEIPT_ALLOWED       =        rec.DAYS_LATE_RECEIPT_ALLOWED,
                RECEIPT_DAYS_EXCEPTION_CODE     =        rec.RECEIPT_DAYS_EXCEPTION_CODE,
                RECEIVING_ROUTING_ID            =        rec.RECEIVING_ROUTING_ID,
                INVOICE_CLOSE_TOLERANCE         =        rec.INVOICE_CLOSE_TOLERANCE,
                RECEIVE_CLOSE_TOLERANCE         =        rec.RECEIVE_CLOSE_TOLERANCE,
                AUTO_LOT_ALPHA_PREFIX           =        rec.AUTO_LOT_ALPHA_PREFIX,
                START_AUTO_LOT_NUMBER           =        rec.START_AUTO_LOT_NUMBER,
                LOT_CONTROL_CODE                =        rec.LOT_CONTROL_CODE,
                SHELF_LIFE_CODE                 =        rec.SHELF_LIFE_CODE,
                SHELF_LIFE_DAYS                 =        rec.SHELF_LIFE_DAYS,
                SERIAL_NUMBER_CONTROL_CODE      =        rec.SERIAL_NUMBER_CONTROL_CODE,
                START_AUTO_SERIAL_NUMBER        =        rec.START_AUTO_SERIAL_NUMBER,
                AUTO_SERIAL_ALPHA_PREFIX        =        rec.AUTO_SERIAL_ALPHA_PREFIX,
                SOURCE_TYPE                     =        rec.SOURCE_TYPE,
                SOURCE_ORGANIZATION_ID          =        rec.SOURCE_ORGANIZATION_ID,
                SOURCE_SUBINVENTORY             =        rec.SOURCE_SUBINVENTORY,
                EXPENSE_ACCOUNT                 =        rec.EXPENSE_ACCOUNT,
                ENCUMBRANCE_ACCOUNT             =        rec.ENCUMBRANCE_ACCOUNT,
                RESTRICT_SUBINVENTORIES_CODE    =        rec.RESTRICT_SUBINVENTORIES_CODE,
                UNIT_WEIGHT                     =        rec.UNIT_WEIGHT,
                WEIGHT_UOM_CODE                 =        rec.WEIGHT_UOM_CODE,
                VOLUME_UOM_CODE                 =        rec.VOLUME_UOM_CODE,
                UNIT_VOLUME                     =        rec.UNIT_VOLUME,
                RESTRICT_LOCATORS_CODE          =        rec.RESTRICT_LOCATORS_CODE,
                LOCATION_CONTROL_CODE           =        rec.LOCATION_CONTROL_CODE,
                SHRINKAGE_RATE                  =        rec.SHRINKAGE_RATE,
                ACCEPTABLE_EARLY_DAYS           =        rec.ACCEPTABLE_EARLY_DAYS,
                PLANNING_TIME_FENCE_CODE        =        rec.PLANNING_TIME_FENCE_CODE,
                DEMAND_TIME_FENCE_CODE          =        rec.DEMAND_TIME_FENCE_CODE,
                LEAD_TIME_LOT_SIZE              =        rec.LEAD_TIME_LOT_SIZE,
                STD_LOT_SIZE                    =        rec.STD_LOT_SIZE,
                CUM_MANUFACTURING_LEAD_TIME     =        rec.CUM_MANUFACTURING_LEAD_TIME,
                OVERRUN_PERCENTAGE              =        rec.OVERRUN_PERCENTAGE,
                ACCEPTABLE_RATE_INCREASE        =        rec.ACCEPTABLE_RATE_INCREASE,
                ACCEPTABLE_RATE_DECREASE        =        rec.ACCEPTABLE_RATE_DECREASE,
                CUMULATIVE_TOTAL_LEAD_TIME      =        rec.CUMULATIVE_TOTAL_LEAD_TIME,
                PLANNING_TIME_FENCE_DAYS        =        rec.PLANNING_TIME_FENCE_DAYS,
                DEMAND_TIME_FENCE_DAYS          =        rec.DEMAND_TIME_FENCE_DAYS,
                END_ASSEMBLY_PEGGING_FLAG       =        rec.END_ASSEMBLY_PEGGING_FLAG,
                PLANNING_EXCEPTION_SET          =        rec.PLANNING_EXCEPTION_SET,
                BOM_ITEM_TYPE                   =        rec.BOM_ITEM_TYPE,
                PICK_COMPONENTS_FLAG            =        rec.PICK_COMPONENTS_FLAG,
                REPLENISH_TO_ORDER_FLAG         =        rec.REPLENISH_TO_ORDER_FLAG,
                BASE_ITEM_ID                    =        rec.BASE_ITEM_ID,
                ATP_COMPONENTS_FLAG             =        rec.ATP_COMPONENTS_FLAG,
                ATP_FLAG                        =        rec.ATP_FLAG,
                FIXED_LEAD_TIME                 =        rec.FIXED_LEAD_TIME,
                VARIABLE_LEAD_TIME              =        rec.VARIABLE_LEAD_TIME,
                WIP_SUPPLY_LOCATOR_ID           =        rec.WIP_SUPPLY_LOCATOR_ID,
                WIP_SUPPLY_TYPE                 =        rec.WIP_SUPPLY_TYPE,
                WIP_SUPPLY_SUBINVENTORY         =        rec.WIP_SUPPLY_SUBINVENTORY,
                PRIMARY_UOM_CODE                =        rec.PRIMARY_UOM_CODE,
                PRIMARY_UNIT_OF_MEASURE         =        rec.PRIMARY_UNIT_OF_MEASURE,
                ALLOWED_UNITS_LOOKUP_CODE       =        rec.ALLOWED_UNITS_LOOKUP_CODE,
                COST_OF_SALES_ACCOUNT           =        rec.COST_OF_SALES_ACCOUNT,
                SALES_ACCOUNT                   =        rec.SALES_ACCOUNT,
                DEFAULT_INCLUDE_IN_ROLLUP_FLAG  =        rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
                INVENTORY_ITEM_STATUS_CODE      =        rec.INVENTORY_ITEM_STATUS_CODE,
                INVENTORY_PLANNING_CODE         =        rec.INVENTORY_PLANNING_CODE,
                PLANNER_CODE                    =        rec.PLANNER_CODE,
                PLANNING_MAKE_BUY_CODE          =        rec.PLANNING_MAKE_BUY_CODE,
                FIXED_LOT_MULTIPLIER            =        rec.FIXED_LOT_MULTIPLIER,
                ROUNDING_CONTROL_TYPE           =        rec.ROUNDING_CONTROL_TYPE,
                CARRYING_COST                   =        rec.CARRYING_COST,
                POSTPROCESSING_LEAD_TIME        =        rec.POSTPROCESSING_LEAD_TIME,
                PREPROCESSING_LEAD_TIME         =        rec.PREPROCESSING_LEAD_TIME,
                FULL_LEAD_TIME                  =        rec.FULL_LEAD_TIME,
                ORDER_COST                      =        rec.ORDER_COST,
                MRP_SAFETY_STOCK_PERCENT        =        rec.MRP_SAFETY_STOCK_PERCENT,
                MRP_SAFETY_STOCK_CODE           =        rec.MRP_SAFETY_STOCK_CODE,
                MIN_MINMAX_QUANTITY             =        rec.MIN_MINMAX_QUANTITY,
                MAX_MINMAX_QUANTITY             =        rec.MAX_MINMAX_QUANTITY,
                MINIMUM_ORDER_QUANTITY          =        rec.MINIMUM_ORDER_QUANTITY,
                FIXED_ORDER_QUANTITY            =        rec.FIXED_ORDER_QUANTITY,
                FIXED_DAYS_SUPPLY               =        rec.FIXED_DAYS_SUPPLY,
                MAXIMUM_ORDER_QUANTITY          =        rec.MAXIMUM_ORDER_QUANTITY,
                ATP_RULE_ID                     =        rec.ATP_RULE_ID,
                PICKING_RULE_ID                 =        rec.PICKING_RULE_ID,
                RESERVABLE_TYPE                 =        rec.RESERVABLE_TYPE,
                POSITIVE_MEASUREMENT_ERROR      =        rec.POSITIVE_MEASUREMENT_ERROR,
                NEGATIVE_MEASUREMENT_ERROR      =        rec.NEGATIVE_MEASUREMENT_ERROR,
                ENGINEERING_ECN_CODE            =        rec.ENGINEERING_ECN_CODE,
                ENGINEERING_ITEM_ID             =        rec.ENGINEERING_ITEM_ID,
                ENGINEERING_DATE                =        rec.ENGINEERING_DATE,
                SERVICE_STARTING_DELAY          =        rec.SERVICE_STARTING_DELAY,
                SERVICEABLE_COMPONENT_FLAG      =        rec.SERVICEABLE_COMPONENT_FLAG,
                SERVICEABLE_PRODUCT_FLAG        =        rec.SERVICEABLE_PRODUCT_FLAG,
                BASE_WARRANTY_SERVICE_ID        =        rec.BASE_WARRANTY_SERVICE_ID,
                PAYMENT_TERMS_ID                =        rec.PAYMENT_TERMS_ID,
                PREVENTIVE_MAINTENANCE_FLAG     =        rec.PREVENTIVE_MAINTENANCE_FLAG,
                PRIMARY_SPECIALIST_ID           =        rec.PRIMARY_SPECIALIST_ID,
                SECONDARY_SPECIALIST_ID         =        rec.SECONDARY_SPECIALIST_ID,
                SERVICEABLE_ITEM_CLASS_ID       =        rec.SERVICEABLE_ITEM_CLASS_ID,
                TIME_BILLABLE_FLAG              =        rec.TIME_BILLABLE_FLAG,
                MATERIAL_BILLABLE_FLAG          =        rec.MATERIAL_BILLABLE_FLAG,
                EXPENSE_BILLABLE_FLAG           =        rec.EXPENSE_BILLABLE_FLAG,
                PRORATE_SERVICE_FLAG            =        rec.PRORATE_SERVICE_FLAG,
                COVERAGE_SCHEDULE_ID            =        rec.COVERAGE_SCHEDULE_ID,
                SERVICE_DURATION_PERIOD_CODE    =        rec.SERVICE_DURATION_PERIOD_CODE,
                SERVICE_DURATION                =        rec.SERVICE_DURATION,
                MAX_WARRANTY_AMOUNT             =        rec.MAX_WARRANTY_AMOUNT,
                RESPONSE_TIME_PERIOD_CODE       =        rec.RESPONSE_TIME_PERIOD_CODE,
                RESPONSE_TIME_VALUE             =        rec.RESPONSE_TIME_VALUE,
                NEW_REVISION_CODE               =        rec.NEW_REVISION_CODE,
                TAX_CODE                        =        rec.TAX_CODE,
                MUST_USE_APPROVED_VENDOR_FLAG   =        rec.MUST_USE_APPROVED_VENDOR_FLAG,
                SAFETY_STOCK_BUCKET_DAYS        =        rec.SAFETY_STOCK_BUCKET_DAYS,
                AUTO_REDUCE_MPS                 =        rec.AUTO_REDUCE_MPS,
                COSTING_ENABLED_FLAG            =        rec.COSTING_ENABLED_FLAG,
                INVOICEABLE_ITEM_FLAG           =        rec.INVOICEABLE_ITEM_FLAG,
                INVOICE_ENABLED_FLAG            =        rec.INVOICE_ENABLED_FLAG,
                OUTSIDE_OPERATION_FLAG          =        rec.OUTSIDE_OPERATION_FLAG,
                OUTSIDE_OPERATION_UOM_TYPE      =        rec.OUTSIDE_OPERATION_UOM_TYPE,
                AUTO_CREATED_CONFIG_FLAG        =        rec.AUTO_CREATED_CONFIG_FLAG,
                CYCLE_COUNT_ENABLED_FLAG        =        rec.CYCLE_COUNT_ENABLED_FLAG,
                MODEL_CONFIG_CLAUSE_NAME        =        rec.MODEL_CONFIG_CLAUSE_NAME,
                SHIP_MODEL_COMPLETE_FLAG        =        rec.SHIP_MODEL_COMPLETE_FLAG,
                MRP_PLANNING_CODE               =        rec.MRP_PLANNING_CODE,
                RETURN_INSPECTION_REQUIREMENT   =        rec.RETURN_INSPECTION_REQUIREMENT,
                REQUEST_ID                      =        req_id,
                PROGRAM_APPLICATION_ID          =        prg_appid,
                PROGRAM_ID                      =        prg_id,
                PROGRAM_UPDATE_DATE             =        l_sysdate,
                REPETITIVE_PLANNING_FLAG        =        rec.REPETITIVE_PLANNING_FLAG,
                QTY_RCV_EXCEPTION_CODE          =        rec.QTY_RCV_EXCEPTION_CODE,
                MRP_CALCULATE_ATP_FLAG          =        rec.MRP_CALCULATE_ATP_FLAG,
                ITEM_TYPE                       =        rec.ITEM_TYPE,
                WARRANTY_VENDOR_ID              =        rec.WARRANTY_VENDOR_ID,
                ATO_FORECAST_CONTROL            =        rec.ATO_FORECAST_CONTROL,
                RELEASE_TIME_FENCE_CODE         =        rec.RELEASE_TIME_FENCE_CODE,
                RELEASE_TIME_FENCE_DAYS         =        rec.RELEASE_TIME_FENCE_DAYS,
                CONTAINER_ITEM_FLAG             =        rec.CONTAINER_ITEM_FLAG,
                CONTAINER_TYPE_CODE             =        rec.CONTAINER_TYPE_CODE,
                INTERNAL_VOLUME                 =        rec.INTERNAL_VOLUME,
                MAXIMUM_LOAD_WEIGHT             =        rec.MAXIMUM_LOAD_WEIGHT,
                MINIMUM_FILL_PERCENT            =        rec.MINIMUM_FILL_PERCENT,
                VEHICLE_ITEM_FLAG               =        rec.VEHICLE_ITEM_FLAG,

         CHECK_SHORTAGES_FLAG           =  rec.CHECK_SHORTAGES_FLAG
      ,  EFFECTIVITY_CONTROL            =  rec.EFFECTIVITY_CONTROL

      ,   OVERCOMPLETION_TOLERANCE_TYPE =  rec.OVERCOMPLETION_TOLERANCE_TYPE
      ,   OVERCOMPLETION_TOLERANCE_VALUE        =  rec.OVERCOMPLETION_TOLERANCE_VALUE
      ,   OVER_SHIPMENT_TOLERANCE       =  rec.OVER_SHIPMENT_TOLERANCE
      ,   UNDER_SHIPMENT_TOLERANCE      =  rec.UNDER_SHIPMENT_TOLERANCE
      ,   OVER_RETURN_TOLERANCE         =  rec.OVER_RETURN_TOLERANCE
      ,   UNDER_RETURN_TOLERANCE        =  rec.UNDER_RETURN_TOLERANCE
      ,   EQUIPMENT_TYPE                =  rec.EQUIPMENT_TYPE
      ,   RECOVERED_PART_DISP_CODE      =  rec.RECOVERED_PART_DISP_CODE
      ,   DEFECT_TRACKING_ON_FLAG       =  rec.DEFECT_TRACKING_ON_FLAG
      ,   EVENT_FLAG                    =  rec.EVENT_FLAG
      ,   ELECTRONIC_FLAG               =  rec.ELECTRONIC_FLAG
      ,   DOWNLOADABLE_FLAG             =  rec.DOWNLOADABLE_FLAG
      ,   VOL_DISCOUNT_EXEMPT_FLAG      =  rec.VOL_DISCOUNT_EXEMPT_FLAG
      ,   COUPON_EXEMPT_FLAG            =  rec.COUPON_EXEMPT_FLAG
      ,   COMMS_NL_TRACKABLE_FLAG       =  rec.COMMS_NL_TRACKABLE_FLAG
      ,   ASSET_CREATION_CODE           =  rec.ASSET_CREATION_CODE
      ,   COMMS_ACTIVATION_REQD_FLAG    =  rec.COMMS_ACTIVATION_REQD_FLAG
      ,   ORDERABLE_ON_WEB_FLAG         =  rec.ORDERABLE_ON_WEB_FLAG
      ,   BACK_ORDERABLE_FLAG           =  rec.BACK_ORDERABLE_FLAG
      --
      ,  WEB_STATUS                     =  rec.WEB_STATUS
      ,  INDIVISIBLE_FLAG               =  rec.INDIVISIBLE_FLAG
      --
      ,   DIMENSION_UOM_CODE            =  rec.DIMENSION_UOM_CODE
      ,   UNIT_LENGTH                   =  rec.UNIT_LENGTH
      ,   UNIT_WIDTH                    =  rec.UNIT_WIDTH
      ,   UNIT_HEIGHT                   =  rec.UNIT_HEIGHT
      ,   BULK_PICKED_FLAG              =  rec.BULK_PICKED_FLAG
      ,   LOT_STATUS_ENABLED            =  rec.LOT_STATUS_ENABLED
      ,   DEFAULT_LOT_STATUS_ID         =  rec.DEFAULT_LOT_STATUS_ID
      ,   SERIAL_STATUS_ENABLED         =  rec.SERIAL_STATUS_ENABLED
      ,   DEFAULT_SERIAL_STATUS_ID      =  rec.DEFAULT_SERIAL_STATUS_ID
      ,   LOT_SPLIT_ENABLED             =  rec.LOT_SPLIT_ENABLED
      ,   LOT_MERGE_ENABLED             =  rec.LOT_MERGE_ENABLED
      ,   INVENTORY_CARRY_PENALTY       =  rec.INVENTORY_CARRY_PENALTY
      ,   OPERATION_SLACK_PENALTY       =  rec.OPERATION_SLACK_PENALTY
      ,   FINANCING_ALLOWED_FLAG        =  rec.FINANCING_ALLOWED_FLAG
      ,  EAM_ITEM_TYPE                  =  rec.EAM_ITEM_TYPE
      ,  EAM_ACTIVITY_TYPE_CODE         =  rec.EAM_ACTIVITY_TYPE_CODE
      ,  EAM_ACTIVITY_CAUSE_CODE        =  rec.EAM_ACTIVITY_CAUSE_CODE
      ,  EAM_ACT_NOTIFICATION_FLAG      =  rec.EAM_ACT_NOTIFICATION_FLAG
      ,  EAM_ACT_SHUTDOWN_STATUS        =  rec.EAM_ACT_SHUTDOWN_STATUS
      ,  DUAL_UOM_CONTROL               =  rec.DUAL_UOM_CONTROL
      ,  SECONDARY_UOM_CODE             =  rec.SECONDARY_UOM_CODE
      ,  DUAL_UOM_DEVIATION_HIGH        =  rec.DUAL_UOM_DEVIATION_HIGH
      ,  DUAL_UOM_DEVIATION_LOW         =  rec.DUAL_UOM_DEVIATION_LOW
      --
      -- Service Item, Warranty, Usage flag attributes are dependent on
      -- and derived from Contract Item Type; supported for view only.
      --
      ,  SERVICE_ITEM_FLAG              =  DECODE( rec.CONTRACT_ITEM_TYPE_CODE,
              'SERVICE'      , 'Y',
              'WARRANTY'     , 'Y', 'N' )
      ,  VENDOR_WARRANTY_FLAG           =  DECODE( rec.CONTRACT_ITEM_TYPE_CODE, 'WARRANTY', 'Y', 'N' )
      ,  USAGE_ITEM_FLAG                =  DECODE( rec.CONTRACT_ITEM_TYPE_CODE, 'USAGE', 'Y', NULL )
      --
      ,  CONTRACT_ITEM_TYPE_CODE        =  rec.CONTRACT_ITEM_TYPE_CODE
      ,  SUBSCRIPTION_DEPEND_FLAG       =  rec.SUBSCRIPTION_DEPEND_FLAG
      --
      ,  SERV_REQ_ENABLED_CODE          =  rec.SERV_REQ_ENABLED_CODE
      ,  SERV_BILLING_ENABLED_FLAG      =  rec.SERV_BILLING_ENABLED_FLAG
      ,  SERV_IMPORTANCE_LEVEL          =  rec.SERV_IMPORTANCE_LEVEL
      ,  PLANNED_INV_POINT_FLAG         =  rec.PLANNED_INV_POINT_FLAG
      ,  LOT_TRANSLATE_ENABLED          =  rec.LOT_TRANSLATE_ENABLED
      ,  DEFAULT_SO_SOURCE_TYPE         =  rec.DEFAULT_SO_SOURCE_TYPE
      ,  CREATE_SUPPLY_FLAG             =  rec.CREATE_SUPPLY_FLAG
      ,  SUBSTITUTION_WINDOW_CODE       =  rec.SUBSTITUTION_WINDOW_CODE
      ,  SUBSTITUTION_WINDOW_DAYS       =  rec.SUBSTITUTION_WINDOW_DAYS
--Added as part of 11.5.9
      ,  LOT_SUBSTITUTION_ENABLED       =  rec.LOT_SUBSTITUTION_ENABLED
      ,  MINIMUM_LICENSE_QUANTITY       =  rec.MINIMUM_LICENSE_QUANTITY
      ,  EAM_ACTIVITY_SOURCE_CODE       =  rec.EAM_ACTIVITY_SOURCE_CODE
      ,  IB_ITEM_INSTANCE_CLASS         =  rec.IB_ITEM_INSTANCE_CLASS
      ,  CONFIG_MODEL_TYPE              =  rec.CONFIG_MODEL_TYPE
      --2777118:IOI Lifecycle and Phase validations
      ,CURRENT_PHASE_ID                 = rec.CURRENT_PHASE_ID
      --2805950 Missed placing lifecycle id during 2777118
      ,LIFECYCLE_ID                     = rec.LIFECYCLE_ID
--Added as part of 11.5.10
      ,  TRACKING_QUANTITY_IND          =  rec.TRACKING_QUANTITY_IND
      ,  ONT_PRICING_QTY_SOURCE         =  rec.ONT_PRICING_QTY_SOURCE
      ,  SECONDARY_DEFAULT_IND          =  rec.SECONDARY_DEFAULT_IND
      ,  CONFIG_ORGS                    =  rec.CONFIG_ORGS
      ,  CONFIG_MATCH                   =  rec.CONFIG_MATCH
        ,VMI_MINIMUM_UNITS                 = rec.VMI_MINIMUM_UNITS
        ,VMI_MINIMUM_DAYS                  = rec.VMI_MINIMUM_DAYS
        ,VMI_MAXIMUM_UNITS                 = rec.VMI_MAXIMUM_UNITS
        ,VMI_MAXIMUM_DAYS                  = rec.VMI_MAXIMUM_DAYS
        ,VMI_FIXED_ORDER_QUANTITY          = rec.VMI_FIXED_ORDER_QUANTITY
        ,SO_AUTHORIZATION_FLAG             = rec.SO_AUTHORIZATION_FLAG
        ,CONSIGNED_FLAG                    = rec.CONSIGNED_FLAG
        ,ASN_AUTOEXPIRE_FLAG               = rec.ASN_AUTOEXPIRE_FLAG
        ,VMI_FORECAST_TYPE                 = rec.VMI_FORECAST_TYPE
        ,FORECAST_HORIZON                  = rec.FORECAST_HORIZON
        ,EXCLUDE_FROM_BUDGET_FLAG          = rec.EXCLUDE_FROM_BUDGET_FLAG
        ,DAYS_TGT_INV_SUPPLY               = rec.DAYS_TGT_INV_SUPPLY
        ,DAYS_TGT_INV_WINDOW               = rec.DAYS_TGT_INV_WINDOW
        ,DAYS_MAX_INV_SUPPLY               = rec.DAYS_MAX_INV_SUPPLY
        ,DAYS_MAX_INV_WINDOW               = rec.DAYS_MAX_INV_WINDOW
        ,DRP_PLANNED_FLAG                  = rec.DRP_PLANNED_FLAG
        ,CRITICAL_COMPONENT_FLAG           = rec.CRITICAL_COMPONENT_FLAG
        ,CONTINOUS_TRANSFER                = rec.CONTINOUS_TRANSFER
        ,CONVERGENCE                       = rec.CONVERGENCE
        ,DIVERGENCE                        = rec.DIVERGENCE
        ,OBJECT_VERSION_NUMBER             = NVL(OBJECT_VERSION_NUMBER,1)+1
         --Start Bug 3713912
        ,LOT_DIVISIBLE_FLAG                = rec.LOT_DIVISIBLE_FLAG
        ,GRADE_CONTROL_FLAG                = rec.GRADE_CONTROL_FLAG
        ,DEFAULT_GRADE                     = rec.DEFAULT_GRADE
        ,CHILD_LOT_FLAG                    = rec.CHILD_LOT_FLAG
        ,PARENT_CHILD_GENERATION_FLAG      = rec.PARENT_CHILD_GENERATION_FLAG
        ,CHILD_LOT_PREFIX                  = rec.CHILD_LOT_PREFIX
        ,CHILD_LOT_STARTING_NUMBER         = rec.CHILD_LOT_STARTING_NUMBER
        ,CHILD_LOT_VALIDATION_FLAG         = rec.CHILD_LOT_VALIDATION_FLAG
        ,COPY_LOT_ATTRIBUTE_FLAG           = rec.COPY_LOT_ATTRIBUTE_FLAG
        ,RECIPE_ENABLED_FLAG               = rec.RECIPE_ENABLED_FLAG
        ,PROCESS_QUALITY_ENABLED_FLAG      = rec.PROCESS_QUALITY_ENABLED_FLAG
        ,PROCESS_EXECUTION_ENABLED_FLAG    = rec.PROCESS_EXECUTION_ENABLED_FLAG
        ,PROCESS_COSTING_ENABLED_FLAG      = rec.PROCESS_COSTING_ENABLED_FLAG
        ,PROCESS_SUPPLY_SUBINVENTORY       = rec.PROCESS_SUPPLY_SUBINVENTORY
        ,PROCESS_SUPPLY_LOCATOR_ID         = rec.PROCESS_SUPPLY_LOCATOR_ID
        ,PROCESS_YIELD_SUBINVENTORY        = rec.PROCESS_YIELD_SUBINVENTORY
        ,PROCESS_YIELD_LOCATOR_ID          = rec.PROCESS_YIELD_LOCATOR_ID
        ,HAZARDOUS_MATERIAL_FLAG           = rec.HAZARDOUS_MATERIAL_FLAG
        ,CAS_NUMBER                        = rec.CAS_NUMBER
        ,RETEST_INTERVAL                   = rec.RETEST_INTERVAL
        ,EXPIRATION_ACTION_INTERVAL        = rec.EXPIRATION_ACTION_INTERVAL
        ,EXPIRATION_ACTION_CODE            = rec.EXPIRATION_ACTION_CODE
        ,MATURITY_DAYS                     = rec.MATURITY_DAYS
        ,HOLD_DAYS                         = rec.HOLD_DAYS
     --End Bug 3713912
     -- R12 Enhacement
    ,CHARGE_PERIODICITY_CODE           = rec.CHARGE_PERIODICITY_CODE
    ,REPAIR_LEADTIME                   = rec.REPAIR_LEADTIME
    ,REPAIR_YIELD                      = rec.REPAIR_YIELD
    ,PREPOSITION_POINT                 = rec.PREPOSITION_POINT
    ,REPAIR_PROGRAM                    = rec.REPAIR_PROGRAM
    ,SUBCONTRACTING_COMPONENT          = rec.SUBCONTRACTING_COMPONENT
    ,OUTSOURCED_ASSEMBLY               = rec.OUTSOURCED_ASSEMBLY
    /* New attributes for R12 FPC */
    ,GDSN_OUTBOUND_ENABLED_FLAG        = rec.GDSN_OUTBOUND_ENABLED_FLAG
    ,TRADE_ITEM_DESCRIPTOR             = rec.TRADE_ITEM_DESCRIPTOR
    ,STYLE_ITEM_FLAG           = rec.STYLE_ITEM_FLAG
        ,STYLE_ITEM_ID                     = rec.STYLE_ITEM_ID
    --serial_tagging enh -- bug 9913552

        ,serial_tagging_flag               = Decode (INV_SERIAL_NUMBER_PUB.is_serial_tagged(rec.inventory_item_id, rec.organization_id),2,'Y')

      WHERE

         MTLSYSI.rowid = rec.msi_rowid;

      --
      -- R11.5 MLS
      --
      -- bug 10373720 , set last_update_date = sysdate,
      -- old Nvl(rec.LAST_UPDATE_DATE,l_sysdate),
      ---
      update MTL_SYSTEM_ITEMS_TL
      set
         DESCRIPTION         =  rec.DESCRIPTION,
         LONG_DESCRIPTION    =  rec.LONG_DESCRIPTION,
         LAST_UPDATE_DATE    =  l_sysdate,
         LAST_UPDATED_BY     =  user_id,
         LAST_UPDATE_LOGIN   =  login_id,
         SOURCE_LANG         =  userenv('LANG')
      where
             INVENTORY_ITEM_ID = rec.INVENTORY_ITEM_ID
         and ORGANIZATION_ID = rec.ORGANIZATION_ID
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  --Bug: 3899614,2948014 Updating the cst tables if asset flag is changed
      IF(rec.inv_asset_flag <> rec.INVENTORY_ASSET_FLAG )THEN
           INV_ITEM_PVT.Delete_Cost_Details(
            P_Item_Id             => rec.inventory_item_id
           ,P_Org_Id              => rec.organization_id
           ,P_Asset_Flag          => rec.inventory_asset_flag
           ,P_Cost_Txn            => NULL
           ,P_Last_Updated_By     => user_id
           ,P_Last_Updated_Login  => login_id);
           IF (NVL(rec.inv_asset_flag,'N')='N' AND rec.INVENTORY_ASSET_FLAG='Y' )THEN
             IF rec.planning_make_buy_code IN (1,2) THEN
               l_cst_item_type := rec.planning_make_buy_code;
             ELSE
               l_cst_item_type := 2;
             END IF;
             INVIDIT2.Insert_Cost_Details (
                 x_item_id         => rec.inventory_item_id
                ,x_org_id          => rec.organization_id
                ,x_inv_install     => INV_Item_Util.g_Appl_Inst.INV
                ,x_last_updated_by => user_id
                ,x_cst_item_type   => l_cst_item_type );
           END IF;
       END IF;
   --Bug:3899614 end


      END LOOP;  -- C_lock_msi_records

      /* commit for debugging ONLY */
      -- COMMIT;

   EXCEPTION

      when obj_version_error THEN -- bug 5870114
        update mtl_system_items_interface
          set process_flag = 3,
              request_id = req_id,
              PROGRAM_APPLICATION_ID = prg_appid,
              PROGRAM_ID = prg_id,
              PROGRAM_UPDATE_DATE             =        l_sysdate,
              last_update_login = login_id
        where inventory_item_id = item_rec.inventory_item_id
          and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000)
          and process_flag = 4;
        -- Returning clause is commented and change to select clause a part of bug 5870114 as it was throwing TOO_MANY_RECORDS errors

       SELECT organization_id,   transaction_id INTO
              l_org_id,l_transaction_id
       FROM   mtl_system_items_interface
       WHERE inventory_item_id = item_rec.inventory_item_id
         and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000)
         and process_flag = 3 AND ROWNUM=1;

       dumm_status  := INVPUOPI.mtl_log_interface_err(
                                         l_org_id,
                                     user_id,
                                     login_id,
                                     prg_appid,
                                     prg_id,
                                     req_id,
                                     l_transaction_id,
                                     err_text,
                                     'INVENTORY_ITEM_ID',
                                     'MTL_SYSTEM_ITEMS',
                                     'INV_IOI_RECORD_LOCKED',
                                     err_text);
      when resource_busy then

         -- 2810346: Lock failed record details into log
         -- Updating the interface records and then logging errors
         -- Earlier it was log and then update. Doing this to avoid a fetch.

         update mtl_system_items_interface
         set process_flag = 3,
         request_id = req_id,
         PROGRAM_APPLICATION_ID          =        prg_appid,
         PROGRAM_ID                      =        prg_id,
         PROGRAM_UPDATE_DATE             =        l_sysdate,
         last_update_login = login_id
         where inventory_item_id = item_rec.inventory_item_id
         and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000)
         and process_flag = 4;
         --RETURNING organization_id,transaction_id INTO l_org_id,l_transaction_id;

        SELECT organization_id,   transaction_id INTO l_org_id,l_transaction_id
        FROM mtl_system_items_interface
        WHERE inventory_item_id = item_rec.inventory_item_id
          and (set_process_id = xset_id or set_process_id = xset_id +1000000000000)
          and process_flag = 3 AND ROWNUM=1;

       dumm_status  := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prg_appid,
                                prg_id,
                                req_id,
                                l_transaction_id,
                                err_text,
                                'INVENTORY_ITEM_ID',
                                'MTL_SYSTEM_ITEMS',
                                'INV_IOI_RECORD_LOCKED',
                                err_text);
                  /* commit for debugging ONLY */
                  -- COMMIT;

      when OTHERS then
         --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
    IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info(
            Substr(
              'when OTHERS exception raised in inproit_process_item_update' ||
              ' - Cursor C_lock_msi_records '                               ||
              SQLCODE ||
              ' - '   ||
              SQLERRM,1,240));
    END IF;
        return (1);

   END;

   END LOOP;  -- C_msii_processed_records

  -- Start fix for bug 7017691 Issue #3
  --6417028 propagate item number update to all org hierarchies
  FOR item_csr IN c_item_number_updated
  LOOP
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: Update: III' || item_csr.inventory_item_id ||
'segment1' || item_csr.segment1);
   END IF;

   UPDATE mtl_system_items_b
      SET segment1 = item_csr.segment1,
          segment2 = item_csr.segment2,
          segment3 = item_csr.segment3,
          segment4 = item_csr.segment4,
          segment5 = item_csr.segment5,
          segment6 = item_csr.segment6,
          segment7 = item_csr.segment7,
          segment8 = item_csr.segment8,
          segment9 = item_csr.segment9,
          segment10 = item_csr.segment10,
          segment11 = item_csr.segment11,
          segment12 = item_csr.segment12,
          segment13 = item_csr.segment13,
          segment14 = item_csr.segment14,
          segment15 = item_csr.segment15,
          segment16 = item_csr.segment16,
          segment17 = item_csr.segment17,
          segment18 = item_csr.segment18,
          segment19 = item_csr.segment19,
          segment20 = item_csr.segment20
    WHERE inventory_item_id = item_csr.inventory_item_id;
  END LOOP;
  -- End fix for bug 7017691 Issue #3

  -- Start fix for bug 7017691 Issue #4 Move out of the C_msii_processed_records
  -- loop
   FOR cr IN c_ego_intf_rows LOOP
      INVPUTLI.info('Ego Intf Table has rows '||cr.language || ' ' ||cr.column_value);
      UPDATE MTL_SYSTEM_ITEMS_TL
         SET DESCRIPTION = NVL(cr.column_value, DESCRIPTION),
             LAST_UPDATE_DATE = l_sysdate,
             LAST_UPDATED_BY = user_id,
             LAST_UPDATE_LOGIN = login_id
       WHERE inventory_item_id = cr.inventory_item_id
         AND organization_id = cr.organization_id
         AND language = cr.language;
    END LOOP; -- c_ego_intf_rows
    -- End fix for bug 7017691 Issue #4

   --6531937 : Item specific UOM conversion out of loop
   -- Start of Bug 5190184
   FOR UOM_process_rec IN UOM_Process LOOP
      IF ( UOM_process_rec.base_uom_flag = 'Y' ) THEN
         conversion_rate_temp := 1;
      ELSE
          select conversion_rate  into conversion_rate_temp
          from mtl_uom_conversions
          where inventory_item_id = 0
          and uom_code = UOM_process_rec.PUOMCODE;
      END IF;

      l_default_conversion_flag := 'N';

      INSERT INTO mtl_uom_conversions(
       unit_of_measure,
       uom_code,
       uom_class,
       inventory_item_id,
       conversion_rate,
       default_conversion_flag,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by)
     VALUES(
       UOM_process_rec.PUOM,
       UOM_process_rec.PUOMCODE,
       UOM_process_rec.UOMCL,
       UOM_process_rec.INV_ITEM_ID,
       conversion_rate_temp,
       l_default_conversion_flag,
       l_sysdate,
       user_id,
       l_sysdate,
       user_id);
   END LOOP;
   -- End of Bug 5190184

--INVPUTLI.info('INVPPROC: Finished updating record in MSI with MSII record'|| xset_id);

   --2808277 : Start Revision Update support


   FOR rev_rec IN C_rev_processed_records LOOP


      DECLARE
         CURSOR c_lock_rev_record IS
            SELECT ROWID
            FROM   mtl_item_revisions_b
            WHERE  revision_id   = rev_rec.revision_id
         FOR UPDATE of revision_id;

         resource_busy    EXCEPTION;
         PRAGMA EXCEPTION_INIT (resource_busy, -54);
         l_org_id         mtl_system_items_interface.organization_id%TYPE ;
         l_transaction_id mtl_system_items_interface.transaction_id%TYPE;

      BEGIN


         FOR update_rec IN c_lock_rev_record LOOP

            -- bug 10373720, set last_update_date to sysdate instead of picking
            -- from interface
            UPDATE MTL_ITEM_REVISIONS_B
            SET
                DESCRIPTION             = decode(l_INSTALLED_FLAG, 'B', rev_rec.DESCRIPTION, DESCRIPTION),
                CHANGE_NOTICE           = rev_rec.CHANGE_NOTICE,
                ECN_INITIATION_DATE     = rev_rec.ECN_INITIATION_DATE,
                IMPLEMENTATION_DATE     = rev_rec.IMPLEMENTATION_DATE,
                EFFECTIVITY_DATE        = rev_rec.EFFECTIVITY_DATE,
                ATTRIBUTE_CATEGORY      = rev_rec.ATTRIBUTE_CATEGORY,
                ATTRIBUTE1              = rev_rec.ATTRIBUTE1,
                ATTRIBUTE2              = rev_rec.ATTRIBUTE2,
                ATTRIBUTE3              = rev_rec.ATTRIBUTE3,
                ATTRIBUTE4              = rev_rec.ATTRIBUTE4,
                ATTRIBUTE5              = rev_rec.ATTRIBUTE5,
                ATTRIBUTE6              = rev_rec.ATTRIBUTE6,
                ATTRIBUTE7              = rev_rec.ATTRIBUTE7,
                ATTRIBUTE8              = rev_rec.ATTRIBUTE8,
                ATTRIBUTE9              = rev_rec.ATTRIBUTE9,
                ATTRIBUTE10             = rev_rec.ATTRIBUTE10,
                ATTRIBUTE11             = rev_rec.ATTRIBUTE11,
                ATTRIBUTE12             = rev_rec.ATTRIBUTE12,
                ATTRIBUTE13             = rev_rec.ATTRIBUTE13,
                ATTRIBUTE14             = rev_rec.ATTRIBUTE14,
                ATTRIBUTE15             = rev_rec.ATTRIBUTE15,
                LIFECYCLE_ID            = rev_rec.LIFECYCLE_ID,
                CURRENT_PHASE_ID        = rev_rec.CURRENT_PHASE_ID,
                REVISION_LABEL          = rev_rec.REVISION_LABEL,
                REVISION_REASON         = rev_rec.REVISION_REASON,
                REVISED_ITEM_SEQUENCE_ID = rev_rec.REVISED_ITEM_SEQUENCE_ID,
                LAST_UPDATE_DATE        = l_sysdate,
                LAST_UPDATED_BY         = user_id,
                LAST_UPDATE_LOGIN       = login_id,
    /* Bug 4224512 : Incrementing the object version number for each update -Anmurali */
        OBJECT_VERSION_NUMBER   = NVL(OBJECT_VERSION_NUMBER,1)+1
            WHERE rowid = update_rec.rowid;

            -- bug 10373720, set last_update_date to sysdate instead of picking
            -- from interface
            UPDATE mtl_item_revisions_tl
            SET    description       = rev_rec.description,
                   last_update_date  =  l_sysdate,
                   last_updated_by   =  user_id,
                   last_update_login =  login_id,
                   source_lang       =  userenv('LANG')
            WHERE  revision_id = rev_rec.revision_id
            AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

         END LOOP;

      EXCEPTION
         WHEN resource_busy THEN
            UPDATE mtl_item_revisions_interface
            SET    process_flag = 3,
                   request_id = req_id,
                   PROGRAM_APPLICATION_ID          =        prg_appid,
                   PROGRAM_ID                      =        prg_id,
                   PROGRAM_UPDATE_DATE             =        l_sysdate,
                   last_update_login = login_id
         WHERE     rowid = rev_rec.rowid
         RETURNING organization_id,transaction_id INTO l_org_id,l_transaction_id;

         dumm_status  := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prg_appid,
                                prg_id,
                                req_id,
                                l_transaction_id,
                                err_text,
                                'INVENTORY_ITEM_ID',
                                'MTL_SYSTEM_ITEMS',
                                'INV_IOI_RECORD_LOCKED',
                                err_text);
          WHEN OTHERS THEN
             --bug #4251913: Included SQLCODE and SQLERRM to trap exception messages.
         IF l_inv_debug_level IN(101, 102) THEN
                 INVPUTLI.info(
                Substr(
               'when OTHERS exception raised in inproit_process_item_update ' ||
               '- Cursor c_lock_rev_record ' ||
                SQLCODE                      ||
                ' - '                        ||
                SQLERRM,1,240));
         END IF;
             return (1);
      END;
   END LOOP;
   --2808277 : End Revision Update support

--INVPUTLI.info('INVPPROC: Finished updating record in MSI with MSII record'|| xset_id);

-- set process_flags to 7

        table_name := 'MTL_SYSTEM_ITEMS_INTERFACE';
        update MTL_SYSTEM_ITEMS_INTERFACE
        set process_flag = 7,
          request_id = req_id,
          PROGRAM_APPLICATION_ID          =        prg_appid,
          PROGRAM_ID                      =        prg_id,
          PROGRAM_UPDATE_DATE             =        l_sysdate,
          last_update_login = login_id
        where process_flag = 4
        and transaction_type in ('UPDATE','AUTO_CHILD')
        and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000);

        --2808277 : Start Revision Update support
        table_name := 'MTL_ITEM_REVISIONS_INTERFACE';

        update MTL_ITEM_REVISIONS_INTERFACE
        set process_flag           = 7,
            request_id             = nvl(request_id,req_id),
            program_application_id = nvl(program_application_id,prg_appid),
            PROGRAM_ID             = nvl(PROGRAM_ID,prg_id),
            PROGRAM_UPDATE_DATE    = nvl(PROGRAM_UPDATE_DATE,l_sysdate),
            LAST_UPDATE_LOGIN      = nvl(LAST_UPDATE_LOGIN,login_id)
        where process_flag         = 4
        and   transaction_type     =  'UPDATE'
        and (set_process_id = xset_id or set_process_id = xset_id + 1000000000000);
        --2808277 : Start Revision Update support
    INV_EGO_REVISION_VALIDATE.apply_default_uda_values(xset_id,commit_flag);  /*Added to fix Bug 8359046*/
   return (0);

EXCEPTION

   when OTHERS then
      --dbms_output.put_line(sqlerrm);
      --bug #4251913 : Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info(
         Substr(
            'when OTHERS exception raised in inproit_process_item_update ' ||
             SQLCODE ||
             ' - '   ||
             SQLERRM,1,240));
      END IF;
      return (1);

END inproit_process_item_update;


FUNCTION set_process_flag3
(
   row_id       ROWID,
   user_id         NUMBER          := -1,
   login_id        NUMBER          := -1,
   prog_appid      NUMBER          := -1,
   prog_id         NUMBER          := -1,
   reqst_id      NUMBER          := -1
)
return INTEGER
IS
   l_process_flag_3    NUMBER  := 3;

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
       INVPUTLI.info('INVUPD2B: Inside set_process_flag3');
   END IF;
        update MTL_SYSTEM_ITEMS_INTERFACE
        set PROCESS_FLAG = l_process_flag_3,
          request_id = reqst_id,
          PROGRAM_APPLICATION_ID = prog_appid,
          PROGRAM_ID = prog_id,
          last_update_login = login_id
        where ROWID = row_id;
        return (0);

EXCEPTION

   when OTHERS then
      --bug #4251913: Included SQLCODE and SQLERRM to trap exception messages.
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(
             Substr(
            'when OTHERS exception raised in set_process_flag3 ' ||
            SQLCODE ||
            ' - '   ||
            SQLERRM,1,240));
      END IF;
      /*End  Bug: 4667452*/
      return (1);

END set_process_flag3;


FUNCTION get_message
(
   msg_name          VARCHAR2
,  error_text   OUT NOCOPY VARCHAR2
)
return INTEGER
IS
    l_inv_debug_level   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVUPD2B: inside get_message');
   END IF;
   FND_MESSAGE.SET_NAME('INV', SUBSTRB(msg_name, 1,30));
   error_text := FND_MESSAGE.GET;
   return (0);

EXCEPTION

   when OTHERS then
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info( SUBSTRB('get_message: ' || SQLERRM, 1, 240) );
      END IF;
      return (1);

END get_message;


end INVUPD2B;

/
