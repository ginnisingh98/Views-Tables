--------------------------------------------------------
--  DDL for Package Body EGO_UI_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UI_ITEM_PUB" AS
/* $Header: EGOITUIB.pls 115.40 2004/06/07 00:11:16 absinha noship $ */

G_FILE_NAME               CONSTANT  VARCHAR2(12)  := 'EGOITUIB.pls';
G_PKG_NAME                CONSTANT  VARCHAR2(30)  := 'EGO_UI_ITEM_PUB';
G_CREATE_TRANSACTION_TYPE CONSTANT  VARCHAR2(10)  := 'CREATE';
G_UPDATE_TRANSACTION_TYPE CONSTANT  VARCHAR2(10)  := 'UPDATE';
G_COPY_TRANSACTION_TYPE   CONSTANT  VARCHAR2(10)  := 'COPY';
G_OBJECT_NAME             CONSTANT  VARCHAR2(10)  := 'EGO_ITEM';

-- =============================================================================
--                         Package variables and cursors
-- =============================================================================

g_USER_ID       NUMBER  :=  FND_GLOBAL.User_Id;
g_LOGIN_ID      NUMBER  :=  FND_GLOBAL.Conc_Login_Id;

-- the below variables are used for copy item
g_in_item_tbl     EGO_ITEM_PUB.ITEM_TBL_TYPE;
g_out_item_tbl    EGO_ITEM_PUB.ITEM_TBL_TYPE;
-- end of global variables for copy_item_functionality

--g_MISS_CHAR     VARCHAR2(1)  :=  FND_API.g_MISS_CHAR;
--g_MISS_NUM      NUMBER       :=  FND_API.g_MISS_NUM;
--g_MISS_DATE     DATE         :=  FND_API.g_MISS_DATE;

-- =============================================================================
--                                  Procedures
-- =============================================================================

--
-- Capture the sysdate at once for the whole process. During the process we use
-- sysdate in many places for compare, insert and update. It is essential that
-- we deal with the same sysdate value. Date will be assigned in the entry procedure.
--
G_Sysdate               DATE;

   CURSOR org_item_exists_cur
   (  p_inventory_item_id    NUMBER
   ,  p_organization_id      NUMBER
   ) IS
      SELECT 'x'
      FROM  mtl_system_items_b
      WHERE
              inventory_item_id = p_inventory_item_id
      AND  organization_id   = p_organization_id;

-- Developer debugging
-- Should be set to false when arcing in.
msg_line_no            NUMBER := -1000;


PROCEDURE developer_debug (p_msg  IN  VARCHAR2) IS
--Modified for Debug purpose for Bug 2960442
BEGIN
--   msg_line_no := msg_line_no + 1;
--   INSERT INTO IDC_ITEM_DEBUG VALUES (msg_line_no||p_msg||TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS'));
--  debug (p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;


 PROCEDURE initialize_item_info (p_inventory_item_id  IN  NUMBER
                                 ,p_organization_id    IN  NUMBER
                                 ,x_return_status      OUT  NOCOPY VARCHAR2
                                 ,x_msg_count          OUT  NOCOPY NUMBER
                                 ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : Initialize_item_info
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  : Initialize the Item record with the values of the
  --             item_id (p_inventory_item_id) and Org Id (p_Organization_id)
  --
  -- Parameters:
  --     IN    : p_inventory_item_id     IN  NUMBER     (required)
  --           : p_organization_id       IN  NUMBER     (required)
  --
  --
  --    OUT    : x_return_status        OUT  VARCHAR2
  --             x_msg_count            OUT  NUMBER
  --
  ----------------------------------------------------------------------------

    CURSOR c_copy_item_info (cp_inventory_item_id IN  NUMBER
                            ,cp_organization_id   IN  NUMBER ) IS
    SELECT *
    FROM mtl_system_items_b
    WHERE inventory_item_id = cp_inventory_item_id
      AND organization_id   = cp_organization_id;

    l_orig_item_rec   MTL_SYSTEM_ITEMS_B%ROWTYPE;

  BEGIN
    developer_debug ('::2960442::initialize_item_info::start');
    OPEN c_copy_item_info (cp_inventory_item_id => p_inventory_item_id
                          ,cp_organization_id   => p_organization_id);
    FETCH c_copy_item_info into l_orig_item_rec;
    IF c_copy_item_info%NOTFOUND THEN
    developer_debug (' Invalid item informatin passed');
      -- no items found to copy from
      EGO_Item_Msg.Add_Error_Message
           (p_entity_index           => 1
           ,p_application_short_name => 'EGO'
           ,p_message_name           => 'EGO_IPI_INVALID_ITEM'
           ,p_token_name1            => 'ITEM'
           ,p_token_value1           => p_inventory_item_id
           ,p_translate1             => FALSE
           ,p_token_name2            => 'ORGANIZATION'
           ,p_token_value2           => p_organization_id
           ,p_translate2             => FALSE
           ,p_token_name3            => NULL
           ,p_token_value3           => NULL
           ,p_translate3             => FALSE
           );
      x_return_status := G_RET_STS_ERROR;
      RETURN;
    END IF;
  -- TODO get inputs from Murthy regarding which columns are not available in FORMS
  -- and reset them to
    -- all the item info available in the record
    g_in_item_tbl(0).transaction_type      := NULL;
    g_in_item_tbl(0).Return_Status         := NULL;
    g_in_item_tbl(0).transaction_type      := NULL;
    g_in_item_tbl(0).Language_Code         := NULL;
    g_in_item_tbl(0).Template_Id           := NULL;
    g_in_item_tbl(0).Template_Name         := NULL;
    g_in_item_tbl(0).Inventory_Item_Id     := NULL;
    g_in_item_tbl(0).Item_Number           := NULL;
    g_in_item_tbl(0).segment1              := NULL;
    g_in_item_tbl(0).segment2              := NULL;
    g_in_item_tbl(0).segment3              := NULL;
    g_in_item_tbl(0).segment4              := NULL;
    g_in_item_tbl(0).segment5              := NULL;
    g_in_item_tbl(0).segment6              := NULL;
    g_in_item_tbl(0).segment7              := NULL;
    g_in_item_tbl(0).segment8              := NULL;
    g_in_item_tbl(0).segment9              := NULL;
    g_in_item_tbl(0).segment10             := NULL;
    g_in_item_tbl(0).segment11             := NULL;
    g_in_item_tbl(0).segment12             := NULL;
    g_in_item_tbl(0).segment13             := NULL;
    g_in_item_tbl(0).segment14             := NULL;
    g_in_item_tbl(0).segment15             := NULL;
    g_in_item_tbl(0).segment16             := NULL;
    g_in_item_tbl(0).segment17             := NULL;
    g_in_item_tbl(0).segment18             := NULL;
    g_in_item_tbl(0).segment19             := NULL;
    g_in_item_tbl(0).segment20             := NULL;
    g_in_item_tbl(0).summary_flag          := l_orig_item_rec.SUMMARY_FLAG;
    g_in_item_tbl(0).Organization_Id       := NULL;
    g_in_item_tbl(0).Organization_Code     := NULL;
    g_in_item_tbl(0).Item_Catalog_Group_Id := NULL;
    g_in_item_tbl(0).Catalog_Status_Flag   := NULL;
    g_in_item_tbl(0).Lifecycle_Id          := NULL;
    g_in_item_tbl(0).Current_Phase_Id      := NULL;
    g_in_item_tbl(0).Description           := NULL;
    g_in_item_tbl(0).Long_Description      := NULL;
    g_in_item_tbl(0).Primary_Uom_Code      := NULL;
    g_in_item_tbl(0).ALLOWED_UNITS_LOOKUP_CODE     := l_orig_item_rec.allowed_units_lookup_code;
    g_in_item_tbl(0).Inventory_Item_Status_Code    := NULL;
    g_in_item_tbl(0).DUAL_UOM_CONTROL              := l_orig_item_rec.DUAL_UOM_CONTROL;
    g_in_item_tbl(0).SECONDARY_UOM_CODE            := l_orig_item_rec.SECONDARY_UOM_CODE;
    g_in_item_tbl(0).DUAL_UOM_DEVIATION_HIGH       := l_orig_item_rec.DUAL_UOM_DEVIATION_HIGH;
    g_in_item_tbl(0).DUAL_UOM_DEVIATION_LOW        := l_orig_item_rec.DUAL_UOM_DEVIATION_LOW;
    g_in_item_tbl(0).ITEM_TYPE                     := l_orig_item_rec.ITEM_TYPE;
 -- Inventory
    g_in_item_tbl(0).INVENTORY_ITEM_FLAG           := l_orig_item_rec.INVENTORY_ITEM_FLAG;
    g_in_item_tbl(0).STOCK_ENABLED_FLAG            := l_orig_item_rec.STOCK_ENABLED_FLAG;
    g_in_item_tbl(0).MTL_TRANSACTIONS_ENABLED_FLAG := l_orig_item_rec.MTL_TRANSACTIONS_ENABLED_FLAG;
    g_in_item_tbl(0).REVISION_QTY_CONTROL_CODE     := l_orig_item_rec.REVISION_QTY_CONTROL_CODE;
    g_in_item_tbl(0).LOT_CONTROL_CODE              := l_orig_item_rec.LOT_CONTROL_CODE;
    g_in_item_tbl(0).AUTO_LOT_ALPHA_PREFIX         := l_orig_item_rec.AUTO_LOT_ALPHA_PREFIX;
    g_in_item_tbl(0).START_AUTO_LOT_NUMBER         := l_orig_item_rec.START_AUTO_LOT_NUMBER;
    g_in_item_tbl(0).SERIAL_NUMBER_CONTROL_CODE    := l_orig_item_rec.SERIAL_NUMBER_CONTROL_CODE;
    g_in_item_tbl(0).AUTO_SERIAL_ALPHA_PREFIX      := l_orig_item_rec.AUTO_SERIAL_ALPHA_PREFIX;
    g_in_item_tbl(0).START_AUTO_SERIAL_NUMBER      := l_orig_item_rec.START_AUTO_SERIAL_NUMBER;
    g_in_item_tbl(0).SHELF_LIFE_CODE               := l_orig_item_rec.SHELF_LIFE_CODE;
    g_in_item_tbl(0).SHELF_LIFE_DAYS               := l_orig_item_rec.SHELF_LIFE_DAYS;
    g_in_item_tbl(0).RESTRICT_SUBINVENTORIES_CODE  := l_orig_item_rec.RESTRICT_SUBINVENTORIES_CODE;
    g_in_item_tbl(0).LOCATION_CONTROL_CODE         := l_orig_item_rec.LOCATION_CONTROL_CODE;
    g_in_item_tbl(0).RESTRICT_LOCATORS_CODE        := l_orig_item_rec.RESTRICT_LOCATORS_CODE;
    g_in_item_tbl(0).RESERVABLE_TYPE               := l_orig_item_rec.RESERVABLE_TYPE;
    g_in_item_tbl(0).CYCLE_COUNT_ENABLED_FLAG      := l_orig_item_rec.CYCLE_COUNT_ENABLED_FLAG;
    g_in_item_tbl(0).NEGATIVE_MEASUREMENT_ERROR    := l_orig_item_rec.NEGATIVE_MEASUREMENT_ERROR;
    g_in_item_tbl(0).POSITIVE_MEASUREMENT_ERROR    := l_orig_item_rec.POSITIVE_MEASUREMENT_ERROR;
    g_in_item_tbl(0).CHECK_SHORTAGES_FLAG          := l_orig_item_rec.CHECK_SHORTAGES_FLAG;
    g_in_item_tbl(0).LOT_STATUS_ENABLED            := l_orig_item_rec.LOT_STATUS_ENABLED;
    g_in_item_tbl(0).DEFAULT_LOT_STATUS_ID         := l_orig_item_rec.DEFAULT_LOT_STATUS_ID;
    g_in_item_tbl(0).SERIAL_STATUS_ENABLED         := l_orig_item_rec.SERIAL_STATUS_ENABLED;
    g_in_item_tbl(0).DEFAULT_SERIAL_STATUS_ID      := l_orig_item_rec.DEFAULT_SERIAL_STATUS_ID;
    g_in_item_tbl(0).LOT_SPLIT_ENABLED             := l_orig_item_rec.LOT_SPLIT_ENABLED;
    g_in_item_tbl(0).LOT_MERGE_ENABLED             := l_orig_item_rec.LOT_MERGE_ENABLED;
    g_in_item_tbl(0).LOT_TRANSLATE_ENABLED         := l_orig_item_rec.LOT_TRANSLATE_ENABLED;
    g_in_item_tbl(0).BULK_PICKED_FLAG              := l_orig_item_rec.BULK_PICKED_FLAG;
    g_in_item_tbl(0).LOT_SUBSTITUTION_ENABLED      := l_orig_item_rec.LOT_SUBSTITUTION_ENABLED;
 -- Bills of Material
    g_in_item_tbl(0).BOM_ITEM_TYPE                 := l_orig_item_rec.BOM_ITEM_TYPE;
    g_in_item_tbl(0).BOM_ENABLED_FLAG              := l_orig_item_rec.BOM_ENABLED_FLAG;
    g_in_item_tbl(0).BASE_ITEM_ID                  := l_orig_item_rec.BASE_ITEM_ID;
    g_in_item_tbl(0).ENG_ITEM_FLAG                 := l_orig_item_rec.ENG_ITEM_FLAG;
    g_in_item_tbl(0).ENGINEERING_ITEM_ID           := l_orig_item_rec.ENGINEERING_ITEM_ID;
    g_in_item_tbl(0).ENGINEERING_ECN_CODE          := l_orig_item_rec.ENGINEERING_ECN_CODE;
    g_in_item_tbl(0).ENGINEERING_DATE              := l_orig_item_rec.ENGINEERING_DATE;
    g_in_item_tbl(0).EFFECTIVITY_CONTROL           := l_orig_item_rec.EFFECTIVITY_CONTROL;
-- already commented out    --,  CONFIG_MODEL_TYPE                  VARCHAR2(30)    :=  FND_API.g_MISS_CHAR
    g_in_item_tbl(0).Product_Family_Item_Id        := l_orig_item_rec.Product_Family_Item_Id;
 -- Costing
    g_in_item_tbl(0).COSTING_ENABLED_FLAG          := l_orig_item_rec.COSTING_ENABLED_FLAG;
    g_in_item_tbl(0).INVENTORY_ASSET_FLAG          := l_orig_item_rec.INVENTORY_ASSET_FLAG;
    g_in_item_tbl(0).COST_OF_SALES_ACCOUNT         := l_orig_item_rec.COST_OF_SALES_ACCOUNT;
    g_in_item_tbl(0).DEFAULT_INCLUDE_IN_ROLLUP_FLAG   := l_orig_item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG;
    g_in_item_tbl(0).STD_LOT_SIZE                  := l_orig_item_rec.STD_LOT_SIZE;
    g_in_item_tbl(0).CONFIG_MODEL_TYPE             := l_orig_item_rec.CONFIG_MODEL_TYPE;
 -- Enterprise Asset Management
    g_in_item_tbl(0).EAM_ITEM_TYPE                 := l_orig_item_rec.EAM_ITEM_TYPE;
    g_in_item_tbl(0).EAM_ACTIVITY_TYPE_CODE        := l_orig_item_rec.EAM_ACTIVITY_TYPE_CODE;
    g_in_item_tbl(0).EAM_ACTIVITY_CAUSE_CODE       := l_orig_item_rec.EAM_ACTIVITY_CAUSE_CODE;
    g_in_item_tbl(0).EAM_ACT_SHUTDOWN_STATUS       := l_orig_item_rec.EAM_ACT_SHUTDOWN_STATUS;
    g_in_item_tbl(0).EAM_ACT_NOTIFICATION_FLAG     := l_orig_item_rec.EAM_ACT_NOTIFICATION_FLAG;
    g_in_item_tbl(0).EAM_ACTIVITY_SOURCE_CODE      := l_orig_item_rec.EAM_ACTIVITY_SOURCE_CODE;
 -- Purchasing
    g_in_item_tbl(0).PURCHASING_ITEM_FLAG          := l_orig_item_rec.PURCHASING_ITEM_FLAG;
    g_in_item_tbl(0).PURCHASING_ENABLED_FLAG       := l_orig_item_rec.PURCHASING_ENABLED_FLAG;
    g_in_item_tbl(0).BUYER_ID                      := l_orig_item_rec.BUYER_ID;
    g_in_item_tbl(0).MUST_USE_APPROVED_VENDOR_FLAG := l_orig_item_rec.MUST_USE_APPROVED_VENDOR_FLAG;
    g_in_item_tbl(0).PURCHASING_TAX_CODE           := l_orig_item_rec.PURCHASING_TAX_CODE;
    g_in_item_tbl(0).TAXABLE_FLAG                  := l_orig_item_rec.TAXABLE_FLAG;
    g_in_item_tbl(0).RECEIVE_CLOSE_TOLERANCE       := l_orig_item_rec.RECEIVE_CLOSE_TOLERANCE;
    g_in_item_tbl(0).ALLOW_ITEM_DESC_UPDATE_FLAG   := l_orig_item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG;
    g_in_item_tbl(0).INSPECTION_REQUIRED_FLAG      := l_orig_item_rec.INSPECTION_REQUIRED_FLAG;
    g_in_item_tbl(0).RECEIPT_REQUIRED_FLAG         := l_orig_item_rec.RECEIPT_REQUIRED_FLAG;
    g_in_item_tbl(0).MARKET_PRICE                  := l_orig_item_rec.MARKET_PRICE;
    g_in_item_tbl(0).UN_NUMBER_ID                  := l_orig_item_rec.UN_NUMBER_ID;
    g_in_item_tbl(0).HAZARD_CLASS_ID               := l_orig_item_rec.HAZARD_CLASS_ID;
    g_in_item_tbl(0).RFQ_REQUIRED_FLAG             := l_orig_item_rec.RFQ_REQUIRED_FLAG;
    g_in_item_tbl(0).LIST_PRICE_PER_UNIT           := l_orig_item_rec.LIST_PRICE_PER_UNIT;
    g_in_item_tbl(0).PRICE_TOLERANCE_PERCENT       := l_orig_item_rec.PRICE_TOLERANCE_PERCENT;
    g_in_item_tbl(0).ASSET_CATEGORY_ID             := l_orig_item_rec.ASSET_CATEGORY_ID;
    g_in_item_tbl(0).ROUNDING_FACTOR               := l_orig_item_rec.ROUNDING_FACTOR;
    g_in_item_tbl(0).UNIT_OF_ISSUE                 := l_orig_item_rec.UNIT_OF_ISSUE;
    g_in_item_tbl(0).OUTSIDE_OPERATION_FLAG        := l_orig_item_rec.OUTSIDE_OPERATION_FLAG;
    g_in_item_tbl(0).OUTSIDE_OPERATION_UOM_TYPE    := l_orig_item_rec.OUTSIDE_OPERATION_UOM_TYPE;
    g_in_item_tbl(0).INVOICE_CLOSE_TOLERANCE       := l_orig_item_rec.INVOICE_CLOSE_TOLERANCE;
    g_in_item_tbl(0).ENCUMBRANCE_ACCOUNT           := l_orig_item_rec.ENCUMBRANCE_ACCOUNT;
    g_in_item_tbl(0).EXPENSE_ACCOUNT               := l_orig_item_rec.EXPENSE_ACCOUNT;
    g_in_item_tbl(0).QTY_RCV_EXCEPTION_CODE        := l_orig_item_rec.QTY_RCV_EXCEPTION_CODE;
    g_in_item_tbl(0).RECEIVING_ROUTING_ID          := l_orig_item_rec.RECEIVING_ROUTING_ID;
    g_in_item_tbl(0).QTY_RCV_TOLERANCE             := l_orig_item_rec.QTY_RCV_TOLERANCE;
    g_in_item_tbl(0).ENFORCE_SHIP_TO_LOCATION_CODE   := l_orig_item_rec.ENFORCE_SHIP_TO_LOCATION_CODE;
    g_in_item_tbl(0).ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := l_orig_item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
    g_in_item_tbl(0).ALLOW_UNORDERED_RECEIPTS_FLAG   := l_orig_item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
    g_in_item_tbl(0).ALLOW_EXPRESS_DELIVERY_FLAG     := l_orig_item_rec.ALLOW_EXPRESS_DELIVERY_FLAG;
    g_in_item_tbl(0).DAYS_EARLY_RECEIPT_ALLOWED      := l_orig_item_rec.DAYS_EARLY_RECEIPT_ALLOWED;
    g_in_item_tbl(0).DAYS_LATE_RECEIPT_ALLOWED       := l_orig_item_rec.DAYS_LATE_RECEIPT_ALLOWED;
    g_in_item_tbl(0).RECEIPT_DAYS_EXCEPTION_CODE     := l_orig_item_rec.RECEIPT_DAYS_EXCEPTION_CODE;
 -- Physical
    g_in_item_tbl(0).WEIGHT_UOM_CODE               := l_orig_item_rec.WEIGHT_UOM_CODE;
    g_in_item_tbl(0).UNIT_WEIGHT                   := l_orig_item_rec.UNIT_WEIGHT;
    g_in_item_tbl(0).VOLUME_UOM_CODE               := l_orig_item_rec.VOLUME_UOM_CODE;
    g_in_item_tbl(0).UNIT_VOLUME                   := l_orig_item_rec.UNIT_VOLUME;
    g_in_item_tbl(0).CONTAINER_ITEM_FLAG           := l_orig_item_rec.CONTAINER_ITEM_FLAG;
    g_in_item_tbl(0).VEHICLE_ITEM_FLAG             := l_orig_item_rec.VEHICLE_ITEM_FLAG;
    g_in_item_tbl(0).MAXIMUM_LOAD_WEIGHT           := l_orig_item_rec.MAXIMUM_LOAD_WEIGHT;
    g_in_item_tbl(0).MINIMUM_FILL_PERCENT          := l_orig_item_rec.MINIMUM_FILL_PERCENT;
    g_in_item_tbl(0).INTERNAL_VOLUME               := l_orig_item_rec.INTERNAL_VOLUME;
    g_in_item_tbl(0).CONTAINER_TYPE_CODE           := l_orig_item_rec.CONTAINER_TYPE_CODE;
    g_in_item_tbl(0).COLLATERAL_FLAG               := l_orig_item_rec.COLLATERAL_FLAG;
    g_in_item_tbl(0).EVENT_FLAG                    := l_orig_item_rec.EVENT_FLAG;
    g_in_item_tbl(0).EQUIPMENT_TYPE                := l_orig_item_rec.EQUIPMENT_TYPE;
    g_in_item_tbl(0).ELECTRONIC_FLAG               := l_orig_item_rec.ELECTRONIC_FLAG;
    g_in_item_tbl(0).DOWNLOADABLE_FLAG             := l_orig_item_rec.DOWNLOADABLE_FLAG;
    g_in_item_tbl(0).INDIVISIBLE_FLAG              := l_orig_item_rec.INDIVISIBLE_FLAG;
    g_in_item_tbl(0).DIMENSION_UOM_CODE            := l_orig_item_rec.DIMENSION_UOM_CODE;
    g_in_item_tbl(0).UNIT_LENGTH                   := l_orig_item_rec.UNIT_LENGTH;
    g_in_item_tbl(0).UNIT_WIDTH                    := l_orig_item_rec.UNIT_WIDTH;
    g_in_item_tbl(0).UNIT_HEIGHT                   := l_orig_item_rec.UNIT_HEIGHT;
 --
    g_in_item_tbl(0).INVENTORY_PLANNING_CODE       := l_orig_item_rec.INVENTORY_PLANNING_CODE;
    g_in_item_tbl(0).PLANNER_CODE                  := l_orig_item_rec.PLANNER_CODE;
    g_in_item_tbl(0).PLANNING_MAKE_BUY_CODE        := l_orig_item_rec.PLANNING_MAKE_BUY_CODE;
    g_in_item_tbl(0).MIN_MINMAX_QUANTITY           := l_orig_item_rec.MIN_MINMAX_QUANTITY;
    g_in_item_tbl(0).MAX_MINMAX_QUANTITY           := l_orig_item_rec.MAX_MINMAX_QUANTITY;
    g_in_item_tbl(0).SAFETY_STOCK_BUCKET_DAYS      := l_orig_item_rec.SAFETY_STOCK_BUCKET_DAYS;
    g_in_item_tbl(0).CARRYING_COST                 := FND_API.G_MISS_NUM;
    g_in_item_tbl(0).ORDER_COST                    := FND_API.G_MISS_NUM;
    g_in_item_tbl(0).MRP_SAFETY_STOCK_PERCENT      := l_orig_item_rec.MRP_SAFETY_STOCK_PERCENT;
    g_in_item_tbl(0).MRP_SAFETY_STOCK_CODE         := l_orig_item_rec.MRP_SAFETY_STOCK_CODE;
    g_in_item_tbl(0).FIXED_ORDER_QUANTITY          := l_orig_item_rec.FIXED_ORDER_QUANTITY;
    g_in_item_tbl(0).FIXED_DAYS_SUPPLY             := l_orig_item_rec.FIXED_DAYS_SUPPLY;
    g_in_item_tbl(0).MINIMUM_ORDER_QUANTITY        := l_orig_item_rec.MINIMUM_ORDER_QUANTITY;
    g_in_item_tbl(0).MAXIMUM_ORDER_QUANTITY        := l_orig_item_rec.MAXIMUM_ORDER_QUANTITY;
    g_in_item_tbl(0).FIXED_LOT_MULTIPLIER          := l_orig_item_rec.FIXED_LOT_MULTIPLIER;
    g_in_item_tbl(0).SOURCE_TYPE                   := l_orig_item_rec.SOURCE_TYPE;
    g_in_item_tbl(0).SOURCE_ORGANIZATION_ID        := l_orig_item_rec.SOURCE_ORGANIZATION_ID;
    g_in_item_tbl(0).SOURCE_SUBINVENTORY           := l_orig_item_rec.SOURCE_SUBINVENTORY;
    g_in_item_tbl(0).MRP_PLANNING_CODE             := l_orig_item_rec.MRP_PLANNING_CODE;
    g_in_item_tbl(0).ATO_FORECAST_CONTROL          := l_orig_item_rec.ATO_FORECAST_CONTROL;
    g_in_item_tbl(0).PLANNING_EXCEPTION_SET        := l_orig_item_rec.PLANNING_EXCEPTION_SET;
    g_in_item_tbl(0).SHRINKAGE_RATE                := l_orig_item_rec.SHRINKAGE_RATE;
    g_in_item_tbl(0).END_ASSEMBLY_PEGGING_FLAG     := l_orig_item_rec.END_ASSEMBLY_PEGGING_FLAG;
    g_in_item_tbl(0).ROUNDING_CONTROL_TYPE         := l_orig_item_rec.ROUNDING_CONTROL_TYPE;
    g_in_item_tbl(0).PLANNED_INV_POINT_FLAG        := l_orig_item_rec.PLANNED_INV_POINT_FLAG;
    g_in_item_tbl(0).CREATE_SUPPLY_FLAG            := l_orig_item_rec.CREATE_SUPPLY_FLAG;
    g_in_item_tbl(0).ACCEPTABLE_EARLY_DAYS         := l_orig_item_rec.ACCEPTABLE_EARLY_DAYS;
    g_in_item_tbl(0).MRP_CALCULATE_ATP_FLAG        := l_orig_item_rec.MRP_CALCULATE_ATP_FLAG;
    g_in_item_tbl(0).AUTO_REDUCE_MPS               := l_orig_item_rec.AUTO_REDUCE_MPS;
    g_in_item_tbl(0).REPETITIVE_PLANNING_FLAG      := l_orig_item_rec.REPETITIVE_PLANNING_FLAG;
    g_in_item_tbl(0).OVERRUN_PERCENTAGE            := l_orig_item_rec.OVERRUN_PERCENTAGE;
    g_in_item_tbl(0).ACCEPTABLE_RATE_DECREASE      := l_orig_item_rec.ACCEPTABLE_RATE_DECREASE;
    g_in_item_tbl(0).ACCEPTABLE_RATE_INCREASE      := l_orig_item_rec.ACCEPTABLE_RATE_INCREASE;
    g_in_item_tbl(0).PLANNING_TIME_FENCE_CODE      := l_orig_item_rec.PLANNING_TIME_FENCE_CODE;
    g_in_item_tbl(0).PLANNING_TIME_FENCE_DAYS      := l_orig_item_rec.PLANNING_TIME_FENCE_DAYS;
    g_in_item_tbl(0).DEMAND_TIME_FENCE_CODE        := l_orig_item_rec.DEMAND_TIME_FENCE_CODE;
    g_in_item_tbl(0).DEMAND_TIME_FENCE_DAYS        := l_orig_item_rec.DEMAND_TIME_FENCE_DAYS;
    g_in_item_tbl(0).RELEASE_TIME_FENCE_CODE       := l_orig_item_rec.RELEASE_TIME_FENCE_CODE;
    g_in_item_tbl(0).RELEASE_TIME_FENCE_DAYS       := l_orig_item_rec.RELEASE_TIME_FENCE_DAYS;
    g_in_item_tbl(0).SUBSTITUTION_WINDOW_CODE      := l_orig_item_rec.SUBSTITUTION_WINDOW_CODE;
    g_in_item_tbl(0).SUBSTITUTION_WINDOW_DAYS      := l_orig_item_rec.SUBSTITUTION_WINDOW_DAYS;
 -- Lead Times
    g_in_item_tbl(0).PREPROCESSING_LEAD_TIME       := l_orig_item_rec.PREPROCESSING_LEAD_TIME;
    g_in_item_tbl(0).FULL_LEAD_TIME                := l_orig_item_rec.FULL_LEAD_TIME;
    g_in_item_tbl(0).POSTPROCESSING_LEAD_TIME      := l_orig_item_rec.POSTPROCESSING_LEAD_TIME;
    g_in_item_tbl(0).FIXED_LEAD_TIME               := l_orig_item_rec.FIXED_LEAD_TIME;
    g_in_item_tbl(0).VARIABLE_LEAD_TIME            := l_orig_item_rec.VARIABLE_LEAD_TIME;
    g_in_item_tbl(0).CUM_MANUFACTURING_LEAD_TIME   := l_orig_item_rec.CUM_MANUFACTURING_LEAD_TIME;
    g_in_item_tbl(0).CUMULATIVE_TOTAL_LEAD_TIME    := l_orig_item_rec.CUMULATIVE_TOTAL_LEAD_TIME;
    g_in_item_tbl(0).LEAD_TIME_LOT_SIZE            := l_orig_item_rec.LEAD_TIME_LOT_SIZE;
 -- WIP
    g_in_item_tbl(0).BUILD_IN_WIP_FLAG                    := l_orig_item_rec.BUILD_IN_WIP_FLAG;
    g_in_item_tbl(0).WIP_SUPPLY_TYPE                      := l_orig_item_rec.WIP_SUPPLY_TYPE;
    g_in_item_tbl(0).WIP_SUPPLY_SUBINVENTORY              := l_orig_item_rec.WIP_SUPPLY_SUBINVENTORY;
    g_in_item_tbl(0).WIP_SUPPLY_LOCATOR_ID                := l_orig_item_rec.WIP_SUPPLY_LOCATOR_ID;
    g_in_item_tbl(0).OVERCOMPLETION_TOLERANCE_TYPE        := l_orig_item_rec.OVERCOMPLETION_TOLERANCE_TYPE;
    g_in_item_tbl(0).OVERCOMPLETION_TOLERANCE_VALUE       := l_orig_item_rec.OVERCOMPLETION_TOLERANCE_VALUE;
    g_in_item_tbl(0).INVENTORY_CARRY_PENALTY              := l_orig_item_rec.INVENTORY_CARRY_PENALTY;
    g_in_item_tbl(0).OPERATION_SLACK_PENALTY              := l_orig_item_rec.OPERATION_SLACK_PENALTY;
 -- Order Management
    g_in_item_tbl(0).CUSTOMER_ORDER_FLAG           := l_orig_item_rec.CUSTOMER_ORDER_FLAG;
    g_in_item_tbl(0).CUSTOMER_ORDER_ENABLED_FLAG   := l_orig_item_rec.CUSTOMER_ORDER_ENABLED_FLAG;
    g_in_item_tbl(0).INTERNAL_ORDER_FLAG           := l_orig_item_rec.INTERNAL_ORDER_FLAG;
    g_in_item_tbl(0).INTERNAL_ORDER_ENABLED_FLAG   := l_orig_item_rec.INTERNAL_ORDER_ENABLED_FLAG;
    g_in_item_tbl(0).SHIPPABLE_ITEM_FLAG           := l_orig_item_rec.SHIPPABLE_ITEM_FLAG;
    g_in_item_tbl(0).SO_TRANSACTIONS_FLAG          := l_orig_item_rec.SO_TRANSACTIONS_FLAG;
    g_in_item_tbl(0).PICKING_RULE_ID               := l_orig_item_rec.PICKING_RULE_ID;
    g_in_item_tbl(0).PICK_COMPONENTS_FLAG          := l_orig_item_rec.PICK_COMPONENTS_FLAG;
    g_in_item_tbl(0).REPLENISH_TO_ORDER_FLAG       := l_orig_item_rec.REPLENISH_TO_ORDER_FLAG;
    g_in_item_tbl(0).ATP_FLAG                      := l_orig_item_rec.ATP_FLAG;
    g_in_item_tbl(0).ATP_COMPONENTS_FLAG           := l_orig_item_rec.ATP_COMPONENTS_FLAG;
    g_in_item_tbl(0).ATP_RULE_ID                   := l_orig_item_rec.ATP_RULE_ID;
    g_in_item_tbl(0).SHIP_MODEL_COMPLETE_FLAG      := l_orig_item_rec.SHIP_MODEL_COMPLETE_FLAG;
    g_in_item_tbl(0).DEFAULT_SHIPPING_ORG          := l_orig_item_rec.DEFAULT_SHIPPING_ORG;
    g_in_item_tbl(0).DEFAULT_SO_SOURCE_TYPE        := l_orig_item_rec.DEFAULT_SO_SOURCE_TYPE;
    g_in_item_tbl(0).RETURNABLE_FLAG               := l_orig_item_rec.RETURNABLE_FLAG;
    g_in_item_tbl(0).RETURN_INSPECTION_REQUIREMENT := l_orig_item_rec.RETURN_INSPECTION_REQUIREMENT;
    g_in_item_tbl(0).OVER_SHIPMENT_TOLERANCE       := l_orig_item_rec.OVER_SHIPMENT_TOLERANCE;
    g_in_item_tbl(0).UNDER_SHIPMENT_TOLERANCE      := l_orig_item_rec.UNDER_SHIPMENT_TOLERANCE;
    g_in_item_tbl(0).OVER_RETURN_TOLERANCE         := l_orig_item_rec.OVER_RETURN_TOLERANCE;
    g_in_item_tbl(0).UNDER_RETURN_TOLERANCE        := l_orig_item_rec.UNDER_RETURN_TOLERANCE;
    g_in_item_tbl(0).FINANCING_ALLOWED_FLAG        := l_orig_item_rec.FINANCING_ALLOWED_FLAG;
    g_in_item_tbl(0).VOL_DISCOUNT_EXEMPT_FLAG      := l_orig_item_rec.VOL_DISCOUNT_EXEMPT_FLAG;
    g_in_item_tbl(0).COUPON_EXEMPT_FLAG            := l_orig_item_rec.COUPON_EXEMPT_FLAG;
    g_in_item_tbl(0).INVOICEABLE_ITEM_FLAG         := l_orig_item_rec.INVOICEABLE_ITEM_FLAG;
    g_in_item_tbl(0).INVOICE_ENABLED_FLAG          := l_orig_item_rec.INVOICE_ENABLED_FLAG;
    g_in_item_tbl(0).ACCOUNTING_RULE_ID            := l_orig_item_rec.ACCOUNTING_RULE_ID;
    g_in_item_tbl(0).INVOICING_RULE_ID             := l_orig_item_rec.INVOICING_RULE_ID;
    g_in_item_tbl(0).TAX_CODE                      := l_orig_item_rec.TAX_CODE;
    g_in_item_tbl(0).SALES_ACCOUNT                 := l_orig_item_rec.SALES_ACCOUNT;
    g_in_item_tbl(0).PAYMENT_TERMS_ID              := l_orig_item_rec.PAYMENT_TERMS_ID;
 -- Service
    g_in_item_tbl(0).CONTRACT_ITEM_TYPE_CODE       := l_orig_item_rec.CONTRACT_ITEM_TYPE_CODE;
    g_in_item_tbl(0).SERVICE_DURATION_PERIOD_CODE  := l_orig_item_rec.SERVICE_DURATION_PERIOD_CODE;
    g_in_item_tbl(0).SERVICE_DURATION              := l_orig_item_rec.SERVICE_DURATION;
    g_in_item_tbl(0).COVERAGE_SCHEDULE_ID          := l_orig_item_rec.COVERAGE_SCHEDULE_ID;
    g_in_item_tbl(0).SUBSCRIPTION_DEPEND_FLAG      := l_orig_item_rec.SUBSCRIPTION_DEPEND_FLAG;
    g_in_item_tbl(0).SERV_IMPORTANCE_LEVEL         := l_orig_item_rec.SERV_IMPORTANCE_LEVEL;
    g_in_item_tbl(0).SERV_REQ_ENABLED_CODE         := l_orig_item_rec.SERV_REQ_ENABLED_CODE;
    g_in_item_tbl(0).COMMS_ACTIVATION_REQD_FLAG    := l_orig_item_rec.COMMS_ACTIVATION_REQD_FLAG;
    g_in_item_tbl(0).SERVICEABLE_PRODUCT_FLAG      := l_orig_item_rec.SERVICEABLE_PRODUCT_FLAG;
    g_in_item_tbl(0).MATERIAL_BILLABLE_FLAG        := l_orig_item_rec.MATERIAL_BILLABLE_FLAG;
    g_in_item_tbl(0).SERV_BILLING_ENABLED_FLAG     := l_orig_item_rec.SERV_BILLING_ENABLED_FLAG;
    g_in_item_tbl(0).DEFECT_TRACKING_ON_FLAG       := l_orig_item_rec.DEFECT_TRACKING_ON_FLAG;
    g_in_item_tbl(0).RECOVERED_PART_DISP_CODE      := l_orig_item_rec.RECOVERED_PART_DISP_CODE;
    g_in_item_tbl(0).COMMS_NL_TRACKABLE_FLAG       := l_orig_item_rec.COMMS_NL_TRACKABLE_FLAG;
    g_in_item_tbl(0).ASSET_CREATION_CODE           := l_orig_item_rec.ASSET_CREATION_CODE;
-- already commented out    --,  IB_ITEM_INSTANCE_CLASS                  VARCHAR2(30)    :=  FND_API.g_MISS_CHAR
    g_in_item_tbl(0).IB_ITEM_INSTANCE_CLASS        := l_orig_item_rec.IB_ITEM_INSTANCE_CLASS;
    g_in_item_tbl(0).SERVICE_STARTING_DELAY        := l_orig_item_rec.SERVICE_STARTING_DELAY;
 -- Web Option
    g_in_item_tbl(0).WEB_STATUS                    := l_orig_item_rec.WEB_STATUS;
    g_in_item_tbl(0).ORDERABLE_ON_WEB_FLAG         := l_orig_item_rec.ORDERABLE_ON_WEB_FLAG;
    g_in_item_tbl(0).BACK_ORDERABLE_FLAG           := l_orig_item_rec.BACK_ORDERABLE_FLAG;
    g_in_item_tbl(0).MINIMUM_LICENSE_QUANTITY      := l_orig_item_rec.MINIMUM_LICENSE_QUANTITY;
 -- Descriptive flex
    g_in_item_tbl(0).Attribute_Category            := l_orig_item_rec.Attribute_Category;
    g_in_item_tbl(0).Attribute1                    := l_orig_item_rec.Attribute1;
    g_in_item_tbl(0).Attribute2                    := l_orig_item_rec.Attribute2;
    g_in_item_tbl(0).Attribute3                    := l_orig_item_rec.Attribute3;
    g_in_item_tbl(0).Attribute4                    := l_orig_item_rec.Attribute4;
    g_in_item_tbl(0).Attribute5                    := l_orig_item_rec.Attribute5;
    g_in_item_tbl(0).Attribute6                    := l_orig_item_rec.Attribute6;
    g_in_item_tbl(0).Attribute7                    := l_orig_item_rec.Attribute7;
    g_in_item_tbl(0).Attribute8                    := l_orig_item_rec.Attribute8;
    g_in_item_tbl(0).Attribute9                    := l_orig_item_rec.Attribute9;
    g_in_item_tbl(0).Attribute10                   := l_orig_item_rec.Attribute10;
    g_in_item_tbl(0).Attribute11                   := l_orig_item_rec.Attribute11;
    g_in_item_tbl(0).Attribute12                   := l_orig_item_rec.Attribute12;
    g_in_item_tbl(0).Attribute13                   := l_orig_item_rec.Attribute13;
    g_in_item_tbl(0).Attribute14                   := l_orig_item_rec.Attribute14;
    g_in_item_tbl(0).Attribute15                   := l_orig_item_rec.Attribute15;
 -- Global Descriptive flex
    g_in_item_tbl(0).Global_Attribute_Category     := l_orig_item_rec.Global_Attribute_Category;
    g_in_item_tbl(0).Global_Attribute1             := l_orig_item_rec.Global_Attribute1;
    g_in_item_tbl(0).Global_Attribute2             := l_orig_item_rec.Global_Attribute2;
    g_in_item_tbl(0).Global_Attribute3             := l_orig_item_rec.Global_Attribute3;
    g_in_item_tbl(0).Global_Attribute4             := l_orig_item_rec.Global_Attribute4;
    g_in_item_tbl(0).Global_Attribute5             := l_orig_item_rec.Global_Attribute5;
    g_in_item_tbl(0).Global_Attribute6             := l_orig_item_rec.Global_Attribute6;
    g_in_item_tbl(0).Global_Attribute7             := l_orig_item_rec.Global_Attribute7;
    g_in_item_tbl(0).Global_Attribute8             := l_orig_item_rec.Global_Attribute8;
    g_in_item_tbl(0).Global_Attribute9             := l_orig_item_rec.Global_Attribute9;
    g_in_item_tbl(0).Global_Attribute10            := l_orig_item_rec.Global_Attribute10;

    x_return_status := G_RET_STS_SUCCESS;
    developer_debug ('::2960442::initialize_item_info::end');
  EXCEPTION
    WHEN OTHERS THEN
      IF c_copy_item_info%ISOPEN THEN
        CLOSE c_copy_item_info;
      END IF;
      RAISE;
  END initialize_item_info;


  PROCEDURE initialize_template_info (p_template_id         IN  NUMBER
                                     ,p_template_name       IN  VARCHAR2
                                     ,p_organization_id     IN  NUMBER
                                     ,p_organization_code   IN  VARCHAR2
                                     ,x_return_status      OUT  NOCOPY VARCHAR2
                     ,x_msg_count          OUT  NOCOPY NUMBER
                                     ) IS
  ----------------------------------------------------------------------------
  -- Start OF comments
  -- API name  : initialize_template_info
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  : Initialize the Item record with the Template values of the
  --             template_id specified
  --
  -- Parameters:
  --     IN    : p_template_id           IN  NUMBER     (required)
  --           : p_inventory_item_id     IN  NUMBER     (required)
  --           : p_organization_id       IN  NUMBER     (required)
  --
  --
  --    OUT    : x_return_status        OUT  VARCHAR2
  --             x_msg_count            OUT  NUMBER
  --
  ----------------------------------------------------------------------------
    CURSOR c_get_context_org (cp_template_id  IN NUMBER) IS
      SELECT context_organization_id
       FROM  mtl_item_templates mit
       WHERE mit.template_id = cp_template_id;

    CURSOR c_get_template_attributes (cp_template_id  IN  NUMBER) IS
      SELECT attribute_name, attribute_value
      FROM   mtl_item_templ_attributes
      WHERE  template_id = cp_template_id
        AND  enabled_flag = 'Y'
        AND  attribute_name IN
             ( SELECT a.attribute_name
               FROM   mtl_item_attributes  a
               WHERE  NVL(a.status_control_code, 3) <> 1
                 AND  a.control_level IN (1, 2)
                 AND  a.attribute_group_id_gui IS NOT NULL
                 AND  a.attribute_name NOT IN
             ('MTL_SYSTEM_ITEMS.BASE_ITEM_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY',
             'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID',
             'MTL_SYSTEM_ITEMS.PLANNER_CODE',
             'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET')
             );

    --
    -- Attributes that can be applied only through the Org Specific templates.
    --
    CURSOR c_get_org_template_attributes (cp_template_id IN  NUMBER)  IS
      SELECT attribute_name,  attribute_value
      FROM   mtl_item_templ_attributes
      WHERE  template_id = cp_template_id
        AND  enabled_flag = 'Y'
        AND  attribute_name IN
             ( SELECT  a.attribute_name
               FROM    mtl_item_attributes  a
               WHERE   NVL(a.status_control_code, 3) <> 1
                  AND  a.control_level IN (1, 2)
                  AND  a.attribute_group_id_gui IS NOT NULL
                  AND  a.attribute_name IN
             ('MTL_SYSTEM_ITEMS.BASE_ITEM_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY',
             'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID',
             'MTL_SYSTEM_ITEMS.PLANNER_CODE',
             'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET')
             );

   CURSOR c_get_global_flex_fields (cp_template_id IN  NUMBER) IS
      SELECT GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10
      FROM MTL_ITEM_TEMPLATES MIT
      WHERE MIT.template_id = cp_template_id;

    l_org_id  mtl_item_templates.context_organization_id%TYPE;

  BEGIN
    developer_debug ('::2960442::initialize_template_info::start');
    l_org_id := NULL;
    OPEN c_get_context_org (cp_template_id => p_template_id);
    FETCH c_get_context_org INTO l_org_id;
    CLOSE c_get_context_org;
    IF ( (l_org_id is NOT NULL) AND (l_org_id <> p_organization_id) ) THEN
      EGO_Item_Msg.Add_Error_Message
         (p_entity_index           => 1
         ,p_application_short_name => 'EGO'
         ,p_message_name           => 'EGO_INVALID_TEMPLATE_ORG'
         ,p_token_name1            => 'TEMPLATE_NAME'
         ,p_token_value1           => p_template_name
         ,p_translate1             => FALSE
         ,p_token_name2            => 'ORGANIZATION_CODE'
         ,p_token_value2       => p_organization_code
         ,p_translate2             => FALSE
         ,p_token_name3            => NULL
         ,p_token_value3           => NULL
         ,p_translate3             => FALSE
         );
      x_return_status := G_RET_STS_ERROR;
      RETURN;
    END IF; -- c_get_context_org%NOTFOUND

    ------------------------------------
    -- Set item record attribute values
    ------------------------------------
    FOR cr IN c_get_template_attributes (cp_template_id => p_template_id) LOOP
       developer_debug('  Setting item template Attribute Name ' || cr.attribute_name || ' attribute value ' || cr.attribute_value );
    IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_EARLY_DAYS' THEN
            g_in_item_tbl(0).ACCEPTABLE_EARLY_DAYS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_DECREASE' THEN
        g_in_item_tbl(0).ACCEPTABLE_RATE_DECREASE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_INCREASE' THEN
            g_in_item_tbl(0).ACCEPTABLE_RATE_INCREASE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCOUNTING_RULE_ID' THEN
            g_in_item_tbl(0).ACCOUNTING_RULE_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOWED_UNITS_LOOKUP_CODE' THEN
            g_in_item_tbl(0).ALLOWED_UNITS_LOOKUP_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_EXPRESS_DELIVERY_FLAG' THEN
            g_in_item_tbl(0).ALLOW_EXPRESS_DELIVERY_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_ITEM_DESC_UPDATE_FLAG' THEN
            g_in_item_tbl(0).ALLOW_ITEM_DESC_UPDATE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_SUBSTITUTE_RECEIPTS_FLAG' THEN
            g_in_item_tbl(0).ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_UNORDERED_RECEIPTS_FLAG' THEN
            g_in_item_tbl(0).ALLOW_UNORDERED_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CATEGORY_ID' THEN
            g_in_item_tbl(0).ASSET_CATEGORY_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_COMPONENTS_FLAG' THEN
            g_in_item_tbl(0).ATP_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_FLAG' THEN
            g_in_item_tbl(0).ATP_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_RULE_ID' THEN
            g_in_item_tbl(0).ATP_RULE_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_LOT_ALPHA_PREFIX' THEN
            g_in_item_tbl(0).AUTO_LOT_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_REDUCE_MPS' THEN
            g_in_item_tbl(0).AUTO_REDUCE_MPS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_SERIAL_ALPHA_PREFIX' THEN
            g_in_item_tbl(0).AUTO_SERIAL_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
            g_in_item_tbl(0).BOM_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE' THEN
            g_in_item_tbl(0).BOM_ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
            g_in_item_tbl(0).BUILD_IN_WIP_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUYER_ID' THEN
            g_in_item_tbl(0).BUYER_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CARRYING_COST' THEN
            g_in_item_tbl(0).CARRYING_COST  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COLLATERAL_FLAG' THEN
            g_in_item_tbl(0).COLLATERAL_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG' THEN
            g_in_item_tbl(0).COSTING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COVERAGE_SCHEDULE_ID' THEN
            g_in_item_tbl(0).COVERAGE_SCHEDULE_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUMULATIVE_TOTAL_LEAD_TIME' THEN
            g_in_item_tbl(0).CUMULATIVE_TOTAL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUM_MANUFACTURING_LEAD_TIME' THEN
            g_in_item_tbl(0).CUM_MANUFACTURING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
            g_in_item_tbl(0).CUSTOMER_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG' THEN
            g_in_item_tbl(0).CUSTOMER_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CYCLE_COUNT_ENABLED_FLAG' THEN
            g_in_item_tbl(0).CYCLE_COUNT_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_EARLY_RECEIPT_ALLOWED' THEN
            g_in_item_tbl(0).DAYS_EARLY_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_LATE_RECEIPT_ALLOWED' THEN
            g_in_item_tbl(0).DAYS_LATE_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_INCLUDE_IN_ROLLUP_FLAG' THEN
            g_in_item_tbl(0).DEFAULT_INCLUDE_IN_ROLLUP_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SHIPPING_ORG' THEN
            g_in_item_tbl(0).DEFAULT_SHIPPING_ORG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_CODE' THEN
            g_in_item_tbl(0).DEMAND_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_DAYS' THEN
            g_in_item_tbl(0).DEMAND_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.END_ASSEMBLY_PEGGING_FLAG' THEN
            g_in_item_tbl(0).END_ASSEMBLY_PEGGING_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENFORCE_SHIP_TO_LOCATION_CODE' THEN
            g_in_item_tbl(0).ENFORCE_SHIP_TO_LOCATION_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT' THEN
            g_in_item_tbl(0).EXPENSE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_BILLABLE_FLAG' THEN
--            g_in_item_tbl(0).EXPENSE_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_DAYS_SUPPLY' THEN
            g_in_item_tbl(0).FIXED_DAYS_SUPPLY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LEAD_TIME' THEN
            g_in_item_tbl(0).FIXED_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LOT_MULTIPLIER' THEN
            g_in_item_tbl(0).FIXED_LOT_MULTIPLIER  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_ORDER_QUANTITY' THEN
            g_in_item_tbl(0).FIXED_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FULL_LEAD_TIME' THEN
            g_in_item_tbl(0).FULL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARD_CLASS_ID' THEN
            g_in_item_tbl(0).HAZARD_CLASS_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INSPECTION_REQUIRED_FLAG' THEN
            g_in_item_tbl(0).INSPECTION_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
            g_in_item_tbl(0).INTERNAL_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG' THEN
            g_in_item_tbl(0).INTERNAL_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG' THEN
            g_in_item_tbl(0).INVENTORY_ASSET_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_FLAG' THEN
            g_in_item_tbl(0).INVENTORY_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE' THEN
            g_in_item_tbl(0).INVENTORY_ITEM_STATUS_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_PLANNING_CODE' THEN
            g_in_item_tbl(0).INVENTORY_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG' THEN
            g_in_item_tbl(0).INVOICEABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_CLOSE_TOLERANCE' THEN
            g_in_item_tbl(0).INVOICE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
            g_in_item_tbl(0).INVOICE_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICING_RULE_ID' THEN
            g_in_item_tbl(0).INVOICING_RULE_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ITEM_TYPE' THEN
            g_in_item_tbl(0).ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LEAD_TIME_LOT_SIZE' THEN
            g_in_item_tbl(0).LEAD_TIME_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT' THEN
            g_in_item_tbl(0).LIST_PRICE_PER_UNIT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE' THEN
            g_in_item_tbl(0).LOCATION_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE' THEN
            g_in_item_tbl(0).LOT_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MARKET_PRICE' THEN
            g_in_item_tbl(0).MARKET_PRICE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATERIAL_BILLABLE_FLAG' THEN
            g_in_item_tbl(0).MATERIAL_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_ORDER_QUANTITY' THEN
            g_in_item_tbl(0).MAXIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_MINMAX_QUANTITY' THEN
            g_in_item_tbl(0).MAX_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_WARRANTY_AMOUNT' THEN
--            g_in_item_tbl(0).MAX_WARRANTY_AMOUNT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_ORDER_QUANTITY' THEN
            g_in_item_tbl(0).MINIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MIN_MINMAX_QUANTITY' THEN
            g_in_item_tbl(0).MIN_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_CALCULATE_ATP_FLAG' THEN
            g_in_item_tbl(0).MRP_CALCULATE_ATP_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_PLANNING_CODE' THEN
            g_in_item_tbl(0).MRP_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_CODE' THEN
            g_in_item_tbl(0).MRP_SAFETY_STOCK_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_PERCENT' THEN
            g_in_item_tbl(0).MRP_SAFETY_STOCK_PERCENT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' THEN
            g_in_item_tbl(0).MTL_TRANSACTIONS_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MUST_USE_APPROVED_VENDOR_FLAG' THEN
            g_in_item_tbl(0).MUST_USE_APPROVED_VENDOR_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEGATIVE_MEASUREMENT_ERROR' THEN
            g_in_item_tbl(0).NEGATIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEW_REVISION_CODE' THEN
--            g_in_item_tbl(0).NEW_REVISION_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDER_COST' THEN
            g_in_item_tbl(0).ORDER_COST  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_FLAG' THEN
            g_in_item_tbl(0).OUTSIDE_OPERATION_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_UOM_TYPE' THEN
            g_in_item_tbl(0).OUTSIDE_OPERATION_UOM_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERRUN_PERCENTAGE' THEN
            g_in_item_tbl(0).OVERRUN_PERCENTAGE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PAYMENT_TERMS_ID' THEN
            g_in_item_tbl(0).PAYMENT_TERMS_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICKING_RULE_ID' THEN
            g_in_item_tbl(0).PICKING_RULE_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICK_COMPONENTS_FLAG' THEN
            g_in_item_tbl(0).PICK_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_MAKE_BUY_CODE' THEN
            g_in_item_tbl(0).PLANNING_MAKE_BUY_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_CODE' THEN
            g_in_item_tbl(0).PLANNING_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_DAYS' THEN
            g_in_item_tbl(0).PLANNING_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSITIVE_MEASUREMENT_ERROR' THEN
            g_in_item_tbl(0).POSITIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSTPROCESSING_LEAD_TIME' THEN
            g_in_item_tbl(0).POSTPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPROCESSING_LEAD_TIME' THEN
            g_in_item_tbl(0).PREPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREVENTIVE_MAINTENANCE_FLAG' THEN
--            g_in_item_tbl(0).PREVENTIVE_MAINTENANCE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRICE_TOLERANCE_PERCENT' THEN
            g_in_item_tbl(0).PRICE_TOLERANCE_PERCENT  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_SPECIALIST_ID' THEN
--            g_in_item_tbl(0).PRIMARY_SPECIALIST_ID  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRORATE_SERVICE_FLAG' THEN
--            g_in_item_tbl(0).PRORATE_SERVICE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
            g_in_item_tbl(0).PURCHASING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ITEM_FLAG' THEN
            g_in_item_tbl(0).PURCHASING_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_EXCEPTION_CODE' THEN
            g_in_item_tbl(0).QTY_RCV_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_TOLERANCE' THEN
            g_in_item_tbl(0).QTY_RCV_TOLERANCE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_DAYS_EXCEPTION_CODE' THEN
            g_in_item_tbl(0).RECEIPT_DAYS_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_REQUIRED_FLAG' THEN
            g_in_item_tbl(0).RECEIPT_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVE_CLOSE_TOLERANCE' THEN
            g_in_item_tbl(0).RECEIVE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVING_ROUTING_ID' THEN
            g_in_item_tbl(0).RECEIVING_ROUTING_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPETITIVE_PLANNING_FLAG' THEN
            g_in_item_tbl(0).REPETITIVE_PLANNING_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPLENISH_TO_ORDER_FLAG' THEN
            g_in_item_tbl(0).REPLENISH_TO_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE' THEN
            g_in_item_tbl(0).RESERVABLE_TYPE  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_PERIOD_CODE' THEN
--          g_in_item_tbl(0).RESPONSE_TIME_PERIOD_CODE  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_VALUE' THEN
--            g_in_item_tbl(0).RESPONSE_TIME_VALUE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE' THEN
            g_in_item_tbl(0).RESTRICT_LOCATORS_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_SUBINVENTORIES_CODE' THEN
            g_in_item_tbl(0).RESTRICT_SUBINVENTORIES_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURNABLE_FLAG' THEN
            g_in_item_tbl(0).RETURNABLE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURN_INSPECTION_REQUIREMENT' THEN
            g_in_item_tbl(0).RETURN_INSPECTION_REQUIREMENT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE' THEN
            g_in_item_tbl(0).REVISION_QTY_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RFQ_REQUIRED_FLAG' THEN
            g_in_item_tbl(0).RFQ_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_CONTROL_TYPE' THEN
            g_in_item_tbl(0).ROUNDING_CONTROL_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_FACTOR' THEN
            g_in_item_tbl(0).ROUNDING_FACTOR  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SAFETY_STOCK_BUCKET_DAYS' THEN
            g_in_item_tbl(0).SAFETY_STOCK_BUCKET_DAYS  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_SPECIALIST_ID' THEN
--            g_in_item_tbl(0).SECONDARY_SPECIALIST_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE' THEN
            g_in_item_tbl(0).SERIAL_NUMBER_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_COMPONENT_FLAG' THEN
--            g_in_item_tbl(0).SERVICEABLE_COMPONENT_FLAG  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_ITEM_CLASS_ID' THEN
--            g_in_item_tbl(0).SERVICEABLE_ITEM_CLASS_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_PRODUCT_FLAG' THEN
            g_in_item_tbl(0).SERVICEABLE_PRODUCT_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION' THEN
            g_in_item_tbl(0).SERVICE_DURATION  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION_PERIOD_CODE' THEN
            g_in_item_tbl(0).SERVICE_DURATION_PERIOD_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_STARTING_DELAY' THEN
            g_in_item_tbl(0).SERVICE_STARTING_DELAY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE' THEN
            g_in_item_tbl(0).SHELF_LIFE_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_DAYS' THEN
            g_in_item_tbl(0).SHELF_LIFE_DAYS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG' THEN
            g_in_item_tbl(0).SHIPPABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIP_MODEL_COMPLETE_FLAG' THEN
            g_in_item_tbl(0).SHIP_MODEL_COMPLETE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHRINKAGE_RATE' THEN
            g_in_item_tbl(0).SHRINKAGE_RATE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_ORGANIZATION_ID' THEN
            g_in_item_tbl(0).SOURCE_ORGANIZATION_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_SUBINVENTORY' THEN
            g_in_item_tbl(0).SOURCE_SUBINVENTORY  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_TYPE' THEN
            g_in_item_tbl(0).SOURCE_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG' THEN
            g_in_item_tbl(0).SO_TRANSACTIONS_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_LOT_NUMBER' THEN
            g_in_item_tbl(0).START_AUTO_LOT_NUMBER  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_SERIAL_NUMBER' THEN
            g_in_item_tbl(0).START_AUTO_SERIAL_NUMBER  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STD_LOT_SIZE' THEN
            g_in_item_tbl(0).STD_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN
            g_in_item_tbl(0).STOCK_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAXABLE_FLAG' THEN
            g_in_item_tbl(0).TAXABLE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_TAX_CODE' THEN
            g_in_item_tbl(0).PURCHASING_TAX_CODE := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAX_CODE' THEN
            g_in_item_tbl(0).TAX_CODE  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TIME_BILLABLE_FLAG' THEN
--            g_in_item_tbl(0).TIME_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_OF_ISSUE' THEN
            g_in_item_tbl(0).UNIT_OF_ISSUE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_VOLUME' THEN
            g_in_item_tbl(0).UNIT_VOLUME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WEIGHT' THEN
            g_in_item_tbl(0).UNIT_WEIGHT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UN_NUMBER_ID' THEN
            g_in_item_tbl(0).UN_NUMBER_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VARIABLE_LEAD_TIME' THEN
            g_in_item_tbl(0).VARIABLE_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOLUME_UOM_CODE' THEN
            g_in_item_tbl(0).VOLUME_UOM_CODE  := cr.ATTRIBUTE_VALUE;
--  ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WARRANTY_VENDOR_ID' THEN
--            g_in_item_tbl(0).WARRANTY_VENDOR_ID  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE' THEN
            g_in_item_tbl(0).WEIGHT_UOM_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_TYPE' THEN
            g_in_item_tbl(0).WIP_SUPPLY_TYPE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATO_FORECAST_CONTROL' THEN
            g_in_item_tbl(0).ATO_FORECAST_CONTROL  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DESCRIPTION' THEN
            g_in_item_tbl(0).DESCRIPTION  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_CODE' THEN
            g_in_item_tbl(0).RELEASE_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_DAYS' THEN
            g_in_item_tbl(0).RELEASE_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_ITEM_FLAG' THEN
            g_in_item_tbl(0).CONTAINER_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_TYPE_CODE' THEN
            g_in_item_tbl(0).CONTAINER_TYPE_CODE  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_VOLUME' THEN
            g_in_item_tbl(0).INTERNAL_VOLUME  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_LOAD_WEIGHT' THEN
            g_in_item_tbl(0).MAXIMUM_LOAD_WEIGHT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_FILL_PERCENT' THEN
            g_in_item_tbl(0).MINIMUM_FILL_PERCENT  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VEHICLE_ITEM_FLAG' THEN
            g_in_item_tbl(0).VEHICLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHECK_SHORTAGES_FLAG' THEN
            g_in_item_tbl(0).CHECK_SHORTAGES_FLAG  := cr.ATTRIBUTE_VALUE;
    ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EFFECTIVITY_CONTROL' THEN
            g_in_item_tbl(0).EFFECTIVITY_CONTROL  := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_TYPE' THEN
            g_in_item_tbl(0).OVERCOMPLETION_TOLERANCE_TYPE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_VALUE' THEN
            g_in_item_tbl(0).OVERCOMPLETION_TOLERANCE_VALUE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_SHIPMENT_TOLERANCE' THEN
            g_in_item_tbl(0).OVER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_SHIPMENT_TOLERANCE' THEN
            g_in_item_tbl(0).UNDER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_RETURN_TOLERANCE' THEN
            g_in_item_tbl(0).OVER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_RETURN_TOLERANCE' THEN
            g_in_item_tbl(0).UNDER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EQUIPMENT_TYPE' THEN
            g_in_item_tbl(0).EQUIPMENT_TYPE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECOVERED_PART_DISP_CODE' THEN
            g_in_item_tbl(0).RECOVERED_PART_DISP_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFECT_TRACKING_ON_FLAG' THEN
            g_in_item_tbl(0).DEFECT_TRACKING_ON_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EVENT_FLAG' THEN
            g_in_item_tbl(0).EVENT_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ELECTRONIC_FLAG' THEN
            g_in_item_tbl(0).ELECTRONIC_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DOWNLOADABLE_FLAG' THEN
            g_in_item_tbl(0).DOWNLOADABLE_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOL_DISCOUNT_EXEMPT_FLAG' THEN
            g_in_item_tbl(0).VOL_DISCOUNT_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COUPON_EXEMPT_FLAG' THEN
            g_in_item_tbl(0).COUPON_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG' THEN
            g_in_item_tbl(0).COMMS_NL_TRACKABLE_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CREATION_CODE' THEN
            g_in_item_tbl(0).ASSET_CREATION_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_ACTIVATION_REQD_FLAG' THEN
            g_in_item_tbl(0).COMMS_ACTIVATION_REQD_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDERABLE_ON_WEB_FLAG' THEN
            g_in_item_tbl(0).ORDERABLE_ON_WEB_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BACK_ORDERABLE_FLAG' THEN
            g_in_item_tbl(0).BACK_ORDERABLE_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEB_STATUS' THEN
            g_in_item_tbl(0).WEB_STATUS := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INDIVISIBLE_FLAG' THEN
            g_in_item_tbl(0).INDIVISIBLE_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIMENSION_UOM_CODE' THEN
            g_in_item_tbl(0).DIMENSION_UOM_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_LENGTH' THEN
            g_in_item_tbl(0).UNIT_LENGTH := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WIDTH' THEN
            g_in_item_tbl(0).UNIT_WIDTH := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_HEIGHT' THEN
            g_in_item_tbl(0).UNIT_HEIGHT := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BULK_PICKED_FLAG' THEN
            g_in_item_tbl(0).BULK_PICKED_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_STATUS_ENABLED' THEN
            g_in_item_tbl(0).LOT_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_LOT_STATUS_ID' THEN
            g_in_item_tbl(0).DEFAULT_LOT_STATUS_ID := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_STATUS_ENABLED' THEN
            g_in_item_tbl(0).SERIAL_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SERIAL_STATUS_ID' THEN
            g_in_item_tbl(0).DEFAULT_SERIAL_STATUS_ID := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SPLIT_ENABLED' THEN
            g_in_item_tbl(0).LOT_SPLIT_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_MERGE_ENABLED' THEN
            g_in_item_tbl(0).LOT_MERGE_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_CARRY_PENALTY' THEN
            g_in_item_tbl(0).INVENTORY_CARRY_PENALTY := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OPERATION_SLACK_PENALTY' THEN
            g_in_item_tbl(0).OPERATION_SLACK_PENALTY := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FINANCING_ALLOWED_FLAG' THEN
            g_in_item_tbl(0).FINANCING_ALLOWED_FLAG := cr.ATTRIBUTE_VALUE;
        -- Primary Unit of Measure is now maintained via the PRIMARY_UOM_CODE column.
        --
        --IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE' then g_in_item_tbl(0).PRIMARY_UNIT_OF_MEASURE  := cr.ATTRIBUTE_VALUE; END IF;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE' THEN
            g_in_item_tbl(0).PRIMARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE' THEN
            g_in_item_tbl(0).EAM_ITEM_TYPE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_TYPE_CODE' THEN
            g_in_item_tbl(0).EAM_ACTIVITY_TYPE_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_CAUSE_CODE' THEN
            g_in_item_tbl(0).EAM_ACTIVITY_CAUSE_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_NOTIFICATION_FLAG' THEN
            g_in_item_tbl(0).EAM_ACT_NOTIFICATION_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_SHUTDOWN_STATUS' THEN
            g_in_item_tbl(0).EAM_ACT_SHUTDOWN_STATUS := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_CONTROL' THEN
            g_in_item_tbl(0).DUAL_UOM_CONTROL := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE' THEN
            g_in_item_tbl(0).SECONDARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH' THEN
            g_in_item_tbl(0).DUAL_UOM_DEVIATION_HIGH := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW' THEN
            g_in_item_tbl(0).DUAL_UOM_DEVIATION_LOW := cr.ATTRIBUTE_VALUE;
        --
        -- Service Item flag attribute is no longer supported for DML.
        --
    --IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_ITEM_FLAG' THEN g_in_item_tbl(0).SERVICE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE; END IF;
    --IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VENDOR_WARRANTY_FLAG' THEN g_in_item_tbl(0).VENDOR_WARRANTY_FLAG  := cr.ATTRIBUTE_VALUE; END IF;
        --IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.USAGE_ITEM_FLAG' THEN g_in_item_tbl(0).USAGE_ITEM_FLAG := cr.ATTRIBUTE_VALUE; END IF;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTRACT_ITEM_TYPE_CODE' THEN
            g_in_item_tbl(0).CONTRACT_ITEM_TYPE_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSCRIPTION_DEPEND_FLAG' THEN
            g_in_item_tbl(0).SUBSCRIPTION_DEPEND_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_REQ_ENABLED_CODE' THEN
            g_in_item_tbl(0).SERV_REQ_ENABLED_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_BILLING_ENABLED_FLAG' THEN
            g_in_item_tbl(0).SERV_BILLING_ENABLED_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_IMPORTANCE_LEVEL' THEN
            g_in_item_tbl(0).SERV_IMPORTANCE_LEVEL := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNED_INV_POINT_FLAG' THEN
            g_in_item_tbl(0).PLANNED_INV_POINT_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_TRANSLATE_ENABLED' THEN
            g_in_item_tbl(0).LOT_TRANSLATE_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SO_SOURCE_TYPE' THEN
            g_in_item_tbl(0).DEFAULT_SO_SOURCE_TYPE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CREATE_SUPPLY_FLAG' THEN
            g_in_item_tbl(0).CREATE_SUPPLY_FLAG := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_CODE' THEN
            g_in_item_tbl(0).SUBSTITUTION_WINDOW_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SUBSTITUTION_ENABLED' THEN
            g_in_item_tbl(0).LOT_SUBSTITUTION_ENABLED := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_LICENSE_QUANTITY' THEN
            g_in_item_tbl(0).MINIMUM_LICENSE_QUANTITY := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_SOURCE_CODE' THEN
            g_in_item_tbl(0).EAM_ACTIVITY_SOURCE_CODE := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.IB_ITEM_INSTANCE_CLASS' THEN
            g_in_item_tbl(0).IB_ITEM_INSTANCE_CLASS := cr.ATTRIBUTE_VALUE;
        ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MODEL_TYPE' THEN
            g_in_item_tbl(0).CONFIG_MODEL_TYPE := cr.ATTRIBUTE_VALUE;
        END IF;  -- cr.ATTRIBUTE_NAME
    END LOOP;  -- cursor c_get_template_attributes

    IF ( (l_org_id is NOT NULL) AND (l_org_id = p_organization_id) ) THEN
      FOR cr IN c_get_org_template_attributes (cp_template_id => p_template_id) LOOP
developer_debug('  Setting ORG template Attribute Name ' || cr.attribute_name || ' attribute value ' || cr.attribute_value );
          IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_ITEM_ID' THEN
            g_in_item_tbl(0).BASE_ITEM_ID  := cr.ATTRIBUTE_VALUE;
--          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID' THEN
--            g_in_item_tbl(0).BASE_WARRANTY_SERVICE_ID  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT' THEN
            g_in_item_tbl(0).COST_OF_SALES_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT' THEN
            g_in_item_tbl(0).ENCUMBRANCE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT' THEN
            g_in_item_tbl(0).EXPENSE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNER_CODE' THEN
            g_in_item_tbl(0).PLANNER_CODE  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET' THEN
            g_in_item_tbl(0).PLANNING_EXCEPTION_SET  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SALES_ACCOUNT' THEN
            g_in_item_tbl(0).SALES_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID' THEN
            g_in_item_tbl(0).WIP_SUPPLY_LOCATOR_ID  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY' THEN
            g_in_item_tbl(0).WIP_SUPPLY_SUBINVENTORY  := cr.ATTRIBUTE_VALUE;
          END IF;
      END LOOP; -- cursor c_get_org_template_attributes
    END IF; -- cursor c_get_org_template_attributes
/***
-- this is the forms logic, handled by IOI??
    IF ( g_in_item_tbl(0).CONTRACT_ITEM_TYPE_CODE = 'SERVICE' ) THEN
      g_in_item_tbl(0).SERVICE_ITEM_FLAG    := 'Y';
      g_in_item_tbl(0).VENDOR_WARRANTY_FLAG := 'N';
      g_in_item_tbl(0).USAGE_ITEM_FLAG      := NULL;
    ELSIF ( g_in_item_tbl(0).CONTRACT_ITEM_TYPE_CODE = 'WARRANTY' ) THEN
      g_in_item_tbl(0).SERVICE_ITEM_FLAG    := 'Y';
      g_in_item_tbl(0).VENDOR_WARRANTY_FLAG := 'Y';
      g_in_item_tbl(0).USAGE_ITEM_FLAG      := NULL;
    ELSIF ( g_in_item_tbl(0).CONTRACT_ITEM_TYPE_CODE = 'USAGE' ) THEN
      g_in_item_tbl(0).SERVICE_ITEM_FLAG    := 'N';
      g_in_item_tbl(0).VENDOR_WARRANTY_FLAG := 'N';
      g_in_item_tbl(0).USAGE_ITEM_FLAG      := 'Y';
    ELSE
      g_in_item_tbl(0).SERVICE_ITEM_FLAG    := 'N';
      g_in_item_tbl(0).VENDOR_WARRANTY_FLAG := 'N';
      g_in_item_tbl(0).USAGE_ITEM_FLAG      := NULL;
    END IF;
***/
    -- setting the flexible attributes here.
    FOR cr IN c_get_global_flex_fields (cp_template_id => p_template_id) LOOP
      g_in_item_tbl(0).Global_Attribute_Category  := NVL(cr.Global_Attribute_Category,g_in_item_tbl(0).Global_Attribute_Category);
      g_in_item_tbl(0).Global_Attribute1          := NVL(cr.Global_Attribute1,g_in_item_tbl(0).Global_Attribute1);
      g_in_item_tbl(0).Global_Attribute2          := NVL(cr.Global_Attribute2,g_in_item_tbl(0).Global_Attribute2);
      g_in_item_tbl(0).Global_Attribute3          := NVL(cr.Global_Attribute3,g_in_item_tbl(0).Global_Attribute3);
      g_in_item_tbl(0).Global_Attribute4          := NVL(cr.Global_Attribute4,g_in_item_tbl(0).Global_Attribute4);
      g_in_item_tbl(0).Global_Attribute5          := NVL(cr.Global_Attribute5,g_in_item_tbl(0).Global_Attribute5);
      g_in_item_tbl(0).Global_Attribute6          := NVL(cr.Global_Attribute6,g_in_item_tbl(0).Global_Attribute6);
      g_in_item_tbl(0).Global_Attribute7          := NVL(cr.Global_Attribute7,g_in_item_tbl(0).Global_Attribute7);
      g_in_item_tbl(0).Global_Attribute8          := NVL(cr.Global_Attribute8,g_in_item_tbl(0).Global_Attribute8);
      g_in_item_tbl(0).Global_Attribute9          := NVL(cr.Global_Attribute9,g_in_item_tbl(0).Global_Attribute9);
      g_in_item_tbl(0).Global_Attribute10         := NVL(cr.Global_Attribute10,g_in_item_tbl(0).Global_Attribute10);
    END LOOP;
    x_return_status := G_RET_STS_SUCCESS;
    developer_debug ('::2960442::initialize_template_info::end');
  EXCEPTION
    WHEN OTHERS THEN
    IF c_get_context_org%ISOPEN THEN
      CLOSE c_get_context_org;
    END IF;
    IF c_get_template_attributes%ISOPEN THEN
      CLOSE c_get_template_attributes;
    END IF;
    IF c_get_org_template_attributes%ISOPEN THEN
      CLOSE c_get_org_template_attributes;
    END IF;
    IF c_get_global_flex_fields%ISOPEN THEN
      CLOSE c_get_global_flex_fields;
    END IF;
    RAISE;
  END initialize_template_info;


-- -----------------------------------------------------------------------------
--  API Name:       Update_Item_Lifecycle
-- -----------------------------------------------------------------------------

Procedure Process_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  P_TRANSACTION_TYPE            IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
)
IS
BEGIN
  SAVEPOINT Process_Item_Lifecycle;
  developer_debug ('::2960442::Process_Item_Lifecycle::start');
  X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;

  IF (P_TRANSACTION_TYPE = G_CREATE_TRANSACTION_TYPE) THEN
    Create_Item_Lifecycle(
      P_API_VERSION       => P_API_VERSION,
      P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
      P_COMMIT            => P_COMMIT,
      P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
      P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
      P_LIFECYCLE_ID      => P_LIFECYCLE_ID,
      P_CURRENT_PHASE_ID  => P_CURRENT_PHASE_ID,
      P_ITEM_STATUS       => P_ITEM_STATUS,
      X_RETURN_STATUS     => X_RETURN_STATUS,
      X_MSG_COUNT         => X_MSG_COUNT
    );
  ELSIF (P_TRANSACTION_TYPE = G_UPDATE_TRANSACTION_TYPE) THEN
    Update_Item_Lifecycle(
      P_API_VERSION       => P_API_VERSION,
      P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
      P_COMMIT            => P_COMMIT,
      P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
      P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
      P_CATALOG_GROUP_ID  => P_CATALOG_GROUP_ID,
      P_LIFECYCLE_ID      => P_LIFECYCLE_ID,
      P_CURRENT_PHASE_ID  => P_CURRENT_PHASE_ID,
      P_ITEM_STATUS       => P_ITEM_STATUS,
      X_RETURN_STATUS     => X_RETURN_STATUS,
      X_MSG_COUNT         => X_MSG_COUNT
    );
  END IF;
  developer_debug ('::2960442::Process_Item_Lifecycle::end');
EXCEPTION
  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Item_Lifecycle;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN others THEN
    ROLLBACK TO Process_Item_Lifecycle;
    X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;

END Process_Item_Lifecycle;

Procedure Create_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
)
IS
BEGIN
  SAVEPOINT Create_Item_Lifecycle;
  developer_debug ('::2960442::Create_Item_Lifecycle::start');
  X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;

  UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

  UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

  UPDATE MTL_SYSTEM_ITEMS_B SET INVENTORY_ITEM_STATUS_CODE = P_ITEM_STATUS
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

  UPDATE MTL_PENDING_ITEM_STATUS SET LIFECYCLE_ID = P_LIFECYCLE_ID
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

  UPDATE MTL_PENDING_ITEM_STATUS SET PHASE_ID = P_CURRENT_PHASE_ID
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;

  UPDATE MTL_PENDING_ITEM_STATUS SET STATUS_CODE = P_ITEM_STATUS
  WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
  AND   ORGANIZATION_ID = P_ORGANIZATION_ID;
  developer_debug ('::2960442::Create_Item_Lifecycle::end');
  COMMIT;


EXCEPTION
  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Item_Lifecycle;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN others THEN
    ROLLBACK TO Create_Item_Lifecycle;
    X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Item_Lifecycle;

Procedure Update_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
)
IS
  CURSOR ego_item_assigned_org_csr
  (
    v_inventory_item_id       IN   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
    v_master_organization_id  IN   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE
  ) IS
  SELECT ORGANIZATION_ID
  FROM MTL_SYSTEM_ITEMS_VL
  WHERE INVENTORY_ITEM_ID = v_inventory_item_id
  AND   ORGANIZATION_ID <> v_master_organization_id;

  L_SYSDATE                DATE := Sysdate;
  L_LIFECYCLE_ID           NUMBER;
  L_CURRENT_PHASE_ID       NUMBER;
  L_MASTER_ORGANIZATION_ID NUMBER;
  L_ORGANIZATION_ID        NUMBER;
  L_ITEM_ASSIGNED_ORG_REC  ego_item_assigned_org_csr%ROWTYPE;
  L_CONTROL_LEVEL          NUMBER;

BEGIN
  SAVEPOINT Update_Item_Lifecycle;
  developer_debug ('::2960442::Update_Item_Lifecycle::start');
  X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;

  L_MASTER_ORGANIZATION_ID := EGO_UI_ITEM_PUB.Get_Master_Organization_Id(P_ORGANIZATION_ID => P_ORGANIZATION_ID);

  IF (P_ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID) THEN
    IF (P_CATALOG_GROUP_ID IS NULL) THEN
      UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = NULL
      WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;

      UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = NULL
      WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
    ELSE
      L_CONTROL_LEVEL := EGO_UI_ITEM_PUB.Get_Item_Attr_Control_Level(P_ITEM_ATTRIBUTE => 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE');

      -- Insert a row to Mtl_Pending_Item_Status table with master organization id
      -- and pending_flag = N.
      INSERT INTO MTL_PENDING_ITEM_STATUS
      (
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        EFFECTIVE_DATE,
        IMPLEMENTED_DATE,
        PENDING_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LIFECYCLE_ID,
        PHASE_ID,
        STATUS_CODE
      )
      VALUES
      (
        P_INVENTORY_ITEM_ID,
        L_MASTER_ORGANIZATION_ID,
        L_SYSDATE,
        L_SYSDATE,
        'N',
        L_SYSDATE,
        g_USER_ID,
        L_SYSDATE,
        g_USER_ID,
        P_LIFECYCLE_ID,
        P_CURRENT_PHASE_ID,
        P_ITEM_STATUS
      );

      IF (L_CONTROL_LEVEL = 2) THEN
        -- Org Control
        UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
        WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
        AND   ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID;

        UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
        WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
        AND   ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID;

        OPEN ego_item_assigned_org_csr (v_inventory_item_id => P_INVENTORY_ITEM_ID,
                                        v_master_organization_id => L_MASTER_ORGANIZATION_ID);
        LOOP
          FETCH ego_item_assigned_org_csr INTO L_ITEM_ASSIGNED_ORG_REC;
          EXIT WHEN ego_item_assigned_org_csr%NOTFOUND;

          INSERT INTO MTL_PENDING_ITEM_STATUS
          (
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            EFFECTIVE_DATE,
            PENDING_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LIFECYCLE_ID,
            PHASE_ID,
            STATUS_CODE
          )
          VALUES
          (
            P_INVENTORY_ITEM_ID,
            L_ITEM_ASSIGNED_ORG_REC.ORGANIZATION_ID,
            L_SYSDATE,
            'Y',
            L_SYSDATE,
            g_USER_ID,
            L_SYSDATE,
            g_USER_ID,
            P_LIFECYCLE_ID,
            P_CURRENT_PHASE_ID,
            P_ITEM_STATUS
          );

        END LOOP;
        CLOSE ego_item_assigned_org_csr;
      ELSE
        -- Master Control
        UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
        WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;

        UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
        WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;

        OPEN ego_item_assigned_org_csr (v_inventory_item_id => P_INVENTORY_ITEM_ID,
                                        v_master_organization_id => L_MASTER_ORGANIZATION_ID);
        LOOP
          FETCH ego_item_assigned_org_csr INTO L_ITEM_ASSIGNED_ORG_REC;
          EXIT WHEN ego_item_assigned_org_csr%NOTFOUND;

          INSERT INTO MTL_PENDING_ITEM_STATUS
          (
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            EFFECTIVE_DATE,
            IMPLEMENTED_DATE,
            PENDING_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LIFECYCLE_ID,
            PHASE_ID,
            STATUS_CODE
          )
          VALUES
          (
            P_INVENTORY_ITEM_ID,
            L_ITEM_ASSIGNED_ORG_REC.ORGANIZATION_ID,
            L_SYSDATE,
            L_SYSDATE,
            'N',
            L_SYSDATE,
            g_USER_ID,
            L_SYSDATE,
            g_USER_ID,
            P_LIFECYCLE_ID,
            P_CURRENT_PHASE_ID,
            P_ITEM_STATUS
          );

        END LOOP;
        CLOSE ego_item_assigned_org_csr;

      END IF;
    END IF;
  END IF;
  developer_debug ('::2960442::Update_Item_Attr_Ext::start');
  Update_Item_Attr_Ext(P_API_VERSION => P_API_VERSION,
                       P_INIT_MSG_LIST         => P_INIT_MSG_LIST,
                       P_COMMIT                => P_COMMIT,
                       P_INVENTORY_ITEM_ID     => P_INVENTORY_ITEM_ID,
                       P_ITEM_CATALOG_GROUP_ID => P_CATALOG_GROUP_ID,
                       X_RETURN_STATUS         => X_RETURN_STATUS,
                       X_MSG_COUNT             => X_MSG_COUNT);
  developer_debug ('::2960442::Update_Item_Attr_Ext::end');
  developer_debug ('::2960442::Update_Item_Lifecycle::end');
  COMMIT;

EXCEPTION
  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Item_Lifecycle;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN others THEN
    ROLLBACK TO Update_Item_Lifecycle;
    X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Item_Lifecycle;

-- -----------------------------------------------------------------------------
--  API Name:           Update_Item_Attr_Ext
-- -----------------------------------------------------------------------------

Procedure Update_Item_Attr_Ext(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ITEM_CATALOG_GROUP_ID       IN   NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER
)
IS
BEGIN
  SAVEPOINT Update_Item_Attr_Ext;
  developer_debug ('::2960442::Update_Item_Attr_Ext::start');
  X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;

  IF (P_ITEM_CATALOG_GROUP_ID IS NULL) THEN
    DELETE FROM EGO_MTL_SY_ITEMS_EXT_B WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
    DELETE FROM EGO_MTL_SY_ITEMS_EXT_TL WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
  ELSE
    UPDATE EGO_MTL_SY_ITEMS_EXT_B SET ITEM_CATALOG_GROUP_ID = P_ITEM_CATALOG_GROUP_ID
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;

    UPDATE EGO_MTL_SY_ITEMS_EXT_TL SET ITEM_CATALOG_GROUP_ID = P_ITEM_CATALOG_GROUP_ID
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
  END IF;
  developer_debug ('::2960442::Update_Item_Attr_Ext::end');
  COMMIT;

EXCEPTION
  WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Item_Attr_Ext;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN others THEN
    ROLLBACK TO Update_Item_Attr_Ext;
    X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Item_Attr_Ext;


/******************************************************************
** Procedure: Get_Master_Organization_Id (unexposed)
********************************************************************/

FUNCTION Get_Master_Organization_Id(
  P_ORGANIZATION_ID  IN NUMBER
) RETURN NUMBER
IS
  L_MASTER_ORGANIZATION_ID NUMBER;
BEGIN
  SELECT MP.MASTER_ORGANIZATION_ID INTO L_MASTER_ORGANIZATION_ID
  FROM MTL_PARAMETERS MP
  WHERE MP.ORGANIZATION_ID = P_ORGANIZATION_ID;

  RETURN L_MASTER_ORGANIZATION_ID;
END Get_Master_Organization_Id;

/******************************************************************
** Procedure: Get_Item_Attr_Control_Level (unexposed)
********************************************************************/

FUNCTION Get_Item_Attr_Control_Level(
  P_ITEM_ATTRIBUTE IN VARCHAR2
) RETURN NUMBER
IS
  L_CONTROL_LEVEL NUMBER;
BEGIN
  SELECT LOOKUP_CODE2 INTO L_CONTROL_LEVEL
  FROM MTL_ITEM_ATTRIBUTES_V
  WHERE ATTRIBUTE_NAME = P_ITEM_ATTRIBUTE;

  RETURN L_CONTROL_LEVEL;
END Get_Item_Attr_Control_Level;

-- -----------------------------------------------------------------------------
--  API Name:       Set_Debug_Parameters
-- -----------------------------------------------------------------------------

/******************************************************************
** Procedure: Set_Debug_Parameters (unexposed)
** Purpose: Will take input as the debug parameters and check if
** a debug session needs to be eastablished. If yes, the it will
** open a debug session file and all developer messages will be
** logged into a debug error file. File name will be the parameter
** debug_file_name_<session_id>
********************************************************************/
Procedure Set_Debug_Parameters(
      P_debug_flag      IN VARCHAR2
    , P_output_dir      IN VARCHAR2
    , P_debug_filename  IN VARCHAR2
)
IS
l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_token_Tbl   Error_Handler.Token_Tbl_Type;
l_return_status   VARCHAR2(1);
l_Debug_Flag      VARCHAR2(1) := p_debug_flag;
BEGIN

IF p_debug_flag = 'Y'
THEN
  -- dbms_output.put_line('Debug is Yes ' );

  IF trim(p_output_dir) IS NULL OR trim(p_output_dir) = ''
  THEN
    -- If debug is Y then out dir must be
    -- specified
    Error_Handler.Add_Error_Token
    (   p_Message_text       =>
        ' Debug is set to Y so an output directory' ||
        ' must be specified. Debug will be turned' ||
        ' off since no directory is specified'
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
    );

    Ego_Catalog_Group_Err_Handler.Log_Error
    (  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     , p_error_status => 'W'
     , p_error_level => Error_Handler.G_BO_LEVEL
    );
    l_debug_flag := 'N';

    -- dbms_output.put_line('Reverting debug to N ' );
  END IF;

  IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = ''
  THEN

    Error_Handler.Add_Error_Token
    (  p_Message_text       =>
       'Debug is set to Y so an output filename' ||
       ' must be specified. Debug will be turned' ||
       ' off since no filename is specified'
     , p_Mesg_Token_Tbl     => l_mesg_token_tbl
     , x_Mesg_Token_Tbl     => l_mesg_token_tbl
     , p_Token_Tbl          => l_token_tbl
    );

    Ego_Catalog_Group_Err_Handler.Log_Error
    (  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     , p_error_status => 'W'
     , p_error_level => Error_Handler.G_BO_LEVEL
    );
    l_debug_flag := 'N';


    -- dbms_output.put_line('Reverting debug to N ' );

  END IF;
  Error_Handler.Set_Debug(l_debug_flag);

  IF p_debug_flag = 'Y'
  THEN
    Error_Handler.Open_Debug_Session
    (  p_debug_filename     => p_debug_filename
     , p_output_dir         => p_output_dir
     , x_return_status      => l_return_status
     , p_mesg_token_tbl     => l_mesg_token_tbl
     , x_mesg_token_tbl     => l_mesg_token_tbl
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS     THEN
       Error_Handler.Set_Debug('N');
    END IF;
  END IF;
END IF;
END Set_Debug_Parameters;


-- -----------------------------------------------------------------------------
--  API Name:       Delete_Extra_Item_Long_Desc_AG
--
--  Description:
--    A private helper function for use with Seed_Item_Long_Desc_Attr_Group;
--    After a call to Copy_User_Attrs_Data in item creation from copy, it will
--    delete all but one Item Long Desc AG row.  See bug 3023736 for details.
-- -----------------------------------------------------------------------------

PROCEDURE Delete_Extra_Item_Long_Desc_AG (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
) IS

    l_ext_id_to_delete_list  VARCHAR2(200);
    l_dynamic_sql            VARCHAR2(1000);

    CURSOR Ext_Id_To_Delete_Cursor (
        cp_inventory_item_id            IN  NUMBER
       ,cp_organization_id              IN  NUMBER
    ) IS
    SELECT EXTENSION_ID
      FROM EGO_MTL_SY_ITEMS_EXT_VL
     WHERE INVENTORY_ITEM_ID = cp_inventory_item_id
       AND ORGANIZATION_ID = cp_organization_id
       AND ATTR_GROUP_ID = (SELECT ATTR_GROUP_ID
                              FROM EGO_FND_DSC_FLX_CTX_EXT
                             WHERE APPLICATION_ID = 431
                               AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP'
                               AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'ItemDetailDesc')
       AND C_EXT_ATTR1 = 'D';

  BEGIN

    FOR ext_rec IN Ext_Id_To_Delete_Cursor(p_inventory_item_id, p_organization_id)
    LOOP

       IF (Ext_Id_To_Delete_Cursor%ROWCOUNT > 1) THEN
        l_ext_id_to_delete_list := l_ext_id_to_delete_list || ext_rec.EXTENSION_ID || ',';
      END IF;

    END LOOP;

    IF (LENGTH(l_ext_id_to_delete_list) > 0) THEN
      -----------------------------------------------
      -- ...trim the trailing ',' from the list... --
      -----------------------------------------------
      l_ext_id_to_delete_list := SUBSTR(l_ext_id_to_delete_list, 1, LENGTH(l_ext_id_to_delete_list) - LENGTH(','));

      ----------------------------------------------------------------------
      -- ...and then delete all rows in the list from the B and TL tables --
      ----------------------------------------------------------------------
      l_dynamic_sql := ' DELETE FROM EGO_MTL_SY_ITEMS_EXT_B'||
                        ' WHERE EXTENSION_ID IN ('||l_ext_id_to_delete_list||')';
      EXECUTE IMMEDIATE l_dynamic_sql;

      l_dynamic_sql := ' DELETE FROM EGO_MTL_SY_ITEMS_EXT_TL'||
                        ' WHERE EXTENSION_ID IN ('||l_ext_id_to_delete_list||')';
      EXECUTE IMMEDIATE l_dynamic_sql;
    END IF;

END Delete_Extra_Item_Long_Desc_AG;


-- -----------------------------------------------------------------------------
--  API Name:       Process_Item
-- -----------------------------------------------------------------------------

PROCEDURE Process_Item
(
   p_api_version            IN  NUMBER
,  p_init_msg_list      IN  VARCHAR2
,  p_commit             IN  VARCHAR2
 -- Transaction data
,  p_Transaction_Type       IN  VARCHAR2
,  p_Language_Code      IN  VARCHAR2
 -- Organization
,  p_Organization_Id        IN  NUMBER
,  p_Organization_Code      IN  VARCHAR2
 -- Item catalog group
,  p_Item_Catalog_Group_Id  IN  NUMBER
,  p_Catalog_Status_Flag    IN  VARCHAR2
 -- Copy item from
,  p_Template_Id            IN  NUMBER
,  p_Template_Name      IN  VARCHAR2
 -- Item identifier
,  p_Inventory_Item_Id      IN  NUMBER
,  p_Item_Number            IN  VARCHAR2
,  p_Segment1           IN  VARCHAR2
,  p_Segment2           IN  VARCHAR2
,  p_Segment3           IN  VARCHAR2
,  p_Segment4           IN  VARCHAR2
,  p_Segment5           IN  VARCHAR2
,  p_Segment6           IN  VARCHAR2
,  p_Segment7           IN  VARCHAR2
,  p_Segment8           IN  VARCHAR2
,  p_Segment9           IN  VARCHAR2
,  p_Segment10          IN  VARCHAR2
,  p_Segment11          IN  VARCHAR2
,  p_Segment12          IN  VARCHAR2
,  p_Segment13          IN  VARCHAR2
,  p_Segment14          IN  VARCHAR2
,  p_Segment15          IN  VARCHAR2
,  p_Segment16          IN  VARCHAR2
,  p_Segment17          IN  VARCHAR2
,  p_Segment18          IN  VARCHAR2
,  p_Segment19          IN  VARCHAR2
,  p_Segment20          IN  VARCHAR2
,  p_Object_Version_Number  IN  NUMBER
 -- Lifecycle
,  p_Lifecycle_Id           IN  NUMBER
,  p_Current_Phase_Id       IN  NUMBER
 -- Main attributes
,  p_Description            IN  VARCHAR2
,  p_Long_Description       IN  VARCHAR2
,  p_Primary_Uom_Code       IN  VARCHAR2
,  p_Inventory_Item_Status_Code IN  VARCHAR2
 -- BoM/Eng
,  p_Bom_Enabled_Flag       IN  VARCHAR2
,  p_Eng_Item_Flag      IN  VARCHAR2
 -- Role Grant
,  p_Role_Id            IN  NUMBER
,  p_Role_Name          IN  VARCHAR2
,  p_Grantee_Party_Type     IN  VARCHAR2
,  p_Grantee_Party_Id       IN  NUMBER
,  p_Grantee_Party_Name     IN  VARCHAR2
,  p_Grant_Start_Date       IN  DATE
,  p_Grant_End_Date     IN  DATE
-- Returned item id
,  x_Inventory_Item_Id      OUT NOCOPY  NUMBER
,  x_Organization_Id        OUT NOCOPY  NUMBER
 --
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_msg_count          OUT NOCOPY  NUMBER
)
IS
  l_api_name       CONSTANT    VARCHAR2(30)   :=  'Process_Item';
  l_api_version    CONSTANT    NUMBER         :=  1.0;

  indx                         BINARY_INTEGER :=  1;

   CURSOR c_fnd_object_id(cp_object_name  IN VARCHAR2) IS
   SELECT  object_id
   FROM    fnd_objects
   WHERE   obj_name = cp_object_name;

   CURSOR c_get_application_id IS
   SELECT  application_id
   FROM    fnd_application
   WHERE   application_short_name = 'EGO';

   CURSOR c_get_orig_item_rev_details (cp_inventory_item_id IN NUMBER
                                      ,cp_organization_id   IN NUMBER) IS
    SELECT revision, revision_id
    FROM MTL_ITEM_REVISIONS_B
    WHERE inventory_item_id = cp_inventory_item_id
      AND organization_id   = cp_organization_id
      AND effectivity_date <= SYSDATE
    ORDER BY effectivity_date desc;


  l_object_id       FND_OBJECTS.object_id%TYPE;
  l_return_status   VARCHAR2(10);
  l_error_code      NUMBER;
  l_msg_data        VARCHAR2(9999);
  l_application_id                fnd_application.application_id%TYPE;
  l_orig_item_pk_value_pairs      EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_item_pk_value_pairs       EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_orig_item_rev_pk_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_item_rev_pk_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_cc_col_value_pairs        EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_item_rev_id                   mtl_item_revisions_b.revision_id%TYPE;
  l_item_rev_code                 mtl_item_revisions_b.revision%TYPE;
  l_commit                        VARCHAR2(20);

BEGIN

developer_debug ('::2960442::Process_Item::start');
-------------------------------------------------------------
-- TODO:
-- the following parameters are never used in this procedure
-- are these really required??
-------------------------------------------------------------
--,  p_Object_Version_Number    IN  NUMBER
-- BoM/Eng
--,  p_Bom_Enabled_Flag     IN  VARCHAR2
--,  p_Eng_Item_Flag        IN  VARCHAR2
 -- Role Grant
--,  p_Role_Id          IN  NUMBER
--,  p_Role_Name        IN  VARCHAR2
--,  p_Grantee_Party_Type   IN  VARCHAR2
--,  p_Grantee_Party_Id     IN  NUMBER
--,  p_Grantee_Party_Name   IN  VARCHAR2
--,  p_Grant_Start_Date     IN  DATE
--,  p_Grant_End_Date       IN  DATE

developer_debug (' Entered EGO_UI_ITEM_PUB.Process_item  Input Parameters ' );
developer_debug ('   p_api_version      '||to_char(p_api_version));
developer_debug ('   p_init_msg_list    '|| p_init_msg_list);
developer_debug ('   p_commit       '|| p_commit);
developer_debug ('   p_Transaction_Type '||p_transaction_type);
developer_debug ('   p_Language_Code    '||p_language_code);
developer_debug ('   p_Organization_Id  '||to_char(p_organization_id));
developer_debug ('   p_Organization_Code    '||p_organization_code);
developer_debug ('   p_Item_Catalog_Group_Id    '||to_char(p_item_catalog_group_id));
developer_debug ('   p_Catalog_Status_Flag  '|| p_Catalog_Status_Flag);
developer_debug ('   p_Template_Id          '|| to_char(p_template_id));
developer_debug ('   p_Template_Name        '||p_template_name);
developer_debug ('   p_Inventory_Item_Id    '||to_char(p_inventory_item_id));
developer_debug ('   p_Item_Number          '|| p_item_number);
developer_debug ('   p_Segment1         '|| p_segment1);
developer_debug ('   p_Segment2         '|| p_segment2);
developer_debug ('   p_Segment3         '|| p_segment3);
developer_debug ('   p_Segment4         '|| p_segment4);
developer_debug ('   p_Segment5         '|| p_segment5);
developer_debug ('   p_Segment6         '|| p_segment6);
developer_debug ('   p_Segment7         '|| p_segment7);
developer_debug ('   p_Segment8         '|| p_segment8);
developer_debug ('   p_Segment9         '|| p_segment9);
developer_debug ('   p_Segment10        '|| p_segment10);
developer_debug ('   p_Segment11        '|| p_segment11);
developer_debug ('   p_Segment12        '|| p_segment12);
developer_debug ('   p_Segment13        '|| p_segment13);
developer_debug ('   p_Segment14        '|| p_segment14);
developer_debug ('   p_Segment15        '|| p_segment15);
developer_debug ('   p_Segment16        '|| p_segment16);
developer_debug ('   p_Segment17        '|| p_segment17);
developer_debug ('   p_Segment18        '|| p_segment18);
developer_debug ('   p_Segment19        '|| p_segment19);
developer_debug ('   p_Segment20        '|| p_segment20);
developer_debug ('   p_Object_Version_Number    '||to_char(p_Object_Version_Number));
developer_debug ('   p_Lifecycle_Id         '||to_char(p_Lifecycle_Id));
developer_debug ('   p_Current_Phase_Id     '||to_char(p_Current_Phase_Id));
developer_debug ('   p_Description          '|| p_description);
developer_debug ('   p_Long_Description     '|| p_long_description);
developer_debug ('   p_Primary_Uom_Code     '|| p_Primary_Uom_Code);
developer_debug ('   p_Inventory_Item_Status_Code   '|| p_inventory_item_status_code);
developer_debug ('   p_Bom_Enabled_Flag     '|| p_bom_enabled_flag);
developer_debug ('   p_Eng_Item_Flag        '|| p_eng_item_flag);
developer_debug ('   p_Role_Id          '||to_char(p_Role_Id));
developer_debug ('   p_Role_Name        '|| p_role_name);
developer_debug ('   p_Grantee_Party_Type   '|| p_grantee_party_type);
developer_debug ('   p_Grantee_Party_Id     '||to_char(p_Grantee_Party_Id));
developer_debug ('   p_Grantee_Party_Name   '|| p_grantee_party_name);
developer_debug ('   p_Grant_Start_Date     '||to_char(p_grant_start_date,'DD-MON-YYYY'));
developer_debug ('   p_Grant_End_Date       '||to_char(p_grant_end_date,'DD-MON-YYYY'));

  -- need to add code here
  -- check if the correct signature is passed.
  IF p_api_version <> l_api_version THEN
    -- invalid api version, return back immediately.
    EGO_Item_Msg.Add_Error_Message
       (p_entity_index           => indx
       ,p_application_short_name => 'EGO'
       ,p_message_name           => 'EGO_PKG_INVALID_API_VER'
       ,p_token_name1            => 'PACKAGE'
       ,p_token_value1           => G_PKG_NAME
       ,p_translate1             => FALSE
       ,p_token_name2            => 'PROCEDURE'
       ,p_token_value2           => l_api_name
       ,p_translate2             => FALSE
       ,p_token_name3            => 'API_VERSION'
       ,p_token_value3           => TO_CHAR(p_api_version)
       ,p_translate3             => FALSE
       );
    x_return_status := G_RET_STS_ERROR;
    RETURN;
  END IF;
developer_debug (' Correct api version passed');
  IF p_transaction_type = G_COPY_TRANSACTION_TYPE THEN
    -- collect all the parameters from the parent item (p_Inventory_item_id)
    IF p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL THEN
      -- initialize with the item id passed values
      initialize_item_info (p_inventory_item_id => p_inventory_item_id
                           ,p_organization_id   => p_organization_id
               ,x_return_status     => x_return_status
               ,x_msg_count         => x_msg_count
               );
      IF x_return_status <>  G_RET_STS_SUCCESS THEN
        RETURN;
      ELSE
        -- get the template info now
        initialize_template_info (p_template_id         => p_template_id
                                 ,p_template_name       => p_template_name
                                 ,p_organization_id     => p_organization_id
                                 ,p_organization_code   => p_organization_code
                                 ,x_return_status       => x_return_status
                                 ,x_msg_count           => x_msg_count
                 );
        IF x_return_status <> G_RET_STS_SUCCESS THEN
          RETURN;
        END IF; -- x-return_status fro initialize_template_info
      END IF;  -- x-return_status fro initialize_item_info
    ELSE
developer_debug (' No inventory item id OR organization id passed ');
    EGO_Item_Msg.Add_Error_Message
       (p_entity_index           => indx
       ,p_application_short_name => 'EGO'
       ,p_message_name           => 'EGO_PKG_MAND_VALUES_MISS'
       ,p_token_name1            => 'PACKAGE'
       ,p_token_value1           => G_PKG_NAME||'.'||l_api_name
       ,p_translate1             => FALSE
       ,p_token_name2            => 'VALUE1'
       ,p_token_value2           => 'INVENTORY_ITEM_ID'
       ,p_translate2             => FALSE
       ,p_token_name3            => 'VALUE2'
       ,p_token_value3           => 'ORGANIZATION_ID'
       ,p_translate3             => FALSE
       );
      x_return_status := G_RET_STS_ERROR;
      RETURN;
    END IF;  -- p_inventory_item_id IS NOT NULL / p_organization_id IS NOT NULL
developer_debug (' Correct api and Inventory Item information passed');
    -- all the item info available in the UI
    g_in_item_tbl(0).transaction_type           := G_CREATE_TRANSACTION_TYPE;
    g_in_item_tbl(0).Language_Code              := p_language_code;
    g_in_item_tbl(0).Template_Id                := NULL;
    g_in_item_tbl(0).Template_Name              := NULL;
    g_in_item_tbl(0).Item_Number                := p_item_number;
    g_in_item_tbl(0).segment1                   := p_segment1;
    g_in_item_tbl(0).segment2                   := p_segment2;
    g_in_item_tbl(0).segment3                   := p_segment3;
    g_in_item_tbl(0).segment4                   := p_segment4;
    g_in_item_tbl(0).segment5                   := p_segment5;
    g_in_item_tbl(0).segment6                   := p_segment6;
    g_in_item_tbl(0).segment7                   := p_segment7;
    g_in_item_tbl(0).segment8                   := p_segment8;
    g_in_item_tbl(0).segment9                   := p_segment9;
    g_in_item_tbl(0).segment10                  := p_segment10;
    g_in_item_tbl(0).segment11                  := p_segment11;
    g_in_item_tbl(0).segment12                  := p_segment12;
    g_in_item_tbl(0).segment13                  := p_segment13;
    g_in_item_tbl(0).segment14                  := p_segment14;
    g_in_item_tbl(0).segment15                  := p_segment15;
    g_in_item_tbl(0).segment16                  := p_segment16;
    g_in_item_tbl(0).segment17                  := p_segment17;
    g_in_item_tbl(0).segment18                  := p_segment18;
    g_in_item_tbl(0).segment19                  := p_segment19;
    g_in_item_tbl(0).segment20                  := p_segment20;
    g_in_item_tbl(0).Organization_Id            := p_organization_id;
    g_in_item_tbl(0).Organization_Code          := p_organization_code;
    g_in_item_tbl(0).Item_Catalog_Group_Id      := p_item_catalog_group_id;
    g_in_item_tbl(0).Catalog_Status_Flag        := p_catalog_status_flag;
    g_in_item_tbl(0).Lifecycle_Id               := p_lifecycle_id;
    g_in_item_tbl(0).Current_Phase_Id           := p_current_phase_id;
    g_in_item_tbl(0).Description                := p_description;
    g_in_item_tbl(0).Long_Description           := p_long_description;
    g_in_item_tbl(0).Primary_Uom_Code           := p_primary_uom_code;
    g_in_item_tbl(0).Inventory_Item_Status_Code := p_Inventory_Item_Status_Code;

     developer_debug (' Before calling ego_item_pub.process_items');
      EGO_ITEM_PUB.Process_Items
             (p_api_version    => 1.0
             ,p_init_msg_list  => FND_API.g_FALSE
             ,p_commit         => FND_API.g_FALSE
             ,p_Item_Tbl       => g_in_item_tbl
             ,p_Role_Grant_Tbl => EGO_ITEM_PUB.G_MISS_ROLE_GRANT_TBL
             ,x_Item_Tbl       => g_out_item_tbl
             ,x_return_status  => x_return_status
             ,x_msg_count      => x_msg_count
             );
      IF x_return_status =  FND_API.G_RET_STS_SUCCESS THEN
        -- item created successfully
        x_inventory_item_id := g_out_item_tbl(0).inventory_item_id;
        x_organization_id   := g_out_item_tbl(0).organization_id;
      ELSE
        -- messages already logged by EGO_ITEM_PUB
        RETURN;
      END IF;  -- x_return_status = FND_API.G_RET_STS_SUCCESS
      OPEN c_fnd_object_id (cp_object_name  => G_OBJECT_NAME);
      FETCH c_fnd_object_id INTO l_object_id;
      IF c_fnd_object_id%NOTFOUND THEN
        l_object_id := -1;
      END IF;
developer_debug(' Object Information passed ');
      CLOSE c_fnd_object_id;
      OPEN c_get_application_id;
      FETCH c_get_application_id INTO l_application_id;
      IF c_get_application_id%NOTFOUND THEN
        l_application_id := -1;
      END IF;
      CLOSE c_get_application_id;
developer_debug (' Original Item Id ' || to_char(p_inventory_item_id));
developer_debug (' Original Org  Id ' || to_char(p_organization_id));
developer_debug (' Object  Id ' || to_char(l_object_id));
developer_debug (' Application  Id ' || to_char(l_application_id));
developer_debug (' New Item Id ' || to_char(x_inventory_item_id));
developer_debug (' New Org  Id ' || to_char(x_organization_id));
      -- call the user attributes code for item level
      l_orig_item_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
         EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_inventory_item_id),
         EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', p_organization_id));
      l_new_item_pk_value_pairs  := EGO_COL_NAME_VALUE_PAIR_ARRAY(
         EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', x_inventory_item_id),
         EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', x_organization_id));

      l_orig_item_rev_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
--         EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION', NULL),
         EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', NULL));
      l_new_item_rev_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
--         EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION', NULL),
         EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', NULL));
      l_new_cc_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
           EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', p_Item_Catalog_Group_Id));
developer_debug(' Before calling   EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data ');
      EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data (
         p_api_version                   => 1.0
        ,p_application_id                => l_application_id
        ,p_object_id                     => l_object_id
        ,p_object_name                   => G_OBJECT_NAME
        ,p_old_pk_col_value_pairs        => l_orig_item_pk_value_pairs
        ,p_old_dtlevel_col_value_pairs   => l_orig_item_rev_pk_value_pairs
        ,p_new_pk_col_value_pairs        => l_new_item_pk_value_pairs
        ,p_new_dtlevel_col_value_pairs   => l_new_item_rev_pk_value_pairs
        ,p_new_cc_col_value_pairs        => l_new_cc_col_value_pairs
        ,p_commit                        => FND_API.G_FALSE
        ,x_return_status                 => x_return_status
        ,x_errorcode                     => l_error_code
        ,x_msg_count                     => x_msg_count
        ,x_msg_data                      => l_msg_data
        );
developer_debug(' 20  Returning from    EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data  ' );
IF x_return_status = fnd_api.g_miss_char THEN
developer_debug(' 21 ');
ELSIF x_return_status IS NULL THEN
developer_debug(' 22 ');
ELSE
developer_debug(' 23 '||x_return_status);
END IF;

      IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        -- error handled in Ego_user_attrs_data_pub
        RETURN;
      END IF;
      -- call the user attributes code for revision level
developer_debug(' 30 ');
      OPEN c_get_orig_item_rev_details (cp_inventory_item_id => p_inventory_item_id
                                       ,cp_organization_id   => p_organization_id);
      FETCH c_get_orig_item_rev_details INTO l_item_rev_code, l_item_rev_id;
developer_debug(' 40 ');
      IF c_get_orig_item_rev_details%FOUND THEN
        CLOSE c_get_orig_item_rev_details;
developer_debug(' 50 ');
        l_orig_item_rev_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
            EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', l_item_rev_id));
developer_debug(' 55  -- orig revision ' || l_item_rev_code);
    -- fetch the item revision of the newly created item.
developer_debug(' 60 ');
        OPEN c_get_orig_item_rev_details (cp_inventory_item_id => x_inventory_item_id
                                         ,cp_organization_id   => x_organization_id);
        FETCH c_get_orig_item_rev_details INTO l_item_rev_code, l_item_rev_id;
    IF c_get_orig_item_rev_details%FOUND THEN
developer_debug(' 70 ');
        l_new_item_rev_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
            EGO_COL_NAME_VALUE_PAIR_OBJ('REVISION_ID', l_item_rev_id));
developer_debug(' 75  -- new revision ' || l_item_rev_code);
        ELSE
      l_new_item_rev_pk_value_pairs := NULL;
    END IF;
developer_debug(' 80 ');
    CLOSE c_get_orig_item_rev_details;
        l_new_cc_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
           EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', p_Item_Catalog_Group_Id));
    EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data (
           p_api_version                   => 1.0
          ,p_application_id                => l_application_id
          ,p_object_id                     => l_object_id
          ,p_object_name                   => G_OBJECT_NAME
          ,p_old_pk_col_value_pairs        => l_orig_item_pk_value_pairs
          ,p_old_dtlevel_col_value_pairs   => l_orig_item_rev_pk_value_pairs
          ,p_new_pk_col_value_pairs        => l_new_item_pk_value_pairs
          ,p_new_dtlevel_col_value_pairs   => l_new_item_rev_pk_value_pairs
      ,p_new_cc_col_value_pairs        => l_new_cc_col_value_pairs
          ,p_commit                        => FND_API.G_FALSE
          ,x_return_status                 => x_return_status
          ,x_errorcode                     => l_error_code
          ,x_msg_count                     => x_msg_count
          ,x_msg_data                      => l_msg_data
          );


      -----------------------------------------------------------------------
      -- Dylan added this clean-up procedure to deal with duplicate
      -- Item Long Desc AG rows from the above calls to Copy_User_Attrs_Data
      -- in conjunction with the call that's made to
      --       EGO_ITEM_PUB.Seed_Item_Long_Desc_Attr_Group
      -- from
      --       INVPOPIF.inopinp_OI_process_create
      -----------------------------------------------------------------------
      Delete_Extra_Item_Long_Desc_AG(x_inventory_item_id, x_organization_id);

developer_debug(' 90  Returning from    EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data  -- Revision Part ' );
IF x_return_status = fnd_api.g_miss_char THEN
developer_debug(' 91 ');
ELSIF x_return_status IS NULL THEN
developer_debug(' 92 ');
ELSE
developer_debug(' 93 '||x_return_status);
END IF;
        IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- problem with Copy Revision Attrs Data for item
          RETURN;
        END IF;
      ELSE
developer_debug(' 100 ');
        CLOSE c_get_orig_item_rev_details;
      END IF; -- c_get_orig_item_rev_details%FOUND
--  item revision also created successfully.
--  create the lifecycle details now
      process_item_lifecycle
             (p_api_version         => 1.0
             ,p_init_msg_list       => p_init_msg_list
             ,p_commit              => FND_API.G_FALSE
             ,p_inventory_item_id   => x_inventory_item_id
             ,p_organization_id     => x_organization_id
             ,p_catalog_group_id    => p_item_catalog_group_id
             ,p_lifecycle_id        => p_lifecycle_id
             ,p_current_phase_id    => p_current_phase_id
             ,p_item_status         => p_inventory_item_status_code
             ,p_transaction_type    => G_CREATE_TRANSACTION_TYPE
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             );

developer_debug(' 110  Returning from    Process Item Lifecycle  ' );
IF x_return_status = fnd_api.g_miss_char THEN
developer_debug(' 111 ');
ELSIF x_return_status IS NULL THEN
developer_debug(' 112 ');
ELSE
developer_debug(' 113 '||x_return_status);
END IF;
      IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        -- problem with item lifecycle processing for item
        RETURN;
      END IF;
developer_debug(' 120 ');
  ELSE
developer_debug(' 130  Sent TRANSACTIIOY_TYPE which is not COPY ');
    x_return_status := G_RET_STS_ERROR;
    RETURN;
  END IF; -- p_transaction_type = G_COPY_TRANSACTION_TYPE
developer_debug(' 140 ');

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;
developer_debug ('::2960442::Process_Item::end');
EXCEPTION

  WHEN others THEN
    IF c_fnd_object_id%ISOPEN THEN
      CLOSE c_fnd_object_id;
    END IF;
    IF c_get_application_id%ISOPEN THEN
      CLOSE c_get_application_id;
    END IF;
    IF c_get_orig_item_rev_details%ISOPEN THEN
      CLOSE c_get_orig_item_rev_details;
    END IF;
    x_return_status  :=  G_RET_STS_UNEXP_ERROR;
    EGO_Item_Msg.Add_Error_Message ( indx, 'EGO', 'EGO_PKG_UNEXPECTED_ERROR',
                                       'PACKAGE', G_PKG_NAME, FALSE,
                                       'PROCEDURE', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );

END Process_Item;

-- -----------------------------------------------------------------------------
--  API Name:       Get_Item_Count
-- -----------------------------------------------------------------------------

/**************************************************************************
** Function: Get_Item_Count
** Purpose: Will take input as the organizationId and the cataloggroupId
**  and return the count of items in that organization for that
**  particular catalog group.
** Added a parameter p_item_type for the Item Count to be Session Specific(Bug 3536404)
**************************************************************************/

FUNCTION Get_Item_Count(
p_catalog_group_id IN NUMBER
,p_organization_id IN NUMBER
,p_item_type       IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS

 l_total_count NUMBER :=0;

BEGIN
 IF(p_item_type IS NOT NULL) THEN
  select  count(*) INTO l_total_count
  from mtl_system_items_b a
  where item_catalog_group_id
    in(
      select item_catalog_group_id
     from mtl_item_catalog_groups_b b
     connect by prior item_catalog_group_id = parent_catalog_group_id
     start with b.item_catalog_group_id  =p_catalog_group_id
          )
  and a.organization_id = p_organization_id
  and a.eng_item_flag = p_item_type;
 ELSE
  select  count(*) INTO l_total_count
  from mtl_system_items_b a
  where item_catalog_group_id
    in(
      select item_catalog_group_id
     from mtl_item_catalog_groups_b b
     connect by prior item_catalog_group_id = parent_catalog_group_id
     start with b.item_catalog_group_id  =p_catalog_group_id
          )
  and a.organization_id = p_organization_id;
  END IF;

 return l_total_count;
 EXCEPTION
  WHEN OTHERS THEN
       NULL;

END get_item_count;



/******************************************************************
** Function: Get_Category_Item_Count
** Purpose: Will take input as the organizationId and the cataloggroupId
**  and return the count of items in that organization for that
**  particular category.
** Added a parameter p_item_type for the Item Count to be Session Specific(Bug 3536404)
********************************************************************/

FUNCTION Get_Category_Item_Count(
  P_CATEGORY_SET_ID IN NUMBER,
  P_CATEGORY_ID     IN NUMBER,
  P_ORGANIZATION_ID IN NUMBER,
  P_ITEM_TYPE       IN VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
IS

 l_total_count NUMBER := 0;

BEGIN
 IF (P_CATEGORY_ID <> -1) THEN
  IF(P_ITEM_TYPE IS NOT NULL) THEN
   select count(*) into l_total_count
   from mtl_item_categories a , mtl_system_items_b b
   where category_id in (
         select category_id
         from mtl_category_set_valid_cats
         start with category_id = P_CATEGORY_ID
         and category_set_id = P_CATEGORY_SET_ID  --Corrected the connect clause in count query
         connect by prior category_id = parent_category_id
         and category_set_id = P_CATEGORY_SET_ID
   )
   and a.organization_id = P_ORGANIZATION_ID
   and a.category_set_id = P_CATEGORY_SET_ID
   and a.inventory_item_id = b.inventory_item_id
   and a.organization_id = b.organization_id
   and b.eng_item_flag = P_ITEM_TYPE;
  ELSE
   select count(*) into l_total_count
   from mtl_item_categories a , mtl_system_items_b b
   where category_id in (
         select category_id
         from mtl_category_set_valid_cats
         start with category_id = P_CATEGORY_ID
         and category_set_id = P_CATEGORY_SET_ID  --Corrected the connect clause in count query
         connect by prior category_id = parent_category_id
         and category_set_id = P_CATEGORY_SET_ID
   )
   and a.organization_id = P_ORGANIZATION_ID
   and a.category_set_id = P_CATEGORY_SET_ID
   and a.inventory_item_id = b.inventory_item_id
   and a.organization_id = b.organization_id;
  END IF;
 ELSE
   IF(P_ITEM_TYPE IS NOT NULL) THEN
    select count(*) into l_total_count
    from mtl_item_categories a , mtl_system_items_b b,mtl_category_set_valid_cats c
    where a.organization_id = P_ORGANIZATION_ID
    and a.category_set_id = P_CATEGORY_SET_ID
    and c.category_set_id = P_CATEGORY_SET_ID
    and c.category_id = a.category_id
    and a.inventory_item_id = b.inventory_item_id
    and a.organization_id = b.organization_id
    and b.eng_item_flag = P_ITEM_TYPE;
   ELSE
    select count(*) into l_total_count
    from mtl_item_categories a , mtl_system_items_b b,mtl_category_set_valid_cats c
    where a.organization_id = P_ORGANIZATION_ID
    and a.category_set_id = P_CATEGORY_SET_ID
    and c.category_set_id = P_CATEGORY_SET_ID
    and c.category_id = a.category_id
    and a.inventory_item_id = b.inventory_item_id
    and a.organization_id = b.organization_id;
   END IF;
 END IF;

 return l_total_count;
 EXCEPTION
  WHEN OTHERS THEN
       NULL;

END Get_Category_Item_Count;

FUNCTION Get_Category_Hierarchy_Names(
  P_CATEGORY_SET_ID IN NUMBER,
  P_CATEGORY_ID     IN NUMBER
)
RETURN VARCHAR2
IS

CURSOR get_parent_category_id_csr (p_category_set_id IN  NUMBER,
                                   p_category_id     IN  NUMBER ) IS
  SELECT IC.CATEGORY_ID,
         IC.PARENT_CATEGORY_ID
  FROM MTL_CATEGORY_SET_VALID_CATS IC
  START WITH CATEGORY_ID = p_category_id --3030474
  AND CATEGORY_SET_ID    = p_category_set_id
  CONNECT BY PRIOR PARENT_CATEGORY_ID = CATEGORY_ID
  AND CATEGORY_SET_ID    = p_category_set_id;

  l_parent_categories        get_parent_category_id_csr%ROWTYPE;
  l_category_set_name        VARCHAR2(30);
  l_category_name            VARCHAR2(122);
  l_category_hierarchy_names VARCHAR2(1000);
  l_tmp_names                VARCHAR2(1000);

BEGIN
  SELECT CATEGORY_SET_NAME into l_category_set_name
  FROM MTL_CATEGORY_SETS_VL
  WHERE CATEGORY_SET_ID = P_CATEGORY_SET_ID;

  OPEN get_parent_category_id_csr(p_category_set_id => P_CATEGORY_SET_ID,
                                  p_category_id     => P_CATEGORY_ID);
  LOOP
    FETCH get_parent_category_id_csr into l_parent_categories;
    EXIT WHEN get_parent_category_id_csr%NOTFOUND;

    SELECT C.CONCATENATED_SEGMENTS into l_category_name
    FROM MTL_CATEGORIES_KFV C
    WHERE C.CATEGORY_ID = l_parent_categories.CATEGORY_ID;

    l_tmp_names := l_category_hierarchy_names;
    IF (l_tmp_names IS NULL) THEN
      l_category_hierarchy_names := l_category_name;
    ELSE
      l_category_hierarchy_names := l_category_name || ' > ' || l_tmp_names;
    END IF;
  END LOOP;
  CLOSE get_parent_category_id_csr;

  l_tmp_names := l_category_hierarchy_names;
--Bug: 3018903 Added If condition
  IF l_tmp_names IS NOT NULL THEN
   l_category_hierarchy_names := l_category_set_name || ' > ' || l_tmp_names;
  ELSE
    SELECT C.CONCATENATED_SEGMENTS into l_category_hierarchy_names
    FROM MTL_CATEGORIES_KFV C
    WHERE C.CATEGORY_ID = p_category_id;
  END IF;
  RETURN l_category_hierarchy_names;

END Get_Category_Hierarchy_Names;

-- -----------------------------------------------------------------------------
--  API Name:       Process_Item
-- -----------------------------------------------------------------------------

PROCEDURE Process_Item
(
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
-- attribute not in the form
,p_serviceable_item_class_id      IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_base_warranty_service_id       IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_warranty_vendor_id             IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_max_warranty_amount            IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_response_time_period_code      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
-- attribute not in the form
,p_response_time_value            IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_primary_specialist_id          IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_secondary_specialist_id        IN   NUMBER     DEFAULT  G_MISS_NUM
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
-- derived attributes
--,p_service_item_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--,p_vendor_warranty_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--,p_usage_item_flag                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
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
--added for 11.5.9 enh
,p_lot_substitution_enabled       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_minimum_license_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_eam_activity_source_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--added for 11.5.10 enh
,p_tracking_quantity_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_ont_pricing_qty_source         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_secondary_default_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_option_specific_sourced        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_approval_status                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--
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
 -- Returned item id
,x_Inventory_Item_Id              OUT NOCOPY    NUMBER
,x_Organization_Id                OUT NOCOPY    NUMBER
,x_return_status                  OUT NOCOPY    VARCHAR2
,x_msg_count                      OUT NOCOPY    NUMBER
,x_msg_data                       OUT NOCOPY    VARCHAR2
) IS
  ------------------------------------------------------------------
  -- Start Of comments
  --
  -- Function name   : Process_Item
  -- Type            : Public
  -- Pre-reqs        : IOI should be functional
  -- Functionality   : Process (CREATE/UPDATE) one item using IOI
  -- Notes           : Scalar Signature to Process Item
  --
  --
  -- History         :
  --    23-SEP-2003     Sridhar Rajaparthi    Creation (bug 3143834)
  --
  -- END OF comments
  ------------------------------------------------------------------

  l_api_name       CONSTANT    VARCHAR2(30) :=  'Process_Item_Scalar';
  l_api_version    CONSTANT    NUMBER       :=  1.0;

  indx                 BINARY_INTEGER       :=  1;
  l_item_tbl           EGO_ITEM_PUB.Item_Tbl_Type;
  l_item_created_tbl   EGO_ITEM_PUB.Item_Tbl_Type;

BEGIN
developer_debug (' ISS: Started Item Scalar Signature ');

  -- standard check for API validation
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

developer_debug (' ISS: API version valid ');
  -- create save point
  IF FND_API.To_Boolean(p_commit) THEN
developer_debug (' ISS: Save Point Created ');
    SAVEPOINT Process_Item_Scalar;
  END IF;

  -- Initialize message list
  IF FND_API.To_Boolean(p_init_msg_list) THEN
developer_debug (' ISS: Message list initialized ');
    FND_MSG_PUB.Initialize;
  END IF;

developer_debug (' ISS: processing for transaction type ' || p_transaction_type);
  -- todo validate the parameters
  IF p_transaction_type IN (G_CREATE_TRANSACTION_TYPE, G_UPDATE_TRANSACTION_TYPE) THEN
    --
    -- copy the passed values into the table.
    -- create the table to store all the values.
    --
    -- pre IOI processing
    --
    IF p_transaction_type = G_CREATE_TRANSACTION_TYPE THEN
      l_item_tbl(indx).item_number       :=  p_item_number;
      l_item_tbl(indx).segment1          :=  p_segment1;
      l_item_tbl(indx).segment2          :=  p_segment2;
      l_item_tbl(indx).segment3          :=  p_segment3;
      l_item_tbl(indx).segment4          :=  p_segment4;
      l_item_tbl(indx).segment5          :=  p_segment5;
      l_item_tbl(indx).segment6          :=  p_segment6;
      l_item_tbl(indx).segment7          :=  p_segment7;
      l_item_tbl(indx).segment8          :=  p_segment8;
      l_item_tbl(indx).segment9          :=  p_segment9;
      l_item_tbl(indx).segment10         :=  p_segment10;
      l_item_tbl(indx).segment11         :=  p_segment11;
      l_item_tbl(indx).segment12         :=  p_segment12;
      l_item_tbl(indx).segment13         :=  p_segment13;
      l_item_tbl(indx).segment14         :=  p_segment14;
      l_item_tbl(indx).segment15         :=  p_segment15;
      l_item_tbl(indx).segment16         :=  p_segment16;
      l_item_tbl(indx).segment17         :=  p_segment17;
      l_item_tbl(indx).segment18         :=  p_segment18;
      l_item_tbl(indx).segment19         :=  p_segment19;
      l_item_tbl(indx).segment20         :=  p_segment20;
    ELSE
      --
      -- do not set segment1..20 as IOI cross checks
      -- the inventory_item_id and the segments passed
      --
      NULL;
    END IF;
    l_item_tbl(indx).transaction_type  := p_transaction_type;
-- not passed do leave as it is
--    l_item_tbl(indx).return_status     := NULL;
    l_item_tbl(indx).language_code     :=  p_language_code;
    l_item_tbl(indx).template_id       :=  p_template_id;
    l_item_tbl(indx).template_name     :=  p_template_name;
    --
    -- item identifier
    --
    l_item_tbl(indx).inventory_item_id :=  p_inventory_item_id;
    l_item_tbl(indx).summary_flag      :=  p_summary_flag;
    l_item_tbl(indx).enabled_flag      :=  p_enabled_flag;
    l_item_tbl(indx).start_date_active :=  p_start_date_active;
    l_item_tbl(indx).end_date_active   :=  p_end_date_active;
    --
    -- organization
    --
    l_item_tbl(indx).organization_id        :=  p_organization_id;
-- not passed do leave as it is
--    l_item_tbl(indx).organization_code      :=  NULL;
    --
    -- item catalog group (user item type)
    --
    l_item_tbl(indx).item_catalog_group_id  :=  p_item_catalog_group_id;
    l_item_tbl(indx).catalog_status_flag    :=  p_catalog_status_flag;
    --
    -- lifecycle
    --
    l_item_tbl(indx).lifecycle_id           :=  p_lifecycle_id;
    l_item_tbl(indx).current_phase_id       :=  p_current_phase_id;
    --
    -- main attributes
    --
    l_item_tbl(indx).description                 :=  p_description;
    l_item_tbl(indx).long_description            :=  p_long_description;
    l_item_tbl(indx).primary_uom_code            :=  p_primary_uom_code;
    l_item_tbl(indx).allowed_units_lookup_code   :=  p_allowed_units_lookup_code;
    l_item_tbl(indx).inventory_item_status_code  :=  p_inventory_item_status_code;
    l_item_tbl(indx).dual_uom_control            :=  p_dual_uom_control;
    l_item_tbl(indx).secondary_uom_code          :=  p_secondary_uom_code;
    l_item_tbl(indx).dual_uom_deviation_high     :=  p_dual_uom_deviation_high;
    l_item_tbl(indx).dual_uom_deviation_low      :=  p_dual_uom_deviation_low;
    l_item_tbl(indx).item_type                   :=  p_item_type;
    -- inventory
    l_item_tbl(indx).inventory_item_flag            :=  p_inventory_item_flag;
    l_item_tbl(indx).stock_enabled_flag             :=  p_stock_enabled_flag;
    l_item_tbl(indx).mtl_transactions_enabled_flag  :=  p_mtl_transactions_enabled_fl;
    l_item_tbl(indx).revision_qty_control_code      :=  p_revision_qty_control_code;
    l_item_tbl(indx).lot_control_code               :=  p_lot_control_code;
    l_item_tbl(indx).auto_lot_alpha_prefix          :=  p_auto_lot_alpha_prefix;
    l_item_tbl(indx).start_auto_lot_number          :=  p_start_auto_lot_number;
    l_item_tbl(indx).serial_number_control_code     :=  p_serial_number_control_code;
    l_item_tbl(indx).auto_serial_alpha_prefix       :=  p_auto_serial_alpha_prefix;
    l_item_tbl(indx).start_auto_serial_number       :=  p_start_auto_serial_number;
    l_item_tbl(indx).shelf_life_code                :=  p_shelf_life_code;
    l_item_tbl(indx).shelf_life_days                :=  p_shelf_life_days;
    l_item_tbl(indx).restrict_subinventories_code   :=  p_restrict_subinventories_cod;
    l_item_tbl(indx).location_control_code          :=  p_location_control_code;
    l_item_tbl(indx).restrict_locators_code         :=  p_restrict_locators_code;
    l_item_tbl(indx).reservable_type                :=  p_reservable_type;
    l_item_tbl(indx).cycle_count_enabled_flag       :=  p_cycle_count_enabled_flag;
    l_item_tbl(indx).negative_measurement_error     :=  p_negative_measurement_error;
    l_item_tbl(indx).positive_measurement_error     :=  p_positive_measurement_error;
    l_item_tbl(indx).check_shortages_flag           :=  p_check_shortages_flag;
    l_item_tbl(indx).lot_status_enabled             :=  p_lot_status_enabled;
    l_item_tbl(indx).default_lot_status_id          :=  p_default_lot_status_id;
    l_item_tbl(indx).serial_status_enabled          :=  p_serial_status_enabled;
    l_item_tbl(indx).default_serial_status_id       :=  p_default_serial_status_id;
    l_item_tbl(indx).lot_split_enabled              :=  p_lot_split_enabled;
    l_item_tbl(indx).lot_merge_enabled              :=  p_lot_merge_enabled;
    l_item_tbl(indx).lot_translate_enabled          :=  p_lot_translate_enabled;
    l_item_tbl(indx).lot_substitution_enabled       :=  p_lot_substitution_enabled;
    l_item_tbl(indx).bulk_picked_flag               :=  p_bulk_picked_flag;
    -- bills of material
    l_item_tbl(indx).bom_item_type            :=  p_bom_item_type;
    l_item_tbl(indx).bom_enabled_flag         :=  p_bom_enabled_flag;
    l_item_tbl(indx).base_item_id             :=  p_base_item_id;
    l_item_tbl(indx).eng_item_flag            :=  p_eng_item_flag;
    l_item_tbl(indx).engineering_item_id      :=  p_engineering_item_id;
    l_item_tbl(indx).engineering_ecn_code     :=  p_engineering_ecn_code;
    l_item_tbl(indx).engineering_date         :=  p_engineering_date;
    l_item_tbl(indx).effectivity_control      :=  p_effectivity_control;
    l_item_tbl(indx).config_model_type        :=  p_config_model_type;
    l_item_tbl(indx).product_family_item_id   :=  p_product_family_item_id;
    -- costing
    l_item_tbl(indx).costing_enabled_flag           :=  p_costing_enabled_flag;
    l_item_tbl(indx).inventory_asset_flag           :=  p_inventory_asset_flag;
    l_item_tbl(indx).cost_of_sales_account          :=  p_cost_of_sales_account;
    l_item_tbl(indx).default_include_in_rollup_flag :=  p_default_include_in_rollup_f;
    l_item_tbl(indx).std_lot_size                   :=  p_std_lot_size;
    -- enterprise asset management
    l_item_tbl(indx).eam_item_type                  :=  p_eam_item_type;
    l_item_tbl(indx).eam_activity_type_code         :=  p_eam_activity_type_code;
    l_item_tbl(indx).eam_activity_cause_code        :=  p_eam_activity_cause_code;
    l_item_tbl(indx).eam_activity_source_code       :=  p_eam_activity_source_code;
    l_item_tbl(indx).eam_act_shutdown_status        :=  p_eam_act_shutdown_status;
    l_item_tbl(indx).eam_act_notification_flag      :=  p_eam_act_notification_flag;
    -- purchasing
    l_item_tbl(indx).purchasing_item_flag           :=  p_purchasing_item_flag;
    l_item_tbl(indx).purchasing_enabled_flag        :=  p_purchasing_enabled_flag;
    l_item_tbl(indx).buyer_id                       :=  p_buyer_id;
    l_item_tbl(indx).must_use_approved_vendor_flag  :=  p_must_use_approved_vendor_fl;
    l_item_tbl(indx).purchasing_tax_code            :=  p_purchasing_tax_code;
    l_item_tbl(indx).taxable_flag                   :=  p_taxable_flag;
    l_item_tbl(indx).receive_close_tolerance        :=  p_receive_close_tolerance;
    l_item_tbl(indx).allow_item_desc_update_flag    :=  p_allow_item_desc_update_flag;
    l_item_tbl(indx).inspection_required_flag       :=  p_inspection_required_flag;
    l_item_tbl(indx).receipt_required_flag          :=  p_receipt_required_flag;
    l_item_tbl(indx).market_price                   :=  p_market_price;
    l_item_tbl(indx).un_number_id                   :=  p_un_number_id;
    l_item_tbl(indx).hazard_class_id                :=  p_hazard_class_id;
    l_item_tbl(indx).rfq_required_flag              :=  p_rfq_required_flag;
    l_item_tbl(indx).list_price_per_unit            :=  p_list_price_per_unit;
    l_item_tbl(indx).price_tolerance_percent        :=  p_price_tolerance_percent;
    l_item_tbl(indx).asset_category_id              :=  p_asset_category_id;
    l_item_tbl(indx).rounding_factor                :=  p_rounding_factor;
    l_item_tbl(indx).unit_of_issue                  :=  p_unit_of_issue;
    l_item_tbl(indx).outside_operation_flag         :=  p_outside_operation_flag;
    l_item_tbl(indx).outside_operation_uom_type     :=  p_outside_operation_uom_type;
    l_item_tbl(indx).invoice_close_tolerance        :=  p_invoice_close_tolerance;
    l_item_tbl(indx).encumbrance_account            :=  p_encumbrance_account;
    l_item_tbl(indx).expense_account                :=  p_expense_account;
-- old db column used for backword compatability only. not used currently
--    l_item_tbl(indx).expense_billable_flag          :=  p_expense_billable_flag;
    l_item_tbl(indx).qty_rcv_exception_code         :=  p_qty_rcv_exception_code;
    l_item_tbl(indx).receiving_routing_id           :=  p_receiving_routing_id;
    l_item_tbl(indx).qty_rcv_tolerance              :=  p_qty_rcv_tolerance;
    l_item_tbl(indx).enforce_ship_to_location_code  :=  p_enforce_ship_to_location_c;
    l_item_tbl(indx).allow_substitute_receipts_flag :=  p_allow_substitute_receipts_f;
    l_item_tbl(indx).allow_unordered_receipts_flag  :=  p_allow_unordered_receipts_fl;
    l_item_tbl(indx).allow_express_delivery_flag    :=  p_allow_express_delivery_flag;
    l_item_tbl(indx).days_early_receipt_allowed     :=  p_days_early_receipt_allowed;
    l_item_tbl(indx).days_late_receipt_allowed      :=  p_days_late_receipt_allowed;
    l_item_tbl(indx).receipt_days_exception_code    :=  p_receipt_days_exception_code;
    -- physical
    l_item_tbl(indx).weight_uom_code        :=  p_weight_uom_code;
    l_item_tbl(indx).unit_weight            :=  p_unit_weight;
    l_item_tbl(indx).volume_uom_code        :=  p_volume_uom_code;
    l_item_tbl(indx).unit_volume            :=  p_unit_volume;
    l_item_tbl(indx).container_item_flag    :=  p_container_item_flag;
    l_item_tbl(indx).vehicle_item_flag      :=  p_vehicle_item_flag;
    l_item_tbl(indx).maximum_load_weight    :=  p_maximum_load_weight;
    l_item_tbl(indx).minimum_fill_percent   :=  p_minimum_fill_percent;
    l_item_tbl(indx).internal_volume        :=  p_internal_volume;
    l_item_tbl(indx).container_type_code    :=  p_container_type_code;
    l_item_tbl(indx).collateral_flag        :=  p_collateral_flag;
    l_item_tbl(indx).event_flag             :=  p_event_flag;
    l_item_tbl(indx).equipment_type         :=  p_equipment_type;
    l_item_tbl(indx).electronic_flag        :=  p_electronic_flag;
    l_item_tbl(indx).downloadable_flag      :=  p_downloadable_flag;
    l_item_tbl(indx).indivisible_flag       :=  p_indivisible_flag;
    l_item_tbl(indx).dimension_uom_code     :=  p_dimension_uom_code;
    l_item_tbl(indx).unit_length            :=  p_unit_length;
    l_item_tbl(indx).unit_width             :=  p_unit_width;
    l_item_tbl(indx).unit_height            :=  p_unit_height;
    --
    l_item_tbl(indx).inventory_planning_code    :=  p_inventory_planning_code;
    l_item_tbl(indx).planner_code               :=  p_planner_code;
    l_item_tbl(indx).planning_make_buy_code     :=  p_planning_make_buy_code;
    l_item_tbl(indx).min_minmax_quantity        :=  p_min_minmax_quantity;
    l_item_tbl(indx).max_minmax_quantity        :=  p_max_minmax_quantity;
    l_item_tbl(indx).safety_stock_bucket_days   :=  p_safety_stock_bucket_days;
    l_item_tbl(indx).carrying_cost              :=  p_carrying_cost;
    l_item_tbl(indx).order_cost                 :=  p_order_cost;
    l_item_tbl(indx).mrp_safety_stock_percent   :=  p_mrp_safety_stock_percent;
    l_item_tbl(indx).mrp_safety_stock_code      :=  p_mrp_safety_stock_code;
    l_item_tbl(indx).fixed_order_quantity       :=  p_fixed_order_quantity;
    l_item_tbl(indx).fixed_days_supply          :=  p_fixed_days_supply;
    l_item_tbl(indx).minimum_order_quantity     :=  p_minimum_order_quantity;
    l_item_tbl(indx).maximum_order_quantity     :=  p_maximum_order_quantity;
    l_item_tbl(indx).fixed_lot_multiplier       :=  p_fixed_lot_multiplier;
    l_item_tbl(indx).source_type                :=  p_source_type;
    l_item_tbl(indx).source_organization_id     :=  p_source_organization_id;
    l_item_tbl(indx).source_subinventory        :=  p_source_subinventory;
    l_item_tbl(indx).mrp_planning_code          :=  p_mrp_planning_code;
    l_item_tbl(indx).ato_forecast_control       :=  p_ato_forecast_control;
    l_item_tbl(indx).planning_exception_set     :=  p_planning_exception_set;
    l_item_tbl(indx).shrinkage_rate             :=  p_shrinkage_rate;
    l_item_tbl(indx).end_assembly_pegging_flag  :=  p_end_assembly_pegging_flag;
    l_item_tbl(indx).rounding_control_type      :=  p_rounding_control_type;
    l_item_tbl(indx).planned_inv_point_flag     :=  p_planned_inv_point_flag;
    l_item_tbl(indx).create_supply_flag         :=  p_create_supply_flag;
    l_item_tbl(indx).acceptable_early_days      :=  p_acceptable_early_days;
    l_item_tbl(indx).mrp_calculate_atp_flag     :=  p_mrp_calculate_atp_flag;
    l_item_tbl(indx).auto_reduce_mps            :=  p_auto_reduce_mps;
    l_item_tbl(indx).repetitive_planning_flag   :=  p_repetitive_planning_flag;
    l_item_tbl(indx).overrun_percentage         :=  p_overrun_percentage;
    l_item_tbl(indx).acceptable_rate_decrease   :=  p_acceptable_rate_decrease;
    l_item_tbl(indx).acceptable_rate_increase   :=  p_acceptable_rate_increase;
    l_item_tbl(indx).planning_time_fence_code   :=  p_planning_time_fence_code;
    l_item_tbl(indx).planning_time_fence_days   :=  p_planning_time_fence_days;
    l_item_tbl(indx).demand_time_fence_code     :=  p_demand_time_fence_code;
    l_item_tbl(indx).demand_time_fence_days     :=  p_demand_time_fence_days;
    l_item_tbl(indx).release_time_fence_code    :=  p_release_time_fence_code;
    l_item_tbl(indx).release_time_fence_days    :=  p_release_time_fence_days;
    l_item_tbl(indx).substitution_window_code   :=  p_substitution_window_code;
    l_item_tbl(indx).substitution_window_days   :=  p_substitution_window_days;
    -- lead times
    l_item_tbl(indx).preprocessing_lead_time        :=  p_preprocessing_lead_time;
    l_item_tbl(indx).full_lead_time                 :=  p_full_lead_time;
    l_item_tbl(indx).postprocessing_lead_time       :=  p_postprocessing_lead_time;
    l_item_tbl(indx).fixed_lead_time                :=  p_fixed_lead_time;
    l_item_tbl(indx).variable_lead_time             :=  p_variable_lead_time;
    l_item_tbl(indx).cum_manufacturing_lead_time    :=  p_cum_manufacturing_lead_time;
    l_item_tbl(indx).cumulative_total_lead_time     :=  p_cumulative_total_lead_time;
    l_item_tbl(indx).lead_time_lot_size             :=  p_lead_time_lot_size;
    -- wip
    l_item_tbl(indx).build_in_wip_flag              :=  p_build_in_wip_flag;
    l_item_tbl(indx).wip_supply_type                :=  p_wip_supply_type;
    l_item_tbl(indx).wip_supply_subinventory        :=  p_wip_supply_subinventory;
    l_item_tbl(indx).wip_supply_locator_id          :=  p_wip_supply_locator_id;
    l_item_tbl(indx).overcompletion_tolerance_type  :=  p_overcompletion_tolerance_ty;
    l_item_tbl(indx).overcompletion_tolerance_value :=  p_overcompletion_tolerance_va;
    l_item_tbl(indx).inventory_carry_penalty        :=  p_inventory_carry_penalty;
    l_item_tbl(indx).operation_slack_penalty        :=  p_operation_slack_penalty;
    -- order management
    l_item_tbl(indx).customer_order_flag            :=  p_customer_order_flag;
    l_item_tbl(indx).customer_order_enabled_flag    :=  p_customer_order_enabled_flag;
    l_item_tbl(indx).internal_order_flag            :=  p_internal_order_flag;
    l_item_tbl(indx).internal_order_enabled_flag    :=  p_internal_order_enabled_flag;
    l_item_tbl(indx).shippable_item_flag            :=  p_shippable_item_flag;
    l_item_tbl(indx).so_transactions_flag           :=  p_so_transactions_flag;
    l_item_tbl(indx).picking_rule_id                :=  p_picking_rule_id;
    l_item_tbl(indx).pick_components_flag           :=  p_pick_components_flag;
    l_item_tbl(indx).replenish_to_order_flag        :=  p_replenish_to_order_flag;
    l_item_tbl(indx).atp_flag                       :=  p_atp_flag;
    l_item_tbl(indx).atp_components_flag            :=  p_atp_components_flag;
    l_item_tbl(indx).atp_rule_id                    :=  p_atp_rule_id;
    l_item_tbl(indx).ship_model_complete_flag       :=  p_ship_model_complete_flag;
    l_item_tbl(indx).default_shipping_org           :=  p_default_shipping_org;
    l_item_tbl(indx).default_so_source_type         :=  p_default_so_source_type;
    l_item_tbl(indx).returnable_flag                :=  p_returnable_flag;
    l_item_tbl(indx).return_inspection_requirement  :=  p_return_inspection_requireme;
    l_item_tbl(indx).over_shipment_tolerance        :=  p_over_shipment_tolerance;
    l_item_tbl(indx).under_shipment_tolerance       :=  p_under_shipment_tolerance;
    l_item_tbl(indx).over_return_tolerance          :=  p_over_return_tolerance;
    l_item_tbl(indx).under_return_tolerance         :=  p_under_return_tolerance;
    l_item_tbl(indx).financing_allowed_flag         :=  p_financing_allowed_flag;
    l_item_tbl(indx).vol_discount_exempt_flag       :=  p_vol_discount_exempt_flag;
    l_item_tbl(indx).coupon_exempt_flag             :=  p_coupon_exempt_flag;
    l_item_tbl(indx).invoiceable_item_flag          :=  p_invoiceable_item_flag;
    l_item_tbl(indx).invoice_enabled_flag           :=  p_invoice_enabled_flag;
    l_item_tbl(indx).accounting_rule_id             :=  p_accounting_rule_id;
    l_item_tbl(indx).invoicing_rule_id              :=  p_invoicing_rule_id;
    l_item_tbl(indx).tax_code                       :=  p_tax_code;
    l_item_tbl(indx).sales_account                  :=  p_sales_account;
    l_item_tbl(indx).payment_terms_id               :=  p_payment_terms_id;
    -- service
    l_item_tbl(indx).contract_item_type_code        :=  p_contract_item_type_code;
    l_item_tbl(indx).service_duration_period_code   :=  p_service_duration_period_cod;
    l_item_tbl(indx).service_duration               :=  p_service_duration;
    l_item_tbl(indx).coverage_schedule_id           :=  p_coverage_schedule_id;
    l_item_tbl(indx).subscription_depend_flag       :=  p_subscription_depend_flag;
    l_item_tbl(indx).serv_importance_level          :=  p_serv_importance_level;
    l_item_tbl(indx).serv_req_enabled_code          :=  p_serv_req_enabled_code;
    l_item_tbl(indx).comms_activation_reqd_flag     :=  p_comms_activation_reqd_flag;
    l_item_tbl(indx).serviceable_product_flag       :=  p_serviceable_product_flag;
    l_item_tbl(indx).material_billable_flag         :=  p_material_billable_flag;
    l_item_tbl(indx).serv_billing_enabled_flag      :=  p_serv_billing_enabled_flag;
    l_item_tbl(indx).defect_tracking_on_flag        :=  p_defect_tracking_on_flag;
    l_item_tbl(indx).recovered_part_disp_code       :=  p_recovered_part_disp_code;
    l_item_tbl(indx).comms_nl_trackable_flag        :=  p_comms_nl_trackable_flag;
    l_item_tbl(indx).asset_creation_code            :=  p_asset_creation_code;
    l_item_tbl(indx).ib_item_instance_class         :=  p_ib_item_instance_class;
    l_item_tbl(indx).service_starting_delay         :=  p_service_starting_delay;
    -- web option
    l_item_tbl(indx).web_status                     :=  p_web_status;
    l_item_tbl(indx).orderable_on_web_flag          :=  p_orderable_on_web_flag;
    l_item_tbl(indx).back_orderable_flag            :=  p_back_orderable_flag;
    l_item_tbl(indx).minimum_license_quantity       :=  p_minimum_license_quantity;
    -- descriptive flex
    l_item_tbl(indx).attribute_category   :=  p_attribute_category;
    l_item_tbl(indx).attribute1           :=  p_attribute1;
    l_item_tbl(indx).attribute2           :=  p_attribute2;
    l_item_tbl(indx).attribute3           :=  p_attribute3;
    l_item_tbl(indx).attribute4           :=  p_attribute4;
    l_item_tbl(indx).attribute5           :=  p_attribute5;
    l_item_tbl(indx).attribute6           :=  p_attribute6;
    l_item_tbl(indx).attribute7           :=  p_attribute7;
    l_item_tbl(indx).attribute8           :=  p_attribute8;
    l_item_tbl(indx).attribute9           :=  p_attribute9;
    l_item_tbl(indx).attribute10          :=  p_attribute10;
    l_item_tbl(indx).attribute11          :=  p_attribute11;
    l_item_tbl(indx).attribute12          :=  p_attribute12;
    l_item_tbl(indx).attribute13          :=  p_attribute13;
    l_item_tbl(indx).attribute14          :=  p_attribute14;
    l_item_tbl(indx).attribute15          :=  p_attribute15;
    -- global descriptive flex
    l_item_tbl(indx).global_attribute_category  :=  p_global_attribute_category;
    l_item_tbl(indx).global_attribute1          :=  p_global_attribute1;
    l_item_tbl(indx).global_attribute2          :=  p_global_attribute2;
    l_item_tbl(indx).global_attribute3          :=  p_global_attribute3;
    l_item_tbl(indx).global_attribute4          :=  p_global_attribute4;
    l_item_tbl(indx).global_attribute5          :=  p_global_attribute5;
    l_item_tbl(indx).global_attribute6          :=  p_global_attribute6;
    l_item_tbl(indx).global_attribute7          :=  p_global_attribute7;
    l_item_tbl(indx).global_attribute8          :=  p_global_attribute8;
    l_item_tbl(indx).global_attribute9          :=  p_global_attribute9;
    l_item_tbl(indx).global_attribute10         :=  p_global_attribute10;
-- who / maintenance columns are not required
--    l_item_tbl(indx).object_version_number   :=  p_object_version_number;
--    l_item_tbl(indx).creation_date           :=  p_creation_date;
--    l_item_tbl(indx).created_by              :=  p_created_by;
--    l_item_tbl(indx).last_update_date        :=  p_last_update_date;
--    l_item_tbl(indx).last_updated_by         :=  p_last_updated_by;
--    l_item_tbl(indx).last_update_login       :=  p_last_update_login;

developer_debug (' ISS: table created for PRE IOI Processing ');

    EGO_Item_PVT.G_Item_Tbl  :=  l_item_tbl;
    -----------------------------------------------------------------------------
    -- Call the Private API to process items table.
    -----------------------------------------------------------------------------
developer_debug (' ISS: calling EGO_ITEM_PVT.Process_Items ');
    EGO_Item_PVT.Process_Items (
        p_commit         =>  p_commit
       ,x_return_status  =>  x_return_status
       ,x_msg_count      =>  x_msg_count);
developer_debug (' ISS: returned from EGO_ITEM_PVT.Process_Items -> ' || x_return_status);
    -----------------------------------------------------------------------------
    -- Return items data from the re-populated global table
    -----------------------------------------------------------------------------
    l_item_created_tbl := EGO_Item_PVT.G_Item_Tbl;
developer_debug (' ISS: copied the item to created table ');

    IF x_return_status =  FND_API.G_RET_STS_SUCCESS THEN
      -- item created successfully
      x_inventory_item_id := l_item_created_tbl(indx).inventory_item_id;
      x_organization_id   := l_item_created_tbl(indx).organization_id;
developer_debug (' ISS: copied the item created values ');
      --
      -- post IOI process
      --
      IF p_transaction_type = G_CREATE_TRANSACTION_TYPE THEN
        --
        -- transaction type = 'CREATE'
        -- do specific validations here
        --
        NULL;
      ELSIF p_transaction_type = G_UPDATE_TRANSACTION_TYPE THEN
        --
        -- transaction type = 'UPDATE'
        --
developer_debug (' ISS: calling Update_item_number ');
        EGO_ITEM_PUB.Update_Item_Number (
           p_Inventory_Item_Id =>  x_inventory_item_id
          ,p_Item_Number       =>  p_Item_Number
          ,p_Segment1          =>  NULL
          ,p_Segment2          =>  NULL
          ,p_Segment3          =>  NULL
          ,p_Segment4          =>  NULL
          ,p_Segment5          =>  NULL
          ,p_Segment6          =>  NULL
          ,p_Segment7          =>  NULL
          ,p_Segment8          =>  NULL
          ,p_Segment9          =>  NULL
          ,p_Segment10         =>  NULL
          ,p_Segment11         =>  NULL
          ,p_Segment12         =>  NULL
          ,p_Segment13         =>  NULL
          ,p_Segment14         =>  NULL
          ,p_Segment15         =>  NULL
          ,p_Segment16         =>  NULL
          ,p_Segment17         =>  NULL
          ,p_Segment18         =>  NULL
          ,p_Segment19         =>  NULL
          ,p_Segment20         =>  NULL
          ,p_New_Segment1      =>  p_Segment1
          ,p_New_Segment2      =>  p_Segment2
          ,p_New_Segment3      =>  p_Segment3
          ,p_New_Segment4      =>  p_Segment4
          ,p_New_Segment5      =>  p_Segment5
          ,p_New_Segment6      =>  p_Segment6
          ,p_New_Segment7      =>  p_Segment7
          ,p_New_Segment8      =>  p_Segment8
          ,p_New_Segment9      =>  p_Segment9
          ,p_New_Segment10     =>  p_Segment10
          ,p_New_Segment11     =>  p_Segment11
          ,p_New_Segment12     =>  p_Segment12
          ,p_New_Segment13     =>  p_Segment13
          ,p_New_Segment14     =>  p_Segment14
          ,p_New_Segment15     =>  p_Segment15
          ,p_New_Segment16     =>  p_Segment16
          ,p_New_Segment17     =>  p_Segment17
          ,p_New_Segment18     =>  p_Segment18
          ,p_New_Segment19     =>  p_Segment19
          ,p_New_Segment20     =>  p_Segment20
          ,x_Item_Tbl          =>  l_item_created_tbl
          ,x_return_status     =>  x_return_status
          );
developer_debug (' ISS: returned from Update_Item_Number -> ' || x_return_status);
        IF x_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      -- common processing after update
      -- call the update approval status routine now
developer_debug (' ISS: calling EGO_ITEM_PUB.Update_Item_Approval_Status ');
developer_debug (' ISS: inventory_item_id -> '||to_char(x_inventory_item_id));
developer_debug (' ISS: organization_id -> '||to_char(x_organization_id));
developer_debug (' ISS: approval_status -> '||p_approval_status);
      EGO_ITEM_PUB.Update_Item_Approval_Status (
           p_inventory_item_id   => x_inventory_item_id
          ,p_organization_id     => x_organization_id
          ,p_approval_status     => p_approval_status
          );
    ELSE
      -- messages already logged by EGO_ITEM_PVT
      RETURN;
    END IF;  -- x_return_status = FND_API.G_RET_STS_SUCCESS from IOI

  ELSIF p_transaction_type = G_COPY_TRANSACTION_TYPE THEN
    -- transaction type = 'COPY'
    -- to be implemented
    FND_MESSAGE.Set_Name ('EGO', 'EGO_PROGRAM_NOT_IMPLEMENTED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_return_status := G_RET_STS_SUCCESS;
developer_debug (' ISS: DONE with status -> '||x_return_status);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Process_Item_Scalar;
      END IF;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Process_Item_Scalar;
      END IF;
      x_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Process_Item_Scalar;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      -- for PL/SQL errors
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Process_Item;


END EGO_UI_ITEM_PUB;

/
