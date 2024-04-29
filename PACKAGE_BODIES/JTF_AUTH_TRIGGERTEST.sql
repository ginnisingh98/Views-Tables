--------------------------------------------------------
--  DDL for Package Body JTF_AUTH_TRIGGERTEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AUTH_TRIGGERTEST" AS
/* $Header: jtf_TriggerTestB.pls 120.2 2005/10/25 05:09:26 psanyal noship $ */

  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executes prior to test run
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   /* Setup datastructures for tests (one possible usage below) */
    null;
  END;

  ------------------------------------------------------------
  -- procedure to cleanup any  test datastructures that were setup in the init
  --  procedure call executes after test run
  ------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
  /*  Cleanup datastructures used by test and set up in init call
  * to restore database to original state  [optional] Generally the
  * test writer should write code here to undo what was done in init()
  * to return the datavase to a pre-diagnostic test state */
    null;
  END;


  ------------------------------------------------------------
  -- procedure to execute the PLSQL test
  -- the inputs needed for the test are passed in and a report
  -- object and CLOB are -- returned.
  ------------------------------------------------------------
  PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                            report OUT NOCOPY JTF_DIAG_REPORT,
                            reportClob OUT NOCOPY CLOB) IS
     statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE strings
     errStr      VARCHAR2(4000); -- upto a max of 4000 chars.
     fixInfo     VARCHAR2(4000); -- upto a max of 4000 chars.
     isFatal     VARCHAR2(50);   -- TRUE or FALSE strings
     reportStr   LONG;


     v_count1   NUMBER;          -- JTF_AUTH_PRINCIPAL_MAPS_T4
     v_count2   NUMBER;          -- JTF_AUTH_DOMAIN_TI
     v_count3   NUMBER;          -- JTF_AUTH_ROLE_PERM_TI
     v_count4   NUMBER;          -- JTF_AUTH_PERMISSIONS_B_T1
     v_count5   NUMBER;          -- JTF_AUTH_DOMAINS_B_T1
     v_count6   NUMBER;          -- JTF_AUTH_PRINCIPALS_B_T1
     v_count7   NUMBER;          -- JTF_AUTH_PRINCIPAL_MAPS_T3



   BEGIN
     /* Initialixe some core PL/SQL datastructions CLOB */
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
     JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');


     select count(*) into v_count1 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_PRINCIPAL_MAPS_T4' and OWNER = 'APPS';
     select count(*) into v_count2 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_DOMAIN_TI' and OWNER = 'APPS';
     select count(*) into v_count3 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_ROLE_PERM_TI' and OWNER = 'APPS';
     select count(*) into v_count4 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_PERMISSIONS_B_T1' and OWNER = 'APPS';
     select count(*) into v_count5 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_DOMAINS_B_T1' and OWNER = 'APPS';
     select count(*) into v_count6 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_PRINCIPALS_B_T1' and OWNER = 'APPS';
     select count(*) into v_count7 from ALL_TRIGGERS where upper(TRIGGER_NAME) = 'JTF_AUTH_PRINCIPAL_MAPS_T3' and OWNER = 'APPS';


     IF (v_count1 = 1) AND (v_count2 = 1) AND (v_count3 = 1) AND (v_count4 = 1) AND (v_count5 = 1) AND (v_count6 = 1) AND (v_count7 = 1) THEN

        reportStr := 'The triggers exist. Test is successful';
        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportStr);
        statusStr := 'SUCCESS';
     ELSE
        JTF_DIAGNOSTIC_COREAPI.line_out('The following triggers do not exist : ');
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        IF (v_count1 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('jtf_auth_principal_maps_t4');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count2 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('jtf_auth_domain_tI');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count3 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('jtf_auth_role_perm_tI');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count4 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('JTF_AUTH_PERMISSIONS_B_T1');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count5 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('JTF_AUTH_DOMAINS_B_T1');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count6 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('JTF_AUTH_PRINCIPALS_B_T1');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
        IF (v_count7 <> 1) THEN
           JTF_DIAGNOSTIC_COREAPI.line_out('JTF_AUTH_PRINCIPAL_MAPS_T3');
           JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;

        statusStr := 'FAILURE';
        errStr := 'The triggers do not exist. Test is failure';
        fixInfo := 'Security Triggers are to be created.';
        isFatal := 'FALSE';
     END IF;

     /* Assign the OUT JTF_DIAG_REPORT object with the various report fields */
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);

     /* Retrieve and assign the OUT CLOB object with the current CLOB */
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

   EXCEPTION WHEN others THEN
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport('FAILURE','The test has failed','Try rerunning','FALSE');
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
   END runTest;





   FUNCTION getTestMode return INTEGER IS
   BEGIN
     return JTF_DIAGNOSTIC_ADAPTUTIL.BASIC_MODE;
   END getTestMode;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(compName OUT NOCOPY VARCHAR2) IS
  BEGIN
   compName := 'JTF Security Trigger Test';
  END;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(testDesc OUT NOCOPY VARCHAR2) IS
  BEGIN
   testDesc := 'This test is used to find out the existance of security framework triggers';
  END;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(testName OUT NOCOPY VARCHAR2) IS
  BEGIN
   testName := 'JTF Security Trigger Test';
  END;

  ------------------------------------------------------------
  -- procedure to provide/populate  the default parameters for the test case.
  ------------------------------------------------------------
  PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
    ip JTF_DIAG_INPUTTBL;
  BEGIN
    /* return a initialized JTF_DIAG_INPUTTBL object */
    ip := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
    defaultInputValues := ip;
  END getDefaultTestParams;


END JTF_AUTH_TRIGGERTEST;

/
