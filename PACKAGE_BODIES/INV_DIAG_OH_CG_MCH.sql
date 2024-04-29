--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OH_CG_MCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OH_CG_MCH" as
/* $Header: INVDO07B.pls 120.0.12000000.1 2007/06/22 01:06:01 musinha noship $ */

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
BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');



   sqltxt := ' select  ' ||
             ' mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)"' ||
             ' ,mif.item_number|| '' (''||moqd.inventory_item_id||'')'' "Item (Id)",' ||
             ' mil.project_id "Proj Id",' ||
             ' mil.segment19 "Segment 19",' ||
             ' moqd.subinventory_code "subinv",' ||
             ' moqd.locator_id "Locator",' ||
             ' moqd.cost_group_id "Cost group id",' ||
             ' mproj.costing_group_id "Proj cost group id"' ||
             ' from mtl_onhand_quantities_detail moqd,' ||
             ' mtl_parameters mp,' ||
             ' mtl_item_flexfields mif,' ||
             ' mtl_item_locations_kfv mil,' ||
             ' mrp_project_parameters mproj' ||
             ' where moqd.inventory_item_id=mif.inventory_item_id' ||
             ' and moqd.organization_id=mif.organization_id' ||
             ' and moqd.organization_id=mp.organization_id' ||
             ' and moqd.organization_id=mil.organization_id' ||
             ' and moqd.locator_id=mil.inventory_location_id' ||
             ' and mil.project_id=mproj.project_id' ||
             ' and mil.organization_id=mproj.organization_id ' ||
             ' and mproj.costing_group_id <> moqd.cost_group_id ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of MOQD cost group mismatch.');

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
    fixInfo := 'Unexpected Exception in INVDO07B.pls';
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
   descStr := 'Onhand Cost Group does not match with Project Mfg';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Onhand CostGrp Mismatch for Project Mfg';
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
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_DIAG_OH_CG_MCH;

/
