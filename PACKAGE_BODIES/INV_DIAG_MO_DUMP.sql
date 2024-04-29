--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MO_DUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MO_DUMP" as
/* $Header: INVDM05B.pls 120.0.12000000.1 2007/06/22 00:56:12 musinha noship $ */

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
                  report OUT NOCOPY  JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY  CLOB) IS

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
l_item_id NUMBER;
row_limit NUMBER;
l_script  VARCHAR2(30);


BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   row_limit := INV_DIAG_GRP.g_max_row;

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
   l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);
   l_script :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ScriptName',inputs);

   IF l_script = 'MTRH_DUMP' THEN

      sqltxt := ' SELECT ' ||
                ' MTRH.HEADER_ID,' ||
                ' MTRH.REQUEST_NUMBER,' ||
                ' MTRH.TRANSACTION_TYPE_ID,' ||
                ' MTRH.MOVE_ORDER_TYPE,' ||
                ' mp.organization_code || ''('' || MTRH.ORGANIZATION_ID ||'')'' "Organization|Code (Id)", ' ||
                ' MTRH.ORGANIZATION_ID,' ||
                ' MTRH.DESCRIPTION,' ||
                ' MTRH.DATE_REQUIRED,' ||
                ' MTRH.FROM_SUBINVENTORY_CODE,' ||
                ' MTRH.TO_SUBINVENTORY_CODE,' ||
                ' MTRH.TO_ACCOUNT_ID,' ||
                ' MTRH.HEADER_STATUS,' ||
                ' MTRH.STATUS_DATE,' ||
                ' MTRH.LAST_UPDATED_BY,' ||
                ' MTRH.LAST_UPDATE_LOGIN,' ||
                ' MTRH.LAST_UPDATE_DATE,' ||
                ' MTRH.CREATED_BY,' ||
                ' MTRH.CREATION_DATE,' ||
                ' MTRH.REQUEST_ID,' ||
                ' MTRH.PROGRAM_APPLICATION_ID,' ||
                ' MTRH.PROGRAM_ID,' ||
                ' MTRH.PROGRAM_UPDATE_DATE,' ||
                ' MTRH.GROUPING_RULE_ID,' ||
                ' MTRH.ATTRIBUTE1,' ||
                ' MTRH.ATTRIBUTE2,' ||
                ' MTRH.ATTRIBUTE3,' ||
                ' MTRH.ATTRIBUTE4,' ||
                ' MTRH.ATTRIBUTE5,' ||
                ' MTRH.ATTRIBUTE6,' ||
                ' MTRH.ATTRIBUTE7,' ||
                ' MTRH.ATTRIBUTE8,' ||
                ' MTRH.ATTRIBUTE9,' ||
                ' MTRH.ATTRIBUTE10,' ||
                ' MTRH.ATTRIBUTE11,' ||
                ' MTRH.ATTRIBUTE12,' ||
                ' MTRH.ATTRIBUTE13,' ||
                ' MTRH.ATTRIBUTE14,' ||
                ' MTRH.ATTRIBUTE15,' ||
                ' MTRH.ATTRIBUTE_CATEGORY,' ||
                ' MTRH.SHIP_TO_LOCATION_ID,' ||
                ' MTRH.FREIGHT_CODE,' ||
                ' MTRH.SHIPMENT_METHOD,' ||
                ' MTRH.AUTO_RECEIPT_FLAG,' ||
                ' MTRH.REFERENCE_ID,' ||
                ' MTRH.REFERENCE_DETAIL_ID,' ||
                ' MTRH.ASSIGNMENT_ID ' ||
                ' FROM MTL_TXN_REQUEST_HEADERS MTRH, MTL_PARAMETERS mp ' ;

	  IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ', MTL_TXN_REQUEST_LINES mtrl WHERE mtrh.organization_id = mp.organization_id AND mtrh.header_id = mtrl.header_id  AND mtrl.inventory_item_id = ' || l_item_id ;
          ELSE
             sqltxt := sqltxt || ' WHERE mtrh.organization_id = mp.organization_id ' ;
          END IF;

       IF l_org_id IS NOT NULL THEN
          sqltxt := sqltxt  || ' AND mtrh.organization_id = ' || l_org_id  || ' AND ROWNUM < ' || row_limit ;
       ELSE
          sqltxt := sqltxt  || ' AND ROWNUM < ' || row_limit ;
       END IF;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Dump of Move order headers (MTL_TXN_REQUEST_HEADERS)');

    ELSIF l_script = 'MTRL_DUMP' THEN
       sqltxt := ' SELECT  '||
                 ' MTRL.LINE_ID,' ||
                 ' MTRL.HEADER_ID,' ||
                 ' MTRL.LINE_NUMBER,' ||
                 ' mp.organization_code || ''('' || MTRL.ORGANIZATION_ID ||'')'' "Organization|Code (Id)", ' ||
    	         ' mif.item_number || ''(''|| mif.inventory_item_id || '')'' "Item (Id)", ' ||
                 ' MTRL.REVISION,' ||
                 ' MTRL.FROM_SUBINVENTORY_CODE,' ||
                 ' MTRL.FROM_LOCATOR_ID,' ||
                 ' MTRL.TO_SUBINVENTORY_CODE,' ||
                 ' MTRL.TO_LOCATOR_ID,' ||
                 ' MTRL.TO_ACCOUNT_ID,' ||
                 ' MTRL.LOT_NUMBER,' ||
                 ' MTRL.SERIAL_NUMBER_START,' ||
                 ' MTRL.SERIAL_NUMBER_END,' ||
                 ' MTRL.UOM_CODE,' ||
                 ' MTRL.QUANTITY,' ||
                 ' MTRL.QUANTITY_DELIVERED,' ||
                 ' MTRL.QUANTITY_DETAILED,' ||
                 ' MTRL.DATE_REQUIRED,' ||
                 ' MTRL.REASON_ID,' ||
                 ' MTRL.REFERENCE,' ||
                 ' MTRL.REFERENCE_TYPE_CODE,' ||
                 ' MTRL.REFERENCE_ID,' ||
                 ' MTRL.PROJECT_ID,' ||
                 ' MTRL.TASK_ID,' ||
                 ' MTRL.TRANSACTION_HEADER_ID,' ||
                 ' MTRL.LINE_STATUS,' ||
                 ' MTRL.STATUS_DATE,' ||
                 ' MTRL.LAST_UPDATED_BY,' ||
                 ' MTRL.LAST_UPDATE_LOGIN,' ||
                 ' MTRL.LAST_UPDATE_DATE,' ||
                 ' MTRL.CREATED_BY,' ||
                 ' MTRL.CREATION_DATE,' ||
                 ' MTRL.REQUEST_ID,' ||
                 ' MTRL.PROGRAM_APPLICATION_ID,' ||
                 ' MTRL.PROGRAM_ID,' ||
                 ' MTRL.PROGRAM_UPDATE_DATE,' ||
                 ' MTRL.ATTRIBUTE1,' ||
                 ' MTRL.ATTRIBUTE2,' ||
                 ' MTRL.ATTRIBUTE3,' ||
                 ' MTRL.ATTRIBUTE4,' ||
                 ' MTRL.ATTRIBUTE5,' ||
                 ' MTRL.ATTRIBUTE6,' ||
                 ' MTRL.ATTRIBUTE7,' ||
                 ' MTRL.ATTRIBUTE8,' ||
                 ' MTRL.ATTRIBUTE9,' ||
                 ' MTRL.ATTRIBUTE10,' ||
                 ' MTRL.ATTRIBUTE11,' ||
                 ' MTRL.ATTRIBUTE12,' ||
                 ' MTRL.ATTRIBUTE13,' ||
                 ' MTRL.ATTRIBUTE14,' ||
                 ' MTRL.ATTRIBUTE15,' ||
                 ' MTRL.ATTRIBUTE_CATEGORY,' ||
                 ' MTRL.TXN_SOURCE_ID,' ||
                 ' MTRL.TXN_SOURCE_LINE_ID,' ||
                 ' MTRL.TXN_SOURCE_LINE_DETAIL_ID,' ||
                 ' MTRL.TRANSACTION_TYPE_ID,' ||
                 ' MTRL.TRANSACTION_SOURCE_TYPE_ID,' ||
                 ' MTRL.PRIMARY_QUANTITY,' ||
                 ' MTRL.TO_ORGANIZATION_ID,' ||
                 ' MTRL.PUT_AWAY_STRATEGY_ID,' ||
                 ' MTRL.PICK_STRATEGY_ID,' ||
                 ' MTRL.SHIP_TO_LOCATION_ID,' ||
                 ' MTRL.UNIT_NUMBER,' ||
                 ' MTRL.REFERENCE_DETAIL_ID,' ||
                 ' MTRL.ASSIGNMENT_ID,' ||
                 ' MTRL.FROM_COST_GROUP_ID,' ||
                 ' MTRL.TO_COST_GROUP_ID,' ||
                 ' MTRL.LPN_ID,' ||
                 ' MTRL.TO_LPN_ID,' ||
                 ' MTRL.PICK_SLIP_NUMBER,' ||
                 ' MTRL.PICK_SLIP_DATE,' ||
                 ' MTRL.INSPECTION_STATUS,' ||
                 ' MTRL.PICK_METHODOLOGY_ID,' ||
                 ' MTRL.CONTAINER_ITEM_ID,' ||
                 ' MTRL.CARTON_GROUPING_ID,' ||
                 ' MTRL.BACKORDER_DELIVERY_DETAIL_ID,' ||
                 ' MTRL.WMS_PROCESS_FLAG,' ||
                 ' MTRL.SHIP_SET_ID,' ||
                 ' MTRL.SHIP_MODEL_ID,' ||
                 ' MTRL.MODEL_QUANTITY,' ||
                 ' MTRL.FROM_SUBINVENTORY_ID,' ||
                 ' MTRL.TO_SUBINVENTORY_ID,' ||
                 ' MTRL.CROSSDOCK_TYPE,' ||
                 ' MTRL.REQUIRED_QUANTITY' ||
                 ' FROM MTL_TXN_REQUEST_LINES MTRL, MTL_PARAMETERS mp, MTL_ITEM_FLEXFIELDS mif ' ||
    	         ' WHERE MTRL.organization_id = mp.organization_id ' ||
    	         ' AND MTRL.inventory_item_id = mif.inventory_item_id(+) ' ||
    	         ' AND MTRL.organization_id = mif.organization_id(+) ' ;

       IF l_org_id IS NOT NULL THEN
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MTRL.organization_id = ' || l_org_id || ' AND MTRL.inventory_item_id = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND MTRL.organization_id = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
          END IF;

       ELSE
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MTRL.inventory_item_id = ' || l_item_id  || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit ;
          END IF;

       END IF;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Dump of Move Order Lines');

    ELSE
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'Please execute the report with Script Name');
       JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Script Name');
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please choose correct Script Name');
       statusStr := 'FAILURE';
       errStr := 'Invalid Script Name';
       fixInfo := 'Please choose correct Script Name';
       isFatal := 'FALSE';
       report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
       reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
       RETURN;
    END IF;

   reportStr := ' Note: Only first 199 rows are returned by this script. The test completed as expected';
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
    fixInfo := 'Unexpected Exception in INVDM05B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Move Orders';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'Dump of Move Order Tables';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Dump of Move Order';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY   JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY   VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;

PROCEDURE getOutputValues(outputValues OUT NOCOPY   JTF_DIAG_OUTPUTTBL) IS
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
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ScriptName','LOV-oracle.apps.inv.diag.lov.MODumpScriptsLov');
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_DIAG_MO_DUMP;

/
