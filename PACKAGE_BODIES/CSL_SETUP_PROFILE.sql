--------------------------------------------------------
--  DDL for Package Body CSL_SETUP_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_SETUP_PROFILE" AS
/* $Header: cslstprb.pls 120.0 2005/05/24 17:45:58 appldev noship $ */

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
  jtmProfileValue    VARCHAR2(255) ;
  cslProfileValue    VARCHAR2(255) ;
  profileValue       VARCHAR2(255) ;
  TYPE profileTab IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  profileTable profileTab ;

BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);

     /*First level specific profiles*/
     jtmProfileValue := fnd_profile.VALUE_SPECIFIC(
          Name => 'JTM_MOB_APPS_ENABLED', APPLICATION_ID => 874); -- JTM

     cslProfileValue := fnd_profile.VALUE_SPECIFIC(
          Name => 'JTM_MOB_APPS_ENABLED', APPLICATION_ID => 868, RESPONSIBILITY_ID => 22916 ); --CSL

     IF (jtmProfileValue = 'Y') AND (cslProfileValue = 'Y') THEN
        reportStr := '-Profile option values for JTM: Mobile Applications Enabled are set up correct'||
	             ' for JTM and CSL-';
        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
        statusStr := 'SUCCESS';
     ELSE
        statusStr := 'FAILURE';
	IF jtmProfileValue = 'N' THEN
	   errStr := 'JTM: Mobile Applications Enabled profile is not set to Y for application'||
	             ' Oracle CRM Mobile Foundation ';
	   fixInfo :='Set the application specific JTM: Mobile Applications Enabled profile value to Y.';
	ELSIF cslProfileValue = 'N' THEN
	   IF errStr IS NULL THEN
              errStr := 'JTM: Mobile Applications Enabled profile is not set to Y for Oracle Field Service'||
	                ' / Laptop responsibility';
	   ELSE
              errStr := errStr||', JTM: Mobile Applications Enabled profile is not set to Y for '||
	                        'Oracle Field Service / Laptop responsibility';
	   END IF;
	   IF fixInfo IS NULL THEN
              fixInfo := 'Set the responsibility specific JTM: Mobile Applications Enabled profile '||
	                 'value to Y.' ;
	   ELSE
	      fixInfo :=fixInfo||', Set the responsibility specific JTM: Mobile Applications Enabled'||
	                         ' profile value to Y.' ;
	   END IF;
	END IF;
	isFatal := 'FALSE';
     END IF;

     jtmProfileValue := fnd_profile.VALUE_SPECIFIC(
          Name => 'JTM_DEFAULT_LOGON_RESPONSIBILITY', APPLICATION_ID => 868); -- CSL
     IF jtmProfileValue = 'CSL_IMOBILE' THEN
         reportStr := '-Profile JTM: Default Logon Responsibility for CRM Mobile Application '||
	              'is correct set to Oracle Field Service/Laptop-';
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
     ELSE
       IF errStr IS NULL THEN
         errStr := 'Profile JTM: Default Logon Responsibility for CRM Mobile Application '||
	           'is not set to Oracle Field Service/Laptop on application level';
       ELSE
         errStr := errStr|| ', Profile JTM: Default Logon Responsibility for CRM Mobile Application '||
	                    'is not set to Oracle Field Service/Laptop on application level';
       END IF;
       IF fixInfo IS NULL THEN
         fixInfo := 'Set the profile at application level to Oracle Field Service/Laptop';
       ELSE
         fixInfo := fixInfo||', Set the profile at application level to Oracle Field Service/Laptop';
       END IF;
     END IF;

     /*Site level profiles, can add more if needed*/
     --Bug 3724123
     profileTable(1) := 'CS_INV_VALIDATION_ORG' ;
     reportStr := NULL;
     FOR i IN 1..profileTable.COUNT LOOP
       profileValue := null ;
       fnd_profile.get(profileTable(i),profileValue) ;
       IF profileValue IS NOT NULL THEN
          reportStr := '-Profile option value set for profile '|| profileTable(i)||' to: '||profileValue||'-';
          JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
          IF statusStr IS NULL OR statusStr = 'SUCCESS' THEN
             statusStr := 'SUCCESS';
          END IF;
        ELSE
           statusStr := 'FAILURE';
           IF errStr IS NULL THEN
              errStr := errStr || 'Profile option value not set for ' || profileTable(i);
           ELSE
              errStr := errStr || ', ' || profileTable(i) ;
           END IF;
           IF fixInfo IS NULL THEN
              fixInfo := fixInfo || 'Set up Profile option values for ' || profileTable(i);
           ELSE
              fixInfo := fixInfo || ', ' || profileTable(i) ;
           END IF;
           isFatal := 'FALSE';
        END IF;
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
 str := 'Profile setup';
END getComponentName;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
PROCEDURE getTestName(str OUT NOCOPY  VARCHAR2)
IS
BEGIN
 str := 'Check Profiles';
END getTestName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2)
IS
BEGIN
 str := 'Check profiles for their values';
END getTestDesc;

END CSL_SETUP_PROFILE;

/
