--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MTI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MTI" as
/* $Header: INVDT03B.pls 120.0.12000000.1 2007/06/22 01:27:39 musinha noship $ */

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
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_txn_id    NUMBER;
 l_org_id    NUMBER;
 l_proc_flag number;
 l_msg       varchar2(1000);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ErrorFlag',inputs);
row_limit :=INV_DIAG_GRP.g_max_row;

reportStr :='';
if l_org_id is null then
   reportStr := ' For All Organizations';
end if;

if l_proc_flag = 0 then
   l_proc_flag := null;
end if;

if l_proc_flag = 3 then
   reportStr := reportStr||' : process Errored';
elsif l_proc_flag = 1 then
   reportStr := reportStr||' : process Pending';
end if;


JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('OrgID input :'||l_org_id);
JTF_DIAGNOSTIC_COREAPI.BRPrint;
sqltxt := 'SELECT transaction_header_id "Txn Header Id"  '||
          '    , mti.transaction_interface_id "Txn IntFace|Id"  '||
          '    , mif.item_number ||'' (''|| mti.inventory_item_id ||'')'' "Item (Id)"  '||
          '    , item_segment1 "Item Segment1"  '||
          '    , subinventory_code "Subinv"  '||
          '    , loc_segment1 ||'' ''|| loc_segment2 ||'' ''|| loc_segment3 "Loc_Segment  1-3"  '||
          '    , locator_id "Locator Id"  '||
          '    , revision "Rev"  '||
          '    , mti.transaction_quantity "Txn Qty"  '||
          '    , mti.primary_quantity "Primary Qty"  '||
          '    , transaction_uom "Txn UoM"  '||
          '    , transaction_cost "Txn Cost"  '||
          '    , transaction_type_name ||'' (''|| transaction_type_id ||'')'' "Txn Type (Id)"  '||
          '    , transaction_action_name ||'' (''|| transaction_action_id ||'')'' "Txn Action (Id)"  '||
          '    , transaction_source_type_name ||'' (''|| transaction_source_type_id ||'')'' "Txn Source Type (Id)"  '||
          '    , transaction_source_name ||'' (''|| transaction_source_id ||'')'' "Txn Source (Id)"  '||
          '    , trx_source_line_id "Txn Source|Line Id"  '||
          '    , cost_group_id "Cost|Group Id"  '||
          '    , TO_CHAR( transaction_date, ''DD-MON-RR HH24:MI'' ) "Txn Date"  '||
          '    , transaction_reference "Txn Reference"  '||
          '    , transfer_subinventory "Transfer|Subinv"  '||
          '    , transfer_organization_code ||'' (''|| transfer_organization ||'')'' "Transfer|Organization"  '||
          '    , mti.request_id "Request Id"  '||
          '    , mti.source_code "Source|Code"  '||
          '    , mti.source_line_id "Source Line Id"  '||
          '    , source_header_id "Source Header Id"  '||
          '    , mti.distribution_account_id "Distribution Account Id"  '||
          '    , mti.process_flag_desc ||'' ('' || mti.process_flag || '')'' "Process Flag"  '||
          '    , transaction_mode_desc ||'' ('' || transaction_mode || '')'' "Txn Mode"  '||
          '    , lock_flag_desc ||'' ('' || lock_flag || '')'' "Lock Flag"  '||
          '    , TO_CHAR( mti.last_update_date, ''DD-MON-RR HH24:MI'' ) "Last updated"  '||
          '    , mti.error_code "Error Code"  '||
          '    , error_explanation "Error Explanation"  '||
          ' FROM mtl_transactions_interface_v mti  '||
          '    , mtl_item_flexfields mif  '||
          'WHERE mti.organization_id = mif.organization_id(+)  '||
          '  AND mti.inventory_item_id = mif.inventory_item_id(+) ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;

if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
end if;

sqltxt := sqltxt||' ORDER BY transaction_header_id, mti.transaction_interface_id';

sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Display transaction records in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT transaction_interface_id "Txn|Interface Id"  '||
          '    , transaction_quantity "Txn Qty"  '||
          '    , primary_quantity "Primary|Txn Qty"  '||
          '    , transaction_uom "Txn UoM"  '||
          '    , subinventory_code "Subinventory"  '||
          '    , error_code "Error|Code"  '||
          '    , error_explanation "Error|Explanation"  '||
          ' FROM mtl_transactions_interface  '||
          'WHERE ( ABS( transaction_quantity ) < 0.00001  '||
          '        OR ABS( primary_quantity ) < 0.00001 )';

if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_proc_flag is not null then
   sqltxt :=sqltxt||' and process_flag = '||l_proc_flag;
end if;

sqltxt := sqltxt||' ORDER BY transaction_interface_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions with Transaction or Primary Quantity Below Minimum'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';



sqltxt := 'SELECT transaction_interface_id  '||
          '     , item_segment1  '||
          '     , inventory_item_id  '||
          '  FROM mtl_transactions_interface  '||
          ' WHERE ( item_segment1 like ''% '' OR item_segment2 like ''% ''  '||
          '         OR item_segment3 like ''% '' OR item_segment3 like ''% '' )';
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Items with Trailing Spaces '||reportStr);

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
sqltxt := sqltxt||'  AND moq.inventory_item_id  '||
          '      IN ( SELECT DISTINCT mti.inventory_item_id  '||
          '             FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  mti.process_flag = '||l_proc_flag;
end if;
sqltxt := sqltxt||'          )'||
          ' GROUP BY mif.item_number, moq.inventory_item_id  '||
          '       , moq.subinventory_code, moq.locator_id  '||
          '       , mil.concatenated_segments, mil.description  '||
          '       , moq.revision, moq.lot_number  '||
          ' ORDER BY mif.item_number, moq.inventory_item_id  '||
          '       , moq.subinventory_code, moq.locator_id  '||
          '       , mil.concatenated_segments, mil.description  '||
          '       , moq.revision, moq.lot_number';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'On-hand Quantities of Items Associated with Pending Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT DISTINCT( msi.secondary_inventory_name ) "Name"   '||
          '  , msi.description "Description"   '||
          '  , TO_CHAR( msi.disable_date, ''DD-MON-YYYY'' ) "Disable|Date"   '||
          '  , DECODE( msi.reservable_type, 1, ''Yes'', 2, ''No'',   '||
          '            msi.reservable_type) "Reservable|Type"   '||
          '  , DECODE( msi.locator_type  '||
          '                ,1, ''None''   '||
          '                ,2, ''Prespecified''   '||
          '                ,3, ''Dynamic''   '||
          '                ,4, ''SubInv Level''   '||
          '                ,5, ''Item Level'', msi.locator_type)  '||
          '     || '' (''||msi.locator_type||'')'' "Locator|Control"  '||
          '  , DECODE( msi.availability_type  '||
          '              ,1, ''Nettable''  '||
          '              ,2, ''Non-Nettable'',msi.availability_type ) "Availability|Type"  '||
          '  , DECODE( msi.inventory_atp_code, 1, ''Included''  '||
          '                                  , 2, ''Not included''  '||
          '          , msi.inventory_atp_code ) "Include|in ATP"  '||
          '  , DECODE( msi.asset_inventory, 1, ''Yes'', 2, ''No'',  '||
          '            msi.asset_inventory ) "Asset|Inventory"  '||
          '  , DECODE( msi.quantity_tracked, 1, ''Yes'', 2, ''No'',  '||
          '            msi.quantity_tracked ) "Quantity|Tracked"   '||
          '  , default_cost_group_id "Default|Cost Group Id" '||
          '  ,  DECODE( NVL( subinventory_type, 1 ), 1, ''Storage'', 2,''Receiving'', subinventory_type ) "Type"  '||
          'FROM mtl_secondary_inventories msi   '||
          'WHERE (msi.organization_id, msi.secondary_inventory_name ) IN  '||
          '   ( SELECT mti.organization_id, NVL(mti.subinventory_code,-99)'||
          '          FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  mti.process_flag = '||l_proc_flag;
end if;
sqltxt := sqltxt||'UNION  '||
          'SELECT NVL( mti.transfer_organization, mti.organization_id )  '||
          '      ,NVL( mti.transfer_subinventory,-99 ) '||
          'FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  mti.process_flag = '||l_proc_flag;
end if;

sqltxt := sqltxt||') '||
          ' ORDER BY secondary_inventory_name';
sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Subinventories Associated with Pending Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mp.organization_code "Organization|Code"  '||
          '    , mti.organization_id "Organization|Id"  '||
          '    , DECODE( process_flag, 1, ''Ready''  '||
          '                          , 2, ''Not Ready''  '||
          '                          , 3, ''Error''  '||
          '            , process_flag )   '||
          '        || '' ('' ||process_flag|| '')'' "Process Flag"             '||
          '    , DECODE( NVL( lock_flag, 2) , 1,''Locked''  '||
          '                                 , 2, ''Not Locked'', lock_flag)  '||
          '      || '' ('' || lock_flag || '')'' "Lock Flag"  '||
          '    , COUNT(*) "Count"  '||
          ' FROM mtl_transactions_interface mti  '||
          '    , mtl_parameters mp  '||
          'WHERE mti.organization_id = mp.organization_id(+)  ';
if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
end if;

sqltxt :=sqltxt||' GROUP BY mp.organization_code, mti.organization_id  '||
          '       , process_flag, lock_flag  '||
          ' ORDER BY mp.organization_code, mti.organization_id  '||
          '       , process_flag, lock_flag';


sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Count ALL Inventory organizations in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          '  FROM mtl_transactions_interface  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  process_flag = '||l_proc_flag;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Transaction stuck in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT COUNT(*) "Count"  '||
          '   , DECODE( process_flag, 1, ''Ready''  '||
          '                         , 2, ''Not Ready''  '||
          '                         , 3, ''Error''  '||
          '           , process_flag )   '||
          '   || '' ('' ||process_flag|| '')'' "Process Flag" '||
          'FROM mtl_transactions_interface  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt||' GROUP BY process_flag  '||
          ' ORDER BY COUNT(*) , process_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct process_flag for All Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*) "Count"  '||
          '    , DECODE( NVL( lock_flag, 2) , ''1'',''Locked'', 2, ''Not Locked'', lock_flag)  '||
          '      || '' ('' || lock_flag || '')'' "Lock Flag"  '||
          ' FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt||' GROUP BY lock_flag  '||
          ' ORDER BY COUNT(*) DESC, lock_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct lock_flag for All Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*) "Count"  '||
          '    , transaction_mode_desc || '' ('' ||transaction_mode|| '')'' "Transaction Mode"  '||
          ' FROM mtl_transactions_interface_v  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt||' GROUP BY transaction_mode_desc, transaction_mode  '||
          ' ORDER BY COUNT(*) , transaction_mode_desc, transaction_mode ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct transaction_mode for All Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*) "Count"  '||
          '     , transaction_type_name ||'' ( ''||transaction_type_id||'' )'' "Txn Type (Id)"  '||
          ' FROM mtl_transactions_interface_v mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' where mti.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt||'GROUP BY transaction_type_name, transaction_type_id  '||
          'ORDER BY COUNT(*) DESC, transaction_type_name, transaction_type_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct transaction_type for All Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT msni.transaction_interface_id "Txn|Interface Id"  '||
          '    , mti.inventory_item_id "Item Id"  '||
          '    , msni.fm_serial_number "From|Serial#"  '||
          '    , msni.to_serial_number "To|Serial#"  '||
          '    , msni.error_code "Error Code"  '||
          '    , msni.parent_serial_number "Parent|Serial#"  '||
          ' FROM mtl_transactions_interface mti  '||
          '    , mtl_serial_numbers_interface msni  '||
          'WHERE NVL( mti.transaction_interface_id, -999 ) = msni.transaction_interface_id ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;
if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
end if;
sqltxt :=sqltxt||'ORDER BY mti.transaction_interface_id';

sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Serial Number Information from Table MSNI'||reportStr);

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
          'WHERE msn.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND msn.current_organization_id = mif.organization_id  '||
          '  AND msn.current_organization_id = mp.organization_id(+)  '||
          '  AND msn.current_locator_id = mil.inventory_location_id(+)  '||
          '  AND msn.current_organization_id = mil.organization_id(+)  '||
          '  AND msn.current_status = ml.lookup_code(+)  '||
          '  AND ''SERIAL_NUM_STATUS'' = ml.lookup_type(+)  '||
          '  AND msn.inventory_item_id IN  '||
          '     ( SELECT DISTINCT( inventory_item_id )  '||
          '         FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  mti.process_flag = '||l_proc_flag;
end if;
sqltxt :=sqltxt||') ORDER BY mif.item_number, msn.serial_number';

sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Serial Number Information from MSN for Pending Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          '  FROM mtl_transactions_interface mti  '||
          '     , mtl_system_items_b msib  '||
          ' WHERE mti.organization_id = msib.organization_id  '||
          '   AND mti.inventory_item_id = msib.inventory_item_id  '||
          '   AND msib.serial_number_control_code > 1 ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a serial-controlled item'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          '  FROM mtl_transactions_interface mti  '||
          '     , mtl_system_items_b msib  '||
          ' WHERE mti.organization_id = msib.organization_id  '||
          '   AND mti.inventory_item_id = msib.inventory_item_id  '||
          '   AND msib.lot_control_code = 2 ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a lot-controlled item'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT mtli.transaction_interface_id "Txn|Interface Id"  '||
          '   , mti.inventory_item_id "Item Id"  '||
          '   , mtli.transaction_quantity "Txn Qty"  '||
          '   , mtli.primary_quantity "Primary|Txn Qty"  '||
          '   , mtli.lot_number "Lot|Number"  '||
          '   , mtli.lot_expiration_date "Lot Expiration|Date"  '||
          '   , mtli.error_code "Lot Error Code"  '||
          '   , mtli.serial_transaction_temp_id "Serial Txn|Temp Id"  '||
          '   , mtli.process_flag "Process|Flag"  '||
          'FROM mtl_transactions_interface mti  '||
          '   , mtl_transaction_lots_interface mtli  '||
          'WHERE NVL( mti.transaction_interface_id, -999 ) = mtli.transaction_interface_id ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;

if l_proc_flag is not null then
   sqltxt :=sqltxt||' and mti.process_flag = '||l_proc_flag;
end if;
sqltxt :=sqltxt||'ORDER BY mtli.transaction_interface_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Information form MTLI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt := 'SELECT COUNT(*)  '||
          ' FROM mtl_transactions_interface mti  '||
          '    , mtl_system_items_b msib  '||
          'WHERE mti.organization_id = msib.organization_id  '||
          '  AND mti.inventory_item_id = msib.inventory_item_id  '||
          '  AND msib.revision_qty_control_code = 2 ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;

if l_proc_flag is not null then
   sqltxt :=sqltxt||' and mti.process_flag = '||l_proc_flag;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Number of Pending txns that refer to a revision-controlled item'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';
sqltxt := 'SELECT mif.item_number "Item|Number"  '||
          '    , mir.inventory_item_id "Item Id"  '||
          '    , mir.revision "Revision"  '||
          '    , mir.change_notice "Change Notice"  '||
          '    , TO_CHAR( mir.ecn_initiation_date, ''DD-MON-RR'' ) "ECN Initiation|Date"  '||
          '    , TO_CHAR( mir.implementation_date, ''DD-MON-RR'' ) "Implementation|Date"  '||
          '    , TO_CHAR( mir.effectivity_date, ''DD-MON-RR'' ) "Effectivity|Date"  '||
          ' FROM mtl_item_revisions mir, mtl_item_flexfields mif  '||
          'WHERE mir.organization_id = mif.organization_id  '||
          '  AND mir.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND mif.revision_qty_control_code = ''2''  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mir.organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||'  AND mir.inventory_item_id IN  '||
          '      ( SELECT DISTINCT( inventory_item_id )  '||
          '          FROM mtl_transactions_interface mti  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE mti.organization_id =  '||l_org_id;
   if l_proc_flag is not null then
   sqltxt :=sqltxt||' and  mti.process_flag = '||l_proc_flag;
   end if;
elsif l_proc_flag is not null then
   sqltxt :=sqltxt||' where  mti.process_flag = '||l_proc_flag;
end if;
sqltxt :=sqltxt||'      )'||
          '   ORDER BY mif.item_number, mir.revision';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Revision Information'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT DISTINCT mif.item_number "Item Number"  '||
          '     ,mti.inventory_item_id "Item Id"   '||
          '     ,primary_uom_code "Primary|UoM"   '||
          '     ,mif.inventory_item_flag "Inventory|Item Flag"   '||
          '     ,mif.stock_enabled_flag "Stock|Flag"   '||
          '     ,mif.mtl_transactions_enabled_flag "Transactable|Flag"   '||
          '     ,mif.costing_enabled_flag "Costing|Flag"   '||
          '     ,mif.inventory_asset_flag "Inventory|Asset Flag"   '||
          '     ,DECODE( mif.lot_control_code, 1, ''N'' , 2, ''Y''   '||
          '            , mif.lot_control_code )  '||
          '       || '' (''||mif.lot_control_code||'')'' "Lot|Control"   '||
          '     ,ml.meaning||'' (''||mif.serial_number_control_code||'')'' "Serial|Control"  '||
          '     ,DECODE( TO_CHAR(mif.revision_qty_control_code) , ''1'', ''No''   '||
          '                                                     , ''2'', ''Yes''   '||
          '             , mif.revision_qty_control_code )  '||
          '       || '' (''||mif.revision_qty_control_code||'')'' "Revision|Control"  '||
          '     ,DECODE( TO_CHAR(mif.location_control_code)  '||
          '                          , ''1'', ''None''  '||
          '                          , ''2'', ''Prespecified''  '||
          '                          , ''3'', ''Dynamic''  '||
          '                          , ''4'', ''Determine at Subinv Level''  '||
          '                          , ''5'', ''Determine at Item Level''  '||
          '                   , mif.location_control_code )  '||
          '       || '' (''||mif.location_control_code||'')'' "Location|Control"  '||
          '     ,DECODE( mif.restrict_subinventories_code, 1, ''Yes''  '||
          '                                              , 2, ''No''  '||
          '             ,mif.restrict_subinventories_code ) "Restricted|Subinvs"  '||
          '     ,DECODE( mif.restrict_locators_code, 1, ''Yes'', 2, ''No''  '||
          '             ,mif.restrict_locators_code )  '||
          '       || '' (''||mif.restrict_locators_code||'')'' "Restricted|Locators"  '||
          ' FROM mtl_transactions_interface mti  '||
          '    , mtl_item_flexfields mif  '||
          '    , mfg_lookups ml  '||
          'WHERE mti.organization_id = mif.organization_id  '||
          '  AND mti.inventory_item_id = mif.inventory_item_id(+)  '||
          '  AND mif.serial_number_control_code = ml.lookup_code(+)  '||
          '  AND ''MTL_SERIAL_NUMBER'' = ml.lookup_type(+) ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||'ORDER BY mif.item_number';
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Item Associated with Pending Txns in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT COUNT(*) "Count"  '||
          '    , error_code "Error Code"  '||
          '    , error_explanation "Error Explanation"  '||
          ' FROM mtl_transactions_interface  ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||'GROUP BY error_code, error_explanation  '||
          'ORDER BY COUNT(*) DESC, error_code, error_explanation ';
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct Types of Errors in MTI'||reportStr);

statusStr := 'SUCCESS';
isFatal := 'FALSE';
errStr :='';
fixInfo :='';


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
name := 'Open Interface Transactions (MTI)';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Pending Transactions in MTI';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Open Interface Transactions (MTI)';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ErrorFlag','LOV-oracle.apps.inv.diag.lov.MTIErroredAllLov');
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
