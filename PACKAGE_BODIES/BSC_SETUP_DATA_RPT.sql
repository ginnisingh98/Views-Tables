--------------------------------------------------------
--  DDL for Package Body BSC_SETUP_DATA_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SETUP_DATA_RPT" AS
/* $Header: BSCSTPAB.pls 120.4.12000000.2 2007/08/10 06:06:58 amitgupt noship $ */

------------------------------------------------------------
-- procedure to initialize test datastructures
------------------------------------------------------------
    PROCEDURE init IS
    BEGIN
        -- test writer could insert special setup code here
        NULL;
    END init;
------------------------------------------------------------
-- procedure to cleanup any test datastructures that were setup in the init

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
                      reportClob OUT NOCOPY CLOB) IS
      reportStr LONG;
      counter NUMBER;
      dummy_v2t JTF_DIAGNOSTIC_COREAPI.v2t;
      c_userid VARCHAR2(50);
      statusStr VARCHAR2(50);
      errStr VARCHAR2(4000);
      fixInfo VARCHAR2(4000);
      isFatal VARCHAR2(50);
      dummy_num NUMBER;
      sqltxt VARCHAR2 (2000);
      h_db_version v$version.banner%TYPE;
      h_Apps_version VARCHAR2(100);
      l_status              VARCHAR2(1);
      l_industry            VARCHAR2(1);
      l_oracle_schema       VARCHAR2(30);
      l_return              BOOLEAN;
    BEGIN
        l_return := FND_INSTALLATION.get_app_info
	                    ( application_short_name  => 'BSC'
	                    , status                  => l_status
	                    , industry                => l_industry
	                    , oracle_schema           => l_oracle_schema
                    );
        JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;

        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');

        JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(g_patch_level_sql,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PRODUCT_LEVEL'));
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.LINE_OUT(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_APPS_VERSION')||JTF_DIAGNOSTIC_COREAPI.Get_DB_Apps_versioN);
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.LINE_OUT(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_DB_VERSION')||JTF_DIAGNOSTIC_COREAPI.Get_RDBMS_Header);
        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        sqltxt := 'SELECT a.SESSION_ID,b.serial#,b.status,c.object_name,a.ORACLE_USERNAME,'||
                  ' a.OS_USER_NAME,a.PROCESS FROM v$locked_object a, v$session b, all_objects c '||
                  ' WHERE c.OBJECT_NAME LIKE ''BSC%'' AND c.OBJECT_ID=a.OBJECT_ID AND b.sid=a.SESSION_ID'||
                  ' AND c.OWNER = '''|| l_oracle_schema||'''';

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_OBJECT_LOCKS');

        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        sqltxt := 'SELECT * FROM BSC_CURRENT_SESSIONS';

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_CURRENT_SESSIONS');

        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.display_profiles(271);
        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        sqltxt := 'SELECT * FROM bsc_sys_init ';

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_SYS_INIT');

        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        sqltxt := 'SELECT * FROM BSC_MESSAGE_LOGS ';

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_MESSAGE_LOGS');

        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        statusStr := 'SUCCESS';

        JTF_DIAGNOSTIC_COREAPI.WarningPrint(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_REPORT_OUTPUT'));

        report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
        reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
    END runTest;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
    PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_SETUP_TEST_COMPONENT');
    END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
    PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
    BEGIN
        descStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_SETUP_DATA_TDESC');
    END getTestDesc;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_SETUP_DATA_TNAME');
    END getTestName;

------------------------------------------------------------
-- procedure to provide the default parameters for the test case.
-- please note the paramters have to be registered through the UI
-- before basic tests can be run.
--
------------------------------------------------------------
     PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
         tempInput JTF_DIAG_INPUTTBL;
     BEGIN
         tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
--         tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'USERID',NULL);
         -- tempInput := JTF_DIAGNOSTIC_
         defaultInputValues := tempInput;
     EXCEPTION
         WHEN OTHERS THEN
             defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
     END getDefaultTestParams;

     FUNCTION getTestMode RETURN INTEGER IS
     BEGIN
         RETURN  JTF_DIAGNOSTIC_ADAPTUTIL.BASIC_MODE;
     END;
END;

/
