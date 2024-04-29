--------------------------------------------------------
--  DDL for Package Body CSL_SETUP_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_SETUP_HOOKS" AS
/* $Header: cslsthkb.pls 115.5 2002/11/14 13:58:24 asiegers ship $ */

------------------------------------------------------------
-- procedure to initialize test datastructures
-- executeds prior to test run (not currently being called)
------------------------------------------------------------
PROCEDURE init
IS
BEGIN
 NULL;
END init;

------------------------------------------------------------
-- procedure to cleanup any  test datastructures that were setup in the init
--  procedure call executes after test run (not currently being called)
------------------------------------------------------------
PROCEDURE cleanup
IS
BEGIN
 NULL;
END cleanup ;


------------------------------------------------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are -- returned.
------------------------------------------------------------
PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB)
IS
  reportStr          LONG;
  statusStr          VARCHAR2(50);  -- SUCCESS or FAILURE
  errStr             VARCHAR2(4000);
  fixInfo            VARCHAR2(4000);
  isFatal            VARCHAR2(50);  -- TRUE or FALSE
  hookExists         VARCHAR2(1) ;

  TYPE hookRec IS RECORD (packageName varchar2 (50),
                          apiName varchar2(50),
                          hookType varchar2(1),
                          processingType varchar2(1)) ;

  TYPE hookTab IS TABLE OF hookRec INDEX BY BINARY_INTEGER;
       hookTable hookTab ;


  CURSOR c_hook( b_package_name VARCHAR2,
                 b_api_name     VARCHAR2,
				 b_hook_type    VARCHAR2,
                 b_process_type VARCHAR2 ) IS
     SELECT EXECUTE_FLAG
	 ,      HOOK_PACKAGE
	 ,      HOOK_API
	 FROM JTF_HOOKS_DATA
	 WHERE PRODUCT_CODE    = 'CSL'
	 AND   PACKAGE_NAME    = b_package_name
	 AND   API_NAME        = b_api_name
	 AND   HOOK_TYPE       = b_hook_type
	 AND   PROCESSING_TYPE = b_process_type
	 AND   EXECUTE_FLAG    = 'Y';
  r_hook c_hook%ROWTYPE;

BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);

  hookTable(1).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(1).apiName := 'DELETE_ROW' ;
  hookTable(1).hookType := 'I' ;
  hookTable(1).processingType := 'B' ;

  hookTable(2).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(2).apiName := 'DELETE_ROW' ;
  hookTable(2).hookType := 'I' ;
  hookTable(2).processingType := 'A' ;

  hookTable(3).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(3).apiName := 'INSERT_ROW' ;
  hookTable(3).hookType := 'I' ;
  hookTable(3).processingType := 'B' ;

  hookTable(4).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(4).apiName := 'INSERT_ROW' ;
  hookTable(4).hookType := 'I' ;
  hookTable(4).processingType := 'A' ;

  hookTable(5).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(5).apiName := 'UPDATE_ROW' ;
  hookTable(5).hookType := 'I' ;
  hookTable(5).processingType := 'B' ;

  hookTable(6).packageName := 'CSF_DEBRIEF_LINES_IUHK' ;
  hookTable(6).apiName := 'UPDATE_ROW' ;
  hookTable(6).hookType := 'I' ;
  hookTable(6).processingType := 'A' ;

  hookTable(7).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
  hookTable(7).apiName := 'DELETE_ROW' ;
  hookTable(7).hookType := 'I' ;
  hookTable(7).processingType := 'B' ;

  hookTable(8).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
  hookTable(8).apiName := 'INSERT_ROW' ;
  hookTable(8).hookType := 'I' ;
  hookTable(8).processingType := 'A' ;

  hookTable(9).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
  hookTable(9).apiName := 'UPDATE_ROW' ;
  hookTable(9).hookType := 'I' ;
  hookTable(9).processingType := 'B' ;

  hookTable(10).packageName := 'CSP_INV_LOC_ASSIGNMENTS_IUHK' ;
  hookTable(10).apiName := 'UPDATE_ROW' ;
  hookTable(10).hookType := 'I' ;
  hookTable(10).processingType := 'A' ;

  hookTable(11).packageName := 'CSP_REQUIREMENT_HEADERS_PKG' ;
  hookTable(11).apiName := 'INSERT_ROW' ;
  hookTable(11).hookType := 'I' ;
  hookTable(11).processingType := 'A' ;

  hookTable(12).packageName := 'CSP_REQUIREMENT_HEADERS_PKG' ;
  hookTable(12).apiName := 'UPDATE_ROW' ;
  hookTable(12).hookType := 'I' ;
  hookTable(12).processingType := 'A' ;

  hookTable(13).packageName := 'CSP_REQUIREMENT_LINES_PKG' ;
  hookTable(13).apiName := 'INSERT_ROW' ;
  hookTable(13).hookType := 'I' ;
  hookTable(13).processingType := 'A' ;

  hookTable(14).packageName := 'CSP_REQUIREMENT_LINES_PKG' ;
  hookTable(14).apiName := 'UPDATE_ROW' ;
  hookTable(14).hookType := 'I' ;
  hookTable(14).processingType := 'A' ;

  hookTable(15).packageName := 'CSP_SHIP_TO_ADDRESS_PVT' ;
  hookTable(15).apiName := 'SHIP_TO_ADDRESS_HANDLER' ;
  hookTable(15).hookType := 'I' ;
  hookTable(15).processingType := 'A' ;

  hookTable(16).packageName := 'CSP_SHIP_TO_ADDRESS_PVT' ;
  hookTable(16).apiName := 'UPDATE_LOCATION' ;
  hookTable(16).hookType := 'I' ;
  hookTable(16).processingType := 'A' ;

  hookTable(17).packageName := 'CS_ServiceRequest_PVT' ;
  hookTable(17).apiName := 'Create_ServiceRequest' ;
  hookTable(17).hookType := 'I' ;
  hookTable(17).processingType := 'B' ;

  hookTable(18).packageName := 'CS_ServiceRequest_PVT' ;
  hookTable(18).apiName := 'Create_ServiceRequest' ;
  hookTable(18).hookType := 'I' ;
  hookTable(18).processingType := 'A' ;

  hookTable(19).packageName := 'CS_ServiceRequest_PVT' ;
  hookTable(19).apiName := 'Update_ServiceRequest' ;
  hookTable(19).hookType := 'I' ;
  hookTable(19).processingType := 'B' ;

  hookTable(20).packageName := 'CS_ServiceRequest_PVT' ;
  hookTable(20).apiName := 'Update_ServiceRequest' ;
  hookTable(20).hookType := 'I' ;
  hookTable(20).processingType := 'A' ;

  hookTable(21).packageName := 'JTF_TASKS_PUB' ;
  hookTable(21).apiName := 'CREATE_TASK' ;
  hookTable(21).hookType := 'I' ;
  hookTable(21).processingType := 'B' ;

  hookTable(22).packageName := 'JTF_TASKS_PUB' ;
  hookTable(22).apiName := 'CREATE_TASK' ;
  hookTable(22).hookType := 'I' ;
  hookTable(22).processingType := 'A' ;

  hookTable(23).packageName := 'JTF_TASKS_PUB' ;
  hookTable(23).apiName := 'DELETE_TASK' ;
  hookTable(23).hookType := 'I' ;
  hookTable(23).processingType := 'B' ;

  hookTable(24).packageName := 'JTF_TASKS_PUB' ;
  hookTable(24).apiName := 'DELETE_TASK' ;
  hookTable(24).hookType := 'I' ;
  hookTable(24).processingType := 'A' ;

  hookTable(25).packageName := 'JTF_TASKS_PUB' ;
  hookTable(25).apiName := 'UPDATE_TASK' ;
  hookTable(25).hookType := 'I' ;
  hookTable(25).processingType := 'B' ;

  hookTable(26).packageName := 'JTF_TASKS_PUB' ;
  hookTable(26).apiName := 'UPDATE_TASK' ;
  hookTable(26).hookType := 'I' ;
  hookTable(26).processingType := 'A' ;

  hookTable(27).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(27).apiName := 'CREATE_TASK_ASSIGNMENT' ;
  hookTable(27).hookType := 'I' ;
  hookTable(27).processingType := 'B' ;

  hookTable(28).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(28).apiName := 'CREATE_TASK_ASSIGNMENT' ;
  hookTable(28).hookType := 'I' ;
  hookTable(28).processingType := 'A' ;

  hookTable(29).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(29).apiName := 'DELETE_TASK_ASSIGNMENT' ;
  hookTable(29).hookType := 'I' ;
  hookTable(29).processingType := 'B' ;

  hookTable(30).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(30).apiName := 'DELETE_TASK_ASSIGNMENT' ;
  hookTable(30).hookType := 'I' ;
  hookTable(30).processingType := 'A' ;

  hookTable(31).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(31).apiName := 'UPDATE_TASK_ASSIGNMENT' ;
  hookTable(31).hookType := 'I' ;
  hookTable(31).processingType := 'B' ;

  hookTable(32).packageName := 'JTF_TASK_ASSIGNMENTS_PUB' ;
  hookTable(32).apiName := 'UPDATE_TASK_ASSIGNMENT' ;
  hookTable(32).hookType := 'I' ;
  hookTable(32).processingType := 'A' ;

  hookTable(33).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(33).apiName := 'CREATE_COUNTER' ;
  hookTable(33).hookType := 'V' ;
  hookTable(33).processingType := 'A' ;

  hookTable(34).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(34).apiName := 'CREATE_CTR_GRP_INSTANCE' ;
  hookTable(34).hookType := 'V' ;
  hookTable(34).processingType := 'A' ;

  hookTable(35).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(35).apiName := 'CREATE_CTR_PROP' ;
  hookTable(35).hookType := 'V' ;
  hookTable(35).processingType := 'A' ;

  hookTable(36).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(36).apiName := 'DELETE_COUNTER' ;
  hookTable(36).hookType := 'V' ;
  hookTable(36).processingType := 'B' ;

  hookTable(37).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(37).apiName := 'DELETE_CTR_PROP' ;
  hookTable(37).hookType := 'V' ;
  hookTable(37).processingType := 'B' ;

  hookTable(38).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(38).apiName := 'UPDATE_COUNTER' ;
  hookTable(38).hookType := 'V' ;
  hookTable(38).processingType := 'A' ;

  hookTable(39).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(39).apiName := 'UPDATE_CTR_GRP' ;
  hookTable(39).hookType := 'V' ;
  hookTable(39).processingType := 'A' ;

  hookTable(40).packageName := 'JTM_COUNTERS_PUB' ;
  hookTable(40).apiName := 'UPDATE_CTR_PROP' ;
  hookTable(40).hookType := 'V' ;
  hookTable(40).processingType := 'A' ;

  hookTable(41).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
  hookTable(41).apiName := 'CAPTURE_COUNTER_READING' ;
  hookTable(41).hookType := 'V' ;
  hookTable(41).processingType := 'A' ;

  hookTable(42).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
  hookTable(42).apiName := 'CAPTURE_CTR_PROP_READING' ;
  hookTable(42).hookType := 'V' ;
  hookTable(42).processingType := 'A' ;

  hookTable(43).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
  hookTable(43).apiName := 'UPDATE_COUNTER_READING' ;
  hookTable(43).hookType := 'V' ;
  hookTable(43).processingType := 'A' ;

  hookTable(44).packageName := 'JTM_CTR_CAPTURE_READING_PUB' ;
  hookTable(44).apiName := 'UPDATE_COUNTER_READING' ;
  hookTable(44).hookType := 'V' ;
  hookTable(44).processingType := 'A' ;

  hookTable(45).packageName := 'JTM_ITEM_INSTANCE_PUB' ;
  hookTable(45).apiName := 'CREATE_ITEM_INSTANCE' ;
  hookTable(45).hookType := 'V' ;
  hookTable(45).processingType := 'A' ;

  hookTable(46).packageName := 'JTM_NOTES_PUB' ;
  hookTable(46).apiName := 'CREATE_NOTE' ;
  hookTable(46).hookType := 'V' ;
  hookTable(46).processingType := 'A' ;

  hookTable(47).packageName := 'JTM_NOTES_PUB' ;
  hookTable(47).apiName := 'UPDATE_NOTE' ;
  hookTable(47).hookType := 'V' ;
  hookTable(47).processingType := 'A' ;

  hookTable(48).packageName := 'JTM_RS_GROUP_MEMBERS_PVT' ;
  hookTable(48).apiName := 'CREATE_RESOURCE_GROUP_MEMBERS' ;
  hookTable(48).hookType := 'V' ;
  hookTable(48).processingType := 'A' ;

  hookTable(49).packageName := 'JTM_RS_GROUP_MEMBERS_PVT' ;
  hookTable(49).apiName := 'DELETE_RESOURCE_GROUP_MEMBERS' ;
  hookTable(49).hookType := 'V' ;
  hookTable(49).processingType := 'B' ;

  FOR i IN 1..hookTable.COUNT LOOP
	 OPEN c_hook ( hookTable(i).packageName,
	               hookTable(i).apiName,
				   hookTable(i).hookType,
				   hookTable(i).processingType );
	 FETCH c_hook INTO r_hook;
	 IF c_hook%FOUND THEN
         reportStr := '-Hook registered for ' || hookTable(i).packageName || '.' ||
                       hookTable(i).apiName || ' with processing type '||hookTable(i).processingType||
					   ' to package '||r_hook.hook_package||'-';
         JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
         if statusStr is null or statusStr = 'SUCCESS' then
            statusStr := 'SUCCESS';
         end if ;
      ELSE
        statusStr := 'FAILURE';
        if errStr is null then
           errStr := 'Hook not registered for ' || hookTable(i).packageName || '.' ||
	             hookTable(i).apiName || ' with processing type '||hookTable(i).processingType;
        else
           errStr := errStr || ', ' || hookTable(i).packageName || '.' || hookTable(i).apiName ||
	                      ' with processing type '||hookTable(i).processingType  ;
        end if ;
        fixInfo := 'Apply latest patch then contact support (if needed).' ;
        isFatal := 'FALSE';
      END IF;
	  CLOSE c_hook;
  END LOOP ;

  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runtest;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(str OUT NOCOPY  VARCHAR2)
IS
BEGIN
 str := 'User hook setup';
END getComponentName;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
PROCEDURE getTestName(str OUT NOCOPY  VARCHAR2)
IS
BEGIN
 str := 'User hook status';
END getTestName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2)
IS
BEGIN
 str := 'Check Oracle Field Service / Laptop hooks';
END getTestDesc;

END CSL_SETUP_HOOKS;

/
