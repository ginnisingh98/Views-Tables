--------------------------------------------------------
--  DDL for Package Body BSC_TIME_DIM_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TIME_DIM_TEST" AS
/* $Header: BSCTIMDB.pls 120.2.12000000.1 2007/08/09 09:54:40 appldev noship $ */

FUNCTION check_dangling_records RETURN BOOLEAN;
PROCEDURE correct_dangling_records;
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
      h_module_name BSC_LOOKUPS.MEANING%TYPE;
      h_fii_cnt NUMBER;
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

        --Check FII tables first, if there is any data
        SELECT COUNT(1) INTO h_fii_cnt FROM FII_TIME_DAY;
        JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_FII_DATA_CHK'));

        IF h_fii_cnt = 0 THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;

            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_FII_NO_DATA');

            JTF_DIAGNOSTIC_COREAPI.actionerrorprint(errStr);

            statusStr := 'FAILURE';

            fixInfo := errStr;

            isFatal := 'FALSE';
        END IF;
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_CHK'));

        IF check_dangling_records THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_CORRECT'));
            correct_dangling_records;
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_FOUND');
            statusStr := 'FAILURE';
            fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PER_DANG_FIX');
            isFatal := 'FALSE';
            report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
            reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
            RETURN ;
        END IF;
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIME_DIM_INDEX'));

        SELECT COUNT(1) INTO h_count FROM all_indexes
        WHERE index_name = 'BSC_DB_CALENDAR_U1'
        AND OWNER = l_oracle_schema;

        IF h_count > 0 THEN
            JTF_DIAGNOSTIC_COREAPI.Line_out(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIMED_IND_FOUND'));
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIMED_IND_FOUND');
            statusStr := 'FAILURE';
            fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIMED_IND_FIX');
            isFatal := 'FALSE';
            report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
            reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
            RETURN ;
        END IF;

        sqltxt := 'SELECT start_month||''/''||start_day||''/''||current_year "START_DATE",edw_calendar_id FROM'||
                   ' bsc_sys_calendars_b WHERE edw_calendar_type_id=1 AND edw_calendar_id IN (1001,1002,1003)';
        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_DBI_CAL_METADATA'));

        statusStr := 'WARNING';
        errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_NEED_INVESTIGATION');

        fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIMED_DATA_UPLOAD');
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
        isFatal := 'FALSE';
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
        descStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIME_DIM_TDESC');
    END getTestDesc;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_TIME_DIM_TNAME');
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

     PROCEDURE correct_dangling_records IS
     BEGIN
        DELETE bsc_sys_periods_tl WHERE periodicity_id NOT IN
        (SELECT periodicity_id  FROM bsc_sys_periodicities);

        DELETE bsc_sys_periods WHERE periodicity_id NOT IN
        (SELECT periodicity_id  FROM bsc_sys_periodicities);

        DELETE bsc_sys_periodicities WHERE calendar_id NOT IN
        (SELECT calendar_id FROM bsc_sys_calendars_b);
     END;

     FUNCTION check_dangling_records RETURN BOOLEAN IS
        h_count NUMBER;
        h_dangling_true BOOLEAN;
     BEGIN
        h_dangling_true := FALSE;
        SELECT COUNT(1) INTO h_count from bsc_sys_periods_tl WHERE periodicity_id NOT IN
        (SELECT periodicity_id  FROM bsc_sys_periodicities);

        IF h_count > 0 THEN
            h_dangling_true := TRUE;
        END IF;

        SELECT COUNT(1) INTO h_count from bsc_sys_periods WHERE periodicity_id NOT IN
        (SELECT periodicity_id  FROM bsc_sys_periodicities);

        IF h_count > 0 THEN
            h_dangling_true := TRUE;
        END IF;

        SELECT COUNT(1) INTO h_count from bsc_sys_periodicities WHERE calendar_id NOT IN
        (SELECT calendar_id FROM bsc_sys_calendars_b);

        IF h_count > 0 THEN
            h_dangling_true := TRUE;
        END IF;

        RETURN h_dangling_true;
     END;
END;

/
