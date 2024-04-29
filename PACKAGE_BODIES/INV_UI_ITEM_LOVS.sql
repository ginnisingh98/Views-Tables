--------------------------------------------------------
--  DDL for Package Body INV_UI_ITEM_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_ITEM_LOVS" AS
  /* $Header: INVITMLB.pls 120.24.12010000.8 2010/03/03 01:15:34 musinha ship $ */


g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;

  --      Name: GET_ITEM_LOV
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  AS% for item LOV's contanenated_segment
  --       p_where_clause    different LOV beans pass in different where clause string
  --                         for their LOV SQL
  --                         The String should start with AND and conform with dynamic
  --                         SQL syntax  e.g. 'AND purchasing_enabled_flag = ''Y'''
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --      Functions: This procedure uses dynamic SQL to handle different where clauses for
  --                 LOV query. Because of the way the java file is structured, all the LOV's
  --                 should select the same columns that is the columns finally
  --                 selected should be the superset of the columns needed by all lovs.
  --                 To addd more columns to LOV subfield, one should append the
  --                 new columns to the end of the existing ones. Specifically, one should
  --                 modify the following local variable, l_sql_stmt.
  --

  PROCEDURE get_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_where_clause IN VARCHAR2) IS
    posstring      NUMBER         := 0;
    l_where_clause VARCHAR2(7500) := '';
    l_sql_stmt      VARCHAR2(7500);
    l_conc_seg varchar2(2000) := p_concatenated_segments;
    l_append varchar2(2):='';
    -- Bug# 6747729
    -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
    l_sql_stmt1     VARCHAR2(7500)
  :=    'select concatenated_segments,'
     || 'msik.inventory_item_id, msik.description,'
     || 'Nvl(revision_qty_control_code,1),'
     || 'Nvl(lot_control_code, 1),'
     || 'Nvl(serial_number_control_code, 1),'
     || 'Nvl(restrict_subinventories_code, 2),'
     || 'Nvl(restrict_locators_code, 2),'
     || 'Nvl(location_control_code, 1),'
     || 'primary_uom_code,'
     || 'Nvl(inspection_required_flag, ''N''),'
     || 'Nvl(shelf_life_code, 1),'
     || 'Nvl(shelf_life_days,0),'
     || 'Nvl(allowed_units_lookup_code, 2),'
     || 'Nvl(effectivity_control,1), '
     || '0, 0,'
     || 'Nvl(default_serial_status_id,1), '
     || 'Nvl(serial_status_enabled,''N''), '
     || 'Nvl(default_lot_status_id,0), '
     || 'Nvl(lot_status_enabled,''N''), '
     || 'null, '
     || '''N'', '
     || 'inventory_item_flag, '
     || '0,'
     || 'wms_deploy.get_item_client_name(msik.inventory_item_id),'
     || 'inventory_asset_flag,'
     || 'outside_operation_flag,'
     --Bug No 3952081
     --Additional Fields for Process Convergence
     || 'NVL(GRADE_CONTROL_FLAG,''N''),'
     || 'NVL(DEFAULT_GRADE,''''),'
     || 'NVL(EXPIRATION_ACTION_INTERVAL,0),'
     || 'NVL(EXPIRATION_ACTION_CODE,''''),'
     || 'NVL(HOLD_DAYS,0),'
     || 'NVL(MATURITY_DAYS,0),'
     || 'NVL(RETEST_INTERVAL,0),'
     || 'NVL(COPY_LOT_ATTRIBUTE_FLAG,''N''),'
     || 'NVL(CHILD_LOT_FLAG,''N''),'
     || 'NVL(CHILD_LOT_VALIDATION_FLAG,''N''),'
     || 'NVL(LOT_DIVISIBLE_FLAG,''Y''),'
     || 'NVL(SECONDARY_UOM_CODE,''''),'
     || 'NVL(SECONDARY_DEFAULT_IND,''''),'
     || 'NVL(TRACKING_QUANTITY_IND,''P''),'
     || 'NVL(DUAL_UOM_DEVIATION_HIGH,0),'
     || 'NVL(DUAL_UOM_DEVIATION_LOW,0),'
     || 'stock_enabled_flag';
    -- Bug# 6747729
    -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
    l_sql_stmt_xref     VARCHAR2(7500)
  :=    'select concatenated_segments,'
     || 'msik.inventory_item_id, msik.description,'
     || 'Nvl(revision_qty_control_code,1),'
     || 'Nvl(lot_control_code, 1),'
     || 'Nvl(serial_number_control_code, 1),'
     || 'Nvl(restrict_subinventories_code, 2),'
     || 'Nvl(restrict_locators_code, 2),'
     || 'Nvl(location_control_code, 1),'
     || 'primary_uom_code,'
     || 'Nvl(inspection_required_flag, ''N''),'
     || 'Nvl(shelf_life_code, 1),'
     || 'Nvl(shelf_life_days,0),'
     || 'Nvl(allowed_units_lookup_code, 2),'
     || 'Nvl(effectivity_control,1), '
     || '0, 0,'
     || 'Nvl(default_serial_status_id,1), '
     || 'Nvl(serial_status_enabled,''N''), '
     || 'Nvl(default_lot_status_id,0), '
     || 'Nvl(lot_status_enabled,''N''), '
     || 'mcr.cross_reference, '
     || '''N'', '
     || 'inventory_item_flag, '
     || '0,'
     || 'wms_deploy.get_item_client_name(msik.inventory_item_id),'
     || 'inventory_asset_flag,'
     || 'outside_operation_flag,'
     --Bug No 3952081
     --Additional Fields for Process Convergence
     || 'NVL(GRADE_CONTROL_FLAG,''N''),'
     || 'NVL(DEFAULT_GRADE,''''),'
     || 'NVL(EXPIRATION_ACTION_INTERVAL,0),'
     || 'NVL(EXPIRATION_ACTION_CODE,''''),'
     || 'NVL(HOLD_DAYS,0),'
     || 'NVL(MATURITY_DAYS,0),'
     || 'NVL(RETEST_INTERVAL,0),'
     || 'NVL(COPY_LOT_ATTRIBUTE_FLAG,''N''),'
     || 'NVL(CHILD_LOT_FLAG,''N''),'
     || 'NVL(CHILD_LOT_VALIDATION_FLAG,''N''),'
     || 'NVL(LOT_DIVISIBLE_FLAG,''Y''),'
     || 'NVL(SECONDARY_UOM_CODE,''''),'
     || 'NVL(SECONDARY_DEFAULT_IND,''''),'
     || 'NVL(TRACKING_QUANTITY_IND,''P''),'
     || 'NVL(DUAL_UOM_DEVIATION_HIGH,0),'
     || 'NVL(DUAL_UOM_DEVIATION_LOW,0),'
     || 'stock_enabled_flag';

 -- Bug 4997004 sql Id 14813260 Start Added 3 variables to fix the literals issue in l_sql_stmt.
  val VARCHAR2(10)  :='''';
  pad VARCHAR2(20)  :='''00000000000000''';
  flag VARCHAR2(10) :='''Y''';
  -- Bug 4997004 sql Id 14813260 End
  BEGIN
    l_where_clause  := p_where_clause;

    l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

     -- Modified for Bug # 5472330
     -- Changed mtl_system_items_kfv to mtl_system_items_vl

    l_sql_stmt := l_sql_stmt1 || ' from mtl_system_items_vl msik WHERE organization_id = ' || p_organization_id || ' AND concatenated_segments like :l_conc_seg ' || l_where_clause;
    -- 1 effectivity control implies that the item is NOT effectivity
    -- controlled.

    l_sql_stmt := l_sql_stmt || ' UNION ' || l_sql_stmt_xref ||
      ' FROM mtl_system_items_vl msik, mtl_cross_references mcr ' ||
      ' WHERE msik.organization_id = ' || p_organization_id ||
      ' AND msik.inventory_item_id = mcr.inventory_item_id ' ||
      ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type || val ||
      ' AND mcr.cross_reference      like lpad(rtrim(:l_conc_seg
      , ''%'' ), ' || g_gtin_code_length || ' , ' || pad ||')' ||
      ' AND (mcr.organization_id     = msik.organization_id OR mcr.org_independent_flag = ' || flag || ')' || l_where_clause;

    OPEN x_items FOR l_sql_stmt using l_conc_seg||l_append,l_conc_seg;
  END get_item_lov;




  PROCEDURE get_item_lov_sub_loc_moqd(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN NUMBER, p_where_clause IN VARCHAR2) IS
    posstring      NUMBER         := 0;
    l_where_clause VARCHAR2(7500) := '';
    l_sql_stmt      VARCHAR2(7500);
    l_conc_seg varchar2(2000) := p_concatenated_segments;
    l_append varchar2(2):='';
    l_sql_stmt1     VARCHAR2(7500)
  :=    'select distinct msik.concatenated_segments,'
     || 'msik.inventory_item_id, msik.description,'
     || 'Nvl(msik.revision_qty_control_code,1),'
     || 'Nvl(msik.lot_control_code, 1),'
     || 'Nvl(msik.serial_number_control_code, 1),'
     || 'Nvl(msik.restrict_subinventories_code, 2),'
     || 'Nvl(msik.restrict_locators_code, 2),'
     || 'Nvl(msik.location_control_code, 1),'
     || ' msik.primary_uom_code,'
     || 'Nvl(msik.inspection_required_flag, ''N''),'
     || 'Nvl(msik.shelf_life_code, 1),'
     || 'Nvl(msik.shelf_life_days,0),'
     || 'Nvl(msik.allowed_units_lookup_code, 2),'
     || 'Nvl(msik.effectivity_control,1), '
     || '0, 0,'
     || 'Nvl(msik.default_serial_status_id,1), '
     || 'Nvl(msik.serial_status_enabled,''N''), '
     || 'Nvl(msik.default_lot_status_id,0), '
     || 'Nvl(msik.lot_status_enabled,''N''), '
     || 'null, '
     || '''N'', '
     || ' msik.inventory_item_flag, '
     || '0,'
     || 'wms_deploy.get_item_client_name(msik.inventory_item_id),'
     || ' msik.inventory_asset_flag,'
     || ' msik.outside_operation_flag,'
     --Bug No 3952081
     --Additional Fields for Process Convergence
     || 'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
     || 'NVL(msik.DEFAULT_GRADE,''''),'
     || 'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
     || 'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
     || 'NVL(msik.HOLD_DAYS,0),'
     || 'NVL(msik.MATURITY_DAYS,0),'
     || 'NVL(msik.RETEST_INTERVAL,0),'
     || 'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
     || 'NVL(msik.CHILD_LOT_FLAG,''N''),'
     || 'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
     || 'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
     || 'NVL(msik.SECONDARY_UOM_CODE,''''),'
     || 'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
     || 'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
     || 'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
     || 'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';
	l_sql_stmt_xref     VARCHAR2(7500)
	 :=    'select distinct msik.concatenated_segments,'
	|| 'msik.inventory_item_id, msik.description,'
	|| 'Nvl(msik.revision_qty_control_code,1),'
	|| 'Nvl(msik.lot_control_code, 1),'
	|| 'Nvl(msik.serial_number_control_code, 1),'
	|| 'Nvl(msik.restrict_subinventories_code, 2),'
	|| 'Nvl(msik.restrict_locators_code, 2),'
	|| 'Nvl(msik.location_control_code, 1),'
	|| ' msik.primary_uom_code,'
	|| 'Nvl(msik.inspection_required_flag, ''N''),'
	|| 'Nvl(msik.shelf_life_code, 1),'
	|| 'Nvl(msik.shelf_life_days,0),'
	|| 'Nvl(msik.allowed_units_lookup_code, 2),'
	|| 'Nvl(msik.effectivity_control,1), '
	|| '0, 0,'
	|| 'Nvl(msik.default_serial_status_id,1), '
	|| 'Nvl(msik.serial_status_enabled,''N''), '
	|| 'Nvl(msik.default_lot_status_id,0), '
	|| 'Nvl(msik.lot_status_enabled,''N''), '
	|| 'null, '
	|| '''N'', '
	|| ' msik.inventory_item_flag, '
	|| '0,'
      || 'wms_deploy.get_item_client_name(msik.inventory_item_id),'
	|| ' msik.inventory_asset_flag,'
	|| ' msik.outside_operation_flag,'
	--Additional Fields for Process Convergence
	|| 'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
	|| 'NVL(msik.DEFAULT_GRADE,''''),'
	|| 'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
	|| 'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
	|| 'NVL(msik.HOLD_DAYS,0),'
	|| 'NVL(msik.MATURITY_DAYS,0),'
	|| 'NVL(msik.RETEST_INTERVAL,0),'
	|| 'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
	|| 'NVL(msik.CHILD_LOT_FLAG,''N''),'
	|| 'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
	|| 'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
	|| 'NVL(msik.SECONDARY_UOM_CODE,''''),'
	|| 'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
	|| 'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
	|| 'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
	|| 'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';

  BEGIN
    l_where_clause  := p_where_clause;
    l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

IF (p_locator_id IS NOT NULL ) THEN
    l_sql_stmt := l_sql_stmt1 || ' from mtl_system_items_vl msik, mtl_onhand_quantities_detail moqd  WHERE msik.organization_id = ' || p_organization_id || ' AND moqd.subinventory_code = ''' || p_subinventory_code /* Bug 5581528 */
 || ''' AND moqd.locator_id = ' || p_locator_id ||
' AND msik.concatenated_segments like :l_conc_seg ' || ' AND msik.organization_id = moqd.organization_id AND msik.inventory_item_id = moqd.inventory_item_id ' || l_where_clause;

	l_sql_stmt := l_sql_stmt || ' UNION ' || l_sql_stmt_xref ||
	 ' FROM mtl_system_items_vl msik, mtl_cross_references mcr ' || /* Bug 5581528 */
	 ' WHERE msik.organization_id = ' || p_organization_id ||
	 ' AND msik.inventory_item_id = mcr.inventory_item_id ' ||
	 ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type ||''''||
	 ' AND mcr.cross_reference      like lpad(rtrim(:l_conc_seg
	 , ''%'' ), ' || g_gtin_code_length || ' , ' || '''00000000000000'''||')' ||
	 ' AND (mcr.organization_id     = msik.organization_id OR mcr.org_independent_flag = ' || '''Y''' || ')' || l_where_clause;

ELSE
    l_sql_stmt := l_sql_stmt1 || ' from mtl_system_items_vl msik, mtl_onhand_quantities_detail moqd  WHERE msik.organization_id = ' || p_organization_id || ' AND moqd.subinventory_code = ''' || p_subinventory_code /* Bug 5581528 */
 || ''' AND msik.concatenated_segments like :l_conc_seg ' || ' AND msik.organization_id = moqd.organization_id AND msik.inventory_item_id = moqd.inventory_item_id ' || l_where_clause;

	   l_sql_stmt := l_sql_stmt || ' UNION ' || l_sql_stmt_xref ||
	 ' FROM mtl_system_items_vl msik, mtl_cross_references mcr ' || /* Bug 5581528 */
	 ' WHERE msik.organization_id = ' || p_organization_id ||
	 ' AND msik.inventory_item_id = mcr.inventory_item_id ' ||
	 ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type ||''''||
	 ' AND mcr.cross_reference      like lpad(rtrim(:l_conc_seg
	 , ''%'' ), ' || g_gtin_code_length || ' , ' || '''00000000000000'''||')' ||
	 ' AND (mcr.organization_id     = msik.organization_id OR mcr.org_independent_flag = ' || '''Y''' || ')' || l_where_clause;
	   l_sql_stmt := l_sql_stmt || ' UNION ' || l_sql_stmt_xref ||
	 ' FROM mtl_system_items_vl msik, mtl_cross_references mcr ' || /* Bug 5581528 */
	 ' WHERE msik.organization_id = ' || p_organization_id ||
	 ' AND msik.inventory_item_id = mcr.inventory_item_id ' ||
	 ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type ||''''||
	 ' AND mcr.cross_reference      like lpad(rtrim(:l_conc_seg
	 , ''%'' ), ' || g_gtin_code_length || ' , ' || '''00000000000000'''||')' ||
	 ' AND (mcr.organization_id     = msik.organization_id OR mcr.org_independent_flag = ' || '''Y''' || ')' || l_where_clause;

END IF;

	IF p_locator_id IS NOT NULL THEN
	    OPEN x_items FOR l_sql_stmt using l_conc_seg||l_append,l_conc_seg;
	ELSE
	   OPEN x_items FOR l_sql_stmt using l_conc_seg||l_append,l_conc_seg,l_conc_seg;
	END IF;
  END get_item_lov_sub_loc_moqd;







 --Bug #5443966
--Removed inventory_asset_flag from the SELECT statements
--since it is not used in the Query MO Issue/Xfer pages
PROCEDURE get_mo_item_lov
  (x_Items OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_Concatenated_Segments IN VARCHAR2,
   p_header_id IN VARCHAR2)
  IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  l_Concatenated_Segments VARCHAR2(204):=p_Concatenated_Segments;
BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   if l_Concatenated_Segments is not null then
	l_Concatenated_Segments:=l_Concatenated_Segments||wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);
   end if;


   OPEN x_items FOR
     SELECT concatenated_segments,
            inventory_item_id,
            description,
            Nvl(revision_qty_control_code,1),
            Nvl(lot_control_code, 1),
            Nvl(serial_number_control_code, 1),
            Nvl(restrict_subinventories_code, 2),
            Nvl(restrict_locators_code, 2),
            Nvl(location_control_code, 1),
            primary_uom_code,
            Nvl(inspection_required_flag, 'N'),
            Nvl(shelf_life_code, 1),
            Nvl(shelf_life_days,0),
            Nvl(allowed_units_lookup_code, 2),
            Nvl(effectivity_control,1),
            0,
            0,
            Nvl(default_serial_status_id,1),
            Nvl(serial_status_enabled,'N'),
            Nvl(default_lot_status_id,0),
            Nvl(lot_status_enabled,'N'),
            '',
            'N',
            inventory_item_flag,
            0,
            wms_deploy.get_item_client_name(inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
            NVL(GRADE_CONTROL_FLAG,'N'),
            NVL(DEFAULT_GRADE,''),
            NVL(EXPIRATION_ACTION_INTERVAL,0),
            NVL(EXPIRATION_ACTION_CODE,''),
            NVL(HOLD_DAYS,0),
            NVL(MATURITY_DAYS,0),
            NVL(RETEST_INTERVAL,0),
            NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
            NVL(CHILD_LOT_FLAG,'N'),
            NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
            NVL(LOT_DIVISIBLE_FLAG,'Y'),
            NVL(SECONDARY_UOM_CODE,''),
            NVL(SECONDARY_DEFAULT_IND,''),
            NVL(TRACKING_QUANTITY_IND,'P'),
            NVL(DUAL_UOM_DEVIATION_HIGH,0),
            NVL(DUAL_UOM_DEVIATION_LOW,0)
     FROM   mtl_system_items_vl /* Bug 5581528 */
     WHERE  organization_id = p_organization_id
     AND    concatenated_segments LIKE nvl(l_concatenated_segments,concatenated_segments)
     AND    inventory_item_id in (select inventory_item_id from mtl_txn_request_lines where header_id =to_number(p_header_id))

     --Changes for GTIN
     UNION

     SELECT concatenated_segments,
            msik.inventory_item_id,
            msik.description,
            Nvl(revision_qty_control_code,1),
            Nvl(lot_control_code, 1),
            Nvl(serial_number_control_code, 1),
            Nvl(restrict_subinventories_code, 2),
            Nvl(restrict_locators_code, 2),
            Nvl(location_control_code, 1),
            primary_uom_code,
            Nvl(inspection_required_flag, 'N'),
            Nvl(shelf_life_code, 1),
            Nvl(shelf_life_days,0),
            Nvl(allowed_units_lookup_code, 2),
            Nvl(effectivity_control,1),
            0,
            0,
            Nvl(default_serial_status_id,1),
            Nvl(serial_status_enabled,'N'),
            Nvl(default_lot_status_id,0),
            Nvl(lot_status_enabled,'N'),
            mcr.cross_reference,
            'N',
            inventory_item_flag,
            0,
            wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
            NVL(GRADE_CONTROL_FLAG,'N'),
            NVL(DEFAULT_GRADE,''),
            NVL(EXPIRATION_ACTION_INTERVAL,0),
            NVL(EXPIRATION_ACTION_CODE,''),
            NVL(HOLD_DAYS,0),
            NVL(MATURITY_DAYS,0),
            NVL(RETEST_INTERVAL,0),
            NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
            NVL(CHILD_LOT_FLAG,'N'),
            NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
            NVL(LOT_DIVISIBLE_FLAG,'Y'),
            NVL(SECONDARY_UOM_CODE,''),
            NVL(SECONDARY_DEFAULT_IND,''),
            NVL(TRACKING_QUANTITY_IND,'P'),
            NVL(DUAL_UOM_DEVIATION_HIGH,0),
            NVL(DUAL_UOM_DEVIATION_LOW,0)
     FROM   mtl_system_items_vl msik, mtl_cross_references mcr /* Bug 5581528 */
     WHERE  msik.organization_id = p_organization_id
     AND    msik.inventory_item_id   = mcr.inventory_item_id
     AND    mcr.cross_reference_type = g_gtin_cross_ref_type
     AND    mcr.cross_reference      LIKE l_cross_ref
     AND    (mcr.organization_id     = msik.organization_id
             OR
             mcr.org_independent_flag = 'Y');

END get_mo_item_lov;


  PROCEDURE get_transactable_items(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_transaction_action_id IN NUMBER, p_to_organization_id IN NUMBER) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN
   --Bug 2769632 Modified the sub query so that invalid combinations of lot/serial and revision items are not visible in the LOV
   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    OPEN x_items FOR
      SELECT msik.concatenated_segments
           , msik.inventory_item_id
           , msik.description
           , NVL(msik.revision_qty_control_code, 1)
           , NVL(msik.lot_control_code, 1)
           , NVL(msik.serial_number_control_code, 1)
           , NVL(msik.restrict_subinventories_code, 2)
           , NVL(msik.restrict_locators_code, 2)
           , NVL(msik.location_control_code, 1)
           , msik.primary_uom_code
           , NVL(msik.inspection_required_flag, 2)
           , NVL(msik.shelf_life_code, 1)
           , NVL(msik.shelf_life_days, 0)
           , NVL(msik.allowed_units_lookup_code, 2)
           , NVL(msik.effectivity_control, 1)
           , 0
           , 0
           , NVL(msik.default_serial_status_id, 0)
           , NVL(msik.serial_status_enabled, 'N')
           , NVL(msik.default_lot_status_id, 0)
           , NVL(msik.lot_status_enabled, 'N')
           , ''
           , 'N'
           , msik.inventory_item_flag
           , 0
	     , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
           NVL(msik.GRADE_CONTROL_FLAG,'N'),
           NVL(msik.DEFAULT_GRADE,''),
           NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
           NVL(msik.EXPIRATION_ACTION_CODE,''),
           NVL(msik.HOLD_DAYS,0),
           NVL(msik.MATURITY_DAYS,0),
           NVL(msik.RETEST_INTERVAL,0),
           NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
           NVL(msik.CHILD_LOT_FLAG,'N'),
           NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
           NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
           NVL(msik.SECONDARY_UOM_CODE,''),
           NVL(msik.SECONDARY_DEFAULT_IND,''),
           NVL(msik.TRACKING_QUANTITY_IND,'P'),
           NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
           NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
        FROM mtl_system_items_vl msik /* Bug 5581528 */
       WHERE msik.organization_id = p_organization_id
         AND msik.mtl_transactions_enabled_flag = 'Y'
         AND ((p_transaction_action_id=3 AND EXISTS (SELECT 1
                                                    FROM mtl_system_items_b msib
                                                    WHERE msib.inventory_item_id=msik.inventory_item_id
                                                    AND  msib.organization_id = p_to_organization_id
                                                    AND msib.mtl_transactions_enabled_flag = 'Y'
                                                    AND (NVL(msik.lot_control_code,1)=2 OR nvl(msib.lot_control_code,1)=1)
                                                    AND (NVL(msik.serial_number_control_code,1) IN (2,5) OR nvl(msib.serial_number_control_code,1) IN (1,6))
                                                   AND (NVL(msik.revision_qty_control_code,1)=2 OR NVL(msib.revision_qty_control_code,1)=1)))
              OR (p_transaction_action_id<>3 AND EXISTS (SELECT 1
                                                        FROM mtl_system_items_b msib1
                                                        WHERE msib1.inventory_item_id=msik.inventory_item_id
                                                        AND msib1.organization_id=p_to_organization_id
                                                        AND msib1.mtl_transactions_enabled_flag='Y')))
      AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)

      -- Changes for GTIN
      UNION
      SELECT concatenated_segments
           , msik.inventory_item_id
           , msik.description
           , NVL(revision_qty_control_code, 1)
           , NVL(lot_control_code, 1)
           , NVL(serial_number_control_code, 1)
           , NVL(restrict_subinventories_code, 2)
           , NVL(restrict_locators_code, 2)
           , NVL(location_control_code, 1)
           , primary_uom_code
           , NVL(inspection_required_flag, 2)
           , NVL(shelf_life_code, 1)
           , NVL(shelf_life_days, 0)
           , NVL(allowed_units_lookup_code, 2)
           , NVL(effectivity_control, 1)
           , 0
           , 0
           , NVL(default_serial_status_id, 0)
           , NVL(serial_status_enabled, 'N')
           , NVL(default_lot_status_id, 0)
           , NVL(lot_status_enabled, 'N')
           , mcr.cross_reference
           , 'N'
           , inventory_item_flag
           , 0
	     , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
           NVL(GRADE_CONTROL_FLAG,'N'),
           NVL(DEFAULT_GRADE,''),
           NVL(EXPIRATION_ACTION_INTERVAL,0),
           NVL(EXPIRATION_ACTION_CODE,''),
           NVL(HOLD_DAYS,0),
           NVL(MATURITY_DAYS,0),
           NVL(RETEST_INTERVAL,0),
           NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
           NVL(CHILD_LOT_FLAG,'N'),
           NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
           NVL(LOT_DIVISIBLE_FLAG,'Y'),
           NVL(SECONDARY_UOM_CODE,''),
           NVL(SECONDARY_DEFAULT_IND,''),
           NVL(TRACKING_QUANTITY_IND,'P'),
           NVL(DUAL_UOM_DEVIATION_HIGH,0),
           NVL(DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msik, mtl_cross_references mcr /* Bug 5581528 */
      WHERE msik.organization_id = p_organization_id
      AND msik.mtl_transactions_enabled_flag = 'Y'
      AND ((p_transaction_action_id=3 AND EXISTS (SELECT 1
                                                 FROM mtl_system_items_b msib
                                                 WHERE msib.inventory_item_id=msik.inventory_item_id
                                                 AND msib.organization_id = p_to_organization_id
                                                 AND msib.mtl_transactions_enabled_flag ='Y'
                                                 AND (NVL(msik.lot_control_code,1)=2 OR nvl(msib.lot_control_code,1)=1)
                                                 AND (NVL(msik.serial_number_control_code,1) IN (2,5) OR nvl(msib.serial_number_control_code,1) IN (1,6))
                                                 AND (NVL(msik.revision_qty_control_code,1)=2 OR NVL(msib.revision_qty_control_code,1)=1)))
           OR ((p_transaction_action_id <>3 AND EXISTS(SELECT 1
                                                   FROM mtl_system_items_b msib1
                                                   WHERE  msib1.inventory_item_id=msik.inventory_item_id
                                                     AND msib1.organization_id=p_to_organization_id
                                                    AND msib1.mtl_transactions_enabled_flag='Y'))))
      AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id OR mcr.org_independent_flag = 'Y');
  END get_transactable_items;

  --      Name: GET_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_revision            Revision
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_revs                Returns LOV rows as Reference Cursor
  --
  --      Functions: This procedure returns valid Revisions after restricting it by
  --                 Org, Item, Planning and Owning criterions.
  --
  --

  PROCEDURE get_revision_lov(
    x_revs OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_revision IN VARCHAR2
  , p_planning_org_id IN NUMBER
  , p_planning_tp_type IN NUMBER
  , p_owning_org_id IN NUMBER
  , p_owning_tp_type IN NUMBER
  ) IS
  BEGIN
    OPEN x_revs FOR
      SELECT a.revision, a.effectivity_date, NVL(a.description, '')
        FROM mtl_item_revisions a
       WHERE a.organization_id = p_organization_id
         AND a.inventory_item_id = p_inventory_item_id
          /* Bug# 8912324: Commented the code below so as to allow unimplemented item
            revisions for other transactions except misc issue/ receipt */
         -- AND a.implementation_date is not null                --BUG 7204523 Added to restrict the revisions that are not yet implemented.
         AND a.revision LIKE (p_revision)
         AND (p_planning_org_id IS NULL
              OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                         WHERE moqd.revision = a.revision
                           AND moqd.organization_id = a.organization_id
                           AND moqd.inventory_item_id = a.inventory_item_id
                           AND moqd.planning_organization_id = p_planning_org_id
                           AND moqd.planning_tp_type = p_planning_tp_type))
         AND (p_owning_org_id IS NULL
              OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                         WHERE moqd.revision = a.revision
                           AND moqd.organization_id = a.organization_id
                           AND moqd.inventory_item_id = a.inventory_item_id
                           AND moqd.owning_organization_id = p_owning_org_id
                           AND moqd.owning_tp_type = p_owning_tp_type));
  END get_revision_lov;


  --      Name: GET_INV_TXN_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_revision            Revision
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_revs                Returns LOV rows as Reference Cursor
  --
  --      Functions: This procedure returns valid Revisions after restricting it by
  --                 Org, Item, Planning and Owning criterions.
  --                 This lov is only applicable for inv transactions whicn restricts
  --                 unimplemented item revisions

  /* Bug# 8912324 : Added new proc get_inv_txn_revision_lov */
  PROCEDURE get_inv_txn_revision_lov(
    x_revs OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_revision IN VARCHAR2
  , p_planning_org_id IN NUMBER
  , p_planning_tp_type IN NUMBER
  , p_owning_org_id IN NUMBER
  , p_owning_tp_type IN NUMBER
  ) IS
  BEGIN
    OPEN x_revs FOR
      SELECT a.revision, a.effectivity_date, NVL(a.description, '')
        FROM mtl_item_revisions a
       WHERE a.organization_id = p_organization_id
         AND a.inventory_item_id = p_inventory_item_id
         AND a.implementation_date is not null                --BUG 7204523 Added to restrict the revisions that are not yet implemented.
         AND a.revision LIKE (p_revision)
         AND (p_planning_org_id IS NULL
              OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                         WHERE moqd.revision = a.revision
                           AND moqd.organization_id = a.organization_id
                           AND moqd.inventory_item_id = a.inventory_item_id
                           AND moqd.planning_organization_id = p_planning_org_id
                           AND moqd.planning_tp_type = p_planning_tp_type))
         AND (p_owning_org_id IS NULL
              OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                         WHERE moqd.revision = a.revision
                           AND moqd.organization_id = a.organization_id
                           AND moqd.inventory_item_id = a.inventory_item_id
                           AND moqd.owning_organization_id = p_owning_org_id
                           AND moqd.owning_tp_type = p_owning_tp_type));
  END get_inv_txn_revision_lov;

  --      Name: GET_UOM_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_UOM_code   which restricts LOV SQL to the user input text
  --                                e.g.  Ea%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --

  --Bug # 2647045
  PROCEDURE get_uom_lov(x_UOMS OUT NOCOPY t_genref,
		      p_Organization_Id IN NUMBER,
		      p_Inventory_Item_Id IN NUMBER,
		      p_UOM_Code IN VARCHAR2) IS
     l_code VARCHAR2(20):=p_UOM_Code;
  BEGIN
    IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_UOM_Code,1,INSTR(p_UOM_Code,'(')-1);
    END IF;

    OPEN x_uoms FOR
      SELECT (inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) uom_code_comp
           , unit_of_measure
           , description
           , uom_class
        FROM mtl_item_uoms_view
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         AND uom_code LIKE (l_code)
      ORDER BY inv_ui_item_lovs.conversion_order(inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) asc, Upper(uom_code);
  END get_uom_lov;

  --      Name: GET_UOM_LOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_uom_type  restrict LOV to certain UOM type
  --       p_UOM_code   which restricts LOV SQL to the user input text
  --                                e.g.  Ea%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns UOM LOV rows for a given org, item and
  --                 user input text.
  --                 This API is for RECEIVING transaction only
  --
  -- Bug 2192815
  -- The part for Expense Items is now moved over to INVRCVLB.pls, INVRCVLS.pls
  -- The name of the procedure is get_uom_lov_expense
  --

  --Bug # 2647045
  PROCEDURE get_uom_lov_rcv(x_uoms OUT NOCOPY t_genref,
			  p_organization_id IN NUMBER,
			  p_item_id IN NUMBER,
			  p_uom_type IN NUMBER,
			  p_uom_code IN VARCHAR2) IS
     l_code VARCHAR2(20):=p_uom_code;
  BEGIN
    IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_uom_code,1,INSTR(p_uom_code,'(')-1);
    END IF;

    IF (p_item_id IS NOT NULL
        AND p_item_id > 0
       ) THEN
      OPEN x_uoms FOR
        SELECT   (inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_organization_id,
				   Inventory_Item_Id)) uom_code_comp
               , unit_of_measure
               , description
               , uom_class
            FROM mtl_item_uoms_view
           WHERE organization_id = p_organization_id
             AND inventory_item_id(+) = p_item_id
             AND NVL(uom_type, 3) = NVL(p_uom_type, 3)
             AND uom_code LIKE (l_code)
	     ORDER BY inv_ui_item_lovs.conversion_order(inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_organization_id,
				   Inventory_Item_Id)) asc, Upper(uom_code);
    -- Bug 2192815
    -- The following is commented out as this is part of INVRCVLB.pls now
    -- ELSE
    -- OPEN x_uoms FOR
    --SELECT uom_code
    --, unit_of_measure
    --, ''
    --, uom_class
    --FROM mtl_units_of_measure
    --WHERE base_uom_flag = 'Y'
    --AND uom_code LIKE (p_uom_code || '%')
    --ORDER BY Upper(uom_code);

    END IF;
  END get_uom_lov_rcv;

  PROCEDURE get_lot_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lot_number IN VARCHAR2, p_transaction_type_id IN VARCHAR2, p_concatenated_segments IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    IF p_transaction_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                                THEN
      OPEN x_items FOR
        SELECT   msik.concatenated_segments concatenated_segments
               , msik.inventory_item_id
               , msik.description
               , NVL(msik.revision_qty_control_code, 1)
               , NVL(msik.lot_control_code, 1)
               , NVL(msik.serial_number_control_code, 1)
               , NVL(msik.restrict_subinventories_code, 2)
               , NVL(msik.restrict_locators_code, 2)
               , NVL(msik.location_control_code, 1)
               , msik.primary_uom_code
               , NVL(msik.inspection_required_flag, 2)
               , NVL(msik.shelf_life_code, 1)
               , NVL(msik.shelf_life_days, 0)
               , NVL(msik.allowed_units_lookup_code, 2)
               , NVL(msik.effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(msik.default_serial_status_id, 0)
               , NVL(msik.serial_status_enabled, 'N')
               , NVL(msik.default_lot_status_id, 0)
               , NVL(msik.lot_status_enabled, 'N')
               , ''
               , 'N'
               , msik.inventory_item_flag
               , 0
		   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
            FROM mtl_system_items_vl msik, mtl_lot_numbers mln /* Bug 5581528 */
           WHERE msik.lot_split_enabled = 'Y'
             AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
             AND msik.organization_id = mln.organization_id
             AND msik.inventory_item_id = mln.inventory_item_id
             AND mln.lot_number = p_lot_number
             AND mln.organization_id = p_organization_id
             AND (NVL(msik.lot_status_enabled, 'N') = 'N'
                 OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                                 WHERE status_id = mln.status_id
                                   AND transaction_type_id = p_transaction_type_id
                                   AND is_allowed = 2))


	--Changes for GTIN

	UNION

	SELECT   msik.concatenated_segments concatenated_segments
               , msik.inventory_item_id
               , msik.description
               , NVL(msik.revision_qty_control_code, 1)
               , NVL(msik.lot_control_code, 1)
               , NVL(msik.serial_number_control_code, 1)
               , NVL(msik.restrict_subinventories_code, 2)
               , NVL(msik.restrict_locators_code, 2)
               , NVL(msik.location_control_code, 1)
               , msik.primary_uom_code
               , NVL(msik.inspection_required_flag, 2)
               , NVL(msik.shelf_life_code, 1)
               , NVL(msik.shelf_life_days, 0)
               , NVL(msik.allowed_units_lookup_code, 2)
               , NVL(msik.effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(msik.default_serial_status_id, 0)
               , NVL(msik.serial_status_enabled, 'N')
               , NVL(msik.default_lot_status_id, 0)
               , NVL(msik.lot_status_enabled, 'N')
               , mcr.cross_reference
               , 'N'
               , msik.inventory_item_flag
               , 0
		   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl msik, /* Bug 5581528 */
	mtl_lot_numbers mln,
	mtl_cross_references mcr
	WHERE msik.lot_split_enabled = 'Y'
	AND msik.organization_id = mln.organization_id
	AND msik.inventory_item_id = mln.inventory_item_id
	AND mln.lot_number = p_lot_number
	AND mln.organization_id = p_organization_id
	AND msik.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msik.organization_id
	     OR
	     mcr.org_independent_flag = 'Y')
        AND (NVL(msik.lot_status_enabled, 'N') = 'N'
             OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                             WHERE status_id = mln.status_id
                               AND transaction_type_id = p_transaction_type_id
                               AND is_allowed = 2))
	ORDER BY concatenated_segments;

    ELSE
      IF p_transaction_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                                  THEN
        OPEN x_items FOR
          SELECT   msik.concatenated_segments concatenated_segments
                 , msik.inventory_item_id
                 , msik.description
                 , NVL(msik.revision_qty_control_code, 1)
                 , NVL(msik.lot_control_code, 1)
                 , NVL(msik.serial_number_control_code, 1)
                 , NVL(msik.restrict_subinventories_code, 2)
                 , NVL(msik.restrict_locators_code, 2)
                 , NVL(msik.location_control_code, 1)
                 , msik.primary_uom_code
                 , NVL(msik.inspection_required_flag, 2)
                 , NVL(msik.shelf_life_code, 1)
                 , NVL(msik.shelf_life_days, 0)
                 , NVL(msik.allowed_units_lookup_code, 2)
                 , NVL(msik.effectivity_control, 1)
                 , 0 parentlpnid
                 , 0 quantity
                 , NVL(msik.default_serial_status_id, 0)
                 , NVL(msik.serial_status_enabled, 'N')
                 , NVL(msik.default_lot_status_id, 0)
                 , NVL(msik.lot_status_enabled, 'N')
                 , ''
                 , 'N'
                 , msik.inventory_item_flag
                 , 0
		     , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
              FROM mtl_system_items_vl msik, mtl_lot_numbers mln /* Bug 5581528 */
             WHERE msik.lot_merge_enabled = 'Y'
               AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
               AND msik.organization_id = mln.organization_id
               AND msik.inventory_item_id = mln.inventory_item_id
               AND mln.lot_number = p_lot_number
  	       AND mln.organization_id = p_organization_id
               AND (NVL(msik.lot_status_enabled, 'N') = 'N'
                   OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                                   WHERE status_id = mln.status_id
                                     AND transaction_type_id = p_transaction_type_id
                                     AND is_allowed = 2))


	  --Changes for GTIN

	  UNION

          SELECT   msik.concatenated_segments concatenated_segments
                 , msik.inventory_item_id
                 , msik.description
                 , NVL(msik.revision_qty_control_code, 1)
                 , NVL(msik.lot_control_code, 1)
                 , NVL(msik.serial_number_control_code, 1)
                 , NVL(msik.restrict_subinventories_code, 2)
                 , NVL(msik.restrict_locators_code, 2)
                 , NVL(msik.location_control_code, 1)
                 , msik.primary_uom_code
                 , NVL(msik.inspection_required_flag, 2)
                 , NVL(msik.shelf_life_code, 1)
                 , NVL(msik.shelf_life_days, 0)
                 , NVL(msik.allowed_units_lookup_code, 2)
                 , NVL(msik.effectivity_control, 1)
                 , 0 parentlpnid
                 , 0 quantity
                 , NVL(msik.default_serial_status_id, 0)
                 , NVL(msik.serial_status_enabled, 'N')
                 , NVL(msik.default_lot_status_id, 0)
                 , NVL(msik.lot_status_enabled, 'N')
                 , mcr.cross_reference
                 , 'N'
                 , msik.inventory_item_flag
                 , 0
		     , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	  FROM mtl_system_items_vl msik, /* Bug 5581528 */
	  mtl_lot_numbers mln,
	  mtl_cross_references mcr
	  WHERE msik.lot_merge_enabled = 'Y'
	  AND msik.organization_id = mln.organization_id
	  AND msik.inventory_item_id = mln.inventory_item_id
	  AND mln.lot_number = p_lot_number
	  AND mln.organization_id = p_organization_id
	  AND msik.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = msik.organization_id
	       OR
	       mcr.org_independent_flag = 'Y')
          AND (NVL(msik.lot_status_enabled, 'N') = 'N'
               OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                               WHERE status_id = mln.status_id
                                 AND transaction_type_id = p_transaction_type_id
                                 AND is_allowed = 2))
	  ORDER BY concatenated_segments;

      ELSE
        IF p_transaction_type_id = inv_globals.g_type_inv_lot_translate THEN
          IF (p_lot_number IS NOT NULL) THEN
            OPEN x_items FOR
              SELECT   msik.concatenated_segments concatenated_segments
                     , msik.inventory_item_id
                     , msik.description
                     , NVL(msik.revision_qty_control_code, 1)
                     , NVL(msik.lot_control_code, 1)
                     , NVL(msik.serial_number_control_code, 1)
                     , NVL(msik.restrict_subinventories_code, 2)
                     , NVL(msik.restrict_locators_code, 2)
                     , NVL(msik.location_control_code, 1)
                     , msik.primary_uom_code
                     , NVL(msik.inspection_required_flag, 2)
                     , NVL(msik.shelf_life_code, 1)
                     , NVL(msik.shelf_life_days, 0)
                     , NVL(msik.allowed_units_lookup_code, 2)
                     , NVL(msik.effectivity_control, 1)
                     , 0 parentlpnid
                     , 0 quantity
                     , NVL(msik.default_serial_status_id, 0)
                     , NVL(msik.serial_status_enabled, 'N')
                     , NVL(msik.default_lot_status_id, 0)
                     , NVL(msik.lot_status_enabled, 'N')
                     , ''
                     , 'N'
                     , msik.inventory_item_flag
                     , 0
			   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                     NVL(msik.GRADE_CONTROL_FLAG,'N'),
                     NVL(msik.DEFAULT_GRADE,''),
                     NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                     NVL(msik.EXPIRATION_ACTION_CODE,''),
                     NVL(msik.HOLD_DAYS,0),
                     NVL(msik.MATURITY_DAYS,0),
                     NVL(msik.RETEST_INTERVAL,0),
                     NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                     NVL(msik.CHILD_LOT_FLAG,'N'),
                     NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                     NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                     NVL(msik.SECONDARY_UOM_CODE,''),
                     NVL(msik.SECONDARY_DEFAULT_IND,''),
                     NVL(msik.TRACKING_QUANTITY_IND,'P'),
                     NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                     NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                  FROM mtl_system_items_vl msik, mtl_lot_numbers mln /* Bug 5581528 */
                 WHERE msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
                   AND msik.organization_id = mln.organization_id
                   AND msik.inventory_item_id = mln.inventory_item_id
                   AND mln.lot_number = p_lot_number
	           AND mln.organization_id = p_organization_id
                   AND (NVL(msik.lot_status_enabled, 'N') = 'N'
                    OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                                    WHERE status_id = mln.status_id
                                      AND transaction_type_id = p_transaction_type_id
                                      AND is_allowed = 2))

	      --Changes for GTIN

	      UNION

	      SELECT   msik.concatenated_segments concatenated_segments
                     , msik.inventory_item_id
                     , msik.description
                     , NVL(msik.revision_qty_control_code, 1)
                     , NVL(msik.lot_control_code, 1)
                     , NVL(msik.serial_number_control_code, 1)
                     , NVL(msik.restrict_subinventories_code, 2)
                     , NVL(msik.restrict_locators_code, 2)
                     , NVL(msik.location_control_code, 1)
                     , msik.primary_uom_code
                     , NVL(msik.inspection_required_flag, 2)
                     , NVL(msik.shelf_life_code, 1)
                     , NVL(msik.shelf_life_days, 0)
                     , NVL(msik.allowed_units_lookup_code, 2)
                     , NVL(msik.effectivity_control, 1)
                     , 0 parentlpnid
                     , 0 quantity
                     , NVL(msik.default_serial_status_id, 0)
                     , NVL(msik.serial_status_enabled, 'N')
                     , NVL(msik.default_lot_status_id, 0)
                     , NVL(msik.lot_status_enabled, 'N')
                     , mcr.cross_reference
                     , 'N'
                     , msik.inventory_item_flag
                     , 0
			   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                     NVL(msik.GRADE_CONTROL_FLAG,'N'),
                     NVL(msik.DEFAULT_GRADE,''),
                     NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                     NVL(msik.EXPIRATION_ACTION_CODE,''),
                     NVL(msik.HOLD_DAYS,0),
                     NVL(msik.MATURITY_DAYS,0),
                     NVL(msik.RETEST_INTERVAL,0),
                     NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                     NVL(msik.CHILD_LOT_FLAG,'N'),
                     NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                     NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                     NVL(msik.SECONDARY_UOM_CODE,''),
                     NVL(msik.SECONDARY_DEFAULT_IND,''),
                     NVL(msik.TRACKING_QUANTITY_IND,'P'),
                     NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                     NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	      FROM mtl_system_items_vl msik, /* Bug 5581528 */
	      mtl_lot_numbers mln,
	      mtl_cross_references mcr
	      WHERE msik.organization_id = mln.organization_id
	      AND msik.inventory_item_id = mln.inventory_item_id
	      AND mln.lot_number = p_lot_number
	      AND mln.organization_id = p_organization_id
	      AND msik.inventory_item_id   = mcr.inventory_item_id
	      AND mcr.cross_reference_type = g_gtin_cross_ref_type
	      AND mcr.cross_reference      LIKE l_cross_ref
	      AND (mcr.organization_id     = msik.organization_id
		   OR
		   mcr.org_independent_flag = 'Y')
              AND (NVL(msik.lot_status_enabled, 'N') = 'N'
                  OR NOT EXISTS (SELECT 1 FROM  mtl_status_transaction_control
                                  WHERE status_id = mln.status_id
                                    AND transaction_type_id = p_transaction_type_id
                                    AND is_allowed = 2))
	      ORDER BY concatenated_segments;
          ELSE
            OPEN x_items FOR
              SELECT   msik.concatenated_segments concatenated_segments
                     , msik.inventory_item_id
                     , msik.description
                     , NVL(msik.revision_qty_control_code, 1)
                     , NVL(msik.lot_control_code, 1)
                     , NVL(msik.serial_number_control_code, 1)
                     , NVL(msik.restrict_subinventories_code, 2)
                     , NVL(msik.restrict_locators_code, 2)
                     , NVL(msik.location_control_code, 1)
                     , msik.primary_uom_code
                     , NVL(msik.inspection_required_flag, 2)
                     , NVL(msik.shelf_life_code, 1)
                     , NVL(msik.shelf_life_days, 0)
                     , NVL(msik.allowed_units_lookup_code, 2)
                     , NVL(msik.effectivity_control, 1)
                     , 0 parentlpnid
                     , 0 quantity
                     , NVL(msik.default_serial_status_id, 0)
                     , NVL(msik.serial_status_enabled, 'N')
                     , NVL(msik.default_lot_status_id, 0)
                     , NVL(msik.lot_status_enabled, 'N')
                     , ''
                     , 'N'
                     , msik.inventory_item_flag
                     , 0
			   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                     NVL(msik.GRADE_CONTROL_FLAG,'N'),
                     NVL(msik.DEFAULT_GRADE,''),
                     NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                     NVL(msik.EXPIRATION_ACTION_CODE,''),
                     NVL(msik.HOLD_DAYS,0),
                     NVL(msik.MATURITY_DAYS,0),
                     NVL(msik.RETEST_INTERVAL,0),
                     NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                     NVL(msik.CHILD_LOT_FLAG,'N'),
                     NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                     NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                     NVL(msik.SECONDARY_UOM_CODE,''),
                     NVL(msik.SECONDARY_DEFAULT_IND,''),
                     NVL(msik.TRACKING_QUANTITY_IND,'P'),
                     NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                     NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                  FROM mtl_system_items_vl msik /* Bug 5581528 */
                 WHERE msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
                   AND msik.lot_control_code = 2
	      AND msik.organization_id = p_organization_id

	      --Changes for GTIN

	      UNION

	                    SELECT   msik.concatenated_segments concatenated_segments
                     , msik.inventory_item_id
                     , msik.description
                     , NVL(msik.revision_qty_control_code, 1)
                     , NVL(msik.lot_control_code, 1)
                     , NVL(msik.serial_number_control_code, 1)
                     , NVL(msik.restrict_subinventories_code, 2)
                     , NVL(msik.restrict_locators_code, 2)
                     , NVL(msik.location_control_code, 1)
                     , msik.primary_uom_code
                     , NVL(msik.inspection_required_flag, 2)
                     , NVL(msik.shelf_life_code, 1)
                     , NVL(msik.shelf_life_days, 0)
                     , NVL(msik.allowed_units_lookup_code, 2)
                     , NVL(msik.effectivity_control, 1)
                     , 0 parentlpnid
                     , 0 quantity
                     , NVL(msik.default_serial_status_id, 0)
                     , NVL(msik.serial_status_enabled, 'N')
                     , NVL(msik.default_lot_status_id, 0)
                     , NVL(msik.lot_status_enabled, 'N')
                     , mcr.cross_reference
                     , 'N'
                     , msik.inventory_item_flag
                     , 0
			   , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                     NVL(msik.GRADE_CONTROL_FLAG,'N'),
                     NVL(msik.DEFAULT_GRADE,''),
                     NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                     NVL(msik.EXPIRATION_ACTION_CODE,''),
                     NVL(msik.HOLD_DAYS,0),
                     NVL(msik.MATURITY_DAYS,0),
                     NVL(msik.RETEST_INTERVAL,0),
                     NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                     NVL(msik.CHILD_LOT_FLAG,'N'),
                     NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                     NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                     NVL(msik.SECONDARY_UOM_CODE,''),
                     NVL(msik.SECONDARY_DEFAULT_IND,''),
                     NVL(msik.TRACKING_QUANTITY_IND,'P'),
                     NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                     NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	      FROM mtl_system_items_vl msik, /* Bug 5581528 */
	      mtl_cross_references mcr
	      WHERE msik.lot_control_code = 2
	      AND msik.organization_id = p_organization_id
	      AND msik.inventory_item_id   = mcr.inventory_item_id
	      AND mcr.cross_reference_type = g_gtin_cross_ref_type
	      AND mcr.cross_reference      LIKE l_cross_ref
	      AND (mcr.organization_id     = msik.organization_id
		   OR
		   mcr.org_independent_flag = 'Y')
              ORDER BY concatenated_segments;
          END IF;
        ELSE
          OPEN x_items FOR
            SELECT   msik.concatenated_segments concatenated_segments
                   , msik.inventory_item_id
                   , msik.description
                   , NVL(msik.revision_qty_control_code, 1)
                   , NVL(msik.lot_control_code, 1)
                   , NVL(msik.serial_number_control_code, 1)
                   , NVL(msik.restrict_subinventories_code, 2)
                   , NVL(msik.restrict_locators_code, 2)
                   , NVL(msik.location_control_code, 1)
                   , msik.primary_uom_code
                   , NVL(msik.inspection_required_flag, 2)
                   , NVL(msik.shelf_life_code, 1)
                   , NVL(msik.shelf_life_days, 0)
                   , NVL(msik.allowed_units_lookup_code, 2)
                   , NVL(msik.effectivity_control, 1)
                   , 0 parentlpnid
                   , 0 quantity
                   , NVL(msik.default_serial_status_id, 0)
                   , NVL(msik.serial_status_enabled, 'N')
                   , NVL(msik.default_lot_status_id, 0)
                   , NVL(msik.lot_status_enabled, 'N')
                   , ''
                   , 'N'
                   , msik.inventory_item_flag
                   , 0
			 , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                   NVL(msik.GRADE_CONTROL_FLAG,'N'),
                   NVL(msik.DEFAULT_GRADE,''),
                   NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                   NVL(msik.EXPIRATION_ACTION_CODE,''),
                   NVL(msik.HOLD_DAYS,0),
                   NVL(msik.MATURITY_DAYS,0),
                   NVL(msik.RETEST_INTERVAL,0),
                   NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                   NVL(msik.CHILD_LOT_FLAG,'N'),
                   NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                   NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                   NVL(msik.SECONDARY_UOM_CODE,''),
                   NVL(msik.SECONDARY_DEFAULT_IND,''),
                   NVL(msik.TRACKING_QUANTITY_IND,'P'),
                   NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                   NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                FROM mtl_system_items_vl msik, mtl_lot_numbers mln /* Bug 5581528 */
               WHERE msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
                 AND msik.organization_id = mln.organization_id
                 AND msik.inventory_item_id = mln.inventory_item_id
                 AND mln.lot_number = p_lot_number
                 AND mln.organization_id = p_organization_id

	    --Changes for GTIN

	    UNION

	                SELECT   msik.concatenated_segments concatenated_segments
                   , msik.inventory_item_id
                   , msik.description
                   , NVL(msik.revision_qty_control_code, 1)
                   , NVL(msik.lot_control_code, 1)
                   , NVL(msik.serial_number_control_code, 1)
                   , NVL(msik.restrict_subinventories_code, 2)
                   , NVL(msik.restrict_locators_code, 2)
                   , NVL(msik.location_control_code, 1)
                   , msik.primary_uom_code
                   , NVL(msik.inspection_required_flag, 2)
                   , NVL(msik.shelf_life_code, 1)
                   , NVL(msik.shelf_life_days, 0)
                   , NVL(msik.allowed_units_lookup_code, 2)
                   , NVL(msik.effectivity_control, 1)
                   , 0 parentlpnid
                   , 0 quantity
                   , NVL(msik.default_serial_status_id, 0)
                   , NVL(msik.serial_status_enabled, 'N')
                   , NVL(msik.default_lot_status_id, 0)
                   , NVL(msik.lot_status_enabled, 'N')
                   , mcr.cross_reference
                   , 'N'
                   , msik.inventory_item_flag
                   , 0
			 , null,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                   NVL(msik.GRADE_CONTROL_FLAG,'N'),
                   NVL(msik.DEFAULT_GRADE,''),
                   NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                   NVL(msik.EXPIRATION_ACTION_CODE,''),
                   NVL(msik.HOLD_DAYS,0),
                   NVL(msik.MATURITY_DAYS,0),
                   NVL(msik.RETEST_INTERVAL,0),
                   NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                   NVL(msik.CHILD_LOT_FLAG,'N'),
                   NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                   NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                   NVL(msik.SECONDARY_UOM_CODE,''),
                   NVL(msik.SECONDARY_DEFAULT_IND,''),
                   NVL(msik.TRACKING_QUANTITY_IND,'P'),
                   NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                   NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	    FROM mtl_system_items_vl msik, /* Bug 5581528 */
	    mtl_lot_numbers mln,
	    mtl_cross_references mcr
	    WHERE msik.organization_id = mln.organization_id
	    AND msik.inventory_item_id = mln.inventory_item_id
	    AND mln.lot_number = p_lot_number
	    AND mln.organization_id = p_organization_id
	    AND msik.inventory_item_id   = mcr.inventory_item_id
	    AND mcr.cross_reference_type = g_gtin_cross_ref_type
	    AND mcr.cross_reference      LIKE l_cross_ref
	    AND (mcr.organization_id     = msik.organization_id
		 OR
		 mcr.org_independent_flag = 'Y')
	    ORDER BY concatenated_segments;
        END IF;
      END IF;
    END IF;
  END get_lot_items_lov;

  PROCEDURE get_lot_item_details(
    x_revision_qty_control_code    OUT    NOCOPY NUMBER
  , x_serial_number_control_code   OUT    NOCOPY NUMBER
  , x_restrict_subinventories_code OUT    NOCOPY NUMBER
  , x_restrict_locators_code       OUT    NOCOPY NUMBER
  , x_location_control_code        OUT    NOCOPY NUMBER
  , x_primary_uom_code             OUT    NOCOPY VARCHAR2
  , x_shelf_life_code              OUT    NOCOPY NUMBER
  , x_shelf_life_days              OUT    NOCOPY NUMBER
  , x_allowed_units_lookup_code    OUT    NOCOPY NUMBER
  , x_lot_status_enabled           OUT    NOCOPY VARCHAR2
  , x_default_lot_status_id        OUT    NOCOPY NUMBER
  , x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_organization_id              IN     NUMBER
  , p_lot_number                   IN     VARCHAR2
  , p_transaction_type_id          IN     VARCHAR2
  , p_inventory_item_id            IN     NUMBER
  ) IS
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    x_msg_data       := '';

    IF p_transaction_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                                THEN
      SELECT NVL(msik.revision_qty_control_code, 1)
           , NVL(msik.serial_number_control_code, 1)
           , NVL(msik.restrict_subinventories_code, 2)
           , NVL(msik.restrict_locators_code, 2)
           , NVL(msik.location_control_code, 1)
           , msik.primary_uom_code
           , NVL(msik.shelf_life_code, 1)
           , NVL(msik.shelf_life_days, 0)
           , NVL(msik.allowed_units_lookup_code, 2)
           , NVL(msik.lot_status_enabled, 'N')
           , NVL(msik.default_lot_status_id, 0)
        INTO x_revision_qty_control_code
           , x_serial_number_control_code
           , x_restrict_subinventories_code
           , x_restrict_locators_code
           , x_location_control_code
           , x_primary_uom_code
           , x_shelf_life_code
           , x_shelf_life_days
           , x_allowed_units_lookup_code
           , x_lot_status_enabled
           , x_default_lot_status_id
        FROM mtl_system_items_vl msik /* Bug 5581528 */
       WHERE msik.lot_split_enabled = 'Y'
         AND msik.organization_id = p_organization_id
         AND msik.inventory_item_id = p_inventory_item_id;
    ELSE
      IF p_transaction_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                                  THEN
        SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2)
             , NVL(msik.lot_status_enabled, 'N') -- nsinghi bug#5475282
             , NVL(msik.default_lot_status_id, 0) -- nsinghi bug#5475282
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
             , x_lot_status_enabled -- nsinghi bug#5475282
             , x_default_lot_status_id -- nsinghi bug#5475282
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.lot_merge_enabled = 'Y'
           AND msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id;
      ELSIF p_transaction_type_id = inv_globals.g_type_inv_lot_translate -- Lot Translate 84 Added bug4096035
                                                                    THEN
          SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2)
             , NVL(msik.lot_status_enabled, 'N')
             , NVL(msik.default_lot_status_id, 0)
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
             , x_lot_status_enabled
             , x_default_lot_status_id
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.lot_translate_enabled = 'Y'
           AND msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id; /*Added bug4096035*/
      ELSE
        SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2)
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'INV_NO_ITEM');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END get_lot_item_details;

  /* Overridden method to retreiveDUOM attributes for Convergence */

  PROCEDURE get_lot_item_details(
    x_revision_qty_control_code    OUT    NOCOPY NUMBER
  , x_serial_number_control_code   OUT    NOCOPY NUMBER
  , x_restrict_subinventories_code OUT    NOCOPY NUMBER
  , x_restrict_locators_code       OUT    NOCOPY NUMBER
  , x_location_control_code        OUT    NOCOPY NUMBER
  , x_primary_uom_code             OUT    NOCOPY VARCHAR2
  , x_shelf_life_code              OUT    NOCOPY NUMBER
  , x_shelf_life_days              OUT    NOCOPY NUMBER
  , x_allowed_units_lookup_code    OUT    NOCOPY NUMBER
  , x_lot_status_enabled           OUT    NOCOPY VARCHAR2
  , x_default_lot_status_id        OUT    NOCOPY NUMBER
  , x_GRADE_CONTROL_FLAG OUT    NOCOPY VARCHAR2
  , x_DEFAULT_GRADE OUT    NOCOPY VARCHAR2
  , x_EXPIRATION_ACTION_INTERVAL OUT    NOCOPY NUMBER
  , x_EXPIRATION_ACTION_CODE OUT    NOCOPY VARCHAR2
  , x_HOLD_DAYS OUT    NOCOPY NUMBER
  , x_MATURITY_DAYS OUT    NOCOPY NUMBER
  , x_RETEST_INTERVAL OUT    NOCOPY NUMBER
  , x_COPY_LOT_ATTRIBUTE_FLAG OUT    NOCOPY VARCHAR2
  , x_CHILD_LOT_FLAG OUT    NOCOPY VARCHAR2
  , x_CHILD_LOT_VALIDATION_FLAG OUT    NOCOPY VARCHAR2
  , x_LOT_DIVISIBLE_FLAG OUT    NOCOPY VARCHAR2
  , x_SECONDARY_UOM_CODE OUT    NOCOPY VARCHAR2
  , x_SECONDARY_DEFAULT_IND OUT    NOCOPY VARCHAR2
  , x_TRACKING_QUANTITY_IND OUT    NOCOPY VARCHAR2
  , x_DUAL_UOM_DEVIATION_HIGH OUT    NOCOPY NUMBER
  , x_DUAL_UOM_DEVIATION_LOW OUT    NOCOPY NUMBER
  , x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_organization_id              IN     NUMBER
  , p_lot_number                   IN     VARCHAR2
  , p_transaction_type_id          IN     VARCHAR2
  , p_inventory_item_id            IN     NUMBER
  ) IS
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    x_msg_data       := '';

    IF p_transaction_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                                THEN
      SELECT NVL(msik.revision_qty_control_code, 1)
           , NVL(msik.serial_number_control_code, 1)
           , NVL(msik.restrict_subinventories_code, 2)
           , NVL(msik.restrict_locators_code, 2)
           , NVL(msik.location_control_code, 1)
           , msik.primary_uom_code
           , NVL(msik.shelf_life_code, 1)
           , NVL(msik.shelf_life_days, 0)
           , NVL(msik.allowed_units_lookup_code, 2)
           , NVL(msik.lot_status_enabled, 'N')
           , NVL(msik.default_lot_status_id, 0),
     --Bug No 3952081
     --Additional Fields for Process Convergence
           NVL(msik.GRADE_CONTROL_FLAG,'N'),
           NVL(msik.DEFAULT_GRADE,''),
           NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
           NVL(msik.EXPIRATION_ACTION_CODE,''),
           NVL(msik.HOLD_DAYS,0),
           NVL(msik.MATURITY_DAYS,0),
           NVL(msik.RETEST_INTERVAL,0),
           NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
           NVL(msik.CHILD_LOT_FLAG,'N'),
           NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
           NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
           NVL(msik.SECONDARY_UOM_CODE,''),
           NVL(msik.SECONDARY_DEFAULT_IND,''),
           NVL(msik.TRACKING_QUANTITY_IND,'P'),
           NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
           NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
        INTO x_revision_qty_control_code
           , x_serial_number_control_code
           , x_restrict_subinventories_code
           , x_restrict_locators_code
           , x_location_control_code
           , x_primary_uom_code
           , x_shelf_life_code
           , x_shelf_life_days
           , x_allowed_units_lookup_code
           , x_lot_status_enabled
           , x_default_lot_status_id
           , x_GRADE_CONTROL_FLAG
           , x_DEFAULT_GRADE
           , x_EXPIRATION_ACTION_INTERVAL
           , x_EXPIRATION_ACTION_CODE
           , x_HOLD_DAYS
           , x_MATURITY_DAYS
           , x_RETEST_INTERVAL
           , x_COPY_LOT_ATTRIBUTE_FLAG
           , x_CHILD_LOT_FLAG
           , x_CHILD_LOT_VALIDATION_FLAG
           , x_LOT_DIVISIBLE_FLAG
           , x_SECONDARY_UOM_CODE
           , x_SECONDARY_DEFAULT_IND
           , x_TRACKING_QUANTITY_IND
           , x_DUAL_UOM_DEVIATION_HIGH
           , x_DUAL_UOM_DEVIATION_LOW
        FROM mtl_system_items_vl msik /* Bug 5581528 */
       WHERE msik.lot_split_enabled = 'Y'
         AND msik.organization_id = p_organization_id
         AND msik.inventory_item_id = p_inventory_item_id;
    ELSE
      IF p_transaction_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                                  THEN
        SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2)
             , NVL(msik.lot_status_enabled, 'N') -- nsinghi bug#5475282
             , NVL(msik.default_lot_status_id, 0), -- nsinghi bug#5475282
     --Bug No 3952081
     --Additional Fields for Process Convergence
           NVL(msik.GRADE_CONTROL_FLAG,'N'),
           NVL(msik.DEFAULT_GRADE,''),
           NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
           NVL(msik.EXPIRATION_ACTION_CODE,''),
           NVL(msik.HOLD_DAYS,0),
           NVL(msik.MATURITY_DAYS,0),
           NVL(msik.RETEST_INTERVAL,0),
           NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
           NVL(msik.CHILD_LOT_FLAG,'N'),
           NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
           NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
           NVL(msik.SECONDARY_UOM_CODE,''),
           NVL(msik.SECONDARY_DEFAULT_IND,''),
           NVL(msik.TRACKING_QUANTITY_IND,'P'),
           NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
           NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
             , x_lot_status_enabled -- nsinghi bug#5475282
             , x_default_lot_status_id -- nsinghi bug#5475282
           , x_GRADE_CONTROL_FLAG
           , x_DEFAULT_GRADE
           , x_EXPIRATION_ACTION_INTERVAL
           , x_EXPIRATION_ACTION_CODE
           , x_HOLD_DAYS
           , x_MATURITY_DAYS
           , x_RETEST_INTERVAL
           , x_COPY_LOT_ATTRIBUTE_FLAG
           , x_CHILD_LOT_FLAG
           , x_CHILD_LOT_VALIDATION_FLAG
           , x_LOT_DIVISIBLE_FLAG
           , x_SECONDARY_UOM_CODE
           , x_SECONDARY_DEFAULT_IND
           , x_TRACKING_QUANTITY_IND
           , x_DUAL_UOM_DEVIATION_HIGH
           , x_DUAL_UOM_DEVIATION_LOW
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.lot_merge_enabled = 'Y'
           AND msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id;
      ELSIF p_transaction_type_id = inv_globals.g_type_inv_lot_translate -- Lot Translate 84 Added bug4096035
                                                                    THEN
          SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2)
             , NVL(msik.lot_status_enabled, 'N')
             , NVL(msik.default_lot_status_id, 0),
             --Additional Fields for Process Convergence
              NVL(msik.GRADE_CONTROL_FLAG,'N'),
              NVL(msik.DEFAULT_GRADE,''),
              NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
              NVL(msik.EXPIRATION_ACTION_CODE,''),
              NVL(msik.HOLD_DAYS,0),
              NVL(msik.MATURITY_DAYS,0),
              NVL(msik.RETEST_INTERVAL,0),
              NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
              NVL(msik.CHILD_LOT_FLAG,'N'),
              NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
              NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
              NVL(msik.SECONDARY_UOM_CODE,''),
              NVL(msik.SECONDARY_DEFAULT_IND,''),
              NVL(msik.TRACKING_QUANTITY_IND,'P'),
              NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
              NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
             , x_lot_status_enabled
             , x_default_lot_status_id
             , x_GRADE_CONTROL_FLAG
             , x_DEFAULT_GRADE
             , x_EXPIRATION_ACTION_INTERVAL
             , x_EXPIRATION_ACTION_CODE
             , x_HOLD_DAYS
             , x_MATURITY_DAYS
             , x_RETEST_INTERVAL
             , x_COPY_LOT_ATTRIBUTE_FLAG
             , x_CHILD_LOT_FLAG
             , x_CHILD_LOT_VALIDATION_FLAG
             , x_LOT_DIVISIBLE_FLAG
             , x_SECONDARY_UOM_CODE
             , x_SECONDARY_DEFAULT_IND
             , x_TRACKING_QUANTITY_IND
             , x_DUAL_UOM_DEVIATION_HIGH
             , x_DUAL_UOM_DEVIATION_LOW
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.lot_translate_enabled = 'Y'
           AND msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id; /*Added bug4096035*/


      ELSE
        SELECT NVL(msik.revision_qty_control_code, 1)
             , NVL(msik.serial_number_control_code, 1)
             , NVL(msik.restrict_subinventories_code, 2)
             , NVL(msik.restrict_locators_code, 2)
             , NVL(msik.location_control_code, 1)
             , msik.primary_uom_code
             , NVL(msik.shelf_life_code, 1)
             , NVL(msik.shelf_life_days, 0)
             , NVL(msik.allowed_units_lookup_code, 2),
     --Bug No 3952081
     --Additional Fields for Process Convergence
           NVL(msik.GRADE_CONTROL_FLAG,'N'),
           NVL(msik.DEFAULT_GRADE,''),
           NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
           NVL(msik.EXPIRATION_ACTION_CODE,''),
           NVL(msik.HOLD_DAYS,0),
           NVL(msik.MATURITY_DAYS,0),
           NVL(msik.RETEST_INTERVAL,0),
           NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
           NVL(msik.CHILD_LOT_FLAG,'N'),
           NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
           NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
           NVL(msik.SECONDARY_UOM_CODE,''),
           NVL(msik.SECONDARY_DEFAULT_IND,''),
           NVL(msik.TRACKING_QUANTITY_IND,'P'),
           NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
           NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
          INTO x_revision_qty_control_code
             , x_serial_number_control_code
             , x_restrict_subinventories_code
             , x_restrict_locators_code
             , x_location_control_code
             , x_primary_uom_code
             , x_shelf_life_code
             , x_shelf_life_days
             , x_allowed_units_lookup_code
           , x_GRADE_CONTROL_FLAG
           , x_DEFAULT_GRADE
           , x_EXPIRATION_ACTION_INTERVAL
           , x_EXPIRATION_ACTION_CODE
           , x_HOLD_DAYS
           , x_MATURITY_DAYS
           , x_RETEST_INTERVAL
           , x_COPY_LOT_ATTRIBUTE_FLAG
           , x_CHILD_LOT_FLAG
           , x_CHILD_LOT_VALIDATION_FLAG
           , x_LOT_DIVISIBLE_FLAG
           , x_SECONDARY_UOM_CODE
           , x_SECONDARY_DEFAULT_IND
           , x_TRACKING_QUANTITY_IND
           , x_DUAL_UOM_DEVIATION_HIGH
           , x_DUAL_UOM_DEVIATION_LOW
          FROM mtl_system_items_vl msik /* Bug 5581528 */
         WHERE msik.organization_id = p_organization_id
           AND msik.inventory_item_id = p_inventory_item_id;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'INV_NO_ITEM');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
END get_lot_item_details;

-- Bug 5498323 - Procedure accepts two more parameters - Subinventory code and Locator Id
-- If Subinventory code IS not NULL, then the Item list returned is filtered by this Subinventory
-- If Subinventory is not NULL and Locator Id is not NULL and Locator Id <> -1, then the Item list returned is filtered by this Subinventory and Locator Id

PROCEDURE get_status_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN NUMBER) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  l_sql_stmt1     VARCHAR2(7500)
  := 'SELECT msik.concatenated_segments concatenated_segments'
      ||            ', msik.inventory_item_id'
      ||            ', msik.description'
      ||            ', NVL(msik.revision_qty_control_code, 1)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.restrict_subinventories_code, 2)'
      ||            ', NVL(msik.restrict_locators_code, 2)'
      ||            ', NVL(msik.location_control_code, 1)'
      ||            ', msik.primary_uom_code'
      ||            ', NVL(msik.inspection_required_flag, 2)'
      ||            ', NVL(msik.shelf_life_code, 1)'
      ||            ', NVL(msik.shelf_life_days, 0)'
      ||            ', NVL(msik.allowed_units_lookup_code, 2)'
      ||            ', NVL(msik.effectivity_control, 1)'
      ||            ', 0 parentlpnid'
      ||            ', 0 quantity'
      ||            ', NVL(msik.default_serial_status_id, 0)'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.default_lot_status_id, 0)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', '''''
      ||            ', ''N'''
      ||            ', msik.inventory_item_flag'
      ||            ', 0'
      ||            ', wms_deploy.get_item_client_name(msik.inventory_item_id),'
--Bug No 3952081
--Additional Fields for Process Convergence
      ||            'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
      ||            'NVL(msik.DEFAULT_GRADE,''''),'
      ||            'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
      ||            'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
      ||            'NVL(msik.HOLD_DAYS,0),'
      ||            'NVL(msik.MATURITY_DAYS,0),'
      ||            'NVL(msik.RETEST_INTERVAL,0),'
      ||            'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
      ||            'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
      ||            'NVL(msik.SECONDARY_UOM_CODE,''''),'
      ||            'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
      ||            'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';

l_sql_stmt_xref     VARCHAR2(7500)
      :=       'SELECT msik.concatenated_segments concatenated_segments'
      ||            ', msik.inventory_item_id'
      ||            ', msik.description'
      ||            ', NVL(msik.revision_qty_control_code, 1)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.restrict_subinventories_code, 2)'
      ||            ', NVL(msik.restrict_locators_code, 2)'
      ||            ', NVL(msik.location_control_code, 1)'
      ||            ', msik.primary_uom_code'
      ||            ', NVL(msik.inspection_required_flag, 2)'
      ||            ', NVL(msik.shelf_life_code, 1)'
      ||            ', NVL(msik.shelf_life_days, 0)'
      ||            ', NVL(msik.allowed_units_lookup_code, 2)'
      ||            ', NVL(msik.effectivity_control, 1)'
      ||            ', 0 parentlpnid'
      ||            ', 0 quantity'
      ||            ', NVL(msik.default_serial_status_id, 0)'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.default_lot_status_id, 0)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', mcr.cross_reference'
      ||            ', ''N'''
      ||            ', msik.inventory_item_flag'
      ||            ', 0'
      ||            ', wms_deploy.get_item_client_name(msik.inventory_item_id),'
     --Bug No 3952081
     --Additional Fields for Process Convergence
      ||            'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
      ||            'NVL(msik.DEFAULT_GRADE,''''),'
      ||            'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
      ||            'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
      ||            'NVL(msik.HOLD_DAYS,0),'
      ||            'NVL(msik.MATURITY_DAYS,0),'
      ||            'NVL(msik.RETEST_INTERVAL,0),'
      ||            'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
      ||            'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
      ||            'NVL(msik.SECONDARY_UOM_CODE,''''),'
      ||            'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
      ||            'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

   l_sql_stmt1 := l_sql_stmt1 || ' FROM mtl_system_items_vl msik, mtl_onhand_quantities_detail moqd'
                              || ' WHERE msik.concatenated_segments LIKE (''' || p_concatenated_segments ||l_append|| ''')'
         		      || ' AND msik.organization_id = ' || p_organization_id
			      || ' AND (msik.lot_status_enabled = ''Y'' OR msik.serial_status_enabled = ''Y'')';

   l_sql_stmt_xref := l_sql_stmt_xref || ' FROM mtl_system_items_vl msik,'
				|| 'mtl_cross_references mcr, mtl_onhand_quantities_detail moqd'
				|| ' WHERE msik.organization_id = ' || p_organization_id
				|| ' AND (msik.lot_status_enabled = ''Y'' OR msik.serial_status_enabled = ''Y'' )'
				|| ' AND msik.inventory_item_id   = mcr.inventory_item_id'
				|| ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type || ''''
				|| ' AND mcr.cross_reference LIKE ''' || l_cross_ref || ''''
				|| ' AND (mcr.organization_id = msik.organization_id OR mcr.org_independent_flag = ''Y'')';


   IF p_subinventory_code IS NOT NULL THEN
        l_sql_stmt1 := l_sql_stmt1 || ' AND moqd.organization_id = msik.organization_id'
				   || ' AND moqd.inventory_item_id = msik.inventory_item_id'
				   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

        l_sql_stmt_xref := l_sql_stmt_xref || ' AND moqd.organization_id = msik.organization_id'
				   || ' AND moqd.inventory_item_id = msik.inventory_item_id'
				   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

	IF p_locator_id IS NOT NULL AND p_locator_id <> -1 THEN

		l_sql_stmt1 := l_sql_stmt1 || ' AND moqd.locator_id = ' || p_locator_id;

		l_sql_stmt_xref := l_sql_stmt_xref || ' AND moqd.locator_id = ' || p_locator_id;
	END IF;
   END IF;

   l_sql_stmt1 := l_sql_stmt1 || ' UNION ' || l_sql_stmt_xref || ' ORDER BY concatenated_segments';

   --dbms_output.put_line(l_sql_stmt1);
   OPEN x_items FOR l_sql_stmt1;

END get_status_items_lov;

  PROCEDURE get_ship_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_delivery_id IN NUMBER, p_concatenated_segments IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    OPEN x_items FOR
      SELECT DISTINCT msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msik, wsh_delivery_details dd, wsh_delivery_assignments da, wsh_new_deliveries nd /* Bug 5581528 */
      WHERE msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
      AND msik.organization_id = p_organization_id
      AND msik.inventory_item_id = dd.inventory_item_id
      AND nd.delivery_id = p_delivery_id
      AND nd.delivery_id = da.delivery_id
      AND da.delivery_detail_id = dd.delivery_detail_id
      AND (dd.inv_interfaced_flag = 'N' OR dd.inv_interfaced_flag IS NULL)
      AND dd.released_status = 'Y'
      AND nd.status_code NOT IN ('CO', 'CL', 'IT')

	--Changes for GTIN
	UNION

	      SELECT DISTINCT msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , mcr.cross_reference
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl msik, /* Bug 5581528 */
	wsh_delivery_details dd,
	wsh_delivery_assignments da,
	wsh_new_deliveries nd,
	mtl_cross_references mcr
	WHERE msik.organization_id = p_organization_id
	AND msik.inventory_item_id = dd.inventory_item_id
	AND nd.delivery_id = p_delivery_id
	AND nd.delivery_id = da.delivery_id
	AND da.delivery_detail_id = dd.delivery_detail_id
	AND (dd.inv_interfaced_flag = 'N' OR dd.inv_interfaced_flag IS NULL)
	  AND dd.released_status = 'Y'
	  AND nd.status_code NOT IN ('CO', 'CL', 'IT')
	  AND msik.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = msik.organization_id
	       OR
	       mcr.org_independent_flag = 'Y')
	  ORDER BY concatenated_segments;
  END get_ship_items_lov;

  --      Name: GET_PHYINV_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - User inputted value
  --        p_organization_id     -  Organization ID
  --        p_subinventory_code   -  Subinventory
  --        p_locator_id          -  Locator ID
  --        p_dynamic_entry_flag  -  Indicates if dynamic entries are allowed
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid items that are associated
  --                 with the given physical inventory
  --

  PROCEDURE get_phyinv_item_lov(
    x_items                 OUT    NOCOPY t_genref
  , p_concatenated_segments IN     VARCHAR2
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      OPEN x_items FOR
        SELECT   concatenated_segments
               , inventory_item_id
               , description
               , NVL(revision_qty_control_code, 1)
               , NVL(lot_control_code, 1)
               , NVL(serial_number_control_code, 1)
               , NVL(restrict_subinventories_code, 2)
               , NVL(restrict_locators_code, 2)
               , NVL(location_control_code, 1)
               , primary_uom_code
               , NVL(inspection_required_flag, 2)
               , NVL(shelf_life_code, 1)
               , NVL(shelf_life_days, 0)
               , NVL(allowed_units_lookup_code, 2)
               , NVL(effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(default_serial_status_id, 0)
               , NVL(serial_status_enabled, 'N')
               , NVL(default_lot_status_id, 0)
               , NVL(lot_status_enabled, 'N')
               , ''
               , 'N'
               , inventory_item_flag
               , 0
		   , wms_deploy.get_item_client_name(inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(GRADE_CONTROL_FLAG,'N'),
               NVL(DEFAULT_GRADE,''),
               NVL(EXPIRATION_ACTION_INTERVAL,0),
               NVL(EXPIRATION_ACTION_CODE,''),
               NVL(HOLD_DAYS,0),
               NVL(MATURITY_DAYS,0),
               NVL(RETEST_INTERVAL,0),
               NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(CHILD_LOT_FLAG,'N'),
               NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(LOT_DIVISIBLE_FLAG,'Y'),
               NVL(SECONDARY_UOM_CODE,''),
               NVL(SECONDARY_DEFAULT_IND,''),
               NVL(TRACKING_QUANTITY_IND,'P'),
               NVL(DUAL_UOM_DEVIATION_HIGH,0),
               NVL(DUAL_UOM_DEVIATION_LOW,0)
            --FROM mtl_system_items_vl /* Bug 5581528 */
            from mtl_system_items_vl msik /*bug7626228*/
           WHERE organization_id = p_organization_id
	AND concatenated_segments LIKE (p_concatenated_segments||l_append)
   /*AND INV_MATERIAL_STATUS_GRP.loc_valid_for_item(p_locator_id,
                                                  p_organization_id,
                                                  inventory_item_id,
                                                  p_subinventory_code)='Y' --Bug# 2879164
    AND INV_MATERIAL_STATUS_GRP.sub_valid_for_item (p_organization_id,
                                                    inventory_item_id,
                                                    p_subinventory_code)='Y' -- Bug 5500255*/
    AND INV_MATERIAL_STATUS_GRP.sub_loc_valid_for_item(p_organization_id,msik.inventory_item_id,p_subinventory_code,p_locator_id,
           msik.restrict_subinventories_code,msik.restrict_locators_code)='Y' -- bug7626228
    AND msik.stock_enabled_flag = 'Y'                             -- Added for Bug 6310345

--Changes for GTIN
	UNION

	SELECT   concatenated_segments
               , msik.inventory_item_id
               , msik.description
               , NVL(revision_qty_control_code, 1)
               , NVL(lot_control_code, 1)
               , NVL(serial_number_control_code, 1)
               , NVL(restrict_subinventories_code, 2)
               , NVL(restrict_locators_code, 2)
               , NVL(location_control_code, 1)
               , primary_uom_code
               , NVL(inspection_required_flag, 2)
               , NVL(shelf_life_code, 1)
               , NVL(shelf_life_days, 0)
               , NVL(allowed_units_lookup_code, 2)
               , NVL(effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(default_serial_status_id, 0)
               , NVL(serial_status_enabled, 'N')
               , NVL(default_lot_status_id, 0)
               , NVL(lot_status_enabled, 'N')
               , mcr.cross_reference
               , 'N'
               , inventory_item_flag
               , 0
		   , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(GRADE_CONTROL_FLAG,'N'),
               NVL(DEFAULT_GRADE,''),
               NVL(EXPIRATION_ACTION_INTERVAL,0),
               NVL(EXPIRATION_ACTION_CODE,''),
               NVL(HOLD_DAYS,0),
               NVL(MATURITY_DAYS,0),
               NVL(RETEST_INTERVAL,0),
               NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(CHILD_LOT_FLAG,'N'),
               NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(LOT_DIVISIBLE_FLAG,'Y'),
               NVL(SECONDARY_UOM_CODE,''),
               NVL(SECONDARY_DEFAULT_IND,''),
               NVL(TRACKING_QUANTITY_IND,'P'),
               NVL(DUAL_UOM_DEVIATION_HIGH,0),
               NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl msik, mtl_cross_references mcr /* Bug 5581528 */
	WHERE msik.organization_id = p_organization_id
	AND msik.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msik.organization_id
	     OR
	     mcr.org_independent_flag = 'Y')
       AND msik.stock_enabled_flag = 'Y'                             -- Added for Bug 6310345
        ORDER BY concatenated_segments;

    ELSE -- Dynamic entries are not allowed
      OPEN x_items FOR
        SELECT UNIQUE msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
		        , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msik, mtl_physical_inventory_tags mpit /* Bug 5581528 */
                WHERE msik.organization_id = p_organization_id
                  AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
                  AND msik.inventory_item_id = mpit.inventory_item_id
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.organization_id = p_organization_id
                  AND mpit.subinventory = p_subinventory_code
                  AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
                                               FROM mtl_physical_adjustments
                                              WHERE physical_inventory_id = p_physical_inventory_id
                                                AND organization_id = p_organization_id
                                                AND approval_status IS NULL)
                  /*AND INV_MATERIAL_STATUS_GRP.loc_valid_for_item(p_locator_id,
                                                                 p_organization_id,
                                                                 msik.inventory_item_id,
                                                                 p_subinventory_code)='Y' --Bug# 2879164
						AND INV_MATERIAL_STATUS_GRP.sub_valid_for_item(p_organization_id,
                                                                 msik.inventory_item_id,
                                                                 p_subinventory_code)='Y' -- Bug 5500255*/
                  AND INV_MATERIAL_STATUS_GRP.sub_loc_valid_for_item(p_organization_id,msik.inventory_item_id,p_subinventory_code,p_locator_id,
                                                                     msik.restrict_subinventories_code,msik.restrict_locators_code)='Y' -- bug7626228
                 AND msik.stock_enabled_flag = 'Y'                             -- Added for Bug 6310345

                  --Changes for GTIN
		  UNION
		        SELECT UNIQUE msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , mcr.cross_reference
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
   		        , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msik, mtl_physical_inventory_tags mpit, mtl_cross_references mcr /* Bug 5581528 */
                WHERE msik.organization_id = p_organization_id
                  AND msik.inventory_item_id = mpit.inventory_item_id
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.organization_id = p_organization_id
                  AND mpit.subinventory = p_subinventory_code
                  AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
                                               FROM mtl_physical_adjustments
                                              WHERE physical_inventory_id = p_physical_inventory_id
                                                AND organization_id = p_organization_id
                                                AND approval_status IS NULL)
		AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id
	   OR
	   mcr.org_independent_flag = 'Y')
      AND msik.stock_enabled_flag = 'Y'                             -- Added for Bug 6310345
	ORDER BY concatenated_segments;
    END IF;
  END get_phyinv_item_lov;

  --      Name: GET_PHYINV_REV_LOV
  --
  --      Input parameters:
  --       p_organization_id    - restricts LOV SQL to current org
  --       p_inventory_item_id  - restrict LOV for a given item
  --       p_revision           - restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --       p_dynamic_entry_flag - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - restricts LOV SQL to current physical inventory
  --
  --      Output parameters:
  --       x_revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text for a given physical inventory
  --

  PROCEDURE get_phyinv_rev_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_dynamic_entry_flag IN NUMBER, p_physical_inventory_id IN NUMBER, p_parent_lpn_id IN NUMBER) IS
  BEGIN
    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      OPEN x_revs FOR
        SELECT   revision
               , effectivity_date
               , NVL(description, '')
            FROM mtl_item_revisions
           WHERE organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND revision LIKE (p_revision)
        ORDER BY UPPER(revision);
    ELSE -- Dynamic entries are not allowed
      OPEN x_revs FOR
        SELECT UNIQUE mir.revision
                    , mir.effectivity_date
                    , NVL(mir.description, '')
                 FROM mtl_item_revisions mir, mtl_physical_inventory_tags mpit
                WHERE mir.organization_id = p_organization_id
                  AND mir.inventory_item_id = p_inventory_item_id
                  AND mir.revision LIKE (p_revision)
                  AND mir.inventory_item_id = mpit.inventory_item_id
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
                                               FROM mtl_physical_adjustments
                                              WHERE physical_inventory_id = p_physical_inventory_id
                                                AND organization_id = p_organization_id
                                                AND approval_status IS NULL)
             ORDER BY UPPER(mir.revision);
    END IF;
  END get_phyinv_rev_lov;

  --      Name: GET_PHYINV_UOM_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV for a given item
  --       p_uom_code              - Restricts LOV SQL to the user input text
  --                                   e.g.  Ea%
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --
  --      Output parameters:
  --       x_uoms      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user inputted text for valid UOM's for a particular
  --                 physical inventory
  --

  PROCEDURE get_phyinv_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_uom_code IN VARCHAR2) IS
     l_code VARCHAR2(20):=p_UOM_Code;
  BEGIN
    IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_UOM_Code,1,INSTR(p_UOM_Code,'(')-1);
    END IF;

    OPEN x_uoms FOR
      SELECT (inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) uom_code_comp
             , unit_of_measure
             , description
             , uom_class
          FROM mtl_item_uoms_view
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND uom_code LIKE (l_code)
      ORDER BY inv_ui_item_lovs.conversion_order(inv_ui_item_lovs.get_conversion_rate(uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) asc, Upper(uom_code);
  END get_phyinv_uom_lov;

  --      Name: GET_CONTAINER_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - Restricts output to user inputted value
  --        p_organization_id     -  Organization ID
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid container items
  --                 within the given org
  --

  PROCEDURE get_container_item_lov(x_items OUT NOCOPY t_genref, p_concatenated_segments IN VARCHAR2, p_organization_id IN NUMBER) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);
    OPEN x_items FOR
      SELECT DISTINCT concatenated_segments
                    , inventory_item_id
                    , description
                    , NVL(revision_qty_control_code, 1)
                    , NVL(lot_control_code, 1)
                    , NVL(serial_number_control_code, 1)
                    , NVL(restrict_subinventories_code, 2)
                    , NVL(restrict_locators_code, 2)
                    , NVL(location_control_code, 1)
                    , primary_uom_code
                    , NVL(inspection_required_flag, 2)
                    , NVL(shelf_life_code, 1)
                    , NVL(shelf_life_days, 0)
                    , NVL(allowed_units_lookup_code, 2)
                    , NVL(effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(default_serial_status_id, 0)
                    , NVL(serial_status_enabled, 'N')
                    , NVL(default_lot_status_id, 0)
                    , NVL(lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(inventory_item_id),
		    inventory_asset_flag, --5591433: Added inventory_asset_flag and outside_processing_flag.
                    outside_operation_flag,
                    --Bug No 3952081
                    --Additional Fields for Process Convergence
                    NVL(GRADE_CONTROL_FLAG,'N'),
                    NVL(DEFAULT_GRADE,''),
                    NVL(EXPIRATION_ACTION_INTERVAL,0),
                    NVL(EXPIRATION_ACTION_CODE,''),
                    NVL(HOLD_DAYS,0),
                    NVL(MATURITY_DAYS,0),
                    NVL(RETEST_INTERVAL,0),
                    NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(CHILD_LOT_FLAG,'N'),
                    NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(SECONDARY_UOM_CODE,''),
                    NVL(SECONDARY_DEFAULT_IND,''),
                    NVL(TRACKING_QUANTITY_IND,'P'),
                    NVL(DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl /* Bug 5581528 */
                WHERE organization_id = p_organization_id
                  AND container_item_flag = 'Y'
                  AND mtl_transactions_enabled_flag = 'Y'
      AND concatenated_segments LIKE (p_concatenated_segments||l_append)

      --Changes for GTIN

      UNION

           SELECT DISTINCT concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(revision_qty_control_code, 1)
                    , NVL(lot_control_code, 1)
                    , NVL(serial_number_control_code, 1)
                    , NVL(restrict_subinventories_code, 2)
                    , NVL(restrict_locators_code, 2)
                    , NVL(location_control_code, 1)
                    , primary_uom_code
                    , NVL(inspection_required_flag, 2)
                    , NVL(shelf_life_code, 1)
                    , NVL(shelf_life_days, 0)
                    , NVL(allowed_units_lookup_code, 2)
                    , NVL(effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(default_serial_status_id, 0)
                    , NVL(serial_status_enabled, 'N')
                    , NVL(default_lot_status_id, 0)
                    , NVL(lot_status_enabled, 'N')
                    , mcr.cross_reference
                    , 'N'
                    , inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msik.inventory_item_id),
		    inventory_asset_flag, --5591433: Added inventory_asset_flag and outside_processing_flag.
                    outside_operation_flag,
                    --Bug No 3952081
                    --Additional Fields for Process Convergence
                    NVL(GRADE_CONTROL_FLAG,'N'),
                    NVL(DEFAULT_GRADE,''),
                    NVL(EXPIRATION_ACTION_INTERVAL,0),
                    NVL(EXPIRATION_ACTION_CODE,''),
                    NVL(HOLD_DAYS,0),
                    NVL(MATURITY_DAYS,0),
                    NVL(RETEST_INTERVAL,0),
                    NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(CHILD_LOT_FLAG,'N'),
                    NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(SECONDARY_UOM_CODE,''),
                    NVL(SECONDARY_DEFAULT_IND,''),
                    NVL(TRACKING_QUANTITY_IND,'P'),
                    NVL(DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msik, /* Bug 5581528 */
      mtl_cross_references mcr
      WHERE msik.organization_id = p_organization_id
      AND msik.container_item_flag = 'Y'
      AND msik.mtl_transactions_enabled_flag = 'Y'
      AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id
	   OR
	   mcr.org_independent_flag = 'Y')
      ORDER BY concatenated_segments;
  END get_container_item_lov;

  --      Name: GET_CYC_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - User inputted value
  --        p_organization_id       -  Organization ID
  --        p_subinventory_code     -  Subinventory
  --        p_locator_id            -  Locator ID
  --        p_unscheduled_entry     -  Indicates if unscheduled entries are allowed
  --        p_cycle_count_header_id -  Restricts output to the given cycle count
  --        p_parent_lpn_id         -  Restricts output to only items with the
  --                                   given parent lpn ID
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid items that are associated
  --                 with the given cycle count
  --

  PROCEDURE get_cyc_item_lov(
    x_items                 OUT    NOCOPY t_genref
  , p_concatenated_segments IN     VARCHAR2
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
    l_serial_count_option          NUMBER;
    l_serial_discrepancy_option    NUMBER;
    l_container_discrepancy_option NUMBER;
    l_cross_ref varchar2(204);
    l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    -- Get the cycle count discrepancy option flags
    SELECT NVL(serial_discrepancy_option, 2)
         , NVL(container_discrepancy_option, 2)
      INTO l_serial_discrepancy_option
         , l_container_discrepancy_option
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

    -- Get the serial count option for the cycle count header
    SELECT NVL(serial_count_option, 1)
      INTO l_serial_count_option
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id
       AND organization_id = p_organization_id;

    IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      OPEN x_items FOR
        SELECT   msik.concatenated_segments concatenated_segments
               , msik.inventory_item_id
               , msik.description
               , NVL(msik.revision_qty_control_code, 1)
               , NVL(msik.lot_control_code, 1)
               , NVL(msik.serial_number_control_code, 1)
               , NVL(msik.restrict_subinventories_code, 2)
               , NVL(msik.restrict_locators_code, 2)
               , NVL(msik.location_control_code, 1)
               , msik.primary_uom_code
               , NVL(msik.inspection_required_flag, 2)
               , NVL(msik.shelf_life_code, 1)
               , NVL(msik.shelf_life_days, 0)
               , NVL(msik.allowed_units_lookup_code, 2)
               , NVL(msik.effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(msik.default_serial_status_id, 0)
               , NVL(msik.serial_status_enabled, 'N')
               , NVL(msik.default_lot_status_id, 0)
               , NVL(msik.lot_status_enabled, 'N')
               , ''
               , 'N'
               , msik.inventory_item_flag
               , 0
	     	   , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
            FROM mtl_system_items_vl msik, /* Bug 5581528 */
	         mtl_cycle_count_items mcci
           WHERE msik.organization_id = p_organization_id
             AND msik.inventory_item_id = mcci.inventory_item_id
             AND mcci.cycle_count_header_id = p_cycle_count_header_id
             AND (msik.serial_number_control_code IN (1, 6)
                  OR (l_serial_count_option <> 1
                      AND serial_number_control_code NOT IN (1, 6)
                     )
                 )
	AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
	/*AND INV_MATERIAL_STATUS_GRP.loc_valid_for_item(p_locator_id,
                                                  p_organization_id,
                                                   msik.inventory_item_id,
                                                  p_subinventory_code)='Y' --Bug# 3188455 Added this for validating restricted Items to locator and subinventory
   AND INV_MATERIAL_STATUS_GRP.sub_valid_for_item(p_organization_id,
                                                  msik.inventory_item_id,
                                                  p_subinventory_code)='Y' -- Bug 5500255*/
   AND INV_MATERIAL_STATUS_GRP.sub_loc_valid_for_item(p_organization_id,msik.inventory_item_id,p_subinventory_code,p_locator_id,
                                                      msik.restrict_subinventories_code,msik.restrict_locators_code)='Y' -- Bug7626228
	--Changes for GTIN
	UNION

	SELECT   msik.concatenated_segments concatenated_segments
               , msik.inventory_item_id
               , msik.description
               , NVL(msik.revision_qty_control_code, 1)
               , NVL(msik.lot_control_code, 1)
               , NVL(msik.serial_number_control_code, 1)
               , NVL(msik.restrict_subinventories_code, 2)
               , NVL(msik.restrict_locators_code, 2)
               , NVL(msik.location_control_code, 1)
               , msik.primary_uom_code
               , NVL(msik.inspection_required_flag, 2)
               , NVL(msik.shelf_life_code, 1)
               , NVL(msik.shelf_life_days, 0)
               , NVL(msik.allowed_units_lookup_code, 2)
               , NVL(msik.effectivity_control, 1)
               , 0 parentlpnid
               , 0 quantity
               , NVL(msik.default_serial_status_id, 0)
               , NVL(msik.serial_status_enabled, 'N')
               , NVL(msik.default_lot_status_id, 0)
               , NVL(msik.lot_status_enabled, 'N')
               , mcr.cross_reference
               , 'N'
               , msik.inventory_item_flag
               , 0
	     	   , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
               NVL(msik.GRADE_CONTROL_FLAG,'N'),
               NVL(msik.DEFAULT_GRADE,''),
               NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
               NVL(msik.EXPIRATION_ACTION_CODE,''),
               NVL(msik.HOLD_DAYS,0),
               NVL(msik.MATURITY_DAYS,0),
               NVL(msik.RETEST_INTERVAL,0),
               NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(msik.CHILD_LOT_FLAG,'N'),
               NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
               NVL(msik.SECONDARY_UOM_CODE,''),
               NVL(msik.SECONDARY_DEFAULT_IND,''),
               NVL(msik.TRACKING_QUANTITY_IND,'P'),
               NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
               NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
            FROM mtl_system_items_vl msik, /* Bug 5581528 */
	         mtl_cycle_count_items mcci, mtl_cross_references mcr
           WHERE msik.organization_id = p_organization_id
             AND msik.inventory_item_id = mcci.inventory_item_id
             AND mcci.cycle_count_header_id = p_cycle_count_header_id
             AND (msik.serial_number_control_code IN (1, 6)
                  OR (l_serial_count_option <> 1
                      AND serial_number_control_code NOT IN (1, 6)
                     )
                 )
	AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id
	   OR
	   mcr.org_independent_flag = 'Y')
        ORDER BY concatenated_segments;
    ELSE -- Unscheduled entries are not allowed
      OPEN x_items FOR
        SELECT UNIQUE msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
	     	        , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msik, /* Bug 5581528 */
		      mtl_cycle_count_entries mcce
                WHERE msik.organization_id = p_organization_id
                  AND msik.concatenated_segments LIKE (p_concatenated_segments||l_append)
                  AND msik.inventory_item_id = mcce.inventory_item_id
                  AND mcce.cycle_count_header_id = p_cycle_count_header_id
                  AND mcce.organization_id = p_organization_id
                  -- The sub and loc have to match an existing cycle count entry
                  -- OR the entry contains an LPN and
                  -- container discrepancies are allowed
                  -- OR the item is serial controlled, the cycle count header allows
                  -- serial items and serial discrepancies are allowed
                  AND ((mcce.subinventory = p_subinventory_code
                        AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
                       )
                       OR (mcce.parent_lpn_id IS NOT NULL
                           AND l_container_discrepancy_option = 1
                          )
                       OR (l_serial_count_option <> 1
                           AND msik.serial_number_control_code NOT IN (1, 6)
                           AND l_serial_discrepancy_option = 1
                          )
                      )
                  AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
			 AND mcce.entry_status_code IN (1, 3)

			 --Changes for GTIN
			 UNION

			         SELECT UNIQUE msik.concatenated_segments concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(msik.revision_qty_control_code, 1)
                    , NVL(msik.lot_control_code, 1)
                    , NVL(msik.serial_number_control_code, 1)
                    , NVL(msik.restrict_subinventories_code, 2)
                    , NVL(msik.restrict_locators_code, 2)
                    , NVL(msik.location_control_code, 1)
                    , msik.primary_uom_code
                    , NVL(msik.inspection_required_flag, 2)
                    , NVL(msik.shelf_life_code, 1)
                    , NVL(msik.shelf_life_days, 0)
                    , NVL(msik.allowed_units_lookup_code, 2)
                    , NVL(msik.effectivity_control, 1)
                    , 0 parentlpnid
                    , 0 quantity
                    , NVL(msik.default_serial_status_id, 0)
                    , NVL(msik.serial_status_enabled, 'N')
                    , NVL(msik.default_lot_status_id, 0)
                    , NVL(msik.lot_status_enabled, 'N')
                    , mcr.cross_reference
                    , 'N'
                    , msik.inventory_item_flag
                    , 0
	     	        , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msik.GRADE_CONTROL_FLAG,'N'),
                    NVL(msik.DEFAULT_GRADE,''),
                    NVL(msik.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msik.EXPIRATION_ACTION_CODE,''),
                    NVL(msik.HOLD_DAYS,0),
                    NVL(msik.MATURITY_DAYS,0),
                    NVL(msik.RETEST_INTERVAL,0),
                    NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msik.CHILD_LOT_FLAG,'N'),
                    NVL(msik.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msik.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msik.SECONDARY_UOM_CODE,''),
                    NVL(msik.SECONDARY_DEFAULT_IND,''),
                    NVL(msik.TRACKING_QUANTITY_IND,'P'),
                    NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msik.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msik, /* Bug 5581528 */
		      mtl_cycle_count_entries mcce, mtl_cross_references mcr
                WHERE msik.organization_id = p_organization_id
                  AND msik.inventory_item_id = mcce.inventory_item_id
                  AND mcce.cycle_count_header_id = p_cycle_count_header_id
                  AND mcce.organization_id = p_organization_id
                  -- The sub and loc have to match an existing cycle count entry
                  -- OR the entry contains an LPN and
                  -- container discrepancies are allowed
                  -- OR the item is serial controlled, the cycle count header allows
                  -- serial items and serial discrepancies are allowed
                  AND ((mcce.subinventory = p_subinventory_code
                        AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
                       )
                       OR (mcce.parent_lpn_id IS NOT NULL
                           AND l_container_discrepancy_option = 1
                          )
                       OR (l_serial_count_option <> 1
                           AND msik.serial_number_control_code NOT IN (1, 6)
                           AND l_serial_discrepancy_option = 1
                          )
                      )
                  AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
			 AND mcce.entry_status_code IN (1, 3)
			       AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id
	   OR
	   mcr.org_independent_flag = 'Y')
             ORDER BY concatenated_segments;
    END IF;
  END get_cyc_item_lov;

  --      Name: GET_CYC_REV_LOV
  --
  --      Input parameters:
  --       p_organization_id    - restricts LOV SQL to current org
  --       p_inventory_item_id  - restrict LOV for a given item
  --       p_revision           - restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --       p_unscheduled_entry  - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - restricts LOV SQL to current cycle count
  --       p_parent_lpn_id      -  Restricts output to only items with the
  --                               given parent lpn ID
  --
  --      Output parameters:
  --       x_revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text for a given cycle count
  --

  PROCEDURE get_cyc_rev_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_unscheduled_entry IN NUMBER, p_cycle_count_header_id IN NUMBER, p_parent_lpn_id IN NUMBER) IS
  BEGIN
    IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      OPEN x_revs FOR
        SELECT   revision
               , effectivity_date
               , NVL(description, '')
            FROM mtl_item_revisions
           WHERE organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND revision LIKE (p_revision)
        ORDER BY UPPER(revision);
    ELSE -- Unscheduled entries are not allowed
      OPEN x_revs FOR
        SELECT UNIQUE mir.revision
                    , mir.effectivity_date
                    , NVL(mir.description, '')
                 FROM mtl_item_revisions mir, mtl_cycle_count_entries mcce
                WHERE mir.organization_id = p_organization_id
                  AND mir.inventory_item_id = p_inventory_item_id
                  AND mir.revision LIKE (p_revision)
                  AND mir.inventory_item_id = mcce.inventory_item_id
                  AND mcce.cycle_count_header_id = p_cycle_count_header_id
                  AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND mcce.entry_status_code IN (1, 3)
             ORDER BY UPPER(mir.revision);
    END IF;
  END get_cyc_rev_lov;

  --      Name: GET_CYC_UOM_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV for a given item
  --       p_uom_code              - Restricts LOV SQL to the user input text
  --                                   e.g.  Ea%
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle count
  --
  --      Output parameters:
  --       x_uoms      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user inputted text for valid UOM's for a particular
  --                 cycle count
  --

  PROCEDURE get_cyc_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_uom_code IN VARCHAR2) IS
  l_code VARCHAR2(20):=p_UOM_Code;
  BEGIN
   IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_UOM_Code,1,INSTR(p_UOM_Code,'(')-1);
   END IF;

    OPEN x_uoms FOR
/* UOM LOV Enhancements */
--      SELECT   uom_code
      SELECT (inv_ui_item_lovs.get_conversion_rate(uom_code,
                                   p_organization_id,
                                   p_inventory_item_id)) uom_code_comp
             , unit_of_measure
             , description
             , uom_class
          FROM mtl_item_uoms_view
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND uom_code LIKE (l_code)
      ORDER BY inv_ui_item_lovs.conversion_order(inv_ui_item_lovs.get_conversion_rate(uom_code,
                                   p_Organization_Id,
                                   p_Inventory_Item_Id)) asc, Upper(uom_code);
--      ORDER BY UPPER(uom_code);
  END get_cyc_uom_lov;

  --      Name: GET_INSPECT_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id         organization where the inspection occurs
  --       p_concatenated_segments   restricts output to user entered search pattern for item
  --       p_lpn_id                  id of lpn that contains items to be inspected
  --
  --      Output parameters:
  --       x_items      returns LOV rows as reference cursor
  --
  --      Functions:
  --                      This procedure returns items that need inspection
  --

  PROCEDURE get_inspect_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_lpn_id IN NUMBER) IS
    l_inspection_qty NUMBER;
    l_return_status  VARCHAR2(10);
    l_msg_data       VARCHAR2(500);
    l_cross_ref varchar2(204);
    l_append varchar2(2):='';
   BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

     IF (p_concatenated_segments IS NOT NULL
	 AND p_concatenated_segments <> '%') THEN
	OPEN x_items FOR
	  SELECT DISTINCT a.concatenated_segments
	            , a.inventory_item_id
                    , a.description
                    , NVL(a.revision_qty_control_code, 1)
                    , NVL(a.lot_control_code, 1)
                    , NVL(a.serial_number_control_code, 1)
                    , NVL(a.restrict_subinventories_code, 2)
                    , NVL(a.restrict_locators_code, 2)
                    , NVL(a.location_control_code, 1)
                    , a.primary_uom_code
                    , NVL(a.inspection_required_flag, 2)
                    , NVL(a.shelf_life_code, 1)
                    , NVL(a.shelf_life_days, 0)
                    , NVL(a.allowed_units_lookup_code, 2)
                    , NVL(a.effectivity_control, 1)
                    , 0
                    , 0
                    , NVL(a.default_serial_status_id, 0)
                    , NVL(a.serial_status_enabled, 'N')
                    , NVL(a.default_lot_status_id, 0)
                    , NVL(a.lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , a.inventory_item_flag
                    , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN', p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
			  , wms_deploy.get_item_client_name(a.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(a.GRADE_CONTROL_FLAG,'N'),
                    NVL(a.DEFAULT_GRADE,''),
                    NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(a.EXPIRATION_ACTION_CODE,''),
                    NVL(a.HOLD_DAYS,0),
                    NVL(a.MATURITY_DAYS,0),
                    NVL(a.RETEST_INTERVAL,0),
                    NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(a.CHILD_LOT_FLAG,'N'),
                    NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(a.SECONDARY_UOM_CODE,''),
                    NVL(a.SECONDARY_DEFAULT_IND,''),
                    NVL(a.TRACKING_QUANTITY_IND,'P'),
                    NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl a, mtl_txn_request_lines b /* Bug 5581528 */
                WHERE b.lpn_id = p_lpn_id
                  AND b.organization_id = p_organization_id
                  AND b.inspection_status is not null   -- 8405606
                  AND b.organization_id = a.organization_id
                  AND b.inventory_item_id = a.inventory_item_id
	          AND a.concatenated_segments LIKE (p_concatenated_segments||l_append)
	          AND Nvl(b.wms_process_flag,-1) <> 2
	  AND ((inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN',
								    p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0)

	  --Changes for GTIN
	  UNION

	  	  SELECT DISTINCT a.concatenated_segments
	            , a.inventory_item_id
                    , a.description
                    , NVL(a.revision_qty_control_code, 1)
                    , NVL(a.lot_control_code, 1)
                    , NVL(a.serial_number_control_code, 1)
                    , NVL(a.restrict_subinventories_code, 2)
                    , NVL(a.restrict_locators_code, 2)
                    , NVL(a.location_control_code, 1)
                    , a.primary_uom_code
                    , NVL(a.inspection_required_flag, 2)
                    , NVL(a.shelf_life_code, 1)
                    , NVL(a.shelf_life_days, 0)
                    , NVL(a.allowed_units_lookup_code, 2)
                    , NVL(a.effectivity_control, 1)
                    , 0
                    , 0
                    , NVL(a.default_serial_status_id, 0)
                    , NVL(a.serial_status_enabled, 'N')
                    , NVL(a.default_lot_status_id, 0)
                    , NVL(a.lot_status_enabled, 'N')
                    , mcr.cross_reference
                    , 'N'
                    , a.inventory_item_flag
                    , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN', p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
			  , wms_deploy.get_item_client_name(a.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(a.GRADE_CONTROL_FLAG,'N'),
                    NVL(a.DEFAULT_GRADE,''),
                    NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(a.EXPIRATION_ACTION_CODE,''),
                    NVL(a.HOLD_DAYS,0),
                    NVL(a.MATURITY_DAYS,0),
                    NVL(a.RETEST_INTERVAL,0),
                    NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(a.CHILD_LOT_FLAG,'N'),
                    NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(a.SECONDARY_UOM_CODE,''),
                    NVL(a.SECONDARY_DEFAULT_IND,''),
                    NVL(a.TRACKING_QUANTITY_IND,'P'),
                    NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	  FROM mtl_system_items_vl a, /* Bug 5581528 */
	  mtl_txn_request_lines b,
	    mtl_cross_references mcr
	  WHERE b.lpn_id = p_lpn_id
	  AND b.organization_id = p_organization_id
	  AND b.inspection_status is not null   -- 8405606
	  AND b.organization_id = a.organization_id
	  AND b.inventory_item_id = a.inventory_item_id
	  AND Nvl(b.wms_process_flag,-1) <> 2
	  AND ((inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN',
								    p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0)
	  AND a.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = a.organization_id
	       OR
	       mcr.org_independent_flag = 'Y');


      ELSE
	OPEN x_items FOR
	  SELECT DISTINCT a.concatenated_segments
	            , a.inventory_item_id
                    , a.description
                    , NVL(a.revision_qty_control_code, 1)
                    , NVL(a.lot_control_code, 1)
                    , NVL(a.serial_number_control_code, 1)
                    , NVL(a.restrict_subinventories_code, 2)
                    , NVL(a.restrict_locators_code, 2)
                    , NVL(a.location_control_code, 1)
                    , a.primary_uom_code
                    , NVL(a.inspection_required_flag, 2)
                    , NVL(a.shelf_life_code, 1)
                    , NVL(a.shelf_life_days, 0)
                    , NVL(a.allowed_units_lookup_code, 2)
                    , NVL(a.effectivity_control, 1)
                    , 0
                    , 0
                    , NVL(a.default_serial_status_id, 0)
                    , NVL(a.serial_status_enabled, 'N')
                    , NVL(a.default_lot_status_id, 0)
                    , NVL(a.lot_status_enabled, 'N')
                    , ''
                    , 'N'
                    , a.inventory_item_flag
                    , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN', p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
			  , wms_deploy.get_item_client_name(a.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(a.GRADE_CONTROL_FLAG,'N'),
                    NVL(a.DEFAULT_GRADE,''),
                    NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(a.EXPIRATION_ACTION_CODE,''),
                    NVL(a.HOLD_DAYS,0),
                    NVL(a.MATURITY_DAYS,0),
                    NVL(a.RETEST_INTERVAL,0),
                    NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(a.CHILD_LOT_FLAG,'N'),
                    NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(a.SECONDARY_UOM_CODE,''),
                    NVL(a.SECONDARY_DEFAULT_IND,''),
                    NVL(a.TRACKING_QUANTITY_IND,'P'),
                    NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl a, mtl_txn_request_lines b /* Bug 5581528 */
                WHERE b.lpn_id = p_lpn_id
                  AND b.organization_id = p_organization_id
                  AND b.inspection_status is not null   -- 8405606
                  AND b.organization_id = a.organization_id
                  AND b.inventory_item_id = a.inventory_item_id
		  AND a.concatenated_segments LIKE (p_concatenated_segments||l_append)
	          AND Nvl(b.wms_process_flag,-1) <> 2
	  AND ((inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('LPN', p_lpn_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0);
     END IF;
  END get_inspect_item_lov;

  --      Name: GET_INSPECT_REVISION_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_lpn_id            restricts items to lpn that is being inspected
  --       p_Revision          which restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --
  --      Output parameters:
  --       x_Revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_inspect_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_lpn_id IN NUMBER, p_revision IN VARCHAR2) IS
  BEGIN
    OPEN x_revs FOR
      SELECT DISTINCT a.revision
                    , a.effectivity_date
                    , NVL(a.description, '')
                 FROM mtl_item_revisions a, mtl_txn_request_lines b
                WHERE b.organization_id = p_organization_id
                  AND b.inventory_item_id = p_inventory_item_id
                  AND b.lpn_id = p_lpn_id
                  AND b.inspection_status is not null  --8405606
                  AND a.organization_id = b.organization_id
                  AND a.inventory_item_id = b.inventory_item_id
                  AND a.revision = b.revision
                  AND a.revision LIKE (p_revision);
  END get_inspect_revision_lov;

  PROCEDURE get_oh_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_subinventory_code VARCHAR2, p_locator_id VARCHAR2, p_container_item_flag VARCHAR2, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    IF (p_container_item_flag IS NULL) THEN
      OPEN x_items FOR
        SELECT DISTINCT msi.concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , NVL(msi.restrict_subinventories_code, 2)
                      , NVL(msi.restrict_locators_code, 2)
                      , NVL(msi.location_control_code, 1)
                      , msi.primary_uom_code
                      , NVL(msi.inspection_required_flag, 2)
                      , NVL(msi.shelf_life_code, 1)
                      , NVL(msi.shelf_life_days, 0)
                      , NVL(msi.allowed_units_lookup_code, 2)
                      , NVL(msi.effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , ''
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_onhand_quantities_detail moq, mtl_system_items_vl msi  -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
                  WHERE moq.organization_id = p_org_id
                    AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
                    AND NVL(moq.locator_id, -1) = NVL(p_locator_id, NVL(moq.locator_id, -1))
                    AND moq.containerized_flag = 2
                    AND moq.inventory_item_id = msi.inventory_item_id
                    AND moq.organization_id = msi.organization_id
	AND msi.concatenated_segments LIKE (p_item||l_append)

	--Changes for GTIN
	UNION

	        SELECT DISTINCT msi.concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , NVL(msi.restrict_subinventories_code, 2)
                      , NVL(msi.restrict_locators_code, 2)
                      , NVL(msi.location_control_code, 1)
                      , msi.primary_uom_code
                      , NVL(msi.inspection_required_flag, 2)
                      , NVL(msi.shelf_life_code, 1)
                      , NVL(msi.shelf_life_days, 0)
                      , NVL(msi.allowed_units_lookup_code, 2)
                      , NVL(msi.effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , mcr.cross_reference
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_onhand_quantities_detail moq, -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
	mtl_system_items_vl msi, /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE moq.organization_id = p_org_id
	AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
	AND NVL(moq.locator_id, -1) = NVL(p_locator_id, NVL(moq.locator_id, -1))
	AND moq.containerized_flag = 2
	AND moq.inventory_item_id = msi.inventory_item_id
	AND moq.organization_id = msi.organization_id
	AND msi.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msi.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');

    ELSE
      OPEN x_items FOR
        SELECT DISTINCT msi.concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , NVL(msi.restrict_subinventories_code, 2)
                      , NVL(msi.restrict_locators_code, 2)
                      , NVL(msi.location_control_code, 1)
                      , msi.primary_uom_code
                      , NVL(msi.inspection_required_flag, 2)
                      , NVL(msi.shelf_life_code, 1)
                      , NVL(msi.shelf_life_days, 0)
                      , NVL(msi.allowed_units_lookup_code, 2)
                      , NVL(msi.effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , ''
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_onhand_quantities_detail moq, mtl_system_items_vl msi /* Bug 5581528 */
					-- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
                  WHERE moq.organization_id = p_org_id
                    AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
                    AND NVL(moq.locator_id, -1) = NVL(p_locator_id, NVL(moq.locator_id, -1))
                    AND NVL(msi.container_item_flag, '@') = NVL(p_container_item_flag, NVL(msi.container_item_flag, '@'))
                    AND moq.inventory_item_id = msi.inventory_item_id
                    AND moq.organization_id = msi.organization_id
	AND concatenated_segments LIKE (p_item||l_append)

	--Changes for GTIN
	UNION

	        SELECT DISTINCT msi.concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , NVL(msi.restrict_subinventories_code, 2)
                      , NVL(msi.restrict_locators_code, 2)
                      , NVL(msi.location_control_code, 1)
                      , msi.primary_uom_code
                      , NVL(msi.inspection_required_flag, 2)
                      , NVL(msi.shelf_life_code, 1)
                      , NVL(msi.shelf_life_days, 0)
                      , NVL(msi.allowed_units_lookup_code, 2)
                      , NVL(msi.effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , mcr.cross_reference
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_onhand_quantities_detail moq, -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
	mtl_system_items_vl msi, /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE moq.organization_id = p_org_id
	AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
	AND NVL(moq.locator_id, -1) = NVL(p_locator_id, NVL(moq.locator_id, -1))
	AND NVL(msi.container_item_flag, '@') = NVL(p_container_item_flag, NVL(msi.container_item_flag, '@'))
	AND moq.inventory_item_id = msi.inventory_item_id
	AND moq.organization_id = msi.organization_id
	AND msi.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msi.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');
    END IF;
  END get_oh_item_lov;

  PROCEDURE get_cont_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN VARCHAR2, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    OPEN x_items FOR
      SELECT DISTINCT msi.concatenated_segments
                    , wlc.inventory_item_id
                    , NVL(msi.description, '')
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , NVL(msi.primary_uom_code, '')
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , NVL(wlc.parent_lpn_id, 0)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , ''
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(wlc.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msi, wms_lpn_contents wlc /* Bug 5581528 */
                WHERE wlc.organization_id = p_org_id
                  AND wlc.parent_lpn_id = TO_NUMBER(p_lpn_id)
                  AND msi.inventory_item_id = wlc.inventory_item_id
                  AND msi.organization_id = wlc.organization_id
      AND msi.concatenated_segments LIKE (p_item||l_append)

      --Changes for GTIN
      UNION

            SELECT DISTINCT msi.concatenated_segments
                    , wlc.inventory_item_id
                    , NVL(msi.description, '')
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , NVL(msi.primary_uom_code, '')
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , NVL(wlc.parent_lpn_id, 0)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , mcr.cross_reference
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(wlc.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msi, /* Bug 5581528 */
      wms_lpn_contents wlc,
      mtl_cross_references mcr
      WHERE wlc.organization_id = p_org_id
      AND wlc.parent_lpn_id = TO_NUMBER(p_lpn_id)
      AND msi.inventory_item_id = wlc.inventory_item_id
      AND msi.organization_id = wlc.organization_id
      AND msi.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msi.organization_id
	   OR
	   mcr.org_independent_flag = 'Y');

  END get_cont_item_lov;

  PROCEDURE get_bp_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_subinventory_code VARCHAR2, p_locator_id VARCHAR2, p_container_item_flag VARCHAR2, p_source VARCHAR2, p_item VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');
   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    IF (NVL(p_source, '1') = '1') THEN
      IF (p_container_item_flag = 'Y') THEN
        OPEN x_items FOR
          SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
				, wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                     FROM mtl_system_items_vl msi /* Bug 5581528 */
                    WHERE msi.organization_id = p_org_id
                      AND NVL(serial_number_control_code, 1) IN (1, 2, 5, 6)
                      AND NVL(container_item_flag, 'N') = NVL(p_container_item_flag, NVL(container_item_flag, 'N'))
	  AND msi.concatenated_segments LIKE (p_item||l_append)

	  --Changes for GTIN
	  UNION

	            SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , mcr.cross_reference
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
				, wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	  FROM mtl_system_items_vl msi, /* Bug 5581528 */
	  mtl_cross_references mcr
	  WHERE msi.organization_id = p_org_id
	  AND NVL(serial_number_control_code, 1) IN (1, 2, 5, 6)
	  AND NVL(container_item_flag, 'N') = NVL(p_container_item_flag, NVL(container_item_flag, 'N'))
	  AND msi.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = msi.organization_id
	       OR
	       mcr.org_independent_flag = 'Y');

      ELSE
        OPEN x_items FOR
          SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
				, wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                     FROM mtl_onhand_quantities_detail moq, mtl_system_items_vl msi -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
                    WHERE msi.organization_id = p_org_id
                      AND NVL(serial_number_control_code, 1) IN (1, 2, 5, 6)
                      AND msi.concatenated_segments LIKE (p_item||l_append)
                      AND NVL(container_item_flag, 'N') = NVL(p_container_item_flag, NVL(container_item_flag, 'N'))
                      AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
                      AND moq.locator_id = NVL(TO_NUMBER(p_locator_id), moq.locator_id)
                      AND moq.containerized_flag = 2
                      AND moq.inventory_item_id = msi.inventory_item_id
	  AND moq.organization_id = msi.organization_id

	  --Changes for GTIN
	  UNION

	            SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , mcr.cross_reference
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
				, wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(msi.GRADE_CONTROL_FLAG,'N'),
                    NVL(msi.DEFAULT_GRADE,''),
                    NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                    NVL(msi.EXPIRATION_ACTION_CODE,''),
                    NVL(msi.HOLD_DAYS,0),
                    NVL(msi.MATURITY_DAYS,0),
                    NVL(msi.RETEST_INTERVAL,0),
                    NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(msi.CHILD_LOT_FLAG,'N'),
                    NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(msi.SECONDARY_UOM_CODE,''),
                    NVL(msi.SECONDARY_DEFAULT_IND,''),
                    NVL(msi.TRACKING_QUANTITY_IND,'P'),
                    NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	  FROM mtl_onhand_quantities_detail moq, -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
	  mtl_system_items_vl msi, /* Bug 5581528 */
	  mtl_cross_references mcr
	  WHERE msi.organization_id = p_org_id
	  AND NVL(serial_number_control_code, 1) IN (1, 2, 5, 6)
	  AND NVL(container_item_flag, 'N') = NVL(p_container_item_flag, NVL(container_item_flag, 'N'))
	  AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
	  AND moq.locator_id = NVL(TO_NUMBER(p_locator_id), moq.locator_id)
	  AND moq.containerized_flag = 2
	  AND moq.inventory_item_id = msi.inventory_item_id
	  AND moq.organization_id = msi.organization_id
	  AND msi.inventory_item_id   = mcr.inventory_item_id
	  AND mcr.cross_reference_type = g_gtin_cross_ref_type
	  AND mcr.cross_reference      LIKE l_cross_ref
	  AND (mcr.organization_id     = msi.organization_id
	       OR
	       mcr.org_independent_flag = 'Y');

      END IF;
    ELSE
      OPEN x_items FOR
        SELECT DISTINCT concatenated_segments
                      , inventory_item_id
                      , description
                      , NVL(revision_qty_control_code, 1)
                      , NVL(lot_control_code, 1)
                      , NVL(serial_number_control_code, 1)
                      , NVL(restrict_subinventories_code, 2)
                      , NVL(restrict_locators_code, 2)
                      , NVL(location_control_code, 1)
                      , primary_uom_code
                      , NVL(inspection_required_flag, 2)
                      , NVL(shelf_life_code, 1)
                      , NVL(shelf_life_days, 0)
                      , NVL(allowed_units_lookup_code, 2)
                      , NVL(effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , ''
                      , 'N'
                      , inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(GRADE_CONTROL_FLAG,'N'),
                    NVL(DEFAULT_GRADE,''),
                    NVL(EXPIRATION_ACTION_INTERVAL,0),
                    NVL(EXPIRATION_ACTION_CODE,''),
                    NVL(HOLD_DAYS,0),
                    NVL(MATURITY_DAYS,0),
                    NVL(RETEST_INTERVAL,0),
                    NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(CHILD_LOT_FLAG,'N'),
                    NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(SECONDARY_UOM_CODE,''),
                    NVL(SECONDARY_DEFAULT_IND,''),
                    NVL(TRACKING_QUANTITY_IND,'P'),
                    NVL(DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_system_items_vl /* Bug 5581528 */
                  WHERE organization_id = p_org_id
                    AND NVL(container_item_flag, 'N') = NVL(p_container_item_flag, NVL(container_item_flag, 'N'))
                    AND NVL(serial_number_control_code, 1) IN (1, 2, 5, 6)
	AND concatenated_segments LIKE (p_item||l_append)

	--Changes for GTIN
	UNION

	        SELECT DISTINCT msik.concatenated_segments
                      , msik.inventory_item_id
                      , msik.description
                      , NVL(revision_qty_control_code, 1)
                      , NVL(lot_control_code, 1)
                      , NVL(serial_number_control_code, 1)
                      , NVL(restrict_subinventories_code, 2)
                      , NVL(restrict_locators_code, 2)
                      , NVL(location_control_code, 1)
                      , primary_uom_code
                      , NVL(inspection_required_flag, 2)
                      , NVL(shelf_life_code, 1)
                      , NVL(shelf_life_days, 0)
                      , NVL(allowed_units_lookup_code, 2)
                      , NVL(effectivity_control, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , mcr.cross_reference
                      , 'N'
                      , inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                    NVL(GRADE_CONTROL_FLAG,'N'),
                    NVL(DEFAULT_GRADE,''),
                    NVL(EXPIRATION_ACTION_INTERVAL,0),
                    NVL(EXPIRATION_ACTION_CODE,''),
                    NVL(HOLD_DAYS,0),
                    NVL(MATURITY_DAYS,0),
                    NVL(RETEST_INTERVAL,0),
                    NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                    NVL(CHILD_LOT_FLAG,'N'),
                    NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                    NVL(LOT_DIVISIBLE_FLAG,'Y'),
                    NVL(SECONDARY_UOM_CODE,''),
                    NVL(SECONDARY_DEFAULT_IND,''),
                    NVL(TRACKING_QUANTITY_IND,'P'),
                    NVL(DUAL_UOM_DEVIATION_HIGH,0),
                    NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl msik, /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE msik.organization_id = p_org_id
	AND NVL(msik.container_item_flag, 'N') = NVL(p_container_item_flag, NVL(msik.container_item_flag, 'N'))
	AND NVL(msik.serial_number_control_code, 1) IN (1, 2, 5, 6)
	AND msik.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msik.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');

    END IF;
  END get_bp_item_lov;


  --Bug # 2647045
  PROCEDURE get_cont_uom_lov(x_UOMS OUT NOCOPY t_genref,
		      p_Organization_Id IN NUMBER,
		      p_Inventory_Item_Id IN NUMBER,
		      p_lpn_id IN NUMBER,
		      p_UOM_Code IN VARCHAR2) IS
     l_code VARCHAR2(20):=p_UOM_Code;
  BEGIN
     IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_UOM_Code,1,INSTR(p_UOM_Code,'(')-1);
   END IF;

    OPEN x_uoms FOR
      SELECT DISTINCT (inv_ui_item_lovs.get_conversion_rate(wlc.uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) uom_code_comp
                    , miuv.unit_of_measure
                    , miuv.description
                    , miuv.uom_class
                 FROM mtl_item_uoms_view miuv, wms_lpn_contents wlc
                WHERE wlc.organization_id = p_organization_id
                  AND wlc.inventory_item_id = p_inventory_item_id
                  AND NVL(wlc.parent_lpn_id, 0) = NVL(p_lpn_id, NVL(wlc.parent_lpn_id, 0))
                  AND miuv.organization_id = wlc.organization_id
                  AND miuv.inventory_item_id = wlc.inventory_item_id
                  AND miuv.uom_code = wlc.uom_code
                  AND wlc.uom_code LIKE (l_code)
      ORDER BY inv_ui_item_lovs.conversion_order(inv_ui_item_lovs.get_conversion_rate(wlc.uom_code,
				   p_Organization_Id,
				   p_Inventory_Item_Id)) asc, Upper(wlc.uom_code);
  END get_cont_uom_lov;



  PROCEDURE get_all_uom_lov(x_uoms OUT NOCOPY t_genref, p_uom_code IN VARCHAR2) IS
  BEGIN
    OPEN x_uoms FOR
      SELECT DISTINCT uom_code
                    , unit_of_measure
                    , description
                    , uom_class
                 FROM mtl_units_of_measure
                WHERE uom_code LIKE (p_uom_code);
  END get_all_uom_lov;

  --      Name: GET_INV_INSPECT_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id         organization where the inspection occurs
  --       p_concatenated_segments   restricts output to user entered search pattern for item
  --       p_source                  document source type being inspected
  --                                 PO, INTSHIP, RMA, RECEIPT
  --       p_source_id               relevant document id based on p_source
  --                                 po_header_id, shipment_header_id, oe_order_header_id,
  --                                 receipt_num
  --
  --      Output parameters:
  --       x_items      returns LOV rows as reference cursor
  --
  --      Functions:
  --                      This procedure returns the items that need inspection
  --

  PROCEDURE get_inv_inspect_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_source IN VARCHAR2, p_source_id IN NUMBER) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    IF (p_source IN ('PO', 'po')) THEN
      OPEN x_items FOR
        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('PO', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_system_items_vl a, rcv_transactions_v b /* Bug 5581528 */
                  WHERE b.to_organization_id = p_organization_id
                    AND b.po_header_id = p_source_id
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND b.to_organization_id = a.organization_id
                    AND b.item_id = a.inventory_item_id
                    --bug5708184,in PO Source,add the condition to match with po supplier item.
                    AND (a.concatenated_segments LIKE (p_concatenated_segments||l_append)
                          or exists (select pla.vendor_product_num
                                    from po_lines_all pla
                                    where pla.po_header_id=b.po_header_id and
                                    pla.po_line_id=b.po_line_id and
                                    pla.vendor_product_num like (p_concatenated_segments)))
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('PO',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0

	--Changes for GTIN

	UNION
	        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('PO', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl a, /* Bug 5581528 */
	rcv_transactions_v b,
	mtl_cross_references mcr
	WHERE b.to_organization_id = p_organization_id
	AND b.po_header_id = p_source_id
	AND b.inspection_status_code = 'NOT INSPECTED'
	AND b.routing_id = 2  /* Inspection routing */
	AND b.to_organization_id = a.organization_id
	AND b.item_id = a.inventory_item_id
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('PO', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0
	AND a.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = a.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');

     ELSIF (p_source IN ('INTSHIP', 'intship')) THEN
      OPEN x_items FOR
        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_system_items_vl a, rcv_transactions_v b /* Bug 5581528 */
                  WHERE b.to_organization_id = p_organization_id
                    AND b.shipment_header_id = p_source_id
                    AND b.receipt_source_code <> 'VENDOR'
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND b.to_organization_id = a.organization_id
                    AND b.item_id = a.inventory_item_id
                    AND a.concatenated_segments LIKE (p_concatenated_segments||l_append)
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0

	--Changes for GTIN
	UNION

	        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl a, /* Bug 5581528 */
	rcv_transactions_v b,
	mtl_cross_references mcr
	WHERE b.to_organization_id = p_organization_id
	AND b.shipment_header_id = p_source_id
	AND b.receipt_source_code <> 'VENDOR'
	AND b.inspection_status_code = 'NOT INSPECTED'
	AND b.routing_id = 2  /* Inspection routing */
	AND b.to_organization_id = a.organization_id
	AND b.item_id = a.inventory_item_id
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0
	AND a.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = a.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');

    ELSIF (p_source IN ('RMA', 'rma')) THEN
      OPEN x_items FOR
        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RMA', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_system_items_vl a, rcv_transactions_v b /* Bug 5581528 */
                  WHERE b.to_organization_id = p_organization_id
                    AND b.oe_order_header_id = p_source_id
                    AND b.receipt_source_code <> 'VENDOR'
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND b.to_organization_id = a.organization_id
                    AND b.item_id = a.inventory_item_id
                    AND a.concatenated_segments LIKE (p_concatenated_segments||l_append)
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RMA',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0

	--Changes for GTIN
	UNION

	        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RMA', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl a, /* Bug 5581528 */
	rcv_transactions_v b,
	mtl_cross_references mcr
	WHERE b.to_organization_id = p_organization_id
	AND b.oe_order_header_id = p_source_id
	AND b.receipt_source_code <> 'VENDOR'
	AND b.inspection_status_code = 'NOT INSPECTED'
	AND b.routing_id = 2  /* Inspection routing */
	AND b.to_organization_id = a.organization_id
	AND b.item_id = a.inventory_item_id
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RMA',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0
	AND a.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = a.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');

    ELSIF (p_source IN ('RECEIPT', 'receipt')) THEN
      OPEN x_items FOR
        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RECEIPT', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
                   FROM mtl_system_items_vl a, rcv_transactions_v b /* Bug 5581528 */
                  WHERE b.to_organization_id = p_organization_id
                    AND b.shipment_header_id = TO_CHAR(p_source_id)
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND b.to_organization_id = a.organization_id
                    AND b.item_id = a.inventory_item_id
                    --bug5708184,in Receitp source,add the condition to match with po supplier item
                    AND (a.concatenated_segments LIKE (p_concatenated_segments||l_append)
                          or exists (select pla.vendor_product_num
                                    from po_lines_all pla
                                    where pla.po_header_id=b.po_header_id and
                                    pla.po_line_id=b.po_line_id and
                                    pla.vendor_product_num like (p_concatenated_segments)))
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RECEIPT',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0

	--Changes for GTIN
	UNION

	        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RECEIPT', p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl a, /* Bug 5581528 */
	rcv_transactions_v b,
	mtl_cross_references mcr
	WHERE b.to_organization_id = p_organization_id
	AND b.shipment_header_id = TO_CHAR(p_source_id)
	AND b.inspection_status_code = 'NOT INSPECTED'
	AND b.routing_id = 2  /* Inspection routing */
	AND b.to_organization_id = a.organization_id
	AND b.item_id = a.inventory_item_id
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('RECEIPT',
								 p_source_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0
	AND a.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = a.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');
     ELSIF (p_source IN ('REQ', 'req')) THEN
       --BUG 3421219: First get the shipment_num for this IR, then query
       --exactly the same way as for IntShip
       OPEN x_items FOR
        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP', shipment.shipment_header_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	             FROM mtl_system_items_vl a, /* Bug 5581528 */
	                  rcv_transactions_v b,
	                  (SELECT DISTINCT rsl.shipment_header_id
			   FROM   po_requisition_lines pol,
			          rcv_shipment_lines rsl
			   WHERE  pol.requisition_header_id = p_source_id
			   AND    pol.requisition_line_id = rsl.requisition_line_id
			   ) shipment
	           WHERE b.to_organization_id = p_organization_id
	            AND b.shipment_header_id = shipment.shipment_header_id
                    AND b.receipt_source_code <> 'VENDOR'
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND b.to_organization_id = a.organization_id
                    AND b.item_id = a.inventory_item_id
                    AND a.concatenated_segments LIKE (p_concatenated_segments||l_append)
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP',
								 shipment.shipment_header_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0

	--Changes for GTIN
	UNION

	        SELECT DISTINCT a.concatenated_segments
                      , a.inventory_item_id
                      , a.description
                      , NVL(a.revision_qty_control_code, 1)
                      , NVL(a.lot_control_code, 1)
                      , NVL(a.serial_number_control_code, 1)
                      , NVL(a.restrict_subinventories_code, 2)
                      , NVL(a.restrict_locators_code, 2)
                      , NVL(a.location_control_code, 1)
                      , a.primary_uom_code
                      , NVL(a.inspection_required_flag, 2)
                      , NVL(a.shelf_life_code, 1)
                      , NVL(a.shelf_life_days, 0)
                      , NVL(a.allowed_units_lookup_code, 2)
                      , NVL(a.effectivity_control, 1)
                      , 0
                      , 0
                      , NVL(a.default_serial_status_id, 0)
                      , NVL(a.serial_status_enabled, 'N')
                      , NVL(a.default_lot_status_id, 0)
                      , NVL(a.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , a.inventory_item_flag
                      , (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP', shipment.shipment_header_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code))
		     	    , wms_deploy.get_item_client_name(a.inventory_item_id)
		      , a.inventory_asset_flag --5405993: Added inventory_asset_flag and outside_processing_flag.
		      , a.outside_operation_flag,
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(a.GRADE_CONTROL_FLAG,'N'),
                      NVL(a.DEFAULT_GRADE,''),
                      NVL(a.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(a.EXPIRATION_ACTION_CODE,''),
                      NVL(a.HOLD_DAYS,0),
                      NVL(a.MATURITY_DAYS,0),
                      NVL(a.RETEST_INTERVAL,0),
                      NVL(a.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(a.CHILD_LOT_FLAG,'N'),
                      NVL(a.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(a.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(a.SECONDARY_UOM_CODE,''),
                      NVL(a.SECONDARY_DEFAULT_IND,''),
                      NVL(a.TRACKING_QUANTITY_IND,'P'),
                      NVL(a.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(a.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl a, /* Bug 5581528 */
	rcv_transactions_v b,
	mtl_cross_references mcr,
	(SELECT DISTINCT rsl.shipment_header_id
	 FROM   po_requisition_lines pol,
	 rcv_shipment_lines rsl
	 WHERE  pol.requisition_header_id = p_source_id
	 AND    pol.requisition_line_id = rsl.requisition_line_id
	 ) shipment
	WHERE b.to_organization_id = p_organization_id
	AND b.shipment_header_id = shipment.shipment_header_id
	AND b.receipt_source_code <> 'VENDOR'
	AND b.inspection_status_code = 'NOT INSPECTED'
	AND b.routing_id = 2  /* Inspection routing */
	AND b.to_organization_id = a.organization_id
	AND b.item_id = a.inventory_item_id
	AND (inv_rcv_std_inspect_apis.get_inspection_qty_wrapper('INTSHIP',
								 shipment.shipment_header_id, NULL, NULL, p_organization_id, a.inventory_item_id, a.primary_uom_code)) > 0
	AND a.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = a.organization_id
	     OR
	     mcr.org_independent_flag = 'Y');
    END IF;
  END get_inv_inspect_item_lov;

  --      Name: GET_INV_INSPECT_REVISION_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_source                  document source type being inspected
  --                                 PO, INTSHIP, RMA, RECEIPT
  --       p_source_id               relevant document id based on p_source
  --                                 po_header_id, shipment_header_id, oe_order_header_id,
  --                                 receipt_num
  --       p_Revision          which restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --
  --      Output parameters:
  --       x_Revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --

  PROCEDURE get_inv_inspect_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_source IN VARCHAR2, p_source_id IN NUMBER, p_revision IN VARCHAR2) IS
  BEGIN
    IF (p_source IN ('PO', 'po')) THEN
      OPEN x_revs FOR
        SELECT DISTINCT a.revision
                      , a.effectivity_date
                      , NVL(a.description, '')
                   FROM mtl_item_revisions a, rcv_transactions_v b
                  WHERE b.to_organization_id = p_organization_id
                    AND b.item_id = p_inventory_item_id
                    AND b.po_header_id = p_source_id
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND a.organization_id = b.to_organization_id
                    AND a.inventory_item_id = b.item_id
                    AND a.revision = b.item_revision
                    AND a.revision LIKE (p_revision);
    ELSIF (p_source IN ('INTSHIP', 'intship', 'REQ', 'req')) THEN
      OPEN x_revs FOR
        SELECT DISTINCT a.revision
                      , a.effectivity_date
                      , NVL(a.description, '')
                   FROM mtl_item_revisions a, rcv_transactions_v b
                  WHERE b.to_organization_id = p_organization_id
                    AND b.item_id = p_inventory_item_id
                    AND b.receipt_source_code <> 'VENDOR'
                    AND b.shipment_header_id = p_source_id
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND a.organization_id = b.to_organization_id
                    AND a.inventory_item_id = b.item_id
                    AND a.revision = b.item_revision
                    AND a.revision LIKE (p_revision);
    ELSIF (p_source IN ('RMA', 'rma')) THEN
      OPEN x_revs FOR
        SELECT DISTINCT a.revision
                      , a.effectivity_date
                      , NVL(a.description, '')
                   FROM mtl_item_revisions a, rcv_transactions_v b
                  WHERE b.to_organization_id = p_organization_id
                    AND b.item_id = p_inventory_item_id
                    AND b.receipt_source_code <> 'VENDOR'
                    AND b.oe_order_header_id = p_source_id
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND a.organization_id = b.to_organization_id
                    AND a.inventory_item_id = b.item_id
                    AND a.revision = b.item_revision
                    AND a.revision LIKE (p_revision);
    ELSIF (p_source IN ('RECEIPT', 'receipt')) THEN
      OPEN x_revs FOR
        SELECT DISTINCT a.revision
                      , a.effectivity_date
                      , NVL(a.description, '')
                   FROM mtl_item_revisions a, rcv_transactions_v b
                  WHERE b.to_organization_id = p_organization_id
                    AND b.item_id = p_inventory_item_id
                    AND b.shipment_header_id = TO_CHAR(p_source_id)
                    AND b.inspection_status_code = 'NOT INSPECTED'
                    AND b.routing_id = 2  /* Inspection routing */
                    AND a.organization_id = b.to_organization_id
                    AND a.inventory_item_id = b.item_id
                    AND a.revision = b.item_revision
                    AND a.revision LIKE (p_revision);
    END IF;
  END get_inv_inspect_revision_lov;

  PROCEDURE get_cgupdate_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    IF p_lpn_id IS NULL THEN
      OPEN x_items FOR
        SELECT DISTINCT msi.concatenated_segments concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , msi.primary_uom_code
                      , '0'
                      , NVL(shelf_life_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , NVL(msi.default_serial_status_id, 0)
                      , NVL(msi.serial_status_enabled, 'N')
                      , NVL(msi.default_lot_status_id, 0)
                      , NVL(msi.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                  FROM mtl_onhand_quantities_detail moq, mtl_system_items_vl msi -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
                  WHERE moq.containerized_flag = 2
                    AND moq.organization_id = p_org_id
                    AND moq.inventory_item_id = msi.inventory_item_id
                    AND msi.concatenated_segments LIKE (p_item||l_append)
	AND msi.organization_id = p_org_id

	--Changes for GTIN
	UNION
	        SELECT DISTINCT msi.concatenated_segments concatenated_segments
                      , moq.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , msi.primary_uom_code
                      , '0'
                      , NVL(shelf_life_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , NVL(msi.default_serial_status_id, 0)
                      , NVL(msi.serial_status_enabled, 'N')
                      , NVL(msi.default_lot_status_id, 0)
                      , NVL(msi.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(moq.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_onhand_quantities_detail moq, -- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
	mtl_system_items_vl msi, /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE moq.containerized_flag = 2
	AND moq.organization_id = p_org_id
	AND moq.inventory_item_id = msi.inventory_item_id
	AND msi.organization_id = p_org_id
	AND msi.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msi.organization_id
	     OR
	     mcr.org_independent_flag = 'Y')

	ORDER BY concatenated_segments;
     ELSE
      OPEN x_items FOR
        SELECT DISTINCT msi.concatenated_segments concatenated_segments
                      , wlc.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , msi.primary_uom_code
                      , '0'
                      , NVL(shelf_life_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , NVL(msi.default_serial_status_id, 0)
                      , NVL(msi.serial_status_enabled, 'N')
                      , NVL(msi.default_lot_status_id, 0)
                      , NVL(msi.lot_status_enabled, 'N')
                      , ''
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(wlc.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                   -- bug 5172851, wms_lpn_contents_v is replaced with
                   --              wms_lpn_contents for performance reason
                   FROM mtl_system_items_vl msi, wms_lpn_contents wlc /* Bug 5581528 */
                  WHERE msi.concatenated_segments LIKE (p_item||l_append)
                    AND msi.inventory_item_id = wlc.inventory_item_id
                    AND msi.organization_id = p_org_id
	AND wlc.parent_lpn_id = p_lpn_id

	--Changes for GTIN
	UNION

	        SELECT DISTINCT msi.concatenated_segments concatenated_segments
                      , wlc.inventory_item_id
                      , msi.description
                      , NVL(msi.revision_qty_control_code, 1)
                      , NVL(msi.lot_control_code, 1)
                      , NVL(msi.serial_number_control_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , msi.primary_uom_code
                      , '0'
                      , NVL(shelf_life_code, 1)
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , '0'
                      , NVL(msi.default_serial_status_id, 0)
                      , NVL(msi.serial_status_enabled, 'N')
                      , NVL(msi.default_lot_status_id, 0)
                      , NVL(msi.lot_status_enabled, 'N')
                      , mcr.cross_reference
                      , 'N'
                      , msi.inventory_item_flag
                      , 0
			    , wms_deploy.get_item_client_name(wlc.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
	FROM mtl_system_items_vl msi, /* Bug 5581528 */
        -- bug 5172851, wms_lpn_contents_v is replaced with
        --              wms_lpn_contents for performance reason
	wms_lpn_contents wlc,
	mtl_cross_references mcr
	WHERE msi.inventory_item_id = wlc.inventory_item_id
	AND msi.organization_id = p_org_id
	AND wlc.parent_lpn_id = p_lpn_id
	AND msi.inventory_item_id   = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference      LIKE l_cross_ref
	AND (mcr.organization_id     = msi.organization_id
	     OR
	     mcr.org_independent_flag = 'Y')
	ORDER BY concatenated_segments;
    END IF;
  END get_cgupdate_item_lov;

  PROCEDURE get_content_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_lpn_id IN VARCHAR2, p_revision IN VARCHAR2) IS
  BEGIN
    OPEN x_revs FOR
      SELECT DISTINCT wlc.revision
                    , mir.effectivity_date
                    , NVL(mir.description, '')
                 FROM mtl_item_revisions mir, wms_lpn_contents_v wlc
                WHERE wlc.organization_id = p_organization_id
                  AND wlc.inventory_item_id = TO_NUMBER(p_inventory_item_id)
                  AND NVL(wlc.parent_lpn_id, '0') = NVL(TO_NUMBER(p_lpn_id), NVL(wlc.parent_lpn_id, '0'))
                  AND mir.organization_id = wlc.organization_id
                  AND mir.inventory_item_id = wlc.inventory_item_id
                  AND mir.revision = wlc.revision
                  AND wlc.revision LIKE (p_revision);
  END get_content_revision_lov;

  PROCEDURE get_system_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    OPEN x_items FOR
      SELECT DISTINCT concatenated_segments
                    , inventory_item_id
                    , description
                    , NVL(revision_qty_control_code, 1)
                    , NVL(lot_control_code, 1)
                    , NVL(serial_number_control_code, 1)
                    , NVL(restrict_subinventories_code, 2)
                    , NVL(restrict_locators_code, 2)
                    , NVL(location_control_code, 1)
                    , primary_uom_code
                    , NVL(inspection_required_flag, 2)
                    , NVL(shelf_life_code, 1)
                    , NVL(shelf_life_days, 0)
                    , NVL(allowed_units_lookup_code, 2)
                    , NVL(effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , ''
                    , 'N'
                    , inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(GRADE_CONTROL_FLAG,'N'),
                      NVL(DEFAULT_GRADE,''),
                      NVL(EXPIRATION_ACTION_INTERVAL,0),
                      NVL(EXPIRATION_ACTION_CODE,''),
                      NVL(HOLD_DAYS,0),
                      NVL(MATURITY_DAYS,0),
                      NVL(RETEST_INTERVAL,0),
                      NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(CHILD_LOT_FLAG,'N'),
                      NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(SECONDARY_UOM_CODE,''),
                      NVL(SECONDARY_DEFAULT_IND,''),
                      NVL(TRACKING_QUANTITY_IND,'P'),
                      NVL(DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl /* Bug 5581528 */
                WHERE organization_id = p_org_id
      AND concatenated_segments LIKE (p_item||l_append)

      --Changes for GTIN
      UNION

            SELECT DISTINCT msik.concatenated_segments
                    , msik.inventory_item_id
                    , msik.description
                    , NVL(revision_qty_control_code, 1)
                    , NVL(lot_control_code, 1)
                    , NVL(serial_number_control_code, 1)
                    , NVL(restrict_subinventories_code, 2)
                    , NVL(restrict_locators_code, 2)
                    , NVL(location_control_code, 1)
                    , primary_uom_code
                    , NVL(inspection_required_flag, 2)
                    , NVL(shelf_life_code, 1)
                    , NVL(shelf_life_days, 0)
                    , NVL(allowed_units_lookup_code, 2)
                    , NVL(effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , mcr.cross_reference
                    , 'N'
                    , inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msik.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(GRADE_CONTROL_FLAG,'N'),
                      NVL(DEFAULT_GRADE,''),
                      NVL(EXPIRATION_ACTION_INTERVAL,0),
                      NVL(EXPIRATION_ACTION_CODE,''),
                      NVL(HOLD_DAYS,0),
                      NVL(MATURITY_DAYS,0),
                      NVL(RETEST_INTERVAL,0),
                      NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(CHILD_LOT_FLAG,'N'),
                      NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(SECONDARY_UOM_CODE,''),
                      NVL(SECONDARY_DEFAULT_IND,''),
                      NVL(TRACKING_QUANTITY_IND,'P'),
                      NVL(DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msik, /* Bug 5581528 */
      mtl_cross_references mcr
      WHERE msik.organization_id = p_org_id
      AND msik.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msik.organization_id
	   OR
	   mcr.org_independent_flag = 'Y');
  END get_system_item_lov;

  PROCEDURE get_serial_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_serial IN VARCHAR2, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    OPEN x_items FOR
      SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , ''
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_serial_numbers msn, mtl_system_items_vl msi /* Bug 5581528 */
                WHERE msn.current_organization_id = p_org_id
                  AND msn.serial_number = p_serial
                  AND msn.inventory_item_id = msi.inventory_item_id
                  AND msi.organization_id = msn.current_organization_id
      AND msi.concatenated_segments LIKE (p_item||l_append)

      --Changes for GTIN
      UNION

            SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , mcr.cross_reference
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_serial_numbers msn,
      mtl_system_items_vl msi, /* Bug 5581528 */
      mtl_cross_references mcr
      WHERE msn.current_organization_id = p_org_id
      AND msn.serial_number = p_serial
      AND msn.inventory_item_id = msi.inventory_item_id
      AND msi.organization_id = msn.current_organization_id
      AND msi.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msi.organization_id
	   OR
	   mcr.org_independent_flag = 'Y');

  END get_serial_item_lov;

  --"Returns"
  PROCEDURE get_return_items_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item IN VARCHAR2) IS
  l_cross_ref varchar2(204);
  l_append varchar2(2):='';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_item, '%'), g_gtin_code_length, '00000000000000');

   l_append:=wms_deploy.get_item_suffix_for_lov(p_item);

    OPEN x_items FOR
      SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , ''
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msi, wms_lpn_contents wlpnc /* Bug 5581528 */
                WHERE wlpnc.parent_lpn_id = p_lpn_id
                  AND wlpnc.source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
                  AND wlpnc.organization_id = p_org_id
                  AND msi.organization_id = wlpnc.organization_id
                  AND msi.inventory_item_id = wlpnc.inventory_item_id
                  AND msi.concatenated_segments LIKE (p_item||l_append)
      UNION
      SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , ''
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
                 FROM mtl_system_items_vl msi, mtl_serial_numbers msn /* Bug 5581528 */
                WHERE msn.lpn_id = p_lpn_id
                  AND msn.last_txn_source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
                  AND msn.current_organization_id = p_org_id
                  AND msi.organization_id = msn.current_organization_id
                  AND msi.inventory_item_id = msn.inventory_item_id
      AND msi.concatenated_segments LIKE (p_item||l_append)

      -- Changes for GTIN
      UNION

      SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , mcr.cross_reference
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msi, /* Bug 5581528 */
      wms_lpn_contents wlpnc,
      mtl_cross_references mcr
      WHERE wlpnc.parent_lpn_id = p_lpn_id
      AND wlpnc.source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
      AND wlpnc.organization_id = p_org_id
      AND msi.organization_id = wlpnc.organization_id
      AND msi.inventory_item_id = wlpnc.inventory_item_id
      AND msi.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msi.organization_id
	   OR
	   mcr.org_independent_flag = 'Y')
      UNION
      SELECT DISTINCT msi.concatenated_segments
                    , msi.inventory_item_id
                    , msi.description
                    , NVL(msi.revision_qty_control_code, 1)
                    , NVL(msi.lot_control_code, 1)
                    , NVL(msi.serial_number_control_code, 1)
                    , NVL(msi.restrict_subinventories_code, 2)
                    , NVL(msi.restrict_locators_code, 2)
                    , NVL(msi.location_control_code, 1)
                    , msi.primary_uom_code
                    , NVL(msi.inspection_required_flag, 2)
                    , NVL(msi.shelf_life_code, 1)
                    , NVL(msi.shelf_life_days, 0)
                    , NVL(msi.allowed_units_lookup_code, 2)
                    , NVL(msi.effectivity_control, 1)
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , '0'
                    , mcr.cross_reference
                    , 'N'
                    , msi.inventory_item_flag
                    , 0
			  , wms_deploy.get_item_client_name(msi.inventory_item_id),
     --Bug No 3952081
     --Additional Fields for Process Convergence
                      NVL(msi.GRADE_CONTROL_FLAG,'N'),
                      NVL(msi.DEFAULT_GRADE,''),
                      NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
                      NVL(msi.EXPIRATION_ACTION_CODE,''),
                      NVL(msi.HOLD_DAYS,0),
                      NVL(msi.MATURITY_DAYS,0),
                      NVL(msi.RETEST_INTERVAL,0),
                      NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
                      NVL(msi.CHILD_LOT_FLAG,'N'),
                      NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
                      NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
                      NVL(msi.SECONDARY_UOM_CODE,''),
                      NVL(msi.SECONDARY_DEFAULT_IND,''),
                      NVL(msi.TRACKING_QUANTITY_IND,'P'),
                      NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
                      NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
      FROM mtl_system_items_vl msi, /* Bug 5581528 */
      mtl_serial_numbers msn,
      mtl_cross_references mcr
      WHERE msn.lpn_id = p_lpn_id
      AND msn.last_txn_source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
      AND msn.current_organization_id = p_org_id
      AND msi.organization_id = msn.current_organization_id
      AND msi.inventory_item_id = msn.inventory_item_id
      AND msi.inventory_item_id   = mcr.inventory_item_id
      AND mcr.cross_reference_type = g_gtin_cross_ref_type
      AND mcr.cross_reference      LIKE l_cross_ref
      AND (mcr.organization_id     = msi.organization_id
	   OR
	   mcr.org_independent_flag = 'Y');
  END get_return_items_lov;

  PROCEDURE get_return_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_lpn_id IN VARCHAR2, p_revision IN VARCHAR2) IS
  BEGIN
    OPEN x_revs FOR
      SELECT DISTINCT wlc.revision
                    , mir.effectivity_date
                    , NVL(mir.description, '')
                 FROM mtl_item_revisions mir, wms_lpn_contents_v wlc
                WHERE wlc.organization_id = p_organization_id
                  AND wlc.inventory_item_id = TO_NUMBER(p_inventory_item_id)
                  AND NVL(wlc.parent_lpn_id, '0') = NVL(TO_NUMBER(p_lpn_id), NVL(wlc.parent_lpn_id, '0'))
                  AND wlc.source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
                  AND mir.organization_id = wlc.organization_id
                  AND mir.inventory_item_id = wlc.inventory_item_id
                  AND mir.revision = wlc.revision
                  AND wlc.revision LIKE (p_revision);
  END get_return_revision_lov;

  --"Returns"


  /* Direct Shipping */

  PROCEDURE get_vehicle_lov(x_vehicle OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2) IS
  BEGIN
    OPEN x_vehicle FOR
      SELECT   msi.concatenated_segments
             , msi.description
             , msi.inventory_item_id
          FROM mtl_system_items_vl msi /* Bug 5581528 */
         WHERE msi.organization_id = p_organization_id
           AND msi.concatenated_segments LIKE (p_concatenated_segments)
           AND msi.vehicle_item_flag = 'Y'
      ORDER BY UPPER(msi.concatenated_segments);
  END get_vehicle_lov;

  --Bug#2310308
  PROCEDURE get_direct_ship_uom_lov(x_uom OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lpn_id IN NUMBER, p_uom_text IN VARCHAR2) IS
  BEGIN
    OPEN x_uom FOR
      SELECT DISTINCT muom.uom_code
                    , muom.unit_of_measure
                    , muom.description
                    , muom.uom_class
                 FROM mtl_units_of_measure muom, wms_license_plate_numbers wlpn
                WHERE muom.uom_code LIKE (p_uom_text)
                  AND wlpn.lpn_id = p_lpn_id
                  AND muom.uom_code = wlpn.gross_weight_uom_code
      UNION
      SELECT DISTINCT muom.uom_code
                    , muom.unit_of_measure
                    , muom.description
                    , muom.uom_class
                 FROM mtl_units_of_measure muom, wsh_shipping_parameters wsp
                WHERE wsp.organization_id = p_organization_id
                  AND wsp.weight_uom_class = muom.uom_class
                  AND muom.uom_code LIKE (p_uom_text);
  END get_direct_ship_uom_lov;

  --Bug#2310308

  --Bug #2252193
  PROCEDURE get_deliver_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_po_header_id IN NUMBER, p_shipment_header_id IN NUMBER, p_revision IN VARCHAR2) IS
  BEGIN
    IF (p_shipment_header_id <> 0) THEN
      OPEN x_revs FOR
        SELECT DISTINCT miv.revision
                      , miv.effectivity_date
                      , NVL(miv.description, '')
                   FROM mtl_item_revisions miv, rcv_supply rs
                  WHERE miv.organization_id = p_organization_id
                    AND miv.inventory_item_id = p_inventory_item_id
                    AND rs.shipment_header_id(+) = p_shipment_header_id
                    AND (rs.shipment_header_id IS NULL
                         OR rs.shipment_header_id = p_shipment_header_id
                        )
                    AND rs.to_organization_id(+) = miv.organization_id
                    AND (rs.to_organization_id IS NULL
                         OR rs.to_organization_id = p_organization_id
                        )
                    AND rs.item_id(+) = miv.inventory_item_id
                    AND (rs.item_id IS NULL
                         OR rs.item_id = p_inventory_item_id
                        )
                    AND NVL(rs.item_revision, miv.revision) = miv.revision
                    AND miv.revision LIKE (p_revision);
    ELSIF (p_po_header_id <> 0) THEN
      OPEN x_revs FOR
        SELECT DISTINCT miv.revision
                      , miv.effectivity_date
                      , NVL(miv.description, '')
                   FROM mtl_item_revisions miv, rcv_supply rs
                  WHERE miv.organization_id = p_organization_id
                    AND miv.inventory_item_id = p_inventory_item_id
                    AND rs.po_header_id(+) = p_po_header_id
                    AND (rs.po_header_id IS NULL
                         OR rs.po_header_id = p_po_header_id
                        )
                    AND rs.to_organization_id(+) = miv.organization_id
                    AND (rs.to_organization_id IS NULL
                         OR rs.to_organization_id = p_organization_id
                        )
                    AND rs.item_id(+) = miv.inventory_item_id
                    AND (rs.item_id IS NULL
                         OR rs.item_id = p_inventory_item_id
                        )
                    AND NVL(rs.item_revision, miv.revision) = miv.revision
                    AND miv.revision LIKE (p_revision);
    ELSE
      get_revision_lov(x_revs, p_organization_id, p_inventory_item_id, p_revision);
    END IF;
  END get_deliver_revision_lov;

  --Bug# 2647045
FUNCTION conversion_order(p_uom_string IN VARCHAR2) RETURN NUMBER IS
   l_uom_string VARCHAR2(50);
   l_bracket_loc NUMBER;
BEGIN
   l_uom_string := p_uom_string;
   l_bracket_loc := Instr(l_uom_string,'(');
   IF l_bracket_loc IS NULL OR l_bracket_loc = 0 THEN
      RETURN 0;
   END IF;
   l_uom_string :=  Substr(l_uom_string,l_bracket_loc+1);
   l_bracket_loc := Instr(l_uom_string,' ');
   IF l_bracket_loc IS NULL OR l_bracket_loc = 0 THEN
      RETURN 0;
   END IF;
   l_uom_string := Substr(l_uom_string,1,l_bracket_loc-1);
   RETURN To_number(l_uom_string);
END;

--Bug# 2647045
FUNCTION get_conversion_rate(p_from_uom_code   varchar2,
			     p_organization_id NUMBER,
			     p_item_id         NUMBER)
  RETURN VARCHAR2 IS
     l_primary_uom_code VARCHAR2(3);
     l_conversion_rate NUMBER;
     l_return_string VARCHAR2(50);
BEGIN
   IF p_item_id IS NULL THEN
      RETURN p_from_uom_code;
    ELSE
      BEGIN
	 SELECT primary_uom_code
	   INTO l_primary_uom_code
	   FROM mtl_system_items
	  WHERE organization_id = p_organization_id
	    AND inventory_item_id = p_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    NULL;
      END;

      IF (p_from_uom_code <> l_primary_uom_code) THEN
	      inv_convert.inv_um_conversion(p_from_uom_code,
				    l_primary_uom_code,
				    p_item_id,
				    l_conversion_rate);
      ELSE
      	      l_conversion_rate := 1;
      END IF;

      IF l_conversion_rate IS NOT NULL AND l_conversion_rate > 0 THEN
	 l_return_string :=
	   p_from_uom_code||'('||To_char(TRUNC(l_conversion_rate,4))||' '||l_primary_uom_code||')';
	 RETURN l_return_string;
      END IF;
      RETURN p_from_uom_code;
   END IF;
END;

--added the procedure for handling lpn and loose in update status page for LPN status project
PROCEDURE get_ostatus_items_lov(x_items OUT NOCOPY t_genref,
                               p_organization_id IN NUMBER,
                               p_lpn IN VARCHAR2,
                               p_concatenated_segments IN VARCHAR2,
                               p_subinventory_code IN VARCHAR2,
                               p_locator_id IN NUMBER) is
l_cross_ref varchar2(204);
l_append varchar2(2):=''; -- Bug 9369327

  l_sql_stmt1     VARCHAR2(7500)
  := 'SELECT msik.concatenated_segments concatenated_segments'
      ||            ', msik.inventory_item_id'
      ||            ', msik.description'
      ||            ', NVL(msik.revision_qty_control_code, 1)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.restrict_subinventories_code, 2)'
      ||            ', NVL(msik.restrict_locators_code, 2)'
      ||            ', NVL(msik.location_control_code, 1)'
      ||            ', msik.primary_uom_code'
      ||            ', NVL(msik.inspection_required_flag, 2)'
      ||            ', NVL(msik.shelf_life_code, 1)'
      ||            ', NVL(msik.shelf_life_days, 0)'
      ||            ', NVL(msik.allowed_units_lookup_code, 2)'
      ||            ', NVL(msik.effectivity_control, 1)'
      ||            ', 0 parentlpnid'
      ||            ', 0 quantity'
      ||            ', NVL(msik.default_serial_status_id, 0)'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.default_lot_status_id, 0)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', '''''
      ||            ', ''N'''
      ||            ', msik.inventory_item_flag'
      ||            ', 0'
      ||            ', wms_deploy.get_item_client_name(msik.inventory_item_id),' -- Bug9369327
--Bug No 3952081
--Additional Fields for Process Convergence
      ||            'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
      ||            'NVL(msik.DEFAULT_GRADE,''''),'
      ||            'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
      ||            'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
      ||            'NVL(msik.HOLD_DAYS,0),'
      ||            'NVL(msik.MATURITY_DAYS,0),'
      ||            'NVL(msik.RETEST_INTERVAL,0),'
      ||            'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
      ||            'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
      ||            'NVL(msik.SECONDARY_UOM_CODE,''''),'
      ||            'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
      ||            'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';

l_sql_stmt_xref     VARCHAR2(7500)
      :=       'SELECT msik.concatenated_segments concatenated_segments'
      ||            ', msik.inventory_item_id'
      ||            ', msik.description'
      ||            ', NVL(msik.revision_qty_control_code, 1)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.restrict_subinventories_code, 2)'
      ||            ', NVL(msik.restrict_locators_code, 2)'
      ||            ', NVL(msik.location_control_code, 1)'
      ||            ', msik.primary_uom_code'
      ||            ', NVL(msik.inspection_required_flag, 2)'
      ||            ', NVL(msik.shelf_life_code, 1)'
      ||            ', NVL(msik.shelf_life_days, 0)'
      ||            ', NVL(msik.allowed_units_lookup_code, 2)'
      ||            ', NVL(msik.effectivity_control, 1)'
      ||            ', 0 parentlpnid'
      ||            ', 0 quantity'
      ||            ', NVL(msik.default_serial_status_id, 0)'
      ||            ', NVL(msik.serial_status_enabled, ''N'')'
      ||            ', NVL(msik.default_lot_status_id, 0)'
      ||            ', NVL(msik.lot_status_enabled, ''N'')'
      ||            ', mcr.cross_reference'
      ||            ', ''N'''
      ||            ', msik.inventory_item_flag'
      ||            ', 0'
      ||            ', wms_deploy.get_item_client_name(msik.inventory_item_id),' -- Bug9369327
     --Bug No 3952081
     --Additional Fields for Process Convergence
      ||            'NVL(msik.GRADE_CONTROL_FLAG,''N''),'
      ||            'NVL(msik.DEFAULT_GRADE,''''),'
      ||            'NVL(msik.EXPIRATION_ACTION_INTERVAL,0),'
      ||            'NVL(msik.EXPIRATION_ACTION_CODE,''''),'
      ||            'NVL(msik.HOLD_DAYS,0),'
      ||            'NVL(msik.MATURITY_DAYS,0),'
      ||            'NVL(msik.RETEST_INTERVAL,0),'
      ||            'NVL(msik.COPY_LOT_ATTRIBUTE_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_FLAG,''N''),'
      ||            'NVL(msik.CHILD_LOT_VALIDATION_FLAG,''N''),'
      ||            'NVL(msik.LOT_DIVISIBLE_FLAG,''Y''),'
      ||            'NVL(msik.SECONDARY_UOM_CODE,''''),'
      ||            'NVL(msik.SECONDARY_DEFAULT_IND,''''),'
      ||            'NVL(msik.TRACKING_QUANTITY_IND,''P''),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_HIGH,0),'
      ||            'NVL(msik.DUAL_UOM_DEVIATION_LOW,0)';
  BEGIN

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   l_append := wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);


IF P_LPN IS NULL THEN

   l_sql_stmt1 := l_sql_stmt1 || ' FROM mtl_system_items_vl msik, mtl_onhand_quantities_detail moqd'
                              || ' WHERE msik.concatenated_segments LIKE (''' || p_concatenated_segments ||l_append|| ''')' -- Bug 9369327

         		      || ' AND msik.organization_id = ' || p_organization_id
			            || ' AND (msik.serial_number_control_code in (1,6) OR msik.serial_status_enabled = ''Y'' )'
                     || ' AND moqd.inventory_item_id = msik.inventory_item_id '
                     || ' AND moqd.organization_id = msik.organization_id '
                     || ' AND moqd.lpn_id is NULL ' ;

   l_sql_stmt_xref := l_sql_stmt_xref || ' FROM mtl_system_items_vl msik,'
				|| 'mtl_cross_references mcr, mtl_onhand_quantities_detail moqd'
				|| ' WHERE msik.organization_id = ' || p_organization_id
				|| ' AND (msik.serial_number_control_code in (1,6) OR msik.serial_status_enabled = ''Y'' )'
				|| ' AND msik.inventory_item_id   = mcr.inventory_item_id'
				|| ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type || ''''
				|| ' AND mcr.cross_reference LIKE ''' || l_cross_ref || ''''
				|| ' AND (mcr.organization_id = msik.organization_id OR mcr.org_independent_flag = ''Y'')'
            || ' AND moqd.organization_id = msik.organization_id '
            || ' AND moqd.inventory_item_id = msik.inventory_item_id '
            || ' AND moqd.lpn_id is NULL ' ;


   IF p_subinventory_code IS NOT NULL THEN
        l_sql_stmt1 := l_sql_stmt1
				   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

        l_sql_stmt_xref := l_sql_stmt_xref
				  				   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

	IF p_locator_id IS NOT NULL AND p_locator_id <> -1 THEN

		l_sql_stmt1 := l_sql_stmt1 || ' AND moqd.locator_id = ' || p_locator_id;

		l_sql_stmt_xref := l_sql_stmt_xref || ' AND moqd.locator_id = ' || p_locator_id;
	END IF;
   END IF;
ELSE
   l_sql_stmt1 := l_sql_stmt1 || ' FROM mtl_system_items_vl msik, mtl_onhand_quantities_detail moqd ,WMS_LICENSE_PLATE_NUMBERS WLPN ,WMS_LPN_CONTENTS WLC'
                              || ' WHERE WLPN.LICENSE_PLATE_NUMBER = ''' || p_lpn || ''''
                              || ' AND WLC.PARENT_LPN_ID =  WLPN.LPN_ID '
                              || ' AND MSIK.INVENTORY_ITEM_ID = WLC.INVENTORY_ITEM_ID '
                              || ' AND msik.concatenated_segments LIKE (''' || p_concatenated_segments ||l_append|| ''')' -- Bug 9369327
                  		      || ' AND msik.organization_id = ' || p_organization_id
			                     || ' AND (msik.serial_number_control_code in (1,6) OR msik.serial_status_enabled = ''Y'' )'
                              || ' AND moqd.organization_id = msik.organization_id'
                              || ' AND moqd.inventory_item_id = msik.inventory_item_id';

   l_sql_stmt_xref := l_sql_stmt_xref || ' FROM mtl_system_items_vl msik,'
				|| 'mtl_cross_references mcr, mtl_onhand_quantities_detail moqd ,WMS_LICENSE_PLATE_NUMBERS WLPN ,WMS_LPN_CONTENTS WLC'
				|| ' WHERE WLPN.LICENSE_PLATE_NUMBER = ''' || p_lpn || ''''
            || ' AND WLC.PARENT_LPN_ID =  WLPN.LPN_ID '
            || ' AND MSIK.INVENTORY_ITEM_ID = WLC.INVENTORY_ITEM_ID '
            || ' AND msik.organization_id = ' || p_organization_id
				|| ' AND (msik.serial_number_control_code in (1,6) OR msik.serial_status_enabled = ''Y'' )'
				|| ' AND msik.inventory_item_id   = mcr.inventory_item_id'
				|| ' AND mcr.cross_reference_type = ''' || g_gtin_cross_ref_type || ''''
				|| ' AND mcr.cross_reference LIKE ''' || l_cross_ref || ''''
				|| ' AND (mcr.organization_id = msik.organization_id OR mcr.org_independent_flag = ''Y'')'
            || ' AND moqd.organization_id = msik.organization_id'
            || ' AND moqd.inventory_item_id = msik.inventory_item_id';


       l_sql_stmt1 := l_sql_stmt1

				   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

        l_sql_stmt_xref := l_sql_stmt_xref
				  	   || ' AND moqd.subinventory_code = ''' || p_subinventory_code || '''';

		l_sql_stmt1 := l_sql_stmt1 || ' AND moqd.locator_id = ' || p_locator_id;

		l_sql_stmt_xref := l_sql_stmt_xref || ' AND moqd.locator_id = ' || p_locator_id;


END IF;
   l_sql_stmt1 := l_sql_stmt1 || ' UNION ' || l_sql_stmt_xref || ' ORDER BY concatenated_segments';

   --dbms_output.put_line(l_sql_stmt1);
 OPEN x_items FOR l_sql_stmt1;
END get_ostatus_items_lov;

END inv_ui_item_lovs;

/
