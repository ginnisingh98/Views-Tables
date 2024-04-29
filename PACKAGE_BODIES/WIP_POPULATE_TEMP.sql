--------------------------------------------------------
--  DDL for Package Body WIP_POPULATE_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_POPULATE_TEMP" as
/* $Header: wiputmtb.pls 120.7.12010000.4 2010/02/16 20:15:04 hliew ship $ */

PROCEDURE INSERT_TEMP
(p_transaction_mode IN NUMBER,
 p_wip_entity_id IN NUMBER,
 p_line_id IN NUMBER,
 p_transaction_date IN DATE,
 p_transaction_type_id IN NUMBER,
 p_transaction_action_id IN NUMBER,
 p_subinventory IN VARCHAR2,
 p_locator_id IN NUMBER,
 p_repetitive_days IN NUMBER,
 p_assembly_quantity IN NUMBER,
 p_operation_seq_num IN NUMBER,
 p_department_id IN NUMBER,
 p_criteria_sub IN VARCHAR2,
 p_organization_id IN NUMBER,
 p_acct_period_id IN NUMBER,
 p_last_updated_by IN NUMBER,
 p_entity_type IN NUMBER,
 p_next_seq_num IN NUMBER,
 p_calendar_code IN VARCHAR2,
 p_exception_set_id IN NUMBER,
 p_transaction_header_id IN NUMBER,
 p_commit_counter OUT  NOCOPY NUMBER)
IS
 x_transaction_source_type_id NUMBER;
 x_transaction_source_id NUMBER;
 x_item_segments VARCHAR2(2000);
 x_locator_id NUMBER;
 x_locator_control NUMBER;
 x_locator_segments VARCHAR2(2000);
 x_valid_locator_flag VARCHAR2(2);
 x_valid_subinventory_flag VARCHAR2(2);
 x_dummy BOOLEAN;
 x_rev VARCHAR2(5) := NULL;
 x_wip_commit_flag VARCHAR2(2);
 i NUMBER := 0;
 x_commit_counter NUMBER := 0;
 x_released_revs_type 		NUMBER ;
 x_released_revs_meaning 	Varchar2(30);
 l_include_yield            NUMBER;  /* ER 4369064: Component Yield Enhancement */


CURSOR CDIS IS
--bug 7654664: rounding the transaction_quantity to inventory precision
SELECT	round(WIP_COMPONENT.Determine_Txn_Quantity
                (p_transaction_action_id,
                 wro.quantity_per_assembly,
                 wro.required_quantity,
                 wro.quantity_issued,
                 p_assembly_quantity,
                 l_include_yield, /* ER 4369064: Component Yield Enhancement */
                 nvl(wro.component_yield_factor, 1), /* Bug 8319533: component_yield_factor could be null
							for jobs created prior to R12 */
                 wro.basis_type),wip_constants.inv_max_precision) transaction_quantity,  /* LBM Project */
	wro.inventory_item_id,
	msinv.secondary_inventory_name subinventory_code,
	wro.quantity_issued,
	wro.required_quantity,
	wro.quantity_per_assembly,
	bd.department_id,
	bd.department_code,
	wro.operation_seq_num,
	wro.wip_supply_type,
	wro.supply_subinventory,
	wro.supply_locator_id,
	msi.mtl_transactions_enabled_flag,
	msi.description,
	msi.location_control_code,
	msi.restrict_subinventories_code,
	msi.restrict_locators_code,
	msi.revision_qty_control_code,
	msi.primary_uom_code,
	mum.uom_class,
	msi.inventory_asset_flag,
	msi.allowed_units_lookup_code,
	msi.shelf_life_code,
	msi.shelf_life_days,
	/* decode(msi.serial_number_control_code,2,2,5,2,1) serial_control_code, */
        decode(msi.serial_number_control_code,2,2,5,5,1) serial_control_code, /* Bug 2914137 */
	msi.lot_control_code,
	msinv.locator_type,
	msi.start_auto_lot_number,
	msi.auto_lot_alpha_prefix,
	msi.start_auto_serial_number,
	msi.auto_serial_alpha_prefix,
	mil.inventory_location_id,
	mil.disable_date locator_disable_date,
	mp.stock_locator_control_code,
	WIP_COMPONENT.Valid_Subinventory(msinv.secondary_inventory_name,
				     msi.inventory_item_id,
				     p_organization_id)
		valid_subinventory_flag,
	mil.project_id,
	mil.task_id,
	wdj.project_id source_project_id,
	wdj.task_id source_task_id,
        msi.eam_item_type
FROM	mtl_parameters mp,
	mtl_item_locations mil,
	mtl_secondary_inventories msinv,
	mtl_units_of_measure mum,
	bom_departments bd,
	mtl_system_items msi,
	wip_discrete_jobs wdj,
	wip_requirement_operations wro
WHERE   wro.wip_entity_id = p_wip_entity_id
AND	wro.organization_id = p_organization_id
AND	WIP_COMPONENT.is_valid(
		p_transaction_action_id,
		wro.wip_supply_type,
		wro.required_quantity,
		wro.quantity_issued,
		p_assembly_quantity,
		p_entity_type) = WIP_CONSTANTS.YES
AND	WIP_COMPONENT.meets_criteria(
		wro.operation_seq_num,
		p_operation_seq_num,
		wro.department_id,
		p_department_id,
		wro.supply_subinventory,
		p_criteria_sub) = WIP_CONSTANTS.YES
AND     wdj.wip_entity_id = wro.wip_entity_id
AND	wdj.organization_id = wro.organization_id
AND	bd.department_id(+) = wro.department_id
AND	bd.organization_id(+) = wro.organization_id
AND	msi.inventory_item_id = wro.inventory_item_id
AND	msi.organization_id = wro.organization_id
AND	mum.uom_code = msi.primary_uom_code
AND	msinv.organization_id(+) = wro.organization_id
AND	msinv.secondary_inventory_name(+) =
		decode(p_transaction_action_id,
			WIP_CONSTANTS.SUBTRFR_ACTION, p_subinventory,
			NVL(wro.supply_subinventory, p_subinventory))
AND	mil.organization_id(+) = wro.organization_id
AND	mil.inventory_location_id(+) =
		decode(p_transaction_action_id,
			WIP_CONSTANTS.SUBTRFR_ACTION, p_locator_id,
			NVL(wro.supply_locator_id, p_locator_id))
AND	mp.organization_id = wro.organization_id
ORDER BY
wro.operation_seq_num;

CURSOR CREP IS
SELECT
	wro.inventory_item_id,
	msinv.secondary_inventory_name subinventory_code,
	sum(wro.quantity_issued) quantity_issued,
	sum(wro.required_quantity) required_quantity,
	sum(wro.quantity_per_assembly) quantity_per_assembly,
	bd.department_id,
	bd.department_code,
	wro.operation_seq_num,
	wro.wip_supply_type,
	wro.supply_subinventory,
	wro.supply_locator_id,
	msi.mtl_transactions_enabled_flag,
	msi.description,
	msi.location_control_code,
	msi.restrict_subinventories_code,
	msi.restrict_locators_code,
	msi.revision_qty_control_code,
	msi.primary_uom_code,
	mum.uom_class,
	msi.inventory_asset_flag,
	msi.allowed_units_lookup_code,
	msi.shelf_life_code,
	msi.shelf_life_days,
	decode(msi.serial_number_control_code,2,2,5,5,1) serial_control_code, /* Bug 2914137 */
	msi.lot_control_code,
	msinv.locator_type,
	msi.start_auto_lot_number,
	msi.auto_lot_alpha_prefix,
	msi.start_auto_serial_number,
	msi.auto_serial_alpha_prefix,
	mil.inventory_location_id,
	mil.disable_date locator_disable_date,
	mp.stock_locator_control_code,
--bug 7654664: rounding the transaction_quantity to inventory precision
	round(SUM((LEAST(bcd1.next_seq_num+wrs.processing_work_days,
		   p_next_seq_num + p_repetitive_days) -
	     GREATEST(bcd1.next_seq_num, p_next_seq_num)) *
	     wro.quantity_per_assembly * wrs.daily_production_rate *
	     decode(p_transaction_action_id, 1, -1, 2, -1, 33, -1, 1)/
         decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1))),
	 wip_constants.inv_max_precision) transaction_quantity /* ER 4369064: Component Yield Enhancement */
FROM	mtl_parameters mp,
	mtl_item_locations mil,
	mtl_secondary_inventories msinv,
	mtl_units_of_measure mum,
	bom_departments bd,
	mtl_system_items msi,
	bom_calendar_dates bcd1,
	wip_requirement_operations wro,
	wip_repetitive_schedules wrs
WHERE   wro.wip_entity_id = wrs.wip_entity_id
AND	wro.organization_id = wrs.organization_id
AND	wro.repetitive_schedule_id = wrs.repetitive_schedule_id
AND	wrs.wip_entity_id = p_wip_entity_id
AND	wrs.organization_id = p_organization_id
AND	wrs.line_id = p_line_id
AND	bcd1.calendar_code(+) = p_calendar_code
AND	bcd1.exception_set_id(+) = p_exception_set_id
--bug 5470386 truncating the time factor from both the date fields as
-- calendar date doesnot have the time factor but date required field includes the time factor
--and therefore repetitive schedule is not defaulting
--AND     bcd1.calendar_date(+) = trunc(wro.date_required)
AND	trunc(bcd1.calendar_date(+)) = trunc(wro.date_required)
AND	bcd1.next_seq_num(+) < p_next_seq_num + p_repetitive_days
AND	bcd1.next_seq_num + wrs.processing_work_days > p_next_seq_num
AND	WIP_COMPONENT.is_valid(
		p_transaction_action_id,
		wro.wip_supply_type,
		wro.required_quantity,
		wro.quantity_issued,
		NULL,
		p_entity_type) = WIP_CONSTANTS.YES
AND	WIP_COMPONENT.meets_criteria(
		wro.operation_seq_num,
		p_operation_seq_num,
		wro.department_id,
		p_department_id,
		wro.supply_subinventory,
		p_criteria_sub) = WIP_CONSTANTS.YES
AND	bd.department_id(+) = wro.department_id
AND	bd.organization_id(+) = wro.organization_id
AND	msi.inventory_item_id = wro.inventory_item_id
AND	msi.organization_id = wro.organization_id
AND	mum.uom_code = msi.primary_uom_code
AND	msinv.organization_id(+) = wro.organization_id
AND	msinv.secondary_inventory_name(+) =
		decode(p_transaction_action_id,
			WIP_CONSTANTS.SUBTRFR_ACTION, p_subinventory,
			NVL(wro.supply_subinventory, p_subinventory))
AND	mil.organization_id(+) = wro.organization_id
AND	mil.inventory_location_id(+) =
		decode(p_transaction_action_id,
			WIP_CONSTANTS.SUBTRFR_ACTION, p_locator_id,
			NVL(wro.supply_locator_id, p_locator_id))
AND	mp.organization_id = wro.organization_id
/* Fix for bug 2570492 Adding filtering by status_type */
AND     status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
GROUP BY
        wro.inventory_item_id,
        msinv.secondary_inventory_name,
        bd.department_id,
        bd.department_code,
        wro.operation_seq_num,
        wro.wip_supply_type,
        wro.supply_subinventory,
        wro.supply_locator_id,
        msi.mtl_transactions_enabled_flag,
        msi.description,
        msi.location_control_code,
        msi.restrict_subinventories_code,
        msi.restrict_locators_code,
        msi.revision_qty_control_code,
        msi.primary_uom_code,
        mum.uom_class,
        msi.inventory_asset_flag,
        msi.allowed_units_lookup_code,
        msi.shelf_life_code,
        msi.shelf_life_days,
        decode(msi.serial_number_control_code,2,2,5,5,1), /* Bug 2914137 */
        msi.lot_control_code,
        msinv.locator_type,
        msi.start_auto_lot_number,
        msi.auto_lot_alpha_prefix,
        msi.start_auto_serial_number,
        msi.auto_serial_alpha_prefix,
        mil.inventory_location_id,
        mil.disable_date,
        mp.stock_locator_control_code
ORDER BY
wro.operation_seq_num,
wro.supply_subinventory
;

BEGIN
        x_wip_commit_flag := 'Y';

	X_COMMIT_COUNTER := 0;

	/* Source Type and Source are set differently for Subinventory Replen */

	IF p_transaction_action_id = WIP_CONSTANTS.SUBTRFR_ACTION THEN
	/*Start: Bug 6460181: Instead of a constant value for x_transaction_source_type_id, the value is selected from mtl_transaction_type table*/

		SELECT transaction_source_type_id
		into x_transaction_source_type_id
		from mtl_transaction_types where transaction_type_id = p_transaction_type_id ;
		--x_transaction_source_type_id := 13;
		x_transaction_source_id := NULL;
	ELSE
		x_transaction_source_type_id := 5;
		x_transaction_source_id := p_wip_entity_id;
	END IF;

    /* ER 4369064: Component Yield Enhancement */
    select nvl(include_component_yield,1) /* Handled Null value */
      into l_include_yield
      from wip_parameters
     where organization_id = p_organization_id;

          --  set up release type
          /* 2999230 */
          wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                     x_released_revs_meaning
                                                    );

        --6 is eAM job
	IF p_entity_type in (WIP_CONSTANTS.DISCRETE,WIP_CONSTANTS.LOTBASED,6) THEN
 	    FOR C IN CDIS LOOP

		x_dummy := FND_FLEX_KEYVAL.validate_ccid(
				appl_short_name => 'INV',
				key_flex_code => 'MSTK',
				structure_number => 101,
				combination_id => C.inventory_item_id,
				data_set => p_organization_id);

		x_item_segments := FND_FLEX_KEYVAL.concatenated_values;

		x_locator_id := C.inventory_location_id;
               /* Fix for Bug# 2149033. Added x_locator_id condition in if condition */
                IF(C.subinventory_code IS NOT NULL) and (x_locator_id IS NOT NULL)  THEN
			x_valid_locator_flag := WIP_COMPONENT.Valid_Locator
			(x_locator_id,
			 C.inventory_item_id,
			 p_organization_id,
			 C.stock_locator_control_code,
			 C.locator_type,
			 C.location_control_code,
			 C.restrict_locators_code,
			 C.locator_disable_date,
			 x_locator_control);

			IF x_locator_control = 1 THEN
				x_locator_segments := NULL;
			ELSE

				x_dummy := FND_FLEX_KEYVAL.validate_ccid(
					appl_short_name => 'INV',
					key_flex_code => 'MTLL',
					structure_number => 101,
					combination_id => x_locator_id,
					data_set => p_organization_id);

                                -- fix for bug 4084598
				--x_locator_segments := FND_FLEX_KEYVAL.concatenated_values;
			END IF;
		ELSE
			x_valid_locator_flag := 'N';
			x_locator_id := null; --no locator when sub is not populated
			x_locator_segments := NULL;
		END IF;

		IF C.revision_qty_control_code = WIP_CONSTANTS.REV THEN
			BOM_REVISIONS.Get_Revision
			(type => 'PART',
			 eco_status => x_released_revs_meaning,
			 examine_type => 'ALL',
			 org_id => P_Organization_Id,
			 item_id => C.inventory_item_id,
			 rev_date => p_transaction_date,
			 itm_rev => x_rev);
                ELSE
                       x_rev := NULL;
		END IF;

		IF C.mtl_transactions_enabled_flag = 'N'
		   OR (C.valid_subinventory_flag = 'N')
		   OR (x_valid_locator_flag = 'N')
		   OR (C.lot_control_code <> 1
			AND C.transaction_quantity <> 0)
		   OR (C.serial_control_code <> 1
			AND C.transaction_quantity <> 0)
		   OR (C.lot_control_code <> 1
			AND C.serial_control_code <> 1)
		   OR (C.transaction_quantity = 0
			AND p_assembly_quantity IS NOT NULL
			AND p_transaction_action_id IN
				(WIP_CONSTANTS.RETNEGC_ACTION,
				 WIP_CONSTANTS.RETCOMP_ACTION)) THEN
			x_wip_commit_flag := 'N';
			X_COMMIT_COUNTER := X_COMMIT_COUNTER + 1;
		ELSE
			x_wip_commit_flag := 'Y';
		END IF;

                -- bug3430508: do not insert subinv/loc if material status
                --             disables it
                if (inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           p_transaction_type_id, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           p_organization_id,
                           C.inventory_item_id,
                           C.subinventory_code,
                           NULL,
                           NULL,
                           NULL,
                           'Z') = 'N') then
                                  C.subinventory_code := null;
                                  x_locator_id := null;
                end if;

                if (inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           p_transaction_type_id, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           p_organization_id,
                           C.inventory_item_id,
                           NULL,
                           x_locator_id,
                           NULL,
                           NULL,
                           'L') = 'N') then
                                  x_locator_id := null;
                end if;

                INSERT INTO mtl_material_transactions_temp
                    (item_segments,
                     locator_segments,
                     primary_switch,
                     transaction_header_id,
                     transaction_mode,
                     lock_flag,
                     inventory_item_id,
                     subinventory_code,
                     primary_quantity,
                     transaction_quantity,
                     transaction_date,
                     organization_id,
                     acct_period_id,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     transaction_source_id,
                     transaction_source_type_id,
                     transaction_type_id,
                     transaction_action_id,
                     wip_entity_type,
                     repetitive_line_id,
                     department_id,
                     department_code,
                     locator_id,
                     required_flag,
                     operation_seq_num,
                     transfer_subinventory,
                     transfer_to_location,
                     wip_supply_type,
                     supply_subinventory,
                     supply_locator_id,
                     item_trx_enabled_flag,
                     item_description,
                     item_location_control_code,
                     item_restrict_subinv_code,
                     item_restrict_locators_code,
                     item_revision_qty_control_code,
                     revision,
                     item_primary_uom_code,
                     transaction_uom,
                     item_uom_class,
                     item_inventory_asset_flag,
                     allowed_units_lookup_code,
                     item_shelf_life_code,
                     item_shelf_life_days,
                     item_serial_control_code,
                     item_lot_control_code,
                     current_locator_control_code,
                     wip_commit_flag,
                     number_of_lots_entered,
                     next_lot_number,
                     next_serial_number,
                     lot_alpha_prefix,
                     serial_alpha_prefix,
                     valid_subinventory_flag,
                     valid_locator_flag,
                     negative_req_flag,
                     posting_flag,
                     process_flag,
		     project_id,
		     task_id,
		     source_project_id,
		     source_task_id)
		VALUES
                    (x_item_segments,
                     x_locator_segments,
                     i,
                     p_transaction_header_id,
                     decode(p_transaction_mode,2,2,1),
                     'N',
                     C.inventory_item_id,
                     C.subinventory_code,
                     /*Fix for bug 9371748*/
                     decode(C.eam_item_type, WIP_CONSTANTS.REBUILD_ITEM_TYPE, decode(p_entity_type,WIP_CONSTANTS.EAM,1,C.transaction_quantity), C.transaction_quantity),
                     decode(C.eam_item_type, WIP_CONSTANTS.REBUILD_ITEM_TYPE, decode(p_entity_type,WIP_CONSTANTS.EAM,1,C.transaction_quantity), C.transaction_quantity),
                     p_transaction_date,
                     p_organization_id,
                     p_acct_period_id,
                     SYSDATE,
                     p_last_updated_by,
                     SYSDATE,
                     p_last_updated_by,
                     x_transaction_source_id,
                     x_transaction_source_type_id,
                     p_transaction_type_id,
                     p_transaction_action_id,
                     p_entity_type,
                     p_line_id,
                     C.department_id,
                     C.department_code,
                     x_locator_id,
                     1,
                     C.operation_seq_num,
                     DECODE(    p_transaction_action_id,
                                2,C.supply_subinventory,
                                NULL),
                     DECODE(    p_transaction_action_id,
                                2,C.supply_locator_id,
                                NULL),
                     C.wip_supply_type,
                     C.supply_subinventory,
                     C.supply_locator_id,
                     C.mtl_transactions_enabled_flag,
                     C.description,
                     C.location_control_code,
                     C.restrict_subinventories_code,
                     C.restrict_locators_code,
                     C.revision_qty_control_code,
                     x_rev,
                     C.primary_uom_code,
                     C.primary_uom_code,
                     C.uom_class,
                     C.inventory_asset_flag,
                     C.allowed_units_lookup_code,
                     C.shelf_life_code,
                     C.shelf_life_days,
                     C.serial_control_code,
                     C.lot_control_code,
                     C.locator_type,
                     x_wip_commit_flag,
                     0,
                     C.start_auto_lot_number,
                     C.start_auto_serial_number,
                     C.auto_lot_alpha_prefix,
                     C.auto_serial_alpha_prefix,
                     C.valid_subinventory_flag,
                     x_valid_locator_flag,
                     sign(C.required_quantity),
                     'Y',
                     'Y',
		     C.project_id,
		     C.task_id,
		     C.source_project_id,
		     C.source_task_id);

		i := i + 1;

	    END LOOP;

	ELSE

 	    FOR C IN CREP LOOP

		x_dummy := FND_FLEX_KEYVAL.validate_ccid(
				appl_short_name => 'INV',
				key_flex_code => 'MSTK',
				structure_number => 101,
				combination_id => C.inventory_item_id,
				data_set => p_organization_id);

		x_item_segments := FND_FLEX_KEYVAL.concatenated_values;
                IF(C.subinventory_code IS NULL) THEN
			x_valid_subinventory_flag := 'N';
			x_valid_locator_flag := 'N';
		ELSE
			x_valid_subinventory_flag := WIP_COMPONENT.Valid_Subinventory
				(C.subinventory_code,
				 C.inventory_item_id,
				 p_organization_id);

			x_locator_id := C.inventory_location_id;

			x_valid_locator_flag := WIP_COMPONENT.Valid_Locator
			(x_locator_id,
			 C.inventory_item_id,
			 p_organization_id,
			 C.stock_locator_control_code,
			 C.locator_type,
			 C.location_control_code,
			 C.restrict_locators_code,
			 C.locator_disable_date,
			 x_locator_control);

			IF x_locator_control = 1 THEN
				x_locator_segments := NULL;
			ELSE

				x_dummy := FND_FLEX_KEYVAL.validate_ccid(
					appl_short_name => 'INV',
					key_flex_code => 'MTLL',
					structure_number => 101,
					combination_id => x_locator_id,
					data_set => p_organization_id);

                                -- fix for bug 4084598
				--x_locator_segments := FND_FLEX_KEYVAL.concatenated_values;
			END IF;
		END IF;

		IF C.revision_qty_control_code = WIP_CONSTANTS.REV THEN
			BOM_REVISIONS.Get_Revision
			(type => 'PART',
			 eco_status => x_released_revs_meaning,
			 examine_type => 'ALL',
			 org_id => P_Organization_Id,
			 item_id => C.inventory_item_id,
			 rev_date => p_transaction_date,
			 itm_rev => x_rev);
                ELSE
                     x_rev := NULL;
		END IF;

		IF C.mtl_transactions_enabled_flag = 'N'
		   OR (x_valid_subinventory_flag = 'N')
		   OR (x_valid_locator_flag = 'N')
		   OR (C.lot_control_code <> 1
			AND C.transaction_quantity <> 0)
		   OR (C.serial_control_code <> 1
			AND C.transaction_quantity <> 0)
		   OR (C.lot_control_code <> 1
			AND C.serial_control_code <> 1)
		   OR (C.transaction_quantity = 0
			AND p_assembly_quantity IS NOT NULL
			AND p_transaction_action_id IN
				(WIP_CONSTANTS.RETNEGC_ACTION,
				 WIP_CONSTANTS.RETCOMP_ACTION)) THEN
			x_wip_commit_flag := 'N';
			X_COMMIT_COUNTER := X_COMMIT_COUNTER + 1;
		ELSE
			x_wip_commit_flag := 'Y';
		END IF;

                INSERT INTO mtl_material_transactions_temp
                    (item_segments,
                     locator_segments,
                     primary_switch,
                     transaction_header_id,
                     transaction_mode,
                     lock_flag,
                     inventory_item_id,
                     subinventory_code,
                     primary_quantity,
                     transaction_quantity,
                     transaction_date,
                     organization_id,
                     acct_period_id,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     transaction_source_id,
                     transaction_source_type_id,
                     transaction_type_id,
                     transaction_action_id,
                     wip_entity_type,
                     repetitive_line_id,
                     department_id,
                     department_code,
                     locator_id,
                     required_flag,
                     operation_seq_num,
                     transfer_subinventory,
                     transfer_to_location,
                     wip_supply_type,
                     supply_subinventory,
                     supply_locator_id,
                     item_trx_enabled_flag,
                     item_description,
                     item_location_control_code,
                     item_restrict_subinv_code,
                     item_restrict_locators_code,
                     item_revision_qty_control_code,
                     revision,
                     item_primary_uom_code,
                     transaction_uom,
                     item_uom_class,
                     item_inventory_asset_flag,
                     allowed_units_lookup_code,
                     item_shelf_life_code,
                     item_shelf_life_days,
                     item_serial_control_code,
                     item_lot_control_code,
                     current_locator_control_code,
                     wip_commit_flag,
                     number_of_lots_entered,
                     next_lot_number,
                     next_serial_number,
                     lot_alpha_prefix,
                     serial_alpha_prefix,
                     valid_subinventory_flag,
                     valid_locator_flag,
                     negative_req_flag,
                     posting_flag,
                     process_flag)
		VALUES
                    (x_item_segments,
                     x_locator_segments,
                     i,
                     p_transaction_header_id,
                     decode(p_transaction_mode,2,2,1),
                     'N',
                     C.inventory_item_id,
                     C.subinventory_code,
                     C.transaction_quantity,
                     C.transaction_quantity,
                     p_transaction_date,
                     p_organization_id,
                     p_acct_period_id,
                     SYSDATE,
                     p_last_updated_by,
                     SYSDATE,
                     p_last_updated_by,
                     x_transaction_source_id,
                     x_transaction_source_type_id,
                     p_transaction_type_id,
                     p_transaction_action_id,
                     p_entity_type,
                     p_line_id,
                     C.department_id,
                     C.department_code,
                     x_locator_id,
                     1,				/* Required_Flag */
                     C.operation_seq_num,
                     DECODE(	p_transaction_action_id,
				2,C.supply_subinventory,
				NULL),
                     DECODE(	p_transaction_action_id,
				2,C.supply_locator_id,
				NULL),
                     C.wip_supply_type,
                     C.supply_subinventory,
                     C.supply_locator_id,
                     C.mtl_transactions_enabled_flag,
                     C.description,
                     C.location_control_code,
                     C.restrict_subinventories_code,
                     C.restrict_locators_code,
                     C.revision_qty_control_code,
                     x_rev,
                     C.primary_uom_code,
                     C.primary_uom_code,
                     C.uom_class,
                     C.inventory_asset_flag,
                     C.allowed_units_lookup_code,
                     C.shelf_life_code,
                     C.shelf_life_days,
                     C.serial_control_code,
                     C.lot_control_code,
                     C.locator_type,
                     x_wip_commit_flag,
                     0,				/* Num Lots Entered */
                     C.start_auto_lot_number,
                     C.start_auto_serial_number,
                     C.auto_lot_alpha_prefix,
                     C.auto_serial_alpha_prefix,
                     x_valid_subinventory_flag,
                     x_valid_locator_flag,
                     sign(C.required_quantity),
                     'Y',
                     'Y');

		i := i + 1;

	    END LOOP;

	END IF;

	P_COMMIT_COUNTER := X_COMMIT_COUNTER;

END INSERT_TEMP;

END WIP_POPULATE_TEMP;

/
