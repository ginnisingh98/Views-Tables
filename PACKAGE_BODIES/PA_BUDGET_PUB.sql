--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_PUB" as
--$Header: PAPMBUPB.pls 120.26.12010000.8 2010/04/20 14:00:53 rthumma ship $

--package global to be used during updates
G_USER_ID         CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID        CONSTANT NUMBER := FND_GLOBAL.login_id;
l_pm_product_code VARCHAR2(2) :='Z'; /*for bug 2413400 a new variable defined.*/

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception   EXCEPTION; /* FPB2 */

g_module_name     VARCHAR2(100) := 'pa.plsql.PA_BUDGET_PUB';


/*new cursor for bug no 2413400*/
Cursor p_product_code_csr (p_pm_product_code IN VARCHAR2)
  Is
  Select 'X'
  from pa_lookups
  where lookup_type='PM_PRODUCT_CODE'
   and lookup_code = p_pm_product_code;

-- Added by Xin Liu 24-APR-03

FUNCTION get_project_id return pa_projects_all.project_id%type
is
BEGIN
  return PA_BUDGET_PUB.G_PROJECT_ID;
END;

PROCEDURE set_project_id (p_project_id IN PA_PROJECTS_ALL.project_id%type) is
BEGIN
  PA_BUDGET_PUB.G_Project_Id := p_project_id;
END;




----------------------------------------------------------------------------------------
--Name:               create_draft_budget
--Type:               Procedure
--Description:        This procedure can be used to create a draft budget with budget lines
--
--
--Called subprograms:   PA_BUDGET_UTILS.create_draft
--          pa_budget_pvt.insert_budget_line
--          pa_budget_lines_v_pkg.check_overlapping_dates
--          PA_BUDGET_UTILS.summerize_project_totals
--                      PA_BUDGET_FUND_PKG.get_budget_ctrl_options
--
--
--
--History:
--    19-SEP-1996        L. de Werker    Created
--    19-NOV-1996    L. de Werker    Changed for use of PA_BUDGET_PVT.INSERT_BUDGET_LINE
--    28-NOV-1996    L. de Werker    Add 16 parameters for descriptive flexfields
--    29-NOV-1996    L. de Werker    Added parameter p_pm_budget_reference
--    05-DEC-1996    L. de Werker    Added validation for change_reason_code
--    07-DEC-1996    L. de Werker    Added locking mechanism, because previous draft budget is deleted
--    12-DEC-1996    L. de Werker    Added update for pm_budget_reference and pm_product_code
--    12-DEC-1996    L. de Werker    Added raising error when working budget is already submitted.
--
--    02-MAY-01         jwhite      As per the Non-Project Budget Ingtegration
--                                      development effort, if budget is enabled for budgetary
--                                      controls, the baseline process will be
--                                      aborted.
--
--    11-FEB-02        Srikanth     Added the changes required for AMG due to finplan model


PROCEDURE create_draft_budget
( p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code               IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code             IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id              IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in               IN  budget_line_in_tbl_type
 ,p_budget_lines_out              OUT NOCOPY budget_line_out_tbl_type

 /*Parameters due fin plan model */
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE
 ,p_raw_cost_flag                 IN   VARCHAR2
 ,p_burdened_cost_flag            IN   VARCHAR2
 ,p_revenue_flag                  IN   VARCHAR2
 ,p_cost_qty_flag                 IN   VARCHAR2
 ,p_revenue_qty_flag              IN   VARCHAR2
 ,P_all_qty_flag                  IN   VARCHAR2
 ,p_create_new_curr_working_flag  IN   VARCHAR2
 ,p_replace_current_working_flag  IN   VARCHAR2
 ,p_using_resource_lists_flag   IN   VARCHAR2
)
      IS

      --Cursor to get the budget version id in the old budget model
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
      AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


      l_budget_version_rec             l_budget_version_csr%ROWTYPE;

      --Cursor to lock the budget version .
      CURSOR l_lock_old_budget_csr( c_budget_version_id NUMBER )
      IS
      SELECT 'x'
      FROM   pa_budget_versions bv
            ,pa_resource_assignments ra
            ,pa_budget_lines bl
      WHERE  bv.budget_version_id = c_budget_version_id
      AND    bv.budget_version_id = ra.budget_version_id (+)
      AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
      AND    bv.ci_id IS NULL         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156
      FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;



      l_api_name           CONSTANT    VARCHAR2(30)        := 'create_draft_budget';
      l_return_status                  VARCHAR2(1);

      l_project_id                     pa_projects_all.project_id%TYPE;
      l_resource_list_id               pa_resource_lists_all_bg.resource_list_id%TYPE;
      l_budget_version_id              pa_budget_versions.budget_version_id%TYPE;
      l_err_code                       NUMBER;
      l_err_stage                      VARCHAR2(120);
      l_err_stack                      VARCHAR2(630);
      i                                NUMBER;
      l_budget_line_in_rec             pa_budget_pub.budget_line_in_rec_type;
      l_budget_entry_method_rec        pa_budget_entry_methods%rowtype;
      l_budget_amount_code             pa_budget_types.budget_amount_code%type;
      l_description                    VARCHAR2(255);
      l_resource_name                  pa_resource_lists_tl.Name%type;
      l_dummy                          VARCHAR2(1);
      l_attribute_category             VARCHAR2(30);
      l_attribute1                     VARCHAR2(150);
      l_attribute2                     VARCHAR2(150);
      l_attribute3                     VARCHAR2(150);
      l_attribute4                     VARCHAR2(150);
      l_attribute5                     VARCHAR2(150);
      l_attribute6                     VARCHAR2(150);
      l_attribute7                     VARCHAR2(150);
      l_attribute8                     VARCHAR2(150);
      l_attribute9                     VARCHAR2(150);
      l_attribute10                    VARCHAR2(150);
      l_attribute11                    VARCHAR2(150);
      l_attribute12                    VARCHAR2(150);
      l_attribute13                    VARCHAR2(150);
      l_attribute14                    VARCHAR2(150);
      l_attribute15                    VARCHAR2(150);
      l_pm_budget_reference            pa_budget_versions.pm_budget_reference%type; --Bug 3231587
      l_change_reason_code             pa_budget_versions.change_reason_code%type;
      l_budget_version_name            VARCHAR2(60);
      l_budget_rlmid                   NUMBER;
      l_budget_alias                   VARCHAR2(80); --bug 3711693

      l_fin_plan_type_id               pa_fin_plan_types_b.fin_plan_type_id%TYPE ;
      l_fin_plan_type_name             pa_fin_plan_types_vl.name%TYPE ;
      l_version_type                   pa_budget_versions.version_type%TYPE ;
      l_fin_plan_level_code            pa_proj_fp_options.cost_fin_plan_level_code%TYPE ;
      l_time_phased_code               pa_proj_fp_options.cost_time_phased_code%TYPE ;
      l_plan_in_multi_curr_flag        pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
      l_projfunc_cost_rate_type        pa_proj_fp_options.projfunc_cost_rate_type%TYPE ;
      l_projfunc_cost_rate_date_typ    pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE ;
      l_projfunc_cost_rate_date        pa_proj_fp_options.projfunc_cost_rate_date%TYPE ;
      l_projfunc_rev_rate_type         pa_proj_fp_options.projfunc_rev_rate_type%TYPE ;
      l_projfunc_rev_rate_date_typ     pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE;
      l_projfunc_rev_rate_date         pa_proj_fp_options.projfunc_rev_rate_date%TYPE ;
      l_project_cost_rate_type         pa_proj_fp_options.project_cost_rate_type%TYPE ;
      l_project_cost_rate_date_typ     pa_proj_fp_options.project_cost_rate_date_type%TYPE  ;
      l_project_cost_rate_date         pa_proj_fp_options.project_cost_rate_date%TYPE ;
      l_project_rev_rate_type          pa_proj_fp_options.project_rev_rate_type%TYPE  ;
      l_project_rev_rate_date_typ      pa_proj_fp_options.project_rev_rate_date_type%TYPE ;
      l_project_rev_rate_date          pa_proj_fp_options.project_rev_rate_date%TYPE ;
      l_raw_cost_flag                  VARCHAR2(1) ;
      l_burdened_cost_flag             VARCHAR2(1);
      l_revenue_flag                   VARCHAR2(1);
      l_cost_qty_flag                  VARCHAR2(1);
      l_revenue_qty_flag               VARCHAR2(1);
      l_all_qty_flag                   VARCHAR2(1);
      l_create_new_working_flag        VARCHAR2(1);
      l_replace_current_working_flag   VARCHAR2(1);
      l_allow_cost_budget_entry_flag   VARCHAR2(1);
      l_allow_rev_budget_entry_flag    VARCHAR2(1);
      p_multiple_task_msg              VARCHAR2(1) := 'T';
      l_resource_list_name             pa_resource_lists_tl.Name%TYPE;
      l_msg_count                      NUMBER := 0;
      l_data                           VARCHAR2(2000);
      l_msg_data                       VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_budget_lines_in                budget_line_in_tbl_type;
      l_allow_qty_flag                 VARCHAR2(1);
      l_uncategorized_res_list_id      pa_resource_list_members.resource_list_id%TYPE;
      l_uncategorized_rlmid            pa_resource_list_members.resource_list_member_id%TYPE;
      l_uncategorized_resid            pa_resource_list_members.resource_id%TYPE;
      l_time_phased_type_code          pa_budget_entry_methods.time_phased_type_code%TYPE;
      l_categorization_code            pa_budget_entry_methods.categorization_code%TYPE;
      l_entry_level_code               pa_budget_entry_methods.entry_level_code%TYPE;
      l_amg_segment1                   pa_projects_all.segment1%TYPE;
      l_finplan_lines_tab              pa_fin_plan_pvt.budget_lines_tab;
      l_unit_of_measure                pa_resources.unit_of_measure%TYPE;
      l_track_as_labor_flag            pa_resource_list_members.track_as_labor_flag%TYPE;
      l_unc_track_as_labor_flag        pa_resource_list_members.track_as_labor_flag%TYPE;
      l_unc_unit_of_measure            pa_resources.unit_of_measure%TYPE;
      l_debug_mode                     VARCHAR2(1);
      l_module_name                    VARCHAR2(80);
      l_debug_level3          CONSTANT NUMBER := 3;
      l_debug_level5          CONSTANT NUMBER := 5;
      j                                NUMBER;
      l_proj_fp_options_id             pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_CW_version_id                  pa_budget_versions.budget_version_id%TYPE;
      l_CW_record_version_number       pa_budget_versions.record_Version_number%TYPE;
      l_user_id                        NUMBER := 0;
      l_resp_id                        NUMBER := 0;
      l_using_resource_lists_flag          VARCHAR2(1);
      l_refresh_required_flag          VARCHAR2(1) := NULL;
      l_request_id                     NUMBER(15)  := NULL;
      l_process_code                   VARCHAR2(30) := NULL;
--      l_fp_type_id                     pa_budget_versions.fin_plan_type_id%TYPE; --3569883
--      l_old_model                      VARCHAR2(1):=null; --3569883

      -- added for bug Bug 3986129: FP.M Web ADI Dev changes
      l_mfc_cost_type_id_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_etc_method_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_spread_curve_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

      l_locked_by_person_id       pa_budget_versions.locked_by_person_id%TYPE;

BEGIN

      --Standard begin of API savepoint
      SAVEPOINT create_draft_budget_pub;
      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name :=  'create_draft_budget' || g_module_name;

      -- Changes for bug 3182963
      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'create_draft_budget',
                                      p_debug_mode => l_debug_mode );
      END IF;



      --  Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( PA_BUDGET_PUB.g_api_version_number ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --dbms_output.put_line('copying input parameters to local variables');

      --Copy the input parametes into the local variables.

      l_resource_list_name            :=   p_resource_list_name           ;

      -- G_MISS_NUM can not fit in l_resource_list_id . Hence make it null
      IF p_resource_list_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
             -- dbms_output.put_line('Copying the miss num to l_resource_list_id');
            l_resource_list_id        :=   NULL;
      ELSE
            l_resource_list_id        :=   p_resource_list_id;
      END IF;

--Check if input parameters is G_PA_MISS_XXX. If true set to NULL
--Changes made by Xin Liu for post_fpk. 24-APR-03

    IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
       l_fin_plan_type_id := NULL;
    ELSE
      l_fin_plan_type_id              :=   p_fin_plan_type_id             ;
    END IF;

    IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_fin_plan_type_name := NULL;
    ELSE
      l_fin_plan_type_name            :=   p_fin_plan_type_name           ;
    END IF;

    IF p_version_type =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_version_type := NULL;
    ELSE
      l_version_type                  :=   p_version_type                 ;
    END IF;

    IF p_fin_plan_level_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_fin_plan_level_code := NULL;
    ELSE
      l_fin_plan_level_code           :=   p_fin_plan_level_code          ;
    END IF;

    IF p_time_phased_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_time_phased_code := NULL;
    ELSE
      l_time_phased_code              :=   p_time_phased_code             ;
    END IF;

    IF p_plan_in_multi_curr_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_plan_in_multi_curr_flag := NULL; --Bug 4586948.
    ELSE
      l_plan_in_multi_curr_flag       :=   p_plan_in_multi_curr_flag      ;
    END IF;

    IF p_projfunc_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_projfunc_cost_rate_type := NULL;
    ELSE
      l_projfunc_cost_rate_type := p_projfunc_cost_rate_type ;
    END IF;

     IF p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_projfunc_cost_rate_date_typ  := NULL;
    ELSE
      l_projfunc_cost_rate_date_typ   :=   p_projfunc_cost_rate_date_typ  ;
    END IF;

    IF p_projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      l_projfunc_cost_rate_date := NULL;
    ELSE
      l_projfunc_cost_rate_date       :=   p_projfunc_cost_rate_date      ;
    END IF;

    IF p_projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_projfunc_rev_rate_type := NULL;
    ELSE
      l_projfunc_rev_rate_type        :=   p_projfunc_rev_rate_type       ;
    END IF;

    IF p_projfunc_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_projfunc_rev_rate_date_typ  := NULL;
    ELSE
      l_projfunc_rev_rate_date_typ    :=   p_projfunc_rev_rate_date_typ   ;
    END IF;

    IF p_projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      l_projfunc_rev_rate_date := NULL;
    ELSE
      l_projfunc_rev_rate_date        :=   p_projfunc_rev_rate_date       ;
    END IF;

    IF p_project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_project_cost_rate_type := NULL;
    ELSE
      l_project_cost_rate_type        :=   p_project_cost_rate_type       ;
    END IF;

    IF p_project_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_project_cost_rate_date_typ  := NULL;
    ELSE
      l_project_cost_rate_date_typ    :=   p_project_cost_rate_date_typ   ;
    END IF;

    IF p_project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      l_project_cost_rate_date := NULL;
    ELSE
      l_project_cost_rate_date        :=   p_project_cost_rate_date       ;
    END IF;

    IF p_project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_project_rev_rate_type := NULL;
    ELSE
      l_project_rev_rate_type         :=   p_project_rev_rate_type        ;
    END IF;

    IF p_project_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_project_rev_rate_date_typ  := NULL;
    ELSE
      l_project_rev_rate_date_typ     :=   p_project_rev_rate_date_typ    ;
    END IF;

    IF p_project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      l_project_rev_rate_date := NULL;
    ELSE
      l_project_rev_rate_date         :=   p_project_rev_rate_date        ;
    END IF;

    IF p_raw_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_raw_cost_flag  := 'N';
    ELSE
      l_raw_cost_flag                 :=   p_raw_cost_flag                ;
    END IF;

    IF p_burdened_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_burdened_cost_flag  := 'N';
    ELSE
      l_burdened_cost_flag            :=   p_burdened_cost_flag           ;
    END IF;

    IF p_revenue_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_revenue_flag  := 'N';
    ELSE
      l_revenue_flag                  :=   p_revenue_flag                 ;
    END IF;

    IF p_cost_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_cost_qty_flag  := 'N';
    ELSE
      l_cost_qty_flag                 :=   p_cost_qty_flag                ;
    END IF;

    IF p_revenue_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_revenue_qty_flag  := 'N';
    ELSE
      l_revenue_qty_flag              :=   p_revenue_qty_flag             ;
    END IF;

    IF p_all_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_all_qty_flag  := 'N';
    ELSE
      l_all_qty_flag                  :=   p_all_qty_flag                 ;
    END IF;

    IF p_create_new_curr_working_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_create_new_working_flag  := 'N';
    ELSE
      l_create_new_working_flag       :=   p_create_new_curr_working_flag ;
    END IF;

    IF p_replace_current_working_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_replace_current_working_flag  := 'N';
    ELSE
      l_replace_current_working_flag  :=   p_replace_current_working_flag ;
    END IF;

    IF p_using_resource_lists_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_using_resource_lists_flag  := 'Y';
    ELSE
      l_using_resource_lists_flag  :=   p_using_resource_lists_flag ;
    END IF;


      -- G_MISS_NUM can not fit in l_project_id . Hence make it null
      IF p_pa_project_id= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
      --dbms_output.put_line('Copying the miss num to l_project_id');
            l_project_id                :=   NULL;
      ELSE
            l_project_id                :=   p_pa_project_id;
      END IF;
      --Get the user id and responsibility Ids
      l_user_id := FND_GLOBAL.User_id;
      l_resp_id := FND_GLOBAL.Resp_id;

      -- This api will initialize the data that will be used by the map_new_amg_msg.
      -- Commented out the procedure call as required by Venkatesh. 25-APR-03
   /*
        PA_INTERFACE_UTILS_PUB.Set_Global_Info
        ( p_api_version_number => 1.0
         ,p_responsibility_id  => l_resp_id
         ,p_user_id            => l_user_id
         ,p_calling_mode       => 'AMG'     --bug 2783845
         ,p_msg_count          => p_msg_count
         ,p_msg_data           => p_msg_data
         ,p_return_status      => p_return_status);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
   */

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'About to call validate header info';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --Call the api that validates the input information
      pa_budget_pvt.Validate_Header_Info
      ( p_api_version_number           => p_api_version_number
      /* Bug 3133930- parameter included to pass version name */
      ,p_budget_version_name           => p_budget_version_name
      ,p_init_msg_list                 => p_init_msg_list
      ,px_pa_project_id                => l_project_id
      ,p_pm_project_reference          => p_pm_project_reference
      ,p_pm_product_code               => p_pm_product_code
      ,p_budget_type_code              => p_budget_type_code
      ,p_entry_method_code             => p_entry_method_code
      ,px_resource_list_name           => l_resource_list_name
      ,px_resource_list_id             => l_resource_list_id
      ,px_fin_plan_type_id             => l_fin_plan_type_id
      ,px_fin_plan_type_name           => l_fin_plan_type_name
      ,px_version_type                 => l_version_type
      ,px_fin_plan_level_code          => l_fin_plan_level_code
      ,px_time_phased_code             => l_time_phased_code
      ,px_plan_in_multi_curr_flag      => l_plan_in_multi_curr_flag
      ,px_projfunc_cost_rate_type      => l_projfunc_cost_rate_type
      ,px_projfunc_cost_rate_date_typ  => l_projfunc_cost_rate_date_typ
      ,px_projfunc_cost_rate_date      => l_projfunc_cost_rate_date
      ,px_projfunc_rev_rate_type       => l_projfunc_rev_rate_type
      ,px_projfunc_rev_rate_date_typ   => l_projfunc_rev_rate_date_typ
      ,px_projfunc_rev_rate_date       => l_projfunc_rev_rate_date
      ,px_project_cost_rate_type       => l_project_cost_rate_type
      ,px_project_cost_rate_date_typ   => l_project_cost_rate_date_typ
      ,px_project_cost_rate_date       => l_project_cost_rate_date
      ,px_project_rev_rate_type        => l_project_rev_rate_type
      ,px_project_rev_rate_date_typ    => l_project_rev_rate_date_typ
      ,px_project_rev_rate_date        => l_project_rev_rate_date
      ,px_raw_cost_flag                => l_raw_cost_flag
      ,px_burdened_cost_flag           => l_burdened_cost_flag
      ,px_revenue_flag                 => l_revenue_flag
      ,px_cost_qty_flag                => l_cost_qty_flag
      ,px_revenue_qty_flag             => l_revenue_qty_flag
      ,px_all_qty_flag                 => l_all_qty_flag
      ,p_create_new_curr_working_flag  => l_create_new_working_flag
      ,p_replace_current_working_flag  => l_replace_current_working_flag
      ,p_change_reason_code            => p_change_reason_code
      ,p_calling_module                => 'PA_PM_CREATE_DRAFT_BUDGET'
      ,p_using_resource_lists_flag     => p_using_resource_lists_flag
      ,x_budget_amount_code            => l_budget_amount_code   -- Added for bug 4224464
      ,x_msg_count                     => p_msg_count
      ,x_msg_data                      => p_msg_data
      ,x_return_status                 => p_return_status);

      IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Validate Header got executed successfully';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      -- Copy the input pl/sql table to a local pl/sql table. This is necessary since the
      -- input table is a IN variable and hence read only.
      l_budget_lines_in := p_budget_lines_in;


      -- Budget type code and budget entry method,project id should be valid at this point
      -- Hence exception handling is not done

      IF (p_budget_type_code IS NOT NULL AND
           p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

            SELECT  budget_amount_code
            INTO    l_budget_amount_code
            FROM    pa_budget_types
            WHERE   budget_type_code = p_budget_type_code;

            SELECT time_phased_type_code
                  ,categorization_code
                  ,entry_level_code
            INTO   l_time_phased_type_code
                  ,l_categorization_code
                  ,l_entry_level_code
            FROM   pa_budget_entry_methods
            WHERE  budget_entry_method_code = p_entry_method_code
            AND    trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

      END IF;

      SELECT segment1
      INTO   l_amg_segment1
      FROM   pa_projects_all
      WHERE  project_id=l_project_id;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Got the budget type details and segment1 of the project';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;


/* After bug fix for bug 4052562, note that the below API returns UOM from rlm table as DOLLARS instead of
 * pa_resources table. Due to this, the below api may not be suitable for usage
 * for old budgets model which retrieves UOM from pa_resources (HOURS). As such,
 * since UOM is not used in create_draft_budget api FOR OLD BUDGETS MODEL, reusing
 * the below api for both old and new budget model resource lists. If for some
 * reason in future, UOM of uncatrlm is to be used even for old budgets model,
 * we should consider using pa_get_resource.get_uncateg_Resource_info. Not
 * changing it now, since, pa_get_resource.get_uncateg_resource_info owned by RF
 * team, as of now, has the same performance issue of full table scans on RLM
 * and pa_resources tables.  */
      --Get the uncategorized resource list info.
      pa_fin_plan_utils.Get_Uncat_Resource_List_Info
        (x_resource_list_id           => l_uncategorized_res_list_id,
         x_resource_list_member_id    => l_uncategorized_rlmid,
         x_track_as_labor_flag        => l_unc_track_as_labor_flag,
         x_unit_of_measure            => l_unc_unit_of_measure,
         x_return_status              => p_return_status,
         x_msg_count                  => p_msg_count,
         x_msg_data                   => p_msg_data     );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      --  RAISE  FND_API.G_EXC_ERROR;
      END IF; -- IF l_err_code <> 0 THEN

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Got the uncategorized res list info';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --Added by Xin Liu for supporting Project Connect 4.0
      --5/6/2003

      If l_using_resource_lists_flag = 'N' THEN

       l_resource_list_id :=l_uncategorized_res_list_id;

      END IF;

      --When description is not passed, set value to NULL

      IF p_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_description := NULL;
      ELSE
            l_description := p_description;
      END IF;

      /*   -- dbms_output.put_line('Before setting flex fields to NULL, when not passed'); */

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


      IF p_pm_budget_reference =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_pm_budget_reference := NULL;
      ELSE
            l_pm_budget_reference := p_pm_budget_reference;
      END IF;

      IF p_budget_version_name =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_budget_version_name := NULL;
      ELSE
            l_budget_version_name := p_budget_version_name;
      END IF;

      IF p_change_reason_code =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            l_change_reason_code := NULL;
      ELSE
            l_change_reason_code := p_change_reason_code;
      END IF;


      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Done with the initialisation of flex fields, dexcription, etc';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;


      IF p_budget_type_code IS NOT NULL AND
         p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

            -- Lock the existing working version.
            OPEN l_budget_version_csr( l_project_id, p_budget_type_code );
            FETCH l_budget_version_csr INTO l_budget_version_rec;
            IF l_budget_version_csr%FOUND THEN

                  OPEN l_lock_old_budget_csr( l_budget_version_rec.budget_Version_id );
                  CLOSE l_lock_old_budget_csr;                --FYI, does not release locks

            END IF;
            CLOSE l_budget_version_csr;

/* It is assumed that if the program reaches till this point,then there are no budget lines with errors in the out plsql table*/

            --Call the api that creates the draft budget
            PA_BUDGET_UTILS.create_draft
            (x_project_id                 => l_project_id
            ,x_budget_type_code           => p_budget_type_code
            ,x_version_name               => l_budget_version_name
            ,x_description                => l_description
            ,x_resource_list_id           => l_resource_list_id
            ,x_change_reason_code         => l_change_reason_code
            ,x_budget_entry_method_code   => p_entry_method_code
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
            ,x_budget_version_id          => l_budget_version_id
            ,x_err_code                   => l_err_code
            ,x_err_stage                  => l_err_stage
            ,x_err_stack                  => l_err_stack
            ,x_pm_product_code            => p_pm_product_code
            ,x_pm_budget_reference        => l_pm_budget_reference );

           -----------
            -- temporary solution
            -- COMMIT in DELETE_DRAFT removes all savepoints!!!

            SAVEPOINT create_draft_budget_pub;
            -----------

            IF l_err_code > 0
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN

                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_CREATE_DRAFT_FAILED'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'BUDG'
                               ,p_attribute1       => l_amg_segment1
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
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => p_budget_type_code
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                        END IF;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Error executing create draft';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN

                  FND_MSG_PUB.add_exc_msg
                      (  p_pkg_name       => 'PA_BUDGET_UTILS'
                      ,  p_procedure_name => 'CREATE_DRAFT'
                      ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'SQL Error executing create draft';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Created the version in the budget model';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            -- Commenting out this select as the create draft now returns the id of hte
            -- newly created version
            -- SELECT pa_budget_versions_s.currval  --because x_budget_version_id in procedure
            -- INTO   l_budget_version_id        --PA_BUDGET_UTILS.create_draft returns nothing: BUG.
            -- FROM   SYS.DUAL;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Created version is is '|| l_budget_version_id ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                  pa_debug.g_err_stage := 'About to call validate budget lines';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            --Validate the budget lines.
            IF ( nvl(l_budget_lines_in.last,0) > 0 ) THEN

            --Added by Xin Liu. Handle G_MISS_XXX for l_budget_lines_in before calling Validate_Budget_Lines.
            FOR i in l_budget_lines_in.FIRST..l_budget_lines_in.LAST LOOP

                             IF l_budget_lines_in(i).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).pa_task_id   :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).pm_task_reference =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).pm_task_reference  :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_alias= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).resource_alias :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_list_member_id =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).resource_list_member_id:=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).budget_start_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_start_date:=  NULL;
                              END IF;
                             IF l_budget_lines_in(i).budget_end_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_end_date:=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                        l_budget_lines_in(i).period_name := NULL;
                              END IF;

                        IF l_budget_lines_in(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).raw_cost   :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).burdened_cost  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).revenue  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).quantity  := NULL;
                              END IF;


                              IF l_budget_lines_in(i).change_reason_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).change_reason_code  :=NULL;
                              END IF;

                              IF l_budget_lines_in(i).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).description     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute_category     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute1     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute2     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute3     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute4     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute5     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute6     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute7     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute8     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute9     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute10     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute11     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute12     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute13     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute14     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute15     :=  NULL;
                              END IF;

                        IF l_budget_lines_in(i).txn_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                            l_budget_lines_in(i).txn_currency_code := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE     := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_budget_lines_in(i).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                               l_budget_lines_in(i).PROJFUNC_REV_RATE_TYPE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_budget_lines_in(i).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                        END IF;

                        IF  l_budget_lines_in(i).project_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_TYPE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE      THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_DATE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_budget_lines_in(i).PROJECT_COST_EXCHANGE_RATE  := NULL;
                        END IF;

                        IF  l_budget_lines_in(i).project_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_TYPE       := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_DATE       := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_budget_lines_in(i).PROJECT_REV_EXCHANGE_RATE   := NULL;
                        END IF;

                                /* Bug 3218822 - Use the validated pm_product_code of the header for the budget line if
                                   pm_product_code is passed as Null at the line level */

                        IF l_budget_lines_in(i).pm_product_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
                        l_budget_lines_in(i).pm_product_code IS NULL THEN
                                l_budget_lines_in(i).pm_product_code := p_pm_product_code;
                                END IF;

                        IF l_budget_lines_in(i).pm_budget_line_reference=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).pm_budget_line_reference    := NULL;
                        END IF;


            END LOOP;
/** Bug 3709462
                --3569883 start
              select fin_plan_type_id
              into l_fp_type_id
              from pa_budget_versions
             where budget_version_id = l_budget_version_id;

                select DECODE(l_fp_type_id, null, 'Y','N') into l_old_model from dual;
                --3569883 end
**/            -- Bug 3709462 we are in old model context no additional checks are necessary
--               l_old_model := 'Y';
               --Done with Changes by xin liu
                  pa_budget_pvt.Validate_Budget_Lines
                        ( p_pa_project_id              => l_project_id
                        ,p_budget_type_code            => p_budget_type_code
                        ,p_fin_plan_type_id            => NULL
                        ,p_version_type                => NULL
                        ,p_resource_list_id            => l_resource_list_id
                        ,p_time_phased_code            => l_time_phased_type_code
                        ,p_budget_entry_method_code    => p_entry_method_code
                        ,p_entry_level_code            => l_entry_level_code
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
                        ,px_budget_lines_in            => l_budget_lines_in
                        ,x_budget_lines_out            => p_budget_lines_out /* Bug 3133930*/
--                        ,x_old_model                   => l_old_model --3569883
                        ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                        ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                        ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                        ,x_msg_count                   => p_msg_count
                        ,x_msg_data                    => p_msg_data
                        ,x_return_status               => p_return_status);

                  IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                         RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Validate Budget Lines got executed successfully';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

            END IF;--IF ( nvl(l_budget_lines_in.last,0) > 0 ) THEN




    /*
        -- Not necessary now since the same is passed as parameters to create_draft
        --add the pm_budget_reference and pm_product_code to the just created budget
        UPDATE pa_budget_versions
        SET pm_budget_reference = p_pm_budget_reference
        ,   pm_product_code      = p_pm_product_code
        WHERE budget_version_id = l_budget_version_id;
    */


    -- BUDGET LINES

            i := l_budget_lines_in.first;

            IF l_budget_lines_in.exists(i)
            THEN

                  <<budget_line>>
                  WHILE i IS NOT NULL LOOP

                        /* initialize return status for budget line to success */

                        /* Bug 3133930 initialization is removed here as it has been done in
                        validate_budget_lines */
                        /* p_budget_lines_out(i).return_status     := FND_API.G_RET_STS_SUCCESS; */

                        l_budget_line_in_rec := l_budget_lines_in(i);
                        IF l_budget_line_in_rec.pm_budget_line_reference =
                                       PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_line_in_rec.pm_budget_line_reference := NULL;
                        END IF;

                        IF l_categorization_code = 'N' THEN
                              l_budget_rlmid := l_uncategorized_rlmid;
                              l_budget_alias := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                        ELSE
                              l_budget_rlmid := l_budget_line_in_rec.resource_list_member_id;
                              l_budget_alias := l_budget_line_in_rec.resource_alias;
                        END IF;

                        /* For bug # 675869 Fix */
                        IF l_budget_line_in_rec.period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_line_in_rec.period_name := NULL;
                        END IF;
                        /* End Of bug # 675869 Fix */


                        --Call the api that inserts the budget line
                        pa_budget_pvt.insert_budget_line
                        ( p_return_status           => l_return_status
                        ,p_pa_project_id            => l_project_id
                        ,p_budget_type_code         => p_budget_type_code
                        ,p_pa_task_id               => l_budget_line_in_rec.pa_task_id
                        ,p_pm_task_reference        => l_budget_line_in_rec.pm_task_reference
                        ,p_resource_alias           => l_budget_alias
                        ,p_member_id                => l_budget_rlmid
                        ,p_budget_start_date        => l_budget_line_in_rec.budget_start_date
                        ,p_budget_end_date          => l_budget_line_in_rec.budget_end_date
                        ,p_period_name              => l_budget_line_in_rec.period_name
                        ,p_description              => l_budget_line_in_rec.description
                        ,p_raw_cost                 => l_budget_line_in_rec.raw_cost
                        ,p_burdened_cost            => l_budget_line_in_rec.burdened_cost
                        ,p_revenue                  => l_budget_line_in_rec.revenue
                        ,p_quantity                 => l_budget_line_in_rec.quantity
                        ,p_pm_product_code          => l_budget_line_in_rec.pm_product_code
                        ,p_pm_budget_line_reference => l_budget_line_in_rec.pm_budget_line_reference
                        ,p_resource_list_id         => l_resource_list_id
                        ,p_attribute_category       => l_budget_line_in_rec.attribute_category
                        ,p_attribute1               => l_budget_line_in_rec.attribute1
                        ,p_attribute2               => l_budget_line_in_rec.attribute2
                        ,p_attribute3               => l_budget_line_in_rec.attribute3
                        ,p_attribute4               => l_budget_line_in_rec.attribute4
                        ,p_attribute5               => l_budget_line_in_rec.attribute5
                        ,p_attribute6               => l_budget_line_in_rec.attribute6
                        ,p_attribute7               => l_budget_line_in_rec.attribute7
                        ,p_attribute8               => l_budget_line_in_rec.attribute8
                        ,p_attribute9               => l_budget_line_in_rec.attribute9
                        ,p_attribute10              => l_budget_line_in_rec.attribute10
                        ,p_attribute11              => l_budget_line_in_rec.attribute11
                        ,p_attribute12              => l_budget_line_in_rec.attribute12
                        ,p_attribute13              => l_budget_line_in_rec.attribute13
                        ,p_attribute14              => l_budget_line_in_rec.attribute14
                        ,p_attribute15              => l_budget_line_in_rec.attribute15
                        ,p_time_phased_type_code    => l_time_phased_type_code
                        ,p_entry_level_code         => l_entry_level_code
                        ,p_budget_amount_code       => l_budget_amount_code
                        ,p_budget_entry_method_code => p_entry_method_code
                        ,p_categorization_code      => l_categorization_code
                        ,p_budget_version_id        => l_budget_version_id  );
                        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
                        THEN
                              p_budget_lines_out(i).return_status := l_return_status;

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Unexpected Error inserting line '||i;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                        THEN
                              p_budget_lines_out(i).return_status := l_return_status;
                              p_multiple_task_msg   := 'F';
                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Error inserting line '||i;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;

                              --        RAISE  FND_API.G_EXC_ERROR;

                        END IF;

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Done with the insertion of line '||i;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;


                        i := l_budget_lines_in.next(i);

                  END LOOP budget_line;

                  IF p_multiple_task_msg = 'F'
                  THEN
                        RAISE  FND_API.G_EXC_ERROR;
                  END IF;

            END IF;

      ELSE--Create a version in the finplan model

            IF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN

                  l_allow_qty_flag := p_cost_qty_flag;

            ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN

                  l_allow_qty_flag := p_revenue_qty_flag;

            ELSE

                  l_allow_qty_flag :=  P_all_qty_flag;

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'l_allow_qty_flag is  '||l_allow_qty_flag;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            --Call the api only if budget lines exist
             -- dbms_output.put_line('l_budget_lines_in.last '||l_budget_lines_in.last);
            IF ( nvl(l_budget_lines_in.last,0) > 0 ) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to call validate budget lines in finplan model';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

            --Added by Xin Liu. Handle G_MISS_XXX for l_budget_lines_in before calling Validate_Budget_Lines.
            FOR i in l_budget_lines_in.FIRST..l_budget_lines_in.LAST LOOP

                             IF l_budget_lines_in(i).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).pa_task_id   :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).pm_task_reference =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).pm_task_reference  :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_alias= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).resource_alias :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_list_member_id =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).resource_list_member_id:=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).budget_start_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_start_date:=  NULL;
                              END IF;
                             IF l_budget_lines_in(i).budget_end_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_end_date:=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                        l_budget_lines_in(i).period_name := NULL;
                              END IF;

                        IF l_budget_lines_in(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).raw_cost   :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).burdened_cost  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).revenue  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).quantity  := NULL;
                              END IF;


                              IF l_budget_lines_in(i).change_reason_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).change_reason_code  :=NULL;
                              END IF;

                              IF l_budget_lines_in(i).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).description     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute_category     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute1     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute2     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute3     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute4     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute5     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute6     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute7     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute8     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute9     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute10     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute11     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute12     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute13     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute14     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute15     :=  NULL;
                              END IF;

                        IF l_budget_lines_in(i).txn_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                            l_budget_lines_in(i).txn_currency_code := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE     := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_budget_lines_in(i).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                               l_budget_lines_in(i).PROJFUNC_REV_RATE_TYPE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_budget_lines_in(i).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                        END IF;

                        IF  l_budget_lines_in(i).project_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_TYPE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_DATE_TYPE := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE      THEN
                        l_budget_lines_in(i).PROJECT_COST_RATE_DATE      := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_budget_lines_in(i).PROJECT_COST_EXCHANGE_RATE  := NULL;
                        END IF;

                        IF  l_budget_lines_in(i).project_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_TYPE       := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_budget_lines_in(i).PROJECT_REV_RATE_DATE       := NULL;
                        END IF;

                        IF  l_budget_lines_in(i).project_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_budget_lines_in(i).PROJECT_REV_EXCHANGE_RATE   := NULL;
                        END IF;

                                /* Bug 3218822 - Use the validated pm_product_code of the header for the budget line if
                                   pm_product_code is passed as Null at the line level */

                        IF l_budget_lines_in(i).pm_product_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
                                l_budget_lines_in(i).pm_product_code IS NULL THEN
                                l_budget_lines_in(i).pm_product_code := p_pm_product_code;
                        END IF;

                        IF l_budget_lines_in(i).pm_budget_line_reference=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_budget_lines_in(i).pm_budget_line_reference    := NULL;
                        END IF;


            END LOOP;
                  --Done with Changes by xin liu
/** Bug 3709462
                  --3569883 start
                  select fin_plan_type_id
                  into l_fp_type_id
                  from pa_budget_versions
                  where budget_version_id = l_budget_version_id;

                  select DECODE(l_fp_type_id, null, 'Y','N') into l_old_model from dual;
                  --3569883 end
**/
                  -- Bug 3709462 We are in new model context, no new checks are necessary
--                  l_old_model := 'N';
                  --Validate the finplan lines passed
                  pa_budget_pvt.Validate_Budget_Lines
                  ( p_pa_project_id              => l_project_id
                  ,p_budget_type_code            => NULL
                  ,p_fin_plan_type_id            => l_fin_plan_type_id
                  ,p_version_type                => l_version_type
                  ,p_resource_list_id            => l_resource_list_id
                  ,p_time_phased_code            => l_time_phased_code
                  ,p_budget_entry_method_code    => NULL
                  ,p_entry_level_code            => l_fin_plan_level_code
                  ,p_allow_qty_flag              => l_allow_qty_flag
                  ,p_allow_raw_cost_flag         => p_raw_cost_flag
                  ,p_allow_burdened_cost_flag    => p_burdened_cost_flag
                  ,p_allow_revenue_flag          => p_revenue_flag
                  ,p_multi_currency_flag         => l_plan_in_multi_curr_flag
                  ,p_project_cost_rate_type      => l_project_cost_rate_type
                  ,p_project_cost_rate_date_typ  => l_project_cost_rate_date_typ
                  ,p_project_cost_rate_date      => l_project_cost_rate_date
                  ,p_project_cost_exchange_rate  => NULL
                  ,p_projfunc_cost_rate_type     => l_projfunc_cost_rate_type
                  ,p_projfunc_cost_rate_date_typ => l_projfunc_cost_rate_date_typ
                  ,p_projfunc_cost_rate_date     => l_projfunc_cost_rate_date
                  ,p_projfunc_cost_exchange_rate => NULL
                  ,p_project_rev_rate_type       => l_project_rev_rate_type
                  ,p_project_rev_rate_date_typ   => l_project_rev_rate_date_typ
                  ,p_project_rev_rate_date       => l_project_rev_rate_date
                  ,p_project_rev_exchange_rate   => NULL
                  ,p_projfunc_rev_rate_type      => l_projfunc_rev_rate_type
                  ,p_projfunc_rev_rate_date_typ  => l_projfunc_rev_rate_date_typ
                  ,p_projfunc_rev_rate_date      => l_projfunc_rev_rate_date
                  ,p_projfunc_rev_exchange_rate  => NULL
                  ,px_budget_lines_in            => l_budget_lines_in
                  ,x_budget_lines_out            => p_budget_lines_out /* Bug 3133930*/
--                  ,x_old_model                   => l_old_model --3569883
                  ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                  ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                  ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                  ,x_msg_count                   => p_msg_count
                  ,x_msg_data                    => p_msg_data
                  ,x_return_status               => p_return_status);

                  IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Validate budget lines got executed successfully';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  -- Initialise the index for the fin plan lines table
                  j :=1;

                  -- Intilalise the UOM and track as labor flag to the values associated with
                  -- the uncategorized resource list.
                  l_unit_of_measure := l_unc_unit_of_measure;
                  l_track_as_labor_flag := l_unc_track_as_labor_flag;

                  --dbms_output.put_line('l_budget_lines_in.FIRST '||l_budget_lines_in.FIRST);
                  --dbms_output.put_line('l_budget_lines_in.LAST '||l_budget_lines_in.LAST);

                  -- Copy the fin plan lines into a table of type pa_fp_rollup_tmp
                  FOR i in l_budget_lines_in.FIRST..l_budget_lines_in.LAST LOOP

                       --dbms_output.put_line('In the for loop');

                        IF l_budget_lines_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_lines_in(i).period_name := NULL;
                        END IF;

                        --Lines should be processed only if atleast one of the amounts exist
                         -- Commenting out the below check for 8423481. In SelfService, we do not have this check
                     /*  IF (nvl(l_budget_lines_in(i).quantity,0)<>0 OR
                            nvl(l_budget_lines_in(i).raw_cost,0)<>0 OR
                            nvl(l_budget_lines_in(i).burdened_cost,0)<>0 OR
                            nvl(l_budget_lines_in(i).revenue,0) <>0) THEN
*/

                              -- Get UOM and track as labor flag only if the resource list is not uncategorized
                              -- If it is is uncategorized then we can make use of the uom and track as labor
                              -- flag obtained earlier
                              IF (l_resource_list_id <> l_uncategorized_res_list_id) THEN
                                    -- Bug 3807633.. We can directly fetch UOM from pa_resource_list_members
                                    -- for FINPLAN MODEL(FP.M Changes) as old non-migrated resource
                                    -- list cannot be used and only New and Migrated resource
                                    -- list can be used for FINPLAN Model.
                                    SELECT prlm.unit_of_measure
                                    INTO   l_unit_of_measure
                                    FROM   pa_resource_list_members prlm
                                    WHERE  prlm.resource_list_member_id = l_budget_lines_in(i).resource_list_member_id;

                              END IF;

                              --dbms_output.put_line('copying from budget to rollup finplan');

                              -- Convert flex field attributes to NULL if they have Miss Char as value

                              l_finplan_lines_tab(j).system_reference1           :=  l_budget_lines_in(i).pa_task_id;
                              l_finplan_lines_tab(j).system_reference2           :=  l_budget_lines_in(i).resource_list_member_id         ;
                              l_finplan_lines_tab(j).start_date                  :=  l_budget_lines_in(i).budget_start_date;
                              l_finplan_lines_tab(j).end_date                    :=  l_budget_lines_in(i).budget_end_date;
                              l_finplan_lines_tab(j).period_name                 :=  l_budget_lines_in(i).period_name;
                              l_finplan_lines_tab(j).system_reference4           :=  l_unit_of_measure     ;
                              --  l_finplan_lines_tab(j).system_reference5           :=  l_track_as_labor_flag  ;
                              l_finplan_lines_tab(j).system_reference5           :=  NULL; -- 3807633 track_as_labor_flag not mantained in FPM changes
                              l_finplan_lines_tab(j).txn_currency_code           :=  l_budget_lines_in(i).txn_currency_code               ;
                              l_finplan_lines_tab(j).projfunc_raw_cost           :=  NULL;
                              l_finplan_lines_tab(j).projfunc_burdened_cost      :=  NULL;
                              l_finplan_lines_tab(j).projfunc_revenue            :=  NULL;
                              l_finplan_lines_tab(j).project_raw_cost            :=  NULL ;
                              l_finplan_lines_tab(j).project_burdened_cost       :=  NULL;
                              l_finplan_lines_tab(j).project_revenue             :=  NULL;

                              IF l_budget_lines_in(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_finplan_lines_tab(j).txn_raw_cost   :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).txn_raw_cost   :=  l_budget_lines_in(i).raw_cost          ;
                              END IF;

                              IF l_budget_lines_in(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_finplan_lines_tab(j).txn_burdened_cost  := NULL;
                              ELSE
                                    l_finplan_lines_tab(j).txn_burdened_cost  := l_budget_lines_in(i).burdened_cost;
                              END IF;

                              IF l_budget_lines_in(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_finplan_lines_tab(j).txn_revenue  := NULL;
                              ELSE
                                    l_finplan_lines_tab(j).txn_revenue  := l_budget_lines_in(i).revenue;
                              END IF;

                              IF l_budget_lines_in(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_finplan_lines_tab(j).quantity  := NULL;
                              ELSE
                                    l_finplan_lines_tab(j).quantity  := l_budget_lines_in(i).quantity;
                              END IF;


                              IF l_budget_lines_in(i).change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).change_reason_code  :=NULL;
                              ELSE
                                    l_finplan_lines_tab(j).change_reason_code  :=  l_budget_lines_in(i).change_reason_code ;
                              END IF;

                              IF l_budget_lines_in(i).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).description     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).description     :=  l_budget_lines_in(i).description;
                              END IF;

                              IF l_budget_lines_in(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute_category     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute_category     :=  l_budget_lines_in(i).attribute_category;
                              END IF;

                              IF l_budget_lines_in(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute1     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute1     :=  l_budget_lines_in(i).attribute1;
                              END IF;

                              IF l_budget_lines_in(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute2     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute2     :=  l_budget_lines_in(i).attribute2;
                              END IF;

                              IF l_budget_lines_in(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute3     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute3     :=  l_budget_lines_in(i).attribute3;
                              END IF;

                              IF l_budget_lines_in(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute4     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute4     :=  l_budget_lines_in(i).attribute4;
                              END IF;

                              IF l_budget_lines_in(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute5     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute5     :=  l_budget_lines_in(i).attribute5;
                              END IF;

                              IF l_budget_lines_in(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute6     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute6     :=  l_budget_lines_in(i).attribute6;
                              END IF;

                              IF l_budget_lines_in(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute7     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute7     :=  l_budget_lines_in(i).attribute7;
                              END IF;

                              IF l_budget_lines_in(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute8     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute8     :=  l_budget_lines_in(i).attribute8;
                              END IF;

                              IF l_budget_lines_in(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute9     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute9     :=  l_budget_lines_in(i).attribute9;
                              END IF;

                              IF l_budget_lines_in(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute10     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute10     :=  l_budget_lines_in(i).attribute10;
                              END IF;

                              IF l_budget_lines_in(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute11     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute11     :=  l_budget_lines_in(i).attribute11;
                              END IF;

                              IF l_budget_lines_in(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute12     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute12     :=  l_budget_lines_in(i).attribute12;
                              END IF;

                              IF l_budget_lines_in(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute13     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute13     :=  l_budget_lines_in(i).attribute13;
                              END IF;

                              IF l_budget_lines_in(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute14     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute14     :=  l_budget_lines_in(i).attribute14;
                              END IF;

                              IF l_budget_lines_in(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_finplan_lines_tab(j).attribute15     :=  NULL;
                              ELSE
                                    l_finplan_lines_tab(j).attribute15     :=  l_budget_lines_in(i).attribute15;
                              END IF;

            -- Added by Xin Liu

                        IF l_budget_lines_in(i).projfunc_cost_rate_type =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE     :=  l_budget_lines_in(i).projfunc_cost_rate_type            ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE :=l_budget_lines_in(i).projfunc_cost_rate_date_type      ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     :=  l_budget_lines_in(i).projfunc_cost_rate_date            ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE :=  l_budget_lines_in(i).projfunc_cost_exchange_rate        ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                               l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      :=  l_budget_lines_in(i).projfunc_rev_rate_type             ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE :=  l_budget_lines_in(i).projfunc_rev_rate_date_type        ;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      :=  l_budget_lines_in(i).projfunc_rev_rate_date;
                        END IF;

                        IF l_budget_lines_in(i).projfunc_rev_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  :=  l_budget_lines_in(i).projfunc_rev_exchange_rate         ;
                        END IF;

                        IF  l_budget_lines_in(i).project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      :=  l_budget_lines_in(i).project_cost_rate_type;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE :=  l_budget_lines_in(i).project_cost_rate_date_type        ;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE    THEN
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      :=  l_budget_lines_in(i).project_cost_rate_date             ;
                        END IF;

                        IF l_budget_lines_in(i).project_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  :=  l_budget_lines_in(i).project_cost_exchange_rate ;
                        END IF;

                        IF  l_budget_lines_in(i).project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       := NULL;
                        ELSE
                               l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       :=  l_budget_lines_in(i).project_rev_rate_type              ;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                        l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  :=  l_budget_lines_in(i).project_rev_rate_date_type         ;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  THEN
                        l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       :=  l_budget_lines_in(i).project_rev_rate_date              ;
                        END IF;

                        IF l_budget_lines_in(i).project_rev_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                        l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   := NULL;
                        ELSE
                        l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   :=  l_budget_lines_in(i).project_rev_exchange_rate          ;
                        END IF;

                                /* Bug 3218822 - Use the validated pm_product_code of the header for the budget line if
                                   pm_product_code is passed as Null at the line level */

                        IF l_budget_lines_in(i).pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
                                l_budget_lines_in(i).pm_product_code IS NULL THEN
                        l_finplan_lines_tab(j).pm_product_code             :=  p_pm_product_code      ;
                        ELSE
                        l_finplan_lines_tab(j).pm_product_code             :=  l_budget_lines_in(i).pm_product_code      ;
                        END IF;

                        IF l_budget_lines_in(i).pm_budget_line_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_finplan_lines_tab(j).pm_budget_line_reference    := NULL;
                        ELSE
                        l_finplan_lines_tab(j).pm_budget_line_reference    :=  l_budget_lines_in(i).pm_budget_line_reference        ;
                        END IF;
            -- Done with Changes.
                        l_finplan_lines_tab(j).quantity_source             :=  'I'          ;
                              l_finplan_lines_tab(j).raw_cost_source             :=  'I'         ;
                              l_finplan_lines_tab(j).burdened_cost_source        :=  'I'         ;
                              l_finplan_lines_tab(j).revenue_source              :=  'I'         ;
                              l_finplan_lines_tab(j).resource_assignment_id      :=  -1          ;

                              --increment the index for fin plan lines table
                              j := j+1;

                    --    END IF;--IF (nvl(l_budget_lines_in(i).quantity,0)<>0 OR

                  END LOOP;--Loop for copying fin plan lines into table of type rollup temp

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Done with the copying of budget lines to fin plan lines';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to call the create draft api in fin plan pvt';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            -- If either of the create , replace current working version flags are Y then lock the
            -- Current working version.

            IF (p_replace_current_working_flag = 'Y' OR
                       p_create_new_curr_working_flag = 'Y')  THEN
                  --Get the current working version info
                   pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                         p_project_id            => l_project_id
                        ,p_fin_plan_type_id      => l_fin_plan_type_id
                        ,p_version_type          => l_version_type
                        ,x_fp_options_id         => l_proj_fp_options_id
                        ,x_fin_plan_version_id   => l_CW_version_id
                        ,x_return_status         => p_return_status
                        ,x_msg_count             => p_msg_count
                        ,x_msg_data              => p_msg_data );

                  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  IF l_CW_version_id IS NOT NULL THEN

-- Bug # 3507156 : Patchset M: B and F impact changes : AMG
-- Commented the call to PA_FP_REFRESH_ELEMENTS_PUB.GET_REFRESH_PLAN_ELE_DTLS
-- Comment START
/*
                    --Added by Xin Liu
                    --Check if the current working version is locked for WBS refresh or not
                  PA_FP_REFRESH_ELEMENTS_PUB.GET_REFRESH_PLAN_ELE_DTLS
                                                      (
                                                         p_budget_version_id      => l_CW_version_id
                                                       , p_proj_fp_options_id     => NULL
                                                       , x_refresh_required_flag  => l_refresh_required_flag
                                                       , x_request_id             => l_request_id
                                                       , x_process_code           => l_process_code
                                                       , x_return_status          => p_return_status
                                                       , x_msg_count              => p_msg_count
                                                       , x_msg_data               => p_msg_data
                                                       );

                  IF p_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Error executing get refresh plan ele dtls';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                        END IF;

                     IF ( NVL(l_refresh_required_flag, 'N')  = 'Y' ) THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Plan version must be refreshed for new plannable-task state.';
                                    pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                              END IF;

                  pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_FP_AMG_WBS_IN_PROC_MSG'
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'Y'
                              ,p_msg_context      => 'GENERAL'
                              ,p_attribute1       => ''
                              ,p_attribute2       => ''
                              ,p_attribute3       => ''
                              ,p_attribute4       => ''
                              ,p_attribute5       => '');

                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                        END IF;

                    --End changes done by Xin Liu for WBS refresh
*/
-- Comment END
-- Bug # 3507156 : Patchset M: B and F impact changes : AMG

                        select locked_by_person_id
                        into l_locked_by_person_id from pa_budget_versions
                         where budget_version_id = l_CW_version_id;

                        --Get the record version number of the current working version
                        l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                        pa_fin_plan_pvt.lock_unlock_version
                              (p_budget_version_id      => l_CW_version_id,
                              p_record_version_number   => l_CW_record_version_number,
                              p_action                  => 'L',
                              p_user_id                 => l_user_id,
                              p_person_id               => NULL,
                              x_return_status           => p_return_status,
                              x_msg_count               => p_msg_count,
                              x_msg_data                => p_msg_data) ;

                        IF p_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Error executing lock unlock version';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                        END IF;

                  END IF;--IF l_CW_version_id IS NOT NULL THEN

            END IF;--IF (p_replace_current_working_flag = 'Y' OR

            --Call the api that creates the fin plan version
            PA_FIN_PLAN_PVT.CREATE_DRAFT(
            p_project_id                   => l_project_id
            ,p_fin_plan_type_id             => l_fin_plan_type_id
            ,p_version_type                 => l_version_type
            ,p_calling_context              => PA_FP_CONSTANTS_PKG.G_AMG_API--Bug 4224464.Changed this to AMG_API as this is a AMG flow.
            ,p_time_phased_code             => l_time_phased_code
            ,p_resource_list_id             => l_resource_list_id
            ,p_fin_plan_level_code          => l_fin_plan_level_code
            ,p_plan_in_mc_flag              => l_plan_in_multi_curr_flag
            ,p_version_name                 => l_budget_version_name
            ,p_description                  => l_description
            ,p_change_reason_code           => l_change_reason_code
            ,p_raw_cost_flag                => l_raw_cost_flag
            ,p_burdened_cost_flag           => l_burdened_cost_flag
            ,p_revenue_flag                 => l_revenue_flag
            ,p_cost_qty_flag                => l_cost_qty_flag
            ,p_revenue_qty_flag             => l_revenue_qty_flag
            ,p_all_qty_flag                 => l_all_qty_flag
            ,p_attribute_category           => l_attribute_category
            ,p_attribute1                   => l_attribute1
            ,p_attribute2                   => l_attribute2
            ,p_attribute3                   => l_attribute3
            ,p_attribute4                   => l_attribute4
            ,p_attribute5                   => l_attribute5
            ,p_attribute6                   => l_attribute6
            ,p_attribute7                   => l_attribute7
            ,p_attribute8                   => l_attribute8
            ,p_attribute9                   => l_attribute9
            ,p_attribute10                  => l_attribute10
            ,p_attribute11                  => l_attribute11
            ,p_attribute12                  => l_attribute12
            ,p_attribute13                  => l_attribute13
            ,p_attribute14                  => l_attribute14
            ,p_attribute15                  => l_attribute15
            ,p_projfunc_cost_rate_type      => l_projfunc_cost_rate_type
            ,p_projfunc_cost_rate_date_type => l_projfunc_cost_rate_date_typ
            ,p_projfunc_cost_rate_date      => l_projfunc_cost_rate_date
            ,p_projfunc_rev_rate_type       => l_projfunc_rev_rate_type
            ,p_projfunc_rev_rate_date_type  => l_projfunc_rev_rate_date_typ
            ,p_projfunc_rev_rate_date       => l_projfunc_rev_rate_date
            ,p_project_cost_rate_type       => l_project_cost_rate_type
            ,p_project_cost_rate_date_type  => l_project_cost_rate_date_typ
            ,p_project_cost_rate_date       => l_project_cost_rate_date
            ,p_project_rev_rate_type        => l_project_rev_rate_type
            ,p_project_rev_rate_date_type   => l_project_rev_rate_date_typ
            ,p_project_rev_rate_date        => l_project_rev_rate_date
            ,p_pm_product_code              => p_pm_product_code
             ,p_pm_budget_reference          => l_pm_budget_reference -- p_pm_project_reference changed to budget reference for bug 3858543
            ,p_budget_lines_tab             => l_finplan_lines_tab
            -- Start of additional columns for B
            ,p_ci_id                        => NULL
            ,p_est_proj_raw_cost            => NULL
            ,p_est_proj_bd_cost             => NULL
            ,p_est_proj_revenue             => NULL
            ,p_est_qty                      => NULL
            ,p_impacted_task_id             => NULL
            ,p_agreement_id                 => NULL
            -- End of additional columns for Bug
            ,p_create_new_curr_working_flag => l_create_new_working_flag
            ,p_replace_current_working_flag => l_replace_current_working_flag
            ,x_budget_version_id            => l_budget_version_id
            ,x_return_status                => p_return_status
            ,x_msg_count                    => p_msg_count
            ,x_msg_data                     => p_msg_data);


            IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                  RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

       -- Added for Bug #4680197 Unlock the budget version incase is it locked in this create_draft api.
         IF p_create_new_curr_working_flag = 'Y'
             AND p_replace_current_working_flag <> 'Y' --Bug 8617706
             AND l_CW_version_id IS NOT NULL
             AND l_locked_by_person_id IS NULL THEN
                     --Get the record version number of the current working version
                     l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);
                     pa_fin_plan_pvt.lock_unlock_version
                           (p_budget_version_id      => l_CW_version_id,
                           p_record_version_number   => l_CW_record_version_number,
                           p_action                  => 'U',
                           p_user_id                 => l_user_id,
                           p_person_id               => NULL,
                           x_return_status           => p_return_status,
                           x_msg_count               => p_msg_count,
                           x_msg_data                => p_msg_data) ;

                     IF p_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                           IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage := 'Error executing lock unlock version';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
         END IF;
         --Changes ended  for Bug #4680197


            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Succesfully executed the fin plan pvt create draft ';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;



      END IF;--IF p_budget_type_code IS NOT NULL

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'About to check the overlapping dates';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      -- check for overlapping dates
      pa_budget_lines_v_pkg.check_overlapping_dates( x_budget_version_id  => l_budget_version_id
                              ,x_resource_name  => l_resource_name
                              ,x_err_code       => l_err_code       );

      IF l_err_code > 0
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                  FND_MESSAGE.SET_NAME('PA','PA_CHECK_DATES_FAILED');
                  FND_MESSAGE.SET_TOKEN('RNAME',l_resource_name);

                  FND_MSG_PUB.add;
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Error executing check_overlapping_dates';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;


            RAISE FND_API.G_EXC_ERROR;

      ELSIF l_err_code < 0
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN

                  FND_MSG_PUB.add_exc_msg
                  (  p_pkg_name       => 'PA_BUDGET_LINES_V_PKG'
                  ,  p_procedure_name => 'CHECK_OVERLAPPING_DATES'
                  ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Unexpected Error executing check_overlapping_dates';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

--Bug # 3507156 : Patchset M: B and F impact changes : AMG
--Added a call to PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS to get the return statuses of the input budget lines.

            PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS(
                          p_fin_plan_version_id            =>   l_budget_version_id
                         ,p_budget_lines_in                 =>   l_budget_lines_in          /* Bug # 3589304 */
                         ,x_fp_lines_retn_status_tab        =>   p_budget_lines_out
                         ,x_return_status                   =>   p_return_status
                         ,x_msg_count                       =>   p_msg_count
                         ,x_msg_data                        =>   p_msg_data );


            IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS got executed successfully';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;


      --summarizing the totals in the table pa_budget_versions

      /*Summarizing of totals should be done only in the buget model*/
      IF (p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR and p_budget_type_code IS NOT NULL) THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to summarize totals in budget model';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            pa_budget_utils.summerize_project_totals( x_budget_version_id => l_budget_version_id
                                , x_err_code      => l_err_code
                            , x_err_stage     => l_err_stage
                            , x_err_stack     => l_err_stack        );


            IF l_err_code > 0
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN

                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'BUDG'
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => p_budget_type_code
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                        else
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => l_err_stage
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'BUDG'
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => p_budget_type_code
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                        end IF;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Error in  summarizing totals in budget model';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN

                        FND_MSG_PUB.add_exc_msg
                            (  p_pkg_name       => 'PA_BUDGET_UTILS'
                            ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
                            ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Unexpected Error in  summarizing totals in budget model';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;


      END IF;


      IF FND_API.TO_BOOLEAN( p_commit )
      THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to do a COMMIT';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            COMMIT;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Leaving create draft budget';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --Changes for bug 3182963
      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;


EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
             -- dbms_output.put_line('MSG count in the stack ' || FND_MSG_PUB.count_msg);
            ROLLBACK TO create_draft_budget_pub;

            IF p_return_status IS NULL OR
               p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
                  p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            l_msg_count := FND_MSG_PUB.count_msg;
             -- dbms_output.put_line('MSG count in the stack ' || l_msg_count);

            IF l_msg_count = 1 AND p_msg_data IS NULL THEN
                   PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out);

                   p_msg_data  := l_data;
                   p_msg_count := l_msg_count;
            ELSE
                   p_msg_count := l_msg_count;
            END IF;

          IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
            END IF;

             -- dbms_output.put_line('MSG count in the stack ' || l_msg_count);

            RETURN;

    WHEN FND_API.G_EXC_ERROR
    THEN

/*   -- dbms_output.put_line('handling an G_EXC_ERROR exception in create_draft_budget'); */

            ROLLBACK TO create_draft_budget_pub;

            p_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );
          --Changes for bug 3182963
          IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
            END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

/*   -- dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception in create_draft_budget'); */

            ROLLBACK TO create_draft_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

          --Changes for bug 3182963
          IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
            END IF;


    WHEN ROW_ALREADY_LOCKED
    THEN
    ROLLBACK TO create_draft_budget_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
      FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
      FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
      FND_MESSAGE.SET_TOKEN('TASK',    '');
      FND_MESSAGE.SET_TOKEN('BUDGET_TYPE', p_budget_type_code);
      FND_MESSAGE.SET_TOKEN('SOURCE_NAME', '');
      FND_MESSAGE.SET_TOKEN('START_DATE', '');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'G_BUDGET_CODE');
      FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

          --Changes for bug 3182963
          IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
            END IF;


    WHEN OTHERS
    THEN

/*   -- dbms_output.put_line('handling an OTHERS exception'); */

            ROLLBACK TO create_draft_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
            FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

            END IF;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

          --Changes for bug 3182963
          IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
            END IF;


END create_draft_budget;



----------------------------------------------------------------------------------------
--Name:               init_budget
--Type:               Procedure
--Description:        This procedure can be used to initialize the global PL/SQL
--            tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--
--Called subprograms:
--
--
--
--History:
--    20-SEP-1996        L. de Werker    Created
--
--
PROCEDURE init_budget

IS

BEGIN

    FND_MSG_PUB.Initialize;

--  Initialize global table and record types

    G_budget_lines_in_tbl.delete;

    G_budget_lines_tbl_count := 0;

    G_budget_lines_out_tbl.delete;


END init_budget;


----------------------------------------------------------------------------------------
--Name:               load_budget_line
--Type:               Procedure
--Description:        This procedure can be used to load a budget line
--                    in a global PL/SQL table.
--
--Called subprograms:
--
--
--
--History:
--    24-SEP-1996        L. de Werker    Created
--    28-NOV-1996        L. de Werker    Add 16 parameters for descriptive flexfields
--    11-Mar-2003        Srikanth        Included the parameters for Fin Plan Model

PROCEDURE load_budget_line
( p_api_version_number          IN  NUMBER
 ,p_commit              IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_task_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_pm_product_code          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_pm_budget_line_reference IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --Parameters for fin plan model

 --Changes the default of the following parameters from NULL to G_PA_MISS_XXX 24-APR-03 by Xin Liu
 ,p_txn_currency_code             IN  pa_fp_txn_currencies.txn_currency_code%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_type  IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_type   IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_type   IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_type    IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_change_reason_code            IN  pa_budget_lines.change_reason_code%TYPE
:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 )

IS

   l_api_name               CONSTANT    VARCHAR2(30)        := 'load_budget_line';
   l_return_status                  VARCHAR2(1);
   l_err_stage                      VARCHAR2(120);
   l_msg_entity                     VARCHAR2(100);
   l_msg_entity_index                   NUMBER;


BEGIN

--  Standard begin of API savepoint

    SAVEPOINT load_budget_line_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

--  assign a value to the global counter for this table
    G_budget_lines_tbl_count := G_budget_lines_tbl_count + 1;


--  assign incoming parameters to the fields of pl/sql global table G_budget_lines_in_tbl
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).pa_task_id          := p_pa_task_id;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).pm_task_reference       := p_pm_task_reference;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).resource_alias      := p_resource_alias;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).resource_list_member_id := p_resource_list_member_id;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).budget_start_date       := p_budget_start_date;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).budget_end_date     := p_budget_end_date;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).period_name         := p_period_name;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).description         := p_description;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).raw_cost            := p_raw_cost;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).burdened_cost       := p_burdened_cost;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).revenue         := p_revenue;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).quantity            := p_quantity;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).pm_product_code
:= p_pm_product_code;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).pm_budget_line_reference
:= p_pm_budget_line_reference;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute_category      := p_attribute_category;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute1
:= p_attribute1;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute2
:= p_attribute2;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute3
:= p_attribute3;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute4
:= p_attribute4;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute5
:= p_attribute5;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute6
:= p_attribute6;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute7
:= p_attribute7;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute8
:= p_attribute8;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute9
:= p_attribute9;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute10
:= p_attribute10;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute11
:= p_attribute11;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute12
:= p_attribute12;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute13
:= p_attribute13;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute14
:= p_attribute14;
    G_budget_lines_in_tbl(G_budget_lines_tbl_count).attribute15
:= p_attribute15;

-- The parameters included for fin plan model
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).txn_currency_code             :=  p_txn_currency_code            ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_cost_rate_type       :=  p_projfunc_cost_rate_type      ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_cost_rate_date_type  :=  p_projfunc_cost_rate_date_type ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_cost_rate_date       :=  p_projfunc_cost_rate_date      ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_cost_exchange_rate   :=  p_projfunc_cost_exchange_rate  ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_rev_rate_type        :=  p_projfunc_rev_rate_type       ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_rev_rate_date_type   :=  p_projfunc_rev_rate_date_type  ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_rev_rate_date        :=  p_projfunc_rev_rate_date        ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).projfunc_rev_exchange_rate    :=  p_projfunc_rev_exchange_rate   ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_cost_rate_type        :=  p_project_cost_rate_type       ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_cost_rate_date_type   :=  p_project_cost_rate_date_type  ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_cost_rate_date        :=  p_project_cost_rate_date       ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_cost_exchange_rate    :=  p_project_cost_exchange_rate   ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_rev_rate_type         :=  p_project_rev_rate_type        ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_rev_rate_date_type    :=  p_project_rev_rate_date_type   ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_rev_rate_date         :=  p_project_rev_rate_date        ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).project_rev_exchange_rate     :=  p_project_rev_exchange_rate    ;
   G_budget_lines_in_tbl(G_budget_lines_tbl_count).change_reason_code            :=  p_change_reason_code           ;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
    ROLLBACK TO load_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
    ROLLBACK TO load_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
    ROLLBACK TO load_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

    END IF;

END load_budget_line;

----------------------------------------------------------------------------------------
--Name:               execute_create_draft_budget
--Type:               Procedure
--Description:        This procedure can be used to create a draft budget
--                    using global PL/SQL tables.
--
--Called subprograms:
--
--
--
--History:
--    23-SEP-1996        L. de Werker    Created
--    28-NOV-1996    L. de Werker    Add 16 parameters for descriptive flexfields
--    29-NOV-1996    L. de Werker    Added parameter p_pm_budget_reference
--    01-sep-2004    tpalaniv        Added parameter  p_pm_budget_reference while calling create_draft_budget
PROCEDURE execute_create_draft_budget
( p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --Added the following parameters for changes in AMG due to finplan model
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE
 ,p_raw_cost_flag                 IN   VARCHAR2
 ,p_burdened_cost_flag            IN   VARCHAR2
 ,p_revenue_flag                  IN   VARCHAR2
 ,p_cost_qty_flag                 IN   VARCHAR2
 ,p_revenue_qty_flag              IN   VARCHAR2
 ,P_all_qty_flag                  IN   VARCHAR2
 ,p_create_new_curr_working_flag  IN   VARCHAR2
 ,p_replace_current_working_flag  IN   VARCHAR2
 ,p_using_resource_lists_flag   IN   VARCHAR2
 )


IS

   l_api_name               CONSTANT    VARCHAR2(30)        := 'execute_create_draft_budget';
   i                            NUMBER;
   l_return_status                  VARCHAR2(1);
   l_err_stage                      VARCHAR2(120);


BEGIN

--  Standard begin of API savepoint

    SAVEPOINT execute_create_budget_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    create_draft_budget
            ( p_api_version_number          => p_api_version_number
             ,p_commit                      => FND_API.G_FALSE
             ,p_init_msg_list               => FND_API.G_FALSE
             ,p_msg_count                   => p_msg_count
             ,p_msg_data                    => p_msg_data
             ,p_return_status               => l_return_status
             ,p_pm_product_code             => p_pm_product_code
             ,p_budget_version_name         => p_budget_version_name
             ,p_pa_project_id               => p_pa_project_id
             ,p_pm_project_reference        => p_pm_project_reference
           ,p_pm_budget_reference         => p_pm_budget_reference  -- Added for bug 3858543
             ,p_budget_type_code            => p_budget_type_code
             ,p_change_reason_code          => p_change_reason_code
             ,p_description                 => p_description
             ,p_entry_method_code           => p_entry_method_code
             ,p_resource_list_name          => p_resource_list_name
             ,p_resource_list_id            => p_resource_list_id
             ,p_attribute_category          => p_attribute_category
             ,p_attribute1                  => p_attribute1
             ,p_attribute2                  => p_attribute2
             ,p_attribute3                  => p_attribute3
             ,p_attribute4                  => p_attribute4
             ,p_attribute5                  => p_attribute5
             ,p_attribute6                  => p_attribute6
             ,p_attribute7                  => p_attribute7
             ,p_attribute8                  => p_attribute8
             ,p_attribute9                  => p_attribute9
             ,p_attribute10                 => p_attribute10
             ,p_attribute11                 => p_attribute11
             ,p_attribute12                 => p_attribute12
             ,p_attribute13                 => p_attribute13
             ,p_attribute14                 => p_attribute14
             ,p_attribute15                 => p_attribute15
             ,p_budget_lines_in             => G_budget_lines_in_tbl
             ,p_budget_lines_out            => G_budget_lines_out_tbl

             --New parameters for finplan model
             ,p_fin_plan_type_id            => p_fin_plan_type_id
             ,p_fin_plan_type_name          => p_fin_plan_type_name
             ,p_version_type                => p_version_type
             ,p_fin_plan_level_code         => p_fin_plan_level_code
             ,p_time_phased_code            => p_time_phased_code
             ,p_plan_in_multi_curr_flag     => p_plan_in_multi_curr_flag
             ,p_projfunc_cost_rate_type     => p_projfunc_cost_rate_type
             ,p_projfunc_cost_rate_date_typ => p_projfunc_cost_rate_date_typ
             ,p_projfunc_cost_rate_date     => p_projfunc_cost_rate_date
             ,p_projfunc_rev_rate_type      => p_projfunc_rev_rate_type
             ,p_projfunc_rev_rate_date_typ  => p_projfunc_rev_rate_date_typ
             ,p_projfunc_rev_rate_date      => p_projfunc_rev_rate_date
             ,p_project_cost_rate_type      => p_project_cost_rate_type
             ,p_project_cost_rate_date_typ  => p_project_cost_rate_date_typ
             ,p_project_cost_rate_date      => p_project_cost_rate_date
             ,p_project_rev_rate_type       => p_project_rev_rate_type
             ,p_project_rev_rate_date_typ   => p_project_rev_rate_date_typ
             ,p_project_rev_rate_date       => p_project_rev_rate_date
             ,p_raw_cost_flag               => p_raw_cost_flag
             ,p_burdened_cost_flag          => p_burdened_cost_flag
             ,p_revenue_flag                => p_revenue_flag
             ,p_cost_qty_flag               => p_cost_qty_flag
             ,p_revenue_qty_flag            => p_revenue_qty_flag
             ,P_all_qty_flag                => P_all_qty_flag
             ,p_create_new_curr_working_flag=> p_create_new_curr_working_flag
             ,p_replace_current_working_flag=> p_replace_current_working_flag
           ,p_using_resource_lists_flag   => p_using_resource_lists_flag);


-- Temporary solution because of commit in delete_budget!!!!

   SAVEPOINT execute_create_budget_pub;

/*   -- dbms_output.put_line('Return status create_draft_budget: '||l_return_status); */

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT;
        END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN


        ROLLBACK TO execute_create_budget_pub;

        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_count     =>  p_msg_count ,
            p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

/*   -- dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    ROLLBACK TO execute_create_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );

    WHEN OTHERS THEN


    ROLLBACK TO execute_create_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

    END IF;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );

END execute_create_draft_budget;


----------------------------------------------------------------------------------------
--Name:               fetch_budget_line
--Type:               Procedure
--Description:        This procedure can be used to fetch the outcoming
--            parameters for budget lines as part of the LOAD/EXECUTE/FETCH cycle.
--
--
--Called subprograms:
--
--
--
--History:
--    30-SEP-1996        L. de Werker    Created
--
--
PROCEDURE fetch_budget_line
( p_api_version_number      IN  NUMBER
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_line_index          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_line_return_status      OUT NOCOPY VARCHAR2                    ) --File.Sql.39 bug 4440895

IS

   l_api_name           CONSTANT    VARCHAR2(30)        := 'fetch_budget_line';
   l_index                  NUMBER;
   i                        NUMBER;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT fetch_budget_line_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check budget line index value,
-- when they don't provide an index we will error out

IF p_line_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
OR p_line_index IS NULL
THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
         pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_BUGDET_LINE_INDEX_MISSING'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'Y'
           ,p_msg_context      => 'GENERAL'
           ,p_attribute1       => ''
           ,p_attribute2       => ''
           ,p_attribute3       => ''
           ,p_attribute4       => ''
           ,p_attribute5       => '');
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
ELSE
    l_index := p_line_index;
END IF;

--assign global table fields to the outgoing parameter
p_line_return_status        := G_budget_lines_out_tbl(l_index).return_status;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN

    ROLLBACK TO fetch_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

    ROLLBACK TO fetch_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

    ROLLBACK TO fetch_budget_line_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

    END IF;


END fetch_budget_line;

----------------------------------------------------------------------------------------
--Name:               clear_budget
--Type:               Procedure
--Description:        This procedure can be used to clear the global PL/SQL
--            tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--
--Called subprograms:
--
--
--
--History:
--    23-SEP-1996        L. de Werker    Created
--
--
PROCEDURE clear_budget

IS

BEGIN


   init_budget;


END clear_budget;


----------------------------------------------------------------------------------------
--Name:               Baseline_Budget
--Type:               Procedure
--Description:        This procedure can be used to baseline
--            a budget for a given project.
--
--
--Called subprograms: pa_budget_core.verify
--            pa_budget_core.baseline
--                    PA_BUDGET_FUND_PKG.get_budget_ctrl_options
--
--
--
--History:
--    30-SEP-1996       L. de Werker    Created
--    03-DEC-1996   L. de Werker    Added check for previous baselined budgets.
--    03-MAR-1997   L. de Werker    Added workflow enabling
--    24-JUN-97     jwhite      Workflow had been commented-out, renabled it
--                  as per latest specifications.
--    21-JUL-97     jwhite      Added Check_Baseline_Rules procedure
--                  to validations section.
--    29-JUL-97     jwhite      Radically changed validations and WF implementation
--                  as per new specs from jlowell.
--    12-AUG-97     jwhite      Added new OUT-parameter, p_workflow_started
--                  as per workflow implementation.
--    08-SEP-97     jwhite      Updated to latest specifications: added
--                  wrappers for Start_Budget_WF and
--                  Budget_WF_Is_Used, new parameters to
--                  Verify_Budget_Rules calls, etc.
--    11-SEP-97     jwhite      Added new concept of  warnings_only ('W')
--                  for the p_return_status with respect
--                  to the Verify_Budget_Rules calls.
--
--    02-MAY-01         jwhite      As per the Non-Project Budget Ingtegration
--                                      development effort,  if budget is enabled for budgetary
--                                      controls, the baseline process will be
--                                      aborted.
--    02-FEB-03        sgoteti     Made changes for the finplan model


PROCEDURE Baseline_Budget
( p_api_version_number        IN    NUMBER
 ,p_commit                    IN    VARCHAR2          := FND_API.G_FALSE
 ,p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE
 ,p_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_workflow_started          OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference      IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_mark_as_original          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 --Parameters due to Fin Plan Model
 ,p_fin_plan_type_id          IN    pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name        IN    pa_fin_plan_types_tl.name%TYPE
 ,p_version_type              IN    pa_budget_versions.version_type%TYPE)

IS

      CURSOR l_budget_types_csr
             (p_budget_type_code    VARCHAR2 )
      IS
      SELECT 1
      FROM   pa_budget_types
      WHERE  budget_type_code = p_budget_type_code;

      -- Changed the cursor so that it can be used in both old budget model
      -- and finplan model
      CURSOR l_budget_lines_csr
             (p_budget_version_id NUMBER )
      IS
      SELECT 1
      FROM   pa_budget_lines
      WHERE  budget_version_id = p_budget_version_id;

--8423481
      CURSOR l_resource_assignments_csr
             ( p_budget_version_id NUMBER )
      IS
      SELECT 1
      FROM pa_resource_assignments
      WHERE budget_version_id = p_budget_version_id;

      CURSOR l_budget_versions_csr
             (c_project_id       NUMBER
             ,c_budget_type_code VARCHAR2)

      IS
      SELECT budget_version_id
      FROM   pa_budget_versions
      WHERE  project_id   = c_project_id
      AND    budget_type_code       = c_budget_type_code
      AND    budget_status_code     = 'W'
      AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


      l_budget_versions_rec              l_budget_versions_csr%ROWTYPE;


      CURSOR l_baselined_csr
            ( c_project_id       NUMBER
             ,c_budget_type_code VARCHAR2 )

      IS
      SELECT budget_version_id
      FROM   pa_budget_versions
      WHERE  project_id             = c_project_id
      AND    budget_type_code = c_budget_type_code
      AND    budget_status_code     = 'B'
      AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


      l_baselined_rec                    l_baselined_csr%ROWTYPE;


      -- 01-AUG-97, jwhite
      -- Cursor for Verify_Budget_Rules

      CURSOR l_budget_rules_csr(p_draft_version_id NUMBER)
      IS
      SELECT v.resource_list_id,
             t.project_type_class_code
      FROM   pa_project_types t,
             pa_projects p,
             pa_budget_versions v
      WHERE  v.budget_version_id = p_draft_version_id
      AND    v.project_id = p.project_id
      AND    p.project_type = t.project_type
      AND    v.ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause v.ci_id IS NULL--Bug # 3507156



      -- 24-JUN-97, jwhite
      -- ROW LOCKING ---------------------------------------------------------------

      CURSOR l_lock_budget_csr (p_budget_version_id NUMBER)
      IS
      SELECT 'x'
      FROM   pa_budget_versions
      WHERE  budget_version_id = p_budget_version_id
      AND    ci_id IS NULL         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156
      FOR UPDATE NOWAIT;

      -- --------------------------------------------------------------------------------------



      l_api_name              CONSTANT    VARCHAR2(30)            := 'baseline_budget';
      l_return_status                     VARCHAR2(1);
      l_project_id                        NUMBER;

      l_budget_version_id                 NUMBER;
      l_mark_as_original                  pa_budget_versions.current_original_flag%TYPE;

      l_err_code                          NUMBER;
      l_err_stage                         VARCHAR2(120);
      l_err_stack                         VARCHAR2(630);
      i                                   NUMBER;
      l_row_found                         NUMBER;
      l_msg_count                         NUMBER ;
      l_msg_data                          VARCHAR2(2000);
      l_function_allowed                  VARCHAR2(1);
      l_resp_id                           NUMBER := 0;
      l_user_id                           NUMBER := 0;
      l_module_name                       VARCHAR2(80);

      l_workflow_is_used                  VARCHAR2(1) := NULL;
      l_resource_list_id                  NUMBER;
      l_project_type_class_code           pa_project_types.project_type_class_code%TYPE;

      l_warnings_only_flag                VARCHAR2(1) := 'Y';
      l_err_msg_count                     NUMBER      := 0;

      --needed to get the field values associated to a AMG message

      CURSOR l_amg_project_csr
          (p_pa_project_id pa_projects.project_id%type)
      IS
      SELECT segment1
      FROM   pa_projects p
      WHERE  p.project_id = p_pa_project_id;

      l_amg_segment1                      VARCHAR2(25);

      -- Needed to check whether the plan type id passed is attached to the project or Not
      CURSOR l_plan_type_option_csr
             (c_project_id          pa_projects_all.project_id%TYPE,
              c_fin_plan_type_id    pa_proj_fp_options.proj_fp_options_id%TYPE)
      IS
      SELECT 'X'
      FROM   pa_proj_fp_options pfo
      WHERE  pfo.project_id=c_project_id
      AND    pfo.fin_plan_type_id=c_fin_plan_type_id
      AND    pfo.fin_plan_option_level_code=PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

      -- Needed to get the version id and record version number of the original baselined version
      CURSOR l_orig_baselined_ver_csr
             (c_project_id        pa_projects_all.project_id%TYPE,
              c_fin_plan_type_id  pa_budget_versions.fin_plan_type_id%TYPE,
              c_version_type      pa_budget_versions.version_type%TYPE)
      IS
      SELECT budget_version_id
            ,record_version_number
      FROM   pa_budget_versions
      WHERE  project_id=c_project_id
      AND    fin_plan_type_id=c_fin_plan_type_id
      AND    version_type=c_version_type
      AND    current_original_flag='Y'
      AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


      l_orig_baselined_ver_rec            l_orig_baselined_ver_csr%ROWTYPE;


      -- Budget Integration Variables --------------------------

      l_fck_req_flag                      VARCHAR2(1) := NULL;
      l_bdgt_intg_flag                    VARCHAR2(1) := NULL;
      l_bdgt_ver_id                       NUMBER := NULL;
      l_encum_type_id                     NUMBER := NULL;
      l_balance_type                      VARCHAR2(1) := NULL;

      -- --------------------------------------------------------
      l_fin_plan_type_id                  pa_fin_plan_types_b.fin_plan_type_id%TYPE;
      l_debug_mode                        VARCHAR2(1);
      l_debug_level2             CONSTANT NUMBER := 2;
      l_debug_level3             CONSTANT NUMBER := 3;
      l_debug_level4             CONSTANT NUMBER := 4;
      l_debug_level5             CONSTANT NUMBER := 5;
      l_version_type                      pa_budget_Versions.version_type%TYPE;
      l_security_ret_code                 VARCHAR2(1);
      l_baselined_Ver_options_id          pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_baselined_version_id              pa_budget_Versions.budget_version_id%TYPE;
      l_CW_ver_options_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_curr_working_version_id           pa_budget_Versions.budget_version_id%TYPE;
      l_CB_record_version_number          pa_budget_Versions.record_version_number%TYPE;
      l_CW_record_version_number          pa_budget_Versions.record_version_number%TYPE;
      l_any_error_occurred_flag           VARCHAR2(1);
      l_data                              VARCHAR2(2000);
      l_msg_index_out                     NUMBER;
      l_dummy                             VARCHAR2(1);
      l_fin_plan_type_name                pa_fin_plan_types_tl.name%TYPE;
      l_result                            VARCHAR2(1);
      ll_fin_plan_type_id                  pa_fin_plan_types_b.fin_plan_type_id%TYPE;
      ll_fin_plan_type_name                pa_fin_plan_types_tl.name%TYPE;
      l_fc_version_created_flag            VARCHAR2(1);
      l_final_plan_prc_code                VARCHAR2(10);
      l_targ_request_id                pa_budget_versions.request_id%TYPE;
BEGIN

      --Standard begin of API savepoint

      SAVEPOINT baseline_budget_pub;


      --Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                               p_api_version_number   ,
                               l_api_name             ,
                               G_PKG_NAME             )
      THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


      pa_debug.set_curr_function( p_function   => 'baseline_budget',
                                  p_debug_mode => l_debug_mode );


      --Initialize the message table if requested.
      IF FND_API.TO_BOOLEAN( p_init_msg_list )
      THEN

            FND_MSG_PUB.initialize;

      END IF;

      --Get the user id and responsibility Ids
      l_user_id := FND_GLOBAL.User_id;
      l_resp_id := FND_GLOBAL.Resp_id;


      -- This api will initialize the data that will be used by the map_new_amg_msg.
      -- commented out the procedure call as required by venkatesh. 25-APR-03
/*
      PA_INTERFACE_UTILS_PUB.Set_Global_Info
        ( p_api_version_number => 1.0
         ,p_responsibility_id  => l_resp_id
         ,p_user_id            => l_user_id
         ,p_calling_mode       => 'AMG'     --bug 2783845
         ,p_msg_count          => l_msg_count
         ,p_msg_data           => l_msg_data
         ,p_return_status      => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
*/
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
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Product code is missing';
                  pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

--            RAISE FND_API.G_EXC_ERROR;
              l_any_error_occurred_flag := 'Y';

      ELSE
            l_pm_product_code :='Z';
            /*added for bug no :2413400*/
             -- dbms_output.put_line('p_pm_product_code is '||p_pm_product_code);
             -- dbms_output.put_line('l_pm_product_code is '||l_pm_product_code);
            OPEN p_product_code_csr (p_pm_product_code);
            FETCH p_product_code_csr INTO l_pm_product_code;
            CLOSE p_product_code_csr;
             -- dbms_output.put_line('l_pm_product_code is 2'||l_pm_product_code);
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
                  p_return_status             := FND_API.G_RET_STS_ERROR;
                  -- RAISE FND_API.G_EXC_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Product code is invalid';
                        pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                   -- dbms_output.put_line('Product Code is invalid');
            END IF;
             -- dbms_output.put_line('Validated the code');
      END IF;

      --l_module_name := p_pm_product_code||'.'||'PA_PM_BASELINE_BUDGET';
      l_module_name := 'PA_PM_BASELINE_BUDGET';

      --Commented out the existing calls to security APIs. call the api that has all the
      --security checks (As part of the changes to AMG for finplan model)

      -- As part of enforcing project security, which would determine
      -- whether the user has the necessary privileges to update the project
      -- need to call the pa_security package
      -- If a user does not have privileges to update the project, then
      -- cannot baseline the budget

      --pa_security.initialize (X_user_id        => l_user_id,
      --                        X_calling_module => l_module_name);

      -- Actions performed using the APIs would be subject to
      -- function security. If the responsibility does not allow
      -- such functions to be executed, the API should not proceed further
      -- since the user does not have access to such functions

      --PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_pa_project_id; Moved this to later part of code


      --PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      --(p_api_version_number => p_api_version_number,
      -- p_responsibility_id  => l_resp_id,
      -- p_function_name      => 'PA_PM_BASELINE_BUDGET',
      -- p_msg_count          => l_msg_count,
      -- p_msg_data           => l_msg_data,
      -- p_return_status      => l_return_status,
      -- p_function_allowed   => l_function_allowed );

      --IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      --THEN
      --      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      --
      --ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      --THEN
      --      RAISE FND_API.G_EXC_ERROR;
      --END IF;
      --IF l_function_allowed = 'N' THEN
      --      pa_interface_utils_pub.map_new_amg_msg
      --      ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
      --      ,p_msg_attribute    => 'CHANGE'
      --      ,p_resize_flag      => 'Y'
      --      ,p_msg_context      => 'GENERAL'
      --      ,p_attribute1       => ''
      --      ,p_attribute2       => ''
      --      ,p_attribute3       => ''
      --      ,p_attribute4       => ''
      --      ,p_attribute5       => '');
      --      p_return_status := FND_API.G_RET_STS_ERROR;
      --      RAISE FND_API.G_EXC_ERROR;
      --END IF;


      --  Set API return status to success

      p_return_status         := FND_API.G_RET_STS_SUCCESS;



      -- 12-AUG-97, jwhite:
      --  Initialize New OUT-parameter to indicate workflow status

      -- Set Worflow Started Status -------------------------------------------------

      p_workflow_started            := 'N';
      -- ------------------------------------------------------------------------------------


      --CHECK FOR MANDATORY FIELDS and CONVERT VALUES to ID's

      /*   -- dbms_output.put_line('Check for Mandatory Fields'); */

      -- convert pm_project_reference to id
      Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => p_pa_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => l_return_status );

      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Convert_pm_projref_to_id returned status '||l_return_status;
            pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
      END IF;

      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
            RAISE  FND_API.G_EXC_ERROR;

      END IF;

      IF l_project_id IS NULL   --never happens because previous procedure checks this.
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                  pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_PROJECT_IS_MISSING'
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
                  pa_debug.g_err_stage:= 'Project id is null ';
                  pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- Get segment1 for AMG messages

      OPEN l_amg_project_csr( l_project_id );
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;

-- Added Logic by Xin Liu to handle MISS vars based on Manoj's code review.
-- 28-APR-03
      IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
         ll_fin_plan_type_id := NULL;
      ELSE
       ll_fin_plan_type_id := p_fin_plan_type_id;
      END IF;

      IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
         ll_fin_plan_type_name := NULL;
      ELSE
         ll_fin_plan_type_name := p_fin_plan_type_name;
      END IF;

-- Changes done.


      -- Both Budget Type Code and Fin Plan Type Id should not be null
      IF ((p_budget_type_code IS NULL OR p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  AND
        (p_fin_plan_type_name IS NULL OR p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
        (p_fin_plan_type_id IS NULL OR p_fin_plan_type_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) )THEN

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name        => 'PA_BUDGET_FP_BOTH_MISSING');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'budget type code and fin plan type id, both are null ';
                  pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- Both Budget Type Code and Fin Plan Type Id should not be not null
      IF ((p_budget_type_code IS NOT NULL  AND
           p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  AND
        ((p_fin_plan_type_name IS NOT NULL AND p_fin_plan_type_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
         (p_fin_plan_type_id IS NOT NULL AND p_fin_plan_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))) THEN

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name        => 'PA_BUDGET_FP_BOTH_NOT_NULL');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'budget type code and fin plan type id, both are not null ';
                  pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      -- Check whether the user has privileges to call this api.
      -- Check whether budget type code or fin plan passed are valid or not
      IF p_budget_type_code IS NOT NULL
      AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            -- This api adds the message to stack in case of error
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                 p_api_version_number => p_api_version_number
                ,p_project_id         => l_project_id
                ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET
                ,p_function_name      => l_module_name
                ,p_version_type       => NULL
                ,x_return_status      => l_return_status
                ,x_ret_code           => l_security_ret_code );

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS OR
               l_security_ret_code = 'N' THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Security API failed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;


            OPEN l_budget_types_csr( p_budget_type_code );

            FETCH l_budget_types_csr
            INTO l_row_found;

            IF l_budget_types_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'N'
                         ,p_msg_context      => 'BUDG'
                         ,p_attribute1       => l_amg_segment1
                         ,p_attribute2       => ''
                         ,p_attribute3       => p_budget_type_code
                         ,p_attribute4       => ''
                         ,p_attribute5       => '');
                  END IF;

                  CLOSE l_budget_types_csr;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Invalid budget type ';
                        pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSE
                  CLOSE l_budget_types_csr;
            END IF;

            --Added this validation for bug#4460120
             --Verify that the budget is not of type FORECASTING_BUDGET_TYPE
             IF p_budget_type_code='FORECASTING_BUDGET_TYPE' THEN
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                         PA_UTILS.add_message
                         (p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_CANT_BLINE_FCST_BUD_TYPE');
                   END IF;
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Budget of type FORECASTING_BUDGET_TYPE' ;
                         pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

      ELSE  -- API is called in the context of fin plan

            --Call the api that converts the fin plan type name to ID .This api adds the
            --message to stack in case of error

          --Changed p_fin_plan_type_id to ll_fin_plan_type_id,
            --        p_fin_plan_type_name to ll_fin_plan_type_name
            --Xin Liu 28-APR-03
            PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
                                     ( p_fin_plan_type_id    => ll_fin_plan_type_id
                                      ,p_fin_plan_type_name  => ll_fin_plan_type_name
                                      ,x_fin_plan_type_id    => l_fin_plan_type_id
                                      ,x_return_status       => l_return_status
                                      ,x_msg_count           => l_msg_count
                                      ,x_msg_data            => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Can not get the value of Fin Plan Type Id' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

             -- dbms_output.put_line('Obtained the plan type id'||l_fin_plan_type_id);

            OPEN l_plan_type_option_csr( l_project_id
                                       ,l_fin_plan_type_id)  ;
            FETCH l_plan_type_option_csr INTO l_dummy;
            IF l_plan_type_option_csr%NOTFOUND THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Plan type options does not exiss' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  SELECT name
                  INTO   l_fin_plan_type_name
                  FROM   pa_fin_plan_types_vl
                  WHERE  fin_plan_type_id = l_fin_plan_type_id;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_NO_PLAN_TYPE_OPTION',
                            p_token1         => 'PROJECT',
                            p_value1         =>  l_amg_segment1,
                            p_token2         => 'PLAN_TYPE',
                            p_value2         =>  l_fin_plan_type_name);


                  CLOSE l_plan_type_option_csr;

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Plan type is not yet added to the project';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE

                  CLOSE l_plan_type_option_csr;

            END IF;

--Added by Xin Liu to Handle the G_miss case.
--28-APR-03
         IF p_version_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_version_type := NULL;
         ELSE
            l_version_type := p_version_type;
         END IF;

            --Derive the version type.
            pa_fin_plan_utils.get_version_type
                 ( p_project_id        => l_project_id
                  ,p_fin_plan_type_id  => l_fin_plan_type_id
                  ,px_version_type     => l_version_type
                  ,x_return_status     => l_return_status
                  ,x_msg_count         => l_msg_count
                  ,x_msg_data          => l_msg_data);

             -- dbms_output.put_line('Got the version type');
            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'get_version_type failed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;


            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                 p_api_version_number => p_api_version_number
                ,p_project_id         => l_project_id
                ,p_fin_plan_type_id   => l_fin_plan_type_id /* Bug 3139924 */
                ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                ,p_function_name      => l_module_name
                ,p_version_type       => l_version_type
                ,x_return_status      => l_return_status
                ,x_ret_code           => l_security_ret_code );

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS OR
               l_security_ret_code = 'N' THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Security API failed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            -- Get the current baselined version
            pa_fin_plan_utils.Get_Baselined_Version_Info(
                           p_project_id           => l_project_id
                          ,p_fin_plan_type_id     => l_fin_plan_type_id
                          ,p_version_type         => l_version_type
                          ,x_fp_options_id        => l_baselined_Ver_options_id
                          ,x_fin_plan_version_id  => l_baselined_version_id
                          ,x_return_status        => l_return_status
                          ,x_msg_count            => l_msg_count
                          ,x_msg_data             => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                 -- RAISE  FND_API.G_EXC_ERROR;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

      END IF;--IF p_budget_type_code IS NOT NULL
      -- Budget Integration Validation ---------------------------------------

      --This validation is required only in budget model
      IF( p_budget_type_code IS NOT NULL
         AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN


            PA_BUDGET_FUND_PKG.get_budget_ctrl_options (p_project_Id => l_project_id
                                  , p_budget_type_code => p_budget_type_code
                                  , p_calling_mode     => 'BUDGET'
                                  , x_fck_req_flag     => l_fck_req_flag
                                  , x_bdgt_intg_flag   => l_bdgt_intg_flag
                                  , x_bdgt_ver_id      => l_bdgt_ver_id
                                  , x_encum_type_id    => l_encum_type_id
                                  , x_balance_type     => l_balance_type
                                  , x_return_status    => l_return_status
                                  , x_msg_data         => l_msg_data
                                  , x_msg_count        => l_msg_count
                                  );


            IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Unexpected error in budget ctrl options' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;


            ELSIF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
                 -- RAISE  FND_API.G_EXC_ERROR;
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
                         ,p_attribute1       => l_amg_segment1
                         ,p_attribute2       => ''
                         ,p_attribute3       => p_budget_type_code
                         ,p_attribute4       => ''
                         ,p_attribute5       => '');
                  END IF;

                  -- RAISE FND_API.G_EXC_ERROR;
                  l_any_error_occurred_flag := 'Y';
            END IF;


            -- ----------------------------------------------------------------------
      END IF;--end of the if for bugetary controls


      -- mark_as_original defaults to YES ('Y') when this is the first time this budget is baselined
      -- otherwise it will default to NO ('N')
      IF p_mark_as_original IS NULL
      OR p_mark_as_original = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      OR UPPER(p_mark_as_original) NOT IN ('N','Y') THEN

            IF( p_budget_type_code IS NOT NULL
            AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

                  OPEN l_baselined_csr( l_project_id
                               ,p_budget_type_code);

                  FETCH l_baselined_csr INTO l_baselined_rec;

                  IF l_baselined_csr%NOTFOUND
                  THEN
                    l_mark_as_original := 'Y';
                  ELSE
                    l_mark_as_original := 'N';
                  END IF;

                  CLOSE l_baselined_csr;

            ELSE--Fin Plan Model . Get the baselined version details


                  IF l_baselined_version_id IS NULL
                  THEN
                    l_mark_as_original := 'Y';
                  ELSE
                    l_mark_as_original := 'N';
                  END IF;

            END IF;

      ELSE --Mark as original param is passed
            l_mark_as_original := UPPER(p_mark_as_original);

      END IF;
       -- dbms_output.put_line('Done with mark as orig');

/*   -- dbms_output.put_line('Mark_as_original = '||l_mark_as_original); */

 -- get the budget version ID associated with this project / budget_type_code combination

      IF( p_budget_type_code IS NOT NULL
            AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

            OPEN l_budget_versions_csr ( l_project_id
                                        ,p_budget_type_code);

            FETCH l_budget_versions_csr
            INTO l_budget_versions_rec;

            IF l_budget_versions_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_NO_BUDGET_VERSION'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'N'
                         ,p_msg_context      => 'BUDG'
                         ,p_attribute1       => l_amg_segment1
                         ,p_attribute2       => ''
                         ,p_attribute3       => p_budget_type_code
                         ,p_attribute4       => ''
                         ,p_attribute5       => '');
                  END IF;

                  CLOSE l_budget_versions_csr;
                  RAISE FND_API.G_EXC_ERROR;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Curr working version does not exist' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                  l_any_error_occurred_flag := 'Y';
            ELSE

                  CLOSE l_budget_versions_csr;

            END IF;

            l_curr_working_version_id := l_budget_versions_rec.budget_version_id;

      ELSE -- Fin Plan Model. Get the current working version info

            pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                  p_project_id             => l_project_id
                  ,p_fin_plan_type_id      => l_fin_plan_type_id
                  ,p_version_type          => l_version_type
                  ,x_fp_options_id         => l_CW_ver_options_id
                  ,x_fin_plan_version_id   => l_curr_working_version_id
                  ,x_return_status         => l_return_status
                  ,x_msg_count             => l_msg_count
                  ,x_msg_data              => l_msg_data );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Unexpected error in Get_Baselined_Version_Info' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  l_any_error_occurred_flag := 'Y';
            END IF;

            IF l_curr_working_version_id IS NULL
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_NO_BUDGET_VERSION'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'N'
                         ,p_msg_context      => 'BUDG'
                         ,p_attribute1       => l_amg_segment1
                         ,p_attribute2       => ''
                         ,p_attribute3       => p_budget_type_code
                         ,p_attribute4       => ''
                         ,p_attribute5       => '');
                  END IF;
                  -- Raising the error since its not possible to proceed if there is no
                  -- Current working version
                  RAISE FND_API.G_EXC_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Curr working version does not exist' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

            END IF;

            pa_fin_plan_utils.return_and_vldt_plan_prc_code
            (p_budget_version_id      =>   l_curr_working_version_id
            ,x_final_plan_prc_code    =>   l_final_plan_prc_code
            ,x_targ_request_id        =>   l_targ_request_id
            ,x_return_status          =>   l_return_status
            ,x_msg_count              =>   l_msg_count
            ,x_msg_data               =>   l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Unexpected error in Get_Baselined_Version_Info' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  l_any_error_occurred_flag := 'Y';
            END IF;


      END IF;

      -- Call the api that performs the autobaseline checks
      -- Bug 3099706 : Skip the autobaseline checks if this API is called from
      -- PA_AGREEMENT_PUB.create_baselined_budget. This API will only be called
      -- in Autobaseline enabled AR plan type / budget type cases only.
      -- This check is valid in all other cases when a budget needs to be baselined.

      -- dbms_output.put_line('Value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '||PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);

      IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'N') THEN
              -- dbms_output.put_line('about to call autobaseline checks API ');

            pa_fin_plan_utils.perform_autobasline_checks
            (  p_budget_version_id  => l_curr_working_version_id
            ,x_result             => l_result
            ,x_return_status      => p_return_status
            ,x_msg_count          => p_msg_count
            ,x_msg_data           => p_msg_data       );

            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'Auto baseline API falied';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;


            IF l_result = 'F' THEN
                IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'Auto baseline checks falied';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                l_any_error_occurred_flag:='Y';
                PA_UTILS.ADD_MESSAGE( p_app_short_name  => 'PA'
                               ,p_msg_name        => 'PA_FP_APP_REV_BL_VER_AB_PROJ'
                               ,p_token1          => 'PROJECT'
                               ,p_value1          => l_amg_segment1);

            END IF;
      END IF; -- bug 3099706

      IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
              PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
      END IF;
       -- dbms_output.put_line('Got the CW version ' || l_curr_working_version_id);


      -- check for budget lines in pa_resource_assignments,
      -- we only permit submit/baseline action when there are budget lines
    -- Fix for bug#8423481, for new budget we will check for budget lines in pa_resource_assignments,
    -- and for old model budget we will check for budget lines in pa_budget_lines
    -- we only permit submit/baseline action when there are budget lines
    IF( p_budget_type_code IS NOT NULL
        AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

          OPEN l_budget_lines_csr(l_curr_working_version_id);

          FETCH l_budget_lines_csr INTO l_row_found;

          IF l_budget_lines_csr%NOTFOUND
          THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_NO_BUDGET_LINES'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'BUDG'
                       ,p_attribute1       => l_amg_segment1
                       ,p_attribute2       => ''
                       ,p_attribute3       => p_budget_type_code
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                END IF;

                CLOSE l_budget_lines_csr;
                l_any_error_occurred_flag := 'Y';
                IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Budget Lines do not exist for current working version' ;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
          ELSE
                CLOSE l_budget_lines_csr;

          END IF;
    ELSE
          OPEN l_resource_assignments_csr(l_curr_working_version_id);

          FETCH l_resource_assignments_csr INTO l_row_found;

          IF l_resource_assignments_csr%NOTFOUND THEN

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NO_BUDGET_LINES'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'BUDG'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => ''
                      ,p_attribute3       => p_budget_type_code
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
		END IF;

		CLOSE l_resource_assignments_csr;
                l_any_error_occurred_flag := 'Y';
                IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Budget Lines do not exist for current working version' ;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
          ELSE
                CLOSE l_resource_assignments_csr;

          END IF;

    END IF;



       -- dbms_output.put_line('done with BL Check');

      -- verify budget (up to this date (sept 96) not implemented)
      --
      pa_budget_core.verify( x_budget_version_id  => l_curr_working_version_id
                            ,x_err_code           => l_err_code
                            ,x_err_stage          => l_err_stage
                            ,x_err_stack          => l_err_stack  );

      IF l_err_code > 0
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                  IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_VERIFY_FAILED'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'N'
                         ,p_msg_context      => 'BUDG'
                         ,p_attribute1       => l_amg_segment1
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
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => p_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;

            END IF;

            -- RAISE FND_API.G_EXC_ERROR;
            l_any_error_occurred_flag := 'Y';

      ELSIF l_err_code < 0
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN

                  FND_MSG_PUB.add_exc_msg
                        (  p_pkg_name           => 'PA_BUDGET_CORE'
                        ,  p_procedure_name     => 'VERIFY'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;
       -- dbms_output.put_line('About to verify budget rules');

      --Verify Budget Rules should be called in budget model Only. In FinPlan model
      --The baseline api  in fin plan pub inturn calls the verify budget rules
      IF p_budget_type_code IS NOT NULL
      AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to verify the budget rules in budget model' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;


            -- ------------------------------------------------------------------------------------
            -- 29-JUL-97, jwhite
            --  Added SUBMISSION/BASELINE RULES and WORFLOW
            -- ------------------------------------------------------------------------------------

            -- Retrieve Required IN-parameters for Verify_Budget_Rules Calls

            OPEN l_budget_rules_csr(l_curr_working_version_id);

            FETCH l_budget_rules_csr
            INTO  l_resource_list_id
                  , l_project_type_class_code;

            IF ( l_budget_rules_csr%NOTFOUND)
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_NO_BUDGET_RULES_ATTR'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'N'
                         ,p_msg_context      => 'BUDG'
                         ,p_attribute1       => l_amg_segment1
                         ,p_attribute2       => ''
                         ,p_attribute3       => p_budget_type_code
                         ,p_attribute4       => ''
                         ,p_attribute5       => '');
                  END IF;

                  CLOSE l_budget_rules_csr;
                  -- RAISE FND_API.G_EXC_ERROR;
                  l_any_error_occurred_flag := 'Y';

            ELSE

                  CLOSE l_budget_rules_csr;

            END IF;


            --
            -- SUBMISSION RULES -------------------------------------------------------------
            --

            /*   -- dbms_output.put_line('Verify Budget Rules - SUBMIT'); */


            PA_BUDGET_UTILS.VERIFY_BUDGET_RULES
            (p_draft_version_id           =>    l_curr_working_version_id
            , p_mark_as_original          =>    l_mark_as_original
            , p_event                     =>    'SUBMIT'
            , p_project_id                =>    l_project_id
            , p_budget_type_code          =>    p_budget_type_code
            , p_resource_list_id          =>    l_resource_list_id
            , p_project_type_class_code   =>    l_project_type_class_code
            , p_created_by                =>    l_user_id
            , p_calling_module            =>    'PAPMBUPB'
            , p_warnings_only_flag        =>    l_warnings_only_flag
            , p_err_msg_count             =>    l_err_msg_count
            , p_err_code                  =>    l_err_code
            , p_err_stage                 =>    l_err_stage
            , p_err_stack                 =>    l_err_stack
            );

            -- 11-SEP-97, jwhite: Warnings-OK Concept -----------------------------------
            --
            IF (l_err_msg_count > 0)
            THEN
                  IF (l_warnings_only_flag      = 'Y')
                  THEN
                        p_return_status := 'W';
                  ELSE
                        -- RAISE FND_API.G_EXC_ERROR;
                        l_any_error_occurred_flag := 'Y';
                  END IF;
             -- dbms_output.put_line('Count after verify the baseline rules is >0');

            END IF;
            --

            -- LOCK DRAFT BUDGET VERSION Since Primary Verification Finished

            OPEN l_lock_budget_csr(l_curr_working_version_id);
            CLOSE l_lock_budget_csr;

             -- dbms_output.put_line('About to verify the baseline rules');
            --
            -- BASELINE RULES -------------------------------------------------------------
            --

            PA_BUDGET_UTILS.VERIFY_BUDGET_RULES
                (p_draft_version_id             =>    l_curr_working_version_id
                , p_mark_as_original            =>    l_mark_as_original
                , p_event                       =>    'BASELINE'
                , p_project_id                  =>    l_project_id
                , p_budget_type_code            =>    p_budget_type_code
                , p_resource_list_id            =>    l_resource_list_id
                , p_project_type_class_code     =>    l_project_type_class_code
                , p_created_by                  =>    l_user_id
                , p_calling_module              =>    'PAPMBUPB'
                , p_warnings_only_flag          =>    l_warnings_only_flag
                , p_err_msg_count               =>    l_err_msg_count
                , p_err_code                    =>    l_err_code
                , p_err_stage                   =>    l_err_stage
                , p_err_stack                   =>    l_err_stack
                );

            -- 11-SEP-97, jwhite: Warnings-OK Concept -----------------------------------
            --
            IF (l_err_msg_count > 0)
             THEN
                  IF (l_warnings_only_flag      = 'Y')
                  THEN
                        p_return_status := 'W';
                  ELSE
                        -- RAISE FND_API.G_EXC_ERROR;
                        l_any_error_occurred_flag := 'Y';
                  END IF;
            END IF;

      ELSE -- Verify budget rules will be called by the baseline api in fin plan model.
           -- Lock the version in the finplan model

            --Get the record version number of the current working version
            l_CW_record_version_number :=pa_fin_plan_utils.Retrieve_Record_Version_Number(l_curr_working_version_id);

            -- Lock the current working version

            pa_fin_plan_pvt.lock_unlock_version
                  (p_budget_version_id      => l_curr_working_version_id,
                  p_record_version_number   => l_CW_record_version_number,
                  p_action                  => 'L',
                  p_user_id                 => l_user_id,
                  p_person_id               => NULL,
                  x_return_status           => p_return_status,
                  x_msg_count               => p_msg_count,
                  x_msg_data                => p_msg_data) ;

            IF p_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Error executing lock unlock version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
            -- dbms_output.put_line('The no of messages in the stack 2 '||FND_MSG_PUB.count_msg);

      END IF;--If for buget model check

       -- dbms_output.put_line('Starting with workflow l_err_code '||l_err_code);
      --

      --
      -- ENABLE WORKFLOW?  ---------------------------------------------------
      --

      /*   -- dbms_output.put_line('Call BUDGET_WF_IS_USED'); */

      IF p_budget_type_code IS NOT NULL
      AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN

            PA_BUDGET_WF.Budget_Wf_Is_Used
            ( p_draft_version_id          =>    l_curr_working_version_id
            , p_project_id                =>    l_project_id
            , p_budget_type_code          =>    p_budget_type_code
            , p_pm_product_code           =>    p_pm_product_code
            , p_result                    =>    l_workflow_is_used
            , p_err_code                  =>    l_err_code
            , p_err_stage                 =>    l_err_stage
            , p_err_stack                 =>    l_err_stack
            );

      ELSE --Fin Plan Model. Pass the version type and plan type id

            PA_BUDGET_WF.Budget_Wf_Is_Used
            ( p_draft_version_id          =>    l_curr_working_version_id
            , p_project_id                =>    l_project_id
            , p_budget_type_code          =>    NULL
            , p_pm_product_code           =>    p_pm_product_code
            , p_result                    =>    l_workflow_is_used
            , p_err_code                  =>    l_err_code
            , p_err_stage                 =>    l_err_stage
            , p_err_stack                 =>    l_err_stack
            , p_fin_plan_type_id          =>    l_fin_plan_type_id
            , p_version_type              =>    l_version_type
            );

      END IF;

       -- dbms_output.put_line('l_err_code after is WD '||l_err_code);
      IF (l_err_code > 0)
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                  FND_MESSAGE.SET_NAME('PA','PA_WF_CLIENT_EXTN');
                  FND_MESSAGE.SET_TOKEN('EXTNAME', 'PA_BUDGET_WF.BUDGET_WF_IS_USED');
                              FND_MESSAGE.SET_TOKEN('ERRCODE',l_err_code);
                  FND_MESSAGE.SET_TOKEN('ERRMSG', l_err_stage);
                  FND_MSG_PUB.add;
            END IF;

            -- RAISE FND_API.G_EXC_ERROR;
            l_any_error_occurred_flag := 'Y';
      ELSIF (l_err_code < 0)
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                  FND_MSG_PUB.add_exc_msg
                        (  p_pkg_name           => 'PA_BUDGET_WF'
                        ,  p_procedure_name     => 'BUDGET_WF_IS_USED'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Stop further processing if any errors are reported
      -- dbms_output.put_line('l_any_error_occurred_flag is '||l_any_error_occurred_flag);
      IF(l_any_error_occurred_flag='Y') THEN
            IF(l_debug_mode='Y') THEN
                  pa_debug.g_err_stage := 'About to display all the messages';
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;
             -- dbms_output.put_line('Displaying all messages');
            l_return_status := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag := 'Y';
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
       -- dbms_output.put_line('Starting with workflow = T');

      IF (l_workflow_is_used = 'T' ) THEN

            -- ENABLE Workflow !!! -------------------------------------------------------------

            -- when the client extension returns 'T',
            -- the baseline action will be skipped here, since the baselining is done later
            -- by the baseliner as part of the workflow process.

            /*   -- dbms_output.put_line('WORKFLOW USED...Update Draft to Submitted, IN_ROUTE'); */

            UPDATE pa_budget_versions
            SET budget_status_code = 'S', WF_status_code = 'IN_ROUTE'
            WHERE budget_version_id = l_curr_working_version_id;

/*   -- dbms_output.put_line('WORKFLOW USED...START_BUDGET_WF API'); */

            PA_BUDGET_WF.Start_Budget_Wf
            (p_draft_version_id           =>    l_curr_working_version_id
            , p_project_id                =>    l_project_id
            , p_budget_type_code          =>    p_budget_type_code
            , p_mark_as_original          =>    l_mark_as_original
            , p_err_code                  =>      l_err_code
            , p_err_stage                 =>    l_err_stage
            , p_err_stack                 =>    l_err_stack
            );

            IF (l_err_code > 0)
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        FND_MESSAGE.SET_NAME('PA','PA_WF_CLIENT_EXTN');
                        FND_MESSAGE.SET_TOKEN('EXTNAME', 'PA_BUDGET_WF.START_BUDGET_WF');
                                    FND_MESSAGE.SET_TOKEN('ERRCODE',l_err_code);
                        FND_MESSAGE.SET_TOKEN('ERRMSG', l_err_stage);
                        FND_MSG_PUB.add;
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSIF (l_err_code < 0)
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                        FND_MSG_PUB.add_exc_msg
                              (  p_pkg_name           => 'PA_BUDGET_WF'
                              ,  p_procedure_name     => 'START_BUDGET_WF'
                              ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;



            p_workflow_started            := 'Y';

            -- NOTE: A commit is required to actually start/activate  the workflow instance opened
            -- by the previous Start_Budget_WF procedure.


            IF FND_API.TO_BOOLEAN( p_commit )
            THEN
                  COMMIT;
            END IF;

            RETURN;
      ELSE

      -- STRAIGHT BASELINE, NO Workflow


            UPDATE pa_budget_versions
            SET budget_status_code = 'S', WF_status_code = NULL
            WHERE budget_version_id = l_curr_working_version_id;


      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Budget rules verified' ;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

-- -------------------------------------------------------------------------------------

 -- calling private API 'BASELINE'
    -- Hardcode p_verify_budget_rules to 'N' becuase verify_budget_rules already called.

/*   -- dbms_output.put_line('Call PA_BUDGET_CORE.BASELINE'); */




      IF p_budget_type_code IS NOT NULL
      AND p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to baseline the budget ' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            -- dbms_output.put_line('About to call the baseline api in budget core');
            pa_budget_core.baseline ( x_draft_version_id    => l_curr_working_version_id
                             ,x_mark_as_original      => l_mark_as_original
                             ,x_verify_budget_rules     => 'N'
                             ,x_err_code        => l_err_code
                             ,x_err_stage       => l_err_stage
                             ,x_err_stack       => l_err_stack    );



            IF l_err_code > 0
            THEN

            /*   -- dbms_output.put_line('Err_code: '||l_err_code); */
            /*   -- dbms_output.put_line('Err_stage: '||l_err_stage); */
            /*   -- dbms_output.put_line('Err_stack: '||l_err_stack); */

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN

                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_BASELINE_FAILED'
                               ,p_msg_attribute    => 'CHANGE'
                               ,p_resize_flag      => 'N'
                               ,p_msg_context      => 'BUDG'
                               ,p_attribute1       => l_amg_segment1
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
                               ,p_attribute1       => l_amg_segment1
                               ,p_attribute2       => ''
                               ,p_attribute3       => p_budget_type_code
                               ,p_attribute4       => ''
                               ,p_attribute5       => '');
                        END IF;

                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN

      /*   -- dbms_output.put_line('Err_code: '||l_err_code); */
      /*   -- dbms_output.put_line('Err_stage: '||l_err_stage); */
      /*   -- dbms_output.put_line('Err_stack: '||l_err_stack); */

                        FND_MSG_PUB.add_exc_msg
                              (  p_pkg_name           => 'PA_BUDGET_CORE'
                              ,  p_procedure_name     => 'BASELINE'
                              ,  p_error_text         => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

       -- after calling BASELINE, set the budget_status_code back to 'W' (Working)
       -- the concept of submitting budget is not available in the public API's!

            UPDATE pa_budget_versions
            SET budget_status_code = 'W'
            WHERE budget_version_id = l_curr_working_version_id;

      ELSE--Fin Plan Model. Call the baseline api in fin plan pub

            --Get the record version number of the current baselined version
            IF l_baselined_version_id IS NOT NULL THEN
                  --Get the record version number
                  l_CB_record_version_number :=pa_fin_plan_utils.Retrieve_Record_Version_Number(l_baselined_version_id);
            ELSE
                  l_CB_record_version_number:=NULL;
            END IF;

            --Get the record version number of the current working version  (As it will be incremented by the lock_unlock_version)
            l_CW_record_version_number :=pa_fin_plan_utils.Retrieve_Record_Version_Number(l_curr_working_version_id);

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to baseline the finplan ' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

             -- dbms_output.put_line('About to call baseline api');

            IF (l_mark_as_original = 'Y') THEN

                  -- Fetch the details of  original baseline version
                  -- so that they can be used to set its orginal flag

                  OPEN l_orig_baselined_ver_csr(l_project_id,
                                                l_fin_plan_type_id,
                                                l_version_type);
                  FETCH  l_orig_baselined_ver_csr INTO l_orig_baselined_ver_rec;
                  CLOSE l_orig_baselined_ver_csr;

            END IF;

            pa_fin_plan_pub.Baseline
                  ( p_project_id                 => l_project_id
                   ,p_budget_version_id          => l_curr_working_version_id
                   ,p_record_version_number      => l_CW_record_version_number
                   ,p_orig_budget_version_id     => l_baselined_version_id
                   ,p_orig_record_version_number => l_CB_record_version_number
                   ,x_fc_version_created_flag    => l_fc_version_created_flag
                   ,x_return_status              => l_return_status
                   ,x_msg_count                  => l_msg_count
                   ,x_msg_data                   => l_msg_data );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Error in fin plan pub baseline ';
                        pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

             -- dbms_output.put_line('About to call mark as original api');

            --If the mark as original parameter is Y then call the api that sets the just now baselined version
            --as the orginal version
            IF (l_mark_as_original = 'Y') THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to mark the created version as original baselined ' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  -- Fetch the details current baselined version
                  pa_fin_plan_utils.Get_Baselined_Version_Info(
                           p_project_id           => l_project_id
                          ,p_fin_plan_type_id     => l_fin_plan_type_id
                          ,p_version_type         => l_version_type
                          ,x_fp_options_id        => l_baselined_Ver_options_id
                          ,x_fin_plan_version_id  => l_baselined_version_id
                          ,x_return_status        => l_return_status
                          ,x_msg_count            => l_msg_count
                          ,x_msg_data             => l_msg_data);

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                       -- RAISE  FND_API.G_EXC_ERROR;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  l_CB_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_baselined_version_id);

                  IF l_orig_baselined_ver_rec.budget_version_id IS NOT NULL THEN

                        l_orig_baselined_ver_rec.record_version_number:=pa_fin_plan_utils.Retrieve_Record_Version_Number
                                                                            (l_orig_baselined_ver_rec.budget_version_id);

                  END IF;

                   -- dbms_output.put_line('The verid to be marked as orig is '||l_baselined_version_id);
                   -- dbms_output.put_line('The orig verid to be marked as orig is '||l_orig_baselined_ver_rec.budget_version_id);

                  pa_fin_plan_pub.Mark_As_Original
                        ( p_project_id                  => l_project_id
                         ,p_budget_version_id           => l_baselined_version_id
                         ,p_record_version_number       => l_Cb_record_version_number
                         ,p_orig_budget_version_id      => l_orig_baselined_ver_rec.budget_version_id
                         ,p_orig_record_version_number  => l_orig_baselined_ver_rec.record_version_number
                         ,x_return_status               => l_return_status
                         ,x_msg_count                   => l_msg_count
                         ,x_msg_data                    => l_msg_data      );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  OR
                     l_msg_count <> 0THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error while marking the newly created version as the original version ';
                              pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

            END IF;

            --Bug 6453987 - skkoppul - Unlocking the working version

            pa_fin_plan_pvt.lock_unlock_version
                  (p_budget_version_id      => l_curr_working_version_id,
                  p_record_version_number   => l_CW_record_version_number,
                  p_action                  => 'U',
                  p_user_id                 => l_user_id,
                  p_person_id               => NULL,
                  x_return_status           => p_return_status,
                  x_msg_count               => p_msg_count,
                  x_msg_data                => p_msg_data) ;

            IF p_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Error executing lock unlock version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --End changes bug 6453987 - skkoppul


      END IF;-- IF p_budget_type_code IS NOT NULL


      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
            COMMIT;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving baseline budget';
            pa_debug.write('baseline_budget ' || g_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      pa_debug.reset_curr_function;


EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
            ROLLBACK TO baseline_budget_pub;

            IF p_return_status IS NULL OR
               p_return_status = FND_API.G_RET_STS_SUCCESS THEN
                  p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count = 1 THEN
                  PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out);

                  p_msg_data  := l_data;
                  p_msg_count := l_msg_count;
            ELSE
                  p_msg_count := l_msg_count;
            END IF;
            pa_debug.reset_curr_function;

            RETURN;

      WHEN FND_API.G_EXC_ERROR
      THEN


            ROLLBACK TO baseline_budget_pub;

            p_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count       =>    p_msg_count ,
                p_data        =>    p_msg_data  );

            pa_debug.reset_curr_function;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN


            ROLLBACK TO baseline_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count       =>    p_msg_count ,
                p_data        =>    p_msg_data  );

            pa_debug.reset_curr_function;

      WHEN ROW_ALREADY_LOCKED
      THEN

            ROLLBACK TO baseline_budget_pub;

            p_return_status := FND_API.G_RET_STS_ERROR ;

                  IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
                        FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
                        FND_MESSAGE.SET_TOKEN('TASK',    '');
                        FND_MESSAGE.SET_TOKEN('BUDGET_TYPE', p_budget_type_code);
                        FND_MESSAGE.SET_TOKEN('SOURCE_NAME', '');
                        FND_MESSAGE.SET_TOKEN('START_DATE', '');
                        FND_MESSAGE.SET_TOKEN('ENTITY', 'BUDGET_VERSIONS');
                        FND_MSG_PUB.Add;
                  END IF;

            FND_MSG_PUB.Count_And_Get
            (p_count                =>    p_msg_count
            , p_data                =>    p_msg_data
            );
            pa_debug.reset_curr_function;


      WHEN OTHERS
      THEN


            ROLLBACK TO baseline_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                  FND_MSG_PUB.add_exc_msg
                  (  p_pkg_name           => G_PKG_NAME
                  ,  p_procedure_name     => l_api_name );

            END IF;

            FND_MSG_PUB.Count_And_Get
            (   p_count       =>    p_msg_count ,
            p_data            =>    p_msg_data  );

            pa_debug.reset_curr_function;


END baseline_budget;


----------------------------------------------------------------------------------------
--Name:               add_budget_line
--Type:               Procedure
--Description:        This procedure can be used to add a budgetline to an
--                    existing WORKING budget.
--
--Called subprograms:
--          pa_budget_pvt.insert_budget_line
--          pa_budget_lines_v_pkg.check_overlapping_dates
--          PA_BUDGET_UTILS.summerize_project_totals
--
--
--
--History:
--    01-OCT-1996        L. de Werker    Created
--    19-NOV-1996    L. de Werker    Changed to use pa_budget_pvt.insert_budget_line
--    28-NOV-1996    L. de Werker    Add 16 parameters for descriptive flexfields
--    26-APR-2005    Ritesh Shukla   Bug 4224464: FP.M Changes - Did changes in
--                                   add_budget_line for FP.M FinPlan model.

PROCEDURE Add_Budget_Line
( p_api_version_number       IN  NUMBER
 ,p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
 ,p_init_msg_list            IN  VARCHAR2   := FND_API.G_FALSE
 ,p_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code          IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id            IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference     IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id               IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias           IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id  IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date          IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost            IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                  IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_budget_line_reference IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Parameters added for FP.M
 ,p_fin_plan_type_id         IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type             IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number           IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_currency_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )

IS


     l_api_name       CONSTANT    VARCHAR2(30)  := 'Add_Budget_Line';
     l_err_code                   NUMBER;
     l_err_stage                  VARCHAR2(120);
     l_err_stack                  VARCHAR2(630);

     l_project_id                 NUMBER := p_pa_project_id;
     l_budget_type_code           pa_budget_types.budget_type_code%TYPE := p_budget_type_code;
     l_fin_plan_type_id           NUMBER := p_fin_plan_type_id;
     l_fin_plan_type_name         pa_fin_plan_types_tl.name%TYPE := p_fin_plan_type_name;
     l_version_type               pa_budget_versions.version_type%TYPE := p_version_type;
     l_budget_version_id          NUMBER;
     l_budget_entry_method_code   pa_budget_entry_methods.budget_entry_method_code%TYPE;
     l_resource_list_id           pa_resource_lists_all_bg.resource_list_id%TYPE;
     l_budget_amount_code         pa_budget_types.budget_amount_code%type;
     l_entry_level_code           pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
     l_time_phased_code           pa_proj_fp_options.cost_time_phased_code%TYPE;
     l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
     l_categorization_code        pa_budget_entry_methods.categorization_code%TYPE;
     l_record_version_number      pa_budget_versions.record_version_number%TYPE;

     l_resource_name              VARCHAR2(80); --bug 3711693

     l_budget_lines_in            budget_line_in_tbl_type;
     l_budget_lines_out_tbl       budget_line_out_tbl_type;
     l_mfc_cost_type_id_tbl       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
     l_etc_method_code_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
     l_spread_curve_id_tbl        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

     l_finplan_lines_tab          pa_fin_plan_pvt.budget_lines_tab;
     l_version_info_rec           pa_fp_gen_amount_utils.fp_cols;

     --Following parameters are needed for amounts check
     l_amount_set_id              pa_proj_fp_options.all_amount_set_id%TYPE;
     lx_raw_cost_flag             VARCHAR2(1) := NULL;
     lx_burdened_cost_flag        VARCHAR2(1) := NULL;
     lx_revenue_flag              VARCHAR2(1) := NULL;
     lx_cost_qty_flag             VARCHAR2(1) := NULL;
     lx_revenue_qty_flag          VARCHAR2(1) := NULL;
     lx_all_qty_flag              VARCHAR2(1) := NULL;
     l_bill_rate_flag             pa_fin_plan_amount_sets.bill_rate_flag%type;
     l_cost_rate_flag             pa_fin_plan_amount_sets.cost_rate_flag%type;
     l_burden_rate_flag           pa_fin_plan_amount_sets.burden_rate_flag%type;
     l_allow_qty_flag             VARCHAR2(1);

     l_msg_count                  NUMBER := 0;
     l_msg_data                   VARCHAR2(2000);
     l_function_allowed           VARCHAR2(1);
     l_module_name                VARCHAR2(80);
     l_data                       VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     l_amg_project_number        pa_projects_all.segment1%TYPE;
     l_amg_task_number            VARCHAR2(50);

     --debug variables
     l_debug_mode                 VARCHAR2(1);
     l_debug_level2      CONSTANT NUMBER := 2;
     l_debug_level3      CONSTANT NUMBER := 3;
     l_debug_level4      CONSTANT NUMBER := 4;
     l_debug_level5      CONSTANT NUMBER := 5;
     --Added for bug 6408139 to pass G_PA_MISS_CHAR
     l_pa_miss_char varchar2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;


BEGIN


     --Standard begin of API savepoint

     SAVEPOINT add_budget_line_pub;

     p_msg_count := 0;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     l_module_name := g_module_name || ':Add_Budget_Line';

     IF ( l_debug_mode = 'Y' )
     THEN
           pa_debug.set_curr_function( p_function   => 'Add_Budget_Line',
                                       p_debug_mode => l_debug_mode );
     END IF;

     IF ( l_debug_mode = 'Y' )
     THEN
           pa_debug.g_err_stage:='Entering ' || l_api_name;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     --Initialize the message table if requested.
     IF FND_API.TO_BOOLEAN( p_init_msg_list )
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     --Set API return status to success
     p_return_status     := FND_API.G_RET_STS_SUCCESS;

     --Call PA_BUDGET_PVT.validate_header_info to do the necessary
     --header level validations
     PA_BUDGET_PVT.validate_header_info
          ( p_api_version_number          => p_api_version_number
           ,p_api_name                    => l_api_name
           ,p_init_msg_list               => p_init_msg_list
           ,px_pa_project_id              => l_project_id
           ,p_pm_project_reference        => p_pm_project_reference
           ,p_pm_product_code             => p_pm_product_code
           ,px_budget_type_code           => l_budget_type_code
           ,px_fin_plan_type_id           => l_fin_plan_type_id
           ,px_fin_plan_type_name         => l_fin_plan_type_name
           ,px_version_type               => l_version_type
           ,p_budget_version_number       => p_version_number
           ,p_change_reason_code          => NULL
           ,p_function_name               => 'PA_PM_ADD_BUDGET_LINE'
           ,x_budget_entry_method_code    => l_budget_entry_method_code
           ,x_resource_list_id            => l_resource_list_id
           ,x_budget_version_id           => l_budget_version_id
           ,x_fin_plan_level_code         => l_entry_level_code
           ,x_time_phased_code            => l_time_phased_code
           ,x_plan_in_multi_curr_flag     => l_multi_curr_flag
           ,x_budget_amount_code          => l_budget_amount_code
           ,x_categorization_code         => l_categorization_code
           ,x_project_number              => l_amg_project_number
           /* Plan Amount Entry flags introduced by bug 6408139 */
           /*Passing all as G_PA_MISS_CHAR since validations not required*/
           ,px_raw_cost_flag         =>   l_pa_miss_char
           ,px_burdened_cost_flag    =>   l_pa_miss_char
           ,px_revenue_flag          =>   l_pa_miss_char
           ,px_cost_qty_flag         =>   l_pa_miss_char
           ,px_revenue_qty_flag      =>   l_pa_miss_char
           ,px_all_qty_flag          =>   l_pa_miss_char
           ,px_bill_rate_flag        =>   l_pa_miss_char
           ,px_cost_rate_flag        =>   l_pa_miss_char
           ,px_burden_rate_flag      =>   l_pa_miss_char
           /* Plan Amount Entry flags introduced by bug 6408139 */
           ,x_msg_count                   => p_msg_count
           ,x_msg_data                    => p_msg_data
           ,x_return_status               => p_return_status );

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF(l_debug_mode='Y') THEN
                 pa_debug.g_err_stage := 'validate header info API falied';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;


     --Get Task number for AMG Messages

     IF p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).pa_task_id := NULL;
     ELSE
          l_budget_lines_in(1).pa_task_id := p_pa_task_id;
     END IF;

     IF p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).pm_task_reference := NULL;
     ELSE
          l_budget_lines_in(1).pm_task_reference := p_pm_task_reference;
     END IF;

     l_amg_task_number := PA_INTERFACE_UTILS_PUB.get_task_number_amg
     (p_task_number=> ''
     ,p_task_reference => l_budget_lines_in(1).pm_task_reference
     ,p_task_id => l_budget_lines_in(1).pa_task_id);


     --Insert budget line for old FORMS based Budgets Model
     IF l_budget_type_code IS NOT NULL
     THEN

          --Insert BUDGET LINES
          PA_BUDGET_PVT.insert_budget_line
              ( p_return_status              => p_return_status
               ,p_pa_project_id              => l_project_id
               ,p_budget_type_code           => l_budget_type_code
               ,p_pa_task_id                 => p_pa_task_id
               ,p_pm_task_reference          => p_pm_task_reference
               ,p_resource_alias             => p_resource_alias
               ,p_member_id                  => p_resource_list_member_id
               ,p_budget_start_date          => p_budget_start_date
               ,p_budget_end_date            => p_budget_end_date
               ,p_period_name                => p_period_name
               ,p_description                => p_description
               ,p_raw_cost                   => p_raw_cost
               ,p_burdened_cost              => p_burdened_cost
               ,p_revenue                    => p_revenue
               ,p_quantity                   => p_quantity
               ,p_pm_product_code            => p_pm_product_code
               ,p_pm_budget_line_reference   => p_pm_budget_line_reference
               ,p_resource_list_id           => l_resource_list_id
               ,p_attribute_category         => p_attribute_category
               ,p_attribute1                 => p_attribute1
               ,p_attribute2                 => p_attribute2
               ,p_attribute3                 => p_attribute3
               ,p_attribute4                 => p_attribute4
               ,p_attribute5                 => p_attribute5
               ,p_attribute6                 => p_attribute6
               ,p_attribute7                 => p_attribute7
               ,p_attribute8                 => p_attribute8
               ,p_attribute9                 => p_attribute9
               ,p_attribute10                => p_attribute10
               ,p_attribute11                => p_attribute11
               ,p_attribute12                => p_attribute12
               ,p_attribute13                => p_attribute13
               ,p_attribute14                => p_attribute14
               ,p_attribute15                => p_attribute15
               ,p_time_phased_type_code      => l_time_phased_code
               ,p_entry_level_code           => l_entry_level_code
               ,p_budget_amount_code         => l_budget_amount_code
               ,p_budget_entry_method_code   => l_budget_entry_method_code
               ,p_categorization_code        => l_categorization_code
               ,p_budget_version_id          => l_budget_version_id
               ,p_change_reason_code         => p_change_reason_code);

          IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
          THEN
              IF(l_debug_mode='Y') THEN
                     pa_debug.g_err_stage := 'PA_BUDGET_PVT.insert_budget_line API falied - unexpected error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF p_return_status = FND_API.G_RET_STS_ERROR
          THEN
              IF(l_debug_mode='Y') THEN
                     pa_debug.g_err_stage := 'PA_BUDGET_PVT.insert_budget_line API falied - expected error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
          END IF;


          --check for overlapping dates
          PA_BUDGET_LINES_V_PKG.check_overlapping_dates
                    ( x_budget_version_id  => l_budget_version_id  --IN
                     ,x_resource_name  => l_resource_name  --OUT
                     ,x_err_code       => l_err_code       );

          IF l_err_code > 0
          THEN

             IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'check_overlapping_dates API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
             END IF;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.SET_NAME('PA','PA_CHECK_DATES_FAILED');
                 FND_MESSAGE.SET_TOKEN('Rname',l_resource_name);

                 FND_MSG_PUB.add;
             END IF;

             RAISE FND_API.G_EXC_ERROR;

          ELSIF l_err_code < 0
          THEN

             IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'check_overlapping_dates API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
             END IF;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.add_exc_msg
                     (  p_pkg_name       => 'PA_BUDGET_LINES_V_PKG'
                     ,  p_procedure_name => 'CHECK_OVERLAPPING_DATES'
                     ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
             END IF;

             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;


          --summarizing the totals in the table pa_budget_versions
          PA_BUDGET_UTILS.summerize_project_totals
               ( x_budget_version_id => l_budget_version_id
               , x_err_code      => l_err_code
               , x_err_stage     => l_err_stage
               , x_err_stack     => l_err_stack        );

          IF l_err_code > 0  THEN

             IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'summerize_project_totals API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
             END IF;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                 THEN
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'BUDG'
                       ,p_attribute1       => l_amg_project_number
                       ,p_attribute2       => l_amg_task_number
                       ,p_attribute3       => p_budget_type_code
                       ,p_attribute4       => l_resource_name
                       ,p_attribute5       => to_char(p_budget_start_date));
                 ELSE
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => l_err_stage
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'BUDG'
                       ,p_attribute1       => l_amg_project_number
                       ,p_attribute2       => l_amg_task_number
                       ,p_attribute3       => p_budget_type_code
                       ,p_attribute4       => l_resource_name
                       ,p_attribute5       => to_char(p_budget_start_date));
                 END IF;
             END IF;

             RAISE FND_API.G_EXC_ERROR;

          ELSIF l_err_code < 0  THEN

             IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'summerize_project_totals API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
             END IF;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.add_exc_msg
                     (  p_pkg_name       => 'PA_BUDGET_UTILS'
                     ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
                     ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
             END IF;

             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;


     ELSE --insert budget line for new FinPlan model


          --Store the budget line data in budget line table

          IF p_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).resource_alias := NULL;
          ELSE
               l_budget_lines_in(1).resource_alias := p_resource_alias;
          END IF;

          IF p_resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_budget_lines_in(1).resource_list_member_id := NULL;
          ELSE
               l_budget_lines_in(1).resource_list_member_id := p_resource_list_member_id;
          END IF;

          IF p_budget_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
               l_budget_lines_in(1).budget_start_date := NULL;
          ELSE
               l_budget_lines_in(1).budget_start_date := p_budget_start_date;
          END IF;

          IF p_budget_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
               l_budget_lines_in(1).budget_end_date := NULL;
          ELSE
               l_budget_lines_in(1).budget_end_date := p_budget_end_date;
          END IF;

          IF p_period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).period_name := NULL;
          ELSE
               l_budget_lines_in(1).period_name := p_period_name;
          END IF;

          IF p_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).description := NULL;
          ELSE
               l_budget_lines_in(1).description := p_description;
          END IF;

          IF p_raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_budget_lines_in(1).raw_cost := NULL;
          ELSE
               l_budget_lines_in(1).raw_cost := p_raw_cost;
          END IF;

          IF p_burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_budget_lines_in(1).burdened_cost := NULL;
          ELSE
               l_budget_lines_in(1).burdened_cost := p_burdened_cost;
          END IF;

          IF p_revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_budget_lines_in(1).revenue := NULL;
          ELSE
               l_budget_lines_in(1).revenue := p_revenue;
          END IF;

          IF p_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
               l_budget_lines_in(1).quantity := NULL;
          ELSE
               l_budget_lines_in(1).quantity := p_quantity;
          END IF;

          IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).pm_product_code := NULL;
          ELSE
               l_budget_lines_in(1).pm_product_code := p_pm_product_code;
          END IF;

          IF p_pm_budget_line_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).pm_budget_line_reference := NULL;
          ELSE
               l_budget_lines_in(1).pm_budget_line_reference := p_pm_budget_line_reference;
          END IF;

          IF p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute_category := NULL;
          ELSE
               l_budget_lines_in(1).attribute_category := p_attribute_category;
          END IF;

          IF p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute1 := NULL;
          ELSE
               l_budget_lines_in(1).attribute1 := p_attribute1;
          END IF;

          IF p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute2 := NULL;
          ELSE
               l_budget_lines_in(1).attribute2 := p_attribute2;
          END IF;

          IF p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute3 := NULL;
          ELSE
               l_budget_lines_in(1).attribute3 := p_attribute3;
          END IF;

          IF p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute4 := NULL;
          ELSE
               l_budget_lines_in(1).attribute4 := p_attribute4;
          END IF;

          IF p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute5 := NULL;
          ELSE
               l_budget_lines_in(1).attribute5 := p_attribute5;
          END IF;

          IF p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute6 := NULL;
          ELSE
               l_budget_lines_in(1).attribute6 := p_attribute6;
          END IF;

          IF p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute7 := NULL;
          ELSE
               l_budget_lines_in(1).attribute7 := p_attribute7;
          END IF;

          IF p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute8 := NULL;
          ELSE
               l_budget_lines_in(1).attribute8 := p_attribute8;
          END IF;

          IF p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute9 := NULL;
          ELSE
               l_budget_lines_in(1).attribute9 := p_attribute9;
          END IF;

          IF p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute10 := NULL;
          ELSE
               l_budget_lines_in(1).attribute10 := p_attribute10;
          END IF;

          IF p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute11 := NULL;
          ELSE
               l_budget_lines_in(1).attribute11 := p_attribute11;
          END IF;

          IF p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute12 := NULL;
          ELSE
               l_budget_lines_in(1).attribute12 := p_attribute12;
          END IF;

          IF p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute13 := NULL;
          ELSE
               l_budget_lines_in(1).attribute13 := p_attribute13;
          END IF;

          IF p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute14 := NULL;
          ELSE
               l_budget_lines_in(1).attribute14 := p_attribute14;
          END IF;

          IF p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).attribute15 := NULL;
          ELSE
               l_budget_lines_in(1).attribute15 := p_attribute15;
          END IF;

          IF p_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).txn_currency_code := NULL;
          ELSE
               l_budget_lines_in(1).txn_currency_code := p_currency_code;
          END IF;

          IF p_change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
               l_budget_lines_in(1).change_reason_code := NULL;
          ELSE
               l_budget_lines_in(1).change_reason_code := p_change_reason_code;
          END IF;

          --Since currency attributes are defaulted to G_MISS values in
          --PA_BUDGET_PUB.budget_line_in_rec_type so we have to explicitly
          --make them null
          l_budget_lines_in(1).projfunc_cost_rate_type      := NULL;
          l_budget_lines_in(1).projfunc_cost_rate_date_type := NULL;
          l_budget_lines_in(1).projfunc_cost_rate_date      := NULL;
          l_budget_lines_in(1).projfunc_cost_exchange_rate  := NULL;
          l_budget_lines_in(1).projfunc_rev_rate_type       := NULL;
          l_budget_lines_in(1).projfunc_rev_rate_date_type  := NULL;
          l_budget_lines_in(1).projfunc_rev_rate_date       := NULL;
          l_budget_lines_in(1).projfunc_rev_exchange_rate   := NULL;
          l_budget_lines_in(1).project_cost_rate_type       := NULL;
          l_budget_lines_in(1).project_cost_rate_date_type  := NULL;
          l_budget_lines_in(1).project_cost_rate_date       := NULL;
          l_budget_lines_in(1).project_cost_exchange_rate   := NULL;
          l_budget_lines_in(1).project_rev_rate_type        := NULL;
          l_budget_lines_in(1).project_rev_rate_date_type   := NULL;
          l_budget_lines_in(1).project_rev_rate_date        := NULL;
          l_budget_lines_in(1).project_rev_exchange_rate    := NULL;


          --Send the budget version id to validate_budget_lines API for
          --actuals on FORECAST check
          l_version_info_rec.x_budget_version_id := l_budget_version_id;

          --Get entry method options and validate them against cost, rev and quantity passed
          l_amount_set_id := PA_FIN_PLAN_UTILS.get_amount_set_id(l_budget_version_id);

          PA_FIN_PLAN_UTILS.get_plan_amount_flags(
                         P_AMOUNT_SET_ID      => l_amount_set_id
                        ,X_RAW_COST_FLAG      => lx_raw_cost_flag
                        ,X_BURDENED_FLAG      => lx_burdened_cost_flag
                        ,X_REVENUE_FLAG       => lx_revenue_flag
                        ,X_COST_QUANTITY_FLAG => lx_cost_qty_flag
                        ,X_REV_QUANTITY_FLAG  => lx_revenue_qty_flag
                        ,X_ALL_QUANTITY_FLAG  => lx_all_qty_flag
                        ,X_BILL_RATE_FLAG     => l_bill_rate_flag
                        ,X_COST_RATE_FLAG     => l_cost_rate_flag
                        ,X_BURDEN_RATE_FLAG   => l_burden_rate_flag
                        ,x_message_count      => p_msg_count
                        ,x_return_status      => p_return_status
                        ,x_message_data       => p_msg_data) ;

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'get_plan_amount_flags API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          --Derive the value of all_qty_flag based on version_type
          IF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
               l_allow_qty_flag := lx_cost_qty_flag;
          ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
               l_allow_qty_flag := lx_revenue_qty_flag;
          ELSE
               l_allow_qty_flag :=  lx_all_qty_flag;
          END IF;


          --Validate the budget line data
          PA_BUDGET_PVT.Validate_Budget_Lines
               ( p_calling_context             => 'BUDGET_LINE_LEVEL_VALIDATION'
                ,p_pa_project_id               => l_project_id
                ,p_budget_type_code            => l_budget_type_code
                ,p_fin_plan_type_id            => l_fin_plan_type_id
                ,p_version_type                => l_version_type
                ,p_resource_list_id            => l_resource_list_id
                ,p_time_phased_code            => l_time_phased_code
                ,p_budget_entry_method_code    => l_budget_entry_method_code
                ,p_entry_level_code            => l_entry_level_code
                ,p_allow_qty_flag              => l_allow_qty_flag
                ,p_allow_raw_cost_flag         => lx_raw_cost_flag
                ,p_allow_burdened_cost_flag    => lx_burdened_cost_flag
                ,p_allow_revenue_flag          => lx_revenue_flag
                ,p_multi_currency_flag         => l_multi_curr_flag
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
                ,px_budget_lines_in            => l_budget_lines_in
                ,x_budget_lines_out            => l_budget_lines_out_tbl
                ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                ,x_msg_count                   => p_msg_count
                ,x_msg_data                    => p_msg_data
                ,x_return_status               => p_return_status );

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'validate budget lines API falied';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;


          --Copy the fin plan line data into a table of type pa_fp_rollup_tmp

          l_finplan_lines_tab(1).system_reference1            := l_budget_lines_in(1).pa_task_id;
          l_finplan_lines_tab(1).system_reference2            := l_budget_lines_in(1).resource_list_member_id;
          l_finplan_lines_tab(1).start_date                   := l_budget_lines_in(1).budget_start_date;
          l_finplan_lines_tab(1).end_date                     := l_budget_lines_in(1).budget_end_date;
          l_finplan_lines_tab(1).period_name                  := l_budget_lines_in(1).period_name;
          l_finplan_lines_tab(1).txn_currency_code            := l_budget_lines_in(1).txn_currency_code;
          l_finplan_lines_tab(1).txn_raw_cost                 := l_budget_lines_in(1).raw_cost;
          l_finplan_lines_tab(1).txn_burdened_cost            := l_budget_lines_in(1).burdened_cost;
          l_finplan_lines_tab(1).txn_revenue                  := l_budget_lines_in(1).revenue;
          l_finplan_lines_tab(1).quantity                     := l_budget_lines_in(1).quantity;
          l_finplan_lines_tab(1).change_reason_code           := l_budget_lines_in(1).change_reason_code;
          l_finplan_lines_tab(1).description                  := l_budget_lines_in(1).description;
          l_finplan_lines_tab(1).attribute_category           := l_budget_lines_in(1).attribute_category;
          l_finplan_lines_tab(1).attribute1                   := l_budget_lines_in(1).attribute1;
          l_finplan_lines_tab(1).attribute2                   := l_budget_lines_in(1).attribute2;
          l_finplan_lines_tab(1).attribute3                   := l_budget_lines_in(1).attribute3;
          l_finplan_lines_tab(1).attribute4                   := l_budget_lines_in(1).attribute4;
          l_finplan_lines_tab(1).attribute5                   := l_budget_lines_in(1).attribute5;
          l_finplan_lines_tab(1).attribute6                   := l_budget_lines_in(1).attribute6;
          l_finplan_lines_tab(1).attribute7                   := l_budget_lines_in(1).attribute7;
          l_finplan_lines_tab(1).attribute8                   := l_budget_lines_in(1).attribute8;
          l_finplan_lines_tab(1).attribute9                   := l_budget_lines_in(1).attribute9;
          l_finplan_lines_tab(1).attribute10                  := l_budget_lines_in(1).attribute10;
          l_finplan_lines_tab(1).attribute11                  := l_budget_lines_in(1).attribute11;
          l_finplan_lines_tab(1).attribute12                  := l_budget_lines_in(1).attribute12;
          l_finplan_lines_tab(1).attribute13                  := l_budget_lines_in(1).attribute13;
          l_finplan_lines_tab(1).attribute14                  := l_budget_lines_in(1).attribute14;
          l_finplan_lines_tab(1).attribute15                  := l_budget_lines_in(1).attribute15;
          l_finplan_lines_tab(1).projfunc_cost_rate_type      := l_budget_lines_in(1).projfunc_cost_rate_type;
          l_finplan_lines_tab(1).projfunc_cost_rate_date_type := l_budget_lines_in(1).projfunc_cost_rate_date_type;
          l_finplan_lines_tab(1).projfunc_cost_rate_date      := l_budget_lines_in(1).projfunc_cost_rate_date;
          l_finplan_lines_tab(1).projfunc_cost_exchange_rate  := l_budget_lines_in(1).projfunc_cost_exchange_rate;
          l_finplan_lines_tab(1).projfunc_rev_rate_type       := l_budget_lines_in(1).projfunc_rev_rate_type;
          l_finplan_lines_tab(1).projfunc_rev_rate_date_type  := l_budget_lines_in(1).projfunc_rev_rate_date_type;
          l_finplan_lines_tab(1).projfunc_rev_rate_date       := l_budget_lines_in(1).projfunc_rev_rate_date;
          l_finplan_lines_tab(1).projfunc_rev_exchange_rate   := l_budget_lines_in(1).projfunc_rev_exchange_rate;
          l_finplan_lines_tab(1).project_cost_rate_type       := l_budget_lines_in(1).project_cost_rate_type;
          l_finplan_lines_tab(1).project_cost_rate_date_type  := l_budget_lines_in(1).project_cost_rate_date_type;
          l_finplan_lines_tab(1).project_cost_rate_date       := l_budget_lines_in(1).project_cost_rate_date;
          l_finplan_lines_tab(1).project_cost_exchange_rate   := l_budget_lines_in(1).project_cost_exchange_rate;
          l_finplan_lines_tab(1).project_rev_rate_type        := l_budget_lines_in(1).project_rev_rate_type;
          l_finplan_lines_tab(1).project_rev_rate_date_type   := l_budget_lines_in(1).project_rev_rate_date_type;
          l_finplan_lines_tab(1).project_rev_rate_date        := l_budget_lines_in(1).project_rev_rate_date;
          l_finplan_lines_tab(1).project_rev_exchange_rate    := l_budget_lines_in(1).project_rev_exchange_rate;
          l_finplan_lines_tab(1).pm_product_code              := l_budget_lines_in(1).pm_product_code;
          l_finplan_lines_tab(1).pm_budget_line_reference     := l_budget_lines_in(1).pm_budget_line_reference;
          l_finplan_lines_tab(1).quantity_source              := 'I';
          l_finplan_lines_tab(1).raw_cost_source              := 'I';
          l_finplan_lines_tab(1).burdened_cost_source         := 'I';
          l_finplan_lines_tab(1).revenue_source               := 'I';
          l_finplan_lines_tab(1).resource_assignment_id       := -1;


          --Lock the budget version before inserting a budget line
          l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                     (p_budget_version_id => l_budget_version_id);

          PA_FIN_PLAN_PVT.lock_unlock_version
          ( p_budget_version_id       => l_budget_version_id
           ,p_record_version_number   => l_record_version_number
           ,p_action                  => 'L'
           ,p_user_id                 => FND_GLOBAL.User_id
           ,p_person_id               => null
           ,x_return_status           => p_return_status
           ,x_msg_count               => p_msg_count
           ,x_msg_data                => p_msg_data);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                -- Error message is not added here as the api lock_unlock_version
                -- adds the message to stack
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'Failed in locking the version ' || l_budget_version_id;
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;

          --Call PA_FIN_PLAN_PVT.add_fin_plan_lines. This api takes care of inserting
          --budget lines data in all relevant tables.
          PA_FIN_PLAN_PVT.add_fin_plan_lines
               ( p_calling_context      => PA_FP_CONSTANTS_PKG.G_AMG_API--Bug 4224464.Changed this to AMG_API as this is a AMG flow.
                ,p_fin_plan_version_id  => l_budget_version_id
                ,p_finplan_lines_tab    => l_finplan_lines_tab
                ,x_return_status        => p_return_status
                ,x_msg_count            => p_msg_count
                ,x_msg_data             => p_msg_data );

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'PA_FIN_PLAN_PVT.add_fin_plan_lines API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE  FND_API.G_EXC_ERROR;
          END IF;


          --unlock the budget version after inserting the budget line
          l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                     (p_budget_version_id => l_budget_version_id);

          PA_FIN_PLAN_PVT.lock_unlock_version
          ( p_budget_version_id       => l_budget_version_id
           ,p_record_version_number   => l_record_version_number
           ,p_action                  => 'U'
           ,p_user_id                 => FND_GLOBAL.User_id
           ,p_person_id               => null
           ,x_return_status           => p_return_status
           ,x_msg_count               => p_msg_count
           ,x_msg_data                => p_msg_data);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                -- Error message is not added here as the api lock_unlock_version
                -- adds the message to stack
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'Failed in unlocking the version ' || l_budget_version_id;
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;


     END IF; --end of code to insert budget line


     IF FND_API.to_boolean( p_commit )
     THEN
          COMMIT;
     END IF;

     IF(l_debug_mode='Y') THEN
           pa_debug.g_err_stage := 'Exiting ' || l_api_name;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc
     THEN

     ROLLBACK TO add_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and p_msg_data IS NULL THEN
           PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE
           ,p_msg_index      => 1
           ,p_msg_count      => l_msg_count
           ,p_msg_data       => l_msg_data
           ,p_data           => l_data
           ,p_msg_index_out  => l_msg_index_out);
           p_msg_data  := l_data;
           p_msg_count := l_msg_count;
     ELSE
           p_msg_count := l_msg_count;
     END IF;

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;

     RETURN;


     WHEN FND_API.G_EXC_ERROR
     THEN

     ROLLBACK TO add_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN

     ROLLBACK TO add_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN ROW_ALREADY_LOCKED
     THEN

     ROLLBACK TO add_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
           FND_MESSAGE.set_name('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
           FND_MESSAGE.set_token('PROJECT', l_amg_project_number);
           FND_MESSAGE.set_token('TASK', l_amg_task_number);
           FND_MESSAGE.set_token('BUDGET_TYPE', l_budget_type_code);
           FND_MESSAGE.set_token('SOURCE_NAME', '');
           FND_MESSAGE.set_token('START_DATE', '');
           FND_MESSAGE.set_token('ENTITY', 'G_BUDGET_LINE_CODE');
           FND_MSG_PUB.add;
     END IF;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN OTHERS
     THEN

     ROLLBACK TO add_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.add_exc_msg
        (  p_pkg_name       => G_PKG_NAME
        ,  p_procedure_name => l_api_name );
     END IF;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;

END Add_Budget_Line;


----------------------------------------------------------------------------------------
--Name:               delete_draft_budget
--Type:               Procedure
--Description:        This procedure can be used to delete a draft budget
--
--
--Called subprograms:
--
--
--
--History:
--    07-OCT-1996        L. de Werker    Created
--    07-DEC-1996        L. de Werker    Added locking mechanism
--    19-MAR-2003        Srikanth        Made Changes to make this api work for Fin Plan Model
--    11-APR-2005        Rishukla        Bug 4224464: FP M Changes for delete_draft_budget

PROCEDURE delete_draft_budget
( p_api_version_number          IN  NUMBER
 ,p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 -- Parameters required for Fin Plan Model
 ,p_fin_plan_type_name          IN  pa_fin_plan_types_vl.name%TYPE
 ,p_fin_plan_type_id            IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_version_number              IN  pa_budget_versions.version_number%TYPE
 ,p_version_type                IN  pa_budget_versions.version_type%TYPE
 )

IS

      CURSOR l_budget_version_csr
      ( p_project_id NUMBER
      , p_budget_type_code VARCHAR2  )
      IS
      SELECT budget_version_id
      FROM pa_budget_versions
      WHERE project_id = p_project_id
      AND   budget_type_code = p_budget_type_code
      AND   budget_status_code = 'W'
      AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


      CURSOR l_budget_type_csr
      ( p_budget_type_code VARCHAR2 )
      IS
      SELECT 1
      FROM   pa_budget_types
      WHERE  budget_type_code = p_budget_type_code;

      --Bug 4224464: Following cursor has been added as part of
      --FP M Changes for delete_draft_budget
      --This cursor is used to check if a fin_plan_type_id is
      --used to store workplan data
      CURSOR l_use_for_wp_csr
      ( p_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE)
      IS
      SELECT 1
      FROM pa_fin_plan_types_b
      WHERE fin_plan_type_id = p_fin_plan_type_id
      AND   use_for_workplan_flag = 'Y';


      CURSOR l_lock_budget_csr( p_budget_version_id NUMBER )
      IS
      SELECT 'x'
      FROM   pa_budget_versions bv
      ,      pa_resource_assignments ra
      ,      pa_budget_lines bl
      WHERE  bv.budget_version_id = p_budget_version_id
      AND    bv.budget_version_id = ra.budget_version_id (+)
      AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
      AND    bv.ci_id IS NULL         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause bv.ci_id IS NULL--Bug # 3507156

      FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

      l_api_name               CONSTANT    VARCHAR2(30)        := 'delete_draft_budget';

      i                                NUMBER;
      l_return_status                  VARCHAR2(1);
      l_err_code                       NUMBER;
      l_err_stage                      VARCHAR2(120);
      l_err_stack                      VARCHAR2(630);
      l_dummy                          NUMBER :=0;
      l_budget_version_id              NUMBER;
      l_ci_id                          pa_budget_versions.ci_id%TYPE;
      l_project_id                     NUMBER;
      l_budget_type_code               VARCHAR2(30);
      l_msg_count                      NUMBER ;
      l_msg_data                       VARCHAR2(2000);
      l_function_allowed               VARCHAR2(1);
      l_resp_id                        NUMBER := 0;
      l_user_id                        NUMBER := 0;
      l_module_name                    VARCHAR2(80) := g_module_name ||'.DELETE_DRAFT_BUDGET';
      l_fp_options_id                  NUMBER;

      --needed to get the field values associated to a AMG message

      CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
      IS
      SELECT   segment1
      FROM     pa_projects p
      WHERE p.project_id = p_pa_project_id;

      l_amg_segment1       VARCHAR2(25);

      --Included the following variables as part of Changes due to Fin Plan Model
      l_any_error_occurred_flag        VARCHAR2(1):='N';
      l_baseline_funding_flag          VARCHAR2(1):='N';
      l_data                           VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_debug_mode                     VARCHAR2(1);

      l_debug_level3                   CONSTANT NUMBER := 3;
      l_debug_level5                   CONSTANT NUMBER := 5;
      l_security_ret_code              VARCHAR2(1);
      l_fin_plan_type_id               NUMBER;
      l_version_type                   pa_budget_versions.version_type%TYPE;
      l_proj_fp_options_id             NUMBER;
      l_result                         VARCHAR2(1);
      l_record_version_number          pa_budget_versions.record_version_number%TYPE;
      l_fin_plan_type_name             pa_fin_plan_types_tl.name%TYPE;
--Added by Xin Liu. 28-APR-03
      ll_fin_plan_type_id               pa_proj_fp_options.fin_plan_type_id%TYPE;
      ll_fin_plan_type_name             pa_fin_plan_types_tl.name%TYPE;
      ll_version_type                   pa_budget_versions.version_type%TYPE;
      ll_version_number                 pa_budget_versions.version_number%TYPE;

BEGIN

      --  Standard begin of API savepoint

      SAVEPOINT delete_draft_budget_pub;

      --  Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
      THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF ( l_debug_mode = 'Y' )
      THEN
            pa_debug.set_curr_function( p_function   => 'delete_draft_budget',
                                        p_debug_mode => l_debug_mode );
      END IF;

      --  Initialize the message table if requested.

      IF FND_API.TO_BOOLEAN( p_init_msg_list )
      THEN

            FND_MSG_PUB.initialize;

      END IF;
      -- This api will initialize the data that will be used by the map_new_amg_msg.
      l_resp_id := FND_GLOBAL.Resp_id;
      l_user_id := FND_GLOBAL.User_id;

       -- Added Logic by Xin Liu to handle MISS vars based on Manoj's code review.
       -- 28-APR-03
      IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        ll_fin_plan_type_id := NULL;
      ELSE
                        ll_fin_plan_type_id := p_fin_plan_type_id;
      END IF;

      IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        ll_fin_plan_type_name := NULL;
      ELSE
                        ll_fin_plan_type_name := p_fin_plan_type_name;
      END IF;

      IF p_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        ll_version_number := NULL;
      ELSE
                        ll_version_number := p_version_number;
      END IF;


      -- Changes done.


      -- Both Budget Type Code and Fin Plan Type Id should not be null
      -- Changes done by Xin Liu, 24-APR-03, for Fin plan Type Id and Name for G_PA_MISS_XXX
      IF ((p_budget_type_code IS NULL  OR
           p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )  AND
          (p_fin_plan_type_name IS NULL OR p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_fin_plan_type_id IS NULL OR p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) )THEN

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
      -- Changes done by Xin Liu, 24-APR-03, for Fin plan Type Id and Name for G_PA_MISS_XXX
      IF ((p_budget_type_code IS NOT NULL AND
          p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  AND
        ((p_fin_plan_type_name IS NOT NULL AND p_fin_plan_type_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
         (p_fin_plan_type_id IS NOT NULL AND p_fin_plan_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))) THEN

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name        => 'PA_BUDGET_FP_BOTH_NOT_NULL');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info both are provided';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;


--  product_code is mandatory

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
            END IF;
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Product code is missing' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

             -- RAISE FND_API.G_EXC_ERROR;
             l_any_error_occurred_flag:='Y' ;
      END IF;

      l_pm_product_code :='Z';
      /*added for bug no :2413400*/
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
            p_return_status             := FND_API.G_RET_STS_ERROR;
            --RAISE FND_API.G_EXC_ERROR;
            l_any_error_occurred_flag:='Y';
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Product code is invalid' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

      END IF;


      -- convert pm_project_reference to id

      Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => p_pa_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => l_return_status );


      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Unexpected error while getting project id' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Error while getting project id' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE  FND_API.G_EXC_ERROR;

      END IF;

      -- Get segment1 for AMG messages

      OPEN l_amg_project_csr( l_project_id );
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;

     --Do the processing required for budget model
     IF  (p_budget_type_code IS NOT NULL AND
          p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  THEN

            --Check for the security
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                               p_api_version_number => p_api_version_number
                                              ,p_project_id         => l_project_id
                                              ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET
                                              ,p_function_name      => 'PA_PM_DELETE_DRAFT_BUDGET'
                                              ,p_version_type       => null
                                              ,x_return_status      => p_return_status
                                              ,x_ret_code           => l_security_ret_code );

            -- the above API adds the error message to stack. Hence the message is not added here.
            -- Also, as security check is important further validations are not done in case this
            -- validation fails.
            IF (p_return_status<>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code = 'N') THEN
                   -- dbms_output.put_line('Security api failed l_security_ret_code '||l_security_ret_code);
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Security API Failed';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            OPEN l_budget_type_csr( p_budget_type_code );

            FETCH l_budget_type_csr INTO l_dummy;

            IF l_budget_type_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        (p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => p_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget Type is invalid' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  CLOSE l_budget_type_csr;
                  RAISE FND_API.G_EXC_ERROR;

            END IF;

            CLOSE l_budget_type_csr;

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
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  l_any_error_occurred_flag := 'Y';
            END IF;

            -- get the corresponding budget_version_id
            -- we do not verify p_version_number here because
            -- as per FD, this parameter should be ignored for
            -- FORMS budget model.
            OPEN l_budget_version_csr
              (p_project_id       => l_project_id
              ,p_budget_type_code => p_budget_type_code );

            FETCH l_budget_version_csr INTO l_budget_version_id;

            IF l_budget_version_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_NO_BUDGET_VERSION'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => p_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget version does not exist' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;


                  CLOSE l_budget_version_csr;
                  RAISE FND_API.G_EXC_ERROR;

            END IF;

            CLOSE l_budget_version_csr;


            --Check if budgetary control is enabled for this project and budget version
            --If a record is present for this budget version in PA_BC_BALANCES table
            --then we do not proceed with delete.
            IF ( PA_BUDGET_PVT.is_bc_enabled_for_budget(l_budget_version_id) )
            THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Cannnot delete budget version - '
                                             || 'budgetary control is enabled';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.ADD_MESSAGE(
                                 p_app_short_name  => 'PA'
                                ,p_msg_name        => 'PA_FP_DEL_BC_ENABLED_BV_AMG'
                                ,p_token1          => 'PROJECT'
                                ,p_value1          => l_amg_segment1
                                ,p_token2          => 'BUDGET_TYPE'
                                ,p_value2          => p_budget_type_code
                                ,p_token3          => 'BUDGET_VERSION_ID'
                                ,p_value3          => l_budget_version_id);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            END IF;--budgetary control enabled check


            OPEN l_lock_budget_csr( l_budget_version_id );

            --Stop Further processing if any errors are reported
            IF(l_any_error_occurred_flag='Y') THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'About to display all the messages';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            PA_BUDGET_UTILS.delete_draft( x_budget_version_id   => l_budget_version_id
                                         ,x_err_code            => l_err_code
                                         ,x_err_stage           => l_err_stage
                                         ,x_err_stack           => l_err_stack  );

            IF l_err_code > 0
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN

                        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                        THEN
                              IF(l_debug_mode='Y') THEN
                                    pa_debug.g_err_stage := 'Delete draft falied';
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => 'PA_DELETE_DRAFT_FAILED'
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => ''
                              ,p_attribute3       => p_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => '');
                        ELSE
                              IF(l_debug_mode='Y') THEN
                                    pa_debug.g_err_stage := 'Error in Delete draft';
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;

                              pa_interface_utils_pub.map_new_amg_msg
                              ( p_old_message_code => l_err_stage
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => ''
                              ,p_attribute3       => p_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => '');
                              END IF;

                        END IF;

                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0
            THEN


                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                        IF(l_debug_mode='Y') THEN
                              pa_debug.g_err_stage := 'Unexpected Error in Delete draft';
                              pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;

                        FND_MSG_PUB.add_exc_msg
                        (  p_pkg_name       => 'PA_BUDGET_UTILS'
                        ,  p_procedure_name => 'DELETE_DRAFT'
                        ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            CLOSE l_lock_budget_csr; --FYI, does not release locks


      ELSE -- Fin Plan Model


            -- validate the plan type passed
            PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
                                           ( p_fin_plan_type_id    => ll_fin_plan_type_id
                                            ,p_fin_plan_type_name  => ll_fin_plan_type_name
                                            ,x_fin_plan_type_id    => l_fin_plan_type_id
                                            ,x_return_status       => p_return_status
                                            ,x_msg_count           => p_msg_count
                                            ,x_msg_data            => p_msg_data);
            -- Throw the error if the above API is not successfully executed
            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Can not get the value of Fin Plan Type Id' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --Bug 4224464: Following validation has been added as part of
            --FP M Changes for delete_draft_budget
            --check if the fin_plan_type_id is used to store workplan data
            --first reset the value of l_dummy
            l_dummy := 0;
            OPEN l_use_for_wp_csr( l_fin_plan_type_id );
            FETCH l_use_for_wp_csr INTO l_dummy;
            CLOSE l_use_for_wp_csr;

            IF l_dummy = 1
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_DEL_WP_DATA');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Fin Plan Type Id is used for WP' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --Validate / get the version type
            --Changes done by Xin Liu for post_fpk. Check if p_version_type is G_PA_MISS_CHAR.  24-APR-03
            IF p_version_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                 l_version_type := NULL;
            ELSE
                 l_version_type := p_version_type;
            END IF;
            --Changes Done.

            pa_fin_plan_utils.get_version_type
                 ( p_project_id        => l_project_id
                  ,p_fin_plan_type_id  => l_fin_plan_type_id
                  ,px_version_type     => l_version_type
                  ,x_return_status     => p_return_status
                  ,x_msg_count         => p_msg_count
                  ,x_msg_data          => p_msg_data);

            IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Failed in get_Version_type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                               -- dbms_output.put_line('Exc in getting ver type');

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --Check for the security
            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                                               p_api_version_number => p_api_version_number
                                              ,p_project_id         => l_project_id
                                              ,p_fin_plan_type_id   => l_fin_plan_type_id /* Bug 3139924 */
                                              ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                                              ,p_function_name      => 'PA_PM_DELETE_DRAFT_BUDGET'
                                              ,p_version_type       => l_version_type
                                              ,x_return_status      => p_return_status
                                              ,x_ret_code           => l_security_ret_code );

            IF (p_return_status <>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code='N') THEN
                 -- dbms_output.put_line('Exc in security');
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Security API failed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Bug 4224464: Following validation has been added as part of
            --FP M Changes for delete_draft_budget.
            --If version number is null, then current working version should be
            --deleted. If current working version doesn't exist then error
            --message is thrown
            IF ll_version_number IS NULL THEN

                  PA_FIN_PLAN_UTILS.get_curr_working_version_info
                  ( p_project_id          => l_project_id
                   ,p_fin_plan_type_id    => l_fin_plan_type_id
                   ,p_version_type        => l_version_type
                   ,x_fp_options_id       => l_fp_options_id
                   ,x_fin_plan_version_id => l_budget_version_id
                   ,x_return_status       => p_return_status
                   ,x_msg_count           => p_msg_count
                   ,x_msg_data            => p_msg_data );

            ELSE --version_number not NULL
            --Derive the version Id depending on the parameters passed as input.

                  PA_FIN_PLAN_UTILS.get_version_id
                  (  p_project_id        => l_project_id
                    ,p_fin_plan_type_id  => l_fin_plan_type_id
                    ,p_version_type      => l_version_type
                    ,p_version_number    => ll_version_number
                    ,x_budget_version_id => l_budget_version_id
                    ,x_ci_id             => l_ci_id  -- 2863564
                    ,x_return_status     => p_return_status
                    ,x_msg_count         => p_msg_count
                    ,x_msg_data          => p_msg_data );

                  -- If the budget version is a control item version throw error
                  IF l_ci_id IS NOT NULL THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                              PA_UTILS.ADD_MESSAGE(
                              p_app_short_name  => 'PA'
                             ,p_msg_name        => 'PA_FP_CI_VERSION_NON_EDITABLE'
                             ,p_token1          => 'BUDGET_VERSION_ID'
                             ,p_value1          => l_budget_version_id);
                        END IF;
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'i/p version is ci version' ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

            END IF; --version_number IS NULL

            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'get Version Id Failed ' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            IF l_budget_version_id IS NULL THEN

                  --Get the plan type name
                  SELECT  name
                  INTO    l_fin_plan_type_name
                  FROM    pa_fin_plan_types_vl
                  WHERE   fin_plan_type_id = l_fin_plan_type_id;

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_FP_NO_WORKING_VERSION'
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => l_amg_segment1
                        ,p_token2         => 'PLAN_TYPE'
                        ,p_value2         => l_fin_plan_type_name
                        ,p_token3         => 'VERSION_NUMBER'
                        ,p_value3         => ll_version_number );
                  END IF;

                  IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Working Budget Version does not exist' ;
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --Bug 4224464: Following validation has been added as part of
            --FP M Changes for delete_draft_budget. If the budget version
            --belongs to an org forecast project then throw an error
            IF (PA_FIN_PLAN_UTILS.is_orgforecast_plan(l_budget_version_id) = 'Y')
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_DEL_ORG_FCST_PLAN');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Cannot delete draft budgets attached' ||
                                                'to an organisation forecasting project';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  p_return_status    := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag:='Y' ;
            END IF; --org_forecast = 'Y'

            --Lock the version before deleting it
            l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                       (p_budget_version_id => l_budget_version_id);
            pa_fin_plan_pvt.lock_unlock_version
            ( p_budget_version_id       => l_budget_version_id
             ,p_record_version_number   => l_record_version_number
             ,p_action                  => 'L'
             ,p_user_id                 => l_user_id
             ,p_person_id               => null
             ,x_return_status           => p_return_status
             ,x_msg_count               => p_msg_count
             ,x_msg_data                => p_msg_data);

             IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                  -- Error message is not added here as the api lock_unlock_version
                  -- adds the message to stack
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Failed in locking the version';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  l_any_error_occurred_flag:='Y';
            END IF;

            --Stop Further processing if any errors are reported
            IF(l_any_error_occurred_flag='Y') THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'About to display all the messages';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Delete the version
            l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                       (p_budget_version_id => l_budget_version_id);
            PA_FIN_PLAN_PUB.Delete_Version
            ( p_project_id               => l_project_id
             ,p_budget_version_id        => l_budget_version_id
             ,p_record_version_number    => l_record_version_number
             ,x_return_status            => p_return_status
             ,x_msg_count                => p_msg_count
             ,x_msg_data                 => p_msg_data );

             IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Failed in deleting the version';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Bug 4224464: Following DMLs have been added as part of
            --FP M Changes for delete_draft_budget
            --If the budget version being deleted is a generation source
            --then we null out the GEN_SRC_XXX_PLAN_VERSION_ID column in
            --pa_proj_fp_options table and increase the record_version_no
            IF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_cost_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_cost_plan_version_id = l_budget_version_id;
            ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_rev_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_rev_plan_version_id = l_budget_version_id;
            ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_all_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_all_plan_version_id = l_budget_version_id;
            END IF;

            --if any record had been updated in pa_proj_fp_options then
            --we do a dummy update in pa_budget_versions also for the
            --budget version that is being updated to increase the record version number
            IF SQL%ROWCOUNT > 0 THEN
                  UPDATE pa_budget_versions
                  SET record_version_number = record_version_number + 1,
                  last_update_date = SYSDATE,
                  last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                  last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE project_id = l_project_id
                  AND   budget_version_id = l_budget_version_id;
            END IF;


      END IF;


      IF fnd_api.to_boolean(p_commit)
      THEN
            COMMIT;
      END IF;


      IF(l_debug_mode='Y') THEN
            pa_debug.g_err_stage := 'Exiting delete draft budget';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

            p_return_status := FND_API.G_RET_STS_ERROR;
            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count = 1 and p_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                    (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
                p_msg_data := l_data;
                p_msg_count := l_msg_count;
            ELSE
                p_msg_count := l_msg_count;
            END IF;
            IF ( l_debug_mode = 'Y' ) THEN
                  pa_debug.reset_curr_function;
            END IF;
            RETURN;

    WHEN FND_API.G_EXC_ERROR
    THEN

    ROLLBACK TO delete_draft_budget_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );
     IF ( l_debug_mode = 'Y' ) THEN
          pa_debug.reset_curr_function;
     END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

    ROLLBACK TO delete_draft_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );
    IF ( l_debug_mode = 'Y' ) THEN
          pa_debug.reset_curr_function;
     END IF;

    WHEN ROW_ALREADY_LOCKED
    THEN
    ROLLBACK TO delete_draft_budget_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
      FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
      FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
      FND_MESSAGE.SET_TOKEN('TASK',    '');
      FND_MESSAGE.SET_TOKEN('BUDGET_TYPE', p_budget_type_code);
      FND_MESSAGE.SET_TOKEN('SOURCE_NAME', '');
      FND_MESSAGE.SET_TOKEN('START_DATE', '');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'G_BUDGET_CODE');
      FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );
     IF ( l_debug_mode = 'Y' ) THEN
          pa_debug.reset_curr_function;
     END IF;

    WHEN OTHERS THEN

    ROLLBACK TO delete_draft_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

    END IF;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );
     IF ( l_debug_mode = 'Y' ) THEN
          pa_debug.reset_curr_function;
     END IF;

END delete_draft_budget;


----------------------------------------------------------------------------------------
--Name:               delete_baseline_budget
--Type:               Procedure
--Description:        This procedure can be used to delete an existing baseline budget
--                    version except the current original and current baseline budget
--                    versions.
--
--Called subprograms:
--    FND_API.compatible_api_call
--    PA_PROJECT_PVT.convert_pm_projref_to_id
--    PA_PM_FUNCTION_SECURITY_PUB.check_budget_security
--    PA_BUDGET_UTILS.delete_draft
--    PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
--    PA_FIN_PLAN_UTILS.get_version_type
--    PA_FIN_PLAN_UTILS.is_orgforecast_plan
--    PA_FIN_PLAN_UTILS.retrieve_record_version_number
--    PA_FIN_PLAN_PVT.lock_unlock_version
--    PA_FIN_PLAN_PUB.delete_version
--
--History:
--    05-APR-2005     Rishukla    Created.

PROCEDURE delete_baseline_budget
( p_api_version_number          IN  NUMBER
 ,p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER
 ,p_msg_data                    OUT NOCOPY VARCHAR2
 ,p_return_status               OUT NOCOPY VARCHAR2
 ,p_pm_product_code             IN  pa_projects_all.pm_product_code%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN  pa_projects_all.project_id%TYPE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  pa_projects_all.pm_project_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  pa_budget_versions.budget_type_code%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_type_id            IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name          IN  pa_fin_plan_types_vl.name%TYPE            :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                IN  pa_budget_versions.version_type%TYPE      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number              IN  pa_budget_versions.version_number%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 )

IS

      --This cursor is used to check if a valid combination of
      --project_id, budget_type_code and version_number has
      --been passed to this api for a baseline budget
      --version. If yes, then current and current_original
      --flags and budget_version_id are retrieved
      CURSOR l_budget_version_no_csr
      ( p_project_id NUMBER
      , p_budget_type_code VARCHAR2
      , p_version_number NUMBER )
      IS
      SELECT budget_version_id
            ,current_flag
            ,current_original_flag
      FROM pa_budget_versions
      WHERE project_id = p_project_id
      AND   budget_type_code = p_budget_type_code
      AND   version_number = p_version_number
      AND   budget_status_code = 'B';

      l_budget_version_no_rec   l_budget_version_no_csr%ROWTYPE;


      --This cursor is used to check if a valid combination of
      --project_id, fin_plan_type_id, version_type and version_number
      --has been passed to this api for a baseline budget
      --version. If yes, then budget_version_id is retrieved
      CURSOR l_finplan_version_no_csr
      ( p_project_id NUMBER
      , p_fin_plan_type_id NUMBER
      , p_version_type VARCHAR2
      , p_version_number NUMBER )
      IS
      SELECT budget_version_id
      FROM pa_budget_versions
      WHERE project_id = p_project_id
      AND   fin_plan_type_id = p_fin_plan_type_id
      AND   version_type = p_version_type
      AND   version_number = p_version_number
      AND   ci_id IS NULL --Added for better readability (Venketesh's suggestion)
      AND   budget_status_code = 'B';

      --This cursor is used to verify a budget_type_code
      CURSOR l_budget_type_csr
      ( p_budget_type_code VARCHAR2 )
      IS
      SELECT 1
      FROM   pa_budget_types
      WHERE  budget_type_code = p_budget_type_code;

      --This cursor is used to check if a fin_plan_type_id is
      --used to store workplan data
      CURSOR l_use_for_wp_csr
      ( p_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE)
      IS
      SELECT 1
      FROM pa_fin_plan_types_b
      WHERE fin_plan_type_id = p_fin_plan_type_id
      AND   use_for_workplan_flag = 'Y';

      --needed to get the field values associated to a AMG message
      CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
      IS
      SELECT   segment1
      FROM     pa_projects p
      WHERE p.project_id = p_pa_project_id;

      l_amg_segment1                   VARCHAR2(25);

      l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_BASELINE_BUDGET';
      l_module_name           CONSTANT VARCHAR2(100)  := g_module_name || '.DELETE_BASELINE_BUDGET';

      l_return_status                  VARCHAR2(1);
      l_err_code                       NUMBER;
      l_err_stage                      VARCHAR2(120);
      l_err_stack                      VARCHAR2(630);
      l_dummy                          NUMBER := 0;

      l_msg_count                      NUMBER := 0;
      l_msg_data                       VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_data                           VARCHAR2(2000);

      l_any_error_occurred_flag        VARCHAR2(1):='N';

      l_debug_mode                     VARCHAR2(1);
      l_debug_level2          CONSTANT NUMBER := 2;
      l_debug_level3          CONSTANT NUMBER := 3;
      l_debug_level4          CONSTANT NUMBER := 4;
      l_debug_level5          CONSTANT NUMBER := 5;

      l_security_ret_code              VARCHAR2(1);
      l_function_name                  VARCHAR2(80);
      l_record_version_number          pa_budget_versions.record_version_number%TYPE;

      l_project_id                     NUMBER;
      l_budget_type_code               pa_budget_versions.budget_type_code%TYPE;
      l_budget_version_id              NUMBER;
      l_fin_plan_type_id               NUMBER;
      l_fin_plan_type_name             pa_fin_plan_types_vl.name%TYPE;
      l_version_type                   pa_budget_versions.version_type%TYPE;
      l_version_number                 NUMBER;
      l_pm_product_code                pa_projects_all.pm_product_code%TYPE;


BEGIN

      --Standard begin of API savepoint

      SAVEPOINT delete_baseline_budget_pub;

      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF ( l_debug_mode = 'Y' )
      THEN
            pa_debug.set_curr_function( p_function   => 'delete_baseline_budget',
                                        p_debug_mode => l_debug_mode );
      END IF;

      IF ( l_debug_mode = 'Y' )
      THEN
            pa_debug.g_err_stage:='Entering ' || l_api_name;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --Initialize the message table if requested.

      IF FND_API.to_boolean( p_init_msg_list )
      THEN
            FND_MSG_PUB.initialize;
      END IF;

      --Standard call to check for call compatibility.

      IF NOT FND_API.compatible_api_call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
      THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --Convert following IN parameters from G_PA_MISS_XXX to null

      IF p_pa_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_project_id := NULL;
      ELSE
            l_project_id := p_pa_project_id;
      END IF;

      IF p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            l_budget_type_code := NULL;
      ELSE
            l_budget_type_code := p_budget_type_code;
      END IF;

      IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_fin_plan_type_id := NULL;
      ELSE
            l_fin_plan_type_id := p_fin_plan_type_id;
      END IF;

      IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            l_fin_plan_type_name := NULL;
      ELSE
            l_fin_plan_type_name := p_fin_plan_type_name;
      END IF;

      IF p_version_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
            l_version_type := NULL;
      ELSE
            l_version_type := p_version_type;
      END IF;

      IF p_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_version_number := NULL;
      ELSE
            l_version_number := p_version_number;
      END IF;

      --Both Budget Type Code and Fin Plan Type Id should not be null simultaneously

      IF (l_budget_type_code IS NULL  AND  l_fin_plan_type_name IS NULL  AND  l_fin_plan_type_id IS NULL)
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  PA_UTILS.add_message
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_BUDGET_FP_BOTH_MISSING');
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Fin Plan type info and budget type info are missing';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Both Budget Type Code and Fin Plan Type Id should not be not null simultaneously

      IF ((l_budget_type_code IS NOT NULL)  AND
         (l_fin_plan_type_name IS NOT NULL OR l_fin_plan_type_id IS NOT NULL ))
      THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  PA_UTILS.add_message
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
            --This function checks if the message being written to the message table
            --is higher or equal to the message level threshold.
            THEN
                  PA_UTILS.add_message
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_PRODUCT_CODE_IS_MISSING_AMG');
            END IF;
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Product code is missing' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            p_return_status    := FND_API.G_RET_STS_ERROR;
            l_any_error_occurred_flag:='Y' ;

      ELSE --p_pm_product_code is not null

            l_pm_product_code :='Z';
            OPEN p_product_code_csr (p_pm_product_code);
            FETCH p_product_code_csr INTO l_pm_product_code;
            CLOSE p_product_code_csr;

            IF l_pm_product_code <> 'X'
            THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_PRODUCT_CODE_IS_INVALID_AMG');
                  END IF;
                  p_return_status    := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag:='Y';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Product code is invalid' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

            END IF; --l_pm_product_code <> 'X'

      END IF; --p_pm_product_code IS NULL


      --p_version_number is mandatory
      IF l_version_number IS NULL
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                  PA_UTILS.add_message
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_FP_VERSION_NUMBER_REQD');
            END IF;
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Version Number is missing' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            p_return_status    := FND_API.G_RET_STS_ERROR;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF; --l_version_number IS NULL


      --convert pm_project_reference to id
      PA_PROJECT_PVT.convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => l_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => l_return_status );

      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Unexpected error while getting project id' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Error while getting project id' ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
            END IF;

            RAISE  FND_API.G_EXC_ERROR;

      END IF;

      -- Get segment1 for AMG messages
      OPEN l_amg_project_csr( l_project_id );
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;


      --Do the processing required for budget model
      IF  (l_budget_type_code IS NOT NULL)  THEN

            --Verify the budget type code passed
            OPEN l_budget_type_csr( l_budget_type_code );
            FETCH l_budget_type_csr INTO l_dummy;

            IF l_budget_type_csr%NOTFOUND
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_INTERFACE_UTILS_PUB.map_new_amg_msg
                        ( p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => l_budget_type_code
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget Type is invalid' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  CLOSE l_budget_type_csr;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF; --l_budget_type_csr%NOTFOUND
            CLOSE l_budget_type_csr;

            --Verify the version number passed and derive budget_version_id if it is valid
            OPEN l_budget_version_no_csr
              (p_project_id       => l_project_id
              ,p_budget_type_code => l_budget_type_code
              ,p_version_number   => l_version_number);
            FETCH l_budget_version_no_csr INTO l_budget_version_no_rec;
            CLOSE l_budget_version_no_csr;

            IF (l_budget_version_no_rec.budget_version_id IS NULL)
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_VERSION_NO_IS_INVALID');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget version number is invalid' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  p_return_status    := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE --l_budget_version_no_rec has been fetched

                  IF (l_budget_version_no_rec.current_flag = 'Y'
                  OR  l_budget_version_no_rec.current_original_flag = 'Y') THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                              PA_UTILS.add_message
                              (p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_DEL_CUR_OR_ORIG_BASELINE');
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'baseline versions marked as current' ||
                                                      'or current original can not be deleted';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;

                        p_return_status    := FND_API.G_RET_STS_ERROR;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
            END IF; --l_budget_version_no_rec.budget_version_id IS NULL

            --Check for the security. We select the function security based
            --on whether the budget type is Approved or not.
            IF (l_budget_type_code = 'AC' OR l_budget_type_code = 'AR')
            THEN
                  --Approved Budget (Cost or Revenue)
                  l_function_name:='PA_FP_DEL_BSLN_APPRVD_BDGT';
            ELSE --for baseline budgets the only other values should be 'FR' or user defined
                  --Budget (not approved cost or revenue)
                  l_function_name:='PA_FP_DEL_BSLN_BDGT';
            END IF;

            PA_PM_FUNCTION_SECURITY_PUB.check_budget_security (
                                               p_api_version_number => p_api_version_number
                                              ,p_project_id         => l_project_id
                                              ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET
                                              ,p_function_name      => l_function_name
                                              ,p_version_type       => null
                                              ,x_return_status      => p_return_status
                                              ,x_ret_code           => l_security_ret_code );

            -- the above API adds the error message to stack. Hence the message is not added here.
            -- Also, as security check is important further validations are not done in case this
            -- validation fails.
            IF (p_return_status<>FND_API.G_RET_STS_SUCCESS OR l_security_ret_code = 'N')
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Security API Failed';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;


            --Check if budgetary control is enabled for this project and budget version
            --If a record is present for this budget version in PA_BC_BALANCES table
            --then we do not proceed with delete.
            IF ( PA_BUDGET_PVT.is_bc_enabled_for_budget(l_budget_version_no_rec.budget_version_id) )
            THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Cannnot delete budget version - '
                                             || 'budgetary control is enabled';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.ADD_MESSAGE(
                                 p_app_short_name  => 'PA'
                                ,p_msg_name        => 'PA_FP_DEL_BC_ENABLED_BV_AMG'
                                ,p_token1          => 'PROJECT'
                                ,p_value1          => l_amg_segment1
                                ,p_token2          => 'BUDGET_TYPE'
                                ,p_value2          => l_budget_type_code
                                ,p_token3          => 'BUDGET_VERSION_ID'
                                ,p_value3          => l_budget_version_no_rec.budget_version_id);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

            END IF;--budgetary control enabled check


            --Stop Further processing if any errors are reported
            IF(l_any_error_occurred_flag='Y') THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'About to display all the messages';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Calling delete API
            PA_BUDGET_UTILS.delete_draft( x_budget_version_id   => l_budget_version_no_rec.budget_version_id
                                         ,x_err_code            => l_err_code
                                         ,x_err_stage           => l_err_stage
                                         ,x_err_stack           => l_err_stack );

            IF l_err_code > 0  THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        IF NOT PA_PROJECT_PVT.check_valid_message(l_err_stage)
                        THEN
                              IF(l_debug_mode='Y') THEN
                                    pa_debug.g_err_stage := 'PA_BUDGET_UTILS.DELETE_DRAFT falied';
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              PA_INTERFACE_UTILS_PUB.map_new_amg_msg
                              ( p_old_message_code => 'PA_DELETE_DRAFT_FAILED'
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => ''
                              ,p_attribute3       => l_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => '');

                        ELSE   --valid error message has been returned by Delete_Draft

                              IF(l_debug_mode='Y') THEN
                                    pa_debug.g_err_stage := 'Error in Delete_draft api';
                                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                              END IF;
                              PA_INTERFACE_UTILS_PUB.map_new_amg_msg
                              ( p_old_message_code => l_err_stage
                              ,p_msg_attribute    => 'CHANGE'
                              ,p_resize_flag      => 'N'
                              ,p_msg_context      => 'BUDG'
                              ,p_attribute1       => l_amg_segment1
                              ,p_attribute2       => ''
                              ,p_attribute3       => l_budget_type_code
                              ,p_attribute4       => ''
                              ,p_attribute5       => '');
                        END IF;

                  END IF; --FND_MSG_PUB.check_msg_level
                  RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0  THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                        IF(l_debug_mode='Y') THEN
                              pa_debug.g_err_stage := 'Unexpected Error in Delete_draft api';
                              pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;

                        FND_MSG_PUB.add_exc_msg
                        (  p_pkg_name       => 'PA_BUDGET_UTILS'
                        ,  p_procedure_name => 'DELETE_DRAFT'
                        ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
                  END IF; --FND_MSG_PUB.check_msg_level

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF; --l_err_code > 0

      ELSE --finplan model

            --validate the plan type passed
            PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
                         ( p_fin_plan_type_id    => l_fin_plan_type_id
                          ,p_fin_plan_type_name  => l_fin_plan_type_name
                          ,x_fin_plan_type_id    => l_fin_plan_type_id
                          ,x_return_status       => p_return_status
                          ,x_msg_count           => p_msg_count
                          ,x_msg_data            => p_msg_data);
            --Throw the error if the above API is not successfully executed
            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Cannot get the value of Fin Plan Type Id' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --check if the fin_plan_type_id is used to store workplan data
            --first reset the l_dummy value
            l_dummy := 0;
            OPEN l_use_for_wp_csr( l_fin_plan_type_id );
            FETCH l_use_for_wp_csr INTO l_dummy;
            CLOSE l_use_for_wp_csr;

            IF l_dummy = 1
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_DEL_WP_DATA');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Fin Plan Type Id is used for WP' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

            --Validate / get the version type
            PA_FIN_PLAN_UTILS.get_version_type
                 ( p_project_id        => l_project_id
                  ,p_fin_plan_type_id  => l_fin_plan_type_id
                  ,px_version_type     => l_version_type
                  ,x_return_status     => p_return_status
                  ,x_msg_count         => p_msg_count
                  ,x_msg_data          => p_msg_data);

            IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Failed in get_Version_type' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Check for the security
            l_function_name:='PA_PM_DELETE_BASELINE_BUDGET';
            PA_PM_FUNCTION_SECURITY_PUB.check_budget_security (
                                        p_api_version_number => p_api_version_number
                                       ,p_project_id         => l_project_id
                                       ,p_fin_plan_type_id   => l_fin_plan_type_id
                                       ,p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                                       ,p_function_name      => l_function_name
                                       ,p_version_type       => l_version_type
                                       ,x_return_status      => p_return_status
                                       ,x_ret_code           => l_security_ret_code );

            IF (p_return_status <>FND_API.G_RET_STS_SUCCESS OR
                l_security_ret_code='N') THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Security API failed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Verify the version number passed and derive budget_version_id if it is valid
            OPEN l_finplan_version_no_csr
              (p_project_id       => l_project_id
              ,p_fin_plan_type_id => l_fin_plan_type_id
              ,p_version_type     => l_version_type
              ,p_version_number   => l_version_number);
            FETCH l_finplan_version_no_csr INTO l_budget_version_id;
            CLOSE l_finplan_version_no_csr;

            IF (l_budget_version_id IS NULL)
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_VERSION_NO_IS_INVALID');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Budget version number is invalid' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  p_return_status    := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag:='Y' ;
            END IF; --l_budget_version_id IS NULL

            --if the budget version belongs to an org forecast project then throw an error
            IF (PA_FIN_PLAN_UTILS.is_orgforecast_plan(l_budget_version_id) = 'Y')
            THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                        PA_UTILS.add_message
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_CANT_DEL_ORG_FCST_PLAN');
                  END IF;
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Cannot delete baseline budgets attached' ||
                                                'to an organisation forecasting project';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  p_return_status    := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag:='Y' ;
            END IF; --org_forecast = 'Y'

            --Stop Further processing if any errors are reported
            IF(l_any_error_occurred_flag='Y') THEN
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'About to display all the messages';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  l_any_error_occurred_flag := 'Y';
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --Delete the version
            l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                       (p_budget_version_id => l_budget_version_id);
            PA_FIN_PLAN_PUB.delete_version
            ( p_project_id               => l_project_id
             ,p_budget_version_id        => l_budget_version_id
             ,p_record_version_number    => l_record_version_number
             ,x_return_status            => p_return_status
             ,x_msg_count                => p_msg_count
             ,x_msg_data                 => p_msg_data );

             IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Failed in deleting the version';
                        pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --If the budget version being deleted is a generation source
            --then we null out the GEN_SRC_XXX_PLAN_VERSION_ID column in
            --pa_proj_fp_options table and increase the record_version_no
            IF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_cost_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_cost_plan_version_id = l_budget_version_id;
            ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_rev_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_rev_plan_version_id = l_budget_version_id;
            ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL
            THEN
                  UPDATE pa_proj_fp_options
                  SET    gen_src_all_plan_version_id = NULL,
                         record_version_number = record_version_number + 1,
                         last_update_date = SYSDATE,
                         last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                         last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE  project_id = l_project_id
                  AND    gen_src_all_plan_version_id = l_budget_version_id;
            END IF;

            --if any record had been updated in pa_proj_fp_options then
            --we do a dummy update in pa_budget_versions also for the
            --budget version that is being updated to increase the record version number
            IF SQL%ROWCOUNT > 0 THEN
                  UPDATE pa_budget_versions
                  SET record_version_number = record_version_number + 1,
                  last_update_date = SYSDATE,
                  last_updated_by = to_number(nvl(fnd_profile.value('USER_ID'),fnd_global.user_id)),
                  last_update_login = FND_GLOBAL.LOGIN_ID
                  WHERE project_id = l_project_id
                  AND   budget_version_id = l_budget_version_id;
            END IF;

      End IF; --l_budget_type_code IS NOT NULL


      IF fnd_api.to_boolean(p_commit)
      THEN
            COMMIT;
      END IF;

      IF(l_debug_mode='Y') THEN
            pa_debug.g_err_stage := 'Exiting delete baseline budget version';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc
      THEN

      p_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 and p_msg_data IS NULL THEN
            PA_INTERFACE_UTILS_PUB.get_messages
            (p_encoded        => FND_API.G_TRUE
            ,p_msg_index      => 1
            ,p_msg_count      => l_msg_count
            ,p_msg_data       => l_msg_data
            ,p_data           => l_data
            ,p_msg_index_out  => l_msg_index_out);
            p_msg_data  := l_data;
            p_msg_count := l_msg_count;
      ELSE
            p_msg_count := l_msg_count;
      END IF;

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      RETURN;

      WHEN FND_API.G_EXC_ERROR
      THEN

      ROLLBACK TO delete_baseline_budget_pub;

      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  p_msg_count ,
          p_data      =>  p_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN

      ROLLBACK TO delete_baseline_budget_pub;

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  p_msg_count ,
          p_data      =>  p_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      WHEN ROW_ALREADY_LOCKED
      THEN
      ROLLBACK TO delete_baseline_budget_pub;

      p_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
            FND_MESSAGE.set_name('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
            FND_MESSAGE.set_token('PROJECT', l_amg_segment1);
            FND_MESSAGE.set_token('TASK', '');
            FND_MESSAGE.set_token('BUDGET_TYPE', p_budget_type_code);
            FND_MESSAGE.set_token('SOURCE_NAME', '');
            FND_MESSAGE.set_token('START_DATE', '');
            FND_MESSAGE.set_token('ENTITY', 'G_BUDGET_CODE');
            FND_MSG_PUB.add;
      END IF;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  p_msg_count ,
          p_data      =>  p_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

      WHEN OTHERS THEN

      ROLLBACK TO delete_baseline_budget_pub;

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

      END IF;

      FND_MSG_PUB.count_and_get
      (   p_count     =>  p_msg_count ,
          p_data      =>  p_msg_data  );

      IF ( l_debug_mode = 'Y' ) THEN
            pa_debug.reset_curr_function;
      END IF;

END delete_baseline_budget;



----------------------------------------------------------------------------------------
--Name:               delete_budget_line
--Type:               Procedure
--Description:        This procedure can be used to delete a budget_line of a draft budget
--
--
--Called subprograms:
--
--
--
--History:
--    07-OCT-1996        L. de Werker    Created
--    28-NOV-1996    L. de Werker    Add parameter p_period_name and functionality to get
--                   start_date from p_period_name
--    07-DEC-1996    L. de Werker    Added locking mechanism
--    16-MAY-2005    Ritesh Shukla   Modified this procedure for FP.M
--    16-Apr-2007    rthumma    Bug# 5998035 : Added call to PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions API
--                   for deleting the data from pa_resource_assignments
--    29-Feb-2008    paljain    Bug# 6854131 : Removed second call to close cursor l_budget_line_rowid_csr
--
PROCEDURE delete_budget_line
( p_api_version_number        IN  NUMBER
 ,p_commit                    IN  VARCHAR2
 ,p_init_msg_list             IN  VARCHAR2
 ,p_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code           IN  VARCHAR2
 ,p_pa_project_id             IN  NUMBER
 ,p_pm_project_reference      IN  VARCHAR2
 ,p_budget_type_code          IN  VARCHAR2
 ,p_pa_task_id                IN  NUMBER
 ,p_pm_task_reference         IN  VARCHAR2
 ,p_resource_alias            IN  VARCHAR2
 ,p_resource_list_member_id   IN  NUMBER
 ,p_start_date                IN  DATE
 ,p_period_name               IN  VARCHAR2
--Parameters added for FP.M
 ,p_fin_plan_type_id          IN  NUMBER
 ,p_fin_plan_type_name        IN  VARCHAR2
 ,p_version_type              IN  VARCHAR2
 ,p_version_number            IN  NUMBER
 ,p_currency_code             IN  VARCHAR2 )

IS


   CURSOR l_resource_assignment_csr
      (p_budget_version_id  NUMBER
      ,p_task_id        NUMBER
      ,p_member_id      NUMBER  )
   IS
   SELECT resource_assignment_id
   FROM   pa_resource_assignments
   WHERE  budget_version_id = p_budget_version_id
   AND    task_id = p_task_id
   AND    resource_list_member_id = p_member_id;

   CURSOR l_budget_line_rowid_csr
     ( p_resource_assignment_id NUMBER
      ,p_budget_start_date      DATE
      ,p_currency_code          VARCHAR2)
   IS
   SELECT rowidtochar(rowid)
         ,txn_currency_code
         ,start_date
         ,end_date
   FROM   pa_budget_lines
   WHERE  resource_assignment_id = p_resource_assignment_id
   AND    trunc(start_date) = nvl(trunc(p_budget_start_date),trunc(start_date))
   AND    txn_currency_code = nvl(p_currency_code,txn_currency_code);

   -- FP.M Data Model Logic

   CURSOR l_uncategorized_list_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND    prl.uncategorized_flag='Y'
   and    prlm.resource_class_code = 'FINANCIAL_ELEMENTS';

   -- End: FP.M Resource LIst Data Model Impact Changes ------

   -- needed to get the budget_start_date of a period
   CURSOR   l_budget_periods_csr
        (p_period_name          VARCHAR2
        ,p_time_phased_type_code    VARCHAR2    )
   IS
   SELECT trunc(period_start_date)
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND    period_type_code = p_time_phased_type_code;

   --needed to validate to given start_date
   CURSOR   l_start_date_csr
        (p_start_date           DATE
        ,p_time_phased_type_code    VARCHAR2    )
   IS
   SELECT 1
   FROM   pa_budget_periods_v
   WHERE  trunc(period_start_date) = trunc(p_start_date)
   AND    period_type_code = p_time_phased_type_code;

   --needed to lock the budget line row
   CURSOR l_lock_budget_line_csr( p_budget_line_rowid VARCHAR2)
   IS
   SELECT 'x'
   FROM   pa_budget_lines
   WHERE  rowid = p_budget_line_rowid
   FOR UPDATE NOWAIT;

   --This cursor is used to get the approved rev plan type flag of the plan type
   CURSOR l_approved_revenue_flag_csr
          ( c_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE
           ,c_project_id pa_projects_all.project_id%TYPE)
   IS
   SELECT approved_rev_plan_type_flag
   FROM   pa_proj_fp_options
   WHERE  project_id=c_project_id
   AND    fin_plan_type_id=c_fin_plan_type_id
   AND    fin_plan_option_level_code=PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

   l_app_rev_plan_type_flag     VARCHAR2(1);

   --This cursor is used to compare a currency code with pfc
   CURSOR l_proj_func_currency_csr
          ( c_project_id    NUMBER
           ,c_currency_code VARCHAR2)
   IS
   SELECT 1
   FROM  pa_projects_all
   WHERE project_id = c_project_id
   AND   projfunc_currency_code = c_currency_code;

   --This cursor is used to fetch the txn currencies of the plan version
   --and validate currency_code against them.
   CURSOR l_plan_ver_txn_curr_csr
          ( c_fin_plan_version_id   NUMBER
           ,c_currency_code         VARCHAR2)
   IS
   SELECT 1
   FROM   pa_fp_txn_currencies
   WHERE  fin_plan_version_id = c_fin_plan_version_id
   AND    txn_currency_code   = c_currency_code;

   --Cursor to derive plan_class_code and etc_start_date for a budget version
   CURSOR budget_version_info_cur (c_budget_version_id IN NUMBER)
   IS
   SELECT  pt.plan_class_code
          ,bv.etc_start_date
   FROM    pa_budget_versions bv,
           pa_fin_plan_types_b pt
   WHERE   bv.budget_version_id = c_budget_version_id
   AND     pt.fin_plan_type_id = bv.fin_plan_type_id;

   l_plan_class_code            pa_fin_plan_types_b.plan_class_code%TYPE;
   l_etc_start_date             pa_budget_versions.etc_start_date%TYPE;

   i                            NUMBER := 0;
   l_dummy                      NUMBER;

   l_api_name          CONSTANT VARCHAR2(30)        := 'delete_budget_line';

   l_resource_assignment_id     pa_resource_assignments.resource_assignment_id%type;
   l_budget_line_rowid          VARCHAR(20);

   l_err_code                   NUMBER;
   l_err_stage                  VARCHAR2(120);
   l_err_stack                  VARCHAR2(630);

   l_project_id                 NUMBER := p_pa_project_id;
   l_budget_type_code           pa_budget_types.budget_type_code%TYPE := p_budget_type_code;
   l_fin_plan_type_id           NUMBER := p_fin_plan_type_id;
   l_fin_plan_type_name         pa_fin_plan_types_tl.name%TYPE := p_fin_plan_type_name;
   l_version_type               pa_budget_versions.version_type%TYPE := p_version_type;
   l_budget_version_id          NUMBER;
   l_budget_entry_method_code   pa_budget_entry_methods.budget_entry_method_code%TYPE;
   l_resource_list_id           NUMBER;
   l_budget_amount_code         pa_budget_types.budget_amount_code%type;
   l_entry_level_code           pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
   l_time_phased_code           pa_proj_fp_options.cost_time_phased_code%TYPE;
   l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
   l_categorization_code        pa_budget_entry_methods.categorization_code%TYPE;
   l_record_version_number      NUMBER;
   l_task_id                    NUMBER;
   l_resource_list_member_id    NUMBER;
   l_currency_code              VARCHAR2(15);
   l_start_date                 DATE;

   l_resource_assignment_tab    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
   l_delete_budget_lines_tab    SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
   l_txn_currency_code_tab      SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
   l_line_start_date_tab        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   l_line_end_date_tab          SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   l_txn_currency_code          VARCHAR2(15);
   l_line_start_date            DATE;
   l_line_end_date              DATE;

   l_msg_count                  NUMBER := 0;
   l_msg_data                   VARCHAR2(2000);
   l_module_name                VARCHAR2(80);
   l_data                       VARCHAR2(2000);
   l_msg_index_out              NUMBER;

   l_amg_project_number         pa_projects_all.segment1%TYPE;
   l_amg_task_number            VARCHAR2(50);

   -- Bug# 5998035
   l_call_del_planning_trans            VARCHAR2(1) := 'N';
   l_currency_code_tbl           SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

   --debug variables
   l_debug_mode                 VARCHAR2(1);
   l_debug_level2      CONSTANT NUMBER := 2;
   l_debug_level3      CONSTANT NUMBER := 3;
   l_debug_level4      CONSTANT NUMBER := 4;
   l_debug_level5      CONSTANT NUMBER := 5;
   --Added for bug 6408139 to pass G_PA_MISS_CHAR
   l_pa_miss_char varchar2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;


BEGIN


   --Standard begin of API savepoint
   SAVEPOINT delete_budget_line_pub;

   p_msg_count := 0;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
   l_module_name := g_module_name || ':Delete_Budget_Line ';

   IF ( l_debug_mode = 'Y' )
   THEN
         pa_debug.set_curr_function( p_function   => l_api_name
                                    ,p_debug_mode => l_debug_mode );
   END IF;

   IF ( l_debug_mode = 'Y' )
   THEN
         pa_debug.g_err_stage:='Entering ' || l_api_name;
         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
   END IF;

   --Initialize the message table if requested.
   IF FND_API.TO_BOOLEAN( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

   --Set API return status to success
   p_return_status     := FND_API.G_RET_STS_SUCCESS;

   --Call PA_BUDGET_PVT.validate_header_info to do the necessary
   --header level validations
   PA_BUDGET_PVT.validate_header_info
        ( p_api_version_number          => p_api_version_number
         ,p_api_name                    => l_api_name
         ,p_init_msg_list               => p_init_msg_list
         ,px_pa_project_id              => l_project_id
         ,p_pm_project_reference        => p_pm_project_reference
         ,p_pm_product_code             => p_pm_product_code
         ,px_budget_type_code           => l_budget_type_code
         ,px_fin_plan_type_id           => l_fin_plan_type_id
         ,px_fin_plan_type_name         => l_fin_plan_type_name
         ,px_version_type               => l_version_type
         ,p_budget_version_number       => p_version_number
         ,p_change_reason_code          => NULL
         ,p_function_name               => 'PA_PM_DELETE_BUDGET_LINE'
         ,x_budget_entry_method_code    => l_budget_entry_method_code
         ,x_resource_list_id            => l_resource_list_id
         ,x_budget_version_id           => l_budget_version_id
         ,x_fin_plan_level_code         => l_entry_level_code
         ,x_time_phased_code            => l_time_phased_code
         ,x_plan_in_multi_curr_flag     => l_multi_curr_flag
         ,x_budget_amount_code          => l_budget_amount_code
         ,x_categorization_code         => l_categorization_code
         ,x_project_number              => l_amg_project_number
         /* Plan Amount Entry flags introduced by bug 6408139 */
         /*Passing all as G_PA_MISS_CHAR since validations not required*/
         ,px_raw_cost_flag         =>   l_pa_miss_char
         ,px_burdened_cost_flag    =>   l_pa_miss_char
         ,px_revenue_flag          =>   l_pa_miss_char
         ,px_cost_qty_flag         =>   l_pa_miss_char
         ,px_revenue_qty_flag      =>   l_pa_miss_char
         ,px_all_qty_flag          =>   l_pa_miss_char
         ,px_bill_rate_flag        =>   l_pa_miss_char
         ,px_cost_rate_flag        =>   l_pa_miss_char
         ,px_burden_rate_flag      =>   l_pa_miss_char
         /* Plan Amount Entry flags introduced by bug 6408139 */
         ,x_msg_count                   => p_msg_count
         ,x_msg_data                    => p_msg_data
         ,x_return_status               => p_return_status );

   IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF(l_debug_mode='Y') THEN
               pa_debug.g_err_stage := 'validate header info API falied';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;


   -- convert pm_task_reference to pa_task_id
   -- if both task_id and task_reference are not passed or NULL, then we will default to 0, because this
   -- is the value of task_id when budgetting is done at the project level.

   IF (p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       OR p_pa_task_id IS NULL )
   AND (p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        OR p_pm_task_reference IS NULL )
   THEN

    l_task_id := 0;

   ELSE

    PA_PROJECT_PVT.Convert_pm_taskref_to_id ( p_pa_project_id       => l_project_id,
                              p_pa_task_id          => p_pa_task_id,
                              p_pm_task_reference   => p_pm_task_reference,
                              p_out_task_id         => l_task_id,
                              p_return_status       => p_return_status );

    IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF p_return_status = FND_API.G_RET_STS_ERROR
    THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

   END IF;

   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
                        (p_task_number=> ''
                        ,p_task_reference => p_pm_task_reference
                        ,p_task_id => l_task_id);

   -- convert resource alias to (resource) member id if passed and NOT NULL
   -- if resource alias is (passed and not NULL)
   -- and resource member is (passed and not NULL)
   -- then we convert the alias to the id
   -- else we default to the uncategorized resource member

   IF (p_resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND p_resource_alias IS NOT NULL)
   OR (p_resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND p_resource_list_member_id IS NOT NULL)
   THEN

       pa_resource_pub.Convert_alias_to_id
             ( p_project_id                  => p_pa_project_id
              ,p_resource_list_id            => l_resource_list_id
              ,p_alias                       => p_resource_alias
              ,p_resource_list_member_id     => p_resource_list_member_id
              ,p_out_resource_list_member_id => l_resource_list_member_id
              ,p_return_status               => p_return_status  );

       IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
       THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF p_return_status = FND_API.G_RET_STS_ERROR
       THEN
               RAISE  FND_API.G_EXC_ERROR;
       END IF;

   ELSE

       OPEN l_uncategorized_list_csr;
       FETCH l_uncategorized_list_csr INTO l_resource_list_member_id;
       CLOSE l_uncategorized_list_csr;

   END IF;

-- No check has been made to see if RLM id passed belongs to PRL stamped at Budget Version Level
-- Bug 4375976 has been logged to take care of this in API pa_resource_pub.Convert_alias_to_id

   --Check the existence of resource assignment
   OPEN l_resource_assignment_csr
    (l_budget_version_id
    ,l_task_id
    ,l_resource_list_member_id);

   FETCH l_resource_assignment_csr INTO l_resource_assignment_id;

   IF l_resource_assignment_csr%NOTFOUND
   THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        pa_interface_utils_pub.map_new_amg_msg
        ( p_old_message_code => 'PA_NO_RESOURCE_ASSIGNMENT'
         ,p_msg_attribute    => 'CHANGE'
         ,p_resize_flag      => 'N'
         ,p_msg_context      => 'BUDG'
         ,p_attribute1       => l_amg_project_number
         ,p_attribute2       => l_amg_task_number
         ,p_attribute3       => p_budget_type_code
         ,p_attribute4       => ''
         ,p_attribute5       => to_char(p_start_date));
    END IF;

    CLOSE l_resource_assignment_csr;
    RAISE FND_API.G_EXC_ERROR;

   END IF;

   CLOSE l_resource_assignment_csr;


   --Period name/start date check
   IF p_period_name IS NOT NULL
   AND p_period_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   THEN

       OPEN l_budget_periods_csr( p_period_name => p_period_name
                                 ,p_time_phased_type_code => l_time_phased_code );

       FETCH l_budget_periods_csr INTO l_start_date;

       IF l_budget_periods_csr%NOTFOUND
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PERIOD_NAME_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'BUDG'
            ,p_attribute1       => l_amg_project_number
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => l_budget_type_code
            ,p_attribute4       => ''
            ,p_attribute5       => to_char(p_start_date));
           END IF;

           CLOSE l_budget_periods_csr;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE l_budget_periods_csr;

   ELSIF p_start_date IS NOT NULL
   AND   p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   THEN

        -- Fix: 27-JAN-97, jwhite
        --  Added condition for 'G' or 'P' time-phased-type code as only
        --  required for period phased budgets.
        IF (l_time_phased_code IN ('G', 'P') )  THEN

            OPEN l_start_date_csr(p_start_date            => p_start_date
                                 ,p_time_phased_type_code => l_time_phased_code );

            FETCH l_start_date_csr INTO l_dummy;

            IF l_start_date_csr%NOTFOUND
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                pa_interface_utils_pub.map_new_amg_msg
                ( p_old_message_code => 'PA_START_DATE_INVALID'
                 ,p_msg_attribute    => 'CHANGE'
                 ,p_resize_flag      => 'N'
                 ,p_msg_context      => 'PROJ'
                 ,p_attribute1       => l_amg_project_number
                 ,p_attribute2       => ''
                 ,p_attribute3       => ''
                 ,p_attribute4       => ''
                 ,p_attribute5       => '');
                END IF;

                CLOSE l_start_date_csr;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE l_start_date_csr;

        END IF;--(l_time_phased_code IN ('G', 'P') )

        l_start_date := p_start_date;

   ELSE

        /* Added code for Bug# 5998035 */
        -- If start_date and period_name are passed as NULL
        IF (p_period_name IS NULL and p_start_date IS NULL) THEN
                -- If time phased then set l_call_del_planning_trans to 'Y'
                IF (l_time_phased_code IN ('G', 'P')  AND l_fin_plan_type_id IS NOT NULL) THEN
                        l_call_del_planning_trans := 'Y';
                END IF;
        END IF;
        /* End of code for Bug# 5998035 */
	l_start_date := NULL;   --when no start_date or period_name is passed or both are NULL
                                --, then all periods will be deleted

   END IF;--Period name/start date check

   --DO G_MISS_CHAR to NULL conv for currency_code
   IF p_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_currency_code := NULL;
   ELSE
        l_currency_code := p_currency_code;
   END IF;

   --Following validations are required only for the new model
   IF l_fin_plan_type_id IS NOT NULL
   THEN

         --Validate currency_code if it is not null
         --Validate the txn currency code provided by the user. The follwing checks are made.
         --If the version is an approved revenue version then the txn curr code should be PFC.
         --else If the version is MC enabled then txn curr code should be among the txn
         --currencies provided at the version level.

         IF l_currency_code IS NOT NULL THEN

            l_dummy := 0; --reset the value of l_dummy

            --Get the approved revenue plan type flag
            OPEN l_approved_revenue_flag_csr( l_fin_plan_type_id
                                             ,l_project_id);
            FETCH l_approved_revenue_flag_csr INTO l_app_rev_plan_type_flag;
            CLOSE l_approved_revenue_flag_csr;

            -- check for approved rev plan type flag is made here because in case plan type is at
            -- cost and revenue separately then version can have currencies other than PFC.
            IF( nvl(l_app_rev_plan_type_flag,'N') = 'Y' AND
                l_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST)
            THEN

                 OPEN l_proj_func_currency_csr( l_project_id
                                               ,l_currency_code);
                 FETCH l_proj_func_currency_csr INTO l_dummy;
                 CLOSE l_proj_func_currency_csr;

                 IF l_dummy = 0 THEN --currency_code not equal to PFC

                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                          PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_TXN_NOT_PFC_FOR_APP_REV',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_number,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  l_fin_plan_type_name,
                              p_token3         => 'CURRENCY',
                              p_value3         =>  l_currency_code);
                     END IF;

                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                 END IF;--l_dummy = 0

            ELSE-- Version is not approved for revenue. The txn curr must be available in fp txn curr table

                 OPEN l_plan_ver_txn_curr_csr( l_budget_version_id
                                              ,l_currency_code);
                 FETCH l_plan_ver_txn_curr_csr INTO l_dummy;
                 CLOSE l_plan_ver_txn_curr_csr;

                 IF l_dummy = 0 THEN --currency_code is not valid

                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                          PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_TXN_NOT_ADDED_FOR_PT',
                              p_token1         => 'PROJECT',
                              p_value1         =>  l_amg_project_number,
                              p_token2         => 'PLAN_TYPE',
                              p_value2         =>  l_fin_plan_type_name,
                              p_token3         => 'CURRENCY',
                              p_value3         =>  l_currency_code);
                     END IF;

                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                 END IF;--l_dummy = 0

            END IF;

         END IF;--l_currency_code IS NOT NULL

         --If multi-currency is enabled and one of period_name or start_date is
         --not null, then currency_code cannot be null.
         IF (l_multi_curr_flag = 'Y' AND
             l_currency_code IS NULL AND
             l_start_date IS NOT NULL)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                     PA_UTILS.add_message
                     (p_app_short_name => 'PA'
                     ,p_msg_name       => 'PA_FP_CURRENCY_NULL_AMG'
                     ,p_token1         => 'PROJECT'
                     ,p_value1         => l_amg_project_number
                     ,p_token2         => 'PLAN_TYPE'
                     ,p_value2         => l_fin_plan_type_name
                     ,p_token3         => 'TASK'
                     ,p_value3         => l_amg_task_number
                     ,p_token4         => 'START_DATE'
                     ,p_value4         => to_char(l_start_date) );
               END IF;

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'For multi-currency enabled, currency code is'
                                          || 'null but start_date is not null';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;


         --In case of new model, check if Actuals have been entered for the FORECAST Line.
         OPEN budget_version_info_cur(l_budget_version_id);
         FETCH budget_version_info_cur
         INTO  l_plan_class_code
              ,l_etc_start_date;
         CLOSE budget_version_info_cur;
         --Since we have already validated the presence of a budget version id
         --in PA_BUDGET_PVT.validate_header_info, hence we do not check for
         --budget_version_info_cur%NOT FOUND here.

	 /* Added for Bug# 5998035 */
         IF ( l_time_phased_code NOT IN ('G', 'P') AND l_etc_start_date IS NULL) THEN
                l_call_del_planning_trans := 'Y';
        END IF;
         IF (l_plan_class_code IS NOT NULL AND
             l_plan_class_code = 'FORECAST' AND
             l_etc_start_date IS NOT NULL AND
             ((l_start_date IS NOT NULL AND l_etc_start_date > l_start_date) OR l_start_date IS NULL) AND        -- Bug 5998035
             l_time_phased_code IS NOT NULL AND
             l_time_phased_code <> 'N')
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                     PA_UTILS.add_message
                     (p_app_short_name => 'PA'
                     ,p_msg_name       => 'PA_FP_FCST_ACTUALS_AMG'
                     ,p_token1         => 'PROJECT'
                     ,p_value1         => l_amg_project_number
                     ,p_token2         => 'PLAN_TYPE'
                     ,p_value2         => l_fin_plan_type_name
                     ,p_token3         => 'TASK'
                     ,p_value3         => l_amg_task_number
                     ,p_token4         => 'CURRENCY'
                     ,p_value4         => l_currency_code
                     ,p_token5         => 'START_DATE'
                     ,p_value5         => to_char(l_start_date) );
               END IF;

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Forecast Line has actuals and hence cannot be edited';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;--end of actuals-on-FORECAST check

   ELSE -- old FORMS based Budgets Model

         --Currency_code value, even if specified, should be ignored in
         --case of old Budgets Model
         l_currency_code := NULL;

   END IF; --l_fin_plan_type_id IS NOT NULL


   --Checking existence of budget line
   /* Added code for Bug# 5998035 */
   --Skipping this loop while calling delete_planning_transactions
   IF ( l_call_del_planning_trans <> 'Y' ) THEN --Bug# 5998035
   OPEN l_budget_line_rowid_csr( l_resource_assignment_id
                                ,l_start_date
                                ,l_currency_code );

   FETCH l_budget_line_rowid_csr INTO l_budget_line_rowid
                                     ,l_txn_currency_code
                                     ,l_line_start_date
                                     ,l_line_end_date ;

   IF l_budget_line_rowid_csr%NOTFOUND
   THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        pa_interface_utils_pub.map_new_amg_msg
        ( p_old_message_code => 'PA_BUDGET_LINE_NOT_FOUND'
         ,p_msg_attribute    => 'CHANGE'
         ,p_resize_flag      => 'N'
         ,p_msg_context      => 'BUDG'
         ,p_attribute1       => l_amg_project_number
         ,p_attribute2       => l_amg_task_number
         ,p_attribute3       => l_budget_type_code
         ,p_attribute4       => ''
         ,p_attribute5       => to_char(l_start_date));
    END IF;

    CLOSE l_budget_line_rowid_csr;
    RAISE FND_API.G_EXC_ERROR;

   END IF;

   --Loop for deleting budget lines begins
   WHILE l_budget_line_rowid_csr%FOUND LOOP

      --Do the processing for FORMS based Budgets Model
      IF l_budget_type_code IS NOT NULL
      THEN
           BEGIN

           OPEN l_lock_budget_line_csr( l_budget_line_rowid );
           CLOSE l_lock_budget_line_csr;

                /*FPB2: MRC PA_BUDGET_LINES_V_PKG.delete_row( l_budget_line_rowid ); */
                pa_budget_lines_v_pkg.delete_row(X_Rowid => l_budget_line_rowid);
                                     -- Bug Fix: 4569365. Removed MRC code.
             --,  x_mrc_flag => 'Y');  /* FPB2: Added x_mrc_flag for MRC changes */


           --this exception part is here because this procedure doesn't handle the exceptions itself.
           EXCEPTION
           WHEN ROW_ALREADY_LOCKED THEN RAISE;

           WHEN OTHERS
           THEN

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
               THEN
                   FND_MSG_PUB.add_exc_msg
                   (  p_pkg_name       => 'PA_BUDGET_LINES_V_PKG'
                   ,  p_procedure_name => 'DELETE_ROW'
                   ,  p_error_text     => SQLCODE          );

               END IF;

               CLOSE l_budget_line_rowid_csr;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;

      ELSIF l_fin_plan_type_id IS NOT NULL --new FINPLAN model
      THEN

           i := i + 1; --incrementing the counter

           --Store the data for PA_FP_CALC_PLAN_PKG.calculate API call
           l_resource_assignment_tab.extend(1);
           l_delete_budget_lines_tab.extend(1);
           l_txn_currency_code_tab.extend(1);
           l_line_start_date_tab.extend(1);
           l_line_end_date_tab.extend(1);

           l_resource_assignment_tab(i) := l_resource_assignment_id;
           l_delete_budget_lines_tab(i) := 'Y';
           l_txn_currency_code_tab(i)   := l_txn_currency_code;
           l_line_start_date_tab(i)     := l_line_start_date;
           l_line_end_date_tab(i)       := l_line_end_date;

      END IF;--l_budget_type_code IS NOT NULL

      FETCH l_budget_line_rowid_csr INTO l_budget_line_rowid
                                        ,l_txn_currency_code
                                        ,l_line_start_date
                                        ,l_line_end_date ;

   END LOOP;

   /* Added for Bug# 5998035 */
   ELSE

        l_resource_assignment_tab.extend(1);
        l_currency_code_tbl.extend(1);

        l_resource_assignment_tab(1) := l_resource_assignment_id;
        l_currency_code_tbl(1) := l_currency_code;

   END IF;      -- Bug# 5998035

   IF l_budget_line_rowid_csr%ISOPEN THEN               -- Bug 5998035
    -- Bug 6854131
    CLOSE l_budget_line_rowid_csr;
   END IF;

   IF l_budget_type_code IS NOT NULL --old budgets model
   THEN
        --summarizing the totals in the table pa_budget_versions
        PA_BUDGET_UTILS.summerize_project_totals( x_budget_version_id => l_budget_version_id
                                                , x_err_code          => l_err_code
                                                , x_err_stage         => l_err_stage
                                                , x_err_stack         => l_err_stack );

        IF l_err_code > 0
        THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            IF NOT pa_project_pvt.check_valid_message(l_err_stage)
            THEN
            pa_interface_utils_pub.map_new_amg_msg
            ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
             ,p_msg_attribute    => 'CHANGE'
             ,p_resize_flag      => 'N'
             ,p_msg_context      => 'BUDG'
             ,p_attribute1       => l_amg_project_number
             ,p_attribute2       => l_amg_task_number
             ,p_attribute3       => p_budget_type_code
             ,p_attribute4       => ''
             ,p_attribute5       => to_char(p_start_date));
            ELSE
            pa_interface_utils_pub.map_new_amg_msg
            ( p_old_message_code => l_err_stage
             ,p_msg_attribute    => 'CHANGE'
             ,p_resize_flag      => 'N'
             ,p_msg_context      => 'BUDG'
             ,p_attribute1       => l_amg_project_number
             ,p_attribute2       => l_amg_task_number
             ,p_attribute3       => p_budget_type_code
             ,p_attribute4       => ''
             ,p_attribute5       => to_char(p_start_date));
            END IF;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

        ELSIF l_err_code < 0
        THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN

            FND_MSG_PUB.add_exc_msg
                (  p_pkg_name       => 'PA_BUDGET_UTILS'
                ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
                ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

   ELSIF l_fin_plan_type_id IS NOT NULL --new FINPLAN model
   THEN

        --Lock the budget version before deleting a budget line
        l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                   (p_budget_version_id => l_budget_version_id);

        PA_FIN_PLAN_PVT.lock_unlock_version
        ( p_budget_version_id       => l_budget_version_id
         ,p_record_version_number   => l_record_version_number
         ,p_action                  => 'L'
         ,p_user_id                 => FND_GLOBAL.User_id
         ,p_person_id               => null
         ,x_return_status           => p_return_status
         ,x_msg_count               => p_msg_count
         ,x_msg_data                => p_msg_data);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              -- Error message is not added here as the api lock_unlock_version
              -- adds the message to stack
              IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'Failed in locking the version ' || l_budget_version_id;
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

        --Call PA_FP_CALC_PLAN_PKG.calculate api to delete the budget line(s)
	/* Added the following code for Bug# 5998035 */
        IF (l_call_del_planning_trans = 'Y') THEN
        -- Call PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions if period_name and start_date are NULL
        PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions
                        (p_context                        => l_plan_class_code
                        ,p_task_or_res                => 'ASSIGNMENT'
                        ,p_resource_assignment_tbl        => l_resource_assignment_tab
                        ,p_currency_code_tbl        => l_currency_code_tbl
                        ,x_return_status           => p_return_status
                        ,x_msg_count               => p_msg_count
                        ,x_msg_data                => p_msg_data
                        );
         IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions API has thrown error';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
         END IF;
         /* End of code for Bug# 5998035 */
        ELSE
        PA_FP_CALC_PLAN_PKG.calculate
                           (p_project_id              => l_project_id
                           ,p_budget_version_id       => l_budget_version_id
                           ,p_spread_required_flag    => 'N'
                           ,p_source_context          => 'BUDGET_LINE'
                           ,p_calling_module          => PA_FP_CONSTANTS_PKG.G_AMG_API
                           ,p_resource_assignment_tab => l_resource_assignment_tab
                           ,p_delete_budget_lines_tab => l_delete_budget_lines_tab
                           ,p_txn_currency_code_tab   => l_txn_currency_code_tab
                           ,p_line_start_date_tab     => l_line_start_date_tab
                           ,p_line_end_date_tab       => l_line_end_date_tab
                           ,x_return_status           => p_return_status
                           ,x_msg_count               => p_msg_count
                           ,x_msg_data                => p_msg_data );
	END IF;

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PKG.calculate API has thrown error';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

        --unlock the budget version after deleting the budget line
        l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                   (p_budget_version_id => l_budget_version_id);

        PA_FIN_PLAN_PVT.lock_unlock_version
        ( p_budget_version_id       => l_budget_version_id
         ,p_record_version_number   => l_record_version_number
         ,p_action                  => 'U'
         ,p_user_id                 => FND_GLOBAL.User_id
         ,p_person_id               => null
         ,x_return_status           => p_return_status
         ,x_msg_count               => p_msg_count
         ,x_msg_data                => p_msg_data);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
              -- Error message is not added here as the api lock_unlock_version
              -- adds the message to stack
              IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'Failed in unlocking the version ' || l_budget_version_id;
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

   END IF;--end of code to delete budget line

   IF fnd_api.to_boolean(p_commit)
   THEN
       COMMIT;
   END IF;

   IF ( l_debug_mode = 'Y' ) THEN
         pa_debug.reset_curr_function;
   END IF;


EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc
   THEN

   ROLLBACK TO delete_budget_line_pub;

   p_return_status := FND_API.G_RET_STS_ERROR;
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count = 1 and p_msg_data IS NULL THEN
         PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index      => 1
         ,p_msg_count      => l_msg_count
         ,p_msg_data       => l_msg_data
         ,p_data           => l_data
         ,p_msg_index_out  => l_msg_index_out);
         p_msg_data  := l_data;
         p_msg_count := l_msg_count;
   ELSE
         p_msg_count := l_msg_count;
   END IF;

   IF ( l_debug_mode = 'Y' ) THEN
         pa_debug.reset_curr_function;
   END IF;

   RETURN;


   WHEN FND_API.G_EXC_ERROR
   THEN

   ROLLBACK TO delete_budget_line_pub;

   p_return_status := FND_API.G_RET_STS_ERROR;

   FND_MSG_PUB.Count_And_Get
   (   p_count     =>  p_msg_count ,
       p_data      =>  p_msg_data  );

   IF ( l_debug_mode = 'Y' ) THEN
         pa_debug.reset_curr_function;
   END IF;


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN

   ROLLBACK TO delete_budget_line_pub;

   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   FND_MSG_PUB.Count_And_Get
   (   p_count     =>  p_msg_count ,
       p_data      =>  p_msg_data  );

   IF ( l_debug_mode = 'Y' ) THEN
         pa_debug.reset_curr_function;
   END IF;


   WHEN ROW_ALREADY_LOCKED
   THEN
   ROLLBACK TO delete_budget_line_pub;

   p_return_status := FND_API.G_RET_STS_ERROR;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
   THEN
     FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
     FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_project_number);
     FND_MESSAGE.SET_TOKEN('TASK',    l_amg_task_number);
     FND_MESSAGE.SET_TOKEN('BUDGET_TYPE', l_budget_type_code);
     FND_MESSAGE.SET_TOKEN('SOURCE_NAME', '');
     FND_MESSAGE.SET_TOKEN('START_DATE',fnd_date.date_to_chardate(p_start_date));
     FND_MESSAGE.SET_TOKEN('ENTITY', 'G_BUDGET_LINE_CODE');
     FND_MSG_PUB.ADD;
   END IF;

   FND_MSG_PUB.Count_And_Get
           (   p_count     =>  p_msg_count ,
               p_data      =>  p_msg_data  );

   IF ( l_debug_mode = 'Y' ) THEN
         pa_debug.reset_curr_function;
   END IF;


   WHEN OTHERS THEN

   ROLLBACK TO delete_budget_line_pub;

   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
       FND_MSG_PUB.add_exc_msg
       (  p_pkg_name       => G_PKG_NAME
       ,  p_procedure_name => l_api_name );

   END IF;

   FND_MSG_PUB.Count_And_Get
   (   p_count     =>  p_msg_count ,
       p_data      =>  p_msg_data  );

    IF ( l_debug_mode = 'Y' ) THEN
          pa_debug.reset_curr_function;
    END IF;

END delete_budget_line;


----------------------------------------------------------------------------------------
--Name:               update_budget
--Type:               Procedure
--Description:        This procedure can be used to update a working budget and it's
--                budget lines.
--
--Called subprograms:   pa_budget_pvt.insert_budget_line
--          pa_budget_pvt.update_budget_line_sql
--
--
--
--History:
--    14-OCT-1996        L. de Werker    Created
--    19-NOV-1996    L. de Werker    Changed for use of INSERT_BUDGET_LINE and
--                   UPDATE_BUDGET_LINE_SQL
--    28-NOV-1996    L. de Werker    Added 16 parameters for descriptive flexfields
--    05-DEC-1996    L. de Werker    Added validation for change_reason_code
--                   Corrected error when no resource assignment is found.
--    26-APR-2005    Bug 4224464. Changed the procedure update_budget to support finplan model.

PROCEDURE update_budget
( p_api_version_number      IN  NUMBER
 ,p_commit          IN  VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list       IN  VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code     IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id       IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code        IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code      IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category      IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in     IN  budget_line_in_tbl_type
 ,p_budget_lines_out        OUT NOCOPY budget_line_out_tbl_type
  --Added for the bug 3453650
 ,p_resource_list_id              IN   pa_budget_versions.resource_list_id%TYPE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_set_current_working_flag      IN   pa_budget_versions.current_working_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_locked_by_person_id           IN   pa_budget_versions.locked_by_person_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_version_name           IN   pa_budget_versions.version_name%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  -- 3453650
 ,p_finplan_type_id               IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_finplan_type_name             IN   pa_fin_plan_types_vl.name%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
/* Plan Amount Entry flags introduced by bug 6408139 */
 ,p_raw_cost_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_all_qty_flag                  IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_bill_rate_flag                IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_rate_flag                IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burden_rate_flag              IN   VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
)
IS


   --needed to check the validity of the incoming budget type

   CURSOR l_budget_type_csr
      (p_budget_type_code   VARCHAR2 )
   IS
   SELECT budget_amount_code
   FROM   pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;

   --needed to check whether budget line already exists

   CURSOR l_budget_line_csr
      (p_resource_assigment_id NUMBER
      ,p_budget_start_date     DATE )
   IS
   SELECT 'X'
   FROM   pa_budget_lines
   WHERE  resource_assignment_id = p_resource_assigment_id
   AND    start_date = p_budget_start_date;

   --needed to get the current budget version data

   CURSOR l_budget_version_csr
          ( p_project_id NUMBER
          , p_budget_type_code VARCHAR2 )
   IS
   SELECT budget_version_id
   ,      budget_entry_method_code
   ,      resource_list_id
   ,      change_reason_code
   ,      description
   FROM   pa_budget_versions
   WHERE  project_id        = p_project_id
   AND    budget_type_code  = p_budget_type_code
   AND    budget_status_code    = 'W';

   --needed to get the current budget entry method data

   CURSOR l_budget_entry_method_csr
          ( p_budget_entry_method_code VARCHAR2)
   IS
   SELECT time_phased_type_code
   ,      entry_level_code
   ,      categorization_code
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code;

   --needed to get the resource assignment for this budget_version / task / member combination

   CURSOR l_resource_assignment_csr
      (p_budget_version_id  NUMBER
      ,p_task_id        NUMBER
      ,p_member_id      NUMBER  )
   IS
   SELECT resource_assignment_id
   FROM   pa_resource_assignments
   WHERE  budget_version_id = p_budget_version_id
   AND    task_id = p_task_id
   AND    resource_list_member_id = p_member_id;

   -- needed to get the budget_start_date of a period

   CURSOR   l_budget_periods_csr
        (p_period_name      VARCHAR2
        ,p_period_type_code VARCHAR2    )
   IS
   SELECT trunc(period_start_date)
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND    period_type_code = p_period_type_code;

   -- the uncategorized resource list




   -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------

   -- Augmented original code with additional filter

/* -- Original Logic

   CURSOR l_uncategorized_list_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND    prl.uncategorized_flag='Y';

*/

   -- FP.M Data Model Logic

   CURSOR l_uncategorized_list_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND    prl.uncategorized_flag='Y'
   and    prlm.resource_class_code = 'FINANCIAL_ELEMENTS';


   -- End: FP.M Resource LIst Data Model Impact Changes -----------------------------




   CURSOR   l_budget_change_reason_csr ( p_change_reason_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM   pa_lookups
   WHERE  lookup_type = 'BUDGET CHANGE REASON'
   AND    lookup_code = p_change_reason_code;

   --needed for locking of budget rows

   CURSOR l_lock_budget_csr( p_budget_version_id NUMBER )
   IS
   SELECT 'x'
   FROM   pa_budget_versions bv
   ,      pa_resource_assignments ra
   ,      pa_budget_lines bl
   WHERE  bv.budget_version_id = p_budget_version_id
   AND    bv.budget_version_id = ra.budget_version_id (+)
   AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
   AND    bv.ci_id IS NULL         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause bv.ci_id IS NULL--Bug # 3507156
   FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

   l_api_name           CONSTANT    VARCHAR2(30)        := 'update_budget';

   l_return_status              VARCHAR2(1);
   l_project_id                 NUMBER;
   l_task_id                    NUMBER;
   l_dummy                  VARCHAR2(1);
   l_budget_version_id              NUMBER;
   l_budget_entry_method_code           VARCHAR2(30);
   l_change_reason_code             VARCHAR2(30);
   l_description                VARCHAR2(255);
   l_budget_line_index              NUMBER;
   l_budget_line_in_rec             pa_budget_pub.budget_line_in_rec_type;
   l_time_phased_type_code          VARCHAR2(30);
   l_resource_assignment_id         NUMBER;
   l_budget_start_date              DATE;
   l_resource_list_id               NUMBER;
   l_resource_list_member_id            NUMBER;
   l_resource_name              VARCHAR2(80); --bug 3711693
   l_budget_amount_code             VARCHAR2(30);
   l_entry_level_code               VARCHAR2(30);
   l_categorization_code            VARCHAR2(30);

   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

   l_err_code                   NUMBER;
   l_err_stage                  VARCHAR2(120);
   l_err_stack                  VARCHAR2(630);

   --used by dynamic SQL
   l_statement                  VARCHAR2(2000);
   l_update_yes_flag                VARCHAR2(1);
   l_cursor_id                  NUMBER;
   l_rows                   NUMBER;
   l_new_resource_assignment            BOOLEAN;
   l_function_allowed               VARCHAR2(1);
   l_resp_id                    NUMBER := 0;
   l_user_id                                NUMBER := 0;
   l_module_name                                VARCHAR2(80);
   l_budget_rlmid                               NUMBER;
   l_budget_alias                               VARCHAR2(80);  --bug 3711693
   l_uncategorized_list_id          NUMBER;
   l_uncategorized_rlmid                        NUMBER;
   l_uncategorized_resid                        NUMBER;
   l_track_as_labor_flag                        VARCHAR2(1);
   l_multi_currency_billing_flag      PA_PROJECTS_ALL.MULTI_CURRENCY_BILLING_FLAG%TYPE;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

p_multiple_task_msg     VARCHAR2(1) := 'T';

--Added for the bug 3453650
   CURSOR l_budget_attrs_csr(p_budget_type_code VARCHAR2,p_project_id number)
   IS
   SELECT BUDGET_VERSION_ID,version_name,budget_entry_method_code,
   RESOURCE_LIST_ID,CHANGE_REASON_CODE,DESCRIPTION
   FROM PA_BUDGET_VERSIONS
   --WHERE VERSION_NAME=p_budget_version_number
   Where budget_type_code=p_budget_type_code
   and project_id = p_project_id
   and budget_status_code    = 'W';

   /* Version number is mandatory for the finplan model */
   CURSOR l_finplan_attrs_csr(c_budget_version_id NUMBER)
   IS
   SELECT version_name,CURRENT_WORKING_FLAG,
   RESOURCE_LIST_ID,CHANGE_REASON_CODE,DESCRIPTION,version_type
   FROM PA_BUDGET_VERSIONS
   WHERE budget_version_id = c_budget_version_id;

   CURSOR l_finplan_type_name_csr(p_finplan_type_id NUMBER)
   IS
   SELECT name
   FROM pa_fin_plan_types_vl
   WHERE fin_plan_type_id=p_finplan_type_id;



   CURSOR get_resource_list_name_csr(p_resource_list_id NUMBER)
   IS
   SELECT name
   FROM pa_resource_lists
   WHERE p_resource_list_id=p_resource_list_id;

   CURSOR get_status_code_csr(p_budget_version_id NUMBER)
   IS
   select budget_status_code
   from pa_budget_versions
   where budget_version_id = p_budget_version_id;

   CURSOR l_finplan_line_csr
      (p_resource_assigment_id NUMBER
      ,p_budget_start_date     DATE
      ,p_txn_currency_code VARCHAR2)
   IS
   SELECT 'X'
   FROM   pa_budget_lines
   WHERE  resource_assignment_id = p_resource_assigment_id
   AND    start_date = p_budget_start_date
   AND    txn_currency_code = p_txn_currency_code;

/*Added a new cursor c_dff_values for Bug 6417360*/
   cursor c_dff_values(p_budget_version_id NUMBER)
   is
   select attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15
   from pa_budget_versions
   where budget_version_id = p_budget_version_id;
/*End of code for Bug 6417360*/

   l_budget_version_name       pa_budget_versions.version_name%TYPE := null;
   l_fin_plan_type_id          number;
   l_fin_plan_type_name        pa_fin_plan_types_tl.name%TYPE:=null;
   l_current_working_flag      pa_budget_versions.current_working_flag%TYPE :=null;
   l_budget_entry_code         pa_budget_versions.budget_entry_method_code%TYPE :=null;
--   l_locked_by_person_id       pa_budget_versions.locked_by_person_id%TYPE;
   l_record_version_number     pa_budget_versions.record_version_number%TYPE;

   l_amount_set_id             pa_proj_fp_options.all_amount_set_id%TYPE;
   l_fin_plan_level_code            pa_proj_fp_options.cost_fin_plan_level_code%TYPE :=null;
   l_person_id per_all_people_f.person_id%TYPE;
   l_resource_id per_all_people_f.person_id%TYPE;
   l_baselined_version_id NUMBER;
   l_debug_mode VARCHAR2(1);
   l_version_type pa_budget_versions.version_type%TYPE;
   l_curr_work_version_id VARCHAR2(15);
   l_debug_level5            CONSTANT NUMBER :=5;
   l_baselined_Ver_options_id VARCHAR2(15);
   l_budget_lines_in                budget_line_in_tbl_type;
   l_debug_level3          CONSTANT NUMBER := 3;
   l_finplan_lines_tab              pa_fin_plan_pvt.budget_lines_tab;
   l_uncategorized_res_list_id pa_resource_list_members.resource_list_id%TYPE;
   l_unit_of_measure pa_resources.unit_of_measure%TYPE;
   l_unc_track_as_labor_flag pa_resource_list_members.track_as_labor_flag%TYPE;
   l_unc_unit_of_measure            pa_resources.unit_of_measure%TYPE;
   -- Bug Fix: 4569365. Removed MRC code.
   -- l_calling_context               pa_mrc_finplan.g_calling_module%TYPE;
   l_calling_context               VARCHAR2(30);

   l_budget_status_code     pa_budget_versions.budget_status_code%TYPE;

   lx_budget_version_name       pa_budget_versions.version_name%TYPE := null;
   lx_budget_version_number    pa_budget_versions.version_number%TYPE  :=null;
   lx_version_type             pa_budget_versions.version_type%TYPE := null;
   lx_fin_plan_type_id         pa_fin_plan_types_b.fin_plan_type_id%TYPE :=null;
   lx_fin_plan_type_name       pa_fin_plan_types_tl.name%TYPE:=null;
   lx_set_current_working_flag      pa_budget_versions.current_working_flag%TYPE :=null;
   lx_locked_by_person_id       pa_budget_versions.locked_by_person_id%TYPE;
   lx_resource_list_id         pa_budget_versions.resource_list_id%TYPE;
   lx_plan_in_multi_curr_flag  pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
   lx_time_phased_type_code    pa_proj_fp_options.cost_time_phased_code%TYPE;
   lx_resource_list_name       pa_resource_lists_all_bg.Name%TYPE := null;
   lx_raw_cost_flag                  VARCHAR2(1) ;
   lx_burdened_cost_flag             VARCHAR2(1);
   lx_revenue_flag                   VARCHAR2(1);
   lx_cost_qty_flag                  VARCHAR2(1);
   lx_revenue_qty_flag               VARCHAR2(1);
   lx_all_qty_flag                   VARCHAR2(1);
   x_return_status VARCHAR2(1);
   lx_projfunc_cost_rate_type        pa_proj_fp_options.projfunc_cost_rate_type%TYPE ;
   lx_projfunc_cost_rate_date_typ    pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE ;
   lx_projfunc_cost_rate_date        pa_proj_fp_options.projfunc_cost_rate_date%TYPE ;
   lx_projfunc_rev_rate_type         pa_proj_fp_options.projfunc_rev_rate_type%TYPE ;
   lx_projfunc_rev_rate_date_typ     pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE;
   lx_projfunc_rev_rate_date         pa_proj_fp_options.projfunc_rev_rate_date%TYPE ;
   lx_project_cost_rate_type         pa_proj_fp_options.project_cost_rate_type%TYPE ;
   lx_project_cost_rate_date_typ     pa_proj_fp_options.project_cost_rate_date_type%TYPE  ;
   lx_project_cost_rate_date         pa_proj_fp_options.project_cost_rate_date%TYPE ;
   lx_project_rev_rate_type          pa_proj_fp_options.project_rev_rate_type%TYPE  ;
   lx_project_rev_rate_date_typ      pa_proj_fp_options.project_rev_rate_date_type%TYPE ;
   lx_project_rev_rate_date          pa_proj_fp_options.project_rev_rate_date%TYPE ;

   l_project_currency_code            pa_projects_all.project_currency_code%TYPE;  -- 3453650
   l_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE; -- 3453650

   i number;
   j number;
   lx_change_reason_code VARCHAR2(30);

   l_data                       VARCHAR2(2000);
   l_msg_index_out               NUMBER;

/*Commenting the old variables and adding new ones for bug 6408139*/
   /*Earlier they were not being used anywhere else, but now will be used */
--   l_bill_rate_flag        pa_fin_plan_amount_sets.bill_rate_flag%type;
--   l_cost_rate_flag        pa_fin_plan_amount_sets.cost_rate_flag%type;
--   l_burden_rate_flag      pa_fin_plan_amount_sets.burden_rate_flag%type;
   lx_bill_rate_flag        pa_fin_plan_amount_sets.bill_rate_flag%type;
   lx_cost_rate_flag        pa_fin_plan_amount_sets.cost_rate_flag%type;
   lx_burden_rate_flag      pa_fin_plan_amount_sets.burden_rate_flag%type;
   l_using_resource_lists_flag           VARCHAR2(1);
   l_mfc_cost_type_id_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
   l_etc_method_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
   l_spread_curve_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
   l_budget_type_code                    pa_budget_types.budget_type_code%TYPE;
   l_amg_project_number                  pa_projects_all.segment1%TYPE;
   l_proj_fp_options_id             pa_proj_fp_options.proj_fp_options_id%TYPE;
   l_CW_version_id                  pa_budget_versions.budget_version_id%TYPE;
   l_CW_record_version_number       pa_budget_versions.record_Version_number%TYPE;
   l_allow_qty_flag                  VARCHAR2(1);
   l_conv_attrs_to_be_validated     VARCHAR2(30);
   l_is_rate_type_valid             BOOLEAN;
   l_call_validate_curr_api_flg     VARCHAR2(1);
   l_projfunc_cost_rate_type        pa_proj_fp_options.projfunc_cost_rate_type%TYPE ;
   l_projfunc_rev_rate_type         pa_proj_fp_options.projfunc_rev_rate_type%TYPE ;
   l_project_cost_rate_type         pa_proj_fp_options.project_cost_rate_type%TYPE ;
   l_project_rev_rate_type          pa_proj_fp_options.project_rev_rate_type%TYPE ;
   l_projfunc_cost_exchange_rate    pa_budget_lines.projfunc_cost_exchange_rate%TYPE;
   l_projfunc_rev_exchange_rate     pa_budget_lines.projfunc_rev_exchange_rate%TYPE;
   l_project_cost_exchange_rate     pa_budget_lines.project_cost_exchange_rate%TYPE;
   l_project_rev_exchange_rate      pa_budget_lines.project_rev_exchange_rate%TYPE;

   l_version_info_rec           pa_fp_gen_amount_utils.fp_cols;
   /*Added local variables for bug 6408139*/
   l_plan_pref_code        pa_proj_fp_options.fin_plan_preference_code%TYPE;
   l_cost_amount_set_id    pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
   l_rev_amount_set_id     pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
   l_all_amount_set_id     pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
   l_proj_fp_options_id_new             pa_proj_fp_options.proj_fp_options_id%TYPE;


/*Added local variables for Bug 6417360*/
   l_attribute_category   pa_budget_versions.attribute_category%type;
   l_attribute1           pa_budget_versions.attribute1%type;
   l_attribute2           pa_budget_versions.attribute2%type;
   l_attribute3           pa_budget_versions.attribute3%type;
   l_attribute4           pa_budget_versions.attribute4%type;
   l_attribute5           pa_budget_versions.attribute5%type;
   l_attribute6           pa_budget_versions.attribute6%type;
   l_attribute7           pa_budget_versions.attribute7%type;
   l_attribute8           pa_budget_versions.attribute8%type;
   l_attribute9           pa_budget_versions.attribute9%type;
   l_attribute10          pa_budget_versions.attribute10%type;
   l_attribute11          pa_budget_versions.attribute11%type;
   l_attribute12          pa_budget_versions.attribute12%type;
   l_attribute13          pa_budget_versions.attribute13%type;
   l_attribute14          pa_budget_versions.attribute14%type;
   l_attribute15          pa_budget_versions.attribute15%type;

   l_validate_status      varchar2(1);
/*End of code for Bug 6417360*/

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT update_budget_pub;

    --Added for the bug 3453650
    IF p_change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_change_reason_code := NULL;
    ELSE
      lx_change_reason_code              :=   p_change_reason_code ;
    END IF;

    IF p_set_current_working_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_set_current_working_flag := NULL;
    ELSE
      lx_set_current_working_flag              :=   p_set_current_working_flag  ;
    END IF;

    IF p_budget_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
      lx_budget_version_number := NULL;
    ELSE
      lx_budget_version_number              :=   p_budget_version_number  ;
    END IF;

    IF p_projfunc_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_projfunc_cost_rate_type := NULL;
    ELSE
      lx_projfunc_cost_rate_type := p_projfunc_cost_rate_type ;
    END IF;

     IF p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_projfunc_cost_rate_date_typ  := NULL;
    ELSE
      lx_projfunc_cost_rate_date_typ   :=   p_projfunc_cost_rate_date_typ  ;
    END IF;

    IF p_projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      lx_projfunc_cost_rate_date := NULL;
    ELSE
      lx_projfunc_cost_rate_date       :=   p_projfunc_cost_rate_date      ;
    END IF;

    IF p_projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_projfunc_rev_rate_type := NULL;
    ELSE
      lx_projfunc_rev_rate_type        :=   p_projfunc_rev_rate_type       ;
    END IF;

    IF p_projfunc_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_projfunc_rev_rate_date_typ  := NULL;
    ELSE
      lx_projfunc_rev_rate_date_typ    :=   p_projfunc_rev_rate_date_typ   ;
    END IF;

    IF p_projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      lx_projfunc_rev_rate_date := NULL;
    ELSE
      lx_projfunc_rev_rate_date        :=   p_projfunc_rev_rate_date       ;
    END IF;

    IF p_project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_project_cost_rate_type := NULL;
    ELSE
      lx_project_cost_rate_type        :=   p_project_cost_rate_type       ;
    END IF;

    IF p_project_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_project_cost_rate_date_typ  := NULL;
    ELSE
      lx_project_cost_rate_date_typ    :=   p_project_cost_rate_date_typ   ;
    END IF;

    IF p_project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      lx_project_cost_rate_date := NULL;
    ELSE
      lx_project_cost_rate_date        :=   p_project_cost_rate_date       ;
    END IF;

    IF p_project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_project_rev_rate_type := NULL;
    ELSE
      lx_project_rev_rate_type         :=   p_project_rev_rate_type        ;
    END IF;

    IF p_project_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      lx_project_rev_rate_date_typ  := NULL;
    ELSE
      lx_project_rev_rate_date_typ     :=   p_project_rev_rate_date_typ    ;
    END IF;

    IF p_project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
      lx_project_rev_rate_date := NULL;
    ELSE
      lx_project_rev_rate_date         :=   p_project_rev_rate_date        ;
    END IF;
    /*Added checks for Plan Amount Entry Flags for bug 6408139*/
    /*If the flags are PASSED as NULL, then it would mean that */
    /*user wants to make the flag as 'N' */
    IF p_raw_cost_flag = NULL THEN
      lx_raw_cost_flag  := 'N';
    ELSE
      lx_raw_cost_flag                 :=   p_raw_cost_flag                ;
    END IF;

    IF p_burdened_cost_flag = NULL THEN
      lx_burdened_cost_flag  := 'N';
    ELSE
      lx_burdened_cost_flag            :=   p_burdened_cost_flag           ;
    END IF;

    IF p_revenue_flag = NULL THEN
      lx_revenue_flag  := 'N';
    ELSE
      lx_revenue_flag                  :=   p_revenue_flag                 ;
    END IF;

    IF p_cost_qty_flag = NULL THEN
      lx_cost_qty_flag  := 'N';
    ELSE
      lx_cost_qty_flag                 :=   p_cost_qty_flag                ;
    END IF;

    IF p_revenue_qty_flag = NULL THEN
      lx_revenue_qty_flag  := 'N';
    ELSE
      lx_revenue_qty_flag              :=   p_revenue_qty_flag             ;
    END IF;

    IF p_all_qty_flag = NULL THEN
      lx_all_qty_flag  := 'N';
    ELSE
      lx_all_qty_flag                  :=   p_all_qty_flag                 ;
    END IF;

    IF p_bill_rate_flag = NULL THEN
      lx_bill_rate_flag  := 'N';
    ELSE
      lx_bill_rate_flag                  :=   p_bill_rate_flag                 ;
    END IF;

    IF p_cost_rate_flag = NULL THEN
      lx_cost_rate_flag  := 'N';
    ELSE
      lx_cost_rate_flag                  :=   p_cost_rate_flag                 ;
    END IF;

    IF p_burden_rate_flag = NULL THEN
      lx_burden_rate_flag  := 'N';
    ELSE
      lx_burden_rate_flag                 :=   p_burden_rate_flag                 ;
    END IF;
    /*Checks End for Plan Amount Entry Flags for bug 6408139*/

    l_user_id := FND_GLOBAL.User_id;

/*  The G_MISS_XXX/null handling for these variables below has been deleted from the existing code in update_budget
    . This handling would be done in validate_header_info now */
    l_project_id          :=  p_pa_project_id;
    l_budget_type_code    :=  p_budget_type_code;
    l_fin_plan_type_id    :=  p_finplan_type_id;
    lx_fin_plan_type_name :=  p_finplan_type_name;
    lx_version_type       :=  p_version_type  ;

     --Call PA_BUDGET_PVT.validate_header_info to do the necessary
     --header level validations
     PA_BUDGET_PVT.validate_header_info
          ( p_api_version_number          => p_api_version_number
           ,p_api_name                    => l_api_name
           ,p_init_msg_list               => p_init_msg_list
           ,px_pa_project_id              => l_project_id
           ,p_pm_project_reference        => p_pm_project_reference
           ,p_pm_product_code             => p_pm_product_code
           ,px_budget_type_code           => l_budget_type_code
           ,px_fin_plan_type_id           => l_fin_plan_type_id
           ,px_fin_plan_type_name         => lx_fin_plan_type_name
           ,px_version_type               => lx_version_type
           ,p_budget_version_number       => p_budget_version_number
           ,p_change_reason_code          => lx_change_reason_code
           ,p_function_name               => 'PA_PM_UPDATE_BUDGET'
           ,x_budget_entry_method_code    => l_budget_entry_method_code
           ,x_resource_list_id            => lx_resource_list_id
           ,x_budget_version_id           => l_budget_version_id
           ,x_fin_plan_level_code         => l_fin_plan_level_code
           ,x_time_phased_code            => lx_time_phased_type_code
           ,x_plan_in_multi_curr_flag     => lx_plan_in_multi_curr_flag
           ,x_budget_amount_code          => l_budget_amount_code
           ,x_categorization_code         => l_categorization_code
           ,x_project_number              => l_amg_project_number
           /* Plan Amount Entry flags introduced by bug 6408139 */
           ,px_raw_cost_flag              => lx_raw_cost_flag
           ,px_burdened_cost_flag         => lx_burdened_cost_flag
           ,px_revenue_flag               => lx_revenue_flag
           ,px_cost_qty_flag              => lx_cost_qty_flag
           ,px_revenue_qty_flag           => lx_revenue_qty_flag
           ,px_all_qty_flag               => lx_all_qty_flag
           ,px_bill_rate_flag             => lx_bill_rate_flag
           ,px_cost_rate_flag             => lx_cost_rate_flag
           ,px_burden_rate_flag           => lx_burden_rate_flag
           /* Plan Amount Entry flags introduced by bug 6408139 */
           ,x_msg_count                   => p_msg_count
           ,x_msg_data                    => p_msg_data
           ,x_return_status               => p_return_status );

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF(l_debug_mode='Y') THEN
                 pa_debug.g_err_stage := 'validate header info API falied';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

      OPEN l_amg_project_csr( l_project_id );
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;

    IF l_budget_type_code IS NOT NULL THEN

       OPEN l_budget_attrs_csr(l_budget_type_code,l_project_id);
       FETCH l_budget_attrs_csr INTO l_budget_version_id,l_budget_version_name,l_budget_entry_method_code,
       l_resource_list_id,l_change_reason_code,l_description;
       CLOSE l_budget_attrs_csr;


       OPEN l_budget_entry_method_csr( l_budget_entry_method_code );
       FETCH l_budget_entry_method_csr INTO l_time_phased_type_code
                       , l_entry_level_code
                       , l_categorization_code;
       CLOSE l_budget_entry_method_csr;

    ELSE

     --Bug 5031071 l_budget_version_id fetched above and will contain the value
       OPEN l_finplan_attrs_csr(l_budget_version_id);
       FETCH l_finplan_attrs_csr INTO l_budget_version_name,l_current_working_flag,
       l_resource_list_id,l_change_reason_code,l_description,l_version_type;
       CLOSE l_finplan_attrs_csr;


    END IF;


      IF l_budget_version_id IS NULL THEN

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_NO_BUDGET_VERSION'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'BUDG'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => lx_fin_plan_type_name
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
          p_multiple_task_msg  := 'F';  -- 3453650
      END IF;

  IF l_budget_type_code IS NULL THEN
        PA_COMP_PROFILE_PUB.GET_USER_INFO
                (p_user_id         => l_user_id,
                 x_person_id       => l_person_id,
                 x_resource_id     => l_resource_id,
                 x_resource_name   => l_resource_name);

            l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                         (p_budget_version_id => l_budget_version_id);

      --Try to lock the version before updating the version. This is required so that nobody else can access it.
           pa_fin_plan_pvt.lock_unlock_version
                    (p_budget_version_id       => l_budget_version_id,
                     p_record_version_number   => l_record_version_number,
                     p_action                  => 'L',
                     p_user_id                 => l_user_id,
                     p_person_id               => lx_locked_by_person_id,
                     x_return_status           => x_return_status,
                     x_msg_count               => l_msg_count,
                     x_msg_data                => l_msg_data) ;


                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                     IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Error in lock unlock version - Cannot lock the version';
                           pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;

                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
  END IF; -- END IF FOR l_budget_type_code is not null


     l_time_phased_type_code := PA_FIN_PLAN_UTILS.Get_Time_Phased_code(l_budget_version_id);

IF p_multiple_task_msg = 'F' THEN
RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
END IF;

     IF (p_budget_version_name IS NOT NULL AND p_budget_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
        --(p_budget_version_name <> l_budget_version_name) THEN
        ((p_budget_version_name <> l_budget_version_name OR l_budget_version_name IS NULL)) THEN       --Bug 6600625
        lx_budget_version_name := p_budget_version_name;
     ELSE
       lx_budget_version_name := l_budget_version_name;
     END IF;

/*Commenting for bug 6408139 */
/*
 --Added after review comments
 IF l_budget_type_code IS NULL THEN
-- dbms_output.put_line ('about to get plan amt flags ');
        l_amount_set_id := PA_FIN_PLAN_UTILS.get_amount_set_id(l_budget_version_id);

                 PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS(
                      P_AMOUNT_SET_ID      => l_amount_set_id
                     ,X_RAW_COST_FLAG      => lx_raw_cost_flag
                     ,X_BURDENED_FLAG      => lx_burdened_cost_flag
                     ,X_REVENUE_FLAG       => lx_revenue_flag
                     ,X_COST_QUANTITY_FLAG => lx_cost_qty_flag
                     ,X_REV_QUANTITY_FLAG  => lx_revenue_qty_flag
                     ,X_ALL_QUANTITY_FLAG  => lx_all_qty_flag
                     ,X_BILL_RATE_FLAG     => l_bill_rate_flag
                     ,X_COST_RATE_FLAG     => l_cost_rate_flag
                     ,X_BURDEN_RATE_FLAG   => l_burden_rate_flag
                     ,x_message_count      => l_msg_count
                     ,x_return_status      => x_return_status
                     ,x_message_data       => l_msg_data) ;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                         -- RAISE  FND_API.G_EXC_ERROR;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
  END IF; -- BUDGET_TYPE_CODE IS NULL FOR FINPLAN MODEL. */
  /*Commenting ends for bug 6408139 */


  /* Modified code for bug 6408139*/
  /* Bug 6408139 : Get Plan Amount Entry flags ONLY if ALL the passed ones are G_PA_MISS_CHAR */
  /* If even a single flag has been passed as NOT G_PA_MISS_CHAR, then we have already got the */
  /* flags from validate_header_info */
 IF l_budget_type_code IS NULL THEN

    IF (  ( lx_raw_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          ( lx_burdened_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_revenue_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_cost_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_revenue_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_all_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_bill_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_cost_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
      ( lx_burden_rate_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN

        l_amount_set_id := PA_FIN_PLAN_UTILS.get_amount_set_id(l_budget_version_id);

                 PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS(
                      P_AMOUNT_SET_ID      => l_amount_set_id
                     ,X_RAW_COST_FLAG      => lx_raw_cost_flag
                     ,X_BURDENED_FLAG      => lx_burdened_cost_flag
                     ,X_REVENUE_FLAG       => lx_revenue_flag
                     ,X_COST_QUANTITY_FLAG => lx_cost_qty_flag
                     ,X_REV_QUANTITY_FLAG  => lx_revenue_qty_flag
                     ,X_ALL_QUANTITY_FLAG  => lx_all_qty_flag
                     ,X_BILL_RATE_FLAG     => lx_bill_rate_flag -- l_bill_rate_flag
                     ,X_COST_RATE_FLAG     => lx_cost_rate_flag -- l_cost_rate_flag
                     ,X_BURDEN_RATE_FLAG   => lx_burden_rate_flag -- l_burden_rate_flag
                     ,x_message_count      => l_msg_count
                     ,x_return_status      => x_return_status
                     ,x_message_data       => l_msg_data) ;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                         -- RAISE  FND_API.G_EXC_ERROR;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

    END IF ; -- Getting plan flags only when all are passed as G_PA_MISS_CHAR
   END IF; -- BUDGET_TYPE_CODE IS NULL FOR FINPLAN MODEL.
   /*Modified code ends for bug 6408139*/


   OPEN l_lock_budget_csr( l_budget_version_id ); -- 3453650
   CLOSE l_lock_budget_csr;             --FYI, does not release locks

/*   -- Changes made by Xin Liu for using of SQL BIND VARIABLE 12-MAY-2003 */
    --building the dynamic SQL statement

    l_statement := ' UPDATE PA_BUDGET_VERSIONS SET ';

    IF  (p_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_description IS NULL)
    AND    nvl(p_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> nvl(l_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN

             l_statement := l_statement ||
                           ' DESCRIPTION = :xDescription'||',';

            l_update_yes_flag := 'Y';
    END IF;

    IF  (p_change_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_change_reason_code IS NULL)
    AND    nvl(p_change_reason_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> nvl(l_change_reason_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN

    IF ( p_change_reason_code IS NOT NULL AND
             p_change_reason_code  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
        THEN

            OPEN l_budget_change_reason_csr( p_change_reason_code );
            FETCH l_budget_change_reason_csr INTO l_dummy;

            IF l_budget_change_reason_csr%NOTFOUND
            THEN
                CLOSE l_budget_change_reason_csr;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
            pa_interface_utils_pub.map_new_amg_msg
             ( p_old_message_code => 'PA_CHANGE_REASON_INVALID'
              ,p_msg_attribute    => 'CHANGE'
              ,p_resize_flag      => 'N'
              ,p_msg_context      => 'BUDG'
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => l_budget_type_code
              ,p_attribute4       => ''
              ,p_attribute5       => '');
            END IF;

                RAISE FND_API.G_EXC_ERROR;
            END IF;

        CLOSE l_budget_change_reason_csr;

        END IF;

        l_statement := l_statement ||
                       ' CHANGE_REASON_CODE = :xChangeReasonCode'||',';

        l_update_yes_flag := 'Y';

    END IF;

/*Addition for the bug 3453650 starts */
-- commented below code for the bug 4702500/4730094
/*
IF l_budget_type_code IS NULL THEN

        IF (p_set_current_working_flag IS  NULL
        OR p_set_current_working_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
        AND (nvl(p_set_current_working_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
         nvl(l_current_working_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
        THEN
          l_statement := l_statement || 'CURRENT_WORKING_FLAG = :xSetCurrentWorkingFlag' || ',';
        l_update_yes_flag := 'Y';

        END IF;

END IF; --l_budget_type_code is null
*/

IF (p_budget_version_name IS NULL
OR p_budget_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
AND  (nvl(p_budget_version_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
         nvl(l_budget_version_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
then
  l_statement := l_statement || 'VERSION_NAME = :xBudgetVersionName' || ',';

  l_update_yes_flag := 'Y';
end if;

/*Addition for the bug 3453650 ends */

/*Below code is added for Bug 6417360*/

   open c_dff_values(l_budget_version_id);

   fetch c_dff_values into l_attribute_category,
                           l_attribute1,
                           l_attribute2,
                           l_attribute3,
                           l_attribute4,
                           l_attribute5,
                           l_attribute6,
                           l_attribute7,
                           l_attribute8,
                           l_attribute9,
                           l_attribute10,
                           l_attribute11,
                           l_attribute12,
                           l_attribute13,
                           l_attribute14,
                           l_attribute15;
    close c_dff_values;

    --Validate PA_BUDGET_VERSIONS_DESC_FLEX

-- 6188316 Adding double quotes for all 15 attributes and category values being appended to Update Query String

    if ((p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute_category is null)
        and nvl(p_attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute_category := p_attribute_category;
            if l_attribute_category is null then

                 l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY = null,';
            else
                l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY = '''||l_attribute_category||''',';
            end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute1 is null)
        and nvl(p_attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute1 := p_attribute1;
           -- dbms_output.put_line(' came inside the outer if ');
             if l_attribute1 is null then
               --  dbms_output.put_line(' came inside the inner if ');
                 l_statement := l_statement ||
                               ' ATTRIBUTE1 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE1 = '''||l_attribute1||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute2 is null)
        and nvl(p_attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute2 := p_attribute2;
             if l_attribute2 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE2 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE2 = '''||l_attribute2||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute3 is null)
        and nvl(p_attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute3 := p_attribute3;
             if l_attribute3 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE3 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE3 = '''||l_attribute3||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute4 is null)
        and nvl(p_attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute4 := p_attribute4;
             if l_attribute4 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE4 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE4 = '''||l_attribute4||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute5 is null)
        and nvl(p_attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute5 := p_attribute5;
             if l_attribute5 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE5 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE5 = '''||l_attribute5||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute6 is null)
        and nvl(p_attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute6 := p_attribute6;
             if l_attribute6 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE6 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE6 = '''||l_attribute6||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute7 is null)
        and nvl(p_attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute7 := p_attribute7;
             if l_attribute7 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE7 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE7 = '''||l_attribute7||''',';
             end if;
              l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute8 is null)
        and nvl(p_attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute8 := p_attribute8;
             if l_attribute8 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE8 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE8 = '''||l_attribute8||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute9 is null)
        and nvl(p_attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute9 := p_attribute9;
             if l_attribute9 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE9 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE9 = '''||l_attribute9||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute10 is null)
        and nvl(p_attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute10 := p_attribute10;
             if l_attribute10 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE10 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE10 = '''||l_attribute10||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute11 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute11 is null)
        and nvl(p_attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute11,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute11 := p_attribute11;
             if l_attribute11 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE11 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE11 = '''||l_attribute11||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute12 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute12 is null)
        and nvl(p_attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute12,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute12 := p_attribute12;
             if l_attribute12 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE12 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE12 = '''||l_attribute12||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute13 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute13 is null)
        and nvl(p_attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute13,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute13 := p_attribute13;
             if l_attribute13 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE13 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE13 = '''||l_attribute13||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute14 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute14 is null)
        and nvl(p_attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute14,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute14 := p_attribute14;
             if l_attribute14 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE14 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE14 = '''||l_attribute14||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;

    if ((p_attribute15 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         or p_attribute15 is null)
        and nvl(p_attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_attribute15,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) then
            l_attribute15 := p_attribute15;
             if l_attribute15 is null then
                 l_statement := l_statement ||
                               ' ATTRIBUTE15 = null,';
             else
                l_statement := l_statement ||
                               ' ATTRIBUTE15 = '''||l_attribute15||''',';
             end if;
             l_update_yes_flag := 'Y';
    end if;
/*
    dbms_output.put_line('statement ');
    dbms_output.put_line('l_attribute_category '||l_attribute_category);
    dbms_output.put_line('l_attribute1 '||l_attribute1);
    dbms_output.put_line('l_attribute2 '||l_attribute2);
    dbms_output.put_line('l_attribute3 '||l_attribute3);
    dbms_output.put_line('l_attribute4 '||l_attribute4);
    dbms_output.put_line('l_attribute5 '||l_attribute5);

    dbms_output.put_line('l_attribute6 '||l_attribute6);
    dbms_output.put_line('l_attribute7 '||l_attribute7);
    dbms_output.put_line('l_attribute8 '||l_attribute8);
    dbms_output.put_line('l_attribute9 '||l_attribute9);
    dbms_output.put_line('l_attribute10 '||l_attribute10);

    dbms_output.put_line('l_attribute11 '||l_attribute11);
    dbms_output.put_line('l_attribute12 '||l_attribute12);
    dbms_output.put_line('l_attribute13 '||l_attribute13);
    dbms_output.put_line('l_attribute14 '||l_attribute14);
    dbms_output.put_line('l_attribute15 '||l_attribute15);*/


    pa_task_utils.validate_flex_fields(
          p_desc_flex_name        => 'PA_BUDGET_VERSIONS_DESC_FLEX'
         ,p_attribute_category    => l_attribute_category
         ,p_attribute1            => l_attribute1
         ,p_attribute2            => l_attribute2
         ,p_attribute3            => l_attribute3
         ,p_attribute4            => l_attribute4
         ,p_attribute5            => l_attribute5
         ,p_attribute6            => l_attribute6
         ,p_attribute7            => l_attribute7
         ,p_attribute8            => l_attribute8
         ,p_attribute9            => l_attribute9
         ,p_attribute10           => l_attribute10
         ,p_attribute11           => l_attribute11
         ,p_attribute12           => l_attribute12
         ,p_attribute13           => l_attribute13
         ,p_attribute14           => l_attribute14
         ,p_attribute15           => l_attribute15
         ,p_RETURN_msg            => l_msg_data
         ,p_validate_status       => l_validate_status
         );
     IF l_validate_status = 'N'
        THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                  pa_interface_utils_pub.map_new_amg_msg
                            ( p_old_message_code => 'PA_INVALID_FF_VALUES'
                            ,p_msg_attribute    => 'CHANGE'
                            ,p_resize_flag      => 'N'
                            ,p_msg_context      => 'FLEX'
                            ,p_attribute1       => l_msg_data
                            ,p_attribute2       => ''
                            ,p_attribute3       => ''
                            ,p_attribute4       => ''
                            ,p_attribute5       => '');
            END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

/*End of code for Bug 6417360*/

    IF l_update_yes_flag = 'Y'
    THEN
            l_statement := l_statement ||
                           ' LAST_UPDATE_DATE = '||''''||
                           SYSDATE||''''||',';

            l_statement := l_statement ||
                           ' LAST_UPDATED_BY = '||G_USER_ID||',';

            l_statement := l_statement ||
                           ' LAST_UPDATE_LOGIN = '||G_LOGIN_ID;

            l_statement := l_statement ||
            ' WHERE BUDGET_VERSION_ID  = '||TO_CHAR(l_budget_version_id);

        l_cursor_id := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(l_cursor_id, l_statement, DBMS_SQL.native);

    IF  (p_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_description IS NULL)
         AND    nvl(p_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
                nvl(l_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xDescription', p_description);

    END IF;

    IF  (p_change_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_change_reason_code IS NULL)
    AND  nvl(p_change_reason_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
         nvl(l_change_reason_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xChangeReasonCode', p_change_reason_code);

    END IF;


/*Addition for the bug 3453650 starts */
IF l_budget_type_code IS NULL THEN
    IF  (p_set_current_working_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_set_current_working_flag IS NULL)
    AND  nvl(p_set_current_working_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
         nvl(l_current_working_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
            -- Get the details of the current working version so as to pass it to the
            -- Set Current Working API.
            pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                   p_project_id            => l_project_id
                  ,p_fin_plan_type_id      => l_fin_plan_type_id
                  ,p_version_type          => lx_version_type
                  ,x_fp_options_id         => l_proj_fp_options_id
                  ,x_fin_plan_version_id   => l_CW_version_id
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => l_msg_count
                  ,x_msg_data              => l_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Further processing is required only if the version to be updated is not the current working verion
            IF  l_budget_version_id <>  l_CW_version_id THEN

                  --Get the record version number of the current working version
                  l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                  --Get the record version number of the version to be updated
                  l_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_budget_version_id);

                  pa_fin_plan_pvt.lock_unlock_version
                       (p_budget_version_id       => l_CW_version_id,
                        p_record_version_number   => l_CW_record_version_number,
                        p_action                  => 'L',
                        p_user_id                 => l_user_id,
                        p_person_id               => lx_locked_by_person_id,
                        x_return_status           => x_return_status,
                        x_msg_count               => l_msg_count,
                        x_msg_data                => l_msg_data) ;

                  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Error executing lock unlock version';
                              pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to call set current working version';
                        pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  -- Getting the rec ver number again as it will be incremented by the api  lock_unlock_version
                  l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                  pa_fin_plan_pub.Set_Current_Working
                        (p_project_id                  => l_project_id,
                         p_budget_version_id           => l_budget_version_id,
                         p_record_version_number       => l_record_version_number,
                         p_orig_budget_version_id      => l_CW_version_id,
                         p_orig_record_version_number  => l_CW_record_version_number,
                         x_return_status               => x_return_status,
                         x_msg_count                   => l_msg_count,
                         x_msg_data                    => l_msg_data);

                  IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                        IF  l_debug_mode= 'Y' THEN
                              pa_debug.g_err_stage:= 'Error executing Set_Current_Working ';
                              pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

            END IF; --  IF  l_created_version_id <>  l_CW_version_id THEN


    END IF;

END IF; -- l_budget_type_code IS NULL

    IF  (p_budget_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_budget_version_name IS NULL)
    AND  nvl(p_budget_version_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
         nvl(l_budget_version_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
        DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':xBudgetVersionName', lx_budget_version_name);

    END IF;
/*Addition for the bug 3453650 ends */

        l_rows   := DBMS_SQL.execute(l_cursor_id);

        IF DBMS_SQL.is_open (l_cursor_id)
        THEN
            DBMS_SQL.close_cursor (l_cursor_id);
        END IF;

   END IF;

/* Bug 6408139 : We are setting the amount_set_id ONLY when atleast some of the */
/* input amount entry flags ARE not G_PA_MISS_CHAR , which means, user wants to */
/* change some flag*/
IF l_budget_type_code IS NULL THEN   -- finplan model

  IF (( lx_raw_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_burdened_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_revenue_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_cost_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_revenue_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_all_qty_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_bill_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_cost_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
          ( lx_burden_rate_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) ) THEN

        --Get the preference code
        IF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY;
        ELSIF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY;
        ELSIF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME;
        END IF;

        IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Preference code is -> ' || l_plan_pref_code;
          pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;


        --Get the amount set id.
        pa_fin_plan_utils.GET_OR_CREATE_AMOUNT_SET_ID
        (
                 p_raw_cost_flag            => lx_raw_cost_flag
                ,p_burdened_cost_flag       => lx_burdened_cost_flag
                ,p_revenue_flag             => lx_revenue_flag
                ,p_cost_qty_flag            => lx_cost_qty_flag
                ,p_revenue_qty_flag         => lx_revenue_qty_flag
                ,p_all_qty_flag             => lx_all_qty_flag
                ,p_plan_pref_code           => l_plan_pref_code
                ,p_bill_rate_flag           => lx_bill_rate_flag
                ,p_cost_rate_flag           => lx_cost_rate_flag
                ,p_burden_rate_flag         => lx_burden_rate_flag
                ,x_cost_amount_set_id       => l_cost_amount_set_id
                ,x_revenue_amount_set_id    => l_rev_amount_set_id
                ,x_all_amount_set_id        => l_all_amount_set_id
                ,x_message_count            => l_msg_count
                ,x_return_status            => x_return_status
                ,x_message_data             => l_msg_data
        );

        IF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN
                l_amount_set_id := l_cost_amount_set_id;
        ELSIF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN
                l_amount_set_id := l_rev_amount_set_id;
        ELSIF(lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN
                l_amount_set_id := l_all_amount_set_id;
        END IF;

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Amount set id is -> ' || l_amount_set_id;
           pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        l_proj_fp_options_id_new :=  PA_PROJ_FP_OPTIONS_PUB.Get_FP_Option_ID
                                     (p_project_id => l_project_id
                                     ,p_plan_type_id => l_fin_plan_type_id
                                     ,p_plan_version_id => l_budget_version_id
                                     );


        IF lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
         UPDATE pa_proj_fp_options
         SET    cost_amount_set_id           =   l_amount_set_id
         WHERE  proj_fp_options_id = l_proj_fp_options_id_new;
        ELSIF lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
         UPDATE pa_proj_fp_options
         SET    revenue_amount_set_id         =   l_amount_set_id
         WHERE  proj_fp_options_id = l_proj_fp_options_id_new;
        ELSIF lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL THEN
         UPDATE pa_proj_fp_options
         SET    all_amount_set_id             =   l_amount_set_id
         WHERE  proj_fp_options_id = l_proj_fp_options_id_new;
       END IF;

  END IF ; -- G_PA_MISS_CHAR condition

END IF ; --IF l_budget_type_code IS NULL THEN

/*Bug 6408139 : Code addition ends*/

  l_budget_lines_in := p_budget_lines_in;
-- Changes for the bug 3453650
            IF ( nvl(l_budget_lines_in.last,0) > 0 ) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to call validate budget lines in Budgets model';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                --Handle G_MISS_XXX for l_budget_lines_in before calling Validate_Budget_Lines.
                FOR i in l_budget_lines_in.FIRST..l_budget_lines_in.LAST LOOP

                             IF l_budget_lines_in(i).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).pa_task_id   :=  NULL;
                             END IF;

                             IF l_budget_lines_in(i).pm_task_reference =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).pm_task_reference  :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_alias= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).resource_alias :=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).resource_list_member_id =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).resource_list_member_id:=  NULL;
                              END IF;

                             IF l_budget_lines_in(i).budget_start_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_start_date:=  NULL;
                              END IF;
                             IF l_budget_lines_in(i).budget_end_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                                    l_budget_lines_in(i).budget_end_date:=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).period_name := NULL;
                              END IF;

                              IF l_budget_lines_in(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).raw_cost   :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).burdened_cost  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).revenue  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                    l_budget_lines_in(i).quantity  := NULL;
                              END IF;


                              IF l_budget_lines_in(i).change_reason_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).change_reason_code  :=NULL;
                              END IF;

                              IF l_budget_lines_in(i).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).description     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute_category     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute1     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute2     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute3     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute4     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute5     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute6     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute7     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute8     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute9     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute10     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute11     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute12     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute13     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute14     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).attribute15     :=  NULL;
                              END IF;

                              IF l_budget_lines_in(i).txn_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                    l_budget_lines_in(i).txn_currency_code := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                                l_budget_lines_in(i).PROJFUNC_COST_RATE_TYPE := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                              l_budget_lines_in(i).PROJFUNC_COST_RATE_DATE     := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                              l_budget_lines_in(i).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                               l_budget_lines_in(i).PROJFUNC_REV_RATE_TYPE      := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_rev_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                              l_budget_lines_in(i).PROJFUNC_REV_RATE_DATE      := NULL;
                              END IF;

                              IF l_budget_lines_in(i).projfunc_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                              l_budget_lines_in(i).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                              END IF;

                              IF  l_budget_lines_in(i).project_cost_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_budget_lines_in(i).PROJECT_COST_RATE_TYPE      := NULL;
                              END IF;

                              IF l_budget_lines_in(i).project_cost_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_budget_lines_in(i).PROJECT_COST_RATE_DATE_TYPE := NULL;
                              END IF;

                              IF l_budget_lines_in(i).project_cost_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE    THEN
                              l_budget_lines_in(i).PROJECT_COST_RATE_DATE      := NULL;
                              END IF;

                              IF l_budget_lines_in(i).project_cost_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                              l_budget_lines_in(i).PROJECT_COST_EXCHANGE_RATE  := NULL;
                              END IF;

                              IF  l_budget_lines_in(i).project_rev_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_lines_in(i).PROJECT_REV_RATE_TYPE       := NULL;
                              END IF;

                              IF l_budget_lines_in(i).project_rev_rate_date_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_lines_in(i).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                              END IF;

                              IF l_budget_lines_in(i).project_rev_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                              l_budget_lines_in(i).PROJECT_REV_RATE_DATE       := NULL;
                              END IF;

                              IF  l_budget_lines_in(i).project_rev_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                              l_budget_lines_in(i).PROJECT_REV_EXCHANGE_RATE   := NULL;
                              END IF;

                              IF l_budget_lines_in(i).pm_product_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                              l_budget_lines_in(i).pm_product_code             := NULL;
                              END IF;

                              IF l_budget_lines_in(i).pm_budget_line_reference=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_budget_lines_in(i).pm_budget_line_reference    := NULL;
                              END IF;
                END LOOP;
END IF; -- ( nvl(l_budget_lines_in.last,0) > 0 )

l_version_info_rec.x_budget_version_id := l_budget_version_id;  --Added for bug 4290310.

IF l_budget_type_code IS NOT NULL THEN

                  pa_budget_pvt.Validate_Budget_Lines
                  (p_pa_project_id               => l_project_id
                  ,p_budget_type_code            => l_budget_type_code
                  ,p_fin_plan_type_id            => NULL
                  ,p_version_type                => NULL
                  ,p_resource_list_id            => lx_resource_list_id
                  ,p_time_phased_code            => lx_time_phased_type_code
                  ,p_budget_entry_method_code    => l_budget_entry_method_code
                  ,p_entry_level_code            => l_entry_level_code
                  ,p_allow_qty_flag              => NULL
                  ,p_allow_raw_cost_flag         => NULL
                  ,p_allow_burdened_cost_flag    => NULL
                  ,p_allow_revenue_flag          => NULL
                  ,p_multi_currency_flag         => NULL
                  ,p_project_cost_rate_type      => NULL
                  ,p_project_cost_rate_date_typ  => NULL
                  ,p_project_cost_rate_date      => NULL
                  ,p_project_cost_exchange_rate  => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_projfunc_cost_rate_type     => NULL
                  ,p_projfunc_cost_rate_date_typ => NULL
                  ,p_projfunc_cost_rate_date     => NULL
                  ,p_projfunc_cost_exchange_rate => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_project_rev_rate_type       => NULL
                  ,p_project_rev_rate_date_typ   => NULL
                  ,p_project_rev_rate_date       => NULL
                  ,p_project_rev_exchange_rate   => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_projfunc_rev_rate_type      => NULL
                  ,p_projfunc_rev_rate_date_typ  => NULL
                  ,p_projfunc_rev_rate_date      => NULL
                  ,p_projfunc_rev_exchange_rate  => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,px_budget_lines_in            => l_budget_lines_in
                  ,x_budget_lines_out            => p_budget_lines_out /* Bug 3368135*/
/* Bug 3986129: FP.M Web ADI Dev changes: New parameters added */
                  ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                  ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                  ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                  ,x_msg_count                   => p_msg_count
                  ,x_msg_data                    => p_msg_data
                  ,x_return_status               => p_return_status);

            IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN  -- 3453650
                        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

ELSE --l_budget_type_code IS NOT NULL

                 IF lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
                      l_allow_qty_flag := lx_cost_qty_flag;
                 ELSIF lx_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
                      l_allow_qty_flag := lx_revenue_qty_flag;
                 ELSE
                      l_allow_qty_flag :=  lx_all_qty_flag;
                 END IF;

                  --Validate the finplan lines passed
                  pa_budget_pvt.Validate_Budget_Lines
                  ( p_pa_project_id              => l_project_id
                  ,p_budget_type_code            => NULL
                  ,p_fin_plan_type_id            => l_fin_plan_type_id
                  ,p_version_type                => lx_version_type
                  ,p_resource_list_id            => lx_resource_list_id
                  ,p_time_phased_code            => lx_time_phased_type_code
                  ,p_budget_entry_method_code    => NULL
                  ,p_entry_level_code            => l_fin_plan_level_code
                  ,p_allow_qty_flag              => l_allow_qty_flag
                  ,p_allow_raw_cost_flag         => lx_raw_cost_flag
                  ,p_allow_burdened_cost_flag    => lx_burdened_cost_flag
                  ,p_allow_revenue_flag          => lx_revenue_flag  --Bug 4422201.Passing the correct flag for this parameter.
                  ,p_multi_currency_flag         => lx_plan_in_multi_curr_flag
                  ,p_project_cost_rate_type      => lx_project_cost_rate_type
                  ,p_project_cost_rate_date_typ  => lx_project_cost_rate_date_typ
                  ,p_project_cost_rate_date      => lx_project_cost_rate_date
                  ,p_project_cost_exchange_rate  => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_projfunc_cost_rate_type     => lx_projfunc_cost_rate_type
                  ,p_projfunc_cost_rate_date_typ => lx_projfunc_cost_rate_date_typ
                  ,p_projfunc_cost_rate_date     => lx_projfunc_cost_rate_date
                  ,p_projfunc_cost_exchange_rate => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_project_rev_rate_type       => lx_project_rev_rate_type
                  ,p_project_rev_rate_date_typ   => lx_project_rev_rate_date_typ
                  ,p_project_rev_rate_date       => lx_project_rev_rate_date
                  ,p_project_rev_exchange_rate   => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_projfunc_rev_rate_type      => lx_projfunc_rev_rate_type
                  ,p_projfunc_rev_rate_date_typ  => lx_projfunc_rev_rate_date_typ
                  ,p_projfunc_rev_rate_date      => lx_projfunc_rev_rate_date
                  ,p_projfunc_rev_exchange_rate  => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --Passing this as G_MISS_XXX as this is obsolete parameter
                  ,p_version_info_rec            => l_version_info_rec  -- Added for bug 4290310.
                  ,px_budget_lines_in            => l_budget_lines_in
                  ,x_budget_lines_out            => p_budget_lines_out /* Bug 3368135*/
/* Bug 3986129: FP.M Web ADI Dev changes: New parameters added */
                  ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                  ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                  ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                  ,x_msg_count                   => p_msg_count
                  ,x_msg_data                    => p_msg_data
                  ,x_return_status               => p_return_status);

                  IF(p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
END IF; --l_budget_type_code IS NOT NULL

--In the below code for finplan model validate header level currency conversion attributes and update them.
IF (l_budget_type_code IS NULL)
THEN
        IF(lx_plan_in_multi_curr_flag = 'N')
        THEN
               IF((p_projfunc_cost_rate_type is null OR p_projfunc_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_projfunc_cost_rate_date_typ is null OR p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_projfunc_cost_rate_date is null OR p_projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                  (p_projfunc_rev_rate_type is null OR  p_projfunc_rev_rate_type =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_projfunc_rev_rate_date_typ is null OR p_projfunc_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_projfunc_rev_rate_date is null OR p_projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                  (p_project_cost_rate_type is null OR p_project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_project_cost_rate_date_typ is null OR p_project_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_project_cost_rate_date is null OR p_project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
                  (p_project_rev_rate_type is null OR p_project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_project_rev_rate_date_typ is null OR p_project_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  (p_project_rev_rate_date is null OR p_project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ))
               THEN
                   NULL;
               ELSE
               /*even if one of the currency conversion attributes is not null then call validate header info
                *coz its possible tht multi currency flag could be No and we can still have values for the currency conversion
                *attributes*/
               l_call_validate_curr_api_flg := 'Y'; --Setting this flag to call the validate_currency_conversion API later.
               END IF;
        ELSIF (lx_plan_in_multi_curr_flag = 'Y') THEN
              IF( p_projfunc_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
                  p_projfunc_rev_rate_type =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_projfunc_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
                  p_project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_project_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
                  p_project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_project_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                  p_project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
               THEN --if the user doesnt want them to change then we need not call validate API
                   NULL;
               ELSE
             /*Here there could be two cases. All the passed MC conversion attributes could be null or one of them could be not null
             *When even one of them is not null then validate_conversion_attributes API has to be called surely for validating the attribute
             * which has been passed.
             *And for the other case when all the attributes are null we shd be raising the error as this shd not be allowed for MC=Y. So as
             *of now assuming validate_conversion_attribute api would raise this error we are calling the validate conversion API. If this
             * API doesnt raise the error for this case then we will raise the error from here itself*/
             /*validate_conversion_attribute API raises the error when all the MC conversion attributes are null. So we are not
             raising this error from here.*/

               l_call_validate_curr_api_flg := 'Y';--Setting this flag to call the validate_currency_conversion API later.
               END IF;
        END IF;

        IF(l_call_validate_curr_api_flg = 'Y')  --Now call the validate_currency_conversion API
        THEN
                            -- Depending on px_version_type initialise l_conv_attrs_to_be_validated

                 IF (lx_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL) THEN
                      l_conv_attrs_to_be_validated := lx_version_type;
                 ELSE
                      l_conv_attrs_to_be_validated := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH;
                 END IF;

                 IF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN

                       lx_project_rev_rate_type      :=NULL;
                       lx_project_rev_rate_date_typ  :=NULL;
                       lx_project_rev_rate_date      :=NULL;

                       lx_projfunc_rev_rate_type     :=NULL;
                       lx_projfunc_rev_rate_date_typ :=NULL;
                       lx_projfunc_rev_rate_date     :=NULL;

                 ELSIF l_conv_attrs_to_be_validated = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN

                       lx_project_cost_rate_type      :=NULL;
                       lx_project_cost_rate_date_typ  :=NULL;
                       lx_project_cost_rate_date      :=NULL;

                       lx_projfunc_cost_rate_type     :=NULL;
                       lx_projfunc_cost_rate_date_typ :=NULL;
                       lx_projfunc_cost_rate_date     :=NULL;

                 END IF;

                 SELECT p.project_currency_code
                       ,p.projfunc_currency_code
                 INTO   l_project_currency_code
                       ,l_projfunc_currency_code
                 FROM   pa_projects_all p
                 WHERE  p.project_id = l_project_id;


              SELECT projfunc_cost_rate_type
                    ,projfunc_rev_rate_type
                    ,project_cost_rate_type
                    ,project_rev_rate_type
              INTO l_projfunc_cost_rate_type
                  ,l_projfunc_rev_rate_type
                  ,l_project_cost_rate_type
                  ,l_project_rev_rate_type
              FROM   pa_proj_fp_options
              WHERE  project_id = l_project_id
              AND    fin_plan_type_id=l_fin_plan_type_id
              AND    fin_plan_version_id IS NULL
              AND    fin_plan_option_level_code= PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

                  pa_budget_pvt.valid_rate_type
                    (p_pt_project_cost_rate_type => l_project_cost_rate_type,
                     p_pt_project_rev_rate_type  => l_project_rev_rate_type,
                     p_pt_projfunc_cost_rate_type=> l_projfunc_cost_rate_type,
                     p_pt_projfunc_rev_rate_type => l_projfunc_rev_rate_type,
                     p_pv_project_cost_rate_type => lx_project_cost_rate_type,
                     p_pv_project_rev_rate_type  => lx_projfunc_rev_rate_type,
                     p_pv_projfunc_cost_rate_type=> lx_projfunc_cost_rate_type,
                     p_pv_projfunc_rev_rate_type => lx_projfunc_rev_rate_date,
                     x_is_rate_type_valid        => l_is_rate_type_valid,
                     x_return_status             => p_return_status,
                     x_msg_count                 => p_msg_count,
                     x_msg_data                  => p_msg_data);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF l_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:= 'valid_rate_type returned error';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                 pa_fin_plan_utils.validate_currency_attributes
                 (px_project_cost_rate_type      => lx_project_cost_rate_type
                 ,px_project_cost_rate_date_typ  => lx_project_cost_rate_date_typ
                 ,px_project_cost_rate_date      => lx_project_cost_rate_date
                 ,px_project_cost_exchange_rate  => l_project_cost_exchange_rate
                 ,px_projfunc_cost_rate_type     => lx_projfunc_cost_rate_type
                 ,px_projfunc_cost_rate_date_typ => lx_projfunc_cost_rate_date_typ
                 ,px_projfunc_cost_rate_date     => lx_projfunc_cost_rate_date
                 ,px_projfunc_cost_exchange_rate => l_projfunc_cost_exchange_rate
                 ,px_project_rev_rate_type       => lx_project_rev_rate_type
                 ,px_project_rev_rate_date_typ   => lx_project_rev_rate_date_typ
                 ,px_project_rev_rate_date       => lx_project_rev_rate_date
                 ,px_project_rev_exchange_rate   => l_project_rev_exchange_rate
                 ,px_projfunc_rev_rate_type      => lx_projfunc_rev_rate_type
                 ,px_projfunc_rev_rate_date_typ  => lx_projfunc_rev_rate_date_typ
                 ,px_projfunc_rev_rate_date      => lx_projfunc_rev_rate_date
                 ,px_projfunc_rev_exchange_rate  => l_projfunc_rev_exchange_rate
                 ,p_project_currency_code        => l_project_currency_code
                 ,p_projfunc_currency_code       => l_projfunc_currency_code
                 ,p_context                      => PA_FP_CONSTANTS_PKG.G_AMG_API_HEADER
                 ,p_attrs_to_be_validated        => l_conv_attrs_to_be_validated
                 ,x_return_status                => p_return_status
                 ,x_msg_count                    => p_msg_count
                 ,x_msg_data                     => p_msg_data);

                 IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      p_return_status:=FND_API.G_RET_STS_ERROR;
                      IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'Validate currency attributes returned error';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Updating pa_proj_fp_options with multi currency conversion attributes';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

               update pa_proj_fp_options
               set
               projfunc_cost_rate_type       = decode(p_projfunc_cost_rate_type,    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,   projfunc_cost_rate_type     ,  p_projfunc_cost_rate_type)
              ,projfunc_cost_rate_date_type  = decode(p_projfunc_cost_rate_date_typ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,   projfunc_cost_rate_date_type,  p_projfunc_cost_rate_date_typ)
              ,projfunc_cost_rate_date       = decode(p_projfunc_cost_rate_date,    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,   projfunc_cost_rate_date     ,  p_projfunc_cost_rate_date)
              ,projfunc_rev_rate_type        = decode(p_projfunc_rev_rate_type,     PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,   projfunc_rev_rate_type      ,  p_projfunc_rev_rate_type)
              ,projfunc_rev_rate_date_type   = decode(p_projfunc_rev_rate_date_typ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  projfunc_rev_rate_date_type ,  p_projfunc_rev_rate_date_typ)
              ,projfunc_rev_rate_date        = decode(p_projfunc_rev_rate_date,     PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,  projfunc_rev_rate_date       ,  p_projfunc_rev_rate_date)
              ,project_cost_rate_type        = decode(p_project_cost_rate_type,     PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,   project_cost_rate_type      ,  p_project_cost_rate_type)
              ,project_cost_rate_date_type   = decode(p_project_cost_rate_date_typ,  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  project_cost_rate_date_type ,  p_project_cost_rate_date_typ)
              ,project_cost_rate_date        = decode(p_project_cost_rate_date,     PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,  project_cost_rate_date       ,  p_project_cost_rate_date)
              ,project_rev_rate_type         = decode(p_project_rev_rate_type,      PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  project_rev_rate_type        ,  p_project_rev_rate_type)
              ,project_rev_rate_date_type    = decode(p_project_rev_rate_date_typ,   PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,  project_rev_rate_date_type  ,  p_project_rev_rate_date_typ)
              ,project_rev_rate_date         = decode(p_project_rev_rate_date,      PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,  project_rev_rate_date        ,  p_project_rev_rate_date)
              ,record_version_number         = record_version_number +1
              ,last_update_date     =    SYSDATE
              ,last_updated_by      =    G_USER_ID
              ,last_update_login    =    G_LOGIN_ID
              where project_id = l_project_id
              and fin_plan_type_id = l_fin_plan_type_id
              and fin_plan_version_id = l_budget_version_id;
        END IF;  --(l_call_validate_curr_api_flg = 'Y')
END IF;--For finplan model validate header level currency conversion attributes.

--Major changes for the bug 3453650

     -- BUDGET LINES

    l_budget_line_index := p_budget_lines_in.first;

IF p_budget_lines_in.exists(l_budget_line_index)
THEN
      IF l_budget_type_code IS NOT NULL THEN   -- bug 3453650
          OPEN l_budget_entry_method_csr( l_budget_entry_method_code );
          FETCH l_budget_entry_method_csr INTO l_time_phased_type_code
                          , l_entry_level_code
                         , l_categorization_code;
          CLOSE l_budget_entry_method_csr;
      END IF;

     --Initializing the variable j which is used to build the l_finplan_lines_tab for the finplan model.
     j:=1;
      <<budget_line>>
      WHILE l_budget_line_index IS NOT NULL LOOP

 --dbms_output.put_line('In budget lines LOOP');

    --initialize return status for budget line to success
    p_budget_lines_out(l_budget_line_index).return_status   := FND_API.G_RET_STS_SUCCESS;

   /*Note carefully that we should be using l_budget_lines_in for all the processing going fwd. This l_budgte_lines_in table is an
    *.output parameter of vallidate_budget_lines(this call to validate_budget_lines has been made before this point in code).  */
    l_budget_line_in_rec := l_budget_lines_in(l_budget_line_index);--p_budget_lines_in(l_budget_line_index);


        IF l_budget_line_in_rec.period_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND l_budget_line_in_rec.period_name IS NOT NULL
        THEN

            OPEN l_budget_periods_csr( l_budget_line_in_rec.period_name
                          ,l_time_phased_type_code);

            FETCH l_budget_periods_csr INTO l_budget_start_date;  --is needed to be able to identify a budgetline

            IF   l_budget_periods_csr%NOTFOUND
            THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
            pa_interface_utils_pub.map_new_amg_msg
             ( p_old_message_code => 'PA_BUDGET_PERIOD_IS_INVALID'
              ,p_msg_attribute    => 'CHANGE'
              ,p_resize_flag      => 'Y'
              ,p_msg_context      => 'BUDG'
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => l_budget_type_code
              ,p_attribute4       => ''
              ,p_attribute5       => '');
            END IF;

            CLOSE l_budget_periods_csr;
                p_budget_lines_out(l_budget_line_index).return_status := FND_API.G_RET_STS_ERROR;
         p_multiple_task_msg  := 'F';


            END IF;

            CLOSE l_budget_periods_csr;

        ELSIF  l_budget_line_in_rec.budget_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
           AND l_budget_line_in_rec.budget_start_date IS NOT NULL
        THEN

            l_budget_start_date := trunc(l_budget_line_in_rec.budget_start_date);

        ELSE

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            pa_interface_utils_pub.map_new_amg_msg
             ( p_old_message_code => 'PA_START_DATE_MISSING'
              ,p_msg_attribute    => 'CHANGE'
              ,p_resize_flag      => 'N'
              ,p_msg_context      => 'BUDG'
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => l_budget_type_code
              ,p_attribute4       => ''
              ,p_attribute5       => '');
        END IF;

        p_budget_lines_out(l_budget_line_index).return_status := FND_API.G_RET_STS_ERROR;
        p_multiple_task_msg  := 'F';
--        RAISE  FND_API.G_EXC_ERROR;

        END IF;


    -- if resource alias is (passed and not NULL)
    -- and resource member is (passed and not NULL)
    -- then we convert the alias to the id
    -- else we default to the uncategorized resource member

IF l_budget_type_code IS NOT NULL THEN

  IF l_categorization_code = 'N' THEN
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
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => l_budget_type_code
              ,p_attribute4       => ''
              ,p_attribute5       => to_char(l_budget_start_date));
          ELSE
            pa_interface_utils_pub.map_new_amg_msg
             ( p_old_message_code => l_err_stage
              ,p_msg_attribute    => 'CHANGE'
              ,p_resize_flag      => 'N'
              ,p_msg_context      => 'BUDG'
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => l_budget_type_code
              ,p_attribute4       => ''
              ,p_attribute5       => to_char(l_budget_start_date));
          END IF;
          p_multiple_task_msg := 'F';
--        RAISE  FND_API.G_EXC_ERROR;
       END IF;

       l_resource_list_member_id := l_uncategorized_rlmid;
       l_budget_alias := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

  ELSIF l_categorization_code = 'R' THEN
    IF (l_budget_line_in_rec.resource_alias <>
        PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND l_budget_line_in_rec.resource_alias IS NOT NULL)
    OR (l_budget_line_in_rec.resource_list_member_id
       <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND l_budget_line_in_rec.resource_list_member_id IS NOT NULL) THEN

         pa_resource_pub.convert_alias_to_id
            ( p_project_id                  =>  l_project_id --Passing the project id here.
             ,p_resource_list_id            =>  lx_resource_list_id  --3453650
             ,p_alias                       =>l_budget_line_in_rec.resource_alias
             ,p_resource_list_member_id     =>l_budget_line_in_rec.resource_list_member_id
             ,p_out_resource_list_member_id => l_resource_list_member_id
             ,p_return_status               => l_return_status  );

     IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
        p_budget_lines_out(l_budget_line_index).return_status :=
            l_return_status;
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        p_budget_lines_out(l_budget_line_index).return_status :=
            l_return_status;
            p_multiple_task_msg  := 'F';
--        RAISE  FND_API.G_EXC_ERROR;
     END IF;
         l_budget_alias := l_budget_line_in_rec.resource_alias;
     END IF;   -- If l_budget_line_in_rec.resource_alias <>
  END IF; -- If l_categorization_code = 'N'

        -- convert pm_task_reference to pa_task_id
        -- only if entry_level_code in ('L','M','T')
   IF l_entry_level_code = 'P' THEN
      l_task_id := 0;
   END IF;

   IF l_entry_level_code in ('T','L','M') THEN
      Pa_project_pvt.Convert_pm_taskref_to_id
        (p_pa_project_id       => l_project_id,
         p_pa_task_id          => l_budget_line_in_rec.pa_task_id,
         p_pm_task_reference   => l_budget_line_in_rec.pm_task_reference,
         p_out_task_id         => l_task_id,
         p_return_status       => l_return_status );
      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
         p_budget_lines_out(l_budget_line_index).return_status :=
         l_return_status;
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         p_budget_lines_out(l_budget_line_index).return_status :=
         l_return_status;
        p_multiple_task_msg   := 'F';
--        RAISE  FND_API.G_EXC_ERROR;
      END IF;
   END IF;

ELSE -- Bug 3453650 budget_type_code is not null

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
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => lx_fin_plan_type_name
              ,p_attribute4       => ''
              ,p_attribute5       => to_char(l_budget_start_date));
          ELSE
            pa_interface_utils_pub.map_new_amg_msg
             ( p_old_message_code => l_err_stage
              ,p_msg_attribute    => 'CHANGE'
              ,p_resize_flag      => 'N'
              ,p_msg_context      => 'BUDG'
              ,p_attribute1       => l_amg_segment1
              ,p_attribute2       => ''
              ,p_attribute3       => lx_fin_plan_type_name
              ,p_attribute4       => ''
              ,p_attribute5       => to_char(l_budget_start_date));
          END IF;
          p_multiple_task_msg := 'F';
       END IF;

     IF (nvl(l_uncategorized_list_id,-99) = lx_resource_list_id) THEN

               l_budget_line_in_rec.resource_list_member_id :=l_uncategorized_rlmid;
               l_budget_line_in_rec.resource_alias := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
            l_resource_list_member_id := l_uncategorized_rlmid; -- bug 3453650

     ELSE
--end comment for 3453650

          -- convert resource alias to (resource) member id
          -- if resource alias is (passed and not NULL)
          -- and resource member is (passed and not NULL)
          -- then we convert the alias to the id
          -- else we default to the uncategorized resource member

          IF (l_budget_line_in_rec.resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
             AND l_budget_line_in_rec.resource_alias IS NOT NULL)
              OR (l_budget_line_in_rec.resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
             AND l_budget_line_in_rec.resource_list_member_id IS NOT NULL)
          THEN
                pa_resource_pub.Convert_alias_to_id
                        ( p_project_id                  => l_project_id
                         ,p_resource_list_id            => lx_resource_list_id  -- 3453650
                         ,p_alias                       => l_budget_line_in_rec.resource_alias
                         ,p_resource_list_member_id     => l_budget_line_in_rec.resource_list_member_id
                         ,p_out_resource_list_member_id => l_resource_list_member_id  -- 3453650
                         ,p_return_status               => x_return_status   );

                IF x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                        p_budget_lines_out(l_budget_line_index).return_status := x_return_status;
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    p_budget_lines_out(l_budget_line_index).return_status :=
                        x_return_status;
                        p_multiple_task_msg  := 'F';
               END IF;
               l_budget_alias := l_budget_line_in_rec.resource_alias;

          END IF; -- l_budget_line_in_rec.resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       END IF; -- nvl(l_uncategorized_res_list_id,-99) = lx_resource_list_id   Bug 3454650
   IF l_fin_plan_level_code = 'P'
    OR (l_fin_plan_level_code in ('T','L') AND l_budget_line_in_rec.pa_task_id = 0 AND l_fin_plan_type_id IS NOT NULL)  -- Added for Bug 8688683
   THEN
      l_task_id := 0;
   -- END IF;

   ELSIF l_fin_plan_level_code in ('T','L','M') THEN
      Pa_project_pvt.Convert_pm_taskref_to_id
        (p_pa_project_id       => l_project_id,
         p_pa_task_id          => l_budget_line_in_rec.pa_task_id,
         p_pm_task_reference   => l_budget_line_in_rec.pm_task_reference,
         p_out_task_id         => l_task_id,
         p_return_status       => l_return_status );
      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
         p_budget_lines_out(l_budget_line_index).return_status :=
         l_return_status;
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         p_budget_lines_out(l_budget_line_index).return_status :=
         l_return_status;
        p_multiple_task_msg   := 'F';

      END IF;
   END IF; -- l_fin_plan_level_code in ('T','L','M')
  END IF; -- IF BUDGET TYPE CODE IS NOT NULL

   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> ''
    ,p_task_reference => ''
    ,p_task_id => l_task_id);

    --get the resource assignment id

        OPEN l_resource_assignment_csr( l_budget_version_id
                           ,l_task_id
                           ,l_resource_list_member_id);

        FETCH l_resource_assignment_csr INTO l_resource_assignment_id;

        IF l_resource_assignment_csr%NOTFOUND
        THEN
           l_new_resource_assignment := TRUE;
        ELSE
           l_new_resource_assignment := FALSE;
        END IF;

        CLOSE l_resource_assignment_csr;


        IF l_budget_line_in_rec.pm_budget_line_reference =
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
           l_budget_line_in_rec.pm_budget_line_reference := NULL;
        END IF;

/* Bug: 3453650 Added the below code*/

 l_dummy := Null;    --  Added for bug 4192109

IF l_budget_type_code IS NOT NULL THEN
 -- dbms_output.put_line('Checking existence of budget line . l_budget_start_date = ' || l_budget_start_date);
     OPEN l_budget_line_csr( l_resource_assignment_id, l_budget_start_date);

     FETCH l_budget_line_csr INTO l_dummy;
     CLOSE l_budget_line_csr;
ELSE
     IF l_budget_line_in_rec.txn_currency_code IS NULL THEN
          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_NO_TXN_CURRENCY_CODE'
          ,p_msg_attribute    => 'CHANGE'
          ,p_resize_flag      => 'N'
          ,p_msg_context      => 'BUDG'
          ,p_attribute1       => l_amg_segment1
          ,p_attribute2       => ''
          ,p_attribute3       => lx_fin_plan_type_name
          ,p_attribute4       => ''
          ,p_attribute5       => '');

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

     OPEN l_finplan_line_csr(l_resource_assignment_id
                         ,l_budget_start_date
                      ,l_budget_line_in_rec.txn_currency_code);
     FETCH l_finplan_line_csr into l_dummy;
     CLOSE l_finplan_line_csr;
END IF; -- l_budget_type_code IS NOT NULL

IF l_budget_type_code IS NOT NULL THEN
     --if new line then call insert_budget_line (for old model)
     IF (l_dummy <> 'X' OR l_dummy IS NULL) OR (l_new_resource_assignment) OR (lx_resource_list_id <> l_resource_list_id) THEN
          pa_budget_pvt.insert_budget_line
          ( p_return_status      => l_return_status
          ,p_pa_project_id      => l_project_id
          ,p_budget_type_code   => l_budget_type_code
          ,p_pa_task_id         => l_budget_line_in_rec.pa_task_id
          ,p_pm_task_reference  => l_budget_line_in_rec.pm_task_reference
          ,p_resource_alias     => l_budget_alias
          ,p_member_id          => l_resource_list_member_id
          ,p_budget_start_date  => l_budget_line_in_rec.budget_start_date
          ,p_budget_end_date    => l_budget_line_in_rec.budget_end_date
          ,p_period_name        => l_budget_line_in_rec.period_name
          ,p_description        => l_budget_line_in_rec.description
          ,p_raw_cost           => l_budget_line_in_rec.raw_cost
          ,p_burdened_cost      => l_budget_line_in_rec.burdened_cost
          ,p_revenue            => l_budget_line_in_rec.revenue
          ,p_quantity           => l_budget_line_in_rec.quantity
          ,p_pm_product_code    => l_budget_line_in_rec.pm_product_code
          ,p_pm_budget_line_reference => l_budget_line_in_rec.pm_budget_line_reference
          ,p_resource_list_id   => lx_resource_list_id
          ,p_attribute_category => l_budget_line_in_rec.attribute_category
          ,p_attribute1         => l_budget_line_in_rec.attribute1
          ,p_attribute2         => l_budget_line_in_rec.attribute2
          ,p_attribute3         => l_budget_line_in_rec.attribute3
          ,p_attribute4         => l_budget_line_in_rec.attribute4
          ,p_attribute5         => l_budget_line_in_rec.attribute5
          ,p_attribute6         => l_budget_line_in_rec.attribute6
          ,p_attribute7         => l_budget_line_in_rec.attribute7
          ,p_attribute8         => l_budget_line_in_rec.attribute8
          ,p_attribute9         => l_budget_line_in_rec.attribute9
          ,p_attribute10        => l_budget_line_in_rec.attribute10
          ,p_attribute11        => l_budget_line_in_rec.attribute11
          ,p_attribute12        => l_budget_line_in_rec.attribute12
          ,p_attribute13        => l_budget_line_in_rec.attribute13
          ,p_attribute14        => l_budget_line_in_rec.attribute14
          ,p_attribute15        => l_budget_line_in_rec.attribute15
          ,p_time_phased_type_code => lx_time_phased_type_code
          ,p_entry_level_code   => l_entry_level_code
          ,p_budget_amount_code => l_budget_amount_code
          ,p_budget_entry_method_code => l_budget_entry_method_code
          ,p_categorization_code => l_categorization_code
          ,p_budget_version_id   => l_budget_version_id
          ,p_change_reason_code  => l_budget_line_in_rec.change_reason_code  );

          IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
          THEN
          p_budget_lines_out(l_budget_line_index).return_status := l_return_status;
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
          p_budget_lines_out(l_budget_line_index).return_status := l_return_status;
          p_multiple_task_msg  := 'F';
          END IF;

     ELSE -- If the line is already existing, then call update_budget_line_sql
          -- ELSE for the condition : (l_dummy <> 'X' OR l_dummy IS NULL) OR (l


         /*Note carefully that while making the comparision below we are reading from p_budget_lines_in and not from
         *. l_budget_lines_in. l_budget_lines is an o/p parameter of validate_budget_lines call to which is made
         * above in the code flow. And before calling validate_budget_lines G_MISS_XXX handling is done for the values
         * present in l_budget_lines. So we cant use l_budget_lines in making the comparision again*/
             IF p_budget_lines_in(l_budget_line_index).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                   l_budget_line_in_rec.raw_cost   :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).raw_cost is null) THEN
                   l_budget_line_in_rec.raw_cost   :=  FND_API.G_MISS_NUM;
             ELSE
                   l_budget_line_in_rec.raw_cost   :=  l_budget_line_in_rec.raw_cost;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                   l_budget_line_in_rec.burdened_cost  := NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).burdened_cost is null) THEN
                   l_budget_line_in_rec.burdened_cost   :=  FND_API.G_MISS_NUM;
             ELSE
                   l_budget_line_in_rec.burdened_cost  := l_budget_line_in_rec.burdened_cost;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                   l_budget_line_in_rec.revenue  := NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).revenue is null) THEN
                   l_budget_line_in_rec.revenue   :=  FND_API.G_MISS_NUM;
             ELSE
                   l_budget_line_in_rec.revenue  := l_budget_line_in_rec.revenue;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                   l_budget_line_in_rec.quantity  := NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).quantity is null) THEN
                   l_budget_line_in_rec.quantity   :=  FND_API.G_MISS_NUM;
             ELSE
                   l_budget_line_in_rec.quantity  := l_budget_line_in_rec.quantity;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.change_reason_code  :=NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).change_reason_code is null) THEN
                   l_budget_line_in_rec.change_reason_code   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.change_reason_code  :=  l_budget_line_in_rec.change_reason_code ;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.description     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).description is null) THEN
                   l_budget_line_in_rec.description   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.description     :=  l_budget_line_in_rec.description;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute_category     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute_category is null) THEN
                   l_budget_line_in_rec.attribute_category   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute_category     :=  l_budget_line_in_rec.attribute_category;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute1     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute1 is null) THEN
                   l_budget_line_in_rec.attribute1   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute1     :=  l_budget_line_in_rec.attribute1;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute2     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute2 is null) THEN
                   l_budget_line_in_rec.attribute2   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute2     :=  l_budget_line_in_rec.attribute2;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute3     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute3 is null) THEN
                   l_budget_line_in_rec.attribute3   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute3     :=  l_budget_line_in_rec.attribute3;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute4     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute4 is null) THEN
                   l_budget_line_in_rec.attribute4   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute4     :=  l_budget_line_in_rec.attribute4;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute5     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute5 is null) THEN
                   l_budget_line_in_rec.attribute5   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute5     :=  l_budget_line_in_rec.attribute5;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute6     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute6 is null) THEN
                   l_budget_line_in_rec.attribute6   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute6     :=  l_budget_line_in_rec.attribute6;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute7     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute7 is null) THEN
                   l_budget_line_in_rec.attribute7   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute7     :=  l_budget_line_in_rec.attribute7;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute8     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute8 is null) THEN
                   l_budget_line_in_rec.attribute8   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute8     :=  l_budget_line_in_rec.attribute8;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute9     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute9 is null) THEN
                   l_budget_line_in_rec.attribute9   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute9     :=  l_budget_line_in_rec.attribute9;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute10     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute10 is null) THEN
                   l_budget_line_in_rec.attribute10   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute10     :=  l_budget_line_in_rec.attribute10;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute11     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute11 is null) THEN
                   l_budget_line_in_rec.attribute11   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute11     :=  l_budget_line_in_rec.attribute11;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute12     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute12 is null) THEN
                   l_budget_line_in_rec.attribute12   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute12     :=  l_budget_line_in_rec.attribute12;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute13     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute13 is null) THEN
                   l_budget_line_in_rec.attribute13   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute13     :=  l_budget_line_in_rec.attribute13;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute14     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute14 is null) THEN
                   l_budget_line_in_rec.attribute14   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute14     :=  l_budget_line_in_rec.attribute14;
             END IF;

             IF p_budget_lines_in(l_budget_line_index).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_budget_line_in_rec.attribute15     :=  NULL;
             ELSIF(p_budget_lines_in(l_budget_line_index).attribute15 is null) THEN
                   l_budget_line_in_rec.attribute15   :=  FND_API.G_MISS_CHAR;
             ELSE
                   l_budget_line_in_rec.attribute15     :=  l_budget_line_in_rec.attribute15;
             END IF;

          PA_BUDGET_PVT.UPDATE_BUDGET_LINE_SQL
          ( p_return_status        => l_return_status
          --,p_budget_amount_code         => l_budget_amount_code
          ,p_budget_entry_method_code     => l_budget_entry_method_code
          ,p_resource_assignment_id       => l_resource_assignment_id
          ,p_start_date                   => l_budget_start_date
          ,p_time_phased_type_code        => lx_time_phased_type_code
          ,p_description                  => l_budget_line_in_rec.description
          ,p_quantity                     => l_budget_line_in_rec.quantity
          ,p_raw_cost                     => l_budget_line_in_rec.raw_cost
          ,p_burdened_cost                => l_budget_line_in_rec.burdened_cost
          ,p_revenue                      => l_budget_line_in_rec.revenue
          ,p_change_reason_code           => l_budget_line_in_rec.change_reason_code
          ,p_attribute_category           => l_budget_line_in_rec.attribute_category
          ,p_attribute1                   => l_budget_line_in_rec.attribute1
          ,p_attribute2                   => l_budget_line_in_rec.attribute2
          ,p_attribute3                   => l_budget_line_in_rec.attribute3
          ,p_attribute4                   => l_budget_line_in_rec.attribute4
          ,p_attribute5                   => l_budget_line_in_rec.attribute5
          ,p_attribute6                   => l_budget_line_in_rec.attribute6
          ,p_attribute7                   => l_budget_line_in_rec.attribute7
          ,p_attribute8                   => l_budget_line_in_rec.attribute8
          ,p_attribute9                   => l_budget_line_in_rec.attribute9
          ,p_attribute10                  => l_budget_line_in_rec.attribute10
          ,p_attribute11                  => l_budget_line_in_rec.attribute11
          ,p_attribute12                  => l_budget_line_in_rec.attribute12
          ,p_attribute13                  => l_budget_line_in_rec.attribute13
          ,p_attribute14                  => l_budget_line_in_rec.attribute14
          ,p_attribute15                  => l_budget_line_in_rec.attribute15
          );

          IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
               p_budget_lines_out(l_budget_line_index).return_status := l_return_status;
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR   THEN
               p_budget_lines_out(l_budget_line_index).return_status := l_return_status;
               p_multiple_task_msg   := 'F';

          END IF;  -- l_return_status =  FND_API.G_RET_STS_UNE

     END IF; -- End for the condition : (l_dummy <> 'X' OR l_dummy IS NULL) OR

ELSE -- l_budget_type_code IS NOT NULL (Inserting lines for the finplan model)
     --Checking it its a new budget line.
    IF (l_dummy <> 'X' OR l_dummy IS NULL) OR (l_new_resource_assignment) OR (lx_resource_list_id <> l_resource_list_id) THEN
         --This is a new line case.
          --Get the uncategorized resource list info.
          pa_fin_plan_utils.Get_Uncat_Resource_List_Info
          (x_resource_list_id           => l_uncategorized_res_list_id,
           x_resource_list_member_id    => l_uncategorized_rlmid,
           x_track_as_labor_flag        => l_unc_track_as_labor_flag,
           x_unit_of_measure            => l_unc_unit_of_measure,
           x_return_status              => p_return_status,
           x_msg_count                  => p_msg_count,
           x_msg_data                   => p_msg_data);

          i := l_budget_line_index;

                IF l_budget_lines_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
               l_budget_lines_in(i).period_name := NULL;
                END IF;

                 --Lines should be processed only if atleast one of the amounts exist
                 -- Commenting out the below check for Bug#8423481. In SelfService, we do not have this check
                 /* IF (nvl(l_budget_lines_in(i).quantity,0)<>0 OR
               nvl(l_budget_lines_in(i).raw_cost,0)<>0 OR
               nvl(l_budget_lines_in(i).burdened_cost,0)<>0 OR
               nvl(l_budget_lines_in(i).revenue,0) <>0) THEN */

                -- Get UOM and track as labor flag only if the resource list is not uncategorized
                -- If it is is uncategorized then we can make use of the uom and track as labor
                -- flag obtained earlier
                --Commented out the below code to get the unit of measure and track_as_labor_flag value
                --because these values are used only while passing to add_fin_plan_lines(and further to create_fin_plan_lines )
                --where they are simply populated in pa_fp_rollup_tmp but are not used anywhere.
          /*      IF (lx_resource_list_id <> l_uncategorized_res_list_id) THEN  -- bug 3453650

                      SELECT pr.unit_of_measure
                         ,prlm.track_as_labor_flag
                      INTO   l_unit_of_measure
                         ,l_track_as_labor_flag
                      FROM   pa_resources pr
                         ,pa_resource_lists prl
                         ,pa_resource_list_members prlm
                      WHERE  prl.resource_list_id = lx_resource_list_id  -- bug 3453650
                      AND    pr.resource_id = prlm.resource_id
                      AND    prl.resource_list_id = prlm.resource_list_id
                      AND    prlm.resource_list_member_id = l_budget_lines_in(i).resource_list_member_id;

                  END IF;*/

                       -- dbms_output.put_line('copying from budget to rollup finplan');
                       -- Convert flex field attributes to NULL if they have Miss Char as value

                       l_finplan_lines_tab(j).system_reference1           :=  l_budget_lines_in(i).pa_task_id;
                       l_finplan_lines_tab(j).system_reference2           :=  l_budget_lines_in(i).resource_list_member_id;
                       l_finplan_lines_tab(j).start_date                  :=  l_budget_lines_in(i).budget_start_date;
                       l_finplan_lines_tab(j).end_date                    :=  l_budget_lines_in(i).budget_end_date;
                       l_finplan_lines_tab(j).period_name                 :=  l_budget_lines_in(i).period_name;
                       l_finplan_lines_tab(j).system_reference4           :=  l_unit_of_measure     ;
                       l_finplan_lines_tab(j).system_reference5           :=  l_track_as_labor_flag  ;
                       l_finplan_lines_tab(j).txn_currency_code           :=  l_budget_lines_in(i).txn_currency_code;
                       l_finplan_lines_tab(j).projfunc_raw_cost           :=  NULL;
                       l_finplan_lines_tab(j).projfunc_burdened_cost      :=  NULL;
                       l_finplan_lines_tab(j).projfunc_revenue            :=  NULL;
                       l_finplan_lines_tab(j).project_raw_cost            :=  NULL ;
                       l_finplan_lines_tab(j).project_burdened_cost       :=  NULL;
                       l_finplan_lines_tab(j).project_revenue             :=  NULL;

                      /*Note carefully that while making the comparision below we are reading from p_budget_lines_in and not from
                      *. l_budget_lines_in. l_budget_lines is an o/p parameter of validate_budget_lines call to which is made
                      * above in the code flow. And before calling validate_budget_lines G_MISS_XXX handling is done for the values
                      * present in l_budget_lines. So we cant use l_budget_lines in making the comparision again*/
                       IF p_budget_lines_in(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_raw_cost   :=  NULL;
                       ELSIF(p_budget_lines_in(i).raw_cost is null) THEN
                             l_finplan_lines_tab(j).txn_raw_cost   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_raw_cost   :=  l_budget_lines_in(i).raw_cost;
                       END IF;

                       IF p_budget_lines_in(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_burdened_cost  := NULL;
                       ELSIF(p_budget_lines_in(i).burdened_cost is null) THEN
                             l_finplan_lines_tab(j).txn_burdened_cost   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_burdened_cost  := l_budget_lines_in(i).burdened_cost;
                       END IF;

                       IF p_budget_lines_in(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_revenue  := NULL;
                       ELSIF(p_budget_lines_in(i).revenue is null) THEN
                             l_finplan_lines_tab(j).txn_revenue   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_revenue  := l_budget_lines_in(i).revenue;
                       END IF;

                       IF p_budget_lines_in(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).quantity  := NULL;
                       ELSIF(p_budget_lines_in(i).quantity is null) THEN
                             l_finplan_lines_tab(j).quantity   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).quantity  := l_budget_lines_in(i).quantity;
                       END IF;

                       IF p_budget_lines_in(i).change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).change_reason_code  :=NULL;
                       ELSIF(p_budget_lines_in(i).change_reason_code is null) THEN
                             l_finplan_lines_tab(j).change_reason_code   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).change_reason_code  :=  l_budget_lines_in(i).change_reason_code ;
                       END IF;

                       IF p_budget_lines_in(i).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).description     :=  NULL;
                       ELSIF(p_budget_lines_in(i).description is null) THEN
                             l_finplan_lines_tab(j).description   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).description     :=  l_budget_lines_in(i).description;
                       END IF;

                       IF p_budget_lines_in(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute_category     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute_category is null) THEN
                             l_finplan_lines_tab(j).attribute_category   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute_category     :=  l_budget_lines_in(i).attribute_category;
                       END IF;

                       IF p_budget_lines_in(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute1     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute1 is null) THEN
                             l_finplan_lines_tab(j).attribute1   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute1     :=  l_budget_lines_in(i).attribute1;
                       END IF;

                       IF p_budget_lines_in(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute2     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute2 is null) THEN
                             l_finplan_lines_tab(j).attribute2   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute2     :=  l_budget_lines_in(i).attribute2;
                       END IF;

                       IF p_budget_lines_in(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute3     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute3 is null) THEN
                             l_finplan_lines_tab(j).attribute3   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute3     :=  l_budget_lines_in(i).attribute3;
                       END IF;

                       IF p_budget_lines_in(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute4     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute4 is null) THEN
                             l_finplan_lines_tab(j).attribute4   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute4     :=  l_budget_lines_in(i).attribute4;
                       END IF;

                       IF p_budget_lines_in(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute5     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute5 is null) THEN
                             l_finplan_lines_tab(j).attribute5   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute5     :=  l_budget_lines_in(i).attribute5;
                       END IF;

                       IF p_budget_lines_in(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute6     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute6 is null) THEN
                             l_finplan_lines_tab(j).attribute6   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute6     :=  l_budget_lines_in(i).attribute6;
                       END IF;

                       IF p_budget_lines_in(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute7     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute7 is null) THEN
                             l_finplan_lines_tab(j).attribute7   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute7     :=  l_budget_lines_in(i).attribute7;
                       END IF;

                       IF p_budget_lines_in(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute8     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute8 is null) THEN
                             l_finplan_lines_tab(j).attribute8   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute8     :=  l_budget_lines_in(i).attribute8;
                       END IF;

                       IF p_budget_lines_in(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute9     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute9 is null) THEN
                             l_finplan_lines_tab(j).attribute9   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute9     :=  l_budget_lines_in(i).attribute9;
                       END IF;

                       IF p_budget_lines_in(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute10     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute10 is null) THEN
                             l_finplan_lines_tab(j).attribute10   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute10     :=  l_budget_lines_in(i).attribute10;
                       END IF;

                       IF p_budget_lines_in(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute11     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute11 is null) THEN
                             l_finplan_lines_tab(j).attribute11   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute11     :=  l_budget_lines_in(i).attribute11;
                       END IF;

                       IF p_budget_lines_in(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute12     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute12 is null) THEN
                             l_finplan_lines_tab(j).attribute12   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute12     :=  l_budget_lines_in(i).attribute12;
                       END IF;

                       IF p_budget_lines_in(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute13     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute13 is null) THEN
                             l_finplan_lines_tab(j).attribute13   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute13     :=  l_budget_lines_in(i).attribute13;
                       END IF;

                       IF p_budget_lines_in(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute14     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute14 is null) THEN
                             l_finplan_lines_tab(j).attribute14   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute14     :=  l_budget_lines_in(i).attribute14;
                       END IF;

                       IF p_budget_lines_in(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute15     :=  NULL;
                       ELSIF(p_budget_lines_in(i).attribute15 is null) THEN
                             l_finplan_lines_tab(j).attribute15   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute15     :=  l_budget_lines_in(i).attribute15;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_cost_rate_type =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_cost_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE     :=  l_budget_lines_in(i).projfunc_cost_rate_type;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_cost_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE :=l_budget_lines_in(i).projfunc_cost_rate_date_type;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_cost_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     :=  l_budget_lines_in(i).projfunc_cost_rate_date            ;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_cost_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE :=  l_budget_lines_in(i).projfunc_cost_exchange_rate        ;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_rev_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      :=  l_budget_lines_in(i).projfunc_rev_rate_type             ;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_rev_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE :=  l_budget_lines_in(i).projfunc_rev_rate_date_type ;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_rev_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      :=  l_budget_lines_in(i).projfunc_rev_rate_date;
                       END IF;

                       IF p_budget_lines_in(i).projfunc_rev_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                       ELSIF(p_budget_lines_in(i).projfunc_rev_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  :=  l_budget_lines_in(i).projfunc_rev_exchange_rate ;
                       END IF;

                       IF  p_budget_lines_in(i).project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      := NULL;
                       ELSIF(p_budget_lines_in(i).project_cost_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      :=  l_budget_lines_in(i).project_cost_rate_type;
                       END IF;

                       IF p_budget_lines_in(i).project_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(i).project_cost_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE :=  l_budget_lines_in(i).project_cost_rate_date_type ;
                       END IF;

                       IF p_budget_lines_in(i).project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      := NULL;
                       ELSIF(p_budget_lines_in(i).project_cost_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      :=  l_budget_lines_in(i).project_cost_rate_date;
                       END IF;

                       IF p_budget_lines_in(i).project_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  := NULL;
                       ELSIF(p_budget_lines_in(i).project_cost_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  :=  l_budget_lines_in(i).project_cost_exchange_rate ;
                       END IF;

                       IF  p_budget_lines_in(i).project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       := NULL;
                       ELSIF(p_budget_lines_in(i).project_rev_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                              l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       :=  l_budget_lines_in(i).project_rev_rate_type  ;
                       END IF;

                       IF p_budget_lines_in(i).project_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                       ELSIF(p_budget_lines_in(i).project_rev_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  :=  l_budget_lines_in(i).project_rev_rate_date_type;
                       END IF;

                       IF p_budget_lines_in(i).project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       := NULL;
                       ELSIF(p_budget_lines_in(i).project_rev_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       :=  l_budget_lines_in(i).project_rev_rate_date ;
                       END IF;

                       IF p_budget_lines_in(i).project_rev_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   := NULL;
                       ELSIF(p_budget_lines_in(i).project_rev_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   :=  l_budget_lines_in(i).project_rev_exchange_rate          ;
                       END IF;

                       IF p_budget_lines_in(i).pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).pm_product_code             := NULL;
                       ELSIF(p_budget_lines_in(i).pm_product_code is null) THEN
                             l_finplan_lines_tab(j).pm_product_code   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).pm_product_code             :=  l_budget_lines_in(i).pm_product_code      ;
                       END IF;

                       IF p_budget_lines_in(i).pm_budget_line_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).pm_budget_line_reference    := NULL;
                       ELSIF(p_budget_lines_in(i).pm_budget_line_reference is null) THEN
                             l_finplan_lines_tab(j).pm_budget_line_reference   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).pm_budget_line_reference    :=  l_budget_lines_in(i).pm_budget_line_reference        ;
                       END IF;

                       l_finplan_lines_tab(j).quantity_source             :=  'I';
                       l_finplan_lines_tab(j).raw_cost_source             :=  'I';
                       l_finplan_lines_tab(j).burdened_cost_source        :=  'I';
                       l_finplan_lines_tab(j).revenue_source              :=  'I';
                       l_finplan_lines_tab(j).resource_assignment_id      :=  -1 ;

                       --increment the index for fin plan lines table
                       j := j+1;
             --          END IF; --IF (nvl(l_budget_lines_in(i).quantity,0)<>0 OR
    ELSE
          --its an already existing budget line
          i := l_budget_line_index;

                       l_finplan_lines_tab(j).system_reference1           :=  l_budget_line_in_rec.pa_task_id;
                       l_finplan_lines_tab(j).system_reference2           :=  l_budget_line_in_rec.resource_list_member_id;
                       l_finplan_lines_tab(j).start_date                  :=  l_budget_line_in_rec.budget_start_date;
                       l_finplan_lines_tab(j).end_date                    :=  l_budget_line_in_rec.budget_end_date;
                       l_finplan_lines_tab(j).period_name                 :=  l_budget_line_in_rec.period_name;
                       l_finplan_lines_tab(j).system_reference4           :=  l_unit_of_measure     ;
                       l_finplan_lines_tab(j).system_reference5           :=  l_track_as_labor_flag  ;
                       l_finplan_lines_tab(j).txn_currency_code           :=  l_budget_line_in_rec.txn_currency_code;
                       l_finplan_lines_tab(j).projfunc_raw_cost           :=  NULL;
                       l_finplan_lines_tab(j).projfunc_burdened_cost      :=  NULL;
                       l_finplan_lines_tab(j).projfunc_revenue            :=  NULL;
                       l_finplan_lines_tab(j).project_raw_cost            :=  NULL ;
                       l_finplan_lines_tab(j).project_burdened_cost       :=  NULL;
                       l_finplan_lines_tab(j).project_revenue             :=  NULL;

                      /*Note carefully that while making the comparision below we are reading from p_budget_lines_in and not from
                      *. l_budget_lines_in. l_budget_lines is an o/p parameter of validate_budget_lines call to which is made
                      * above in the code flow. And before calling validate_budget_lines G_MISS_XXX handling is done for the values
                      * present in l_budget_lines. So we cant use l_budget_lines in making the comparision again*/
                       IF p_budget_lines_in(l_budget_line_index).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_raw_cost   :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).raw_cost is null) THEN
                             l_finplan_lines_tab(j).txn_raw_cost   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_raw_cost   :=  l_budget_line_in_rec.raw_cost;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_burdened_cost  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).burdened_cost is null) THEN
                             l_finplan_lines_tab(j).txn_burdened_cost   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_burdened_cost  := l_budget_line_in_rec.burdened_cost;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).txn_revenue  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).revenue is null) THEN
                             l_finplan_lines_tab(j).txn_revenue   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).txn_revenue  := l_budget_line_in_rec.revenue;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).quantity  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).quantity is null) THEN
                             l_finplan_lines_tab(j).quantity   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).quantity  := l_budget_line_in_rec.quantity;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).change_reason_code  :=NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).change_reason_code is null) THEN
                             l_finplan_lines_tab(j).change_reason_code   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).change_reason_code  :=  l_budget_line_in_rec.change_reason_code ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).description     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).description is null) THEN
                             l_finplan_lines_tab(j).description   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).description     :=  l_budget_line_in_rec.description;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute_category     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute_category is null) THEN
                             l_finplan_lines_tab(j).attribute_category   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute_category     :=  l_budget_line_in_rec.attribute_category;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute1     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute1 is null) THEN
                             l_finplan_lines_tab(j).attribute1   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute1     :=  l_budget_line_in_rec.attribute1;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute2     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute2 is null) THEN
                             l_finplan_lines_tab(j).attribute2   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute2     :=  l_budget_line_in_rec.attribute2;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute3     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute3 is null) THEN
                             l_finplan_lines_tab(j).attribute3   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute3     :=  l_budget_line_in_rec.attribute3;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute4     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute4 is null) THEN
                             l_finplan_lines_tab(j).attribute4   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute4     :=  l_budget_line_in_rec.attribute4;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute5     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute5 is null) THEN
                             l_finplan_lines_tab(j).attribute5   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute5     :=  l_budget_line_in_rec.attribute5;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute6     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute6 is null) THEN
                             l_finplan_lines_tab(j).attribute6   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute6     :=  l_budget_line_in_rec.attribute6;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute7     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute7 is null) THEN
                             l_finplan_lines_tab(j).attribute7   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute7     :=  l_budget_line_in_rec.attribute7;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute8     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute8 is null) THEN
                             l_finplan_lines_tab(j).attribute8   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute8     :=  l_budget_line_in_rec.attribute8;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute9     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute9 is null) THEN
                             l_finplan_lines_tab(j).attribute9   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute9     :=  l_budget_line_in_rec.attribute9;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute10     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute10 is null) THEN
                             l_finplan_lines_tab(j).attribute10   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute10     :=  l_budget_line_in_rec.attribute10;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute11     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute11 is null) THEN
                             l_finplan_lines_tab(j).attribute11   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute11     :=  l_budget_line_in_rec.attribute11;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute12     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute12 is null) THEN
                             l_finplan_lines_tab(j).attribute12   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute12     :=  l_budget_line_in_rec.attribute12;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute13     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute13 is null) THEN
                             l_finplan_lines_tab(j).attribute13   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute13     :=  l_budget_line_in_rec.attribute13;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute14     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute14 is null) THEN
                             l_finplan_lines_tab(j).attribute14   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute14     :=  l_budget_line_in_rec.attribute14;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).attribute15     :=  NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).attribute15 is null) THEN
                             l_finplan_lines_tab(j).attribute15   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).attribute15     :=  l_budget_line_in_rec.attribute15;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_type =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                            l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_TYPE     :=  l_budget_line_in_rec.projfunc_cost_rate_type;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE_TYPE :=l_budget_line_in_rec.projfunc_cost_rate_date_type;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_cost_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_RATE_DATE     :=  l_budget_line_in_rec.projfunc_cost_rate_date            ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_cost_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_COST_EXCHANGE_RATE :=  l_budget_line_in_rec.projfunc_cost_exchange_rate        ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                              l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_TYPE      :=  l_budget_line_in_rec.projfunc_rev_rate_type             ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE_TYPE :=  l_budget_line_in_rec.projfunc_rev_rate_date_type ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_rev_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_RATE_DATE      :=  l_budget_line_in_rec.projfunc_rev_rate_date;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).projfunc_rev_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).projfunc_rev_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJFUNC_REV_EXCHANGE_RATE  :=  l_budget_line_in_rec.projfunc_rev_exchange_rate ;
                       END IF;

                       IF  p_budget_lines_in(l_budget_line_index).project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_cost_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_TYPE      :=  l_budget_line_in_rec.project_cost_rate_type;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_cost_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_cost_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE_TYPE :=  l_budget_line_in_rec.project_cost_rate_date_type ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_cost_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_RATE_DATE      :=  l_budget_line_in_rec.project_cost_rate_date;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_cost_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_COST_EXCHANGE_RATE  :=  l_budget_line_in_rec.project_cost_exchange_rate ;
                       END IF;

                       IF  p_budget_lines_in(l_budget_line_index).project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_rev_rate_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                              l_finplan_lines_tab(j).PROJECT_REV_RATE_TYPE       :=  l_budget_line_in_rec.project_rev_rate_type  ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_rev_rate_date_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_rev_rate_date_type is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE_TYPE  :=  l_budget_line_in_rec.project_rev_rate_date_type;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_rev_rate_date is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE   :=  FND_API.G_MISS_DATE;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_RATE_DATE       :=  l_budget_line_in_rec.project_rev_rate_date ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).project_rev_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).project_rev_exchange_rate is null) THEN
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   :=  FND_API.G_MISS_NUM;
                       ELSE
                             l_finplan_lines_tab(j).PROJECT_REV_EXCHANGE_RATE   :=  l_budget_line_in_rec.project_rev_exchange_rate;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
                             l_finplan_lines_tab(j).pm_product_code             := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).pm_product_code is null) THEN
                             l_finplan_lines_tab(j).pm_product_code   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).pm_product_code             :=  l_budget_line_in_rec.pm_product_code ;
                       END IF;

                       IF p_budget_lines_in(l_budget_line_index).pm_budget_line_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                             l_finplan_lines_tab(j).pm_budget_line_reference    := NULL;
                       ELSIF(p_budget_lines_in(l_budget_line_index).pm_budget_line_reference is null) THEN
                             l_finplan_lines_tab(j).pm_budget_line_reference   :=  FND_API.G_MISS_CHAR;
                       ELSE
                             l_finplan_lines_tab(j).pm_budget_line_reference    :=  l_budget_line_in_rec.pm_budget_line_reference  ;
                       END IF;

                       l_finplan_lines_tab(j).quantity_source             :=  'I';
                       l_finplan_lines_tab(j).raw_cost_source             :=  'I';
                       l_finplan_lines_tab(j).burdened_cost_source        :=  'I';
                       l_finplan_lines_tab(j).revenue_source              :=  'I';
                       l_finplan_lines_tab(j).resource_assignment_id      :=  l_resource_assignment_id ;
                       --increment the index for fin plan lines table
                       j := j+1;
    END IF;
                 -- Actual insertion will take place outside the loop as
                 -- as the call to CREATE_FINPLAN_LINES expects a table
                 -- of budget line records.
     --Major changes for the bug 3453650 for the finplan model.


END IF; -- l_budget_type_code IS NOT NULL

     l_budget_line_index := p_budget_lines_in.next(l_budget_line_index);

END LOOP budget_line;

IF l_budget_type_code IS NULL THEN

     -- Bug : 3453650: Calling the create finplan lines api to create the
     -- budget lines for the finplan model and passing the l_finplan_lines_tab
     -- table which was built earlier in the api

     IF ( nvl(l_finplan_lines_tab.last,0) > 0 ) THEN

          -- dbms_output.put_line ('Calling add_finplan_lines');

               PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES
                   ( p_calling_context         => PA_FP_CONSTANTS_PKG.G_AMG_API /* Bug# 2674353 */
                    ,p_fin_plan_version_id     => l_budget_version_id
                    ,p_finplan_lines_tab        => l_finplan_lines_tab
                    ,x_return_status           => l_return_status
                    ,x_msg_count               => l_msg_count
                    ,x_msg_data                => l_msg_data );

          -- dbms_output.put_line ('after Calling add_finplan_lines ' || l_return_status || ' p_multiple_task_msg ' || p_multiple_task_msg);

               IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                    pa_debug.g_err_stage:= 'Error Calling ADD_FINPLAN_LINES';
                    IF L_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('UPDATE_BUDGET: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
     END IF;


        -- Unlock the version now that the budget version is updated.
        l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                     (p_budget_version_id => l_budget_version_id);

      --Try to lock the version before updating the version. This is required so that nobody else can access it.
        pa_fin_plan_pvt.lock_unlock_version
                    (p_budget_version_id       => l_budget_version_id,
                     p_record_version_number   => l_record_version_number,
                     p_action                  => 'U',
                     p_user_id                 => l_user_id,
                     p_person_id               => lx_locked_by_person_id,
                     x_return_status           => x_return_status,
                     x_msg_count               => l_msg_count,
                     x_msg_data                => l_msg_data) ;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Error in lock unlock version - Cannot lock the version';
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,5);
             END IF;

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

END IF; -- END OF l_budget_type_code is null

IF p_multiple_task_msg = 'F' THEN
     RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
END IF;

    --summarizing the totals in the table pa_budget_versions
/*Added the below if condition for the bug 3453650*/
IF l_budget_type_code IS NOT NULL THEN

-- check for overlapping dates
    pa_budget_lines_v_pkg.check_overlapping_dates( x_budget_version_id  => l_budget_version_id      --IN
                              ,x_resource_name  => l_resource_name      --OUT
                              ,x_err_code       => l_err_code       );

-- dbms_output.put_line ('after calling pa_budget_lines_v_pkg.check_overlapping_dates ' || l_err_code );

      IF l_err_code > 0 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.SET_NAME('PA','PA_CHECK_DATES_FAILED');
                  FND_MESSAGE.SET_TOKEN('Rname',l_resource_name);

                  FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      ELSIF l_err_code < 0 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.add_exc_msg
                      (  p_pkg_name       => 'PA_BUDGET_LINES_V_PKG'
                      ,  p_procedure_name => 'CHECK_OVERLAPPING_DATES'
                      ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


        PA_BUDGET_UTILS.summerize_project_totals( x_budget_version_id => l_budget_version_id
                                    , x_err_code      => l_err_code
                            , x_err_stage     => l_err_stage
                            , x_err_stack     => l_err_stack        );

        IF l_err_code > 0 THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               IF NOT pa_project_pvt.check_valid_message(l_err_stage) THEN
                    pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'BUDG'
                    ,p_attribute1       => l_amg_segment1
                    ,p_attribute2       => l_amg_task_number
                    ,p_attribute3       => l_budget_type_code
                    ,p_attribute4       => ''
                    ,p_attribute5       => to_char(l_budget_start_date));
               ELSE
                    pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => l_err_stage
                    ,p_msg_attribute    => 'CHANGE'
                    ,p_resize_flag      => 'N'
                    ,p_msg_context      => 'BUDG'
                    ,p_attribute1       => l_amg_segment1
                    ,p_attribute2       => l_amg_task_number
                    ,p_attribute3       => l_budget_type_code
                    ,p_attribute4       => ''
                    ,p_attribute5       => to_char(l_budget_start_date));
               END IF;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     ELSIF l_err_code < 0 THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.add_exc_msg
               (  p_pkg_name       => 'PA_BUDGET_UTILS'
               ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
               ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF; -- l_err_code > 0
 END IF; -- l_budget_type_code IS NOT NULL

END IF;  --if there are budget lines

IF FND_API.TO_BOOLEAN( p_commit ) THEN
     COMMIT;
END IF;


EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          -- dbms_output.put_line('Invalid_Arg_Exc MSG count in the stack ' || FND_MSG_PUB.count_msg);
        ROLLBACK TO update_budget_pub;

        IF p_return_status IS NULL OR
           p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
              p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        -- dbms_output.put_line('Invalid_Arg_Exc MSG count in the stack ' || l_msg_count);

        IF l_msg_count = 1 AND p_msg_data IS NULL THEN
               PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);

               p_msg_data  := l_data;
               p_msg_count := l_msg_count;
        ELSE
               p_msg_count := l_msg_count;
        END IF;
        --Changes for bug 3182963
        IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
        END IF;
          -- dbms_output.put_line('Invalid_Arg_Exc MSG count in the stack ' || l_msg_count);

        RETURN;

    WHEN FND_API.G_EXC_ERROR
    THEN


            ROLLBACK TO update_budget_pub;

            p_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN


            ROLLBACK TO update_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN ROW_ALREADY_LOCKED
    THEN
        ROLLBACK TO update_budget_pub;

        p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
         FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
         FND_MESSAGE.SET_TOKEN('TASK',    l_amg_task_number);
         FND_MESSAGE.SET_TOKEN('BUDGET_TYPE', l_budget_type_code);
         FND_MESSAGE.SET_TOKEN('SOURCE_NAME', '');
   --    FND_MESSAGE.SET_TOKEN('START_DATE', to_char(l_budget_start_date));
         FND_MESSAGE.SET_TOKEN('START_DATE',
                                fnd_date.date_to_chardate(l_budget_start_date));
         FND_MESSAGE.SET_TOKEN('ENTITY', 'G_BUDGET_CODE');
         FND_MSG_PUB.ADD;
        END IF;

        FND_MSG_PUB.Count_And_Get
                (   p_count     =>  p_msg_count ,
                    p_data      =>  p_msg_data  );

    WHEN OTHERS
    THEN


            ROLLBACK TO update_budget_pub;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.add_exc_msg
                (  p_pkg_name       => G_PKG_NAME
                ,  p_procedure_name => l_api_name );

            END IF;

            FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );


END update_budget;


----------------------------------------------------------------------------------------
--Name:               execute_update_budget
--Type:               Procedure
--Description:        This procedure can be used to update a working (draft) budget
--                    using global PL/SQL tables.
--
--Called subprograms:
--
--
--
--History:
--    14-OCT-1996        L. de Werker    Created
--    28-NOV-1996    L. de Werker    Add 16 parameters for descriptive flexfields
--

PROCEDURE execute_update_budget
( p_api_version_number          IN  NUMBER
 ,p_commit              IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   --Added for the bug 3453650
 ,p_resource_list_id              IN   pa_budget_versions.resource_list_id%TYPE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_set_current_working_flag      IN   pa_budget_versions.current_working_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_name           IN   pa_budget_versions.version_name%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_finplan_type_id               IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN   pa_budget_lines.projfunc_cost_exchange_rate%TYPE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  pa_budget_lines.project_cost_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  pa_budget_lines.project_rev_exchange_rate%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 )

IS

   l_api_name               CONSTANT    VARCHAR2(30)        := 'execute_update_budget';

   i                            NUMBER;
   l_return_status                  VARCHAR2(1);
   l_err_stage                      VARCHAR2(120);


BEGIN

--  Standard begin of API savepoint

    SAVEPOINT execute_update_budget_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;


--  product_code is mandatory

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
    END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    l_pm_product_code :='Z';
    /*added for bug no :2413400*/
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
    p_return_status             := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
    END IF;


/*   -- dbms_output.put_line('Before update_budget'); */

          update_budget( p_api_version_number   => p_api_version_number
                    ,p_commit       => FND_API.G_FALSE
                    ,p_init_msg_list    => FND_API.G_FALSE
                ,p_msg_count        => p_msg_count
                ,p_msg_data     => p_msg_data
                ,p_return_status    => l_return_status
                ,p_pm_product_code  => p_pm_product_code
                ,p_pa_project_id    => p_pa_project_id
                ,p_pm_project_reference => p_pm_project_reference
                ,p_budget_type_code => p_budget_type_code
                ,p_change_reason_code   => p_change_reason_code
                ,p_description      => p_description
                ,p_budget_lines_in  => G_budget_lines_in_tbl
                ,p_budget_lines_out => G_budget_lines_out_tbl
                -- Added for bug 4224464
                --Added the new parameters for the bug 3453650
                ,p_resource_list_id              =>   p_resource_list_id
                ,p_set_current_working_flag      =>   p_set_current_working_flag
                ,p_budget_version_number         =>   p_budget_version_number
                ,p_budget_version_name           =>   p_budget_version_name
                ,p_version_type                  =>   p_version_type  -- 3453650
                ,p_finplan_type_id               =>   p_finplan_type_id
                ,p_plan_in_multi_curr_flag       =>   p_plan_in_multi_curr_flag
                ,p_time_phased_code              =>   p_time_phased_code
                ,p_projfunc_cost_rate_type       =>   p_projfunc_cost_rate_type
                ,p_projfunc_cost_rate_date_typ   =>   p_projfunc_cost_rate_date_typ
                ,p_projfunc_cost_rate_date       =>   p_projfunc_cost_rate_date
                ,p_projfunc_cost_exchange_rate   =>   p_projfunc_cost_exchange_rate
                ,p_projfunc_rev_rate_type        =>   p_projfunc_rev_rate_type
                ,p_projfunc_rev_rate_date_typ    =>   p_projfunc_rev_rate_date_typ
                ,p_projfunc_rev_rate_date        =>   p_projfunc_rev_rate_date
                ,p_projfunc_rev_exchange_rate    =>   p_projfunc_rev_exchange_rate
                ,p_project_cost_rate_type        =>   p_project_cost_rate_type
                ,p_project_cost_rate_date_typ    =>   p_project_cost_rate_date_typ
                ,p_project_cost_rate_date        =>   p_project_cost_rate_date
                ,p_project_cost_exchange_rate    =>   p_project_cost_exchange_rate
                ,p_project_rev_rate_type         =>   p_project_rev_rate_type
                ,p_project_rev_rate_date_typ     =>   p_project_rev_rate_date_typ
                ,p_project_rev_rate_date         =>   p_project_rev_rate_date
                ,p_project_rev_exchange_rate     =>   p_project_rev_exchange_rate );

/*   -- dbms_output.put_line('After update_budget'); */

/*   -- dbms_output.put_line('Return status update_budget: '||l_return_status); */

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT;
        END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN

/*   -- dbms_output.put_line('handling an G_EXC_ERROR exception in execute_update_budget'); */

    ROLLBACK TO execute_update_budget_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

/*   -- dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    ROLLBACK TO execute_update_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );

    WHEN OTHERS THEN

/*   -- dbms_output.put_line('handling an OTHERS exception in execute_update_budget'); */

    ROLLBACK TO execute_update_budget_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
            (  p_pkg_name       => G_PKG_NAME
            ,  p_procedure_name => l_api_name );

    END IF;

    FND_MSG_PUB.Count_And_Get
    (   p_count     =>  p_msg_count ,
        p_data      =>  p_msg_data  );

END execute_update_budget;


----------------------------------------------------------------------------------------
--Name:               update_budget_line
--Type:               Procedure
--Description:        This procedure can be used to update a budgetline of an
--                    existing WORKING budget.
--
--Called subprograms: pa_budget_pvt.update_budget_line_sql
--
--
--
--
--History:
--    10-OCT-1996        L. de Werker    Created
--    19-NOV-1996    L. de Werker    Changed to let it use update_budget_line_sql
--    28-NOV-1996    L. de Werker    Add 16 parameters for descriptive flexfields
--    11-MAY-2005    Ritesh Shukla   Bug 4224464: FP.M Changes for update_budget_line

PROCEDURE update_budget_line
( p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2   := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code               IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference             IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias                IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date             IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date               IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                      IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost                 IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                       IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                      IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Parameters added for FP.M
 ,p_fin_plan_type_id              IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_number                IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_currency_code                 IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_cost_exchange_rate   IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_projfunc_rev_rate_type        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_exchange_rate    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_cost_rate_type        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_exchange_rate    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_rev_rate_type         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN  DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_exchange_rate     IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
)

IS


     --needed to get the resource assignment for this budget_version / task / member combination
     CURSOR l_resource_assignment_csr
        (p_budget_version_id  NUMBER
        ,p_task_id            NUMBER
        ,p_member_id          NUMBER  )
     IS
     SELECT resource_assignment_id
     FROM   pa_resource_assignments
     WHERE  budget_version_id = p_budget_version_id
     AND    task_id = p_task_id
     AND    resource_list_member_id = p_member_id;

     --needed to check whether budget line already exists
     CURSOR l_budget_line_csr
        (p_resource_assigment_id NUMBER
        ,p_budget_start_date     DATE
        ,p_currency_code         VARCHAR2)
     IS
     SELECT rowidtochar(rowid)
           ,budget_line_id
     FROM   pa_budget_lines
     WHERE  resource_assignment_id = p_resource_assigment_id
     AND    trunc(start_date) = nvl(trunc(p_budget_start_date),trunc(start_date))
     AND    txn_currency_code = nvl(p_currency_code,txn_currency_code);

     --needed to lock the budget line row
     CURSOR l_lock_budget_line_csr( p_budget_line_rowid VARCHAR2)
     IS
     SELECT 'x'
     FROM   pa_budget_lines
     WHERE  rowid = p_budget_line_rowid
     FOR UPDATE NOWAIT;

     l_api_name          CONSTANT VARCHAR2(30)        := 'update_budget_line';

     l_resource_assignment_id     NUMBER;
     l_budget_line_id             NUMBER;
     l_budget_line_rowid          VARCHAR(20);

     l_err_code                   NUMBER;
     l_err_stage                  VARCHAR2(120);
     l_err_stack                  VARCHAR2(630);

     l_project_id                 NUMBER := p_pa_project_id;
     l_budget_type_code           pa_budget_types.budget_type_code%TYPE := p_budget_type_code;
     l_fin_plan_type_id           NUMBER := p_fin_plan_type_id;
     l_fin_plan_type_name         pa_fin_plan_types_tl.name%TYPE := p_fin_plan_type_name;
     l_version_type               pa_budget_versions.version_type%TYPE := p_version_type;
     l_budget_version_id          NUMBER;
     l_budget_entry_method_code   pa_budget_entry_methods.budget_entry_method_code%TYPE;
     l_resource_list_id           NUMBER;
     l_budget_amount_code         pa_budget_types.budget_amount_code%type;
     l_entry_level_code           pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
     l_time_phased_code           pa_proj_fp_options.cost_time_phased_code%TYPE;
     l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
     l_categorization_code        pa_budget_entry_methods.categorization_code%TYPE;
     l_record_version_number      pa_budget_versions.record_version_number%TYPE;

     l_budget_lines_in            budget_line_in_tbl_type;
     l_budget_lines_out_tbl       budget_line_out_tbl_type;
     l_mfc_cost_type_id_tbl       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
     l_etc_method_code_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
     l_spread_curve_id_tbl        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

     l_finplan_lines_tab          pa_fin_plan_pvt.budget_lines_tab;
     l_version_info_rec           pa_fp_gen_amount_utils.fp_cols;

     --Following parameters are needed for amounts check
     l_amount_set_id              NUMBER;
     lx_raw_cost_flag             VARCHAR2(1) := NULL;
     lx_burdened_cost_flag        VARCHAR2(1) := NULL;
     lx_revenue_flag              VARCHAR2(1) := NULL;
     lx_cost_qty_flag             VARCHAR2(1) := NULL;
     lx_revenue_qty_flag          VARCHAR2(1) := NULL;
     lx_all_qty_flag              VARCHAR2(1) := NULL;
     l_bill_rate_flag             pa_fin_plan_amount_sets.bill_rate_flag%type;
     l_cost_rate_flag             pa_fin_plan_amount_sets.cost_rate_flag%type;
     l_burden_rate_flag           pa_fin_plan_amount_sets.burden_rate_flag%type;
     l_allow_qty_flag             VARCHAR2(1);

     l_msg_count                  NUMBER := 0;
     l_msg_data                   VARCHAR2(2000);
     l_function_allowed           VARCHAR2(1);
     l_module_name                VARCHAR2(80);
     l_data                       VARCHAR2(2000);
     l_msg_index_out              NUMBER;

     l_amg_project_number        pa_projects_all.segment1%TYPE;
     l_amg_task_number            VARCHAR2(50);

     --debug variables
     l_debug_mode                 VARCHAR2(1);
     l_debug_level2      CONSTANT NUMBER := 2;
     l_debug_level3      CONSTANT NUMBER := 3;
     l_debug_level4      CONSTANT NUMBER := 4;
     l_debug_level5      CONSTANT NUMBER := 5;
     --Added for bug 6408139 to pass G_PA_MISS_CHAR
     l_pa_miss_char varchar2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;


BEGIN


     --Standard begin of API savepoint
     SAVEPOINT update_budget_line_pub;

     p_msg_count := 0;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     l_module_name := g_module_name || ':Update_Budget_Line ';

     IF ( l_debug_mode = 'Y' )
     THEN
           pa_debug.set_curr_function( p_function   => l_api_name
                                      ,p_debug_mode => l_debug_mode );
     END IF;

     IF ( l_debug_mode = 'Y' )
     THEN
           pa_debug.g_err_stage:='Entering ' || l_api_name;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     --Initialize the message table if requested.
     IF FND_API.TO_BOOLEAN( p_init_msg_list )
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     --Set API return status to success
     p_return_status     := FND_API.G_RET_STS_SUCCESS;

     --Call PA_BUDGET_PVT.validate_header_info to do the necessary
     --header level validations
     PA_BUDGET_PVT.validate_header_info
          ( p_api_version_number          => p_api_version_number
           ,p_api_name                    => l_api_name
           ,p_init_msg_list               => p_init_msg_list
           ,px_pa_project_id              => l_project_id
           ,p_pm_project_reference        => p_pm_project_reference
           ,p_pm_product_code             => p_pm_product_code
           ,px_budget_type_code           => l_budget_type_code
           ,px_fin_plan_type_id           => l_fin_plan_type_id
           ,px_fin_plan_type_name         => l_fin_plan_type_name
           ,px_version_type               => l_version_type
           ,p_budget_version_number       => p_version_number
           ,p_change_reason_code          => NULL
           ,p_function_name               => 'PA_PM_UPDATE_BUDGET_LINE'
           ,x_budget_entry_method_code    => l_budget_entry_method_code
           ,x_resource_list_id            => l_resource_list_id
           ,x_budget_version_id           => l_budget_version_id
           ,x_fin_plan_level_code         => l_entry_level_code
           ,x_time_phased_code            => l_time_phased_code
           ,x_plan_in_multi_curr_flag     => l_multi_curr_flag
           ,x_budget_amount_code          => l_budget_amount_code
           ,x_categorization_code         => l_categorization_code
           ,x_project_number              => l_amg_project_number
           /* Plan Amount Entry flags introduced by bug 6408139 */
           /*Passing all as G_PA_MISS_CHAR since validations not required*/
           ,px_raw_cost_flag         =>   l_pa_miss_char
           ,px_burdened_cost_flag    =>   l_pa_miss_char
           ,px_revenue_flag          =>   l_pa_miss_char
           ,px_cost_qty_flag         =>   l_pa_miss_char
           ,px_revenue_qty_flag      =>   l_pa_miss_char
           ,px_all_qty_flag          =>   l_pa_miss_char
           ,px_bill_rate_flag        =>   l_pa_miss_char
           ,px_cost_rate_flag        =>   l_pa_miss_char
           ,px_burden_rate_flag      =>   l_pa_miss_char
           /* Plan Amount Entry flags introduced by bug 6408139 */
           ,x_msg_count                   => p_msg_count
           ,x_msg_data                    => p_msg_data
           ,x_return_status               => p_return_status );

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF(l_debug_mode='Y') THEN
                 pa_debug.g_err_stage := 'validate header info API falied';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     --Store the budget line data in budget line table

     IF p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).pa_task_id := NULL;
     ELSE
          l_budget_lines_in(1).pa_task_id := p_pa_task_id;
     END IF;

     IF p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).pm_task_reference := NULL;
     ELSE
          l_budget_lines_in(1).pm_task_reference := p_pm_task_reference;
     END IF;

     IF p_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).resource_alias := NULL;
     ELSE
          l_budget_lines_in(1).resource_alias := p_resource_alias;
     END IF;

     IF p_resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).resource_list_member_id := NULL;
     ELSE
          l_budget_lines_in(1).resource_list_member_id := p_resource_list_member_id;
     END IF;

     IF p_budget_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).budget_start_date := NULL;
     ELSE
          l_budget_lines_in(1).budget_start_date := p_budget_start_date;
     END IF;

     IF p_budget_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).budget_end_date := NULL;
     ELSE
          l_budget_lines_in(1).budget_end_date := p_budget_end_date;
     END IF;

     IF p_period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).period_name := NULL;
     ELSE
          l_budget_lines_in(1).period_name := p_period_name;
     END IF;

     IF p_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).description := NULL;
     ELSE
          l_budget_lines_in(1).description := p_description;
     END IF;

     IF p_raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).raw_cost := NULL;
     ELSE
          l_budget_lines_in(1).raw_cost := p_raw_cost;
     END IF;

     IF p_burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).burdened_cost := NULL;
     ELSE
          l_budget_lines_in(1).burdened_cost := p_burdened_cost;
     END IF;

     IF p_revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).revenue := NULL;
     ELSE
          l_budget_lines_in(1).revenue := p_revenue;
     END IF;

     IF p_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).quantity := NULL;
     ELSE
          l_budget_lines_in(1).quantity := p_quantity;
     END IF;

     IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).pm_product_code := NULL;
     ELSE
          l_budget_lines_in(1).pm_product_code := p_pm_product_code;
     END IF;

     IF p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute_category := NULL;
     ELSE
          l_budget_lines_in(1).attribute_category := p_attribute_category;
     END IF;

     IF p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute1 := NULL;
     ELSE
          l_budget_lines_in(1).attribute1 := p_attribute1;
     END IF;

     IF p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute2 := NULL;
     ELSE
          l_budget_lines_in(1).attribute2 := p_attribute2;
     END IF;

     IF p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute3 := NULL;
     ELSE
          l_budget_lines_in(1).attribute3 := p_attribute3;
     END IF;

     IF p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute4 := NULL;
     ELSE
          l_budget_lines_in(1).attribute4 := p_attribute4;
     END IF;

     IF p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute5 := NULL;
     ELSE
          l_budget_lines_in(1).attribute5 := p_attribute5;
     END IF;

     IF p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute6 := NULL;
     ELSE
          l_budget_lines_in(1).attribute6 := p_attribute6;
     END IF;

     IF p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute7 := NULL;
     ELSE
          l_budget_lines_in(1).attribute7 := p_attribute7;
     END IF;

     IF p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute8 := NULL;
     ELSE
          l_budget_lines_in(1).attribute8 := p_attribute8;
     END IF;

     IF p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute9 := NULL;
     ELSE
          l_budget_lines_in(1).attribute9 := p_attribute9;
     END IF;

     IF p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute10 := NULL;
     ELSE
          l_budget_lines_in(1).attribute10 := p_attribute10;
     END IF;

     IF p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute11 := NULL;
     ELSE
          l_budget_lines_in(1).attribute11 := p_attribute11;
     END IF;

     IF p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute12 := NULL;
     ELSE
          l_budget_lines_in(1).attribute12 := p_attribute12;
     END IF;

     IF p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute13 := NULL;
     ELSE
          l_budget_lines_in(1).attribute13 := p_attribute13;
     END IF;

     IF p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute14 := NULL;
     ELSE
          l_budget_lines_in(1).attribute14 := p_attribute14;
     END IF;

     IF p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).attribute15 := NULL;
     ELSE
          l_budget_lines_in(1).attribute15 := p_attribute15;
     END IF;

     IF p_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).txn_currency_code := NULL;
     ELSE
          l_budget_lines_in(1).txn_currency_code := p_currency_code;
     END IF;

     IF p_projfunc_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).projfunc_cost_rate_type := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_cost_rate_type := p_projfunc_cost_rate_type;
     END IF;

     IF p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).projfunc_cost_rate_date_type := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_cost_rate_date_type := p_projfunc_cost_rate_date_typ;
     END IF;

     IF p_projfunc_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).projfunc_cost_rate_date := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_cost_rate_date := p_projfunc_cost_rate_date;
     END IF;

     IF p_projfunc_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).projfunc_cost_exchange_rate := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_cost_exchange_rate := p_projfunc_cost_exchange_rate;
     END IF;

     IF p_projfunc_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).projfunc_rev_rate_type := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_rev_rate_type := p_projfunc_rev_rate_type;
     END IF;

     IF p_projfunc_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).projfunc_rev_rate_date_type := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_rev_rate_date_type := p_projfunc_rev_rate_date_typ;
     END IF;

     IF p_projfunc_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).projfunc_rev_rate_date := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_rev_rate_date := p_projfunc_rev_rate_date;
     END IF;

     IF p_projfunc_rev_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).projfunc_rev_exchange_rate := NULL;
     ELSE
          l_budget_lines_in(1).projfunc_rev_exchange_rate := p_projfunc_rev_exchange_rate;
     END IF;

     IF p_project_cost_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).project_cost_rate_type := NULL;
     ELSE
          l_budget_lines_in(1).project_cost_rate_type := p_project_cost_rate_type;
     END IF;

     IF p_project_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).project_cost_rate_date_type := NULL;
     ELSE
          l_budget_lines_in(1).project_cost_rate_date_type := p_project_cost_rate_date_typ;
     END IF;

     IF p_project_cost_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).project_cost_rate_date := NULL;
     ELSE
          l_budget_lines_in(1).project_cost_rate_date := p_project_cost_rate_date;
     END IF;

     IF p_project_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).project_cost_exchange_rate := NULL;
     ELSE
          l_budget_lines_in(1).project_cost_exchange_rate := p_project_cost_exchange_rate;
     END IF;

     IF p_project_rev_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).project_rev_rate_type := NULL;
     ELSE
          l_budget_lines_in(1).project_rev_rate_type := p_project_rev_rate_type;
     END IF;

     IF p_project_rev_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).project_rev_rate_date_type := NULL;
     ELSE
          l_budget_lines_in(1).project_rev_rate_date_type := p_project_rev_rate_date_typ;
     END IF;

     IF p_project_rev_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_budget_lines_in(1).project_rev_rate_date := NULL;
     ELSE
          l_budget_lines_in(1).project_rev_rate_date := p_project_rev_rate_date;
     END IF;

     IF p_project_rev_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_budget_lines_in(1).project_rev_exchange_rate := NULL;
     ELSE
          l_budget_lines_in(1).project_rev_exchange_rate := p_project_rev_exchange_rate;
     END IF;

     IF p_change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_budget_lines_in(1).change_reason_code := NULL;
     ELSE
          l_budget_lines_in(1).change_reason_code := p_change_reason_code;
     END IF;

     --Send the budget version id to validate_budget_lines API for
     --actuals on FORECAST check
     l_version_info_rec.x_budget_version_id := l_budget_version_id;

     --Get entry method options and validate them against cost, rev and quantity passed
     IF l_budget_type_code IS NULL AND l_fin_plan_type_id IS NOT NULL
     THEN

          l_amount_set_id := PA_FIN_PLAN_UTILS.get_amount_set_id(l_budget_version_id);

          PA_FIN_PLAN_UTILS.get_plan_amount_flags(
                         P_AMOUNT_SET_ID      => l_amount_set_id
                        ,X_RAW_COST_FLAG      => lx_raw_cost_flag
                        ,X_BURDENED_FLAG      => lx_burdened_cost_flag
                        ,X_REVENUE_FLAG       => lx_revenue_flag
                        ,X_COST_QUANTITY_FLAG => lx_cost_qty_flag
                        ,X_REV_QUANTITY_FLAG  => lx_revenue_qty_flag
                        ,X_ALL_QUANTITY_FLAG  => lx_all_qty_flag
                        ,X_BILL_RATE_FLAG     => l_bill_rate_flag
                        ,X_COST_RATE_FLAG     => l_cost_rate_flag
                        ,X_BURDEN_RATE_FLAG   => l_burden_rate_flag
                        ,x_message_count      => p_msg_count
                        ,x_return_status      => p_return_status
                        ,x_message_data       => p_msg_data) ;

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'get_plan_amount_flags API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          --Derive the value of all_qty_flag based on version_type
          IF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
               l_allow_qty_flag := lx_cost_qty_flag;
          ELSIF l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
               l_allow_qty_flag := lx_revenue_qty_flag;
          ELSE
               l_allow_qty_flag :=  lx_all_qty_flag;
          END IF;

     END IF;--IF l_budget_type_code IS NULL AND l_fin_plan_type_id IS NOT NULL


     --Validate the budget line data
     PA_BUDGET_PVT.Validate_Budget_Lines
          ( p_calling_context             => 'BUDGET_LINE_LEVEL_VALIDATION'
           ,p_pa_project_id               => l_project_id
           ,p_budget_type_code            => l_budget_type_code
           ,p_fin_plan_type_id            => l_fin_plan_type_id
           ,p_version_type                => l_version_type
           ,p_resource_list_id            => l_resource_list_id
           ,p_time_phased_code            => l_time_phased_code
           ,p_budget_entry_method_code    => l_budget_entry_method_code
           ,p_entry_level_code            => l_entry_level_code
           ,p_allow_qty_flag              => l_allow_qty_flag
           ,p_allow_raw_cost_flag         => lx_raw_cost_flag
           ,p_allow_burdened_cost_flag    => lx_burdened_cost_flag
           ,p_allow_revenue_flag          => lx_revenue_flag
           ,p_multi_currency_flag         => l_multi_curr_flag
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
           ,px_budget_lines_in            => l_budget_lines_in
           ,x_budget_lines_out            => l_budget_lines_out_tbl
           ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
           ,x_etc_method_code_tbl         => l_etc_method_code_tbl
           ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
           ,x_msg_count                   => p_msg_count
           ,x_msg_data                    => p_msg_data
           ,x_return_status               => p_return_status );

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF(l_debug_mode='Y') THEN
                 pa_debug.g_err_stage := 'validate budget lines API falied';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     --Get Task number for AMG Messages
     l_amg_task_number := PA_INTERFACE_UTILS_PUB.get_task_number_amg
     (p_task_number=> ''
     ,p_task_reference => l_budget_lines_in(1).pm_task_reference
     ,p_task_id => l_budget_lines_in(1).pa_task_id);


     --Check the existence of resource assignment
     OPEN l_resource_assignment_csr( l_budget_version_id
                                    ,l_budget_lines_in(1).pa_task_id
                                    ,l_budget_lines_in(1).resource_list_member_id );

     FETCH l_resource_assignment_csr INTO l_resource_assignment_id;

     IF l_resource_assignment_csr%NOTFOUND
     THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
               pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_NO_RESOURCE_ASSIGNMENT'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'BUDG'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_task_number
                ,p_attribute3       => l_budget_type_code
                ,p_attribute4       => l_budget_lines_in(1).resource_alias
                ,p_attribute5       => to_char(l_budget_lines_in(1).budget_start_date));
          END IF;

          CLOSE l_resource_assignment_csr;
          RAISE FND_API.G_EXC_ERROR;
     END IF; --l_resource_assignment_csr%NOTFOUND

     CLOSE l_resource_assignment_csr;

     --Currency_code value, even if specified, should be ignored in
     --case of old Budgets Model
     IF l_budget_type_code IS NOT NULL
     THEN
          l_budget_lines_in(1).txn_currency_code := NULL;
     END IF;

     --Checking existence of budget line
     OPEN l_budget_line_csr( l_resource_assignment_id
                            ,l_budget_lines_in(1).budget_start_date
                            ,l_budget_lines_in(1).txn_currency_code);

     FETCH l_budget_line_csr INTO l_budget_line_rowid
                                 ,l_budget_line_id;

     IF l_budget_line_csr%NOTFOUND
     THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
               pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_BUDGET_LINE_NOT_FOUND'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'BUDG'
                ,p_attribute1       => l_amg_project_number
                ,p_attribute2       => l_amg_task_number
                ,p_attribute3       => l_budget_type_code
                ,p_attribute4       => l_budget_lines_in(1).resource_alias
                ,p_attribute5       => to_char(l_budget_lines_in(1).budget_start_date));
          END IF;

     CLOSE l_budget_line_csr;
     RAISE FND_API.G_EXC_ERROR;
     END IF;--l_budget_line_csr%NOTFOUND

     CLOSE l_budget_line_csr;


     --Update budget line for old FORMS based Budgets Model
     IF l_budget_type_code IS NOT NULL
     THEN

          --Take a db lock on the table pa_budget_lines
          OPEN l_lock_budget_line_csr( l_budget_line_rowid );
          CLOSE l_lock_budget_line_csr;  --FYI, does not release lock

          --Calling update_budget_line_sql to build a dynamic update statement
          pa_budget_pvt.update_budget_line_sql
               ( p_return_status            => p_return_status
                ,p_budget_entry_method_code => l_budget_entry_method_code
                ,p_resource_assignment_id   => l_resource_assignment_id
                ,p_start_date               => l_budget_lines_in(1).budget_start_date
                ,p_time_phased_type_code    => l_time_phased_code
                ,p_description              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_description)
                ,p_quantity                 => PA_TASK_ASSIGNMENTS_PVT.pfnum(p_quantity)
                ,p_raw_cost                 => PA_TASK_ASSIGNMENTS_PVT.pfnum(p_raw_cost)
                ,p_burdened_cost            => PA_TASK_ASSIGNMENTS_PVT.pfnum(p_burdened_cost)
                ,p_revenue                  => PA_TASK_ASSIGNMENTS_PVT.pfnum(p_revenue)
                ,p_change_reason_code       => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_change_reason_code)
                ,p_attribute_category       => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute_category)
                ,p_attribute1               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute1)
                ,p_attribute2               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute2)
                ,p_attribute3               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute3)
                ,p_attribute4               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute4)
                ,p_attribute5               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute5)
                ,p_attribute6               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute6)
                ,p_attribute7               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute7)
                ,p_attribute8               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute8)
                ,p_attribute9               => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute9)
                ,p_attribute10              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute10)
                ,p_attribute11              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute11)
                ,p_attribute12              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute12)
                ,p_attribute13              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute13)
                ,p_attribute14              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute14)
                ,p_attribute15              => PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute15)
               );

          IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
          THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF p_return_status = FND_API.G_RET_STS_ERROR
          THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

          --summarizing the totals in the table pa_budget_versions
          PA_BUDGET_UTILS.summerize_project_totals
                         (x_budget_version_id => l_budget_version_id
                         ,x_err_code          => l_err_code
                         ,x_err_stage         => l_err_stage
                         ,x_err_stack         => l_err_stack );

          IF l_err_code > 0
          THEN
               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'summerize_project_totals API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                    IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                    THEN
                         pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
                          ,p_msg_attribute    => 'CHANGE'
                          ,p_resize_flag      => 'N'
                          ,p_msg_context      => 'BUDG'
                          ,p_attribute1       => l_amg_project_number
                          ,p_attribute2       => l_amg_task_number
                          ,p_attribute3       => l_budget_type_code
                          ,p_attribute4       => l_budget_lines_in(1).resource_alias
                          ,p_attribute5       => to_char(l_budget_lines_in(1).budget_start_date));
                    ELSE
                         pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => l_err_stage
                          ,p_msg_attribute    => 'CHANGE'
                          ,p_resize_flag      => 'N'
                          ,p_msg_context      => 'BUDG'
                          ,p_attribute1       => l_amg_project_number
                          ,p_attribute2       => l_amg_task_number
                          ,p_attribute3       => l_budget_type_code
                          ,p_attribute4       => l_budget_lines_in(1).resource_alias
                          ,p_attribute5       => to_char(l_budget_lines_in(1).budget_start_date));
                    END IF;
               END IF;--FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)

               RAISE FND_API.G_EXC_ERROR;

          ELSIF l_err_code < 0
          THEN

               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'summerize_project_totals API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
               THEN
                    FND_MSG_PUB.add_exc_msg
                    (  p_pkg_name       => 'PA_BUDGET_UTILS'
                    ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
                    ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
               END IF;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;--l_err_code > 0


     ELSE --insert budget line for new FinPlan model


          --Copy the fin plan line data into a table of type pa_fp_rollup_tmp
          --If an attribute should not be updated then pass it as null, and
          --if an attribute should be updated to null then pass it as FND_API.G_MISS_XXX

          l_finplan_lines_tab(1).system_reference1            := l_budget_lines_in(1).pa_task_id;
          l_finplan_lines_tab(1).system_reference2            := l_budget_lines_in(1).resource_list_member_id;
          l_finplan_lines_tab(1).start_date                   := l_budget_lines_in(1).budget_start_date;
          l_finplan_lines_tab(1).end_date                     := l_budget_lines_in(1).budget_end_date;
          l_finplan_lines_tab(1).period_name                  := l_budget_lines_in(1).period_name;
          l_finplan_lines_tab(1).txn_currency_code            := l_budget_lines_in(1).txn_currency_code;
          l_finplan_lines_tab(1).txn_raw_cost                 := PA_TASK_ASSIGNMENTS_PVT.pfnum(p_raw_cost);
          l_finplan_lines_tab(1).txn_burdened_cost            := PA_TASK_ASSIGNMENTS_PVT.pfnum(p_burdened_cost);
          l_finplan_lines_tab(1).txn_revenue                  := PA_TASK_ASSIGNMENTS_PVT.pfnum(p_revenue);
          l_finplan_lines_tab(1).quantity                     := PA_TASK_ASSIGNMENTS_PVT.pfnum(p_quantity);
          l_finplan_lines_tab(1).change_reason_code           := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_change_reason_code);
          l_finplan_lines_tab(1).description                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_description);
          l_finplan_lines_tab(1).attribute_category           := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute_category);
          l_finplan_lines_tab(1).attribute1                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute1);
          l_finplan_lines_tab(1).attribute2                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute2);
          l_finplan_lines_tab(1).attribute3                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute3);
          l_finplan_lines_tab(1).attribute4                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute4);
          l_finplan_lines_tab(1).attribute5                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute5);
          l_finplan_lines_tab(1).attribute6                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute6);
          l_finplan_lines_tab(1).attribute7                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute7);
          l_finplan_lines_tab(1).attribute8                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute8);
          l_finplan_lines_tab(1).attribute9                   := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute9);
          l_finplan_lines_tab(1).attribute10                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute10);
          l_finplan_lines_tab(1).attribute11                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute11);
          l_finplan_lines_tab(1).attribute12                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute12);
          l_finplan_lines_tab(1).attribute13                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute13);
          l_finplan_lines_tab(1).attribute14                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute14);
          l_finplan_lines_tab(1).attribute15                  := PA_TASK_ASSIGNMENTS_PVT.pfchar(p_attribute15);

          IF (p_projfunc_cost_rate_type     = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_projfunc_cost_rate_date_typ = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_projfunc_cost_rate_date     = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_projfunc_cost_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_projfunc_rev_rate_type      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_projfunc_rev_rate_date_typ  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_projfunc_rev_rate_date      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_projfunc_rev_exchange_rate  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_project_cost_rate_type      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_project_cost_rate_date_typ  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_project_cost_rate_date      = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_project_cost_exchange_rate  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_project_rev_rate_type       = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_project_rev_rate_date_typ   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_project_rev_rate_date       = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_project_rev_exchange_rate   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
          THEN
               l_finplan_lines_tab(1).projfunc_cost_rate_type      := to_char(NULL);
               l_finplan_lines_tab(1).projfunc_cost_rate_date_type := to_char(NULL);
               l_finplan_lines_tab(1).projfunc_cost_rate_date      := to_date(NULL);
               l_finplan_lines_tab(1).projfunc_cost_exchange_rate  := to_number(NULL);
               l_finplan_lines_tab(1).projfunc_rev_rate_type       := to_char(NULL);
               l_finplan_lines_tab(1).projfunc_rev_rate_date_type  := to_char(NULL);
               l_finplan_lines_tab(1).projfunc_rev_rate_date       := to_date(NULL);
               l_finplan_lines_tab(1).projfunc_rev_exchange_rate   := to_number(NULL);
               l_finplan_lines_tab(1).project_cost_rate_type       := to_char(NULL);
               l_finplan_lines_tab(1).project_cost_rate_date_type  := to_char(NULL);
               l_finplan_lines_tab(1).project_cost_rate_date       := to_date(NULL);
               l_finplan_lines_tab(1).project_cost_exchange_rate   := to_number(NULL);
               l_finplan_lines_tab(1).project_rev_rate_type        := to_char(NULL);
               l_finplan_lines_tab(1).project_rev_rate_date_type   := to_char(NULL);
               l_finplan_lines_tab(1).project_rev_rate_date        := to_date(NULL);
               l_finplan_lines_tab(1).project_rev_exchange_rate    := to_number(NULL);
          ELSE
               l_finplan_lines_tab(1).projfunc_cost_rate_type      := nvl(l_budget_lines_in(1).projfunc_cost_rate_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).projfunc_cost_rate_date_type := nvl(l_budget_lines_in(1).projfunc_cost_rate_date_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).projfunc_cost_rate_date      := nvl(l_budget_lines_in(1).projfunc_cost_rate_date,FND_API.G_MISS_DATE);
               l_finplan_lines_tab(1).projfunc_cost_exchange_rate  := nvl(l_budget_lines_in(1).projfunc_cost_exchange_rate,FND_API.G_MISS_NUM);
               l_finplan_lines_tab(1).projfunc_rev_rate_type       := nvl(l_budget_lines_in(1).projfunc_rev_rate_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).projfunc_rev_rate_date_type  := nvl(l_budget_lines_in(1).projfunc_rev_rate_date_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).projfunc_rev_rate_date       := nvl(l_budget_lines_in(1).projfunc_rev_rate_date,FND_API.G_MISS_DATE);
               l_finplan_lines_tab(1).projfunc_rev_exchange_rate   := nvl(l_budget_lines_in(1).projfunc_rev_exchange_rate,FND_API.G_MISS_NUM);
               l_finplan_lines_tab(1).project_cost_rate_type       := nvl(l_budget_lines_in(1).project_cost_rate_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).project_cost_rate_date_type  := nvl(l_budget_lines_in(1).project_cost_rate_date_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).project_cost_rate_date       := nvl(l_budget_lines_in(1).project_cost_rate_date,FND_API.G_MISS_DATE);
               l_finplan_lines_tab(1).project_cost_exchange_rate   := nvl(l_budget_lines_in(1).project_cost_exchange_rate,FND_API.G_MISS_NUM);
               l_finplan_lines_tab(1).project_rev_rate_type        := nvl(l_budget_lines_in(1).project_rev_rate_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).project_rev_rate_date_type   := nvl(l_budget_lines_in(1).project_rev_rate_date_type,FND_API.G_MISS_CHAR);
               l_finplan_lines_tab(1).project_rev_rate_date        := nvl(l_budget_lines_in(1).project_rev_rate_date,FND_API.G_MISS_DATE);
               l_finplan_lines_tab(1).project_rev_exchange_rate    := nvl(l_budget_lines_in(1).project_rev_exchange_rate,FND_API.G_MISS_NUM);
          END IF;

          l_finplan_lines_tab(1).pm_product_code              := l_budget_lines_in(1).pm_product_code;
          l_finplan_lines_tab(1).quantity_source              := 'I';
          l_finplan_lines_tab(1).raw_cost_source              := 'I';
          l_finplan_lines_tab(1).burdened_cost_source         := 'I';
          l_finplan_lines_tab(1).revenue_source               := 'I';
          l_finplan_lines_tab(1).resource_assignment_id       := l_resource_assignment_id;
          l_finplan_lines_tab(1).budget_line_id               := l_budget_line_id;
          l_finplan_lines_tab(1).budget_version_id            := l_budget_version_id;

          --Lock the budget version before updating a budget line
          l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                     (p_budget_version_id => l_budget_version_id);

          PA_FIN_PLAN_PVT.lock_unlock_version
          ( p_budget_version_id       => l_budget_version_id
           ,p_record_version_number   => l_record_version_number
           ,p_action                  => 'L'
           ,p_user_id                 => FND_GLOBAL.User_id
           ,p_person_id               => null
           ,x_return_status           => p_return_status
           ,x_msg_count               => p_msg_count
           ,x_msg_data                => p_msg_data);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                -- Error message is not added here as the api lock_unlock_version
                -- adds the message to stack
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'Failed in locking the version ' || l_budget_version_id;
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;

          --Call PA_FIN_PLAN_PVT.add_fin_plan_lines. This api takes care of updating
          --budget lines data in all relevant tables.
          PA_FIN_PLAN_PVT.add_fin_plan_lines
               ( p_calling_context      => PA_FP_CONSTANTS_PKG.G_AMG_API
                ,p_fin_plan_version_id  => l_budget_version_id
                ,p_finplan_lines_tab    => l_finplan_lines_tab
                ,x_return_status        => p_return_status
                ,x_msg_count            => p_msg_count
                ,x_msg_data             => p_msg_data );

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
               IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'PA_FIN_PLAN_PVT.add_fin_plan_lines API falied';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE  FND_API.G_EXC_ERROR;
          END IF;


          --unlock the budget version after updating the budget line
          l_record_version_number := PA_FIN_PLAN_UTILS.retrieve_record_version_number
                                     (p_budget_version_id => l_budget_version_id);

          PA_FIN_PLAN_PVT.lock_unlock_version
          ( p_budget_version_id       => l_budget_version_id
           ,p_record_version_number   => l_record_version_number
           ,p_action                  => 'U'
           ,p_user_id                 => FND_GLOBAL.User_id
           ,p_person_id               => null
           ,x_return_status           => p_return_status
           ,x_msg_count               => p_msg_count
           ,x_msg_data                => p_msg_data);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                -- Error message is not added here as the api lock_unlock_version
                -- adds the message to stack
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'Failed in unlocking the version ' || l_budget_version_id;
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;


     END IF;--end of code to update budget line


     IF FND_API.TO_BOOLEAN( p_commit )
     THEN
          COMMIT;
     END IF;

     IF(l_debug_mode='Y') THEN
           pa_debug.g_err_stage := 'Exiting ' || l_api_name;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc
     THEN

     ROLLBACK TO update_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and p_msg_data IS NULL THEN
           PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE
           ,p_msg_index      => 1
           ,p_msg_count      => l_msg_count
           ,p_msg_data       => l_msg_data
           ,p_data           => l_data
           ,p_msg_index_out  => l_msg_index_out);
           p_msg_data  := l_data;
           p_msg_count := l_msg_count;
     ELSE
           p_msg_count := l_msg_count;
     END IF;

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;

     RETURN;


     WHEN FND_API.G_EXC_ERROR
     THEN

     ROLLBACK TO update_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN

     ROLLBACK TO update_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN ROW_ALREADY_LOCKED
     THEN

     ROLLBACK TO update_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_ERROR;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
           FND_MESSAGE.set_name('PA','PA_ROW_ALREADY_LOCKED_B_AMG');
           FND_MESSAGE.set_token('PROJECT', l_amg_project_number);
           FND_MESSAGE.set_token('TASK', l_amg_task_number);
           FND_MESSAGE.set_token('BUDGET_TYPE', l_budget_type_code);
           FND_MESSAGE.set_token('SOURCE_NAME', '');
           FND_MESSAGE.set_token('START_DATE', '');
           FND_MESSAGE.set_token('ENTITY', 'G_BUDGET_LINE_CODE');
           FND_MSG_PUB.add;
     END IF;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;


     WHEN OTHERS
     THEN

     ROLLBACK TO update_budget_line_pub;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.add_exc_msg
        (  p_pkg_name       => G_PKG_NAME
        ,  p_procedure_name => l_api_name );
     END IF;

     FND_MSG_PUB.count_and_get
     (   p_count     =>  p_msg_count ,
         p_data      =>  p_msg_data  );

     IF ( l_debug_mode = 'Y' ) THEN
           pa_debug.reset_curr_function;
     END IF;

END update_budget_line;


----------------------------------------------------------------------------------------
--Name:             calculate_amounts
--Type:             Procedure
--Description:      This procedure can is used to recalculate raw cost,
--                  burdened cost and revenue by budget line within
--                  a given project.
--
--
--Called subprograms: Pa_Client_Extn_Budget.Calc_Raw_Cost
--                  , Pa_Client_Extn_Budget.Calc_Burdened_Cost
--                  , Pa_Client_Extn_Budget.Calc_Revenue
--
--
--
--History:
--    AUTUMN-1996    R. Krishnamurthy       Created
--    07-DEC-1996    L. de Werker           Changed error handling
--    25-MAR-2003    Rajagopal              Modified the code to make it compatible with
--                                          new Budgets and forecasts model
--
--    27-SEP-05      jwhite                 Bug 4588279
--                                          For budget_type_code Budgetary Control budgets,
--                                          add validation to prevent update to
--                                          periods later than the latest encumbrance year
--                                          for the set-of-books.
--
PROCEDURE Calculate_Amounts
( p_api_version_number          IN  NUMBER
 ,p_commit                      IN  VARCHAR2   := FND_API.G_FALSE
 ,p_init_msg_list               IN  VARCHAR2   := FND_API.G_FALSE
 ,p_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_raw_cost_yn            IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_burdened_cost_yn       IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_revenue_yn             IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_update_db_flag              IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_budget_lines_out       OUT NOCOPY calc_budget_line_out_tbl_type
  -- Bug 2863564 Parameters added for new Fin Plan Model
 ,p_budget_version_id           IN  pa_budget_versions.budget_version_id%TYPE
 ,p_fin_plan_type_id            IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name          IN  pa_fin_plan_types_tl.name%TYPE
 ,p_version_type                IN  pa_budget_versions.version_type%TYPE
 ,p_budget_version_number       IN  pa_budget_versions.version_number%TYPE
) IS

CURSOR l_budget_type_csr
          (p_budget_type_code   VARCHAR2 )
IS
SELECT 'X'
FROM   pa_budget_types
WHERE  budget_type_code = p_budget_type_code;

CURSOR l_task_csr (p_task_id IN NUMBER ) IS
SELECT pm_task_reference,
       task_name  -- Bug 2863564
FROM   pa_tasks
WHERE  task_id = p_task_id;

-- Bug 2863564 new variables defined for Financial Planning chnages

l_task_name                        pa_tasks.task_name%TYPE;
l_context                          VARCHAR2(30);
l_context_finplan         CONSTANT VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN;
l_context_budget          CONSTANT VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET;

-- Bug 2863564 The cursor has been modified for financial planning changes.
-- The changes include fetching of new columns which aren't included in the
-- view definition. Changing the pa_budget_lines_v view could have a large impact.
-- So, cursor has been modified to be based on the direct tables.

--<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
-- Modified the select statement to selecy alias name directly from pa_resource_list_members table
-- instead of PA_RESOURCES_PKG.GET_RESOURCE_NAME(rlm.resource_id,rlm.resource_type_id)



CURSOR l_resource_assignment_csr
      ( c_budget_version_id  NUMBER,
        c_context            VARCHAR2)
IS
SELECT  bl.rowid   row_id
       ,bl.budget_line_id   budget_line_id
       ,DECODE(c_context,l_context_finplan,bl.txn_currency_code,bl.projfunc_currency_code) txn_currency_code
       ,ra.resource_assignment_id resource_assignment_id
       ,ra.task_id     task_id
       ,ra.rate_based_flag rate_based_flag
       ,rlm.resource_list_id  resource_list_id
       ,rlm.resource_list_member_id resource_list_member_id
       ,rlm.resource_id  resource_id
       ,rlm.alias
       ,bl.start_date   start_date
       ,bl.end_date     end_date
       ,bl.period_name  period_name
       ,bl.quantity     quantity
       ,bl.display_quantity display_quantity  --IPM Arch Enhancement Bug 4865563
       ,DECODE(c_context,l_context_finplan,bl.txn_raw_cost,bl.raw_cost)           txn_raw_cost
       ,DECODE(c_context,l_context_finplan,bl.txn_burdened_cost,bl.burdened_cost) txn_burdened_cost
       ,DECODE(c_context,l_context_finplan,bl.txn_revenue,bl.revenue)             txn_revenue
       ,bl.project_raw_cost         project_raw_cost
        ,bl.project_burdened_cost    project_burdened_cost
        ,bl.project_revenue          project_revenue
        ,bl.raw_cost                 projfunc_raw_cost
        ,bl.burdened_cost            projfunc_burdened_cost
        ,bl.revenue                  projfunc_revenue
FROM   pa_budget_lines bl,
       pa_resource_assignments ra,
        pa_resource_list_members rlm
WHERE  bl.budget_version_id = c_budget_version_id
  AND  bl.resource_assignment_id = ra.resource_assignment_id
  AND  ra.resource_list_member_id = rlm.resource_list_member_id;

l_resource_assignment_rec        l_resource_assignment_csr%ROWTYPE;

-- PL/SQL tables that would be used for bulk processing

l_rowid_tbl                      row_id_tbl_type;
l_budget_line_id_tbl             budget_line_id_tbl_type;
l_txn_currency_code_tbl          txn_currency_code_tbl_type;
l_res_assignment_id_tbl          res_assignment_id_tbl_type;
l_task_id_tbl                    task_id_tbl_type;
l_resource_list_id_tbl           resource_list_id_tbl_type;
l_resource_list_member_id_tbl    res_list_member_id_tbl_type;
l_resource_id_tbl                resource_id_tbl_type;
l_resource_name_tbl              resource_name_tbl_type;
l_start_date_tbl                 date_tbl_type;
l_end_date_tbl                   date_tbl_type;
l_period_name_tbl                period_name_tbl_type;
l_quantity_tbl                   quantity_tbl_type;
l_display_quantity_tbl           display_quantity_tbl_type;  --IPM Arch Enhancement Bug 4865563
l_txn_raw_cost_tbl               raw_cost_tbl_type;
l_txn_burdened_cost_tbl          burdened_cost_tbl_type;
l_txn_revenue_tbl                revenue_tbl_type;
l_project_raw_cost_tbl           raw_cost_tbl_type;
l_project_burdened_cost_tbl      burdened_cost_tbl_type;
l_project_revenue_tbl            revenue_tbl_type;
l_projfunc_raw_cost_tbl          raw_cost_tbl_type;
l_projfunc_burdened_cost_tbl     burdened_cost_tbl_type;
l_projfunc_revenue_tbl           revenue_tbl_type;
l_rate_based_flag_tbl            rate_based_flag_tbl_type;

/* added for 2207723 */
CURSOR l_get_entry_level_csr (c_budget_version_id IN NUMBER)
IS
SELECT m.entry_level_code
FROM pa_budget_versions v
    ,pa_budget_entry_methods m
WHERE v.budget_version_id = c_budget_version_id
  AND v.budget_entry_method_code = m.budget_entry_method_code
  AND    v.ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause v.ci_id IS NULL--Bug # 3507156


l_api_name      CONSTANT    VARCHAR2(30) := 'Calculate_Amounts';

-- Bug 2863564 l_return_status             VARCHAR2(1);
l_project_id                NUMBER;
l_dummy                     VARCHAR2(30);
l_calculated_raw_cost       NUMBER := 0;
l_calculated_burdened_cost  NUMBER := 0;
l_calculated_revenue        NUMBER := 0;
l_err_code                  NUMBER := 0;
l_err_message               VARCHAR2(100);
l_err_stage                 VARCHAR2(100);
l_err_stack                 VARCHAR2(100);
l_budget_version_id         NUMBER;
l_line_ctr                  NUMBER := 0;
l_labor_flag                VARCHAR2(1);
l_allow_override_flag       VARCHAR2(1);
l_pm_task_reference         VARCHAR2(30);
l_msg_count                 NUMBER := 0;
l_msg_data                  VARCHAR2(2000);
l_function_allowed          VARCHAR2(1);
l_resp_id                   NUMBER := 0;
l_user_id                   NUMBER := 0;
l_module_name               VARCHAR2(80);
l_entry_level               pa_budget_entry_methods.entry_level_code%type; /* 2207723 */

p_multiple_task_msg         VARCHAR2(1) := 'T';

l_budget_line_id            pa_budget_lines.budget_line_id%TYPE; /* FPB2 */

--Included the following variables as part of changes to AMG due to finplan model.
l_txn_currency_code                pa_budget_lines.txn_currency_code%TYPE;
l_multi_currency_billing_flag      pa_projects_all.multi_currency_billing_flag%TYPE;
l_project_currency_code            pa_projects_all.project_currency_code%TYPE;
l_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE;
l_project_cost_rate_type           pa_projects_all.project_rate_type%TYPE;
l_projfunc_cost_rate_type          pa_projects_all.projfunc_cost_rate_type%TYPE;
l_project_bil_rate_type            pa_projects_all.project_bil_rate_type%TYPE;
l_projfunc_bil_rate_type           pa_projects_all.projfunc_bil_rate_type%TYPE;

l_fin_plan_type_id                 pa_fin_plan_types_b.fin_plan_type_id%TYPE;
l_fin_plan_type_code               pa_fin_plan_types_b.fin_plan_type_code%TYPE;
l_fin_plan_type_name               pa_fin_plan_types_tl.name%TYPE;

l_version_type                     pa_budget_versions.version_type%TYPE;
l_record_version_number            pa_budget_versions.record_version_number%TYPE;
l_budget_type_code                 pa_budget_versions.budget_type_code%TYPE;
l_ci_id                            pa_budget_versions.ci_id%TYPE;

l_debug_mode                       VARCHAR2(30):= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level5            CONSTANT NUMBER := 5;

l_plsql_max_array_size             NUMBER := 200;
l_security_ret_code                VARCHAR2(30);
l_result                           VARCHAR2(30);


ll_fin_plan_type_id                 pa_fin_plan_types_b.fin_plan_type_id%TYPE;
ll_fin_plan_type_name               pa_fin_plan_types_tl.name%TYPE;
ll_version_type                     pa_budget_versions.version_type%TYPE;
ll_version_number                   pa_budget_versions.version_number%TYPE;
--needed to get the field values associated to a AMG message

--Added baseline_funding flag and querying from pa_projects_all and not from pa_projects
CURSOR   l_amg_project_csr
   (p_pa_project_id pa_projects.project_id%type)
IS
SELECT   segment1
        ,baseline_funding_flag
FROM     pa_projects_all p
WHERE p.project_id = p_pa_project_id;

l_amg_project_rec               l_amg_project_csr%ROWTYPE;
--l_amg_segment1       VARCHAR2(25); no more used. Replaced by l_amg_project_rec.segment1

-- Bug 2863564 added for new financial planning changes

CURSOR  proj_fp_options_cur
        (c_project_id IN NUMBER, c_fin_plan_type_id IN NUMBER) IS
SELECT  'x'
FROM    pa_proj_fp_options pfo
WHERE   pfo.project_id = c_project_id
AND     pfo.fin_plan_type_id = c_fin_plan_type_id
AND     pfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

proj_fp_options_rec  proj_fp_options_cur%ROWTYPE;

CURSOR budget_version_info_cur (c_budget_version_id IN NUMBER) IS
SELECT  bv.project_id          project_id
       ,bv.budget_type_code    budget_type_code
       ,bv.fin_plan_type_id    fin_plan_type_id
       ,bv.version_type        version_type
       ,bv.budget_status_code  budget_status_code
       ,bv.ci_id               ci_id    -- raja
       ,pt.fin_plan_type_code  fin_plan_type_code
       ,pt.name                fin_plan_type_name
       ,pa_fin_plan_utils.get_fin_plan_level_code(bv.budget_version_id) plan_level_code
       ,bv.locked_by_person_id
       ,bv.request_id
       ,pt.plan_class_code
       ,bv.etc_start_date
       ,nvl(bv.wp_version_flag,'N') wp_version_flag
       ,bv.plan_processing_code
FROM   pa_budget_versions bv,
       pa_fin_plan_types_vl pt
WHERE  bv.budget_version_id = c_budget_version_id
AND    pt.fin_plan_type_id(+) = bv.fin_plan_type_id
AND    bv.ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause bv.ci_id IS NULL--Bug # 3507156


budget_version_info_rec  budget_version_info_cur%ROWTYPE;

CURSOR draft_version_cur(
       c_project_id         pa_budget_versions.project_id%TYPE
      ,c_budget_type_code   pa_budget_versions.budget_type_code%TYPE)
IS
SELECT  budget_version_id
FROM    pa_budget_versions
WHERE   project_id = c_project_id
AND     budget_type_code = c_budget_type_code
AND     budget_status_code = 'W'
AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156


draft_version_rec    draft_version_cur%ROWTYPE;

--Added for bug#3636409
l_workplan_flag                  VARCHAR2(1) := NULL;
l_editable_flag                  VARCHAR2(1);
l_autobaseline_flag              VARCHAR2(1) := NULL;

l_person_id                   fnd_user.employee_id%type;
l_resource_id                 pa_resource_txn_attributes.resource_id%type;
l_resource_name               per_all_people_f.full_name%type;
l_locked_by_name              per_people_x.full_name%type;

l_rw_cost_rate_override            pa_budget_lines.txn_cost_rate_override%TYPE;
l_burden_cost_rate_override        pa_budget_lines.burden_cost_rate_override%TYPE;
l_bill_rate_override               pa_budget_lines.txn_bill_rate_override%TYPE;

TYPE l_rw_cost_rate_override_tbl_t      IS TABLE OF pa_budget_lines.txn_cost_rate_override%TYPE
      INDEX BY BINARY_INTEGER;
TYPE l_burdn_cst_rte_override_tbl_t      IS TABLE OF pa_budget_lines.burden_cost_rate_override%TYPE
      INDEX BY BINARY_INTEGER;
TYPE l_bill_rate_override_tbl_t      IS TABLE OF pa_budget_lines.txn_bill_rate_override%TYPE
      INDEX BY BINARY_INTEGER;

l_rw_cost_rate_override_tbl            l_rw_cost_rate_override_tbl_t;
l_burden_cst_rate_override_tbl        l_burdn_cst_rte_override_tbl_t;
l_bill_rate_override_tbl               l_bill_rate_override_tbl_t;


l_budget_version_id_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_time_phased_code               pa_proj_fp_options.cost_time_phased_code%TYPE;
l_bdgt_lines_skip_flag           varchar2(1);
l_targ_request_id                pa_budget_versions.request_id%TYPE;

  --This variable will be used to call pa_resource_asgn_curr maintenance api - IPM Arch Enhancement
   l_fp_cols_rec              PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

 -- Bug 4588279, 27-SEP-05, jwhite ------------------

 -- Funds Check API Call
 l_fck_req_flag                   VARCHAR2(1) := NULL;
 l_bdgt_intg_flag                 VARCHAR2(1) := NULL;
 l_bdgt_ver_id                    NUMBER      := NULL;
 l_encum_type_id                  NUMBER      := NULL;
 l_balance_type                   VARCHAR2(1) := NULL;

 --Business Rule Validation
 l_period_year                    gl_period_statuses.period_year%TYPE;

 CURSOR l_budget_periods_csr
      (p_period_name    VARCHAR2
       ,p_period_type_code   VARCHAR2    )
   IS
   SELECT PERIOD_YEAR
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND    period_type_code = p_period_type_code;

 -- End Bug 4588279, 27-SEP-05, jwhite ------------------



BEGIN
--  Standard begin of API savepoint

    SAVEPOINT calculate_amounts_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
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
         END IF;

         RAISE FND_API.G_EXC_ERROR;

    END IF;

    l_pm_product_code :='Z';
    /*added for bug no :2413400*/
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
            p_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_resp_id     := FND_GLOBAL.Resp_id;
    l_user_id     := FND_GLOBAL.User_id;
--    l_module_name := 'PA_FP_MAINTAIN_GENERATED_PLAN'; -- 'PA_PM_UPDATE_BUDGET_LINE';

    -- Bug 2863564
    -- The code below commented out as all the security checks are shifted to a common API
    /*
    IF p_update_db_flag = 'Y' THEN
           l_resp_id := FND_GLOBAL.Resp_id;
           l_user_id := FND_GLOBAL.User_id;
           --l_module_name := p_pm_product_code||'.'||'PA_PM_UPDATE_BUDGET_LINE';
           l_module_name := 'PA_PM_UPDATE_BUDGET_LINE';

        -- As part of enforcing project security, which would determine
        -- whether the user has the necessary privileges to update the project
        -- need to call the pa_security package
        -- If a user does not have privileges to update the project, then
        -- cannot update the budget lines

        pa_security.initialize (X_user_id        => l_user_id,
                                X_calling_module => l_module_name);

        -- Actions performed using the APIs would be subject to
        -- function security. If the responsibility does not allow
        -- such functions to be executed, the API should not proceed further
        -- since the user does not have access to such functions

        PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_pa_project_id;


        PA_PM_FUNCTION_SECURITY_PUB.check_function_security
          (p_api_version_number => p_api_version_number,
           p_responsibility_id  => l_resp_id,
           p_function_name      => 'PA_PM_UPDATE_BUDGET_LINE',
           p_msg_count          => l_msg_count,
           p_msg_data           => l_msg_data,
           p_return_status      => l_return_status,
           p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
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
             p_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    */
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

         FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status         := FND_API.G_RET_STS_SUCCESS;


--CHECK FOR MANDATORY FIELDS and CONVERT VALUES to ID's

    --product_code is mandatory

     -- convert pm_project_reference to id

    Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => p_pa_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => p_return_status );

    IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF p_return_status = FND_API.G_RET_STS_ERROR
    THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- Commenting out the code below as all the security checks are shifted to a common API
    /*
    IF p_update_db_flag = 'Y' THEN

        -- Now verify whether project security allows the user to update
        -- project
        -- If a user does not have privileges to update the project, then
        -- cannot update the budget line

        IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

           -- The user does not have query privileges on this project
           -- Hence, cannot update the project.Raise error
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
              p_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        ELSE
              -- If the user has query privileges, then check whether
              -- update privileges are also available
              IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

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
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
        END IF;
    END IF;
   */
   -- Get segment1 for AMG messages

    OPEN l_amg_project_csr( l_project_id );
    FETCH l_amg_project_csr INTO l_amg_project_rec;
    CLOSE l_amg_project_csr;

    -- Bug 2863564 This is redundant code and thus commented out
/*
    -- Get the project and project functional currencies so that they can be used later
    pa_fin_plan_utils.Get_Project_Curr_Attributes
            (  p_project_id                    => l_project_id
              ,x_multi_currency_billing_flag   => l_multi_currency_billing_flag
              ,x_project_currency_code         => l_project_currency_code
              ,x_projfunc_currency_code        => l_projfunc_currency_code
              ,x_project_cost_rate_type        => l_project_cost_rate_type
              ,x_projfunc_cost_rate_type       => l_projfunc_cost_rate_type
              ,x_project_bil_rate_type         => l_project_bil_rate_type
              ,x_projfunc_bil_rate_type        => l_projfunc_bil_rate_type
              ,x_return_status                 => l_return_status
              ,x_msg_count                     => l_msg_count
              ,x_msg_data                      => l_msg_data);

    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- In budget model intialise txn currency code to PFC
    IF p_budget_type_code IS NOT  NULL  AND
       p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_txn_currency_code := l_projfunc_currency_code;
    END IF;
*/

       -- Added Logic by Xin Liu to handle MISS vars based on Manoj's code review.
       -- 28-APR-03


      IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        ll_fin_plan_type_id := NULL;
      ELSE
                        ll_fin_plan_type_id := p_fin_plan_type_id;
      END IF;

      IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        ll_fin_plan_type_name := NULL;
      ELSE
                        ll_fin_plan_type_name := p_fin_plan_type_name;
      END IF;

      IF p_budget_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        ll_version_number := NULL;
      ELSE
                        ll_version_number := p_budget_version_number;
      END IF;

      -- Changes done.


    -- Bug 2863564 New validations included as part of the changes

    -- Budget Version Id, Budget Type Info and Fin Plan Type info all shouldn't be missing

    IF ((p_budget_version_id  IS NULL OR p_budget_version_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  )  AND
        (p_budget_type_code   IS NULL OR p_budget_type_code   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )  AND
        (p_fin_plan_type_id   IS NULL OR p_fin_plan_type_id   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  )  AND
        (p_fin_plan_type_name IS NULL OR p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) )
    THEN
         PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA',
                p_msg_name       => 'PA_BUDGET_FP_BOTH_MISSING');

         IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Fin Plan type info and budget type info are missing';
               pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Both Budget Type Info and Fin Plan Type info shouldn't be provided

    IF (p_budget_type_code    IS NOT NULL AND p_budget_type_code   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
       ((p_fin_plan_type_name IS NOT NULL AND p_fin_plan_type_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
        (p_fin_plan_type_id   IS NOT NULL AND p_fin_plan_type_id   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ))
    THEN
         PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA',
                p_msg_name       => 'PA_BUDGET_FP_BOTH_NOT_NULL');

         IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Fin Plan type info and budget type info both are provided';
               pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

          -- get the person_id: used for locking checks
        PA_COMP_PROFILE_PUB.GET_USER_INFO
              (p_user_id         => l_user_id,
               x_person_id       => l_person_id,
               x_resource_id     => l_resource_id,
               x_resource_name   => l_resource_name);

    IF (p_budget_version_id IS NOT NULL AND p_budget_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
         -- Fetch budget version info
         OPEN  budget_version_info_cur(p_budget_version_id);
         FETCH budget_version_info_cur INTO budget_version_info_rec;

            IF budget_version_info_cur%NOTFOUND
            THEN

                 -- Add the error message that i/p plan version id is invlid

                 PA_UTILS.ADD_MESSAGE(
                        p_app_short_name  => 'PA'
                       ,p_msg_name        => 'PA_FP_INVALID_VERSION_ID'
                       ,p_token1          => 'BUDGET_VERSION_ID'
                       ,p_value1          => p_budget_version_id);

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'No budget version exists with i/p version id' ;
                       pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                 END IF;
                 CLOSE budget_version_info_cur;
                 RAISE FND_API.G_EXC_ERROR;

            ELSE
                 -- Check if the budget belongs to the same project

                 IF (budget_version_info_rec.project_id <> l_project_id)
                 THEN
                      PA_UTILS.ADD_MESSAGE(
                           p_app_short_name  => 'PA'
                          ,p_msg_name        => 'PA_FP_PROJ_VERSION_MISMATCH');

                      IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'i/p version doesnot belong to i/p project' ;
                            pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                      END IF;
                      CLOSE budget_version_info_cur;
                      RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 -- The i/p budget version should be a working verion.

                 IF (budget_version_info_rec.budget_status_code <> 'W')
                 THEN
                      PA_UTILS.ADD_MESSAGE(
                           p_app_short_name  => 'PA'
                          ,p_msg_name        => 'PA_FP_INVALID_VERSION_STATUS');

                      IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'i/p version is not a working version' ;
                            pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                      END IF;
                      CLOSE budget_version_info_cur;
                      RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 -- If the budget version is a control item version throw error

                 IF budget_version_info_rec.ci_id IS NOT NULL THEN
                      PA_UTILS.ADD_MESSAGE(
                            p_app_short_name  => 'PA'
                           ,p_msg_name        => 'PA_FP_CI_VERSION_NON_EDITABLE'
                           ,p_token1          => 'BUDGET_VERSION_ID'
                           ,p_value1          => p_budget_version_id);
                      IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'i/p version is ci version' ;
                            pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                      END IF;
                      CLOSE budget_version_info_cur;
                      RAISE FND_API.G_EXC_ERROR;
                 END IF;
            END IF;


         -- Derive the new / old budgets model context value using the budget version info.

         IF budget_version_info_rec.fin_plan_type_id IS NOT NULL
         THEN
              l_context            :=  l_context_finplan;
              l_fin_plan_type_id   :=  budget_version_info_rec.fin_plan_type_id;
              l_version_type       :=  budget_version_info_rec.version_type;
              l_fin_plan_type_code :=  budget_version_info_rec.fin_plan_type_code;
              l_fin_plan_type_name :=  budget_version_info_rec.fin_plan_type_name;
              l_workplan_flag       :=  budget_version_info_rec.wp_version_flag;
              l_budget_version_id  :=  p_budget_version_id;


              IF  l_fin_plan_type_code = 'ORG_FORECAST' THEN

                    -- Add appropriate exception message

                    PA_UTILS.ADD_MESSAGE
                         (p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_ORG_FCST_PLAN_TYPE'
                          );

                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Org_Forecast plan type has been passed' ;
                          pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
              END IF;
              --bug #3636409. Validation for WorkPlan Versions which cannot be edited using this AMG interface.

              IF  l_workplan_flag = 'Y' THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'WorkPlan Versions cannot be edited using this AMG interface' ;
                        pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_WP_BV_NOT_ALLOWED');
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- version locked by process
              IF ( ( nvl( budget_version_info_rec.locked_by_person_id,0) = -98)
                         AND ( budget_version_info_rec.request_id is NOT NULL )) THEN
                     PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_LOCKED_BY_PRC');
                     CLOSE budget_version_info_cur;
                     RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- version locked by another user
              IF (budget_version_info_rec.locked_by_person_id is not null)  then
                  IF (l_person_id <> budget_version_info_rec.locked_by_person_id) then

                      l_locked_by_name :=
                          pa_fin_plan_utils.get_person_name(budget_version_info_rec.locked_by_person_id);
                      PA_UTILS.ADD_MESSAGE
                             ( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_LCK_BY_USER',
                               p_token1         => 'PERSON_NAME',
                               p_value1         => l_locked_by_name);
                    CLOSE budget_version_info_cur;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
              END IF;
               -- Get the status of the current working version. If the status is submitted then
            -- it can not be updated/deleted
              IF nvl(budget_version_info_rec.budget_status_code,'X') = 'S' THEN
                 IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'Version exists in submitted status';
                            pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;
                 PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_VER_SUB_STS');
                 CLOSE budget_version_info_cur;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              l_entry_level := pa_fin_plan_utils.get_fin_plan_level_code(l_budget_version_id);

              l_autobaseline_flag := l_amg_project_rec.baseline_funding_flag;

              IF l_autobaseline_flag = 'N' THEN

                    pa_fin_plan_utils.Check_if_plan_type_editable (
                             P_project_id         => l_project_id
                            ,P_fin_plan_type_id   => l_fin_plan_type_id
                            ,P_version_type       => l_version_type
                            ,X_editable_flag      => l_editable_flag
                            ,X_return_status      => p_return_status
                            ,X_msg_count          => p_msg_count
                            ,X_msg_data           => p_msg_data);

                    -- Throw the error if the above API is not successfully executed

                    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage := 'Can not check if plan type is editable' ;
                                          pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                                    END IF;

                         RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    --Check for l_editable_flag. If it returns N, then raise PA_FP_PLAN_TYPE_NON_EDITABLE.

                    IF l_editable_flag = 'N'  THEN

                          IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'Plan type is not editable' ;
                                pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;

                          PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_PLAN_TYPE_NON_EDITABLE',
                                    p_token1         => 'PROJECT',
                                    p_value1         =>  l_amg_project_rec.segment1,
                                    p_token2         => 'PLAN_TYPE',
                                    p_value2         =>  l_fin_plan_type_name);

                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
              END IF;

         ELSE
              l_context := l_context_budget;
              l_budget_type_code   :=  budget_version_info_rec.budget_type_code;
              l_budget_version_id  :=  p_budget_version_id;
              /* added for 2207723 to get the entry level of the budget */
              OPEN l_get_entry_level_csr(l_budget_version_id);
              FETCH l_get_entry_level_csr into l_entry_level;
              CLOSE l_get_entry_level_csr;

         END IF;
         CLOSE budget_version_info_cur;

    ELSIF (p_fin_plan_type_id   IS NOT NULL AND p_fin_plan_type_id   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) OR
          (p_fin_plan_type_name IS NOT NULL AND p_fin_plan_type_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN

         -- Bug 2863564
         -- We are in the contex of new budgets model

         l_context := l_context_finplan;

         -- Call convert_plan_type_name_to_id api.
         -- If Plan Type Id is passed then the existence of a plan type with that id is checked
         -- Else using plan type name provided Plan Type Id is fetched.
         -- Proper error messages are stacked by the api if any validations fail.

         -- Change the p_fin_plan_type_id, p_fin_plan_type_name to
       --          ll_fin_plan_type_id,ll_fin_plan_type_name
         -- Xin Liu. 28-APR-03

         PA_FIN_PLAN_PVT.convert_plan_type_name_to_id
               ( p_fin_plan_type_id    => ll_fin_plan_type_id
                ,p_fin_plan_type_name  => ll_fin_plan_type_name
                ,x_fin_plan_type_id    => l_fin_plan_type_id
                ,x_return_status       => p_return_status
                ,x_msg_count           => p_msg_count
                ,x_msg_data            => p_msg_data);

         -- Throw the error if the above API is not successfully executed

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Plan Type validation have failed' ;
                     pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Now, we have a valid fin plan type id
         -- Check if the fin plan type code is 'ORG_FORECAST' if so throw an error

         BEGIN
              SELECT  fin_plan_type_code
                     ,name
                     , use_for_workplan_flag
              INTO    l_fin_plan_type_code
                     ,l_fin_plan_type_name
                     ,l_workplan_flag
              FROM   pa_fin_plan_types_vl
              WHERE  fin_plan_type_id = l_fin_plan_type_id;

              IF  l_fin_plan_type_code = 'ORG_FORECAST' THEN

                    -- Add appropriate exception message

                    PA_UTILS.ADD_MESSAGE
                         (p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_ORG_FCST_PLAN_TYPE'
                          );

                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Org_Forecast plan type has been passed' ;
                          pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
              END IF;
         EXCEPTION
              WHEN OTHERS THEN
                   IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Unexpected error while fetching the plan type code'||SQLERRM ;
                         pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

            --bug #3636409. Validation for WorkPlan Versions which cannot be edited using this AMG interface.

            IF  l_workplan_flag = 'Y' THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'WorkPlan Versions cannot be edited using this AMG interface' ;
                        pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_WP_BV_NOT_ALLOWED');
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
            --bug #3636409. Validation for workplan versions ends here.

         -- Bug 2863564 Check if the plan type has been attached to the project or not.

         OPEN  proj_fp_options_cur(l_project_id,l_fin_plan_type_id);
         FETCH proj_fp_options_cur INTO proj_fp_options_rec;

           IF proj_fp_options_cur%NOTFOUND THEN

              -- Throw appropriate error message
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_PLAN_TYPE_OPTION',
                       p_token1         => 'PROJECT',
                       p_value1         =>  l_amg_project_rec.segment1,
                       p_token2         => 'PLAN_TYPE',
                       p_value2         =>  l_fin_plan_type_name);

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'plan type not attached to project' ;
                     pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               CLOSE proj_fp_options_cur;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

         CLOSE proj_fp_options_cur;

      -- Changes done by Xin Liu for post_fpk. Check if p_version_type is G_PA_MISS_CHAR.  24-APR-03
         IF p_version_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                    l_version_type := NULL;
       ELSE
                  l_version_type := p_version_type;
         END IF;
      --Changes Done.

         -- Bug 2863564
         -- Call get_version_type api to do the necessary validations regarding the version type
         -- If the version type is passed as null,
         --      it returns version_type if it can be fethced uniquely.
         -- else if passed as not null
         --       it validates the passed value against the fin plan preference code

         pa_fin_plan_utils.get_version_type
                  ( p_project_id        => l_project_id
                   ,p_fin_plan_type_id  => l_fin_plan_type_id
                   ,px_version_type     => l_version_type
                   ,x_return_status     => p_return_status
                   ,x_msg_count         => p_msg_count
                   ,x_msg_data          => p_msg_data);

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'getversiontype Failed ' ;
                     pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
         END IF;

          --bug #3636409. Validation for allow_edit_after_baseline_flag starts here.
         l_autobaseline_flag := l_amg_project_rec.baseline_funding_flag;

         IF l_autobaseline_flag = 'N' THEN

               pa_fin_plan_utils.Check_if_plan_type_editable (
                        P_project_id         => l_project_id
                       ,P_fin_plan_type_id   => l_fin_plan_type_id
                       ,P_version_type       => l_version_type
                       ,X_editable_flag      => l_editable_flag
                       ,X_return_status      => p_return_status
                       ,X_msg_count          => p_msg_count
                       ,X_msg_data           => p_msg_data);

               -- Throw the error if the above API is not successfully executed

               IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                               IF l_debug_mode = 'Y' THEN
                                     pa_debug.g_err_stage := 'Can not check if plan type is editable' ;
                                     pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;

                    RAISE FND_API.G_EXC_ERROR;
               END IF;

               --Check for l_editable_flag. If it returns N, then raise PA_FP_PLAN_TYPE_NON_EDITABLE.

               IF l_editable_flag = 'N'  THEN

                     IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Plan type is not editable' ;
                           pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;

                     PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_PLAN_TYPE_NON_EDITABLE',
                               p_token1         => 'PROJECT',
                               p_value1         =>  l_amg_project_rec.segment1,
                               p_token2         => 'PLAN_TYPE',
                               p_value2         =>  l_fin_plan_type_name);

                    RAISE FND_API.G_EXC_ERROR;
               END IF;
         END IF;
           --bug #3636409. Validation for allow_edit_after_baseline_flag ends here.


         IF   p_budget_version_number IS NOT NULL
         AND  p_budget_Version_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
         THEN
              -- Bug 2863564
              -- Fetch the working budget version with the unique combination of
              -- l_project_id, l_finplan_type_id,l_version_type, version_number provided

              pa_fin_plan_utils.get_version_id
                  (  p_project_id        => l_project_id
                    ,p_fin_plan_type_id  => l_fin_plan_type_id
                    ,p_version_type      => l_version_type
                    ,p_version_number    => p_budget_version_number
                    ,x_budget_version_id => l_budget_version_id
                    ,x_ci_id             => l_ci_id
                    ,x_return_status     => p_return_status
                    ,x_msg_count         => p_msg_count
                    ,x_msg_data          => p_msg_data );

              IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'getVersionId api Failed ' ;
                          pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- If the budget version is a control item version throw error

              IF l_ci_id IS NOT NULL THEN
                  PA_UTILS.ADD_MESSAGE(
                         p_app_short_name  => 'PA'
                        ,p_msg_name        => 'PA_FP_CI_VERSION_NON_EDITABLE'
                        ,p_token1          => 'BUDGET_VERSION_ID'
                        ,p_value1          => p_budget_version_id);

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'i/p version is ci version' ;
                        pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
         ELSE
              -- Fetch the current working version for the project, finplan type and verion type

              PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(
                      p_project_id           =>   l_project_id
                     ,p_fin_plan_type_id     =>   l_fin_plan_type_id
                     ,p_version_type         =>   l_version_type
                     ,x_fp_options_id        =>   l_dummy
                     ,x_fin_plan_version_id  =>   l_budget_version_id
                     ,x_return_status        =>   p_return_status
                     ,x_msg_count            =>   p_msg_count
                     ,x_msg_data             =>   p_msg_data );

              IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Get_Curr_Working_Version_Info api Failed ' ;
                          pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
              END IF;

         END IF;

         -- Bug 2863564
         -- If budget version id can't be found for i/p parameteres throw appropriate error message

       -- Changes done by Xin Liu for post_fpk. Added check for G_PA_MISS_NUM. 24-APR-03
         IF l_budget_version_id IS NULL OR l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

              -- Throw appropriate error message
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_NO_WORKING_VERSION',
                       p_token1         => 'PROJECT',
                       p_value1         =>  l_amg_project_rec.segment1,
                       p_token2         => 'PLAN_TYPE',
                       p_value2         =>  l_fin_plan_type_name,
                       p_token3         => 'VERSION_NUMBER',
                       p_value3         =>  p_budget_Version_number );

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Budget Version does not exist' ;
                     pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
         Else
                -- Fetch budget version info
                OPEN  budget_version_info_cur(l_budget_version_id);
                FETCH budget_version_info_cur INTO budget_version_info_rec;
                -- version locked by process
                IF ( ( nvl( budget_version_info_rec.locked_by_person_id,0) = -98 )
                         AND ( budget_version_info_rec.request_id is NOT NULL )    ) THEN

                     PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_LOCKED_BY_PRC');

                    CLOSE budget_version_info_cur;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

              -- version locked by another user
              IF (budget_version_info_rec.locked_by_person_id is not null)  then
                  IF (l_person_id <> budget_version_info_rec.locked_by_person_id) then

                      l_locked_by_name := pa_fin_plan_utils.get_person_name(budget_version_info_rec.locked_by_person_id);
                      PA_UTILS.ADD_MESSAGE
                               ( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_LCK_BY_USER',
                                 p_token1         => 'PERSON_NAME',
                                 p_value1         => l_locked_by_name);
                      CLOSE budget_version_info_cur;
                      RAISE FND_API.G_EXC_ERROR;
                  END IF;
              END IF;

              -- Get the status of the current working version. If the status is submitted then
              -- it can not be updated/deleted
              IF nvl(budget_version_info_rec.budget_status_code,'X') = 'S' THEN
                 IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'Version exists in submitted status';
                            pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;
                 PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_VER_SUB_STS');
                 CLOSE budget_version_info_cur;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF budget_version_info_rec.plan_processing_code IN ('XLUE','XLUP') THEN

                  pa_fin_plan_utils.return_and_vldt_plan_prc_code
                      (p_budget_version_id      =>   l_budget_version_id
                       ,p_plan_processing_code  =>   budget_version_info_rec.plan_processing_code
                       ,x_final_plan_prc_code    =>  budget_version_info_rec.plan_processing_code
                       ,x_targ_request_id        =>  l_targ_request_id
                       ,x_return_status          =>   p_return_status
                       ,x_msg_count              =>   p_msg_count
                       ,x_msg_data               =>   p_msg_data);

                  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Validate plan processing code api Failed ' ;
                              pa_debug.write('Processing Code'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

              END IF;

            CLOSE budget_version_info_cur;
         End if;

         -- Bug 2863564
         -- Fetch the planning level of the budget version

         l_entry_level := pa_fin_plan_utils.get_fin_plan_level_code(l_budget_version_id);

    ELSIF p_budget_type_code IS NOT NULL OR p_budget_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN

         -- Bug 2863564
         -- The following validation has been commented as its not relevant any more

         /*
         -- budget type code is mandatory
         IF p_budget_type_code IS NULL
         OR p_budget_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 pa_interface_utils_pub.map_new_amg_msg
                 ( p_old_message_code => 'PA_BUDGET_TYPE_IS_INVALID'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'BUDG'
                  ,p_attribute1       => l_amg_segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => p_budget_type_code
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          ELSE
          */

         -- If the budget_type info is passed, we are in the context of old bugets model

         l_context := l_context_budget;
         l_budget_type_code := p_budget_type_code;

         -- Validate the budget type code

         OPEN l_budget_type_csr( p_budget_type_code );

         FETCH l_budget_type_csr INTO l_dummy;

         IF l_budget_type_csr%NOTFOUND THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
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
            END IF;
            CLOSE l_budget_type_csr;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE l_budget_type_csr;

         -- fetch the draft version id

         OPEN  draft_version_cur( l_project_id
                                 ,p_budget_type_code );
         FETCH draft_version_cur INTO draft_version_rec;
               IF draft_version_cur%NOTFOUND
               THEN
                     -- Throw appropriate error message
                     PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA',
                             p_msg_name       => 'PA_NO_BUDGET_VERSION');

                     IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Draft Budget Version does not exist' ;
                           pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                     CLOSE draft_version_cur;
                     RAISE FND_API.G_EXC_ERROR;
               ELSE
                     l_budget_version_id := draft_version_rec.budget_version_id;
               END IF;
         CLOSE draft_version_cur;

         -- Get budget entry method details

         /* added for 2207723 to get the entry level of the budget */
         OPEN l_get_entry_level_csr(l_budget_version_id);
         FETCH l_get_entry_level_csr into l_entry_level;
         CLOSE l_get_entry_level_csr;


    END IF; -- I/p Budget Version Id not null

    -- Bug 2863564
    -- Call the api that performs the autobaseline checks

    PA_FIN_PLAN_UTILS.PERFORM_AUTOBASLINE_CHECKS (
           p_budget_version_id  =>   l_budget_version_id
          ,x_result             =>   l_result
          ,x_return_status      =>   p_return_status
          ,x_msg_count          =>   p_msg_count
          ,x_msg_data           =>   p_msg_data       );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF(l_debug_mode='Y') THEN
                pa_debug.g_err_stage := 'Auto baseline API falied';
                pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_result = 'F' THEN
          IF(l_debug_mode='Y') THEN
                pa_debug.g_err_stage := 'Auto baselining enabled for the project';
                pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE(
                  p_app_short_name  => 'PA'
                 ,p_msg_name        => 'PA_FP_AB_AR_VER_NON_EDITABLE'
                 ,p_token1          => 'PROJECT'
                 ,p_value1          => l_amg_project_rec.segment1);
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_context = l_context_budget
    THEN
         -- Derive the version type using the budget amount code to restrict
         -- the users editing the 'COST' amounts if the version is 'REVENUE_ONLY'

        PA_FIN_PLAN_UTILS.get_version_type_for_bdgt_type
             (  p_budget_type_code      => l_budget_type_code
               ,x_version_type          => l_version_type
               ,x_return_status         => p_return_status
               ,x_msg_count             => p_msg_count
               ,x_msg_data              => p_msg_data );

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF(l_debug_mode='Y') THEN
                    pa_debug.g_err_stage := 'get_version_type_for_bdgt_type API falied';
                    pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_update_db_flag = 'Y'
    THEN
           l_module_name := 'PA_PM_UPDATE_BUDGET_LINE'; --4615645.

            -- Bug 2863564 Check for the function security

            PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY (
                   p_api_version_number =>   p_api_version_number
                  ,p_project_id         =>   l_project_id
                  ,p_fin_plan_type_id   =>   l_fin_plan_type_id /* Bug 3139924 */
                  ,p_calling_context    =>   l_context
                  ,p_function_name      =>   l_module_name
                  ,p_version_type       =>   l_version_type
                  ,x_return_status      =>   p_return_status
                  ,x_ret_code           =>   l_security_ret_code );

            -- The above API adds the error message to stack. Hence the message is not added here.
            -- Also, as security check is important further validations are not done in case this
            -- validation fails.

            IF (p_return_status <> FND_API.G_RET_STS_SUCCESS OR l_security_ret_code <> 'Y') THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Security API Failed';
                        pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;

    -- Bug 2863564
    -- For Financial Planning model, we need to lock the plan version explicitly
    -- before Updating the version.

    IF p_update_db_flag = 'Y' AND l_context = l_context_finplan THEN

         -- Fetch the record version number of the plan version
         l_record_version_number :=
                  PA_FIN_PLAN_UTILS.RETRIEVE_RECORD_VERSION_NUMBER(l_budget_version_id);

         PA_FIN_PLAN_PVT.LOCK_UNLOCK_VERSION
              ( p_budget_version_id       => l_budget_version_id
               ,p_record_version_number   => l_record_version_number
               ,p_action                  => 'L'
               ,p_user_id                 => FND_GLOBAL.User_id
               ,p_person_id               => NULL
               ,x_return_status           => p_return_status
               ,x_msg_count               => p_msg_count
               ,x_msg_data                => p_msg_data);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

               -- Error message is not added here as the api lock_unlock_version
               -- adds the message to stack
               IF(l_debug_mode='Y') THEN
                     pa_debug.g_err_stage := 'Failed in locking the version';
                     pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               RAISE FND_API.G_EXC_ERROR;
         END IF;

    END IF;



    -- Bug 4588279, 27-SEP-05, jwhite ---------------------------------------------------

    -- For budget_type_code Budgetary Control budgets,
    --
    -- 1) Add validation rule to prevent update to
    --    periods later than the latest encumbrance year for the set-of-books.
    --
    -- 2) For information purposes, this validation will be performed even if the update mode
    --    is disabled ( p_update_db_flag = 'N' )
    --
    --

    -- Since this initilization is performed here, this global can be used in lieu of a test
    -- for the following later in this procedure:
    -- 1) Update Mode
    -- 2) Budget_type_code model
    -- 3) Budgetary Control
    --

    PA_BUDGET_PUB.G_Latest_Encumbrance_Year := -99;


    IF ( p_update_db_flag = 'Y' )
     THEN
     -- UPDATE MODE

      IF ( p_budget_type_code IS NOT NULL ) -- budget_type_code model
         THEN

          -- Test for Budgetary Control

            --Check if budgetary control is enabled for the given project and
            --budget type code.
            PA_BUDGET_FUND_PKG.get_budget_ctrl_options
                            ( p_project_Id       => l_project_id
                            , p_budget_type_code => p_budget_type_code
                            , p_calling_mode     => 'BUDGET'
                            , x_fck_req_flag     => l_fck_req_flag
                            , x_bdgt_intg_flag   => l_bdgt_intg_flag
                            , x_bdgt_ver_id      => l_bdgt_ver_id
                            , x_encum_type_id    => l_encum_type_id
                            , x_balance_type     => l_balance_type
                            , x_return_status    => p_return_status
                            , x_msg_data         => p_msg_data
                            , x_msg_count        => p_msg_count
                            );

            -- calling api above adds the error message to stack hence not adding the error message here.
            IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Calculate_Amounts returned unexp error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF p_return_status = FND_API.G_RET_STS_ERROR
            THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Calculate_Amounts returned  error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE  FND_API.G_EXC_ERROR;
            END IF;


            --If funds check is required then this budget cannot be updated thru AMG interface
            --FOR PERIOD_YEARS THAT FALL AFTER THE LATEST ENCUMBRANCE YEAR.


            IF (nvl(l_fck_req_flag,'N') = 'Y')
            THEN

                 --RE-Populate global for subsequent conditional budget LINE validation
                 --  Storing a value other than -99 is essential to conditional LINE validation

                 PA_BUDGET_PVT.Get_Latest_BC_Year
                     ( p_pa_project_id            => l_project_id
                       ,x_latest_encumbrance_year => PA_BUDGET_PUB.G_Latest_Encumbrance_Year
                       ,x_return_status           => p_return_status
                       ,x_msg_count               => p_msg_count
                       ,x_msg_data                => p_msg_data
                      );


                 -- calling api above adds the error message to stack hence not adding the error message here.
                 IF p_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
                 THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Get_Latest_BC_Year returned unexp error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF p_return_status = FND_API.G_RET_STS_ERROR
                 THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Get_Latest_BC_Year returned  error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE  FND_API.G_EXC_ERROR;
                 END IF;

            END IF; --(nvl(l_fck_req_flag,'N') = 'Y')

       END IF;  -- p_budget_type_code IS NOT NULL


   END IF;  -- p_update_db_flag = 'Y'

    -- End Bug 4588279, 27-SEP-05, jwhite -------------------------------------------------




    -- Read all budget lines  - Begin Budget lines loop

    l_line_ctr   := 0;

    IF l_context = l_context_finplan THEN
       l_time_phased_code := PA_FIN_PLAN_UTILS.Get_Time_Phased_code(l_budget_version_id);
    END IF;

     OPEN  budget_version_info_cur(l_budget_version_id);
     FETCH budget_version_info_cur INTO budget_version_info_rec;
     close budget_version_info_cur;

    --Set this variable to 'N' initially. This would be set to Yes if for some budget lines client extensions are not called.
    l_bdgt_lines_skip_flag := 'N';

    OPEN l_resource_assignment_csr (l_budget_version_id,l_context);
    LOOP

         FETCH l_resource_assignment_csr BULK COLLECT INTO
             l_rowid_tbl
            ,l_budget_line_id_tbl
            ,l_txn_currency_code_tbl
            ,l_res_assignment_id_tbl
            ,l_task_id_tbl
            ,l_rate_based_flag_tbl
            ,l_resource_list_id_tbl
            ,l_resource_list_member_id_tbl
            ,l_resource_id_tbl
            ,l_resource_name_tbl
            ,l_start_date_tbl
            ,l_end_date_tbl
            ,l_period_name_tbl
            ,l_quantity_tbl
            ,l_display_quantity_tbl --IPM Arch Enhancement Bug 4865563
            ,l_txn_raw_cost_tbl
            ,l_txn_burdened_cost_tbl
            ,l_txn_revenue_tbl
            ,l_project_raw_cost_tbl
            ,l_project_burdened_cost_tbl
            ,l_project_revenue_tbl
            ,l_projfunc_raw_cost_tbl
            ,l_projfunc_burdened_cost_tbl
            ,l_projfunc_revenue_tbl
         LIMIT l_plsql_max_array_size;

         IF(l_debug_mode='Y') THEN
               pa_debug.g_err_stage := 'fetched ' || sql%rowcount || ' records';
               pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;

         -- For each of the budget line fetched call client extension apis

         IF NVL(l_rowid_tbl.last,0) >= 1 THEN  /* Only if something is fetched */
           FOR i IN l_rowid_tbl.first .. l_rowid_tbl.last
           LOOP
                l_line_ctr := l_line_ctr + 1;
                l_task_name := NULL;
                -- Get the pm_task_reference for the task_id
                IF l_entry_level <> 'P' THEN /* 2207733 do this check only if budget is not at project level other valid
                                                values are 'L', 'M', and 'P' */
                     --OPEN l_task_csr (l_resource_assignment_rec.task_id);
                     OPEN  l_task_csr (l_task_id_tbl(i));
                     FETCH l_task_csr INTO l_pm_task_reference
                                          ,l_task_name; -- Bug 2863564
                          IF l_task_csr%NOTFOUND THEN
                              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                  pa_interface_utils_pub.map_new_amg_msg
                                  ( p_old_message_code => 'PA_TASK_ID_INVALID'
                                   ,p_msg_attribute    => 'CHANGE'
                                   ,p_resize_flag      => 'N'
                                   ,p_msg_context      => 'PROJ'
                                   ,p_attribute1       => l_amg_project_rec.segment1
                                   ,p_attribute2       => ''
                                   ,p_attribute3       => ''
                                   ,p_attribute4       => ''
                                   ,p_attribute5       => '');
                              END IF;
                              CLOSE l_task_csr;
                              p_multiple_task_msg   := 'F';
                              --  RAISE FND_API.G_EXC_ERROR;
                          END IF;
                     CLOSE l_task_csr;
                END IF; /* 2207733 */


                p_calc_budget_lines_out(l_line_ctr).pa_task_id              := l_task_id_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).pm_task_reference       := l_pm_task_reference;
                p_calc_budget_lines_out(l_line_ctr).resource_alias          := l_resource_name_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).resource_list_member_id := l_resource_list_member_id_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).budget_start_date       := l_start_date_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).budget_end_date         := l_end_date_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).period_name             := l_period_name_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).quantity                := l_quantity_tbl(i);
                p_calc_budget_lines_out(l_line_ctr).display_quantity        := l_display_quantity_tbl(i); --IPM Arch Enhancement Bug 4865563
                p_calc_budget_lines_out(l_line_ctr).txn_currency_code       := l_txn_currency_code_tbl(i);

                -- Fix: 03-FEB-97, jwhite
                -- Added line to populate line return status. ---------------------------
                p_calc_budget_lines_out(l_line_ctr).return_status := FND_API.G_RET_STS_SUCCESS;
                -- ------------------------------------------------------------------------------

                l_calculated_raw_cost        := l_txn_raw_cost_tbl(i);
                l_calculated_burdened_cost   := l_txn_burdened_cost_tbl(i);
                l_calculated_revenue         := l_txn_revenue_tbl(i);

                --Initialize the three override values to null. These would be appropriately set to new derived values depending on
                -- the context.
                l_rw_cost_rate_override_tbl(i) := null;
                l_burden_cst_rate_override_tbl(i) := null;
                l_bill_rate_override_tbl(i) := null;


                -- Bug 4588279, 27-SEP-05, jwhite ---------------------
                -- For Update-Mode, Budget-Type-Code and Budgetary Control, issue error for any period record that
                -- falls after the latest encumbrance year.
                --
                -- Implicit Assumptions in following code:
                -- 1) If ( PA_BUDGET_PUB.G_Latest_Encumbrance_Year > -99), then
                --     this is Update-Mode, Budget-Type-Code and Budgetary Control data.
                -- 2) Budgetary control is ONLY for GL periods.
                --

                -- Initialize Period Year Variable
                l_period_year := NULL;


                IF ( PA_BUDGET_PUB.G_Latest_Encumbrance_Year > -99)
                   THEN
                   -- Budgetary Control Enabled Budget-Type-Code and Update_Mode

                   -- Fetch Period Year for budget LINE Period Name
                   OPEN l_budget_periods_csr( l_period_name_tbl(i),'G');

                   FETCH l_budget_periods_csr INTO l_period_year;

                   CLOSE l_budget_periods_csr;

                   -- Test Business Rule
                   IF ( l_period_year > PA_BUDGET_PUB.G_Latest_Encumbrance_Year )
                     THEN
                          pa_utils.add_message
                                    ( p_app_short_name  => 'PA'
                                      , p_msg_name        => 'PA_BC_ENC_YR_NO_CHG_FUTURE');
                          p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_ERROR;
                          p_multiple_task_msg   := 'F';
                     END IF;

                END IF;

                -- End Bug 4588279, 27-SEP-05, jwhite ------------------


                --if plan type is FORECAST and for such a forecast version if the ETC start date is greater than start date for
                --any of the budget lines then dont call the extension for these lines. For these lines report the amounts
                -- as such without calling client extesion on these. For other lines for this version we can
                --call the client extensions.
                --Also for a forecast version with ETC start date greater than budget line start date, if time phasing for the
                --forecast version is none then call client extension for such lines.

                if ( not(budget_version_info_rec.plan_class_code = 'FORECAST' and
                         budget_version_info_rec.etc_start_date is not null and   --Added this null check for Bug 3636409
                         budget_version_info_rec.etc_start_date > l_start_date_tbl(i) and
                         l_time_phased_code is not null and
                         l_time_phased_code <> 'N')
                     or
                     l_context = l_context_budget )
                then
                IF (p_calc_raw_cost_yn = 'Y'   AND
                    l_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE)
                THEN   -- calculate raw cost

                   Pa_client_Extn_Budget.Calc_Raw_Cost
                       (x_budget_version_id         => l_budget_version_id,
                        x_project_id                => l_project_id,
                        x_task_id                   => l_task_id_tbl(i),
                        x_resource_list_member_id   => l_resource_list_member_id_tbl(i),
                        x_resource_list_id          => l_resource_list_id_tbl(i),
                        x_resource_id               => l_resource_id_tbl(i),
                        x_start_date                => l_start_date_tbl(i),
                        x_end_date                  => l_end_date_tbl(i),
                        x_period_name               => l_period_name_tbl(i),
                        x_quantity                  => l_quantity_tbl(i),
                        x_raw_cost                  => l_calculated_raw_cost,
                        x_pm_product_code           => p_pm_product_code,
                        x_error_code                => l_err_code,
                        x_error_message             => l_err_message,
                        --Added the parameter as part of changes to AMG due to finplan model
                        x_txn_currency_code         => l_txn_currency_code_tbl(i));

                   IF l_err_code > 0
                   THEN

                       IF l_context = l_context_budget
                       THEN
                            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN

                                IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                                THEN
                                    pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_CALC_RAW_COST_FAILED'
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

                            END IF;
                       ELSE
                            PA_UTILS.ADD_MESSAGE(
                                   p_app_short_name  => 'PA'
                                  ,p_msg_name        => 'PA_FP_CALC_RAW_COST_FAILED'
                                  ,p_token1          => 'PROJECT'
                                  ,p_value1          => l_amg_project_rec.segment1
                                  ,p_token2          => 'TASK'
                                  ,p_value2          => l_task_name
                                  ,p_token3          => 'PLAN_TYPE'
                                  ,p_value3          => l_fin_plan_type_name
                                  ,p_token4          => 'SOURCE_NAME'
                                  ,p_value4          => l_resource_name_tbl(i)
                                  ,p_token5          => 'START_DATE'
                                  ,p_value5          => l_start_date_tbl(i)
                                  );
                       END IF;

                       p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_ERROR;
                       p_multiple_task_msg   := 'F';
                       --  RAISE FND_API.G_EXC_ERROR;

                   ELSIF l_err_code < 0
                   THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN

                            FND_MSG_PUB.add_exc_msg
                                (  p_pkg_name       => 'PA_CLIENT_EXTN_BUDGET'
                                ,  p_procedure_name => 'CALC_RAW_COST'
                                ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                        END IF;

                        p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   END IF;

                            /* if the Client extn amounts override the rate api derived amounts
                             * then re-derive the override rates. This should be done only for finplan model
                             */
                    if l_fin_plan_type_id is not null then
                            IF l_version_type in ('ALL','COST') Then
                                If l_rate_based_flag_tbl(i) = 'N' Then
                                        If NVL(l_calculated_raw_cost,0) <> NVL(l_txn_raw_cost_tbl(i),0) Then
                                           l_calculated_raw_cost := pa_currency.round_trans_currency_amt1(l_calculated_raw_cost,l_txn_currency_code_tbl(i));
                                                l_quantity_tbl(i) := l_calculated_raw_cost;
                                                l_display_quantity_tbl(i) := null;  --IPM Arch Enhancements Bug 4865563
                                                l_rw_cost_rate_override_tbl(i) := 1;
                                                /* change in raw cost changes the burden cost rate */
                                                If (nvl(l_quantity_tbl(i),0) <> 0 AND nvl(l_quantity_tbl(i),0) <>
                                                      nvl(p_calc_budget_lines_out(l_line_ctr).quantity,0)) Then
                                                   l_burden_cst_rate_override_tbl(i) := l_txn_burdened_cost_tbl(i)/l_quantity_tbl(i);
                                                End if;
                                                /* change in the quantity changes the bill rate */
                                                If l_version_type = 'ALL' Then
                                                      If (nvl(l_quantity_tbl(i),0) <> 0 AND nvl(l_quantity_tbl(i),0) <> nvl(p_calc_budget_lines_out(l_line_ctr).quantity,0)) Then
                                                            l_bill_rate_override_tbl(i) := l_txn_revenue_tbl(i)/l_quantity_tbl(i);
                                                      End If;
                                          End If;
                                        End If;
                                Else
                                        If NVL(l_calculated_raw_cost,0) <> NVL(l_txn_raw_cost_tbl(i),0) Then
                                 l_calculated_raw_cost := pa_currency.round_trans_currency_amt1(l_calculated_raw_cost,l_txn_currency_code_tbl(i));
                                           If nvl(l_quantity_tbl(i),0) <> 0 Then
                                           --Bug 5006031 Issue 8
                                                 If l_calculated_raw_cost = 0 OR l_calculated_raw_cost IS NULL then
                                                   l_rw_cost_rate_override_tbl(i) := 0;
                                                 Else
                                                l_rw_cost_rate_override_tbl(i) := l_calculated_raw_cost/l_quantity_tbl(i);
                                                 End If;
                                           End If;
                                        End If;
                                End If;
                            End If;
                    end if; --l_fin_plan_type_id is not null
                END IF;

                IF (p_calc_burdened_cost_yn = 'Y'   AND
                    l_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE)
                THEN

                     -- calculate burdened cost. Note that calculated_raw_cost is being
                     -- used as the parameter,in case both p_calc_raw_cost_yn and
                     -- p_calc_burdened_cost_yn are both set to 'Y'.Calculated_raw_cost
                     -- would either hold the newly calculated value or the value from
                     -- the database,depending on the value of p_calc_raw_cost_yn flag.

                     Pa_client_Extn_Budget.Calc_burdened_Cost
                          ( x_budget_version_id         => l_budget_version_id
                           ,x_project_id                => l_project_id
                           ,x_task_id                   => l_task_id_tbl(i)
                           ,x_resource_list_member_id   => l_resource_list_member_id_tbl(i)
                           ,x_resource_list_id          => l_resource_list_id_tbl(i)
                           ,x_resource_id               => l_resource_id_tbl(i)
                           ,x_start_date                => l_start_date_tbl(i)
                           ,x_end_date                  => l_end_date_tbl(i)
                           ,x_period_name               => l_period_name_tbl(i)
                           ,x_quantity                  => l_quantity_tbl(i)
                           ,x_raw_cost                  => l_calculated_raw_cost
                           ,x_burdened_cost             => l_calculated_burdened_cost
                           ,x_pm_product_code           => p_pm_product_code
                           ,x_error_code                => l_err_code
                           ,x_error_message             => l_err_message
                           --Added the parameter as part of changes to AMG due to finplan model
                           ,x_txn_currency_code         => l_txn_currency_code_tbl(i));

                     IF l_err_code > 0
                     THEN

                          IF l_context = l_context_budget
                          THEN
                               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                               THEN

                                    IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                                    THEN
                                        pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code => 'PA_CALC_BURDENED_COST_FAILED'
                                         ,p_msg_attribute    => 'CHANGE'
                                         ,p_resize_flag      => 'Y'
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
                                         ,p_resize_flag      => 'Y'
                                         ,p_msg_context      => 'BUDG'
                                         ,p_attribute1       => l_amg_project_rec.segment1
                                         ,p_attribute2       => ''
                                         ,p_attribute3       => p_budget_type_code
                                         ,p_attribute4       => ''
                                         ,p_attribute5       => '');
                                    END IF;

                               END IF;
                          ELSE
                               PA_UTILS.ADD_MESSAGE(
                                      p_app_short_name  => 'PA'
                                     ,p_msg_name        => 'PA_FP_CALC_BURD_COST_FAILED'
                                     ,p_token1          => 'PROJECT'
                                     ,p_value1          => l_amg_project_rec.segment1
                                     ,p_token2          => 'TASK'
                                     ,p_value2          => l_task_name
                                     ,p_token3          => 'PLAN_TYPE'
                                     ,p_value3          => l_fin_plan_type_name
                                     ,p_token4          => 'SOURCE_NAME'
                                     ,p_value4          => l_resource_name_tbl(i)
                                     ,p_token5          => 'START_DATE'
                                     ,p_value5          => l_start_date_tbl(i)
                                     );
                          END IF;

                          p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_ERROR;
                          p_multiple_task_msg   := 'F';
                          --   RAISE FND_API.G_EXC_ERROR;

                     ELSIF l_err_code < 0
                     THEN

                           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                           THEN

                               FND_MSG_PUB.add_exc_msg
                                   (  p_pkg_name       => 'PA_CLIENT_EXTN_BUDGET'
                                   ,  p_procedure_name => 'CALC_BURDENED_COST'
                                   ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                           END IF;

                           p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                     END IF;

                           /* re derive the burden cost rate override after calling the client extn  Do it only for finplan model*/
                    if l_fin_plan_type_id is not null then
                           IF l_version_type in ('ALL','COST') Then
                               If NVl(l_calculated_burdened_cost,0) <> NVl(l_txn_burdened_cost_tbl(i),0) Then
                                         l_calculated_burdened_cost := pa_currency.round_trans_currency_amt1(l_calculated_burdened_cost,l_txn_currency_code_tbl(i));
                                       If nvl(l_quantity_tbl(i),0) <> 0 Then
                                       --Bug 5006031 Issue 8
                                            If l_rate_based_flag_tbl(i) = 'Y' Then
                                                 If l_calculated_burdened_cost = 0 OR l_calculated_burdened_cost IS NULL then
                                                   l_burden_cst_rate_override_tbl(i) := 0;
                                                 Else
                                              l_burden_cst_rate_override_tbl(i) := l_calculated_burdened_cost/l_quantity_tbl(i);
                                              End If;
                                            End If;
                                         --l_display_quantity_tbl(i) := l_quantity_tbl(i); --IPM Arch Enhancement Bug 4865563
                                       End if;
                               End if;
                           END IF;
                   end if; --if l_fin_plan_type_id is not null
                END IF;

                IF  (p_calc_revenue_yn = 'Y'   AND
                     l_version_type <> PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST)
                THEN

                     Pa_client_Extn_Budget.Calc_revenue
                         ( x_budget_version_id         => l_budget_version_id
                          ,x_project_id                => l_project_id
                          ,x_task_id                   => l_task_id_tbl(i)
                          ,x_resource_list_member_id   => l_resource_list_member_id_tbl(i)
                          ,x_resource_list_id          => l_resource_list_id_tbl(i)
                          ,x_resource_id               => l_resource_id_tbl(i)
                          ,x_start_date                => l_start_date_tbl(i)
                          ,x_end_date                  => l_end_date_tbl(i)
                          ,x_period_name               => l_period_name_tbl(i)
                          ,x_quantity                  => l_quantity_tbl(i)
                          ,x_revenue                   => l_calculated_revenue
                          ,x_pm_product_code           => p_pm_product_code
                          ,x_error_code                => l_err_code
                          ,x_error_message             => l_err_message
                          --Added the parameter as part of changes to AMG due to finplan model
                          ,x_txn_currency_code         => l_txn_currency_code_tbl(i));


                      IF l_err_code > 0
                      THEN

                          IF l_context = l_context_budget
                          THEN
                               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                               THEN

                                   IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                                   THEN
                                       pa_interface_utils_pub.map_new_amg_msg
                                       ( p_old_message_code => 'PA_CALC_REVENUE_FAILED'
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

                               END IF;
                          ELSE
                               PA_UTILS.ADD_MESSAGE(
                                      p_app_short_name  => 'PA'
                                     ,p_msg_name        => 'PA_FP_CALC_REVENUE_FAILED'
                                     ,p_token1          => 'PROJECT'
                                     ,p_value1          => l_amg_project_rec.segment1
                                     ,p_token2          => 'TASK'
                                     ,p_value2          => l_task_name
                                     ,p_token3          => 'PLAN_TYPE'
                                     ,p_value3          => l_fin_plan_type_name
                                     ,p_token4          => 'SOURCE_NAME'
                                     ,p_value4          => l_resource_name_tbl(i)
                                     ,p_token5          => 'START_DATE'
                                     ,p_value5          => l_start_date_tbl(i)
                                     );
                          END IF;

                          p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_ERROR;
                          p_multiple_task_msg   := 'F';
                          --  RAISE FND_API.G_EXC_ERROR;

                      ELSIF l_err_code < 0
                      THEN

                           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                           THEN

                               FND_MSG_PUB.add_exc_msg
                                   (  p_pkg_name       => 'PA_CLIENT_EXTN_BUDGET'
                                   ,  p_procedure_name => 'CALC_REVENUE'
                                   ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                           END IF;

                           p_calc_budget_lines_out(l_line_ctr).return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      END IF;

                     /* rederive the override rates */
                    if l_fin_plan_type_id is not null then
                           If l_version_type in ('ALL','REVENUE') Then
                                If l_rate_based_flag_tbl(i) = 'N' Then
                                        If NVL(l_calculated_revenue,0) <> NVL(l_txn_revenue_tbl(i),0) Then
                                 l_calculated_revenue := pa_currency.round_trans_currency_amt1(l_calculated_revenue, l_txn_currency_code_tbl(i));
                                           If l_version_type = 'REVENUE' Then
                                                l_quantity_tbl(i) := l_calculated_revenue;
                                                l_display_quantity_tbl(i) := null;  --IPM Arch Enhancements Bug 4865563
                                    l_bill_rate_override_tbl(i) := 1;
                                           Else
                                                If nvl(l_quantity_tbl(i),0) <> 0 Then
                                                   l_bill_rate_override_tbl(i) := l_calculated_revenue/l_quantity_tbl(i);
                                                End If;
                                           End If;
                                        End If;
                                Else
                                        If NVL(l_calculated_revenue,0) <> NVL(l_txn_revenue_tbl(i),0) Then
                                 l_calculated_revenue := pa_currency.round_trans_currency_amt1(l_calculated_revenue,l_txn_currency_code_tbl(i));
                                           If nvl(l_quantity_tbl(i),0) <> 0 Then
                                            --Bug 5006031 Issue 8
                                                 If l_calculated_revenue = 0 OR l_calculated_revenue IS NULL then
                                                   l_bill_rate_override_tbl(i) := 0;
                                                 Else
                                                l_bill_rate_override_tbl(i) := l_calculated_revenue/l_quantity_tbl(i);
                                                 End If;
                                           End If;
                                        End If;
                                End If;
                           End If;
                    end if;  --  if l_fin_plan_type_id is not null
                 END IF;
                /* Bug 5006031 Issue 8 Start - In IPM, RC drives BC and Rev for amount based transactions
                   So, RC cannot be null. BC is copied into RC if RC is null and BC not null.*/
            IF (l_context = l_context_finplan AND l_rate_based_flag_tbl(i) = 'N' AND (l_calculated_raw_cost is null OR l_calculated_raw_cost = 0 )
            AND (l_calculated_burdened_cost IS NOT NULL OR l_calculated_burdened_cost <> 0)) --IPM Arch Enhancments Bug 4865563
            THEN
                IF  (l_txn_raw_cost_tbl(i) is null) then
                    l_calculated_raw_cost := l_calculated_burdened_cost;
                            IF(l_debug_mode='Y') THEN
                                pa_debug.g_err_stage := 'Assigning BC to RC. When BC is entered by the user, BC is copied to RC ';
                                pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                            END IF;
                 Elsif l_txn_raw_cost_tbl(i) is not null THEN
                     l_calculated_burdened_cost := null;
                     l_calculated_revenue       := null;
                           IF(l_debug_mode='Y') THEN
                               pa_debug.g_err_stage := 'When existing RC is nulled out, BC and Rev are also nulled out';
                               pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                            END IF;
                  End IF;
                END IF;
                /* Bug 5006031 Issue 8 End */
                else ----if plan_class_code = 'FORECAST' and budget_version_info_rec.etc_start_date > l_start_date_tbl(i))
                          l_bdgt_lines_skip_flag := 'Y';
                end if; --if plan_class_code = 'FORECAST' and budget_version_info_rec.etc_start_date > l_start_date_tbl(i))


                 -- Populate the budget lines out table with the calculated amounts.

                 p_calc_budget_lines_out(l_line_ctr).quantity                 := l_quantity_tbl(i);
                 p_calc_budget_lines_out(l_line_ctr).display_quantity         := l_display_quantity_tbl(i); --IPM Arch Enhancement Bug 4865563
                 p_calc_budget_lines_out(l_line_ctr).calculated_raw_cost      := l_calculated_raw_cost;
                 p_calc_budget_lines_out(l_line_ctr).calculated_burdened_cost := l_calculated_burdened_cost;
                 p_calc_budget_lines_out(l_line_ctr).calculated_revenue       := l_calculated_revenue;

                 -- PC and PFC amounts would be populated only if update_flag = 'Y'
                 p_calc_budget_lines_out(l_line_ctr).project_raw_cost         := NULL;
                 p_calc_budget_lines_out(l_line_ctr).project_burdened_cost    := NULL;
                 p_calc_budget_lines_out(l_line_ctr).project_revenue          := NULL;
                 p_calc_budget_lines_out(l_line_ctr).projfunc_raw_cost        := NULL;
                 p_calc_budget_lines_out(l_line_ctr).projfunc_burdened_cost   := NULL;
                 p_calc_budget_lines_out(l_line_ctr).projfunc_revenue         := NULL;

                 -- Raw_cost, Burdened_cost, Revnue Pl/sql tables should be updated with the calculated amounts
                 -- to enable mass update out of the pl/sql loop

                 l_txn_raw_cost_tbl(i)          :=   l_calculated_raw_cost;
                 l_txn_burdened_cost_tbl(i)     :=   l_calculated_burdened_cost;
                 l_txn_revenue_tbl(i)           :=   l_calculated_revenue;

           END LOOP; -- PL/SQL Table loop

           -- Bulk update the budget lines if update flag is set.

           IF p_update_db_flag = 'Y' THEN
             IF p_multiple_task_msg <> 'F' THEN
               IF l_context = l_context_budget
               THEN
                    FORALL i IN l_rowid_tbl.first .. l_rowid_tbl.last
                    UPDATE    pa_budget_lines
                    SET       raw_cost             =    l_txn_raw_cost_tbl(i),
                              burdened_cost        =    l_txn_burdened_cost_tbl(i),
                              revenue              =    l_txn_revenue_tbl(i),
                              last_update_date     =    SYSDATE,
                              last_updated_by      =    G_USER_ID,
                              last_update_login    =    G_LOGIN_ID
                    WHERE     rowid                =    l_rowid_tbl(i);
               ELSE
                    FORALL i IN l_rowid_tbl.first .. l_rowid_tbl.last
                    UPDATE    pa_budget_lines
                    SET       quantity                  =    l_quantity_tbl(i),
                              display_quantity          =    l_display_quantity_tbl(i), --IPM Arch Enhancements Bug 4865563
                              txn_raw_cost              =    l_txn_raw_cost_tbl(i),
                              txn_burdened_cost         =    l_txn_burdened_cost_tbl(i),
                              txn_revenue               =    l_txn_revenue_tbl(i),
                              txn_cost_rate_override    =    decode(l_rw_cost_rate_override_tbl(i), null, txn_cost_rate_override,
                                                                    l_rw_cost_rate_override_tbl(i)),
                              burden_cost_rate_override =    decode(l_burden_cst_rate_override_tbl(i), null, burden_cost_rate_override,
                                                                    l_burden_cst_rate_override_tbl(i)),
                              txn_bill_rate_override    =    decode (l_bill_rate_override_tbl(i), null, txn_bill_rate_override,
                                                                     l_bill_rate_override_tbl(i)),
                              last_update_date          =    SYSDATE,
                              last_updated_by           =    G_USER_ID,
                              last_update_login         =    G_LOGIN_ID
                    WHERE     rowid                     =    l_rowid_tbl(i);
               END IF;
             END IF;
           END IF;
         END IF; -- if any records are fetched

         EXIT WHEN nvl(l_rowid_tbl.last,0) < l_plsql_max_array_size;
    END LOOP;
    CLOSE l_resource_assignment_csr;

    IF p_multiple_task_msg = 'F'
    THEN
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF p_update_db_flag = 'Y' THEN

         IF l_context = l_context_budget THEN --Bug 2863564

              -- Bug 2863564
              -- Call to MRC apis should be done only in case of old 'BUDGETS' model
              -- for NEW Financial Planning Model, this would be taken care by
              -- the api pa_fp_edit_line_pkg. PROCESS_BDGTLINES_FOR_VERSION

              -- Bug Fix: 4569365. Removed MRC code.
              /*
              IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL
              THEN
                     PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                               (x_return_status => p_return_status,
                                x_msg_count     => p_msg_count,
                                x_msg_data      => p_msg_data);
              END IF;

              IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                 PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A'
              THEN
                   PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                         ( p_fin_plan_version_id    =>     l_budget_version_id
                          ,p_entire_version         =>     'Y'
                          ,x_return_status          =>     p_return_status
                          ,x_msg_count              =>     p_msg_count
                          ,x_msg_data               =>     p_msg_data);
              END IF;

              IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF(l_debug_mode='Y') THEN
                      pa_debug.g_err_stage := 'MRC failed';
                      pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              */
              --Summarizing the totals in the table pa_budget_versions

              PA_BUDGET_UTILS.summerize_project_totals
                       (x_budget_version_id  =>  l_budget_version_id,
                        x_err_code           =>  l_err_code,
                        x_err_stage          =>  l_err_stage,
                        x_err_stack          =>  l_err_stack);

              IF l_err_code > 0
              THEN

                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN

                       IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                       THEN
                           pa_interface_utils_pub.map_new_amg_msg
                           ( p_old_message_code => 'PA_SUMMERIZE_TOTALS_FAILED'
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

                   END IF;

                   IF(l_debug_mode='Y') THEN
                         pa_debug.g_err_stage := 'summerize_project_totals api failed';
                         pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;

              ELSIF l_err_code < 0
              THEN

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN

                      FND_MSG_PUB.add_exc_msg
                          (  p_pkg_name       => 'PA_BUDGET_UTILS'
                          ,  p_procedure_name => 'SUMMERIZE_PROJECT_TOTALS'
                          ,  p_error_text     => 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );

                  END IF;

                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'summerize_project_totals api failed with unexpected error ';
                        pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

              END IF;

         ELSIF l_context = l_context_finplan THEN

             -- Bug 2863564
             -- Call 'PROCESS_BDGTLINES_FOR_VERSION' api
             -- This api does the final processing of budget lines data for a budget version.
             -- It includes computing the MC amounts, creating MRC lines if required and
             -- rolling up budget lines data, resource_assignments data and period denorm data.

/*             PA_FP_EDIT_LINE_PKG.PROCESS_BDGTLINES_FOR_VERSION
                (  p_budget_version_id     =>  l_budget_version_id
                  ,p_calling_context       =>  PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
                  ,x_return_status         =>  p_return_status
                  ,x_msg_count             =>  p_msg_count
                  ,x_msg_data              =>  p_msg_data );

             IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                  -- Error message is not added here as the api lock_unlock_version
                  -- adds the message to stack
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Failed in locking the version';
                        pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;*/

     /* Call PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY for the MC conversions. */


        PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
                    ( p_budget_version_id  => l_budget_version_id
                     ,p_entire_version     => 'Y'
                     ,x_return_status      => p_return_status
                     ,x_msg_count          => p_msg_count
                     ,x_msg_data           => p_msg_data);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Call to PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY errored... ';
               pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        --IPM Architecture Enhancement - Start

        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                                   (P_BUDGET_VERSION_ID              => l_budget_version_id,
                                    X_FP_COLS_REC                    => l_fp_cols_rec,
                                    X_RETURN_STATUS                  => p_return_status,
                                    X_MSG_COUNT                      => p_msg_count,
                                    X_MSG_DATA                       => p_msg_data);

        IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                     IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'Error in PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                                pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        pa_res_asg_currency_pub.maintain_data
           (p_fp_cols_rec           => l_fp_cols_rec,
            p_calling_module        => 'AMG_API',
            p_rollup_flag           => 'Y',
            p_version_level_flag    => 'Y',
            x_return_status         => p_return_status,
            x_msg_data              => p_msg_data,
            x_msg_count             => p_msg_count );

        IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         --IPM Architecture Enhancement - End

      /* Call the rollup API to rollup the amounts. */
      PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION(
                 p_budget_version_id => l_budget_version_id
                ,p_entire_version    => 'Y'
                ,x_return_status     => p_return_status
                ,x_msg_count         => p_msg_count
                ,x_msg_data          => p_msg_data    ) ;


     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Call to PA_FP_ROLLUP_PKG errored... ';
             pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     -- Bug Fix: 4569365. Removed MRC code.
     /* Check if MRC is enabled and Call MRC API */
     /*
     IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
        PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                   (x_return_status      => p_return_status,
                    x_msg_count          => p_msg_count,
                    x_msg_data           => p_msg_data);
     END IF;

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Unexpected exception in checking MRC Install '||sqlerrm;
             pa_debug.write('Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
         PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

         PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                (p_fin_plan_version_id => l_budget_version_id,
                 p_entire_version      => 'Y',
                 x_return_status       => p_return_status,
                 x_msg_count           => p_msg_count,
                 x_msg_data            => p_msg_data);
      END IF;

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Unexpected exception in MRC API '||sqlerrm;
             pa_debug.write('Calculate_Amounts: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */

         -- populating the l_budget_version_id_tbl with p_budget_version_id
         l_budget_version_id_tbl := SYSTEM.pa_num_tbl_type(l_budget_version_id);

         -- Call PJI delete api first to delete existing summarization data
         PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
                 p_fp_version_ids   => l_budget_version_id_tbl,
                 x_return_status    => p_return_status,
                 x_msg_code         => p_msg_data);

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                    p_msg_name            => p_msg_data);
               RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Call PLAN_CREATE to create summarization data as per the new RBS
         PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
               p_fp_version_ids   => l_budget_version_id_tbl,
               x_return_status    => p_return_status,
               x_msg_code         => p_msg_data);

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                    p_msg_name            => p_msg_data);
               RAISE FND_API.G_EXC_ERROR;
         END IF;


             -- Bug 2863564 We need to unlock the version

             -- Fetch the record version number of the plan version
             l_record_version_number :=
                      PA_FIN_PLAN_UTILS.RETRIEVE_RECORD_VERSION_NUMBER(l_budget_version_id);

             PA_FIN_PLAN_PVT.LOCK_UNLOCK_VERSION
                  ( p_budget_version_id       => l_budget_version_id
                   ,p_record_version_number   => l_record_version_number
                   ,p_action                  => 'U'
                   ,p_user_id                 => FND_GLOBAL.User_id
                   ,p_person_id               => NULL
                   ,x_return_status           => p_return_status
                   ,x_msg_count               => p_msg_count
                   ,x_msg_data                => p_msg_data);

             IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                  -- Error message is not added here as the api lock_unlock_version
                  -- adds the message to stack
                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'Failed in Unlocking the version';
                        pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;

             -- We need to populate the PC, PFC amounts also in the OUT table
             -- in the context of new budgets model. So, open the
             -- resource_assignments_cur and repopulate the complete data.
             -- NOTE: If there had been any error in the calculation of amounts
             -- by the client extension apis, error would have been raised by now
             -- Since the program execution has come till here, we can populate
             -- return status success for each budget line fetched.

             -- Delete the existing data
             p_calc_budget_lines_out.delete;

             -- Intialise l_line_ctr to zero once again
             l_line_ctr := 0;

             OPEN l_resource_assignment_csr (l_budget_version_id,l_context);
             LOOP

                  FETCH l_resource_assignment_csr BULK COLLECT INTO
                      l_rowid_tbl
                     ,l_budget_line_id_tbl
                     ,l_txn_currency_code_tbl
                     ,l_res_assignment_id_tbl
                     ,l_task_id_tbl
                     ,l_rate_based_flag_tbl
                     ,l_resource_list_id_tbl
                     ,l_resource_list_member_id_tbl
                     ,l_resource_id_tbl
                     ,l_resource_name_tbl
                     ,l_start_date_tbl
                     ,l_end_date_tbl
                     ,l_period_name_tbl
                     ,l_quantity_tbl
                     ,l_display_quantity_tbl --IPM Arch Enhancement Bug 4865563
                     ,l_txn_raw_cost_tbl
                     ,l_txn_burdened_cost_tbl
                     ,l_txn_revenue_tbl
                     ,l_project_raw_cost_tbl
                     ,l_project_burdened_cost_tbl
                     ,l_project_revenue_tbl
                     ,l_projfunc_raw_cost_tbl
                     ,l_projfunc_burdened_cost_tbl
                     ,l_projfunc_revenue_tbl
                  LIMIT l_plsql_max_array_size;

                  IF(l_debug_mode='Y') THEN
                        pa_debug.g_err_stage := 'fetched ' || sql%rowcount || ' records';
                        pa_debug.write( 'Calculate_Amounts'||g_module_name,pa_debug.g_err_stage,l_debug_level5);
                  END IF;

                  IF  NVL(l_rowid_tbl.last,0) >= 1 THEN
                     FOR  i IN l_rowid_tbl.first .. l_rowid_tbl.last
                     LOOP

                          l_line_ctr := l_line_ctr + 1;

                          p_calc_budget_lines_out(l_line_ctr).pa_task_id               := l_task_id_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).pm_task_reference        := l_pm_task_reference;
                          p_calc_budget_lines_out(l_line_ctr).resource_alias           := l_resource_name_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).resource_list_member_id  := l_resource_list_member_id_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).budget_start_date        := l_start_date_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).budget_end_date          := l_end_date_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).period_name              := l_period_name_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).quantity                 := l_quantity_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).display_quantity         := l_display_quantity_tbl(i); --IPM Arch Enhancement Bug 4865563
                          p_calc_budget_lines_out(l_line_ctr).txn_currency_code        := l_txn_currency_code_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).return_status            := FND_API.G_RET_STS_SUCCESS;
                          p_calc_budget_lines_out(l_line_ctr).calculated_raw_cost      := l_txn_raw_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).calculated_burdened_cost := l_txn_burdened_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).calculated_revenue       := l_txn_revenue_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).project_raw_cost         := l_project_raw_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).project_burdened_cost    := l_project_burdened_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).project_revenue          := l_project_revenue_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).projfunc_raw_cost        := l_projfunc_raw_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).projfunc_burdened_cost   := l_projfunc_burdened_cost_tbl(i);
                          p_calc_budget_lines_out(l_line_ctr).projfunc_revenue         := l_projfunc_revenue_tbl(i);

                     END LOOP;
                  END IF;

                  EXIT WHEN  NVL(l_rowid_tbl.last,0) < l_plsql_max_array_size;
             END LOOP;
             CLOSE l_resource_assignment_csr;
         END IF;

    END IF;

    if( l_bdgt_lines_skip_flag = 'Y')
    then
           PA_UTILS.ADD_MESSAGE
               ( p_app_short_name => 'PA'
                ,p_msg_name       => 'PA_FP_ETC_BL_DATE'
               );
    end if;


    IF FND_API.TO_BOOLEAN( p_commit )
    THEN
           COMMIT;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
             ROLLBACK TO calculate_amounts_pub;

             p_return_status := FND_API.G_RET_STS_ERROR;

             FND_MSG_PUB.Count_And_Get
               (p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

             ROLLBACK TO calculate_amounts_pub;

             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

             FND_MSG_PUB.Count_And_Get
                 (p_count    =>  p_msg_count ,
                  p_data     =>  p_msg_data  );
    WHEN OTHERS
    THEN
         ROLLBACK TO calculate_amounts_pub;

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.add_exc_msg
              ( p_pkg_name     => G_PKG_NAME
               ,p_procedure_name => l_api_name );
         END IF;

         FND_MSG_PUB.Count_And_Get
             (p_count    =>  p_msg_count ,
              p_data     =>  p_msg_data  );

END Calculate_Amounts;


----------------------------------------------------------------------------------------
--Name:               Init_Calculate_Amounts
--Type:               Procedure
--Description:        This procedure can be used to as part of load/exec/fetch concept
--
--
--Called subprograms:
--
--
--
--
--History:
--    AUTUMN-1996        R. Krishnamurthy       Created
--
--
PROCEDURE Init_Calculate_Amounts IS
BEGIN
    FND_MSG_PUB.Initialize;
    --  Initialize global table and record types
    G_calc_budget_lines_tbl_count   := 0;
    G_calc_budget_lines_out_tbl.delete;
END Init_Calculate_Amounts;


----------------------------------------------------------------------------------------
--Name:               Execute_Calculate_Amounts
--Type:               Procedure
--Description:        This procedure can be used to as part of load/exec/fetch concept
--
--
--Called subprograms:
--
--
--
--
--History:
--    AUTUMN-1996        R. Krishnamurthy       Created
--    25-MAR-2003        Rajagopal              Modified for New Fin Plan Model
--
PROCEDURE Execute_Calculate_Amounts
( p_api_version_number          IN   NUMBER
 ,p_commit                      IN   VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list               IN   VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_tot_budget_lines_calculated OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_product_code             IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference        IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code            IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_raw_cost_yn            IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_burdened_cost_yn       IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_calc_revenue_yn             IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_update_db_flag              IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  -- Bug 2863564 Parameters required for new Fin Plan Model
 ,p_budget_version_id           IN   pa_budget_versions.budget_version_id%TYPE
 ,p_fin_plan_type_id            IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name          IN   pa_fin_plan_types_tl.name%TYPE
 ,p_version_type                IN   pa_budget_versions.version_type%TYPE
 ,p_budget_version_number       IN   pa_budget_versions.version_number%TYPE
) IS

   l_api_name           CONSTANT   VARCHAR2(30) := 'Execute_Calculate_Amounts';
   --Bug 2863564 l_return_status      VARCHAR2(1);

BEGIN
--  Standard begin of API savepoint
    SAVEPOINT execute_calculate_amounts;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN
    FND_MSG_PUB.initialize;
    END IF;
--  Set API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_tot_budget_lines_calculated := 0;

    Calculate_Amounts
     ( p_api_version_number      => p_api_version_number
      ,p_commit                  => p_commit
      ,p_init_msg_list           => p_init_msg_list
      ,p_msg_count               => p_msg_count
      ,p_msg_data                => p_msg_data
      ,p_return_status           => p_return_status
      ,p_pm_product_code         => p_pm_product_code
      ,p_pa_project_id           => p_pa_project_id
      ,p_pm_project_reference    => p_pm_project_reference
      ,p_budget_type_code        => p_budget_type_code
      ,p_calc_raw_cost_yn        => p_calc_raw_cost_yn
      ,p_calc_burdened_cost_yn   => p_calc_burdened_cost_yn
      ,p_calc_revenue_yn         => p_calc_revenue_yn
      ,p_update_db_flag          => p_update_db_flag
      ,p_calc_budget_lines_out   => G_calc_budget_lines_out_tbl
      -- Bug 2863564 new parameters added
      ,p_fin_plan_type_name      => p_fin_plan_type_name
      ,p_fin_plan_type_id        => p_fin_plan_type_id
      ,p_budget_version_number   => p_budget_version_number
      ,p_version_type            => p_version_type
      ,p_budget_version_id       => p_budget_version_id
     );


    IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF p_return_status = FND_API.G_RET_STS_ERROR
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF G_calc_budget_lines_out_tbl.EXISTS(1) THEN
       p_tot_budget_lines_calculated := G_calc_budget_lines_out_tbl.COUNT;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
       COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO execute_calculate_amounts;
         p_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
              (   p_count     =>  p_msg_count ,
                  p_data      =>  p_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO execute_calculate_amounts;
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
              (   p_count     =>  p_msg_count ,
                  p_data      =>  p_msg_data  );
    WHEN OTHERS THEN
         ROLLBACK TO execute_calculate_amounts;
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.add_exc_msg
                 (  p_pkg_name       => G_PKG_NAME
                 ,  p_procedure_name => l_api_name );
         END IF;

         FND_MSG_PUB.Count_And_Get
         (   p_count     =>  p_msg_count ,
             p_data      =>  p_msg_data  );
END Execute_Calculate_Amounts;


----------------------------------------------------------------------------------------
--Name:               fetch_calculate_amounts
--Type:               Procedure
--Description:        This procedure can be used to as part of load/exec/fetch concept
--
--
--Called subprograms:
--
--
--
--
--History:
--    AUTUMN-1996        R. Krishnamurthy       Created
--
--
PROCEDURE fetch_calculate_amounts
( p_api_version_number        IN      NUMBER
 ,p_init_msg_list             IN      VARCHAR2    := FND_API.G_FALSE
 ,p_line_index                IN      NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_return_status             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_task_id                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_pm_task_reference         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date         OUT     NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date           OUT     NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_period_name               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_resource_list_member_id   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_quantity                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_resource_alias            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_calculated_raw_cost       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_burdened_cost  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_calculated_revenue        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,p_line_return_status        OUT     NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_api_name       CONSTANT   VARCHAR2(30)   := 'fetch_calculate_amounts';

l_index             NUMBER;
i                   NUMBER;

BEGIN

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

--  Check index value,
--  when they don't provide an index we will error out

    IF p_line_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    OR p_line_index IS NULL
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
               pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_BUGDET_LINE_INDEX_MISSING'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'Y'
                ,p_msg_context      => 'GENERAL'
                ,p_attribute1       => ''
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_index := p_line_index;
    END IF;

-- Fix: 03-FEB-97, jwhite
-- Changed references to correct global table -------------------------------

--assign global table fields to the outgoing parameter
    IF G_calc_budget_lines_out_tbl.EXISTS(l_index) THEN
         p_pa_task_id        := G_calc_budget_lines_out_tbl(l_index).pa_task_id;
         p_pm_task_reference :=
                 G_calc_budget_lines_out_tbl(l_index).pm_task_reference;
         p_budget_start_date :=
                 G_calc_budget_lines_out_tbl(l_index).budget_start_date;
         p_budget_end_date   := G_calc_budget_lines_out_tbl(l_index).budget_end_date;
         p_period_name       := G_calc_budget_lines_out_tbl(l_index).period_name;
         p_resource_list_member_id         := G_calc_budget_lines_out_tbl(l_index).resource_list_member_id;
         p_quantity          := G_calc_budget_lines_out_tbl(l_index).quantity;
         p_resource_alias    := G_calc_budget_lines_out_tbl(l_index).resource_alias;
         p_calculated_raw_cost :=
                 G_calc_budget_lines_out_tbl(l_index).calculated_raw_cost;
         p_calculated_burdened_cost :=
                 G_calc_budget_lines_out_tbl(l_index).calculated_burdened_cost;
         p_calculated_revenue :=
                 G_calc_budget_lines_out_tbl(l_index).calculated_revenue;
         p_line_return_status := G_calc_budget_lines_out_tbl(l_index).return_status;

    END IF;
-- ----------------------------------------------------------------------------------------

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
      p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.add_exc_msg
              (  p_pkg_name       => G_PKG_NAME
              ,  p_procedure_name => l_api_name );

      END IF;

END fetch_calculate_amounts;


----------------------------------------------------------------------------------------
--Name:               Clear_Calculate_Amounts
--Type:               Procedure
--Description:        This procedure can be used to as part of load/exec/fetch concept
--
--
--Called subprograms:
--
--
--
--
--History:
--    AUTUMN-1996        R. Krishnamurthy       Created
--
--
PROCEDURE Clear_Calculate_Amounts IS
BEGIN
   Init_Calculate_Amounts;
END Clear_Calculate_Amounts;

----------------------------------------------------------------------------------------
--Name:               fetch_calculate_amounts
--Type:               Procedure
--Description:        This procedure can be used to as part of load/exec/fetch concept
--
--
--Called subprograms:
--                    fetch_calculate_amounts
--
--History:
--    24-MAR-2003     Rajagopal      Created
--
PROCEDURE fetch_calculate_amounts
     ( p_api_version_number         IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE
      ,p_line_index                 IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ,p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_pa_task_id                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_pm_task_reference         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_budget_start_date         OUT   NOCOPY DATE --File.Sql.39 bug 4440895
      ,p_budget_end_date           OUT   NOCOPY DATE --File.Sql.39 bug 4440895
      ,p_period_name               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_resource_list_member_id   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_quantity                  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_resource_alias            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_calculated_raw_cost       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_calculated_burdened_cost  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_calculated_revenue        OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_line_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_txn_currency_code         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,p_project_raw_cost          OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_project_burdened_cost     OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_project_revenue           OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_projfunc_raw_cost         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_projfunc_burdened_cost    OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_projfunc_revenue          OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,p_display_quantity          OUT   NOCOPY NUMBER  --IPM Arch Enhancement Bug 4865563
      ) IS

l_api_name       CONSTANT   VARCHAR2(30)   := 'fetch_calculate_amounts';

BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Call the existing  fetch_calculate_amounts api

     PA_BUDGET_PUB.fetch_calculate_amounts
          ( p_api_version_number           =>   p_api_version_number
           ,p_init_msg_list                =>   p_init_msg_list
           ,p_line_index                   =>   p_line_index
           ,p_return_status                =>   p_return_status
           ,p_pa_task_id                   =>   p_pa_task_id
           ,p_pm_task_reference            =>   p_pm_task_reference
           ,p_budget_start_date            =>   p_budget_start_date
           ,p_budget_end_date              =>   p_budget_end_date
           ,p_period_name                  =>   p_period_name
           ,p_resource_list_member_id      =>   p_resource_list_member_id
           ,p_quantity                     =>   p_quantity
           ,p_resource_alias               =>   p_resource_alias
           ,p_calculated_raw_cost          =>   p_calculated_raw_cost
           ,p_calculated_burdened_cost     =>   p_calculated_burdened_cost
           ,p_calculated_revenue           =>   p_calculated_revenue
           ,p_line_return_status           =>   p_line_return_status  );

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         RAISE FND_API.G_EXC_ERROR;

     END IF;

     -- Fetch the txn currency code of the budget line

     IF G_calc_budget_lines_out_tbl.EXISTS(p_line_index) THEN

          p_txn_currency_code      := G_calc_budget_lines_out_tbl(p_line_index).txn_currency_code;
          p_project_raw_cost       := G_calc_budget_lines_out_tbl(p_line_index).project_raw_cost;
          p_project_burdened_cost  := G_calc_budget_lines_out_tbl(p_line_index).project_burdened_cost ;
          p_project_revenue        := G_calc_budget_lines_out_tbl(p_line_index).project_revenue;
          p_projfunc_raw_cost      := G_calc_budget_lines_out_tbl(p_line_index).projfunc_raw_cost;
          p_projfunc_burdened_cost := G_calc_budget_lines_out_tbl(p_line_index).projfunc_burdened_cost;
          p_projfunc_revenue       := G_calc_budget_lines_out_tbl(p_line_index).projfunc_revenue;
          p_display_quantity       := G_calc_budget_lines_out_tbl(p_line_index).display_quantity;  --IPM Arch Enhancement Bug 4865563

     END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR
   THEN
        p_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
                (  p_pkg_name       => G_PKG_NAME
                  ,p_procedure_name => l_api_name );

        END IF;
END fetch_calculate_amounts;

PROCEDURE CREATE_DRAFT_FINPLAN
 ( p_api_version_number              IN NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_commit                              IN VARCHAR2          := FND_API.G_FALSE
  ,p_init_msg_list                       IN VARCHAR2          := FND_API.G_FALSE
  ,p_pm_product_code                 IN pa_budget_versions.pm_product_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_finplan_reference            IN pa_budget_versions.pm_budget_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference            IN pa_projects_all. PM_PROJECT_REFERENCE%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_id                   IN pa_budget_versions.project_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_id                IN pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_name              IN pa_fin_plan_types_vl.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_version_type                    IN pa_budget_versions.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_time_phased_code                IN pa_proj_fp_options.cost_time_phased_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_name              IN pa_resource_lists.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_id                IN pa_budget_versions.resource_list_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_level_code             IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_plan_in_multi_curr_flag         IN pa_proj_fp_options.plan_in_multi_curr_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_budget_version_name             IN pa_budget_versions.version_name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_description                     IN pa_budget_versions.description%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_change_reason_code              IN pa_budget_versions.change_reason_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_raw_cost_flag                   IN pa_fin_plan_amount_sets.raw_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_burdened_cost_flag              IN pa_fin_plan_amount_sets.burdened_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_flag                    IN pa_fin_plan_amount_sets.revenue_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cost_qty_flag                   IN pa_fin_plan_amount_sets.cost_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_qty_flag                IN pa_fin_plan_amount_sets.revenue_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_all_qty_flag                    IN pa_fin_plan_amount_sets.all_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_create_new_curr_working_flag    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_replace_current_working_flag    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_using_resource_lists_flag       IN   VARCHAR2 DEFAULT 'N'
  ,p_finplan_trans_tab               IN pa_budget_pub.FinPlan_Trans_Tab
  ,p_attribute_category              IN pa_budget_versions.attribute_category%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                      IN pa_budget_versions.attribute1%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                      IN pa_budget_versions.attribute2%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                      IN pa_budget_versions.attribute3%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                      IN pa_budget_versions.attribute4%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                      IN pa_budget_versions.attribute5%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                      IN pa_budget_versions.attribute6%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                      IN pa_budget_versions.attribute7%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                      IN pa_budget_versions.attribute8%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                      IN pa_budget_versions.attribute9%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                     IN pa_budget_versions.attribute10%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11                     IN pa_budget_versions.attribute11%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                     IN pa_budget_versions.attribute12%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                     IN pa_budget_versions.attribute13%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                     IN pa_budget_versions.attribute14%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                     IN pa_budget_versions.attribute15%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,x_finplan_version_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT NOCOPY VARCHAR2
  ,x_msg_count                       OUT NOCOPY NUMBER
  ,x_msg_data                        OUT NOCOPY VARCHAR2
 )
 IS


/* SCALAR VARIABLES */
l_task_number                          pa_tasks.task_number%TYPE;
l_fp_options_id                        pa_proj_fp_options.proj_fp_options_id%TYPE;
l_baselined_version_id                 pa_budget_versions.budget_version_id%TYPE;
l_curr_work_version_id                 pa_budget_versions.budget_version_id%TYPE;
l_amount_set_id                        pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_struct_elem_version_id               pa_proj_elem_ver_structure.element_version_id%TYPE;
l_cost_amount_set_id                   pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_rev_amount_set_id                    pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_all_amount_set_id                    pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_created_version_id                   pa_budget_versions.budget_version_id%TYPE;
l_plan_pref_code                       pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_uncat_rlmid                          pa_resource_assignments.resource_list_member_id%TYPE;
l_track_as_labor_flag                  pa_resource_list_members.track_as_labor_flag%TYPE;
l_unit_of_measure                      pa_resource_assignments.unit_of_measure%TYPE;
-- Bug Fix: 4569365. Removed MRC code.
-- l_calling_context                      pa_mrc_finplan.g_calling_module%TYPE := PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT;
l_calling_context                      VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT;

l_plan_tran_context                    VARCHAR2(30);
l_record_version_number                pa_budget_versions.record_version_number%TYPE;
l_mixed_resource_planned_flag          VARCHAR2(1);
l_proj_fp_options_id                   pa_proj_fp_options.proj_fp_options_id%TYPE;
l_CW_version_id                        pa_budget_versions.budget_version_id%TYPE;
l_CW_record_version_number             pa_budget_versions.record_version_number%TYPE;
l_created_ver_rec_ver_num              pa_budget_versions.record_version_number%TYPE;

l_project_id                           PA_PROJECTS_ALL.PROJECT_ID%TYPE;
l_resource_list_name                   PA_RESOURCE_LISTS.NAME%TYPE;
l_resource_list_id                     PA_RESOURCE_LISTS.resource_list_id%TYPE;

l_description                          PA_BUDGET_VERSIONS.description%Type;
l_attribute_category                   PA_BUDGET_VERSIONS.attribute_category%Type;
l_attribute1                           PA_BUDGET_VERSIONS.attribute1%Type;
l_attribute2                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute3                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute4                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute5                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute6                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute7                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute8                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute9                           PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute10                          PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute11                          PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute12                          PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute13                          PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute14                          PA_BUDGET_VERSIONS.attribute2%Type;
l_attribute15                          PA_BUDGET_VERSIONS.attribute2%Type;
l_pm_finplan_reference                 pa_budget_versions.pm_budget_reference%type;
l_change_reason_code                   pa_budget_versions.change_reason_code%type;
l_budget_version_name                  pa_budget_versions.version_name%type;
l_fin_plan_type_id                     pa_fin_plan_types_b.fin_plan_type_id%TYPE ;
l_fin_plan_type_name                   pa_fin_plan_types_vl.name%TYPE ;
l_version_type                         pa_budget_versions.version_type%TYPE ;
l_fin_plan_level_code                  pa_proj_fp_options.cost_fin_plan_level_code%TYPE ;
l_time_phased_code                     pa_proj_fp_options.cost_time_phased_code%TYPE ;

L_RAW_COST_FLAG                        VARCHAR2(1);
L_BURDENED_COST_FLAG                   VARCHAR2(1);
L_REVENUE_FLAG                         VARCHAR2(1);
L_COST_QTY_FLAG                        VARCHAR2(1);
L_REVENUE_QTY_FLAG                     VARCHAR2(1);

L_ALL_QTY_FLAG                         VARCHAR2(1);
L_CREATE_NEW_WORKING_FLAG              VARCHAR2(1);
L_REPLACE_CURRENT_WORKING_FLAG         VARCHAR2(1);
L_USING_RESOURCE_LISTS_FLAG            VARCHAR2(1);

l_plan_in_multi_curr_flag              pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_projfunc_cost_rate_type              pa_proj_fp_options.projfunc_cost_rate_type%TYPE ;
l_projfunc_cost_rate_date_typ          pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE ;
l_projfunc_cost_rate_date              pa_proj_fp_options.projfunc_cost_rate_date%TYPE ;
l_projfunc_rev_rate_type               pa_proj_fp_options.projfunc_rev_rate_type%TYPE ;
l_projfunc_rev_rate_date_typ           pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE;
l_projfunc_rev_rate_date               pa_proj_fp_options.projfunc_rev_rate_date%TYPE ;
l_project_cost_rate_type               pa_proj_fp_options.project_cost_rate_type%TYPE ;
l_project_cost_rate_date_typ           pa_proj_fp_options.project_cost_rate_date_type%TYPE  ;
l_project_cost_rate_date               pa_proj_fp_options.project_cost_rate_date%TYPE ;
l_project_rev_rate_type                pa_proj_fp_options.project_rev_rate_type%TYPE  ;
l_project_rev_rate_date_typ            pa_proj_fp_options.project_rev_rate_date_type%TYPE ;
l_project_rev_rate_date                pa_proj_fp_options.project_rev_rate_date%TYPE ;

/**PLSQL TABLES**/
l_pm_task_reference_tbl       SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_task_elem_version_id_tbl    SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
l_task_number_tbl             SYSTEM.PA_VARCHAR2_100_TBL_TYPE := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
l_project_assignment_id_tbl   SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
l_resource_alias_tbl          SYSTEM.PA_VARCHAR2_80_TBL_TYPE  := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
l_pm_res_asgmt_ref_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_resource_list_member_id_tbl SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
l_pm_product_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_currency_code_tbl           SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_start_date_tbl              SYSTEM.pa_date_tbl_type         := SYSTEM.pa_date_tbl_type();
l_end_date_tbl                SYSTEM.pa_date_tbl_type         := SYSTEM.pa_date_tbl_type();

l_quantity_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_raw_cost_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_burdened_cost_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_revenue_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_fp_version_ids_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

l_attribute_category_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_attribute1_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute2_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute3_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute4_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute5_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute6_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute7_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute8_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute9_tbl         SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute10_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute11_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute12_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute13_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute14_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute15_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute16_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute17_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute18_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute19_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute20_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute21_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute22_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute23_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute24_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute25_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute26_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute27_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute28_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute29_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_attribute30_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();

/*=======================================================+
 | Used to call pa_budget_pvt.get_fin_plan_lines_status. |
 +=======================================================*/
l_budget_lines_in        pa_budget_pub.budget_line_in_tbl_type;
l_budget_lines_out       pa_budget_pub.budget_line_out_tbl_type;

/*===================================================+
 | Used to call pa_budget_pvt.validate_budget_lines. |
 +===================================================*/
l_res_asg_in_tbl         pa_budget_pub.budget_line_in_tbl_type;
l_res_asg_out_tbl        pa_budget_pub.budget_line_out_tbl_type;

l_allow_qty_flag         VARCHAR2(1); -- Bug 3825873 Used to call validate_budget_lines

--fix later
l_pkg_name          VARCHAR2(30)  := 'PA_BUDGET_PUB';
g_module_name       VARCHAR2(100) := 'CREATE_DRAFT_FINPLAN';
l_api_name          VARCHAR2(30)  := 'CREATE_DRAFT_FINPLAN';
l_module_name       VARCHAR2(100) := 'CREATE_DRAFT_FINPLAN';
l_procedure_name    VARCHAR2(30)  := 'CREATE_DRAFT_FINPLAN';

l_debug_mode        VARCHAR2(1);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(150);
l_msg_code          VARCHAR2(2000);
l_msg_index_out     NUMBER;
l_return_status     VARCHAR2(1);

l_user_id           NUMBER :=0;
t_person_id         NUMBER;
t_resource_id       NUMBER;
t_resource_name     VARCHAR2(39);
cnt number:=0;

 -- added for bug Bug 3986129: FP.M Web ADI Dev changes
 l_mfc_cost_type_id_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
 l_etc_method_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
 l_spread_curve_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

 --Added for bug 4224464
 l_budget_amount_code             pa_budget_types.budget_amount_code%type;

 l_version_info_rec           pa_fp_gen_amount_utils.fp_cols;

 --Bug 5475184. In the below set, pt stands for "plan type".
 l_pt_amount_set_id                    pa_proj_fp_options.cost_amount_set_id%TYPE;
 l_pt_raw_cost_flag                    VARCHAR2(1);
 l_pt_burdened_flag                    VARCHAR2(1);
 l_pt_revenue_flag                     VARCHAR2(1);
 l_pt_cost_quantity_flag               VARCHAR2(1);
 l_pt_rev_quantity_flag                VARCHAR2(1);
 l_pt_all_quantity_flag                VARCHAR2(1);
 l_pt_bill_rate_flag                   VARCHAR2(1);
 l_pt_cost_rate_flag                   VARCHAR2(1);
 l_pt_burden_rate_flag                 VARCHAR2(1);


BEGIN

    --Standard begin of API savepoint
    SAVEPOINT create_draft_finplan_pub;

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.set_err_stack('PA_BUDGET_PUB.CREATE_DRAFT_FINPLAN');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF ( l_debug_mode = 'Y' )
    THEN
        pa_debug.set_process(l_procedure_name || 'PLSQL','LOG',l_debug_mode);
        pa_debug.g_err_stage:='Entering CREATE_DRAFT_FINPLAN';
        pa_debug.write('CREATE_DRAFT_FINPLAN: ' || g_module_name,pa_debug.g_err_stage,2);
    END IF;

    l_msg_count := 0;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
    l_module_name :=  'create_draft_finplan' || g_module_name;

    IF ( l_debug_mode = 'Y' )
    THEN
          pa_debug.set_curr_function( p_function   => 'create_draft_finplan'
                                     ,p_debug_mode => l_debug_mode );
    END IF;

    l_resource_list_name :=  p_resource_list_name ;

    IF p_resource_list_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_resource_list_id        :=   NULL;
    ELSE
            l_resource_list_id        :=   p_resource_list_id;
    END IF;


    IF p_fin_plan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_fin_plan_type_id := NULL;
    ELSE
            l_fin_plan_type_id              :=   p_fin_plan_type_id ;
    END IF;

    IF p_fin_plan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_fin_plan_type_name := NULL;
    ELSE
      l_fin_plan_type_name            :=   p_fin_plan_type_name           ;
    END IF;

    IF p_version_type =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_version_type := NULL;
    ELSE
      l_version_type                  :=   p_version_type                 ;
    END IF;

    IF p_fin_plan_level_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_fin_plan_level_code := NULL;
    ELSE
      l_fin_plan_level_code           :=   p_fin_plan_level_code          ;
    END IF;

    IF p_time_phased_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_time_phased_code := NULL;
    ELSE
      l_time_phased_code              :=   p_time_phased_code             ;

    END IF;

    IF p_plan_in_multi_curr_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_plan_in_multi_curr_flag := NULL; --Bug 4586948.
    ELSE
      l_plan_in_multi_curr_flag       :=   p_plan_in_multi_curr_flag      ;
    END IF;

    IF p_raw_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_raw_cost_flag  := 'N';
    ELSE
      l_raw_cost_flag                 :=   p_raw_cost_flag                ;
    END IF;

    IF p_burdened_cost_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_burdened_cost_flag  := 'N';
    ELSE
      l_burdened_cost_flag            :=   p_burdened_cost_flag           ;
    END IF;

    IF p_revenue_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_revenue_flag  := 'N';
    ELSE
      l_revenue_flag                  :=   p_revenue_flag                 ;
    END IF;

    IF p_cost_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_cost_qty_flag  := 'N';
    ELSE
      l_cost_qty_flag                 :=   p_cost_qty_flag                ;
    END IF;

    IF p_revenue_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_revenue_qty_flag  := 'N';
    ELSE
      l_revenue_qty_flag              :=   p_revenue_qty_flag             ;
    END IF;

    IF p_all_qty_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_all_qty_flag  := 'N';
    ELSE
      l_all_qty_flag                  :=   p_all_qty_flag                 ;
    END IF;

    IF p_create_new_curr_working_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_create_new_working_flag  := 'N';
    ELSE
      l_create_new_working_flag       :=   p_create_new_curr_working_flag ;
    END IF;

    IF p_replace_current_working_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_replace_current_working_flag  := 'N';
    ELSE
      l_replace_current_working_flag  :=   p_replace_current_working_flag ;
    END IF;

    IF p_using_resource_lists_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_using_resource_lists_flag  := 'Y';
    ELSE
      l_using_resource_lists_flag  :=   p_using_resource_lists_flag ;
    END IF;

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

    IF p_pm_finplan_reference =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
            l_pm_finplan_reference := NULL;
    ELSE
            l_pm_finplan_reference := p_pm_finplan_reference;
    END IF;

    IF p_pa_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            l_project_id                :=   NULL;
    ELSE
            l_project_id                :=   p_pa_project_id;
    END IF;

    IF p_change_reason_code =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
            l_change_reason_code := NULL;
    ELSE
            l_change_reason_code := p_change_reason_code;
    END IF;
  -- bug 5031071
    IF p_description =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
            l_description := NULL;
    ELSE
            l_description := p_description;
    END IF;



    l_user_id := FND_GLOBAL.User_id;

    pa_budget_pvt.Validate_Header_Info
          ( p_api_version_number            => p_api_version_number
           ,p_budget_version_name           => p_budget_version_name
           ,p_init_msg_list                 => p_init_msg_list
           ,px_pa_project_id                => l_project_id
           ,p_pm_project_reference          => p_pm_project_reference
           ,p_pm_product_code               => p_pm_product_code
           ,p_budget_type_code              => NULL
           ,p_entry_method_code             => NULL
           ,px_resource_list_name           => l_resource_list_name
           ,px_resource_list_id             => l_resource_list_id
           ,px_fin_plan_type_id             => l_fin_plan_type_id
           ,px_fin_plan_type_name           => l_fin_plan_type_name
           ,px_version_type                 => l_version_type
           ,px_fin_plan_level_code          => l_fin_plan_level_code
           ,px_time_phased_code             => l_time_phased_code
           ,px_plan_in_multi_curr_flag      => l_plan_in_multi_curr_flag
           ,px_projfunc_cost_rate_type      => l_projfunc_cost_rate_type
           ,px_projfunc_cost_rate_date_typ  => l_projfunc_cost_rate_date_typ
           ,px_projfunc_cost_rate_date      => l_projfunc_cost_rate_date
           ,px_projfunc_rev_rate_type       => l_projfunc_rev_rate_type
           ,px_projfunc_rev_rate_date_typ   => l_projfunc_rev_rate_date_typ
           ,px_projfunc_rev_rate_date       => l_projfunc_rev_rate_date
           ,px_project_cost_rate_type       => l_project_cost_rate_type
           ,px_project_cost_rate_date_typ   => l_project_cost_rate_date_typ
           ,px_project_cost_rate_date       => l_project_cost_rate_date
           ,px_project_rev_rate_type        => l_project_rev_rate_type
           ,px_project_rev_rate_date_typ    => l_project_rev_rate_date_typ
           ,px_project_rev_rate_date        => l_project_rev_rate_date
           ,px_raw_cost_flag                => l_raw_cost_flag
           ,px_burdened_cost_flag           => l_burdened_cost_flag
           ,px_revenue_flag                 => l_revenue_flag
           ,px_cost_qty_flag                => l_cost_qty_flag
           ,px_revenue_qty_flag             => l_revenue_qty_flag
           ,px_all_qty_flag                 => l_all_qty_flag
           ,p_create_new_curr_working_flag  => l_create_new_working_flag
           ,p_replace_current_working_flag  => l_replace_current_working_flag
           ,p_change_reason_code            => p_change_reason_code
           ,p_calling_module                => 'PA_PM_CREATE_DRAFT_BUDGET'
           ,p_using_resource_lists_flag     => p_using_resource_lists_flag
           ,x_budget_amount_code            => l_budget_amount_code   -- Added for bug 4224464
           ,x_msg_count                     => x_msg_count
           ,x_msg_data                      => x_msg_data
           ,x_return_status                 => x_return_status
          );

          IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
          THEN
               RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                 p_project_id            => l_project_id
                ,p_fin_plan_type_id      => l_fin_plan_type_id
                ,p_version_type          => l_version_type
                ,x_fp_options_id         => l_fp_options_id
                ,x_fin_plan_version_id   => l_curr_work_version_id
                ,x_return_status         => x_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (l_curr_work_version_id IS NOT NULL) THEN

        IF nvl(p_replace_current_working_flag,'N')= 'Y' THEN

              l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                            (p_budget_version_id => l_curr_work_version_id);
              l_user_id := FND_GLOBAL.User_id;
              pa_fin_plan_pvt.lock_unlock_version
                       (p_budget_version_id       => l_curr_work_version_id,
                          p_record_version_number   => l_record_version_number,
                        p_action                  => 'L',
                        p_user_id                 => l_user_id,
                        p_person_id               => NULL,
                        x_return_status           => x_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data
                       );

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Error in lock unlock version - cannot delete working version';
                         pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

              pa_fin_plan_pub.delete_version
                    ( p_project_id            => l_project_id
                           ,p_budget_version_id     => l_curr_work_version_id
                           ,p_record_version_number => l_record_version_number
                           ,x_return_status         => x_return_status
                           ,x_msg_count             => x_msg_count
                           ,x_msg_data              => x_msg_data
                          );
              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS)
              THEN
                  pa_debug.g_err_stage:= 'Could not delete the current working version';
                  IF l_debug_mode = 'Y' THEN
                       pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,
                                                PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              ELSE
                  pa_debug.g_err_stage:= 'Deleted the current working version';
                  IF l_debug_mode = 'Y' THEN
                         pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,
                                  PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                  END IF;
              END IF;
        END IF; --p_replace_current_working_flag = 'Y'
    END IF; -- l_curr_work_version_id IS NOT NULL

    IF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN
           l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY;
    ELSIF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN
          l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY;
    ELSIF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN
          l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME;
    END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Preference code is [' || l_plan_pref_code || ']';
          pa_debug.write(l_procedure_name ||
                      g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

 --Bug 5475184. The below block will be used to get the cost/bill rate flags from the plan type option.
         --These flags will be set for the new plan version that will be created instead of always setting
         --the value 'Y' for these flags in the plan version. Please note that except for these rate flags, other
         --amount flags can be passed as input parameters to this API

         --Get the amount set id from the plan type option.
         SELECT DECODE(l_version_type,
                       PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST, cost_amount_set_id,
                       PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_amount_set_id,
                       PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, all_amount_set_id)
         INTO   l_pt_amount_set_id
         FROM   pa_proj_fp_options
         WHERE  project_id=l_project_id
         AND    fin_plan_type_id=l_fin_plan_type_id
         AND    fin_plan_version_id IS NULL;

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Plan Type amount set id is [' || l_pt_amount_set_id || ']';
              pa_debug.write(l_procedure_name ||
                           g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;

         --Get the plan type flag values
         pa_fin_plan_utils.get_plan_amount_flags (
         p_amount_set_id       => l_pt_amount_set_id,
         x_raw_cost_flag       => l_pt_raw_cost_flag,
         x_burdened_flag       => l_pt_burdened_flag,
         x_revenue_flag        => l_pt_revenue_flag,
         x_cost_quantity_flag  => l_pt_cost_quantity_flag,
         x_rev_quantity_flag   => l_pt_rev_quantity_flag,
         x_all_quantity_flag   => l_pt_all_quantity_flag,
         x_bill_rate_flag      => l_pt_bill_rate_flag,
         x_cost_rate_flag      => l_pt_cost_rate_flag,
         x_burden_rate_flag    => l_pt_burden_rate_flag,
         x_message_count       => x_msg_count,
         x_return_status       => x_return_status,
         x_message_data        => x_msg_data);

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Return status from pa_fin_plan_utils.get_plan_amount_flags is [' || x_return_status || ']';
              pa_debug.write(l_procedure_name ||
                           g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

              pa_debug.g_err_stage:= 'l_pt_bill_rate_flag is [' || l_pt_bill_rate_flag || ']';
              pa_debug.write(l_procedure_name ||
                           g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

              pa_debug.g_err_stage:= 'l_pt_cost_rate_flag is [' || l_pt_cost_rate_flag || ']';
              pa_debug.write(l_procedure_name ||
                           g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

              pa_debug.g_err_stage:= 'l_pt_burden_rate_flag is [' || l_pt_burden_rate_flag || ']';
              pa_debug.write(l_procedure_name ||
                           g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         END IF;

         IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS)    THEN

           pa_debug.g_err_stage:= 'pa_fin_plan_utils.get_plan_amount_flags returned error';
           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

         END IF;

         --Bug 5475184. End of derivation logic for bill/cost rate flags from plan type option.

/* Bug 5478041: Modified the following 6 variables from parameterized variables to
   local variables : l_raw_cost_flag,l_burdened_cost_flag,l_revenue_flag,l_cost_qty_flag
   l_revenue_qty_flag and l_all_qty_flag*/

    pa_fin_plan_utils.GET_OR_CREATE_AMOUNT_SET_ID
    (
             p_raw_cost_flag            => l_raw_cost_flag
            ,p_burdened_cost_flag       => l_burdened_cost_flag
            ,p_revenue_flag             => l_revenue_flag
            ,p_cost_qty_flag            => l_cost_qty_flag
            ,p_revenue_qty_flag         => l_revenue_qty_flag
            ,p_all_qty_flag             => l_all_qty_flag
            ,p_plan_pref_code           => l_plan_pref_code
            ,p_bill_rate_flag           => /*'Y'*/ l_pt_bill_rate_flag   --Bug 5475184
            ,p_cost_rate_flag           => /*'Y'*/ l_pt_cost_rate_flag   --Bug 5475184
            ,p_burden_rate_flag         => /*'Y'*/ l_pt_burden_rate_flag --Bug 5475184
            ,x_cost_amount_set_id       => l_cost_amount_set_id
            ,x_revenue_amount_set_id    => l_rev_amount_set_id
            ,x_all_amount_set_id        => l_all_amount_set_id
            ,x_message_count            => x_msg_count
            ,x_return_status            => x_return_status
            ,x_message_data             => x_msg_data
    );
    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Error in pa_fin_plan_utils.GET_OR_CREATE_AMOUNT_SET_ID';
                     pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- bug 3825873 populating l_allow_qty_flag to call validate_budget_lines

    IF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST)
    THEN
            l_amount_set_id := l_cost_amount_set_id;
            l_allow_qty_flag := l_cost_qty_flag; -- p_cost_qty_flag; Bug 5478041
    ELSIF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE)
    THEN
            l_amount_set_id := l_rev_amount_set_id;
            l_allow_qty_flag := l_revenue_qty_flag; -- p_revenue_qty_flag;Bug 5478041
    ELSIF(l_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL)
    THEN
            l_amount_set_id := l_all_amount_set_id;
            l_allow_qty_flag := l_all_qty_flag; -- p_all_qty_flag; Bug 5478041
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Amount set id is [' || l_amount_set_id || ']';
        pa_debug.write(l_procedure_name ||
                          g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(l_project_id);

    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'l_struct_elem_version_id is [' || l_struct_elem_version_id || ']';
           pa_debug.write(l_procedure_name ||
                          g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    l_created_version_id := NULL;


    IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Calling Create_Version';
           pa_debug.write(l_procedure_name ||
                          g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

--dbms_output.put_line('calling pa_fin_plan_pub.Create_Version');
    pa_fin_plan_pub.Create_Version (
             p_project_id               => l_project_id
            ,p_fin_plan_type_id         => l_fin_plan_type_id
            ,p_element_type             => l_version_type
            ,p_version_name             => p_budget_version_name
            ,p_description              => l_description  -- bug 5031071
            ,p_ci_id                    => NULL
            ,p_est_proj_raw_cost        => NULL
            ,p_est_proj_bd_cost         => NULL
            ,p_est_proj_revenue         => NULL
            ,p_est_qty                  => NULL
            ,p_est_equip_qty            => NULL
            ,p_impacted_task_id         => NULL
            ,p_agreement_id             => NULL
            ,p_calling_context          => l_calling_context
            ,p_resource_list_id         => l_resource_list_id
            ,p_time_phased_code         => l_time_phased_code
            ,p_fin_plan_level_code      => l_fin_plan_level_code /* Bug 6085160 p_fin_plan_level_code */
            ,p_plan_in_multi_curr_flag  => l_plan_in_multi_curr_flag /*Bug 4290310. p_plan_in_multi_curr_flag. Passing the
            l_plan_in_multi_curr_flag as create_version doesnt handle the conversion of G_MISS_XXX values for this variable. Also
            l_plan_in_multi_curr_flag is a validated o/p variable from validate_header_info*/
            ,p_amount_set_id            => l_amount_set_id
            ,p_attribute_category       => l_attribute_category
            ,p_attribute1               => l_attribute1
            ,p_attribute2               => l_attribute2
            ,p_attribute3               => l_attribute3
            ,p_attribute4               => l_attribute4
            ,p_attribute5               => l_attribute5
            ,p_attribute6               => l_attribute6
            ,p_attribute7               => l_attribute7
            ,p_attribute8               => l_attribute8
            ,p_attribute9               => l_attribute9
            ,p_attribute10              => l_attribute10
            ,p_attribute11              => l_attribute11
            ,p_attribute12              => l_attribute12
            ,p_attribute13              => l_attribute13
            ,p_attribute14              => l_attribute14
            ,p_attribute15              => l_attribute15
            ,px_budget_version_id       => l_created_version_id
            ,p_struct_elem_version_id   => NULL --l_struct_elem_version_id commented for bug 5451269
            ,p_pm_product_code          => p_pm_product_code
            ,p_finplan_reference        => l_pm_finplan_reference
            ,p_change_reason_code       => l_change_reason_code
            ,x_proj_fp_option_id        => l_fp_options_id
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data );

        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                pa_debug.g_err_stage:= 'Error Create_Version';
                IF l_debug_mode = 'Y' THEN
                   pa_debug.write( l_procedure_name ||
                         g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
--dbms_output.put_line('after calling pa_fin_plan_pub.Create_Version l_created_version_id is [' || to_char(l_created_version_id) ||']');
        /*========================================================+
         | Prepare to call pa_budget_pvt.validate_budget_lines()  |
         *========================================================*/
        IF ( p_finplan_trans_tab.COUNT > 0 )
        THEN
               FOR i IN p_finplan_trans_tab.FIRST .. p_finplan_trans_tab.LAST
               LOOP
                    l_res_asg_in_tbl(i).pm_product_code := p_finplan_trans_tab(i).pm_product_code;
                    l_res_asg_in_tbl(i).pa_task_id := p_finplan_trans_tab(i).task_id;
                    l_res_asg_in_tbl(i).pm_task_reference := p_finplan_trans_tab(i).pm_task_reference;
                    l_res_asg_in_tbl(i).resource_alias := p_finplan_trans_tab(i).resource_alias;
                    l_res_asg_in_tbl(i).resource_list_member_id := p_finplan_trans_tab(i).resource_list_member_id;
                    l_res_asg_in_tbl(i).budget_start_date := p_finplan_trans_tab(i).start_date;
                    l_res_asg_in_tbl(i).budget_end_date := p_finplan_trans_tab(i).end_date;
                    l_res_asg_in_tbl(i).raw_cost := p_finplan_trans_tab(i).raw_cost;
                    l_res_asg_in_tbl(i).burdened_cost := p_finplan_trans_tab(i).burdened_Cost;
                    l_res_asg_in_tbl(i).revenue := p_finplan_trans_tab(i).revenue;
                    l_res_asg_in_tbl(i).quantity := p_finplan_trans_tab(i).quantity;
                    l_res_asg_in_tbl(i).attribute_category := p_finplan_trans_tab(i).attribute_category;
                    l_res_asg_in_tbl(i).txn_currency_code := p_finplan_trans_tab(i).currency_code;
                    l_res_asg_in_tbl(i).period_name := NULL;
                    l_res_asg_in_tbl(i).description := NULL;
                    l_res_asg_in_tbl(i).pm_budget_line_reference := NULL;
                    l_res_asg_in_tbl(i).attribute1 := NULL;
                    l_res_asg_in_tbl(i).attribute2 := NULL;
                    l_res_asg_in_tbl(i).attribute3 := NULL;
                    l_res_asg_in_tbl(i).attribute4 := NULL;
                    l_res_asg_in_tbl(i).attribute5 := NULL;
                    l_res_asg_in_tbl(i).attribute6 := NULL;
                    l_res_asg_in_tbl(i).attribute7 := NULL;
                    l_res_asg_in_tbl(i).attribute8 := NULL;
                    l_res_asg_in_tbl(i).attribute9 := NULL;
                    l_res_asg_in_tbl(i).attribute10 := NULL;
                    l_res_asg_in_tbl(i).attribute11 := NULL;
                    l_res_asg_in_tbl(i).attribute12 := NULL;
                    l_res_asg_in_tbl(i).attribute13 := NULL;
                    l_res_asg_in_tbl(i).attribute14 := NULL;
                    l_res_asg_in_tbl(i).attribute15 := NULL;
                    l_res_asg_in_tbl(i).projfunc_cost_rate_type := NULL;
                    l_res_asg_in_tbl(i).projfunc_cost_rate_date_type := NULL;
                    l_res_asg_in_tbl(i).projfunc_cost_rate_date := NULL;
                    l_res_asg_in_tbl(i).projfunc_cost_exchange_rate := NULL;
                    l_res_asg_in_tbl(i).projfunc_rev_rate_type := NULL;
                    l_res_asg_in_tbl(i).projfunc_rev_rate_date_type := NULL;
                    l_res_asg_in_tbl(i).projfunc_rev_rate_date := NULL;
                    l_res_asg_in_tbl(i).projfunc_rev_exchange_rate := NULL;
                    l_res_asg_in_tbl(i).project_cost_rate_type := NULL;
                    l_res_asg_in_tbl(i).project_cost_rate_date_type := NULL;
                    l_res_asg_in_tbl(i).project_cost_rate_date := NULL;
                    l_res_asg_in_tbl(i).project_cost_exchange_rate := NULL;
                    l_res_asg_in_tbl(i).project_rev_rate_type := NULL;
                    l_res_asg_in_tbl(i).project_rev_rate_date_type := NULL;
                    l_res_asg_in_tbl(i).project_rev_rate_date := NULL;
                    l_res_asg_in_tbl(i).project_rev_exchange_rate := NULL;
                    l_res_asg_in_tbl(i).change_reason_code := NULL;
               END LOOP;

                 l_version_info_rec.x_budget_version_id := l_created_version_id; -- Added for bug 4290310
/* Bug 5478041: Modified the following 3 variables from parameterized variables to
   local variables : l_raw_cost_flag,l_burdened_cost_flag,l_revenue_flag */
--dbms_output.put_line('calling pa_budget_pvt.Validate_Budget_Lines');

                  pa_budget_pvt.Validate_Budget_Lines
                        (p_calling_context             => 'RES_ASSGNMT_LEVEL_VALIDATION'
                        ,p_pa_project_id               => l_project_id
                        ,p_budget_type_code            => NULL
                        ,p_fin_plan_type_id            => l_fin_plan_type_id
                        ,p_version_type                => l_version_type
                        ,p_resource_list_id            => l_resource_list_id
                        ,p_time_phased_code            => l_time_phased_code
                        ,p_budget_entry_method_code    => NULL
                        ,p_entry_level_code            => l_fin_plan_level_code --Bug#5510196
                        ,p_allow_qty_flag              => l_allow_qty_flag-- bug 3825873 p_cost_qty_flag
                        ,p_allow_raw_cost_flag         => l_raw_cost_flag
                        ,p_allow_burdened_cost_flag    => l_burdened_cost_flag
                        ,p_allow_revenue_flag          => l_revenue_flag
                        ,p_multi_currency_flag         => l_plan_in_multi_curr_flag /*Bug 4290310.p_plan_in_multi_curr_flag. Passing
           the l_plan_in_multi_curr_flag as validate_budget_lines doesnt handle the conversion of G_MISS_XXX values for this variable.
           Also l_plan_in_multi_curr_flag is a validated o/p variable from validate_header_info*/
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
                        ,p_version_info_rec            => l_version_info_rec --Added for bug 4290310.
                        ,px_budget_lines_in            => l_res_asg_in_tbl
                        ,x_budget_lines_out            => l_res_asg_out_tbl
                        ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                        ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                        ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                        ,x_msg_count                   => l_msg_count
                        ,x_msg_data                    => l_msg_data
                        ,x_return_status               => l_return_status);

                  IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         --dbms_output.put_line('error occurred while calling pa_budget_pvt.Validate_Budget_Lines');
                         RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

        END IF; -- p_finplan_trans_tab.COUNT > 0
--dbms_output.put_line('after calling pa_budget_pvt.Validate_Budget_Lines');

/* Calling Add Planning Transaction */

cnt := P_finplan_trans_tab.COUNT;

l_task_number_tbl.EXTEND(cnt);
l_task_elem_version_id_tbl.EXTEND(cnt);
l_pm_task_reference_tbl.EXTEND(cnt);
l_resource_list_member_id_tbl.EXTEND(cnt);
l_pm_res_asgmt_ref_tbl.EXTEND(cnt);
l_currency_code_tbl.EXTEND(cnt);
l_pm_product_code_tbl.EXTEND(cnt);

l_start_date_tbl.EXTEND(cnt);
l_end_date_tbl.EXTEND(cnt);

l_quantity_tbl.EXTEND(cnt);
l_raw_cost_tbl.EXTEND(cnt);
l_burdened_cost_tbl.EXTEND(cnt);
l_revenue_tbl.EXTEND(cnt);

l_attribute_category_tbl.EXTEND(cnt);
l_attribute1_tbl.EXTEND(cnt);
l_attribute2_tbl.EXTEND(cnt);
l_attribute3_tbl.EXTEND(cnt);
l_attribute4_tbl.EXTEND(cnt);
l_attribute5_tbl.EXTEND(cnt);
l_attribute6_tbl.EXTEND(cnt);
l_attribute7_tbl.EXTEND(cnt);
l_attribute8_tbl.EXTEND(cnt);
l_attribute9_tbl.EXTEND(cnt);
l_attribute10_tbl.EXTEND(cnt);
l_attribute11_tbl.EXTEND(cnt);
l_attribute12_tbl.EXTEND(cnt);
l_attribute13_tbl.EXTEND(cnt);
l_attribute14_tbl.EXTEND(cnt);
l_attribute15_tbl.EXTEND(cnt);
l_attribute16_tbl.EXTEND(cnt);
l_attribute17_tbl.EXTEND(cnt);
l_attribute18_tbl.EXTEND(cnt);
l_attribute19_tbl.EXTEND(cnt);
l_attribute20_tbl.EXTEND(cnt);
l_attribute21_tbl.EXTEND(cnt);
l_attribute22_tbl.EXTEND(cnt);
l_attribute23_tbl.EXTEND(cnt);
l_attribute24_tbl.EXTEND(cnt);
l_attribute25_tbl.EXTEND(cnt);
l_attribute26_tbl.EXTEND(cnt);
l_attribute27_tbl.EXTEND(cnt);
l_attribute28_tbl.EXTEND(cnt);
l_attribute29_tbl.EXTEND(cnt);
l_attribute30_tbl.EXTEND(cnt);

 IF P_finplan_trans_tab.COUNT > 0 THEN -- Added for Bug 3793370
    FOR  i in 1 .. P_finplan_trans_tab.LAST
    LOOP
          IF ( P_finplan_trans_tab(i).task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
            OR P_finplan_trans_tab(i).task_id = 0 ) -- Added for Bug 8688677
          THEN
                  l_task_number_tbl(i) := NULL;
          ELSE
                  BEGIN
                         SELECT t.task_number
                           INTO l_task_number
                           FROM pa_tasks t
                          WHERE t.task_id = P_finplan_trans_tab(i).task_id;
                         l_task_number_tbl(i) := l_task_number;

                  EXCEPTION
                          WHEN OTHERS THEN
                            RAISE;
                  END; -- anonymous
          END IF;

          IF P_finplan_trans_tab(i).pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_pm_task_reference_tbl(i) := NULL;
          ELSE
                  l_pm_task_reference_tbl(i) := P_finplan_trans_tab(i).pm_task_reference;
          END IF;
          IF P_finplan_trans_tab(i).CURRENCY_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_currency_code_tbl(i) := NULL;
          ELSE
                  l_currency_code_tbl(i) := P_finplan_trans_tab(i).CURRENCY_CODE;
          END IF;

          IF P_finplan_trans_tab(i).pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_pm_product_code_tbl(i) := NULL;
          ELSE
                  l_pm_product_code_tbl(i) := P_finplan_trans_tab(i).pm_product_code;
          END IF;

          IF ( P_finplan_trans_tab(i).task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR l_struct_elem_version_id IS NULL
            OR P_finplan_trans_tab(i).task_id = 0 ) -- Added for Bug 8688677
          THEN
                  l_task_elem_version_id_tbl(i) := NULL;
          ELSE
                  BEGIN
                         SELECT element_version_id
                           INTO l_task_elem_version_id_tbl(i)
                           FROM pa_struct_task_wbs_v
                          WHERE parent_structure_version_id = l_struct_elem_version_id
                           AND  project_id = l_project_id
                           AND  task_id = P_finplan_trans_tab(i).task_id;
                  EXCEPTION
                      WHEN OTHERS THEN RAISE;
                  END; -- anonymous
         END IF;

         /* Commented out the code for Bug 5079329.
          IF P_finplan_trans_tab(i).resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  l_resource_list_member_id_tbl(i) := NULL;
          ELSE
                  l_resource_list_member_id_tbl(i) :=  P_finplan_trans_tab(i).resource_list_member_id;
          END IF;
        */

        /* Added for Bug 5079329*/
          l_resource_list_member_id_tbl(i) := l_res_asg_in_tbl(i).resource_list_member_id;

          IF P_finplan_trans_tab(i).PM_RES_ASGMT_REFERENCE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_pm_res_asgmt_ref_tbl(i) := NULL;
          ELSE
                  l_pm_res_asgmt_ref_tbl(i)        :=   P_finplan_trans_tab(i).PM_RES_ASGMT_REFERENCE;
          END IF;


          IF P_finplan_trans_tab(i).start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                  l_start_date_tbl(i) := NULL;
          ELSE
                  l_start_date_tbl(i)        :=   P_finplan_trans_tab(i).start_date;
          END IF;

          IF P_finplan_trans_tab(i).end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                  l_end_date_tbl(i) := NULL;
          ELSE
                  l_end_date_tbl(i)        :=   P_finplan_trans_tab(i).end_date;
          END IF;

          IF P_finplan_trans_tab(i).quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  l_quantity_tbl(i) := NULL;
          ELSE
                  l_quantity_tbl(i)        :=   P_finplan_trans_tab(i).quantity;
          END IF;

          IF P_finplan_trans_tab(i).raw_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  l_raw_cost_tbl(i) := NULL;
          ELSE
                  l_raw_cost_tbl(i)        :=   P_finplan_trans_tab(i).raw_cost;
          END IF;

          IF P_finplan_trans_tab(i).burdened_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  l_burdened_cost_tbl(i) := NULL;
          ELSE
                  l_burdened_cost_tbl(i)        :=   P_finplan_trans_tab(i).burdened_cost;
          END IF;

          IF P_finplan_trans_tab(i).revenue = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                  L_revenue_tbl(i) := NULL;
          ELSE
                  l_revenue_tbl(i)        :=   P_finplan_trans_tab(i).revenue;
          END IF;

--When descriptive flex fields are not passed set them to NULL

         IF  P_finplan_trans_tab(i).attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute_category_tbl(i) := NULL;
         ELSE
            l_attribute_category_tbl(i) := P_finplan_trans_tab(i).attribute_category;
         END IF;

         IF  P_finplan_trans_tab(i).attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute1_tbl(i) := NULL;
         ELSE
           l_attribute1_tbl(i) := P_finplan_trans_tab(i).attribute1;
         END IF;

         IF  P_finplan_trans_tab(i).attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute2_tbl(i) := NULL;
         ELSE
           l_attribute2_tbl(i) := P_finplan_trans_tab(i).attribute2;
         END IF;

         IF  P_finplan_trans_tab(i).attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute3_tbl(i) := NULL;
         ELSE
           l_attribute3_tbl(i) := P_finplan_trans_tab(i).attribute3;
         END IF;

         IF  P_finplan_trans_tab(i).attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute4_tbl(i) := NULL;
         ELSE
           l_attribute4_tbl(i) := P_finplan_trans_tab(i).attribute4;
         END IF;

         IF  P_finplan_trans_tab(i).attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute5_tbl(i) := NULL;
         ELSE
           l_attribute5_tbl(i) := P_finplan_trans_tab(i).attribute5;
         END IF;

         IF  P_finplan_trans_tab(i).attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute6_tbl(i) := NULL;
         ELSE
           l_attribute6_tbl(i) := P_finplan_trans_tab(i).attribute6;
         END IF;

         IF  P_finplan_trans_tab(i).attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute7_tbl(i) := NULL;
         ELSE
           l_attribute7_tbl(i) := P_finplan_trans_tab(i).attribute7;
         END IF;

         IF  P_finplan_trans_tab(i).attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute8_tbl(i) := NULL;
         ELSE
           l_attribute8_tbl(i) := P_finplan_trans_tab(i).attribute8;
         END IF;

         IF  P_finplan_trans_tab(i).attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute9_tbl(i) := NULL;
         ELSE
           l_attribute9_tbl(i) := P_finplan_trans_tab(i).attribute9;
         END IF;

         IF  P_finplan_trans_tab(i).attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute10_tbl(i) := NULL;
         ELSE
           l_attribute10_tbl(i) := P_finplan_trans_tab(i).attribute10;
         END IF;

         IF  P_finplan_trans_tab(i).attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute11_tbl(i) := NULL;
         ELSE
           l_attribute11_tbl(i) := P_finplan_trans_tab(i).attribute11;
         END IF;

         IF  P_finplan_trans_tab(i).attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute12_tbl(i) := NULL;
         ELSE
           l_attribute12_tbl(i) := P_finplan_trans_tab(i).attribute12;
         END IF;

         IF  P_finplan_trans_tab(i).attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute13_tbl(i) := NULL;
         ELSE
           l_attribute13_tbl(i) := P_finplan_trans_tab(i).attribute13;
         END IF;

         IF  P_finplan_trans_tab(i).attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute14_tbl(i) := NULL;
         ELSE
           l_attribute14_tbl(i) := P_finplan_trans_tab(i).attribute14;
         END IF;

         IF  P_finplan_trans_tab(i).attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute15_tbl(i) := NULL;
         ELSE
           l_attribute15_tbl(i) := P_finplan_trans_tab(i).attribute15;
         END IF;

         IF  P_finplan_trans_tab(i).attribute16 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute16_tbl(i) := NULL;
         ELSE
           l_attribute16_tbl(i) := P_finplan_trans_tab(i).attribute16;
         END IF;

         IF  P_finplan_trans_tab(i).attribute17 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute17_tbl(i) := NULL;
         ELSE
           l_attribute17_tbl(i) := P_finplan_trans_tab(i).attribute17;
         END IF;

         IF  P_finplan_trans_tab(i).attribute18 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute18_tbl(i) := NULL;
         ELSE
           l_attribute18_tbl(i) := P_finplan_trans_tab(i).attribute18;
         END IF;

         IF  P_finplan_trans_tab(i).attribute19 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute19_tbl(i) := NULL;
         ELSE
           l_attribute19_tbl(i) := P_finplan_trans_tab(i).attribute19;
         END IF;

         IF  P_finplan_trans_tab(i).attribute20 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute20_tbl(i) := NULL;
         ELSE
           l_attribute20_tbl(i) := P_finplan_trans_tab(i).attribute20;
         END IF;

         IF  P_finplan_trans_tab(i).attribute21 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute21_tbl(i) := NULL;
         ELSE
           l_attribute21_tbl(i) := P_finplan_trans_tab(i).attribute21;
         END IF;

         IF  P_finplan_trans_tab(i).attribute22 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute22_tbl(i) := NULL;
         ELSE
           l_attribute22_tbl(i) := P_finplan_trans_tab(i).attribute22;
         END IF;

         IF  P_finplan_trans_tab(i).attribute23 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute23_tbl(i) := NULL;
         ELSE
           l_attribute23_tbl(i) := P_finplan_trans_tab(i).attribute23;
         END IF;

         IF  P_finplan_trans_tab(i).attribute24 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute24_tbl(i) := NULL;
         ELSE
           l_attribute24_tbl(i) := P_finplan_trans_tab(i).attribute24;
         END IF;

         IF  P_finplan_trans_tab(i).attribute25 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute25_tbl(i) := NULL;
         ELSE
           l_attribute25_tbl(i) := P_finplan_trans_tab(i).attribute25;
         END IF;

         IF  P_finplan_trans_tab(i).attribute26 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute26_tbl(i) := NULL;
         ELSE
           l_attribute26_tbl(i) := P_finplan_trans_tab(i).attribute26;
         END IF;

         IF  P_finplan_trans_tab(i).attribute27 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute27_tbl(i) := NULL;
         ELSE
           l_attribute27_tbl(i) := P_finplan_trans_tab(i).attribute27;
         END IF;

         IF  P_finplan_trans_tab(i).attribute28 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute28_tbl(i) := NULL;
         ELSE
           l_attribute28_tbl(i) := P_finplan_trans_tab(i).attribute28;
         END IF;

         IF  P_finplan_trans_tab(i).attribute29 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute29_tbl(i) := NULL;
         ELSE
           l_attribute29_tbl(i) := P_finplan_trans_tab(i).attribute29;
         END IF;

         IF  P_finplan_trans_tab(i).attribute30 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  THEN
            l_attribute30_tbl(i) := NULL;
         ELSE
           l_attribute30_tbl(i) := P_finplan_trans_tab(i).attribute30;
         END IF;


END LOOP;

      Select decode(plan_class_code,
          'BUDGET',PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
          'FORECAST',PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FORECAST)
      Into l_plan_tran_context
      From pa_fin_plan_types_b
      Where fin_plan_type_id = l_fin_plan_type_id;

/* Calling Add Planning Transaction API */


--dbms_output.put_line('calling pa_fp_planning_transaction_pub.add_planning_transactions bvid [' || to_char(l_created_version_id) || ']');
      /*
       | Bug 3709462. Passed p_one_to_one_mapping_flag ('Y') to avoid creation of
       |              Resource Assignments for combinations of Task and Resource.
       */
      pa_fp_planning_transaction_pub.add_planning_transactions
      (       p_context                      => l_plan_tran_context
            , p_one_to_one_mapping_flag      => 'Y'
            , p_calling_module               => 'CREATE_DRAFT_FINPLAN'
            , p_project_id                   => l_project_id
            , p_budget_version_id            => l_created_version_id
            , p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl
            , p_task_name_tbl                => l_pm_task_reference_tbl
            , p_task_number_tbl              => l_task_number_tbl
            , p_planning_start_date_tbl      => l_start_date_tbl -- Bug 5026210
            , p_planning_end_date_tbl        => l_end_date_tbl -- Bug 5026210
            , p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl
            , p_quantity_tbl                 => l_quantity_tbl
            , p_currency_code_tbl            => l_currency_code_tbl
            , p_raw_cost_tbl                 => l_raw_cost_tbl
            , p_burdened_cost_tbl            => l_burdened_cost_tbl
            , p_revenue_tbl                  => l_revenue_tbl
            , p_skip_duplicates_flag         => 'N'
            , p_pm_product_code              => l_pm_product_code_tbl
            , p_pm_res_asgmt_ref             => l_pm_res_asgmt_ref_tbl
            , p_attribute_category_tbl       => l_attribute_category_tbl
            , p_attribute1                 => l_attribute1_tbl
            , p_attribute2                 => l_attribute2_tbl
            , p_attribute3                 => l_attribute3_tbl
            , p_attribute4                 => l_attribute4_tbl
            , p_attribute5                 => l_attribute5_tbl
            , p_attribute6                 => l_attribute6_tbl
            , p_attribute7                 => l_attribute7_tbl
            , p_attribute8                 => l_attribute8_tbl
            , p_attribute9                 => l_attribute9_tbl
            , p_attribute10                => l_attribute10_tbl
            , p_attribute11                => l_attribute11_tbl
            , p_attribute12                => l_attribute12_tbl
            , p_attribute13                => l_attribute13_tbl
            , p_attribute14                => l_attribute14_tbl
            , p_attribute15                => l_attribute15_tbl
            , p_attribute16                => l_attribute16_tbl
            , p_attribute17                => l_attribute17_tbl
            , p_attribute18                => l_attribute18_tbl
            , p_attribute19                => l_attribute19_tbl
            , p_attribute20                => l_attribute20_tbl
            , p_attribute21                => l_attribute21_tbl
            , p_attribute22                => l_attribute22_tbl
            , p_attribute23                => l_attribute23_tbl
            , p_attribute24                => l_attribute24_tbl
            , p_attribute25                => l_attribute25_tbl
            , p_attribute26                => l_attribute26_tbl
            , p_attribute27                => l_attribute27_tbl
            , p_attribute28                => l_attribute28_tbl
            , p_attribute29                => l_attribute29_tbl
            , p_attribute30                => l_attribute30_tbl
            , x_return_status                => l_return_status
            , x_msg_count                    => l_msg_count
            , x_msg_data                     => l_msg_data
      );
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR)
      THEN
                RAISE  FND_API.G_EXC_ERROR;
      END IF;
 END IF; -- 3793370 -- P_finplan_trans_tab.COUNT > 0
/************************************
        l_fp_version_ids_tbl.extend;
        l_fp_version_ids_tbl(1) := l_created_version_id;
        PJI_FM_XBS_ACCUM_MAINT.plan_create( p_fp_version_ids   => l_fp_version_ids_tbl
                                           ,x_return_status    => l_return_status
                                 ,x_msg_code         => l_msg_code
                                          );
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR)
        THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
********************/

        x_finplan_version_id := l_created_version_id;

        IF ( p_create_new_curr_working_flag = 'Y' OR
             p_replace_current_working_flag = 'Y')
        THEN
--dbms_output.put_line('pa_fin_plan_utils.Get_Curr_Working_Version_Info');
            pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                   p_project_id            => l_project_id
                  ,p_fin_plan_type_id      => l_fin_plan_type_id
                  ,p_version_type          => l_version_type
                  ,x_fp_options_id         => l_proj_fp_options_id
                  ,x_fin_plan_version_id   => l_CW_version_id
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => x_msg_count
                  ,x_msg_data              => x_msg_data );
            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
            THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR)
            THEN
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
            IF  ( l_created_version_id <>  l_CW_version_id )
            THEN
                pa_debug.g_err_stage:= 'l_created_version_id [' || TO_CHAR(l_created_version_id) ||
                                  '] is not same as l_CW_version_id [' || TO_CHAR(l_CW_version_id) || ']';
                IF l_debug_mode = 'Y' THEN
                   pa_debug.write( l_procedure_name ||
                         g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;

                l_CW_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                l_created_ver_rec_ver_num := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_created_version_id);
                l_user_id := FND_GLOBAL.User_id;
                PA_COMP_PROFILE_PUB.GET_USER_INFO
                      (p_user_id         => l_user_id,
                       x_person_id       => t_person_id,
                       x_resource_id     => t_resource_id,
                       x_resource_name   => t_resource_name);
--dbms_output.put_line('pa_fin_plan_pvt.lock_unlock_version');
                pa_fin_plan_pvt.lock_unlock_version
                       (p_budget_version_id       => l_CW_version_id,
                        p_record_version_number   => l_CW_record_version_number,
                        p_action                  => 'L',
                        p_user_id                 => l_user_id,
                        p_person_id               => NULL,
                        x_return_status           => x_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data) ;

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Error executing lock unlock version';
                              pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to call set current working version';
                        pa_debug.write(l_procedure_name || g_module_name,pa_debug.g_err_stage,3);
                END IF;


                l_CW_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);
--dbms_output.put_line('pa_fin_plan_pub.Set_Current_Working');
                pa_fin_plan_pub.Set_Current_Working
                        (p_project_id                  => l_project_id,
                         p_budget_version_id           => l_created_version_id,
                         p_record_version_number       => l_created_ver_rec_ver_num,
                         p_orig_budget_version_id      => l_CW_version_id,
                         p_orig_record_version_number  => l_CW_record_version_number,
                         x_return_status               => x_return_status,
                         x_msg_count                   => x_msg_count,
                         x_msg_data                    => x_msg_data);

                IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error executing Set_Current_Working ';
                              pa_debug.write('CREATE_DRAFT: ' ||
                                   g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF; --l_created_version_id <>  l_CW_version_id

      END IF;  --p_create_new_curr_working_flag = 'Y' OR p_replace_current_working_flag = 'Y'
--dbms_output.put_line('PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS');
      PA_BUDGET_PVT.GET_FIN_PLAN_LINES_STATUS
          (p_fin_plan_version_id             => l_created_version_id
          ,p_budget_lines_in                 => l_budget_lines_in
          ,p_calling_context                 => 'CREATE_DRAFT_FINPLAN'
          ,x_fp_lines_retn_status_tab        => l_budget_lines_out
          ,x_return_status                   => x_return_status
          ,x_msg_count                       => x_msg_count
          ,x_msg_data                        => x_msg_data
         );

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR)
      THEN
                RAISE  FND_API.G_EXC_ERROR;
      END IF;
      /*====================================================================+
       | If any of the budget lines had any rejections, set x_return_status |
       | appropriately - So, whoever calls this API would know - there was  |
       | issue creating atleast one of the budget lines.                    |
       +====================================================================*/
      IF ( x_return_status = 'R')
      THEN
             -- bug 3825873 donot raise error it will rollback the entire changes
             -- bug 3825873 RAISE  FND_API.G_EXC_ERROR;
             x_return_status := 'S';
      END IF;

      --Changes for bug 3823485
      IF FND_API.TO_BOOLEAN( p_commit )
      THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'About to do a COMMIT';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            COMMIT;
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Leaving create draft finplan';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            pa_debug.reset_curr_function;
      END IF;

EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           ROLLBACK TO create_draft_finplan_pub;

           IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='In invalid args exception';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, 3);
           END IF;

           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='In invalid args exception 1';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage, 3);
                 END IF;

                 PA_INTERFACE_UTILS_PUB.get_messages
                     ( p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_msg_data
                      ,p_msg_index_out  => l_msg_index_out);

                 x_msg_data  := l_msg_data;
                 x_msg_count := l_msg_count;
           ELSE
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='In invalid args exception 2';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage, 3);
                 END IF;
                 x_msg_count := l_msg_count;
           END IF;


           x_return_status := FND_API.G_RET_STS_ERROR;

           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='In invalid args exception 3';
               pa_debug.write(l_module_name,pa_debug.g_err_stage, 3);
               pa_debug.reset_curr_function;
           END IF;

     WHEN OTHERS THEN

             ROLLBACK TO create_draft_finplan_pub;

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SQLERRM;

             FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_PUB'
                                  ,p_procedure_name  => 'Update_Planning_Transactions');

             IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage, 3);
               pa_debug.reset_curr_function;
             END IF;

             RAISE;

END CREATE_DRAFT_FINPLAN;

PROCEDURE load_resource_info(
 P_PM_PRODUCT_CODE PA_BUDGET_VERSIONS.PM_PRODUCT_CODE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_TASK_ID PA_TASKS.TASK_ID%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_PM_TASK_REFERENCE PA_TASKS.PM_TASK_REFERENCE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_PM_RES_ASGMT_REFERENCE VARCHAR2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_RESOURCE_ALIAS         VARCHAR2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_CURRENCY_CODE PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_UNIT_OF_MEASURE_CODE PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_START_DATE PA_RESOURCE_ASSIGNMENTS.PLANNING_START_DATE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,P_END_DATE PA_RESOURCE_ASSIGNMENTS.PLANNING_END_DATE%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,P_QUANTITY                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_RAW_COST                NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_BURDENED_COST           NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_REVENUE                 NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_RESOURCE_LIST_MEMBER_ID NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,P_ATTRIBUTE_CATEGORY PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE_CATEGORY%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE1 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE1%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE2 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE2%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE3 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE3%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE4 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE4%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE5 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE5%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE6 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE6%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE7 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE7%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE8 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE8%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE9 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE9%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE10 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE10%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE11 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE11%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE12 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE12%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE13 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE13%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE14 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE14%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE15 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE15%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE16 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE16%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE17 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE17%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE18 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE18%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE19 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE19%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE20 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE20%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE21 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE21%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE22 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE22%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE23 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE23%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE24 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE24%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE25 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE25%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE26 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE26%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE27 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE27%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE28 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE28%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE29 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE29%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,P_ATTRIBUTE30 PA_RESOURCE_ASSIGNMENTS.ATTRIBUTE30%TYPE DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
) IS
      cnt number:=0;
BEGIN
      G_PM_PRODUCT_CODE_TBL.extend(1);
      G_TASK_ID_TBL.extend(1);
      G_PM_TASK_REFERENCE_TBL.extend(1);
      G_PM_RES_ASGMT_REFERENCE_TBL.extend(1);
      G_RESOURCE_ALIAS_TBL.extend(1);
      G_CURRENCY_CODE_TBL.extend(1);
      G_UNIT_OF_MEASURE_CODE_TBL.extend(1);
      G_START_DATE_TBL.extend(1);
      G_END_DATE_TBL.extend(1);
      G_QUANTITY_TBL.extend(1);
      G_RAW_COST_TBL.extend(1);
      G_BURDENED_COST_TBL.extend(1);
      G_REVENUE_TBL.extend(1);
      G_RESOURCE_LIST_MEMBER_ID_TBL.extend(1);
      G_ATTRIBUTE_CATEGORY_TBL.extend(1);
      G_ATTRIBUTE1_TBL.extend(1);
      G_ATTRIBUTE2_TBL.extend(1);
      G_ATTRIBUTE3_TBL.extend(1);
      G_ATTRIBUTE4_TBL.extend(1);
      G_ATTRIBUTE5_TBL.extend(1);
      G_ATTRIBUTE6_TBL.extend(1);
      G_ATTRIBUTE7_TBL.extend(1);
      G_ATTRIBUTE8_TBL.extend(1);
      G_ATTRIBUTE9_TBL.extend(1);
      G_ATTRIBUTE10_TBL.extend(1);
      G_ATTRIBUTE11_TBL.extend(1);
      G_ATTRIBUTE12_TBL .extend(1);
      G_ATTRIBUTE13_TBL.extend(1);
      G_ATTRIBUTE14_TBL.extend(1);
      G_ATTRIBUTE15_TBL.extend(1);
      G_ATTRIBUTE16_TBL.extend(1);
      G_ATTRIBUTE17_TBL.extend(1);
      G_ATTRIBUTE18_TBL.extend(1);
      G_ATTRIBUTE19_TBL.extend(1);
      G_ATTRIBUTE20_TBL.extend(1);
      G_ATTRIBUTE21_TBL.extend(1);
      G_ATTRIBUTE22_TBL.extend(1);
      G_ATTRIBUTE23_TBL.extend(1);
      G_ATTRIBUTE24_TBL.extend(1);
      G_ATTRIBUTE25_TBL.extend(1);
      G_ATTRIBUTE26_TBL.extend(1);
      G_ATTRIBUTE27_TBL.extend(1);
      G_ATTRIBUTE28_TBL.extend(1);
      G_ATTRIBUTE29_TBL.extend(1);
      G_ATTRIBUTE30_TBL.extend(1);
--dbms_output.put_line('extending over');

      --find the count on the table.
      cnt := G_START_DATE_TBL.COUNT;
--dbms_output.put_line('G has [' || to_char(cnt) || '] records');

      G_PM_PRODUCT_CODE_TBL(cnt)               := P_PM_PRODUCT_CODE;
      G_TASK_ID_TBL(cnt)                       := P_TASK_ID;
      G_PM_TASK_REFERENCE_TBL(cnt)             := P_PM_TASK_REFERENCE;
      G_PM_RES_ASGMT_REFERENCE_TBL(cnt)        := P_PM_RES_ASGMT_REFERENCE;
      G_RESOURCE_ALIAS_TBL(cnt)                := P_RESOURCE_ALIAS;
      G_CURRENCY_CODE_TBL(cnt)                 := P_CURRENCY_CODE;
      G_UNIT_OF_MEASURE_CODE_TBL(cnt)          := P_UNIT_OF_MEASURE_CODE;
      G_START_DATE_TBL(cnt)                    := P_START_DATE;
      G_END_DATE_TBL(cnt)                      := P_END_DATE;
      G_QUANTITY_TBL(cnt)                      := P_QUANTITY;
      G_RAW_COST_TBL(cnt)                      := P_RAW_COST;
      G_BURDENED_COST_TBL(cnt)                 := P_BURDENED_COST;
      G_REVENUE_TBL(cnt)                       := P_REVENUE;
      G_RESOURCE_LIST_MEMBER_ID_TBL(cnt)       := P_RESOURCE_LIST_MEMBER_ID;
      G_ATTRIBUTE_CATEGORY_TBL(cnt)            := P_ATTRIBUTE_CATEGORY;
      G_ATTRIBUTE1_TBL(cnt)                    := P_ATTRIBUTE1;
      G_ATTRIBUTE2_TBL(cnt)                    := P_ATTRIBUTE2;
      G_ATTRIBUTE3_TBL(cnt)                    := P_ATTRIBUTE3;
      G_ATTRIBUTE4_TBL(cnt)                    := P_ATTRIBUTE4;
      G_ATTRIBUTE5_TBL(cnt)                    := P_ATTRIBUTE5;
      G_ATTRIBUTE6_TBL(cnt)                    := P_ATTRIBUTE6;
      G_ATTRIBUTE7_TBL(cnt)                    := P_ATTRIBUTE7;
      G_ATTRIBUTE8_TBL(cnt)                    := P_ATTRIBUTE8;
      G_ATTRIBUTE9_TBL(cnt)                    := P_ATTRIBUTE9;
      G_ATTRIBUTE10_TBL(cnt)                   := P_ATTRIBUTE10;
      G_ATTRIBUTE11_TBL(cnt)                   := P_ATTRIBUTE11;
      G_ATTRIBUTE12_TBL (cnt)                  := P_ATTRIBUTE12;
      G_ATTRIBUTE13_TBL(cnt)                   := P_ATTRIBUTE13;
      G_ATTRIBUTE14_TBL(cnt)                   := P_ATTRIBUTE14;
      G_ATTRIBUTE15_TBL(cnt)                   := P_ATTRIBUTE15;
      G_ATTRIBUTE16_TBL(cnt)                   := P_ATTRIBUTE16;
      G_ATTRIBUTE17_TBL(cnt)                   := P_ATTRIBUTE17;
      G_ATTRIBUTE18_TBL(cnt)                   := P_ATTRIBUTE18;
      G_ATTRIBUTE19_TBL(cnt)                   := P_ATTRIBUTE19;
      G_ATTRIBUTE20_TBL(cnt)                   := P_ATTRIBUTE20;
      G_ATTRIBUTE21_TBL(cnt)                   := P_ATTRIBUTE21;
      G_ATTRIBUTE22_TBL(cnt)                   := P_ATTRIBUTE22;
      G_ATTRIBUTE23_TBL(cnt)                   := P_ATTRIBUTE23;
      G_ATTRIBUTE24_TBL(cnt)                   := P_ATTRIBUTE24;
      G_ATTRIBUTE25_TBL(cnt)                   := P_ATTRIBUTE25;
      G_ATTRIBUTE26_TBL(cnt)                   := P_ATTRIBUTE26;
      G_ATTRIBUTE27_TBL(cnt)                   := P_ATTRIBUTE27;
      G_ATTRIBUTE28_TBL(cnt)                   := P_ATTRIBUTE28;
      G_ATTRIBUTE29_TBL(cnt)                   := P_ATTRIBUTE29;
      G_ATTRIBUTE30_TBL(cnt)                   := P_ATTRIBUTE30;
--dbms_output.put_line('done with assigning to global tables');
END load_resource_info;

PROCEDURE EXECUTE_CREATE_DRAFT_FINPLAN
 ( p_api_version_number              IN      NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_commit                              IN      VARCHAR2          := FND_API.G_FALSE
  ,p_init_msg_list                       IN      VARCHAR2          := FND_API.G_FALSE
  ,p_pm_product_code                 IN      pa_budget_versions.pm_product_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_finplan_reference            IN      pa_budget_versions.pm_budget_reference%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pm_project_reference            IN      pa_projects_all.PM_PROJECT_REFERENCE%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_id                   IN      pa_budget_versions.project_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_id                IN      pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_type_name              IN      pa_fin_plan_types_vl.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_version_type                    IN      pa_budget_versions.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_time_phased_code                IN      pa_proj_fp_options.cost_time_phased_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_name              IN      pa_resource_lists.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_resource_list_id                IN      pa_budget_versions.resource_list_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_fin_plan_level_code             IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,P_PLAN_IN_MULTI_CURR_FLAG         IN      pa_proj_fp_options.plan_in_multi_curr_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_budget_version_name             IN      pa_budget_versions.version_name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_description                     IN      pa_budget_versions.description%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_change_reason_code              IN      pa_budget_versions.change_reason_code%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_raw_cost_flag                   IN      pa_fin_plan_amount_sets.raw_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_burdened_cost_flag              IN      pa_fin_plan_amount_sets.burdened_cost_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_flag                    IN      pa_fin_plan_amount_sets.revenue_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_cost_qty_flag                   IN      pa_fin_plan_amount_sets.cost_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_revenue_qty_flag                IN      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_all_qty_flag                    IN      pa_fin_plan_amount_sets.all_qty_flag%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute_category              IN      pa_budget_versions.attribute_category%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1                      IN      pa_budget_versions.attribute1%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2                      IN      pa_budget_versions.attribute2%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3                      IN      pa_budget_versions.attribute3%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4                      IN      pa_budget_versions.attribute4%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5                      IN      pa_budget_versions.attribute5%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6                      IN      pa_budget_versions.attribute6%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7                      IN      pa_budget_versions.attribute7%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8                      IN      pa_budget_versions.attribute8%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9                      IN      pa_budget_versions.attribute9%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10                     IN      pa_budget_versions.attribute10%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11                     IN      pa_budget_versions.attribute11%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12                     IN      pa_budget_versions.attribute12%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13                     IN      pa_budget_versions.attribute13%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14                     IN      pa_budget_versions.attribute14%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15                     IN      pa_budget_versions.attribute15%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_create_new_curr_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_replace_current_working_flag    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_using_resource_lists_flag       IN        VARCHAR2 DEFAULT 'N'
  ,x_finplan_version_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT NOCOPY VARCHAR2
  ,x_msg_count                       OUT NOCOPY NUMBER
  ,x_msg_data                        OUT NOCOPY VARCHAR2
 )
IS
  l_finplan_trans_tab               pa_budget_pub.FinPlan_Trans_Tab;
BEGIN
            --dbms_output.put_line('populating table of records');
            FOR i IN G_START_DATE_TBL.FIRST .. G_START_DATE_TBL.LAST
            LOOP
                 l_finplan_trans_tab(i).pm_product_code          := G_PM_PRODUCT_CODE_TBL(i);
                 l_finplan_trans_tab(i).TASK_ID                  := G_TASK_ID_TBL(i);
                 l_finplan_trans_tab(i).PM_TASK_REFERENCE        := G_PM_TASK_REFERENCE_TBL(i);
                 l_finplan_trans_tab(i).PM_RES_ASGMT_REFERENCE   := G_PM_RES_ASGMT_REFERENCE_TBL(i);
                 l_finplan_trans_tab(i).RESOURCE_ALIAS           := G_RESOURCE_ALIAS_TBL(i);
                 l_finplan_trans_tab(i).CURRENCY_CODE            := G_CURRENCY_CODE_TBL(i);
                 l_finplan_trans_tab(i).UNIT_OF_MEASURE_CODE     := G_UNIT_OF_MEASURE_CODE_TBL(i);
                 l_finplan_trans_tab(i).START_DATE               := G_START_DATE_TBL(i);
                 l_finplan_trans_tab(i).END_DATE                 := G_END_DATE_TBL(i);
                 l_finplan_trans_tab(i).QUANTITY                 := G_QUANTITY_TBL(i);
                 l_finplan_trans_tab(i).RAW_COST                 := G_RAW_COST_TBL(i);
                 l_finplan_trans_tab(i).BURDENED_COST            := G_BURDENED_COST_TBL(i);
                 l_finplan_trans_tab(i).REVENUE                  := G_REVENUE_TBL(I);
                 l_finplan_trans_tab(i).RESOURCE_LIST_MEMBER_ID  := G_RESOURCE_LIST_MEMBER_ID_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE_CATEGORY       := G_ATTRIBUTE_CATEGORY_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE1               := G_ATTRIBUTE1_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE2               := G_ATTRIBUTE2_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE3               := G_ATTRIBUTE3_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE4               := G_ATTRIBUTE4_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE5               := G_ATTRIBUTE5_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE6               := G_ATTRIBUTE6_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE7               := G_ATTRIBUTE7_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE8               := G_ATTRIBUTE8_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE9               := G_ATTRIBUTE9_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE10              := G_ATTRIBUTE10_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE11              := G_ATTRIBUTE11_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE12              := G_ATTRIBUTE12_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE13              := G_ATTRIBUTE13_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE14              := G_ATTRIBUTE14_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE15              := G_ATTRIBUTE15_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE16              := G_ATTRIBUTE16_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE17              := G_ATTRIBUTE17_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE18              := G_ATTRIBUTE18_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE19              := G_ATTRIBUTE19_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE20              := G_ATTRIBUTE20_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE21              := G_ATTRIBUTE21_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE22              := G_ATTRIBUTE22_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE23              := G_ATTRIBUTE23_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE24              := G_ATTRIBUTE24_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE25              := G_ATTRIBUTE25_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE26              := G_ATTRIBUTE26_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE27              := G_ATTRIBUTE27_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE28              := G_ATTRIBUTE28_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE29              := G_ATTRIBUTE29_TBL(i);
                 l_finplan_trans_tab(i).ATTRIBUTE30              := G_ATTRIBUTE30_TBL(i);
            END LOOP;

            --dbms_output.put_line('Before calling PA_FIN_PLAN_PUB.CREATE_DRAFT_FINPLAN');
            PA_BUDGET_PUB.CREATE_DRAFT_FINPLAN
                         ( p_api_version_number             => p_api_version_number
                          ,p_commit                             => p_commit
                          ,p_init_msg_list                      => p_init_msg_list
                          ,p_pm_product_code                => p_pm_product_code
                          ,p_pm_finplan_reference           => p_pm_finplan_reference
                          ,p_pm_project_reference           => p_pm_project_reference
                          ,p_pa_project_id                  => p_pa_project_id
                          ,p_fin_plan_type_id               => p_fin_plan_type_id
                          ,p_fin_plan_type_name             => p_fin_plan_type_name
                          ,p_version_type                   => p_version_type
                          ,p_time_phased_code               => p_time_phased_code
                          ,p_resource_list_name             => p_resource_list_name
                          ,p_resource_list_id               => p_resource_list_id
                          ,p_fin_plan_level_code            => p_fin_plan_level_code
                          ,p_plan_in_multi_curr_flag        => P_plan_in_multi_curr_flag
                          ,p_budget_version_name            => p_budget_version_name
                          ,p_description                    => p_description
                          ,p_change_reason_code             => p_change_reason_code
                          ,p_raw_cost_flag                  => p_raw_cost_flag
                          ,p_burdened_cost_flag             => p_burdened_cost_flag
                          ,p_revenue_flag                   => p_revenue_flag
                          ,p_cost_qty_flag                  => p_cost_qty_flag
                          ,p_revenue_qty_flag               => p_revenue_qty_flag
                          ,p_all_qty_flag                   => p_all_qty_flag
                          ,p_attribute_category             => p_attribute_category
                          ,p_attribute1                     => p_attribute1
                          ,p_attribute2                     => p_attribute2
                          ,p_attribute3                     => p_attribute3
                          ,p_attribute4                     => p_attribute4
                          ,p_attribute5                     => p_attribute5
                          ,p_attribute6                     => p_attribute6
                          ,p_attribute7                     => p_attribute7
                          ,p_attribute8                     => p_attribute8
                          ,p_attribute9                     => p_attribute9
                          ,p_attribute10                    => p_attribute10
                          ,p_attribute11                    => p_attribute11
                          ,p_attribute12                    => p_attribute12
                          ,p_attribute13                    => p_attribute13
                          ,p_attribute14                    => p_attribute14
                          ,p_attribute15                    => p_attribute15
                          ,p_create_new_curr_working_flag   => p_create_new_curr_working_flag
                          ,p_replace_current_working_flag   => p_replace_current_working_flag
                          ,p_using_resource_lists_flag      => p_using_resource_lists_flag
                          ,p_finplan_trans_tab              => l_finplan_trans_tab
                          ,x_finplan_version_id             => x_finplan_version_id
                          ,x_return_status                  => x_return_status
                          ,x_msg_count                      => x_msg_count
                          ,x_msg_data                       => x_msg_data
                         );
                         --dbms_output.put_line('after call to PA_FIN_PLAN_PUB.CREATE_DRAFT_FINPLAN');

        /*
         * Empty the tables after each call to CREATE_DRAFT_FINPLAN
         */
        G_PM_PRODUCT_CODE_TBL.DELETE;
        G_TASK_ID_TBL.DELETE;
        G_PM_TASK_REFERENCE_TBL.DELETE;
        G_PM_RES_ASGMT_REFERENCE_TBL.DELETE;
        G_RESOURCE_ALIAS_TBL.DELETE;
        G_CURRENCY_CODE_TBL.DELETE;
        G_UNIT_OF_MEASURE_CODE_TBL.DELETE;
        G_START_DATE_TBL.DELETE;
        G_END_DATE_TBL.DELETE;
        G_QUANTITY_TBL.DELETE;
        G_RAW_COST_TBL.DELETE;
        G_BURDENED_COST_TBL.DELETE;
        G_REVENUE_TBL.DELETE;
        G_RESOURCE_LIST_MEMBER_ID_TBL.DELETE;
        G_ATTRIBUTE_CATEGORY_TBL.DELETE;
        G_ATTRIBUTE1_TBL.DELETE;
        G_ATTRIBUTE2_TBL.DELETE;
        G_ATTRIBUTE3_TBL.DELETE;
        G_ATTRIBUTE4_TBL.DELETE;
        G_ATTRIBUTE5_TBL.DELETE;
        G_ATTRIBUTE6_TBL.DELETE;
        G_ATTRIBUTE7_TBL.DELETE;
        G_ATTRIBUTE8_TBL.DELETE;
        G_ATTRIBUTE9_TBL.DELETE;
        G_ATTRIBUTE10_TBL.DELETE;
        G_ATTRIBUTE11_TBL.DELETE;
        G_ATTRIBUTE12_TBL.DELETE;
        G_ATTRIBUTE13_TBL.DELETE;
        G_ATTRIBUTE14_TBL.DELETE;
        G_ATTRIBUTE15_TBL.DELETE;
        G_ATTRIBUTE16_TBL.DELETE;
        G_ATTRIBUTE17_TBL.DELETE;
        G_ATTRIBUTE18_TBL.DELETE;
        G_ATTRIBUTE19_TBL.DELETE;
        G_ATTRIBUTE20_TBL.DELETE;
        G_ATTRIBUTE21_TBL.DELETE;
        G_ATTRIBUTE22_TBL.DELETE;
        G_ATTRIBUTE23_TBL.DELETE;
        G_ATTRIBUTE24_TBL.DELETE;
        G_ATTRIBUTE25_TBL.DELETE;
        G_ATTRIBUTE26_TBL.DELETE;
        G_ATTRIBUTE27_TBL.DELETE;
        G_ATTRIBUTE28_TBL.DELETE;
        G_ATTRIBUTE29_TBL.DELETE;
        G_ATTRIBUTE30_TBL.DELETE;
                         --dbms_output.put_line('leaving EXECUTE_CREATE_DRAFT_FINPLAN');

END EXECUTE_CREATE_DRAFT_FINPLAN;


   ----------------------------------------------------------------------------------------
   --Name:               update_plannning_element_attr
   --Type:               Procedure
   --Description:        This procedure can be used to update attributes of existing
   --                    Planning Elements
   --
   --
   --Called subprograms: pa_budget_pvt.validate_header_info,pa_budget_pvt.validate_budget_lines
   --                    pa_fp_planning_transaction_pub.update_planning_transactions
   --
   --
   --

   PROCEDURE update_plannning_element_attr
    (p_api_version_number            IN   NUMBER
    ,p_commit                        IN   VARCHAR2                             := FND_API.G_FALSE
    ,p_init_msg_list                 IN   VARCHAR2                             := FND_API.G_FALSE
    ,p_pm_product_code               IN   VARCHAR2                             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pa_project_id                 IN   NUMBER                               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_pm_project_reference          IN   VARCHAR2                             := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_fin_plan_type_id              IN   pa_budget_versions.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_fin_plan_type_name            IN   pa_fin_plan_types_tl.name%TYPE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_budget_version_number         IN   pa_budget_versions.version_number%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_version_type                  IN   pa_budget_versions.version_type%TYPE     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_planning_element_rec_tbl      IN   planning_element_rec_tbl_type
    ,p_distribute_amounts            IN   VARCHAR2             DEFAULT 'Y'    -- Bug 9610380
    ,x_msg_count                     OUT  NOCOPY NUMBER
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2)
    IS

        CURSOR c_get_plan_class_code(c_fin_plan_type_id pa_budget_versions.fin_plan_type_id%TYPE) is
        SELECT plan_class_code
        FROM pa_fin_plan_types_b
        WHERE fin_plan_type_id=c_fin_plan_type_id;

        l_msg_count                              NUMBER := 0;
        l_data                                   VARCHAR2(2000);
        l_msg_data                               VARCHAR2(2000);
        l_msg_index_out                          NUMBER;
        l_return_status                          VARCHAR2(2000);
        l_debug_mode                             VARCHAR2(30);
        i                                        NUMBER;

        l_module_name                            VARCHAR2(100) :='update_plannning_element_attr';
        l_api_name                               CONSTANT    VARCHAR2(100)  := 'update_plannning_element_attr';

        l_project_id                             NUMBER;
        l_budget_type_code                       pa_budget_types.budget_type_code%TYPE;
        l_fin_plan_type_id                       NUMBER;
        l_fin_plan_type_name                     pa_fin_plan_types_tl.name%TYPE;
        l_fin_plan_class_code                    varchar2(30);
        l_version_type                           pa_budget_versions.version_type%TYPE;
        l_budget_version_id                      NUMBER;
        l_budget_entry_method_code               pa_budget_entry_methods.budget_entry_method_code%TYPE;
        l_resource_list_id                       pa_resource_lists_all_bg.resource_list_id%TYPE;
        l_budget_amount_code                     pa_budget_types.budget_amount_code%type;
        l_entry_level_code                       pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
        l_time_phased_code                       pa_proj_fp_options.cost_time_phased_code%TYPE;
        l_multi_curr_flag                        pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
        l_categorization_code                    pa_budget_entry_methods.categorization_code%TYPE;
        l_project_number                         pa_projects_all.segment1%type;

        l_mfc_cost_type_id_tbl                   SYSTEM.pa_num_tbl_type;
        l_etc_method_code_tbl                    SYSTEM.pa_varchar2_30_tbl_type;
        l_spread_curve_id_tbl                    SYSTEM.pa_num_tbl_type;

        l_version_info_rec                       pa_fp_gen_amount_utils.fp_cols;

        l_budget_lines_in_tbl                    PA_BUDGET_PUB.G_BUDGET_LINES_IN_TBL%TYPE;
        l_budget_lines_out_tbl                   PA_BUDGET_PUB.G_BUDGET_LINES_OUT_TBL%TYPE;
        l_planning_start_date_tbl                SYSTEM.pa_date_tbl_type;
        l_planning_end_date_tbl                  SYSTEM.pa_date_tbl_type;
        l_spread_curve_name_tbl                  SYSTEM.PA_VARCHAR2_240_TBL_TYPE;
        l_sp_fixed_date_tbl                      SYSTEM.PA_DATE_TBL_TYPE;
        l_etc_method_name_tbl                    SYSTEM.PA_VARCHAR2_80_TBL_TYPE;

        l_uom_tbl                                SYSTEM.pa_varchar2_80_tbl_type;
        l_mfc_cost_type_tbl                      SYSTEM.PA_VARCHAR2_15_TBL_TYPE;

        l_resource_assignment_id_tbl             SYSTEM.PA_NUM_TBL_TYPE;

        l_currency_code                          varchar2(25);
        l_currency_code_tbl                      SYSTEM.PA_VARCHAR2_15_TBL_TYPE;

        l_assignment_description_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE   ;
        l_attribute_category_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE    ;
        l_attribute1_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute2_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute3_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute4_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute5_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute6_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute7_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute8_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute9_tbl                         SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute10_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute11_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute12_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute13_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute14_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute15_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute16_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute17_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute18_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute19_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute20_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute21_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute22_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute23_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute24_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute25_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute26_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute27_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute28_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute29_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        l_attribute30_tbl                        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   ;
        --Added for bug 6408139 to pass G_PA_MISS_CHAR
        l_pa_miss_char varchar2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

        -- Bug 9610380
        l_distribute_amounts   varchar2(1);
        l_err_value            varchar2(1);
        l_err_field            varchar2(20);

    BEGIN
           -- Set the error stack.
           pa_debug.set_err_stack('PA_BUDGET_PUB.update_plannning_element_attr');

           -- Get the Debug mode into local variable and set it to 'Y'if its NULL
           fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
           l_debug_mode := NVL(l_debug_mode, 'Y');

           -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF FND_API.TO_BOOLEAN( p_init_msg_list )
           THEN
           FND_MSG_PUB.initialize;
           END IF;

           --initialize

           l_project_id                                := p_pa_project_id;
           l_fin_plan_type_id                        := p_fin_plan_type_id;
           l_fin_plan_type_name                        := p_fin_plan_type_name;
           l_version_type                                := p_version_type;


           l_mfc_cost_type_id_tbl                        := SYSTEM.pa_num_tbl_type();
           l_etc_method_code_tbl                        := SYSTEM.pa_varchar2_30_tbl_type();
           l_spread_curve_id_tbl                        := SYSTEM.pa_num_tbl_type();


           l_planning_start_date_tbl                        := SYSTEM.pa_date_tbl_type();
           l_planning_end_date_tbl                        := SYSTEM.pa_date_tbl_type();
           l_spread_curve_name_tbl                        := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
           l_sp_fixed_date_tbl                        := SYSTEM.PA_DATE_TBL_TYPE();
           l_etc_method_name_tbl                        := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();

           l_uom_tbl                                        := SYSTEM.pa_varchar2_80_tbl_type();
           l_mfc_cost_type_tbl                        := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

           l_resource_assignment_id_tbl                := SYSTEM.pa_num_tbl_type();


           l_currency_code_tbl                      := SYSTEM.pa_varchar2_15_tbl_type();

           l_assignment_description_tbl             := SYSTEM.pa_varchar2_240_tbl_type();
           l_attribute_category_tbl                 := SYSTEM.pa_varchar2_30_tbl_type();
           l_attribute1_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute2_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute3_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute4_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute5_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute6_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute7_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute8_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute9_tbl                         := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute10_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute11_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute12_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute13_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute14_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute15_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute16_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute17_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute18_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute19_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute20_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute21_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute22_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute23_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute24_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute25_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute26_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute27_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute28_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute29_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();
           l_attribute30_tbl                        := SYSTEM.pa_varchar2_150_tbl_type();

           pa_budget_pvt.G_res_assign_tbl.delete;
           l_distribute_amounts                     := p_distribute_amounts;  -- Bug 9610380
           --end initialize

           -- Bug 9610380 : Start
           IF (l_distribute_amounts is NULL) OR (l_distribute_amounts <> 'N' AND l_distribute_amounts <> 'Y')
           THEN
             IF l_debug_mode = 'Y' THEN
               pa_debug.write_file('Failed because the value of p_distrib_amts is not valid',5);
             END IF;
             l_err_value := l_distribute_amounts;
             l_err_field := 'p_distribute_amounts';
             FND_MESSAGE.SET_NAME('PA','PA_PMC_INVALID_LOV_VAL');
             FND_MESSAGE.SET_TOKEN('VALUE',l_err_value);
             FND_MESSAGE.SET_TOKEN('FIELD',l_err_field);
             FND_MSG_PUB.add;
             raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           -- Bug 9610380 : End

           if p_planning_element_rec_tbl.count = 0 then
                   IF l_debug_mode = 'Y' THEN
                       pa_debug.write_file('No Planning Elements Passed',5);
                   END IF;
                   pa_debug.reset_err_stack;
                   return;
           end if;


--           DBMS_OUTPUT.PUT_LINE('p_api_version_number '||p_api_version_number);
--           DBMS_OUTPUT.PUT_LINE(' l_api_name '|| l_api_name);
--           DBMS_OUTPUT.PUT_LINE('p_init_msg_list'||p_init_msg_list);
--           DBMS_OUTPUT.PUT_LINE('l_project_id'||l_project_id);
--           DBMS_OUTPUT.PUT_LINE('p_pm_project_reference'||p_pm_project_reference);
--           DBMS_OUTPUT.PUT_LINE('p_pm_product_code'||p_pm_product_code);
--           DBMS_OUTPUT.PUT_LINE('l_fin_plan_type_id'||l_fin_plan_type_id);
--           DBMS_OUTPUT.PUT_LINE('l_fin_plan_type_name'||l_fin_plan_type_name);
--           DBMS_OUTPUT.PUT_LINE('p_budget_version_number'||p_budget_version_number);
--           DBMS_OUTPUT.PUT_LINE('l_version_type'||l_version_type);


           PA_BUDGET_PVT.validate_header_info(
               p_api_version_number          => p_api_version_number
              ,p_api_name                    => l_api_name
              ,p_init_msg_list               => p_init_msg_list
              ,px_pa_project_id              => l_project_id
              ,p_pm_project_reference        => p_pm_project_reference
              ,p_pm_product_code             => p_pm_product_code
              ,px_budget_type_code                  => l_budget_type_code
              ,px_fin_plan_type_id           => l_fin_plan_type_id
              ,px_fin_plan_type_name         => l_fin_plan_type_name
              ,px_version_type               => l_version_type
              ,p_budget_version_number       => p_budget_version_number
              ,p_change_reason_code          => NULL
              ,p_function_name               => 'PA_PM_UPDATE_BUDGET'
              ,x_budget_entry_method_code    => l_budget_entry_method_code
              ,x_resource_list_id            => l_resource_list_id
              ,x_budget_version_id           => l_budget_version_id
              ,x_fin_plan_level_code         => l_entry_level_code
              ,x_time_phased_code            => l_time_phased_code
              ,x_plan_in_multi_curr_flag     => l_multi_curr_flag
              ,x_budget_amount_code          => l_budget_amount_code
              ,x_categorization_code         => l_categorization_code
              ,x_project_number              => l_project_number
              /* Plan Amount Entry flags introduced by bug 6408139 */
              /*Passing all as G_PA_MISS_CHAR since validations not required*/
              ,px_raw_cost_flag         =>   l_pa_miss_char
              ,px_burdened_cost_flag    =>   l_pa_miss_char
              ,px_revenue_flag          =>   l_pa_miss_char
              ,px_cost_qty_flag         =>   l_pa_miss_char
              ,px_revenue_qty_flag      =>   l_pa_miss_char
              ,px_all_qty_flag          =>   l_pa_miss_char
              ,px_bill_rate_flag        =>   l_pa_miss_char
              ,px_cost_rate_flag        =>   l_pa_miss_char
              ,px_burden_rate_flag      =>   l_pa_miss_char
              /* Plan Amount Entry flags introduced by bug 6408139 */
              ,x_msg_count                   => l_msg_count
              ,x_msg_data                    => l_msg_data
              ,x_return_status               => l_return_status );
           /*
           DBMS_OUTPUT.PUT_LINE('return status is '||l_return_status);
           */
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.write_file('Failed due to error in pa_budget_pvt.validate_header_info',5);
                 END IF;
                 raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
           END IF;

           --DBMS_OUTPUT.PUT_LINE('PA_BUDGET_PVT.validate_header_info successful project number is '||l_project_number||' bversion id '||l_budget_version_id);

           l_version_info_rec.x_budget_version_id := l_budget_version_id;

           FOR i IN p_planning_element_rec_tbl.first..p_planning_element_rec_tbl.last LOOP
                   -- how we will handle project id
                    --make these null when pa.g_miss num and fnd g miss num when null
               l_budget_lines_in_tbl(i).pa_task_id                    :=   p_planning_element_rec_tbl(i).pa_task_id;
               l_budget_lines_in_tbl(i).pm_task_reference             :=   p_planning_element_rec_tbl(i).pm_task_reference;
               l_budget_lines_in_tbl(i).resource_alias                :=   p_planning_element_rec_tbl(i).resource_alias;
               l_budget_lines_in_tbl(i).resource_list_member_id       :=   p_planning_element_rec_tbl(i).resource_list_member_id;

               l_planning_start_date_tbl.extend(1);
               l_planning_start_date_tbl(i) :=  p_planning_element_rec_tbl(i).planning_start_date;
               if l_planning_start_date_tbl(i) is null then
                   l_planning_start_date_tbl(i) :=FND_API.G_MISS_DATE;
               elsif l_planning_start_date_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE then
                   l_planning_start_date_tbl(i) := null;
               end if;

               l_planning_end_date_tbl.extend(1);
               l_planning_end_date_tbl(i)   :=  p_planning_element_rec_tbl(i).planning_end_date;
               if l_planning_end_date_tbl(i) is null then
                   l_planning_end_date_tbl(i) :=FND_API.G_MISS_DATE;
               elsif l_planning_end_date_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE then
                   l_planning_end_date_tbl(i) := null;
               end if;

               l_spread_curve_name_tbl.extend(1);
               l_spread_curve_name_tbl(i)   :=  p_planning_element_rec_tbl(i).spread_curve;
               if l_spread_curve_name_tbl(i)is null then
                   l_spread_curve_name_tbl(i) :=FND_API.G_MISS_CHAR;
               elsif l_spread_curve_name_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR then
                   l_spread_curve_name_tbl(i) := null;
               end if;

               l_sp_fixed_date_tbl.extend(1);
               l_sp_fixed_date_tbl(i)       :=  p_planning_element_rec_tbl(i).fixed_date;
               if l_sp_fixed_date_tbl(i) is null then
                   l_sp_fixed_date_tbl(i) :=FND_API.G_MISS_DATE;
               elsif l_sp_fixed_date_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE then
                   l_sp_fixed_date_tbl(i) := null;
               end if;

               l_etc_method_name_tbl.extend(1);
               l_etc_method_name_tbl(i)     :=  p_planning_element_rec_tbl(i).etc_method_name;
               if l_etc_method_name_tbl(i) is null then
                   l_etc_method_name_tbl(i) :=FND_API.G_MISS_CHAR;
               elsif l_etc_method_name_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR then
                   l_etc_method_name_tbl(i) := null;
               end if;

               l_uom_tbl.extend(1);
               l_uom_tbl(i):=null;
               l_mfc_cost_type_tbl.extend(1);
               l_mfc_cost_type_tbl(i):=null;

           end loop;

           pa_budget_pvt.Validate_Budget_Lines
                     (p_calling_context             => 'UPDATE_PLANNING_ELEMENT_ATTR'
                     ,p_pa_project_id               => l_project_id
                     ,p_budget_type_code            => NULL
                     ,p_fin_plan_type_id            => l_fin_plan_type_id
                     ,p_version_type                => l_version_type
                     ,p_resource_list_id            => l_resource_list_id
                     ,p_time_phased_code            => l_time_phased_code
                     ,p_budget_entry_method_code    => NULL
                     ,p_entry_level_code            => l_entry_level_code
                     ,p_allow_qty_flag              => null
                     ,p_allow_raw_cost_flag         => null
                     ,p_allow_burdened_cost_flag    => null
                     ,p_allow_revenue_flag          => null
                     ,p_multi_currency_flag         => l_multi_curr_flag
                     ,p_project_cost_rate_type      => null
                     ,p_project_cost_rate_date_typ  => null
                     ,p_project_cost_rate_date      => null
                     ,p_project_cost_exchange_rate  => null
                     ,p_projfunc_cost_rate_type     => null
                     ,p_projfunc_cost_rate_date_typ => null
                     ,p_projfunc_cost_rate_date     => null
                     ,p_projfunc_cost_exchange_rate => null
                     ,p_project_rev_rate_type       => null
                     ,p_project_rev_rate_date_typ   => null
                     ,p_project_rev_rate_date       => null
                     ,p_project_rev_exchange_rate   => null
                     ,p_projfunc_rev_rate_type      => null
                     ,p_projfunc_rev_rate_date_typ  => null
                     ,p_projfunc_rev_rate_date      => null
                     ,p_projfunc_rev_exchange_rate  => null
                     ,p_planning_start_date_tbl     => l_planning_start_date_tbl
                     ,p_planning_end_date_tbl         => l_planning_end_date_tbl
                     ,p_spread_curve_name_tbl         => l_spread_curve_name_tbl
                     ,p_sp_fixed_date_tbl                 => l_sp_fixed_date_tbl
                     ,p_etc_method_name_tbl         => l_etc_method_name_tbl
                     ,p_uom_tbl                         => l_uom_tbl
                     ,p_mfc_cost_type_tbl                 => l_mfc_cost_type_tbl
                     ,p_version_info_rec            => l_version_info_rec
                     ,px_budget_lines_in            => l_budget_lines_in_tbl
                     ,x_budget_lines_out            => l_budget_lines_out_tbl
                     ,x_mfc_cost_type_id_tbl        => l_mfc_cost_type_id_tbl
                     ,x_etc_method_code_tbl         => l_etc_method_code_tbl
                     ,x_spread_curve_id_tbl         => l_spread_curve_id_tbl
                     ,x_msg_count                   => l_msg_count
                     ,x_msg_data                    => l_msg_data
                     ,x_return_status               => l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 IF l_debug_mode = 'Y' THEN
                       pa_debug.write_file('Failed due to error in pa_budget_pvt.validate_budget_lines',5);
                 END IF;
                 raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
           END IF;

           --DBMS_OUTPUT.PUT_LINE('PA_BUDGET_PVT.validate_budget_lines successful');
           /*
           for i in l_etc_method_code_tbl.first..l_etc_method_code_tbl.count loop
                   DBMS_OUTPUT.PUT_LINE('resource alias '||i||' '||l_budget_lines_in_tbl(i).pm_task_reference);
           end loop;
           */
           l_resource_assignment_id_tbl.extend(l_budget_lines_in_tbl.count);
           l_currency_code_tbl.extend(l_budget_lines_in_tbl.count);

           l_assignment_description_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute_category_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute1_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute2_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute3_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute4_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute5_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute6_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute7_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute8_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute9_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute10_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute11_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute12_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute13_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute14_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute15_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute16_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute17_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute18_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute19_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute20_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute21_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute22_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute23_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute24_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute25_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute26_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute27_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute28_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute29_tbl.extend(l_budget_lines_in_tbl.count);
           l_attribute30_tbl.extend(l_budget_lines_in_tbl.count);


           open c_get_plan_class_code(l_fin_plan_type_id);
           fetch c_get_plan_class_code into l_fin_plan_class_code;
           close c_get_plan_class_code;

           SELECT decode(pf.approved_rev_plan_type_flag,'Y'
           ,pa.PROJFUNC_CURRENCY_CODE
           ,pa.PROJECT_CURRENCY_CODE)
           INTO l_currency_code
           FROM pa_projects_all pa,
           pa_proj_fp_options pf
           WHERE pa.project_id=l_project_id
           AND pa.project_id=pf.project_id
           AND pf.fin_plan_version_id=l_budget_version_id;

             FOR i IN 1..l_budget_lines_in_tbl.COUNT loop
             /*
                   begin
                    select resource_assignment_id
                    into l_resource_assignment_id_tbl(i)
                    from pa_resource_assignments
                    where  budget_version_id=l_budget_version_id
                    and task_id=l_budget_lines_in_tbl(i).pa_task_id
                    and resource_list_member_id=l_budget_lines_in_tbl(i).resource_list_member_id
                    and project_id=l_project_id
                    and PROJECT_ASSIGNMENT_ID =-1;
                    exception when no_data_found then
                           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'RES_ASSGN_DOESNT_EXIST_AMG',
                                 p_token1         => 'PROJECT_OR_TASK_NUMBER',
                                 p_value1         => l_budget_lines_in_tbl(i).pm_task_reference,
                                 p_token2         => 'RESOURCE',
                                 p_value2         => l_budget_lines_in_tbl(i).resource_alias);
                   end;*/
                   l_resource_assignment_id_tbl(i) := pa_budget_pvt.G_res_assign_tbl(i).resource_assignment_id;
                   begin
                   select txn_currency_code into l_currency_code_tbl(i)
                   from pa_budget_lines
                   where resource_assignment_id=l_resource_assignment_id_tbl(i)
                   and rownum=1;
                   exception when no_data_found then
                   l_currency_code_tbl(i):=l_currency_code;
                   end;


                   l_assignment_description_tbl(i) :=  p_planning_element_rec_tbl(i).assignment_description;
                   if l_assignment_description_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR then
                           l_assignment_description_tbl(i):=null;
                   elsif l_assignment_description_tbl(i) = null then
                           l_assignment_description_tbl(i):=FND_API.G_MISS_CHAR;
                   end if;

                   l_attribute_category_tbl(i) := p_planning_element_rec_tbl(i).attribute_category;
                   l_attribute1_tbl(i)         := p_planning_element_rec_tbl(i).attribute1;
                   l_attribute2_tbl(i)         := p_planning_element_rec_tbl(i).attribute2;
                   l_attribute3_tbl(i)         := p_planning_element_rec_tbl(i).attribute3;
                   l_attribute4_tbl(i)         := p_planning_element_rec_tbl(i).attribute4;
                   l_attribute5_tbl(i)         := p_planning_element_rec_tbl(i).attribute5;
                   l_attribute6_tbl(i)         := p_planning_element_rec_tbl(i).attribute6;
                   l_attribute7_tbl(i)         := p_planning_element_rec_tbl(i).attribute7;
                   l_attribute8_tbl(i)         := p_planning_element_rec_tbl(i).attribute8;
                   l_attribute9_tbl(i)         := p_planning_element_rec_tbl(i).attribute9;
                   l_attribute10_tbl(i)        := p_planning_element_rec_tbl(i).attribute10;
                   l_attribute11_tbl(i)        := p_planning_element_rec_tbl(i).attribute11;
                   l_attribute12_tbl(i)        := p_planning_element_rec_tbl(i).attribute12;
                   l_attribute13_tbl(i)        := p_planning_element_rec_tbl(i).attribute13;
                   l_attribute14_tbl(i)        := p_planning_element_rec_tbl(i).attribute14;
                   l_attribute15_tbl(i)        := p_planning_element_rec_tbl(i).attribute15;
                   l_attribute16_tbl(i)        := p_planning_element_rec_tbl(i).attribute16;
                   l_attribute17_tbl(i)        := p_planning_element_rec_tbl(i).attribute17;
                   l_attribute18_tbl(i)        := p_planning_element_rec_tbl(i).attribute18;
                   l_attribute19_tbl(i)        := p_planning_element_rec_tbl(i).attribute19;
                   l_attribute20_tbl(i)        := p_planning_element_rec_tbl(i).attribute20;
                   l_attribute21_tbl(i)        := p_planning_element_rec_tbl(i).attribute21;
                   l_attribute22_tbl(i)        := p_planning_element_rec_tbl(i).attribute22;
                   l_attribute23_tbl(i)        := p_planning_element_rec_tbl(i).attribute23;
                   l_attribute24_tbl(i)        := p_planning_element_rec_tbl(i).attribute24;
                   l_attribute25_tbl(i)        := p_planning_element_rec_tbl(i).attribute25;
                   l_attribute26_tbl(i)        := p_planning_element_rec_tbl(i).attribute26;
                   l_attribute27_tbl(i)        := p_planning_element_rec_tbl(i).attribute27;
                   l_attribute28_tbl(i)        := p_planning_element_rec_tbl(i).attribute28;
                   l_attribute29_tbl(i)        := p_planning_element_rec_tbl(i).attribute29;
                   l_attribute30_tbl(i)        := p_planning_element_rec_tbl(i).attribute30;

             end loop;

           pa_fp_planning_transaction_pub.update_planning_transactions(
            p_context                        => l_fin_plan_class_code
           ,p_budget_version_id            => l_budget_version_id
           ,p_resource_assignment_id_tbl   => l_resource_assignment_id_tbl
           ,p_planning_start_date_tbl      => l_planning_start_date_tbl
           ,p_planning_end_date_tbl        => l_planning_end_date_tbl
           ,p_mfc_cost_type_id_tbl         => l_mfc_cost_type_id_tbl
           ,p_etc_method_code_tbl          => l_etc_method_code_tbl
           ,p_spread_curve_id_tbl          => l_spread_curve_id_tbl
           ,p_sp_fixed_date_tbl            => l_sp_fixed_date_tbl
           ,p_currency_code_tbl            => l_currency_code_tbl
           ,p_assignment_description_tbl   => l_assignment_description_tbl
           ,p_attribute_category_tbl       => l_attribute_category_tbl
           ,p_attribute1_tbl               => l_attribute1_tbl
           ,p_attribute2_tbl               => l_attribute2_tbl
           ,p_attribute3_tbl               => l_attribute3_tbl
           ,p_attribute4_tbl               => l_attribute4_tbl
           ,p_attribute5_tbl               => l_attribute5_tbl
           ,p_attribute6_tbl               => l_attribute6_tbl
           ,p_attribute7_tbl               => l_attribute7_tbl
           ,p_attribute8_tbl               => l_attribute8_tbl
           ,p_attribute9_tbl               => l_attribute9_tbl
           ,p_attribute10_tbl              => l_attribute10_tbl
           ,p_attribute11_tbl              => l_attribute11_tbl
           ,p_attribute12_tbl              => l_attribute12_tbl
           ,p_attribute13_tbl              => l_attribute13_tbl
           ,p_attribute14_tbl              => l_attribute14_tbl
           ,p_attribute15_tbl              => l_attribute15_tbl
           ,p_attribute16_tbl              => l_attribute16_tbl
           ,p_attribute17_tbl              => l_attribute17_tbl
           ,p_attribute18_tbl              => l_attribute18_tbl
           ,p_attribute19_tbl              => l_attribute19_tbl
           ,p_attribute20_tbl              => l_attribute20_tbl
           ,p_attribute21_tbl              => l_attribute21_tbl
           ,p_attribute22_tbl              => l_attribute22_tbl
           ,p_attribute23_tbl              => l_attribute23_tbl
           ,p_attribute24_tbl              => l_attribute24_tbl
           ,p_attribute25_tbl              => l_attribute25_tbl
           ,p_attribute26_tbl              => l_attribute26_tbl
           ,p_attribute27_tbl              => l_attribute27_tbl
           ,p_attribute28_tbl              => l_attribute28_tbl
           ,p_attribute29_tbl              => l_attribute29_tbl
           ,p_attribute30_tbl              => l_attribute30_tbl
           ,p_pji_rollup_required          => 'Y'
           ,p_distrib_amts                 => l_distribute_amounts  -- Bug 9610380
           ,x_msg_count                    => l_msg_count
           ,x_msg_data                     => l_msg_data
           ,x_return_status                => l_return_status
           );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                 IF l_debug_mode = 'Y' THEN
                       pa_debug.write_file('Failed due to error in update_planning_transactions',5);
                 END IF;
                 raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
           END IF;



               pa_debug.reset_err_stack;

   EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

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
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.write_file('update_plannning_element_attr ' || x_msg_data,5);
           END IF;

           x_return_status:= FND_API.G_RET_STS_ERROR;


               pa_debug.reset_err_stack;


      WHEN Others THEN


           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;
           FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_BUDGET_PUB'
                            ,p_procedure_name  => 'update_plannning_element_attr');
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.write_file('update_plannning_element_attr '  || pa_debug.G_Err_Stack,5);
           END IF;

               pa_debug.reset_err_stack;

    END update_plannning_element_attr;


end PA_BUDGET_PUB;

/
