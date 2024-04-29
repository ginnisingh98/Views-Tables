--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RSV_HDR_ZERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RSV_HDR_ZERO" AS
/* $Header: INVDP02B.pls 120.0.12000000.1 2007/06/22 01:13:28 musinha noship $ */

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
    sqltxt VARCHAR2 (2000);
  BEGIN
    JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
    JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
    --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

    sqltxt := ' SELECT MR.RESERVATION_ID RSV_ID,' ||
              ' MR.DEMAND_SOURCE_LINE_ID ORDER_LINE_ID,' ||
              ' MR.INVENTORY_ITEM_ID ITEM_ID,' ||
              ' MR.ORGANIZATION_ID ORG_ID,' ||
              ' MR.PRIMARY_RESERVATION_QUANTITY PRSV_QTY' ||
              ' FROM  MTL_RESERVATIONS MR' ||
              ' WHERE DEMAND_SOURCE_TYPE_ID IN (2,8)' ||
              ' AND NVL(DEMAND_SOURCE_HEADER_ID, 0) = 0' ||
              ' AND SUPPLY_SOURCE_TYPE_ID = 13 ';

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Reservation details with DEMAND_SOURCE_HEADER_ID as 0');

    sqltxt := ' SELECT MD.DEMAND_ID DEMD_ID,' ||
              ' MD.DEMAND_SOURCE_LINE ORDER_LINE_ID,' ||
              ' MD.INVENTORY_ITEM_ID ITEM_ID,' ||
              ' MD.ORGANIZATION_ID ORG_ID,' ||
              ' MD.PRIMARY_UOM_QUANTITY PDEMD_QTY' ||
              ' FROM  MTL_DEMAND MD' ||
              ' WHERE DEMAND_SOURCE_TYPE IN (2,8)' ||
              ' AND NVL(DEMAND_SOURCE_HEADER_ID, 0) = 0' ||
              ' AND NVL(SUPPLY_SOURCE_TYPE, 13) = 13 ';

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Demand details with DEMAND_SOURCE_HEADER_ID as 0');

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
      errStr := sqlerrm ||' occurred in script  Exception handled';
      fixInfo := 'Unexpected Exception in INVDP02B.pls';
      isFatal := 'FALSE';
      report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
  END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
  name := 'Pick Release and Reservation';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
  BEGIN
  descStr := 'Details of Reservation with DEMAND_SOURCE_HEADER_ID as 0';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Reservations with HDR zero';
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
  EXCEPTION
    when others then
      defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  END getDefaultTestParams;

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

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_RSV_HDR_ZERO;

/
