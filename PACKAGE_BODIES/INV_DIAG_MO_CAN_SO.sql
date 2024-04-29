--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MO_CAN_SO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MO_CAN_SO" as
/* $Header: INVDM02B.pls 120.0.12000000.1 2007/06/22 00:54:42 musinha noship $ */

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
l_line_id NUMBER;
l_org_id NUMBER;

BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
   l_line_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('LineId',inputs);

   IF l_org_id IS NULL THEN
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'Please execute the report with organization information');
       JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Organization Identifier');
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter correct organization Identifier');
       statusStr := 'FAILURE';
       errStr := 'Invalid Organization Identifier';
       fixInfo := 'Please enter or choose Organization identifier';
       isFatal := 'FALSE';
       report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
       reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
       RETURN;
   END IF;

   FND_CLIENT_INFO.SET_ORG_CONTEXT('' || l_org_id || '');

    sqltxt := ' select ' ||
              ' mp.organization_code|| '' (''||mtr.organization_id ||'')'' "Organization|Code (Id)"' ||
              ' ,mif.item_number|| '' (''||mtr.inventory_item_id||'')'' "Item (Id)" ,' ||
              ' mtr.request_number "MO Number",' ||
              ' move_order_type "MO Type",' ||
              ' mtr.quantity_detailed "Qty Detailed",' ||
              ' mmtt_sum "Sum MMTT qty"               ' ||
              ' from  (SELECT move_order_line_id, sum(abs(transaction_quantity)) mmtt_sum' ||
                      ' FROM   mtl_material_transactions_temp ' ||
                      ' group BY move_order_line_id) mmtt , ' ||
                      ' ( select mtrl.organization_id, mtrl.inventory_item_id ,request_number,move_order_type, mtrh.header_id, line_id ,quantity_detailed from' ||
                      ' mtl_txn_Request_headers mtrh, mtl_Txn_Request_lines mtrl' ||
                      ' WHERE mtrh.header_id = mtrl.header_id'  ||
		      ' AND   mtrl.organization_id = ' || l_org_id  ;
    IF l_line_id IS NOT NULL THEN
        sqltxt := sqltxt || ' and mtrl.line_id = '||  l_line_id  || ') mtr,' ;
    ELSE
        sqltxt := sqltxt || ' ) mtr,' ;
    END IF;
        sqltxt := sqltxt ||
              ' mtl_parameters mp,mtl_item_flexfields mif' ||
              ' where mmtt.move_order_line_id = mtr.line_id' ||
              ' and mtr.organization_id = mp.organization_id(+)' ||
              ' and mtr.inventory_item_id = mif.inventory_item_id(+)' ||
              ' and mtr.organization_id = mif.organization_id(+) ';

    dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of Move Order');


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
    fixInfo := 'Unexpected Exception in INVDM02B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Move Orders';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := 'Allocation exists for cancelled Sales Orders';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Allocations for canceled Sales Order';
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
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'MoNumber','');
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'LineId','LOV-oracle.apps.inv.diag.lov.MOLineLov');
   -- tempInput := JTF_DIAGNOSTIC_
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_DIAG_MO_CAN_SO;

/
