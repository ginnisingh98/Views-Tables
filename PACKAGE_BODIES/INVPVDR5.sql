--------------------------------------------------------
--  DDL for Package Body INVPVDR5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR5" as
/* $Header: INVPVD5B.pls 120.14.12010000.2 2009/08/10 23:11:46 mshirkol ship $ */
-- private function to get the message text
-- created for fixing 3108469
function get_msg_text (p_message_name    IN  VARCHAR2
                      ,p_organization_id IN  NUMBER)
RETURN VARCHAR2 IS
  l_org_name      HR_ALL_ORGANIZATION_UNITS_VL.name%TYPE;
  l_msg_text      fnd_new_messages.message_text%TYPE;
BEGIN

  BEGIN
    SELECT name
      INTO l_org_name
      FROM hr_all_organization_units_vl
     WHERE organization_id = p_organization_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_org_name := p_organization_id;
  END;
  FND_MESSAGE.SET_NAME ('INV', p_message_name);
  FND_MESSAGE.SET_TOKEN ('ORGANIZATION', l_org_name);
  l_msg_text := FND_MESSAGE.GET;
  RETURN l_msg_text;
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_message_name;
END get_msg_text;

function validate_item_header5
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
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
         temp                  VARCHAR2(2);
         temp_uom_code         VARCHAR2(3);
         temp_u_o_m            VARCHAR2(25);
         temp_uom_class        VARCHAR2(10);
         temp_enabled_flag     VARCHAR2(1);
         temp_base_uom_flag    VARCHAR2(1);

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
         DIMENSION_UOM_CODE,
         UNIT_LENGTH,
         UNIT_WIDTH,
         UNIT_HEIGHT,
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
         SERV_REQ_ENABLED_CODE,
         SERV_BILLING_ENABLED_FLAG,
--         SERV_IMPORTANCE_LEVEL,
         PLANNED_INV_POINT_FLAG
-- Added for 11.5.10
      ,  TRACKING_QUANTITY_IND
      ,  ONT_PRICING_QTY_SOURCE
      ,  SECONDARY_DEFAULT_IND
      ,  SECONDARY_UOM_CODE
      ,  DUAL_UOM_DEVIATION_HIGH
      ,  DUAL_UOM_DEVIATION_LOW
      ,  CONTRACT_ITEM_TYPE_CODE
      ,  RECOVERED_PART_DISP_CODE
        from MTL_SYSTEM_ITEMS_INTERFACE
-- Replacing organization_id + 0 with organization_id - Anmurali - Bug 4175124
        where ((organization_id = org_id) or
               (all_Org = 1))
        and   set_process_id  = xset_id
        and   process_flag in (31, 32, 33, 34, 44);

         /*NP 27DEC94
         *New condition for process_flag;
         *As a result of the  breakup of INVPVHDR into smaller packages
         *there are now new process_flag values possible
         *INVPVHDR sets it to either 31 or 41
         *INVPVDR2 may overwrite 41 by 42 or 32; will not overwrite 31
         *INVPVDR3 may overwrite 42 by 43 or 33; will not overwrite 32
         *INVPVDR4 may overwrite 43 by 44 or 34; will not overwrite 33
         * Thus the values possible are: 31, 32, 33, 34, 44
         */

        --Start 2878098 WIP Locator mandatory by loc contrl
        CURSOR c_org_loc_control(cp_org_id number) IS
           SELECT stock_locator_control_code,negative_inv_receipt_code
           FROM   mtl_parameters
           where  organization_id = cp_org_id;

        CURSOR c_subinv_loc_control(cp_org_id      number,
                                    cp_subinv_name varchar2) IS
           SELECT locator_type
           FROM   mtl_secondary_inventories
           WHERE  secondary_inventory_name = cp_subinv_name
           AND    organization_id          = cp_org_id
           AND    SYSDATE < nvl(disable_date, SYSDATE+1);

        -- Added the cursor for bug # 3762750
	CURSOR c_fndcomlookup_exists(cp_lookup_type VARCHAR2,
	                             cp_lookup_code VARCHAR2) IS
	   SELECT enabled_flag
	   FROM FND_COMMON_LOOKUPS
	   WHERE lookup_type = cp_lookup_type
	   AND   lookup_code = cp_lookup_code;

      -- Added the cursor for bug # 3762750
      CURSOR c_fndlookup_exists(cp_lookup_type VARCHAR2,
  	                     cp_lookup_code VARCHAR2) IS
         SELECT 'x'
         FROM  FND_LOOKUP_VALUES_VL
         WHERE LOOKUP_TYPE = cp_lookup_type
         AND   LOOKUP_CODE = cp_lookup_code
         AND   SYSDATE BETWEEN  NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
         AND   ENABLED_FLAG = 'Y';

        l_org_loc_ctrl          number;
        l_subinv_loc_ctrl       number;
        l_locator_control       number;
        l_loc_mandatory         boolean := FALSE;
        l_allow_neg_bal_flag    number;
        l_return_status         varchar2(10);
        l_msg_count             number;
        l_msg_data              varchar2(240);


        --End 2878098 WIP Locator mandatory by loc contrl

        msicount                number;
        msiicount               number;
        resersal_flag           number;
        dup_item_id             number;
        l_item_id               number;
        l_org_id                number;
        cat_set_id              number;
        trans_id                number;
        ext_flag                number := 0;
        error_msg               varchar2(70);
        status                  number;
        dumm_status             number;
        master_org_id           number;
        stmt                    number;
        LOGGING_ERR             exception;
        VALIDATE_ERR            exception;
        chart_of_acc_id         number;
        temp_proc_flag          number;
        l_old_catalog_id        number;
        l_wip_subinv_error      BOOLEAN := FALSE;
        l_wip_locator_error     BOOLEAN := FALSE;
        l_message_name          VARCHAR2(30):= NULL;
        l_msg_text              fnd_new_messages.message_text%TYPE;
	l_source_subinv_error   BOOLEAN := FALSE;  -- Bug 4489727
	l_source_restrict_sub   number;            -- Bug 4489727
	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
	l_prev_org_id           NUMBER := -1;      -- Bug: 4654433

begin

        error_msg := 'Validation error in validating MTL_SYSTEM_ITEMS_INTERFACE with ';


-- validate the records

        for cr in cc loop
                status := 0;
                trans_id := cr.transaction_id;
                l_org_id := cr.organization_id;
		l_item_id := cr.inventory_item_id;  --Bug: 4654433
		temp_proc_flag := cr.process_flag; -- Bug 4705184


              /*NP 28DEC94
              **A lot of item_id related validation has now been removed from all the new
              **INVPVDR*.sql packages that once constituted INVPVHDR
              **This validation was redundant (and expensive!).
              **
              **The item_id related  validation now takes place ONLY in INVPVHDR.sql.
              **
              **However, this has meant that the value for l_item_id (see INVPVHDR.sql)  now
              **needs to be gotten from the database
              */
              /* Bug: 4654433 Commneting out the following code
              select inventory_item_id
                into l_item_id
                from mtl_system_items_interface
                where transaction_id = cr.transaction_id
                and   set_process_id = xset_id;
              */
        -- Validate first group of foreign keys

              IF l_inv_debug_level IN(101, 102) THEN
                 INVPUTLI.info('INVPVDR5: Validating foreign keys set 1');
              END IF;


stmt := 11;

                -- validate foreign keys: COST_OF_SALES_ACCOUNT
                /*NP 31AUG94 Get chart_of_accounts_id for the org where
                ** There is only one chart_of_accounts_id per organization_id.
                ** The chart_of_accounts_id will be used to validate the 4 expense accounts
                ** cost_of_sales_account, sales_account, expense_account and encumbrance_account
                */

                -- Bug fix # 3742121
                -- If an organization in mtl_system_items_interface does not exist in
                -- org_organization_definitions, error message is logged.
		--Bug: 4654433 Query chart_of_accounts_id only if organization_id has changed
		if l_org_id <> l_prev_org_id then
                   begin
                      --Perf Issue : Replaced org_organizations_definitions view.
                      SELECT lgr.CHART_OF_ACCOUNTS_ID into chart_of_acc_id
                      FROM   gl_ledgers lgr,
                             hr_organization_information hoi
                      where hoi.organization_id = cr.organization_id
                        and (HOI.ORG_INFORMATION_CONTEXT|| '') ='Accounting Information'
                        and TO_NUMBER(DECODE(RTRIM(TRANSLATE(HOI.ORG_INFORMATION1,'0123456789',' ')), NULL, HOI.ORG_INFORMATION1,-99999)) = LGR.LEDGER_ID
                        and lgr.object_type_code = 'L'
                        and rownum = 1;

                   exception
                           when NO_DATA_FOUND then
                                   dumm_status := INVPUOPI.mtl_log_interface_err(
                                   cr.organization_id,
                                   user_id,
                                   login_id,
                                   prog_appid,
                                   prog_id,
                                   request_id,
                                   cr.TRANSACTION_ID,
                                   l_msg_text,
                                   'ORGANIZATION_ID',
                                   'MTL_SYSTEM_ITEMS_INTERFACE',
                                   'INV_IOI_INVALID_ORG',
                                   err_text);
                                   if dumm_status < 0 then
                                           raise LOGGING_ERR;
                                   end if;
                                   status := 1;
                   end;
		end if;
		l_prev_org_id := l_org_id;
                -- End of bug fix # 3742121

                if  cr.COST_OF_SALES_ACCOUNT is not null then
                        begin
                                select 'x' into temp
                                from GL_CODE_COMBINATIONS
                                where CODE_COMBINATION_ID = cr.COST_OF_SALES_ACCOUNT
                                  and CHART_OF_ACCOUNTS_ID = chart_of_acc_id
                                  and nvl(START_DATE_ACTIVE,sysdate) <= sysdate
                                  and nvl(END_DATE_ACTIVE,sysdate) >= sysdate
				  and DETAIL_POSTING_ALLOWED_FLAG = 'Y' ;  --* Added for bug #4229090 - Anmurali
                                      /*NP 31AUG94 added CHART_OF_ACCOUNTS_ID clause*/
                        exception
                                when NO_DATA_FOUND then
                                -- 3108469
                                l_msg_text := get_msg_text (p_message_name => 'INV_IOI_COST_OF_SALES_ACNT'
                                                           ,p_organization_id => cr.organization_id);
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                l_msg_text,
                                'COST_OF_SALES_ACCOUNT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 12;
                -- validate foreign keys: SALES_ACCOUNT
                if  cr.SALES_ACCOUNT is not null then
                        begin
                                select 'x' into temp
                                from GL_CODE_COMBINATIONS
                                where CODE_COMBINATION_ID = cr.SALES_ACCOUNT
                                  and CHART_OF_ACCOUNTS_ID = chart_of_acc_id
                                  and nvl(START_DATE_ACTIVE,sysdate) <= sysdate
                                  and nvl(END_DATE_ACTIVE,sysdate) >= sysdate
				  and DETAIL_POSTING_ALLOWED_FLAG = 'Y' ;  --* Added for bug #4229090 - Anmurali
                                      /*NP 31AUG94 added CHART_OF_ACCOUNTS_ID clause*/
                        exception
                                when NO_DATA_FOUND then
                                -- 3108469
                                l_msg_text := get_msg_text (p_message_name => 'INV_IOI_SALES_ACCOUNT'
                                                           ,p_organization_id => cr.organization_id);
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                l_msg_text,
                                'SALES_ACCOUNT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 36;

               -- validate Expense_account
                if  cr.EXPENSE_ACCOUNT is not null then
                        begin
                                select 'x' into temp
                                from GL_CODE_COMBINATIONS
                                where CODE_COMBINATION_ID = cr.EXPENSE_ACCOUNT
                                  and CHART_OF_ACCOUNTS_ID = chart_of_acc_id
                                  and nvl(START_DATE_ACTIVE,sysdate) <= sysdate
                                  and nvl(END_DATE_ACTIVE,sysdate) >= sysdate
				  and DETAIL_POSTING_ALLOWED_FLAG = 'Y' ;  --* Added for bug #4229090 -Anmurali
                        exception
                                when NO_DATA_FOUND then
                                -- 3108469
                                l_msg_text := get_msg_text (p_message_name => 'INV_IOI_EXEPENSE_ACCOUNT'
                                                           ,p_organization_id => cr.organization_id);
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                l_msg_text,
                                'EXPENSE_ACCOUNT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 37;

               -- validate Encumbrance Account
                if  cr.ENCUMBRANCE_ACCOUNT is not null then
                        begin
                                select 'x' into temp
                                from GL_CODE_COMBINATIONS
                                where CODE_COMBINATION_ID = cr.ENCUMBRANCE_ACCOUNT
                                  and CHART_OF_ACCOUNTS_ID = chart_of_acc_id
                                  and nvl(START_DATE_ACTIVE,sysdate) <= sysdate
                                  and nvl(END_DATE_ACTIVE,sysdate) >= sysdate
				  and DETAIL_POSTING_ALLOWED_FLAG = 'Y' ;  --* Added for bug #4229090 -Anmurali
                        exception
                                when NO_DATA_FOUND then
                                -- 3108469
                                l_msg_text := get_msg_text (p_message_name => 'INV_IOI_ENCUMB_ACCT'
                                                           ,p_organization_id => cr.organization_id);
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
                        end;
                end if;

                if (cr.material_billable_flag IN ('E', 'L') AND
                       ( cr.stock_enabled_flag = 'Y' OR cr.mtl_transactions_enabled_flag = 'Y')) then
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MATERIAL_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MATERIAL_BILLABLE_NON_TXN',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if ;
--Added for 11.5.10  Recovered Part Disposition should be null For LABOR and EXPENSE Item Billing Types
                if (cr.material_billable_flag IN ('E', 'L') AND
                       cr.RECOVERED_PART_DISP_CODE IS NOT NULL) then
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MATERIAL_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_REC_PART_BIILLING_TYPE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if ;
--Added for 11.5.10  If Billing Enabled Flag is not set then Billing Type cannot be defined.
                if (cr.material_billable_flag IS NOT NULL AND
                       NVL(cr.SERV_BILLING_ENABLED_FLAG,'N') = 'N') then
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MATERIAL_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SERV_BILLING_MATERIAL_DEP',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if ;
stmt := 13;
                -- validate foreign keys
                if  cr.PICKING_RULE_ID is not null then
                        begin
                                select 'x' into temp
                                from MTL_PICKING_RULES
                                where PICKING_RULE_ID = cr.PICKING_RULE_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PICKING_RULE_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PICKING_RULE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 14;
                -- validate foreign keys
                if  cr.INVENTORY_ITEM_STATUS_CODE is not null then
                        begin
                                select 'x' into temp
                                from MTL_ITEM_STATUS
                                where INVENTORY_ITEM_STATUS_CODE = cr.INVENTORY_ITEM_STATUS_CODE
                                  and SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVENTORY_ITEM_STATUS_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_STATUS_CODE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 16;
                -- validate foreign keys
                if  cr.ENGINEERING_ITEM_ID is not null then
                        begin
                                select 'x' into temp
                                from MTL_SYSTEM_ITEMS
                                where INVENTORY_ITEM_ID = cr.ENGINEERING_ITEM_ID
                                and   ORGANIZATION_ID = cr.ORGANIZATION_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ENGINEERING_ITEM_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 17;
-- validate foreign keys

/*Fix for bug 4564472 - Since primary_unit_of_measure and primary_uom_code cannot be updated it is sufficient
  to make the below uom related validations for create txn only.
  Added below If condition to check for TRANSACTION_TYPE=CREATE. */

	IF cr.TRANSACTION_TYPE='CREATE' THEN

                IF  cr.PRIMARY_UNIT_OF_MEASURE IS NOT NULL THEN
                  BEGIN
                    select UOM_CODE into temp_uom_code
                    from MTL_UNITS_OF_MEASURE
                    where UNIT_OF_MEASURE = cr.PRIMARY_UNIT_OF_MEASURE /*Bug 5192495*/
                     and SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/

                    if cr.PRIMARY_UOM_CODE is null then
                      cr.PRIMARY_UOM_CODE := temp_uom_code;
                    else
                      if cr.PRIMARY_UOM_CODE <> temp_uom_code then
                            dumm_status := INVPUOPI.mtl_log_interface_err(
                            cr.organization_id,
                            user_id,
                            login_id,
                            prog_appid,
                            prog_id,
                            request_id,
                            cr.TRANSACTION_ID,
                            error_msg,
                            'PRIMARY_UOM_CODE',
                            'MTL_SYSTEM_ITEMS_INTERFACE',
                            'INV_IOI_PRIMARY_UOM',
                            err_text);
                            if dumm_status < 0 then
                              raise LOGGING_ERR;
                            end if;
                            status := 1;
                        end if;
                     end if;
                     exception
                       when NO_DATA_FOUND then
                       dumm_status := INVPUOPI.mtl_log_interface_err(
                       cr.organization_id,
                       user_id,
                       login_id,
                       prog_appid,
                       prog_id,
                       request_id,
                       cr.TRANSACTION_ID,
                       error_msg,
                       'PRIMARY_UNIT_OF_MEASURE',
                       'MTL_SYSTEM_ITEMS_INTERFACE',
                       'INV_IOI_PRIMARY_UOM',
                       err_text);
                       if dumm_status < 0 then
                         raise LOGGING_ERR;
                       end if;
                       status := 1;
stmt := 18;
                        end;

                /*NP 22SEP94 if PRIMARY_UNIT_OF_MEASURE is null
                **   and UOM_CODE is not
                */
                ELSIF cr.PRIMARY_UOM_CODE is not null THEN
                  BEGIN
                    select UNIT_OF_MEASURE into temp_u_o_m  /*Bug 5192495*/
                    from MTL_UNITS_OF_MEASURE
                    where UOM_CODE = cr.PRIMARY_UOM_CODE
                     and SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/

                    cr.PRIMARY_UNIT_OF_MEASURE := temp_u_o_m;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                         dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
                         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
                         'PRIMARY_UOM_CODE',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_IOI_PRIMARY_UOM',
                         err_text);
                         IF dumm_status < 0 THEN
                           RAISE LOGGING_ERR;
                         END IF;
                         status := 1;
                  END;
                END IF; --IF cr.PRIMARY_UNIT_OF_MEASURE is not null THEN


/*NP 17OCT94 New code to fix bug # 241374
** By this time the cr.inventory_item_id, cr.PRIMARY_UNIT_OF_MEASURE
** and cr.PRIMARY_UOM_CODE fields already have values assigned to them.
** Here we validate that for any given inv_item_id
** the primary_unit_of_measure (and correspondingly the primary_uom_code)
** should be in the same uom_class across ALL orgs
*/
                -- validate foreign keys
                if  cr.PRIMARY_UOM_CODE is not null THEN  --* Modified for Bug 4366615
                        begin
                                select UOM_CLASS into temp_uom_class
                                  from MTL_UNITS_OF_MEASURE
				where UOM_CODE = cr.PRIMARY_UOM_CODE; --* Modified for Bug 4366615

/*Fix for bug 4564472 -Organizaition_id filter was added in the where clause of the below query
			  to improve its performance. */

                                select 'x' into temp
                                  from MTL_SYSTEM_ITEMS msi
                                 where INVENTORY_ITEM_ID = cr.INVENTORY_ITEM_ID
				   and ORGANIZATION_ID in
                                     ( select MASTER_ORGANIZATION_ID
                                         from MTL_PARAMETERS
                                        where ORGANIZATION_ID = MASTER_ORGANIZATION_ID )
                                   and rownum = 1
                                   and not exists
                                        (select UNIT_OF_MEASURE
                                           from MTL_UNITS_OF_MEASURE MUOM
                                          where UOM_CLASS = temp_uom_class
                                            and msi.PRIMARY_UOM_CODE
                                                     = MUOM.UOM_CODE);

                              /*NP If any rows are fetched here then it is invalid
                              **   Call the error routine
                              **   else goto the exception and exit this validation
                              **   succesfully.
                              */

                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PRIMARY_UNIT_OF_MEASURE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PRIMARY_UOM2',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;

                        exception
                                when NO_DATA_FOUND then
                                 /*NP Do nothing. Valid data */
                                 null;
                        end;
                end if;


     -- Bug 1320556: when the UOM entered is Item Specific,
     -- and the UOM is not the base UOM of the Class,
     -- check if there is a conversion defined for the UOM.
     --
     -- Bug 1386939: the UOM conversion must exist irrespective
     -- of Conversions (ALLOWED_UNITS_LOOKUP_CODE).

                /* if (cr.ALLOWED_UNITS_LOOKUP_CODE = 1) and */
                if cr.PRIMARY_UOM_CODE is not null THEN  --* Modified for Bug 4366615
                      select  BASE_UOM_FLAG
                        into  temp_base_uom_flag
                      from  MTL_UNITS_OF_MEASURE
                      where UOM_CODE = cr.PRIMARY_UOM_CODE; --* Modified for Bug 4366615

                      if (temp_base_uom_flag <> 'Y') then
                      begin
                        select 'x'
                        into temp
                        from mtl_uom_conversions
                        where INVENTORY_ITEM_ID = 0
                          and UOM_CODE = cr.PRIMARY_UOM_CODE;

                      exception
                         when no_data_found then
                            dumm_status := INVPUOPI.mtl_log_interface_err (
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PRIMARY_UNIT_OF_MEASURE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_NO_UOM_CONV',
                                err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
                                status := 1;
                      end;
                      end if;
                end if;

	END IF; /* Fix for bug 4564472 - End of if for transaction_type='create' */

                -- Validate ITEM_TYPE
                --
                if  cr.ITEM_TYPE is not null then
			-- 3762750: Using cursor call to avoid multiple parsing
			OPEN  c_fndcomlookup_exists('ITEM_TYPE',cr.ITEM_TYPE);
			FETCH c_fndcomlookup_exists INTO temp_enabled_flag;
			CLOSE c_fndcomlookup_exists;

                        if (temp_enabled_flag <> 'Y' OR temp_enabled_flag IS NULL) then
                             dumm_status := INVPUOPI.mtl_log_interface_err(
                                                cr.organization_id,
                                                user_id,
                                                login_id,
                                                prog_appid,
                                                prog_id,
                                                request_id,
                                                cr.TRANSACTION_ID,
                                                error_msg,
                                                'ITEM_TYPE',
                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                'INV_IOI_ITEM_TYPE',
                                                err_text);
			     if dumm_status < 0 then
				  raise LOGGING_ERR;
			     end if;
                             status := 1;
                         end if;
                end if;

                --validate CONTAINER_TYPE_CODE

                if  cr.CONTAINER_TYPE_CODE is not null then
			-- 3762750: Using cursor call to avoid multiple parsing
			OPEN  c_fndcomlookup_exists('CONTAINER_TYPE',cr.CONTAINER_TYPE_CODE);
			FETCH c_fndcomlookup_exists INTO temp_enabled_flag;
			CLOSE c_fndcomlookup_exists;

                        if (temp_enabled_flag <> 'Y' OR temp_enabled_flag IS NULL) then
                              dumm_status := INVPUOPI.mtl_log_interface_err(
                                                cr.organization_id,
                                                user_id,
                                                login_id,
                                                prog_appid,
                                                prog_id,
                                                request_id,
                                                cr.TRANSACTION_ID,
                                                error_msg,
                                                'CONTAINER_TYPE_CODE',
                                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                                'INV_IOI_CONTAINER_TYPE_CODE',
                                                err_text);
                              if dumm_status < 0 then
                                   raise LOGGING_ERR;
                              end if;
                              status := 1;
                        end if;
                end if;

stmt := 19;
                -- validate foreign keys
                if  cr.VOLUME_UOM_CODE is not null then
                        begin
                                select 'x' into temp
                                from MTL_UNITS_OF_MEASURE
                                where UOM_CODE = cr.VOLUME_UOM_CODE;
                        exception
                            when NO_DATA_FOUND then
                             dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VOLUME_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_VOLUME_UOM_CODE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 20;
                -- validate foreign keys
             /* R12 C Unit Weight can now be updated for Pending items. Moving the below set of validations to INVPVHDR
                if  cr.WEIGHT_UOM_CODE is not null then
                        begin
                                select 'x' into temp
                                from MTL_UNITS_OF_MEASURE
                                where UOM_CODE = cr.WEIGHT_UOM_CODE;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WEIGHT_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_WEIGHT_UOM_CODE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;  */

                IF l_inv_debug_level IN(101, 102) THEN
                   INVPUTLI.info('INVPVDR5: Validating foreign keys set 2');
                END IF;

stmt := 21;
                -- validate foreign keys
                if  cr.ITEM_CATALOG_GROUP_ID is not null then
                   --2777118: Start Catalog Group check enhanced
                   IF cr.transaction_type ='CREATE' THEN
                      BEGIN
                         select 'x' into temp
                         from   mtl_item_catalog_groups
                         where  item_catalog_group_id = cr.ITEM_CATALOG_GROUP_ID
                         and    item_creation_allowed_flag    = 'Y'
                         and    NVL(inactive_date,sysdate+1) > sysdate;
                      exception
                         when NO_DATA_FOUND then
                            dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ITEM_CATALOG_GROUP_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ITEM_CAT_GROUP',
                                err_text);
                            if dumm_status < 0 then
                               raise LOGGING_ERR;
                            end if;
                            status := 1;
                        END;
                      ELSIF  cr.transaction_type ='UPDATE' THEN

                         SELECT item_catalog_group_id
                         INTO   l_old_catalog_id
                         FROM   mtl_system_items_b
                         WHERE  inventory_item_id = cr.inventory_item_id
                         AND    organization_id   = cr.organization_id;

                        --Bug: 2805253 Modified the validation
                        -- IF (l_old_catalog_id IS NULL OR l_old_catalog_id <> cr.item_catalog_group_id) THEN
                         IF (NVL(l_old_catalog_id,-1) <> NVL(cr.item_catalog_group_id,-1) AND cr.item_catalog_group_id IS NOT NULL) THEN
                            BEGIN
                            /*Bug:3491746
                               SELECT 'x' into temp
                               FROM   mtl_item_catalog_groups_b
                               WHERE  item_catalog_group_id = cr.item_catalog_group_id
                               AND    item_creation_allowed_flag    = 'Y'
                               AND    item_catalog_group_id IN
                                        (SELECT ICG.item_catalog_group_id
                                         FROM mtl_item_catalog_groups_b ICG
                                         WHERE ICG.item_creation_allowed_flag = 'Y'
                                         AND ((ICG.inactive_date IS NULL) OR (TRUNC(ICG.inactive_date) > TRUNC(SYSDATE))));
                             ELSE
                               SELECT 'x' into temp
                               FROM   mtl_item_catalog_groups_b
                               WHERE  item_catalog_group_id = cr.item_catalog_group_id
                               AND    item_creation_allowed_flag    = 'Y'
                               AND    item_catalog_group_id IN
                                        (SELECT ICG.item_catalog_group_id
                                         FROM mtl_item_catalog_groups_b ICG
                                         WHERE ICG.item_creation_allowed_flag = 'Y'
                                         --Bug: 2805253 Removed NVL
                                         AND ((ICG.inactive_date IS NULL) OR (TRUNC(ICG.inactive_date) > TRUNC(SYSDATE)))
                                         CONNECT BY PRIOR ICG.item_catalog_group_id = ICG.parent_catalog_group_id
                                         START WITH ICG.item_catalog_group_id  = l_old_catalog_id);
                             END IF;
                             */
                             SELECT 'x' into temp
                               FROM   mtl_item_catalog_groups_b
                               WHERE  item_catalog_group_id = cr.item_catalog_group_id
                               AND    item_creation_allowed_flag    = 'Y'
                               AND   (inactive_date IS NULL OR TRUNC(inactive_date) > TRUNC(SYSDATE));
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                                        cr.organization_id,
                                                        user_id,
                                                        login_id,
                                                        prog_appid,
                                                        prog_id,
                                                        request_id,
                                                        cr.TRANSACTION_ID,
                                                        error_msg,
                                                        'ITEM_CATALOG_GROUP_ID',
                                                        'MTL_SYSTEM_ITEMS_INTERFACE',
                                                        'INV_IOI_ONLY_CATALOG_DOWNCAST',
                                                        err_text);
                                  if dumm_status < 0 then
                                     raise LOGGING_ERR;
                                  end if;
                                  status := 1;
                               END;
                            END IF;
                         END IF;
                         --2777118: End Catalog Group check enhanced
                end if;
stmt := 22;
                -- validate foreign keys
                if  cr.SOURCE_SUBINVENTORY is not null then

		  -- Bug4489727. Restrict subinventories based on source organization's restrict sub checkbox
		  l_source_subinv_error := FALSE;
		  if ( cr.ORGANIZATION_ID <> cr.SOURCE_ORGANIZATION_ID ) then
		        select restrict_subinventories_code
                        into l_source_restrict_sub
		        from mtl_system_items_b
		        where organization_id = cr.SOURCE_ORGANIZATION_ID
		        and   inventory_item_id = cr.INVENTORY_ITEM_ID;
                  else
                        l_source_restrict_sub := nvl(cr.RESTRICT_SUBINVENTORIES_CODE, 2) ;
                  end if;

                   if ( l_source_restrict_sub = 1 ) then
                     begin
                       select 'x' into temp
                       from MTL_SECONDARY_INVENTORIES s, MTL_ITEM_SUB_INVENTORIES i
                       where s.SECONDARY_INVENTORY_NAME = cr.SOURCE_SUBINVENTORY
                       and   s.ORGANIZATION_ID = cr.SOURCE_ORGANIZATION_ID
		       and   nvl(s.DISABLE_DATE, sysdate + 1 ) > sysdate
		       and   i.INVENTORY_ITEM_ID = cr.INVENTORY_ITEM_ID
		       and   i.ORGANIZATION_ID = cr.SOURCE_ORGANIZATION_ID
		       and   i.SECONDARY_INVENTORY = s.SECONDARY_INVENTORY_NAME
		       and   2 = decode(cr.source_organization_id, cr.organization_id,
		                 decode(cr.mrp_planning_code, 3, availability_type, 7, availability_type, 9, availability_type, 2), 2);
                     exception
		       when NO_DATA_FOUND then
		          l_source_subinv_error  := TRUE;
                          l_message_name := 'INV_INT_RESSUBEXP';
                     end;
		   else
                        begin
                                select 'x' into temp
                                from MTL_SECONDARY_INVENTORIES
                                where SECONDARY_INVENTORY_NAME = cr.SOURCE_SUBINVENTORY
                                and   ORGANIZATION_ID = cr.SOURCE_ORGANIZATION_ID
		                and   nvl(DISABLE_DATE, sysdate + 1 ) > sysdate
		                and   2 = decode(cr.source_organization_id, cr.organization_id,
		                          decode(cr.mrp_planning_code, 3, availability_type, 7, availability_type, 9, availability_type, 2), 2);
                        exception
		          when NO_DATA_FOUND then
		             l_source_subinv_error  := TRUE;
                             l_message_name := 'INV_IOI_SOURCE_SUB';
		        end;
		      end if;

                      if ( l_source_subinv_error ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SOURCE_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_message_name,
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                      end if;
                end if;

stmt := 23;
                -- validate foreign keys
                if  cr.HAZARD_CLASS_ID is not null then
                        begin
                                select 'x' into temp
                                from PO_HAZARD_CLASSES
                                where HAZARD_CLASS_ID = cr.HAZARD_CLASS_ID
                                and (INACTIVE_DATE is null or INACTIVE_DATE > sysdate);
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'HAZARD_CLASS_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_HAZARD_CLASS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 24;
                -- validate foreign keys
                if  cr.UN_NUMBER_ID is not null then
                        begin
                                select 'x' into temp
                                from PO_UN_NUMBERS
                                where UN_NUMBER_ID = cr.UN_NUMBER_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'UN_NUMBER_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_UN_NUMBER',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 25;
                -- validate foreign keys
                if  cr.ASSET_CATEGORY_ID is not null then
                        begin
                                select 'x' into temp
                                from FA_CATEGORIES
                                where CATEGORY_ID = cr.ASSET_CATEGORY_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ASSET_CATEGORY_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ASSET_CAT_ID',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

stmt := 26;
                -- validate foreign keys
                if  cr.BASE_ITEM_ID is not null then
                        begin
                                select 'x' into temp
                                from MTL_SYSTEM_ITEMS
                                where INVENTORY_ITEM_ID = cr.BASE_ITEM_ID
                                and   ORGANIZATION_ID = cr.ORGANIZATION_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'BASE_ITEM_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_BASE_ITEM_ID',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
--Added for 11.5.10 If Base Model is null then Autocreated Configuration flag cannot be defined.
               elsif cr.AUTO_CREATED_CONFIG_FLAG = 'Y' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'AUTO_CREATED_CONFIG_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_BASE_ITEM_AUTO_CREATE_DEP',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
               end if;

stmt := 28;
                -- validate foreign keys
                -- 2870552 : WIP SUB INV validation sequenced properly
                IF (cr.WIP_SUPPLY_SUBINVENTORY IS NOT NULL ) THEN
                   l_wip_subinv_error := FALSE;
                   IF cr.RESTRICT_SUBINVENTORIES_CODE = 1    AND cr.TRANSACTION_TYPE ='CREATE' THEN
                      l_wip_subinv_error := TRUE;
                      l_message_name     := 'INV_IOI_WIP_SUP_SUB';
                   ELSIF cr.RESTRICT_SUBINVENTORIES_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' THEN
                      BEGIN
                         SELECT 'x' INTO temp
                         FROM  MTL_ITEM_SUB_INVENTORIES i
                         WHERE i.inventory_item_id   = cr.inventory_item_id
                         AND   i.ORGANIZATION_ID     = cr.ORGANIZATION_ID
                         AND   i.SECONDARY_INVENTORY = cr.WIP_SUPPLY_SUBINVENTORY;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_wip_subinv_error := TRUE;
                            l_message_name     := 'INV_INT_RESSUBEXP';
                      END;
                   ELSIF NVL(cr.RESTRICT_SUBINVENTORIES_CODE,2) = 2 THEN
                      BEGIN
                         SELECT 'x' INTO temp
                         FROM  MTL_SECONDARY_INVENTORIES
                         WHERE SECONDARY_INVENTORY_NAME = cr.WIP_SUPPLY_SUBINVENTORY
                         AND   ORGANIZATION_ID          = cr.ORGANIZATION_ID
                         AND  SYSDATE < nvl(DISABLE_DATE, SYSDATE+1);
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_wip_subinv_error := TRUE;
                            l_message_name     := 'INV_IOI_WIP_SUP_SUB';
                      END;
                   END IF;

                   IF l_wip_subinv_error THEN
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WIP_SUPPLY_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_message_name,
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                   END IF;
                END IF;
                --End of fix 2870552
stmt := 48;
                --Start 2878098,3799430: WIP Locator mandatory by loc contrl
                IF cr.WIP_SUPPLY_SUBINVENTORY IS NOT NULL THEN

                   l_loc_mandatory := FALSE;
                   OPEN  c_org_loc_control(cr.organization_id);
                   FETCH c_org_loc_control INTO l_org_loc_ctrl,l_allow_neg_bal_flag;
                   CLOSE c_org_loc_control;

                   OPEN  c_subinv_loc_control(cr.organization_id,cr.wip_supply_subinventory);
                   FETCH c_subinv_loc_control INTO l_subinv_loc_ctrl;
                   CLOSE c_subinv_loc_control;

                   l_locator_control :=
                    inv_globals.locator_control(l_return_status,l_msg_count,l_msg_data,
                          l_org_loc_ctrl,l_subinv_loc_ctrl,cr.location_control_code,
                          cr.restrict_locators_code,l_allow_neg_bal_flag,1);

                   if nvl(l_locator_control,1) in (2,3) then
                      l_loc_mandatory := TRUE;
                   end if;


          /* Bug 3799430. Modifying fix 2878098 as its incomplete

                   IF l_org_loc_ctrl IN (2,3) THEN
                      l_loc_mandatory := TRUE;
                   END IF;

                   IF NOT l_loc_mandatory THEN
                      OPEN  c_subinv_loc_control(cr.organization_id,cr.wip_supply_subinventory);
                      FETCH c_subinv_loc_control INTO l_subinv_loc_ctrl;
                      CLOSE c_subinv_loc_control;
                      IF l_subinv_loc_ctrl NOT IN (1,5) THEN
                         l_loc_mandatory := TRUE;
                      END IF;
                   END IF;

                   IF NOT l_loc_mandatory
                      AND cr.LOCATION_CONTROL_CODE <> 1 THEN
                      l_loc_mandatory := TRUE;
                   END IF;
           */
                   IF l_loc_mandatory
                      AND cr.WIP_SUPPLY_LOCATOR_ID IS NULL THEN
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WIP_SUPPLY_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SUP_LOC_ID_MANDATORY',
                                err_text);
                       IF dumm_status < 0 THEN
                          raise LOGGING_ERR;
                       END IF;
                       status := 1;
                    END IF;

                END IF;
                --End 2878098: WIP Locator mandatory by loc contrl

stmt := 27;
                -- 2870552: Locators  LOV should be redefined by Restrict Locators option.
                -- validate foreign keys
                IF  cr.WIP_SUPPLY_LOCATOR_ID IS NOT NULL THEN

                   l_wip_locator_error := FALSE;

                   IF cr.RESTRICT_LOCATORS_CODE = 1 AND cr.TRANSACTION_TYPE ='CREATE' THEN
                      l_wip_locator_error := TRUE;
                   ELSIF cr.RESTRICT_LOCATORS_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' THEN
                      BEGIN
                         SELECT 'x' INTO temp
                         FROM   MTL_SECONDARY_LOCATORS
                         WHERE  INVENTORY_ITEM_ID     = cr.INVENTORY_ITEM_ID
                         AND    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                         AND    SECONDARY_LOCATOR     = cr.WIP_SUPPLY_LOCATOR_ID
                         AND    SUBINVENTORY_CODE     = cr.WIP_SUPPLY_SUBINVENTORY;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_wip_locator_error := TRUE;
                      END;
                   ELSIF NVL(cr.RESTRICT_LOCATORS_CODE,2) = 2 THEN
                      BEGIN
                         SELECT 'x' INTO temp
                         FROM   MTL_ITEM_LOCATIONS
                         WHERE  INVENTORY_LOCATION_ID = cr.WIP_SUPPLY_LOCATOR_ID
                         AND    SUBINVENTORY_CODE     = cr.WIP_SUPPLY_SUBINVENTORY
                         AND    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                         AND    SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_wip_locator_error := TRUE;
                      END;
                   END IF;

                   IF l_wip_locator_error THEN
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WIP_SUPPLY_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_WIP_SUP_LOC_ID',
                                err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
                                status := 1;
                   END IF;
                END IF;
                --End of fix 2870552

stmt := 29;
                -- validate foreign keys
                if  cr.BUYER_ID is not null then
                        begin

                        -- Lines changed by Ppeddama on 2/2/2000 for bug#1171778
       -- For the bug fix 3845910 from base bug 3810566-- anmurali
       -- Bug 4695915 - Replacing references to per_all_workforce_v with per_people_f

			if (nvl(hr_general.get_xbg_profile, 'N') = 'Y') then
				SELECT 'x' into temp
				  FROM PER_PEOPLE_F  PPF,
                                       PO_AGENTS POA, PER_BUSINESS_GROUPS_PERF PB
                                WHERE PPF.PERSON_ID = POA.AGENT_ID
                                  AND PPF.BUSINESS_GROUP_ID= PB.BUSINESS_GROUP_ID
                                  AND SYSDATE BETWEEN NVL(POA.START_DATE_ACTIVE, SYSDATE-1)
                                  AND NVL(POA.END_DATE_ACTIVE,SYSDATE+1)
                                  AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
				  AND PPF.PERSON_ID = cr.BUYER_ID;
			else
				SELECT 'x' into temp
                                  FROM PER_PEOPLE_F  PPF,
	                               PO_AGENTS POA , HR_ORGANIZATION_UNITS ORG
   	                         WHERE PPF.PERSON_ID = POA.AGENT_ID
	                           AND PPF.BUSINESS_GROUP_ID= ORG.BUSINESS_GROUP_ID
	                           AND ORG.ORGANIZATION_ID = cr.ORGANIZATION_ID
	                           AND SYSDATE BETWEEN NVL(POA.START_DATE_ACTIVE, SYSDATE-1)
	                           AND NVL(POA.END_DATE_ACTIVE,SYSDATE+1)
 	                           AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND  PPF.EFFECTIVE_END_DATE
				   AND PPF.PERSON_ID = cr.BUYER_ID;
			end if;

        -- End of Bug 3845910 -- anmurali

                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'BUYER_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_BUYER_ID',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;


stmt := 30;
                -- validate foreign keys
                if  cr.RECEIVING_ROUTING_ID is not null then
                        begin
                                select 'x' into temp
                                from RCV_ROUTING_HEADERS
                                where ROUTING_HEADER_ID = cr.RECEIVING_ROUTING_ID;
                        exception
                                when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RECEIVING_ROUTING_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REC_ROUTING_ID',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;
                if  cr.SERV_REQ_ENABLED_CODE is not null AND
                    cr.SERV_REQ_ENABLED_CODE not in ('E','D','I') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERV_REQ_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SERV_REQ_ENABLED',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
--Added for 11.5.10 SERV_REQ_ENABLED_CODE must be mutually exclusive with 'SERVICE,WARRANTY and USAGE'
                if  cr.SERV_REQ_ENABLED_CODE ='E'  AND
                    cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE', 'WARRANTY', 'USAGE') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERV_REQ_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SERV_REQ_CONTRACT_DEP',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
--Added for 11.5.10 SERVICE_STARTING_DELAY cannot have a value if Item contract type is not 'SUBSCRIPTION' and not NULL
                if  cr.SERVICE_STARTING_DELAY IS NOT NULL AND
                    NVL(cr.CONTRACT_ITEM_TYPE_CODE,'SUBSCRIPTION') <> 'SUBSCRIPTION' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERVICE_STARTING_DELAY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONTRACT_START_DELAY_DEP',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
/* Removed in 11.5.10
                if  nvl(cr.SERV_IMPORTANCE_LEVEL,1) < 0 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERV_IMPORTANCE_LEVEL',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SERV_IMPORTANCE_LEVEL',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
*/
stmt := 32;
  --Jalaj Srivastava Bug 5017588
  --uom fields should only be validated while creating the item
  --{
  IF cr.TRANSACTION_TYPE='CREATE' THEN
                -- validate foreign keys for 11.5.10
                if  cr.TRACKING_QUANTITY_IND is not null then
	     --3762750: Using cursor call to avoid multiple parsing
	     -- Added this assignment for Bug 4096886  -- Anmurali
		   temp := null;
                   OPEN  c_fndlookup_exists('INV_TRACKING_UOM_TYPE',cr.TRACKING_QUANTITY_IND);
	           FETCH c_fndlookup_exists INTO temp;
		   CLOSE c_fndlookup_exists;
		   IF temp IS NULL THEN
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'TRACKING_QUANTITY_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                      if dumm_status < 0 then
                                        raise LOGGING_ERR;
                      end if;
                      status := 1;
                   END IF;
                end if;

                if  cr.ONT_PRICING_QTY_SOURCE is not null then
		   begin
                  --3762750: Using cursor call to avoid multiple parsing
                  -- Added this assignment for Bug 4096886  -- Anmurali
		      temp := null;
                      OPEN  c_fndlookup_exists('INV_PRICING_UOM_TYPE',cr.ONT_PRICING_QTY_SOURCE);
	              FETCH c_fndlookup_exists INTO temp;
	              CLOSE c_fndlookup_exists;
		      IF temp IS NULL THEN
		         RAISE NO_DATA_FOUND;
		      END IF;
		   --Jalaj Srivastava Bug 5017588
		   --remove the condition "Pricing will be supported
		   --only in OM.J and WMS.J installed environments."
                   exception
                      when NO_DATA_FOUND then
                         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ONT_PRICING_QTY_SOURCE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                         if dumm_status < 0 then
                            raise LOGGING_ERR;
                         end if;
                         status := 1;
                   end;
                end if;

                if  cr.SECONDARY_DEFAULT_IND is not null then
            --3762750: Using cursor call to avoid multiple parsing
            --Added the assignment for Bug 4096886  -- Anmurali
		   temp := null;
                   OPEN  c_fndlookup_exists('INV_DEFAULTING_UOM_TYPE',cr.SECONDARY_DEFAULT_IND);
	           FETCH c_fndlookup_exists INTO temp;
	           CLOSE c_fndlookup_exists;
		   IF temp IS NULL THEN
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_DEFAULT_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
		   end if;
                end if;
                if cr.SECONDARY_UOM_CODE is not null THEN
                  BEGIN
                    select UNIT_OF_MEASURE into temp_u_o_m
                    from MTL_UNITS_OF_MEASURE
                    where UOM_CODE = cr.SECONDARY_UOM_CODE
                     and SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/
                    if(cr.SECONDARY_UOM_CODE  = cr.PRIMARY_UOM_CODE ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_PRIMARY_SEC_UOM_SAME',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                   end if;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                         dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
                         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
                         'SECONDARY_UOM_CODE',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_ATTR_COL_VALUE',
                         err_text);
                         IF dumm_status < 0 THEN
                           RAISE LOGGING_ERR;
                         END IF;
                         status := 1;
                  END;
                end if;

        --If tracking is set to Primary and pricing is set to Secondary, then
        --Defaulting can be set to either Default or No Default.
                if  (nvl(cr.TRACKING_QUANTITY_IND,'P') = 'P'
                    and (nvl(cr.ONT_PRICING_QTY_SOURCE,'P') = 'S'
                    and nvl(cr.SECONDARY_DEFAULT_IND,'F') = 'F')) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_DEFAULT_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SEC_DEFULT_IS_FIXED',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                if  (nvl(cr.TRACKING_QUANTITY_IND,'P') = 'P'
                 and nvl(cr.ONT_PRICING_QTY_SOURCE,'P') = 'P') then
                   if(cr.SECONDARY_DEFAULT_IND IS NOT NULL ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_DEFAULT_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SEC_DEFAULT_NOT_NULL',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                   end if;
                   if(cr.SECONDARY_UOM_CODE  IS NOT NULL ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SEC_UOM_IS_NOT_NULL',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                  end if;
                end if;
                if ( (cr.SECONDARY_DEFAULT_IND IS NULL OR cr.SECONDARY_DEFAULT_IND NOT IN('D','N'))--Bug:3574973
                     and (cr.DUAL_UOM_DEVIATION_HIGH <> 0
                        or cr.DUAL_UOM_DEVIATION_LOW <> 0))then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DUAL_UOM_DEVIATION_HIGH',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_UOM_DEV_IS_NOT_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
             -- Required values check
               if ( (nvl(cr.TRACKING_QUANTITY_IND,'P') = 'PS'
                  or nvl(cr.ONT_PRICING_QTY_SOURCE,'P') = 'S')
                  and cr.SECONDARY_UOM_CODE IS NULL) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_REQUIRED_FIELDS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
               if ( (nvl(cr.TRACKING_QUANTITY_IND,'P') = 'PS'
                  or nvl(cr.ONT_PRICING_QTY_SOURCE,'P') = 'S')
                  and cr.SECONDARY_DEFAULT_IND IS NULL) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_DEFAULT_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_REQUIRED_FIELDS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
                if ( NVL(cr.DUAL_UOM_DEVIATION_HIGH,-1) < 0
                    or NVL(cr.DUAL_UOM_DEVIATION_LOW,-1) < 0) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DUAL_UOM_DEVIATION_FACTORS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_POSITIVE_NUMBER',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                /* Jalaj Srivastava Bug 5017588
                   secondary uom class should be same across all orgs*/
                --{
                if  cr.SECONDARY_UOM_CODE is not null THEN
                        begin
                                select UOM_CLASS
                                into   temp_uom_class
                                from   MTL_UNITS_OF_MEASURE
				where  UOM_CODE = cr.SECONDARY_UOM_CODE;

                                select 'x' into temp
                                from   MTL_SYSTEM_ITEMS msi
                                 where INVENTORY_ITEM_ID = cr.INVENTORY_ITEM_ID
                                 and   secondary_uom_code IS NOT NULL
                                 and   not exists (select UNIT_OF_MEASURE
                                                   from   MTL_UNITS_OF_MEASURE MUOM
                                                   where  UOM_CLASS  = temp_uom_class
                                                   and MUOM.UOM_CODE = msi.SECONDARY_UOM_CODE)
                                 and   rownum = 1;

                              /* If any rows are fetched here then it is invalid
                              **   Call the error routine
                              **   else goto the exception and exit this validation
                              **   succesfully.
                              */

                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SECONDARY_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SEC_UOM_MISMATCH_CLASS',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;

                        exception
                                when NO_DATA_FOUND then
                                 /*Do nothing. Valid data */
                                 null;
                        end;
                end if;--}

  END IF;--}
                        /* Start Bug 3713912 */
 		        if  (cr.TRACKING_QUANTITY_IND <> 'P'
 		             and nvl(cr.SERIAL_NUMBER_CONTROL_CODE,1) <> 1) then
			   dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'TRACKING_QUANTITY_IND',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_TRACKING_QTY_IND',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;

                        end if;
                        /* End Bug 3713912 */
stmt := 34;
                -- Start : 2339789: Dimension UOM code validation
                -- validate foreign keys
                if  cr.DIMENSION_UOM_CODE is not null then
                        begin
                                select 'x' into temp
                                from MTL_UNITS_OF_MEASURE
                                where UOM_CODE = cr.DIMENSION_UOM_CODE;
                        exception
                            when NO_DATA_FOUND then
                             dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DIMENSION_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_DIMENSION_UOM_CODE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;
                -- End : 2339789
stmt := 36;
                /* NP26DEC94 : New code to update process_flag.
                ** This code necessiated due to the breaking up INVPVHDR into
                ** 6 smaller packages to overcome PL/SQL limitations with code size.
                ** Let's update the process flag for the record
                ** Give it value 42 if all okay and 32 if some validation failed in this procedure
                ** Need to do this ONLY if all previous validation okay.
                ** The process flag values that are possible at this time are
                ** 31, 41 :set by INVPVHDR
                ** 32, 42 :set by INVPVDR2
                ** 33, 43 :set by INVPVDR3
                ** 34, 44 :set by INVPVDR4
                */

		/* Bug 4705184
                select process_flag into temp_proc_flag
                  from MTL_SYSTEM_ITEMS_INTERFACE
                where inventory_item_id = l_item_id
                and   set_process_id + 0 = xset_id
                and   process_flag in (31, 32, 33, 34, 44)
                and   organization_id = cr.organization_id
                and   rownum < 2; */

                /* set value of process_flag to 45 or 35 depending on
                ** value of the variable: status.
                ** Essentially, we check to see if validation has not already failed in one of
                ** the previous packages.
                */
               if   (temp_proc_flag <> 31 and temp_proc_flag <> 32
                 and temp_proc_flag <> 33 and temp_proc_flag <> 34) then
                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = DECODE(status,0,45,35),
                            PRIMARY_UOM_CODE = cr.primary_uom_code,
                            primary_unit_of_measure = cr.primary_unit_of_measure
                        where inventory_item_id = l_item_id
                        -- and   set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id = xset_id
                        and   process_flag = 44
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
                err_text := substr('INVPVALI.validate_item_header5' || SQLERRM , 1, 240);
                return(SQLCODE);

end validate_item_header5;

end INVPVDR5;

/
