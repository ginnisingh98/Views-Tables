--------------------------------------------------------
--  DDL for Package EGO_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPITMS.pls 120.21.12010000.8 2013/07/03 07:57:03 evwang ship $ */
/*#
 * This package provides functionality for maintaining items, item
 * revisions, etc.
 *
 * <B>Constants:</B> All constants that are unqualified belong to
 * the package EGO_ITEM_PUB.
 *
 * <B>Standard parameters:</B> Several standard parameters are
 * used throughout the APIs below:
 * <ul>
 * <li>p_api_version: A decimal number indicating major and minor
 * revisions to the API (where major revisions change the portion
 * of the number before the decimal and minor revisions change the
 * portion of the number after the decimal).  Pass 1.0 unless
 * otherwise indicated in the API parameter list.</li>
 * <li>p_init_msg_list: A one-character flag indicating whether
 * to initialize the FND_MSG_PUB package's message stack at the
 * beginning of API processing (which removes any messages that
 * may exist on the stack from prior processing in the same session).
 * Valid values are FND_API.G_TRUE and FND_API.G_FALSE.</li>
 * <li>p_commit: A one-character flag indicating whether to commit
 * work at the end of API processing.  Valid values are
 * FND_API.G_TRUE and FND_API.G_FALSE.</li>
 * <li>x_return_status: A one-character code indicating whether
 * any errors occurred during processing (in which case error
 * messages will be present on the FND_MSG_PUB package's message
 * stack).  Valid values are FND_API.G_RET_STS_SUCCESS,
 * FND_API.G_RET_STS_ERROR, and FND_API.G_RET_STS_UNEXP_ERROR.</li>
 * <li>x_msg_count: An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  For information about how to retrieve messages
 * from the message stack, refer to FND_MSG_PUB documentation.</li>
 * <li>x_msg_data: A character string containing message text;
 * will be nonempty only when x_msg_count is exactly 1.  This is
 * a convenience feature so that callers need not interact with
 * the message stack when it contains only one message (as is
 * commonly the case).</li>
 * </ul>
 *
 * <B>G_MISS_* values:</B> In addition, four standard default values
 * (EGO_ITEM_PUB.G_MISS_NUM, EGO_ITEM_PUB.G_MISS_CHAR,
 * EGO_ITEM_PUB.G_MISS_DATE, and EGO_ITEM_PUB.G_MISS_Role_Grant_Tbl)
 * are used throughout the APIs below.  These default values are used
 * to differentiate between a value not passed at all (represented
 * by the G_MISS_* default value) and a value explicitly passed
 * as NULL.  This convention avoids unintentional nullification
 * of values during update processing (because G_MISS_* values
 * are never applied to the database; only explicit NULL values are).
 *
 * <B>Copy/Template behavior:</B> In several of the APIs, it is
 * possible to specify both a template and an item to copy; in such
 * cases, copied item attributes supersede template item attributes.
 *
 * @rep:product EGO
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Catalog Item Maintenance
 * @rep:category BUSINESS_ENTITY EGO_ITEM
 * @rep:businessevent oracle.apps.ego.item.postAttributeChange
 */

   G_FILE_NAME               CONSTANT  VARCHAR2(12) :=  'EGOPITMS.pls';
   G_BO_Identifier           CONSTANT  VARCHAR2(30) :=  'ITM';

   G_RET_STS_SUCCESS         CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
   G_RET_STS_ERROR           CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
   G_RET_STS_UNEXP_ERROR     CONSTANT  VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'
   G_RET_STS_WARNING         CONSTANT  VARCHAR2(1)  := 'W';

   G_MISS_NUM                CONSTANT  NUMBER       :=  9.99E125;
   G_MISS_CHAR               CONSTANT  VARCHAR2(1)  :=  CHR(0);
   G_MISS_DATE               CONSTANT  DATE         :=  TO_DATE('1','j');
   G_FALSE                   CONSTANT  VARCHAR2(1)  :=  FND_API.G_FALSE; -- 'F'
   G_TRUE                    CONSTANT  VARCHAR2(1)  :=  FND_API.G_TRUE;  -- 'T'

   G_TTYPE_CREATE            CONSTANT  VARCHAR2(20) := 'CREATE';
   G_TTYPE_DELETE            CONSTANT  VARCHAR2(20) := 'DELETE';
   G_TTYPE_UPDATE            CONSTANT  VARCHAR2(20) := 'UPDATE';
   G_TTYPE_SYNC              CONSTANT  VARCHAR2(20) := 'SYNC';
   G_TTYPE_PROMOTE           CONSTANT  VARCHAR2(20) := 'PROMOTE';
   G_TTYPE_DEMOTE            CONSTANT  VARCHAR2(20) := 'DEMOTE';
   G_TTYPE_CHANGE_PHASE      CONSTANT  VARCHAR2(20) := 'CHANGE_PHASE';  /* P4TP immutability enhancement */
   G_TTYPE_CHANGE_STATUS     CONSTANT  VARCHAR2(20) := 'CHANGE_STATUS';

   G_INTF_NULL_CHAR          CONSTANT  VARCHAR2(1)  := '!';
-- 5346752 writing the complete number
--   G_INTF_NULL_NUM           CONSTANT  NUMBER       := 9.99E125;
   G_INTF_NULL_NUM           CONSTANT  NUMBER       := 999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
   G_INTF_NULL_DATE          CONSTANT  DATE         := TO_DATE('1','j');

   G_INTF_DELETE_ALL         CONSTANT  NUMBER       := 1;
   G_INTF_DELETE_NONE        CONSTANT  NUMBER       := 2;
   G_INTF_DELETE_ERROR       CONSTANT  NUMBER       := 3;
   G_INTF_DELETE_SUCCESS     CONSTANT  NUMBER       := 4;

   G_INSTANCE_TYPE_SET       CONSTANT  VARCHAR2(10) := 'SET';
   G_INSTANCE_TYPE_INSTANCE  CONSTANT  VARCHAR2(10) := 'INSTANCE';

   G_USER_PARTY_TYPE         CONSTANT  VARCHAR2(10) := 'USER';
   G_GROUP_PARTY_TYPE        CONSTANT  VARCHAR2(10) := 'GROUP';
   G_COMPANY_PARTY_TYPE      CONSTANT  VARCHAR2(10) := 'COMPANY';
   G_ALL_USERS_PARTY_TYPE    CONSTANT  VARCHAR2(10) := 'GLOBAL';

   G_CONC_RET_STS_SUCCESS    CONSTANT  VARCHAR2(1)  := '0';
   G_CONC_RET_STS_WARNING    CONSTANT  VARCHAR2(1)  := '1';
   G_CONC_RET_STS_ERROR      CONSTANT  VARCHAR2(1)  := '2';

   --  Item record table and table (public types).
   TYPE Item_Rec_Type IS RECORD(
      Transaction_Type                  VARCHAR2(30)
     ,Return_Status                     VARCHAR2(1)    :=  G_MISS_CHAR
     ,Language_Code                     VARCHAR2(4)    :=  G_MISS_CHAR
   -- Copy item from
     ,Copy_Inventory_Item_Id            NUMBER         :=  G_MISS_NUM
     ,Template_Id                       NUMBER         :=  NULL
     ,Template_Name                     VARCHAR2(30)   :=  NULL
   -- Item identifier
     ,Inventory_Item_Id                 NUMBER         :=  G_MISS_NUM
     ,Item_Number                       VARCHAR2(2000) :=  G_MISS_CHAR
     ,Segment1                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment2                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment3                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment4                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment5                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment6                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment7                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment8                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment9                          VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment10                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment11                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment12                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment13                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment14                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment15                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment16                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment17                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment18                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment19                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Segment20                         VARCHAR2(40)   :=  G_MISS_CHAR
     ,Summary_Flag                      VARCHAR2(1)    :=  G_MISS_CHAR
     ,Enabled_Flag                      VARCHAR2(1)    :=  G_MISS_CHAR
     ,Start_Date_Active                 DATE           :=  G_MISS_DATE
     ,End_Date_Active                   DATE           :=  G_MISS_DATE
   -- Organization
     ,Organization_Id                   NUMBER         :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)    :=  G_MISS_CHAR
   -- Item catalog group (user item type)
     ,Item_Catalog_Group_Id             NUMBER         :=  G_MISS_NUM
     ,Catalog_Status_Flag               VARCHAR2(1)    :=  G_MISS_CHAR
   -- Lifecycle
     ,Lifecycle_Id                      NUMBER         :=  G_MISS_NUM
     ,Current_Phase_Id                  NUMBER         :=  G_MISS_NUM
   -- Main attributes
     ,Description                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Long_Description                  VARCHAR2(4000) :=  G_MISS_CHAR
     ,Primary_Uom_Code                  VARCHAR2(3)    :=  G_MISS_CHAR
     ,ALLOWED_UNITS_LOOKUP_CODE         NUMBER         :=  G_MISS_NUM
     ,INVENTORY_ITEM_STATUS_CODE        VARCHAR2(10)   :=  G_MISS_CHAR
     ,DUAL_UOM_CONTROL                  NUMBER         :=  G_MISS_NUM
     ,SECONDARY_UOM_CODE                VARCHAR2(3)    :=  G_MISS_CHAR
     ,DUAL_UOM_DEVIATION_HIGH           NUMBER         :=  G_MISS_NUM
     ,DUAL_UOM_DEVIATION_LOW            NUMBER         :=  G_MISS_NUM
     ,ITEM_TYPE                         VARCHAR2(30)   :=  G_MISS_CHAR
   -- Inventory
     ,INVENTORY_ITEM_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,STOCK_ENABLED_FLAG                VARCHAR2(1)    :=  G_MISS_CHAR
     ,MTL_TRANSACTIONS_ENABLED_FLAG     VARCHAR2(1)    :=  G_MISS_CHAR
     ,REVISION_QTY_CONTROL_CODE         NUMBER         :=  G_MISS_NUM
     ,LOT_CONTROL_CODE                  NUMBER         :=  G_MISS_NUM
     ,AUTO_LOT_ALPHA_PREFIX             VARCHAR2(30)   :=  G_MISS_CHAR
     ,START_AUTO_LOT_NUMBER             VARCHAR2(30)   :=  G_MISS_CHAR
     ,SERIAL_NUMBER_CONTROL_CODE        NUMBER         :=  G_MISS_NUM
     ,AUTO_SERIAL_ALPHA_PREFIX          VARCHAR2(30)   :=  G_MISS_CHAR
     ,START_AUTO_SERIAL_NUMBER          VARCHAR2(30)   :=  G_MISS_CHAR
     ,SHELF_LIFE_CODE                   NUMBER         :=  G_MISS_NUM
     ,SHELF_LIFE_DAYS                   NUMBER         :=  G_MISS_NUM
     ,RESTRICT_SUBINVENTORIES_CODE      NUMBER         :=  G_MISS_NUM
     ,LOCATION_CONTROL_CODE             NUMBER         :=  G_MISS_NUM
     ,RESTRICT_LOCATORS_CODE            NUMBER         :=  G_MISS_NUM
     ,RESERVABLE_TYPE                   NUMBER         :=  G_MISS_NUM
     ,CYCLE_COUNT_ENABLED_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,NEGATIVE_MEASUREMENT_ERROR        NUMBER         :=  G_MISS_NUM
     ,POSITIVE_MEASUREMENT_ERROR        NUMBER         :=  G_MISS_NUM
     ,CHECK_SHORTAGES_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,LOT_STATUS_ENABLED                VARCHAR2(1)    :=  G_MISS_CHAR
     ,DEFAULT_LOT_STATUS_ID             NUMBER         :=  G_MISS_NUM
     ,SERIAL_STATUS_ENABLED             VARCHAR2(1)    :=  G_MISS_CHAR
     ,DEFAULT_SERIAL_STATUS_ID          NUMBER         :=  G_MISS_NUM
     ,LOT_SPLIT_ENABLED                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,LOT_MERGE_ENABLED                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,LOT_TRANSLATE_ENABLED             VARCHAR2(1)    :=  G_MISS_CHAR
     ,LOT_SUBSTITUTION_ENABLED          VARCHAR2(1)    :=  G_MISS_CHAR
     ,BULK_PICKED_FLAG                  VARCHAR2(1)    :=  G_MISS_CHAR
   -- Bills of Material
     ,BOM_ITEM_TYPE                     NUMBER         :=  G_MISS_NUM
     ,BOM_ENABLED_FLAG                  VARCHAR2(1)    :=  G_MISS_CHAR
     ,BASE_ITEM_ID                      NUMBER         :=  G_MISS_NUM
     ,ENG_ITEM_FLAG                     VARCHAR2(1)    :=  G_MISS_CHAR
     ,ENGINEERING_ITEM_ID               NUMBER         :=  G_MISS_NUM
     ,ENGINEERING_ECN_CODE              VARCHAR2(50)   :=  G_MISS_CHAR
     ,ENGINEERING_DATE                  DATE           :=  G_MISS_DATE
     ,EFFECTIVITY_CONTROL               NUMBER         :=  G_MISS_NUM
     ,CONFIG_MODEL_TYPE                 VARCHAR2(30)   :=  G_MISS_CHAR
     ,Product_Family_Item_Id            NUMBER         :=  G_MISS_NUM
     ,AUTO_CREATED_CONFIG_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR--3911562
   -- Costing
     ,COSTING_ENABLED_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,INVENTORY_ASSET_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,COST_OF_SALES_ACCOUNT             NUMBER         :=  G_MISS_NUM
     ,DEFAULT_INCLUDE_IN_ROLLUP_FLAG    VARCHAR2(1)    :=  G_MISS_CHAR
     ,STD_LOT_SIZE                      NUMBER         :=  G_MISS_NUM
   -- Enterprise Asset Management
     ,EAM_ITEM_TYPE                     NUMBER         :=  G_MISS_NUM
     ,EAM_ACTIVITY_TYPE_CODE            VARCHAR2(30)   :=  G_MISS_CHAR
     ,EAM_ACTIVITY_CAUSE_CODE           VARCHAR2(30)   :=  G_MISS_CHAR
     ,EAM_ACTIVITY_SOURCE_CODE          VARCHAR2(30)   :=  G_MISS_CHAR
     ,EAM_ACT_SHUTDOWN_STATUS           VARCHAR2(30)   :=  G_MISS_CHAR
     ,EAM_ACT_NOTIFICATION_FLAG         VARCHAR2(1)    :=  G_MISS_CHAR
   -- Purchasing
     ,PURCHASING_ITEM_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,PURCHASING_ENABLED_FLAG           VARCHAR2(1)    :=  G_MISS_CHAR
     ,BUYER_ID                          NUMBER         :=  G_MISS_NUM
     ,MUST_USE_APPROVED_VENDOR_FLAG     VARCHAR2(1)    :=  G_MISS_CHAR
     ,PURCHASING_TAX_CODE               VARCHAR2(50)   :=  G_MISS_CHAR
     ,TAXABLE_FLAG                      VARCHAR2(1)    :=  G_MISS_CHAR
     ,RECEIVE_CLOSE_TOLERANCE           NUMBER         :=  G_MISS_NUM
     ,ALLOW_ITEM_DESC_UPDATE_FLAG       VARCHAR2(1)    :=  G_MISS_CHAR
     ,INSPECTION_REQUIRED_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,RECEIPT_REQUIRED_FLAG             VARCHAR2(1)    :=  G_MISS_CHAR
     ,MARKET_PRICE                      NUMBER         :=  G_MISS_NUM
     ,UN_NUMBER_ID                      NUMBER         :=  G_MISS_NUM
     ,HAZARD_CLASS_ID                   NUMBER         :=  G_MISS_NUM
     ,RFQ_REQUIRED_FLAG                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,LIST_PRICE_PER_UNIT               NUMBER         :=  G_MISS_NUM
     ,PRICE_TOLERANCE_PERCENT           NUMBER         :=  G_MISS_NUM
     ,ASSET_CATEGORY_ID                 NUMBER         :=  G_MISS_NUM
     ,ROUNDING_FACTOR                   NUMBER         :=  G_MISS_NUM
     ,UNIT_OF_ISSUE                     VARCHAR2(25)   :=  G_MISS_CHAR
     ,OUTSIDE_OPERATION_FLAG            VARCHAR2(1)    :=  G_MISS_CHAR
     ,OUTSIDE_OPERATION_UOM_TYPE        VARCHAR2(25)   :=  G_MISS_CHAR
     ,INVOICE_CLOSE_TOLERANCE           NUMBER         :=  G_MISS_NUM
     ,ENCUMBRANCE_ACCOUNT               NUMBER         :=  G_MISS_NUM
     ,EXPENSE_ACCOUNT                   NUMBER         :=  G_MISS_NUM
     ,QTY_RCV_EXCEPTION_CODE            VARCHAR2(25)   :=  G_MISS_CHAR
     ,RECEIVING_ROUTING_ID              NUMBER         :=  G_MISS_NUM
     ,QTY_RCV_TOLERANCE                 NUMBER         :=  G_MISS_NUM
     ,ENFORCE_SHIP_TO_LOCATION_CODE     VARCHAR2(25)   :=  G_MISS_CHAR
     ,ALLOW_SUBSTITUTE_RECEIPTS_FLAG    VARCHAR2(1)    :=  G_MISS_CHAR
     ,ALLOW_UNORDERED_RECEIPTS_FLAG     VARCHAR2(1)    :=  G_MISS_CHAR
     ,ALLOW_EXPRESS_DELIVERY_FLAG       VARCHAR2(1)    :=  G_MISS_CHAR
     ,DAYS_EARLY_RECEIPT_ALLOWED        NUMBER         :=  G_MISS_NUM
     ,DAYS_LATE_RECEIPT_ALLOWED         NUMBER         :=  G_MISS_NUM
     ,RECEIPT_DAYS_EXCEPTION_CODE       VARCHAR2(25)   :=  G_MISS_CHAR
   -- Physical
     ,WEIGHT_UOM_CODE                   VARCHAR2(3)    :=  G_MISS_CHAR
     ,UNIT_WEIGHT                       NUMBER         :=  G_MISS_NUM
     ,VOLUME_UOM_CODE                   VARCHAR2(3)    :=  G_MISS_CHAR
     ,UNIT_VOLUME                       NUMBER         :=  G_MISS_NUM
     ,CONTAINER_ITEM_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,VEHICLE_ITEM_FLAG                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,MAXIMUM_LOAD_WEIGHT               NUMBER         :=  G_MISS_NUM
     ,MINIMUM_FILL_PERCENT              NUMBER         :=  G_MISS_NUM
     ,INTERNAL_VOLUME                   NUMBER         :=  G_MISS_NUM
     ,CONTAINER_TYPE_CODE               VARCHAR2(30)   :=  G_MISS_CHAR
     ,COLLATERAL_FLAG                   VARCHAR2(1)    :=  G_MISS_CHAR
     ,EVENT_FLAG                        VARCHAR2(1)    :=  G_MISS_CHAR
     ,EQUIPMENT_TYPE                    NUMBER         :=  G_MISS_NUM
     ,ELECTRONIC_FLAG                   VARCHAR2(1)    :=  G_MISS_CHAR
     ,DOWNLOADABLE_FLAG                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,INDIVISIBLE_FLAG                  VARCHAR2(1)    :=  G_MISS_CHAR
     ,DIMENSION_UOM_CODE                VARCHAR2(3)    :=  G_MISS_CHAR
     ,UNIT_LENGTH                       NUMBER         :=  G_MISS_NUM
     ,UNIT_WIDTH                        NUMBER         :=  G_MISS_NUM
     ,UNIT_HEIGHT                       NUMBER         :=  G_MISS_NUM
   --Planing
     ,INVENTORY_PLANNING_CODE           NUMBER         :=  G_MISS_NUM
     ,PLANNER_CODE                      VARCHAR2(10)   :=  G_MISS_CHAR
     ,PLANNING_MAKE_BUY_CODE            NUMBER         :=  G_MISS_NUM
     ,MIN_MINMAX_QUANTITY               NUMBER         :=  G_MISS_NUM
     ,MAX_MINMAX_QUANTITY               NUMBER         :=  G_MISS_NUM
     ,SAFETY_STOCK_BUCKET_DAYS          NUMBER         :=  G_MISS_NUM
     ,CARRYING_COST                     NUMBER         :=  G_MISS_NUM
     ,ORDER_COST                        NUMBER         :=  G_MISS_NUM
     ,MRP_SAFETY_STOCK_PERCENT          NUMBER         :=  G_MISS_NUM
     ,MRP_SAFETY_STOCK_CODE             NUMBER         :=  G_MISS_NUM
     ,FIXED_ORDER_QUANTITY              NUMBER         :=  G_MISS_NUM
     ,FIXED_DAYS_SUPPLY                 NUMBER         :=  G_MISS_NUM
     ,MINIMUM_ORDER_QUANTITY            NUMBER         :=  G_MISS_NUM
     ,MAXIMUM_ORDER_QUANTITY            NUMBER         :=  G_MISS_NUM
     ,FIXED_LOT_MULTIPLIER              NUMBER         :=  G_MISS_NUM
     ,SOURCE_TYPE                       NUMBER         :=  G_MISS_NUM
     ,SOURCE_ORGANIZATION_ID            NUMBER         :=  G_MISS_NUM
     ,SOURCE_SUBINVENTORY               VARCHAR2(10)   :=  G_MISS_CHAR
     ,MRP_PLANNING_CODE                 NUMBER         :=  G_MISS_NUM
     ,ATO_FORECAST_CONTROL              NUMBER         :=  G_MISS_NUM
     ,PLANNING_EXCEPTION_SET            VARCHAR2(10)   :=  G_MISS_CHAR
     ,SHRINKAGE_RATE                    NUMBER         :=  G_MISS_NUM
     ,END_ASSEMBLY_PEGGING_FLAG         VARCHAR2(1)    :=  G_MISS_CHAR
     ,ROUNDING_CONTROL_TYPE             NUMBER         :=  G_MISS_NUM
     ,PLANNED_INV_POINT_FLAG            VARCHAR2(1)    :=  G_MISS_CHAR
     ,CREATE_SUPPLY_FLAG                VARCHAR2(1)    :=  G_MISS_CHAR
     ,ACCEPTABLE_EARLY_DAYS             NUMBER         :=  G_MISS_NUM
     ,MRP_CALCULATE_ATP_FLAG            VARCHAR2(1)    :=  G_MISS_CHAR
     ,AUTO_REDUCE_MPS                   NUMBER         :=  G_MISS_NUM
     ,REPETITIVE_PLANNING_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,OVERRUN_PERCENTAGE                NUMBER         :=  G_MISS_NUM
     ,ACCEPTABLE_RATE_DECREASE          NUMBER         :=  G_MISS_NUM
     ,ACCEPTABLE_RATE_INCREASE          NUMBER         :=  G_MISS_NUM
     ,PLANNING_TIME_FENCE_CODE          NUMBER         :=  G_MISS_NUM
     ,PLANNING_TIME_FENCE_DAYS          NUMBER         :=  G_MISS_NUM
     ,DEMAND_TIME_FENCE_CODE            NUMBER         :=  G_MISS_NUM
     ,DEMAND_TIME_FENCE_DAYS            NUMBER         :=  G_MISS_NUM
     ,RELEASE_TIME_FENCE_CODE           NUMBER         :=  G_MISS_NUM
     ,RELEASE_TIME_FENCE_DAYS           NUMBER         :=  G_MISS_NUM
     ,SUBSTITUTION_WINDOW_CODE          NUMBER         :=  G_MISS_NUM
     ,SUBSTITUTION_WINDOW_DAYS          NUMBER         :=  G_MISS_NUM
   -- Lead Times
     ,PREPROCESSING_LEAD_TIME           NUMBER         :=  G_MISS_NUM
     ,FULL_LEAD_TIME                    NUMBER         :=  G_MISS_NUM
     ,POSTPROCESSING_LEAD_TIME          NUMBER         :=  G_MISS_NUM
     ,FIXED_LEAD_TIME                   NUMBER         :=  G_MISS_NUM
     ,VARIABLE_LEAD_TIME                NUMBER         :=  G_MISS_NUM
     ,CUM_MANUFACTURING_LEAD_TIME       NUMBER         :=  G_MISS_NUM
     ,CUMULATIVE_TOTAL_LEAD_TIME        NUMBER         :=  G_MISS_NUM
     ,LEAD_TIME_LOT_SIZE                NUMBER         :=  G_MISS_NUM
   -- WIP
     ,BUILD_IN_WIP_FLAG                 VARCHAR2(1)    :=  G_MISS_CHAR
     ,WIP_SUPPLY_TYPE                   NUMBER         :=  G_MISS_NUM
     ,WIP_SUPPLY_SUBINVENTORY           VARCHAR2(10)   :=  G_MISS_CHAR
     ,WIP_SUPPLY_LOCATOR_ID             NUMBER         :=  G_MISS_NUM
     ,OVERCOMPLETION_TOLERANCE_TYPE     NUMBER         :=  G_MISS_NUM
     ,OVERCOMPLETION_TOLERANCE_VALUE    NUMBER         :=  G_MISS_NUM
     ,INVENTORY_CARRY_PENALTY           NUMBER         :=  G_MISS_NUM
     ,OPERATION_SLACK_PENALTY           NUMBER         :=  G_MISS_NUM
   -- Order Management
     ,CUSTOMER_ORDER_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,CUSTOMER_ORDER_ENABLED_FLAG       VARCHAR2(1)    :=  G_MISS_CHAR
     ,INTERNAL_ORDER_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,INTERNAL_ORDER_ENABLED_FLAG       VARCHAR2(1)    :=  G_MISS_CHAR
     ,SHIPPABLE_ITEM_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,SO_TRANSACTIONS_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,PICKING_RULE_ID                   NUMBER         :=  G_MISS_NUM
     ,PICK_COMPONENTS_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,REPLENISH_TO_ORDER_FLAG           VARCHAR2(1)    :=  G_MISS_CHAR
     ,ATP_FLAG                          VARCHAR2(1)    :=  G_MISS_CHAR
     ,ATP_COMPONENTS_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,ATP_RULE_ID                       NUMBER         :=  G_MISS_NUM
     ,SHIP_MODEL_COMPLETE_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,DEFAULT_SHIPPING_ORG              NUMBER         :=  G_MISS_NUM
     ,DEFAULT_SO_SOURCE_TYPE            VARCHAR2(30)   :=  G_MISS_CHAR
     ,RETURNABLE_FLAG                   VARCHAR2(1)    :=  G_MISS_CHAR
     ,RETURN_INSPECTION_REQUIREMENT     NUMBER         :=  G_MISS_NUM
     ,OVER_SHIPMENT_TOLERANCE           NUMBER         :=  G_MISS_NUM
     ,UNDER_SHIPMENT_TOLERANCE          NUMBER         :=  G_MISS_NUM
     ,OVER_RETURN_TOLERANCE             NUMBER         :=  G_MISS_NUM
     ,UNDER_RETURN_TOLERANCE            NUMBER         :=  G_MISS_NUM
     ,FINANCING_ALLOWED_FLAG            VARCHAR2(1)    :=  G_MISS_CHAR
     ,VOL_DISCOUNT_EXEMPT_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,COUPON_EXEMPT_FLAG                VARCHAR2(1)    :=  G_MISS_CHAR
     ,INVOICEABLE_ITEM_FLAG             VARCHAR2(1)    :=  G_MISS_CHAR
     ,INVOICE_ENABLED_FLAG              VARCHAR2(1)    :=  G_MISS_CHAR
     ,ACCOUNTING_RULE_ID                NUMBER         :=  G_MISS_NUM
     ,INVOICING_RULE_ID                 NUMBER         :=  G_MISS_NUM
     ,TAX_CODE                          VARCHAR2(50)   :=  G_MISS_CHAR
     ,SALES_ACCOUNT                     NUMBER         :=  G_MISS_NUM
     ,PAYMENT_TERMS_ID                  NUMBER         :=  G_MISS_NUM
   -- Service
     ,CONTRACT_ITEM_TYPE_CODE           VARCHAR2(30)   :=  G_MISS_CHAR
     ,SERVICE_DURATION_PERIOD_CODE      VARCHAR2(10)   :=  G_MISS_CHAR
     ,SERVICE_DURATION                  NUMBER         :=  G_MISS_NUM
     ,COVERAGE_SCHEDULE_ID              NUMBER         :=  G_MISS_NUM
     ,SUBSCRIPTION_DEPEND_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,SERV_IMPORTANCE_LEVEL             NUMBER         :=  G_MISS_NUM
     ,SERV_REQ_ENABLED_CODE             VARCHAR2(30)   :=  G_MISS_CHAR
     ,COMMS_ACTIVATION_REQD_FLAG        VARCHAR2(1)    :=  G_MISS_CHAR
     ,SERVICEABLE_PRODUCT_FLAG          VARCHAR2(1)    :=  G_MISS_CHAR
     ,MATERIAL_BILLABLE_FLAG            VARCHAR2(30)   :=  G_MISS_CHAR
     ,SERV_BILLING_ENABLED_FLAG         VARCHAR2(1)    :=  G_MISS_CHAR
     ,DEFECT_TRACKING_ON_FLAG           VARCHAR2(1)    :=  G_MISS_CHAR
     ,RECOVERED_PART_DISP_CODE          VARCHAR2(30)   :=  G_MISS_CHAR
     ,COMMS_NL_TRACKABLE_FLAG           VARCHAR2(1)    :=  G_MISS_CHAR
     ,ASSET_CREATION_CODE               VARCHAR2(30)   :=  G_MISS_CHAR
     ,IB_ITEM_INSTANCE_CLASS            VARCHAR2(30)   :=  G_MISS_CHAR
     ,SERVICE_STARTING_DELAY            NUMBER         :=  G_MISS_NUM
   -- Web Option
     ,WEB_STATUS                        VARCHAR2(30)   :=  G_MISS_CHAR
     ,ORDERABLE_ON_WEB_FLAG             VARCHAR2(1)    :=  G_MISS_CHAR
     ,BACK_ORDERABLE_FLAG               VARCHAR2(1)    :=  G_MISS_CHAR
     ,MINIMUM_LICENSE_QUANTITY          NUMBER         :=  G_MISS_NUM
   -- Start:  26 new attributes
     ,TRACKING_QUANTITY_IND             VARCHAR2(30)   :=  G_MISS_CHAR
     ,ONT_PRICING_QTY_SOURCE            VARCHAR2(30)   :=  G_MISS_CHAR
     ,SECONDARY_DEFAULT_IND             VARCHAR2(30)   :=  G_MISS_CHAR
     ,OPTION_SPECIFIC_SOURCED           NUMBER         :=  G_MISS_NUM
     ,VMI_MINIMUM_UNITS                 NUMBER         :=  G_MISS_NUM
     ,VMI_MINIMUM_DAYS                  NUMBER         :=  G_MISS_NUM
     ,VMI_MAXIMUM_UNITS                 NUMBER         :=  G_MISS_NUM
     ,VMI_MAXIMUM_DAYS                  NUMBER         :=  G_MISS_NUM
     ,VMI_FIXED_ORDER_QUANTITY          NUMBER         :=  G_MISS_NUM
     ,SO_AUTHORIZATION_FLAG             NUMBER         :=  G_MISS_NUM
     ,CONSIGNED_FLAG                    NUMBER         :=  G_MISS_NUM
     ,ASN_AUTOEXPIRE_FLAG               NUMBER         :=  G_MISS_NUM
     ,VMI_FORECAST_TYPE                 NUMBER         :=  G_MISS_NUM
     ,FORECAST_HORIZON                  NUMBER         :=  G_MISS_NUM
     ,EXCLUDE_FROM_BUDGET_FLAG          NUMBER         :=  G_MISS_NUM
     ,DAYS_TGT_INV_SUPPLY               NUMBER         :=  G_MISS_NUM
     ,DAYS_TGT_INV_WINDOW               NUMBER         :=  G_MISS_NUM
     ,DAYS_MAX_INV_SUPPLY               NUMBER         :=  G_MISS_NUM
     ,DAYS_MAX_INV_WINDOW               NUMBER         :=  G_MISS_NUM
     ,DRP_PLANNED_FLAG                  NUMBER         :=  G_MISS_NUM
     ,CRITICAL_COMPONENT_FLAG           NUMBER         :=  G_MISS_NUM
     ,CONTINOUS_TRANSFER                NUMBER         :=  G_MISS_NUM
     ,CONVERGENCE                       NUMBER         :=  G_MISS_NUM
     ,DIVERGENCE                        NUMBER         :=  G_MISS_NUM
     ,CONFIG_ORGS                       VARCHAR2(30)   :=  G_MISS_CHAR
     ,CONFIG_MATCH                      VARCHAR2(30)   :=  G_MISS_CHAR
   -- End  : 26 new attributes
   -- Descriptive flex
     ,Attribute_Category                VARCHAR2(30)   :=  G_MISS_CHAR
     ,Attribute1                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute2                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute3                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute4                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute5                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute6                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute7                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute8                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute9                        VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute10                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute11                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute12                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute13                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute14                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute15                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute16                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute17                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute18                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute19                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute20                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute21                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute22                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute23                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute24                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute25                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute26                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute27                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute28                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute29                       VARCHAR2(240)  :=  G_MISS_CHAR
     ,Attribute30                       VARCHAR2(240)  :=  G_MISS_CHAR
   -- Global Descriptive flex
     ,Global_Attribute_Category         VARCHAR2(30)   :=  G_MISS_CHAR
     ,Global_Attribute1                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute2                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute3                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute4                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute5                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute6                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute7                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute8                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute9                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute10                VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute11                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute12                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute13                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute14                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute15                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute16                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute17                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute18                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute19                 VARCHAR2(150)  :=  G_MISS_CHAR
     ,Global_Attribute20                VARCHAR2(150)  :=  G_MISS_CHAR
   -- Who
     ,Object_Version_Number             NUMBER         :=  G_MISS_NUM
     ,Creation_Date                     DATE           :=  G_MISS_DATE
     ,Created_By                        NUMBER         :=  G_MISS_NUM
     ,Last_Update_Date                  DATE           :=  G_MISS_DATE
     ,Last_Updated_By                   NUMBER         :=  G_MISS_NUM
     ,Last_Update_Login                 NUMBER         :=  G_MISS_NUM
     ,process_item_record               NUMBER         :=  G_MISS_NUM
          /* R12 Enhancements */
    ,CAS_NUMBER                     VARCHAR2(30) :=  G_MISS_CHAR
    ,CHILD_LOT_FLAG                 VARCHAR2(1)  :=  G_MISS_CHAR
    ,CHILD_LOT_PREFIX               VARCHAR2(30) :=  G_MISS_CHAR
    ,CHILD_LOT_STARTING_NUMBER      NUMBER       :=  G_MISS_NUM
    ,CHILD_LOT_VALIDATION_FLAG      VARCHAR2(1)  :=  G_MISS_CHAR
    ,COPY_LOT_ATTRIBUTE_FLAG        VARCHAR2(1)  :=  G_MISS_CHAR
    ,DEFAULT_GRADE                  VARCHAR2(150):=  G_MISS_CHAR
    ,EXPIRATION_ACTION_CODE         VARCHAR2(32) :=  G_MISS_CHAR
    ,EXPIRATION_ACTION_INTERVAL     NUMBER       :=  G_MISS_NUM
    ,GRADE_CONTROL_FLAG             VARCHAR2(1)  :=  G_MISS_CHAR
    ,HAZARDOUS_MATERIAL_FLAG        VARCHAR2(1)  :=  G_MISS_CHAR
    ,HOLD_DAYS                      NUMBER       :=  G_MISS_NUM
    ,LOT_DIVISIBLE_FLAG             VARCHAR2(1)  :=  G_MISS_CHAR
    ,MATURITY_DAYS                  NUMBER       :=  G_MISS_NUM
    ,PARENT_CHILD_GENERATION_FLAG   VARCHAR2(1)  :=  G_MISS_CHAR
    ,PROCESS_COSTING_ENABLED_FLAG   VARCHAR2(1)  :=  G_MISS_CHAR
    ,PROCESS_EXECUTION_ENABLED_FLAG VARCHAR2(1)  :=  G_MISS_CHAR
    ,PROCESS_QUALITY_ENABLED_FLAG   VARCHAR2(1)  :=  G_MISS_CHAR
    ,PROCESS_SUPPLY_LOCATOR_ID      NUMBER       :=  G_MISS_NUM
    ,PROCESS_SUPPLY_SUBINVENTORY    VARCHAR2(10) :=  G_MISS_CHAR
    ,PROCESS_YIELD_LOCATOR_ID       NUMBER       :=  G_MISS_NUM
    ,PROCESS_YIELD_SUBINVENTORY     VARCHAR2(10) :=  G_MISS_CHAR
    ,RECIPE_ENABLED_FLAG            VARCHAR2(1)  :=  G_MISS_CHAR
    ,RETEST_INTERVAL                NUMBER       :=  G_MISS_NUM
    ,CHARGE_PERIODICITY_CODE        VARCHAR2(3)  :=  G_MISS_CHAR
    ,REPAIR_LEADTIME                NUMBER       :=  G_MISS_NUM
    ,REPAIR_YIELD                   NUMBER       :=  G_MISS_NUM
    ,PREPOSITION_POINT              VARCHAR2(1)  :=  G_MISS_CHAR
    ,REPAIR_PROGRAM                 NUMBER       :=  G_MISS_NUM
    ,SUBCONTRACTING_COMPONENT       NUMBER       :=  G_MISS_NUM
    ,OUTSOURCED_ASSEMBLY            NUMBER       :=  G_MISS_NUM
    --R12 C Attributes
    ,GDSN_OUTBOUND_ENABLED_FLAG     VARCHAR2(1)  :=  G_MISS_CHAR
    ,TRADE_ITEM_DESCRIPTOR          VARCHAR2(35) :=  G_MISS_CHAR
    ,STYLE_ITEM_FLAG                VARCHAR2(1)  :=  G_MISS_CHAR
    ,STYLE_ITEM_ID                  NUMBER       :=  G_MISS_NUM
    -- Bug 9852661
    ,ATTRIBUTES_ROW_TABLE          EGO_USER_ATTR_ROW_TABLE := EGO_USER_ATTR_ROW_TABLE()
    ,ATTRIBUTES_DATA_TABLE         EGO_USER_ATTR_DATA_TABLE := EGO_USER_ATTR_DATA_TABLE()
    -- Bug 9852661
    );

   TYPE Item_Tbl_Type IS TABLE OF Item_Rec_Type INDEX BY BINARY_INTEGER;

   --  Organization record and table (public types).

   TYPE Org_Rec_Type IS RECORD(
      Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
     ,Organization_Id                   NUMBER          :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)     :=  G_MISS_CHAR);

   TYPE Org_Tbl_Type IS TABLE OF Org_Rec_Type INDEX BY BINARY_INTEGER;

   --  Organization Assignment record and table (public types).

   TYPE Item_Org_Assignment_Rec_Type IS RECORD(
      Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
     ,Inventory_Item_Id                 NUMBER          :=  G_MISS_NUM
     ,Item_Number                       VARCHAR2(2000)  :=  G_MISS_CHAR
     ,Organization_Id                   NUMBER          :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)     :=  G_MISS_CHAR
     ,Primary_Uom_Code                  MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE  :=  G_MISS_CHAR);

   TYPE Item_Org_Assignment_Tbl_Type IS TABLE OF Item_Org_Assignment_Rec_Type INDEX BY BINARY_INTEGER;

   --  Item Revision record and table (public types).

   TYPE Item_Revision_Rec_Type IS RECORD(
      Transaction_Type                  VARCHAR2(30)    :=  G_MISS_CHAR
     ,Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
     ,Language_Code                     VARCHAR2(4)     :=  G_MISS_CHAR
   -- Revision identifier
     ,Inventory_Item_Id                 NUMBER          :=  G_MISS_NUM
     ,Item_Number                       VARCHAR2(2000)  :=  G_MISS_CHAR
     ,Organization_Id                   NUMBER          :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)     :=  G_MISS_CHAR
     ,Revision_Id                       NUMBER          :=  G_MISS_NUM
   -- Attributes
     ,Revision_Code                     VARCHAR2(3)     :=  G_MISS_CHAR
     ,Revision_Label                    VARCHAR2(80)    :=  G_MISS_CHAR
     ,Description                       VARCHAR2(240)   :=  G_MISS_CHAR
     ,Change_Notice                     VARCHAR2(10)    :=  G_MISS_CHAR
     ,Ecn_Initiation_Date               DATE            :=  G_MISS_DATE
     ,Implementation_Date               DATE            :=  G_MISS_DATE
     ,Effectivity_Date                  DATE            :=  G_MISS_DATE
     ,Revised_Item_Sequence_Id          NUMBER          :=  G_MISS_NUM
   -- Lifecycle
     ,Lifecycle_Id                      NUMBER          :=  G_MISS_NUM
     ,Current_Phase_Id                  NUMBER          :=  G_MISS_NUM
   -- 5208102: Supporting template for UDA's at revisions
     ,template_id   MTL_ITEM_TEMPLATES_B.TEMPLATE_ID%TYPE    :=  G_MISS_NUM
     ,template_name MTL_ITEM_TEMPLATES_TL.TEMPLATE_NAME%TYPE :=  G_MISS_CHAR

   -- Descriptive flex
     ,Attribute_Category                VARCHAR2(30)    :=  G_MISS_CHAR
     ,Attribute1                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute2                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute3                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute4                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute5                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute6                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute7                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute8                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute9                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute10                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute11                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute12                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute13                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute14                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute15                       VARCHAR2(150)   :=  G_MISS_CHAR
   -- Who
     ,Object_Version_Number             NUMBER          :=  G_MISS_NUM
     ,Creation_Date                     DATE            :=  G_MISS_DATE
     ,Created_By                        NUMBER          :=  G_MISS_NUM
     ,Last_Update_Date                  DATE            :=  G_MISS_DATE
     ,Last_Updated_By                   NUMBER          :=  G_MISS_NUM
     ,Last_Update_Login                 NUMBER          :=  G_MISS_NUM);

   TYPE Item_Revision_Tbl_Type IS TABLE OF Item_Revision_Rec_Type INDEX BY BINARY_INTEGER;

   --  Category Assignment record and table (public types).

   TYPE Category_Assignment_Rec_Type IS RECORD(
      Transaction_Type                  VARCHAR2(30)    :=  G_MISS_CHAR
     ,Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
   -- Assignment key
     ,Inventory_Item_Id                 NUMBER          :=  G_MISS_NUM
     ,Item_Number                       VARCHAR2(2000)  :=  G_MISS_CHAR
     ,Organization_Id                   NUMBER          :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)     :=  G_MISS_CHAR
     ,Category_Set_Id                   NUMBER          :=  G_MISS_NUM
     ,Category_Set_Name                 VARCHAR2(30)    :=  G_MISS_CHAR
   -- Category identifier
     ,Category_Id                       NUMBER          :=  G_MISS_NUM
     ,Category_Code                     VARCHAR2(2000)  :=  G_MISS_CHAR
     ,Segment1                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment2                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment3                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment4                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment5                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment6                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment7                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment8                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment9                          VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment10                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment11                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment12                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment13                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment14                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment15                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment16                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment17                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment18                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment19                         VARCHAR2(40)    :=  G_MISS_CHAR
     ,Segment20                         VARCHAR2(40)    :=  G_MISS_CHAR);

   TYPE Category_Assignment_Tbl_Type IS TABLE OF Category_Assignment_Rec_Type  INDEX BY BINARY_INTEGER;

   --  Role Grant record and table (public types).

   TYPE Role_Grant_Rec_Type IS RECORD(
      Transaction_Type                  VARCHAR2(30)    :=  G_MISS_CHAR
     ,Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
     ,Role_Id                           NUMBER          :=  G_MISS_NUM
     ,Role_Name                         VARCHAR2(30)    :=  G_MISS_CHAR /* FND_MENUS.MENU_NAME%TYPE */
     ,Grantee_Party_Type                VARCHAR2(8)     :=  G_MISS_CHAR /* User, Group, All Users */
     ,Grantee_Party_Id                  NUMBER          :=  G_MISS_NUM  /* HZ_PARTIES.PARTY_ID%TYPE  NUMBER(15) */
     ,Grantee_Party_Name                VARCHAR2(360)   :=  G_MISS_CHAR /* HZ_PARTIES.PARTY_NAME%TYPE */
     ,Start_Date                        DATE            :=  G_MISS_DATE
     ,End_Date                          DATE            :=  G_MISS_DATE);

   TYPE Role_Grant_Tbl_Type IS TABLE OF Role_Grant_Rec_Type INDEX BY BINARY_INTEGER;


   --Variables representing missing values
   G_MISS_Role_Grant_Tbl       EGO_Item_PUB.Role_Grant_Tbl_Type;

  -- dsakalle for UCCnet Attributes
  -- IREP comments needs to be added
  TYPE UCCnet_Attrs_Singl_Row_Rec_Typ IS RECORD(
     TRANSACTION_TYPE                  VARCHAR2(30)
    ,RETURN_STATUS                     VARCHAR2(1)
    ,LANGUAGE_CODE                     VARCHAR2(4)
    ,IS_TRADE_ITEM_A_CONSUMER_UNIT     EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_A_CONSUMER_UNIT%TYPE
    ,IS_TRADE_ITEM_INFO_PRIVATE        EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_INFO_PRIVATE%TYPE
    ,GROSS_WEIGHT                      NUMBER
    ,UOM_GROSS_WEIGHT                  EGO_ITEM_GTN_ATTRS_VL.UOM_GROSS_WEIGHT%TYPE
    ,EFFECTIVE_DATE                    EGO_ITEM_GTN_ATTRS_VL.EFFECTIVE_DATE%TYPE
    ,END_AVAILABILITY_DATE_TIME        EGO_ITEM_GTN_ATTRS_VL.END_AVAILABILITY_DATE_TIME%TYPE
    ,START_AVAILABILITY_DATE_TIME      EGO_ITEM_GTN_ATTRS_VL.START_AVAILABILITY_DATE_TIME%TYPE
    ,BRAND_NAME                        EGO_ITEM_GTN_ATTRS_VL.BRAND_NAME%TYPE
    ,IS_TRADE_ITEM_A_BASE_UNIT         EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_A_BASE_UNIT%TYPE
    ,IS_TRADE_ITEM_A_VARIABLE_UNIT     EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_A_VARIABLE_UNIT%TYPE
    ,IS_PACK_MARKED_WITH_EXP_DATE      EGO_ITEM_GTN_ATTRS_VL.IS_PACK_MARKED_WITH_EXP_DATE%TYPE
    ,IS_PACK_MARKED_WITH_GREEN_DOT     EGO_ITEM_GTN_ATTRS_VL.IS_PACK_MARKED_WITH_GREEN_DOT%TYPE
    ,IS_PACK_MARKED_WITH_INGRED        EGO_ITEM_GTN_ATTRS_VL.IS_PACK_MARKED_WITH_INGRED%TYPE
    ,IS_PACKAGE_MARKED_AS_REC          EGO_ITEM_GTN_ATTRS_VL.IS_PACKAGE_MARKED_AS_REC%TYPE
    ,IS_PACKAGE_MARKED_RET             EGO_ITEM_GTN_ATTRS_VL.IS_PACKAGE_MARKED_RET%TYPE
    ,STACKING_FACTOR                   NUMBER
    ,STACKING_WEIGHT_MAXIMUM           NUMBER
    ,UOM_STACKING_WEIGHT_MAXIMUM       EGO_ITEM_GTN_ATTRS_VL.UOM_STACKING_WEIGHT_MAXIMUM%TYPE
    ,ORDERING_LEAD_TIME                NUMBER
    ,UOM_ORDERING_LEAD_TIME            EGO_ITEM_GTN_ATTRS_VL.UOM_ORDERING_LEAD_TIME%TYPE
    ,ORDER_QUANTITY_MAX                NUMBER
    ,ORDER_QUANTITY_MIN                NUMBER
    ,ORDER_QUANTITY_MULTIPLE           NUMBER
    ,ORDER_SIZING_FACTOR               NUMBER
    ,EFFECTIVE_START_DATE              EGO_ITEM_GTN_ATTRS_VL.EFFECTIVE_START_DATE%TYPE
    ,CATALOG_PRICE                     NUMBER
    ,EFFECTIVE_END_DATE                EGO_ITEM_GTN_ATTRS_VL.EFFECTIVE_END_DATE%TYPE
    ,SUGGESTED_RETAIL_PRICE            NUMBER
    ,MATERIAL_SAFETY_DATA_SHEET_NO     EGO_ITEM_GTN_ATTRS_VL.MATERIAL_SAFETY_DATA_SHEET_NO%TYPE
    ,HAS_BATCH_NUMBER                  EGO_ITEM_GTN_ATTRS_VL.HAS_BATCH_NUMBER%TYPE
    ,IS_NON_SOLD_TRADE_RET_FLAG        EGO_ITEM_GTN_ATTRS_VL.IS_NON_SOLD_TRADE_RET_FLAG%TYPE
    ,IS_TRADE_ITEM_MAR_REC_FLAG        EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_MAR_REC_FLAG%TYPE
    ,DIAMETER                          NUMBER
    ,UOM_DIAMETER                      EGO_ITEM_GTN_ATTRS_VL.UOM_DIAMETER%TYPE
    ,DRAINED_WEIGHT                    NUMBER
    ,UOM_DRAINED_WEIGHT                EGO_ITEM_GTN_ATTRS_VL.UOM_DRAINED_WEIGHT%TYPE
    ,GENERIC_INGREDIENT                EGO_ITEM_GTN_ATTRS_VL.GENERIC_INGREDIENT%TYPE
    ,GENERIC_INGREDIENT_STRGTH         NUMBER
    ,UOM_GENERIC_INGREDIENT_STRGTH     EGO_ITEM_GTN_ATTRS_VL.UOM_GENERIC_INGREDIENT_STRGTH%TYPE
    ,INGREDIENT_STRENGTH               EGO_ITEM_GTN_ATTRS_VL.INGREDIENT_STRENGTH%TYPE
    ,IS_NET_CONTENT_DEC_FLAG           EGO_ITEM_GTN_ATTRS_VL.IS_NET_CONTENT_DEC_FLAG%TYPE
    ,NET_CONTENT                       NUMBER
    ,UOM_NET_CONTENT                   EGO_ITEM_GTN_ATTRS_VL.UOM_NET_CONTENT%TYPE
    ,PEG_HORIZONTAL                    NUMBER
    ,UOM_PEG_HORIZONTAL                EGO_ITEM_GTN_ATTRS_VL.UOM_PEG_HORIZONTAL%TYPE
    ,PEG_VERTICAL                      NUMBER
    ,UOM_PEG_VERTICAL                  EGO_ITEM_GTN_ATTRS_VL.UOM_PEG_VERTICAL%TYPE
    ,CONSUMER_AVAIL_DATE_TIME          EGO_ITEM_GTN_ATTRS_VL.CONSUMER_AVAIL_DATE_TIME%TYPE
    ,DEL_TO_DIST_CNTR_TEMP_MAX         NUMBER
    ,UOM_DEL_TO_DIST_CNTR_TEMP_MAX     EGO_ITEM_GTN_ATTRS_VL.UOM_DEL_TO_DIST_CNTR_TEMP_MAX%TYPE
    ,DEL_TO_DIST_CNTR_TEMP_MIN         NUMBER
    ,UOM_DEL_TO_DIST_CNTR_TEMP_MIN     EGO_ITEM_GTN_ATTRS_VL.UOM_DEL_TO_DIST_CNTR_TEMP_MIN%TYPE
    ,DELIVERY_TO_MRKT_TEMP_MAX         NUMBER
    ,UOM_DELIVERY_TO_MRKT_TEMP_MAX     EGO_ITEM_GTN_ATTRS_VL.UOM_DELIVERY_TO_MRKT_TEMP_MAX%TYPE
    ,DELIVERY_TO_MRKT_TEMP_MIN         NUMBER
    ,UOM_DELIVERY_TO_MRKT_TEMP_MIN     EGO_ITEM_GTN_ATTRS_VL.UOM_DELIVERY_TO_MRKT_TEMP_MIN%TYPE
    ,SUB_BRAND                         EGO_ITEM_GTN_ATTRS_VL.SUB_BRAND%TYPE
 -- ,TRADE_ITEM_DESCRIPTOR             EGO_ITEM_GTN_ATTRS_VL.TRADE_ITEM_DESCRIPTOR%TYPE
    ,EANUCC_CODE                       EGO_ITEM_GTN_ATTRS_VL.EANUCC_CODE%TYPE
    ,EANUCC_TYPE                       EGO_ITEM_GTN_ATTRS_VL.EANUCC_TYPE%TYPE
    ,RETAIL_PRICE_ON_TRADE_ITEM        NUMBER
    ,QUANTITY_OF_COMP_LAY_ITEM         NUMBER
    ,QUANITY_OF_ITEM_IN_LAYER          NUMBER
    ,QUANTITY_OF_ITEM_INNER_PACK       NUMBER
    ,QUANTITY_OF_INNER_PACK            NUMBER
    ,BRAND_OWNER_GLN                   EGO_ITEM_GTN_ATTRS_VL.BRAND_OWNER_GLN%TYPE
    ,BRAND_OWNER_NAME                  EGO_ITEM_GTN_ATTRS_VL.BRAND_OWNER_NAME%TYPE
    ,STORAGE_HANDLING_TEMP_MAX         NUMBER
    ,UOM_STORAGE_HANDLING_TEMP_MAX     EGO_ITEM_GTN_ATTRS_VL.UOM_STORAGE_HANDLING_TEMP_MAX%TYPE
    ,STORAGE_HANDLING_TEMP_MIN         NUMBER
    ,UOM_STORAGE_HANDLING_TEMP_MIN     EGO_ITEM_GTN_ATTRS_VL.UOM_STORAGE_HANDLING_TEMP_MIN%TYPE
    ,TRADE_ITEM_COUPON                 NUMBER
    ,DEGREE_OF_ORIGINAL_WORT           EGO_ITEM_GTN_ATTRS_VL.DEGREE_OF_ORIGINAL_WORT%TYPE
    ,FAT_PERCENT_IN_DRY_MATTER         NUMBER
    ,PERCENT_OF_ALCOHOL_BY_VOL         NUMBER
    ,ISBN_NUMBER                       EGO_ITEM_GTN_ATTRS_VL.ISBN_NUMBER%TYPE
    ,ISSN_NUMBER                       EGO_ITEM_GTN_ATTRS_VL.ISSN_NUMBER%TYPE
    ,IS_INGREDIENT_IRRADIATED          EGO_ITEM_GTN_ATTRS_VL.IS_INGREDIENT_IRRADIATED%TYPE
    ,IS_RAW_MATERIAL_IRRADIATED        EGO_ITEM_GTN_ATTRS_VL.IS_RAW_MATERIAL_IRRADIATED%TYPE
    ,IS_TRADE_ITEM_GENETICALLY_MOD     EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_GENETICALLY_MOD%TYPE
    ,IS_TRADE_ITEM_IRRADIATED          EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_IRRADIATED%TYPE
    ,SECURITY_TAG_LOCATION             EGO_ITEM_GTN_ATTRS_VL.SECURITY_TAG_LOCATION%TYPE
    ,URL_FOR_WARRANTY                  EGO_ITEM_GTN_ATTRS_VL.URL_FOR_WARRANTY%TYPE
    ,NESTING_INCREMENT                 NUMBER
    ,UOM_NESTING_INCREMENT             EGO_ITEM_GTN_ATTRS_VL.UOM_NESTING_INCREMENT%TYPE
    ,IS_TRADE_ITEM_RECALLED            EGO_ITEM_GTN_ATTRS_VL.IS_TRADE_ITEM_RECALLED%TYPE
    ,MODEL_NUMBER                      EGO_ITEM_GTN_ATTRS_VL.MODEL_NUMBER%TYPE
    ,PIECES_PER_TRADE_ITEM             NUMBER
    ,UOM_PIECES_PER_TRADE_ITEM         EGO_ITEM_GTN_ATTRS_VL.UOM_PIECES_PER_TRADE_ITEM%TYPE
    ,DEPT_OF_TRNSPRT_DANG_GOODS_NUM    EGO_ITEM_GTN_ATTRS_VL.DEPT_OF_TRNSPRT_DANG_GOODS_NUM%TYPE
    ,RETURN_GOODS_POLICY               EGO_ITEM_GTN_ATTRS_VL.RETURN_GOODS_POLICY%TYPE
    ,IS_OUT_OF_BOX_PROVIDED            EGO_ITEM_GTN_ATTRS_VL.IS_OUT_OF_BOX_PROVIDED%TYPE
    ,INVOICE_NAME                      EGO_ITEM_GTN_ATTRS_VL.INVOICE_NAME%TYPE
    ,DESCRIPTIVE_SIZE                  EGO_ITEM_GTN_ATTRS_VL.DESCRIPTIVE_SIZE%TYPE
    ,FUNCTIONAL_NAME                   EGO_ITEM_GTN_ATTRS_VL.FUNCTIONAL_NAME%TYPE
    ,TRADE_ITEM_FORM_DESCRIPTION       EGO_ITEM_GTN_ATTRS_VL.TRADE_ITEM_FORM_DESCRIPTION%TYPE
    ,WARRANTY_DESCRIPTION              EGO_ITEM_GTN_ATTRS_VL.WARRANTY_DESCRIPTION%TYPE
    ,TRADE_ITEM_FINISH_DESCRIPTION     EGO_ITEM_GTN_ATTRS_VL.TRADE_ITEM_FINISH_DESCRIPTION%TYPE
    ,DESCRIPTION_SHORT                 EGO_ITEM_GTN_ATTRS_VL.DESCRIPTION_SHORT%TYPE
    ,IS_BARCODE_SYMBOLOGY_DERIVABLE    EGO_ITEM_GTN_ATTRS_VL.IS_BARCODE_SYMBOLOGY_DERIVABLE%TYPE
  );

  TYPE UCCnet_Attrs_Multi_Row_Rec_Typ IS RECORD(
     EXTENSION_ID                    NUMBER
    ,TRANSACTION_TYPE                VARCHAR2(30)
    ,RETURN_STATUS                   VARCHAR2(1)
    ,LANGUAGE_CODE                   VARCHAR2(4)
    ,MANUFACTURER_GLN                EGO_ITM_GTN_MUL_ATTRS_VL.MANUFACTURER_GLN%TYPE
    ,MANUFACTURER_ID                 NUMBER
    ,BAR_CODE_TYPE                   EGO_ITM_GTN_MUL_ATTRS_VL.BAR_CODE_TYPE%TYPE
    ,COLOR_CODE_LIST_AGENCY          EGO_ITM_GTN_MUL_ATTRS_VL.COLOR_CODE_LIST_AGENCY%TYPE
    ,COLOR_CODE_VALUE                EGO_ITM_GTN_MUL_ATTRS_VL.COLOR_CODE_VALUE%TYPE
    ,CLASS_OF_DANGEROUS_CODE         EGO_ITM_GTN_MUL_ATTRS_VL.CLASS_OF_DANGEROUS_CODE%TYPE
    ,DANGEROUS_GOODS_MARGIN_NUMBER   EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_MARGIN_NUMBER%TYPE
    ,DANGEROUS_GOODS_HAZARDOUS_CODE  EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_HAZARDOUS_CODE%TYPE
    ,DANGEROUS_GOODS_PACK_GROUP      EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_PACK_GROUP%TYPE
    ,DANGEROUS_GOODS_REG_CODE        EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_REG_CODE%TYPE
    ,DANGEROUS_GOODS_SHIPPING_NAME   EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_SHIPPING_NAME%TYPE
    ,UNITED_NATIONS_DANG_GOODS_NO    NUMBER
    ,FLASH_POINT_TEMP                NUMBER
    ,UOM_FLASH_POINT_TEMP            EGO_ITM_GTN_MUL_ATTRS_VL.UOM_FLASH_POINT_TEMP%TYPE
    ,COUNTRY_OF_ORIGIN               EGO_ITM_GTN_MUL_ATTRS_VL.COUNTRY_OF_ORIGIN%TYPE
    ,HARMONIZED_TARIFF_SYS_ID_CODE   NUMBER
    ,SIZE_CODE_LIST_AGENCY           EGO_ITM_GTN_MUL_ATTRS_VL.SIZE_CODE_LIST_AGENCY%TYPE
    ,SIZE_CODE_VALUE                 EGO_ITM_GTN_MUL_ATTRS_VL.SIZE_CODE_VALUE%TYPE
    ,HANDLING_INSTRUCTIONS_CODE      EGO_ITM_GTN_MUL_ATTRS_VL.HANDLING_INSTRUCTIONS_CODE%TYPE
    ,DANGEROUS_GOODS_TECHNICAL_NAME  EGO_ITM_GTN_MUL_ATTRS_VL.DANGEROUS_GOODS_TECHNICAL_NAME%TYPE
    ,DELIVERY_METHOD_INDICATOR       EGO_ITM_GTN_MUL_ATTRS_VL.DELIVERY_METHOD_INDICATOR%TYPE
  );

  TYPE UCCnet_Attrs_Multi_Row_Tbl_Typ IS TABLE OF UCCnet_Attrs_Multi_Row_Rec_Typ INDEX BY BINARY_INTEGER;

  TYPE UCCnet_Extra_Attrs_Rec_Typ IS RECORD(
     UNIT_WEIGHT                  NUMBER
  );

  -- IREP comments needs to be added
  -- dsakalle for UCCnet Attributes -- end

/*#
 * Use this API to create or update multiple items at once.  The
 * table type passed in p_role_grant_tbl is as follows:
 *<code><pre>
  TYPE Role_Grant_Tbl_Type IS TABLE OF Role_Grant_Rec_Type
    INDEX BY BINARY_INTEGER;

  TYPE Role_Grant_Rec_Type IS RECORD
  (
    Transaction_Type   VARCHAR2(30)  := G_MISS_CHAR
   ,Return_Status      VARCHAR2(1)   := G_MISS_CHAR
   ,Role_Id            NUMBER        := G_MISS_NUM
   ,Role_Name          VARCHAR2(30)  := G_MISS_CHAR
   ,Grantee_Party_Type VARCHAR2(8)   := G_MISS_CHAR
   ,Grantee_Party_Id   NUMBER        := G_MISS_NUM
   ,Grantee_Party_Name VARCHAR2(360) := G_MISS_CHAR
   ,Start_Date         DATE          := G_MISS_DATE
   ,End_Date           DATE          := G_MISS_DATE
  );
 *</pre></code>
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_item_tbl Each record in this PL/SQL table contains 320
 * fields representing all of the attribute values for one item
 * to be created or updated and various record-specific settings
 * (e.g., language, DML operation to perform for the record, etc.).
 * For more information about the record fields, refer to the parameter
 * documentation for the full parameter-list version of Process Item.
 * @param x_item_tbl Contains records corresponding to those passed
 * in p_item_tbl, except that the only populated fields for each
 * record are Inventory_Item_Id, Organization_Id, Description,
 * Long_Description, Item_Catalog_Group_Id, Primary_Uom_Code,
 * Allowed_Units_Lookup_Code, Inventory_Item_Status_Code,
 * Bom_Enabled_Flag, and Eng_Item_Flag.
 * @param p_role_grant_tbl Each record in this PL/SQL table
 * corresponds to one role grant to be created or updated; refer
 * to API description for the record type declaration.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Items
 */
   PROCEDURE Process_Items(
      p_api_version        IN           NUMBER
     ,p_init_msg_list      IN           VARCHAR2   DEFAULT  G_FALSE
     ,p_commit             IN           VARCHAR2   DEFAULT  G_FALSE
     ,p_Item_Tbl           IN           EGO_Item_PUB.Item_Tbl_Type
     ,x_Item_Tbl           OUT NOCOPY   EGO_Item_PUB.Item_Tbl_Type
     ,p_Role_Grant_Tbl     IN           EGO_Item_PUB.Role_Grant_Tbl_Type  DEFAULT  EGO_Item_PUB.G_MISS_Role_Grant_Tbl
     ,x_return_status      OUT NOCOPY   VARCHAR2
     ,x_msg_count          OUT NOCOPY   NUMBER
     -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl      IN           VARCHAR2 DEFAULT G_FALSE);


/*#
 * A convenience wrapper to Process_Item: use this API to create
 * or update an item by passing only the most important and/or
 * commonly used item attributes.  This version provides information
 * about parameters unique to this wrapper; for more information about
 * parameters and functionality, refer to the full parameter-list
 * version of Process Item.
 * @param p_New_Item_Number To update an existing item's Item
 * Number (i.e., the concatenated segments), pass this value
 * instead of passing each updated segment value individually.
 * @param p_New_segment1 As an alternative to passing
 * p_new_item_number above, you can pass each updated segment
 * value (1 through 20) as its own parameter.
* @rep:comment ------------ INTERNAL COMMENTS -----------------
 * there several params in this signature that aren't in the
   longer signature and that aren't yet explained:
     p_Organization_Code
     p_Item_Catalog_Group_Id
     p_Role_Id
     p_Role_Name
     p_Grantee_Party_Type
     p_Grantee_Party_Id
     p_Grantee_Party_Name
     p_Grant_Start_Date
     p_Grant_End_Date
   We can always explain these if feedback indicates that we should
* @rep:comment ---------- END INTERNAL COMMENTS ---------------
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item (convenience wrapper version)
 */
   PROCEDURE Process_Item(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2   DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2   DEFAULT  G_FALSE
   -- Transaction data
     ,p_Transaction_Type        IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Language_Code           IN      VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Copy item from
     ,p_Template_Id             IN      NUMBER     DEFAULT  NULL
     ,p_Template_Name           IN      VARCHAR2   DEFAULT  NULL
   -- Item identifier
     ,p_Inventory_Item_Id       IN      NUMBER     DEFAULT  G_MISS_NUM
     ,p_Item_Number             IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment1                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment2                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment3                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment4                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment5                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment6                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment7                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment8                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment9                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment10               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment11               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment12               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment13               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment14               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment15               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment16               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment17               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment18               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment19               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment20               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Object_Version_Number   IN      NUMBER     DEFAULT  G_MISS_NUM
   -- New Item segments Bug:2806390
     ,p_New_Item_Number         IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment1            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment2            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment3            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment4            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment5            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment6            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment7            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment8            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment9            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment10           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment11           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment12           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment13           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment14           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment15           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment16           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment17           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment18           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment19           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment20           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
   -- Organization
     ,p_Organization_Id         IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Organization_Code       IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Item catalog group
     ,p_Item_Catalog_Group_Id   IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Catalog_Status_Flag     IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Lifecycle
     ,p_Lifecycle_Id            IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Current_Phase_Id        IN      NUMBER          DEFAULT  G_MISS_NUM
   -- Main attributes
     ,p_Description             IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Long_Description        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Primary_Uom_Code        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Inventory_Item_Status_Code IN   VARCHAR2        DEFAULT  G_MISS_CHAR
   -- BOM/Eng
     ,p_Bom_Enabled_Flag        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Eng_Item_Flag           IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Role Grant
     ,p_Role_Id                 IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Role_Name               IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grantee_Party_Type      IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grantee_Party_Id        IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Grantee_Party_Name      IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grant_Start_Date        IN      DATE            DEFAULT  G_MISS_DATE
     ,p_Grant_End_Date          IN      DATE            DEFAULT  G_MISS_DATE
   -- Returned item ID
     ,x_Inventory_Item_Id       OUT NOCOPY      NUMBER
     ,x_Organization_Id         OUT NOCOPY      NUMBER
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,x_msg_count               OUT NOCOPY      NUMBER
   -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl           IN      VARCHAR2 DEFAULT G_FALSE);

/*#
 * The full parameter-list version of Process_Item: use this API
 * to create or update one item if you want to specify item attribute
 * values that aren't exposed in the wrapper version of Process_Item,
 * or to create or update an item revision.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_transaction_type Valid values are G_TTYPE_CREATE and
 * G_TTYPE_UPDATE.
 * @param p_Template_Id Either p_template_id or p_template_name may
 * be passed if applying a template.
 * @param p_inventory_item_id <B>DEPRECATED.</B>  This parameter
 * should not be used.
 * @param p_organization_id Item's Organization ID.
 * @param p_master_organization_id Item's Master Organization ID.
 * @param p_description Main Attribute Group Attribute Group - Description.
 * @param x_Inventory_Item_Id Item ID of successfully created or
 * updated Item.
 * @param x_Organization_Id Organization ID of successfully created
 * or updated item.
 * @param p_apply_template Valid values are 'BASE_TEMPLATE', 'USER_TEMPLATE',
 * and 'ALL'.  The values' meanings are:
 *<pre>
  BASE_TEMPLATE - Apply the template's item base attributes but not its user-defined attributes.
  USER_TEMPLATE - Apply the template's user-defined attributes but not its item base attributes.
  ALL - Apply all of the template's attributes, both item base and user-defined.
 *</pre>
 * @param p_object_version_number <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_long_description Main Attribute Group - Long Description.
 * @param p_primary_uom_code Main Attribute Group - Primary Unit of Measure. E.g., 'EA' for 'Each' or 'FT' for 'Foot'.
 * @param p_primary_unit_of_measure <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_item_type Main Attribute Group - User Item Type.
 * @param p_inventory_item_status_code Main Attribute Group - Item Status.
 * @param p_allowed_units_lookup_code Main Attribute Group - Conversions. Valid values are 1, 2, and 3.
 * @param p_item_catalog_group_id Item's Catalog group ID.
 * @param p_catalog_status_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_inventory_item_flag Inventory Attribute Group - Inventory Item. Valid values are 'Y' and 'N'.
 * @param p_stock_enabled_flag  Inventory Attribute Group - Stockable. Valid values are 'Y' and 'N'.
 * @param p_mtl_transactions_enabled_fl Inventory Attribute Group - Transactable. Valid values are 'Y' and 'N'.
 * @param p_check_shortages_flag Inventory Attribute Group - Check Material Shortage. Valid values are 'Y' and 'N'.
 * @param p_revision_qty_control_code Inventory Attribute Group - Revision Control. Valid values are 1 and 2.
 * @param p_reservable_type Inventory Attribute Group - Inventory - Reservable. Valid values are 1 and 2.
 * @param p_shelf_life_code Inventory Attribute Group - Lot Expiration Control. Valid values are 1, 2, and 4.
 * @param p_shelf_life_days Inventory Attribute Group - Lot Expiration Shelf Life Days.
 * @param p_cycle_count_enabled_flag  Inventory Attribute Group - Cycle Count Enabled - Cycle Count Enabled. Valid values are 'Y' and 'N'.
 * @param p_negative_measurement_error Inventory Attribute Group - Negative Measurement Error.
 * @param p_positive_measurement_error Inventory Attribute Group - Positive Measurement Error.
 * @param p_lot_control_code Inventory Attribute Group - Lot Control. Valid values are 1 and 2.
 * @param p_auto_lot_alpha_prefix Inventory Attribute Group - Lot Starting Prefix.
 * @param p_start_auto_lot_number Inventory Attribute Group - Lot Starting Number.
 * @param p_serial_number_control_code Inventory Attribute Group - Serial Generation. Valid values are 1, 2, 5, and 6.
 * @param p_auto_serial_alpha_prefix Inventory Attribute Group - Serial Starting Prefix.
 * @param p_start_auto_serial_number Inventory Attribute Group - Serial Starting Number.
 * @param p_location_control_code Inventory Attribute Group - Inventory - Locator Control. Valid values are 1, 2, and 3.
 * @param p_restrict_subinventories_cod Inventory Attribute Group - Inventory - Restrict Subinventories. Valid values are 1 and 2.
 * @param p_restrict_locators_code Inventory Attribute Group - Inventory - Restrict Locators. Valid values are 1 and 2.
 * @param p_bom_enabled_flag Bills of Material Attribute Group - BOM Allowed. Valid values are 'Y' and 'N'.
 * @param p_bom_item_type Bills of Material Attribute Group - BOM Item Type. Valid values are 1, 2, 3, 4, and 5.
 * @param p_base_item_id Bills of Material Attribute Group - Base Model.
 * @param p_effectivity_control Bills of Material Attribute Group - Effectivity Control. Valid values are 1 and 2.
 * @param p_eng_item_flag Bills of Material Attribute Group - Engineering Item. Valid values are 'Y' and 'N'.
 * @param p_engineering_ecn_code <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_engineering_item_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_engineering_date <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_product_family_item_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_auto_created_config_flag Bills of Material Attribute Group - Autocreated Configuration. Valid values are 'Y' and 'N'.
 * @param p_model_config_clause_name <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_new_revision_code <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_costing_enabled_flag Costing Attribute Group - Costing Enabled. Valid values are 'Y' and 'N'.
 * @param p_inventory_asset_flag Costing Attribute Group - Inventory Asset Value. Valid values are 'Y' and 'N'.
 * @param p_default_include_in_rollup_f Costing Attribute Group - Include In Rollup. Valid values are 'Y' and 'N'.
 * @param p_cost_of_sales_account Costing Attribute Group - Cost of Goods Sold Account.
 * @param p_std_lot_size Costing Attribute Group - Standard Lot Size.
 * @param p_purchasing_item_flag Purchasing Attribute Group - Purchased. Valid values are 'Y' and 'N'.
 * @param p_purchasing_enabled_flag Purchasing Attribute Group - Purchasable. Valid values are 'Y' and 'N'.
 * @param p_must_use_approved_vendor_fl Purchasing Attribute Group - Use Approved Supplier. Valid values are 'Y' and 'N'.
 * @param p_allow_item_desc_update_flag Purchasing Attribute Group - Allow Description Update. Valid values are 'Y' and 'N'.
 * @param p_rfq_required_flag Purchasing Attribute Group - RFQ Required. Valid values are 'Y' and 'N'.
 * @param p_outside_operation_flag Purchasing Attribute Group - Outside Processing Item. Valid values are 'Y' and 'N'.
 * @param p_outside_operation_uom_type Purchasing Attribute Group - Outside Processing Item - Unit Type. Valid values are ASSEMBLY and SOURCE.
 * @param p_taxable_flag Purchasing Attribute Group - Taxable. Valid values are 'Y' and 'N'.
 * @param p_purchasing_tax_code Purchasing Attribute Group - Tax Code.
 * @param p_receipt_required_flag Purchasing Attribute Group - Receipt Required. Valid values are 'Y' and 'N'.
 * @param p_inspection_required_flag Purchasing Attribute Group - Inspection Required. Valid values are 'Y' and 'N'.
 * @param p_buyer_id Purchasing Attribute Group - Default Buyer.
 * @param p_unit_of_issue Purchasing Attribute Group - Unit of Issue.
 * @param p_receive_close_tolerance Purchasing Attribute Group - Receipt Close Tolerance Percentage.
 * @param p_invoice_close_tolerance Purchasing Attribute Group - Purchasing - Invoice Close Tolerance Percentage.
 * @param p_un_number_id Purchasing Attribute Group - UN Number.
 * @param p_hazard_class_id Purchasing Attribute Group - Hazard Class.
 * @param p_list_price_per_unit Purchasing Attribute Group - List Price.
 * @param p_market_price Purchasing Attribute Group - Market Price.
 * @param p_price_tolerance_percent Purchasing Attribute Group - Price Tolerance Percentage.
 * @param p_rounding_factor Purchasing Attribute Group - Rounding Factor.
 * @param p_encumbrance_account Purchasing Attribute Group - Purchasing - Encumbrance Account.
 * @param p_expense_account Purchasing Attribute Group - Purchasing - Expense Account.
 * @param p_expense_billable_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_asset_category_id Purchasing Attribute Group - Asset Category.
 * @param p_receipt_days_exception_code Receiving Attribute Group - Receipt Date Controls - Action. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_days_early_receipt_allowed Receiving Attribute Group - Receipt Date Controls - Days Early.
 * @param p_days_late_receipt_allowed Receiving Attribute Group - Receipt Date Controls - Days Late.
 * @param p_allow_substitute_receipts_f Receiving Attribute Group - Allow Substitute Receipts. Valid values are 'Y' and 'N'.
 * @param p_allow_unordered_receipts_fl Receiving Attribute Group - Allow Unordered Receipts. Valid values are 'Y' and 'N'.
 * @param p_allow_express_delivery_flag Receiving Attribute Group - Allow Express Transactions . Valid values are 'Y' and 'N'.
 * @param p_qty_rcv_exception_code Receiving Attribute Group - Overreceipt Quantity Control - Action. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_qty_rcv_tolerance Receiving Attribute Group - Overreceipt Quantity Control - Tolerance Percentage.
 * @param p_receiving_routing_id Receiving Attribute Group - Receipt Routing. Valid values are 1, 2, and 3.
 * @param p_enforce_ship_to_location_c Receiving Attribute Group - Enforce Ship-To. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_weight_uom_code Physical Attributes Attribute Group - Unit of Measure.
 * @param p_unit_weight Physical Attributes Attribute Group - Unit Weight.
 * @param p_volume_uom_code Physical Attributes Attribute Group - Unit of Measure.
 * @param p_unit_volume Physical Attributes Attribute Group - Unit Volume.
 * @param p_container_item_flag Physical Attributes Attribute Group - Container. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_vehicle_item_flag Physical Attributes Attribute Group - Vehicle. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_container_type_code Physical Attributes Attribute Group - Container Type.
 * @param p_internal_volume Physical Attributes Attribute Group - Internal Volume.
 * @param p_maximum_load_weight Physical Attributes Attribute Group - Maximum Load Weight.
 * @param p_minimum_fill_percent Physical Attributes Attribute Group - Minimum Fill Percent.
 * @param p_inventory_planning_code General Planning Attribute Group - Inventory Planning Method. Valid values are 1, 2, 6, and 7.
 * @param p_planner_code General Planning Attribute Group - Planner.
 * @param p_planning_make_buy_code General Planning Attribute Group - Make or Buy. Valid values are 1 and 2.
 * @param p_min_minmax_quantity General Planning Attribute Group - Min-Max Quantity - Minimum.
 * @param p_max_minmax_quantity General Planning Attribute Group - Min-Max Quantity - Maximum.
 * @param p_minimum_order_quantity General Planning Attribute Group - Order Quantity - Minimum.
 * @param p_maximum_order_quantity General Planning Attribute Group - Order Quantity - Maximum.
 * @param p_order_cost General Planning Attribute Group - Cost - Order.
 * @param p_carrying_cost General Planning Attribute Group - Cost - Carrying Percentage.
 * @param p_source_type General Planning Attribute Group - Source - Type. Valid values are 1 and 2.
 * @param p_source_organization_id General Planning Attribute Group - Source - Organization.
 * @param p_source_subinventory General Planning Attribute Group - Source - Subinventory.
 * @param p_mrp_safety_stock_code General Planning Attribute Group - Safety Stock - Method. Valid values are 1 and 2.
 * @param p_safety_stock_bucket_days General Planning Attribute Group - Safety Stock - Bucket Days.
 * @param p_mrp_safety_stock_percent General Planning Attribute Group - Safety Stock - Percent.
 * @param p_fixed_order_quantity General Planning Attribute Group - Order Modifiers - Fixed Order Quantity.
 * @param p_fixed_days_supply General Planning Attribute Group - Order Modifiers - Fixed Days Supply.
 * @param p_fixed_lot_multiplier General Planning Attribute Group - Order Modifiers - Fixed Lot Multiplier.
 * @param p_mrp_planning_code MPS/MRP Planning Attribute Group - Planning Method. Valid values are 3, 4, 6, 7, 8, and 9.
 * @param p_ato_forecast_control MPS/MRP Planning Attribute Group - Forecast Control. Valid values are 1, 2, and 3.
 * @param p_planning_exception_set MPS/MRP Planning Attribute Group - Exception Set .
 * @param p_end_assembly_pegging_flag MPS/MRP Planning Attribute Group - Pegging. Valid values are A, B, Y, I, X, and N.
 * @param p_shrinkage_rate MPS/MRP Planning Attribute Group - Shrinkage Rate.
 * @param p_rounding_control_type MPS/MRP Planning Attribute Group - Round Order Quantities. Valid values are 1 and 2.
 * @param p_acceptable_early_days MPS/MRP Planning Attribute Group - Acceptable Early Days.
 * @param p_repetitive_planning_flag MPS/MRP Planning Attribute Group - Repetitive Planning - Repetitive Planning. Valid values are 'Y' and 'N'.
 * @param p_overrun_percentage MPS/MRP Planning Attribute Group - Repetitive Planning - Overrun Percentage.
 * @param p_acceptable_rate_increase MPS/MRP Planning Attribute Group - Repetitive Planning - Negative Acceptable Rate.
 * @param p_acceptable_rate_decrease MPS/MRP Planning Attribute Group - Repetitive Planning - Positive Acceptable Rate.
 * @param p_mrp_calculate_atp_flag MPS/MRP Planning Attribute Group - MPS Planning - Calculate ATP. Valid values are 'Y' and 'N'.
 * @param p_auto_reduce_mps MPS/MRP Planning Attribute Group - MPS Planning - Reduce MPS. Valid values are 1, 2, 3, and 4.
 * @param p_planning_time_fence_code MPS/MRP Planning Attribute Group - Planning Time Fence. Valid values are 1, 2, 3, and 4.
 * @param p_planning_time_fence_days MPS/MRP Planning Attribute Group - Planning Time Days.
 * @param p_demand_time_fence_code MPS/MRP Planning Attribute Group - Demand Time Fence. Valid values are 1, 2, 3, and 4.
 * @param p_demand_time_fence_days MPS/MRP Planning Attribute Group - Demand Time Days.
 * @param p_release_time_fence_code MPS/MRP Planning Attribute Group - Release Time Fence. Valid values are 1, 2, 3, 4, 5, and 6.
 * @param p_release_time_fence_days MPS/MRP Planning Attribute Group - Release Time Days.
 * @param p_preprocessing_lead_time Lead Times Attribute Group - Preprocessing.
 * @param p_full_lead_time Lead Times Attribute Group - Postprocessing.
 * @param p_postprocessing_lead_time Lead Times Attribute Group - Processing.
 * @param p_fixed_lead_time Lead Times Attribute Group - Fixed.
 * @param p_variable_lead_time Lead Times Attribute Group - Variable.
 * @param p_cum_manufacturing_lead_time Lead Times Attribute Group - Cumulative Manufacturing.
 * @param p_cumulative_total_lead_time Lead Times Attribute Group - Cumulative Total.
 * @param p_lead_time_lot_size Lead Times Attribute Group - Lead Time Lot Size.
 * @param p_build_in_wip_flag Work In Process - Build in WIP. Valid values are 'Y' and 'N'.
 * @param p_wip_supply_type Work In Process - Supply Type. Valid values are 1, 2, 3, 4, 5, and 6.
 * @param p_wip_supply_subinventory Work In Process - Supply Subinventory.
 * @param p_wip_supply_locator_id Work In Process - Supply Locator.
 * @param p_overcompletion_tolerance_ty Work In Process - Overcompletion Tolerance Type. Valid values are 1 and 2.
 * @param p_overcompletion_tolerance_va Work In Process - Overcompletion Tolerance Value.
 * @param p_customer_order_flag Order Management Attribute Group - Customer Ordered. Valid values are 'Y' and 'N'.
 * @param p_customer_order_enabled_flag Order Management Attribute Group - Customer Orders Enabled. Valid values are 'Y' and 'N'.
 * @param p_shippable_item_flag Order Management Attribute Group - Shippable. Valid values are 'Y' and 'N'.
 * @param p_internal_order_flag Order Management Attribute Group - Internal Ordered. Valid values are 'Y' and 'N'.
 * @param p_internal_order_enabled_flag Order Management Attribute Group - Internal Orders Enabled. Valid values are 'Y' and 'N'.
 * @param p_so_transactions_flag Order Management Attribute Group - OE Transactable. Valid values are 'Y' and 'N'.
 * @param p_pick_components_flag Order Management Attribute Group - Pick Components. Valid values are 'Y' and 'N'.
 * @param p_atp_flag Order Management Attribute Group - Check ATP. Valid values are 'Y', 'R', 'C', and 'N'.
 * @param p_replenish_to_order_flag Order Management Attribute Group - Assemble to Order. Valid values are 'Y' and 'N'.
 * @param p_atp_rule_id Order Management Attribute Group - ATP Rule.
 * @param p_atp_components_flag Order Management Attribute Group - ATP Components.
 * @param p_ship_model_complete_flag Order Management Attribute Group - Ship Model Complete.
 * @param p_picking_rule_id Order Management Attribute Group - Picking Rule.
 * @param p_collateral_flag Physical Attributes Attribute Group - Collateral Item. Valid values are 'NONE', 'REJECT', and 'WARNING'.
 * @param p_default_shipping_org Order Management Attribute Group - Default Shipping Organization.
 * @param p_returnable_flag Order Management Attribute Group - Returnable. Valid values are 'Y' and 'N'.
 * @param p_return_inspection_requireme Order Management Attribute Group - RMA Inspection Required. Valid values are 1 and 2.
 * @param p_over_shipment_tolerance Order Management Attribute Group - Tolerances - Over Shipment.
 * @param p_under_shipment_tolerance Order Management Attribute Group - Tolerances - Under Shipment.
 * @param p_over_return_tolerance Order Management Attribute Group - Tolerances - Over Return.
 * @param p_under_return_tolerance Order Management Attribute Group - Tolerances - Under Return.
 * @param p_invoiceable_item_flag Invoicing Attribute Group - Invoiceable Item. Valid values are 'Y' and 'N'.
 * @param p_invoice_enabled_flag Invoicing Attribute Group - Invoice Enabled. Valid values are 'Y' and 'N'.
 * @param p_accounting_rule_id Invoicing Attribute Group - Accounting Rule.
 * @param p_invoicing_rule_id Invoicing Attribute Group - Invoiceable Item.
 * @param p_tax_code Invoicing Attribute Group - Tax Code.
 * @param p_sales_account Invoicing Attribute Group - Sales Account.
 * @param p_payment_terms_id Invoicing Attribute Group - Payment Terms.
 * @param p_coverage_schedule_id Service Attribute Group - Service Contracts - Template.
 * @param p_service_duration Service Attribute Group - Service Contracts - Duration.
 * @param p_service_duration_period_cod Service Attribute Group - Service Contracts - Duration Period.
 * @param p_serviceable_product_flag Service Attribute Group - Enable Contract Coverage. Valid values are 'Y' and 'N'.
 * @param p_service_starting_delay Service Attribute Group - Service Contracts - Starting Delay (Days).
 * @param p_material_billable_flag Service Attribute Group - Debrief and Charges - Billing Type.
 * @param p_serviceable_component_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_preventive_maintenance_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_prorate_service_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_serviceable_item_class_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_base_warranty_service_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_warranty_vendor_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_max_warranty_amount <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_response_time_period_code <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_response_time_value <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_primary_specialist_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_secondary_specialist_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_wh_update_date <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_equipment_type Physical Attributes Attribute Group - Equipment. Valid values are 1 and 2.
 * @param p_recovered_part_disp_code Service Attribute Group - Debrief and Charges - Recovered Part Disposition.
 * @param p_defect_tracking_on_flag Service Attribute Group - Enable Defect Tracking. Valid values are 'Y' and NULL.
 * @param p_event_flag Physical Attributes Attribute Group - Event. Valid values are 'Y' and NULL.
 * @param p_electronic_flag Physical Attributes Attribute Group - Electronic Format. Valid values are 'Y' and NULL.
 * @param p_downloadable_flag Physical Attributes Attribute Group - Downloadable. Valid values are 'Y' and NULL.
 * @param p_vol_discount_exempt_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_coupon_exempt_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_comms_nl_trackable_flag Service Attribute Group - Installed Base - Track in Installed Base. Valid values are 'Y' and NULL.
 * @param p_asset_creation_code Service Attribute Group - Installed Base - Create Fixed Asset. Valid values are 1 and 0.
 * @param p_comms_activation_reqd_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_orderable_on_web_flag Web Option Attribute Group - Orderable on the Web. Valid values are 'Y' and NULL.
 * @param p_back_orderable_flag Web Option Attribute Group - Back Orderable. Valid values are 'Y' and NULL.
 * @param p_web_status Web Option Attribute Group - Web Status.
 * @param p_indivisible_flag Physical Attributes Attribute Group - OM Indivisible. Valid values are 'Y' and NULL.
 * @param p_dimension_uom_code Physical Attributes Attribute Group - Unit of Measure.
 * @param p_unit_length Physical Attributes Attribute Group - Length.
 * @param p_unit_width  Physical Attributes Attribute Group - Width.
 * @param p_unit_height Physical Attributes Attribute Group - Height.
 * @param p_bulk_picked_flag Inventory Attribute Group - Bulk Picked. Valid values are 'Y' and 'N'.
 * @param p_lot_status_enabled Inventory Attribute Group - Lot Status Enabled. Valid values are 'Y' and 'N'.
 * @param p_default_lot_status_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_serial_status_enabled Inventory Attribute Group - Serial Status Enabled. Valid values are 'Y' and 'N'.
 * @param p_default_serial_status_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_lot_split_enabled Inventory Attribute Group - Lot Split Enabled. Valid values are 'Y' and 'N'.
 * @param p_lot_merge_enabled Inventory Attribute Group - Lot Merge Enabled. Valid values are 'Y' and 'N'.
 * @param p_inventory_carry_penalty Work In Process - Inventory Carry.
 * @param p_operation_slack_penalty Work In Process - Operation Slack.
 * @param p_financing_allowed_flag Order Management Attribute Group - Financing Allowed. Valid values are 'Y' and NULL.
 * @param p_eam_item_type Asset Management Attribute Group - Asset Item Type. Valid values are 1, 2, and 3.
 * @param p_eam_activity_type_code Asset Management Attribute Group - Activity Type.
 * @param p_eam_activity_cause_code Asset Management Attribute Group - Activity Cause.
 * @param p_eam_act_notification_flag Asset Management Attribute Group - Activity Notification Required. Valid values are 'Y' and 'N'.
 * @param p_eam_act_shutdown_status Asset Management Attribute Group - Shutdown Type.
 * @param p_dual_uom_control <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_secondary_uom_code Main Attribute Group - Secondary Unit of Measure.
 * @param p_dual_uom_deviation_high Main Attribute Group - Positive Deviation Factor.
 * @param p_dual_uom_deviation_low Main Attribute Group - Negative Deviation Factor.
 * @param p_contract_item_type_code Service Attribute Group - Service Contracts - Contract Item Type. Valid values are 'SERVICE', 'SUBSCRIPTION', 'USAGE', and 'WARRANTY'.
 * @param p_subscription_depend_flag <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_serv_req_enabled_code Service Attribute Group - Service Request. Valid values are 'E', 'D', and 'I'.
 * @param p_serv_billing_enabled_flag Service Attribute Group - Debrief and Charges - Enable Service Billing. Valid values are 'Y' and 'N'.
 * @param p_serv_importance_level <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_planned_inv_point_flag MPS/MRP Planning Attribute Group - Planned Inventory Point. Valid values are 'Y' and NULL.
 * @param p_lot_translate_enabled Inventory Attribute Group - Lot Translate Enabled. Valid values are 'Y' and 'N'.
 * @param p_default_so_source_type Order Management Attribute Group - Default SO Source Type.
 * @param p_create_supply_flag MPS/MRP Planning Attribute Group - Create Supply. Valid values are 'Y' and 'N'.
 * @param p_substitution_window_code MPS/MRP Planning Attribute Group - Substitution Window. Valid values are 1, 2, 3, and 4.
 * @param p_substitution_window_days MPS/MRP Planning Attribute Group - Substitution Days.
 * @param p_ib_item_instance_class Service Attribute Group - Installed Base - Instance Class.
 * @param p_config_model_type Bills of Material Attribute Group - Configurator Model Type.
 * @param p_lot_substitution_enabled Inventory Attribute Group - Lot Substitution Enabled. Valid values are 'Y' and NULL.
 * @param p_minimum_license_quantity Web Option Attribute Group - Minimum License Quantity.
 * @param p_eam_activity_source_code Asset Management Attribute Group - Activity Source.
 * @param p_approval_status <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_tracking_quantity_ind Main Attribute Group - Tracking. Valid values are 'P' and 'D'.
 * @param p_ont_pricing_qty_source Main Attribute Group - Pricing. Valid values are 'P' and 'S'.
 * @param p_secondary_default_ind Main Attribute Group - Defaulting. Valid values are 'F', 'D', 'N', and NULL.
 * @param p_option_specific_sourced <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_vmi_minimum_units General Planning Attribute Group - Replenishment Point - Minimum Order.
 * @param p_vmi_minimum_days General Planning Attribute Group - Replenishment Point - Minimum Days of Supply.
 * @param p_vmi_maximum_units General Planning Attribute Group - Order Quantity - Maximum Order.
 * @param p_vmi_maximum_days General Planning Attribute Group - Order Quantity - Maximum Days of Supply.
 * @param p_vmi_fixed_order_quantity General Planning Attribute Group - Order Quantity - Fixed Quantity.
 * @param p_so_authorization_flag General Planning Attribute Group - Release Authorization Required. Valid values are 1, 2, and NULL.
 * @param p_consigned_flag General Planning Attribute Group - Consigned. Valid values are 1 and 2.
 * @param p_asn_autoexpire_flag General Planning Attribute Group - Auto-expire ASN. Valid values are 1 and 2.
 * @param p_vmi_forecast_type General Planning Attribute Group - Average Daily Demand Calculation - Forecast Type.
 * @param p_forecast_horizon General Planning Attribute Group - Average Daily Demand Calculation - Window Days.
 * @param p_exclude_from_budget_flag MPS/MRP Planning Attribute Group - Exclude From Budget. Valid values are 1 and 2.
 * @param p_days_tgt_inv_supply MPS/MRP Planning Attribute Group - Distribution Planning - Target Inventory Days of Supply.
 * @param p_days_tgt_inv_window MPS/MRP Planning Attribute Group - Distribution Planning - Target Inventory Window.
 * @param p_days_max_inv_supply MPS/MRP Planning Attribute Group - Distribution Planning - Maximum Inventory Days of Supply.
 * @param p_days_max_inv_window MPS/MRP Planning Attribute Group - Distribution Planning - Maximum Inventory Window.
 * @param p_drp_planned_flag MPS/MRP Planning Attribute Group - Distribution Planning - DRP Planned. Valid values are 1 and 2.
 * @param p_critical_component_flag MPS/MRP Planning Attribute Group - Critical Component. Valid values are 1 and 2.
 * @param p_continous_transfer MPS/MRP Planning Attribute Group - Incremental Supply Pattern - Continuous Inter-Org Transfers.
 * @param p_convergence MPS/MRP Planning Attribute Group - Incremental Supply Pattern - Convergence Pattern.
 * @param p_divergence MPS/MRP Planning Attribute Group - Incremental Supply Pattern - Divergence Pattern.
 * @param p_config_orgs Bills of Material Attribute Group - Create Configured Item, BOM.
 * @param p_config_match Bills of Material Attribute Group - Match Configuration.
 * @param p_Item_Number Concatenated segments value. Either Item Number or Segments should be passed.
 * @param p_segment1 Segment1 of item name.
 * @param p_segment2 Segment2 of item name.
 * @param p_segment3 Segment3 of item name.
 * @param p_segment4 Segment4 of item name.
 * @param p_segment5 Segment5 of item name.
 * @param p_segment6 Segment6 of item name.
 * @param p_segment7 Segment7 of item name.
 * @param p_segment8 Segment8 of item name.
 * @param p_segment9 Segment9 of item name.
 * @param p_segment10 Segment10 of item name.
 * @param p_segment11 Segment11 of item name.
 * @param p_segment12 Segment12 of item name.
 * @param p_segment13 Segment13 of item name.
 * @param p_segment14 Segment14 of item name.
 * @param p_segment15 Segment15 of item name.
 * @param p_segment16 Segment16 of item name.
 * @param p_segment17 Segment17 of item name.
 * @param p_segment18 Segment18 of item name.
 * @param p_segment19 Segment19 of item name.
 * @param p_segment20 Segment20 of item name.
 * @param p_summary_flag  <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_enabled_flag   <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_start_date_active  <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_end_date_active  <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_attribute_category Descriptive Flexfield (DFF) Context Field.
 * @param p_attribute1 Descriptive Flexfield's Attribute1.
 * @param p_attribute2 Descriptive Flexfield's Attribute2.
 * @param p_attribute3 Descriptive Flexfield's Attribute3.
 * @param p_attribute4 Descriptive Flexfield's Attribute4.
 * @param p_attribute5 Descriptive Flexfield's Attribute5.
 * @param p_attribute6 Descriptive Flexfield's Attribute6.
 * @param p_attribute7 Descriptive Flexfield's Attribute7.
 * @param p_attribute8 Descriptive Flexfield's Attribute8.
 * @param p_attribute9 Descriptive Flexfield's Attribute9.
 * @param p_attribute10 Descriptive Flexfield's Attribute10.
 * @param p_attribute11 Descriptive Flexfield's Attribute11.
 * @param p_attribute12 Descriptive Flexfield's Attribute12.
 * @param p_attribute13 Descriptive Flexfield's Attribute13.
 * @param p_attribute14 Descriptive Flexfield's Attribute14.
 * @param p_attribute15 Descriptive Flexfield's Attribute15.
 * @param p_global_attribute_category Descriptive Flexfield (DFF) Context Field.
 * @param p_global_attribute1 Descriptive Flexfield's Global Attribute1.
 * @param p_global_attribute2 Descriptive Flexfield's Global Attribute2.
 * @param p_global_attribute3 Descriptive Flexfield's Global Attribute3.
 * @param p_global_attribute4 Descriptive Flexfield's Global Attribute4.
 * @param p_global_attribute5 Descriptive Flexfield's Global Attribute5.
 * @param p_global_attribute6 Descriptive Flexfield's Global Attribute6.
 * @param p_global_attribute7 Descriptive Flexfield's Global Attribute7.
 * @param p_global_attribute8 Descriptive Flexfield's Global Attribute8.
 * @param p_global_attribute9 Descriptive Flexfield's Global Attribute9.
 * @param p_global_attribute10 Descriptive Flexfield's Global Attribute10.
 * @param p_global_attribute11 Descriptive Flexfield's Global Attribute11.
 * @param p_global_attribute12 Descriptive Flexfield's Global Attribute12.
 * @param p_global_attribute13 Descriptive Flexfield's Global Attribute13.
 * @param p_global_attribute14 Descriptive Flexfield's Global Attribute14.
 * @param p_global_attribute15 Descriptive Flexfield's Global Attribute15.
 * @param p_global_attribute16 Descriptive Flexfield's Global Attribute16.
 * @param p_global_attribute17 Descriptive Flexfield's Global Attribute17.
 * @param p_global_attribute18 Descriptive Flexfield's Global Attribute18.
 * @param p_global_attribute19 Descriptive Flexfield's Global Attribute19.
 * @param p_global_attribute20 Descriptive Flexfield's Global Attribute20.
 * @param p_creation_date <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_created_by    <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_last_update_date <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_last_updated_by  <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_last_update_login <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_request_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_program_application_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_program_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_program_update_date <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_lifecycle_id Item's Lifecycle.
 * @param p_current_phase_id Item's Lifecycle Phase.
 * @param p_revision_id <B>DEPRECATED.</B>  This parameter should not be used.
 * @param p_revision_code Revision Code.
 * @param p_revision_label Revision Label.
 * @param p_revision_description Revision Description.
 * @param p_effectivity_Date Revision Effectivity Date.
 * @param p_rev_lifecycle_id Revision's Lifecycle.
 * @param p_rev_current_phase_id Revision's Lifecycle Phase.
 * @param p_rev_attribute_category Revision's Descriptive Flexfield (DFF) Context Field.
 * @param p_rev_attribute1 Revision Descriptive Flexfield's Attribute1.
 * @param p_rev_attribute2 Revision Descriptive Flexfield's Attribute2.
 * @param p_rev_attribute3 Revision Descriptive Flexfield's Attribute3.
 * @param p_rev_attribute4 Revision Descriptive Flexfield's Attribute4.
 * @param p_rev_attribute5 Revision Descriptive Flexfield's Attribute5.
 * @param p_rev_attribute6 Revision Descriptive Flexfield's Attribute6.
 * @param p_rev_attribute7 Revision Descriptive Flexfield's Attribute7.
 * @param p_rev_attribute8 Revision Descriptive Flexfield's Attribute8.
 * @param p_rev_attribute9 Revision Descriptive Flexfield's Attribute9.
 * @param p_rev_attribute10 Revision Descriptive Flexfield's Attribute10.
 * @param p_rev_attribute11 Revision Descriptive Flexfield's Attribute11.
 * @param p_rev_attribute12 Revision Descriptive Flexfield's Attribute12.
 * @param p_rev_attribute13 Revision Descriptive Flexfield's Attribute13.
 * @param p_rev_attribute14 Revision Descriptive Flexfield's Attribute14.
 * @param p_rev_attribute15 Revision Descriptive Flexfield's Attribute15.
 * @param p_style_item_flag Provide the value for this parameter as 'N' to create a SKU item.
 * @param p_style_item_id Provide the style item id that need to be used while creating SKU item.
 * @param p_attributes_row_table Contains row-level data and metadata about each attribute group row of variant attributes of SKU item.
 * See EGO_USER_ATTRS_DATA_PUB for details. (Valid only in CREATE Mode).
 * @param p_attributes_data_table Contains data and metadata about each variant attribute in each attribute group row for SKU creation.
 * See EGO_USER_ATTRS_DATA_PUB for details. (Valid only in CREATE Mode).
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item
 */
 PROCEDURE Process_Item(
      p_api_version                    IN   NUMBER
     ,p_init_msg_list                  IN   VARCHAR2   DEFAULT  G_FALSE
     ,p_commit                         IN   VARCHAR2   DEFAULT  G_FALSE
   -- Transaction data
     ,p_Transaction_Type               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Language_Code                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Copy item from template
     ,p_Template_Id                    IN   NUMBER     DEFAULT  NULL
     ,p_Template_Name                  IN   VARCHAR2   DEFAULT  NULL
   -- Copy item from another item
     ,p_copy_inventory_item_Id         IN   NUMBER     DEFAULT  G_MISS_NUM
   -- Base Attributes
     ,p_inventory_item_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_organization_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_master_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_description                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_long_description               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_primary_uom_code               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_primary_unit_of_measure        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_item_type                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_item_status_code     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allowed_units_lookup_code      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_item_catalog_group_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_catalog_status_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_stock_enabled_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_mtl_transactions_enabled_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_check_shortages_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_qty_control_code      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_reservable_type                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_shelf_life_code                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_shelf_life_days                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cycle_count_enabled_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_negative_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_positive_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lot_control_code               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_lot_alpha_prefix          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_auto_lot_number          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serial_number_control_code     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_serial_alpha_prefix       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_auto_serial_number       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_location_control_code          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_restrict_subinventories_cod    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_restrict_locators_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_bom_enabled_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_bom_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_base_item_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_effectivity_control            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eng_item_flag                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_engineering_ecn_code           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_engineering_item_id            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_engineering_date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_product_family_item_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_created_config_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_model_config_clause_name       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- attribute not in the form
     ,p_new_revision_code              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_costing_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_asset_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_include_in_rollup_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_cost_of_sales_account          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_std_lot_size                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_purchasing_item_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_purchasing_enabled_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_must_use_approved_vendor_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_item_desc_update_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rfq_required_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_outside_operation_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_outside_operation_uom_type     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_taxable_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_purchasing_tax_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_receipt_required_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inspection_required_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_buyer_id                       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_of_issue                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_receive_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoice_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_un_number_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_hazard_class_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_list_price_per_unit            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_market_price                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_price_tolerance_percent        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rounding_factor                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_encumbrance_account            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_expense_account                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_expense_billable_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_asset_category_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_receipt_days_exception_code    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_days_early_receipt_allowed     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_late_receipt_allowed      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_allow_substitute_receipts_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_unordered_receipts_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_express_delivery_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_qty_rcv_exception_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_qty_rcv_tolerance              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_receiving_routing_id           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_enforce_ship_to_location_c     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_weight_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_weight                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_volume_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_volume                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_container_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_vehicle_item_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_container_type_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_volume                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_maximum_load_weight            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_minimum_fill_percent           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_inventory_planning_code        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planner_code                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_planning_make_buy_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_min_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_max_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_minimum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_maximum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_order_cost                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_carrying_cost                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_type                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_subinventory            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_mrp_safety_stock_code          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_safety_stock_bucket_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_safety_stock_percent       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_order_quantity           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_days_supply              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_lot_multiplier           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_planning_code              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_ato_forecast_control           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_exception_set         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_end_assembly_pegging_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_shrinkage_rate                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rounding_control_type          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_early_days          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_repetitive_planning_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_overrun_percentage             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_rate_increase       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_rate_decrease       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_calculate_atp_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_auto_reduce_mps                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_time_fence_code       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_time_fence_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_demand_time_fence_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_demand_time_fence_days         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_release_time_fence_code        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_release_time_fence_days        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_preprocessing_lead_time        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_full_lead_time                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_postprocessing_lead_time       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_lead_time                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_variable_lead_time             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cum_manufacturing_lead_time    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cumulative_total_lead_time     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lead_time_lot_size             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_build_in_wip_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_wip_supply_type                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_wip_supply_subinventory        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_wip_supply_locator_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_overcompletion_tolerance_ty    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_overcompletion_tolerance_va    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_customer_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_customer_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_shippable_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_so_transactions_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_pick_components_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_atp_flag                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_replenish_to_order_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_atp_rule_id                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_atp_components_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_ship_model_complete_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_picking_rule_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_collateral_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_shipping_org           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_returnable_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_return_inspection_requireme    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_over_shipment_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_under_shipment_tolerance       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_over_return_tolerance          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_under_return_tolerance         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoiceable_item_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_invoice_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_accounting_rule_id             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoicing_rule_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_tax_code                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_sales_account                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_payment_terms_id               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_coverage_schedule_id           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_service_duration               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_service_duration_period_cod    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serviceable_product_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_service_starting_delay         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_material_billable_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serviceable_component_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_preventive_maintenance_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_prorate_service_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Start attributes not in the form
     ,p_serviceable_item_class_id      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_base_warranty_service_id       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_warranty_vendor_id             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_max_warranty_amount            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_response_time_period_code      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_response_time_value            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_primary_specialist_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_secondary_specialist_id        IN   NUMBER     DEFAULT  G_MISS_NUM
   -- End attributes not in the form
     ,p_wh_update_date                 IN   DATE       DEFAULT  G_MISS_DATE
     ,p_equipment_type                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_recovered_part_disp_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_defect_tracking_on_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_event_flag                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_electronic_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_downloadable_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_vol_discount_exempt_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_coupon_exempt_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_comms_nl_trackable_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_asset_creation_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_comms_activation_reqd_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_orderable_on_web_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_back_orderable_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_web_status                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_indivisible_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dimension_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_length                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_width                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_height                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_bulk_picked_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_status_enabled             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_lot_status_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_serial_status_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_serial_status_id       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lot_split_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_merge_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_carry_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_operation_slack_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_financing_allowed_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eam_activity_type_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_activity_cause_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_act_notification_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_act_shutdown_status        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dual_uom_control               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_secondary_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dual_uom_deviation_high        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_dual_uom_deviation_low         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_contract_item_type_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_subscription_depend_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_req_enabled_code          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_billing_enabled_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_importance_level          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planned_inv_point_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_translate_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_so_source_type         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_create_supply_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_substitution_window_code       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_substitution_window_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_ib_item_instance_class         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_config_model_type              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_substitution_enabled       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_minimum_license_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eam_activity_source_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_approval_status                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     --Start: 26 new attributes
     ,p_tracking_quantity_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_ont_pricing_qty_source         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_secondary_default_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_option_specific_sourced        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_minimum_units              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_minimum_days               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_maximum_units              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_maximum_days               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_fixed_order_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_so_authorization_flag          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_consigned_flag                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_asn_autoexpire_flag            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_forecast_type              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_forecast_horizon               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_exclude_from_budget_flag       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_tgt_inv_supply            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_tgt_inv_window            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_max_inv_supply            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_max_inv_window            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_drp_planned_flag               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_critical_component_flag        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_continous_transfer             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_convergence                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_divergence                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_config_orgs                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_config_match                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     --End: 26 new attributes
     ,p_Item_Number                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment1                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment2                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment3                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment4                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment5                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment6                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment7                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment8                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment9                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment10                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment11                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment12                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment13                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment14                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment15                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment16                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment17                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment18                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment19                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment20                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_summary_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_enabled_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_date_active              IN   DATE       DEFAULT  G_MISS_DATE
     ,p_end_date_active                IN   DATE       DEFAULT  G_MISS_DATE
     ,p_attribute_category             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute1                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute2                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute3                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute4                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute5                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute6                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute7                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute8                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute9                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute10                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute11                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute12                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute13                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute14                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute15                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute16                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute17                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute18                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute19                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute20                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute21                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute22                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute23                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute24                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute25                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute26                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute27                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute28                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute29                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute30                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute_category      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute1              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute2              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute3              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute4              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute5              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute6              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute7              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute8              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute9              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute10             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute11              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute12              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute13              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute14              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute15              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute16              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute17              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute18              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute19              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute20             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_creation_date                  IN   DATE       DEFAULT  G_MISS_DATE
     ,p_created_by                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_last_update_date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_last_updated_by                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_last_update_login              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_request_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_application_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_update_date            IN   DATE       DEFAULT  G_MISS_DATE
     ,p_lifecycle_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_current_phase_id               IN   NUMBER     DEFAULT  G_MISS_NUM
   -- Revision attribute parameter
     ,p_revision_id                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_revision_code                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_label                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_description           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_effectivity_Date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_rev_lifecycle_id               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rev_current_phase_id           IN   NUMBER     DEFAULT  G_MISS_NUM
   -- 5208102: Supporting template for UDA's at revisions
     ,p_rev_template_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rev_template_name              IN   VARCHAR2   DEFAULT  G_MISS_CHAR

     ,p_rev_attribute_category         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute1                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute2                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute3                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute4                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute5                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute6                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute7                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute8                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute9                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute10                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute11                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute12                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute13                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute14                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute15                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Returned item ID
     ,x_Inventory_Item_Id              OUT NOCOPY    NUMBER
     ,x_Organization_Id                OUT NOCOPY    NUMBER
     ,x_return_status                  OUT NOCOPY    VARCHAR2
     ,x_msg_count                      OUT NOCOPY    NUMBER
     ,x_msg_data                       OUT NOCOPY    VARCHAR2
     ,p_apply_template                 IN   VARCHAR2   DEFAULT 'ALL'
     ,p_object_version_number          IN   NUMBER     DEFAULT G_MISS_NUM
     ,p_process_control                IN  VARCHAR2    DEFAULT 'API' -- Bug 909288 --Bug:3777954
     ,p_process_item                   IN   NUMBER     DEFAULT G_MISS_NUM

     /* R12 Attributes */
     ,P_CAS_NUMBER                    IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_FLAG                IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_PREFIX              IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_STARTING_NUMBER     IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_CHILD_LOT_VALIDATION_FLAG     IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_COPY_LOT_ATTRIBUTE_FLAG       IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_DEFAULT_GRADE                 IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_EXPIRATION_ACTION_CODE        IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_EXPIRATION_ACTION_INTERVAL    IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_GRADE_CONTROL_FLAG            IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_HAZARDOUS_MATERIAL_FLAG       IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_HOLD_DAYS                     IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_LOT_DIVISIBLE_FLAG            IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_MATURITY_DAYS                 IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_PARENT_CHILD_GENERATION_FLAG  IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_PROCESS_COSTING_ENABLED_FLAG  IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_PROCESS_EXECUTION_ENABLED_FL  IN VARCHAR2    DEFAULT  G_MISS_CHAR
     ,P_PROCESS_QUALITY_ENABLED_FLAG  IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_PROCESS_SUPPLY_LOCATOR_ID     IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_PROCESS_SUPPLY_SUBINVENTORY   IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_PROCESS_YIELD_LOCATOR_ID      IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_PROCESS_YIELD_SUBINVENTORY    IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_RECIPE_ENABLED_FLAG           IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_RETEST_INTERVAL               IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_CHARGE_PERIODICITY_CODE       IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_REPAIR_LEADTIME               IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_REPAIR_YIELD                  IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_PREPOSITION_POINT             IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_REPAIR_PROGRAM                IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_SUBCONTRACTING_COMPONENT      IN NUMBER       DEFAULT  G_MISS_NUM
     ,P_OUTSOURCED_ASSEMBLY           IN NUMBER       DEFAULT  G_MISS_NUM
      -- R12 C Attributes
     ,P_GDSN_OUTBOUND_ENABLED_FLAG    IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_TRADE_ITEM_DESCRIPTOR         IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_STYLE_ITEM_FLAG               IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_STYLE_ITEM_ID                 IN NUMBER       DEFAULT  G_MISS_NUM
     -- Bug 9092888 - changes
     ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
     ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
     -- Bug 9092888 - changes
     -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl                 IN VARCHAR2 DEFAULT G_FALSE
     );

/*#
 * Use this API to assign multiple items to organizations.  The
 * table type passed in p_item_org_assignment_tbl is as follows:
 *<code><pre>
  TYPE Item_Org_Assignment_Tbl_Type IS TABLE OF Item_Org_Assignment_Rec_Type
    INDEX BY BINARY_INTEGER;

  TYPE Item_Org_Assignment_Rec_Type IS RECORD
  (
    Return_Status     VARCHAR2(1)    := G_MISS_CHAR
   ,Inventory_Item_Id NUMBER         := G_MISS_NUM
   ,Item_Number       VARCHAR2(2000) := G_MISS_CHAR
   ,Organization_Id   NUMBER         := G_MISS_NUM
   ,Organization_Code VARCHAR2(3)    := G_MISS_CHAR
   ,Primary_Uom_Code  MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE := G_MISS_CHAR
  );
 *</pre></code>
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_item_org_assignment_tbl Each record in this PL/SQL
 * table corresponds to one assignment of an item to an organization;
 * refer to API description for the record type declaration.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Organization Assignments
 */
   PROCEDURE Process_Item_Org_Assignments(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_Item_Org_Assignment_Tbl IN      EGO_Item_PUB.Item_Org_Assignment_Tbl_Type
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER);

/*#
 * Use this API to assign an item to an organization.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_primary_uom_code E.g., 'EA' for 'Each' or 'FT' for 'Foot'.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Item to Organization
 */
   PROCEDURE Assign_Item_To_Org(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_Inventory_Item_Id       IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Item_Number             IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Organization_Id         IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Organization_Code       IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Primary_Uom_Code        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER);

   PROCEDURE Update_Item_Number(
      p_Inventory_Item_Id       IN  NUMBER
     ,p_Item_Number             IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment1                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment2                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment3                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment4                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment5                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment6                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment7                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment8                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment9                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment10               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment11               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment12               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment13               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment14               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment15               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment16               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment17               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment18               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment19               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment20               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment1            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment2            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment3            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment4            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment5            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment6            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment7            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment8            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment9            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment10           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment11           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment12           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment13           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment14           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment15           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment16           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment17           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment18           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment19           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment20           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,x_Item_Tbl                IN OUT NOCOPY   EGO_Item_PUB.Item_Tbl_Type
     ,x_return_status           OUT NOCOPY  VARCHAR2);

   PROCEDURE Seed_Item_Long_Desc_Attr_Group (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_item_catalog_group_id         IN  NUMBER
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

   PROCEDURE Seed_Item_Long_Desc_In_Bulk (
        p_set_process_id                IN  NUMBER
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_data                      OUT NOCOPY VARCHAR2);


/*#
 * Use this API to insert, update, or delete one or more rows of
 * user-defined attributes data for one item. Note: This API is a
 * wrapper for an API in the EGO_USER_ATTRS_DATA_PUB package, which
 * uses the ERROR_HANDLER package; more information is available in
 * the EGO_USER_ATTRS_DATA_PUB and ERROR_HANDLER package specifications.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_attributes_row_table Contains row-level data and metadata
 * about each attribute group that is processed.  See
 * EGO_USER_ATTRS_DATA_PUB for details.
 * @param p_attributes_data_table Contains data and metadata about each
 * attribute that is processed.  Refer to EGO_USER_ATTRS_DATA_PUB
 * for details.
 * @param p_entity_id Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_index Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_code Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_debug_level Used in debugging; refer to EGO_USER_ATTRS_DATA_PUB
 * for details.
 * @param p_init_error_handler Indicates whether to initialize
 * ERROR_HANDLER message stack (and open debug session, if applicable).
 * @param p_write_to_concurrent_log Indicates whether to log ERROR_HANDLER
 * messages to concurrent log (only applicable when called from concurrent
 * program and when p_log_errors is passed as FND_API.G_TRUE).
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.  Refer to the package description of the parameter
 * 'p_init_msg_list' above for more information about this parameter
 * and a list of valid values.
 * @param p_log_errors Indicates whether to write ERROR_HANDLER message
 * stack to MTL_INTERFACE_ERRORS, concurrent log (if applicable), and
 * debug file (if applicable); if FND_API.G_FALSE is passed, messages
 * will still be added to ERROR_HANDLER, but the message stack will not
 * be written to any destination.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param x_failed_row_id_list Returns a comma-delimited list of
 * ROW_IDENTIFIERs indicating which attribute group rows failed to be
 * processed.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process User-Defined Attributes for Item
 * @rep:businessevent oracle.apps.ego.item.postAttributeChange
 */
  PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

/*#
 * Use this API to retrieve one or more rows of user-defined attributes
 * data for one item. Note: This API is a wrapper for an API in the
 * EGO_USER_ATTRS_DATA_PUB package, which uses the ERROR_HANDLER
 * package; more information is available in the EGO_USER_ATTRS_DATA_PUB
 * and ERROR_HANDLER package specifications.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_attr_group_request_table Contains a list of elements, each
 * of which identifies an attribute group whose data to retrieve.  Refer
 * to EGO_USER_ATTRS_DATA_PUB for details about this data type and its
 * usage.
 * @param p_entity_id Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_index Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_code Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_debug_level Used in debugging; refer to EGO_USER_ATTRS_DATA_PUB
 * for details.
 * @param p_init_error_handler Indicates whether to initialize
 * ERROR_HANDLER message stack (and open debug session, if applicable).
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.  Refer to the package description of the parameter
 * 'p_init_msg_list' above for more information about this parameter
 * and a list of valid values.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing (but since this API currently performs no
 * DML operations, this parameter is reserved for future use).
 * for more information about this parameter and a list of valid
 * values.
 * @param x_attributes_row_table Contains row-level data and metadata
 * about each attribute group row that was requested for the specified
 * item.  See EGO_USER_ATTRS_DATA_PUB for details.
 * @param x_attributes_data_table Contains data and metadata about each
 * attribute in each attribute group row that was requested for the
 * specified item.  Refer to EGO_USER_ATTRS_DATA_PUB for details.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get User-Defined Attributes for Item
 */
  PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

   PROCEDURE Update_Item_Approval_Status (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_approval_status               IN  VARCHAR2
       ,p_nir_id                        IN  NUMBER     DEFAULT  NULL
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE);

   Procedure Process_Item_Lifecycle(
      P_API_VERSION                 IN   NUMBER,
      P_INIT_MSG_LIST               IN   VARCHAR2,
      P_INVENTORY_ITEM_ID           IN   NUMBER,
      P_ORGANIZATION_ID             IN   NUMBER,
      P_CATALOG_GROUP_ID            IN   NUMBER,
      P_LIFECYCLE_ID                IN   NUMBER,
      P_CURRENT_PHASE_ID            IN   NUMBER,
      P_ITEM_STATUS                 IN   VARCHAR2,
      P_TRANSACTION_TYPE            IN   VARCHAR2,
      P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
      X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
      X_MSG_COUNT                   OUT  NOCOPY NUMBER);

   Procedure Create_Item_Lifecycle(
      P_API_VERSION                 IN   NUMBER,
      P_INIT_MSG_LIST               IN   VARCHAR2,
      P_INVENTORY_ITEM_ID           IN   NUMBER,
      P_ORGANIZATION_ID             IN   NUMBER,
      P_LIFECYCLE_ID                IN   NUMBER,
      P_CURRENT_PHASE_ID            IN   NUMBER,
      P_ITEM_STATUS                 IN   VARCHAR2,
      P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
      X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
      X_MSG_COUNT                   OUT  NOCOPY NUMBER);

   Procedure Update_Item_Lifecycle(
      P_API_VERSION                 IN   NUMBER,
      P_INIT_MSG_LIST               IN   VARCHAR2,
      P_INVENTORY_ITEM_ID           IN   NUMBER,
      P_ORGANIZATION_ID             IN   NUMBER,
      P_CATALOG_GROUP_ID            IN   NUMBER,
      P_LIFECYCLE_ID                IN   NUMBER,
      P_CURRENT_PHASE_ID            IN   NUMBER,
      P_ITEM_STATUS                 IN   VARCHAR2,
      P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
      X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
      X_MSG_COUNT                   OUT  NOCOPY NUMBER);

   Procedure Update_Item_Attr_Ext(
      P_API_VERSION                 IN   NUMBER,
      P_INIT_MSG_LIST               IN   VARCHAR2,
      P_INVENTORY_ITEM_ID           IN   NUMBER,
      P_ITEM_CATALOG_GROUP_ID       IN   NUMBER,
      P_COMMIT                      IN  VARCHAR2   DEFAULT  G_FALSE,
      X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
      X_MSG_COUNT                   OUT NOCOPY NUMBER);

   FUNCTION Get_Master_Organization_Id(
      P_ORGANIZATION_ID  IN NUMBER) RETURN NUMBER;

   FUNCTION Get_Item_Attr_Control_Level(
      P_ITEM_ATTRIBUTE IN VARCHAR2) RETURN NUMBER;

   FUNCTION Get_Item_Count (
      p_catalog_group_id IN NUMBER,
      p_organization_id IN NUMBER) RETURN NUMBER;

   FUNCTION Get_Category_Item_Count(
      P_CATEGORY_SET_ID IN NUMBER,
      p_CATEGORY_ID     IN NUMBER,
      P_ORGANIZATION_ID IN NUMBER) RETURN NUMBER;

   FUNCTION Get_Category_Hierarchy_Names(
      P_CATEGORY_SET_ID IN NUMBER,
      P_CATEGORY_ID     IN NUMBER) RETURN VARCHAR2;

   -- Added for bug 3781216
   PROCEDURE Apply_Templ_User_Attrs_To_Item (
      p_api_version                   IN   NUMBER
     ,p_mode                          IN   VARCHAR2
     ,p_item_id                       IN   NUMBER
     ,p_organization_id               IN   NUMBER
     ,p_template_id                   IN   NUMBER
     ,p_object_name                   IN   VARCHAR2
     ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
     ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
     ,x_return_status                 OUT NOCOPY VARCHAR2
     ,x_errorcode                     OUT NOCOPY NUMBER
     ,x_msg_count                     OUT NOCOPY NUMBER
     ,x_msg_data                      OUT NOCOPY VARCHAR2);

     PROCEDURE SYNC_IM_INDEX;

/*#
 * Use this API to create, update, or delete one role grant either
 * on an item or on an existing instance set.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_transaction_type Valid values are G_TTYPE_CREATE,
 * G_TTYPE_UPDATE, and G_TTYPE_DELETE.
 * @param p_instance_type Valid values are G_INSTANCE_TYPE_INSTANCE
 * and G_INSTANCE_TYPE_SET.
 * @param p_party_type Valid values are G_USER_PARTY_TYPE,
 * G_GROUP_PARTY_TYPE, G_COMPANY_PARTY_TYPE, and G_ALL_USERS_PARTY_TYPE.
 * @param x_grant_guid Unique identifier of the grant; primary key for FND_GRANTS.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Role
 */
   PROCEDURE Process_item_role
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_transaction_type      IN  VARCHAR2  DEFAULT  G_TTYPE_CREATE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_role_id               IN  NUMBER    DEFAULT  NULL
      ,p_role_name             IN  VARCHAR2  DEFAULT  NULL
      ,p_instance_type         IN  VARCHAR2  DEFAULT  G_INSTANCE_TYPE_INSTANCE
      ,p_instance_set_id       IN  NUMBER    DEFAULT  NULL
      ,p_instance_set_name     IN  VARCHAR2  DEFAULT  NULL
      ,p_party_type            IN  VARCHAR2  DEFAULT  G_USER_PARTY_TYPE
      ,p_party_id              IN  NUMBER    DEFAULT  NULL
      ,p_party_name            IN  VARCHAR2  DEFAULT  NULL
      ,p_start_date            IN  DATE      DEFAULT  NULL
      ,p_end_date              IN  DATE      DEFAULT  NULL
      ,x_grant_guid            IN  OUT NOCOPY RAW
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );

/*#
 * Use this API to either change the status of an item or promote/demote
 * the lifecycle of an item/item revision.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_transaction_type Valid values are G_TTYPE_UPDATE and
 * G_TTYPE_DELETE to modify an existing pending change, G_TTYPE_PROMOTE
 * and G_TTYPE_DEMOTE to change the phase of an item/item revision, or
 * G_TTYPE_CHANGE_STATUS to change the item status. G_TTYPE_CHANGE_PHASE is used
 * to change to the lifecycle phase p_phase_id, only promotes are allowed
 * @param p_revision Revison code.
 * @param p_implement_changes The API always creates a pending
 * phase/status change; in addition, it can also implement all
 * pending changes for this item whose effective date is prior
 * to SYSDATE.  Valid values are G_TRUE and G_FALSE.
 * @param p_status Status to which the item should be changed.
 * @param p_effective_date Date on or after which the phase/status
 * change can be implemented.
 * @param p_phase_id Primary key of the phase to which item should
 * be changed.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Phase and Status
 */
   PROCEDURE Process_item_phase_and_status
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_transaction_type      IN  VARCHAR2  DEFAULT  G_TTYPE_PROMOTE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_revision_id           IN  NUMBER    DEFAULT  NULL
      ,p_revision              IN  VARCHAR2  DEFAULT  NULL
      ,p_implement_changes     IN  VARCHAR2  DEFAULT  G_TRUE
      ,p_status                IN  VARCHAR2  DEFAULT  NULL
      ,p_effective_date        IN  DATE      DEFAULT  NULL
      ,p_lifecycle_id          IN  NUMBER    DEFAULT  NULL
      ,p_phase_id              IN  NUMBER    DEFAULT  NULL
      ,p_new_effective_date    IN  DATE      DEFAULT  NULL
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );

/*#
 * Use this API to implement pending phase and/or status changes
 * for an item/item revision.  The procedure implements all pending
 * changes for the item/item revision whose effective dates are prior
 * to SYSDATE.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_revision Revison code.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Implement Item Pending Changes
 */
   PROCEDURE Implement_Item_Pending_Changes
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_revision_id           IN  NUMBER    DEFAULT  NULL
      ,p_revision              IN  VARCHAR2  DEFAULT  NULL
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     );

/*#
 * Use this API to create a new item revision or update an existing
 * item revision.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_transaction_type Valid values are G_TTYPE_CREATE and
 * G_TTYPE_UPDATE.
 * @param p_item_number Either Item Number or Inventory Item ID
 * should be passed.
 * @p_Organization_Code Either Org Code or Organization ID should
 * be passed.
 * @param p_description The revision's description.
 * @param p_effectivity_date The revision's effectivity date.
 * @param p_lifecycle_id <B>DEPRECATED.</B>  This parameter
 * should not be used.
 * @param p_current_phase_id The revision's lifecycle phase ID.
 * @param p_attribute_category The revision's Descriptive
 * Flexfield (DFF) Context Field.
 * @param p_attribute1 Revision Descriptive Flexfield's Attribute1.
 * @param p_attribute2 Revision Descriptive Flexfield's Attribute2.
 * @param p_attribute3 Revision Descriptive Flexfield's Attribute3.
 * @param p_attribute4 Revision Descriptive Flexfield's Attribute4.
 * @param p_attribute5 Revision Descriptive Flexfield's Attribute5.
 * @param p_attribute6 Revision Descriptive Flexfield's Attribute6.
 * @param p_attribute7 Revision Descriptive Flexfield's Attribute7.
 * @param p_attribute8 Revision Descriptive Flexfield's Attribute8.
 * @param p_attribute9 Revision Descriptive Flexfield's Attribute9.
 * @param p_attribute10 Revision Descriptive Flexfield's Attribute10.
 * @param p_attribute11 Revision Descriptive Flexfield's Attribute11.
 * @param p_attribute12 Revision Descriptive Flexfield's Attribute12.
 * @param p_attribute13 Revision Descriptive Flexfield's Attribute13.
 * @param p_attribute14 Revision Descriptive Flexfield's Attribute14.
 * @param p_attribute15 Revision Descriptive Flexfield's Attribute15.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Revision
 */

PROCEDURE Process_Item_Revision(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 :=  FND_API.G_TRUE
 ,p_commit                       IN VARCHAR2   DEFAULT  G_FALSE
 ,p_transaction_type             IN VARCHAR2
 ,p_inventory_item_id            IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_item_number                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_organization_id              IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_Organization_Code            IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_revision                     IN VARCHAR2
 ,p_description                  IN VARCHAR2   DEFAULT  NULL
 ,p_effectivity_date             IN DATE
 ,p_revision_label               IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_revision_reason              IN VARCHAR2   DEFAULT  NULL
 ,p_lifecycle_id                 IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_current_phase_id             IN NUMBER     DEFAULT  G_MISS_NUM
  -- 5208102: Supporting template for UDA's at revisions
 ,p_template_id                  IN   NUMBER   DEFAULT  G_MISS_NUM
 ,p_template_name                IN   VARCHAR2 DEFAULT  G_MISS_CHAR

 ,p_attribute_category           IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute1                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute2                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute3                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute4                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute5                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute6                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute7                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute8                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute9                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute10                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute11                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute12                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute13                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute14                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute15                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,x_Return_Status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2);

------------------------ Process_item_descr_elements ---------------------
/*#
 * Use this API to set the values of item catalog category descriptive
 * elements (if the calling user has permission to edit the item).
 * The table type passed in p_item_desc_element_table is as follows:
 *<code><pre>
  TYPE Item_Desc_Element_Table IS TABLE OF Item_Desc_Element
    INDEX BY BINARY_INTEGER;

  TYPE Item_Desc_Element IS RECORD
  (
    ELEMENT_NAME        VARCHAR2(30)
   ,ELEMENT_VALUE       VARCHAR2(30)
   ,DESCRIPTION_DEFAULT VARCHAR2(1)
  );
 *</pre></code>
 * In this record, DESCRIPTION_DEFAULT indicates whether the element
 * value should be defaulted into the Item Description.  Valid values
 * are 'Y' and 'N'.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit_flag A flag indicating whether to commit work
 * at the end of API processing.  Refer to the package description
 * of the parameter 'p_commit' above for more information about
 * this parameter and a list of valid values.
 * @param p_validation_level <B>DEPRECATED.</B>  This parameter
 * should not be used.
 * @param p_inventory_item_id Item ID of the item to which these
 * descriptive element values apply.
 * @param p_item_number Item Number of the item to which these
 * descriptive element values apply.
 * @param p_item_desc_element_table Each record in this PL/SQL table
 * corresponds to one descriptive element to be created or updated;
 * refer to API description for the record type declaration.
 * @param x_generated_descr Returns the newly generated item
 * description, if DESCRIPTION_DEFAULT was passed as 'Y' for at least
 * one descriptive element passed in p_item_desc_element_table.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Descriptive Element Values
 */

   PROCEDURE Process_item_descr_elements
     (
        p_api_version        IN   NUMBER
     ,  p_init_msg_list      IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
     ,  p_commit_flag        IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
     ,  p_validation_level   IN   NUMBER    DEFAULT  INV_ITEM_CATALOG_ELEM_PUB.g_VALIDATE_ALL
     ,  p_inventory_item_id  IN   NUMBER    DEFAULT  -999
     ,  p_item_number        IN   VARCHAR2  DEFAULT  NULL
     ,  p_item_desc_element_table IN INV_ITEM_CATALOG_ELEM_PUB.ITEM_DESC_ELEMENT_TABLE
     ,  x_generated_descr    OUT NOCOPY VARCHAR2
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     );


------------------------ Process_Item_Cat_Assignment ---------------------
/*#
 * Use this API to assign/remove a catalog/category to/from an
 * item (if the calling user has permission to edit the item).
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_init_msg_list A flag indicating whether to initialize
 * the FND_MSG_PUB package's message stack.  Refer to the package
 * description above for more information about this parameter and
 * a list of valid values.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_category_id Catalog/Category ID to be assigned/removed.
 * @param p_old_category_id Old category ID to be unassigned
 * @param p_category_set_id Category Set/Catalog Category ID to
 * which Catalog/Category passed in p_category_id belongs.
 * @param p_transaction_type Valid values are G_TTYPE_CREATE and
 * G_TTYPE_DELETE, G_TTYPE_UPDATE
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Category/Catalog Assignments
 */
PROCEDURE Process_Item_Cat_Assignment
     (
        p_api_version       IN   NUMBER
      , p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE
      , p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE
      , p_category_id       IN   NUMBER
      , p_category_set_id   IN   NUMBER
      , p_old_category_id   IN   NUMBER   DEFAULT NULL        --- added bug bug 10091928
      , p_inventory_item_id IN   NUMBER
      , p_organization_id   IN   NUMBER
      , p_transaction_type  IN   VARCHAR2
      , x_return_status     OUT  NOCOPY VARCHAR2
      , x_errorcode         OUT  NOCOPY NUMBER
      , x_msg_count         OUT  NOCOPY NUMBER
      , x_msg_data          OUT  NOCOPY VARCHAR2
     );

/*#
 * Use this API to add/update/delete GDSN Attributes of an item
 * (if the calling user has permission to edit the item).
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_commit A flag indicating whether to commit work at the
 * end of API processing.  Refer to the package description above
 * for more information about this parameter and a list of valid
 * values.
 * @param p_inventory_item_id Item ID of the item to which these
 * GDSN Attribute values apply.
 * @param p_organization_id Organization ID of the Item to
 * be processed.
 * @param p_single_row_attrs_rec Record containing all single row
 * GDSN attributes. User must populate this record to process
 * GDSN single row attributes.
 * @param p_multi_row_attrs_table Table of Record containing all
 * multi row GDSN attributes. User must populate this table to process
 * GDSN multi row attributes.
 * @param p_entity_id Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_index Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_entity_code Used in error reporting; refer to ERROR_HANDLER
 * for details.
 * @param p_init_error_handler Indicates whether to initialize
 * ERROR_HANDLER message stack (and open debug session, if applicable).
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to the package description above for more
 * information about this parameter.
 * @param x_msg_data A character string containing message text.
 * Refer to the package description above for more information
 * about this parameter and a list of valid values.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process GDSN Attributes For an Item.
 */
PROCEDURE Process_UCCnet_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_single_row_attrs_rec          IN   UCCnet_Attrs_Singl_Row_Rec_Typ
       ,p_multi_row_attrs_table         IN   UCCnet_Attrs_Multi_Row_Tbl_Typ
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

/*#
 * Use this API to validate required attributes for an item.
 * The API returns the list of required attributes having null values
 * for the item.
 * @param p_api_version A decimal number indicating revisions to
 * the API.  Pass the number indicated in the package description
 * above.
 * @param p_inventory_item_id Item ID
 * @param p_organization_id Item organization ID.
 * @param p_revision_id Item revision ID
 * @param x_attributes_req_table Contains metadata about each
 * attribute in each attribute group row for an item being validated.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Required Attributes For Item
 */
PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_revision_id                   IN   NUMBER DEFAULT NULL
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*#
 * <b>Import Workbench</b>
 * Call this API to complete the loading, via custom methods such as SQL script,
 * of data into the INV and EGO open interface tables for items and child entities.
 * This API prepares the newly loaded data for display in the Import Workbench
 * HTML UI. Note that this API only prepares the batch data for UI display and does
 * not attempt to import these records into production tables.
 * The API is reentrant: it can be called repeatedly for the same batch.
 *
 * @param p_api_version A decimal number indicating revisions to
 * the API. Pass the number indicated in the package description
 * above.
 * @param p_batch_id Import Batch ID. This parameter cannot be null.
 * @param x_return_status A code indicating whether any errors
 * occurred during processing.  Refer to the package description
 * above for more information about this parameter and a list of
 * valid values.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Prepare Batch Data For Import UI
 */
PROCEDURE Prep_Batch_Data_For_Import_UI
    (   p_api_version           IN          NUMBER
    ,   p_batch_id              IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_errorcode             OUT NOCOPY  NUMBER
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
    );


END EGO_ITEM_PUB;

/
