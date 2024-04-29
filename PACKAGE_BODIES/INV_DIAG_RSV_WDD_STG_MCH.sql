--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RSV_WDD_STG_MCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RSV_WDD_STG_MCH" AS
/* $Header: INVDP03B.pls 120.0.12000000.1 2007/06/22 01:14:56 musinha noship $ */

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

    sqltxt := ' select' ||
              ' mp.organization_code || '' ('' ||mr.organization_id|| '')'' "Organization Code (Id)"' ||
              ' ,mif.item_number||'' (''||mif.inventory_item_id||'')'' "Item (Id)"' ||
              ' ,mr.reservation_id "Rsv ID"' ||
              ' ,TO_CHAR( requirement_date, ''DD-MON-RR'' ) "Requirement Date"' ||
              ' , reservation_quantity' ||
              ' , primary_reservation_quantity' ||
              ' , detailed_quantity' ||
              ' , demand_source_type_id' ||
              ' , demand_source_name' ||
              ' , demand_source_header_id' ||
              ' , demand_source_line_id' ||
              ' , demand_source_delivery' ||
              ' , revision' ||
              ' , subinventory_code' ||
              ' , locator_id' ||
              ' , lot_number "Lot Number"' ||
              ' , serial_number "Serial Number"' ||
              ' , lpn_id' ||
              ' , TO_CHAR( mr.creation_date, ''DD-MON-RR'' ) "Creation DateE"' ||
              ' , TO_CHAR( mr.last_update_date, ''DD-MON-RR'' ) "Last UPDATE Date"' ||
              ' from mtl_reservations mr,' ||
               ' mtl_parameters mp,' ||
               ' mtl_item_flexfields mif' ||
               ' WHERE mr.organization_id = mp.organization_id (+)' ||
               ' AND mr.inventory_item_id = mif.inventory_item_id (+)' ||
               ' AND mr.organization_id = mif.organization_id (+)' ||
               ' AND mr.supply_source_type_id=13' ||
               ' and mr.demand_source_type_id in (2,8)' ||
               ' and nvl(mr.staged_flag,''N'') =''N''' ||
               ' and mr.demand_source_line_id in (select wdd1.source_line_id from' ||
                                                  ' wsh_delivery_details wdd1' ||
                                                  ' where wdd1.source_line_id=mr.demand_source_line_id' ||
                                                  ' and wdd1.source_code=''OE''' ||
                                                  ' and wdd1.released_status =''S''' ||
                                                  ' and not exists  (select 1 from' ||
                                                                     ' wsh_delivery_details wdd2' ||
                                                                     ' where  wdd2.source_line_id=wdd1.source_line_id' ||
                                                                     ' and  wdd2.source_code=''OE''' ||
                                                                     ' and  wdd2.released_status <> ''S''))' ||
               ' and mr.reservation_id not in (select reservation_id from' ||
                                               ' mtl_material_transactions_temp mmtt' ||
                                               ' where mmtt.trx_source_line_id=mr.demand_source_line_id' ||
                                               ' and mr.demand_source_type_id=mmtt.transaction_source_type_id' ||
                                               ' and mmtt.reservation_id is not null)  ';

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Unstaged Reservations');

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
      errStr := sqlerrm ||' occurred in script Exception handled';
      fixInfo := 'Unexpected Exception in INVDP03B.pls';
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
  descStr := 'Details of unstaged reservation with staged delivery';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Unstaged Reservation and Staged Delivery';
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

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;
END INV_DIAG_RSV_WDD_STG_MCH;

/
