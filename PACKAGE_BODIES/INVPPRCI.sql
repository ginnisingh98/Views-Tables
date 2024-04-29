--------------------------------------------------------
--  DDL for Package Body INVPPRCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPPRCI" as
/* $Header: INVPRCIB.pls 120.1 2005/06/21 04:36:36 appldev ship $ */

function inproit_process_item (
ato_flag   in   NUMBER,
prg_appid  in   NUMBER,
prg_id     in   NUMBER,
req_id     in   NUMBER,
user_id    in   NUMBER,
login_id   in   NUMBER,
error_message  out      NOCOPY VARCHAR2,
message_name   out      NOCOPY VARCHAR2,
table_name     out      NOCOPY VARCHAR2)
return integer
is
validation_org NUMBER;
l_cost_group_id NUMBER;

/** Need to define a cursor to get project_id for each config item **/

cursor allconfig is
       select sla.line_id, si.organization_id,sla.project_id
       from   so_headers_all SOH,
              mtl_system_items_interface SI,
              mtl_sales_orders mso,
              so_order_types_all sot,
              so_lines_all     sla
       where  si.demand_source_header_id = mso.sales_order_id
       and    mso.segment1               = soh.order_number
       and    soh.order_type_id          = sot.order_type_id
       and    sot.name                   = mso.segment2
       and    sla.line_id                = si.demand_source_line
       and    si.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')));
BEGIN

	/* Yet another addition thanks to "Order from Chaos" */
	/* we need to have this configuration item  created  */
        /* in the validation organization as well so if      */
        /* their val org is different from master org, it    */
	/* will still be visible			     */

        /* Time for a kludge here. We will pass in the profile value */
        /* in the ato_flag parameter, so that we can use C api in    */
        /* bmlcci.ppc to get the profile option setting              */
        /* ato_flag is not being used anywhere else                  */

     validation_org := ato_flag;

    /* Copy the configuration item in the item interface table
      into the inventory system master table                           */

      table_name := 'MTL_SYSTEM_ITEMS';

      insert into MTL_SYSTEM_ITEMS_B
	    (INVENTORY_ITEM_ID,
	     ORGANIZATION_ID,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     SUMMARY_FLAG,
	     ENABLED_FLAG,
	     START_DATE_ACTIVE,
	     END_DATE_ACTIVE,
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
	     PURCHASING_ITEM_FLAG,
	     SHIPPABLE_ITEM_FLAG,
	     CUSTOMER_ORDER_FLAG,
	     INTERNAL_ORDER_FLAG,
	     SERVICE_ITEM_FLAG,
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
	     VENDOR_WARRANTY_FLAG,
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
	     ITEM_TYPE,
	     MODEL_CONFIG_CLAUSE_NAME,
	     SHIP_MODEL_COMPLETE_FLAG,
	     MRP_PLANNING_CODE,
             REPETITIVE_PLANNING_FLAG,
	     RETURN_INSPECTION_REQUIREMENT,
             EFFECTIVITY_CONTROL,
	     REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE
            )
      select
	     I.INVENTORY_ITEM_ID,
	     MP1.ORGANIZATION_ID,
	     NVL(I.LAST_UPDATE_DATE,SYSDATE),
	     user_id,       /* last_updated_by */
	     NVL(I.CREATION_DATE,SYSDATE),
	     user_id,       /* created_by */
             login_id,      /* last_update_login */
	     NVL(I.SUMMARY_FLAG,M.SUMMARY_FLAG),
	     NVL(I.ENABLED_FLAG,M.ENABLED_FLAG),
	     NVL(I.START_DATE_ACTIVE,M.START_DATE_ACTIVE),
	     NVL(I.END_DATE_ACTIVE,M.END_DATE_ACTIVE),
	     NVL(I.DESCRIPTION,M.DESCRIPTION),
	     NVL(I.BUYER_ID,M.BUYER_ID),
	     NVL(I.ACCOUNTING_RULE_ID,M.ACCOUNTING_RULE_ID),
	     NVL(I.INVOICING_RULE_ID,M.INVOICING_RULE_ID),
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
	     NVL(I.ATTRIBUTE_CATEGORY,M.ATTRIBUTE_CATEGORY),
	     NVL(I.ATTRIBUTE1,M.ATTRIBUTE1),
	     NVL(I.ATTRIBUTE2,M.ATTRIBUTE2),
	     NVL(I.ATTRIBUTE3,M.ATTRIBUTE3),
	     NVL(I.ATTRIBUTE4,M.ATTRIBUTE4),
	     NVL(I.ATTRIBUTE5,M.ATTRIBUTE5),
	     NVL(I.ATTRIBUTE6,M.ATTRIBUTE6),
	     NVL(I.ATTRIBUTE7,M.ATTRIBUTE7),
	     NVL(I.ATTRIBUTE8,M.ATTRIBUTE8),
	     NVL(I.ATTRIBUTE9,M.ATTRIBUTE9),
	     NVL(I.ATTRIBUTE10,M.ATTRIBUTE10),
	     NVL(I.ATTRIBUTE11,M.ATTRIBUTE11),
	     NVL(I.ATTRIBUTE12,M.ATTRIBUTE12),
	     NVL(I.ATTRIBUTE13,M.ATTRIBUTE13),
	     NVL(I.ATTRIBUTE14,M.ATTRIBUTE14),
	     NVL(I.ATTRIBUTE15,M.ATTRIBUTE15),
	     NVL(I.PURCHASING_ITEM_FLAG,M.PURCHASING_ITEM_FLAG),
	     NVL(I.SHIPPABLE_ITEM_FLAG,M.SHIPPABLE_ITEM_FLAG),
	     NVL(I.CUSTOMER_ORDER_FLAG,M.CUSTOMER_ORDER_FLAG),
	     NVL(I.INTERNAL_ORDER_FLAG,M.INTERNAL_ORDER_FLAG),
	     NVL(I.SERVICE_ITEM_FLAG,M.SERVICE_ITEM_FLAG),
	     NVL(I.INVENTORY_ITEM_FLAG,M.INVENTORY_ITEM_FLAG),
	     NVL(I.ENG_ITEM_FLAG,M.ENG_ITEM_FLAG),
	     NVL(I.INVENTORY_ASSET_FLAG,M.INVENTORY_ASSET_FLAG),
	     NVL(I.PURCHASING_ENABLED_FLAG,M.PURCHASING_ENABLED_FLAG),
	     NVL(I.CUSTOMER_ORDER_ENABLED_FLAG,M.CUSTOMER_ORDER_ENABLED_FLAG),
	     NVL(I.INTERNAL_ORDER_ENABLED_FLAG,M.INTERNAL_ORDER_ENABLED_FLAG),
	     NVL(I.SO_TRANSACTIONS_FLAG,M.SO_TRANSACTIONS_FLAG),
	     NVL(I.MTL_TRANSACTIONS_ENABLED_FLAG,M.MTL_TRANSACTIONS_ENABLED_FLAG),
	     NVL(I.STOCK_ENABLED_FLAG,M.STOCK_ENABLED_FLAG),
	     NVL(I.BOM_ENABLED_FLAG,M.BOM_ENABLED_FLAG),
	     NVL(I.BUILD_IN_WIP_FLAG,M.BUILD_IN_WIP_FLAG),
	     NVL(I.REVISION_QTY_CONTROL_CODE,M.REVISION_QTY_CONTROL_CODE),
	     NVL(I.ITEM_CATALOG_GROUP_ID,M.ITEM_CATALOG_GROUP_ID),
	     NVL(I.CATALOG_STATUS_FLAG,M.CATALOG_STATUS_FLAG),
	     NVL(I.RETURNABLE_FLAG,M.RETURNABLE_FLAG),
	     NVL(I.DEFAULT_SHIPPING_ORG,M.DEFAULT_SHIPPING_ORG),
	     NVL(I.COLLATERAL_FLAG,M.COLLATERAL_FLAG),
	     NVL(I.TAXABLE_FLAG,M.TAXABLE_FLAG),
	     NVL(I.ALLOW_ITEM_DESC_UPDATE_FLAG,M.ALLOW_ITEM_DESC_UPDATE_FLAG),
	     NVL(I.INSPECTION_REQUIRED_FLAG,M.INSPECTION_REQUIRED_FLAG),
	     NVL(I.RECEIPT_REQUIRED_FLAG,M.RECEIPT_REQUIRED_FLAG),
	     NVL(I.MARKET_PRICE,M.MARKET_PRICE),
	     NVL(I.HAZARD_CLASS_ID,M.HAZARD_CLASS_ID),
	     NVL(I.RFQ_REQUIRED_FLAG,M.RFQ_REQUIRED_FLAG),
	     NVL(I.QTY_RCV_TOLERANCE,M.QTY_RCV_TOLERANCE),
	     NVL(I.LIST_PRICE_PER_UNIT,M.LIST_PRICE_PER_UNIT),
	     NVL(I.UN_NUMBER_ID,M.UN_NUMBER_ID),
	     NVL(I.PRICE_TOLERANCE_PERCENT,M.PRICE_TOLERANCE_PERCENT),
	     NVL(I.ASSET_CATEGORY_ID,M.ASSET_CATEGORY_ID),
	     NVL(I.ROUNDING_FACTOR,M.ROUNDING_FACTOR),
	     NVL(I.UNIT_OF_ISSUE,M.UNIT_OF_ISSUE),
	     NVL(I.ENFORCE_SHIP_TO_LOCATION_CODE,M.ENFORCE_SHIP_TO_LOCATION_CODE),
	     NVL(I.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,M.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
	     NVL(I.ALLOW_UNORDERED_RECEIPTS_FLAG,M.ALLOW_UNORDERED_RECEIPTS_FLAG),
	     NVL(I.ALLOW_EXPRESS_DELIVERY_FLAG,M.ALLOW_EXPRESS_DELIVERY_FLAG),
	     NVL(I.DAYS_EARLY_RECEIPT_ALLOWED,M.DAYS_EARLY_RECEIPT_ALLOWED),
	     NVL(I.DAYS_LATE_RECEIPT_ALLOWED,M.DAYS_LATE_RECEIPT_ALLOWED),
	     NVL(I.RECEIPT_DAYS_EXCEPTION_CODE,M.RECEIPT_DAYS_EXCEPTION_CODE),
	     NVL(I.RECEIVING_ROUTING_ID,M.RECEIVING_ROUTING_ID),
	     NVL(I.INVOICE_CLOSE_TOLERANCE,M.INVOICE_CLOSE_TOLERANCE),
	     NVL(I.RECEIVE_CLOSE_TOLERANCE,M.RECEIVE_CLOSE_TOLERANCE),
	     NVL(I.AUTO_LOT_ALPHA_PREFIX,M.AUTO_LOT_ALPHA_PREFIX),
	     NVL(I.START_AUTO_LOT_NUMBER,M.START_AUTO_LOT_NUMBER),
	     NVL(I.LOT_CONTROL_CODE,M.LOT_CONTROL_CODE),
	     NVL(I.SHELF_LIFE_CODE,M.SHELF_LIFE_CODE),
	     NVL(I.SHELF_LIFE_DAYS,M.SHELF_LIFE_DAYS),
	     NVL(I.SERIAL_NUMBER_CONTROL_CODE,M.SERIAL_NUMBER_CONTROL_CODE),
	     NVL(I.START_AUTO_SERIAL_NUMBER,M.START_AUTO_SERIAL_NUMBER),
	     NVL(I.AUTO_SERIAL_ALPHA_PREFIX,M.AUTO_SERIAL_ALPHA_PREFIX),
	     NVL(I.SOURCE_TYPE,M.SOURCE_TYPE),
	     NVL(I.SOURCE_ORGANIZATION_ID,M.SOURCE_ORGANIZATION_ID),
	     NVL(I.SOURCE_SUBINVENTORY,M.SOURCE_SUBINVENTORY),
             NVL(I.EXPENSE_ACCOUNT,M.EXPENSE_ACCOUNT),
	     NVL(I.ENCUMBRANCE_ACCOUNT,M.ENCUMBRANCE_ACCOUNT),
	     NVL(I.RESTRICT_SUBINVENTORIES_CODE,M.RESTRICT_SUBINVENTORIES_CODE),
	     NVL(I.UNIT_WEIGHT,M.UNIT_WEIGHT),
	     NVL(I.WEIGHT_UOM_CODE,M.WEIGHT_UOM_CODE),
	     NVL(I.VOLUME_UOM_CODE,M.VOLUME_UOM_CODE),
	     NVL(I.UNIT_VOLUME,M.UNIT_VOLUME),
	     NVL(I.RESTRICT_LOCATORS_CODE,M.RESTRICT_LOCATORS_CODE),
	     NVL(I.LOCATION_CONTROL_CODE,M.LOCATION_CONTROL_CODE),
	     NVL(I.SHRINKAGE_RATE,M.SHRINKAGE_RATE),
	     NVL(I.ACCEPTABLE_EARLY_DAYS,M.ACCEPTABLE_EARLY_DAYS),
	     NVL(I.PLANNING_TIME_FENCE_CODE,M.PLANNING_TIME_FENCE_CODE),
	     NVL(I.DEMAND_TIME_FENCE_CODE,M.DEMAND_TIME_FENCE_CODE),
	     NVL(I.LEAD_TIME_LOT_SIZE,M.LEAD_TIME_LOT_SIZE),
	     NVL(I.STD_LOT_SIZE,M.STD_LOT_SIZE),
	     NVL(I.CUM_MANUFACTURING_LEAD_TIME,M.CUM_MANUFACTURING_LEAD_TIME),
	     NVL(I.OVERRUN_PERCENTAGE,M.OVERRUN_PERCENTAGE),
	     NVL(I.ACCEPTABLE_RATE_INCREASE,M.ACCEPTABLE_RATE_INCREASE),
	     NVL(I.ACCEPTABLE_RATE_DECREASE,M.ACCEPTABLE_RATE_DECREASE),
	     NVL(I.CUMULATIVE_TOTAL_LEAD_TIME,M.CUMULATIVE_TOTAL_LEAD_TIME),
	     NVL(I.PLANNING_TIME_FENCE_DAYS,M.PLANNING_TIME_FENCE_DAYS),
	     NVL(I.DEMAND_TIME_FENCE_DAYS,M.DEMAND_TIME_FENCE_DAYS),
             NVL(I.END_ASSEMBLY_PEGGING_FLAG,M.END_ASSEMBLY_PEGGING_FLAG),
	     NVL(I.PLANNING_EXCEPTION_SET,M.PLANNING_EXCEPTION_SET),
             NVL(I.BOM_ITEM_TYPE,M.BOM_ITEM_TYPE),
	     NVL(I.PICK_COMPONENTS_FLAG,M.PICK_COMPONENTS_FLAG),
	     NVL(I.REPLENISH_TO_ORDER_FLAG,M.REPLENISH_TO_ORDER_FLAG),
	     NVL(I.BASE_ITEM_ID,M.BASE_ITEM_ID),
	     NVL(I.ATP_COMPONENTS_FLAG,M.ATP_COMPONENTS_FLAG),
	     NVL(I.ATP_FLAG,M.ATP_FLAG),
	     NVL(I.FIXED_LEAD_TIME,M.FIXED_LEAD_TIME),
	     NVL(I.VARIABLE_LEAD_TIME,M.VARIABLE_LEAD_TIME),
	     NVL(I.WIP_SUPPLY_LOCATOR_ID,M.WIP_SUPPLY_LOCATOR_ID),
	     NVL(I.WIP_SUPPLY_TYPE,M.WIP_SUPPLY_TYPE),
	     NVL(I.WIP_SUPPLY_SUBINVENTORY,M.WIP_SUPPLY_SUBINVENTORY),
	     NVL(I.PRIMARY_UOM_CODE,M.PRIMARY_UOM_CODE),
	     NVL(I.PRIMARY_UNIT_OF_MEASURE,M.PRIMARY_UNIT_OF_MEASURE),
	     NVL(I.ALLOWED_UNITS_LOOKUP_CODE,M.ALLOWED_UNITS_LOOKUP_CODE),
	     NVL(I.COST_OF_SALES_ACCOUNT,M.COST_OF_SALES_ACCOUNT),
	     NVL(I.SALES_ACCOUNT,M.SALES_ACCOUNT),
             NVL(I.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,M.DEFAULT_INCLUDE_IN_ROLLUP_FLAG),
	     NVL(I.INVENTORY_ITEM_STATUS_CODE,M.INVENTORY_ITEM_STATUS_CODE),
	     NVL(I.INVENTORY_PLANNING_CODE,M.INVENTORY_PLANNING_CODE),
	     NVL(I.PLANNER_CODE,M.PLANNER_CODE),
	     NVL(I.PLANNING_MAKE_BUY_CODE,M.PLANNING_MAKE_BUY_CODE),
	     NVL(I.FIXED_LOT_MULTIPLIER,M.FIXED_LOT_MULTIPLIER),
	     NVL(I.ROUNDING_CONTROL_TYPE,M.ROUNDING_CONTROL_TYPE),
	     NVL(I.CARRYING_COST,M.CARRYING_COST),
	     NVL(I.POSTPROCESSING_LEAD_TIME,M.POSTPROCESSING_LEAD_TIME),
	     NVL(I.PREPROCESSING_LEAD_TIME,M.PREPROCESSING_LEAD_TIME),
	     NVL(I.FULL_LEAD_TIME,M.FULL_LEAD_TIME),
	     NVL(I.ORDER_COST,M.ORDER_COST),
	     NVL(I.MRP_SAFETY_STOCK_PERCENT,M.MRP_SAFETY_STOCK_PERCENT),
	     NVL(I.MRP_SAFETY_STOCK_CODE,M.MRP_SAFETY_STOCK_CODE),
             NVL(I.MIN_MINMAX_QUANTITY,M.MIN_MINMAX_QUANTITY),
	     NVL(I.MAX_MINMAX_QUANTITY,M.MAX_MINMAX_QUANTITY),
	     NVL(I.MINIMUM_ORDER_QUANTITY,M.MINIMUM_ORDER_QUANTITY),
	     NVL(I.FIXED_ORDER_QUANTITY,M.FIXED_ORDER_QUANTITY),
	     NVL(I.FIXED_DAYS_SUPPLY,M.FIXED_DAYS_SUPPLY),
	     NVL(I.MAXIMUM_ORDER_QUANTITY,M.MAXIMUM_ORDER_QUANTITY),
	     NVL(I.ATP_RULE_ID,M.ATP_RULE_ID),
	     NVL(I.PICKING_RULE_ID,M.PICKING_RULE_ID),
	     NVL(I.RESERVABLE_TYPE,M.RESERVABLE_TYPE),
             NVL(I.POSITIVE_MEASUREMENT_ERROR,M.POSITIVE_MEASUREMENT_ERROR),
             NVL(I.NEGATIVE_MEASUREMENT_ERROR,M.NEGATIVE_MEASUREMENT_ERROR),
	     NVL(I.ENGINEERING_ECN_CODE,M.ENGINEERING_ECN_CODE),
	     NVL(I.ENGINEERING_ITEM_ID,M.ENGINEERING_ITEM_ID),
	     NVL(I.ENGINEERING_DATE,M.ENGINEERING_DATE),
	     NVL(I.SERVICE_STARTING_DELAY,M.SERVICE_STARTING_DELAY),
	     NVL(I.VENDOR_WARRANTY_FLAG,M.VENDOR_WARRANTY_FLAG),
	     NVL(I.SERVICEABLE_COMPONENT_FLAG,M.SERVICEABLE_COMPONENT_FLAG),
	     NVL(I.SERVICEABLE_PRODUCT_FLAG,M.SERVICEABLE_PRODUCT_FLAG),
	     NVL(I.BASE_WARRANTY_SERVICE_ID,M.BASE_WARRANTY_SERVICE_ID),
	     NVL(I.PAYMENT_TERMS_ID,M.PAYMENT_TERMS_ID),
	     NVL(I.PREVENTIVE_MAINTENANCE_FLAG,M.PREVENTIVE_MAINTENANCE_FLAG),
	     NVL(I.PRIMARY_SPECIALIST_ID,M.PRIMARY_SPECIALIST_ID),
	     NVL(I.SECONDARY_SPECIALIST_ID,M.SECONDARY_SPECIALIST_ID),
	     NVL(I.SERVICEABLE_ITEM_CLASS_ID,M.SERVICEABLE_ITEM_CLASS_ID),
	     NVL(I.TIME_BILLABLE_FLAG,M.TIME_BILLABLE_FLAG),
	     NVL(I.MATERIAL_BILLABLE_FLAG,M.MATERIAL_BILLABLE_FLAG),
	     NVL(I.EXPENSE_BILLABLE_FLAG,M.EXPENSE_BILLABLE_FLAG),
	     NVL(I.PRORATE_SERVICE_FLAG,M.PRORATE_SERVICE_FLAG),
	     NVL(I.COVERAGE_SCHEDULE_ID,M.COVERAGE_SCHEDULE_ID),
	     NVL(I.SERVICE_DURATION_PERIOD_CODE,M.SERVICE_DURATION_PERIOD_CODE),
	     NVL(I.SERVICE_DURATION,M.SERVICE_DURATION),
	     NVL(I.MAX_WARRANTY_AMOUNT,M.MAX_WARRANTY_AMOUNT),
	     NVL(I.RESPONSE_TIME_PERIOD_CODE,M.RESPONSE_TIME_PERIOD_CODE),
	     NVL(I.RESPONSE_TIME_VALUE,M.RESPONSE_TIME_VALUE),
             NVL(I.NEW_REVISION_CODE,M.NEW_REVISION_CODE),
	     NVL(I.TAX_CODE,M.TAX_CODE),
	     NVL(I.MUST_USE_APPROVED_VENDOR_FLAG,M.MUST_USE_APPROVED_VENDOR_FLAG),
	     NVL(I.SAFETY_STOCK_BUCKET_DAYS,M.SAFETY_STOCK_BUCKET_DAYS),
             NVL(I.AUTO_REDUCE_MPS,M.AUTO_REDUCE_MPS),
             NVL(I.COSTING_ENABLED_FLAG,M.COSTING_ENABLED_FLAG),
             NVL(I.INVOICEABLE_ITEM_FLAG,M.INVOICEABLE_ITEM_FLAG),
             NVL(I.INVOICE_ENABLED_FLAG, M.INVOICE_ENABLED_FLAG),
             NVL(I.OUTSIDE_OPERATION_FLAG,M.OUTSIDE_OPERATION_FLAG),
             NVL(I.OUTSIDE_OPERATION_UOM_TYPE,M.OUTSIDE_OPERATION_UOM_TYPE),
             NVL(I.AUTO_CREATED_CONFIG_FLAG,  'Y'),
             NVL(I.CYCLE_COUNT_ENABLED_FLAG,M.CYCLE_COUNT_ENABLED_FLAG),
	     I.ITEM_TYPE,
             NVL(I.MODEL_CONFIG_CLAUSE_NAME,M.MODEL_CONFIG_CLAUSE_NAME),
             NVL(I.SHIP_MODEL_COMPLETE_FLAG,M.SHIP_MODEL_COMPLETE_FLAG),
             NVL(I.MRP_PLANNING_CODE,M.MRP_PLANNING_CODE),
             I.REPETITIVE_PLANNING_FLAG,
             NVL(I.RETURN_INSPECTION_REQUIREMENT,M.RETURN_INSPECTION_REQUIREMENT),
             nvl( NVL(I.EFFECTIVITY_CONTROL,M.EFFECTIVITY_CONTROL), 1),
 	     req_id,
             prg_appid,
             prg_id,
             SYSDATE
      from
	     MTL_PARAMETERS MP1,
	     MTL_PARAMETERS MP2,
             MTL_SYSTEM_ITEMS_B  M,           /* Model */
	     MTL_SYSTEM_ITEMS_INTERFACE I
      where  M.ORGANIZATION_ID = MP1.ORGANIZATION_ID
      and    I.COPY_ITEM_ID = M.INVENTORY_ITEM_ID
      and    I.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
      and    MP2.organization_id = I.organization_id
      and  ((I.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
            (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	    (MP1.ORGANIZATION_ID = validation_org ));

  --
  -- R11.5 MLS
  --
  insert into MTL_SYSTEM_ITEMS_TL (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    I.INVENTORY_ITEM_ID,
    MP1.ORGANIZATION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    NVL(I.DESCRIPTION,M.DESCRIPTION),
    NVL(I.LAST_UPDATE_DATE,SYSDATE),
    user_id,       /* last_updated_by */
    NVL(I.CREATION_DATE,SYSDATE),
    user_id,       /* created_by */
    login_id       /* last_update_login */
  from
         MTL_PARAMETERS MP1,
         MTL_PARAMETERS MP2,
         MTL_SYSTEM_ITEMS_B  M,           /* Model */
         MTL_SYSTEM_ITEMS_INTERFACE I
      ,  FND_LANGUAGES  L
  where  M.ORGANIZATION_ID = MP1.ORGANIZATION_ID
  and    I.COPY_ITEM_ID = M.INVENTORY_ITEM_ID
  and    I.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
  and    MP2.organization_id = I.organization_id
  and  ((I.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
        (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
        (MP1.ORGANIZATION_ID = validation_org ))
    and  L.INSTALLED_FLAG in ('I', 'B')
    and  not exists
         ( select NULL
           from  MTL_SYSTEM_ITEMS_TL  T
           where  T.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
             and  T.ORGANIZATION_ID = MP1.ORGANIZATION_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

    /* Copy the item revisions into the item revisions table            */

      table_name := 'MTL_ITEM_REVISIONS';
      insert into MTL_ITEM_REVISIONS
	    (INVENTORY_ITEM_ID,
	     ORGANIZATION_ID,
	     REVISION,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
	     IMPLEMENTATION_DATE,
             EFFECTIVITY_DATE
            )
     select
             R.INVENTORY_ITEM_ID,
             MP1.ORGANIZATION_ID,
	     R.REVISION,
	     NVL(R.LAST_UPDATE_DATE,SYSDATE),
	     user_id,       /* LAST_UPDATED_BY */
	     NVL(R.CREATION_DATE,SYSDATE),
             user_id,       /* created_by */
             login_id,      /* last_update_login */
	     SYSDATE,
             SYSDATE
      from
	     MTL_PARAMETERS MP1,
	     MTL_PARAMETERS MP2,
	     MTL_SYSTEM_ITEMS_INTERFACE R
      where  R.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
      and    MP2.organization_id = R.organization_id
      and  ((R.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
            (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	    (MP1.ORGANIZATION_ID = validation_org ));

      /* Create rows for config items in the MTL_PENDING_ITEM_STATUS */

	table_name := 'MTL_PENDING_ITEM_STATUS';
	insert into MTL_PENDING_ITEM_STATUS (
 		INVENTORY_ITEM_ID,
 		ORGANIZATION_ID,
 		STATUS_CODE,
 		EFFECTIVE_DATE,
 		PENDING_FLAG,
		LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
 		PROGRAM_APPLICATION_ID,
 		PROGRAM_ID,
 		PROGRAM_UPDATE_DATE,
 		REQUEST_ID)
	select
                R.INVENTORY_ITEM_ID,
                MP1.ORGANIZATION_ID,
                SI.INVENTORY_ITEM_STATUS_CODE,
                SYSDATE,
                'N',
		NVL(R.LAST_UPDATE_DATE,SYSDATE),
                user_id,
                NVL(R.CREATION_DATE,SYSDATE),
                user_id,
                login_id,
             	prg_appid,
             	prg_id,
             	SYSDATE,
		req_id
        from   MTL_SYSTEM_ITEMS_B SI,
               MTL_PARAMETERS MP1,
               MTL_PARAMETERS MP2,
      	       MTL_SYSTEM_ITEMS_INTERFACE R
      	where  R.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
	and    R.inventory_item_id = SI.inventory_item_id
        and    R.organization_id = SI.organization_id
        and    MP2.organization_id = R.organization_id
      	and    ((R.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
                (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	        (MP1.ORGANIZATION_ID = validation_org ));


   /* **************************************************************** */
   /*                                                                  */
   /* The logic for the cst_item_costs and cst_item_costs_detail       */
   /* is different from the other table loads.  These tables will load */
   /* whatever data is found in their interface tables exactly as they */
   /* are.  The logic is this way because there is no unique key on    */
   /* on the cst_item_costs_detail table for us to match to a model's  */
   /* row.                                                             */
   /* Above logic has been changed to copy the data from the model     */
   /* in the respective org rather than keeping the same data in all   */
   /* three Orgs. It is important because these Orgs may have different*/
   /* Primary costing methods since we support avg costing now.        */
   /*                                                                  */
   /* **************************************************************** */

   /* Copy the item cost attributes into the regular product table     */
      table_name := 'CST_ITEM_COSTS';
      insert into CST_ITEM_COSTS
		(
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                COST_TYPE_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                INVENTORY_ASSET_FLAG,
                LOT_SIZE,
                BASED_ON_ROLLUP_FLAG,
                SHRINKAGE_RATE,
                DEFAULTED_FLAG,
                COST_UPDATE_ID,
                PL_MATERIAL,
                PL_MATERIAL_OVERHEAD,
                PL_RESOURCE,
                PL_OUTSIDE_PROCESSING,
                PL_OVERHEAD,
                TL_MATERIAL,
                TL_MATERIAL_OVERHEAD,
                TL_RESOURCE,
                TL_OUTSIDE_PROCESSING,
                TL_OVERHEAD,
                MATERIAL_COST,
                MATERIAL_OVERHEAD_COST,
                RESOURCE_COST,
                OUTSIDE_PROCESSING_COST ,
                OVERHEAD_COST,
                PL_ITEM_COST,
                TL_ITEM_COST,
                ITEM_COST,
                UNBURDENED_COST ,
                BURDEN_COST,
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
                PROGRAM_UPDATE_DATE
		)
      select
                SI.INVENTORY_ITEM_ID,
                MP1.ORGANIZATION_ID,
		C.COST_TYPE_ID,
		NVL(C.LAST_UPDATE_DATE,SYSDATE),
		user_id,       /* LAST_UPDATED_BY */
		NVL(C.CREATION_DATE,SYSDATE),
		user_id,       /* created_by */
                login_id,      /* last_update_login */
		C.INVENTORY_ASSET_FLAG,
                C.LOT_SIZE,
		C.BASED_ON_ROLLUP_FLAG,
                C.SHRINKAGE_RATE,
                C.DEFAULTED_FLAG,
                NVL(C.COST_UPDATE_ID,CST_LISTS_S.NEXTVAL),
                C.PL_MATERIAL,
                C.PL_MATERIAL_OVERHEAD,
                C.PL_RESOURCE,
                C.PL_OUTSIDE_PROCESSING,
                C.PL_OVERHEAD,
                C.TL_MATERIAL,
                C.TL_MATERIAL_OVERHEAD,
                C.TL_RESOURCE,
                C.TL_OUTSIDE_PROCESSING,
                C.TL_OVERHEAD,
                C.MATERIAL_COST,
                C.MATERIAL_OVERHEAD_COST,
                C.RESOURCE_COST,
                C.OUTSIDE_PROCESSING_COST ,
                C.OVERHEAD_COST,
                C.PL_ITEM_COST,
                C.TL_ITEM_COST,
                C.ITEM_COST,
                C.UNBURDENED_COST ,
                C.BURDEN_COST,
		C.ATTRIBUTE_CATEGORY,
                C.ATTRIBUTE1,
                C.ATTRIBUTE2,
                C.ATTRIBUTE3,
                C.ATTRIBUTE4,
                C.ATTRIBUTE5,
                C.ATTRIBUTE6,
                C.ATTRIBUTE7,
                C.ATTRIBUTE8,
                C.ATTRIBUTE9,
                C.ATTRIBUTE10,
                C.ATTRIBUTE11,
                C.ATTRIBUTE12,
                C.ATTRIBUTE13,
                C.ATTRIBUTE14,
                C.ATTRIBUTE15,
                req_id,        /* request_id */
                prg_appid,     /* program_application_id */
                prg_id,        /* program_id */
                SYSDATE
      from
             CST_ITEM_COSTS C,
             MTL_PARAMETERS MP1,
	     MTL_PARAMETERS MP2,
	     MTL_SYSTEM_ITEMS_INTERFACE SI
      where  C.ORGANIZATION_ID = MP1.ORGANIZATION_ID
      and    C.INVENTORY_ITEM_ID = SI.Copy_item_id
      and    C.COST_TYPE_ID  IN ( MP1.PRIMARY_COST_METHOD, MP1.AVG_RATES_COST_TYPE_ID)
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
      and    MP2.organization_id = SI.organization_id
      and  ((SI.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
                (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	        (MP1.ORGANIZATION_ID = validation_org ));


    /* Copy the item cost details into the regular product table        */

      table_name := 'CST_ITEM_COST_DETAILS';
      insert into CST_ITEM_COST_DETAILS
	    (INVENTORY_ITEM_ID,
	     ORGANIZATION_ID,
	     COST_TYPE_ID,
	     LAST_UPDATE_DATE,
	     LAST_UPDATED_BY,
	     CREATION_DATE,
	     CREATED_BY,
	     LAST_UPDATE_LOGIN,
             OPERATION_SEQUENCE_ID,
	     OPERATION_SEQ_NUM,
	     DEPARTMENT_ID,
	     LEVEL_TYPE,
	     ACTIVITY_ID,
	     RESOURCE_SEQ_NUM,
	     RESOURCE_ID,
	     RESOURCE_RATE,
	     ITEM_UNITS,
	     ACTIVITY_UNITS,
	     USAGE_RATE_OR_AMOUNT,
	     BASIS_TYPE,
	     BASIS_RESOURCE_ID,
	     BASIS_FACTOR,
	     NET_YIELD_OR_SHRINKAGE_FACTOR,
	     ITEM_COST,
	     COST_ELEMENT_ID,
	     ROLLUP_SOURCE_TYPE,
             ACTIVITY_CONTEXT,
	     REQUEST_ID,
	     PROGRAM_APPLICATION_ID,
	     PROGRAM_ID,
	     PROGRAM_UPDATE_DATE,
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
             ATTRIBUTE15
            )
      select SI.INVENTORY_ITEM_ID,
             MP1.ORGANIZATION_ID,
	     C.COST_TYPE_ID,
	     NVL(C.LAST_UPDATE_DATE,SYSDATE),
	     user_id,       /* LAST_UPDATED_BY */
	     NVL(C.CREATION_DATE,SYSDATE),
	     user_id,       /* created_by */
             login_id,      /* last_update_login */
             C.OPERATION_SEQUENCE_ID,
	     C.OPERATION_SEQ_NUM,
	     C.DEPARTMENT_ID,
	     C.LEVEL_TYPE,
	     C.ACTIVITY_ID,
	     C.RESOURCE_SEQ_NUM,
	     C.RESOURCE_ID,
	     C.RESOURCE_RATE,
	     C.ITEM_UNITS,
	     C.ACTIVITY_UNITS,
	     C.USAGE_RATE_OR_AMOUNT,
	     C.BASIS_TYPE,
	     C.BASIS_RESOURCE_ID,
	     C.BASIS_FACTOR,
	     C.NET_YIELD_OR_SHRINKAGE_FACTOR,
	     C.ITEM_COST,
	     C.COST_ELEMENT_ID,
	     C.ROLLUP_SOURCE_TYPE,
             C.ACTIVITY_CONTEXT,
	     req_id,        /* request_id */
             prg_appid,     /* program_application_id */
             prg_id,        /* program_id */
             SYSDATE,         /* program_update_date */
             C.ATTRIBUTE_CATEGORY,
             C.ATTRIBUTE1,
             C.ATTRIBUTE2,
             C.ATTRIBUTE3,
             C.ATTRIBUTE4,
             C.ATTRIBUTE5,
             C.ATTRIBUTE6,
             C.ATTRIBUTE7,
             C.ATTRIBUTE8,
             C.ATTRIBUTE9,
             C.ATTRIBUTE10,
             C.ATTRIBUTE11,
             C.ATTRIBUTE12,
             C.ATTRIBUTE13,
             C.ATTRIBUTE14,
             C.ATTRIBUTE15
      from
             CST_ITEM_COST_DETAILS C,
             MTL_PARAMETERS MP1,
	     MTL_PARAMETERS MP2,
	     MTL_SYSTEM_ITEMS_INTERFACE SI
      where  C.ORGANIZATION_ID = MP1.ORGANIZATION_ID
      and    C.INVENTORY_ITEM_ID = SI.COPY_ITEM_ID
      and    C.COST_TYPE_ID  IN ( MP1.PRIMARY_COST_METHOD, MP1.AVG_RATES_COST_TYPE_ID)
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
      and    MP2.organization_id = SI.organization_id
      and  ((SI.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
               (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	        (MP1.ORGANIZATION_ID = validation_org ));


     /* If the config item is being created in an average costing organisation
        insert a blank row in cst_quantity_layers  to earn MOH when the
        item is transacted. If the item is being created in the shipping org,
        and the corrosponding Sales order has project refrence, use projects
        cost_group_id.
     */

     l_cost_group_id := 1;

     for nxtconfig in allconfig
     loop
         if nxtconfig.project_id is NULL then
            l_cost_group_id := 1;
         else
            select nvl(costing_group_id,1)
            into   l_cost_group_id
            from   pjm_project_parameters ppp
            where  ppp.project_id = nxtconfig.project_id
            and    ppp.organization_id = nxtconfig.organization_id;
          end if;

      insert into cst_quantity_layers (
             layer_id,
             organization_id,
             inventory_item_id,
             cost_group_id,
             layer_quantity,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             request_id,
             program_id,
             program_application_id,
             PL_MATERIAL,
             PL_MATERIAL_OVERHEAD,
             PL_RESOURCE,
             PL_OUTSIDE_PROCESSING,
             PL_OVERHEAD,
             TL_MATERIAL,
             TL_MATERIAL_OVERHEAD,
             TL_RESOURCE,
             TL_OUTSIDE_PROCESSING,
             TL_OVERHEAD,
             MATERIAL_COST,
             MATERIAL_OVERHEAD_COST ,
             RESOURCE_COST,
             OUTSIDE_PROCESSING_COST,
             OVERHEAD_COST,
             PL_ITEM_COST,
             TL_ITEM_COST,
             ITEM_COST,
             UNBURDENED_COST,
             BURDEN_COST,
             CREATE_TRANSACTION_ID
             )
           Select
             cst_quantity_layers_s.nextval,
             MP1.organization_id,
             SI.inventory_item_id,
             DECODE(MP1.ORGANIZATION_ID, SI.ORGANIZATION_ID,l_cost_group_id,1),    /* cost_group_id   */
             0,
             SYSDATE,
             user_id,
             SYSDATE,
             user_id,
             req_id,
             prg_id,
             prg_appid,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             -1    /*  txn_id */
         from
            MTL_SYSTEM_ITEMS_INTERFACE SI,
            MTL_PARAMETERS MP1,
            MTL_PARAMETERS MP2,
            CST_ITEM_COSTS C
        where
            C.ORGANIZATION_ID       = MP1.ORGANIZATION_ID
        and C.INVENTORY_ITEM_ID     = SI.COPY_ITEM_ID
        and C.COST_TYPE_ID          = MP1.primary_cost_method /*Average FIFO/LIFO Costing */
        and SI.SET_ID               = TO_CHAR(to_number(USERENV('SESSIONID')))
        and MP2.organization_id     = SI.organization_id
        and ((SI.ORGANIZATION_ID    = MP1.ORGANIZATION_ID) OR
               (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
               (MP1.ORGANIZATION_ID = validation_org ))
        and MP1.Primary_cost_method IN (2,5,6); /* Create only in Average costing organization*/
   end loop;

    /* Copy the item descriptive element values into the regular
       product table.                                                   */

      table_name := 'MTL_DESCR_ELEMENT_VALUES';
      insert into MTL_DESCR_ELEMENT_VALUES
	    (INVENTORY_ITEM_ID,
             ELEMENT_NAME,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             ELEMENT_VALUE,
             DEFAULT_ELEMENT_FLAG,
	     PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             REQUEST_ID,
             ELEMENT_SEQUENCE
            )
      select V.INVENTORY_ITEM_ID,
             NVL(V.ELEMENT_NAME,M.ELEMENT_NAME),
             NVL(V.LAST_UPDATE_DATE,SYSDATE),
	     user_id,       /* last_updated_by */
             login_id,      /* last_update_login */
             NVL(V.CREATION_DATE,SYSDATE),
	     user_id,       /* created_by */
             NVL(V.ELEMENT_VALUE,M.ELEMENT_VALUE),
             NVL(V.DEFAULT_ELEMENT_FLAG,M.DEFAULT_ELEMENT_FLAG),
	     prg_appid,		/* PROGRAM_APPLICATION_ID */
             prg_id,		/* PROGRAM_ID */
             SYSDATE,		/* PROGRAM_UPDATE_DATE */
             req_id,		/* REQUEST_ID */
             NVL(V.ELEMENT_SEQUENCE,M.ELEMENT_SEQUENCE)
      from   MTL_DESCR_ELEMENT_VALUES M,  /* Model's desc elem values */
             MTL_DESC_ELEM_VAL_INTERFACE V,
	     MTL_SYSTEM_ITEMS_INTERFACE SI
      where  V.INVENTORY_ITEM_ID = SI.INVENTORY_ITEM_ID
      and    SI.SET_ID = TO_CHAR(to_number(USERENV('SESSIONID')))
      and    M.INVENTORY_ITEM_ID = SI.COPY_ITEM_ID
      and    M.ELEMENT_NAME = V.ELEMENT_NAME; /* This where clause was  */
                                              /* originally an outer join */


	/* Copy item categories into MTL_ITEM_CATEGORIES table */
	        table_name := 'MTL_ITEM_CATEGORIES';
		insert into MTL_ITEM_CATEGORIES
		(	inventory_item_id,
			category_set_id,
			category_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			organization_id
		)
		select
                        ici.inventory_item_id,
                        ici.category_set_id,
                        ici.category_id,
                        NVL(ici.last_update_date,sysdate),
                        user_id,	/* last_updated_by */
                        NVL(ici.creation_date, sysdate),
                        user_id,	/* created_by */
                        login_id,	/* last_update_login */
             		req_id,        /* request_id */
             		prg_appid,     /* program_application_id */
             		prg_id,        /* program_id */
             		SYSDATE,        /* program_update_date */
			MP1.organization_id
	        from	MTL_PARAMETERS MP1,
			MTL_PARAMETERS MP2,
                        mtl_item_categories_interface ici,
			mtl_system_items_interface si
                where si.inventory_item_id = ici.inventory_item_id
		and   si.organization_id = ici.organization_id
		and   ici.category_set_id is not NULL
		and   ici.category_id is not NULL
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
	        and   MP2.organization_id = si.organization_id
      		and  ((si.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
                      (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	              (MP1.ORGANIZATION_ID = validation_org ));

	        insert into MTL_ITEM_CATEGORIES
                (       inventory_item_id,
                        category_set_id,
                        category_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
			organization_id
                )
                select
			si.inventory_item_id,
                        ic.category_set_id,
                        ic.category_id,
                        sysdate,	/* last_update_date */
                        user_id,	/* last_updated_by */
                        sysdate,	/*creation_date */
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,        /* program_update_date */
			MP1.organization_id
		from
                        mtl_item_categories ic,
			MTL_PARAMETERS MP1,
			MTL_PARAMETERS MP2,
			mtl_system_items_interface si
                where si.copy_item_id = ic.inventory_item_id
		and   si.organization_id = ic.organization_id
		and   MP2.organization_id = si.organization_id
		and   not exists ( select NULL
		      from mtl_item_categories_interface ici
		      where ici.inventory_item_id = si.inventory_item_id
		      and   ici.organization_id = si.organization_id
		      and   ici.category_set_id is not NULL
		      and   ici.category_id is not NULL)
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                and  ((si.ORGANIZATION_ID = MP1.ORGANIZATION_ID) OR
                      (MP1.ORGANIZATION_ID = MP2.master_organization_id) OR
	              (MP1.ORGANIZATION_ID = validation_org ));



	/* Copy related items into MTL_RELATED_ITEMS table */
		table_name := 'MTL_RELATED_ITEMS';
		insert into MTL_RELATED_ITEMS
		(
			inventory_item_id,
			related_item_id,
			relationship_type_id,
			reciprocal_flag,
			last_update_date,
                        last_updated_by,
                        creation_date,                                                                  created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
			organization_id
                )
                select
                        rii.inventory_item_id,
                        rii.related_item_id,
                        rii.relationship_type_id,
                        rii.reciprocal_flag,
                        NVL(rii.last_update_date,sysdate),
                        user_id,       /* last_updated_by */
                        NVL(rii.creation_date, sysdate),
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,        /* program_update_date */
			rii.organization_id
		from mtl_related_items_interface rii,
                     mtl_system_items_interface si
		where rii.inventory_item_id = si.inventory_item_id
		and   rii.organization_id = si.organization_id
		and   rii.related_item_id is not NULL
		and   rii.relationship_type_id is not NULL
		and   rii.reciprocal_flag is not NULL
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));


                insert into MTL_RELATED_ITEMS
                (
                        inventory_item_id,
                        related_item_id,
                        relationship_type_id,
                        reciprocal_flag,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
			organization_id
                )
                select
			si.inventory_item_id,
                        ri.related_item_id,
                        ri.relationship_type_id,
                        ri.reciprocal_flag,
                        sysdate,        /* last_update_date */
                        user_id,       /* last_updated_by */
                        sysdate,        /*creation_date */
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,        /* program_update_date */
			ri.organization_id
                from mtl_related_items ri,
                     mtl_system_items_interface si
                where ri.inventory_item_id = si.copy_item_id
		and   ri.organization_id = si.organization_id
		and  not exists ( select NULL
		   	from mtl_related_items_interface rii
			where rii.inventory_item_id = si.inventory_item_id
			and   rii.organization_id = si.organization_id
		        and   rii.related_item_id is not NULL
                	and   rii.relationship_type_id is not NULL
                	and   rii.reciprocal_flag is not NULL)
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

	/* Copy substitute inventories into MTL_ITEM_SUB_INVENTORIES */
	        table_name := 'MTL_ITEM_SUB_INVENTORIES';
		insert into mtl_item_sub_inventories
		(
                       INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       SECONDARY_INVENTORY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       PRIMARY_SUBINVENTORY_FLAG ,
                       PICKING_ORDER,
                       MIN_MINMAX_QUANTITY,
                       MAX_MINMAX_QUANTITY,
                       INVENTORY_PLANNING_CODE,
                       FIXED_LOT_MULTIPLE,
                       MINIMUM_ORDER_QUANTITY,
                       MAXIMUM_ORDER_QUANTITY,
                       SOURCE_TYPE,
                       SOURCE_ORGANIZATION_ID,
                       SOURCE_SUBINVENTORY,
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
                       PROGRAM_APPLICATION_ID ,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       ENCUMBRANCE_ACCOUNT
		)
		select
                       isii.INVENTORY_ITEM_ID,
                       isii.ORGANIZATION_ID,
                       isii.SECONDARY_INVENTORY,
                       NVL(isii.LAST_UPDATE_DATE, SYSDATE),
                       user_id,	/* LAST_UPDATED_BY */
                       NVL(isii.CREATION_DATE, SYSDATE),
                       user_id,	/* CREATED_BY  */
                       login_id,	/* LAST_UPDATE_LOGIN */
                       isii.PRIMARY_SUBINVENTORY_FLAG,
                       isii.PICKING_ORDER,
                       isii.MIN_MINMAX_QUANTITY,
                       isii.MAX_MINMAX_QUANTITY,
                       isii.INVENTORY_PLANNING_CODE,
                       isii.FIXED_LOT_MULTIPLE,
                       isii.MINIMUM_ORDER_QUANTITY,
                       isii.MAXIMUM_ORDER_QUANTITY,
                       isii.SOURCE_TYPE,
                       isii.SOURCE_ORGANIZATION_ID,
                       isii.SOURCE_SUBINVENTORY,
                       isii.ATTRIBUTE_CATEGORY,
                       isii.ATTRIBUTE1,
                       isii.ATTRIBUTE2,
                       isii.ATTRIBUTE3,
                       isii.ATTRIBUTE4,
                       isii.ATTRIBUTE5,
                       isii.ATTRIBUTE6,
                       isii.ATTRIBUTE7,
                       isii.ATTRIBUTE8,
                       isii.ATTRIBUTE9,
                       isii.ATTRIBUTE10,
                       isii.ATTRIBUTE11,
                       isii.ATTRIBUTE12,
                       isii.ATTRIBUTE13,
                       isii.ATTRIBUTE14,
                       isii.ATTRIBUTE15,
                       req_id,        /* request_id */
                       prg_appid,     /* program_application_id */
                       prg_id,        /* program_id */
                       SYSDATE,         /* program_update_date */
                       isii.ENCUMBRANCE_ACCOUNT
		from
		     mtl_item_sub_invs_interface isii,
		     mtl_system_items_interface si
		where si.organization_id = isii.organization_id
		and   si.inventory_item_id = isii.inventory_item_id
		and   isii.secondary_inventory is not NULL
		and   isii.inventory_planning_code is not NULL
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

                insert into mtl_item_sub_inventories
                (
                       INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       SECONDARY_INVENTORY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       PRIMARY_SUBINVENTORY_FLAG ,
                       PICKING_ORDER,
                       MIN_MINMAX_QUANTITY,
                       MAX_MINMAX_QUANTITY,
                       INVENTORY_PLANNING_CODE,
                       FIXED_LOT_MULTIPLE,
                       MINIMUM_ORDER_QUANTITY,
                       MAXIMUM_ORDER_QUANTITY,
                       SOURCE_TYPE,
                       SOURCE_ORGANIZATION_ID,
                       SOURCE_SUBINVENTORY,
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
                       PROGRAM_APPLICATION_ID ,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       ENCUMBRANCE_ACCOUNT
                )
                select
                       si.INVENTORY_ITEM_ID,
                       isi.ORGANIZATION_ID,
                       isi.SECONDARY_INVENTORY,
                       sysdate,        /* last_update_date */
                       user_id,       /* last_updated_by */
                       sysdate,        /*creation_date */
                       user_id,       /* created_by */
                       login_id,      /* last_update_login */
                       isi.PRIMARY_SUBINVENTORY_FLAG ,
                       isi.PICKING_ORDER,
                       isi.MIN_MINMAX_QUANTITY,
                       isi.MAX_MINMAX_QUANTITY,
                       isi.INVENTORY_PLANNING_CODE,
                       isi.FIXED_LOT_MULTIPLE,
                       isi.MINIMUM_ORDER_QUANTITY,
                       isi.MAXIMUM_ORDER_QUANTITY,
                       isi.SOURCE_TYPE,
                       isi.SOURCE_ORGANIZATION_ID,
                       isi.SOURCE_SUBINVENTORY,
                       isi.ATTRIBUTE_CATEGORY,
                       isi.ATTRIBUTE1,
                       isi.ATTRIBUTE2,
                       isi.ATTRIBUTE3,
                       isi.ATTRIBUTE4,
                       isi.ATTRIBUTE5,
                       isi.ATTRIBUTE6,
                       isi.ATTRIBUTE7,
                       isi.ATTRIBUTE8,
                       isi.ATTRIBUTE9,
                       isi.ATTRIBUTE10,
                       isi.ATTRIBUTE11,
                       isi.ATTRIBUTE12,
                       isi.ATTRIBUTE13,
                       isi.ATTRIBUTE14,
                       isi.ATTRIBUTE15,
                       req_id,        /* request_id */
                       prg_appid,     /* program_application_id */
                       prg_id,        /* program_id */
                       SYSDATE,         /* program_update_date */
                       isi.ENCUMBRANCE_ACCOUNT
		from
		     mtl_item_sub_inventories isi,
		     mtl_system_items_interface si
		where si.organization_id = isi.organization_id
		and   si.copy_item_id = isi.inventory_item_id
		and not exists ( select NULL
			from mtl_item_sub_invs_interface isii
			where isii.inventory_item_id = si.inventory_item_id
			and   isii.organization_id = si.organization_id
                	and   isii.secondary_inventory is not NULL
                	and   isii.inventory_planning_code is not NULL)
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

	/* Copy secondary locators into MTL_SECONDARY_LOCATORS table */
	        table_name := 'MTL_SECONDARY_LOCATORS';
		insert into mtl_secondary_locators
		(
			inventory_item_id,
			organization_id,
			secondary_locator,
			primary_locator_flag,
			picking_order,
			subinventory_code,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
		)
		select
                        sli.inventory_item_id,
                        sli.organization_id,
                        sli.secondary_locator,
                        sli.primary_locator_flag,
                        sli.picking_order,
                        sli.subinventory_code,
                        NVL(sli.last_update_date,sysdate),
                        user_id,	/* last_updated_by */
                        NVL(sli.creation_date,sysdate),
                        user_id,	/* created_by */
                        login_id,	/* last_update_login */
                        req_id,        /* request_id */
                       	prg_appid,     /* program_application_id */
                       	prg_id,        /* program_id */
                        SYSDATE         /* program_update_date */
		from
                     mtl_secondary_locs_interface sli,
		     mtl_system_items_interface si
		where si.organization_id = sli.organization_id
		and   si.inventory_item_id = sli.inventory_item_id
		and   sli.secondary_locator is not NULL
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));


		insert into mtl_secondary_locators
                (
                        inventory_item_id,
                        organization_id,
                        secondary_locator,
                        primary_locator_flag,
                        picking_order,
                        subinventory_code,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
                )
                select
                        si.inventory_item_id,
                        sl.organization_id,
                        sl.secondary_locator,
                        sl.primary_locator_flag,
                        sl.picking_order,
                        sl.subinventory_code,
                        sysdate,        /* last_update_date */
                        user_id,       /* last_updated_by */
                        sysdate,        /*creation_date */
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE         /* program_update_date */
		from
		     mtl_secondary_locators sl,
		     mtl_system_items_interface si
		where si.organization_id = sl.organization_id
		and   si.copy_item_id = sl.inventory_item_id
		and not exists ( select NULL
			from  mtl_secondary_locs_interface sli
			where sli.inventory_item_id = si.inventory_item_id
			and   sli.organization_id = si.organization_id
			and   sli.secondary_locator is not NULL)
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

	/* Copy cross references into MTL_CROSS_REFERENCES table */
	        table_name := 'MTL_CROSS_REFERENCES table';
		insert into mtl_cross_references
		(
			inventory_item_id,
			organization_id,
			cross_reference_type,
			cross_reference,
			description,
			org_independent_flag,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
                )
		select
                        cri.inventory_item_id,
                        cri.organization_id,
                        cri.cross_reference_type,
                        cri.cross_reference,
                        cri.description,
                        cri.org_independent_flag,
                        NVL(cri.last_update_date,sysdate),
                        user_id,       /* last_updated_by */
                        NVL(cri.creation_date,sysdate),
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE         /* program_update_date */
		from
		     mtl_cross_references_interface cri,
		     mtl_system_items_interface si
		where (si.organization_id = cri.organization_id or
		    	cri.organization_id is NULL)
                and   si.inventory_item_id = cri.inventory_item_id
		and   cri.cross_reference_type is not NULL
		and   cri.cross_reference is not NULL
		and   org_independent_flag is not NULL
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));


		insert into mtl_cross_references
                (
                        inventory_item_id,
                        organization_id,
                        cross_reference_type,
                        cross_reference,
                        description,
                        org_independent_flag,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
                )
                select
                        si.inventory_item_id,
                        cr.organization_id,
                        cr.cross_reference_type,
                        cr.cross_reference,
                        cr.description,
                        cr.org_independent_flag,
                        sysdate,        /* last_update_date */
                        user_id,       /* last_updated_by */
                        sysdate,        /*creation_date */
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE         /* program_update_date */
                from
                     mtl_cross_references cr,
		     mtl_system_items_interface si
                where (si.organization_id = cr.organization_id or
		       cr.organization_id is NULL)
                and   si.copy_item_id = cr.inventory_item_id
		and not exists (select NULL
			from mtl_cross_references_interface cri
			where cri.inventory_item_id = si.inventory_item_id
			and   cri.organization_id = si.organization_id
                	and   cri.cross_reference_type is not NULL
                	and   cri.cross_reference is not NULL
                	and   org_independent_flag is not NULL )
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

        table_name := 'MTL_DESC_ELEM_VAL_INTERFACE';
	delete from MTL_DESC_ELEM_VAL_INTERFACE di
        where di.rowid in  ( select di2.rowid
		from    MTL_DESC_ELEM_VAL_INTERFACE di2,
			MTL_SYSTEM_ITEMS_INTERFACE si
		where si.inventory_item_id = di2.inventory_item_id
		and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'MTL_ITEM_CATEGORIES_INTERFACE';
        delete from MTL_ITEM_CATEGORIES_INTERFACE  ci
        where ci.rowid in ( select ci2.rowid
                from    MTL_ITEM_CATEGORIES_INTERFACE ci2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ci2.inventory_item_id
                and   si.organization_id = ci2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'MTL_RELATED_ITEMS_INTERFACE';
        delete from MTL_RELATED_ITEMS_INTERFACE ri
        where ri.rowid in  ( select ri2.rowid
                from    MTL_RELATED_ITEMS_INTERFACE ri2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ri2.inventory_item_id
                and   si.organization_id = ri2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'MTL_ITEM_SUB_INVS_INTERFACE';
        delete from MTL_ITEM_SUB_INVS_INTERFACE ii
        where ii.rowid in  ( select ii2.rowid
                from    MTL_ITEM_SUB_INVS_INTERFACE ii2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ii2.inventory_item_id
                and   si.organization_id = ii2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'MTL_SECONDARY_LOCS_INTERFACE';
        delete from MTL_SECONDARY_LOCS_INTERFACE li
        where li.rowid in  ( select li2.rowid
                from    MTL_SECONDARY_LOCS_INTERFACE li2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = li2.inventory_item_id
                and   si.organization_id = li2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'MTL_CROSS_REFERENCES_INTERFACE';
        delete from MTL_CROSS_REFERENCES_INTERFACE ri
        where rowid in  ( select ri2.rowid
                from    MTL_CROSS_REFERENCES_INTERFACE ri2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ri2.inventory_item_id
                and   (si.organization_id = ri2.organization_id or
			ri2.organization_id is NULL)
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'CST_ITEM_COSTS_INTERFACE';
        delete from CST_ITEM_COSTS_INTERFACE ci
        where ci.rowid in  ( select ci2.rowid
                from    CST_ITEM_COSTS_INTERFACE ci2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ci2.inventory_item_id
                and   si.organization_id = ci2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	table_name := 'CST_ITEM_CST_DTLS_INTERFACE';
        delete from CST_ITEM_CST_DTLS_INTERFACE ci
        where ci.rowid in  ( select ci2.rowid
                from    CST_ITEM_CST_DTLS_INTERFACE ci2,
			MTL_SYSTEM_ITEMS_INTERFACE si
                where si.inventory_item_id = ci2.inventory_item_id
                and   si.organization_id = ci2.organization_id
                and   si.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));
	return(1);

  EXCEPTION
     WHEN NO_DATA_FOUND then
	return (1);
     WHEN others THEN
        error_message := 'INVPPRCI:' || substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        return(0);

END inproit_process_item;


end invpprci;

/
