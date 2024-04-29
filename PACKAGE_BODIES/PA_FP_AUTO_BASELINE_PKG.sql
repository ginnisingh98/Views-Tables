--------------------------------------------------------
--  DDL for Package Body PA_FP_AUTO_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_AUTO_BASELINE_PKG" AS
/* $Header: PAFPABPB.pls 120.3 2005/09/23 12:29:09 rnamburi noship $ */

g_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_AUTO_BASELINE_PKG';

/*==============================================================================
   This api would be calling by the billing code to create a baselined version
   based on the funding lines when automatic baseline feature is enabled for
   the project.
 ===============================================================================*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE CREATE_BASELINED_VERSION
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_funding_level_code      IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_version_name            IN      pa_budget_versions.version_name%TYPE
     ,p_description             IN      pa_budget_versions.description%TYPE
     ,p_funding_bl_tab          IN      pa_fp_auto_baseline_pkg.funding_bl_tab
    -- Start of additional columns for Bug :- 2634900
     ,p_ci_id                   IN      pa_budget_versions.ci_id%TYPE                    --:= NULL
     ,p_est_proj_raw_cost       IN      pa_budget_versions.est_project_raw_cost%TYPE     --:= NULL
     ,p_est_proj_bd_cost        IN      pa_budget_versions.est_project_burdened_cost%TYPE--:= NULL
     ,p_est_proj_revenue        IN      pa_budget_versions.est_project_revenue%TYPE      --:= NULL
     ,p_est_qty                 IN      pa_budget_versions.est_quantity%TYPE             --:= NULL
     ,p_est_equip_qty           IN      pa_budget_versions.est_equipment_quantity%TYPE    -- FP.M
     ,p_impacted_task_id        IN      pa_tasks.task_id%TYPE                            --:= NULL
     ,p_agreement_id            IN      pa_budget_versions.agreement_id%TYPE             --:= NULL
    -- End of additional columns for Bug :- 2634900
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE      --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
-- Bug Fix: 4569365. Removed MRC code.
-- l_calling_context               pa_mrc_finplan.g_calling_module%TYPE; /* Bug# 2674353 */
   l_calling_context            VARCHAR2(30) ;

l_uncateg_resource_list_id    pa_proj_fp_options.cost_resource_list_id%TYPE;
l_uncateg_rlm_id        pa_resource_assignments.resource_list_member_id%TYPE;
l_uncateg_resource_id         pa_resource_list_members.resource_id%TYPE;
l_uncateg_trk_as_labor_flg    pa_resource_list_members.track_as_labor_flag%TYPE;
l_err_code              pa_debug.G_Err_Code%TYPE;
l_err_stage             pa_debug.g_err_stage%TYPE;

l_plan_in_mc_flag       pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_budget_lines_tab            pa_fin_plan_pvt.budget_lines_tab;

l_project_currency_code       pa_projects_all.project_currency_code%TYPE;
l_projfunc_currency_code      pa_projects_all.projfunc_currency_code%TYPE;
l_dummy_currency_code         pa_projects_all.projfunc_currency_code%TYPE;

l_fp_options_id               pa_proj_fp_options.proj_fp_options_id%TYPE;
l_baselined_version_id        pa_budget_versions.budget_version_id%TYPE;
l_record_version_number       pa_budget_versions.record_version_number%TYPE;
l_orig_record_version_number  pa_budget_versions.record_version_number%TYPE;
l_created_version_id          pa_budget_versions.budget_version_id%TYPE;

l_fp_mc_cols                  pa_proj_fp_options_pub.FP_MC_COLS;


l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(1);
l_debug_mode                    VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_fc_version_created_flag       VARCHAR2(1);

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_AUTO_BASELINE_PKG.CREATE_AUTO_BASELINE_VERSION');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if project id or plan type id or plan level code
      --is null

      IF (p_project_id is null or p_fin_plan_type_id is null or p_version_name is null
          or p_funding_level_code not in (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT,
                                     PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP))
      THEN

                pa_debug.g_err_stage:= 'project id = '|| p_project_id ;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                pa_debug.g_err_stage:= 'plan type id = '|| p_fin_plan_type_id;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

            pa_debug.g_err_stage:= 'finplan level code = '|| p_funding_level_code;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      pa_debug.g_err_stage:= 'Input parameters validated';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

        l_calling_context               :=   PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE; /* Bug# 2674353 */

      pa_debug.g_err_stage:= 'Get the uncategorized resource list id';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      PA_GET_RESOURCE.Get_Uncateg_Resource_Info( p_resource_list_id        => l_uncateg_resource_list_id
                                                  ,p_resource_list_member_id => l_uncateg_rlm_id
                                      ,p_resource_id       => l_uncateg_resource_id
                                      ,p_track_as_labor_flag     => l_uncateg_trk_as_labor_flg
                                      ,p_err_code                => l_err_code
                                      ,p_err_stage               => l_err_stage
                                      ,p_err_stack               =>     PA_DEBUG.G_Err_Stack);

      pa_debug.g_err_stage:= 'uncategorized resource list id ' || l_uncateg_resource_list_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_debug.g_err_stage:= 'Determine the MC flag';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_budget_utils.Get_Project_Currency_Info
             (
                p_project_id                    => p_project_id
              , x_projfunc_currency_code        => l_projfunc_currency_code
              , x_project_currency_code         => l_project_currency_code
              , x_txn_currency_code             => l_dummy_currency_code
              , x_msg_count                     => x_msg_count
              , x_msg_data                      => x_msg_data
              , x_return_status                 => x_return_status
             );

      IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            pa_debug.g_err_stage:= 'Could not obtain currency info for the project';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;


      IF ( l_projfunc_currency_code <> l_project_currency_code) THEN
            l_plan_in_mc_flag := 'Y';
      ELSE
            l_plan_in_mc_flag := 'N';
      END IF;

      pa_debug.g_err_stage:= 'MC flag -> ' || l_plan_in_mc_flag;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;


      pa_debug.g_err_stage:= 'Get the currency attributes from the plan type';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      l_fp_options_id := pa_proj_fp_options_pub.get_fp_option_id( p_project_id      => p_project_id
                                                   ,p_plan_type_id    => p_fin_plan_type_id
                                                   ,p_plan_version_id => NULL );

      pa_debug.g_err_stage:= 'plan type option id is ' || l_fp_options_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      l_fp_mc_cols := pa_proj_fp_options_pub.Get_FP_Proj_Mc_Options(p_proj_fp_options_id => l_fp_options_id);


      pa_debug.g_err_stage:= 'Prepare the budget lines tab from funding lines tab';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;



      /* Review Comment - Included comment for system reference columns
         system_reference1 -> task_id
         system_reference2 -> resource_list_member_id
         system_reference4 -> unit_of_measure
         system_reference5 -> track_as_labor_flag
      */
      IF nvl(p_funding_bl_tab.last,0) > 0 THEN
            FOR i IN p_funding_bl_tab.first..p_funding_bl_tab.last LOOP
                  IF(p_funding_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT) THEN
                        l_budget_lines_tab(i).system_reference1         := 0;
                  ELSE
                        l_budget_lines_tab(i).system_reference1         := p_funding_bl_tab(i).task_id;
                  END IF;

                  l_budget_lines_tab(i).description               := p_funding_bl_tab(i).description;
                  IF(p_funding_bl_tab(i).start_date IS NULL) THEN
                        pa_debug.g_err_stage:= 'start date is null';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  ELSE
                        l_budget_lines_tab(i).start_date          := p_funding_bl_tab(i).start_date;
                  END IF;


                  /* In budget lines table the end date is a not null column. Hence including
                     the following validation */
                  IF(p_funding_bl_tab(i).end_date IS NULL) THEN                 --Included after UT.
                        pa_debug.g_err_stage:= 'end date is null';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  ELSE
                        l_budget_lines_tab(i).end_date                  := p_funding_bl_tab(i).end_date;
                  END IF;

                  --Commented after UT.
                  --l_budget_lines_tab(i).end_date                      := p_funding_bl_tab(i).end_date;

                  l_budget_lines_tab(i).projfunc_revenue                := p_funding_bl_tab(i).projfunc_revenue;
                  l_budget_lines_tab(i).project_revenue                 := p_funding_bl_tab(i).project_revenue;
                  l_budget_lines_tab(i).system_reference2               := l_uncateg_rlm_id;
                  l_budget_lines_tab(i).period_name               := NULL;
                  l_budget_lines_tab(i).quantity                        := NULL;
                  l_budget_lines_tab(i).system_reference4               := NULL;        /* Changed after ut */
                  l_budget_lines_tab(i).system_reference5               := 'N';         /* Changed after ut */
                  l_budget_lines_tab(i).txn_currency_code               := l_projfunc_currency_code;
                  l_budget_lines_tab(i).projfunc_raw_cost               := NULL;
                  l_budget_lines_tab(i).projfunc_burdened_cost          := NULL;
                  l_budget_lines_tab(i).txn_raw_cost              := NULL;
                  l_budget_lines_tab(i).txn_burdened_cost               := NULL;
                  l_budget_lines_tab(i).txn_revenue               := p_funding_bl_tab(i).projfunc_revenue;
                  l_budget_lines_tab(i).project_raw_cost                := NULL;
                  l_budget_lines_tab(i).project_burdened_cost           := NULL;
                  l_budget_lines_tab(i).change_reason_code        := NULL;
                  l_budget_lines_tab(i).attribute_category        := NULL;
                  l_budget_lines_tab(i).attribute1                := NULL;
                  l_budget_lines_tab(i).attribute2                := NULL;
                  l_budget_lines_tab(i).attribute4                := NULL;
                  l_budget_lines_tab(i).attribute5                := NULL;
                  l_budget_lines_tab(i).attribute6                := NULL;
                  l_budget_lines_tab(i).attribute7                := NULL;
                  l_budget_lines_tab(i).attribute8                := NULL;
                  l_budget_lines_tab(i).attribute9                := NULL;
                  l_budget_lines_tab(i).attribute10               := NULL;
                  l_budget_lines_tab(i).attribute11               := NULL;
                  l_budget_lines_tab(i).attribute12               := NULL;
                  l_budget_lines_tab(i).attribute13               := NULL;
                  l_budget_lines_tab(i).attribute14               := NULL;
                  l_budget_lines_tab(i).attribute15               := NULL;
                  l_budget_lines_tab(i).PROJFUNC_COST_RATE_TYPE         := l_fp_mc_cols.projfunc_cost_rate_type;
                  l_budget_lines_tab(i).PROJFUNC_COST_RATE_DATE_TYPE    := l_fp_mc_cols.projfunc_cost_rate_date_type;
                  l_budget_lines_tab(i).PROJFUNC_COST_RATE_DATE         := l_fp_mc_cols.projfunc_cost_rate_date;
                  l_budget_lines_tab(i).PROJFUNC_COST_EXCHANGE_RATE     := NULL;
                  l_budget_lines_tab(i).PROJFUNC_REV_RATE_TYPE          := l_fp_mc_cols.projfunc_rev_rate_type;
                  l_budget_lines_tab(i).PROJFUNC_REV_RATE_DATE_TYPE     := l_fp_mc_cols.projfunc_rev_rate_date_type;
                  l_budget_lines_tab(i).PROJFUNC_REV_RATE_DATE          := l_fp_mc_cols.projfunc_rev_rate_date;
                  l_budget_lines_tab(i).PROJFUNC_REV_EXCHANGE_RATE      := NULL;
                  l_budget_lines_tab(i).PROJECT_COST_RATE_TYPE          := l_fp_mc_cols.project_cost_rate_type;
                  l_budget_lines_tab(i).PROJECT_COST_RATE_DATE_TYPE     := l_fp_mc_cols.project_cost_rate_date_type;
                  l_budget_lines_tab(i).PROJECT_COST_RATE_DATE          := l_fp_mc_cols.project_cost_rate_date;
                  l_budget_lines_tab(i).PROJECT_COST_EXCHANGE_RATE      := NULL;
                  l_budget_lines_tab(i).PROJECT_REV_RATE_TYPE           := l_fp_mc_cols.project_rev_rate_type;
                  l_budget_lines_tab(i).PROJECT_REV_RATE_DATE_TYPE      := l_fp_mc_cols.project_rev_rate_date_type;
                  l_budget_lines_tab(i).PROJECT_REV_RATE_DATE           := l_fp_mc_cols.project_rev_rate_date;
                  l_budget_lines_tab(i).PROJECT_REV_EXCHANGE_RATE       := NULL;
                  l_budget_lines_tab(i).pm_product_code                 := NULL;
                  l_budget_lines_tab(i).pm_budget_line_reference        := NULL;
                  l_budget_lines_tab(i).quantity_source                 := PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M;
                  l_budget_lines_tab(i).raw_cost_source                 := PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M;
                  l_budget_lines_tab(i).burdened_cost_source            := PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M;
                  l_budget_lines_tab(i).revenue_source                  := PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M;
                  l_budget_lines_tab(i).resource_assignment_id          := -1;
            END LOOP;
      END IF;

      pa_debug.g_err_stage:= 'Calling pa_fin_plan_pvt.create_draft';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_fin_plan_pvt.create_draft
          ( p_project_id                    => p_project_id
           ,p_fin_plan_type_id              => p_fin_plan_type_id
           ,p_version_type                  => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
           ,p_calling_context               => l_calling_context
           ,p_time_phased_code              => PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_N
           ,p_resource_list_id              => l_uncateg_resource_list_id
           ,p_fin_plan_level_code           => p_funding_level_code
           ,p_plan_in_mc_flag               => l_plan_in_mc_flag
           ,p_version_name                  => p_version_name
           ,p_description                   => p_description
           ,p_change_reason_code            => NULL
           ,p_raw_cost_flag                 => 'N'
           ,p_burdened_cost_flag            => 'N'
           ,p_cost_qty_flag                 => 'N'
           ,p_revenue_flag                  => 'Y'
      /* Bug# 2676365 - For autobaseline case, the revenue qty should be enterable
             ,p_revenue_qty_flag            => 'N'               Bug# 2676365 */
             ,p_revenue_qty_flag            => 'Y'
           ,p_all_qty_flag                  => 'N'
           ,p_attribute_category            => NULL
           ,p_attribute1                    => NULL
           ,p_attribute2                    => NULL
           ,p_attribute3                    => NULL
           ,p_attribute4                    => NULL
           ,p_attribute5                    => NULL
           ,p_attribute6                    => NULL
           ,p_attribute7                    => NULL
           ,p_attribute8                    => NULL
           ,p_attribute9                    => NULL
           ,p_attribute10                   => NULL
           ,p_attribute11                   => NULL
           ,p_attribute12                   => NULL
           ,p_attribute13                   => NULL
           ,p_attribute14                   => NULL
           ,p_attribute15                   => NULL
           ,x_budget_version_id             => l_created_version_id
           ,p_projfunc_cost_rate_type       => l_fp_mc_cols.projfunc_cost_rate_type
           ,p_projfunc_cost_rate_date_type  => l_fp_mc_cols.projfunc_cost_rate_date_type
           ,p_projfunc_cost_rate_date       => l_fp_mc_cols.projfunc_cost_rate_date
           ,p_projfunc_rev_rate_type        => l_fp_mc_cols.projfunc_rev_rate_type
           ,p_projfunc_rev_rate_date_type   => l_fp_mc_cols.projfunc_rev_rate_date_type
           ,p_projfunc_rev_rate_date        => l_fp_mc_cols.projfunc_rev_rate_date
           ,p_project_cost_rate_type        => l_fp_mc_cols.project_cost_rate_type
           ,p_project_cost_rate_date_type   => l_fp_mc_cols.project_cost_rate_date_type
           ,p_project_cost_rate_date        => l_fp_mc_cols.project_cost_rate_date
           ,p_project_rev_rate_type         => l_fp_mc_cols.project_rev_rate_type
           ,p_project_rev_rate_date_type    => l_fp_mc_cols.project_rev_rate_date_type
           ,p_project_rev_rate_date         => l_fp_mc_cols.project_rev_rate_date
           ,p_pm_product_code               => NULL
           ,p_pm_budget_reference           => NULL
           ,p_budget_lines_tab              => l_budget_lines_tab
           -- Start of additional columns for Bug :- 2634900
           ,p_ci_id                         => p_ci_id
           ,p_est_proj_raw_cost             => p_est_proj_raw_cost
           ,p_est_proj_bd_cost              => p_est_proj_bd_cost
           ,p_est_proj_revenue              => p_est_proj_revenue
           ,p_est_qty                       => p_est_qty
           ,p_est_equip_qty                 => p_est_equip_qty
           ,p_impacted_task_id              => p_impacted_task_id
           ,p_agreement_id                  => p_agreement_id
           -- End of additional columns for Bug :- 2634900

           --Added the following parameters. These parameters are added to create_draft for AMG
           ,p_create_new_curr_working_flag  => 'N'
           ,p_replace_current_working_flag  => 'Y'
           ,x_return_status                 => x_return_status
           ,x_msg_count                     => x_msg_count
           ,x_msg_data                      => x_msg_data  );

      IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            pa_debug.g_err_stage:= 'Error Calling Create_Draft';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      ELSE
            x_budget_version_id := l_created_version_id;
            pa_debug.g_err_stage:= 'successful call of Create_Draft. Created Version id : ' || l_created_version_id;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
      END IF;

      /* Review Comment */
      l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                      (p_budget_version_id => l_created_version_id);

      /* The version needs to be baselined only if the ci_id is null - Bug 2672654 */
      IF (p_ci_id is null) THEN
            pa_debug.g_err_stage:= 'This is not a control item version - Going ahead to baseline';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            pa_debug.g_err_stage:= 'Get details of the existing baselined version';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
               p_project_id           => p_project_id
              ,p_fin_plan_type_id     => p_fin_plan_type_id
              ,p_version_type         => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
              ,x_fp_options_id        => l_fp_options_id
              ,x_fin_plan_version_id  => l_baselined_version_id
              ,x_return_status        => x_return_status
              ,x_msg_count            => x_msg_count
              ,x_msg_data             => x_msg_data );

            IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                  pa_debug.g_err_stage:= 'Error Getting current baselined version info';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            pa_debug.g_err_stage:= 'current baselined version id -> ' || l_baselined_version_id;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;



            l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                   (p_budget_version_id => l_created_version_id);

            IF l_baselined_version_id is not null THEN
              l_orig_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                        (p_budget_version_id => l_baselined_version_id);
            END IF;
                -- Bug Fix: 4569365. Removed MRC code.
                -- PA_MRC_FINPLAN.G_CALLING_MODULE :=   l_calling_context; /* Bug 2881994 */

            PA_FIN_PLAN_PUB.Baseline(
                 p_project_id                    => p_project_id
                 ,p_budget_version_id            => l_created_version_id
                 ,p_record_version_number        => l_record_version_number        -- Changed after Review.
                 ,p_orig_budget_version_id       => l_baselined_version_id
                 ,p_orig_record_version_number   => l_orig_record_version_number   -- Changed after Review.
                     ,x_fc_version_created_flag      => l_fc_version_created_flag
                 ,x_return_status                => x_return_status
                 ,x_msg_count                    => x_msg_count
                 ,x_msg_data             => x_msg_data );
                -- Bug Fix: 4569365. Removed MRC code.
                -- PA_MRC_FINPLAN.G_CALLING_MODULE :=   null; /* Bug 2881994 */

            IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                  pa_debug.g_err_stage:= 'Error baselining version - Version id->' || l_created_version_id;
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

      ELSE
            pa_debug.g_err_stage:= 'This is a control item version - Skipped baseline';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
      END IF;

      pa_debug.g_err_stage:= 'Exiting CREATE_AUTO_BASELINE_VERSION';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

  EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           x_budget_version_id := NULL; --NOCOPY
           x_return_status := FND_API.G_RET_STS_ERROR;
           -- Bug Fix: 4569365. Removed MRC code.
           -- PA_MRC_FINPLAN.G_CALLING_MODULE :=   null; /* Bug 2881994 */
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

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

      WHEN others THEN

          x_budget_version_id := NULL; --NOCOPY
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          -- Bug Fix: 4569365. Removed MRC code.
          -- PA_MRC_FINPLAN.G_CALLING_MODULE :=   null; /* Bug 2881994 */
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_AUTO_BASELINE_PKG'
                                  ,p_procedure_name  => 'CREATE_BASELINED_VERSION');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('CREATE_BASELINED_VERSION: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END CREATE_BASELINED_VERSION;

END PA_FP_AUTO_BASELINE_PKG;

/
