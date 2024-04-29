--------------------------------------------------------
--  DDL for Package Body INVPVDR3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR3" as
/* $Header: INVPVD3B.pls 120.6.12010000.3 2010/07/29 14:02:20 ccsingh ship $ */

function validate_item_header3
(
org_id		number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out	NOCOPY varchar2,
xset_id  IN     NUMBER     DEFAULT -999
)
return integer
is
        /******************************************************/
        /*  Variable required for the validation for UPDATES  */
        /******************************************************/
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
	/*
	** Retrieve column values for validation
	*/
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
         VEHICLE_ITEM_FLAG,
	 LOT_STATUS_ENABLED,
	 SERIAL_STATUS_ENABLED,
	 EFFECTIVITY_CONTROL,
	 ORDERABLE_ON_WEB_FLAG,
         EQUIPMENT_TYPE,
         DEFAULT_LOT_STATUS_ID,
         DEFAULT_SERIAL_STATUS_ID,
--Adding 2 attributes for bug fix 3969580 By Anmurali
         OVERCOMPLETION_TOLERANCE_TYPE,
         OVERCOMPLETION_TOLERANCE_VALUE,
--Adding an attribute for R12
         DRP_PLANNED_FLAG
	from MTL_SYSTEM_ITEMS_INTERFACE
--Replacing organization_id + 0 with organization_id - Anmurali -Bug 4175124
	where ((organization_id = org_id) or
	       (all_Org = 1))
        and   set_process_id  = xset_id
	and   process_flag in ( 31, 32, 42);

		/*NP 27DEC94
		 *New condition for process_flag;
		 *As a result of the  breakup of INVPVHDR into smaller packages
		 *there are now new process_flag values possible
		 *INVPVHDR sets it to either 31 or 41
		 *INVPVDR2 may overwrite 41 by 42 or 32; will not overwrite 31
		 * Thus the values possible are: 31, 32, 42
		 */


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
        temp_proc_flag          number;
        l_err_msg		varchar2(2000) := NULL;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452

begin

        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('Inside INVPVDR3');
	END IF;
	error_msg := 'Validation error in validating MTL_SYSTEM_ITEMS_INTERFACE with ';

/*
** validate the records
*/

	for cr in cc loop
		status := 0;
		trans_id := cr.transaction_id;
		l_org_id := cr.organization_id;
		l_item_id := cr.inventory_item_id; -- Bug 4705184
		temp_proc_flag := cr.process_flag; -- Bug 4705184

              /*NP 28DEC94
              **A lot of item_id realted validation has now been removed from all the new
              **INVPVDR*.sql packages that once constituted INVPVHDR
              **This validation was redundant (and expensive!).
              **
              **The item_id related  validation now takes place ONLY in INVPVHDR.sql.
              **
              **However, this has meant that the value for l_item_id (see INVPVHDR.sql)  now
              **needs to be gotten from the database
              */
            /* Bug 4705184. Get item_id from the cursor itself
                select inventory_item_id
                into l_item_id
                from mtl_system_items_interface
                where transaction_id = cr.transaction_id
                and   set_process_id = xset_id; */


		/*
		** Validate fields with lookup values @@
		*/

                /*INVPUTLI.info('INVPVDR3: Validating lookups'); */

                IF l_inv_debug_level IN(101, 102) THEN
		   INVPUTLI.info('INVPVDR3: L8R values: '|| l_item_id||' '|| l_org_id);
	           INVPUTLI.info('INVPVDR3: L8R revision_qty_control_code: '|| cr.revision_qty_control_code);
		END IF;

		-- validate lookup
		if  (cr.revision_qty_control_code <> 1 and
		     cr.revision_qty_control_code <> 2) then

		                IF l_inv_debug_level IN(101, 102) THEN
		                   INVPUTLI.info('INVPVDR3: inside the if..ie validation failed');
			        END IF;
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REVISION_QTY_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REV_QTY_CTRL_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.qty_rcv_exception_code <> 'NONE' and
		     cr.qty_rcv_exception_code <> 'REJECT' and
		     cr.qty_rcv_exception_code <> 'WARNING') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'QTY_RCV_EXCEPTION_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_QTY_RCV_EXC_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate lookup
		if  (cr.enforce_ship_to_location_code <> 'NONE' and
		     cr.enforce_ship_to_location_code <> 'REJECT' and
		     cr.enforce_ship_to_location_code <> 'WARNING') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'ENFORCE_SHIP_TO_LOCATION_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ENF_SHIP_TO_LOC',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate lookup
		if  (cr.receipt_days_exception_code <> 'NONE' and
		     cr.receipt_days_exception_code <> 'REJECT' and
		     cr.receipt_days_exception_code <> 'WARNING') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RECEIPT_DAYS_EXCEPTION_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REC_DAYS_EXC',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.lot_control_code <> 1 and
		     cr.lot_control_code <> 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LOT_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_LOT_CTRL_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.shelf_life_code not in (1, 2, 4)) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SHELF_LIFE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SHELF_LIFE_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.serial_number_control_code <> 1 and
		     cr.serial_number_control_code <> 2 and
		     cr.serial_number_control_code <> 5 and
		     cr.serial_number_control_code <> 6 ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERIAL_NUMBER_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SERIAL_NUM_CONTROL',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
               if (cr.source_type is not null) then
		if  (cr.source_type <> 1 and
		     cr.source_type <> 2 and
		     cr.source_type <> 3) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SOURCE_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SOURCE_TYPE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
               end if;
		-- validate lookup
		if  (cr.restrict_subinventories_code <> 1 and
		     cr.restrict_subinventories_code <> 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RESTRICT_SUBINVENTORIES_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.restrict_locators_code <> 1 and
		     cr.restrict_locators_code <> 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'RESTRICT_LOCATOR_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REST_LOC_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.location_control_code <> 1 and
		     cr.location_control_code <> 2 and
		     cr.location_control_code <> 3) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LOCATION_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_LOC_CTRL_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.planning_time_fence_code <> 1 and
		     cr.planning_time_fence_code <> 2 and
		     cr.planning_time_fence_code <> 3 and
		     cr.planning_time_fence_code <> 4) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PLANNING_TIME_FENCE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PLN_TIME_FENCE_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate lookup
		if  (cr.demand_time_fence_code <> 1 and
		     cr.demand_time_fence_code <> 2 and
		     cr.demand_time_fence_code <> 3 and
		     cr.demand_time_fence_code <> 4) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEMAND_TIME_FENCE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_DEM_TIME_FENCE_CODE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
-- Bug No:3296502  Lot Status can be enabled only if Lot Control is Full Controlled
		 IF l_inv_debug_level IN(101, 102) THEN
	            INVPUTLI.info('INVPVDR3: verifying lot status....');
		 END IF;

		if  (cr.LOT_CONTROL_CODE = 1 and NVL(cr.LOT_STATUS_ENABLED,'N') = 'Y') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LOT_STATUS_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_STA_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

-- serial_tagging Enh -- bug 9913552

		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying Serial Number Control for serial tagging');
                END IF;
		if  (cr.SERIAL_NUMBER_CONTROL_CODE in (2,5)) then

		     if INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => cr.inventory_item_id,
		         p_organization_id =>cr.organization_id)=2 then

                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERIAL_NUMBER_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SER_CNT_FLG_NT_CHG',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		    end if;
                end if;

-- Bug No:3296526  Serial Status can be enabled only if the item is Serial Controlled.

		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying serial status....');
                END IF;
		if  (cr.SERIAL_NUMBER_CONTROL_CODE = 1 and NVL(cr.SERIAL_STATUS_ENABLED,'N') = 'Y') then
                     --serial_tagging enh -- bug 9913552
		     IF (INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => cr.inventory_item_id,
                                                                p_organization_id => cr.organization_id)<>2) THEN

				dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERIAL_STATUS_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_SER_STA_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                    end if;
		end if;

-- Bug No:3306166 Safety COde must = 1 when mrp_planning_code=6
		if  (    cr.MRP_PLANNING_CODE = 6
		  -- Adding the NVL for Bug 5239406
		     and NVL(cr.drp_planned_flag,2) = 2  -- Adding the clause for R12
		     and cr.MRP_SAFETY_STOCK_CODE <> 1) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MRP_SAFETY_STOCK_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SAFETY_STOCK',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
		-- Start 2958422 : Effectivity Control Validations
		if cr.EFFECTIVITY_CONTROL IS NOT NULL
		   AND cr.EFFECTIVITY_CONTROL NOT IN (1,2)
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
				'EFFECTIVITY_CONTROL',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_INVALID_EFFECT_CONTL',
				err_text);
                   if dumm_status < 0 then
                      raise LOGGING_ERR;
                   end if;
                   status := 1;
		end if;

		if cr.EFFECTIVITY_CONTROL = 2
		   AND INV_ITEM_UTIL.g_Appl_Inst.PJM_Unit_Eff_flag ='N'
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
				'EFFECTIVITY_CONTROL',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MODEL_UNIT_CONTROL_NA',
				err_text);
                   if dumm_status < 0 then
                      raise LOGGING_ERR;
                   end if;
                   status := 1;
		end if;
		-- End 2958422 : Effectivity Control Validations

-- Bug No:3296755  SERIAL_NUMBER_CONTROL_CODE Must be 'At Recept' or 'Predefined' if Effectivity_control is 'Model/Unit Number'.
		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying serial status....');
                END IF;
		if  (cr.SERIAL_NUMBER_CONTROL_CODE = 1 and cr.EFFECTIVITY_CONTROL = 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERIAL_NUMBER_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'ITM-EFFC-Invalid Serial Ctrl',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

--Bug 4319349 Effectivity Control can be Model/Unit Number ONLY for BOM Item type Standard items -Anmurali
		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying bom item type for effectivity control....');
                END IF;
		if  (cr.BOM_ITEM_TYPE <> 4 and cr.EFFECTIVITY_CONTROL = 2) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'BOM_ITEM_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'ITM-EFFC-BOM Type is not Std',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
-- Bug No:3308701  ORDERABLE_ON_WEB_FLAG Must be 'N' if CUSTOMER_ORDER_ENABLED_FLAG is not set.
		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying serial status....');
		END IF;
		if  (NVL(cr.CUSTOMER_ORDER_ENABLED_FLAG,'N') = 'N' and NVL(cr.ORDERABLE_ON_WEB_FLAG,'N') =  'Y') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'ORDERABLE_ON_WEB_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_ORDERABLE_ON_WEB',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

-- Bug No:3311672  When BOM Item type is Option Class or Model, then Assemble to order or Pick Components must be Yes
		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR3: verifying serial status....');
		END IF;
		if  ((cr.BOM_ITEM_TYPE = 1 OR cr.BOM_ITEM_TYPE = 2 )
		       AND NVL(cr.PICK_COMPONENTS_FLAG,'N') = 'N' AND NVL(cr.REPLENISH_TO_ORDER_FLAG,'N') = 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'BOM_ITEM_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_BOM_TYPE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

-- Bug No:3294341  When SHELF_LIFE_CODE= 2 then SHELF_LIFE_DAYS should be > 0 and SHELF_LIFE_DAYS should always +Integer
                /* Jalaj Srivastava Bug 4079744
                     Shelf life should be a positive number less than 999999 */
		if (cr.SHELF_LIFE_DAYS < 0 OR cr.SHELF_LIFE_DAYS > 999999) then
		    l_err_msg := 'INV_INVALID_SHELF_LIFE_DAYS';
		elsif(cr.SHELF_LIFE_CODE = 2 AND cr.SHELF_LIFE_DAYS = 0 )then
      		    l_err_msg := 'INV_SHELF_DAYS_MUST_BE_GT_ZERO';
		end if;
		if (l_err_msg IS NOT NULL) then
                   dumm_status := INVPUOPI.mtl_log_interface_err(
                   cr.organization_id,
                   user_id,
                   login_id,
                   prog_appid,
                   prog_id,
                   request_id,
                   cr.TRANSACTION_ID,
                   error_msg,
		   'SHELF_LIFE_DAYS',
                   'MTL_SYSTEM_ITEMS_INTERFACE',
                   l_err_msg,
		   err_text);
                   if dumm_status < 0 then
                      raise LOGGING_ERR;
                   end if;
                   status := 1;
                end if;

-- Bug No:3436107 if Equipment is set to yes, then Serial number generation has to be `Receipt or Predefined
                if  (cr.SERIAL_NUMBER_CONTROL_CODE NOT IN (2,5) and cr.EQUIPMENT_TYPE = 1) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERIAL_NUMBER_CONTROL_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV-ITM-EQMT-INVALID_SER_CTRL',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
-- Bug No:3969580 If OVERCOMPLETION_TOLERANCE_TYPE is not specified then OVER_COMPLETION_TOLERANCE_VALUE must throw an error msg on entry
		if  (cr.OVERCOMPLETION_TOLERANCE_TYPE IS NULL)and (cr.OVERCOMPLETION_TOLERANCE_VALUE IS NOT NULL) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'OVERCOMPLETION_TOLERANCE_VALUE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_WIP_OC_TOLERANCE_V_NUPD',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
--End of bug fix 3969580 By Anmurali
-- Bug No:3421324 Default Lot/Serial Status is mandatory if Lot/Serial status is enabled
                l_err_msg := NULL;
		if  (cr.DEFAULT_LOT_STATUS_ID IS NULL and NVL(cr.LOT_STATUS_ENABLED,'N') = 'Y') then
                    l_err_msg :=  'INV_DEF_LOT_STATUS_MAND';
                elsif  (cr.DEFAULT_LOT_STATUS_ID IS NOT NULL and NVL(cr.LOT_STATUS_ENABLED,'N') = 'N') then
                    l_err_msg :=  'INV_DEF_LOT_STATUS_ID_NULL';
		end if;
                if l_err_msg IS NOT NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEFAULT_LOT_STATUS_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_err_msg,
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
                l_err_msg := NULL;
		if  (cr.DEFAULT_SERIAL_STATUS_ID IS NULL and NVL(cr.SERIAL_STATUS_ENABLED,'N') = 'Y') then
                    l_err_msg :=  'INV_DEF_SERIAL_STATUS_MAND';
                elsif  (cr.DEFAULT_SERIAL_STATUS_ID IS NOT NULL and NVL(cr.SERIAL_STATUS_ENABLED,'N') = 'N') then
                    l_err_msg :=  'INV_DEF_SERIAL_STATUS_ID_NULL';
		end if;
                if l_err_msg IS NOT NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEFAULT_SERIAL_STATUS_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_err_msg,
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
                ** 31 :set by INVPVHDR
                ** 32, 42 :set by INVPVDR2
                */
	   /* Bug 4705184. Get process flag from the cursor itself
                select process_flag into temp_proc_flag
                from MTL_SYSTEM_ITEMS_INTERFACE
                where inventory_item_id = l_item_id
                and   organization_id = cr.organization_id
		and   process_flag in (31,32,42)
                and   set_process_id = xset_id
		and   rownum < 2 ; */

                /*set value of process_flag to 43 or 33 depending on
                ** value of the variable: status.
                ** Essentially, we check to see if validation has not already failed in one of
                ** the previous packages.
                */
               if (temp_proc_flag <> 31 and temp_proc_flag <> 32) then
                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = DECODE(status,0,43,33),
                            PRIMARY_UOM_CODE = cr.primary_uom_code,
                            primary_unit_of_measure = cr.primary_unit_of_measure
                        where inventory_item_id = l_item_id
                        -- and   set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id = xset_id
		        and   process_flag = 42
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
		err_text := substr('INVPVALI.validate_item_header3' || SQLERRM , 1 , 240 );
		return(SQLCODE);
end validate_item_header3;

end INVPVDR3;

/
