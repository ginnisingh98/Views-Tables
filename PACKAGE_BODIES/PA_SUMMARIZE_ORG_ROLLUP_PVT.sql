--------------------------------------------------------
--  DDL for Package Body PA_SUMMARIZE_ORG_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SUMMARIZE_ORG_ROLLUP_PVT" AS
/* $Header: PARRORGB.pls 120.0 2005/05/30 09:37:32 appldev noship $ */

  /*
   * Amount type ids - locally cached at the
   * package level.
   */
  l_org_dir_hrs_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_hrs_id;
  l_org_dir_wtdhrs_org_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_wtdhrs_org_id;
  l_org_dir_prvhrs_id              pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_prvhrs_id;
  l_org_dir_prvwtdhrs_org_id       pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_prvwtdhrs_org_id;
  l_org_dir_cap_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_cap_id;
  l_org_dir_reducedcap_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_dir_reducedcap_id;

  l_org_sub_hrs_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_hrs_id;
  l_org_sub_wtdhrs_org_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_wtdhrs_org_id;
  l_org_sub_prvhrs_id              pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_prvhrs_id;
  l_org_sub_prvwtdhrs_org_id       pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_prvwtdhrs_org_id;
  l_org_sub_cap_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_cap_id;
  l_org_sub_reducedcap_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_sub_reducedcap_id;

  l_org_tot_hrs_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_hrs_id;
  l_org_tot_wtdhrs_org_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_wtdhrs_org_id;
  l_org_tot_prvhrs_id              pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_prvhrs_id;
  l_org_tot_prvwtdhrs_org_id       pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_prvwtdhrs_org_id;
  l_org_tot_cap_id                 pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_cap_id;
  l_org_tot_reducedcap_id          pa_amount_types_b.amount_type_id%TYPE := pa_rep_util_glob.G_amt_type_details.G_org_tot_reducedcap_id;

  /*
   * Object types locally cached at the package level.
   */
  l_obj_type_orgwt VARCHAR2(15) := pa_rep_util_glob.G_OBJ_TYPE_C.G_ORGWT_C;
  l_obj_type_orguc VARCHAR2(15) := pa_rep_util_glob.G_OBJ_TYPE_C.G_ORGUC_C;
  l_obj_type_org   VARCHAR2(15) := pa_rep_util_glob.G_OBJ_TYPE_C.G_ORG_C;

  /*
   * Org ids locally cached at the package level.
   */
  l_start_org_id pa_implementations_all.start_organization_id%TYPE := pa_rep_util_glob.G_implementation_details.G_start_organization_id;
  l_org_id       pa_implementations_all.org_id%TYPE := pa_rep_util_glob.G_implementation_details.G_org_id;
  l_org_structure_version_id       pa_implementations_all.org_id%TYPE := pa_rep_util_glob.G_implementation_details.G_org_structure_version_id;

  /*
   * Period Set Name locally cached at the package level.
   * Changed for bug 3434019
   */
--  l_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_period_set_name;
  l_gl_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_gl_period_set_name;
  l_pa_period_set_name gl_sets_of_books.period_set_name%TYPE := pa_rep_util_glob.G_implementation_details.G_pa_period_set_name;

  /*
   * Commit and Fetch Sizes locally cached at the package level.
   */
  l_commit_size PLS_INTEGER := pa_rep_util_glob.G_util_fetch_size;
  l_fetch_size  PLS_INTEGER := pa_rep_util_glob.G_util_fetch_size;

  /*
   * Unit of measure locally cached at the package level.
   */
  l_unit_of_measure VARCHAR2(10) := pa_rep_util_glob.G_UNIT_OF_MEASURE_HRS_C;

  /*
   * Dummy Date locally cached at the package level.
   */
  l_dummy_date DATE := pa_rep_util_glob.G_DUMMY_DATE_C;
  l_dummy_period_set_name   VARCHAR2(15) := PA_REP_UTIL_GLOB.G_DUMMY_C;


  /*
   * Level of the start_org_id.
   */
  l_maximum_level PLS_INTEGER;

----------------------------------------------------------------------------
  /*
   * This procedure calls the org_rollup_pagl_period_type procedure for
   * period types 'PA' and 'GL' and org_rollup_ge_period_type for period
   * type 'GE'.
   */
  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE refresh_org_hierarchy_rollup( p_balance_type_code  IN VARCHAR2)
  IS
    l_pa_period_flag pa_utilization_options.pa_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_pa_period_flag;
    l_gl_period_flag pa_utilization_options.gl_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_gl_period_flag;
    l_ge_period_flag pa_utilization_options.global_exp_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_ge_period_flag;

    /*
     * pa and gl period types.
     */
    l_pa_period_type pa_implementations_all.pa_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_pa_period_type;
    l_gl_period_type gl_sets_of_books.accounted_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_gl_period_type;

    /*
     * Constants for 'PA' and 'GL'.
     */
    l_period_type_pa VARCHAR2(3) := pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C;
    l_period_type_gl VARCHAR2(3) := pa_rep_util_glob.G_PERIOD_TYPE_C.G_GL_C;
    l_period_type_ge VARCHAR2(3) := pa_rep_util_glob.G_PERIOD_TYPE_C.G_GE_C;

    l_balance_type_code pa_objects.balance_type_code%TYPE;
    l_eff_start_pa_period_num PLS_INTEGER;
    l_eff_start_gl_period_num PLS_INTEGER;
    l_start_date DATE;
    l_end_date   DATE;
  BEGIN
    PA_DEBUG.set_curr_function('refresh_org_hierarchy_rollup');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '50:Inside refresh_org_hierarchy_rollup';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    END IF;
    l_balance_type_code := p_balance_type_code;

    IF (l_balance_type_code = 'ACTUALS') THEN
      l_start_date := pa_rep_util_glob.G_input_parameters.G_ac_start_date;
      l_end_date   := pa_rep_util_glob.G_input_parameters.G_ac_end_date;
      l_eff_start_pa_period_num := pa_rep_util_glob.G_eff_ac_start_pa_period_num;
      l_eff_start_gl_period_num := pa_rep_util_glob.G_eff_ac_start_gl_period_num;
    ELSIF (l_balance_type_code = 'FORECAST') THEN
      l_start_date := pa_rep_util_glob.G_input_parameters.G_fc_start_date;
      l_end_date   := pa_rep_util_glob.G_input_parameters.G_fc_end_date;
      l_eff_start_pa_period_num := pa_rep_util_glob.G_eff_fc_start_pa_period_num;
      l_eff_start_gl_period_num := pa_rep_util_glob.G_eff_fc_start_gl_period_num;
    END IF;

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '100:Balance Type is [' || l_balance_type_code || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '100:Start Date is [' || TO_CHAR(l_start_date) || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '100:End Date is [' || TO_CHAR(l_end_date) || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '100:Effective PA start period num is [' || TO_CHAR(l_eff_start_pa_period_num) || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '100:Effective GL start period num is [' || TO_CHAR(l_eff_start_gl_period_num) || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Determining the maximum level in the hierarchy for rollup.
     */
    SELECT parent_level
      INTO l_maximum_level
      FROM pa_org_hierarchy_denorm
     WHERE parent_organization_id = l_start_org_id
       AND pa_org_use_type = 'REPORTING'
       AND ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
       AND NVL(org_id, -99) = l_org_id
       AND ROWNUM = 1;
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '150:Maximum Level is [' || TO_CHAR(l_maximum_level) || ']';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Create Missing objects pa_objects for organizations.
     */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '150:Before Calling create_missing_parent_objects';
    PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    END IF;

    create_missing_parent_objects(p_balance_type_code  => l_balance_type_code);
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '175:After Calling create_missing_parent_objects';

       PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
    END IF;

    IF (l_pa_period_flag = 'Y') THEN

      /*
       * Call the org_rollup_pagl_period_type procedure with parameters.
       */
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '200:Before calling org_rollup_pagl_period_type for [' || l_period_type_pa || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;
      org_rollup_pagl_period_type( p_balance_type_code          => l_balance_type_code
                                  ,p_period_type                => l_period_type_pa
                                  ,p_effective_start_period_num => l_eff_start_pa_period_num
                                 );
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '250:After calling org_rollup_pagl_period_type for [' || l_period_type_pa || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;

    END IF; -- Check for PA flag


    IF (l_gl_period_flag = 'Y') THEN

      /*
       * Call the org rollup procedure with parameters.
       */

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '300:Before calling org_rollup_pagl_period_type for [' || l_period_type_gl || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;
      org_rollup_pagl_period_type( p_balance_type_code          => l_balance_type_code
                                  ,p_period_type                => l_period_type_gl
                                  ,p_effective_start_period_num => l_eff_start_gl_period_num
                                 );
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '350:After calling org_rollup_pagl_period_type for [' || l_period_type_gl || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;

    END IF; -- Check for GL flag.

    IF (l_ge_period_flag = 'Y') THEN
      /*
       * Call the org rollup procedure with parameters.
       */
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '400:Before calling org_rollup_ge_period_type for [' || l_period_type_ge || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;
      org_rollup_ge_period_type( p_balance_type_code      => l_balance_type_code
                                ,p_period_type            => l_period_type_ge
                                ,p_start_date             => l_start_date
                                ,p_end_date               => l_end_date
                               );
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '450:After calling org_rollup_ge_period_type for [' || l_period_type_ge || ']';
      PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
      END IF;
    END IF; -- Check for GE flag.

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := '500:Leaving refresh_org_hierarchy_rollup';
  PA_DEBUG.log_message('refresh_org_hierarchy_rollup: ' || PA_DEBUG.g_err_stage);
  END IF;
  PA_DEBUG.reset_curr_function;
  END refresh_org_hierarchy_rollup;
----------------------------------------------------------------
  /*
   * If the Generate Utilization process is run in the 'Refresh' mode
   * While creating the detail level records, the summarization process
   * creates Objects for only those organization which have direct numbers.
   *
   * During the rollup process, balances are to be rolled-up to the
   * parent organizations, even if that organization doesnt' have
   * that corresponding object.
   *
   * To handle this situation, before entering into the rollup process
   * we create objects for the parent, grand-parent organizations
   * depending on the objects their child, grand-child organizations have.
   *
   * Rule: If any of the children of an organization has an object
   * the parent organization must have that object.
   */

  PROCEDURE create_missing_parent_objects(p_balance_type_code IN VARCHAR2)
  IS

    l_object_type_code         pa_objects.object_type_code%TYPE;
    l_org_util_category_id     pa_objects.org_util_category_id%TYPE;
    l_work_type_id             pa_objects.work_type_id%TYPE;
    l_parent_organization_id   pa_objects.expenditure_organization_id%TYPE;

    l_dummy                    VARCHAR2(1);

    /*
     * The following cursor - selects a set of objects the parent organizations
     * should have based on the objects its child organizations have.
     */

    CURSOR cur_unique_objects_per_parent( p_level             IN PLS_INTEGER
                                         ,p_balance_type_code IN pa_objects.balance_type_code%TYPE
                                        )
    IS
      SELECT obj.object_type_code
            ,obj.org_util_category_id
            ,obj.work_type_id
            ,hier.parent_organization_id
        FROM pa_objects                   obj
            ,pa_org_hierarchy_denorm      hier
       WHERE hier.child_organization_id = obj.expenditure_organization_id
         AND hier.pa_org_use_type = 'REPORTING'
         AND hier.ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
         AND hier.parent_level = p_level
         AND hier.parent_level = hier.child_level + 1
         AND NVL(hier.org_id,-99) = l_org_id
         AND obj.expenditure_org_id = l_org_id
         AND obj.balance_type_code = p_balance_type_code
         AND obj.object_type_code IN ( l_obj_type_orgwt
                                      ,l_obj_type_orguc
                                      ,l_obj_type_org
                                     )
         AND obj.project_org_id = -1
         AND obj.project_organization_id = -1
         AND obj.project_id = -1
         AND obj.task_id = -1
         AND obj.person_id = -1
       GROUP BY obj.object_type_code
               ,obj.org_util_category_id
               ,obj.work_type_id
               ,hier.parent_organization_id
       ;

  BEGIN
    pa_debug.set_curr_function('create_missing_parent_objects');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.g_err_stage := '50:Inside create_missing_parent_objects';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    pa_debug.g_err_stage := '50:l_start_org_id = [' || to_char(l_start_org_id) || ']';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    pa_debug.g_err_stage := '50:l_org_id       = [' || to_char(l_org_id) || ']';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    pa_debug.g_err_stage := '50:max_level      = [' || to_char(l_maximum_level) || ']';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    pa_debug.g_err_stage := '50:bal_type_code  = [' || p_balance_type_code || ']';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
     pa_debug.g_err_stage := '50:orgwt          = [' || l_obj_type_orgwt || ']';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    pa_debug.g_err_stage := '50:orguc          = [' || l_obj_type_orguc || ']';
     pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
     pa_debug.g_err_stage := '50:org            = [' || l_obj_type_org || ']';
     pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    END IF;

    FOR l_level IN 2 .. l_maximum_level
    LOOP
    /*
     * Loop for each level.
     */
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.g_err_stage := '100:Opening cursor for level [' || to_char(l_level) || ']';
       pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
      END IF;

      OPEN cur_unique_objects_per_parent( l_level
                                         ,p_balance_type_code
                                        );
      LOOP
      /*
       * Loop for all object combinations at this level.
       * Fetching one object combination for this level.
       */
        FETCH cur_unique_objects_per_parent
         INTO l_object_type_code
             ,l_org_util_category_id
             ,l_work_type_id
             ,l_parent_organization_id ;

        IF cur_unique_objects_per_parent%NOTFOUND
        THEN
          /*
           * No more object combination exists.
           */
          EXIT;
        END IF;

        /*
         * Individual Pl/sql block because we got to handle exception.
         */
        BEGIN

          /*
           * Check whether the object combination already exist for the parent.
           * If it exists, do nothing. Else insert.
           */
          SELECT 'X'
            INTO l_dummy
            FROM pa_objects obj
           WHERE obj.object_type_code = l_object_type_code
             AND obj.balance_type_code = p_balance_type_code
             AND obj.work_type_id = l_work_type_id
             AND obj.org_util_category_id = l_org_util_category_id
             AND obj.expenditure_organization_id = l_parent_organization_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

          /*
           * If control comes here, object doesnt exists. Insert.
           */

          INSERT
            INTO pa_objects( object_id
                            ,object_type_code
                            ,balance_type_code
                            ,project_org_id
                            ,project_organization_id
                            ,project_id
                            ,task_id
                            ,expenditure_org_id
                            ,expenditure_organization_id
                            ,person_id
                            ,assignment_id
                            ,work_type_id
                            ,org_util_category_id
                            ,res_util_category_id
                            ,expenditure_type
                            ,expenditure_type_class
                            ,last_update_date
                            ,last_updated_by
                            ,creation_date
                            ,created_by
                            ,last_update_login
                            ,request_id
                            ,program_application_id
                            ,program_id
                            ,program_update_date
                           )
          VALUES( pa_objects_s.nextval
                 ,l_object_type_code
                 ,p_balance_type_code
                 ,-1
                 ,-1
                 ,-1
                 ,-1
                 ,l_org_id
                 ,l_parent_organization_id
                 ,-1
                 ,-1
                 ,l_work_type_id
                 ,l_org_util_category_id
                 ,-1
                 ,-1
                 ,-1
                 ,SYSDATE
                 ,-1
                 ,SYSDATE
                 ,-1
                 ,-1
                 ,-1
                 ,-1
                 ,-1
                 ,SYSDATE
                );


        END;
      END LOOP; -- Loop for records in this level.
      CLOSE cur_unique_objects_per_parent; -- Closing cursor for this level.
    END LOOP;  -- Loop for level in hierarchy.
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.g_err_stage := '150:Leaving create_missing_parent_objects';
    pa_debug.log_message('create_missing_parent_objects: ' || pa_debug.g_err_stage);
    END IF;

    pa_debug.reset_curr_function;
  END create_missing_parent_objects;
----------------------------------------------------------------
  /*
   * The following procedure does the organization rollup for a
   * 'PA' and 'GL' period types.
   */
  PROCEDURE org_rollup_pagl_period_type( p_balance_type_code          IN VARCHAR2
                                        ,p_period_type                IN VARCHAR2
                                        ,p_effective_start_period_num IN PLS_INTEGER
                                       )
  IS

    /*
     * Cursor to insert tot_num records same as that of
     * dir_num records.
     */
    CURSOR cur_org_dir_balances_pagl( p_start_org_id                IN pa_implementations_all.start_organization_id%TYPE
                                     ,p_balance_type_code           IN pa_objects.balance_type_code%TYPE
                                     ,p_maximum_level               IN PLS_INTEGER
                                     ,p_period_type                 IN VARCHAR2
                                     ,p_effective_start_period_num  IN PLS_INTEGER
                                     ,p_org_id                      IN pa_implementations_all.org_id%TYPE
                                    )
        IS SELECT bal.object_id
                 ,bal.object_type_code
                 ,bal.period_name
                 ,bal.period_year
                 ,bal.quarter_or_month_number
                 ,bal.amount_type_id
                 ,bal.period_num
                 ,bal.period_balance
             FROM pa_org_hierarchy_denorm hier
                 ,pa_summ_balances        bal
                 ,pa_objects              obj
            WHERE hier.parent_organization_id = p_start_org_id
              AND hier.parent_level = p_maximum_level
              AND NVL(hier.org_id,-99) = p_org_id
              AND hier.pa_org_use_type = 'REPORTING'
              AND hier.ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
              AND bal.object_id = obj.object_id
              AND bal.version_id = -1
              AND bal.period_num >= p_effective_start_period_num
              AND bal.period_type = p_period_type
--              AND bal.period_set_name = l_period_set_name
              AND bal.period_set_name = decode(bal.period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name) -- bug 3434019
              AND bal.object_type_code = obj.object_type_code
              AND obj.expenditure_organization_id = hier.child_organization_id
              AND obj.expenditure_org_id = p_org_id
              AND obj.balance_type_code = p_balance_type_code
              AND obj.project_org_id = -1
              AND obj.project_organization_id = -1
              AND obj.project_id = -1
              AND obj.task_id = -1
              AND obj.assignment_id = -1
              AND obj.person_id = -1
              AND obj.object_type_code IN ( l_obj_type_orgwt
                                           ,l_obj_type_orguc
                                           ,l_obj_type_org
                                          )
              AND bal.amount_type_id IN ( l_org_dir_hrs_id
                                         ,l_org_dir_wtdhrs_org_id
                                         ,l_org_dir_prvhrs_id
                                         ,l_org_dir_prvwtdhrs_org_id
                                         ,l_org_dir_cap_id
                                         ,l_org_dir_reducedcap_id
                                        );


    /*
     * Cursor for getting the level-wise sub-org numbers.
     */
    CURSOR cur_org_sub_balances_pagl( p_level_number               IN PLS_INTEGER
                                     ,p_balance_type_code          IN pa_objects.balance_type_code%TYPE
                                     ,p_period_type                IN VARCHAR2
                                     ,p_effective_start_period_num IN PLS_INTEGER
                                     ,p_org_id                     IN pa_implementations_all.org_id%TYPE
                                    )
        IS SELECT MAX(obj1.object_id)
                 ,obj.object_type_code
                 ,bal.period_name
                 ,MAX(bal.period_year)
                 ,MAX(bal.quarter_or_month_number)
                 ,bal.amount_type_id
                 ,MAX(bal.period_num)
                 ,SUM(bal.period_balance)
             FROM pa_summ_balances             bal
                 ,pa_objects                   obj
                 ,pa_objects                   obj1
                 ,pa_org_hierarchy_denorm      hier
            WHERE obj1.object_type_code = obj.object_type_code
              AND obj1.balance_type_code = obj.balance_type_code
              AND obj1.project_org_id = obj.project_org_id
              AND obj1.project_organization_id = obj.project_organization_id
              AND obj1.project_id = obj.project_id
              AND obj1.task_id = obj.task_id
              AND obj1.expenditure_organization_id = hier.parent_organization_id
              AND obj1.expenditure_org_id = obj.expenditure_org_id
              AND obj1.assignment_id = obj.assignment_id
              AND obj1.person_id = obj.person_id
              AND obj1.org_util_category_id = obj.org_util_category_id
              AND obj1.work_type_id = obj.work_type_id
              AND obj.balance_type_code = p_balance_type_code
              AND obj.project_org_id = -1
              AND obj.project_organization_id = -1
              AND obj.project_id = -1
              AND obj.task_id = -1
              AND obj.expenditure_org_id = p_org_id
              AND obj.expenditure_organization_id = hier.child_organization_id
              AND obj.assignment_id = -1
              AND obj.person_id = -1
              AND NVL(hier.org_id,-99) = p_org_id
              AND hier.pa_org_use_type = 'REPORTING'
              AND hier.ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
              AND hier.parent_level = p_level_number
              AND hier.parent_level = hier.child_level + 1
              AND bal.object_id = obj.object_id
              AND bal.object_type_code = obj.object_type_code
              AND bal.version_id = -1
              AND bal.period_num >= p_effective_start_period_num
              AND bal.period_type = p_period_type
--            AND bal.period_set_name = l_period_set_name
              AND bal.period_set_name = decode(bal.period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name) -- bug 3434019
              AND bal.amount_type_id IN ( l_org_tot_hrs_id
                                         ,l_org_tot_wtdhrs_org_id
                                         ,l_org_tot_prvhrs_id
                                         ,l_org_tot_prvwtdhrs_org_id
                                         ,l_org_tot_cap_id
                                         ,l_org_tot_reducedcap_id
                                        )
              AND obj.object_type_code IN ( l_obj_type_orgwt
                                           ,l_obj_type_orguc
                                           ,l_obj_type_org
                                        )
            GROUP BY hier.parent_organization_id
                    ,obj.object_type_code
                    ,obj.org_util_category_id
                    ,obj.work_type_id
                    ,bal.period_name
--                  ,bal.global_exp_period_end_date
                    ,bal.amount_type_id;

  /*
   * Tables to hold fetched values.
   */
  l_object_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
  l_object_type_code_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_period_name_tab                PA_PLSQL_DATATYPES.Char15TabTyp;
--  l_ge_period_end_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
  l_period_year_tab                PA_PLSQL_DATATYPES.NumTabTyp;
  l_quarter_or_month_number_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_type_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_period_num_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_period_balance_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_sub_org_total_tab              PA_PLSQL_DATATYPES.NumTabTyp;

  l_bunch_size        PLS_INTEGER := 100;
  l_this_fetch        PLS_INTEGER;
  l_totally_fetched   PLS_INTEGER;
  l_this_commit_cycle PLS_INTEGER;

  l_rowcount number :=0;

  BEGIN

    PA_DEBUG.set_curr_function('org_rollup_pagl_period_type');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '50:Inside org_rollup_pagl_period_type';
    PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Delete all total and sub-org numbers from pa_summ_balances.
     */
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '100:Deleting Total and Sub-org Records';
    PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;
    LOOP
      DELETE
        FROM pa_summ_balances    bal
       WHERE bal.amount_type_id IN ( l_org_sub_hrs_id
                                    ,l_org_sub_wtdhrs_org_id
                                    ,l_org_sub_prvhrs_id
                                    ,l_org_sub_prvwtdhrs_org_id
                                    ,l_org_sub_cap_id
                                    ,l_org_sub_reducedcap_id
                                    ,l_org_tot_hrs_id
                                    ,l_org_tot_wtdhrs_org_id
                                    ,l_org_tot_prvhrs_id
                                    ,l_org_tot_prvwtdhrs_org_id
                                    ,l_org_tot_cap_id
                                    ,l_org_tot_reducedcap_id
                                   )
         AND bal.object_type_code IN ( l_obj_type_orgwt
                                      ,l_obj_type_orguc
                                      ,l_obj_type_org
                                     )
         AND bal.period_num >= p_effective_start_period_num
         AND period_type = p_period_type
         AND ROWNUM <= l_fetch_size
         AND EXISTS ( SELECT NULL
                        FROM pa_objects   obj
                       WHERE obj.balance_type_code = p_balance_type_code
                         AND obj.object_id = bal.object_id
                         AND obj.expenditure_org_id = l_org_id
                    );

	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '150:Deleted [' || TO_CHAR(l_rowcount) || '] records';
      PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * Exit when no more records left to delete.
       */
      IF (l_rowcount = 0 OR l_rowcount < l_fetch_size) THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '200:All Total and Sub-org records deleted.';
         PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;
        EXIT;
      END IF;
      COMMIT;
    END LOOP;

    /*
     * Set the Total numbers equal to the direct
     * numbers for all the orgs.
     */
    /*
     * A set of records equalling the bunch_size are dumped
     * into plsql tables and then they are bulk inserted into
     * the table.
     * Since, we have already deleted all the total records,
     * 'upsert' is NOT needed. ONLY insert.
     */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '250:Opening Direct-number Cursor.';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Start Org id is [' || l_start_org_id || ']';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Balance Type is [' || p_balance_type_code || ']';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Effective Start Period Number is [' || p_effective_start_period_num || ']';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Org Id is [' || l_org_id || ']';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    OPEN cur_org_dir_balances_pagl( l_start_org_id
                                   ,p_balance_type_code
                                   ,l_maximum_level
                                   ,p_period_type
                                   ,p_effective_start_period_num
                                   ,l_org_id
                                  );
    /*
     * Resetting fetch-related variables.
     */
    l_this_fetch        := 0;
    l_this_commit_cycle := 0;
    l_totally_fetched   := 0;
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '300:Fetching Direct-number Cursor.';
    PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    LOOP
      FETCH cur_org_dir_balances_pagl
       BULK COLLECT
        INTO l_object_id_tab
            ,l_object_type_code_tab
            ,l_period_name_tab
            ,l_period_year_tab
            ,l_quarter_or_month_number_tab
            ,l_amount_type_id_tab
            ,l_period_num_tab
            ,l_period_balance_tab
       LIMIT l_bunch_size;

      l_this_fetch := cur_org_dir_balances_pagl%ROWCOUNT - l_totally_fetched;
      l_this_commit_cycle := l_this_commit_cycle + l_this_fetch;
      l_totally_fetched := cur_org_dir_balances_pagl%ROWCOUNT;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '350:Fetched [' || l_this_fetch || '] Direct-number records';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      IF (l_this_fetch = 0) THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '400:No more Direct-number records to fetch. Exiting';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;
        EXIT;
      END IF;


      FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
        INSERT
          INTO pa_summ_balances( object_id
                                 ,version_id
                                 ,object_type_code
                                 ,period_type
                                 ,period_set_name
                                 ,period_name
                                 ,global_exp_period_end_date
                                 ,period_year
                                 ,quarter_or_month_number
                                 ,amount_type_id
                                 ,period_num
                                 ,unit_of_measure
                                 ,period_balance
                                 ,pvdr_currency_code
                                 ,pvdr_period_balance
                                )
        VALUES( l_object_id_tab(i)
               ,-1
               ,l_object_type_code_tab(i)
               ,p_period_type
--             ,l_period_set_name
               ,decode(p_period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name) -- bug 3434019
               ,l_period_name_tab(i)
               ,l_dummy_date
               ,l_period_year_tab(i)
               ,l_quarter_or_month_number_tab(i)
               ,DECODE(l_amount_type_id_tab(i)
                              ,l_org_dir_hrs_id,l_org_tot_hrs_id
                              ,l_org_dir_wtdhrs_org_id, l_org_tot_wtdhrs_org_id
                              ,l_org_dir_prvhrs_id, l_org_tot_prvhrs_id
                              ,l_org_dir_prvwtdhrs_org_id, l_org_tot_prvwtdhrs_org_id
                              ,l_org_dir_cap_id, l_org_tot_cap_id
                              ,l_org_dir_reducedcap_id, l_org_tot_reducedcap_id
                              ,-1                                                        --is this ok??
                      )
               ,l_period_num_tab(i)
               ,l_unit_of_measure
               ,l_period_balance_tab(i)
               ,NULL
               ,NULL
              );
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '450:Inserted [' || SQL%ROWCOUNT || '] Total-number records';
      PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * Commit if no. of records inserted is more than or
       * equal to the fetch size.
       */
      IF (l_this_commit_cycle >= l_commit_size) THEN
        COMMIT;
        l_this_commit_cycle := 0;
      END IF;

      IF (l_this_fetch < l_bunch_size) THEN
        /*
         * Indicates last fetch.
         */
        COMMIT;
        EXIT;
      END IF;
    END LOOP; -- End of loop to insert total number records.
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '500:Closing Direct-number Cursor.';
    PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    CLOSE cur_org_dir_balances_pagl;

    /*
     * Insert the sub-org number records.
     */
    FOR l_level IN 2 .. l_maximum_level
     LOOP
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.g_err_stage := '550:Opening Sub-org Cursor for Level [' || l_level || ']';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
       PA_DEBUG.g_err_stage := '550:Balance Type is [' || p_balance_type_code || ']';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
       PA_DEBUG.g_err_stage := '550:Effective Start Period num is [' || p_effective_start_period_num || ']';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
       PA_DEBUG.g_err_stage := '550:Org Id is [' || l_org_id || ']';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
       END IF;

       OPEN cur_org_sub_balances_pagl( l_level
                                      ,p_balance_type_code
                                      ,p_period_type
                                      ,p_effective_start_period_num
                                      ,l_org_id
                                     );
      /*
       * Resetting fetch related variables.
       */
      l_this_fetch        := 0;
      l_this_commit_cycle := 0;
      l_totally_fetched   := 0;

       LOOP
         FETCH cur_org_sub_balances_pagl
          BULK COLLECT
           INTO l_object_id_tab
               ,l_object_type_code_tab
               ,l_period_name_tab
               ,l_period_year_tab
               ,l_quarter_or_month_number_tab
               ,l_amount_type_id_tab
               ,l_period_num_tab
               ,l_sub_org_total_tab
          LIMIT l_bunch_size;

        l_this_fetch := cur_org_sub_balances_pagl%ROWCOUNT - l_totally_fetched;
        l_this_commit_cycle := l_this_commit_cycle + l_this_fetch;
        l_totally_fetched := cur_org_sub_balances_pagl%ROWCOUNT;
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '600:Fetched [' || l_this_fetch || '] Sub-org records';
        PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;
        IF (l_this_fetch = 0) THEN
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.g_err_stage := '650:No more Sub-org records left for level [' || l_level || '] Exiting';
           PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
          END IF;
          EXIT;
        END IF;

        FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
          INSERT
            INTO pa_summ_balances( object_id
                                  ,version_id
                                  ,object_type_code
                                  ,period_type
                                  ,period_set_name
                                  ,period_name
                                  ,global_exp_period_end_date
                                  ,period_year
                                  ,quarter_or_month_number
                                  ,amount_type_id
                                  ,period_num
                                  ,unit_of_measure
                                  ,period_balance
                                  ,pvdr_currency_code
                                  ,pvdr_period_balance
                                 )
          VALUES( l_object_id_tab(i)
                 ,-1
                 ,l_object_type_code_tab(i)
                 ,p_period_type
--               ,l_period_set_name
                 ,decode(p_period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name)  -- bug 3434019
                 ,l_period_name_tab(i)
                 ,l_dummy_date
                 ,l_period_year_tab(i)
                 ,l_quarter_or_month_number_tab(i)
                 ,DECODE(l_amount_type_id_tab(i)
                                ,l_org_tot_hrs_id ,l_org_sub_hrs_id
                                ,l_org_tot_wtdhrs_org_id ,l_org_sub_wtdhrs_org_id
                                ,l_org_tot_prvhrs_id ,l_org_sub_prvhrs_id
                                ,l_org_tot_prvwtdhrs_org_id ,l_org_sub_prvwtdhrs_org_id
                                ,l_org_tot_cap_id ,l_org_sub_cap_id
                                ,l_org_tot_reducedcap_id ,l_org_sub_reducedcap_id
                                ,-1
                        )
                 ,l_period_num_tab(i)
                 ,l_unit_of_measure
                 ,l_sub_org_total_tab(i)
                 ,NULL
                 ,NULL
                );
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '700:Inserted [' || SQL%ROWCOUNT || '] Sub-org records';
      PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;
      /*
       * Update the tot_num records with tot_num = tot_num + sub_org
       */
      FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
        UPDATE pa_summ_balances bal
           SET bal.period_balance = bal.period_balance + l_sub_org_total_tab(i)
         WHERE bal.object_id = l_object_id_tab(i)
           AND bal.version_id = -1
           AND bal.object_type_code = l_object_type_code_tab(i)
           AND bal.period_type = p_period_type
--         AND bal.period_set_name = l_period_set_name
           AND bal.period_set_name = decode(bal.period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name) -- bug 3434019
           AND bal.period_name = l_period_name_tab(i)
--           AND bal.global_exp_period_end_date = l_ge_period_end_date_tab(i)
           AND bal.global_exp_period_end_date = l_dummy_date
           AND bal.period_year = l_period_year_tab(i)
           AND bal.quarter_or_month_number = l_quarter_or_month_number_tab(i)
           AND bal.amount_type_id = l_amount_type_id_tab(i)
           AND bal.period_num = l_period_num_tab(i)
           AND bal.unit_of_measure = l_unit_of_measure
           AND bal.pvdr_currency_code IS NULL
           AND bal.pvdr_period_balance IS NULL;

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '750:Updated [' || SQL%ROWCOUNT || '] Total Records with T=T+S';
      PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * If UPDATE didnt' go thro for a particular combination, that means
       * that that particular combination doesnt already exist in the table.
       * so INSERT.
       */
      FOR i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
      LOOP
        IF (SQL%BULK_ROWCOUNT(i) = 0) THEN
        /*
         * Update didnt' go thro' so, INSERT.
         */
        INSERT
          INTO pa_summ_balances( object_id
                                 ,version_id
                                 ,object_type_code
                                 ,period_type
                                 ,period_set_name
                                 ,period_name
                                 ,global_exp_period_end_date
                                 ,period_year
                                 ,quarter_or_month_number
                                 ,amount_type_id
                                 ,period_num
                                 ,unit_of_measure
                                 ,period_balance
                                 ,pvdr_currency_code
                                 ,pvdr_period_balance
                                )
        VALUES( l_object_id_tab(i)
               ,-1
               ,l_object_type_code_tab(i)
               ,p_period_type
--             ,l_period_set_name
               ,decode(p_period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name)  -- bug 3434019
               ,l_period_name_tab(i)
               ,l_dummy_date
               ,l_period_year_tab(i)
               ,l_quarter_or_month_number_tab(i)
               ,l_amount_type_id_tab(i)
               ,l_period_num_tab(i)
               ,l_unit_of_measure
               ,l_sub_org_total_tab(i)
               ,NULL
               ,NULL
              );
        END IF;
      END LOOP; -- Loop to check whether the record was updated.
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '800:After Inserting Total Records.';
      PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

        /*
         * Commit if no. of records inserted is more than or
         * equal to the fetch size.
         */
        IF (l_this_commit_cycle >= l_commit_size) THEN
          l_this_commit_cycle := 0;
          COMMIT;
        END IF;

        IF (l_this_fetch < l_bunch_size) THEN
          COMMIT;
          EXIT;
        END IF;
      END LOOP; -- loop for each of the levels.
      CLOSE cur_org_sub_balances_pagl;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '850:After Closing Sub-org Cursor.';
       PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

    END LOOP; -- End of loop to insert sub-org number records.
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '900:Finished creating Sub-org and total Records for all Levels.';
    PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := '950:Leaving org_rollup_pagl_period_type';
  PA_DEBUG.log_message('org_rollup_pagl_period_type: ' || PA_DEBUG.g_err_stage);
  END IF;
  PA_DEBUG.reset_curr_function;

  END org_rollup_pagl_period_type;

------------------------------------------------------------------
  /*
   * The following procedure does the organization rollup for
   * the 'GE' period type.
   */
  PROCEDURE org_rollup_ge_period_type( p_balance_type_code   IN VARCHAR2
                                      ,p_period_type         IN VARCHAR2
                                      ,p_start_date          IN DATE
                                      ,p_end_date            IN DATE
                                     )
  IS
    /*
     * Cursor to insert tot_num records same as that of
     * dir_num records.
     */
    CURSOR cur_org_dir_balances_ge( p_start_org_id        IN pa_implementations_all.start_organization_id%TYPE
                                   ,p_balance_type_code   IN pa_objects.balance_type_code%TYPE
                                   ,p_maximum_level       IN PLS_INTEGER
                                   ,p_period_type         IN VARCHAR2
                                   ,p_start_date          IN DATE
                                   ,p_end_date            IN DATE
                                   ,p_org_id              IN pa_implementations_all.org_id%TYPE
                                  )
        IS SELECT bal.object_id
                 ,bal.object_type_code
                 ,bal.period_name
                 ,bal.global_exp_period_end_date
                 ,bal.period_year
                 ,bal.quarter_or_month_number
                 ,bal.amount_type_id
                 ,bal.period_balance
             FROM pa_org_hierarchy_denorm hier
                 ,pa_summ_balances        bal
                 ,pa_objects              obj
            WHERE hier.parent_organization_id = p_start_org_id
              AND hier.parent_level = p_maximum_level
              AND NVL(hier.org_id,-99) = p_org_id
              AND hier.pa_org_use_type = 'REPORTING'
              AND hier.ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
              AND bal.object_id = obj.object_id
              AND bal.version_id = -1
              AND bal.global_exp_period_end_date >= p_start_date
              AND bal.period_type = p_period_type
              AND bal.object_type_code = obj.object_type_code
              AND obj.expenditure_organization_id = hier.child_organization_id
              AND obj.expenditure_org_id = p_org_id
              AND obj.balance_type_code = p_balance_type_code
              AND obj.project_org_id = -1
              AND obj.project_organization_id = -1
              AND obj.project_id = -1
              AND obj.task_id = -1
              AND obj.assignment_id = -1
              AND obj.person_id = -1
              AND obj.object_type_code IN ( l_obj_type_orgwt
                                           ,l_obj_type_orguc
                                           ,l_obj_type_org
                                          )
              AND bal.amount_type_id IN ( l_org_dir_hrs_id
                                         ,l_org_dir_wtdhrs_org_id
                                         ,l_org_dir_prvhrs_id
                                         ,l_org_dir_prvwtdhrs_org_id
                                         ,l_org_dir_cap_id
                                         ,l_org_dir_reducedcap_id
                                        );


    /*
     * Cursor for getting the level-wise sub-org numbers.
     */
    CURSOR cur_org_sub_balances_ge( p_level_number               IN PLS_INTEGER
                                   ,p_balance_type_code          IN pa_objects.balance_type_code%TYPE
                                   ,p_period_type                IN VARCHAR2
                                   ,p_start_date                 IN DATE
                                   ,p_end_date                   IN DATE
                                   ,p_org_id                     IN pa_implementations_all.org_id%TYPE
                                  )
        IS SELECT MAX(obj1.object_id)
                 ,obj.object_type_code
                 ,bal.period_name
                 ,bal.global_exp_period_end_date
                 ,MAX(bal.period_year)
                 ,MAX(bal.quarter_or_month_number)
                 ,bal.amount_type_id
                 ,SUM(bal.period_balance)
             FROM pa_summ_balances             bal
                 ,pa_objects                   obj
                 ,pa_objects                   obj1
                 ,pa_org_hierarchy_denorm      hier
            WHERE obj1.object_type_code = obj.object_type_code
              AND obj1.balance_type_code = obj.balance_type_code
              AND obj1.project_org_id = obj.project_org_id
              AND obj1.project_organization_id = obj.project_organization_id
              AND obj1.project_id = obj.project_id
              AND obj1.task_id = obj.task_id
              AND obj1.expenditure_organization_id = hier.parent_organization_id
              AND obj1.expenditure_org_id = obj.expenditure_org_id
              AND obj1.assignment_id = obj.assignment_id
              AND obj1.person_id = obj.person_id
              AND obj1.org_util_category_id = obj.org_util_category_id
              AND obj1.work_type_id = obj.work_type_id
              AND obj.balance_type_code = p_balance_type_code
              AND obj.project_org_id = -1
              AND obj.project_organization_id = -1
              AND obj.project_id = -1
              AND obj.task_id = -1
              AND obj.expenditure_org_id = p_org_id
              AND obj.expenditure_organization_id = hier.child_organization_id
              AND obj.assignment_id = -1
              AND obj.person_id = -1
              AND NVL(hier.org_id,-99) = p_org_id
              AND hier.pa_org_use_type = 'REPORTING'
              AND hier.ORG_HIERARCHY_VERSION_ID = l_org_structure_version_id
              AND hier.parent_level = p_level_number
              AND hier.parent_level = hier.child_level + 1
              AND bal.object_id = obj.object_id
              AND bal.object_type_code = obj.object_type_code
              AND bal.version_id = -1
              AND bal.global_exp_period_end_date >= p_start_date
              AND bal.period_type = p_period_type
              AND bal.amount_type_id IN ( l_org_tot_hrs_id
                                         ,l_org_tot_wtdhrs_org_id
                                         ,l_org_tot_prvhrs_id
                                         ,l_org_tot_prvwtdhrs_org_id
                                         ,l_org_tot_cap_id
                                         ,l_org_tot_reducedcap_id
                                        )
              AND obj.object_type_code IN ( l_obj_type_orgwt
                                           ,l_obj_type_orguc
                                           ,l_obj_type_org
                                        )
            GROUP BY hier.parent_organization_id
                    ,obj.object_type_code
                    ,obj.org_util_category_id
                    ,obj.work_type_id
                    ,bal.period_name
                    ,bal.global_exp_period_end_date
                    ,bal.amount_type_id;

  /*
   * Tables to hold fetched values.
   */
  l_object_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
  l_object_type_code_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_period_name_tab                PA_PLSQL_DATATYPES.Char15TabTyp;
  l_ge_period_end_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
  l_period_year_tab                PA_PLSQL_DATATYPES.NumTabTyp;
  l_quarter_or_month_number_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_type_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_period_balance_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_sub_org_total_tab              PA_PLSQL_DATATYPES.NumTabTyp;

  l_bunch_size        PLS_INTEGER := 100;
  l_this_fetch        PLS_INTEGER;
  l_totally_fetched   PLS_INTEGER;
  l_this_commit_cycle PLS_INTEGER;

/*Code Changes for Bug No.2984871 start */
  l_rowcount number :=0;
/*Code Changes for Bug No.2984871 end */

  BEGIN
    PA_DEBUG.set_curr_function('org_rollup_ge_period_type');
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '50:Inside org_rollup_ge_period_type';
    PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '100:Deleting Total and Sub-org Records';
    PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;
    /*
     * Delete all total and sub-org numbers from pa_summ_balances.
     */
    LOOP
      DELETE
        FROM pa_summ_balances    bal
       WHERE bal.amount_type_id IN ( l_org_sub_hrs_id
                                    ,l_org_sub_wtdhrs_org_id
                                    ,l_org_sub_prvhrs_id
                                    ,l_org_sub_prvwtdhrs_org_id
                                    ,l_org_sub_cap_id
                                    ,l_org_sub_reducedcap_id
                                    ,l_org_tot_hrs_id
                                    ,l_org_tot_wtdhrs_org_id
                                    ,l_org_tot_prvhrs_id
                                    ,l_org_tot_prvwtdhrs_org_id
                                    ,l_org_tot_cap_id
                                    ,l_org_tot_reducedcap_id
                                   )
         AND bal.object_type_code IN ( l_obj_type_orgwt
                                      ,l_obj_type_orguc
                                      ,l_obj_type_org
                                     )
         AND bal.global_exp_period_end_date >= p_start_date
         AND bal.period_type = p_period_type
         AND ROWNUM <= l_fetch_size
         AND EXISTS ( SELECT NULL
                        FROM pa_objects   obj
                       WHERE obj.balance_type_code = p_balance_type_code
                         AND obj.object_id = bal.object_id
                         AND obj.expenditure_org_id = l_org_id
                    );
	/*Code Changes for Bug No.2984871 start */
	l_rowcount:=sql%rowcount;
	/*Code Changes for Bug No.2984871 end */

      /*
       * Exit when no more records left to delete.
       */
      IF (l_rowcount = 0) THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '200:All Total and Sub-org records deleted.';
        PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;
        COMMIT;
        EXIT;
      END IF;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '150:Deleted [' || TO_CHAR(l_rowcount) || '] records';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;
      COMMIT;
    END LOOP;

    /*
     * Set the Total numbers equal to the direct
     * numbers for all the orgs.
     */
    /*
     * The plan is to dump a set of N records into plsql tables
     * and then do a bulk insert into the table.
     * Since, we have already deleted all the total records,
     * 'upsert' is NOT needed. ONLY insert.
     */
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '250:Opening Direct-number Cursor.';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Start Org id is [' || l_start_org_id || ']';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Balance Type is [' || p_balance_type_code || ']';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
       PA_DEBUG.g_err_stage := '250:Start Date is [' || p_start_date || ']';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:End Date is [' || p_end_date || ']';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        PA_DEBUG.g_err_stage := '250:Org Id is [' || l_org_id || ']';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    OPEN cur_org_dir_balances_ge( l_start_org_id
                                 ,p_balance_type_code
                                 ,l_maximum_level
                                 ,p_period_type
                                 ,p_start_date
                                 ,p_end_date
                                 ,l_org_id
                                );
    /*
     * Resetting fetch-related variables.
     */
    l_this_fetch        := 0;
    l_this_commit_cycle := 0;
    l_totally_fetched   := 0;
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '300:Fetching Direct-number Cursor.';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    LOOP
      FETCH cur_org_dir_balances_ge
       BULK COLLECT
        INTO l_object_id_tab
            ,l_object_type_code_tab
            ,l_period_name_tab
            ,l_ge_period_end_date_tab
            ,l_period_year_tab
            ,l_quarter_or_month_number_tab
            ,l_amount_type_id_tab
            ,l_period_balance_tab
       LIMIT l_bunch_size;

      l_this_fetch := cur_org_dir_balances_ge%ROWCOUNT - l_totally_fetched;
      l_this_commit_cycle := l_this_commit_cycle + l_this_fetch;
      l_totally_fetched := cur_org_dir_balances_ge%ROWCOUNT;

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '350:Fetched [' || l_this_fetch || '] Direct-number records';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      IF (l_this_fetch = 0) THEN
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '400:No more Direct-number records to fetch. Exiting';
        PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;
        EXIT;
      END IF;


      FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
        INSERT
          INTO pa_summ_balances( object_id
                                ,version_id
                                ,object_type_code
                                ,period_type
                                ,period_set_name
                                ,period_name
                                ,global_exp_period_end_date
                                ,period_year
                                ,quarter_or_month_number
                                ,amount_type_id
                                ,period_num
                                ,unit_of_measure
                                ,period_balance
                                ,pvdr_currency_code
                                ,pvdr_period_balance
                               )
        VALUES( l_object_id_tab(i)
               ,-1
               ,l_object_type_code_tab(i)
               ,p_period_type
--             ,l_dummy_period_set_name
               ,decode(p_period_type, pa_rep_util_glob.G_PERIOD_TYPE_C.G_PA_C, l_pa_period_set_name, l_gl_period_set_name) -- bug 3434019
               ,l_period_name_tab(i)
               ,l_ge_period_end_date_tab(i)
               ,l_period_year_tab(i)
               ,l_quarter_or_month_number_tab(i)
               ,DECODE(l_amount_type_id_tab(i)
                              ,l_org_dir_hrs_id,l_org_tot_hrs_id
                              ,l_org_dir_wtdhrs_org_id, l_org_tot_wtdhrs_org_id
                              ,l_org_dir_prvhrs_id, l_org_tot_prvhrs_id
                              ,l_org_dir_prvwtdhrs_org_id, l_org_tot_prvwtdhrs_org_id
                              ,l_org_dir_cap_id, l_org_tot_cap_id
                              ,l_org_dir_reducedcap_id, l_org_tot_reducedcap_id
                              ,-1                                                        --is this ok??
                      )
               ,-1
               ,l_unit_of_measure
               ,l_period_balance_tab(i)
               ,NULL
               ,NULL
              );

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '450:Inserted [' || SQL%ROWCOUNT || '] Total-number records';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * Commit if no. of records inserted is more than or
       * equal to the fetch size.
       */
      IF (l_this_commit_cycle >= l_commit_size) THEN
        COMMIT;
        l_this_commit_cycle := 0;
      END IF;

      IF (l_this_fetch < l_bunch_size) THEN
        /*
         * Indicates last fetch.
         */
        COMMIT;
        EXIT;
      END IF;
    END LOOP; -- End of loop to insert total number records.
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '500:Closing Direct-number Cursor.';
           PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

    CLOSE cur_org_dir_balances_ge;

    /*
     * Insert the sub-org number records.
     */
    FOR l_level IN 2 .. l_maximum_level
     LOOP
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.g_err_stage := '550:Opening Sub-org Cursor for Level [' || l_level || ']';
                 PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
          PA_DEBUG.g_err_stage := '550:Balance Type is [' || p_balance_type_code || ']';
                 PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
             PA_DEBUG.g_err_stage := '550:Start Date is [' || p_start_date || ']';
                 PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
             PA_DEBUG.g_err_stage := '550:End Date is [' || p_end_date || ']';
                 PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
              PA_DEBUG.g_err_stage := '550:Org Id is [' || l_org_id || ']';
                 PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
       END IF;

       OPEN cur_org_sub_balances_ge( l_level
                                    ,p_balance_type_code
                                    ,p_period_type
                                    ,p_start_date
                                    ,p_end_date
                                    ,l_org_id
                                  );
      /*
       * Resetting fetch related variables.
       */
      l_this_fetch        := 0;
      l_this_commit_cycle := 0;
      l_totally_fetched   := 0;

       LOOP
         FETCH cur_org_sub_balances_ge
          BULK COLLECT
           INTO l_object_id_tab
               ,l_object_type_code_tab
               ,l_period_name_tab
               ,l_ge_period_end_date_tab
               ,l_period_year_tab
               ,l_quarter_or_month_number_tab
               ,l_amount_type_id_tab
               ,l_sub_org_total_tab
          LIMIT l_bunch_size;

        l_this_fetch := cur_org_sub_balances_ge%ROWCOUNT - l_totally_fetched;
        l_this_commit_cycle := l_this_commit_cycle + l_this_fetch;
        l_totally_fetched := cur_org_sub_balances_ge%ROWCOUNT;

        IF (l_this_fetch = 0) THEN
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.g_err_stage := '650:No more Sub-org records left for level [' || l_level || '] Exiting';
          PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
          END IF;
          EXIT;
        END IF;
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.g_err_stage := '600:Fetched [' || l_this_fetch || '] Sub-org records';
        PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
        END IF;

        FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
          INSERT
            INTO pa_summ_balances( object_id
                                   ,version_id
                                   ,object_type_code
                                   ,period_type
                                   ,period_set_name
                                   ,period_name
                                   ,global_exp_period_end_date
                                   ,period_year
                                   ,quarter_or_month_number
                                   ,amount_type_id
                                   ,period_num
                                   ,unit_of_measure
                                   ,period_balance
                                   ,pvdr_currency_code
                                   ,pvdr_period_balance
                                  )
          VALUES( l_object_id_tab(i)
                 ,-1
                 ,l_object_type_code_tab(i)
                 ,p_period_type
                 ,l_dummy_period_set_name
                 ,l_period_name_tab(i)
                 ,l_ge_period_end_date_tab(i)
                 ,l_period_year_tab(i)
                 ,l_quarter_or_month_number_tab(i)
                 ,DECODE(l_amount_type_id_tab(i)
                                ,l_org_tot_hrs_id ,l_org_sub_hrs_id
                                ,l_org_tot_wtdhrs_org_id ,l_org_sub_wtdhrs_org_id
                                ,l_org_tot_prvhrs_id ,l_org_sub_prvhrs_id
                                ,l_org_tot_prvwtdhrs_org_id ,l_org_sub_prvwtdhrs_org_id
                                ,l_org_tot_cap_id ,l_org_sub_cap_id
                                ,l_org_tot_reducedcap_id ,l_org_sub_reducedcap_id
                                ,-1                                                    -- is this ok??
                        )
                 ,-1
                 ,l_unit_of_measure
                 ,l_sub_org_total_tab(i)
                 ,NULL
                 ,NULL
                );
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '700:Inserted [' || SQL%ROWCOUNT || '] Sub-org records';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * Update the tot_num records with tot_num = tot_num + sub_org
       * Some of the checks in the where clause may not be required.
       */
      FORALL i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
        UPDATE pa_summ_balances bal
           SET bal.period_balance = bal.period_balance + l_sub_org_total_tab(i)
         WHERE bal.object_id = l_object_id_tab(i)
           AND bal.version_id = -1
           AND bal.object_type_code = l_object_type_code_tab(i)
           AND bal.period_type = p_period_type
           AND bal.period_set_name = l_dummy_period_set_name
           AND bal.period_name = l_period_name_tab(i)
           AND bal.global_exp_period_end_date = l_ge_period_end_date_tab(i)
           AND bal.period_year = l_period_year_tab(i)
           AND bal.quarter_or_month_number = l_quarter_or_month_number_tab(i)
           AND bal.amount_type_id = l_amount_type_id_tab(i)
           AND bal.period_num = -1
           AND bal.unit_of_measure = l_unit_of_measure
           AND bal.pvdr_currency_code IS NULL
           AND bal.pvdr_period_balance IS NULL;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '750:Updated [' || SQL%ROWCOUNT || '] Total Records with T=T+S';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

      /*
       * If UPDATE didnt' go thro for a particular combination, that means
       * that that particular combination doesnt already exist in the table.
       * so INSERT.
       */
      FOR i IN l_object_id_tab.FIRST .. l_object_id_tab.LAST
      LOOP
        IF (SQL%BULK_ROWCOUNT(i) = 0) THEN
        /*
         * Update didnt' go thro' so, INSERT.
         */
        INSERT
          INTO pa_summ_balances( object_id
                                 ,version_id
                                 ,object_type_code
                                 ,period_type
                                 ,period_set_name
                                 ,period_name
                                 ,global_exp_period_end_date
                                 ,period_year
                                 ,quarter_or_month_number
                                 ,amount_type_id
                                 ,period_num
                                 ,unit_of_measure
                                 ,period_balance
                                 ,pvdr_currency_code
                                 ,pvdr_period_balance
                                )
        VALUES( l_object_id_tab(i)
               ,-1
               ,l_object_type_code_tab(i)
               ,p_period_type
               ,l_dummy_period_set_name
               ,l_period_name_tab(i)
               ,l_ge_period_end_date_tab(i)
               ,l_period_year_tab(i)
               ,l_quarter_or_month_number_tab(i)
               ,l_amount_type_id_tab(i)
               ,-1
               ,l_unit_of_measure
               ,l_sub_org_total_tab(i)
               ,NULL
               ,NULL
              );
        END IF;
      END LOOP; -- Loop to chek whether the record was updated.
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '800:After Inserting Total Records.';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

        /*
         * Commit if no. of records inserted is more than or
         * equal to the fetch size.
         */
        IF (l_this_commit_cycle >= l_commit_size) THEN
          l_this_commit_cycle := 0;
          COMMIT;
        END IF;

        IF (l_this_fetch < l_bunch_size) THEN
          COMMIT;
          EXIT;
        END IF;
      END LOOP; -- loop for each of the levels.
      CLOSE cur_org_sub_balances_ge;
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.g_err_stage := '850:After Closing Sub-org Cursor.';
      PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
      END IF;

    END LOOP; -- End of loop to insert sub-org number records.
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.g_err_stage := '900:Finished creating Sub-org and total Records for all Levels.';
    PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.g_err_stage := '950:Leaving org_rollup_ge_period_type';
   PA_DEBUG.log_message('org_rollup_ge_period_type: ' || PA_DEBUG.g_err_stage);
  END IF;
  PA_DEBUG.reset_curr_function;

  END org_rollup_ge_period_type;
------------------------------------------------------------------

END PA_SUMMARIZE_ORG_ROLLUP_PVT;

/
