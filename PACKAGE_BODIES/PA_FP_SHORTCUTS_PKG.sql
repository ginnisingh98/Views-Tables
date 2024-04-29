--------------------------------------------------------
--  DDL for Package Body PA_FP_SHORTCUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_SHORTCUTS_PKG" AS
/* $Header: PAFPSHPB.pls 120.3 2006/06/12 06:25:26 nkumbi noship $ */
p_pa_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_module VARCHAR2(50) := 'pa_fp_shortcuts_pkg';
/* Calling Module : Project Home shortcut Financial dummy page
                    Budgeting and Forecasting page
   When called from dummy page, this pakcage identify the
   plan type and returns the budget versiond id along with the URL.
   When called from Budgeting and Forecasting page the plan type id is
   always passed. This API checks the validity of the plan type and the option
   selected and returns the budget version id and the URL */
/* 07/13/2005 dlai - added parameter p_same_org_id_flag for R12 MOAC effort to remove
 *                   dependency on pa_fp_org_fcst_utils.same_org_id
 */
PROCEDURE identify_plan_version_id(
          p_project_id            IN        pa_projects_all.project_id%TYPE,
          p_function_code         IN        VARCHAR2,
          p_context               IN        VARCHAR2 DEFAULT NULL,
          p_user_id               IN        NUMBER,
          p_same_org_id_flag      IN        VARCHAR2, -- Bug 5276024: Making this field mandatory -- DEFAULT 'N',
          px_fin_plan_type_id     IN  OUT   NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
          x_budget_version_id     OUT       NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
          x_redirect_url          OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_request_id            OUT       NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
          x_plan_processing_code  OUT       NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
          x_proj_fp_option_id     OUT       NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
          x_return_status         OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT       NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data              OUT       NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
   l_version_type             pa_budget_versions.version_type%type;
   l_plan_class_code          pa_fin_plan_types_b.plan_class_code%type;
   l_fin_plan_type_id         pa_fin_plan_types_b.fin_plan_type_id%type;
   l_edit_in_excel_flag       VARCHAR2(1) := 'N';
   l_no_of_fcst_plan_types    NUMBER;
   l_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%type;
   l_baseline_funding_flag    pa_projects_all.baseline_funding_flag%TYPE;
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_data                     VARCHAR2(2000);
   l_msg_index_out            NUMBER;
   l_cost_fin_plan_type_id    pa_fin_plan_types_b.fin_plan_type_id%type;
   l_rev_fin_plan_type_id     pa_fin_plan_types_b.fin_plan_type_id%type;
   l_fp_options_id            pa_proj_fp_options.proj_fp_options_id%TYPE;
   l_temp_pref_code           pa_proj_fp_options.fin_plan_preference_code%type;
   l_same_org_id         VARCHAR2(1);
   l_bdgt_version_id          pa_budget_versions.budget_version_id%TYPE;  -- Added for bug 4089561
   l_approved_rev_plan_type_flag  VARCHAR2(1);


BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FP_SHORTCUTS_PKG.identify_plan_version_id');
       pa_debug.write( x_module => l_module,
                       x_msg => 'proj id :'||p_project_id||' fn code :'||p_function_code,
                       x_log_level => 3);
       pa_debug.write( x_module => l_module,
                       x_msg => 'context :'||p_context||' uid :'||p_user_id,
                       x_log_level => 3);
       pa_debug.write( x_module => l_module,
                       x_msg => 'ptype id :'||px_fin_plan_type_id,
                       x_log_level => 3);
   END IF;
   l_same_org_id := p_same_org_id_flag;
    --Added for bug 4117017.
    IF p_function_code IN ( 'PA_FP_EDIT_REV_BUDGET', 'PA_FP_EDIT_REV_BUDGET_EXCEL', 'PA_FP_EDIT_COST_BUDGET', 'PA_FP_EDIT_COST_BUDGET_EXCEL',
                           'PA_FP_EDIT_REV_FCST', 'PA_FP_EDIT_REV_FCST_EXCEL', 'PA_FP_EDIT_COST_FCST', 'PA_FP_EDIT_COST_FCST_EXCEL'  ) THEN
		if l_same_org_id = 'N' then
			x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                           || '&paProjectId=' || p_project_id
                          || '&pMsg=PA_CROSSOU_NO_UPDATE';
			RETURN;
		END if;
    END IF;

   --If the financial structure is not enabled for the project then the budget creation/updation
   --should not be possible
   IF pa_project_structure_utils.get_fin_struc_ver_id( p_project_id => p_project_id) IS NULL THEN

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write( x_module    => l_module,
                           x_msg       => 'Financial structure is not enabled for the project '||p_project_id,
                           x_log_level => 5);
       END IF;

       --Now the user should be re-directed to Budgets and Forecasts Page where the error message will be
       --displayed
       x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275';

       IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Err_stack;
       END IF;
       RETURN;

   END IF;


   /* bug 2959269 check for auto baseline enabled projects. If any of the Revenue
      shortcut option is selected in Project Home page, then error should be
      raised in the Budgets and Forecasts page as editing the Revenue version is
      not allowed for these types or projects. */

   l_baseline_funding_flag := 'N';

   BEGIN
       SELECT NVL(Baseline_Funding_Flag,'N')
       INTO
              l_baseline_funding_flag
       FROM
       Pa_Projects_All WHERE Project_Id = p_project_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
      IF fnd_msg_pub.count_msg = 1 THEN
          PA_INTERFACE_UTILS_PUB.Get_Messages (
                                        p_encoded        => FND_API.G_TRUE,
                                        p_msg_index      => 1,
                                        p_msg_count      => 1 ,
                                        p_msg_data       => l_msg_data ,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );
             x_msg_data := l_data;
             x_msg_count := 1;
      ELSE
          x_msg_count := fnd_msg_pub.count_msg;
      END IF;
      IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Err_stack;
      END IF;
      RETURN;
   END;

--Added the code to allow editing of the version in case the revenue version is not of an approved plan type. This will happen when Edit Revenue
-- is chosen from the Budgets and Forecasts page.

    IF p_context IS NULL THEN

       SELECT NVL(approved_rev_plan_type_flag,'N')
       INTO  l_approved_rev_plan_type_flag
       FROM pa_proj_fp_options
       WHERE Project_Id = p_project_id
       AND fin_plan_type_id = px_fin_plan_type_id
       AND fin_plan_version_id IS NULL
       AND fin_plan_option_level_code = 'PLAN_TYPE';

    ELSE
        l_approved_rev_plan_type_flag := 'Y';
    END IF;

   IF l_baseline_funding_flag = 'Y' AND l_approved_rev_plan_type_flag = 'Y' AND
      p_function_code IN ( 'PA_FP_EDIT_REV_BUDGET',
                           'PA_FP_EDIT_REV_BUDGET_EXCEL'  ) THEN
      /* setting url for Budgets and Forecasts page */

        x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                        || '&paProjectId=' || p_project_id
                          || '&pMsg=PA_FP_AB_REV_SH_OPT';

        IF p_context IS NOT NULL THEN
           x_redirect_url := x_redirect_url ||'&pContext='||p_context;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Err_stack;
        END IF;
        RETURN;

   END IF;
   /* bug 2959269   */

   l_fin_plan_type_id := px_fin_plan_type_id;

   IF p_function_code IN ( 'PA_FP_EDIT_COST_BUDGET',
                           'PA_FP_EDIT_REV_BUDGET',
                           'PA_FP_EDIT_COST_BUDGET_EXCEL',
                           'PA_FP_EDIT_REV_BUDGET_EXCEL',
                           'PJI_VIEW_BDGT_TASK_SUMMARY') THEN
      l_plan_class_code := 'BUDGET';
      IF p_function_code IN ( 'PA_FP_EDIT_COST_BUDGET',
                           'PA_FP_EDIT_COST_BUDGET_EXCEL' ) THEN
         l_version_type := 'COST';
      ELSIF p_function_code IN ( 'PA_FP_EDIT_REV_BUDGET',
                           'PA_FP_EDIT_REV_BUDGET_EXCEL' ) THEN
         l_version_type := 'REVENUE';
      ELSIF p_function_code = 'PJI_VIEW_BDGT_TASK_SUMMARY' THEN
         l_version_type := 'BOTH';
      END IF;
   END IF;
   IF p_function_code IN ( 'PA_FP_EDIT_COST_FCST',
                           'PA_FP_EDIT_REV_FCST',
                           'PA_FP_EDIT_COST_FCST_EXCEL',
                           'PA_FP_EDIT_REV_FCST_EXCEL',
                           'PJI_VIEW_FCST_TASK_SUMMARY') THEN
      l_plan_class_code := 'FORECAST';
      IF p_function_code IN ( 'PA_FP_EDIT_COST_FCST',
                           'PA_FP_EDIT_COST_FCST_EXCEL' ) THEN
         l_version_type := 'COST';
      ELSIF p_function_code IN ( 'PA_FP_EDIT_REV_FCST',
                           'PA_FP_EDIT_REV_FCST_EXCEL' ) THEN
         l_version_type := 'REVENUE';
      ELSIF p_function_code = 'PJI_VIEW_FCST_TASK_SUMMARY' THEN
         l_version_type := 'BOTH';
      END IF;
   END IF;
   IF p_function_code like '%EXCEL' THEN
      l_edit_in_excel_flag := 'Y';
   END IF;
   IF px_fin_plan_type_id IS NULL THEN
     IF l_version_type = 'BOTH' THEN

       IF l_plan_class_code = 'BUDGET' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write( x_module => l_module,
                       x_msg => 'calling get_app_budget_pt_id api',
                       x_log_level => 3);
         END IF;

         pa_fp_shortcuts_pkg.get_app_budget_pt_id(
                            p_project_id       => p_project_id,
                            p_version_type     => 'COST',
                            p_context          => p_context,
                            p_function_code    =>  p_function_code,
                            x_fin_plan_type_id => l_cost_fin_plan_type_id,
                            x_redirect_url     => x_redirect_url,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
         END IF;

         pa_fp_shortcuts_pkg.get_app_budget_pt_id(
                            p_project_id       => p_project_id,
                            p_version_type     => 'REVENUE',
                            p_context          => p_context,
                            p_function_code    =>  p_function_code,
                            x_fin_plan_type_id => l_rev_fin_plan_type_id,
                            x_redirect_url     => x_redirect_url,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
           END IF;

         IF l_cost_fin_plan_type_id is null AND
             l_rev_fin_plan_type_id is null THEN
              /* setting url for Budgets and forecasts page */
              x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                                 || '&pMsg=PA_FP_NO_AB_PLAN_TYPE';

                    IF p_context IS NOT NULL THEN
                         x_redirect_url := x_redirect_url ||'&pContext='||p_context;
                    END IF;
                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
               RETURN;
           END IF;

      ELSIF l_plan_class_code = 'FORECAST' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write( x_module => l_module,
                       x_msg => 'calling get_fcst_plan_type_id api',
                       x_log_level => 3);
         END IF;
         pa_fp_shortcuts_pkg.get_fcst_plan_type_id(
                            p_project_id       => p_project_id,
                            p_version_type     => 'COST',
                            p_context          => p_context,
                            p_function_code    => p_function_code,
                            x_fin_plan_type_id => l_cost_fin_plan_type_id,
                            x_redirect_url     => x_redirect_url,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
         END IF;

         pa_fp_shortcuts_pkg.get_fcst_plan_type_id(
                            p_project_id       => p_project_id,
                            p_version_type     => 'REVENUE',
                            p_context          => p_context,
                            p_function_code    =>  p_function_code,
                            x_fin_plan_type_id => l_rev_fin_plan_type_id,
                            x_redirect_url     => x_redirect_url,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
           END IF;

         IF l_cost_fin_plan_type_id is null AND
             l_rev_fin_plan_type_id is null THEN
              /* setting url for Budgets and forecasts page */
              x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                                 || '&pMsg=PA_FP_NO_FCST_PLAN_TYPE';

                    IF p_context IS NOT NULL THEN
                         x_redirect_url := x_redirect_url ||'&pContext='||p_context;
                    END IF;
                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
               RETURN;
           END IF;

       END IF; -- l_plan_class_code

     ELSE -- l_version_type

      IF l_plan_class_code = 'BUDGET' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write( x_module => l_module,
                       x_msg => 'calling get_app_budget_pt_id api',
                       x_log_level => 3);
         END IF;

         pa_fp_shortcuts_pkg.get_app_budget_pt_id(
                            p_project_id       => p_project_id,
                            p_version_type     => l_version_type,
                            p_context          => p_context,
                            p_function_code    => p_function_code,
                            x_fin_plan_type_id => l_fin_plan_type_id,
                            x_redirect_url     => x_redirect_url,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data );
         px_fin_plan_type_id := l_fin_plan_type_id;
         IF x_redirect_url IS NOT NULL OR
            x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
         END IF;
      ELSIF l_plan_class_code = 'FORECAST' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write( x_module => l_module,
                       x_msg => 'calling get_fcst_plan_type_id api',
                       x_log_level => 3);
         END IF;
         pa_fp_shortcuts_pkg.get_fcst_plan_type_id(
                            p_project_id            => p_project_id,
                            p_version_type          => l_version_type,
                            p_context               => p_context,
                            p_function_code         => p_function_code,
                            x_fin_plan_type_id      => l_fin_plan_type_id,
                            x_redirect_url          => x_redirect_url,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data  );
         px_fin_plan_type_id := l_fin_plan_type_id;
         IF x_redirect_url IS NOT NULL OR
            x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
         END IF;
     END IF;
    END IF; -- l_version_type
   ELSE
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write( x_module => l_module,
                       x_msg => 'plan type id passed, validating plan type pref code',
                       x_log_level => 3);
      END IF;

      SELECT po.fin_plan_preference_code INTO l_fin_plan_preference_code
      FROM pa_proj_fp_options po
      WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = px_fin_plan_type_id;

      IF l_version_type = 'COST' AND
         l_fin_plan_preference_code = 'REVENUE_ONLY' THEN
         /* setting url for Budgets and forecasts page */
         x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                         || '&paProjectId=' || p_project_id
                           || '&pMsg=PA_FP_REV_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      ELSIF l_version_type = 'REVENUE' AND
         l_fin_plan_preference_code = 'COST_ONLY' THEN
         /* setting url for Budgets and forecasts page */
         x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                         || '&paProjectId=' || p_project_id
                           || '&pMsg=PA_FP_COST_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      END IF;
   END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write(  x_module => l_module,
                       x_msg => 'getting current working version',
                       x_log_level => 3);
   END IF;

   IF l_version_type = 'BOTH' THEN
     IF l_cost_fin_plan_type_id is NOT NULL THEN
     /* Bug 3658139: Getting the preference_code to check for the
      * case of approved budget with COST_AND_REV_SAME.
      */
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write(  x_module => l_module,
                                x_msg => 'getting the preference code',
                                x_log_level => 3);
          END IF;
          BEGIN
               SELECT fin_plan_preference_code
               INTO   l_temp_pref_code
               FROM   pa_proj_fp_options
               WHERE  project_id = p_project_id
               AND    fin_plan_type_id = l_cost_fin_plan_type_id
               AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;
          EXCEPTION
               WHEN OTHERS THEN
                    RAISE;
          END;
          IF l_temp_pref_code = 'COST_AND_REV_SAME' THEN
                pa_fin_plan_utils.get_curr_working_version_info(
                     p_project_id             => p_project_id,
                     p_fin_plan_type_id       => l_cost_fin_plan_type_id,
                     p_version_type           => 'ALL',
                     x_fp_options_id          => l_fp_options_id,
                     x_fin_plan_version_id    => x_budget_version_id,
                     x_return_status          => x_return_status,
                     x_msg_count              => x_msg_count,
                     x_msg_data               => x_msg_data );

                l_bdgt_version_id := x_budget_version_id; /*Added for bug 4089561. If its a 'COST_AND_REV_SAME' case then
                                            paRevContextVersionId should also be set equal to x_budget_version_id derived above.*/
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                     END IF;
                     RETURN;
                END IF;
          ELSE
                pa_fin_plan_utils.get_curr_working_version_info(
                     p_project_id             => p_project_id,
                     p_fin_plan_type_id       => l_cost_fin_plan_type_id,
                     p_version_type           => 'COST',
                     x_fp_options_id          => l_fp_options_id,
                     x_fin_plan_version_id    => x_budget_version_id,
                     x_return_status          => x_return_status,
                     x_msg_count              => x_msg_count,
                     x_msg_data               => x_msg_data );

                l_bdgt_version_id :=  -99; /*Added for bug 4089561. If its not  'COST_AND_REV_SAME' case then
                                           paRevContextVersionId should be set equal to -99*/
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                     END IF;
                     RETURN;
                END IF;
          END IF;
            IF x_budget_version_id is NOT NULL THEN
             /* setting url for View Plan page */
              IF l_plan_class_code =  'BUDGET' THEN  --'PJI_VIEW_BDGT_TASK_SUMMARY'  THEN -- Changed hkulkarn
                    x_redirect_url := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetTaskSumPG'
                                        ||'&paProjectId=' || p_project_id
                                        ||'&paFinTypeId=' || l_cost_fin_plan_type_id
                                        ||'&paCstContextVersionId=' || x_budget_version_id
                                        ||'&paRevContextVersionId=' || l_bdgt_version_id; --changed for bug 4089561

                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
                    RETURN;
              ELSIF l_plan_class_code = 'FORECAST' THEN --'PJI_VIEW_FCST_TASK_SUMMARY'  THEN -- Changed hkulkarn
                    x_redirect_url := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/ForecastTaskSummaryPG'
                                        ||'&paProjectId=' || p_project_id
                                        ||'&paFinTypeId=' || l_cost_fin_plan_type_id
                                        ||'&paCstContextVersionId=' || x_budget_version_id
                                        ||'&paRevContextVersionId=' || l_bdgt_version_id; --changed for bug 4089561

                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
                    RETURN;
              END IF;
            END IF; -- x_budget_version_id

     END IF; -- l_cost_fin_plan_type_id

     IF  x_budget_version_id is NULL AND
          l_rev_fin_plan_type_id is NOT NULL THEN

     pa_fin_plan_utils.get_curr_working_version_info(
                     p_project_id             => p_project_id,
                     p_fin_plan_type_id       => l_rev_fin_plan_type_id,
                     p_version_type           => 'REVENUE',
                     x_fp_options_id          => l_fp_options_id,
                     x_fin_plan_version_id    => x_budget_version_id,
                     x_return_status          => x_return_status,
                     x_msg_count              => x_msg_count,
                     x_msg_data               => x_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF p_pa_debug_mode = 'Y' THEN
                    PA_DEBUG.Reset_Err_stack;
               END IF;
               RETURN;
            END IF;

            IF x_budget_version_id is NOT NULL THEN
             /* setting url for View Plan page */
              IF l_plan_class_code = 'BUDGET' THEN  --'PJI_VIEW_BDGT_TASK_SUMMARY'  THEN -- Changed hkulkarn
                    x_redirect_url := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/VPBudgetTaskSumPG'
                                        ||'&paProjectId=' || p_project_id
                                        ||'&paFinTypeId=' || l_rev_fin_plan_type_id
                                        ||'&paCstContextVersionId=-99'
                                        ||'&paRevContextVersionId=' || x_budget_version_id;

                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
                    RETURN;
              ELSIF l_plan_class_code = 'FORECAST' THEN --'PJI_VIEW_FCST_TASK_SUMMARY'  THEN -- Changed hkulkarn
                    x_redirect_url := 'OA.jsp?page=/oracle/apps/pji/viewplan/reporting/webui/ForecastTaskSummaryPG'
                                        ||'&paProjectId=' || p_project_id
                                        ||'&paFinTypeId=' || l_rev_fin_plan_type_id
                                        ||'&paCstContextVersionId=-99'
                                        ||'&paRevContextVersionId=' || x_budget_version_id;

                    IF p_pa_debug_mode = 'Y' THEN
                         PA_DEBUG.Reset_Err_stack;
                    END IF;
                    RETURN;
              END IF;
            END IF; -- x_budget_version_id

     END IF; -- l_rev_fin_plan_type_id

     IF x_budget_version_id is null THEN
        /* setting url for Budgets and Forecasts page */
        x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                          || '&pMsg=PA_FP_NO_CW_VER';

        IF p_context IS NOT NULL THEN
           x_redirect_url := x_redirect_url ||'&pContext='||p_context;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
        END IF;
        RETURN;

     END IF; -- x_budget_version_id

   ELSE

   pa_fp_shortcuts_pkg.get_cw_version(
                     p_project_id             => p_project_id,
                     p_plan_class_code        => l_plan_class_code,
                     p_version_type           => l_version_type,
                     p_fin_plan_type_id       => px_fin_plan_type_id,
                     p_edit_in_excel_Flag     => l_edit_in_excel_Flag,
                     p_user_id                => p_user_id,
                     p_context                => p_context,
                     x_budget_version_id      => x_budget_version_id,
                     x_redirect_url           => x_redirect_url,
                     x_request_id             => x_request_id,
                     x_plan_processing_code   => x_plan_processing_code,
                     x_proj_fp_option_id      => x_proj_fp_option_id,
                     x_return_status          => x_return_status,
                     x_msg_count              => x_msg_count,
                     x_msg_data               => x_msg_data );


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF p_pa_debug_mode = 'Y' THEN
                    PA_DEBUG.Reset_Err_stack;
               END IF;
               RETURN;
            END IF;
-- S.N. hkulkarn
     IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Err_stack;
     END IF;
-- E.N. hkulkarn

   END IF; -- l_version_type

EXCEPTION
  WHEN OTHERS THEN
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_SHORTCUTS_PKG',
                            p_procedure_name => 'IDENTIFY_PLAN_VERSION_ID',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END identify_plan_version_id;

/* This API returns the approved budget plan type id based on the shortcut
   option selected in the Project Home. If the approved budget plan type does not
   exist, then the URL will be returned with the error message and the information
   for page. */

PROCEDURE get_app_budget_pt_id(
                     p_project_id IN pa_projects_all.project_id%TYPE,
                     p_version_type IN pa_budget_versions.version_type%TYPE,
                     p_context IN VARCHAR2,
                     p_function_code IN VARCHAR2 DEFAULT NULL,
                     x_fin_plan_type_id OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
                     x_redirect_url OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data      OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
CURSOR approved_budget_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        (pt.approved_cost_plan_type_flag = 'Y' OR
         pt.approved_rev_plan_type_flag = 'Y');

approved_budget_rec approved_budget_csr%ROWTYPE;


CURSOR approved_cost_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        po.fin_plan_preference_code <> 'REVENUE_ONLY' AND
        pt.approved_cost_plan_type_flag = 'Y';

approved_cost_rec approved_cost_csr%ROWTYPE;

CURSOR approved_revenue_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        po.fin_plan_preference_code <> 'COST_ONLY' AND
        pt.approved_rev_plan_type_flag = 'Y';

approved_revenue_rec approved_revenue_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_FP_SHORTCUTS_PKG.get_app_budget_pt_id');
      pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for approved budget',
                       x_log_level => 3);
   END IF;
   OPEN approved_budget_csr;
   FETCH approved_budget_csr INTO approved_budget_rec;
   IF approved_budget_csr%NOTFOUND THEN
       IF p_function_code = 'PJI_VIEW_BDGT_TASK_SUMMARY' THEN
           NULL;
            IF p_pa_debug_mode = 'Y' THEN
                   PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
       ELSE
        /* setting url for Budgets and Forecasts page */
        x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                        || '&paProjectId=' || p_project_id
                          || '&pMsg=PA_FP_NO_AB_PLAN_TYPE';

        IF p_context IS NOT NULL THEN
           x_redirect_url := x_redirect_url ||'&pContext='||p_context;
        END IF;
        CLOSE approved_budget_csr;
        IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
        END IF;
        RETURN;
       END IF;
   END IF;
   CLOSE approved_budget_csr;

   IF p_version_type = 'COST' THEN
        -- COST BUDGET
        -- Validate: Approved Budget Plan type allows for cost numbers
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for cost approved budget',
                       x_log_level => 3);
        END IF;
        OPEN approved_cost_csr;
        FETCH approved_cost_csr INTO approved_cost_rec;
        IF approved_cost_csr%NOTFOUND THEN
          /* setting url for Budgets and Forecasts page */
          x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                          || '&paProjectId=' || p_project_id
                            || '&pMsg=PA_FP_REV_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
        ELSE
          x_fin_plan_type_id := approved_cost_rec.fin_plan_type_id;
        END IF;
        CLOSE approved_cost_csr;
      ELSIF p_version_type = 'REVENUE' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for revenue approved budget',
                       x_log_level => 3);
        END IF;
        OPEN approved_revenue_csr;
        FETCH approved_revenue_csr INTO approved_revenue_rec;
        IF approved_revenue_csr%NOTFOUND THEN
          /* setting url for Budgets and Forecasts page */
          x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                          || '&paProjectId=' || p_project_id
                            || '&pMsg=PA_FP_COST_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
          CLOSE approved_revenue_csr;
          IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
          END IF;
          RETURN;
        ELSE
          x_fin_plan_type_id := approved_revenue_rec.fin_plan_type_id;
        END IF;
        CLOSE approved_revenue_csr;
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_SHORTCUTS_PKG',
                            p_procedure_name => 'GET_APP_BUDGET_PT_ID',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END get_app_budget_pt_id;

/* This API identifies the FORECAST budget plan type based on the shortcut
   option selected in the Project Home. If the plan type does not exist, then
   the URL will be returned with appropriate information. */
PROCEDURE get_fcst_plan_type_id(
                     p_project_id IN pa_projects_all.project_id%TYPE,
                     p_version_type IN pa_budget_versions.version_type%TYPE,
                     p_context IN VARCHAR2,
                     p_function_code IN VARCHAR2 DEFAULT NULL,
                     x_fin_plan_type_id OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
                     x_redirect_url OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data      OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

CURSOR primary_budget_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        (pt.primary_cost_forecast_flag = 'Y' OR
         pt.primary_rev_forecast_flag = 'Y');

primary_budget_rec primary_budget_csr%ROWTYPE;


CURSOR primary_cost_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        po.fin_plan_preference_code <> 'REVENUE_ONLY' AND
        pt.primary_cost_forecast_flag = 'Y';

primary_cost_rec primary_cost_csr%ROWTYPE;

CURSOR primary_revenue_csr IS
SELECT pt.fin_plan_type_id,
       po.fin_plan_preference_code
  FROM pa_proj_fp_options po,
       pa_fin_plan_types_b pt
  WHERE po.project_id = p_project_id AND
        po.fin_plan_option_level_code = 'PLAN_TYPE' AND
        po.fin_plan_type_id = pt.fin_plan_type_id AND
        po.fin_plan_preference_code <> 'COST_ONLY' AND
        pt.primary_rev_forecast_flag = 'Y';

primary_revenue_rec primary_revenue_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_FP_SHORTCUTS_PKG.get_fcst_plan_type_id');
      pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for primary forecast plan type',
                       x_log_level => 3);
   END IF;
   OPEN primary_budget_csr;
   FETCH primary_budget_csr INTO primary_budget_rec;
   IF primary_budget_csr%NOTFOUND THEN
       IF p_function_code = 'PJI_VIEW_FCST_TASK_SUMMARY' THEN
           NULL;
            IF p_pa_debug_mode = 'Y' THEN
                   PA_DEBUG.Reset_Err_stack;
            END IF;
            RETURN;
       ELSE
        /* setting url for Budgets and Forecasts page */
        x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                        || '&paProjectId=' || p_project_id
                          || '&pMsg=PA_FP_NO_FCST_PLAN_TYPE';

        IF p_context IS NOT NULL THEN
           x_redirect_url := x_redirect_url ||'&pContext='||p_context;
        END IF;
        CLOSE primary_budget_csr;
        IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
        END IF;
        RETURN;
       END IF;
   END IF;
   CLOSE primary_budget_csr;
   IF p_version_type = 'COST' THEN
        -- COST BUDGET
        -- Validate: primary Budget Plan type allows for cost numbers
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for primary cost forecast',
                       x_log_level => 3);
        END IF;
        OPEN primary_cost_csr;
        FETCH primary_cost_csr INTO primary_cost_rec;
        IF primary_cost_csr%NOTFOUND THEN
          /* setting url for Budgets and Forecasts page */
          x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                          || '&paProjectId=' || p_project_id
                            || '&pMsg=PA_FP_REV_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
        ELSE
          x_fin_plan_type_id := primary_cost_rec.fin_plan_type_id;
        END IF;
        CLOSE primary_cost_csr;
      ELSIF p_version_type = 'REVENUE' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write(  x_module => l_module,
                       x_msg => 'checking for primary revenue forecast',
                       x_log_level => 3);
        END IF;
        OPEN primary_revenue_csr;
        FETCH primary_revenue_csr INTO primary_revenue_rec;
        IF primary_revenue_csr%NOTFOUND THEN
          /* setting url for Budgets and Forecasts page */
          x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                          || '&paProjectId=' || p_project_id
                            || '&pMsg=PA_FP_COST_ONLY_PT';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
          CLOSE primary_revenue_csr;
          IF p_pa_debug_mode = 'Y' THEN
               PA_DEBUG.Reset_Err_stack;
          END IF;
          RETURN;
        ELSE
          x_fin_plan_type_id := primary_revenue_rec.fin_plan_type_id;
        END IF;
        CLOSE primary_revenue_csr;
      END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_SHORTCUTS_PKG',
                            p_procedure_name => 'GET_FCST_PLAN_TYPE_ID',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END get_fcst_plan_type_id;

/* This API returns the current working budget version id for the given plan type.
   If there is no current workgin version available, then URL will be set with the
   error message and appropriate page information. If the CW version is available, but
   if the version is either locked or in submitted status, then the URL will be set
   for Budgeting and Forecasting page with appropriate error message. */

PROCEDURE get_cw_version(   p_project_id IN pa_projects_all.project_id%TYPE,
                            p_plan_class_code      in  pa_fin_plan_types_b.plan_class_Code%type,
                            p_version_type         IN  pa_budget_versions.version_type%TYPE,
                            p_fin_plan_type_id     in  pa_fin_plan_types_b.fin_plan_type_id%TYPE,
                            p_edit_in_excel_Flag   IN  varchar2,
                            p_user_id              in  number,
                            p_context              IN  VARCHAR2,
                            x_budget_version_id    OUT NOCOPY pa_budget_versions.budget_version_id%type, --File.Sql.39 bug 4440895
                            x_redirect_url         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_request_id           OUT NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
                            x_plan_processing_code OUT NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
                            x_proj_fp_option_id    OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
                            x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_msg_data             OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
   l_locked_by_person_id pa_budget_versions.locked_by_person_id%type;
   l_budget_status_code pa_budget_versions.budget_status_code%type;
   l_rec_ver_number  pa_budget_versions.record_version_number%type;
   l_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%type;
   l_person_id                 NUMBER;
   l_resource_id               NUMBER;
   l_resource_name             VARCHAR2(200);
   l_webadi_enabled_flag VARCHAR2(30);
   l_msg_code varchar2(30);
   l_fp_opt_id pa_proj_fp_options.proj_fp_options_id%type;
   /* l_process_wbs_flag      pa_budget_versions.process_update_wbs_flag%TYPE; * 3604167 */
   l_editable_flag VARCHAR2(1) := 'Y';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_webadi_enabled_flag := nvl(FND_PROFILE.value('PA_FP_WEBADI_ENABLE'), 'N');

   SAVEPOINT lock_cw_version_PH;

   SELECT fin_plan_preference_code,
   proj_fp_options_id
   INTO l_fin_plan_preference_code,l_fp_opt_id
   FROM pa_proj_fp_options
   WHERE
   project_id = p_project_id AND
   fin_plan_option_level_code = 'PLAN_TYPE' AND
   fin_plan_type_id = p_fin_plan_type_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.init_err_stack('PA_FP_SHORTCUTS_PKG.get_cw_version');
      pa_debug.write(  x_module => l_module,
                       x_msg => 'selecting the CW version',
                       x_log_level => 3);
   END IF;

   x_proj_fp_option_id := l_fp_opt_id;

   BEGIN
      Select bv.budget_Version_id,
      bv.locked_by_person_id,bv.budget_status_code,record_version_number,bv.request_id,bv.plan_processing_code
      -- nvl(bv.process_update_wbs_flag,'N')
      INTO x_budget_version_id,
      l_locked_by_person_id,
      l_budget_status_code,
      l_rec_ver_number,
      x_request_id,
      x_plan_processing_code
      -- l_process_wbs_flag
      FROM pa_budget_versions bv
      WHERE project_id = p_project_id AND
      fin_plan_type_id = p_fin_plan_type_id AND
      current_working_Flag ='Y'  AND
      version_type IN (p_version_type,'ALL');
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write(  x_module => l_module,
                       x_msg => 'no CW version',
                       x_log_level => 3);
       END IF;
       IF p_version_type = 'COST' THEN
          IF l_fin_plan_preference_code IN ( 'COST_ONLY',
                                          'COST_AND_REV_SEP' ) THEN
             l_msg_code := 'PA_FP_NO_CW_VER_COST';
          ELSIF l_fin_plan_preference_code = 'COST_AND_REV_SAME' THEN
             l_msg_code := 'PA_FP_NO_CW_VER_ALL';
          END IF;
       END IF;
       IF p_version_type = 'REVENUE' THEN
          IF l_fin_plan_preference_code IN ( 'REVENUE_ONLY',
                                          'COST_AND_REV_SEP' ) THEN
             l_msg_code := 'PA_FP_NO_CW_VER_REV';
          ELSIF l_fin_plan_preference_code = 'COST_AND_REV_SAME' THEN
             l_msg_code := 'PA_FP_NO_CW_VER_ALL';
          END IF;
       END IF;
          /* setting url for Create Version page */
          x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_CV_LAYOUT&akRegionApplicationId=275'
                            || '&paFinPlanTypeId=' || p_fin_plan_type_id
                            || '&pMsg='||l_msg_Code
                            || '&paFinPlanOptionsId='||l_fp_opt_id;

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF l_fin_plan_preference_code = 'COST_AND_REV_SEP' THEN
            x_redirect_url := x_redirect_url ||'&paCostOrRev='||
                              initcap(p_version_type);
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
   END;

   IF l_budget_Status_code = 'S' THEN
      /* setting url for Budgets and Forecasts page */
      x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
--                      || '&paProjectId=' || p_project_id
                        || '&pMsg=PA_FP_VERSION_SUBMITTED';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
      RETURN;
   END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write(  x_module => l_module,
                       x_msg => 'calling Pa_fin_plan_utils.Check_if_plan_type_editable',
                       x_log_level => 3);
   END IF;

   PA_FIN_PLAN_UTILS.CHECK_IF_PLAN_TYPE_EDITABLE
            ( P_project_id   => p_project_id,
              P_fin_plan_type_id   => p_fin_plan_type_id,
              P_version_type    => p_version_type,
              X_editable_flag    => l_editable_flag,
              X_return_status   => x_return_status,
              X_msg_count      => x_msg_count,
              X_msg_data        => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      END IF;

      IF l_editable_flag = 'N' THEN
      /* setting url for Budgets and Forecasts page */
      x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                       || '&pMsg=PA_FP_PLAN_TYPE_NON_EDITABLE';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
      RETURN;
      END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write(  x_module => l_module,
                       x_msg => 'calling PA_COMP_PROFILE_PUB.get_user_info api for person id',
                       x_log_level => 3);
   END IF;
   PA_COMP_PROFILE_PUB.GET_USER_INFO
          (p_user_id         => p_user_id,
           x_person_id       => l_person_id,
           x_resource_id     => l_resource_id,
           x_resource_name   => l_resource_name);

   IF l_locked_by_person_id IS NOT NULL  AND
      l_locked_by_person_id <> l_person_id THEN

      /* Bug fix 3079388: if locked for processing, go to Edit Plan page,
         where it will be caught.
       NOTE: use locked_by_person_id=-98 instead of update_wbs_flag=Y so that this
       will catch ALL concurrent process in progress scenarios */
      if l_locked_by_person_id = -98 then
      /* setting url for Edit Plan page */
      x_redirect_url := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpEditPlanPG'
                     || '&paBvId=' || x_budget_version_id
                     || '&paContextLevel=VERSION'
                     || '&pMsg=-1';

        IF p_context IS NOT NULL THEN
           x_redirect_url := x_redirect_url ||'&pContext='||p_context;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Err_stack;
        END IF;
        RETURN;
      else
        /* setting url for Budgets and Forecasts page */
        x_redirect_url := 'OA.jsp?akRegionCode=PA_FIN_PLAN_LAYOUT&akRegionApplicationId=275'
                           || '&pMsg=PA_FP_VERSION_LOCKED_BY_USER';

           IF p_context IS NOT NULL THEN
              x_redirect_url := x_redirect_url ||'&pContext='||p_context;
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Err_stack;
           END IF;
        RETURN;
      end if;
   END IF;

   IF l_locked_by_person_id IS NULL THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write(  x_module => l_module,
                       x_msg => 'calling pa_fin_plan_pvt.lock_unlock_version api',
                       x_log_level => 3);
      END IF;
      pa_fin_plan_pvt.lock_unlock_version
                  (p_budget_version_id     => x_budget_version_id,
                   p_record_version_number => l_rec_Ver_number,
                   p_action                => 'L',
                   p_user_id               => p_user_id,
                   p_person_id             => l_person_id,
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write(  x_module => l_module,
                       x_msg => 'version locked successfully.',
                       x_log_level => 3);
      END IF;
   END IF;


   IF  p_edit_in_excel_flag='Y' THEN
       IF l_webadi_enabled_flag='Y' THEN
        -- FP L build 2: WBS UPDATE VALIDATION CHECK: If undergoing WBS validation,
        -- simply redirect to Edit Plan page
        /* IF l_process_wbs_flag = 'Y' THEN
            ** x_redirect_url = EDIT PLAN
            x_redirect_url := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpEditPlanPG'||
                          '&paBvId=' || x_budget_version_id
                                || '&paContextLevel=VERSION'
                          || '&pMsg=-1'; ** 2979654: use -1 to eliminate URL persistence
                IF p_context IS NOT NULL THEN ** Bug 3079328 **
                   x_redirect_url := x_redirect_url ||'&pContext='||p_context;
                END IF;

        ELSE ** 3604167 */
            x_redirect_url := 'WEBADI';
            IF p_pa_debug_mode = 'Y' THEN
                    PA_DEBUG.Reset_Err_stack;
            END IF;
        -- END IF;
          RETURN;
       ELSE
           /* setting url for Edit Plan page */
           x_redirect_url := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpEditPlanPG'
                                  ||'&paBvId=' || x_budget_version_id
                                  || '&paContextLevel=VERSION'
                                  || '&pMsg=PA_FP_WEBADI_NOT_ENABLED';

         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
          IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
          END IF;
          RETURN;
       END IF;
   ELSE
          /* setting url for Edit Plan page */
          x_redirect_url := 'OA.jsp?page=/oracle/apps/pa/finplan/webui/FpEditPlanPG'||
                                  '&paBvId=' || x_budget_version_id
                                  || '&paContextLevel=VERSION'
                                  || '&pMsg=-1';
                              -- 2979654: use -1 to eliminate URL persistence
         IF p_context IS NOT NULL THEN
            x_redirect_url := x_redirect_url ||'&pContext='||p_context;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Err_stack;
         END IF;
         RETURN;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO lock_cw_version_PH;
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_FP_SHORTCUTS_PKG',
                            p_procedure_name => 'GET_CW_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);



END get_cw_version;


END pa_fp_shortcuts_pkg;

/
