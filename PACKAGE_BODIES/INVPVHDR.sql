--------------------------------------------------------
--  DDL for Package Body INVPVHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVHDR" as
/* $Header: INVPVD1B.pls 120.13.12010000.9 2009/12/17 02:45:54 kaizhao ship $ */

g_max_segment         number := NULL;
g_totalsegs           number := NULL;
g_segment_delimiter   varchar2(10)  := NULL;

--bug 8478315
g_null_item_number 		varchar2(100) := NULL;

function validate_item_header
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
	 ITEM_NUMBER,
	 TRANSACTION_ID,
	 ORGANIZATION_ID,
	 ORGANIZATION_CODE,
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
--	 SERVICE_ITEM_FLAG,
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
--	 VENDOR_WARRANTY_FLAG,
--	 SERVICEABLE_COMPONENT_FLAG,
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
	 RELEASE_TIME_FENCE_CODE, /*NP 19AUG96 Eight new cols added for 10.7 */
	 RELEASE_TIME_FENCE_DAYS,
	 CONTAINER_ITEM_FLAG,
	 CONTAINER_TYPE_CODE,
	 INTERNAL_VOLUME,
	 MAXIMUM_LOAD_WEIGHT,
         MINIMUM_FILL_PERCENT,
         VEHICLE_ITEM_FLAG,
         CHECK_SHORTAGES_FLAG,  /*CK 21MAY98 Added new attribute*/
         INDIVISIBLE_FLAG,
         CONTRACT_ITEM_TYPE_CODE,
       --Adding attributes now updateable for Pending items R12 C
         DIMENSION_UOM_CODE,
         UNIT_LENGTH,
	 UNIT_WIDTH,
	 UNIT_HEIGHT
	from MTL_SYSTEM_ITEMS_INTERFACE
	where ((organization_id = org_id) or -- fix for bug#8757041,removed + 0
	       (all_Org = 1))
        and   set_process_id  = xset_id
	and   process_flag = 2;

        -- Bug: 4654433
        CURSOR get_organization_code (cp_org_id VARCHAR2) IS
	SELECT
	   name
        FROM hr_organization_units
        WHERE organization_id = cp_org_id;

        CURSOR is_gdsn_batch(cp_xset_id NUMBER) IS
          SELECT 1 FROM ego_import_option_sets
           WHERE batch_id = cp_xset_id
             AND enabled_for_data_pool = 'Y';
	/*
	** Items have the same key segment values must have the same item id
        ** NP 13-OCT-94 Comment
        ** The cursor dd1 has largely been obsoleted by the TWO_PASS design
        ** Because of the two pass design an item will always find its
        ** inventory item id from the master, since we insert an item
        ** in  master org
        ** in the first pass (before the insertion into the child org).
        ** However it performs ONE very important task:
        ** It allows you to insert an item in more than one MASTER org
        ** in the same FIRST pass
        ** and it ensures that they all get the same InvItemId
        ** (which has to be constant across ALL orgs)
        ** Following cursor now being replaced by Dyn SQL 2
        **		CURSOR dd1 (seg1 varchar2,seg2 varchar2,seg3 varchar2,
        **		blah blah...
        **	seg17 varchar2,seg18 varchar2,
        **                 seg19 varchar2,seg20 varchar2,
	**		item_id_in number) is
	**	select inventory_item_id,
	**	       transaction_id,
	**	       organization_id
	**	from MTL_SYSTEM_ITEMS_INTERFACE
	**	where inventory_item_id <> item_id_in
	**	and   set_process_id    = nvl(xset_id, set_process_id)
	**	and   nvl(segment1,'.') = nvl(seg1,'.')
	**	and   nvl(segment2,'.') = nvl(seg2,'.')
	**	and so on so forth...
	**	and   nvl(segment20,'.') = nvl(seg20,'.');
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
	error_msg		varchar2(400);
	status			number;
	dumm_status		number;
	master_org_id		number;
	stmt			number;
	LOGGING_ERR		exception;
	VALIDATE_ERR		exception;
        lot_num_generation_val  number;   /*NP 21DEC94*/
        ser_num_generation_val  number;   /*NP 21DEC94*/
	is_master_org           number ;
        no_of_masterorgs        number ;
	org_name                varchar2(240);

        /* Dynamic SQL variables*/

        type BindVarType is table of varchar2(80) index by binary_integer;
        type BindValType is table of varchar2(80) index by binary_integer;
        type NumType     is table of number       index by binary_integer;

        bindvars1               BindVarType;
        bindvals1               BindValType;

        SEG_TAB                 NumType;
        segnum_temp             varchar2(2);
        max_segment             number;
        return_status           number;
        pos                     number;
        ind                     number;
        segnum                  number := NULL;
        totalsegs               number;

        DSQL_inventory_item_id  number; /*dynamic sql column*/
        DSQL_count_star         number; /*dynamic sql column*/
	DSQL2_inventory_item_id number;
	DSQL2_transaction_id    number;
	DSQL2_organization_id   number;
        DSQL_statement1         varchar2(3000);
        DSQL_statement2         varchar2(3000);
        DSQL_statement3         varchar2(3000);
        DSQL_statement4         varchar2(3000);
        DSQL_c1                 integer; /*pointer to dynamic SQL cursor*/
        DSQL_c2                 integer; /*pointer to dynamic SQL cursor*/
        DSQL_c3                 integer; /*pointer to dynamic SQL cursor*/
        DSQL_c4                 integer; /*pointer to dynamic SQL cursor*/
        statement_temp1         varchar2(2000) := NULL;
        statement_temp2         varchar2(2000) := NULL;
        statement_temp3         varchar2(2000) := NULL;
        statement_temp4         varchar2(2000) := NULL;
        err_temp                varchar2(1000) := NULL;
        DSQL_rows_processed     integer;
        transaction_id_bind     integer;
        dummy_ret_code          integer;
        l_application_id number(10) :=  401;
        l_id_flex_code  varchar2(4) := 'MSTK';
        l_enabled_flag  varchar2(1) := 'Y';
        l_id_flex_num   number(15)  := 101;
        l_dummy         varchar2(50);
	l_seg_size      number      := 0;
	l_uppercase_flag	varchar2(1) ;
	l_msg_name              VARCHAR2(1000) := NULL;
	l_start_auto_lot_num    mtl_system_items_b.START_AUTO_LOT_NUMBER%TYPE;

        --2967569 : Required Segments check
	l_segment_required      NUMBER(10):=0;
	l_required_flag varchar2(1) := 'Y';

	--3360280:KFV validation using fnd_flex_keyval
	l_valid_segments        BOOLEAN := FALSE;
	l_item_number           mtl_system_items_interface.item_number%TYPE;
	l_deliminator_count     NUMBER(10) := 0;
	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
	l_col_name              VARCHAR2(100);
   l_is_gdsn_batch          NUMBER;

begin



/**** Begin section for dynamic sql bind variables*/

for n in 1..20 loop
   SEG_TAB(n) := NULL;
end loop;

IF g_max_segment IS NULL THEN
   select max(FS.segment_num)
   into g_max_segment
   from FND_ID_FLEX_SEGMENTS FS
   where FS.APPLICATION_ID = l_application_id
   and   FS.id_flex_code   = l_id_flex_code
   and   FS.ENABLED_FLAG   = l_enabled_flag
   and   FS.id_flex_num    = l_id_flex_num;
END IF;

max_segment := g_max_segment;

IF g_totalsegs IS NULL THEN
   select count(*) into  g_totalsegs
   from FND_ID_FLEX_SEGMENTS FS
   where FS.APPLICATION_ID = l_application_id
   and FS.id_flex_code     = l_id_flex_code
   and FS.ENABLED_FLAG     = l_enabled_flag
   and FS.id_flex_num      = l_id_flex_num;
 END IF;

totalsegs := g_totalsegs;

IF g_segment_delimiter IS NULL THEN
   select concatenated_segment_delimiter
   into g_segment_delimiter
   from fnd_id_flex_structures
   where id_flex_code   = l_id_flex_code
   and   APPLICATION_ID = l_application_id
   and   ID_FLEX_NUM    = l_id_flex_num;
END IF;

pos := 1;
ind := 1;

for n in 1..max_segment loop
   begin
    /* NP 05SEP96 changed this select FS.segment_num
    ** to match the changes made in INVPUL1B.pls get_dynamic_sql_str
    */
    select  to_number(substr(FS.application_column_name, 8))
	   into segnum
       from FND_ID_FLEX_SEGMENTS FS
	where FS.SEGMENT_NUM = n
	and   FS.ID_FLEX_CODE = l_id_flex_code
	and   FS.ID_FLEX_NUM = l_id_flex_num
	and   FS.ENABLED_FLAG = l_enabled_flag
	and   FS.APPLICATION_ID = l_application_id;
   exception
	when NO_DATA_FOUND then
		segnum := NULL;
	when OTHERS then
		raise_application_error(-20001, SQLERRM);
   end;

   if segnum is not NULL then
	SEG_TAB(ind) := segnum;
	ind := ind + 1;
   end if;
end loop;

/* This dynamic sql is trying to create entries in plsql tables
** bindvarsX   bindvalsX
** to facilitate the dynamic binding of variables: For example:
** dbms_sql.bind_variable(DSQL_c1, 'cr_segment1_bind', cr.segment1);
** The code fragment here mimics the code in INVPUTLI.get_dynamic_sql_str()
*/

for n in 1..totalsegs loop
   segnum_temp := to_char(SEG_TAB(n));
   bindvars1(n) := 'cr_segment'||segnum_temp||'_bind';
end loop;

--bug 8478315
g_null_item_number := NULL;
for n in 1..totalsegs-1 loop
	g_null_item_number := g_null_item_number||g_segment_delimiter;
end loop;
/* Call the function to dynamically build the where clause */
dummy_ret_code := INVPUTLI.get_dynamic_sql_str(2, statement_temp1,
							      err_temp);
/* The same where clause is needed for the 1st
** and 3rd dynamic sql statements in this package
*/
statement_temp3 := statement_temp1;

err_temp := NULL;
dummy_ret_code := INVPUTLI.get_dynamic_sql_str(3, statement_temp4,
                                                              err_temp);
/* The same where clause is needed for the 2nd and 4th
** dynamic sql statements in this package
*/
statement_temp2 := statement_temp4;


/*
** End section for dynamic sql bind variables
*/

error_msg := 'Validation error in validating MTL_SYSTEM_ITEMS_INTERFACE with ';

/*
** validate the records
*/
	for cr in cc loop
		status := 0;
		trans_id := cr.transaction_id;
		l_org_id := cr.organization_id;
		l_item_id := cr.inventory_item_id;

		/*
		** Since the item_id might be changed
                ** in this code when segments match etc.,
                ** get the current one
		*/

	     /* Bug 4705184. Get item id from the cursor. At this point there is no change in item id.
	        select inventory_item_id
		into l_item_id
		from mtl_system_items_interface
		where transaction_id = cr.transaction_id
                and   set_process_id = xset_id ; */

                /* Put in the values of cr.segmentX in the right
                ** place in the bindvals1 table
                ** The bindvars1 table has already been populated
                ** outside the cursor scope because it will remain constant.
                ** The bindvals1 table will have different entries depending
                ** on the cursor record cr
                */

		for n in 1..totalsegs loop
		   segnum_temp := to_char(SEG_TAB(n));

                   if    (segnum_temp = 1) then
		     bindvals1(n) := cr.segment1;
                   elsif (segnum_temp = 2) then
		     bindvals1(n) := cr.segment2;
                   elsif (segnum_temp = 3) then
		     bindvals1(n) := cr.segment3;
                   elsif (segnum_temp = 4) then
		     bindvals1(n) := cr.segment4;
                   elsif (segnum_temp = 5) then
		     bindvals1(n) := cr.segment5;
                   elsif (segnum_temp = 6) then
		     bindvals1(n) := cr.segment6;
                   elsif (segnum_temp = 7) then
		     bindvals1(n) := cr.segment7;
                   elsif (segnum_temp = 8) then
		     bindvals1(n) := cr.segment8;
                   elsif (segnum_temp = 9) then
		     bindvals1(n) := cr.segment9;
                   elsif (segnum_temp = 10) then
		     bindvals1(n) := cr.segment10;
                   elsif (segnum_temp = 11) then
		     bindvals1(n) := cr.segment11;
                   elsif (segnum_temp = 12) then
		     bindvals1(n) := cr.segment12;
                   elsif (segnum_temp = 13) then
		     bindvals1(n) := cr.segment13;
                   elsif (segnum_temp = 14) then
		     bindvals1(n) := cr.segment14;
                   elsif (segnum_temp = 15) then
		     bindvals1(n) := cr.segment15;
                   elsif (segnum_temp = 16) then
		     bindvals1(n) := cr.segment16;
                   elsif (segnum_temp = 17) then
		     bindvals1(n) := cr.segment17;
                   elsif (segnum_temp = 18) then
		     bindvals1(n) := cr.segment18;
                   elsif (segnum_temp = 19) then
		     bindvals1(n) := cr.segment19;
                   elsif (segnum_temp = 20) then
		     bindvals1(n) := cr.segment20;
                   end if;

		end loop;  /* Finished populating the bindvals1() plsql table*/

		 --Start 3360280:KFV validation using fnd_flex_keyval
		  --bug8478315, if cr.item_number contains only segment delimiters, re-populate item_number
		  if cr.item_number IS NULL or  cr.item_number = g_null_item_number then
                    dumm_status := INVPUOPI.mtl_pr_parse_item_segments
                       (p_row_id      => cr.rowid
                       ,item_number   => l_item_number
                       ,item_id       => l_item_id
                       ,err_text      => err_text);

		    --Bug: 5512333
		    if cr.item_number IS NOT NULL THEN
		       dumm_status := INVPUOPI.mtl_pr_parse_item_number(l_item_number
		                                                       ,cr.inventory_item_id
								       ,cr.transaction_id
								       ,cr.organization_id
								       ,err_text
								       ,cr.rowid);
                       if dumm_status < 0 THEN
		          status := 1;
			  dumm_status := INVPUOPI.mtl_log_interface_err(
			                   cr.organization_id
					  ,user_id
					  ,login_id
					  ,prog_appid
					  ,prog_id
					  ,request_id
					  ,cr.transaction_id
					  ,error_msg
					  ,null
					  ,'MTL_SYSTEM_ITEMS_INTERFACE'
					  ,'BOM_PARSE_ITEM_ERROR'
					  ,err_text);
		          if dumm_status < 0 then
			     raise LOGGING_ERR;
			  end if;
		       end if;
		    end if;
		    --End Bug: 5512333
                 else
                    l_item_number := cr.item_number;
		 end if;

                 --Start 3610290: Item number should have deliminator
		 /*If one+ segments are enabled irrespective of required
		   or not fnd_flex_keyval.validate_segs expects item number
		   to be passed in segment1.segment..*/

		 l_deliminator_count := 0;
		 IF totalsegs > 1 THEN
                    WHILE l_deliminator_count < totalsegs -1 LOOP
                       SELECT INSTR(l_item_number,g_segment_delimiter,1,totalsegs -1)
		       INTO l_deliminator_count FROM DUAL;
		       IF l_deliminator_count < totalsegs -1 THEN
		          l_item_number := l_item_number ||g_segment_delimiter;
		       END IF;
		    END LOOP;
		 END IF;
                 --End 3610290: Item number should have deliminator

		 l_valid_segments := fnd_flex_keyval.validate_segs
                         (operation         =>'CHECK_SEGMENTS',
                          appl_short_name   => 'INV',
                          key_flex_code     => 'MSTK',
		          structure_number  => 101,
		          concat_segments   => l_item_number,
				  values_or_ids     => 'I'); --bug 9172582, from FND team's suggestion, we append the new parameter 'values_or_ids'

                 IF NOT l_valid_segments THEN
                    status := 1;
                    dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                substr(FND_FLEX_KEYVAL.error_message,1,239),
                                'ITEM_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
                 ELSE
                 --Bug: 5200023 Added the ELSE BLOCK
		    IF l_item_number <> fnd_flex_keyval.concatenated_ids THEN --bug 9172582, from FND team's suggestion, we use 'fnd_flex_keyval.concatenated_ids' instead of 'fnd_flex_keyval.concatenated_values'

		       /*Following Condition is added for Bug 8588151.This Condition is set because When ItemNumber is
                         not having the Escape Char for \ It happens when we do item updation from WebADI.*/
                       IF  NOT (InStr(l_item_number,'\') <>0  AND
                                 (Translate(fnd_flex_keyval.concatenated_values,'#\','\') = Translate(l_item_number,'#\','\'))) THEN
                           status := 1;
                           FND_MESSAGE.SET_NAME ('INV', 'INV_ITEM_SEGMENTS_INVALID');
                           FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', l_item_number);
                           error_msg := FND_MESSAGE.GET;

                         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ITEM_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
		      END IF;
		    END IF;
		 END IF;
                 --End 3360280:KFV validation using fnd_flex_keyval


		/*
		** For any two items have the same key segment values,
	        ** ensure that they have the same item id
                ** 08-APR-96 This code now completely rewritten using
                ** dynamic sql.
	    ** 04SEP96 To remove full table scan on msi by using the msi index
	    ** on org_id and segment(s), add a (dummy) join to mtl_parameters
	    ** The + 0 has been put in so the mtl_parameters index is not used
		*/
	 select count(*)
           into is_master_org
         from mtl_parameters
         where organization_id = cr.organization_id
           and master_organization_id = cr.organization_id ;

	 If (is_master_org = 1) then
                select count(*)
                into no_of_masterorgs
                from mtl_parameters
                where organization_id = master_organization_id ;

           If (no_of_masterorgs > 1) then
		BEGIN  /* PLSQL Block1 */
		   IF l_inv_debug_level IN(101, 102) THEN
                      INVPUTLI.info('INVPVHDR: stmt0 latest');
		   END IF;

   /* removed + 0 from where condition
   and clause of organization_id to fix bug 7459820 with base bug 7003119 */
                 DSQL_statement1 := 'select distinct msi.inventory_item_id
                                       from mtl_system_items msi,
                                            mtl_parameters mp
                                      where msi.organization_id <>
                                                        :organization_id_bind
                             and msi.inventory_item_id <> :l_item_id_bind
                             and msi.organization_id = mp.organization_id
                             and ' || statement_temp1;



                /* statement_temp1 is from call to get_dyn_sql_stmt
                ** organization_id_bind gets cr.organization_id
                ** l_item_id_bind gets l_item_id
                ** Now, open cursor DSQL_c1, parse it and bind the variables
                */

                DSQL_c1 := dbms_sql.open_cursor;
                dbms_sql.parse(DSQL_c1, DSQL_statement1, dbms_sql.native);
                dbms_sql.define_column(DSQL_c1, 1, DSQL_inventory_item_id);
                dbms_sql.bind_variable(DSQL_c1, 'organization_id_bind',
                                                   cr.organization_id);
                dbms_sql.bind_variable(DSQL_c1, 'l_item_id_bind', l_item_id);

		/* The following is to facilitate the dynamic binding
                ** of the where clause variables:
		** dbms_sql.bind_variable(DSQL_c1,
                **                    'cr_segment1_bind', cr.segment1);
                ** The PL/SQL tables bindvars1 and bindvals1 have alreadey
                ** been populated before.
		*/

		for n in 1..totalsegs loop
                 BEGIN
		    IF l_inv_debug_level IN(101, 102) THEN
		       INVPUTLI.info('INVPVHDR: BIND values ' ||
                                       bindvars1(n)||' gets '|| bindvals1(n));
		    END IF;

                  dbms_sql.bind_variable(DSQL_c1, bindvars1(n), bindvals1(n) );

                 EXCEPTION
                  when others then
                  err_text:= substr('validate_item_header DSQL 1'|| SQLERRM, 1, 240);
                  return(SQLCODE);

                 END;
		end loop;


                Begin
                 DSQL_rows_processed := dbms_sql.execute(DSQL_c1);
                Exception
                 when others then
                  err_text:= substr('validate_item_header DSQL 2'|| SQLERRM , 1, 240) ;
                  return(SQLCODE);
                End;

                /*NP 10-APR-95
		**This is the code that is being replaced by dynamic sql
		**select distinct inventory_item_id
		**into dup_item_id
		**from mtl_system_items msi
		**where
		**msi.organization_id <> cr.organization_id
		**and msi.inventory_item_id <> l_item_id
		**and segment1 = nvl(cr.segment1,'.');
		**and segment2 = nvl(cr.segment2,'.') .........
		**and so on so forth : Now with dynamic SQL, only the
                **relevant portions of the where clause are activated
                **depending on which segments
		**of the system_item flexfield have been enabled
      	        */

                /*
                ** Note that we are not going to loop here
                ** over the cursor DSQL_c1, as is traditionally done.
                ** Because we expect just one row at most to be
                ** returned from the MSI table because of the distinct
                ** clause
                */

              if dbms_sql.fetch_rows(DSQL_c1) > 0 then /* BIG If*/

                  Begin
                    dbms_sql.column_value(DSQL_c1,1,DSQL_inventory_item_id);

                    dup_item_id :=  DSQL_inventory_item_id;

		    update mtl_system_items_interface
		    set inventory_item_id = dup_item_id
		    where transaction_id = cr.transaction_id
                    and   set_process_id = xset_id;

		    l_item_id := dup_item_id;

                  Exception
                     When NO_DATA_FOUND then NULL;
                     When OTHERS then
                                err_text := substr('CK_DU_ISEG:' || SQLERRM , 1, 240);
                                status := SQLCODE;
                                raise VALIDATE_ERR;
                  End;

              else /*The cursor DSQL_c1 fetched no rows at all*/
                dbms_sql.close_cursor(DSQL_c1);
		IF l_inv_debug_level IN(101, 102) THEN
		   INVPUTLI.info('INVPVHDR: entering DSQL2 ');
		END IF;

	        /* This else clause simulates the earlier
	        ** exception when NO_DATA_FOUND then
	        ** clause
	        ** Now close that DSQL_c1 cursor and
	        ** do the processing for items is multiple
	        ** masters case
	        */

               BEGIN /*Dyn SQL BLOCK 2*/
                /*NP 30AUG96 This statement has been identified as being
                **a big resource hog, because of nvl to nvl
                **comparison in statement_temp2
	        ** 04SEP96 To remove full table scan on msii by using the
		** msii index on org_id and segment(s), add a (dummy)
		** join to mtl_parameters The + 0 has been put in so
		** the mtl_parameters index is not used
                */

   /* removed + 0 from where condition
   and clause of organization_id to fix bug 7459820 with base bug 7003119 */
                DSQL_statement2 := ' select msii.inventory_item_id,
                                            msii.transaction_id,
                                            msii.organization_id
                                    from mtl_system_items_interface msii,
                                         mtl_parameters mp
                                   where msii.inventory_item_id <>
                                                          :l_item_id_bind
                        and set_process_id = :xset_id_bind
                        and msii.organization_id = mp.organization_id
                        and ' || statement_temp2;

                DSQL_c2 := dbms_sql.open_cursor;
                dbms_sql.parse(DSQL_c2, DSQL_statement2, dbms_sql.native);
                dbms_sql.define_column(DSQL_c2, 1, DSQL2_inventory_item_id);
                dbms_sql.define_column(DSQL_c2, 2, DSQL2_transaction_id);
                dbms_sql.define_column(DSQL_c2, 3, DSQL2_organization_id);
                dbms_sql.bind_variable(DSQL_c2, 'l_item_id_bind', l_item_id);
                dbms_sql.bind_variable(DSQL_c2, 'xset_id_bind', xset_id);

                for n in 1..totalsegs loop
                 BEGIN
		    IF l_inv_debug_level IN(101, 102) THEN
		       INVPUTLI.info('INVPVHDR: BIND2 values ' ||
                                        bindvars1(n)||' gets '|| bindvals1(n));
		    END IF;

                  dbms_sql.bind_variable(DSQL_c2, bindvars1(n), bindvals1(n) );
                 EXCEPTION
                  when others then
                  err_text:= substr('validate_item_header DSQL 2'|| SQLERRM , 1, 240);
                  return(SQLCODE);
                 END;
                end loop;

                begin
                 DSQL_rows_processed := dbms_sql.execute(DSQL_c2);
                exception
                  when others then
                  err_text:= substr('validate_item_header DSQL 2.2'|| SQLERRM , 1, 240);
                  return(SQLCODE);
                end;

	        loop
	          if dbms_sql.fetch_rows(DSQL_c2) > 0 then
			dbms_sql.column_value(DSQL_c2, 1, DSQL2_inventory_item_id);
			dbms_sql.column_value(DSQL_c2, 2, DSQL2_transaction_id);
			dbms_sql.column_value(DSQL_c2, 3, DSQL2_organization_id);


			    /* update item header with new item id
			    ** This is for updating the III for similar
			    ** segment items
			    ** going to different master orgs
			    ** Child items will not enter this NO DATA FOUND
			    ** clause because
			    ** the TWO_PASS design ensures that item WILL be
			    ** found in masterorg in MSI*/
			    IF l_inv_debug_level IN(101, 102) THEN
		               INVPUTLI.info('INVPVHDR: Same item being added to MULTIPLE masters ');
	                       INVPUTLI.info('INVPVHDR: So now updating inv_item_id in MSII, MIRI ');
                            END IF;
			    update mtl_system_items_interface
			    set inventory_item_id = l_item_id
			    where transaction_id = DSQL2_transaction_id
                            and   set_process_id = xset_id;


                            /* 09-APR-96 Added update to MIRI
                            ** because if the inv_item_id is being
                            ** changed in MSII
                            ** it should also be changed in MIRI and MICI
                            ** otherwise there will be dangling
                            ** references that will
                            ** be flagged as errors in mtl_interface_errors
                            ** Also do so only where the org ids don't match
                            ** since now the iii will be same we definitely
                            ** don't want to do it for a record with same
                            ** orgs: it will be a violation
                            ** This violation WILL be caught elsewhere
                            ** on checking that similar segs don't have
                            ** same org in msii (duplicate record)
                            **
                            **Also,the following not needed since categories INSERT
                            **takes place much later..so no point in updating.
                            **update mtl_item_categories_interface
                            **set inventory_item_id = l_item_id
                            **where inventory_item_id = DSQL2_inventory_item_id;
                            ** 06/18/97 Changed below
			    ** and organization_id <> DSQL2_organization_id
                            ** will ensure that the inventory_item_id
                            ** is updated correctly in MIRI. The <> is
                            ** changed to equals.
                            */

			    update mtl_item_revisions_interface
                            set inventory_item_id = l_item_id
                            where inventory_item_id = DSQL2_inventory_item_id
                            and organization_id = DSQL2_organization_id
                            -- and   set_process_id + 0 = xset_id; -- fix for bug#8757041,removed + 0
                            and   set_process_id = xset_id;

                    else
		            -- no more rows, Close cursor and exit
			    dbms_sql.close_cursor(DSQL_c2);
			    exit;
		    end if;
                   end loop;
		  EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			   if dbms_sql.is_open(DSQL_c2) then
			    dbms_sql.close_cursor(DSQL_c2);
			   end if;
		      WHEN OTHERS THEN
			  if dbms_sql.is_open(DSQL_c2) then
			    dbms_sql.close_cursor(DSQL_c2);
			  end if;
			  err_text:= substr('validate_item_header DSQL STMT2 '|| SQLERRM , 1,240) ;
			  return(SQLCODE);
		  END; /*PLSQL Block 2 (inside block 1)*/


                end if; /*BIG if from BLOCK 1*/

                   if dbms_sql.is_open(DSQL_c1) then
                      dbms_sql.close_cursor(DSQL_c1);
                   end if;

             EXCEPTION

              WHEN NO_DATA_FOUND THEN
                   if dbms_sql.is_open(DSQL_c1) then
                    dbms_sql.close_cursor(DSQL_c1);
                   end if;
              WHEN OTHERS THEN
                  if dbms_sql.is_open(DSQL_c1) then
                    dbms_sql.close_cursor(DSQL_c1);
                  end if;
                  err_text:= substr('validate_item_header DSQL STMT1'|| SQLERRM , 1,240);
                  return(SQLCODE);

             END; /*PLSQL Block 1 (This block also contains the PL/SQL Block2)*/
	   END IF;
         END IF;

		/*
		** Check for uniqueness of INVENTORY_ITEM_ID and
		**	ORGANIZATION_ID.
		*/
stmt := 1;

		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVHDR: check 3-1');
		END IF;

		select count(*)
		into ext_flag
		from MTL_SYSTEM_ITEMS_B
		where inventory_item_id = l_item_id
		and   organization_id = cr.organization_id
                and   cr.transaction_type = 'CREATE';
		IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVHDR: check 3-1');
		END IF;

stmt := 2;
		if ext_flag > 0 then
                    -- Bug: 4654433
		    Open get_organization_code(cr.organization_id);
		    Fetch get_organization_code Into org_name;
		    Close get_organization_code;
		    org_name := NVL(org_name, cr.organization_code);
		    status := 1;
stmt := 3;

                    FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_DUPLICATE_ITEM_MSI');
                    FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', cr.item_number);
                    FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
                    error_msg := FND_MESSAGE.GET;
		    dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ITEM_ID',
                               'MTL_SYSTEM_ITEMS_INTERFACE',
                               'INV_IOI_ERR',
				err_text);
			if dumm_status < 0 then
				raise LOGGING_ERR;
			end if;
		else
stmt := 4;
		    select count(*)
                    into ext_flag
                    from MTL_SYSTEM_ITEMS_INTERFACE
                    where inventory_item_id = l_item_id
                    and   organization_id = cr.organization_id
                    and  process_flag = 2
                    and   set_process_id  = xset_id;
                    IF l_inv_debug_level IN(101, 102) THEN
	               INVPUTLI.info('INVPVHDR: check 4-1');
		    END IF;

          if ext_flag > 1 then
stmt := 5;
            --Bypassing validation for GDSN batches
            l_is_gdsn_batch := 0;
            Open  is_gdsn_batch(xset_id);
            Fetch is_gdsn_batch INTO l_is_gdsn_batch;
            Close is_gdsn_batch;

            if l_is_gdsn_batch <> 1 then
                       -- Bug: 4654433
		        Open  get_organization_code(cr.organization_id);
		        Fetch get_organization_code Into org_name;
		        Close get_organization_code;
		        org_name := NVL(org_name, cr.organization_code);
                      status := 1;
		      --Bug: 4777089 Flagging INV_IOI_DUPLICATE_REC_MSII in place of INV_IOI_DUPLICATE_ITEM_MSI
                      FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_DUPLICATE_REC_MSII');
                      FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', cr.item_number);
                      FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
                      error_msg := FND_MESSAGE.GET;
		        dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVENTORY_ITEM_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
			 	                    err_text);
                        if dumm_status < 0 then
                                raise LOGGING_ERR;
                        end if;
            end if; --Not GDSN Batch
		    end if;
		end if;

		/*
		** Check for uniqueness of combination of key segment values
		** 	and organization id
		*/
stmt := 6;
            IF l_inv_debug_level IN(101, 102) THEN
               INVPUTLI.info('INVPVHDR: stmt6');
	    END IF;
            BEGIN /* PLSQL Block 2*/

                DSQL_statement3 := 'select count(*)
				from MTL_SYSTEM_ITEMS msi
				where organization_id = :organization_id_bind
				and :transaction_type_bind = ''CREATE''
                                and ' || statement_temp3;

                DSQL_c3 := dbms_sql.open_cursor;
                dbms_sql.parse(DSQL_c3, DSQL_statement3, dbms_sql.native);
                dbms_sql.define_column(DSQL_c3, 1, DSQL_count_star);

                /* Now bind the variables*/
                dbms_sql.bind_variable(DSQL_c3, 'organization_id_bind',
                                                   cr.organization_id);
                dbms_sql.bind_variable(DSQL_c3, 'transaction_type_bind',
                                                    cr.transaction_type);
                /*
                ** The following binding for
                ** DSQL_c3 is exactly the same as for DSQL_c1
                ** since the where clauses happen to be the same
                ** Same bind variables and Bind values, just a different cursor
                */

                for n in 1..totalsegs loop
                 BEGIN
                  dbms_sql.bind_variable(DSQL_c3, bindvars1(n), bindvals1(n) );
                 EXCEPTION
                  when others then
                  err_text:= substr('validate_item_header DSQL 1.1'|| SQLERRM , 1, 240);
                  return(SQLCODE);
                 END;
                end loop;

                BEGIN
                 DSQL_rows_processed := dbms_sql.execute(DSQL_c3);
                EXCEPTION
                  when others then
                  err_text:= substr('validate_item_header DSQL 1.2'|| SQLERRM , 1, 240);
                  return(SQLCODE);
                END;

                ext_flag := 0;
                if dbms_sql.fetch_rows(DSQL_c3) > 0 then
                    dbms_sql.column_value(DSQL_c3,1,DSQL_count_star);
                    ext_flag := DSQL_count_star;
                else
                    dbms_sql.close_cursor(DSQL_c3);
                end if;

                if dbms_sql.is_open(DSQL_c3) then
                    dbms_sql.close_cursor(DSQL_c3);
                end if;


            EXCEPTION
             WHEN OTHERS THEN
                if dbms_sql.is_open(DSQL_c3) then
                 dbms_sql.close_cursor(DSQL_c3);
                end if;
                err_text:= substr('validate_item_header DSQL STMT3'|| SQLERRM , 1,240);
                return(SQLCODE);

            END; /*Plsql block2*/

stmt := 7;

	    IF l_inv_debug_level IN(101, 102) THEN
	       INVPUTLI.info('INVPVHDR: stmt7');
	    END IF;
	    IF ext_flag > 0 AND status=0 THEN  /* Crucial If:*/ --Bug:5208039

		/*
		** There is a record in MSI with same segs and org_id
		** So error this record out
		*/
		-- Bug: 4654433
		Open get_organization_code(cr.organization_id);
		Fetch get_organization_code Into org_name;
		Close get_organization_code;
		org_name := NVL(org_name, cr.organization_code);
		status := 1;

                FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_DUPLICATE_ITEM_MSI');
                FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', cr.item_number);
                FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
                error_msg := FND_MESSAGE.GET;
		dumm_status := INVPUOPI.mtl_log_interface_err(
			cr.organization_id,
			user_id,
			login_id,
			prog_appid,
			prog_id,
			request_id,
			cr.TRANSACTION_ID,
			error_msg,
			'SEGMENTS',
			'MTL_SYSTEM_ITEMS_INTERFACE',
			'INV_IOI_ERR',
			err_text);
			/*NP 08-APR-96 Changed the table to
			**be msi instead of MSI_intf
			*/
		if dumm_status < 0 then
			raise LOGGING_ERR;
		end if;

	    ELSE  /* Check the same for duplicate records in MSII */

               BEGIN /* PLSQL block 3 for dyn sql*/
                stmt := 8;
		/*
                ** Changing following stmt to dynamic sql
		**select count(*)
		**into ext_flag
		**from MTL_SYSTEM_ITEMS_INTERFACE msii
		**where organization_id = cr.organization_id
		**and nvl(msii.segment1, '.') = nvl(cr.segment1,'.');
                **and so on......
                ** intermediate step: ...... = nvl(:cr_segment1_bind, '.')
                ** and so on., and then use dbms_sql.bind_variable to bind the
                ** values to the cursor DSQL_c4
                ** 03MAY96 Added xset_id processing to this dynamic sql stmt.
		*/

                --Bug 8520379: the select is for duplication check, so doesn't need to select count(*) for performance sake
		--DSQL_statement4 := 'select count(*)
		DSQL_statement4 := 'select 1
				from MTL_SYSTEM_ITEMS_INTERFACE msii
				where organization_id = :organization_id_bind
                                and set_process_id = :xset_id_bind
				and  process_flag = 2
                                and ' || statement_temp4;

                DSQL_c4 := dbms_sql.open_cursor;
                dbms_sql.parse(DSQL_c4, DSQL_statement4, dbms_sql.native);
                dbms_sql.define_column(DSQL_c4, 1, DSQL_count_star);
                dbms_sql.bind_variable(DSQL_c4, 'xset_id_bind', xset_id);
                dbms_sql.bind_variable(DSQL_c4, 'organization_id_bind',
                                                   cr.organization_id);

                /*
                ** The following binding for
                ** DSQL_c4 is exactly the same as for DSQL_c1
                ** since the where clauses happen to be the same
                ** Same bind variables and Bind values, just a different cursor
                */

                for n in 1..totalsegs loop
                 begin
                  dbms_sql.bind_variable(DSQL_c4, bindvars1(n), bindvals1(n) );
                 exception
                  when others then
                  err_text:= substr('validate_item_header DSQL 4.1'|| SQLERRM,1,240);
                  return(SQLCODE);
                 end;
                end loop;

                begin
                 DSQL_rows_processed := dbms_sql.execute(DSQL_c4);
                exception
                  when others then
                  err_text:= substr('validate_item_header DSQL 4.2'|| SQLERRM , 1 , 240);
                  return(SQLCODE);
                end;

                ext_flag := 0;
		--Bug 8520379, see description above
		/*
                if dbms_sql.fetch_rows(DSQL_c4) > 0 then
                    dbms_sql.column_value(DSQL_c4,1,DSQL_count_star);
                    ext_flag := DSQL_count_star;

                else
                    dbms_sql.close_cursor(DSQL_c4);
                end if;
                */
		if dbms_sql.fetch_rows(DSQL_c4) > 0 then
                       if dbms_sql.fetch_rows(DSQL_c4) > 0 then
                           ext_flag := 2;
                       end if;
                end if;

                if dbms_sql.is_open(DSQL_c4) then
                    dbms_sql.close_cursor(DSQL_c4);
                end if;

             EXCEPTION
                WHEN OTHERS THEN
                if dbms_sql.is_open(DSQL_c4) then
                    dbms_sql.close_cursor(DSQL_c4);
                 dbms_sql.close_cursor(DSQL_c4);
                end if;
                err_text:= substr('validate_item_header DSQL STMT4'|| SQLERRM , 1,240);
                return(SQLCODE);

             END; /*Plsql block3 for dynamic SQL*/


stmt := 9;
	     if ext_flag > 1 then
			/* That is, there is another row in msii
			** with exactly the same segment and org info
			** Flag as error.
			*/
          l_is_gdsn_batch := 0;
          Open  is_gdsn_batch(xset_id);
          Fetch is_gdsn_batch INTO l_is_gdsn_batch;
          Close is_gdsn_batch;

          if l_is_gdsn_batch <> 1 then
                    -- Bug: 4654433
		      Open get_organization_code(cr.organization_id);
            Fetch get_organization_code Into org_name;
            Close get_organization_code;
            org_name := NVL(org_name, cr.organization_code);
            status := 1;
                    --Bug: 4777089 Flagging INV_IOI_DUPLICATE_REC_MSII in place of INV_IOI_DUPLICATE_ITEM_MSI
                    FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_DUPLICATE_REC_MSII');
                    FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', cr.item_number);
                    FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
                    error_msg := FND_MESSAGE.GET;
		    dumm_status := INVPUOPI.mtl_log_interface_err(
			cr.organization_id,
			user_id,
			login_id,
			prog_appid,
			prog_id,
			request_id,
			cr.TRANSACTION_ID,
			error_msg,
			'SEGMENTS',
			'MTL_SYSTEM_ITEMS_INTERFACE',
			'INV_IOI_ERR',
			err_text);
		     if dumm_status < 0 then
			raise LOGGING_ERR;
		     end if;
         end if; --Not GDSN Batch
	     end if;

	 END IF;  /* Crucial If*/

         -- added following IF condition to fix bug 8827755
         IF cr.description IS NULL THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DESCRIPTION',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DESC_NULL_ITEM_ERROR',
                                err_text);
                 status := 1;
           if dumm_status < 0 then
             raise LOGGING_ERR;
           end if;
         END IF;


    /* R12C Desc Null chk, since check in Defaulting phase is bypassed for func generated ICC catalog items */
    IF cr.description IS NULL THEN
	    dumm_status := INVPUOPI.mtl_log_interface_err(
				                    cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
				                    cr.TRANSACTION_ID,
                                error_msg,
                                'DESCRIPTION',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DESC_ITEM_ERROR',
				                    err_text);
		 status := 1;
       if dumm_status < 0 then
         raise LOGGING_ERR;
       end if;
    END IF;

        /*NP 10-APR-96 End of all performance improving dynamic sql changes*/


	/*
	** Check for integrity rules/restrictions for item attributes
	*/
                /*INVPUTLI.info('INVPVHDR: Validating flags'); */

                -- validate that UOM values exist
                 /*NP 28DEC94 New validation
                 ** if both PRIMARY_UOM_CODE and PRIMARY_UNIT_OF_MEASURE null
                 ** then we have a problem
                 ** if either exists then INVPVDR5 handles it later.
                 */
	      if cr.PRIMARY_UOM_CODE is NULL
                 and cr.PRIMARY_UNIT_OF_MEASURE is NULL then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'UOM_PROFILE',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_INVALID_PRIMARY_UOM',
				err_text);
				status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
		end if;

		-- validate INTERNAL_ORDER_FLAG
		-- Added for bug 4260213
		if cr.INTERNAL_ORDER_FLAG = 'Y' AND cr.SHIPPABLE_ITEM_FLAG = 'N'
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
				'SHIPPABLE_ITEM_FLAG',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_SHIP_INT_YES',
				err_text);
				status := 1;
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                end if;

		-- validate BOM_ITEM_TYPE
		--Added for bug   3436384
                if cr.BOM_ITEM_TYPE = 5 AND cr.CUSTOMER_ORDER_FLAG <> 'N' then
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
				'INV_CUSTOMER',
				err_text);
				status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                end if;

		if cr.BOM_ITEM_TYPE = 3 then
		       if  cr.CUSTOMER_ORDER_FLAG <> 'N' then
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
				'INV_CUSTOMER',
				err_text);
				status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
			end if;
		       if  cr.SHIPPABLE_ITEM_FLAG <> 'N' then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'SHIPPABLE_ITEM_FLAG',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_SHIPPABLE',
				err_text);
				status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
			end if;
		   	if cr.INTERNAL_ORDER_FLAG <> 'N' or
		   	   cr.CUSTOMER_ORDER_FLAG <> 'N' or
		           cr.PICK_COMPONENTS_FLAG <> 'N' or
		           cr.REPLENISH_TO_ORDER_FLAG	<> 'N'  then
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
				'INV_IOI_PLANNING_DEP',
				err_text);
				status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
			end if;
		end if;
		if cr.BOM_ITEM_TYPE <> 4 then
			if cr.BUILD_IN_WIP_FLAG <> 'N' or
			   cr.BASE_ITEM_ID is not NULL then
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
                                'INV_IOI_BOM_STANDARD',
				err_text);
                                status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
			end if;
			if cr.INTERNAL_ORDER_FLAG <> 'N' then
--bug: 2731125 Modified the msgs for each bom item type
                                l_msg_name := 'INV_INTERNAL';
				if cr.BOM_ITEM_TYPE = 1 then
				  l_msg_name := 'INV_INTERNAL_MODEL' ;
                                elsif cr.BOM_ITEM_TYPE = 2 then
				  l_msg_name := 'INV_INTERNAL_OPTION_CLASS' ;
                                elsif cr.BOM_ITEM_TYPE = 5 then
				  l_msg_name := 'INV_INTERNAL_PRODUCT_FAMILY' ;
                                end if;
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INTERNAL_ORDER_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
--                                'INV_INTERNAL',
				l_msg_name,
				err_text);
                                status := 1;
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
			end if;
		end if;

		-- validate stock_enabled_flag
		if cr.stock_enabled_flag = 'Y' and
		   cr.INVENTORY_ITEM_FLAG <> 'Y'  then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'STOCK_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_STOCKABLE',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate inventory_item_flag

                -- NP 24OCT96
                -- if inventory_item_flag Y then SERVICE_ITEM_FLAG has to be 'N'
                -- Bug; 2696647 Inventory Item and Service/Warranty/Usage Contract Item
		--  Types are mutually exclusive item types.

		if cr.inventory_item_flag = 'Y' and
--Bug: 2731125   cr.service_item_flag = 'Y' then
		 cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE','WARRANTY','USAGE') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
--                                'INV_ITM_SERVICE_ITM',
				'INV_NO_INVENTORY_ITEM',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

                -- NP 24OCT96
                -- if inventory_item_flag Y
                -- or (SERVICE_ITEM_FLAG and VENDOR_WARRANTY_FLAG are both Y )
                -- then BOM_ENABLED_FLAG can be anything; else it must  be N
/**Bug: 3546140 Removed this validation for PLM RBOMS
		if ( cr.inventory_item_flag = 'Y'  or
--Bug: 2731125     or ( cr.SERVICE_ITEM_FLAG = 'Y' and cr.VENDOR_WARRANTY_FLAG = 'Y'))
		    cr.CONTRACT_ITEM_TYPE_CODE IS NOT NULL )
                then
                   null;  -- need not check BOM_ENABLED_FLAG
                else
                   if cr.BOM_ENABLED_FLAG = 'Y'   then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_BOM_ENABLED1',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		    end if;
		end if;
**/
		if cr.inventory_item_flag = 'N' and
		   cr.BUILD_IN_WIP_FLAG <> 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVENTORY_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_BUILD_WIP_NO',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate purchasing_item_flag
		if cr.purchasing_item_flag = 'N' and
		   cr.PURCHASING_ENABLED_FLAG <> 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PURCHASING_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_PO_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate customer_order_flag
		if cr.customer_order_flag = 'N' and
		   cr.CUSTOMER_ORDER_ENABLED_FLAG <> 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CUSTOMER_ORDER_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CUSTOMER_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate invoiceable_item_flag
		if cr.invoiceable_item_flag = 'N' and
		   cr.INVOICE_ENABLED_FLAG <> 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'INVOICEABLE_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVOICE_ENABLED',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;
/*** Bug: 2731125 SERVICEABLE_COMPONENT_FLAG got obsoleted
		-- validate service_item_flag
		if cr.service_item_flag = 'Y' and
		   cr.SERVICEABLE_COMPONENT_FLAG <> 'N'then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERVICE_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;
***/
--		if cr.service_item_flag = 'Y' and
		if cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE','USAGE','WARRANTY') and
		   cr.SERVICEABLE_PRODUCT_FLAG <> 'N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
--				'SERVICE_ITEM_FLAG',
				'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
--                                'INV_SERVICE',
				'INV_SERVICEABLE_CONTRACT',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

                /*NP 24OCT96 New Service related validations
                ** INVENTORY_ITEM_FLAG, service_item_flag validation already done
                ** in the INVENTORY_ITEM_FLAG section above
                */
--Bug: 2731125  if cr.service_item_flag = 'Y' and
--Bug: 2696647  SUBSCRIPTION Contract Items can be shippable and purchasable.
		if cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE','WARRANTY','USAGE') and
		   (cr.CYCLE_COUNT_ENABLED_FLAG <> 'N'
                    or cr.PURCHASING_ITEM_FLAG <> 'N'
                    or cr.SHIPPABLE_ITEM_FLAG <> 'N'
                    or cr.RETURNABLE_FLAG  <> 'N'
                    or cr.material_billable_flag is not NULL
                    or cr.ATP_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
--				'SERVICE_ITEM_FLAG',
				'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SERVICE1',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

                /*NP 24OCT96 New Service related validations
                ** if service_item_flag is N then
                ** VENDOR_WARRANTY_FLAG has to be N
                ** and coverage_schedule_id has to be null
                ** and service_duration has to be ZERO
                ** and service_duration_period_code has to be null
                */
--Bug: 2731125		if cr.service_item_flag = 'N' and
		if cr.CONTRACT_ITEM_TYPE_CODE IS NULL and
/**		   (  cr.VENDOR_WARRANTY_FLAG <> 'N'
                     or **/
		   ( cr.coverage_schedule_id is not NULL
                     or cr.service_duration <> 0
                     or cr.service_duration_period_code is not NULL) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
--				'SERVICE_ITEM_FLAG',
				'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SERVICE2',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

                /*NP 24OCT96 New Service related validations
                ** if service_item_flag is Y and
                ** VENDOR_WARRANTY_FLAG is Y then
                ** service_duration_period_code mustbe not NULL
                */
/**Bug: 2731125		if cr.service_item_flag = 'Y' and
                   cr.VENDOR_WARRANTY_FLAG  = 'Y'  and
 **/
-- Bug: 2811878 This validation will be in 11.5.10 in IOI
 		if cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE','WARRANTY') and
                   cr.service_duration_period_code is NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
--				'SERVICE_ITEM_FLAG',
				'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
--                                'INV_SERVICE3',
				'INV_SER_DURATION_MAND',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

/*Bug:3697824 removed this validation
		-- validate seviceable_product_flag
		if cr.SERVICEABLE_PRODUCT_FLAG = 'N'
                      and cr.service_starting_delay <> 0 then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SERVICEABLE_PRODUCT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SERVICE_PROD_FL',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;
*/
		-- validate pick_components_flag
		if cr.pick_components_flag='Y' then
		   	if cr.REPLENISH_TO_ORDER_FLAG	<> 'N' or
		   	   cr.BASE_ITEM_ID is not NULL then
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
                                'INV_IOI_PICK_DEP',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
			end if;
		   	if cr.MRP_PLANNING_CODE <> 6  then
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
                                'INV_MRP_PLANNING',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
			end if;
		end if;

		-- validate replenish_to_order_flag
		if cr.replenish_to_order_flag ='Y' and (
	           cr.PICK_COMPONENTS_FLAG = 'Y' or
		   cr.BOM_ITEM_TYPE = 3 ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'REPLENISH_TO_ORDER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_REPL_TO_ORDER_DEP',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate lot_control_code
                lot_num_generation_val := NULL;
                select lot_number_generation into lot_num_generation_val
                  from mtl_parameters
                 where organization_id = cr.organization_id
                   and rownum =1;  /*NP 21DEC94 */

-- Bug 3333917 : Message name corrected - Anmurali
		if cr.lot_control_code = 2 and
                   lot_num_generation_val = 2 and
	           cr.AUTO_LOT_ALPHA_PREFIX is NULL then
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
                                'INV_AUTO_LOT_PREFIX',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate lot_control_code
                lot_num_generation_val := NULL;
                select lot_number_generation into lot_num_generation_val
                  from mtl_parameters
                 where organization_id = cr.organization_id
                   and rownum =1;  /*NP 21DEC94 */

                --3296460:START_AUTO_LOT_NUMBER should be number.
                if cr.START_AUTO_LOT_NUMBER IS NOT NULL then
		   begin

		      SELECT TO_CHAR(TO_NUMBER(cr.START_AUTO_LOT_NUMBER))
		      INTO   l_start_auto_lot_num
		      FROM DUAL;

		   exception
		      when others then
		         --Catch ORA-01722: invalid number and raise a error message.
                         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'START_AUTO_LOT_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_START_AUTO_LOT_INVALID_NUM',
				err_text);
                         if dumm_status < 0 then
                            raise LOGGING_ERR;
                         end if;
                         status := 1;
		   end;
		end if;

-- Bug 3333917 : Message name corrected - Anmurali
		if cr.lot_control_code = 2 and
                   lot_num_generation_val = 2 and
		   cr.START_AUTO_LOT_NUMBER is NULL then
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
				'INV_START_LOT_NUM',
				 err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate serial_number_control_code
                ser_num_generation_val := NULL;
                select serial_number_generation into ser_num_generation_val
                  from mtl_parameters
                 where organization_id = cr.organization_id
                   and rownum =1;  /*NP 21DEC94 */

		if cr.serial_number_control_code = 2 and
                   ser_num_generation_val = 2 and
		   cr.START_AUTO_SERIAL_NUMBER is NULL then
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
                                'INV_START_SERIAL_NUM',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate serial_number_control_code
                ser_num_generation_val := NULL;
                select serial_number_generation into ser_num_generation_val
                  from mtl_parameters
                 where organization_id = cr.organization_id
                   and rownum =1;  /*NP 21DEC94 */

		if cr.serial_number_control_code = 2 and
                   ser_num_generation_val = 2 and
		   cr.AUTO_SERIAL_ALPHA_PREFIX is NULL then
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
                                'INV_AUTO_SERIAL_PREFIX',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate shelf_life_code
		if cr.shelf_life_code = 2 and
	           cr.SHELF_LIFE_DAYS is NULL then
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
                                'INV_SHELF_DAYS_MAND',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate OUTSIDE_OPERATION_FLAG
		if cr.OUTSIDE_OPERATION_FLAG = 'Y' then
			if cr.purchasing_item_flag ='N' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'OUTSIDE_OPERATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_OUT_OP_FLAG_DEP',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
			end if;
			if cr.OUTSIDE_OPERATION_UOM_TYPE is NULL then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'OUTSIDE_OPERATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OUTSIDE_OP_UNIT',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;

			end if;
                end if;

		/* Fix for bug 5844510- Commented all the source org related validations
		 as they are redundant. These are done in INVPVD6B.pls

		-- Validate SOURCE_ORGANIZATION_ID
                --
                if (cr.SOURCE_ORGANIZATION_ID is NOT NULL) then

                     if (cr.SOURCE_ORGANIZATION_ID <> cr.ORGANIZATION_ID) then

                     -- Check if the item exists in the source organization.
                     --
                     begin
                        select 'item_in_source_org'
                        into  l_dummy
                        from  mtl_system_items_b
                        where  inventory_item_id = l_item_id
                          and  organization_id = cr.source_organization_id;

                     exception
                         when no_data_found then
                           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SOURCE_ORGANIZATION_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_ITEM_IN_SOURCE_ORG',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                     end;

                     begin
                        Select 'inter-org network defined'
                          into l_dummy
			from  mtl_interorg_parameters
			where to_organization_id   = cr.organization_id
			and   from_organization_id = cr.source_organization_id;

                     exception
                         when no_data_found then
                           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'SOURCE_ORGANIZATION_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INTERORG_NTWK',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                     end;
                     end if;

                    If  cr.SOURCE_ORGANIZATION_ID = cr.ORGANIZATION_ID  and
                        cr.mrp_planning_code      = 3                   then
                        begin
			select 'nettable or null source sub'
                           into l_dummy
			from    mtl_secondary_inventories
			where   secondary_inventory_name =
                                     nvl(cr.source_subinventory,
                                               secondary_inventory_name)
			and     availability_type = 1
                        and     rownum < 2 ;
                        dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SOURCE_ORGANIZATION_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INTRAORG_SOURCE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        Exception
                                When no_data_found then
                                     null;
                        end ;
                        End if ;

                end if;

		-- validate SOURCE_TYPE/ SOURCE_ORGANIZATION_ID
                -- 13-FEB-98, Source Organization Not Mandatory for source_type 1
                -- 15-APR-98, Source Org/Sub Should be Null if source_type <> 1
		IF (cr.source_type = 2  OR
                    cr.source_type IS NULL) AND
		   (cr.SOURCE_ORGANIZATION_ID is NOT NULL) THEN
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
                                'INV_SOURCE_ORG_MUST_BE_NULL',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                END IF;

		End of commented code for fixing bug 5844510 */

		-- validate MINIMUM_ORDER_QUANTITY
                if cr.MINIMUM_ORDER_QUANTITY < 0 or
                   cr.MINIMUM_ORDER_QUANTITY >
                            nvl(cr.maximum_order_quantity, cr.MINIMUM_ORDER_QUANTITY) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MINIMUM_ORDER_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MIN_ORD_QTY',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

		-- validate MAXIMUM_ORDER_QUANTITY

                if cr.MAXIMUM_ORDER_QUANTITY < 0 or
                   cr.MAXIMUM_ORDER_QUANTITY <
                               nvl(cr.minimum_order_quantity, cr.MAXIMUM_ORDER_QUANTITY) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MAXIMUM_ORDER_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MAX_ORD_QTY',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate MIN_MINMAX_QUANTITY
		if cr.MIN_MINMAX_QUANTITY < 0 or
		   cr.MIN_MINMAX_QUANTITY >
                    nvl(cr.max_minmax_quantity, cr.MIN_MINMAX_QUANTITY +1 ) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MIN_MINMAX_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MINMAX_MIN',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

		-- validate MAX_MINMAX_QUANTITY
		if cr.MAX_MINMAX_QUANTITY < nvl(cr.min_minmax_quantity,0) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'MAX_MINMAX_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MINMAX_MAX',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                -- validate check_shortages_flag
                if cr.CHECK_SHORTAGES_FLAG = 'Y' and
                   cr.MTL_TRANSACTIONS_ENABLED_FLAG <> 'Y'  then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CHECK_SHORTAGES_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_ENABLE_SHORT_CHECK',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;
		if cr.CONTRACT_ITEM_TYPE_CODE ='WARRANTY' and
		   cr.CUSTOMER_ORDER_FLAG = 'Y' then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_CUSTOMER_CONTRACT',
				err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
		end if;

             /* R12 C Unit Weight can now be updated for Pending items. Moving the below set of validations to INVPVHDR */
                IF cr.WEIGHT_UOM_CODE IS NOT NULL THEN
                   BEGIN
                     SELECT 'x' INTO temp
                       FROM MTL_UNITS_OF_MEASURE
                      WHERE UOM_CODE = cr.WEIGHT_UOM_CODE;
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
                                'WEIGHT_UOM_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_WEIGHT_UOM_CODE',
                                err_text);
                          IF dumm_status < 0 THEN
                             raise LOGGING_ERR;
                          END IF;
                          status := 1;
                   END;
                END IF;

	      /* Moved the Weight UOM Code and Unit Weight validations from INVPVDR4 and INVPVDR5 */
		 l_col_name := NULL;
                 l_msg_name := NULL;

                 IF   cr.WEIGHT_UOM_CODE IS NULL
                 AND (cr.UNIT_WEIGHT IS NOT NULL OR cr.MAXIMUM_LOAD_WEIGHT IS NOT NULL) THEN --Bug: 3503944
                    l_col_name := 'WEIGHT_UOM_CODE';
                    l_msg_name := 'INV_IOI_WEIGHT_UOM_MISSING';
                 ELSIF cr.VOLUME_UOM_CODE IS NULL
                 AND  (cr.UNIT_VOLUME IS NOT NULL OR cr.INTERNAL_VOLUME IS NOT NULL) THEN --Bug: 3503944
                    l_col_name := 'VOLUME_UOM_CODE';
                    l_msg_name := 'INV_IOI_VOLUME_UOM_MISSING';
                 ELSIF cr.DIMENSION_UOM_CODE IS NULL
                 AND  (cr.UNIT_LENGTH IS NOT NULL
                  OR   cr.UNIT_WIDTH  IS NOT NULL
                  OR   cr.UNIT_HEIGHT IS NOT NULL)
                 THEN
                    l_col_name := 'DIMENSION_UOM_CODE';
                    l_msg_name := 'INV_IOI_DIMENSION_UOM_MISSING';
                 END IF;

                 IF l_col_name IS NOT NULL THEN
                    dumm_status := INVPUOPI.mtl_log_interface_err
                                     (cr.organization_id,
                                      user_id,
				      login_id,
				      prog_appid,
				      prog_id,
				      request_id,
                                      cr.TRANSACTION_ID,
				      error_msg,
                                      l_col_name,
				      'MTL_SYSTEM_ITEMS_INTERFACE',
                                      l_msg_name,
				      err_text );
                    IF dumm_status < 0 THEN
                       raise LOGGING_ERR;
                    END IF;
                    status := 1;
                 END IF;

                -- Validate INDIVISIBLE_FLAG
                --
                /* Independent attribute
                */


                /* NP26DEC94 : New code to update process_flag.
                ** This modified/new code necessiated due to the breaking up INVPVHDR into
                ** 6 smaller packages to overcome PL/SQL limitations with code size.
                ** Let's update the process flag for the record
                ** Give it value 41 if all okay and 31 if some validation failed in this procedure
                ** The process flag values that are possible at this time are
                ** 2 set by the previous procedure.
                ** Since this is the first validation procedure..the logic is a little different
                ** from the 5 other validation procedures in files
                ** INVPVDR2.sql thru INVPVDR6.sql
                */

                        --R12C WHERE clause changed to ROWID
                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = DECODE(status,0,41,31),
                            PRIMARY_UOM_CODE = cr.primary_uom_code,
                            primary_unit_of_measure = cr.primary_unit_of_measure
                        where rowid = cr.rowid;

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
		err_text := substr('INVPVALI.validate_item_header' || SQLERRM , 1, 240);
		return(SQLCODE);

end validate_item_header;


end INVPVHDR;

/
