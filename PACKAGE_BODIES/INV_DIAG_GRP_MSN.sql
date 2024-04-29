--------------------------------------------------------
--  DDL for Package Body INV_DIAG_GRP_MSN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_GRP_MSN" AS
/* $Header: INVDGSNB.pls 120.0.12000000.1 2007/06/22 00:48:00 musinha noship $ */
  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Serial Number Information';
  END getTestName;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Serial Number Information';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Serial Number Information';
  END getTestDesc;


  PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
    tempDependencies JTF_DIAG_DEPENDTBL;
  BEGIN
    tempDependencies := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
    tempDependencies := JTF_DIAGNOSTIC_ADAPTUTIL.addDependency(tempDependencies,'INV_DIAG_MSN');
    tempDependencies := JTF_DIAGNOSTIC_ADAPTUTIL.addDependency(tempDependencies,'INV_DIAG_MUT');
    package_names := tempDependencies;
   EXCEPTION
   when others then
     package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
  END getDependencies;

  PROCEDURE isDependencyPipelined(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'TRUE';
  END isDependencyPipelined;


  PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
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
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'SerialNum','LOV-oracle.apps.inv.diag.lov.SerialLov');
   defaultInputValues := tempInput;
  -- EXCEPTION
   -- when others then
   --defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  END getDefaultTestParams;

  ------------------------------------------------------------
  -- procedure to report test mode back to the framework
  ------------------------------------------------------------
  FUNCTION getTestMode RETURN NUMBER IS
  BEGIN
    --return(2);
    return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
  END getTestMode;


  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executes prior to test run
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   -- test writer could insert special setup code here
   --   fnd_file.put_line(fnd_file.log,'@@@ in pipe init : '||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
   null;
  END init;

  ------------------------------------------------------------
  -- procedure to cleanup any  test datastructures that were setup in the init
  --  procedure call executes after test run
  ------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
   -- test writer could insert special cleanup code here
   fnd_file.put_line(fnd_file.log,'@@@ in pipe cleanup : '||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
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
     num_rows	 NUMBER;
     l_sn VARCHAR2(30);
     l_org_id number;
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;  -- must have

     -- html formatting
     JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
     JTF_DIAGNOSTIC_COREAPI.Show_Header(null, null); -- add html css
fnd_file.put_line(fnd_file.log,'@@@ grpmsn 1');
INV_DIAG_GRP.g_grp_name :='INV_DIAG_GRP_MSN';
     -- for dummy testing, simply put status as 'SUCCESS'
     -- successful test will not show error message and fix info in report
     statusStr := ''; -- 'SUCCESS';
     errStr := ''; --Test failure message displayed here';
     fixInfo := '';  -- 'Fixing the test suggestions here';
     isFatal := '';  -- 'FALSE';

     -- construct report
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
fnd_file.put_line(fnd_file.log,'@@@ grpmsn 2');
   END runTest;

END;

/
