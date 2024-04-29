--------------------------------------------------------
--  DDL for Package Body INV_DIAG_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_ITEM" as
/* $Header: INVDI01B.pls 120.0.12000000.1 2007/06/22 00:51:51 musinha noship $ */

PROCEDURE init is
BEGIN
-- test writer
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB) IS
  reportStr LONG;
  counter NUMBER;
  dummy_v2t JTF_DIAGNOSTIC_COREAPI.v2t;
  c_userid VARCHAR2(50);
  statusStr VARCHAR2(50);
  errStr VARCHAR2(4000);
  fixInfo VARCHAR2(4000);
  isFatal VARCHAR2(50);
  dummy_num NUMBER;
  sqltxt VARCHAR2 (9999);
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_txn_id   NUMBER;
  item_err   NUMBER := 0 ;
  l_count  NUMBER;
  l_row_limit NUMBER;
  l_resp       fnd_responsibility_tl.Responsibility_Name%type :='Inventory';

  CURSOR c_item_valid (cp_n_item_id IN NUMBER, cp_n_org_id IN NUMBER) IS
    SELECT count(*)
    FROM   mtl_system_items_b
    WHERE  organization_id = cp_n_org_id
    AND    inventory_item_id = cp_n_item_id;

  CURSOR c_item_info (cp_n_item_id IN NUMBER, cp_n_org_id IN NUMBER) IS
    SELECT *
    FROM   mtl_system_items_b
    WHERE  organization_id = cp_n_org_id
    AND    inventory_item_id = cp_n_item_id;

  l_item c_item_info%ROWTYPE;

BEGIN

  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

   /* -- check whether user has 'Inventory' responsibilty to execute diagnostics script.
   IF NOT INV_DIAG_GRP.check_responsibility(p_responsibility_name => l_resp) THEN  -- l_resp = 'Inventory'
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' You do not have the privilege to run this Diagnostics.');
      statusStr := 'FAILURE';
      errStr := 'This test requires Inventory Responsibility Role';
      fixInfo := 'Please contact your sysadmin to get Inventory Responsibility';
      isFatal := 'FALSE';
      report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      RETURN;
   END IF; */

  l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);
  l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
  l_count := 0 ;
  l_row_limit := INV_DIAG_GRP.g_max_row;

  IF l_item_id IS NOT NULL AND l_org_id IS NOT NULL THEN
     OPEN c_item_valid (l_item_id, l_org_id);
     FETCH c_item_valid INTO l_count;
     CLOSE c_item_valid;
  END IF;

  IF l_count IS NULL OR l_count <> 1 THEN
      JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Item and Organization Combination');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Invalid Input Arguments');
      statusStr := 'FAILURE';
      errStr := 'Invalid Item and Organization Combination';
      fixInfo := 'Please enter right combination of Item and Organization';
      isFatal := 'FALSE';
      report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      RETURN;
  END IF;

  INV_DIAG_GRP.g_inv_diag_item_tbl.delete;
  INV_DIAG_GRP.g_inv_diag_item_tbl(1).inventory_item_id :=l_item_id;
  INV_DIAG_GRP.g_inv_diag_item_tbl(1).org_id := l_org_id;

  -- Collect the item informatation in a local variable
  OPEN c_item_info (l_item_id, l_org_id);
  FETCH c_item_info INTO l_item;
  CLOSE c_item_info;


   if INV_DIAG_GRP.g_grp_name is null then    --standard alone test for item
--fnd_file.put_line(fnd_file.log,'@@@ item grp null');
       sqltxt := 'SELECT language "Language" '||
                 ', description "Description"  '||
                 ', long_description "Long Description" '||
                 ' FROM mtl_system_items_tl '||
                 ' WHERE organization_id = '||l_org_id||
                 ' AND inventory_item_id = '||l_item_id||
                 ' ORDER BY language';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item descriptions in all installed languages');

       sqltxt := 'SELECT mp.organization_code||'' (''||mp.organization_id||'')'' "Organization|Code (Id)" '||
                 ',mpm.organization_code||'' (''||mp.master_organization_id||'' )'' "Master Org| Code (Id)" '||
                 ',mpc.organization_code||'' (''||mp.cost_organization_id||'' )''  "Cost Org|Code (Id)"  '||
                 ',mp.wms_enabled_flag "WMS|Enabled"  '||
                 ',DECODE(mp.negative_inv_receipt_code,1,''Yes'', ''No'') "Negative|Balances|Allowed"  '||
                 ',DECODE(mp.serial_number_generation,1,''At organization level'',  2,''At item level'', 3,''User Defined'', '||
                 '        mp.serial_number_generation) "Serial Number|Generation"  '||
                 ',DECODE(mp.lot_number_uniqueness,1,''Unique for item'', 2,''No uniqueness'',  mp.lot_number_uniqueness) "Lot Number|Uniqueness"   '||
                 ',DECODE(mp.lot_number_generation,1,''At organization level'', 2,''At item level'',   3,''User Defined'',  '||
                 '        mp.lot_number_generation) "Lot Number Generation"  '||
                 ',DECODE(mp.serial_number_type,1,''Unique within inventory items'', 2,''Unique within organization'',   3,''Unique across organizations'',  '||
                 '        mp.serial_number_type) "Serial Number Type"  '||
                 ',DECODE(mp.stock_locator_control_code,1,''None'', 2,''Prespecified'',  3,''Dynamic entry'',   4,''At subinventory level'',  5,''At item level'',  '||
                 '        mp.stock_locator_control_code) "Locator|Control"  '||
                 ',DECODE(mp.primary_cost_method,1,''Standard'', 2,''Average'', 3,''Periodic Average'',4,''Periodic Incremental LIFO'', 5,''FIFO'',  6,''LIFO'', mp.primary_cost_method) "Primary Cost Method" '||
                 ',mp.default_cost_group_id "Default|Cost Group|Id"  '||
                 ',mp.wsm_enabled_flag "WSM|Enabled"  '||
                 ',mp.process_enabled_flag "Process|Enabled"  '||
                 ',DECODE( TO_CHAR( NVL(mp.project_reference_enabled, 2)),''1'', ''Yes'', ''2'', ''No'' , TO_CHAR( mp.project_reference_enabled ) )|| '' ('' ||mp.project_reference_enabled||'')'' "Project Reference Enabled" '||
                 ' FROM mtl_parameters mp '||
                 ',mtl_parameters mpc '||
                 ',mtl_parameters mpm  '||
                 'WHERE mp.cost_organization_id=mpc.organization_id  '||
                 'AND mp.master_organization_id=mpm.organization_id  '||
                 'AND mp.organization_id IN (SELECT organization_id  '||
                 '                     FROM mtl_system_items_b  '||
                 '                     WHERE inventory_item_id='||l_item_id||' )';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Inventory organization information ');
       sqltxt :='SELECT user_group_name "Group" '||
                ', user_attribute_name "Attribute Name" '||
                ', control_level_dsp "Controlled at" '||
                ', user_attribute_value "Attribute Value" '||
                'FROM mtl_item_attribute_values_v '||
                'WHERE organization_id = '||l_org_id||
                'AND inventory_item_id = '||l_item_id||
                'ORDER BY user_group_name, user_attribute_name';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item attribute values');

       -- displaying restricted subinventory information when the item is restricted pre-defined list of subinventories
       IF NVL(l_item.restrict_subinventories_code,1) = 1 THEN

           sqltxt :='SELECT msi.secondary_inventory_name "Name"   ' ||
                    ', msi.description "Description"   ' ||
                    ', TO_CHAR( msi.disable_date, ''DD-Mon-RR'' ) "Disable|Date"   ' ||
                    ', DECODE( msi.reservable_type, 1, ''Yes'', 2, ''No'',   ' ||
                    '          msi.reservable_type) "Reservable|Type"   ' ||
                    ', DECODE( msi.locator_type  ' ||
                    '              ,1, ''None''  ' ||
                    '              ,2, ''Prespecified''   ' ||
                    '              ,3, ''Dynamic''   ' ||
                    '              ,4, ''SubInv Level''   ' ||
                    '              ,5, ''Item Level'', msi.locator_type)  ' ||
                    '   || '' (''||msi.locator_type||'')'' "Locator|Control"  ' ||
                    ', DECODE( msi.availability_type, 1, ''Nettable''  ' ||
                    '                                ,2, ''Non-Nettable''  ' ||
                    '         ,msi.availability_type ) "Availability|Type"  ' ||
                    ', DECODE( msi.inventory_atp_code, 1, ''Included''  ' ||
                    '                                , 2, ''Not included''  ' ||
                    '        , msi.inventory_atp_code ) "Include|in ATP"  ' ||
                    ', DECODE( msi.asset_inventory, 1, ''Yes'', 2, ''No'',  ' ||
                    '          msi.asset_inventory ) "Asset|Inventory"  ' ||
                    ', DECODE( msi.quantity_tracked, 1, ''Yes'', 2, ''No'',  ' ||
                    '          msi.quantity_tracked ) "Quantity|Tracked"   ' ||
                    ', msi.picking_order "Picking|Order"   ' ||
                    ', DECODE( msi.source_type, 1,''Inventory''  ' ||
                    '                         , 2,''Supplier''  ' ||
                    '                         , 3,''Subinventory''  ' ||
                    '        , msi.source_type )   ' ||
                    '   || '' ( ''||msi.source_type||'')'' "Source|Type"  ' ||
                    ', default_cost_group_id "Default|Cost Group Id"  ' ||
                    ' FROM mtl_secondary_inventories msi  ' ||
                    ' WHERE (msi.organization_id, msi.secondary_inventory_name ) IN ' ||
                      '( SELECT misi.organization_id, misi.secondary_inventory ' ||
                      ' FROM mtl_item_sub_inventories misi ' ||
                      ' WHERE misi.organization_id =' ||l_org_id ||
                      ' AND inventory_item_id ='||l_item_id || ')' ;

           dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Subinventories the item is restricted to');

       END IF;

       sqltxt :='SELECT msi.secondary_inventory_name "Name"   ' ||
                ', msi.description "Description"   ' ||
                ', TO_CHAR( msi.disable_date, ''DD-Mon-RR'' ) "Disable|Date"   ' ||
                ', DECODE( msi.reservable_type, 1, ''Yes'', 2, ''No'',   ' ||
                '          msi.reservable_type) "Reservable|Type"   ' ||
                ', DECODE( msi.locator_type  ' ||
                '              ,1, ''None''  ' ||
                '              ,2, ''Prespecified''   ' ||
                '              ,3, ''Dynamic''   ' ||
                '              ,4, ''SubInv Level''   ' ||
                '              ,5, ''Item Level'', msi.locator_type)  ' ||
                '   || '' (''||msi.locator_type||'')'' "Locator|Control"  ' ||
                ', DECODE( msi.availability_type, 1, ''Nettable''  ' ||
                '                                ,2, ''Non-Nettable''  ' ||
                '         ,msi.availability_type ) "Availability|Type"  ' ||
                ', DECODE( msi.inventory_atp_code, 1, ''Included''  ' ||
                '                                , 2, ''Not included''  ' ||
                '        , msi.inventory_atp_code ) "Include|in ATP"  ' ||
                ', DECODE( msi.asset_inventory, 1, ''Yes'', 2, ''No'',  ' ||
                '          msi.asset_inventory ) "Asset|Inventory"  ' ||
                ', DECODE( msi.quantity_tracked, 1, ''Yes'', 2, ''No''  ' ||
                '        , msi.quantity_tracked ) "Quantity|Tracked"   ' ||
                ', msi.picking_order "Picking|Order"   ' ||
                ', DECODE( msi.source_type, 1,''Inventory''  ' ||
                '                         , 2,''Supplier''  ' ||
                '                         , 3,''Subinventory''  ' ||
                '        , msi.source_type )   ' ||
                '   || '' ( ''||msi.source_type||'')'' "Source|Type"  ' ||
                ', default_cost_group_id "Default|Cost Group Id"  ' ||
                ' FROM mtl_secondary_inventories msi  ' ||
                ' WHERE (msi.organization_id, msi.secondary_inventory_name ) IN ' ||
                    '( SELECT DISTINCT moq.organization_id, moq.subinventory_code' ||
                    ' FROM mtl_onhand_quantities_detail moq' ||
                    ' WHERE moq.organization_id = '|| l_org_id ||
                    ' AND moq.inventory_item_id = '|| l_item_id ||')' ||
                ' ORDER BY msi.secondary_inventory_name';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Onhand Subinventory Information ');

       sqltxt := ' SELECT micv.category_set_name "Category Set"   ' ||
                 ' , micv.category_set_id "Category Set Id"   ' ||
                 ' , DECODE( micv.control_level, 1, ''Master'', 2, ''Org'', micv.control_level )  ' ||
                 ' "Control Level"   ' ||
                 ' , micv.category_concat_segs "Category"   ' ||
                 ' , micv.category_id "Category Id"   ' ||
                 ' FROM mtl_item_categories_v micv  ' ||
                 ' WHERE micv.organization_id = '|| l_org_id  ||
                 ' AND micv.inventory_item_id = '|| l_item_id;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item categories');

       sqltxt :=' SELECT micgv.concatenated_segments "Group Name"  ' ||
                ' , msi.item_catalog_group_id "Group id"   ' ||
                ' , micgv.description "Description"  ' ||
                ' , TO_CHAR( micgv.start_date_active, ''DD-MON-RR'' ) "Start Date Active"  ' ||
                ' , TO_CHAR( micgv.end_date_active, ''DD-MON-RR'' ) "End Date Active"  ' ||
                ' , TO_CHAR( micgv.inactive_date, ''DD-MON-RR'' ) "Inactive Date"  ' ||
                ' FROM mtl_system_items_b msi   ' ||
                ' , mtl_item_catalog_groups_kfv micgv ' ||
                ' WHERE msi.organization_id ='|| l_org_id  ||
                ' AND inventory_item_id = '|| l_item_id  ||
                ' AND msi.item_catalog_group_id = micgv.item_catalog_group_id ' ||
                ' ORDER BY 1,2';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Catalogs item assigned to');

       sqltxt :=' SELECT mdev.element_sequence "Element|Sequence"  ' ||
                ' , mdev.element_name "Element Name"  ' ||
                ' , mdev.element_value "Element Value"  ' ||
                ' , mde.description "Description"  ' ||
                ' , mde.required_element_flag "Required"   ' ||
                ' , mde.default_element_flag "Defaulted"   ' ||
                ' FROM mtl_descriptive_elements mde  ' ||
                ' , mtl_descr_element_values mdev  ' ||
                ' , mtl_system_items_b msi  ' ||
                ' WHERE msi.organization_id = '|| l_org_id  ||
                ' AND msi.inventory_item_id = '|| l_item_id  ||
                ' AND msi.inventory_item_id = mdev.inventory_item_id   ' ||
                ' AND mde.item_catalog_group_id = msi.item_catalog_group_id  ' ||
                ' AND mde.element_name = mdev.element_name  ' ||
                ' AND mdev.element_value IS NOT NULL ' ||
                ' ORDER BY mdev.element_sequence';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Catalog descriptive elements');

       -- Displaying serial information only for serial conrolled item
       IF NVL(l_item.serial_number_control_code,2) <> 1 THEN

	  sqltxt := 'SELECT * FROM (  ' ||
                      ' SELECT msn.serial_number "Serial|Number"   ' ||
                      ' , ml.meaning || '' ( '' || msn.current_status || '' )''   ' ||
                      '     "Current Status (Id)"   ' ||
                      ' , msn.current_subinventory_code "Current|Subinventory"   ' ||
                      ' , msn.current_locator_id "Current|Locator Id"   ' ||
                      ' , msn.cost_group_id "Cost Group|Id"   ' ||
                      ' , msn.lpn_id "LPN Id"   ' ||
                      ' , msn.group_mark_id "Group Mark|Id"   ' ||
                      ' , msn.line_mark_id "Line Mark|Id"   ' ||
                      ' , msn.lot_line_mark_id "Lot Line Mark|Id"  ' ||
                      ' , TO_CHAR( msn.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last|Updated"  ' ||
                      ' FROM mtl_serial_numbers msn  ' ||
                      ' , mfg_lookups ml   ' ||
                      ' WHERE msn.current_organization_id = '|| l_org_id    ||
                      ' AND msn.inventory_item_id = '|| l_item_id  ||
                      ' AND msn.current_status = ml.lookup_code(+)   ' ||
                      ' AND ''SERIAL_NUM_STATUS'' = ml.lookup_type(+)   ' ||
                      ' ORDER BY msn.last_update_date DESC ' ||
                    ' ) WHERE ROWNUM <= ' || l_row_limit ;

          dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Serial number');

       END IF;

       -- Displaying item revision only for revision controlled item
       IF NVL(l_item.revision_qty_control_code,2) <> 1  THEN

	   sqltxt := ' SELECT * FROM (   ' ||
                        ' SELECT revision "Revision"  ' ||
                        ' , TO_CHAR( creation_date, ''DD-MON-RR HH24:MI'' ) "Creation Date"   ' ||
                        ' , change_notice "ECO Name"   ' ||
                        ' , TO_CHAR( implementation_date, ''DD-MON-RR HH24:MI'' ) "Implementation Date"  ' ||
                        ' , TO_CHAR( effectivity_date, ''DD-MON-RR HH24:MI'' ) "Effectivity Date"   ' ||
                        ' FROM mtl_item_revisions   ' ||
                        ' WHERE organization_id = '|| l_org_id   ||
                        ' AND inventory_item_id = '|| l_item_id  ||
                        ' ORDER BY revision ' ||
                      ' ) WHERE ROWNUM <= ' || l_row_limit ;

          dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item revisions');

       END IF;

       -- Displaying lot information only for lote controlled item
       IF NVL(l_item.lot_control_code,2) <> 1 THEN

	  sqltxt :=' SELECT * FROM (  ' ||
                     ' SELECT lot_number "Lot Number"   ' ||
                     ', status_code ||'' (''|| status_id ||'')'' "Status (Id)"   ' ||
                     ', TO_CHAR( expiration_date, ''DD-MON-RR HH24:MI'' ) "Expiration Date"   ' ||
                     ', DECODE( disable_flag, 1, ''Yes'', 2, ''No'', disable_flag ) "Disabled"  ' ||
                     ', description "Description"  ' ||
                     ' FROM mtl_lot_numbers_all_v  ' ||
                     ' WHERE organization_id = '|| l_org_id    ||
                     ' AND inventory_item_id = '|| l_item_id ||
                     ' ORDER BY lot_number ' ||
                   ' ) WHERE ROWNUM <= ' || l_row_limit ;

	  dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Lot Number' );

       END IF;

       sqltxt := 'SELECT subinventory_code "Subinventory"   ' ||
                 ' , DECODE( default_type, 1, ''Shipping'', 2, ''Receiving'', 3, ''Move Order Receipt''  ' ||
                 ' , default_type )  ' ||
                 ' ||'' (''||default_type||'')'' "Default Type"   ' ||
                 ' , TO_CHAR( last_update_date, ''DD-MON-RR'' ) "Last updated"  ' ||
                 ' FROM mtl_item_sub_defaults   ' ||
                 ' WHERE organization_id = '|| l_org_id    ||
                 ' AND inventory_item_id = '|| l_item_id  ||
                 ' ORDER BY subinventory_code, default_type';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item transactions defaults: subinventory' );

       sqltxt := 'SELECT mild.subinventory_code "Subinventory"   ' ||
                 ' , milv.concatenated_segments "Locator"  ' ||
                 ' , milv.inventory_location_id "Locator Id"  ' ||
                 ' , DECODE( default_type,  1, ''Shipping'', 2, ''Receiving'', 3, ''Move Order Receipt''  ' ||
                 '         , default_type )  ' ||
                 '    ||'' (''||default_type||'')'' "Default Type"  ' ||
                 ' , TO_CHAR( disable_date, ''DD-MON-RR'' ) "Disable Date"  ' ||
                 ' , TO_CHAR( mild.last_update_date, ''DD-MON-RR'' ) "Last updated"  ' ||
                 ' FROM mtl_item_loc_defaults mild   ' ||
                 ' , mtl_item_locations_kfv milv   ' ||
                 ' WHERE mild.organization_id = '|| l_org_id   ||
                 ' AND mild.inventory_item_id = '|| l_item_id ||
                 ' AND mild.organization_id = milv.organization_id   ' ||
                 ' AND mild.locator_id = milv.inventory_location_id  ' ||
                 ' ORDER BY mild.subinventory_code, milv.concatenated_segments' ;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item transactions defaults:  locators');

       sqltxt := ' SELECT mif.item_number "Item"  ' ||
                 ' , moq.inventory_item_id "Item Id"  ' ||
                 ' , SUM( moq.transaction_quantity ) "Txn Qty"  ' ||
                 ' , moq.subinventory_code "Subinv"  ' ||
                 ' , moq.locator_id "Locator Id"  ' ||
                 ' , mil.concatenated_segments "Locator"  ' ||
                 ' , mil.description "Locator Desc"  ' ||
                 ' , moq.revision "Revision"  ' ||
                 ' , moq.lot_number "Lot Number"  ' ||
                 ' FROM mtl_onhand_quantities_detail moq  ' ||
                 ' , mtl_item_flexfields mif  ' ||
                 ' , mtl_item_locations_kfv mil  ' ||
                 ' WHERE moq.organization_id = ' || l_org_id  ||
                 ' AND moq.inventory_item_id = ' || l_item_id ||
                 ' AND moq.inventory_item_id = mif.inventory_item_id(+)  ' ||
                 ' AND moq.organization_id = mif.organization_id(+)  ' ||
                 ' AND moq.organization_id = mil.organization_id(+)  ' ||
                 ' AND moq.locator_id = mil.inventory_location_id(+)  ' ||
                 ' GROUP BY mif.item_number, moq.inventory_item_id  ' ||
                 ' , moq.subinventory_code, moq.locator_id  ' ||
                 ' , mil.concatenated_segments, mil.description  ' ||
                 ' , moq.revision, moq.lot_number  ' ||
                 ' ORDER BY mif.item_number, moq.inventory_item_id  ' ||
                 ' , moq.subinventory_code, moq.locator_id  ' ||
                 ' , mil.concatenated_segments, mil.description  ' ||
                 ' , moq.revision, moq.lot_number ';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item Onhand Quantity');

       sqltxt := ' SELECT * FROM (  ' ||
                   ' SELECT TO_CHAR( requirement_date, ''DD-MON-RR'' ) "REQUIREMENT_DATE"  ' ||
                   ' , reservation_id  ' ||
                   ' , reservation_quantity  ' ||
                   ' , primary_reservation_quantity  ' ||
                   ' , detailed_quantity  ' ||
                   ' , demand_source_type_id  ' ||
                   ' , demand_source_name  ' ||
                   ' , demand_source_header_id  ' ||
                   ' , demand_source_line_id  ' ||
                   ' , demand_source_delivery  ' ||
                   ' , revision  ' ||
                   ' , subinventory_code  ' ||
                   ' , locator_id  ' ||
                   ' , lot_number "LOT|NUMBER"  ' ||
                   ' , serial_number "SERIAL|NUMBER"  ' ||
                   ' , lpn_id  ' ||
                   ' , TO_CHAR( creation_date, ''DD-MON-RR'' ) "CREATION_DATE"  ' ||
                   ' , TO_CHAR( last_update_date, ''DD-MON-RR'' ) "LAST_UPDATE_DATE"  ' ||
                   ' FROM mtl_reservations   ' ||
                   ' WHERE organization_id = ' || l_org_id  ||
                   ' AND inventory_item_id = ' || l_item_id ||
                   ' ORDER BY requirement_date DESC ' ||
             ' ) WHERE ROWNUM <=   ' || l_row_limit ;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item Reservations');

       sqltxt := ' SELECT demand_id  ' ||
                 ' , demand_source_name  ' ||
                 ' , inventory_item_id  ' ||
                 ' , line_item_quantity  ' ||
                 ' , line_item_reservation_qty  ' ||
                 ' , reservation_quantity  ' ||
                 ' , primary_uom_quantity  ' ||
                 ' , requirement_date  ' ||
                 ' , revision  ' ||
                 ' , subinventory  ' ||
                 ' , locator_id  ' ||
                 ' , lot_number "LOT|NUMBER"  ' ||
                 ' , serial_number  ' ||
                 ' , TO_CHAR( creation_date, ''DD-MON-RR'' ) "creation_date"  ' ||
                 ' , TO_CHAR( last_update_date, ''DD-MON-RR'' ) "last_update_date"  ' ||
                 ' FROM mtl_demand  ' ||
                 ' WHERE organization_id = ' || l_org_id  ||
                 ' AND inventory_item_id = ' || l_item_id ||
                 ' ORDER BY requirement_date ';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item Demand');

                 -- intentionally not joining to MIF due ot performance
       sqltxt := ' SELECT * FROM ( ' ||
                   ' SELECT mtiv.transaction_interface_id "Transaction|Interface Id"  ' ||
                   ' , mtiv.item_segment1 "Item" ' ||
                   ' , mtiv.inventory_item_id "Item Id"  ' ||
                   ' , mttv.transaction_type_name  ' ||
                   ' ||'' (''||mtiv.transaction_type_id||'')'' "Transaction|Type Name (Id)"  ' ||
                   ' , mtiv.transaction_quantity "Transaction|Quantity"   ' ||
                   ' , mtiv.transaction_mode_desc||'' ('' ||transaction_mode || '')'' "Transaction|Mode"  ' ||
                   ' , mtiv.process_flag_desc||'' ('' ||mtiv.process_flag || '')'' "Process|Flag"  ' ||
                   ' , lock_flag_desc||'' ('' || lock_flag || '')'' "Lock|Flag"  ' ||
                   ' , TO_CHAR( mtiv.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last updated"  ' ||
                   ' , mtiv.error_code "Error Code"  ' ||
                   ' , error_explanation "Error Explanation"              ' ||
                   ' FROM mtl_transactions_interface_v mtiv   ' ||
                   ' , mtl_trx_types_view mttv   ' ||
                   ' WHERE mtiv.organization_id = ' || l_org_id  ||
                   ' AND mtiv.inventory_item_id = ' || l_item_id ||
                   ' AND mtiv.transaction_type_id = mttv.transaction_type_id ' ||
                 ' ) WHERE ROWNUM <= ' || l_row_limit ;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item transactions at Interface');

       sqltxt := ' SELECT * FROM (   ' ||
                   ' SELECT transaction_header_id "Txn|Header Id"  ' ||
                   ' ,transaction_temp_id "Txn|Temp Id"  ' ||
                   ' ,TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Transaction|Date"  ' ||
                   ' ,DECODE(transaction_mode,1,''Online'' ' ||
                              ' ,2,''Concurrent'' ' ||
                              ' ,3,''Background'' ' ||
                              ' ,transaction_mode)  ' ||
                              ' ||'' (''||transaction_mode||'')'' "Transaction|Mode"  ' ||
                   ' ,DECODE(transaction_status,1,''Pending'' ' ||
                              ' ,2,''Allocated'' ' ||
                              ' ,3,''Pending'' ' ||
                              ' ,NULL,''Pending''  ' ||
                              ' ,transaction_status)  ' ||
                              ' ||'' (''||transaction_status||'')'' "Transaction|Status"  ' ||
                   ' ,process_flag "Process|Flag"  ' ||
                   ' ,lock_flag "Lock|Flag"  ' ||
                   ' ,error_code ' ||
                   ' ,error_explanation ' ||
                   ' ,TO_CHAR( mmtt.last_update_date, ''DD-MON-RR HH24:MI'') "Last Updated"  ' ||
                   ' ,mif.item_number ' ||
                   ' ||'' (''||mmtt.inventory_item_id||'')'' "Item (Id)"  ' ||
                   ' ,item_description "Item Description"  ' ||
                   ' ,revision "Rev" ' ||
                   ' ,lot_number "Lot" ' ||
                   ' ,serial_number "Serial|Number"  ' ||
                   ' ,mmtt.cost_group_id "Cost|Group Id"  ' ||
                   ' ,mmtt.subinventory_code "Subinv"  ' ||
                   ' ,mil.description  ' ||
                   ' ||'' (''||mmtt.locator_id||'') '' "Stock|Locator (Id)"  ' ||
                   ' ,transfer_subinventory "Transfer|Subinv"  ' ||
                   ' ,transfer_to_location "Transfer|Location"  ' ||
                   ' ,transaction_quantity "Txn Qty" ' ||
                   ' ,primary_quantity "Primary|Qty" ' ||
                   ' ,transaction_uom "Txn|UoM"  ' ||
                   ' ,mtt.transaction_type_name  ' ||
                   ' ||'' (''||mmtt.transaction_type_id||'')'' "Txn Type (Id)"  ' ||
                   ' ,ml.meaning  ' ||
                   ' ||'' (''||mmtt.transaction_action_id||'')'' "Txn Action Type (Id)"  ' ||
                   ' FROM mtl_material_transactions_temp mmtt ' ||
                   ' ,mtl_transaction_types mtt ' ||
                   ' ,mtl_item_flexfields mif ' ||
                   ' ,mfg_lookups ml ' ||
                   ' ,mtl_item_locations_kfv mil ' ||
                   ' WHERE mmtt.organization_id = ' || l_org_id  ||
                   ' AND mmtt.inventory_item_id = ' || l_item_id ||
                   ' AND mmtt.transaction_type_id=mtt.transaction_type_id ' ||
                   ' AND mmtt.organization_id=mif.organization_id(+) ' ||
                   ' AND mmtt.inventory_item_id=mif.inventory_item_id(+) ' ||
                   ' AND mmtt.transaction_action_id=ml.lookup_code ' ||
                   ' AND ml.lookup_type=''MTL_TRANSACTION_ACTION'' ' ||
                   ' AND mmtt.locator_id=mil.inventory_location_id(+) ' ||
                   ' AND mmtt.organization_id=mil.organization_id(+) ' ||
                   ' ORDER BY 1,2 ' ||
                 ' ) WHERE ROWNUM <= ' || l_row_limit ;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Pending Item Transactions ');

       sqltxt := ' SELECT * FROM (   ' ||
                   ' SELECT mmt.transaction_id "Txn Id"  ' ||
                   ' , TO_CHAR( mmt.transaction_date, ''DD-MON-RR'' ) "Txn Date"  ' ||
                   ' , mmt.acct_period_id "Account|Period Id"  ' ||
                   ' , mmt.transaction_quantity "Txn Qty"  ' ||
                   ' , mmt.primary_quantity "Pri Qty"  ' ||
                   ' , mmt.transaction_uom "Uom"  ' ||
                   ' , tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"  ' ||
                   ' , mmt.subinventory_code "Subinv"  ' ||
                   ' , mmt.locator_id "Locator|Id"  ' ||
                   ' , mmt.revision "Rev"  ' ||
                   ' , mmt.distribution_account_id "Distribution|Account Id"  ' ||
                   ' , mmt.costed_flag "Costed|Flag"  ' ||
                   ' , mmt.shipment_costed "Shipment|Costed"  ' ||
                   ' , mmt.cost_group_id "Cost Group|Id"  ' ||
                   ' , mmt.transfer_cost_group_id "Transfer|Cost Group Id"  ' ||
                   ' , mmt.transaction_group_id "Txn Group Id"  ' ||
                   ' , mmt.transaction_set_id "Txn Set Id"  ' ||
                   ' , mmt.transaction_action_id "Txn Action Id"  ' ||
                   ' , mmt.completion_transaction_id "Completion|Txn Id"  ' ||
                   ' , st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"  ' ||
                   ' , mmt.transaction_source_id "Txn Source Id"  ' ||
                   ' , mmt.transaction_source_name "Txn Source"   ' ||
                   ' , mmt.source_code "Source|Code"  ' ||
                   ' , mmt.source_line_id "Source|Line Id"  ' ||
                   ' , mmt.request_id "Txn|Request Id"  ' ||
                   ' , mmt.operation_seq_num "Operation|Seq Num"              ' ||
                   ' , mmt.transfer_transaction_id "Transfer|Txn Id"  ' ||
                   ' , mmt.move_transaction_id "Move|Txn Id"  ' ||
                   ' , mmt.transfer_organization_id "Transfer|Organization Id"  ' ||
                   ' , mmt.transfer_subinventory "Transfer|Subinv"  ' ||
                   ' , mmt.shipment_number "Shipment|Number"  ' ||
                   ' , TO_CHAR( mmt.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last updated"  ' ||
                   ' , mmt.error_code "Error Code"  ' ||
                   ' , mmt.error_explanation "Error Explanation"  ' ||
                   ' FROM mtl_material_transactions mmt  ' ||
                   ' , mtl_transaction_types tt  ' ||
                   ' , mtl_txn_source_types st  ' ||
                   ' WHERE mmt.organization_id = ' || l_org_id  ||
                   ' AND mmt.inventory_item_id = ' || l_item_id ||
                   ' AND mmt.costed_flag IS NOT NULL ' ||
                   ' AND mmt.transaction_type_id = tt.transaction_type_id(+)  ' ||
                   ' AND mmt.transaction_source_type_id = st.transaction_source_type_id(+)  ' ||
                   ' ORDER BY mmt.transaction_id ' ||
                 ' ) WHERE ROWNUM <= ' || l_row_limit ;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Uncosted Transactions ');

       sqltxt := ' SELECT DISTINCT( mpi.physical_inventory_name ) "PhyInv.|Name"   ' ||
                 ' , mpi.physical_inventory_id "PhyInv.|Id"  ' ||
                 ' , TO_CHAR( mpi.physical_inventory_date, ''DD-MON-RR'' ) "PhyInv.|Date"  ' ||
                 ' , mpa.approval_status "Adj.Approval|Status"   ' ||
                 ' , COUNT(*) "Approved|Adjustments"   ' ||
                 ' FROM mtl_physical_adjustments mpa   ' ||
                 ' , mtl_physical_inventories mpi   ' ||
                 ' WHERE mpi.organization_id = mpa.organization_id  ' ||
                 ' AND mpi.physical_inventory_id = mpa.physical_inventory_id  ' ||
                 ' AND mpi.organization_id = ' || l_org_id  ||
                 ' AND mpa.inventory_item_id = ' || l_item_id ||
                 ' AND mpa.approval_status = 3  ' ||
                 ' GROUP BY mpi.physical_inventory_name, mpi.physical_inventory_id  ' ||
                 ' , mpi.physical_inventory_date, mpa.approval_status ';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item Physical Inventory Adjustments');

       sqltxt := ' SELECT mcch.cycle_count_header_name "Cycle Count|Name"  ' ||
                 ' , mcce.cycle_count_header_id "Cycle Count|Id"  ' ||
                 ' , mac.abc_class_name "ABC Class|Name"  ' ||
                 ' , mcci.abc_class_id "ABC Class|Id"  ' ||
                 ' , TO_CHAR( mcci.item_last_schedule_date, ''DD-MON-RR'' ) "Item Last|Scheduled Date"  ' ||
                 ' , COUNT(*) "Completed|Cycle Count| Entries"  ' ||
                 ' FROM mtl_cycle_count_items mcci  ' ||
                 ' , mtl_cycle_count_headers mcch  ' ||
                 ' , mtl_abc_classes mac  ' ||
                 ' , mtl_cycle_count_entries mcce  ' ||
                 ' WHERE mcce.organization_id = ' || l_org_id  ||
                 ' AND mcce.inventory_item_id = ' || l_item_id ||
                 ' AND mcce.cycle_count_header_id = mcch.cycle_count_header_id  ' ||
                 ' AND mcce.inventory_item_id = mcci.inventory_item_id  ' ||
                 ' AND mcce.cycle_count_header_id = mcci.cycle_count_header_id  ' ||
                 ' AND mcci.abc_class_id = mac.abc_class_id  ' ||
                 ' AND mac.organization_id = mcce.organization_id  ' ||
                 ' AND mcce.entry_status_code = 5 ' ||
                 ' GROUP BY mcch.cycle_count_header_name, mcce.cycle_count_header_id  ' ||
                 ' , mac.abc_class_name, mcci.abc_class_id  ' ||
                 ' , mcci.item_last_schedule_date  ' ||
                 ' ORDER BY mcch.cycle_count_header_name ';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Item Cycle Count');



   reportStr := 'The test completed as expected';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   statusStr := 'SUCCESS';
   report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

else

     -- if no item input, do nothing
     statusStr := ''; -- 'SUCCESS';
     errStr := ''; --Test failure message displayed here';
     fixInfo := '';  -- 'Fixing the test suggestions here';
     isFatal := '';  -- 'FALSE';

END IF;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in INVDI01B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
--name := 'Inventory Item';
name := 'Item Data Collection';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Inventory organization information that have the given item assigned';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Item Data Collection';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY  JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY  VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY  JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_ITEM;

/
