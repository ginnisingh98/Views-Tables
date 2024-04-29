--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MSN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MSN" as
/* $Header: INVDS01B.pls 120.0.12000000.1 2007/06/22 01:22:39 musinha noship $ */
PROCEDURE init is
BEGIN
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
counter   NUMBER;
dummy_v2t JTF_DIAGNOSTIC_COREAPI.v2t;
c_userid  VARCHAR2(50);
statusStr VARCHAR2(50);
errStr    VARCHAR2(4000);
fixInfo   VARCHAR2(4000);
isFatal   VARCHAR2(50);
dummy_num NUMBER;
sqltxt    VARCHAR2 (2000);
l_sn   VARCHAR2(30);
l_item_id number;
l_org_id  NUMBER;
l_org_code VARCHAR2(3);
l_txn_id  NUMBER;
row_limit NUMBER;

BEGIN

JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_sn := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('SerialNum',inputs);
l_item_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('OrgID input : '||l_org_id||'  Serial '||l_sn||'  ItemId : '||l_item_id);
row_limit :=INV_DIAG_GRP.g_max_row;
test_out :='MSN';
reportStr :='';

if l_sn is not null or l_item_id is not null then

    sqltxt :='SELECT msn.serial_number "Serial|Number" '||
             ', msn.inventory_item_id "Item ID" '||
             ', ml.meaning || '' ( '' || msn.current_status || '' )'' "Current Status (Id)" '||
             ', msn.current_subinventory_code "Current|Subinventory" '||
             ', msn.current_locator_id "Current|Locator Id" '||
             ', msn.cost_group_id "Cost Group|Id" '||
             ', msn.lpn_id "LPN Id" '||
             ', msn.group_mark_id "Group Mark|Id" '||
             ', msn.line_mark_id "Line Mark|Id" '||
             ', msn.lot_line_mark_id "Lot Line Mark|Id" '||
             ', TO_CHAR( msn.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last|Updated" '||
             ', msn.last_transaction_id "Last Transaction ID" '||
             ', msn.wip_entity_id "WIP Entity ID" '||
             ', msn.original_wip_entity_id "Original|WIP Entity ID" '||
             'FROM mtl_serial_numbers msn  '||
             ', mfg_lookups ml '||
             'WHERE 1 = 1 ';

    if l_org_id is not null then
       sqltxt := sqltxt||' and msn.current_organization_id = '||l_org_id;
    end if;
    if l_sn is not null then
       sqltxt := sqltxt||' AND msn.serial_number = '''||l_sn||'''';
    end if;
    if l_item_id is not null then
       sqltxt := sqltxt||' AND msn.inventory_item_id = '||l_item_id;
    end if;
    sqltxt := sqltxt||' AND msn.current_status = ml.lookup_code(+)'||
             'AND ''SERIAL_NUM_STATUS'' = ml.lookup_type(+)'||
             'ORDER BY msn.serial_number ';

    sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

    dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Serial Status');

    delete from inv_diag_msn_temp;

    insert into inv_diag_msn_temp
           (serial_number
           ,org_id
           ,inventory_item_id)
    select distinct serial_number, current_organization_id,inventory_item_id
        from mtl_serial_numbers
       where inventory_item_id = nvl(l_item_id, inventory_item_id)
         and current_organization_id = nvl(l_org_id, current_organization_id)
         and serial_number = nvl(l_sn, serial_number);

    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
    statusStr := 'SUCCESS';

  ELSE

    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Parameter input is requred ');
    statusStr := 'FAILURE';
    errStr := 'This test failed as: no input';
    fixInfo := 'Please enter at least one of the following parameters: Serial or ItemId';
    isFatal := 'SUCCESS';

end if;

report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
when others then
-- this should never happen
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('Exception Occurred In RUNTEST');
reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
raise;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Serial Status';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Checks for Serial Status';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'MSN';
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
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.addOutput(tempOutput,'testout', test_out);
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'SerialNum','LOV-oracle.apps.inv.diag.lov.SerialLov');
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

END;

/
