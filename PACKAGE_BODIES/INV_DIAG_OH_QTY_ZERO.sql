--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OH_QTY_ZERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OH_QTY_ZERO" as
/* $Header: INVDO08B.pls 120.0.12000000.1 2007/06/22 01:07:27 musinha noship $ */

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
l_org_id NUMBER;
l_item_id NUMBER;

CURSOR c_tnx (cp_org_id IN NUMBER,
              cp_item_id IN NUMBER) IS
  SELECT moqd.create_transaction_id
  FROM mtl_onhand_quantities_detail moqd
  WHERE moqd.subinventory_code is not null
  AND  ( moqd.primary_transaction_quantity = 0
  OR    moqd.transaction_quantity = 0 )
  AND   moqd.organization_id = NVL(cp_org_id,moqd.organization_id)
  AND   moqd.inventory_item_id = NVL(cp_item_id, moqd.inventory_item_id)
  ORDER BY moqd.create_transaction_id;

BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
   l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);


   sqltxt := ' select mif.item_number||''(''||mif.inventory_item_id||'')'' "Item (Id)"' ||
             ' , mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)"' ||
             ' , moqd.subinventory_code "Subinv"' ||
             ' , moqd.locator_id "Stock Locator"' ||
             ' , moqd.revision "Rev"' ||
             ' , moqd.primary_transaction_quantity "Prim Qty"' ||
             ' , moqd.create_transaction_id "Create txn_id"' ||
             ' from mtl_onhand_quantities_detail moqd, mtl_parameters mp,' ||
             ' mtl_item_flexfields mif' ||
             ' where subinventory_code is not null ' ||
	     ' and moqd.organization_id = mp.organization_id' ||
             ' and (primary_transaction_quantity = 0 ' ||
             ' or   transaction_quantity = 0 )  ' ||
             ' and moqd.inventory_item_id = mif.inventory_item_id(+)' ||
             ' and moqd.organization_id =mif.organization_id(+) ' ;
   IF l_org_id IS NOT NULL THEN
      sqltxt :=  sqltxt  || '  and moqd.organization_id = ' || l_org_id ;
   END IF;

   IF l_item_id IS NOT NULL THEN
      sqltxt :=  sqltxt  || '  and moqd.inventory_item_id = ' || l_item_id ;
   END IF;

   sqltxt :=  sqltxt  || ' ORDER BY moqd.create_transaction_id ' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of onhand quantity with transaction quantity as zero');

   FOR rec_tnx IN c_tnx (l_org_id,l_item_id) LOOP
       sqltxt := ' SELECT mmt.transaction_id "Txn Id"' ||
               ' , mp.organization_code|| '' (''||mmt.organization_id ||'')'' "Organization|Code (Id)"' ||
               ' , mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)"' ||
               ' , mmt.transaction_date "Txn Date"' ||
               ' , mmt.transaction_quantity "Txn Qty"' ||
               ' , mmt.primary_quantity "Prim Qty"' ||
               ' , mmt.transaction_uom "Uom"' ||
               ' , tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"' ||
               ' , ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''' ||
               ' "Txn Action (Id)"' ||
               ' , st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"' ||
               ' , mmt.subinventory_code "Subinv"' ||
               ' , mmt.locator_id "Stock Locator"' ||
               ' , mmt.revision "Rev"' ||
               ' , mmt.physical_adjustment_id "Physical Adj Id"' ||
               ' , mmt.transaction_source_id "Txn Source Id"' ||
               ' , mmt.transaction_source_name "Txn Source"' ||
               ' FROM mtl_material_transactions mmt , mtl_parameters mp ' ||
               ' , mtl_item_flexfields mif' ||
               ' , mtl_transaction_types tt' ||
               ' , mtl_txn_source_types st' ||
               ' , mfg_lookups ml' ||
               ' WHERE mmt.transaction_id = ' || rec_tnx.create_transaction_id ||
               ' and mmt.organization_id = mp.organization_id' ||
               ' AND mmt.inventory_item_id = mif.inventory_item_id(+)' ||
               ' AND mmt.organization_id = mif.organization_id(+)' ||
               ' AND mmt.transaction_type_id = tt.transaction_type_id(+)' ||
               ' AND mmt.transaction_source_type_id = st.transaction_source_type_id(+)' ||
               ' AND mmt.transaction_action_id=ml.lookup_code' ||
               ' AND ml.lookup_type = ''MTL_TRANSACTION_ACTION''' ||
               ' ORDER BY costed_flag, transaction_id ';

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Create Transaction Details for transaction_id ' || rec_tnx.create_transaction_id );
    END LOOP;

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
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in INVDO08B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Onhand';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := 'Onhand with transaction quantity as zero';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := 'Zero Onhand Quantity';
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

END INV_DIAG_OH_QTY_ZERO;

/
