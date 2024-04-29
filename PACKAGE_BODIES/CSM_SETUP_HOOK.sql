--------------------------------------------------------
--  DDL for Package Body CSM_SETUP_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SETUP_HOOK" AS
/* $Header: csmduhkb.pls 120.1 2005/07/22 08:22:26 trajasek noship $ */
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
     hookExists  VARCHAR2(1) ;

     TYPE hookRec IS RECORD (packageName varchar2 (50),
                            apiName varchar2(50),
                            hookType varchar2(1),
                            processingType varchar2(1)) ;

     TYPE hookTab IS TABLE OF hookRec INDEX BY BINARY_INTEGER;
     hookTable hookTab ;
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);

         hookTable(1).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
         hookTable(1).apiName := 'INSERT_ROW' ;
         hookTable(1).hookType := 'I' ; -- Internal
         hookTable(1).processingType := 'A' ; -- After

         hookTable(2).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
         hookTable(2).apiName := 'UPDATE_ROW' ;
         hookTable(2).hookType := 'I' ; -- Internal
         hookTable(2).processingType := 'B' ; -- Before

         hookTable(3).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
         hookTable(3).apiName := 'UPDATE_ROW' ;
         hookTable(3).hookType := 'I' ; -- Internal
         hookTable(3).processingType := 'A' ; -- After

         hookTable(4).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
         hookTable(4).apiName := 'DELETE_ROW' ;
         hookTable(4).hookType := 'I' ; -- Internal
         hookTable(4).processingType := 'B' ; -- Before

         hookTable(5).packageName := 'JTF_TASKS_PUB' ;
         hookTable(5).apiName := 'UPDATE_TASK' ;
         hookTable(5).hookType := 'I' ; -- Internal
         hookTable(5).processingType := 'B' ;

         hookTable(6).packageName := 'CS_ServiceRequest_PVT' ;
         hookTable(6).apiName := 'Update_ServiceRequest' ;
         hookTable(6).hookType := 'I' ; -- Internal
         hookTable(6).processingType := 'B' ;

         hookTable(7).packageName := 'CS_ServiceRequest_PVT' ;
         hookTable(7).apiName := 'Update_ServiceRequest' ;
         hookTable(7).hookType := 'I' ; -- Internal
         hookTable(7).processingType := 'A' ;

         hookTable(8).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
         hookTable(8).apiName := 'CREATE_TASK_ASSIGNMENT' ;
         hookTable(8).hookType := 'I' ; -- Internal
         hookTable(8).processingType := 'A' ;

         hookTable(9).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
         hookTable(9).apiName := 'UPDATE_TASK_ASSIGNMENT' ;
         hookTable(9).hookType := 'I' ; -- Internal
         hookTable(9).processingType := 'B' ;

         hookTable(10).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
         hookTable(10).apiName := 'DELETE_TASK_ASSIGNMENT' ;
         hookTable(10).hookType := 'I' ; -- Internal
         hookTable(10).processingType := 'B' ;

         hookTable(11).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
         hookTable(11).apiName := 'INSERT_ROW' ;
         hookTable(11).hookType := 'I' ; -- Internal
         hookTable(11).processingType := 'A' ;

         hookTable(12).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
         hookTable(12).apiName := 'UPDATE_ROW' ;
         hookTable(12).hookType := 'I' ; -- Internal
         hookTable(12).processingType := 'B' ;

         hookTable(13).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
         hookTable(13).apiName := 'UPDATE_ROW' ;
         hookTable(13).hookType := 'I' ; -- Internal
         hookTable(13).processingType := 'A' ;

         hookTable(14).packageName := 'JTM_NOTES_PUB' ;
         hookTable(14).apiName := 'CREATE_NOTE' ;
         hookTable(14).hookType := 'V' ; -- Vertical
         hookTable(14).processingType := 'A' ;

         hookTable(15).packageName := 'JTM_NOTES_PUB' ;
         hookTable(15).apiName := 'UPDATE_NOTE' ;
         hookTable(15).hookType := 'V' ; -- Vertical
         hookTable(15).processingType := 'B' ;

         hookTable(16).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
         hookTable(16).apiName := 'CAPTURE_COUNTER_READING' ;
         hookTable(16).hookType := 'V' ; -- Vertical
         hookTable(16).processingType := 'A' ;

         hookTable(17).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
         hookTable(17).apiName := 'UPDATE_COUNTER_READING' ;
         hookTable(17).hookType := 'V' ; -- Vertical
         hookTable(17).processingType := 'B' ;

         hookTable(18).packageName := 'JTM_RS_GROUP_MEMBERS_PVT' ;
         hookTable(18).apiName := 'CREATE_RESOURCE_GROUP_MEMBERS' ;
         hookTable(18).hookType := 'V' ; -- Vertical
         hookTable(18).processingType := 'A' ;

         hookTable(19).packageName := 'JTM_RS_GROUP_MEMBERS_PVT' ;
         hookTable(19).apiName := 'DELETE_RESOURCE_GROUP_MEMBERS' ;
         hookTable(19).hookType := 'V' ; -- Vertical
         hookTable(19).processingType := 'B' ;

         hookTable(20).packageName := 'JTM_COUNTERS_PUB' ;
         hookTable(20).apiName := 'CREATE_COUNTER' ;
         hookTable(20).hookType := 'V' ; -- Vertical
         hookTable(20).processingType := 'A' ;

         hookTable(21).packageName := 'JTM_COUNTERS_PUB' ;
         hookTable(21).apiName := 'UPDATE_COUNTER' ;
         hookTable(21).hookType := 'V' ; -- Vertical
         hookTable(21).processingType := 'B' ;

         hookTable(22).packageName := 'CS_ServiceRequest_PVT' ;
         hookTable(22).apiName := 'Create_ServiceRequest' ;
         hookTable(22).hookType := 'I' ; -- Internal
         hookTable(22).processingType := 'A' ;

         hookTable(23).packageName := 'JTF_TASKS_PUB' ;
	 hookTable(23).apiName := 'CREATE_TASK' ;
         hookTable(23).hookType := 'I' ; -- Internal
         hookTable(23).processingType := 'A' ;

         hookTable(24).packageName := 'JTF_TASKS_PUB' ;
	 hookTable(24).apiName := 'DELETE_TASK' ;
         hookTable(24).hookType := 'I' ; -- Internal
         hookTable(24).processingType := 'A' ;

         hookTable(25).packageName := 'CSP_SHIP_TO_ADDRESS_PVT' ;
	 hookTable(25).apiName := 'SHIP_TO_ADDRESS_HANDLER' ;
         hookTable(25).hookType := 'I' ; -- Internal
         hookTable(25).processingType := 'A' ;

         hookTable(26).packageName := 'CSP_SHIP_TO_ADDRESS_PVT' ;
	 hookTable(26).apiName := 'UPDATE_LOCATION' ;
         hookTable(26).hookType := 'I' ; -- Internal
         hookTable(26).processingType := 'A' ;

         hookTable(27).packageName := 'CSP_REQUIREMENT_HEADERS_PKG' ;
	 hookTable(27).apiName := 'UPDATE_ROW' ;
         hookTable(27).hookType := 'I' ; -- Internal
         hookTable(27).processingType := 'A' ;

         hookTable(28).packageName := 'CSP_REQUIREMENT_HEADERS_PKG' ;
	 hookTable(28).apiName := 'INSERT_ROW' ;
         hookTable(28).hookType := 'I' ; -- Internal
         hookTable(28).processingType := 'A' ;

         hookTable(29).packageName := 'CSP_REQUIREMENT_HEADERS_PKG' ;
	 hookTable(29).apiName := 'DELETE_ROW' ;
         hookTable(29).hookType := 'I' ; -- Internal
         hookTable(29).processingType := 'A' ;

         hookTable(30).packageName := 'CSP_REQUIREMENT_LINES_PKG' ;
	 hookTable(30).apiName := 'UPDATE_ROW' ;
         hookTable(30).hookType := 'I' ; -- Internal
         hookTable(30).processingType := 'A' ;

         hookTable(31).packageName := 'CSP_REQUIREMENT_LINES_PKG' ;
	 hookTable(31).apiName := 'INSERT_ROW' ;
         hookTable(31).hookType := 'I' ; -- Internal
         hookTable(31).processingType := 'A' ;

         hookTable(32).packageName := 'CSP_REQUIREMENT_LINES_PKG' ;
	 hookTable(32).apiName := 'DELETE_ROW' ;
         hookTable(32).hookType := 'I' ; -- Internal
         hookTable(32).processingType := 'A' ;

         FOR i IN 1..hookTable.COUNT LOOP
            BEGIN
                select 'Y'
                  into hookExists
                  from jtf_hooks_data
                 where package_name = hookTable(i).packageName
                   and api_name = hookTable(i).apiName
                   and hook_type = hookTable(i).hookType
                   and processing_type = hookTable(i).processingType
                   and execute_flag = 'Y'
                   and product_code = 'CSM' ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     hookExists := 'N' ;
            END  ;

            IF (hookExists = 'Y') THEN
                if reportStr is null then
                   reportStr := 'Hook registered for ' || hookTable(i).packageName || '.' || hookTable(i).apiName || ' with processing type '||hookTable(i).processingType  ;
                else
                   reportStr := ', ' || hookTable(i).packageName || '.' || hookTable(i).apiName || ' with processing type '||hookTable(i).processingType  ;
                end if ;
                JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
                if statusStr is null or statusStr = 'SUCCESS' then
                   statusStr := 'SUCCESS';
                end if ;
           ELSE
              statusStr := 'FAILURE';
              if errStr is null then
                 errStr := errStr || 'Hook not registered for ' || hookTable(i).packageName || '.' || hookTable(i).apiName || ' with processing type '||hookTable(i).processingType  ;
              else
                 errStr := errStr || ', ' || hookTable(i).packageName || '.' || hookTable(i).apiName || ' with processing type '||hookTable(i).processingType  ;
              end if ;
              fixInfo := 'Apply latest patch then contact support (if needed).' ;
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
    str := 'User Hooks Registration Status';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'User Hooks Registration';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Check User Hooks';
  END getTestName;

   -- Enter further code below as specified in the Package spec.
END;

/
