--------------------------------------------------------
--  DDL for Package Body JTF_DIAG_QAPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAG_QAPACKAGE" AS
/* $Header: jtfdiagadptdqa_b.pls 120.2 2005/08/13 01:16:21 minxu noship $ */
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
     reportStr   LONG;
     counter     NUMBER;
     c_username  VARCHAR2(50);
     statusStr   VARCHAR2(50);  -- SUCCESS or FAILURE
     errStr      VARCHAR2(4000);
     fixInfo     VARCHAR2(4000);
     isFatal     VARCHAR2(50);  -- TRUE or FALSE
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
         c_username := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('USERNAME',inputs);
         select count(*) into counter
         from  fnd_user
         where user_name  like c_username;
         IF (counter = 1) THEN
           reportStr := 'Report on Successful run displayed here';
           JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportStr);
           statusStr := 'SUCCESS';
         ELSE
           c_username := upper(c_username);
           select count(*) into counter
           from fnd_user
           where user_name like c_username;
           IF (counter = 1) THEN
             reportStr := 'Warning: user found, but name was not in all caps';
             errStr := 'Test failure message displayed here';
             fixInfo := 'Fixing the test suggestions here';
             isFatal := 'FALSE';
             statusStr := 'WARNING';
             JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportStr);
           ELSE
             statusStr := 'FAILURE';
             errStr := 'Test failure message displayed here';
             fixInfo := 'Fixing the test suggestions here';
             isFatal := 'FALSE';
           END IF;
         END IF;
         report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
   END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'QA Tests';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'QAPackage Test to test core API calls';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'QAPackage Test';
  END getTestName;

  ------------------------------------------------------------
  -- procedure to provide/populate  the default parameters for the test case.
  ------------------------------------------------------------
  PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
    tempInput JTF_DIAG_INPUTTBL;
  BEGIN
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'USERNAME','SYSADMIN');
    defaultInputValues := tempInput;
  EXCEPTION
   when others then
   defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  END getDefaultTestParams;

  ------------------------------------------------------------
  -- procedure to report test mode back to the framework
  ------------------------------------------------------------
  FUNCTION getTestMode RETURN NUMBER IS
  BEGIN
    return(2);
  END getTestMode;


END JTF_DIAG_QAPACKAGE;




/
