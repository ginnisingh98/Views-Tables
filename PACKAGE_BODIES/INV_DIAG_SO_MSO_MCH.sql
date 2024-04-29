--------------------------------------------------------
--  DDL for Package Body INV_DIAG_SO_MSO_MCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_SO_MSO_MCH" as
/* $Header: INVDP01B.pls 120.0.12000000.1 2007/06/22 01:11:50 musinha noship $ */

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
l_order_number NUMBER;
l_org_id NUMBER;
l_resp       fnd_responsibility_tl.Responsibility_Name%type :='Inventory';

BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   /*
   -- check whether user has 'Inventory' responsibilty to execute diagnostics script.
   IF NOT INV_DIAG_GRP.check_responsibility(p_responsibility_name => l_resp) THEN  -- l_resp = 'Inventory'
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' You do not have the privilege to run this Diagnostics.');
      statusStr := 'FAILURE';
      errStr := 'This test requires Inventory Responsibility Role';
      fixInfo := 'Please contact your sysadmin to get Inventory Responsibility';
      isFatal := 'FALSE';
      report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      RETURN;
   END IF;
   */

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
   l_order_number := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrderNo',inputs);

   IF l_org_id IS NULL OR l_order_number IS NULL THEN
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'Please execute the report with organization and Sales order information');
       JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Organization or Sales Order ');
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter correct organization and Sales Order Number');
       statusStr := 'FAILURE';
       errStr := 'Invalid Organization Sales Order Combination';
       fixInfo := 'Please enter Organization and Sales Order information';
       isFatal := 'FALSE';
       report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
       reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
       RETURN;
   END IF;

   FND_CLIENT_INFO.SET_ORG_CONTEXT('' || l_org_id || '');

   sqltxt := ' select FND_PROFILE.value(''OE_SOURCE_CODE'') "OE_SOURCE_CODE" from dual ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Profile (OE_SROUCE_CODE) value');

   sqltxt := ' select segment1 "Segment 1",segment2 "Segment 2",segment3 "Segment 3",sales_order_id  "Sales Order Id"' ||
              ' from mtl_sales_orders ' ||
              ' where segment1=' || '''' || l_order_number || '''';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Segments value for the sales order ');

   sqltxt := ' SELECT order_number,' ||
              ' NAME || ''(''  || order_type_id || '')'' "Order Type (ID)",  ' ||
	      ' FND_PROFILE.VALUE(''ONT_SOURCE_CODE'') "Order Source"' ||
              ' FROM oe_order_headers oeh,OE_TRANSACTION_TYPES_TL OTT' ||
              ' WHERE order_number = ' || l_order_number ||
              ' AND ott.TRANSACTION_TYPE_ID = oeh.order_type_id' ||
              ' AND language = (select language_code from' ||
              ' fnd_languages' ||
              ' where installed_flag = ''B'') ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of Sales Order');

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
    errStr := sqlerrm ||' occurred in script INVDP01B.pls Exception handled';
    fixInfo := 'Unexpected Exception in INVDP01B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name := 'Pick Release and Reservation';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Sales Order MSO mismatch';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Sales Order Identifier Information';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
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
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrderNo','LOV-oracle.apps.inv.diag.lov.SOLov');
  defaultInputValues := tempInput;
EXCEPTION
when others then
  defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_SO_MSO_MCH;

/
