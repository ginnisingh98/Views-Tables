--------------------------------------------------------
--  DDL for Package Body PA_REP_UTILS_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REP_UTILS_SUMM_PKG" as
/* $Header: PARRSUMB.pls 120.0.12010000.2 2009/05/26 12:46:52 nisinha ship $ */

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

/*
 * This variable is populated by the public procedure of this
 * package.
 */
l_balance_type_code            VARCHAR2(30);

/*
 * Cache all object types for insert.
 */
l_org_c      VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_ORG_C;
l_orguc_c    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_ORGUC_C;
l_orgwt_c    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_ORGWT_C;
l_res_c      VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C;
l_resuco_c   VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RESUCO_C;
l_resucr_c   VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RESUCR_C;
l_reswt_c    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RESWT_C;
l_utildet_c  VARCHAR2(15) := PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_UTILDET_C;
/*
 * End Caching object types.
 */

/*
 * Cache Amount Type Id.
 */
l_tot_hrs_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_hrs_id;
l_tot_prov_hrs_id         pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_prvhrs_id;
l_tot_wght_hrs_people_id  pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_wtdhrs_people_id;
l_tot_wght_hrs_org_id     pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_wtdhrs_org_id;
l_prov_wght_hrs_people_id pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_prvwtdhrs_people_id;
l_prov_wght_hrs_org_id    pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_prvwtdhrs_org_id;
l_red_cap_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_reducedcap_id;
l_tot_cap_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_cap_id;
/*
 * End Caching.
 */

/*
 * Delete Flag identifying whether any deleted record exists in
 * pa_rep_util_summ_tmp.
 */
 l_delete_flag       VARCHAR2(1);

/*
 * Cache the Expenditure Org Id.
 */
l_exp_org_id   NUMBER := PA_REP_UTIL_GLOB.G_implementation_details.G_org_id;

/*
 * Cache the concurrent program related globals.
 */
l_last_updated_by   NUMBER := PA_REP_UTIL_GLOB.G_who_columns.G_last_updated_by;
l_created_by        NUMBER := PA_REP_UTIL_GLOB.G_who_columns.G_created_by;
l_creation_date     DATE   := PA_REP_UTIL_GLOB.G_who_columns.G_creation_date;
l_last_update_date  DATE   := PA_REP_UTIL_GLOB.G_who_columns.G_last_update_date;
l_last_update_login NUMBER := PA_REP_UTIL_GLOB.G_who_columns.G_program_application_id;
l_request_id        NUMBER := PA_REP_UTIL_GLOB.G_who_columns.G_request_id;
l_program_id        NUMBER := PA_REP_UTIL_GLOB.G_who_columns.G_program_id;
l_program_application_id   NUMBER
                    := PA_REP_UTIL_GLOB.G_who_columns.G_program_application_id;

/*
 * End Caching Who Columns.
 */

/*
 * Cache period set name and UOM.
 */
--l_period_set_name  gl_sets_of_books.period_set_name%TYPE
--               := PA_REP_UTIL_GLOB.G_implementation_details.G_period_set_name;
l_gl_period_set_name  gl_sets_of_books.period_set_name%TYPE
               := PA_REP_UTIL_GLOB.G_implementation_details.G_gl_period_set_name; -- Bug 3434019
l_pa_period_set_name  gl_sets_of_books.period_set_name%TYPE
               := PA_REP_UTIL_GLOB.G_implementation_details.G_pa_period_set_name; -- Bug 3434019
l_unit_of_measure   VARCHAR2(10) := PA_REP_UTIL_GLOB.G_UNIT_OF_MEASURE_HRS_C;

/*
 * Cache Period Type.
 */
l_gl_c  VARCHAR2(3) := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_GL_C;
l_pa_c  VARCHAR2(3) := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_PA_C;
l_ge_c  VARCHAR2(3) := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_GE_C;
/*
 * End Caching Period Type.
 */

/*
 * Dummy period set name and period name.
 */
l_dummy_period_set_name   VARCHAR2(15) := PA_REP_UTIL_GLOB.G_DUMMY_C;
l_dummy_period_name       VARCHAR2(15) := PA_REP_UTIL_GLOB.G_DUMMY_C;
l_dummy_ge_date           DATE         := PA_REP_UTIL_GLOB.G_DUMMY_DATE_C;

/*
 * Cache org level direct amount type Id.
 */
l_dirct_tot_hrs_id            pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_hrs_id;
l_dirct_tot_prov_hrs_id       pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_prvhrs_id;
l_dirct_tot_wght_hrs_org_id   pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_wtdhrs_org_id;
l_dirct_prov_wght_hrs_org_id  pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_prvwtdhrs_org_id;
l_dirct_cap_id                pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_cap_id;
l_dirct_reduce_cap_id         pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_reducedcap_id;
/*
 * End Cache org level direct amount type Id.
 */

/*
 * Cache Incremental Method flag.
 */
l_org_rollup_method    VARCHAR2(1)
                     := PA_REP_UTIL_GLOB.G_input_parameters.G_org_rollup_method;
/*
 * Cache Actual and Forecast balance type Constants.
 */
l_actual_c      VARCHAR2(15) := PA_REP_UTIL_GLOB.G_BAL_TYPE_C.G_ACTUALS_C;
l_forecast_c    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_BAL_TYPE_C.G_FORECAST_C;

/*
 * Predefination of local procedure.
 */
PROCEDURE populate_incremental_rollup;

/*
 * This procedure reads data from global table, summarize by
 * PA_PERIOD ,GL Period or Global Expenditure week based on the
 * global setup data. This procedure has two steps -
 *   1. It loads data into a temporary table pa_rep_util_summ_tmp
 *      from global PL/SQL Table.
 *   2. Summarize the data by period depending on setup and populate
 *      a PL/SQL Table.
 */

PROCEDURE summarize_by_period
IS
   i          PLS_INTEGER;
BEGIN

   PA_DEBUG.set_curr_function('summarize_by_period');
   /*
    * Step 1 - Populate the global temporary table from individual PL/SQL Table
    * in bulk.
    */

    /*
     * Separate the SQL for delete flag = 'A' and <>'A'
     * 'A' - means all records from pa_rep_util_summ0_tmp should be processed.
     * 'F' - means only non deleted record will be processed .
     */

   IF ( l_delete_flag <> 'A')
   THEN

      /*
       * Populate pa_rep_util_summ_tmp for Total Hours.
       */
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Hours ';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;
      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG
          )
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_hrs_id,
             TOTAL_HOURS,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE DELETE_FLAG     = 'N'
       AND   TOTAL_HOURS     <> 0;


      IF (l_balance_type_code <> l_actual_c) THEN

        /*
         * Populate pa_rep_util_summ_tmp for Total Provisional Hours.
         */
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Hours';
        PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
	END IF;

        INSERT INTO pa_rep_util_summ_tmp
         (  RECORD_TYPE
            ,EXPENDITURE_ORGANIZATION_ID
            ,PERSON_ID
            ,ASSIGNMENT_ID
            ,WORK_TYPE_ID
            ,ORG_UTIL_CATEGORY_ID
            ,RES_UTIL_CATEGORY_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_TYPE_CLASS
            ,PA_PERIOD_NAME
            ,PA_PERIOD_NUM
            ,PA_PERIOD_YEAR
            ,PA_QUARTER_NUMBER
            ,GL_PERIOD_NAME
            ,GL_PERIOD_NUM
            ,GL_PERIOD_YEAR
            ,GL_QUARTER_NUMBER
            ,GLOBAL_EXP_PERIOD_END_DATE
            ,GLOBAL_EXP_YEAR
            ,GLOBAL_EXP_MONTH_NUMBER
            ,AMOUNT_TYPE_ID
            ,PERIOD_BALANCE
            ,OBJECT_ID
            ,VERSION_ID
            ,OBJECT_TYPE_CODE
            ,BALANCE_TYPE_CODE
            ,EXPENDITURE_ORG_ID
            ,PERIOD_TYPE
            ,PERIOD_SET_NAME
            ,PERIOD_NAME
            ,PERIOD_NUM
            ,PERIOD_YEAR
            ,QUARTER_OR_MONTH_NUMBER
            ,UNIT_OF_MEASURE
            ,SUMM_LEVEL_FLAG
            ,PROCESS_MODE_FLAG)
        SELECT 'TMP1',
               EXPENDITURE_ORGANIZATION_ID,
               PERSON_ID,
               ASSIGNMENT_ID,
               WORK_TYPE_ID,
               ORG_UTIL_CATEGORY_ID,
               RES_UTIL_CATEGORY_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               PA_PERIOD_NAME,
               PA_PERIOD_NUM,
               PA_PERIOD_YEAR,
               PA_QUARTER_NUMBER,
               GL_PERIOD_NAME,
               GL_PERIOD_NUM,
               GL_PERIOD_YEAR,
               GL_QUARTER_NUMBER,
               GLOBAL_EXP_PERIOD_END_DATE,
               GLOBAL_EXP_YEAR,
               GLOBAL_EXP_MONTH_NUMBER,
               l_tot_prov_hrs_id,
               TOTAL_PROV_HOURS,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'N',
               'NN'
         FROM  pa_rep_util_summ0_tmp
         WHERE DELETE_FLAG     = 'N'
         AND   TOTAL_PROV_HOURS <> 0;
      END IF;

      /*
       * Populate pa_rep_util_summ_tmp for Total Weighted Hours - People.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Weighted Hours-People';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_wght_hrs_people_id,
             TOTAL_WGHTED_HOURS_PEOPLE,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE DELETE_FLAG     = 'N'
       AND   TOTAL_WGHTED_HOURS_PEOPLE <> 0;

      /*
       * Populate pa_rep_util_summ_tmp for Total Weighted Hours -Organization.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Weighted Hours-Org';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_wght_hrs_org_id,
             TOTAL_WGHTED_HOURS_ORG,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE DELETE_FLAG     = 'N'
       AND   TOTAL_WGHTED_HOURS_ORG <> 0;

      IF (l_balance_type_code <> l_actual_c) THEN
        /*
         * Populate pa_rep_util_summ_tmp for Prov Weighted Hours -People.
         */
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Weighted Hours-People';
        PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
	END IF;

        INSERT INTO pa_rep_util_summ_tmp
         (  RECORD_TYPE
            ,EXPENDITURE_ORGANIZATION_ID
            ,PERSON_ID
            ,ASSIGNMENT_ID
            ,WORK_TYPE_ID
            ,ORG_UTIL_CATEGORY_ID
            ,RES_UTIL_CATEGORY_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_TYPE_CLASS
            ,PA_PERIOD_NAME
            ,PA_PERIOD_NUM
            ,PA_PERIOD_YEAR
            ,PA_QUARTER_NUMBER
            ,GL_PERIOD_NAME
            ,GL_PERIOD_NUM
            ,GL_PERIOD_YEAR
            ,GL_QUARTER_NUMBER
            ,GLOBAL_EXP_PERIOD_END_DATE
            ,GLOBAL_EXP_YEAR
            ,GLOBAL_EXP_MONTH_NUMBER
            ,AMOUNT_TYPE_ID
            ,PERIOD_BALANCE
            ,OBJECT_ID
            ,VERSION_ID
            ,OBJECT_TYPE_CODE
            ,BALANCE_TYPE_CODE
            ,EXPENDITURE_ORG_ID
            ,PERIOD_TYPE
            ,PERIOD_SET_NAME
            ,PERIOD_NAME
            ,PERIOD_NUM
            ,PERIOD_YEAR
            ,QUARTER_OR_MONTH_NUMBER
            ,UNIT_OF_MEASURE
            ,SUMM_LEVEL_FLAG
            ,PROCESS_MODE_FLAG)
        SELECT 'TMP1',
               EXPENDITURE_ORGANIZATION_ID,
               PERSON_ID,
               ASSIGNMENT_ID,
               WORK_TYPE_ID,
               ORG_UTIL_CATEGORY_ID,
               RES_UTIL_CATEGORY_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               PA_PERIOD_NAME,
               PA_PERIOD_NUM,
               PA_PERIOD_YEAR,
               PA_QUARTER_NUMBER,
               GL_PERIOD_NAME,
               GL_PERIOD_NUM,
               GL_PERIOD_YEAR,
               GL_QUARTER_NUMBER,
               GLOBAL_EXP_PERIOD_END_DATE,
               GLOBAL_EXP_YEAR,
               GLOBAL_EXP_MONTH_NUMBER,
               l_prov_wght_hrs_people_id,
               PROV_WGHTED_HOURS_PEOPLE,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'N',
               'NN'
         FROM  pa_rep_util_summ0_tmp
         WHERE DELETE_FLAG     = 'N'
         AND   PROV_WGHTED_HOURS_PEOPLE <> 0;

     /*
      * Populate pa_rep_util_summ_tmp for Prov Weighted Hours -Organization.
      */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Weighted Hours-Org';
     PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
     END IF;

     INSERT INTO pa_rep_util_summ_tmp
         (  RECORD_TYPE
            ,EXPENDITURE_ORGANIZATION_ID
            ,PERSON_ID
            ,ASSIGNMENT_ID
            ,WORK_TYPE_ID
            ,ORG_UTIL_CATEGORY_ID
            ,RES_UTIL_CATEGORY_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_TYPE_CLASS
            ,PA_PERIOD_NAME
            ,PA_PERIOD_NUM
            ,PA_PERIOD_YEAR
            ,PA_QUARTER_NUMBER
            ,GL_PERIOD_NAME
            ,GL_PERIOD_NUM
            ,GL_PERIOD_YEAR
            ,GL_QUARTER_NUMBER
            ,GLOBAL_EXP_PERIOD_END_DATE
            ,GLOBAL_EXP_YEAR
            ,GLOBAL_EXP_MONTH_NUMBER
            ,AMOUNT_TYPE_ID
            ,PERIOD_BALANCE
            ,OBJECT_ID
            ,VERSION_ID
            ,OBJECT_TYPE_CODE
            ,BALANCE_TYPE_CODE
            ,EXPENDITURE_ORG_ID
            ,PERIOD_TYPE
            ,PERIOD_SET_NAME
            ,PERIOD_NAME
            ,PERIOD_NUM
            ,PERIOD_YEAR
            ,QUARTER_OR_MONTH_NUMBER
            ,UNIT_OF_MEASURE
            ,SUMM_LEVEL_FLAG
            ,PROCESS_MODE_FLAG)
        SELECT 'TMP1',
               EXPENDITURE_ORGANIZATION_ID,
               PERSON_ID,
               ASSIGNMENT_ID,
               WORK_TYPE_ID,
               ORG_UTIL_CATEGORY_ID,
               RES_UTIL_CATEGORY_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               PA_PERIOD_NAME,
               PA_PERIOD_NUM,
               PA_PERIOD_YEAR,
               PA_QUARTER_NUMBER,
               GL_PERIOD_NAME,
               GL_PERIOD_NUM,
               GL_PERIOD_YEAR,
               GL_QUARTER_NUMBER,
               GLOBAL_EXP_PERIOD_END_DATE,
               GLOBAL_EXP_YEAR,
               GLOBAL_EXP_MONTH_NUMBER,
               l_prov_wght_hrs_org_id,
               PROV_WGHTED_HOURS_ORG,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'N',
               'NN'
         FROM  pa_rep_util_summ0_tmp
         WHERE DELETE_FLAG     = 'N'
         AND   PROV_WGHTED_HOURS_ORG <> 0;

      END IF;
      /*
       * Populate pa_rep_util_summ_tmp for Reduce Capacity.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Reduce Capacity';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_red_cap_id,
             REDUCE_CAPACITY,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE DELETE_FLAG     = 'N'
       AND   REDUCE_CAPACITY <> 0;

    ELSE
      /*
       * Here we process all records of pa_rep_util_summ0_tmp.
       */

      /*
       * Populate pa_rep_util_summ_tmp for Total Hours.
       */

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Hours ';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG
          )
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_hrs_id,
             TOTAL_HOURS,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE TOTAL_HOURS     <> 0;


      IF (l_balance_type_code <> l_actual_c) THEN
        /*
         * Populate pa_rep_util_summ_tmp for Total Provisional Hours.
         */
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Hours';
         PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
	 END IF;

         INSERT INTO pa_rep_util_summ_tmp
          (  RECORD_TYPE
             ,EXPENDITURE_ORGANIZATION_ID
             ,PERSON_ID
             ,ASSIGNMENT_ID
             ,WORK_TYPE_ID
             ,ORG_UTIL_CATEGORY_ID
             ,RES_UTIL_CATEGORY_ID
             ,EXPENDITURE_TYPE
             ,EXPENDITURE_TYPE_CLASS
             ,PA_PERIOD_NAME
             ,PA_PERIOD_NUM
             ,PA_PERIOD_YEAR
             ,PA_QUARTER_NUMBER
             ,GL_PERIOD_NAME
             ,GL_PERIOD_NUM
             ,GL_PERIOD_YEAR
             ,GL_QUARTER_NUMBER
             ,GLOBAL_EXP_PERIOD_END_DATE
             ,GLOBAL_EXP_YEAR
             ,GLOBAL_EXP_MONTH_NUMBER
             ,AMOUNT_TYPE_ID
             ,PERIOD_BALANCE
             ,OBJECT_ID
             ,VERSION_ID
             ,OBJECT_TYPE_CODE
             ,BALANCE_TYPE_CODE
             ,EXPENDITURE_ORG_ID
             ,PERIOD_TYPE
             ,PERIOD_SET_NAME
             ,PERIOD_NAME
             ,PERIOD_NUM
             ,PERIOD_YEAR
             ,QUARTER_OR_MONTH_NUMBER
             ,UNIT_OF_MEASURE
             ,SUMM_LEVEL_FLAG
             ,PROCESS_MODE_FLAG)
         SELECT 'TMP1',
                EXPENDITURE_ORGANIZATION_ID,
                PERSON_ID,
                ASSIGNMENT_ID,
                WORK_TYPE_ID,
                ORG_UTIL_CATEGORY_ID,
                RES_UTIL_CATEGORY_ID,
                EXPENDITURE_TYPE,
                EXPENDITURE_TYPE_CLASS,
                PA_PERIOD_NAME,
                PA_PERIOD_NUM,
                PA_PERIOD_YEAR,
                PA_QUARTER_NUMBER,
                GL_PERIOD_NAME,
                GL_PERIOD_NUM,
                GL_PERIOD_YEAR,
                GL_QUARTER_NUMBER,
                GLOBAL_EXP_PERIOD_END_DATE,
                GLOBAL_EXP_YEAR,
                GLOBAL_EXP_MONTH_NUMBER,
                l_tot_prov_hrs_id,
                TOTAL_PROV_HOURS,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                'NN'
          FROM  pa_rep_util_summ0_tmp
          WHERE TOTAL_PROV_HOURS <> 0;

      END IF;

      /*
       * Populate pa_rep_util_summ_tmp for Total Weighted Hours - People.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Weighted Hours-People';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_wght_hrs_people_id,
             TOTAL_WGHTED_HOURS_PEOPLE,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE TOTAL_WGHTED_HOURS_PEOPLE <> 0;

      /*
       * Populate pa_rep_util_summ_tmp for Total Weighted Hours -Organization.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Weighted Hours-Org';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;
      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_tot_wght_hrs_org_id,
             TOTAL_WGHTED_HOURS_ORG,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE TOTAL_WGHTED_HOURS_ORG <> 0;

      IF (l_balance_type_code <> l_actual_c) THEN

        /*
         * Populate pa_rep_util_summ_tmp for Prov Weighted Hours -People.
         */
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Weighted Hours-People';
        PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
	END IF;

        INSERT INTO pa_rep_util_summ_tmp
         (  RECORD_TYPE
            ,EXPENDITURE_ORGANIZATION_ID
            ,PERSON_ID
            ,ASSIGNMENT_ID
            ,WORK_TYPE_ID
            ,ORG_UTIL_CATEGORY_ID
            ,RES_UTIL_CATEGORY_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_TYPE_CLASS
            ,PA_PERIOD_NAME
            ,PA_PERIOD_NUM
            ,PA_PERIOD_YEAR
            ,PA_QUARTER_NUMBER
            ,GL_PERIOD_NAME
            ,GL_PERIOD_NUM
            ,GL_PERIOD_YEAR
            ,GL_QUARTER_NUMBER
            ,GLOBAL_EXP_PERIOD_END_DATE
            ,GLOBAL_EXP_YEAR
            ,GLOBAL_EXP_MONTH_NUMBER
            ,AMOUNT_TYPE_ID
            ,PERIOD_BALANCE
            ,OBJECT_ID
            ,VERSION_ID
            ,OBJECT_TYPE_CODE
            ,BALANCE_TYPE_CODE
            ,EXPENDITURE_ORG_ID
            ,PERIOD_TYPE
            ,PERIOD_SET_NAME
            ,PERIOD_NAME
            ,PERIOD_NUM
            ,PERIOD_YEAR
            ,QUARTER_OR_MONTH_NUMBER
            ,UNIT_OF_MEASURE
            ,SUMM_LEVEL_FLAG
            ,PROCESS_MODE_FLAG)
        SELECT 'TMP1',
               EXPENDITURE_ORGANIZATION_ID,
               PERSON_ID,
               ASSIGNMENT_ID,
               WORK_TYPE_ID,
               ORG_UTIL_CATEGORY_ID,
               RES_UTIL_CATEGORY_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               PA_PERIOD_NAME,
               PA_PERIOD_NUM,
               PA_PERIOD_YEAR,
               PA_QUARTER_NUMBER,
               GL_PERIOD_NAME,
               GL_PERIOD_NUM,
               GL_PERIOD_YEAR,
               GL_QUARTER_NUMBER,
               GLOBAL_EXP_PERIOD_END_DATE,
               GLOBAL_EXP_YEAR,
               GLOBAL_EXP_MONTH_NUMBER,
               l_prov_wght_hrs_people_id,
               PROV_WGHTED_HOURS_PEOPLE,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'N',
               'NN'
         FROM  pa_rep_util_summ0_tmp
         WHERE PROV_WGHTED_HOURS_PEOPLE <> 0;

     /*
      * Populate pa_rep_util_summ_tmp for Prov Weighted Hours -Organization.
      */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp for Prov Weighted Hours-Org';
     PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
     END IF;

     INSERT INTO pa_rep_util_summ_tmp
         (  RECORD_TYPE
            ,EXPENDITURE_ORGANIZATION_ID
            ,PERSON_ID
            ,ASSIGNMENT_ID
            ,WORK_TYPE_ID
            ,ORG_UTIL_CATEGORY_ID
            ,RES_UTIL_CATEGORY_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_TYPE_CLASS
            ,PA_PERIOD_NAME
            ,PA_PERIOD_NUM
            ,PA_PERIOD_YEAR
            ,PA_QUARTER_NUMBER
            ,GL_PERIOD_NAME
            ,GL_PERIOD_NUM
            ,GL_PERIOD_YEAR
            ,GL_QUARTER_NUMBER
            ,GLOBAL_EXP_PERIOD_END_DATE
            ,GLOBAL_EXP_YEAR
            ,GLOBAL_EXP_MONTH_NUMBER
            ,AMOUNT_TYPE_ID
            ,PERIOD_BALANCE
            ,OBJECT_ID
            ,VERSION_ID
            ,OBJECT_TYPE_CODE
            ,BALANCE_TYPE_CODE
            ,EXPENDITURE_ORG_ID
            ,PERIOD_TYPE
            ,PERIOD_SET_NAME
            ,PERIOD_NAME
            ,PERIOD_NUM
            ,PERIOD_YEAR
            ,QUARTER_OR_MONTH_NUMBER
            ,UNIT_OF_MEASURE
            ,SUMM_LEVEL_FLAG
            ,PROCESS_MODE_FLAG)
        SELECT 'TMP1',
               EXPENDITURE_ORGANIZATION_ID,
               PERSON_ID,
               ASSIGNMENT_ID,
               WORK_TYPE_ID,
               ORG_UTIL_CATEGORY_ID,
               RES_UTIL_CATEGORY_ID,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               PA_PERIOD_NAME,
               PA_PERIOD_NUM,
               PA_PERIOD_YEAR,
               PA_QUARTER_NUMBER,
               GL_PERIOD_NAME,
               GL_PERIOD_NUM,
               GL_PERIOD_YEAR,
               GL_QUARTER_NUMBER,
               GLOBAL_EXP_PERIOD_END_DATE,
               GLOBAL_EXP_YEAR,
               GLOBAL_EXP_MONTH_NUMBER,
               l_prov_wght_hrs_org_id,
               PROV_WGHTED_HOURS_ORG,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'N',
               'NN'
         FROM  pa_rep_util_summ0_tmp
         WHERE PROV_WGHTED_HOURS_ORG <> 0;

      END IF;

      /*
       * Populate pa_rep_util_summ_tmp for Reduce Capacity.
       */
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage:='Populate pa_rep_util_summ_tmp for Reduce Capacity';
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;

      INSERT INTO pa_rep_util_summ_tmp
       (  RECORD_TYPE
          ,EXPENDITURE_ORGANIZATION_ID
          ,PERSON_ID
          ,ASSIGNMENT_ID
          ,WORK_TYPE_ID
          ,ORG_UTIL_CATEGORY_ID
          ,RES_UTIL_CATEGORY_ID
          ,EXPENDITURE_TYPE
          ,EXPENDITURE_TYPE_CLASS
          ,PA_PERIOD_NAME
          ,PA_PERIOD_NUM
          ,PA_PERIOD_YEAR
          ,PA_QUARTER_NUMBER
          ,GL_PERIOD_NAME
          ,GL_PERIOD_NUM
          ,GL_PERIOD_YEAR
          ,GL_QUARTER_NUMBER
          ,GLOBAL_EXP_PERIOD_END_DATE
          ,GLOBAL_EXP_YEAR
          ,GLOBAL_EXP_MONTH_NUMBER
          ,AMOUNT_TYPE_ID
          ,PERIOD_BALANCE
          ,OBJECT_ID
          ,VERSION_ID
          ,OBJECT_TYPE_CODE
          ,BALANCE_TYPE_CODE
          ,EXPENDITURE_ORG_ID
          ,PERIOD_TYPE
          ,PERIOD_SET_NAME
          ,PERIOD_NAME
          ,PERIOD_NUM
          ,PERIOD_YEAR
          ,QUARTER_OR_MONTH_NUMBER
          ,UNIT_OF_MEASURE
          ,SUMM_LEVEL_FLAG
          ,PROCESS_MODE_FLAG)
      SELECT 'TMP1',
             EXPENDITURE_ORGANIZATION_ID,
             PERSON_ID,
             ASSIGNMENT_ID,
             WORK_TYPE_ID,
             ORG_UTIL_CATEGORY_ID,
             RES_UTIL_CATEGORY_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_TYPE_CLASS,
             PA_PERIOD_NAME,
             PA_PERIOD_NUM,
             PA_PERIOD_YEAR,
             PA_QUARTER_NUMBER,
             GL_PERIOD_NAME,
             GL_PERIOD_NUM,
             GL_PERIOD_YEAR,
             GL_QUARTER_NUMBER,
             GLOBAL_EXP_PERIOD_END_DATE,
             GLOBAL_EXP_YEAR,
             GLOBAL_EXP_MONTH_NUMBER,
             l_red_cap_id,
             REDUCE_CAPACITY,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',
             'NN'
       FROM  pa_rep_util_summ0_tmp
       WHERE REDUCE_CAPACITY <> 0;

   END IF;

   /*
    * Step 2 - Populate PL/SQL Table after summarizing data from global temporary
    *          table pa_rep_util_summ_tmp based on setup.
    */

   /*
    * Summarization by PA period if enabled.
    */

   IF ( PA_REP_UTIL_GLOB.G_util_option_details.G_pa_period_flag = 'Y')
   THEN
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.g_err_stage:='Summarization By PA Period';
       PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
       END IF;

       INSERT INTO  pa_rep_util_summ_tmp
       (   record_type,
           object_id,
           version_id,
           period_type,
           period_set_name,
           period_name,
           global_exp_period_end_date,
           amount_type_id,
           unit_of_measure,
           period_balance,
           period_num,
           period_year,
           quarter_or_month_number,
           balance_type_code,
           object_type_code,
           expenditure_org_id,
           expenditure_organization_id,
           person_id,
           assignment_id,
           work_type_id,
           org_util_category_id,
           res_util_category_id,
           expenditure_type,
           expenditure_type_class,
           summ_level_flag,
           process_mode_flag,
           pa_period_name,
           pa_period_num,
           pa_period_year,
           pa_quarter_number,
           gl_period_name,
           gl_period_num,
           gl_period_year,
           gl_quarter_number,
           global_exp_year,
           global_exp_month_number)
       SELECT 'TMP1A',
              NULL,
              -1,
              l_pa_c,
--            l_period_set_name,
              l_pa_period_set_name, -- Bug 3434019
              PA_PERIOD_NAME,
              l_dummy_ge_date,
              AMOUNT_TYPE_ID,
              l_unit_of_measure,
              sum(PERIOD_BALANCE),
              MAX(PA_PERIOD_NUM),
              MAX(PA_PERIOD_YEAR),
              MAX(PA_QUARTER_NUMBER),
              l_balance_type_code,
              l_utildet_c,
              l_exp_org_id,
              EXPENDITURE_ORGANIZATION_ID,
              PERSON_ID,
              ASSIGNMENT_ID,
              WORK_TYPE_ID,
              ORG_UTIL_CATEGORY_ID,
              RES_UTIL_CATEGORY_ID,
              EXPENDITURE_TYPE,
              EXPENDITURE_TYPE_CLASS,
              'U',
              'II',
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL
         FROM  pa_rep_util_summ_tmp
-- mpuvathi: changed line below so that it is an FTS instead of an index scan
--         WHERE record_type = 'TMP1'
         WHERE process_mode_flag = 'NN'
         GROUP BY AMOUNT_TYPE_ID,PA_PERIOD_NAME,EXPENDITURE_ORGANIZATION_ID,
                  PERSON_ID,ASSIGNMENT_ID,WORK_TYPE_ID,ORG_UTIL_CATEGORY_ID,
                  RES_UTIL_CATEGORY_ID,EXPENDITURE_TYPE,EXPENDITURE_TYPE_CLASS;

   END IF;


   /*
    * Summarization by GL period if enabled.
    */

   IF ( PA_REP_UTIL_GLOB.G_util_option_details.G_gl_period_flag = 'Y')
   THEN
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.g_err_stage:='Summarization By GL Period';
       PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
       END IF;

       INSERT INTO  pa_rep_util_summ_tmp
       (   record_type,
           object_id,
           version_id,
           period_type,
           period_set_name,
           period_name,
           global_exp_period_end_date,
           amount_type_id,
           unit_of_measure,
           period_balance,
           period_num,
           period_year,
           quarter_or_month_number,
           balance_type_code,
           object_type_code,
           expenditure_org_id,
           expenditure_organization_id,
           person_id,
           assignment_id,
           work_type_id,
           org_util_category_id,
           res_util_category_id,
           expenditure_type,
           expenditure_type_class,
           summ_level_flag,
           process_mode_flag,
           pa_period_name,
           pa_period_num,
           pa_period_year,
           pa_quarter_number,
           gl_period_name,
           gl_period_num,
           gl_period_year,
           gl_quarter_number,
           global_exp_year,
           global_exp_month_number)
       SELECT 'TMP1A',
              NULL,
              -1,
              l_gl_c,
--            l_period_set_name,
              l_gl_period_set_name, -- Bug 3434019
              GL_PERIOD_NAME,
              l_dummy_ge_date,
              AMOUNT_TYPE_ID,
              l_unit_of_measure,
              sum(PERIOD_BALANCE),
              MAX(GL_PERIOD_NUM),
              MAX(GL_PERIOD_YEAR),
              MAX(GL_QUARTER_NUMBER),
              l_balance_type_code,
              l_utildet_c,
              l_exp_org_id,
              EXPENDITURE_ORGANIZATION_ID,
              PERSON_ID,
              ASSIGNMENT_ID,
              WORK_TYPE_ID,
              ORG_UTIL_CATEGORY_ID,
              RES_UTIL_CATEGORY_ID,
              EXPENDITURE_TYPE,
              EXPENDITURE_TYPE_CLASS,
              'U',
              'II',
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL
         FROM pa_rep_util_summ_tmp
-- mpuvathi: changed line below so that it is an FTS instead of an index scan
--         WHERE record_type = 'TMP1'
         WHERE process_mode_flag = 'NN'
         GROUP BY AMOUNT_TYPE_ID,GL_PERIOD_NAME,EXPENDITURE_ORGANIZATION_ID,
                  PERSON_ID,ASSIGNMENT_ID,WORK_TYPE_ID,ORG_UTIL_CATEGORY_ID,
                  RES_UTIL_CATEGORY_ID,EXPENDITURE_TYPE,EXPENDITURE_TYPE_CLASS;

   END IF;

   /*
    * Summarization by Global Expenditure week if enabled.
    */

   IF (PA_REP_UTIL_GLOB.G_util_option_details.G_ge_period_flag = 'Y')
   THEN
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.g_err_stage:='Summarization By GE Period';
       PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
       END IF;


       INSERT INTO  pa_rep_util_summ_tmp
       (   record_type,
           object_id,
           version_id,
           period_type,
           period_set_name,
           period_name,
           global_exp_period_end_date,
           amount_type_id,
           unit_of_measure,
           period_balance,
           period_num,
           period_year,
           quarter_or_month_number,
           balance_type_code,
           object_type_code,
           expenditure_org_id,
           expenditure_organization_id,
           person_id,
           assignment_id,
           work_type_id,
           org_util_category_id,
           res_util_category_id,
           expenditure_type,
           expenditure_type_class,
           summ_level_flag,
           process_mode_flag,
           pa_period_name,
           pa_period_num,
           pa_period_year,
           pa_quarter_number,
           gl_period_name,
           gl_period_num,
           gl_period_year,
           gl_quarter_number,
           global_exp_year,
           global_exp_month_number)
       SELECT 'TMP1A',
              NULL,
              -1,
              l_ge_c,
              l_dummy_period_set_name,
              l_dummy_period_name,
              GLOBAL_EXP_PERIOD_END_DATE,
              AMOUNT_TYPE_ID,
              l_unit_of_measure,
              sum(PERIOD_BALANCE),
              NULL,
              max(GLOBAL_EXP_YEAR),
              max(GLOBAL_EXP_MONTH_NUMBER),
              l_balance_type_code,
              l_utildet_c,
              l_exp_org_id,
              EXPENDITURE_ORGANIZATION_ID,
              PERSON_ID,
              ASSIGNMENT_ID,
              WORK_TYPE_ID,
              ORG_UTIL_CATEGORY_ID,
              RES_UTIL_CATEGORY_ID,
              EXPENDITURE_TYPE,
              EXPENDITURE_TYPE_CLASS,
              'U',
              'II',
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL
         FROM pa_rep_util_summ_tmp
-- mpuvathi: changed line below so that it is an FTS instead of an index scan
--         WHERE record_type = 'TMP1'
         WHERE process_mode_flag = 'NN'
         GROUP BY AMOUNT_TYPE_ID,GLOBAL_EXP_PERIOD_END_DATE,
                  EXPENDITURE_ORGANIZATION_ID,
                  PERSON_ID,ASSIGNMENT_ID,WORK_TYPE_ID,ORG_UTIL_CATEGORY_ID,
                  RES_UTIL_CATEGORY_ID,EXPENDITURE_TYPE,EXPENDITURE_TYPE_CLASS;
   END IF;

   PA_DEBUG.Reset_curr_function;

EXCEPTION
   WHEN OTHERS
   THEN
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
     raise;

END summarize_by_period;

PROCEDURE summarize_temp_data_by_res
IS
BEGIN
   /*
    * Summarize the lowlevel records to Resource level.
    */
   PA_DEBUG.set_curr_function('summarize_temp_data_by_res');
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Summarization at resource level';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO pa_rep_util_summ_tmp
      (   record_type,
          object_id,
          version_id,
          object_type_code,
          balance_type_code,
          expenditure_org_id,
          expenditure_organization_id,
          person_id,
          assignment_id,
          work_type_id,
          org_util_category_id,
          res_util_category_id,
          period_type,
          period_set_name,
          period_name,
          global_exp_period_end_date,
          period_year,
          quarter_or_month_number,
          unit_of_measure,
          amount_type_id,
          period_balance,
          period_num,
          expenditure_type,
          expenditure_type_class,
          summ_level_flag,
          process_mode_flag)
    SELECT 'TMP2',
           NULL,
           -1,
           decode(to_char(grouping(org_util_category_id))||
                  to_char(grouping(res_util_category_id))||
                  to_char(grouping(work_type_id)),
                  '111',l_res_c,  /* Expenditure Organization level */
                  '011',l_resuco_c,  /* Expenditure Organization ,
                                        Organization Utilization Level */
                  '101',l_resucr_c,  /* Expenditure Organization,
                                        Resource Utilization Level */
                  '000',l_reswt_c), /*  Expenditure Organization
                                        Organization Utilization
                                        Resource Utilization Level */
           l_balance_type_code,
           l_exp_org_id,
           expenditure_organization_id,
           person_id,
           -1,
           nvl(work_type_id,-1),
           nvl(org_util_category_id,-1),
           nvl(res_util_category_id,-1),
           period_type,
           max(period_set_name),
           period_name,
           global_exp_period_end_date,
           max(period_year),
           max(quarter_or_month_number),
           l_unit_of_measure,
           amount_type_id,
           sum(period_balance),
           max(period_num),
           NULL,
           NULL,
           decode(to_char(grouping(org_util_category_id))||
                  to_char(grouping(res_util_category_id))||
                  to_char(grouping(work_type_id)),
                  '111','Q',  /* Expenditure Organization level */
                  '011','P',  /* Expenditure Organization ,
                                 Organization Utilization Level */
                  '101','P',  /* Expenditure Organization,
                                 Resource Utilization Level */
                  '000','R'), /*  Expenditure Organization
                                 Organization Utilization
                                 Resource Utilization Level */
            'II'
       from  pa_rep_util_summ_tmp
       WHERE record_type = 'TMP1A'
       AND   process_mode_flag = 'II'
       AND   summ_level_flag = 'U'
AND ASSIGNMENT_ID IS NOT NULL     /*bug#8344802*/
       group by period_type,
                period_name,
                global_exp_period_end_date,
                amount_type_id,
                expenditure_organization_id,
                person_id,
                cube(org_util_category_id,
                     res_util_category_id,
                     work_type_id)
        having (to_char(grouping(org_util_category_id))||
                to_char(grouping(res_util_category_id))||
                to_char(grouping(work_type_id)))
        in ( '111','011', '101', '000');

   PA_DEBUG.Reset_curr_function;

EXCEPTION
   WHEN OTHERS
   THEN
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
        PA_DEBUG.log_message(SQLERRM);
	END IF;
        raise;
END summarize_temp_data_by_res;

/*
 * Insert Records for Utilization Capacity.
 */
PROCEDURE populate_tmp_for_capacity
IS

   CURSOR capacity_api_input_cur(p_start_date DATE,p_end_date DATE)
   IS
    SELECT distinct
		   resource_organization_id
		   , person_id
		   , resource_id
		   , resource_effective_start_date
		   , resource_effective_end_date
    FROM  pa_resources_denorm
    WHERE resource_org_id = PA_REP_UTIL_GLOB.GetOrgId
    AND   utilization_flag = 'Y'
    AND   (
            (RESOURCE_EFFECTIVE_START_DATE BETWEEN p_start_date AND p_end_date)
          OR
            (RESOURCE_EFFECTIVE_END_DATE   BETWEEN p_start_date AND p_end_date)
          OR
            (p_start_date BETWEEN RESOURCE_EFFECTIVE_START_DATE AND RESOURCE_EFFECTIVE_END_DATE)
          );


   /*
    * Define PL/SQL Table for input and return values.
    */
    l_in_exp_orgz_tab       PA_PLSQL_DATATYPES.IdTabTyp;
    l_in_person_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
    l_in_resource_id_tab    PA_PLSQL_DATATYPES.IdTabTyp;
    l_in_res_eff_s_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
    l_in_res_eff_e_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
    l_out_exp_orgz_tab      PA_PLSQL_DATATYPES.IdTabTyp;
    l_out_person_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
    l_period_type_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
    l_period_name_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
    l_global_exp_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
    l_period_year_tab       PA_PLSQL_DATATYPES.NumTabTyp;
    l_qm_number_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_period_num_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_period_balance_tab    PA_PLSQL_DATATYPES.NumTabTyp;

   /*
    * Define other variable to be used in this procedure
    */
    l_return_status         VARCHAR2(10);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(240);
    I                       PLS_INTEGER;
    l_last_fetch            VARCHAR2(1):='N';
    l_this_fetch            NUMBER:=0;
    l_totally_fetched       NUMBER:=0;
    l_run_start_date        DATE;
    l_run_end_date          DATE;
--  l_period_set_name       VARCHAR2(15) := PA_REP_UTIL_GLOB.GetPeriodSetName;
    l_gl_period_set_name    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_implementation_details.G_gl_period_set_name; -- Bug 3434019
    l_pa_period_set_name    VARCHAR2(15) := PA_REP_UTIL_GLOB.G_implementation_details.G_pa_period_set_name; -- Bug 3434019
    l_gl_c  VARCHAR2(3) := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_GL_C; -- Bug 3434019
    l_pa_c  VARCHAR2(3) := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_PA_C; -- Bug 3434019

BEGIN


   PA_DEBUG.set_curr_function('populate_tmp_for_capacity');
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Setting the start and end dates of the run';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;
    /*
     * First figure out which balance_type is the current call for so as
     * to set the appropriate start and end dates for the run
     */
     IF l_balance_type_code = PA_REP_UTIL_GLOB.GetBalTypeActuals  then
            l_run_start_date := PA_REP_UTIL_GLOB.G_input_parameters.G_ac_start_date;
            l_run_end_date   := PA_REP_UTIL_GLOB.G_input_parameters.G_ac_end_date;
     ELSIF l_balance_type_code = PA_REP_UTIL_GLOB.GetBalTypeForecast  then
            l_run_start_date := PA_REP_UTIL_GLOB.G_input_parameters.G_fc_start_date;
            l_run_end_date   := PA_REP_UTIL_GLOB.G_input_parameters.G_fc_end_date;
     END IF;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Opening the Cursor';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   OPEN capacity_api_input_cur(l_run_start_date,l_run_end_date);

   LOOP

    /*
     * Clear all PL/SQL table.
     */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Clearing PL/SQL Table';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

    l_in_exp_orgz_tab.delete;
    l_in_person_id_tab.delete;
    l_in_resource_id_tab.delete;
    l_in_res_eff_s_date_tab.delete;
    l_in_res_eff_e_date_tab.delete;
    l_out_exp_orgz_tab.delete;
    l_out_person_id_tab.delete;
    l_period_type_tab.delete;
    l_period_name_tab.delete;
    l_global_exp_date_tab.delete;
    l_period_year_tab.delete;
    l_qm_number_tab.delete;
    l_period_num_tab.delete;
    l_period_balance_tab.delete;

    /*
     * Fetch 100 records at a time.
     */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Fetching 100 records at a time in PL/SQL Table';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

    FETCH capacity_api_input_cur  BULK COLLECT
    INTO l_in_exp_orgz_tab
         , l_in_person_id_tab
         , l_in_resource_id_tab
         , l_in_res_eff_s_date_tab
         , l_in_res_eff_e_date_tab  LIMIT 100;


    /*
     *  To check the rows fetched in this fetch
     */
      l_this_fetch := capacity_api_input_cur%ROWCOUNT - l_totally_fetched;
      l_totally_fetched := capacity_api_input_cur%ROWCOUNT;

    /*
     *  Check if this fetch has 0 rows returned (ie last fetch was even 100)
     *  This could happen in 2 cases
     *      1) this fetch is the very first fetch with 0 rows returned
     *   OR 2) the last fetch returned an even 100 rows
     *  If either then EXIT without any processing
     */
        IF  l_this_fetch = 0 then
                EXIT;
        END IF;

    /*
     *  Check if this fetch is the last fetch
     *  If so then set the flag l_last_fetch so as to exit after processing
     */
        IF  l_this_fetch < 100  then
              l_last_fetch := 'Y';
        ELSE
              l_last_fetch := 'N';
        END IF;


    /*
     * Call CV's API in loop get value.
     */
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Calling Capacity API for 100 records at a time';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

    PA_FORECAST_GRC_PVT.Get_Capacity_Vector(
                        p_OU_id                   => l_exp_org_id
                        , p_exp_org_id_tab        => l_in_exp_orgz_tab
                        , p_person_id_tab         => l_in_person_id_tab
                        , p_resource_id_tab       => l_in_resource_id_tab
                        , p_in_res_eff_s_date_tab => l_in_res_eff_s_date_tab
                        , p_in_res_eff_e_date_tab => l_in_res_eff_e_date_tab
                        , p_balance_type_code     => l_balance_type_code
                        , p_run_start_date        => l_run_start_date
                        , p_run_end_date          => l_run_end_date
                        , x_resource_capacity_tab => l_period_balance_tab
                        , x_exp_orgz_id_tab       => l_out_exp_orgz_tab
                        , x_person_id_tab         => l_out_person_id_tab
                        , x_period_type_tab       => l_period_type_tab
                        , x_period_name_tab       => l_period_name_tab
                        , x_global_exp_date_tab   => l_global_exp_date_tab
                        , x_period_year_tab       => l_period_year_tab
                        , x_qm_number_tab         => l_qm_number_tab
                        , x_period_num_tab        => l_period_num_tab
                        , x_return_status         => l_return_status
                        , x_msg_count             => l_msg_count
                        , x_msg_data              => l_msg_data);

IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Inserting Records into pa_rep_util_summ_tmp for capacity';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

    FORALL I in l_out_person_id_tab.FIRST..l_out_person_id_tab.LAST
      INSERT INTO pa_rep_util_summ_tmp
        (   record_type,
            object_id,
            version_id,
            object_type_code,
            balance_type_code,
            expenditure_org_id,
            expenditure_organization_id,
            person_id,
            assignment_id,
            work_type_id,
            org_util_category_id,
            res_util_category_id,
            period_type,
            period_set_name,
            period_name,
            global_exp_period_end_date,
            period_year,
            quarter_or_month_number,
            unit_of_measure,
            amount_type_id,
            period_balance,
            period_num,
            expenditure_type,
            expenditure_type_class,
            summ_level_flag,
            process_mode_flag)
       VALUES (
            'TMP2',
            NULL,
            -1,
            l_res_c,
            l_balance_type_code,
            l_exp_org_id,
            l_out_exp_orgz_tab(I),
            l_out_person_id_tab(I),
            -1,
            -1,
            -1,
            -1,
            l_period_type_tab(I),
--          DECODE(l_period_name_tab(I)
--                 , l_dummy_period_name, l_dummy_period_set_name
--                 , l_period_set_name) ,
            DECODE(l_period_name_tab(I)
                   , l_dummy_period_name, l_dummy_period_set_name, decode(l_period_type_tab(I), l_gl_c
                   , l_gl_period_set_name, l_pa_period_set_name) ), -- Bug 3434019
            l_period_name_tab(I),
            l_global_exp_date_tab(I),
            l_period_year_tab(I),
            l_qm_number_tab(I),
            l_unit_of_measure,
            l_tot_cap_id,
            l_period_balance_tab(I),
            l_period_num_tab(I),
            NULL,
            NULL,
            'S',
            'II');

    /*
     *  Check if this loop is the last set of 100
     *  If so then EXIT;
     */
        IF l_last_fetch='Y' THEN
               EXIT;
        END IF;

   END LOOP;
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Closing the cursor';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   CLOSE capacity_api_input_cur;

   PA_DEBUG.Reset_curr_function;

EXCEPTION
   WHEN OTHERS
   THEN
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
      raise;
END populate_tmp_for_capacity;


/*
 * Summarize the resource level records to Organization level.
 */
PROCEDURE summarize_temp_data_by_org
IS
BEGIN
   PA_DEBUG.set_curr_function('PA_REP_UTILS_SUMM_PKG.summarize_temp_data_by_org');
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Summarizing at Organization level';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO pa_rep_util_summ_tmp
      (   record_type,
          object_id,
          version_id,
          object_type_code,
          balance_type_code,
          expenditure_org_id,
          expenditure_organization_id,
          person_id,
          assignment_id,
          work_type_id,
          org_util_category_id,
          res_util_category_id,
          period_type,
          period_set_name,
          period_name,
          global_exp_period_end_date,
          period_year,
          quarter_or_month_number,
          unit_of_measure,
          amount_type_id,
          period_balance,
          period_num,
          expenditure_type,
          expenditure_type_class,
          summ_level_flag,
          process_mode_flag)
    SELECT 'TMP2',
           NULL,
           -1,
           decode(grouping(org_util_category_id)||grouping(work_type_id),
                  '11',l_org_c,
                  '01',l_orguc_c,
                  '00',l_orgwt_c),
           l_balance_type_code,
           l_exp_org_id,
           expenditure_organization_id,
           -1,
           -1,
           nvl(work_type_id,-1),
           nvl(org_util_category_id,-1),
           -1,
           period_type,
--         DECODE(period_type
--                , l_ge_c, l_dummy_period_set_name
--                , l_period_set_name) ,
           DECODE(period_type
                  , l_ge_c, l_dummy_period_set_name, l_gl_c, l_gl_period_set_name
                  , l_pa_period_set_name) , -- Bug 3434019
           period_name,
           global_exp_period_end_date,
           max(period_year),
           max(quarter_or_month_number),
           l_unit_of_measure,
           /*
            * Convert the Utilization and resource level amount type
            * to Direct organization level amount types.
            */
           decode(amount_type_id,l_tot_hrs_id,l_dirct_tot_hrs_id,
                         l_tot_prov_hrs_id,l_dirct_tot_prov_hrs_id,
                         l_tot_wght_hrs_org_id,l_dirct_tot_wght_hrs_org_id,
                         l_prov_wght_hrs_org_id,l_dirct_prov_wght_hrs_org_id,
                         l_red_cap_id,l_dirct_reduce_cap_id,
                         l_tot_cap_id,l_dirct_cap_id),
           sum(period_balance),
           max(period_num),
           NULL,
           NULL,
           'O',
           'II'
       from  pa_rep_util_summ_tmp
       where summ_level_flag in ( 'R','S')
       and   record_type = 'TMP2'
       and   process_mode_flag = 'II'
       and   amount_type_id not in (l_tot_wght_hrs_people_id,
                                    l_prov_wght_hrs_people_id)
       group by period_type,
                period_name,
                global_exp_period_end_date,
                amount_type_id,
                expenditure_organization_id,
                summ_level_flag,
                rollup(org_util_category_id,
                       work_type_id)
       having ((summ_level_flag = 'S'
          and grouping(org_util_category_id)||grouping(work_type_id) = '11')
          or  ( summ_level_flag = 'R'));

       PA_DEBUG.Reset_curr_function;

EXCEPTION
   WHEN OTHERS
   THEN
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
      raise;
END summarize_temp_data_by_org;

/** This procedure will  find the object Id for each record of
    pa_rep_util_summ_tmp with record type = 'TMP2' and process_mode_flag = 'II'
	and populate it.  If not found, generate an object id **/


PROCEDURE populate_object_entity IS

BEGIN

   PA_DEBUG.set_curr_function('PA_REP_UTILS_SUMM_PKG.summarize_temp_data_by_org');

   /*
    * Update the pa_rep_util_summ_tmp with matching object Id.
    */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Update pa_rep_util_summ_tmp with matching object Id';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   UPDATE pa_rep_util_summ_tmp T
   SET    (T.object_id,T.process_mode_flag)
                     = ( select OB.object_id ,'UI'
                         from   pa_objects OB
                         where  OB.OBJECT_TYPE_CODE   = T.OBJECT_TYPE_CODE
                         and    OB.BALANCE_TYPE_CODE  = T.BALANCE_TYPE_CODE
                         and    OB.EXPENDITURE_ORG_ID = T.EXPENDITURE_ORG_ID
                         and    OB.EXPENDITURE_ORGANIZATION_ID
                                = T.EXPENDITURE_ORGANIZATION_ID
                         and    OB.PERSON_ID          = T.PERSON_ID
                         and    OB.ASSIGNMENT_ID      = T.ASSIGNMENT_ID
                         and    OB.WORK_TYPE_ID       = T.WORK_TYPE_ID
                         and    OB.ORG_UTIL_CATEGORY_ID
                                = T.ORG_UTIL_CATEGORY_ID
                         and    OB.RES_UTIL_CATEGORY_ID
                                = T.RES_UTIL_CATEGORY_ID
                         and    nvl(OB.EXPENDITURE_TYPE,'-1')
                                = nvl(T.EXPENDITURE_TYPE,'-1')
                         and    nvl(OB.EXPENDITURE_TYPE_CLASS,'-1')
                                = nvl(T.EXPENDITURE_TYPE_CLASS,'-1')
                         and    OB.PROJECT_ORG_ID          = -1
                         and    OB.PROJECT_ORGANIZATION_ID = -1
                         and    OB.PROJECT_ID              = -1
                         and    OB.TASK_ID                 = -1)
   WHERE   T.record_type    = 'TMP2'
-- mpuvathi: since all are 'II' till now
   AND     T.process_mode_flag = 'II'
   ;

   /*
    * Populate pa_rep_util_summ_tmp with unique key for pa_objects.
    */
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Populate pa_rep_util_summ_tmp with unique key for pa_objects';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO pa_rep_util_summ_tmp
      (   record_type,
          object_id,
          version_id,
          object_type_code,
          balance_type_code,
          expenditure_org_id,
          expenditure_organization_id,
          person_id,
          assignment_id,
          work_type_id,
          org_util_category_id,
          res_util_category_id,
          period_type,
          period_set_name,
          period_name,
          global_exp_period_end_date,
          period_year,
          quarter_or_month_number,
          unit_of_measure,
          amount_type_id,
          period_balance,
          period_num,
          expenditure_type,
          expenditure_type_class,
          summ_level_flag,
          process_mode_flag)
    SELECT 'TMP3',
           pa_objects_s.nextval,
           NULL,
           T1.object_type_code,
           T1.balance_type_code,
           T1.expenditure_org_id,
           T1.expenditure_organization_id,
           T1.person_id,
           T1.assignment_id,
           T1.work_type_id,
           T1.org_util_category_id,
           T1.res_util_category_id,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           T1.expenditure_type,
           T1.expenditure_type_class,
           'H',
           'HH'
     FROM  pa_rep_util_summ_tmp T1
     WHERE T1.record_type = 'TMP2'
-- mpuvathi: since even process_mode_flag would have been updated to NULL
     AND   T1.process_mode_flag is NULL
     AND   T1.object_id  IS NULL
     AND   T1.rowid      in (SELECT max(T2.rowid)
                             FROM   pa_rep_util_summ_tmp T2
-- mpuvathi: since even process_mode_flag would have been updated to NULL
                             WHERE  T2.process_mode_flag is NULL
                             AND    T2.object_id  IS NULL
                             AND    T2.record_type = 'TMP2'
                             GROUP BY
                                     T2.OBJECT_TYPE_CODE
                                   , T2.BALANCE_TYPE_CODE
                                   , T2.EXPENDITURE_ORGANIZATION_ID
                                   , T2.PERSON_ID
                                   , T2.ASSIGNMENT_ID
                                   , T2.WORK_TYPE_ID
                                   , T2.ORG_UTIL_CATEGORY_ID
                                   , T2.RES_UTIL_CATEGORY_ID
                               )
;


   /*
    * Populate the other records of pa_rep_util_summ_tmp with
    * record type = 'TMP2' and null object Id.
    */
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Populate the other records of pa_rep_util_summ_tmp with record type =TMP2 and null object Id';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   UPDATE  pa_rep_util_summ_tmp T1
   SET     (T1.object_id ,
            T1.process_mode_flag) = ( SELECT T2.object_id,'II'
                                      FROM   pa_rep_util_summ_tmp T2
                                      WHERE  T1.OBJECT_TYPE_CODE
                                        = T2.OBJECT_TYPE_CODE
                                      AND    T1.BALANCE_TYPE_CODE
                                        = T2.BALANCE_TYPE_CODE
                                      AND    T1.EXPENDITURE_ORGANIZATION_ID
                                        = T2.EXPENDITURE_ORGANIZATION_ID
                                      AND    T1.PERSON_ID      = T2.PERSON_ID
--                                      AND    T1.ASSIGNMENT_ID  = T2.ASSIGNMENT_ID
                                      AND    T1.WORK_TYPE_ID   = T2.WORK_TYPE_ID
                                      AND    T1.ORG_UTIL_CATEGORY_ID
                                        = T2.ORG_UTIL_CATEGORY_ID
                                      AND    T1.RES_UTIL_CATEGORY_ID
                                        = T2.RES_UTIL_CATEGORY_ID
--                                      AND    nvl(T1.EXPENDITURE_TYPE,'-1') = nvl(T2.EXPENDITURE_TYPE,'-1')
--                                      AND    nvl(T1.EXPENDITURE_TYPE_CLASS,'-1') = nvl(T2.EXPENDITURE_TYPE_CLASS,'-1')
                                      AND    T2.record_type = 'TMP3'
									  AND    T2.process_mode_flag = 'HH'
									)
   WHERE   T1.record_type       = 'TMP2'
-- mpuvathi: since even process_mode_flag would have been updated to NULL
   AND     T1.process_mode_flag is NULL
--   AND     nvl(T1.process_mode_flag,'II') <> 'UI'
   AND     T1.object_id         IS NULL
   ;


   /*
    * Insert New Objects in PA_OBJECTS.
    */
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Insert New Objects in PA_OBJECTS';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO PA_OBJECTS
   (  OBJECT_ID,
      OBJECT_TYPE_CODE,
      BALANCE_TYPE_CODE,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ID,
      TASK_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      PERSON_ID,
      ASSIGNMENT_ID,
      WORK_TYPE_ID,
      ORG_UTIL_CATEGORY_ID,
      RES_UTIL_CATEGORY_ID,
      EXPENDITURE_TYPE,
      EXPENDITURE_TYPE_CLASS,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE)
  SELECT  OBJECT_ID,
          OBJECT_TYPE_CODE,
          BALANCE_TYPE_CODE,
          -1,
          -1,
          -1,
          -1,
          l_exp_org_id,
          EXPENDITURE_ORGANIZATION_ID,
          PERSON_ID,
          ASSIGNMENT_ID,
          WORK_TYPE_ID,
          ORG_UTIL_CATEGORY_ID,
          RES_UTIL_CATEGORY_ID,
          EXPENDITURE_TYPE,
          EXPENDITURE_TYPE_CLASS,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login,
          l_request_id,
          l_program_application_id,
          l_program_id,
          l_creation_date
    FROM  pa_rep_util_summ_tmp
    WHERE record_type   = 'TMP3'
    AND   summ_level_flag = 'H'
    AND   process_mode_flag = 'HH'
	AND   object_type_code <> l_utildet_c
    ;

    PA_DEBUG.Reset_curr_function;

EXCEPTION
   WHEN OTHERS
   THEN
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
        raise;
END populate_object_entity;

/*
 * This procedure checks whether any matching record exists in
 * PA_SUMM_BALANCES, if yes, it will update the record. If no,it
 * will insert a new record in PA_SUMM_BALANCES.
 */

PROCEDURE populate_balance_entity IS

   /*
    * Define PL/SQL Table for holding the fetched records from the cursor
    * before inserting into the global temporary table pa_rep_util_summ0_tmp
    */
          L_PERIOD_BALANCE_TAB          PA_PLSQL_DATATYPES.NumTabTyp;
          L_OBJECT_ID_TAB               PA_PLSQL_DATATYPES.IdTabTyp;
          L_VERSION_ID_TAB              PA_PLSQL_DATATYPES.IdTabTyp;
          L_OBJECT_TYPE_CODE_TAB        PA_PLSQL_DATATYPES.CHAR15TabTyp;
          L_PERIOD_TYPE_TAB             PA_PLSQL_DATATYPES.CHAR15TabTyp;
          L_PERIOD_SET_NAME_TAB         PA_PLSQL_DATATYPES.CHAR15TabTyp;
          L_PERIOD_NAME_TAB             PA_PLSQL_DATATYPES.CHAR15TabTyp;
          L_GLOBAL_EXP_END_DATE_TAB     PA_PLSQL_DATATYPES.DateTabTyp;
          L_PERIOD_YEAR_TAB             PA_PLSQL_DATATYPES.NumTabTyp;
          L_QUARTER_OR_MONTH_NUMBER_TAB PA_PLSQL_DATATYPES.NumTabTyp;
          L_AMOUNT_TYPE_ID_TAB          PA_PLSQL_DATATYPES.IdTabTyp;

l_tot_cap_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_res_cap_id;
l_dirct_cap_id                pa_amount_types_b.amount_type_id%TYPE
           := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_dir_cap_id;
l_sub_org_cap_id                  pa_amount_types_b.amount_type_id%TYPE
          := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_cap_id;
l_org_tot_cap_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_cap_id;

l_totally_fetched NUMBER := 0;

  CURSOR cur_update_bal
  IS
    SELECT
          SUM(T.period_balance)           period_balance
          , T.OBJECT_ID                   OBJECT_ID
          , T.VERSION_ID                  VERSION_ID
          , T.OBJECT_TYPE_CODE            OBJECT_TYPE_CODE
          , T.PERIOD_TYPE                 PERIOD_TYPE
          , T.PERIOD_SET_NAME             PERIOD_SET_NAME
          , T.PERIOD_NAME                 PERIOD_NAME
          , T.GLOBAL_EXP_PERIOD_END_DATE  GLOBAL_EXP_PERIOD_END_DATE
          , T.PERIOD_YEAR                 PERIOD_YEAR
          , T.QUARTER_OR_MONTH_NUMBER     QUARTER_OR_MONTH_NUMBER
          , T.AMOUNT_TYPE_ID              AMOUNT_TYPE_ID
    FROM  pa_rep_util_summ_tmp T
    WHERE
          T.RECORD_TYPE = 'TMP4'
      AND T.PROCESS_MODE_FLAG = 'U'
    GROUP BY
          T.OBJECT_ID
          , T.VERSION_ID
          , T.OBJECT_TYPE_CODE
          , T.PERIOD_TYPE
          , T.PERIOD_SET_NAME
          , T.PERIOD_NAME
          , T.GLOBAL_EXP_PERIOD_END_DATE
          , T.PERIOD_YEAR
          , T.QUARTER_OR_MONTH_NUMBER
          , T.AMOUNT_TYPE_ID
    ;

    rec_update_bal  cur_update_bal%ROWTYPE;

BEGIN

   PA_DEBUG.set_curr_function('PA_REP_UTILS_SUMM_PKG.populate_balance_entity');

   /*
    * Update the global temporary table for successful update.
    */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Update the global temporary table for successful update1';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   UPDATE pa_rep_util_summ_tmp B
   SET    B.process_mode_flag    = 'U'
          , B.record_type        = 'TMP4'
   WHERE  exists( SELECT T.period_balance
                  FROM   pa_summ_balances T
                  WHERE  T.OBJECT_ID        = B.OBJECT_ID
                  AND    T.VERSION_ID       = B.VERSION_ID
                  AND    T.OBJECT_TYPE_CODE = B.OBJECT_TYPE_CODE
                  AND    T.PERIOD_TYPE      = B.PERIOD_TYPE
                  AND    T.PERIOD_SET_NAME  = B.PERIOD_SET_NAME
                  AND    T.PERIOD_NAME      = B.PERIOD_NAME
                  AND    T.GLOBAL_EXP_PERIOD_END_DATE
                         = B.GLOBAL_EXP_PERIOD_END_DATE
                  AND    T.PERIOD_YEAR      = B.PERIOD_YEAR
                  AND    T.QUARTER_OR_MONTH_NUMBER
                         = B.QUARTER_OR_MONTH_NUMBER
                  AND    T.AMOUNT_TYPE_ID   = B.AMOUNT_TYPE_ID)
   AND   B.RECORD_TYPE      = 'TMP2'
--   AND   nvl(B.process_mode_flag,'II') <> 'II'
   AND   B.process_mode_flag = 'UI'
   ;

    /*
     * Clear all PL/SQL table.
     */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Clearing PL/SQL Table';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

    L_PERIOD_BALANCE_TAB.delete;
    L_OBJECT_ID_TAB.delete;
    L_VERSION_ID_TAB.delete;
    L_OBJECT_TYPE_CODE_TAB.delete;
    L_PERIOD_TYPE_TAB.delete;
    L_PERIOD_SET_NAME_TAB.delete;
    L_PERIOD_NAME_TAB.delete;
    L_GLOBAL_EXP_END_DATE_TAB.delete;
    L_PERIOD_YEAR_TAB.delete;
    L_QUARTER_OR_MONTH_NUMBER_TAB.delete;
    L_AMOUNT_TYPE_ID_TAB.delete;

   /*
    * Update the balance entity for existing records of pa_rep_util_summ_tmp
    * marked for update.
    */
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Update the balance entity for existing records of pa_rep_util_summ_tmp  marked for update';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   IF cur_update_bal%ISOPEN then
      CLOSE cur_update_bal;
   END IF;

   OPEN cur_update_bal;

   FETCH cur_update_bal BULK COLLECT
   INTO
       L_PERIOD_BALANCE_TAB
       , L_OBJECT_ID_TAB
       , L_VERSION_ID_TAB
       , L_OBJECT_TYPE_CODE_TAB
       , L_PERIOD_TYPE_TAB
       , L_PERIOD_SET_NAME_TAB
       , L_PERIOD_NAME_TAB
       , L_GLOBAL_EXP_END_DATE_TAB
       , L_PERIOD_YEAR_TAB
       , L_QUARTER_OR_MONTH_NUMBER_TAB
       , L_AMOUNT_TYPE_ID_TAB
       ;
   l_totally_fetched := cur_update_bal%ROWCOUNT;
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Records totally fetched from cur_update_bal'||l_totally_fetched||L_PERIOD_BALANCE_TAB.COUNT;
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'Before updating PA_SUMM_BALANCES from cur_update_bal';
    PA_DEBUG.Log_Message( p_message => PA_DEBUG.g_err_stage);
    END IF;


    IF L_PERIOD_BALANCE_TAB.COUNT > 0 then
           FORALL I in L_PERIOD_BALANCE_TAB.FIRST..L_PERIOD_BALANCE_TAB.LAST
           UPDATE pa_summ_balances  B
                  set B.period_balance = (L_PERIOD_BALANCE_TAB(I)+
                                         DECODE(B.amount_type_id
                                         , l_tot_cap_id     , 0
                                         , l_dirct_cap_id   , 0
                                         , l_org_tot_cap_id , 0
                                         , l_sub_org_cap_id , 0
                                         , B.period_balance)
                                         )
           WHERE L_OBJECT_ID_TAB(I)             = B.OBJECT_ID
           AND L_VERSION_ID_TAB(I)              = B.VERSION_ID
           AND L_OBJECT_TYPE_CODE_TAB(I)        = B.OBJECT_TYPE_CODE
           AND L_PERIOD_TYPE_TAB(I)             = B.PERIOD_TYPE
           AND L_PERIOD_SET_NAME_TAB(I)         = B.PERIOD_SET_NAME
           AND L_PERIOD_NAME_TAB(I)             = B.PERIOD_NAME
           AND L_GLOBAL_EXP_END_DATE_TAB(I)     = B.GLOBAL_EXP_PERIOD_END_DATE
           AND L_PERIOD_YEAR_TAB(I)             = B.PERIOD_YEAR
           AND L_QUARTER_OR_MONTH_NUMBER_TAB(I) = B.QUARTER_OR_MONTH_NUMBER
           AND L_AMOUNT_TYPE_ID_TAB(I)          = B.AMOUNT_TYPE_ID
           ;
    END IF;
    CLOSE cur_update_bal;


   /*
    * Insert new balance records from pa_rep_util_summ_tmp if needed.
    */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'Insert new balance records from pa_rep_util_summ_tmp if needed.';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO pa_summ_balances
   ( OBJECT_ID,
     VERSION_ID,
     OBJECT_TYPE_CODE,
     PERIOD_TYPE,
     PERIOD_SET_NAME ,
     PERIOD_NAME,
     GLOBAL_EXP_PERIOD_END_DATE,
     PERIOD_YEAR,
     QUARTER_OR_MONTH_NUMBER,
     AMOUNT_TYPE_ID,
     PERIOD_NUM,
     UNIT_OF_MEASURE ,
     PERIOD_BALANCE,
     PVDR_CURRENCY_CODE,
     PVDR_PERIOD_BALANCE)
   SELECT OBJECT_ID,
       -1,
       max(OBJECT_TYPE_CODE),
       PERIOD_TYPE,
       max(nvl(PERIOD_SET_NAME,l_dummy_period_set_name)),
       nvl(PERIOD_NAME,l_dummy_period_name),
       nvl(GLOBAL_EXP_PERIOD_END_DATE,l_dummy_ge_date),
       max(PERIOD_YEAR),
       max(QUARTER_OR_MONTH_NUMBER),
       AMOUNT_TYPE_ID,
       max(PERIOD_NUM),
       max(UNIT_OF_MEASURE),
       sum(PERIOD_BALANCE),
       NULL,
       NULL
   FROM   pa_rep_util_summ_tmp
   WHERE  RECORD_TYPE       = 'TMP2'
-- mpuvathi: for both UI and II
   AND    PROCESS_MODE_FLAG in ('UI' , 'II')
   AND    object_type_code <> l_utildet_c
   GROUP BY OBJECT_ID, PERIOD_TYPE, PERIOD_NAME,
         GLOBAL_EXP_PERIOD_END_DATE, AMOUNT_TYPE_ID;

   PA_DEBUG.Reset_curr_function;

EXCEPTION
    WHEN OTHERS
    THEN
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
        raise;
END populate_balance_entity;


/*
 * This will populate the PA_REP_UTIL_SUMM_TMP table for incremental rollup.
 */
PROCEDURE populate_incremental_rollup
IS
/*
 * Cache sub org and total level amount types.
 */
l_org_tot_hrs_id     pa_amount_types_b.amount_type_id%TYPE
               := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_hrs_id;
l_org_tot_wght_hrs_org_id     pa_amount_types_b.amount_type_id%TYPE
               := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_wtdhrs_org_id;
l_org_tot_prov_hrs_id         pa_amount_types_b.amount_type_id%TYPE
               := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_prvhrs_id;
l_org_prov_wght_hrs_org_id    pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_prvwtdhrs_org_id;
l_org_tot_cap_id              pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_cap_id;
l_org_tot_reducedcap_id       pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_tot_reducedcap_id;
l_sub_org_tot_hrs_id         pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_hrs_id;
l_sub_org_tot_prov_hrs_id    pa_amount_types_b.amount_type_id%TYPE
              := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_prvhrs_id;
l_sub_org_tot_wght_hrs_org_id    pa_amount_types_b.amount_type_id%TYPE
          := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_wtdhrs_org_id;
l_sub_org_prov_wght_hrs_org_id    pa_amount_types_b.amount_type_id%TYPE
          := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_prvwtdhrs_org_id;
l_sub_org_cap_id                  pa_amount_types_b.amount_type_id%TYPE
          := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_cap_id;
l_sub_org_reducedcap_id           pa_amount_types_b.amount_type_id%TYPE
          := PA_REP_UTIL_GLOB.G_amt_type_details.G_org_sub_reducedcap_id;
/** End Cache sub org and total level amount types **/


BEGIN

   PA_DEBUG.set_curr_function('PA_REP_UTILS_SUMM_PKG.populate_incremental_rollup');

   /*
    * populate PA_REP_UTIL_SUMM_TMP for total hours.
    */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.g_err_stage := 'populate PA_REP_UTIL_SUMM_TMP for total hours';
   PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
   END IF;

   INSERT INTO pa_rep_util_summ_tmp
      (   record_type,
          object_id,
          version_id,
          object_type_code,
          balance_type_code,
          expenditure_org_id,
          expenditure_organization_id,
          person_id,
          assignment_id,
          work_type_id,
          org_util_category_id,
          res_util_category_id,
          period_type,
          period_set_name,
          period_name,
          global_exp_period_end_date,
          period_year,
          quarter_or_month_number,
          unit_of_measure,
          amount_type_id,
          period_balance,
          period_num,
          expenditure_type,
          expenditure_type_class,
          summ_level_flag,
          process_mode_flag)
    SELECT 'TMP2',
           tmp.object_id,
           tmp.version_id,
           tmp.object_type_code,
           tmp.balance_type_code,
           tmp.expenditure_org_id,
           org.parent_organization_id,
           tmp.person_id,
           tmp.assignment_id,
           tmp.work_type_id,
           tmp.org_util_category_id,
           tmp.res_util_category_id,
           tmp.period_type,
           tmp.period_set_name,
           tmp.period_name,
           tmp.global_exp_period_end_date,
           tmp.period_year,
           tmp.quarter_or_month_number,
           tmp.unit_of_measure,
           decode(dummytab.dummy_col,'S',
            decode(tmp.amount_type_id,l_dirct_tot_hrs_id,l_sub_org_tot_hrs_id,
                   l_dirct_tot_prov_hrs_id,l_sub_org_tot_prov_hrs_id,
                   l_dirct_tot_wght_hrs_org_id,l_sub_org_tot_wght_hrs_org_id,
                   l_dirct_prov_wght_hrs_org_id,l_sub_org_prov_wght_hrs_org_id,
                   l_dirct_cap_id,l_sub_org_cap_id,
                   l_dirct_reduce_cap_id,l_sub_org_reducedcap_id),
            decode(tmp.amount_type_id,l_dirct_tot_hrs_id,l_org_tot_hrs_id,
                   l_dirct_tot_prov_hrs_id,l_org_tot_prov_hrs_id,
                   l_dirct_tot_wght_hrs_org_id,l_org_tot_wght_hrs_org_id,
                   l_dirct_prov_wght_hrs_org_id,l_org_prov_wght_hrs_org_id,
                   l_dirct_cap_id,l_org_tot_cap_id,
                   l_dirct_reduce_cap_id,l_org_tot_reducedcap_id)),
           tmp.period_balance,
           tmp.period_num,
           tmp.expenditure_type,
           tmp.expenditure_type_class,
           'O',
           'II'
       from  pa_rep_util_summ_tmp tmp,
             pa_org_hierarchy_denorm org,
             pa_implementations imp,
            (select 'T' dummy_col from dual union select 'S' from dual) dummytab
       where tmp.summ_level_flag  = 'O'
       and   tmp.record_type = 'TMP2'
--  new line below
       and   tmp.process_mode_flag = 'II'
       and   org.pa_org_use_type = 'REPORTING'
       and   org.org_id          = l_exp_org_id
       and   imp.org_structure_version_id = org.org_hierarchy_version_id
       and   org.child_organization_id =  tmp.expenditure_organization_id
       and   ((dummytab.dummy_col = 'S'
       and    org.child_organization_id <> org.parent_organization_id)
       or    (dummytab.dummy_col = 'T'));

  PA_DEBUG.Reset_curr_function;

EXCEPTION
  WHEN OTHERS
  THEN
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
       raise;
END populate_incremental_rollup;

PROCEDURE populate_summ_entity(P_Balance_Type_Code IN VARCHAR2,
                               p_process_method IN VARCHAR2)
IS

BEGIN

   PA_DEBUG.set_curr_function('populate_summ_entity');

  /*
   * Assign P_Balance_Type_Code to package variable for future use.
   */
  l_balance_type_code := P_Balance_Type_Code;

  /*
   * Assign p_process_method to package variable for future use.
   */
  l_delete_flag       := p_process_method;
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := 'Summarize the Data by Period ';
  PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
  END IF;
  /*
   * Summarize the data period wise from Global PL/SQL Table  and
   * populate global temprary table with periodwise summarized data.
   */
  summarize_by_period;




  /*
   * Call the actual procedure to summarize data from global temporary
   * table.
   */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := 'Summarize the Data by Object Type ';
  PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
  END IF;

  summarize_temp_data_by_res;

  IF PA_REP_UTIL_GLOB.G_is_this_first_fetch = 'Y'  THEN
          populate_tmp_for_capacity;
          PA_REP_UTIL_GLOB.G_is_this_first_fetch := 'N';
  END IF;

  summarize_temp_data_by_org;

  /*
   * If incremental rollup is enabled, populate the pa_rep_util_summ_tmp.
   */
  IF (l_org_rollup_method = 'I')
  THEN
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'Processing Incremental Rollup';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;
    populate_incremental_rollup;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := 'After Processing Incremental Rollup';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
    END IF;

  END IF;

  /*
   * Populate the object entity from pa_rep_util_summ_tmp
   * for record_type='TMP2'.
   */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := 'Before calling populate_object_entity';
  PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
  END IF;

  populate_object_entity;

  /*
   * Populate the balance entity from pa_rep_util_summ_tmp
   * for record_type='TMP2'.
   */
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := 'Before calling populate_balance_entity';
  PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
  END IF;

  populate_balance_entity;

  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := 'After calling populate_balance_entity';
  PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
  END IF;

  PA_DEBUG.Reset_curr_function;

EXCEPTION
  WHEN OTHERS
  THEN
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      PA_DEBUG.log_message(SQLERRM);
      END IF;
       raise;

END populate_summ_entity;

END PA_REP_UTILS_SUMM_PKG;

/
