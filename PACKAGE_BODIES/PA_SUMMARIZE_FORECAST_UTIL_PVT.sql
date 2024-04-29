--------------------------------------------------------
--  DDL for Package Body PA_SUMMARIZE_FORECAST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SUMMARIZE_FORECAST_UTIL_PVT" 
-- $Header: PARRFCVB.pls 120.0 2005/05/29 23:19:58 appldev noship $
AS

  -- Assign the glboal variables to the local variable
  -- This aviods repeated calls to the global package

  -- Balance Type
  l_balance_type  VARCHAR2(15) := PA_REP_UTIL_GLOB.G_BAL_TYPE_C.G_FORECAST_C;

  --  Input Parameters.
  l_fc_start_date   DATE := PA_REP_UTIL_GLOB.G_input_parameters.G_fc_start_date;
  l_fc_end_date     DATE := PA_REP_UTIL_GLOB.G_input_parameters.G_fc_end_date;

  -- Utilization Option details
  l_forecast_thru_date pa_utilization_options.forecast_thru_date%TYPE := PA_REP_UTIL_GLOB.G_util_option_details.G_forecast_thru_date;
  l_pa_period_flag     pa_utilization_options.pa_period_flag%TYPE     := PA_REP_UTIL_GLOB.G_util_option_details.G_pa_period_flag;
  l_gl_period_flag     pa_utilization_options.gl_period_flag%TYPE     := PA_REP_UTIL_GLOB.G_util_option_details.G_gl_period_flag;
  l_ge_period_flag     pa_utilization_options.global_exp_period_flag%TYPE := PA_REP_UTIL_GLOB.G_util_option_details.G_ge_period_flag;

  -- Implementation options
  l_org_id pa_implementations.org_id%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_org_id;

  --  Profile Options
  l_global_week_start_day PLS_INTEGER := PA_REP_UTIL_GLOB.G_global_week_start_day;
  l_fetch_size            PLS_INTEGER := PA_REP_UTIL_GLOB.G_util_fetch_size;

  -- Period Information
--  l_period_set_name gl_sets_of_books.period_set_name%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_period_set_name;
  l_gl_period_set_name gl_sets_of_books.period_set_name%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_gl_period_set_name; -- bug 3434019
  l_pa_period_set_name gl_sets_of_books.period_set_name%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_pa_period_set_name; -- bug 3434019
  l_pa_period_type pa_implementations.pa_period_type%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_pa_period_type;
  l_gl_period_type gl_sets_of_books.accounted_period_type%TYPE := PA_REP_UTIL_GLOB.G_implementation_details.G_gl_period_type;

  -- Who Columns
  l_created_by             NUMBER(15) := PA_REP_UTIL_GLOB.G_who_columns.G_created_by;
  l_last_updated_by        NUMBER(15) := PA_REP_UTIL_GLOB.G_who_columns.G_last_updated_by;
  l_request_id             NUMBER(15) := PA_REP_UTIL_GLOB.G_who_columns.G_request_id;
  l_program_id             NUMBER(15) := PA_REP_UTIL_GLOB.G_who_columns.G_program_id;
  l_program_application_id NUMBER(15) := PA_REP_UTIL_GLOB.G_who_columns.G_program_application_id;
  l_creation_date          DATE := PA_REP_UTIL_GLOB.G_who_columns.G_creation_date;
  l_last_update_date       DATE := PA_REP_UTIL_GLOB.G_who_columns.G_last_update_date;
  l_program_update_date    DATE := PA_REP_UTIL_GLOB.G_who_columns.G_last_update_date;

  l_debug_mode         VARCHAR2(2) := PA_REP_UTIL_GLOB.G_input_parameters.G_debug_mode;
  l_quantity_id        pa_amount_types_b.amount_type_id%TYPE := PA_REP_UTIL_GLOB. G_amt_type_details.G_quantity_id;
  l_org_rollup_method  VARCHAR2(1) := PA_REP_UTIL_GLOB.G_input_parameters.G_org_rollup_method;

-------------------------------------------------------
  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

  PROCEDURE insert_fct_into_tmp_table
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function => 'insert_fct_into_tmp_table');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
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

--    PA_DEBUG.g_err_stage := '210: After inserting recs into Temp Table';
--    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END insert_fct_into_tmp_table;
-------------------------------------------------------

PROCEDURE Summarize_Forecast_Util
IS
  l_fid_rowid_tab        PA_PLSQL_DATATYPES.RowidTabTyp;
  l_process_method       VARCHAR2(1);
  l_records_inserted     PLS_INTEGER;
  l_records_updated      PLS_INTEGER;
  l_capacity_summarized  NUMBER :=0;
  l_records_inserted1    PLS_INTEGER;
 BEGIN
    -- Initialize the Error Stack


    PA_DEBUG.Set_Curr_Function( p_function   => 'Summarize_Forecast_Util');

    IF  (l_pa_period_flag = 'N') AND (l_gl_period_flag = 'N') AND (l_ge_period_flag = 'N') THEN
      -- Reset the error stack when returning to the calling program
      PA_DEBUG.Reset_Curr_Function;
      RETURN;
    END IF;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.G_Err_Stage := '50  : L_FC_START_DATE ' || l_fc_start_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.G_Err_Stage := '100 : L_FC_END_DATE ' || l_fc_end_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.G_Err_Stage := '150 : After checking the flags ';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.G_Err_Stage := '200 : L_PA_PERIOD_FLAG ' || l_pa_period_flag;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.G_Err_Stage := '250 : L_GL_PERIOD_FLAG ' || l_gl_period_flag;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.G_Err_Stage := '300 : L_GE_PERIOD_FLAG ' || l_ge_period_flag;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    END IF;

    /*
     * Calling a procedure for populating the initial temporary workspace
     * Starts Here
     */
      IF (l_pa_period_flag = 'Y') THEN
        IF (l_gl_period_flag = 'Y') THEN
          IF (l_ge_period_flag = 'Y') THEN
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            PA_DEBUG.G_Err_Stage := '350 : Calling PAGLGE';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	    END IF;
            Insert_Fcst_Into_Tmp_PAGLGE;
          ELSE
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            PA_DEBUG.G_Err_Stage := '400 : Calling PAGL';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	    END IF;
            Insert_Fcst_Into_Tmp_PAGL;
          END IF;
        ELSIF (l_ge_period_flag = 'Y') THEN
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.G_Err_Stage := '450 : Calling PAGE';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	  END IF;
          Insert_Fcst_Into_Tmp_PAGE;
        ELSE
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.G_Err_Stage := '500 : Calling PA';
	  PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	  END IF;
          Insert_Fcst_Into_Tmp_PA;
        END IF;
      ELSIF (l_gl_period_flag = 'Y') THEN
        IF (l_ge_period_flag = 'Y') THEN
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.G_Err_Stage := '550 : Calling GLGE';
	  PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	  END IF;
          Insert_Fcst_Into_Tmp_GLGE;
        ELSE
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.G_Err_Stage := '600 : Calling GL';
	  PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	  END IF;
          Insert_Fcst_Into_Tmp_GL;
        END IF;
      ELSE
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.G_Err_Stage := '650 : Calling GE';
	PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	END IF;
        Insert_Fcst_Into_Tmp_GE;
      END IF;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '700 : After Calling the INSERT_PROC_[PA][GL][GE]';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
      END IF;

    /*
     * Calling a procedure for populating the temporary workspace
     * Ends Here
     */
    -- Main Un-conditional Loop. Exits if No more records to process (SQL%ROWCOUNT = 0)
    LOOP

      -- Check if ANY records have been inserted into the temporary table.
      /*
       * Transfer the data from the initial staging area to the current
       * processing set.
       */

      insert_fct_into_tmp_table;
      -- If NO records are inserted, getout of the loop.
      l_records_inserted := SQL%ROWCOUNT;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '750 : Records Inserted in Temp tab : ' || l_records_inserted;
      PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
      PA_DEBUG.G_Err_Stage := '753 : l_capacity_summarized: ' || l_capacity_summarized;
      PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
      END IF;

      IF (l_records_inserted = 0 AND l_capacity_summarized= 1) THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '757 : EXITING since l_records_inserted = 0 AND l_capacity_summarized= 1';
      PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
      END IF;
        EXIT;
      END IF;

      -- Update Forecast Item Detail with util_summarized_code = 'S' for  the
      -- rowids available in the temp0 table.
      -- The local rowid plsql table collects all the rowids
      -- for which update was successful.

      UPDATE pa_forecast_item_details A
      SET    util_summarized_code = 'S'
      WHERE  util_summarized_code = 'N'
      AND    exists (   SELECT row_id
                        FROM   pa_rep_util_summ0_tmp B
			WHERE  A.ROWID = B.ROW_ID  -- bug 3132246
                      )
      RETURNING ROWID BULK COLLECT INTO l_fid_rowid_tab;

      l_records_updated := SQL%ROWCOUNT;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '800 : Records Updated in PA_FORECAST_ITEMS_DETAILS : '|| l_records_updated;
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
      END IF;

      -- Check if the all the Forecast_Item_Detail records corresponding to the
      -- those in temp0 have been updated with util_summarized_code = 'S'.
      -- If YES, process_method = 'A' (ALL)
      -- id not process_method = 'F'(FILTER - will be based on the PA_REP_UTIL_SUMM0_TMP.delete_flag).
      -- The delete flag in pa_rep_util_summ0_tmp is initialized
      -- to 'Y' when first inserted. But if update of util_summarized_code = 'S'
      -- is successful, for those records, delete_flag of their corresponding records in temp table
      -- are updated to 'N' - meaning that, those records SHOULD be processed and hence
      -- to be considered as NOT deleted.

      l_process_method := 'A';


      IF (l_records_updated < l_records_inserted AND l_fid_rowid_tab.COUNT > 0) THEN /* added second condition 2084888 */
        l_process_method := 'F';
        FORALL i IN l_fid_rowid_tab.FIRST .. l_fid_rowid_tab.LAST
          UPDATE pa_rep_util_summ0_tmp tmp
          SET    tmp.delete_flag = 'N'
          WHERE  tmp.row_id = l_fid_rowid_tab(i);
      END IF;

      -- Delete the rowid plsql table.
      l_fid_rowid_tab.DELETE;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '850 : Process Method : ' || l_process_method;
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
      PA_DEBUG.G_Err_Stage := '900 : Before calling PA_REP_UTILS_SUMM_PKG';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
      END IF;

      --
      -- Call the package which processes the data.
      PA_REP_UTILS_SUMM_PKG.populate_summ_entity( p_balance_type_code => l_balance_type
                                                 ,p_process_method    => l_process_method );


      l_capacity_summarized := 1;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.G_Err_Stage := '950 : After calling PA_REP_UTILS_SUMM_PKG';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
      END IF;

      -- If the process_method is 'F' (Filter):
      --   1. Delete those records from pa_forecast_item_details which have been processed
      --      i.e. summarised code is 'S' and temp table delete flag is 'N'
      --   2. Update the util_summarized_code to NULL for those records which have been processed
      --   3. Delete pa_forecat_items (master) records for which processed detail records have been
      --      deleted and no further detail record exists
      --
      -- If process_method is 'A' (All):
      --   1. Delete those records from pa_forecast_item_details which have been processed and for
      --      for which a record exsists in temp table. i.e. summarised code is 'S'
      --      and temp table delete flag is 'Y'
      --   2. Update the util_summarized_code to NULL for those records which have been processed
      --
      --   3. Delete pa_forecat_items (master) records for which processed detail records have been
      --    deleted and no further detail record exists


      IF l_process_method = 'F' THEN
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	/* Commented for Bug 2984871
        PA_DEBUG.G_Err_Stage := '1000 : Records Deleted from PA_FORECAST_ITEM_DETAILS: ' || to_char(SQL%ROWCOUNT);
	PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
	PA_DEBUG.G_Err_Stage := '1050 : After deleting from PA_FORECAST_ITEM_DETAILS for process method ' || l_process_method ;
	PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);*/
	/*Code Changes for Bug No.2984871 start */
	PA_DEBUG.G_Err_Stage := '1050 : process method = ' || l_process_method ;
	PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	/*Code Changes for Bug No.2984871 end */
	END IF;
        --
        UPDATE pa_forecast_item_details
        SET    util_summarized_code = NULL
              ,last_update_date  = l_last_update_date
              ,last_updated_by   = l_last_updated_by
              ,request_id       = l_request_id
              ,program_application_id = l_program_application_id
              ,program_id = l_program_id
              ,program_update_date = l_program_update_date
        WHERE  util_summarized_code = 'S' -- Do we require this?
        AND    ROWID IN (SELECT  row_id
                         FROM    pa_rep_util_summ0_tmp
                         WHERE   delete_flag = 'N'
                        );
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.G_Err_Stage := '1100 : Records Updated in PA_FORECAST_ITEM_DETAILS: ' || to_char(SQL%ROWCOUNT);
	PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
	PA_DEBUG.G_Err_Stage := '1150 : After Updating PA_FORECAST_ITEM_DETAILS for process method ' || l_process_method ;
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	END IF;
        --
		/*
		** Bug 2263074
		** The delete statement for pa_forecast_items is removed.
	    */
        --
      ELSIF l_process_method = 'A' THEN
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	/* Commented for Bug 2984871
        PA_DEBUG.G_Err_Stage := '1300 : Records Deleted from PA_FORECAST_ITEM_DETAILS: ' || to_char(SQL%ROWCOUNT);
	PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
	PA_DEBUG.G_Err_Stage := '1350 : After deleting from PA_FORECAST_ITEM_DETAILS for process method ' || l_process_method ;
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);*/

	/*Code Changes for Bug No.2984871 start */
	PA_DEBUG.G_Err_Stage := '1350 : process method = ' || l_process_method ;
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	/*Code Changes for Bug No.2984871 end */
	END IF;
        --
        UPDATE pa_forecast_item_details
        SET    util_summarized_code = NULL
              ,last_update_date = l_last_update_date
              ,last_updated_by  = l_last_updated_by
              ,request_id       = l_request_id
              ,program_application_id = l_program_application_id
              ,program_id = l_program_id
              ,program_update_date = l_program_update_date
        WHERE  util_summarized_code = 'S' -- Do we require this?
        AND    ROWID IN (SELECT  row_id
                         FROM    pa_rep_util_summ0_tmp
                        );
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.G_Err_Stage := '1400 : Records Updated in PA_FORECAST_ITEM_DETAILS: ' || to_char(SQL%ROWCOUNT);
         PA_DEBUG.Log_Message(p_message => pa_debug.G_Err_Stage);
	PA_DEBUG.G_Err_Stage := '1450 : After Updating PA_FORECAST_ITEM_DETAILS for process method ' || l_process_method ;
	PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
	END IF;
        --
        /*
        ** Bug 2263074
        ** The delete statement for pa_forecast_items is removed.
        */
        --
      END IF;
-- mpuvathi
 delete from pa_rep_util_summ00_tmp
 where row_id in (select row_id from pa_rep_util_summ0_tmp)
 ;
-- mpuvathi
      COMMIT;
    END LOOP;


    -- IF Refresh organization rollup is enabled, populate the PA_rep_util_summ_tmp
    IF (l_org_rollup_method = 'R') THEN
      PA_SUMMARIZE_ORG_ROLLUP_PVT.refresh_org_hierarchy_rollup( p_balance_type_code => l_balance_type);
    END IF;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.G_Err_Stage := '1600 : After calling Organization Utilization Forecast Refresh Rollup';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    END IF;

    --
    -- Update pa_utilization_options with the dates for which Balances exist.
    --
    /* Bug 1628557
     * Put the code for update outside of the if loop so that the thru date
     *  is updated with the end date of the current run (it would no longer
     *  reflect the furthest out date till which summarization was ever run,
     *  as was the case earlier)
     * IF NVL(l_forecast_thru_date, l_fc_end_date -1) < l_fc_end_date  THEN
     * code for update
     * END IF;
     */
    UPDATE pa_utilization_options_all
    SET    forecast_thru_date = l_fc_end_date
           , forecast_last_run_date = sysdate
    WHERE  NVL(org_id, -99) = l_org_id;

	/* Bug 2177424
	 * The delete logic is modified to delete all the forecast items
	 * which are processed (util_summarized_code is null).
	 */
    /*
    ** Bug 2263074
    ** The delete statement for pa_forecast_item_details is removed.
    */

    COMMIT;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.G_Err_Stage := '1650 : After updating PA_UTILIZATION_OPTIONS_ALL';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
    PA_DEBUG.g_err_stage := '1660: Exiting the Package PA_SUMMARIZE_FORECAST_UTIL';
    END IF;
    -- Reset the error stack when returning to the calling program
    PA_DEBUG.Reset_Curr_Function;

    EXCEPTION
      WHEN OTHERS THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stack);
        PA_DEBUG.Log_Message(p_message => SQLERRM);
	END IF;
        RAISE;

 END Summarize_Forecast_Util;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_PA
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_PA
IS
 BEGIN
   -- Set the error stack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_PA');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2000 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA';
    END IF;
   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
    )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,fi.pvdr_pa_period_name                    pa_period_name
         ,(pp.period_year * 10000) + pp.period_num  pa_period_num
         ,pp.period_year                            pa_period_year
         ,pp.quarter_num                            pa_quarter_number
         ,NULL                                      gl_period_name
         ,NULL                                      gl_period_num
         ,NULL                                      gl_period_year
         ,NULL                                      gl_quarter_number
         ,NULL                                      global_exp_period_end_date
         ,NULL                                      global_exp_year
         ,NULL                                      global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
   FROM  pa_forecast_items fi
        ,pa_forecast_item_details fid
        ,gl_periods pp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
-- AND   pp.period_set_name = l_period_set_name
   AND   pp.period_set_name = l_pa_period_set_name  -- bug 3434019
   AND   pp.period_type = l_pa_period_type
   --AND   fi.pvdr_period_set_name = pp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_pa_period_name  = pp.period_name
   AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999;  /* BUG# 3118592 */

   commit;
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
     PA_DEBUG.G_Err_Stage := '2050 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_PA;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_GL
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_GL
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_GL');
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2100 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GL';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
   )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,NULL                                      pa_period_name
         ,NULL                                      pa_period_num
         ,NULL                                      pa_period_year
         ,NULL                                      pa_quarter_number
         ,fi.pvdr_gl_period_name                    gl_period_name
         ,(gp.period_year * 10000) + gp.period_num  gl_period_num
         ,gp.period_year                            gl_period_year
         ,gp.quarter_num                            gl_quarter_number
         ,NULL                                      global_exp_period_end_date
         ,NULL                                      global_exp_year
         ,NULL                                      global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
    FROM  pa_forecast_items fi
         ,pa_forecast_item_details fid
         ,gl_periods gp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
-- AND   gp.period_set_name = l_period_set_name
   AND   gp.period_set_name = l_gl_period_set_name  -- bug 3322360
   AND   gp.period_type = l_gl_period_type
 --AND   fi.pvdr_period_set_name = gp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_gl_period_name  = gp.period_name
     AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999 ; /* BUG# 3118592 */


   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2150 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GL';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_GL;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_GE
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_GE
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_GE');

IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2200 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
   )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,NULL                    pa_period_name
         ,NULL                    pa_period_num
         ,NULL                    pa_period_year
         ,NULL                    pa_quarter_number
         ,NULL                    gl_period_name
         ,NULL                    gl_period_num
         ,NULL                    gl_period_year
         ,NULL                    gl_quarter_number
         ,trunc(fi.global_exp_period_end_date)                        global_exp_period_end_date
         ,to_number(to_char(fi.global_exp_period_end_date, 'YYYY'))   global_exp_year
         ,to_number(to_char(fi.global_exp_period_end_date, 'MM'))     global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
    FROM  pa_forecast_items fi
         ,pa_forecast_item_details fid
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
   AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999;   /* BUG# 3118592 */

IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2250 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_GE;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_PAGL
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_PAGL
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_PAGL');

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2300 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA and GL';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
    )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,fi.pvdr_pa_period_name                    pa_period_name
         ,(pp.period_year * 10000) + pp.period_num  pa_period_num
         ,pp.period_year                            pa_period_year
         ,pp.quarter_num                            pa_quarter_number
         ,fi.pvdr_gl_period_name                    gl_period_name
         ,(gp.period_year * 10000) + gp.period_num  gl_period_num
         ,gp.period_year                            gl_period_year
         ,gp.quarter_num                            gl_quarter_number
         ,NULL                                      global_exp_period_end_date
         ,NULL                                      global_exp_year
         ,NULL                                      global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
   FROM  pa_forecast_items fi
        ,pa_forecast_item_details fid
        ,gl_periods pp
        ,gl_periods gp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
-- AND   pp.period_set_name = l_period_set_name
   AND   pp.period_set_name = l_pa_period_set_name  -- bug 3434019
   AND   pp.period_type = l_pa_period_type
 --AND   fi.pvdr_period_set_name = pp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_pa_period_name  = pp.period_name
-- AND   gp.period_set_name = l_period_set_name
   AND   gp.period_set_name = l_gl_period_set_name  -- bug 3434019
   AND   gp.period_type = l_gl_period_type
 --AND   fi.pvdr_period_set_name = gp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_gl_period_name  = gp.period_name
   AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999 ;  /* BUG# 3118592 */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2350 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA and GL';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_PAGL;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_PAGE
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_PAGE
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_PAGE');

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2400 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
    )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,fi.pvdr_pa_period_name                    pa_period_name
         ,(pp.period_year * 10000) + pp.period_num  pa_period_num
         ,pp.period_year                            pa_period_year
         ,pp.quarter_num                            pa_quarter_number
         ,NULL                                      gl_period_name
         ,NULL                                      gl_period_num
         ,NULL                                      gl_period_year
         ,NULL                                      gl_quarter_number
         ,trunc(fi.global_exp_period_end_date)                        global_exp_period_end_date
         ,to_number(to_char(fi.global_exp_period_end_date, 'YYYY'))   global_exp_year
         ,to_number(to_char(fi.global_exp_period_end_date, 'MM'))     global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
   FROM  pa_forecast_items fi
        ,pa_forecast_item_details fid
        ,gl_periods pp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
--   AND   pp.period_set_name = l_period_set_name
   AND   pp.period_set_name = l_pa_period_set_name  -- bug 3434019
   AND   pp.period_type = l_pa_period_type
  --AND   fi.pvdr_period_set_name = pp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_pa_period_name  = pp.period_name
   AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999   ; /* BUG# 3118592 */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2450 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_PAGE;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_GLGE
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_GLGE
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_GLGE');

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2500 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GL and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
    )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,NULL                                      pa_period_name
         ,NULL                                      pa_period_num
         ,NULL                                      pa_period_year
         ,NULL                                      pa_quarter_number
         ,fi.pvdr_gl_period_name                    gl_period_name
         ,(gp.period_year * 10000) + gp.period_num  gl_period_num
         ,gp.period_year                            gl_period_year
         ,gp.quarter_num                            gl_quarter_number
         ,trunc(fi.global_exp_period_end_date)                        global_exp_period_end_date
         ,to_number(to_char(fi.global_exp_period_end_date, 'YYYY'))   global_exp_year
         ,to_number(to_char(fi.global_exp_period_end_date, 'MM'))     global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
   FROM  pa_forecast_items fi
        ,pa_forecast_item_details fid
        ,gl_periods gp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
-- AND   gp.period_set_name = l_period_set_name
   AND   gp.period_set_name = l_gl_period_set_name  -- bug 3434019
   AND   gp.period_type = l_gl_period_type
  --AND   fi.pvdr_period_set_name = gp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_gl_period_name  = gp.period_name
  AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999; /* BUG# 3118592 */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2550 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for GL and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_GLGE;


--------------------------------------------
--  Procedure Insert_Fcst_Into_Tmp_PAGLGE
--------------------------------------------

PROCEDURE Insert_Fcst_Into_Tmp_PAGLGE
IS
 BEGIN
   -- Set the error satack
   PA_DEBUG.Set_Curr_Function( p_function   => 'Insert_Fcst_Into_Tmp_PAGLGE');
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2600 : Before Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA, GL and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   INSERT INTO pa_rep_util_summ00_tmp
   ( row_id
    ,parent_row_id
    ,expenditure_organization_id
    ,person_id
    ,assignment_id
    ,work_type_id
    ,org_util_category_id
    ,res_util_category_id
    ,expenditure_type
    ,expenditure_type_class
    ,pa_period_name
    ,pa_period_num
    ,pa_period_year
    ,pa_quarter_number
    ,gl_period_name
    ,gl_period_num
    ,gl_period_year
    ,gl_quarter_number
    ,global_exp_period_end_date
    ,global_exp_year
    ,global_exp_month_number
    ,total_hours
    ,total_prov_hours
    ,total_wghted_hours_people
    ,total_wghted_hours_org
    ,prov_wghted_hours_people
    ,prov_wghted_hours_org
    ,reduce_capacity
    ,delete_flag
    )
   SELECT fid.rowid   row_id
         ,fi.rowid    parent_row_id
         ,fi.expenditure_organization_id
         ,fi.person_id
         ,fi.assignment_id
         ,fid.work_type_id
         ,fid.org_util_category_id
         ,fid.resource_util_category_id
         ,fi.expenditure_type
         ,fi.expenditure_type_class
         ,fi.pvdr_pa_period_name                    pa_period_name
         ,(pp.period_year * 10000) + pp.period_num  pa_period_num
         ,pp.period_year                            pa_period_year
         ,pp.quarter_num                            pa_quarter_number
         ,fi.pvdr_gl_period_name                    gl_period_name
         ,(gp.period_year * 10000) + gp.period_num  gl_period_num
         ,gp.period_year                            gl_period_year
         ,gp.quarter_num                            gl_quarter_number
         ,trunc(fi.global_exp_period_end_date)                        global_exp_period_end_date
         ,to_number(to_char(fi.global_exp_period_end_date, 'YYYY'))   global_exp_year
         ,to_number(to_char(fi.global_exp_period_end_date, 'MM'))     global_exp_month_number
         ,NVL(fid.item_quantity, 0)                                                     total_hours
         ,NVL(fid.item_quantity, 0) * decode(fid.provisional_flag, 'Y', 1, 0)           total_prov_hours
         ,NVL(fid.resource_util_weighted, 0)                                            total_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0)                                                 total_wghted_hours_org
         ,NVL(fid.resource_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)  prov_wghted_hours_people
         ,NVL(fid.org_util_weighted, 0) * decode(fid.provisional_flag, 'Y', 1, 0)       prov_wghted_hours_org
         ,DECODE(fid.reduce_capacity_flag, 'Y', 1, 'N', 0) * NVL(fid.item_quantity, 0)  reduce_capacity
         ,'Y'                                                                           delete_flag
   FROM  pa_forecast_items fi
        ,pa_forecast_item_details fid
        ,gl_periods pp
        ,gl_periods gp
   WHERE fi.forecast_item_id = fid.forecast_item_id
   AND   fi.expenditure_org_id = l_org_id
   AND   fid.expenditure_org_id = l_org_id
   AND   fi.forecast_item_type IN ('A', 'U')
   AND   fid.util_summarized_code = 'N'
   --AND   fid.person_billable_flag = 'Y'
   AND   fid.amount_type_id = l_quantity_id
-- AND   pp.period_set_name = l_period_set_name
   AND   pp.period_set_name = l_pa_period_set_name  -- bug 3434019
   AND   pp.period_type = l_pa_period_type
 --AND   fi.pvdr_period_set_name = pp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_pa_period_name  = pp.period_name
-- AND   gp.period_set_name = l_period_set_name
   AND   gp.period_set_name = l_gl_period_set_name  -- bug 3434019
   AND   gp.period_type = l_gl_period_type
  --AND   fi.pvdr_period_set_name = gp.period_set_name /* commented for bug 3488229 */
   AND   fi.pvdr_gl_period_name  = gp.period_name
   AND   fi.item_date BETWEEN  l_fc_start_date AND TRUNC(l_fc_end_date)+0.99999 ; /* BUG# 3118592 */

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.G_Err_Stage := '2650 : After Inserting Forecast data into PA_REP_UTIL_SUMM0_TMP for PA, GL and GE';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.G_Err_Stage);
   END IF;

   -- Reset the error stack
   PA_DEBUG.Reset_Curr_Function;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
 END Insert_Fcst_Into_Tmp_PAGLGE;


END PA_SUMMARIZE_FORECAST_UTIL_PVT;

/
