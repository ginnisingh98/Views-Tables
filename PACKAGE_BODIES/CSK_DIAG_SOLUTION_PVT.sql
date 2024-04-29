--------------------------------------------------------
--  DDL for Package Body CSK_DIAG_SOLUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSK_DIAG_SOLUTION_PVT" AS
  /* $Header: csktsolb.pls 120.1 2005/06/22 12:33:58 appldev noship $ */

    --CHANGE_PARENT_CATEGORY_TEST
    g_move_solutions_test_c1ID NUMBER;
    g_move_solutions_test_c2ID NUMBER;
    g_move_solutions_test_s1_aID NUMBER;
    g_move_solutions_test_s1_bID NUMBER;
------------------
-- init
------------------
--This procedure does not take any parameters and is always called prior to the
--runTest procedure being executed. In this procedure, implement the code for any
--data structures that need to be set up before the test runs.
--
PROCEDURE init
IS
  l_return_status varchar2(1) := '';
  l_msg_count number := 0;
  l_msg_data varchar2(4000) := '';

  l_P_SET_DEF_REC   CSK_SETUP_UTILITY_PKG.Soln_rec_type;
  l_P_ELE_DEF_TBL   CSK_SETUP_UTILITY_PKG.Stmt_tbl_type;
  l_P_CAT_DEF_TBL   CSK_SETUP_UTILITY_PKG.Cat_tbl_type;
BEGIN
    FND_GLOBAL.APPS_initialize(1000667,21782,170,null,null);
    CSK_SETUP_UTILITY_PKG.validate_seeded_setups(p_api_version => 1.0,
                                                 x_return_status => l_return_status,
                                                 x_msg_count => l_msg_count,
                                                 x_msg_data => l_msg_data);
    --MOVE_SOLUTIONS_TEST
    g_move_solutions_test_c1ID := CSK_SETUP_UTILITY_PKG.get_next_category_id();
    CSK_SETUP_UTILITY_PKG.Create_Category (
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_PARENT_CATEGORY_ID => 1,
        P_CATEGORY_ID        => g_move_solutions_test_c1ID,
        P_CATEGORY_NAME      => 'Move Solutions Test Category c1',
        P_VISIBILITY_ID      => CSK_SETUP_UTILITY_PKG.VISIBILITY_EXTERNAL_API_TEST);

    g_move_solutions_test_c2ID := CSK_SETUP_UTILITY_PKG.get_next_category_id();
    CSK_SETUP_UTILITY_PKG.Create_Category (
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_PARENT_CATEGORY_ID => 1,
        P_CATEGORY_ID        => g_move_solutions_test_c2ID,
        P_CATEGORY_NAME      => 'Move Solutions Test Category c2',
        P_VISIBILITY_ID      => CSK_SETUP_UTILITY_PKG.VISIBILITY_EXTERNAL_API_TEST);


    g_move_solutions_test_s1_aID := CSK_SETUP_UTILITY_PKG.get_next_set_id();
    l_P_SET_DEF_REC.SET_ID :=   g_move_solutions_test_s1_aID;
    l_P_SET_DEF_REC.SET_NUMBER :=   CSK_SETUP_UTILITY_PKG.get_next_set_number();
    l_P_SET_DEF_REC.SET_TYPE_ID :=   CSK_SETUP_UTILITY_PKG.SOLN_TYPE_FAQ_API_TEST;
    l_P_SET_DEF_REC.NAME :=   'Move Solution Test s1_a';
    l_P_SET_DEF_REC.visibility_id :=   CSK_SETUP_UTILITY_PKG.VISIBILITY_EXTERNAL_API_TEST;

    l_P_ELE_DEF_TBL := CSK_SETUP_UTILITY_PKG.Stmt_tbl_type();

    l_P_CAT_DEF_TBL := CSK_SETUP_UTILITY_PKG.Cat_tbl_type();
    l_P_CAT_DEF_TBL.EXTEND;
    l_P_CAT_DEF_TBL(1) := g_move_solutions_test_c1ID;

    CSK_SETUP_UTILITY_PKG.Create_Solution(
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_SOLN_REC => l_P_SET_DEF_REC
        ,P_STMT_TBL => l_P_ELE_DEF_TBL
        ,P_CAT_TBL  => l_P_CAT_DEF_TBL
        ,P_PUBLISH => true );

    g_move_solutions_test_s1_bID := CSK_SETUP_UTILITY_PKG.get_next_set_id();
    l_P_SET_DEF_REC.SET_ID :=   g_move_solutions_test_s1_bID;
    l_P_SET_DEF_REC.NAME :=   'Move Solution Test Solution s1_b';
    CSK_SETUP_UTILITY_PKG.Create_Solution(
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_SOLN_REC => l_P_SET_DEF_REC
        ,P_STMT_TBL => l_P_ELE_DEF_TBL
        ,P_CAT_TBL  => l_P_CAT_DEF_TBL
        ,P_PUBLISH => false );

    commit;
END init;

------------------
-- cleanup
------------------
PROCEDURE cleanup
IS
    l_return_status varchar2(200);
    l_msg_count number;
    l_msg_data  varchar2(200);
begin

    CSK_SETUP_UTILITY_PKG.delete_solution(
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_set_ID        => g_move_solutions_test_s1_aID);
    CSK_SETUP_UTILITY_PKG.delete_solution(
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_set_ID        => g_move_solutions_test_s1_bID);
    CSK_SETUP_UTILITY_PKG.Delete_Category (
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_CATEGORY_ID        => g_move_solutions_test_c1ID);
    CSK_SETUP_UTILITY_PKG.Delete_Category (
        p_api_version        => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        P_CATEGORY_ID        => g_move_solutions_test_c2ID);

    commit;
END cleanup;

------------------
-- getComponentName
------------------
PROCEDURE getComponentName(name  OUT NOCOPY VARCHAR2)
IS
BEGIN
name := 'cs_kb_solution_pvt';
END getComponentName;

------------------
-- getTestName
------------------
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2)
IS
BEGIN
name := 'cs_kb_solution_pvt Test';
END getTestName;

------------------
-- getTestDesc
------------------
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2)
IS
BEGIN
descStr := 'This test will test functions in cs_kb_solution_pvt';
END getTestDesc;

------------------
-- getDefaultTestParams
------------------
-- procedure to provide the default parameters for the test case.
-- please note the paramters have to be registered through the UI
-- before basic tests can be run.
--
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL)
IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
-- If the Unit Test requires Input Parameters the defaults can be set up as follows:
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
--tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'DEMO VALUE','1');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

------------------
-- currentUser
------------------
--
PROCEDURE currentUser
IS
 sqltxt VARCHAR2(2000);
 dummy_num NUMBER;
BEGIN
 -- If you want to display the output of a Simple SQL query it can be achieved as follows:
 sqltxt := ' select fnd_global.user_id, fnd_global.USER_NAME '||
           ' , fnd_global.APPLICATION_SHORT_NAME '||
           ' , fnd_global.APPLICATION_NAME '||
           ' , fnd_global.RESP_NAME '||
           ' from dual ';
 dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Current User Information');
END currentUser;
------------------
-- cascadeDeleteTest
------------------
--
PROCEDURE moveSolutionsTest IS
  l_STATUS   VARCHAR2(2000);
  l_RETURN_STATUS   VARCHAR2(2000);
  l_MSG_DATA   VARCHAR2(2000);
  l_MSG_COUNT   NUMBER;
  l_value NUMBER;
  l_count NUMBER;
  l_count_1 NUMBER;
  l_count_2 NUMBER;
  l_success varchar2(1) := 'N';
  l_soln_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

  l_index_content varchar2(4000) := '';
  l_start_tag number;
  l_end_tag number;
  l_categories_section varchar2(4000) := '';

BEGIN
 JTF_DIAGNOSTIC_COREAPI.line_out('<br><font color=blue> <b> Test Name </b></font> Move Solutions Test  ');
 JTF_DIAGNOSTIC_COREAPI.line_out('<br><font color=blue> <b> Test Ref </b></font>  CS_KB_SOLN_CATEGORIES_PVT_MOVE_SOLUTIONS_TEST');
 -- step 10
    l_soln_ids.EXTEND;
    l_soln_ids(1) := g_move_solutions_test_s1_aID;
    l_soln_ids.EXTEND;
    l_soln_ids(2) := g_move_solutions_test_s1_bID;

   cs_kb_solution_pvt.move_solutions(1.0,
                                     x_return_status => l_RETURN_STATUS,
                                     x_msg_count => l_MSG_COUNT,
                                     x_msg_data => l_MSG_DATA,
                                     p_set_ids => l_soln_ids,
                                     p_src_cat_id => g_move_solutions_test_c1ID,
                                     p_dest_cat_id => g_move_solutions_test_c2ID );
   IF (l_RETURN_STATUS = 'E') THEN
     l_success := 'N';
   ELSE
     l_success := 'Y';
   END IF;

   IF l_success = 'Y' THEN
    JTF_DIAGNOSTIC_COREAPI.line_out('<br><b>' ||'SUCCESS: [ 10] moveSolutions() execution </b>');
        --Step 20
        select count(1) into l_count_1
        from cs_kb_set_categories
        where set_id = g_move_solutions_test_s1_aID and category_id = g_move_solutions_test_c2ID;
        select count(1) into l_count_2
        from cs_kb_set_categories
        where set_id = g_move_solutions_test_s1_bID and category_id = g_move_solutions_test_c2ID;
        if l_count_1 = 1 and l_count_2 = 1 then
            JTF_DIAGNOSTIC_COREAPI.line_out('<br><b>' ||'SUCCESS: [ 20] solutions have been moved into c2</b>');
            --step 30
            select count(1) into l_count_1
            from cs_kb_set_categories
            where set_id = g_move_solutions_test_s1_aID and category_id = g_move_solutions_test_c1ID;
            select count(1) into l_count_2
            from cs_kb_set_categories
            where set_id = g_move_solutions_test_s1_bID and category_id = g_move_solutions_test_c1ID;
            if l_count_1 = 0 and l_count_2 = 0 then
                JTF_DIAGNOSTIC_COREAPI.line_out('<br><b>' ||'SUCCESS: [ 30] solutions have been moved out of c1</b>');
                --step 40
                l_index_content := CSK_SETUP_UTILITY_PKG.Calculate_Set_Index_Content(g_move_solutions_test_s1_aID);
                select INSTR(l_index_content,'</CATEGORIES>') into l_end_tag from dual;
                if (l_end_tag > 0) then
                    select INSTR(l_index_content,'<CATEGORIES>') into l_start_tag from dual;
                    l_categories_section := substr(l_index_content,l_start_tag+12,l_end_tag-l_start_tag-12);
                    select INSTR(l_categories_section,'a'||g_move_solutions_test_c2ID||'a') into l_count from dual;
                    if(l_count > 0) then
                        JTF_DIAGNOSTIC_COREAPI.line_out('<br><b>' ||'SUCCESS: [ 40] text index of child solution updated. </b>');
                    else
                        l_success := 'N';
                        JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<br><b>' ||'FAILED : [ 40] text index of child solution updated. </b>');
                        l_statusStr := 'FAILURE';
                        l_errStr := l_errStr||'<BR> text index of child solution was not updated correctly';
                        l_fixInfo := '.';
                        l_isFatal := 'TRUE';
                    end if;
                else
                    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<br><b>' ||'WARNING: [ 50] Cannot fetch the whole <CATEGORIES> section.</b>');
                end if;
            else
                JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<br><b>' ||'FAILED : [ 30] solutions have been moved out of c1 </b>');
                l_statusStr := 'FAILURE';
                l_errStr := l_errStr||'<BR> solutions have not been moved into c2';
                l_fixInfo := '.';
                l_isFatal := 'TRUE';
            end if;

        else
            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<br><b>' ||'FAILED : [ 20] solutions have been moved into c2 </b>');
            l_statusStr := 'FAILURE';
            l_errStr := l_errStr||'<BR> solutions have not been moved into c2';
            l_fixInfo := '.';
            l_isFatal := 'TRUE';
        end if;
   ELSE
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<br><b>' ||'FAILED : [ 10] moveSolutions() execution </b>');
    l_statusStr := 'FAILURE';
    l_errStr := l_errStr||'<BR> moveSolutions() execution failed';
    l_fixInfo := '.';
    l_isFatal := 'TRUE';
   END IF;
END moveSolutionsTest;
------------------
-- runtest
------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are
-- returned.
PROCEDURE runtest(inputs     IN  JTF_DIAG_INPUTTBL,
                  report     OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB)
IS
BEGIN
 -- The Report for the Unit Test is represented by a CLOB
 -- This CLOB must be initialized before it can be used
 JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
 -- if the report is HTML-based, then the first string added to
 -- the report must be "@html".
 -- addStringToReport writes to the Report CLOB
 JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
 JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
 -- line_out writes to the Report CLOB
 JTF_DIAGNOSTIC_COREAPI.line_out('======================================================');
 -- BRPrint Adds a New Line to the Report CLOB
 JTF_DIAGNOSTIC_COREAPI.BRPrint;
 JTF_DIAGNOSTIC_COREAPI.line_out('=== Knowledge Management Diagnostics - cs_kb_solution_pvt');
 JTF_DIAGNOSTIC_COREAPI.BRPrint;
 JTF_DIAGNOSTIC_COREAPI.line_out('======================================================');
 l_statusStr := 'SUCCESS';
 ----------------------------------------------
 -- Add Product Specific Tests Here:
 ----------------------------------------------
 currentUser;
 moveSolutionsTest;
 ----------------------------------------------
-- Construct the Report with the corresponding Report Status information:
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(l_statusStr, -- SUCCESS, FAILURE, WARNING
                                                    l_errStr,    -- The Error Message
                                                    l_fixInfo,   -- fix suggestions
                                                    l_isFatal    -- Fatal Error: "TRUE" or "FALSE"
                                                    );
 -- Return the clob output report
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

END CSK_DIAG_SOLUTION_PVT;

/
