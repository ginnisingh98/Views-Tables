--------------------------------------------------------
--  DDL for Package Body INV_DIAG_PI_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_PI_ONHAND" as
/* $Header: INVDA01B.pls 120.0.12000000.1 2007/06/22 00:33:51 musinha noship $ */

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
 l_phy_inv_id NUMBER;
 l_org_id NUMBER;
 l_item_id NUMBER;

BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

  l_phy_inv_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PhyInvId',inputs);
  l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
  l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);

  -- accept input
  sqltxt := ' SELECT  org "OrganizationCode (Id)"' ||
            ' ,item "Item (Id)",rev "Rev",' ||
            ' sub "Subinv",' ||
            ' loc "Locator id",' ||
            ' onhand "Onhand Qty",' ||
            ' qty_avail "Available Qty",' ||
            ' Adj_qty "Adj Qty"' ||
            ' from' ||
            ' (select mp.organization_code|| '' (''||mpa.organization_id ||'')'' org, msi.concatenated_segments || '' (''||mpa.inventory_item_id ||'')'' item, ' ||
            ' mpa.revision rev, mpa.subinventory_name sub, mpa.locator_id loc, mpa.lot_number lot,' ||
	    ' INV_DIAG_GRP.CHECK_ONHAND(mpa.inventory_item_id, mpa.organization_id, mpa.revision, mpa.subinventory_name, mpa.locator_id) onhand, ' ||
            ' INV_DIAG_GRP.CHECK_AVAIL(mpa.inventory_item_id,mpa.organization_id,mpa.revision, mpa.subinventory_name,mpa.locator_id) qty_avail, ' ||
            ' sum(adjustment_quantity) adj_qty' ||
            ' from mtl_physical_adjustments mpa, mtl_system_items_kfv msi,mtl_parameters mp' ||
            ' where mpa.approval_status is null and mpa.adjustment_quantity < 0 ' ||
            ' and   mpa.inventory_item_id = msi.inventory_item_id' ||
            ' and   mpa.organization_id = msi.organization_id' ||
            ' and   mp.organization_id = mpa.organization_id ' ;

  IF l_phy_inv_id IS NOT NULL THEN
      sqltxt := sqltxt  || ' AND mpa.physical_inventory_id = ' || l_phy_inv_id ;
  END IF;

  IF l_org_id IS NOT NULL THEN
     sqltxt := sqltxt || ' AND mpa.organization_id = ' || l_org_id ;
  END IF;

  IF l_item_id IS NOT NULL THEN
     sqltxt := sqltxt || ' AND mpa.inventory_item_id = ' || l_item_id;
  END IF;

     sqltxt := sqltxt || ' group by mp.organization_code|| '' (''||mpa.organization_id ||'')'', mpa.inventory_item_id, ' ||
                         ' msi.concatenated_segments, mpa.revision, mpa.subinventory_name, mpa.locator_id, mpa.lot_number, ' ||
                         ' INV_DIAG_GRP.CHECK_ONHAND(mpa.inventory_item_id, mpa.organization_id, mpa.revision, mpa.subinventory_name, mpa.locator_id), ' ||
                         ' INV_DIAG_GRP.CHECK_AVAIL(mpa.inventory_item_id,mpa.organization_id,mpa.revision, mpa.subinventory_name,mpa.locator_id) ' ||
                         ' order by mpa.inventory_item_id)' ||
                         ' where abs(adj_qty) > qty_avail ';

  dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Details of Physical Inventory Tags without onhand');
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
    fixInfo := 'Unexpected Exception in INVDA01B.pls';
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
descStr := 'PI tags without onhand';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'PI tags without onhand';
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
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PhyInvId','LOV-oracle.apps.inv.diag.lov.PhysInvLov');
   defaultInputValues := tempInput;
EXCEPTION
   when others then
      defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_PI_ONHAND;

/
