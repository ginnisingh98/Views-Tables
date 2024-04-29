--------------------------------------------------------
--  DDL for Package Body CSM_SETUP_JTMCONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SETUP_JTMCONC" AS
/* $Header: csmdjcrb.pls 120.1 2005/07/22 04:52:58 trajasek noship $ */
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
     concExists  VARCHAR2(1) ;

     TYPE concRec IS RECORD (packageName varchar2 (30),
                            procedureName varchar2(30)) ;

     TYPE concTab IS TABLE OF concRec INDEX BY BINARY_INTEGER;
     concTable concTab ;
   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);

         concTable(1).packageName := 'CSM_BUS_PROCESS_TXNS_EVENT_PKG' ;
         concTable(1).procedureName := 'REFRESH_ACC' ;

         concTable(2).packageName := 'CSM_CURRENCY_EVENT_PKG' ;
         concTable(2).procedureName := 'REFRESH_ACC' ;

         concTable(3).packageName := 'CSM_LOOKUP_EVENT_PKG' ;
         concTable(3).procedureName := 'REFRESH_ACC' ;

         concTable(4).packageName := 'CSM_MESSAGES_EVENT_PKG' ;
         concTable(4).procedureName := 'REFRESH_ACC' ;

         concTable(5).packageName := 'CSM_PROFILE_EVENT_PKG' ;
         concTable(5).procedureName := 'REFRESH_ACC' ;

         concTable(6).packageName := 'CSM_SYSTEM_ITEM_EVENT_PKG' ;
         concTable(6).procedureName := 'REFRESH_ACC' ;

         concTable(7).packageName := 'CSM_SYSTEM_ITEM_EVENT_PKG' ;
         concTable(7).procedureName := 'REFRESH_MTL_ONHAND_QUANTITY' ;

         concTable(8).packageName := 'CSM_TXN_BILL_TYPES_EVENT_PKG' ;
         concTable(8).procedureName := 'REFRESH_ACC' ;

         concTable(9).packageName := 'CSM_UOM_EVENT_PKG' ;
         concTable(9).procedureName := 'REFRESH_ACC' ;

         concTable(10).packageName := 'CSM_UTIL_PKG' ;
         concTable(10).procedureName := 'REFRESH_ALL_APP_LEVEL_ACC' ;

         concTable(11).packageName := 'CSM_TASK_ASSIGNMENT_EVENT_PKG' ;
         concTable(11).procedureName := 'PURGE_TASK_ASSIGNMENTS_CONC' ;

         concTable(12).packageName := 'CSM_STATE_TRANSITION_EVENT_PKG' ;
         concTable(12).procedureName := 'REFRESH_ACC' ;

         concTable(13).packageName := 'CSM_SR_EVENT_PKG' ;
         concTable(13).procedureName := 'PURGE_INCIDENTS_CONC' ;

         concTable(14).packageName := 'CSM_TASK_EVENT_PKG' ;
         concTable(14).procedureName := 'PURGE_TASKS_CONC' ;

         concTable(15).packageName := 'CSM_MTL_SYSTEM_ITEMS_EVENT_PKG' ;
         concTable(15).procedureName := 'REFRESH_MTL_SYSTEM_ITEMS_ACC' ;

         concTable(16).packageName := 'CSM_MTL_TXN_REASONS_EVENT_PKG' ;
         concTable(16).procedureName := 'REFRESH_MTL_TXN_REASONS_ACC' ;

         concTable(17).packageName := 'CSM_MTL_ITEM_SUBINV_EVENT_PKG' ;
         concTable(17).procedureName := 'REFRESH_ACC' ;

         concTable(18).packageName := 'CSM_SERIAL_NUMBERS_EVENT_PKG' ;
         concTable(18).procedureName := 'REFRESH_MTL_SERIAL_NUMBERS_ACC' ;

         concTable(19).packageName := 'CSM_MTL_SEC_INV_EVENT_PKG' ;
         concTable(19).procedureName := 'REFRESH_ACC' ;

         concTable(20).packageName := 'CSM_SERVICE_HISTORY_EVENT_PKG' ;
         concTable(20).procedureName := 'CONCURRENT_HISTORY' ;

         FOR i IN 1..concTable.COUNT LOOP
            BEGIN
                select 'Y'
                  into concExists
                  from jtm_con_request_data
                 where package_name = concTable(i).packageName
                   and procedure_name = concTable(i).procedureName
                   and execute_flag = 'Y'
                   and product_code = 'CSM' ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     concExists := 'N' ;
            END  ;

            IF (concExists = 'Y') THEN
                if reportStr is null then
                   reportStr := 'In JTM Common Concurrent Program registered APIs are ' || concTable(i).packageName || '.' || concTable(i).procedureName ;
                else
                   reportStr := ', ' || concTable(i).packageName || '.' || concTable(i).procedureName ;
                end if ;
                JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
                if statusStr is null or statusStr = 'SUCCESS' then
                   statusStr := 'SUCCESS';
                end if ;
           ELSE
              statusStr := 'FAILURE';
              if errStr is null then
                 errStr := errStr || 'In JTM Common Concurrent Program not registered APIs are ' || concTable(i).packageName || '.' || concTable(i).procedureName ;
              else
                 errStr := errStr || ', ' || concTable(i).packageName || '.' || concTable(i).procedureName ;
              end if ;
              fixInfo := 'Apply latest patch then call support (if not fixed).' ;
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
    str := 'JTM Common Concurrent Program Registration Status';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'JTM Common Concurrent Program Registration';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Check JTM Concurrent Program Registration';
  END getTestName;
   -- Enter further code below as specified in the Package spec.
END;

/
