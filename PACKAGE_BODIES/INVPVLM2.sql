--------------------------------------------------------
--  DDL for Package Body INVPVLM2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVLM2" AS
/* $Header: INVPVM2B.pls 120.2 2005/07/14 01:08:15 anmurali ship $ */

FUNCTION validate_item_org4
(
org_id		number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out	NOCOPY varchar2,
xset_id  IN     NUMBER  DEFAULT -999
)
return integer
is
	/*
	** Retrieve column values for validation
	*/
	CURSOR cc is
	select
	 msii.TRANSACTION_ID,
	 msii.INVENTORY_ITEM_ID III,
	 msii.ORGANIZATION_ID ORGID,
	 mp.MASTER_ORGANIZATION_ID MORGID,
 	 msii.START_AUTO_LOT_NUMBER,
	 msii.LOT_CONTROL_CODE,
	 msii.SHELF_LIFE_CODE,
	 msii.SHELF_LIFE_DAYS,
	 msii.SERIAL_NUMBER_CONTROL_CODE,
	 msii.START_AUTO_SERIAL_NUMBER,
	 msii.AUTO_SERIAL_ALPHA_PREFIX,
	 msii.SOURCE_TYPE,
	 msii.SOURCE_ORGANIZATION_ID,
	 msii.SOURCE_SUBINVENTORY,
	 msii.EXPENSE_ACCOUNT,
	 msii.ENCUMBRANCE_ACCOUNT,
	 msii.RESTRICT_SUBINVENTORIES_CODE,
	 msii.UNIT_WEIGHT,
	 msii.WEIGHT_UOM_CODE,
	 msii.VOLUME_UOM_CODE,
	 msii.UNIT_VOLUME,
	 msii.RESTRICT_LOCATORS_CODE,
	 msii.LOCATION_CONTROL_CODE,
	 msii.SHRINKAGE_RATE,
	 msii.ACCEPTABLE_EARLY_DAYS,
	 msii.PLANNING_TIME_FENCE_CODE,
	 msii.DEMAND_TIME_FENCE_CODE,
	 msii.LEAD_TIME_LOT_SIZE,
	 msii.STD_LOT_SIZE,
	 msii.CUM_MANUFACTURING_LEAD_TIME,
	 msii.OVERRUN_PERCENTAGE,
	 msii.MRP_CALCULATE_ATP_FLAG,
	 msii.ACCEPTABLE_RATE_INCREASE,
	 msii.ACCEPTABLE_RATE_DECREASE,
 	 msii.CUMULATIVE_TOTAL_LEAD_TIME,
	 msii.PLANNING_TIME_FENCE_DAYS,
	 msii.DEMAND_TIME_FENCE_DAYS,
	 msii.END_ASSEMBLY_PEGGING_FLAG,
	 msii.REPETITIVE_PLANNING_FLAG,
	 msii.PLANNING_EXCEPTION_SET,
	 msii.BOM_ITEM_TYPE,
	 msii.PICK_COMPONENTS_FLAG,
	 msii.REPLENISH_TO_ORDER_FLAG,
	 msii.BASE_ITEM_ID,
	 msii.ATP_COMPONENTS_FLAG,
	 msii.ATP_FLAG,
	 msii.FIXED_LEAD_TIME,
	 msii.VARIABLE_LEAD_TIME,
	 msii.WIP_SUPPLY_LOCATOR_ID,
	 msii.WIP_SUPPLY_TYPE,
	 msii.WIP_SUPPLY_SUBINVENTORY,
	 msii.PRIMARY_UOM_CODE,
	-- msii.PRIMARY_UNIT_OF_MEASURE,
	 msii.ALLOWED_UNITS_LOOKUP_CODE,
	 msii.COST_OF_SALES_ACCOUNT,
	 msii.SALES_ACCOUNT,
	 msii.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
	 msii.INVENTORY_ITEM_STATUS_CODE,
	 msii.INVENTORY_PLANNING_CODE,
	 msii.PLANNER_CODE,
	 msii.PLANNING_MAKE_BUY_CODE,
	 msii.FIXED_LOT_MULTIPLIER,
	 msii.ROUNDING_CONTROL_TYPE,
	 msii.CARRYING_COST,
 	 msii.POSTPROCESSING_LEAD_TIME,
	 msii.PREPROCESSING_LEAD_TIME,
	 msii.FULL_LEAD_TIME,
	 msii.ORDER_COST,
	 msii.MRP_SAFETY_STOCK_PERCENT,
	 msii.MRP_SAFETY_STOCK_CODE,
	 msii.MIN_MINMAX_QUANTITY,
	 msii.MAX_MINMAX_QUANTITY,
	 msii.MINIMUM_ORDER_QUANTITY,
	 msii.FIXED_ORDER_QUANTITY,
	 msii.FIXED_DAYS_SUPPLY,
	 msii.MAXIMUM_ORDER_QUANTITY,
	 msii.ATP_RULE_ID,
	 msii.PICKING_RULE_ID,
	 msii.RESERVABLE_TYPE,
	 msii.POSITIVE_MEASUREMENT_ERROR,
	 msii.OUTSIDE_OPERATION_FLAG,
	 msii.OUTSIDE_OPERATION_UOM_TYPE,
	 msii.SAFETY_STOCK_BUCKET_DAYS,
	 msii.AUTO_REDUCE_MPS,
	 msii.COSTING_ENABLED_FLAG,
	 msii.AUTO_CREATED_CONFIG_FLAG,
	 msii.CYCLE_COUNT_ENABLED_FLAG,
	 msii.ITEM_TYPE,
	 msii.MODEL_CONFIG_CLAUSE_NAME,
	 msii.SHIP_MODEL_COMPLETE_FLAG,
	 msii.MRP_PLANNING_CODE,
	 msii.RETURN_INSPECTION_REQUIREMENT,
	 msii.ATO_FORECAST_CONTROL
--Added as part of 11.5.9 ENH
 	,msii.LOT_SUBSTITUTION_ENABLED
	,msii.MINIMUM_LICENSE_QUANTITY
	,msii.EAM_ACTIVITY_SOURCE_CODE
	,msii.IB_ITEM_INSTANCE_CLASS
	,msii.CONFIG_MODEL_TYPE
	--Added as part of R12 Enh
        ,msii.OUTSOURCED_ASSEMBLY
	,msii.CHARGE_PERIODICITY_CODE
	,msii.SUBCONTRACTING_COMPONENT
	,msii.REPAIR_LEADTIME
	,msii.REPAIR_PROGRAM
	,msii.REPAIR_YIELD
	,msii.PREPOSITION_POINT
	from MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
	where ((msii.organization_id = org_id) or
	       (all_Org = 1))
	and   msii.process_flag = 2
	and   msii.organization_id = mp.organization_id
        and   msii.set_process_id = xset_id
	and   msii.organization_id <> mp.master_organization_id;

	/*
	** Attributes that are Item level (can't be different from master org's value)
	*/

        CURSOR ee is
        select attribute_name,
	       control_level
        from MTL_ITEM_ATTRIBUTES
        where control_level = 1;

	msicount		number;
	msiicount		number;
	l_item_id		number;
	l_org_id		number;
	trans_id		number;
	ext_flag		number := 0;
	error_msg		varchar2(70);
	status			number;
	dumm_status		number;
	master_org_id		number;
	LOGGING_ERR		exception;
	VALIDATE_ERR		exception;
	X_TRUE			number := 1;
 	 A_START_AUTO_LOT_NUMBER	number := 2;
	 A_LOT_CONTROL_CODE		number := 2;
	 A_SHELF_LIFE_CODE		number := 2;
	 A_SHELF_LIFE_DAYS		number := 2;
	 A_SERIAL_NUMBER_CONTROL_CODE	number := 2;
	 A_START_AUTO_SERIAL_NUMBER	number := 2;
	 A_AUTO_SERIAL_ALPHA_PREFIX	number := 2;
	 A_SOURCE_TYPE			number := 2;
	 A_SOURCE_ORGANIZATION_ID	number := 2;
	 A_SOURCE_SUBINVENTORY		number := 2;
	 A_EXPENSE_ACCOUNT		number := 2;
	 A_ENCUMBRANCE_ACCOUNT		number := 2;
	 A_RESTRICT_SUBINVENTORIES_CODE	number := 2;
	 A_UNIT_WEIGHT			number := 2;
	 A_WEIGHT_UOM_CODE		number := 2;
	 A_VOLUME_UOM_CODE		number := 2;
	 A_UNIT_VOLUME			number := 2;
	 A_RESTRICT_LOCATORS_CODE	number := 2;
	 A_LOCATION_CONTROL_CODE	number := 2;
	 A_SHRINKAGE_RATE		number := 2;
	 A_ACCEPTABLE_EARLY_DAYS	number := 2;
	 A_PLANNING_TIME_FENCE_CODE	number := 2;
	 A_DEMAND_TIME_FENCE_CODE	number := 2;
	 A_LEAD_TIME_LOT_SIZE		number := 2;
	 A_STD_LOT_SIZE			number := 2;
	 A_CUM_MANUFACTURING_LEAD_TIME	number := 2;
	 A_OVERRUN_PERCENTAGE		number := 2;
	 A_MRP_CALCULATE_ATP_FLAG	number := 2;
	 A_ACCEPTABLE_RATE_INCREASE	number := 2;
	 A_ACCEPTABLE_RATE_DECREASE	number := 2;
 	 A_CUMULATIVE_TOTAL_LEAD_TIME	number := 2;
	 A_PLANNING_TIME_FENCE_DAYS	number := 2;
	 A_DEMAND_TIME_FENCE_DAYS	number := 2;
	 A_END_ASSEMBLY_PEGGING_FLAG	number := 2;
	 A_REPETITIVE_PLANNING_FLAG	number := 2;
	 A_PLANNING_EXCEPTION_SET	number := 2;
	 A_BOM_ITEM_TYPE		number := 2;
	 A_PICK_COMPONENTS_FLAG		number := 2;
	 A_REPLENISH_TO_ORDER_FLAG	number := 2;
	 A_BASE_ITEM_ID			number := 2;
	 A_ATP_COMPONENTS_FLAG		number := 2;
	 A_ATP_FLAG			number := 2;
	 A_FIXED_LEAD_TIME		number := 2;
	 A_VARIABLE_LEAD_TIME		number := 2;
	 A_WIP_SUPPLY_LOCATOR_ID	number := 2;
	 A_WIP_SUPPLY_TYPE		number := 2;
	 A_WIP_SUPPLY_SUBINVENTORY	number := 2;
	 A_PRIMARY_UOM_CODE		number := 2;
	-- A_PRIMARY_UNIT_OF_MEASURE	number := 2;
	 A_ALLOWED_UNITS_LOOKUP_CODE	number := 2;
	 A_COST_OF_SALES_ACCOUNT	number := 2;
	 A_SALES_ACCOUNT		number := 2;
	 A_DEFAULT_INCLUDE_IN_ROLLUP_F	number := 2;
	 A_INVENTORY_ITEM_STATUS_CODE	number := 2;
	 A_INVENTORY_PLANNING_CODE	number := 2;
	 A_PLANNER_CODE			number := 2;
	 A_PLANNING_MAKE_BUY_CODE	number := 2;
	 A_FIXED_LOT_MULTIPLIER		number := 2;
	 A_ROUNDING_CONTROL_TYPE	number := 2;
	 A_CARRYING_COST		number := 2;
 	 A_POSTPROCESSING_LEAD_TIME	number := 2;
	 A_PREPROCESSING_LEAD_TIME	number := 2;
	 A_FULL_LEAD_TIME		number := 2;
	 A_ORDER_COST			number := 2;
	 A_MRP_SAFETY_STOCK_PERCENT	number := 2;
	 A_MRP_SAFETY_STOCK_CODE	number := 2;
	 A_MIN_MINMAX_QUANTITY		number := 2;
	 A_MAX_MINMAX_QUANTITY		number := 2;
	 A_MINIMUM_ORDER_QUANTITY	number := 2;
	 A_FIXED_ORDER_QUANTITY		number := 2;
	 A_FIXED_DAYS_SUPPLY		number := 2;
	 A_MAXIMUM_ORDER_QUANTITY	number := 2;
	 A_ATP_RULE_ID			number := 2;
	 A_PICKING_RULE_ID		number := 2;
	 A_RESERVABLE_TYPE		number := 2;
	 A_POSITIVE_MEASUREMENT_ERROR	number := 2;
	 A_OUTSIDE_OPERATION_FLAG	number := 2;
	 A_OUTSIDE_OPERATION_UOM_TYPE	number := 2;
	 A_SAFETY_STOCK_BUCKET_DAYS	number := 2;
	 A_AUTO_REDUCE_MPS		number := 2;
	 A_COSTING_ENABLED_FLAG		number := 2;
	 A_AUTO_CREATED_CONFIG_FLAG	number := 2;
	 A_CYCLE_COUNT_ENABLED_FLAG	number := 2;
	 A_ITEM_TYPE			number := 2;
	 A_MODEL_CONFIG_CLAUSE_NAME	number := 2;
	 A_SHIP_MODEL_COMPLETE_FLAG	number := 2;
	 A_MRP_PLANNING_CODE		number := 2;
	 A_RETURN_INSPECTION_REQUIRE	number := 2;
	 A_ATO_FORECAST_CONTROL		number := 2;
 	 A_LOT_SUBSTITUTION_ENABLED     number := 2;
 	 A_MINIMUM_LICENSE_QUANTITY     number := 2;
	 A_EAM_ACTIVITY_SOURCE_CODE     number := 2;
	 A_IB_ITEM_INSTANCE_CLASS       number := 2;
	 A_CONFIG_MODEL_TYPE            number := 2;
	 --Added as part of R12
	 A_SUBCONTRACTING_COMPONENT     number := 2;
	 A_OUTSOURCED_ASSEMBLY          number := 2;
	 A_CHARGE_PERIODICITY_CODE      number := 2;
	 A_REPAIR_LEADTIME              number := 2;
	 A_REPAIR_PROGRAM               number := 2;
	 A_REPAIR_YIELD                 number := 2;
	 A_PREPOSITION_POINT            number := 2;

begin

/* set the attribute level variables to be used when validating a child's item
** level attributes against the master org's attribute value.  this is done
** outside the loop so that it is only done once for all the records
** instead of once PER record.
*/

	for att in ee loop
		if substr(att.attribute_name,18) = 'START_AUTO_LOT_NUMBER' then
			A_START_AUTO_LOT_NUMBER := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'LOT_CONTROL_CODE' then
			A_LOT_CONTROL_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SHELF_LIFE_CODE' then
			A_SHELF_LIFE_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SHELF_LIFE_DAYS' then
			A_SHELF_LIFE_DAYS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SERIAL_NUMBER_CONTROL_CODE' then
			A_SERIAL_NUMBER_CONTROL_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'START_AUTO_SERIAL_NUMBER' then
			A_START_AUTO_SERIAL_NUMBER := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'AUTO_SERIAL_ALPHA_PREFIX' then
			A_AUTO_SERIAL_ALPHA_PREFIX := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SOURCE_TYPE' then
			A_SOURCE_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SOURCE_ORGANIZATION_ID' then
			A_SOURCE_ORGANIZATION_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SOURCE_SUBINVENTORY' then
			A_SOURCE_SUBINVENTORY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'EXPENSE_ACCOUNT' then
			A_EXPENSE_ACCOUNT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ENCUMBRANCE_ACCOUNT' then
			A_ENCUMBRANCE_ACCOUNT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RESTRICT_SUBINVENTORIES_CODE' then
			A_RESTRICT_SUBINVENTORIES_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'UNIT_WEIGHT' then
			A_UNIT_WEIGHT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'WEIGHT_UOM_CODE' then
			A_WEIGHT_UOM_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'VOLUME_UOM_CODE' then
			A_VOLUME_UOM_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'UNIT_VOLUME' then
			A_UNIT_VOLUME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RESTRICT_LOCATORS_CODE' then
			A_RESTRICT_LOCATORS_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'LOCATION_CONTROL_CODE' then
			A_LOCATION_CONTROL_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SHRINKAGE_RATE' then
			A_SHRINKAGE_RATE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ACCEPTABLE_EARLY_DAYS' then
			A_ACCEPTABLE_EARLY_DAYS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PLANNING_TIME_FENCE_CODE' then
			A_PLANNING_TIME_FENCE_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DEMAND_TIME_FENCE_CODE' then
			A_DEMAND_TIME_FENCE_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'LEAD_TIME_LOT_SIZE' then
			A_LEAD_TIME_LOT_SIZE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'STD_LOT_SIZE' then
			A_STD_LOT_SIZE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CUM_MANUFACTURING_LEAD_TIME' then
			A_CUM_MANUFACTURING_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'OVERRUN_PERCENTAGE' then
			A_OVERRUN_PERCENTAGE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MRP_CALCULATE_ATP_FLAG' then
			A_MRP_CALCULATE_ATP_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ACCEPTABLE_RATE_INCREASE' then
			A_ACCEPTABLE_RATE_INCREASE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ACCEPTABLE_RATE_DECREASE' then
			A_ACCEPTABLE_RATE_DECREASE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CUMULATIVE_TOTAL_LEAD_TIME' then
			A_CUMULATIVE_TOTAL_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PLANNING_TIME_FENCE_DAYS' then
			A_PLANNING_TIME_FENCE_DAYS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DEMAND_TIME_FENCE_DAYS' then
			A_DEMAND_TIME_FENCE_DAYS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'END_ASSEMBLY_PEGGING_FLAG' then
			A_END_ASSEMBLY_PEGGING_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REPETITIVE_PLANNING_FLAG' then
			A_REPETITIVE_PLANNING_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PLANNING_EXCEPTION_SET' then
			A_PLANNING_EXCEPTION_SET := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BOM_ITEM_TYPE' then
			A_BOM_ITEM_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PICK_COMPONENTS_FLAG' then
			A_PICK_COMPONENTS_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REPLENISH_TO_ORDER_FLAG' then
			A_REPLENISH_TO_ORDER_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BASE_ITEM_ID' then
			A_BASE_ITEM_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ATP_COMPONENTS_FLAG' then
			A_ATP_COMPONENTS_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ATP_FLAG' then
			A_ATP_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'FIXED_LEAD_TIME' then
			A_FIXED_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'VARIABLE_LEAD_TIME' then
			A_VARIABLE_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'WIP_SUPPLY_LOCATOR_ID' then
			A_WIP_SUPPLY_LOCATOR_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'WIP_SUPPLY_TYPE' then
			A_WIP_SUPPLY_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'WIP_SUPPLY_SUBINVENTORY' then
			A_WIP_SUPPLY_SUBINVENTORY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PRIMARY_UOM_CODE' then
			A_PRIMARY_UOM_CODE := att.control_level;
		end if;
/*
		if substr(att.attribute_name,18) = 'PRIMARY_UNIT_OF_MEASURE' then
			A_PRIMARY_UNIT_OF_MEASURE := att.control_level;
		end if;
*/
		if substr(att.attribute_name,18) = 'ALLOWED_UNITS_LOOKUP_CODE' then
			A_ALLOWED_UNITS_LOOKUP_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'COST_OF_SALES_ACCOUNT' then
			A_COST_OF_SALES_ACCOUNT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SALES_ACCOUNT' then
			A_SALES_ACCOUNT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DEFAULT_INCLUDE_IN_ROLLUP_FLAG' then
			A_DEFAULT_INCLUDE_IN_ROLLUP_F := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVENTORY_ITEM_STATUS_CODE' then
			A_INVENTORY_ITEM_STATUS_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVENTORY_PLANNING_CODE' then
			A_INVENTORY_PLANNING_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PLANNER_CODE' then
			A_PLANNER_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PLANNING_MAKE_BUY_CODE' then
			A_PLANNING_MAKE_BUY_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'FIXED_LOT_MULTIPLIER' then
			A_FIXED_LOT_MULTIPLIER := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ROUNDING_CONTROL_TYPE' then
			A_ROUNDING_CONTROL_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CARRYING_COST' then
			A_CARRYING_COST := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'POSTPROCESSING_LEAD_TIME' then
			A_POSTPROCESSING_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PREPROCESSING_LEAD_TIME' then
			A_PREPROCESSING_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'FULL_LEAD_TIME' then
			A_FULL_LEAD_TIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ORDER_COST' then
			A_ORDER_COST := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MRP_SAFETY_STOCK_PERCENT' then
			A_MRP_SAFETY_STOCK_PERCENT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MRP_SAFETY_STOCK_CODE' then
			A_MRP_SAFETY_STOCK_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MIN_MINMAX_QUANTITY' then
			A_MIN_MINMAX_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MAX_MINMAX_QUANTITY' then
			A_MAX_MINMAX_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MINIMUM_ORDER_QUANTITY' then
			A_MINIMUM_ORDER_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'FIXED_ORDER_QUANTITY' then
			A_FIXED_ORDER_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'FIXED_DAYS_SUPPLY' then
			A_FIXED_DAYS_SUPPLY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MAXIMUM_ORDER_QUANTITY' then
			A_MAXIMUM_ORDER_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ATP_RULE_ID' then
			A_ATP_RULE_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PICKING_RULE_ID' then
			A_PICKING_RULE_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RESERVABLE_TYPE' then
			A_RESERVABLE_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'POSITIVE_MEASUREMENT_ERROR' then
			A_POSITIVE_MEASUREMENT_ERROR := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'OUTSIDE_OPERATION_FLAG' then
			A_OUTSIDE_OPERATION_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'OUTSIDE_OPERATION_UOM_TYPE' then
			A_OUTSIDE_OPERATION_UOM_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SAFETY_STOCK_BUCKET_DAYS' then
			A_SAFETY_STOCK_BUCKET_DAYS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'AUTO_REDUCE_MPS' then
			A_AUTO_REDUCE_MPS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'COSTING_ENABLED_FLAG' then
			A_COSTING_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'AUTO_CREATED_CONFIG_FLAG' then
			A_AUTO_CREATED_CONFIG_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CYCLE_COUNT_ENABLED_FLAG' then
			A_CYCLE_COUNT_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ITEM_TYPE' then
			A_ITEM_TYPE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MODEL_CONFIG_CLAUSE_NAME' then
			A_MODEL_CONFIG_CLAUSE_NAME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SHIP_MODEL_COMPLETE_FLAG' then
			A_SHIP_MODEL_COMPLETE_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MRP_PLANNING_CODE' then
			A_MRP_PLANNING_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RETURN_INSPECTION_REQUIREMENT' then
			A_RETURN_INSPECTION_REQUIRE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ATO_FORECAST_CONTROL' then
			A_ATO_FORECAST_CONTROL := att.control_level;
		end if;
--Added as part of 11.5.9
		if substr(att.attribute_name,18) = 'LOT_SUBSTITUTION_ENABLED' then
			 A_LOT_SUBSTITUTION_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MINIMUM_LICENSE_QUANTITY' then
			 A_MINIMUM_LICENSE_QUANTITY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'EAM_ACTIVITY_SOURCE_CODE' then
			 A_EAM_ACTIVITY_SOURCE_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'IB_ITEM_INSTANCE_CLASS' then
			 A_IB_ITEM_INSTANCE_CLASS := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CONFIG_MODEL_TYPE' then
			 A_CONFIG_MODEL_TYPE := att.control_level;
		end if;
--Added as part of R12 Enh.
		if substr(att.attribute_name,18) = 'OUTSOURCED_ASSEMBLY' then
			 A_OUTSOURCED_ASSEMBLY := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SUBCONTRACTING_COMPONENT' then
			 A_SUBCONTRACTING_COMPONENT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CHARGE_PERIODICITY_CODE' then
			 A_CHARGE_PERIODICITY_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REPAIR_LEADTIME' then
			 A_REPAIR_LEADTIME := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REPAIR_PROGRAM' then
			 A_REPAIR_PROGRAM := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REPAIR_YIELD' then
			 A_REPAIR_YIELD := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PREPOSITION_POINT' then
			 A_PREPOSITION_POINT := att.control_level;
		end if;
	end loop;
/*
** validate the records
*/
	for cr in cc loop
		status := 0;
		trans_id := cr.transaction_id;
		l_org_id := cr.ORGID;

		begin /* MASTER_CHILD_4A */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_START_AUTO_LOT_NUMBER,X_TRUE,nvl(cr.START_AUTO_LOT_NUMBER,-1),nvl(msi.START_AUTO_LOT_NUMBER,-1))=nvl(msi.START_AUTO_LOT_NUMBER,-1)
 			and decode(A_LOT_CONTROL_CODE,X_TRUE,nvl(cr.LOT_CONTROL_CODE,-1),nvl(msi.LOT_CONTROL_CODE,-1))=nvl(msi.LOT_CONTROL_CODE,-1)
 			and decode(A_SHELF_LIFE_CODE,X_TRUE,nvl(cr.SHELF_LIFE_CODE,-1),nvl(msi.SHELF_LIFE_CODE,-1))=nvl(msi.SHELF_LIFE_CODE,-1)
 			and decode(A_SHELF_LIFE_DAYS,X_TRUE,nvl(cr.SHELF_LIFE_DAYS,-1),nvl(msi.SHELF_LIFE_DAYS,-1))=nvl(msi.SHELF_LIFE_DAYS,-1)
 			and decode(A_SERIAL_NUMBER_CONTROL_CODE,X_TRUE,nvl(cr.SERIAL_NUMBER_CONTROL_CODE,-1),nvl(msi.SERIAL_NUMBER_CONTROL_CODE,-1))=nvl(msi.SERIAL_NUMBER_CONTROL_CODE,-1)
 			and decode(A_START_AUTO_SERIAL_NUMBER,X_TRUE,nvl(cr.START_AUTO_SERIAL_NUMBER,-1),nvl(msi.START_AUTO_SERIAL_NUMBER,-1))=nvl(msi.START_AUTO_SERIAL_NUMBER,-1)
 			and decode(A_AUTO_SERIAL_ALPHA_PREFIX,X_TRUE,nvl(cr.AUTO_SERIAL_ALPHA_PREFIX,-1),nvl(msi.AUTO_SERIAL_ALPHA_PREFIX,-1))=nvl(msi.AUTO_SERIAL_ALPHA_PREFIX,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4A',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4A',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4A */


		begin /* MASTER_CHILD_4B */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_SOURCE_TYPE,X_TRUE,nvl(cr.SOURCE_TYPE,-1),nvl(msi.SOURCE_TYPE,-1))=nvl(msi.SOURCE_TYPE,-1)
 			and decode(A_SOURCE_ORGANIZATION_ID,X_TRUE,nvl(cr.SOURCE_ORGANIZATION_ID,-1),nvl(msi.SOURCE_ORGANIZATION_ID,-1))=nvl(msi.SOURCE_ORGANIZATION_ID,-1)
 			and decode(A_SOURCE_SUBINVENTORY,X_TRUE,nvl(cr.SOURCE_SUBINVENTORY,-1),nvl(msi.SOURCE_SUBINVENTORY,-1))=nvl(msi.SOURCE_SUBINVENTORY,-1)
 			and decode(A_EXPENSE_ACCOUNT,X_TRUE,nvl(cr.EXPENSE_ACCOUNT,-1),nvl(msi.EXPENSE_ACCOUNT,-1))=nvl(msi.EXPENSE_ACCOUNT,-1)
 			and decode(A_ENCUMBRANCE_ACCOUNT,X_TRUE,nvl(cr.ENCUMBRANCE_ACCOUNT,-1),nvl(msi.ENCUMBRANCE_ACCOUNT,-1))=nvl(msi.ENCUMBRANCE_ACCOUNT,-1)
 			and decode(A_RESTRICT_SUBINVENTORIES_CODE,X_TRUE,nvl(cr.RESTRICT_SUBINVENTORIES_CODE,-1),nvl(msi.RESTRICT_SUBINVENTORIES_CODE,-1))=nvl(msi.RESTRICT_SUBINVENTORIES_CODE,-1)
 			and decode(A_UNIT_WEIGHT,X_TRUE,nvl(cr.UNIT_WEIGHT,-1),nvl(msi.UNIT_WEIGHT,-1))=nvl(msi.UNIT_WEIGHT,-1)
 			and decode(A_WEIGHT_UOM_CODE,X_TRUE,nvl(cr.WEIGHT_UOM_CODE,-1),nvl(msi.WEIGHT_UOM_CODE,-1))=nvl(msi.WEIGHT_UOM_CODE,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4B',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4B',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4B */


		begin /* MASTER_CHILD_4C */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_VOLUME_UOM_CODE,X_TRUE,nvl(cr.VOLUME_UOM_CODE,-1),nvl(msi.VOLUME_UOM_CODE,-1))=nvl(msi.VOLUME_UOM_CODE,-1)
 			and decode(A_UNIT_VOLUME,X_TRUE,nvl(cr.UNIT_VOLUME,-1),nvl(msi.UNIT_VOLUME,-1))=nvl(msi.UNIT_VOLUME,-1)
 			and decode(A_RESTRICT_LOCATORS_CODE,X_TRUE,nvl(cr.RESTRICT_LOCATORS_CODE,-1),nvl(msi.RESTRICT_LOCATORS_CODE,-1))=nvl(msi.RESTRICT_LOCATORS_CODE,-1)
 			and decode(A_LOCATION_CONTROL_CODE,X_TRUE,nvl(cr.LOCATION_CONTROL_CODE,-1),nvl(msi.LOCATION_CONTROL_CODE,-1))=nvl(msi.LOCATION_CONTROL_CODE,-1)
 			and decode(A_SHRINKAGE_RATE,X_TRUE,nvl(cr.SHRINKAGE_RATE,-1),nvl(msi.SHRINKAGE_RATE,-1))=nvl(msi.SHRINKAGE_RATE,-1)
 			and decode(A_ACCEPTABLE_EARLY_DAYS,X_TRUE,nvl(cr.ACCEPTABLE_EARLY_DAYS,-1),nvl(msi.ACCEPTABLE_EARLY_DAYS,-1))=nvl(msi.ACCEPTABLE_EARLY_DAYS,-1)
 			and decode(A_PLANNING_TIME_FENCE_CODE,X_TRUE,nvl(cr.PLANNING_TIME_FENCE_CODE,-1),nvl(msi.PLANNING_TIME_FENCE_CODE,-1))=nvl(msi.PLANNING_TIME_FENCE_CODE,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4C',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4C',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4C */


		begin /* MASTER_CHILD_4D */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_DEMAND_TIME_FENCE_CODE,X_TRUE,nvl(cr.DEMAND_TIME_FENCE_CODE,-1),nvl(msi.DEMAND_TIME_FENCE_CODE,-1))=nvl(msi.DEMAND_TIME_FENCE_CODE,-1)
 			and decode(A_LEAD_TIME_LOT_SIZE,X_TRUE,nvl(cr.LEAD_TIME_LOT_SIZE,-1),nvl(msi.LEAD_TIME_LOT_SIZE,-1))=nvl(msi.LEAD_TIME_LOT_SIZE,-1)
 			and decode(A_STD_LOT_SIZE,X_TRUE,nvl(cr.STD_LOT_SIZE,-1),nvl(msi.STD_LOT_SIZE,-1))=nvl(msi.STD_LOT_SIZE,-1)
 			and decode(A_CUM_MANUFACTURING_LEAD_TIME,X_TRUE,nvl(cr.CUM_MANUFACTURING_LEAD_TIME,-1),nvl(msi.CUM_MANUFACTURING_LEAD_TIME,-1))=nvl(msi.CUM_MANUFACTURING_LEAD_TIME,-1)
 			and decode(A_OVERRUN_PERCENTAGE,X_TRUE,nvl(cr.OVERRUN_PERCENTAGE,-1),nvl(msi.OVERRUN_PERCENTAGE,-1))=nvl(msi.OVERRUN_PERCENTAGE,-1)
 			and decode(A_MRP_CALCULATE_ATP_FLAG,X_TRUE,nvl(cr.MRP_CALCULATE_ATP_FLAG,-1),nvl(msi.MRP_CALCULATE_ATP_FLAG,-1))=nvl(msi.MRP_CALCULATE_ATP_FLAG,-1)
 			and decode(A_ACCEPTABLE_RATE_INCREASE,X_TRUE,nvl(cr.ACCEPTABLE_RATE_INCREASE,-1),nvl(msi.ACCEPTABLE_RATE_INCREASE,-1))=nvl(msi.ACCEPTABLE_RATE_INCREASE,-1)
 			and decode(A_ACCEPTABLE_RATE_DECREASE,X_TRUE,nvl(cr.ACCEPTABLE_RATE_DECREASE,-1),nvl(msi.ACCEPTABLE_RATE_DECREASE,-1))=nvl(msi.ACCEPTABLE_RATE_DECREASE,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4D',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4D',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4D */


		begin /* MASTER_CHILD_4E */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_CUMULATIVE_TOTAL_LEAD_TIME,X_TRUE,nvl(cr.CUMULATIVE_TOTAL_LEAD_TIME,-1),nvl(msi.CUMULATIVE_TOTAL_LEAD_TIME,-1))=nvl(msi.CUMULATIVE_TOTAL_LEAD_TIME,-1)
 			and decode(A_PLANNING_TIME_FENCE_DAYS,X_TRUE,nvl(cr.PLANNING_TIME_FENCE_DAYS,-1),nvl(msi.PLANNING_TIME_FENCE_DAYS,-1))=nvl(msi.PLANNING_TIME_FENCE_DAYS,-1)
 			and decode(A_DEMAND_TIME_FENCE_DAYS,X_TRUE,nvl(cr.DEMAND_TIME_FENCE_DAYS,-1),nvl(msi.DEMAND_TIME_FENCE_DAYS,-1))=nvl(msi.DEMAND_TIME_FENCE_DAYS,-1)
 			and decode(A_END_ASSEMBLY_PEGGING_FLAG,X_TRUE,nvl(cr.END_ASSEMBLY_PEGGING_FLAG,-1),nvl(msi.END_ASSEMBLY_PEGGING_FLAG,-1))=nvl(msi.END_ASSEMBLY_PEGGING_FLAG,-1)
 			and decode(A_REPETITIVE_PLANNING_FLAG,X_TRUE,nvl(cr.REPETITIVE_PLANNING_FLAG,-1),nvl(msi.REPETITIVE_PLANNING_FLAG,-1))=nvl(msi.REPETITIVE_PLANNING_FLAG,-1)
 			and decode(A_PLANNING_EXCEPTION_SET,X_TRUE,nvl(cr.PLANNING_EXCEPTION_SET,-1),nvl(msi.PLANNING_EXCEPTION_SET,-1))=nvl(msi.PLANNING_EXCEPTION_SET,-1)
 			and decode(A_BOM_ITEM_TYPE,X_TRUE,nvl(cr.BOM_ITEM_TYPE,-1),nvl(msi.BOM_ITEM_TYPE,-1))=nvl(msi.BOM_ITEM_TYPE,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4E',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4E',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4E */


		begin /* MASTER_CHILD_4F */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_PICK_COMPONENTS_FLAG,X_TRUE,nvl(cr.PICK_COMPONENTS_FLAG,-1),nvl(msi.PICK_COMPONENTS_FLAG,-1))=nvl(msi.PICK_COMPONENTS_FLAG,-1)
 			and decode(A_REPLENISH_TO_ORDER_FLAG,X_TRUE,nvl(cr.REPLENISH_TO_ORDER_FLAG,-1),nvl(msi.REPLENISH_TO_ORDER_FLAG,-1))=nvl(msi.REPLENISH_TO_ORDER_FLAG,-1)
 			and decode(A_BASE_ITEM_ID,X_TRUE,nvl(cr.BASE_ITEM_ID,-1),nvl(msi.BASE_ITEM_ID,-1))=nvl(msi.BASE_ITEM_ID,-1)
 			and decode(A_ATP_COMPONENTS_FLAG,X_TRUE,nvl(cr.ATP_COMPONENTS_FLAG,-1),nvl(msi.ATP_COMPONENTS_FLAG,-1))=nvl(msi.ATP_COMPONENTS_FLAG,-1)
 			and decode(A_ATP_FLAG,X_TRUE,nvl(cr.ATP_FLAG,-1),nvl(msi.ATP_FLAG,-1))=nvl(msi.ATP_FLAG,-1)
 			and decode(A_FIXED_LEAD_TIME,X_TRUE,nvl(cr.FIXED_LEAD_TIME,-1),nvl(msi.FIXED_LEAD_TIME,-1))=nvl(msi.FIXED_LEAD_TIME,-1)
 			and decode(A_VARIABLE_LEAD_TIME,X_TRUE,nvl(cr.VARIABLE_LEAD_TIME,-1),nvl(msi.VARIABLE_LEAD_TIME,-1))=nvl(msi.VARIABLE_LEAD_TIME,-1)
 			and decode(A_WIP_SUPPLY_LOCATOR_ID,X_TRUE,nvl(cr.WIP_SUPPLY_LOCATOR_ID,-1),nvl(msi.WIP_SUPPLY_LOCATOR_ID,-1))=nvl(msi.WIP_SUPPLY_LOCATOR_ID,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4F',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4F',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4F */


		begin /* MASTER_CHILD_4G */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_WIP_SUPPLY_TYPE,X_TRUE,nvl(cr.WIP_SUPPLY_TYPE,-1),nvl(msi.WIP_SUPPLY_TYPE,-1))=nvl(msi.WIP_SUPPLY_TYPE,-1)
 			and decode(A_WIP_SUPPLY_SUBINVENTORY,X_TRUE,nvl(cr.WIP_SUPPLY_SUBINVENTORY,-1),nvl(msi.WIP_SUPPLY_SUBINVENTORY,-1))=nvl(msi.WIP_SUPPLY_SUBINVENTORY,-1)
 			and decode(A_PRIMARY_UOM_CODE,X_TRUE,nvl(cr.PRIMARY_UOM_CODE,-1),nvl(msi.PRIMARY_UOM_CODE,-1))=nvl(msi.PRIMARY_UOM_CODE,-1)
/*
 			and decode(A_PRIMARY_UNIT_OF_MEASURE,X_TRUE,nvl(cr.PRIMARY_UNIT_OF_MEASURE,-1),nvl(msi.PRIMARY_UNIT_OF_MEASURE,-1))=nvl(msi.PRIMARY_UNIT_OF_MEASURE,-1)
*/
 			and decode(A_ALLOWED_UNITS_LOOKUP_CODE,X_TRUE,nvl(cr.ALLOWED_UNITS_LOOKUP_CODE,-1),nvl(msi.ALLOWED_UNITS_LOOKUP_CODE,-1))=nvl(msi.ALLOWED_UNITS_LOOKUP_CODE,-1)
 			and decode(A_COST_OF_SALES_ACCOUNT,X_TRUE,nvl(cr.COST_OF_SALES_ACCOUNT,-1),nvl(msi.COST_OF_SALES_ACCOUNT,-1))=nvl(msi.COST_OF_SALES_ACCOUNT,-1)
 			and decode(A_SALES_ACCOUNT,X_TRUE,nvl(cr.SALES_ACCOUNT,-1),nvl(msi.SALES_ACCOUNT,-1))=nvl(msi.SALES_ACCOUNT,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4G',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4G',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4G */


		begin /* MASTER_CHILD_4H */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_DEFAULT_INCLUDE_IN_ROLLUP_F,X_TRUE,nvl(cr.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,-1),nvl(msi.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,-1))=nvl(msi.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,-1)
 			and decode(A_INVENTORY_ITEM_STATUS_CODE,X_TRUE,nvl(cr.INVENTORY_ITEM_STATUS_CODE,-1),nvl(msi.INVENTORY_ITEM_STATUS_CODE,-1))=nvl(msi.INVENTORY_ITEM_STATUS_CODE,-1)
 			and decode(A_INVENTORY_PLANNING_CODE,X_TRUE,nvl(cr.INVENTORY_PLANNING_CODE,-1),nvl(msi.INVENTORY_PLANNING_CODE,-1))=nvl(msi.INVENTORY_PLANNING_CODE,-1)
 			and decode(A_PLANNER_CODE,X_TRUE,nvl(cr.PLANNER_CODE,-1),nvl(msi.PLANNER_CODE,-1))=nvl(msi.PLANNER_CODE,-1)
 			and decode(A_PLANNING_MAKE_BUY_CODE,X_TRUE,nvl(cr.PLANNING_MAKE_BUY_CODE,-1),nvl(msi.PLANNING_MAKE_BUY_CODE,-1))=nvl(msi.PLANNING_MAKE_BUY_CODE,-1)
 			and decode(A_FIXED_LOT_MULTIPLIER,X_TRUE,nvl(cr.FIXED_LOT_MULTIPLIER,-1),nvl(msi.FIXED_LOT_MULTIPLIER,-1))=nvl(msi.FIXED_LOT_MULTIPLIER,-1)
 			and decode(A_ROUNDING_CONTROL_TYPE,X_TRUE,nvl(cr.ROUNDING_CONTROL_TYPE,-1),nvl(msi.ROUNDING_CONTROL_TYPE,-1))=nvl(msi.ROUNDING_CONTROL_TYPE,-1)
 			and decode(A_CARRYING_COST,X_TRUE,nvl(cr.CARRYING_COST,-1),nvl(msi.CARRYING_COST,-1))=nvl(msi.CARRYING_COST,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4H',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4H',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4H */



		begin /* MASTER_CHILD_4I */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_POSTPROCESSING_LEAD_TIME,X_TRUE,nvl(cr.POSTPROCESSING_LEAD_TIME,-1),nvl(msi.POSTPROCESSING_LEAD_TIME,-1))=nvl(msi.POSTPROCESSING_LEAD_TIME,-1)
 			and decode(A_PREPROCESSING_LEAD_TIME,X_TRUE,nvl(cr.PREPROCESSING_LEAD_TIME,-1),nvl(msi.PREPROCESSING_LEAD_TIME,-1))=nvl(msi.PREPROCESSING_LEAD_TIME,-1)
 			and decode(A_FULL_LEAD_TIME,X_TRUE,nvl(cr.FULL_LEAD_TIME,-1),nvl(msi.FULL_LEAD_TIME,-1))=nvl(msi.FULL_LEAD_TIME,-1)
 			and decode(A_ORDER_COST,X_TRUE,nvl(cr.ORDER_COST,-1),nvl(msi.ORDER_COST,-1))=nvl(msi.ORDER_COST,-1)
 			and decode(A_MRP_SAFETY_STOCK_PERCENT,X_TRUE,nvl(cr.MRP_SAFETY_STOCK_PERCENT,-1),nvl(msi.MRP_SAFETY_STOCK_PERCENT,-1))=nvl(msi.MRP_SAFETY_STOCK_PERCENT,-1)
 			and decode(A_MRP_SAFETY_STOCK_CODE,X_TRUE,nvl(cr.MRP_SAFETY_STOCK_CODE,-1),nvl(msi.MRP_SAFETY_STOCK_CODE,-1))=nvl(msi.MRP_SAFETY_STOCK_CODE,-1)
 			and decode(A_MIN_MINMAX_QUANTITY,X_TRUE,nvl(cr.MIN_MINMAX_QUANTITY,-1),nvl(msi.MIN_MINMAX_QUANTITY,-1))=nvl(msi.MIN_MINMAX_QUANTITY,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4I',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4I',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4I */

		begin /* MASTER_CHILD_4J */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_MAX_MINMAX_QUANTITY,X_TRUE,nvl(cr.MAX_MINMAX_QUANTITY,-1),nvl(msi.MAX_MINMAX_QUANTITY,-1))=nvl(msi.MAX_MINMAX_QUANTITY,-1)
 			and decode(A_MINIMUM_ORDER_QUANTITY,X_TRUE,nvl(cr.MINIMUM_ORDER_QUANTITY,-1),nvl(msi.MINIMUM_ORDER_QUANTITY,-1))=nvl(msi.MINIMUM_ORDER_QUANTITY,-1)
 			and decode(A_FIXED_ORDER_QUANTITY,X_TRUE,nvl(cr.FIXED_ORDER_QUANTITY,-1),nvl(msi.FIXED_ORDER_QUANTITY,-1))=nvl(msi.FIXED_ORDER_QUANTITY,-1)
 			and decode(A_FIXED_DAYS_SUPPLY,X_TRUE,nvl(cr.FIXED_DAYS_SUPPLY,-1),nvl(msi.FIXED_DAYS_SUPPLY,-1))=nvl(msi.FIXED_DAYS_SUPPLY,-1)
 			and decode(A_MAXIMUM_ORDER_QUANTITY,X_TRUE,nvl(cr.MAXIMUM_ORDER_QUANTITY,-1),nvl(msi.MAXIMUM_ORDER_QUANTITY,-1))=nvl(msi.MAXIMUM_ORDER_QUANTITY,-1)
 			and decode(A_ATP_RULE_ID,X_TRUE,nvl(cr.ATP_RULE_ID,-1),nvl(msi.ATP_RULE_ID,-1))=nvl(msi.ATP_RULE_ID,-1)
 			and decode(A_PICKING_RULE_ID,X_TRUE,nvl(cr.PICKING_RULE_ID,-1),nvl(msi.PICKING_RULE_ID,-1))=nvl(msi.PICKING_RULE_ID,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4J',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4J',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4J */



		begin /* MASTER_CHILD_4K */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_RESERVABLE_TYPE,X_TRUE,nvl(cr.RESERVABLE_TYPE,-1),nvl(msi.RESERVABLE_TYPE,-1))=nvl(msi.RESERVABLE_TYPE,-1)
 			and decode(A_POSITIVE_MEASUREMENT_ERROR,X_TRUE,nvl(cr.POSITIVE_MEASUREMENT_ERROR,-1),nvl(msi.POSITIVE_MEASUREMENT_ERROR,-1))=nvl(msi.POSITIVE_MEASUREMENT_ERROR,-1)
 			and decode(A_OUTSIDE_OPERATION_FLAG,X_TRUE,nvl(cr.OUTSIDE_OPERATION_FLAG,-1),nvl(msi.OUTSIDE_OPERATION_FLAG,-1))=nvl(msi.OUTSIDE_OPERATION_FLAG,-1)
 			and decode(A_OUTSIDE_OPERATION_UOM_TYPE,X_TRUE,nvl(cr.OUTSIDE_OPERATION_UOM_TYPE,-1),nvl(msi.OUTSIDE_OPERATION_UOM_TYPE,-1))=nvl(msi.OUTSIDE_OPERATION_UOM_TYPE,-1)
 			and decode(A_SAFETY_STOCK_BUCKET_DAYS,X_TRUE,nvl(cr.SAFETY_STOCK_BUCKET_DAYS,-1),nvl(msi.SAFETY_STOCK_BUCKET_DAYS,-1))=nvl(msi.SAFETY_STOCK_BUCKET_DAYS,-1)
 			and decode(A_AUTO_REDUCE_MPS,X_TRUE,nvl(cr.AUTO_REDUCE_MPS,-1),nvl(msi.AUTO_REDUCE_MPS,-1))=nvl(msi.AUTO_REDUCE_MPS,-1)
 			and decode(A_COSTING_ENABLED_FLAG,X_TRUE,nvl(cr.COSTING_ENABLED_FLAG,-1),nvl(msi.COSTING_ENABLED_FLAG,-1))=nvl(msi.COSTING_ENABLED_FLAG,-1);


		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4K',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4K',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4K */

		begin /* MASTER_CHILD_4L */

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_AUTO_CREATED_CONFIG_FLAG,X_TRUE,nvl(cr.AUTO_CREATED_CONFIG_FLAG,-1),nvl(msi.AUTO_CREATED_CONFIG_FLAG,-1))=nvl(msi.AUTO_CREATED_CONFIG_FLAG,-1)
 			and decode(A_CYCLE_COUNT_ENABLED_FLAG,X_TRUE,nvl(cr.CYCLE_COUNT_ENABLED_FLAG,-1),nvl(msi.CYCLE_COUNT_ENABLED_FLAG,-1))=nvl(msi.CYCLE_COUNT_ENABLED_FLAG,-1)
 			and decode(A_ITEM_TYPE,X_TRUE,nvl(cr.ITEM_TYPE,-1),nvl(msi.ITEM_TYPE,-1))=nvl(msi.ITEM_TYPE,-1)
 			and decode(A_MODEL_CONFIG_CLAUSE_NAME,X_TRUE,nvl(cr.MODEL_CONFIG_CLAUSE_NAME,-1),nvl(msi.MODEL_CONFIG_CLAUSE_NAME,-1))=nvl(msi.MODEL_CONFIG_CLAUSE_NAME,-1)
 			and decode(A_SHIP_MODEL_COMPLETE_FLAG,X_TRUE,nvl(cr.SHIP_MODEL_COMPLETE_FLAG,-1),nvl(msi.SHIP_MODEL_COMPLETE_FLAG,-1))=nvl(msi.SHIP_MODEL_COMPLETE_FLAG,-1)
 			and decode(A_MRP_PLANNING_CODE,X_TRUE,nvl(cr.MRP_PLANNING_CODE,-1),nvl(msi.MRP_PLANNING_CODE,-1))=nvl(msi.MRP_PLANNING_CODE,-1)
 			and decode(A_RETURN_INSPECTION_REQUIRE,X_TRUE,nvl(cr.RETURN_INSPECTION_REQUIREMENT,-1),nvl(msi.RETURN_INSPECTION_REQUIREMENT,-1))=nvl(msi.RETURN_INSPECTION_REQUIREMENT,-1)
 			and decode(A_ATO_FORECAST_CONTROL,X_TRUE,nvl(cr.ATO_FORECAST_CONTROL,-1),nvl(msi.ATO_FORECAST_CONTROL,-1))=nvl(msi.ATO_FORECAST_CONTROL,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4L',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4L',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4L */
		begin /* MASTER_CHILD_4M Added as part of 11.5.9*/

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_LOT_SUBSTITUTION_ENABLED,X_TRUE,nvl(cr.LOT_SUBSTITUTION_ENABLED,-1),nvl(msi.LOT_SUBSTITUTION_ENABLED,-1))=nvl(msi.LOT_SUBSTITUTION_ENABLED,-1)
 			and decode(A_MINIMUM_LICENSE_QUANTITY,X_TRUE,nvl(cr.MINIMUM_LICENSE_QUANTITY,-1),nvl(msi.MINIMUM_LICENSE_QUANTITY,-1))=nvl(msi.MINIMUM_LICENSE_QUANTITY,-1)
 			and decode(A_EAM_ACTIVITY_SOURCE_CODE,X_TRUE,nvl(cr.EAM_ACTIVITY_SOURCE_CODE,-1),nvl(msi.EAM_ACTIVITY_SOURCE_CODE,-1))=nvl(msi.EAM_ACTIVITY_SOURCE_CODE,-1)
 			and decode(A_IB_ITEM_INSTANCE_CLASS,X_TRUE,nvl(cr.IB_ITEM_INSTANCE_CLASS,-1),nvl(msi.IB_ITEM_INSTANCE_CLASS,-1))=nvl(msi.IB_ITEM_INSTANCE_CLASS,-1)
 			and decode(A_CONFIG_MODEL_TYPE,X_TRUE,nvl(cr.CONFIG_MODEL_TYPE,-1),nvl(msi.CONFIG_MODEL_TYPE,-1))=nvl(msi.CONFIG_MODEL_TYPE,-1);
	        exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4M',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4M',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4M */
				begin /* MASTER_CHILD_4N Added as part of R12*/

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_OUTSOURCED_ASSEMBLY,X_TRUE,nvl(cr.OUTSOURCED_ASSEMBLY,-1),nvl(msi.OUTSOURCED_ASSEMBLY,-1))=nvl(msi.OUTSOURCED_ASSEMBLY,-1)
 			and decode(A_SUBCONTRACTING_COMPONENT,X_TRUE,nvl(cr.SUBCONTRACTING_COMPONENT,-1),nvl(msi.SUBCONTRACTING_COMPONENT,-1))=nvl(msi.SUBCONTRACTING_COMPONENT,-1)
 			and decode(A_CHARGE_PERIODICITY_CODE,X_TRUE,nvl(cr.CHARGE_PERIODICITY_CODE,-1),nvl(msi.CHARGE_PERIODICITY_CODE,-1))=nvl(msi.CHARGE_PERIODICITY_CODE,-1);
	        exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4M',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4N',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_4N */
		begin /* MASTER_CHILD_4O Added as part of R12*/

			select inventory_item_id into msicount
			from mtl_system_items msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_REPAIR_LEADTIME,X_TRUE,nvl(cr.REPAIR_LEADTIME,-1),nvl(msi.REPAIR_LEADTIME,-1))=nvl(msi.REPAIR_LEADTIME,-1)
 			and decode(A_REPAIR_PROGRAM,X_TRUE,nvl(cr.REPAIR_PROGRAM,-1),nvl(msi.REPAIR_PROGRAM,-1))=nvl(msi.REPAIR_PROGRAM,-1)
 			and decode(A_REPAIR_YIELD,X_TRUE,nvl(cr.REPAIR_YIELD,-1),nvl(msi.REPAIR_YIELD,-1))=nvl(msi.REPAIR_YIELD,-1)
			and decode(A_PREPOSITION_POINT,X_TRUE,nvl(cr.PREPOSITION_POINT,-1),nvl(msi.PREPOSITION_POINT,-1))=nvl(msi.PREPOSITION_POINT,-1);
	        exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_4M',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_4O',
				err_text);
                                If dumm_status < 0 Then
                                   raise LOGGING_ERR ;
                                End if ;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_40 */

	end loop;

	return(0);

exception

	when LOGGING_ERR then
		return(dumm_status);

	when VALIDATE_ERR then
		dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                trans_id,
                                err_text,
                                'MASTER_CHILD_4',
				'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);

		return(status);

	when OTHERS then

		err_text := substr('INVPVALI.validate_item_org4' || SQLERRM , 1, 240);
		return(SQLCODE);

END validate_item_org4;


END INVPVLM2;

/
