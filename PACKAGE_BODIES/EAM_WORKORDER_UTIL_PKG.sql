--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDER_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDER_UTIL_PKG" as
/* $Header: EAMWOUTB.pls 120.18.12010000.4 2010/01/04 09:22:13 jgootyag ship $ */
g_supply_type VARCHAR2(30) := EAM_CONSTANTS.G_SUPPLY_TYPE;

PROCEDURE retrieve_asset_bom(
		i_organization_id	IN 	NUMBER,
		i_asset_number		IN	VARCHAR2,
		i_asset_group_id	IN	NUMBER,
		p_context			IN VARCHAR2, -- stocked inventory or non-stocked inventory
 		o_bom_table		OUT NOCOPY	t_bom_table,
		o_error_code		OUT NOCOPY	NUMBER) IS

  l_index NUMBER;
  l_index1 NUMBER;
  l_bill_sequence_id NUMBER;
  l_phantom_bom	t_bom_table;

  CURSOR components(l_stock_flag VARCHAR2) IS
    select bic.component_sequence_id,
           bic.component_item_id,
	   msik.concatenated_segments component_item,
	   msik.description,
	   bic.component_quantity,
	   bic.component_yield_factor component_yield,
	   msik.primary_uom_code uom,
	   bic.wip_supply_type,
	   lu.meaning wip_supply_type_disp
    from bom_inventory_components bic,
	 mtl_system_items_kfv msik,
	 mfg_lookups lu
    where bic.bill_sequence_id = l_bill_sequence_id
      and bic.effectivity_date <= sysdate
      and (bic.disable_date >= sysdate or
	   bic.disable_date is null)
      and i_asset_number >= bic.from_end_item_unit_number
      and (i_asset_number <= bic.to_end_item_unit_number or
	   bic.to_end_item_unit_number is null)
      and msik.organization_id = i_organization_id
      and msik.inventory_item_id = bic.component_item_id
      and lu.lookup_type(+) = g_supply_type
      and lu.lookup_code(+) = bic.wip_supply_type
    --fix for 3371471.added following condition to fetch only stockable items
      and msik.stock_enabled_flag= l_stock_flag
    order by component_sequence_id;

          /* Bug#3013574: If it is for rebuildable item
     then the no check on BOM_INVENTORY_COMPONENTS.from_end_item_unit_number
     and BOM_INVENTORY_COMPONENTS.to_end_item_unit_number is required */

       CURSOR C_REBUILD_COMPONENTS( l_stock_flag VARCHAR2) IS
    SELECT
      bic.component_sequence_id,
      bic.component_item_id,
      msik.concatenated_segments component_item,
      msik.description,
      bic.component_quantity,
      bic.component_yield_factor component_yield,
      msik.primary_uom_code uom,
      bic.wip_supply_type,
      lu.meaning wip_supply_type_disp
    FROM
      bom_inventory_components bic,
      mtl_system_items_kfv msik,
      mfg_lookups lu
    WHERE
      bic.bill_sequence_id = l_bill_sequence_id
      and bic.effectivity_date <= sysdate
      and (bic.disable_date >= sysdate or
	   bic.disable_date is null)
      and msik.organization_id = i_organization_id
      and msik.inventory_item_id = bic.component_item_id
      and lu.lookup_type(+) = g_supply_type
      and lu.lookup_code(+) = bic.wip_supply_type
     --fix for 3371471.added following condition to fetch only stockable items
      and msik.stock_enabled_flag= l_stock_flag
    ORDER BY component_sequence_id;

  l_record components%ROWTYPE;

  /* BUG#3013574 */
  l_eam_item_type NUMBER;
  l_record_rebuild C_REBUILD_COMPONENTS%ROWTYPE;
  l_stock_enabled_flag VARCHAR2(1) ;

  PROCEDURE explode_phantom_bom(
	i_phantom_item_id	IN	NUMBER,
	i_phantom_quantity	IN	NUMBER,
	i_phantom_yield		IN	NUMBER,
	o_phantom_bom		OUT NOCOPY	t_bom_table) IS
    CURSOR phantom_comp IS
      select bic.component_sequence_id,
             bic.component_item_id,
	     msik.concatenated_segments component_item,
	     msik.description,
	     bic.component_quantity,
	     bic.component_yield_factor component_yield,
	     msik.primary_uom_code uom,
	     bic.wip_supply_type,
	     lu.meaning wip_supply_type_disp
      from bom_inventory_components bic,
	   bom_bill_of_materials bbom,
  	   mtl_system_items_kfv msik,
	   mfg_lookups lu
      where bbom.assembly_item_id = i_phantom_item_id
        and bbom.organization_id = i_organization_id
        and bbom.alternate_bom_designator is null
        and bic.bill_sequence_id = bbom.common_bill_sequence_id
        and bic.effectivity_date <= sysdate
        and (bic.disable_date >= sysdate or
	     bic.disable_date is null)
        and i_asset_number >= bic.from_end_item_unit_number
        and (i_asset_number <= bic.to_end_item_unit_number or
	     bic.to_end_item_unit_number is null)
        and msik.organization_id = i_organization_id
        and msik.inventory_item_id = bic.component_item_id
        and lu.lookup_type(+) = g_supply_type
        and lu.lookup_code(+) = bic.wip_supply_type
      order by component_sequence_id;


  BEGIN
    -- Clear
    l_phantom_bom.delete;
    -- Select
/****************************************
 *      UNFINISHED!!!!			*
 ****************************************/
/*** We don't need phantom actually  ***/


  END explode_phantom_bom;


BEGIN
  -- Clear
  o_bom_table.delete;
  -- Get the Bill-Sequence
  begin
    select common_bill_sequence_id
    into l_bill_sequence_id
    from bom_bill_of_materials
    where organization_id = i_organization_id
      and assembly_item_id = i_asset_group_id
      and alternate_bom_designator is null;
  exception
    when NO_DATA_FOUND then               /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
      return;
  end;

  IF ( p_context = 'REQUIREMENTS') THEN
	l_stock_enabled_flag := 'Y' ;
  ELSIF ( p_context = 'DIRECT_ITEMS') THEN
	l_stock_enabled_flag := 'N' ;
  END IF ;

  -- Retrieve the Asset BOM
  l_index := 0;

  /*  Bug#3013574: Fetch rebuild/Asset BOM depending upon the type of workorder
      for which it is being summoned. */
  SELECT
    NVL(msi.eam_item_type,-1) INTO l_eam_item_type
  FROM
    mtl_system_items_b msi
  WHERE
    msi.inventory_item_id = i_asset_group_id
    and organization_id = i_organization_id;

  /* Bug#3013574: If the i_asset_group_id being passed corresponds to Asset Group
     continue doing the work as is being done. If it is for rebuildable item
     then the no check on BOM_INVENTORY_COMPONENTS.from_end_item_unit_number
     and BOM_INVENTORY_COMPONENTS.to_end_item_unit_number is required */

  IF (l_eam_item_type = 1) THEN
    OPEN components( l_stock_enabled_flag );
    LOOP
      fetch components into l_record;
      exit when components%notfound;
      if l_record.wip_supply_type = 6 then -- phantom
       null;
      else
        o_bom_table(l_index).component_sequence_id := l_record.component_sequence_id;
        o_bom_table(l_index).component_item_id := l_record.component_item_id;
        o_bom_table(l_index).component_item := l_record.component_item;
        o_bom_table(l_index).description := l_record.description;
        o_bom_table(l_index).component_quantity := l_record.component_quantity;
        o_bom_table(l_index).component_yield := l_record.component_yield;
        o_bom_table(l_index).uom := l_record.uom;
        o_bom_table(l_index).wip_supply_type := l_record.wip_supply_type;
        o_bom_table(l_index).wip_supply_type_disp := l_record.wip_supply_type_disp;
        l_index := l_index+1;
      end if;
    END LOOP;
    CLOSE components;
  ELSIF (l_eam_item_type = 3) THEN
    OPEN C_REBUILD_COMPONENTS ( l_stock_enabled_flag );
    LOOP
      FETCH C_REBUILD_COMPONENTS INTO l_record_rebuild;
      EXIT WHEN C_REBUILD_COMPONENTS%NOTFOUND;
      IF l_record_rebuild.wip_supply_type = 6 THEN -- phantom
        null;
      ELSE
        o_bom_table(l_index).component_sequence_id := l_record_rebuild.component_sequence_id;
        o_bom_table(l_index).component_item_id := l_record_rebuild.component_item_id;
        o_bom_table(l_index).component_item := l_record_rebuild.component_item;
        o_bom_table(l_index).description := l_record_rebuild.description;
        o_bom_table(l_index).component_quantity := l_record_rebuild.component_quantity;
        o_bom_table(l_index).component_yield := l_record_rebuild.component_yield;
        o_bom_table(l_index).uom := l_record_rebuild.uom;
        o_bom_table(l_index).wip_supply_type := l_record_rebuild.wip_supply_type;
        o_bom_table(l_index).wip_supply_type_disp := l_record_rebuild.wip_supply_type_disp;
        l_index := l_index+1;
      END IF;
    END LOOP;
    CLOSE C_REBUILD_COMPONENTS;
  END IF;
END retrieve_asset_bom;


PROCEDURE copy_to_bom(
		i_organization_id	IN	NUMBER,
		i_organization_code	IN	VARCHAR2,
		i_asset_number		IN	VARCHAR2,
		i_asset_group_id	IN	NUMBER,
		i_component_table	IN	t_component_table,
		o_error_code		OUT NOCOPY	NUMBER) IS

--  PRAGMA AUTONOMOUS_TRANSACTION;

  l_index1	NUMBER;
  l_index2	NUMBER;

  l_assembly_item_name	VARCHAR2(81);

  l_bom_header_rec	BOM_BO_PUB.bom_head_rec_type;
  l_bom_component_tbl 	BOM_BO_PUB.bom_comps_tbl_type;
  o_bom_header_rec	BOM_BO_PUB.bom_head_rec_type;
  o_bom_revision_tbl	BOM_BO_PUB.bom_revision_tbl_type;
  o_bom_component_tbl 	BOM_BO_PUB.bom_comps_tbl_type;
  o_bom_ref_designator_tbl	BOM_BO_PUB.bom_ref_designator_tbl_type;
  o_bom_sub_component_tbl	BOM_BO_PUB.bom_sub_component_tbl_type;
  o_return_status	varchar2(100);
  o_msg_count	number;

  l_error_msg	Error_Handler.Error_tbl_type;
  l_tmp number;
  l_seq_increment NUMBER;
  l_start_item_seq_number NUMBER;

  -- Check whether the given component already in the bom of given assembly
  FUNCTION comp_exists(i_organization_id 	IN	NUMBER,
		       i_assembly_item_id	IN	NUMBER,
		       i_serial_number		IN	VARCHAR2,
		       i_component_item_id	IN	NUMBER)
    RETURN BOOLEAN IS
    l_component_item_id NUMBER;
  BEGIN
    select bic.component_item_id
    into l_component_item_id
    from bom_bill_of_materials bbom,
	 bom_inventory_components bic
    where bbom.assembly_item_id = i_assembly_item_id
      and bbom.organization_id = i_organization_id
      and bbom.alternate_bom_designator is null
      and bbom.common_bill_sequence_id = bic.bill_sequence_id
      and bic.component_item_id = i_component_item_id
      and bic.disable_date is null /*consider only enabled components, added for #6072910*/
      and i_serial_number >= bic.from_end_item_unit_number
      and (i_serial_number <= bic.to_end_item_unit_number or
           bic.to_end_item_unit_number is null);
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN     /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
      RETURN FALSE;
  END comp_exists;

-- Bug# 3844669 : Function to compute item sequence number
   FUNCTION get_item_sequence_num(i_organization_id      IN        NUMBER,
                            i_assembly_item_id        IN        NUMBER)
     RETURN NUMBER IS
     l_bill_sequence_id NUMBER;
     l_item_sequence_num NUMBER;
     l_seq_increment NUMBER;
   BEGIN
     l_item_sequence_num := 100;

     select common_bill_sequence_id
     into l_bill_sequence_id
     from bom_bill_of_materials
     where organization_id = i_organization_id
       and assembly_item_id = i_assembly_item_id
       and alternate_bom_designator is null;

     select nvl(max(item_num),100)
     into l_item_sequence_num
     from bom_inventory_components
     where bill_sequence_id=l_bill_sequence_id;

     l_seq_increment := to_number(nvl(fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT'),'10'));
     l_item_sequence_num := l_item_sequence_num + l_seq_increment;

     RETURN l_item_sequence_num;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN l_item_sequence_num;
   END get_item_sequence_num;

BEGIN
  o_error_code := 0;
  -- Return if no Components
  if i_component_table.COUNT <= 0 then
    RETURN;
  end if;
  -- Bug# 3844669 : Added code to compute current starting item sequence number in assembly item BOM.
  l_start_item_seq_number := get_item_sequence_num(i_organization_id, i_asset_group_id);
  l_seq_increment := to_number(nvl(fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT'),'10'));
  -- Construct the Components Table
  l_index1 := i_component_table.FIRST;
  l_index2 := 1;
  select concatenated_segments
  into l_assembly_item_name
  from mtl_system_items_kfv
  where organization_id = i_organization_id
    and inventory_item_id = i_asset_group_id;
  loop
    if not comp_exists(i_organization_id, i_asset_group_id, i_asset_number,
		       i_component_table(l_index1).component_item_id) then
      -- Add this Entry
        -- Set the context
      l_bom_component_tbl(l_index2).assembly_item_name := l_assembly_item_name;
      l_bom_component_tbl(l_index2).organization_code := i_organization_code;
      l_bom_component_tbl(l_index2).alternate_bom_code := null;
      l_bom_component_tbl(l_index2).transaction_type := 'CREATE';
        -- Copy the Data
      l_bom_component_tbl(l_index2).component_item_name := i_component_table(l_index1).component_item;
      l_bom_component_tbl(l_index2).start_effective_date := i_component_table(l_index1).start_effective_date;
      l_bom_component_tbl(l_index2).quantity_per_assembly := i_component_table(l_index1).quantity_per_assembly;
      l_bom_component_tbl(l_index2).wip_supply_type := i_component_table(l_index1).wip_supply_type;
      l_bom_component_tbl(l_index2).supply_subinventory := i_component_table(l_index1).supply_subinventory;
      l_bom_component_tbl(l_index2).location_name := i_component_table(l_index1).supply_locator_name;
      l_bom_component_tbl(l_index2).from_end_item_unit_number := i_asset_number;
      l_bom_component_tbl(l_index2).to_end_item_unit_number := i_asset_number;
      -- Default In Required Fields. All hardcoded values are as per design. Pls refer to eTRM for object: BOM_INVENTORY_COMPONENTS to view description of below hardcoded columns.
      l_bom_component_tbl(l_index2).operation_sequence_number := 1;
      -- Modified for bug# 3844669.
      l_bom_component_tbl(l_index2).item_sequence_number := l_start_item_seq_number + l_seq_increment*(l_index2 - 1);
      l_bom_component_tbl(l_index2).projected_yield := 1;
      l_bom_component_tbl(l_index2).planning_percent := 100;
      l_bom_component_tbl(l_index2).quantity_related := 2;
      l_bom_component_tbl(l_index2).include_in_cost_rollup := 1;
      l_bom_component_tbl(l_index2).check_atp := 2;
      l_bom_component_tbl(l_index2).so_basis := 2;
      l_bom_component_tbl(l_index2).optional := 2;
      l_bom_component_tbl(l_index2).mutually_exclusive := 2;
      l_bom_component_tbl(l_index2).shipping_allowed := null;
      l_bom_component_tbl(l_index2).required_to_ship := 2;
      l_bom_component_tbl(l_index2).required_for_revenue := 2;
      l_bom_component_tbl(l_index2).include_on_ship_docs := 2;
      l_index2 := l_index2 + 1;
    else
      o_error_code := 1;
    end if;
    exit when l_index1 = i_component_table.LAST;
    l_index1 := i_component_table.NEXT(l_index1);
  end loop;

  -- Construct header
    l_bom_header_rec.organization_code := i_organization_code;
    l_bom_header_rec.assembly_item_name := l_assembly_item_name;
    l_bom_header_rec.alternate_bom_code := null;
    l_bom_header_rec.transaction_type := 'SYNC';
    l_bom_header_rec.assembly_type := 1;

    -- Bug# 3844669: Initializes BOM Message List and associated variables.
    Error_Handler.Initialize;

  -- Call the BOM API
  BOM_BO_PUB.Process_Bom(
	p_bom_header_rec	=> l_bom_header_rec,
	p_bom_component_tbl	=> l_bom_component_tbl,
	x_bom_header_rec	=> o_bom_header_rec,
	x_bom_revision_tbl	=> o_bom_revision_tbl,
	x_bom_component_tbl	=> o_bom_component_tbl,
	x_bom_ref_designator_tbl	=> o_bom_ref_designator_tbl,
	x_bom_sub_component_tbl	=> o_bom_sub_component_tbl,
	x_return_status		=> o_return_status,
	x_msg_count		=> o_msg_count);

  if o_return_status = 'S' then
   commit;
  else
   rollback;
   o_error_code := 2;
  end if;
EXCEPTION
  WHEN NO_DATA_FOUND THEN   /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
    o_error_code := 2;
END copy_to_bom;


PROCEDURE adjust_resources(i_wip_entity_id	IN	NUMBER) IS

  CURSOR all_operations IS
    select operation_seq_num
    from wip_operations
    where wip_entity_id = i_wip_entity_id;

  l_wo_start_date	DATE;
  l_wo_completion_date	DATE;
  l_op_seq_num		NUMBER;
  l_op_start_date	DATE;
  l_op_completion_date	DATE;

BEGIN
  -- Update Operations
  OPEN all_operations;
  LOOP
    -- Next Operation
    FETCH all_operations INTO l_op_seq_num;
    EXIT WHEN all_operations%NOTFOUND;
    -- Check Resources
    BEGIN
      -- Get the New Date Range
      select min(start_date), max(completion_date)
      into l_op_start_date, l_op_completion_date
      from wip_operation_resources
      where wip_entity_id = i_wip_entity_id
        and operation_seq_num = l_op_seq_num;
      -- Update the Operation

      if (l_op_start_date is not null) and (l_op_completion_date is not null) then  -- Fix for operations with no resources
      update wip_operations set
	first_unit_start_date		= l_op_start_date,
	first_unit_completion_date 	= l_op_completion_date,
	last_unit_start_date		= l_op_start_date,
	last_unit_completion_date 	= l_op_completion_date
      where wip_entity_id = i_wip_entity_id
        and operation_seq_num = l_op_seq_num;
       end if;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN  /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
        NULL;
    END;
  END LOOP;
  CLOSE all_operations;
  -- Update Work Order
  BEGIN
    select min(first_unit_start_date), max(last_unit_completion_date)
    into l_wo_start_date, l_wo_completion_date
    from wip_operations
    where wip_entity_id = i_wip_entity_id;

    if (l_wo_start_date is not null and l_wo_completion_date is not null) then
    update wip_discrete_jobs set
	scheduled_start_date		= l_wo_start_date,
	scheduled_completion_date	= l_wo_completion_date
    where wip_entity_id = i_wip_entity_id;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN          /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
      NULL;
  END;
END adjust_resources;


PROCEDURE adjust_operations(
		i_wip_entity_id		IN	NUMBER,
		i_operation_table	IN	t_optime_table) IS

  CURSOR all_operations IS
    select operation_seq_num
    from wip_operations
    where wip_entity_id = i_wip_entity_id;

  l_index	NUMBER;

  l_wo_start_date	DATE;
  l_wo_completion_date	DATE;
  l_op_seq_num		NUMBER;

  l_op	number;
  l_shift number;
BEGIN
/*
 | insert into lmtmp (wip_entity_id, op_count)values(
 |   i_wip_entity_id, 0);--i_operation_table.count);
 | l_index := i_operation_table.first;
 | loop
 |     insert into lmtmp(wip_entity_id, op_count)values(
 |       -1, l_index);
 |     l_op := i_operation_table(l_index).operation_seq_num;
 |     l_shift := i_operation_table(l_index).time_shift;
 |     insert into lmtmp (wip_entity_id, op_count)values(
 |        l_op, l_shift);
 |   exit when l_index = i_operation_table.last;
 |   l_index := i_operation_table.next(l_index);
 | end loop;
 |     commit;
*/
  -- Work Order
  BEGIN
    select min(first_unit_start_date), max(last_unit_completion_date)
    into l_wo_start_date, l_wo_completion_date
    from wip_operations
    where wip_entity_id = i_wip_entity_id;

    update wip_discrete_jobs set
	scheduled_start_date		= l_wo_start_date,
	scheduled_completion_date	= l_wo_completion_date
    where wip_entity_id = i_wip_entity_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN            /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
      NULL;
  END;
  -- Resources
  if i_operation_table is null or
     i_operation_table.count <= 0 then
    return;
  end if;
  l_index := i_operation_table.FIRST;
  LOOP
      update wip_operation_resources set
	start_date = start_date, -- + i_operation_table(l_index).time_shift,
	completion_date = completion_date   --+ i_operation_table(l_index).time_shift
      where wip_entity_id = i_wip_entity_id
	and operation_seq_num = i_operation_table(l_index).operation_seq_num;
    EXIT WHEN l_index = i_operation_table.LAST;
    l_index := i_operation_table.NEXT(l_index);
  END LOOP;
--*/ null;
END adjust_operations;


PROCEDURE adjust_workorder(
		i_wip_entity_id		IN	NUMBER,
		i_shift			IN	NUMBER) IS
BEGIN
  -- Operations
  update wip_operations set
    first_unit_start_date 	= first_unit_start_date,
    first_unit_completion_date	= first_unit_completion_date,
    last_unit_start_date 	= last_unit_start_date,
    last_unit_completion_date	= last_unit_completion_date
  where wip_entity_id = i_wip_entity_id;
  -- Resources
  update wip_operation_resources set
    start_date 		= start_date,
    completion_date	= completion_date
  where wip_entity_id = i_wip_entity_id;
END adjust_workorder;


FUNCTION dependency_violated( i_wip_entity_id		IN	NUMBER)
	RETURN BOOLEAN IS

  CURSOR all_dependencies IS
    select prior_operation, next_operation
    from wip_operation_networks
    where wip_entity_id = i_wip_entity_id;

  l_from_op	number;
  l_to_op	number;

  l_start_date_from	date;
  l_end_date_from	date;
  l_start_date_to	date;
  l_end_date_to		date;
BEGIN
  OPEN all_dependencies;
  LOOP
    FETCH all_dependencies INTO l_from_op, l_to_op;
    EXIT WHEN all_dependencies%NOTFOUND;
    select first_unit_start_date, last_unit_completion_date
    into l_start_date_from, l_end_date_from
    from wip_operations
    where wip_entity_id = i_wip_entity_id
      and operation_seq_num = l_from_op;
    select first_unit_start_date, last_unit_completion_date
    into l_start_date_to, l_end_date_to
    from wip_operations
    where wip_entity_id = i_wip_entity_id
      and operation_seq_num = l_to_op;
    if l_start_date_to < l_end_date_from then
      CLOSE all_dependencies;
      RETURN TRUE;
    end if;
  END LOOP;
  CLOSE all_dependencies;
  RETURN FALSE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN      /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
    RETURN FALSE;
END dependency_violated;


/*Earlier, this function used to check whether there were multiple
 *released work orders for the same maintenance object and asset
 *activity. Now that restriction has been relaxed and multiple such
 *released work orders are going to be allowed. Hence this function
 *always returns 0 for success.

 *This procedure is being still allowed
 *to exist as we could add other checks later on.
 */
FUNCTION check_released_onhold_allowed(
             p_rebuild_flag    in varchar2,
             p_org_id          in number,
             p_item_id         in number,
             p_serial_number   in varchar2,
             p_activity_id     in number) RETURN NUMBER IS
  x_count number := null;
BEGIN

  return 0;

END check_released_onhold_allowed;




/****************************************
 *	Get Responsibility Id		*
 ****************************************/
function menu_has_function
(
   p_menu_id IN NUMBER
  ,p_function_id IN NUMBER
) RETURN NUMBER
IS

CURSOR COUNT_FUNC IS
 select count(*) as func_count
 from
  ( select level as entry_level, function_id
    from fnd_menu_entries me
    start with menu_id = p_menu_id
    connect by prior sub_menu_id = menu_id
  ) e
 where e.function_id = p_function_id;

l_count NUMBER;
BEGIN

  open COUNT_FUNC;
  fetch COUNT_FUNC into l_count;
  if( COUNT_FUNC%NOTFOUND) then
    l_count := 0;
  end if;

  return l_count;
END;

procedure get_resp_for_func
(
   p_function_id IN NUMBER
  ,p_user_id     IN NUMBER
  ,p_resp_app_id IN NUMBER
  ,x_resp_id     OUT NOCOPY NUMBER
  ,x_out         OUT NOCOPY VARCHAR2
) IS

l_resp_key VARCHAR2(300);
l_resp_id  NUMBER;
l_resp_app_id NUMBER;
l_menu_id NUMBER;
l_org_id VARCHAR2(240);

-- added Resposibility-User active date check (furg active date check) as per bug 3464424 fix */
CURSOR C_RESPS  IS
  select fr.responsibility_key, fr.responsibility_id, fr.application_id,
fr.menu_id
  from fnd_user fu, fnd_responsibility fr, fnd_user_resp_groups furg
  where fu.user_id = p_user_id
    and furg.user_id = fu.user_id
    and fr.responsibility_id = furg.responsibility_id
    and fr.application_id = furg.responsibility_application_id
    and nvl(fr.start_date, sysdate) <= sysdate
    and nvl(fr.end_date, sysdate) >= sysdate
    and nvl(furg.start_date, sysdate) <= sysdate
    and nvl(furg.end_date, sysdate) >= sysdate
    and nvl(p_resp_app_id, fr.application_id) = fr.application_id
    and eam_workorder_util_pkg.menu_has_function(fr.menu_id, p_function_id) > 0
    and NVL(l_org_id,  fnd_profile.value_specific('ORG_ID', NULL,
        fr.responsibility_id, furg.responsibility_application_id)) =
        fnd_profile.value_specific('ORG_ID', NULL,
        fr.responsibility_id, furg.responsibility_application_id)
    and ROWNUM=1;

BEGIN
  fnd_profile.get('ORG_ID', l_org_id);
  open C_RESPS ;
  fetch C_RESPS into l_resp_key, l_resp_id, l_resp_app_id, l_menu_id;
  if( C_RESPS%NOTFOUND ) then
     l_resp_id:=-1;
  end if;
  x_out := l_resp_key;
  x_resp_id := l_resp_id;
END;

--Procedure will return responsibility id with valid organization access
procedure get_resp
(
   p_function_id IN NUMBER
  ,p_user_id     IN NUMBER
  ,p_resp_app_id IN NUMBER
  ,x_resp_id     OUT NOCOPY NUMBER
  ,x_out         OUT NOCOPY VARCHAR2
) IS

l_resp_key VARCHAR2(300);
l_resp_id  NUMBER;
l_resp_app_id NUMBER;
l_menu_id NUMBER;
l_organization_id NUMBER;

CURSOR C_RESPS  IS
  select fr.responsibility_key, fr.responsibility_id, fr.application_id,
fr.menu_id
  from fnd_user fu, fnd_responsibility fr, fnd_user_resp_groups furg, org_access_view oav
  where fu.user_id = p_user_id
    and furg.user_id = fu.user_id
    and fr.responsibility_id = furg.responsibility_id
    and fr.application_id = furg.responsibility_application_id
    and nvl(fr.start_date, sysdate) <= sysdate
    and nvl(fr.end_date, sysdate) >= sysdate
    and nvl(furg.start_date, sysdate) <= sysdate
    and nvl(furg.end_date, sysdate) >= sysdate
    and nvl(p_resp_app_id, fr.application_id) = fr.application_id
    and eam_workorder_util_pkg.menu_has_function(fr.menu_id, p_function_id) > 0
    and oav.responsibility_id=fr.responsibility_id
    and oav.organization_id=l_organization_id
    and oav.resp_application_id=426
    and ROWNUM=1;

BEGIN
  fnd_profile.get('MFG_ORGANIZATION_ID', l_organization_id);
  open C_RESPS ;
  fetch C_RESPS into l_resp_key, l_resp_id, l_resp_app_id, l_menu_id;
  if( C_RESPS%NOTFOUND ) then
    FND_MESSAGE.SET_NAME('EAM', 'EAM_ORG_ACCESS_VIOLATION');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  x_out := l_resp_key;
  x_resp_id := l_resp_id;
END;

function get_ip_resp_id
(
   p_user_id IN NUMBER
) RETURN NUMBER IS

l_ip_function_id NUMBER;
l_ret NUMBER;
l_out VARCHAR2(300);
l_resp_id NUMBER;
l_ip_app_id NUMBER;
l_function_name fnd_form_functions.function_name%TYPE := 'POR_SSP_HOME';

BEGIN

  BEGIN
    select function_id
    into l_ip_function_id
    from fnd_form_functions
    where function_name = l_function_name;   -- Fix for Bug 3756518

    -- IP use 178 (ICX) as app id
    l_ip_app_id := 178;

    get_resp_for_func(l_ip_function_id, p_user_id, null, l_resp_id,
l_out);

    l_ret := l_resp_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_ret := -2;
  END;

  return l_ret;
END;

--Function to return Responsibility Id for Maint. Super User.
--This returns -1 if resp. is not assigned to current user
FUNCTION Get_Eam_Resp_Id
RETURN NUMBER
IS
     l_eam_function_id       NUMBER;
     l_function_name   fnd_form_functions.function_name%TYPE := 'EAM_APPL_MENU_HOME';
     l_resp_id                          NUMBER;
     l_eam_app_id                 NUMBER;
     l_resp_key                       VARCHAR2(300);
BEGIN

		BEGIN
			    select function_id
			    into l_eam_function_id
			    from fnd_form_functions
			    where function_name = l_function_name;
	         EXCEPTION
		 WHEN NO_DATA_FOUND THEN
					fnd_message.set_name('EAM','EAM_RESP_NOT_AVAILABLE');  --show message that resp. is not available
					APP_EXCEPTION.RAISE_EXCEPTION;
		END;

			    -- EAM uses 426 as application id
			    l_eam_app_id := 426;

			    get_resp_for_func(l_eam_function_id,FND_GLOBAL.user_id, null, l_resp_id, l_resp_key);

			    IF(l_resp_id = -1) THEN
			              fnd_message.set_name('EAM','EAM_RESP_NOT_AVAILABLE');   --show message that resp. is not available
					APP_EXCEPTION.RAISE_EXCEPTION;
			    END IF;

RETURN  l_resp_id;

END Get_Eam_Resp_Id;


FUNCTION Resource_Schedulable(X_Hour_UOM_Code VARCHAR2,
			        X_Unit_Of_Measure VARCHAR2) RETURN NUMBER IS
  uom_class_code		VARCHAR2(10);
  hour_uom_class_code		VARCHAR2(10);
  conversion_exists		NUMBER;
  different_uom_class		EXCEPTION;
  uom_conversion_exists		EXCEPTION;
  no_uom_conversion		EXCEPTION;

BEGIN
  SELECT UOM_CLASS INTO hour_uom_class_code
    FROM MTL_UNITS_OF_MEASURE
   WHERE UOM_CODE = X_Hour_UOM_Code;

  SELECT UOM_CLASS INTO uom_class_code
    FROM MTL_UNITS_OF_MEASURE
   WHERE UOM_CODE = X_Unit_Of_Measure;

  IF hour_uom_class_code <> uom_class_code THEN
    RAISE different_uom_class;
  ELSE
    SELECT COUNT(*) INTO conversion_exists
      FROM MTL_UOM_CONVERSIONS muc1,
           MTL_UOM_CONVERSIONS muc2
     WHERE muc1.UOM_CLASS = uom_class_code
       AND muc1.UOM_CODE = X_Unit_Of_Measure
       AND muc1.inventory_item_id = 0
       AND nvl(muc1.disable_date, sysdate +1) > sysdate
       AND muc2.uom_code = X_Hour_Uom_Code
       AND muc2.inventory_item_id = 0
       AND muc2.uom_class = muc1.uom_class;
    IF conversion_exists > 0 THEN
      RAISE uom_conversion_exists;
    ELSE
      RAISE no_uom_conversion;
    END IF;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(0);
    WHEN different_uom_class THEN
      RETURN(0);
    WHEN no_uom_conversion THEN
      RETURN(0);
    WHEN uom_conversion_exists THEN
     RETURN(1);

END Resource_Schedulable;


PROCEDURE UNRELEASE(x_org_id        IN NUMBER,
                    x_wip_id        IN NUMBER,
                    x_rep_id        IN NUMBER,
                    x_line_id       IN NUMBER,
                    x_ent_type      IN NUMBER) IS

 ops_exist VARCHAR2(2);
 charges_exist VARCHAR2(2);
 po_req_exist VARCHAR2(20);
 quantity_left  NUMBER := 0;

 charges_exist_1 varchar2(2) := '0';
 charges_exist_2 varchar2(2) := '0';
 charges_exist_3 varchar2(2) := '0';



BEGIN

  /* Check for OSP */

  IF (WIP_OSP.PO_REQ_EXISTS( p_wip_entity_id	=> x_wip_id
		    	    ,p_rep_sched_id	=> x_rep_id
		    	    ,p_organization_id	=> x_org_id
		            ,p_entity_type 	=> x_ent_type	) = TRUE) THEN
	FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED_OPEN_PO');
	APP_EXCEPTION.RAISE_EXCEPTION;
        RETURN;
  END IF;

  /* End of OSP Check */

  /* Check for Direct Items */

  begin

 /* select ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0))) qty_left
  into quantity_left
  from wip_eam_direct_items_v
  where work_order_number = x_wip_id; */


  SELECT
    ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0))) qty_left into quantity_left
FROM
    (
    SELECT
        rql.wip_entity_id,
        rql.quantity quantity_ordered,
        to_number(null) quantity_received
    FROM po_requisition_lines_all rql,
        po_requisition_headers_all rqh,
        po_line_types plt
    WHERE rql.requisition_header_id = rqh.requisition_header_id
        AND rql.line_type_id = plt.line_type_id
        AND upper(rqh.authorization_status) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
        AND rql.line_location_id is NULL
        AND upper(nvl(rql.cancel_flag, 'N')) <> 'Y'
        AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
        AND rql.destination_type_code = 'SHOP FLOOR'
        AND rql.wip_entity_id is not null
    UNION
        (
        SELECT
            pd.wip_entity_id,
            sum(pd.quantity_ordered) quantity_ordered,
            sum(pd.quantity_delivered) quantity_received
        FROM po_line_types plt,
            (
            SELECT
                pd1.wip_entity_id,
                pd1.wip_operation_seq_num,
                pd1.destination_organization_id,
                pol.item_description,
                pol.unit_price,
                pol.quantity,
                pd1.quantity_delivered,
                pd1.quantity_ordered,
                pd1.quantity_cancelled,
                pol.po_line_id,
                pol.po_header_id,
                pd1.req_distribution_id,
                pd1.line_location_id,
                pol.line_type_id,
                pd1.destination_type_code,
                pol.cancel_flag,
                pol.item_id,
                pol.category_id ,
                pd1.po_release_id,
                pd1.amount_ordered,
                pd1.amount_delivered
            FROM po_lines_all pol,
                po_distributions_all pd1
            WHERE pol.po_line_id = pd1.po_line_id
            )
            pd
        WHERE pd.line_type_id = plt.line_type_id
            AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
            AND pd.destination_type_code = 'SHOP FLOOR'
            AND upper(nvl(pd.cancel_flag, 'N')) <> 'Y'
            AND pd.wip_entity_id is not null
        GROUP BY pd.wip_entity_id,
            pd.amount_ordered,
            pd.amount_delivered
        )
    )
	WHERE wip_entity_id = x_wip_id ;


-- bug fix 2675869: removed following group by clause for performance
--  group by work_order_number;

  if (quantity_left > 0) then
  FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED_OPEN_PO');
  APP_EXCEPTION.RAISE_EXCEPTION;
 /* Bug#3022963: The 'RETURN' was placed outside the quantity_left check causing
     the procedure to return without making other checks */
  RETURN;
  END IF;
  exception
    WHEN NO_DATA_FOUND then      -- Here the exception will not raise, hence commenting. fix for the bug 2551622
    null;

  end;

 /* End of Check for Direct Items */

 /* Check for Material and Resource Transactions */

   begin

-- bug fix 2675869: removed 'distinct' from following query and added additonal ROWNUM<=1
   SELECT '1'
        into  charges_exist_1
        FROM    WIP_DISCRETE_JOBS DJ, WIP_PERIOD_BALANCES WPB
        WHERE   DJ.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                AND DJ.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                AND DJ.WIP_ENTITY_ID = x_wip_id
                AND DJ.ORGANIZATION_ID = x_org_id
                AND (DJ.QUANTITY_COMPLETED <> 0
                        OR DJ.QUANTITY_SCRAPPED <> 0
                        OR WPB.TL_RESOURCE_IN <> 0
                        OR WPB.TL_OVERHEAD_IN <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.PL_MATERIAL_IN <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_IN <> 0
                        OR WPB.PL_RESOURCE_IN <> 0
                        OR WPB.PL_OVERHEAD_IN <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.TL_MATERIAL_OUT <> 0
                        OR WPB.TL_RESOURCE_OUT <> 0
                        OR WPB.TL_OVERHEAD_OUT <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                        OR WPB.PL_MATERIAL_OUT <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_OUT <> 0
                        OR WPB.PL_RESOURCE_OUT <> 0
                        OR WPB.PL_OVERHEAD_OUT <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0)
                AND ROWNUM <= 1;

   if charges_exist_1 = '1' then
      FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
      APP_EXCEPTION.RAISE_EXCEPTION;
      /* Bug#3022963: The 'RETURN' was placed outside the quantity_left check causing
         the procedure to return without making other checks */
     RETURN;
   end if;
   exception
   WHEN NO_DATA_FOUND then    /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
   null;
   end;

   begin

   SELECT '1'
     into  charges_exist_2
     FROM  DUAL                                           /*fix for 2414244 */
    WHERE  EXISTS (SELECT '1'
                         FROM WIP_REQUIREMENT_OPERATIONS
                        WHERE ORGANIZATION_ID = x_org_id
                         AND WIP_ENTITY_ID = x_wip_id
                          AND QUANTITY_ISSUED <> 0)
        OR EXISTS (SELECT '1'
                         FROM WIP_MOVE_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id)
        OR EXISTS (SELECT '1'
                         FROM WIP_COST_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id);

   if charges_exist_2 = '1' then
      FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
      APP_EXCEPTION.RAISE_EXCEPTION;
      /* Bug#3022963: The 'RETURN' was placed outside the quantity_left check causing
     the procedure to return without making other checks */
      RETURN;
   end if;
   exception
   WHEN NO_DATA_FOUND then      /* fix for the perf bug #2551622 */
   null;
   end;


   BEGIN
	-- Fix for Bug 3890165

	SELECT '1'
	INTO charges_exist_3
	FROM dual
	WHERE EXISTS (SELECT '1'
		      FROM mtl_material_transactions_temp
	              WHERE organization_id = x_org_id
	              AND transaction_source_type_id = 5
	              AND transaction_source_id = x_wip_id);
      if charges_exist_3 = '1' then
         FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
         APP_EXCEPTION.RAISE_EXCEPTION;
	  /* Bug#3022963: The 'RETURN' was placed outside the quantity_left check causing
         the procedure to return without making other checks */
	 RETURN;
      end if;
   EXCEPTION
    WHEN NO_DATA_FOUND then     /* fix for the perf bug #2551622 */
      begin
                   SELECT DISTINCT '1'
                    into charges_exist_3
                    FROM dual
                  where EXISTS (SELECT '1'
                         FROM WIP_OPERATION_RESOURCES
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id
                          AND APPLIED_RESOURCE_UNITS <> 0);

      if charges_exist_3 = '1' then
         FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
         APP_EXCEPTION.RAISE_EXCEPTION;
	  /* Bug#3022963: The 'RETURN' was placed outside the quantity_left check causing
         the procedure to return without making other checks */
	 RETURN;
      end if;
      exception
	   WHEN NO_DATA_FOUND then     /* fix for the perf bug #2551622 */
	      null;
      end;
     END;

    /* Bug#3022963: All 3 checks should be negative for the wok order to be
       put from released to unreleased */
    IF (charges_exist_1 = '0' and charges_exist_2 = '0' and charges_exist_3 = '0') THEN

      UPDATE WIP_OPERATIONS
         SET QUANTITY_WAITING_TO_MOVE = 0,
             QUANTITY_SCRAPPED = 0,
             QUANTITY_REJECTED = 0,
             QUANTITY_IN_QUEUE = 0,
             QUANTITY_RUNNING = 0,
             QUANTITY_COMPLETED = 0
       WHERE WIP_ENTITY_ID = x_wip_id
         AND ORGANIZATION_ID = x_org_id;
    ELSE
      FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;

   /* End of Check for Material and Resource Transactions */

  DELETE FROM wip_period_balances
  WHERE wip_entity_id = x_wip_id
  AND NVL(repetitive_schedule_id, -1) =
      NVL(x_rep_id, -1)
  AND organization_id = x_org_id;

  -- Undo changes to WRO as a result of Overcompletion
   wip_overcompletion.undo_overcompletion
	( p_org_id 		=> x_org_id,
	  p_wip_entity_id 	=> x_wip_id,
	  p_rep_id 		=> x_rep_id);

END UNRELEASE;



   procedure create_default_operation
  (  p_organization_id             IN    NUMBER
    ,p_wip_entity_id               IN    NUMBER
  ) IS

  l_wip_entity_id            NUMBER;
  l_organization_id          NUMBER;

 BEGIN

   l_organization_id := p_organization_id;
   l_wip_entity_id   := p_wip_entity_id;

   WIP_EAM_UTILS.create_default_operation(p_organization_id => l_organization_id
                                        , p_wip_entity_id   => l_wip_entity_id);


  END create_default_operation;  -- dml

/* bug no 3349197 */

PROCEDURE CK_MATERIAL_ALLOC_ON_HOLD(x_org_id        IN NUMBER,
                    x_wip_id        IN NUMBER,
                    x_rep_id        IN NUMBER,
                    x_line_id       IN NUMBER,
                    x_ent_type      IN NUMBER,
		    x_return_status OUT NOCOPY   VARCHAR2) IS

 ops_exist VARCHAR2(2) := '0';
 charges_exist VARCHAR2(2) := '0';
 po_req_exist VARCHAR2(20);
 quantity_left  NUMBER := 0;

 charges_exist_1 varchar2(2) := '0';
 charges_exist_2 varchar2(2) := '0';
 charges_exist_3 varchar2(2) := '0';

BEGIN

  /* Check for OSP */

  IF (WIP_OSP.PO_REQ_EXISTS( p_wip_entity_id	=> x_wip_id
		    	    ,p_rep_sched_id	=> x_rep_id
		    	    ,p_organization_id	=> x_org_id
		            ,p_entity_type 	=> x_ent_type	) = TRUE) THEN
    ops_exist := '1';
  END IF;

  /* End of OSP Check */

  /* Check for Direct Items */

  begin
/*  select ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0))) qty_left
  into quantity_left
  from wip_eam_direct_items_v
  where work_order_number = x_wip_id;
  */

  SELECT
    ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0))) qty_left into quantity_left
FROM
    (
    SELECT
        rql.wip_entity_id,
        rql.quantity quantity_ordered,
        to_number(null) quantity_received
    FROM po_requisition_lines_all rql,
        po_requisition_headers_all rqh,
        po_line_types plt
    WHERE rql.requisition_header_id = rqh.requisition_header_id
        AND rql.line_type_id = plt.line_type_id
        AND upper(rqh.authorization_status) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
        AND rql.line_location_id is NULL
        AND upper(nvl(rql.cancel_flag, 'N')) <> 'Y'
        AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
        AND rql.destination_type_code = 'SHOP FLOOR'
        AND rql.wip_entity_id is not null
    UNION
        (
        SELECT
            pd.wip_entity_id,
            sum(pd.quantity_ordered) quantity_ordered,
            sum(pd.quantity_delivered) quantity_received
        FROM po_line_types plt,
            (
            SELECT
                pd1.wip_entity_id,
                pd1.wip_operation_seq_num,
                pd1.destination_organization_id,
                pol.item_description,
                pol.unit_price,
                pol.quantity,
                pd1.quantity_delivered,
                pd1.quantity_ordered,
                pd1.quantity_cancelled,
                pol.po_line_id,
                pol.po_header_id,
                pd1.req_distribution_id,
                pd1.line_location_id,
                pol.line_type_id,
                pd1.destination_type_code,
                pol.cancel_flag,
                pol.item_id,
                pol.category_id ,
                pd1.po_release_id,
                pd1.amount_ordered,
                pd1.amount_delivered
            FROM po_lines_all pol,
                po_distributions_all pd1
            WHERE pol.po_line_id = pd1.po_line_id
            )
            pd
        WHERE pd.line_type_id = plt.line_type_id
            AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
            AND pd.destination_type_code = 'SHOP FLOOR'
            AND upper(nvl(pd.cancel_flag, 'N')) <> 'Y'
            AND pd.wip_entity_id is not null
        GROUP BY pd.wip_entity_id,
            pd.amount_ordered,
            pd.amount_delivered
        )
    )
  WHERE wip_entity_id = x_wip_id;


  -- bug fix 2675869: removed following group by clause for performance
  --  group by work_order_number;

  if (quantity_left > 0) then
    charges_exist := '1';
  END IF;
  exception
    WHEN NO_DATA_FOUND then      -- Here the exception will not raise, hence commenting. fix for the bug 2551622
    null;
  end;
 /* End of Check for Direct Items */

 /* Check for Material and Resource Transactions */

   begin
   -- bug fix 2675869: removed 'distinct' from following query and added additonal ROWNUM<=1
   SELECT '1'
        into  charges_exist_1
        FROM    WIP_DISCRETE_JOBS DJ, WIP_PERIOD_BALANCES WPB
        WHERE   DJ.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                AND DJ.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                AND DJ.WIP_ENTITY_ID = x_wip_id
                AND DJ.ORGANIZATION_ID = x_org_id
                AND (DJ.QUANTITY_COMPLETED <> 0
                        OR DJ.QUANTITY_SCRAPPED <> 0
                        OR WPB.TL_RESOURCE_IN <> 0
                        OR WPB.TL_OVERHEAD_IN <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.PL_MATERIAL_IN <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_IN <> 0
                        OR WPB.PL_RESOURCE_IN <> 0
                        OR WPB.PL_OVERHEAD_IN <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.TL_MATERIAL_OUT <> 0
                        OR WPB.TL_RESOURCE_OUT <> 0
                        OR WPB.TL_OVERHEAD_OUT <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                        OR WPB.PL_MATERIAL_OUT <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_OUT <> 0
                        OR WPB.PL_RESOURCE_OUT <> 0
                        OR WPB.PL_OVERHEAD_OUT <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0)
                AND ROWNUM <= 1;
   exception
   WHEN NO_DATA_FOUND then    /* Here the exception is changed from OTHERS to NO_DATA_FOUND for the bug 2551622 */
   null;
   end;

   begin
   SELECT '1'
     into  charges_exist_2
     FROM  DUAL                                           /*fix for 2414244 */
    WHERE  EXISTS (SELECT '1'
                         FROM WIP_REQUIREMENT_OPERATIONS
                        WHERE ORGANIZATION_ID = x_org_id
                         AND WIP_ENTITY_ID = x_wip_id
                          AND QUANTITY_ISSUED <> 0)
        OR EXISTS (SELECT '1'
                         FROM WIP_MOVE_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id)
        OR EXISTS (SELECT '1'
                         FROM WIP_COST_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id);
   exception
   WHEN NO_DATA_FOUND then      /* fix for the perf bug #2551622 */
   null;
   end;

 begin
   SELECT DISTINCT '1'
    into charges_exist_3
                         FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                        WHERE ORGANIZATION_ID = x_org_id
			  AND TRANSACTION_SOURCE_TYPE_ID = 5
                          AND TRANSACTION_SOURCE_ID = x_wip_id;
   exception
   WHEN NO_DATA_FOUND then     /* fix for the perf bug #2551622 */
	begin
		   SELECT DISTINCT '1'
		    into charges_exist_3
    	            FROM dual
		  where EXISTS (SELECT '1'
                         FROM WIP_OPERATION_RESOURCES
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id
                          AND APPLIED_RESOURCE_UNITS <> 0);

	exception WHEN NO_DATA_FOUND then
	   null;
	end;
   end;

    IF (charges_exist_1 = '0' and charges_exist_2 = '0' and charges_exist_3 = '0' and ops_exist ='0' and charges_exist ='0') THEN
 	x_return_status := 'S';
    else
	x_return_status := 'F';
    END IF;

END CK_MATERIAL_ALLOC_ON_HOLD;

--Fix for 3360801.Added the following procedure to show the messages from the api
        /********************************************************************
        * Procedure     : show_mesg
        * Purpose       : Procedure will concatenate all the messages
	                  from the workorder api and return 1 string
        *********************************************************************/
	PROCEDURE show_mesg IS
		 l_msg_count NUMBER;
		 mesg varchar2(2000);
		  i NUMBER;
		  msg_index number;
		 temp varchar2(2000);
	BEGIN
	   mesg := '';

	   l_msg_count := fnd_msg_pub.count_msg;
	IF(l_msg_count>0) THEN

	 msg_index := l_msg_count;

	 for i in 1..l_msg_count loop
		 fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => temp,
                    p_msg_index_out => msg_index);
		msg_index := msg_index-1;
		mesg := mesg || '    ' ||  to_char(i) || ' . '||temp ;
	end loop;
		fnd_message.set_name('EAM','EAM_WO_API_MESG');

		fnd_message.set_token(token => 'MESG',
			  	  value =>mesg,
			  	  translate =>FALSE);
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

     END show_mesg;


  --Fix for 3360801.the following procedure will return a directory to get the log directory path
        PROCEDURE log_path(
	    x_output_dir   OUT NOCOPY VARCHAR2
	  )
	IS
		        l_full_path     VARCHAR2(512);
			l_new_full_path         VARCHAR2(512);
			l_file_dir      VARCHAR2(512);

			fileHandler     UTL_FILE.FILE_TYPE;
			fileName        VARCHAR2(50);

			l_flag          NUMBER;
			l_index		NUMBER;
	BEGIN
	           fileName:='test.log';--this is only a dummy filename to check if directory is valid or not

        	   /* get output directory path from database */
			SELECT value
			INTO   l_full_path
			FROM   v$parameter
			WHERE  name = 'utl_file_dir';

			l_flag := 0;
			--l_full_path contains a list of comma-separated directories
			WHILE(TRUE)
			LOOP
					    --get the first dir in the list. Removed select statement for bug# 3805306
					    l_index := instr(l_full_path,',')-1;
					    IF l_index = -1 THEN
						l_index := length(l_full_path);
  					    END IF;
					    l_file_dir := trim( substr( l_full_path, 1, l_index ) );

					    -- check if the dir is valid
					    BEGIN
						    fileHandler := UTL_FILE.FOPEN(l_file_dir , filename, 'w');
						    l_flag := 1;
					    EXCEPTION
						    WHEN utl_file.invalid_path THEN
							l_flag := 0;
						    WHEN utl_file.invalid_operation THEN
							l_flag := 0;
					    END;

					    IF l_flag = 1 THEN --got a valid directory
						utl_file.fclose(fileHandler);
						EXIT;
					    END IF;

					    --earlier found dir was not a valid dir,
					    --so remove that from the list, and get the new list
					    l_new_full_path := trim(substr(l_full_path, instr(l_full_path, ',')+1, length(l_full_path)));

					    --if the new list has not changed, there are no more valid dirs left
					    IF l_full_path = l_new_full_path THEN
						    l_flag:=0;
						    EXIT;
					    END IF;
					     l_full_path := l_new_full_path;
			 END LOOP;

			 IF(l_flag=1) THEN --found a valid directory
			     x_output_dir := l_file_dir;
			  ELSE
			      x_output_dir:= null;

			  END IF;
         EXCEPTION
              WHEN OTHERS THEN
                  x_output_dir := null;

	END log_path;

-- Fix for Bug 3489907 Start

PROCEDURE Check_open_txns(p_org_id        IN NUMBER,
                         p_wip_id        IN NUMBER,
                         p_ent_type      IN NUMBER,
			 p_return_status OUT NOCOPY NUMBER,
			 p_return_string OUT NOCOPY VARCHAR2 /* Added for bug#5335940 */) IS
 quantity_left  NUMBER := 0;
 charges_exist_2 varchar2(2) := '0';
 charges_exist_3 varchar2(2) := '0';
 charges_exist_4 varchar2(2) := '0';
BEGIN
p_return_status := 0; /* Added for bug#5253575 */
  /* Check for Direct Items and OSP*/


  BEGIN

/*
    SELECT ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0)))
         qty_left
    INTO quantity_left
    FROM   wip_eam_direct_items_v
    WHERE  work_order_number = p_wip_id
    AND    rownum <=1;

 */

    SELECT
    ((nvl(SUM(quantity_ordered),0)) - (nvl(SUM(quantity_received),0))) qty_left  INTO quantity_left
FROM
    (
    SELECT
        rql.wip_entity_id,
        rql.quantity quantity_ordered,
        to_number(null) quantity_received
    FROM po_requisition_lines_all rql,
        po_requisition_headers_all rqh,
        po_line_types plt
    WHERE rql.requisition_header_id = rqh.requisition_header_id
        AND rql.line_type_id = plt.line_type_id
        AND upper(rqh.authorization_status) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
        AND rql.line_location_id is NULL
        AND upper(nvl(rql.cancel_flag, 'N')) <> 'Y'
        AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
        AND rql.destination_type_code = 'SHOP FLOOR'
        AND rql.wip_entity_id is not null
    UNION
        (
        SELECT
            pd.wip_entity_id,
            sum(pd.quantity_ordered) quantity_ordered,
            sum(pd.quantity_delivered) quantity_received
        FROM po_line_types plt,
            (
            SELECT
                pd1.wip_entity_id,
                pd1.wip_operation_seq_num,
                pd1.destination_organization_id,
                pol.item_description,
                pol.unit_price,
                pol.quantity,
                pd1.quantity_delivered,
                pd1.quantity_ordered,
                pd1.quantity_cancelled,
                pol.po_line_id,
                pol.po_header_id,
                pd1.req_distribution_id,
                pd1.line_location_id,
                pol.line_type_id,
                pd1.destination_type_code,
                pol.cancel_flag,
                pol.item_id,
                pol.category_id ,
                pd1.po_release_id,
                pd1.amount_ordered,
                pd1.amount_delivered
            FROM po_lines_all pol,
                po_distributions_all pd1
            WHERE pol.po_line_id = pd1.po_line_id
            )
            pd
        WHERE pd.line_type_id = plt.line_type_id
            AND upper(nvl(plt.outside_operation_flag, 'N')) = 'N'
            AND pd.destination_type_code = 'SHOP FLOOR'
            AND upper(nvl(pd.cancel_flag, 'N')) <> 'Y'
            AND pd.wip_entity_id is not null
        GROUP BY pd.wip_entity_id,
            pd.amount_ordered,
            pd.amount_delivered
        )
    )
WHERE wip_entity_id = p_wip_id
    AND rownum <=1;

    IF ( (quantity_left > 0) OR
         (WIP_OSP.PO_REQ_EXISTS( p_wip_entity_id  => p_wip_id
                 	    	,p_rep_sched_id	  => -1
  		    	        ,p_organization_id=> p_org_id
  		                ,p_entity_type 	  => p_ent_type)=TRUE)
       )THEN
       p_return_status:= 1;
       p_return_string := 'Direct Item/ OSP';
       RETURN;
     END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND then
    null;
  END;
 /* End Check for Direct Items and OSP*/

/*Start Check for Material Transactions */
  BEGIN

    SELECT DISTINCT '1'
    INTO charges_exist_2
    FROM MTL_MATERIAL_TRANSACTIONS_TEMP
    WHERE (ORGANIZATION_ID = p_org_id
	  AND TRANSACTION_SOURCE_TYPE_ID = 5
          AND TRANSACTION_SOURCE_ID = p_wip_id
	  AND rownum <=1)
OR EXISTS (SELECT '1'
 	                         FROM WIP_REQUIREMENT_OPERATIONS
 	                        WHERE ORGANIZATION_ID = p_org_id
 	                          AND WIP_ENTITY_ID = p_wip_id
 	                          AND QUANTITY_ISSUED <> 0);
	/*
	  IF charges_exist_2 = '1' then
	      p_return_status:= 2;
	      RETURN;
	  END IF;

	*/

  exception
   WHEN NO_DATA_FOUND then     /* fix for the perf bug #2551622 */
        BEGIN
                   SELECT DISTINCT '1'
                    into charges_exist_2
                    FROM dual
                  where EXISTS (SELECT '1'
                         FROM WIP_OPERATION_RESOURCES
                        WHERE ORGANIZATION_ID = p_org_id
                          AND WIP_ENTITY_ID = p_wip_id
                          AND APPLIED_RESOURCE_UNITS <> 0);

	 /* IF charges_exist_2 = '1' then
	      p_return_status:= 2;
	      RETURN;
	  END IF;
	*/
	  EXCEPTION
	    WHEN NO_DATA_FOUND then
		   null;
	  END;
  END;
/*End Check for Material Transactions */

/* Check for Move Transactions */
  BEGIN
    SELECT '1'
    INTO  charges_exist_3
    FROM  DUAL
    WHERE EXISTS (SELECT '1'
                  FROM WIP_REQUIREMENT_OPERATIONS
                  WHERE     ORGANIZATION_ID = p_org_id
                        AND WIP_ENTITY_ID = p_wip_id
                        AND QUANTITY_ISSUED <> 0)
        OR EXISTS(SELECT '1'
                  FROM WIP_MOVE_TXN_INTERFACE
                  WHERE     ORGANIZATION_ID = p_org_id
                        AND WIP_ENTITY_ID = p_wip_id)
        OR EXISTS(SELECT '1'
                  FROM WIP_COST_TXN_INTERFACE
                  WHERE     ORGANIZATION_ID = p_org_id
                        AND WIP_ENTITY_ID = p_wip_id);
  /* IF charges_exist_3 = '1' then
      p_return_status:= 3;
      RETURN;
   END IF;
   */
  EXCEPTION
    WHEN NO_DATA_FOUND then
    null;
  END;
/*End Check for Move Transactions */

 /* Code Added for bug#5335940 Start */
IF ( charges_exist_2 = '1' AND charges_exist_3 = '0' ) THEN
 	      p_return_status := 1;
 	      fnd_message.set_name('EAM','EAM_UPDATE_WO_TXN_OPEN');
 	      fnd_message.set_token(token => 'TXN', value => 'EAM_MATERIAL', translate => TRUE );
 	      p_return_string := fnd_message.get;
 	   ELSIF ( charges_exist_2 = '0' AND charges_exist_3 = '1' ) THEN
 	      p_return_status := 1;
	      fnd_message.set_name('EAM','EAM_UPDATE_WO_TXN_OPEN');
 	      fnd_message.set_token(token => 'TXN', value => 'EAM_RESOURCE', translate => TRUE );
 	      p_return_string := fnd_message.get;
 	   ElSIF ( charges_exist_2 = '1' AND charges_exist_3 = '1' ) THEN
 	      p_return_status := 1;
 	      fnd_message.set_name('EAM','EAM_UPDATE_WO_TXN_OPEN');
 	      fnd_message.set_token(token => 'TXN', value => 'EAM_MATERIAL_RESOURCE', translate => TRUE );
 	      p_return_string := fnd_message.get;
 	   ELSE
   p_return_status:=0;	   p_return_status:=0;
 	      p_return_string := null;
 	   END IF;
 	   /* Code Added for bug#5335940 Ends */

/*  p_return_status:=0; --commented for bug#5335940 */
END Check_open_txns;

PROCEDURE CANCEL(   p_org_id        IN NUMBER,
                    p_wip_id        IN NUMBER,
		    x_return_status  OUT NOCOPY NUMBER,
		    x_return_string  OUT NOCOPY VARCHAR2 /* Added for bug# 5335940 */) IS

 CURSOR disc_check_po_req_cur IS
    SELECT 'PO/REQ Linked'
      FROM PO_DISTRIBUTIONS_ALL PD,
           PO_LINE_LOCATIONS_ALL PLL
     WHERE pd.po_line_id IS NOT NULL
       AND pd.line_location_id IS NOT NULL
       AND PD.WIP_ENTITY_ID = p_wip_id
       AND PD.DESTINATION_ORGANIZATION_ID = p_org_id
       AND PLL.LINE_LOCATION_ID		  = PD.LINE_LOCATION_ID
       AND NOT(
               NVL(PLL.CANCEL_FLAG,'N')='Y'
	    OR NVL(PLL.CLOSED_CODE,'N')='FINALLY CLOSED'
	    OR NVL(PLL.CLOSED_CODE,'N')='CANCELLED'
	    OR NVL(PLL.CLOSED_CODE,'N')='CLOSED FOR INVOICE'
	    OR NVL(PLL.CLOSED_CODE,'N')='CLOSED FOR RECEIVING'
	    OR NVL(PLL.CLOSED_CODE,'N')='CLOSED'
	    OR NVL(PLL.CLOSED_CODE,'N')='REJECTED'
  	      )
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITION_LINES_ALL PRL
     WHERE PRL.WIP_ENTITY_ID = p_wip_id
       AND PRL.DESTINATION_ORGANIZATION_ID = p_org_id
       AND NOT(
	       NVL(PRL.CANCEL_FLAG,'N')='Y'
	    OR NVL(PRL.CLOSED_CODE,'N')='FINALLY CLOSED'
	    OR NVL(PRL.CLOSED_CODE,'N')='CANCELLED'
	    OR NVL(PRL.CLOSED_CODE,'N')='CLOSED FOR INVOICE'
	    OR NVL(PRL.CLOSED_CODE,'N')='CLOSED FOR RECEIVING'
	    OR NVL(PRL.CLOSED_CODE,'N')='CLOSED'
	    OR NVL(PRL.CLOSED_CODE,'N')='REJECTED'
  	      )
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITIONS_INTERFACE_ALL PRI
     WHERE PRI.WIP_ENTITY_ID = p_wip_id
       AND PRI.DESTINATION_ORGANIZATION_ID = p_org_id
       AND NVL(PRI.PROCESS_FLAG,'FUTURE') <> 'ERROR';

       po_req_exists    VARCHAR2(20);
	/* Added for bug#5335940 start */
	 l_return_string  VARCHAR2(2000);
	l_po_exists      VARCHAR2(2) := '0';
        l_txn_exists     VARCHAR2(2) := '0';
	/* Added for bug#5335940 end */
 BEGIN
	   OPEN disc_check_po_req_cur;
	   FETCH disc_check_po_req_cur INTO po_req_exists;
	   IF (disc_check_po_req_cur%FOUND) THEN
	    l_po_exists := '1';
 	            END IF;
 	            CLOSE disc_check_po_req_cur;
 	    /* Added for bug# 5335940 Start */
 	            Check_open_txns(p_org_id        => p_org_id,
 	                            p_wip_id        => p_wip_id,
 	                            p_ent_type      => 6,
 	                            p_return_status => x_return_status,
 	                            p_return_string => l_return_string
 	                           );
 	            IF x_return_status = 1 THEN
 	               l_txn_exists := '1';
 	            END IF;

 	            IF ( l_po_exists = '0' AND l_txn_exists = '1' ) THEN
                      x_return_status:=1;
 	                 x_return_string := l_return_string;
 	            ELSIF ( l_po_exists = '1' AND l_txn_exists = '0' ) THEN
 	                 x_return_status:=1;
 	                 fnd_message.set_name ('EAM','EAM_UPDATE_WO_CONFIRM_CANCEL');
 	                 x_return_string := fnd_message.get;
 	            ELSIF ( l_po_exists = '1' AND l_txn_exists = '1' ) THEN
 	                 fnd_message.set_name ('EAM','EAM_UPDATE_WO_CONFIRM_CANCEL');
 	                 x_return_string := fnd_message.get;
 	                 x_return_string := l_return_string || x_return_string;
	   ELSE
		     x_return_status:=0;
		      x_return_string := null;
	   END IF;
	   /* Added for bug#5335940 end */

  END CANCEL;

-- Fix for Bug 3489907 End

/* Function to get rebuild description in eam_work_orders_v*/

FUNCTION get_rebuild_description( p_rebuild_item_id NUMBER, p_organization_id NUMBER)
                             return VARCHAR2 IS
   l_description  MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE ;
   CURSOR get_description IS
      SELECT description
      FROM MTL_SYSTEM_ITEMS
      WHERE inventory_item_id = p_rebuild_item_id
      AND organization_id = p_organization_id ;
   BEGIN
    OPEN get_description ;
    FETCH get_description INTO l_description ;
    CLOSE get_description;
     return l_description;
 END get_rebuild_description;


/*
   Procedure to populate the x_workflow_table with approver's details
   for a particular workflow item key
   p_item_type = Workflow Item Type
   p_item_key  = Workflow Item key
   x_workflow_table = This table will be populated with approver's details like telephone, email etc.
*/

PROCEDURE get_workflow_details( p_item_type	 IN STRING,
				p_item_key	 IN STRING,
				x_workflow_table OUT NOCOPY t_workflow_table)
IS
	l_transaction_id		VARCHAR2(50);
	l_approvalProcessCompleteYNOut	VARCHAR2(1);
	l_approversOut			ame_util.approversTable2;


 	   -- Fetch telephone no from per_addresses
	   CURSOR per_addresses_csr( p_person_id NUMBER)IS
	   SELECT telephone_number_1
	     FROM per_addresses
	    WHERE person_id = p_person_id
	      AND sysdate BETWEEN date_from AND date_to
	      AND primary_flag = 'Y';

 	   -- Fetch telephone no from per_addresses with employee_id from fnd_user
	   CURSOR per_addresses_fnd_csr(p_user_id NUMBER) IS
	   SELECT telephone_number_1
	     FROM per_addresses
	    WHERE sysdate BETWEEN date_from AND date_to
	      AND primary_flag = 'Y'
	      AND person_id = (SELECT employee_id
			          FROM fnd_user
				 WHERE user_id  = p_user_id);

 	   -- Fetch email address per_all_people_f
	   CURSOR per_all_people_csr(p_person_id NUMBER) IS
	   SELECT email_address
	     FROM per_all_people_f
	    WHERE person_id = p_person_id
	      AND sysdate between effective_start_date AND effective_end_date;

 	   -- Fetch email address per_all_people_f
	   CURSOR per_all_people_fnd_csr(p_user_id NUMBER) IS
	   SELECT email_address
	     FROM per_all_people_f
	    WHERE sysdate between effective_start_date AND effective_end_date
  	      AND person_id = (SELECT employee_id
			          FROM fnd_user
				 WHERE user_id = p_user_id);

	   -- Fetch email address fnd_user
	   CURSOR fnd_user_csr(p_user_id VARCHAR2) IS
	   SELECT email_address
	     FROM fnd_user
	    WHERE user_id  = p_user_id;

	   l_transaction_type        VARCHAR2(250);

BEGIN

  BEGIN

	l_transaction_type := wf_engine.GetItemAttrtext( itemtype => p_item_type,
		    itemkey => p_item_key, aname => 'AME_TRANSACTION_TYPE');
  EXCEPTION
    WHEN OTHERS  THEN
	    l_transaction_type := 'oracle.apps.eam.workorder.release.approval';
  END;

   BEGIN
       l_transaction_id := wf_engine.GetItemAttrtext( itemtype => p_item_type,
		    itemkey => p_item_key, aname => 'AME_TRANSACTION_ID');
   EXCEPTION
      WHEN OTHERS  THEN
	    l_transaction_id := p_item_key;
	 END;
	Ame_api2.GetAllApprovers7(applicationIdIn => 426,
                                transactionTypeIn =>    l_transaction_type,
                                transactionIdIn =>     l_transaction_id,
                                approvalProcessCompleteYNOut =>    l_approvalProcessCompleteYNOut,
                                approversOut =>     l_approversOut);

   IF l_approversOut.count > 0 THEN
	   FOR i IN l_approversOut.FIRST..l_approversOut.LAST
	   LOOP
		x_workflow_table(i).seq_no := l_approversOut(i).approver_order_number;
		x_workflow_table(i).approver := l_approversOut(i).display_name;
		x_workflow_table(i).status := l_approversOut(i).approval_status;
		-- x_workflow_table(i).status_date:=

		IF (l_approversOut(i).orig_system = AME_UTIL.PERORIGSYSTEM) THEN
			OPEN  per_addresses_csr(l_approversOut(i).orig_system_id);
			FETCH per_addresses_csr INTO x_workflow_table(i).telephone;
			CLOSE per_addresses_csr;

			OPEN  per_all_people_csr(l_approversOut(i).orig_system_id);
			FETCH per_all_people_csr INTO  x_workflow_table(i).email;
			CLOSE per_all_people_csr;

		ELSIF (l_approversOut(i).orig_system = AME_UTIL.FNDUSERORIGSYSTEM) THEN
			OPEN  per_addresses_fnd_csr(l_approversOut(i).orig_system_id);
			FETCH per_addresses_fnd_csr INTO  x_workflow_table(i).telephone;
			CLOSE per_addresses_fnd_csr;

			OPEN  per_all_people_fnd_csr(l_approversOut(i).orig_system_id);
			FETCH per_all_people_fnd_csr INTO  x_workflow_table(i).email;
			IF per_all_people_fnd_csr%NOTFOUND THEN
				OPEN  fnd_user_csr(l_approversOut(i).orig_system_id);
				FETCH fnd_user_csr INTO  x_workflow_table(i).email;
				CLOSE fnd_user_csr;
			END IF;
			CLOSE per_all_people_fnd_csr;

		END IF;
	    END LOOP;
	END IF;

END get_workflow_details;

PROCEDURE callCostEstimatorSS(
							p_api_version		IN	NUMBER		:= 1.0,
							p_init_msg_list		IN	VARCHAR2		:= FND_API.G_FALSE,
							p_commit			IN	VARCHAR2		:= FND_API.G_FALSE,
							p_validation_level	IN	NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
							p_wip_entity_id		IN	NUMBER,
							p_organization_id	IN	NUMBER,
							x_return_status		OUT NOCOPY VARCHAR2,
							x_msg_count		OUT NOCOPY NUMBER,
							x_msg_data		OUT NOCOPY VARCHAR2
						) IS

l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                     NUMBER ;
l_msg_data                      VARCHAR2(2000) ;

BEGIN

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	UPDATE	WIP_DISCRETE_JOBS
	      SET	estimation_status = 2
	WHERE	wip_entity_id = p_wip_entity_id
	     AND	organization_id = p_organization_id;

	      CSTPECEP.Estimate_WorkOrder_GRP(	p_api_version		=>	p_api_version,
									p_init_msg_list		=>	p_init_msg_list,
									p_commit			=>	p_commit,
									p_validation_level	=>	p_validation_level,
									x_return_status		=>	l_return_status,
									x_msg_count		=>	l_msg_count,
									x_msg_data		=>	l_msg_data,
									p_organization_id	=>	p_organization_id,
									p_wip_entity_id		=>	p_wip_entity_id );


		x_return_status	 := l_return_status ;
		x_msg_count      :=  l_msg_count ;
		x_msg_data       :=  l_msg_data ;


END callCostEstimatorSS ;

PROCEDURE GET_REPLACED_REBUILDS(
		p_wip_entity_id   IN            NUMBER,
		p_organization_id IN            NUMBER,
		x_replaced_rebuild_tbl 		OUT NOCOPY REPLACE_REBUILD_TBL_TYPE,
		x_return_status			OUT NOCOPY VARCHAR2,
		x_error_message			OUT NOCOPY VARCHAR2
)IS
	l_maint_objid_tbl	     EAM_WORKORDER_UTIL_PKG.REPLACE_REBUILD_TBL_TYPE;
BEGIN
	 x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT wdj.maintenance_object_id
	  bulk collect into l_maint_objid_tbl
          FROM WIP_DISCRETE_JOBS wdj
         WHERE wdj.parent_wip_entity_id = p_wip_entity_id
           AND wdj.organization_id = p_organization_id
           AND wdj.manual_rebuild_flag = 'N'
           AND wdj.maintenance_object_type = 3;

EXCEPTION WHEN NO_DATA_FOUND THEN
		null;
		 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 WHEN OTHERS THEN

		x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		x_error_message := sqlerrm;
END GET_REPLACED_REBUILDS;

-- For Failure Ananlysis Project Tools > Menu option
FUNCTION get_msu_resp_id( p_user_id IN NUMBER)
RETURN NUMBER
IS
        l_function_name fnd_form_functions.function_name%TYPE := 'EAM_APPL_MENU_HOME';
        l_msu_function_id NUMBER;
        l_out VARCHAR2(300);
        l_resp_id NUMBER;

BEGIN

    SELECT function_id
    INTO l_msu_function_id
    FROM fnd_form_functions
    WHERE function_name = l_function_name;

    get_resp(l_msu_function_id, p_user_id, null, l_resp_id,l_out);
    RETURN l_resp_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN -2;
END get_msu_resp_id;


END EAM_WORKORDER_UTIL_PKG;


/
