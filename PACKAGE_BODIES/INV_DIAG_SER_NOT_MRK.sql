--------------------------------------------------------
--  DDL for Package Body INV_DIAG_SER_NOT_MRK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_SER_NOT_MRK" AS
/* $Header: INVDP05B.pls 120.0.12000000.1 2007/06/22 01:18:20 musinha noship $ */

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
    l_org_id NUMBER;
    l_item_id NUMBER;
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
    l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);


    sqltxt := ' SELECT count(*) ' ||
              ' FROM' ||
              ' mtl_serial_numbers msn ,' ||
              ' mtl_system_items msi,' ||
              ' wsh_delivery_details wdd' ||
              ' where msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and (msn.group_mark_id is NULL or msn.group_mark_id = -1 )' ||
              ' and msn.current_organization_id = wdd.organization_id ' ||
              ' and msn.inventory_item_id = wdd.inventory_item_id' ||
              ' and msn.serial_number = wdd.serial_number' ||
              ' and wdd.transaction_temp_id is null' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'')' ;

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Total number of staged serial and not marked, serial in delivery details');

    sqltxt := ' SELECT count(*) ' ||
              ' FROM' ||
              ' mtl_serial_numbers msn,' ||
              ' mtl_system_items msi,' ||
              ' wsh_delivery_details wdd,' ||
              ' mtl_serial_numbers_temp  msnt' ||
              ' where msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and ( group_mark_id is NULL or group_mark_id =-1 )' ||
              ' and msn.current_organization_id = wdd.organization_id ' ||
              ' and msn.inventory_item_id = wdd.inventory_item_id' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'')' ||
              ' and wdd.transaction_temp_id = msnt.transaction_temp_id' ||
              ' and msn.serial_number BETWEEN msnt.fm_serial_number and msnt.to_serial_number ';

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Total number of staged serial and not marked, serial in pending serials');

    sqltxt := ' SELECT count(*) ' ||
              ' FROM' ||
              ' mtl_serial_numbers msn ,' ||
              ' mtl_system_items msi,' ||
              ' wsh_delivery_details wdd,' ||
              ' wsh_serial_numbers wsn' ||
              ' where msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and ( group_mark_id is NULL or group_mark_id =-1 )' ||
              ' and msn.current_organization_id = wdd.organization_id ' ||
              ' and msn.inventory_item_id = wdd.inventory_item_id' ||
              ' and wdd.transaction_temp_id is not null' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'')' ||
              ' and wdd.delivery_detail_id = wsn.delivery_detail_id' ||
              ' and msn.serial_number BETWEEN wsn.fm_serial_number and wsn.to_serial_number ';

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Total number of staged serial and not marked, serial in deliveried serials');

    sqltxt := 'select mp.organization_code || '' ('' || msn.current_organization_id ||'')'' "Organization|Code (Id)" ,' ||
              ' msi.item_number || '' ('' || msn.inventory_item_id || '')'' "Item (Id)" ,' ||
              ' msn.serial_number "Serial Number",' ||
              ' msn.group_mark_id "Group Mark Id",' ||
              ' wdd.source_header_number "Order number",' ||
              ' wdd.source_line_id "Order line id",' ||
              ' wdd.delivery_Detail_id "Delivery detail Id"' ||
              ' from ' ||
              ' mtl_serial_numbers msn ,mtl_item_flexfields msi,' ||
              ' mtl_parameters mp, wsh_delivery_Details wdd' ||
              ' where mp.organization_id = msn.current_organization_id ' ||
              ' and msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3 ' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and (group_mark_id is NULL or group_mark_id =-1 ) ' ||
              ' and msn.serial_number = wdd.serial_number ' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'')' ||
              ' and wdd.organization_id=msn.current_organization_id' ||
              ' and wdd.inventory_item_id=msn.inventory_item_id' ||
              ' and wdd.serial_number=msn.serial_number' ||
              ' and wdd.transaction_temp_id is null ';

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of staged / shipped (and not inventory interfaced) serials, serials in deliver details');

    sqltxt := ' select mp.organization_code  || ''('' || msn.current_organization_id  || '')''  "Organization|Code (Id)" ,' ||
              ' msi.item_number    || ''('' ||   msn.inventory_item_id   || '')''  "Item (Id)" ,' ||
              ' msn.serial_number "Serial Number",' ||
              ' msn.group_mark_id "Group Mark Id",' ||
              ' wdd.source_header_number "Order number",' ||
              ' wdd.source_line_id "Order line id",' ||
              ' wdd.delivery_Detail_id "Delivery detail Id"' ||
              ' from   mtl_serial_numbers msn ,' ||
              ' mtl_item_flexfields msi,' ||
              ' mtl_parameters mp,    ' ||
              ' wsh_delivery_details wdd,' ||
              ' mtl_serial_numbers_temp msnt' ||
              ' where mp.organization_id = msn.current_organization_id' ||
              ' and msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and (group_mark_id is NULL or group_mark_id =-1 )' ||
              ' and msn.current_organization_id = wdd.organization_id ' ||
              ' and msn.inventory_item_id = wdd.inventory_item_id' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'')' ||
              ' and wdd.transaction_temp_id = msnt.transaction_temp_id' ||
              ' and msn.serial_number BETWEEN msnt.fm_serial_number and msnt.to_serial_number  ';

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of staged / shipped (and not inventory interfaced) serials, serial in pending serials');

    sqltxt := 'select mp.organization_code || '' ('' || msn.current_organization_id ||'')'' "Organization|Code (Id)" ,' ||
              ' msi.item_number || '' ('' || msn.inventory_item_id || '')'' "Item (Id)" ,' ||
              ' msn.serial_number "Serial Number",' ||
              ' msn.group_mark_id "Group Mark Id",' ||
              ' wdd.source_header_number "Order number",' ||
              ' wdd.source_line_id "Order line id",' ||
              ' wdd.delivery_Detail_id "Delivery detail Id"' ||
              ' from' ||
              ' mtl_serial_numbers msn ,mtl_item_flexfields msi,' ||
              ' mtl_parameters mp, wsh_serial_numbers wsn ,wsh_delivery_details wdd' ||
              ' where  mp.organization_id = msn.current_organization_id ' ||
              ' and msn.inventory_item_id=msi.inventory_item_id' ||
              ' and msi.organization_id=msn.current_organization_id' ||
              ' and msn.current_status =3 ' ||
              ' and msi.reservable_type=1' ||
              ' and msi.serial_number_control_code not in (1,6)' ||
              ' and ( group_mark_id is NULL or group_mark_id =-1) ' ||
              ' and wdd.transaction_temp_id is not NULL' ||
              ' and wsn.delivery_detail_id=wdd.delivery_detail_id' ||
              ' and wdd.organization_id=msn.current_organization_id' ||
              ' and wdd.inventory_item_id=msn.inventory_item_id' ||
              ' and wsn.fm_serial_number=msn.serial_number' ||
              ' and wsn.fm_serial_number=wsn.to_serial_number' ||
              ' and wdd.released_status in (''C'',''Y'') ' ||
              ' and wdd.inv_interfaced_flag in (''N'',''P'') ' ;

    IF l_org_id IS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.organization_id = ' || l_org_id ;
    END IF;

    IF l_item_id iS NOT NULL THEN
       sqltxt := sqltxt || ' and msi.inventory_item_id = ' || l_item_id ;
    END IF;

    dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of staged / shipped (and not inventory interfaced) serials, serials in delivered serials');

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
      fixInfo := 'Unexpected Exception in INVDP05B.pls';
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
  descStr := 'Details of staged / shipped (and not inventory interfaced) serials not marked';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
  BEGIN
    name := 'Staged Serial Not Marked';
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
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
    defaultInputValues := tempInput;

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

END INV_DIAG_SER_NOT_MRK;

/
