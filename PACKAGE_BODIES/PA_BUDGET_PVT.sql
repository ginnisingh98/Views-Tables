--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_PVT" as
--$Header: PAPMBUVB.pls 120.32.12010000.9 2010/01/15 08:07:20 sugupta ship $
--package constants to be used in error messages
G_PKG_NAME          CONSTANT VARCHAR2(30)   := 'PA_BUDGET_PVT';

--package constants to be used during updates
G_USER_ID         CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID        CONSTANT NUMBER := FND_GLOBAL.login_id;

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception         EXCEPTION; /* FPB2 */

g_module_name   VARCHAR2(100) := 'pa.plsql.PA_BUDGET_PVT';

-- Cursor to get the budget amount code of the budget type passed
CURSOR  l_budget_amount_code_csr
       (c_budget_type_code    VARCHAR2 )
IS
SELECT  budget_amount_code
FROM    pa_budget_types
WHERE   budget_type_code = c_budget_type_code;

-- Cursor to validate the change reason code
CURSOR l_budget_change_reason_csr ( c_change_reason_code VARCHAR2 )
IS
SELECT 'x'
FROM   pa_lookups
WHERE  lookup_type = 'BUDGET CHANGE REASON'
AND    lookup_code = c_change_reason_code;

--Bug 2871603: Added the following PLSQL table to remove build dependency.
TYPE l_txn_currency_code_tbl_typ IS TABLE OF
                pa_budget_lines.TXN_CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER ;

--This record type will contain key and a value. A pl/sql tbl of this record type can be declared and it can be
--used for different purposes. One such case is : if its required to get the wbs level for a task id at many
--places in the code then instead of firing a select each time we can fetch it and store in this record. The key
--will be the task id and the value will be top task id.
--Created for bug 3678314
TYPE key_value_rec IS RECORD
(key                          NUMBER
,value                        VARCHAR2(30));

TYPE key_value_rec_tbl_type IS TABLE OF key_value_rec
      INDEX BY BINARY_INTEGER;

-- This procedure accepts the rate types at the plan version level and plan type level
-- FALSE is returned if the rate type at plan type is not User and the rate type at
-- plan version is user.TRUE is returned otherwise
-- Created        19-FEB-03          sgoteti
--
PROCEDURE valid_rate_type
( p_pt_project_cost_rate_type   IN      pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_pt_project_rev_rate_type    IN      pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_pt_projfunc_cost_rate_type  IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_pt_projfunc_rev_rate_type   IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_pv_project_cost_rate_type   IN      pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_pv_project_rev_rate_type    IN      pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_pv_projfunc_cost_rate_type  IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_pv_projfunc_rev_rate_type   IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,x_is_rate_type_valid          OUT     NOCOPY BOOLEAN --File.Sql.39 bug 4440895
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

      l_debug_mode                     VARCHAR2(1);
      l_module_name                    VARCHAR2(80);
      l_debug_level3          CONSTANT NUMBER := 3;
BEGIN

      x_msg_count :=0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'valid_rate_type: ' || g_module_name;

      IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'valid_rate_type',
                                    p_debug_mode => l_debug_mode );
      END IF;

      x_is_rate_type_valid := TRUE;

      IF (nvl(p_pv_project_cost_rate_type,'-99') = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER AND
          nvl(p_pt_project_cost_rate_type,'-99') <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER ) THEN

            x_is_rate_type_valid := FALSE;

      END IF;

      IF (nvl(p_pv_project_rev_rate_type,'-99') = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER AND
          nvl(p_pt_project_rev_rate_type,'-99') <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER ) THEN

            x_is_rate_type_valid := FALSE;

      END IF;

      IF (nvl(p_pv_projfunc_cost_rate_type,'-99') = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER AND
          nvl(p_pt_projfunc_cost_rate_type,'-99') <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER ) THEN

            x_is_rate_type_valid := FALSE;

      END IF;

      IF (nvl(p_pv_projfunc_rev_rate_type,'-99') = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER AND
          nvl(p_pt_projfunc_rev_rate_type,'-99') <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER ) THEN

            x_is_rate_type_valid := FALSE;

      END IF;

      IF(l_debug_mode='Y') THEN

            pa_debug.g_err_stage := 'Leaving valid_rate_type';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.reset_curr_function;
      END IF;
EXCEPTION

      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_BUDGET_PUB'
            ,p_procedure_name  => 'VALID_RATE_TYPE'
            ,p_error_text      => sqlerrm);

            IF l_debug_mode = 'Y' THEN
                  pa_debug.G_Err_Stack := SQLERRM;
                  pa_debug.write( l_module_name,pa_debug.G_Err_Stack,4);
                  pa_debug.reset_curr_function;
 	    END IF;
            RAISE;


END valid_rate_type;



-- This API is created as part of FinPlan Development. All header level validations are moved
-- from create_draft_budget API to this API. This API handles validations of versions in new
-- as well as old models.

-- Created        19-FEB-03          sgoteti

PROCEDURE Validate_Header_Info
( p_api_version_number            IN        NUMBER
 ,p_budget_version_name           IN        VARCHAR2       /* Introduced for bug 3133930*/
 ,p_init_msg_list                 IN        VARCHAR2
 ,px_pa_project_id                IN  OUT   NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
 ,p_pm_project_reference          IN        pa_projects_all.pm_project_reference%TYPE
 ,p_pm_product_code               IN        pa_projects_all.pm_product_code%TYPE
 ,p_budget_type_code              IN        pa_budget_types.budget_type_code%TYPE
 ,p_entry_method_code             IN        pa_budget_entry_methods.budget_entry_method_code%TYPE
 ,px_resource_list_name           IN  OUT   NOCOPY pa_resource_lists_tl.name%TYPE --File.Sql.39 bug 4440895
 ,px_resource_list_id             IN  OUT   NOCOPY pa_resource_lists_all_bg.resource_list_id%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_type_id             IN  OUT   NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_type_name           IN  OUT   NOCOPY pa_fin_plan_types_tl.name%TYPE --File.Sql.39 bug 4440895
 ,px_version_type                 IN  OUT   NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_level_code          IN  OUT   NOCOPY pa_proj_fp_options.cost_fin_plan_level_code%TYPE --File.Sql.39 bug 4440895
 ,px_time_phased_code             IN  OUT   NOCOPY pa_proj_fp_options.cost_time_phased_code%TYPE --File.Sql.39 bug 4440895
 ,px_plan_in_multi_curr_flag      IN  OUT   NOCOPY pa_proj_fp_options.plan_in_multi_curr_flag%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_type      IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_date_typ  IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_date      IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_type       IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_date_typ   IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_date       IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_type       IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_date_typ   IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_date       IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_type        IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_date_typ    IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_date        IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_raw_cost_flag                IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_burdened_cost_flag           IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_revenue_flag                 IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_cost_qty_flag                IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_revenue_qty_flag             IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_all_qty_flag                 IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_create_new_curr_working_flag  IN        VARCHAR2
 ,p_replace_current_working_flag  IN        VARCHAR2
 ,p_change_reason_code            IN        pa_budget_versions.change_reason_code%TYPE
 ,p_calling_module                IN        VARCHAR2
 ,p_using_resource_lists_flag     IN        VARCHAR2
 ,x_budget_amount_code            OUT       NOCOPY pa_budget_types.budget_amount_code%TYPE --Added for bug 4224464. --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                 OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

      -- Cursor to get the cost and revenue budget entry flags from the project type
      CURSOR  l_cost_rev_budget_entry_csr
            (c_project_id pa_projects.project_id%type)
      IS
      SELECT ppt.allow_cost_budget_entry_flag
            ,ppt.allow_rev_budget_entry_flag
      FROM   pa_project_types ppt
            ,pa_projects_all ppa
      WHERE  ppa.project_id = c_project_id
      AND    ppa.project_type = ppt.project_type;

      -- Cursor to get the details of the budget entry method passed
      CURSOR  l_budget_entry_method_csr
             (c_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
      IS
      SELECT *
      FROM   pa_budget_entry_methods
      WHERE  budget_entry_method_code = c_budget_entry_method_code
      AND    trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

      l_budget_entry_method_rec        pa_budget_entry_methods%rowtype;


      l_budget_amount_code             pa_budget_types.budget_amount_code%TYPE;

      -- Cursor to get the plan type details of the version being created. Created as part
      -- of changes due to fin plan in AMG
      CURSOR  l_proj_fp_options_csr
            ( c_project_id       pa_projects.project_id%TYPE
             ,c_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE)
      IS
      SELECT fin_plan_preference_code
            ,nvl(plan_in_multi_curr_flag,'N') plan_in_multi_curr_flag
            ,approved_rev_plan_type_flag
            ,projfunc_cost_rate_type
            ,projfunc_cost_rate_date_type
            ,projfunc_cost_rate_date
            ,projfunc_rev_rate_type
            ,projfunc_rev_rate_date_type
            ,projfunc_rev_rate_date
            ,project_cost_rate_type
            ,project_cost_rate_date_type
            ,project_cost_rate_date
            ,project_rev_rate_type
            ,project_rev_rate_date_type
            ,project_rev_rate_date
      FROM   pa_proj_fp_options
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    fin_plan_version_id IS NULL
      AND    fin_plan_option_level_code= PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

      l_proj_fp_options_rec           l_proj_fp_options_csr%ROWTYPE;

      -- Cursot to get the segment 1 of the project. Added baseline funding flag as part
      -- changes due to finplan in AMG
      CURSOR l_amg_project_csr
            (c_project_id pa_projects_all.project_id%TYPE)
      IS
      SELECT segment1
            ,baseline_funding_flag
      FROM   pa_projects_all
      WHERE  project_id=c_project_id;

      l_amg_project_rec               l_amg_project_csr%ROWTYPE;

      -- Cursor to get the planning level ,resource list and time phasing from the plan type
      -- Added as part of changes due to finplan in AMG
      CURSOR l_plan_type_settings_csr
            ( c_project_id pa_projects.project_id%TYPE
             ,c_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE
             ,c_version_type VARCHAR2)

      IS
      SELECT decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_fin_plan_level_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_fin_plan_level_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_fin_plan_level_code) fin_plan_level_code
            ,decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_resource_list_id,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_resource_list_id,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_resource_list_id)  resource_list_id
            ,decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_time_phased_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_time_phased_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_time_phased_code)  time_phased_code
      FROM   pa_proj_fp_options
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    fin_plan_version_id IS NULL
      AND    fin_plan_option_level_code= PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

      l_plan_type_settings_rec        l_plan_type_settings_csr%ROWTYPE;



 -- Cursor to get the existing version details of the budget type code passed

      CURSOR l_budget_version_csr
            ( c_project_id NUMBER
             ,c_budget_type_code VARCHAR2  )
      IS
      SELECT budget_version_id
            ,budget_status_code
      FROM   pa_budget_versions
      WHERE  project_id = c_project_id
      AND    budget_type_code = c_budget_type_code
      AND    budget_status_code IN ('W','S')
      AND    ci_id IS NULL;         -- Bug # 3507156 --Added an extra clause ci_id IS NULL

      -- Cursor to get the details of the current working version in finplan model. Added
      -- as part of changes due to finplan in AMG
      CURSOR l_finplan_CW_ver_csr
           ( c_project_id NUMBER
            ,c_fin_plan_type_id VARCHAR2
            ,c_version_type VARCHAR2)
      IS
      SELECT budget_version_id
            ,budget_status_code
            ,record_version_number
            ,plan_processing_code
      FROM   pa_budget_versions
      WHERE  project_id = c_project_id
      AND    fin_plan_type_id = c_fin_plan_type_id
      AND    current_working_flag='Y'
      AND    version_type = c_version_type
      AND    budget_status_code IN ('W','S')
      AND    ci_id IS NULL;         -- Bug # 3507156 --Added an extra clause ci_id IS NULL


      l_finplan_CW_ver_rec       l_finplan_CW_ver_csr%ROWTYPE;

      -- Cursor to know whether a version exists for plan type created by upgrading the budget type
      -- which is given as input. Crated as part of changes due to finplan in AMG
      CURSOR  is_budget_type_upgraded_csr
            ( c_budget_type_code pa_budget_types.budget_type_code%TYPE
             ,c_project_id       pa_projects_all.project_id%TYPE)
      IS
      SELECT  'X'
      FROM    pa_fin_plan_types_b fin ,pa_proj_fp_options pfo
      WHERE   pfo.project_id=c_project_id
      AND     pfo.fin_plan_option_level_code=PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE   --AMG UT2
      AND     pfo.fin_plan_type_id = fin.fin_plan_type_id
      AND     fin.migrated_frm_bdgt_typ_code =  c_budget_type_code;

      l_budget_type_upgraded_rec       is_budget_type_upgraded_csr%ROWTYPE;

      -- Cursor to lock the version
      CURSOR l_lock_old_budget_csr( c_budget_version_id NUMBER )
      IS
      SELECT 'x'
      FROM   pa_budget_versions bv
            ,pa_resource_assignments ra
            ,pa_budget_lines bl
      WHERE  bv.budget_version_id = c_budget_version_id
      AND    bv.budget_version_id = ra.budget_version_id (+)
      AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
      AND    bv.ci_id IS NULL          -- Bug # 3507156 --Added an extra clause ci_id IS NULL

      FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

      -- Cursor used in validating the product code
      Cursor p_product_code_csr (c_pm_product_code IN VARCHAR2)
      Is
      Select 'X'
      from   pa_lookups
      where  lookup_type='PM_PRODUCT_CODE'
      and    lookup_code = c_pm_product_code;


      l_msg_count                      NUMBER := 0;
      l_data                           VARCHAR2(2000);
      l_msg_data                       VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_debug_mode                     VARCHAR2(1);
      l_function_allowed               VARCHAR2(1);
      l_resp_id                        NUMBER := 0;
      l_user_id                        NUMBER := 0;
      l_module_name                    VARCHAR2(80);

     -- <Patchset M:B and F impact changes : AMG:> -- Bug # 3507156
     -- Added the variable l_editable_flag for call to procedure pa_fin_plan_utils.Check_if_plan_type_editable

      l_editable_flag                  VARCHAR2(1);

      l_copy_conv_attr                 boolean;
      l_conv_attrs_to_be_validated     VARCHAR2(10);
      l_old_budget_version_id          pa_budget_versions.budget_version_id%TYPE;
      l_budget_status_code             pa_budget_versions.budget_status_code%TYPE;
      l_approved_fin_plan_type_id      pa_fin_plan_types_b.fin_plan_type_id%TYPE;

      l_allow_cost_budget_entry_flag   pa_project_types_all.allow_cost_budget_entry_flag%TYPE;
      l_allow_rev_budget_entry_flag    pa_project_types_all.allow_rev_budget_entry_flag%TYPE;

      -- Budget Integration Variables --------------------------
      l_fck_req_flag                   VARCHAR2(1) := NULL;
      l_bdgt_intg_flag                 VARCHAR2(1) := NULL;
      l_bdgt_ver_id                    NUMBER := NULL;
      l_encum_type_id                  NUMBER := NULL;
      l_balance_type                   VARCHAR2(1) := NULL;

      -- --------------------------------------------------------
      l_uncategorized_list_id          pa_resource_lists_all_bg.resource_list_id%TYPE;
      l_uncategorized_resid            pa_resource_list_members.resource_id%TYPE;
      l_err_code                       NUMBER;
      l_err_stage                      VARCHAR2(120);
      l_err_stack                      VARCHAR2(630);
      l_track_as_labor_flag            pa_resource_list_members.track_as_labor_flag%TYPE;
      l_period_type                    VARCHAR2(2);
      l_period_profile_id              pa_proj_period_profiles.period_profile_id%TYPE;
      l_start_period                   pa_proj_period_profiles.period_name1%TYPE;
      l_end_period                     pa_proj_period_profiles.profile_end_period_name%TYPE;
      l_security_ret_code              VARCHAR2(1);
      l_dummy                          VARCHAR2(1);
      l_debug_level2                   CONSTANT NUMBER := 2;
      l_debug_level3                   CONSTANT NUMBER := 3;
      l_debug_level4                   CONSTANT NUMBER := 4;
      l_debug_level5                   CONSTANT NUMBER := 5;
      l_pm_product_code                VARCHAR2(2) :='Z';

      -- Following variable will be set when atleast one error
      -- is reported while validating the input parameters
      -- passed by the user
      l_any_error_occurred_flag        VARCHAR2(1) :='N';

      l_multi_currency_billing_flag    pa_projects_all.multi_currency_billing_flag%TYPE;
      l_project_currency_code          pa_projects_all.project_currency_code%TYPE      ;
      l_projfunc_currency_code         pa_projects_all.projfunc_currency_code%TYPE     ;
      l_project_cost_rate_type         pa_projects_all.project_rate_type%TYPE          ;
      l_projfunc_cost_rate_type        pa_projects_all.projfunc_cost_rate_type%TYPE    ;
      l_project_bil_rate_type          pa_projects_all.project_bil_rate_type%TYPE      ;
      l_projfunc_bil_rate_type         pa_projects_all.projfunc_bil_rate_type%TYPE     ;
      l_uncategorized_rlmid            pa_resource_list_members.resource_list_member_id%TYPE;
      l_is_rate_type_valid             BOOLEAN;
      l_planning_level_lookup          CONSTANT VARCHAR2(30) := 'BUDGET ENTRY LEVEL';
      l_time_phasing_lookup            CONSTANT VARCHAR2(30) := 'BUDGET TIME PHASED TYPE';
      l_validate_mc_attributes         VARCHAR2(1);
      l_project_cost_exchange_rate     pa_budget_lines.project_cost_exchange_rate%TYPE;
      l_projfunc_cost_exchange_rate    pa_budget_lines.projfunc_cost_exchange_rate%TYPE;
      l_project_rev_exchange_rate      pa_budget_lines.project_rev_exchange_rate%TYPE;
      l_projfunc_rev_exchange_rate     pa_budget_lines.projfunc_rev_exchange_rate%TYPE;
      l_fin_plan_type_name             pa_fin_plan_types_tl.name%TYPE;
      l_context_info                   pa_fin_plan_types_tl.name%TYPE;

      l_called_from_agr_pub            VARCHAR2(1) := NULL;  -- Bug 3099706

      --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
      --Added extra parameters
      l_autobaseline_flag              VARCHAR2(1) := NULL;
      l_workplan_flag                  VARCHAR2(1) := NULL;
      l_exists                         VARCHAR2(1) := NULL;

      -- for bug 3954329
      l_res_list_migration_code        pa_resource_list_members.migration_code%TYPE  := FND_API.G_MISS_CHAR;
      l_targ_request_id                pa_budget_versions.request_id%TYPE;
      px_pa_project_id_in              pa_projects_all.project_id%TYPE;
      px_resource_list_id_in           pa_resource_lists_all_bg.resource_list_id%TYPE;
      px_fin_plan_type_id_in           pa_fin_plan_types_b.fin_plan_type_id%TYPE;

BEGIN

      --dbms_output.put_line('In validate header info');
      x_msg_count :=0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'validate_header_info: ' || g_module_name;

	  IF l_debug_mode = 'Y' THEN
        	pa_debug.set_curr_function( p_function   => 'validate_header_info',
                                    p_debug_mode => l_debug_mode );
                pa_debug.g_err_stage:= 'Validating input parameters';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                l_debug_level3);
          END IF;
      --dbms_output.put_line('About to validate budget type code and fin plan type id');

      -- Initialize the message table if requested.Moved this above as the messages will be added from
      -- this point.
      IF FND_API.TO_BOOLEAN( p_init_msg_list )
      THEN

        FND_MSG_PUB.initialize;

      END IF;



      -- Both Budget Type Code and Fin Plan Type Id should not be null
      IF ((p_budget_type_code IS NULL  OR
           p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )  AND
          (px_fin_plan_type_name IS NULL) AND
          (px_fin_plan_type_id IS NULL) )THEN

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name        => 'PA_BUDGET_FP_BOTH_MISSING');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info are missing';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- Both Budget Type Code and Fin Plan Type Id should not be not null

      IF ((p_budget_type_code IS NOT NULL AND
          p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  AND
        ((px_fin_plan_type_name IS NOT NULL) OR
         (px_fin_plan_type_id IS NOT NULL))) THEN

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name        => 'PA_BUDGET_FP_BOTH_NOT_NULL');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info both are provided';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

       --dbms_output.put_line('After validating budget and finplan ids');

      --product_code is mandatory
      IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         OR p_pm_product_code IS NULL
      THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                    pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
                      --dbms_output.put_line('MSG count in the stack ' || FND_MSG_PUB.count_msg);
                      --dbms_output.put_line('added msg to stack');
                      --dbms_output.put_line('MSG count in the stack 2 ' || FND_MSG_PUB.count_msg);
                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'PM Product code is missing';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;

              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_any_error_occurred_flag := 'Y';


               --dbms_output.put_line('pm product code is null or miss');


              -- RAISE FND_API.G_EXC_ERROR;
      ELSE

            -- added for bug no :2413400
            OPEN p_product_code_csr (p_pm_product_code);
            FETCH p_product_code_csr INTO l_pm_product_code;
            CLOSE p_product_code_csr;
            IF l_pm_product_code <> 'X'
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'GENERAL'
                       ,p_attribute1       => ''
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PM Product code is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  x_return_status             := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
            -- RAISE FND_API.G_EXC_ERROR;
            END IF;

             --dbms_output.put_line('pm product code is not valid '||l_pm_product_code);
      END IF;-- p_pm_product_code IS NULL

      l_resp_id := FND_GLOBAL.Resp_id;
      l_user_id := FND_GLOBAL.User_id;

      --  l_module_name := p_pm_product_code||'.'||'PA_PM_CREATE_DRAFT_BUDGET';

      /* Replaced the security checks with a call to single api

      -- As part of enforcing project security, which would determine
      -- whether the user has the necessary privileges to update the project
      -- If a user does not have privileges to update the project, then
      -- cannot create a budget
      -- need to call the pa_security package

      pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);
      */

      -- Actions performed using the APIs would be subject to
      -- function security. If the responsibility does not allow
      -- such functions to be executed, the API should not proceed further
      -- since the user does not have access to such functions



      /*
      PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_CREATE_DRAFT_BUDGET',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => x_return_status,
       p_function_allowed   => l_function_allowed );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_function_allowed = 'N' THEN
            pa_interface_utils_pub.map_new_amg_msg
            ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            x_return_status := FND_API.G_RET_STS_ERROR;
            --  RAISE FND_API.G_EXC_ERROR;
      END IF;
      */

      -- CHECK FOR MANDATORY FIELDS and CONVERT VALUES to ID's
      -- convert pm_project_reference to id

	  px_pa_project_id_in := px_pa_project_id;

      Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => px_pa_project_id_in,
         p_out_project_id        => px_pa_project_id,
         p_return_status         => x_return_status );

       --dbms_output.put_line('x_return_status is  '|| x_return_status);
      IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
      THEN
             --dbms_output.put_line('unexpected error while deriving project id '|| px_pa_project_id);
             --dbms_output.put_line('expected error while deriving l project id '||px_pa_project_id );
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected error while deriving project id';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
             --dbms_output.put_line('expected error while deriving px project id '||px_pa_project_id );
             --dbms_output.put_line('expected error while deriving l project id '||px_pa_project_id );
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Error while deriving project id';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            --RAISE  FND_API.G_EXC_ERROR;    --AMG UT2
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := px_pa_project_id;

      -- Now verify whether project security allows the user to update
      -- the project
      -- If a user does not have privileges to update the project, then
      -- cannot create a budget

      /*   dbms_output.put_line('Before project security'); */

      /*
      IF pa_security.allow_query (x_project_id => px_pa_project_id ) = 'N' THEN

            -- The user does not have query privileges on this project
            -- Hence, cannot create a draft budget.Raise error

            pa_interface_utils_pub.map_new_amg_msg
            ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            x_return_status := FND_API.G_RET_STS_ERROR;
            --        RAISE FND_API.G_EXC_ERROR;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
            IF pa_security.allow_update (x_project_id => px_pa_project_id ) = 'N' THEN

                  -- The user does not have update privileges on this project
                  -- Hence , raise error

                  pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
                   ,p_msg_attribute    => 'CHANGE'
                   ,p_resize_flag      => 'Y'
                   ,p_msg_context      => 'GENERAL'
                   ,p_attribute1       => ''
                   ,p_attribute2       => ''
                   ,p_attribute3       => ''
                   ,p_attribute4       => ''
                   ,p_attribute5       => '');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  --            RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;
      */


      -- Get the segment 1 of the project so that it can be used in the
      -- later part of the code
      OPEN l_amg_project_csr( px_pa_project_id );
      FETCH l_amg_project_csr INTO l_amg_project_rec;
      CLOSE l_amg_project_csr;

      -- Get the cost and rev budget entry flags so that they can be
      -- used in budget and finplan models
      OPEN  l_cost_rev_budget_entry_csr(px_pa_project_id);
      FETCH l_cost_rev_budget_entry_csr
      INTO  l_allow_cost_budget_entry_flag,
            l_allow_rev_budget_entry_flag  ;
      CLOSE l_cost_rev_budget_entry_csr;

       --dbms_output.put_line('Starting the budget type validations');

      -- Do the validations required for the budget model
      IF (p_budget_type_code IS NOT NULL AND
          p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

             --dbms_output.put_line('About to call the security api');
            --Check for the security
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                               p_api_version_number => p_api_version_number
                                              ,p_project_id         => px_pa_project_id
                                              ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET
                                              ,p_function_name      => p_calling_module
                                              ,p_version_type       => null
                                              ,x_return_status      => x_return_status
                                              ,x_ret_code           => l_security_ret_code );

            -- the above API adds the error message to stack. Hence the message is not added here.
            -- Also, as security check is important further validations are not done in case this
            -- validation fails.
            IF (x_return_status<>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code = 'N') THEN
                   --dbms_output.put_line('Security api failed l_security_ret_code '||l_security_ret_code);
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Security API Failed';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

             --dbms_output.put_line('About to validate the budget type');
            -- Get the budget amount code. Check whether the project type allows the
            -- creation of plan versions with obtained budget amounT code.
            OPEN  l_budget_amount_code_csr( p_budget_type_code );
            FETCH l_budget_amount_code_csr
            INTO  l_budget_amount_code;       --will be used later on during validation of Budget lines.

            x_budget_amount_code := l_budget_amount_code; -- Added for bug 4224464

            IF l_budget_amount_code_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                          ,p_msg_attribute    => 'CHANGE'
                          ,p_resize_flag      => 'N'
                          ,p_msg_context      => 'BUDG'
                          ,p_attribute1       => l_amg_project_rec.segment1
                          ,p_attribute2       => ''
                          ,p_attribute3       => p_budget_type_code
                          ,p_attribute4       => ''
                          ,p_attribute5       => '');

                          IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Budget type is invalid';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;

                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

                  CLOSE l_budget_amount_code_csr;
                  -- RAISE FND_API.G_EXC_ERROR;

            ELSE

                  CLOSE l_budget_amount_code_csr;


                  IF l_budget_amount_code = PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_C THEN

                        IF NVL(l_allow_cost_budget_entry_flag,'N') = 'N' THEN
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                              THEN
                                    PA_UTILS.ADD_MESSAGE
                                          (p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_COST_BUDGET_NOT_ALLOWED',
                                           p_token1         => 'PROJECT',
                                           p_value1         =>  l_amg_project_rec.segment1,
                                           p_token2         => 'BUDGET_TYPE',
                                           p_value2         =>  p_budget_type_code );
                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Creation of cost version is not allowed';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;
                              END IF;
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              l_any_error_occurred_flag := 'Y';

                          -- RAISE FND_API.G_EXC_ERROR;
                        END IF;

                  ELSIF l_budget_amount_code = PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_R THEN

                        IF NVL(l_allow_rev_budget_entry_flag,'N') = 'N' THEN
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                              THEN
                                    PA_UTILS.ADD_MESSAGE
                                          (p_app_short_name => 'PA',
                                           p_msg_name       => 'PA_REV_BUDGET_NOT_ALLOWED',
                                           p_token1         => 'PROJECT',
                                           p_value1         =>  l_amg_project_rec.segment1,
                                           p_token2         => 'BUDGET_TYPE',
                                           p_value2         =>  p_budget_type_code );
                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Creation of rev version is not allowed';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;
                              END IF;
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              l_any_error_occurred_flag := 'Y';

                        -- RAISE FND_API.G_EXC_ERROR;
                        END IF;

                  END IF; --End of l_budget_amount_code = PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_C

            END IF; --End of l_budget_amount_code_csr%NOTFOUND

            --Added this for bug#4460139
             --Verify that the budget is not of type FORECASTING_BUDGET_TYPE
             IF p_budget_type_code='FORECASTING_BUDGET_TYPE' THEN
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                         PA_UTILS.add_message
                         (p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_CANT_EDIT_FCST_BUD_TYPE');
                   END IF;
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Budget of type FORECASTING_BUDGET_TYPE' ;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

            -- Budget Integration Validation ---------------------------------------

             --dbms_output.put_line('About to call get_bdget_ctrl_options');

            PA_BUDGET_FUND_PKG.get_budget_ctrl_options (p_project_Id => px_pa_project_id
                            , p_budget_type_code => p_budget_type_code
                            , p_calling_mode     => 'BUDGET'
                            , x_fck_req_flag     => l_fck_req_flag
                            , x_bdgt_intg_flag   => l_bdgt_intg_flag
                            , x_bdgt_ver_id      => l_bdgt_ver_id
                            , x_encum_type_id    => l_encum_type_id
                            , x_balance_type     => l_balance_type
                            , x_return_status    => x_return_status
                            , x_msg_data         => x_msg_data
                            , x_msg_count        => x_msg_count
                            );

            -- calling api above adds the error message to stack hence not adding the error message here.
            IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
            THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'get_budget_ctrl_options returned unexp error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF x_return_status = FND_API.G_RET_STS_ERROR
            THEN
                  -- RAISE  FND_API.G_EXC_ERROR;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'get_budget_ctrl_options returned  error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  l_any_error_occurred_flag := 'Y';
            END IF;

            IF (nvl(l_fck_req_flag,'N') = 'Y')
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_BC_BGT_TYPE_IS_BAD_AMG'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'BUDG'
                       ,p_attribute1       => l_amg_project_rec.segment1
                       ,p_attribute2       => ''
                       ,p_attribute3       => p_budget_type_code
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

                  -- RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- ----------------------------------------------------------------------

            -- entry method code is mandatory

            IF p_entry_method_code IS NULL
               OR p_entry_method_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_ENTRY_METHOD_IS_MISSING'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_project_rec.segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => p_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Budget entry method is missing';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

                  -- RAISE FND_API.G_EXC_ERROR;
            ELSE -- entry method is not null

                  -- check validity of this budget entry method code, and store associated fields in record

                  OPEN l_budget_entry_method_csr(p_entry_method_code);
                  FETCH l_budget_entry_method_csr INTO l_budget_entry_method_rec;

                  IF   l_budget_entry_method_csr%NOTFOUND
                  THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                pa_interface_utils_pub.map_new_amg_msg
                               ( p_old_message_code => 'PA_ENTRY_METHOD_IS_INVALID'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'BUDG'
                                ,p_attribute1       => l_amg_project_rec.segment1
                                ,p_attribute2       => ''
                                ,p_attribute3       => p_budget_type_code
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                                IF l_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Budget entry method is invlaid';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                END IF;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';

                        CLOSE l_budget_entry_method_csr;
                        --  RAISE FND_API.G_EXC_ERROR;

                  ELSE

                        CLOSE l_budget_entry_method_csr;

                        IF l_budget_entry_method_rec.categorization_code = 'N' THEN

                              pa_get_resource.Get_Uncateg_Resource_Info
                                      (p_resource_list_id          => l_uncategorized_list_id,
                                       p_resource_list_member_id   => l_uncategorized_rlmid,
                                       p_resource_id               => l_uncategorized_resid,
                                       p_track_as_labor_flag       => l_track_as_labor_flag,
                                       p_err_code                  => l_err_code,
                                       p_err_stage                 => l_err_stage,
                                       p_err_stack                 => l_err_stack );

                              IF l_err_code <> 0 THEN
                                    IF NOT pa_project_pvt.check_valid_message(l_err_stage) THEN
                                          pa_interface_utils_pub.map_new_amg_msg
                                          ( p_old_message_code => 'PA_NO_UNCATEGORIZED_LIST'
                                          ,p_msg_attribute    => 'CHANGE'
                                          ,p_resize_flag      => 'N'
                                          ,p_msg_context      => 'BUDG'
                                          ,p_attribute1       => l_amg_project_rec.segment1
                                          ,p_attribute2       => ''
                                          ,p_attribute3       => p_budget_type_code
                                          ,p_attribute4       => ''
                                          ,p_attribute5       => '');

                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'Uncategorized res list  is missing';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    ELSE
                                          pa_interface_utils_pub.map_new_amg_msg
                                          ( p_old_message_code => l_err_stage
                                          ,p_msg_attribute    => 'CHANGE'
                                          ,p_resize_flag      => 'N'
                                          ,p_msg_context      => 'BUDG'
                                          ,p_attribute1       => l_amg_project_rec.segment1
                                          ,p_attribute2       => ''
                                          ,p_attribute3       => p_budget_type_code
                                          ,p_attribute4       => ''
                                          ,p_attribute5       => '');
                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'Unexp error while deriving uncat res list';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    END IF;

                              ELSE

                                    px_resource_list_id := l_uncategorized_list_id;

                              --  RAISE  FND_API.G_EXC_ERROR;
                              END IF; -- IF l_err_code <> 0 THEN


                        ELSIF l_budget_entry_method_rec.categorization_code = 'R' THEN
                              IF  (px_resource_list_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                               AND px_resource_list_name IS NOT NULL)
                                OR (px_resource_list_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                               AND px_resource_list_id IS NOT NULL) THEN
                                    -- convert resource_list_name to resource_list_id
									px_resource_list_id_in := px_resource_list_id;
                                    pa_resource_pub.Convert_List_name_to_id
                                    ( p_resource_list_name    =>  px_resource_list_name,
                                      p_resource_list_id      =>  px_resource_list_id_in,
                                      p_out_resource_list_id  =>  px_resource_list_id,
                                      p_return_status         =>  x_return_status );

                                    IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                                          x_return_status := x_return_status;
                                           --dbms_output.put_line('Unexp error as Resource list id not derived properly');
                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'Unexp error while deriving  res list';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;

                                          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

                                    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                          x_return_status := x_return_status;
                                          --                            RAISE  FND_API.G_EXC_ERROR;
                                          PA_UTILS.ADD_MESSAGE
                                                (p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_FP_INVALID_RESOURCE_LIST',
                                                 p_token1         => 'PROJECT',
                                                 p_value1         =>  l_amg_project_rec.segment1);
                                           x_return_status := FND_API.G_RET_STS_ERROR;
                                            --dbms_output.put_line('exp error as Resource list id not derived properly');
                                           l_any_error_occurred_flag := 'Y';
                                           IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'error while deriving uncat res list';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                           END IF;

                                    END IF;

                                    /* changes for bug 3954329: following check included */
                                    BEGIN
                                          SELECT migration_code
                                          INTO   l_res_list_migration_code
                                          FROM   pa_resource_lists_all_bg
                                          WHERE  resource_list_id = px_resource_list_id;
                                    EXCEPTION
                                          WHEN NO_DATA_FOUND THEN
                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                PA_UTILS.ADD_MESSAGE
                                                  (p_app_short_name => 'PA',
                                                   p_msg_name       => 'PA_FP_INVALID_RESOURCE_LIST',
                                                   p_token1         => 'PROJECT',
                                                   p_value1         =>  l_amg_project_rec.segment1);
                                                x_return_status := FND_API.G_RET_STS_ERROR;

                                               l_any_error_occurred_flag := 'Y';
                                               IF l_debug_mode = 'Y' THEN
                                                   pa_debug.g_err_stage:= 'error while deriving uncat res list';
                                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                               END IF;
                                    END;
                                    IF l_res_list_migration_code = 'N' THEN
                                          x_return_status := FND_API.G_RET_STS_ERROR;
                                          l_any_error_occurred_flag := 'Y';
                                          PA_UTILS.ADD_MESSAGE
                                               (p_app_short_name => 'PA',
                                                p_msg_name       => 'PA_FP_NEW_RES_LIST_OLD_MODEL');
                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'res list is new in old budget model';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    END IF;
                                    /* bug 3954329 ends */
                              ELSE -- There is no valid resource list id
                                    x_return_status := FND_API.G_RET_STS_ERROR;     --AMG UT2
                                    l_any_error_occurred_flag := 'Y';

                                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                          pa_interface_utils_pub.map_new_amg_msg
                                          ( p_old_message_code => 'PA_RESOURCE_LIST_IS_MISSING'
                                          ,p_msg_attribute    => 'CHANGE'
                                          ,p_resize_flag      => 'Y'
                                          ,p_msg_context      => 'BUDG'
                                          ,p_attribute1       => l_amg_project_rec.segment1
                                          ,p_attribute2       => ''
                                          ,p_attribute3       => p_budget_type_code
                                          ,p_attribute4       => ''
                                          ,p_attribute5       => '');
                                    END IF;
                                    IF l_debug_mode = 'Y' THEN
                                           pa_debug.g_err_stage:= 'res list is missing';
                                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;

                                    --  RAISE FND_API.G_EXC_ERROR;
                              END IF;
                        END IF ; -- If l_budget_entry_method_rec.categorization_code = 'N
                  END IF;--l_budget_entry_method_csr%NOTFOUND
            END IF;--p_entry_method_code IS NULL

            -- If autobaselining is enabled for the project and If the budget type code is 'AR' then the
            -- version can not be created thru AMG

            l_called_from_agr_pub := PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB; -- Bug # 3099706

            IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
                    PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
            END IF;

            IF ( (NVL(l_amg_project_rec.baseline_funding_flag,'N')='Y')
            AND (p_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR)
            AND (NVL(l_called_from_agr_pub,'N') = 'N')) THEN -- Bug 3099706

-- Added the param p_called_from_baseline to skip the autobaseline validation if
-- the create_draft_budget API is called to create a draft budget while creating
-- a baselined budget. If this API is called to create a draft version directly,
-- this check should be done. In this case, the param p_called_from_baseline
-- is defaulted to 'N' (for bug # 3099706)

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Auto base line error' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_AUTO_BASELINE_ENABLED',
                         p_token1         => 'PROJECT',
                         p_value1         =>  l_amg_project_rec.segment1);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

                  --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                   --dbms_output.put_line('Autobaseline error');

            END IF;

            -- A version can not be created for a budget type that is already
            -- upgraded.
            OPEN is_budget_type_upgraded_csr( p_budget_type_code
                                             ,px_pa_project_id);
            FETCH is_budget_type_upgraded_csr INTO l_budget_type_upgraded_rec;
            IF (is_budget_type_upgraded_csr%FOUND) THEN

                  CLOSE is_budget_type_upgraded_csr;

                  PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                          p_msg_name      => 'PA_FP_BUDGET_TYPE_UPGRADED');

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                   --dbms_output.put_line('Budget type upgraded error');
                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Budget type is already upgraded';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;


            ELSE

                  CLOSE is_budget_type_upgraded_csr;

            END IF;

            -- If an Approved Cost plan version exists for the project in new model then a budget version
            -- for budget type 'AC' can not be created for that project.
            IF (p_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC) THEN

                  -- Call the utility function that gives the id of the approved cost plan type, if exists,
                  -- that is added to the project
                  pa_fin_plan_utils.Get_Appr_Cost_Plan_Type_Info(
                     p_project_id     =>  px_pa_project_id
                    ,x_plan_type_id   =>  l_approved_fin_plan_type_id
                    ,x_return_status  =>  x_return_status
                    ,x_msg_count      =>  x_msg_count
                    ,x_msg_data       =>  x_msg_data);

                  -- Throw the error if the above API is not successfully executed
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                        IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Get_Appr_Cost_Plan_Type_Info API returned error' ;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  -- The Get_Appr_Cost_Plan_Type_Info api got executed successfully.Approved cost version
                  --  is already added to the project
                  ELSIF (l_approved_fin_plan_type_id IS NOT NULL)  THEN

                        IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Approved cost plan version is already added ' ;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;

                        PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                 p_msg_name      => 'PA_FP_AC_PLAN_TYPE_EXISTS');

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';

                  END IF; --IF x_return_status <> FND_API.G_RET_STS_SUCCESS

            END IF; --IF (p_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC)

            -- If an Approved Revenue plan version exists for the project in new model then a budget
            -- version of budget   type 'AR' can not be created for that project.
            IF (p_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR) THEN

                  -- Call the utility function that gives the id of the approved revenue plan type, if exists,
                  -- that is added to the project
                  pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info(
                     p_project_id     => px_pa_project_id
                    ,x_plan_type_id  =>  l_approved_fin_plan_type_id
                    ,x_return_status =>  x_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data) ;

                  -- Throw the error if the above API is not successfully executed
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                        IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Get_Appr_Cost_Plan_Type_Info API returned error' ;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  -- The Get_Appr_Cost_Plan_Type_Info api got executed successfully.Approved cost version
                  -- is already added to the project
                  ELSIF(  l_approved_fin_plan_type_id IS NOT NULL)  THEN

                      IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Approved Revenue plan version is already added ' ;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;

                      PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                 p_msg_name      => 'PA_FP_AR_PLAN_TYPE_EXISTS');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      l_any_error_occurred_flag := 'Y';

                  END IF;
            END IF;


            -- Get the ID of the old draft budget and then
            -- Lock the old draft budget and it budget lines (if it exists)
            -- because it will be deleted by create_draft.
            OPEN l_budget_version_csr( px_pa_project_id, p_budget_type_code );
            FETCH l_budget_version_csr INTO l_old_budget_version_id, l_budget_status_code;
            CLOSE l_budget_version_csr;

            --if working bugdet is submitted no new working budget can be created
            IF l_budget_status_code = 'S'
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_BUDGET_IS_SUBMITTED'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'BUDG'
                     ,p_attribute1       => l_amg_project_rec.segment1
                     ,p_attribute2       => ''
                     ,p_attribute3       => p_budget_type_code
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                 --RAISE FND_API.G_EXC_ERROR;

            END IF;--l_budget_status_code = 'S'


      -- Validations for fin plan model
      ELSE
	        px_fin_plan_type_id_in := px_fin_plan_type_id;
            PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
                                           ( p_fin_plan_type_id    => px_fin_plan_type_id_in
                                            ,p_fin_plan_type_name  => px_fin_plan_type_name
                                            ,x_fin_plan_type_id    => px_fin_plan_type_id
                                            ,x_return_status       => x_return_status
                                            ,x_msg_count           => x_msg_count
                                            ,x_msg_data            => x_msg_data);
             --dbms_output.put_line('After the getting plan id');

            -- Throw the error if the above API is not successfully executed
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Can not get the value of Fin Plan Type Id' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            -- Get the  plan type level settings

            OPEN  l_proj_fp_options_csr(px_pa_project_id,px_fin_plan_type_id);
            FETCH l_proj_fp_options_csr
            INTO  l_proj_fp_options_rec;

            --Bug # 3507156 : Patchset M: B and F impact changes : AMG
            --Added the parameter use_for_workplan_flag.We need to check this flag as workplan versions
            --cannot be created using AMG interface.Error handling also done.

            -- Get the name of the plan type
            SELECT name,use_for_workplan_flag
            INTO   l_fin_plan_type_name,l_workplan_flag
            FROM   pa_fin_plan_types_vl
            WHERE  fin_plan_type_id =  px_fin_plan_type_id;

            IF  l_workplan_flag = 'Y' THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'WorkPlan Versions cannot be created using this AMG interface' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_WP_BV_CR_NO_ALLOWED');

            --Bug # 3507156 : Patchset M: B and F impact changes : AMG
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

            END IF;

            -- Throw an error if the plan type is not attached to the project
            IF  l_proj_fp_options_csr%NOTFOUND THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Plan type options does not exist' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_NO_PLAN_TYPE_OPTION',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);


                  CLOSE l_proj_fp_options_csr;

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Plan type is not yet added to the project';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE

                  CLOSE l_proj_fp_options_csr;

            END IF;

            -- If autobaselining is enabled for the project and If the budget type code is 'AR' then the
            -- version can not be created thru AMG

             l_called_from_agr_pub := PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB; -- Bug # 3099706

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            --PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB should be reset to N even in case of errors.

            IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
                 PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
            END IF;

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            -- To check whether finplan is auto baselined by calling the api.

            l_autobaseline_flag := pa_fp_control_items_utils.IsFpAutoBaselineEnabled(px_pa_project_id);

            --dbms_output.put_line('About to get ver type');

            -- Derive the version type. An error will be thrown by this api if preference code is
            -- COST_AND_REV_SEP and version type is not passed
            pa_fin_plan_utils.get_version_type
                 ( p_project_id        => px_pa_project_id
                  ,p_fin_plan_type_id  => px_fin_plan_type_id
                  ,px_version_type     => px_version_type
                  ,x_return_status     => x_return_status
                  ,x_msg_count         => x_msg_count
                  ,x_msg_data          => x_msg_data);

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Faied in get_Version_type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                               --dbms_output.put_line('Exc in getting ver type');

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      IF l_autobaseline_flag = 'N' THEN

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            --If validate_header_info is called for create_budget_context call pa_fin_plan_utils.allow_edit_after_baseline_flag.

            pa_fin_plan_utils.Check_if_plan_type_editable (
                     P_project_id         => px_pa_project_id
                    ,P_fin_plan_type_id   => px_fin_plan_type_id
                    ,P_version_type       => px_version_type
                    ,X_editable_flag      => l_editable_flag
                    ,X_return_status      => x_return_status
                    ,X_msg_count          => x_msg_count
                    ,X_msg_data           => x_msg_data);

            -- Throw the error if the above API is not successfully executed

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                            IF l_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage := 'Can not check if plan type is editable' ;
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;

                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --<Patchset M: B and F impact changes : AMG:> -- Bug # 3507156
            --If it returns N, then raise PA_FP_PLAN_TYPE_NON_EDITABLE.

            IF l_editable_flag = 'N'  THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Plan type is not editable' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_PLAN_TYPE_NON_EDITABLE',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            --Setting the error statuses if plan type is not editable.

            x_return_status := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag := 'Y';

            END IF;
      END IF;

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            -- Commented out as it is redundant over here.
/*
            IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
               PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
            END IF;
*/


            IF ( (NVL(l_amg_project_rec.baseline_funding_flag,'N')='Y')
            AND (p_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR)
            AND (NVL(l_called_from_agr_pub,'N') = 'N')) THEN -- Bug 3099706


-- Added the param p_called_from_baseline to skip the autobaseline validation if
-- the create_draft_budget API is called to create a draft budget while creating
-- a baselined budget. If this API is called to create a draft version directly,
-- this check should be done. In this case, the param p_called_from_baseline
-- is defaulted to 'N' (for bug # 3099706)

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Auto base line error' ;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_FP_AUTO_BASELINE_ENABLED',
                   p_token1         => 'PROJECT',
                   p_value1         =>  l_amg_project_rec.segment1);

            x_return_status := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag := 'Y';

            --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             --dbms_output.put_line('Autobaseline error');

            END IF;

            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                         p_api_version_number => p_api_version_number
                                        ,p_project_id         => px_pa_project_id
                                        ,p_fin_plan_type_id   => px_fin_plan_type_id /* Bug 3139924 */
                                        ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                                        ,p_function_name      => p_calling_module
                                        ,p_version_type       => px_version_type
                                        ,x_return_status      => x_return_status
                                        ,x_ret_code           => l_security_ret_code );

            IF (x_return_status <>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code='N') THEN
                 --dbms_output.put_line('Exc in security');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;


            /* Bug 3133930- Version name validation is included */

            IF p_budget_version_name IS NULL OR
               p_budget_version_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  PA_UTILS.ADD_MESSAGE(
                           p_app_short_name => 'PA'
                           ,p_msg_name   => 'PA_VERSION_NAME_IS_MISSING');
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

             --dbms_output.put_line('DONE with sec');
       	-- Added the check to skip the autobaseline validation if
        -- the create_draft_budget API is called to create a draft budget while creating
        -- a baselined budget. --4738996
            -- Auto Baseline check. If auto baselining is enabled for the project the user can not
            -- create an approved revenue plan version thru AMG
            IF ((NVL(l_amg_project_rec.baseline_funding_flag,'N')='Y')
               AND (px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE)
               AND (l_proj_fp_options_rec.approved_rev_plan_type_flag = 'Y')
	       AND (NVL(l_called_from_agr_pub,'N') = 'N')) THEN -- Added for bug 4738996

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Auto base line error' ;
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                             p_msg_name      => 'PA_FP_AUTO_BASELINE_ENABLED',
                             p_token1        => 'PROJECT',
                             p_value1        =>  l_amg_project_rec.segment1);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                 --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            -- Validate planning level, resource list id and time phasing if they are passed. If they
            -- are not passed, default them from the plan type options.
            -- Get the plan type level settings so that they can be used in the defaulting
            OPEN l_plan_type_settings_csr( px_pa_project_id
                                      ,px_fin_plan_type_id
                                      ,px_version_type);
            FETCH l_plan_type_settings_csr
            INTO  l_plan_type_settings_rec;

            IF (l_plan_type_settings_csr%NOTFOUND) THEN --This condition should never be true

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'l_plan_type_settings_csr returned 0 rows' ;
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                  CLOSE l_plan_type_settings_csr;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE

                  CLOSE l_plan_type_settings_csr;

            END IF;



            -- Get the planning level
            IF ( px_fin_plan_level_code IS NULL) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Defaulting planning level from the plan type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  px_fin_plan_level_code :=  l_plan_type_settings_rec.fin_plan_level_code;

            ELSE -- validate the passed planning level

            -- Use the utility function that returns the meaning given the lookup type and code
            -- to validate the planning level given by the user

            -- <Patchset M : B andF impact changes : AMG:> -- Bug # 3507156
            -- Added a check to filter out budgets where fin_plan_level_code = 'M'

                 IF ((pa_fin_plan_utils.get_lookup_value(l_planning_level_lookup ,px_fin_plan_level_code) IS NULL)
                 OR (px_fin_plan_level_code = 'M'))
                  THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Planning level passed is '|| px_fin_plan_level_code ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INVALID_PLANNING_LEVEL',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';

                 END IF;


            END IF;--IF ( px_fin_plan_level_code IS NULL) THEN

            -- Get the resource list
               IF p_using_resource_lists_flag = 'N' THEN
                              pa_get_resource.Get_Uncateg_Resource_Info
                                      (p_resource_list_id          => l_uncategorized_list_id,
                                       p_resource_list_member_id   => l_uncategorized_rlmid,
                                       p_resource_id               => l_uncategorized_resid,
                                       p_track_as_labor_flag       => l_track_as_labor_flag,
                                       p_err_code                  => l_err_code,
                                       p_err_stage                 => l_err_stage,
                                       p_err_stack                 => l_err_stack );

                              IF l_err_code <> 0 THEN
                                    IF NOT pa_project_pvt.check_valid_message(l_err_stage) THEN
                                          pa_interface_utils_pub.map_new_amg_msg
                                          ( p_old_message_code => 'PA_NO_UNCATEGORIZED_LIST'
                                          ,p_msg_attribute    => 'CHANGE'
                                          ,p_resize_flag      => 'N'
                                          ,p_msg_context      => 'BUDG'
                                          ,p_attribute1       => l_amg_project_rec.segment1
                                          ,p_attribute2       => ''
                                          ,p_attribute3       => p_budget_type_code
                                          ,p_attribute4       => ''
                                          ,p_attribute5       => '');

                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'Uncategorized res list  is missing';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    ELSE
                                          pa_interface_utils_pub.map_new_amg_msg
                                          ( p_old_message_code => l_err_stage
                                          ,p_msg_attribute    => 'CHANGE'
                                          ,p_resize_flag      => 'N'
                                          ,p_msg_context      => 'BUDG'
                                          ,p_attribute1       => l_amg_project_rec.segment1
                                          ,p_attribute2       => ''
                                          ,p_attribute3       => p_budget_type_code
                                          ,p_attribute4       => ''
                                          ,p_attribute5       => '');
                                          IF l_debug_mode = 'Y' THEN
                                                 pa_debug.g_err_stage:= 'Unexp error while deriving uncat res list';
                                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    END IF;

                              ELSE

                                    px_resource_list_id := l_uncategorized_list_id;

                              --  RAISE  FND_API.G_EXC_ERROR;
                              END IF; -- IF l_err_code <> 0 THEN
               ELSE
                  IF( px_resource_list_name IS NULL OR
                      px_resource_list_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )AND
                     (px_resource_list_id IS NULL OR
                      px_resource_list_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Defaulting Resource List Id from the plan type' ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        px_resource_list_id := l_plan_type_settings_rec.resource_list_id;
                  ELSE

                     -- convert resource_list_name to resource_list_id
					 px_resource_list_id_in := px_resource_list_id;
                     pa_resource_pub.Convert_List_name_to_id
                         ( p_resource_list_name    =>  px_resource_list_name,
                           p_resource_list_id      =>  px_resource_list_id_in,
                           p_out_resource_list_id  =>  px_resource_list_id,
                           p_return_status         =>  x_return_status );

                     IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

                           PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_RESOURCE_LIST',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_rec.segment1);

                           IF l_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'Resource list passed is invalid';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;


                           x_return_status := FND_API.G_RET_STS_ERROR;
                           l_any_error_occurred_flag := 'Y';

                     END IF;

                     /* changes for bug 3954329: following check included */
                     BEGIN
                           SELECT migration_code
                           INTO   l_res_list_migration_code
                           FROM   pa_resource_lists_all_bg
                           WHERE  resource_list_id = px_resource_list_id;
                     EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                                 x_return_status := FND_API.G_RET_STS_ERROR;
                                 PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_INVALID_RESOURCE_LIST',
                                    p_token1         => 'PROJECT',
                                    p_value1         =>  l_amg_project_rec.segment1);
                                 x_return_status := FND_API.G_RET_STS_ERROR;

                                l_any_error_occurred_flag := 'Y';
                                IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'error while deriving uncat res list';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                END IF;
                     END;
                     IF l_res_list_migration_code IS NULL THEN
                           x_return_status := FND_API.G_RET_STS_ERROR;
                           l_any_error_occurred_flag := 'Y';
                           PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_OLD_RES_LIST_NEW_MODEL');
                           IF l_debug_mode = 'Y' THEN
                                  pa_debug.g_err_stage:= 'res list is OLD in NEW budget model';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                     END IF;
                     /* bug 3954329 ends */
                  END IF;
               END IF;

            -- Get the Time Phasing
            IF ( px_time_phased_code IS NULL) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Defaulting Time Phasing from the plan type' ;
                        pa_debug.write( l_module_name,pa_debug.g_err_stage, l_debug_level3);
                  END IF;

                  px_time_phased_code :=  l_plan_type_settings_rec.time_phased_code;

            ELSE -- validate the passed time phased code

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            --Added the extra condition to check for time phasing as 'R'(Date Range) as date range time phasing is not supported in FP M.

                  IF  ((pa_fin_plan_utils.get_lookup_value( l_time_phasing_lookup,px_time_phased_code) IS NULL) OR (px_time_phased_code = 'R'))
                  THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Time Phased Code passed is '|| px_time_phased_code ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INVALID_TIME_PHASING',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';


            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            -- Call to Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info has become obsolete as per the FP M
            -- model so this condition has been commented out.
            --Comment START.
/*
                  -- The time phasing passed is valid. Time phasing can not be 'PA' or 'GL' if the
                  -- period profile is not defined for the project.
                  ELSE
                        IF px_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,
                                                PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G) THEN
                              -- If the time phasing is either PA or GL check whether a period profile for that project
                              -- exists or not
                              IF px_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P THEN
                                    l_period_type := PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA;
                              ELSE
                                    l_period_type := PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL;
                              END IF;

                              Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info
                                   ( p_project_id          => px_pa_project_id,
                                     p_period_type         => l_period_type,
                                     p_period_profile_type => PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING,
                                     x_period_profile_id   => l_period_profile_id,
                                     x_start_period        => l_start_period,
                                     x_end_period          => l_end_period,
                                     x_return_status       => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data );

                              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'get current period profile gave error' ||px_pa_project_id;
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                    END IF;
                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                              IF(l_period_profile_id IS NULL) THEN

                                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                         p_msg_name       => 'PA_FP_NO_PERIOD_PROFILE');
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    l_any_error_occurred_flag := 'Y';
                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Project does not have a period profile';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                                    END IF;

                              END IF;
                        END IF; --IF px_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,
*/

            --<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
            -- Replaced the call to Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info
            -- by a check for existence of record in pa_period_masks_b

                  ELSIF px_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,
                                                PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G) THEN
                       BEGIN
                       SELECT 'Y'
                       INTO l_exists
                       FROM dual
                       WHERE exists(SELECT 'X' FROM pa_period_masks_b WHERE trunc(sysdate) between  EFFECTIVE_START_DATE
                       AND nvl( EFFECTIVE_END_DATE,sysdate)
                       AND TIME_PHASE_CODE = px_time_phased_code);                  -- Bug # 3507156

                       EXCEPTION
                       WHEN no_data_found THEN
                       l_exists := 'N' ;  /* No record exists in pa_period_masks_b */
                       l_any_error_occurred_flag := 'Y';

                                   PA_UTILS.ADD_MESSAGE
                                        (p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_NO_PERIOD_MASK');

                       x_return_status := FND_API.G_RET_STS_ERROR;
                       END;
                  END IF; -- IF pa_fin_plan_utils.get_lookup_value

            END IF; -- IF(px_time_phased_code IS NULL) THEN
                                           --dbms_output.put_line('About to start mc');

            -- Multi currency flag validation.

            -- Depending on px_version_type initialise l_conv_attrs_to_be_validated
            IF (px_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL) THEN
                 l_conv_attrs_to_be_validated := px_version_type;
            ELSE
                 l_conv_attrs_to_be_validated := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;
            END IF;


            -- Get the project and project functional currencies.
            pa_fin_plan_utils.Get_Project_Curr_Attributes
            (  p_project_id                    => px_pa_project_id
              ,x_multi_currency_billing_flag   => l_multi_currency_billing_flag
              ,x_project_currency_code         => l_project_currency_code
              ,x_projfunc_currency_code        => l_projfunc_currency_code
              ,x_project_cost_rate_type        => l_project_cost_rate_type
              ,x_projfunc_cost_rate_type       => l_projfunc_cost_rate_type
              ,x_project_bil_rate_type         => l_project_bil_rate_type
              ,x_projfunc_bil_rate_type        => l_projfunc_bil_rate_type
              ,x_return_status                 => x_return_status
              ,x_msg_count                     => x_msg_count
              ,x_msg_data                      => x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'pa_fin_plan_utils.Get_Project_Curr_Attributes errored out for project' ||px_pa_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;


            -- Validate the MC flag.
            l_validate_mc_attributes := 'Y';
            IF (px_plan_in_multi_curr_flag IS NULL)   THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Defaulting MC from plan type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  px_plan_in_multi_curr_flag :=  l_proj_fp_options_rec.plan_in_multi_curr_flag ;

                  IF px_plan_in_multi_curr_flag = 'N' THEN
                        l_validate_mc_attributes := 'N';

                        px_projfunc_cost_rate_type := NULL;
                        px_projfunc_cost_rate_date_typ := NULL;
                        px_projfunc_cost_rate_date := NULL;
                        px_projfunc_rev_rate_type  := NULL;
                        px_projfunc_rev_rate_date_typ := NULL;
                        px_projfunc_rev_rate_date := NULL;
                        px_project_cost_rate_type := NULL;
                        px_project_cost_rate_date_typ := NULL;
                        px_project_cost_rate_date := NULL;
                        px_project_rev_rate_type  := NULL;
                        px_project_rev_rate_date_typ := NULL;
                        px_project_rev_rate_date  := NULL;

                  END IF;

            END IF;

            IF px_plan_in_multi_curr_flag = 'Y' THEN
                  -- if plan type does not allow MC then it is also not allowed at the version level.
                  IF  l_proj_fp_options_rec.plan_in_multi_curr_flag = 'N' THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'mc is not enabled at plan type level';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_MC_MISMATCH',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        l_validate_mc_attributes := 'N';

                  END IF;

                  --  when plan type is approved revenue and PC = PFC then its not allowed
                  --  to enable MC for revenue versions
                  IF l_proj_fp_options_rec.approved_rev_plan_type_flag = 'Y' AND
                     l_project_currency_code = l_projfunc_currency_code AND
                     px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'mc is wrongly enabled at version level';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_AR_AT_PROJ_TEMP');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';

                        l_validate_mc_attributes := 'N';

                  END IF;

            ELSIF px_plan_in_multi_curr_flag = 'N' THEN

                  l_validate_mc_attributes := 'N';
                  IF (l_project_currency_code <> l_projfunc_currency_code) THEN
                  --24-APR-03. Changes made for post_fpk by Xin Liu
            /*
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'mc should be enabled at version level since PC <> PFC';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        l_copy_conv_attr :=FALSE;

                        PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_MC_DISABLED_AT_VER',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);


                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
            */
                  l_validate_mc_attributes := 'Y';
                  px_plan_in_multi_curr_flag := 'Y';
                  --Done with changes


                  ELSE

                        px_projfunc_cost_rate_type := NULL;
                        px_projfunc_cost_rate_date_typ := NULL;
                        px_projfunc_cost_rate_date := NULL;
                        px_projfunc_rev_rate_type  := NULL;
                        px_projfunc_rev_rate_date_typ := NULL;
                        px_projfunc_rev_rate_date := NULL;
                        px_project_cost_rate_type := NULL;
                        px_project_cost_rate_date_typ := NULL;
                        px_project_cost_rate_date := NULL;
                        px_project_rev_rate_type  := NULL;
                        px_project_rev_rate_date_typ := NULL;
                        px_project_rev_rate_date  := NULL;

                  END IF;--IF (l_project_currency_code <> l_projfunc_currency_code) THEN

            ELSE--Invalid value for MC flagg

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Value of mc flag is' ||px_plan_in_multi_curr_flag;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_VAL_FOR_MC',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_amg_project_rec.segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  l_validate_mc_attributes := 'N';


            END IF; -- IF ( px_plan_in_multi_curr_flag = 'Y') THEN

            IF l_validate_mc_attributes = 'Y' THEN

                  IF (px_project_cost_rate_type        IS NULL     AND
                      px_project_cost_rate_date_typ    IS NULL     AND
                      px_project_cost_rate_date        IS NULL     AND
                      px_projfunc_cost_rate_type       IS NULL     AND
                      px_projfunc_cost_rate_date_typ   IS NULL     AND
                      px_projfunc_cost_rate_date       IS NULL     AND
                      px_project_rev_rate_type         IS NULL     AND
                      px_project_rev_rate_date_typ     IS NULL     AND
                      px_project_rev_rate_date         IS NULL     AND
                      px_projfunc_rev_rate_type        IS NULL     AND
                      px_projfunc_rev_rate_date_typ    IS NULL     AND
                      px_projfunc_rev_rate_date        IS NULL     ) THEN

                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'Deriving the conversion attrs from plan type';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        px_projfunc_cost_rate_type    := l_proj_fp_options_rec.projfunc_cost_rate_type;
                        px_projfunc_cost_rate_date_typ:= l_proj_fp_options_rec.projfunc_cost_rate_date_type;
                        px_projfunc_cost_rate_date    := l_proj_fp_options_rec.projfunc_cost_rate_date;
                        px_projfunc_rev_rate_type     := l_proj_fp_options_rec.projfunc_rev_rate_type;
                        px_projfunc_rev_rate_date_typ := l_proj_fp_options_rec.projfunc_rev_rate_date_type;
                        px_projfunc_rev_rate_date     := l_proj_fp_options_rec.projfunc_rev_rate_date;
                        px_project_cost_rate_type     := l_proj_fp_options_rec.project_cost_rate_type;
                        px_project_cost_rate_date_typ := l_proj_fp_options_rec.project_cost_rate_date_type;
                        px_project_cost_rate_date     := l_proj_fp_options_rec.project_cost_rate_date;
                        px_project_rev_rate_type      := l_proj_fp_options_rec.project_rev_rate_type;
                        px_project_rev_rate_date_typ  := l_proj_fp_options_rec.project_rev_rate_date_type;
                        px_project_rev_rate_date      := l_proj_fp_options_rec.project_rev_rate_date;

                  -- Conversion attributes are passed. Validate them
                  ELSE

                        -- Null out the cost attributes for revenue version and vice versa              AMG UT2
                        IF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN

                              px_project_rev_rate_type      :=NULL;
                              px_project_rev_rate_date_typ  :=NULL;
                              px_project_rev_rate_date      :=NULL;

                              px_projfunc_rev_rate_type     :=NULL;
                              px_projfunc_rev_rate_date_typ :=NULL;
                              px_projfunc_rev_rate_date     :=NULL;

                        ELSIF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN

                              px_project_cost_rate_type      :=NULL;
                              px_project_cost_rate_date_typ  :=NULL;
                              px_project_cost_rate_date      :=NULL;

                              px_projfunc_cost_rate_type     :=NULL;
                              px_projfunc_cost_rate_date_typ :=NULL;
                              px_projfunc_cost_rate_date     :=NULL;

                        END IF;

                        -- If the rate type is not user at plan type and the rate type provided
                        -- is User then throw an error since the rates at the option level can not
                        -- be obtained

                        pa_budget_pvt.valid_rate_type
                              (p_pt_project_cost_rate_type => l_proj_fp_options_rec.project_cost_rate_type,
                               p_pt_project_rev_rate_type  => l_proj_fp_options_rec.project_rev_rate_type,
                               p_pt_projfunc_cost_rate_type=> l_proj_fp_options_rec.projfunc_cost_rate_type,
                               p_pt_projfunc_rev_rate_type => l_proj_fp_options_rec.projfunc_rev_rate_type,
                               p_pv_project_cost_rate_type => px_project_cost_rate_type,
                               p_pv_project_rev_rate_type  => px_project_rev_rate_type,
                               p_pv_projfunc_cost_rate_type=> px_projfunc_cost_rate_type,
                               p_pv_projfunc_rev_rate_type => px_projfunc_rev_rate_type,
                               x_is_rate_type_valid        => l_is_rate_type_valid,
                               x_return_status             => x_return_status,
                               x_msg_count                 => x_msg_count,
                               x_msg_data                  => x_msg_data);

                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                              IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'valid_rate_type returned error';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                        END IF;

                        IF NOT l_is_rate_type_valid THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'mc is wrongly enabled at version level';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_RATE_TYPE_NOT_USER_AT_PT',
                               p_token1         => 'PROJECT',
                               p_value1         =>  l_amg_project_rec.segment1,
                               p_token2         => 'PLAN_TYPE',
                               p_value2         =>  l_fin_plan_type_name);

                              x_return_status := FND_API.G_RET_STS_ERROR;
                              l_any_error_occurred_flag := 'Y';

                        ELSE
                               --dbms_output.put_line('The value of l_conv_attrs_to_be_validated is ' ||l_conv_attrs_to_be_validated);

                              pa_fin_plan_utils.validate_currency_attributes
                              (px_project_cost_rate_type      =>px_project_cost_rate_type
                              ,px_project_cost_rate_date_typ  =>px_project_cost_rate_date_typ
                              ,px_project_cost_rate_date      =>px_project_cost_rate_date
                              ,px_project_cost_exchange_rate  =>l_project_cost_exchange_rate
                              ,px_projfunc_cost_rate_type     =>px_projfunc_cost_rate_type
                              ,px_projfunc_cost_rate_date_typ =>px_projfunc_cost_rate_date_typ
                              ,px_projfunc_cost_rate_date     =>px_projfunc_cost_rate_date
                              ,px_projfunc_cost_exchange_rate =>l_projfunc_cost_exchange_rate
                              ,px_project_rev_rate_type       =>px_project_rev_rate_type
                              ,px_project_rev_rate_date_typ   =>px_project_rev_rate_date_typ
                              ,px_project_rev_rate_date       =>px_project_rev_rate_date
                              ,px_project_rev_exchange_rate   =>l_project_rev_exchange_rate
                              ,px_projfunc_rev_rate_type      =>px_projfunc_rev_rate_type
                              ,px_projfunc_rev_rate_date_typ  =>px_projfunc_rev_rate_date_typ
                              ,px_projfunc_rev_rate_date      =>px_projfunc_rev_rate_date
                              ,px_projfunc_rev_exchange_rate  =>l_projfunc_rev_exchange_rate
                              ,p_project_currency_code        =>l_project_currency_code
                              ,p_projfunc_currency_code       =>l_projfunc_currency_code
                              ,p_context                      =>PA_FP_CONSTANTS_PKG.G_AMG_API_HEADER
                              ,p_attrs_to_be_validated        =>l_conv_attrs_to_be_validated
                              ,x_return_status                =>x_return_status
                              ,x_msg_count                    =>x_msg_count
                              ,x_msg_data                     =>x_msg_data);

                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    x_return_status:=FND_API.G_RET_STS_ERROR;

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Validate currency attributes returned error';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;
                                    l_any_error_occurred_flag := 'Y';
                              END IF;
                        END IF;

                  END IF;-- For If where all the conv attrs are checked for NULL
            END IF;--l_validate_mc_attributes = 'Y'

 -- Added for Bug#5510196 START

                     px_revenue_flag := nvl(px_revenue_flag,'N');
                     px_revenue_qty_flag := nvl(px_revenue_qty_flag,'N');

                     px_raw_cost_flag:= nvl(px_raw_cost_flag,'N');
                     px_burdened_cost_flag := nvl(px_burdened_cost_flag,'N');
                     px_cost_qty_flag := nvl(px_cost_qty_flag,'N');
                     px_all_qty_flag := nvl(px_all_qty_flag,'N');

   -- Addeed for Bug#5510196 END


            --  Validate amount and quantity flags
            IF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN

                  px_raw_cost_flag:= nvl(px_raw_cost_flag,'N');
                  px_burdened_cost_flag := nvl(px_burdened_cost_flag,'N');
                  px_cost_qty_flag := nvl(px_cost_qty_flag,'N');

                  IF( px_raw_cost_flag     NOT IN ('Y','N')) OR
                    ( px_burdened_cost_flag NOT IN ('Y','N')) OR
                    ( px_cost_qty_flag     NOT IN ('Y','N')) THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_rec.segment1,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  l_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid values for amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                  END IF;


                  IF( px_raw_cost_flag     = 'N') AND
                    ( px_burdened_cost_flag = 'N') AND
                    ( px_cost_qty_flag     = 'N') THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                  END IF;

            ELSIF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ) THEN

                  px_revenue_flag := nvl(px_revenue_flag,'N');
                  px_revenue_qty_flag := nvl(px_revenue_qty_flag,'N');

                  IF( px_revenue_flag     NOT IN ('Y','N')) OR
                    ( px_revenue_qty_flag NOT IN ('Y','N')) THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_rec.segment1,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  l_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid value for the amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;


                  IF( px_revenue_flag     ='N') AND
                    ( px_revenue_qty_flag ='N') THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

            ELSIF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL ) THEN

                  px_raw_cost_flag:= nvl(px_raw_cost_flag,'N');
                  px_burdened_cost_flag := nvl(px_burdened_cost_flag,'N');
                  px_revenue_flag := nvl(px_revenue_flag,'N');
                  px_all_qty_flag := nvl(px_all_qty_flag,'N');

                  IF( px_raw_cost_flag      NOT IN ('Y','N')) OR
                    ( px_burdened_cost_flag NOT IN ('Y','N')) OR
                    ( px_revenue_flag       NOT IN ('Y','N')) OR
                    ( px_all_qty_flag       NOT IN ('Y','N')) THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_rec.segment1,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  l_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid value for the amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

		  IF( px_raw_cost_flag     ='N') AND
                    ( px_burdened_cost_flag='N') AND
                    ( px_revenue_flag      ='N') AND
                    ( px_cost_qty_flag     = 'N') AND			--Fix for 7172129
                    ( px_revenue_qty_flag ='N') AND
                    ( px_all_qty_flag      ='N') THEN

			PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

            END IF; -- Validate amount and quantity flags

            -- Check create_new_working_flag and replace_current_working_flag
            IF ( p_create_new_curr_working_flag IS NULL  OR
                 p_replace_current_working_flag IS NULL OR
                 p_create_new_curr_working_flag NOT IN ('Y','N') OR
                 p_replace_current_working_flag NOT IN ('Y','N')) THEN

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_CR_REP_FLAGS_INVALID',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_project_rec.segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Create replace CW version flags are invalid ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;


            --Create and Replace flags have valid values
            ELSE

                  IF (p_replace_current_working_flag = 'Y' OR
                       p_create_new_curr_working_flag = 'Y')  THEN

                        -- Get the status of the current working version. If the status is submitted then
                        -- it can not be updated/deleted
                        OPEN  l_finplan_CW_ver_csr(px_pa_project_id,px_fin_plan_type_id,px_version_type);
                        FETCH l_finplan_CW_ver_csr
                        INTO  l_finplan_CW_ver_rec;

                        IF( l_finplan_CW_ver_csr%NOTFOUND) THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'A working version does not exist for the project '||px_pa_project_id;
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              CLOSE l_finplan_CW_ver_csr;

                        ELSE

                              CLOSE l_finplan_CW_ver_csr;

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'One of the create  replace flags is Y';
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              IF nvl(l_finplan_CW_ver_rec.budget_status_code,'X') = 'S' THEN
                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage := 'Version exists in submitted status';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;

                                    pa_interface_utils_pub.map_new_amg_msg
                                      ( p_old_message_code => 'PA_BUDGET_IS_SUBMITTED'
                                       ,p_msg_attribute    => 'CHANGE'
                                       ,p_resize_flag      => 'N'
                                       ,p_msg_context      => 'BUDG'
                                       ,p_attribute1       => l_amg_project_rec.segment1
                                       ,p_attribute2       => ''
                                       ,p_attribute3       => l_fin_plan_type_name
                                       ,p_attribute4       => ''
                                       ,p_attribute5       => '');
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    l_any_error_occurred_flag := 'Y';

                              IF l_finplan_CW_ver_rec.plan_processing_code IN ('XLUE','XLUP') THEN

                                  pa_fin_plan_utils.return_and_vldt_plan_prc_code
                                 (p_plan_processing_code    =>   l_finplan_CW_ver_rec.plan_processing_code
                                  ,x_final_plan_prc_code    =>   l_finplan_CW_ver_rec.plan_processing_code
                                  ,x_targ_request_id        =>   l_targ_request_id
                                  ,x_return_status          =>   x_return_status
                                  ,x_msg_count              =>   x_msg_count
                                  ,x_msg_data               =>   x_msg_data);

                                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        x_return_status:=FND_API.G_RET_STS_ERROR;

                                        IF l_debug_mode = 'Y' THEN
                                              pa_debug.g_err_stage:= 'pa_fin_plan_utils.return_and_vldt_plan_prc_code returned error';
                                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                        END IF;
                                        l_any_error_occurred_flag := 'Y';
                                  END IF;

                              END IF;

                              END IF; -- if budget version is in submitted status.

                        END IF;--IF( l_finplan_CW_ver_csr%NOTFOUND) THEN

                  END IF;--IF ((p_replace_current_working_flag <> 'N' OR

            END IF;  -- p_create_new_curr_working_flag IS NULL  OR

      END IF; -- END OF CHECKS FOR FINPLAN MODEL

      -- check validity of the budget change reason code, passing NULL is OK

      IF (p_change_reason_code IS NOT NULL AND
          p_change_reason_code  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

            --dbms_output.put_line('In head p_change_reason_code is '||p_change_reason_code);
            OPEN l_budget_change_reason_csr( p_change_reason_code );
            FETCH l_budget_change_reason_csr INTO l_dummy;
            IF (p_budget_type_code IS NULL  OR
                 p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

                  l_context_info := l_fin_plan_type_name;

            ELSE

                  l_context_info := p_budget_type_code;

            END IF;
            IF l_budget_change_reason_csr%NOTFOUND THEN
                  CLOSE l_budget_change_reason_csr;

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CHANGE_REASON_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_project_rec.segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => l_context_info
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid Change Reason code ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';

                  --RAISE FND_API.G_EXC_ERROR;

            ELSE

                  CLOSE l_budget_change_reason_csr;
            END IF;



      END IF;--IF (p_change_reason_code IS NOT NULL AND
                               --dbms_output.put_line('Leaving val header info');
      IF(l_debug_mode='Y') THEN
            pa_debug.g_err_stage := 'Leaving validate_header_info';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      -- Stop further processing if any errors are reported
       --dbms_output.put_line('MSG count in the stack ' || FND_MSG_PUB.count_msg);
      IF(l_any_error_occurred_flag='Y') THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'About to display all the messages';
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag := 'Y';
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

	  IF l_debug_mode = 'Y' THEN
	      pa_debug.reset_curr_function;
	  END IF;
EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
            IF x_return_status IS NULL OR
               x_return_status =  FND_API.G_RET_STS_SUCCESS THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            l_msg_count := FND_MSG_PUB.count_msg;
             --dbms_output.put_line('MSG count in the stack ' || l_msg_count);

            IF l_msg_count = 1 AND x_msg_data IS NULL THEN
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
             --dbms_output.put_line('MSG count in the stack ' || l_msg_count);

        IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
	END IF;
            RETURN;

      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_BUDGET_PVT'
            ,p_procedure_name  => 'VALIDATE_HEADER_INFO'
            ,p_error_text      => sqlerrm);

	    IF l_debug_mode = 'Y' THEN
                  pa_debug.G_Err_Stack := SQLERRM;
                  pa_debug.write( l_module_name,pa_debug.G_Err_Stack,4);
                  pa_debug.reset_curr_function;
            END IF;
            RAISE;

END VALIDATE_HEADER_INFO;


--###This API is an overloaded version of an already existing procedure. It is
--created as part of FP.M Changes for FP AMG Apis. All header level validations
--required for PA_BUDGET_PUB.add_budget_line have been added to this API.
--This API handles validations for budget versions in new as well as old models.

-- 26-APR-2005  Ritesh Shukla   Created.
-- 01-Jun-2005  Ritesh Shukla   Bug 4224464: Commented out the budgetary control check
--                              in this API as per the discussions between PM and Dev.
--                              At present this API is being called from following APIs:
--                              PA_BUDGET_PBU.add_budget_line
--                              PA_BUDGET_PBU.update_budget_line
--                              PA_BUDGET_PBU.delete_budget_line
--                              PA_BUDGET_PBU.update_budget
--                              These APIs do not require the budgetary control check.
--                              If in future this API is called from any API that
--                              requires the budgetary control check then this code may
--                              be uncommented and following design suggested by
--                              Jeff White (PM) may be used. "Add a IN-paramter,
--                              say p_budgetary_control_flag (Y to enforece edit,
--                              N to disable edit) Default 'N'.
--
-- 27-SEP-2005 jwhite           -Bug 4588279
--                               For overloaded procedure Validate_Header_Info,
--                               1) Renabled the budgetary control api call.
--                               2) Rewrote logic to populate a package global for budget LINE validation
--                                  by pa_budget_check_pvt.GET_VALID_PERIOD_DATES_PVT procedure.
--
--                               Note:
--                               1)   For the PA_BUDGET_PBU.delete_budget_line, this procedure is NOT impacted
--                                    by these code changes. Also, it is OK to delete budget lines for
--                                    budgetary control project/budget-types.
-- 21-Oct-2008 rthumma          -Bug 7498493
--                               Added a variable px_pa_project_id_tmp to prevent the error
--                               PA_PROJECT_REF_AND_ID_MISSING
--
--




PROCEDURE Validate_Header_Info
( p_api_version_number            IN            NUMBER
 ,p_api_name                      IN            VARCHAR2
 ,p_init_msg_list                 IN            VARCHAR2
 ,px_pa_project_id                IN OUT NOCOPY NUMBER
 ,p_pm_project_reference          IN            VARCHAR2
 ,p_pm_product_code               IN            VARCHAR2
 ,px_budget_type_code             IN OUT NOCOPY VARCHAR2
 ,px_fin_plan_type_id             IN OUT NOCOPY NUMBER
 ,px_fin_plan_type_name           IN OUT NOCOPY VARCHAR2
 ,px_version_type                 IN OUT NOCOPY VARCHAR2
 ,p_budget_version_number         IN            NUMBER
 ,p_change_reason_code            IN            VARCHAR2
 ,p_function_name                 IN            VARCHAR2
 ,x_budget_entry_method_code      OUT    NOCOPY VARCHAR2
 ,x_resource_list_id              OUT    NOCOPY NUMBER
 ,x_budget_version_id             OUT    NOCOPY NUMBER
 ,x_fin_plan_level_code           OUT    NOCOPY VARCHAR2
 ,x_time_phased_code              OUT    NOCOPY VARCHAR2
 ,x_plan_in_multi_curr_flag       OUT    NOCOPY VARCHAR2
 ,x_budget_amount_code            OUT    NOCOPY VARCHAR2
 ,x_categorization_code           OUT    NOCOPY VARCHAR2
 ,x_project_number                OUT    NOCOPY VARCHAR2
 /* Plan Amount Entry flags introduced by bug 6408139 */
 ,px_raw_cost_flag                IN OUT NOCOPY   VARCHAR2
 ,px_burdened_cost_flag           IN OUT NOCOPY   VARCHAR2
 ,px_revenue_flag                 IN OUT NOCOPY   VARCHAR2
 ,px_cost_qty_flag                IN OUT NOCOPY   VARCHAR2
 ,px_revenue_qty_flag             IN OUT NOCOPY   VARCHAR2
 ,px_all_qty_flag                 IN OUT NOCOPY   VARCHAR2
 ,px_bill_rate_flag               IN OUT NOCOPY   VARCHAR2
 ,px_cost_rate_flag               IN OUT NOCOPY   VARCHAR2
 ,px_burden_rate_flag             IN OUT NOCOPY   VARCHAR2
 /* Plan Amount Entry flags introduced by bug 6408139 */
 ,x_msg_count                     OUT    NOCOPY NUMBER
 ,x_msg_data                      OUT    NOCOPY VARCHAR2
 ,x_return_status                 OUT    NOCOPY VARCHAR2)

IS

      --This cursor is used to check if a fin_plan_type_id is
      --used to store workplan data
      CURSOR l_use_for_wp_csr
      ( p_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE)
      IS
      SELECT 1
      FROM pa_fin_plan_types_b
      WHERE fin_plan_type_id = p_fin_plan_type_id
      AND   use_for_workplan_flag = 'Y';

      --Cursor to get the details of the budget entry method passed
      CURSOR  l_budget_entry_method_csr
             (c_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
      IS
      SELECT entry_level_code
            ,categorization_code
            ,time_phased_type_code
      FROM   pa_budget_entry_methods
      WHERE  budget_entry_method_code = c_budget_entry_method_code
      AND    trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

      --Cursor to get the plan type details of the version being created.
      CURSOR  l_proj_fp_options_csr
            ( c_project_id          pa_projects.project_id%TYPE
             ,c_fin_plan_type_id    pa_fin_plan_types_b.fin_plan_type_id%TYPE
             ,c_version_type        pa_budget_versions.version_type%TYPE
             ,c_fin_plan_version_id pa_budget_versions.budget_version_id%TYPE)
      IS
      SELECT nvl(plan_in_multi_curr_flag,'N') multi_curr_flag
            ,decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_fin_plan_level_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_fin_plan_level_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_fin_plan_level_code) fin_plan_level_code
            ,decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_resource_list_id,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_resource_list_id,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_resource_list_id)  resource_list_id
            ,decode(c_version_type,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_time_phased_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_time_phased_code,
                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_time_phased_code)  time_phased_code
      FROM   pa_proj_fp_options
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    fin_plan_version_id = c_fin_plan_version_id;


      -- Cursor to get the segment 1 of the project.
      CURSOR l_amg_project_csr
            (c_project_id pa_projects_all.project_id%TYPE)
      IS
      SELECT segment1
      FROM   pa_projects_all
      WHERE  project_id=c_project_id;

      -- Cursor used in validating the product code
      Cursor p_product_code_csr (c_pm_product_code IN VARCHAR2)
      Is
      Select 'X'
      from   pa_lookups
      where  lookup_type='PM_PRODUCT_CODE'
      and    lookup_code = c_pm_product_code;

      -- needed to get the related budget_version, entry_method and resource_list
      CURSOR  l_budget_version_csr
              ( c_project_id          NUMBER
              , c_budget_type_code    VARCHAR2 )
      IS
      SELECT budget_version_id
      ,      budget_entry_method_code
      ,      resource_list_id
      FROM   pa_budget_versions
      WHERE  project_id        = c_project_id
      AND    budget_type_code  = c_budget_type_code
      AND    budget_status_code    = 'W'
      AND    ci_id IS NULL;

      --Cursor to get FinPlan ver id for a FinPlan version
      CURSOR l_finplan_version_id_csr
             (c_project_id        NUMBER
             ,c_fin_plan_type_id  NUMBER
             ,c_version_type      VARCHAR2
             ,c_version_number    NUMBER )
      IS
      SELECT budget_version_id
      FROM   pa_budget_versions
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    version_type=c_version_type
      AND    version_number=c_version_number
      AND    budget_status_code='W'
      AND    ci_id is null;

      l_data                           VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_debug_mode                     VARCHAR2(1);
      l_module_name                    VARCHAR2(80);

      l_security_ret_code              VARCHAR2(1);
      l_dummy                          NUMBER;
      l_dummy1                         VARCHAR2(1); -- Bug 5359585;
      l_debug_level2                   CONSTANT NUMBER := 2;
      l_debug_level3                   CONSTANT NUMBER := 3;
      l_debug_level4                   CONSTANT NUMBER := 4;
      l_debug_level5                   CONSTANT NUMBER := 5;
      l_pm_product_code                VARCHAR2(2) :='Z';
      l_result                         VARCHAR2(30);
      l_locked_by_persion_id           pa_budget_versions.locked_by_person_id%TYPE;
      l_val_err_code                   VARCHAR2(30);

      -- Following variable will be set when atleast one error
      -- is reported while validating the input parameters
      -- passed by the user
      l_any_error_occurred_flag        VARCHAR2(1) :='N';

      l_context_info                   pa_fin_plan_types_tl.name%TYPE;
      l_plan_processing_code           pa_budget_versions.plan_processing_code%TYPE;

      --Local variables needed for calling Funds Check API
      l_fck_req_flag                   VARCHAR2(1) := NULL;
      l_bdgt_intg_flag                 VARCHAR2(1) := NULL;
      l_bdgt_ver_id                    NUMBER      := NULL;
      l_encum_type_id                  NUMBER      := NULL;

      l_balance_type                   VARCHAR2(1) := NULL;

      l_targ_request_id                pa_budget_versions.request_id%TYPE;
      /*Variables added for bug 6408139*/
      l_amount_set_id       pa_proj_fp_options.all_amount_set_id%TYPE;
      lx_raw_cost_flag                  VARCHAR2(1) ;
      lx_burdened_cost_flag             VARCHAR2(1);
      lx_revenue_flag                   VARCHAR2(1);
      lx_cost_qty_flag                  VARCHAR2(1);
      lx_revenue_qty_flag               VARCHAR2(1);
      lx_all_qty_flag                   VARCHAR2(1);
      lx_bill_rate_flag                 VARCHAR2(1);
      lx_cost_rate_flag                 VARCHAR2(1);
      lx_burden_rate_flag               VARCHAR2(1);
      px_pa_project_id_tmp NUMBER := NULL;    /* Bug 7498493 */

      px_fin_plan_type_id_in           pa_fin_plan_types_b.fin_plan_type_id%TYPE; --Bug 6920539

BEGIN


      x_msg_count :=0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := g_module_name || 'validate_header_info: ';

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'validate_header_info',
                                        p_debug_mode => l_debug_mode );
      END IF;

      -- Initialize the message table if requested.
      IF FND_API.TO_BOOLEAN( p_init_msg_list )
      THEN
        FND_MSG_PUB.initialize;
      END IF;

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;


      --Standard call to check for call compatibility.
      --We do not perform the call compatibility check if p_api_name
      --is null. Internal APIs should pass this parameter as null.
      IF p_api_name IS NOT NULL THEN
            IF NOT FND_API.compatible_api_call ( PA_BUDGET_PUB.g_api_version_number,
                                                 p_api_version_number    ,
                                                 p_api_name              ,
                                                 PA_BUDGET_PUB.G_PKG_NAME )
            THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      --Convert following IN parameters from G_PA_MISS_XXX to null

      IF px_pa_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            px_pa_project_id := NULL;
      END IF;

      IF px_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            px_budget_type_code := NULL;
      END IF;

      IF px_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            px_fin_plan_type_id := NULL;
      END IF;

      IF px_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            px_fin_plan_type_name := NULL;
      END IF;

      IF px_version_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            px_version_type := NULL;
      END IF;

      -- Both Budget Type Code and Fin Plan Type Id should not be null
      IF (px_budget_type_code IS NULL  AND  px_fin_plan_type_name IS NULL  AND
          px_fin_plan_type_id IS NULL)  THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_BUDGET_FP_BOTH_MISSING');
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info are missing';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- Both Budget Type Code and Fin Plan Type Id should not be not null

      IF ((px_budget_type_code IS NOT NULL)  AND
          (px_fin_plan_type_name IS NOT NULL  OR  px_fin_plan_type_id IS NOT NULL)) THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_BUDGET_FP_BOTH_NOT_NULL');
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info both are provided';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --product_code is mandatory
      IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      OR p_pm_product_code IS NULL
      THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                    PA_INTERFACE_UTILS_PUB.map_new_amg_msg
                    ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
              END IF;
              IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'PM Product code is missing';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      ELSE --p_pm_product_code is not null

            OPEN p_product_code_csr (p_pm_product_code);
            FETCH p_product_code_csr INTO l_pm_product_code;
            CLOSE p_product_code_csr;
            IF l_pm_product_code <> 'X'
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'GENERAL'
                       ,p_attribute1       => ''
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PM Product code is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  x_return_status             := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
      END IF;-- p_pm_product_code IS NULL


      -- convert pm_project_reference to id
      Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => px_pa_project_id,
         p_out_project_id        => px_pa_project_id_tmp,      /* Bug 7498493 */
         p_return_status         => x_return_status );

        IF px_pa_project_id_tmp IS NOT NULL then        /* Bug 7498493 */
          px_pa_project_id := px_pa_project_id_tmp;
        END IF;

      IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected error while deriving project id';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF x_return_status = FND_API.G_RET_STS_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Error while deriving project id';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := px_pa_project_id;

      -- Get the segment 1 of the project so that it can be used in the
      -- later part of the code
      OPEN l_amg_project_csr( px_pa_project_id );
      FETCH l_amg_project_csr INTO x_project_number;
      CLOSE l_amg_project_csr;


      -- Bug 4588279, 27-SEP-05, jwhite -----------------------------------------
      -- Initialize for Budget LINE Conditional Validation

      -- Storing -99 here is essential for proper Budget LINE conditional validation
      -- for both the budget_type and FP models.

            PA_BUDGET_PUB.G_Latest_Encumbrance_Year := -99;


      -- End Bug 4588279, 27-SEP-05, jwhite -----------------------------------------




      -- Do the validations required for the BUDGET_TYPE_CODE budget model
      IF (px_budget_type_code IS NOT NULL)  THEN


            --Check for the security
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                               p_api_version_number => p_api_version_number
                                              ,p_project_id         => px_pa_project_id
                                              ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET
                                              ,p_function_name      => p_function_name
                                              ,p_version_type       => null
                                              ,x_return_status      => x_return_status
                                              ,x_ret_code           => l_security_ret_code );

            -- the above API adds the error message to stack. Hence the message is not added here.
            -- Also, as security check is important further validations are not done in case this
            -- validation fails.
            IF (x_return_status<>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code = 'N') THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Security API Failed';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Verify Budget Type and get the budget amount code.
            OPEN  l_budget_amount_code_csr( px_budget_type_code );
            FETCH l_budget_amount_code_csr
            INTO  x_budget_amount_code;

            IF l_budget_amount_code_csr%NOTFOUND
            THEN
                  CLOSE l_budget_amount_code_csr;
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                          ,p_msg_attribute    => 'CHANGE'
                          ,p_resize_flag      => 'N'
                          ,p_msg_context      => 'BUDG'
                          ,p_attribute1       => x_project_number
                          ,p_attribute2       => ''
                          ,p_attribute3       => px_budget_type_code
                          ,p_attribute4       => ''
                          ,p_attribute5       => '');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Budget type is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                  CLOSE l_budget_amount_code_csr;
            END IF; --End of l_budget_amount_code_csr%NOTFOUND


            --Verify that the budget is not of type FORECASTING_BUDGET_TYPE
            IF px_budget_type_code='FORECASTING_BUDGET_TYPE' THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_EDIT_FCST_BUD_TYPE');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget of type FORECASTING_BUDGET_TYPE' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Budgetary Control Check
            -- Bug 4588279, 27-SEP-05, jwhite -----------------------------------------

            -- If project/budget-type enabled for budgetary control, then a package spec
            -- global is used for budget LINE validation by the lower-level
            -- pa_budget_check_pvt.GET_VALID_PERIOD_DATES_PVT procedure.



            --Check if budgetary control is enabled for the given project and
            --budget type code.
            PA_BUDGET_FUND_PKG.get_budget_ctrl_options
                            ( p_project_Id       => px_pa_project_id
                            , p_budget_type_code => px_budget_type_code
                            , p_calling_mode     => 'BUDGET'
                            , x_fck_req_flag     => l_fck_req_flag
                            , x_bdgt_intg_flag   => l_bdgt_intg_flag
                            , x_bdgt_ver_id      => l_bdgt_ver_id
                            , x_encum_type_id    => l_encum_type_id
                            , x_balance_type     => l_balance_type
                            , x_return_status    => x_return_status
                            , x_msg_data         => x_msg_data
                            , x_msg_count        => x_msg_count
                            );

            -- calling api above adds the error message to stack hence not adding the error message here.
            IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'get_budget_ctrl_options returned unexp error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF x_return_status = FND_API.G_RET_STS_ERROR
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'get_budget_ctrl_options returned  error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  l_any_error_occurred_flag := 'Y';
            END IF;


            --If funds check is required then this budget cannot be inserted or updated thru AMG interface
              --FOR PERIOD_YEARS THAT FALL AFTER THE LATEST ENCUMBRANCE YEAR.
              --Deletes are OK.


            IF (nvl(l_fck_req_flag,'N') = 'Y')
            THEN

                 --RE-Populate global for subsequent conditional budget LINE validation
                 --  Storing a value other than -99 is essential to conditional LINE validation

                 PA_BUDGET_PVT.Get_Latest_BC_Year
                     ( p_pa_project_id            => px_pa_project_id
                       ,x_latest_encumbrance_year => PA_BUDGET_PUB.G_Latest_Encumbrance_Year
                       ,x_return_status           => x_return_status
                       ,x_msg_count               => x_msg_count
                       ,x_msg_data                => x_msg_data
                      );


                 -- calling api above adds the error message to stack hence not adding the error message here.
                 IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
                 THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Get_Latest_BC_Year returned unexp error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF x_return_status = FND_API.G_RET_STS_ERROR
                 THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Get_Latest_BC_Year returned  error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   l_any_error_occurred_flag := 'Y';
                 END IF;


              /* Since PA.M, this rule no longer applies for bugetary control
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_BC_BGT_TYPE_IS_BAD_AMG'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'BUDG'
                       ,p_attribute1       => x_project_number
                       ,p_attribute2       => ''
                       ,p_attribute3       => px_budget_type_code
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');

                      x_return_status := FND_API.G_RET_STS_ERROR;
                      l_any_error_occurred_flag := 'Y';
                  END IF;
               */

            END IF; --(nvl(l_fck_req_flag,'N') = 'Y')


            -- Bug 4588279, 27-SEP-05, jwhite -----------------------------------------


            --Get the budget_version_id, budget_entry_method_code and resource_list_id
            --from table pa_budget_version
            OPEN l_budget_version_csr( px_pa_project_id
                                     , px_budget_type_code );
            FETCH l_budget_version_csr
            INTO  x_budget_version_id
            ,     x_budget_entry_method_code
            ,     x_resource_list_id;

            IF l_budget_version_csr%NOTFOUND
            THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                         pa_interface_utils_pub.map_new_amg_msg
                          ( p_old_message_code => 'PA_NO_BUDGET_VERSION'
                           ,p_msg_attribute    => 'CHANGE'
                           ,p_resize_flag      => 'N'
                           ,p_msg_context      => 'BUDG'
                           ,p_attribute1       => x_project_number
                           ,p_attribute2       => ''
                           ,p_attribute3       => px_budget_type_code
                           ,p_attribute4       => ''
                           ,p_attribute5       => '');
                 END IF;

                 CLOSE l_budget_version_csr;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;--l_budget_version_csr%NOTFOUND

            CLOSE l_budget_version_csr;

            --entry method code is mandatory
            IF x_budget_entry_method_code IS NULL
            OR x_budget_entry_method_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        (p_old_message_code => 'PA_ENTRY_METHOD_IS_MISSING'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => x_project_number
                        ,p_attribute2       => ''
                        ,p_attribute3       => px_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Budget entry method is missing';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

            ELSE -- entry method is not null

                  -- check validity of this budget entry method code, and store associated fields in record
                  OPEN l_budget_entry_method_csr(x_budget_entry_method_code);
                  FETCH l_budget_entry_method_csr INTO x_fin_plan_level_code
                                                      ,x_categorization_code
                                                      ,x_time_phased_code;

                  IF  l_budget_entry_method_csr%NOTFOUND
                  THEN
                        CLOSE l_budget_entry_method_csr;
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                pa_interface_utils_pub.map_new_amg_msg
                               ( p_old_message_code => 'PA_ENTRY_METHOD_IS_INVALID'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'BUDG'
                                ,p_attribute1       => x_project_number
                                ,p_attribute2       => ''
                                ,p_attribute3       => px_budget_type_code
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'Budget entry method is invalid';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                  ELSE
                        CLOSE l_budget_entry_method_csr;
                  END IF;--l_budget_entry_method_csr%NOTFOUND

            END IF;--x_budget_entry_method_code IS NULL


      ELSE -- Validations for fin plan model

      			px_fin_plan_type_id_in := px_fin_plan_type_id; --Bug 6920539

            PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
                                           ( p_fin_plan_type_id    => px_fin_plan_type_id_in
                                            ,p_fin_plan_type_name  => px_fin_plan_type_name
                                            ,x_fin_plan_type_id    => px_fin_plan_type_id
                                            ,x_return_status       => x_return_status
                                            ,x_msg_count           => x_msg_count
                                            ,x_msg_data            => x_msg_data);

            -- Throw the error if the above API is not successfully executed
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Cannot get the value of Fin Plan Type Id' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --We need to check use_for_workplan_flag as workplan versions
            --cannot be edited using this AMG interface.
            --reset the value of l_dummy
            l_dummy := 0;
            OPEN l_use_for_wp_csr( px_fin_plan_type_id );
            FETCH l_use_for_wp_csr INTO l_dummy;
            CLOSE l_use_for_wp_csr;

            IF l_dummy = 1
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_EDIT_WP_DATA');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Fin Plan Type Id is used for WP' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;



            -- Derive the version type. An error will be thrown by this api if preference code is
            -- COST_AND_REV_SEP and version type is not passed
            pa_fin_plan_utils.get_version_type
                 ( p_project_id        => px_pa_project_id
                  ,p_fin_plan_type_id  => px_fin_plan_type_id
                  ,px_version_type     => px_version_type
                  ,x_return_status     => x_return_status
                  ,x_msg_count         => x_msg_count
                  ,x_msg_data          => x_msg_data);

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Failed in get_Version_type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --if the budget version belongs to an org forecasting project then throw an error
            IF px_version_type = 'ORG_FORECAST' THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_ORG_FCST_PLAN_TYPE');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Org_Forecast plan type has been passed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  x_return_status    := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF; --org_forecast

            --Check function security
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                         p_api_version_number => p_api_version_number
                                        ,p_project_id         => px_pa_project_id
                                        ,p_fin_plan_type_id   => px_fin_plan_type_id
                                        ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                                        ,p_function_name      => p_function_name
                                        ,p_version_type       => px_version_type
                                        ,x_return_status      => x_return_status
                                        ,x_ret_code           => l_security_ret_code );

            IF (x_return_status <>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code='N') THEN
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Derive the fin plan version id based on the unique combination of
            --project id, fin plan type id, version type and version number
            IF   p_budget_version_number IS NOT NULL
            AND  p_budget_Version_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            THEN

                  OPEN l_finplan_version_id_csr( px_pa_project_id
                                                ,px_fin_plan_type_id
                                                ,px_version_type
                                                ,p_budget_version_number);
                  FETCH l_finplan_version_id_csr INTO x_budget_version_id;
                  CLOSE l_finplan_version_id_csr;

            ELSE --p_budget_version_number IS NULL

                  -- Fetch the current working version for the project, finplan type and verion type
                  PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                      p_project_id           =>   px_pa_project_id
                     ,p_fin_plan_type_id     =>   px_fin_plan_type_id
                     ,p_version_type         =>   px_version_type
                     ,x_fp_options_id        =>   l_dummy
                     ,x_fin_plan_version_id  =>   x_budget_version_id
                     ,x_return_status        =>   x_return_status
                     ,x_msg_count            =>   x_msg_count
                     ,x_msg_data             =>   x_msg_data );

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Get_Curr_Working_Version_Info api Failed ' ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

            END IF; --p_budget_version_number IS NOT NULL

            --If budget version id can't be found throw appropriate error message
            IF x_budget_version_id IS NULL OR x_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            THEN
                  --Throw appropriate error message
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_NO_WORKING_VERSION',
                                  p_token1         => 'PROJECT',
                                  p_value1         =>  x_project_number,
                                  p_token2         => 'PLAN_TYPE',
                                  p_value2         =>  px_fin_plan_type_name,
                                  p_token3         => 'VERSION_NUMBER',
                                  p_value3         =>  p_budget_Version_number );
                  END IF;

                  IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Budget Version does not exist' ;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;--x_budget_version_id IS NULL

            --Calling PA_FIN_PLAN_UTILS.validate_editable_bv API to check
            --if the budget version is locked by another user/process
            --or Edit after initial baseline setup is true and baseline
            --versions exist.

            pa_fin_plan_utils.validate_editable_bv
                       (p_budget_version_id   => x_budget_version_id,
                        p_user_id             => FND_GLOBAL.user_id,
                        p_context             => PA_FP_CONSTANTS_PKG.G_AMG_API,
                        x_locked_by_person_id => l_locked_by_persion_id,
                        x_err_code            => l_val_err_code,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data);

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'This budget version can not be edited';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Get the plan type level settings so that they can be passed as out parameters
            OPEN l_proj_fp_options_csr( px_pa_project_id
                                      , px_fin_plan_type_id
                                      , px_version_type
                                      , x_budget_version_id);
            FETCH l_proj_fp_options_csr
            INTO  x_plan_in_multi_curr_flag
                  ,x_fin_plan_level_code
                  ,x_resource_list_id
                  ,x_time_phased_code;

            --Control will never really enter this IF block since this check is
            --already made inside pa_fin_plan_utils.get_version_type before
            --control reaches here
            IF (l_proj_fp_options_csr%NOTFOUND) THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_PLAN_TYPE_OPTION',
                                 p_token1         => 'PROJECT',
                                 p_value1         =>  x_project_number,
                                 p_token2         => 'PLAN_TYPE',
                                 p_value2         =>  px_fin_plan_type_name);
                  END IF;
                  CLOSE l_proj_fp_options_csr;
                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Plan type is not yet added to the project';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            ELSE
                  CLOSE l_proj_fp_options_csr;
            END IF;--(l_proj_fp_options_csr%NOTFOUND)


      END IF; -- END OF CHECKS FOR FINPLAN MODEL


      -- check validity of the budget change reason code, passing NULL is OK
      IF (p_change_reason_code IS NOT NULL AND
          p_change_reason_code  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
      THEN
            OPEN l_budget_change_reason_csr( p_change_reason_code );
            FETCH l_budget_change_reason_csr INTO l_dummy1;

            IF px_budget_type_code IS NULL  THEN
                  l_context_info := px_fin_plan_type_name;
            ELSE
                  l_context_info := px_budget_type_code;
            END IF;

            IF l_budget_change_reason_csr%NOTFOUND THEN
                  CLOSE l_budget_change_reason_csr;

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CHANGE_REASON_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => x_project_number
                        ,p_attribute2       => ''
                        ,p_attribute3       => l_context_info
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Invalid Change Reason code ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

            ELSE
                  CLOSE l_budget_change_reason_csr;
            END IF;
      END IF;--p_change_reason_code IS NOT NULL


      -- Call the api that performs the autobaseline checks
      PA_FIN_PLAN_UTILS.PERFORM_AUTOBASLINE_CHECKS (
         p_budget_version_id  =>   x_budget_version_id
        ,x_result             =>   l_result
        ,x_return_status      =>   x_return_status
        ,x_msg_count          =>   x_msg_count
        ,x_msg_data           =>   x_msg_data       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'Auto baseline API falied';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_result = 'F' THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'Auto baselining enabled for the project';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 PA_UTILS.ADD_MESSAGE(
                         p_app_short_name  => 'PA'
                        ,p_msg_name        => 'PA_FP_AB_AR_VER_NON_EDITABLE'
                        ,p_token1          => 'PROJECT'
                        ,p_value1          => x_project_number);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      --Check if the Budget version has any processing errors.
      PA_FIN_PLAN_UTILS.return_and_vldt_plan_prc_code
          (p_add_msg_to_stack      => 'Y'
          ,p_calling_context       => 'BUDGET'
          ,p_budget_version_id     => x_budget_version_id
          ,x_final_plan_prc_code   => l_plan_processing_code
          ,x_targ_request_id       => l_targ_request_id
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'return_and_vldt_plan_prc_code API falied';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

/* Plan Amount Entry flags validations start : bug 6408139 */
  IF px_budget_type_code IS NULL THEN -- for plan versions only, we are checking the flags

      px_raw_cost_flag         :=  NVL (px_raw_cost_flag,'N');
      px_burdened_cost_flag    :=  NVL (px_burdened_cost_flag,'N');
      px_revenue_flag          :=  NVL (px_revenue_flag,'N');
      px_cost_qty_flag         :=  NVL (px_cost_qty_flag,'N');
      px_revenue_qty_flag      :=  NVL (px_revenue_qty_flag,'N');
      px_all_qty_flag          :=  NVL (px_all_qty_flag,'N');
      px_bill_rate_flag        :=  NVL (px_bill_rate_flag,'N');
      px_cost_rate_flag        :=  NVL (px_cost_rate_flag,'N');
      px_burden_rate_flag      :=  NVL (px_burden_rate_flag,'N');

      /* Skip the validations if all are passed as G_PA_MISS_CHAR */
      IF (( px_raw_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( px_burdened_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_revenue_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_cost_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_revenue_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_all_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_bill_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_cost_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
      ( px_burden_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) ) THEN

          /*Get the existing plan amount entry flags for the plan version*/
      l_amount_set_id := PA_FIN_PLAN_UTILS.get_amount_set_id(x_budget_version_id);

      PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS(
                      P_AMOUNT_SET_ID      => l_amount_set_id
                     ,X_RAW_COST_FLAG      => lx_raw_cost_flag
                     ,X_BURDENED_FLAG      => lx_burdened_cost_flag
                     ,X_REVENUE_FLAG       => lx_revenue_flag
                     ,X_COST_QUANTITY_FLAG => lx_cost_qty_flag
                     ,X_REV_QUANTITY_FLAG  => lx_revenue_qty_flag
                     ,X_ALL_QUANTITY_FLAG  => lx_all_qty_flag
                     ,X_BILL_RATE_FLAG     => lx_bill_rate_flag
                     ,X_COST_RATE_FLAG     => lx_cost_rate_flag
                     ,X_BURDEN_RATE_FLAG   => lx_burden_rate_flag
                     ,x_message_count      => x_msg_count
                     ,x_return_status      => x_return_status
                     ,x_message_data       => x_msg_data) ;

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                         -- RAISE  FND_API.G_EXC_ERROR;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

          IF ( px_raw_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
            px_raw_cost_flag := lx_raw_cost_flag;
          END IF ;

          IF ( px_burdened_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
           px_burdened_cost_flag := lx_burdened_cost_flag;
          END IF ;

      IF ( px_revenue_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
           px_revenue_flag := lx_revenue_flag;
          END IF ;

      IF ( px_cost_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
           px_cost_qty_flag := lx_cost_qty_flag;
          END IF ;

      IF ( px_revenue_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
           px_revenue_qty_flag := lx_revenue_qty_flag;
          END IF ;

      IF ( px_all_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
           px_all_qty_flag := lx_all_qty_flag;
          END IF ;

      IF ( px_bill_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
            px_bill_rate_flag :=  lx_bill_rate_flag;
          END IF ;

      IF ( px_cost_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
            px_cost_rate_flag := lx_cost_rate_flag;
          END IF ;

      IF ( px_burden_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
            px_burden_rate_flag := lx_burden_rate_flag;
          END IF ;


        IF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN

                  IF( px_raw_cost_flag     NOT IN ('Y','N')) OR
                    ( px_burdened_cost_flag NOT IN ('Y','N')) OR
                    ( px_cost_qty_flag     NOT IN ('Y','N')) OR
            ( px_bill_rate_flag <> 'N' ) OR
            ( px_cost_rate_flag    NOT IN ('Y','N')) OR
            ( px_burden_rate_flag  NOT IN ('Y','N')) THEN

            PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  x_project_number,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  px_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid values for amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                  END IF;


                  IF( px_raw_cost_flag     = 'N') AND
                    ( px_burdened_cost_flag = 'N') AND
                    ( px_cost_qty_flag     = 'N') THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                  END IF;

            ELSIF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ) THEN

                  IF( px_revenue_flag     NOT IN ('Y','N')) OR
                    ( px_revenue_qty_flag NOT IN ('Y','N')) OR
            ( px_bill_rate_flag   NOT IN ('Y','N')) OR
            ( px_cost_rate_flag   <> 'N') OR
            ( px_burden_rate_flag <> 'N')THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  x_project_number,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  px_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid value for the amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;


                  IF( px_revenue_flag     ='N') AND
                    ( px_revenue_qty_flag ='N') THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

            ELSIF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL ) THEN

                  IF( px_raw_cost_flag      NOT IN ('Y','N')) OR
                    ( px_burdened_cost_flag NOT IN ('Y','N')) OR
                    ( px_revenue_flag       NOT IN ('Y','N')) OR
                    ( px_all_qty_flag       NOT IN ('Y','N')) OR
            ( px_bill_rate_flag     NOT IN ('Y','N')) OR
            ( px_cost_rate_flag     NOT IN ('Y','N')) OR
            ( px_burden_rate_flag   NOT IN ('Y','N')) THEN

                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_AMT_FLAGS',
                              p_token1         => 'PROJECT',
                              p_value1         =>  x_project_number,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  px_fin_plan_type_name);
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Invalid value for the amount flags ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

                 IF( px_raw_cost_flag     ='N') AND
                    ( px_burdened_cost_flag='N') AND
                    ( px_revenue_flag      ='N') AND
                    ( px_cost_qty_flag     = 'N') AND			--Fix for 7172129
                    ( px_revenue_qty_flag ='N') AND
                    ( px_all_qty_flag      ='N') THEN

                        PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_NO_PLAN_AMT_CHECKED');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_any_error_occurred_flag := 'Y';
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'None of the amount flags are Y ';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                  END IF;

            END IF; -- px_version_type checks

      END IF ; -- G_PA_MISS_CHAR condition

  END IF ; --IF px_budget_type_code IS NULL

/* Plan Amount Entry flags validations end : bug 6408139*/

      -- Stop further processing if any errors are reported
      IF(l_any_error_occurred_flag='Y') THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'About to display all the messages';
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag := 'Y';
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF(l_debug_mode='Y') THEN
            pa_debug.g_err_stage := 'Leaving validate_header_info';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      IF x_return_status IS NULL
      OR x_return_status =  FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      x_msg_count := FND_MSG_PUB.count_msg;

      IF x_msg_count = 1 AND x_msg_data IS NULL THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => x_msg_count,
                  p_msg_data       => x_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_count := l_msg_index_out;
            x_msg_data  := l_data;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

      RETURN;

      WHEN FND_API.G_EXC_ERROR
      THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  x_msg_count ,
          p_data      =>  x_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  x_msg_count ,
          p_data      =>  x_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
      ( p_pkg_name       => 'PA_BUDGET_PVT'
      ,p_procedure_name  => 'VALIDATE_HEADER_INFO'
      ,p_error_text      => sqlerrm);

      IF l_debug_mode = 'Y' THEN
            pa_debug.G_Err_Stack := SQLERRM;
            pa_debug.reset_curr_function;
      END IF;
      RAISE;

END Validate_Header_Info;


----------------------------------------------------------------------------------------
--Name:               insert_budget_line
--Type:               Procedure
--Description:        This procedure can be used to insert a budgetline for
--                    an existing WORKING budget. Used by create_draft_budget
--                and add_budget_line.
--
--Called subprograms:
--                pa_budget_utils.create_line
--
--
--
--History:
--    18-NOV-1996        L. de Werker    Created
--
--    11-Feb-2002        Srikanth        Modified as part of the changes for AMG in finplan model
--    10-AUG-2003        bvarnasi        Bug 3062294 : rectified many bugs. See bug for more details.
--    22-OCT-2003        Rajagopal       bug 2998221 : Included call to validate_budget_lines api
--                                       for validations. l_budget_lines_in_tbl is a in/out plsql table
--                                       which stamps task_id derived from task_reference etc. So, use
--                                       values from l_budget_lines_in_tbl while calling create_line api
--    29-APR-2005        rishukla        Bug 4224464: FP M Changes: Added parameter p_change_reason_code
--                                       to insert_budget_line API.

PROCEDURE insert_budget_line
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference         IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias            IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_member_id                 IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date         IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date           IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                   IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_line_reference  IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id          IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_time_phased_type_code     IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_level_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_amount_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_entry_method_code  IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_categorization_code       IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_id         IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_change_reason_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )--Bug 4224464

IS

   l_return_status                        VARCHAR2(1);
   l_api_name                 CONSTANT    VARCHAR2(30)            := 'insert_budget_line';
   l_resource_assignment_id               NUMBER;
   l_unit_of_measure                      VARCHAR2(30);
   l_track_as_labor_flag                  VARCHAR2(1);
   l_attribute_category                   VARCHAR2(30);
   l_attribute1                           VARCHAR2(150);
   l_attribute2                           VARCHAR2(150);
   l_attribute3                           VARCHAR2(150);
   l_attribute4                           VARCHAR2(150);
   l_attribute5                           VARCHAR2(150);
   l_attribute6                           VARCHAR2(150);
   l_attribute7                           VARCHAR2(150);
   l_attribute8                           VARCHAR2(150);
   l_attribute9                           VARCHAR2(150);
   l_attribute10                          VARCHAR2(150);
   l_attribute11                          VARCHAR2(150);
   l_attribute12                          VARCHAR2(150);
   l_attribute13                          VARCHAR2(150);
   l_attribute14                          VARCHAR2(150);
   l_attribute15                          VARCHAR2(150);
   l_err_code                             NUMBER;
   l_err_stage                            VARCHAR2(120);
   l_err_stack                            VARCHAR2(630);
   l_amg_segment1                         VARCHAR2(25);
   l_amg_task_number                      VARCHAR2(50);
   l_quantity                             NUMBER;
   l_raw_cost                             NUMBER;
   l_burdened_cost                        NUMBER;
   l_revenue                              NUMBER;
--  Following local variables added as part of bug 3062294
   l_pa_task_id                           pa_resource_assignments.task_id%TYPE;
   l_pm_task_ref                          pa_tasks.pm_task_reference%TYPE;
   l_resource_alias                       pa_resource_list_members.alias%TYPE; -- bug 3711693
   l_rlm_id                               pa_resource_list_members.resource_list_member_id%TYPE;
   l_budget_start_date                    pa_budget_lines.start_date%TYPE;
   l_budget_end_date                      pa_budget_lines.start_date%TYPE;
   l_period_name                          pa_budget_lines.period_name%TYPE;
   l_description                          pa_budget_lines.description%TYPE;
   l_pm_budget_line_reference             pa_budget_lines.pm_budget_line_reference%TYPE;
   l_change_reason_code                   pa_budget_lines.change_reason_code%TYPE;

   l_budget_lines_in_tbl                  PA_BUDGET_PUB.G_BUDGET_LINES_IN_TBL%TYPE; /* bug 2998221 */
   l_budget_lines_out_tbl                 PA_BUDGET_PUB.G_BUDGET_LINES_OUT_TBL%TYPE;
   i                                      NUMBER;
   l_msg_data                             VARCHAR2(2000);
   l_msg_count                            NUMBER;
   l_debug_mode                           VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
   l_module_name                          VARCHAR2(80) := 'add_budget_line: ' || g_module_name;
--   l_fp_type_id                           pa_budget_versions.fin_plan_type_id%TYPE; --3569883
--   l_old_model                            VARCHAR2(1):=null; --3569883

   -- added for bug Bug 3986129: FP.M Web ADI Dev changes
   l_mfc_cost_type_id_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
   l_etc_method_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
   l_spread_curve_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

   l_version_info_rec                    pa_fp_gen_amount_utils.fp_cols;
   l_pm_product_code                     VARCHAR2(30);
   l_task_id                             NUMBER;

      --needed to get the field values associated to a AMG message

      CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
      IS
      SELECT   segment1
      FROM     pa_projects p
      WHERE p.project_id = p_pa_project_id;

      --needed to get the unit_of_measure and track_as_labor_flag for this resource_list_member
      --and check for valid resource_list / member combination

      CURSOR l_resource_csr
            (c_resource_list_member_id NUMBER
            ,c_resource_list_id        NUMBER)
      IS
      SELECT pr.unit_of_measure
            ,prlm.track_as_labor_flag
      FROM   pa_resources pr
            ,pa_resource_lists prl
            ,pa_resource_list_members prlm
      WHERE  prl.resource_list_id = c_resource_list_id
      AND    pr.resource_id = prlm.resource_id
      AND    prl.resource_list_id = prlm.resource_list_id
      AND    prlm.resource_list_member_id = c_resource_list_member_id;

BEGIN
      --Standard begin of API savepoint

      SAVEPOINT insert_budget_line_pvt;

      --Set API return status to success

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      --get unit_of_measure and track_as_labor_flag associated to
      --the resource member and check whether this is a valid member for this list
      OPEN l_resource_csr( p_member_id
                          ,p_resource_list_id     );
      FETCH l_resource_csr INTO l_unit_of_measure, l_track_as_labor_flag;
      IF l_resource_csr%NOTFOUND
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                  pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_LIST_MEMBER_INVALID'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'BUDG'
                  ,p_attribute1       => l_amg_segment1
                  ,p_attribute2       => l_amg_task_number
                  ,p_attribute3       => p_budget_type_code
                  ,p_attribute4       => ''
                  ,p_attribute5       => to_char(p_budget_start_date));
            END IF;

            CLOSE l_resource_csr;
            p_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;

      ELSE
            CLOSE l_resource_csr;

      END IF;

      /*****************************
       Bug 3218822 - PM_PRODUCT_CODE could be Null. We need valid it if it is NOT NULL.
         This will be done in validate_budget_lines.

      -- bug 3062294
      --product_code is mandatory : this validation was missing altogether
      IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         OR p_pm_product_code IS NULL
      THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                    pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
                      dbms_output.put_line('MSG count in the stack ' || FND_MSG_PUB.count_msg);
                      dbms_output.put_line('added msg to stack');
                      dbms_output.put_line('MSG count in the stack 2 ' || FND_MSG_PUB.count_msg);
              END IF;
              p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      -- bug 3062294

      Bug 3218822 - PM_PRODUCT_CODE could be Null. We need valid it if it is NOT NULL
      *****************************/

      --Get the segment1 of the project so that it can be used later
      OPEN l_amg_project_csr(p_pa_project_id);
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;

      --Get the task number

        --Fixed for bug 5060391
            IF (p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_task_id := NULL;
            ELSE
                l_task_id  := p_pa_task_id;
            END IF;
            l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
                                      ( p_task_number=> ''
                                       ,p_task_reference => p_pm_task_reference
                                       ,p_task_id => l_task_id);

      --When descriptive flex fields are not passed set them to NULL
      IF p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute_category := NULL;
      ELSE
            l_attribute_category := p_attribute_category;
      END IF;

      IF p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute1 := NULL;
      ELSE
            l_attribute1 := p_attribute1;
      END IF;

      IF p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute2 := NULL;
      ELSE
            l_attribute2 := p_attribute2;
      END IF;

      IF p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute3 := NULL;
      ELSE
            l_attribute3 := p_attribute3;
      END IF;

      IF p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute4 := NULL;
      ELSE
            l_attribute4 := p_attribute4;
      END IF;

      IF p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute5 := NULL;
      ELSE
            l_attribute5 := p_attribute5;
      END IF;

      IF p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute6 := NULL;
      ELSE
            l_attribute6 := p_attribute6;
      END IF;

      IF p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute7 := NULL;
      ELSE
            l_attribute7 := p_attribute7;
      END IF;

      IF p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute8 := NULL;
      ELSE
            l_attribute8 := p_attribute8;
      END IF;

      IF p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute9 := NULL;
      ELSE
            l_attribute9 := p_attribute9;
      END IF;

      IF p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute10 := NULL;
      ELSE
            l_attribute10 := p_attribute10;
      END IF;

      IF p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute11 := NULL;
      ELSE
            l_attribute11 := p_attribute11;
      END IF;

      IF p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute12 := NULL;
      ELSE
            l_attribute12 := p_attribute12;
      END IF;

      IF p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute13 := NULL;
      ELSE
            l_attribute13 := p_attribute13;
      END IF;

      IF p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute14:= NULL;
      ELSE
            l_attribute14:= p_attribute14;
      END IF;

      IF p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_attribute15 := NULL;
      ELSE
            l_attribute15 := p_attribute15;
      END IF;


      --Remove big numbers in case parameters were not passed, default to NULL; Assign Valid
      --Values to local variables.

      IF p_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_quantity := null;
      ELSE
            l_quantity := p_quantity;
      END IF;

      IF p_raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_raw_cost := null;
      ELSE
            l_raw_cost := p_raw_cost;
      END IF;

      IF p_burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_burdened_cost := null;
      ELSE
            l_burdened_cost := p_burdened_cost;
      END IF;

      IF p_revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_revenue := null;
      ELSE
            l_revenue := p_revenue;
      END IF;
      -- extending this null assignment to all other parameters passed as part
      -- of p_budget_lines_rec (as defined in pa_budget_pub)
      -- Added for bug 3062294 :

      IF p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_pa_task_id := null;
      ELSE
            l_pa_task_id := p_pa_task_id;
      END IF;

      IF p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_pm_task_ref := null;
      ELSE
            l_pm_task_ref := p_pm_task_reference;
      END IF;

      IF p_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_resource_alias := null;
      ELSE
            l_resource_alias := p_resource_alias;
      END IF;

      IF p_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
            l_rlm_id := null;
      ELSE
            l_rlm_id := p_member_id;
      END IF;

      IF p_budget_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
      THEN
            l_budget_start_date := null;
      ELSE
            l_budget_start_date := p_budget_start_date;
      END IF;

      IF p_budget_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
      THEN
            l_budget_end_date := null;
      ELSE
            l_budget_end_date := p_budget_end_date;
      END IF;

      IF p_period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_period_name := null;
      ELSE
            l_period_name := p_period_name;
      END IF;

      IF p_description  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_description := null;
      ELSE
            l_description := p_description;
      END IF;

      IF p_pm_budget_line_reference  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_pm_budget_line_reference := null;
      ELSE
            l_pm_budget_line_reference := p_pm_budget_line_reference;
      END IF;

      --Bug 4224464
      IF p_change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_change_reason_code := NULL;
      ELSE
            l_change_reason_code := p_change_reason_code;
      END IF;

      IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_pm_product_code := NULL;
      ELSE
            l_pm_product_code := p_pm_product_code;
      END IF;

      IF (l_quantity IS NULL AND l_raw_cost IS NULL AND l_burdened_cost IS NULL AND p_budget_amount_code = 'C')
      OR (l_quantity IS NULL AND l_revenue IS NULL  AND p_budget_amount_code = 'R')
      THEN
            NULL;  --we don't insert budget lines with all zero's

      ELSE

            /**** Validation checks introduced for the bug 2998221 starts here   ****/

            -- Initialize l_budget_lines_tbl with the budget line details
            -- The table would contain only one record

            i :=  1;

            l_budget_lines_in_tbl(i).pa_task_id                    :=      l_pa_task_id;
            l_budget_lines_in_tbl(i).pm_task_reference             :=      l_pm_task_ref;
            l_budget_lines_in_tbl(i).resource_alias                :=      l_resource_alias;
            l_budget_lines_in_tbl(i).resource_list_member_id       :=      l_rlm_id;
            l_budget_lines_in_tbl(i).budget_start_date             :=      l_budget_start_date ;
            l_budget_lines_in_tbl(i).budget_end_date               :=      l_budget_end_date ;
            l_budget_lines_in_tbl(i).period_name                   :=      l_period_name;
            l_budget_lines_in_tbl(i).description                   :=      l_description ;
            l_budget_lines_in_tbl(i).raw_cost                      :=      l_raw_cost;
            l_budget_lines_in_tbl(i).burdened_cost                 :=      l_burdened_cost;
            l_budget_lines_in_tbl(i).revenue                       :=      l_revenue;
            l_budget_lines_in_tbl(i).quantity                      :=      l_quantity;
            l_budget_lines_in_tbl(i).pm_product_code               :=      l_pm_product_code;
            l_budget_lines_in_tbl(i).pm_budget_line_reference      :=      l_pm_budget_line_reference;
            l_budget_lines_in_tbl(i).attribute_category            :=      l_attribute_category ;
            l_budget_lines_in_tbl(i).attribute1                    :=      l_attribute1 ;
            l_budget_lines_in_tbl(i).attribute2                    :=      l_attribute2 ;
            l_budget_lines_in_tbl(i).attribute3                    :=      l_attribute3 ;
            l_budget_lines_in_tbl(i).attribute4                    :=      l_attribute4 ;
            l_budget_lines_in_tbl(i).attribute5                    :=      l_attribute5 ;
            l_budget_lines_in_tbl(i).attribute6                    :=      l_attribute6 ;
            l_budget_lines_in_tbl(i).attribute7                    :=      l_attribute7 ;
            l_budget_lines_in_tbl(i).attribute8                    :=      l_attribute8 ;
            l_budget_lines_in_tbl(i).attribute9                    :=      l_attribute9 ;
            l_budget_lines_in_tbl(i).attribute10                   :=      l_attribute10;
            l_budget_lines_in_tbl(i).attribute11                   :=      l_attribute11;
            l_budget_lines_in_tbl(i).attribute12                   :=      l_attribute12;
            l_budget_lines_in_tbl(i).attribute13                   :=      l_attribute13;
            l_budget_lines_in_tbl(i).attribute14                   :=      l_attribute14;
            l_budget_lines_in_tbl(i).attribute15                   :=      l_attribute15;
            l_budget_lines_in_tbl(i).txn_currency_code             :=      null;
            l_budget_lines_in_tbl(i).projfunc_cost_rate_type       :=      null;
            l_budget_lines_in_tbl(i).projfunc_cost_rate_date_type  :=      null;
            l_budget_lines_in_tbl(i).projfunc_cost_rate_date       :=      null;
            l_budget_lines_in_tbl(i).projfunc_cost_exchange_rate   :=      null;
            l_budget_lines_in_tbl(i).projfunc_rev_rate_type        :=      null;
            l_budget_lines_in_tbl(i).projfunc_rev_rate_date_type   :=      null;
            l_budget_lines_in_tbl(i).projfunc_rev_rate_date        :=      null;
            l_budget_lines_in_tbl(i).projfunc_rev_exchange_rate    :=      null;
            l_budget_lines_in_tbl(i).project_cost_rate_type        :=      null;
            l_budget_lines_in_tbl(i).project_cost_rate_date_type   :=      null;
            l_budget_lines_in_tbl(i).project_cost_rate_date        :=      null;
            l_budget_lines_in_tbl(i).project_cost_exchange_rate    :=      null;
            l_budget_lines_in_tbl(i).project_rev_rate_type         :=      null;
            l_budget_lines_in_tbl(i).project_rev_rate_date_type    :=      null;
            l_budget_lines_in_tbl(i).project_rev_rate_date         :=      null;
            l_budget_lines_in_tbl(i).project_rev_exchange_rate     :=      null;
            l_budget_lines_in_tbl(i).change_reason_code            :=      l_change_reason_code;--Bug 4224464

--3569883 start
--    select fin_plan_type_id
--      into l_fp_type_id
--          from pa_budget_versions
--         where budget_version_id = p_budget_version_id;
--
--      select DECODE(l_fp_type_id, null, 'Y','N') into l_old_model from dual;
----3569883 end

            --Bug 4224464: FP.M Changes for Validate_Budget_Lines
            --Send the budget version id to validate_budget_lines API for
            --actuals on FORECAST check
            IF p_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  l_version_info_rec.x_budget_version_id := null;
            ELSE
                  l_version_info_rec.x_budget_version_id := p_budget_version_id;
            END IF;

            -- Call validate_budget_lines api
            pa_budget_pvt.Validate_Budget_Lines
                    ( p_pa_project_id               => p_pa_project_id
                     ,p_budget_type_code            => p_budget_type_code
                     ,p_fin_plan_type_id            => NULL
                     ,p_version_type                => NULL
                     ,p_resource_list_id            => p_resource_list_id
                     ,p_time_phased_code            => p_time_phased_type_code
                     ,p_budget_entry_method_code    => p_budget_entry_method_code
                     ,p_entry_level_code            => p_entry_level_code
                     ,p_allow_qty_flag              => NULL
                     ,p_allow_raw_cost_flag         => NULL
                     ,p_allow_burdened_cost_flag    => NULL
                     ,p_allow_revenue_flag          => NULL
                     ,p_multi_currency_flag         => NULL
                     ,p_project_cost_rate_type      => NULL
                     ,p_project_cost_rate_date_typ  => NULL
                     ,p_project_cost_rate_date      => NULL
                     ,p_project_cost_exchange_rate  => NULL
                     ,p_projfunc_cost_rate_type     => NULL
                     ,p_projfunc_cost_rate_date_typ => NULL
                     ,p_projfunc_cost_rate_date     => NULL
                     ,p_projfunc_cost_exchange_rate => NULL
                     ,p_project_rev_rate_type       => NULL
                     ,p_project_rev_rate_date_typ   => NULL
                     ,p_project_rev_rate_date       => NULL
                     ,p_project_rev_exchange_rate   => NULL
                     ,p_projfunc_rev_rate_type      => NULL
                     ,p_projfunc_rev_rate_date_typ  => NULL
                     ,p_projfunc_rev_rate_date      => NULL
                     ,p_projfunc_rev_exchange_rate  => NULL
                     ,p_version_info_rec            => l_version_info_rec
                     ,px_budget_lines_in            => l_budget_lines_in_tbl
                     ,x_budget_lines_out            => l_budget_lines_out_tbl
--                     ,x_old_model                   => l_old_model --3569883
                     ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                     ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                     ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                     ,x_msg_count                   => l_msg_count
                     ,x_msg_data                    => l_msg_data
                     ,x_return_status               => l_return_status);

            IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   RAISE  FND_API.G_EXC_ERROR;
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Validate Budget Lines got executed successfully';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            /**** Validation checks introduced for the bug 2998221 starts here   ****/

           --create budget line
--      dbms_output.put_line('before create_line revenue = '|| l_revenue || ' raw cost '||l_raw_cost || 'l_burdened_cost '||l_burdened_cost||' l_quantity  ' || l_quantity);

            pa_budget_utils.create_line
                  (x_budget_version_id          => p_budget_version_id
                  ,x_project_id                 => p_pa_project_id
                  ,x_task_id                    => l_budget_lines_in_tbl(i).pa_task_id --bug 2998221  l_pa_task_id
                  ,x_resource_list_member_id    => l_budget_lines_in_tbl(i).resource_list_member_id --bug 2998221 l_rlm_id
                  ,x_description                => l_description
                  ,x_start_date                 => l_budget_lines_in_tbl(i).budget_start_date --bug 2998221 l_budget_start_date
                  ,x_end_date                   => l_budget_lines_in_tbl(i).budget_end_date   --bug 2998221 l_budget_end_date
                  ,x_period_name                => l_budget_lines_in_tbl(i).period_name       --bug 2998221 l_period_name
                  ,x_quantity                   => l_quantity
                  ,x_unit_of_measure            => l_unit_of_measure
                  ,x_track_as_labor_flag        => l_track_as_labor_flag
                  ,x_raw_cost                   => l_raw_cost
                  ,x_burdened_cost              => l_burdened_cost
                  ,x_revenue                    => l_revenue
                  ,x_change_reason_code         => l_change_reason_code --Bug 4224464
                  ,x_attribute_category         => l_attribute_category
                  ,x_attribute1                 => l_attribute1
                  ,x_attribute2                 => l_attribute2
                  ,x_attribute3                 => l_attribute3
                  ,x_attribute4                 => l_attribute4
                  ,x_attribute5                 => l_attribute5
                  ,x_attribute6                 => l_attribute6
                  ,x_attribute7                 => l_attribute7
                  ,x_attribute8                 => l_attribute8
                  ,x_attribute9                 => l_attribute9
                  ,x_attribute10                => l_attribute10
                  ,x_attribute11                => l_attribute11
                  ,x_attribute12                => l_attribute12
                  ,x_attribute13                => l_attribute13
                  ,x_attribute14                => l_attribute14
                  ,x_attribute15                => l_attribute15
                  -- Bug Fix: 4569365. Removed MRC code.
                  -- ,x_mrc_flag                   => 'Y' /* FPB2: MRC */
                  ,x_resource_assignment_id     => l_resource_assignment_id
                  ,x_err_code                   => l_err_code
                  ,x_err_stage                  => l_err_stage
                  ,x_err_stack                  => l_err_stack
                  ,x_pm_product_code            => l_pm_product_code
                  ,x_pm_budget_line_reference   =>  l_budget_lines_in_tbl(i).pm_budget_line_reference  --bug 2998221 l_pm_budget_line_reference
                  ,x_quantity_source            => 'I'
                  ,x_raw_cost_source            => 'I'
                  ,x_burdened_cost_source       => 'I'
                  ,x_revenue_source             => 'I' );

      --dbms_output.put_line('After create_line');
      --dbms_output.put_line('Error code: '||l_err_code);
      --dbms_output.put_line('Error Stage: '||l_err_stage);
      --dbms_output.put_line('Error Stack: '||l_err_stack);

            IF l_err_code > 0
            then

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN

                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_CREATE_LINE_FAILED'
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => l_amg_task_number
                              ,p_attribute3       => p_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => to_char(p_budget_start_date));
                        ELSE
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => l_err_stage
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => l_amg_task_number
                              ,p_attribute3       => p_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => to_char(p_budget_start_date));
                        END IF;

                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0
            THEN

                  IF l_err_code = -1   --special handling of duplicate line error
                  THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_BUDGET_LINE_ALREADY_EXISTS'
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'Y'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => l_amg_task_number
                              ,p_attribute3       => p_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => to_char(p_budget_start_date));
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN

                              FND_MSG_PUB.add_exc_msg
                              (  p_pkg_name           => 'PA_BUDGET_UTILS'
                              ,  p_procedure_name     => 'CREATE_LINE'
                              ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

            END IF;
   END IF;  --all zero's

EXCEPTION

      WHEN FND_API.G_EXC_ERROR
      THEN

            ROLLBACK TO insert_budget_line_pvt;

            p_return_status := FND_API.G_RET_STS_ERROR;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN

            ROLLBACK TO insert_budget_line_pvt;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

            ROLLBACK TO insert_budget_line_pvt;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                  FND_MSG_PUB.add_exc_msg
                  (  p_pkg_name           => G_PKG_NAME
                  ,  p_procedure_name     => l_api_name );

            END IF;

END insert_budget_line;


----------------------------------------------------------------------------------------
--Name:               update_budget_line_sql
--Type:               Procedure
--Description:        This procedure is be build a update statement for a budgetline.
--
--
--Called subprograms: PA_BUDGET_PVT.check_entry_method_flags
--
--
--
--
--History:
--    19-NOV-1996   L. de Werker    Created
--
--    04-FEB-2003   gjain           Bug 2756050: Modified the code which generates
--                                  the dynamic sql to append additional quotes before
--                                  and after the numeric columns like raw_cost,
--                                  burdened_cost,revenue,quantity
--    10-MAY-2005   Ritesh Shukla   Bug 4224464- This procedure has been modified extensively
--                                  during FP.M changes for AMG. If you do not want to update
--                                  a parameter then either do not pass it or pass its value
--                                  as NULL, and if you want to null out a parameter then
--                                  pass it as FND_API.G_MISS_XXX
--    13-MAY-2005   Ritesh Shukla   Bug 4224464-Removed parameter p_budget_amount_code from
--                                  procedure update_budget_line_sql since it has become redundant.

PROCEDURE update_budget_line_sql
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_entry_method_code  IN    VARCHAR2
 ,p_resource_assignment_id    IN    NUMBER
 ,p_start_date                IN    DATE
 ,p_time_phased_type_code     IN    VARCHAR2
 ,p_description               IN    VARCHAR2
 ,p_quantity                  IN    NUMBER
 ,p_raw_cost                  IN    NUMBER
 ,p_burdened_cost             IN    NUMBER
 ,p_revenue                   IN    NUMBER
 ,p_change_reason_code        IN    VARCHAR2
 ,p_attribute_category        IN    VARCHAR2
 ,p_attribute1                IN    VARCHAR2
 ,p_attribute2                IN    VARCHAR2
 ,p_attribute3                IN    VARCHAR2
 ,p_attribute4                IN    VARCHAR2
 ,p_attribute5                IN    VARCHAR2
 ,p_attribute6                IN    VARCHAR2
 ,p_attribute7                IN    VARCHAR2
 ,p_attribute8                IN    VARCHAR2
 ,p_attribute9                IN    VARCHAR2
 ,p_attribute10               IN    VARCHAR2
 ,p_attribute11               IN    VARCHAR2
 ,p_attribute12               IN    VARCHAR2
 ,p_attribute13               IN    VARCHAR2
 ,p_attribute14               IN    VARCHAR2
 ,p_attribute15               IN    VARCHAR2
)

IS

   --needed to get the current data of a budget line

   CURSOR l_budget_line_csr
        (p_resource_assigment_id NUMBER
        ,p_budget_start_date     DATE )
   IS
   SELECT pa_budget_lines.*, rowid
   FROM   pa_budget_lines
   WHERE  resource_assignment_id = p_resource_assigment_id
   AND    start_date = p_budget_start_date;

--cursor added as part of fix for Bug#1406799 to check the burdened_cost_flag

  CURSOR l_budget_entry_method_csr
(p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type)
  IS
  SELECT burdened_cost_flag
  FROM pa_budget_entry_methods
  WHERE budget_entry_method_code = p_budget_entry_method_code
  AND    trunc(sysdate)
  BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));


   l_return_status                        VARCHAR2(1);
   l_api_name                 CONSTANT    VARCHAR2(30)            := 'update_budget_line_sql';
   l_budget_line_rec                      l_budget_line_csr%rowtype;

 --used by dynamic SQL
   l_statement                            VARCHAR2(2000);
   l_update_yes_flag                      VARCHAR2(1) := 'N';
   l_rows                           NUMBER;
   l_cursor_id                            NUMBER;
-- added as part of fix for Bug#1406799 to check for burdened_cost_flag
   l_burdened_cost_flag                         VARCHAR2(1) := 'Y';

   /* FPB2: MRC */
   l_budget_line_id                            PA_BUDGET_LINES.BUDGET_LINE_ID%type;
   l_budget_version_id                         PA_BUDGET_LINES.BUDGET_VERSION_ID%type;
   l_txn_currency_code                         PA_BUDGET_LINES.TXN_CURRENCY_CODE%type;
   l_msg_count          NUMBER := 0;
   l_msg_data           VARCHAR2(2000);


BEGIN

    --  Standard begin of API savepoint

    SAVEPOINT update_budget_line_sql_pvt;

    --  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --get the current values for this budget line

    OPEN l_budget_line_csr( p_resource_assignment_id, p_start_date );
    FETCH l_budget_line_csr INTO l_budget_line_rec;
    CLOSE l_budget_line_csr;

--dbms_output.put_line('Building the dynamic SQL statement');

    --building the dynamic SQL statement
    -- Changes made by Xin Liu for using of SQL BIND VARIABLE 12-MAY-2003

    l_statement := ' UPDATE PA_BUDGET_LINES SET ';

--dbms_output.put_line('p_description             : '||p_description);
--dbms_output.put_line('l_budget_line_rec.description: '||l_budget_line_rec.description);

    IF  p_description IS NOT NULL
    AND p_description <> nvl(l_budget_line_rec.description,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' DESCRIPTION = :xDescription'||',';
            l_update_yes_flag := 'Y';
    END IF;

--dbms_output.put_line('New Raw cost: '||nvl(to_char(p_raw_cost),'NULL'));
--dbms_output.put_line('Old Raw cost: '||nvl(to_char(l_budget_line_rec.raw_cost),'NULL'));

    IF p_raw_cost IS NOT NULL
    AND p_raw_cost <> nvl(l_budget_line_rec.raw_cost,FND_API.G_MISS_NUM)
    THEN
            l_statement := l_statement ||
                           ' RAW_COST = :xRawCost'||',';

            l_update_yes_flag := 'Y';
    END IF;

    -- code added as part of fix for Bug#1406799. To check for burdened_cost_flag.
    OPEN l_budget_entry_method_csr( p_budget_entry_method_code );
    FETCH l_budget_entry_method_csr INTO l_burdened_cost_flag;
    CLOSE l_budget_entry_method_csr;

    IF l_burdened_cost_flag = 'N'  -- added for burden_distributed_cost ='N'
    THEN
/* Bug 2864086 - Added this check for p_raw_cost before updating burdened cost with the p_raw_cost */

          IF p_raw_cost IS NOT NULL
          AND p_raw_cost <> nvl(l_budget_line_rec.burdened_cost,FND_API.G_MISS_NUM)
          THEN
                l_statement := l_statement ||
                               ' BURDENED_COST = :xRawCostForB'||',';

                l_update_yes_flag := 'Y';
         END If;
    ELSE

        IF p_burdened_cost IS NOT NULL
        AND p_burdened_cost <> nvl(l_budget_line_rec.burdened_cost,FND_API.G_MISS_NUM)
        THEN
                l_statement := l_statement ||
                               ' BURDENED_COST = :xBurdenedCost'||',';

                l_update_yes_flag := 'Y';
        END IF;
    END IF;--l_burdened_cost_flag = 'N'

    IF p_revenue IS NOT NULL
    AND p_revenue <> nvl(l_budget_line_rec.revenue,FND_API.G_MISS_NUM)
    THEN
            l_statement := l_statement ||
                           ' REVENUE = :xRevenue'||',';

            l_update_yes_flag := 'Y';
    END IF;

    IF p_quantity IS NOT NULL
    AND p_quantity <> nvl(l_budget_line_rec.quantity,FND_API.G_MISS_NUM)
    THEN
            l_statement := l_statement ||
                           ' QUANTITY = :xQuantity'||',';

            l_update_yes_flag := 'Y';
    END IF;

    IF  p_change_reason_code IS NOT NULL
    AND p_change_reason_code <> nvl(l_budget_line_rec.change_reason_code,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' CHANGE_REASON_CODE = :xChangeReasonCode'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute_category IS NOT NULL
    AND p_attribute_category <> nvl(l_budget_line_rec.attribute_category,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY = :xAttributeCategory'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute1 IS NOT NULL
    AND p_attribute1 <> nvl(l_budget_line_rec.attribute1,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE1 = :xAttribute1'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute2 IS NOT NULL
    AND p_attribute2 <> nvl(l_budget_line_rec.attribute2,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE2 = :xAttribute2'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute3 IS NOT NULL
    AND p_attribute3 <> nvl(l_budget_line_rec.attribute3,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE3 = :xAttribute3'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute4 IS NOT NULL
    AND p_attribute4 <> nvl(l_budget_line_rec.attribute4,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE4 = :xAttribute4'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute5 IS NOT NULL
    AND p_attribute5 <> nvl(l_budget_line_rec.attribute5,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE5 = :xAttribute5'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute6 IS NOT NULL
    AND p_attribute6 <> nvl(l_budget_line_rec.attribute6,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE6 = :xAttribute6'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute7 IS NOT NULL
    AND p_attribute7 <> nvl(l_budget_line_rec.attribute7,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE7 = :xAttribute7'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute8 IS NOT NULL
    AND p_attribute8 <> nvl(l_budget_line_rec.attribute8,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE8 = :xAttribute8'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute9 IS NOT NULL
    AND p_attribute9 <> nvl(l_budget_line_rec.attribute9,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE9 = :xAttribute9'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute10 IS NOT NULL
    AND p_attribute10 <> nvl(l_budget_line_rec.attribute10,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE10 = :xAttribute10'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute11 IS NOT NULL
    AND p_attribute11 <> nvl(l_budget_line_rec.attribute11,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE11 = :xAttribute11'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute12 IS NOT NULL
    AND p_attribute12 <> nvl(l_budget_line_rec.attribute12,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE12 = :xAttribute12'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute13 IS NOT NULL
    AND p_attribute13 <> nvl(l_budget_line_rec.attribute13,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE13 = :xAttribute13'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute14 IS NOT NULL
    AND p_attribute14 <> nvl(l_budget_line_rec.attribute14,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE14 = :xAttribute14'||',';
            l_update_yes_flag := 'Y';
    END IF;

    IF  p_attribute15 IS NOT NULL
    AND p_attribute15 <> nvl(l_budget_line_rec.attribute15,FND_API.G_MISS_CHAR)
    THEN
            l_statement := l_statement ||
                           ' ATTRIBUTE15 = :xAttribute15'||',';
            l_update_yes_flag := 'Y';
    END IF;


    /* FPB2: MRC
           - This code is used only in the old model
           - Txn_currency_code will always be the projfunc_currency_code
           - Adding txn_currency_code in update for more clarity to indicate the update will
             always update just one record. We get the budget_line_id of the updated record
             and pass to mrc api */

    BEGIN
      SELECT projfunc_currency_code
      INTO   l_txn_currency_code
      FROM   pa_projects_all a, pa_budget_versions b, pa_resource_Assignments c
      WHERE  a.project_id = b.project_id
      AND    b.budget_version_id = c.budget_version_id
      AND    c.resource_assignment_id = p_resource_assignment_id
      AND    b.ci_id IS NULL;    -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause b.ci_id IS NULL --Bug # 3507156

    EXCEPTION
       WHEN OTHERS THEN
          /* May the resource assignment id passed is not correct ! */
         l_txn_currency_code := null;
    END;

    IF l_update_yes_flag = 'Y'
    THEN
        l_statement := l_statement ||
                       ' LAST_UPDATE_DATE = :xLastUpdateDate'||',';

        l_statement := l_statement ||
                       ' LAST_UPDATED_BY = '||G_USER_ID||',';

        l_statement := l_statement ||
                       ' LAST_UPDATE_LOGIN = '||G_LOGIN_ID||',';

        l_statement := SUBSTR(l_statement,1,LENGTH(l_statement)-1);

        l_statement := l_statement ||
          ' WHERE RESOURCE_ASSIGNMENT_ID  = '||TO_CHAR(p_resource_assignment_id) ||
          ' AND START_DATE = :xStartDate' ||
          ' AND TXN_CURRENCY_CODE = ' || '''' || l_txn_currency_code || ''''; /* FPB2: MRC */

--dbms_output.put_line('Opening the cursor');
--dbms_output.put_line(to_char(length(l_statement)));
--dbms_output.put_line('Statement: '||substr(l_statement,1,100));
--dbms_output.put_line('Statement: '||substr(l_statement,101,100));
--dbms_output.put_line('Statement: '||substr(l_statement,201,100));

        l_cursor_id := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(l_cursor_id, l_statement, DBMS_SQL.native);

        IF  p_description IS NOT NULL
          AND p_description <> nvl(l_budget_line_rec.description,FND_API.G_MISS_CHAR)
        THEN
              IF p_description = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xDescription', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xDescription', p_description);
              END IF;
        END IF;

        IF p_raw_cost IS NOT NULL
           AND p_raw_cost <> nvl(l_budget_line_rec.raw_cost,FND_API.G_MISS_NUM)
        THEN
              IF p_raw_cost = FND_API.G_MISS_NUM THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRawCost', TO_NUMBER(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRawCost', p_raw_cost);
              END IF;
        END IF;

        IF l_burdened_cost_flag = 'N'  -- added for burden_distributed_cost ='N'
        THEN

          IF p_raw_cost IS NOT NULL
          AND p_raw_cost <> nvl(l_budget_line_rec.burdened_cost,FND_API.G_MISS_NUM)
          THEN
              IF p_raw_cost = FND_API.G_MISS_NUM THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRawCostForB', TO_NUMBER(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRawCostForB', p_raw_cost);
              END IF;
          END IF;

        ELSE

         IF p_burdened_cost IS NOT NULL
          AND p_burdened_cost <> nvl(l_budget_line_rec.burdened_cost,FND_API.G_MISS_NUM)
         THEN
              IF p_burdened_cost = FND_API.G_MISS_NUM THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xBurdenedCost', TO_NUMBER(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xBurdenedCost', p_burdened_cost);
              END IF;
         END IF;

        END IF;--l_burdened_cost_flag = 'N'

        IF p_revenue IS NOT NULL
         AND p_revenue <> nvl(l_budget_line_rec.revenue,FND_API.G_MISS_NUM)
        THEN
              IF p_revenue = FND_API.G_MISS_NUM THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRevenue',TO_NUMBER(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xRevenue',p_revenue);
              END IF;
        END IF;

        IF p_quantity IS NOT NULL
         AND p_quantity <> nvl(l_budget_line_rec.quantity,FND_API.G_MISS_NUM)
        THEN
              IF p_quantity = FND_API.G_MISS_NUM THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xQuantity',TO_NUMBER(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xQuantity',p_quantity);
              END IF;
        END IF;

        IF  p_change_reason_code IS NOT NULL
        AND p_change_reason_code <> nvl(l_budget_line_rec.change_reason_code,FND_API.G_MISS_CHAR)
        THEN
              IF p_change_reason_code = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xChangeReasonCode', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xChangeReasonCode', p_change_reason_code);
              END IF;
        END IF;

        IF  p_attribute_category IS NOT NULL
        AND p_attribute_category <> nvl(l_budget_line_rec.attribute_category,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute_category = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttributeCategory', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttributeCategory', p_attribute_category);
              END IF;
        END IF;

        IF  p_attribute1 IS NOT NULL
        AND p_attribute1 <> nvl(l_budget_line_rec.attribute1,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute1 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute1', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute1', p_attribute1);
              END IF;
        END IF;

        IF  p_attribute2 IS NOT NULL
        AND p_attribute2 <> nvl(l_budget_line_rec.attribute2,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute2 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute2', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute2', p_attribute2);
              END IF;
        END IF;

        IF  p_attribute3 IS NOT NULL
        AND p_attribute3 <> nvl(l_budget_line_rec.attribute3,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute3 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute3', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute3', p_attribute3);
              END IF;
        END IF;

        IF  p_attribute4 IS NOT NULL
        AND p_attribute4 <> nvl(l_budget_line_rec.attribute4,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute4 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute4', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute4', p_attribute4);
              END IF;
        END IF;

        IF  p_attribute5 IS NOT NULL
        AND p_attribute5 <> nvl(l_budget_line_rec.attribute5,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute5 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute5', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute5', p_attribute5);
              END IF;
        END IF;

        IF  p_attribute6 IS NOT NULL
        AND p_attribute6 <> nvl(l_budget_line_rec.attribute6,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute6 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute6', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute6', p_attribute6);
              END IF;
        END IF;

        IF  p_attribute7 IS NOT NULL
        AND p_attribute7 <> nvl(l_budget_line_rec.attribute7,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute7 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute7', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute7', p_attribute7);
              END IF;
        END IF;

        IF  p_attribute8 IS NOT NULL
        AND p_attribute8 <> nvl(l_budget_line_rec.attribute8,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute8 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute8', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute8', p_attribute8);
              END IF;
        END IF;

        IF  p_attribute9 IS NOT NULL
        AND p_attribute9 <> nvl(l_budget_line_rec.attribute9,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute9 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute9', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute9', p_attribute9);
              END IF;
        END IF;

        IF  p_attribute10 IS NOT NULL
        AND p_attribute10 <> nvl(l_budget_line_rec.attribute10,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute10 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute10', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute10', p_attribute10);
              END IF;
        END IF;

        IF  p_attribute11 IS NOT NULL
        AND p_attribute11 <> nvl(l_budget_line_rec.attribute11,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute11 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute11', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute11', p_attribute11);
              END IF;
        END IF;

        IF  p_attribute12 IS NOT NULL
        AND p_attribute12 <> nvl(l_budget_line_rec.attribute12,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute12 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute12', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute12', p_attribute12);
              END IF;
        END IF;

        IF  p_attribute13 IS NOT NULL
        AND p_attribute13 <> nvl(l_budget_line_rec.attribute13,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute13 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute13', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute13', p_attribute13);
              END IF;
        END IF;

        IF  p_attribute14 IS NOT NULL
        AND p_attribute14 <> nvl(l_budget_line_rec.attribute14,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute14 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute14', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute14', p_attribute14);
              END IF;
        END IF;

        IF  p_attribute15 IS NOT NULL
        AND p_attribute15 <> nvl(l_budget_line_rec.attribute15,FND_API.G_MISS_CHAR)
        THEN
              IF p_attribute15 = FND_API.G_MISS_CHAR THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute15', TO_CHAR(NULL));
              ELSE
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xAttribute15', p_attribute15);
              END IF;
        END IF;

        --Dates should always be bound instead of concatenating them as strings to
        --avoid conversion problems.
        DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xLastUpdateDate', SYSDATE);
        DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xStartDate', p_start_date);


        l_rows   := DBMS_SQL.execute(l_cursor_id);

--dbms_output.put_line('# rows processed: '||l_rows);

        IF DBMS_SQL.is_open (l_cursor_id)
        THEN
            DBMS_SQL.close_cursor (l_cursor_id);
        END IF;

            /* FPB2: MRC */
        BEGIN
             SELECT budget_line_id, budget_version_id --Bug 4224464
             INTO   l_budget_line_id, l_budget_version_id
             FROM   pa_budget_lines
             WHERE  resource_assignment_id = p_resource_assignment_id
             AND    start_date = p_start_date
             AND    txn_currency_code = l_txn_currency_code;
        EXCEPTION
             WHEN no_data_found THEN
                l_budget_line_id := null; /* No budget line was updated */
        END;
        -- Bug Fix: 4569365. Removed MRC code.

        /* FPB2: Proceed with MRC only if a budget line was update */
        --Bug 4224464: changed IF condition to determine whether update has happened or not
        /*
         IF nvl(l_rows,0) > 0 THEN

             IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                    PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                              (x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg_data);
             END IF;

             IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                  PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                             (p_budget_line_id => l_budget_line_id,
                              p_budget_version_id => l_budget_version_id,
                              p_action         => PA_MRC_FINPLAN.G_ACTION_UPDATE,
                              x_return_status  => l_return_status,
                              x_msg_count      => l_msg_count,
                              x_msg_data       => l_msg_data);
             END IF;

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE g_mrc_exception;
             END IF;

         END IF;--nvl(l_rows,0) > 0
         */
         --need to check for zero or null values in the case of a PA or GL phased budget
         --if so budget line needs to be deleted.

--dbms_output.put_line('raw cost: '||NVL(to_char(l_budget_line_rec.raw_cost),'NULL'));
--dbms_output.put_line('burdened cost: '||NVL(to_char(l_budget_line_rec.burdened_cost),'NULL'));
--dbms_output.put_line('revenue: '||NVL(to_char(l_budget_line_rec.revenue),'NULL'));
--dbms_output.put_line('quantity: '||NVL(to_char(l_budget_line_rec.quantity),'NULL'));

         IF p_time_phased_type_code IN ('G','P')
         THEN

            OPEN l_budget_line_csr( p_resource_assignment_id
                                 ,p_start_date  );

            FETCH l_budget_line_csr INTO l_budget_line_rec;
            CLOSE l_budget_line_csr;

--dbms_output.put_line('raw cost: '||NVL(to_char(l_budget_line_rec.raw_cost),'NULL'));
--dbms_output.put_line('burdened cost: '||NVL(to_char(l_budget_line_rec.burdened_cost),'NULL'));
--dbms_output.put_line('revenue: '||NVL(to_char(l_budget_line_rec.revenue),'NULL'));
--dbms_output.put_line('quantity: '||NVL(to_char(l_budget_line_rec.quantity),'NULL'));

            IF  NVL(l_budget_line_rec.raw_cost,0) = 0
            AND NVL(l_budget_line_rec.burdened_cost,0) = 0
            AND NVL(l_budget_line_rec.revenue,0) = 0
            AND NVL(l_budget_line_rec.quantity,0) = 0
            THEN

                  BEGIN
--dbms_output.put_line('About to delete the budget line because of zero values');
                  PA_BUDGET_LINES_V_PKG.delete_row
                        ( x_rowid => l_budget_line_rec.rowid );
                          -- Bug Fix: 4569365. Removed MRC code.
						  -- ,x_mrc_flag => 'Y'); /* FPB2: MRC */

                         -- Bug Fix: 4569365. Removed MRC code.
                        /* FPB2: MRC */
                        /*
                        IF nvl(l_rows,0) > 0 THEN--Calling MRC APIs only if a budget line was updated

                           IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                                  PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                            (x_return_status      => l_return_status,
                                             x_msg_count          => l_msg_count,
                                             x_msg_data           => l_msg_data);
                           END IF;

                           IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                              PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                                PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                           (p_budget_line_id => l_budget_line_rec.budget_line_id,
                                            p_budget_version_id => l_budget_line_rec.budget_version_id,
                                            p_action         => PA_MRC_FINPLAN.G_ACTION_DELETE,
                                            x_return_status  => l_return_status,
                                            x_msg_count      => l_msg_count,
                                            x_msg_data       => l_msg_data);
                           END IF;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE g_mrc_exception;
                           END IF;
                        END IF; --nvl(l_rows,0) > 0
                        */
                  --this exception part is here because this procedure doesn't handle the exceptions itself.
                  EXCEPTION
                  WHEN OTHERS
                  THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                              FND_MSG_PUB.add_exc_msg
                              (  p_pkg_name           => 'PA_BUDGET_LINES_V_PKG'
                              ,  p_procedure_name     => 'DELETE_ROW'
                              ,  p_error_text         => SQLCODE              );
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;

            END IF;
         END IF;  --time phased by PA or GL period
    END IF;--l_update_yes_flag = 'Y'

EXCEPTION

      WHEN FND_API.G_EXC_ERROR
      THEN

      ROLLBACK TO update_budget_line_sql_pvt;

      p_return_status := FND_API.G_RET_STS_ERROR;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN

      ROLLBACK TO update_budget_line_sql_pvt;

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

      ROLLBACK TO update_budget_line_sql_pvt;

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            FND_MSG_PUB.add_exc_msg
            (  p_pkg_name           => G_PKG_NAME
            ,  p_procedure_name     => l_api_name );

      END IF;


END update_budget_line_sql;


----------------------------------------------------------------------------------------
--Name:               get_valid_period_dates
--Type:               Procedure
--Description:        This procedure can be used to get the valid begin and end date
--                for a budget line
--
--
--Called subprograms:
--
--
--
--History:
--   10-OCT-1996         L. de Werker    Created
--   17-OCT-1996         L. de Werker    Parameter p_period_name_out added, to enable the translation
--                                       of begin and end date to a period name.
--   09-Nov-2004         dbora           Bug 3986129: FP.M Web ADI Dev changes
--                                       Modified to take care of the spec changes
--                                       of pa_budget_check_pvt.get_valid_period_dates_Pvt

PROCEDURE get_valid_period_dates
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_project_id                IN    NUMBER
 ,p_task_id                   IN    NUMBER
 ,p_time_phased_type_code     IN    VARCHAR2
 ,p_entry_level_code          IN    VARCHAR2
 ,p_period_name_in            IN    VARCHAR2
 ,p_budget_start_date_in      IN    DATE
 ,p_budget_end_date_in        IN    DATE
 ,p_period_name_out           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date_out     OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date_out       OUT   NOCOPY DATE --File.Sql.39 bug 4440895

-- Bug 3986129: FP.M Web ADI Dev changes
 ,p_context                IN   VARCHAR2
 ,p_calling_model_context     IN   VARCHAR2
 ,x_error_code             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

BEGIN

pa_budget_check_pvt.get_valid_period_dates_Pvt
(p_return_status                    => p_return_status
,p_project_id                       => p_project_id
,p_task_id                          => p_task_id
,p_time_phased_type_code            => p_time_phased_type_code
,p_entry_level_code                 => p_entry_level_code
,p_period_name_in                   => p_period_name_in
,p_budget_start_date_in             => p_budget_start_date_in
,p_budget_end_date_in               => p_budget_end_date_in
,p_period_name_out                  => p_period_name_out
,p_budget_start_date_out            => p_budget_start_date_out
,p_budget_end_date_out              => p_budget_end_date_out

-- Bug 3986129: FP.M Web ADI Dev changes
 ,p_context                         => p_context
 ,p_calling_model_context           => p_calling_model_context
 ,x_error_code                      => x_error_code);

END get_valid_period_dates;


----------------------------------------------------------------------------------------
--Name:               check_entry_method_flags
--Type:               Procedure
--Description:        This procedure can be used to check whether it is allowed to pass
--                cost quantity, raw_cost, burdened_cost, revenue and revenue quantity.
--
--
--Called subprograms:
--
--
--
--History:
--    15-OCT-1996        L. de Werker    Created
--    08-Nov-2004        dbora           Bug 3986129: FP.M Web ADI Dev changes
--                                       Modified to take care of the spec changes
--                                       of pa_budget_check_pvt.check_entry_method_flags_pvt

PROCEDURE check_entry_method_flags
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_amount_code        IN    VARCHAR2
 ,p_budget_entry_method_code  IN    VARCHAR2
 ,p_quantity                  IN    NUMBER
 ,p_raw_cost                  IN    NUMBER
 ,p_burdened_cost             IN    NUMBER
 ,p_revenue                   IN    NUMBER
 ,p_version_type              IN    VARCHAR2
 ,p_allow_qty_flag            IN    VARCHAR2
 ,p_allow_raw_cost_flag       IN    VARCHAR2
 ,p_allow_burdened_cost_flag  IN    VARCHAR2
 ,p_allow_revenue_flag        IN    VARCHAR2

-- Bug 3986129: FP.M Web ADI Dev changes, new parameters
 ,p_context                   IN  VARCHAR2
 ,p_raw_cost_rate             IN  NUMBER
 ,p_burdened_cost_rate        IN  NUMBER
 ,p_bill_rate                 IN  NUMBER
 ,p_allow_raw_cost_rate_flag  IN  VARCHAR2
 ,p_allow_burd_cost_rate_flag IN  VARCHAR2
 ,p_allow_bill_rate_flag      IN  VARCHAR2
 ,x_webadi_error_code         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

      pa_budget_check_pvt.check_entry_method_flags_pvt
      (p_return_status                => p_return_status
      ,p_budget_amount_code           => p_budget_amount_code
      ,p_budget_entry_method_code     => p_budget_entry_method_code
      ,p_quantity                     => p_quantity
      ,p_raw_cost                     => p_raw_cost
      ,p_burdened_cost                => p_burdened_cost
      ,p_revenue                      => p_revenue
      ,p_version_type                 => p_version_type
      ,p_allow_qty_flag               => p_allow_qty_flag
      ,p_allow_raw_cost_flag          => p_allow_raw_cost_flag
      ,p_allow_burdened_cost_flag     => p_allow_burdened_cost_flag
      ,p_allow_revenue_flag           => p_allow_revenue_flag

      --Bug 3986129: FP.M Web ADI Dev changes
      ,p_context                      => p_context
      ,p_raw_cost_rate                => p_raw_cost_rate
      ,p_burdened_cost_rate           => p_burdened_cost_rate
      ,p_bill_rate                    => p_bill_rate
      ,p_allow_raw_cost_rate_flag     => p_allow_raw_cost_rate_flag
      ,p_allow_burd_cost_rate_flag    => p_allow_burd_cost_rate_flag
      ,p_allow_bill_rate_flag         => p_allow_bill_rate_flag
      ,x_webadi_error_code            => x_webadi_error_code);


END check_entry_method_flags;


--This procedure is created as part of FinPlan Development. All the validations
--are shifted from insert_budget_line to this procedure. This procedure handles the
--validations for both budget and finplan models

-- sgoteti         14-Feb-03      Created
-- rravipat        24-Jun-04      Bug 3717093  Commented out the validation put
--                                included by hari on 11th may. The api is called
--                                with the same context for both old budgets model
--                                versions and nee budgets model versions.
-- rishukla        09-May-05      Bug 4224464: FP M Changes - Added validation for
--                                actual amounts on Forecast lines.
-- sgoteti         11-May-05      Added p_run_id parameter. This parameter will be used in web ADI flow only
PROCEDURE Validate_Budget_Lines
( p_calling_context                 IN     VARCHAR2 DEFAULT 'BUDGET_LINE_LEVEL_VALIDATION'
 ,p_run_id                          IN     pa_fp_webadi_upload_inf.run_id%TYPE
 ,p_pa_project_id                   IN     pa_projects_all.project_id%TYPE
 ,p_budget_type_code                IN     pa_budget_types.budget_type_code%TYPE
 ,p_fin_plan_type_id                IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_version_type                    IN     pa_budget_versions.version_type%TYPE
 ,p_resource_list_id                IN     pa_resource_lists_all_bg.resource_list_id%TYPE
 ,p_time_phased_code                IN     pa_proj_fp_options.cost_time_phased_code%TYPE
 ,p_budget_entry_method_code        IN     pa_budget_entry_methods.budget_entry_method_code%TYPE
 ,p_entry_level_code                IN     pa_proj_fp_options.cost_fin_plan_level_code%TYPE
 ,p_allow_qty_flag                  IN     VARCHAR2
 ,p_allow_raw_cost_flag             IN     VARCHAR2
 ,p_allow_burdened_cost_flag        IN     VARCHAR2
 ,p_allow_revenue_flag              IN     VARCHAR2
 ,p_multi_currency_flag             IN     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
 ,p_project_cost_rate_type          IN     pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_project_cost_rate_date_typ      IN     pa_proj_fp_options.project_cost_rate_date_type%TYPE
 ,p_project_cost_rate_date          IN     pa_proj_fp_options.project_cost_rate_date%TYPE
 ,p_project_cost_exchange_rate      IN     pa_budget_lines.project_cost_exchange_rate%TYPE
 ,p_projfunc_cost_rate_type         IN     pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_projfunc_cost_rate_date_typ     IN     pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
 ,p_projfunc_cost_rate_date         IN     pa_proj_fp_options.projfunc_cost_rate_date%TYPE
 ,p_projfunc_cost_exchange_rate     IN     pa_budget_lines.projfunc_cost_exchange_rate%TYPE
 ,p_project_rev_rate_type           IN     pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_project_rev_rate_date_typ       IN     pa_proj_fp_options.project_rev_rate_date_type%TYPE
 ,p_project_rev_rate_date           IN     pa_proj_fp_options.project_rev_rate_date%TYPE
 ,p_project_rev_exchange_rate       IN     pa_budget_lines.project_rev_exchange_rate%TYPE
 ,p_projfunc_rev_rate_type          IN     pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_projfunc_rev_rate_date_typ      IN     pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
 ,p_projfunc_rev_rate_date          IN     pa_proj_fp_options.projfunc_rev_rate_date%TYPE
 ,p_projfunc_rev_exchange_rate      IN     pa_budget_lines.project_rev_exchange_rate%TYPE

  /* Bug 3986129: FP.M Web ADI Dev changes: New parameters added */
 ,p_version_info_rec                IN     pa_fp_gen_amount_utils.fp_cols
 ,p_allow_raw_cost_rate_flag        IN     VARCHAR2
 ,p_allow_burd_cost_rate_flag       IN     VARCHAR2
 ,p_allow_bill_rate_flag            IN     VARCHAR2
 ,p_raw_cost_rate_tbl               IN     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_burd_cost_rate_tbl              IN     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_bill_rate_tbl                   IN     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_uom_tbl                         IN     SYSTEM.pa_varchar2_80_tbl_type := SYSTEM.pa_varchar2_80_tbl_type()
 ,p_planning_start_date_tbl         IN     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
 ,p_planning_end_date_tbl           IN     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
 ,p_delete_flag_tbl                 IN     SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type()
 ,p_mfc_cost_type_tbl               IN     SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
 ,p_spread_curve_name_tbl           IN     SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
 ,p_sp_fixed_date_tbl               IN     SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE()
 ,p_etc_method_name_tbl             IN     SYSTEM.PA_VARCHAR2_80_TBL_TYPE  := SYSTEM.PA_VARCHAR2_80_TBL_TYPE()
 ,p_spread_curve_id_tbl             IN     SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE()
 ,p_amount_type_tbl                 IN     SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
 /* Bug 3986129: end*/

 ,px_budget_lines_in                IN OUT NOCOPY PA_BUDGET_PUB.G_BUDGET_LINES_IN_TBL%TYPE --File.Sql.39 bug 4440895
 /* Bug 3133930- a new output variable is introduced to return the error status */
 ,x_budget_lines_out                OUT    NOCOPY PA_BUDGET_PUB.G_BUDGET_LINES_OUT_TBL%TYPE --File.Sql.39 bug 4440895
/* Bug 3986129: FP.M Web ADI Dev changes: New parameters added */
 ,x_mfc_cost_type_id_tbl            OUT    NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_etc_method_code_tbl             OUT    NOCOPY SYSTEM.pa_varchar2_30_tbl_type --File.Sql.39 bug 4440895
 ,x_spread_curve_id_tbl             OUT    NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

      --Declare a pl/sql table for storing the txn currencies of the plan type

      --l_valid_txn_currencies_tbl  pa_fp_webadi_pkg.l_txn_currency_code_tbl_typ;    Bug 2871603
      --Bug 2871603 - Created a package pvt defn for l_txn_currency_code_tbl_typ and using it.
      l_valid_txn_currencies_tbl  l_txn_currency_code_tbl_typ;

      --following table will contain the top task planning levels.
      l_top_tasks_tbl             key_value_rec_tbl_type;
      l_temp                      NUMBER;


      --This cursor is used to fetch the txn currencies of the plan type
      CURSOR l_plan_type_txn_curr_csr
             ( c_proj_fp_options_id  pa_fp_txn_currencies.proj_fp_options_id%TYPE
              ,c_project_id       pa_fp_txn_currencies.project_id%TYPE)
      IS
      SELECT txn_currency_code
      FROM   pa_fp_txn_currencies ptxn
            ,pa_projects_all p
      WHERE  p.project_id=c_project_id
      AND    ptxn.project_id = p.project_id
      AND    ptxn.txn_currency_code NOT IN (p.project_currency_code, p.projfunc_currency_code)
      AND    ptxn.proj_fp_options_id  = c_proj_fp_options_id;  --made changes to the sql for bug 4886319 (performance)


      -- this cursor is used to fetch the txn currencies of the plan version for web adi context
      CURSOR l_plan_ver_txn_curr_csr
             ( c_fin_plan_type_id      pa_fp_txn_currencies.fin_plan_type_id%TYPE
              ,c_project_id            pa_fp_txn_currencies.project_id%TYPE
              ,c_fin_plan_version_id   pa_fp_txn_currencies.fin_plan_version_id%TYPE)
      IS
      SELECT txn_currency_code
      FROM   pa_fp_txn_currencies ptxn
            ,pa_projects_all p
      WHERE  p.project_id = c_project_id
      AND    ptxn.project_id = p.project_id
      AND    ptxn.fin_plan_type_id = c_fin_plan_type_id
      AND    ptxn.txn_currency_code NOT IN (p.project_currency_code, p.projfunc_currency_code)
      AND    ptxn.fin_plan_version_id = c_fin_plan_version_id;

      --cursor to get the unit_of_measure and track_as_labor_flag for this resource_list_member
      --and check for valid resource_list / member combination
      CURSOR l_resource_csr
            (c_resource_list_member_id NUMBER
            ,c_resource_list_id        NUMBER)
      IS
      SELECT pr.unit_of_measure
            ,prlm.track_as_labor_flag
            ,prlm.migration_code
      FROM   pa_resources pr
            ,pa_resource_lists prl
            ,pa_resource_list_members prlm
      WHERE  prl.resource_list_id = c_resource_list_id
      AND    pr.resource_id = prlm.resource_id
      AND    prl.resource_list_id = prlm.resource_list_id
      AND    prlm.resource_list_member_id = c_resource_list_member_id;

      --cursor to get the unit_of_measure for FINPLAN Model - 3801891
      CURSOR l_resource_csr_fp
            (c_resource_list_member_id NUMBER)
      IS
      SELECT prlm.unit_of_measure,
             prlm.migration_code
      FROM   pa_resource_list_members prlm
      WHERE  prlm.resource_list_member_id = c_resource_list_member_id;

      --cursor to get the field values associated to a AMG message
      CURSOR l_amg_project_csr
             (c_pa_project_id pa_projects.project_id%type)
      IS
      SELECT segment1
      FROM   pa_projects p
      WHERE  p.project_id = c_pa_project_id;

      l_amg_project_rec     l_amg_project_csr%ROWTYPE;

      CURSOR l_amg_task_csr
            (c_pa_task_id pa_tasks.task_id%type)
      IS
      SELECT task_number
      FROM   pa_tasks p
      WHERE  p.task_id = c_pa_task_id;

      --This cursor is used to get the approved rev plan type flag of the plan type
      --Added as part of the changes for fin plan model in FP L
      CURSOR l_approved_revenue_flag_csr
                                        ( c_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE
                                         ,c_project_id pa_projects_all.project_id%TYPE)
      IS
      SELECT approved_rev_plan_type_flag,
             proj_fp_options_id
      FROM   pa_proj_fp_options
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    fin_plan_option_level_code=PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

      /* Bug 4224464: FP M Changes Start */
      --Cursor to derive plan_class_code and etc_start_date for a budget version
      CURSOR budget_version_info_cur (c_budget_version_id IN NUMBER)
      IS
      SELECT  pt.plan_class_code
             ,bv.etc_start_date
      FROM    pa_budget_versions bv,
              pa_fin_plan_types_b pt
      WHERE   bv.budget_version_id = c_budget_version_id
      AND     pt.fin_plan_type_id = bv.fin_plan_type_id;

      l_plan_class_code                   pa_fin_plan_types_b.plan_class_code%TYPE;
      l_etc_start_date                    pa_budget_versions.etc_start_date%TYPE;
      /* Bug 4224464: FP M Changes End */

      l_app_rev_plan_type_flag            pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;

      l_msg_count                         NUMBER := 0;
      l_data                              VARCHAR2(2000);
      l_msg_data                          VARCHAR2(2000);
      l_msg_index_out                     NUMBER;
      l_debug_mode                        VARCHAR2(1);

      l_debug_level2             CONSTANT NUMBER := 2;
      l_debug_level3             CONSTANT NUMBER := 3;
      l_debug_level4             CONSTANT NUMBER := 4;
      l_debug_level5             CONSTANT NUMBER := 5;

      l_return_status                     VARCHAR2(1);
      l_return_status_task                NUMBER;
      l_unit_of_measure                   VARCHAR2(30);
      l_track_as_labor_flag               VARCHAR2(1);
      l_err_code                          NUMBER;
      l_err_stage                         VARCHAR2(120);
      l_err_stack                         VARCHAR2(630);
      l_amg_segment1                      VARCHAR2(25);
      l_amg_task_number                   VARCHAR2(50);
      l_amg_top_task_number               VARCHAR2(50);
      l_any_error_occurred_flag           VARCHAR2(1) :='N';
      l_budget_lines_tbl_index            NUMBER;
      l_budget_amount_code                pa_budget_types.budget_amount_code%TYPE;
      l_txn_tbl_index                     NUMBER;
      i                                   NUMBER;
      l_valid_txn_curr                    BOOLEAN;
      l_txn_curr_code                     pa_fp_txn_currencies.txn_currency_code%TYPE;
      l_parent_member_id                  pa_resource_list_members.parent_member_id%TYPE;
      l_conv_attrs_to_be_validated        VARCHAR2(10);
      l_module_name                       VARCHAR2(80);
      l_top_task_id                       pa_tasks.top_task_id%TYPE;
      l_dummy                             VARCHAR2(1);
      l_txn_currency_code                 pa_fp_txn_currencies.txn_currency_code%TYPE;
      l_multi_currency_billing_flag       pa_projects_all.multi_currency_billing_flag%TYPE;
      l_project_currency_code             pa_projects_all.project_currency_code%TYPE      ;
      l_projfunc_currency_code            pa_projects_all.projfunc_currency_code%TYPE     ;
      l_project_cost_rate_type            pa_projects_all.project_rate_type%TYPE          ;
      l_projfunc_cost_rate_type           pa_projects_all.projfunc_cost_rate_type%TYPE    ;
      l_project_bil_rate_type             pa_projects_all.project_bil_rate_type%TYPE      ;
      l_projfunc_bil_rate_type            pa_projects_all.projfunc_bil_rate_type%TYPE     ;
      l_top_task_planning_level           pa_fp_elements.top_task_planning_level%TYPE;
      l_res_planning_level                pa_fp_elements.resource_planning_level%TYPE;
      l_uncategorized_res_list_id         pa_resource_list_members.resource_list_id%TYPE;
      l_uncategorized_rlmid               pa_resource_list_members.resource_list_member_id%TYPE;
      l_uncategorized_resid               pa_resource_list_members.resource_id%TYPE;
      l_res_group_name                    pa_resource_list_members.alias%TYPE;
      l_valid_rlmid                       VARCHAR2(1);
      l_fin_plan_type_name                pa_fin_plan_types_tl.name%TYPE;
      l_resource_type_code                pa_resource_list_members.resource_type_code%TYPE;
      l_context_info                      pa_fin_plan_types_tl.name%TYPE;
      l_pm_product_code                   pa_budget_lines.pm_product_code%TYPE;

      -- Cursor used in validating the product code
      Cursor p_product_code_csr (c_pm_product_code IN VARCHAR2)
      Is
      Select 'X'
      from   pa_lookups
      where  lookup_type='PM_PRODUCT_CODE'
      and    lookup_code = c_pm_product_code;

      -- Bug 3986129: FP.M Web ADI Dev changes
      l_spread_curve_id                   pa_spread_curves_b.spread_curve_id%TYPE;
      l_valid_spread_curve                VARCHAR2(1) := 'Y';
      l_etc_method_code                   pa_lookups.lookup_code%TYPE;
      l_valid_etc_method                  VARCHAR2(1) := 'Y';
      l_mfc_cost_type_id                  CST_COST_TYPES_V.cost_type_id%TYPE;
      l_valid_mfc_cost_type                VARCHAR2(1) := 'Y';

      l_webadi_sp_fix_date                DATE;
      l_webadi_err_code_tbl               SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_new_error_code                    pa_lookups.lookup_code%TYPE;
      l_webadi_err_task_id_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_webadi_err_rlm_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_webadi_err_txn_curr_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_webadi_err_amt_type_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_webadi_err_prd_flag               VARCHAR2(1) := 'N';
      l_webadi_cont_proc_flag             VARCHAR2(1):= 'Y';

      TYPE web_adi_err_code_lookup IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
      l_wa_error_code_lookup              web_adi_err_code_lookup;

      -- for bug 3954329
      l_rlm_migration_code             pa_resource_lists_all_bg.migration_code%TYPE;

      l_wa_project_cost_rate_typ               pa_proj_fp_options.project_cost_rate_type%TYPE;
      l_wa_project_cost_rate_dt_typ            pa_proj_fp_options.project_cost_rate_date_type%TYPE;
      l_wa_project_cost_rate_date              pa_proj_fp_options.project_cost_rate_date%TYPE;
      l_wa_project_cost_exc_rate               pa_budget_lines.project_cost_exchange_rate%TYPE;
      l_wa_projfunc_cost_rate_typ              pa_proj_fp_options.projfunc_cost_rate_type%TYPE;
      l_wa_projfunc_cost_rate_dt_typ           pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE;
      l_wa_projfunc_cost_rate_date             pa_proj_fp_options.projfunc_cost_rate_date%TYPE;
      l_wa_projfunc_cost_exc_rate              pa_budget_lines.projfunc_cost_exchange_rate%TYPE;
      l_wa_project_rev_rate_typ                pa_proj_fp_options.project_rev_rate_type%TYPE;
      l_wa_project_rev_rate_dt_typ             pa_proj_fp_options.project_rev_rate_date_type%TYPE;
      l_wa_project_rev_rate_date               pa_proj_fp_options.project_rev_rate_date%TYPE;
      l_wa_project_rev_exc_rate                pa_budget_lines.project_rev_exchange_rate%TYPE;
      l_wa_projfunc_rev_rate_typ               pa_proj_fp_options.projfunc_rev_rate_type%TYPE;
      l_wa_projfunc_rev_rate_dt_typ            pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE;
      l_wa_projfunc_rev_rate_date              pa_proj_fp_options.projfunc_rev_rate_date%TYPE;
      l_wa_projfunc_rev_exc_rate               pa_budget_lines.project_rev_exchange_rate%TYPE;
      l_wa_val_conv_attr_flag                  VARCHAR2(1);
      l_calling_model_context   VARCHAR(30);


     -- Added for the bug 4414062
      l_period_time_phased_code  VARCHAR(1);
      l_period_plan_start_date   DATE;
      l_period_plan_end_date     DATE;

      -- bug 4462614: add the following cursor to be executed for Web ADI flow
      -- to check if the budget lines passed belongs to a CI version
      CURSOR check_and_return_ci_version (c_budget_version_id     pa_budget_versions.budget_version_id%TYPE)
      IS
      SELECT pbv.ci_id,
             agr.agreement_currency_code
      FROM   pa_budget_versions pbv,
             pa_agreements_all agr
      WHERE  pbv.budget_version_id = c_budget_version_id
      AND    pbv.agreement_id = agr.agreement_id;

      l_webadi_agr_curr_code           pa_agreements_all.agreement_currency_code%TYPE;
      l_webadi_ci_id                   pa_budget_versions.ci_id%TYPE;

      l_period_start_date    DATE;
      l_period_end_date      DATE;
      l_plan_start_date      pa_resource_assignments.planning_start_date%type;
      l_plan_end_date        pa_resource_assignments.planning_end_date%type;

      TYPE varchr_32_index_date_tbl_typ   IS TABLE OF DATE INDEX BY VARCHAR2(32);
      TYPE varchr_32_index_varchr_tbl_typ IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(32);

      l_plan_start_date_tbl                varchr_32_index_date_tbl_typ;
      l_plan_end_date_tbl                  varchr_32_index_date_tbl_typ;
      l_task_name_tbl                      varchr_32_index_varchr_tbl_typ;
      l_resource_alias_tbl                 varchr_32_index_varchr_tbl_typ;
      l_distinct_taskid_rlmid_index        VARCHAR2(32);  --Index to store task id and rlm id comnination.
      l_resource_alias                     pa_resource_list_members.alias%type;

      TYPE varchr_120_index_num_tbl_typ IS TABLE OF NUMBER(15) INDEX BY VARCHAR2(120);
      l_distinct_rlmid_idx        VARCHAR2(120);  --Index to store rlm id and resource alias
      l_rlm_id_tbl                         varchr_120_index_num_tbl_typ;

      TYPE varchr_30_index_num_tbl_typ IS TABLE OF NUMBER(15) INDEX BY VARCHAR2(30);
      l_distinct_tskid_idx        VARCHAR2(30);  --Index to store task id and task name
      l_tsk_id_tbl                varchr_30_index_num_tbl_typ;

      --Added thses date tables for bug#4488926.
      TYPE date_tbl_type IS TABLE OF DATE INDEX BY VARCHAR2(20);
      l_period_start_date_tbl         date_tbl_type;
      l_period_end_date_tbl           date_tbl_type;
      l_period_plan_start_date_tbl    date_tbl_type;
      l_period_plan_end_date_tbl      date_tbl_type;
      l_proj_fp_options_id             pa_proj_fp_options.proj_fp_options_id%TYPE;

     l_fixed_date_sp_id             number;
     l_resource_assignment_id       number;
     l_planning_start_date          date;
     l_planning_end_date            date;
     l_sp_fixed_date                date;
     l_invalid_plandates_flag       varchar2(1);
     l_invalid_resassgn_flag        varchar2(1);
     l_project_number               varchar2(25);
     l_raid_hash_table              res_assign_tbl_type1;



BEGIN
      x_msg_count :=0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'Validate_Budget_Lines: ' || g_module_name;

	  IF l_debug_mode = 'Y' THEN
	      pa_debug.set_curr_function( p_function   => 'Validate_Budget_Lines',
                                  p_debug_mode => l_debug_mode );

      --dbms_output.put_line('----- Entering into validate_budget_lines-------');
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

 /* Bug 3717093 This api is called both for new and old budgets model versions
      -- hari 11th may
      IF ( p_calling_context = 'BUDGET_LINE_LEVEL_VALIDATION' AND p_budget_type_code IS NULL )
      THEN
                  PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      Bug 3717093 */

      /*============================================================+
       | Bug 3717093 : Replaced the above check with the following. |
       +============================================================*/
      IF ( p_calling_context in('RES_ASSGNMT_LEVEL_VALIDATION','UPDATE_PLANNING_ELEMENT_ATTR') AND p_budget_type_code IS NOT NULL )
      THEN
                  PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF(p_fin_plan_type_id IS NULL) AND (p_budget_type_code IS NOT NULL) THEN

            IF(p_pa_project_id             IS NULL OR
               p_resource_list_id          IS NULL OR
               p_budget_entry_method_code  IS NULL OR
               p_entry_level_code          IS NULL ) THEN

                  IF l_debug_mode = 'Y' THEN

                        pa_debug.g_err_stage:= 'p_pa_project_id is ' || p_pa_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_budget_type_code is ' || p_budget_type_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_resource_list_id is ' || p_resource_list_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_budget_entry_method_code is ' ||
                                                                              p_budget_entry_method_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_entry_level_code is ' || p_entry_level_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  END IF;

                  PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
      END IF;

      --<Patchset M: B and F impact changes : AMG:> -- Bug # 3507156
      --Added a check to error out budget lines with time phased code as 'R'(Date Range) and p_entry_level_code as 'M'
      -- as it is not supported in FP M model.

      IF(p_fin_plan_type_id IS NOT NULL) AND (p_budget_type_code IS NULL) THEN

            IF(p_pa_project_id             IS NULL OR
               p_version_type              IS NULL OR
               p_resource_list_id          IS NULL OR
               p_time_phased_code          IS NULL OR
               p_entry_level_code          IS NULL OR
               p_multi_currency_flag       IS NULL OR
               p_time_phased_code          = 'R'   OR
               p_entry_level_code          = 'M')THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_pa_project_id is ' || p_pa_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_fin_plan_type_id is ' || p_fin_plan_type_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_version_type is ' || p_version_type;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_resource_list_id is ' || p_resource_list_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_time_phased_code is ' || p_time_phased_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_entry_level_code is ' || p_entry_level_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                        pa_debug.g_err_stage:= 'p_multi_currency_flag is ' || p_multi_currency_flag;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  END IF;
                  PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
      END IF;

      -- Bug 3986129: FP.M Web ADI Dev changes:
      IF p_calling_context = 'WEBADI' THEN
             IF p_version_info_rec.x_plan_in_multi_curr_flag IS NULL THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'For Web ADI context the version info rec is null';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                  PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                       p_token1         => 'PROCEDURENAME',
                       p_value1         => l_module_name);
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
             IF px_budget_lines_in.COUNT <> p_raw_cost_rate_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_burd_cost_rate_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_bill_rate_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_uom_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_planning_start_date_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_planning_end_date_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_delete_flag_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_mfc_cost_type_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_spread_curve_name_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_sp_fixed_date_tbl.COUNT OR
                px_budget_lines_in.COUNT <> p_etc_method_name_tbl.COUNT THEN
                     IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'For Web ADI context the input tables are not equal';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;
                     PA_UTILS.ADD_MESSAGE
                         (p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                          p_token1         => 'PROCEDURENAME',
                          p_value1         => l_module_name);
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

             -- initializing the out table type parameters
             x_mfc_cost_type_id_tbl := SYSTEM.pa_num_tbl_type();
             x_etc_method_code_tbl  := SYSTEM.pa_varchar2_30_tbl_type();
             x_spread_curve_id_tbl  := SYSTEM.pa_num_tbl_type();

             -- initializing the web adi error code lookup table:
             -- this is required to get the validation failure context, so that appropriate lookup code
             -- for web adi context can be used to stamp the interface table corresponding the error
             -- code returned from the currency conversion validating api.
             l_wa_error_code_lookup ('PA_FP_INVALID_RATE_TYPE')      := 'PA_FP_WA_INV_RATE_TYPE';
             l_wa_error_code_lookup ('PA_FP_INVALID_RATE_DATE_TYPE') := 'PA_FP_WA_INV_RATE_DATE_TYPE';
             l_wa_error_code_lookup ('PA_FP_INVALID_RATE_DATE')      := 'PA_FP_WA_INV_RATE_DATE';
             l_wa_error_code_lookup ('PA_FP_USER_EXCH_RATE_REQ')     := 'PA_FP_WA_USER_EXCH_RATE_REQ';
             l_wa_error_code_lookup ('PA_FP_RATE_TYPE_REQ')          := 'PA_FP_WA_INV_RATE_TYPE';

      END IF;


       IF p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' THEN
               IF px_budget_lines_in.COUNT <> p_uom_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_planning_start_date_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_planning_end_date_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_mfc_cost_type_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_spread_curve_name_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_sp_fixed_date_tbl.COUNT OR
                       px_budget_lines_in.COUNT <> p_etc_method_name_tbl.COUNT THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'For UPDATE_PLANNING_ELEMENT_ATTR context the input tables are not equal';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;
                            PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                 p_token1         => 'PROCEDURENAME',
                                 p_value1         => l_module_name);
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

            -- initializing the out table type parameters
            x_mfc_cost_type_id_tbl := SYSTEM.pa_num_tbl_type();
            x_etc_method_code_tbl  := SYSTEM.pa_varchar2_30_tbl_type();
            x_spread_curve_id_tbl  := SYSTEM.pa_num_tbl_type();

            Select spread_curve_id
            into l_fixed_date_sp_id
            from pa_spread_curves_b
            where spread_curve_code = 'FIXED_DATE';

            select segment1
            into l_project_number
            from pa_projects_all
            where project_id=p_pa_project_id;

       END IF;  -- Bug 5509192

      --Set API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Get segment1 for AMG messages
      OPEN  l_amg_project_csr( p_pa_project_id );
      FETCH l_amg_project_csr INTO l_amg_project_rec;
      CLOSE l_amg_project_csr;

      --AMG UT2. Moved this piece of code from if plan_type_id <> null to here.
      --Get the uncategorized resource list info.If the resource is uncategorized
      --resource list member id should be set to uncategorized resource list member id
      pa_get_resource.Get_Uncateg_Resource_Info
            (p_resource_list_id         => l_uncategorized_res_list_id,
            p_resource_list_member_id   => l_uncategorized_rlmid,
            p_resource_id               => l_uncategorized_resid,
            p_track_as_labor_flag       => l_track_as_labor_flag,
            p_err_code                  => l_err_code,
            p_err_stage                 => l_err_stage,
            p_err_stack                 => l_err_stack );

      IF l_err_code <> 0 THEN
            IF NOT pa_project_pvt.check_valid_message(l_err_stage) THEN
                  pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_NO_UNCATEGORIZED_LIST'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'BUDG'
                  ,p_attribute1       => l_amg_project_rec.segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => p_budget_type_code
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
            ELSE
                  pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => l_err_stage
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'BUDG'
                  ,p_attribute1       => l_amg_project_rec.segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => p_budget_type_code
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
            END IF;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Could not obtain uncategorized resource list info';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;   --AMG UT2
      END IF; -- IF l_err_code <> 0 THEN


      -- Get the budget amount code so that it can be used later
      IF (p_budget_type_code IS NOT  NULL) THEN

            /*Get the budget amount code. Check whether the project type allows the
              creation of plan versions with obtained budget amounT code.
            */
            OPEN  l_budget_amount_code_csr( p_budget_type_code );
            FETCH l_budget_amount_code_csr
            INTO  l_budget_amount_code;       --will be used later on during validation of Budget lines.
            CLOSE l_budget_amount_code_csr;
      END IF;


      --Get the approved revenue plan type flag and txn currencies for the plan type so that the
      --txn currencies for the plan version can be validated later.
      IF(p_fin_plan_type_id IS NOT NULL) THEN
            OPEN l_approved_revenue_flag_csr( p_fin_plan_type_id
                                             ,p_pa_project_id);
            FETCH l_approved_revenue_flag_csr INTO l_app_rev_plan_type_flag , l_proj_fp_options_id; --for bug 4886319
            CLOSE l_approved_revenue_flag_csr;

           --Bug 4290310. Changed the if condition to read the txn currency for budget version level when the
           --budget version id is passed.
            IF (p_calling_context = 'WEBADI' OR p_version_info_rec.x_budget_version_id is not null) THEN
                OPEN   l_plan_ver_txn_curr_csr( p_fin_plan_type_id
                                               ,p_pa_project_id
                                               ,p_version_info_rec.x_budget_version_id);
                FETCH l_plan_ver_txn_curr_csr BULK COLLECT
                INTO  l_valid_txn_currencies_tbl;

                CLOSE l_plan_ver_txn_curr_csr;
            ELSE
                OPEN   l_plan_type_txn_curr_csr( l_proj_fp_options_id
                                                 ,p_pa_project_id);
                FETCH l_plan_type_txn_curr_csr BULK COLLECT
                INTO  l_valid_txn_currencies_tbl;

                CLOSE l_plan_type_txn_curr_csr;
            END IF;

            --Get the project and project functional currencies so that they can be used later
            pa_fin_plan_utils.Get_Project_Curr_Attributes
            (  p_project_id                    => p_pa_project_id
              ,x_multi_currency_billing_flag   => l_multi_currency_billing_flag
              ,x_project_currency_code         => l_project_currency_code
              ,x_projfunc_currency_code        => l_projfunc_currency_code
              ,x_project_cost_rate_type        => l_project_cost_rate_type
              ,x_projfunc_cost_rate_type       => l_projfunc_cost_rate_type
              ,x_project_bil_rate_type         => l_project_bil_rate_type
              ,x_projfunc_bil_rate_type        => l_projfunc_bil_rate_type
              ,x_return_status                 => x_return_status
              ,x_msg_count                     => x_msg_count
              ,x_msg_data                      => x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'pa_fin_plan_utils.Get_Project_Curr_Attributes errored out for project' ||p_pa_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            -- Get the plan type name
           SELECT name
            INTO   l_fin_plan_type_name
            FROM   pa_fin_plan_types_vl
            WHERE  fin_plan_type_id =  p_fin_plan_type_id;


      -- bug 4462614: added the following check for CI version for webadi context
      IF (p_calling_context = 'WEBADI' AND
         Nvl(l_app_rev_plan_type_flag, 'N') = 'Y') THEN
             -- open the cursor to get the ci_id and agr_curr_code
             OPEN check_and_return_ci_version(p_version_info_rec.x_budget_version_id);
             FETCH check_and_return_ci_version
             INTO  l_webadi_ci_id,
                   l_webadi_agr_curr_code;
             CLOSE check_and_return_ci_version;
      END IF;

      END IF;  --IF(p_fin_plan_type_id IS NOT NULL) THEN

     --Bug 4488926.Deriving the l_period_time_phased_code only once  for passed budget version id.
     l_period_time_phased_code := p_time_phased_code; --Use the i/p parameter to get this value.
    --if p_time_phased_code was passed as null we try to derive the time phase code.
     IF(l_period_time_phased_code is null)
     THEN
        l_period_time_phased_code :=  PA_FIN_PLAN_UTILS.Get_Time_Phased_code(p_version_info_rec.x_budget_version_id);
     END IF;


      IF px_budget_lines_in.exists(px_budget_lines_in.first) THEN
            --Loop thru the pl/sql table and validate each budget line
            FOR i IN px_budget_lines_in.first..px_budget_lines_in.last LOOP
                  /* Bug 3133930 */
                  x_budget_lines_out(i).return_status     := FND_API.G_RET_STS_SUCCESS;
                  --Initialise all the global variables to null
                  pa_budget_pvt.g_Task_number    := NULL;
                  pa_budget_pvt.g_start_date     := NULL;
                  pa_budget_pvt.g_resource_alias := NULL;


                  /* Bug 3218822 - PM_PRODUCT_CODE could be Null. We need valid it if it is NOT NULL */

                  IF px_budget_lines_in(i).pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                     OR px_budget_lines_in(i).pm_product_code IS NOT NULL
                  THEN

                        /* Validating as done in bug# 2413400 */
                        OPEN p_product_code_csr (px_budget_lines_in(i).pm_product_code);
                        FETCH p_product_code_csr INTO l_pm_product_code;
                        CLOSE p_product_code_csr;
                        IF l_pm_product_code <> 'X'
                        THEN
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                              THEN
                                  pa_interface_utils_pub.map_new_amg_msg
                                  ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
                                   ,p_msg_attribute    => 'CHANGE'
                                   ,p_resize_flag      => 'N'
                                   ,p_msg_context      => 'GENERAL'
                                   ,p_attribute1       => ''
                                   ,p_attribute2       => ''
                                   ,p_attribute3       => ''
                                   ,p_attribute4       => ''
                                   ,p_attribute5       => '');
                              END IF;
                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'PM Product code is invalid';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              x_return_status             := FND_API.G_RET_STS_ERROR;
                              x_budget_lines_out(i).return_status := FND_API.G_RET_STS_ERROR;
                              l_any_error_occurred_flag:='Y';
                        END IF;

                  END IF;

                  /* End of bug fix for Bug 3218822 */

                  -- checking if for project level planning, tasks ids are passed as 0 or not for web adi context
                  IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                        IF p_entry_level_code = 'P' THEN
                              IF px_budget_lines_in(i).pa_task_id <> 0 THEN
                                     l_webadi_err_code_tbl.extend(1);
                                     l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_TASK_IS_NOT_PROJECT';
                                     l_webadi_err_task_id_tbl.extend(1);
                                     l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                     l_webadi_err_rlm_id_tbl.extend(1);
                                     l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                     l_webadi_err_txn_curr_tbl.extend(1);
                                     l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                     l_webadi_err_amt_type_tbl.extend(1);
                                     l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                              END IF;
                        END IF;
                  END IF; -- p_context = WEBADI
                  -- convert pm_task_reference to pa_task_id
                  -- if both task id and reference are NULL or not passed, we will assume that budgetting is
                  -- done at the project level and that requires l_task_id to be '0'
                  -- if budgeting at the project level,then ignore all tasks
                  IF p_entry_level_code = 'P' THEN
                      px_budget_lines_in(i).pa_task_id := 0;

                  ELSIF p_entry_level_code in ('T','L','M') THEN
                        --Added a null check in the if below for the bug#4479835. The API pa_project_pvt.Convert_pm_taskref_to_id
                        --should be called to derive the pa_task_id if pa_task_id is null
                        IF (px_budget_lines_in(i).pa_task_id is null OR px_budget_lines_in(i).pa_task_id <> 0) THEN

                            --Selecting the index if it will be based on pa_task_id or pm_ask_reference. This index is decided on the
                            --basis of whther this (pa_project_pvt.Convert_pm_taskref_to_id ) API call would honour the
                            --pa_task_id or pm_task_reference. The rule is pa_task_id is honoured if both are passed to the API
                            --otherwise whichever value is passed that value is honoured by the API.
                            --Also note while preparing the index we are prepending 'TSKID' or 'TSKREF' before the actual values.
                            --The index would always be in this format.
                             IF(px_budget_lines_in(i).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                             px_budget_lines_in(i).pa_task_id is not null)
                             THEN
                             --Prepending the word 'TSKID' before the pa_task_id value while preparing the index.
                             l_distinct_tskid_idx := 'TSKID' || px_budget_lines_in(i).pa_task_id;
                             ELSIF( px_budget_lines_in(i).pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                             px_budget_lines_in(i).pm_task_reference is not null)
                             THEN
                             --Prepending the word 'TSKREF' before the pm_task_reference value while preparing the index.
                             l_distinct_tskid_idx := 'TSKREF' || px_budget_lines_in(i).pm_task_reference;
                             END IF;

                           --l_tsk_id_tbl table would be used to cache the pa_task_id for the pa_task_id/pm_task_reference passed.
                           -- This table would store the value for pa_task_id everytime a new task_id or pm_task_reference is passed.
                           --The table is indexed by index 'l_distinct_tskid_idx' which could be either pm_task_reference or
                           --pa_task_id.
                           --Check in the table if the value is already present for this index(which is one of
                           --pa_task_id/pm_task_reference). If present then read the task_id from the table for this index
                           --else call the api.
                            IF( NOT(l_tsk_id_tbl.exists(l_distinct_tskid_idx) ) )
                            THEN
                                        pa_project_pvt.Convert_pm_taskref_to_id
                                                      ( p_pa_project_id       => p_pa_project_id,
                                                        p_pa_task_id          => px_budget_lines_in(i).pa_task_id,
                                                        p_pm_task_reference   => px_budget_lines_in(i).pm_task_reference,
                                                        p_out_task_id         => px_budget_lines_in(i).pa_task_id,
                                                        p_return_status       => x_return_status );

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Converted Task Id is ' || px_budget_lines_in(i).pa_task_id;
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;

                                    IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                                          /*  Bug 3133930- set the return status to the new output variable */
                                          x_budget_lines_out(i).return_status := x_return_status;

                                          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                                    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                          -- exception is raised here because we cannot go ahead and do further validations
                                          -- as other validations depend upon task id to be correct.
                                          --RAISE  FND_API.G_EXC_ERROR; AMG UT2
                                          x_budget_lines_out(i).return_status := x_return_status;
                                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                    --Changed the elsif below for bug#4488926.
                                    ELSIF (px_budget_lines_in(i).pa_task_id IS NOT NULL) THEN /*if the API above executes successfully
                                                                                              then pa_task_id would never be null*/
                                          --If the API completes successfully then store the task_id in the l_tsk_id_tbl at the location
                                          --indexed by l_distinct_tskid_idx.
                                          l_tsk_id_tbl(l_distinct_tskid_idx) := px_budget_lines_in(i).pa_task_id;
                                          --Also if the index was based on task_reference then we derive task_id for this, but next time
                                          --possibly task_id could be passed which has been derived from this task_reference. So we
                                          --should store this derived task_id also in the table.
                                          --More importantly this task_id should be stored at the location indexed by
                                          --'TSKID' || px_budget_lines_in(i).pa_task_id. Here prepending the TSKID and the value
                                          --px_budget_lines_in(i).pa_task_id was derived in the above API call as o/p parameter.
                                          IF(l_distinct_tskid_idx = 'TSKREF' || px_budget_lines_in(i).pm_task_reference)
                                          THEN
                                              IF(l_tsk_id_tbl.exists('TSKID' || px_budget_lines_in(i).pa_task_id))
                                              THEN
                                                  --If the task_id derived from this task_reference is already present then dont store
                                                  --it again.
                                                   null;
                                               ELSE
                                                  --Derived task_id should be stored at the location indexed by
                                                  --'TSKID' || px_budget_lines_in(i).pa_task_id. Here prepending the TSKID and the value
                                                  --px_budget_lines_in(i).pa_task_id was derived in the above API call as o/p parameter.
                                                  --Storing this value would ensure that next time if this task_id is passed we dont
                                                  --call the API.
                                                   l_tsk_id_tbl('TSKID' || px_budget_lines_in(i).pa_task_id) :=
                                                                                                      px_budget_lines_in(i).pa_task_id;
                                               END IF;
                                          END IF;
                                    END IF;
                            ELSE --IF( NOT(l_tsk_id_tbl.exists(l_distinct_tskid_idx) ) )
                                 --If the value is already there in the table for this index(task_id/task_ref) then read it from table
                                 --for this index.
                                px_budget_lines_in(i).pa_task_id := l_tsk_id_tbl(l_distinct_tskid_idx) ;
                            END IF;--IF( NOT(l_tsk_id_tbl.exists(l_distinct_tskid_idx) ) )

                        END IF;
                  END IF;


                  -- get the task number. This task number is required as input to map_new_amg_msg API.

                  IF px_budget_lines_in(i).pa_task_id <> 0 THEN

                      l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
                                                                          ( p_task_number=> ''
                                                                           ,p_task_reference => px_budget_lines_in(i).pm_task_reference
                                                                           ,p_task_id => px_budget_lines_in(i).pa_task_id);
                      /* Bug 3124283: Added substr below */
                      pa_budget_pvt.g_task_number := substrb(l_amg_task_number,1,25);
                  ELSE
                      pa_budget_pvt.g_task_number := substrb(l_amg_project_rec.segment1,1,25); --Added for the bug 4421602.
                  END IF;

  -- <Patchset M:B and F impact changes : AMG:> -- Bug # 3507156
  -- Added a check for old model(p_budget_type_code) or new model(p_fin_plan_type_id) as the processing
  -- of the parameter p_entry_level_code is different for both.

  IF(p_budget_type_code IS NOT NULL) THEN  --Budget Model

                  IF p_entry_level_code = 'T' THEN -- then check whether it is top task
                             IF px_budget_lines_in(i).pa_task_id <> pa_task_utils.get_top_task_id( px_budget_lines_in(i).pa_task_id ) THEN
                                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                              pa_interface_utils_pub.map_new_amg_msg
                                                                    ( p_old_message_code => 'PA_TASK_IS_NOT_TOP'
                                                                     ,p_msg_attribute    => 'CHANGE'
                                                                     ,p_resize_flag      => 'N'
                                                                     ,p_msg_context      => 'TASK'
                                                                     ,p_attribute1       => l_amg_project_rec.segment1
                                                                     ,p_attribute2       => l_amg_task_number
                                                                     ,p_attribute3       => ''
                                                                     ,p_attribute4       => ''
                                                                     ,p_attribute5       => '');
                                        END IF;
                                   -- RAISE FND_API.G_EXC_ERROR;
                                   x_return_status :=  FND_API.G_RET_STS_ERROR;
                                   /*  Bug 3133930- set the return status to the new output variable */
                                   x_budget_lines_out(i).return_status := FND_API.G_RET_STS_ERROR;

                                   l_any_error_occurred_flag:='Y';
                             END IF;
                  ELSIF p_entry_level_code = 'L' -- then check whether it is lowest task
                  THEN
                        pa_tasks_pkg.verify_lowest_level_task( l_return_status_task,
                                                               px_budget_lines_in(i).pa_task_id);
                        IF l_return_status_task <> 0 THEN
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                              THEN
                                    pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_TASK_IS_NOT_LOWEST'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'N'
                                    ,p_msg_context      => 'TASK'
                                    ,p_attribute1       => l_amg_project_rec.segment1
                                    ,p_attribute2       => l_amg_task_number
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');
                              END IF;
                              --RAISE FND_API.G_EXC_ERROR;
                              x_return_status :=  FND_API.G_RET_STS_ERROR;
                              /*  Bug 3133930- set the return status to the new output variable */
                              x_budget_lines_out(i).return_status := x_return_status;

                              l_any_error_occurred_flag:='Y';
                        END IF;

                  ELSIF p_entry_level_code = 'M' -- then check whether it is a top or
                                                 -- lowest level tasks
                  THEN
                        --Added check to prevent the user from entering the amounts for both
                        --top task and one of its sub tasks.
                        l_top_task_id := pa_task_utils.get_top_task_id( px_budget_lines_in(i).pa_task_id );

                        l_top_task_planning_level := NULL;

                        IF px_budget_lines_in(i).pa_task_id =  nvl(l_top_task_id,-99) THEN

                              l_top_task_planning_level := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP;

                        ELSE
                              pa_tasks_pkg.verify_lowest_level_task( l_return_status_task
                                                                   , px_budget_lines_in(i).pa_task_id);
                                   IF l_return_status_task <> 0 THEN
                                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                              THEN
                                                    pa_interface_utils_pub.map_new_amg_msg
                                                    ( p_old_message_code => 'PA_TASK_IS_NOT_TOP_OR_LOWEST'
                                                    ,p_msg_attribute    => 'CHANGE'
                                                    ,p_resize_flag      => 'Y'
                                                    ,p_msg_context      => 'TASK'
                                                    ,p_attribute1       => l_amg_project_rec.segment1
                                                    ,p_attribute2       => l_amg_task_number
                                                    ,p_attribute3       => ''
                                                    ,p_attribute4       => ''
                                                    ,p_attribute5       => '');
                                              END IF;
                                         --RAISE FND_API.G_EXC_ERROR;
                                         x_return_status :=  FND_API.G_RET_STS_ERROR;
                                         /*  Bug 3133930- set the return status to the new output variable */
                                         x_budget_lines_out(i).return_status := x_return_status;

                                         l_any_error_occurred_flag:='Y';
                                   ELSE--The task passed is a lowest task
                                         l_top_task_planning_level := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST;
                                   END IF;


                        END IF;--iF px_budget_lines_in(i).pa_task_id =  nvl(l_top_task_id,-99) THEN

                  -- Check the planning level only if the task entered is valid.
                        IF l_top_task_planning_level IS NOT NULL THEN

                              --See whether the planning level is already cached in l_top_tasks_tbl. If it is
                              --cached then that can be used. For bug 3678314
                              l_temp:=NULL;
                              FOR kk IN 1..l_top_tasks_tbl.COUNT LOOP

                                  IF l_top_tasks_tbl(kk).key=l_top_task_id THEN
                                      l_temp:=kk;
                                      EXIT;
                                  END IF;

                              END LOOP;

                              IF (l_temp IS NOT NULL) THEN
                                    IF l_top_task_planning_level <> l_top_tasks_tbl(l_temp).value THEN

                                          l_amg_top_task_number := pa_interface_utils_pub.get_task_number_amg
                                                                      ( p_task_number=> ''
                                                                       ,p_task_reference => NULL
                                                                       ,p_task_id => l_top_task_id);


                                          PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_FP_AMTS_FOR_BOTH_TOP_LOWEST',
                                              p_token1         => 'PROJECT',
                                              p_value1         =>  l_amg_project_rec.segment1,
                                              p_token2         => 'TASK',
                                              p_value2         =>  l_amg_top_task_number);


                                          x_return_status := FND_API.G_RET_STS_ERROR;
                                          /*  Bug 3133930- set the return status to the new output variable */
                                          x_budget_lines_out(i).return_status := x_return_status;

                                          l_any_error_occurred_flag := 'Y';
                                    END IF;
                              ELSE
                                    --Cache the values derived so that they can be used again. Bug 3678314
                                    l_temp := l_top_tasks_tbl.COUNT + 1;
                                    l_top_tasks_tbl(l_temp).key := l_top_task_id;
                                    l_top_tasks_tbl(l_temp).value := l_top_task_planning_level;

                              END IF;
                        END IF;

                  END IF;     -- IF p_entry_level_code = T THEN

 ELSIF (p_fin_plan_type_id IS NOT NULL) THEN  --FinPlan Model
 -- <Patchset M:B and F impact changes : AMG:> -- Bug # 3507156
 -- If Planning level is Top, then only top task or project level planning is allowed.

               IF p_entry_level_code = 'T' THEN -- then check whether it is a task at top level or project level
                          IF  (px_budget_lines_in(i).pa_task_id <> 0)
                          AND (px_budget_lines_in(i).pa_task_id <> pa_task_utils.get_top_task_id( px_budget_lines_in(i).pa_task_id )) THEN
                                    IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                                          l_webadi_err_code_tbl.extend(1);
                                          l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_TASK_IS_NOT_TOP';
                                          l_webadi_err_task_id_tbl.extend(1);
                                          l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                          l_webadi_err_rlm_id_tbl.extend(1);
                                          l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                          l_webadi_err_txn_curr_tbl.extend(1);
                                          l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                          l_webadi_err_amt_type_tbl.extend(1);
                                          l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                    ELSE
                                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                          pa_interface_utils_pub.map_new_amg_msg
                                                      ( p_old_message_code => 'PA_TASK_IS_NOT_TOP'
                                                       ,p_msg_attribute    => 'CHANGE'
                                                       ,p_resize_flag      => 'N'
                                                       ,p_msg_context      => 'TASK'
                                                       ,p_attribute1       => l_amg_project_rec.segment1
                                                       ,p_attribute2       => l_amg_task_number
                                                       ,p_attribute3       => ''
                                                       ,p_attribute4       => ''
                                                       ,p_attribute5       => '');
                                       END IF;
                                         -- RAISE FND_API.G_EXC_ERROR;
                                         x_return_status :=  FND_API.G_RET_STS_ERROR;
                                         /*  Bug 3133930- set the return status to the new output variable */
                                         x_budget_lines_out(i).return_status := FND_API.G_RET_STS_ERROR;
                                    END IF;
                                   l_any_error_occurred_flag:='Y';
                          END IF;

 -- <Patchset M:B and F impact changes : AMG:> --Bug # 3507156
 --If Planning level is lowest, then no validations - any task can be planned
 --As there is already a check for p_entry_level_code = 'M' we do not need to check it again.

               END IF; -- if p_entry_level_code = 'T'

 END IF ; -- If fin_plan_type_id is NOT NULL


                  -- check the validity of the period_name,budget_start_date and
                  -- budget_end_date for budget lines and return values of budget_start_date
                  -- and budget_end_date for given period_name
           -- hari 11th may
              IF ( p_calling_context  not in ('RES_ASSGNMT_LEVEL_VALIDATION','UPDATE_PLANNING_ELEMENT_ATTR') )
              THEN
                      IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                          -- checking if the planning start date/end date has been explcitely nulled ou
                          IF p_planning_start_date_tbl(i) = FND_API.G_MISS_DATE OR
                             p_planning_end_date_tbl(i) = FND_API.G_MISS_DATE THEN
                                  l_webadi_err_code_tbl.extend(1);
                                  l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_PLAN_DATES_NULLED_OUT';
                                  l_webadi_err_task_id_tbl.extend(1);
                                  l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                  l_webadi_err_rlm_id_tbl.extend(1);
                                  l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                  l_webadi_err_txn_curr_tbl.extend(1);
                                  l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                  l_webadi_err_amt_type_tbl.extend(1);
                                  l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                  l_any_error_occurred_flag:='Y';
                          END IF;

                          -- before calling get_valid_periods_dates validating the followings
                          IF (px_budget_lines_in(i).budget_start_date IS NOT NULL OR
                              px_budget_lines_in(i).budget_start_date <> FND_API.G_MISS_DATE) AND
                             (px_budget_lines_in(i).budget_end_date IS NOT NULL OR
                              px_budget_lines_in(i).budget_end_date <> FND_API.G_MISS_DATE) THEN

                                  -- checking if the budget line start date/ end date falls between
                                  -- the planning start date/ end date
                                  -- Added for the bug 4414062

                                  --After the  derivation of l_period_time_phased_code, if l_period_time_phased_code = N
                                  --then it means its a non periodic finplan case
                                  IF ( l_period_time_phased_code <> 'N')
                                  THEN
                                        ---Added this code for bug#4488926. Caching the values of l_period_plan_start_date and
                                        --l_period_plan_end_date
                                        IF ( NOT(l_period_plan_start_date_tbl.exists(to_char(p_planning_start_date_tbl(i)))
                                             AND l_period_plan_end_date_tbl.exists(to_char(p_planning_end_date_tbl(i)))))
                                        THEN
                                        --For periodic case get the start and end dates.
                                            l_period_plan_start_date := PA_FIN_PLAN_UTILS.get_period_start_date(p_planning_start_date_tbl(i),l_period_time_phased_code);
                                            l_period_plan_end_date :=  PA_FIN_PLAN_UTILS.get_period_end_date (p_planning_end_date_tbl(i) , l_period_time_phased_code);
                                            l_period_plan_start_date_tbl(to_char(p_planning_start_date_tbl(i))) := l_period_plan_start_date;
                                            l_period_plan_end_date_tbl(to_char(p_planning_end_date_tbl(i))) := l_period_plan_end_date;
                                        ELSE
                                            l_period_plan_start_date := l_period_plan_start_date_tbl(to_char(p_planning_start_date_tbl(i)));
                                            l_period_plan_end_date := l_period_plan_end_date_tbl(to_char(p_planning_end_date_tbl(i)));
                                        END IF;
                                  ELSE
                                  --Its a non periodic case.
                                     l_period_plan_start_date := p_planning_start_date_tbl(i);
                                     l_period_plan_end_date   := p_planning_end_date_tbl(i);
                                  END IF;




                                  IF px_budget_lines_in(i).budget_start_date < l_period_plan_start_date OR
                                     px_budget_lines_in(i).budget_end_date > l_period_plan_end_date THEN
                                          -- throwing error
                                          l_webadi_err_code_tbl.extend(1);
                                          l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_BL_OUT_OF_PLAN_RANGE';
                                          l_webadi_err_task_id_tbl.extend(1);
                                          l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                          l_webadi_err_rlm_id_tbl.extend(1);
                                          l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                          l_webadi_err_txn_curr_tbl.extend(1);
                                          l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                          l_webadi_err_amt_type_tbl.extend(1);
                                          l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                          l_any_error_occurred_flag:='Y';
                                  END IF;
                          END IF;

                                IF p_budget_type_code IS NOT NULL THEN
                                       l_calling_model_context := 'BUDGETSMODEL';
                                 ELSIF p_fin_plan_type_id IS NOT NULL THEN
                                       l_calling_model_context := 'FINPLANMODEL';
                                END IF;

                               get_valid_period_dates
                                             ( p_project_id              => p_pa_project_id
                                              ,p_task_id                 => px_budget_lines_in(i).pa_task_id
                                              ,p_time_phased_type_code   => p_time_phased_code
                                              ,p_entry_level_code        => p_entry_level_code
                                              ,p_period_name_in          => px_budget_lines_in(i).period_name
                                              ,p_budget_start_date_in    => px_budget_lines_in(i).budget_start_date
                                              ,p_budget_end_date_in      => px_budget_lines_in(i).budget_end_date
                                              ,p_period_name_out         => px_budget_lines_in(i).period_name
                                              ,p_budget_start_date_out   => px_budget_lines_in(i).budget_start_date
                                              ,p_budget_end_date_out     => px_budget_lines_in(i).budget_end_date
                                              ,p_calling_model_context   => l_calling_model_context
                                              ,p_context                 => 'WEBADI'
                                              ,p_return_status           => x_return_status
                                              ,x_error_code              => l_new_error_code);

                                              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                                   -- populationg the error tbl variables to call process_errors at the end
                                                   l_webadi_err_code_tbl.extend(1);
                                                   l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) :=    l_new_error_code;
                                                   l_webadi_err_task_id_tbl.extend(1);
                                                   l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                                   l_webadi_err_rlm_id_tbl.extend(1);
                                                   l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                                   l_webadi_err_txn_curr_tbl.extend(1);
                                                   l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                                   l_webadi_err_amt_type_tbl.extend(1);
                                                   l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                              END IF;
                      ELSE -- p_context <> 'WEBADI'

                                IF p_budget_type_code IS NOT NULL THEN
                                       l_calling_model_context := 'BUDGETSMODEL';
                                 ELSIF p_fin_plan_type_id IS NOT NULL THEN
                                       l_calling_model_context := 'FINPLANMODEL';
                                END IF;

                                  IF (l_calling_model_context = 'BUDGETSMODEL') or (NOT(p_time_phased_code = 'N' AND  -- Bug no 5846942
                                   (px_budget_lines_in(i).budget_start_date IS NULL
                                    OR px_budget_lines_in(i).budget_start_date  = FND_API.G_MISS_DATE )
                                   AND (px_budget_lines_in(i).budget_end_date IS NULL
                                    OR px_budget_lines_in(i).budget_end_date  = FND_API.G_MISS_DATE )) )THEN


                               get_valid_period_dates
                                             ( p_project_id              => p_pa_project_id
                                              ,p_task_id                 => px_budget_lines_in(i).pa_task_id
                                              ,p_time_phased_type_code   => p_time_phased_code
                                              ,p_entry_level_code        => p_entry_level_code
                                              ,p_period_name_in          => px_budget_lines_in(i).period_name
                                              ,p_budget_start_date_in    => px_budget_lines_in(i).budget_start_date
                                              ,p_budget_end_date_in      => px_budget_lines_in(i).budget_end_date
                                              ,p_period_name_out         => px_budget_lines_in(i).period_name
                                              ,p_budget_start_date_out   => px_budget_lines_in(i).budget_start_date
                                              ,p_budget_end_date_out     => px_budget_lines_in(i).budget_end_date
                                              ,p_return_status           => x_return_status
                                              ,p_calling_model_context   => l_calling_model_context
                                              ,x_error_code              => l_new_error_code);
                                  END IF;
                      END IF;  -- Bug 3986129

                  pa_budget_pvt.g_start_date := px_budget_lines_in(i).budget_start_date;
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       -- RAISE  FND_API.G_EXC_ERROR;
                       -- as the API get_valid_period_dates adds the error msg to the stack hence we
                       -- do not need to add the error msg in this API.
                        /*  Bug 3133930- set the return status to the new output variable */
                        x_budget_lines_out(i).return_status := x_return_status;
                       l_any_error_occurred_flag:='Y';
                  END IF;
              END IF; --p_calling_context <> 'RES_ASSGNMT_LEVEL_VALIDATION','UPDATE_PLANNING_ELEMENT_ATTR'

              IF p_calling_context <> 'UPDATE_PLANNING_ELEMENT_ATTR' then -- Bug 5509192
                  --every budget line need to be checked for it's amount values.
                  IF p_fin_plan_type_id IS NULL THEN
                  --Budget Model.Do not pass version type and amount flags

                        pa_budget_pvt.check_entry_method_flags
                                   ( p_budget_amount_code        => l_budget_amount_code
                                    ,p_budget_entry_method_code  => p_budget_entry_method_code
                                    ,p_quantity                  => px_budget_lines_in(i).quantity
                                    ,p_raw_cost                  => px_budget_lines_in(i).raw_cost
                                    ,p_burdened_cost             => px_budget_lines_in(i).burdened_cost
                                    ,p_revenue                   => px_budget_lines_in(i).revenue
                                    ,p_return_status             => x_return_status

                                    -- Bug 3986129: FP.M Web ADI Dev changes
                                    ,x_webadi_error_code         => l_new_error_code);

                  ELSE
                  --Finplan model.Pass version type and other amount flags
                        IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                               pa_budget_pvt.check_entry_method_flags
                                   ( p_budget_amount_code        => NULL
                                    ,p_budget_entry_method_code  => p_budget_entry_method_code
                                    ,p_quantity                  => px_budget_lines_in(i).quantity
                                    ,p_raw_cost                  => px_budget_lines_in(i).raw_cost
                                    ,p_burdened_cost             => px_budget_lines_in(i).burdened_cost
                                    ,p_revenue                   => px_budget_lines_in(i).revenue
                                    ,p_return_status             => x_return_status
                                    ,p_version_type              => p_version_type
                                    ,p_allow_qty_flag            => p_allow_qty_flag
                                    ,p_allow_raw_cost_flag       => p_allow_raw_cost_flag
                                    ,p_allow_burdened_cost_flag  => p_allow_burdened_cost_flag
                                    ,p_allow_revenue_flag        => p_allow_revenue_flag
                                    ,p_context                   => 'WEBADI'
                                    ,p_raw_cost_rate             => p_raw_cost_rate_tbl(i)
                                    ,p_burdened_cost_rate        => p_burd_cost_rate_tbl(i)
                                    ,p_bill_rate                 => p_bill_rate_tbl(i)
                                    ,p_allow_raw_cost_rate_flag  => p_allow_raw_cost_rate_flag
                                    ,p_allow_burd_cost_rate_flag => p_allow_burd_cost_rate_flag
                                    ,p_allow_bill_rate_flag      => p_allow_bill_rate_flag
                                    ,x_webadi_error_code         => l_new_error_code);

                                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                        l_webadi_err_code_tbl.extend(1);
                                        l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := l_new_error_code;
                                        l_webadi_err_task_id_tbl.extend(1);
                                        l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                        l_webadi_err_rlm_id_tbl.extend(1);
                                        l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                        l_webadi_err_txn_curr_tbl.extend(1);
                                        l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                        l_webadi_err_amt_type_tbl.extend(1);
                                        l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                    END IF;
                        ELSE  -- p_calling_context <> 'WEBADI'
                                    pa_budget_pvt.check_entry_method_flags
                                   ( p_budget_amount_code        => NULL
                                    ,p_budget_entry_method_code  => p_budget_entry_method_code
                                    ,p_quantity                  => px_budget_lines_in(i).quantity
                                    ,p_raw_cost                  => px_budget_lines_in(i).raw_cost
                                    ,p_burdened_cost             => px_budget_lines_in(i).burdened_cost
                                    ,p_revenue                   => px_budget_lines_in(i).revenue
                                    ,p_return_status             => x_return_status
                                    ,p_version_type              => p_version_type
                                    ,p_allow_qty_flag            => p_allow_qty_flag
                                    ,p_allow_raw_cost_flag       => p_allow_raw_cost_flag
                                    ,p_allow_burdened_cost_flag  => p_allow_burdened_cost_flag
                                    ,p_allow_revenue_flag        => p_allow_revenue_flag
                                    ,x_webadi_error_code         => l_new_error_code);
                        END IF;  -- Bug 3986129
                  END IF;
                       IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
                       THEN
                             /*  Bug 3133930- set the return status to the new output variable */
                             x_budget_lines_out(i).return_status := x_return_status;

                             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSIF x_return_status = FND_API.G_RET_STS_ERROR
                       THEN
                             --RAISE  FND_API.G_EXC_ERROR;
                             -- as the called api adds msg to stack hence no need to add err msg here.

                             /*  Bug 3133930- set the return status to the new output variable */
                             x_budget_lines_out(i).return_status := x_return_status;

                             l_any_error_occurred_flag:='Y';
                       END IF;
              END IF; --p_clalling_context <> 'UPDATE_PLANNING_ELEMENT_ATTR' Bug 5509192

                  l_res_planning_level := NULL;

                  --Manipulation of resource alias should be done only when the resource list passed
                  --is not uncategorized
                  IF (nvl(l_uncategorized_res_list_id,-99) = p_resource_list_id) THEN

                        px_budget_lines_in(i).resource_list_member_id :=l_uncategorized_rlmid;
                        px_budget_lines_in(i).resource_alias := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

                        IF p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' then
                                   l_valid_rlmid := 'Y';
                        END IF ;


                  ELSE -- not uncategorized RL
                        -- convert resource alias to (resource) member id
                        -- if resource alias is (passed and not NULL)
                        -- and resource member is (passed and not NULL)
                        -- then we convert the alias to the id
                        -- else we default to the uncategorized resource member

                        IF (px_budget_lines_in(i).resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                           AND px_budget_lines_in(i).resource_alias IS NOT NULL)
                            OR (px_budget_lines_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                           AND px_budget_lines_in(i).resource_list_member_id IS NOT NULL)
                        THEN

                            --Selecting the index if it will be based on rlm_id or resource_alias. This index is decided on the
                            --basis of whther this (pa_resource_pub.Convert_alias_to_id ) API call would honour the
                            --rlm_id or resource_alias. The rule is rlm_id is honoured if both are passed to the API
                            --otherwise whichever value is passed that value is honoured by the API.
                            --Also note while preparing the index we are prepending 'RLMID' or 'RALIAS' before the actual values.
                            --The index would always be in this format.

                            --Also didnt included the null check in below if's to decide the index because it has already been
                            --taken care of in the last if before this. See above. We wont reach here if any one of rlm_id or
                            --resource_alias is null
                             IF(px_budget_lines_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
                             THEN
                             --Prepending the word 'RLMID' before the rlm_id value while preparing the index.
                             l_distinct_rlmid_idx := 'RLMID' || px_budget_lines_in(i).resource_list_member_id;
                             ELSIF( px_budget_lines_in(i).resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                             THEN
                             --Prepending the word 'RALIAS' before the reasource_alias value while preparing the index.
                             l_distinct_rlmid_idx := 'RALIAS' || px_budget_lines_in(i).resource_alias;
                             END IF;

                           --l_rlm_id_tbl table would be used to cache the rlm_id for the rlm_id/resource_alias passed.
                           -- This table would store the value for rlm_id everytime a new rlm_id or resource_alias is passed.
                           --The table is indexed by index 'l_distinct_rlmid_idx' which could be either resource_alias or
                           --rlm_id.
                           --Check in the table if the value is already present for this index(which is one of
                           --rlm_id/resource_alias). If present then read the rlm_id from the table for this index
                           --else call the api.
                             IF( NOT(l_rlm_id_tbl.exists(l_distinct_rlmid_idx) ) )
                             THEN
                                      pa_resource_pub.Convert_alias_to_id
                                                    ( p_project_id                  => p_pa_project_id
                                                     ,p_resource_list_id            => p_resource_list_id
                                                     ,p_alias                       => px_budget_lines_in(i).resource_alias
                                                     ,p_resource_list_member_id     => px_budget_lines_in(i).resource_list_member_id
                                                     ,p_out_resource_list_member_id => px_budget_lines_in(i).resource_list_member_id
                                                     ,p_return_status               => x_return_status   );

                                      --dbms_output.put_line('----- p_out_resource_list_member_id: -----' || p_out_resource_list_member_id);
                                      IF x_return_status = FND_API.G_RET_STS_SUCCESS
                                      THEN
                                          -- Initialise valid rlmid variable to Y
                                          l_valid_rlmid := 'Y';
                                          IF((p_budget_type_code IS NOT NULL) AND
                                             (p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN -- Old Bugdets Model -- Bug 3801891
                                            --get unit_of_measure and track_as_labor_flag associated to
                                            --the resource member and check whether this is a valid member for this list
                                            OPEN l_resource_csr( px_budget_lines_in(i).resource_list_member_id
                                                                ,p_resource_list_id     );
                                            FETCH l_resource_csr INTO l_unit_of_measure, l_track_as_labor_flag, l_rlm_migration_code;
                                            IF l_resource_csr%NOTFOUND THEN
                                                  l_context_info := p_budget_type_code;
                                                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                                  THEN
                                                      pa_interface_utils_pub.map_new_amg_msg
                                                      ( p_old_message_code => 'PA_LIST_MEMBER_INVALID'
                                                      ,p_msg_attribute    => 'CHANGE'
                                                      ,p_resize_flag      => 'N'
                                                      ,p_msg_context      => 'BUDG'
                                                      ,p_attribute1       => l_amg_project_rec.segment1
                                                      ,p_attribute2       => l_amg_task_number
                                                      ,p_attribute3       => l_context_info
                                                      ,p_attribute4       => ''
                                                      ,p_attribute5       => to_char(px_budget_lines_in(i).budget_start_date));
                                                  END IF;
                                                  x_return_status := FND_API.G_RET_STS_ERROR;
                                                  /*  Bug 3133930- set the return status to the new output variable */
                                                  x_budget_lines_out(i).return_status := x_return_status;
                                                  CLOSE l_resource_csr;

                                                  l_any_error_occurred_flag:='Y';
                                                  l_valid_rlmid := 'N';
                                                  --RAISE FND_API.G_EXC_ERROR;
                                            ELSE
                                                  CLOSE l_resource_csr;
                                            END IF;

                                            /* bug 3954329: included the following check */
                                            IF l_rlm_migration_code = 'N' THEN
                                                  l_any_error_occurred_flag:='Y';
                                                  l_valid_rlmid := 'N';
                                                  x_return_status := FND_API.G_RET_STS_ERROR;
                                                  x_budget_lines_out(i).return_status := x_return_status;
                                                  PA_UTILS.ADD_MESSAGE
                                                              ( p_app_short_name => 'PA',
                                                                p_msg_name       => 'PA_FP_OLD_MOD_NEW_RLM_PASSED');
                                            END IF;
                                            /* bug 3954329 end */

                                          ELSE -- New Bugdets Model -- Bug 3801891
                                            OPEN l_resource_csr_fp(px_budget_lines_in(i).resource_list_member_id);
                                            FETCH l_resource_csr_fp INTO l_unit_of_measure, l_rlm_migration_code;
                                            IF l_resource_csr_fp%NOTFOUND THEN
                                                  l_context_info := l_fin_plan_type_name;
                                                    IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                                                           l_webadi_err_code_tbl.extend(1);
                                                           l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_LIST_MEMBER_INVALID';
                                                           l_webadi_err_task_id_tbl.extend(1);
                                                           l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                                           l_webadi_err_rlm_id_tbl.extend(1);
                                                           l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                                           l_webadi_err_txn_curr_tbl.extend(1);
                                                           l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                                           l_webadi_err_amt_type_tbl.extend(1);
                                                           l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                                    ELSE
                                                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                                          pa_interface_utils_pub.map_new_amg_msg
                                                          ( p_old_message_code => 'PA_LIST_MEMBER_INVALID'
                                                           ,p_msg_attribute    => 'CHANGE'
                                                           ,p_resize_flag      => 'N'
                                                           ,p_msg_context      => 'BUDG'
                                                           ,p_attribute1       => l_amg_project_rec.segment1
                                                           ,p_attribute2       => l_amg_task_number
                                                           ,p_attribute3       => l_context_info
                                                           ,p_attribute4       => ''
                                                           ,p_attribute5       => to_char(px_budget_lines_in(i).budget_start_date));
                                                       END IF;
                                                          x_return_status := FND_API.G_RET_STS_ERROR;
                                                          x_budget_lines_out(i).return_status := x_return_status;
                                                    END IF;
                                                  CLOSE l_resource_csr_fp;

                                                  l_any_error_occurred_flag:='Y';
                                                  l_valid_rlmid := 'N';
                                            ELSE
                                                  CLOSE l_resource_csr_fp;
                                            END IF;
                                            /* bug 3954329: included the following check */
                                            IF l_rlm_migration_code IS NULL THEN
                                                  IF p_calling_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                                                         l_webadi_err_code_tbl.extend(1);
                                                         l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_OLD_RLM_PASSED';
                                                         l_webadi_err_task_id_tbl.extend(1);
                                                         l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                                         l_webadi_err_rlm_id_tbl.extend(1);
                                                         l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                                         l_webadi_err_txn_curr_tbl.extend(1);
                                                         l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                                         l_webadi_err_amt_type_tbl.extend(1);
                                                         l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                                  ELSE
                                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                                        x_budget_lines_out(i).return_status := x_return_status;
                                                        PA_UTILS.ADD_MESSAGE
                                                                    ( p_app_short_name => 'PA',
                                                                      p_msg_name       => 'PA_FP_NEW_MOD_OLD_RLM_PASSED');
                                                  END IF;

                                                  l_any_error_occurred_flag:='Y';
                                                  l_valid_rlmid := 'N';
                                            END IF;
                                            /* bug 3954329 end */

                                          END IF; -- Bug 3801891

                                          IF((p_budget_type_code IS NOT NULL) AND
                                             (p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN -- 4504585 For old budget model only

                                                IF l_valid_rlmid='Y' THEN

                                                      SELECT parent_member_id
                                                            ,resource_type_code
                                                            ,alias
                                                      INTO   l_parent_member_id
                                                            ,l_resource_type_code
                                                            ,pa_budget_pvt.g_resource_alias
                                                      FROM   pa_resource_list_members
                                                      WHERE  resource_list_member_id = px_budget_lines_in(i).resource_list_member_id;

                                                      IF l_resource_type_code = 'UNCLASSIFIED' THEN

                                                            l_any_error_occurred_flag:='Y';
                                                            l_valid_rlmid := 'N';
                                                            x_return_status := FND_API.G_RET_STS_ERROR;
                                                            /*  Bug 3133930- set the return status to the new output variable */
                                                            x_budget_lines_out(i).return_status := x_return_status;

                                                            PA_UTILS.ADD_MESSAGE
                                                                        ( p_app_short_name => 'PA',
                                                                          p_msg_name       => 'PA_FP_AMT_FOR_UNCLASSIFIED_RES',
                                                                          p_token1         => 'PROJECT',
                                                                          p_value1         =>  l_amg_project_rec.segment1,
                                                                          p_token2         => 'TASK',
                                                                          p_value2         => l_amg_task_number);
                                                            l_valid_rlmid:='N';

                                                      ELSE

                                                            IF l_parent_member_id IS NULL THEN
                                                                  l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_G;
                                                            ELSE
                                                                  l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;
                                                            END IF;

                                                      END IF;
                                                END IF;
                                          END IF;
                                            --Changed the if below for bug#4488926.
                                            IF (l_valid_rlmid = 'Y') THEN /*l_valid_rlmid equal to Y would ensure that no error
                                            occurred after  the API call pa_resource_pub.Convert_alias_to_id made above till this
                                            point in code*/
                                          --If the API completes and above validations completes successfully then store the rlm_id in the
                                          --l_rlm_id_tbl at the location indexed by l_distinct_rlmid_idx.
                                               l_rlm_id_tbl(l_distinct_rlmid_idx) := px_budget_lines_in(i).resource_list_member_id;
                                          --Also if the index was based on resource_alias then we derive rlm_id for this, but next time
                                          --possibly rlm_id could be passed which has been derived from this resource_alias. So we
                                          --should store this derived rlm_id also in the table.
                                          --More importantly this rlm_id should be stored at the location indexed by
                                          --'RLMID' || px_budget_lines_in(i).rlm_id. Here prepending the RLMID and the value
                                          --px_budget_lines_in(i).resource_list_member_id was derived in the above API call as o/p
                                          --parameter.
                                              IF(l_distinct_rlmid_idx = 'RALIAS' || px_budget_lines_in(i).resource_alias)
                                              THEN
                                                  IF(l_rlm_id_tbl.exists('RLMID' || px_budget_lines_in(i).resource_list_member_id))
                                                  THEN
                                                      --If the rlm_id derived from this resource_alias is already present then dont
                                                      --store it again.
                                                       null;
                                                  ELSE
                                                      --Derived rlm_id should be stored at the location indexed by
                                                      --'RLMID' || px_budget_lines_in(i).resource_list_member_id Here prepending the
                                                      --RLMID and the value px_budget_lines_in(i).resource_list_member_id was derived in
                                                      --the above API call as o/p parameter.
                                                      --Storing this value would ensure that next time if this rlm_id is passed we dont
                                                      --call the API.
                                                       l_rlm_id_tbl('RLMID' || px_budget_lines_in(i).resource_list_member_id) :=
                                                                                         px_budget_lines_in(i).resource_list_member_id;
                                                  END IF;
                                              END IF;
                                            END IF; --x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                                      ELSIF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
                                      THEN
                                            /*  Bug 3133930- set the return status to the new output variable */
                                            x_budget_lines_out(i).return_status := x_return_status;
                                            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

                                      ELSIF x_return_status = FND_API.G_RET_STS_ERROR
                                      THEN
                                            /*  Bug 3133930- set the return status to the new output variable */
                                            x_budget_lines_out(i).return_status := x_return_status;
                                            --RAISE  FND_API.G_EXC_ERROR;
                                            -- error message is added by the called API. Hence no error msg need to be added here.
                                            l_any_error_occurred_flag:='Y';
                                      END IF;
                              ELSE --IF( NOT(l_rlm_id_tbl.exists(l_distinct_rlmid_idx) ) )
                             --If the value is already there in the table for this index(task_id/task_ref) then read it from table
                                --for this index.
                                px_budget_lines_in(i).resource_list_member_id := l_rlm_id_tbl(l_distinct_rlmid_idx) ;
                              END IF; --IF( NOT(l_rlm_id_tbl.exists(l_distinct_rlmid_idx) ) )

                        ELSE
                              IF (p_budget_type_code IS NULL  OR
                                   p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
                                    l_context_info := l_fin_plan_type_name;
                              ELSE
                                    l_context_info := p_budget_type_code;
                              END IF;

                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    pa_interface_utils_pub.map_new_amg_msg
                                   ( p_old_message_code => 'PA_RESOURCE_IS_MISSING'
                                   ,p_msg_attribute    => 'CHANGE'
                                   ,p_resize_flag      => 'N'
                                   ,p_msg_context      => 'BUDG'
                                   ,p_attribute1       => l_amg_project_rec.segment1
                                   ,p_attribute2       => l_amg_task_number
                                   ,p_attribute3       => l_context_info
                                   ,p_attribute4       => ''
                                   ,p_attribute5       => to_char(px_budget_lines_in(i).budget_start_date));
                                   --RAISE FND_API.G_EXC_ERROR;
                               END IF;
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              /*  Bug 3133930- set the return status to the new output variable */
                              x_budget_lines_out(i).return_status := x_return_status;
                              l_any_error_occurred_flag:='Y';
                        END IF;

                  END IF;--IF (nvl(l_uncategorized_res_list_id,-99) = p_resource_list_id) THEN

                  IF p_calling_context= 'UPDATE_PLANNING_ELEMENT_ATTR' then
                         IF l_valid_rlmid ='Y' then
                                   SELECT  ALIAS
                                   INTO   px_budget_lines_in(i).resource_alias
                                   FROM   pa_resource_list_members
                                   WHERE  resource_list_member_id = px_budget_lines_in(i).resource_list_member_id;
                         END IF;
                          -- DBMS_OUTPUT.PUT_LINE('resource alias '||i||' '||px_budget_lines_in(i).resource_alias);
                  END IF;


                  -- Bug 3986129: FP.M Web ADI Dev changes
                   IF p_calling_context = 'WEBADI' or
                   (p_calling_context='UPDATE_PLANNING_ELEMENT_ATTR' and l_valid_rlmid ='Y') THEN --Bug 5509192

                       -- validating resource level attributes
                       IF p_uom_tbl(i) IS NOT NULL AND
                          p_uom_tbl(i) = FND_API.G_MISS_CHAR THEN
                              -- UOM has been nulled out
                              l_webadi_err_code_tbl.extend(1);
                              l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_UOM_NULLED_OUT';
                              l_webadi_err_task_id_tbl.extend(1);
                              l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                              l_webadi_err_rlm_id_tbl.extend(1);
                              l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                              l_webadi_err_txn_curr_tbl.extend(1);
                              l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                              l_webadi_err_amt_type_tbl.extend(1);
                              l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                              l_any_error_occurred_flag := 'Y';
                       ELSIF p_uom_tbl(i) IS NOT NULL AND
                             p_uom_tbl(i) <> FND_API.G_MISS_CHAR THEN
                             -- value for UOM has been passed
                             -- calling an api to validate the UOM passed
                             PA_BUDGET_CHECK_PVT.validate_uom_passed
                                 (p_res_list_mem_id  => px_budget_lines_in(i).resource_list_member_id,
                                  p_uom_passed       => p_uom_tbl(i),
                                  x_error_code       => l_new_error_code,
                                  x_return_status    => x_return_status,
                                  x_msg_data         => x_msg_data,
                                  x_msg_count        => x_msg_count);

                                  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                                      IF l_new_error_code IS NOT NULL THEN
                                            l_webadi_err_code_tbl.extend(1);
                                            l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := l_new_error_code;
                                            l_webadi_err_task_id_tbl.extend(1);
                                            l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                            l_webadi_err_rlm_id_tbl.extend(1);
                                            l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                            l_webadi_err_txn_curr_tbl.extend(1);
                                            l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                            l_webadi_err_amt_type_tbl.extend(1);
                                            l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                            l_any_error_occurred_flag := 'Y';
                                      END IF;
                                  ELSE
                                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                  END IF;
                       END IF; -- uom validation

                     --etc method validation starts
                      l_valid_etc_method:='Y';
                      l_etc_method_code :=null;

                       IF p_etc_method_name_tbl(i) IS NOT NULL AND
                         (p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' or
                          p_etc_method_name_tbl(i) <> FND_API.G_MISS_CHAR) THEN
                              BEGIN
                                    SELECT lookup_code
                                    INTO   l_etc_method_code
                                    FROM   pa_lookups
                                    WHERE  lookup_type = 'PA_FP_ETC_METHOD'
                                    AND    meaning = p_etc_method_name_tbl(i);
                              EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                           l_valid_etc_method := 'N';
                              END;

                              IF l_valid_etc_method = 'N' THEN
                              -- throwing error
                                 IF p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' then
                                       IF px_budget_lines_in(i).pa_task_id <> 0 then
                                               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                               p_msg_name       => 'INVALID_ETC_METHOD_AMG',
                                               p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                               p_value1         => l_amg_task_number,
                                               p_token2         => 'RESOURCE',
                                               p_value2         => px_budget_lines_in(i).resource_alias);
                                       ELSE
                                               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                               p_msg_name       => 'INVALID_ETC_METHOD_AMG',
                                               p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                               p_value1         => l_project_number,
                                               p_token2         => 'RESOURCE',
                                               p_value2         => px_budget_lines_in(i).resource_alias);
                                       END IF;
                                       l_any_error_occurred_flag := 'Y';
                                 ELSE
                                    l_webadi_err_code_tbl.extend(1);
                                    l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_INV_ETC_PASSED';
                                    l_webadi_err_task_id_tbl.extend(1);
                                    l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                    l_webadi_err_rlm_id_tbl.extend(1);
                                    l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                    l_webadi_err_txn_curr_tbl.extend(1);
                                    l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                    l_webadi_err_amt_type_tbl.extend(1);
                                    l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                    l_any_error_occurred_flag := 'Y';
                                 END IF;
                              ELSE
                                    x_etc_method_code_tbl.EXTEND(1);
                                    x_etc_method_code_tbl(x_etc_method_code_tbl.COUNT) := l_etc_method_code;
                              END IF;
                       ELSIF p_etc_method_name_tbl(i) IS NULL THEN
                              -- this need not be validated as the column is hidden
                              x_etc_method_code_tbl.EXTEND(1);
                              x_etc_method_code_tbl(x_etc_method_code_tbl.COUNT) := null;
                       END IF; -- etc validation



                       IF p_mfc_cost_type_tbl(i) IS NOT NULL AND
                          p_mfc_cost_type_tbl(i) <> FND_API.G_MISS_CHAR THEN
                              BEGIN
                                    SELECT cost_type_id
                                    INTO   l_mfc_cost_type_id
                                    FROM   CST_COST_TYPES_V
                                    WHERE  multi_org_flag = 1
                                    AND    cost_type = p_mfc_cost_type_tbl(i);
                              EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                           l_valid_mfc_cost_type := 'N';
                              END;

                              IF l_valid_mfc_cost_type = 'N' THEN
                              -- throwing error
                                    l_webadi_err_code_tbl.extend(1);
                                    l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_INV_MFC_PASSED';
                                    l_webadi_err_task_id_tbl.extend(1);
                                    l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                    l_webadi_err_rlm_id_tbl.extend(1);
                                    l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                    l_webadi_err_txn_curr_tbl.extend(1);
                                    l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                    l_webadi_err_amt_type_tbl.extend(1);
                                    l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                    l_any_error_occurred_flag := 'Y';
                              ELSE
                                    x_mfc_cost_type_id_tbl.EXTEND(1);
                                    x_mfc_cost_type_id_tbl(x_mfc_cost_type_id_tbl.COUNT) := l_mfc_cost_type_id;
                              END IF;
                       ELSIF p_mfc_cost_type_tbl(i) IS NULL THEN
                              -- this need not be validated as the column is hidden
                              x_mfc_cost_type_id_tbl.EXTEND(1);
                              x_mfc_cost_type_id_tbl(x_mfc_cost_type_id_tbl.COUNT) := null;
                       END IF; -- MFC validation\

                       l_valid_spread_curve := 'Y';
                       l_spread_curve_id    :=null;

                       -- validating spread curve
                       IF p_calling_context='WEBADI' and p_spread_curve_id_tbl.EXISTS(i) AND
                          (p_spread_curve_id_tbl(i) IS NULL  OR p_spread_curve_id_tbl(i) <> FND_API.G_MISS_NUM) THEN
                              x_spread_curve_id_tbl.EXTEND(1);
                              x_spread_curve_id_tbl(x_spread_curve_id_tbl.COUNT) := p_spread_curve_id_tbl(i);
                       ELSE
                              IF p_spread_curve_name_tbl(i) IS NOT NULL AND
                                 p_spread_curve_name_tbl(i) = FND_API.G_MISS_CHAR AND
                                 p_calling_context <> 'UPDATE_PLANNING_ELEMENT_ATTR' THEN

                                    l_webadi_err_code_tbl.extend(1);
                                    l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_SC_NULLED_OUT';
                                    l_webadi_err_task_id_tbl.extend(1);
                                    l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                    l_webadi_err_rlm_id_tbl.extend(1);
                                    l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                    l_webadi_err_txn_curr_tbl.extend(1);
                                    l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                    l_webadi_err_amt_type_tbl.extend(1);
                                    l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                    l_any_error_occurred_flag := 'Y';
                              ELSIF p_spread_curve_name_tbl(i) IS NOT NULL AND
                                    (p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' or
                                      p_spread_curve_name_tbl(i) <> FND_API.G_MISS_CHAR) THEN

                                    BEGIN
                                          SELECT spread_curve_id
                                          INTO   l_spread_curve_id
                                          FROM   pa_spread_curves_vl
                                          WHERE  name = p_spread_curve_name_tbl(i);
                                    EXCEPTION
                                          WHEN NO_DATA_FOUND THEN
                                                l_valid_spread_curve := 'N';
                                    END;
                                    IF l_valid_spread_curve = 'N' THEN
                                    -- throwing error
                                       IF p_calling_context = 'UPDATE_PLANNING_ELEMENT_ATTR' then
                                               IF px_budget_lines_in(i).pa_task_id <> 0 then
                                                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                       p_msg_name       => 'INVALID_SPREAD_CURVE_AMG',
                                                       p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                       p_value1         => l_amg_task_number,
                                                       p_token2         => 'RESOURCE',
                                                       p_value2         => px_budget_lines_in(i).resource_alias);
                                                ELSE
                                                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                       p_msg_name       => 'INVALID_SPREAD_CURVE_AMG',
                                                       p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                       p_value1         => l_project_number,
                                                       p_token2         => 'RESOURCE',
                                                       p_value2         => px_budget_lines_in(i).resource_alias);
                                               END IF;

                                               l_any_error_occurred_flag := 'Y';
                                       ELSE

                                          l_webadi_err_code_tbl.extend(1);
                                          l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_INV_SC_PASSED';
                                          l_webadi_err_task_id_tbl.extend(1);
                                          l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                          l_webadi_err_rlm_id_tbl.extend(1);
                                          l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                          l_webadi_err_txn_curr_tbl.extend(1);
                                          l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                          l_webadi_err_amt_type_tbl.extend(1);
                                          l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                          l_any_error_occurred_flag := 'Y';
                                       END IF;
                                    ELSE
                                          x_spread_curve_id_tbl.EXTEND(1);
                                          x_spread_curve_id_tbl(x_spread_curve_id_tbl.COUNT) := l_spread_curve_id;
                                    END IF;
                              ELSIF p_spread_curve_name_tbl(i) IS NULL then
                                          x_spread_curve_id_tbl.EXTEND(1);
                                          x_spread_curve_id_tbl(x_spread_curve_id_tbl.COUNT) := null;
                              END IF;
                       END IF; -- spread curve validation ends

                      if p_calling_context ='UPDATE_PLANNING_ELEMENT_ATTR' then
                                   l_invalid_resassgn_flag :='N';
                                   l_resource_assignment_id:=null;
                                   l_planning_start_date   :=null;
                                   l_planning_end_date     :=null;
                                   l_sp_fixed_date         :=null;
                                   begin
                                           SELECT resource_assignment_id,planning_start_date,
                                           planning_end_date,nvl(l_spread_curve_id,spread_curve_id),sp_fixed_date
                                           INTO l_resource_assignment_id,l_planning_start_date,
                                           l_planning_end_date,l_spread_curve_id,l_sp_fixed_date
                                           FROM pa_resource_assignments
                                           WHERE  budget_version_id=p_version_info_rec.x_budget_version_id
                                           AND task_id=px_budget_lines_in(i).pa_task_id
                                           AND resource_list_member_id=px_budget_lines_in(i).resource_list_member_id
                                           AND project_id=p_pa_project_id
                                           AND PROJECT_ASSIGNMENT_ID =-1;
                                   exception when no_data_found then
                                           if px_budget_lines_in(i).pa_task_id <> 0 then
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                           p_msg_name       => 'RES_ASSGN_DOESNT_EXIST_AMG',
                                                           p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                           p_value1         => l_amg_task_number,
                                                           p_token2         => 'RESOURCE',
                                                           p_value2         => px_budget_lines_in(i).resource_alias);
                                           else
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                           p_msg_name       => 'RES_ASSGN_DOESNT_EXIST_AMG',
                                                           p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                           p_value1         => l_project_number,
                                                           p_token2         => 'RESOURCE',
                                                           p_value2         => px_budget_lines_in(i).resource_alias);
                                           end if;
                                           l_any_error_occurred_flag := 'Y';
                                           l_invalid_resassgn_flag:='Y';
                                   end;

                                   G_res_assign_tbl(i).resource_assignment_id:=l_resource_assignment_id;

                                   if l_invalid_resassgn_flag <> 'Y' then
                                           if l_raid_hash_table.exists('RA'||l_resource_assignment_id) then
                                                   if px_budget_lines_in(i).pa_task_id <> 0 then
                                                           PA_UTILS.ADD_MESSAGE
                                                                  (p_app_short_name => 'PA',
                                                                   p_msg_name       => 'PA_ATTR_DUP_SRCH_ERR',
                                                                   p_token1         => 'ATTR_NAME',
                                                                   p_value1         => 'Task '||l_amg_task_number||' Resource '||px_budget_lines_in(i).resource_alias

                                                                   );
                                                   else
                                                           PA_UTILS.ADD_MESSAGE
                                                                   (p_app_short_name => 'PA',
                                                                    p_msg_name       => 'PA_ATTR_DUP_SRCH_ERR',
                                                                    p_token1         => 'ATTR_NAME',
                                                                    p_value1         => 'Project '||l_project_number||' Resource '||px_budget_lines_in(i).resource_alias

                                                                    );
                                                   end if;
                                                   l_any_error_occurred_flag := 'Y';
                                           else
                                                   l_raid_hash_table('RA'||l_resource_assignment_id).resource_assignment_id:=l_resource_assignment_id;
                                           end if;
                                   end if;

                                   l_invalid_plandates_flag :='N';

                                   if p_planning_start_date_tbl(i) = FND_API.G_MISS_DATE or
                                      p_planning_end_date_tbl(i) = FND_API.G_MISS_DATE   then
                                           if px_budget_lines_in(i).pa_task_id <> 0 then
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                   p_msg_name       => 'INVALID_PLANNING_DATES_AMG',
                                                   p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                   p_value1         => l_amg_task_number,
                                                   p_token2         => 'RESOURCE',
                                                   p_value2         => px_budget_lines_in(i).resource_alias);
                                           else
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                   p_msg_name       => 'INVALID_PLANNING_DATES_AMG',
                                                   p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                   p_value1         => l_project_number,
                                                   p_token2         => 'RESOURCE',
                                                   p_value2         => px_budget_lines_in(i).resource_alias);
                                           end if;
                                           l_any_error_occurred_flag := 'Y';
                                           l_invalid_plandates_flag  := 'Y';

                                    end if;

                                   if (l_invalid_plandates_flag  <> 'Y' and
                                       ((p_planning_start_date_tbl(i) is null and
                                           p_planning_end_date_tbl(i) is not null) or
                                        (p_planning_start_date_tbl(i) is not null and
                                           p_planning_end_date_tbl(i) is null) or
                                         (nvl(p_planning_end_date_tbl(i),FND_API.G_MISS_DATE) <
                                           nvl(p_planning_start_date_tbl(i),FND_API.G_MISS_DATE)))) then

                                           if px_budget_lines_in(i).pa_task_id <> 0 then
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                   p_msg_name       => 'INVALID_PLANNING_DATES_AMG',
                                                   p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                   p_value1         => l_amg_task_number,
                                                   p_token2         => 'RESOURCE',
                                                   p_value2         => px_budget_lines_in(i).resource_alias);
                                           else
                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                   p_msg_name       => 'INVALID_PLANNING_DATES_AMG',
                                                   p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                   p_value1         => l_project_number,
                                                   p_token2         => 'RESOURCE',
                                                   p_value2         => px_budget_lines_in(i).resource_alias);
                                           end if;
                                           l_any_error_occurred_flag := 'Y';
                                           l_invalid_plandates_flag  := 'Y';

                                   end if;

                                   IF l_spread_curve_id = l_fixed_date_sp_id THEN
                                           if (l_sp_fixed_date is null and (p_sp_fixed_date_tbl(i) is null or p_sp_fixed_date_tbl(i)= FND_API.G_MISS_DATE )) or
                                           (l_sp_fixed_date is not null and p_sp_fixed_date_tbl(i)= FND_API.G_MISS_DATE)
                                           then
                                                           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                           p_msg_name       => 'PA_FP_SP_FIXED_DATE_NULL');
                                                           l_any_error_occurred_flag := 'Y';
                                                           l_invalid_plandates_flag  := 'Y';
                                           end if;

                                           if l_invalid_plandates_flag <> 'Y' then
                                                   if ((nvl(p_sp_fixed_date_tbl(i),l_sp_fixed_date) <
                                                           nvl(p_planning_start_date_tbl(i),l_planning_start_date)) or
                                                           (nvl(p_sp_fixed_date_tbl(i),l_sp_fixed_date) >
                                                           nvl(p_planning_end_date_tbl(i),l_planning_end_date))) then

                                                           if px_budget_lines_in(i).pa_task_id <> 0 then
                                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                                           p_msg_name       => 'INVALID_FIXED_DATE_AMG',
                                                                           p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                                           p_value1         => l_amg_task_number,
                                                                           p_token2         => 'RESOURCE',
                                                                           p_value2         => px_budget_lines_in(i).resource_alias);
                                                           else
                                                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                                           p_msg_name       => 'INVALID_FIXED_DATE_AMG',
                                                                           p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                                                           p_value1         => l_project_number,
                                                                           p_token2         => 'RESOURCE',
                                                                           p_value2         => px_budget_lines_in(i).resource_alias);
                                                    end if;
                                                   l_any_error_occurred_flag := 'Y';

                                           end if;

                                   end if;



                           END IF;
                          end if; -- end of newly introduced checks for UPDATE_PLANNING_ELEMENT_ATTR
                   END IF;  -- Bug 3986129: FP.M Web ADI ,UPDATE_PLANNING_ELEMENT_ATTR

           -- hari 11th may
              IF ( p_calling_context NOT IN( 'RES_ASSGNMT_LEVEL_VALIDATION','WEBADI','UPDATE_PLANNING_ELEMENT_ATTR') OR --Bug 5509192
                  (p_calling_context = 'WEBADI' AND ((NOT (p_delete_flag_tbl.exists(i))) OR
                                                          Nvl(p_delete_flag_tbl(i), 'N') <> 'Y')))
              THEN
                    --Validate the change reason code. This validation is added for Fin plan model in FP L
                   IF (px_budget_lines_in(i).change_reason_code IS NOT NULL AND
                       ((p_calling_context = 'WEBADI' AND px_budget_lines_in(i).change_reason_code  <> FND_API.G_MISS_CHAR) OR
                        (p_calling_context <> 'WEBADI' AND px_budget_lines_in(i).change_reason_code  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))) THEN

                          OPEN l_budget_change_reason_csr( px_budget_lines_in(i).change_reason_code );
                          FETCH l_budget_change_reason_csr INTO l_dummy;
                          IF l_budget_change_reason_csr%NOTFOUND THEN
                              CLOSE l_budget_change_reason_csr;

                              IF p_calling_context <> 'WEBADI' THEN
                                         IF (p_budget_type_code IS NULL  OR
                                             p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN

                                               l_context_info := l_fin_plan_type_name;
                                               /*  Bug 3133930- set the return status to the new output variable */
                                               x_budget_lines_out(i).return_status := x_return_status;
                                         ELSE

                                                l_context_info := p_budget_type_code;
                                         END IF;
                                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                             PA_UTILS.add_message
                                             (p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_CHANGE_REASON_INVALID_AMG',
                                              p_token1         => 'PROJECT',
                                              p_value1         =>  l_amg_project_rec.segment1,
                                              p_token2         => 'TASK',
                                              p_value2         => l_amg_task_number,
                                              p_token3         => 'BUDGET_TYPE',
                                              p_value3         => l_context_info ,
                                              p_token4         => 'START_DATE',
                                              p_value4         => to_char(px_budget_lines_in(i).budget_start_date));
                                          END IF;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    /*  Bug 3133930- set the return status to the new output variable */
                                    x_budget_lines_out(i).return_status := x_return_status;
                                    --RAISE FND_API.G_EXC_ERROR;
                              ELSE --p_calling_context <> 'WEBADI' THEN
                                    -- populate the error code specific to webadi context
                                    l_webadi_err_code_tbl.extend(1);
                                    l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_INV_RESN_CODE_PASSED';
                                    l_webadi_err_task_id_tbl.extend(1);
                                    l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                    l_webadi_err_rlm_id_tbl.extend(1);
                                    l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                    l_webadi_err_txn_curr_tbl.extend(1);
                                    l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                    l_webadi_err_amt_type_tbl.extend(1);
                                    l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                              END IF;  -- calling context WEBADI


                              l_any_error_occurred_flag:='Y';
                          ELSE
                              CLOSE l_budget_change_reason_csr;
                          END IF;
                   END IF;--IF (px_budget_lines_in(i).change_reason_code IS NOT NULL AND
                END IF; --p_calling_context <> 'RES_ASSGNMT_LEVEL_VALIDATION','UPDATE_PLANNING_ELEMENT_ATTR'

                 IF p_fin_plan_type_id IS NOT NULL and p_calling_context <> 'UPDATE_PLANNING_ELEMENT_ATTR' THEN -- Bug 5509192

                      --Bug#4457546:Added code to throw an error when amounts are entered for a period which
                      --does not fall within the planning start/end dates of resource assignment
                      --This API validate_budget_lines is being called from the following API's
                      --CREATE_DRAFT_BUDGET  (PACKAGE PA_BUDGET_PUB)
                      --ADD_BUDGET_LINE      (PACKAGE PA_BUDGET_PUB)
                      --UPDATE_BUDGET        (PACKAGE PA_BUDGET_PUB)
                      --UPDATE_BUDGET_LINE   (PACKAGE PA_BUDGET_PUB)
                      --CREATE_DRAFT_FINPLAN (PACKAGE PA_BUDGET_PUB)
                      --INSERT_BUDGET_LINE   (PACKAGE PA_BUDGET_PVT)
                      -- Of all the above places the below if condition would only be satisfied by ADD_BUDGET_LINE, UPDATE_BUDGET,
                      --UPDATE_BUDGET_LINE for finplan model only which is what is required here. This validation should only be done
                      --only from these calling places and only for finplan model.

                      IF ( p_calling_context = 'BUDGET_LINE_LEVEL_VALIDATION' and p_version_info_rec.x_budget_version_id is not null)
                      THEN
		      	                        -- Start of Bug 8854015
 	                        IF (px_budget_lines_in(i).budget_start_date IS NOT NULL AND
 	                            px_budget_lines_in(i).budget_start_date <> FND_API.G_MISS_DATE) AND
 	                           (px_budget_lines_in(i).budget_end_date IS NOT NULL AND
 	                            px_budget_lines_in(i).budget_end_date <> FND_API.G_MISS_DATE) AND
 	                            l_period_time_phased_code = 'N'
 	                        THEN
 	                          IF (px_budget_lines_in(i).budget_end_date < px_budget_lines_in(i).budget_start_date)
 	                          THEN
 	                            x_return_status := FND_API.G_RET_STS_ERROR;
 	                            x_budget_lines_out(i).return_status := x_return_status;
 	                            PA_UTILS.add_message
 	                            (p_app_short_name => 'PA',
 	                             p_msg_name       => 'PA_INVALID_END_DATE');
 	                            l_any_error_occurred_flag:='Y';
 	                          ELSE
 	                               l_plan_start_date   := px_budget_lines_in(i).budget_start_date;
 	                               l_plan_end_date     := px_budget_lines_in(i).budget_end_date;

 	                               IF (px_budget_lines_in(i).resource_alias IS NOT NULL AND
 	                                   px_budget_lines_in(i).resource_alias <> FND_API.G_MISS_CHAR)
 	                               THEN

 	                                  l_resource_alias    := px_budget_lines_in(i).resource_alias;

 	                               ELSE

 	                                 SELECT  alias
 	                                 INTO   px_budget_lines_in(i).resource_alias
 	                                 FROM   pa_resource_list_members
 	                                 WHERE  resource_list_member_id = px_budget_lines_in(i).resource_list_member_id;

 	                                 l_resource_alias    := px_budget_lines_in(i).resource_alias;

 	                               END IF;
 	                          END IF;

 	                        ELSE
 	                        -- End of Bug 8854015

                        --Prepare the index in this form for each budget line.
                         l_distinct_taskid_rlmid_index := 'T'||px_budget_lines_in(i).pa_task_id||'R'||px_budget_lines_in(i).resource_list_member_id;

                          --Checking if the values are already present in the tables(l_plan_start_date_tbl, l_plan_end_date_tbl,
                          --l_task_name_tbl, l_resource_alias_tbl) for the index which we just prepared above. If the values are persent
                          --in these tables then done fire the below select
                         IF ( NOT(l_plan_start_date_tbl.exists(l_distinct_taskid_rlmid_index)
                             AND l_plan_end_date_tbl.exists(l_distinct_taskid_rlmid_index)
                             AND l_resource_alias_tbl.exists(l_distinct_taskid_rlmid_index) ) )
                         THEN
                             --Fire this select only if the values are not present in the above tables for any of the four values
                             --that we are reading in the below query.
                              BEGIN
                              -- We have to handle the no_data_found exception for this select because this select could be fired for
                              -- caselike from add_budget_line, the budget_line is being added for first time so there wont be any
                              --record in pa_resource_assignments when line is added for first time.
                                 SELECT pra.planning_start_date,
                                        pra.planning_end_date,
                                        prlm.alias
                                 INTO l_plan_start_date,
                                      l_plan_end_date,
                                      l_resource_alias
                                 FROM pa_resource_assignments pra,
                                      pa_resource_list_members prlm
                                 WHERE pra.budget_version_id = p_version_info_rec.x_budget_version_id
                                 AND   pra.resource_list_member_id = px_budget_lines_in(i).resource_list_member_id
                                 AND   pra.task_id = px_budget_lines_in(i).pa_task_id
                                 AND   prlm.resource_list_member_id = pra.resource_list_member_id;
                              EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
                                     l_plan_start_date := null;
                                     l_plan_end_date := null;
                                     l_resource_alias := null;
                              END;

                                    --Store the values just read in the tables for caching purpose
                                    l_plan_start_date_tbl(l_distinct_taskid_rlmid_index) := l_plan_start_date;
                                    l_plan_end_date_tbl(l_distinct_taskid_rlmid_index) := l_plan_end_date;
                                    l_resource_alias_tbl(l_distinct_taskid_rlmid_index) := l_resource_alias;

                         ELSE
                                 --The tables already contain the values so read the values from the tables.
                                 l_plan_start_date   := l_plan_start_date_tbl(l_distinct_taskid_rlmid_index);
                                 l_plan_end_date     := l_plan_end_date_tbl(l_distinct_taskid_rlmid_index);
                                 l_resource_alias    := l_resource_alias_tbl(l_distinct_taskid_rlmid_index);
                         END IF;
                END IF;  -- Bug 8854015
                          --Added this if condition below for the bug#4479835
                          --We should do these validations only when the above query returned a record.
                          IF (l_plan_start_date is not null)
                          THEN
                                  IF (px_budget_lines_in(i).budget_start_date IS NOT NULL AND
                                      px_budget_lines_in(i).budget_start_date <> FND_API.G_MISS_DATE) AND
                                     (px_budget_lines_in(i).budget_end_date IS NOT NULL AND
                                      px_budget_lines_in(i).budget_end_date <> FND_API.G_MISS_DATE) THEN

                                          -- checking if the budget line start date/ end date falls between
                                          -- the planning start date/ end date

                                          --After the above  of l_period_time_phased_code, if l_period_time_phased_code = N
                                          --then it means its a non periodic finplan case
                                          IF ( l_period_time_phased_code <> 'N')
                                          THEN
                                              ---Added this code for bug#4488926. Caching the values of l_period_start_date and
                                              --l_period_end_date
                                              IF ( NOT(l_period_start_date_tbl.exists(to_char(l_plan_start_date))
                                                   AND l_period_end_date_tbl.exists(to_char(l_plan_end_date))))
                                                   THEN
                                                  --For periodic case get the start and end dates.
                                                  l_period_start_date := PA_FIN_PLAN_UTILS.get_period_start_date(l_plan_start_date,l_period_time_phased_code);
                                                  l_period_end_date :=  PA_FIN_PLAN_UTILS.get_period_end_date (l_plan_end_date , l_period_time_phased_code);
                                                  l_period_start_date_tbl(to_char(l_plan_start_date)) := l_period_start_date;
                                                  l_period_end_date_tbl(to_char(l_plan_end_date)) := l_period_end_date;
                                              ELSE
                                                  l_period_start_date := l_period_start_date_tbl(to_char(l_plan_start_date));
                                                  l_period_end_date := l_period_end_date_tbl(to_char(l_plan_end_date));
                                              END IF;
                                          ELSE
                                          --Its a non periodic case.
                                                  l_period_start_date := l_plan_start_date;
                                                  l_period_end_date :=  l_plan_end_date;
                                          END IF;

                                          IF (px_budget_lines_in(i).budget_start_date < l_period_start_date OR
                                             px_budget_lines_in(i).budget_end_date > l_period_end_date)
                                          THEN
                                              x_return_status := FND_API.G_RET_STS_ERROR;
                                              x_budget_lines_out(i).return_status := x_return_status;
                                              PA_UTILS.add_message
                                              (p_app_short_name => 'PA',
                                               p_msg_name       => 'PA_FP_START_END_DATE_NOT_VALID',
                                               p_token1         => 'TASK',
                                               p_value1         => l_amg_task_number,
                                               p_token2         => 'RESOURCE',
                                               p_value2         => l_resource_alias,
                                               p_token3         => 'CURRENCY',
                                               p_value3         => px_budget_lines_in(i).txn_currency_code,
                                               p_token4         => 'START_DATE',
                                               p_value4         => to_char(px_budget_lines_in(i).budget_start_date) );
                                           l_any_error_occurred_flag:='Y';
                                          END IF;
                                    ELSIF ( p_time_phased_code = 'N' and
                                           (px_budget_lines_in(i).budget_start_date IS NULL
                                            OR px_budget_lines_in(i).budget_start_date  = FND_API.G_MISS_DATE )
                                           AND (px_budget_lines_in(i).budget_end_date IS NULL
                                            OR px_budget_lines_in(i).budget_end_date  = FND_API.G_MISS_DATE ) )THEN

                                           px_budget_lines_in(i).budget_start_date := l_plan_start_date;
                                           px_budget_lines_in(i).budget_end_date :=   l_period_end_date;

                                  END IF; --px_budget_lines_in(i).budget_start_date IS NOT NULL AND
                          END IF; --IF (l_plan_start_date is not null)
                      END IF;-- p_calling_context='BUDGET_LINE_LEVEL_VALIDATION' and p_version_info_rec.x_budget_version_id is not null


                        --Validate the txn currency code provided by the user. The follwing checks are made.
                        --1.If the version is an approved revenue version then the txn curr code should be PFC.
                        --else If the version is MC enabled then txn curr code should be among the txn
                        --currencies provided at the plan type level option
                        --else if the version is not MC enabled then the txn curr code should be PC


                        -- check for approved rev plan type flag is made here because in case plan type is at
                        -- cost and revenue separately then version can have currencies other than PFC.
                        l_valid_txn_curr := FALSE;
                        IF(l_app_rev_plan_type_flag = 'Y' AND
                           p_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST) THEN

                              --Bug 4382980:Issue#19 - Currency Defaulting when txn_currency_code
                              --is null done as suggested by Venkatesh Jayeraman
                              IF (px_budget_lines_in(i).txn_currency_code IS NULL ) THEN
                                   -- bug 4462614: added the following check for webadi context
                                   IF p_calling_context = 'WEBADI' THEN
                                         IF l_webadi_ci_id IS NULL THEN
                                             px_budget_lines_in(i).txn_currency_code:=l_projfunc_currency_code;
                                         ELSE
                                             px_budget_lines_in(i).txn_currency_code:=l_webadi_agr_curr_code;
                                         END IF;
                                   ELSE
                                         px_budget_lines_in(i).txn_currency_code:=l_projfunc_currency_code;
                                   END IF;

                              END IF; -- if currency passed is null

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Plan Version is approved for revenue';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              IF l_webadi_ci_id IS NULL THEN
                                    -- non ci version for both web adi and other contexts
                                    IF(nvl(px_budget_lines_in(i).txn_currency_code,'-99') <>
                                                            l_projfunc_currency_code) THEN
                                          IF p_calling_context <> 'WEBADI' THEN
                                                PA_UTILS.ADD_MESSAGE
                                                  ( p_app_short_name => 'PA',
                                                    p_msg_name       => 'PA_FP_TXN_NOT_PFC_FOR_APP_REV',
                                                    p_token1         => 'PROJECT',
                                                    p_value1         =>  l_amg_project_rec.segment1,
                                                    p_token2         => 'PLAN_TYPE',
                                                    p_value2         =>  l_fin_plan_type_name,
                                                    p_token3         => 'CURRENCY',
                                                    p_value3         =>  px_budget_lines_in(i).txn_currency_code);


                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                /*  Bug 3133930- set the return status to the new output variable */
                                                x_budget_lines_out(i).return_status := x_return_status;

                                          ELSE
                                                -- populate the error code specific to webadi context
                                                l_webadi_err_code_tbl.extend(1);
                                                l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_TXN_CURR_NOT_PFC_AR';
                                                l_webadi_err_task_id_tbl.extend(1);
                                                l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                                l_webadi_err_rlm_id_tbl.extend(1);
                                                l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                                l_webadi_err_txn_curr_tbl.extend(1);
                                                l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                                l_webadi_err_amt_type_tbl.extend(1);
                                                l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                          END IF;  -- p_calling_context <> WEBADI

                                          l_any_error_occurred_flag:='Y';
                                    ELSE
                                        l_valid_txn_curr := TRUE;
                                    END IF;
                              ELSE  -- bug 4462614:
                                    -- ci versions, webadi context only.
                                    IF(nvl(px_budget_lines_in(i).txn_currency_code,'-99') <>
                                                            l_webadi_agr_curr_code) THEN
                                        -- txn curr code passed is not agreement currency
                                        l_webadi_err_code_tbl.extend(1);
                                        l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_TXN_CURR_NOT_AGR_CUR';
                                        l_webadi_err_task_id_tbl.extend(1);
                                        l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                        l_webadi_err_rlm_id_tbl.extend(1);
                                        l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                        l_webadi_err_txn_curr_tbl.extend(1);
                                        l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                        l_webadi_err_amt_type_tbl.extend(1);
                                        l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);

                                        l_any_error_occurred_flag:='Y';
                                    ELSE
                                        l_valid_txn_curr := TRUE;
                                    END IF;
                              END IF; -- l_ci_id null

                        -- Version is not approved for revenue. The txn curr must be available in fp txn curr table
                        ELSE

                              --Bug 4382980:Issue#19 - Currency Defaulting when txn_currency_code
                              --is null done as suggested by Venkatesh Jayeraman
                              IF (px_budget_lines_in(i).txn_currency_code IS NULL
                              AND p_multi_currency_flag='N')
                              THEN

                                    px_budget_lines_in(i).txn_currency_code:=l_project_currency_code;

                              END IF; -- if currency passed is null

                              IF( nvl(px_budget_lines_in(i).txn_currency_code,'-99') <>
                                                      l_project_currency_code
                                 AND nvl(px_budget_lines_in(i).txn_currency_code,'-99') <>
                                                      l_projfunc_currency_code ) THEN

                                  IF(p_multi_currency_flag = 'Y') THEN --Added for bug 4290310.
                                        IF l_valid_txn_currencies_tbl.exists(l_valid_txn_currencies_tbl.first) THEN

                                              FOR l_txn_tbl_index in l_valid_txn_currencies_tbl.first..l_valid_txn_currencies_tbl.last LOOP

                                                    IF( nvl(px_budget_lines_in(i).txn_currency_code,'-99')= l_valid_txn_currencies_tbl(l_txn_tbl_index)) THEN

                                                          l_valid_txn_curr := TRUE;

                                                          EXIT;

                                                    END IF;

                                              END LOOP;

                                        END IF;
                                  ELSE
                                         l_valid_txn_curr := FALSE;
                                  END IF;
                              ELSE --The Txn curr code is either PC or PFC

                                  l_valid_txn_curr := TRUE;

                              END IF;--IF(l_app_rev_plan_type_flag = 'Y') THEN

                              --The txn currency code passed is not valid
                              IF NOT l_valid_txn_curr THEN
                                    IF p_calling_context <> 'WEBADI' THEN
                                          --Add a message to the stack since the txn curr code is not valid
                                          PA_UTILS.ADD_MESSAGE
                                            ( p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_FP_TXN_NOT_ADDED_FOR_PT',
                                              p_token1         => 'PROJECT',
                                              p_value1         =>  l_amg_project_rec.segment1,
                                              p_token2         => 'PLAN_TYPE',
                                              p_value2         =>  l_fin_plan_type_name,
                                              p_token3         => 'CURRENCY',
                                              p_value3         =>  px_budget_lines_in(i).txn_currency_code);

                                          x_return_status := FND_API.G_RET_STS_ERROR;
                                          /*  Bug 3133930- set the return status to the new output variable */
                                          x_budget_lines_out(i).return_status := x_return_status;

                                          IF l_debug_mode = 'Y' THEN
                                                pa_debug.g_err_stage:= 'Txn Curreny Code Entered is '|| l_txn_curr_code ;
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;
                                    ELSE
                                          -- populate the error code specific to webadi context
                                          l_webadi_err_code_tbl.extend(1);
                                          l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := 'PA_FP_WA_TXN_CURR_NOT_AVL_PT';
                                          l_webadi_err_task_id_tbl.extend(1);
                                          l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                          l_webadi_err_rlm_id_tbl.extend(1);
                                          l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                          l_webadi_err_txn_curr_tbl.extend(1);
                                          l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                          l_webadi_err_amt_type_tbl.extend(1);
                                          l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);

                                    END IF;  -- WEBADI context

                                    l_any_error_occurred_flag:='Y';
                              END IF;

                        END IF;

                        -- deriving the value of a flag to continue the following processing
                        l_webadi_cont_proc_flag:='Y';
                        IF p_calling_context = 'WEBADI' THEN
                             IF (p_delete_flag_tbl.exists(i) AND
                                 Nvl(p_delete_flag_tbl(i), 'N') = 'Y')THEN
                                     l_webadi_cont_proc_flag := 'N';
                             END IF;
                        END IF;
                        -- validation of curr attributes is done only if the currency passed is a valid currency.
                        IF l_valid_txn_curr THEN
                              IF l_webadi_cont_proc_flag = 'Y' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                                   l_wa_val_conv_attr_flag := 'Y';
                                   --TXN Currency is valid . validate the currency attributes
                                   IF   (px_budget_lines_in(i).project_cost_rate_type        IS NULL     AND
                                         px_budget_lines_in(i).project_cost_rate_date_type   IS NULL     AND
                                         px_budget_lines_in(i).project_cost_rate_date        IS NULL     AND
                                         px_budget_lines_in(i).projfunc_cost_rate_type       IS NULL     AND
                                         px_budget_lines_in(i).projfunc_cost_rate_date_type  IS NULL     AND
                                         px_budget_lines_in(i).projfunc_cost_rate_date       IS NULL     AND
                                         px_budget_lines_in(i).project_rev_rate_type         IS NULL     AND
                                         px_budget_lines_in(i).project_rev_rate_date_type    IS NULL     AND
                                         px_budget_lines_in(i).project_rev_rate_date         IS NULL     AND
                                         px_budget_lines_in(i).projfunc_rev_rate_type        IS NULL     AND
                                         px_budget_lines_in(i).projfunc_rev_rate_date_type   IS NULL     AND
                                         px_budget_lines_in(i).projfunc_rev_rate_date        IS NULL     ) THEN

                                      IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage := 'Deriving the conversion attrs from plan Version option';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                      END IF;

                                      -- Bug 3986129: FP.M Web ADI Dev changes: included the following check
                                      IF p_calling_context <> 'WEBADI' THEN
                                          px_budget_lines_in(i).project_cost_rate_type      := p_project_cost_rate_type      ;
                                          px_budget_lines_in(i).project_cost_rate_date_type := p_project_cost_rate_date_typ  ;
                                          px_budget_lines_in(i).project_cost_rate_date      := p_project_cost_rate_date      ;
                                          px_budget_lines_in(i).projfunc_cost_rate_type     := p_projfunc_cost_rate_type     ;
                                          px_budget_lines_in(i).projfunc_cost_rate_date_type:= p_projfunc_cost_rate_date_typ ;
                                          px_budget_lines_in(i).projfunc_cost_rate_date     := p_projfunc_cost_rate_date     ;
                                          px_budget_lines_in(i).project_rev_rate_type       := p_project_rev_rate_type       ;
                                          px_budget_lines_in(i).project_rev_rate_date_type  := p_project_rev_rate_date_typ   ;
                                          px_budget_lines_in(i).project_rev_rate_date       := p_project_rev_rate_date       ;
                                          px_budget_lines_in(i).projfunc_rev_rate_type      := p_projfunc_rev_rate_type      ;
                                          px_budget_lines_in(i).projfunc_rev_rate_date_type := p_projfunc_rev_rate_date_typ  ;
                                          px_budget_lines_in(i).projfunc_rev_rate_date      := p_projfunc_rev_rate_date      ;
                                      END IF;

                                      l_wa_val_conv_attr_flag := 'N';

                                   -- Conversion attributes are passed. Validate them
                                   ELSE
                                      -- Depending on p_version_type initialise l_conv_attrs_to_be_validated
                                      IF (p_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL) THEN
                                             l_conv_attrs_to_be_validated := p_version_type;
                                      ELSE
                                             l_conv_attrs_to_be_validated := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;
                                      END IF;

                                      -- Null out the cost attributes for revenue version and vice versa
                                      IF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN

                                          px_budget_lines_in(i).project_rev_rate_type       :=NULL;
                                          px_budget_lines_in(i).project_rev_rate_date_type  :=NULL;
                                          px_budget_lines_in(i).project_rev_rate_date       :=NULL;
                                          px_budget_lines_in(i).project_rev_exchange_rate   :=NULL;

                                          px_budget_lines_in(i).projfunc_rev_rate_type      :=NULL;
                                          px_budget_lines_in(i).projfunc_rev_rate_date_type :=NULL;
                                          px_budget_lines_in(i).projfunc_rev_rate_date      :=NULL;
                                          px_budget_lines_in(i).projfunc_rev_exchange_rate  :=NULL;

                                      ELSIF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN

                                          px_budget_lines_in(i).project_cost_rate_type        :=NULL;
                                          px_budget_lines_in(i).project_cost_rate_date_type   :=NULL;
                                          px_budget_lines_in(i).project_cost_rate_date        :=NULL;
                                          px_budget_lines_in(i).project_cost_exchange_rate    :=NULL;

                                          px_budget_lines_in(i).projfunc_cost_rate_type      :=NULL;
                                          px_budget_lines_in(i).projfunc_cost_rate_date_type :=NULL;
                                          px_budget_lines_in(i).projfunc_cost_rate_date      :=NULL;
                                          px_budget_lines_in(i).projfunc_cost_exchange_rate  :=NULL;

                                      END IF;

                                      -- Bug 3986129: FP.M Web ADI Dev changes: included the following check
                                         IF p_calling_context = 'WEBADI' AND
                                            l_wa_val_conv_attr_flag='Y'  THEN

                                              IF px_budget_lines_in(i).project_cost_rate_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_project_cost_rate_typ := NULL;
                                              ELSE
                                                     l_wa_project_cost_rate_typ := px_budget_lines_in(i).project_cost_rate_type;
                                              END IF;
                                              IF px_budget_lines_in(i).project_cost_rate_date_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_project_cost_rate_dt_typ := NULL;
                                              ELSE
                                                     l_wa_project_cost_rate_dt_typ := px_budget_lines_in(i).project_cost_rate_date_type;
                                              END IF;
                                              IF px_budget_lines_in(i).project_cost_rate_date = FND_API.G_MISS_DATE THEN
                                                     l_wa_project_cost_rate_date := NULL;
                                              ELSE
                                                     l_wa_project_cost_rate_date := px_budget_lines_in(i).project_cost_rate_date;
                                              END IF;
                                              IF px_budget_lines_in(i).project_cost_exchange_rate = FND_API.G_MISS_NUM THEN
                                                     l_wa_project_cost_exc_rate := NULL;
                                              ELSE
                                                     l_wa_project_cost_exc_rate := px_budget_lines_in(i).project_cost_exchange_rate;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_cost_rate_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_projfunc_cost_rate_typ := NULL;
                                              ELSE
                                                     l_wa_projfunc_cost_rate_typ := px_budget_lines_in(i).projfunc_cost_rate_type;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_cost_rate_date_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_projfunc_cost_rate_dt_typ := NULL;
                                              ELSE
                                                     l_wa_projfunc_cost_rate_dt_typ := px_budget_lines_in(i).projfunc_cost_rate_date_type;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_cost_rate_date = FND_API.G_MISS_DATE THEN
                                                     l_wa_projfunc_cost_rate_date := NULL;
                                              ELSE
                                                     l_wa_projfunc_cost_rate_date := px_budget_lines_in(i).projfunc_cost_rate_date;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_cost_exchange_rate = FND_API.G_MISS_NUM THEN
                                                     l_wa_projfunc_cost_exc_rate := NULL;
                                              ELSE
                                                     l_wa_projfunc_cost_exc_rate := px_budget_lines_in(i).projfunc_cost_exchange_rate;
                                              END IF;
                                              IF px_budget_lines_in(i).project_rev_rate_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_project_rev_rate_typ := NULL;
                                              ELSE
                                                     l_wa_project_rev_rate_typ := px_budget_lines_in(i).project_rev_rate_type;
                                              END IF;
                                              IF px_budget_lines_in(i).project_rev_rate_date_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_project_rev_rate_dt_typ := NULL;
                                              ELSE
                                                     l_wa_project_rev_rate_dt_typ := px_budget_lines_in(i).project_rev_rate_date_type;
                                              END IF;
                                              IF px_budget_lines_in(i).project_rev_rate_date = FND_API.G_MISS_DATE THEN
                                                     l_wa_project_rev_rate_date := NULL;
                                              ELSE
                                                     l_wa_project_rev_rate_date := px_budget_lines_in(i).project_rev_rate_date;
                                              END IF;
                                              IF px_budget_lines_in(i).project_rev_exchange_rate = FND_API.G_MISS_NUM THEN
                                                     l_wa_project_rev_exc_rate := NULL;
                                              ELSE
                                                     l_wa_project_rev_exc_rate := px_budget_lines_in(i).project_rev_exchange_rate;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_rev_rate_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_projfunc_rev_rate_typ := NULL;
                                              ELSE
                                                     l_wa_projfunc_rev_rate_typ := px_budget_lines_in(i).projfunc_rev_rate_type;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_rev_rate_date_type = FND_API.G_MISS_CHAR THEN
                                                     l_wa_projfunc_rev_rate_dt_typ := NULL;
                                              ELSE
                                                     l_wa_projfunc_rev_rate_dt_typ := px_budget_lines_in(i).projfunc_rev_rate_date_type;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_rev_rate_date = FND_API.G_MISS_DATE THEN
                                                     l_wa_projfunc_rev_rate_date := NULL;
                                              ELSE
                                                     l_wa_projfunc_rev_rate_date := px_budget_lines_in(i).projfunc_rev_rate_date;
                                              END IF;
                                              IF px_budget_lines_in(i).projfunc_rev_exchange_rate = FND_API.G_MISS_NUM THEN
                                                     l_wa_projfunc_rev_exc_rate := NULL;
                                              ELSE
                                                     l_wa_projfunc_rev_exc_rate := px_budget_lines_in(i).projfunc_rev_exchange_rate;
                                              END IF;
                                         END IF; -- p_context = WEBADI

                                      --Validate the conversion attributes passed
                                      IF p_calling_context = 'WEBADI' AND
                                         l_wa_val_conv_attr_flag='Y' THEN
                                            pa_fin_plan_utils.validate_currency_attributes
                                            ( px_project_cost_rate_type      => l_wa_project_cost_rate_typ
                                             ,px_project_cost_rate_date_typ  => l_wa_project_cost_rate_dt_typ
                                             ,px_project_cost_rate_date      => l_wa_project_cost_rate_date
                                             ,px_project_cost_exchange_rate  => l_wa_project_cost_exc_rate
                                             ,px_projfunc_cost_rate_type     => l_wa_projfunc_cost_rate_typ
                                             ,px_projfunc_cost_rate_date_typ => l_wa_projfunc_cost_rate_dt_typ
                                             ,px_projfunc_cost_rate_date     => l_wa_projfunc_cost_rate_date
                                             ,px_projfunc_cost_exchange_rate => l_wa_projfunc_cost_exc_rate
                                             ,px_project_rev_rate_type       => l_wa_project_rev_rate_typ
                                             ,px_project_rev_rate_date_typ   => l_wa_project_rev_rate_dt_typ
                                             ,px_project_rev_rate_date       => l_wa_project_rev_rate_date
                                             ,px_project_rev_exchange_rate   => l_wa_project_rev_exc_rate
                                             ,px_projfunc_rev_rate_type      => l_wa_projfunc_rev_rate_typ
                                             ,px_projfunc_rev_rate_date_typ  => l_wa_projfunc_rev_rate_dt_typ
                                             ,px_projfunc_rev_rate_date      => l_wa_projfunc_rev_rate_date
                                             ,px_projfunc_rev_exchange_rate  => l_wa_projfunc_rev_exc_rate
                                             ,p_project_currency_code        => l_project_currency_code
                                             ,p_projfunc_currency_code       => l_projfunc_currency_code
                                             ,p_context                      => PA_FP_CONSTANTS_PKG.G_WEBADI
                                             ,p_attrs_to_be_validated        => l_conv_attrs_to_be_validated
                                             ,x_return_status                => x_return_status
                                             ,x_msg_count                    => x_msg_count
                                             ,x_msg_data                     => x_msg_data);
                                      ELSE
                                            pa_fin_plan_utils.validate_currency_attributes
                                            ( px_project_cost_rate_type      =>px_budget_lines_in(i).project_cost_rate_type
                                             ,px_project_cost_rate_date_typ  =>px_budget_lines_in(i).project_cost_rate_date_type
                                             ,px_project_cost_rate_date      =>px_budget_lines_in(i).project_cost_rate_date
                                             ,px_project_cost_exchange_rate  =>px_budget_lines_in(i).project_cost_exchange_rate
                                             ,px_projfunc_cost_rate_type     =>px_budget_lines_in(i).projfunc_cost_rate_type
                                             ,px_projfunc_cost_rate_date_typ =>px_budget_lines_in(i).projfunc_cost_rate_date_type
                                             ,px_projfunc_cost_rate_date     =>px_budget_lines_in(i).projfunc_cost_rate_date
                                             ,px_projfunc_cost_exchange_rate =>px_budget_lines_in(i).projfunc_cost_exchange_rate
                                             ,px_project_rev_rate_type       =>px_budget_lines_in(i).project_rev_rate_type
                                             ,px_project_rev_rate_date_typ   =>px_budget_lines_in(i).project_rev_rate_date_type
                                             ,px_project_rev_rate_date       =>px_budget_lines_in(i).project_rev_rate_date
                                             ,px_project_rev_exchange_rate   =>px_budget_lines_in(i).project_rev_exchange_rate
                                             ,px_projfunc_rev_rate_type      =>px_budget_lines_in(i).projfunc_rev_rate_type
                                             ,px_projfunc_rev_rate_date_typ  =>px_budget_lines_in(i).projfunc_rev_rate_date_type
                                             ,px_projfunc_rev_rate_date      =>px_budget_lines_in(i).projfunc_rev_rate_date
                                             ,px_projfunc_rev_exchange_rate  =>px_budget_lines_in(i).projfunc_rev_exchange_rate
                                             ,p_project_currency_code        =>l_project_currency_code
                                             ,p_projfunc_currency_code       =>l_projfunc_currency_code
                                             ,p_context                      =>PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL
                                             ,p_attrs_to_be_validated        =>l_conv_attrs_to_be_validated
                                             ,x_return_status                =>x_return_status
                                             ,x_msg_count                    =>x_msg_count
                                             ,x_msg_data                     =>x_msg_data);
                                      END IF;
                                          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                             IF p_calling_context <> 'WEBADI' THEN
                                                   /*  Bug 3133930- set the return status to the new output variable */
                                                   x_budget_lines_out(i).return_status := x_return_status;

                                             ELSIF l_wa_val_conv_attr_flag='Y' THEN
                                                   l_webadi_err_code_tbl.extend(1);
                                                   l_webadi_err_code_tbl(l_webadi_err_code_tbl.COUNT) := l_wa_error_code_lookup(PA_FIN_PLAN_UTILS.g_first_error_code);
                                                   l_webadi_err_task_id_tbl.extend(1);
                                                   l_webadi_err_task_id_tbl(l_webadi_err_task_id_tbl.COUNT) := px_budget_lines_in(i).pa_task_id;
                                                   l_webadi_err_rlm_id_tbl.extend(1);
                                                   l_webadi_err_rlm_id_tbl(l_webadi_err_rlm_id_tbl.COUNT) := px_budget_lines_in(i).resource_list_member_id;
                                                   l_webadi_err_txn_curr_tbl.extend(1);
                                                   l_webadi_err_txn_curr_tbl(l_webadi_err_txn_curr_tbl.COUNT) := px_budget_lines_in(i).txn_currency_code;
                                                   l_webadi_err_amt_type_tbl.extend(1);
                                                   l_webadi_err_amt_type_tbl(l_webadi_err_amt_type_tbl.COUNT) := p_amount_type_tbl(i);
                                             END IF;

                                             l_any_error_occurred_flag:='Y';
                                          ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                                             IF p_calling_context = 'WEBADI' THEN --Bug 4382980
                                                 -- copying back the validated attribute in the rac type
                                                 px_budget_lines_in(i).project_cost_rate_type := l_wa_project_cost_rate_typ;
                                                 px_budget_lines_in(i).project_cost_rate_date_type := l_wa_project_cost_rate_dt_typ;
                                                 px_budget_lines_in(i).project_cost_rate_date := l_wa_project_cost_rate_date;
                                                 px_budget_lines_in(i).project_cost_exchange_rate := l_wa_project_cost_exc_rate;
                                                 px_budget_lines_in(i).projfunc_cost_rate_type := l_wa_projfunc_cost_rate_typ;
                                                 px_budget_lines_in(i).projfunc_cost_rate_date_type := l_wa_projfunc_cost_rate_dt_typ;
                                                 px_budget_lines_in(i).projfunc_cost_rate_date := l_wa_projfunc_cost_rate_date;
                                                 px_budget_lines_in(i).projfunc_cost_exchange_rate := l_wa_projfunc_cost_exc_rate;
                                                 px_budget_lines_in(i).project_rev_rate_type := l_wa_project_rev_rate_typ;
                                                 px_budget_lines_in(i).project_rev_rate_date_type := l_wa_project_rev_rate_dt_typ;
                                                 px_budget_lines_in(i).project_rev_rate_date := l_wa_project_rev_rate_date;
                                                 px_budget_lines_in(i).project_rev_exchange_rate := l_wa_project_rev_exc_rate;
                                                 px_budget_lines_in(i).projfunc_rev_rate_type := l_wa_projfunc_rev_rate_typ;
                                                 px_budget_lines_in(i).projfunc_rev_rate_date_type := l_wa_projfunc_rev_rate_dt_typ;
                                                 px_budget_lines_in(i).projfunc_rev_rate_date := l_wa_projfunc_rev_rate_date;
                                                 px_budget_lines_in(i).projfunc_rev_exchange_rate := l_wa_projfunc_rev_exc_rate;
                                             END IF;
                                          END IF; -- return_status
                                   END IF;--IF all parameters are null
                              END IF; -- cont_proc_flag
                        END IF; -- IF l_valid_txn_curr THEN

                        /* Bug 4224464: FP M Changes Start */
                        --Check if Actuals have been entered for the FORECAST Line. We perform this
                        --check only when p_version_info_rec.x_budget_version_id has been passed.
                        IF p_calling_context <> 'WEBADI' THEN
                              IF (p_version_info_rec.x_budget_version_id IS NOT NULL)
                              THEN
                                    OPEN budget_version_info_cur(p_version_info_rec.x_budget_version_id);
                                    FETCH budget_version_info_cur
                                    INTO  l_plan_class_code
                                         ,l_etc_start_date;

                                    IF budget_version_info_cur%NOTFOUND
                                    THEN
                                         l_any_error_occurred_flag := 'Y';
                                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                         THEN
                                               PA_UTILS.add_message
                                               (p_app_short_name => 'PA'
                                               ,p_msg_name       => 'PA_FP_NO_WORKING_VERSION'
                                               ,p_token1         => 'PROJECT'
                                               ,p_value1         => l_amg_project_rec.segment1
                                               ,p_token2         => 'PLAN_TYPE'
                                               ,p_value2         => l_fin_plan_type_name
                                               ,p_token3         => 'VERSION_NUMBER'
                                               ,p_value3         => '' );
                                         END IF;

                                         IF l_debug_mode = 'Y' THEN
                                               pa_debug.g_err_stage := 'Passed Budget Version Id is invalid';
                                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                         END IF;

                                    END IF; --budget_version_info_cur%NOTFOUND

                                    CLOSE budget_version_info_cur;

                                    IF (l_plan_class_code IS NOT NULL AND
                                        l_plan_class_code = 'FORECAST' AND
                                        l_etc_start_date IS NOT NULL AND
                                        l_etc_start_date > px_budget_lines_in(i).budget_start_date AND
                                        p_time_phased_code IS NOT NULL AND
                                        p_time_phased_code <> 'N')
                                    THEN
                                          l_any_error_occurred_flag := 'Y';
                                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                          THEN
                                                PA_UTILS.add_message
                                                (p_app_short_name => 'PA'
                                                ,p_msg_name       => 'PA_FP_FCST_ACTUALS_AMG'
                                                ,p_token1         => 'PROJECT'
                                                ,p_value1         => l_amg_project_rec.segment1
                                                ,p_token2         => 'PLAN_TYPE'
                                                ,p_value2         => l_fin_plan_type_name
                                                ,p_token3         => 'TASK'
                                                ,p_value3         => l_amg_task_number
                                                ,p_token4         => 'CURRENCY'
                                                ,p_value4         => px_budget_lines_in(i).txn_currency_code
                                                ,p_token5         => 'START_DATE'
                                                ,p_value5         => to_char(px_budget_lines_in(i).budget_start_date) );
                                          END IF;

                                          IF l_debug_mode = 'Y' THEN
                                                pa_debug.g_err_stage := 'Forecast Line has actuals and hence cannot be edited';
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                          END IF;

                                    END IF;--end of actuals-on-FORECAST check

                              END IF; --budget_version_id IS NOT NULL
                        END IF; -- p_calling_context
                        /* Bug 4224464: FP M Changes End */

                  END IF; -- IF p_fin_plan_type_id IS NOT NULL THEN

            END LOOP; -- ;For Loop

      END IF;--Check for the existence of budget lines

      -- Bug 3986129: FP.M Web ADI Dev changes
      IF p_calling_context = 'WEBADI' THEN
            IF l_webadi_err_code_tbl.COUNT > 0 THEN
                  -- call an api to populate the error code in the excel sheet
                  pa_fp_webadi_pkg.process_errors
                        ( p_run_id          => p_run_id,
                          p_error_code_tbl  => l_webadi_err_code_tbl,
                          p_task_id_tbl     => l_webadi_err_task_id_tbl,
                          p_rlm_id_tbl      => l_webadi_err_rlm_id_tbl,
                          p_txn_curr_tbl    => l_webadi_err_txn_curr_tbl,
                          p_amount_type_tbl => l_webadi_err_amt_type_tbl,
                          x_return_status   => x_return_status,
                          x_msg_data        => x_msg_data,
                          x_msg_count       => x_msg_count);

                       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'Call to process_errors returned with error';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                             END IF;

                             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;
            END IF;  -- error tbl count > 0
      END IF; -- Bug 3986129

      --Raise an error if any errors are reported till this poing
      IF l_any_error_occurred_flag = 'Y' THEN
            IF p_calling_context <> 'WEBADI' THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Reporting the errors occured while validating budget lines';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF; -- non webadi context
      END IF;

      -- Null out the global variables.
      pa_budget_pvt.g_Task_number    := NULL;
      pa_budget_pvt.g_start_date     := NULL;
      pa_budget_pvt.g_resource_alias := NULL;


      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting Validate Budget Lines';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
      END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

            IF  x_return_status IS NULL OR
                x_return_status = FND_API.G_RET_STS_SUCCESS THEN
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
	  IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
	  END IF;
            RETURN;

      WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

            THEN
                  FND_MSG_PUB.add_exc_msg
                  (  p_pkg_name           => G_PKG_NAME
                  ,  p_procedure_name     => 'Validate_Budget_Lines' );

            END IF;
	  IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
	  END IF;
END validate_budget_lines;



PROCEDURE GET_FIN_PLAN_LINES_STATUS
          (p_calling_context                 IN                VARCHAR2 DEFAULT NULL
          ,p_fin_plan_version_id               IN             pa_budget_versions.budget_version_id%TYPE
          ,p_budget_lines_in                 IN             PA_BUDGET_PUB.budget_line_in_tbl_type
          ,x_fp_lines_retn_status_tab     OUT NOCOPY     PA_BUDGET_PUB.budget_line_out_tbl_type
          ,x_return_status                      OUT NOCOPY     VARCHAR2
          ,x_msg_count                          OUT NOCOPY     NUMBER
          ,x_msg_data                           OUT NOCOPY     VARCHAR2)

IS

l_cost_rejection_data_tab           PA_PLSQL_DATATYPES.Char2000TabTyp;
l_burden_rejection_data_tab         PA_PLSQL_DATATYPES.Char2000TabTyp;
l_revenue_rejection_data_tab       PA_PLSQL_DATATYPES.Char2000TabTyp;
l_pc_conv_rejection_data_tab       PA_PLSQL_DATATYPES.Char2000TabTyp;
l_pfc_conv_rejection_data_tab      PA_PLSQL_DATATYPES.Char2000TabTyp;
l_other_rejection_data_tab          PA_PLSQL_DATATYPES.Char2000TabTyp;
l_return_status                    VARCHAR2(1);
l_fin_plan_line_id_tab             PA_PLSQL_DATATYPES.IDTABTYP;
l_fp_lines_retn_status_tab          PA_BUDGET_PUB.budget_line_out_tbl_type;
l_debug_mode                        VARCHAR2(1);
l_module_name                       VARCHAR2(80);
l_tmp_return_status                VARCHAR2(1);
I                                  NUMBER;
l_count                            NUMBER;
l_time_phased_code                pa_proj_fp_options.all_time_phased_code%TYPE;      -- Added for BUG 6847497
l_uncategorized_flag              pa_resource_lists_all_bg.uncategorized_flag%TYPE;  -- Added for BUG 6847497
l_budget_type_code                pa_budget_versions.budget_type_code%TYPE;   -- Added for BUG 6653796

CURSOR get_primary_key_csr IS
SELECT ra.task_id,
     ra.resource_list_member_id,
     bl.txn_currency_code,
     bl.start_date,
     DECODE(bl.cost_rejection_code,NULL,
          DECODE(bl.revenue_rejection_code,NULL,
               DECODE(bl.burden_rejection_code,NULL,
                    DECODE(bl.other_rejection_code,NULL,
                         DECODE(bl.pfc_cur_conv_rejection_code,NULL,
                              DECODE(bl.pc_cur_conv_rejection_code,NULL,NULL,'E')
                                   ,'E'),'E'),'E'),'E'),'E') return_status
FROM pa_resource_assignments ra , pa_budget_lines bl
where ra.budget_version_id = p_fin_plan_version_id
and ra.resource_assignment_id = bl.resource_assignment_id;

BEGIN

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
l_module_name :=  'PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS ';

          IF l_debug_mode = 'Y' THEN
              pa_debug.set_curr_function( p_function   => l_module_name,
                                          p_debug_mode => l_debug_mode );
          END IF;


PA_FIN_PLAN_UTILS2.Get_AMG_BdgtLineRejctions
                (p_budget_version_id              =>   p_fin_plan_version_id
                ,x_budget_line_id_tab             =>   l_fin_plan_line_id_tab
                ,x_cost_rejection_data_tab        =>   l_cost_rejection_data_tab
                ,x_burden_rejection_data_tab      =>   l_burden_rejection_data_tab
                ,x_revenue_rejection_data_tab     =>   l_revenue_rejection_data_tab
                ,x_pc_conv_rejection_data_tab     =>   l_pc_conv_rejection_data_tab
                ,x_pfc_conv_rejection_data_tab    =>   l_pfc_conv_rejection_data_tab
                ,x_other_rejection_data_tab       =>   l_other_rejection_data_tab
                ,x_return_status                  =>   l_return_status ) ;

IF l_return_status ='U' THEN

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             FND_MSG_PUB.add_exc_msg
                 (  p_pkg_name       => 'PA_BUDGET_PVT'
                   ,p_procedure_name => 'GET_FIN_PLAN_LINES_STATUS' );

     END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IF;

IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

     IF nvl(l_fin_plan_line_id_tab.LAST,0) > 0 THEN                 /* Bug # 3588604 */

               FOR I in l_fin_plan_line_id_tab.FIRST .. l_fin_plan_line_id_tab.LAST LOOP

                         IF L_cost_rejection_data_tab(I) IS NOT NULL THEN

                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     =>l_cost_rejection_data_tab(i));

                         END IF;

                         IF l_burden_rejection_data_tab(I) IS NOT NULL THEN

                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     =>l_burden_rejection_data_tab(i));

                         END IF;
                         IF l_revenue_rejection_data_tab(I) IS NOT NULL THEN

                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     =>l_revenue_rejection_data_tab(i));

                         END IF;
                         IF l_pc_conv_rejection_data_tab(I) IS NOT NULL THEN

                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     =>l_pc_conv_rejection_data_tab(i));

                         END IF;
                         IF l_pfc_conv_rejection_data_tab(I) IS NOT NULL THEN

                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     =>l_pfc_conv_rejection_data_tab(i));

                         END IF;

                         IF l_other_rejection_data_tab(I) IS NOT NULL THEN
                                pa_utils.Add_Message( p_app_short_name  => 'PA'
                                                     ,p_msg_name     => l_other_rejection_data_tab(i));

                         END IF;

               END LOOP;

     END IF;   --IF nvl(l_fin_plan_line_id_tab.LAST,0) > 0

END IF;

-- Bug 8318068 Tring to get budget type code to find if its old model budget to avoid processing being done as
-- per code fix for bug 6653796.
BEGIN
  SELECT budget_type_code
  INTO l_budget_type_code
  FROM pa_budget_versions
  WHERE budget_version_id = p_fin_plan_version_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_budget_type_code    := NULL;
END;

IF l_budget_type_code IS NULL THEN
  BEGIN /* Added for bug 7611462 */

	 SELECT nvl(cost_time_phased_code,NVL(revenue_time_phased_code,all_time_phased_code)),     -- Added for BUG 6847497
 	        prl.uncategorized_flag
 	 INTO   l_time_phased_code, l_uncategorized_flag
 	 FROM   pa_proj_fp_options , pa_resource_lists_all_bg prl
 	 WHERE  fin_plan_version_id=p_fin_plan_version_id
 	 AND    nvl(cost_resource_list_id,nvl(revenue_resource_list_id,all_resource_list_id))=
 	        prl.resource_list_id;

	/* Added below logic for bug 7611462 */
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    l_time_phased_code := NULL;
		l_uncategorized_flag := NULL;
   END;/* Ends added for bug 7611462 */
END IF; --IF l_budget_type_code IS NULL THEN

/*===========================================================================+
 | The amg api pa_budgets_pub.CREATE_DRAFT_FINPLAN need to know if           |
 | any of budget lines in the budget version had any rejections.             |
 | And that's all it need to know. x_return_status is being reused for this. |
 +===========================================================================*/
IF ( p_calling_context = 'CREATE_DRAFT_FINPLAN')
THEN
          IF ( NVL(l_fin_plan_line_id_tab.LAST,0) > 0 )
          THEN
                       x_return_status := 'R';
          END IF;

END IF; --p_calling_context <> 'CREATE_DRAFT_FINPLAN'

/*=========================================================================+
 | pa_budgets_pub.CREATE_DRAFT_FINPLAN is AMG api. When this api is called |
 | from CREATE_DRAFT_FINPLAN, p_budget_lines_in is not passed in.          |
 | Rejections at the budget line level need not be returned back. Hence    |
 | the following code not executed for when it is calling from the AMG api.|
 +=========================================================================*/
IF ( NVL(p_calling_context,'-99') <> 'CREATE_DRAFT_FINPLAN')
THEN
FOR l_primary_key_tab IN get_primary_key_csr LOOP

          l_count := 0;

          IF nvl(p_budget_lines_in.LAST,0) > 0 THEN                      /* Bug # 3588604 */

               FOR k in p_budget_lines_in.FIRST .. p_budget_lines_in.LAST LOOP

                   IF l_budget_type_code IS NULL THEN --Bug 8318068
               /* Added null handing for l_time_phased_code for bug 7611462 */
                     IF ( p_budget_lines_in(k).pa_task_id = l_primary_key_tab.task_id) AND    -- Modified for BUG 6847497
                       (((NVL(l_uncategorized_flag,'N')<>'Y') AND (p_budget_lines_in(k).resource_list_member_id = l_primary_key_tab.resource_list_member_id)) OR l_uncategorized_flag = 'Y') AND
                       (((nvl(l_time_phased_code, 'Y') <> 'N') AND (nvl(p_budget_lines_in(k).budget_start_date, l_primary_key_tab.start_date) = l_primary_key_tab.start_date)) OR l_time_phased_code = 'N') AND
                       (nvl(p_budget_lines_in(k).txn_currency_code,l_primary_key_tab.txn_currency_code) = l_primary_key_tab.txn_currency_code) THEN

                    l_count := 1;
                    l_fp_lines_retn_status_tab(k).return_status := l_primary_key_tab.return_status;

                    END IF;
                   ELSE
                      IF (p_budget_lines_in(k).pa_task_id = l_primary_key_tab.task_id) AND
                         (p_budget_lines_in(k).resource_list_member_id = l_primary_key_tab.resource_list_member_id ) AND
                         (nvl(p_budget_lines_in(k).budget_start_date,l_primary_key_tab.start_date) = l_primary_key_tab.start_date) AND
                         (nvl(p_budget_lines_in(k).txn_currency_code,l_primary_key_tab.txn_currency_code) = l_primary_key_tab.txn_currency_code) THEN

                        l_count := 1;
                        l_fp_lines_retn_status_tab(k).return_status := l_primary_key_tab.return_status;

                      END IF;
                   END IF; -- IF l_budget_type_code IS NULL THEN

               EXIT WHEN (l_count = 1);

               END LOOP;

          END IF ;                  --IF nvl(p_budget_lines_in.LAST,0) > 0


IF (l_count = 0) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

x_fp_lines_retn_status_tab := l_fp_lines_retn_status_tab ;
END IF; -- p_calling_context <> 'CREATE_DRAFT_FINPLAN'
-- bug 7813303
IF l_debug_mode = 'Y' THEN
   pa_debug.reset_curr_function;
END IF;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
  	IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write('GET_FIN_PLAN_LINES_STATUS: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                -- bug 7813303 - replaced reset_err_stack with reset_curr_function
                -- pa_debug.reset_err_stack;
                pa_debug.reset_curr_function;

	END IF;
           RETURN;

WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_budget_pvt'
                                  ,p_procedure_name  => 'GET_FIN_PLAN_LINES_STATUS');

	     IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write('GET_FIN_PLAN_LINES_STATUS: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               -- bug 7813303 - replaced reset_err_stack with reset_curr_function
                -- pa_debug.reset_err_stack;
                pa_debug.reset_curr_function;

	     END IF;
          FND_MSG_PUB.Count_And_Get (p_count     =>  x_msg_count
                                    ,p_data      =>  x_msg_data  );
          RAISE;


END GET_FIN_PLAN_LINES_STATUS;


-- Function             : Is_bc_enabled_for_budget
-- Purpose              : This functions returns true if a record exists in
--                        PA_BC_BALANCES table for the given budget version id
-- Parameters           : Budget Version Id.
--

FUNCTION Is_bc_enabled_for_budget
( p_budget_version_id   IN    NUMBER )
RETURN BOOLEAN
IS

      CURSOR bc_enabled_for_budg_ver_csr
      IS
      SELECT 'Y'
      FROM pa_bc_balances
      WHERE budget_version_id = p_budget_version_id;

l_return_value    VARCHAR2(2) := 'N';

BEGIN

      OPEN bc_enabled_for_budg_ver_csr;
      FETCH bc_enabled_for_budg_ver_csr into l_return_value;
      CLOSE bc_enabled_for_budg_ver_csr;

      IF ( l_return_value = 'Y' ) THEN
            RETURN true;
      ELSE
            RETURN false;
      END IF;

END Is_bc_enabled_for_budget;




--Name:               Get_Latest_BC_Year
--Type:               Procedure
--Description:        For budgetary control projects, this procedure fetches the
--                    latest encumbrance year for the project's set-of-books.
--
--
--
--History:
--   27-SEP-2005    jwhite    Created per bug 4588279


  PROCEDURE Get_Latest_BC_Year
          ( p_pa_project_id                IN      pa_projects_all.project_id%TYPE
            ,x_latest_encumbrance_year     OUT     NOCOPY gl_ledgers.Latest_Encumbrance_Year%TYPE
            ,x_return_status               OUT     NOCOPY VARCHAR2
            ,x_msg_count                   OUT     NOCOPY NUMBER
            ,x_msg_data                    OUT     NOCOPY VARCHAR2
              )

  IS

         l_debug_mode                      VARCHAR2(1)  := NULL;
         l_module_name                     VARCHAR2(80) :=NULL;

  BEGIN

         x_msg_count := 0;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
         l_module_name :=  'PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS ';

         IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => l_module_name,
                                          p_debug_mode => l_debug_mode );
         END IF;



         SELECT l.Latest_Encumbrance_Year
         INTO   x_latest_encumbrance_year
         FROM   GL_ledgers l
                , pa_implementations_all i
                , pa_projects_all p
         WHERE  l.LEDGER_ID = i.set_of_books_id
         AND        i.org_id = p.org_id
         AND        p.project_id  = p_pa_project_id;



  EXCEPTION

  WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_budget_pvt'
                                  ,p_procedure_name  => 'GET_LATEST_BC_YEAR');
	  IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
             pa_debug.write('GET_LATEST_BC_YEAR: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.reset_err_stack;
	  END IF;
          FND_MSG_PUB.Count_And_Get (p_count     =>  x_msg_count
                                    ,p_data      =>  x_msg_data  );
          RAISE;


  END Get_Latest_BC_Year;






end PA_BUDGET_PVT;

/
