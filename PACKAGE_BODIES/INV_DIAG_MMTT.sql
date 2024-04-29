--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MMTT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MMTT" as
/* $Header: INVDT02B.pls 120.0.12000000.1 2007/06/22 01:25:57 musinha noship $ */
PROCEDURE init is
BEGIN
--fnd_file.put_line(fnd_file.log,'@@@ diag_msn init'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 l_msg       varchar2(1000);
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_txn_id    NUMBER;
 l_org_id    NUMBER;
 l_acct_period_id NUMBER;
 l_acct_period varchar2(15);
 l_proc_flag varchar2(1);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_acct_period :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('AcctPeriod',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ErrorFlag',inputs);
row_limit :=INV_DIAG_GRP.g_max_row;

reportStr :='';
if l_org_id is null and l_acct_period is null then
   reportStr := ' For All Organizations and Acct Period';
elsif l_org_id is not null and l_acct_period is null then
   reportStr := ' For All Acct Period';
end if;

if l_proc_flag = 'A' then
   l_proc_flag := null;
end if;

if l_proc_flag is not null then
   reportStr := reportStr||' with process flag '||l_proc_flag;
end if;


if l_org_id is not null and l_acct_period is not null then
begin
    SELECT acct_period_id
    into l_acct_period_id
    FROM org_acct_periods
    WHERE organization_id = l_org_id
    AND period_name = l_acct_period;
exception
    when others then
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Invalid Input Parameters. ');
     errStr := 'Invalid Account period '||SQLCODE||' '||substrb(sqlerrm,1,1000);
     fixInfo := 'Enter a valid account period';
     statusStr := 'FAILURE';
     isFatal := 'SUCCESS';
     goto l_test_end;
end;
end if;

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('OrgID input :'||l_org_id||' Account Period: '||l_acct_period||'('||l_acct_period_id||')');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sqltxt := 'SELECT  fa.application_name "Application Name"  '||
          '     , fa.application_short_name "Application|Shortname"  '||
          '     , fcp.concurrent_processor_name "Name"  '||
          '     , fcq.user_concurrent_queue_name "Manager"  '||
          '     , NVL( fcq.target_node,''n/a'') "Node"  '||
          '     , fcq.running_processes "Actual"  '||
          '     , fcq.max_processes "Target"  '||
          ' FROM fnd_concurrent_queues_vl fcq  '||
          '     , fnd_application_vl fa  '||
          '     , fnd_concurrent_processors fcp '||
          'WHERE fa.application_id = fcq.application_id  '||
          '  AND fcq.application_id = fcp.application_id  '||
          '  AND fcq.concurrent_processor_id = fcp.concurrent_processor_id  '||
          '  AND fa.application_short_name IN ( ''INV'' )  '||
          'ORDER BY fcp.application_id DESC  '||
          ', fcp.concurrent_processor_id  '||
          ', fcp.concurrent_processor_name';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Concurrent Managers related to Inventory');
statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT DISTINCT period_name "Period|Name"  '||
          '     , oap.acct_period_id "Period|Id"  '||
          '     , mp.organization_code "Organization|Code"  '||
          '     , mmtt.organization_id "Organization|Id"  '||
          '     , TO_CHAR( period_start_date, ''DD-MON-YYYY'' ) "Start Date"  '||
          '     , TO_CHAR( period_close_date, ''DD-MON-YYYY'' ) "Close Date"  '||
          '     , TO_CHAR( schedule_close_date, ''DD-MON-YYYY'' ) "Scheduled |Close Date"  '||
          '     , open_flag "Open"  '||
          '     , description "Description"  '||
          '     , period_set_name "GL Period Set|Name"  '||
          '     , period_name "GL Period|Name"  '||
          '     , period_year "GL Period|Year"  '||
          '  FROM mtl_material_transactions_temp mmtt, mtl_parameters mp  '||
          '     , org_acct_periods oap  '||
          ' WHERE NVL( mmtt.transaction_status,1 ) != 2  '||
          '   AND mmtt.organization_id=mp.organization_id(+)  '||
          '   AND mmtt.acct_period_id=oap.acct_period_id(+)';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||' ORDER BY mp.organization_code, oap.acct_period_id ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Period Information ');
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT ';
if l_org_id is null then
   sqltxt :=sqltxt||'organization_code || '' ('' ||mmtt.organization_id|| '')'' "Organization|Code (Id)", ';
end if;

if l_acct_period_id is null then
   sqltxt :=sqltxt||'period_name "Period|Name", mmtt.acct_period_id "Period|Id",';
end if;

sqltxt := sqltxt||' transaction_header_id "Txn|Header Id"  '||
          ',transaction_temp_id "Txn|Temp Id"  '||
          ',TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Txn|Date"  '||
          ',DECODE(transaction_mode,1,''Online''  '||
          '                       ,2,''Concurrent''  '||
          '                       ,3,''Background''  '||
          '      ,transaction_mode)  '||
          '   ||'' ('' ||transaction_mode|| '')'' "Transaction|Mode"  '||
          ',DECODE(transaction_status,1,''Pending''  '||
          '                         ,2,''Allocated''  '||
          '                         ,3,''Pending''  '||
          '                         ,NULL,''Pending''  '||
          '      ,transaction_status)  '||
          ' ||'' ('' ||transaction_status|| '')'' "Transaction|Status"  '||
          ',process_flag "Process|Flag"  '||
          ',lock_flag "Lock|Flag"  '||
          ',error_code  '||
          ',error_explanation  '||
          ',TO_CHAR( mmtt.last_update_date, ''DD-MON-RR HH24:MI'') "Last Updated"  '||
          ',mif.item_number  '||
          '||'' (''||mmtt.inventory_item_id||'')'' "Item (Id)"  '||
          ',item_description "Item Description"  '||
          ',revision "Rev"   '||
          ',lot_number "Lot" '||
          ',serial_number "Serial|Number"  '||
          ',mmtt.cost_group_id "Cost|Group Id"  '||
          ',mmtt.subinventory_code "Subinv"  '||
          ',mil.description  '||
          '||'' (''||mmtt.locator_id||'') '' "Stock|Locator (Id)"  '||
          ',transfer_subinventory "Transfer|Subinv"  '||
          ',transfer_to_location "Transfer|Location"  '||
          ',transaction_quantity "Txn Qty"   '||
          ',primary_quantity "Primary|Qty"   '||
          ',transaction_uom "Txn|UoM"  '||
          ',mtt.transaction_type_name  '||
          '||'' (''||mmtt.transaction_type_id||'')'' "Txn Type (Id)"  '||
          ',ml.meaning  '||
          '||'' (''||mmtt.transaction_action_id||'')'' "Txn Action Type (Id)"  '||
          'FROM mtl_material_transactions_temp mmtt  '||
          ',mtl_transaction_types mtt  '||
          ',mtl_item_flexfields mif  '||
          ',mfg_lookups ml  '||
          ',mtl_item_locations_kfv mil';

if l_org_id is null then
   sqltxt :=sqltxt||' ,mtl_parameters mp ';
end if;
if l_acct_period_id is null then
   sqltxt :=sqltxt||' ,org_acct_periods oap ';
end if;

sqltxt := sqltxt||' WHERE NVL(transaction_status,1)!=2 '||
          '  AND mmtt.transaction_type_id=mtt.transaction_type_id '||
          '  AND mmtt.organization_id=mif.organization_id(+) '||
          '  AND mmtt.inventory_item_id=mif.inventory_item_id(+) '||
          '  AND mmtt.transaction_action_id=ml.lookup_code '||
          '  AND ml.lookup_type=''MTL_TRANSACTION_ACTION'' '||
          '  AND mmtt.locator_id=mil.inventory_location_id(+) '||
          '  AND mmtt.organization_id=mil.organization_id(+)';
if l_org_id is null then
   sqltxt :=sqltxt||'  AND mmtt.organization_id=mp.organization_id(+) ';
else
   sqltxt :=sqltxt||'  and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
else
   sqltxt := sqltxt||' AND mmtt.acct_period_id=oap.acct_period_id(+) ';
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND process_flag= '''||l_proc_flag||''' ';
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Pending Material Transactions '||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT mmtt.transaction_temp_id "Txn|Temp Id"  '||
          '    , mmtt.transaction_quantity "Txn Qty"  '||
          '    , mmtt.primary_quantity "Primary|Txn Qty"  '||
          '    , mmtt.transaction_uom "Txn UoM"  '||
          '    , mmtt.subinventory_code "SubInventory"  '||
          '    , mmtt.error_code "Error|Code"  '||
          '    , mmtt.error_explanation "Error|Explanation"  '||
          '    , mmtt.item_description "Item Description"  '||
          ' FROM mtl_material_transactions_temp mmtt  '||
          'WHERE ( ABS( transaction_quantity )*100000 <= 1  '||
          '        OR ABS( primary_quantity )* 100000 <= 1 )';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt :=sqltxt||' ORDER BY transaction_temp_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Pending Txns with Transaction or Primary Quantity Below Minimum'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mmtt.transaction_temp_id "Txn|Temp Id"  '||
          '     , mmtt.item_description "Item Description"  '||
          '     , mmtt.inventory_item_id "Inventory|Item Id"  '||
          '  FROM mtl_material_transactions_temp mmtt  '||
          ' WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
          '   AND mmtt.item_description like ''% '' ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND process_flag= '''||l_proc_flag||''' ';
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Items with Trailing Spaces in Description'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mif.item_number "Item"  '||
          '    , moq.inventory_item_id "Item Id"  '||
          '    , SUM( moq.transaction_quantity ) "Txn Qty"  '||
          '    , moq.subinventory_code "Subinv"  '||
          '    , moq.locator_id "Locator Id"  '||
          '    , mil.concatenated_segments "Locator"  '||
          '    , mil.description "Locator Desc"  '||
          '    , moq.revision "Revision"  '||
          '    , moq.lot_number "Lot Number"  '||
          ' FROM mtl_onhand_quantities_detail moq , mtl_item_flexfields mif  '||
          '    , mtl_item_locations_kfv mil  '||
          'WHERE moq.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND moq.organization_id = mif.organization_id(+)  '||
          '  AND moq.organization_id = mil.organization_id(+)  '||
          '  AND moq.locator_id = mil.inventory_location_id(+)  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and moq.organization_id =  '||l_org_id;
end if;

sqltxt :=sqltxt||'  AND moq.inventory_item_id  '||
          '      IN ( SELECT DISTINCT mmtt.inventory_item_id  '||
          '             FROM mtl_material_transactions_temp mmtt  '||
          '            WHERE  NVL( mmtt.transaction_status, 1 ) !=2 ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND mmtt.process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt := sqltxt||')'||
          'GROUP BY mif.item_number, moq.inventory_item_id  '||
          '       , moq.subinventory_code, moq.locator_id  '||
          '       , mil.concatenated_segments, mil.description  '||
          '       , moq.revision, moq.lot_number  '||
          'ORDER BY mif.item_number, moq.inventory_item_id  '||
          '       , moq.subinventory_code, moq.locator_id  '||
          '       , mil.concatenated_segments, mil.description  '||
          '       , moq.revision, moq.lot_number';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'On-hand Quantities of Items Associated with Pending Txns in MMTT'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT DISTINCT( msi.secondary_inventory_name ) "Name"   '||
          '    , msi.description "Description"   '||
          '    , msi.disable_date "Disable|Date"   '||
          '    , DECODE( msi.reservable_type, 1, ''Yes'', 2, ''No'',   '||
          '              msi.reservable_type) "Reservable|Type"   '||
          '    , DECODE( msi.locator_type  '||
          '                  ,1, ''None''   '||
          '                  ,2, ''Prespecified''   '||
          '                  ,3, ''Dynamic''   '||
          '                  ,4, ''SubInv Level''   '||
          '                  ,5, ''Item Level'', msi.locator_type)  '||
          '       || '' (''||msi.locator_type||'')'' "Locator|Control"  '||
          '    , DECODE( msi.availability_type  '||
          '                ,1, ''Nettable''   '||
          '                ,2, ''Non-Nettable'',msi.availability_type ) "Availability|Type"  '||
          '    , DECODE( msi.inventory_atp_code, 1, ''Included in atp''   '||
          '                                    , 2, ''Not included in atp''   '||
          '            , msi.inventory_atp_code ) "Include|in ATP"   '||
          '    , DECODE( msi.asset_inventory, 1, ''Yes'', 2, ''No'',   '||
          '              msi.asset_inventory ) "Asset|Inventory"   '||
          '    , DECODE( msi.quantity_tracked, 1, ''Yes'', 2, ''No'',   '||
          '              msi.quantity_tracked ) "Quantity|Tracked"   '||
          ' FROM mtl_secondary_inventories msi   '||
          'WHERE (msi.organization_id, msi.secondary_inventory_name ) IN   '||
          '     ( SELECT mmtt.organization_id, NVL(mmtt.subinventory_code,-99) '||
          '       FROM mtl_material_transactions_temp mmtt  '||
          '       WHERE NVL( mmtt.transaction_status, 1 ) != 2  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||'       UNION  '||
          '       SELECT NVL( mmtt.transfer_organization, mmtt.organization_id )  '||
          '        ,NVL( mmtt.transfer_subinventory,-99 )'||
          '        FROM mtl_material_transactions_temp mmtt  '||
          '       WHERE NVL( mmtt.transaction_status, 1 ) != 2  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;
sqltxt := sqltxt||' )  '||
          '  ORDER BY secondary_inventory_name';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Subinventories Associated with Pending Txns in MMTT'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mp.organization_code "Organization|Code"  '||
          '    , mmtt.organization_id "Organization|ID"  '||
          '    , oap.period_name "Period Name"  '||
          '    , mmtt.acct_period_id "Period ID"  '||
          '    , mmtt.process_flag "Process Flag"  '||
          '    , mmtt.lock_flag "Lock Flag"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp mmtt, mtl_parameters mp  '||
          '    , org_acct_periods oap  '||
          'WHERE NVL( mmtt.transaction_status,1 ) != 2  '||
          '  AND mmtt.organization_id=mp.organization_id(+)  '||
          '  AND mmtt.acct_period_id=oap.acct_period_id(+) ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||' GROUP BY mp.organization_code, mmtt.organization_id  '||
          '       , oap.period_name, mmtt.acct_period_id  '||
          '       , mmtt.process_flag, mmtt.lock_flag  '||
          'ORDER BY mp.organization_code, mmtt.organization_id  '||
          '       , mmtt.acct_period_id, mmtt.process_flag';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Over view of All Pending Material Transactions');
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT process_flag "Process Flag"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp  '||
          'WHERE NVL( transaction_status, 1 ) != 2';
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;
sqltxt := sqltxt||'GROUP BY process_flag  '||
          'ORDER BY process_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct process_flag for All Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT lock_flag "Lock Flag" , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp  '||
          'WHERE NVL( transaction_status, 1 ) != 2';
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||'GROUP BY lock_flag  '||
          'ORDER BY lock_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct lock_flag for All Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT process_flag "Process Flag"  '||
          '    , DECODE( NVL( transaction_status, ''-99'' )  '||
          '                        , ''1'', ''Pending''  '||
          '                        , ''2'', ''Allocated''  '||
          '                        , ''-99'', ''Pending''  '||
          '                  , transaction_status )  '||
          '        || '' ('' ||NVL( TO_CHAR( transaction_status ), ''null'')  '||
          '        || '' )'' "Transaction Status"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp ';
if l_org_id is not null then
   sqltxt :=sqltxt||' where organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||'GROUP BY process_flag, transaction_status  '||
          'ORDER BY process_flag, transaction_status ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct process_flag, transaction_status for All Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT process_flag "Process Flag"  '||
          '    , ml.meaning || '' ('' || mmtt.transaction_mode || '')''  '||
          '        "Transaction Mode"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp mmtt, mfg_lookups ml  '||
          'WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
          '  AND ml.lookup_type(+) = ''MTL_TRANSACTION_MODE''  '||
          '  AND mmtt.transaction_mode = ml.lookup_code(+)';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;
sqltxt := sqltxt||'GROUP BY process_flag, ml.meaning, mmtt.transaction_mode  '||
          'ORDER BY process_flag, ml.meaning, mmtt.transaction_mode ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct process_flag, transaction_mode for All Pending Txns');
statusStr := 'SUCCESS';
isFatal := 'FALSE';



sqltxt :='SELECT mmtt.process_flag "Process Flag"  '||
'     , tt.transaction_type_name  '||
'         ||'' ( ''||mmtt.transaction_type_id||'' )''  '||
'         "Txn Type (Id)"  '||
'     , ml.meaning  '||
'       ||'' ( ''||mmtt.transaction_action_id||'' )''  '||
'      "Txn Action (Id)"  '||
'    , COUNT(*) "Count"  '||
' FROM mtl_material_transactions_temp mmtt  '||
'    , mtl_transaction_types tt  '||
'    , mfg_lookups ml  '||
'WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
'  AND mmtt.transaction_type_id = tt.transaction_type_id(+)  '||
'  AND mmtt.transaction_action_id = ml.lookup_code  '||
'  AND ml.lookup_type = ''MTL_TRANSACTION_ACTION'' ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||' GROUP BY mmtt.process_flag  '||
'        , tt.transaction_type_name, mmtt.transaction_type_id  '||
'        , ml.meaning, mmtt.transaction_action_id  '||
' ORDER BY mmtt.process_flag  '||
'        , tt.transaction_type_name  '||
'              ||'' ( ''||mmtt.transaction_type_id||'' )''  '||
'        , ml.meaning  '||
'              ||'' ( ''||mmtt.transaction_action_id||'' )'' ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct process_flag, transaction_type for All Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          '  FROM mtl_material_transactions_temp mmtt, mtl_system_items_b msib  '||
          ' WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
          '   AND mmtt.organization_id = msib.organization_id  '||
          '   AND mmtt.inventory_item_id = msib.inventory_item_id  '||
          '   AND msib.serial_number_control_code > 1 ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a serial-controlled item'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mmtt.transaction_temp_id "Txn|Temp Id"  '||
          '    , mmtt.transaction_quantity "Txn Qty"  '||
          '    , mmtt.primary_quantity "Primary|Txn Qty"  '||
          '    , mmtt.transaction_uom "Txn UoM"  '||
          '    , msnt.fm_serial_number "From|Serial#"  '||
          '    , msnt.to_serial_number "To|Serial#"  '||
          '    , msnt.serial_prefix "Serial|Prefix"  '||
          '    , msnt.error_code "Error Code"  '||
          '    , msnt.parent_serial_number "Parent|Serial#"  '||
          '    , msnt.group_header_id "Group|Header Id"  '||
          '    , mmtt.item_description "Item Description"  '||
          '    , mmtt.serial_number "Serial#"  '||
          '    , DECODE( mmtt.item_serial_control_code,  '||
          '                  1, ''No serial number control'',  '||
          '                  2, ''Predefined serial numbers'',  '||
          '                  5, ''Dynamic entry at inventory receipt'',  '||
          '                  6, ''Dynamic entry at sales order issue'',  '||
          '              mmtt.item_serial_control_code )  '||
          '      ||'' (''||mmtt.item_serial_control_code||'')'' "Item Serial Control"  '||
          '    , mmtt.next_serial_number "Next Serial#"  '||
          '    , mmtt.serial_alpha_prefix "Serial|Alpha Prefix"  '||
          'FROM mtl_material_transactions_temp mmtt  '||
          '   , mtl_serial_numbers_temp msnt  '||
          'WHERE NVL( mmtt.transaction_status, 1 ) != 2  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;
sqltxt := sqltxt||' AND mmtt.transaction_temp_id = msnt.transaction_temp_id'||
          ' ORDER BY mmtt.transaction_temp_id';
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Serial Number Information from Table MSNT');
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mif.item_number  '||
          '       ||'' (''|| msn.inventory_item_id||'')'' "Item (Id)"  '||
          '    , msn.serial_number "Serial|Number"  '||
          '    , ml.meaning  '||
          '       ||'' (''||msn.current_status||'')'' "Current|Status"  '||
          '    , msn.group_mark_id "Group|Mark Id"  '||
          '    , msn.line_mark_id "Line|Mark Id"  '||
          '    , msn.lot_line_mark_id "Lot Line|Mark Id"  '||
          '    , mp.organization_Code "Current|Org Code"  '||
          '    , msn.current_organization_id "Current|Org Id"  '||
          '    , msn.current_subinventory_code "Current|Subinventory"  '||
          '    , msn.current_locator_id "Current|Locator Id"  '||
          '    , mil.concatenated_segments "Current|Locator"  '||
          '    , mil.description "Current|Locator Desc"  '||
          ' FROM mtl_serial_numbers msn, mtl_item_flexfields mif  '||
          '    , mtl_parameters mp, mtl_item_locations_kfv mil  '||
          '    , mfg_lookups ml  '||
          'WHERE msn.inventory_item_id = mif.inventory_item_id  '||
          '  AND msn.current_organization_id = mif.organization_id  '||
          '  AND msn.current_organization_id = mp.organization_id(+)  '||
          '  AND msn.current_locator_id = mil.inventory_location_id(+)  '||
          '  AND msn.current_organization_id = mil.organization_id(+)  '||
          '  AND msn.current_status = ml.lookup_code(+)  '||
          '  AND ''SERIAL_NUM_STATUS'' = ml.lookup_type(+)  '||
          '  AND msn.inventory_item_id IN  '||
          '     ( SELECT DISTINCT( inventory_item_id )  '||
          '         FROM mtl_material_transactions_temp mmtt  '||
          '        WHERE NVL( mmtt.transaction_status,1 ) != 2';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND mmtt.process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt := sqltxt|| ') ORDER BY mif.item_number, msn.serial_number';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Serial Number Information from MSN for Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          '  FROM mtl_material_transactions_temp mmtt, mtl_system_items_b msib  '||
          ' WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
          '   AND mmtt.organization_id = msib.organization_id  '||
          '   AND mmtt.inventory_item_id = msib.inventory_item_id  '||
          '   AND msib.lot_control_code = 2 ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a lot-controlled item'||reportStr );
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mmtt.transaction_temp_id "Txn|Temp Id"  '||
          '     , mmtt.transaction_quantity "Txn Qty"  '||
          '     , mmtt.primary_quantity "Primary|Txn Qty"  '||
          '     , mmtt.transaction_uom "Txn UoM"  '||
          '     , mtlt.lot_number "Lot|Number"  '||
          '     , mtlt.lot_expiration_date "Lot Expiration|Date"  '||
          '     , mtlt.error_code "Lot Error Code"  '||
          '     , mtlt.serial_transaction_temp_id "Serial Txn|Temp Id"  '||
          '     , mmtt.item_description "Item|Description"  '||
          '  FROM mtl_material_transactions_temp mmtt  '||
          '     , mtl_transaction_lots_temp mtlt  '||
          ' WHERE NVL( mmtt.transaction_status, 1 ) != 2  '||
          '   AND mmtt.transaction_temp_id = mtlt.transaction_temp_id ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND mmtt.process_flag= '''||l_proc_flag||''' ';
end if;
sqltxt := sqltxt||'  ORDER BY mmtt.transaction_temp_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Information from MTLT for Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          ' FROM mtl_material_transactions_temp mmtt, mtl_system_items_b msib  '||
          'WHERE mmtt.organization_id = msib.organization_id  '||
          '  AND mmtt.inventory_item_id = msib.inventory_item_id  '||
          '  AND NVL( mmtt.transaction_status, 1 ) != 2  '||
          '  AND msib.revision_qty_control_code = 2 ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a revision-controlled item'||reportStr );
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mif.item_number "Item|Number"  '||
          '    , mir.inventory_item_id "Item Id"  '||
          '    , mir.revision "Revision"  '||
          '    , mir.change_notice "Change Notice"  '||
          '    , mir.ecn_initiation_date "ECN Initiation|Date"  '||
          '    , mir.implementation_date "Implementation|Date"  '||
          '    , mir.effectivity_date "Effectivity|Date"  '||
          ' FROM mtl_item_revisions mir, mtl_item_flexfields mif  '||
          'WHERE mir.organization_id = mif.organization_id  '||
          '  AND mir.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND mif.revision_qty_control_code = ''2''  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mir.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt||'  AND mir.inventory_item_id IN  '||
          '      ( SELECT DISTINCT( inventory_item_id )  '||
          '          FROM mtl_material_transactions_temp mmtt  '||
          '         WHERE NVL( mmtt.transaction_status, 1 ) != 2    ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND mmtt.process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt := sqltxt||') '||
          ' ORDER BY mif.item_number, mir.revision';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Revision Information for Pending Txns'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT DISTINCT mif.item_number "Item Number"  '||
          '     ,mmtt.inventory_item_id "Item Id"   '||
          '     ,primary_uom_code "Primary|UoM"   '||
          '     ,mif.inventory_item_flag "Inventory|Item Flag"   '||
          '     ,mif.stock_enabled_flag "Stock|Flag"   '||
          '     ,mif.mtl_transactions_enabled_flag "Transactable|Flag"   '||
          '     ,mif.costing_enabled_flag "Costing|Flag"   '||
          '     ,mif.inventory_asset_flag "Inventory|Asset Flag"   '||
          '     ,DECODE( mif.lot_control_code, 1, ''N'' , 2, ''Y''   '||
          '            , mif.lot_control_code ) "Lot|Control"   '||
          '     ,ml.meaning||'' (''||mif.serial_number_control_code||'')'' "Serial|Control"  '||
          '     ,DECODE( TO_CHAR(mif.revision_qty_control_code)  '||
          '                           , ''1'', ''No''   '||
          '                           , ''2'', ''Yes''   '||
          '                ,mif.revision_qty_control_code ) "Revision|Control"  '||
          '     ,DECODE( TO_CHAR(mif.location_control_code)  '||
          '                          , ''1'', ''None''  '||
          '                          , ''2'', ''Prespecified''  '||
          '                          , ''3'', ''Dynamic''  '||
          '                          , ''4'', ''Determine at Subinv Level''  '||
          '                          , ''5'', ''Determine at Item Level''  '||
          '                   , mif.location_control_code )  '||
          '       || '' (''||mif.location_control_code||'')'' "Location|Control"  '||
          '     ,DECODE( mif.restrict_subinventories_code, 1, ''Y''  '||
          '                                              , 2, ''N''  '||
          '             ,mif.restrict_subinventories_code ) "Restricted|Subinvs"  '||
          '     ,DECODE( mif.restrict_locators_code, 1, ''Y'', 2, ''N''  '||
          '             ,mif.restrict_locators_code ) "Restricted|Locators"  '||
          ' FROM mtl_material_transactions_temp mmtt  '||
          '    , mtl_item_flexfields mif , mfg_lookups ml  '||
          'WHERE mmtt.organization_id = mif.organization_id  '||
          '  AND mmtt.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND mif.serial_number_control_code = ml.lookup_code(+)  '||
          '  AND ''MTL_SERIAL_NUMBER'' = ml.lookup_type(+)  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmtt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmtt.acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND mmtt.process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt := sqltxt||' ORDER BY mif.item_number';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Item Associated with Pending Txns in MMTT'||reportStr);
statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT process_flag "Process Flag"  '||
          '    , error_code "Error Code"  '||
          '    , error_explanation "Error Explanation"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_material_transactions_temp  '||
          'WHERE NVL( transaction_status, 1 ) != 2';
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

if l_proc_flag is not null then
   sqltxt := sqltxt||' AND process_flag= '''||l_proc_flag||''' ';
end if;

sqltxt := sqltxt||'GROUP BY process_flag, error_code, error_explanation  '||
          ' ORDER BY process_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct Types of Errors in MMTT');
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
 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Pending Transactions (MMTT)';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Pending Transactions in MMTT';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Pending Transactions (MMTT)';
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
--tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'testout','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'AcctPeriod','LOV-oracle.apps.inv.diag.lov.PeriodLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ErrorFlag','LOV-oracle.apps.inv.diag.lov.MMTTErroredAllLov');
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
