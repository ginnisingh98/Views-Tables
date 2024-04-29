--------------------------------------------------------
--  DDL for Package Body BIS_DIAG_SETUP_ENV_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIAG_SETUP_ENV_TEST" AS
/* $Header: BISPDENB.pls 120.0.12000000.1 2007/08/09 09:59:05 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2007 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDENB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Diagnostics Environment Test Package Body                         |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | Date              Developer           Comments                        |
REM | 02-AUG-2007       nbarik              Creation                        |
REM |                                                                       |
REM +=======================================================================+
*/

------------------------------------------------------------
-- procedure to initialize test datastructures
-- executed prior to test run - leave body as null otherwise
------------------------------------------------------------
PROCEDURE init IS
BEGIN
-- test writer could insert special setup code here
  NULL;
END init;
------------------------------------------------------------
-- procedure to cleanup any test datastructures that were setup in the init
-- procedure call executes after test run - leave body as null otherwize
------------------------------------------------------------
PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
  NULL;
END cleanup;
------------------------------------------------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are
-- returned.
-- note the way that support API writes to the report CLOB.
------------------------------------------------------------
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
	report OUT NOCOPY JTF_DIAG_REPORT,
	reportClob OUT NOCOPY CLOB)
IS
  reportStr LONG;
  counter NUMBER;
  dummy_v2t JTF_DIAGNOSTIC_COREAPI.v2t;
  c_userid VARCHAR2(50);
  statusStr VARCHAR2(50);
  errStr VARCHAR2(4000);
  fixInfo VARCHAR2(4000); isFatal VARCHAR2(50);
  dummy_num NUMBER;
  sqltxt VARCHAR2 (2000);
  l_apps_version VARCHAR2(30);
  l_db_version VARCHAR2 (2000);
  l_num_rows NUMBER;
BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
  -- JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
  -- JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('String into report');
  l_apps_version := JTF_DIAGNOSTIC_COREAPI.Get_DB_Apps_Version;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(fnd_message.get_string('BIS', 'BIS_DIAG_APPS_VERSION') || ': ' || l_apps_version);
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_db_version := JTF_DIAGNOSTIC_COREAPI.Get_RDBMS_Header;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(fnd_message.get_string('BIS', 'BIS_DIAG_DB_VERSION') || ': ' || l_db_version);
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_num_rows := JTF_DIAGNOSTIC_COREAPI.Display_SQL('SELECT patch_level FROM fnd_product_installations WHERE patch_level LIKE ''%BIS%''', 'BIS Version', 'Y', 'Y', null, 0);
  l_num_rows := JTF_DIAGNOSTIC_COREAPI.Display_SQL('SELECT decode(bug_number,''5404886'',''DBI 7.3: 11i.BIS_PF.G: 5404886'',''5565583'',''DBI 7.4: 11i.BIS_PF.H: 5565583'',''4458359'',''DBI 8.0: R12.BIS_PF.A: 4458359'') ' ||
                                                                           ' "Current DBI Family Pack level:" FROM ad_bugs WHERE bug_number IN (''5404886'',''5565583'',''4458359'')', 'DBI Version', 'Y', 'Y', null, 0);
  l_num_rows := JTF_DIAGNOSTIC_COREAPI.Display_SQL('SELECT object_name, object_type FROM user_objects WHERE object_name LIKE ''BIS%'' AND status = ''INVALID''', 'Invalid Packages', 'Y', 'Y', null, 0);
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  JTF_DIAGNOSTIC_COREAPI.ActionPrint(fnd_message.get_string('BIS', 'BIS_DIAG_TESTCASE_FIX_INFO'));
  statusStr := 'SUCCESS';
  -- JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('You better do something!');
  errStr := '';
  fixInfo := '';
  isFatal := 'FALSE';
  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;
------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name := fnd_message.get_string('BIS', 'BIS_DIAG_ENVIRONMENTS');
END getComponentName;
------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
  descStr := fnd_message.get_string('BIS', 'BIS_DIAG_ENVIRONMENTS_DESC');
END getTestDesc;
------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name := fnd_message.get_string('BIS', 'BIS_DIAG_ENVIRONMENTS_TEST');
END getTestName;
------------------------------------------------------------
-- procedure to provide the default parameters for the test case.
-- please note the paramters have to be registered through the UI
-- before basic tests can be run.
--
------------------------------------------------------------
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL)
IS
  tempInput JTF_DIAG_INPUTTBL;
BEGIN
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'USERID','SYSADMIN');
  -- tempInput := JTF_DIAGNOSTIC_defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

END BIS_DIAG_SETUP_ENV_TEST;

/
