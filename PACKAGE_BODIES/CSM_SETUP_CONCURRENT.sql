--------------------------------------------------------
--  DDL for Package Body CSM_SETUP_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SETUP_CONCURRENT" AS
/* $Header: csmdconb.pls 120.1 2005/07/22 04:23:36 trajasek noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executeds prior to test run (not currently being called)
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   -- test writer could insert special setup code here
   null;
  END init;

  ------------------------------------------------------------
  -- procedure to cleanup any  test datastructures that were setup in the init
  --  procedure call executes after test run (not currently being called)
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
     statusStr   VARCHAR2(50);  -- SUCCESS or FAILURE
     errStr      VARCHAR2(4000);
     fixInfo     VARCHAR2(4000);
     isFatal     VARCHAR2(50);  -- TRUE or FALSE
     request_id  NUMBER ;
     phase       VARCHAR2(80) ;
     status       VARCHAR2(80) ;
     dev_phase       VARCHAR2(80) ;
     dev_status       VARCHAR2(80) ;
     message       VARCHAR2(255) ;
     return_status  BOOLEAN := FALSE ;
     TYPE concRec IS RECORD (applName varchar2 (30), concName varchar2(30), concUserName varchar2(255)) ;
     TYPE concTab IS TABLE OF concRec INDEX BY BINARY_INTEGER;
     concTable concTab ;
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);

         concTable(1).applName := 'ASG' ;
         concTable(1).concName := 'ASG_USER_CONC' ;
         concTable(1).concUserName := 'Manage Mobile Users' ;
         concTable(2).applName := 'ASG' ;
         concTable(2).concName := 'ASG_APPLY' ;
         concTable(2).concUserName := 'Processes Uploaded Mobile Data' ;
         concTable(3).applName := 'FND' ;
         concTable(3).concName := 'FNDWFBG' ;
         concTable(3).concUserName := 'Workflow Background Process' ;
--         concTable(1).applName := 'JTM' ;
--         concTable(1).concName := 'MOBILE_CON_PROGRAM' ;
--         concTable(1).concUserName := 'MOBILE_CON_PROGRAM' ;


         FOR i IN 1..concTable.COUNT LOOP
           request_id := null ;
           return_status := fnd_concurrent.get_request_status(request_id, -- request_id
                                                  concTable(i).applName, -- appl_shortname
                                                  concTable(i).concName, -- program
                                                  phase,
                                                  status,
                                                  dev_phase,
                                                  dev_status,
                                                  message) ;
           IF (return_status) THEN
                reportStr := 'Concurrent program ' || concTable(i).concUserName || ' is scheduled with status ' || status || '.';
                JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
                if statusStr IS NULL or statusStr = 'SUCCESS' THEN
                   statusStr := 'SUCCESS';
                end if ;
           ELSE
              statusStr := 'FAILURE';
              errStr := errStr || 'Concurrent program ' || concTable(i).concUserName || ' is not scheduled. ';
              fixInfo := 'Switch to mobile admin responsibility and schedule concurrent programs ' ;
              isFatal := 'FALSE';
           END IF;
         END LOOP ;
         report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
         reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob ;
   END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Concurrent Programs Status';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Concurrent Programs Scheduled or Not';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Check Concurrent Programs';
  END getTestName;

   -- Enter further code below as specified in the Package spec.
END;

/
