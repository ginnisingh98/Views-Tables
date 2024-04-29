--------------------------------------------------------
--  DDL for Package Body INV_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_GRP" AS
/* $Header: INVGITMB.pls 120.7.12010000.8 2011/12/01 11:14:08 nendrapu ship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------

G_PKG_NAME      CONSTANT  VARCHAR2(30)  := 'INV_ITEM_GRP';

g_Null_CHAR     VARCHAR2(1)  :=  NULL;
g_Null_NUM      NUMBER       :=  NULL;
g_Null_DATE     DATE         :=  NULL;

-- Values used in IOI to indicate the meaning of NULL.
--
g_Upd_Null_CHAR     VARCHAR2(1);
g_Upd_Null_NUM      NUMBER;
g_Upd_Null_DATE     DATE;
-- Bug 8442016
G_PS_IN_PROCESS              CONSTANT NUMBER := 2;
G_PS_GENERIC_ERROR           CONSTANT NUMBER := 3;
-- Bug 8442016
-- ------------------------------------------------------
-- ------------------- Global cursors -------------------
-- ------------------------------------------------------

-- Item cursor for Item_GRP API
--
CURSOR Item_csr
(
   p_Item_ID        IN   NUMBER
,  p_Org_ID         IN   NUMBER
)
RETURN Item_rec_type
IS
SELECT
  MSI.ORGANIZATION_ID
, MP.ORGANIZATION_CODE
, MSI.INVENTORY_ITEM_ID
, MSI.CONCATENATED_SEGMENTS    ITEM_NUMBER
, MSI.SEGMENT1
, MSI.SEGMENT2
, MSI.SEGMENT3
, MSI.SEGMENT4
, MSI.SEGMENT5
, MSI.SEGMENT6
, MSI.SEGMENT7
, MSI.SEGMENT8
, MSI.SEGMENT9
, MSI.SEGMENT10
, MSI.SEGMENT11
, MSI.SEGMENT12
, MSI.SEGMENT13
, MSI.SEGMENT14
, MSI.SEGMENT15
, MSI.SEGMENT16
, MSI.SEGMENT17
, MSI.SEGMENT18
, MSI.SEGMENT19
, MSI.SEGMENT20
, MSI.SUMMARY_FLAG
, MSI.ENABLED_FLAG
, MSI.START_DATE_ACTIVE
, MSI.END_DATE_ACTIVE
, MSI.DESCRIPTION
, MSI.LONG_DESCRIPTION
, MSI.PRIMARY_UOM_CODE
, MSI.PRIMARY_UNIT_OF_MEASURE
, MSI.ITEM_TYPE
, MSI.INVENTORY_ITEM_STATUS_CODE
, MSI.ALLOWED_UNITS_LOOKUP_CODE
, MSI.ITEM_CATALOG_GROUP_ID
, MSI.CATALOG_STATUS_FLAG
, MSI.INVENTORY_ITEM_FLAG
, MSI.STOCK_ENABLED_FLAG
, MSI.MTL_TRANSACTIONS_ENABLED_FLAG
, MSI.CHECK_SHORTAGES_FLAG
, MSI.REVISION_QTY_CONTROL_CODE
, MSI.RESERVABLE_TYPE
, MSI.SHELF_LIFE_CODE
, MSI.SHELF_LIFE_DAYS
, MSI.CYCLE_COUNT_ENABLED_FLAG
, MSI.NEGATIVE_MEASUREMENT_ERROR
, MSI.POSITIVE_MEASUREMENT_ERROR
, MSI.LOT_CONTROL_CODE
, MSI.AUTO_LOT_ALPHA_PREFIX
, MSI.START_AUTO_LOT_NUMBER
, MSI.SERIAL_NUMBER_CONTROL_CODE
, MSI.AUTO_SERIAL_ALPHA_PREFIX
, MSI.START_AUTO_SERIAL_NUMBER
, MSI.LOCATION_CONTROL_CODE
, MSI.RESTRICT_SUBINVENTORIES_CODE
, MSI.RESTRICT_LOCATORS_CODE
, MSI.BOM_ENABLED_FLAG
, MSI.BOM_ITEM_TYPE
, MSI.BASE_ITEM_ID
, MSI.EFFECTIVITY_CONTROL
, MSI.ENG_ITEM_FLAG
, MSI.ENGINEERING_ECN_CODE
, MSI.ENGINEERING_ITEM_ID
, MSI.ENGINEERING_DATE
, MSI.PRODUCT_FAMILY_ITEM_ID
, MSI.AUTO_CREATED_CONFIG_FLAG
, MSI.MODEL_CONFIG_CLAUSE_NAME
, MSI.COSTING_ENABLED_FLAG
, MSI.INVENTORY_ASSET_FLAG
, MSI.DEFAULT_INCLUDE_IN_ROLLUP_FLAG
, MSI.COST_OF_SALES_ACCOUNT
, MSI.STD_LOT_SIZE
, MSI.PURCHASING_ITEM_FLAG
, MSI.PURCHASING_ENABLED_FLAG
, MSI.MUST_USE_APPROVED_VENDOR_FLAG
, MSI.ALLOW_ITEM_DESC_UPDATE_FLAG
, MSI.RFQ_REQUIRED_FLAG
, MSI.OUTSIDE_OPERATION_FLAG
, MSI.OUTSIDE_OPERATION_UOM_TYPE
, MSI.TAXABLE_FLAG
, MSI.PURCHASING_TAX_CODE
, MSI.RECEIPT_REQUIRED_FLAG
, MSI.INSPECTION_REQUIRED_FLAG
, MSI.BUYER_ID
, MSI.UNIT_OF_ISSUE
, MSI.RECEIVE_CLOSE_TOLERANCE
, MSI.INVOICE_CLOSE_TOLERANCE
, MSI.UN_NUMBER_ID
, MSI.HAZARD_CLASS_ID
, MSI.LIST_PRICE_PER_UNIT
, MSI.MARKET_PRICE
, MSI.PRICE_TOLERANCE_PERCENT
, MSI.ROUNDING_FACTOR
, MSI.ENCUMBRANCE_ACCOUNT
, MSI.EXPENSE_ACCOUNT
, MSI.ASSET_CATEGORY_ID
, MSI.RECEIPT_DAYS_EXCEPTION_CODE
, MSI.DAYS_EARLY_RECEIPT_ALLOWED
, MSI.DAYS_LATE_RECEIPT_ALLOWED
, MSI.ALLOW_SUBSTITUTE_RECEIPTS_FLAG
, MSI.ALLOW_UNORDERED_RECEIPTS_FLAG
, MSI.ALLOW_EXPRESS_DELIVERY_FLAG
, MSI.QTY_RCV_EXCEPTION_CODE
, MSI.QTY_RCV_TOLERANCE
, MSI.RECEIVING_ROUTING_ID
, MSI.ENFORCE_SHIP_TO_LOCATION_CODE
, MSI.WEIGHT_UOM_CODE
, MSI.UNIT_WEIGHT
, MSI.VOLUME_UOM_CODE
, MSI.UNIT_VOLUME
, MSI.CONTAINER_ITEM_FLAG
, MSI.VEHICLE_ITEM_FLAG
, MSI.CONTAINER_TYPE_CODE
, MSI.INTERNAL_VOLUME
, MSI.MAXIMUM_LOAD_WEIGHT
, MSI.MINIMUM_FILL_PERCENT
, MSI.INVENTORY_PLANNING_CODE
, MSI.PLANNER_CODE
, MSI.PLANNING_MAKE_BUY_CODE
, MSI.MIN_MINMAX_QUANTITY
, MSI.MAX_MINMAX_QUANTITY
, MSI.MINIMUM_ORDER_QUANTITY
, MSI.MAXIMUM_ORDER_QUANTITY
, MSI.ORDER_COST
, MSI.CARRYING_COST
, MSI.SOURCE_TYPE
, MSI.SOURCE_ORGANIZATION_ID
, MSI.SOURCE_SUBINVENTORY
, MSI.MRP_SAFETY_STOCK_CODE
, MSI.SAFETY_STOCK_BUCKET_DAYS
, MSI.MRP_SAFETY_STOCK_PERCENT
, MSI.FIXED_ORDER_QUANTITY
, MSI.FIXED_DAYS_SUPPLY
, MSI.FIXED_LOT_MULTIPLIER
, MSI.MRP_PLANNING_CODE
, MSI.ATO_FORECAST_CONTROL
, MSI.PLANNING_EXCEPTION_SET
, MSI.END_ASSEMBLY_PEGGING_FLAG
, MSI.SHRINKAGE_RATE
, MSI.ROUNDING_CONTROL_TYPE
, MSI.ACCEPTABLE_EARLY_DAYS
, MSI.REPETITIVE_PLANNING_FLAG
, MSI.OVERRUN_PERCENTAGE
, MSI.ACCEPTABLE_RATE_INCREASE
, MSI.ACCEPTABLE_RATE_DECREASE
, MSI.MRP_CALCULATE_ATP_FLAG
, MSI.AUTO_REDUCE_MPS
, MSI.PLANNING_TIME_FENCE_CODE
, MSI.PLANNING_TIME_FENCE_DAYS
, MSI.DEMAND_TIME_FENCE_CODE
, MSI.DEMAND_TIME_FENCE_DAYS
, MSI.RELEASE_TIME_FENCE_CODE
, MSI.RELEASE_TIME_FENCE_DAYS
, MSI.PREPROCESSING_LEAD_TIME
, MSI.FULL_LEAD_TIME
, MSI.POSTPROCESSING_LEAD_TIME
, MSI.FIXED_LEAD_TIME
, MSI.VARIABLE_LEAD_TIME
, MSI.CUM_MANUFACTURING_LEAD_TIME
, MSI.CUMULATIVE_TOTAL_LEAD_TIME
, MSI.LEAD_TIME_LOT_SIZE
, MSI.BUILD_IN_WIP_FLAG
, MSI.WIP_SUPPLY_TYPE
, MSI.WIP_SUPPLY_SUBINVENTORY
, MSI.WIP_SUPPLY_LOCATOR_ID
, MSI.OVERCOMPLETION_TOLERANCE_TYPE
, MSI.OVERCOMPLETION_TOLERANCE_VALUE
, MSI.CUSTOMER_ORDER_FLAG
, MSI.CUSTOMER_ORDER_ENABLED_FLAG
, MSI.SHIPPABLE_ITEM_FLAG
, MSI.INTERNAL_ORDER_FLAG
, MSI.INTERNAL_ORDER_ENABLED_FLAG
, MSI.SO_TRANSACTIONS_FLAG
, MSI.PICK_COMPONENTS_FLAG
, MSI.ATP_FLAG
, MSI.REPLENISH_TO_ORDER_FLAG
, MSI.ATP_RULE_ID
, MSI.ATP_COMPONENTS_FLAG
, MSI.SHIP_MODEL_COMPLETE_FLAG
, MSI.PICKING_RULE_ID
, MSI.COLLATERAL_FLAG
, MSI.DEFAULT_SHIPPING_ORG
, MSI.RETURNABLE_FLAG
, MSI.RETURN_INSPECTION_REQUIREMENT
, MSI.OVER_SHIPMENT_TOLERANCE
, MSI.UNDER_SHIPMENT_TOLERANCE
, MSI.OVER_RETURN_TOLERANCE
, MSI.UNDER_RETURN_TOLERANCE
, MSI.INVOICEABLE_ITEM_FLAG
, MSI.INVOICE_ENABLED_FLAG
, MSI.ACCOUNTING_RULE_ID
, MSI.INVOICING_RULE_ID
, MSI.TAX_CODE
, MSI.SALES_ACCOUNT
, MSI.PAYMENT_TERMS_ID
, MSI.COVERAGE_SCHEDULE_ID
, MSI.SERVICE_DURATION
, MSI.SERVICE_DURATION_PERIOD_CODE
, MSI.SERVICEABLE_PRODUCT_FLAG
, MSI.SERVICE_STARTING_DELAY
, MSI.MATERIAL_BILLABLE_FLAG
, MSI.SERVICEABLE_COMPONENT_FLAG
, MSI.PREVENTIVE_MAINTENANCE_FLAG
, MSI.PRORATE_SERVICE_FLAG
, MSI.WH_UPDATE_DATE
,  MSI.EQUIPMENT_TYPE
, MSI.RECOVERED_PART_DISP_CODE
, MSI.DEFECT_TRACKING_ON_FLAG
, MSI.EVENT_FLAG
, MSI.ELECTRONIC_FLAG
, MSI.DOWNLOADABLE_FLAG
, MSI.VOL_DISCOUNT_EXEMPT_FLAG
, MSI.COUPON_EXEMPT_FLAG
, MSI.COMMS_NL_TRACKABLE_FLAG
, MSI.ASSET_CREATION_CODE
, MSI.COMMS_ACTIVATION_REQD_FLAG
, MSI.WEB_STATUS
, MSI.ORDERABLE_ON_WEB_FLAG
, MSI.BACK_ORDERABLE_FLAG
,  MSI.INDIVISIBLE_FLAG
, MSI.DIMENSION_UOM_CODE
, MSI.UNIT_LENGTH
, MSI.UNIT_WIDTH
, MSI.UNIT_HEIGHT
, MSI.BULK_PICKED_FLAG
, MSI.LOT_STATUS_ENABLED
, MSI.DEFAULT_LOT_STATUS_ID
, MSI.SERIAL_STATUS_ENABLED
, MSI.DEFAULT_SERIAL_STATUS_ID
, MSI.LOT_SPLIT_ENABLED
, MSI.LOT_MERGE_ENABLED
, MSI.INVENTORY_CARRY_PENALTY
, MSI.OPERATION_SLACK_PENALTY
, MSI.FINANCING_ALLOWED_FLAG
,  MSI.EAM_ITEM_TYPE
,  MSI.EAM_ACTIVITY_TYPE_CODE
,  MSI.EAM_ACTIVITY_CAUSE_CODE
,  MSI.EAM_ACT_NOTIFICATION_FLAG
,  MSI.EAM_ACT_SHUTDOWN_STATUS
,  MSI.DUAL_UOM_CONTROL
,  MSI.SECONDARY_UOM_CODE
,  MSI.DUAL_UOM_DEVIATION_HIGH
,  MSI.DUAL_UOM_DEVIATION_LOW
--
,  MSI.SERVICE_ITEM_FLAG
,  MSI.VENDOR_WARRANTY_FLAG
,  MSI.USAGE_ITEM_FLAG
--
,  MSI.CONTRACT_ITEM_TYPE_CODE
,  MSI.SUBSCRIPTION_DEPEND_FLAG
--
,  MSI.SERV_REQ_ENABLED_CODE
,  MSI.SERV_BILLING_ENABLED_FLAG
,  MSI.SERV_IMPORTANCE_LEVEL
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
--
, MSI.ATTRIBUTE_CATEGORY
, MSI.ATTRIBUTE1
, MSI.ATTRIBUTE2
, MSI.ATTRIBUTE3
, MSI.ATTRIBUTE4
, MSI.ATTRIBUTE5
, MSI.ATTRIBUTE6
, MSI.ATTRIBUTE7
, MSI.ATTRIBUTE8
, MSI.ATTRIBUTE9
, MSI.ATTRIBUTE10
, MSI.ATTRIBUTE11
, MSI.ATTRIBUTE12
, MSI.ATTRIBUTE13
, MSI.ATTRIBUTE14
, MSI.ATTRIBUTE15
/* Start Bug 3713912 */
, MSI.ATTRIBUTE16
, MSI.ATTRIBUTE17
, MSI.ATTRIBUTE18
, MSI.ATTRIBUTE19
, MSI.ATTRIBUTE20
, MSI.ATTRIBUTE21
, MSI.ATTRIBUTE22
, MSI.ATTRIBUTE23
, MSI.ATTRIBUTE24
, MSI.ATTRIBUTE25
, MSI.ATTRIBUTE26
, MSI.ATTRIBUTE27
, MSI.ATTRIBUTE28
, MSI.ATTRIBUTE29
, MSI.ATTRIBUTE30
/* End Bug 3713912 */
, MSI.GLOBAL_ATTRIBUTE_CATEGORY
, MSI.GLOBAL_ATTRIBUTE1
, MSI.GLOBAL_ATTRIBUTE2
, MSI.GLOBAL_ATTRIBUTE3
, MSI.GLOBAL_ATTRIBUTE4
, MSI.GLOBAL_ATTRIBUTE5
, MSI.GLOBAL_ATTRIBUTE6
, MSI.GLOBAL_ATTRIBUTE7
, MSI.GLOBAL_ATTRIBUTE8
, MSI.GLOBAL_ATTRIBUTE9
, MSI.GLOBAL_ATTRIBUTE10
, MSI.GLOBAL_ATTRIBUTE11
, MSI.GLOBAL_ATTRIBUTE12
, MSI.GLOBAL_ATTRIBUTE13
, MSI.GLOBAL_ATTRIBUTE14
, MSI.GLOBAL_ATTRIBUTE15
, MSI.GLOBAL_ATTRIBUTE16
, MSI.GLOBAL_ATTRIBUTE17
, MSI.GLOBAL_ATTRIBUTE18
, MSI.GLOBAL_ATTRIBUTE19
, MSI.GLOBAL_ATTRIBUTE20
--
,  MSI.Lifecycle_Id
,  MSI.Current_Phase_Id
--
, MSI.CREATION_DATE
, MSI.CREATED_BY
, MSI.LAST_UPDATE_DATE
, MSI.LAST_UPDATED_BY
, MSI.LAST_UPDATE_LOGIN
, MSI.REQUEST_ID
, MSI.PROGRAM_APPLICATION_ID
, MSI.PROGRAM_ID
, MSI.PROGRAM_UPDATE_DATE
,  MSI.VMI_MINIMUM_UNITS
,  MSI.VMI_MINIMUM_DAYS
,  MSI.VMI_MAXIMUM_UNITS
,  MSI.VMI_MAXIMUM_DAYS
,  MSI.VMI_FIXED_ORDER_QUANTITY
,  MSI.SO_AUTHORIZATION_FLAG
,  MSI.CONSIGNED_FLAG
,  MSI.ASN_AUTOEXPIRE_FLAG
,  MSI.VMI_FORECAST_TYPE
,  MSI.FORECAST_HORIZON
,  MSI.EXCLUDE_FROM_BUDGET_FLAG
,  MSI.DAYS_TGT_INV_SUPPLY
,  MSI.DAYS_TGT_INV_WINDOW
,  MSI.DAYS_MAX_INV_SUPPLY
,  MSI.DAYS_MAX_INV_WINDOW
,  MSI.DRP_PLANNED_FLAG
,  MSI.CRITICAL_COMPONENT_FLAG
,  MSI.CONTINOUS_TRANSFER
,  MSI.CONVERGENCE
,  MSI.DIVERGENCE
/* Start Bug 3713912 */
, MSI.LOT_DIVISIBLE_FLAG
, MSI.GRADE_CONTROL_FLAG
, MSI.DEFAULT_GRADE
, MSI.CHILD_LOT_FLAG
, MSI.PARENT_CHILD_GENERATION_FLAG
, MSI.CHILD_LOT_PREFIX
, MSI.CHILD_LOT_STARTING_NUMBER
, MSI.CHILD_LOT_VALIDATION_FLAG
, MSI.COPY_LOT_ATTRIBUTE_FLAG
, MSI.RECIPE_ENABLED_FLAG
, MSI.PROCESS_QUALITY_ENABLED_FLAG
, MSI.PROCESS_EXECUTION_ENABLED_FLAG
, MSI.PROCESS_COSTING_ENABLED_FLAG
, MSI.PROCESS_SUPPLY_SUBINVENTORY
, MSI.PROCESS_SUPPLY_LOCATOR_ID
, MSI.PROCESS_YIELD_SUBINVENTORY
, MSI.PROCESS_YIELD_LOCATOR_ID
, MSI.HAZARDOUS_MATERIAL_FLAG
, MSI.CAS_NUMBER
, MSI.RETEST_INTERVAL
, MSI.EXPIRATION_ACTION_INTERVAL
, MSI.EXPIRATION_ACTION_CODE
, MSI.MATURITY_DAYS
, MSI.HOLD_DAYS
, 1 -- Process Item Record.
/* End Bug 3713912 */
/* R12 Enhancement */
,  MSI.CHARGE_PERIODICITY_CODE
,  MSI.REPAIR_LEADTIME
,  MSI.REPAIR_YIELD
,  MSI.PREPOSITION_POINT
,  MSI.REPAIR_PROGRAM
,  MSI.SUBCONTRACTING_COMPONENT
,  MSI.OUTSOURCED_ASSEMBLY
/* R12 C Attributes */
,  MSI.GDSN_OUTBOUND_ENABLED_FLAG
,  MSI.TRADE_ITEM_DESCRIPTOR
,  MSI.STYLE_ITEM_FLAG
,  MSI.STYLE_ITEM_ID
FROM
   MTL_SYSTEM_ITEMS_VL  MSI
,  MTL_PARAMETERS       MP
WHERE
        MSI.INVENTORY_ITEM_ID = p_Item_ID
   AND  MSI.ORGANIZATION_ID   = p_Org_ID
   AND  MP.ORGANIZATION_ID = MSI.ORGANIZATION_ID;

-- ------------------------------------------------------
-- ----------------- Local Procedure Specs --------------
-- ------------------------------------------------------

PROCEDURE Insert_MSII_Row
(
   p_commit              IN      VARCHAR2
,  p_transaction_type    IN      VARCHAR2
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  p_revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
,  p_Template_Id         IN      NUMBER
,  p_Template_Name       IN      VARCHAR2
,  x_set_process_id      OUT     NOCOPY NUMBER
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_return_err          OUT     NOCOPY VARCHAR2
);

PROCEDURE Insert_Revision_Record
(
   p_item_rowid      IN  ROWID
  ,p_Revision_rec    IN  INV_ITEM_GRP.Item_Revision_Rec_Type
  ,p_set_process_id  IN  NUMBER
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,x_return_err      OUT NOCOPY VARCHAR2
);

PROCEDURE IOI_Process
(
   p_transaction_type    IN      VARCHAR2
,  p_commit              IN      VARCHAR2
,  p_validation_level    IN      NUMBER        DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  p_revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
,  p_Template_Id         IN      NUMBER
,  p_Template_Name       IN      VARCHAR2
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
-- Bug 9092888 - changes
,  p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
,  p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
-- Bug 9092888 - changes
);

PROCEDURE Get_IOI_Errors
(
    p_transaction_id       IN    NUMBER
,   p_inventory_item_id    IN    NUMBER
,   x_Error_tbl          IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,   x_return_status        OUT   NOCOPY VARCHAR2
,   x_return_err           OUT   NOCOPY VARCHAR2
);

-- -------------------------------------------------------
-- --------------------- Procedures ----------------------
-- -------------------------------------------------------

-- Bug 8442016

  -- Private API to call tempalte application for UDAs
  PROCEDURE Apply_Templates_For_UDAs
                        ( p_batch_id       NUMBER,
                          p_template_id    NUMBER,
                          p_user_id        NUMBER,
                          p_login_id       NUMBER,
                          p_prog_appid     NUMBER,
                          p_prog_id        NUMBER,
                          p_request_id     NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          ERRBUF           OUT NOCOPY VARCHAR2,
                          RETCODE          OUT NOCOPY VARCHAR2
                        )
  IS
    l_return_status            VARCHAR2(2);
    l_entity_sql               VARCHAR2(32000);
    l_gdsn_entity_sql          VARCHAR2(32000);
    l_item_dl_id               NUMBER;
    l_item_rev_dl_id           NUMBER;
    l_item_org_dl_id           NUMBER;
    l_item_gtin_dl_id          NUMBER;
    l_item_gtin_multi_dl_id    NUMBER;
    l_msg_data                 VARCHAR2(4000);

    CURSOR c_data_levels IS
      SELECT ATTR_GROUP_TYPE, DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEMMGMT_GROUP', 'EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ( 'ITEM_LEVEL', 'ITEM_REVISION_LEVEL', 'ITEM_ORG' );

  BEGIN
    RETCODE := '0';

    FOR i IN c_data_levels LOOP
      IF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_ORG' THEN
        l_item_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL' THEN
        l_item_rev_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_multi_dl_id := i.DATA_LEVEL_ID;
      END IF;
    END LOOP;

    l_entity_sql := q'#
                      SELECT
                        MIRI.TEMPLATE_ID,
                        MSIB.INVENTORY_ITEM_ID ,
                        MSIB.ORGANIZATION_ID,
                        MSIB.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        MIRI.REVISION_ID, #' ||
                        l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_ITEM_REVISIONS_INTERFACE MIRI,
                        MTL_SYSTEM_ITEMS_B           MSIB
                      WHERE MSIB.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MIRI.TEMPLATE_ID           IS NOT NULL
                        AND MIRI.INVENTORY_ITEM_ID     = MSIB.INVENTORY_ITEM_ID
                        AND MIRI.ORGANIZATION_ID       = MSIB.ORGANIZATION_ID
                        AND MIRI.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MIRI.PROCESS_FLAG          = 7
                        AND NOT EXISTS
                             (SELECT NULL
                              FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                              WHERE MSII.INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID
                                AND MSII.ORGANIZATION_ID   = MIRI.ORGANIZATION_ID
                                AND MSII.SET_PROCESS_ID    = MIRI.SET_PROCESS_ID
                                AND MSII.PROCESS_FLAG      = MIRI.PROCESS_FLAG)
                      UNION ALL
                      SELECT  /*+ LEADING(MSII) USE_NL_WITH_INDEX(MIRI, MTL_ITEM_REVS_INTERFACE_N2 ) */
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        (CASE WHEN MIRI.REVISION_Id IS NULL
                              THEN (SELECT Max(REVISION_ID)
                                    FROM MTL_ITEM_REVISIONS_B MIRB
                                    WHERE MIRB.EFFECTIVITY_DATE <= SYSDATE
                                      AND MIRB.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                                      AND MIRB.ORGANIZATION_ID   = MSII.ORGANIZATION_ID
                                   )
                              ELSE MIRI.REVISION_ID
                        END) REVISION_ID, #' ||
                        l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII,
                        MTL_ITEM_REVISIONS_INTERFACE MIRI
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MIRI.INVENTORY_ITEM_ID(+)  = MSII.INVENTORY_ITEM_ID
                        AND MIRI.ORGANIZATION_ID(+)    = MSII.ORGANIZATION_ID
                        AND MIRI.SET_PROCESS_ID(+)     = MSII.SET_PROCESS_ID
                        AND MIRI.PROCESS_FLAG(+)       = 7
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 7
                      UNION ALL
                      SELECT
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        NULL AS REVISION_ID, #' ||
                        l_item_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 7
          UNION ALL
                      SELECT
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        NULL AS REVISION_ID, #' ||
                        l_item_org_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 7 #';


      l_gdsn_entity_sql := q'#
                            SELECT
                              MSII.TEMPLATE_ID,
                              MSII.INVENTORY_ITEM_ID ,
                              MSII.ORGANIZATION_ID,
                              MSII.ITEM_CATALOG_GROUP_ID,
                              NULL AS PK1_VALUE,
                              NULL AS PK2_VALUE,
                              NULL AS PK3_VALUE,
                              NULL AS PK4_VALUE,
                              NULL AS PK5_VALUE,
                              NULL AS REVISION_ID, #' ||
                              l_item_gtin_dl_id || q'# AS DATA_LEVEL_ID
                            FROM
                              MTL_SYSTEM_ITEMS_INTERFACE   MSII
                            WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                              AND MSII.TEMPLATE_ID                          IS NOT NULL
                              AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                              AND MSII.PROCESS_FLAG                         = 7
                              AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                            UNION ALL
                            SELECT
                              MSII.TEMPLATE_ID,
                              MSII.INVENTORY_ITEM_ID ,
                              MSII.ORGANIZATION_ID,
                              MSII.ITEM_CATALOG_GROUP_ID,
                              NULL AS PK1_VALUE,
                              NULL AS PK2_VALUE,
                              NULL AS PK3_VALUE,
                              NULL AS PK4_VALUE,
                              NULL AS PK5_VALUE,
                              NULL AS REVISION_ID, #' ||
                              l_item_gtin_multi_dl_id || q'# AS DATA_LEVEL_ID
                            FROM
                              MTL_SYSTEM_ITEMS_INTERFACE   MSII
                            WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                              AND MSII.TEMPLATE_ID                          IS NOT NULL
                              AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                              AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                              AND MSII.PROCESS_FLAG                         = 7 #';


      EGO_IMPORT_UTIL_PVT.Call_UDA_Apply_Template
                    ( p_batch_id        => p_batch_id,
                      p_entity_sql      => l_entity_sql,
                      p_gdsn_entity_sql => l_gdsn_entity_sql,
                      p_user_id         => p_user_id,
                      p_login_id        => p_login_id,
                      p_prog_appid      => p_prog_appid,
                      p_prog_id         => p_prog_id,
                      p_request_id      => p_request_id,
                      x_return_status   => l_return_status,
                      x_err_msg         => l_msg_data
                    );
    IF (l_return_status = '2') THEN
     RETCODE := '2';
     ERRBUF  := l_msg_data;
    ELSIF (l_return_status = '1') THEN
     RETCODE := '1';
     ERRBUF  := l_msg_data;
    ELSE
     RETCODE := '0';
     ERRBUF  := NULL;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN

        ----------------------------------------
        -- Mark all rows in process as errors --
        ----------------------------------------
        UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET PROCESS_STATUS = G_PS_GENERIC_ERROR
        WHERE DATA_SET_ID = p_batch_id
          AND PROCESS_STATUS = G_PS_IN_PROCESS;

    RETCODE := '2';
    ERRBUF  := 'When Others Exception - Apply_Templates_For_UDAs';

  END Apply_Templates_For_UDAs;

-- Bug 8442016

-- -------------------- Create_Item --------------------
--Start:3259338: Overloaded procedures Update_Item,Create_item
PROCEDURE Create_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
)
IS
BEGIN
   INV_ITEM_GRP.Create_Item(p_commit           => p_commit
                           ,p_validation_level => p_validation_level
                           ,p_Item_rec         => p_Item_rec
                           ,x_Item_rec         => x_Item_rec
                           ,x_return_status    => x_return_status
                           ,x_Error_tbl        => x_Error_tbl
                           ,p_Template_Id      => p_Template_Id
                           ,p_Template_Name    => p_Template_Name
                           ,p_Revision_rec     => g_Miss_Revision_rec);
END Create_Item;
--End:3259338: Overloaded procedures Update_Item,Create_item

PROCEDURE Create_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
,  p_Revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
-- Bug 9092888 - changes
,  p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
,  p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
-- Bug 9092888 - changes
)
IS
  c_transaction_type    CONSTANT  VARCHAR2(10)  :=  'CREATE';
  l_return_status       VARCHAR2(1);
  l_idx                 BINARY_INTEGER;
BEGIN

   SAVEPOINT Create_Item_GRP;
   x_return_status := fnd_api.g_RET_STS_SUCCESS;

   IOI_Process
   (
      p_transaction_type   =>  c_transaction_type
   ,  p_commit             =>  p_commit
   ,  p_validation_level   =>  p_validation_level
   ,  p_Item_rec           =>  p_Item_rec
   ,  p_revision_rec       =>  p_Revision_rec
   ,  p_Template_Id        =>  p_Template_Id
   ,  p_Template_Name      =>  p_Template_Name
   ,  x_Item_rec           =>  x_Item_rec
   ,  x_return_status      =>  l_return_status
   ,  x_Error_tbl          =>  x_Error_tbl
   -- Bug 9092888 - Changes
   ,  p_attributes_row_table   => p_attributes_row_table  --       IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
   ,  p_attributes_data_table  => p_attributes_data_table --       IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
   -- Bug 9092888 - Changes
   );

   x_return_status := l_return_status;

EXCEPTION

   WHEN others THEN
      ROLLBACK TO Create_Item_GRP;
      x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
      x_Error_tbl(l_idx).UNIQUE_ID    := 999;
      x_Error_tbl(l_idx).TABLE_NAME   := '';
      x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR('INV_ITEM_GRP.Create_Item: Unexpexted error: ' || SQLERRM,1,239);
--      INV_message_s.sql_error('Create_Item', x_progress, SQLCODE);
--      INV_ITEM_debug.put_line('Create_Item: ');
--      RAISE;

END Create_Item;

-- -------------------- Update_Item -------------------
--Start:3259338: Overloaded procedures Update_Item,Create_item
PROCEDURE Update_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_lock_rows           IN      VARCHAR2                            DEFAULT  fnd_api.g_TRUE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
)
IS
BEGIN

   INV_ITEM_GRP.Update_Item(
       p_commit           => p_commit
      ,p_lock_rows        => p_lock_rows
      ,p_validation_level => p_validation_level
      ,p_Item_rec         => p_Item_rec
      ,x_Item_rec         => x_Item_rec
      ,x_return_status    => x_return_status
      ,x_Error_tbl        => x_Error_tbl
      ,p_Template_Id      => p_Template_Id
      ,p_Template_Name    => p_Template_Name
      ,p_Revision_rec     => g_Miss_Revision_rec);

END Update_Item;
--End:3259338: Overloaded procedures Update_Item,Create_item

PROCEDURE Update_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_lock_rows           IN      VARCHAR2                            DEFAULT  fnd_api.g_TRUE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
,  p_Revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
)
IS
  c_transaction_type    CONSTANT  VARCHAR2(10)  :=  'UPDATE';
  l_return_status       VARCHAR2(1);
  l_idx                 BINARY_INTEGER;
BEGIN

   SAVEPOINT Update_Item_GRP;
   x_return_status := fnd_api.g_RET_STS_SUCCESS;

   IOI_Process
   (
      p_transaction_type   =>  c_transaction_type
   ,  p_commit             =>  p_commit
   ,  p_validation_level   =>  p_validation_level
   ,  p_Item_rec           =>  p_Item_rec
   ,  p_revision_rec       =>  p_Revision_rec
   ,  p_Template_Id        =>  p_Template_Id
   ,  p_Template_Name      =>  p_Template_Name
   ,  x_Item_rec           =>  x_Item_rec
   ,  x_return_status      =>  l_return_status
   ,  x_Error_tbl          =>  x_Error_tbl
   );

   x_return_status := l_return_status;

EXCEPTION

   WHEN others THEN
      ROLLBACK TO Update_Item_GRP;
      x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
      x_Error_tbl(l_idx).UNIQUE_ID    := 999;
      x_Error_tbl(l_idx).TABLE_NAME   := '';
      x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR('INV_ITEM_GRP.Update_Item: Unexpexted error: ' || SQLERRM,1,239);

END Update_Item;

-- --------------------- Lock_Item ---------------------

PROCEDURE Lock_Item
(
    p_Item_ID             IN    NUMBER
,   p_Org_ID              IN    NUMBER
,   x_return_status       OUT   NOCOPY VARCHAR2
,   x_Error_tbl         IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
)
IS
BEGIN

     INV_ITEM_PVT.Lock_Org_Items
     (
         p_Item_ID         =>  p_Item_ID
     ,   p_Org_ID          =>  p_Org_ID
     ,   p_lock_Master     =>  fnd_api.g_TRUE
     ,   p_lock_Orgs       =>  fnd_api.g_TRUE
     ,   x_return_status   =>  x_return_status
     );

END Lock_Item;

-- Bug 9092888 - changes
FUNCTION SKU_ITEM_PREPROCESS
      (p_attributes_row_table     IN    EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
       ,p_attributes_data_table   IN    EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
       ,p_set_process_id          IN    NUMBER
       ,p_Item_rec                IN    INV_ITEM_GRP.Item_rec_type
       ,x_return_err             OUT   NOCOPY VARCHAR2
       )
RETURN VARCHAR2 IS
l_ix                NUMBER;
l_attr_name         VARCHAR2(100);
l_attr_group_id     NUMBER;
l_attr_group_name   VARCHAR2(100);
l_attr_group_type   VARCHAR2(100);
l_row_identifier    NUMBER;
l_token_table       ERROR_HANDLER.Token_Tbl_Type;
l_err_msg_name      VARCHAR2(30);

BEGIN
  IF p_attributes_row_table IS NOT NULL AND
    p_attributes_data_table IS NOT NULL AND
    p_attributes_data_table.Count > 0 AND
    p_attributes_row_table.Count > 0
  THEN
    FOR j IN 1 .. p_attributes_data_table.COUNT LOOP
      l_ix := -1;

      FOR k IN 1 .. p_attributes_row_table.COUNT LOOP
        IF p_attributes_row_table(k).ROW_IDENTIFIER =
            p_attributes_data_table(j).ROW_IDENTIFIER
        THEN
          l_ix := k;
          exit;
        END IF;
      END LOOP;

      IF l_ix = -1 THEN
        x_return_err := 'SKU_ITEM_PREPROCESS - Unexpected Error occured';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_attr_name := p_attributes_data_table(j).ATTR_NAME;
      l_attr_group_id := p_attributes_row_table(l_ix).ATTR_GROUP_ID;
      l_attr_group_name := p_attributes_row_table(l_ix).ATTR_GROUP_NAME;
      l_attr_group_type := p_attributes_row_table(l_ix).ATTR_GROUP_TYPE;
      l_row_identifier := p_attributes_row_table(l_ix).ROW_IDENTIFIER;

      IF (l_attr_group_name IS NULL) THEN
        IF (l_attr_group_id IS NOT NULL) THEN

          BEGIN
            SELECT attr_group_name INTO l_attr_group_name
            FROM ego_attr_groups_v
            WHERE APPLICATION_ID = 431
              AND attr_group_id = l_attr_group_id
              AND ATTR_GROUP_TYPE = l_attr_group_type
              AND VARIANT = 'Y';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_err_msg_name := 'EGO_ATTR_GROUP_ID_PK_NOT_FOUND';

              l_token_table(1).TOKEN_NAME := 'APP_ID';
              l_token_table(1).TOKEN_VALUE := 431;

              l_token_table(2).TOKEN_NAME := 'AG_TYPE"';
              l_token_table(2).TOKEN_VALUE := l_attr_group_type;

              l_token_table(3).TOKEN_NAME := 'AG_ID';
              l_token_table(3).TOKEN_VALUE := l_attr_group_id;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name      => l_err_msg_name
              ,p_application_id    => 'EGO'
              ,p_token_tbl         => l_token_table
              ,p_message_type      => FND_API.G_RET_STS_ERROR
              );
              RETURN FND_API.g_RET_STS_ERROR;
          END;
        ELSE
          -- error attribute group details are not provided.
          l_err_msg_name := 'EGO_VAR_ATTR_GROUP_DETAILS_ERR';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name      => l_err_msg_name
            ,p_application_id    => 'EGO'
            ,p_token_tbl         => l_token_table
            ,p_message_type      => FND_API.G_RET_STS_ERROR
            );

          RETURN FND_API.g_RET_STS_ERROR;
        END IF;
      END IF;

      INSERT INTO EGO_ITM_USR_ATTR_INTRFC
          (
          DATA_SET_ID          ,
          ITEM_NUMBER          ,
          ROW_IDENTIFIER       ,
          ATTR_GROUP_INT_NAME  ,
          ATTR_INT_NAME        ,
          PROCESS_STATUS       ,
          ATTR_GROUP_TYPE,
          ITEM_CATALOG_GROUP_ID,
          DATA_LEVEL_ID ,
          ATTR_VALUE_STR,
          ATTR_VALUE_NUM,
          ATTR_VALUE_DATE,
          ATTR_DISP_VALUE
          )
          VALUES
          (
          p_set_process_id,
          p_Item_rec.ITEM_NUMBER,
          l_row_identifier,
          l_attr_group_name,
          l_attr_name,
          1,
          l_attr_group_type,
          p_Item_rec.ITEM_CATALOG_GROUP_ID,
          43101 ,         --since variants are always item level, hard coding this
          p_attributes_data_table(j).ATTR_VALUE_STR,
          p_attributes_data_table(j).ATTR_VALUE_NUM,
          p_attributes_data_table(j).ATTR_VALUE_DATE,
          p_attributes_data_table(j).ATTR_DISP_VALUE
          );
    END LOOP; -- p_attributes_data_table
  ELSE
    l_err_msg_name := 'EGO_ALL_VAR_ATTR_VAL_ERR';

    ERROR_HANDLER.Add_Error_Message(
      p_message_name      => l_err_msg_name
    ,p_application_id    => 'EGO'
    ,p_token_tbl         => l_token_table
    ,p_message_type      => FND_API.G_RET_STS_ERROR
    );
    RETURN FND_API.g_RET_STS_ERROR;
  END IF; -- attr row and data NOT NULL

  RETURN fnd_api.g_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_return_err := 'SKU_ITEM_PREPROCESS - Exception Othres'||SQLERRM ;
    RETURN fnd_api.g_RET_STS_UNEXP_ERROR;

END SKU_ITEM_PREPROCESS;
-- Bug 9092888 - changes


-- -------------------- IOI_Process --------------------

PROCEDURE IOI_Process
(
   p_transaction_type    IN      VARCHAR2
,  p_commit              IN      VARCHAR2
,  p_validation_level    IN      NUMBER        DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  p_revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
,  p_Template_Id         IN      NUMBER
,  p_Template_Name       IN      VARCHAR2
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
-- Bug 9092888 - changes
,  p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
,  p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
-- Bug 9092888 - changes
)
IS
  -- Do not commit an inserted row in MSII
  --
  c_MSII_commit_flag    CONSTANT  VARCHAR2(1)  :=  fnd_api.g_FALSE;

  -- Control the IOI run mode (CREATE, UPDATE) through the IOI parameter
  --
  l_IOI_run_mode        NUMBER;

  -- No init value; control the API commit through the IOI parameter
  --
  l_IOI_commit_flag     NUMBER;

  l_set_process_id      NUMBER;
  l_process_flag        NUMBER;
  l_transaction_id      NUMBER;
  l_return_status       VARCHAR2(1);

  -- Return error from Insert_MSII_Row and Get_IOI_Errors procedures
  --
  l_return_err          VARCHAR2(2000);

  l_inventory_item_id   NUMBER;
  l_organization_id     NUMBER;

  l_org_id              NUMBER;
  l_all_org             NUMBER;

  -- Created/updated item id
  --
  l_Item_ID_out         NUMBER;
  l_Org_ID_out          NUMBER;

  l_Language_Code       VARCHAR2(4);

  -- IOI return code
  --
  l_return_code         NUMBER;
  l_err_text            VARCHAR2(2000);

  l_idx                 BINARY_INTEGER;
  l_only_validate       NUMBER;
  l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

  -- Bug 9092888 - changes
  l_err_bug    VARCHAR2(1000);
  l_ret_code   VARCHAR2(1000);
  -- Bug 9092888 - changes
  -- Bug 8442016
  l_msg_data   VARCHAR2(1000);
  l_errorcode  VARCHAR2(1);
  -- Bug 8442016
BEGIN

  -- Control the IOI run mode (CREATE, UPDATE) through the IOI parameter
  --
  IF ( p_transaction_type = 'CREATE' ) then
     l_IOI_run_mode := 1;
  ELSIF ( p_transaction_type = 'UPDATE' ) then
     l_IOI_run_mode := 2;

/* Need to get Item ID from MTL_SYSTEM_ITEMS_INTERFACE since ITEM_NUMBER
   could be passed with item record to Update_Item
     --
     -- Use passed record item id to retrieve updated item
     --
     l_Item_ID_out := p_Item_rec.INVENTORY_ITEM_ID;
     l_Org_ID_out  := p_Item_rec.ORGANIZATION_ID;
*/

  ELSE
     l_IOI_run_mode := -1;
  END IF;

  -- Control the API commit through the IOI parameter
  --
  IF ( fnd_api.to_Boolean (p_commit) ) THEN
     l_IOI_commit_flag := 1;
  ELSE
     l_IOI_commit_flag := 2;
  END IF;

  x_return_status := fnd_api.g_RET_STS_SUCCESS;

  ----------------------------------------------------------------------------
  -- Insert a row into MSI INTERFACE table converting missing values to nulls
  ----------------------------------------------------------------------------

  Insert_MSII_Row
  (
     p_commit            =>  c_MSII_commit_flag
  ,  p_transaction_type  =>  p_transaction_type
  ,  p_Item_rec          =>  p_Item_rec
  ,  p_revision_rec      =>  p_revision_rec
  ,  p_Template_Id       =>  p_Template_Id
  ,  p_Template_Name     =>  p_Template_Name
  ,  x_set_process_id    =>  l_set_process_id
  ,  x_return_status     =>  l_return_status
  ,  x_return_err        =>  l_return_err
  );

  IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_Error_tbl(1).UNIQUE_ID    := 1;
     x_Error_tbl(1).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
     x_Error_tbl(1).MESSAGE_TEXT := SUBSTR(l_return_err,1,239);
     RETURN;
  END IF;

  -- Bug 9092888 - changes
  IF(p_transaction_type = 'CREATE' AND INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API = 'API' AND
      p_Item_rec.STYLE_ITEM_FLAG = 'N' AND p_Item_rec.STYLE_ITEM_ID IS NOT NULL)
  THEN
    l_return_status := SKU_ITEM_PREPROCESS
                        (
                         p_attributes_row_table   => p_attributes_row_table --       IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
                        ,p_attributes_data_table  => p_attributes_data_table --       IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
                        ,p_set_process_id => l_set_process_id
                        ,p_Item_rec          =>  p_Item_rec
                        , x_return_err  => l_return_err
                        );

    IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
      x_return_status := l_return_status;
      x_Error_tbl(1).UNIQUE_ID    := 1;
      x_Error_tbl(1).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
      x_Error_tbl(1).MESSAGE_TEXT := SUBSTR(l_return_err,1,239);
      RETURN;
    END IF;
  END IF;
  -- Bug 9092888 - changes

  -----------------------------------------------------
  -- Run Item OI process.
  -- Then call oi delete; need to get
  --     process_flag
  --  ,  transaction_id
  --  ,  inventory_item_id
  --  ,  organization_id
  -- before deleting processed records.
  --
  -- ToDo: Get the above from the Interface Process routine.
  -----------------------------------------------------

/*
     select organization_id
     from MTL_PARAMETERS
     where organization_code = p_Item_rec.ORGANIZATION_code;
*/

  IF (    p_Item_rec.ORGANIZATION_ID = g_MISS_NUM
       OR p_Item_rec.ORGANIZATION_ID IS NULL )
  THEN
     l_org_id  := NULL;
     l_all_org := 1;
  ELSE
    -- Bug 12635842 : Start
    -- If we are creating a SKU from API, then we need to process for all orgs though the user provides the specifi organization.
    -- Becases the style item could be assicgned to multiple orgs, so while creating SKU we will create the SKU in all those orgs.
        IF(INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API = 'API' AND p_Item_rec.STYLE_ITEM_FLAG = 'N'
       AND p_Item_rec.STYLE_ITEM_ID IS NOT NULL AND p_transaction_type = 'CREATE')
    THEN
       l_org_id := NULL;
       l_all_org := 1;
    ELSE
    -- Bug 12635842 : End
      l_org_id  := p_Item_rec.ORGANIZATION_ID;
      l_all_org := 2;  -- process only org_id
    END IF; -- Bug 12635842
  END IF;

  IF p_Item_rec.PROCESS_ITEM_RECORD NOT IN (1,2) THEN
     l_only_validate := 1;
  ELSE
    l_only_validate := p_Item_rec.PROCESS_ITEM_RECORD;
  END IF;

  IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INV_ITEM_GRP.IOI_Process: calling INVPOPIF.inopinp_open_interface_process');
  END IF;
  l_return_code :=
  INVPOPIF.inopinp_open_interface_process
  (
     org_id         =>  l_org_id
  ,  all_org        =>  l_all_org
  ,  val_item_flag  =>  1  -- validate item
  ,  pro_item_flag  =>  l_only_validate  -- process validated items
  ,  del_rec_flag   =>  2  -- do not delete processed records
  ,  prog_appid     =>  fnd_global.prog_appl_id
  ,  prog_id        =>  fnd_global.conc_program_id
  ,  request_id     =>  fnd_global.conc_request_id
  ,  user_id        =>  fnd_global.user_id
  ,  login_id       =>  fnd_global.login_id
  ,  err_text       =>  l_err_text
  ,  xset_id        =>  l_set_process_id  -- only run for the current item record
  ,  commit_flag    =>  l_IOI_commit_flag
  ,  run_mode       =>  l_IOI_run_mode
  );

  IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INV_ITEM_GRP.IOI_Process: done INVPOPIF.inopinp_open_interface_process: l_return_code = ' || l_return_code);
  END IF;

  --------------------------------------------------------------------------
  -- Get IOI transaction_id and process_flag for the current set_process_id
  --------------------------------------------------------------------------

  -- Bug 12635842 : Start
  -- Adding the below IF statement as when creating a SKU, the sku can be created in child orgs also if the style is addigned
  -- to any child orgs. So we ned to check for master org creation .
  -- IF creating a SKU using API, check if the SKU creation for master org successeded or not
  IF(INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API = 'API' AND p_Item_rec.STYLE_ITEM_FLAG = 'N'
       AND p_Item_rec.STYLE_ITEM_ID IS NOT NULL AND p_transaction_type = 'CREATE')
  THEN
    SELECT
        process_flag
    ,  transaction_id
    ,  inventory_item_id
    ,  MSII.organization_id
    INTO
        l_process_flag
    ,  l_transaction_id
    ,  l_inventory_item_id
    ,  l_organization_id
    FROM
      MTL_SYSTEM_ITEMS_INTERFACE MSII,
      MTL_PARAMETERS MP
    WHERE set_process_id = l_set_process_id
      AND MP.MASTER_ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND MP.ORGANIZATION_ID = MSII.ORGANIZATION_ID;

    -- IF item got created in master org and failed in one child org, then return code may not be 0.
    -- In this case we need to process child enties for other child orgs in which item got created, So making the l_return_code to 0.
    IF(l_process_flag = 7 and l_return_code <> 0) THEN
      l_return_code := 0;
    END IF;

  ELSE
  -- Bug 12635842 : End
    SELECT
        process_flag
    ,  transaction_id
    ,  inventory_item_id
    ,  organization_id
    INTO
        l_process_flag
    ,  l_transaction_id
    ,  l_inventory_item_id
    ,  l_organization_id
    FROM
      MTL_SYSTEM_ITEMS_INTERFACE
    WHERE
     set_process_id = l_set_process_id;
  END IF; --  Bug 12635842

  IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INV_ITEM_GRP.IOI_Process: l_process_flag = ' || l_process_flag || ' l_return_code = ' || l_return_code || ' l_err_text = ' || l_err_text);
  END IF;

  -----------------------------------------------------------
  -- Populate the API Error_tbl with the IOI errors, if any.
   -----------------------------------------------------------

  IF ( (l_process_flag = 7) AND (l_return_code = 0) and (l_only_validate =1))
  THEN
     -- Successfull competion of the IOI run.
     -- Get the whole record for the newly created/updated item.
     --
        l_Item_ID_out := l_inventory_item_id;
        l_Org_ID_out  := l_organization_id;

-- Bug 8442016
  IF ( INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API = 'API' ) THEN

   IF ( p_Template_Id IS NOT NULL AND (p_transaction_type = 'CREATE' OR p_transaction_type = 'UPDATE') )  -- For Template UDAs processing
   THEN
    Apply_Templates_For_UDAs
                          (  p_batch_id       => l_set_process_id
                            ,p_template_id    => p_Template_Id
                            ,p_user_id        => fnd_global.user_id
                            ,p_login_id       => fnd_global.login_id
                            ,p_prog_appid     => fnd_global.prog_appl_id
                            ,p_prog_id        => fnd_global.conc_program_id
                            ,p_request_id     => fnd_global.conc_request_id
                            ,x_return_status   => l_return_status
                            ,ERRBUF            => l_msg_data
                            ,RETCODE           => l_errorcode
                          );

    /* Bug 13414358 : Validating the UDAs after applying templates for UDAs, so that transaction type for UDAs
       inserted by template code will be set to correct value CREATE/UPDATE from SYNC. */
    EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data(
                    ERRBUF        => l_err_bug
                  ,RETCODE       => l_ret_code
                  ,p_data_set_id => l_set_process_id
                  ,p_validate_only => FND_API.G_TRUE
                  ,p_is_id_validations_reqd  => FND_API.G_FALSE
                  );
	 END IF;

   -- Bug 12635842 : Start
   -- If we are creating a SKU, then we need to default child entities (like supplier, supplier site and supplier site org etc..) along with their UDAS.
   IF(p_Item_rec.STYLE_ITEM_FLAG = 'N' AND p_Item_rec.STYLE_ITEM_ID IS NOT NULL AND p_transaction_type = 'CREATE') THEN

    EGO_ITEM_OPEN_INTERFACE_PVT.process_item_entities(ERRBUF            =>  l_err_bug
                                                      ,RETCODE          =>  l_ret_code
                                                      ,p_del_rec_flag   =>  1
                                                      ,p_xset_id        =>  l_set_process_id
                                                      ,p_request_id     => fnd_global.conc_request_id
                                                      ,p_call_uda_process => FALSE );
   END IF;
   -- Bug 12635842 : End

   -- Bug 9959169 : Start
   -- Below api is called to populate the default udas into ego interface table.
   EGO_IMPORT_UTIL_PVT.Do_AGLevel_UDA_Defaulting( p_batch_id       => l_set_process_id,
                                                 x_return_status  => l_return_status,
                                                 x_err_msg        => l_return_err ,
                                                 p_msii_miri_process_flag   => 7
                                               );
   /*
      -- commenting the below if clause so that the Process_Item_User_Attrs_Data api is called always,
      -- So that the processing of default udas is done always.
      -- if there are no records to be processed the api will return in the startin only,
      --   so it won't have any performance impact in calling this always.

   IF ( (p_transaction_type = 'CREATE' AND p_Item_rec.STYLE_ITEM_FLAG = 'N' AND p_Item_rec.STYLE_ITEM_ID IS NOT NULL) OR  -- For SKU UDAS processing
        (p_Template_Id IS NOT NULL AND (p_transaction_type = 'CREATE' OR p_transaction_type = 'UPDATE') AND l_errorcode <> '2' )  -- For Template UDAs processing
       )
    THEN
  */ -- Bug 9959169

    EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data(
                    ERRBUF        => l_err_bug
                  ,RETCODE       => l_ret_code
                  ,p_data_set_id => l_set_process_id
                  );
  -- END IF; -- Bug 9959169 : End
  END IF; -- end of if INV_EGO_REVISION_VALIDATE.Get_Process_Control_HTML_API = 'API'
-- Bug 8442016

--     IF ( p_transaction_type <> 'UPDATE' ) then
--     END IF;

     IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('INV_ITEM_GRP.IOI_Process: calling INV_ITEM_GRP.Get_Item');
     END IF;

     INV_ITEM_GRP.Get_Item
     (
         p_Item_ID         =>  l_Item_ID_out
     ,   p_Org_ID          =>  l_Org_ID_out
     ,   x_Item_rec        =>  x_Item_rec
     ,   x_return_status   =>  l_return_status
     ,   x_return_err      =>  l_return_err
     );

     IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
        x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
        l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
        x_Error_tbl(l_idx).UNIQUE_ID    := 999;
        x_Error_tbl(l_idx).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
        x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR(l_return_err,1,239);
     END IF;

-- Do not insert message, if IOI is success.
--
/*
     l_idx := 1;
     x_Error_tbl(l_idx).UNIQUE_ID    := 0;
     x_Error_tbl(l_idx).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
     x_Error_tbl(l_idx).MESSAGE_TEXT :=
        'Create_Item success. IOI tnx_id=' || to_char(l_transaction_id) ||
        ' inventory_item_id=' || to_char(l_inventory_item_id);
*/
  ELSIF ( (l_process_flag = 4) AND (l_return_code = 0) and (l_only_validate =2)) THEN
     x_return_status := fnd_api.g_RET_STS_SUCCESS;
  ELSE
     --
     -- An error happened during the IOI run.
     --
     x_return_status := fnd_api.g_RET_STS_ERROR;

     -----------------------------------------------------------------
     -- Populate the Item API Error_tbl with the IOI errors, if any.
     -----------------------------------------------------------------

     l_idx := NVL( x_Error_tbl.COUNT, 0);

     IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('INV_ITEM_GRP.IOI_Process: calling INV_ITEM_GRP.Get_IOI_Errors');
     END IF;

     INV_ITEM_GRP.Get_IOI_Errors
     (   p_transaction_id     =>  l_transaction_id
     ,   p_inventory_item_id  =>  l_inventory_item_id
     ,   x_Error_tbl          =>  x_Error_tbl
     ,   x_return_status      =>  l_return_status
     ,   x_return_err         =>  l_return_err
     );

     IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
        x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
        l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
        x_Error_tbl(l_idx).UNIQUE_ID    := 999;
        x_Error_tbl(l_idx).TABLE_NAME   := 'MTL_INTERFACE_ERRORS';
        x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR(l_return_err,1,239);
     ELSE
        --
        -- If Interface Process return_code <> 0 and there are no additional
        -- messages in x_Error_tbl, then insert an Unexpexted error message.
        --
        IF ( l_return_code <> 0
             AND l_idx = NVL( x_Error_tbl.COUNT, 0) ) THEN
           l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
           x_Error_tbl(l_idx).UNIQUE_ID    := 1;
           x_Error_tbl(l_idx).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
           x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR('Error during IOI run.'
              || ' Process_flag=' || to_char(l_process_flag)
              || ' Return_code=' || to_char(l_return_code)
              || ' Unexpexted error: ' || l_err_text,1,239);
        END IF;
     END IF;

  END IF;  -- (l_process_flag = 7) AND (l_return_code = 0)

  ----------------------------------------------------------
  -- Delete IOI process set rows from the interface tables
  ----------------------------------------------------------
  l_return_code :=
  INVPOPIF.indelitm_delete_item_oi
  (  err_text  =>  l_err_text
  ,  com_flag  =>  l_IOI_commit_flag
  ,  xset_id   =>  l_set_process_id
  );

  IF ( l_return_code <> 0 ) THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
     x_Error_tbl(l_idx).UNIQUE_ID    := 999;
     x_Error_tbl(l_idx).TABLE_NAME   := 'MTL_SYSTEM_ITEMS_INTERFACE';
     x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR(l_err_text,1,239);
  END IF;
  ----------------------------------------------------------
  -- Control the API commit through the IOI
  -- inopinp_open_interface_process parameter
  ----------------------------------------------------------
/*
  IF ( fnd_api.to_Boolean (p_commit) ) THEN
     COMMIT WORK;
  END IF;
*/

EXCEPTION

  WHEN others THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     l_idx := NVL( x_Error_tbl.COUNT, 0) + 1;
     x_Error_tbl(l_idx).UNIQUE_ID    := 999;
     x_Error_tbl(l_idx).TABLE_NAME   := '';
     x_Error_tbl(l_idx).MESSAGE_TEXT := SUBSTR('INV_ITEM_GRP.IOI_Process: Unexpexted error: ' || SQLERRM,1,239);

END IOI_Process;

-- -------------------- Get_IOI_Errors -------------------

PROCEDURE Get_IOI_Errors
(
    p_transaction_id       IN    NUMBER
,   p_inventory_item_id    IN    NUMBER
,   x_Error_tbl          IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,   x_return_status        OUT   NOCOPY VARCHAR2
,   x_return_err           OUT   NOCOPY VARCHAR2
)
IS
  l_Error_rec      INV_ITEM_GRP.Error_rec_type;
  l_init_errno     NUMBER;
  l_idx            BINARY_INTEGER;

/*
  CURSOR c_mtl_item_cat_interface
  IS
    SELECT  transaction_id
    FROM  MTL_ITEM_CATEGORIES_INTERFACE
    WHERE  organization_id = X_organization_id
      AND  inventory_item_id = X_inventory_item_id;

  CURSOR c_mtl_item_rev_interface
  IS
    SELECT  transaction_id
    FROM  mtl_item_revisions_interface
    WHERE  organization_id = X_organization_id
      AND  inventory_item_id = X_inventory_item_id
      AND  revision = X_revision;
*/

  CURSOR Interface_Errors_csr ( p_tnx_id  IN  NUMBER )
  RETURN Error_rec_type
  IS
    SELECT
       TRANSACTION_ID
    ,  UNIQUE_ID
    ,  MESSAGE_NAME               MESSAGE_NAME
    ,  ERROR_MESSAGE              MESSAGE_TEXT
  --  ,  error_message || column_name
    ,  TABLE_NAME
    ,  substr(COLUMN_NAME,1,30)   COLUMN_NAME
    ,  ORGANIZATION_ID
    FROM  MTL_INTERFACE_ERRORS
    WHERE  TRANSACTION_ID = p_tnx_id
    ORDER BY  TRANSACTION_ID, UNIQUE_ID;

BEGIN

/*
  OPEN c_mtl_item_cat_interface;
  FETCH c_mtl_item_cat_interface INTO X_transaction_id_2;
  IF c_mtl_item_cat_interface%NOTFOUND THEN
        X_transaction_id_2 := -999;  -- assign some number to tnx
  END IF;
  CLOSE c_mtl_item_cat_interface;

  OPEN c_mtl_item_rev_interface;
  FETCH c_mtl_item_rev_interface INTO X_transaction_id_3;
  IF c_mtl_item_rev_interface%NOTFOUND THEN
        X_transaction_id_3 := -99;
  END IF;
  CLOSE c_mtl_item_rev_interface;
*/

/*
  OPEN Interface_Errors_csr( p_tnx_id => p_transaction_id );
  l_idx := l_init_errno;
  LOOP  -- Loop through error records
     FETCH Interface_Errors_csr INTO l_Error_rec;
     EXIT WHEN ( Interface_Errors_csr%NOTFOUND );
     l_idx := l_idx + 1;
     x_Error_tbl(l_idx) := l_Error_rec;
  END LOOP;
*/

  l_init_errno := NVL( x_Error_tbl.COUNT, 0);
  l_idx := l_init_errno;
  FOR l_Error_rec IN Interface_Errors_csr( p_tnx_id => p_transaction_id )
  LOOP
     l_idx := l_idx + 1;
     x_Error_tbl(l_idx) := l_Error_rec;
  END LOOP;

  IF ( l_idx = l_init_errno ) THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'IOI error(s) occurred, but no records found in MTL_INTERFACE_ERRORS table';
  END IF;

EXCEPTION

  WHEN others THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'INV_ITEM_GRP.Get_IOI_Errors: Unexpexted error: ' || SQLERRM;

END Get_IOI_Errors;

-- ------------------- Insert_MSII_Row -------------------

PROCEDURE Insert_MSII_Row
(
   p_commit              IN      VARCHAR2
,  p_transaction_type    IN      VARCHAR2
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  p_revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
,  p_Template_Id         IN      NUMBER
,  p_Template_Name       IN      VARCHAR2
,  x_set_process_id      OUT     NOCOPY NUMBER
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_return_err          OUT     NOCOPY VARCHAR2
)
IS
  -- Initial row status (Awaiting Validation)
  l_process_flag       NUMBER  :=  1;

  -- Unique process set id for one record
  l_set_process_id     NUMBER;

--  x_def_master_org_id  /* organization id */

  l_Contract_Item_Type_Code       VARCHAR2(30);
  l_item_rowid                    ROWID;
  l_Item_rec                      INV_ITEM_GRP.Item_Rec_Type := p_Item_rec;

BEGIN

  SAVEPOINT Insert_MSII_Row;
  x_return_status := fnd_api.g_RET_STS_SUCCESS;

  IF ( p_transaction_type = 'UPDATE' ) THEN
     -- Values used in IOI to indicate update to NULL.
     g_Upd_Null_CHAR  :=  '!';
     g_Upd_Null_NUM   :=  -999999;
     g_Upd_Null_DATE  :=  NULL;
  ELSE
     g_Upd_Null_CHAR  :=  NULL;
     g_Upd_Null_NUM   :=  NULL;
     g_Upd_Null_DATE  :=  NULL;
  END IF;

  ----------------------------------------------------------------------------
  -- Derive Contract Item Type attribute value based on Service Item, Warranty
  -- and Usage flag attributes (11.5.7).
  ----------------------------------------------------------------------------

  IF ( p_Item_rec.CONTRACT_ITEM_TYPE_CODE = g_MISS_CHAR ) THEN
     IF ( p_Item_rec.VENDOR_WARRANTY_FLAG = 'Y' ) THEN
        l_Contract_Item_Type_Code := 'WARRANTY';
     ELSIF ( p_Item_rec.SERVICE_ITEM_FLAG = 'Y' ) THEN
        l_Contract_Item_Type_Code := 'SERVICE';
     ELSIF ( p_Item_rec.USAGE_ITEM_FLAG = 'Y' ) THEN
        l_Contract_Item_Type_Code := 'USAGE';
     ELSIF (    p_Item_rec.SERVICE_ITEM_FLAG = 'N'
             OR p_Item_rec.VENDOR_WARRANTY_FLAG = 'N' ) THEN
        l_Contract_Item_Type_Code := g_Null_CHAR;
     ELSE
        l_Contract_Item_Type_Code := p_Item_rec.CONTRACT_ITEM_TYPE_CODE;
     END IF;
  ELSE
     l_Contract_Item_Type_Code := p_Item_rec.CONTRACT_ITEM_TYPE_CODE;
  END IF;

  -- Get unique process set id for one record processing.

  SELECT  mtl_system_items_intf_sets_s.NEXTVAL
    INTO  l_set_process_id
  FROM  dual;

  x_set_process_id := l_set_process_id;

  --5565453 : Appsperf issues reducing the shared memory.
  IF(p_Item_rec.ORGANIZATION_ID IS NULL ) THEN
    l_Item_rec.ORGANIZATION_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ORGANIZATION_ID =  g_MISS_NUM  THEN
    l_Item_rec.ORGANIZATION_ID := null;
  END IF;

  IF(p_Item_rec.ORGANIZATION_CODE IS NULL) THEN
    l_Item_rec.ORGANIZATION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ORGANIZATION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.ORGANIZATION_CODE := null;
  END IF;

  IF(p_Item_rec.INVENTORY_ITEM_ID IS NULL ) THEN
    l_Item_rec.INVENTORY_ITEM_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INVENTORY_ITEM_ID =  g_MISS_NUM  THEN
    l_Item_rec.INVENTORY_ITEM_ID := null;
  END IF;

  IF(p_Item_rec.ITEM_NUMBER IS NULL) THEN
    l_Item_rec.ITEM_NUMBER :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ITEM_NUMBER =  g_MISS_CHAR THEN
    l_Item_rec.ITEM_NUMBER := null;
  END IF;

  IF(p_Item_rec.SEGMENT1 IS NULL) THEN
    l_Item_rec.SEGMENT1 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT1 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT1 := null;
  END IF;

  IF(p_Item_rec.SEGMENT2 IS NULL) THEN
    l_Item_rec.SEGMENT2 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT2 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT2 := null;
  END IF;

  IF(p_Item_rec.SEGMENT3 IS NULL) THEN
    l_Item_rec.SEGMENT3 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT3 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT3 := null;
  END IF;

  IF(p_Item_rec.SEGMENT4 IS NULL) THEN
    l_Item_rec.SEGMENT4 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT4 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT4 := null;
  END IF;

  IF(p_Item_rec.SEGMENT5 IS NULL) THEN
    l_Item_rec.SEGMENT5 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT5 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT5 := null;
  END IF;

  IF(p_Item_rec.SEGMENT6 IS NULL) THEN
    l_Item_rec.SEGMENT6 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT6 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT6 := null;
  END IF;

  IF(p_Item_rec.SEGMENT7 IS NULL) THEN
    l_Item_rec.SEGMENT7 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT7 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT7 := null;
  END IF;

  IF(p_Item_rec.SEGMENT8 IS NULL) THEN
    l_Item_rec.SEGMENT8 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT8 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT8 := null;
  END IF;

  IF(p_Item_rec.SEGMENT9 IS NULL) THEN
    l_Item_rec.SEGMENT9 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT9 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT9 := null;
  END IF;

  IF(p_Item_rec.SEGMENT10 IS NULL) THEN
    l_Item_rec.SEGMENT10 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT10 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT10 := null;
  END IF;

  IF(p_Item_rec.SEGMENT11 IS NULL) THEN
    l_Item_rec.SEGMENT11 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT11 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT11 := null;
  END IF;

  IF(p_Item_rec.SEGMENT12 IS NULL) THEN
    l_Item_rec.SEGMENT12 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT12 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT12 := null;
  END IF;

  IF(p_Item_rec.SEGMENT13 IS NULL) THEN
    l_Item_rec.SEGMENT13 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT13 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT13 := null;
  END IF;

  IF(p_Item_rec.SEGMENT14 IS NULL) THEN
    l_Item_rec.SEGMENT14 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT14 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT14 := null;
  END IF;

  IF(p_Item_rec.SEGMENT15 IS NULL) THEN
    l_Item_rec.SEGMENT15 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT15 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT15 := null;
  END IF;

  IF(p_Item_rec.SEGMENT16 IS NULL) THEN
    l_Item_rec.SEGMENT16 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT16 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT16 := null;
  END IF;

  IF(p_Item_rec.SEGMENT17 IS NULL) THEN
    l_Item_rec.SEGMENT17 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT17 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT17 := null;
  END IF;

  IF(p_Item_rec.SEGMENT18 IS NULL) THEN
    l_Item_rec.SEGMENT18 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT18 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT18 := null;
  END IF;

  IF(p_Item_rec.SEGMENT19 IS NULL) THEN
    l_Item_rec.SEGMENT19 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT19 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT19 := null;
  END IF;

  IF(p_Item_rec.SEGMENT20 IS NULL) THEN
    l_Item_rec.SEGMENT20 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SEGMENT20 =  g_MISS_CHAR THEN
    l_Item_rec.SEGMENT20 := null;
  END IF;

  IF(p_Item_rec.SUMMARY_FLAG IS NULL) THEN
    l_Item_rec.SUMMARY_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SUMMARY_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SUMMARY_FLAG := null;
  END IF;

  IF(p_Item_rec.ENABLED_FLAG IS NULL) THEN
    l_Item_rec.ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.START_DATE_ACTIVE =  g_Null_DATE) THEN
    l_Item_rec.START_DATE_ACTIVE :=  g_Upd_Null_DATE;
  ELSIF  p_Item_rec.START_DATE_ACTIVE =  g_MISS_DATE THEN
    l_Item_rec.START_DATE_ACTIVE := null;
  END IF;

  IF(p_Item_rec.END_DATE_ACTIVE =  g_Null_DATE) THEN
    l_Item_rec.END_DATE_ACTIVE :=  g_Upd_Null_DATE;
  ELSIF  p_Item_rec.END_DATE_ACTIVE =  g_MISS_DATE THEN
    l_Item_rec.END_DATE_ACTIVE := null;
  END IF;

  IF(p_Item_rec.DESCRIPTION IS NULL) THEN
    l_Item_rec.DESCRIPTION :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DESCRIPTION =  g_MISS_CHAR THEN
    l_Item_rec.DESCRIPTION := null;
  END IF;

  IF(p_Item_rec.LONG_DESCRIPTION IS NULL) THEN
    l_Item_rec.LONG_DESCRIPTION :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LONG_DESCRIPTION =  g_MISS_CHAR THEN
    l_Item_rec.LONG_DESCRIPTION := null;
  END IF;

  IF(p_Item_rec.PRIMARY_UOM_CODE IS NULL) THEN
    l_Item_rec.PRIMARY_UOM_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PRIMARY_UOM_CODE =  g_MISS_CHAR THEN
    l_Item_rec.PRIMARY_UOM_CODE := null;
  END IF;

  IF(p_Item_rec.PRIMARY_UNIT_OF_MEASURE IS NULL) THEN
    l_Item_rec.PRIMARY_UNIT_OF_MEASURE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PRIMARY_UNIT_OF_MEASURE =  g_MISS_CHAR THEN
    l_Item_rec.PRIMARY_UNIT_OF_MEASURE := null;
  END IF;

  IF(p_Item_rec.ITEM_TYPE IS NULL) THEN
    l_Item_rec.ITEM_TYPE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ITEM_TYPE =  g_MISS_CHAR THEN
    l_Item_rec.ITEM_TYPE := null;
  END IF;

  IF(p_Item_rec.INVENTORY_ITEM_STATUS_CODE IS NULL) THEN
    l_Item_rec.INVENTORY_ITEM_STATUS_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INVENTORY_ITEM_STATUS_CODE =  g_MISS_CHAR THEN
    l_Item_rec.INVENTORY_ITEM_STATUS_CODE := null;
  END IF;

  IF(p_Item_rec.ALLOWED_UNITS_LOOKUP_CODE IS NULL ) THEN
    l_Item_rec.ALLOWED_UNITS_LOOKUP_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ALLOWED_UNITS_LOOKUP_CODE =  g_MISS_NUM  THEN
    l_Item_rec.ALLOWED_UNITS_LOOKUP_CODE := null;
  END IF;

  IF(p_Item_rec.ITEM_CATALOG_GROUP_ID IS NULL ) THEN
    l_Item_rec.ITEM_CATALOG_GROUP_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ITEM_CATALOG_GROUP_ID =  g_MISS_NUM  THEN
    l_Item_rec.ITEM_CATALOG_GROUP_ID := null;
  END IF;

  IF(p_Item_rec.CATALOG_STATUS_FLAG IS NULL) THEN
    l_Item_rec.CATALOG_STATUS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CATALOG_STATUS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CATALOG_STATUS_FLAG := null;
  END IF;

  IF(p_Item_rec.INVENTORY_ITEM_FLAG IS NULL) THEN
    l_Item_rec.INVENTORY_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INVENTORY_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INVENTORY_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.STOCK_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.STOCK_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.STOCK_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.STOCK_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.CHECK_SHORTAGES_FLAG IS NULL) THEN
    l_Item_rec.CHECK_SHORTAGES_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CHECK_SHORTAGES_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CHECK_SHORTAGES_FLAG := null;
  END IF;

  IF(p_Item_rec.REVISION_QTY_CONTROL_CODE IS NULL ) THEN
    l_Item_rec.REVISION_QTY_CONTROL_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.REVISION_QTY_CONTROL_CODE =  g_MISS_NUM  THEN
    l_Item_rec.REVISION_QTY_CONTROL_CODE := null;
  END IF;

  IF(p_Item_rec.RESERVABLE_TYPE IS NULL ) THEN
    l_Item_rec.RESERVABLE_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RESERVABLE_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.RESERVABLE_TYPE := null;
  END IF;

  IF(p_Item_rec.SHELF_LIFE_CODE IS NULL ) THEN
    l_Item_rec.SHELF_LIFE_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SHELF_LIFE_CODE =  g_MISS_NUM  THEN
    l_Item_rec.SHELF_LIFE_CODE := null;
  END IF;

  IF(p_Item_rec.SHELF_LIFE_DAYS IS NULL ) THEN
    l_Item_rec.SHELF_LIFE_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SHELF_LIFE_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.SHELF_LIFE_DAYS := null;
  END IF;

  IF(p_Item_rec.CYCLE_COUNT_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.CYCLE_COUNT_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CYCLE_COUNT_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CYCLE_COUNT_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.NEGATIVE_MEASUREMENT_ERROR IS NULL ) THEN
    l_Item_rec.NEGATIVE_MEASUREMENT_ERROR :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.NEGATIVE_MEASUREMENT_ERROR =  g_MISS_NUM  THEN
    l_Item_rec.NEGATIVE_MEASUREMENT_ERROR := null;
  END IF;

  IF(p_Item_rec.POSITIVE_MEASUREMENT_ERROR IS NULL ) THEN
    l_Item_rec.POSITIVE_MEASUREMENT_ERROR :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.POSITIVE_MEASUREMENT_ERROR =  g_MISS_NUM  THEN
    l_Item_rec.POSITIVE_MEASUREMENT_ERROR := null;
  END IF;

  IF(p_Item_rec.LOT_CONTROL_CODE IS NULL ) THEN
    l_Item_rec.LOT_CONTROL_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.LOT_CONTROL_CODE =  g_MISS_NUM  THEN
    l_Item_rec.LOT_CONTROL_CODE := null;
  END IF;

  IF(p_Item_rec.AUTO_LOT_ALPHA_PREFIX IS NULL) THEN
    l_Item_rec.AUTO_LOT_ALPHA_PREFIX :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.AUTO_LOT_ALPHA_PREFIX =  g_MISS_CHAR THEN
    l_Item_rec.AUTO_LOT_ALPHA_PREFIX := null;
  END IF;

  IF(p_Item_rec.START_AUTO_LOT_NUMBER IS NULL) THEN
    l_Item_rec.START_AUTO_LOT_NUMBER :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.START_AUTO_LOT_NUMBER =  g_MISS_CHAR THEN
    l_Item_rec.START_AUTO_LOT_NUMBER := null;
  END IF;

  IF(p_Item_rec.SERIAL_NUMBER_CONTROL_CODE IS NULL ) THEN
    l_Item_rec.SERIAL_NUMBER_CONTROL_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SERIAL_NUMBER_CONTROL_CODE =  g_MISS_NUM  THEN
    l_Item_rec.SERIAL_NUMBER_CONTROL_CODE := null;
  END IF;

  IF(p_Item_rec.AUTO_SERIAL_ALPHA_PREFIX IS NULL) THEN
    l_Item_rec.AUTO_SERIAL_ALPHA_PREFIX :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.AUTO_SERIAL_ALPHA_PREFIX =  g_MISS_CHAR THEN
    l_Item_rec.AUTO_SERIAL_ALPHA_PREFIX := null;
  END IF;

  IF(p_Item_rec.START_AUTO_SERIAL_NUMBER IS NULL) THEN
    l_Item_rec.START_AUTO_SERIAL_NUMBER :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.START_AUTO_SERIAL_NUMBER =  g_MISS_CHAR THEN
    l_Item_rec.START_AUTO_SERIAL_NUMBER := null;
  END IF;

  IF(p_Item_rec.LOCATION_CONTROL_CODE IS NULL ) THEN
    l_Item_rec.LOCATION_CONTROL_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.LOCATION_CONTROL_CODE =  g_MISS_NUM  THEN
    l_Item_rec.LOCATION_CONTROL_CODE := null;
  END IF;

  IF(p_Item_rec.RESTRICT_SUBINVENTORIES_CODE IS NULL ) THEN
    l_Item_rec.RESTRICT_SUBINVENTORIES_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RESTRICT_SUBINVENTORIES_CODE =  g_MISS_NUM  THEN
    l_Item_rec.RESTRICT_SUBINVENTORIES_CODE := null;
  END IF;

  IF(p_Item_rec.RESTRICT_LOCATORS_CODE IS NULL ) THEN
    l_Item_rec.RESTRICT_LOCATORS_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RESTRICT_LOCATORS_CODE =  g_MISS_NUM  THEN
    l_Item_rec.RESTRICT_LOCATORS_CODE := null;
  END IF;

  IF(p_Item_rec.BOM_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.BOM_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.BOM_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.BOM_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.BOM_ITEM_TYPE IS NULL ) THEN
    l_Item_rec.BOM_ITEM_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.BOM_ITEM_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.BOM_ITEM_TYPE := null;
  END IF;

  IF(p_Item_rec.BASE_ITEM_ID IS NULL ) THEN
    l_Item_rec.BASE_ITEM_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.BASE_ITEM_ID =  g_MISS_NUM  THEN
    l_Item_rec.BASE_ITEM_ID := null;
  END IF;

  IF(p_Item_rec.EFFECTIVITY_CONTROL IS NULL ) THEN
    l_Item_rec.EFFECTIVITY_CONTROL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EFFECTIVITY_CONTROL =  g_MISS_NUM  THEN
    l_Item_rec.EFFECTIVITY_CONTROL := null;
  END IF;

  IF(p_Item_rec.ENG_ITEM_FLAG IS NULL) THEN
    l_Item_rec.ENG_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ENG_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ENG_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.ENGINEERING_ECN_CODE IS NULL) THEN
    l_Item_rec.ENGINEERING_ECN_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ENGINEERING_ECN_CODE =  g_MISS_CHAR THEN
    l_Item_rec.ENGINEERING_ECN_CODE := null;
  END IF;

  IF(p_Item_rec.ENGINEERING_ITEM_ID IS NULL ) THEN
    l_Item_rec.ENGINEERING_ITEM_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ENGINEERING_ITEM_ID =  g_MISS_NUM  THEN
    l_Item_rec.ENGINEERING_ITEM_ID := null;
  END IF;

  IF(p_Item_rec.ENGINEERING_DATE =  g_Null_DATE) THEN
    l_Item_rec.ENGINEERING_DATE :=  g_Upd_Null_DATE;
  ELSIF  p_Item_rec.ENGINEERING_DATE =  g_MISS_DATE THEN
    l_Item_rec.ENGINEERING_DATE := null;
  END IF;

  IF(p_Item_rec.PRODUCT_FAMILY_ITEM_ID IS NULL ) THEN
    l_Item_rec.PRODUCT_FAMILY_ITEM_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PRODUCT_FAMILY_ITEM_ID =  g_MISS_NUM  THEN
    l_Item_rec.PRODUCT_FAMILY_ITEM_ID := null;
  END IF;

  IF(p_Item_rec.AUTO_CREATED_CONFIG_FLAG IS NULL) THEN
    l_Item_rec.AUTO_CREATED_CONFIG_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.AUTO_CREATED_CONFIG_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.AUTO_CREATED_CONFIG_FLAG := null;
  END IF;

  IF(p_Item_rec.MODEL_CONFIG_CLAUSE_NAME IS NULL) THEN
    l_Item_rec.MODEL_CONFIG_CLAUSE_NAME :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.MODEL_CONFIG_CLAUSE_NAME =  g_MISS_CHAR THEN
    l_Item_rec.MODEL_CONFIG_CLAUSE_NAME := null;
  END IF;

  IF(p_Item_rec.COSTING_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.COSTING_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COSTING_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COSTING_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.INVENTORY_ASSET_FLAG IS NULL) THEN
    l_Item_rec.INVENTORY_ASSET_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INVENTORY_ASSET_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INVENTORY_ASSET_FLAG := null;
  END IF;

  IF(p_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG IS NULL) THEN
    l_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG := null;
  END IF;

  IF(p_Item_rec.COST_OF_SALES_ACCOUNT IS NULL ) THEN
    l_Item_rec.COST_OF_SALES_ACCOUNT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.COST_OF_SALES_ACCOUNT =  g_MISS_NUM  THEN
    l_Item_rec.COST_OF_SALES_ACCOUNT := null;
  END IF;

  IF(p_Item_rec.STD_LOT_SIZE IS NULL ) THEN
    l_Item_rec.STD_LOT_SIZE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.STD_LOT_SIZE =  g_MISS_NUM  THEN
    l_Item_rec.STD_LOT_SIZE := null;
  END IF;

  IF(p_Item_rec.PURCHASING_ITEM_FLAG IS NULL) THEN
    l_Item_rec.PURCHASING_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PURCHASING_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PURCHASING_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.PURCHASING_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.PURCHASING_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PURCHASING_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PURCHASING_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG IS NULL) THEN
    l_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG := null;
  END IF;

  IF(p_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG IS NULL) THEN
    l_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG := null;
  END IF;

  IF(p_Item_rec.RFQ_REQUIRED_FLAG IS NULL) THEN
    l_Item_rec.RFQ_REQUIRED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RFQ_REQUIRED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.RFQ_REQUIRED_FLAG := null;
  END IF;

  IF(p_Item_rec.OUTSIDE_OPERATION_FLAG IS NULL) THEN
    l_Item_rec.OUTSIDE_OPERATION_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.OUTSIDE_OPERATION_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.OUTSIDE_OPERATION_FLAG := null;
  END IF;

  IF(p_Item_rec.OUTSIDE_OPERATION_UOM_TYPE IS NULL) THEN
    l_Item_rec.OUTSIDE_OPERATION_UOM_TYPE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.OUTSIDE_OPERATION_UOM_TYPE =  g_MISS_CHAR THEN
    l_Item_rec.OUTSIDE_OPERATION_UOM_TYPE := null;
  END IF;

  IF(p_Item_rec.TAXABLE_FLAG IS NULL) THEN
    l_Item_rec.TAXABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.TAXABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.TAXABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.PURCHASING_TAX_CODE IS NULL) THEN
    l_Item_rec.PURCHASING_TAX_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PURCHASING_TAX_CODE =  g_MISS_CHAR THEN
    l_Item_rec.PURCHASING_TAX_CODE := null;
  END IF;

  IF(p_Item_rec.RECEIPT_REQUIRED_FLAG IS NULL) THEN
    l_Item_rec.RECEIPT_REQUIRED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RECEIPT_REQUIRED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.RECEIPT_REQUIRED_FLAG := null;
  END IF;

  IF(p_Item_rec.INSPECTION_REQUIRED_FLAG IS NULL) THEN
    l_Item_rec.INSPECTION_REQUIRED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INSPECTION_REQUIRED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INSPECTION_REQUIRED_FLAG := null;
  END IF;

  IF(p_Item_rec.BUYER_ID IS NULL ) THEN
    l_Item_rec.BUYER_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.BUYER_ID =  g_MISS_NUM  THEN
    l_Item_rec.BUYER_ID := null;
  END IF;

  IF(p_Item_rec.UNIT_OF_ISSUE IS NULL) THEN
    l_Item_rec.UNIT_OF_ISSUE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.UNIT_OF_ISSUE =  g_MISS_CHAR THEN
    l_Item_rec.UNIT_OF_ISSUE := null;
  END IF;

  IF(p_Item_rec.RECEIVE_CLOSE_TOLERANCE IS NULL ) THEN
    l_Item_rec.RECEIVE_CLOSE_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RECEIVE_CLOSE_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.RECEIVE_CLOSE_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.INVOICE_CLOSE_TOLERANCE IS NULL ) THEN
    l_Item_rec.INVOICE_CLOSE_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INVOICE_CLOSE_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.INVOICE_CLOSE_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.UN_NUMBER_ID IS NULL ) THEN
    l_Item_rec.UN_NUMBER_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UN_NUMBER_ID =  g_MISS_NUM  THEN
    l_Item_rec.UN_NUMBER_ID := null;
  END IF;

  IF(p_Item_rec.HAZARD_CLASS_ID IS NULL ) THEN
    l_Item_rec.HAZARD_CLASS_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.HAZARD_CLASS_ID =  g_MISS_NUM  THEN
    l_Item_rec.HAZARD_CLASS_ID := null;
  END IF;

  IF(p_Item_rec.LIST_PRICE_PER_UNIT IS NULL ) THEN
    l_Item_rec.LIST_PRICE_PER_UNIT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.LIST_PRICE_PER_UNIT =  g_MISS_NUM  THEN
    l_Item_rec.LIST_PRICE_PER_UNIT := null;
  END IF;

  IF(p_Item_rec.MARKET_PRICE IS NULL ) THEN
    l_Item_rec.MARKET_PRICE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MARKET_PRICE =  g_MISS_NUM  THEN
    l_Item_rec.MARKET_PRICE := null;
  END IF;

  IF(p_Item_rec.PRICE_TOLERANCE_PERCENT IS NULL ) THEN
    l_Item_rec.PRICE_TOLERANCE_PERCENT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PRICE_TOLERANCE_PERCENT =  g_MISS_NUM  THEN
    l_Item_rec.PRICE_TOLERANCE_PERCENT := null;
  END IF;

  IF(p_Item_rec.ROUNDING_FACTOR IS NULL ) THEN
    l_Item_rec.ROUNDING_FACTOR :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ROUNDING_FACTOR =  g_MISS_NUM  THEN
    l_Item_rec.ROUNDING_FACTOR := null;
  END IF;

  IF(p_Item_rec.ENCUMBRANCE_ACCOUNT IS NULL ) THEN
    l_Item_rec.ENCUMBRANCE_ACCOUNT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ENCUMBRANCE_ACCOUNT =  g_MISS_NUM  THEN
    l_Item_rec.ENCUMBRANCE_ACCOUNT := null;
  END IF;

  IF(p_Item_rec.EXPENSE_ACCOUNT IS NULL ) THEN
    l_Item_rec.EXPENSE_ACCOUNT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EXPENSE_ACCOUNT =  g_MISS_NUM  THEN
    l_Item_rec.EXPENSE_ACCOUNT := null;
  END IF;

  IF(p_Item_rec.ASSET_CATEGORY_ID IS NULL ) THEN
    l_Item_rec.ASSET_CATEGORY_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ASSET_CATEGORY_ID =  g_MISS_NUM  THEN
    l_Item_rec.ASSET_CATEGORY_ID := null;
  END IF;

  IF(p_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE IS NULL) THEN
    l_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE := null;
  END IF;

  IF(p_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED IS NULL ) THEN
    l_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED := null;
  END IF;

  IF(p_Item_rec.DAYS_LATE_RECEIPT_ALLOWED IS NULL ) THEN
    l_Item_rec.DAYS_LATE_RECEIPT_ALLOWED :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_LATE_RECEIPT_ALLOWED =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_LATE_RECEIPT_ALLOWED := null;
  END IF;

  IF(p_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG IS NULL) THEN
    l_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := null;
  END IF;

  IF(p_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG IS NULL) THEN
    l_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG := null;
  END IF;

  IF(p_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG IS NULL) THEN
    l_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG := null;
  END IF;

  IF(p_Item_rec.QTY_RCV_EXCEPTION_CODE IS NULL) THEN
    l_Item_rec.QTY_RCV_EXCEPTION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.QTY_RCV_EXCEPTION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.QTY_RCV_EXCEPTION_CODE := null;
  END IF;

  IF(p_Item_rec.QTY_RCV_TOLERANCE IS NULL ) THEN
    l_Item_rec.QTY_RCV_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.QTY_RCV_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.QTY_RCV_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.RECEIVING_ROUTING_ID IS NULL ) THEN
    l_Item_rec.RECEIVING_ROUTING_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RECEIVING_ROUTING_ID =  g_MISS_NUM  THEN
    l_Item_rec.RECEIVING_ROUTING_ID := null;
  END IF;

  IF(p_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE IS NULL) THEN
    l_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE := null;
  END IF;

  IF(p_Item_rec.WEIGHT_UOM_CODE IS NULL) THEN
    l_Item_rec.WEIGHT_UOM_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.WEIGHT_UOM_CODE =  g_MISS_CHAR THEN
    l_Item_rec.WEIGHT_UOM_CODE := null;
  END IF;

  IF(p_Item_rec.UNIT_WEIGHT IS NULL ) THEN
    l_Item_rec.UNIT_WEIGHT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNIT_WEIGHT =  g_MISS_NUM  THEN
    l_Item_rec.UNIT_WEIGHT := null;
  END IF;

  IF(p_Item_rec.VOLUME_UOM_CODE IS NULL) THEN
    l_Item_rec.VOLUME_UOM_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.VOLUME_UOM_CODE =  g_MISS_CHAR THEN
    l_Item_rec.VOLUME_UOM_CODE := null;
  END IF;

  IF(p_Item_rec.UNIT_VOLUME IS NULL ) THEN
    l_Item_rec.UNIT_VOLUME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNIT_VOLUME =  g_MISS_NUM  THEN
    l_Item_rec.UNIT_VOLUME := null;
  END IF;

  IF(p_Item_rec.CONTAINER_ITEM_FLAG IS NULL) THEN
    l_Item_rec.CONTAINER_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CONTAINER_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CONTAINER_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.VEHICLE_ITEM_FLAG IS NULL) THEN
    l_Item_rec.VEHICLE_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.VEHICLE_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.VEHICLE_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.CONTAINER_TYPE_CODE IS NULL) THEN
    l_Item_rec.CONTAINER_TYPE_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CONTAINER_TYPE_CODE =  g_MISS_CHAR THEN
    l_Item_rec.CONTAINER_TYPE_CODE := null;
  END IF;

  IF(p_Item_rec.INTERNAL_VOLUME IS NULL ) THEN
    l_Item_rec.INTERNAL_VOLUME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INTERNAL_VOLUME =  g_MISS_NUM  THEN
    l_Item_rec.INTERNAL_VOLUME := null;
  END IF;

  IF(p_Item_rec.MAXIMUM_LOAD_WEIGHT IS NULL ) THEN
    l_Item_rec.MAXIMUM_LOAD_WEIGHT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MAXIMUM_LOAD_WEIGHT =  g_MISS_NUM  THEN
    l_Item_rec.MAXIMUM_LOAD_WEIGHT := null;
  END IF;

  IF(p_Item_rec.MINIMUM_FILL_PERCENT IS NULL ) THEN
    l_Item_rec.MINIMUM_FILL_PERCENT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MINIMUM_FILL_PERCENT =  g_MISS_NUM  THEN
    l_Item_rec.MINIMUM_FILL_PERCENT := null;
  END IF;

  IF(p_Item_rec.INVENTORY_PLANNING_CODE IS NULL ) THEN
    l_Item_rec.INVENTORY_PLANNING_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INVENTORY_PLANNING_CODE =  g_MISS_NUM  THEN
    l_Item_rec.INVENTORY_PLANNING_CODE := null;
  END IF;

  IF(p_Item_rec.PLANNER_CODE IS NULL) THEN
    l_Item_rec.PLANNER_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PLANNER_CODE =  g_MISS_CHAR THEN
    l_Item_rec.PLANNER_CODE := null;
  END IF;

  IF(p_Item_rec.PLANNING_MAKE_BUY_CODE IS NULL ) THEN
    l_Item_rec.PLANNING_MAKE_BUY_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PLANNING_MAKE_BUY_CODE =  g_MISS_NUM  THEN
    l_Item_rec.PLANNING_MAKE_BUY_CODE := null;
  END IF;

  IF(p_Item_rec.MIN_MINMAX_QUANTITY IS NULL ) THEN
    l_Item_rec.MIN_MINMAX_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MIN_MINMAX_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.MIN_MINMAX_QUANTITY := null;
  END IF;

  IF(p_Item_rec.MAX_MINMAX_QUANTITY IS NULL ) THEN
    l_Item_rec.MAX_MINMAX_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MAX_MINMAX_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.MAX_MINMAX_QUANTITY := null;
  END IF;

  IF(p_Item_rec.MINIMUM_ORDER_QUANTITY IS NULL ) THEN
    l_Item_rec.MINIMUM_ORDER_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MINIMUM_ORDER_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.MINIMUM_ORDER_QUANTITY := null;
  END IF;

  IF(p_Item_rec.MAXIMUM_ORDER_QUANTITY IS NULL ) THEN
    l_Item_rec.MAXIMUM_ORDER_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MAXIMUM_ORDER_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.MAXIMUM_ORDER_QUANTITY := null;
  END IF;

  IF(p_Item_rec.ORDER_COST IS NULL ) THEN
    l_Item_rec.ORDER_COST :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ORDER_COST =  g_MISS_NUM  THEN
    l_Item_rec.ORDER_COST := null;
  END IF;

  IF(p_Item_rec.CARRYING_COST IS NULL ) THEN
    l_Item_rec.CARRYING_COST :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CARRYING_COST =  g_MISS_NUM  THEN
    l_Item_rec.CARRYING_COST := null;
  END IF;

  IF(p_Item_rec.SOURCE_TYPE IS NULL ) THEN
    l_Item_rec.SOURCE_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SOURCE_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.SOURCE_TYPE := null;
  END IF;

  IF(p_Item_rec.SOURCE_ORGANIZATION_ID IS NULL ) THEN
    l_Item_rec.SOURCE_ORGANIZATION_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SOURCE_ORGANIZATION_ID =  g_MISS_NUM  THEN
    l_Item_rec.SOURCE_ORGANIZATION_ID := null;
  END IF;

  IF(p_Item_rec.SOURCE_SUBINVENTORY IS NULL) THEN
    l_Item_rec.SOURCE_SUBINVENTORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SOURCE_SUBINVENTORY =  g_MISS_CHAR THEN
    l_Item_rec.SOURCE_SUBINVENTORY := null;
  END IF;

  IF(p_Item_rec.MRP_SAFETY_STOCK_CODE IS NULL ) THEN
    l_Item_rec.MRP_SAFETY_STOCK_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MRP_SAFETY_STOCK_CODE =  g_MISS_NUM  THEN
    l_Item_rec.MRP_SAFETY_STOCK_CODE := null;
  END IF;

  IF(p_Item_rec.SAFETY_STOCK_BUCKET_DAYS IS NULL ) THEN
    l_Item_rec.SAFETY_STOCK_BUCKET_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SAFETY_STOCK_BUCKET_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.SAFETY_STOCK_BUCKET_DAYS := null;
  END IF;

  IF(p_Item_rec.MRP_SAFETY_STOCK_PERCENT IS NULL ) THEN
    l_Item_rec.MRP_SAFETY_STOCK_PERCENT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MRP_SAFETY_STOCK_PERCENT =  g_MISS_NUM  THEN
    l_Item_rec.MRP_SAFETY_STOCK_PERCENT := null;
  END IF;

  IF(p_Item_rec.FIXED_ORDER_QUANTITY IS NULL ) THEN
    l_Item_rec.FIXED_ORDER_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FIXED_ORDER_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.FIXED_ORDER_QUANTITY := null;
  END IF;

  IF(p_Item_rec.FIXED_DAYS_SUPPLY IS NULL ) THEN
    l_Item_rec.FIXED_DAYS_SUPPLY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FIXED_DAYS_SUPPLY =  g_MISS_NUM  THEN
    l_Item_rec.FIXED_DAYS_SUPPLY := null;
  END IF;

  IF(p_Item_rec.FIXED_LOT_MULTIPLIER IS NULL ) THEN
    l_Item_rec.FIXED_LOT_MULTIPLIER :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FIXED_LOT_MULTIPLIER =  g_MISS_NUM  THEN
    l_Item_rec.FIXED_LOT_MULTIPLIER := null;
  END IF;

  IF(p_Item_rec.MRP_PLANNING_CODE IS NULL ) THEN
    l_Item_rec.MRP_PLANNING_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MRP_PLANNING_CODE =  g_MISS_NUM  THEN
    l_Item_rec.MRP_PLANNING_CODE := null;
  END IF;

  IF(p_Item_rec.ATO_FORECAST_CONTROL IS NULL ) THEN
    l_Item_rec.ATO_FORECAST_CONTROL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ATO_FORECAST_CONTROL =  g_MISS_NUM  THEN
    l_Item_rec.ATO_FORECAST_CONTROL := null;
  END IF;

  IF(p_Item_rec.PLANNING_EXCEPTION_SET IS NULL) THEN
    l_Item_rec.PLANNING_EXCEPTION_SET :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PLANNING_EXCEPTION_SET =  g_MISS_CHAR THEN
    l_Item_rec.PLANNING_EXCEPTION_SET := null;
  END IF;

  IF(p_Item_rec.END_ASSEMBLY_PEGGING_FLAG IS NULL) THEN
    l_Item_rec.END_ASSEMBLY_PEGGING_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.END_ASSEMBLY_PEGGING_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.END_ASSEMBLY_PEGGING_FLAG := null;
  END IF;

  IF(p_Item_rec.SHRINKAGE_RATE IS NULL ) THEN
    l_Item_rec.SHRINKAGE_RATE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SHRINKAGE_RATE =  g_MISS_NUM  THEN
    l_Item_rec.SHRINKAGE_RATE := null;
  END IF;

  IF(p_Item_rec.ROUNDING_CONTROL_TYPE IS NULL ) THEN
    l_Item_rec.ROUNDING_CONTROL_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ROUNDING_CONTROL_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.ROUNDING_CONTROL_TYPE := null;
  END IF;

  IF(p_Item_rec.ACCEPTABLE_EARLY_DAYS IS NULL ) THEN
    l_Item_rec.ACCEPTABLE_EARLY_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ACCEPTABLE_EARLY_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.ACCEPTABLE_EARLY_DAYS := null;
  END IF;

  IF(p_Item_rec.REPETITIVE_PLANNING_FLAG IS NULL) THEN
    l_Item_rec.REPETITIVE_PLANNING_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.REPETITIVE_PLANNING_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.REPETITIVE_PLANNING_FLAG := null;
  END IF;

  IF(p_Item_rec.OVERRUN_PERCENTAGE IS NULL ) THEN
    l_Item_rec.OVERRUN_PERCENTAGE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OVERRUN_PERCENTAGE =  g_MISS_NUM  THEN
    l_Item_rec.OVERRUN_PERCENTAGE := null;
  END IF;

  IF(p_Item_rec.ACCEPTABLE_RATE_INCREASE IS NULL ) THEN
    l_Item_rec.ACCEPTABLE_RATE_INCREASE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ACCEPTABLE_RATE_INCREASE =  g_MISS_NUM  THEN
    l_Item_rec.ACCEPTABLE_RATE_INCREASE := null;
  END IF;

  IF(p_Item_rec.ACCEPTABLE_RATE_DECREASE IS NULL ) THEN
    l_Item_rec.ACCEPTABLE_RATE_DECREASE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ACCEPTABLE_RATE_DECREASE =  g_MISS_NUM  THEN
    l_Item_rec.ACCEPTABLE_RATE_DECREASE := null;
  END IF;

  IF(p_Item_rec.MRP_CALCULATE_ATP_FLAG IS NULL) THEN
    l_Item_rec.MRP_CALCULATE_ATP_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.MRP_CALCULATE_ATP_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.MRP_CALCULATE_ATP_FLAG := null;
  END IF;

  IF(p_Item_rec.AUTO_REDUCE_MPS IS NULL ) THEN
    l_Item_rec.AUTO_REDUCE_MPS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.AUTO_REDUCE_MPS =  g_MISS_NUM  THEN
    l_Item_rec.AUTO_REDUCE_MPS := null;
  END IF;

  IF(p_Item_rec.PLANNING_TIME_FENCE_CODE IS NULL ) THEN
    l_Item_rec.PLANNING_TIME_FENCE_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PLANNING_TIME_FENCE_CODE =  g_MISS_NUM  THEN
    l_Item_rec.PLANNING_TIME_FENCE_CODE := null;
  END IF;

  IF(p_Item_rec.PLANNING_TIME_FENCE_DAYS IS NULL ) THEN
    l_Item_rec.PLANNING_TIME_FENCE_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PLANNING_TIME_FENCE_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.PLANNING_TIME_FENCE_DAYS := null;
  END IF;

  IF(p_Item_rec.DEMAND_TIME_FENCE_CODE IS NULL ) THEN
    l_Item_rec.DEMAND_TIME_FENCE_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DEMAND_TIME_FENCE_CODE =  g_MISS_NUM  THEN
    l_Item_rec.DEMAND_TIME_FENCE_CODE := null;
  END IF;

  IF(p_Item_rec.DEMAND_TIME_FENCE_DAYS IS NULL ) THEN
    l_Item_rec.DEMAND_TIME_FENCE_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DEMAND_TIME_FENCE_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.DEMAND_TIME_FENCE_DAYS := null;
  END IF;

  IF(p_Item_rec.RELEASE_TIME_FENCE_CODE IS NULL ) THEN
    l_Item_rec.RELEASE_TIME_FENCE_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RELEASE_TIME_FENCE_CODE =  g_MISS_NUM  THEN
    l_Item_rec.RELEASE_TIME_FENCE_CODE := null;
  END IF;

  IF(p_Item_rec.RELEASE_TIME_FENCE_DAYS IS NULL ) THEN
    l_Item_rec.RELEASE_TIME_FENCE_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RELEASE_TIME_FENCE_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.RELEASE_TIME_FENCE_DAYS := null;
  END IF;

  IF(p_Item_rec.PREPROCESSING_LEAD_TIME IS NULL ) THEN
    l_Item_rec.PREPROCESSING_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PREPROCESSING_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.PREPROCESSING_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.FULL_LEAD_TIME IS NULL ) THEN
    l_Item_rec.FULL_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FULL_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.FULL_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.POSTPROCESSING_LEAD_TIME IS NULL ) THEN
    l_Item_rec.POSTPROCESSING_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.POSTPROCESSING_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.POSTPROCESSING_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.FIXED_LEAD_TIME IS NULL ) THEN
    l_Item_rec.FIXED_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FIXED_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.FIXED_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.VARIABLE_LEAD_TIME IS NULL ) THEN
    l_Item_rec.VARIABLE_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VARIABLE_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.VARIABLE_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.CUM_MANUFACTURING_LEAD_TIME IS NULL ) THEN
    l_Item_rec.CUM_MANUFACTURING_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CUM_MANUFACTURING_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.CUM_MANUFACTURING_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME IS NULL ) THEN
    l_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME =  g_MISS_NUM  THEN
    l_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME := null;
  END IF;

  IF(p_Item_rec.LEAD_TIME_LOT_SIZE IS NULL ) THEN
    l_Item_rec.LEAD_TIME_LOT_SIZE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.LEAD_TIME_LOT_SIZE =  g_MISS_NUM  THEN
    l_Item_rec.LEAD_TIME_LOT_SIZE := null;
  END IF;

  IF(p_Item_rec.BUILD_IN_WIP_FLAG IS NULL) THEN
    l_Item_rec.BUILD_IN_WIP_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.BUILD_IN_WIP_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.BUILD_IN_WIP_FLAG := null;
  END IF;

  IF(p_Item_rec.WIP_SUPPLY_TYPE IS NULL ) THEN
    l_Item_rec.WIP_SUPPLY_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.WIP_SUPPLY_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.WIP_SUPPLY_TYPE := null;
  END IF;

  IF(p_Item_rec.WIP_SUPPLY_SUBINVENTORY IS NULL) THEN
    l_Item_rec.WIP_SUPPLY_SUBINVENTORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.WIP_SUPPLY_SUBINVENTORY =  g_MISS_CHAR THEN
    l_Item_rec.WIP_SUPPLY_SUBINVENTORY := null;
  END IF;

  IF(p_Item_rec.WIP_SUPPLY_LOCATOR_ID IS NULL ) THEN
    l_Item_rec.WIP_SUPPLY_LOCATOR_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.WIP_SUPPLY_LOCATOR_ID =  g_MISS_NUM  THEN
    l_Item_rec.WIP_SUPPLY_LOCATOR_ID := null;
  END IF;

  IF(p_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE IS NULL ) THEN
    l_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE := null;
  END IF;

  IF(p_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE IS NULL ) THEN
    l_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE =  g_MISS_NUM  THEN
    l_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE := null;
  END IF;

  IF(p_Item_rec.CUSTOMER_ORDER_FLAG IS NULL) THEN
    l_Item_rec.CUSTOMER_ORDER_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CUSTOMER_ORDER_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CUSTOMER_ORDER_FLAG := null;
  END IF;

  IF(p_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.SHIPPABLE_ITEM_FLAG IS NULL) THEN
    l_Item_rec.SHIPPABLE_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SHIPPABLE_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SHIPPABLE_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.INTERNAL_ORDER_FLAG IS NULL) THEN
    l_Item_rec.INTERNAL_ORDER_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INTERNAL_ORDER_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INTERNAL_ORDER_FLAG := null;
  END IF;

  IF(p_Item_rec.INTERNAL_ORDER_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INTERNAL_ORDER_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.SO_TRANSACTIONS_FLAG IS NULL) THEN
    l_Item_rec.SO_TRANSACTIONS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SO_TRANSACTIONS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SO_TRANSACTIONS_FLAG := null;
  END IF;

  IF(p_Item_rec.PICK_COMPONENTS_FLAG IS NULL) THEN
    l_Item_rec.PICK_COMPONENTS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PICK_COMPONENTS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PICK_COMPONENTS_FLAG := null;
  END IF;

  IF(p_Item_rec.ATP_FLAG IS NULL) THEN
    l_Item_rec.ATP_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATP_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ATP_FLAG := null;
  END IF;

  IF(p_Item_rec.REPLENISH_TO_ORDER_FLAG IS NULL) THEN
    l_Item_rec.REPLENISH_TO_ORDER_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.REPLENISH_TO_ORDER_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.REPLENISH_TO_ORDER_FLAG := null;
  END IF;

  IF(p_Item_rec.ATP_RULE_ID IS NULL ) THEN
    l_Item_rec.ATP_RULE_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ATP_RULE_ID =  g_MISS_NUM  THEN
    l_Item_rec.ATP_RULE_ID := null;
  END IF;

  IF(p_Item_rec.ATP_COMPONENTS_FLAG IS NULL) THEN
    l_Item_rec.ATP_COMPONENTS_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATP_COMPONENTS_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ATP_COMPONENTS_FLAG := null;
  END IF;

  IF(p_Item_rec.SHIP_MODEL_COMPLETE_FLAG IS NULL) THEN
    l_Item_rec.SHIP_MODEL_COMPLETE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SHIP_MODEL_COMPLETE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SHIP_MODEL_COMPLETE_FLAG := null;
  END IF;

  IF(p_Item_rec.PICKING_RULE_ID IS NULL ) THEN
    l_Item_rec.PICKING_RULE_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PICKING_RULE_ID =  g_MISS_NUM  THEN
    l_Item_rec.PICKING_RULE_ID := null;
  END IF;

  IF(p_Item_rec.COLLATERAL_FLAG IS NULL) THEN
    l_Item_rec.COLLATERAL_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COLLATERAL_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COLLATERAL_FLAG := null;
  END IF;

  IF(p_Item_rec.DEFAULT_SHIPPING_ORG IS NULL ) THEN
    l_Item_rec.DEFAULT_SHIPPING_ORG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DEFAULT_SHIPPING_ORG =  g_MISS_NUM  THEN
    l_Item_rec.DEFAULT_SHIPPING_ORG := null;
  END IF;

  IF(p_Item_rec.RETURNABLE_FLAG IS NULL) THEN
    l_Item_rec.RETURNABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RETURNABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.RETURNABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.RETURN_INSPECTION_REQUIREMENT IS NULL ) THEN
    l_Item_rec.RETURN_INSPECTION_REQUIREMENT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RETURN_INSPECTION_REQUIREMENT =  g_MISS_NUM  THEN
    l_Item_rec.RETURN_INSPECTION_REQUIREMENT := null;
  END IF;

  IF(p_Item_rec.OVER_SHIPMENT_TOLERANCE IS NULL ) THEN
    l_Item_rec.OVER_SHIPMENT_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OVER_SHIPMENT_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.OVER_SHIPMENT_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.UNDER_SHIPMENT_TOLERANCE IS NULL ) THEN
    l_Item_rec.UNDER_SHIPMENT_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNDER_SHIPMENT_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.UNDER_SHIPMENT_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.OVER_RETURN_TOLERANCE IS NULL ) THEN
    l_Item_rec.OVER_RETURN_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OVER_RETURN_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.OVER_RETURN_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.UNDER_RETURN_TOLERANCE IS NULL ) THEN
    l_Item_rec.UNDER_RETURN_TOLERANCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNDER_RETURN_TOLERANCE =  g_MISS_NUM  THEN
    l_Item_rec.UNDER_RETURN_TOLERANCE := null;
  END IF;

  IF(p_Item_rec.INVOICEABLE_ITEM_FLAG IS NULL) THEN
    l_Item_rec.INVOICEABLE_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INVOICEABLE_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INVOICEABLE_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.INVOICE_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.INVOICE_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INVOICE_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INVOICE_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.ACCOUNTING_RULE_ID IS NULL ) THEN
    l_Item_rec.ACCOUNTING_RULE_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ACCOUNTING_RULE_ID =  g_MISS_NUM  THEN
    l_Item_rec.ACCOUNTING_RULE_ID := null;
  END IF;

  IF(p_Item_rec.INVOICING_RULE_ID IS NULL ) THEN
    l_Item_rec.INVOICING_RULE_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INVOICING_RULE_ID =  g_MISS_NUM  THEN
    l_Item_rec.INVOICING_RULE_ID := null;
  END IF;

  IF(p_Item_rec.TAX_CODE IS NULL) THEN
    l_Item_rec.TAX_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.TAX_CODE =  g_MISS_CHAR THEN
    l_Item_rec.TAX_CODE := null;
  END IF;

  IF(p_Item_rec.SALES_ACCOUNT IS NULL ) THEN
    l_Item_rec.SALES_ACCOUNT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SALES_ACCOUNT =  g_MISS_NUM  THEN
    l_Item_rec.SALES_ACCOUNT := null;
  END IF;

  IF(p_Item_rec.PAYMENT_TERMS_ID IS NULL ) THEN
    l_Item_rec.PAYMENT_TERMS_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PAYMENT_TERMS_ID =  g_MISS_NUM  THEN
    l_Item_rec.PAYMENT_TERMS_ID := null;
  END IF;

  IF(p_Item_rec.COVERAGE_SCHEDULE_ID IS NULL ) THEN
    l_Item_rec.COVERAGE_SCHEDULE_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.COVERAGE_SCHEDULE_ID =  g_MISS_NUM  THEN
    l_Item_rec.COVERAGE_SCHEDULE_ID := null;
  END IF;

  IF(p_Item_rec.SERVICE_DURATION IS NULL ) THEN
    l_Item_rec.SERVICE_DURATION :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SERVICE_DURATION =  g_MISS_NUM  THEN
    l_Item_rec.SERVICE_DURATION := null;
  END IF;

  IF(p_Item_rec.SERVICE_DURATION_PERIOD_CODE IS NULL) THEN
    l_Item_rec.SERVICE_DURATION_PERIOD_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERVICE_DURATION_PERIOD_CODE =  g_MISS_CHAR THEN
    l_Item_rec.SERVICE_DURATION_PERIOD_CODE := null;
  END IF;

  IF(p_Item_rec.SERVICEABLE_PRODUCT_FLAG IS NULL) THEN
    l_Item_rec.SERVICEABLE_PRODUCT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERVICEABLE_PRODUCT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SERVICEABLE_PRODUCT_FLAG := null;
  END IF;

  IF(p_Item_rec.SERVICE_STARTING_DELAY IS NULL ) THEN
    l_Item_rec.SERVICE_STARTING_DELAY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SERVICE_STARTING_DELAY =  g_MISS_NUM  THEN
    l_Item_rec.SERVICE_STARTING_DELAY := null;
  END IF;

  IF(p_Item_rec.MATERIAL_BILLABLE_FLAG IS NULL) THEN
    l_Item_rec.MATERIAL_BILLABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.MATERIAL_BILLABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.MATERIAL_BILLABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.SERVICEABLE_COMPONENT_FLAG IS NULL) THEN
    l_Item_rec.SERVICEABLE_COMPONENT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERVICEABLE_COMPONENT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SERVICEABLE_COMPONENT_FLAG := null;
  END IF;

  IF(p_Item_rec.PREVENTIVE_MAINTENANCE_FLAG IS NULL) THEN
    l_Item_rec.PREVENTIVE_MAINTENANCE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PREVENTIVE_MAINTENANCE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PREVENTIVE_MAINTENANCE_FLAG := null;
  END IF;

  IF(p_Item_rec.PRORATE_SERVICE_FLAG IS NULL) THEN
    l_Item_rec.PRORATE_SERVICE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PRORATE_SERVICE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PRORATE_SERVICE_FLAG := null;
  END IF;

  IF(p_Item_rec.WH_UPDATE_DATE =  g_Null_DATE) THEN
    l_Item_rec.WH_UPDATE_DATE :=  g_Upd_Null_DATE;
  ELSIF  p_Item_rec.WH_UPDATE_DATE =  g_MISS_DATE THEN
    l_Item_rec.WH_UPDATE_DATE := null;
  END IF;

  IF(p_Item_rec.EQUIPMENT_TYPE IS NULL ) THEN
    l_Item_rec.EQUIPMENT_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EQUIPMENT_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.EQUIPMENT_TYPE := null;
  END IF;

  IF(p_Item_rec.RECOVERED_PART_DISP_CODE IS NULL) THEN
    l_Item_rec.RECOVERED_PART_DISP_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RECOVERED_PART_DISP_CODE =  g_MISS_CHAR THEN
    l_Item_rec.RECOVERED_PART_DISP_CODE := null;
  END IF;

  IF(p_Item_rec.DEFECT_TRACKING_ON_FLAG IS NULL) THEN
    l_Item_rec.DEFECT_TRACKING_ON_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DEFECT_TRACKING_ON_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.DEFECT_TRACKING_ON_FLAG := null;
  END IF;

  IF(p_Item_rec.EVENT_FLAG IS NULL) THEN
    l_Item_rec.EVENT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EVENT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.EVENT_FLAG := null;
  END IF;

  IF(p_Item_rec.ELECTRONIC_FLAG IS NULL) THEN
    l_Item_rec.ELECTRONIC_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ELECTRONIC_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ELECTRONIC_FLAG := null;
  END IF;

  IF(p_Item_rec.DOWNLOADABLE_FLAG IS NULL) THEN
    l_Item_rec.DOWNLOADABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DOWNLOADABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.DOWNLOADABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG IS NULL) THEN
    l_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG := null;
  END IF;

  IF(p_Item_rec.COUPON_EXEMPT_FLAG IS NULL) THEN
    l_Item_rec.COUPON_EXEMPT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COUPON_EXEMPT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COUPON_EXEMPT_FLAG := null;
  END IF;

  IF(p_Item_rec.COMMS_NL_TRACKABLE_FLAG IS NULL) THEN
    l_Item_rec.COMMS_NL_TRACKABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COMMS_NL_TRACKABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COMMS_NL_TRACKABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.ASSET_CREATION_CODE IS NULL) THEN
    l_Item_rec.ASSET_CREATION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ASSET_CREATION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.ASSET_CREATION_CODE := null;
  END IF;

  IF(p_Item_rec.COMMS_ACTIVATION_REQD_FLAG IS NULL) THEN
    l_Item_rec.COMMS_ACTIVATION_REQD_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COMMS_ACTIVATION_REQD_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COMMS_ACTIVATION_REQD_FLAG := null;
  END IF;

  IF(p_Item_rec.WEB_STATUS IS NULL) THEN
    l_Item_rec.WEB_STATUS :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.WEB_STATUS =  g_MISS_CHAR THEN
    l_Item_rec.WEB_STATUS := null;
  END IF;

  IF(p_Item_rec.ORDERABLE_ON_WEB_FLAG IS NULL) THEN
    l_Item_rec.ORDERABLE_ON_WEB_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ORDERABLE_ON_WEB_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.ORDERABLE_ON_WEB_FLAG := null;
  END IF;

  IF(p_Item_rec.BACK_ORDERABLE_FLAG IS NULL) THEN
    l_Item_rec.BACK_ORDERABLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.BACK_ORDERABLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.BACK_ORDERABLE_FLAG := null;
  END IF;

  IF(p_Item_rec.INDIVISIBLE_FLAG IS NULL) THEN
    l_Item_rec.INDIVISIBLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.INDIVISIBLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.INDIVISIBLE_FLAG := null;
  END IF;

  IF(p_Item_rec.DIMENSION_UOM_CODE IS NULL) THEN
    l_Item_rec.DIMENSION_UOM_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DIMENSION_UOM_CODE =  g_MISS_CHAR THEN
    l_Item_rec.DIMENSION_UOM_CODE := null;
  END IF;

  IF(p_Item_rec.UNIT_LENGTH IS NULL ) THEN
    l_Item_rec.UNIT_LENGTH :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNIT_LENGTH =  g_MISS_NUM  THEN
    l_Item_rec.UNIT_LENGTH := null;
  END IF;

  IF(p_Item_rec.UNIT_WIDTH IS NULL ) THEN
    l_Item_rec.UNIT_WIDTH :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNIT_WIDTH =  g_MISS_NUM  THEN
    l_Item_rec.UNIT_WIDTH := null;
  END IF;

  IF(p_Item_rec.UNIT_HEIGHT IS NULL ) THEN
    l_Item_rec.UNIT_HEIGHT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.UNIT_HEIGHT =  g_MISS_NUM  THEN
    l_Item_rec.UNIT_HEIGHT := null;
  END IF;

  IF(p_Item_rec.BULK_PICKED_FLAG IS NULL) THEN
    l_Item_rec.BULK_PICKED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.BULK_PICKED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.BULK_PICKED_FLAG := null;
  END IF;

  IF(p_Item_rec.LOT_STATUS_ENABLED IS NULL) THEN
    l_Item_rec.LOT_STATUS_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_STATUS_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.LOT_STATUS_ENABLED := null;
  END IF;

  IF(p_Item_rec.DEFAULT_LOT_STATUS_ID IS NULL ) THEN
    l_Item_rec.DEFAULT_LOT_STATUS_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DEFAULT_LOT_STATUS_ID =  g_MISS_NUM  THEN
    l_Item_rec.DEFAULT_LOT_STATUS_ID := null;
  END IF;

  IF(p_Item_rec.SERIAL_STATUS_ENABLED IS NULL) THEN
    l_Item_rec.SERIAL_STATUS_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERIAL_STATUS_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.SERIAL_STATUS_ENABLED := null;
  END IF;

  IF(p_Item_rec.DEFAULT_SERIAL_STATUS_ID IS NULL ) THEN
    l_Item_rec.DEFAULT_SERIAL_STATUS_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DEFAULT_SERIAL_STATUS_ID =  g_MISS_NUM  THEN
    l_Item_rec.DEFAULT_SERIAL_STATUS_ID := null;
  END IF;

  IF(p_Item_rec.LOT_SPLIT_ENABLED IS NULL) THEN
    l_Item_rec.LOT_SPLIT_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_SPLIT_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.LOT_SPLIT_ENABLED := null;
  END IF;

  IF(p_Item_rec.LOT_MERGE_ENABLED IS NULL) THEN
    l_Item_rec.LOT_MERGE_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_MERGE_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.LOT_MERGE_ENABLED := null;
  END IF;

  IF(p_Item_rec.INVENTORY_CARRY_PENALTY IS NULL ) THEN
    l_Item_rec.INVENTORY_CARRY_PENALTY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.INVENTORY_CARRY_PENALTY =  g_MISS_NUM  THEN
    l_Item_rec.INVENTORY_CARRY_PENALTY := null;
  END IF;

  IF(p_Item_rec.OPERATION_SLACK_PENALTY IS NULL ) THEN
    l_Item_rec.OPERATION_SLACK_PENALTY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OPERATION_SLACK_PENALTY =  g_MISS_NUM  THEN
    l_Item_rec.OPERATION_SLACK_PENALTY := null;
  END IF;

  IF(p_Item_rec.FINANCING_ALLOWED_FLAG IS NULL) THEN
    l_Item_rec.FINANCING_ALLOWED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.FINANCING_ALLOWED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.FINANCING_ALLOWED_FLAG := null;
  END IF;

  IF(p_Item_rec.EAM_ITEM_TYPE IS NULL ) THEN
    l_Item_rec.EAM_ITEM_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EAM_ITEM_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.EAM_ITEM_TYPE := null;
  END IF;

  IF(p_Item_rec.EAM_ACTIVITY_TYPE_CODE IS NULL) THEN
    l_Item_rec.EAM_ACTIVITY_TYPE_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EAM_ACTIVITY_TYPE_CODE =  g_MISS_CHAR THEN
    l_Item_rec.EAM_ACTIVITY_TYPE_CODE := null;
  END IF;

  IF(p_Item_rec.EAM_ACTIVITY_CAUSE_CODE IS NULL) THEN
    l_Item_rec.EAM_ACTIVITY_CAUSE_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EAM_ACTIVITY_CAUSE_CODE =  g_MISS_CHAR THEN
    l_Item_rec.EAM_ACTIVITY_CAUSE_CODE := null;
  END IF;

  IF(p_Item_rec.EAM_ACT_NOTIFICATION_FLAG IS NULL) THEN
    l_Item_rec.EAM_ACT_NOTIFICATION_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EAM_ACT_NOTIFICATION_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.EAM_ACT_NOTIFICATION_FLAG := null;
  END IF;

  IF(p_Item_rec.EAM_ACT_SHUTDOWN_STATUS IS NULL) THEN
    l_Item_rec.EAM_ACT_SHUTDOWN_STATUS :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EAM_ACT_SHUTDOWN_STATUS =  g_MISS_CHAR THEN
    l_Item_rec.EAM_ACT_SHUTDOWN_STATUS := null;
  END IF;

  IF(p_Item_rec.DUAL_UOM_CONTROL IS NULL ) THEN
    l_Item_rec.DUAL_UOM_CONTROL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DUAL_UOM_CONTROL =  g_MISS_NUM  THEN
    l_Item_rec.DUAL_UOM_CONTROL := null;
  END IF;

  IF(p_Item_rec.SECONDARY_UOM_CODE IS NULL) THEN
    l_Item_rec.SECONDARY_UOM_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SECONDARY_UOM_CODE =  g_MISS_CHAR THEN
    l_Item_rec.SECONDARY_UOM_CODE := null;
  END IF;

  IF(p_Item_rec.DUAL_UOM_DEVIATION_HIGH IS NULL ) THEN
    l_Item_rec.DUAL_UOM_DEVIATION_HIGH :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DUAL_UOM_DEVIATION_HIGH =  g_MISS_NUM  THEN
    l_Item_rec.DUAL_UOM_DEVIATION_HIGH := null;
  END IF;

  IF(p_Item_rec.DUAL_UOM_DEVIATION_LOW IS NULL ) THEN
    l_Item_rec.DUAL_UOM_DEVIATION_LOW :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DUAL_UOM_DEVIATION_LOW =  g_MISS_NUM  THEN
    l_Item_rec.DUAL_UOM_DEVIATION_LOW := null;
  END IF;

  IF(p_Item_rec.SUBSCRIPTION_DEPEND_FLAG IS NULL) THEN
    l_Item_rec.SUBSCRIPTION_DEPEND_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SUBSCRIPTION_DEPEND_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SUBSCRIPTION_DEPEND_FLAG := null;
  END IF;

  IF(p_Item_rec.SERV_REQ_ENABLED_CODE IS NULL) THEN
    l_Item_rec.SERV_REQ_ENABLED_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERV_REQ_ENABLED_CODE =  g_MISS_CHAR THEN
    l_Item_rec.SERV_REQ_ENABLED_CODE := null;
  END IF;

  IF(p_Item_rec.SERV_BILLING_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.SERV_BILLING_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SERV_BILLING_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.SERV_BILLING_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.SERV_IMPORTANCE_LEVEL IS NULL ) THEN
    l_Item_rec.SERV_IMPORTANCE_LEVEL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SERV_IMPORTANCE_LEVEL =  g_MISS_NUM  THEN
    l_Item_rec.SERV_IMPORTANCE_LEVEL := null;
  END IF;

  IF(p_Item_rec.PLANNED_INV_POINT_FLAG IS NULL) THEN
    l_Item_rec.PLANNED_INV_POINT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PLANNED_INV_POINT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PLANNED_INV_POINT_FLAG := null;
  END IF;

  IF(p_Item_rec.LOT_TRANSLATE_ENABLED IS NULL) THEN
    l_Item_rec.LOT_TRANSLATE_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_TRANSLATE_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.LOT_TRANSLATE_ENABLED := null;
  END IF;

  IF(p_Item_rec.DEFAULT_SO_SOURCE_TYPE IS NULL) THEN
    l_Item_rec.DEFAULT_SO_SOURCE_TYPE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DEFAULT_SO_SOURCE_TYPE =  g_MISS_CHAR THEN
    l_Item_rec.DEFAULT_SO_SOURCE_TYPE := null;
  END IF;

  IF(p_Item_rec.CREATE_SUPPLY_FLAG IS NULL) THEN
    l_Item_rec.CREATE_SUPPLY_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CREATE_SUPPLY_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CREATE_SUPPLY_FLAG := null;
  END IF;

  IF(p_Item_rec.SUBSTITUTION_WINDOW_CODE IS NULL ) THEN
    l_Item_rec.SUBSTITUTION_WINDOW_CODE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SUBSTITUTION_WINDOW_CODE =  g_MISS_NUM  THEN
    l_Item_rec.SUBSTITUTION_WINDOW_CODE := null;
  END IF;

  IF(p_Item_rec.SUBSTITUTION_WINDOW_DAYS IS NULL ) THEN
    l_Item_rec.SUBSTITUTION_WINDOW_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SUBSTITUTION_WINDOW_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.SUBSTITUTION_WINDOW_DAYS := null;
  END IF;

  IF(p_Item_rec.LOT_SUBSTITUTION_ENABLED IS NULL) THEN
    l_Item_rec.LOT_SUBSTITUTION_ENABLED :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_SUBSTITUTION_ENABLED =  g_MISS_CHAR THEN
    l_Item_rec.LOT_SUBSTITUTION_ENABLED := null;
  END IF;

  IF(p_Item_rec.MINIMUM_LICENSE_QUANTITY =  g_MISS_NUM ) THEN
    l_Item_rec.MINIMUM_LICENSE_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MINIMUM_LICENSE_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.MINIMUM_LICENSE_QUANTITY := null;
  END IF;

  IF(p_Item_rec.EAM_ACTIVITY_SOURCE_CODE IS NULL) THEN
    l_Item_rec.EAM_ACTIVITY_SOURCE_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EAM_ACTIVITY_SOURCE_CODE =  g_MISS_CHAR THEN
    l_Item_rec.EAM_ACTIVITY_SOURCE_CODE := null;
  END IF;

  IF(p_Item_rec.IB_ITEM_INSTANCE_CLASS IS NULL) THEN
    l_Item_rec.IB_ITEM_INSTANCE_CLASS :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.IB_ITEM_INSTANCE_CLASS =  g_MISS_CHAR THEN
    l_Item_rec.IB_ITEM_INSTANCE_CLASS := null;
  END IF;

  IF(p_Item_rec.CONFIG_MODEL_TYPE IS NULL) THEN
    l_Item_rec.CONFIG_MODEL_TYPE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CONFIG_MODEL_TYPE =  g_MISS_CHAR THEN
    l_Item_rec.CONFIG_MODEL_TYPE := null;
  END IF;

  IF(p_Item_rec.TRACKING_QUANTITY_IND IS NULL) THEN
    l_Item_rec.TRACKING_QUANTITY_IND :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.TRACKING_QUANTITY_IND =  g_MISS_CHAR THEN
    l_Item_rec.TRACKING_QUANTITY_IND := null;
  END IF;

  IF(p_Item_rec.ONT_PRICING_QTY_SOURCE IS NULL) THEN
    l_Item_rec.ONT_PRICING_QTY_SOURCE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ONT_PRICING_QTY_SOURCE =  g_MISS_CHAR THEN
    l_Item_rec.ONT_PRICING_QTY_SOURCE := null;
  END IF;

  IF(p_Item_rec.SECONDARY_DEFAULT_IND IS NULL) THEN
    l_Item_rec.SECONDARY_DEFAULT_IND :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.SECONDARY_DEFAULT_IND =  g_MISS_CHAR THEN
    l_Item_rec.SECONDARY_DEFAULT_IND := null;
  END IF;

  IF(p_Item_rec.CONFIG_ORGS IS NULL) THEN
    l_Item_rec.CONFIG_ORGS :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CONFIG_ORGS =  g_MISS_CHAR THEN
    l_Item_rec.CONFIG_ORGS := null;
  END IF;

  IF(p_Item_rec.CONFIG_MATCH IS NULL) THEN
    l_Item_rec.CONFIG_MATCH :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CONFIG_MATCH =  g_MISS_CHAR THEN
    l_Item_rec.CONFIG_MATCH := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE_CATEGORY IS NULL) THEN
    l_Item_rec.ATTRIBUTE_CATEGORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE_CATEGORY =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE_CATEGORY := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE1 IS NULL) THEN
    l_Item_rec.ATTRIBUTE1 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE1 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE1 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE2 IS NULL) THEN
    l_Item_rec.ATTRIBUTE2 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE2 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE2 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE3 IS NULL) THEN
    l_Item_rec.ATTRIBUTE3 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE3 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE3 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE4 IS NULL) THEN
    l_Item_rec.ATTRIBUTE4 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE4 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE4 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE5 IS NULL) THEN
    l_Item_rec.ATTRIBUTE5 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE5 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE5 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE6 IS NULL) THEN
    l_Item_rec.ATTRIBUTE6 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE6 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE6 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE7 IS NULL) THEN
    l_Item_rec.ATTRIBUTE7 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE7 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE7 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE8 IS NULL) THEN
    l_Item_rec.ATTRIBUTE8 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE8 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE8 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE9 IS NULL) THEN
    l_Item_rec.ATTRIBUTE9 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE9 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE9 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE10 IS NULL) THEN
    l_Item_rec.ATTRIBUTE10 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE10 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE10 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE11 IS NULL) THEN
    l_Item_rec.ATTRIBUTE11 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE11 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE11 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE12 IS NULL) THEN
    l_Item_rec.ATTRIBUTE12 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE12 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE12 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE13 IS NULL) THEN
    l_Item_rec.ATTRIBUTE13 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE13 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE13 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE14 IS NULL) THEN
    l_Item_rec.ATTRIBUTE14 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE14 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE14 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE15 IS NULL) THEN
    l_Item_rec.ATTRIBUTE15 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE15 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE15 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE16 IS NULL) THEN
    l_Item_rec.ATTRIBUTE16 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE16 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE16 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE17 IS NULL) THEN
    l_Item_rec.ATTRIBUTE17 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE17 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE17 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE18 IS NULL) THEN
    l_Item_rec.ATTRIBUTE18 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE18 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE18 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE19 IS NULL) THEN
    l_Item_rec.ATTRIBUTE19 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE19 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE19 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE20 IS NULL) THEN
    l_Item_rec.ATTRIBUTE20 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE20 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE20 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE21 IS NULL) THEN
    l_Item_rec.ATTRIBUTE21 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE21 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE21 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE22 IS NULL) THEN
    l_Item_rec.ATTRIBUTE22 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE22 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE22 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE23 IS NULL) THEN
    l_Item_rec.ATTRIBUTE23 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE23 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE23 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE24 IS NULL) THEN
    l_Item_rec.ATTRIBUTE24 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE24 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE24 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE25 IS NULL) THEN
    l_Item_rec.ATTRIBUTE25 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE25 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE25 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE26 IS NULL) THEN
    l_Item_rec.ATTRIBUTE26 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE26 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE26 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE27 IS NULL) THEN
    l_Item_rec.ATTRIBUTE27 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE27 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE27 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE28 IS NULL) THEN
    l_Item_rec.ATTRIBUTE28 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE28 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE28 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE29 IS NULL) THEN
    l_Item_rec.ATTRIBUTE29 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE29 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE29 := null;
  END IF;

  IF(p_Item_rec.ATTRIBUTE30 IS NULL) THEN
    l_Item_rec.ATTRIBUTE30 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.ATTRIBUTE30 =  g_MISS_CHAR THEN
    l_Item_rec.ATTRIBUTE30 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE_CATEGORY IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE_CATEGORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE_CATEGORY =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE_CATEGORY := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE1 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE1 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE1 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE1 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE2 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE2 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE2 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE2 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE3 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE3 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE3 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE3 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE4 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE4 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE4 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE4 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE5 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE5 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE5 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE5 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE6 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE6 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE6 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE6 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE7 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE7 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE7 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE7 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE8 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE8 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE8 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE8 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE9 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE9 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE9 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE9 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE10 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE10 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE10 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE10 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE11 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE11 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE11 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE11 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE12 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE12 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE12 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE12 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE13 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE13 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE13 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE13 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE14 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE14 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE14 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE14 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE15 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE15 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE15 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE15 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE16 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE16 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE16 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE16 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE17 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE17 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE17 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE17 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE18 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE18 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE18 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE18 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE19 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE19 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE19 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE19 := null;
  END IF;

  IF(p_Item_rec.GLOBAL_ATTRIBUTE20 IS NULL) THEN
    l_Item_rec.GLOBAL_ATTRIBUTE20 :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GLOBAL_ATTRIBUTE20 =  g_MISS_CHAR THEN
    l_Item_rec.GLOBAL_ATTRIBUTE20 := null;
  END IF;

  IF(p_Item_rec.VMI_MINIMUM_UNITS IS NULL ) THEN
    l_Item_rec.VMI_MINIMUM_UNITS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_MINIMUM_UNITS =  g_MISS_NUM  THEN
    l_Item_rec.VMI_MINIMUM_UNITS := null;
  END IF;

  IF(p_Item_rec.VMI_MINIMUM_DAYS IS NULL ) THEN
    l_Item_rec.VMI_MINIMUM_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_MINIMUM_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.VMI_MINIMUM_DAYS := null;
  END IF;

  IF(p_Item_rec.VMI_MAXIMUM_UNITS IS NULL ) THEN
    l_Item_rec.VMI_MAXIMUM_UNITS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_MAXIMUM_UNITS =  g_MISS_NUM  THEN
    l_Item_rec.VMI_MAXIMUM_UNITS := null;
  END IF;

  IF(p_Item_rec.VMI_MAXIMUM_DAYS IS NULL ) THEN
    l_Item_rec.VMI_MAXIMUM_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_MAXIMUM_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.VMI_MAXIMUM_DAYS := null;
  END IF;

  IF(p_Item_rec.VMI_FIXED_ORDER_QUANTITY IS NULL ) THEN
    l_Item_rec.VMI_FIXED_ORDER_QUANTITY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_FIXED_ORDER_QUANTITY =  g_MISS_NUM  THEN
    l_Item_rec.VMI_FIXED_ORDER_QUANTITY := null;
  END IF;

  IF(p_Item_rec.SO_AUTHORIZATION_FLAG IS NULL ) THEN
    l_Item_rec.SO_AUTHORIZATION_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SO_AUTHORIZATION_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.SO_AUTHORIZATION_FLAG := null;
  END IF;

  IF(p_Item_rec.CONSIGNED_FLAG IS NULL ) THEN
    l_Item_rec.CONSIGNED_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CONSIGNED_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.CONSIGNED_FLAG := null;
  END IF;

  IF(p_Item_rec.ASN_AUTOEXPIRE_FLAG IS NULL ) THEN
    l_Item_rec.ASN_AUTOEXPIRE_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.ASN_AUTOEXPIRE_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.ASN_AUTOEXPIRE_FLAG := null;
  END IF;

  IF(p_Item_rec.VMI_FORECAST_TYPE IS NULL ) THEN
    l_Item_rec.VMI_FORECAST_TYPE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.VMI_FORECAST_TYPE =  g_MISS_NUM  THEN
    l_Item_rec.VMI_FORECAST_TYPE := null;
  END IF;

  IF(p_Item_rec.FORECAST_HORIZON IS NULL ) THEN
    l_Item_rec.FORECAST_HORIZON :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.FORECAST_HORIZON =  g_MISS_NUM  THEN
    l_Item_rec.FORECAST_HORIZON := null;
  END IF;

  IF(p_Item_rec.EXCLUDE_FROM_BUDGET_FLAG IS NULL ) THEN
    l_Item_rec.EXCLUDE_FROM_BUDGET_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EXCLUDE_FROM_BUDGET_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.EXCLUDE_FROM_BUDGET_FLAG := null;
  END IF;

  IF(p_Item_rec.DAYS_TGT_INV_SUPPLY IS NULL ) THEN
    l_Item_rec.DAYS_TGT_INV_SUPPLY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_TGT_INV_SUPPLY =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_TGT_INV_SUPPLY := null;
  END IF;

  IF(p_Item_rec.DAYS_TGT_INV_WINDOW IS NULL ) THEN
    l_Item_rec.DAYS_TGT_INV_WINDOW :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_TGT_INV_WINDOW =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_TGT_INV_WINDOW := null;
  END IF;

  IF(p_Item_rec.DAYS_MAX_INV_SUPPLY IS NULL ) THEN
    l_Item_rec.DAYS_MAX_INV_SUPPLY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_MAX_INV_SUPPLY =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_MAX_INV_SUPPLY := null;
  END IF;

  IF(p_Item_rec.DAYS_MAX_INV_WINDOW IS NULL ) THEN
    l_Item_rec.DAYS_MAX_INV_WINDOW :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DAYS_MAX_INV_WINDOW =  g_MISS_NUM  THEN
    l_Item_rec.DAYS_MAX_INV_WINDOW := null;
  END IF;

  IF(p_Item_rec.DRP_PLANNED_FLAG IS NULL ) THEN
    l_Item_rec.DRP_PLANNED_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DRP_PLANNED_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.DRP_PLANNED_FLAG := null;
  END IF;

  IF(p_Item_rec.CRITICAL_COMPONENT_FLAG IS NULL ) THEN
    l_Item_rec.CRITICAL_COMPONENT_FLAG :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CRITICAL_COMPONENT_FLAG =  g_MISS_NUM  THEN
    l_Item_rec.CRITICAL_COMPONENT_FLAG := null;
  END IF;

  IF(p_Item_rec.CONTINOUS_TRANSFER IS NULL ) THEN
    l_Item_rec.CONTINOUS_TRANSFER :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CONTINOUS_TRANSFER =  g_MISS_NUM  THEN
    l_Item_rec.CONTINOUS_TRANSFER := null;
  END IF;

  IF(p_Item_rec.CONVERGENCE IS NULL ) THEN
    l_Item_rec.CONVERGENCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CONVERGENCE =  g_MISS_NUM  THEN
    l_Item_rec.CONVERGENCE := null;
  END IF;

  IF(p_Item_rec.DIVERGENCE IS NULL ) THEN
    l_Item_rec.DIVERGENCE :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.DIVERGENCE =  g_MISS_NUM  THEN
    l_Item_rec.DIVERGENCE := null;
  END IF;

  IF(p_Item_rec.LOT_DIVISIBLE_FLAG IS NULL) THEN
    l_Item_rec.LOT_DIVISIBLE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.LOT_DIVISIBLE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.LOT_DIVISIBLE_FLAG := null;
  END IF;

  IF(p_Item_rec.GRADE_CONTROL_FLAG IS NULL) THEN
    l_Item_rec.GRADE_CONTROL_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GRADE_CONTROL_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.GRADE_CONTROL_FLAG := null;
  END IF;

  IF(p_Item_rec.DEFAULT_GRADE IS NULL) THEN
    l_Item_rec.DEFAULT_GRADE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.DEFAULT_GRADE =  g_MISS_CHAR THEN
    l_Item_rec.DEFAULT_GRADE := null;
  END IF;

  IF(p_Item_rec.CHILD_LOT_FLAG IS NULL) THEN
    l_Item_rec.CHILD_LOT_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CHILD_LOT_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CHILD_LOT_FLAG := null;
  END IF;

  IF(p_Item_rec.PARENT_CHILD_GENERATION_FLAG IS NULL) THEN
    l_Item_rec.PARENT_CHILD_GENERATION_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PARENT_CHILD_GENERATION_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PARENT_CHILD_GENERATION_FLAG := null;
  END IF;

  IF(p_Item_rec.CHILD_LOT_PREFIX IS NULL) THEN
    l_Item_rec.CHILD_LOT_PREFIX :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CHILD_LOT_PREFIX =  g_MISS_CHAR THEN
    l_Item_rec.CHILD_LOT_PREFIX := null;
  END IF;

  IF(p_Item_rec.CHILD_LOT_STARTING_NUMBER IS NULL ) THEN
    l_Item_rec.CHILD_LOT_STARTING_NUMBER :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.CHILD_LOT_STARTING_NUMBER =  g_MISS_NUM  THEN
    l_Item_rec.CHILD_LOT_STARTING_NUMBER := null;
  END IF;

  IF(p_Item_rec.CHILD_LOT_VALIDATION_FLAG IS NULL) THEN
    l_Item_rec.CHILD_LOT_VALIDATION_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CHILD_LOT_VALIDATION_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.CHILD_LOT_VALIDATION_FLAG := null;
  END IF;

  IF(p_Item_rec.COPY_LOT_ATTRIBUTE_FLAG IS NULL) THEN
    l_Item_rec.COPY_LOT_ATTRIBUTE_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.COPY_LOT_ATTRIBUTE_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.COPY_LOT_ATTRIBUTE_FLAG := null;
  END IF;

  IF(p_Item_rec.RECIPE_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.RECIPE_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.RECIPE_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.RECIPE_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.PROCESS_QUALITY_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.PROCESS_QUALITY_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PROCESS_QUALITY_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PROCESS_QUALITY_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.PROCESS_COSTING_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.PROCESS_COSTING_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PROCESS_COSTING_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.PROCESS_COSTING_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.PROCESS_SUPPLY_SUBINVENTORY IS NULL) THEN
    l_Item_rec.PROCESS_SUPPLY_SUBINVENTORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PROCESS_SUPPLY_SUBINVENTORY =  g_MISS_CHAR THEN
    l_Item_rec.PROCESS_SUPPLY_SUBINVENTORY := null;
  END IF;

  IF(p_Item_rec.PROCESS_SUPPLY_LOCATOR_ID IS NULL ) THEN
    l_Item_rec.PROCESS_SUPPLY_LOCATOR_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PROCESS_SUPPLY_LOCATOR_ID =  g_MISS_NUM  THEN
    l_Item_rec.PROCESS_SUPPLY_LOCATOR_ID := null;
  END IF;

  IF(p_Item_rec.PROCESS_YIELD_SUBINVENTORY IS NULL) THEN
    l_Item_rec.PROCESS_YIELD_SUBINVENTORY :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PROCESS_YIELD_SUBINVENTORY =  g_MISS_CHAR THEN
    l_Item_rec.PROCESS_YIELD_SUBINVENTORY := null;
  END IF;

  IF(p_Item_rec.PROCESS_YIELD_LOCATOR_ID IS NULL ) THEN
    l_Item_rec.PROCESS_YIELD_LOCATOR_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.PROCESS_YIELD_LOCATOR_ID =  g_MISS_NUM  THEN
    l_Item_rec.PROCESS_YIELD_LOCATOR_ID := null;
  END IF;

  IF(p_Item_rec.HAZARDOUS_MATERIAL_FLAG IS NULL) THEN
    l_Item_rec.HAZARDOUS_MATERIAL_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.HAZARDOUS_MATERIAL_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.HAZARDOUS_MATERIAL_FLAG := null;
  END IF;

  IF(p_Item_rec.CAS_NUMBER IS NULL) THEN
    l_Item_rec.CAS_NUMBER :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CAS_NUMBER =  g_MISS_CHAR THEN
    l_Item_rec.CAS_NUMBER := null;
  END IF;

  IF(p_Item_rec.RETEST_INTERVAL IS NULL ) THEN
    l_Item_rec.RETEST_INTERVAL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.RETEST_INTERVAL =  g_MISS_NUM  THEN
    l_Item_rec.RETEST_INTERVAL := null;
  END IF;

  IF(p_Item_rec.EXPIRATION_ACTION_INTERVAL IS NULL ) THEN
    l_Item_rec.EXPIRATION_ACTION_INTERVAL :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.EXPIRATION_ACTION_INTERVAL =  g_MISS_NUM  THEN
    l_Item_rec.EXPIRATION_ACTION_INTERVAL := null;
  END IF;

  IF(p_Item_rec.EXPIRATION_ACTION_CODE IS NULL) THEN
    l_Item_rec.EXPIRATION_ACTION_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.EXPIRATION_ACTION_CODE =  g_MISS_CHAR THEN
    l_Item_rec.EXPIRATION_ACTION_CODE := null;
  END IF;

  IF(p_Item_rec.MATURITY_DAYS IS NULL ) THEN
    l_Item_rec.MATURITY_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.MATURITY_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.MATURITY_DAYS := null;
  END IF;

  IF(p_Item_rec.HOLD_DAYS IS NULL ) THEN
    l_Item_rec.HOLD_DAYS :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.HOLD_DAYS =  g_MISS_NUM  THEN
    l_Item_rec.HOLD_DAYS := null;
  END IF;

  IF(p_Item_rec.Lifecycle_Id IS NULL ) THEN
    l_Item_rec.Lifecycle_Id :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.Lifecycle_Id =  g_MISS_NUM  THEN
    l_Item_rec.Lifecycle_Id := null;
  END IF;

  IF(p_Item_rec.Current_Phase_Id IS NULL ) THEN
    l_Item_rec.Current_Phase_Id :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.Current_Phase_Id =  g_MISS_NUM  THEN
    l_Item_rec.Current_Phase_Id := null;
  END IF;

  IF(p_Item_rec.CHARGE_PERIODICITY_CODE IS NULL) THEN
    l_Item_rec.CHARGE_PERIODICITY_CODE :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.CHARGE_PERIODICITY_CODE =  g_MISS_CHAR THEN
    l_Item_rec.CHARGE_PERIODICITY_CODE := null;
  END IF;

  IF(p_Item_rec.REPAIR_LEADTIME IS NULL ) THEN
    l_Item_rec.REPAIR_LEADTIME :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.REPAIR_LEADTIME =  g_MISS_NUM  THEN
    l_Item_rec.REPAIR_LEADTIME := null;
  END IF;

  IF(p_Item_rec.REPAIR_YIELD IS NULL ) THEN
    l_Item_rec.REPAIR_YIELD :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.REPAIR_YIELD =  g_MISS_NUM  THEN
    l_Item_rec.REPAIR_YIELD := null;
  END IF;

  IF(p_Item_rec.PREPOSITION_POINT IS NULL) THEN
    l_Item_rec.PREPOSITION_POINT :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.PREPOSITION_POINT =  g_MISS_CHAR THEN
    l_Item_rec.PREPOSITION_POINT := null;
  END IF;

  IF(p_Item_rec.REPAIR_PROGRAM IS NULL ) THEN
    l_Item_rec.REPAIR_PROGRAM :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.REPAIR_PROGRAM =  g_MISS_NUM  THEN
    l_Item_rec.REPAIR_PROGRAM := null;
  END IF;

  IF(p_Item_rec.SUBCONTRACTING_COMPONENT IS NULL ) THEN
    l_Item_rec.SUBCONTRACTING_COMPONENT :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.SUBCONTRACTING_COMPONENT =  g_MISS_NUM  THEN
    l_Item_rec.SUBCONTRACTING_COMPONENT := null;
  END IF;

  IF(p_Item_rec.OUTSOURCED_ASSEMBLY IS NULL ) THEN
    l_Item_rec.OUTSOURCED_ASSEMBLY :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.OUTSOURCED_ASSEMBLY =  g_MISS_NUM  THEN
    l_Item_rec.OUTSOURCED_ASSEMBLY := null;
  END IF;

  --R12 C Attributes
  IF(p_Item_rec.GDSN_OUTBOUND_ENABLED_FLAG IS NULL) THEN
    l_Item_rec.GDSN_OUTBOUND_ENABLED_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.GDSN_OUTBOUND_ENABLED_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.GDSN_OUTBOUND_ENABLED_FLAG := null;
  END IF;

  IF(p_Item_rec.TRADE_ITEM_DESCRIPTOR IS NULL) THEN
    l_Item_rec.TRADE_ITEM_DESCRIPTOR :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.TRADE_ITEM_DESCRIPTOR =  g_MISS_CHAR THEN
    l_Item_rec.TRADE_ITEM_DESCRIPTOR := null;
  END IF;

  IF(p_Item_rec.STYLE_ITEM_FLAG IS NULL) THEN
    l_Item_rec.STYLE_ITEM_FLAG :=  g_Upd_Null_CHAR;
  ELSIF  p_Item_rec.STYLE_ITEM_FLAG =  g_MISS_CHAR THEN
    l_Item_rec.STYLE_ITEM_FLAG := null;
  END IF;

  IF(p_Item_rec.STYLE_ITEM_ID IS NULL ) THEN
    l_Item_rec.STYLE_ITEM_ID :=  g_Upd_Null_NUM ;
  ELSIF  p_Item_rec.STYLE_ITEM_ID =  g_MISS_NUM  THEN
    l_Item_rec.STYLE_ITEM_ID := null;
  END IF;

  -- Insert item row into MSII for further processing by IOI.

    INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE(
   process_flag
  ,set_process_id
  ,transaction_type
  ,ORGANIZATION_ID
  ,ORGANIZATION_CODE
  ,INVENTORY_ITEM_ID
  ,ITEM_NUMBER
  ,SEGMENT1
  ,SEGMENT2
  ,SEGMENT3
  ,SEGMENT4
  ,SEGMENT5
  ,SEGMENT6
  ,SEGMENT7
  ,SEGMENT8
  ,SEGMENT9
  ,SEGMENT10
  ,SEGMENT11
  ,SEGMENT12
  ,SEGMENT13
  ,SEGMENT14
  ,SEGMENT15
  ,SEGMENT16
  ,SEGMENT17
  ,SEGMENT18
  ,SEGMENT19
  ,SEGMENT20
  ,SUMMARY_FLAG
  ,ENABLED_FLAG
  ,START_DATE_ACTIVE
  ,END_DATE_ACTIVE
  --
  ,TEMPLATE_ID
  ,TEMPLATE_NAME
  --
  ,DESCRIPTION
  ,LONG_DESCRIPTION
  ,PRIMARY_UOM_CODE
  ,PRIMARY_UNIT_OF_MEASURE
  ,ITEM_TYPE
  ,INVENTORY_ITEM_STATUS_CODE
  ,ALLOWED_UNITS_LOOKUP_CODE
  ,ITEM_CATALOG_GROUP_ID
  ,CATALOG_STATUS_FLAG
  ,INVENTORY_ITEM_FLAG
  ,STOCK_ENABLED_FLAG
  ,MTL_TRANSACTIONS_ENABLED_FLAG
  ,CHECK_SHORTAGES_FLAG
  ,REVISION_QTY_CONTROL_CODE
  ,RESERVABLE_TYPE
  ,SHELF_LIFE_CODE
  ,SHELF_LIFE_DAYS
  ,CYCLE_COUNT_ENABLED_FLAG
  ,NEGATIVE_MEASUREMENT_ERROR
  ,POSITIVE_MEASUREMENT_ERROR
  ,LOT_CONTROL_CODE
  ,AUTO_LOT_ALPHA_PREFIX
  ,START_AUTO_LOT_NUMBER
  ,SERIAL_NUMBER_CONTROL_CODE
  ,AUTO_SERIAL_ALPHA_PREFIX
  ,START_AUTO_SERIAL_NUMBER
  ,LOCATION_CONTROL_CODE
  ,RESTRICT_SUBINVENTORIES_CODE
  ,RESTRICT_LOCATORS_CODE
  ,BOM_ENABLED_FLAG
  ,BOM_ITEM_TYPE
  ,BASE_ITEM_ID
  ,EFFECTIVITY_CONTROL
  ,ENG_ITEM_FLAG
  ,ENGINEERING_ECN_CODE
  ,ENGINEERING_ITEM_ID
  ,ENGINEERING_DATE
  ,PRODUCT_FAMILY_ITEM_ID
  ,AUTO_CREATED_CONFIG_FLAG
  ,MODEL_CONFIG_CLAUSE_NAME
  ,COSTING_ENABLED_FLAG
  ,INVENTORY_ASSET_FLAG
  ,DEFAULT_INCLUDE_IN_ROLLUP_FLAG
  ,COST_OF_SALES_ACCOUNT
  ,STD_LOT_SIZE
  ,PURCHASING_ITEM_FLAG
  ,PURCHASING_ENABLED_FLAG
  ,MUST_USE_APPROVED_VENDOR_FLAG
  ,ALLOW_ITEM_DESC_UPDATE_FLAG
  ,RFQ_REQUIRED_FLAG
  ,OUTSIDE_OPERATION_FLAG
  ,OUTSIDE_OPERATION_UOM_TYPE
  ,TAXABLE_FLAG
  ,PURCHASING_TAX_CODE
  ,RECEIPT_REQUIRED_FLAG
  ,INSPECTION_REQUIRED_FLAG
  ,BUYER_ID
  ,UNIT_OF_ISSUE
  ,RECEIVE_CLOSE_TOLERANCE
  ,INVOICE_CLOSE_TOLERANCE
  ,UN_NUMBER_ID
  ,HAZARD_CLASS_ID
  ,LIST_PRICE_PER_UNIT
  ,MARKET_PRICE
  ,PRICE_TOLERANCE_PERCENT
  ,ROUNDING_FACTOR
  ,ENCUMBRANCE_ACCOUNT
  ,EXPENSE_ACCOUNT
  ,ASSET_CATEGORY_ID
  ,RECEIPT_DAYS_EXCEPTION_CODE
  ,DAYS_EARLY_RECEIPT_ALLOWED
  ,DAYS_LATE_RECEIPT_ALLOWED
  ,ALLOW_SUBSTITUTE_RECEIPTS_FLAG
  ,ALLOW_UNORDERED_RECEIPTS_FLAG
  ,ALLOW_EXPRESS_DELIVERY_FLAG
  ,QTY_RCV_EXCEPTION_CODE
  ,QTY_RCV_TOLERANCE
  ,RECEIVING_ROUTING_ID
  ,ENFORCE_SHIP_TO_LOCATION_CODE
  ,WEIGHT_UOM_CODE
  ,UNIT_WEIGHT
  ,VOLUME_UOM_CODE
  ,UNIT_VOLUME
  ,CONTAINER_ITEM_FLAG
  ,VEHICLE_ITEM_FLAG
  ,CONTAINER_TYPE_CODE
  ,INTERNAL_VOLUME
  ,MAXIMUM_LOAD_WEIGHT
  ,MINIMUM_FILL_PERCENT
  ,INVENTORY_PLANNING_CODE
  ,PLANNER_CODE
  ,PLANNING_MAKE_BUY_CODE
  ,MIN_MINMAX_QUANTITY
  ,MAX_MINMAX_QUANTITY
  ,MINIMUM_ORDER_QUANTITY
  ,MAXIMUM_ORDER_QUANTITY
  ,ORDER_COST
  ,CARRYING_COST
  ,SOURCE_TYPE
  ,SOURCE_ORGANIZATION_ID
  ,SOURCE_SUBINVENTORY
  ,MRP_SAFETY_STOCK_CODE
  ,SAFETY_STOCK_BUCKET_DAYS
  ,MRP_SAFETY_STOCK_PERCENT
  ,FIXED_ORDER_QUANTITY
  ,FIXED_DAYS_SUPPLY
  ,FIXED_LOT_MULTIPLIER
  ,MRP_PLANNING_CODE
  ,ATO_FORECAST_CONTROL
  ,PLANNING_EXCEPTION_SET
  ,END_ASSEMBLY_PEGGING_FLAG
  ,SHRINKAGE_RATE
  ,ROUNDING_CONTROL_TYPE
  ,ACCEPTABLE_EARLY_DAYS
  ,REPETITIVE_PLANNING_FLAG
  ,OVERRUN_PERCENTAGE
  ,ACCEPTABLE_RATE_INCREASE
  ,ACCEPTABLE_RATE_DECREASE
  ,MRP_CALCULATE_ATP_FLAG
  ,AUTO_REDUCE_MPS
  ,PLANNING_TIME_FENCE_CODE
  ,PLANNING_TIME_FENCE_DAYS
  ,DEMAND_TIME_FENCE_CODE
  ,DEMAND_TIME_FENCE_DAYS
  ,RELEASE_TIME_FENCE_CODE
  ,RELEASE_TIME_FENCE_DAYS
  ,PREPROCESSING_LEAD_TIME
  ,FULL_LEAD_TIME
  ,POSTPROCESSING_LEAD_TIME
  ,FIXED_LEAD_TIME
  ,VARIABLE_LEAD_TIME
  ,CUM_MANUFACTURING_LEAD_TIME
  ,CUMULATIVE_TOTAL_LEAD_TIME
  ,LEAD_TIME_LOT_SIZE
  ,BUILD_IN_WIP_FLAG
  ,WIP_SUPPLY_TYPE
  ,WIP_SUPPLY_SUBINVENTORY
  ,WIP_SUPPLY_LOCATOR_ID
  ,OVERCOMPLETION_TOLERANCE_TYPE
  ,OVERCOMPLETION_TOLERANCE_VALUE
  ,CUSTOMER_ORDER_FLAG
  ,CUSTOMER_ORDER_ENABLED_FLAG
  ,SHIPPABLE_ITEM_FLAG
  ,INTERNAL_ORDER_FLAG
  ,INTERNAL_ORDER_ENABLED_FLAG
  ,SO_TRANSACTIONS_FLAG
  ,PICK_COMPONENTS_FLAG
  ,ATP_FLAG
  ,REPLENISH_TO_ORDER_FLAG
  ,ATP_RULE_ID
  ,ATP_COMPONENTS_FLAG
  ,SHIP_MODEL_COMPLETE_FLAG
  ,PICKING_RULE_ID
  ,COLLATERAL_FLAG
  ,DEFAULT_SHIPPING_ORG
  ,RETURNABLE_FLAG
  ,RETURN_INSPECTION_REQUIREMENT
  ,OVER_SHIPMENT_TOLERANCE
  ,UNDER_SHIPMENT_TOLERANCE
  ,OVER_RETURN_TOLERANCE
  ,UNDER_RETURN_TOLERANCE
  ,INVOICEABLE_ITEM_FLAG
  ,INVOICE_ENABLED_FLAG
  ,ACCOUNTING_RULE_ID
  ,INVOICING_RULE_ID
  ,TAX_CODE
  ,SALES_ACCOUNT
  ,PAYMENT_TERMS_ID
  ,COVERAGE_SCHEDULE_ID
  ,SERVICE_DURATION
  ,SERVICE_DURATION_PERIOD_CODE
  ,SERVICEABLE_PRODUCT_FLAG
  ,SERVICE_STARTING_DELAY
  ,MATERIAL_BILLABLE_FLAG
  ,SERVICEABLE_COMPONENT_FLAG
  ,PREVENTIVE_MAINTENANCE_FLAG
  ,PRORATE_SERVICE_FLAG
  ,WH_UPDATE_DATE
  ,EQUIPMENT_TYPE
  ,RECOVERED_PART_DISP_CODE
  ,DEFECT_TRACKING_ON_FLAG
  ,EVENT_FLAG
  ,ELECTRONIC_FLAG
  ,DOWNLOADABLE_FLAG
  ,VOL_DISCOUNT_EXEMPT_FLAG
  ,COUPON_EXEMPT_FLAG
  ,COMMS_NL_TRACKABLE_FLAG
  ,ASSET_CREATION_CODE
  ,COMMS_ACTIVATION_REQD_FLAG
  ,WEB_STATUS
  ,ORDERABLE_ON_WEB_FLAG
  ,BACK_ORDERABLE_FLAG
  , INDIVISIBLE_FLAG
  ,DIMENSION_UOM_CODE
  ,UNIT_LENGTH
  ,UNIT_WIDTH
  ,UNIT_HEIGHT
  ,BULK_PICKED_FLAG
  ,LOT_STATUS_ENABLED
  ,DEFAULT_LOT_STATUS_ID
  ,SERIAL_STATUS_ENABLED
  ,DEFAULT_SERIAL_STATUS_ID
  ,LOT_SPLIT_ENABLED
  ,LOT_MERGE_ENABLED
  ,INVENTORY_CARRY_PENALTY
  ,OPERATION_SLACK_PENALTY
  ,FINANCING_ALLOWED_FLAG
  ,EAM_ITEM_TYPE
  ,EAM_ACTIVITY_TYPE_CODE
  ,EAM_ACTIVITY_CAUSE_CODE
  ,EAM_ACT_NOTIFICATION_FLAG
  ,EAM_ACT_SHUTDOWN_STATUS
  ,DUAL_UOM_CONTROL
  ,SECONDARY_UOM_CODE
  ,DUAL_UOM_DEVIATION_HIGH
  ,DUAL_UOM_DEVIATION_LOW
  --
  ,CONTRACT_ITEM_TYPE_CODE
  ,SUBSCRIPTION_DEPEND_FLAG
  --
  ,SERV_REQ_ENABLED_CODE
  ,SERV_BILLING_ENABLED_FLAG
  ,SERV_IMPORTANCE_LEVEL
  ,PLANNED_INV_POINT_FLAG
  ,LOT_TRANSLATE_ENABLED
  ,DEFAULT_SO_SOURCE_TYPE
  ,CREATE_SUPPLY_FLAG
  ,SUBSTITUTION_WINDOW_CODE
  ,SUBSTITUTION_WINDOW_DAYS
 -- Added as part of 11.5.9
  ,LOT_SUBSTITUTION_ENABLED
  ,MINIMUM_LICENSE_QUANTITY
  ,EAM_ACTIVITY_SOURCE_CODE
  ,IB_ITEM_INSTANCE_CLASS
  ,CONFIG_MODEL_TYPE
 -- Added as part of 11.5.10
  ,TRACKING_QUANTITY_IND
  ,ONT_PRICING_QTY_SOURCE
  ,SECONDARY_DEFAULT_IND
  ,CONFIG_ORGS
  ,CONFIG_MATCH
--
  ,ATTRIBUTE_CATEGORY
  ,ATTRIBUTE1
  ,ATTRIBUTE2
  ,ATTRIBUTE3
  ,ATTRIBUTE4
  ,ATTRIBUTE5
  ,ATTRIBUTE6
  ,ATTRIBUTE7
  ,ATTRIBUTE8
  ,ATTRIBUTE9
  ,ATTRIBUTE10
  ,ATTRIBUTE11
  ,ATTRIBUTE12
  ,ATTRIBUTE13
  ,ATTRIBUTE14
  ,ATTRIBUTE15
  /* Start Bug 3713912 */
  ,ATTRIBUTE16
  ,ATTRIBUTE17
  ,ATTRIBUTE18
  ,ATTRIBUTE19
  ,ATTRIBUTE20
  ,ATTRIBUTE21
  ,ATTRIBUTE22
  ,ATTRIBUTE23
  ,ATTRIBUTE24
  ,ATTRIBUTE25
  ,ATTRIBUTE26
  ,ATTRIBUTE27
  ,ATTRIBUTE28
  ,ATTRIBUTE29
  ,ATTRIBUTE30
  /* End Bug 3713912 */
  ,GLOBAL_ATTRIBUTE_CATEGORY
  ,GLOBAL_ATTRIBUTE1
  ,GLOBAL_ATTRIBUTE2
  ,GLOBAL_ATTRIBUTE3
  ,GLOBAL_ATTRIBUTE4
  ,GLOBAL_ATTRIBUTE5
  ,GLOBAL_ATTRIBUTE6
  ,GLOBAL_ATTRIBUTE7
  ,GLOBAL_ATTRIBUTE8
  ,GLOBAL_ATTRIBUTE9
  ,GLOBAL_ATTRIBUTE10
  ,GLOBAL_ATTRIBUTE11
  ,GLOBAL_ATTRIBUTE12
  ,GLOBAL_ATTRIBUTE13
  ,GLOBAL_ATTRIBUTE14
  ,GLOBAL_ATTRIBUTE15
  ,GLOBAL_ATTRIBUTE16
  ,GLOBAL_ATTRIBUTE17
  ,GLOBAL_ATTRIBUTE18
  ,GLOBAL_ATTRIBUTE19
  ,GLOBAL_ATTRIBUTE20
  ,CREATION_DATE
  ,CREATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,REQUEST_ID
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
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
  ,LIFECYCLE_ID   -- Bug 3933277
  ,CURRENT_PHASE_ID -- Bug 3933277
  /* R12 Enhancement */
  ,CHARGE_PERIODICITY_CODE
  ,REPAIR_LEADTIME
  ,REPAIR_YIELD
  ,PREPOSITION_POINT
  ,REPAIR_PROGRAM
  ,SUBCONTRACTING_COMPONENT
  ,OUTSOURCED_ASSEMBLY
   --R12 C Attributes
  ,GDSN_OUTBOUND_ENABLED_FLAG
  ,TRADE_ITEM_DESCRIPTOR
  ,STYLE_ITEM_FLAG
  ,STYLE_ITEM_ID)
  VALUES(
   l_process_flag
  ,l_set_process_id     /* unique process set id for one record in IOI */
  ,p_transaction_type   /* transaction type (CREATE, UPDATE) */
  ,l_Item_rec.ORGANIZATION_ID
  ,l_Item_rec.ORGANIZATION_CODE
  ,l_Item_rec.INVENTORY_ITEM_ID
  ,l_Item_rec.ITEM_NUMBER
  ,l_Item_rec.SEGMENT1
  ,l_Item_rec.SEGMENT2
  ,l_Item_rec.SEGMENT3
  ,l_Item_rec.SEGMENT4
  ,l_Item_rec.SEGMENT5
  ,l_Item_rec.SEGMENT6
  ,l_Item_rec.SEGMENT7
  ,l_Item_rec.SEGMENT8
  ,l_Item_rec.SEGMENT9
  ,l_Item_rec.SEGMENT10
  ,l_Item_rec.SEGMENT11
  ,l_Item_rec.SEGMENT12
  ,l_Item_rec.SEGMENT13
  ,l_Item_rec.SEGMENT14
  ,l_Item_rec.SEGMENT15
  ,l_Item_rec.SEGMENT16
  ,l_Item_rec.SEGMENT17
  ,l_Item_rec.SEGMENT18
  ,l_Item_rec.SEGMENT19
  ,l_Item_rec.SEGMENT20
  ,l_Item_rec.SUMMARY_FLAG
  ,l_Item_rec.ENABLED_FLAG
  ,l_Item_rec.START_DATE_ACTIVE
  ,l_Item_rec.END_DATE_ACTIVE
  --
  ,p_Template_Id
  ,p_Template_Name
  --
  ,l_Item_rec.DESCRIPTION
  ,l_Item_rec.LONG_DESCRIPTION
  ,l_Item_rec.PRIMARY_UOM_CODE
  ,l_Item_rec.PRIMARY_UNIT_OF_MEASURE
  ,l_Item_rec.ITEM_TYPE
  ,l_Item_rec.INVENTORY_ITEM_STATUS_CODE
  ,l_Item_rec.ALLOWED_UNITS_LOOKUP_CODE
  ,l_Item_rec.ITEM_CATALOG_GROUP_ID
  ,l_Item_rec.CATALOG_STATUS_FLAG
  ,l_Item_rec.INVENTORY_ITEM_FLAG
  ,l_Item_rec.STOCK_ENABLED_FLAG
  ,l_Item_rec.MTL_TRANSACTIONS_ENABLED_FLAG
  ,l_Item_rec.CHECK_SHORTAGES_FLAG
  ,l_Item_rec.REVISION_QTY_CONTROL_CODE
  ,l_Item_rec.RESERVABLE_TYPE
  ,l_Item_rec.SHELF_LIFE_CODE
  ,l_Item_rec.SHELF_LIFE_DAYS
  ,l_Item_rec.CYCLE_COUNT_ENABLED_FLAG
  ,l_Item_rec.NEGATIVE_MEASUREMENT_ERROR
  ,l_Item_rec.POSITIVE_MEASUREMENT_ERROR
  ,l_Item_rec.LOT_CONTROL_CODE
  ,l_Item_rec.AUTO_LOT_ALPHA_PREFIX
  ,l_Item_rec.START_AUTO_LOT_NUMBER
  ,l_Item_rec.SERIAL_NUMBER_CONTROL_CODE
  ,l_Item_rec.AUTO_SERIAL_ALPHA_PREFIX
  ,l_Item_rec.START_AUTO_SERIAL_NUMBER
  ,l_Item_rec.LOCATION_CONTROL_CODE
  ,l_Item_rec.RESTRICT_SUBINVENTORIES_CODE
  ,l_Item_rec.RESTRICT_LOCATORS_CODE
  ,l_Item_rec.BOM_ENABLED_FLAG
  ,l_Item_rec.BOM_ITEM_TYPE
  ,l_Item_rec.BASE_ITEM_ID
  ,l_Item_rec.EFFECTIVITY_CONTROL
  ,l_Item_rec.ENG_ITEM_FLAG
  ,l_Item_rec.ENGINEERING_ECN_CODE
  ,l_Item_rec.ENGINEERING_ITEM_ID
  ,l_Item_rec.ENGINEERING_DATE
  ,l_Item_rec.PRODUCT_FAMILY_ITEM_ID
  ,l_Item_rec.AUTO_CREATED_CONFIG_FLAG
  ,l_Item_rec.MODEL_CONFIG_CLAUSE_NAME
  ,l_Item_rec.COSTING_ENABLED_FLAG
  ,l_Item_rec.INVENTORY_ASSET_FLAG
  ,l_Item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG
  ,l_Item_rec.COST_OF_SALES_ACCOUNT
  ,l_Item_rec.STD_LOT_SIZE
  ,l_Item_rec.PURCHASING_ITEM_FLAG
  ,l_Item_rec.PURCHASING_ENABLED_FLAG
  ,l_Item_rec.MUST_USE_APPROVED_VENDOR_FLAG
  ,l_Item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG
  ,l_Item_rec.RFQ_REQUIRED_FLAG
  ,l_Item_rec.OUTSIDE_OPERATION_FLAG
  ,l_Item_rec.OUTSIDE_OPERATION_UOM_TYPE
  ,l_Item_rec.TAXABLE_FLAG
  ,l_Item_rec.PURCHASING_TAX_CODE
  ,l_Item_rec.RECEIPT_REQUIRED_FLAG
  ,l_Item_rec.INSPECTION_REQUIRED_FLAG
  ,l_Item_rec.BUYER_ID
  ,l_Item_rec.UNIT_OF_ISSUE
  ,l_Item_rec.RECEIVE_CLOSE_TOLERANCE
  ,l_Item_rec.INVOICE_CLOSE_TOLERANCE
  ,l_Item_rec.UN_NUMBER_ID
  ,l_Item_rec.HAZARD_CLASS_ID
  ,l_Item_rec.LIST_PRICE_PER_UNIT
  ,l_Item_rec.MARKET_PRICE
  ,l_Item_rec.PRICE_TOLERANCE_PERCENT
  ,l_Item_rec.ROUNDING_FACTOR
  ,l_Item_rec.ENCUMBRANCE_ACCOUNT
  ,l_Item_rec.EXPENSE_ACCOUNT
  ,l_Item_rec.ASSET_CATEGORY_ID
  ,l_Item_rec.RECEIPT_DAYS_EXCEPTION_CODE
  ,l_Item_rec.DAYS_EARLY_RECEIPT_ALLOWED
  ,l_Item_rec.DAYS_LATE_RECEIPT_ALLOWED
  ,l_Item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG
  ,l_Item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG
  ,l_Item_rec.ALLOW_EXPRESS_DELIVERY_FLAG
  ,l_Item_rec.QTY_RCV_EXCEPTION_CODE
  ,l_Item_rec.QTY_RCV_TOLERANCE
  ,l_Item_rec.RECEIVING_ROUTING_ID
  ,l_Item_rec.ENFORCE_SHIP_TO_LOCATION_CODE
  ,l_Item_rec.WEIGHT_UOM_CODE
  ,l_Item_rec.UNIT_WEIGHT
  ,l_Item_rec.VOLUME_UOM_CODE
  ,l_Item_rec.UNIT_VOLUME
  ,l_Item_rec.CONTAINER_ITEM_FLAG
  ,l_Item_rec.VEHICLE_ITEM_FLAG
  ,l_Item_rec.CONTAINER_TYPE_CODE
  ,l_Item_rec.INTERNAL_VOLUME
  ,l_Item_rec.MAXIMUM_LOAD_WEIGHT
  ,l_Item_rec.MINIMUM_FILL_PERCENT
  ,l_Item_rec.INVENTORY_PLANNING_CODE
  ,l_Item_rec.PLANNER_CODE
  ,l_Item_rec.PLANNING_MAKE_BUY_CODE
  ,l_Item_rec.MIN_MINMAX_QUANTITY
  ,l_Item_rec.MAX_MINMAX_QUANTITY
  ,l_Item_rec.MINIMUM_ORDER_QUANTITY
  ,l_Item_rec.MAXIMUM_ORDER_QUANTITY
  ,l_Item_rec.ORDER_COST
  ,l_Item_rec.CARRYING_COST
  ,l_Item_rec.SOURCE_TYPE
  ,l_Item_rec.SOURCE_ORGANIZATION_ID
  ,l_Item_rec.SOURCE_SUBINVENTORY
  ,l_Item_rec.MRP_SAFETY_STOCK_CODE
  ,l_Item_rec.SAFETY_STOCK_BUCKET_DAYS
  ,l_Item_rec.MRP_SAFETY_STOCK_PERCENT
  ,l_Item_rec.FIXED_ORDER_QUANTITY
  ,l_Item_rec.FIXED_DAYS_SUPPLY
  ,l_Item_rec.FIXED_LOT_MULTIPLIER
  ,l_Item_rec.MRP_PLANNING_CODE
  ,l_Item_rec.ATO_FORECAST_CONTROL
  ,l_Item_rec.PLANNING_EXCEPTION_SET
  ,l_Item_rec.END_ASSEMBLY_PEGGING_FLAG
  ,l_Item_rec.SHRINKAGE_RATE
  ,l_Item_rec.ROUNDING_CONTROL_TYPE
  ,l_Item_rec.ACCEPTABLE_EARLY_DAYS
  ,l_Item_rec.REPETITIVE_PLANNING_FLAG
  ,l_Item_rec.OVERRUN_PERCENTAGE
  ,l_Item_rec.ACCEPTABLE_RATE_INCREASE
  ,l_Item_rec.ACCEPTABLE_RATE_DECREASE
  ,l_Item_rec.MRP_CALCULATE_ATP_FLAG
  ,l_Item_rec.AUTO_REDUCE_MPS
  ,l_Item_rec.PLANNING_TIME_FENCE_CODE
  ,l_Item_rec.PLANNING_TIME_FENCE_DAYS
  ,l_Item_rec.DEMAND_TIME_FENCE_CODE
  ,l_Item_rec.DEMAND_TIME_FENCE_DAYS
  ,l_Item_rec.RELEASE_TIME_FENCE_CODE
  ,l_Item_rec.RELEASE_TIME_FENCE_DAYS
  ,l_Item_rec.PREPROCESSING_LEAD_TIME
  ,l_Item_rec.FULL_LEAD_TIME
  ,l_Item_rec.POSTPROCESSING_LEAD_TIME
  ,l_Item_rec.FIXED_LEAD_TIME
  ,l_Item_rec.VARIABLE_LEAD_TIME
  ,l_Item_rec.CUM_MANUFACTURING_LEAD_TIME
  ,l_Item_rec.CUMULATIVE_TOTAL_LEAD_TIME
  ,l_Item_rec.LEAD_TIME_LOT_SIZE
  ,l_Item_rec.BUILD_IN_WIP_FLAG
  ,l_Item_rec.WIP_SUPPLY_TYPE
  ,l_Item_rec.WIP_SUPPLY_SUBINVENTORY
  ,l_Item_rec.WIP_SUPPLY_LOCATOR_ID
  ,l_Item_rec.OVERCOMPLETION_TOLERANCE_TYPE
  ,l_Item_rec.OVERCOMPLETION_TOLERANCE_VALUE
  ,l_Item_rec.CUSTOMER_ORDER_FLAG
  ,l_Item_rec.CUSTOMER_ORDER_ENABLED_FLAG
  ,l_Item_rec.SHIPPABLE_ITEM_FLAG
  ,l_Item_rec.INTERNAL_ORDER_FLAG
  ,l_Item_rec.INTERNAL_ORDER_ENABLED_FLAG
  ,l_Item_rec.SO_TRANSACTIONS_FLAG
  ,l_Item_rec.PICK_COMPONENTS_FLAG
  ,l_Item_rec.ATP_FLAG
  ,l_Item_rec.REPLENISH_TO_ORDER_FLAG
  ,l_Item_rec.ATP_RULE_ID
  ,l_Item_rec.ATP_COMPONENTS_FLAG
  ,l_Item_rec.SHIP_MODEL_COMPLETE_FLAG
  ,l_Item_rec.PICKING_RULE_ID
  ,l_Item_rec.COLLATERAL_FLAG
  ,l_Item_rec.DEFAULT_SHIPPING_ORG
  ,l_Item_rec.RETURNABLE_FLAG
  ,l_Item_rec.RETURN_INSPECTION_REQUIREMENT
  ,l_Item_rec.OVER_SHIPMENT_TOLERANCE
  ,l_Item_rec.UNDER_SHIPMENT_TOLERANCE
  ,l_Item_rec.OVER_RETURN_TOLERANCE
  ,l_Item_rec.UNDER_RETURN_TOLERANCE
  ,l_Item_rec.INVOICEABLE_ITEM_FLAG
  ,l_Item_rec.INVOICE_ENABLED_FLAG
  ,l_Item_rec.ACCOUNTING_RULE_ID
  ,l_Item_rec.INVOICING_RULE_ID
  ,l_Item_rec.TAX_CODE
  ,l_Item_rec.SALES_ACCOUNT
  ,l_Item_rec.PAYMENT_TERMS_ID
  ,l_Item_rec.COVERAGE_SCHEDULE_ID
  ,l_Item_rec.SERVICE_DURATION
  ,l_Item_rec.SERVICE_DURATION_PERIOD_CODE
  ,l_Item_rec.SERVICEABLE_PRODUCT_FLAG
  ,l_Item_rec.SERVICE_STARTING_DELAY
  ,l_Item_rec.MATERIAL_BILLABLE_FLAG
  ,l_Item_rec.SERVICEABLE_COMPONENT_FLAG
  ,l_Item_rec.PREVENTIVE_MAINTENANCE_FLAG
  ,l_Item_rec.PRORATE_SERVICE_FLAG
  ,l_Item_rec.WH_UPDATE_DATE
  ,l_Item_rec.EQUIPMENT_TYPE
  ,l_Item_rec.RECOVERED_PART_DISP_CODE
  ,l_Item_rec.DEFECT_TRACKING_ON_FLAG
  ,l_Item_rec.EVENT_FLAG
  ,l_Item_rec.ELECTRONIC_FLAG
  ,l_Item_rec.DOWNLOADABLE_FLAG
  ,l_Item_rec.VOL_DISCOUNT_EXEMPT_FLAG
  ,l_Item_rec.COUPON_EXEMPT_FLAG
  ,l_Item_rec.COMMS_NL_TRACKABLE_FLAG
  ,l_Item_rec.ASSET_CREATION_CODE
  ,l_Item_rec.COMMS_ACTIVATION_REQD_FLAG
  ,l_Item_rec.WEB_STATUS
  ,l_Item_rec.ORDERABLE_ON_WEB_FLAG
  ,l_Item_rec.BACK_ORDERABLE_FLAG
  ,l_Item_rec.INDIVISIBLE_FLAG
  ,l_Item_rec.DIMENSION_UOM_CODE
  ,l_Item_rec.UNIT_LENGTH
  ,l_Item_rec.UNIT_WIDTH
  ,l_Item_rec.UNIT_HEIGHT
  ,l_Item_rec.BULK_PICKED_FLAG
  ,l_Item_rec.LOT_STATUS_ENABLED
  ,l_Item_rec.DEFAULT_LOT_STATUS_ID
  ,l_Item_rec.SERIAL_STATUS_ENABLED
  ,l_Item_rec.DEFAULT_SERIAL_STATUS_ID
  ,l_Item_rec.LOT_SPLIT_ENABLED
  ,l_Item_rec.LOT_MERGE_ENABLED
  ,l_Item_rec.INVENTORY_CARRY_PENALTY
  ,l_Item_rec.OPERATION_SLACK_PENALTY
  ,l_Item_rec.FINANCING_ALLOWED_FLAG
  ,l_Item_rec.EAM_ITEM_TYPE
  ,l_Item_rec.EAM_ACTIVITY_TYPE_CODE
  ,l_Item_rec.EAM_ACTIVITY_CAUSE_CODE
  ,l_Item_rec.EAM_ACT_NOTIFICATION_FLAG
  ,l_Item_rec.EAM_ACT_SHUTDOWN_STATUS
  ,l_Item_rec.DUAL_UOM_CONTROL
  ,l_Item_rec.SECONDARY_UOM_CODE
  ,l_Item_rec.DUAL_UOM_DEVIATION_HIGH
  ,l_Item_rec.DUAL_UOM_DEVIATION_LOW
  --
  ,DECODE(l_Contract_Item_Type_Code, g_Null_CHAR, g_Upd_Null_CHAR, g_MISS_CHAR, NULL, l_Contract_Item_Type_Code)
  ,l_Item_rec.SUBSCRIPTION_DEPEND_FLAG
  --
  ,l_Item_rec.SERV_REQ_ENABLED_CODE
  ,l_Item_rec.SERV_BILLING_ENABLED_FLAG
  ,l_Item_rec.SERV_IMPORTANCE_LEVEL
  ,l_Item_rec.PLANNED_INV_POINT_FLAG
  ,l_Item_rec.LOT_TRANSLATE_ENABLED
  ,l_Item_rec.DEFAULT_SO_SOURCE_TYPE
  ,l_Item_rec.CREATE_SUPPLY_FLAG
  ,l_Item_rec.SUBSTITUTION_WINDOW_CODE
  ,l_Item_rec.SUBSTITUTION_WINDOW_DAYS
-- Added as part of 11.5.9
  ,l_Item_rec.LOT_SUBSTITUTION_ENABLED
  ,l_Item_rec.MINIMUM_LICENSE_QUANTITY
  ,l_Item_rec.EAM_ACTIVITY_SOURCE_CODE
  ,l_Item_rec.IB_ITEM_INSTANCE_CLASS
  ,l_Item_rec.CONFIG_MODEL_TYPE
-- Added as part of 11.5.10
  ,l_Item_rec.TRACKING_QUANTITY_IND
  ,l_Item_rec.ONT_PRICING_QTY_SOURCE
  ,l_Item_rec.SECONDARY_DEFAULT_IND
  ,l_Item_rec.CONFIG_ORGS
  ,l_Item_rec.CONFIG_MATCH
--
  ,l_Item_rec.ATTRIBUTE_CATEGORY
  ,l_Item_rec.ATTRIBUTE1
  ,l_Item_rec.ATTRIBUTE2
  ,l_Item_rec.ATTRIBUTE3
  ,l_Item_rec.ATTRIBUTE4
  ,l_Item_rec.ATTRIBUTE5
  ,l_Item_rec.ATTRIBUTE6
  ,l_Item_rec.ATTRIBUTE7
  ,l_Item_rec.ATTRIBUTE8
  ,l_Item_rec.ATTRIBUTE9
  ,l_Item_rec.ATTRIBUTE10
  ,l_Item_rec.ATTRIBUTE11
  ,l_Item_rec.ATTRIBUTE12
  ,l_Item_rec.ATTRIBUTE13
  ,l_Item_rec.ATTRIBUTE14
  ,l_Item_rec.ATTRIBUTE15
  /* Start Bug 3713912 */
  ,l_Item_rec.ATTRIBUTE16
  ,l_Item_rec.ATTRIBUTE17
  ,l_Item_rec.ATTRIBUTE18
  ,l_Item_rec.ATTRIBUTE19
  ,l_Item_rec.ATTRIBUTE20
  ,l_Item_rec.ATTRIBUTE21
  ,l_Item_rec.ATTRIBUTE22
  ,l_Item_rec.ATTRIBUTE23
  ,l_Item_rec.ATTRIBUTE24
  ,l_Item_rec.ATTRIBUTE25
  ,l_Item_rec.ATTRIBUTE26
  ,l_Item_rec.ATTRIBUTE27
  ,l_Item_rec.ATTRIBUTE28
  ,l_Item_rec.ATTRIBUTE29
  ,l_Item_rec.ATTRIBUTE30
  /* End Bug 3713912 */
  ,l_Item_rec.GLOBAL_ATTRIBUTE_CATEGORY
  ,l_Item_rec.GLOBAL_ATTRIBUTE1
  ,l_Item_rec.GLOBAL_ATTRIBUTE2
  ,l_Item_rec.GLOBAL_ATTRIBUTE3
  ,l_Item_rec.GLOBAL_ATTRIBUTE4
  ,l_Item_rec.GLOBAL_ATTRIBUTE5
  ,l_Item_rec.GLOBAL_ATTRIBUTE6
  ,l_Item_rec.GLOBAL_ATTRIBUTE7
  ,l_Item_rec.GLOBAL_ATTRIBUTE8
  ,l_Item_rec.GLOBAL_ATTRIBUTE9
  ,l_Item_rec.GLOBAL_ATTRIBUTE10
  ,l_Item_rec.GLOBAL_ATTRIBUTE11
  ,l_Item_rec.GLOBAL_ATTRIBUTE12
  ,l_Item_rec.GLOBAL_ATTRIBUTE13
  ,l_Item_rec.GLOBAL_ATTRIBUTE14
  ,l_Item_rec.GLOBAL_ATTRIBUTE15
  ,l_Item_rec.GLOBAL_ATTRIBUTE16
  ,l_Item_rec.GLOBAL_ATTRIBUTE17
  ,l_Item_rec.GLOBAL_ATTRIBUTE18
  ,l_Item_rec.GLOBAL_ATTRIBUTE19
  ,l_Item_rec.GLOBAL_ATTRIBUTE20
  ,SYSDATE
  ,FND_GLOBAL.user_id
  ,SYSDATE
  ,FND_GLOBAL.user_id
  ,FND_GLOBAL.login_id
  ,FND_GLOBAL.conc_request_id
  ,FND_GLOBAL.prog_appl_id
  ,FND_GLOBAL.conc_program_id
  ,SYSDATE
  ,l_Item_rec.VMI_MINIMUM_UNITS
  ,l_Item_rec.VMI_MINIMUM_DAYS
  ,l_Item_rec.VMI_MAXIMUM_UNITS
  ,l_Item_rec.VMI_MAXIMUM_DAYS
  ,l_Item_rec.VMI_FIXED_ORDER_QUANTITY
  ,l_Item_rec.SO_AUTHORIZATION_FLAG
  ,l_Item_rec.CONSIGNED_FLAG
  ,l_Item_rec.ASN_AUTOEXPIRE_FLAG
  ,l_Item_rec.VMI_FORECAST_TYPE
  ,l_Item_rec.FORECAST_HORIZON
  ,l_Item_rec.EXCLUDE_FROM_BUDGET_FLAG
  ,l_Item_rec.DAYS_TGT_INV_SUPPLY
  ,l_Item_rec.DAYS_TGT_INV_WINDOW
  ,l_Item_rec.DAYS_MAX_INV_SUPPLY
  ,l_Item_rec.DAYS_MAX_INV_WINDOW
  ,l_Item_rec.DRP_PLANNED_FLAG
  ,l_Item_rec.CRITICAL_COMPONENT_FLAG
  ,l_Item_rec.CONTINOUS_TRANSFER
  ,l_Item_rec.CONVERGENCE
  ,l_Item_rec.DIVERGENCE
  /* Start Bug 3713912 */
  ,l_Item_rec.LOT_DIVISIBLE_FLAG
  ,l_Item_rec.GRADE_CONTROL_FLAG
  ,l_Item_rec.DEFAULT_GRADE
  ,l_Item_rec.CHILD_LOT_FLAG
  ,l_Item_rec.PARENT_CHILD_GENERATION_FLAG
  ,l_Item_rec.CHILD_LOT_PREFIX
  ,l_Item_rec.CHILD_LOT_STARTING_NUMBER
  ,l_Item_rec.CHILD_LOT_VALIDATION_FLAG
  ,l_Item_rec.COPY_LOT_ATTRIBUTE_FLAG
  ,l_Item_rec.RECIPE_ENABLED_FLAG
  ,l_Item_rec.PROCESS_QUALITY_ENABLED_FLAG
  ,l_Item_rec.PROCESS_EXECUTION_ENABLED_FLAG
  ,l_Item_rec.PROCESS_COSTING_ENABLED_FLAG
  ,l_Item_rec.PROCESS_SUPPLY_SUBINVENTORY
  ,l_Item_rec.PROCESS_SUPPLY_LOCATOR_ID
  ,l_Item_rec.PROCESS_YIELD_SUBINVENTORY
  ,l_Item_rec.PROCESS_YIELD_LOCATOR_ID
  ,l_Item_rec.HAZARDOUS_MATERIAL_FLAG
  ,l_Item_rec.CAS_NUMBER
  ,l_Item_rec.RETEST_INTERVAL
  ,l_Item_rec.EXPIRATION_ACTION_INTERVAL
  ,l_Item_rec.EXPIRATION_ACTION_CODE
  ,l_Item_rec.MATURITY_DAYS
  ,l_Item_rec.HOLD_DAYS
  /* End Bug 3713912 */
  /* Bug: 3933277 */
  ,l_Item_rec.Lifecycle_Id
  ,l_Item_rec.Current_Phase_Id
  /* Bug: 3933277 */
  /* R12 Enhancement */
  ,l_Item_rec.CHARGE_PERIODICITY_CODE
  ,l_Item_rec.REPAIR_LEADTIME
  ,l_Item_rec.REPAIR_YIELD
  ,l_Item_rec.PREPOSITION_POINT
  ,l_Item_rec.REPAIR_PROGRAM
  ,l_Item_rec.SUBCONTRACTING_COMPONENT
  ,l_Item_rec.OUTSOURCED_ASSEMBLY
   --R12 C Attributes
  ,l_Item_rec.GDSN_OUTBOUND_ENABLED_FLAG
  ,l_Item_rec.TRADE_ITEM_DESCRIPTOR
  ,l_Item_rec.STYLE_ITEM_FLAG
  ,l_Item_rec.STYLE_ITEM_ID
  ) RETURNING ROWID INTO l_item_rowid;

  Insert_Revision_Record(
   p_item_rowid      => l_item_rowid
  ,p_Revision_rec    => p_Revision_rec
  ,p_set_process_id  => l_set_process_id
  ,x_return_status   => x_return_status
  ,x_return_err      => x_return_err);


  IF ( fnd_api.to_Boolean (p_commit) ) THEN
     COMMIT WORK;
  END IF;

EXCEPTION

  WHEN others THEN
     ROLLBACK TO Insert_MSII_Row;
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'INV_ITEM_GRP.Insert_MSII_Row: Unexpexted error: ' || SQLERRM;

END Insert_MSII_Row;

PROCEDURE Insert_Revision_Record(
   p_item_rowid      IN  ROWID
  ,p_Revision_rec    IN  INV_ITEM_GRP.Item_Revision_Rec_Type
  ,p_set_process_id  IN  NUMBER
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,x_return_err      OUT NOCOPY VARCHAR2)
IS

   p_Upd_Null_CHAR      VARCHAR2(1);
   p_Upd_Null_NUM       NUMBER;
   p_Upd_Null_DATE      DATE;
   l_default_revision   mtl_item_revisions_interface.revision%TYPE;
   l_temp_integer       INTEGER;
   l_item_number        mtl_item_revisions_interface.item_number%TYPE := NULL;
   l_item_id            mtl_item_revisions_interface.inventory_item_id%TYPE := NULL;
   l_error_text         VARCHAR2(1000);

BEGIN

   x_return_status := fnd_api.g_RET_STS_SUCCESS;

   IF UPPER(p_Revision_rec.TRANSACTION_TYPE) IN ('CREATE','UPDATE','SYNC') THEN

      SELECT  starting_revision
      INTO    l_default_revision
      FROM    mtl_parameters
      WHERE   organization_id = p_Revision_rec.ORGANIZATION_ID;

      l_item_number := p_Revision_rec.ITEM_NUMBER;

      IF (l_item_number IS NULL OR l_item_number = G_MISS_CHAR) THEN
         l_temp_integer:=INVPUOPI.mtl_pr_parse_item_segments
                            (p_row_id      => p_item_rowid
                            ,item_number   => l_item_number
                            ,item_id       => l_item_id
                            ,err_text      => l_error_text);
      END IF;

      IF ( UPPER(p_Revision_rec.TRANSACTION_TYPE) = 'UPDATE' ) THEN
         p_Upd_Null_CHAR  :=  '!';
         p_Upd_Null_NUM   :=  -999999;
         p_Upd_Null_DATE  :=  NULL;
      ELSE
         p_Upd_Null_CHAR  :=  NULL;
         p_Upd_Null_NUM   :=  NULL;
         p_Upd_Null_DATE  :=  NULL;
      END IF;

      INSERT INTO MTL_ITEM_REVISIONS_INTERFACE (
          INVENTORY_ITEM_ID
         ,ORGANIZATION_ID
         ,REVISION
         ,EFFECTIVITY_DATE
         ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,DESCRIPTION
         ,ITEM_NUMBER
         ,PROCESS_FLAG
         ,TRANSACTION_TYPE
         ,SET_PROCESS_ID
         ,REVISION_ID
         ,REVISION_LABEL
         ,LIFECYCLE_ID
         ,CURRENT_PHASE_ID
   ,TEMPLATE_ID
   ,TEMPLATE_NAME
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE)
      VALUES
         (NVL(DECODE(p_Revision_rec.INVENTORY_ITEM_ID     , g_Null_NUM , p_Upd_Null_NUM , g_MISS_NUM , NULL, p_Revision_rec.INVENTORY_ITEM_ID),l_item_id)
         ,DECODE(p_Revision_rec.ORGANIZATION_ID           , g_Null_NUM , p_Upd_Null_NUM , g_MISS_NUM , NULL, p_Revision_rec.ORGANIZATION_ID)
         ,NVL(DECODE(p_Revision_rec.revision_code         , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.revision_code),l_default_revision)
         ,NVL(DECODE(p_Revision_rec.EFFECTIVITY_DATE      , g_Null_DATE, p_Upd_Null_DATE, g_MISS_DATE, NULL, p_Revision_rec.EFFECTIVITY_DATE),SYSDATE)
         ,DECODE(p_Revision_rec.ATTRIBUTE_CATEGORY, g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE_CATEGORY)
         ,DECODE(p_Revision_rec.ATTRIBUTE1        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE1)
         ,DECODE(p_Revision_rec.ATTRIBUTE2        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE2)
         ,DECODE(p_Revision_rec.ATTRIBUTE3        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE3)
         ,DECODE(p_Revision_rec.ATTRIBUTE4        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE4)
         ,DECODE(p_Revision_rec.ATTRIBUTE5        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE5)
         ,DECODE(p_Revision_rec.ATTRIBUTE6        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE6)
         ,DECODE(p_Revision_rec.ATTRIBUTE7        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE7)
         ,DECODE(p_Revision_rec.ATTRIBUTE8        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE8)
         ,DECODE(p_Revision_rec.ATTRIBUTE9        , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE9)
         ,DECODE(p_Revision_rec.ATTRIBUTE10       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE10)
         ,DECODE(p_Revision_rec.ATTRIBUTE11       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE11)
         ,DECODE(p_Revision_rec.ATTRIBUTE12       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE12)
         ,DECODE(p_Revision_rec.ATTRIBUTE13       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE13)
         ,DECODE(p_Revision_rec.ATTRIBUTE14       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE14)
         ,DECODE(p_Revision_rec.ATTRIBUTE15       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ATTRIBUTE15)
         ,DECODE(p_Revision_rec.DESCRIPTION       , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.DESCRIPTION)
         ,NVL(DECODE(p_Revision_rec.ITEM_NUMBER   , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.ITEM_NUMBER),l_item_number)
         ,1
         ,p_Revision_rec.TRANSACTION_TYPE
         ,P_SET_PROCESS_ID
         ,DECODE(p_Revision_rec.REVISION_ID       , g_Null_NUM , p_Upd_Null_NUM , g_MISS_NUM , NULL, p_Revision_rec.REVISION_ID)
         ,DECODE(p_Revision_rec.REVISION_LABEL    , g_Null_CHAR, p_Upd_Null_CHAR, g_MISS_CHAR, NULL, p_Revision_rec.REVISION_LABEL)
         ,DECODE(p_Revision_rec.LIFECYCLE_ID      , g_Null_NUM , p_Upd_Null_NUM , g_MISS_NUM , NULL, p_Revision_rec.LIFECYCLE_ID)
         ,DECODE(p_Revision_rec.CURRENT_PHASE_ID  , g_Null_NUM , p_Upd_Null_NUM , g_MISS_NUM , NULL, p_Revision_rec.CURRENT_PHASE_ID)
          --5208102: Supporting template for UDA's at revisions
         ,DECODE(p_Revision_rec.TEMPLATE_ID       ,g_Null_NUM   ,p_Upd_Null_NUM  ,g_MISS_NUM  ,NULL ,p_Revision_rec.TEMPLATE_ID)
         ,DECODE(p_Revision_rec.TEMPLATE_NAME     ,g_Null_CHAR  ,p_Upd_Null_CHAR ,g_MISS_CHAR ,NULL ,p_Revision_rec.TEMPLATE_NAME)
         ,SYSDATE
         ,FND_GLOBAL.user_id
         ,SYSDATE
         ,FND_GLOBAL.user_id
         ,FND_GLOBAL.login_id
         ,FND_GLOBAL.conc_request_id
         ,FND_GLOBAL.prog_appl_id
         ,FND_GLOBAL.conc_program_id
         ,SYSDATE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err    := 'INV_ITEM_GRP.Insert_Revision_Record: Unexpexted error: ' || SQLERRM;
END Insert_Revision_Record;

-- -------------------- Get_Item ---------------------

PROCEDURE Get_Item
(
    p_Item_Number        IN    VARCHAR2       :=  fnd_api.g_MISS_CHAR
,   p_Item_ID            IN    NUMBER         :=  fnd_api.g_MISS_NUM
,   p_Org_ID             IN    NUMBER
,   p_Language_Code      IN    VARCHAR2       :=  fnd_api.g_MISS_CHAR
,   x_Item_rec           OUT   NOCOPY INV_ITEM_GRP.Item_rec_type
,   x_return_status      OUT   NOCOPY VARCHAR2
,   x_return_err         OUT   NOCOPY VARCHAR2
)
IS
  l_api_name     CONSTANT  VARCHAR2(30)  :=  'Get_Item';
  l_return_status          VARCHAR2(1);
BEGIN

  -- Initialize API return status to success
  --
  x_return_status := fnd_api.g_RET_STS_SUCCESS;

  IF ( p_Item_ID = fnd_api.g_MISS_NUM ) OR ( p_Item_ID IS NULL ) OR
     ( p_Org_ID  = fnd_api.g_MISS_NUM ) OR ( p_Org_ID  IS NULL )
  THEN
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'INV_ITEM_GRP.Get_Item: INV_MISS_ORG_ITEM_ID';
     RETURN;
/*
     fnd_message.SET_NAME( 'INV', 'INV_MISS_ORG_ITEM_ID' );
     fnd_msg_pub.Add;
     RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
*/
  END IF;

  --------------------------------------------
  -- Open item query and fetch a first row.
  --------------------------------------------

  OPEN Item_csr (  p_Item_ID  =>  p_Item_ID
                ,  p_Org_ID   =>  p_Org_ID
                );

  FETCH Item_csr INTO x_Item_rec;

  IF ( Item_csr%NOTFOUND ) THEN
     CLOSE Item_csr;
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'INV_ITEM_GRP.Get_Item: Item not found.';
     RETURN;
/*
     fnd_message.SET_NAME( 'INV', 'INV_ORG_ITEM_NOTFOUND' );
     fnd_msg_pub.Add;
     RAISE fnd_api.g_EXC_UNEXPECTED_ERROR;
*/
  END IF;

  CLOSE Item_csr;

EXCEPTION

  WHEN others THEN
     IF ( Item_csr%ISOPEN ) THEN
        CLOSE Item_csr;
     END IF;
     x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     x_return_err := 'INV_ITEM_GRP.Get_Item: Unexpected error: ' || SQLERRM;

END Get_Item;

PROCEDURE Interface_Handler
(
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_transaction_type IN VARCHAR2
 ,p_Item_rec IN INV_ITEM_GRP.Item_Rec_Type
 ,P_revision_rec IN INV_ITEM_GRP.Item_Revision_Rec_Type
 ,p_Template_Id IN NUMBER
 ,p_Template_Name IN VARCHAR2
 ,x_batch_id OUT NOCOPY NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_return_err  OUT NOCOPY VARCHAR2
)
IS
 l_return_status VARCHAR2(1);
 l_return_err    VARCHAR2(1000);
 l_error_exists  NUMBER := 0;
BEGIN

  --Adding basic validations before creating item row in Interface

  IF p_transaction_type NOT IN ('CREATE', 'UPDATE', 'SYNC') THEN
     l_return_err := 'INV_INVALID_TTYPE';
     l_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
     l_error_exists := 1;
  END IF;

  IF (P_item_rec.organization_id = g_MISS_NUM AND p_item_rec.organization_code = g_MISS_CHAR )
  THEN
        l_return_err := 'INV_ORG_CODE_MAND';
        l_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
        l_error_exists := 1;
  END IF;

  IF(p_transaction_type = 'CREATE' AND P_item_rec.item_number = g_MISS_CHAR AND
     P_item_rec.segment1  = g_MISS_CHAR AND P_item_rec.segment2   = g_MISS_CHAR AND
     P_item_rec.segment3  = g_MISS_CHAR AND P_item_rec.segment4   = g_MISS_CHAR AND
     P_item_rec.segment5  = g_MISS_CHAR AND P_item_rec.segment6   = g_MISS_CHAR AND
     P_item_rec.segment7  = g_MISS_CHAR AND P_item_rec.segment8   = g_MISS_CHAR AND
     P_item_rec.segment9  = g_MISS_CHAR AND P_item_rec.segment10  = g_MISS_CHAR AND
     P_item_rec.segment11 = g_MISS_CHAR AND P_item_rec.segment12  = g_MISS_CHAR AND
     P_item_rec.segment13 = g_MISS_CHAR AND P_item_rec.segment14  = g_MISS_CHAR AND
     P_item_rec.segment15 = g_MISS_CHAR AND P_item_rec.segment16  = g_MISS_CHAR AND
     P_item_rec.segment17 = g_MISS_CHAR AND P_item_rec.segment18  = g_MISS_CHAR AND
     P_item_rec.segment19 = g_MISS_CHAR AND P_item_rec.segment20  = g_MISS_CHAR)
  THEN
      l_return_err := 'INV_SEG_ITM_NUMB_VAL';
      l_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      l_error_exists := 1;

  ELSIF(p_transaction_type = 'UPDATE' AND P_Item_rec.inventory_item_id  = g_MISS_NUM AND
        P_item_rec.item_number = g_MISS_CHAR AND
        P_item_rec.segment1  = g_MISS_CHAR AND P_item_rec.segment2   = g_MISS_CHAR AND
        P_item_rec.segment3  = g_MISS_CHAR AND P_item_rec.segment4   = g_MISS_CHAR AND
        P_item_rec.segment5  = g_MISS_CHAR AND P_item_rec.segment6   = g_MISS_CHAR AND
        P_item_rec.segment7  = g_MISS_CHAR AND P_item_rec.segment8   = g_MISS_CHAR AND
        P_item_rec.segment9  = g_MISS_CHAR AND P_item_rec.segment10  = g_MISS_CHAR AND
        P_item_rec.segment11 = g_MISS_CHAR AND P_item_rec.segment12  = g_MISS_CHAR AND
        P_item_rec.segment13 = g_MISS_CHAR AND P_item_rec.segment14  = g_MISS_CHAR AND
        P_item_rec.segment15 = g_MISS_CHAR AND P_item_rec.segment16  = g_MISS_CHAR AND
        P_item_rec.segment17 = g_MISS_CHAR AND P_item_rec.segment18  = g_MISS_CHAR AND
        P_item_rec.segment19 = g_MISS_CHAR AND P_item_rec.segment20  = g_MISS_CHAR )
  THEN
        l_return_err := 'INV_SEG_ITM_NUMB_VAL';
        l_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
        l_error_exists := 1;
  END IF;

  IF l_error_exists = 0 THEN
     Insert_MSII_Row
     (
        p_commit            =>  p_commit
     ,  p_transaction_type  =>  p_transaction_type
     ,  p_Item_rec          =>  p_Item_rec
     ,  p_revision_rec      =>  p_revision_rec
     ,  p_Template_Id       =>  p_Template_Id
     ,  p_Template_Name     =>  p_Template_Name
     ,  x_set_process_id    =>  x_batch_id
     ,  x_return_status     =>  l_return_status
     ,  x_return_err        =>  l_return_err
     );

     IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
        l_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
        l_return_err := SUBSTR(l_return_err,1,239);
     END IF;
  END IF;

  x_return_status := l_return_status;
  x_return_err := l_return_err;

  IF FND_API.To_Boolean(p_commit) THEN
     COMMIT WORK;
  END IF;

END Interface_Handler;


END INV_ITEM_GRP;

/
