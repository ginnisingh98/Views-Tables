--------------------------------------------------------
--  DDL for Package Body CSM_SETUP_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SETUP_PROFILE" AS
/* $Header: csmdprfb.pls 120.3 2006/02/16 07:52:03 trajasek noship $ */
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
     errStr1     VARCHAR2(4000);
     fixInfo1    VARCHAR2(4000);
     itemCatErrStr     VARCHAR2(4000);
     itemCatFixInfo    VARCHAR2(4000);
     isFatal     VARCHAR2(50);  -- TRUE or FALSE
     jtmProfileValue  VARCHAR2(255) ;
     csmProfileValue  VARCHAR2(255) ;
     itemCatProf      VARCHAR2(255) ;
     itemCatSetProf     VARCHAR2(255) ;
     itemCatProfName    VARCHAR2(255) := 'CSM_ITEM_CATEGORY_FILTER' ;
     itemCatProfUser    VARCHAR2(255) := 'CSM: Item Category Filter' ;
     itemCatSetProfName VARCHAR2(255) := 'CSM_ITEM_CATEGORY_SET_FILTER';
     itemCatSetProfUser VARCHAR2(255) := 'CSM: Item Category Set Filter';
     ProfileValue  VARCHAR2(255) ;
     respId NUMBER ;
     dummy varchar2(1) ;
     TYPE profileRec IS RECORD (profileName varchar2 (255), profileUserName varchar2(255)) ;
     TYPE profileTab IS TABLE OF profileRec INDEX BY BINARY_INTEGER;
     profileTable profileTab ;

     cursor itemProfVal(itemCat in Number,
                        itemCatSet in Number) is
    SELECT  'X'
      FROM  mtl_categories_kfv mck,
            mtl_categories_vl mcv,
            mtl_category_sets_vl mcs
     WHERE mck.category_id = mcv.category_id
       AND mcv.enabled_flag = 'Y'
       AND NVL(mcv.disable_date, sysdate) >= SYSDATE
       AND mcs.category_set_id =  itemCatSet
       AND mcv.category_id = itemCat
       AND mcs.structure_id = mck.structure_id
       AND mcs.validate_flag = 'N'
    UNION
    SELECT 'X'
      FROM mtl_category_set_valid_cats valid_cat,
           mtl_categories_kfv mck,
           mtl_categories_vl mcv,
           mtl_category_sets_vl mcs
     WHERE valid_cat.category_set_id = mcs.category_set_id
       AND mcs.category_set_id = itemCatSet
       AND mck.category_id = itemCat
       AND  mcs.validate_flag = 'Y'
       AND  valid_cat.category_id = mck.category_id
       AND  mck.category_id = mcv.category_id
       AND  mcv.enabled_flag = 'Y'
       AND  NVL(mcv.disable_date, sysdate) >= SYSDATE ;
     itemProfValNotFound exception ;

   BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars(reportClob);
--R12 Changes
--     profileTable(1).profileName := 'CSF_M_HISTORY' ;
--     profileTable(1).profileUserName := 'CSF: History_M' ;
--     profileTable(2).profileName := 'CSF_PALM_ITEM_ORGANIZATION' ;
--     profileTable(2).profileUserName := 'CSF: Palm Inventory Organization' ;
     profileTable(1).profileName := 'JTM_APPL_CONFLICT_RULE' ;
     profileTable(1).profileUserName := 'JTM: Application Conflict Rule' ;
     profileTable(2).profileName := 'CSF_M_RECIPIENTS_BOUNDARY' ;
     profileTable(2).profileUserName := 'CSM: Notifications Scope' ;
     profileTable(3).profileName := 'CSF_M_AGENDA_ALLOWCHANGESCOMPLETEDTASK' ;
     profileTable(3).profileUserName := 'CSM: Allow Changes to Completed Tasks' ;
--R12 Changes
--     profileTable(6).profileName := 'JTM_CREDIT_CARD_ENABLED' ;
--     profileTable(6).profileUserName := 'JTM : Enable credit card functionality' ;
--     profileTable(7).profileName := 'CSF_DEFAULT_TASK_NEW_STATUS' ;
--     profileTable(7).profileUserName := 'CSF: Default New task status' ;
     profileTable(4).profileName := 'INC_DEFAULT_INCIDENT_SEVERITY' ;
     profileTable(4).profileUserName := 'Service: Default Service Request Severity' ;
     profileTable(5).profileName := 'INC_DEFAULT_INCIDENT_URGENCY' ;
     profileTable(5).profileUserName := 'Service: Default Service Request Urgency' ;
     profileTable(6).profileName := 'JTF_TIME_UOM_CLASS' ;
     profileTable(6).profileUserName := 'Time unit of measure class' ;
     profileTable(7).profileName := 'CSM_HISTORY_COUNT' ;
     profileTable(7).profileUserName := 'CSM : Number of Previously Closed Service Requests' ;
     profileTable(8).profileName := 'CSM_SYNCHRONOUS_HISTORY' ;
     profileTable(8).profileUserName := 'CSM : Synchronous History Collection' ;
     profileTable(9).profileName := 'ICX_PREFERRED_CURRENCY' ;
     profileTable(9).profileUserName := 'ICX : Preferred Currency' ;
     profileTable(10).profileName := 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS' ;
     profileTable(10).profileUserName := 'Task Manager: Default assignee status' ;
     profileTable(11).profileName := 'SERVER_TIMEZONE_ID' ;
     profileTable(11).profileUserName := 'Server Timezone' ;
     profileTable(12).profileName := 'CLIENT_TIMEZONE_ID' ;
     profileTable(12).profileUserName := 'Client Timezone' ;

     jtmProfileValue := fnd_profile.VALUE_SPECIFIC(
          'JTM_MOB_APPS_ENABLED', null, null, 874); -- JTM

     BEGIN
	select responsibility_id
	  into respId
          from fnd_responsibility
         where application_id = 883
	   and responsibility_key = 'OMFS_PALM'
	   and sysdate between start_date and nvl(end_date, sysdate) ;
     exception
	WHEN NO_DATA_FOUND THEN
		null ;
     END ;
     csmProfileValue := fnd_profile.VALUE_SPECIFIC(
          'JTM_MOB_APPS_ENABLED', null, respId, 883); --Field Service Palm resp

     IF (jtmProfileValue = 'Y') and (csmProfileValue = 'Y') then
        reportStr := 'Profile option values set Yes for profile JTM: Mobile Applications Enabled'  ;
        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
        statusStr := 'SUCCESS';
     ELSE
              statusStr := 'FAILURE';
              errStr := 'JTM application level and/or Oracle Mobile Field Service responsibility level JTM: Mobile Applications Enabled profile value is not set.';
              fixInfo := 'Set up JTM application and Oracle Mobile Field Service responsibility level JTM: Mobile Applications Enabled profile value to Y.' ;
              isFatal := 'FALSE';
     END IF;
     FOR i IN 1..profileTable.COUNT LOOP
        profileValue := null ;
        fnd_profile.get(profileTable(i).profileName,profileValue) ;
        IF profileValue IS NOT NULL then
           if reportStr is null then
                   reportStr := 'Profile option value set for profile ' || profileTable(i).profileUserName || ' as '|| profileValue ;
           else
                   reportStr := ', ' || profileTable(i).profileUserName  || ' as '|| profileValue;
           end if ;
           JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
           if statusStr is null or statusStr = 'SUCCESS' then
              statusStr := 'SUCCESS';
           end if ;
        ELSE
           statusStr := 'FAILURE';
           if errStr1 is null then
              errStr1 := errStr || 'Profile option value not set for ' || profileTable(i).profileUserName;
           else
              errStr1 := errStr1 || ', ' || profileTable(i).profileUserName ;
           end if ;
           if fixInfo1 is null then
              fixInfo1 := fixInfo || 'Set up Profile option values for ' || profileTable(i).profileUserName;
           else
              fixInfo1 := fixInfo1 || ', ' || profileTable(i).profileUserName ;
           end if ;
              isFatal := 'FALSE';
        END IF;
     END LOOP ;
     -- Check for Item Category and Item Category Set
     fnd_profile.get(itemCatProfName,itemCatProf) ;
     fnd_profile.get(itemCatSetProfName,itemCatSetProf) ;
     IF (itemCatProf IS NULL AND itemCatSetProf IS NULL) then
         reportStr := ' Profile option value not set for profile ' || itemCatProfUser || ' and '|| itemCatSetProfUser || '.' ;
         JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
         if statusStr is null or statusStr = 'SUCCESS' then
              statusStr := 'SUCCESS';
         end if ;
     ELSIF (itemCatProf IS NOT NULL AND itemCatSetProf IS NOT NULL) THEN
       BEGIN
           open itemProfVal(to_number(itemCatProf), to_number(itemCatSetProf)) ;
           fetch itemProfVal into dummy ;
           if itemProfVal%found then
             reportStr := ' Profile option value set for profile ' || itemCatProfUser  || ' and '|| itemCatSetProfUser ||  '.' ;
             JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
             if statusStr is null or statusStr = 'SUCCESS' then
                statusStr := 'SUCCESS';
             end if ;
           else
             raise itemProfValNotFound ;
           end if;
           close itemProfVal ;
       EXCEPTION
         WHEN others THEN
           statusStr := 'FAILURE';
           itemCatErrStr := ' Profile option values combination for profile '  || itemCatProfUser || ' and '|| itemCatSetProfUser || ' not valid.' ;
           itemCatFixInfo := ' Set up valid values for combination of profile '  || itemCatProfUser || ' and '|| itemCatSetProfUser || '.';
           isFatal := 'FALSE';
       END ;
     ELSE
           statusStr := 'FAILURE';
           itemCatErrStr := ' Profile option values should be set for profile '  || itemCatProfUser || ' and '|| itemCatSetProfUser || ' or both should not be set.' ;
           itemCatFixInfo := ' Set up Profile option values for combination of profile '  || itemCatProfUser || ' and '|| itemCatSetProfUser || '.';
           isFatal := 'FALSE';
     END IF;


     if (errStr1 is null and errStr is not null ) then
	errStr1 := errStr ;
     end if ;
     if (fixInfo1 is null and fixInfo is not null ) then
	fixInfo1 := fixInfo ;
     end if ;
     errStr1 := errStr1 || itemCatErrStr ;
     fixInfo1 := fixInfo1 || itemCatFixInfo ;
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr1,fixInfo1,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob ;
   END runTest;

  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Profile setup';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Profile values check';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Check Profiles';
  END getTestName;
END;

/
