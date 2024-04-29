--------------------------------------------------------
--  DDL for Package Body PA_FP_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_UPGRADE_PKG" AS
/* $Header: PAFPUPGB.pls 120.7.12010000.4 2009/02/09 12:09:03 spasala ship $*/

l_module_name VARCHAR2(100):= 'pa.plsql.pa_fp_upgrade_pkg';
p_pa_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_migration_code varchar2(1) := null;

TYPE res_list_tbl IS TABLE OF
     pa_resource_lists_all_bg.resource_list_id%TYPE INDEX BY BINARY_INTEGER;

TYPE bud_typ_code_tbl IS TABLE OF
     pa_budget_versions.budget_type_code%TYPE INDEX BY BINARY_INTEGER;

TYPE ra_id_tbl_type IS TABLE OF
        pa_resource_assignments.resource_assignment_id%TYPE INDEX BY BINARY_INTEGER;

   TYPE rtx_ra_id_tbl_type IS TABLE OF
        pa_resource_asgn_curr.resource_assignment_id%TYPE INDEX BY BINARY_INTEGER;

l_budget_ver_tbl    SYSTEM.PA_NUM_TBL_TYPE;
l_res_list_tbl      res_list_tbl;
l_bud_typ_code_tbl  bud_typ_code_tbl;
l_ra_id_tbl         ra_id_tbl_type;
l_rtx_ra_id_tbl     rtx_ra_id_tbl_type;

-- The following cursor is required both in upgrade_budgets api and
-- also validate_budgets api so, the cursoe has been declared here.


CURSOR projects_for_upgrade_cur1 (
        c_from_project_number   IN   VARCHAR2
       ,c_to_project_number     IN   VARCHAR2
       ,c_project_type          IN   pa_projects.project_type%TYPE
       ,c_project_statuses      IN   VARCHAR2) IS
SELECT project_id
FROM   pa_projects
WHERE  segment1 BETWEEN  c_from_project_number AND  c_to_project_number
AND    NVL(c_project_type,project_type) = project_type
AND    DECODE(c_project_statuses,'ALL','ACTIVE',project_status_code) <> 'CLOSED';  --Bug 5194368


CURSOR projects_for_upgrade_cur2 (
        c_from_project_number   IN   VARCHAR2
       ,c_to_project_number     IN   VARCHAR2
       ,c_project_type          IN   pa_projects.project_type%TYPE
       ,c_project_statuses      IN   VARCHAR2) IS
SELECT project_id
FROM   pa_projects
WHERE  segment1 BETWEEN  NVL(c_from_project_number,segment1) AND  NVL(c_to_project_number,segment1)
AND    c_project_type = project_type
AND    DECODE(c_project_statuses,'ALL','ACTIVE',project_status_code) <> 'CLOSED';  --Bug 5194368


CURSOR projects_for_upgrade_cur3 (
        c_from_project_number   IN   VARCHAR2
       ,c_to_project_number     IN   VARCHAR2
       ,c_project_type          IN   pa_projects.project_type%TYPE
       ,c_project_statuses      IN   VARCHAR2) IS
SELECT project_id
FROM   pa_projects
WHERE  segment1 BETWEEN  NVL(c_from_project_number,segment1) AND  NVL(c_to_project_number,segment1)
AND    NVL(c_project_type,project_type) = project_type
AND    project_status_code <> 'CLOSED';  --Bug 5194368



CURSOR projects_for_upgrade_cur (
        c_from_project_number   IN   VARCHAR2
       ,c_to_project_number     IN   VARCHAR2
       ,c_project_type          IN   pa_projects.project_type%TYPE
       ,c_project_statuses      IN   VARCHAR2) IS
SELECT project_id
FROM   pa_projects
WHERE  segment1 BETWEEN  NVL(c_from_project_number,segment1) AND  NVL(c_to_project_number,segment1)
AND    NVL(c_project_type,project_type) = project_type
AND    DECODE(c_project_statuses,'ALL','ACTIVE',project_status_code) <> 'CLOSED';  --Bug 5194368

project_info_rec         projects_for_upgrade_cur%ROWTYPE;

CURSOR project_type_info_cur (
         c_project_id         IN       pa_projects.project_id%TYPE)IS
SELECT  allow_cost_budget_entry_flag
       ,allow_rev_budget_entry_flag
       ,name
       ,segment1
       ,org_project_flag -- bug 2788983
FROM    pa_project_types ppt
       ,pa_projects  pp
WHERE  pp.project_id = c_project_id
AND    ppt.project_type = pp.project_type;

project_type_info_rec  project_type_info_cur%ROWTYPE;

CURSOR attached_plan_types_cur(
           c_project_id        IN    pa_projects.project_id%TYPE
           ,c_budget_types     IN    VARCHAR2 ) IS
SELECT  pt.fin_plan_type_id  fin_plan_type_id
       ,bt.budget_Type_code  budget_Type_code
FROM   pa_fin_plan_types_b pt /* Bug# 2661650 - Replaced _vl by _b for performance reasons */
       ,pa_budget_types     bt
WHERE  DECODE(c_budget_types,'ALL','Y', bt.upgrade_budget_type_flag) = 'Y'
AND    bt.budget_type_code  = pt.migrated_frm_bdgt_typ_code
AND    NVL(bt.plan_type,'BUDGET') = 'BUDGET'
AND    not exists
           (SELECT 1
            FROM   pa_proj_fp_options ppfo
            WHERE  ppfo.project_id = c_project_id
            AND    ppfo.fin_plan_type_id = pt.fin_plan_type_id
            AND    ppfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE)
AND    exists
          (SELECT 1
           FROM   pa_budget_versions pbv
           WHERE  pbv.project_id = c_project_id
           AND    pbv.budget_type_code = bt.budget_type_code);

attached_plan_types_rec attached_plan_types_cur%ROWTYPE;

-- The follwing cursor would be used in validate_budget_version and also
-- upgrade_budget_versions apis. So, the cursor has been declared here.

-- bug 3673111, 07-JUN-4, jwhite -------------------------------
-- Add resource_list_id as a new column in the select statement.

CURSOR budgets_for_upgrade_cur (
           c_project_id            IN   pa_projects.project_id%TYPE
          ,c_budget_types          IN   VARCHAR2
          ,c_budget_statuses       IN   VARCHAR2
          ,c_mode                  IN   VARCHAR2  ) IS
SELECT budget_version_id
       , bt.budget_type_code
       , bv.resource_list_id  /* bug 3673111, 07-JUN-4, jwhite: New Column */
       , bv.budget_status_code -- Bug# 7187487
FROM   pa_budget_versions bv,
       pa_budget_types  bt
WHERE  bv.project_id = c_project_id
AND    bt.budget_type_code = bv.budget_type_code
AND    bv.budget_type_code IS NOT NULL
AND    DECODE(c_budget_types,'ALL','Y',bt.upgrade_budget_type_flag) = 'Y'
AND    NVL(bt.plan_type,'BUDGET') = 'BUDGET' /* Bug 2758786 */
AND    EXISTS (
                SELECT 1 FROM DUAL
                WHERE  c_budget_statuses = 'ALL'
                UNION  ALL
                SELECT 1 FROM DUAL
                WHERE  (current_original_flag = 'Y' OR
                        original_flag         = 'Y' OR
                        current_flag          = 'Y' OR
                        budget_status_code    IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING) )
                AND    c_budget_statuses = 'CWB')
AND    (c_mode = 'PRE_UPGRADE' OR EXISTS (
                SELECT 1
                FROM   pa_proj_fp_options pfo,
                       pa_fin_plan_types_b pt /* Bug# 2661650 - Replaced _vl by _b for performance reasons */
                WHERE  pfo.project_id = c_project_id
                AND    pfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
                AND    pt.fin_plan_type_id = pfo.fin_plan_type_id
                AND    pt.migrated_frm_bdgt_typ_code = bv.budget_type_code));

budgets_for_upgrade_rec   budgets_for_upgrade_cur%ROWTYPE;

-- END bug 3673111, 07-JUN-4, jwhite -------------------------------

/*==============================================================================
This method will be called from all the apis in this package whenever the current
option changes. The api populates the local variables using the inputs and
the business rules for upgrade process.
==============================================================================*/
Procedure Populate_Local_Variables(
          p_project_id                  IN      pa_proj_fp_options.project_id%TYPE
          ,p_budget_type_code           IN      pa_budget_versions.budget_type_code%TYPE
          ,p_fin_plan_version_id        IN      pa_proj_fp_options.fin_plan_version_id%TYPE
          ,p_fin_plan_option_level      IN      pa_proj_fp_options.fin_plan_option_level_code%TYPE
         ,x_upgrade_elements_rec         OUT  NOCOPY  pa_fp_upgrade_pkg.upgrade_elements_rec_type
          ,x_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status                 VARCHAR2(2000);
l_msg_count                     NUMBER :=0;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(30);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);

l_cost_amount_set_id            pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_revenue_amount_set_id         pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_all_amount_set_id             pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;

l_track_as_labor_flag           pa_resource_list_members.track_as_labor_flag%TYPE;
l_resource_id                   pa_resource_list_members.resource_id%TYPE;

CURSOR budget_version_info_cur(
       c_budget_version_id      IN     pa_budget_versions.budget_version_id%TYPE) IS
SELECT pbv.budget_entry_method_code budget_entry_method_code
       ,resource_list_id
       ,entry_level_code
       ,time_phased_type_code
       ,cost_quantity_flag
       ,raw_cost_flag
       ,burdened_cost_flag
       ,rev_quantity_flag
       ,revenue_flag
FROM   pa_budget_versions pbv,
       pa_budget_entry_methods pbem
WHERE  pbv.budget_version_id = c_budget_version_id
AND    pbem.budget_entry_method_code = pbv.budget_entry_method_code;

budget_version_info_rec         budget_version_info_cur%ROWTYPE;

CURSOR project_type_level_info_cur (
       c_project_id       IN      pa_projects.project_id%TYPE) IS
SELECT cost_budget_entry_method_code
       ,cost_budget_resource_list_id
       ,rev_budget_entry_method_code
       ,rev_budget_resource_list_id
       ,allow_cost_budget_entry_flag
       ,allow_rev_budget_entry_flag
FROM   pa_projects a,
       pa_project_types b
WHERE  a.project_id = c_project_id
AND    b.project_type = a.project_type;

project_type_level_info_rec     project_type_level_info_cur%ROWTYPE;

CURSOR budget_entry_method_info_cur(
       c_budget_entry_method_code   IN    pa_budget_entry_methods.budget_entry_method_code%TYPE) IS
SELECT entry_level_code
       ,time_phased_type_code
       ,cost_quantity_flag
       ,raw_cost_flag
       ,burdened_cost_flag
       ,rev_quantity_flag
       ,revenue_flag
FROM   pa_budget_entry_methods
WHERE  budget_entry_method_code = c_budget_entry_method_code;

budget_entry_method_info_rec    budget_entry_method_info_cur%ROWTYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.Populate_Local_Variables');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);

    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Inside Populate_Local_Variables';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    -- Check for not null parameters
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Checking for valid parameters:';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    IF p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT THEN

          IF (p_project_id IS NULL) THEN
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'P_fin_plan_option_level='||p_fin_plan_option_level;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_project_id='||p_project_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                       p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

    ELSIF p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE THEN

          IF (p_project_id       IS     NULL) OR
             (p_budget_type_code IS     NULL) THEN
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'P_fin_plan_option_level='||p_fin_plan_option_level;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_project_id='||p_project_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_budget_type_code='||p_budget_type_code;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                       p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

    ELSIF p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

          IF (p_project_id          IS       NULL) OR
             (p_budget_type_code    IS       NULL) OR
             (p_fin_plan_version_id IS       NULL) THEN
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'P_fin_plan_option_level='||p_fin_plan_option_level;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_project_id='||p_project_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_budget_type_code='||p_budget_type_code;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_fin_plan_version_id='||p_fin_plan_version_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                       p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
    ELSE
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'P_fin_plan_option_level='||p_fin_plan_option_level;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Parameter validation complete';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'P_fin_plan_option_level='||p_fin_plan_option_level;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'p_project_id='||p_project_id;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'p_budget_type_code='||p_budget_type_code;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'p_fin_plan_version_id='||p_fin_plan_version_id;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    --Null Out all the global parameters.

    x_upgrade_elements_rec := NULL;

    x_upgrade_elements_rec.curr_option_budget_type_code := p_budget_type_code;

    IF  p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT THEN

           --Set the fp option related variables

           x_upgrade_elements_rec.curr_option_project_id      :=   p_project_id;
           x_upgrade_elements_rec.curr_option_plan_type_id    :=   NULL;
           x_upgrade_elements_rec.curr_option_plan_version_id :=   NULL;
           x_upgrade_elements_rec.curr_option_level_code      :=   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT;

           x_upgrade_elements_rec.curr_option_preference_code :=   PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP;

           --Fetch lastest Approved Cost baselined version id as basis_cost_version_id

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Calling pa_budget_utils.get_baselined_version_id for AC';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           pa_budget_utils.get_baselined_version_id (
                      x_project_id              =>      p_project_id
                      ,x_budget_type_code       =>      PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC
                      ,x_budget_version_id      =>      x_upgrade_elements_rec.basis_cost_version_id
                      ,x_err_code               =>      l_err_code
                      ,x_err_stage              =>      l_err_stage
                      ,x_err_stack              =>      l_err_stack);

           /* Bug# 2643043 -- Error code 10 is no_data_found */
           IF  l_err_code NOT IN (10,0)  THEN
              -- the api has returned an error
              IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_baselined_version_id';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;
              RAISE pa_fp_constants_pkg.invalid_arg_exc;
           END IF;

           IF  l_err_code = 10 or x_upgrade_elements_rec.basis_cost_version_id IS NULL THEN /* Bug# 2643043 */

                --Fetch Approved Cost working version as basis_cost_version_id

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Calling pa_budget_utils.get_draft_version_id as no baselined version for no AC';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                pa_budget_utils.get_draft_version_id (
                        x_project_id            =>      p_project_id
                        ,x_budget_type_code     =>      PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC
                        ,x_budget_version_id    =>      x_upgrade_elements_rec.basis_cost_version_id
                        ,x_err_code             =>      l_err_code
                        ,x_err_stage            =>      l_err_stage
                        ,x_err_stack            =>      l_err_stack);


              /* Bug# 2643043 -- Error code 10 is no_data_found */
              IF  l_err_code NOT IN (10,0)  THEN
                -- the api has returned an error
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_draft_version_id';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;
                RAISE pa_fp_constants_pkg.invalid_arg_exc;
              END IF;

/***   Bug# 2643043
****                IF  l_err_code <> 0 THEN
****                    x_upgrade_elements_rec.basis_cost_version_id := NULL;
****                END IF;
****   Bug# 2643043 */

           END IF;

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='cost_version_id ='||x_upgrade_elements_rec.basis_cost_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           --Fetch lastest Approved Revenue baselined version id as basis_rev_version_id

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Calling pa_budget_utils.get_baselined_version_id for AR';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           pa_budget_utils.get_baselined_version_id (
                      x_project_id              =>      p_project_id
                      ,x_budget_type_code       =>      PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR
                      ,x_budget_version_id      =>      x_upgrade_elements_rec.basis_rev_version_id
                      ,x_err_code               =>      l_err_code
                      ,x_err_stage              =>      l_err_stage
                      ,x_err_stack              =>      l_err_stack);


           /* Bug# 2643043 -- Error code 10 is no_data_found */
           IF  l_err_code NOT IN (10,0)  THEN
              -- the api has returned an error
              IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_baselined_version_id';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;
              RAISE pa_fp_constants_pkg.invalid_arg_exc;
           END IF;

           IF  l_err_code = 10 or x_upgrade_elements_rec.basis_rev_version_id IS NULL THEN /* Bug# 2643043 */

                -- baselined version doesn't exist

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Calling pa_budget_utils.get_draft_version_id as no baselined version for no AR';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                --Fetch Approved Revenue working version

                pa_budget_utils.get_draft_version_id (
                        x_project_id            =>      p_project_id
                        ,x_budget_type_code     =>      PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR
                        ,x_budget_version_id    =>      x_upgrade_elements_rec.basis_rev_version_id
                        ,x_err_code             =>      l_err_code
                        ,x_err_stage            =>      l_err_stage
                        ,x_err_stack            =>      l_err_stack);

/*** Bug# 2643043
****                IF l_err_code <> 0 THEN
****                    x_upgrade_elements_rec.basis_cost_version_id := NULL;
****                END IF;
**** Bug# 2643043 */

              /* Bug# 2643043 -- Error code 10 is no_data_found */
              IF  l_err_code NOT IN (10,0)  THEN
                -- the api has returned an error
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_draft_version_id';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;
                RAISE pa_fp_constants_pkg.invalid_arg_exc;
              END IF;

           END IF;

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='basis_rev_version_id ='||x_upgrade_elements_rec.basis_rev_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

    ELSIF  p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE THEN

           --Set the fp option related variables

           x_upgrade_elements_rec.curr_option_project_id      := p_project_id;
           x_upgrade_elements_rec.curr_option_plan_version_id := NULL;
           x_upgrade_elements_rec.curr_option_level_code      := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

           BEGIN
                   --Fetch plan type id using budget_type_code

                   SELECT fin_plan_type_id
                   INTO   x_upgrade_elements_rec.curr_option_plan_type_id
                   FROM   pa_fin_plan_types_b /* Bug# 2661650 - Replaced _vl by _b for performance reasons */
                   WHERE  migrated_frm_bdgt_typ_code = p_budget_type_code;

                   --Fetch preference code using budget amount code

                   SELECT DECODE(budget_amount_code,PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_C,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY
                                                ,PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_R,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY)
                   INTO  x_upgrade_elements_rec.curr_option_preference_code
                   FROM  pa_budget_types
                   WHERE budget_type_code = p_budget_type_code;

                EXCEPTION
                   WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='failed while fetching plan type id for plan_type option '||SQLERRM;
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
           END;

           IF x_upgrade_elements_rec.curr_option_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

                   --Fetch lastest  baselined version id as basis_cost_version_id

                   pa_budget_utils.get_baselined_version_id (
                              x_project_id              =>      p_project_id
                              ,x_budget_type_code       =>      p_budget_type_code
                              ,x_budget_version_id      =>      x_upgrade_elements_rec.basis_cost_version_id
                              ,x_err_code               =>      l_err_code
                              ,x_err_stage              =>      l_err_stage
                              ,x_err_stack              =>      l_err_stack);


                   /* Bug# 2643043 -- Error code 10 is no_data_found */
                   IF  l_err_code not in (10,0)  THEN
                     -- the api has returned an error
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_baselined_version_id';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                   END IF;

                   IF  l_err_code = 10 or x_upgrade_elements_rec.basis_cost_version_id IS NULL THEN /* Bug# 2643043 */

                        --Fetch working version as basis_cost_version_id

                        pa_budget_utils.get_draft_version_id (
                                x_project_id            =>      p_project_id
                                ,x_budget_type_code     =>      p_budget_type_code
                                ,x_budget_version_id    =>      x_upgrade_elements_rec.basis_cost_version_id
                                ,x_err_code             =>      l_err_code
                                ,x_err_stage            =>      l_err_stage
                                ,x_err_stack            =>      l_err_stack);

/*** Bug# 2643043
****                        IF l_err_code <> 0 THEN
****                            x_upgrade_elements_rec.basis_cost_version_id := NULL;
****                        END IF;
**** Bug# 2643043 */

                        /* Bug# 2643043 -- Error code 10 is no_data_found */
                        IF  l_err_code not in (10,0)  THEN
                          -- the api has returned an error
                          IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_draft_version_id';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                          END IF;
                          RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                        END IF;

                   END IF;
           ELSIF x_upgrade_elements_rec.curr_option_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

                   --Fetch lastest  baselined version id as basis_rev_version_id

                   pa_budget_utils.get_baselined_version_id (
                              x_project_id              =>      p_project_id
                              ,x_budget_type_code       =>      p_budget_type_code
                              ,x_budget_version_id      =>      x_upgrade_elements_rec.basis_rev_version_id
                              ,x_err_code               =>      l_err_code
                              ,x_err_stage              =>      l_err_stage
                              ,x_err_stack              =>      l_err_stack);


                   /* Bug# 2643043 -- Error code 10 is no_data_found */
                   IF  l_err_code not in (10,0)  THEN
                     -- the api has returned an error
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_baselined_version_id';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                   END IF;

                   IF  l_err_code = 10 or x_upgrade_elements_rec.basis_cost_version_id IS NULL THEN /* Bug# 2643043 */

                        --Fetch  working version as basis_rev_version_id

                        pa_budget_utils.get_draft_version_id (
                                x_project_id            =>      p_project_id
                                ,x_budget_type_code     =>      p_budget_type_code
                                ,x_budget_version_id    =>      x_upgrade_elements_rec.basis_rev_version_id
                                ,x_err_code             =>      l_err_code
                                ,x_err_stage            =>      l_err_stage
                                ,x_err_stack            =>      l_err_stack);

/*** Bug# 2643043
****                        IF l_err_code <> 0 THEN
****                            x_upgrade_elements_rec.basis_rev_version_id := NULL;
****                        END IF;
**** Bug# 2643043 */

                        /* Bug# 2643043 -- Error code 10 is no_data_found */
                        IF  l_err_code not in (10,0)  THEN
                          -- the api has returned an error
                          IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:='Error returned by  pa_budget_utils.get_draft_version_id';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                          END IF;
                          RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                        END IF;

                   END IF;
           END IF;

    ELSIF p_fin_plan_option_level = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

           --Set the fp option related variables

           x_upgrade_elements_rec.curr_option_project_id      := p_project_id;
           x_upgrade_elements_rec.curr_option_plan_version_id := p_fin_plan_version_id;
           x_upgrade_elements_rec.curr_option_level_code      := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION;

           BEGIN

                   --Fetch plan type id using budget_type_code

                   SELECT fin_plan_type_id
                   INTO   x_upgrade_elements_rec.curr_option_plan_type_id
                   FROM   pa_fin_plan_types_b /* Bug# 2661650 - Replaced _vl by _b for performance reasons */
                   WHERE  migrated_frm_bdgt_typ_code = p_budget_type_code;

                   --Fetch preference code using budget amount code

                   SELECT DECODE(budget_amount_code,PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_C,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY
                                                   ,PA_FP_CONSTANTS_PKG.G_BUDGET_AMOUNT_CODE_R,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY)
                   INTO  x_upgrade_elements_rec.curr_option_preference_code
                   FROM  pa_budget_types
                   WHERE budget_type_code = p_budget_type_code;

             EXCEPTION
                   WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Failed while fetching plan type id for version'||SQLERRM;
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
           END;

           --Using preference code set basis_cost_version_id /g_basis_revenue_version_id appropriately.

           IF x_upgrade_elements_rec.curr_option_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

                  x_upgrade_elements_rec.basis_cost_version_id   :=  p_fin_plan_version_id;

           ELSIF x_upgrade_elements_rec.curr_option_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

                  x_upgrade_elements_rec.basis_rev_version_id    :=  p_fin_plan_version_id;

           END IF;

    END IF;

    --If preference code is cost_only or cost_and_rev_sep then set cost variables.

    IF  x_upgrade_elements_rec.curr_option_preference_code IN(PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,
                                          PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP ) THEN

            IF x_upgrade_elements_rec.basis_cost_version_id IS NOT NULL THEN

                    --Using the basis_cost_version_id set all the cost variables.

                    OPEN  budget_version_info_cur(x_upgrade_elements_rec.basis_cost_version_id);
                    FETCH budget_version_info_cur  INTO budget_version_info_rec;
                    CLOSE budget_version_info_cur;


                    x_upgrade_elements_rec.basis_cost_bem := budget_version_info_rec.budget_entry_method_code;
                    x_upgrade_elements_rec.basis_cost_res_list_id := budget_version_info_rec.resource_list_id;
                    x_upgrade_elements_rec.basis_cost_planning_level := budget_version_info_rec.entry_level_code;
                    x_upgrade_elements_rec.basis_cost_time_phased_code := budget_version_info_rec.time_phased_type_code;

                    --The following api either returns amount set ids based on preference code
                    --and  the flag i/p parameters combination if it already exists OR else
                    --creates a new amount set id.

                    PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID(
                            p_raw_cost_flag             =>      budget_version_info_rec.raw_cost_flag
                            ,p_burdened_cost_flag       =>      budget_version_info_rec.burdened_cost_flag
                            ,p_revenue_flag             =>      budget_version_info_rec.revenue_flag
                            ,p_cost_qty_flag            =>      budget_version_info_rec.cost_quantity_flag
                            ,p_revenue_qty_flag         =>      budget_version_info_rec.rev_quantity_flag
                            ,p_all_qty_flag             =>      'N'
                            ,p_plan_pref_code           =>      x_upgrade_elements_rec.curr_option_preference_code
                            /* Changes for FP.M, Tracking Bug No - 3354518, Adding three new IN parameters p_bill_rate_flag,
                               p_cost_rate_flag, p_burden_multiplier below for new columns in pa_fin_plan_amount_sets
                               defaulting these parameters as 'Y'*/
                            ,p_bill_rate_flag           =>      'Y'
                            ,p_cost_rate_flag           =>      'Y'
                            ,p_burden_rate_flag         =>      'Y'
                            ,x_cost_amount_set_id       =>      x_upgrade_elements_rec.basis_cost_amount_set_id
                            ,x_revenue_amount_set_id    =>      l_revenue_amount_set_id
                            ,x_all_amount_set_id        =>      l_all_amount_set_id
                            ,x_message_count            =>      l_msg_count
                            ,x_return_status            =>      l_return_status
                            ,x_message_data             =>      l_msg_data );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
            ELSE

            --populate the variables using project type level cost options

                    --Fetch project type level options

                    OPEN project_type_level_info_cur(p_project_id);
                    FETCH project_type_level_info_cur INTO project_type_level_info_rec;
                    CLOSE project_type_level_info_cur;

                    IF project_type_level_info_rec.allow_cost_budget_entry_flag  = 'Y' THEN

                            OPEN budget_entry_method_info_cur(project_type_level_info_rec.cost_budget_entry_method_code);
                            FETCH budget_entry_method_info_cur INTO budget_entry_method_info_rec;
                            CLOSE budget_entry_method_info_cur;

                            x_upgrade_elements_rec.basis_cost_bem := project_type_level_info_rec.cost_budget_entry_method_code;
                            x_upgrade_elements_rec.basis_cost_res_list_id := project_type_level_info_rec.cost_budget_resource_list_id;
                            x_upgrade_elements_rec.basis_cost_planning_level := budget_entry_method_info_rec.entry_level_code;
                            x_upgrade_elements_rec.basis_cost_time_phased_code := budget_entry_method_info_rec.time_phased_type_code;

                            --The following api either returns amount set ids based on preference code
                            --and  the flag i/p parameters combination if it already exists OR else
                            --creates a new amount set id.

                            PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID(
                                    p_raw_cost_flag             =>      budget_entry_method_info_rec.raw_cost_flag
                                    ,p_burdened_cost_flag       =>      budget_entry_method_info_rec.burdened_cost_flag
                                    ,p_revenue_flag             =>      budget_entry_method_info_rec.revenue_flag
                                    ,p_cost_qty_flag            =>      budget_entry_method_info_rec.cost_quantity_flag
                                    ,p_revenue_qty_flag         =>      budget_entry_method_info_rec.rev_quantity_flag
                                    ,p_all_qty_flag             =>      'N'
                                    ,p_plan_pref_code           =>      x_upgrade_elements_rec.curr_option_preference_code
                            /* Changes for FP.M, Tracking Bug No - 3354518, Adding three new IN parameters p_bill_rate_flag,
                               p_cost_rate_flag, p_burden_multiplier below for new columns in pa_fin_plan_amount_sets
                               defaulting these parameters as 'Y'*/
                                    ,p_bill_rate_flag           =>      'Y'
                                    ,p_cost_rate_flag           =>      'Y'
                                    ,p_burden_rate_flag         =>      'Y'
                                    ,x_cost_amount_set_id       =>      x_upgrade_elements_rec.basis_cost_amount_set_id
                                    ,x_revenue_amount_set_id    =>      l_revenue_amount_set_id
                                    ,x_all_amount_set_id        =>      l_all_amount_set_id
                                    ,x_message_count            =>      l_msg_count
                                    ,x_return_status            =>      l_return_status
                                    ,x_message_data             =>      l_msg_data );

                              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END IF;
                    END IF;
            END IF;
     END IF;

    --If preference code is revenue_only or cost_and_rev_sep then set revenue variables.

    IF  x_upgrade_elements_rec.curr_option_preference_code IN(PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,
                                          PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP ) THEN

            IF x_upgrade_elements_rec.basis_rev_version_id IS NOT NULL THEN

                    --Using the basis_rev_version_id set all the cost variables.

                    OPEN  budget_version_info_cur(x_upgrade_elements_rec.basis_rev_version_id);
                    FETCH budget_version_info_cur  INTO budget_version_info_rec;
                    CLOSE budget_version_info_cur;

                    x_upgrade_elements_rec.basis_rev_bem := budget_version_info_rec.budget_entry_method_code;
                    x_upgrade_elements_rec.basis_rev_res_list_id := budget_version_info_rec.resource_list_id;
                    x_upgrade_elements_rec.basis_rev_planning_level := budget_version_info_rec.entry_level_code;
                    x_upgrade_elements_rec.basis_rev_time_phased_code := budget_version_info_rec.time_phased_type_code;

                    --The following api either returns amount set ids based on preference code
                    --and  the flag i/p parameters combination if it already exists OR else
                    --creates a new amount set id.

                    PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID(
                            p_raw_cost_flag             =>      budget_version_info_rec.raw_cost_flag
                            ,p_burdened_cost_flag       =>      budget_version_info_rec.burdened_cost_flag
                            ,p_revenue_flag             =>      budget_version_info_rec.revenue_flag
                            ,p_cost_qty_flag            =>      budget_version_info_rec.cost_quantity_flag
                            ,p_revenue_qty_flag         =>      budget_version_info_rec.rev_quantity_flag
                            ,p_all_qty_flag             =>      'N'
                            ,p_plan_pref_code           =>      x_upgrade_elements_rec.curr_option_preference_code
                            /* Changes for FP.M, Tracking Bug No - 3354518, Adding three new IN parameters p_bill_rate_flag,
                               p_cost_rate_flag, p_burden_multiplier below for new columns in pa_fin_plan_amount_sets
                               defaulting these parameters as 'Y'*/
                            ,p_bill_rate_flag           =>      'Y'
                            ,p_cost_rate_flag           =>      'Y'
                            ,p_burden_rate_flag         =>      'Y'
                            ,x_cost_amount_set_id       =>      l_cost_amount_set_id
                            ,x_revenue_amount_set_id    =>      x_upgrade_elements_rec.basis_rev_amount_set_id
                            ,x_all_amount_set_id        =>      l_all_amount_set_id
                            ,x_message_count            =>      l_msg_count
                            ,x_return_status            =>      l_return_status
                            ,x_message_data             =>      l_msg_data );
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
            ELSE
                    --Set revenue varaibles using project type revenue properties

                    --Fetch project type level options

                    OPEN project_type_level_info_cur(p_project_id);
                    FETCH project_type_level_info_cur INTO project_type_level_info_rec;
                    CLOSE project_type_level_info_cur;

                    --Using budget entry method code at project type level fetch cost and revenue flags

                    IF  project_type_level_info_rec.allow_rev_budget_entry_flag  = 'Y' THEN

                            OPEN budget_entry_method_info_cur(project_type_level_info_rec.rev_budget_entry_method_code);
                            FETCH budget_entry_method_info_cur INTO budget_entry_method_info_rec;
                            CLOSE budget_entry_method_info_cur;

                            x_upgrade_elements_rec.basis_rev_bem := project_type_level_info_rec.rev_budget_entry_method_code;
                            x_upgrade_elements_rec.basis_rev_res_list_id := project_type_level_info_rec.rev_budget_resource_list_id;
                            x_upgrade_elements_rec.basis_rev_planning_level := budget_entry_method_info_rec.entry_level_code;
                            x_upgrade_elements_rec.basis_rev_time_phased_code := budget_entry_method_info_rec.time_phased_type_code;

                            --The following api either returns amount set ids based on preference code
                            --and  the flag i/p parameters combination if it already exists OR else
                            --creates a new amount set id.

                            PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID(
                                    p_raw_cost_flag             =>      budget_entry_method_info_rec.raw_cost_flag
                                    ,p_burdened_cost_flag       =>      budget_entry_method_info_rec.burdened_cost_flag
                                    ,p_revenue_flag             =>      budget_entry_method_info_rec.revenue_flag
                                    ,p_cost_qty_flag            =>      budget_entry_method_info_rec.cost_quantity_flag
                                    ,p_revenue_qty_flag         =>      budget_entry_method_info_rec.rev_quantity_flag
                                    ,p_all_qty_flag             =>      'N'
                                    ,p_plan_pref_code           =>      x_upgrade_elements_rec.curr_option_preference_code
                            /* Changes for FP.M, Tracking Bug No - 3354518, Adding three new IN parameters p_bill_rate_flag,
                               p_cost_rate_flag, p_burden_multiplier below for new columns in pa_fin_plan_amount_sets
                               defaulting these parameters as 'Y'*/
                                    ,p_bill_rate_flag           =>      'Y'
                                    ,p_cost_rate_flag           =>      'Y'
                                    ,p_burden_rate_flag         =>      'Y'
                                    ,x_cost_amount_set_id       =>      l_cost_amount_set_id
                                    ,x_revenue_amount_set_id    =>      x_upgrade_elements_rec.basis_rev_amount_set_id
                                    ,x_all_amount_set_id        =>      l_all_amount_set_id
                                    ,x_message_count            =>      l_msg_count
                                    ,x_return_status            =>      l_return_status
                                    ,x_message_data             =>      l_msg_data );

                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                    END IF;
            END IF; --g_basis_rev_version_id

     END IF; --g_curr_option_preference_code is revenue_only or cost_and_rev_sep
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Exiting Populate_Local_Variables';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    pa_debug.reset_err_stack;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         =>        FND_API.G_TRUE
                    ,p_msg_index      =>        1
                    ,p_msg_count      =>        l_msg_count
                    ,p_msg_data       =>        l_msg_data
                    ,p_data           =>        l_data
                    ,p_msg_index_out  =>        l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Populate_Local_Variables ' || x_msg_data,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN

        IF budget_version_info_cur%ISOPEN THEN
             CLOSE budget_version_info_cur;
        END IF;
        IF project_type_level_info_cur%ISOPEN THEN
             CLOSE project_type_level_info_cur;
        END IF;
        IF budget_entry_method_info_cur%ISOPEN THEN
             CLOSE budget_entry_method_info_cur;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Populate_Local_Variables');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Populate_Local_Variables ' || pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;

END Populate_Local_Variables;

/*=============================================================================
This is the main api which will do all that is necessary to upgrade all budget
versions which are eligible for upgrade as per the input parameters to the
concurrent request.
=============================================================================*/
PROCEDURE Upgrade_Budgets(
           p_from_project_number        IN           VARCHAR2
          ,p_to_project_number          IN           VARCHAR2
          ,p_budget_types               IN           VARCHAR2
          ,p_budget_statuses            IN           VARCHAR2
          ,p_project_type               IN           VARCHAR2
          ,p_project_statuses           IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status         VARCHAR2(2000);
l_msg_count             NUMBER :=0;
l_msg_data              VARCHAR2(2000);
l_data                  VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_debug_mode            VARCHAR2(30);

l_project_id            pa_projects.project_id%TYPE;
l_proj_fp_options_id    pa_proj_fp_options.proj_fp_options_id%TYPE;
l_upgrade_elements_rec  upgrade_elements_rec_type;

l_proj_validation_status    VARCHAR2(30);
l_retcode number;
l_errbuf varchar2(512);

/* Bug #2727377 */
l_fp_preference_code    pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_multi_curr_flag       pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    savepoint pa_fp_upgrade_pkg;

    pa_debug.init_err_stack('PA_FP_UPGRADE_PKG.Upgrade_Budget_Types');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Upgrade_Budget_Types';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    IF (p_budget_types        IS NULL) OR
       (p_budget_statuses     IS NULL) OR
       (p_project_statuses    IS NULL)
    THEN
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_budget_types='||p_budget_types;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.g_err_stage := 'p_budget_statuses='||p_budget_statuses;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.g_err_stage := 'p_project_statuses='||p_project_statuses;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Parameter validation complete';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

        --Upgrade all the budget types selected for upgrade

         pa_debug.g_err_stage := 'Calling Upgrade_Budget_Types';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    pa_fp_upgrade_pkg.Upgrade_Budget_Types(
                  p_budget_types        =>      p_budget_types
                  ,x_return_status      =>      l_return_status
                  ,x_msg_count          =>      l_msg_count
                  ,x_msg_data           =>      l_msg_data);
                  if (l_return_status <> 'S') then
                     raise pa_fp_constants_pkg.Invalid_Arg_Exc;
                  end if;
    --Fetch the projects chosen for upgrade
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'opening projects_for_upgrade_cur';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'p_from_project_number  = '||p_from_project_number;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'p_to_project_number = '|| p_to_project_number;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    IF ( p_from_project_number IS NOT NULL) AND ( p_to_project_number IS NOT NULL ) THEN

        OPEN projects_for_upgrade_cur1(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);

    ELSIF ( p_project_type IS NOT NULL)  THEN

        OPEN projects_for_upgrade_cur2(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);

    ELSIF (p_project_statuses <> 'ALL') THEN

        OPEN projects_for_upgrade_cur3(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);
    ELSE

        OPEN projects_for_upgrade_cur(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);

    END IF;

        LOOP

            IF ( p_from_project_number IS NOT NULL) AND ( p_to_project_number IS NOT NULL ) THEN

               FETCH projects_for_upgrade_cur1 INTO l_project_id;
               EXIT WHEN projects_for_upgrade_cur1%NOTFOUND;

            ELSIF ( p_project_type IS NOT NULL)  THEN

               FETCH projects_for_upgrade_cur2 INTO l_project_id;
               EXIT WHEN projects_for_upgrade_cur2%NOTFOUND;

            ELSIF (p_project_statuses <> 'ALL') THEN

               FETCH projects_for_upgrade_cur3 INTO l_project_id;
               EXIT WHEN projects_for_upgrade_cur3%NOTFOUND;

            ELSE
               FETCH projects_for_upgrade_cur INTO l_project_id;
               EXIT WHEN projects_for_upgrade_cur%NOTFOUND;

            END IF;

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Project_id ='||l_project_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                --Check if any types of budgets are allowed for the project using project_type_info_cur.

                pa_debug.g_err_stage := 'Opening  project_type_info_cur'||l_project_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;
           OPEN project_type_info_cur(l_project_id);
           FETCH project_type_info_cur INTO project_type_info_rec;
           CLOSE project_type_info_cur;
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Closed  project_type_info_cur';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;
           IF (( project_type_info_rec.allow_cost_budget_entry_flag ='Y' )OR
               ( project_type_info_rec.allow_rev_budget_entry_flag = 'Y' )) AND
              (NVL(project_type_info_rec.org_project_flag,'N') = 'N') -- bug:- 2788983, org_forecast project shouldn't be upgraded
           THEN
                --Check if project level fp option for the current project_id is
                --already available. Ifn't available create fp option.

                BEGIN
                   SELECT proj_fp_options_id
                   INTO   l_proj_fp_options_id
                   FROM   pa_proj_fp_options
                   WHERE  project_id = l_project_id
                   AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT;

                   -- The follwing variable indicates if there are any project level exceptions
                   -- As the project is available in new model, there would be project level no
                   -- exceptions and so setting it to 'Y'
                   l_proj_validation_status := 'Y';

                EXCEPTION
                    WHEN no_data_found THEN

                            -- Check for project level exceptions and
                            -- set l_proj_validation_status accordingly
                            pa_fp_upgrade_pkg.Validate_Project (
                                   p_project_id         =>  l_project_id
                                  ,x_validation_status  =>  l_proj_validation_status
                                  ,x_return_status      =>  l_return_status
                                  ,x_msg_count          =>  l_msg_count
                                  ,x_msg_data           =>  l_msg_data);

                            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;
                            -- create fp options and elements for project only if there are
                            -- no project level exceptions

                            IF l_proj_validation_status = 'Y' THEN

                                    l_proj_fp_options_id := NULL;
                                    IF p_pa_debug_mode = 'Y' THEN
                                         pa_debug.g_err_stage := 'Calling Create_fp_options for project';
                                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                                    END IF;
                                    pa_fp_upgrade_pkg.Create_fp_options(
                                                  p_project_id             =>   l_project_id
                                                  ,p_budget_type_code      =>   NULL
                                                  ,p_fin_plan_version_id   =>   NULL
                                                  ,p_fin_plan_option_level =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT
                                                  ,x_proj_fp_options_id    =>   l_proj_fp_options_id
                                                  ,x_upgrade_elements_rec  =>   l_upgrade_elements_rec
                                                  ,x_return_status         =>   l_return_status
                                                  ,x_msg_count             =>   l_msg_count
                                                  ,x_msg_data              =>   l_msg_data);
                                                  if (l_return_status <> 'S') then
                                                     raise pa_fp_constants_pkg.Invalid_Arg_Exc;
                                                  end if;

                                    /* 2727377: Added call to copy_fp_txn_currencies API to populate the currencies
                                       in pa_fp_txn_currencies. The source fp option ID is being passed as NULL as
                                       the source is determined in copy_fp_txn_currencies API in case the source is
                                       not passed. Plan in multi currency flag and the fp_preference_code is
                                       retrieved from pa_proj_fp_options_table. */

                                    SELECT fin_plan_preference_code, plan_in_multi_curr_flag
                                      INTO l_fp_preference_code, l_multi_curr_flag
                                      FROM pa_proj_fp_options
                                     WHERE proj_fp_options_id = l_proj_fp_options_id;

                                    IF p_pa_debug_mode = 'Y' THEN
                                         pa_debug.g_err_stage := 'Calling copy_fp_txn_currencies for project';
                                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                                    END IF;
                                    pa_fp_txn_currencies_pub.Copy_Fp_Txn_Currencies (
                                                         p_source_fp_option_id       => NULL
                                                        ,p_target_fp_option_id       => l_proj_fp_options_id
                                                        ,p_target_fp_preference_code => l_fp_preference_code
                                                        ,p_plan_in_multi_curr_flag   => l_multi_curr_flag
                                                        ,x_return_status             => l_return_status
                                                        ,x_msg_count                 => l_msg_count
                                                        ,x_msg_data                  => l_msg_data);
                                                  if (l_return_status <> 'S') then
                                                     raise pa_fp_constants_pkg.Invalid_Arg_Exc;
                                                  end if;

                                    -- Insert into audit table
                                    pa_fp_upgrade_pkg.Insert_Audit_Record(
                                                 p_project_id                     =>   l_project_id
                                                ,p_budget_type_code               =>   NULL
                                                ,p_proj_fp_options_id             =>   l_proj_fp_options_id
                                                ,p_fin_plan_option_level_code     =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT
                                                ,p_basis_cost_version_id          =>   l_upgrade_elements_rec.basis_cost_version_id
                                                ,p_basis_rev_version_id           =>   l_upgrade_elements_rec.basis_rev_version_id
                                                ,p_basis_cost_bem                 =>   l_upgrade_elements_rec.basis_cost_bem
                                                ,p_basis_rev_bem                  =>   l_upgrade_elements_rec.basis_rev_bem
                                                ,p_upgraded_flag                  =>   'Y'
                                                ,p_failure_reason_code            =>   NULL);
                            END IF;
                    WHEN OTHERS THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                            END IF;
                            RAISE;
                END;

                -- Proceed only if there are no project level exceptions

                IF l_proj_validation_status = 'Y' THEN

                     -- Add the plan types to the project which have been used for this project
                     -- and those selected for upgrade.This api validates (?) each of the budget type
                     -- for upgrade. If there are no exceptions it creates both fp options and
                     -- fp elements for all the above plan type .

                     IF p_pa_debug_mode ='Y' THEN
                          pa_debug.g_err_stage := 'Calling Add_Plan_Types';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                     pa_fp_upgrade_pkg.Add_Plan_Types(
                               p_project_id       =>       l_project_id
                               ,p_budget_types    =>       p_budget_types
                               ,x_return_status   =>       l_return_status
                               ,x_msg_count       =>       l_msg_count
                               ,x_msg_data        =>       l_msg_data);
                               if (l_return_status <> 'S') then
                                  raise pa_fp_constants_pkg.Invalid_Arg_Exc;
                               end if;

                     --Upgrade the budget versions of the project for all the budget_types eligible for upgrade
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Calling Upgrade_Budget_Versions';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;
                     pa_fp_upgrade_pkg.Upgrade_Budget_Versions(
                               p_project_id         =>       l_project_id
                               ,p_budget_types      =>       p_budget_types
                               ,p_budget_statuses   =>       p_budget_statuses
                               ,x_return_status     =>       l_return_status
                               ,x_msg_count         =>       l_msg_count
                               ,x_msg_data          =>       l_msg_data);
                               if (l_return_status <> 'S') then
                                  raise pa_fp_constants_pkg.Invalid_Arg_Exc;
                               end if;
                END IF; -- l_proj_validation_status
           END IF; -- if any types of budget are allowed for the project

           COMMIT; -- this commits data for each project processed

    END LOOP;

    IF projects_for_upgrade_cur1%ISOPEN THEN
        CLOSE projects_for_upgrade_cur1;
    ELSIF projects_for_upgrade_cur2%ISOPEN THEN
        CLOSE projects_for_upgrade_cur2;
    ELSIF projects_for_upgrade_cur3%ISOPEN THEN
        CLOSE projects_for_upgrade_cur3;
    ELSE
        CLOSE projects_for_upgrade_cur;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Closed projects_for_upgrade_cur';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.g_err_stage := 'Exiting Upgrade_Budgets';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    pa_debug.reset_err_stack;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        IF projects_for_upgrade_cur1%ISOPEN THEN
            CLOSE projects_for_upgrade_cur1;
        ELSIF projects_for_upgrade_cur2%ISOPEN THEN
            CLOSE projects_for_upgrade_cur2;
        ELSIF projects_for_upgrade_cur3%ISOPEN THEN
            CLOSE projects_for_upgrade_cur3;
        ELSIF projects_for_upgrade_cur%ISOPEN THEN
            CLOSE projects_for_upgrade_cur;
        END IF;

        IF project_type_info_cur%ISOPEN THEN
            CLOSE project_type_info_cur;
        END IF;
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
            x_msg_data := l_msg_data;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.write_file('Upgrade_Budgets : Upgrade has failed for the project: '||project_type_info_rec.segment1||'(project number)',5);
        pa_debug.write_file('Upgrade_Budgets : Failure Reason:'||x_msg_data,5);
        pa_debug.reset_err_stack;
        ROLLBACK TO pa_fp_upgrade_pkg;
        RAISE;
   WHEN Others THEN

        IF projects_for_upgrade_cur1%ISOPEN THEN
            CLOSE projects_for_upgrade_cur1;
        ELSIF projects_for_upgrade_cur2%ISOPEN THEN
            CLOSE projects_for_upgrade_cur2;
        ELSIF projects_for_upgrade_cur3%ISOPEN THEN
            CLOSE projects_for_upgrade_cur3;
        ELSIF projects_for_upgrade_cur%ISOPEN THEN
            CLOSE projects_for_upgrade_cur;
        END IF;
        IF project_type_info_cur%ISOPEN THEN
            CLOSE project_type_info_cur;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Upgrade_Budgets');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        pa_debug.write_file('Upgrade_Budgets : Upgrade has failed for the project'||project_type_info_rec.segment1||'(project number)',5);
        pa_debug.write_file('Upgrade_Budgets : Failure Reason:'||pa_debug.G_Err_Stack,5);
        pa_debug.reset_err_stack;
        ROLLBACK TO pa_fp_upgrade_pkg;
        RAISE;
END Upgrade_Budgets;

/*=============================================================================
This api will create plan types at implementation level for each budget type
selected for upgrade. IF plan type for a budget type already exists then this
api will skip such budget types. Users can submit the upgrade process either
for all budget types or only those which are selected on budget type from
=============================================================================*/
PROCEDURE Upgrade_Budget_Types(
          p_budget_types            IN        VARCHAR2
          ,x_return_status         OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT        NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT        NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status                 VARCHAR2(2000);
l_msg_count                     NUMBER :=0;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(30);
/* Bug# 2661650 - Replaced _vl by _b for performance reasons */
l_plan_class_code                pa_fin_plan_types_b.plan_class_code%TYPE;
l_approved_cost_plan_type_flag   pa_fin_plan_types_b.approved_cost_plan_type_flag%TYPE;
l_approved_rev_plan_type_flag    pa_fin_plan_types_b.approved_rev_plan_type_flag%TYPE;

l_rowid   ROWID := NULL;

CURSOR budget_types_for_upgrade_cur (
       c_budget_types  IN VARCHAR2) IS
SELECT  budget_type_code
       ,budget_type
       ,description
       ,enable_wf_flag
       ,start_date_active
       ,end_date_active
       ,predefined_flag
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   pa_budget_types  bt
WHERE  DECODE(c_budget_types, 'ALL' ,'Y', upgrade_budget_type_flag) = 'Y'
AND    not exists
         (SELECT 1
          FROM   pa_fin_plan_types_b pt /* Bug# 2661650 - Replaced _vl by _b for performance reasons */
          WHERE  pt.migrated_frm_bdgt_typ_code = bt.budget_type_code);

budget_types_for_upgrade_rec budget_types_for_upgrade_cur%ROWTYPE;

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.Upgrade_Budget_Types');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Upgrade_Budget_Types';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    IF (p_budget_types IS NULL) THEN
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_budget_types ='||p_budget_types;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'parameter validation complete';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    OPEN budget_types_for_upgrade_cur(p_budget_types);
    LOOP
         FETCH budget_types_for_upgrade_cur INTO budget_types_for_upgrade_rec;
         EXIT WHEN  budget_types_for_upgrade_cur%NOTFOUND;

         --Set  l_plan_class_code, l_approved_cost_plan_type_flag, l_approved_rev_plan_type_flag
         --using budget_type_code

         IF budget_types_for_upgrade_rec.budget_type_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_FC,
                                                                PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_FR)
         THEN
                 l_plan_class_code := PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_FORECAST;
         ELSE
                 l_plan_class_code := PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_BUDGET;
         END IF;

         IF budget_types_for_upgrade_rec.budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC THEN
                 l_approved_cost_plan_type_flag := 'Y';
         ELSE
                 l_approved_cost_plan_type_flag := 'N';
         END IF;

         IF budget_types_for_upgrade_rec.budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR THEN
                 l_approved_rev_plan_type_flag := 'Y';
         ELSE
                 l_approved_rev_plan_type_flag := 'N';
         END IF;

         PA_FIN_PLAN_TYPES_PKG.Insert_Row (
                  x_rowid                            =>         l_rowid
                 ,x_fin_plan_type_id                 =>         NULL
                 ,x_fin_plan_type_code               =>         NULL
                 ,x_pre_defined_flag                 =>         budget_types_for_upgrade_rec.predefined_flag
                 ,x_generated_flag                   =>         'N'
                 ,x_edit_generated_amt_flag          =>         'N'
                 ,x_used_in_billing_flag             =>         'N'
                 ,x_enable_wf_flag                   =>         NVL(budget_types_for_upgrade_rec.enable_wf_flag,'N')
                 ,x_start_date_active                =>         budget_types_for_upgrade_rec.start_date_active
                 ,x_end_date_active                  =>         budget_types_for_upgrade_rec.end_date_active
                 ,x_record_version_number            =>         1
                 ,x_name                             =>         budget_types_for_upgrade_rec.budget_type
                 ,x_description                      =>         budget_types_for_upgrade_rec.description
                 ,x_plan_class_code                  =>         l_plan_class_code
                 ,x_approved_cost_plan_type_flag     =>         l_approved_cost_plan_type_flag
                 ,x_approved_rev_plan_type_flag      =>         l_approved_rev_plan_type_flag
                 ,x_projfunc_cost_rate_type          =>         NULL
                 ,x_projfunc_cost_rate_date_type     =>         NULL
                 ,x_projfunc_cost_rate_date          =>         NULL
                 ,x_projfunc_rev_rate_type           =>         NULL
                 ,x_projfunc_rev_rate_date_type      =>         NULL
                 ,x_projfunc_rev_rate_date           =>         NULL
                 ,x_project_cost_rate_type           =>         NULL
                 ,x_project_cost_rate_date_type      =>         NULL
                 ,x_project_cost_rate_date           =>         NULL
                 ,x_project_rev_rate_type            =>         NULL
                 ,x_project_rev_rate_date_type       =>         NULL
                 ,x_project_rev_rate_date            =>         NULL
                 ,x_attribute_category               =>         budget_types_for_upgrade_rec.attribute_category
                 ,x_attribute1                       =>         budget_types_for_upgrade_rec.attribute1
                 ,x_attribute2                       =>         budget_types_for_upgrade_rec.attribute2
                 ,x_attribute3                       =>         budget_types_for_upgrade_rec.attribute3
                 ,x_attribute4                       =>         budget_types_for_upgrade_rec.attribute4
                 ,x_attribute5                       =>         budget_types_for_upgrade_rec.attribute5
                 ,x_attribute6                       =>         budget_types_for_upgrade_rec.attribute6
                 ,x_attribute7                       =>         budget_types_for_upgrade_rec.attribute7
                 ,x_attribute8                       =>         budget_types_for_upgrade_rec.attribute8
                 ,x_attribute9                       =>         budget_types_for_upgrade_rec.attribute9
                 ,x_attribute10                      =>         budget_types_for_upgrade_rec.attribute10
                 ,x_attribute11                      =>         budget_types_for_upgrade_rec.attribute11
                 ,x_attribute12                      =>         budget_types_for_upgrade_rec.attribute12
                 ,x_attribute13                      =>         budget_types_for_upgrade_rec.attribute13
                 ,x_attribute14                      =>         budget_types_for_upgrade_rec.attribute14
                 ,x_attribute15                      =>         budget_types_for_upgrade_rec.attribute15
                 ,x_creation_date                    =>         sysdate
                 ,x_created_by                       =>         fnd_global.user_id
                 ,x_last_update_date                 =>         sysdate
                 ,x_last_updated_by                  =>         fnd_global.user_id
                 ,x_last_update_login                =>         fnd_global.login_id
                 ,x_migrated_frm_bdgt_typ_code       =>         budget_types_for_upgrade_rec.budget_type_code
                 ,X_ENABLE_PARTIAL_IMPL_FLAG         =>         'N'
                 ,X_PRIMARY_COST_FORECAST_FLAG       =>         'N'
                 ,X_PRIMARY_REV_FORECAST_FLAG        =>         'N'
                 ,X_EDIT_AFTER_BASELINE_FLAG         =>         'Y'
                 ,X_USE_FOR_WORKPLAN_FLAG            =>         'N');

    END LOOP;
    CLOSE budget_types_for_upgrade_cur;

    IF  p_pa_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Exiting Upgrade_Budget_Types';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    pa_debug.reset_err_stack;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        IF budget_types_for_upgrade_cur%ISOPEN THEN
            CLOSE budget_types_for_upgrade_cur;
        END IF;
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
            x_msg_data := l_msg_data;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Upgrade_Budget_Types ' || x_msg_data,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN

        IF budget_types_for_upgrade_cur%ISOPEN THEN
            CLOSE budget_types_for_upgrade_cur;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Upgrade_Budget_Types');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Upgrade_Budget_Types '  || pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;

END Upgrade_Budget_Types;

/*==============================================================================
This process will create record in pa_proj_fp_options table for the project,
plan type and plan version levels. It will create fp option only at the level
for which this api is called.
Bug#2731534: The api has been modified to default MC conversion attributes from
project level(pa_projects_all) for the plan type and plan version fp options if
Project currency <> Projfunc Currency for the project.
===============================================================================*/
PROCEDURE Create_fp_options(
          p_project_id             IN   pa_proj_fp_options.project_id%TYPE
          ,p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
          ,p_fin_plan_version_id   IN   pa_proj_fp_options.fin_plan_version_id%TYPE
          ,p_fin_plan_option_level IN   pa_proj_fp_options.fin_plan_option_level_code%TYPE
          ,x_proj_fp_options_id    OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
      ,x_upgrade_elements_rec  OUT  NOCOPY  pa_fp_upgrade_pkg.upgrade_elements_rec_type
          ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status      VARCHAR2(2000);
l_msg_count          NUMBER :=0;
l_msg_data           VARCHAR2(2000);
l_data               VARCHAR2(2000);
l_msg_index_out      NUMBER;
l_debug_mode         VARCHAR2(30);

l_target_proj_fp_option_id      pa_proj_fp_options.proj_fp_options_id%TYPE;
l_approved_cost_plan_type_flag  pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;
l_approved_rev_plan_type_flag   pa_proj_fp_options.approved_rev_plan_type_flag%TYPE;

l_upgrade_elements_rec          upgrade_elements_rec_type;

l_multi_currency_billing_flag   pa_projects_all.multi_currency_billing_flag%TYPE;
l_projfunc_currency_code        pa_projects_all.projfunc_currency_code%TYPE;
l_project_currency_code         pa_projects_all.project_currency_code%TYPE;
l_project_bil_rate_type         pa_projects_all.project_bil_rate_type%TYPE;
l_projfunc_bil_rate_type        pa_projects_all.projfunc_bil_rate_type%TYPE;
l_project_cost_rate_type        pa_projects_all.project_rate_type%TYPE;
l_projfunc_cost_rate_type       pa_projects_all.projfunc_cost_rate_type%TYPE;


BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.Create_fp_options');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Entered Create_fp_options';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

           pa_debug.g_err_stage := 'Calling Populate_Local_Variables';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      pa_fp_upgrade_pkg.Populate_Local_Variables(
             p_project_id                 =>      p_project_id
            ,p_budget_type_code           =>      p_budget_type_code
            ,p_fin_plan_version_id        =>      p_fin_plan_version_id
            ,p_fin_plan_option_level      =>      p_fin_plan_option_level
            ,x_upgrade_elements_rec       =>      l_upgrade_elements_rec
            ,x_return_status              =>      l_return_status
            ,x_msg_count                  =>      l_msg_count
            ,x_msg_data                   =>      l_msg_data);
            if (l_return_status <> 'S') then
                raise pa_fp_constants_pkg.Invalid_Arg_Exc;
            end if;

      --Calling create_fp_option api to create an option
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Calling Create_FP_Option of PA_PROJ_FP_OPTIONS_PUB';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      PA_PROJ_FP_OPTIONS_PUB.Create_FP_Option (
                  px_target_proj_fp_option_id           =>      l_target_proj_fp_option_id
                  ,p_source_proj_fp_option_id           =>      NULL
                  ,p_target_fp_option_level_code        =>      l_upgrade_elements_rec.curr_option_level_code
                  ,p_target_fp_preference_code          =>      l_upgrade_elements_rec.curr_option_preference_code
                  ,p_target_fin_plan_version_id         =>      l_upgrade_elements_rec.curr_option_plan_version_id
                  ,p_target_project_id                  =>      l_upgrade_elements_rec.curr_option_project_id
                  ,p_target_plan_type_id                =>      l_upgrade_elements_rec.curr_option_plan_type_id
                  ,x_return_status                      =>      l_return_status
                  ,x_msg_count                          =>      l_msg_count
                  ,x_msg_data                           =>      l_msg_data);
            if (l_return_status <> 'S') then
                raise pa_fp_constants_pkg.Invalid_Arg_Exc;
            end if;

      --Bug 4336691. The below block which, based on the approved cost/rev budgets plan settings,
      --could possibly update the Project Option's settings to have Date Range Time Phase or Top/Lowest
      --Planning Level is not executed. Note that for Project level options, PADTRNGB.DATE_RANGE_UPGRD and
      --PABDGATB.BUDGET_ATTR_UPGRD will not be called in the flow.
      IF l_upgrade_elements_rec.curr_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT THEN

          --Update option with planning level,time phasing,resourcelist, amount set id,
          --approved_rev_plan_type_flag,approved_cost_plan_type_flag values
          --based upon the curr_option_preference_code and g_curr_option_budget_type_code

          IF  l_upgrade_elements_rec.curr_option_level_code IN(PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,
                                           PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN
                IF l_upgrade_elements_rec.curr_option_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC THEN
                           l_approved_cost_plan_type_flag :=  'Y';
                           l_approved_rev_plan_type_flag  :=  'N';
                ELSIF  l_upgrade_elements_rec.curr_option_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR THEN
                           l_approved_cost_plan_type_flag :=  'N';
                           l_approved_rev_plan_type_flag  :=  'Y';
                ELSE
                           l_approved_cost_plan_type_flag :=  'N';
                           l_approved_rev_plan_type_flag  :=  'N';
                END IF;
          ELSE
                l_approved_cost_plan_type_flag :=  'N';
                l_approved_rev_plan_type_flag  :=  'N';

          END IF;

          /* FP M related columns upgrade is done by pa_budget_attr_upgr_pkg.budget_attr_upgrd later in the api.
             pa_budget_attr_upgr_pkg.budget_attr_upgrd also takes care of upgrade FP M attribs for
             project and plan type level records */

          IF l_upgrade_elements_rec.curr_option_preference_code IN ( PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,
                                                                     PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP)
          AND  (l_upgrade_elements_rec.basis_cost_bem IS NOT NULL)
          THEN

             UPDATE PA_PROJ_FP_OPTIONS
             SET   cost_fin_plan_level_code     =   l_upgrade_elements_rec.basis_cost_planning_level
                  ,cost_time_phased_code        =   l_upgrade_elements_rec.basis_cost_time_phased_code
                  ,cost_resource_list_id        =   l_upgrade_elements_rec.basis_cost_res_list_id
                  ,cost_amount_set_id           =   l_upgrade_elements_rec.basis_cost_amount_set_id
                  ,approved_cost_plan_type_flag =   l_approved_cost_plan_type_flag
                  ,approved_rev_plan_type_flag  =   l_approved_rev_plan_type_flag
                  --Bug 4174907
                  ,primary_cost_forecast_flag   = 'N'
                  ,primary_rev_forecast_flag    = 'N'
             WHERE proj_fp_options_id = l_target_proj_fp_option_id;

          END IF;

          IF l_upgrade_elements_rec.curr_option_preference_code IN ( PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,
                                                                     PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP)
          AND  (l_upgrade_elements_rec.basis_rev_bem IS NOT NULL)
          THEN

             UPDATE PA_PROJ_FP_OPTIONS
             SET   revenue_fin_plan_level_code  =   l_upgrade_elements_rec.basis_rev_planning_level
                  ,revenue_time_phased_code     =   l_upgrade_elements_rec.basis_rev_time_phased_code
                  ,revenue_resource_list_id     =   l_upgrade_elements_rec.basis_rev_res_list_id
                  ,revenue_amount_set_id        =   l_upgrade_elements_rec.basis_rev_amount_Set_id
                  ,approved_cost_plan_type_flag =   l_approved_cost_plan_type_flag
                  ,approved_rev_plan_type_flag  =   l_approved_rev_plan_type_flag
                  --Bug 4174907
                  ,primary_cost_forecast_flag   = 'N'
                  ,primary_rev_forecast_flag    = 'N'
             WHERE proj_fp_options_id = l_target_proj_fp_option_id;

          END IF;

      END IF;--Bug 4336691.

      IF  l_upgrade_elements_rec.curr_option_level_code IN(PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE,
                                       PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION) THEN

           -- Get project currency info and the cost,revenue conversion attributes

           PA_FIN_PLAN_UTILS.Get_Project_Curr_Attributes
                  (  p_project_id                      =>  p_project_id
                    ,x_multi_currency_billing_flag     =>  l_multi_currency_billing_flag
                    ,x_project_currency_code           =>  l_project_currency_code
                    ,x_projfunc_currency_code          =>  l_projfunc_currency_code
                    ,x_project_cost_rate_type          =>  l_project_cost_rate_type
                    ,x_projfunc_cost_rate_type         =>  l_projfunc_cost_rate_type
                    ,x_project_bil_rate_type           =>  l_project_bil_rate_type
                    ,x_projfunc_bil_rate_type          =>  l_projfunc_bil_rate_type
                    ,x_return_status                   =>  l_return_status
                    ,x_msg_count                       =>  l_msg_count
                    ,x_msg_data                        =>  l_msg_data   );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

           -- Populate the MC conversion attributes for the fp option if MC enabled

           IF  l_project_currency_code <> l_projfunc_currency_code THEN

                UPDATE PA_PROJ_FP_OPTIONS
                SET   projfunc_cost_rate_type      =  l_projfunc_cost_rate_type
                     ,projfunc_cost_rate_date_type =  PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE
                     ,projfunc_rev_rate_type       =  l_projfunc_bil_rate_type
                     ,projfunc_rev_rate_date_type  =  PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE
                     ,project_cost_rate_type       =  l_project_cost_rate_type
                     ,project_cost_rate_date_type  =  PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE
                     ,project_rev_rate_type        =  l_project_bil_rate_type
                     ,project_rev_rate_date_type   =  PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE
                WHERE proj_fp_options_id = l_target_proj_fp_option_id;

           END IF;

      END IF;
      x_proj_fp_options_id := l_target_proj_fp_option_id;
      x_upgrade_elements_rec := l_upgrade_elements_rec;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Exiting Create_fp_options';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;
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
            x_msg_data := l_msg_data;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Create_fp_options ' || x_msg_data,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Create_fp_options');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Create_fp_options ' || pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;
END Create_fp_options;

/*=============================================================================
This process will identify the budget types for which budget versions exist for
the project and add those plan types to the project.
=============================================================================*/
Procedure Add_Plan_Types(
          p_project_id       IN    pa_projects.project_id%TYPE
          ,p_budget_types    IN    VARCHAR2
          ,x_return_status   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data        OUT   NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status          VARCHAR2(2000);
l_msg_count              NUMBER :=0;
l_msg_data               VARCHAR2(2000);
l_data                   VARCHAR2(2000);
l_msg_index_out          NUMBER;
l_debug_mode             VARCHAR2(30);

l_proj_fp_options_id     pa_proj_fp_options.proj_fp_options_id%TYPE;

l_upgrade_elements_rec   upgrade_elements_rec_type;

l_validation_status      VARCHAR2(30);

/* Bug #2727377 */
l_fp_preference_code     pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_multi_curr_flag        pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.Add_Plan_Types');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Entered Add_Plan_Types';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

           -- Check for not null parameters

           pa_debug.g_err_stage := 'Checking for valid parameters:';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      IF (p_project_id  IS NULL)  OR (p_budget_types IS NULL)
      THEN
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'p_project_id = '||p_project_id;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       pa_debug.g_err_stage := 'p_budget_types = '||p_budget_types;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                       p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Parameter validation complete';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      -- Fetch each budget type used for the project

      OPEN attached_plan_types_cur(p_project_id,p_budget_types);
      LOOP
            FETCH attached_plan_types_cur INTO attached_plan_types_rec;
            EXIT WHEN attached_plan_types_cur%NOTFOUND;

            -- For each budget type fetched check if any plan type level exceptions exist
            pa_fp_upgrade_pkg.Validate_Project_Plan_Type (
                           p_project_id              =>      p_project_id
                          ,p_budget_type_code        =>      attached_plan_types_rec.budget_type_code
                          ,x_validation_status       =>      l_validation_status
                          ,x_return_status           =>      l_return_status
                          ,x_msg_count               =>      l_msg_count
                          ,x_msg_data                =>      l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;

            IF l_validation_status = 'Y' THEN

                    -- For each budget type fetched create fp options

                    l_proj_fp_options_id := NULL;

                    IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Calling Create_fp_options for plan type';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;
                    pa_fp_upgrade_pkg.Create_fp_options(
                                  p_project_id                  =>      p_project_id
                                  ,p_budget_type_code           =>      attached_plan_types_rec.budget_type_code
                                  ,p_fin_plan_version_id        =>      NULL
                                  ,p_fin_plan_option_level      =>      PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
                                  ,x_proj_fp_options_id         =>      l_proj_fp_options_id
                                  ,x_upgrade_elements_rec       =>      l_upgrade_elements_rec
                                  ,x_return_status              =>      l_return_status
                                  ,x_msg_count                  =>      l_msg_count
                                  ,x_msg_data                   =>      l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                    /* 2727377: Added call to copy_fp_txn_currencies API to populate the currencies
                       in pa_fp_txn_currencies. The source fp option ID is being passed as NULL as
                       the source is determined in copy_fp_txn_currencies API in case the source is
                       not passed. Plan in multi currency flag and the fp_preference_code is
                       retrieved from pa_proj_fp_options_table. */

                    SELECT fin_plan_preference_code, plan_in_multi_curr_flag
                      INTO l_fp_preference_code, l_multi_curr_flag
                      FROM pa_proj_fp_options
                     WHERE proj_fp_options_id = l_proj_fp_options_id;

                    IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Calling copy_fp_txn_currencies for plan type';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;
                    pa_fp_txn_currencies_pub.Copy_Fp_Txn_Currencies (
                                         p_source_fp_option_id       => NULL
                                        ,p_target_fp_option_id       => l_proj_fp_options_id
                                        ,p_target_fp_preference_code => l_fp_preference_code
                                        ,p_plan_in_multi_curr_flag   => l_multi_curr_flag
                                        ,x_return_status             => l_return_status
                                        ,x_msg_count                 => l_msg_count
                                        ,x_msg_data                  => l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                    -- Insert into audit table
                    pa_fp_upgrade_pkg.Insert_Audit_Record(
                                   p_project_id                     =>   p_project_id
                                  ,p_budget_type_code               =>   attached_plan_types_rec.budget_type_code
                                  ,p_proj_fp_options_id             =>   l_proj_fp_options_id
                                  ,p_fin_plan_option_level_code     =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
                                  ,p_basis_cost_version_id          =>   l_upgrade_elements_rec.basis_cost_version_id
                                  ,p_basis_rev_version_id           =>   l_upgrade_elements_rec.basis_rev_version_id
                                  ,p_basis_cost_bem                 =>   l_upgrade_elements_rec.basis_cost_bem
                                  ,p_basis_rev_bem                  =>   l_upgrade_elements_rec.basis_rev_bem
                                  ,p_upgraded_flag                  =>   'Y'
                                  ,p_failure_reason_code            =>   NULL);

            END IF;
      END LOOP;
      CLOSE attached_plan_types_cur;
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Exiting Add_Plan_Types';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        IF attached_plan_types_cur%ISOPEN THEN
             CLOSE attached_plan_types_cur;
        END IF;
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
            x_msg_data := l_msg_data;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Add_Plan_Types ' || x_msg_data,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN

        IF attached_plan_types_cur%ISOPEN THEN
             CLOSE attached_plan_types_cur;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Add_Plan_Types');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Add_Plan_Types ' || pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;

END Add_Plan_Types;
/*=============================================================================
This api will upgrade all the budget versions eligible for upgrade based upon the
 input.This api will do the following:-
         1.Create record in PA_PROJ_FP_OPTIONS for the budget version.
         2.Create fp elements
         3.Update Budget Version in PA_BUDGET_VERSIONS
         4.Create resource assignments
         5.Roll up resource assignments
         6.Create period denorm records for the budget.


-- 07-JUN-04 jwhite   Bug 3673111
--                    When I closely reviewed this package for
--                    FP.M resource list and RBS modifications,
--                    I found so many issues that I decided to do
--                    following:
--                    1) Move most of the calls to this
--                       private Upgrade_Budget_Versions api.
--                    2) Change the FP.M Uprade api calls to process one
--                       budget_version_id at a time per the budget_version
--                       cursor in this procedure.
-- 12-Dec-06 nkumbi  Bug 5676682 :Same local variables cannot be passed as both
--                   IN and OUT variables to an api. Fixed the issue
--                   in upgrade_budget_versions api while calling
--                   apply_calculate_fpm_rules.
=============================================================================*/
PROCEDURE Upgrade_Budget_Versions (
           p_project_id            IN    pa_projects.project_id%TYPE
          ,p_budget_types          IN    VARCHAR2
          ,p_budget_statuses       IN    VARCHAR2
          ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT   NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status                 VARCHAR2(2000);
l_msg_count                     NUMBER :=0;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(30);

l_budget_version_id             pa_budget_versions.budget_version_id%TYPE;
l_version_type                  pa_budget_versions.version_type%TYPE;
l_approved_cost_plan_type_flag  pa_budget_versions.approved_cost_plan_type_flag%TYPE;
l_approved_rev_plan_type_flag   pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_prev_budget_type_code         pa_budget_versions.budget_type_code%TYPE;

l_proj_fp_options_id            pa_proj_fp_options.proj_fp_options_id%TYPE;

l_upgrade_elements_rec          upgrade_elements_rec_type;

/* Bug #2727377 */
l_fp_preference_code            pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_multi_curr_flag               pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

-- Bug 3673111, 07-JUN-04, jwhite -----------------------------------------------


   l_migration_code varchar2(1) := null;
   l_budget_ver_tbl SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();

-- End Bug 3673111 --------------------------------------------------------------
-- Added for Bug# 7187487
l_budget_status_code_tbl SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();


--Bug 4300363
l_upg_bl_id_tbl                 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_ra_id_tbl                 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_quantity_tbl              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_quantity_tbl_in           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_raw_cost_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_raw_cost_tbl_in       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_burdened_cost_tbl     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_burdened_cost_tbl_in  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_revenue_tbl           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_txn_revenue_tbl_in        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type(); --Bug 5676682
l_upg_rate_based_flag_tbl       SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_upg_raw_cost_rate_tbl         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_burd_cost_rate_tbl        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_bill_rate_tbl             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_upg_non_rb_ra_id_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_pref_code                     pa_proj_fp_options.fin_plan_preference_code%TYPE;

  -- bug 4865563: added the followings
   l_fp_cols_rec_var               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

BEGIN
      x_msg_count := 0;
      x_msg_data  := NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.Upgrade_Budget_Versions');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Entered Upgrade_Budget_Versions';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

           -- Check for not null parameters

           pa_debug.g_err_stage := 'Checking for valid parameters:';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_project_id       IS NULL)  OR
         (p_budget_types     IS NULL)  OR
         (p_budget_statuses  IS NULL)
      THEN
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_project_id = '||p_project_id;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.g_err_stage := 'p_budget_types = '||p_budget_types;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.g_err_stage := 'p_budget_statuses= '||p_budget_statuses;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Parameter validation complete';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

      END IF;

      --Fetch the budget versions that are eligible for upgrade
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Opening budgets_for_upgrade_cur ';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;


      -- This Processes ONE Qualifying Budget_Version_Id At a Time --------------------------

      OPEN budgets_for_upgrade_cur(p_project_id,p_budget_types,p_budget_statuses,'UPGRADE');
      LOOP
           --Bug 4171254. Corrected the order of the pl/sql tbls to match the order of the columns selected
           FETCH budgets_for_upgrade_cur BULK COLLECT INTO l_budget_ver_tbl,l_bud_typ_code_tbl,l_res_list_tbl,l_budget_status_code_tbl -- Added l_budget_status_code_tbl for Bug# 7187487

           LIMIT 200;

           --Bug 4171254.
           IF l_budget_ver_tbl.COUNT>0 THEN

               FOR j in l_budget_ver_tbl.first .. l_budget_ver_tbl.last loop

                    l_proj_fp_options_id := NULL;

                    --Create fp option for the budget version
                    IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Calling Create_fp_options for '|| l_budget_ver_tbl(j);
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;

                    pa_fp_upgrade_pkg.Create_fp_options(
                                   p_project_id                  =>      p_project_id
                                   ,p_budget_type_code           =>      l_bud_typ_code_tbl(j)
                                   ,p_fin_plan_version_id        =>      l_budget_ver_tbl(j)
                                   ,p_fin_plan_option_level      =>      pa_fp_constants_pkg.g_option_level_plan_version
                                   ,x_proj_fp_options_id         =>      l_proj_fp_options_id
                                   ,x_upgrade_elements_rec       =>      l_upgrade_elements_rec
                                   ,x_return_status              =>      l_return_status
                                   ,x_msg_count                  =>      l_msg_count
                                   ,x_msg_data                   =>      l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                    /* 2727377: Added call to copy_fp_txn_currencies API to populate the currencies
                       in pa_fp_txn_currencies. The source fp option ID is being passed as NULL as
                       the source is determined in copy_fp_txn_currencies API in case the source is
                       not passed. Plan in multi currency flag and the fp_preference_code is
                       retrieved from pa_proj_fp_options_table. */

                    SELECT fin_plan_preference_code, plan_in_multi_curr_flag
                      INTO l_fp_preference_code, l_multi_curr_flag
                      FROM pa_proj_fp_options
                     WHERE proj_fp_options_id = l_proj_fp_options_id;

                    IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Calling copy_fp_txn_currencies for version';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                    END IF;
                    pa_fp_txn_currencies_pub.Copy_Fp_Txn_Currencies (
                                         p_source_fp_option_id       => NULL
                                        ,p_target_fp_option_id       => l_proj_fp_options_id
                                        ,p_target_fp_preference_code => l_fp_preference_code
                                        ,p_plan_in_multi_curr_flag   => l_multi_curr_flag
                                        ,x_return_status             => l_return_status
                                        ,x_msg_count                 => l_msg_count
                                        ,x_msg_data                  => l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                    --Setting the variables for upgrading budget version to fin_plan version

                    --Set l_period_profile_id,l_version_type

                    IF l_upgrade_elements_rec.curr_option_preference_code = pa_fp_constants_pkg.G_PREF_COST_ONLY THEN

                            l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST;

                    ELSIF l_upgrade_elements_rec.curr_option_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

                            l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE;

                    END IF;

                    --Set l_approved_cost_plan_type_flag,l_approved_rev_plan_type_flag variables
                    --using g_curr_option_budget_type_code

                     IF l_upgrade_elements_rec.curr_option_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC THEN
                                l_approved_cost_plan_type_flag :=  'Y';
                                l_approved_rev_plan_type_flag  :=  'N';
                     ELSIF  l_upgrade_elements_rec.curr_option_budget_type_code = PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR THEN
                                l_approved_cost_plan_type_flag :=  'N';
                                l_approved_rev_plan_type_flag  :=  'Y';
                     ELSE
                                l_approved_cost_plan_type_flag :=  'N';
                                l_approved_rev_plan_type_flag  :=  'N';
                     END IF;

                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Updating budget version '||l_budget_ver_tbl(j);
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                    /* FP M related columns upgrade is done by pa_budget_attr_upgr_pkg.budget_attr_upgrd later in the api. */

                    UPDATE PA_BUDGET_VERSIONS
                    SET   budget_type_code               =       NULL,
                          version_name                   =       nvl(version_name,to_char(version_number)),-- Added for Bug 6722317
                          fin_plan_type_id               =       l_upgrade_elements_rec.curr_option_plan_type_id,
                          version_type                   =       l_version_type,
                          approved_cost_plan_type_flag   =       l_approved_cost_plan_type_flag,
                          approved_rev_plan_type_flag    =       l_approved_rev_plan_type_flag,
                          record_version_number          =       NVl(record_version_number,0) + 1, -- null handling ,bug 2788983
                          first_budget_period            =       NULL,
                          request_id                     =       FND_GLOBAL.conc_request_id,
                          last_update_date               =       sysdate,
                          last_updated_by                =       fnd_global.user_id,
                          creation_date                  =       sysdate,
                          created_by                     =       fnd_global.user_id,
                          last_update_login              =       fnd_global.login_id,
                          current_working_flag           =       DECODE(budget_status_code,
                                                                        PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,'Y',NULL)
                          --Bug 4174907
                          ,primary_cost_forecast_flag    = 'N'
                          ,primary_rev_forecast_flag     = 'N'
                     WHERE budget_version_id = l_budget_ver_tbl(j);

                     --update the resource assignments table
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Updating resource assignments '||l_budget_ver_tbl(j);
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                     UPDATE PA_RESOURCE_ASSIGNMENTS
                     SET    resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED
                     WHERE  budget_version_id = l_budget_ver_tbl(j);

                     --Populate txn currency buckets from the project functional currency buckets of budget lines
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Updating budget lines for  '|| l_budget_ver_tbl(j);
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                     UPDATE PA_BUDGET_LINES
                     SET    txn_raw_cost            =    raw_cost,
                            txn_burdened_cost       =    burdened_cost,
                            txn_revenue             =    revenue
                     WHERE  budget_version_id = l_budget_ver_tbl(j);

                     --Call convert_txn_currencies api to populate the project and project functional amounts
                     --from txn_currency amounts.

                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Calling convert_txn_currency ';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                     PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency (
                                       p_budget_version_id   =>      l_budget_ver_tbl(j)
                                       ,p_entire_version     =>      'Y'
                                       ,x_return_status      =>      l_return_status
                                       ,x_msg_count          =>      l_msg_count
                                       ,x_msg_data           =>      l_msg_data );

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN /* Bug# 2644641 */
                           /*For bug 2755740*/
                           IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.write_file('Upgrade failed due to error in PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency',5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                     END IF;

                     -- Convert the Resource List to a Planning Resource List, if Not Already Done So.

                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Is Version Resource List Already a Planning Resource List? ';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

                     l_migration_code := null;
                     SELECT migration_code
                     INTO   l_migration_code
                     FROM   pa_resource_lists_all_bg
                     WHERE  resource_list_id = l_res_list_tbl(j);

                     IF  (l_migration_code is null )
                       then

                       IF p_pa_debug_mode ='Y' THEN
                          pa_debug.g_err_stage := 'Calling Resource List Upgrade to Planning Resource List';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;



                       -- Bug 3802762, 30-JUN-2004, jwhite ------------------------------------
                       -- Added the following IN-parmeters as FND_API.G_FALSE
                       -- 1) p_commit
                       -- 2) p_init_msg_list


                       PA_RES_LIST_UPGRADE_PKG.RES_LIST_TO_PLAN_RES_LIST(
                                      p_resource_list_id          => l_res_list_tbl(j)
                                      , p_commit                  => FND_API.G_FALSE
                                      , p_init_msg_list           => FND_API.G_FALSE
                                      , x_return_status           => l_return_status
                                      , x_msg_count               => l_msg_count
                                      , x_msg_data                => l_msg_data);



                        -- End Bug 3802762, 30-JUN-2004, jwhite ------------------------------------

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                           IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.write_file('Upgrade failed due to error in PA_RES_LIST_UPGRADE_PKG.RES_LIST_TO_PLAN_RES_LIST ',5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;


                     END IF; -- l_migration_code is null


               END LOOP;

               -- Perform Budget Version Data Entity Migration to FP.M Data Model

               IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling Budget Attribute Upgrade';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               END IF;

               FOR k in l_budget_ver_tbl.first .. l_budget_ver_tbl.last LOOP

                     pa_budget_attr_upgr_pkg.budget_attr_upgrd(
                                        p_project_id         =>       p_project_id
                                        ,p_budget_version_id =>       l_budget_ver_tbl(k)
                                        ,x_return_status     =>       l_return_status
                                        ,x_msg_count         =>       l_msg_count
                                        ,x_msg_data          =>       l_msg_data);

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                           IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.write_file('Upgrade failed due to error in pa_budget_attr_upgr_pkg.budget_attr_upgrd ',5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                     END IF;

               END LOOP;

               IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling Rate Attributes Upgrade';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               END IF;

               pa_rate_attr_pkg.rate_attr_upgrd(
                                   p_budget_ver_tbl    =>       l_budget_ver_tbl
                                  ,x_return_status     =>       l_return_status
                                  ,x_msg_count         =>       l_msg_count
                                  ,x_msg_data          =>       l_msg_data);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                     IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.write_file('Upgrade failed due to error in pa_rate_attr_pkg.rate_attr_upgrd ',5);
                     END IF;
                     raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
               END IF;


               IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling Date Range Upgrade Attributes';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               END IF;
               pa_date_range_pkg.date_range_upgrd(
                                   p_budget_versions   =>       l_budget_ver_tbl
                                  ,x_return_status     =>       l_return_status
                                  ,x_msg_count         =>       l_msg_count
                                  ,x_msg_data          =>       l_msg_data);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                     IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.write_file('Upgrade failed due to error in pa_date_range_pkg.date_range_upgrd ',5);
                     END IF;
                     raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
               END IF;

               IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling rollup_budget_version ';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               END IF;

               FOR m in l_budget_ver_tbl.first .. l_budget_ver_tbl.last LOOP


                     --Bug 4300363. Budget lines should not exist with NULL amounts. Below code does
                     --the required processing for correcting such budget lines

                     DELETE
                     FROM   PA_BUDGET_LINES BL
                     WHERE  bl.budget_version_id = l_budget_ver_tbl(m)
                     AND    NVL(bl.quantity,0) = 0
                     AND    NVL(bl.txn_raw_cost,0) = 0
                     AND    NVL(bl.txn_burdened_cost,0) = 0
                     AND    NVL(bl.txn_revenue,0) = 0 ;

                     SELECT  bl.budget_line_id
                            ,bl.resource_assignment_id
                            ,nvl(bl.quantity,0)
                            ,nvl(bl.txn_raw_cost,0)
                            ,nvl(bl.txn_burdened_cost,0)
                            ,nvl(bl.txn_revenue,0)
                            ,nvl(ra.rate_based_flag,'N') rate_based_flag
                     BULK COLLECT INTO
                             l_upg_bl_id_tbl
                            ,l_upg_ra_id_tbl
                            ,l_upg_quantity_tbl
                            ,l_upg_txn_raw_cost_tbl
                            ,l_upg_txn_burdened_cost_tbl
                            ,l_upg_txn_revenue_tbl
                            ,l_upg_rate_based_flag_tbl
                     FROM    pa_budget_lines bl
                            ,pa_resource_assignments ra
                     WHERE  bl.resource_assignment_id=ra.resource_assignment_id
                     AND    bl.budget_version_id=l_budget_ver_tbl(m)
                     ORDER  BY bl.resource_assignment_id ,bl.quantity NULLS FIRST;

                     IF l_upg_bl_id_tbl.COUNT>0 THEN

                         SELECT fin_plan_preference_code
                         INTO   l_pref_code
                         FROM   pa_proj_fp_options
                         WHERE  fin_plan_version_id=l_budget_ver_tbl(m);


                         --Call the API to correct the budget line amounts/rates
						 l_upg_quantity_tbl_in := l_upg_quantity_tbl;
						 l_upg_txn_raw_cost_tbl_in := l_upg_txn_raw_cost_tbl;
						 l_upg_txn_burdened_cost_tbl_in := l_upg_txn_burdened_cost_tbl;
                         l_upg_txn_revenue_tbl_in       := l_upg_txn_revenue_tbl; --Bug 5676682
                        pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules(
                         p_preference_code                => l_pref_code
                        ,p_resource_assignment_id_tbl     => l_upg_ra_id_tbl
                        ,p_rate_based_flag_tbl            => l_upg_rate_based_flag_tbl
                        ,p_quantity_tbl                   => l_upg_quantity_tbl_in
                        ,p_txn_raw_cost_tbl               => l_upg_txn_raw_cost_tbl_in
                        ,p_txn_burdened_cost_tbl          => l_upg_txn_burdened_cost_tbl_in
                        ,p_txn_revenue_tbl                => l_upg_txn_revenue_tbl_in      --Bug 5676682
                        ,p_calling_module                 => 'UPGRADE'              -- bug 5007734
                        ,x_quantity_tbl                   => l_upg_quantity_tbl
                        ,x_txn_raw_cost_tbl               => l_upg_txn_raw_cost_tbl
                        ,x_txn_burdened_cost_tbl          => l_upg_txn_burdened_cost_tbl
                        ,x_txn_revenue_tbl                => l_upg_txn_revenue_tbl
                        ,x_raw_cost_override_rate_tbl     => l_upg_raw_cost_rate_tbl
                        ,x_burd_cost_override_rate_tbl    => l_upg_burd_cost_rate_tbl
                        ,x_bill_override_rate_tbl         => l_upg_bill_rate_tbl
                        ,x_non_rb_ra_id_tbl               => l_upg_non_rb_ra_id_tbl
                        ,x_return_status                  => l_return_status
                        ,x_msg_count                      => l_msg_count
                        ,x_msg_data                       => l_msg_data );


                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                          THEN
                             IF p_pa_debug_mode = 'Y' THEN
                                 pa_debug.write_file('Upgrade failed due to error in pa_fp_upgrade_pkg.Apply_Calculate_FPM_Rules ',5);
                             END IF;
                             raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                        END IF;

                        FORALL j IN 1..l_upg_non_rb_ra_id_tbl.COUNT

                            UPDATE PA_RESOURCE_ASSIGNMENTS ra
                            SET    ra.rate_based_flag = 'N'
                                  ,ra.unit_of_measure = 'DOLLARS'
                            WHERE  ra.resource_assignment_id = l_upg_non_rb_ra_id_tbl(j);

                        FORALL j IN l_upg_bl_id_tbl.first .. l_upg_bl_id_tbl.last

                            UPDATE PA_BUDGET_LINES bl
                            SET    bl.quantity                  = l_upg_quantity_tbl(j)
                                  ,bl.txn_raw_cost              = l_upg_txn_raw_cost_tbl(j)
                                  ,bl.txn_cost_rate_override    = l_upg_raw_cost_rate_tbl(j)
                                  ,bl.txn_standard_cost_rate    = l_upg_raw_cost_rate_tbl(j)
                                  ,bl.txn_burdened_cost         = l_upg_txn_burdened_cost_tbl(j)
                                  ,bl.burden_cost_rate_override = l_upg_burd_cost_rate_tbl(j)
                                  ,bl.burden_cost_rate          = l_upg_burd_cost_rate_tbl(j)
                                  ,bl.txn_revenue               = l_upg_txn_revenue_tbl(j)
                                  ,bl.txn_bill_rate_override    = l_upg_bill_rate_tbl(j)
                                  ,bl.txn_standard_bill_rate    = l_upg_bill_rate_tbl(j)
                            WHERE  bl.budget_line_id = l_upg_bl_id_tbl(j);

                    END IF;
                    --Call MC API
                    PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency
                        ( p_budget_version_id  => l_budget_ver_tbl(m)
                         ,p_entire_version     => 'Y'
                         ,x_return_status      =>l_return_status
                         ,x_msg_count          =>l_msg_count
                         ,x_msg_data           =>l_msg_data) ;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                      THEN
                         IF p_pa_debug_mode = 'Y' THEN
                             pa_debug.write_file('Upgrade failed due to error in PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency ',5);
                         END IF;
                         raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                    END IF;
                    -- Bug Fix: 4569365. Removed MRC code.
                    /*
                    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                          PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                   (x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data);
                    END IF;

                    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                     PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

                         PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                              (p_fin_plan_version_id => l_budget_ver_tbl(m),
                               p_entire_version      => 'Y',
                               x_return_status       => l_return_status,
                               x_msg_count           => l_msg_count,
                               x_msg_data            => l_msg_data);

                    END IF;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                      THEN
                         IF p_pa_debug_mode = 'Y' THEN
                             pa_debug.write_file('Upgrade failed due to error in PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES ',5);
                         END IF;
                         raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                    END IF;
                    */
                    /* bug 4865563: IPM Changes. Calling APIs which take care of
                        *  i. update the display_quantity new column in pa_budget_lines
                        * ii. insert planning transaction records in the new entity pa_resource_asgn_curr
                        *     with the appropriate records.
                        */
                       PA_BUDGET_LINES_UTILS.populate_display_qty
                           (p_budget_version_id     => l_budget_ver_tbl(m),
                            p_context               => 'FINANCIAL',
                            x_return_status         => l_return_status);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in PA_BUDGET_LINES_UTILS.populate_display_quantity',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;

                       /* populating fp_cols_rec to call the new entity maintenace API */
                       PA_FP_GEN_AMOUNT_UTILS.get_plan_version_dtls
                           (p_budget_version_id              => l_budget_ver_tbl(m),
                            x_fp_cols_rec                    => l_fp_cols_rec_var,
                            x_return_status                  => l_return_status,
                            x_msg_count                      => l_msg_count,
                            x_msg_data                       => l_msg_data);

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in PA_FP_GEN_AMOUNT_UTILS.get_plan_version_dtls',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;

                       /* calling the maintenance api to insert data into the new planning transaction level table */
                       PA_RES_ASG_CURRENCY_PUB.maintain_data
                           (p_fp_cols_rec          => l_fp_cols_rec_var,
                            p_calling_module       => 'UPGRADE',
                            p_rollup_flag          => 'Y',
                            p_version_level_flag   => 'Y',
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in PA_RES_ASG_CURRENCY_PUB.maintain_data',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;

                       /* If there is no budget lines for some resource assignments of the current budget versions
                        * then, the maintenance api would not create data in the new entity. In that scenario, we have
                        * to insert those resource assignment with default applicable currency
                        */
                       PA_FIN_PLAN_PUB.create_default_plan_txn_rec
                           (p_budget_version_id => l_budget_ver_tbl(m),
                            p_calling_module    => 'UPGRADE',
                            x_return_status     => l_return_status,
                            x_msg_count         => l_msg_count,
                            x_msg_data          => l_msg_data);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in    PA_FIN_PLAN_PUB.create_default_plan_txn_rec',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;
                       /* bug 4865563: ends */

                     PA_FP_ROLLUP_PKG.rollup_budget_version (
                                p_budget_version_id   =>     l_budget_ver_tbl(m)
                                ,p_entire_version     =>     'Y'
                                ,x_return_status      =>     l_return_status
                                ,x_msg_count          =>     l_msg_count
                                ,x_msg_data           =>     l_msg_data );

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                       THEN
                           IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.write_file('Upgrade failed due to error in PA_FP_ROLLUP_PKG.rollup_budget_version',5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                     END IF;

               END LOOP;

               --Below code is added for bug 7187487
	       --This is to create performance reporting data for the bv's.
               DECLARE
		 l_budget_ver_tbl2 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
		 l_budget_ver_tbl3 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
               	 i number;
               	 j number;
               	 k number;
	       BEGIN
		 j:=1;
	  	 k:=1;
               	 for i in l_budget_ver_tbl.first..l_budget_ver_tbl.last loop
                   if l_budget_status_code_tbl(i) = 'B' then
               	     l_budget_ver_tbl2.extend(1);
               	     l_budget_ver_tbl2(j) := l_budget_ver_tbl(i);
              	     j := j + 1;
               	   else
               	     l_budget_ver_tbl3.extend(1);
               	     l_budget_ver_tbl3(k) := l_budget_ver_tbl(i);
             	     k := k + 1;
               	   end if;
               	 end loop;
                 -- End of Bug# 7187487


                 IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Calling PJI Plan (Version) Create ';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;

                 PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
                      p_fp_version_ids   => l_budget_ver_tbl3, -- Modified to l_budget_ver_tbl3 for Bug# 7187487
                      x_return_status    => l_return_status,
                      x_msg_code         => l_msg_data);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF p_pa_debug_mode = 'Y' THEN
                      pa_debug.write_file('Upgrade failed due to error in PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE',5);
                   END IF;
                   raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                 END IF;

                  IF(l_budget_ver_tbl2.COUNT >0) THEN  --Bug 8233686
                 -- Added below for Bug# 7187487
	         for i in l_budget_ver_tbl2.first..l_budget_ver_tbl2.last loop
		   IF p_pa_debug_mode = 'Y' THEN
		      pa_debug.g_err_stage := 'Calling PJI Plan (Version) Baseline ';
		      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
		   END IF;

	           PJI_FM_XBS_ACCUM_MAINT.PLAN_BASELINE   (
	           	p_baseline_version_id => l_budget_ver_tbl2(i),
	              	p_new_version_id      => l_budget_ver_tbl2(i),
	              	x_return_status       => l_return_status,
	              	x_msg_code            => l_msg_data);

		   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		     IF p_pa_debug_mode = 'Y' THEN
		        pa_debug.write_file('Upgrade failed due to error in PJI_FM_XBS_ACCUM_MAINT.PLAN_baseline',5);
		     END IF;
		     raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
		   END IF;
	         end loop;
               	END IF; --Bug 8233686
               END; -- end of creation of proj perf data bug 7187487


           END IF;--IF l_budget_ver_tbl.COUNT>0 THEN

           --Bug 4171254. Corrected the criteria for exiting the loop. The loop should be exited whenever
           --l_budget_ver_tbl contains records less than the limit size.
           EXIT WHEN l_budget_ver_tbl.count < 200;

      END LOOP;
      CLOSE budgets_for_upgrade_cur;


      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Closed budgets_for_upgrade_cur ';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

           pa_debug.g_err_stage := 'Exiting Upgrade_Budget_Versions';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        IF budgets_for_upgrade_cur%ISOPEN THEN
            CLOSE budgets_for_upgrade_cur;
        END IF;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   ( p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Upgrade_Budget_Versions ' || x_msg_data,5);
        END IF;

        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN

        IF budgets_for_upgrade_cur%ISOPEN THEN
            CLOSE budgets_for_upgrade_cur;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_FP_UPGRADE_PKG'
                         ,p_procedure_name  => 'Upgrade_Budget_Versions');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.write_file('Upgrade_Budget_Versions '  || pa_debug.G_Err_Stack,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;

END Upgrade_Budget_Versions;

/*===============================================================================
  The follwing api is a table handler for the pa_fp_upgrade_audit table.
===============================================================================*/
PROCEDURE Insert_Audit_Record(
         p_project_id                      IN        PA_FP_UPGRADE_AUDIT.PROJECT_ID%TYPE
        ,p_budget_type_code                IN        PA_FP_UPGRADE_AUDIT.BUDGET_TYPE_CODE%TYPE
        ,p_proj_fp_options_id              IN        PA_FP_UPGRADE_AUDIT.PROJ_FP_OPTIONS_ID%TYPE
        ,p_fin_plan_option_level_code      IN        PA_FP_UPGRADE_AUDIT.FIN_PLAN_OPTION_LEVEL_CODE%TYPE
        ,p_basis_cost_version_id           IN        PA_FP_UPGRADE_AUDIT.BASIS_COST_VERSION_ID%TYPE
        ,p_basis_rev_version_id            IN        PA_FP_UPGRADE_AUDIT.BASIS_REV_VERSION_ID%TYPE
        ,p_basis_cost_bem                  IN        PA_FP_UPGRADE_AUDIT.BASIS_COST_BEM%TYPE
        ,p_basis_rev_bem                   IN        PA_FP_UPGRADE_AUDIT.BASIS_REV_BEM%TYPE
        ,p_upgraded_flag                   IN        PA_FP_UPGRADE_AUDIT.UPGRADED_FLAG%TYPE
        ,p_failure_reason_code             IN        PA_FP_UPGRADE_AUDIT.FAILURE_REASON_CODE%TYPE
        ,p_proj_fp_options_id_rup          IN        PA_FP_UPGRADE_AUDIT.PROJ_FP_OPTIONS_ID%TYPE DEFAULT NULL) IS

BEGIN

        INSERT INTO  PA_FP_UPGRADE_AUDIT (
                 PROJECT_ID
                ,BUDGET_TYPE_CODE
                ,PROJ_FP_OPTIONS_ID
                ,FIN_PLAN_OPTION_LEVEL_CODE
                ,BASIS_COST_VERSION_ID
                ,BASIS_REV_VERSION_ID
                ,BASIS_COST_BEM
                ,BASIS_REV_BEM
                ,REQUEST_ID
                ,UPGRADED_FLAG
                ,FAILURE_REASON_CODE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,proj_fp_options_id_rup )
        VALUES(
                 p_project_id
                ,p_budget_type_code
                ,p_proj_fp_options_id
                ,p_fin_plan_option_level_code
                ,p_basis_cost_version_id
                ,p_basis_rev_version_id
                ,p_basis_cost_bem
                ,p_basis_rev_bem
                ,fnd_global.conc_request_id
                ,p_upgraded_flag
                ,p_failure_reason_code
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,p_proj_fp_options_id_rup);

END Insert_Audit_Record;


/*==================================================================
   This api would be called by the pre_upgrade process from the
   upgrade budgets report. The api would insert the exception records
   into pa_fp_upgrade_audit table and pa_fp_upgrade_exceptions_tmp as
   necessary.
 ==================================================================*/

PROCEDURE VALIDATE_BUDGETS (
           p_from_project_number        IN           VARCHAR2
          ,p_to_project_number          IN           VARCHAR2
          ,p_budget_types               IN           VARCHAR2
          ,p_budget_statuses            IN           VARCHAR2
          ,p_project_type               IN           VARCHAR2
          ,p_project_statuses           IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

l_validation_status             VARCHAR2(30);
l_project_id                    pa_projects.project_id%TYPE;

-- cursor written for bug 2853511

CURSOR attached_budget_types_cur(
           c_project_id        IN    pa_projects.project_id%TYPE
           ,c_budget_types     IN    VARCHAR2 ) IS
SELECT bt.budget_type_code  budget_type_code
FROM   pa_budget_types     bt
WHERE  DECODE(c_budget_types,'ALL','Y', bt.upgrade_budget_type_flag) = 'Y'
AND    NVL(bt.plan_type,'BUDGET') = 'BUDGET'
AND    NOT EXISTS
           (SELECT 1
            FROM   pa_proj_fp_options ppfo
                   ,pa_fin_plan_types_b pt
            WHERE  pt.migrated_frm_bdgt_typ_code = bt.budget_type_code
            AND    ppfo.project_id = c_project_id
            AND    ppfo.fin_plan_type_id = pt.fin_plan_type_id
            AND    ppfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE)
AND    EXISTS
          (SELECT 1
           FROM   pa_budget_versions pbv
           WHERE  pbv.project_id = c_project_id
           AND    pbv.budget_type_code = bt.budget_type_code);

attached_budget_types_rec attached_budget_types_cur%ROWTYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.init_err_stack('PA_FP_UPGRADE_PKG.validate_budgets');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Validating input parameters';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_budget_types        IS NULL) OR
         (p_budget_statuses     IS NULL) OR
         (p_project_statuses    IS NULL)
      THEN
            IF p_pa_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'p_budget_types='||p_budget_types;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                 pa_debug.g_err_stage := 'p_budget_statuses='||p_budget_statuses;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                 pa_debug.g_err_stage := 'p_project_statuses='||p_project_statuses;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;

            PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                 p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- Fetch all the projects that are eligible for upgrade

        IF ( p_from_project_number IS NOT NULL) AND ( p_to_project_number IS NOT NULL ) THEN

            OPEN projects_for_upgrade_cur1(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);

        ELSIF ( p_project_type IS NOT NULL)  THEN

            OPEN projects_for_upgrade_cur2(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);

        ELSIF (p_project_statuses <> 'ALL') THEN

            OPEN projects_for_upgrade_cur3(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);
        ELSE
            OPEN projects_for_upgrade_cur(p_from_project_number,p_to_project_number,p_project_type,p_project_statuses);
        END IF;


      LOOP

        IF ( p_from_project_number IS NOT NULL) AND ( p_to_project_number IS NOT NULL ) THEN

             FETCH projects_for_upgrade_cur1 INTO l_project_id;
             EXIT WHEN projects_for_upgrade_cur1%NOTFOUND;

        ELSIF ( p_project_type IS NOT NULL)  THEN

            FETCH projects_for_upgrade_cur2 INTO l_project_id;
             EXIT WHEN projects_for_upgrade_cur2%NOTFOUND;

        ELSIF (p_project_statuses <> 'ALL') THEN

            FETCH projects_for_upgrade_cur3 INTO l_project_id;
             EXIT WHEN projects_for_upgrade_cur3%NOTFOUND;

        ELSE
            FETCH projects_for_upgrade_cur INTO l_project_id;
             EXIT WHEN projects_for_upgrade_cur%NOTFOUND;
        END IF;


             --Check if any types of budgets are allowed for the project using project_type_info_cur.

             IF p_pa_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'l_project_id='||l_project_id;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

             OPEN project_type_info_cur(l_project_id);
             FETCH project_type_info_cur INTO project_type_info_rec;
             CLOSE project_type_info_cur;

             IF (( project_type_info_rec.allow_cost_budget_entry_flag ='Y' )OR
                ( project_type_info_rec.allow_rev_budget_entry_flag = 'Y' )) AND
                ( NVL(project_type_info_rec.org_project_flag,'N') = 'N' ) -- bug :- 2788983 org_forecast project shouldn't be upgraded
             THEN

                  -- Perform project level validations necessary for UPGRADE

                  pa_fp_upgrade_pkg.Validate_Project(
                             p_project_id               =>       l_project_id
                            ,x_validation_status        =>       l_validation_status
                            ,x_return_status            =>       l_return_status
                            ,x_msg_count                =>       l_msg_count
                            ,x_msg_data                 =>       l_msg_data);

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  -- Fetch all the budget/plan types that have to be attached to the project
                  -- during upgrade.

                  -- Changes for bug 2853511
                  -- In PRE_UPGRADE mode, there needn't exist a corresponding plan_type for each
                  -- budget type that has been chosen to be upgraded. So, we should use a different
                  -- cursor to return all the budget_type_codes for a given project.

                 /*
                  OPEN  attached_plan_types_cur(l_project_id, p_budget_types);
                  LOOP
                          FETCH  attached_plan_types_cur INTO attached_plan_types_rec;
                          EXIT WHEN attached_plan_types_cur%NOTFOUND;

                          IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'budget_type_code='||attached_plan_types_rec.budget_type_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                          END IF;

                          -- For each budget type fetched check for all the exceptions

                          pa_fp_upgrade_pkg.Validate_Project_Plan_Type(
                                     p_project_id               =>       l_project_id
                                    ,p_budget_type_code         =>       attached_plan_types_rec.budget_type_code
                                    ,x_validation_status        =>       l_validation_status
                                    ,x_return_status            =>       l_return_status
                                    ,x_msg_count                =>       l_msg_count
                                    ,x_msg_data                 =>       l_msg_data);

                  END LOOP;
                  CLOSE attached_plan_types_cur;
                 */

                  OPEN  attached_budget_types_cur(l_project_id, p_budget_types);
                  LOOP
                          FETCH  attached_budget_types_cur INTO attached_budget_types_rec;
                          EXIT WHEN attached_budget_types_cur%NOTFOUND;

                          IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'budget_type_code='||attached_budget_types_rec.budget_type_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                          END IF;

                          -- For each budget type fetched check for all the exceptions

                          pa_fp_upgrade_pkg.Validate_Project_Plan_Type(
                                     p_project_id               =>       l_project_id
                                    ,p_budget_type_code         =>       attached_budget_types_rec.budget_type_code
                                    ,x_validation_status        =>       l_validation_status
                                    ,x_return_status            =>       l_return_status
                                    ,x_msg_count                =>       l_msg_count
                                    ,x_msg_data                 =>       l_msg_data);

                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;

                  END LOOP;
                  CLOSE attached_budget_types_cur;


                  -- Fetch all the budget versions of the current project that are eligible for upgrade
                  /* For FP M: The pre upgrade report is not going to do anything. Retaining the code as it is
                     (its just dummy processing) and would remove it later. */
                  OPEN budgets_for_upgrade_cur(l_project_id,p_budget_types,p_budget_statuses,'PRE_UPGRADE');
                  LOOP
                       FETCH budgets_for_upgrade_cur INTO  budgets_for_upgrade_rec;
                       EXIT WHEN budgets_for_upgrade_cur%NOTFOUND;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'budget_version_id='||budgets_for_upgrade_rec.budget_version_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                       -- Perform budget_version level validations necessary for UPGRADE
                       -- The only validation that was done in this api was for mixed resource planning level.
                       -- This is not applicable for FP M and hence for FP M this api doesnt do any validation.

                       pa_fp_upgrade_pkg.Validate_Budget_Version
                             (  p_budget_version_id     =>       budgets_for_upgrade_rec.budget_version_id
                               ,x_return_status         =>       l_return_status
                               ,x_msg_count             =>       l_msg_count
                               ,x_msg_data              =>       l_msg_data);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;
                  END LOOP;
                  CLOSE budgets_for_upgrade_cur;

             END IF; --if any types of budget are allowed for the project

      END LOOP;

        IF projects_for_upgrade_cur1%ISOPEN THEN
            CLOSE projects_for_upgrade_cur1;
        ELSIF projects_for_upgrade_cur2%ISOPEN THEN
            CLOSE projects_for_upgrade_cur2;
        ELSIF projects_for_upgrade_cur3%ISOPEN THEN
            CLOSE projects_for_upgrade_cur3;
        ELSE
            CLOSE projects_for_upgrade_cur;
        END IF;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting validate_budgets';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

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
           x_msg_data := l_msg_data;
           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.write_file('VALIDATE_BUDGETS ' || x_msg_data,5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          IF budgets_for_upgrade_cur%ISOPEN THEN
             CLOSE budgets_for_upgrade_cur;
          END IF;
            IF projects_for_upgrade_cur1%ISOPEN THEN
                CLOSE projects_for_upgrade_cur1;
            ELSIF projects_for_upgrade_cur2%ISOPEN THEN
                CLOSE projects_for_upgrade_cur2;
            ELSIF projects_for_upgrade_cur3%ISOPEN THEN
                CLOSE projects_for_upgrade_cur3;
            ELSIF projects_for_upgrade_cur%ISOPEN THEN
                CLOSE projects_for_upgrade_cur;
            END IF;
          --  start of changes for bug 2853511
          IF attached_budget_types_cur%ISOPEN THEN
               CLOSE attached_budget_types_cur;
          END IF;
          --  end of changes for bug 2853511
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_UPGRADE_PKG'
                           ,p_procedure_name  => 'validate_budgets'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.write_file('VALIDATE_BUDGETS ' || pa_debug.G_Err_Stack,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END VALIDATE_BUDGETS;

/*==================================================================
   This api is used to do validations required at project level for
   upgrade. This api is called both in PRE_UPGRADE and UPGRADE modes.

   Bug#2731534. Checking billing flag doesn't suffice the availablity
   of the conversion attributes for the project. It takes care of the
   revenue conversion attributes only. For cost attributes, if we do
   not find cost conversion attributes in pa_projects_all, then get
   them from the implementations table for the project's OU and if
   we do not find them there then raise exception for the project.
 ==================================================================*/

PROCEDURE VALIDATE_PROJECT (
           p_project_id          IN        pa_budget_versions.project_id%TYPE
          ,x_validation_status   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status       OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count           OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data            OUT       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);


l_multi_currency_billing_flag   pa_projects_all.multi_currency_billing_flag%TYPE;
l_projfunc_currency_code        pa_projects_all.projfunc_currency_code%TYPE;
l_project_currency_code         pa_projects_all.project_currency_code%TYPE;
l_project_bil_rate_type         pa_projects_all.project_bil_rate_type%TYPE;
l_projfunc_bil_rate_type        pa_projects_all.projfunc_bil_rate_type%TYPE;
l_project_cost_rate_type        pa_projects_all.project_rate_type%TYPE;
l_projfunc_cost_rate_type       pa_projects_all.projfunc_cost_rate_type%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.VALIDATE_PROJECT');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Validating input parameters';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id IS NULL)
      THEN

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Set x_validation_status to 'Y' initailly as and when we hit upona exception
      -- we update it to 'N'

      x_validation_status := 'Y';

      -- Fetch the project currencies, MCB flag and cost rate types

      /*   This api fetches the cost rate types from pa_projects_all table,
           if they aren't defined for project level then they are fetched from
           pa_implementations table */

      PA_FIN_PLAN_UTILS.Get_Project_Curr_Attributes
             (  p_project_id                      =>  p_project_id
               ,x_multi_currency_billing_flag     =>  l_multi_currency_billing_flag
               ,x_project_currency_code           =>  l_project_currency_code
               ,x_projfunc_currency_code          =>  l_projfunc_currency_code
               ,x_project_cost_rate_type          =>  l_project_cost_rate_type
               ,x_projfunc_cost_rate_type         =>  l_projfunc_cost_rate_type
               ,x_project_bil_rate_type           =>  l_project_bil_rate_type
               ,x_projfunc_bil_rate_type          =>  l_projfunc_bil_rate_type
               ,x_return_status                   =>  l_return_status
               ,x_msg_count                       =>  l_msg_count
               ,x_msg_data                        =>  l_msg_data   );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- check if project currency and projfunc currency are not equal
      -- then we require conversion attributes at project level for upgrade

      IF l_projfunc_currency_code <> l_project_currency_code   AND
         (l_multi_currency_billing_flag <> 'Y'  OR
          l_project_cost_rate_type  IS NULL     OR  -- bug 2731534
          l_projfunc_cost_rate_type IS NULL)        -- bug 2731534
      THEN

             -- set x_validation_status to 'N'

             x_validation_status := 'N';

             -- Insert into audit table

             pa_fp_upgrade_pkg.Insert_Audit_Record(
                     p_project_id                     =>   p_project_id
                    ,p_budget_type_code               =>   NULL
                    ,p_proj_fp_options_id             =>   NULL
                    ,p_fin_plan_option_level_code     =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PROJECT
                    ,p_basis_cost_version_id          =>   NULL
                    ,p_basis_rev_version_id           =>   NULL
                    ,p_basis_cost_bem                 =>   NULL
                    ,p_basis_rev_bem                  =>   NULL
                    ,p_upgraded_flag                  =>   'N'
                    ,p_failure_reason_code            =>   'NO_CONV_ATTR_FOR_PROJ');

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting validate_project';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_validation_status := 'N';
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
                x_msg_data := l_msg_data;
           END IF;

           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.write_file('VALIDATE_PROJECT ' || x_msg_data,5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_validation_status := 'N';
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_UPGRADE_PKG'
                           ,p_procedure_name  => 'VALIDATE_PROJECT'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.write_file('VALIDATE_PROJECT ' || pa_debug.G_Err_Stack,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END VALIDATE_PROJECT;

/*==================================================================
   This api would be called both in 'PRE_UPGRADE' mode and 'UPGRADE'
   mode and does all the necesary business validations that are to be
   done at the budget type level.
 ==================================================================*/

PROCEDURE VALIDATE_PROJECT_PLAN_TYPE (
      p_project_id            IN   pa_budget_versions.project_id%TYPE
     ,p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
     ,x_validation_status     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);

l_draft_version_id              pa_budget_versions.budget_version_id%TYPE;
l_budget_status_code            pa_budget_versions.budget_status_code%TYPE;

      ---------- Variables Used for get_budget_ctrl_options api --------------
l_fck_req_flag                  VARCHAR2(1);
l_bdgt_intg_flag                VARCHAR2(1);
l_bdgt_ver_id                   pa_budget_versions.budget_version_id%TYPE;
l_encum_type_id                 pa_budgetary_control_options.encumbrance_type_id%TYPE;
l_balance_type                  pa_budgetary_control_options.balance_type%TYPE ;
      ---------- Variables Used for get_budget_ctrl_options api --------------

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.VALIDATE_PROJECT_PLAN_TYPE');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations

      IF (p_project_id  IS NULL) OR (p_budget_type_code IS NULL)
      THEN

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     pa_debug.g_err_stage:= 'p_budget_type_code = '|| p_budget_type_code;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED');


                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Initially setting x_validation_status to yes.
      -- as and when we hit upon an error we set the x_validation_status to 'N'
      -- but we still proceed to report all the exceptions

      x_validation_status := 'Y';

      --Check if budetary controls exist for the budget type and project combination.

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Calling get_budget_ctrl_options';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      PA_BUDGET_FUND_PKG.get_budget_ctrl_options (
                   p_project_id             =>      p_project_id,
                   p_budget_type_code       =>      p_budget_type_code,
                   p_calling_mode           =>      'BUDGET',
                   x_fck_req_flag           =>      l_fck_req_flag,
                   x_bdgt_intg_flag         =>      l_bdgt_intg_flag,
                   x_bdgt_ver_id            =>      l_bdgt_ver_id,
                   x_encum_type_id          =>      l_encum_type_id,
                   x_balance_type           =>      l_balance_type,
                   x_return_status          =>      l_return_status,
                   x_msg_count              =>      l_msg_count,
                   x_msg_data               =>      l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;


      --Check if any budget version exists in submitted status having this budget type

      IF NVL(l_bdgt_intg_flag,'Y') <> 'N' OR NVL(l_fck_req_flag,'Y')<> 'N' THEN -- Bug:- 2686836

              -- Set x_validation_status to 'N' as the this budget type and
              -- all the budget versions can't be upgraded.

              x_validation_status := 'N';

              -- Insert the exception into audit table

              pa_fp_upgrade_pkg.Insert_Audit_Record(
                             p_project_id                     =>   p_project_id
                            ,p_budget_type_code               =>   p_budget_type_code
                            ,p_proj_fp_options_id             =>   NULL
                            ,p_fin_plan_option_level_code     =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
                            ,p_basis_cost_version_id          =>   NULL
                            ,p_basis_rev_version_id           =>   NULL
                            ,p_basis_cost_bem                 =>   NULL
                            ,p_basis_rev_bem                  =>   NULL
                            ,p_upgraded_flag                  =>   'N'
                            ,p_failure_reason_code            =>   'BUDGET_INTEGRATION_EXISTS');
      END IF;

      -- Check if for the budget type if any of the budget versions to be upgraded is in
      -- submitted status. if so don't upgrade.
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Calling get_draft_version_id';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      l_draft_version_id := Null;

      pa_budget_utils.get_draft_version_id (
              x_project_id            =>      p_project_id
              ,x_budget_type_code     =>      p_budget_type_code
              ,x_budget_version_id    =>      l_draft_version_id
              ,x_err_code             =>      l_err_code
              ,x_err_stage            =>      l_err_stage
              ,x_err_stack            =>      l_err_stack);

      -- bug 2853511 draft version id could be deleted after baselining the draft version
      -- and thus draft version needn't exist

      IF l_draft_version_id IS NOT NULL THEN
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'draft_version_id = '|| l_draft_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           -- The draft version id fetched may be either working or submitted version
           -- If the draft version is in submitted status this budget type can't be upgraded

           BEGIN
                SELECT budget_status_code
                INTO   l_budget_status_code
                FROM   pa_budget_versions
                WHERE  budget_version_id = l_draft_version_id;
           EXCEPTION
                WHEN OTHERS THEN
                   IF attached_plan_types_cur%ISOPEN THEN
                        CLOSE attached_plan_types_cur;
                   END IF;
                   IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='draft_version_id is null or invalid'||SQLERRM;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   RAISE;
           END;

           IF l_budget_status_code = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED THEN

                   -- Set x_validation_status to 'N' as the this budget type and
                   -- all the budget versions can't be upgraded.

                   x_validation_status := 'N';

                   -- Insert into audit table
                   pa_fp_upgrade_pkg.Insert_Audit_Record(
                                  p_project_id                     =>   p_project_id
                                 ,p_budget_type_code               =>   p_budget_type_code
                                 ,p_proj_fp_options_id             =>   NULL
                                 ,p_fin_plan_option_level_code     =>   PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
                                 ,p_basis_cost_version_id          =>   NULL
                                 ,p_basis_rev_version_id           =>   NULL
                                 ,p_basis_cost_bem                 =>   NULL
                                 ,p_basis_rev_bem                  =>   NULL
                                 ,p_upgraded_flag                  =>   'N'
                                 ,p_failure_reason_code            =>   'SUBMIT_STATUS_VERSION_EXISTS');
           END IF;
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting VALIDATE_PROJECT_PLAN_TYPE';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_validation_status := 'N';
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
                x_msg_data := l_msg_data;
           END IF;

           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.write_file('VALIDATE_PROJECT_PLAN_TYPE ' || x_msg_data,5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_validation_status := 'N';
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_UPGRADE_PKG'
                           ,p_procedure_name  => 'VALIDATE_PROJECT_PLAN_TYPE'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.write_file('VALIDATE_PROJECT_PLAN_TYPE ' || pa_debug.G_Err_Stack,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END VALIDATE_PROJECT_PLAN_TYPE;

/*==================================================================
   This api is used to validate a budget version in pre_upgrade mode.
   The  api reports all the tasks along with different resource
   groups ,if the task id is planned both at resource level and
   resource group level(referred to as 'mixed planning level').

   1.0)In the api, for each task we cache all the resource groups
   planned for along with the planning level in pl/sql tables
       i)if for the task mixed planning level exists then they are
         written to PA_FP_UPG_EXCEPTIONS_TMP table for reporting
         puposes.
       ii)else we flush the plsql tables and move to next task.
 ====================================================================*/

PROCEDURE VALIDATE_BUDGET_VERSION
   (  p_budget_version_id     IN   pa_budget_versions.budget_version_id%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

l_task_id                       pa_tasks.task_id%TYPE;

CURSOR budget_version_info_cur
       (c_budget_version_id  pa_budget_versions.budget_version_id%TYPE) IS
SELECT project_id,
       budget_type_code,
       resource_list_id
FROM   pa_budget_versions
WHERE  budget_Version_id = c_budget_version_id;

budget_version_info_rec        budget_version_info_cur%ROWTYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_UPGRADE_PKG.validate_budget_version');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Check for business rules violations
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Validating input parameters';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_budget_version_id IS NULL)
      THEN
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'p_budget_version_id = '|| p_budget_version_id;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      OPEN budget_version_info_cur(p_budget_version_id);
      FETCH budget_version_info_cur INTO budget_version_info_rec;
      CLOSE budget_version_info_cur;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting validate_budget_version';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

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
                x_msg_data := l_msg_data;
           END IF;

           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.write_file('VALIDATE_BUDGET_VERSION ' || x_msg_data,5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_UPGRADE_PKG'
                           ,p_procedure_name  => 'VALIDATE_BUDGET_VERSION'
                           ,p_error_text      => SQLERRM);
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
               pa_debug.write_file('VALIDATE_BUDGET_VERSION ' || pa_debug.G_Err_Stack,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END VALIDATE_BUDGET_VERSION;

--This procedure will upgrade the budget lines of a budget version so that all the amount/quantity columns
--are populated. Please refer to the bug to see more discussion on this matter

--ASSUMPTIONS
--1.Input is ordered by resource assignment id ,quantities with NULLS coming first
--2.0(Zero)s are passed as input for amounts instead of NULL.
PROCEDURE Apply_Calculate_FPM_Rules
( p_preference_code              IN   pa_proj_fp_options.fin_plan_preference_code%TYPE
 ,p_resource_assignment_id_tbl   IN   SYSTEM.pa_num_tbl_type
 ,p_rate_based_flag_tbl          IN   SYSTEM.pa_varchar2_1_tbl_type
 ,p_quantity_tbl                 IN   SYSTEM.pa_num_tbl_type
 ,p_txn_raw_cost_tbl             IN   SYSTEM.pa_num_tbl_type
 ,p_txn_burdened_cost_tbl        IN   SYSTEM.pa_num_tbl_type
 ,p_txn_revenue_tbl              IN   SYSTEM.pa_num_tbl_type
 ,p_calling_module               IN   VARCHAR2    -- bug 5007734
 ,x_quantity_tbl                 OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_raw_cost_tbl             OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_burdened_cost_tbl        OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_revenue_tbl              OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_raw_cost_override_rate_tbl   OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_burd_cost_override_rate_tbl  OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_bill_override_rate_tbl       OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_non_rb_ra_id_tbl             OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

--Start of variables used for debugging
l_return_status                       VARCHAR2(1);
l_msg_count                           NUMBER := 0;
l_msg_data                            VARCHAR2(2000);
l_data                                VARCHAR2(2000);
l_msg_index_out                       NUMBER;
l_debug_mode                          VARCHAR2(30);
l_module_name                         VARCHAR2(200) :=  'PAFPUPGB.Apply_Calculate_FPM_Rules';

--Stores previous non rate based resource assignment id
l_prev_non_rb_ra_id                   pa_resource_assignments.resource_assignment_id%TYPE;

--Processing will be done in the following local variables
l_quantity_tab                        SYSTEM.pa_num_tbl_type;
l_txn_raw_cost_tab                    SYSTEM.pa_num_tbl_type;
l_txn_burdened_cost_tab               SYSTEM.pa_num_tbl_type;
l_txn_revenue_tab                     SYSTEM.pa_num_tbl_type;
l_cost_rate_override_tab              SYSTEM.pa_num_tbl_type;
l_burden_rate_override_tab            SYSTEM.pa_num_tbl_type;
l_bill_rate_override_tab              SYSTEM.pa_num_tbl_type;

l_stage                               VARCHAR2(100);

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
    pa_debug.set_curr_function(
                p_function   =>'PAFPUPGB.Apply_Calculate_FPM_Rules'
               ,p_debug_mode => l_debug_mode );

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF NVL(p_preference_code,'-99') NOT IN ('COST_ONLY','REVENUE_ONLY','COST_AND_REV_SAME') OR
       p_quantity_tbl.COUNT  <>  p_resource_assignment_id_tbl.COUNT OR
       p_quantity_tbl.COUNT  <>  p_rate_based_flag_tbl.COUNT OR
       p_quantity_tbl.COUNT  <>  p_txn_raw_cost_tbl.COUNT OR
       p_quantity_tbl.COUNT  <>  p_txn_burdened_cost_tbl.COUNT OR
       p_quantity_tbl.COUNT  <>  p_txn_revenue_tbl.COUNT THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_preference_code is '||p_preference_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_quantity_tbl.COUNT is '||p_quantity_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_txn_raw_cost_tbl.COUNT is '||p_txn_raw_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_txn_burdened_cost_tbl.COUNT is '||p_txn_burdened_cost_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_txn_revenue_tbl.COUNT is '||p_txn_revenue_tbl.COUNT;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_quantity_tbl.COUNT=0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Quantity Table is empty -> returning';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
        END IF;
         pa_debug.reset_curr_function;
         RETURN;

    END IF;

    --Prepare amount tbls for processing
    l_quantity_tab             := p_quantity_tbl;
    l_txn_raw_cost_tab         := p_txn_raw_cost_tbl;
    l_txn_burdened_cost_tab    := p_txn_burdened_cost_tbl;
    l_txn_revenue_tab          := p_txn_revenue_tbl;
    l_cost_rate_override_tab   := SYSTEM.pa_num_tbl_type();
    l_burden_rate_override_tab := SYSTEM.pa_num_tbl_type();
    l_bill_rate_override_tab   := SYSTEM.pa_num_tbl_type();
    l_cost_rate_override_tab.extend(p_quantity_tbl.COUNT);
    l_burden_rate_override_tab.extend(p_quantity_tbl.COUNT);
    l_bill_rate_override_tab.extend(p_quantity_tbl.COUNT);

    --Prepare the tbl that holds the RAs for which rate based flag should be changed.
    x_non_rb_ra_id_tbl           := SYSTEM.pa_num_tbl_type();


    FOR i IN l_quantity_tab.first .. l_quantity_tab.last LOOP

        /* check if planning resource is rate based and quantity does not exists
         * then mark the planning resource as non-rate based and change the
         * UOM as Currency
         */
        IF (p_rate_based_flag_tbl(i) = 'Y' AND l_quantity_tab(i) = 0) THEN

            IF l_prev_non_rb_ra_id IS NULL OR (l_prev_non_rb_ra_id <> p_resource_assignment_id_tbl(i)) THEN

                l_stage := 'This is rate based resource quantity doesnot exists';
                x_non_rb_ra_id_tbl.extend;
                x_non_rb_ra_id_tbl(x_non_rb_ra_id_tbl.COUNT) := p_resource_assignment_id_tbl(i);
                l_prev_non_rb_ra_id := p_resource_assignment_id_tbl(i);

            END IF;

        END IF;

        IF p_preference_code = 'COST_ONLY' THEN

            l_txn_revenue_tab(i) := NULL;
            l_bill_rate_override_tab(i) := NULL;


            --this portion will check quantity is zero and amounts are null/zero
            IF l_quantity_tab(i) = 0 THEN

                If (Nvl(l_txn_burdened_cost_tab(i),0) <> 0 and
                    nvl(l_txn_raw_cost_tab(i),0) <> 0 ) Then

                    l_stage := 'PRC:1';
                    l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                    l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                Elsif (Nvl(l_txn_burdened_cost_tab(i),0) <> 0  and
                       nvl(l_txn_raw_cost_tab(i),0) = 0 ) Then

                    l_stage := 'PRC:2';
                    l_quantity_tab(i) := l_txn_burdened_cost_tab(i);
                    l_txn_raw_cost_tab(i) := l_txn_burdened_cost_tab(i);
                    l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                Elsif (Nvl(l_txn_burdened_cost_tab(i),0) = 0
                   and nvl(l_txn_raw_cost_tab(i),0) <> 0 ) Then

                    l_stage := 'PRC:3';
                    l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                    --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                    l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

               End If;
            -- this portion of code checks quantity not zero and amounts are zero
            Else
                 If p_rate_based_flag_tbl(i) = 'N' OR
                      l_prev_non_rb_ra_id = p_resource_assignment_id_tbl(i) Then   -- added for bug 5007734:

                          -- bug 5007734: Making quantity = amounts only for upgrade flow, for the planning transactions
                          -- which are non rate based or going to be made non rate based.
                          IF p_calling_module = 'UPGRADE' THEN

                    If (l_txn_raw_cost_tab(i) <> 0
                    and l_txn_raw_cost_tab(i) <> l_quantity_tab(i)) Then

                        l_stage := 'PRC:4';
                        l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                        l_cost_rate_override_tab(i) :=  1;

                    Else /* if (l_txn_raw_cost_tab(i) = 0 and l_txn_raw_cost_tab(i) <> l_quantity_tab(i))
                               or
                               (txn_raw_cost = quantity  and txn_raw_cost <> 0) Then */

                        l_stage := 'PRC:5'; --Bug 5076350
                        If (l_txn_raw_cost_tab(i) = l_quantity_tab(i) and nvl(l_txn_raw_cost_tab(i),0) <> 0) Then
                                    l_cost_rate_override_tab(i) :=  1;
                        Elsif nvl(l_txn_burdened_cost_tab(i),0) <> 0 Then
                                    l_txn_raw_cost_tab(i) := l_quantity_tab(i);
                                    l_cost_rate_override_tab(i) :=  1;
                        End if;
                    End If;

                    If nvl(l_txn_burdened_cost_tab(i),0) <> 0 Then

                        l_stage := 'PRC:6';
                        l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:7';
                        --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                        --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    End If;
                    END IF; -- end of bug 5007734
                Else --Rate Based Flag ='Y'

                    If l_txn_raw_cost_tab(i) <> 0 Then

                        l_stage := 'PRC:8';
                        l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);

                    Else

                       l_stage := 'PRC:9';
                       --l_txn_raw_cost_tab(i) := l_quantity_tab(i);
                       --l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);

                    End If;

                    If nvl(l_txn_burdened_cost_tab(i),0) <> 0 Then

                        l_stage := 'PRC:10';
                        l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:11';
                        --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                        --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    End If;

                End If; --If p_rate_based_flag_tbl(i) = 'N' Then

            End If; --IF l_quantity_tab(i) = 0 THEN

        Elsif p_preference_code = 'REVENUE_ONLY' Then

            l_txn_raw_cost_tab(i) := NULL;
            l_txn_burdened_cost_tab(i) := NULL;
            l_cost_rate_override_tab(i) := NULL;
            l_burden_rate_override_tab(i) := NULL;

            If l_quantity_tab(i) = 0 then

                l_stage := 'PRC:12';
                If (nvl(l_txn_revenue_tab(i),0) <> 0 ) Then
                     l_stage := 'PRC:13';
                     l_quantity_tab(i) := l_txn_revenue_tab(i);
                     l_bill_rate_override_tab(i) := 1;
                End If;

            Else

                  If p_rate_based_flag_tbl(i) = 'N' OR
                      l_prev_non_rb_ra_id = p_resource_assignment_id_tbl(i) Then   -- added for bug 5007734:
                          -- bug 5007734: Making quantity = amounts only for upgrade flow, for the planning transactions
                          -- which are non rate based or going to be made non rate based.
                          IF p_calling_module = 'UPGRADE' THEN

                    If (nvl(l_txn_revenue_tab(i),0) <> 0
                        and l_txn_revenue_tab(i) <> l_quantity_tab(i)) Then

                        l_stage := 'PRC:14';
                        l_quantity_tab(i) := l_txn_revenue_tab(i);
                        l_bill_rate_override_tab(i) := 1;

                    Else /* if nvl(l_txn_revenue_tab(i),0) = 0 or quantity = revenue Then */

                        l_stage := 'PRC:15';
                        l_txn_revenue_tab(i) := l_quantity_tab(i);
                        l_bill_rate_override_tab(i) := 1;

                    End If;
                   END IF; -- end of bug 5007734

                Else-- Rate Based RA

                    If nvl(l_txn_revenue_tab(i),0) <> 0 Then

                        l_stage := 'PRC:16';
                        l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:17';
                        --l_txn_revenue_tab(i) := l_quantity_tab(i);
                        --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;

                End If;--If p_rate_based_flag_tbl(i) = 'N' Then

            End If; --If l_quantity_tab(i) = 0 then

        Elsif p_preference_code = 'COST_AND_REV_SAME' then

            If l_quantity_tab(i) = 0 then

                l_stage := 'PRC:18';
                If (Nvl(l_txn_burdened_cost_tab(i),0) <> 0
                and nvl(l_txn_raw_cost_tab(i),0) <> 0 ) Then  --{

                    l_stage := 'PRC:19';
                    l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                    l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    If nvl(l_txn_revenue_tab(i),0) <> 0 Then

                       l_stage := 'PRC:21';
                       l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                       l_stage := 'PRC:22';
                       --l_txn_revenue_tab(i) := l_txn_burdened_cost_tab(i);
                       --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;

                Elsif (Nvl(l_txn_burdened_cost_tab(i),0) <> 0
                   and nvl(l_txn_raw_cost_tab(i),0) = 0 ) Then

                    l_stage := 'PRC:20';
                    l_quantity_tab(i) := l_txn_burdened_cost_tab(i);
                    --l_txn_raw_cost_tab(i) := l_txn_burdened_cost_tab(i);
                    --l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    If nvl(l_txn_revenue_tab(i),0) <> 0 Then

                       l_stage := 'PRC:21';
                       l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                       l_stage := 'PRC:22';
                       --l_txn_revenue_tab(i) := l_txn_burdened_cost_tab(i);
                       --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;

                Elsif (Nvl(l_txn_burdened_cost_tab(i),0) = 0
                   and nvl(l_txn_raw_cost_tab(i),0) <> 0 ) Then

                    l_stage := 'PRC:23';
                    l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                    --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                    l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                    --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    If nvl(l_txn_revenue_tab(i),0) <> 0 Then

                        l_stage := 'PRC:24';
                        l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:25';
                        --l_txn_revenue_tab(i) := l_txn_raw_cost_tab(i);
                        --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;

                Elsif (Nvl(l_txn_burdened_cost_tab(i),0) = 0
                   and nvl(l_txn_raw_cost_tab(i),0) = 0
                   and nvl(l_txn_revenue_tab(i),0) <> 0 ) Then

                        l_stage := 'PRC:26';
                        /* Bug 4865563: IPM Business Rule, if only revenue is present, don't copy it to anything. */
                        l_quantity_tab(i) := l_txn_revenue_tab(i);
                        --l_txn_raw_cost_tab(i) := l_txn_revenue_tab(i);
                        --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                        --l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);
                        --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);
                        l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i); /* bug 5006029 */

               End If; --}

            Else  -- quantity not equal to zero

                  If p_rate_based_flag_tbl(i) = 'N' OR
                      l_prev_non_rb_ra_id = p_resource_assignment_id_tbl(i) Then   -- added for bug 5007734:
                          -- bug 5007734: Making quantity = amounts only for upgrade flow, for the planning transactions
                          -- which are non rate based or going to be made non rate based.
                          IF p_calling_module = 'UPGRADE' THEN

                    If (nvl(l_txn_raw_cost_tab(i),0) <> 0
                    and l_quantity_tab(i) <> l_txn_raw_cost_tab(i)) Then

                        l_stage := 'PRC:27';
                        l_quantity_tab(i) := l_txn_raw_cost_tab(i);
                        l_cost_rate_override_tab(i) := 1;

                    Else /* if nvl(l_txn_raw_cost_tab(i),0) = 0 or l_quantity_tab(i) = l_txn_raw_cost_tab(i) */

                        l_stage := 'PRC:28';--Bug 5076350
                        If (l_txn_raw_cost_tab(i) = l_quantity_tab(i) and nvl(l_txn_raw_cost_tab(i),0) <> 0) Then
                            l_cost_rate_override_tab(i) :=  1;
                        Elsif nvl(l_txn_burdened_cost_tab(i),0) <> 0 Then
                        l_txn_raw_cost_tab(i) := l_quantity_tab(i);
                        l_cost_rate_override_tab(i) := 1;
                        End if;
                    End If;

                    If ( nvl(l_txn_burdened_cost_tab(i),0) <> 0) Then

                        l_stage := 'PRC:29';
                        l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:30';
                        --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                        --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    End If;

                    If (nvl(l_txn_revenue_tab(i),0) <> 0) Then

                        l_stage := 'PRC:31';
                        l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:32';
                        --l_txn_revenue_tab(i) := l_txn_burdened_cost_tab(i);
                        --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;
                 END IF; -- end of bug 5007734

                Else -- this for rate based resource

                    If nvl(l_txn_raw_cost_tab(i),0) <> 0 Then

                        l_stage := 'PRC:33';
                        l_cost_rate_override_tab(i) := l_txn_raw_cost_tab(i)/l_quantity_tab(i);

                    Elsif nvl(l_txn_raw_cost_tab(i),0) = 0 Then

                        l_stage := 'PRC:34';
                        --l_txn_raw_cost_tab(i) := l_quantity_tab(i);
                        --l_cost_rate_override_tab(i) := 1;

                    End If;

                    If ( nvl(l_txn_burdened_cost_tab(i),0) <> 0) Then

                        l_stage := 'PRC:35';
                        l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:36';
                        --l_txn_burdened_cost_tab(i) := l_txn_raw_cost_tab(i);
                        --l_burden_rate_override_tab(i) := l_txn_burdened_cost_tab(i)/l_quantity_tab(i);

                    End If;

                    If (nvl(l_txn_revenue_tab(i),0) <> 0) Then

                        l_stage := 'PRC:37';
                        l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    Else

                        l_stage := 'PRC:38';
                        --l_txn_revenue_tab(i) := l_txn_burdened_cost_tab(i);
                        --l_bill_rate_override_tab(i) := l_txn_revenue_tab(i)/l_quantity_tab(i);

                    End If;

                End If; --If p_rate_based_flag_tbl(i) = 'N' Then

            End If; --If l_quantity_tab(i) = 0 then

        End IF; --IF p_preference_code = 'COST_ONLY' THEN

    END LOOP;

    x_quantity_tbl               := l_quantity_tab             ;
    x_txn_raw_cost_tbl           := l_txn_raw_cost_tab         ;
    x_txn_burdened_cost_tbl      := l_txn_burdened_cost_tab    ;
    x_txn_revenue_tbl            := l_txn_revenue_tab          ;
    x_raw_cost_override_rate_tbl := l_cost_rate_override_tab   ;
    x_burd_cost_override_rate_tbl:= l_burden_rate_override_tab ;
    x_bill_override_rate_tbl     := l_bill_rate_override_tab   ;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Apply_Calculate_FPM_Rules';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);
    END IF;
    -- reset curr function
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

           x_msg_data := l_data;
           x_msg_count := l_msg_count;
       ELSE
           x_msg_count := l_msg_count;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

       END IF;
       -- reset curr function
       pa_debug.reset_curr_function();
       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_upgrade_pkg'
                               ,p_procedure_name  => 'Apply_Calculate_FPM_Rules l_stage'||l_stage);

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
       END IF;
       -- reset curr function
       pa_debug.Reset_Curr_Function();
       RAISE;

END Apply_Calculate_FPM_Rules;

PROCEDURE rollup_rejected_bl_amounts(
              p_from_project_number        IN           VARCHAR2 DEFAULT NULL
             ,p_to_project_number          IN           VARCHAR2 DEFAULT NULL
             ,p_fin_plan_type_id           IN           NUMBER DEFAULT NULL
             ,p_project_statuses           IN           VARCHAR2
             ,x_return_status              OUT NOCOPY         VARCHAR2
             ,x_msg_count                  OUT NOCOPY         NUMBER
             ,x_msg_data                   OUT NOCOPY         VARCHAR2) IS
   l_return_status         VARCHAR2(2000);
   l_msg_count             NUMBER :=0;
   l_msg_data              VARCHAR2(2000);
   l_data                  VARCHAR2(2000);
   l_msg_index_out         NUMBER;
   l_debug_mode            VARCHAR2(30);
   l_error_msg_code        VARCHAR2(2000);

   l_project_id            pa_projects.project_id%TYPE;
   l_bv_id                 pa_budget_versions.budget_version_id%TYPE;
   l_budg_ver_id           pa_budget_versions.budget_version_id%TYPE;
   l_ci_id                 pa_control_items.ci_id%TYPE;
   l_op_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;

   /* For bug 5084161 */
   l_ci_status_code        pa_control_items.status_code%TYPE;
   l_process_flag          varchar2(1);
   /* For bug 5084161 */

   l_retcode number;
   l_errbuf varchar2(512);

   l_date date := sysdate;
   l_login_id NUMBER := fnd_global.login_id;
   l_user_id NUMBER := fnd_global.user_id;

   l_budget_ver_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

   l_fp_cols_rec_var               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;  --/* Bug 5098818 */

   record_locked EXCEPTION;
   PRAGMA EXCEPTION_INIT (record_locked, -54);

   /* 5084161 - Removed the ci status checking logic from this cursor */

   CURSOR get_proj_bv_ids_for_rup(
           c_from_project_number   IN   VARCHAR2
          ,c_to_project_number     IN   VARCHAR2
          ,c_project_statuses      IN   VARCHAR2
          ,c_fin_plan_type_id      IN   NUMBER) IS
   SELECT prj.project_id,
          bv.budget_version_id,
          bv.ci_id,
          op.proj_fp_options_id,
          ci.status_code
   FROM   pa_projects prj,
          pa_budget_versions bv,
          pa_fin_plan_types_b fp,
          pa_control_items ci,
          pa_proj_fp_options op
   WHERE  segment1 BETWEEN  NVL(c_from_project_number,segment1) AND  NVL(c_to_project_number,segment1)
   AND    DECODE(c_project_statuses,'ALL','ACTIVE',prj.project_status_code) = 'ACTIVE'
   AND   bv.project_id = prj.project_id
   and   bv.fin_plan_type_id = fp.fin_plan_type_id
   and   bv.budget_version_id = op.fin_plan_version_id
   and   op.project_id = bv.project_id
   and   nvl(c_fin_plan_type_id,fp.fin_plan_type_id) = fp.fin_plan_type_id
   and   nvl(fp.FIN_PLAN_TYPE_CODE,'x') <> 'ORG_FORECAST'
   and   bv.budget_status_code = 'W'
   and   bv.ci_id = ci.ci_id(+)
   and   NVL(pa_project_structure_utils.check_struc_ver_published(bv.project_id,bv.project_structure_version_id),'N') = 'N'
   and NOT EXISTS (SELECT 1 FROM pa_fp_upgrade_audit aud
                    WHERE aud.project_id = op.project_id
                      AND aud.proj_fp_options_id_rup = op.PROJ_FP_OPTIONS_ID
                      AND aud.upgraded_flag = 'Y')
   and EXISTS (SELECT 1 FROM pa_budget_lines bl
                WHERE bl.budget_version_id = bv.budget_version_id
                  AND (  bl.cost_rejection_code  IS NOT NULL
                           OR bl.revenue_rejection_code IS NOT NULL
                           OR bl.burden_rejection_code IS NOT NULL
                           OR bl.pfc_cur_conv_rejection_code IS NOT NULL
                           OR bl.pc_cur_conv_rejection_code IS NOT NULL
                       )
               )
   and bv.prc_generated_flag = 'M';  --IPM Optional Upgrade Process
                                     /* PRC_GENERATED_FLAG is marked with 'M' during the patchset upgrade process
                                     of paupg109.sql while upgrading from FPM to IPM level. This cursor picks up
                                     only those budget_versions which were marked during patchset upgrade. Note that
                                     PRC_GENERATED_FLAG is being reused here; it was introduced earlier for a different
                                     purpose but was never used
                                     */

   BEGIN
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       savepoint rollup_rejected_bl_amounts;

       pa_debug.init_err_stack('PA_FP_UPGRADE_PKG.rollup_rejected_bl_amounts');

       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Entered rollup_rejected_bl_amounts';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage := 'Checking for valid parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       IF p_project_statuses IS NULL THEN
             IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'p_project_statuses='||p_project_statuses;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                  p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Parameter validation complete';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       -- Fetch all the projects whose budget's lines amounts need to be rolled up.
       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'opening get_proj_bv_ids_for_rup';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage := 'p_from_project_number  = '||p_from_project_number;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage := 'p_to_project_number = '|| p_to_project_number;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage := 'p_project_statuses='||p_project_statuses;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
       END IF;

       OPEN get_proj_bv_ids_for_rup(p_from_project_number,p_to_project_number,p_project_statuses,p_fin_plan_type_id);
       LOOP
               FETCH get_proj_bv_ids_for_rup INTO l_project_id,l_bv_id,l_ci_id,l_op_id,l_ci_status_code;
               EXIT WHEN get_proj_bv_ids_for_rup%NOTFOUND;

              IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Project_id ='||l_project_id;
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                   pa_debug.g_err_stage := 'Opening  get_fin_plan_versions'||l_project_id;
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

                       savepoint rollup_bl_amounts_to_bv;

                       BEGIN

                       /* Start of fix for bug 5084161 */

                       l_process_flag := 'Y';

                       /* Check if ci is in updateable status - following code got from ci team */

                       IF l_ci_id IS NOT NULL THEN

                            begin
                                 select 'Y'
                                 into   l_process_flag
                                 from   pa_project_statuses ps ,
                                        pa_project_status_controls psc
                                 where  ps.project_Status_code = l_ci_status_code
                                 and    ps.project_system_status_code = nvl(psc.project_system_status_code,psc.project_Status_code)
                                 and    psc.status_type = 'CONTROL_ITEM'
                                 and    psc.action_code = 'CONTROL_ITEM_ALLOW_UPDATE'
                                 and    psc.enabled_flag = 'N'
                                 and    rownum < 2;

                            exception
                                 when no_data_found then
                                      l_process_flag := 'N';
                            end;

                       END IF;

                       /* End of fix for bug 5084161 */

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Budget Version Id ='||l_bv_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'Change Order/Req ID ='||l_ci_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'l_ci_status_code / l_process_flag = ' || l_ci_status_code || '/' || l_process_flag;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                       IF l_process_flag = 'Y' THEN /* 5084161 */

                       -- Now we have a budget version id and we will try to lock these
                       -- We try to lock the records in pa_resource_asgn_curr,pa_resource_assignments
                       -- as well to avoid the partial processing.
                       -- Imagine the case where the ra records are processed and now we fail
                       -- to obtain a lock on budget versions record. In order to avoid this
                       -- we obtain locks on all the records in all the table and then we will
                       -- proceed. If we fail to obtain a lock on a particular budget version then
                       -- We will update the audit table with that id and the reason then we will
                       -- proceed to process the other budget versions in the project/range.


                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Deleting the pl/sql tables before locking the records.';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                          l_rtx_ra_id_tbl.delete;
                          l_ra_id_tbl.delete ;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Successfully Deleted the pl/sql tables.';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                          SELECT bv.budget_version_id INTO l_budg_ver_id
                            FROM pa_budget_versions bv
                           WHERE bv.budget_version_id = l_bv_id
                           FOR UPDATE OF bv.budget_version_id NOWAIT;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Successfully locked the budget version records';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                          SELECT rtx.resource_assignment_id BULK COLLECT INTO l_rtx_ra_id_tbl
                            FROM pa_resource_asgn_curr rtx
                           WHERE rtx.budget_version_id = l_bv_id
                           FOR UPDATE OF rtx.resource_assignment_id NOWAIT;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Successfully locked the resource assign curr records';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                          SELECT ra.resource_assignment_id BULK COLLECT INTO l_ra_id_tbl
                            FROM pa_resource_assignments ra
                           WHERE ra.budget_version_id = l_bv_id
                           FOR UPDATE OF ra.resource_assignment_id NOWAIT;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Successfully locked the resource assignment records';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                       -- Process each Budget version here
                       -- by rolling up the totals from rejected Budget Line's total
                       -- onto the new entity and RA and BV.
                       /* Bug 5098818 - Start - Replaced exclusive update stmt with a call to maintain_data api */
                       /* populating fp_cols_rec to call the new entity maintenace API */
                       PA_FP_GEN_AMOUNT_UTILS.get_plan_version_dtls
                           (p_budget_version_id              => l_bv_id,
                            x_fp_cols_rec                    => l_fp_cols_rec_var,
                            x_return_status                  => l_return_status,
                            x_msg_count                      => l_msg_count,
                            x_msg_data                       => l_msg_data);

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in PA_FP_GEN_AMOUNT_UTILS.get_plan_version_dtls',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;

                       /* calling the maintenance api to insert data into the new planning transaction level table */
                       PA_RES_ASG_CURRENCY_PUB.maintain_data
                           (p_fp_cols_rec          => l_fp_cols_rec_var,
                            p_calling_module       => 'UPGRADE',
                            p_rollup_flag          => 'Y',
                            p_version_level_flag   => 'Y',
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                            IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.write_file('Upgrade failed due to error in PA_RES_ASG_CURRENCY_PUB.maintain_data',5);
                            END IF;
                            raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                       END IF;
                       /* Bug 5098818 - End - Replaced exclusive update stmt with a call to maintain_data api */

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Updated the resource assign curr amts from budget lines';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                       -- Rollup the totals onto the RA
                       /* Bug 5098818 - Start - Replaced exclusive update stmt with a call to already existing rollup_budget api */

                       PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION(
                            p_budget_version_id      => l_bv_id
                           ,p_entire_version        => 'Y'
                           ,p_context               => NULL
                           ,x_return_status         => l_return_status
                           ,x_msg_count             => l_msg_count
                           ,x_msg_data              => l_msg_data);

                       /* Bug 5098818 - End - Replaced exclusive update stmt with a call to already existing rollup_budget api */
                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Updated the resource assignment amts from resource assign curr';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                       -- Auditing the RA ID records.
                       FORALL i IN l_ra_id_tbl.FIRST..l_ra_id_tbl.LAST
                       -- SAVE EXCEPTIONS
                       INSERT INTO pa_budget_lines_m_upg_dtrange(
                                        LAST_UPDATE_DATE
                                       ,LAST_UPDATED_BY
                                       ,CREATION_DATE
                                       ,CREATED_BY
                                       ,LAST_UPDATE_LOGIN
                                       ,BUDGET_VERSION_ID_RUP
                                       ,RESOURCE_ASSIGNMENT_ID_RUP)
                       VALUES (         sysdate
                                       ,fnd_global.user_id
                                       ,sysdate
                                       ,fnd_global.user_id
                                       ,fnd_global.login_id
                                       ,l_bv_id
                                       ,l_ra_id_tbl(i));

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Audited the resource assignment IDs';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                       -- Sync'ing up the amounts in the PJI model by calling the PJI APIs.
                       -- The business rule is that we should not call the PJI APIs for CO/CR.

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Before calling PJI APIs';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                       IF l_ci_id IS NULL THEN

                           l_budget_ver_tbl.extend;
                           l_budget_ver_tbl(1) := l_bv_id;

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Before calling PJI API PLAN_DELETE for budget ver '||l_bv_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                               PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
                                             p_fp_version_ids   => l_budget_ver_tbl,
                                             x_return_status    => x_return_status,
                                             x_msg_code         => l_error_msg_code);

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'The rtn sts of PJI API PLAN_DELETE is '||x_return_status;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The msg code of PJI API PLAN_DELETE is '||l_error_msg_code;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                               IF (l_return_status <> 'S') THEN
                                   RAISE pa_fp_constants_pkg.Invalid_Arg_Exc;
                               END IF;

                               PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
                                             p_fp_version_ids   => l_budget_ver_tbl,
                                             x_return_status    => x_return_status,
                                             x_msg_code         => l_error_msg_code);

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'The rtn sts of PJI API PLAN_CREATE is '||x_return_status;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The msg code of PJI API PLAN_CREATE is '||l_error_msg_code;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                               IF (l_return_status <> 'S') THEN
                                   RAISE pa_fp_constants_pkg.Invalid_Arg_Exc;
                               END IF;

                       END IF;

                       -- Now Audit the Budget version level record change

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Auditing the budget version ';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The budget version proj fp id is '||l_op_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;


                       pa_fp_upgrade_pkg.Insert_Audit_Record(
                                 p_project_id                     =>   l_project_id
                                ,p_budget_type_code               =>   NULL
                                ,p_proj_fp_options_id             =>   NULL
                                ,p_fin_plan_option_level_code     =>   NULL
                                ,p_basis_cost_version_id          =>   NULL
                                ,p_basis_rev_version_id           =>   NULL
                                ,p_basis_cost_bem                 =>   NULL
                                ,p_basis_rev_bem                  =>   NULL
                                ,p_upgraded_flag                  =>   'Y'
                                ,p_failure_reason_code            =>   NULL
                                ,p_proj_fp_options_id_rup         =>   l_op_id);
                       END IF; /* l_process_flag = 'Y' */
               EXCEPTION
                 WHEN record_locked THEN
                  /* Record was already locked, so audit this version and
                     just keep on going */

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'inside Bdgts loop:Record is locked ';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The proj id is '||l_project_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The proj fp id is '||l_op_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                       rollback to rollup_bl_amounts_to_bv;
                       pa_fp_upgrade_pkg.Insert_Audit_Record(
                                 p_project_id                     =>   l_project_id
                                ,p_budget_type_code               =>   NULL
                                ,p_proj_fp_options_id             =>   NULL
                                ,p_fin_plan_option_level_code     =>   NULL
                                ,p_basis_cost_version_id          =>   NULL
                                ,p_basis_rev_version_id           =>   NULL
                                ,p_basis_cost_bem                 =>   NULL
                                ,p_basis_rev_bem                  =>   NULL
                                ,p_upgraded_flag                  =>   'N'
                                ,p_failure_reason_code            =>   'Record Locked'
                                ,p_proj_fp_options_id_rup         =>   l_op_id);

                  WHEN OTHERS THEN

                       IF p_pa_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'inside Bdgts loop:When others and sqlcode is '||sqlcode;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The proj id is '||l_project_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

                           pa_debug.g_err_stage := 'The proj fp id is '||l_op_id;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                       END IF;

                   rollback to rollup_bl_amounts_to_bv;
                       pa_fp_upgrade_pkg.Insert_Audit_Record(
                                 p_project_id                     =>   l_project_id
                                ,p_budget_type_code               =>   NULL
                                ,p_proj_fp_options_id             =>   NULL
                                ,p_fin_plan_option_level_code     =>   NULL
                                ,p_basis_cost_version_id          =>   NULL
                                ,p_basis_rev_version_id           =>   NULL
                                ,p_basis_cost_bem                 =>   NULL
                                ,p_basis_rev_bem                  =>   NULL
                                ,p_upgraded_flag                  =>   'N'
                                ,p_failure_reason_code            =>   sqlcode
                                ,p_proj_fp_options_id_rup         =>   l_op_id);


                  END;
                          l_rtx_ra_id_tbl.delete;
                          l_ra_id_tbl.delete ;
                          l_budget_ver_tbl.DELETE;
                COMMIT; -- this commits data for each Plan processed

              -- END LOOP;
              -- CLOSE get_fin_plan_versions;
       END LOOP;
       CLOSE get_proj_bv_ids_for_rup;
       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Closed get_proj_bv_ids_for_rup';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage := 'Exiting rollup_rejected_bl_amounts';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       pa_debug.reset_err_stack;
   EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           IF get_proj_bv_ids_for_rup%ISOPEN THEN
               CLOSE get_proj_bv_ids_for_rup;
           END IF;
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
               x_msg_data := l_msg_data;
           END IF;

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           x_return_status:= FND_API.G_RET_STS_ERROR;
           pa_debug.write_file('Rollup_rejected_bl_ampunts : Upgrade has failed for the project: '||l_project_id,5);
           pa_debug.write_file('Rollup_rejected_bl_ampunts : Failure Reason:'||x_msg_data,5);
           pa_debug.reset_err_stack;
           ROLLBACK TO rollup_rejected_bl_amounts;
           RAISE;
      WHEN Others THEN

           IF get_proj_bv_ids_for_rup%ISOPEN THEN
              CLOSE get_proj_bv_ids_for_rup;
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;

           FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                           ,p_procedure_name  => 'Rollup_rejected_bl_ampunts');
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           pa_debug.write_file('Rollup_rejected_bl_ampunts : Upgrade has failed for the project'||l_project_id,5);
           pa_debug.write_file('Upgrade_Budgets : Failure Reason:'||pa_debug.G_Err_Stack,5);
           pa_debug.reset_err_stack;
           ROLLBACK TO rollup_rejected_bl_amounts;
           RAISE;
   END rollup_rejected_bl_amounts;

END pa_fp_upgrade_pkg;

/
