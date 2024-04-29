--------------------------------------------------------
--  DDL for Package Body BSC_PMA_DIAG_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMA_DIAG_TEST" AS
/* $Header: BSCPHNGB.pls 120.0.12000000.1 2007/08/09 09:54:28 appldev noship $ */
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
      h_module_name BSC_LOOKUPS.MEANING%TYPE;
      h_request_id NUMBER;
    BEGIN
        h_bsc_count := 0;
        h_pmf_count := 0;
        JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;

        JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');

        JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

        h_module_name := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Module Name',inputs);
        BEGIN
          h_request_id := TO_NUMBER(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Concurrent Request ID',inputs));
          IF  h_request_id IS NULL OR h_request_id =0 THEN
             RAISE_APPLICATION_ERROR(-20000,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_INVLD_REQUEST_ID'));
          END IF;
        EXCEPTION
             WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_INVLD_REQUEST_ID'));
        END;
        --CHECK IF THERE ARE ANY AW LOCKS

        SELECT COUNT(1) INTO h_count FROM
        v$aw_olap,all_aws,v$session
        WHERE all_aws.aw_name=bsc_aw_management.get_aw_workspace_name
        AND all_aws.aw_number=v$aw_olap.aw_number
        AND v$session.sid=v$aw_olap.session_id;


        IF h_count >0 THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            JTF_DIAGNOSTIC_COREAPI.actionprint(BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_AW_LOCK_MSG'));

            statusStr := 'FAILURE';
            errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_AW_LOCK_MSG');

            fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_AW_LOCK_MSG');

            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
            isFatal := 'FALSE';
        END IF;

        IF h_module_name = 'METADATA_OPTIMIZER' THEN
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            sqltxt := 'SELECT * FROM bsc_tmp_opt_ui_kpis WHERE  PROCESS_ID=( SELECT TO_NUMBER(argument2) FROM '||
                      ' fnd_concurrent_requests WHERE request_id ='|| h_request_id ||' )' ;

            dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_TMP_OPT_UI_KPIS');

            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            sqltxt := 'SELECT VARIABLE_ID,VALUE_N,VALUE_V FROM BSC_TMP_BIG_IN_COND WHERE VARIABLE_ID = -200 ORDER BY VALUE_N';

            dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_TMP_BIG_IN_COND');

        ELSE
            JTF_DIAGNOSTIC_COREAPI.BRPrint;
            sqltxt := 'SELECT * FROM bsc_db_loader_control WHERE  PROCESS_ID=( SELECT TO_NUMBER(argument1) FROM '||
                      ' fnd_concurrent_requests WHERE request_id ='|| h_request_id ||' )' ;
            dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'BSC_DB_LOADER_CONTROL');

        END IF;

        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        statusStr := 'WARNING';
        errStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_NEED_INVESTIGATION');

        fixInfo := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_GEN_CONC_TRC');
        JTF_DIAGNOSTIC_COREAPI.BRPrint;
        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
        isFatal := 'FALSE';
        report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
        reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
    EXCEPTION
      	WHEN OTHERS THEN
            statusStr := 'FAILURE';
            errStr := SQLERRM;

            fixInfo := SQLERRM;
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
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMA_DIAG_COMPONENT');
    END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
    PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
    BEGIN
        descStr := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMA_DIAG_TDESC');
    END getTestDesc;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
    BEGIN
        name := BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMA_DIAG_TNAME');
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
         tempInput :=
                 JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMA_MODULE_NAME'),'LOV-oracle.apps.bsc.diag.lov.ModuleNameLov');
         tempInput :=
                 JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,BSC_OBJECTIVE_METADATA_SETUP.get_message_name('BSC_PMA_CONC_REQ_ID'),NULL);
         defaultInputValues := tempInput;
     EXCEPTION
         WHEN OTHERS THEN
             defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
     END getDefaultTestParams;

     FUNCTION getTestMode RETURN INTEGER IS
     BEGIN
         RETURN  JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
     END;
END;

/
