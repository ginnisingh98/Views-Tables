--------------------------------------------------------
--  DDL for Package Body BSC_CORRUPT_OBJECTS_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CORRUPT_OBJECTS_RPT" AS
/* $Header: BSCCOBJB.pls 120.1.12000000.1 2007/08/09 09:54:37 appldev noship $ */

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
      h_count NUMBER;

    BEGIN
        JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;

        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');

        JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

        JTF_DIAGNOSTIC_COREAPI.BRPrint;

        JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_CHK'));

        h_count := 0;

        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_measure_sql1,'BIS_INDICATORS<>BSC_SYS_DATASETS_B');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_measure_sql2,'BSC_SYS_DATASETS_B<>BIS_INDICATORS');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_measure_sql3,'BSC_DB_MEASURE_COLS_VL<>BSC_SYS_MEASURES');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_per_sql,'BSC_SYS_PERIODICITIES_VL<>BSC_SYS_DIM_LEVELS_VL');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_cal_sql,'BSC_SYS_CALENDARS_VL<>BSC_SYS_DIM_GROUPS_VL');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_rpt_sql,'BSC_KPIS_B<>AK_REGIONS');
        h_count:= h_count+JTF_DIAGNOSTIC_COREAPI.display_sql(g_dang_tab_sql,'BSC_TABS_VL<>AK_REGIONS');


        IF h_count >0 THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_FOUND');
            statusStr := 'WARNING';
            fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_DANGLING_OBJ_FIX');
            isFatal := 'FALSE';
            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
            report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
            reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
            RETURN ;
        END IF;
        statusStr := 'SUCCESS';
        isFatal := 'FALSE';
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_NO_DANG_RECS'));
        report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
        reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
    END runTest;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
    PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_GEN_HEALTH_CHECK');
    END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
    PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
    BEGIN
        descStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_CORRUPT_OBJ_TDESC');
    END getTestDesc;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_CORRUPT_OBJ_TNAME');
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
