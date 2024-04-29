--------------------------------------------------------
--  DDL for Package Body PA_FP_EDIT_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_EDIT_LINE_PKG" AS
/* $Header: PAFPEDLB.pls 120.2 2005/09/26 11:26:14 rnamburi noship $ */

l_module_name VARCHAR2(30) := 'pa.plsql.PA_FP_EDIT_LINE_PKG';

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception EXCEPTION;

/* Bug 2672548 - Populate_local_varaiables would derive PD/SD start and end dates by
   calling DERIVE_PD_SD_START_END_DATES if they are not available in budget lines.
*/

PROCEDURE POPULATE_LOCAL_VARIABLES(
          p_resource_assignment_id     IN  pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
         ,p_txn_currency_code          IN  pa_budget_lines.TXN_CURRENCY_CODE%TYPE
         ,p_calling_context            IN  VARCHAR2
         ,x_preceding_prd_start_date   OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_prd_end_date     OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_start_date  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_end_date    OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_period_profile_start_date  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_period_profile_end_date    OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_period_profile_id          OUT NOCOPY pa_budget_versions.period_profile_id%TYPE --File.Sql.39 bug 4440895
         ,x_time_phased_code           OUT NOCOPY pa_proj_fp_options.cost_time_phased_code%TYPE --File.Sql.39 bug 4440895
         ,x_fin_plan_version_id        OUT NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
         ,x_fin_plan_level_code        OUT NOCOPY pa_proj_fp_options.cost_fin_plan_level_code%TYPE --File.Sql.39 bug 4440895
         ,x_project_start_date         OUT NOCOPY pa_projects_all.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_project_end_date           OUT NOCOPY pa_projects_all.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_task_start_date            OUT NOCOPY pa_projects_all.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_task_end_date              OUT NOCOPY pa_projects_all.start_date%TYPE --File.Sql.39 bug 4440895
         ,x_plan_period_type           OUT NOCOPY pa_proj_period_profiles.plan_period_type%TYPE --File.Sql.39 bug 4440895
         ,x_period_set_name            OUT NOCOPY pa_proj_period_profiles.period_set_name%TYPE --File.Sql.39 bug 4440895
         ,x_project_currency_code      OUT NOCOPY pa_projects_all.project_currency_code%TYPE --File.Sql.39 bug 4440895
         ,x_projfunc_currency_code     OUT NOCOPY pa_projects_all.projfunc_currency_code%TYPE --File.Sql.39 bug 4440895
         ,x_project_id                 OUT NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_period_profile_type  pa_proj_period_profiles.period_profile_type%type;
l_gl_period_type       pa_proj_period_profiles.gl_period_type%TYPE;
l_number_of_periods    pa_proj_period_profiles.number_of_periods%TYPE;

l_task_id              pa_tasks.task_id%TYPE;

l_dummy_pd_name        pa_budget_lines.period_name%TYPE;    /* webadi */

l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_debug_mode      VARCHAR2(30);


BEGIN
   -- Set the error stack.

      pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.Populate_Local_Variables');

   -- Get the Debug mode into local variable and set it to 'Y'if its NULL

      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');

   -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       pa_debug.g_err_stage := 'In PA_FP_EDIT_LINE_PKG.Populate_Local_Variables ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

    /* Check for Budget Version ID not being NULL. */

    pa_debug.g_err_stage := 'Getting the value of the version id profile id etc.';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;


    SELECT pra.budget_version_id
          ,pbv.period_profile_id
          ,pra.project_id
          ,pra.task_id
      INTO x_fin_plan_version_id
          ,x_period_profile_id
          ,x_project_id
          ,l_task_id
      FROM pa_resource_assignments pra,
           pa_budget_versions pbv
     WHERE pra.resource_assignment_id = p_resource_assignment_id
       AND pra.budget_version_id = pbv.budget_version_id;

    pa_debug.g_err_stage := 'getting x_time_phased_code ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    x_time_phased_code := pa_fin_plan_utils.get_time_phased_code(
                              p_fin_plan_version_id => x_fin_plan_version_id);

    pa_debug.g_err_stage := ':x_time_phased_code = ' || x_time_phased_code;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    x_fin_plan_level_code   := pa_fin_plan_utils.Get_Fin_Plan_Level_Code(
                               p_fin_plan_version_id => x_fin_plan_version_id);

    pa_debug.g_err_stage := 'x_fin_plan_level_code = ' || x_fin_plan_level_code;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF x_period_profile_id IS NOT NULL THEN

        pa_debug.g_err_stage := 'calling pa_prj_period_profile_utils.get_prj_period_profile_dtls.';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

       PA_PRJ_PERIOD_PROFILE_UTILS.GET_PRJ_PERIOD_PROFILE_DTLS(
                p_period_profile_id    => x_period_profile_id
               ,p_debug_mode           => 'Y'
               ,p_add_msg_in_stack     => 'Y'
               ,x_period_profile_type  => l_period_profile_type
               ,x_plan_period_type     => x_plan_period_type
               ,x_period_set_name      => x_period_set_name
               ,x_gl_period_type       => l_gl_period_type
               ,x_plan_start_date      => x_period_profile_start_date
               ,x_plan_end_date        => x_period_profile_end_date
               ,x_number_of_periods    => l_number_of_periods
               ,x_return_status        => l_return_status
               ,x_msg_data             => l_msg_data );

       IF l_return_status =  FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
         /*  PA_PRJ_PERIOD_PROFILE_UTILS.GET_PRJ_PERIOD_PROFILE_DTLS doesn't
             raise error and hence this error trapping is done */
       END IF;

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'calling pa_fin_plan_utils.get_peceding_suceeding_pd_info.';
           pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       /* Calling DERIVE_PD_SD_START_END_DATES to get/dervie the PD/SD start and end dates */

       PA_FP_EDIT_LINE_PKG.DERIVE_PD_SD_START_END_DATES
            (p_calling_context           => p_calling_context
            ,p_pp_st_dt                  => x_period_profile_start_date
            ,p_pp_end_dt                 => x_period_profile_end_date
            ,p_plan_period_type          => x_plan_period_type
            ,p_resource_assignment_id    => p_resource_assignment_id
            ,p_transaction_currency_code => p_txn_currency_code
            ,x_pd_st_dt                  => x_preceding_prd_start_date
            ,x_pd_end_dt                 => x_preceding_prd_end_date
            ,x_pd_period_name            => l_dummy_pd_name                     /* webadi */
            ,x_sd_st_dt                  => x_succeeding_prd_start_date
            ,x_sd_end_dt                 => x_succeeding_prd_end_date
            ,x_sd_period_name            => l_dummy_pd_name                     /* webadi */
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Call to derive_pd_sd_start_end_dates errored... ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    /* This program assumes that in case time phased is by PA or GL
       then period profile id will not be null.
    */
    IF nvl(x_project_id,0) <> 0 THEN

       pa_debug.g_err_stage := 'getting project start and end dates.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       SELECT start_date
             ,completion_date
             ,project_currency_code
             ,projfunc_currency_code
        INTO  x_project_start_date
             ,x_project_end_date
             ,x_project_currency_code
             ,x_projfunc_currency_code
        FROM  pa_projects_all p
        WHERE p.project_id = x_project_id;

    END IF;

    IF nvl(l_task_id,0) <> 0 THEN

       pa_debug.g_err_stage := 'getting task start and end dates.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       SELECT start_date
             ,completion_date
        INTO  x_task_start_date
             ,x_task_end_date
        FROM pa_tasks pt
       WHERE pt.task_id = l_task_id;

  END IF;

  pa_debug.reset_err_stack; /* Bug 2699888 */

EXCEPTION
  WHEN FND_API.G_EXC_ERROR or PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,'Invalid arguments passed or some expected error',5);
         pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      pa_debug.reset_err_stack;

      RAISE;

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG.Populate_Local_Variables'
          ,p_procedure_name => pa_debug.G_Err_Stack );
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,SQLERRM,5);
         pa_debug.write('POPULATE_LOCAL_VARIABLES: ' || l_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      pa_debug.reset_err_stack;

      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END POPULATE_LOCAL_VARIABLES;

/* This API first looks into pa_budget_lines to see if PD/SD records for the resource assignment id
   and txn currency code can be found. If found it returns these values (done in
   PA_FIN_PLAN_UTILS.GET_PECEDING_SUCEEDING_PD_INFO). If these values cannot be found in pa_budget_lines
   then if context is not view then this API derives the PD/SD dates based upon the business rules.
*/

PROCEDURE DERIVE_PD_SD_START_END_DATES
    (p_calling_context           IN  VARCHAR2
    ,p_pp_st_dt                  IN  pa_budget_lines.start_date%TYPE
    ,p_pp_end_dt                 IN  pa_budget_lines.start_date%TYPE
    ,p_plan_period_type          IN  pa_proj_period_profiles.plan_period_type%TYPE
    ,p_resource_assignment_id    IN  pa_resource_assignments.resource_assignment_id%TYPE
    ,p_transaction_currency_code IN  pa_budget_lines.txn_currency_code%TYPE
    ,x_pd_st_dt                  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_pd_end_dt                 OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_pd_period_name            OUT NOCOPY pa_budget_lines.period_name%TYPE    /* webadi */ --File.Sql.39 bug 4440895
    ,x_sd_st_dt                  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_sd_end_dt                 OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_sd_period_name            OUT NOCOPY pa_budget_lines.period_name%TYPE    /* webadi */  --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                  OUT NOCOPY VARCHAR2) AS --File.Sql.39 bug 4440895

    l_msg_count                 NUMBER := 0;
    l_data                      VARCHAR2(2000);
    l_msg_data                  VARCHAR2(2000);
    l_msg_index_out             NUMBER;
    l_dummy_pd_name             VARCHAR2(30);

    l_project_id                PA_PROJECTS_ALL.project_id%TYPE;
    l_budget_version_id         PA_BUDGET_VERSIONS.budget_version_id%TYPE;
    l_time_phased_code          PA_PROJ_FP_OPTIONS.all_time_phased_code%TYPE;
    l_project_start_date        DATE;
    l_project_end_date          DATE;
    l_proj_start_prd_start_dt   DATE;
    l_proj_end_prd_end_dt       DATE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.DERIVE_PD_SD_START_END_DATES');
        pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
    END IF;

    -- Check for business rules violations

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validating input parameters';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    IF    p_calling_context           IS NULL or
          p_pp_st_dt                  IS NULL or
          p_pp_end_dt                 IS NULL or
          p_plan_period_type          IS NULL or
          p_resource_assignment_id    IS NULL THEN

        IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'p_calling_context = '|| p_calling_context;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_pp_st_dt = '|| p_pp_st_dt;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_pp_end_dt = '|| p_pp_end_dt;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_plan_period_type = '|| p_plan_period_type;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_resource_assignment_id = '|| p_resource_assignment_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_transaction_currency_code = '|| p_transaction_currency_code;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

            PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;


    /* Txn currency code can be Null when the context is G_CALLING_CONTEXT_OTHER_CURR and
       so checking txn curr code only for other cases */

    IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR and
       p_transaction_currency_code IS NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'p_calling_context = ' || p_calling_context;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.g_err_stage:= 'p_transaction_currency_code is NULL';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    BEGIN
        SELECT project_id, budget_version_id
        INTO   l_project_id, l_budget_version_id
        FROM   PA_RESOURCE_ASSIGNMENTS
        WHERE  RESOURCE_ASSIGNMENT_ID = p_resource_assignment_id;

    EXCEPTION
        WHEN OTHERS THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Error while selecting for the input resource assignment id ' ||
                                                p_resource_assignment_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage || SQLERRM,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;
             RAISE;
    END;

    /* In case of calling context being G_CALLING_CONTEXT_OTHER_CURR, get_peceding_suceeding_pd_info
       need not be called since in this context we are sure there would no budget lines for the resource
       assignment id and also the txn curr code would be Null */

    IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling get_peceding_suceeding_pd_info ... ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        PA_FIN_PLAN_UTILS.GET_PECEDING_SUCEEDING_PD_INFO (
              p_resource_assignment_id     => p_resource_assignment_id
             ,p_txn_currency_code          => p_transaction_currency_code
             ,x_preceding_prd_start_date   => x_pd_st_dt
             ,x_preceding_prd_end_date     => x_pd_end_dt
             ,x_succeeding_prd_start_date  => x_sd_st_dt
             ,x_succeeding_prd_end_date    => x_sd_end_dt
             ,x_return_status              => x_return_status
             ,x_msg_count                  => x_msg_count
             ,x_msg_data                   => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Call to get_peceding_suceeding_pd_info errored... ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END IF; /* IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN  */


    /* In following block we will be deriving PD SD start and end date when these are not available in
       budget lines table. This needs to be done only when mode is not view because in view mode only
       those lines need to be displayed which are in budget lines table. */

    IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_VIEW THEN

        /* In this block we will be deriving start/end date of the period in which project start/end
           date falls. These dates are required later to derive PD/SD start dates */

        IF (x_pd_st_dt IS NULL or x_sd_st_dt IS NULL) THEN

            BEGIN
               SELECT start_date
                      ,completion_date
               INTO   l_project_start_date
                      ,l_project_end_date
               FROM   pa_projects_all p
               WHERE  p.project_id = l_project_id;
            EXCEPTION
               WHEN OTHERS THEN
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'Error while selecting for the project id ' || l_project_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage || ' ' || SQLERRM,5);
                   END IF;
                   Raise;
            END;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Calling pa_fin_plan_utils apis...';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            l_time_phased_code        := pa_fin_plan_utils.get_time_phased_code(
                                             p_fin_plan_version_id => l_budget_version_id);

            /* Bug : 2644537 Assigning the project start and end dates when proj start, end dates
               do not fall in any period */

            IF l_project_start_date IS NOT NULL THEN

                l_proj_start_prd_start_dt := pa_fin_plan_utils.get_period_start_date(
                                                 p_input_date => l_project_start_date,
                                                 p_time_phased_code   => l_time_phased_code);

                IF l_proj_start_prd_start_dt IS NULL THEN
                    l_proj_start_prd_start_dt := l_project_start_date;
                END IF;

            END IF;

            IF l_project_end_date IS NOT NULL THEN
                l_proj_end_prd_end_dt     := pa_fin_plan_utils.get_period_end_date (
                                                 p_input_date  => l_project_end_date,
                                                 p_time_phased_code    => l_time_phased_code);

                IF l_proj_end_prd_end_dt IS NULL THEN
                    l_proj_end_prd_end_dt := l_project_end_date;
                END IF;

            END IF;

        END IF;

        /* Derive PD dates when these could not be found in pa_budget_lines. */

        IF x_pd_st_dt IS NULL THEN /* i.e. PD record could not be found in budget lines */

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Preceding_prd_start_date IS NULL... ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            /* We need to derive PD period only if either project start is null or if period profile
               starts after the project start date. (Business rule for creating pd period.) */

            IF l_proj_start_prd_start_dt IS NULL OR p_pp_st_dt > l_proj_start_prd_start_dt THEN

                /* In the context of G_CALLING_CONTEXT_OTHER_CURR, p_txn_curr_code would be Null and
                   we are sure there would be no budget lines and hence the following update need not
                   be done */

                IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN
                    UPDATE PA_BUDGET_LINES
                    SET    BUCKETING_PERIOD_CODE = NULL
                    WHERE  TXN_CURRENCY_CODE = p_transaction_currency_code
                    AND    RESOURCE_ASSIGNMENT_ID = p_resource_assignment_id
                    AND    BUDGET_VERSION_ID = l_budget_version_id
                    AND    BUCKETING_PERIOD_CODE = PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PE;
                END IF;

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'calling get_period_info ...';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                PA_PLAN_MATRIX.GET_PERIOD_INFO
                    (p_bucketing_period_code         => PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PD
                    ,p_st_dt_4_st_pd                 => p_pp_st_dt
                    ,p_st_dt_4_end_pd                => p_pp_end_dt
                    ,p_plan_period_type              => p_plan_period_type
                    ,p_project_id                    => l_project_id
                    ,p_budget_version_id             => l_budget_version_id
                    ,p_resource_assignment_id        => p_resource_assignment_id
                    ,p_transaction_currency_code     => p_transaction_currency_code
                    ,x_start_date                    => x_pd_st_dt
                    ,x_end_date                      => x_pd_end_dt
                    ,x_period_name                   => x_pd_period_name                       /* webadi */
                    ,x_return_status                 => x_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_msg_data                      => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'calling get_period_info - FAILED...';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                    END IF;
                    Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            END IF; /* l_proj_start_prd_start_dt IS NULL OR p_pp_st_dt > l_proj_start_prd_start_dt */

        END IF; /* IF x_pd_st_dt IS NULL THEN */

        /* Derive SD dates when these could not be found in pa_budget_lines. */

        IF x_sd_st_dt IS NULL THEN

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Succeeding_prd_start_date IS NULL... ';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            /* We need to derive SD period only if either project end date is null or if period profile
               ends before the project end date. (Business rule for creating sd period.) */

            IF l_proj_end_prd_end_dt IS NULL OR p_pp_end_dt < l_proj_end_prd_end_dt THEN

                /* In the context of G_CALLING_CONTEXT_OTHER_CURR, p_txn_curr_code would be Null and
                   we are sure there would be no budget lines and hence the following update need not
                   be done */

                IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN
                     UPDATE PA_BUDGET_LINES
                     SET    BUCKETING_PERIOD_CODE = NULL
                     WHERE  TXN_CURRENCY_CODE = p_transaction_currency_code
                     AND    RESOURCE_ASSIGNMENT_ID = p_resource_assignment_id
                     AND    BUDGET_VERSION_ID = l_budget_version_id
                     AND    BUCKETING_PERIOD_CODE = PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SE;
                END IF;

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'calling get_period_info ...';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                PA_PLAN_MATRIX.GET_PERIOD_INFO
                    (p_bucketing_period_code         => PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SD
                    ,p_st_dt_4_st_pd                 => p_pp_st_dt
                    ,p_st_dt_4_end_pd                => p_pp_end_dt
                    ,p_plan_period_type              => p_plan_period_type
                    ,p_project_id                    => l_project_id
                    ,p_budget_version_id             => l_budget_version_id
                    ,p_resource_assignment_id        => p_resource_assignment_id
                    ,p_transaction_currency_code     => p_transaction_currency_code
                    ,x_start_date                    => x_sd_st_dt
                    ,x_end_date                      => x_sd_end_dt
                    ,x_period_name                   => x_sd_period_name                       /* webadi */
                    ,x_return_status                 => x_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_msg_data                      => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'calling get_period_info - FAILED...';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            END IF; /* l_proj_end_prd_end_dt IS NULL OR p_pp_end_dt < l_proj_end_prd_end_dt */

        END IF; /* x_sd_st_dt IS NULL */

    END IF; /* p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_VIEW */

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Exiting DERIVE_PD_SD_START_END_DATES';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.reset_err_stack;
    END IF;

EXCEPTION

    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                (p_encoded        => FND_API.G_TRUE
                ,p_msg_index      => 1
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_data           => l_data
                ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            pa_debug.reset_err_stack;
        END IF;
        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_FP_EDIT_LINE_PKG'
             ,p_procedure_name  => 'DERIVE_PD_SD_START_END_DATES'
             ,p_error_text      => x_msg_data);

        IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            pa_debug.reset_err_stack;
        END IF;
        RAISE;

END DERIVE_PD_SD_START_END_DATES;

PROCEDURE POPULATE_ROLLUP_TMP(
           p_resource_assignment_id IN pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
          ,p_txn_currency_code      IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
          ,p_calling_context        IN VARCHAR2
          ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
CURSOR MC_CUR(p_fin_plan_version_id IN NUMBER, p_txn_currency_code IN VARCHAR2) IS

SELECT
        pfo.PROJECT_COST_RATE_TYPE
        ,decode(pfo.PROJECT_COST_RATE_TYPE,'User',pftc.PROJECT_COST_EXCHANGE_RATE,null) PROJECT_COST_EXCHANGE_RATE
        ,pfo.PROJECT_COST_RATE_DATE_TYPE
        ,pfo.PROJECT_COST_RATE_DATE
        ,pfo.PROJECT_REV_RATE_TYPE
        ,decode(pfo.PROJECT_REV_RATE_TYPE,'User',pftc.PROJECT_REV_EXCHANGE_RATE,null)  PROJECT_REV_EXCHANGE_RATE
        ,pfo.PROJECT_REV_RATE_DATE_TYPE
        ,pfo.PROJECT_REV_RATE_DATE
        ,pfo.PROJFUNC_COST_RATE_TYPE
        ,decode(pfo.PROJFUNC_COST_RATE_TYPE,'User',pftc.PROJFUNC_COST_EXCHANGE_RATE,null) PROJFUNC_COST_EXCHANGE_RATE
        ,pfo.PROJFUNC_COST_RATE_DATE_TYPE
        ,pfo.PROJFUNC_COST_RATE_DATE
        ,pfo.PROJFUNC_REV_RATE_TYPE
        ,decode(pfo.PROJFUNC_REV_RATE_TYPE,'User',pftc.PROJFUNC_REV_EXCHANGE_RATE,null) PROJFUNC_REV_EXCHANGE_RATE
        ,pfo.PROJFUNC_REV_RATE_DATE_TYPE
        ,pfo.PROJFUNC_REV_RATE_DATE
FROM  pa_proj_fp_options pfo
     ,pa_fp_txn_currencies pftc
WHERE pfo.proj_fp_options_id = pftc.proj_fp_options_id(+)
  AND pfo.fin_plan_version_id = p_fin_plan_version_id
  AND pftc.txn_currency_code(+) = p_txn_currency_code;

l_preceding_prd_start_date      pa_budget_lines.start_date%TYPE;
l_preceding_prd_end_date        pa_budget_lines.start_date%TYPE;
l_succeeding_prd_start_date     pa_budget_lines.start_date%TYPE;
l_succeeding_prd_end_date       pa_budget_lines.start_date%TYPE;
l_period_profile_start_date     pa_budget_lines.start_date%TYPE;
l_period_profile_end_date       pa_budget_lines.start_date%TYPE;
l_period_profile_id             pa_budget_versions.period_profile_id%TYPE;
l_time_phased_code              pa_proj_fp_options.cost_time_phased_code%TYPE;
l_fin_plan_version_id           pa_proj_fp_options.fin_plan_version_id%TYPE;
l_fin_plan_level_code           pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_project_start_date            pa_projects_all.start_date%TYPE;
l_project_end_date              pa_projects_all.start_date%TYPE;
l_task_start_date               pa_projects_all.start_date%TYPE;
l_task_end_date                 pa_projects_all.start_date%TYPE;
l_plan_period_type              pa_proj_period_profiles.plan_period_type%TYPE;
l_period_set_name               pa_proj_period_profiles.period_set_name%TYPE;
l_project_currency_code         pa_projects_all.project_currency_code%TYPE;
l_projfunc_currency_code        pa_projects_all.projfunc_currency_code%TYPE;
l_project_id                    pa_projects_all.project_id%TYPE;
l_dummy_period_name             pa_periods_all.period_name%TYPE;

l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(2000);

l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(10);
l_stage                         NUMBER := 100;

l_preceding_raw_cost            pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_succeeding_raw_cost           pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_preceding_burdened_cost       pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_succeeding_burdened_cost      pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_preceding_revenue             pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_succeeding_revenue            pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_preceding_quantity            pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_succeeding_quantity           pa_proj_periods_denorm.preceding_periods_amount%TYPE;

l_pd_pc_raw_cost                pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_pd_pfc_raw_cost               pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pc_raw_cost                pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pfc_raw_cost               pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_pd_pc_burdened_cost           pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_pd_pfc_burdened_cost          pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pc_burdened_cost           pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pfc_burdened_cost          pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_pd_pc_revenue                 pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_pd_pfc_revenue                pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pc_revenue                 pa_proj_periods_denorm.preceding_periods_amount%TYPE;
l_sd_pfc_revenue                pa_proj_periods_denorm.preceding_periods_amount%TYPE;

l_preceding_period_text         fnd_new_messages.message_text%TYPE := fnd_message.GET_STRING('PA','PA_FP_PREC_PERIOD_AMOUNT');
l_succeeding_period_text        fnd_new_messages.message_text%TYPE := fnd_message.GET_STRING('PA','PA_FP_SUCC_PERIOD_AMOUNT');

l_count                         NUMBER;
mc_cur_rec                      MC_CUR%ROWTYPE;

/* Added for enhancement # 2604957 */
l_min_start_date       pa_budget_lines.start_date%TYPE;
l_max_start_date       pa_budget_lines.start_date%TYPE;

/* Added for enhancement # 2593167 */
l_proj_start_prd_start_dt       pa_budget_lines.start_date%TYPE;
l_proj_end_prd_end_dt           pa_budget_lines.start_date%TYPE;

PROCEDURE insert_dummy_record_pvt (mc_rec IN mc_cur_rec%TYPE)
IS
BEGIN
INSERT INTO PA_FP_ROLLUP_TMP
                 (ROLLUP_ID
                  ,RESOURCE_ASSIGNMENT_ID
                  ,BUDGET_LINE_ID
                  ,OLD_START_DATE
                  ,START_DATE
                  ,END_DATE
                  ,PERIOD_NAME
                  ,txn_currency_code
                  ,old_quantity
                  ,old_txn_raw_cost
                  ,old_txn_burdened_cost
                  ,old_txn_revenue
                  ,quantity
                  ,txn_raw_cost
                  ,txn_burdened_cost
                  ,txn_revenue
                  ,bucketing_period_code
                  ,delete_flag
                  ,parent_assignment_id
                  ,project_currency_code
                  ,projfunc_currency_code
                  ,PROJECT_COST_RATE_TYPE
                  ,PROJECT_COST_EXCHANGE_RATE
                  ,PROJECT_COST_RATE_DATE_TYPE
                  ,PROJECT_COST_RATE_DATE
                  ,PROJECT_REV_RATE_TYPE
                  ,PROJECT_REV_EXCHANGE_RATE
                  ,PROJECT_REV_RATE_DATE_TYPE
                  ,PROJECT_REV_RATE_DATE
                  ,PROJFUNC_COST_RATE_TYPE
                  ,PROJFUNC_COST_EXCHANGE_RATE
                  ,PROJFUNC_COST_RATE_DATE_TYPE
                  ,PROJFUNC_COST_RATE_DATE
                  ,PROJFUNC_REV_RATE_TYPE
                  ,PROJFUNC_REV_EXCHANGE_RATE
                  ,PROJFUNC_REV_RATE_DATE_TYPE
                  ,PROJFUNC_REV_RATE_DATE
                    )
           SELECT  pa_fp_rollup_tmp_s.nextval
                  ,p_resource_assignment_id
                  ,NULL           /* BUDGET_LINE_ID */
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL          /* period name */
                  ,p_txn_currency_code
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,'N'
                  ,parent_assignment_id
                  ,l_project_currency_code
                  ,l_projfunc_currency_code
                  ,mc_rec.PROJECT_COST_RATE_TYPE
                  ,mc_rec.PROJECT_COST_EXCHANGE_RATE
                  ,mc_rec.PROJECT_COST_RATE_DATE_TYPE
                  ,mc_rec.PROJECT_COST_RATE_DATE
                  ,mc_rec.PROJECT_REV_RATE_TYPE
                  ,mc_rec.PROJECT_REV_EXCHANGE_RATE
                  ,mc_rec.PROJECT_REV_RATE_DATE_TYPE
                  ,mc_rec.PROJECT_REV_RATE_DATE
                  ,mc_rec.PROJFUNC_COST_RATE_TYPE
                  ,mc_rec.PROJFUNC_COST_EXCHANGE_RATE
                  ,mc_rec.PROJFUNC_COST_RATE_DATE_TYPE
                  ,mc_rec.PROJFUNC_COST_RATE_DATE
                  ,mc_rec.PROJFUNC_REV_RATE_TYPE
                  ,mc_rec.PROJFUNC_REV_EXCHANGE_RATE
                  ,mc_rec.PROJFUNC_REV_RATE_DATE_TYPE
                  ,mc_rec.PROJFUNC_REV_RATE_DATE
         FROM pa_resource_assignments pra
         where resource_assignment_id = p_resource_assignment_id;

END insert_dummy_record_pvt;

BEGIN
    -- Set the error stack.
       pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.POPULATE_ROLLUP_TMP');

    -- Get the Debug mode into local variable and set it to 'Y' if its NULL
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Initialize the return status to success
       /* #2598389: Uncommented the following assignment. */
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

    -- Validating input parameters
       IF p_calling_context IS NULL THEN

            pa_debug.g_err_stage := 'calling context is null.';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        ELSIF p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN

            IF p_resource_assignment_id IS NULL THEN

                pa_debug.g_err_stage := 'resource assignment id is null in edit in another currency.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;

                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
        ELSE

            IF p_resource_assignment_id IS NULL OR
               p_txn_currency_code IS NULL
            THEN
                pa_debug.g_err_stage := 'one of the input parameter is null.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;


                pa_debug.g_err_stage := 'p_resource_assignment_id = ' || p_resource_assignment_id;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                pa_debug.g_err_stage := 'p_txn_currency_code = ' || p_txn_currency_code;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
                   pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;

                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;

       pa_debug.g_err_stage := 'p_calling_context = ' || p_calling_context;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;

       pa_debug.g_err_stage := 'p_resource_assignment_id = ' || p_resource_assignment_id;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;

       pa_debug.g_err_stage := 'p_txn_currency_code = ' || p_txn_currency_code;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;

       pa_debug.g_err_stage := 'calling populate local variables';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       POPULATE_LOCAL_VARIABLES(
                  p_resource_assignment_id    => p_resource_assignment_id
                 ,p_txn_currency_code         => p_txn_currency_code
                 ,p_calling_context           => p_calling_context
                 ,x_preceding_prd_start_date  => l_preceding_prd_start_date
                 ,x_preceding_prd_end_date    => l_preceding_prd_end_date
                 ,x_succeeding_prd_start_date => l_succeeding_prd_start_date
                 ,x_succeeding_prd_end_date   => l_succeeding_prd_end_date
                 ,x_period_profile_start_date => l_period_profile_start_date
                 ,x_period_profile_end_date   => l_period_profile_end_date
                 ,x_period_profile_id         => l_period_profile_id
                 ,x_time_phased_code          => l_time_phased_code
                 ,x_fin_plan_version_id       => l_fin_plan_version_id
                 ,x_fin_plan_level_code       => l_fin_plan_level_code
                 ,x_project_start_date        => l_project_start_date
                 ,x_project_end_date          => l_project_end_date
                 ,x_task_start_date           => l_task_start_date
                 ,x_task_end_date             => l_task_end_date
                 ,x_plan_period_type          => l_plan_period_type
                 ,x_period_set_name           => l_period_set_name
                 ,x_project_currency_code     => l_project_currency_code
                 ,x_projfunc_currency_code    => l_projfunc_currency_code
                 ,x_project_id                => l_project_id
                 ,x_return_status             => l_return_status
                 ,x_msg_count                 => l_msg_count
                 ,x_msg_data                  => l_msg_data
                 );

        pa_debug.g_err_stage := ':l_period_profile_id = ' || l_period_profile_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF l_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G) THEN

           IF l_period_profile_id IS NULL THEN
              pa_debug.g_err_stage := 'period_profile_id is null when time phasing is PA or GL ';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;
              /* Bug # 2617990 */
              PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                     p_msg_name            => 'PA_FP_PERIODPROFILE_UNDEFINED');
              raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

        ELSE /* if time phasing is none then */

           IF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N THEN
              IF l_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
                 IF l_project_start_date IS NULL or l_project_end_date IS NULL THEN
                    pa_debug.g_err_stage := 'for time phase none and entry level project, project start date and end date must be not null';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
              ELSE
                 /*bug 3182883 if calling context is 'VIEW' do not throw error*/
                 IF (l_task_start_date IS NULL or l_task_end_date IS NULL)
                 AND (p_calling_context <> 'VIEW') THEN
                    pa_debug.g_err_stage := 'for time phase none and entry level task, task start date and end date must be not null';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
              END IF;
           END IF;
        END IF;

        IF l_period_profile_id IS NOT NULL THEN

                /* Since in the context of G_CALLING_CONTEXT_OTHER_CURR, there would be no records
                   in budget lines for the resource assignment and also since p_txn_curr_code would
                   be null, we need not call get_preceding_succeeding_amt */

                IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN

                        pa_debug.g_err_stage := 'calling get_preceding_succeeding_amt';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        GET_PRECEDING_SUCCEEDING_AMT(
                                  p_budget_version_id          => l_fin_plan_version_id
                                 ,p_resource_assignment_id     => p_resource_assignment_id
                                 ,p_txn_currency_code          => p_txn_currency_code
                                 ,p_period_profile_id          => l_period_profile_id
                                 ,x_preceding_raw_cost         => l_preceding_raw_cost
                                 ,x_succeeding_raw_cost        => l_succeeding_raw_cost
                                 ,x_preceding_burdened_cost    => l_preceding_burdened_cost
                                 ,x_succeeding_burdened_cost   => l_succeeding_burdened_cost
                                 ,x_preceding_revenue          => l_preceding_revenue
                                 ,x_succeeding_revenue         => l_succeeding_revenue
                                 ,x_preceding_quantity         => l_preceding_quantity
                                 ,x_succeeding_quantity        => l_succeeding_quantity
                                 ,x_return_status              => l_return_status
                                 ,x_msg_count                  => l_msg_count
                                 ,x_msg_data                   => l_msg_data);

                        /* Call included for Bug2817407. This api returns the PC and PFC amounts
                           for the input resource assignment id and txn currency code.  */

                        GET_PD_SD_AMT_IN_PC_PFC(
                                  p_resource_assignment_id     => p_resource_assignment_id
                                 ,p_txn_currency_code          => p_txn_currency_code
                                 ,p_period_profile_id          => l_period_profile_id
                                 ,x_pd_pc_raw_cost             => l_pd_pc_raw_cost
                                 ,x_pd_pfc_raw_cost            => l_pd_pfc_raw_cost
                                 ,x_sd_pc_raw_cost             => l_sd_pc_raw_cost
                                 ,x_sd_pfc_raw_cost            => l_sd_pfc_raw_cost
                                 ,x_pd_pc_burdened_cost        => l_pd_pc_burdened_cost
                                 ,x_pd_pfc_burdened_cost       => l_pd_pfc_burdened_cost
                                 ,x_sd_pc_burdened_cost        => l_sd_pc_burdened_cost
                                 ,x_sd_pfc_burdened_cost       => l_sd_pfc_burdened_cost
                                 ,x_pd_pc_revenue              => l_pd_pc_revenue
                                 ,x_pd_pfc_revenue             => l_pd_pfc_revenue
                                 ,x_sd_pc_revenue              => l_sd_pc_revenue
                                 ,x_sd_pfc_revenue             => l_sd_pfc_revenue
                                 ,x_return_status              => l_return_status
                                 ,x_msg_count                  => l_msg_count
                                 ,x_msg_data                   => l_msg_data);

                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;
                  END IF;

                /* Fix for enhancement bug # 2604957 starts */

                /* In the context of view, we need to show only the records that are present in the
                   budget lines and that from first avaiable period to the last available period in
                   pa_budget_lines */

                IF p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_VIEW THEN

                    SELECT MIN(start_date), MAX(start_date)
                     INTO l_min_start_date,l_max_start_date
                     FROM pa_budget_lines
                    WHERE budget_version_id = l_fin_plan_version_id
                      AND resource_assignment_id = p_resource_assignment_id
                      AND txn_currency_code = p_txn_currency_code
                      AND start_date >= l_period_profile_start_date
                      AND end_date <= l_period_profile_end_date;

                ELSE

                    l_min_start_date := l_period_profile_start_date;
                    l_max_start_date := l_period_profile_end_date;

                END IF;

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'calling populate_eligible_periods ';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                /* Calling populate_eligible_periods to populate the period date from
                   l_min_start_date to l_max_start_date inclusive of the
                   l_preceding_prd_start_date and l_succeeding_prd_start_date periods */

                POPULATE_ELIGIBLE_PERIODS
                  (  p_fin_plan_version_id            =>   l_fin_plan_version_id
                    ,p_period_profile_start_date      =>   l_min_start_date
                    ,p_period_profile_end_date        =>   l_max_start_date
                    ,p_preceding_prd_start_date       =>   l_preceding_prd_start_date
                    ,p_succeeding_prd_start_date      =>   l_succeeding_prd_start_date
                    ,x_return_status                  =>   l_return_status
                    ,x_msg_count                      =>   l_msg_count
                    ,x_msg_data                       =>   l_msg_data);

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                /* Fix for enhancement bug # 2604957 ends*/

        END IF;

        DELETE FROM PA_FP_ROLLUP_TMP;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='deleted  '||sql%rowcount || ' records from PA_FP_ROLLUP_TMP table' ;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;


        OPEN MC_CUR(l_fin_plan_version_id,p_txn_currency_code);
        FETCH MC_CUR INTO mc_cur_rec;
        CLOSE MC_CUR;

        /* Enhancement bug # 2593167 : starts */

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='time phasing is '|| l_time_phased_code ||
                                  ' before getting project start / end date period start / end dates';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

        IF l_period_profile_id IS NOT NULL THEN

           /* Bug 2672548 - We are deriving the PD / SD info even when budget lines doesnt exists.
              So, bucketing period code can be derived by comparing the start date in pa_fp_cpy_periods_tmp
              with the derived preceding / succeeding information. */

              INSERT INTO PA_FP_ROLLUP_TMP
                        (  ROLLUP_ID
                          ,RESOURCE_ASSIGNMENT_ID
                          ,BUDGET_LINE_ID
                          ,OLD_START_DATE
                          ,START_DATE
                          ,END_DATE
                          ,PERIOD_NAME
                          ,CHANGE_REASON_CODE
                          ,DESCRIPTION
                          ,BUCKETING_PERIOD_CODE
                          ,TXN_CURRENCY_CODE
                          ,PARENT_ASSIGNMENT_ID
                          ,PROJECT_CURRENCY_CODE
                          ,PROJFUNC_CURRENCY_CODE
                          ,PROJECT_COST_RATE_TYPE
                          ,PROJECT_COST_EXCHANGE_RATE
                          ,PROJECT_COST_RATE_DATE_TYPE
                          ,PROJECT_COST_RATE_DATE
                          ,PROJECT_REV_RATE_TYPE
                          ,PROJECT_REV_EXCHANGE_RATE
                          ,PROJECT_REV_RATE_DATE_TYPE
                          ,PROJECT_REV_RATE_DATE
                          ,PROJFUNC_COST_RATE_TYPE
                          ,PROJFUNC_COST_EXCHANGE_RATE
                          ,PROJFUNC_COST_RATE_DATE_TYPE
                          ,PROJFUNC_COST_RATE_DATE
                          ,PROJFUNC_REV_RATE_TYPE
                          ,PROJFUNC_REV_EXCHANGE_RATE
                          ,PROJFUNC_REV_RATE_DATE_TYPE
                          ,PROJFUNC_REV_RATE_DATE
                          ,OLD_PROJ_RAW_COST
                          ,OLD_PROJ_BURDENED_COST
                          ,OLD_PROJ_REVENUE
                          ,OLD_PROJFUNC_RAW_COST
                          ,OLD_PROJFUNC_BURDENED_COST
                          ,OLD_PROJFUNC_REVENUE
                          ,OLD_QUANTITY
                          ,PROJECT_RAW_COST
                          ,PROJECT_BURDENED_COST
                          ,PROJECT_REVENUE
                          ,PROJFUNC_RAW_COST
                          ,PROJFUNC_BURDENED_COST
                          ,PROJFUNC_REVENUE
                          ,OLD_TXN_RAW_COST
                          ,OLD_TXN_BURDENED_COST
                          ,OLD_TXN_REVENUE
                          ,TXN_RAW_COST
                          ,TXN_BURDENED_COST
                          ,TXN_REVENUE
                          ,QUANTITY
                          ,DELETE_FLAG
                          ,ATTRIBUTE_CATEGORY
                          ,ATTRIBUTE1
                          ,ATTRIBUTE2
                          ,ATTRIBUTE3
                          ,ATTRIBUTE4
                          ,ATTRIBUTE5
                          ,ATTRIBUTE6
                          ,ATTRIBUTE7
                          ,ATTRIBUTE8
                          ,ATTRIBUTE9
                          ,ATTRIBUTE10
                          ,ATTRIBUTE11
                          ,ATTRIBUTE12
                          ,ATTRIBUTE13
                          ,ATTRIBUTE14
                          ,ATTRIBUTE15
                          ,RAW_COST_SOURCE
                          ,BURDENED_COST_SOURCE
                          ,QUANTITY_SOURCE
                          ,REVENUE_SOURCE
                          ,PM_PRODUCT_CODE
                          )
                          (
                  SELECT   PA_FP_ROLLUP_TMP_S.NEXTVAL
                          ,P_RESOURCE_ASSIGNMENT_ID
                          ,pbl.BUDGET_LINE_ID
                          ,pbl.START_DATE OLD_START_DATE    /* when old_start_Date is null then the record should be inserted in pbl */
                          ,tmp.START_DATE START_DATE
                          ,tmp.END_DATE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_period_text,
                                      l_succeeding_prd_start_date,l_succeeding_period_text,
                                      tmp.PERIOD_NAME) PERIOD_NAME
                          ,pbl.CHANGE_REASON_CODE
                          ,pbl.DESCRIPTION
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PD,
                                      l_succeeding_prd_start_date,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SD)
                                    BUCKETING_PERIOD_CODE
                          ,P_TXN_CURRENCY_CODE
                          ,pra.PARENT_ASSIGNMENT_ID
                          ,nvl(pbl.PROJECT_CURRENCY_CODE,l_project_currency_code)
                          ,nvl(pbl.PROJFUNC_CURRENCY_CODE,l_projfunc_currency_code) /* decode is used here since there are some outer joined records and we want to default only for such cases */
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_COST_RATE_TYPE,pbl.PROJECT_COST_RATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_COST_EXCHANGE_RATE,pbl.PROJECT_COST_EXCHANGE_RATE)    /* due to changes in the mc page */
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_COST_RATE_DATE_TYPE,pbl.PROJECT_COST_RATE_DATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_COST_RATE_DATE,pbl.PROJECT_COST_RATE_DATE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_REV_RATE_TYPE,pbl.PROJECT_REV_RATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_REV_EXCHANGE_RATE,pbl.PROJECT_REV_EXCHANGE_RATE)     /* due to changes in the mc page */
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_REV_RATE_DATE_TYPE,pbl.PROJECT_REV_RATE_DATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJECT_REV_RATE_DATE,pbl.PROJECT_REV_RATE_DATE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_COST_RATE_TYPE,pbl.PROJFUNC_COST_RATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_COST_EXCHANGE_RATE,pbl.PROJFUNC_COST_EXCHANGE_RATE)/* due to changes in the mc page */
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_COST_RATE_DATE_TYPE,pbl.PROJFUNC_COST_RATE_DATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_COST_RATE_DATE,pbl.PROJFUNC_COST_RATE_DATE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_REV_RATE_TYPE,pbl.PROJFUNC_REV_RATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_REV_EXCHANGE_RATE,pbl.PROJFUNC_REV_EXCHANGE_RATE)  /* due to changes in the mc page */
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_REV_RATE_DATE_TYPE,pbl.PROJFUNC_REV_RATE_DATE_TYPE)
                          ,decode(pbl.START_DATE,null,mc_cur_rec.PROJFUNC_REV_RATE_DATE,pbl.PROJFUNC_REV_RATE_DATE)
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_raw_cost,
                                      l_succeeding_prd_start_date,l_sd_pc_raw_cost,
                                      pbl.PROJECT_RAW_COST) OLD_PROJ_RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_burdened_cost,
                                      l_succeeding_prd_start_date,l_sd_pc_burdened_cost,
                                      pbl.PROJECT_BURDENED_COST) OLD_PROJ_BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_revenue,
                                      l_succeeding_prd_start_date,l_sd_pc_revenue,
                                      pbl.PROJECT_REVENUE) OLD_PROJ_REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_raw_cost,
                                      l_succeeding_prd_start_date,l_sd_pfc_raw_cost,
                                      pbl.RAW_COST) OLD_PROJFUNC_RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_burdened_cost,
                                      l_succeeding_prd_start_date,l_sd_pfc_burdened_cost,
                                      pbl.BURDENED_COST) OLD_PROJFUNC_BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_revenue,
                                      l_succeeding_prd_start_date,l_sd_pfc_revenue,
                                      pbl.REVENUE) OLD_PROJFUNC_REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_quantity,
                                      l_succeeding_prd_start_date,l_succeeding_quantity,
                                      pbl.QUANTITY)       OLD_QUANTITY
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_raw_cost,
                                      l_succeeding_prd_start_date,l_sd_pc_raw_cost,
                                      pbl.PROJECT_RAW_COST) PROJECT_RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_burdened_cost,
                                      l_succeeding_prd_start_date,l_sd_pc_burdened_cost,
                                      pbl.PROJECT_BURDENED_COST) PROJECT_BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pc_revenue,
                                      l_succeeding_prd_start_date,l_sd_pc_revenue,
                                      pbl.PROJECT_REVENUE) PROJECT_REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_raw_cost,
                                      l_succeeding_prd_start_date,l_sd_pfc_raw_cost,
                                      pbl.RAW_COST) RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_burdened_cost,
                                      l_succeeding_prd_start_date,l_sd_pfc_burdened_cost,
                                      pbl.BURDENED_COST) BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_pd_pfc_revenue,
                                      l_succeeding_prd_start_date,l_sd_pfc_revenue,
                                      pbl.REVENUE) REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_raw_cost,
                                      l_succeeding_prd_start_date,l_succeeding_raw_cost,
                                      pbl.TXN_RAW_COST)       OLD_TXN_RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_burdened_cost,
                                      l_succeeding_prd_start_date,l_succeeding_burdened_cost,
                                      pbl.TXN_BURDENED_COST)  OLD_TXN_BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_revenue,
                                      l_succeeding_prd_start_date,l_succeeding_revenue,
                                      pbl.TXN_REVENUE)        OLD_TXN_REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_raw_cost,
                                      l_succeeding_prd_start_date,l_succeeding_raw_cost,
                                      pbl.TXN_RAW_COST)       TXN_RAW_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_burdened_cost,
                                      l_succeeding_prd_start_date,l_succeeding_burdened_cost,
                                      pbl.TXN_BURDENED_COST)  TXN_BURDENED_COST
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_revenue,
                                      l_succeeding_prd_start_date,l_succeeding_revenue,
                                      pbl.TXN_REVENUE)        TXN_REVENUE
                          ,decode(tmp.start_date,
                                      l_preceding_prd_start_date,l_preceding_quantity,
                                      l_succeeding_prd_start_date,l_succeeding_quantity,
                                      pbl.QUANTITY)           QUANTITY
                          ,'N' DELETE_FLAG
                          ,pbl.ATTRIBUTE_CATEGORY
                          ,pbl.ATTRIBUTE1
                          ,pbl.ATTRIBUTE2
                          ,pbl.ATTRIBUTE3
                          ,pbl.ATTRIBUTE4
                          ,pbl.ATTRIBUTE5
                          ,pbl.ATTRIBUTE6
                          ,pbl.ATTRIBUTE7
                          ,pbl.ATTRIBUTE8
                          ,pbl.ATTRIBUTE9
                          ,pbl.ATTRIBUTE10
                          ,pbl.ATTRIBUTE11
                          ,pbl.ATTRIBUTE12
                          ,pbl.ATTRIBUTE13
                          ,pbl.ATTRIBUTE14
                          ,pbl.ATTRIBUTE15
                          ,pbl.RAW_COST_SOURCE
                          ,pbl.BURDENED_COST_SOURCE
                          ,pbl.QUANTITY_SOURCE
                          ,pbl.REVENUE_SOURCE
                          ,pbl.PM_PRODUCT_CODE
                  FROM  pa_resource_assignments pra
                       ,pa_budget_lines pbl
                       ,pa_fp_cpy_periods_tmp tmp
                  WHERE pra.resource_assignment_id = p_resource_assignment_id
                    AND pbl.resource_assignment_id(+) = p_resource_assignment_id
                    AND pbl.start_date(+) = tmp.start_date
                    AND pbl.txn_currency_code(+) = p_txn_currency_code);

              IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := ':inserted ' || sql%rowcount || ' records ';
                  pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

      /* when period profile is null we can assume that the case is either date range or none */

      ELSE /* IF time phased code in G_TIME_PHASED_CODE_P G_TIME_PHASED_CODE_G */

          pa_debug.g_err_stage := ':period profile id is null and so time phasing should be none or date range';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          /* bvarnasi added case for timephasing NONE */

              DECLARE
                   l_start_date pa_budget_lines.start_Date%type;
                   l_end_date   pa_budget_lines.end_Date%type;
              BEGIN

              /* following is the logic of getting start date and end date
                 1. in case time phasing is none and no record exists in budget lines then
                    we need to insert either project start/end date or task start/end date
                    based upon planning level.
                    in case time phasing is date range. insert a row with these values as null
                    User will enter the required start and end dates.
              */
                    IF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N THEN
                       IF l_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
                          l_start_date := l_project_start_date;
                          l_end_date := l_project_end_date;
                       ELSE
                          l_start_date := l_task_start_date;
                          l_end_date := l_task_end_date;
                       END IF;
                    ELSE
                       l_start_date := null;
                       l_end_date := null;
                    END IF;

                  pa_debug.g_err_stage := 'time phasing none and start / end dates are : '|| l_start_date ||' , '||l_end_date;
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                     INSERT INTO PA_FP_ROLLUP_TMP
                              (  ROLLUP_ID
                                ,RESOURCE_ASSIGNMENT_ID
                                ,BUDGET_LINE_ID
                                ,OLD_START_DATE
                                ,START_DATE
                                ,END_DATE
                                ,PERIOD_NAME
                                ,CHANGE_REASON_CODE
                                ,DESCRIPTION
                                ,BUCKETING_PERIOD_CODE
                                ,TXN_CURRENCY_CODE
                                ,PARENT_ASSIGNMENT_ID
                                ,PROJECT_CURRENCY_CODE
                                ,PROJFUNC_CURRENCY_CODE
                                ,PROJECT_COST_RATE_TYPE
                                ,PROJECT_COST_EXCHANGE_RATE
                                ,PROJECT_COST_RATE_DATE_TYPE
                                ,PROJECT_COST_RATE_DATE
                                ,PROJECT_REV_RATE_TYPE
                                ,PROJECT_REV_EXCHANGE_RATE
                                ,PROJECT_REV_RATE_DATE_TYPE
                                ,PROJECT_REV_RATE_DATE
                                ,PROJFUNC_COST_RATE_TYPE
                                ,PROJFUNC_COST_EXCHANGE_RATE
                                ,PROJFUNC_COST_RATE_DATE_TYPE
                                ,PROJFUNC_COST_RATE_DATE
                                ,PROJFUNC_REV_RATE_TYPE
                                ,PROJFUNC_REV_EXCHANGE_RATE
                                ,PROJFUNC_REV_RATE_DATE_TYPE
                                ,PROJFUNC_REV_RATE_DATE
                                ,OLD_PROJ_RAW_COST
                                ,OLD_PROJ_BURDENED_COST
                                ,OLD_PROJ_REVENUE
                                ,OLD_PROJFUNC_RAW_COST
                                ,OLD_PROJFUNC_BURDENED_COST
                                ,OLD_PROJFUNC_REVENUE
                                ,OLD_QUANTITY
                                ,PROJECT_RAW_COST
                                ,PROJECT_BURDENED_COST
                                ,PROJECT_REVENUE
                                ,PROJFUNC_RAW_COST
                                ,PROJFUNC_BURDENED_COST
                                ,PROJFUNC_REVENUE
                                ,OLD_TXN_RAW_COST
                                ,OLD_TXN_BURDENED_COST
                                ,OLD_TXN_REVENUE
                                ,TXN_RAW_COST
                                ,TXN_BURDENED_COST
                                ,TXN_REVENUE
                                ,QUANTITY
                                ,DELETE_FLAG
                                ,ATTRIBUTE_CATEGORY
                                ,ATTRIBUTE1
                                ,ATTRIBUTE2
                                ,ATTRIBUTE3
                                ,ATTRIBUTE4
                                ,ATTRIBUTE5
                                ,ATTRIBUTE6
                                ,ATTRIBUTE7
                                ,ATTRIBUTE8
                                ,ATTRIBUTE9
                                ,ATTRIBUTE10
                                ,ATTRIBUTE11
                                ,ATTRIBUTE12
                                ,ATTRIBUTE13
                                ,ATTRIBUTE14
                                ,ATTRIBUTE15
                                ,RAW_COST_SOURCE
                                ,BURDENED_COST_SOURCE
                                ,QUANTITY_SOURCE
                                ,REVENUE_SOURCE
                                ,PM_PRODUCT_CODE
                                )
                                (
                        SELECT   pa_fp_rollup_tmp_s.nextval
                                ,p_resource_assignment_id /* Fix for bug # 2586514 */
                                ,pbl.BUDGET_LINE_ID
                                ,pbl.start_date OLD_START_DATE    /* when old_start_Date is null then the record should be inserted in pbl */
                                ,nvl(pbl.start_date,l_start_date)
                                ,nvl(pbl.end_Date,l_end_date)
                                ,pbl.PERIOD_NAME
                                ,pbl.CHANGE_REASON_CODE
                                ,pbl.DESCRIPTION
                                ,pbl.BUCKETING_PERIOD_CODE
                                ,P_TXN_CURRENCY_CODE /* Fix for bug # 2590361 */
                                ,pra.PARENT_ASSIGNMENT_ID
                                ,nvl(pbl.PROJECT_CURRENCY_CODE,l_project_currency_code)
                                ,nvl(pbl.PROJFUNC_CURRENCY_CODE,l_projfunc_currency_code)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_COST_RATE_TYPE,pbl.PROJECT_COST_RATE_TYPE) /* remove decode for start date now */
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_COST_EXCHANGE_RATE,pbl.PROJECT_COST_EXCHANGE_RATE)  /* due to changes on mc page */
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_COST_RATE_DATE_TYPE,pbl.PROJECT_COST_RATE_DATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_COST_RATE_DATE,pbl.PROJECT_COST_RATE_DATE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_REV_RATE_TYPE,pbl.PROJECT_REV_RATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_REV_EXCHANGE_RATE,pbl.PROJECT_REV_EXCHANGE_RATE)    /* due to changes on mc page */
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_REV_RATE_DATE_TYPE,pbl.PROJECT_REV_RATE_DATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJECT_REV_RATE_DATE,pbl.PROJECT_REV_RATE_DATE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_COST_RATE_TYPE,pbl.PROJFUNC_COST_RATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_COST_EXCHANGE_RATE,pbl.PROJFUNC_COST_EXCHANGE_RATE)/* due to changes on mc page */
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_COST_RATE_DATE_TYPE,pbl.PROJFUNC_COST_RATE_DATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_COST_RATE_DATE,pbl.PROJFUNC_COST_RATE_DATE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_REV_RATE_TYPE,pbl.PROJFUNC_REV_RATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_REV_EXCHANGE_RATE,pbl.PROJFUNC_REV_EXCHANGE_RATE) /* due to changes on mc page */
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_REV_RATE_DATE_TYPE,pbl.PROJFUNC_REV_RATE_DATE_TYPE)
                                ,decode(pbl.start_date,null,mc_cur_rec.PROJFUNC_REV_RATE_DATE,pbl.PROJFUNC_REV_RATE_DATE)
                                ,pbl.PROJECT_RAW_COST OLD_PROJ_RAW_COST
                                ,pbl.PROJECT_BURDENED_COST OLD_PROJ_BURDENED_COST
                                ,pbl.PROJECT_REVENUE OLD_PROJ_REVENUE
                                ,pbl.RAW_COST               OLD_PROJFUNC_RAW_COST
                                ,pbl.BURDENED_COST          OLD_PROJFUNC_BURDENED_COST
                                ,pbl.REVENUE                OLD_PROJFUNC_REVENUE
                                ,pbl.QUANTITY               OLD_QUANTITY
                                ,pbl.PROJECT_RAW_COST
                                ,pbl.PROJECT_BURDENED_COST
                                ,pbl.PROJECT_REVENUE
                                ,pbl.RAW_COST
                                ,pbl.BURDENED_COST
                                ,pbl.REVENUE
                                ,pbl.TXN_RAW_COST       OLD_TXN_RAW_COST
                                ,pbl.TXN_BURDENED_COST  OLD_TXN_BURDENED_COST
                                ,pbl.TXN_REVENUE        OLD_TXN_REVENUE
                                ,pbl.TXN_RAW_COST
                                ,pbl.TXN_BURDENED_COST
                                ,pbl.TXN_REVENUE
                                ,pbl.QUANTITY
                                ,'N' DELETE_FLAG
                                ,pbl.ATTRIBUTE_CATEGORY
                                ,pbl.ATTRIBUTE1
                                ,pbl.ATTRIBUTE2
                                ,pbl.ATTRIBUTE3
                                ,pbl.ATTRIBUTE4
                                ,pbl.ATTRIBUTE5
                                ,pbl.ATTRIBUTE6
                                ,pbl.ATTRIBUTE7
                                ,pbl.ATTRIBUTE8
                                ,pbl.ATTRIBUTE9
                                ,pbl.ATTRIBUTE10
                                ,pbl.ATTRIBUTE11
                                ,pbl.ATTRIBUTE12
                                ,pbl.ATTRIBUTE13
                                ,pbl.ATTRIBUTE14
                                ,pbl.ATTRIBUTE15
                                ,pbl.RAW_COST_SOURCE
                                ,pbl.BURDENED_COST_SOURCE
                                ,pbl.QUANTITY_SOURCE
                                ,pbl.REVENUE_SOURCE
                                ,pbl.PM_PRODUCT_CODE
                        FROM  pa_resource_assignments pra
                             ,pa_budget_lines pbl
                             ,pa_proj_fp_options pfo
--                             ,pa_fp_txn_currencies pftc   -- Bug # 2615998
                        WHERE pra.resource_assignment_id = p_resource_assignment_id
                          AND pbl.txn_currency_code = p_txn_currency_code
                          AND pbl.resource_assignment_id = pra.resource_assignment_id
                          AND pfo.fin_plan_version_id = pra.budget_version_id
--                        AND pfo.proj_fp_options_id = pftc.proj_fp_options_id   -- Bug # 2615998
--                        AND pftc.txn_currency_code = p_txn_currency_code       -- Bug # 2615998
                        );

                   l_count := SQL%ROWCOUNT;
                /* Bug found during Unit Testing. Do the insert only in EDIT / EDIT ANOTHER CURRENCY modes */
                IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_VIEW THEN
                   IF nvl(l_count,0) = 0 THEN
                      IF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_R THEN
                              FOR i IN 1..5 LOOP
                                  insert_dummy_record_pvt(mc_cur_rec);
                              END LOOP;
                      ELSE
                              insert_dummy_record_pvt(mc_cur_rec);
                              /*
                              Fix for bug # 2630282 : There will be only one record in case of NONE.
                              txn_currency code is not included in the where clause as it will fail in
                              case of Plan In Another Currency.
                              */

                              UPDATE PA_FP_ROLLUP_TMP
                              SET    START_DATE = l_start_date,
                                     END_DATE   = l_end_date
                              WHERE  resource_assignment_id = p_resource_assignment_id;
                      END IF;
                   END IF;
                END IF;

                   pa_debug.g_err_stage := 'inserted ' || sql%rowcount || ' records';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
              END;

      END IF;

      pa_debug.reset_err_stack; /* Bug 2699888 */

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,'Invalid arguments passed',5);
         pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      pa_debug.reset_err_stack;

      RETURN;

   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG.POPULATE_ROLLUP_TMP'
             ,p_procedure_name =>  pa_debug.G_Err_Stack );
         pa_debug.G_Err_Stack := SQLERRM;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('POPULATE_ROLLUP_TMP: ' || l_module_name,pa_debug.G_Err_Stack,4);
         END IF;
         pa_debug.reset_err_stack;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END POPULATE_ROLLUP_TMP;

/* bug 2645574: Making this process more generic. Now this procedure can be used from places
   other than edit line page. One example is create_finplan_line.
   This procedure now can handle more than one resource assignments in PA_FP_ROLLUP_TMP.
   Logic will now be based upon budget_line_id rather than old_start_Date.
   If budget_line_id is null then it will be considered as new record (to be inserted)
   else records will be updated.
*/


PROCEDURE PROCESS_MODIFIED_LINES
         (
            -- Bug Fix: 4569365. Removed MRC code.
		    p_calling_context            IN  VARCHAR2 -- pa_mrc_finplan.g_calling_module%TYPE /* Bug# 2674353 */
           ,p_resource_assignment_id     IN  pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
           ,p_fin_plan_version_id        IN  pa_resource_assignments.budget_version_id%TYPE -- DEFAULT NULL
           ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                  OUT  NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

   /* Variables to be used for debugging purpose */
    l_msg_count                   NUMBER := 0;
    l_data                        VARCHAR2(2000);
    l_msg_data                    VARCHAR2(2000);
    l_msg_index_out               NUMBER;
    l_return_status               VARCHAR2(2000);
    l_debug_mode                  VARCHAR2(10);
    l_stage                       NUMBER := 100;

    l_task_id      NUMBER;
    l_resource_list_member_id  NUMBER ;
   -- l_pm_product_code           VARCHAR2(30); commented for bug 3858543 as this local variable is not used anywhere

    l_budget_version_id   NUMBER;
    -- Bug Fix: 4569365. Removed MRC code.
    -- l_calling_context     pa_mrc_finplan.g_calling_module%TYPE;
    l_calling_context        VARCHAR2(30);

   -- l_budget_line_tmp pa_budget_lines.budget_line_id%TYPE;

    l_res_assignment_tbl pa_fp_copy_from_pkg.l_res_assignment_tbl_typ ;

    l_disabled_resource_entered VARCHAR2(10);

Cursor c_disabled_resource_exists IS
select 1 from dual
where exists (select prlm.resource_list_member_id
                from  pa_resource_list_members prlm, pa_resource_assignments pra, pa_fp_rollup_tmp tmp
	       where pra.resource_assignment_id = p_resource_assignment_id
		 and  pra.resource_list_member_id= prlm.resource_list_member_id
		 and  nvl(prlm.enabled_flag,'Y') = 'N'
		 and  tmp.resource_assignment_id = pra.resource_assignment_id
		 and  tmp.budget_line_id is null);


BEGIN

    -- Set the error stack.
       pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.PROCESS_MODIFIED_LINES');

    -- Get the Debug mode into local variable and set it to 'Y' if its NULL
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_EDIT_LINE_PKG.PROCESS_MODIFIED_LINES ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

   -- Validating for the Input Parameters

       IF p_resource_assignment_id IS NULL AND p_fin_plan_version_id IS NULL THEN

            pa_debug.g_err_stage := 'both p_resource_assignment_id and budget version id cannot be null.';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

       END IF;

       l_calling_context := p_calling_context; /* Bug# 2674353 */

        /*
        Delete all such lines from rollup_tmp table that are not existing in
        pa_budget_lines and also marked for delete by user.
        */
        pa_debug.g_err_stage := TO_CHAR(l_stage)||'Deleting records from pa_fp_rollup_tmp that are not present in the budget lines table ';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        delete from pa_fp_rollup_tmp
        where  budget_line_id is null    /* FPB3: bug 2645574: Instead of old_start_date refer budget_line_id */
          and (delete_flag = 'Y' or
              (txn_raw_cost is null and
               txn_burdened_cost is null and
               quantity is null and
               txn_revenue is null)); /* Bug 2684537 */

        pa_debug.g_err_stage := TO_CHAR(l_stage)||': Deleted '||sql%rowcount||' records ';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

/******************** Commented for bug#2821961.

           Whatever has been done here is now being done in  PaFpEditViewPlanLineCO.java
           because it was causing unique constraint violation error.

           Bug 2817407: If PD/SD amounts are marked for deletion, we should be negating the
           deleted quantum of PD/SD records and updating the delete_flag back to N. This is done
           because deletion of PD/SD means reducing the PD/SD bucket amounts by that amount and
           we should not be deleting the records as such. This means PD/SD bucket amounts should
           be set to zero if delete flag = Y for them. PC/PFC buckets of PD/SD need not be touched
           since they will be maintained by the call to convert_mc api

        UPDATE  pa_fp_rollup_tmp
        SET     delete_flag = 'N'
               ,txn_raw_cost = DECODE(old_txn_raw_cost, NULL,NULL,0)
               ,txn_burdened_cost = DECODE(old_txn_burdened_cost,NULL,NULL,0)
               ,txn_revenue = DECODE(old_txn_revenue,NULL,NULL,0)
               ,quantity = DECODE(old_quantity,NULL,NULL,0)
        WHERE  delete_flag = 'Y'
        AND    bucketing_period_code IN
                (PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SD,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PD);
*********************/

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage)||': updated '||sql%rowcount||' records ';
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        pa_debug.g_err_stage := TO_CHAR(l_stage)||': populating budget version id , task id and rlm id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF p_resource_assignment_id IS NOT NULL THEN
             --Included this block for bug 3050933.
             BEGIN
                   SELECT budget_version_id, task_id, resource_list_member_id
                     INTO l_budget_version_id, l_task_id, l_resource_list_member_id
                     FROM pa_resource_assignments
                    WHERE resource_assignment_id = p_resource_assignment_id;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage)||'Input res assmt id not found in pa_resource_assignments';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF p_calling_context = PA_FP_CONSTANTS_PKG.G_EDIT_PLAN_LINE_PAGE THEN
                        x_msg_data := 'PA_FP_EPL_TASK_UPDATED';
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  ELSE
                        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                             p_msg_name            => 'PA_FP_EPL_TASK_UPDATED');
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;


             END;

        ELSE
           l_budget_version_id := p_fin_plan_version_id;
           l_task_id           := NULL;
           l_resource_list_member_id := NULL;
        END IF;

        /* Bug# 2674353 - In case of autobaseline, the funding apis would have
           sent the converted amounts in pc and pfc and hence we should not
           be calling mc api. This might do a revaluation based on finplan setup
           which is wrong */

        IF nvl(l_calling_context,-99) <> PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE THEN

          pa_debug.g_err_stage := ': calling convert_txn_currency';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency
              ( p_budget_version_id  => l_budget_version_id
               ,p_entire_version     => 'N'
               ,x_return_status      =>x_return_status
               ,x_msg_count          =>x_msg_count
               ,x_msg_data           =>x_msg_data) ;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN /* Bug# 2644641 */
            pa_debug.g_err_stage := 'MC Api returned error...';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
               pa_debug.g_err_stage := 'calling context : '|| p_calling_context;   -- WEBADI UT
               pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            IF p_calling_context = PA_FP_CONSTANTS_PKG.G_WEBADI THEN              --WEBADI UT
               --This exception needs to be raised only in webadi context.
               Raise PA_FP_CONSTANTS_PKG.MC_Conversion_Failed_Exc;
            END IF;

            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

       END IF;  /* l_calling_context <> PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE */

       -- Delete the lines which have delete_flag = 'Y'
       -- in the temp table

       pa_debug.g_err_stage := TO_CHAR(l_stage)||'Deleting from pa_budget_lines table ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       /* 2645574 : Instead of old_start_date based logic on budget line id now.
          A corresponding row from base table can be identified based upon
          budget line id now
       */
       /*
       DELETE FROM pa_budget_lines bl
       WHERE (bl.resource_assignment_id
             ,bl.txn_currency_code
             ,bl.start_date ) IN (SELECT  tmp.resource_assignment_id
                                         ,tmp.txn_currency_code
                                         ,tmp.old_start_date
                                    FROM  pa_fp_rollup_tmp tmp
                                   WHERE  nvl(tmp.delete_flag,'N') = 'Y') ;
       */

       DELETE /*+ INDEX( bl PA_BUDGET_LINES_U2 )*/ FROM pa_budget_lines bl --Bug 2782166
       WHERE (budget_line_id) IN (SELECT  budget_line_id
                                    FROM  pa_fp_rollup_tmp tmp
                                   WHERE  nvl(tmp.delete_flag,'N') = 'Y');

        pa_debug.g_err_stage := TO_CHAR(l_stage)||': Deleted '||sql%rowcount||' records';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

       -- Update the budget line table with the values
       -- in the temp table for the records that exist
       -- in budget line table

       pa_debug.g_err_stage := TO_CHAR(l_stage)||'Updating the pa_budget_lines table ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       UPDATE /*+ INDEX( bl PA_BUDGET_LINES_U2 )*/ PA_BUDGET_LINES bl --Bug 2782166
          SET (
                 START_DATE
                ,END_DATE
                ,QUANTITY
                ,RAW_COST
                ,BURDENED_COST
                ,REVENUE
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,PROJECT_RAW_COST
                ,PROJECT_BURDENED_COST
                ,PROJECT_REVENUE
                ,TXN_RAW_COST
                ,TXN_BURDENED_COST
                ,TXN_REVENUE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJECT_REV_RATE_DATE
                ,PROJECT_REV_RATE_TYPE
                ,PROJECT_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_DATE_TYPE
                ,RAW_COST_SOURCE
                ,BURDENED_COST_SOURCE
                ,QUANTITY_SOURCE
                ,REVENUE_SOURCE
                /* Code Addition for bug 3394907 starts */
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                /* Code Addition for bug 3394907 ends */

                 ) =
                 (
          SELECT
                  START_DATE
                 ,END_DATE
                 ,decode(bucketing_period_code,NULL,QUANTITY,
                         decode(bl.QUANTITY||tmp.QUANTITY||tmp.old_QUANTITY,null,null,
                         nvl(bl.QUANTITY,0) + (nvl(tmp.QUANTITY,0) - nvl(tmp.old_QUANTITY,0))))
                 ,decode(bucketing_period_code,NULL,tmp.PROJFUNC_RAW_COST,
                         decode(bl.RAW_COST||tmp.PROJFUNC_RAW_COST||tmp.OLD_PROJFUNC_RAW_COST,null,null,
                         nvl(bl.RAW_COST,0) + (nvl(tmp.PROJFUNC_RAW_COST,0) - nvl(tmp.OLD_PROJFUNC_RAW_COST,0)))) /* Bug 2774811 */
                 ,decode(bucketing_period_code,NULL,tmp.PROJFUNC_BURDENED_COST,
                         decode(bl.BURDENED_COST||tmp.PROJFUNC_BURDENED_COST||tmp.OLD_PROJFUNC_BURDENED_COST,null,null,
                         nvl(bl.BURDENED_COST,0) + (nvl(tmp.PROJFUNC_BURDENED_COST,0) - nvl(tmp.OLD_PROJFUNC_BURDENED_COST,0)))) /* Bug 2774811 */
                 ,decode(bucketing_period_code,NULL,tmp.PROJFUNC_REVENUE,
                         decode(bl.REVENUE||tmp.PROJFUNC_REVENUE||tmp.OLD_PROJFUNC_REVENUE,null,null,
                         nvl(bl.REVENUE,0) + (nvl(tmp.PROJFUNC_REVENUE,0) - nvl(tmp.OLD_PROJFUNC_REVENUE,0)))) /* Bug 2774811 */
                 ,CHANGE_REASON_CODE
                 ,DESCRIPTION
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
                 ,PROJFUNC_CURRENCY_CODE
                 ,PROJFUNC_COST_RATE_TYPE
                 ,PROJFUNC_COST_EXCHANGE_RATE
                 ,PROJFUNC_COST_RATE_DATE_TYPE
                 ,PROJFUNC_COST_RATE_DATE
                 ,PROJECT_CURRENCY_CODE
                 ,PROJECT_COST_RATE_TYPE
                 ,PROJECT_COST_EXCHANGE_RATE
                 ,PROJECT_COST_RATE_DATE_TYPE
                 ,PROJECT_COST_RATE_DATE
                 ,decode(bucketing_period_code,NULL,tmp.PROJECT_RAW_COST,
                         decode(bl.PROJECT_RAW_COST||tmp.PROJECT_RAW_COST||tmp.OLD_PROJ_RAW_COST,null,null,
                         nvl(bl.PROJECT_RAW_COST,0) + (nvl(tmp.PROJECT_RAW_COST,0) - nvl(tmp.OLD_PROJ_RAW_COST,0)))) /* Bug 2774811 */
                 ,decode(bucketing_period_code,NULL,tmp.PROJECT_BURDENED_COST,
                         decode(bl.PROJECT_BURDENED_COST||tmp.PROJECT_BURDENED_COST||tmp.OLD_PROJ_BURDENED_COST,null,null,
                         nvl(bl.PROJECT_BURDENED_COST,0) + (nvl(tmp.PROJECT_BURDENED_COST,0) - nvl(tmp.OLD_PROJ_BURDENED_COST,0)))) /* Bug 2774811 */
                 ,decode(bucketing_period_code,NULL,tmp.PROJECT_REVENUE,
                         decode(bl.PROJECT_REVENUE||tmp.PROJECT_REVENUE||tmp.OLD_PROJ_REVENUE,null,null,
                         nvl(bl.PROJECT_REVENUE,0) + (nvl(tmp.PROJECT_REVENUE,0) - nvl(tmp.OLD_PROJ_REVENUE,0)))) /* Bug 2774811 */
                 ,decode(bucketing_period_code,NULL,TXN_RAW_COST,
                         decode(bl.txn_raw_cost||tmp.txn_raw_cost||tmp.old_txn_raw_cost,null,null,
                         nvl(bl.txn_raw_cost,0) + (nvl(tmp.txn_raw_cost,0) - nvl(tmp.old_txn_raw_cost,0))))
                 ,decode(bucketing_period_code,NULL,TXN_BURDENED_COST,
                         decode(bl.txn_burdened_cost||tmp.txn_burdened_cost||tmp.old_txn_burdened_cost,null,null,
                         nvl(bl.txn_burdened_cost,0) + (nvl(tmp.txn_burdened_cost,0) - nvl(tmp.old_txn_burdened_cost,0))))
                 ,decode(bucketing_period_code,NULL,TXN_REVENUE,
                         decode(bl.TXN_REVENUE||tmp.TXN_REVENUE||tmp.old_TXN_REVENUE,null,null,
                         nvl(bl.TXN_REVENUE,0) + (nvl(tmp.TXN_REVENUE,0) - nvl(tmp.old_TXN_REVENUE,0))))
                 ,TXN_CURRENCY_CODE
                 ,BUCKETING_PERIOD_CODE
                 ,PROJFUNC_REV_RATE_DATE
                 ,PROJFUNC_REV_RATE_TYPE
                 ,PROJFUNC_REV_EXCHANGE_RATE
                 ,PROJFUNC_REV_RATE_DATE_TYPE
                 ,PROJECT_REV_RATE_DATE
                 ,PROJECT_REV_RATE_TYPE
                 ,PROJECT_REV_EXCHANGE_RATE
                 ,PROJECT_REV_RATE_DATE_TYPE
                 ,nvl(RAW_COST_SOURCE,decode(PROJFUNC_RAW_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                 ,nvl(BURDENED_COST_SOURCE,decode(PROJFUNC_BURDENED_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                 ,nvl(QUANTITY_SOURCE,decode(QUANTITY,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                 ,nvl(REVENUE_SOURCE,decode(PROJFUNC_REVENUE,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                /* Code Addition for bug 3394907 starts */
                 ,sysdate
                 ,FND_GLOBAL.USER_ID
                 ,FND_GLOBAL.LOGIN_ID
                /* Code Addition for bug 3394907 ends */

            FROM  pa_fp_rollup_tmp tmp
           WHERE  bl.budget_line_id = tmp.budget_line_id
             AND  tmp.budget_line_id IS NOT NULL
             AND  nvl(tmp.delete_flag,'N') <> 'Y')
         WHERE  ( bl.budget_line_id ) IN (SELECT  tmp.budget_line_id
                                            FROM  pa_fp_rollup_tmp tmp
                                            where nvl(tmp.delete_flag,'N') <> 'Y'
                                            AND   tmp.budget_line_id IS NOT NULL);

       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := TO_CHAR(l_stage)||'updated '||sql%rowcount||' budget lines ';
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

/*         Bug 2645574: Now a budget_line_id condition is sufficient.
           WHERE  bl.resource_assignment_id = tmp.resource_assignment_id
             AND  bl.start_date = tmp.old_start_date
             AND  tmp.old_start_date IS NOT NULL
             AND  bl.txn_currency_code = tmp.txn_currency_code
         WHERE  ( bl.resource_assignment_id
                 ,bl.start_date
                 ,bl.txn_currency_code ) IN (SELECT  tmp.resource_assignment_id
                                                    ,tmp.old_start_date
                                                    ,tmp.txn_currency_code
                                               FROM  pa_fp_rollup_tmp tmp
                                               where nvl(tmp.delete_flag,'N') <> 'Y'
                                               AND   tmp.old_start_date IS NOT NULL) ;
*/
/* Introduced following cursor for bug 3289243 */

Open c_disabled_resource_exists;
Fetch c_disabled_resource_exists INTO l_disabled_resource_entered;
Close c_disabled_resource_exists;

IF l_disabled_resource_entered IS NOT NULL THEN
       -- throw error
	IF P_PA_DEBUG_MODE = 'Y' THEN
		pa_debug.g_err_stage := 'Throwing error since amounts are entered for a disabld resource';
		pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
	END IF;
	PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
		             p_msg_name            => 'PA_FP_DISABLED_RES_PLANNE');

	RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
END IF;
/* End of code fix for bug 3289243 */

       -- insert into budget lines table  those
       -- records which are present in tmp table
       -- but does not exist in budget line table

       INSERT INTO pa_budget_lines
              (  RESOURCE_ASSIGNMENT_ID
                ,BUDGET_LINE_ID
                ,BUDGET_VERSION_ID
                ,START_DATE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,END_DATE
                ,PERIOD_NAME
                ,QUANTITY
                ,RAW_COST
                ,BURDENED_COST
                ,REVENUE
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,RAW_COST_SOURCE
                ,BURDENED_COST_SOURCE
                ,QUANTITY_SOURCE
                ,REVENUE_SOURCE
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,PROJECT_RAW_COST
                ,PROJECT_BURDENED_COST
                ,PROJECT_REVENUE
                ,TXN_RAW_COST
                ,TXN_BURDENED_COST
                ,TXN_REVENUE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_TYPE
                ,PROJECT_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_DATE_TYPE
                ,PROJECT_REV_RATE_DATE
                ,PM_PRODUCT_CODE
		,PM_BUDGET_LINE_REFERENCE ) -- Added for bug 3858543
       (SELECT
                RESOURCE_ASSIGNMENT_ID
                ,pa_budget_lines_s.nextval
                ,l_budget_version_id
                ,START_DATE
                ,SYSDATE
                ,FND_GLOBAL.USER_ID
                ,SYSDATE
                ,FND_GLOBAL.USER_ID
                ,FND_GLOBAL.LOGIN_ID
                ,END_DATE
                ,PERIOD_NAME
                ,QUANTITY
                ,PROJFUNC_RAW_COST
                ,PROJFUNC_BURDENED_COST
                ,PROJFUNC_REVENUE
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,nvl(RAW_COST_SOURCE,decode(PROJFUNC_RAW_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(BURDENED_COST_SOURCE,decode(PROJFUNC_BURDENED_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(QUANTITY_SOURCE,decode(QUANTITY,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(REVENUE_SOURCE,decode(PROJFUNC_REVENUE,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,PROJECT_RAW_COST
                ,PROJECT_BURDENED_COST
                ,PROJECT_REVENUE
                ,TXN_RAW_COST
                ,TXN_BURDENED_COST
                ,TXN_REVENUE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_TYPE
                ,PROJECT_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_DATE_TYPE
                ,PROJECT_REV_RATE_DATE
                ,pm_product_code    -- , l_pm_product_code   changed to pm_product_code for bug 3858543
                ,pm_budget_line_reference   -- Added for bug 3858543
          FROM  pa_fp_rollup_tmp tmp
          /* bug 2645574 changed the condition to look into budget_line_id
          WHERE  tmp.old_start_date IS NULL
          */
          WHERE  tmp.budget_line_id IS NULL
            /* manokuma: added following as PD and SD should not be inserted in this procedure */
            /* Bug 2779688 - PD/SD can be inserted in this procedure and hence commenting the where clause
            AND nvl(tmp.bucketing_period_code,'XYZ') NOT IN
           (PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SD,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PD) */
            AND (tmp.txn_raw_cost IS NOT NULL
                 or tmp.txn_burdened_cost IS NOT NULL
                 or tmp.quantity IS NOT NULL
                 or tmp.txn_revenue IS NOT NULL));

       /* Added the following code for WebADI functionality. Increasing the record version number
          on pa_budget_versions table everytime there is a change to the version. */

       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := TO_CHAR(l_stage)||'inserted '|| sql%rowcount ||' budget lines ';
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := TO_CHAR(l_stage)||'Increasing record version no. for Budget Version.';
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF nvl(p_calling_context,'-99') <> PA_FP_CONSTANTS_PKG.G_WEBADI THEN
            UPDATE pa_budget_versions
               SET record_version_number = nvl(record_version_number,0) + 1
             WHERE budget_version_id = l_budget_version_id;
       END IF;

-- Bug Fix: 4569365. Removed MRC code.
/* Bug# 2641475 - MRC call moved here from before the insert/update of pa_budget_lines */

/*  Call MRC API */
/*
       pa_debug.g_err_stage := TO_CHAR(l_stage)||'Calling  MRC API ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

        IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
        PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                 (x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data);
        END IF;

        IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
         PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

         PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                (p_fin_plan_version_id => l_budget_version_id,
                 p_entire_version      => 'N',
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            pa_debug.g_err_stage := TO_CHAR(l_stage)||'Unexpected exception in MRC API '||sqlerrm;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;
        RAISE g_mrc_exception;
        END IF;
*/

           pa_debug.g_err_stage := TO_CHAR(l_stage)||'Calling PA_FP_ROLLUP_PKG ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

          -- call the rollup API

          PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION(
                     p_budget_version_id => l_budget_version_id
                    ,p_entire_version    => 'N'
                    ,x_return_status     => x_return_status
                    ,x_msg_count         => x_msg_count
                    ,x_msg_data          => x_msg_data    ) ;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,'End of process_modified_lines',3);
        END IF;

        pa_debug.reset_err_stack; /* 2641475 */

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,'Invalid arguments passed',5);
         pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      pa_debug.reset_err_stack;

      RETURN;

   WHEN   PA_FP_CONSTANTS_PKG.MC_Conversion_Failed_Exc  THEN  --WEBADI UT.
      -- No processing is required here. The processing will be done in WEBADI PKG.
      RAISE;
   WHEN DUP_VAL_ON_INDEX THEN  --Added this handler for AMG.
      -- Call the api that adds the error messages for duplicate rows

      pa_debug.G_Err_Stack := 'In Dup Value on index. Calling Find_dup_rows_in_rollup_tmp';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.G_Err_Stack,3);
      END IF;

      PA_FP_EDIT_LINE_PKG.Find_dup_rows_in_rollup_tmp
            ( x_return_status => x_return_status
             ,x_msg_count     => x_msg_count
             ,x_msg_data      => x_msg_data);

      x_return_status := FND_API.G_RET_STS_ERROR;
      pa_debug.reset_err_stack;
      RETURN;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
        ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG.PROCESS_MODIFIED_LINES'
         ,p_procedure_name =>  pa_debug.G_Err_Stack );

      pa_debug.G_Err_Stack := SQLERRM;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('PROCESS_MODIFIED_LINES: ' || l_module_name,pa_debug.G_Err_Stack,4);
      END IF;
      pa_debug.reset_err_stack;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PROCESS_MODIFIED_LINES;

PROCEDURE GET_ELEMENT_AMOUNT_INFO
       ( p_resource_assignment_id      IN pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
        ,p_txn_currency_code           IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
        ,p_calling_context            IN  VARCHAR2
        ,x_quantity_flag              OUT NOCOPY pa_fin_plan_amount_sets.cost_qty_flag%TYPE --File.Sql.39 bug 4440895
        ,x_raw_cost_flag              OUT NOCOPY pa_fin_plan_amount_sets.raw_cost_flag%TYPE --File.Sql.39 bug 4440895
        ,x_burdened_cost_flag         OUT NOCOPY pa_fin_plan_amount_sets.burdened_cost_flag%TYPE --File.Sql.39 bug 4440895
        ,x_revenue_flag               OUT NOCOPY pa_fin_plan_amount_sets.revenue_flag%TYPE --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518. Adding three new OUT parameters x_bill_rate_flag,
   x_cost_rate_flag, x_burden_multiplier_flag below for new columns in pa_fin_plan_amount_sets */
/* Changes for FP.M, Tracking Bug No - 3354518. Start here*/
        ,x_bill_rate_flag             OUT NOCOPY pa_fin_plan_amount_sets.bill_rate_flag%TYPE --File.Sql.39 bug 4440895
        ,x_cost_rate_flag             OUT NOCOPY pa_fin_plan_amount_sets.cost_rate_flag%TYPE --File.Sql.39 bug 4440895
        ,x_burden_multiplier_flag     OUT NOCOPY pa_fin_plan_amount_sets.burden_rate_flag%TYPE --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518. End here*/
        ,x_period_profile_id          OUT NOCOPY pa_proj_periods_denorm.PERIOD_PROFILE_ID%TYPE --File.Sql.39 bug 4440895
        ,x_plan_period_type           OUT NOCOPY pa_proj_period_profiles.PLAN_PERIOD_TYPE%TYPE --File.Sql.39 bug 4440895
        ,x_quantity                   OUT NOCOPY pa_budget_lines.QUANTITY%TYPE --File.Sql.39 bug 4440895
        ,x_project_raw_cost           OUT NOCOPY pa_budget_lines.RAW_COST%TYPE --File.Sql.39 bug 4440895
        ,x_project_burdened_cost      OUT NOCOPY pa_budget_lines.BURDENED_COST%TYPE --File.Sql.39 bug 4440895
        ,x_project_revenue            OUT NOCOPY pa_budget_lines.REVENUE%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_raw_cost          OUT NOCOPY pa_budget_lines.RAW_COST%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_burdened_cost     OUT NOCOPY pa_budget_lines.BURDENED_COST%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_revenue           OUT NOCOPY pa_budget_lines.REVENUE%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_margin            OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
        ,x_projfunc_margin_percent    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_proj_margin                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_proj_margin_percent        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data                   OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
 /*
    Bug#2668836
    New parameters are added for project functional currency and project currency
    to calculate margin and margin%. The parameters are :
    x_projfunc_margin,x_project_margin,
    x_projfunc_margin_percent,x_project_margin_percent
  */

 /* Variables to be used for debugging purpose */

  l_msg_count                   NUMBER := 0;
  l_data                        VARCHAR2(2000);
  l_msg_data                    VARCHAR2(2000);
  l_msg_index_out               NUMBER;
  l_return_status               VARCHAR2(2000);
  l_debug_mode                  VARCHAR2(10);
  l_stage                       NUMBER := 100;

/* Variables to be used for debugging purpose */

   l_amount_set_id             NUMBER ;
/* Bug #2645300: Removing the defaulting of the quantity flags. */
   l_cost_qty_flag             VARCHAR2(1) ;
   l_revenue_qty_flag          VARCHAR2(1) ;
   l_all_qty_flag              VARCHAR2(1) ;
   l_period_profile_type       VARCHAR2(30) := null;

--   l_gl_period_type            VARCHAR2(30) := null;
--   l_plan_period_type          VARCHAR2(30) := null;
--   l_number_of_periods         NUMBER ;


   l_preceding_prd_start_date          pa_budget_lines.start_date%TYPE;
   l_preceding_prd_end_date            pa_budget_lines.start_date%TYPE;
   l_succeeding_prd_start_date         pa_budget_lines.start_date%TYPE;
   l_succeeding_prd_end_date           pa_budget_lines.start_date%TYPE;
   l_period_profile_start_date         pa_budget_lines.start_date%TYPE;
   l_period_profile_end_date           pa_budget_lines.start_date%TYPE;
   l_time_phased_code                  pa_proj_fp_options.cost_time_phased_code%TYPE ;
   l_fin_plan_version_id               pa_proj_fp_options.fin_plan_version_id%TYPE   ;
   l_fin_plan_level_code               pa_proj_fp_options.cost_fin_plan_level_code%TYPE   ;
   l_project_start_date                pa_projects_all.start_date%TYPE     ;
   l_project_end_date                  pa_projects_all.start_date%TYPE;
   l_task_start_date                   pa_projects_all.start_date%TYPE;
   l_task_end_date                     pa_projects_all.start_date%TYPE;
   l_plan_period_type                  pa_proj_period_profiles.plan_period_type%TYPE;
   l_period_set_name                   pa_proj_period_profiles.period_set_name%TYPE;
   l_project_currency_code             pa_projects_all.project_currency_code%TYPE;
   l_projfunc_currency_code            pa_projects_all.projfunc_currency_code%TYPE;
   l_margin_derived_from_code          pa_proj_fp_options.margin_derived_from_code%TYPE;
   l_dummy_project_id                  pa_projects_all.project_id%TYPE;

BEGIN
    -- Set the error stack.
         pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.GET_ELEMENT_AMOUNT_INFO');

    -- Get the Debug mode into local variable and set it to 'Y' if its NULL
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_EDIT_LINE_PKG.GET_ELEMENT_AMOUNT_INFO ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

    -- Validating for the Input Parameters

       IF p_calling_context IS NULL THEN

            pa_debug.g_err_stage := 'calling context is null.';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        ELSIF p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN

            IF p_resource_assignment_id IS NULL THEN

                pa_debug.g_err_stage := 'resource assignment id is null in edit in another currency.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;

                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
        ELSE

            IF p_resource_assignment_id IS NULL OR
               p_txn_currency_code IS NULL
            THEN
                pa_debug.g_err_stage := 'one of the input parameter is null.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;


                pa_debug.g_err_stage := 'p_resource_assignment_id = ' || p_resource_assignment_id;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                pa_debug.g_err_stage := 'p_txn_currency_code = ' || p_txn_currency_code;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
                   pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;

                PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;


       POPULATE_LOCAL_VARIABLES(
                  p_resource_assignment_id    => p_resource_assignment_id
                 ,p_txn_currency_code         => p_txn_currency_code
                 ,p_calling_context           => p_calling_context
                 ,x_preceding_prd_start_date  => l_preceding_prd_start_date
                 ,x_preceding_prd_end_date    => l_preceding_prd_end_date
                 ,x_succeeding_prd_start_date => l_succeeding_prd_start_date
                 ,x_succeeding_prd_end_date   => l_succeeding_prd_end_date
                 ,x_period_profile_start_date => l_period_profile_start_date
                 ,x_period_profile_end_date   => l_period_profile_end_date
                 ,x_period_profile_id         => x_period_profile_id
                 ,x_time_phased_code          => l_time_phased_code
                 ,x_fin_plan_version_id       => l_fin_plan_version_id
                 ,x_fin_plan_level_code       => l_fin_plan_level_code
                 ,x_project_start_date        => l_project_start_date
                 ,x_project_end_date          => l_project_end_date
                 ,x_task_start_date           => l_task_start_date
                 ,x_task_end_date             => l_task_end_date
                 ,x_plan_period_type          => x_plan_period_type
                 ,x_period_set_name           => l_period_set_name
                 ,x_project_currency_code     => l_project_currency_code
                 ,x_projfunc_currency_code    => l_projfunc_currency_code
                 ,x_project_id                => l_dummy_project_id
                 ,x_return_status             => l_return_status
                 ,x_msg_count                 => l_msg_count
                 ,x_msg_data                  => l_msg_data
                 );

         l_amount_set_id := pa_fin_plan_utils.Get_Amount_Set_Id(
                             p_fin_plan_version_id  => l_fin_plan_version_id);


         IF p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN

                 pa_debug.g_err_stage := TO_CHAR(l_stage)||':calling PA_FIN_PLAN_UTILS.Get_Element_Proj_PF_Amounts ';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 BEGIN

                     SELECT margin_derived_from_code
                       INTO l_margin_derived_from_code
                       FROM pa_proj_fp_options
                      WHERE fin_plan_version_id = l_fin_plan_version_id;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                        -- DO NOTHING
                 END;

                 PA_FIN_PLAN_UTILS.Get_Element_Proj_PF_Amounts(
                          p_resource_assignment_id   => p_resource_assignment_id
                         ,p_txn_currency_code        => p_txn_currency_code
                         ,x_quantity                 => x_quantity
                         ,x_project_raw_cost         => x_project_raw_cost
                         ,x_project_burdened_cost    => x_project_burdened_cost
                         ,x_project_revenue          => x_project_revenue
                         ,x_projfunc_raw_cost        => x_projfunc_raw_cost
                         ,x_projfunc_burdened_cost   => x_projfunc_burdened_cost
                         ,x_projfunc_revenue         => x_projfunc_revenue
                         ,x_return_status            => x_return_status
                         ,x_msg_count                => x_msg_count
                         ,x_msg_data                 => x_msg_data
                            ) ;


            -- Bug#2668836
            -- checking if margin derived from -code is for raw cost or burdened cost
            -- the calculations are made according to margin derived basis.
            /* Initializing the value of out parameters */
            x_projfunc_margin := 0;
            x_projfunc_margin_percent := 0;
            x_proj_margin := 0;
            x_proj_margin_percent := 0;
            /* Bug#2713480 */
            /* Changed the code from Raw cost/Burden cost to revenue for calculating */
            /* and for margin %  multiply it by 100 */
            IF l_margin_derived_from_code IS NOT NULL THEN
                IF l_margin_derived_from_code = 'R' THEN
                    IF x_projfunc_revenue <> 0 THEN
                        x_projfunc_margin := x_projfunc_revenue - x_projfunc_raw_cost;
                        x_projfunc_margin_percent := (x_projfunc_margin / x_projfunc_revenue)*100;
                    END IF;
                    IF x_project_revenue <> 0 THEN
                        x_proj_margin := x_project_revenue - x_project_raw_cost;
                        x_proj_margin_percent := (x_proj_margin / x_project_revenue)*100;
                    END IF;
                ELSE
                    IF x_projfunc_revenue <> 0 THEN
                        x_projfunc_margin := x_projfunc_revenue - x_projfunc_burdened_cost;
                        x_projfunc_margin_percent := (x_projfunc_margin / x_projfunc_revenue)*100;
                    END IF;
                    IF x_project_revenue <> 0 THEN
                        x_proj_margin := x_project_revenue - x_project_burdened_cost;
                        x_proj_margin_percent := (x_proj_margin / x_project_revenue)*100;
                    END IF;
                 END IF; -- end of IF l_margin_derived_from_code = 'R'
            END IF; -- end of IF l_margin_derived_from_code IS NOT NULL
            pa_debug.g_err_stage := TO_CHAR(x_projfunc_margin)||':'||TO_CHAR(x_projfunc_margin_percent)||':'||TO_CHAR(x_proj_margin)||':'||TO_CHAR(x_proj_margin_percent);
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;
        END IF ;
         /* p_calling_context <> PA_FP_CONSTANTS_PKG.G_CALLING_CONTEXT_OTHER_CURR THEN  */

         pa_debug.g_err_stage := TO_CHAR(l_stage)||':calling PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS ';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;


/* Changes for FP.M, Tracking Bug No - 3354518. Adding three new arguements for x_bill_rate_flag,
x_cost_rate_flag, x_burden_multiplier_flag below for new columns in pa_fin_plan_amount_sets
The Signature of the API PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS has now changed now, so the
API call below is being accrodingly modified. */
         PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS(
              P_AMOUNT_SET_ID      => l_amount_set_id
             ,X_RAW_COST_FLAG      => x_raw_cost_flag
             ,X_BURDENED_FLAG      => x_burdened_cost_flag
             ,X_REVENUE_FLAG       => x_revenue_flag
             ,X_COST_QUANTITY_FLAG => l_cost_qty_flag
             ,X_REV_QUANTITY_FLAG  => l_revenue_qty_flag
             ,X_ALL_QUANTITY_FLAG  => l_all_qty_flag
/* Changes for FP.M, Tracking Bug No - 3354518. Start here*/
             ,X_BILL_RATE_FLAG  => x_bill_rate_flag
             ,X_COST_RATE_FLAG  => x_cost_rate_flag
             ,X_BURDEN_RATE_FLAG  => x_burden_multiplier_flag
/* Changes for FP.M, Tracking Bug No - 3354518. Start here*/
             ,x_message_count      => x_msg_count
             ,x_return_status      => x_return_status
             ,x_message_data       => x_msg_data) ;

         /* #2645300: Set the x_quantity out parameter based on the qty_flag local variables.
            If all the aty_flags are 'N', then the quantity flag should be 'N', if any of the
            qty_flags is 'Y', the quantity flag should be 'Y'. */

         IF (nvl(l_cost_qty_flag,'N') = 'N' AND nvl(l_revenue_qty_flag,'N') = 'N' AND
             nvl(l_all_qty_flag,'N') = 'N') THEN

             x_quantity_flag := 'N';

         ELSIF (nvl(l_cost_qty_flag,'N') = 'Y' OR nvl(l_revenue_qty_flag,'N') = 'Y' OR
             nvl(l_all_qty_flag,'N') = 'Y') THEN

             x_quantity_flag := 'Y';

         END IF;

  pa_debug.reset_err_stack; /* Bug 2699888 */

EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,'Invalid arguments passed',5);
         pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      pa_debug.reset_err_stack;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG.GET_ELEMENT_AMOUNT_INFO'
            ,p_procedure_name =>  pa_debug.G_Err_Stack );
         pa_debug.G_Err_Stack := SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_ELEMENT_AMOUNT_INFO: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ELEMENT_AMOUNT_INFO;

PROCEDURE CALL_CLIENT_EXTENSIONS
          (  p_project_id         IN pa_projects_all.PROJECT_ID%TYPE
            ,p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
            ,p_task_id            IN pa_tasks.TASK_ID%TYPE
            ,p_resource_list_member_id IN pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE
            ,p_resource_list_id   IN pa_resource_lists.RESOURCE_LIST_ID%TYPE
            ,p_resource_id        IN pa_resources.RESOURCE_ID%TYPE
            ,p_txn_currency_code  IN pa_budget_lines.txn_currency_code%TYPE
            ,p_product_code_tbl   IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_start_date_tbl     IN SYSTEM.pa_date_tbl_type
            ,p_end_date_tbl       IN SYSTEM.pa_date_tbl_type
            ,p_period_name_tbl    IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_quantity_tbl       IN SYSTEM.pa_num_tbl_type
            ,px_raw_cost_tbl      IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_burdened_cost_tbl IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_revenue_tbl       IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            )

IS

l_err_code                NUMBER := 0;
l_err_message             VARCHAR2(100);
l_debug_mode              VARCHAR2(30);
l_stage                   NUMBER := 100 ;
l_err_stage               VARCHAR2(120);
l_msg_count               NUMBER  :=0 ;
l_data                    VARCHAR2(160) ;
l_msg_data                VARCHAR2(160) ;
l_msg_index_out           NUMBER;

l_res_list_member_id_tbl   SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_task_id_tbl              SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_resource_id_tbl          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_txn_currency_code_tbl    SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type() ;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'CALL_CLIENT_EXTENSIONS'
                                       ,p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS ';
         pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR (p_budget_version_id IS NULL) THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage)||':Invalid Input Parameters';
           pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,1);

        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'before extending p_start_date_tbl.last = ' || p_start_date_tbl.last;
         pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_task_id_tbl.extend(p_start_date_tbl.last);
    l_res_list_member_id_tbl.extend(p_start_date_tbl.last);
    l_resource_id_tbl.extend(p_start_date_tbl.last);
    l_txn_currency_code_tbl.extend(p_start_date_tbl.last);

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'before filling up the tables';
         pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF nvl(p_start_date_tbl.last,0) >= 1 THEN
         FOR i in p_start_date_tbl.FIRST..p_start_date_tbl.LAST LOOP
              l_task_id_tbl(i) := p_task_id ;
              l_res_list_member_id_tbl(i) := p_resource_list_member_id ;
              l_resource_id_tbl(i) := p_resource_id ;
              l_txn_currency_code_tbl(i) := p_txn_currency_code ;
         END LOOP ;
    END IF ;

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS' ;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
    END IF;

    PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS
          (  p_project_id             => p_project_id
            ,p_budget_version_id      => p_budget_version_id
            ,p_task_id_tbl            => l_task_id_tbl
            ,p_res_list_member_id_tbl => l_res_list_member_id_tbl
            ,p_resource_list_id       => p_resource_list_id
            ,p_resource_id_tbl        => l_resource_id_tbl
            ,p_txn_currency_code_tbl  => l_txn_currency_code_tbl
            ,p_product_code_tbl       => p_product_code_tbl
            ,p_start_date_tbl         => p_start_date_tbl
            ,p_end_date_tbl           => p_end_date_tbl
            ,p_period_name_tbl        => p_period_name_tbl
            ,p_quantity_tbl           => p_quantity_tbl
            ,px_raw_cost_tbl          => px_raw_cost_tbl
            ,px_burdened_cost_tbl     => px_burdened_cost_tbl
            ,px_revenue_tbl           => px_revenue_tbl
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
           ) ;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF ;

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting CALL_CLIENT_EXTENSION' ;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          pa_debug.reset_curr_function;
    END IF;

 EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'inside invalid arg exception of call_client_extensions';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;
       IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
       ELSE
              x_msg_count := l_msg_count;
       END IF;
       IF l_debug_mode = 'Y' THEN
         pa_debug.reset_curr_function;
       END IF ;
       RETURN;
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;
       FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FP_LINE_EDIT_PKG'
          ,p_procedure_name => 'CALL_CLIENT_EXTENSION'
          ,p_error_text     =>  sqlerrm);

       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'inside others exception of process_xface_lines';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
         pa_debug.G_Err_Stack := SQLERRM;
         pa_debug.reset_curr_function;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CALL_CLIENT_EXTENSIONS;

PROCEDURE POPULATE_ELIGIBLE_PERIODS
          (  p_fin_plan_version_id   IN pa_proj_fp_options.fin_plan_version_id%TYPE
            ,p_period_profile_start_date  IN pa_budget_lines.start_date%TYPE
            ,p_period_profile_end_date IN pa_budget_lines.end_date%TYPE
            ,p_preceding_prd_start_date     IN pa_budget_lines.start_Date%TYPE
            ,p_succeeding_prd_start_date    IN pa_budget_lines.start_Date%TYPE
            ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_stage                   NUMBER  := 0;
l_msg_count               NUMBER  :=0 ;
l_data                    VARCHAR2(160) ;
l_msg_data                VARCHAR2(160) ;
l_msg_index_out           NUMBER;
l_debug_mode              VARCHAR2(30);
l_time_phased_code        pa_proj_fp_options.cost_time_phased_code%TYPE;

BEGIN
    -- Set the error stack.
       pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.POPULATE_ELIGIBLE_PERIODS');

    -- Get the Debug mode into local variable and set it to 'Y' if its NULL
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_EDIT_LINE_PKG.POPULATE_ELIGIBLE_PERIODS ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       IF (p_fin_plan_version_id IS NULL) THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage)||':Invalid Input Parameters';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,1);
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       l_stage := 200;
       pa_debug.g_err_stage := TO_CHAR(l_stage)||':Starting the main processing. Inserting into temp table';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       l_time_phased_code := pa_fin_plan_utils.get_time_phased_code(
                                    p_fin_plan_version_id => p_fin_plan_version_id);

       pa_debug.g_err_stage:='l_time_phased_code  is '|| l_time_phased_code;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       pa_debug.g_err_stage:='l_start_period_start_date is '||to_char(p_period_profile_start_date);
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       pa_debug.g_err_stage:='l_end_period_end_date is '||to_char(p_period_profile_end_date) ;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       pa_debug.g_err_stage:='p_preceding_prd_start_date is '||to_char(p_preceding_prd_start_date);
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       pa_debug.g_err_stage:='p_succeeding_prd_start_date is '||to_char(p_succeeding_prd_start_date) ;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       delete from pa_fp_cpy_periods_tmp;

       pa_debug.g_err_stage:='deleted  '||sql%rowcount || ' records from tmp table' ;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;


       IF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P THEN

             pa_debug.g_err_stage:='Populating pa_fp_cpy_periods_tmp in the case of pa_period time phasing';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

             IF p_preceding_prd_start_date IS NOT NULL THEN

                pa_debug.g_err_stage:='inserting into pa_fp_cpy_periods_tmp for preceding period' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                INSERT INTO pa_fp_cpy_periods_tmp
                         ( start_date
                           ,end_date
                           ,pa_period_name
                           ,gl_period_name
                           ,period_name )
                SELECT     start_date      start_date
                           ,end_date       end_date
                           ,period_name    pa_period
                           ,gl_period_name gl_period
                           ,period_name    period_name
                FROM       PA_PERIODS
                WHERE start_date = p_preceding_prd_start_date;

             END IF;

             INSERT INTO pa_fp_cpy_periods_tmp
                      ( start_date
                        ,end_date
                        ,pa_period_name
                        ,gl_period_name
                        ,period_name )
             SELECT     start_date      start_date
                        ,end_date       end_date
                        ,period_name    pa_period
                        ,gl_period_name gl_period
                        ,period_name    period_name
             FROM       PA_PERIODS
             WHERE start_date BETWEEN p_period_profile_start_date AND p_period_profile_end_date;

             pa_debug.g_err_stage := TO_CHAR(l_stage)||'inserted ' || sql%rowcount || ' records';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

             IF p_succeeding_prd_start_date IS NOT NULL THEN

                pa_debug.g_err_stage:='inserting into pa_fp_cpy_periods_tmp for succeeding period' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                INSERT INTO pa_fp_cpy_periods_tmp
                         ( start_date
                           ,end_date
                           ,pa_period_name
                           ,gl_period_name
                           ,period_name )
                SELECT     start_date      start_date
                           ,end_date       end_date
                           ,period_name    pa_period
                           ,gl_period_name gl_period
                           ,period_name    period_name
                FROM       PA_PERIODS
                WHERE start_date = p_succeeding_prd_start_date;

             END IF;

       ELSIF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G THEN

             pa_debug.g_err_stage:='Populating pa_fp_cpy_periods_tmp in the case of gl_period time phasing';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;


             IF p_preceding_prd_start_date IS NOT NULL THEN

                pa_debug.g_err_stage:='inserting into pa_fp_cpy_periods_tmp for preceding period' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                INSERT INTO pa_fp_cpy_periods_tmp
                         ( start_date
                           ,end_date
                           ,pa_period_name
                           ,gl_period_name
                           ,period_name )
                SELECT     g.start_date      start_date
                           ,g.end_date       end_date
                           ,'null'         pa_period
                           ,g.period_name  gl_period
                           ,g.period_name    period_name
                  FROM     PA_IMPLEMENTATIONS  i
                          ,GL_PERIOD_STATUSES g
                  WHERE  g.set_of_books_id = i.set_of_books_id
                    AND g.application_id = pa_period_process_pkg.application_id
                    AND g.adjustment_period_flag = 'N'
                    AND g.start_date = p_preceding_prd_start_date;

             END IF;

             INSERT INTO pa_fp_cpy_periods_tmp(
                         start_date
                         ,end_date
                         ,pa_period_name
                         ,gl_period_name
                         ,period_name )
               SELECT    g.start_date  start_date
                         ,g.end_date    end_period
                         ,'null'        pa_period     /* this value is never used */
                         ,g.period_name gl_period
                         ,g.period_name period_name
               FROM      PA_IMPLEMENTATIONS  i
                         ,GL_PERIOD_STATUSES g
               WHERE  g.set_of_books_id = i.set_of_books_id
                 AND g.application_id = pa_period_process_pkg.application_id
                 AND g.adjustment_period_flag = 'N'
                 AND g.start_date BETWEEN p_period_profile_start_date AND p_period_profile_end_date;

             pa_debug.g_err_stage := TO_CHAR(l_stage)||'inserted ' || sql%rowcount || ' records';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

             IF p_succeeding_prd_start_date IS NOT NULL THEN

                pa_debug.g_err_stage:='inserting into pa_fp_cpy_periods_tmp for preceding period' ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                INSERT INTO pa_fp_cpy_periods_tmp
                         ( start_date
                           ,end_date
                           ,pa_period_name
                           ,gl_period_name
                           ,period_name )
                SELECT     g.start_date      start_date
                           ,g.end_date       end_date
                           ,'null'           pa_period
                           ,g.period_name gl_period
                           ,g.period_name    period_name
                  FROM     PA_IMPLEMENTATIONS  i
                          ,GL_PERIOD_STATUSES g
                  WHERE  g.set_of_books_id = i.set_of_books_id
                    AND g.application_id = pa_period_process_pkg.application_id
                    AND g.adjustment_period_flag = 'N'
                    AND g.start_date = p_succeeding_prd_start_date;

             END IF;

       END IF;

       pa_debug.g_err_stage := TO_CHAR(l_stage)||'end of PA_FP_EDIT_LINE_PKG.POPULATE_ELIGIBLE_PERIODS';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       pa_debug.reset_err_stack; /* Bug 2699888 */

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

         x_return_status := FND_API.G_RET_STS_ERROR;
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                    (p_encoded        => FND_API.G_TRUE,
                     p_msg_index      => 1,
                     p_msg_count      => l_msg_count,
                     p_msg_data       => l_msg_data,
                     p_data           => l_data,
                     p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
         ELSE
                x_msg_count := l_msg_count;
         END IF;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,'Invalid arguments passed or some expected error in client extns',5);
            pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.G_Err_Stack,5);
         END IF;
         pa_debug.reset_err_stack;

         RAISE;
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG.POPULATE_ELIGIBLE_PERIODS'
             ,p_procedure_name =>  pa_debug.G_Err_Stack );
         pa_debug.G_Err_Stack := SQLERRM;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('POPULATE_ELIGIBLE_PERIODS: ' || l_module_name,pa_debug.G_Err_Stack,4);
         END IF;
         pa_debug.reset_err_stack;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END POPULATE_ELIGIBLE_PERIODS;

/*
This api returns the PC and PFC amounts for the input resource assignment id and txn currency code.
Since we want the PD/SD amounts for a particular txn currency we need get it from budget lines
table. PPD table will contain the PC/PFC for ALL txn currencies for the raid and not the split up
for each txn currency and hence cannot be used.
*/

PROCEDURE GET_PD_SD_AMT_IN_PC_PFC(
          p_resource_assignment_id     IN  pa_resource_assignments.resource_assignment_id%TYPE
         ,p_txn_currency_code          IN  pa_budget_lines.txn_currency_code%TYPE
         ,p_period_profile_id          IN  pa_budget_versions.period_profile_id%TYPE
         ,x_pd_pc_raw_cost             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_raw_cost            OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_raw_cost             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_raw_cost            OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pc_burdened_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_burdened_cost       OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_burdened_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_burdened_cost       OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pc_revenue              OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_revenue             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_revenue              OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_revenue             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     pa_debug.set_curr_function( p_function   => 'GET_PD_SD_AMT_IN_PC_PFC',
                                 p_debug_mode => l_debug_mode );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (p_resource_assignment_id IS NULL) OR (p_period_profile_id IS NULL) OR (p_txn_currency_code IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_resource_assignment_id = '|| p_resource_assignment_id;
                  pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  pa_debug.g_err_stage:= 'p_period_profile_id = '|| p_period_profile_id;
                  pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  pa_debug.g_err_stage:= 'p_txn_currency_code = '|| p_txn_currency_code;
                  pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('GET_GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,'getting pd/sd pc/pfc amounts',3);
     END IF;

     BEGIN
     SELECT sum(nvl(raw_cost,0)),
            sum(nvl(burdened_cost,0)),
            sum(nvl(revenue,0)),
            sum(nvl(project_raw_cost,0)),
            sum(nvl(project_burdened_cost,0)),
            sum(nvl(project_revenue,0))
     INTO   x_pd_pfc_raw_cost,
            x_pd_pfc_burdened_cost,
            x_pd_pfc_revenue,
            x_pd_pc_raw_cost,
            x_pd_pc_burdened_cost,
            x_pd_pc_revenue
     FROM  pa_budget_lines
     WHERE resource_assignment_id = p_resource_assignment_id
     AND   txn_currency_code = p_txn_currency_code
     AND   bucketing_period_code in
                (PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PD,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_PE);
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
            x_pd_pfc_raw_cost := null ;
            x_pd_pfc_burdened_cost := null ;
            x_pd_pfc_revenue := null ;
            x_pd_pc_raw_cost := null ;
            x_pd_pc_burdened_cost := null ;
            x_pd_pc_revenue := null ;
     END ;

     BEGIN
     SELECT sum(nvl(raw_cost,0)),
            sum(nvl(burdened_cost,0)),
            sum(nvl(revenue,0)),
            sum(nvl(project_raw_cost,0)),
            sum(nvl(project_burdened_cost,0)),
            sum(nvl(project_revenue,0))
     INTO   x_sd_pfc_raw_cost,
            x_sd_pfc_burdened_cost,
            x_sd_pfc_revenue,
            x_sd_pc_raw_cost,
            x_sd_pc_burdened_cost,
            x_sd_pc_revenue
     FROM  pa_budget_lines
     WHERE resource_assignment_id = p_resource_assignment_id
     AND   txn_currency_code = p_txn_currency_code
     AND   bucketing_period_code in
                (PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SD,PA_FP_CONSTANTS_PKG.G_BUCKETING_PERIOD_CODE_SE);
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
            x_sd_pfc_raw_cost := null ;
            x_sd_pfc_burdened_cost := null ;
            x_sd_pfc_revenue := null ;
            x_sd_pc_raw_cost := null ;
            x_sd_pc_burdened_cost := null ;
            x_sd_pc_revenue := null ;
     END ;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting GET_PD_SD_AMT_IN_PC_PFC';
          pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;
     pa_debug.reset_curr_function;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     IF nvl(x_return_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     pa_debug.reset_curr_function;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_EDIT_LINE_PKG'
                    ,p_procedure_name  => 'GET_PD_SD_AMT_IN_PC_PFC'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write('GET_PD_SD_AMT_IN_PC_PFC: ' || l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
     END IF;
     pa_debug.reset_curr_function;
     RAISE;
END GET_PD_SD_AMT_IN_PC_PFC;

PROCEDURE GET_PRECEDING_SUCCEEDING_AMT(
          p_budget_version_id          IN pa_proj_fp_options.fin_plan_version_id%TYPE
         ,p_resource_assignment_id     IN pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
         ,p_txn_currency_code          IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
         ,p_period_profile_id          IN pa_budget_versions.period_profile_id%TYPE
         ,x_preceding_raw_cost         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_raw_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_burdened_cost    OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_burdened_cost   OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_revenue          OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_revenue         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_quantity         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_quantity        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895


 IS

  l_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE;

  CURSOR period_denorm_cur IS
  SELECT amount_type_code
        ,amount_subtype_code
        ,preceding_periods_amount
        ,succeeding_periods_amount
   FROM  pa_proj_periods_denorm
  WHERE  budget_version_id = p_budget_version_id
    AND  resource_assignment_id = p_resource_assignment_id
    AND  object_type_code = PA_FP_CONSTANTS_PKG.G_OBJECT_TYPE_RES_ASSIGNMENT
    AND  object_id = p_resource_assignment_id
    AND  currency_code = p_txn_currency_code
    AND  period_profile_id = p_period_profile_id
    AND  currency_type = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION ;

  l_period_denorm_cur_rec     period_denorm_cur%ROWTYPE ;

BEGIN
   -- Set the error stack.

      pa_debug.set_err_stack('PA_FP_EDIT_LINE_PKG.GET_PRECEDING_SUCCEEDING_AMT');

   -- Initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.g_err_stage := 'In PA_FP_EDIT_LINE_PKG.GET_PRECEDING_SUCCEEDING_AMT ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('GET_PRECEDING_SUCCEEDING_AMT: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

  SELECT fin_plan_preference_code
    INTO l_fin_plan_preference_code
    FROM pa_proj_fp_options pfo
        ,pa_resource_assignments pra
   WHERE pra.resource_assignment_id = p_resource_assignment_id
     AND pra.budget_version_id = pfo.fin_plan_version_id;

  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write('GET_PRECEDING_SUCCEEDING_AMT: ' || l_module_name,'getting preceding succeeding period amounts',3);
  END IF;

  FOR  l_period_denorm_cur_rec IN  period_denorm_cur LOOP
       IF (l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY
           OR l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ) THEN
             IF ( l_period_denorm_cur_rec.amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
                 AND l_period_denorm_cur_rec.amount_subtype_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_RAW_COST ) THEN
                 x_preceding_raw_cost := l_period_denorm_cur_rec.preceding_periods_amount ;
                 x_succeeding_raw_cost := l_period_denorm_cur_rec.succeeding_periods_amount ;
             ELSIF ( l_period_denorm_cur_rec.amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
                   AND l_period_denorm_cur_rec.amount_subtype_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST ) THEN
                 x_preceding_burdened_cost := l_period_denorm_cur_rec.preceding_periods_amount ;
                 x_succeeding_burdened_cost := l_period_denorm_cur_rec.succeeding_periods_amount ;
             END IF;
       END IF ;

       IF (l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY
           OR l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ) then
            IF ( l_period_denorm_cur_rec.amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE
                AND l_period_denorm_cur_rec.amount_subtype_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE ) THEN
                  x_preceding_revenue := l_period_denorm_cur_rec.preceding_periods_amount ;
                  x_succeeding_revenue := l_period_denorm_cur_rec.succeeding_periods_amount ;
            END IF;
        END IF ;

        IF ( l_period_denorm_cur_rec.amount_type_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY
             AND l_period_denorm_cur_rec.amount_subtype_code = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY ) THEN
              x_preceding_quantity := l_period_denorm_cur_rec.preceding_periods_amount ;
              x_succeeding_quantity := l_period_denorm_cur_rec.succeeding_periods_amount ;
        END IF;
  END LOOP;

  pa_debug.reset_err_stack; /* Bug 2699888 */

EXCEPTION
WHEN OTHERS THEN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('GET_PRECEDING_SUCCEEDING_AMT: ' || l_module_name,'SQLERRM = ' || SQLERRM,5);
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     pa_debug.reset_err_stack; /* Bug 2699888 */
     RAISE;
END GET_PRECEDING_SUCCEEDING_AMT;


/* This function returns the value of the package variable for function security changes */

FUNCTION get_is_fn_security_available RETURN VARCHAR2 IS
BEGIN
     return PA_FP_EDIT_LINE_PKG.G_IS_FN_SECURITY_AVAILABLE;
END get_is_fn_security_available;

PROCEDURE  CALL_CLIENT_EXTENSIONS
          (  p_project_id             IN pa_projects_all.project_id%TYPE
            ,p_budget_version_id      IN pa_budget_versions.budget_version_id%TYPE
            ,p_task_id_tbl            IN SYSTEM.pa_num_tbl_type
            ,p_res_list_member_id_tbl IN SYSTEM.pa_num_tbl_type
            ,p_resource_list_id       IN pa_resource_lists.RESOURCE_LIST_ID%TYPE
            ,p_resource_id_tbl        IN SYSTEM.pa_num_tbl_type
            ,p_txn_currency_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_product_code_tbl       IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_start_date_tbl         IN SYSTEM.pa_date_tbl_type
            ,p_end_date_tbl           IN SYSTEM.pa_date_tbl_type
            ,p_period_name_tbl        IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_quantity_tbl           IN SYSTEM.pa_num_tbl_type
            ,px_raw_cost_tbl          IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_burdened_cost_tbl     IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_revenue_tbl           IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           )
IS
    l_err_code                NUMBER := 0;
    l_err_message             VARCHAR2(100);
    l_debug_mode              VARCHAR2(30);
    l_stage                   NUMBER := 100 ;
    l_err_stage               VARCHAR2(120);
    l_msg_count               NUMBER  :=0 ;
    l_data                    VARCHAR2(160) ;
    l_msg_data                VARCHAR2(160) ;
    l_msg_index_out           NUMBER;

    l_expected_error          BOOLEAN ;
    l_fp_preference_code      pa_proj_fp_options.fin_plan_preference_code%TYPE;

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function   => 'CALL_CLIENT_EXTENSIONS'
                                    ,p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS ';
         pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR (p_budget_version_id IS NULL) THEN
         IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage)||':Invalid Input Parameters';
           pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,1);

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := TO_CHAR(l_stage)||':Calling Client Extensions';
        pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SAVEPOINT call_client_extns;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'getting preference code';
        pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT fin_plan_preference_code
      INTO l_fp_preference_code
      FROM pa_proj_fp_options
     WHERE fin_plan_version_id = p_budget_version_id;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'after getting preference code l_fp_preference_code = ' || l_fp_preference_code;
        pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF nvl(p_start_date_tbl.last,0) >= 1 THEN

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage)||':inside IF block and before for loop';
              pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         IF nvl(px_raw_cost_tbl.last,0) = 0 THEN
              px_raw_cost_tbl     := SYSTEM.pa_num_tbl_type();
         END IF;

         IF nvl(px_burdened_cost_tbl.last,0) = 0 THEN
              px_burdened_cost_tbl     := SYSTEM.pa_num_tbl_type();
         END IF;

         IF nvl(px_revenue_tbl.last,0) = 0 THEN
              px_revenue_tbl     := SYSTEM.pa_num_tbl_type();
         END IF;

         FOR i IN nvl(px_raw_cost_tbl.last,1)..p_start_date_tbl.last LOOP
              px_raw_cost_tbl.extend(1);
         END LOOP;

         FOR i IN nvl(px_burdened_cost_tbl.last,1)..p_start_date_tbl.last LOOP
              px_burdened_cost_tbl.extend(1);
         END LOOP;

         FOR i IN nvl(px_revenue_tbl.last,1)..p_start_date_tbl.last LOOP
              px_revenue_tbl.extend(1);
         END LOOP;

         FOR i IN 1..p_start_date_tbl.last LOOP

              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := TO_CHAR(l_stage)||':inside FOR loop and before calling cal_raw_cost';
                   pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              IF l_fp_preference_code IN (PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

                 PA_CLIENT_EXTN_BUDGET.CALC_RAW_COST
                          (x_budget_version_id         => p_budget_version_id,
                           x_project_id                => p_project_id,
                           x_task_id                   => p_task_id_tbl(i),
                           x_resource_list_member_id   => p_res_list_member_id_tbl(i),
                           x_resource_list_id          => p_resource_list_id,
                           x_resource_id               => p_resource_id_tbl(i),
                           x_start_date                => p_start_date_tbl(i),
                           x_end_date                  => p_end_date_tbl(i),
                           x_period_name               => p_period_name_tbl(i),
                           x_quantity                  => p_quantity_tbl(i),
                           x_raw_cost                  => px_raw_cost_tbl(i),                -- OUT
                           x_pm_product_code           => p_product_code_tbl(i),
                           x_error_code                => l_err_code,
                           x_error_message             => l_err_message,
                           x_txn_currency_code         => p_txn_currency_code_tbl(i)
                           );

                 IF l_err_code > 0 THEN

                        x_return_status :=  FND_API.G_RET_STS_ERROR;
                        IF l_debug_mode = 'Y' THEN
                             pa_debug.G_Err_Stage := 'l_err_code = ' || l_err_code;
                             pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                             pa_debug.G_Err_Stage := 'l_err_message = ' || l_err_message;
                             pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                        END IF;

                        pa_utils.add_message
                           ( p_app_short_name => 'PA',
                             p_msg_name       => 'PA_BU_CALC_RAW_EXTN_ERR',
                             p_token1         => 'ERRNO',
                             p_value1         => to_char(l_err_code),
                             p_token2         => 'ERRMSG',
                             p_value2         => l_err_message);

                        l_expected_error := TRUE;

                   ELSIF l_err_code < 0 THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

                             FND_MSG_PUB.add_exc_msg
                                  (  p_pkg_name           => 'PA_CLIENT_EXTN_BUDGET'
                                  ,  p_procedure_name     => 'CALC_RAW_COST'
                                  ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                        END IF;

                        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                 PA_CLIENT_EXTN_BUDGET.CALC_BURDENED_COST
                        (x_budget_version_id         => p_budget_version_id,
                         x_project_id                => p_project_id,
                         x_task_id                   => p_task_id_tbl(i),
                         x_resource_list_member_id   => p_res_list_member_id_tbl(i),
                         x_resource_list_id          => p_resource_list_id,
                         x_resource_id               => p_resource_id_tbl(i),
                         x_start_date                => p_start_date_tbl(i),
                         x_end_date                  => p_end_date_tbl(i),
                         x_period_name               => p_period_name_tbl(i),
                         x_quantity                  => p_quantity_tbl(i),
                         x_raw_cost                  => px_raw_cost_tbl(i),
                         x_burdened_cost             => px_burdened_cost_tbl(i),      --    OUT
                         x_pm_product_code           => p_product_code_tbl(i),
                         x_error_code                => l_err_code,
                         x_error_message             => l_err_message,
                         x_txn_currency_code         => p_txn_currency_code_tbl(i)
                        );


                IF l_err_code > 0 THEN

                        x_return_status :=  FND_API.G_RET_STS_ERROR;

                        IF l_debug_mode = 'Y' THEN
                             pa_debug.G_Err_Stage := 'l_err_code = ' || l_err_code;
                             pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                             pa_debug.G_Err_Stage := 'l_err_message = ' || l_err_message;
                             pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                        END IF;

                        pa_utils.add_message
                             ( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_BU_CALC_BURDENED_EXTN_ERR',
                               p_token1         => 'ERRNO',
                               p_value1         => to_char(l_err_code),
                               p_token2         => 'ERRMSG',
                               p_value2         => l_err_message);

                        l_expected_error := TRUE;

                   ELSIF l_err_code < 0 THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

                              FND_MSG_PUB.add_exc_msg
                                  (  p_pkg_name           => 'PA_CLIENT_EXTN_BUDGET'
                                  ,  p_procedure_name     => 'CALC_BURDENED_COST'
                                  ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                        END IF;

                        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   END IF;
              END IF; -- preference code is cost only or cost and rev same

              IF l_fp_preference_code IN (PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

              PA_CLIENT_EXTN_BUDGET.CALC_REVENUE
                        (x_budget_version_id         => p_budget_version_id,
                         x_project_id                => p_project_id,
                         x_task_id                   => p_task_id_tbl(i),
                         x_resource_list_member_id   => p_res_list_member_id_tbl(i),
                         x_resource_list_id          => p_resource_list_id,
                         x_resource_id               => p_resource_id_tbl(i),
                         x_start_date                => p_start_date_tbl(i),
                         x_end_date                  => p_end_date_tbl(i),
                         x_period_name               => p_period_name_tbl(i),
                         x_quantity                  => p_quantity_tbl(i),
                         x_revenue                   => px_revenue_tbl(i),      -- OUT
                         x_pm_product_code           => p_product_code_tbl(i),
                         x_error_code                => l_err_code,
                         x_error_message             => l_err_message,
                         x_txn_currency_code         => p_txn_currency_code_tbl(i)
                        );

                  IF l_err_code > 0 THEN
                        x_return_status :=  FND_API.G_RET_STS_ERROR;
                        IF l_debug_mode = 'Y' THEN
                           pa_debug.G_Err_Stage := 'l_err_code = ' || l_err_code;
                           pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                           pa_debug.G_Err_Stage := 'l_err_message = ' || l_err_message;
                           pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.G_Err_Stage,5);
                        END IF;
                        pa_utils.add_message
                             ( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_BU_CALC_REV_EXTN_ERR',
                               p_token1         => 'ERRNO',
                               p_value1         => to_char(l_err_code),
                               p_token2         => 'ERRMSG',
                               p_value2         => l_err_message);

                        l_expected_error := TRUE;

                   ELSIF l_err_code < 0 THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

                             FND_MSG_PUB.add_exc_msg
                                  (  p_pkg_name           => 'PA_CLIENT_EXTN_BUDGET'
                                  ,  p_procedure_name     => 'CALC_REVENUE'
                                  ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                          END IF;

                          x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   END IF;
              END IF;

         END LOOP ;

         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := TO_CHAR(l_stage)||'after loop for start date';
             pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

    END IF; -- if l_start_date_tbl


   IF l_expected_error THEN

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'inside expected error occured';
              pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := TO_CHAR(l_stage)||'leaving client extension ';
      pa_debug.write('CALL_CLIENT_EXTENSIONS: ' || l_module_name,pa_debug.g_err_stage,3);
      pa_debug.reset_curr_function;
   END IF;

EXCEPTION
  WHEN  FND_API.G_EXC_ERROR OR PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

       ROLLBACK to call_client_extns;
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'inside invalid arg exception of process_xface_lines';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
       END IF;
       IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
       ELSE
              x_msg_count := l_msg_count;
       END IF;
       IF l_debug_mode = 'Y' THEN
         pa_debug.reset_curr_function;
       END IF ;
       RETURN;
  WHEN OTHERS THEN

       ROLLBACK to call_client_extns;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;
       FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FP_EDIT_LINE_PKG'
          ,p_procedure_name => 'CALL_CLIENT_EXTENSION'
          ,p_error_text     =>  sqlerrm);

       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'inside others exception of call_client_extension';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
         pa_debug.G_Err_Stack := SQLERRM;
         pa_debug.reset_curr_function;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CALL_CLIENT_EXTENSIONS ;

-- This procedure finds out the all the records in pa_fp_rollup_tmp with same
-- budget start date, txn currency code and resource assignment. This
-- api will be called from process_modified_lines whenever dup_val_on_index
-- exception is raised.

PROCEDURE Find_dup_rows_in_rollup_tmp
( x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

 -- Cursor to detect the duplicate rows
 CURSOR   l_duplicate_rows_csr
 IS
 SELECT   resource_assignment_id,start_date,txn_currency_code
 FROM     pa_fp_rollup_tmp
 GROUP BY resource_assignment_id,txn_currency_code,start_date
 HAVING   COUNT(*)>1;

 -- Cursor to get the resource assignment details
 CURSOR  l_res_assignment_details_csr
         (c_resource_assignment_id  pa_resource_assignments.resource_assignment_id%TYPE)
 IS
 SELECT pra.project_id
        ,pra.task_id
        ,pra.resource_list_member_id
        ,pbv.budget_type_code
        ,pbv.fin_plan_type_id
 FROM    pa_resource_assignments pra
        ,pa_budget_versions pbv
 WHERE   pra.resource_assignment_id = c_resource_assignment_id
 AND     pra.budget_version_id = pbv.budget_version_id ;

 l_res_assignment_details_rec l_res_assignment_details_csr%ROWTYPE;

 l_resource_alias             pa_resource_list_members.alias%TYPE;
 l_segment1                   pa_projects_all.segment1%TYPE;
 l_task_number                pa_tasks.task_number%TYPE;
 l_debug_level3               CONSTANT NUMBER := 3;
 l_debug_level5               CONSTANT NUMBER := 5;
 l_module_name                VARCHAR2(100) := 'pa.plsql.PA_FP_EDIT_LINE_PKG Find_dup_rows_in_rollup_tmp ';
 l_debug_mode                 VARCHAR2(1);
 l_context_info               pa_fin_plan_types_vl.name%TYPE;
 l_count                      NUMBER;

 BEGIN
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

       pa_debug.set_curr_function( p_function   => 'Find_dup_rows_in_rollup_tmp',
                                 p_debug_mode => l_debug_mode );
       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'About to enter the for loop';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

       FOR l_duplicate_rows_rec IN l_duplicate_rows_csr LOOP

            --Get the project number, task number and reasource alias
            --so that they can be passed as parameters
            OPEN l_res_assignment_details_csr (l_duplicate_rows_rec.resource_assignment_id);
            FETCH l_res_assignment_details_csr INTO l_res_assignment_details_rec;
            IF (l_res_assignment_details_csr%NOTFOUND) THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'The Cursor l_res_assignment_details_csr did not return rows';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  CLOSE l_res_assignment_details_csr;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            CLOSE l_res_assignment_details_csr;
            /* bug 3326976 Included substrb */
           l_task_number := substrb((pa_interface_utils_pub.get_task_number_amg
                                      ( p_task_number=> ''
                                        ,p_task_reference => null
                                        ,p_task_id => l_res_assignment_details_rec.task_id)),
					1,
					25);

            SELECT alias
            INTO   l_resource_alias
            FROM   pa_resource_list_members
            WHERE  resource_list_member_id = l_res_assignment_details_rec.resource_list_member_id;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Got the resource alias';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;


            IF l_segment1 IS NULL THEN

                  SELECT segment1
                  INTO   l_segment1
                  FROM   pa_projects_all
                  WHERE  project_id=l_res_assignment_details_rec.project_id;

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Got the Project Number';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;


            l_context_info := l_res_assignment_details_rec.budget_type_code;

            IF l_res_assignment_details_rec.fin_plan_type_id IS NOT NULL THEN

                  SELECT name
                  INTO   l_context_info
                  FROM   pa_fin_plan_types_vl
                  WHERE  fin_plan_type_id = l_res_assignment_details_rec.fin_plan_type_id;

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'About to add error message to stact';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;


            PA_UTILS.add_message
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_BUD_LINE_ALREADY_EXISTS_AMG',
                   p_token1         => 'PROJECT',
                   p_value1         =>  l_segment1,
                   p_token2         => 'TASK',
                   p_value2         => l_task_number,
                   p_token3         => 'BUDGET_TYPE',
                   p_value3         => l_context_info ,
                   p_token4         => 'SOURCE_NAME',
                   p_value4         => l_resource_alias,
                   p_token5         => 'START_DATE',
                   p_value5         => to_char(l_duplicate_rows_rec.start_date));


      END LOOP;
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting Find_dup_rows_in_rollup_tmp';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;
     pa_debug.reset_curr_function;

EXCEPTION
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
                         ( p_pkg_name        => 'PA_FP_EDIT_LINE_PKG'
                          ,p_procedure_name  => 'Find_dup_rows_in_rollup_tmp'
                          ,p_error_text      => x_msg_data);

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            pa_debug.reset_curr_function;
            RAISE;

END  Find_dup_rows_in_rollup_tmp;

/*=================================================================================================
   This api will do the final processing of budget lines data for a budget version. The processing
   includes computing the MC amounts, creating MRC lines if required and rolling budget lines data
   in pa_resource_assignments and pa_proj_periods_denorm.
   This API does not do maintenance of plan amount exist flag on pa_fp_elements because as of now
   this process does not create budget lines. The maintenance of the flag should be done from the
   place where budget lines are created always.
 =================================================================================================*/

PROCEDURE PROCESS_BDGTLINES_FOR_VERSION
   (  p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE
     ,p_calling_context        IN  VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode 			       VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     pa_debug.set_curr_function( p_function   => 'PROCESS_BDGTLINES_FOR_VERSION',
                                 p_debug_mode => l_debug_mode );

     -- Check if the requierd parameters are being passed.

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (p_budget_version_id IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Invalid parameter (p_budget_version_id)';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     /* Call PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY for the MC conversions. */

     PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
                 ( p_budget_version_id  => p_budget_version_id
                  ,p_entire_version     => 'Y'
                  ,x_return_status      => x_return_status
                  ,x_msg_count          => x_msg_count
                  ,x_msg_data           => x_msg_data);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Call to PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY errored... ';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     /* Increasing the Record Version Number, similar to the one being done in the API
        Process_Modified_Lines. The parameter p_calling_context is not being used as of now.
        But in future if there are multiple calling contexts, then it is required that the
        calling context needs to be checked for before updating the Budget Version. */

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Increasing record version no. for Budget Version.';
        pa_debug.write('PROCESS_BDGTLINES_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     UPDATE pa_budget_versions
        SET record_version_number = nvl(record_version_number,0) + 1
           ,last_update_date      = SYSDATE
           ,last_updated_by       = FND_GLOBAL.user_id
           ,last_update_login     = FND_GLOBAL.login_id
      WHERE budget_version_id = p_budget_version_id;

    -- Bug Fix: 4569365. Removed MRC code.
     /* Check if MRC is enabled and Call MRC API */
     /*
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Calling  MRC API ';
        pa_debug.write('PROCESS_BDGTLINES_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
        PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                   (x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);
     END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Unexpected exception in checking MRC Install '||sqlerrm;
             pa_debug.write('PROCESS_BDGTLINES_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
      RAISE g_mrc_exception;
      END IF;

      IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
         PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

         PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                (p_fin_plan_version_id => p_budget_version_id,
                 p_entire_version      => 'Y',
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Unexpected exception in MRC API '||sqlerrm;
             pa_debug.write('PROCESS_BDGTLINES_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
      RAISE g_mrc_exception;
      END IF;
      */

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Calling PA_FP_ROLLUP_PKG ';
         pa_debug.write('PROCESS_BDGTLINES_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

      /* Call the rollup API to rollup the amounts. */
      PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION(
                 p_budget_version_id => p_budget_version_id
                ,p_entire_version    => 'Y'
                ,x_return_status     => x_return_status
                ,x_msg_count         => x_msg_count
                ,x_msg_data          => x_msg_data    ) ;


     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Call to PA_FP_ROLLUP_PKG errored... ';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PROCESS_BDGTLINES_FOR_VERSION';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;
     pa_debug.reset_curr_function;
EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     pa_debug.reset_curr_function;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_EDIT_LINE_PKG'
                    ,p_procedure_name  => 'PROCESS_BDGTLINES_FOR_VERSION'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
     END IF;
     pa_debug.reset_curr_function;
     RAISE;
END PROCESS_BDGTLINES_FOR_VERSION;

END PA_FP_EDIT_LINE_PKG;

/
