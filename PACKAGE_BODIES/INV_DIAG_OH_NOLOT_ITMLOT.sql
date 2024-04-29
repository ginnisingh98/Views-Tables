--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OH_NOLOT_ITMLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OH_NOLOT_ITMLOT" as
/* $Header: INVDO02B.pls 120.0.12000000.1 2007/06/22 00:58:56 musinha noship $ */

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

  sqltxt :='select  mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)"' ||
           ' ,mif.item_number|| '' (''||moqd.inventory_item_id||'')'' "Item (Id)" ' ||
           ' ,moqd.locator_id "Loc id",moqd.lot_number "Lot number",moqd.revision "Rev", moqd.subinventory_code "Subinv" ' ||
           ' from mtl_onhand_quantities_detail moqd,' ||
           ' mtl_parameters mp,mtl_item_flexfields mif' ||
           ' where moqd.organization_id = mp.organization_id(+)' ||
           ' and moqd.inventory_item_id = mif.inventory_item_id(+)' ||
           ' and moqd.organization_id = mif.organization_id(+)';

   IF l_org_id IS NOT NULL THEN
      sqltxt := sqltxt  || ' and moqd.organization_id = ' || l_org_id ;
   END IF;
      sqltxt := sqltxt  ||
           ' and   moqd.lot_number is null' ||
           ' and exists (select 1 from mtl_system_items_b msib' ||
           '            where msib.inventory_item_id= moqd.inventory_item_id' ||
           '             and   msib.organization_id = moqd.organization_id' ||
           '            and   msib.lot_control_code=2)'  ||
           ' group  by ' ||
           ' mp.organization_code || '' ('' || moqd.organization_id  || '')'',' ||
           ' mif.item_number|| '' (''||moqd.inventory_item_id||'')'',' ||
           ' moqd.inventory_item_id, moqd.subinventory_code, moqd.locator_id, moqd.lot_number, moqd.revision' ;



   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Onhand without Lot number for Lot controlled Item');

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
    fixInfo := 'Unexpected Exception in INVDO02B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Onhand';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := 'Items is lot controlled and onhand without Lot';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Onhand NoLot Item Lot';
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
END INV_DIAG_OH_NOLOT_ITMLOT;

/
