--------------------------------------------------------
--  DDL for Package Body INV_DIAG_MUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_MUT" as
/* $Header: INVDT04B.pls 120.0.12000000.1 2007/06/22 01:29:15 musinha noship $ */
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
sqltxt VARCHAR2 (2000);
l_sn VARCHAR2(30);
l_org_id NUMBER;
l_org_code VARCHAR2(3);
l_txn_id   NUMBER;

cursor c_mut  is
select serial_number,  org_id
from inv_diag_msn_temp;


BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

for x in c_mut
loop
    l_sn :=x.serial_number;
    l_org_id :=x.org_id;

    JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'MUT of Serial_number  '||l_sn);
    sqltxt := 'select transaction_id '||
       ', transaction_date '||
       ', status_id '||
       ', subinventory_code '||
       ', locator_id '||
       ', inventory_item_id '||
       ', organization_id '||
       ', transaction_source_id '||
       ', transaction_source_type_id '||
       ', ship_id  '||
       ' from mtl_unit_transactions '||
       ' where serial_number = '''||l_sn||'''';

    dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Mtl Unit Transactions');

end loop;

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
statusStr := 'SUCCESS';
test_out := 'MUT';
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
name := 'Serial Transaction History';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Serial Transaction History recorded in MUT';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'MUT test';
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
