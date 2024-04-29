--------------------------------------------------------
--  DDL for Package Body INV_DIAG_PI_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_PI_GEN" AS
/* $Header: INVDA06B.pls 120.0.12000000.1 2007/06/22 17:13:42 musinha noship $ */

  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executed prior to test run leave body as null otherwize
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
    -- test writer could insert special setup code here
    null;
  END init;

  ------------------------------------------------------------
  -- procedure to cleanup any test datastructures that were setup in the init
  -- procedure call executes after test run leave body as null otherwize
  ------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
    -- test writer could insert special cleanup code here
    NULL;
  END cleanup;

  ------------------------------------------------------------
  -- procedure to execute the PLSQL test
  -- the inputs needed for the test are passed in and a report object and CLOB are
  -- returned.
  -- note the way that support API writes to the report CLOB.
  ------------------------------------------------------------
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
    l_phy_inv_id NUMBER;
    l_org_id NUMBER;
    l_count NUMBER;

    CURSOR c_phy_inv (cp_n_org_id IN NUMBER, cp_n_phy_inv_id IN NUMBEr) IS
      SELECT count(*)
      FROM   MTL_PHYSICAL_INVENTORIES
      WHERE  organization_id = cp_n_org_id
      AND physical_inventory_id = cp_n_phy_inv_id;



  BEGIN
    JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
    JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

    l_phy_inv_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PhyInvId',inputs);
    l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
    l_count := 0;

    sqltxt := ' SELECT o.name "Name"  ' ||
              ' , DECODE( o.type#, 9, ''Spec'', 11, ''Body'', o.type# ) "Type"  ' ||
              ' , SUBSTR( s.source, INSTR( s.source, ''$Header'',1 ,1)+9, 12 ) "Filename"  ' ||
              ' , SUBSTR( s.source ,  ' ||
              ' INSTR( s.source ,''.'',10,1)+5,  ' ||
                     ' INSTR( s.source ,'' '',10,3)-  ' ||
                     ' INSTR( s.source ,'' '',10,2) ) "Version"  ' ||
                     ' , DECODE( o.status, 0, ''N/A'', 1, ''VALID'', ''INVALID'' ) "Status" ' ||
              ' FROM sys.source$ s, sys.obj$ o, sys.user$ u  ' ||
              ' WHERE u.name = ''APPS''  ' ||
              ' AND o.owner# = u.user#  ' ||
              ' AND s.obj# = o.obj#  ' ||
              ' AND s.line = 2  ' ||
              ' AND o.name IN ( ''INVADPT1'',  ' ||
                         ' ''INV_CG_UPGRADE'',  ' ||
                         ' ''INV_COST_GROUP_PVT'',  ' ||
                         ' ''INV_LPN_TRX_PUB'',  ' ||
                         ' ''INV_PHY_INV_LOVS'',  ' ||
                         ' ''INV_QUANTITY_TREE_PVT'',   ' ||
                         ' ''INV_TRX_MGR'',  ' ||
                         ' ''INV_UI_ITEM_SUB_LOC_LOVS'' )  ' ||
                         ' ORDER BY o.name, o.type#  ';

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Version of Inventory Key Packages');

    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR>Important Notes Releated to Physical Inventory');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 131795.1,  : Inventory Product Information > Physical Inventory ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 69125.1,   : Latest Inventory news ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 204946.1,  : Manufacturing And Distribution Recommended Patch Strategy ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 246934.1,  : White Paper: Understanding Physical Inventory ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 146869.1,  : How To Create Physical Inventory TAGs ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 105286.1,  : Steps to define and complete a Physical Inventory ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' <BR> Note , 114296.1,  :  Physical Inventory FAQ ');
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'  <BR> Note , 66957.1,  : Oracle Inventory Users Guide, Release 11i <BR>');


    IF l_org_id IS NOT NULL AND l_phy_inv_id IS NOT NULL THEN

       OPEN c_phy_inv(l_org_id, l_phy_inv_id);
       FETCH c_phy_inv INTO l_count;
       CLOSE c_phy_inv;

    END IF;

    IF l_count IS NULL  OR l_count <> 1 THEN
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'Please execute the report with organization and physical inventory information');
       JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Physical Inventory Item and Organization Combination');
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter correct physical inventory and organization ids');
       statusStr := 'FAILURE';
       errStr := 'Invalid Physical Inventory Item and Organization Combination';
       fixInfo := 'Please enter right combination of Physical Inventory Item and Organization';
       isFatal := 'FALSE';
       report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
       reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
       RETURN;
    END IF;

    sqltxt := ' SELECT mif.item_number "Item"  ' ||
              ' ,moq.inventory_item_id "Item Id"  ' ||
              ' ,SUM( moq.transaction_quantity ) "SUM(Txn Qty)"  ' ||
              ' ,SUM( moq.primary_transaction_quantity ) "SUM(Prim Txn Qty)"  ' ||
              ' ,moq.transaction_uom_code "Txn UoM"   ' ||
              ' ,moq.subinventory_code "Subinv"  ' ||
              ' ,moq.locator_id "Locator Id"  ' ||
              ' ,mil.concatenated_segments "Locator"  ' ||
              ' ,mil.description "Locator Desc"  ' ||
              ' ,moq.revision "Revision"  ' ||
              ' ,moq.lot_number "Lot Number"  ' ||
              ' FROM mtl_onhand_quantities_detail moq, mtl_item_flexfields mif  ' ||
              ' , mtl_item_locations_kfv mil  ' ||
              ' WHERE moq.organization_id = ' || l_org_id ||
              ' AND moq.inventory_item_id = mif.inventory_item_id(+)  ' ||
              ' AND moq.organization_id = mif.organization_id(+)  ' ||
              ' AND moq.organization_id = mil.organization_id(+)  ' ||
              ' AND moq.locator_id = mil.inventory_location_id(+)  ' ||
              ' AND moq.inventory_item_id  ' ||
              ' IN ( SELECT DISTINCT mpa.inventory_item_id  ' ||
                     ' FROM mtl_physical_adjustments mpa  ' ||
                     ' WHERE mpa.organization_id = ' || l_org_id ||
                     ' AND mpa.physical_inventory_id = ' || l_phy_inv_id ||')' ||
               ' GROUP BY mif.item_number, moq.inventory_item_id  ' ||
               ' ,moq.transaction_uom_code, moq.subinventory_code, moq.locator_id  ' ||
               ' ,mil.concatenated_segments, mil.description  ' ||
               ' ,moq.revision, moq.lot_number  ' ||
               ' ORDER BY mif.item_number, moq.inventory_item_id  ' ||
               ' ,moq.transaction_uom_code, moq.subinventory_code, moq.locator_id  ' ||
               ' ,mil.concatenated_segments, mil.description  ' ||
               ' ,moq.revision, moq.lot_number  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Onhand information');

  sqltxt := ' SELECT mpa.organization_id  ' ||
            ' , mpa.physical_inventory_id  ' ||
            ' , mpa.adjustment_id  ' ||
            ' , mpa.inventory_item_id  ' ||
            ' , msi.segment1  ' ||
            ' , mpa.subinventory_name  ' ||
            ' , mpa.serial_number  ' ||
            ' , msi.serial_number_control_code  ' ||
            ' , mpa.revision  ' ||
            ' , mpa.lot_number  ' ||
            ' , mpa.locator_id  ' ||
            ' , mpa.approval_status  ' ||
            ' , mpa.adjustment_quantity  ' ||
            ' FROM mtl_physical_adjustments mpa  ' ||
            ' , mtl_system_items msi  ' ||
            ' WHERE mpa.organization_id = ' || l_org_id  ||
            ' AND mpa.physical_inventory_id = ' || l_phy_inv_id  ||
            ' AND mpa.organization_id = msi.organization_id  ' ||
            ' AND mpa.inventory_item_id = msi.inventory_item_id  ' ||
            ' AND msi.serial_number_control_code IN (2,5)  ' ||
            ' AND mpa.serial_number IS NULL  ' ||
            ' AND ( mpa.approval_status = 1 OR mpa.approval_status IS NULL )  ' ||
            ' ORDER BY mpa.organization_id, mpa.physical_inventory_id, mpa.adjustment_id ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'MPA records for serial controlled items without serial numbers');

  sqltxt := ' SELECT mpa.*  ' ||
            ' FROM mtl_physical_adjustments mpa  ' ||
            ' WHERE mpa.organization_id = ' ||  l_org_id  ||
            ' AND mpa.physical_inventory_id = ' || l_phy_inv_id  ||
            ' AND mpa.adjustment_quantity <> 0  ' ||
            ' AND mpa.locator_id IS NOT NULL  ' ||
            ' AND NOT EXISTS  ' ||
            ' ( SELECT 1  ' ||
               ' FROM mtl_item_locations mil  ' ||
               ' WHERE mil.organization_id = mpa.organization_id  ' ||
               ' AND mil.subinventory_code = mpa.subinventory_name  ' ||
               ' AND mil.inventory_location_id = mpa.locator_id ) ' ||
            ' ORDER BY mpa.adjustment_id ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'MPA records with invalid locator_id in onhand');

  sqltxt := ' SELECT mpa.organization_id  ' ||
            ' , mpa.physical_inventory_id  ' ||
            ' , mpa.adjustment_id  ' ||
            ' , mpa.inventory_item_id  ' ||
            ' , msi.segment1  ' ||
            ' , mpa.subinventory_name  ' ||
            ' , mpa.lot_number  ' ||
            ' , mpa.serial_number  ' ||
            ' , msi.serial_number_control_code  ' ||
            ' , mpa.revision  ' ||
            ' , mpa.locator_id  ' ||
            ' , mpa.approval_status  ' ||
            ' , mpa.adjustment_quantity  ' ||
            ' FROM mtl_physical_adjustments mpa  ' ||
            ' , mtl_system_items msi  ' ||
            ' WHERE mpa.organization_id = ' || l_org_id ||
            ' AND mpa.physical_inventory_id = ' || l_phy_inv_id  ||
            ' AND mpa.organization_id = msi.organization_id  ' ||
            ' AND mpa.inventory_item_id = msi.inventory_item_id  ' ||
            ' AND msi.lot_control_code = 2   ' ||
            ' AND mpa.lot_number IS NULL  ' ||
            ' AND ( mpa.approval_status = 1 OR mpa.approval_status IS NULL )   ' ||
            ' ORDER BY mpa.organization_id, mpa.physical_inventory_id, mpa.adjustment_id ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'MPA records of lot controlled item without lot number');

  sqltxt := ' SELECT physical_adjustment_id  ' ||
            ' , inventory_item_id  ' ||
            ' , subinventory_code  ' ||
            ' , locator_id  ' ||
            ' , revision  ' ||
            ' , primary_quantity  ' ||
            ' , last_update_date  ' ||
            ' FROM mtl_material_transactions  ' ||
            ' WHERE physical_adjustment_id IN  ' ||
            ' ( SELECT physical_adjustment_id  ' ||
              ' FROM mtl_material_transactions  ' ||
              ' WHERE organization_id = ' || l_org_id  ||
              ' AND transaction_source_id = ' || l_phy_inv_id ||
              ' AND transaction_type_id = 8  ' ||
              ' GROUP BY physical_adjustment_id  ' ||
              ' HAVING COUNT(*) > 1 ) ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Duplicate Physical Adjustment transactions');

  sqltxt := ' SELECT physical_adjustment_id  ' ||
            ' , inventory_item_id  ' ||
            ' , subinventory_code  ' ||
            ' , locator_id  ' ||
            ' , revision  ' ||
            ' , primary_quantity  ' ||
            ' , last_update_date  ' ||
            ' FROM mtl_material_transactions_temp  ' ||
            ' WHERE organization_id = ' || l_org_id  ||
            ' AND transaction_source_id = ' || l_phy_inv_id  ||
            ' AND transaction_action_id = 8  ' ||
            ' AND physical_adjustment_id IS NOT NULL  ' ||
            ' AND physical_adjustment_id IN  ' ||
            ' ( SELECT physical_adjustment_id  ' ||
                 ' FROM mtl_material_transactions_temp  ' ||
                 ' WHERE organization_id = ' || l_org_id ||
                 ' AND transaction_source_id = ' || l_phy_inv_id  ||
                 ' AND transaction_type_id = 8  ' ||
                 ' GROUP BY physical_adjustment_id  ' ||
                 ' HAVING COUNT(*) > 1 ) ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Duplicate Pending Physical Adjustment transactions');

  sqltxt := ' SELECT physical_adjustment_id  ' ||
            ' , transaction_source_id  ' ||
            ' , inventory_item_id  ' ||
            ' , subinventory_code  ' ||
            ' , locator_id  ' ||
            ' , revision  ' ||
            ' , primary_quantity  ' ||
            ' , last_update_date  ' ||
            ' FROM mtl_material_transactions_temp mmtt  ' ||
            ' WHERE organization_id = ' || l_org_id ||
            ' AND transaction_source_id = ' || l_phy_inv_id  ||
            ' AND transaction_action_id = 8  ' ||
            ' AND physical_adjustment_id IS NOT NULL  ' ||
            ' AND EXISTS  ' ||
            ' ( SELECT 1  ' ||
                  ' FROM mtl_material_transactions mmt  ' ||
                  ' WHERE mmt.organization_id = ' || l_org_id ||
                  ' AND mmt.transaction_source_id = ' || l_phy_inv_id  ||
                  ' AND mmt.physical_adjustment_id IS NOT NULL  ' ||
                  ' AND mmt.physical_adjustment_id = mmtt.physical_adjustment_id  ' ||
                  ' AND mmt.transaction_source_id = mmtt.transaction_source_id  ' ||
                  ' AND mmt.transaction_action_id = mmtt.transaction_action_id ) ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Pending Physical Adjustment transactions duplicate of completed transaction');

  sqltxt := ' SELECT mpa.adjustment_id, mpa.physical_inventory_id  ' ||
            ' , mpa.inventory_item_id, mpa.organization_id, mpa.count_quantity  ' ||
            ' , SUM( mpit.tag_quantity_at_standard_uom ) total_tag  ' ||
            ' FROM mtl_physical_inventory_tags mpit  ' ||
            ' , mtl_physical_adjustments mpa  ' ||
            ' WHERE mpa.organization_id = ' || l_org_id  ||
            ' AND mpa.physical_inventory_id = ' || l_phy_inv_id  ||
            ' AND mpa.physical_inventory_id = mpit.physical_inventory_id  ' ||
            ' AND mpa.adjustment_id = mpit.adjustment_id  ' ||
            ' AND NVL( mpa.approval_status, 1 ) = 1  ' ||
            ' AND mpit.void_flag = 2  ' ||
            ' GROUP BY mpa.adjustment_id, mpa.physical_inventory_id  ' ||
            ' , mpa.inventory_item_id, mpa.organization_id, mpa.count_quantity  ' ||
            ' HAVING count_quantity <> SUM( mpit.tag_quantity_at_standard_uom )  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Mismatch between MPA count and Standard UOM count');

  sqltxt := ' SELECT mpi.physical_inventory_name  ' ||
            ' , mpi.description              ' ||
            ' , mpi.physical_inventory_date  ' ||
            ' , mpi.approval_required        ' ||
            ' , ml.meaning                  ' ||
            ' , mpi.approval_tolerance_pos   ' ||
            ' , mpi.approval_tolerance_neg  ' ||
            ' , mpi.cost_variance_pos        ' ||
            ' , mpi.cost_variance_neg        ' ||
            ' , mpi.all_subinventories_flag  ' ||
            ' , mpi.snapshot_complete        ' ||
            ' , mpi.last_adjustment_date     ' ||
            ' , mpi.adjustments_posted       ' ||
            ' , mpi.freeze_date             ' ||
            ' , mpi.dynamic_tag_entry_flag   ' ||
            ' , mpi.total_adjustment_value   ' ||
            ' , mpi.next_tag_number          ' ||
            ' , mpi.tag_number_increments    ' ||
            ' , mpi.number_of_skus          ' ||
            ' FROM mtl_physical_inventories_v mpi ' ||
            ' , mfg_lookups ml ' ||
            ' WHERE mpi.organization_id = ' ||  l_org_id ||
            ' AND mpi.physical_inventory_id = ' || l_phy_inv_id ||
            ' AND mpi.approval_required = ml.lookup_code(+) ' ||
            ' AND ml.lookup_type = ''MTL_APPROVAL_REQ'' ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Physical inventory information');

  sqltxt := ' SELECT mpit.tag_number  ' ||
            ' ,mpit.tag_id  ' ||
            ' ,mpit.void_flag  ' ||
            ' ,mpit.adjustment_id  ' ||
            ' ,mpit.inventory_item_id  ' ||
            ' ,mpit.tag_quantity  ' ||
            ' ,mpit.tag_uom  ' ||
            ' ,mpit.tag_quantity_at_standard_uom  ' ||
            ' ,mpit.standard_uom  ' ||
            ' ,mpit.subinventory  ' ||
            ' ,mpit.locator_id  ' ||
            ' ,mpit.lot_serial_controls  ' ||
            ' ,mpit.lot_number  ' ||
            ' ,mpit.lot_expiration_date  ' ||
            ' ,mpit.revision  ' ||
            ' ,mpit.serial_num  ' ||
            ' ,mpit.parent_lpn_id  ' ||
            ' ,mpit.outermost_lpn_id  ' ||
            ' ,mpit.cost_group_id  ' ||
            ' FROM mtl_physical_inventory_tags mpit  ' ||
            ' WHERE mpit.organization_id  = ' || l_org_id   ||
            ' AND mpit.physical_inventory_id = ' || l_phy_inv_id  ||
            ' ORDER BY mpit.tag_number  ' ||
            '  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Physical inventory tag information');

  sqltxt := ' SELECT DECODE( approval_status, 1, ''Approved''  ' ||
                                    ' , 2, ''Rejected''  ' ||
                                    ' , 3, ''Posted''  ' ||
                                    ' , NULL, ''No Status entered''  ' ||
                                    ' , approval_status ) || '' ( '' ||approval_status||'' )'' "Approval Status ( Id )"  ' ||
            ' , COUNT(*) "Count"  ' ||
            ' FROM mtl_physical_adjustments  ' ||
            ' WHERE organization_id = ' || l_org_id  ||
            ' AND physical_inventory_id = ' || l_phy_inv_id  ||
            ' GROUP BY approval_status  ' ||
            ' ORDER BY approval_status ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Count of distinct adjustment approval_status');

  sqltxt := ' SELECT mmt.transaction_id  ' ||
            ' ,mmt.costed_flag  ' ||
            ' ,mmt.last_update_date  ' ||
            ' ,mmt.inventory_item_id  ' ||
            ' ,mmt.transaction_quantity  ' ||
            ' ,mmt.transaction_uom ' ||
            ' ,mmt.revision  ' ||
            ' FROM mtl_material_transactions mmt  ' ||
            ' WHERE mmt.organization_id  = ' || l_org_id  ||
            ' AND mmt.transaction_source_id = ' || l_phy_inv_id  ||
            ' AND mmt.transaction_type_id = 8  ' ||
            ' ORDER BY mmt.transaction_id  ' ||
            '  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Adjustment transaction information');

  sqltxt := ' SELECT mpa.adjustment_id  ' ||
             ' ,mpa.approval_status  ' ||
             ' ,mpa.inventory_item_id  ' ||
             ' ,mpa.subinventory_name  ' ||
             ' ,mpa.locator_id  ' ||
             ' ,mpa.system_quantity  ' ||
             ' ,mpa.count_quantity  ' ||
             ' ,mpa.adjustment_quantity  ' ||
             ' ,mpa.revision  ' ||
             ' ,mpa.lot_number  ' ||
             ' ,mpa.lot_expiration_date  ' ||
             ' ,mpa.lot_serial_controls  ' ||
             ' ,mpa.serial_number  ' ||
             ' ,mpa.actual_cost ' ||
             ' ,mpa.cost_group_id  ' ||
             ' ,mpa.automatic_approval_code  ' ||
             ' ,mpa.gl_adjust_account  ' ||
             ' ,mpa.parent_lpn_id  ' ||
             ' ,mpa.outermost_lpn_id  ' ||
             ' FROM mtl_physical_adjustments mpa  ' ||
             ' WHERE mpa.organization_id = ' || l_org_id   ||
             ' AND mpa.physical_inventory_id = ' || l_phy_inv_id   ||
             ' ORDER BY mpa.adjustment_id ' ||
             '  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Adjustment information');

  sqltxt := ' SELECT mmtt.transaction_temp_id "Txn|Temp Id"  ' ||
            ' , transaction_header_id "Txn|Header Id"  ' ||
            ' , mmtt.source_code "Source Code"  ' ||
            ' , mif.item_number ||'' (''|| mmtt.inventory_item_id ||'')'' "Item (Id)"  ' ||
            ' , subinventory_code "Subinv"  ' ||
            ' , locator_id "Stock Locator"  ' ||
            ' , revision "Rev"  ' ||
            ' , TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Txn Date"  ' ||
            ' , mmtt.transaction_quantity "Txn Qty"  ' ||
            ' , mmtt.primary_quantity "Primary|Qty"  ' ||
            ' , transaction_uom "Txn UoM"  ' ||
            ' , transaction_cost "Txn Cost"  ' ||
            ' , tt.transaction_type_name ||'' (''||mmtt.transaction_type_id||'')'' "Txn Type (Id)"  ' ||
            ' , ml.meaning ||'' (''|| mmtt.transaction_action_id ||'')'' "Txn Action (Id)"  ' ||
            ' , st.transaction_source_type_name ||'' (''|| mmtt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"  ' ||
            ' , transaction_source_id "Txn Source Id"  ' ||
            ' , process_flag "Process|Flag"  ' ||
            ' , lock_flag "Lock|Flag"  ' ||
            ' , DECODE( transaction_mode,1, ''Online''  ' ||
                                      ' ,2, ''Concurrent''  ' ||
                                      ' ,3, ''Background''  ' ||
                                      ' , transaction_mode ) || '' ('' || transaction_mode ||'')'' "Transaction|Mode"  ' ||
            ' , mmtt.request_id "Request|Id"  ' ||
            ' , TO_CHAR( mmtt.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last updated"  ' ||
            ' , transfer_subinventory "Transfer|Subinv"  ' ||
            ' , transfer_to_location "Transfer to|Location"  ' ||
            ' , mmtt.error_code "Error|Code"  ' ||
            ' , error_explanation "Error|Explanation"  ' ||
            ' FROM mtl_material_transactions_temp mmtt ' ||
            ' , mtl_item_flexfields mif ' ||
            ' , mtl_transaction_types tt ' ||
            ' , mtl_txn_source_types st ' ||
            ' , mfg_lookups ml  ' ||
            ' WHERE mmtt.organization_id = ' || l_org_id   ||
            ' AND mmtt.transaction_source_id = ' || l_phy_inv_id   ||
            ' AND mmtt.transaction_type_id = 8  ' ||
            ' AND mmtt.inventory_item_id = mif.inventory_item_id(+)  ' ||
            ' AND mmtt.organization_id = mif.organization_id(+)  ' ||
            ' AND mmtt.transaction_type_id = tt.transaction_type_id(+)  ' ||
            ' AND mmtt.transaction_source_type_id = st.transaction_source_type_id(+)  ' ||
            ' AND mmtt.transaction_action_id = ml.lookup_code  ' ||
            ' AND ml.lookup_type = ''MTL_TRANSACTION_ACTION''  ' ||
            ' ORDER BY mmtt.transaction_temp_id, transaction_header_id ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Pending Adjustment transactions');

  sqltxt := ' SELECT transaction_temp_id "Txn|Temp Id"  ' ||
            ' , transaction_header_id "Txn|Header Id"  ' ||
            ' , source_code "Source|Code"  ' ||
            ' , mif.item_number ||'' (''|| mmtt.inventory_item_id ||'')'' "Item (Id)"  ' ||
            ' , subinventory_code "Subinv"  ' ||
            ' , locator_id "Locator|Id"  ' ||
            ' , revision "Rev"  ' ||
            ' , TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Txn Date"  ' ||
            ' , transaction_quantity "Txn Qty"  ' ||
            ' , primary_quantity "Primary|Qty"  ' ||
            ' , transaction_uom "Txn UoM"  ' ||
            ' , transaction_cost "Txn Cost"  ' ||
            ' , tt.transaction_type_name ||'' (''||mmtt.transaction_type_id||'')'' "Txn Type (Id)"  ' ||
            ' , ml.meaning ||'' (''|| mmtt.transaction_action_id ||'')'' "Txn Action (Id)"  ' ||
            ' , st.transaction_source_type_name ||'' (''|| mmtt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"  ' ||
            ' , transaction_source_id "Txn Source|Id"  ' ||
            ' , process_flag "Process|Flag"  ' ||
            ' , lock_flag "Lock|Flag"  ' ||
            ' , DECODE( transaction_mode,1,''Online''  ' ||
                         ' ,2,''Concurrent''  ' ||
                         ' ,3,''Background''  ' ||
                         ' , transaction_mode ) || '' ('' || transaction_mode ||'')'' "Transaction|Mode"  ' ||
                    ' , mmtt.request_id "Request|Id"  ' ||
            ' , TO_CHAR(mmtt.last_update_date,''DD-MON-RR HH24:MI'') "Last updated"  ' ||
            ' , transfer_subinventory "Transfer|Subinv"  ' ||
            ' , transfer_to_location "Transfer to|Location"  ' ||
            ' , error_code "Error|Code"  ' ||
            ' , error_explanation "Error|Explanation"  ' ||
            ' FROM mtl_material_transactions_temp mmtt ' ||
            ' , mtl_item_flexfields mif ' ||
            ' , mtl_transaction_types tt ' ||
            ' , mtl_txn_source_types st ' ||
            ' , mfg_lookups ml  ' ||
            ' WHERE mmtt.organization_id = ' || l_org_id  ||
            ' AND mmtt.transaction_type_id != 8             AND mmtt.inventory_item_id = mif.inventory_item_id(+)  ' ||
            ' AND mmtt.organization_id = mif.organization_id(+)  ' ||
            ' AND mmtt.transaction_type_id = tt.transaction_type_id(+)  ' ||
            ' AND mmtt.transaction_source_type_id = st.transaction_source_type_id(+)  ' ||
            ' AND mmtt.transaction_action_id = ml.lookup_code  ' ||
            ' AND ml.lookup_type = ''MTL_TRANSACTION_ACTION'' ' ||
            ' AND mmtt.subinventory_code IN ( SELECT mps.subinventory  ' ||
            ' FROM mtl_physical_subinventories mps  ' ||
                   ' WHERE mps.organization_id = ' || l_org_id  ||
                   ' AND mps.physical_inventory_id = ' || l_phy_inv_id || ' ) ' ||
                   ' ORDER BY transaction_temp_id, transaction_header_id ' ||
            '  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Pending Non Physical Inventory Transactions');

  sqltxt := ' SELECT transaction_header_id "Txn|Header Id"  ' ||
            ' , mti.transaction_interface_id "Txn IntFace|Id"  ' ||
            ' , mif.item_number ||'' (''|| mti.inventory_item_id ||'')'' "Item (Id)"  ' ||
            ' , item_segment1 "Item|Segment1"  ' ||
            ' , subinventory_code "Subinv"  ' ||
            ' , loc_segment1 ||'' ''|| loc_segment2 ||'' ''|| loc_segment3 "Loc_Segment| 1-3"  ' ||
            ' , locator_id "Locator|Id"  ' ||
            ' , revision "Rev"  ' ||
            ' , mti.transaction_quantity "Txn Qty"  ' ||
            ' , mti.primary_quantity "Primary|Qty"  ' ||
            ' , transaction_uom "Txn UoM"  ' ||
            ' , transaction_cost "Txn Cost"  ' ||
            ' , transaction_type_name ||'' (''|| transaction_type_id ||'')'' "Txn Type (Id)"  ' ||
            ' , transaction_action_name ||'' (''|| transaction_action_id ||'')'' "Txn Action (Id)"  ' ||
            ' , transaction_source_type_name ||'' (''|| transaction_source_type_id ||'')'' "Txn Source Type (Id)"  ' ||
            ' , transaction_source_name ||'' (''|| transaction_source_id ||'')'' "Txn Source (Id)"  ' ||
            ' , trx_source_line_id "Txn Source|Line Id"  ' ||
            ' , cost_group_id "Cost|Group Id"  ' ||
            ' , TO_CHAR( transaction_date, ''DD-MON-RR HH24:MI'' ) "Txn Date"  ' ||
            ' , transaction_reference "Txn Reference"  ' ||
            ' , transfer_subinventory "Transfer|Subinv"  ' ||
            ' , transfer_organization_code ||'' (''|| transfer_organization ||'')'' "Transfer|Organization"  ' ||
            ' , mti.request_id "Request Id"  ' ||
            ' , mti.source_code "Source|Code"  ' ||
            ' , mti.source_line_id "Source|Line Id"  ' ||
            ' , source_header_id "Source|Header Id"  ' ||
            ' , mti.distribution_account_id "Distribution|Account Id"  ' ||
            ' , mti.process_flag_desc ||'' ('' || mti.process_flag || '')'' "Process Flag"  ' ||
            ' , transaction_mode_desc ||'' ('' || transaction_mode || '')'' "Txn Mode"  ' ||
            ' , lock_flag_desc ||'' ('' || lock_flag || '')'' "Lock|Flag"  ' ||
            ' , TO_CHAR( mti.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last updated"  ' ||
            ' , mti.error_code "Error Code"  ' ||
            ' , error_explanation "Error Explanation"  ' ||
            ' FROM mtl_transactions_interface_v mti  ' ||
            ' , mtl_item_flexfields mif  ' ||
            ' WHERE mti.organization_id  = ' || l_org_id   ||
            ' AND mti.organization_id = mif.organization_id(+)  ' ||
            ' AND mti.inventory_item_id = mif.inventory_item_id(+) ' ||
            ' AND mti.subinventory_code IN ( SELECT mps.subinventory  ' ||
            ' FROM mtl_physical_subinventories mps  ' ||
                   ' WHERE mps.organization_id = ' || l_org_id   ||
                   ' AND mps.physical_inventory_id = ' || l_phy_inv_id || ') ' ||
                   ' ORDER BY transaction_header_id, mti.transaction_interface_id  ' ||
            '  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Inventory Interface Transactions');

  sqltxt := ' SELECT COUNT(*) "Count"  ' ||
            ' , transaction_type_name ||'' ( ''||transaction_type_id||'' )'' "Txn Type (Id)"  ' ||
            ' FROM mtl_transactions_interface_v mti  ' ||
            ' WHERE organization_id = ' || l_org_id   ||
            ' GROUP BY transaction_type_name, transaction_type_id  ' ||
            ' ORDER BY COUNT(*) DESC, transaction_type_name, transaction_type_id ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Interfaced Types of Transactions');

  sqltxt := ' SELECT COUNT(*)  ' ||
            ' FROM mtl_physical_adjustments  ' ||
            ' WHERE organization_id = ' || l_org_id   ||
            ' AND physical_inventory_id = ' || l_phy_inv_id  ||
            ' AND adjustment_quantity <> 0  ' ||
            ' AND ( approval_status NOT IN (2, 3) OR approval_status IS NULL ) ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Total number of unprocessed adjustments');

  sqltxt := ' SELECT COUNT(*)  ' ||
            ' FROM mtl_material_transactions  ' ||
            ' WHERE organization_id  = ' || l_org_id   ||
            ' AND transaction_source_id  = ' || l_phy_inv_id  ||
            ' AND transaction_type_id  = 8  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Total number of processed adjustments');

  sqltxt := ' SELECT DISTINCT mif.item_number "Item Number"  ' ||
            ' ,mmtt.inventory_item_id "Item Id"  ' ||
            ' ,primary_uom_code "Primary|UoM"  ' ||
            ' ,mif.inventory_item_flag "Inventory|Item Flag"  ' ||
            ' ,mif.stock_enabled_flag "Stock|Flag"  ' ||
            ' ,mif.mtl_transactions_enabled_flag "Transactable|Flag"  ' ||
            ' ,mif.costing_enabled_flag "Costing|Flag"   ' ||
            ' ,mif.inventory_asset_flag "Inventory|Asset Flag"  ' ||
            ' ,mif.purchasing_enabled_flag "Purchasing|Enabled|Flag"  ' ||
            ' ,mif.purchasing_item_flag "Purchasing|Item|Flag"  ' ||
            ' ,DECODE( mif.lot_control_code, 1, ''N'' , 2, ''Y''   ' ||
            ' , mif.lot_control_code )  ' ||
            ' || '' (''||mif.lot_control_code||'')'' "Lot|Control"   ' ||
            ' ,ml.meaning||'' (''||mif.serial_number_control_code||'')'' "Serial|Control"  ' ||
            ' ,DECODE( TO_CHAR(mif.revision_qty_control_code) , ''1'', ''No''   ' ||
            ' , ''2'', ''Yes''   ' ||
            ' , mif.revision_qty_control_code )  ' ||
            ' || '' (''||mif.revision_qty_control_code||'')'' "Revision|Control"  ' ||
            ' ,DECODE( TO_CHAR(mif.location_control_code)  ' ||
                                 ' ,''1'', ''None''  ' ||
                                 ' ,''2'', ''Prespecified''  ' ||
                                 ' ,''3'', ''Dynamic''  ' ||
                                 ' ,''4'', ''Determine at Subinv Level''  ' ||
                                 ' ,''5'', ''Determine at Item Level''  ' ||
                                 ' , mif.location_control_code )  ' ||
            ' || '' (''||mif.location_control_code||'')'' "Location|Control"  ' ||
            ' ,DECODE( mif.restrict_subinventories_code, 1, ''Yes''  ' ||
            ' , 2, ''No''  ' ||
            ' ,mif.restrict_subinventories_code ) "Restricted|Subinvs"  ' ||
            ' ,DECODE( mif.restrict_locators_code, 1, ''Yes'', 2, ''No''  ' ||
            ' ,mif.restrict_locators_code )  ' ||
            ' || '' (''||mif.restrict_locators_code||'')'' "Restricted|Locators"  ' ||
            ' ,mif.last_update_date  ' ||
            ' FROM mtl_material_transactions_temp mmtt  ' ||
            ' ,mtl_item_flexfields mif  ' ||
            ' ,mfg_lookups ml  ' ||
            ' WHERE mmtt.organization_id = ' || l_org_id   ||
            ' AND mmtt.transaction_source_id = ' || l_phy_inv_id  ||
            ' AND mmtt.transaction_type_id = 8  ' ||
            ' AND mmtt.inventory_item_id = mif.inventory_item_id(+)  ' ||
            ' AND mif.serial_number_control_code = ml.lookup_code(+)  ' ||
            ' AND ''MTL_SERIAL_NUMBER'' = ml.lookup_type(+)  ' ||
            ' ORDER BY mif.item_number ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Pending adjustment item information');

  sqltxt := ' SELECT subinventory  ' ||
            ' FROM mtl_physical_subinventories  ' ||
            ' WHERE organization_id = ' || l_org_id   ||
            ' AND physical_inventory_id = ' || l_phy_inv_id  ||
            ' ORDER BY subinventory  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Physical Inventory Subinventories');

  sqltxt := ' SELECT msi.*  ' ||
            ' FROM mtl_secondary_inventories msi  ' ||
            ' WHERE msi.organization_id = ' || l_org_id   ||
            ' ORDER BY msi.secondary_inventory_name ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Organization Subinventories');

     sqltxt := ' SELECT msi.*  ' ||
               ' FROM mtl_secondary_inventories msi  ' ||
               ' WHERE ( msi.secondary_inventory_name, msi.organization_id ) IN  ' ||
               ' ( SELECT mps.subinventory, mps.organization_id  ' ||
               ' FROM mtl_physical_subinventories mps  ' ||
               ' WHERE mps.organization_id = ' || l_org_id   ||
               ' AND mps.physical_inventory_id = ' || l_phy_inv_id || ' )  ' ||
               ' ORDER BY msi.secondary_inventory_name ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Subinventories restricted to physical inventory');

  reportStr := 'The test completed as expected';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
  statusStr := 'SUCCESS';
  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

  EXCEPTION
    WHEN OTHERS THEN
      JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
      statusStr := 'FAILURE';
      errStr := sqlerrm ||' occurred in script Exception handled';
      fixInfo := 'Unexpected Exception in INVDA06B.pls';
      isFatal := 'FALSE';
      report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
  END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
  name := 'Accuracy';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
  BEGIN
  descStr := 'Physical Inventory Information';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Physical Inventory Information';
  END getTestName;

  ------------------------------------------------------------
  -- procedure to provide the default parameters for the test case.
  -- please note the paramters have to be registered through the UI
  -- before basic tests can be run.
  --
  ------------------------------------------------------------
  PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
    tempInput JTF_DIAG_INPUTTBL;
  BEGIN

    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PhyInvId','LOV-oracle.apps.inv.diag.lov.PhysInvLov');
    defaultInputValues := tempInput;
  EXCEPTION
    when others then
      defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  END getDefaultTestParams;
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

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_PI_GEN;

/
