--------------------------------------------------------
--  DDL for Package Body INV_DIAG_PI_SUBLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_PI_SUBLOC" as
/* $Header: INVDA02B.pls 120.0.12000000.1 2007/06/22 00:36:09 musinha noship $ */

PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY  JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY  CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 l_org_id NUMBER;

 CURSOR c_inv_loc (cp_n_org_id IN NUMBER) IS
    select moqd.inventory_item_id,
           moqd.organization_id,
           moqd.subinventory_code,
           moqd.locator_id,
           moqd.revision,
           moqd.primary_transaction_quantity,
           moqd.create_transaction_id,
	   moqd.update_transaction_id
     from mtl_onhand_quantities_detail moqd
     where moqd.locator_id is not null
     and   moqd.organization_id = NVL(cp_n_org_id, moqd.organization_id)
     and   not exists (select 1 from mtl_item_locations mil
                       where mil.organization_id = moqd.organization_id
                       and  mil.subinventory_code = moqd.subinventory_code
                       and  mil.inventory_location_id = moqd.locator_id)
     and  exists (SELECT 1 FROM MTL_PARAMETERS P,
                                MTL_SECONDARY_INVENTORIES S,
				MTL_SYSTEM_ITEMS I
                            WHERE I.INVENTORY_ITEM_ID = moqd.INVENTORY_ITEM_ID
                            AND S.SECONDARY_INVENTORY_NAME = moqd.SUBINVENTORY_CODE
                            AND P.ORGANIZATION_ID = moqd.ORGANIZATION_ID
                            AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
                            AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
                            AND P.ORGANIZATION_ID = I.ORGANIZATION_ID AND P.WMS_ENABLED_FLAG = 'N'
                            AND (decode(P.STOCK_LOCATOR_CONTROL_CODE,
			            4,decode(S.LOCATOR_TYPE,5,
					I.LOCATION_CONTROL_CODE, S.LOCATOR_TYPE),
				P.STOCK_LOCATOR_CONTROL_CODE) IN (2,3) ))
     ORDER BY  moqd.organization_id, moqd.inventory_item_id, moqd.create_transaction_id, moqd.update_transaction_id, moqd.locator_id;

  CURSOR c_phy_adj ( cp_n_cre_trx_id IN NUMBER, cp_upd_trx_id IN NUMBER) IS
    SELECT mmt.physical_adjustment_id
    FROM   mtl_material_transactions mmt
    WHERE  (mmt.transaction_id = cp_n_cre_trx_id OR mmt.transaction_id = cp_upd_trx_id)
    AND    mmt.physical_adjustment_id IS NOT NULL;

BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

  l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);

  sqltxt := ' select mif.item_number||''(''||mif.inventory_item_id||'')'' "Item (Id)"' ||
            ' , moqd.subinventory_code "Subinv"  ' ||
            ' , moqd.locator_id "Stock Locator"  ' ||
            ' , moqd.revision "Rev"  ' ||
            ' , moqd.primary_transaction_quantity "Prim Qty"  ' ||
            ' , moqd.create_transaction_id "Create txn_id"' ||
	    ' , moqd.update_transaction_id "Update trx_id"' ||
            ' from mtl_onhand_quantities_detail moqd,' ||
            ' mtl_item_flexfields mif' ||
            ' where moqd.locator_id is not null ' ;
  IF l_org_id IS NOT NULL THEN
     sqltxt := sqltxt || ' AND  moqd.organization_id = ' || l_org_id ;
  END IF;

  sqltxt := sqltxt ||  ' and   moqd.inventory_item_id = mif.inventory_item_id(+) ' ||
                       ' and   not exists (select 1 from mtl_item_locations mil ' ||
                                           ' where mil.organization_id = moqd.organization_id ' ||
                                           ' and  mil.subinventory_code = moqd.subinventory_code ' ||
                                           ' and  mil.inventory_location_id = moqd.locator_id) ' ||
	               ' and  exists (SELECT 1' ||
                                      ' FROM MTL_PARAMETERS P,MTL_SECONDARY_INVENTORIES S,MTL_SYSTEM_ITEMS I ' ||
                                      ' WHERE I.INVENTORY_ITEM_ID = moqd.INVENTORY_ITEM_ID ' ||
                                      ' AND S.SECONDARY_INVENTORY_NAME = moqd.SUBINVENTORY_CODE ' ||
                                      ' AND P.ORGANIZATION_ID = moqd.ORGANIZATION_ID ' ||
                                      ' AND I.ORGANIZATION_ID = S.ORGANIZATION_ID ' ||
                                      ' AND P.ORGANIZATION_ID = S.ORGANIZATION_ID ' ||
                                      ' AND P.ORGANIZATION_ID = I.ORGANIZATION_ID ' ||
				      ' AND P.WMS_ENABLED_FLAG = ''N'' ' ||
                                      ' AND (decode(P.STOCK_LOCATOR_CONTROL_CODE,4,decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE, S.LOCATOR_TYPE), ' ||
                                      ' P.STOCK_LOCATOR_CONTROL_CODE) IN (2,3) )) ' ||
				      ' ORDER BY  moqd.organization_id, moqd.inventory_item_id, moqd.create_transaction_id, moqd.update_transaction_id, moqd.locator_id ';

  dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Onhand with invalid locators');

  FOR rec_inv_loc IN c_inv_loc (l_org_id ) LOOP

      sqltxt := ' SELECT mmt.transaction_id "Txn Id"  ' ||
                ' , mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)"  ' ||
                ' , mmt.transaction_date "Txn Date"  ' ||
                ' , mmt.transaction_quantity "Txn Qty"  ' ||
                ' , mmt.primary_quantity "Prim Qty"  ' ||
                ' , mmt.transaction_uom "Uom"  ' ||
                ' , tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"  ' ||
                ' , ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''  ' ||
                ' "Txn Action (Id)"  ' ||
                ' , st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"  ' ||
                ' , mmt.subinventory_code "Subinv"  ' ||
                ' , mmt.locator_id "Stock Locator"  ' ||
                ' , mmt.revision "Rev"   ' ||
                ' , mmt.physical_adjustment_id "Physical Adj Id"' ||
                ' , mmt.transaction_source_id "Txn Source Id"  ' ||
                ' , mmt.transaction_source_name "Txn Source"' ||
                ' FROM mtl_material_transactions mmt  ' ||
                ' , mtl_item_flexfields mif  ' ||
                ' , mtl_transaction_types tt  ' ||
                ' , mtl_txn_source_types st  ' ||
                ' , mfg_lookups ml  ' ||
                ' WHERE mmt.organization_id = ' || rec_inv_loc.organization_id  ||
                ' AND mmt.transaction_id = ' || rec_inv_loc.create_transaction_id ||
                ' AND mmt.inventory_item_id = mif.inventory_item_id(+)  ' ||
                ' AND mmt.organization_id = mif.organization_id(+)  ' ||
                ' AND mmt.transaction_type_id = tt.transaction_type_id(+)  ' ||
                ' AND mmt.transaction_source_type_id = st.transaction_source_type_id(+)  ' ||
                ' AND mmt.transaction_action_id=ml.lookup_code  ' ||
                ' AND ml.lookup_type = ''MTL_TRANSACTION_ACTION''  ' ||
                ' ORDER BY mmt.costed_flag, mmt.transaction_id ';

         dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transaction with invalid locator');

	 FOR rec_phy_adj IN c_phy_adj (rec_inv_loc.create_transaction_id, rec_inv_loc.update_transaction_id) LOOP

	     sqltxt := ' SELECT mpi.physical_inventory_name||''(''||mpi.physical_inventory_id||'')'' "Phy inv name(Id)",' ||
                       ' mpit.adjustment_id "Phy Adj id",' ||
                       ' mif.item_number||''(''||mif.inventory_item_id||'')'' "Item (Id)",' ||
                       ' mpit.subinventory "Subinv",' ||
                       ' mpit.locator_id "Stock locator"' ||
                       ' FROM mtl_physical_inventory_tags mpit, mtl_physical_inventories mpi, mtl_item_flexfields mif' ||
                       ' WHERE mpit.physical_inventory_id = mpi.physical_inventory_id' ||
                       ' and mpit.adjustment_id = ' || rec_phy_adj.physical_adjustment_id ||
                       ' AND mpit.inventory_item_id = mif.inventory_item_id(+)' ||
                       ' and mpit.locator_id is not null and not exists' ||
                       ' (select 1 from mtl_item_locations mil' ||
                       ' where mil.organization_id = mpit.organization_id' ||
                       ' and  mil.subinventory_code = mpit.subinventory' ||
                       ' and  mil.inventory_location_id = mpit.locator_id) ' ||
		       ' ORDER BY mpi.physical_inventory_id ';

	     dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Details of Physical Inventory');

             sqltxt :=  ' SELECT ' ||
                        ' MPA.ADJUSTMENT_ID,' ||
                        ' MPA.ORGANIZATION_ID,' ||
                        ' MPA.PHYSICAL_INVENTORY_ID,' ||
                        ' MPA.INVENTORY_ITEM_ID,' ||
                        ' MPA.SUBINVENTORY_NAME,' ||
                        ' MPA.SYSTEM_QUANTITY,' ||
                        ' MPA.LAST_UPDATE_DATE,' ||
                        ' MPA.LAST_UPDATED_BY,' ||
                        ' MPA.CREATION_DATE,' ||
                        ' MPA.CREATED_BY,' ||
                        ' MPA.LAST_UPDATE_LOGIN,' ||
                        ' MPA.COUNT_QUANTITY,' ||
                        ' MPA.ADJUSTMENT_QUANTITY,' ||
                        ' MPA.REVISION,' ||
                        ' MPA.LOCATOR_ID,' ||
                        ' MPA.LOT_NUMBER,' ||
                        ' MPA.LOT_EXPIRATION_DATE,' ||
                        ' MPA.SERIAL_NUMBER,' ||
                        ' MPA.ACTUAL_COST,' ||
                        ' MPA.APPROVAL_STATUS,' ||
                        ' MPA.APPROVED_BY_EMPLOYEE_ID,' ||
                        ' MPA.AUTOMATIC_APPROVAL_CODE,' ||
                        ' MPA.GL_ADJUST_ACCOUNT,' ||
                        ' MPA.REQUEST_ID,' ||
                        ' MPA.PROGRAM_APPLICATION_ID,' ||
                        ' MPA.PROGRAM_ID,' ||
                        ' MPA.PROGRAM_UPDATE_DATE,' ||
                        ' MPA.LOT_SERIAL_CONTROLS,' ||
                        ' MPA.TEMP_APPROVER,' ||
                        ' MPA.PARENT_LPN_ID,' ||
                        ' MPA.OUTERMOST_LPN_ID,' ||
                        ' MPA.COST_GROUP_ID' ||
                        ' FROM mtl_physical_adjustments mpa' ||
                        ' WHERE mpa.adjustment_id = ' || rec_phy_adj.physical_adjustment_id ||
                        ' and  locator_id is not null and not exists' ||
                        ' (select 1 from mtl_item_locations mil' ||
                        ' where mil.organization_id = mpa.organization_id' ||
                        ' and  mil.subinventory_code = mpa.subinventory_name' ||
                        ' and  mil.inventory_location_id = mpa.locator_id)' ||
                        ' ORDER BY mpa.physical_inventory_id ' ;

	     dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Details of Physical Inventory Adjustments');

	 END LOOP;

  END LOOP;


  reportStr := 'The test completed as expected';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
  statusStr := 'SUCCESS';
  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in INVDA02B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Accuracy';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'PI tags SubLoc mismtach';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'PI tags SubLoc mismtach';
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

PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY  JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_PI_SUBLOC;

/
