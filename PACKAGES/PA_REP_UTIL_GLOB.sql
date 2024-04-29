--------------------------------------------------------
--  DDL for Package PA_REP_UTIL_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REP_UTIL_GLOB" AUTHID CURRENT_USER AS
/* $Header: PARRGLBS.pls 120.1 2005/08/19 17:00:22 mwasowic noship $ */

  /*
   * Constants.
   */
  G_DEFAULT_FETCH_SIZE_C    CONSTANT PLS_INTEGER := 200;
  G_UNIT_OF_MEASURE_HRS_C   CONSTANT VARCHAR2(10) := 'HOURS';           -- datatype length ok??
  G_DUMMY_C                 CONSTANT VARCHAR2(15) := 'SUMM_DUMMY';      -- datatype length ok??
  G_DUMMY_DATE_C            CONSTANT DATE := to_date('01/01/1420', 'DD/MM/YYYY');

  /*
   * The following is a list of constants defined for each
   * of the amount type codes.
   */

    G_RES_HRS_C                   CONSTANT VARCHAR2(30) := 'RES_HRS' ;
    G_RES_WTDHRS_ORG_C            CONSTANT VARCHAR2(30) := 'RES_WTDHRS_ORG';
    G_RES_WTDHRS_PEOPLE_C         CONSTANT VARCHAR2(30) := 'RES_WTDHRS_PEOPLE';
    G_RES_PRVHRS_C                CONSTANT VARCHAR2(30) := 'RES_PRVHRS';
    G_RES_PRVWTDHRS_ORG_C         CONSTANT VARCHAR2(30) := 'RES_PRVWTDHRS_ORG';
    G_RES_PRVWTDHRS_PEOPLE_C      CONSTANT VARCHAR2(30) := 'RES_PRVWTDHRS_PEOPLE';
    G_RES_UTILPRCTGHRS_C          CONSTANT VARCHAR2(30) := 'RES_UTILPRCTGHRS';
    G_RES_UTILPRCTGCAP_C          CONSTANT VARCHAR2(30) := 'RES_UTILPRCTGCAP';
    G_RES_CAP_C                   CONSTANT VARCHAR2(30) := 'RES_CAP';
    G_RES_REDUCEDCAP_C            CONSTANT VARCHAR2(30) := 'RES_REDUCEDCAP';
    G_ORG_SUB_HRS_C               CONSTANT VARCHAR2(30) := 'ORG_SUB_HRS';
    G_ORG_SUB_WTDHRS_ORG_C        CONSTANT VARCHAR2(30) := 'ORG_SUB_WTDHRS_ORG';
    G_ORG_SUB_PRVHRS_C            CONSTANT VARCHAR2(30) := 'ORG_SUB_PRVHRS';
    G_ORG_SUB_PRVWTDHRS_ORG_C     CONSTANT VARCHAR2(30) := 'ORG_SUB_PRVWTDHRS_ORG';
    G_ORG_SUB_UTILPRCTGHRS_C      CONSTANT VARCHAR2(30) := 'ORG_SUB_UTILPRCTGHRS';
    G_ORG_SUB_UTILPRCTGCAP_C      CONSTANT VARCHAR2(30) := 'ORG_SUB_UTILPRCTGCAP';
    G_ORG_SUB_CAP_C               CONSTANT VARCHAR2(30) := 'ORG_SUB_CAP';
    G_ORG_SUB_REDUCEDCAP_C        CONSTANT VARCHAR2(30) := 'ORG_SUB_REDUCEDCAP';
    G_ORG_SUB_HEADCOUNT_C         CONSTANT VARCHAR2(30) := 'ORG_SUB_HEADCOUNT';
    G_ORG_SUB_EMPHEADCOUNT_C      CONSTANT VARCHAR2(30) := 'ORG_SUB_EMPHEADCOUNT';
    G_ORG_DIR_HRS_C               CONSTANT VARCHAR2(30) := 'ORG_DIR_HRS';
    G_ORG_DIR_WTDHRS_ORG_C        CONSTANT VARCHAR2(30) := 'ORG_DIR_WTDHRS_ORG';
    G_ORG_DIR_PRVHRS_C            CONSTANT VARCHAR2(30) := 'ORG_DIR_PRVHRS';
    G_ORG_DIR_PRVWTDHRS_ORG_C     CONSTANT VARCHAR2(30) := 'ORG_DIR_PRVWTDHRS_ORG';
    G_ORG_DIR_UTILPRCTGHRS_C      CONSTANT VARCHAR2(30) := 'ORG_DIR_UTILPRCTGHRS';
    G_ORG_DIR_UTILPRCTGCAP_C      CONSTANT VARCHAR2(30) := 'ORG_DIR_UTILPRCTGCAP';
    G_ORG_DIR_CAP_C               CONSTANT VARCHAR2(30) := 'ORG_DIR_CAP';
    G_ORG_DIR_REDUCEDCAP_C        CONSTANT VARCHAR2(30) := 'ORG_DIR_REDUCEDCAP';
    G_ORG_DIR_HEADCOUNT_C         CONSTANT VARCHAR2(30) := 'ORG_DIR_HEADCOUNT';
    G_ORG_DIR_EMPHEADCOUNT_C      CONSTANT VARCHAR2(30) := 'ORG_DIR_EMPHEADCOUNT';
    G_ORG_TOT_HRS_C               CONSTANT VARCHAR2(30) := 'ORG_TOT_HRS';
    G_ORG_TOT_WTDHRS_ORG_C        CONSTANT VARCHAR2(30) := 'ORG_TOT_WTDHRS_ORG';
    G_ORG_TOT_PRVHRS_C            CONSTANT VARCHAR2(30) := 'ORG_TOT_PRVHRS';
    G_ORG_TOT_PRVWTDHRS_ORG_C     CONSTANT VARCHAR2(30) := 'ORG_TOT_PRVWTDHRS_ORG';
    G_ORG_TOT_UTILPRCTGHRS_C      CONSTANT VARCHAR2(30) := 'ORG_TOT_UTILPRCTGHRS';
    G_ORG_TOT_UTILPRCTGCAP_C      CONSTANT VARCHAR2(30) := 'ORG_TOT_UTILPRCTGCAP';
    G_ORG_TOT_CAP_C               CONSTANT VARCHAR2(30) := 'ORG_TOT_CAP';
    G_ORG_TOT_REDUCEDCAP_C        CONSTANT VARCHAR2(30) := 'ORG_TOT_REDUCEDCAP';
    G_ORG_TOT_HEADCOUNT_C         CONSTANT VARCHAR2(30) := 'ORG_TOT_HEADCOUNT';
    G_ORG_TOT_EMPHEADCOUNT_C      CONSTANT VARCHAR2(30) := 'ORG_TOT_EMPHEADCOUNT';
  /*
   * The variables in the following Record are
   * to be used as constants.
   */
  TYPE G_BAL_TYPE_REC_C
  IS RECORD (
              G_ACTUALS_C  VARCHAR2(15)
             ,G_FORECAST_C VARCHAR2(15)
            );

  TYPE G_OBJ_TYPE_REC_C
  IS RECORD (
              G_ORG_C      VARCHAR2(15)
             ,G_ORGUC_C    VARCHAR2(15)
             ,G_ORGWT_C    VARCHAR2(15)
             ,G_RES_C      VARCHAR2(15)
             ,G_RESUCO_C   VARCHAR2(15)
             ,G_RESUCR_C   VARCHAR2(15)
             ,G_RESWT_C    VARCHAR2(15)
             ,G_UTILDET_C  VARCHAR2(15)
           );

  TYPE G_PERIOD_TYPE_REC_C
  IS RECORD (
              G_GL_C      VARCHAR2(3)
             ,G_PA_C      VARCHAR2(3)
             ,G_GE_C      VARCHAR2(3)
            );
  /*
   * Definitions for Global Variables.
   */
  G_global_week_start_day  PLS_INTEGER;
  G_util_fetch_size        PLS_INTEGER DEFAULT G_DEFAULT_FETCH_SIZE_C;
  G_u1_show_prctg_by        VARCHAR2(30);

  G_period_type_qtr_c      VARCHAR2(3) := 'QR';
  G_period_type_year_c     VARCHAR2(3) := 'YR';

  /*
  ** Cacheing the organization_id for U1 screen
  */
  G_Organization_ID			NUMBER;
  G_Period_Type     			VARCHAR2(30);
  G_Period_Name				VARCHAR2(30);
  G_Period_Year				VARCHAR2(30);
  G_Global_Exp_Period_End_Date	DATE;
  G_Period_Quarter			VARCHAR2(30);



/*
 * Define the variable which will ensure that the call to Capacity vector
 * is made only once. The variable is defaulted to 'Y' and as soon as the first
 * call to the Capacity Vector is made it is set to 'N'.
 */
  G_is_this_first_fetch VARCHAR2(1) := 'Y';

  G_eff_ac_start_pa_period_num PLS_INTEGER;
  G_eff_ac_start_gl_period_num PLS_INTEGER;
  G_eff_fc_start_pa_period_num PLS_INTEGER;
  G_eff_fc_start_gl_period_num PLS_INTEGER;

  /*
   * Definitions for Global Records.
   */

  TYPE G_input_parameters_rec
  IS RECORD (
              G_ac_start_date      DATE
             ,G_ac_end_date        DATE
             ,G_fc_start_date      DATE
             ,G_fc_end_date        DATE
             ,G_org_rollup_method  VARCHAR2(1) DEFAULT 'I'
             ,G_debug_mode         VARCHAR2(2)
            );

  TYPE G_who_columns_rec
  IS RECORD (
             G_last_updated_by          NUMBER(15)
            ,G_created_by               NUMBER(15)
            ,G_creation_date            DATE
            ,G_last_update_date         DATE
            ,G_last_update_login        NUMBER(15)
            ,G_program_application_id   NUMBER(15)
            ,G_request_id               NUMBER(15)
            ,G_program_id               NUMBER(15)
            );

  TYPE G_implementation_details_rec
  IS RECORD (
             G_org_id                    pa_implementations.org_id%TYPE
	    ,G_org_structure_version_id  pa_implementations.org_structure_version_id%TYPE
	    ,G_start_organization_id     pa_implementations.start_organization_id%TYPE
            ,G_pa_period_type            pa_implementations.pa_period_type%TYPE
            ,G_gl_period_type            gl_sets_of_books.accounted_period_type%TYPE
--          ,G_period_set_name           gl_sets_of_books.period_set_name%TYPE
            ,G_gl_period_set_name        gl_sets_of_books.period_set_name%TYPE  --bug 3434019
            ,G_pa_period_set_name        gl_sets_of_books.period_set_name%TYPE  --bug 3434019
            );

  TYPE G_util_option_details_rec
  IS RECORD (
             G_gl_period_flag          pa_utilization_options.gl_period_flag%TYPE
            ,G_pa_period_flag          pa_utilization_options.pa_period_flag%TYPE
            ,G_ge_period_flag          pa_utilization_options.global_exp_period_flag%TYPE
            ,G_forecast_thru_date      pa_utilization_options.forecast_thru_date%TYPE
            ,G_actuals_thru_date       pa_utilization_options.actuals_thru_date%TYPE
            ,G_util_calc_method        VARCHAR2(30)
            );

  TYPE G_u3_parameters_rec
  IS RECORD (
             G_period_type             VARCHAR2(2)
            ,G_period_name             gl_periods.period_name%TYPE
            ,G_qtr_or_mon_num          NUMBER
            ,G_year_num                NUMBER
            ,G_person_id               NUMBER
            ,G_ge_end_date             VARCHAR2(15)
            ,G_eff_period_num          NUMBER
            );
  /*
   * The following Record maintains the Ids for all the
   * Amount types - available in tables pa_amount_types_b
   * and pa_amount_types_tl.
   * It is populated in the procedure PA_REP_UTIL_GLOB.initialize_amt_type_id_cache.
   */
  TYPE G_amt_type_details_rec
  IS RECORD (
               G_res_hrs_id                   pa_amount_types_b.amount_type_id%TYPE
              ,G_res_wtdhrs_org_id            pa_amount_types_b.amount_type_id%TYPE
              ,G_res_wtdhrs_people_id         pa_amount_types_b.amount_type_id%TYPE
              ,G_res_prvhrs_id                pa_amount_types_b.amount_type_id%TYPE
              ,G_res_prvwtdhrs_org_id         pa_amount_types_b.amount_type_id%TYPE
              ,G_res_prvwtdhrs_people_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_res_utilprctghrs_id          pa_amount_types_b.amount_type_id%TYPE
              ,G_res_utilprctgcap_id          pa_amount_types_b.amount_type_id%TYPE
              ,G_res_cap_id                   pa_amount_types_b.amount_type_id%TYPE
              ,G_res_reducedcap_id            pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_hrs_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_wtdhrs_org_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_prvhrs_id            pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_prvwtdhrs_org_id     pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_utilprctghrs_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_utilprctgcap_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_cap_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_reducedcap_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_headcount_id         pa_amount_types_b.amount_type_id%TYPE
              ,G_org_sub_empheadcount_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_hrs_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_wtdhrs_org_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_prvhrs_id            pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_prvwtdhrs_org_id     pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_utilprctghrs_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_utilprctgcap_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_cap_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_reducedcap_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_headcount_id         pa_amount_types_b.amount_type_id%TYPE
              ,G_org_dir_empheadcount_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_hrs_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_wtdhrs_org_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_prvhrs_id            pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_prvwtdhrs_org_id     pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_utilprctghrs_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_utilprctgcap_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_cap_id               pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_reducedcap_id        pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_headcount_id         pa_amount_types_b.amount_type_id%TYPE
              ,G_org_tot_empheadcount_id      pa_amount_types_b.amount_type_id%TYPE
              ,G_quantity_id                  pa_amount_types_b.amount_type_id%TYPE
            );

  TYPE G_last_run_when_rec
  IS RECORD (
              G_ac_last_run_date   DATE
             ,G_fc_last_run_date   DATE
             );

  /*
   * Variable definitions for the Global Record types.
   */
  G_input_parameters       G_input_parameters_rec;
  G_who_columns            G_who_columns_rec;
  G_implementation_details G_implementation_details_rec;
  G_util_option_details    G_util_option_details_rec;
  G_amt_type_details       G_amt_type_details_rec;
  G_u3_parameters          G_u3_parameters_rec;
  G_BAL_TYPE_C             G_BAL_TYPE_REC_C;
  G_OBJ_TYPE_C             G_OBJ_TYPE_REC_C;
  G_PERIOD_TYPE_C          G_PERIOD_TYPE_REC_C;
  G_last_run_when          G_last_run_when_rec;

  /*
   * Procedures.
   */
  PROCEDURE Get_Util_AC_Parm(
                              errbuf                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,retcode               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,p_ac_start_date       IN VARCHAR2
                             ,p_ac_end_date         IN VARCHAR2
                             ,p_fc_start_date       IN VARCHAR2
                             ,p_fc_end_date         IN VARCHAR2
                             ,p_org_rollup_method   IN VARCHAR2
                             ,p_debug_mode          IN VARCHAR2
                            );
  PROCEDURE Get_Util_FC_Parm(
                              errbuf                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,retcode               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,p_ac_start_date       IN VARCHAR2
                             ,p_ac_end_date         IN VARCHAR2
                             ,p_fc_start_date       IN VARCHAR2
                             ,p_fc_end_date         IN VARCHAR2
                             ,p_org_rollup_method   IN VARCHAR2
                             ,p_debug_mode          IN VARCHAR2
                             );
  PROCEDURE Get_Util_Prc_Switch(
                               x_prc_switch       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             );


  PROCEDURE Get_Effective_Start_Period_Num(  errbuf                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                            ,retcode                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                            ,effective_start_period_num OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                            ,p_period_set_name          IN  VARCHAR2
                                            ,p_period_type              IN  VARCHAR2
                                            ,p_start_date               IN  DATE
                                           );

  /*
   * Procedure to populate the parameter cache with
   * the parameters entered during the concurrent process.
   */
  PROCEDURE initialize_util_cache(
                                   p_ac_start_date       IN DATE
                                  ,p_ac_end_date         IN DATE
                                  ,p_fc_start_date       IN DATE
                                  ,p_fc_end_date         IN DATE
                                  ,p_org_rollup_method   IN VARCHAR2 default 'I' /* bug 2386679 */
                                  ,p_debug_mode          IN VARCHAR2
                                 );

  /*
   * Procedure to initialize the variables holding the
   * amount_type_ids with their corresponding values.
   */
  PROCEDURE initialize_amt_type_id_cache;

  /*
   * Procedures to set parameters from the U3 screen.
   */
  PROCEDURE SetU3PeriodType (p_period_type IN pa_implementations.pa_period_type%TYPE);
  PROCEDURE SetU3PeriodName (p_period_name IN gl_periods.period_name%TYPE);
  PROCEDURE SetU3QtrOrMonNum(p_qtr_or_mon_num IN VARCHAR2);
  PROCEDURE SetU3YearNum (p_year_num IN VARCHAR2);
  PROCEDURE SetU3PersonId (p_person_id IN VARCHAR2);
  PROCEDURE SetU3GeEndDate (p_ge_end_date IN VARCHAR2);
  PROCEDURE SetU3EffPeriodNum (p_eff_period_num IN VARCHAR2);

  /*
   * Procedures to set parameters from the U1 screen.
   */
  PROCEDURE SetU1ShowPrctgBy(p_showprctgby IN VARCHAR2);

  /*
   * Functions.
   */

  /*
   * Functions to return Period_types.
   */
  FUNCTION GetPeriodTypeGl  RETURN VARCHAR2;
  FUNCTION GetPeriodTypePa  RETURN VARCHAR2;
  FUNCTION GetPeriodTypeGe  RETURN VARCHAR2;

  /*
   * Functions to return Balance_types.
   */
  FUNCTION GetBalTypeActuals  RETURN VARCHAR2;
  FUNCTION GetBalTypeForecast RETURN VARCHAR2;

  /*
   * Functions to return Object_types..
   */
  FUNCTION GetObjectTypeOrg     RETURN VARCHAR2;
  FUNCTION GetObjectTypeOrgUc   RETURN VARCHAR2;
  FUNCTION GetObjectTypeOrgWt   RETURN VARCHAR2;
  FUNCTION GetObjectTypeRes     RETURN VARCHAR2;
  FUNCTION GetObjectTypeResUco  RETURN VARCHAR2;
  FUNCTION GetObjectTypeResUcr  RETURN VARCHAR2;
  FUNCTION GetObjectTypeResWt   RETURN VARCHAR2;
  FUNCTION GetObjectTypeUtilDet RETURN VARCHAR2;


  /*
   * Functions to get parameters from the U3 screen.
   */
  FUNCTION GetU3PeriodType    RETURN pa_implementations.pa_period_type%TYPE;
  FUNCTION GetU3PeriodName    RETURN gl_periods.period_name%TYPE;
  FUNCTION GetU3QtrOrMonNum   RETURN NUMBER;
  FUNCTION GetU3YearNum       RETURN NUMBER;
  FUNCTION GetU3PersonId      RETURN NUMBER;
  FUNCTION GetU3GeEndDate     RETURN VARCHAR2;
  FUNCTION GetU3EffPeriodNum  RETURN NUMBER;

  FUNCTION GetUtilCalcMethod  RETURN VARCHAR2;
  /*
   * Function to return Fetch Size.
   */
  FUNCTION GetFetchSize         RETURN NUMBER;

  /*
   * Function to return Period Set Name.
   */
  FUNCTION GetPeriodSetName RETURN gl_sets_of_books.period_set_name%TYPE;
  /*
   * Function to return org_id.
   */
  FUNCTION GetOrgId RETURN pa_implementations.org_id%TYPE;
  FUNCTION GetOrgStructureVersionId RETURN pa_implementations.org_structure_version_id%TYPE;

  /*
   * Functions to return dummy values.
   */
  FUNCTION GetDummy     RETURN VARCHAR2;
  FUNCTION GetDummyDate RETURN DATE;
  FUNCTION GetU1ShowPrctgBy RETURN VARCHAR2;
  /* Functions to return Period Type Quarter and Period Type Year
   */
  FUNCTION GetPeriodTypeQr  RETURN VARCHAR2;
  FUNCTION GetperiodTypeYr RETURN VARCHAR2;
  /*
   *  The following Functions are for getting the last run details
   */
  FUNCTION GetActualsLastRunDate RETURN DATE;
  FUNCTION GetForecastLastRunDate RETURN DATE;

  /*
   *  The following subprograms are for getting and setting
   *  the Organization ID and period information for U1 screen
   */
  FUNCTION GetU1OrganizationID return NUMBER;
  PROCEDURE SetU1OrganizationID(p_organization_id IN NUMBER);

  PROCEDURE SetU1Params(p_organization_id IN NUMBER, p_period_type IN VARCHAR2, p_period_name IN VARCHAR2, p_period_year IN NUMBER);
  FUNCTION GetU1PeriodType return VARCHAR2;
  FUNCTION GetU1PeriodName return VARCHAR2;
  FUNCTION GetU1PeriodYear return VARCHAR2;
  FUNCTION GetU1PeriodQuarter return VARCHAR2;
  FUNCTION GetU1GlobalExpPeriodEndDate return DATE;

  /*
   * Bug 2447797 - This following procedure initializes Global variables.
   *               It replaces the procedure auto_util_cache.
   */
  PROCEDURE update_util_cache;


END PA_REP_UTIL_GLOB;

 

/
