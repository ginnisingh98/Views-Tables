--------------------------------------------------------
--  DDL for Package Body INV_DIAG_TDUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_TDUMP" as
/* $Header: INVDT01B.pls 120.0.12000000.1 2007/06/22 01:24:03 musinha noship $ */

PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
 null;
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
 l_item_id   NUMBER;
 l_sn        VARCHAR2(30);
 l_lot       VARCHAR2(30);
 l_script    varchar2(30);
 l_proc_flag varchar2(1);
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_txn_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('TransactionId',inputs);
l_item_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);
l_script :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('TableName',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ProcFlag',inputs);
l_sn := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('SerialNum',inputs);
l_lot := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('LotNum',inputs);

row_limit :=INV_DIAG_GRP.g_max_row;

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('OrgID input :'||l_org_id||' Table name '||l_script);
JTF_DIAGNOSTIC_COREAPI.BRPrint;
if l_script = 'mmt' then
   if l_txn_id is not null then
       sqltxt := 'select * from MTL_MATERIAL_TRANSACTIONS where transaction_id ='||l_txn_id;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MMT for transaction '||l_txn_id);
       statusStr := 'SUCCESS';
   elsif  l_item_id is not null then
       sqltxt := 'select * from MTL_MATERIAL_TRANSACTIONS where inventory_item_id ='||l_item_id||
                 ' order by transaction_id';
       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_MATERIAL_TRANSACTIONS for item id '||l_item_id);
       statusStr := 'SUCCESS';
   else
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Parameter input is requred to get dump of MTL_MATERIAL_TRANSACTIONS!');
       statusStr := 'FAILURE';
       errStr := 'This test failed as: no input';
       fixInfo := 'Please enter at least one of the following parameters: TransactionId or ItemId';
       isFatal := 'SUCCESS';
   end if;
elsif l_script = 'mmtt' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null then
       sqltxt := 'select * from mtl_material_transactions_temp where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_temp_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_temp_id '||l_txn_id;
       end if;
       if l_item_id is not null then
          sqltxt := sqltxt||' and inventory_item_id = '||l_item_id;
          reportStr := ' - Inventory Item Id '||l_item_id;
       end if;
       if l_proc_flag ='E' then
          sqltxt := sqltxt||' and process_flag =''E'' ';
          reportStr := ' - Errored';
       end if;
       if l_org_id is not null then
          sqltxt := sqltxt||' and organization_id = '||l_org_id;
          reportStr := ' - Organization id'||l_org_id;
       end if;

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_MATERIAL_TRANSACTIONS_TEMP'||reportStr||' Transactions');
   else

       sqltxt := 'select * from mtl_material_transactions_temp where rownum <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_MATERIAL_TRANSACTIONS_TEMP for All Pending Transactions ');
       statusStr := 'SUCCESS';
   end if;
elsif l_script = 'mti' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null then
       sqltxt := 'select * from mtl_transactions_interface where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_header_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_header_id '||l_txn_id;
       end if;
       if l_item_id is not null then
          sqltxt := sqltxt||' and inventory_item_id = '||l_item_id;
          reportStr := reportStr||' - Inventory Item Id  '||l_item_id;
       end if;
       if l_proc_flag ='E' then
          sqltxt := sqltxt||' and process_flag =3 ';
          reportStr := reportStr||' - Errored';
       end if;
       if l_org_id is not null then
          sqltxt := sqltxt||' and organization_id = '||l_org_id;
          reportStr := reportStr||' - Organization id'||l_org_id;
       end if;

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_TRANSACTIONS_INTERFACE'||reportStr||' Transactions');
   else
       sqltxt := 'select * from mtl_transactions_interface where rownum <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_TRANSACTIONS_INTERFACE for All Pending Transactions ');
       statusStr := 'SUCCESS';
   end if;
elsif l_script = 'mut' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null
       or l_sn is not null then
       sqltxt := 'select * from MTL_UNIT_TRANSACTIONS where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_id '||l_txn_id;
       end if;
       if l_item_id is not null then
          sqltxt := sqltxt||' and inventory_item_id = '||l_item_id;
          reportStr := reportStr||' - Inventory Item Id  '||l_item_id;
       end if;
       if l_org_id is not null then
          sqltxt := sqltxt||' and organization_id = '||l_org_id;
          reportStr := reportStr||' - Organization id'||l_org_id;
       end if;
       if l_sn is not null then
          sqltxt := sqltxt||' and serial_number = '''||l_sn||'''';
          reportStr := reportStr||' - Serial Number '||l_sn;
       end if;

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_UNIT_TRANSACTIONS'||reportStr||' Transactions');
   else
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Parameter input is requred to get dump of MTL_UNIT_TRANSACTIONS!');
       statusStr := 'FAILURE';
       errStr := 'This test failed as: no input';
       fixInfo := 'Please enter at least one of the following parameters Org, Item, TransactionId, Serial Number';
       isFatal := 'SUCCESS';
   end if;
elsif l_script = 'mtln' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null
       or l_lot is not null then
       sqltxt := 'select * from MTL_TRANSACTION_LOT_NUMBERS where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_id '||l_txn_id;
       end if;
       if l_item_id is not null then
          sqltxt := sqltxt||' and inventory_item_id = '||l_item_id;
          reportStr := reportStr||' - Inventory Item Id  '||l_item_id;
       end if;
       if l_org_id is not null then
          sqltxt := sqltxt||' and organization_id = '||l_org_id;
          reportStr := reportStr||' - Organization id'||l_org_id;
       end if;
       if l_lot is not null then
          sqltxt := sqltxt||' and lot_number = '''||l_lot||'''';
          reportStr := reportStr||' - Lot '||l_lot;
       end if;

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_TRANSACTION_LOT_NUMBERS'||reportStr||' Transactions');
   else
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Parameter input is requred to get dump of MTL_TRANSACTION_LOT_NUMBERS!');
       statusStr := 'FAILURE';
       errStr := 'This test failed as: no input';
       fixInfo := 'Please enter at least one of the following parameters Org, Item, TransactionId, Lot Number';
       isFatal := 'SUCCESS';
   end if;
elsif l_script ='msnt' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null
      or l_sn is not null then
       sqltxt := 'select * from MTL_SERIAL_NUMBERS_TEMP where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_temp_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_temp_id '||l_txn_id;
       end if;
       if l_sn is not null then
          sqltxt := sqltxt||' and ( fm_serial_number = '''||l_sn||''''||
                            ' or to_serial_number = '''||l_sn||''')';
          reportStr := reportStr||' - Serial Number '||l_sn;
       end if;
       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_SERIAL_NUMBERS_TEMP'||reportStr||' Transactions');

   else
       sqltxt := 'select * from MTL_SERIAL_NUMBERS_TEMP  where rownum <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_SERIAL_NUMBERS_TEMP for All Pending Transactions ');
       statusStr := 'SUCCESS';
   end if;
elsif l_script ='mtlt' then
   if l_txn_id is not null or l_item_id is not null or l_proc_flag = 'E' or l_org_id  is not null
      or l_lot is not null then
       sqltxt := 'select * from MTL_TRANSACTION_LOTS_TEMP where 1 = 1';
        reportStr := '  For';
       if l_txn_id is not null then
          sqltxt := sqltxt||' and transaction_temp_id = '||l_txn_id;
          reportStr := reportStr||' - transaction_temp_id '||l_txn_id;
       end if;
       if l_lot is not null then
          sqltxt := sqltxt||' and lot_number = '''||l_lot||'''';
          reportStr := reportStr||' - Lot '||l_lot;
       end if;
       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_TRANSACTION_LOTS_TEMP'||reportStr||' Transactions');

   else
       sqltxt := 'select * from MTL_SERIAL_NUMBERS_TEMP  where rownum <= '||row_limit;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Dump of MTL_TRANSACTION_LOTS_TEMP for All Pending Transactions ');
       statusStr := 'SUCCESS';
   end if;
end if;

 -- construct report
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Dump of Transaction Tables';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Get Dump from Transaction Tables';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Dump of Transaction Tables';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'TableName','LOV-oracle.apps.inv.diag.lov.TxnTablesLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'TransactionId','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ProcFlag','LOV-oracle.apps.inv.diag.lov.ErroredAllLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'SerialNum','LOV-oracle.apps.inv.diag.lov.SerialLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'LotNum','LOV-oracle.apps.inv.diag.lov.LotLov');
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
