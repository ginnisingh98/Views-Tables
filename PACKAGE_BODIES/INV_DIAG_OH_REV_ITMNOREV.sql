--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OH_REV_ITMNOREV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OH_REV_ITMNOREV" as
/* $Header: INVDO03B.pls 120.0.12000000.1 2007/06/22 01:00:27 musinha noship $ */

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
l_org_id NUMBER;
BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);


   IF l_org_id IS NOT NULL THEN

      sqltxt := 'select  mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)"' ||
                ' ,mif.item_number|| '' (''||moqd.inventory_item_id||'')'' "Item (Id)" ' ||
                ' ,moqd.subinventory_code "Subinv", moqd.locator_id "Loc id",moqd.lot_number "Lot number",moqd.revision "Rev" ' ||
                ' from mtl_onhand_quantities_detail moqd,' ||
                ' mtl_parameters mp,mtl_item_flexfields mif' ||
                ' where moqd.organization_id = mp.organization_id' ||
                ' and moqd.inventory_item_id = mif.inventory_item_id' ||
                ' and moqd.organization_id = mif.organization_id' ||
                ' and moqd.revision is not null ' ||
                ' and moqd.organization_id = ' || l_org_id ||
                ' and exists (select 1 from mtl_system_items ' ||
                             ' where inventory_item_id = moqd.inventory_item_id ' ||
                             ' and organization_id = moqd.organization_id ' ||
                             ' and revision_qty_control_code = 1)' ||
                ' group  by ' ||
                ' mp.organization_code || '' ('' || moqd.organization_id  || '')'',' ||
                ' mif.item_number|| '' (''||moqd.inventory_item_id||'')'',' ||
                ' moqd.inventory_item_id, moqd.subinventory_code, moqd.locator_id, moqd.lot_number, moqd.revision' ;

      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Onhand with Revision for item not revision controlled');

   ELSE

      sqltxt := ' select ' ||
                ' mp.organization_code || '' ('' || t.organization_id  || '')'' "Organization|Code (Id)"' ||
                ' ,mif.item_number|| '' (''||t.inventory_item_id||'')'' "Item (Id)" ,' ||
                ' t.subinventory_code "Subinv", t.locator_id "Locator_id", t.lot_number "Lot num", t.revision "Rev"' ||
                ' from temp_disc_inv_cg_loose t, mtl_parameters mp, mtl_item_flexfields mif' ||
                ' where  ' ||
                ' t.organization_id = mp.organization_id(+)' ||
                ' and t.inventory_item_id = mif.inventory_item_id(+)' ||
                ' and t.organization_id = mif.organization_id(+)' ||
                ' and t.revision is not null' ||
                ' and exists (select 1 from mtl_system_items ' ||
                             ' where inventory_item_id = t.inventory_item_id ' ||
                             ' and organization_id = t.organization_id ' ||
                             ' and revision_qty_control_code =1 )' ||
                ' group  by ' ||
                ' mp.organization_code || '' ('' || t.organization_id  || '')'',' ||
                ' mif.item_number|| '' (''||t.inventory_item_id||'')'',' ||
                ' t.inventory_item_id, t.subinventory_code, t.locator_id, t.lot_number, t.revision' ;

      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,' Onhand with Revision for item not revision controlled.');
      JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' Please execute with organization identifier to identify the revision mismatch for an organization.');
      JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,' Alternatively user can execute the mismatch script mentioned in Note 279205.1  and then this script without organization identifier to identify revision mismatches across organization.');

   END IF;

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
    fixInfo := 'Unexpected Exception in INVDO03B.pls';
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
descStr := 'Onhand with revision when item is not revision controlled';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Onhand Rev Item NoRev';
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
  defaultInputValues := tempInput;
EXCEPTION
when others then
  defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_OH_REV_ITMNOREV;

/
