--------------------------------------------------------
--  DDL for Package Body INV_RCV_DIAG_LCM_01
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_DIAG_LCM_01" AS
/* $Header: INVRCV1B.pls 120.0.12010000.1 2009/03/18 19:57:28 vthevark noship $ */

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
                  report OUT NOCOPY  JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY  CLOB) IS

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

BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

   -- Printing ORG_ORGANIZATION_DEFINITIONS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="ORG_ORGANIZATION_DEFINITIONS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>ORG_ORGANIZATION_DEFINITIONS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT ood.*' ||
                 ' FROM   org_organization_definitions ood , mtl_parameters mp, rcv_parameters rp'  ||
    	         ' WHERE  ood.organization_id = mp.organization_id' ||
		 ' AND    mp.organization_id = rp.organization_id' ||
                 ' AND    mp.lcm_enabled_flag = ''N'' ' ||
		 ' AND    rp.pre_receive = ''Y'' ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing MTL_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT mp.*' ||
                 ' FROM   org_organization_definitions ood , mtl_parameters mp, rcv_parameters rp'  ||
    	         ' WHERE  ood.organization_id = mp.organization_id' ||
		 ' AND    mp.organization_id = rp.organization_id' ||
                 ' AND    mp.lcm_enabled_flag = ''N'' ' ||
		 ' AND    rp.pre_receive = ''Y'' ';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT rp.*' ||
                 ' FROM   org_organization_definitions ood , mtl_parameters mp, rcv_parameters rp'  ||
    	         ' WHERE  ood.organization_id = mp.organization_id' ||
		 ' AND    mp.organization_id = rp.organization_id' ||
                 ' AND    mp.lcm_enabled_flag = ''N'' ' ||
		 ' AND    rp.pre_receive = ''Y'' ';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Test Completed successfully.
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
   report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in INVDP08B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'pre_receive flag set to Y for non-lcm org';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'pre_receive flag set to Y for non-lcm org';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Non-LCM org with pre-receiving enabled';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY   JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY   VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;

PROCEDURE getOutputValues(outputValues OUT NOCOPY   JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;

PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY  JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_RCV_DIAG_LCM_01;

/
