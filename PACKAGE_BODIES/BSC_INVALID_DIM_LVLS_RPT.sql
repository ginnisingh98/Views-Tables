--------------------------------------------------------
--  DDL for Package Body BSC_INVALID_DIM_LVLS_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_INVALID_DIM_LVLS_RPT" AS
/* $Header: BSCIVLDB.pls 120.1.12000000.2 2007/08/10 06:08:15 amitgupt noship $ */

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
      h_headers JTF_DIAGNOSTIC_COREAPI.headers;
      h_lengths JTF_DIAGNOSTIC_COREAPI.lengths;
      h_count NUMBER;
      h_source bsc_sys_dim_levels_b.source%TYPE;
      h_pmf_count NUMBER;
      h_bsc_count NUMBER;
      CURSOR cv IS
        SELECT source,COUNT(short_name) FROM bsc_sys_dim_levels_vl
        WHERE table_type = 1 AND EXISTS (SELECT 1 FROM user_objects WHERE status='INVALID' AND
        object_name = level_table_name)
        GROUP BY source;
    BEGIN
        h_bsc_count := 0;
        h_pmf_count := 0;
        JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;

        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');

        JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

        IF cv%ISOPEN THEN
          CLOSE cv;
        END IF;

        --CHECK IF THERE ARE INVALID DIMENSION OBJECTS IN BSC

        OPEN cv;
        LOOP
            FETCH cv INTO h_source,h_count;
            EXIT WHEN cv%NOTFOUND;
            IF h_source = 'PMF' THEN
                h_pmf_count := h_count;
            ELSIF h_source = 'BSC' THEN
                h_bsc_count := h_count;
            END IF;
        END LOOP;
        CLOSE cv;


        h_count := h_pmf_count + h_bsc_count;
        IF h_count >0 THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            sqltxt := 'SELECT Name "Dimension Object Name", short_name, SOURCE, LEVEL_TABLE_NAME, '||
                      ' LEVEL_VIEW_NAME FROM bsc_sys_dim_levels_vl '||
                      ' WHERE TABLE_TYPE = 1 AND EXISTS (SELECT 1 FROM user_objects '||
                      ' WHERE status=''INVALID'' AND object_name = LEVEL_VIEW_NAME) ';

            dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_INVALID_DIM_LVLS'));
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            statusStr := 'FAILURE';
            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_INVALID_DIM_LVLS_F');
            IF h_pmf_count >0 THEN
               fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMF_DIM_LVLS_FIX');
            END IF;
            fixInfo := fixInfo || BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_BSC_DIM_LVLS_FIX');

            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
            isFatal := 'FALSE';
        ELSE
            statusStr := 'SUCCESS';
            reportStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_NO_INVLD_VIEWS');
            JTF_DIAGNOSTIC_COREAPI.Line_out(reportStr);
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
        END IF;
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
        descStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_DIM_VIEW_TDESC');
    END getTestDesc;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_DIM_VIEW_TNAME');
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
