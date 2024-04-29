--------------------------------------------------------
--  DDL for Package Body CSD_ESTIMATES_FROM_BOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_ESTIMATES_FROM_BOM_PVT" AS
/* $Header: csdvbomb.pls 120.2 2008/05/23 05:20:13 subhat noship $*/

g_business_process_id number;
g_txn_billing_type_id NUMBER;
g_transaction_type_id NUMBER;
-- bug# 6890910 subhat
-- contract number can be alpha numeric
g_contract_num varchar2(120);
-- end bug #6890910
gc_delimiter CONSTANT VARCHAR2(1) := ':';

/*--------------------------------------------------------------------------------*/
/*procedure Name: Explode_bom_items
/*Description: This is the wrapper API for the BOM Exploder.			  */
/*This takes in the Item to be expanded and inserts the explosion hierarchy	  */
/*to csd_bom_expl_tmp temp table. The temp table will be flushed whenever a	  */
/*commit is issued in the session or when a session closes.			  */
/*@ param: P_Item - The Name of the item to be expanded.			  */
/*@ param:p_alt_bom - Alternate, if any, for the item. Default null		  */
/*--------------------------------------------------------------------------------*/
PROCEDURE explode_bom_items(p_itemId IN NUMBER,p_alt_bom IN VARCHAR2 DEFAULT NULL ) IS

l_bom_exp_tab bompxinq.bomexporttabtype;
l_err_msg varchar2(2000);
l_err_code number;
--l_type l_bom_exp_tab%rowtype;
l_count number;
l_material_billable_flag varchar2(2);
l_dummy varchar2(2) := null;
l_inventory_item_id number;
l_org_id NUMBER := cs_std.get_item_valdn_orgzn_id;
l_profile_id number;
--bug#6930575,subhat.
l_effectivity_control number;
l_max_level number;
l_unit_number_from varchar2(50) := null;
l_unit_number_to varchar2(50) := null;
l_group_id number;
t_org_code_list INV_OrgHierarchy_PVT.OrgID_tbl_type;

lc_mod_name varchar2(60) := 'csd.plsql.csd_estimates_from_bom_pvt.explode_bom_items';

exploder_error exception;

BEGIN

IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'begin',
                        'Entering explode_bom_items');
END IF;
--bug#6930575, subhat.
-- we will use exploder_userexit API no need for profile_id
-- get the security profile id for the current session
--l_profile_id := fnd_profile.value('PER_SECURITY_PROFILE_ID');

t_org_code_list(1) := l_org_id;
-- bug#6930575, subhat
-- export_bom api doesnt work fine for Model Unit Controlled items.
-- need to use exploder_userexit as BOM team is reluctant to fix this bug in 12.1

-- Check if the item is MU controlled

	select effectivity_control into l_effectivity_control
	from mtl_system_items_b
	where inventory_item_id = p_itemId
		 and organization_id = l_org_id;
-- get the max and min unit numbers if the item is MU controlled.
if nvl(l_effectivity_control,0) = 2 then
	select min(unit_number),max(unit_number) into
               l_unit_number_from,l_unit_number_to
	from pjm_unit_numbers
	where  master_organization_id = fnd_profile.value('ORG_ID');
end if;
-- get the maximum explosion level.
	SELECT MAXIMUM_BOM_LEVEL INTO l_max_level
        FROM BOM_PARAMETERS
        WHERE ORGANIZATION_ID = l_org_id;
-- get the group id used for explosion.
	SELECT bom_explosion_temp_s.nextval INTO  l_group_id from dual;
-- clear the bom temporary table
	delete from  bom_small_expl_temp;
-- calling exploder_userexit API.
IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'begin',
                        'Calling exploder_userexit');
end if;

	bompxinq.exploder_userexit (
        verify_flag          => 0 ,
        org_id               => t_org_code_list(1),
        order_by             => 2 ,
        grp_id               => l_group_id ,
        session_id           => 0 ,
        levels_to_explode    => l_max_level,
        bom_or_eng           => 1,
        impl_flag            => 1,
        plan_factor_flag     => 2,
        explode_option       => 3,
        module               => 2 ,
        unit_number_from     => l_unit_number_from,
        unit_number_to       => l_unit_number_to,
        cst_type_id          => 0 ,
        std_comp_flag        => 2 ,
        expl_qty             => 1,
        item_id              => p_itemId ,
        alt_desg             => p_alt_bom ,
        comp_code            => null,
        rev_date             => sysdate ,
        show_rev             => 1 ,
        material_ctrl        => 1,
        lead_time            => 1,
        err_msg              => l_err_msg ,
        error_code           => l_err_code);
  if l_err_code = 9998 then
    raise exploder_error;
  end if;
  if l_err_code = 0 or l_err_code = null then

	delete from csd_bom_expl_temp;
     INSERT INTO csd_bom_expl_temp (
               TOP_BILL_SEQUENCE_ID      ,
               BILL_SEQUENCE_ID          ,
               COMMON_BILL_SEQUENCE_ID   ,
               ORGANIZATION_ID           ,
               COMPONENT_SEQUENCE_ID     ,
               COMPONENT_ITEM_ID         ,
               BASIS_TYPE		 ,
               COMPONENT_QUANTITY        ,
               PLAN_LEVEL                ,
               EXTENDED_QUANTITY         ,
               SORT_ORDER                ,
               GROUP_ID                  ,
               TOP_ALTERNATE_DESIGNATOR  ,
               COMPONENT_YIELD_FACTOR    ,
               TOP_ITEM_ID               ,
               COMPONENT_CODE            ,
               INCLUDE_IN_ROLLUP_FLAG    ,
               LOOP_FLAG                 ,
               PLANNING_FACTOR           ,
               OPERATION_SEQ_NUM         ,
               BOM_ITEM_TYPE             ,
               PARENT_BOM_ITEM_TYPE      ,
               ASSEMBLY_ITEM_ID          ,
               WIP_SUPPLY_TYPE           ,
               ITEM_NUM                  ,
               EFFECTIVITY_DATE          ,
               DISABLE_DATE              ,
               IMPLEMENTATION_DATE       ,
               OPTIONAL                  ,
               SUPPLY_SUBINVENTORY       ,
               SUPPLY_LOCATOR_ID         ,
               COMPONENT_REMARKS         ,
               CHANGE_NOTICE             ,
               OPERATION_LEAD_TIME_PERCENT,
               MUTUALLY_EXCLUSIVE_OPTIONS ,
               CHECK_ATP                  ,
               REQUIRED_TO_SHIP           ,
               REQUIRED_FOR_REVENUE       ,
               INCLUDE_ON_SHIP_DOCS       ,
               LOW_QUANTITY               ,
               HIGH_QUANTITY              ,
               SO_BASIS                   ,
               OPERATION_OFFSET           ,
               CURRENT_REVISION           ,
               LOCATOR                    ,
               CONTEXT                    ,
               ATTRIBUTE1                 ,
               ATTRIBUTE2                 ,
               ATTRIBUTE3                 ,
               ATTRIBUTE4                 ,
               ATTRIBUTE5                 ,
               ATTRIBUTE6                 ,
               ATTRIBUTE7                 ,
               ATTRIBUTE8                 ,
               ATTRIBUTE9                 ,
               ATTRIBUTE10                ,
               ATTRIBUTE11                ,
               ATTRIBUTE12                ,
               ATTRIBUTE13                ,
               ATTRIBUTE14                ,
               ATTRIBUTE15                ,
               ITEM_COST                  ,
               EXTEND_COST_FLAG
 	)

  Select
               TOP_BILL_SEQUENCE_ID      ,
               BILL_SEQUENCE_ID          ,
               COMMON_BILL_SEQUENCE_ID   ,
               ORGANIZATION_ID           ,
               COMPONENT_SEQUENCE_ID     ,
               COMPONENT_ITEM_ID         ,
               BASIS_TYPE		 ,
               COMPONENT_QUANTITY        ,
               PLAN_LEVEL                ,
               EXTENDED_QUANTITY         ,
               SORT_ORDER                ,
               GROUP_ID                  ,
               TOP_ALTERNATE_DESIGNATOR  ,
               COMPONENT_YIELD_FACTOR    ,
               TOP_ITEM_ID               ,
               COMPONENT_CODE            ,
               INCLUDE_IN_ROLLUP_FLAG    ,
               LOOP_FLAG                 ,
               PLANNING_FACTOR           ,
               OPERATION_SEQ_NUM         ,
               BOM_ITEM_TYPE             ,
               PARENT_BOM_ITEM_TYPE      ,
               ASSEMBLY_ITEM_ID          ,
               WIP_SUPPLY_TYPE           ,
               ITEM_NUM                  ,
               EFFECTIVITY_DATE          ,
               DISABLE_DATE              ,
               IMPLEMENTATION_DATE       ,
               OPTIONAL                  ,
               SUPPLY_SUBINVENTORY       ,
               SUPPLY_LOCATOR_ID         ,
               COMPONENT_REMARKS         ,
               CHANGE_NOTICE             ,
               OPERATION_LEAD_TIME_PERCENT,
               MUTUALLY_EXCLUSIVE_OPTIONS ,
               CHECK_ATP                  ,
               REQUIRED_TO_SHIP           ,
               REQUIRED_FOR_REVENUE       ,
               INCLUDE_ON_SHIP_DOCS       ,
               LOW_QUANTITY               ,
               HIGH_QUANTITY              ,
               SO_BASIS                   ,
               OPERATION_OFFSET           ,
               CURRENT_REVISION           ,
               LOCATOR                    ,
               CONTEXT                    ,
               ATTRIBUTE1                 ,
               ATTRIBUTE2                 ,
               ATTRIBUTE3                 ,
               ATTRIBUTE4                 ,
               ATTRIBUTE5                 ,
               ATTRIBUTE6                 ,
               ATTRIBUTE7                 ,
               ATTRIBUTE8                 ,
               ATTRIBUTE9                 ,
               ATTRIBUTE10                ,
               ATTRIBUTE11                ,
               ATTRIBUTE12                ,
               ATTRIBUTE13                ,
               ATTRIBUTE14                ,
               ATTRIBUTE15                ,
               ITEM_COST                  ,
               EXTEND_COST_FLAG
       from bom_small_expl_temp
       where group_id = l_group_id;

end if;

-- bug#6930575,subhat. commented the previous API call.
-- Call the BOM exploder API to get the PL/SQL table of explosion items.

/*bompxinq.export_bom(profile_id =>l_profile_id,
	               org_hierarchy_name => null,
                    assembly_item_id => p_itemId,
                    organization_id => l_org_id,
                    alternate_bm_designator => P_alt_bom,
                    bom_export_tab => l_bom_exp_tab,
                    err_msg => l_err_msg,
                    error_code => l_err_code );

l_count := l_bom_exp_tab.COUNT;

-- clear the temp table.

DELETE FROM csd_bom_expl_temp;

/*FOR i IN 1 ..l_count
LOOP

-- Insert the values into the temp table.

	INSERT INTO csd_bom_expl_temp (
       top_bill_sequence_id,
       bill_sequence_id,
       organization_id,
       component_sequence_id,
       component_item_id,
       plan_level,
       extended_quantity,
       sort_order,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       GROUP_ID,
       session_id,
       select_flag,
       select_quantity,
       extend_cost_flag,
       top_alternate_designator,
       top_item_id,
       CONTEXT,
       attribute1, attribute2,
       attribute3, attribute4,
       attribute5, attribute6,
       attribute7, attribute8,
       attribute9, attribute10,
       attribute11, attribute12,
       attribute13, attribute14,
       attribute15, header_id,
       line_id, list_price,
       selling_price,
       component_yield_factor,
       item_cost,
       include_in_rollup_flag,
       based_on_rollup_flag,
       actual_cost_type_id,
       component_quantity,
       shrinkage_rate, so_basis,
       optional,
       mutually_exclusive_options,
       check_atp, shipping_allowed,
       required_to_ship,
       required_for_revenue,
       include_on_ship_docs,
       include_on_bill_docs,
       low_quantity, high_quantity,
       pick_components,
       primary_uom_code,
       primary_unit_of_measure,
       base_item_id,
       atp_components_flag, atp_flag,
       bom_item_type,
       pick_components_flag,
       replenish_to_order_flag,
       shippable_item_flag,
       customer_order_flag,
       internal_order_flag,
       customer_order_enabled_flag,
       internal_order_enabled_flag,
       so_transactions_flag,
       mtl_transactions_enabled_flag,
       stock_enabled_flag,
       description, assembly_item_id,
       configurator_flag,
       price_list_id, rounding_factor,
       pricing_context,
       pricing_attribute1,
       pricing_attribute2,
       pricing_attribute3,
       pricing_attribute4,
       pricing_attribute5,
       pricing_attribute6,
       pricing_attribute7,
       pricing_attribute8,
       pricing_attribute9,
       pricing_attribute10,
       pricing_attribute11,
       pricing_attribute12,
       pricing_attribute13,
       pricing_attribute14,
       pricing_attribute15,
       component_code, loop_flag,
       inventory_asset_flag,
       planning_factor,
       operation_seq_num,
       parent_bom_item_type,
       wip_supply_type, item_num,
       effectivity_date, disable_date,
       implementation_date,
       supply_subinventory,
       supply_locator_id,
       component_remarks,
       change_notice,
       operation_lead_time_percent,
       rexplode_flag,
       common_bill_sequence_id,
       operation_offset,
       current_revision, LOCATOR,
       from_end_item_unit_number,
       to_end_item_unit_number,
       basis_type
 )
	VALUES (
       l_bom_exp_tab(i).top_bill_sequence_id,
       l_bom_exp_tab(i).bill_sequence_id,
       l_bom_exp_tab(i).organization_id,
       l_bom_exp_tab(i).component_sequence_id,
       l_bom_exp_tab(i).component_item_id,
       l_bom_exp_tab(i).plan_level,
       l_bom_exp_tab(i).extended_quantity,
       l_bom_exp_tab(i).sort_order,
       l_bom_exp_tab(i).request_id,
       l_bom_exp_tab(i).program_application_id,
       l_bom_exp_tab(i).program_id,
       l_bom_exp_tab(i).program_update_date,
       l_bom_exp_tab(i).GROUP_ID,
       l_bom_exp_tab(i).session_id,
       l_bom_exp_tab(i).select_flag,
       l_bom_exp_tab(i).select_quantity,
       l_bom_exp_tab(i).extend_cost_flag,
       l_bom_exp_tab(i).top_alternate_designator,
       l_bom_exp_tab(i).top_item_id,
       l_bom_exp_tab(i).CONTEXT,
       l_bom_exp_tab(i).attribute1, l_bom_exp_tab(i).attribute2,
       l_bom_exp_tab(i).attribute3, l_bom_exp_tab(i).attribute4,
       l_bom_exp_tab(i).attribute5, l_bom_exp_tab(i).attribute6,
       l_bom_exp_tab(i).attribute7, l_bom_exp_tab(i).attribute8,
       l_bom_exp_tab(i).attribute9, l_bom_exp_tab(i).attribute10,
       l_bom_exp_tab(i).attribute11, l_bom_exp_tab(i).attribute12,
       l_bom_exp_tab(i).attribute13, l_bom_exp_tab(i).attribute14,
       l_bom_exp_tab(i).attribute15, l_bom_exp_tab(i).header_id,
       l_bom_exp_tab(i).line_id, l_bom_exp_tab(i).list_price,
       l_bom_exp_tab(i).selling_price,
       l_bom_exp_tab(i).component_yield_factor,
       l_bom_exp_tab(i).item_cost,
       l_bom_exp_tab(i).include_in_rollup_flag,
       l_bom_exp_tab(i).based_on_rollup_flag,
       l_bom_exp_tab(i).actual_cost_type_id,
       l_bom_exp_tab(i).component_quantity,
       l_bom_exp_tab(i).shrinkage_rate, l_bom_exp_tab(i).so_basis,
       l_bom_exp_tab(i).optional,
       l_bom_exp_tab(i).mutually_exclusive_options,
       l_bom_exp_tab(i).check_atp, l_bom_exp_tab(i).shipping_allowed,
       l_bom_exp_tab(i).required_to_ship,
       l_bom_exp_tab(i).required_for_revenue,
       l_bom_exp_tab(i).include_on_ship_docs,
       l_bom_exp_tab(i).include_on_bill_docs,
       l_bom_exp_tab(i).low_quantity, l_bom_exp_tab(i).high_quantity,
       l_bom_exp_tab(i).pick_components,
       l_bom_exp_tab(i).primary_uom_code,
       l_bom_exp_tab(i).primary_unit_of_measure,
       l_bom_exp_tab(i).base_item_id,
       l_bom_exp_tab(i).atp_components_flag, l_bom_exp_tab(i).atp_flag,
       l_bom_exp_tab(i).bom_item_type,
       l_bom_exp_tab(i).pick_components_flag,
       l_bom_exp_tab(i).replenish_to_order_flag,
       l_bom_exp_tab(i).shippable_item_flag,
       l_bom_exp_tab(i).customer_order_flag,
       l_bom_exp_tab(i).internal_order_flag,
       l_bom_exp_tab(i).customer_order_enabled_flag,
       l_bom_exp_tab(i).internal_order_enabled_flag,
       l_bom_exp_tab(i).so_transactions_flag,
       l_bom_exp_tab(i).mtl_transactions_enabled_flag,
       l_bom_exp_tab(i).stock_enabled_flag,
       l_bom_exp_tab(i).description, l_bom_exp_tab(i).assembly_item_id,
       l_bom_exp_tab(i).configurator_flag,
       l_bom_exp_tab(i).price_list_id, l_bom_exp_tab(i).rounding_factor,
       l_bom_exp_tab(i).pricing_context,
       l_bom_exp_tab(i).pricing_attribute1,
       l_bom_exp_tab(i).pricing_attribute2,
       l_bom_exp_tab(i).pricing_attribute3,
       l_bom_exp_tab(i).pricing_attribute4,
       l_bom_exp_tab(i).pricing_attribute5,
       l_bom_exp_tab(i).pricing_attribute6,
       l_bom_exp_tab(i).pricing_attribute7,
       l_bom_exp_tab(i).pricing_attribute8,
       l_bom_exp_tab(i).pricing_attribute9,
       l_bom_exp_tab(i).pricing_attribute10,
       l_bom_exp_tab(i).pricing_attribute11,
       l_bom_exp_tab(i).pricing_attribute12,
       l_bom_exp_tab(i).pricing_attribute13,
       l_bom_exp_tab(i).pricing_attribute14,
       l_bom_exp_tab(i).pricing_attribute15,
       l_bom_exp_tab(i).component_code, l_bom_exp_tab(i).loop_flag,
       l_bom_exp_tab(i).inventory_asset_flag,
       l_bom_exp_tab(i).planning_factor,
       l_bom_exp_tab(i).operation_seq_num,
       l_bom_exp_tab(i).parent_bom_item_type,
       l_bom_exp_tab(i).wip_supply_type, l_bom_exp_tab(i).item_num,
       l_bom_exp_tab(i).effectivity_date, l_bom_exp_tab(i).disable_date,
       l_bom_exp_tab(i).implementation_date,
       l_bom_exp_tab(i).supply_subinventory,
       l_bom_exp_tab(i).supply_locator_id,
       l_bom_exp_tab(i).component_remarks,
       l_bom_exp_tab(i).change_notice,
       l_bom_exp_tab(i).operation_lead_time_percent,
       l_bom_exp_tab(i).rexplode_flag,
       l_bom_exp_tab(i).common_bill_sequence_id,
       l_bom_exp_tab(i).operation_offset,
       l_bom_exp_tab(i).current_revision, l_bom_exp_tab(i).LOCATOR,
       l_bom_exp_tab(i).from_end_item_unit_number,
       l_bom_exp_tab(i).to_end_item_unit_number,
       l_bom_exp_tab(i).basis_type
       ); */

--END loop;


EXCEPTION
  when exploder_error then
    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'Exploder_error',
                        'Error occured while executing bom_exploder'||l_err_msg);
    END IF;
   rollback;
  WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'others exception',
                        'an unknown error occured');
    end if;
    rollback;
END explode_bom_items;

/* This is the wrapper API for the standard Depot API for the estimate lines.*/
/* This takes a table of Itemid-quantity-primary UOM and creates estimate lines */
/* in Loop. This procedure in turn makes calls to other depot standard api's to get the*/
/* different values.									*/
/* parameters:
/*p_itemQty - This is a table type. Contains the data in the format "invItemid:qty:uom" */
/*		: is the delimiter. */
/*p_repair_line_id:
/*p_repair_type_id:
/*p_currency_code:
/*p_org_id:
/*p_repair_estimate_id:
/*p_contract_line_id:
/*p_incident_id: Incident Id for the repair.
/*x_return_Status: OUT parameter. */

PROCEDURE create_estimate_lines(p_itemQty IN varchar2_table_200,
	                        p_repair_line_id	IN NUMBER,
							p_repair_type_id	IN NUMBER,
							p_currency_code		IN VARCHAR2,
							p_org_id			IN NUMBER,
							p_repair_estimate_id IN NUMBER,
							p_pricelist_header_id IN NUMBER,
							p_contract_line_id	IN NUMBER default null,
							p_incident_id		IN NUMBER,
							p_init_msg_list		IN VARCHAR2,
							x_msg_data			OUT NOCOPY VARCHAR2,
							x_msg_count			OUT NOCOPY NUMBER,
							x_return_status		OUT NOCOPY varchar2) IS
l_selling_price  number;
l_discount_price number;
l_item_cost      number;
l_contract_number number;
l_item_id	 number;
l_quantity	 number;
l_item_name	 varchar2(100);
l_count		 number;
l_uom		 varchar2(10);
l_contract_discount_amnt NUMBER;
l_estimate_line_id NUMBER;

lc_mod_name varchar2(100) := 'csd.plsql.csd_estimates_from_bom_pvt.create_estimate_lines';

-- estimate lines rec.

l_estimate_lines_rec CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC := csd_process_util.ui_estimate_line_rec;

BEGIN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'begin',
                        'Entering create_estimate_lines');
      END IF;

        -- if message init is passed as yes initialize message stack.

	IF FND_API.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
	END IF;

	-- set the return status as success status.

	x_return_status := FND_API.G_RET_STS_SUCCESS;


-- get the billing type id based on the repair_type and billing type

	BEGIN
		SELECT txn_billing_type_id,transaction_type_id
		INTO g_txn_billing_type_id,g_transaction_type_id
		FROM csd_repair_types_sar_vl
		WHERE repair_type_id = p_repair_type_id
		AND billing_type = 'M';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			fnd_message.set_name('CSD','CSD_API_INV_TXN_BILLING_TYPE');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_ERROR;
	END;

-- the required parameter validation is done in the java layer.
l_count := p_itemQty.COUNT;
--dbms_output.put_line('starting loop');
FOR i IN 1 ..l_count
	LOOP
		l_item_id := substr(p_itemQty(i),1,(instr(p_itemQty(i),gc_delimiter,1,1) - 1));

		l_quantity := substr(p_itemQty(i),(instr(p_itemQty(i),gc_delimiter) + 1),(instr(p_itemQty(i),gc_delimiter,-1,1) - (instr(p_itemQty(i),gc_delimiter) + 1)));
		l_uom := substr(p_itemQty(i),instr(p_itemQty(i),gc_delimiter,-1,1)+1,length(p_itemQty(i)));

-- retrieve the contract number.

IF p_contract_line_id IS NOT NULL THEN
	l_contract_number := get_default_contract(p_contract_line_id,p_repair_type_id,x_msg_count,x_msg_data,x_return_status);
ELSE
	l_contract_number := null;
END IF;

-- retrieve the Unit cost of the item.
l_item_cost := get_item_Cost(l_item_id,l_uom,p_currency_code, cs_std.get_item_valdn_orgzn_id,x_msg_count,x_msg_data,x_return_status);

-- retrieve the selling price for the item.
l_selling_price := get_selling_price(l_item_id,l_uom,l_quantity,p_pricelist_header_id,p_currency_code,p_org_id,
				x_msg_count,x_msg_data,x_return_status);

-- get the discounted price for the item.
-- If there is no contract applied for the repair, there is no discounted price.
--dbms_output.put_line('Discount '||l_selling_price);
if p_contract_line_id is not null then
	l_discount_price := get_discount_price(p_contract_line_id,p_repair_type_id,l_selling_price,l_quantity,
		x_msg_count,x_msg_data,x_return_status);
else
	l_discount_price := nvl(l_quantity,0) * nvl(l_selling_price,0);
end if;

-- initialize the repair estimate line rec.
l_estimate_lines_rec.repair_estimate_line_id   := null;
l_estimate_lines_rec.repair_estimate_id        := p_repair_estimate_id;
l_estimate_lines_rec.repair_line_id            := p_repair_line_id;
l_estimate_lines_rec.estimate_detail_id        := null;
l_estimate_lines_rec.incident_id               := p_incident_id; --l_incident_id;
l_estimate_lines_rec.transaction_type_id       := g_transaction_type_id;
l_estimate_lines_rec.business_process_id       := g_business_process_id;
l_estimate_lines_rec.txn_billing_type_id       := g_txn_billing_type_id;
l_estimate_lines_rec.original_source_id        := null;
l_estimate_lines_rec.original_source_code      := null;
l_estimate_lines_rec.source_id                 := null;
l_estimate_lines_rec.source_code               := null;
  if (l_item_cost = 0) then
     l_estimate_lines_rec.item_cost  := null;
  else
     l_estimate_lines_rec.item_cost  := l_item_Cost;
  end if;

l_estimate_lines_rec.customer_product_id       := null;
l_estimate_lines_rec.reference_number          := null;
l_estimate_lines_rec.item_revision             := null;
l_estimate_lines_rec.justification_notes       := null;
l_estimate_lines_rec.estimate_status           := 'NEW';
-- by default the status will be new for the ones created from
-- bom selection screen.
l_estimate_lines_rec.order_number              := null;
l_estimate_lines_rec.purchase_order_num        := NULL;-- name_in('Global.default_po_number');
l_estimate_lines_rec.source_number             := null;
l_estimate_lines_rec.status                    := 'O';
l_estimate_lines_rec.currency_code             := p_currency_code;
l_estimate_lines_rec.line_category_code        := 'ORDER';
l_estimate_lines_rec.unit_of_measure_code      := l_uom;
l_estimate_lines_rec.original_source_number    := null;
l_estimate_lines_rec.order_header_id           := null;
l_estimate_lines_rec.order_line_id             := null;
l_estimate_lines_rec.inventory_item_id         := l_item_id;
l_estimate_lines_rec.after_warranty_cost       := l_discount_price;
l_estimate_lines_rec.selling_price             := l_selling_price;
l_estimate_lines_rec.original_system_reference := null;
l_estimate_lines_rec.estimate_quantity         := l_quantity;
l_estimate_lines_rec.serial_number             := null;
l_estimate_lines_rec.lot_number                := null;
l_estimate_lines_rec.instance_id               := null;
l_estimate_lines_rec.instance_number           := null;
l_estimate_lines_rec.price_list_id             := p_pricelist_header_id;
/*contracts re arch changes for R12 */
l_estimate_lines_rec.contract_line_id          := p_contract_line_id;
l_estimate_lines_rec.contract_id               := l_contract_number;
l_estimate_lines_rec.contract_number           := g_contract_num;
l_estimate_lines_rec.coverage_id               := NULL ; --g_coverage_id;
l_estimate_lines_rec.coverage_txn_group_id     := NULL;--g_coverage_txn_group_id;
l_estimate_lines_rec.coverage_bill_rate_id    := null;
l_estimate_lines_rec.sub_inventory             := null;

l_estimate_lines_rec.organization_id           :=  p_org_id;
l_estimate_lines_rec.invoice_to_org_id         :=  null;--cs_std.get_item_valdn_orgzn_id;
l_estimate_lines_rec.ship_to_org_id            := null;--p_ship_to_org_id;
l_estimate_lines_rec.no_charge_flag            := 'N';
l_estimate_lines_rec.return_reason             := null;
l_estimate_lines_rec.return_by_date            := SYSDATE;
l_estimate_lines_rec.last_update_date          := null;
l_estimate_lines_rec.creation_date             := null;
l_estimate_lines_rec.last_updated_by           := null;
l_estimate_lines_rec.created_by                := null;
l_estimate_lines_rec.last_update_login         := null;
l_estimate_lines_rec.attribute1                := null;
l_estimate_lines_rec.attribute2                := null;
l_estimate_lines_rec.attribute3                := null;
l_estimate_lines_rec.attribute4                := null;
l_estimate_lines_rec.attribute5                := null;
l_estimate_lines_rec.attribute6                := null;
l_estimate_lines_rec.attribute7                := null;
l_estimate_lines_rec.attribute8                := null;
l_estimate_lines_rec.attribute9                := null;
l_estimate_lines_rec.attribute10               := null;
l_estimate_lines_rec.attribute11               := null;
l_estimate_lines_rec.attribute12               := null;
l_estimate_lines_rec.attribute13               := null;
l_estimate_lines_rec.attribute14               := null;
l_estimate_lines_rec.attribute15               := null;
l_estimate_lines_rec.context                   := null;
l_estimate_lines_rec.object_version_number     := 1;
l_estimate_lines_rec.security_group_id         := null;
l_estimate_lines_rec.resource_id               := null;
l_estimate_lines_rec.override_charge_flag      := 'N';
l_estimate_lines_rec.interface_to_om_flag      := 'N';
l_estimate_lines_rec.charge_line_type          := 'ESTIMATE';
l_estimate_lines_rec.apply_contract_discount   := 'N'; -- depot always calculates this
l_estimate_lines_rec.est_line_source_type_code := 'REPAIR_BOM';
l_estimate_lines_rec.est_line_source_id1       := null;
l_estimate_lines_rec.est_line_source_id2       := null;
l_estimate_lines_rec.ro_service_code_id        := null;
l_contract_discount_amnt := (nvl(l_selling_price,0) * nvl(l_quantity,0) ) - l_discount_price ;
l_estimate_lines_rec.contract_discount_amount := nvl(l_contract_discount_amnt,0);

-- Initialize the pricing rec.

l_estimate_lines_rec.pricing_context := null;
l_estimate_lines_rec.pricing_attribute1 :=null;
l_estimate_lines_rec.pricing_attribute2 := null;
l_estimate_lines_rec.pricing_attribute3 := null;
l_estimate_lines_rec.pricing_attribute4 := null;
l_estimate_lines_rec.pricing_attribute5 := null;
l_estimate_lines_rec.pricing_attribute6 := null;
l_estimate_lines_rec.pricing_attribute7 := null;
l_estimate_lines_rec.pricing_attribute8 := null;
l_estimate_lines_rec.pricing_attribute9 := null;
l_estimate_lines_rec.pricing_attribute10 := null;
l_estimate_lines_rec.pricing_attribute11 := null;
l_estimate_lines_rec.pricing_attribute12 := null;
l_estimate_lines_rec.pricing_attribute13 := null;
l_estimate_lines_rec.pricing_attribute14 := null;
l_estimate_lines_rec.pricing_attribute15 := null;
l_estimate_lines_rec.pricing_attribute16 := null;
l_estimate_lines_rec.pricing_attribute17 := null;
l_estimate_lines_rec.pricing_attribute18 := null;
l_estimate_lines_rec.pricing_attribute19 := null;
l_estimate_lines_rec.pricing_attribute20 := null;
l_estimate_lines_rec.pricing_attribute21 := null;
l_estimate_lines_rec.pricing_attribute22 := null;
l_estimate_lines_rec.pricing_attribute23 := null;
l_estimate_lines_rec.pricing_attribute24 := null;
l_estimate_lines_rec.pricing_attribute25 := null;
l_estimate_lines_rec.pricing_attribute26 := null;
l_estimate_lines_rec.pricing_attribute27 := null;
l_estimate_lines_rec.pricing_attribute28 := null;
l_estimate_lines_rec.pricing_attribute29 := null;
l_estimate_lines_rec.pricing_attribute30 := null;
l_estimate_lines_rec.pricing_attribute31 := null;
l_estimate_lines_rec.pricing_attribute32 := null;
l_estimate_lines_rec.pricing_attribute33 := null;
l_estimate_lines_rec.pricing_attribute34 := null;
l_estimate_lines_rec.pricing_attribute35 := null;
l_estimate_lines_rec.pricing_attribute36 := null;
l_estimate_lines_rec.pricing_attribute37 := null;
l_estimate_lines_rec.pricing_attribute38 := null;
l_estimate_lines_rec.pricing_attribute39 := null;
l_estimate_lines_rec.pricing_attribute40 := null;
l_estimate_lines_rec.pricing_attribute41 := null;
l_estimate_lines_rec.pricing_attribute42 := null;
l_estimate_lines_rec.pricing_attribute43 := null;
l_estimate_lines_rec.pricing_attribute44 := null;
l_estimate_lines_rec.pricing_attribute45 := null;
l_estimate_lines_rec.pricing_attribute46 := null;
l_estimate_lines_rec.pricing_attribute47 := null;
l_estimate_lines_rec.pricing_attribute48 := null;
l_estimate_lines_rec.pricing_attribute49 := null;
l_estimate_lines_rec.pricing_attribute50 := null;
l_estimate_lines_rec.pricing_attribute51 := null;
l_estimate_lines_rec.pricing_attribute52 := null;
l_estimate_lines_rec.pricing_attribute53 := null;
l_estimate_lines_rec.pricing_attribute54 := null;
l_estimate_lines_rec.pricing_attribute55 := null;
l_estimate_lines_rec.pricing_attribute56 := null;
l_estimate_lines_rec.pricing_attribute57 := null;
l_estimate_lines_rec.pricing_attribute58 := null;
l_estimate_lines_rec.pricing_attribute59 := null;
l_estimate_lines_rec.pricing_attribute60 := null;
l_estimate_lines_rec.pricing_attribute61 := null;
l_estimate_lines_rec.pricing_attribute62 := null;
l_estimate_lines_rec.pricing_attribute63 := null;
l_estimate_lines_rec.pricing_attribute64 := null;
l_estimate_lines_rec.pricing_attribute65 := null;
l_estimate_lines_rec.pricing_attribute66 := null;
l_estimate_lines_rec.pricing_attribute67 := null;
l_estimate_lines_rec.pricing_attribute68 := null;
l_estimate_lines_rec.pricing_attribute69 := null;
l_estimate_lines_rec.pricing_attribute70 := null;
l_estimate_lines_rec.pricing_attribute71 := null;
l_estimate_lines_rec.pricing_attribute72 := null;
l_estimate_lines_rec.pricing_attribute73 := null;
l_estimate_lines_rec.pricing_attribute74 := null;
l_estimate_lines_rec.pricing_attribute75 := null;
l_estimate_lines_rec.pricing_attribute76 := null;
l_estimate_lines_rec.pricing_attribute77 := null;
l_estimate_lines_rec.pricing_attribute78 := null;
l_estimate_lines_rec.pricing_attribute79 := null;
l_estimate_lines_rec.pricing_attribute80 := null;
l_estimate_lines_rec.pricing_attribute81 := null;
l_estimate_lines_rec.pricing_attribute82 := null;
l_estimate_lines_rec.pricing_attribute83 := null;
l_estimate_lines_rec.pricing_attribute84 := null;
l_estimate_lines_rec.pricing_attribute85 := null;
l_estimate_lines_rec.pricing_attribute86 := null;
l_estimate_lines_rec.pricing_attribute87 := null;
l_estimate_lines_rec.pricing_attribute88 := null;
l_estimate_lines_rec.pricing_attribute89 := null;
l_estimate_lines_rec.pricing_attribute90 := null;
l_estimate_lines_rec.pricing_attribute91 := null;
l_estimate_lines_rec.pricing_attribute92 := null;
l_estimate_lines_rec.pricing_attribute93 := null;
l_estimate_lines_rec.pricing_attribute94 := null;
l_estimate_lines_rec.pricing_attribute95 := null;
l_estimate_lines_rec.pricing_attribute96 := null;
l_estimate_lines_rec.pricing_attribute97 := null;
l_estimate_lines_rec.pricing_attribute98 := null;
l_estimate_lines_rec.pricing_attribute99 := null;
l_estimate_lines_rec.pricing_attribute100 := null;

IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'begin',
                        'calling create_repair_estimate_lines API');
END IF;
-- call estimate lines API.
    csd_repair_estimate_pvt.create_repair_estimate_lines(
                            p_api_version       => 1.0,
                            p_commit            => 'T',
                            p_init_msg_list     => FND_API.G_TRUE,
                            p_validation_level  => 0,
                            x_estimate_line_rec => l_estimate_lines_rec,
                            x_estimate_line_id  => l_estimate_line_id,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data);
--dbms_output.put_line(x_return_status||' - '||x_message_Data);
IF x_return_status <> 'S' THEN
	x_return_Status := 'E';
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,lc_mod_name||'Error',
                        'An error occured during execution of create_repair_estimate API'||x_msg_data);
        END IF;
	--RAISE FND_API.G_EXC_ERROR;
	RETURN;
END IF;

END LOOP;
x_return_status := 'S';
commit;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,
								  p_count   => x_msg_count,
								  p_data    => x_msg_data);

	ROLLBACK;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,
								  p_count   => x_msg_count,
								  p_data    => x_msg_data);
	ROLLBACK;

END;

FUNCTION get_default_contract(l_contract_line_id IN NUMBER,
			      l_repair_type_id IN NUMBER,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data  OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS
l_contract_num number;
l_contract_id NUMBER := NULL;

BEGIN

	IF l_contract_line_id IS NOT NULL THEN
		BEGIN
			 select distinct h.contract_number
			 into g_contract_num
			 from --okc_k_headers_b h,
			      okc_k_headers_all_b h,
			      okc_k_lines_b l
			 where h.id = l.chr_id
			   and l.id = l_contract_line_id;
		EXCEPTION
			when no_data_found THEN
				NULL;
		END;
	    IF g_contract_num IS NOT NULL THEN
		BEGIN
			SELECT business_process_id
		        INTO g_business_process_id
		        FROM csd_repair_types_b
		        WHERE repair_type_id = l_repair_type_id;
		exception
		        when no_data_found THEN
				NULL;
		END ;
	      IF g_business_process_id IS NOT NULL THEN
		BEGIN
			SELECT distinct cov.contract_id
                        INTO l_contract_id
			FROM   oks_ent_coverages_v cov
		        WHERE  cov.contract_line_id = l_contract_line_id ;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;
	      END IF;
	     END IF;
	END IF;
RETURN l_contract_id;
END get_default_contract;

FUNCTION get_item_cost(p_item_id IN number,
		       p_uom IN varchar2,
		       p_currency_code IN varchar2,
		       p_org_id IN NUMBER,
			   x_msg_count OUT NOCOPY NUMBER,
			   x_msg_data  OUT NOCOPY VARCHAR2,
			   x_return_status OUT NOCOPY VARCHAR2) return NUMBER IS
l_item_cost number;
l_return_status varchar2(2);
l_msg_count number;
l_msg_data varchar2(2000);
l_bom_resource_id number;

l_exec_error EXCEPTION;

BEGIN

-- enable costing manually. probably when running from apps context this is not required.
fnd_profile.put('CSD_ENABLE_COSTING','Y');
	CSD_COST_ANALYSIS_PVT.Get_InvItemCost(
                p_api_version           =>     1.0,
                p_commit                =>     csd_process_util.g_false,
                p_init_msg_list         =>     csd_process_util.g_true,
                p_validation_level      =>     csd_process_util.g_valid_level_full,
                x_return_status         =>     x_return_status,
                x_msg_count             =>     x_msg_count,
                x_msg_data              =>     x_msg_data,
                p_inventory_item_id     =>     p_item_id,
                p_organization_id       =>     p_org_id,
                p_charge_date           =>     sysdate,
                p_currency_code         =>     p_currency_code,
      		    p_chg_line_uom_code     =>     p_uom,
                x_item_cost             =>     l_item_cost
            );

	if x_return_status <> 'S' THEN
		l_item_cost := null;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
RETURN l_item_cost;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	RETURN l_item_cost;
	RAISE FND_API.G_EXC_ERROR;
END get_item_cost;

FUNCTION get_selling_price(p_item_id IN number,
			   p_uom IN varchar2,
			   p_quantity IN number,
			   p_pricelist_header_id IN number,
			   p_currency_code IN varchar2,
			   p_org_id IN NUMBER,
			   x_msg_count OUT NOCOPY NUMBER,
			   x_msg_data  OUT NOCOPY VARCHAR2,
			   x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS
l_selling_price  NUMBER;


l_pricing_rec       csd_process_util.pricing_attr_rec := csd_process_util.ui_pricing_attr_rec;
BEGIN

--initialize pricing attributes.

l_pricing_rec.pricing_context := null;
l_pricing_rec.pricing_attribute1 :=null;
l_pricing_rec.pricing_attribute2 := null;
l_pricing_rec.pricing_attribute3 := null;
l_pricing_rec.pricing_attribute4 := null;
l_pricing_rec.pricing_attribute5 := null;
l_pricing_rec.pricing_attribute6 := null;
l_pricing_rec.pricing_attribute7 := null;
l_pricing_rec.pricing_attribute8 := null;
l_pricing_rec.pricing_attribute9 := null;
l_pricing_rec.pricing_attribute10 := null;
l_pricing_rec.pricing_attribute11 := null;
l_pricing_rec.pricing_attribute12 := null;
l_pricing_rec.pricing_attribute13 := null;
l_pricing_rec.pricing_attribute14 := null;
l_pricing_rec.pricing_attribute15 := null;
l_pricing_rec.pricing_attribute16 := null;
l_pricing_rec.pricing_attribute17 := null;
l_pricing_rec.pricing_attribute18 := null;
l_pricing_rec.pricing_attribute19 := null;
l_pricing_rec.pricing_attribute20 := null;
l_pricing_rec.pricing_attribute21 := null;
l_pricing_rec.pricing_attribute22 := null;
l_pricing_rec.pricing_attribute23 := null;
l_pricing_rec.pricing_attribute24 := null;
l_pricing_rec.pricing_attribute25 := null;
l_pricing_rec.pricing_attribute26 := null;
l_pricing_rec.pricing_attribute27 := null;
l_pricing_rec.pricing_attribute28 := null;
l_pricing_rec.pricing_attribute29 := null;
l_pricing_rec.pricing_attribute30 := null;
l_pricing_rec.pricing_attribute31 := null;
l_pricing_rec.pricing_attribute32 := null;
l_pricing_rec.pricing_attribute33 := null;
l_pricing_rec.pricing_attribute34 := null;
l_pricing_rec.pricing_attribute35 := null;
l_pricing_rec.pricing_attribute36 := null;
l_pricing_rec.pricing_attribute37 := null;
l_pricing_rec.pricing_attribute38 := null;
l_pricing_rec.pricing_attribute39 := null;
l_pricing_rec.pricing_attribute40 := null;
l_pricing_rec.pricing_attribute41 := null;
l_pricing_rec.pricing_attribute42 := null;
l_pricing_rec.pricing_attribute43 := null;
l_pricing_rec.pricing_attribute44 := null;
l_pricing_rec.pricing_attribute45 := null;
l_pricing_rec.pricing_attribute46 := null;
l_pricing_rec.pricing_attribute47 := null;
l_pricing_rec.pricing_attribute48 := null;
l_pricing_rec.pricing_attribute49 := null;
l_pricing_rec.pricing_attribute50 := null;
l_pricing_rec.pricing_attribute51 := null;
l_pricing_rec.pricing_attribute52 := null;
l_pricing_rec.pricing_attribute53 := null;
l_pricing_rec.pricing_attribute54 := null;
l_pricing_rec.pricing_attribute55 := null;
l_pricing_rec.pricing_attribute56 := null;
l_pricing_rec.pricing_attribute57 := null;
l_pricing_rec.pricing_attribute58 := null;
l_pricing_rec.pricing_attribute59 := null;
l_pricing_rec.pricing_attribute60 := null;
l_pricing_rec.pricing_attribute61 := null;
l_pricing_rec.pricing_attribute62 := null;
l_pricing_rec.pricing_attribute63 := null;
l_pricing_rec.pricing_attribute64 := null;
l_pricing_rec.pricing_attribute65 := null;
l_pricing_rec.pricing_attribute66 := null;
l_pricing_rec.pricing_attribute67 := null;
l_pricing_rec.pricing_attribute68 := null;
l_pricing_rec.pricing_attribute69 := null;
l_pricing_rec.pricing_attribute70 := null;
l_pricing_rec.pricing_attribute71 := null;
l_pricing_rec.pricing_attribute72 := null;
l_pricing_rec.pricing_attribute73 := null;
l_pricing_rec.pricing_attribute74 := null;
l_pricing_rec.pricing_attribute75 := null;
l_pricing_rec.pricing_attribute76 := null;
l_pricing_rec.pricing_attribute77 := null;
l_pricing_rec.pricing_attribute78 := null;
l_pricing_rec.pricing_attribute79 := null;
l_pricing_rec.pricing_attribute80 := null;
l_pricing_rec.pricing_attribute81 := null;
l_pricing_rec.pricing_attribute82 := null;
l_pricing_rec.pricing_attribute83 := null;
l_pricing_rec.pricing_attribute84 := null;
l_pricing_rec.pricing_attribute85 := null;
l_pricing_rec.pricing_attribute86 := null;
l_pricing_rec.pricing_attribute87 := null;
l_pricing_rec.pricing_attribute88 := null;
l_pricing_rec.pricing_attribute89 := null;
l_pricing_rec.pricing_attribute90 := null;
l_pricing_rec.pricing_attribute91 := null;
l_pricing_rec.pricing_attribute92 := null;
l_pricing_rec.pricing_attribute93 := null;
l_pricing_rec.pricing_attribute94 := null;
l_pricing_rec.pricing_attribute95 := null;
l_pricing_rec.pricing_attribute96 := null;
l_pricing_rec.pricing_attribute97 := null;
l_pricing_rec.pricing_attribute98 := null;
l_pricing_rec.pricing_attribute99 := null;
l_pricing_rec.pricing_attribute100 := null;

if(p_item_id   is not null and
       p_pricelist_header_id is not null and
       p_uom is not null and
       p_currency_code is not null and
       p_quantity is not null  )  THEN
 -- API call to get the selling price.

 csd_process_util.get_charge_selling_price
                 (p_inventory_item_id     => p_item_id,
                  p_price_list_header_id  => p_pricelist_header_id,
            	  p_unit_of_measure_code  => p_uom,
                  p_currency_code         => p_currency_code,
                  p_quantity_required     => p_quantity,
                  p_org_id                => p_org_id,
                  p_pricing_rec           => l_pricing_rec,
                  x_selling_price         => l_selling_price,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data);
IF x_return_Status <> 'S' THEN
	l_selling_price := NULL;
	RAISE FND_API.G_EXC_ERROR;
END IF;

RETURN l_selling_price;
END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		RETURN l_selling_price;
	RAISE FND_API.G_EXC_ERROR;
	when OTHERS then
		return l_selling_price;
		RAISE;
END get_selling_price;


FUNCTION get_discount_price(p_contract_line_id IN NUMBER,p_repair_type_id IN number,
			p_selling_price IN NUMBER,p_quantity IN NUMBER,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data  OUT NOCOPY VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2)RETURN NUMBER IS
l_txn_billing_type_id number;
l_cov_txn_grp_id NUMBER := NULL ;
l_discount_price number;
l_extended_price NUMBER;
l_exec_error EXCEPTION;
BEGIN

-- calculate the extended price.

l_extended_price := nvl(p_quantity,0) * nvl(p_selling_price,0);

-- API call to get the discounted price.

CSD_CHARGE_LINE_UTIL.GET_DISCOUNTEDPRICE
               (
                 p_api_version          => 1.0,
                 p_init_msg_list        => 'T',
                 p_contract_line_id     => p_contract_line_id,
                 p_repair_type_id       => p_repair_type_id,
                 p_txn_billing_type_id  => g_txn_billing_type_id,
                 p_coverage_txn_grp_id  => l_cov_txn_grp_id,
                 p_extended_price       => l_extended_price,
                 p_no_charge_flag       => 'N',
                 x_discounted_price     => l_discount_price,
                 x_return_status        => x_return_status,
 				 x_msg_count            => x_msg_count,
                 x_msg_data             => x_msg_data
                );

IF x_return_status <> 'S' THEN
	l_discount_price := null;
	RAISE FND_API.G_EXC_ERROR;
END if;
RETURN l_discount_price;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	RETURN l_discount_price;
	RAISE FND_API.G_EXC_ERROR;
END get_discount_price;


END csd_estimates_from_bom_pvt;

/
