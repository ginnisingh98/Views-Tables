--------------------------------------------------------
--  DDL for Package Body INVPVDR2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR2" AS
/* $Header: INVPVD2B.pls 120.7.12010000.2 2009/08/10 23:09:16 mshirkol ship $ */

FUNCTION validate_item_header2
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
        --  Variable required for the validation for UPDATES
         loc_ctrl_code         NUMBER;
         cost_flag             VARCHAR2(1);
         inv_asset_flag        VARCHAR2(1);
         mrp_stock_code        NUMBER;
         base_item             NUMBER;
         lead_lot_size         NUMBER;
         out_op_flag           VARCHAR2(1);
         shelf_code            NUMBER;
	 temp		       VARCHAR2(2);
	 temp_uom_code	       VARCHAR2(3);
         temp_u_o_m            VARCHAR2(25);
         temp_uom_class        VARCHAR2(10);
         temp_enabled_flag     VARCHAR2(1);
	 Prof_INV_CTP  	       VARCHAR2(80);

	-- Retrieve column values for validation

	CURSOR cc is
	select
	 ROWID,
	 TRANSACTION_ID,
	 ORGANIZATION_ID,
	 TRANSACTION_TYPE,
	 PROCESS_FLAG,
	 INVENTORY_ITEM_ID,
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
	 CYCLE_COUNT_ENABLED_FLAG,
	 AUTO_CREATED_CONFIG_FLAG,
	 ITEM_TYPE,
	 MODEL_CONFIG_CLAUSE_NAME,
	 SHIP_MODEL_COMPLETE_FLAG,
	 MRP_PLANNING_CODE,
	 RETURN_INSPECTION_REQUIREMENT,
	 ATO_FORECAST_CONTROL,
         RELEASE_TIME_FENCE_CODE, /*NP 19AUG96 Eight cols added for 10.7 */
         RELEASE_TIME_FENCE_DAYS,
         CONTAINER_ITEM_FLAG,
         CONTAINER_TYPE_CODE,
         INTERNAL_VOLUME,
         MAXIMUM_LOAD_WEIGHT,
         MINIMUM_FILL_PERCENT,
         VEHICLE_ITEM_FLAG
	from MTL_SYSTEM_ITEMS_INTERFACE
	where ((organization_id = org_id) or
	       (all_Org = 1))
        and   set_process_id  = xset_id
	and   process_flag in ( 31,41);

	msicount		number;
	msiicount		number;
	resersal_flag		number;
	dup_item_id		number;
	l_item_id		number;
	l_org_id		number;
	cat_set_id		number;
	trans_id		number;
	ext_flag		number := 0;
	error_msg		varchar2(70);
	status			number;
	dumm_status		number;
	master_org_id		number;
	stmt			number;
	LOGGING_ERR		exception;
	VALIDATE_ERR		exception;
        chart_of_acc_id         number;   /*NP 30AUG94*/
        temp_proc_flag          number;

	l_org_name              HR_ALL_ORGANIZATION_UNITS_VL.name%TYPE;
        l_msg_text              fnd_new_messages.message_text%TYPE;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

begin

  -- Retrieving fnd_profile values outside the loop for perf reasons.
    Prof_INV_CTP := nvl( fnd_profile.value('INV_CTP'), 3);

	for cr in cc loop
	       status := 0;
	       trans_id := cr.transaction_id;
	       l_org_id := cr.organization_id;
               l_item_id := cr.inventory_item_id;
	       temp_proc_flag := cr.process_flag;  -- Bug 4705184

	       -- Check for the second set of integrity rules/restrictions for item attributes

               -- Validate Fixed Order Qty
               IF cr.fixed_order_quantity <= 0 THEN
                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 'Validation Error : Fixed Order Qty is <= 0 - Use a Value > 0 or Null',
                                 'FIXED_ORDER_QUANTITY',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'INV_IOI_FIXED_ORDER_QTY',
                                 err_text);
                                 if dumm_status < 0 then
                                    raise LOGGING_ERR;
                                 end if;
                  status := 1;
               END IF;

               -- Validate Fixed Days Supply
               IF cr.fixed_days_supply < 0 THEN
                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 'Validation Error : Fixed Days Supply is < 0 - Use a Value >= 0 or Null',
                                 'FIXED_DAYS_SUPPLY',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'INV_IOI_FIXED_SUP_DAYS',
                                 err_text);
                                 if dumm_status < 0 then
                                    raise LOGGING_ERR;
                                 end if;
                  status := 1;
               END IF;
               IF l_inv_debug_level IN(101, 102) THEN
	          INVPUTLI.info('INVPVDR2: Validating flags');
               END IF;
		-- validate ENCUMBRANCE_ACCOUNT
		select ENCUMBRANCE_REVERSAL_FLAG
		into resersal_flag
		from mtl_parameters
		where organization_id = cr.organization_id;

		if resersal_flag = 1 and
		   cr.ENCUMBRANCE_ACCOUNT is NULL then
                   -- fix for 3108469
		   BEGIN
		     SELECT name
		       INTO l_org_name
		       FROM hr_all_organization_units_vl
		      WHERE organization_id = cr.organization_id;
		   EXCEPTION
		     WHEN OTHERS THEN
		       l_org_name := cr.organization_id;
		   END;
		   FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_ENC_ACCT_REQ');
		   FND_MESSAGE.SET_TOKEN ('ORGANIZATION', l_org_name);
		   l_msg_text := FND_MESSAGE.GET;
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                l_msg_text,
				'ENCUMBRANCE_ACCOUNT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

stmt := 10;
		-- validate SERVICE_DURATION
		IF cr.service_duration_period_code IS NOT NULL AND
		   cr.service_duration IS NULL THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERVICE_DURATION',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SER_DURATION_MAND',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                END IF;
/* Bug 1529024 : Validation of warranty_vendor_id is not required
		if cr.vendor_warranty_flag = 'Y' and
		   cr.WARRANTY_VENDOR_ID is NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'WARRANTY_VENDOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_WARRANTY_VEND_ID',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
*/
		-- validate INSPECTION_REQUIRED_FLAG
		if cr.INSPECTION_REQUIRED_FLAG = 'Y' and
		   (cr.RECEIVING_ROUTING_ID <> 2 or
		    cr.RECEIVING_ROUTING_ID is NULL)then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INSPECTION_REQUIRED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INSPECTION_FLAG_ERR',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate RESPONSE_TIME_VALUE
		if cr.response_time_period_code is not null and
		   cr.RESPONSE_TIME_VALUE is NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RESPONSE_TIME_VALUE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RESP_TIME_VAL',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate DEMAND_TIME_FENCE_DAYS
		if cr.demand_time_fence_code = 4 and
 		   nvl(cr.DEMAND_TIME_FENCE_DAYS,-9) < 0 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEMAND_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DEMAND_DAYS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate DEMAND_TIME_FENCE_DAYS
	        -- Bug 4485018 - Adding a clause to check for DEMAND_TIME_FENCE_CODE with null value

		if ((cr.demand_time_fence_code <> 4 or cr.demand_time_fence_code is null) and
		    (cr.DEMAND_TIME_FENCE_DAYS is NOT NULL)) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEMAND_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_DEMAND_TM_FENCE_DAYS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate PLANNING_TIME_FENCE_DAYS
		if cr.planning_time_fence_code = 4 and
 		   nvl(cr.PLANNING_TIME_FENCE_DAYS,-9) < 0 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PLANNING_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_PLANNING_DAYS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate PLANNING_TIME_FENCE_DAYS
		if cr.planning_time_fence_code <> 4 and
		   cr.PLANNING_TIME_FENCE_DAYS is NOT NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PLANNING_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PLANNING_TM_FENCE_DAYS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate RESTRICT_LOCATORS_CODE
		if cr.location_control_code = 3 and
		   cr.RESTRICT_LOCATORS_CODE <> 2 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'location_control_code',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DYNAMIC_LOCATORS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
			end if;

		-- validate RESTRICT_LOCATORS_CODE
                /*NP 22-JUL-96
                **   RESTRICT_LOCATORS_CODE = 2 related
                **   incorrect validation taken out: see bug 383278
                */
		if cr.RESTRICT_LOCATORS_CODE = 1 then
			if cr.RESTRICT_SUBINVENTORIES_CODE <> 1 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RESTRICT_LOCATORS_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_LOC_NOT_RESTRICT',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end if;
			if (cr.LOCATION_CONTROL_CODE <> 1 and
			    cr.LOCATION_CONTROL_CODE <> 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RESTRICT_LOCATORS_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DYNAMIC_LOCATORS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end if;
                end if;

		-- validate EXPENSE_ACCOUNT
		if cr.inventory_asset_flag = 'N' and
		   cr.inventory_item_flag = 'Y' and
		   cr.EXPENSE_ACCOUNT is NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'EXPENSE_ACCOUNT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_EXP_ACCT_REQ', -- fix for BUG 3069139
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

          --  validate inventory_asset_flag

		if cr.costing_enabled_flag = 'N' and
                   cr.inventory_asset_flag = 'Y'
		    then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ASSET_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_COST_ASSET',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate POSTPROCESSING_LEAD_TIME
		if (cr.POSTPROCESSING_LEAD_TIME > 0 or
		    cr.POSTPROCESSING_LEAD_TIME < 0) and
		   cr.PLANNING_MAKE_BUY_CODE = 1 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'POSTPROCESSING_LEADTIME',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_POST_PROC_LEAD_TIME',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate LEAD_TIME_LOT_SIZE
		if (cr.LEAD_TIME_LOT_SIZE > 1 or
		    cr.LEAD_TIME_LOT_SIZE < 1) and
		   cr.REPETITIVE_PLANNING_FLAG = 'Y' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LEAD_TIME_LOT_SIZE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_LEAD_TIME_LOT_SIZE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate ATP_COMPONENTS_FLAG


		if (Prof_INV_CTP <> 4 and cr.WIP_SUPPLY_TYPE <> 6 ) and
		   cr.ATP_COMPONENTS_FLAG <> 'N' and
		   cr.PICK_COMPONENTS_FLAG = 'N' and
		   cr.REPLENISH_TO_ORDER_FLAG = 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'ATP_COMPONENTS_FLAG1',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ATP_COMPS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
		if( (Prof_INV_CTP = 1 and
                    cr.ATP_COMPONENTS_FLAG in ('C','R') and
          	    cr.REPLENISH_TO_ORDER_FLAG = 'N' and
		    cr.BOM_ITEM_TYPE in (1,2,4)) or
		   (Prof_INV_CTP in (2, 5) and
		    cr.ATP_COMPONENTS_FLAG in ('C','R')) or
                   (Prof_INV_CTP = 3 and
          	    cr.ATP_COMPONENTS_FLAG in ('C','R') and
          	    cr.BOM_ITEM_TYPE in (1,2,4, 5)) or
         	   (Prof_INV_CTP = 4 and
                    cr.ATP_COMPONENTS_FLAG in ('C','Y') and
                    cr.BOM_ITEM_TYPE = 5)) then
			 dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ATP_COMPONENTS_FLAG1',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_ATP_COMPS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate REPETITIVE_PLANNING_FLAG
		if (cr.MRP_PLANNING_CODE = 3 or
		    cr.MRP_PLANNING_CODE = 4) and
		    cr.REPETITIVE_PLANNING_FLAG is null then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REPETITIVE_PLANNING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_REPETITIVE_MAND',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate MTL_TRANSACTIONS_ENABLED_FLAG
		if  cr.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y' and
		    cr.STOCK_ENABLED_FLAG = 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MTL_TRANSACTIONS_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_TRX',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate INTERNAL_ORDER_ENABLED_FLAG
		if  cr.INTERNAL_ORDER_ENABLED_FLAG = 'Y' and
		    cr.INTERNAL_ORDER_FLAG = 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INTERNAL_ORDER_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INTERNAL_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- BugFix # 1402975
		--Validate INTERNAL_ORDER_FLAG and PICK_COMPONENTS_FLAG
		if cr.INTERNAL_ORDER_FLAG = 'Y' and
		   cr.PICK_COMPONENTS_FLAG = 'Y' then
			dumm_status := INVPUOPI.mtl_log_interface_err(
			cr.organization_id,
			user_id,
			login_id,
			prog_appid,
			prog_id,
			request_id,
			cr.TRANSACTION_ID,
			error_msg,
			'PICK_COMPONENTS_FLAG',
			'MTL_SYSTEM_ITEMS_INTERFACE',
			'INV_PICK_COMPONENTS_FLAG',
			err_text);
			if dumm_status < 0 then
				raise LOGGING_ERR;
			end if;
			status := 1;
		end if;
		-- End of Bug Fix 1402975

                /*NP 20AUG96 new validation for 10.7 columns*/
		-- validate CONTAINER_ITEM_FLAG
		if  cr.CONTAINER_ITEM_FLAG not in ('Y', 'N') then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CONTAINER_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate VEHICLE_ITEM_FLAG
		if  cr.VEHICLE_ITEM_FLAG not in ('Y', 'N') then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'VEHICLE_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate MINIMUM_FILL_PERCENTAGE
		if  (cr.MINIMUM_FILL_PERCENT < 0
                     OR cr.MINIMUM_FILL_PERCENT > 100) then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MINIMUM_FILL_PERCENTAGE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MIN_FILL_PERCENT',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                -- validate CONTAINER_ITEM_CODE
                if  (cr.CONTAINER_ITEM_FLAG = 'N'
                     AND cr.CONTAINER_TYPE_CODE  IS NOT NULL ) then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONTAINER_ITEM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONTAINER',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                    end if;

		-- validate MAXIMUM_LOAD_WEIGHT
		if  (cr.CONTAINER_ITEM_FLAG = 'N'
                     AND cr.VEHICLE_ITEM_FLAG = 'N'
                     AND cr.MAXIMUM_LOAD_WEIGHT IS NOT NULL )  then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MAXIMUM_LOAD_WEIGHT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONTAINER_OR_VEHICLE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                -- validate MINIMUM_FILL_PERCENT
                if  (cr.CONTAINER_ITEM_FLAG = 'N'
                     AND cr.VEHICLE_ITEM_FLAG = 'N'
                     AND cr.MINIMUM_FILL_PERCENT IS NOT NULL )  then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MINIMUM_FILL_PERCENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONTAINER_OR_VEHICLE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate INTERNAL_VOLUME
		if  (cr.CONTAINER_ITEM_FLAG = 'N'
                     AND cr.VEHICLE_ITEM_FLAG = 'N'
                     AND cr.INTERNAL_VOLUME IS NOT NULL )  then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INTERNAL_VOLUME',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONTAINER_OR_VEHICLE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate RELEASE_TIME_FENCE_CODE (RELEASE_TIME_FENCE_CODE)
		-- Added value 7 to existing values of Release Time Fence Code - R12 - Anmurali
		if  (cr.RELEASE_TIME_FENCE_CODE not in (1,2,3,4,5,6,7))  then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RELEASE_TIME_FENCE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REL_TIME_FENCE_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                -- validate RELEASE_TIME_FENCE_DAYS
                if cr.RELEASE_TIME_FENCE_CODE = 4 and
                   nvl(cr.RELEASE_TIME_FENCE_DAYS,-9) < 0 then
                             dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RELEASE_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_RELEASE_DAYS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;


               /* Bug 948771
                Added Validation For Release Time Fence Days
                When The Release Time Fence Code is Not USER DEFINED
               */
		-- validate AUTO_REL_TIME_FENCE_DAYS
                if (cr.RELEASE_TIME_FENCE_CODE <> 4 OR cr.RELEASE_TIME_FENCE_CODE IS NULL) and
                   cr.RELEASE_TIME_FENCE_DAYS is NOT NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RELEASE_TIME_FENCE_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RELEASE_TM_FENCE_DAYS',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;


		-- validate PICK_COMPONENTS_FLAG
		if  cr.SHIP_MODEL_COMPLETE_FLAG = 'Y' and
                    cr.PICK_COMPONENTS_FLAG = 'N' then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PICK_COMPONENTS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PICK_COMPONENTS_FLAG',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

/** Bug 1649399 added validation for shrinkage rate */

                -- validate SHRINKAGE_RATE
                if  (cr.SHRINKAGE_RATE >= 1) or (cr.SHRINKAGE_RATE < 0) then
                               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SHRINKAGE_RATE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SHRINKAGE_RATE_ERR',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                /* NP26DEC94 : New code to update process_flag.
                ** This code necessiated due to the breaking up INVPVHDR into
                ** 6 smaller packages to overcome PL/SQL limitations with code size.
                ** Let's update the process flag for the record
                ** Give it value 42 if all okay and 32 if some validation failed in this procedure
                ** Need to do this ONLY if all previous validation okay.
                ** The process flag values that are possible at this time are
                ** 31, 41 :set by INVPVHDR
                */
	   /* Bug 4705184. Get the process_flag value from cursor itself.
                select process_flag into temp_proc_flag
                  from MTL_SYSTEM_ITEMS_INTERFACE
                where inventory_item_id = l_item_id
                and   set_process_id + 0  = xset_id
		and   process_flag in (31,41)
                and   organization_id = cr.organization_id
		and   rownum < 2; */

		/*set value of process_flag to 42 or 32 depending on
		** value of the variable: status.
                ** Essentially, we check to see if validation has not
                ** already failed in one of the previous packages.
                */

               if temp_proc_flag <> 31 then
			update MTL_SYSTEM_ITEMS_INTERFACE
			set process_flag = DECODE(status,0,42,32),
			    PRIMARY_UOM_CODE = cr.primary_uom_code,
			    primary_unit_of_measure = cr.primary_unit_of_measure
			where inventory_item_id = l_item_id
                        -- and   set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id  = xset_id
			and process_flag = 41
			and   organization_id = cr.organization_id;
               end if;

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
                                'validation_error ' || stmt,
				'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
		return(status);
	when OTHERS then
		err_text := substr('INVPVALI.validate_item_header2' || SQLERRM, 1,240);
		return(SQLCODE);
end validate_item_header2;

end INVPVDR2;

/
