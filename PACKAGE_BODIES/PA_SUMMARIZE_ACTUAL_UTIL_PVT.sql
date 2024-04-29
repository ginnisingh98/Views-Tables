--------------------------------------------------------
--  DDL for Package Body PA_SUMMARIZE_ACTUAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SUMMARIZE_ACTUAL_UTIL_PVT" AS
/* $Header: PARRACVB.pls 120.0 2005/06/03 13:52:29 appldev noship $ */

  /*
   * The contents of the global variables - used throughout this
   * package are stored in local variables - so that we dont
   * hit the global package each time.
   */
  l_bal_type_actual VARCHAR2(15) := pa_rep_util_glob.G_BAL_TYPE_C.G_ACTUALS_C;
  /*
   * Input Parameters.
   */
  l_ac_start_date   DATE := pa_rep_util_glob.G_input_parameters.G_ac_start_date;
  l_ac_end_date     DATE := pa_rep_util_glob.G_input_parameters.G_ac_end_date;
  /*
   * Utilization Option details.
   */
  l_actuals_thru_date pa_utilization_options.actuals_thru_date%TYPE := pa_rep_util_glob.G_util_option_details.G_actuals_thru_date;
  l_pa_period_flag pa_utilization_options.pa_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_pa_period_flag;
  l_gl_period_flag pa_utilization_options.gl_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_gl_period_flag;
  l_ge_period_flag pa_utilization_options.global_exp_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_ge_period_flag;
  /*
   * Implementation.
   */
  l_org_id pa_implementations.org_id%TYPE := pa_rep_util_glob.G_implementation_details.G_org_id;
  /*
   * Profile Options.
   */
  l_global_week_start_day PLS_INTEGER := pa_rep_util_glob.G_global_week_start_day;
  l_fetch_size            PLS_INTEGER := pa_rep_util_glob.G_util_fetch_size;

  /*
   * Period Information.
   */
--  l_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_period_set_name;
  l_gl_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_gl_period_set_name;  -- bug 3434019
  l_pa_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_pa_period_set_name;  -- bug 3434019
  l_pa_period_type pa_implementations.pa_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_pa_period_type;
  l_gl_period_type gl_sets_of_books.accounted_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_gl_period_type;
  /*
   * Who Columns.
   */
  l_created_by    NUMBER(15) := pa_rep_util_glob.G_who_columns.G_created_by;
  l_request_id    NUMBER(15) := pa_rep_util_glob.G_who_columns.G_request_id;
  l_program_id    NUMBER(15) := pa_rep_util_glob.G_who_columns.G_program_id;
  l_program_application_id NUMBER(15) := pa_rep_util_glob.G_who_columns.G_program_application_id;
  l_creation_date        DATE := pa_rep_util_glob.G_who_columns.G_creation_date;
  l_program_update_date  DATE := pa_rep_util_glob.G_who_columns.G_last_update_date;
  l_debug     varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

-------------------------------------------------------

  PROCEDURE insert_act_into_tmp_table
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'insert_act_into_tmp_table');

    IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
      PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;


    --
    -- Coded as a performance fix by mpuvathi
    -- Starts here
    --

    INSERT
    INTO pa_rep_util_summ0_tmp
    ( row_id
    , parent_row_id
    , expenditure_organization_id
    , person_id
    , assignment_id
    , work_type_id
    , org_util_category_id
    , res_util_category_id
    , expenditure_type
    , expenditure_type_class
    , pa_period_name
    , pa_period_num
    , pa_period_year
    , pa_quarter_number
    , gl_period_name
    , gl_period_num
    , gl_period_year
    , gl_quarter_number
    , global_exp_period_end_date
    , global_exp_year
    , global_exp_month_number
    , total_hours
    , total_prov_hours
    , total_wghted_hours_people
    , total_wghted_hours_org
    , prov_wghted_hours_people
    , prov_wghted_hours_org
    , reduce_capacity
    , delete_flag               )
    SELECT
      row_id
    , parent_row_id
    , expenditure_organization_id
    , person_id
    , assignment_id
    , work_type_id
    , org_util_category_id
    , res_util_category_id
    , expenditure_type
    , expenditure_type_class
    , pa_period_name
    , pa_period_num
    , pa_period_year
    , pa_quarter_number
    , gl_period_name
    , gl_period_num
    , gl_period_year
    , gl_quarter_number
    , global_exp_period_end_date
    , global_exp_year
    , global_exp_month_number
    , total_hours
    , total_prov_hours
    , total_wghted_hours_people
    , total_wghted_hours_org
    , prov_wghted_hours_people
    , prov_wghted_hours_org
    , reduce_capacity
    , delete_flag
    FROM pa_rep_util_summ00_tmp
    WHERE rownum <= l_fetch_size;

    --
    -- Coded as a performance fix by mpuvathi
    -- Ends here
    --


    IF l_debug ='Y'THEN -- bug 2674619
     PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
   END IF;
    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END insert_act_into_tmp_table;
-------------------------------------------------------

  PROCEDURE summarize_actual_util
  IS
    l_cdl_rowid_tab       PA_PLSQL_DATATYPES.RowidTabTyp;
    l_process_method      VARCHAR2(1) := 'A';
    l_records_inserted    PLS_INTEGER;
    l_records_updated     PLS_INTEGER;
    l_capacity_summarized NUMBER :=0;
  BEGIN

    PA_DEBUG.Set_Curr_Function( p_function => 'Summarize_Actual_Util');

    IF (l_pa_period_flag = 'N') AND
       (l_gl_period_flag = 'N') AND
       (l_ge_period_flag = 'N') THEN
      /*
       * None of the options are selected
       */
        PA_DEBUG.Reset_Curr_Function;
        RETURN;
    END IF;

    IF l_debug ='Y'THEN -- bug 2674619
     PA_DEBUG.g_err_stage := '10 : L_AC_START_DATE '||l_ac_start_date;
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     PA_DEBUG.g_err_stage := '20 : L_AC_END_DATE '||l_ac_end_date;
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);

     PA_DEBUG.g_err_stage := '100 : After checking the flags ';
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     PA_DEBUG.g_err_stage := '110 : L_PA_PERIOD_FLAG '||l_pa_period_flag;
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     PA_DEBUG.g_err_stage := '120 : L_GL_PERIOD_FLAG '||l_gl_period_flag;
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     PA_DEBUG.g_err_stage := '130 : L_GE_PERIOD_FLAG '||l_ge_period_flag;
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Calling a procedure for populating the initial temporary workspace
     * Starts Here
     */
      IF (l_pa_period_flag = 'Y') THEN
        IF (l_gl_period_flag = 'Y') THEN
          IF (l_ge_period_flag = 'Y') THEN
            IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '140 : Calling PAGLGE';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
            END IF;
            insert_act_into_tmp_PAGLGE;
          ELSE
           IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '150 : Calling PAGL';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
           END IF;
            insert_act_into_tmp_PAGL;
          END IF;
        ELSIF (l_ge_period_flag = 'Y') THEN
           IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '160 : Calling PAGE';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
           END IF;
          insert_act_into_tmp_PAGE;
        ELSE
          insert_act_into_tmp_PA;
            IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '170 : Calling PA';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
            END IF;
        END IF;
      ELSIF (l_gl_period_flag = 'Y') THEN
        IF (l_ge_period_flag = 'Y') THEN
           IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '180 : Calling GLGE';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
           END IF;
          insert_act_into_tmp_GLGE;
        ELSE
           IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '190 : Calling GL';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
           END IF;
          insert_act_into_tmp_GL;
        END IF;
      ELSE
            IF l_debug ='Y'THEN -- bug 2674619
             PA_DEBUG.g_err_stage := '200 : Calling GE';
             PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
            END IF;
        insert_act_into_tmp_GE;
      END IF;
    /*
     * Calling a procedure for populating the temporary workspace
     * Ends Here
     */


    /*
     * Main Un-conditional Loop.
     * Exits if No more records to process (SQL%ROWCOUNT = 0)
     */
    LOOP

      /*
       * Transfer the data from the initial staging area to the current
       * processing set.
       */

      insert_act_into_tmp_table;

      /*
       * Check if ANY records have been inserted into the temporary table.
       * If NO records are inserted, getout of the loop.
       */
      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '220 : After Calling the INSERT_PROC_[PA][GL][GE]';
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      l_records_inserted := SQL%ROWCOUNT;

      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '225 : Records Inserted in Temp tab : '||l_records_inserted;
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);

        PA_DEBUG.G_Err_Stage := '753 : l_capacity_summarized: ' || l_capacity_summarized;
        PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
     END IF;

      IF (l_records_inserted = 0 AND l_capacity_summarized = 1) THEN
       IF l_debug ='Y'THEN -- bug 2674619
          PA_DEBUG.G_Err_Stage := '757 : EXITING since l_records_inserted = 0 AND l_capacity_summarized = 1';
          PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
       END IF;
        EXIT;
      END IF;

      /*
       * Update CDL with util_summarized_flag = 'S' with the
       * rowids available in the temp0 table.
       * The local rowid plsql table collects all the rowids
       * for which updation went thro' fine.
       */

      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '250 : Before Updating PA_CDL to UTIL_SUMM_FLAG to S';
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      UPDATE pa_cost_distribution_lines_all
         SET util_summarized_flag = 'S'
       WHERE util_summarized_flag = 'N' AND
         NVL(org_id,-99) = l_org_id
         AND ROWID IN (
                        SELECT row_id
                          FROM pa_rep_util_summ0_tmp
                      )
      RETURNING ROWID BULK COLLECT INTO l_cdl_rowid_tab;

      l_records_updated := SQL%ROWCOUNT;
      /*
       * Check if the all records (in CDL) corresponding to the
       * records in temp0 have been updated with util_summarized_flag = NULL
       * if YES, process_method = 'A' ( ALL) ELSE process_method = 'F'
       * (FILTER - based on the PA_REP_UTIL_SUMM0_TMP.delete_flag).
       *
       * The delete flag in pa_rep_util_summ0_tmp is initialized
       * to 'Y' when inserted. But if updation of util_summarized_flag = 'S'
       * goes through fine for those records, then those records
       * are updated to delete_flag = 'N' - meaning that, those
       * records SHOULD processed and hence to be considered as
       * NOT deleted.
       */
      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '300 : After Updating PA_CDL to UTIL_SUMM_FLAG to S';
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '325 : Records Updated in  PA_CDL : '||l_records_updated;
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      l_process_method := 'A';
      IF (l_records_updated < l_records_inserted AND l_cdl_rowid_tab.COUNT > 0 ) THEN /* Added second condition 2084888 */
        l_process_method := 'F';
        FORALL i IN l_cdl_rowid_tab.FIRST .. l_cdl_rowid_tab.LAST
          UPDATE pa_rep_util_summ0_tmp tmp1
             SET tmp1.delete_flag = 'N'
           WHERE tmp1.row_id = l_cdl_rowid_tab(i);
      END IF;
      /*
       * Delete the rowid plsql table.
       */
      l_cdl_rowid_tab.DELETE;

      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '350: Process Method : '||l_process_method;
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      /*
       * Call Package PA_REP_UTILS_SUMM_PKG.populate_summ_entity to Summarize
         Records and Populate the Objects and Balances
       */
      IF l_debug ='Y'THEN -- bug 2674619
       PA_DEBUG.g_err_stage := '400: Before calling PA_REP_UTILS_SUMM_PKG';
       PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      PA_REP_UTILS_SUMM_PKG.populate_summ_entity( P_Balance_Type_Code => l_bal_type_actual
                                                 ,P_process_method    => l_process_method
                                                );
      l_capacity_summarized :=1;
      /*
       * If the process_method is 'F' (Filter), update only those records
       * in cdl with util_summarized_flag = NULL which got successfully
       * updated to 'S' (delte_flag in temp0 is 'N.
       * If process_method is 'A' (All), update all records in cdl with
       * util_summarized_flag = 'S' to NULL.
       */
      IF l_debug ='Y'THEN -- bug 2674619
       PA_DEBUG.g_err_stage := '450: After calling PA_REP_UTILS_SUMM_PKG';
       PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      IF l_process_method = 'F' THEN
        UPDATE pa_cost_distribution_lines_all
--           SET util_summarized_flag = 'Y'
           SET util_summarized_flag = NULL
              ,request_id    = l_request_id
              ,program_application_id = l_program_application_id
              ,program_id = l_program_id
              ,program_update_date = l_program_update_date
         WHERE util_summarized_flag = 'S' -- Do we require this?
           AND NVL(org_id,-99) = l_org_id -- Do we require this?
           AND ROWID IN ( SELECT row_id
                           FROM pa_rep_util_summ0_tmp
                          WHERE delete_flag = 'N'
                       );
      ELSIF l_process_method = 'A' THEN
        UPDATE pa_cost_distribution_lines_all
--           SET util_summarized_flag = 'Y'
             SET util_summarized_flag = NULL
              ,request_id    = l_request_id
              ,program_application_id = l_program_application_id
              ,program_id = l_program_id
              ,program_update_date = l_program_update_date
         WHERE util_summarized_flag = 'S' -- Do we require this?
           AND NVL(org_id,-99) = l_org_id -- Do we require this?
           AND ROWID IN ( SELECT row_id
                           FROM pa_rep_util_summ0_tmp
                        );
      END IF;

     /*
      * delete the processed data from the intitial temporary workspace
      */

      DELETE FROM pa_rep_util_summ00_tmp
      WHERE row_id IN (SELECT row_id FROM pa_rep_util_summ0_tmp);


      IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.g_err_stage := '500: After updating PA_CDL.UTIL_SUMM_FLAG to Y';
        PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;

      COMMIT;
    END LOOP;
    IF pa_rep_util_glob.G_input_parameters.G_org_rollup_method = 'R' THEN

     IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '510: Before calling Rollup if rollup method is R';
      PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     END IF;

      PA_SUMMARIZE_ORG_ROLLUP_PVT.refresh_org_hierarchy_rollup(l_bal_type_actual);

     IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '520: After  calling Org Hierarchy Rollup';
      PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
     END IF;
    END IF;


   IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '550: Before updating PA_UTILIZATION_OPTIONS_ALL';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
  END IF;

    /*
     * Update pa_utilization_options with the dates for which
     * Balances exist.
     */
    /*
     * Bug 1628557
     * Put the code for update outside of the if loop so that the thru date
     *  is updated with the end date of the current run (it would no longer
	 *  reflect the furthest out date till which summarization was ever run,
     *  as was the case earlier)
     * IF NVL(l_actuals_thru_date, l_ac_end_date -1) < l_ac_end_date THEN
     * code for update
     * END IF;
     */
      UPDATE pa_utilization_options_all
         SET actuals_thru_date = l_ac_end_date
             , actuals_last_run_date = sysdate
       WHERE NVL(org_id,-99) = l_org_id;

      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '600: After  updating PA_UTILIZATION_OPTIONS_ALL';
      PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      PA_DEBUG.g_err_stage := '700: Exiting the Package PA_SUMMARIZE_ACTUAL_UTIL_PVT';
      PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
      END IF;
      PA_DEBUG.Reset_Curr_Function;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
       IF l_debug ='Y'THEN -- bug 2674619
        PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
        PA_DEBUG.Log_Message( SQLERRM);
       END IF;
      RAISE;

  END summarize_actual_util;

-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_PA
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_PA');
    IF l_debug ='Y'THEN -- bug 2674619
     PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
     PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
   END IF;

    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,(pglp.period_year*10000 + pglp.period_num)                           pa_period_number
      ,pglp.period_name                                                     pa_period_name
      ,pglp.quarter_num                                                     pa_qtr_num
      ,pglp.period_year                                                     pa_period_year
      ,NULL                                                                 gl_period_number
      ,NULL                                                                 gl_period_name
      ,NULL                                                                 gl_qtr_num
      ,NULL                                                                 gl_period_year
      ,NULL                                                                 ge_end_date
      ,NULL                                                                 ge_month_number
      ,NULL                                                                 ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
        ,gl_periods                      pglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND pglp.period_set_name = l_period_set_name
    AND pglp.period_set_name = l_pa_period_set_name  -- bug 3434019
    AND pglp.period_name = cdl.pa_period_name
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999  /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id     --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    commit;
   IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
   END IF;

    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

  END insert_act_into_tmp_PA;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_GL
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_GL');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id  --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,NULL                                                                 pa_period_number
      ,NULL                                                                 pa_period_name
      ,NULL                                                                 pa_qtr_num
      ,NULL                                                                 pa_period_year
      ,(gglp.period_year*10000 + gglp.period_num)                                gl_period_number
      ,gglp.period_name                                                     gl_period_name
      ,gglp.quarter_num                                                     gl_qtr_num
      ,gglp.period_year                                                     gl_period_year
      ,NULL                                                                 ge_end_date
      ,NULL                                                                 ge_month_number
      ,NULL                                                                 ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
        ,gl_periods                      gglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND gglp.period_set_name = l_period_set_name
    AND gglp.period_set_name = l_gl_period_set_name  -- bug 3434019
    AND gglp.period_name = cdl.gl_period_name
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999   /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id  --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

  END insert_act_into_tmp_GL;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_PAGL
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_PAGL');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id   --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,(pglp.period_year*10000 + pglp.period_num)                           pa_period_number
      ,pglp.period_name                                                     pa_period_name
      ,pglp.quarter_num                                                     pa_qtr_num
      ,pglp.period_year                                                     pa_period_year
      ,(gglp.period_year*10000 + gglp.period_num)                           gl_period_number
      ,gglp.period_name                                                     gl_period_name
      ,gglp.quarter_num                                                     gl_qtr_num
      ,gglp.period_year                                                     gl_period_year
      ,NULL                                                                 ge_end_date
      ,NULL                                                                 ge_month_number
      ,NULL                                                                 ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         gl_periods                      pglp
        ,gl_periods                      gglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
        ,pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND pglp.period_set_name = l_period_set_name
    AND pglp.period_set_name = l_pa_period_set_name -- bug 3434019
    AND pglp.period_name = cdl.pa_period_name
--  AND gglp.period_set_name = l_period_set_name
    AND gglp.period_set_name = l_gl_period_set_name -- bug 3434019
    AND gglp.period_name = cdl.gl_period_name
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999   /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id  --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END insert_act_into_tmp_PAGL;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_PAGE
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_PAGE');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id  --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,(pglp.period_year*10000 + pglp.period_num)                           pa_period_number
      ,pglp.period_name                                                     pa_period_name
      ,pglp.quarter_num                                                     pa_qtr_num
      ,pglp.period_year                                                     pa_period_year
      ,NULL                                                                 gl_period_number
      ,NULL                                                                 gl_period_name
      ,NULL                                                                 gl_qtr_num
      ,NULL                                                                 gl_period_year
      ,TRUNC(NEXT_DAY(ei.expenditure_item_date,
                 l_global_week_start_day) - 1)                              ge_end_date
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'MM'))                                      ge_month_number
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'YYYY'))                                    ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
        ,gl_periods                      pglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND pglp.period_set_name = l_period_set_name
    AND pglp.period_set_name = l_pa_period_set_name -- bug 3434019
    AND pglp.period_name = cdl.pa_period_name
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999    /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id  --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END insert_act_into_tmp_PAGE;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_GE
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_GE') ;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,NULL                                                                 pa_period_number
      ,NULL                                                                 pa_period_name
      ,NULL                                                                 pa_qtr_num
      ,NULL                                                                 pa_period_year
      ,NULL                                                                 gl_period_number
      ,NULL                                                                 gl_period_name
      ,NULL                                                                 gl_qtr_num
      ,NULL                                                                 gl_period_year
      ,TRUNC(NEXT_DAY(ei.expenditure_item_date,
                 l_global_week_start_day) - 1)                              ge_end_date
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'MM'))                                      ge_month_number
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'YYYY'))                                    ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         pa_work_types_b                 wt
        ,pa_resources_denorm             res
        ,pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(exp.org_id, -99)
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999      /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id    --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END insert_act_into_tmp_GE;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_PAGLGE
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_PAGLGE');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id  --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,(pglp.period_year*10000 + pglp.period_num)                           pa_period_number
      ,pglp.period_name                                                     pa_period_name
      ,pglp.quarter_num                                                     pa_qtr_num
      ,pglp.period_year                                                     pa_period_year
      ,(gglp.period_year*10000 + gglp.period_num)                           gl_period_number
      ,gglp.period_name                                                     gl_period_name
      ,gglp.quarter_num                                                     gl_qtr_num
      ,gglp.period_year                                                     gl_period_year
      ,TRUNC(NEXT_DAY(ei.expenditure_item_date,
                 l_global_week_start_day) - 1)                              ge_end_date
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'MM'))                                      ge_month_number
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'YYYY'))                                    ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         gl_periods                      pglp
        ,gl_periods                      gglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
        ,pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND pglp.period_set_name = l_period_set_name
    AND pglp.period_set_name = l_pa_period_set_name -- bug 3434019
    AND pglp.period_name = cdl.pa_period_name
--    AND gglp.period_set_name = l_period_set_name
    AND gglp.period_set_name = l_gl_period_set_name -- bug 3434019
    AND gglp.period_name = cdl.gl_period_name
    AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999      /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id    --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END insert_act_into_tmp_PAGLGE;
-------------------------------------------------------
  PROCEDURE insert_act_into_tmp_GLGE
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'Insert_act_into_tmp_GLGE');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '205: Before inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;
    INSERT
      INTO pa_rep_util_summ00_tmp(
                  Row_id
                 ,Parent_Row_Id
                 ,Expenditure_Organization_Id
                 ,Person_Id
                 ,Assignment_Id
                 ,Work_Type_Id
                 ,Org_Util_Category_Id
                 ,Res_Util_Category_Id
                 ,Expenditure_Type
                 ,Expenditure_Type_Class
                 ,Pa_Period_Num
                 ,Pa_Period_Name
                 ,Pa_Quarter_Number
                 ,Pa_Period_Year
                 ,Gl_Period_Num
                 ,Gl_Period_Name
                 ,Gl_Quarter_Number
                 ,Gl_Period_Year
                 ,Global_Exp_Period_End_Date
                 ,Global_Exp_Month_Number
                 ,Global_Exp_Year
                 ,Total_Hours
                 ,Total_Wghted_Hours_Org
                 ,Total_Wghted_Hours_People
                 ,Reduce_Capacity
                 ,Total_Prov_Hours
                 ,Prov_Wghted_Hours_Org
                 ,Prov_Wghted_Hours_People
                 ,Delete_flag
              )
    SELECT
       cdl.ROWID                                                            row_id
      ,NULL                                                                 parent_row_id
      ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id) exp_organization_id
      ,exp.incurred_by_person_id                                            person_id
      ,-1                                                                   assignment_id
      ,cdl.work_type_id                                                      work_type_id  --bug 2980483
      ,wt.org_util_category_id                                              org_util_category_id
      ,wt.res_util_category_id                                              res_util_category_id
      ,ei.expenditure_type                                                  exp_type
      ,ei.system_linkage_function                                           exp_type_class
      ,NULL                                                                 pa_period_number
      ,NULL                                                                 pa_period_name
      ,NULL                                                                 pa_qtr_num
      ,NULL                                                                 pa_period_year
      ,(gglp.period_year*10000 + gglp.period_num)                           gl_period_number
      ,gglp.period_name                                                     gl_period_name
      ,gglp.quarter_num                                                     gl_qtr_num
      ,gglp.period_year                                                     gl_period_year
      ,TRUNC(NEXT_DAY(ei.expenditure_item_date,
                 l_global_week_start_day) - 1)                              ge_end_date
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'MM'))                                      ge_month_number
      ,TO_NUMBER(TO_CHAR((NEXT_DAY(ei.expenditure_item_date,
                         l_global_week_start_day
                        ) - 1), 'YYYY'))                                    ge_period_year
      ,NVL(cdl.quantity, 0)                                                 work_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.org_utilization_percentage)/100),2) org_weighted_qty
      ,ROUND(((NVL(cdl.quantity, 0)* wt.res_utilization_percentage)/100),2) res_weighted_qty
      ,DECODE(wt.reduce_capacity_flag, 'Y',
                NVL(cdl.quantity, 0), 0)                                    reduce_cpcty
      ,0                                                                    tot_prov_hrs
      ,0                                                                    prov_wghtd_hrs_org
      ,0                                                                    prov_wghtd_hrs_people
      ,'Y'                                                                  delete_flag
  FROM
         gl_periods                      gglp
        ,pa_work_types_b                 wt
        ,pa_resources_denorm             res
        ,pa_expenditures_all             exp
        ,pa_expenditure_items_all        ei
        ,pa_cost_distribution_lines_all  cdl
  WHERE NVL(cdl.org_id, -99) = NVL(ei.org_id, -99)
    AND NVL(exp.org_id, -99) = NVL(ei.org_id, -99)
--  AND gglp.period_set_name = l_period_set_name
    AND gglp.period_set_name = l_gl_period_set_name -- bug 3434019
    AND gglp.period_name = cdl.gl_period_name
 AND ei.expenditure_item_date BETWEEN l_ac_start_date AND TRUNC(l_ac_end_date)+0.99999   /* BUG# 3118592 */
    AND ei.expenditure_item_date BETWEEN res.resource_effective_start_date AND NVL(TRUNC(res.resource_effective_end_date)+0.99999, ei.expenditure_item_date) /* BUG# 3118592 */
    AND NVL(res.utilization_flag, 'N') = 'Y'
    AND res.person_id = exp.incurred_by_person_id
    AND res.resource_organization_id = nvl(ei.override_to_organization_id,
                                           exp.incurred_by_organization_id )
    AND exp.expenditure_id = ei.expenditure_id
    AND ei.system_linkage_function IN ('ST', 'OT')
    AND ei.cost_distributed_flag = 'Y'
    AND ei.expenditure_item_id = cdl.expenditure_item_id
    AND cdl.work_type_id                     = wt.work_type_id    --bug 2980483
    AND cdl.line_type = 'R'
    AND cdl.util_summarized_flag = 'N'
    AND NVL(cdl.org_id,-99) = l_org_id;
--    AND ROWNUM <= l_fetch_size;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END insert_act_into_tmp_GLGE;
-------------------------------------------------------
END PA_SUMMARIZE_ACTUAL_UTIL_PVT;

/
