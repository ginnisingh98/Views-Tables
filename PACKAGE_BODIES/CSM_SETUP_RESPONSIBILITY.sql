--------------------------------------------------------
--  DDL for Package Body CSM_SETUP_RESPONSIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SETUP_RESPONSIBILITY" AS
/* $Header: csmdresb.pls 120.3 2006/01/09 05:04:49 trajasek noship $ */
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
     responsibilityExists VARCHAR2(1) ;
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);
     begin
       select 'Y'
         into responsibilityExists
         from fnd_responsibility
        where application_id = 883 -- 'CSM'
          and responsibility_key = 'OMFS_PALM'
	  and sysdate between start_date and nvl(end_date, sysdate) ;
     exception
       WHEN NO_DATA_FOUND THEN
            responsibilityExists := 'N' ;
     end ;
     IF (responsibilityExists = 'Y') THEN
         reportStr := 'Oracle Mobile Field Service responsibility exists.' ;
         JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
         statusStr := 'SUCCESS';
     ELSE
              statusStr := 'FAILURE';
              errStr := 'Oracle Mobile Field Service responsibility does not exist. ';
              fixInfo := 'Apply latest patch then contact support (if needed).' ;
              isFatal := 'FALSE';
      END IF;
      report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob ;
   END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Responsibility Status';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Responsibility Exists or not';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Check responsibility';
  END getTestName;

   -- Enter further code below as specified in the Package spec.
END;

/
