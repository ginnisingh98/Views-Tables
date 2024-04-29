--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OH_COMINGLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OH_COMINGLING" as
/* $Header: INVDOH4B.pls 120.0.12010000.2 2009/04/09 12:43:40 aambulka noship $ */

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
 row_limit   NUMBER;
 l_org_id    NUMBER;

BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

  l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);

sqltxt := ' SELECT mp.organization_code' ||
              ' || '' (''' ||
              ' ||x.organization_id' ||
              ' ||'')'' "Organization|Code (Id)" ,' ||
              ' mif.item_number' ||
              ' || '' (''' ||
              ' ||x.inventory_item_id' ||
              ' ||'')'' "Item (Id)" ,' ||
              ' x.subinventory_code  "Subinv" ,' ||
              ' x.locator_id      "Loc id"       ,' ||
              ' x.lot_number      "Lot Number"   ,' ||
              ' mtsv.status_code' ||
              ' ||'' (''' ||
              ' ||x.status_id' ||
              ' ||'')'' "StatusCode (Id)"' ||
              ' FROM' ||
              ' ( SELECT  organization_id ,' ||
              ' inventory_item_id,' ||
                ' subinventory_code,' ||
                ' locator_id       ,' ||
                ' lot_number       ,' ||
                ' status_id        ,' ||
                ' COUNT(*) C1' ||
                ' FROM     mtl_onhand_quantities_detail moqd1' ||
		' WHERE lpn_id is null ' ||
       ' GROUP BY organization_id   ,' ||
       ' inventory_item_id ,' ||
                ' subinventory_code ,' ||
                ' locator_id        ,' ||
                ' lot_number        ,' ||
                ' status_id' ||
                ' ) X                       ,' ||
       ' (SELECT  organization_id  ,' ||
       ' inventory_item_id,' ||
                ' subinventory_code,' ||
                ' locator_id       ,' ||
                ' lot_number       ,' ||
                ' COUNT(*) C2' ||
                ' FROM     mtl_onhand_quantities_detail moqd2' ||
		' WHERE lpn_id is null ' ||
       ' GROUP BY organization_id   ,' ||
       ' inventory_item_id ,' ||
                ' subinventory_code ,' ||
                ' locator_id        ,' ||
                ' lot_number' ||
                ' ) Y                     ,' ||
       ' mtl_parameters mp       ,' ||
       ' mtl_item_flexfields mif ,' ||
       ' mtl_material_statuses_vl mtsv' ||
       ' WHERE  mp.organization_id       = x.organization_id' ||
' AND x.organization_id        = mif.organization_id' ||
   ' AND x.inventory_item_id      = mif.inventory_item_id' ||
   ' AND x.organization_id        = y.organization_id' ||
   ' AND x.inventory_item_id      = y.inventory_item_id' ||
   ' AND x.subinventory_code      = y.subinventory_code' ||
   ' AND NVL(x.locator_id,-9999)  = NVL(y.locator_id,-9999)' ||
   ' AND NVL(x.lot_number,''@@@@'') = NVL(y.lot_number,''@@@@'')' ||
   ' AND x.C1                    <> y.C2' ||
   ' AND mtsv.status_id           = x.status_id' ||
   ' AND mp.default_status_id IS NOT NULL' ||
   ' AND mif.serial_number_control_code IN (1,6) ';

   IF l_org_id IS NOT NULL THEN
      sqltxt := sqltxt  || ' AND x.organization_id = ' || l_org_id ;
   END IF;
      sqltxt := sqltxt  ||
    ' ORDER BY x.organization_id, x.inventory_item_id,'||
    ' x.subinventory_code, x.locator_id, x.lot_number';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Onhand Records for which commingling of the status exists');

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
    fixInfo := 'Unexpected Exception in INVDOH4B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'MATSTATUS';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := 'Onhand Records for which commingling of the status exist';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Commingling of Status in Onhand';
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
END INV_DIAG_OH_COMINGLING;

/
