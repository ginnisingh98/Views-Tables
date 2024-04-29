--------------------------------------------------------
--  DDL for Package Body PA_FP_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_WEBADI_UTILS" as
/* $Header: PAFPWAUB.pls 120.14.12010000.2 2008/08/26 23:31:31 jngeorge ship $*/
/***************************************************************/
/*This procedure is called to return the layout code based on  */
/* p_budget_version_id. */
/***************************************************************/

G_BUDGET_VERSION_ID pa_budget_versions.budget_version_id%TYPE := -99  ;
G_TABLE_POPULATED  VARCHAR2(1) := 'N' ;
G_TXN_CURRENCY_CODE_TBL PA_FP_WEBADI_PKG.l_txn_currency_code_tbl_typ ;


g_module_name VARCHAR2(30) := 'pa.plsql.PA_FP_WEBADI_UTILS';

l_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_metadata_info(
                  p_budget_version_id    IN      NUMBER,
                  x_content_code         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_mapping_code         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_layout_code          OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_integrator_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_rej_lines_exist      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_submit_budget        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_submit_forecast      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_msg_code         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_msg_data             OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_plan_pref_code                pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_time_phased_code              pa_proj_fp_options.cost_time_phased_code%TYPE;
l_fin_plan_level_code           pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_uncategorized_flag            pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
l_group_resource_type_id        pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
l_fin_plan_type_id              pa_proj_fp_options.fin_plan_type_id%TYPE;
l_project_id                    pa_proj_fp_options.project_id%TYPE;
l_cost_layout_code              pa_proj_fp_options.cost_layout_code%TYPE;
l_revenue_layout_code           pa_proj_fp_options.revenue_layout_code%TYPE;
l_all_layout_code               pa_proj_fp_options.all_layout_code%TYPE;
l_plan_class_code               pa_fin_plan_types_b.plan_class_code%TYPE;
l_cost_time_phased_code         pa_proj_fp_options.cost_time_phased_Code%TYPE;
l_revenue_time_phased_Code      pa_proj_fp_options.revenue_time_phased_Code%TYPE;
l_all_time_phased_Code          pa_proj_fp_options.all_time_phased_Code%TYPE;
l_integrator_code               bne_layouts_b.integrator_code%TYPE;
l_cost_period_mask_id           pa_proj_fp_options.cost_period_mask_id%TYPE;
l_revenue_period_mask_id        pa_proj_fp_options.rev_period_mask_id%TYPE;
l_all_period_mask_id            pa_proj_fp_options.all_period_mask_id%TYPE;
l_no_of_periods                 NUMBER;
l_current_working_flag          pa_budget_versions.current_working_flag%TYPE;
l_layout_meaning                bne_layouts_vl.user_name%TYPE;
l_plan_class_name               pa_lookups.meaning%TYPE;
l_layout_code                   VARCHAR2(300);

/* Added variables for debug messages/error. */
l_msg_count              NUMBER := 0;
l_data                   VARCHAR2(2000);
l_msg_data               VARCHAR2(2000);
l_msg_index_out          NUMBER;
l_debug_mode             VARCHAR2(30);
l_module_name            VARCHAR2(200) :=  g_module_name || '.get_metadata_info';
l_debug_level3                    CONSTANT NUMBER :=3;
l_debug_level5                    CONSTANT NUMBER :=5;



BEGIN

   -- 4497318.Perf Fix: The View name pa_resource_lists is reolaced by Table name pa_resource_lists_all_bg in the FROM clause.
    SELECT a.GROUP_RESOURCE_TYPE_ID,a.UNCATEGORIZED_FLAG,b.current_working_flag
    INTO   l_group_resource_type_id,l_uncategorized_flag,l_current_working_flag
    FROM   pa_resource_lists_all_bg a, pa_budget_versions b
    WHERE  b.budget_version_id = p_budget_version_id
    AND    a.RESOURCE_LIST_ID = b.resource_list_id;

    SELECT FIN_PLAN_PREFERENCE_CODE
           ,fin_plan_type_id
           ,project_id
           ,cost_time_phased_code
           ,revenue_time_phased_code
           ,all_time_phased_code
           ,cost_period_mask_id
           ,rev_period_mask_id
           ,all_period_mask_id
    INTO   l_plan_pref_code
           ,l_fin_plan_type_id
           ,l_project_id
           ,l_cost_time_phased_code
           ,l_revenue_time_phased_code
           ,l_all_time_phased_code
           ,l_cost_period_mask_id
           ,l_revenue_period_mask_id
           ,l_all_period_mask_id
    FROM pa_proj_fp_options
    WHERE fin_plan_version_id = p_budget_version_id
    AND FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_VERSION';

    SELECT pfo.cost_layout_code
           ,pfo.revenue_layout_code
           ,pfo.all_layout_code
           ,ptb.plan_class_code
    INTO   l_cost_layout_code
           ,l_revenue_layout_code
           ,l_all_layout_code
           ,l_plan_class_code
    FROM pa_proj_fp_options pfo
        ,pa_fin_plan_types_b ptb
    WHERE pfo.fin_plan_type_id = l_fin_plan_type_id
    AND   pfo.FIN_PLAN_version_id IS NULL
    AND   pfo.fin_plan_type_id = ptb.fin_plan_type_id
    AND   pfo.project_id = l_project_id;



l_fin_plan_level_code   := pa_fin_plan_utils.Get_Fin_Plan_Level_Code(
                               p_fin_plan_version_id => p_budget_version_id);
l_time_phased_code      := pa_fin_plan_utils.get_time_phased_code(
                               p_fin_plan_version_id => p_budget_version_id);

x_rej_lines_exist := 'N';

x_submit_budget   := 'false';
x_submit_forecast := 'false';

    IF l_current_working_flag ='Y' AND l_plan_class_code='BUDGET' THEN
        x_submit_budget := 'true';
    END IF;
    IF l_current_working_flag ='Y' AND l_plan_class_code='FORECAST' THEN
        x_submit_forecast := 'true';
    END IF;


    IF l_plan_pref_code = 'COST_ONLY' THEN
       x_layout_code := l_cost_layout_code;
    ELSIF l_plan_pref_code = 'REVENUE_ONLY' THEN
        x_layout_code := l_revenue_layout_code;
    ELSIF l_plan_pref_code = 'COST_AND_REV_SAME' THEN
        x_layout_code := l_all_layout_code;
    END IF;


/* Calling the Client Extension to get the Custom Layout, if being passed
   by the user. */

   l_layout_code := x_layout_code;

   pa_client_extn_budget.Get_Custom_Layout_Code(
                      p_budget_version_id  => p_budget_version_id
                    , p_layout_code_in     => l_layout_code
                    , x_layout_code_out    => x_layout_code
                    , x_return_status      => x_return_status
                    , x_msg_count          => x_msg_count
                    , x_msg_data           => x_msg_data);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
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
         x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


    IF (l_plan_pref_code = 'COST_ONLY'      AND x_layout_code IS NULL ) OR
       (l_plan_pref_code = 'REVENUE_ONLY'   AND x_layout_code IS NULL ) OR
       (l_plan_pref_code = 'COST_AND_REV_SAME' AND x_layout_code IS NULL) THEN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_err_msg_code :=  'PA_FP_WEBADI_OLD_LAYOUT';
        RETURN;
    END IF;


--Checking if the custom layout code maps to one of the layout codes present
-- in the system.

    BEGIN
        SELECT integrator_code
        INTO l_integrator_code
        FROM bne_layouts_b
        WHERE layout_code = x_layout_code
        and application_id = (SELECT application_id
        FROM FND_APPLICATION
        WHERE APPLICATION_SHORT_NAME = 'PA');



    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='The custom layout code is not present the system.';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_err_msg_code :=  'PA_FP_WEBADI_OLD_LAYOUT';
        RETURN;
    END;



    IF ((l_plan_class_code = 'BUDGET'
    AND l_integrator_code NOT IN ('FINPLAN_BUDGET_PERIODIC' , 'FINPLAN_BUDGET_NON_PERIODIC' ))
    OR (l_plan_class_code = 'FORECAST'
    AND l_integrator_code NOT IN ('FINPLAN_FORECAST_PERIODIC' , 'FINPLAN_FORECAST_NON_PERIODIC' ))) THEN

        SELECT user_name
        INTO l_layout_meaning
        FROM bne_layouts_tl
        WHERE layout_code = x_layout_code
        AND language = userenv('lang')
        AND application_id = (SELECT application_id
        FROM FND_APPLICATION
        WHERE APPLICATION_SHORT_NAME = 'PA');

        SELECT meaning
        INTO l_plan_class_name
        FROM pa_lookups
        WHERE lookup_type = 'FIN_PLAN_CLASS'
        AND Lookup_code = l_plan_class_code;

        IF l_plan_class_code = 'BUDGET' THEN

            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_err_msg_code :=  'PA_FP_WEBADI_INCRT_BDGT_LAYOUT';
            RETURN;

        ELSIF l_plan_class_code = 'FORECAST' THEN

            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_err_msg_code :=  'PA_FP_WEBADI_INCRT_FCST_LAYOUT';
            RETURN;

        END IF;
    END IF;



    IF l_plan_class_code = 'BUDGET' THEN

        IF l_integrator_code = 'FINPLAN_BUDGET_PERIODIC' THEN
            x_integrator_code :=  'FINPLAN_BUDGET_PERIODIC';
            x_content_code    :=  'PA_FP_P_BUDGET_CNT';
            x_mapping_code    :=  'PA_FP_PBUD_MAP';
        ELSIF l_integrator_code = 'FINPLAN_BUDGET_NON_PERIODIC' THEN
            x_integrator_code :=  'FINPLAN_BUDGET_NON_PERIODIC';
            x_content_code    :=  'PA_FP_NP_BUDGET_CNT';
            x_mapping_code    :=  'PA_FP_NPBUD_MAP';
        END IF;
    ELSIF l_plan_class_code = 'FORECAST' THEN

        IF l_integrator_code = 'FINPLAN_FORECAST_PERIODIC' THEN
            x_integrator_code :=  'FINPLAN_FORECAST_PERIODIC';
            x_content_code    :=  'PA_FP_P_FORECAST_CNT';
            x_mapping_code    :=  'PA_FP_PFC_MAP';

        ELSIF l_integrator_code = 'FINPLAN_FORECAST_NON_PERIODIC' THEN
            x_integrator_code :=  'FINPLAN_FORECAST_NON_PERIODIC';
            x_content_code    :=  'PA_FP_NP_FORECAST_CNT';
            x_mapping_code    :=  'PA_FP_NPFC_MAP';
        END IF;
    END IF;


    IF (l_plan_pref_code = 'COST_ONLY' AND l_cost_time_phased_code = 'N'
         AND l_integrator_code IN ('FINPLAN_BUDGET_PERIODIC','FINPLAN_FORECAST_PERIODIC')) OR
       (l_plan_pref_code = 'REVENUE_ONLY'  AND l_revenue_time_phased_code = 'N'
         AND l_integrator_code IN ('FINPLAN_BUDGET_PERIODIC','FINPLAN_FORECAST_PERIODIC')) OR
       (l_plan_pref_code = 'COST_AND_REV_SAME' AND l_all_time_phased_code= 'N'
         AND l_integrator_code IN ('FINPLAN_BUDGET_PERIODIC','FINPLAN_FORECAST_PERIODIC')) THEN

            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_err_msg_code  :=  'PA_FP_WEBADI_PER_LAYOUT';
            RETURN;
    END IF;

    IF l_plan_pref_code = 'COST_ONLY' THEN

        SELECT COUNT(*)
        INTO l_no_of_periods
        FROM pa_period_mask_details
        WHERE period_mask_id = l_cost_period_mask_id
        AND from_anchor_position not in (99999,-99999);
    ELSIF l_plan_pref_code = 'REVENUE_ONLY' THEN

        SELECT COUNT(*)
        INTO l_no_of_periods
        FROM pa_period_mask_details
        WHERE period_mask_id = l_revenue_period_mask_id
        AND from_anchor_position not in (99999,-99999);
    ELSIF l_plan_pref_code = 'COST_AND_REV_SAME' THEN

        SELECT COUNT(*)
        INTO l_no_of_periods
        FROM pa_period_mask_details
        WHERE period_mask_id = l_all_period_mask_id
        AND from_anchor_position not in (99999,-99999);
    END IF;

    IF l_no_of_periods > 52 THEN

        IF l_plan_class_code = 'BUDGET' THEN

            x_layout_code     :=   'NPE_BUDGET';
            x_integrator_code :=   'FINPLAN_BUDGET_NON_PERIODIC';
            x_content_code    :=   'PA_FP_NP_BUDGET_CNT';
            x_mapping_code    :=   'PA_FP_NPBUD_MAP';

        ELSIF l_plan_class_code = 'FORECAST' THEN
            x_layout_code     :=  'NPE_FORECAST';  --Need to check the layout that has to be coded for forecast.
            x_integrator_code :=  'FINPLAN_FORECAST_NON_PERIODIC';
            x_content_code    :=  'PA_FP_NP_FORECAST_CNT';
            x_mapping_code    :=  'PA_FP_NPFC_MAP';
        END IF;
    END IF;

    x_rej_lines_exist := pa_fin_plan_utils.does_bv_have_rej_lines(p_budget_version_id);

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
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
       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

       END IF;
       -- reset curr function
       pa_debug.reset_curr_function();
       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_webadi_utils'
                               ,p_procedure_name  => 'get_metadata_info');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       END IF;
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       RAISE;

END get_metadata_info;


PROCEDURE validate_before_launch(p_budget_version_id    IN   NUMBER,
                    x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS

l_budget_version_id     NUMBER;
l_res_asg_id            NUMBER;
l_project_id            NUMBER;
l_task_id               NUMBER;
l_period_profile_id     NUMBER;
l_time_phased_code      pa_proj_fp_options.cost_time_phased_code%TYPE;
l_fin_plan_level_code   pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_project_start_date        DATE;
l_project_end_date      DATE;
k                       NUMBER;
m                       NUMBER;
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

v_task_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
v_task_end_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;

-- 4497315.Perf Fix.SELECT query is changed.
CURSOR C1(l_budget_version_id number) IS
SELECT pt.start_date,pt.completion_date
 FROM pa_resource_assignments pra,
      pa_budget_versions pbv,
      pa_tasks pt
 WHERE pra.budget_version_id = pbv.budget_version_id
   AND pbv.budget_version_id = l_budget_version_id
   AND pt.task_id = pra.task_id
   AND pra.project_id = pbv.project_id
   AND pbv.project_id = pt.task_id;

BEGIN

l_budget_version_id     := p_budget_version_id;
l_fin_plan_level_code   := pa_fin_plan_utils.Get_Fin_Plan_Level_Code(
                               p_fin_plan_version_id => l_budget_version_id);
l_time_phased_code  := pa_fin_plan_utils.get_time_phased_code(
                               p_fin_plan_version_id => l_budget_version_id);
      SELECT  period_profile_id
              ,project_id
      INTO l_period_profile_id
          ,l_project_id
      FROM pa_budget_versions
     WHERE budget_version_id = l_budget_version_id;

      SELECT start_date
             ,completion_date
        INTO  l_project_start_date
             ,l_project_end_date
        FROM  pa_projects_all p
        WHERE p.project_id = l_project_id;


        IF l_time_phased_code IN(PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G) THEN

           IF l_period_profile_id IS NULL THEN
            --  pa_debug.g_err_stage := 'period_profile_id is null when time phasing is PA or GL ';
            --  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                   p_msg_name            => 'PA_FP_PERIODPROFILE_UNDEFINED');
              raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

        ELSE /* if time phasing is none then */

           IF l_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N THEN
              IF l_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN
                 IF l_project_start_date IS NULL or l_project_end_date IS NULL THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                         p_msg_name            => 'PA_BU_NO_TASK_PROJ_DATE');
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
              ELSE
                OPEN C1(l_budget_version_id);
        k :=0;
                Loop
                fetch C1 into v_task_start_date_tab(k),v_task_end_date_tab(k);
                k := k+1;
        EXIT WHEN C1%NOTFOUND;

            END LOOP; --End k Loop

        CLOSE C1;

        FOR m in v_task_start_date_tab.first..v_task_start_date_tab.last LOOP

                 IF v_task_start_date_tab(m) IS NULL or v_task_end_date_tab(m) IS NULL THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                         p_msg_name            => 'PA_BU_NO_TASK_PROJ_DATE');
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                END LOOP; /* for loop*/

              END IF;
           END IF;
        END IF;

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



END;

procedure convert_task_num_to_id
            (p_project_id   IN  NUMBER,
             p_task_num     IN  VARCHAR2,
         x_task_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_msg_data         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF p_task_num is not NULL then

        BEGIN

          select task_id
            into x_task_id
            from pa_tasks
           where project_id = p_project_id
             and task_number = p_task_num;

        EXCEPTION
          When NO_DATA_FOUND THEN

          x_return_status :=  FND_API.G_RET_STS_ERROR;

        END;

       ELSE x_task_id := 0;

       END IF;

END;

procedure validate_currency_code
        (p_budget_version_id    IN  NUMBER,
         p_currency_code        IN  VARCHAR2,
                 x_return_status    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data         OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_multi_curr_flag   VARCHAR2(1);
l_txn_currency_id   NUMBER;
l_proj_fp_options_id NUMBER;

BEGIN

          select fp.PLAN_IN_MULTI_CURR_FLAG,
                 fp.proj_fp_options_id
            into l_multi_curr_flag,
                 l_proj_fp_options_id
            from pa_proj_fp_options fp, pa_budget_versions bv
           where bv.budget_version_id = p_budget_version_id
             and fp.fin_plan_version_id = p_budget_version_id
             and fp.fin_plan_type_id = bv.fin_plan_type_id
             and fp.fin_plan_option_level_code = 'PLAN_VERSION'
             and fp.project_id = bv.project_id;

          if l_multi_curr_flag = 'Y' then
           begin
         select fp_txn_currency_id
             into   l_txn_currency_id
             from   pa_fp_txn_currencies
             where  proj_fp_options_id  = l_proj_fp_options_id  --Sql Performance to avoid FTS fix sql id 16509328
               and  txn_currency_code = p_currency_code;
       exception
        When NO_DATA_FOUND THEN
                x_return_status :=  FND_API.G_RET_STS_ERROR;

           end;

      end if;

END;

procedure validate_resource_info
        (p_budget_version_id         IN  NUMBER,
         p_resource_group_name       IN  VARCHAR2,
         p_resource_alias            IN  VARCHAR2,
           x_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_resource_gp_flag        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_resource_alias_flag       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_return_status             OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895


IS

l_resource_list_id       NUMBER;
l_budget_line_id         NUMBER;
ll_budget_line_id        NUMBER;
l_budget_version_id      NUMBER;
l_rlm_id_gp              NUMBER;
l_rlm_id_alias           NUMBER;
l_project_id             NUMBER;
l_fin_plan_level_code    pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_plan_pref_code         pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_uncategorized_flag     pa_resource_lists.UNCATEGORIZED_FLAG%TYPE;
l_group_resource_type_id pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE;
l_row_id                 ROWID;
ll_error_flag            VARCHAR2(1);
l_track_as_labor_flag    PA_RESOURCE_LIST_MEMBERS.TRACK_AS_LABOR_FLAG%TYPE;
l_dummy_res_list_id      NUMBER;
l_unit_of_measure        PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE;
l_dummy_id               NUMBER;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(240);

BEGIN



    Select resource_list_id, project_id
    into   l_resource_list_id,l_project_id
    from   pa_budget_versions
        where  budget_version_id = p_budget_version_id;

         -- 4497318.Perf Fix.The View name pa_resource_lists is replaced by Table name pa_resource_lists_all_bg in the FROM clause.
        SELECT GROUP_RESOURCE_TYPE_ID,UNCATEGORIZED_FLAG
        INTO   l_group_resource_type_id,l_uncategorized_flag
        FROM   pa_resource_lists_all_bg
        WHERE  RESOURCE_LIST_ID = l_resource_list_id;

    If l_uncategorized_flag <> 'Y' Then
-- check if plan by resource or by non-resource
   --  dbms_output.put_line('Planning by resource....');

     If l_group_resource_type_id > 0 Then

--check if plan by resource group or by resource-only

--Resource Group
--dbms_output.put_line('Planning by resource group...');
    Begin

      Select resource_list_member_id
      into l_rlm_id_gp
      from pa_resource_list_members
      where resource_list_id = l_resource_list_id
      and parent_member_id is NULL
      and alias = p_resource_group_name;

    Exception
      When NO_DATA_FOUND THEN

          x_resource_gp_flag := 'Y';
          x_return_status    := FND_API.G_RET_STS_ERROR;

          return;

    End;

    -- 4497318.Perf Fix.An AND condition is added in the WHERE clause.
    SELECT count(*)
    INTO   l_dummy_id
    FROM   pa_resource_list_members
    WHERE  resource_list_id = l_resource_list_id
    AND    parent_member_id = l_rlm_id_gp
    AND    rownum=1;

    if l_dummy_id = 0 then
--Plan by Resource Group only
           x_resource_list_member_id := l_rlm_id_gp;

        else
--Plan by Resource Group and Resource alias

    Begin

      Select resource_list_member_id
      into l_rlm_id_alias
      from pa_resource_list_members
      where resource_list_id = l_resource_list_id
      and parent_member_id = l_rlm_id_gp
          and alias = p_resource_alias;

    Exception
      When NO_DATA_FOUND THEN
          x_resource_alias_flag := 'Y';
          x_return_status    := FND_API.G_RET_STS_ERROR;
          return;
        End;

          x_resource_list_member_id := l_rlm_id_alias;

        end if; --end if dummy_id = 0

    Else
--dbms_output.put_line('Planning by resource only.....');
--Resource alias only
    Begin

      Select resource_list_member_id
          into l_rlm_id_alias
          from pa_resource_list_members
      where resource_list_id = l_resource_list_id
       and alias = p_resource_alias;

    Exception
      When NO_DATA_FOUND THEN
          x_resource_alias_flag := 'Y';
          x_return_status    := FND_API.G_RET_STS_ERROR;
          return;
    End;

     END IF; --End if l_group_resource_type_id>0

   ELSE  -- if l_uncategorized <> 'Y'

 PA_FIN_PLAN_UTILS.Get_Uncat_Resource_List_Info
         (x_resource_list_id        => l_dummy_res_list_id
         ,x_resource_list_member_id => l_rlm_id_alias
         ,x_track_as_labor_flag     => l_track_as_labor_flag
         ,x_unit_of_measure         => l_unit_of_measure
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data);

--l_rlm_id_alias := 1000;

   END IF; -- End if l_uncategorized <> 'Y'

   x_resource_list_member_id := l_rlm_id_alias;


END;

PROCEDURE GET_RES_ASSIGNMENT_INFO
                  (p_resource_assignment_id IN  pa_resource_assignments.resource_assignment_id%TYPE
                  ,p_planning_level         IN  pa_proj_fp_options.cost_fin_plan_level_code%TYPE
                  ,x_task_number            OUT NOCOPY pa_tasks.task_number%TYPE --File.Sql.39 bug 4440895
                  ,x_task_id                OUT NOCOPY pa_tasks.task_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_alias         OUT NOCOPY pa_resource_list_members.alias%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_group_alias   OUT NOCOPY pa_resource_list_members.alias%TYPE --File.Sql.39 bug 4440895
                  ,x_parent_assignment_id   OUT NOCOPY pa_resource_assignments.parent_assignment_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_list_member_id OUT NOCOPY pa_resource_list_members.resource_list_member_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_id            OUT NOCOPY pa_resource_list_members.resource_id%TYPE --File.Sql.39 bug 4440895
                  ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_msg_data               OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

 l_debug_mode             VARCHAR2(10);
 l_msg_count              NUMBER ;
 l_data                   VARCHAR2(2000);
 l_msg_data               VARCHAR2(2000);
 l_msg_index_out          NUMBER;

 l_unit_of_measure        pa_resource_assignments.unit_of_measure%TYPE;

-- Cursor c_task_level_info selects the task_name,resource alias
-- and resource group alias for a resource assignment id .
-- This is fired when version planning level is not PROJECT

CURSOR c_task_level_info(c_resource_assignment_id IN NUMBER) IS
     SELECT  pt.task_number
            ,pt.task_id
            ,decode(prlm.parent_member_id,null,decode(prl.group_resource_type_id,0,rtrim(prlm.alias),null)
                                              ,rtrim(prlm.alias)) resource_alias -- Added rtrim for #2839138
            ,decode(prlm.parent_member_id,null,rtrim(prlm.alias),rtrim(prlm_parent.alias)) resource_group_alias
                                                                                 -- Added rtrim for #2839138
            ,pra.unit_of_measure
            ,pra.parent_assignment_id
            ,prlm.resource_list_member_id
            ,prlm.resource_id
       FROM  pa_tasks pt
            ,pa_resource_assignments pra
            ,pa_resource_list_members prlm
            ,pa_resource_list_members prlm_parent
            ,pa_resource_lists_all_bg prl
       WHERE pra.resource_assignment_id = c_resource_assignment_id
         AND pra.project_id = pt.project_id
         AND pra.task_id = pt.task_id
         AND prlm.resource_list_member_id = pra.resource_list_member_id
         AND prlm.parent_member_id = prlm_parent.resource_list_member_id(+)
         AND prl.resource_list_id = prlm.resource_list_id;

-- Cursor c_project_level_info selects the resource alias
-- and resource group alias for a resource assignment id .
-- This is fired when version planning level is PROJECT.

CURSOR c_project_level_info(c_resource_assignment_id IN NUMBER) IS
     SELECT decode(prlm.parent_member_id,null,decode(prl.group_resource_type_id,0,rtrim(prlm.alias),null)
                                             ,rtrim(prlm.alias)) resource_alias -- Added rtrim for #2839138
            ,decode(prlm.parent_member_id,null,rtrim(prlm.alias),rtrim(prlm_parent.alias)) resource_group_alias
                                                                                -- Added rtrim for #2839138
            ,pra.unit_of_measure
            ,pra.parent_assignment_id
            ,prlm.resource_list_member_id
            ,prlm.resource_id
       FROM  pa_resource_assignments pra
            ,pa_resource_list_members prlm
            ,pa_resource_list_members prlm_parent
            ,pa_resource_lists_all_bg prl
       WHERE pra.resource_assignment_id = c_resource_assignment_id
         AND prlm.resource_list_member_id = pra.resource_list_member_id
         AND prl.resource_list_id = prlm.resource_list_id
         AND prlm.parent_member_id = prlm_parent.resource_list_member_id(+);

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'GET_RES_ASSIGNMENT_INFO'
                                       ,p_debug_mode => l_debug_mode );
    END IF;

    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := ':In PA_FP_WEBADI_UTILS.GET_RES_ASSIGNMENT_INFO' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF ((p_resource_assignment_id IS NULL) OR (p_planning_level IS NULL)) THEN

    IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage :='Invalid input parameter';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA'
                        ,p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := 'PA_FP_WEBADI_UTILS.GET_RES_ASSIGNMENT_INFO';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF ;

    IF (p_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT) THEN

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'opening project level cursor';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
       END IF ;

       OPEN c_project_level_info(p_resource_assignment_id) ;
           FETCH c_project_level_info INTO
                 x_resource_alias
                ,x_resource_group_alias
                ,l_unit_of_measure
                ,x_parent_assignment_id
                ,x_resource_list_member_id
                ,x_resource_id;

        IF c_project_level_info%NOTFOUND THEN

          -- Indicates that the resource assignment id past
          -- to the API is invalid.
          x_return_status := FND_API.G_RET_STS_ERROR ;

        END IF ;
          -- 4346858.Cursor c_project_level_info is closed.
       CLOSE c_project_level_info;


    ELSE

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'opening task level cursor';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
       END IF ;

       OPEN c_task_level_info(p_resource_assignment_id) ;
           FETCH c_task_level_info INTO
                 x_task_number
                ,x_task_id
                ,x_resource_alias
                ,x_resource_group_alias
                ,l_unit_of_measure
                ,x_parent_assignment_id
                ,x_resource_list_member_id
                ,x_resource_id;

       IF c_task_level_info%NOTFOUND THEN
          -- Indicates that the resource assignment id past
          -- to the API is invalid.
          x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF ;
         -- 4346858.Cursor c_task_level_info is closed.
     CLOSE c_task_level_info;
    END IF ;

    pa_debug.reset_curr_function;

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

             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
      ELSE
              x_msg_count := l_msg_count;
      END IF;

      IF l_debug_mode = 'Y' THEN
         pa_debug.write('GET_RES_ASSIGNMENT_INFO: ' || g_module_name,'Invalid arguments passed',5);
         pa_debug.write('GET_RES_ASSIGNMENT_INFO: ' || g_module_name,pa_debug.G_Err_Stack,5);
         pa_debug.reset_curr_function;
      END IF;
      RETURN;
 WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
        ( p_pkg_name       => 'PA_FP_WEBADI_UTILS'
         ,p_procedure_name => 'GET_RES_ASSIGNMENT_INFO'
         ,p_error_text     => sqlerrm);


      IF l_debug_mode = 'Y' THEN
         pa_debug.G_Err_Stack := SQLERRM;
         pa_debug.write(g_module_name,pa_debug.G_Err_Stack,4);
         pa_debug.write(g_module_name,pa_debug.G_Err_Stage,4);
         pa_debug.reset_curr_function;

      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_RES_ASSIGNMENT_INFO ;

/* Bug 5350437: Commented the below API
PROCEDURE VALIDATE_CHANGE_REASON_CODE
                 (p_change_reason_code     IN  pa_budget_lines.change_reason_code%TYPE
                 ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data               OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_debug_mode             VARCHAR2(1);
  l_msg_count              NUMBER ;
  l_data                   VARCHAR2(2000);
  l_msg_data               VARCHAR2(2000);
  l_msg_index_out          NUMBER;
  l_exists                 VARCHAR2(1) ;
  l_lookup_code            PA_LOOKUPS.LOOKUP_CODE%TYPE;

  CURSOR c_code_exists_cur IS
      SELECT LOOKUP_CODE
        FROM PA_LOOKUPS
       WHERE LOOKUP_TYPE = 'BUDGET CHANGE REASON'
         AND LOOKUP_CODE = p_change_reason_code ;

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('PA_FP_WEBADI_UTILS.VALIDATE_CHANGE_REASON_CODE');
              pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

     IF p_change_reason_code IS NOT NULL THEN
        -- Open cursor c_code_exists_cur
           OPEN c_code_exists_cur ;

           FETCH c_code_exists_cur INTO l_lookup_code;

           IF  c_code_exists_cur%NOTFOUND THEN

                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'could not find change reason code';
                     pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

               x_return_status := FND_API.G_RET_STS_ERROR ;
           END IF ;

           IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Exiting VALIDATE_CHANGE_REASON_CODE';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                  pa_debug.reset_err_stack;
           END IF;
     END IF;

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

             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
      ELSE
              x_msg_count := l_msg_count;

      END IF;

      IF l_debug_mode = 'Y' THEN
         pa_debug.write('VALIDATE_CHANGE_REASON_CODE: ' || g_module_name,'Invalid arguments passed',5);
         pa_debug.write('VALIDATE_CHANGE_REASON_CODE: ' || g_module_name,pa_debug.G_Err_Stack,5);
      END IF;
      IF l_debug_mode = 'Y' THEN

          pa_debug.g_err_stage:= 'Exiting VALIDATE_CHANGE_REASON_CODE';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          pa_debug.reset_err_stack;

      END IF;
      RETURN;
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
        ( p_pkg_name       => 'PA_FP_WEBADI_UTILS'
         ,p_procedure_name => 'VALIDATE_CHANGE_REASON_CODE'
         ,p_error_text     =>  sqlerrm);

      pa_debug.G_Err_Stack := SQLERRM;
      IF l_debug_mode = 'Y' THEN
         pa_debug.write('VALIDATE_CHANGE_REASON_CODE :' || g_module_name,pa_debug.G_Err_Stack,4);
      END IF;
      pa_debug.reset_err_stack;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END VALIDATE_CHANGE_REASON_CODE ;
*/ -- end of bug 5350437

PROCEDURE VALIDATE_TXN_CURRENCY_CODE
                 (p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE
                 ,p_proj_fp_options_id   IN  pa_proj_fp_options.proj_fp_options_id%TYPE
                 ,p_txn_currency_code    IN  pa_budget_lines.txn_currency_code%TYPE
                 ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data             OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_debug_mode             VARCHAR2(1);
  l_msg_count              NUMBER ;
  l_data                   VARCHAR2(2000);
  l_msg_data               VARCHAR2(2000);
  l_msg_index_out          NUMBER;
  l_exists                 VARCHAR2(1) ;
  l_curr_found             BOOLEAN;


  CURSOR C_TXN_CURR_CODE IS
      SELECT txn_currency_code
        FROM pa_fp_txn_currencies
       WHERE fin_plan_version_id = p_budget_version_id
         AND proj_fp_options_id = p_proj_fp_options_id ;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('PA_FP_WEBADI_UTILS.VALIDATE_TXN_CURRENCY_CODE');
              pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_txn_currency_code IS NULL) OR (p_budget_version_id is NULL )
      THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Invalid input parameter';
                        pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;


      IF (nvl(G_BUDGET_VERSION_ID,-99) <> p_budget_version_id
                OR  nvl(G_TABLE_POPULATED,'N') <> 'Y' ) THEN

              OPEN C_TXN_CURR_CODE ;
              FETCH C_TXN_CURR_CODE BULK COLLECT INTO
                    G_TXN_CURRENCY_CODE_TBL ;

           -- Initialize all the package level global variables

              G_BUDGET_VERSION_ID := p_budget_version_id ;
              G_TABLE_POPULATED   := 'Y' ;

      END IF ;


      --  If the input currency code is there in the PLSQL table
      -- then return success else error .

      l_curr_found := false;
      IF nvl(G_TXN_CURRENCY_CODE_TBL.last,0) >= 1 THEN
          FOR i in G_TXN_CURRENCY_CODE_TBL.FIRST..G_TXN_CURRENCY_CODE_TBL.LAST
          LOOP
               IF p_txn_currency_code = G_TXN_CURRENCY_CODE_TBL(i) THEN
                   l_curr_found := true;
               END IF;
          END LOOP ;
      END IF ;

      IF l_curr_found THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Close the cursor if its open
      IF C_TXN_CURR_CODE%ISOPEN THEN
         CLOSE C_TXN_CURR_CODE ;
      END IF ;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting VALIDATE_TXN_CURRENCY_CODE';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           pa_debug.reset_err_stack;
      END IF;

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

   -- Close the cursor if its open

     IF C_TXN_CURR_CODE%ISOPEN THEN
            CLOSE C_TXN_CURR_CODE ;
     END IF ;

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
           pa_debug.reset_err_stack;
      END IF;

      RETURN;
  WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

  -- Close the cursor if its open

     IF C_TXN_CURR_CODE%ISOPEN THEN
            CLOSE C_TXN_CURR_CODE ;
     END IF ;


      FND_MSG_PUB.add_exc_msg
        ( p_pkg_name       => 'PA_FP_WEBADI_UTILS'
         ,p_procedure_name => 'VALIDATE_TXN_CURRENCY_CODE'
         ,p_error_text     =>  sqlerrm);

      pa_debug.G_Err_Stack := SQLERRM;
      IF l_debug_mode = 'Y' THEN
         pa_debug.write('VALIDATE_TXN_CURRENCY_CODE :' || g_module_name,pa_debug.G_Err_Stack,4);
      END IF;
      pa_debug.reset_err_stack;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END VALIDATE_TXN_CURRENCY_CODE ;

/* Bug 5350437: Commented the below API
PROCEDURE GET_VERSION_PERIODS_INFO
              ( p_budget_version_id  IN  pa_budget_versions.budget_version_id%TYPE
             ,x_period_name_tbl   OUT  NOCOPY pa_fp_webadi_pkg.l_period_name_tbl_typ --File.Sql.39 bug 4440895
             ,x_start_date_tbl    OUT  NOCOPY pa_fp_webadi_pkg.l_start_date_tbl_typ --File.Sql.39 bug 4440895
             ,x_end_date_tbl      OUT  NOCOPY pa_fp_webadi_pkg.l_end_date_tbl_typ --File.Sql.39 bug 4440895
             ,x_number_of_pds     OUT  NOCOPY pa_proj_period_profiles.number_of_periods%TYPE --File.Sql.39 bug 4440895
               ,x_period_profile_id OUT  NOCOPY pa_budget_versions.period_profile_id%TYPE --File.Sql.39 bug 4440895
             ,x_return_status     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_msg_count         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
               ,x_msg_data          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              )
IS

  l_debug_mode                    VARCHAR2(1) ;
  l_msg_count                     NUMBER := 0 ;
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;

  CURSOR C_PERIOD_DATES_CUR IS
     SELECT
            null                -- For SD
          , null                -- For PD
          , ppp.period_name1
          , ppp.period_name2
          , ppp.period_name3
          , ppp.period_name4
          , ppp.period_name5
          , ppp.period_name6
          , ppp.period_name7
          , ppp.period_name8
          , ppp.period_name9
          , ppp.period_name10
          , ppp.period_name11
          , ppp.period_name12
          , ppp.period_name13
          , ppp.period_name14
          , ppp.period_name15
          , ppp.period_name16
          , ppp.period_name17
          , ppp.period_name18
          , ppp.period_name19
          , ppp.period_name20
          , ppp.period_name21
          , ppp.period_name22
          , ppp.period_name23
          , ppp.period_name24
          , ppp.period_name25
          , ppp.period_name26
          , ppp.period_name27
          , ppp.period_name28
          , ppp.period_name29
          , ppp.period_name30
          , ppp.period_name31
          , ppp.period_name32
          , ppp.period_name33
          , ppp.period_name34
          , ppp.period_name35
          , ppp.period_name36
          , ppp.period_name37
          , ppp.period_name38
          , ppp.period_name39
          , ppp.period_name40
          , ppp.period_name41
          , ppp.period_name42
          , ppp.period_name43
          , ppp.period_name44
          , ppp.period_name45
          , ppp.period_name46
          , ppp.period_name47
          , ppp.period_name48
          , ppp.period_name49
          , ppp.period_name50
          , ppp.period_name51
          , ppp.period_name52
          , null                -- For SD
          , null                -- For PD
          , ppp.period1_start_date
          , ppp.period2_start_date
          , ppp.period3_start_date
          , ppp.period4_start_date
          , ppp.period5_start_date
          , ppp.period6_start_date
          , ppp.period7_start_date
          , ppp.period8_start_date
          , ppp.period9_start_date
          , ppp.period10_start_date
          , ppp.period11_start_date
          , ppp.period12_start_date
          , ppp.period13_start_date
          , ppp.period14_start_date
          , ppp.period15_start_date
          , ppp.period16_start_date
          , ppp.period17_start_date
          , ppp.period18_start_date
          , ppp.period19_start_date
          , ppp.period20_start_date
          , ppp.period21_start_date
          , ppp.period22_start_date
          , ppp.period23_start_date
          , ppp.period24_start_date
          , ppp.period25_start_date
          , ppp.period26_start_date
          , ppp.period27_start_date
          , ppp.period28_start_date
          , ppp.period29_start_date
          , ppp.period30_start_date
          , ppp.period31_start_date
          , ppp.period32_start_date
          , ppp.period33_start_date
          , ppp.period34_start_date
          , ppp.period35_start_date
          , ppp.period36_start_date
          , ppp.period37_start_date
          , ppp.period38_start_date
          , ppp.period39_start_date
          , ppp.period40_start_date
          , ppp.period41_start_date
          , ppp.period42_start_date
          , ppp.period43_start_date
          , ppp.period44_start_date
          , ppp.period45_start_date
          , ppp.period46_start_date
          , ppp.period47_start_date
          , ppp.period48_start_date
          , ppp.period49_start_date
          , ppp.period50_start_date
          , ppp.period51_start_date
          , ppp.period52_start_date
          , null                -- For SD
          , null                -- For PD
          , ppp.period1_end_date
          , ppp.period2_end_date
          , ppp.period3_end_date
          , ppp.period4_end_date
          , ppp.period5_end_date
          , ppp.period6_end_date
          , ppp.period7_end_date
          , ppp.period8_end_date
          , ppp.period9_end_date
          , ppp.period10_end_date
          , ppp.period11_end_date
          , ppp.period12_end_date
          , ppp.period13_end_date
          , ppp.period14_end_date
          , ppp.period15_end_date
          , ppp.period16_end_date
          , ppp.period17_end_date
          , ppp.period18_end_date
          , ppp.period19_end_date
          , ppp.period20_end_date
          , ppp.period21_end_date
          , ppp.period22_end_date
          , ppp.period23_end_date
          , ppp.period24_end_date
          , ppp.period25_end_date
          , ppp.period26_end_date
          , ppp.period27_end_date
          , ppp.period28_end_date
          , ppp.period29_end_date
          , ppp.period30_end_date
          , ppp.period31_end_date
          , ppp.period32_end_date
          , ppp.period33_end_date
          , ppp.period34_end_date
          , ppp.period35_end_date
          , ppp.period36_end_date
          , ppp.period37_end_date
          , ppp.period38_end_date
          , ppp.period39_end_date
          , ppp.period40_end_date
          , ppp.period41_end_date
          , ppp.period42_end_date
          , ppp.period43_end_date
          , ppp.period44_end_date
          , ppp.period45_end_date
          , ppp.period46_end_date
          , ppp.period47_end_date
          , ppp.period48_end_date
          , ppp.period49_end_date
          , ppp.period50_end_date
          , ppp.period51_end_date
          , ppp.period52_end_date
          , ppp.number_of_periods
          , pbv.period_profile_id
  FROM
       pa_proj_period_profiles ppp
    , pa_budget_versions pbv
 WHERE pbv.budget_version_id = p_budget_version_id
   AND ppp.period_profile_id = pbv.period_profile_id ;

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
       pa_debug.set_err_stack('PA_FP_WEBADI_PKG.GET_VERSION_PERIOD_INFO');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := ':In PA_FP_WEBADI_PKG.GET_VERSION_PERIOD_INFO' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id IS NULL)  THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'INVALID INPUT PARAMETER';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA'
                                ,p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    OPEN C_PERIOD_DATES_CUR ;

    FETCH C_PERIOD_DATES_CUR INTO
             x_period_name_tbl(1)
           , x_period_name_tbl(2)
           , x_period_name_tbl(3)
           , x_period_name_tbl(4)
           , x_period_name_tbl(5)
           , x_period_name_tbl(6)
           , x_period_name_tbl(7)
           , x_period_name_tbl(8)
           , x_period_name_tbl(9)
           , x_period_name_tbl(10)
           , x_period_name_tbl(11)
           , x_period_name_tbl(12)
           , x_period_name_tbl(13)
           , x_period_name_tbl(14)
           , x_period_name_tbl(15)
           , x_period_name_tbl(16)
           , x_period_name_tbl(17)
           , x_period_name_tbl(18)
           , x_period_name_tbl(19)
           , x_period_name_tbl(20)
           , x_period_name_tbl(21)
           , x_period_name_tbl(22)
           , x_period_name_tbl(23)
           , x_period_name_tbl(24)
           , x_period_name_tbl(25)
           , x_period_name_tbl(26)
           , x_period_name_tbl(27)
           , x_period_name_tbl(28)
           , x_period_name_tbl(29)
           , x_period_name_tbl(30)
           , x_period_name_tbl(31)
           , x_period_name_tbl(32)
           , x_period_name_tbl(33)
           , x_period_name_tbl(34)
           , x_period_name_tbl(35)
           , x_period_name_tbl(36)
           , x_period_name_tbl(37)
           , x_period_name_tbl(38)
           , x_period_name_tbl(39)
           , x_period_name_tbl(40)
           , x_period_name_tbl(41)
           , x_period_name_tbl(42)
           , x_period_name_tbl(43)
           , x_period_name_tbl(44)
           , x_period_name_tbl(45)
           , x_period_name_tbl(46)
           , x_period_name_tbl(47)
           , x_period_name_tbl(48)
           , x_period_name_tbl(49)
           , x_period_name_tbl(50)
           , x_period_name_tbl(51)
           , x_period_name_tbl(52)
           , x_period_name_tbl(53)
           , x_period_name_tbl(54)
           , x_start_date_tbl(1)
           , x_start_date_tbl(2)
           , x_start_date_tbl(3)
           , x_start_date_tbl(4)
           , x_start_date_tbl(5)
           , x_start_date_tbl(6)
           , x_start_date_tbl(7)
           , x_start_date_tbl(8)
           , x_start_date_tbl(9)
           , x_start_date_tbl(10)
           , x_start_date_tbl(11)
           , x_start_date_tbl(12)
           , x_start_date_tbl(13)
           , x_start_date_tbl(14)
           , x_start_date_tbl(15)
           , x_start_date_tbl(16)
           , x_start_date_tbl(17)
           , x_start_date_tbl(18)
           , x_start_date_tbl(19)
           , x_start_date_tbl(20)
           , x_start_date_tbl(21)
           , x_start_date_tbl(22)
           , x_start_date_tbl(23)
           , x_start_date_tbl(24)
           , x_start_date_tbl(25)
           , x_start_date_tbl(26)
           , x_start_date_tbl(27)
           , x_start_date_tbl(28)
           , x_start_date_tbl(29)
           , x_start_date_tbl(30)
           , x_start_date_tbl(31)
           , x_start_date_tbl(32)
           , x_start_date_tbl(33)
           , x_start_date_tbl(34)
           , x_start_date_tbl(35)
           , x_start_date_tbl(36)
           , x_start_date_tbl(37)
           , x_start_date_tbl(38)
           , x_start_date_tbl(39)
           , x_start_date_tbl(40)
           , x_start_date_tbl(41)
           , x_start_date_tbl(42)
           , x_start_date_tbl(43)
           , x_start_date_tbl(44)
           , x_start_date_tbl(45)
           , x_start_date_tbl(46)
           , x_start_date_tbl(47)
           , x_start_date_tbl(48)
           , x_start_date_tbl(49)
           , x_start_date_tbl(50)
           , x_start_date_tbl(51)
           , x_start_date_tbl(52)
           , x_start_date_tbl(53)
           , x_start_date_tbl(54)
           , x_end_date_tbl(1)
           , x_end_date_tbl(2)
           , x_end_date_tbl(3)
           , x_end_date_tbl(4)
           , x_end_date_tbl(5)
           , x_end_date_tbl(6)
           , x_end_date_tbl(7)
           , x_end_date_tbl(8)
           , x_end_date_tbl(9)
           , x_end_date_tbl(10)
           , x_end_date_tbl(11)
           , x_end_date_tbl(12)
           , x_end_date_tbl(13)
           , x_end_date_tbl(14)
           , x_end_date_tbl(15)
           , x_end_date_tbl(16)
           , x_end_date_tbl(17)
           , x_end_date_tbl(18)
           , x_end_date_tbl(19)
           , x_end_date_tbl(20)
           , x_end_date_tbl(21)
           , x_end_date_tbl(22)
           , x_end_date_tbl(23)
           , x_end_date_tbl(24)
           , x_end_date_tbl(25)
           , x_end_date_tbl(26)
           , x_end_date_tbl(27)
           , x_end_date_tbl(28)
           , x_end_date_tbl(29)
           , x_end_date_tbl(30)
           , x_end_date_tbl(31)
           , x_end_date_tbl(32)
           , x_end_date_tbl(33)
           , x_end_date_tbl(34)
           , x_end_date_tbl(35)
           , x_end_date_tbl(36)
           , x_end_date_tbl(37)
           , x_end_date_tbl(38)
           , x_end_date_tbl(39)
           , x_end_date_tbl(40)
           , x_end_date_tbl(41)
           , x_end_date_tbl(42)
           , x_end_date_tbl(43)
           , x_end_date_tbl(44)
           , x_end_date_tbl(45)
           , x_end_date_tbl(46)
           , x_end_date_tbl(47)
           , x_end_date_tbl(48)
           , x_end_date_tbl(49)
           , x_end_date_tbl(50)
           , x_end_date_tbl(51)
           , x_end_date_tbl(52)
           , x_end_date_tbl(53)
           , x_end_date_tbl(54)
           , x_number_of_pds
           , x_period_profile_id;

    IF C_PERIOD_DATES_CUR%NOTFOUND THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc ;
    END IF ;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'exiting get_version_period_info';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
        pa_debug.reset_err_stack;
    END IF ;

EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     -- Close the cursor

     IF C_PERIOD_DATES_CUR%ISOPEN THEN
        CLOSE C_PERIOD_DATES_CUR ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := 'inside invalid arg exception of get_version_period_info';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
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
        pa_debug.reset_err_stack;
      END IF ;

      RETURN;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

      IF C_PERIOD_DATES_CUR%ISOPEN THEN
            CLOSE C_PERIOD_DATES_CUR ;
          END IF ;

          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_WEBADI_PKG'
              ,p_procedure_name => 'GET_VERSION_PERIOD_INFO' );
          IF l_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_XFACE' || g_module_name,SQLERRM,4);
             pa_debug.write('DELETE_XFACE' || g_module_name,pa_debug.G_Err_Stack,4);
          END IF;

          IF l_debug_mode = 'Y' THEN
             pa_debug.reset_err_stack;
          END IF ;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END GET_VERSION_PERIODS_INFO;
*/ -- end of Bug 5350437

/* Bug 3986129: FP.M- Web ADI Dev Changes: The following api is no longer being called from PAFPWAPB.pls
 * retaining this just for reference */
PROCEDURE CHECK_OVERLAPPING_DATES
                  ( p_budget_version_id     IN pa_budget_versions.budget_version_id%TYPE
                   ,x_rec_failed_validation OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                   ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  )
IS

  l_debug_mode                    VARCHAR2(1) ;
  l_msg_count                     NUMBER := 0;
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_exists                        VARCHAR2(1) ;
  l_rowid                         ROWID ;

  -- This cursor selects all the records from the xface table
  -- for which there exists records in eitherxface table or
  -- budget lines table with overlapping dates.

  CURSOR C_OVERLAPPING_CUR IS
      SELECT a.rowid
        FROM PA_FP_WEBADI_XFACE_TMP a
      WHERE a.budget_version_id = p_budget_version_id
        AND ( EXISTS (SELECT 'Y'
                       FROM PA_FP_WEBADI_XFACE_TMP b
                      WHERE a.rowid <> b.rowid
                        AND b.budget_version_id = p_budget_version_id
                        AND b.resource_assignment_id = a.resource_assignment_id
                        AND b.txn_currency_code = a.txn_currency_code
                        AND a.start_date <= b.end_date
                        AND a.end_date >= b.start_date )
               OR EXISTS (SELECT 'Y'
                       FROM PA_BUDGET_LINES bl
                      WHERE bl.budget_version_id = p_budget_version_id
                        AND bl.resource_assignment_id = a.resource_assignment_id
                        AND bl.txn_currency_code = a.txn_currency_code
                    AND bl.start_date <> a.start_date
                        AND a.start_date <= bl.end_date
                        AND a.end_date >= bl.start_date )) ;

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
       pa_debug.set_err_stack('PA_FP_WEBADI_PKG.CHECK_OVERLAPPING_DATES');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := ':In PA_FP_WEBADI_PKG.CHECK_OVERLAPPING_DATES' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id IS NULL)  THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'INVALID INPUT PARAMETER';
                  pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
              END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA'
                                ,p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := ':Opening Cursor C_OVERLAPPING_CUR ' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- initialize x_rec_failed_validation initially.
    x_rec_failed_validation := 'N' ;

    OPEN C_OVERLAPPING_CUR ;
    LOOP
    FETCH C_OVERLAPPING_CUR INTO
          l_rowid ;
    IF C_OVERLAPPING_CUR%FOUND THEN
          x_rec_failed_validation := 'Y' ;
          UPDATE PA_FP_WEBADI_XFACE_TMP tmp
             SET val_error_code = 'PA_FP_WEBADI_OVERLAPPING_DATE'
                ,val_error_flag = 'Y'
             WHERE rowid = l_rowid ;
    END IF ;
    EXIT WHEN C_OVERLAPPING_CUR%NOTFOUND ;
    END LOOP ;

    CLOSE C_OVERLAPPING_CUR ;

    IF l_debug_mode = 'Y' THEN
        pa_debug.reset_err_stack;
    END IF ;

EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

   -- Close the cursor

     IF C_OVERLAPPING_CUR%ISOPEN THEN
        CLOSE C_OVERLAPPING_CUR ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := 'inside invalid arg exception of check_overlapping_dates';
       pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
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
        pa_debug.reset_err_stack;
      END IF ;

      RETURN;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

      IF C_OVERLAPPING_CUR%ISOPEN THEN
            CLOSE C_OVERLAPPING_CUR ;
          END IF ;

          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_WEBADI_PKG'
              ,p_procedure_name => 'C_OVERLAPPING_CUR' );
          IF l_debug_mode = 'Y' THEN
             pa_debug.write('check_overlapping_dates' || g_module_name,SQLERRM,4);
             pa_debug.write('check_overlapping_dates' || g_module_name,pa_debug.G_Err_Stack,4);
          END IF;

          IF l_debug_mode = 'Y' THEN
            pa_debug.reset_err_stack;
          END IF ;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END CHECK_OVERLAPPING_DATES;

/*==================================================================
   This API Accepts the error code, amount type and the currency type
   and returns the lookup code that contains the equivalent error message.
   This API is used in the context of WEBADI for throwing error to the
   user using the lookup code.
 ==================================================================*/

PROCEDURE GET_MC_ERROR_LOOKUP_CODE
                 (p_mc_error_code         IN   pa_lookups.lookup_code%TYPE
                 ,p_attr_set_cost_rev     IN   VARCHAR2
                 ,p_attr_set_pc_pfc       IN   VARCHAR2
                 ,x_error_lookup_code     OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                 ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data              OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode            VARCHAR2(1);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entering GET_ERROR_LOOKUP_CODE';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.set_curr_function( p_function   => 'GET_ERROR_LOOKUP_CODE',
                              p_debug_mode => l_debug_mode );

          -- Check for business rules violations
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'p_mc_error_code = '|| p_mc_error_code;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.g_err_stage:= 'p_attr_set_cost_rev = '|| p_attr_set_cost_rev;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.g_err_stage:= 'p_attr_set_pc_pfc = '|| p_attr_set_pc_pfc;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
     END IF;


     IF (p_mc_error_code IS NULL) OR
        (p_attr_set_cost_rev IS NULL) OR
        (p_attr_set_pc_pfc IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                    p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     --Determine the lookup code from the passed values
     IF p_mc_error_code = 'PA_FP_RATE_TYPE_REQ' OR p_mc_error_code = 'PA_FP_INVALID_RATE_TYPE' -- Rate type is null.
     THEN
          IF p_attr_set_pc_pfc = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC
          THEN
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_COST_RT';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_REV_RT';   -- amount is revenue.
               END IF;

          ELSE
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_COST_RT';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_REV_RT';    -- amount is revenue.
               END IF;
          END IF;
     ELSIF p_mc_error_code = 'PA_FP_USER_EXCH_RATE_REQ' -- Rate type is user and Rate is null.
     THEN
          IF p_attr_set_pc_pfc = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC
          THEN
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_COST_RATE';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_REV_RATE';
               END IF;
          ELSE
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_COST_RATE';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_REV_RATE';
               END IF;
          END IF;
     ELSIF p_mc_error_code = 'PA_FP_INVALID_RATE_DATE_TYPE' -- Rate date type is null.
     THEN
          IF p_attr_set_pc_pfc = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC
          THEN
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_COST_RDT';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_REV_RDT';
               END IF;
          ELSE
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_COST_RDT';
               ELSE

                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PR_REV_RDT';
               END IF;
          END IF;
     ELSIF p_mc_error_code = 'PA_FP_INVALID_RATE_DATE'  -- Rate date type is fixed date and rate date is null.
     THEN
          IF p_attr_set_pc_pfc = PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC
          THEN
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_COST_RD';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_REV_RD';
               END IF;
          ELSE
               IF p_attr_set_cost_rev = PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST
               THEN
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_COST_RD';
               ELSE
                       x_error_lookup_code :=  'PA_FP_WEBADI_INV_PF_REV_RD';
               END IF;
          END IF;
     ELSE   -- The parameters have invalid values.
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Error in input parameters';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'x_error_lookup_code = '||x_error_lookup_code;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting get_error_lookup_code';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          pa_debug.reset_curr_function;
     END IF;
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
        IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
        END IF;
        RETURN;

   WHEN others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name        => 'PA_FP_WEBADI_UTILS'
                         ,p_procedure_name  => 'GET_ERROR_LOOKUP_CODE'
                         ,p_error_text      => x_msg_data);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
        END IF;
        RAISE;

END GET_MC_ERROR_LOOKUP_CODE;

/*==================================================================
   This api gets the lookup meanings and returns the lookup codes.
   This api is used in webadi.
 ==================================================================*/

PROCEDURE CONV_MC_ATTR_MEANING_TO_CODE          /* webadi */
                (p_pc_cost_rate_type_name            IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pc_cost_rate_date_type_name       IN  pa_lookups.meaning%TYPE
                ,p_pfc_cost_rate_type_name           IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pfc_cost_rate_date_type_name      IN  pa_lookups.meaning%TYPE
                ,p_pc_rev_rate_type_name             IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pc_rev_rate_date_type_name        IN  pa_lookups.meaning%TYPE
                ,p_pfc_rev_rate_type_name            IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pfc_rev_rate_date_type_name       IN  pa_lookups.meaning%TYPE
                ,x_pc_cost_rate_type                OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pc_cost_rate_date_type           OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_cost_rate_type               OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_cost_rate_date_type          OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pc_rev_rate_type                 OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pc_rev_rate_date_type            OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_rev_rate_type                OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_rev_rate_date_type           OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_return_status                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count                        OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                ,x_msg_data                         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                )
AS
     l_msg_count                     NUMBER := 0;
     l_data                          VARCHAR2(2000);
     l_msg_data                      VARCHAR2(2000);
     l_msg_index_out                 NUMBER;
     l_debug_mode                 VARCHAR2(1);

     l_conversion_type               pa_conversion_types_v.conversion_type%TYPE;
     l_user_conversion_type          pa_conversion_types_v.user_conversion_type%TYPE;
     l_lookup_code                   pa_lookups.lookup_code%TYPE;
     l_lookup_meaning                pa_lookups.meaning%TYPE;
     l_lookup_type                   pa_lookups.lookup_type%TYPE;

cursor rate_type_cur is
select conversion_type, user_conversion_type
  from pa_conversion_types_v
  where user_conversion_type IN  (p_pc_cost_rate_type_name
                                 ,p_pfc_cost_rate_type_name
                                 ,p_pc_rev_rate_type_name
                                 ,p_pfc_rev_rate_type_name);

cursor rate_date_type_cur is
select lookup_code, lookup_type, meaning
  from pa_lookups
 where lookup_type = 'PA_FP_RATE_DATE_TYPE'
   and meaning IN (p_pc_cost_rate_date_type_name
                         ,p_pfc_cost_rate_date_type_name
                         ,p_pc_rev_rate_date_type_name
                         ,p_pfc_rev_rate_date_type_name);


BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'CONV_MC_ATTR_MEANING_TO_CODE',
                              p_debug_mode => l_debug_mode );

          -- Check for business rules violations
          pa_debug.g_err_stage:= 'No Validation of input parameters is done in this API';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.g_err_stage:= 'Printing the input parameters.';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.g_err_stage:= 'p_pc_cost_rate_type_name : '||p_pc_cost_rate_type_name||
                                 ' p_pc_cost_rate_date_type_name : '||p_pc_cost_rate_date_type_name;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.g_err_stage:= 'p_pfc_cost_rate_type_name : '||p_pfc_cost_rate_type_name||
                                 ' p_pfc_cost_rate_date_type_name : '||p_pfc_cost_rate_date_type_name ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.g_err_stage:= 'p_pc_rev_rate_type_name : '||p_pc_rev_rate_type_name||
                                 ' p_pc_rev_rate_date_type_name : '||p_pc_rev_rate_date_type_name;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

          pa_debug.g_err_stage:= 'p_pfc_rev_rate_type_name : '||p_pfc_rev_rate_type_name||
                                 ' p_pfc_rev_rate_date_type_name : '||p_pfc_rev_rate_date_type_name ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;

     FOR rate_type_rec IN rate_type_cur LOOP
          IF rate_type_rec.user_conversion_type = p_pc_cost_rate_type_name THEN
                x_pc_cost_rate_type := rate_type_rec.conversion_type;
          END IF ;

          IF rate_type_rec.user_conversion_type = p_pfc_cost_rate_type_name THEN
                x_pfc_cost_rate_type:= rate_type_rec.conversion_type;
          END IF ;

          IF rate_type_rec.user_conversion_type = p_pc_rev_rate_type_name THEN
                x_pc_rev_rate_type := rate_type_rec.conversion_type;
          END IF ;

          IF rate_type_rec.user_conversion_type = p_pfc_rev_rate_type_name THEN
                x_pfc_rev_rate_type := rate_type_rec.conversion_type;
          END IF;
     END LOOP;

     FOR rate_date_type_rec IN rate_date_type_cur LOOP
          IF rate_date_type_rec.meaning = p_pc_cost_rate_date_type_name THEN
                x_pc_cost_rate_date_type := rate_date_type_rec.lookup_code;
          END IF;

          IF rate_date_type_rec.meaning = p_pfc_cost_rate_date_type_name THEN
                x_pfc_cost_rate_date_type := rate_date_type_rec.lookup_code;
          END IF ;

          IF rate_date_type_rec.meaning = p_pc_rev_rate_date_type_name THEN
                x_pc_rev_rate_date_type := rate_date_type_rec.lookup_code;
          END IF ;

          IF rate_date_type_rec.meaning = p_pfc_rev_rate_date_type_name THEN
                x_pfc_rev_rate_date_type := rate_date_type_rec.lookup_code;
          END IF;
     END LOOP;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing the output parameters.';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;

          pa_debug.g_err_stage:= 'x_pc_cost_rate_type : '||x_pc_cost_rate_type||
                                 ' x_pc_cost_rate_date_type : '||x_pc_cost_rate_date_type ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          pa_debug.g_err_stage:= 'x_pfc_cost_rate_type: '||x_pfc_cost_rate_type||
                                 ' x_pfc_cost_rate_date_type : '||x_pfc_cost_rate_date_type ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;

          pa_debug.g_err_stage:= 'x_pc_rev_rate_type : '||x_pc_rev_rate_type||
                                 ' x_pc_rev_rate_date_type : '||x_pc_rev_rate_date_type;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;

          pa_debug.g_err_stage:= 'x_pfc_rev_rate_type : '||x_pfc_rev_rate_type||
                                 ' x_pfc_rev_rate_date_type : '||x_pfc_rev_rate_date_type ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;

          pa_debug.g_err_stage:= 'Exiting CONV_MC_ATTR_MEANING_TO_CODE';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.reset_curr_function;
     END IF;

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
        IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
        END IF;
        RETURN;

   WHEN others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name        => 'PA_FP_WEBADI_UTILS'
                         ,p_procedure_name  => 'CONV_MC_ATTR_MEANING_TO_CODE'
                         ,p_error_text      => x_msg_data);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
        END IF;
        RAISE;

END CONV_MC_ATTR_MEANING_TO_CODE ;

FUNCTION GET_AMOUNT_TYPE_NAME (
         p_amount_type_code  IN   PA_AMOUNT_TYPES_B.AMOUNT_TYPE_CODE%TYPE )
RETURN   PA_AMOUNT_TYPES_VL.AMOUNT_TYPE_NAME%TYPE
IS

   l_amount_type_name  PA_AMOUNT_TYPES_VL.AMOUNT_TYPE_NAME%TYPE ;

BEGIN

   SELECT amount_type_name
   INTO   l_amount_type_name
   FROM   pa_amount_types_vl
   WHERE  amount_type_code = p_amount_type_code;

   RETURN l_amount_type_name;

END GET_AMOUNT_TYPE_NAME;

/*==================================================================================
This procedure is used to get the layout name and the layout type code when the
layout type is passed.
  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/
PROCEDURE get_layout_details
                 (p_layout_code           IN    pa_proj_fp_options.cost_layout_code%TYPE
                 ,p_integrator_code       IN    bne_integrators_b.integrator_code%TYPE
                 ,x_layout_name           OUT   NOCOPY bne_layouts_tl.user_name%TYPE --File.Sql.39 bug 4440895
                 ,x_layout_type_code      OUT   NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                 ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count             OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ) IS

    --Start of variables used for debugging
    l_return_status                            VARCHAR2(1);
    l_msg_count                                NUMBER := 0;
    l_msg_data                                 VARCHAR2(2000);
    l_data                                     VARCHAR2(2000);
    l_msg_index_out                            NUMBER;
    l_debug_mode                               VARCHAR2(30);
    l_debug_level3                    CONSTANT NUMBER := 3;
    l_debug_level5                    CONSTANT NUMBER := 5;
    l_module_name                              VARCHAR2(200) :=  g_module_name||'.get_layout_details';
    --End of variables used for debugging
    l_integrator_code                          VARCHAR2(30);
    l_layout_name                              bne_layouts_tl.user_name%TYPE;
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
    pa_debug.set_curr_function(
                p_function   =>'pa_fp_webadi_utils.get_layout_details'
               ,p_debug_mode => l_debug_mode );

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_layout_code IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_layout_code is '||p_layout_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SELECT integrator_code
    INTO   l_integrator_code
    FROM   bne_layouts_b
    WHERE  layout_code= p_layout_code
    AND application_id = (SELECT application_id
    FROM FND_APPLICATION
    WHERE APPLICATION_SHORT_NAME = 'PA');


    IF p_integrator_code IS NOT NULL THEN
        l_integrator_code := p_integrator_code;
    END IF;
    x_layout_name := NULL;
   IF l_integrator_code = 'FINPLAN_BUDGET_PERIODIC' THEN
        x_layout_type_code := 'PERIODIC_BUDGET';
    ELSIF l_integrator_code = 'FINPLAN_BUDGET_NON_PERIODIC' THEN
        x_layout_type_code := 'NON_PERIODIC_BUDGET';
    ELSIF l_integrator_code = 'FINPLAN_FORECAST_PERIODIC' THEN
        x_layout_type_code  := 'PERIODIC_FORECAST';
    ELSIF l_integrator_code = 'FINPLAN_FORECAST_NON_PERIODIC' THEN
        x_layout_type_code  := 'NON_PERIODIC_FORECAST';
    END IF;
    -- reset curr function
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='x_layout_type_code is '|| x_layout_type_code;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
        pa_debug.g_err_stage:='x_layout_name is '|| x_layout_name;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

    END IF;
    pa_debug.reset_curr_function();

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
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
       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

       END IF;
       -- reset curr function
       pa_debug.reset_curr_function();
       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_webadi_utils'
                               ,p_procedure_name  => 'get_layout_details');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       END IF;
       -- reset curr function
       pa_debug.Reset_Curr_Function();
      RAISE;

END get_layout_details;


 -- Bug 3986129: FP.M Web ADI Dev changes: Added the follwoing apis

-- This api would be called from a java method when the user wants to delete the data from the excel interface
-- that is downloaded for a session.

  PROCEDURE delete_interface_tbl_data
      (p_request_id           IN          pa_budget_versions.request_id%TYPE,
       x_return_status        OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count            OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data             OUT         NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

  IS
      l_debug_mode           VARCHAR2(30);
      l_module_name          VARCHAR2(100) := 'PAFPWAUB.delete_interface_tbl_data';
      l_msg_count            NUMBER := 0;
      l_data                 VARCHAR2(2000);
      l_msg_data             VARCHAR2(2000);
      l_msg_index_out        NUMBER;

      l_run_id               pa_fp_webadi_upload_inf.run_id%TYPE;
      l_budget_version_id    pa_budget_versions.budget_version_id%TYPE;

  BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      PA_DEBUG.Set_Curr_Function(p_function   => l_module_name,
                                 p_debug_mode => l_debug_mode );

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Entering delete_inter_face_data';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:='Validating input parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF p_request_id IS NULL THEN
            -- throwing error as this is a mandatory parameter
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='p_request_id is passed as null';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
           pa_utils.add_message
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                 p_token1          => 'PROCEDURENAME',
                 p_value1          => l_module_name);
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Getting run_id and budget_version_id';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      BEGIN
            SELECT run_id,
                   budget_version_id
            INTO   l_run_id,
                   l_budget_version_id
            FROM   pa_fp_webadi_upload_inf
            WHERE  request_id = p_request_id
            AND    ROWNUM = 1;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Invalid request_id is passed';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 pa_utils.add_message
                      (p_app_short_name  => 'PA',
                       p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                       p_token1          => 'PROCEDURENAME',
                       p_value1          => l_module_name);
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Calling PA_FP_WEBADI_PKG.delete_xface';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      PA_FP_WEBADI_PKG.delete_xface
            ( p_run_id         => l_run_id
             ,x_return_status  => x_return_status
             ,x_msg_count      => x_msg_count
             ,x_msg_data       => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Call to PA_FP_WEBADI_PKG.delete_xface returned with error';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='PA_FP_WEBADI_PKG.delete_xface Called';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage:='Updating pa_budget_versions';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      UPDATE pa_budget_versions
      SET    plan_processing_code = null,
             request_id = null,
             record_version_number = record_version_number + 1
      WHERE  budget_version_id = l_budget_version_id;

      -- a explicit commit is required here to reflect the changes
      COMMIT;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Leaving delete_interface_tbl_data';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      pa_debug.reset_curr_function;

  EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count = 1 THEN
                  PA_INTERFACE_UTILS_PUB.get_messages
                      (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
             END IF;
             pa_debug.reset_curr_function;
      WHEN OTHERS THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPWAUB'
                                   ,p_procedure_name  => 'delete_interface_tbl_data');

           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
           pa_debug.reset_curr_function;
           RAISE;
  END delete_interface_tbl_data;

  -- This api would be called from a java method when the user wants to resubmit the request for the concurrent
  -- program, if the upload processing of the plan version fails for some reason.

  PROCEDURE resubmit_conc_request
      (p_old_request_id       IN          pa_budget_versions.request_id%TYPE,
       x_new_request_id       OUT         NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
       x_return_status        OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count            OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data             OUT         NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

  IS
       l_debug_mode           VARCHAR2(30);
       l_module_name          VARCHAR2(100) := 'PAFPWAUB.resubmit_conc_request';
       l_msg_count            NUMBER := 0;
       l_data                 VARCHAR2(2000);
       l_msg_data             VARCHAR2(2000);
       l_msg_index_out        NUMBER;

       l_run_id               pa_fp_webadi_upload_inf.run_id%TYPE;
       l_budget_version_id    pa_budget_versions.budget_version_id%TYPE;
       l_new_request_id       pa_budget_versions.request_id%TYPE;
       -- MOAC changes.
       l_org_id               pa_projects_all.org_id%TYPE;
  BEGIN
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      PA_DEBUG.Set_Curr_Function(p_function   => l_module_name,
                                 p_debug_mode => l_debug_mode );

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Entering resubmit_conc_request';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:='Validating input parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF p_old_request_id IS NULL THEN
            -- throwing error as this is a mandatory parameter
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='p_old_request_id is passed as null';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
           pa_utils.add_message
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                 p_token1          => 'PROCEDURENAME',
                 p_value1          => l_module_name);
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Getting run_id and budget_version_id';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      BEGIN
            SELECT run_id,
                   budget_version_id
            INTO   l_run_id,
                   l_budget_version_id
            FROM   pa_fp_webadi_upload_inf
            WHERE  request_id = p_old_request_id
            AND    ROWNUM = 1;
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Invalid request_id is passed';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 pa_utils.add_message
                      (p_app_short_name  => 'PA',
                       p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                       p_token1          => 'PROCEDURENAME',
                       p_value1          => l_module_name);
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Resubmitting the concurrent request';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      -- MOAC changes for release 12.
      -- Need to set the org id context before submitting a conc request.
      -- Getting the org id from pa_projects_all.
      -- Not embedding this sql in a block as this has to get a
      -- record/org id no matter what.
      -- If it fails let this be an unhandled exception and
      -- let it raise or handle at the end of the program.

           SELECT ppa.org_id
             INTO l_org_id
             FROM pa_projects_all ppa,
                  pa_budget_versions pbv
           WHERE  pbv.project_id = ppa.project_id
             AND  pbv.budget_version_id = l_budget_version_id;
      fnd_request.set_org_id(l_org_id);

      -- End of MOAC changes.

      l_new_request_id := FND_REQUEST.submit_request
                            (application  =>   'PA',
                             program      =>   'PAFPWACP',
                             description  =>   'PRC: Process spreadsheet plan data',
                             start_time   =>   NULL,
                             sub_request  =>   false,
                             argument1    =>   'N',
                             argument2    =>   l_run_id);

      IF l_new_request_id = 0 THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='The concurrent request Resubmission falied';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;

            UPDATE pa_budget_versions
            SET    plan_processing_code = 'XLUE'
            WHERE  budget_version_id = l_budget_version_id;

            x_new_request_id := l_new_request_id;
      ELSIF l_new_request_id > 0 THEN
            pa_debug.g_err_stage := 'plan data processing Request Id is'||TO_CHAR (l_new_request_id);
            IF l_debug_mode = 'Y' THEN
                pa_debug.write_file ('PA_FP_WEBADI_UTILS ' || pa_debug.g_err_stage);
            END IF;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Updating pa_budget_versions';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            UPDATE pa_budget_versions
            SET    plan_processing_code = 'XLUP',
                   request_id = l_new_request_id
            WHERE  budget_version_id = l_budget_version_id;

            -- updating the interface table with the new request_id
            UPDATE pa_fp_webadi_upload_inf
            SET    request_id = l_new_request_id
            WHERE  budget_version_id = l_budget_version_id
            AND    run_id = l_run_id;

            -- returning back the new request_id
            x_new_request_id := l_new_request_id;
      END IF;

      -- a explicit commit is required here to reflect the changes
      COMMIT;

      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Leaving resubmit_conc_request';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      pa_debug.reset_curr_function;

  EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count = 1 THEN
                  PA_INTERFACE_UTILS_PUB.get_messages
                      (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
             END IF;
             pa_debug.reset_curr_function;
      WHEN OTHERS THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPWAUB'
                                   ,p_procedure_name  => 'resubmit_conc_request');

           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           pa_debug.reset_curr_function;
           RAISE;
  END resubmit_conc_request;

 -- Bug 3986129: FP.M Web ADI Dev changes: Ends

-- Bug 3986129: FP.M Web ADI Dev changes: Added the follwoing apis
/* =================================================================================
  This function is used is FPM's Budget and Forecasting webadi download query to get the period amounts
  of the current baselined plan version
=======================================================================================*/
FUNCTION get_current_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER
IS
   l_quantity number :=null;
   l_number   number;
   l_curr_bv_id number := null;

   /* Added for bug 6453050 */
   l_txn_raw_cost number :=null;
   l_txn_burdened_cost number :=null;
   l_txn_revenue number :=null;
   l_amount number :=null;

   cursor bud_line_exists_cur is
       select 1
       from pa_budget_lines pbl, pa_resource_assignments pra
       where pra.project_id = p_project_id
       and   pra.task_id = p_task_id
       and pra.resource_list_member_id = p_resource_list_member_id
       and pra.unit_of_measure =  p_uom
       and pra.resource_assignment_id = pbl.resource_assignment_id
       and pra.budget_version_id = pbl.budget_version_id
       and pbl.budget_version_id = l_curr_bv_id;
BEGIN

    /*Derive the Current Budget Version Id using following logic
      If p_plan_class_code is BUDGET:
              current_version_id = current baselined version of same plan type
      If p_budget_version is a FORECAST version:
              current_version_id = current baselined version of APPROVED BUDGET plan type
    */
    if  p_plan_class_code = 'BUDGET' then
        begin
        select pbv.budget_version_id
        into  l_curr_bv_id
        from pa_budget_versions pbv,
             pa_proj_fp_options pfo
        where pfo.fin_plan_type_id = p_fin_plan_type_id
        and   pfo.project_id = p_project_id
            and   pfo.fin_plan_option_level_code = 'PLAN_VERSION'
            and   pfo.fin_plan_preference_code = p_fin_plan_preference_code
        and   pfo.fin_plan_version_id = pbv.budget_version_id
            and   pbv.current_flag = 'Y';
    exception
       when no_data_found then
           l_curr_bv_id := null;
    end;
    elsif p_plan_class_code = 'FORECAST' then
        if p_fin_plan_preference_code = 'COST_ONLY' then
        -- looking for APPROVED COST BUDGET plan type
           begin
              select bv.budget_version_id
          into l_curr_bv_id
          from pa_proj_fp_options po,
           pa_budget_versions bv
          where po.project_id = p_project_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            bv.approved_cost_plan_type_flag = 'Y' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_flag = 'Y';
           exception
          when NO_DATA_FOUND then
              l_curr_bv_id := null;
           end;
        else
        -- looking for APPROVED REVENUE BUDGET plan type
           begin
              select bv.budget_version_id
          into l_curr_bv_id
          from pa_proj_fp_options po,
           pa_budget_versions bv
          where po.project_id = p_project_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            bv.approved_rev_plan_type_flag = 'Y' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_flag = 'Y';
           exception
          when NO_DATA_FOUND then
              l_curr_bv_id := -1;
           end;
        end if; -- l_fin_plan_pref_code
    end if;



    if l_curr_bv_id is not null then
      -- Check if budget line exists for task, resource and uom
        open bud_line_exists_cur;
    fetch bud_line_exists_cur into l_number;
    if bud_line_exists_cur%notfound then
       l_quantity :=null;
    else
      begin
/* Bug 5144013 : Changed the following select queries to refer
   to new entity pa_resource_asgn_curr instead of pa_budget_lines.
   This is done as part of merging the MRUP3 changes done in 11i into R12.

         if p_amount = 'QUANTITY' THEN
        select total_display_quantity into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_curr_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount ='RAW_COST' then

        select total_txn_raw_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_curr_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount = 'BURDENED_COST' then
        select total_txn_burdened_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_curr_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         elsif p_amount = 'REVENUE' then
        select total_txn_revenue into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_curr_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         else
            l_quantity := null;
         end if; */
       -- Commented above code and added below for Bug# 6453050
        select total_display_quantity
	      ,total_txn_raw_cost
	      ,total_txn_burdened_cost
	      ,total_txn_revenue
         into l_quantity
	      ,l_txn_raw_cost
	      ,l_txn_burdened_cost
	      ,l_txn_revenue
         from pa_resource_asgn_curr rac,
              pa_resource_assignments pra
        where rac.budget_version_id = l_curr_bv_id
	and   pra.project_id = p_project_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

        if    p_amount = 'QUANTITY' THEN
               l_amount := l_quantity;
        elsif p_amount ='RAW_COST' then
               l_amount := l_txn_raw_cost;
        elsif p_amount = 'BURDENED_COST' then
               l_amount := l_txn_burdened_cost;
	elsif p_amount = 'REVENUE' then
               l_amount := l_txn_revenue;
	else
               l_amount := null;
	end if;

      exception
         when no_data_found then
           l_amount :=to_number(null); -- Modified for Bug# 6453050
      end;
    end if;  --  if bud_line_exists_cur%notfound

    close bud_line_exists_cur;


     end if;  --if p_curr_budget_version_id is not null
     return l_amount; -- Modified for Bug# 6453050
EXCEPTION
   when others then
        return  to_number(null);

END;


/* =================================================================================
  This function is used is FPM's  Budget and Forecasting webadi download query to
  get the period amounts  of the original baselined plan version
=======================================================================================*/
FUNCTION get_original_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER
IS
   l_quantity number :=null;
   l_number   number;
   l_orig_bv_id  number :=null;

   cursor bud_line_exists_cur is
       select 1
       from pa_budget_lines pbl, pa_resource_assignments pra
       where pra.project_id = p_project_id
       and   pra.task_id = p_task_id
       and pra.resource_list_member_id = p_resource_list_member_id
       and pra.unit_of_measure =  p_uom
       and pra.resource_assignment_id = pbl.resource_assignment_id
       and pra.budget_version_id = pbl.budget_version_id
       and pbl.budget_version_id = l_orig_bv_id;
BEGIN

    /*Derive the Original Budget Version Id using following logic
         If p_plan_class_code is BUDGET :
            original_version_id = original baselined version of same plan type
        If p_plan_class_code is FORECAST :
            original_version_id = original baselined version of APPROVED BUDGET plan type
    */
    if  p_plan_class_code = 'BUDGET' then
        begin
        select pbv.budget_version_id
        into  l_orig_bv_id
        from pa_budget_versions pbv,
             pa_proj_fp_options pfo
        where pfo.fin_plan_type_id = p_fin_plan_type_id
        and   pfo.project_id = p_project_id
            and   pfo.fin_plan_option_level_code = 'PLAN_VERSION'
            and   pfo.fin_plan_preference_code = p_fin_plan_preference_code
        and   pfo.fin_plan_version_id = pbv.budget_version_id
            and   pbv.current_original_flag = 'Y';
    exception
       when no_data_found then
           l_orig_bv_id := null;
    end;
    elsif p_plan_class_code = 'FORECAST' then
       if p_fin_plan_preference_code = 'COST_ONLY' then
       -- looking for APPROVED COST BUDGET plan type
          begin
            select bv.budget_version_id
          into l_orig_bv_id
          from pa_proj_fp_options po,
           pa_budget_versions bv
          where po.project_id = p_project_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            bv.approved_cost_plan_type_flag = 'Y' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_original_flag = 'Y';
          exception
        when NO_DATA_FOUND then
            l_orig_bv_id := null;
          end;
      elsif p_fin_plan_preference_code = 'REVENUE_ONLY' then
        -- looking for APPROVED REVENUE BUDGET plan type
          begin
            select bv.budget_version_id
          into l_orig_bv_id
          from pa_proj_fp_options po,
           pa_budget_versions bv
          where po.project_id = p_project_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            bv.approved_rev_plan_type_flag = 'Y' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_original_flag = 'Y';
          exception
        when NO_DATA_FOUND then
            l_orig_bv_id := null;
          end;
      else
        -- looking for APPROVED COST AND REVENUE BUDGET plan type
        begin
          select bv.budget_version_id
        into l_orig_bv_id
        from pa_proj_fp_options po,
         pa_budget_versions bv
        where po.project_id = p_project_id and
          po.fin_plan_option_level_code = 'PLAN_VERSION' and
              bv.approved_cost_plan_type_flag = 'Y' and
          bv.approved_rev_plan_type_flag = 'Y' and
          po.fin_plan_version_id = bv.budget_version_id and
          bv.current_original_flag = 'Y';
        exception
      when NO_DATA_FOUND then
            l_orig_bv_id := null;
        end;
      end if; -- l_fin_plan_pref_code
    end if;  --p_plan_class_code

    if l_orig_bv_id is not null then
      -- Check if budget line exists for task, resource and uom
        open bud_line_exists_cur;
    fetch bud_line_exists_cur into l_number;
    if bud_line_exists_cur%notfound then
       l_quantity :=null;
    else
        begin
/* Bug 5144013 : Changed the following select queries to refer
   to new entity pa_resource_asgn_curr instead of pa_budget_lines.
   This is done as part of merging the MRUP3 changes done in 11i into R12.
*/
         if p_amount = 'QUANTITY' THEN
        select total_display_quantity into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_orig_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount ='RAW_COST' then

        select total_txn_raw_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_orig_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount = 'BURDENED_COST' then
        select total_txn_burdened_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_orig_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         elsif p_amount = 'REVENUE' then
        select total_txn_revenue into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_orig_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         else
            l_quantity := null;
         end if;  -- p_amount endif

      exception
         when no_data_found then
            l_quantity :=to_number(null);
      end;
    end if; -- bud_line_exists_cur%notfound

    close bud_line_exists_cur;


     end if; --  if p_orig_budget_version_id is not null
     return l_quantity;
EXCEPTION
   when others then
        return  to_number(null);

END;


/* =================================================================================
  This function is used is FPM's  Budget and Forecasting webadi download query to
  get the period amounts of the prior forecast plan version
=======================================================================================*/
FUNCTION get_prior_forecast_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER
IS
   l_quantity number :=null;
   l_number   number;
   l_pf_bv_id  number :=null;

   cursor bud_line_exists_cur is
       select 1
       from pa_budget_lines pbl, pa_resource_assignments pra
       where pra.project_id = p_project_id
       and   pra.task_id = p_task_id
       and pra.resource_list_member_id = p_resource_list_member_id
       and pra.unit_of_measure =  p_uom
       and pra.resource_assignment_id = pbl.resource_assignment_id
       and pra.budget_version_id = pbl.budget_version_id
       and pbl.budget_version_id = l_pf_bv_id;
BEGIN

    /*Derive the Prior Forecast Budget Version Id using following logic
         If p_plan_class_code is BUDGET :
            No Need to derive as Prior Forecast amounts are not going to be shown in
        Periodic Budget Layout in FP.M Budget and Forecasting WebADI
        If p_plan_class_code is FORECAST :
            x_prior_fcst_version_id = current baselined version of same plan type
    */
    if  p_plan_class_code = 'BUDGET' then
        return to_number(null);
    elsif p_plan_class_code = 'FORECAST' then
        begin
        select pbv.budget_version_id
        into  l_pf_bv_id
        from pa_budget_versions pbv,
             pa_proj_fp_options pfo
        where pfo.fin_plan_type_id = p_fin_plan_type_id
        and   pfo.project_id = p_project_id
            and   pfo.fin_plan_option_level_code = 'PLAN_VERSION'
            and   pfo.fin_plan_preference_code = p_fin_plan_preference_code
        and   pfo.fin_plan_version_id = pbv.budget_version_id
            and   pbv.current_flag = 'Y';
    exception
       when no_data_found then
           l_pf_bv_id := null;
    end;
    end if;  --p_plan_class_code

    if l_pf_bv_id is not null then
      -- Check if budget line exists for task, resource and uom
        open bud_line_exists_cur;
    fetch bud_line_exists_cur into l_number;
    if bud_line_exists_cur%notfound then
       l_quantity :=null;
    else
        begin
/* Bug 5144013 : Changed the following select queries to refer
   to new entity pa_resource_asgn_curr instead of pa_budget_lines.
   This is done as part of merging the MRUP3 changes done in 11i into R12.
*/
         if p_amount = 'QUANTITY' THEN
        select total_display_quantity into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_pf_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount ='RAW_COST' then

        select total_txn_raw_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_pf_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;

         elsif p_amount = 'BURDENED_COST' then
        select total_txn_burdened_cost into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_pf_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         elsif p_amount = 'REVENUE' then
        select total_txn_revenue into l_quantity
            from pa_resource_asgn_curr rac,
             pa_resource_assignments pra
        where rac.budget_version_id = l_pf_bv_id
        and   pra.budget_version_id = rac.budget_version_id
        and   pra.task_id = p_task_id
        and   pra.resource_list_member_id = p_resource_list_member_id
        and   pra.unit_of_measure =  p_uom
        and   pra.resource_assignment_id = rac.resource_assignment_id
        and   rac.txn_currency_code = p_txn_curr_code;
         else
            l_quantity := null;
         end if;  -- p_amount endif

      exception
         when no_data_found then
            l_quantity :=to_number(null);
      end;
    end if; -- bud_line_exists_cur%notfound

    close bud_line_exists_cur;


     end if; --  if p_orig_budget_version_id is not null
     return l_quantity;
EXCEPTION
   when others then
        return  to_number(null);

END;


/* =================================================================================
  This function is used is FPM's Budget and Forecasting webadi download query to get the
  period amounts for the following amount types: RAW_COST_RATE,BURDENED_COST_RATE,BILL_RATE,
  'TOTAL_QTY''FCST_QTY',TOTAL_RAW_COST,FCST_RAW_COST,TOTAL_REV,FCST_REV,TOTAL_BURDENED_COST,
  FCST_BURDENED_COST,ACTUAL_QTY,ACTUAL_RAW_COST,ACTUAL_BURD_COST,ACTUAL_REVENUE,ETC_QTY,
  ETC_RAW_COST,ETC_BURDENED_COST,ETC_REVENUE
=======================================================================================*/
/* Bug 5144013: The following changes are made as part of merging the MRUP3 changes done in 11i into R12,
                a. display_quantity from pa_budget_lines is refered instead of quantity when p_amount_code
                   is TOTAL_QTY or FCST_QTY.
                b. Rates are shown only when the rate_based_flag of the resource assignment is 'Y'.
*/
FUNCTION get_period_amounts(
                     p_budget_version_id           NUMBER,
                     p_amount_code                 VARCHAR2,
                     p_resource_assignment_id      pa_budget_lines.resource_assignment_id%TYPE,
             p_txn_currency_code           pa_budget_lines.txn_currency_code%TYPE,
             p_prd_start_date              DATE,
             p_prd_end_date        DATE,
             preceding_date                DATE,
             succedeing_date               DATE)
return number
is
  l_return NUMBER :=null;
begin
   if (p_prd_start_date is null and p_prd_end_date is null)  and (preceding_date is null and succedeing_date is  null) then
         return to_number(null);
   end if;

     select decode(p_amount_code,'RAW_COST_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                              'ETC_RAW_COST_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                   'BURDENED_COST_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                  'ETC_BURDENED_COST_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                   'BILL_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                  'ETC_BILL_RATE',DECODE(pra.rate_based_flag,'Y',(sum((decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                       decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                        ((nvl(bl.quantity,0) - nvl(bl.init_quantity,0))*nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
                                                   /decode(sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                     decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                       (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))),0, to_number(null)
                                                       ,sum(decode(nvl(bl.quantity,0) - nvl(bl.init_quantity,0),0,to_number(null),
                                                          decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,to_number(null),
                                                               (nvl(bl.quantity,0) - nvl(bl.init_quantity,0))))))),NULL),
                  'TOTAL_QTY',sum(bl.display_quantity),
                  'FCST_QTY',sum(bl.display_quantity),
                  'TOTAL_RAW_COST' ,sum(bl.txn_raw_cost),
                  'FCST_RAW_COST' ,sum(bl.txn_raw_cost),
                  'TOTAL_REV' ,sum(bl.txn_revenue),
                  'FCST_REVENUE' ,sum(bl.txn_revenue),
                  'TOTAL_BURDENED_COST' ,sum(bl.txn_burdened_cost),
                  'FCST_BURDENED_COST' ,sum(bl.txn_burdened_cost),
                  'ACTUAL_QTY',sum(bl.init_quantity),
                  'ACTUAL_RAW_COST',sum(bl.txn_init_raw_cost),
                  'ACTUAL_BURD_COST',sum(bl.txn_init_burdened_cost),
                  'ACTUAL_REVENUE',sum(bl.txn_init_revenue),
                  'ETC_QTY',DECODE(sum(bl.display_quantity),null,null,sum(bl.quantity-nvl(bl.init_quantity,0))),
                  'ETC_RAW_COST',sum(bl.txn_raw_cost-nvl(bl.txn_init_raw_cost,0)),
                  'ETC_BURDENED_COST',sum(bl.txn_burdened_cost-nvl(bl.txn_init_burdened_cost,0)),
                  'ETC_REVENUE', sum(bl.txn_revenue-nvl(bl.txn_init_revenue,0)))
   into l_return
   from pa_budget_lines bl,
        pa_resource_assignments pra
   where bl.budget_version_id = p_budget_version_id
   and bl.resource_assignment_id =  p_resource_assignment_id
   and bl.txn_currency_code =  p_txn_currency_code
   and pra.resource_assignment_id = bl.resource_assignment_id
   and ((p_prd_start_date is not null and p_prd_end_date is not null and (decode(bl.start_date,p_prd_start_date,1,
              decode(bl.end_date,p_prd_end_date,1,
                     decode((((p_prd_end_date-bl.end_date)/(abs(p_prd_end_date-bl.end_date)))*((bl.start_date-p_prd_start_date)/(abs(bl.start_date-p_prd_start_date)))),-1,0,1)))=1))
     or
     (p_prd_start_date is null and p_prd_end_date is  null and decode(preceding_date,null,decode(((bl.start_date-succedeing_date)/abs(bl.start_date-succedeing_date)),1,1,0),
                                                                                           decode(((bl.end_date-preceding_date)/abs(bl.end_date-preceding_date)),-1,1,0))=1))
   GROUP BY pra.rate_based_flag;

  /*if l_return is null then
     l_return :=0;
  end if;*/ --Commented for bug 4365889 Issue# 8

  return l_return;

exception
   when no_data_found then
       return to_number(null);
end;



END PA_FP_WEBADI_UTILS;

/
