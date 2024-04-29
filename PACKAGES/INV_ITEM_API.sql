--------------------------------------------------------
--  DDL for Package INV_ITEM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_API" AUTHID CURRENT_USER AS
/* $Header: INVVIPIS.pls 120.3.12010000.3 2010/07/29 14:51:21 ccsingh ship $ */

-- =============================================================================
--                                  Global types
-- =============================================================================

--  For the Item record type use explicit list of columns,
--  not MTL_SYSTEM_ITEMS_B%ROWTYPE, because
--   (1) record elements must be initialized to pre-defined constants
--       representing missing values;
--   (2) need to include value based attributes absent from the entity table.

TYPE Item_rec_type IS RECORD
(
   INVENTORY_ITEM_ID                    NUMBER
,  ORGANIZATION_ID                      NUMBER
,       MASTER_ORGANIZATION_ID          NUMBER
,       DESCRIPTION                     VARCHAR2(240)
,       LONG_DESCRIPTION                VARCHAR2(4000)
,       PRIMARY_UOM_CODE                VARCHAR2(3)
,       PRIMARY_UNIT_OF_MEASURE         VARCHAR2(25)
,       ITEM_TYPE                       VARCHAR2(30)
,       INVENTORY_ITEM_STATUS_CODE      VARCHAR2(10)
,       ALLOWED_UNITS_LOOKUP_CODE       NUMBER
,       ITEM_CATALOG_GROUP_ID           NUMBER
,       CATALOG_STATUS_FLAG             VARCHAR2(1)
,       INVENTORY_ITEM_FLAG             VARCHAR2(1)
,       STOCK_ENABLED_FLAG              VARCHAR2(1)
,       MTL_TRANSACTIONS_ENABLED_FLAG   VARCHAR2(1)
,       CHECK_SHORTAGES_FLAG            VARCHAR2(1)
,       REVISION_QTY_CONTROL_CODE       NUMBER
,       RESERVABLE_TYPE                 NUMBER
,       SHELF_LIFE_CODE                 NUMBER
,       SHELF_LIFE_DAYS                 NUMBER
,       CYCLE_COUNT_ENABLED_FLAG        VARCHAR2(1)
,       NEGATIVE_MEASUREMENT_ERROR      NUMBER
,       POSITIVE_MEASUREMENT_ERROR      NUMBER
,       LOT_CONTROL_CODE                NUMBER
,       AUTO_LOT_ALPHA_PREFIX           VARCHAR2(30)
,       START_AUTO_LOT_NUMBER           VARCHAR2(30)
,       SERIAL_NUMBER_CONTROL_CODE      NUMBER
,       AUTO_SERIAL_ALPHA_PREFIX        VARCHAR2(30)
,       START_AUTO_SERIAL_NUMBER        VARCHAR2(30)
,       LOCATION_CONTROL_CODE           NUMBER
,       RESTRICT_SUBINVENTORIES_CODE    NUMBER
,       RESTRICT_LOCATORS_CODE          NUMBER
,       BOM_ENABLED_FLAG                VARCHAR2(1)
,       BOM_ITEM_TYPE                   NUMBER
,       BASE_ITEM_ID                    NUMBER
,       EFFECTIVITY_CONTROL             NUMBER
,       ENG_ITEM_FLAG                   VARCHAR2(1)
,       ENGINEERING_ECN_CODE            VARCHAR2(50)
,       ENGINEERING_ITEM_ID             NUMBER
,       ENGINEERING_DATE                DATE
,       PRODUCT_FAMILY_ITEM_ID          NUMBER
,       AUTO_CREATED_CONFIG_FLAG        VARCHAR2(1)
,       MODEL_CONFIG_CLAUSE_NAME        VARCHAR2(10)
-- Attribute not in the form
,       NEW_REVISION_CODE               VARCHAR2(30)
,       COSTING_ENABLED_FLAG            VARCHAR2(1)
,       INVENTORY_ASSET_FLAG            VARCHAR2(1)
,       DEFAULT_INCLUDE_IN_ROLLUP_FLAG  VARCHAR2(1)
,       COST_OF_SALES_ACCOUNT           NUMBER
,       STD_LOT_SIZE                    NUMBER
,       PURCHASING_ITEM_FLAG            VARCHAR2(1)
,       PURCHASING_ENABLED_FLAG         VARCHAR2(1)
,       MUST_USE_APPROVED_VENDOR_FLAG   VARCHAR2(1)
,       ALLOW_ITEM_DESC_UPDATE_FLAG     VARCHAR2(1)
,       RFQ_REQUIRED_FLAG               VARCHAR2(1)
,       OUTSIDE_OPERATION_FLAG          VARCHAR2(1)
,       OUTSIDE_OPERATION_UOM_TYPE      VARCHAR2(25)
,       TAXABLE_FLAG                    VARCHAR2(1)
,       PURCHASING_TAX_CODE             VARCHAR2(50)
,       RECEIPT_REQUIRED_FLAG           VARCHAR2(1)
,       INSPECTION_REQUIRED_FLAG        VARCHAR2(1)
,       BUYER_ID                        NUMBER
,       UNIT_OF_ISSUE                   VARCHAR2(25)
,       RECEIVE_CLOSE_TOLERANCE         NUMBER
,       INVOICE_CLOSE_TOLERANCE         NUMBER
,       UN_NUMBER_ID                    NUMBER
,       HAZARD_CLASS_ID                 NUMBER
,       LIST_PRICE_PER_UNIT             NUMBER
,       MARKET_PRICE                    NUMBER
,       PRICE_TOLERANCE_PERCENT         NUMBER
,       ROUNDING_FACTOR                 NUMBER
,       ENCUMBRANCE_ACCOUNT             NUMBER
,       EXPENSE_ACCOUNT                 NUMBER
,       ASSET_CATEGORY_ID               NUMBER
,       RECEIPT_DAYS_EXCEPTION_CODE     VARCHAR2(25)
,       DAYS_EARLY_RECEIPT_ALLOWED      NUMBER
,       DAYS_LATE_RECEIPT_ALLOWED       NUMBER
,       ALLOW_SUBSTITUTE_RECEIPTS_FLAG  VARCHAR2(1)
,       ALLOW_UNORDERED_RECEIPTS_FLAG   VARCHAR2(1)
,       ALLOW_EXPRESS_DELIVERY_FLAG     VARCHAR2(1)
,       QTY_RCV_EXCEPTION_CODE          VARCHAR2(25)
,       QTY_RCV_TOLERANCE               NUMBER
,       RECEIVING_ROUTING_ID            NUMBER
,       ENFORCE_SHIP_TO_LOCATION_CODE   VARCHAR2(25)
,       WEIGHT_UOM_CODE                 VARCHAR2(3)
,       UNIT_WEIGHT                     NUMBER
,       VOLUME_UOM_CODE                 VARCHAR2(3)
,       UNIT_VOLUME                     NUMBER
,       CONTAINER_ITEM_FLAG             VARCHAR2(1)
,       VEHICLE_ITEM_FLAG               VARCHAR2(1)
,       CONTAINER_TYPE_CODE             VARCHAR2(30)
,       INTERNAL_VOLUME                 NUMBER
,       MAXIMUM_LOAD_WEIGHT             NUMBER
,       MINIMUM_FILL_PERCENT            NUMBER
,       INVENTORY_PLANNING_CODE         NUMBER
,       PLANNER_CODE                    VARCHAR2(10)
,       PLANNING_MAKE_BUY_CODE          NUMBER
,       MIN_MINMAX_QUANTITY             NUMBER
,       MAX_MINMAX_QUANTITY             NUMBER
,       MINIMUM_ORDER_QUANTITY          NUMBER
,       MAXIMUM_ORDER_QUANTITY          NUMBER
,       ORDER_COST                      NUMBER
,       CARRYING_COST                   NUMBER
,       SOURCE_TYPE                     NUMBER
,       SOURCE_ORGANIZATION_ID          NUMBER
,       SOURCE_SUBINVENTORY             VARCHAR2(10)
,       MRP_SAFETY_STOCK_CODE           NUMBER
,       SAFETY_STOCK_BUCKET_DAYS        NUMBER
,       MRP_SAFETY_STOCK_PERCENT        NUMBER
,       FIXED_ORDER_QUANTITY            NUMBER
,       FIXED_DAYS_SUPPLY               NUMBER
,       FIXED_LOT_MULTIPLIER            NUMBER
,       MRP_PLANNING_CODE               NUMBER
,       ATO_FORECAST_CONTROL            NUMBER
,       PLANNING_EXCEPTION_SET          VARCHAR2(10)
,       END_ASSEMBLY_PEGGING_FLAG       VARCHAR2(1)
,       SHRINKAGE_RATE                  NUMBER
,       ROUNDING_CONTROL_TYPE           NUMBER
,       ACCEPTABLE_EARLY_DAYS           NUMBER
,       REPETITIVE_PLANNING_FLAG        VARCHAR2(1)
,       OVERRUN_PERCENTAGE              NUMBER
,       ACCEPTABLE_RATE_INCREASE        NUMBER
,       ACCEPTABLE_RATE_DECREASE        NUMBER
,       MRP_CALCULATE_ATP_FLAG          VARCHAR2(1)
,       AUTO_REDUCE_MPS                 NUMBER
,       PLANNING_TIME_FENCE_CODE        NUMBER
,       PLANNING_TIME_FENCE_DAYS        NUMBER
,       DEMAND_TIME_FENCE_CODE          NUMBER
,       DEMAND_TIME_FENCE_DAYS          NUMBER
,       RELEASE_TIME_FENCE_CODE         NUMBER
,       RELEASE_TIME_FENCE_DAYS         NUMBER
,       PREPROCESSING_LEAD_TIME         NUMBER
,       FULL_LEAD_TIME                  NUMBER
,       POSTPROCESSING_LEAD_TIME        NUMBER
,       FIXED_LEAD_TIME                 NUMBER
,       VARIABLE_LEAD_TIME              NUMBER
,       CUM_MANUFACTURING_LEAD_TIME     NUMBER
,       CUMULATIVE_TOTAL_LEAD_TIME      NUMBER
,       LEAD_TIME_LOT_SIZE              NUMBER
,       BUILD_IN_WIP_FLAG               VARCHAR2(1)
,       WIP_SUPPLY_TYPE                 NUMBER
,       WIP_SUPPLY_SUBINVENTORY         VARCHAR2(10)
,       WIP_SUPPLY_LOCATOR_ID           NUMBER
,       OVERCOMPLETION_TOLERANCE_TYPE   NUMBER
,       OVERCOMPLETION_TOLERANCE_VALUE  NUMBER
,       CUSTOMER_ORDER_FLAG             VARCHAR2(1)
,       CUSTOMER_ORDER_ENABLED_FLAG     VARCHAR2(1)
,       SHIPPABLE_ITEM_FLAG             VARCHAR2(1)
,       INTERNAL_ORDER_FLAG             VARCHAR2(1)
,       INTERNAL_ORDER_ENABLED_FLAG     VARCHAR2(1)
,       SO_TRANSACTIONS_FLAG            VARCHAR2(1)
,       PICK_COMPONENTS_FLAG            VARCHAR2(1)
,       ATP_FLAG                        VARCHAR2(1)
,       REPLENISH_TO_ORDER_FLAG         VARCHAR2(1)
,       ATP_RULE_ID                     NUMBER
,       ATP_COMPONENTS_FLAG             VARCHAR2(1)
,       SHIP_MODEL_COMPLETE_FLAG        VARCHAR2(1)
,       PICKING_RULE_ID                 NUMBER
,       COLLATERAL_FLAG                 VARCHAR2(1)
,       DEFAULT_SHIPPING_ORG            NUMBER
,       RETURNABLE_FLAG                 VARCHAR2(1)
,       RETURN_INSPECTION_REQUIREMENT   NUMBER
,       OVER_SHIPMENT_TOLERANCE         NUMBER
,       UNDER_SHIPMENT_TOLERANCE        NUMBER
,       OVER_RETURN_TOLERANCE           NUMBER
,       UNDER_RETURN_TOLERANCE          NUMBER
,       INVOICEABLE_ITEM_FLAG           VARCHAR2(1)
,       INVOICE_ENABLED_FLAG            VARCHAR2(1)
,       ACCOUNTING_RULE_ID              NUMBER
,       INVOICING_RULE_ID               NUMBER
,       TAX_CODE                        VARCHAR2(50)
,       SALES_ACCOUNT                   NUMBER
,       PAYMENT_TERMS_ID                NUMBER
,       COVERAGE_SCHEDULE_ID            NUMBER
,       SERVICE_DURATION                NUMBER
,       SERVICE_DURATION_PERIOD_CODE    VARCHAR2(10)
,       SERVICEABLE_PRODUCT_FLAG        VARCHAR2(1)
,       SERVICE_STARTING_DELAY          NUMBER
,       MATERIAL_BILLABLE_FLAG          VARCHAR2(30)
,       SERVICEABLE_COMPONENT_FLAG      VARCHAR2(1)
,       PREVENTIVE_MAINTENANCE_FLAG     VARCHAR2(1)
,       PRORATE_SERVICE_FLAG            VARCHAR2(1)
-- Attribute not in the form
,       SERVICEABLE_ITEM_CLASS_ID       NUMBER
-- Attribute not in the form
,       BASE_WARRANTY_SERVICE_ID        NUMBER
-- Attribute not in the form
,       WARRANTY_VENDOR_ID              NUMBER
-- Attribute not in the form
,       MAX_WARRANTY_AMOUNT             NUMBER
-- Attribute not in the form
,       RESPONSE_TIME_PERIOD_CODE       VARCHAR2(30)
-- Attribute not in the form
,       RESPONSE_TIME_VALUE             NUMBER
-- Attribute not in the form
,       PRIMARY_SPECIALIST_ID           NUMBER
-- Attribute not in the form
,       SECONDARY_SPECIALIST_ID         NUMBER
,       WH_UPDATE_DATE                  DATE
,        EQUIPMENT_TYPE                  NUMBER
,        RECOVERED_PART_DISP_CODE        VARCHAR2(30)
,        DEFECT_TRACKING_ON_FLAG         VARCHAR2(1)
,        EVENT_FLAG                      VARCHAR2(1)
,        ELECTRONIC_FLAG                 VARCHAR2(1)
,        DOWNLOADABLE_FLAG               VARCHAR2(1)
,        VOL_DISCOUNT_EXEMPT_FLAG        VARCHAR2(1)
,        COUPON_EXEMPT_FLAG              VARCHAR2(1)
,        COMMS_NL_TRACKABLE_FLAG         VARCHAR2(1)
,        ASSET_CREATION_CODE             VARCHAR2(30)
,        COMMS_ACTIVATION_REQD_FLAG      VARCHAR2(1)
,        ORDERABLE_ON_WEB_FLAG           VARCHAR2(1)
,        BACK_ORDERABLE_FLAG             VARCHAR2(1)
,        WEB_STATUS                      VARCHAR2(30)
,        INDIVISIBLE_FLAG                VARCHAR2(1)
,        DIMENSION_UOM_CODE              VARCHAR2(3)
,        UNIT_LENGTH                     NUMBER
,        UNIT_WIDTH                      NUMBER
,        UNIT_HEIGHT                     NUMBER
,        BULK_PICKED_FLAG                VARCHAR2(1)
,        LOT_STATUS_ENABLED              VARCHAR2(1)
,        DEFAULT_LOT_STATUS_ID           NUMBER
,        SERIAL_STATUS_ENABLED           VARCHAR2(1)
,        DEFAULT_SERIAL_STATUS_ID        NUMBER
,        LOT_SPLIT_ENABLED               VARCHAR2(1)
,        LOT_MERGE_ENABLED               VARCHAR2(1)
,       INVENTORY_CARRY_PENALTY          NUMBER
,       OPERATION_SLACK_PENALTY          NUMBER
,       FINANCING_ALLOWED_FLAG           VARCHAR2(1)
,        EAM_ITEM_TYPE                  NUMBER
,        EAM_ACTIVITY_TYPE_CODE         VARCHAR2(30)
,        EAM_ACTIVITY_CAUSE_CODE        VARCHAR2(30)
,        EAM_ACT_NOTIFICATION_FLAG      VARCHAR2(1)
,        EAM_ACT_SHUTDOWN_STATUS        VARCHAR2(30)
,        DUAL_UOM_CONTROL               NUMBER
,        SECONDARY_UOM_CODE             VARCHAR2(3)
,        DUAL_UOM_DEVIATION_HIGH        NUMBER
,        DUAL_UOM_DEVIATION_LOW         NUMBER
-- Derived attributes
--,  SERVICE_ITEM_FLAG               VARCHAR2(1)
--,  VENDOR_WARRANTY_FLAG            VARCHAR2(1)
--,  USAGE_ITEM_FLAG                 VARCHAR2(1)
,        CONTRACT_ITEM_TYPE_CODE        VARCHAR2(30)
,        SUBSCRIPTION_DEPEND_FLAG       VARCHAR2(1)
,  SERV_REQ_ENABLED_CODE           VARCHAR2(30)
,  SERV_BILLING_ENABLED_FLAG       VARCHAR2(1)
,  SERV_IMPORTANCE_LEVEL           NUMBER
,  PLANNED_INV_POINT_FLAG          VARCHAR2(1)
,  LOT_TRANSLATE_ENABLED           VARCHAR2(1)
,  DEFAULT_SO_SOURCE_TYPE          VARCHAR2(30)
,  CREATE_SUPPLY_FLAG              VARCHAR2(1)
,  SUBSTITUTION_WINDOW_CODE        NUMBER
,  SUBSTITUTION_WINDOW_DAYS        NUMBER
,  IB_ITEM_INSTANCE_CLASS          VARCHAR2(30)
,  CONFIG_MODEL_TYPE               VARCHAR2(30)
--Added for 11.5.9 Enh
,  LOT_SUBSTITUTION_ENABLED        VARCHAR2(1)
,  MINIMUM_LICENSE_QUANTITY        NUMBER
,  EAM_ACTIVITY_SOURCE_CODE        VARCHAR2(30)
--Added for 11.5.10 Enh
,  TRACKING_QUANTITY_IND           VARCHAR2(30)
,  ONT_PRICING_QTY_SOURCE          VARCHAR2(30)
,  SECONDARY_DEFAULT_IND           VARCHAR2(30)
,  OPTION_SPECIFIC_SOURCED         NUMBER
,  CONFIG_ORGS                     VARCHAR2(30)
,  CONFIG_MATCH                    VARCHAR2(30)
--,       ITEM_NUMBER                     VARCHAR2(2000)
,       SEGMENT1                        VARCHAR2(40)
,       SEGMENT2                        VARCHAR2(40)
,       SEGMENT3                        VARCHAR2(40)
,       SEGMENT4                        VARCHAR2(40)
,       SEGMENT5                        VARCHAR2(40)
,       SEGMENT6                        VARCHAR2(40)
,       SEGMENT7                        VARCHAR2(40)
,       SEGMENT8                        VARCHAR2(40)
,       SEGMENT9                        VARCHAR2(40)
,       SEGMENT10                       VARCHAR2(40)
,       SEGMENT11                       VARCHAR2(40)
,       SEGMENT12                       VARCHAR2(40)
,       SEGMENT13                       VARCHAR2(40)
,       SEGMENT14                       VARCHAR2(40)
,       SEGMENT15                       VARCHAR2(40)
,       SEGMENT16                       VARCHAR2(40)
,       SEGMENT17                       VARCHAR2(40)
,       SEGMENT18                       VARCHAR2(40)
,       SEGMENT19                       VARCHAR2(40)
,       SEGMENT20                       VARCHAR2(40)
,       SUMMARY_FLAG                    VARCHAR2(1)
,       ENABLED_FLAG                    VARCHAR2(1)
,       START_DATE_ACTIVE               DATE
,       END_DATE_ACTIVE                 DATE
,       ATTRIBUTE_CATEGORY              VARCHAR2(30)
,       ATTRIBUTE1                      VARCHAR2(240)
,       ATTRIBUTE2                      VARCHAR2(240)
,       ATTRIBUTE3                      VARCHAR2(240)
,       ATTRIBUTE4                      VARCHAR2(240)
,       ATTRIBUTE5                      VARCHAR2(240)
,       ATTRIBUTE6                      VARCHAR2(240)
,       ATTRIBUTE7                      VARCHAR2(240)
,       ATTRIBUTE8                      VARCHAR2(240)
,       ATTRIBUTE9                      VARCHAR2(240)
,       ATTRIBUTE10                     VARCHAR2(240)
,       ATTRIBUTE11                     VARCHAR2(240)
,       ATTRIBUTE12                     VARCHAR2(240)
,       ATTRIBUTE13                     VARCHAR2(240)
,       ATTRIBUTE14                     VARCHAR2(240)
,       ATTRIBUTE15                     VARCHAR2(240)
,       GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2(150)
,       GLOBAL_ATTRIBUTE1               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE2               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE3               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE4               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE5               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE6               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE7               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE8               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE9               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE10              VARCHAR2(150)
,       GLOBAL_ATTRIBUTE11               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE12               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE13               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE14               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE15               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE16               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE17               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE18               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE19               VARCHAR2(150)
,       GLOBAL_ATTRIBUTE20              VARCHAR2(150)
,       CREATION_DATE                   DATE
,       CREATED_BY                      NUMBER
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_LOGIN               NUMBER
,       REQUEST_ID                      NUMBER
,       PROGRAM_APPLICATION_ID          NUMBER
,       PROGRAM_ID                      NUMBER
,       PROGRAM_UPDATE_DATE             DATE
,       LIFECYCLE_ID                    NUMBER
,       CURRENT_PHASE_ID                NUMBER
,       VMI_MINIMUM_UNITS         NUMBER
,       VMI_MINIMUM_DAYS          NUMBER
,       VMI_MAXIMUM_UNITS         NUMBER
,       VMI_MAXIMUM_DAYS          NUMBER
,       VMI_FIXED_ORDER_QUANTITY  NUMBER
,       SO_AUTHORIZATION_FLAG     NUMBER
,       CONSIGNED_FLAG            NUMBER
,       ASN_AUTOEXPIRE_FLAG       NUMBER
,       VMI_FORECAST_TYPE         NUMBER
,       FORECAST_HORIZON          NUMBER
,       EXCLUDE_FROM_BUDGET_FLAG  NUMBER
,       DAYS_TGT_INV_SUPPLY       NUMBER
,       DAYS_TGT_INV_WINDOW       NUMBER
,       DAYS_MAX_INV_SUPPLY       NUMBER
,       DAYS_MAX_INV_WINDOW       NUMBER
,       DRP_PLANNED_FLAG          NUMBER
,       CRITICAL_COMPONENT_FLAG   NUMBER
,       CONTINOUS_TRANSFER        NUMBER
,       CONVERGENCE               NUMBER
,       DIVERGENCE                 NUMBER
/* Start Bug 3713912 */
, LOT_DIVISIBLE_FLAG            VARCHAR2(1) ,
  GRADE_CONTROL_FLAG            VARCHAR2(1) ,
  DEFAULT_GRADE                 VARCHAR2(150),
  CHILD_LOT_FLAG                VARCHAR2(1) ,
  PARENT_CHILD_GENERATION_FLAG  VARCHAR2(1) ,
  CHILD_LOT_PREFIX              VARCHAR2(30),
  CHILD_LOT_STARTING_NUMBER     NUMBER      ,
  CHILD_LOT_VALIDATION_FLAG     VARCHAR2(1) ,
  COPY_LOT_ATTRIBUTE_FLAG       VARCHAR2(1),
  RECIPE_ENABLED_FLAG           VARCHAR2(1) ,
  PROCESS_QUALITY_ENABLED_FLAG  VARCHAR2(1) ,
  PROCESS_EXECUTION_ENABLED_FLAG VARCHAR2(1) ,
  PROCESS_COSTING_ENABLED_FLAG  VARCHAR2(1) ,
  PROCESS_SUPPLY_SUBINVENTORY   VARCHAR2(10)    ,
  PROCESS_SUPPLY_LOCATOR_ID     NUMBER          ,
  PROCESS_YIELD_SUBINVENTORY    VARCHAR2(10)    ,
  PROCESS_YIELD_LOCATOR_ID      NUMBER  ,
  HAZARDOUS_MATERIAL_FLAG       VARCHAR2(1),
  CAS_NUMBER                    VARCHAR2(30)  ,
  RETEST_INTERVAL               NUMBER      ,
  EXPIRATION_ACTION_INTERVAL    NUMBER      ,
  EXPIRATION_ACTION_CODE        VARCHAR2(32) ,
  MATURITY_DAYS                 NUMBER   ,
  HOLD_DAYS                     NUMBER ,
  ATTRIBUTE16                   VARCHAR2(240),
  ATTRIBUTE17                   VARCHAR2(240),
  ATTRIBUTE18                   VARCHAR2(240),
  ATTRIBUTE19                   VARCHAR2(240),
  ATTRIBUTE20                   VARCHAR2(240),
  ATTRIBUTE21                   VARCHAR2(240),
  ATTRIBUTE22                   VARCHAR2(240),
  ATTRIBUTE23                   VARCHAR2(240),
  ATTRIBUTE24                   VARCHAR2(240),
  ATTRIBUTE25                   VARCHAR2(240),
  ATTRIBUTE26                   VARCHAR2(240),
  ATTRIBUTE27                   VARCHAR2(240),
  ATTRIBUTE28                   VARCHAR2(240),
  ATTRIBUTE29                   VARCHAR2(240),
  ATTRIBUTE30                   VARCHAR2(240)
/* End Bug 3713912 */
--Added for R12 ENH.
,       CHARGE_PERIODICITY_CODE VARCHAR2(3)
,       REPAIR_LEADTIME         NUMBER
,       REPAIR_YIELD            NUMBER
,       PREPOSITION_POINT       VARCHAR2(1)
,       REPAIR_PROGRAM          NUMBER
,       SUBCONTRACTING_COMPONENT NUMBER
,       OUTSOURCED_ASSEMBLY     NUMBER
-- Fix for Bug#6644711
, DEFAULT_MATERIAL_STATUS_ID           NUMBER
-- Serial_Tagging Enh -- bug 9913552
, SERIAL_TAGGING_FLAG           VARCHAR2(1)
);

TYPE Item_TL_rec_type IS RECORD
(
        INVENTORY_ITEM_ID               NUMBER
,       ORGANIZATION_ID                 NUMBER
,       LANGUAGE                        VARCHAR2(4)
,       SOURCE_LANG                     VARCHAR2(4)
,       DESCRIPTION                     VARCHAR2(240)
,       LONG_DESCRIPTION                VARCHAR2(4000)
,       CREATION_DATE                   DATE
,       CREATED_BY                      NUMBER
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_LOGIN               NUMBER
);

TYPE Item_Attribute_rec_type IS RECORD
(
        Attribute_Code          VARCHAR2(50)
,       ATTRIBUTE_NAME          VARCHAR2(50)
,       USER_ATTRIBUTE_NAME_GUI VARCHAR2(30)
,       ATTRIBUTE_GROUP_ID_GUI  NUMBER
,       SEQUENCE_GUI            NUMBER
,       DATA_TYPE               VARCHAR2(8)
,       VALIDATION_CODE         NUMBER
,       MANDATORY_FLAG          VARCHAR2(1)
,       CONTROL_LEVEL           NUMBER
,       LEVEL_UPDATEABLE_FLAG   VARCHAR2(1)
,       STATUS_CONTROL_CODE     NUMBER
,       LAST_UPDATE_DATE        DATE
,       LAST_UPDATED_BY         NUMBER
,       CREATION_DATE           DATE
,       CREATED_BY              NUMBER
,       LAST_UPDATE_LOGIN       NUMBER
);

TYPE Item_Attribute_tbl_type IS TABLE OF Item_Attribute_rec_type
                                INDEX BY BINARY_INTEGER;


/*----------------------------------------------------------------------------*/
/*------------------ Variables representing missing values -------------------*/
/*----------------------------------------------------------------------------*/

-- Item_rec_type elements default to NULL.
-- g_miss_Item_rec need not be used anymore.
--
--g_miss_Item_rec         Item_rec_type;

g_miss_Item_Attr_rec    Item_Attribute_rec_type;
g_miss_Item_Attr_tbl    Item_Attribute_tbl_type;


-- =============================================================================
--                        Global variables and constants
-- =============================================================================

g_TRUE          CONSTANT  VARCHAR2(1)  :=  FND_API.g_TRUE;
g_FALSE         CONSTANT  VARCHAR2(1)  :=  FND_API.g_FALSE;

-- Item key flexfield structure
--g_Item_KFF_Struct_Number    CONSTANT  VARCHAR2(30)  :=  '101';


-- =============================================================================
--                              Global cursor specs
-- =============================================================================

-- Item_B cursor
--
CURSOR Item_csr
(
    p_Item_ID        IN   NUMBER
,   p_Org_ID         IN   NUMBER
,   p_fetch_Master   IN   VARCHAR2   :=  g_TRUE
,   p_fetch_Orgs     IN   VARCHAR2   :=  g_FALSE
)
RETURN Item_rec_type ;


-- Org Item_TL cursor
--
CURSOR Item_TL_csr
(
    p_Item_ID        IN   NUMBER
,   p_Org_ID         IN   NUMBER
,   p_fetch_Master   IN   VARCHAR2   :=  g_TRUE
,   p_fetch_Orgs     IN   VARCHAR2   :=  g_FALSE
,   p_restrict_Lang  IN   VARCHAR2   :=  g_FALSE
)
RETURN Item_TL_rec_type ;


-- Item Attributes cursor
--
CURSOR Item_Attribute_csr
RETURN Item_Attribute_rec_type ;


-- =============================================================================
--                                Procedure specs
-- =============================================================================

/*----------------------------- Update_Item_Row ------------------------------*/

PROCEDURE Update_Item_Row
(
    p_Item_rec          IN   Item_rec_type
,   p_update_Item_TL    IN   BOOLEAN
,   p_Lang_Flag         IN   VARCHAR2
,   x_return_status     OUT  NOCOPY VARCHAR2
);


/*---------------------------- Update_Item_TL_Row ----------------------------*/

-- Currently not used
/*
PROCEDURE Update_Item_TL_Row
(
    p_Item_TL_rec       IN   Item_TL_rec_type
,   x_return_status     OUT  VARCHAR2
);
*/

-- -------------------- To_Boolchar ---------------------

-- Currently not used
/*
FUNCTION  To_Boolchar
(
   p_bool        IN   BOOLEAN
)
RETURN  VARCHAR2;
*/


END INV_ITEM_API;

/
