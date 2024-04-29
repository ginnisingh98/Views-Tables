--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MO" as
/* $Header: INVDM01B.pls 120.0.12000000.1 2007/06/22 00:53:18 musinha noship $ */

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
 num_rows	   NUMBER;
 l_txn_id    NUMBER;
 l_org_id    NUMBER;
 l_acct_period_id NUMBER;
 l_proc_flag varchar2(1);
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_acct_period_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('AcctId',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ProcFlag',inputs);

-- l_txn_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('testout',inputs);

sqltxt :='SELECT DISTINCT period_name "Period|Name" '||
         ' , oap.acct_period_id "Period|Id"  '||
         ' , mp.organization_code "Organization|Code"  '||
         ' , mmtt.organization_id "Organization|Id" '||
         ' , TO_CHAR( period_start_date, ''DD-MON-YYYY'' ) "Start Date"  '||
         ' , TO_CHAR( period_close_date, ''DD-MON-YYYY'' ) "Close Date"  '||
         ' , TO_CHAR( schedule_close_date, ''DD-MON-YYYY'' ) "Scheduled |Close Date"  '||
         ' , open_flag "Open"  '||
         ' , description "Description"  '||
         ' , period_set_name "GL Period Set|Name"  '||
         ' , period_name "GL Period|Name"  '||
         ' , period_year "GL Period|Year"  '||
         ' FROM mtl_material_transactions_temp mmtt, mtl_parameters mp '||
         ' , org_acct_periods oap  '||
         'WHERE NVL( mmtt.transaction_status,1 ) != 2  '||
         'AND mmtt.organization_id=mp.organization_id(+)  '||
         'AND mmtt.acct_period_id=oap.acct_period_id(+)';
if l_org_id is not null then
   sqltxt :=sqltxt||'AND mmtt.organization_id = '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt :=sqltxt||'AND mmtt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt :=sqltxt||' ORDER BY mp.organization_code, oap.acct_period_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Period Information for Pending Txn in MMTT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT organization_code || '' ('' ||mmtt.organization_id|| '')'' "Organization|Code (Id)" '||
         ',period_name "Period|Name", mmtt.acct_period_id "Period|Id" '||
         ',transaction_header_id "Txn|Header Id" '||
         ',transaction_temp_id "Txn|Temp Id"  '||
         ',TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Txn|Date"  '||
         ',DECODE(transaction_mode,1,''Online'',2,''Concurrent'',3,''Background'',transaction_mode) ||'' ('' ||transaction_mode|| '')'' "Transaction|Mode" '||
         ',DECODE(transaction_status,1,''Pending'',2,''Allocated'',3,''Pending'',NULL,''Pending'',transaction_status) ||'' ('' ||transaction_status|| '')'' "Transaction|Status"  '||
         ',process_flag "Process|Flag"  '||
         ',lock_flag "Lock|Flag"  '||
         ',error_code  '||
         ',error_explanation  '||
         ',TO_CHAR( mmtt.last_update_date, ''DD-MON-RR HH24:MI'') "Last Updated" '||
         ',mif.item_number ||'' (''||mmtt.inventory_item_id||'')'' "Item (Id)"  '||
         ',item_description "Item Description"  '||
         ' ,revision "Rev" ,lot_number "Lot" ,serial_number "Serial|Number" '||
         ',mmtt.cost_group_id "Cost|Group Id" ,mmtt.subinventory_code "Subinv" '||
         ',mil.description  ||'' (''||mmtt.locator_id||'') '' "Stock|Locator (Id)"  '||
         ',transfer_subinventory "Transfer|Subinv" ,transfer_to_location "Transfer|Location"  '||
         ',transaction_quantity "Txn Qty" ,primary_quantity "Primary|Qty" ,transaction_uom "Txn|UoM"  '||
         ',mtt.transaction_type_name ||'' (''||mmtt.transaction_type_id||'')'' "Txn Type (Id)",ml.meaning||'' (''||mmtt.transaction_action_id||'')'' "Txn Action Type (Id)" '||
         'FROM mtl_material_transactions_temp mmtt ,mtl_transaction_types mtt  '||
         ',mtl_item_flexfields mif ,mfg_lookups ml ,mtl_item_locations_kfv mil ,mtl_parameters mp,org_acct_periods oap '||
         ' WHERE NVL(transaction_status,1)!=2 '||
         'AND mmtt.transaction_type_id=mtt.transaction_type_id '||
         'AND mmtt.organization_id=mif.organization_id(+) '||
         'AND mmtt.inventory_item_id=mif.inventory_item_id(+)'||
         'AND mmtt.transaction_action_id=ml.lookup_code '||
         'AND ml.lookup_type=''MTL_TRANSACTION_ACTION'' '||
         'AND mmtt.locator_id=mil.inventory_location_id(+) '||
         'AND mmtt.organization_id=mil.organization_id(+)'||
         'AND mmtt.organization_id=mp.organization_id(+) '||
         'AND mmtt.acct_period_id=oap.acct_period_id(+) '||
         'AND mmtt.acct_period_id=oap.acct_period_id(+) ';

if l_org_id is not null then
   sqltxt :=sqltxt||'AND mmtt.organization_id = '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt :=sqltxt||'AND mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt :=sqltxt||'AND process_flag= '  ||l_proc_flag;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Error Txn in MMTT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

/**
else
 JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Invalid Input parameters');
 statusStr := 'FAILURE';
 errStr := 'org_id null';
 fixInfo := 'Org or OrdID input is required ';
 isFatal := 'SUCCESS';
end if;
**/
 -- construct report
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Move Order Orphan Allocations';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Move Order Orphan Allocations';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Move Order Orphan Allocations';
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
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.addOutput(tempOutput,'testout', test_out);
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
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END INV_DIAG_MO;

/
