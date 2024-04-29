--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV" AS
/* $Header: INVDR01B.pls 120.0.12000000.1 2007/06/22 01:21:15 musinha noship $ */
------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'Dump of RCVTXN';
END getTestName;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'Dump of RCVTXN';
END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'Dump of RCV Transactions';
END getTestDesc;


PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
BEGIN
  package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
  -- str := 'null';
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


------------------------------------------------------------
-- procedure to provide/populate  the default parameters for the test case.
------------------------------------------------------------
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
  tempInput JTF_DIAG_INPUTTBL;
BEGIN
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'TableName','LOV-oracle.apps.inv.diag.lov.TxnTablesLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'TransactionId','');
  defaultInputValues := tempInput;
--EXCEPTION
 --when others then
 defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

------------------------------------------------------------
-- procedure to report test mode back to the framework
------------------------------------------------------------
FUNCTION getTestMode RETURN NUMBER IS
BEGIN
  return(2);
END getTestMode;


------------------------------------------------------------
-- procedure to initialize test datastructures
-- executes prior to test run
------------------------------------------------------------
PROCEDURE init IS
BEGIN
 -- test writer could insert special setup code here
 null;
END init;

------------------------------------------------------------
-- procedure to cleanup any  test datastructures that were setup in the init
--  procedure call executes after test run
------------------------------------------------------------
PROCEDURE cleanup IS
BEGIN
 -- test writer could insert special cleanup code here
 NULL;
END cleanup;

------------------------------------------------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are -- returned.
------------------------------------------------------------
PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                          report OUT NOCOPY JTF_DIAG_REPORT,
                          reportClob OUT NOCOPY CLOB) IS
   reportStr   LONG;           -- REPORT
   sql_text    VARCHAR2(200);  -- SQL select statement
   c_username  VARCHAR2(50);   -- accept input for username
   statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
   errStr      VARCHAR2(4000); -- error message
   fixInfo     VARCHAR2(4000); -- fix tip
   isFatal     VARCHAR2(50);   -- TRUE or FALSE
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

  statusStr := 'SUCCESS';
  isFatal := 'FALSE';
  -- construct report
  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

 END runTest;

END INV_DIAG_RCV;

/
