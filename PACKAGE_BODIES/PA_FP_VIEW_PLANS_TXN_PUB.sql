--------------------------------------------------------
--  DDL for Package Body PA_FP_VIEW_PLANS_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_VIEW_PLANS_TXN_PUB" as
/* $Header: PAFPVPNB.pls 120.1 2005/08/19 16:31:28 mwasowic noship $
   Start of Comments
   Package name     : pa_fp_view_plans_txn_pub
   Purpose          : API's for Financial Planning: View Plans Non-Hgrid Page
   History          :
   NOTE             :
   End of Comments
*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_plsql_max_array_size  NUMBER        := 200;

function Get_Multicurrency_Flag return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG;
  END Get_Multicurrency_Flag;

function Get_Plan_Type_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_PLAN_TYPE_ID;
  END Get_Plan_Type_Id;

function Get_Cost_Version_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_COST_VERSION_ID;
  END Get_Cost_Version_Id;

function Get_Rev_Version_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_REV_VERSION_ID;
  END Get_Rev_Version_Id;

function Get_Single_Version_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_SINGLE_VERSION_ID;
  END Get_Single_Version_Id;

function Get_Cost_Resource_List_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_COST_RESOURCE_LIST_ID;
  END Get_Cost_Resource_List_Id;

function Get_Revenue_Resource_List_Id return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_REVENUE_RESOURCE_LIST_ID;
  END Get_Revenue_Resource_List_Id;

function Get_Report_Labor_Hrs_From_Code return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE;
  END Get_Report_Labor_Hrs_From_Code;

function Get_Derive_Margin_From_Code return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE;
  END Get_Derive_Margin_From_Code;

function Get_Display_From return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_DISPLAY_FROM;
  END;

function Get_Cost_Version_Grouping return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING;
  END;

function Get_Rev_Version_Grouping return VARCHAR2 is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING;
  END;

function Get_Cost_RV_Num return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_COST_RECORD_VERSION_NUM;
  END;

function Get_Rev_RV_Num return NUMBER is
  BEGIN
    return pa_fp_view_plans_txn_pub.G_REV_RECORD_VERSION_NUM;
  END;

--
-- BUG FIX 2615852: need to recognize if all txn currencies entered for a ra
--

function all_txn_currencies_entered
    (p_resource_assignment_id   IN  pa_resource_assignments.resource_assignment_id%TYPE)
  return VARCHAR2
is
l_return_value   VARCHAR2(1);
l_budget_version_id     pa_budget_versions.budget_version_id%TYPE;
/* bug 3106741
   pa_fp_txn_curr table doesn't have any index on plan_version_id.
   But index is available on proj_fp_options_id.
   So, pa_proj_fp_options_id is used to fetch options_id
 */
cursor unentered_csr is
  select txn_currency_code
    from pa_fp_txn_currencies txncurr,
         pa_proj_fp_options pfo
    where pfo.fin_plan_version_id = l_budget_version_id and
          txncurr.proj_fp_options_id = pfo.proj_fp_options_id and
          not (txn_currency_code in
                 (select distinct txn_currency_code
                    from pa_budget_lines bl
                    where bl.resource_assignment_id = p_resource_assignment_id));
unentered_rec unentered_csr%ROWTYPE;

begin
  l_return_value := 'N';
  select budget_version_id
    into l_budget_version_id
    from pa_resource_assignments
    where resource_assignment_id = p_resource_assignment_id;
  open unentered_csr;
  fetch unentered_csr into unentered_rec;
  -- if the csr is empty, then there are no txn currencies for which a budget
  -- line has not been created.  thus, all txn currencies have been entered
  if unentered_csr%NOTFOUND then
    l_return_value := 'Y';
  end if;
  close unentered_csr;
  return l_return_value;
EXCEPTION
   WHEN NO_DATA_FOUND then
      return l_return_value;
   WHEN OTHERS then
      return l_return_value;
end all_txn_currencies_entered;


/* ------------------------------------------------------------- */

function get_task_name
     (p_task_id IN      pa_tasks.task_id%TYPE) return VARCHAR2 is
  l_task_name   pa_tasks.task_name%TYPE;
  BEGIN
    select task_name
      into l_task_name
      from pa_tasks
      where task_id = p_task_id;
    return l_task_name;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_task_name := 'none';
          return(l_task_name);
     WHEN OTHERS THEN
          l_task_name := 'error';
          return(l_task_name);
  END;
/* ------------------------------------------------------------- */

function get_task_number
     (p_task_id  IN     pa_tasks.task_id%TYPE) return VARCHAR2 is
  l_task_number   pa_tasks.task_number%TYPE;
  BEGIN
    select task_number
      into l_task_number
      from pa_tasks
      where task_id = p_task_id;
    return l_task_number;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_task_number := 'none';
          return(l_task_number);
     WHEN OTHERS THEN
          l_task_number := 'error';
          return(l_task_number);
  END;
/* ------------------------------------------------------------- */
function get_resource_name
     (p_resource_id IN  pa_resources.resource_id%TYPE) return VARCHAR2 is
  l_resource_name   pa_resources.name%TYPE;
  BEGIN
    select name
      into l_resource_name
      from pa_resources
      where resource_id = p_resource_id;
    return l_resource_name;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_resource_name := 'none';
          return(l_resource_name);
     WHEN OTHERS THEN
          l_resource_name := 'error';
          return(l_resource_name);
  END;
/* ------------------------------------------------------------- */

/* ----------------------  CHANGE HISTORY ----------------------- */
-- 10/08/02: x_planned_resources_flag:
--           check pa_resource_lists.uncategorized_flag
-- 10/10/02: for x_display_from, query PLAN_TYPE planning options
-- 10/28/02: make sure resource list global variables are populated
--           for resource query to work
-- 10/31/02: queries for compl version should make sure ci_id is null
-- 11/08/02: x_project_currency = project or projfunc currency, depending if
--           plan type = AR
--           populate G_DISPLAY_CURRENCY_TYPE
-- 07/30/03: changed logic for populating x_planned_resources_flag and x_grouping_type
--           BUG 2813661
procedure nonhgrid_view_initialize
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_cost_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
     p_rev_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
     p_user_id              IN  NUMBER,
--     x_budget_status_code   OUT pa_budget_versions.budget_status_code%TYPE,
     x_cost_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_rev_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id      OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
--     x_cost_locked_id       OUT pa_budget_versions.locked_by_person_id%TYPE,
--     x_rev_locked_id        OUT pa_budget_versions.locked_by_person_id%TYPE,
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,  -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,  -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_labor_hrs_from_code  OUT NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_rv_number       OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_rev_rv_number        OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_cost_locked_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_rev_locked_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_ar_ac_flag           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id     OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_plan_class_code      OUT NOCOPY VARCHAR2,  -- FP L: Plan Class Security --File.Sql.39 bug 4440895
     x_display_res_flag     OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2,  -- bug 3146974 --File.Sql.39 bug 4440895
     x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
is

l_fin_plan_type_id           pa_proj_fp_options.fin_plan_type_id%TYPE;
l_proj_fp_options_id         pa_proj_fp_options.proj_fp_options_id%TYPE;
l_working_or_baselined       VARCHAR2(30);
l_cost_or_revenue            VARCHAR2(30);
l_ar_flag                    pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_ac_flag                    pa_budget_versions.approved_cost_plan_type_flag%TYPE;
l_c_budget_status_code       pa_budget_versions.budget_status_code%TYPE;
l_r_budget_status_code       pa_budget_versions.budget_status_code%TYPE;
l_fp_preference_code         pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_report_labor_hrs_from_code pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_margin_derived_code        pa_proj_fp_options.margin_derived_from_code%TYPE;
l_grouping_type              VARCHAR2(30);
l_compl_grouping_type        VARCHAR2(30);
l_cost_planning_level        pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_rev_planning_level         pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
l_compl_resource_list_id     pa_budget_versions.resource_list_id%TYPE;
l_rv_number                  pa_budget_versions.record_version_number%TYPE;
l_compl_rv_number            pa_budget_versions.record_version_number%TYPE;
l_uncategorized_flag         pa_resource_lists.uncategorized_flag%TYPE;
l_compl_uncategorized_flag   pa_resource_lists.uncategorized_flag%TYPE;
l_debug_mode                    VARCHAR2(30);
l_is_cost_locked_by_user        VARCHAR2(1);
l_is_rev_locked_by_user         VARCHAR2(1);
l_cost_locked_by_person_id      NUMBER;
l_rev_locked_by_person_id       NUMBER;
l_resource_level        VARCHAR2(1); -- bug 2813661
l_cost_resource_level       VARCHAR2(1); -- bug 2813661
l_revenue_resource_level    VARCHAR2(1); -- bug 2813661

-- local error handling variables
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_version_id                   pa_budget_versions.budget_version_id%TYPE;
l_module_name                  VARCHAR2(100);
l_msg_index_out            NUMBER;

BEGIN
  --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_view_initialize', '100: entered procedure', 2);
  x_msg_count := 0;
  l_module_name:='pa_fp_view_plans_txn_pub';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_debug.set_err_stack('pa_fp_view_plans_txn_pub.nonhgrid_view_initialize');
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');
  pa_debug.set_process('PLSQL','LOG',l_debug_mode);
  IF ( p_cost_version_id IS NULL
      AND p_rev_version_id IS NULL ) THEN

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Both cost and rev version ids are null' ;
          pa_debug.write('nonhgrid_view_initialize: ' || l_module_name,pa_debug.g_err_stage,1);
      END IF;
      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

  END IF;
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Inside nonhgrid_view_initialize...';
          pa_debug.write('nonhgrid_view_initialize: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

  -- bug 3146974 GET AUTO BASELINED FLAG
  x_auto_baselined_flag :=
           Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id); -- OUTPUT: x_auto_baselined_flag

  /*Populate l_version_id with any one of the version ids passed so that the common global
    variables can be initialised
  */
  IF (p_cost_version_id IS NOT NULL) THEN
      l_version_id :=p_cost_version_id;
  ELSIF (p_rev_version_id IS NOT NULL) THEN
      l_version_id :=p_rev_version_id;
  END IF;


  pa_fp_view_plans_txn_pub.G_SINGLE_VERSION_ID := l_version_id;

  SELECT nvl(bv.approved_cost_plan_type_flag, 'N'),
         nvl(bv.approved_rev_plan_type_flag, 'N')
  INTO   l_ac_flag,
         l_ar_flag
  FROM   pa_budget_versions bv
  WHERE bv.budget_version_id = l_version_id;

-- >>>>> BUG FIX 2602849: need to check only AR flag <<<<<
-- >>>> BUG FIX 2650878: project or projfunc, depending on AR flag <<<<
  if l_ar_flag = 'Y' then
    -- APPROVED REVENUE: go with Project Functional Currency
    x_ar_ac_flag := 'Y';
    -- get PROJECT CURRENCY
    select projfunc_currency_code
      into x_project_currency
      from pa_projects_all
      where project_id = p_project_id;
    pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJFUNC';
  else
    -- NOT APPROVED REVENUE: go with Project Currency
    x_ar_ac_flag := 'N';
    -- get PROJECT CURRENCY
    select project_currency_code
      into x_project_currency
      from pa_projects_all
      where project_id = p_project_id;
    pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJECT';
  end if; -- approved revenue flag

  select fin_plan_type_id,
         NVL(plan_in_multi_curr_flag, 'N'),
         proj_fp_options_id
    into l_fin_plan_type_id,
         l_multi_curr_flag,
         l_proj_fp_options_id
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_version_id = l_version_id and
          fin_plan_option_level_code = 'PLAN_VERSION';
  x_fin_plan_type_id := l_fin_plan_type_id;

  -- 05/30/03  FP L: Plan Class Security
  x_plan_class_code := pa_fin_plan_type_global.plantype_to_planclass
        (p_project_id, l_fin_plan_type_id);

  select proj_fp_options_id,
         fin_plan_preference_code
    into x_plan_type_fp_options_id,
         l_fp_preference_code
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_type_id = l_fin_plan_type_id and
          fin_plan_option_level_code = 'PLAN_TYPE';
  pa_fp_view_plans_txn_pub.G_PLAN_TYPE_ID := l_fin_plan_type_id;
  pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := l_multi_curr_flag;

  -- get PLAN TYPE NAME
  select name
    into x_plan_type_name
    from pa_fin_plan_types_tl
    where fin_plan_type_id = l_fin_plan_type_id and
          language = USERENV('LANG');

  -- retrieve report_labor_hrs, margin_derived codes from PLAN TYPE entry
  select report_labor_hrs_from_code,
         margin_derived_from_code
    into l_report_labor_hrs_from_code,
         l_margin_derived_code
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_type_id = l_fin_plan_type_id and
          fin_plan_option_level_code = 'PLAN_TYPE';
  pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := l_report_labor_hrs_from_code;
  pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE := l_margin_derived_code;


  /*Fix for bug 2699644 starts*/
  /*Get the values for the revenue version id and populate the global variables with those
    values
  */
  IF(p_cost_version_id IS NOT NULL) THEN

      SELECT DECODE(rl.group_resource_type_id,
                         0, 'NONGROUPED',
                         'GROUPED'),
                  rl.resource_list_id,
                  bv.record_version_number,
                  nvl(rl.uncategorized_flag, 'N'),
            DECODE(bv.budget_status_code,
                  'B', 'B',
                  'W')
      INTO   l_grouping_type,
             l_resource_list_id,
             l_rv_number,
             l_uncategorized_flag,
             l_c_budget_status_code
      FROM   pa_budget_versions bv,
             pa_resource_lists_all_bg rl
      WHERE  bv.budget_version_id = p_cost_version_id and
             bv.resource_list_id = rl.resource_list_id;


      pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := p_cost_version_id;
      pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
      IF l_fp_preference_code = 'COST_AND_REV_SAME' THEN
           pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'ANY';
      ELSE
           pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'COST';
      END IF;

      x_cost_rv_number := l_rv_number;
      x_cost_rl_id := l_resource_list_id;

  ELSE

      pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := -1;
      pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := '';
      pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := null;
      l_grouping_type:=null;
      x_cost_rv_number := -1;
      x_cost_rl_id := -1;
  END IF;

  IF(p_rev_version_id IS NOT NULL) THEN

      SELECT DECODE(rl.group_resource_type_id,
                         0, 'NONGROUPED',
                         'GROUPED'),
                  rl.resource_list_id,
                  bv.record_version_number,
                  nvl(rl.uncategorized_flag, 'N'),
            DECODE(bv.budget_status_code,
                  'B', 'B',
                  'W')
      INTO   l_compl_grouping_type,
             l_compl_resource_list_id,
             l_compl_rv_number,
             l_compl_uncategorized_flag,
             l_r_budget_status_code
      FROM   pa_budget_versions bv,
             pa_resource_lists_all_bg rl
      WHERE  bv.budget_version_id = p_rev_version_id and
             bv.resource_list_id = rl.resource_list_id;


      pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := p_rev_version_id;
      pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_compl_grouping_type;
      IF (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'COST') THEN

          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'BOTH';

      ELSE
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'REVENUE';
      END IF;

      x_rev_rv_number := l_compl_rv_number;
      x_rev_rl_id := l_compl_resource_list_id;

  ELSE

      pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := -1;
      pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := '';
      x_rev_rv_number := -1;
      x_rev_rl_id := -1;
      l_compl_grouping_type:=null;

  END IF;

  --  BUG FIX 3050448: replace x_budget_status_code with
  --                   x_cost_budget_status_code and x_rev_budget_status_code
/*
  IF(l_c_budget_status_code='W' OR
     l_r_budget_status_code='W') THEN
      x_budget_status_code:='W';
  ELSE
      x_budget_status_code:='B';
  END IF;
*/
  x_cost_budget_status_code := l_c_budget_status_code;
  x_rev_budget_status_code := l_r_budget_status_code;
  -- END BUG FIX 3050448

  IF l_grouping_type = 'GROUPED' THEN
     IF l_compl_grouping_type = 'GROUPED' THEN
            x_grouping_type := 'GROUPED';
     ELSE
            x_grouping_type := 'MIXED';
     END IF;
  ELSE
     IF l_compl_grouping_type = 'GROUPED' THEN
            x_grouping_type := 'MIXED';
     ELSE
            x_grouping_type := 'NONGROUPED';
     END IF;
  END IF;

  IF (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'BOTH') THEN

           -- planning level code for cost version: P, T, L, or M
          SELECT cost_fin_plan_level_code
          INTO   l_cost_planning_level
          FROM   pa_proj_fp_options
          WHERE  proj_fp_options_id = l_proj_fp_options_id;

           -- planning level code for revenue (compl) version
          SELECT revenue_fin_plan_level_code
          INTO   l_rev_planning_level
          FROM   pa_proj_fp_options
          WHERE  fin_plan_version_id = p_rev_version_id;

          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          IF (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') THEN
              x_planning_level := 'P';
          ELSE
              x_planning_level := l_cost_planning_level;
          END IF;

  ELSIF (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'ANY') THEN

          SELECT all_fin_plan_level_code
          INTO   l_cost_planning_level
          FROM   pa_proj_fp_options
          WHERE  fin_plan_version_id = p_cost_version_id;

          x_planning_level := l_cost_planning_level;

  ELSIF (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'REVENUE') THEN

          SELECT revenue_fin_plan_level_code
          INTO   l_rev_planning_level
          FROM   pa_proj_fp_options
          WHERE  fin_plan_version_id = p_rev_version_id;

          x_planning_level := l_rev_planning_level;

  ELSIF (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'COST') THEN

          SELECT cost_fin_plan_level_code
          INTO   l_cost_planning_level
          FROM   pa_proj_fp_options
          WHERE  fin_plan_version_id = p_cost_version_id;

          x_planning_level := l_cost_planning_level;

  END IF;

  x_display_from := pa_fp_view_plans_txn_pub.G_DISPLAY_FROM;
  x_multicurrency_flag := pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG;
  x_cost_version_id := pa_fp_view_plans_txn_pub.G_COST_VERSION_ID;
  x_rev_version_id := pa_fp_view_plans_txn_pub.G_REV_VERSION_ID;
  x_labor_hrs_from_code := pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE;

  pa_fp_view_plans_txn_pub.G_COST_RESOURCE_LIST_ID := x_cost_rl_id;
  pa_fp_view_plans_txn_pub.G_REVENUE_RESOURCE_LIST_ID := x_rev_rl_id;


  if (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'BOTH' and
      l_uncategorized_flag = 'Y' and l_compl_uncategorized_flag = 'Y') or
     (pa_fp_view_plans_txn_pub.G_DISPLAY_FROM <> 'BOTH' and
      l_uncategorized_flag = 'Y') then
    x_planned_resources_flag := 'N';
  else
    x_planned_resources_flag := 'Y';
  end if;

  -- determine locked status of budget version(s)
  -- BUG 2813661: use pa_fp_view_plans_util.get_plan_version_res_level to set
  -- x_grouping_type and x_planned_resources_flag
  if x_display_from = 'ANY' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
        x_rev_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
      x_rev_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
     p_entered_amts_only_flag => 'N',
     x_resource_level     => l_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
    if l_resource_level = 'R' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'N';
    elsif l_resource_level = 'G' then
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'Y';
    elsif l_resource_level = 'M' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'Y';
    else
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'N';
    end if;
    else
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;

  elsif x_display_from = 'COST' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
     p_entered_amts_only_flag => 'Y',
     x_resource_level     => l_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
    if l_resource_level = 'R' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'N';
    elsif l_resource_level = 'G' then
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'Y';
    elsif l_resource_level = 'M' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'Y';
    else
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'N';
    end if;
    else
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;

  elsif x_display_from = 'REVENUE' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         x_is_locked_by_userid  => l_is_rev_locked_by_user,
         x_locked_by_person_id  => l_rev_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_rev_locked_by_user

    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
     p_entered_amts_only_flag => 'Y',
     x_resource_level     => l_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
    if l_resource_level = 'R' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'N';
    elsif l_resource_level = 'G' then
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'Y';
    elsif l_resource_level = 'M' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'Y';
    else
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'N';
    end if;
    else
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;

  elsif x_display_from = 'BOTH' then

   -- FOR COST VERSION
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
     p_entered_amts_only_flag => 'Y',
     x_resource_level     => l_cost_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;

    -- FOR REVENUE VERSION
        pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         x_is_locked_by_userid  => l_is_rev_locked_by_user,
         x_locked_by_person_id  => l_rev_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
     p_entered_amts_only_flag => 'Y',
     x_resource_level     => l_revenue_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;
    if l_cost_resource_level = 'R' and l_revenue_resource_level = 'R' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'N';
    elsif l_cost_resource_level = 'G' and l_revenue_resource_level = 'G' then
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'Y';
    else
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'Y';
    end if;

  end if;

  --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_view_initialize', '1000: exited procedure', 2);
END nonhgrid_view_initialize;
/* ------------------------------------------------------------- */

/* ----------------------  CHANGE HISTORY ----------------------- */
-- 10/08/02: x_planned_resources_flag:
--           check pa_resource_lists.uncategorized_flag
-- 10/28/02: make sure resource list global variables are populated
--           for resource query to work
-- 11/08/02: x_project_currency = project or projfunc currency, depending if
--           plan type = AR
--           populate G_DISPLAY_CURRENCY_TYPE
-- 12/30/02: x_project_currency can be AGREEMENT CURRENCY if ci_id is not null
-- 07/30/03: changed logic for populating x_planned_resources_flag and x_grouping_type
--           BUG 2813661
procedure nonhgrid_edit_initialize
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
--     p_fin_plan_type_id     IN  pa_proj_fp_options.fin_plan_type_id%TYPE,
--     p_proj_fp_options_id   IN  pa_proj_fp_options.proj_fp_options_id%TYPE,
--     p_working_or_baselined IN  VARCHAR2,
--     p_cost_or_revenue      IN  VARCHAR2,
     x_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_current_working_flag OUT NOCOPY pa_budget_versions.current_working_flag%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id      OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,  -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,  -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_record_version_number OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_plan_version_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id     OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_ar_ac_flag           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_class_code      OUT NOCOPY VARCHAR2,  -- FP L: Plan Class Security --File.Sql.39 bug 4440895
     x_display_res_flag     OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
is

l_fin_plan_type_id     pa_proj_fp_options.fin_plan_type_id%TYPE;
l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
l_working_or_baselined VARCHAR2(30);
l_cost_or_revenue      VARCHAR2(30);
l_ar_flag              pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_ac_flag              pa_budget_versions.approved_cost_plan_type_flag%TYPE;
l_ci_id            pa_budget_versions.ci_id%TYPE;
l_agreement_id         pa_budget_versions.agreement_id%TYPE;
l_agreement_currency_code   pa_agreements_all.agreement_currency_code%TYPE;

l_fp_preference_code         pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_report_labor_hrs_from_code pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_margin_derived_code        pa_proj_fp_options.margin_derived_from_code%TYPE;
l_grouping_type              VARCHAR2(30);
l_compl_grouping_type        VARCHAR2(30);
l_cost_planning_level        pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_rev_planning_level         pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
l_compl_resource_list_id     pa_budget_versions.resource_list_id%TYPE;
l_version_type               pa_budget_versions.version_type%TYPE;
l_uncategorized_flag         pa_resource_lists.uncategorized_flag%TYPE;
l_resource_level         VARCHAR2(1); -- bug 2813661

-- local debugging variables
l_return_status          VARCHAR2(1);
l_msg_count          NUMBER(10);
l_msg_data           VARCHAR2(2000);
l_msg_index_out          NUMBER(10);

BEGIN
  --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '100: entered procedure', 2);
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get AUTO BASELINED FLAG
  x_auto_baselined_flag :=
        Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id);

  select DECODE(rl.group_resource_type_id,
                0, 'NONGROUPED',
                'GROUPED'),
         bv.resource_list_id,
         nvl(bv.budget_status_code, 'W'),
         DECODE(bv.budget_status_code,
                'B', 'B',
                'W'),
         DECODE(bv.version_type,
                'COST', 'C',
                'REVENUE', 'R',
                'N'),
         nvl(bv.current_working_flag, 'N'),
         bv.record_version_number,
         nvl(bv.approved_cost_plan_type_flag, 'N'),
         nvl(bv.approved_rev_plan_type_flag, 'N'),
         nvl(rl.uncategorized_flag, 'N')
    into l_grouping_type,
         l_resource_list_id,
         x_budget_status_code,
         l_working_or_baselined,
         l_cost_or_revenue,
         x_current_working_flag,
         x_record_version_number,
         l_ac_flag,
         l_ar_flag,
         l_uncategorized_flag
    from pa_budget_versions bv,
         pa_resource_lists_all_bg rl
    where bv.budget_version_id = p_budget_version_id and
          bv.resource_list_id = rl.resource_list_id;
  pa_fp_view_plans_txn_pub.G_SINGLE_VERSION_ID := p_budget_version_id;
-- >>>>> BUG FIX 2602849: need to check only AR flag <<<<<
-- >>>> BUG FIX 2650878: project or projfunc, depending on AR flag <<<<
  if l_ar_flag = 'Y' then
    -- APPROVED REVENUE: go with Project Functional Currency
    x_ar_ac_flag := 'Y';
    -- get PROJECT CURRENCY
    select projfunc_currency_code
      into x_project_currency
      from pa_projects_all
      where project_id = p_project_id;
    -- >>>> BUG FIX 2730016: check pa_agreements_all as well
    select ci_id,
       agreement_id
      into l_ci_id,
       l_agreement_id
      from pa_budget_versions
      where budget_version_id = p_budget_version_id;
    if l_ci_id is not null and l_agreement_id is not null then
      select nvl (agreement_currency_code, 'ANY')
        into l_agreement_currency_code
        from pa_agreements_all
        where agreement_id = l_agreement_id;
      if l_agreement_currency_code <> 'ANY' then
    x_project_currency := l_agreement_currency_code;
      end if;
    end if; -- ci_id is not null
    pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJFUNC';
  else
    -- NOT APPROVED REVENUE: go with Project Currency
    x_ar_ac_flag := 'N';
    -- get PROJECT CURRENCY
    select project_currency_code
      into x_project_currency
      from pa_projects_all
      where project_id = p_project_id;
    pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJECT';
  end if; -- approved revenue flag

  select fin_plan_type_id,
         NVL(plan_in_multi_curr_flag, 'N'),
         proj_fp_options_id
    into l_fin_plan_type_id,
         l_multi_curr_flag,
         l_proj_fp_options_id
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_version_id = p_budget_version_id and
          fin_plan_option_level_code = 'PLAN_VERSION';

  -- 05/30/03  FP L: Plan Class Security
  x_plan_class_code := pa_fin_plan_type_global.plantype_to_planclass
                (p_project_id, l_fin_plan_type_id);

  -- 8/26/02: retrieve fp_options_id for plan_version and plan_type level, and plan_type_id
  x_fin_plan_type_id := l_fin_plan_type_id;
  x_plan_version_fp_options_id := l_proj_fp_options_id;
  select proj_fp_options_id,
         fin_plan_preference_code
    into x_plan_type_fp_options_id,
         l_fp_preference_code
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_type_id = l_fin_plan_type_id and
          fin_plan_option_level_code = 'PLAN_TYPE';

  pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := l_report_labor_hrs_from_code;
  pa_fp_view_plans_txn_pub.G_PLAN_TYPE_ID := l_fin_plan_type_id;
  pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := l_multi_curr_flag;
  -- retrieve report_labor_hrs, margin_derived codes from PLAN TYPE entry
  select report_labor_hrs_from_code,
         margin_derived_from_code
    into l_report_labor_hrs_from_code,
         l_margin_derived_code
    from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_type_id = l_fin_plan_type_id and
          fin_plan_option_level_code = 'PLAN_TYPE';
  pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := l_report_labor_hrs_from_code;
  pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE := l_margin_derived_code;
  -- get PLAN TYPE NAME

  select name
    into x_plan_type_name
    from pa_fin_plan_types_tl
    where fin_plan_type_id = l_fin_plan_type_id and
          language = USERENV('LANG');


  if l_fp_preference_code = 'COST_AND_REV_SAME' then
    --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '200: pref = COST_AND_REV_SAME', 1);
    pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := p_budget_version_id;
    pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := p_budget_version_id;
    pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
    pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
    pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'ANY';

    x_grouping_type := l_grouping_type;
    -- set planning level code for page: P, T, L, or M
    select all_fin_plan_level_code
      into l_cost_planning_level
      from pa_proj_fp_options
      where proj_fp_options_id = l_proj_fp_options_id;
    x_planning_level := l_cost_planning_level;
    x_cost_rl_id := l_resource_list_id;
    x_rev_rl_id := l_resource_list_id;

  elsif l_fp_preference_code = 'COST_ONLY' then
    --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '300: pref = COST_ONLY', 1);
    pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := p_budget_version_id;
    pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := -1;
    pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
    pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := '';
    pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'COST';
    x_grouping_type := l_grouping_type;
    -- set planning level code for page: P, T, L, or M
    select cost_fin_plan_level_code
      into l_cost_planning_level
      from pa_proj_fp_options
      where proj_fp_options_id = l_proj_fp_options_id;
    x_planning_level := l_cost_planning_level;
    x_cost_rl_id := l_resource_list_id;
    x_rev_rl_id := -1;

  elsif l_fp_preference_code = 'REVENUE_ONLY' then
    --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '400: pref = REVENUE_ONLY', 1);
    pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := -1;
    pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := p_budget_version_id;
    pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := '';
    pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
    pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'REVENUE';
    x_grouping_type := l_grouping_type;
    -- set planning level code for page: P, T, L, or M
    select revenue_fin_plan_level_code
      into l_rev_planning_level
      from pa_proj_fp_options
      where proj_fp_options_id = l_proj_fp_options_id;
    x_planning_level := l_rev_planning_level;
    x_cost_rl_id := -1;
    x_rev_rl_id := l_resource_list_id;

  elsif l_fp_preference_code = 'COST_AND_REV_SEP' then
    --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '500: pref = COST_AND_REV_SEP', 1);
    -- this is a cost/revenue version that's part of a cost-revenue pairing
    -- we need to find out which one it is
    select version_type
      into l_version_type
      from pa_budget_versions
      where budget_version_id = p_budget_version_id;
    if l_version_type = 'COST' then
      -- COST VERSION: treat as if COST_ONLY
      pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := p_budget_version_id;
      pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := -1;
      pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
      pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := '';
      pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'COST';
      x_grouping_type := l_grouping_type;
      -- set planning level code for page: P, T, L, or M
      select cost_fin_plan_level_code
        into l_cost_planning_level
        from pa_proj_fp_options
        where proj_fp_options_id = l_proj_fp_options_id;
      x_planning_level := l_cost_planning_level;
      x_cost_rl_id := l_resource_list_id;
      x_rev_rl_id := -1;
    else
      -- REVENUE VERSION: treat as if REVENUE_ONLY
      pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := -1;
      pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := p_budget_version_id;
      pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := '';
      pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
      pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'REVENUE';
      x_grouping_type := l_grouping_type;
      -- set planning level code for page: P, T, L, or M
      select revenue_fin_plan_level_code
        into l_rev_planning_level
        from pa_proj_fp_options
        where proj_fp_options_id = l_proj_fp_options_id;
      x_planning_level := l_rev_planning_level;
      x_cost_rl_id := -1;
      x_rev_rl_id := l_resource_list_id;
    end if; -- l_version_type

  else
    --pa_debug.write('pa_fp_view_plans_txn_pub.hgrid_edit_initialize', '600: invalid value for FIN_PLAN_PREFERENCE_CODE', 1);
    return;
  end if; -- l_fp_preference_code

  x_display_from := pa_fp_view_plans_txn_pub.G_DISPLAY_FROM;
  x_multicurrency_flag := pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG;
  x_cost_version_id := pa_fp_view_plans_txn_pub.G_COST_VERSION_ID;
  x_rev_version_id := pa_fp_view_plans_txn_pub.G_REV_VERSION_ID;
  pa_fp_view_plans_txn_pub.G_COST_RESOURCE_LIST_ID := x_cost_rl_id;
  pa_fp_view_plans_txn_pub.G_REVENUE_RESOURCE_LIST_ID := x_rev_rl_id;
  if (l_uncategorized_flag = 'Y') then
    x_planned_resources_flag := 'N';
  else
    x_planned_resources_flag := 'Y';
  end if;

    -- *** BUG 2813661: use pa_fp_view_plans_util.get_plan_version_res_level to set
    -- x_grouping_type and x_planned_resources_flag
    pa_fp_view_plans_util.get_plan_version_res_level
    (p_budget_version_id      => p_budget_version_id,
     p_entered_amts_only_flag => 'Y',
     x_resource_level     => l_resource_level,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data       => l_msg_data);
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
    if l_resource_level = 'R' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'N';
    elsif l_resource_level = 'G' then
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'Y';
    elsif l_resource_level = 'M' then
        x_display_res_flag := 'Y';
        x_display_resgp_flag := 'Y';
    else
        x_display_res_flag := 'N';
        x_display_resgp_flag := 'N';
    end if;
    else
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        /*
    PA_UTILS.Add_Message(p_app_short_name => 'PA',
                             p_msg_name => l_msg_data);
    */
        x_msg_count := FND_MSG_PUB.Count_Msg;
        if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
        end if;
        return;
    end if;

  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_edit_initialize', '1000: exited procedure', 2);
  END IF;
END nonhgrid_edit_initialize;
/* ------------------------------------------------------------- */

-- HISTORY
-- 10/22/2002: dlai commented out using ra_cursors; it's just a performance optimization
--             that may cause errors like bug 2637079
-- 11/08/02: the cursors are modified such that if they query from pa_resource_assignments,
--           we use the value of G_DISPLAY_CURRENCY_TYPE to determine whether to query from
--           the project columns or projfunc columns
-- 12/24/02: Bug 2710844-The view plan should show resource assignments for which budget lines exists
PROCEDURE view_plans_txn_populate_tmp
    (p_page_mode             IN   VARCHAR2,  /* V - View mode ; E - Edit Mode */
     p_project_id            IN   pa_budget_versions.project_id%TYPE,
     p_cost_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
     p_revenue_version_id    IN   pa_budget_versions.budget_version_id%TYPE,
     p_both_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
     p_project_currency      IN   pa_projects_all.project_currency_code%TYPE,
     p_get_display_from      IN   VARCHAR2,  -- 'COST', 'REVENUE', 'BOTH', 'ANY'
     p_filter_task_id        IN   pa_resource_assignments.task_id%TYPE,
     p_filter_resource_id    IN   pa_resource_list_members.resource_id%TYPE,
     p_filter_rlm_id         IN   pa_resource_assignments.resource_list_member_id%TYPE,
     p_filter_txncurrency    IN   pa_budget_lines.txn_currency_code%TYPE,
     x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data              OUT   NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

-------------------- CURSORS FOR MULTICURRENCY PLAN VERSIONS --------------------
-- 9/25/02: Inserted UNION with query from PA_RESOURCE_ASSIGNMENTS; we want to
-- return all entered rows (budget lines) as well as resource assignments for
-- which budget lines have not yet been created
--10/08/02: modified cursor query: where rlm.resource_type_code <> 'UNCATEGORIZED'

c_view_mode CONSTANT VARCHAR2(1) := 'V';
c_edit_mode CONSTANT VARCHAR2(1) := 'E';

cursor cost_csr is
select ra_cost.project_id,
       ra_cost.task_id,
       ra_cost.resource_list_member_id,
       bl_cost.resource_assignment_id,
       -1 as compl_resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type, -- used in wrapper view to decide how to handle
                                                                            -- parent_member_id = null cases
       bl_cost.txn_currency_code,
       decode((NVL(ra_cost.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) AS UNIT_OF_MEASURE,     -- ra_cost.unit_of_measure, bug 3463685
       SUM(nvl(bl_cost.quantity,0)) as quantity,
       SUM(nvl(bl_cost.txn_burdened_cost,0)) as burdened_cost,
       SUM(nvl(bl_cost.txn_raw_cost,0)) as raw_cost,
       0 as revenue,
       0 as margin,
       0 as margin_percent
  from pa_resource_assignments ra_cost,
       pa_budget_lines bl_cost,
       pa_resource_list_members rlm,
       pa_resources  pr                  -- added for bug 3463685
  where ra_cost.budget_version_id = p_cost_version_id and
        ra_cost.resource_assignment_type = 'USER_ENTERED' and
        ra_cost.resource_assignment_id = bl_cost.resource_assignment_id and
        ra_cost.resource_list_member_id = rlm.resource_list_member_id and
        rlm.resource_id = pr.resource_id and   -- added for bug 3463685
        (p_filter_task_id = -1 or ra_cost.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        (p_filter_txncurrency = 'ALL' or bl_cost.txn_currency_code = p_filter_txncurrency)
        --(bl_cost.txn_raw_cost is not null or bl_cost.txn_burdened_cost is not null)
  group by ra_cost.project_id,
           ra_cost.task_id,
           ra_cost.resource_list_member_id,
           bl_cost.resource_assignment_id,
           bl_cost.txn_currency_code,
           decode((NVL(ra_cost.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure)   --     ra_cost.unit_of_measure  bug 3463685
   UNION
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       -1 as compl_resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type,
       ftc.txn_currency_code as txn_currency_code,
       DECODE((NVL(ra.track_as_labor_flag,'N')), 'Y' , 'HOURS' , pr.unit_of_measure) as UNIT_OF_MEASURE,       --  ra.unit_of_measure, bug 3463685
       ra.total_plan_quantity as quantity,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_burdened_cost,
              ra.total_plan_burdened_cost) as burdened_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_raw_cost,
              ra.total_plan_raw_cost) as raw_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue,
              ra.total_plan_revenue) as revenue,  -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue - ra.total_project_raw_cost,
              ra.total_plan_revenue - ra.total_plan_raw_cost) as margin, -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT',
                  DECODE(ra.total_project_revenue,
                         0, 0,
                        (ra.total_project_revenue - ra.total_project_raw_cost)/
                         ra.total_project_revenue),
                DECODE(ra.total_plan_revenue,
                        0, 0,
                        (ra.total_plan_revenue - ra.total_plan_raw_cost)/
                         ra.total_plan_revenue)) as margin_percent -- null
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_fp_txn_currencies ftc,
       pa_resources pr   -- added for bug 3463685
  where ra.budget_version_id = p_cost_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
        rlm.resource_id = pr.resource_id and  -- added for bug 3463685
        ra.budget_version_id = ftc.fin_plan_version_id and
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        ftc.default_cost_curr_flag = 'Y' and
        (p_filter_txncurrency = 'ALL' or
         ftc.txn_currency_code = p_filter_txncurrency) and -- bug fix 2697775
        not exists(select bl.resource_assignment_id from pa_budget_lines bl
            where ra.resource_assignment_id = bl.resource_assignment_id) and
        p_page_mode = c_edit_mode; /* p_page_mode condition included for bug 2710844 */

cursor revenue_csr is
select ra_revenue.project_id,
       ra_revenue.task_id,
       ra_revenue.resource_list_member_id,
       bl_revenue.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping as grouping_type,
       bl_revenue.txn_currency_code,
       DECODE((NVL(ra_revenue.track_as_labor_flag,'N')), 'Y' , 'HOURS' , pr.unit_of_measure) as UNIT_OF_MEASURE,      -- ra_revenue.unit_of_measure, bug 3463685
       SUM(nvl(bl_revenue.quantity,0)) as quantity,
   --    0 as burdened_cost,
   --    0 as raw_cost,
       SUM(nvl(bl_revenue.txn_revenue,0)) as revenue
   --    0 as margin,
   --    0 as margin_percent
  from pa_resource_assignments ra_revenue,
       pa_budget_lines bl_revenue,
       pa_resource_list_members rlm,
       pa_resources pr               -- Added for bug 3463685
  where ra_revenue.budget_version_id = p_revenue_version_id and
        ra_revenue.resource_assignment_type = 'USER_ENTERED' and
        ra_revenue.resource_assignment_id = bl_revenue.resource_assignment_id and
        ra_revenue.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id and    --  added for bug 3463685
        (p_filter_task_id = -1 or ra_revenue.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'NONGROUPED' and /* Bug 2843566 - changed cost function to rev function */
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'GROUPED' and /* Bug 2843566 - changed cost function to rev
 function */
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        (p_filter_txncurrency = 'ALL' or bl_revenue.txn_currency_code = p_filter_txncurrency)
        --bl_revenue.txn_revenue is not null
  group by ra_revenue.project_id,
           ra_revenue.task_id,
           ra_revenue.resource_list_member_id,
           bl_revenue.resource_assignment_id,
           bl_revenue.txn_currency_code,
           DECODE((NVL(ra_revenue.track_as_labor_flag,'N')), 'Y' , 'HOURS' , pr.unit_of_measure)-- pr.unit_of_measure               --ra_revenue.unit_of_measure bug 3463685
  UNION
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping as grouping_type,
       ftc.txn_currency_code as txn_currency_code,
       DECODE((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) as unit_of_measure,          -- ra.unit_of_measure, bug 3463685
       ra.total_plan_quantity as quantity,
   --    0 as burdened_cost,
   --    0 as raw_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue,
              ra.total_plan_revenue) as revenue -- null
   --    0 as margin,
   --    0 as margin_percent
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_fp_txn_currencies ftc,
       pa_resources pr    -- added for bug 3463685
  where ra.budget_version_id = p_revenue_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id  and                             -- bug 3463685
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'NONGROUPED' and /* Bug 2843566 - changed cost function to rev
 function */
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'GROUPED' and /* Bug 2843566 - changed cost function to rev
 function */
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        ra.budget_version_id = ftc.fin_plan_version_id and
        ftc.default_rev_curr_flag = 'Y' and
        (p_filter_txncurrency = 'ALL' or
         ftc.txn_currency_code = p_filter_txncurrency) and -- bug fix 2697775
        not exists(select bl.resource_assignment_id from pa_budget_lines bl
            where ra.resource_assignment_id = bl.resource_assignment_id) and
        p_page_mode = c_edit_mode; /* p_page_mode condition included for bug 2710844 */

cursor all_csr is
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       bl.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type,
       bl.txn_currency_code,
       DECODE((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) as unit_of_measure,          -- ra.unit_of_measure, bug 3463685
       SUM(nvl(bl.quantity,0)) as quantity,
       SUM(nvl(bl.txn_burdened_cost,0)) as burdened_cost,
       SUM(nvl(bl.txn_raw_cost,0)) as raw_cost,
       SUM(nvl(bl.txn_revenue,0)) as revenue,
       DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
              'R', SUM(nvl(bl.txn_revenue,0)) -  SUM(nvl(bl.txn_raw_cost,0)),
              SUM(nvl(bl.txn_revenue,0)) -  SUM(nvl(bl.txn_burdened_cost,0))) as margin,
       DECODE(SUM(nvl(bl.txn_revenue,0)),
              0, 0,
              null, 0,
              DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
                     'R', (SUM(nvl(bl.txn_revenue,0)) -  SUM(nvl(bl.txn_raw_cost,0)))/
                           SUM(nvl(bl.txn_revenue,0)),
                     (SUM(nvl(bl.txn_revenue,0)) -  SUM(nvl(bl.txn_burdened_cost,0)))/
                      SUM(nvl(bl.txn_revenue,0)))) as margin_percent
  from pa_resource_assignments ra,
       pa_budget_lines bl,
       pa_resource_list_members rlm,
       pa_resources pr       -- Added for bug 3463685
  where ra.budget_version_id = p_both_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_assignment_id = bl.resource_assignment_id and
        ra.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id and   -- added for bug 3463685
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        (p_filter_txncurrency = 'ALL' or bl.txn_currency_code = p_filter_txncurrency)
  group by ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           bl.resource_assignment_id,
           bl.txn_currency_code,
           DECODE((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure)        --ra.unit_of_measure bug 3463685
   UNION
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type,
       ftc.txn_currency_code as txn_currency_code,
       DECODE((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) AS unit_of_measure,             -- ra.unit_of_measure, bug 3463685
       ra.total_plan_quantity as quantity,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_burdened_cost,
              ra.total_plan_burdened_cost) as burdened_cost, -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_raw_cost,
              ra.total_plan_raw_cost) as raw_cost, -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue,
              ra.total_plan_revenue) as revenue, -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue - ra.total_project_raw_cost,
              ra.total_plan_revenue - total_plan_raw_cost) as margin, -- null
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT',
                   DECODE(ra.total_project_revenue,
                          0, 0,
                          (ra.total_project_revenue - ra.total_project_raw_cost)/
                           ra.total_project_revenue),
                DECODE(ra.total_plan_revenue,
                       0, 0,
                       (ra.total_plan_revenue - ra.total_plan_raw_cost)/
                        ra.total_plan_revenue)) as margin_percent  -- null
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_fp_txn_currencies ftc,
       pa_resources pr        -- Added for bug 3463685
  where ra.budget_version_id = p_both_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
	pr.resource_id = rlm.resource_id and -- bug 3463685
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        ra.budget_version_id = ftc.fin_plan_version_id and
        ftc.default_all_curr_flag = 'Y' and
        (p_filter_txncurrency = 'ALL' or
         ftc.txn_currency_code = p_filter_txncurrency) and -- bug fix 2697775
        not exists(select bl.resource_assignment_id from pa_budget_lines bl
            where ra.resource_assignment_id = bl.resource_assignment_id) and
        p_page_mode = c_edit_mode; /* p_page_mode condition included for bug 2710844 */

-------------------- CURSORS FOR SINGLE CURRENCY PLAN VERSIONS --------------------
cursor cost_ra_csr is
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       -1 as compl_resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type,
       p_project_currency as txn_currency_code,
       DECODE((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) AS unit_of_measure,             -- ra.unit_of_measure, bug 3463685
       ra.total_plan_quantity as quantity,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_burdened_cost,
              ra.total_plan_burdened_cost) as burdened_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_raw_cost,
              ra.total_plan_raw_cost) as raw_cost,
       0 as revenue,
       0 as margin,
       0 as margin_percent
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_resources pr  -- added for bug 3463685
  where ra.budget_version_id = p_cost_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id  and        -- added for bug 3463685
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        exists (select 1 from pa_budget_lines bl where bl.budget_version_id = ra.budget_version_id and
                bl.resource_assignment_id = ra.resource_assignment_id
                union
                select 1 from dual where p_page_mode = c_edit_mode); /* exists condition included for bug 2710844 */

cursor revenue_ra_csr is
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping as grouping_type,
       p_project_currency as txn_currency_code,
       decode((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) AS UNIT_OF_MEASURE,           -- ra.unit_of_measure, bug 3463685
       total_plan_quantity as quantity,
   --    0 as burdened_cost,
   --    0 as raw_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue,
              ra.total_plan_revenue) as revenue
   --    0 as margin,
   --    0 as margin_percent
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_resources pr       -- Added for bug 3463685
  where ra.budget_version_id = p_revenue_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id and     -- bug 3463685
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Rev_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        exists (select 1 from pa_budget_lines bl where bl.budget_version_id = ra.budget_version_id and
                bl.resource_assignment_id = ra.resource_assignment_id
                union
                select 1 from dual where p_page_mode = c_edit_mode); /* exists condition included for bug 2710844 */

cursor all_ra_csr is
select ra.project_id,
       ra.task_id,
       ra.resource_list_member_id,
       ra.resource_assignment_id,
       pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping as grouping_type,
       p_project_currency as txn_currency_code,
       decode((NVL(ra.track_as_labor_flag,'N')),'Y','HOURS',pr.unit_of_measure) AS UNIT_OF_MEASURE,           -- ra.unit_of_measure, bug 3463685
       ra.total_plan_quantity as quantity,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_burdened_cost,
              ra.total_plan_burdened_cost) as burdened_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_raw_cost,
              ra.total_plan_raw_cost) as raw_cost,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT', ra.total_project_revenue,
              ra.total_plan_revenue) as revenue,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT',
          DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
                 'R', ra.total_project_revenue - ra.total_project_raw_cost,
                 ra.total_project_revenue - ra.total_project_burdened_cost),
          DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
                 'R', ra.total_plan_revenue - ra.total_plan_raw_cost,
                 ra.total_plan_revenue - ra.total_plan_burdened_cost)) as margin,
       DECODE(pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE,
              'PROJECT',
          DECODE(ra.total_project_revenue,
                 null, null,
                 0, 0,
                 DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
                        'R', (ra.total_project_revenue - ra.total_project_raw_cost)/
                              ra.total_project_revenue,
                        (ra.total_project_revenue -  ra.total_project_burdened_cost)/
                         ra.total_project_revenue)),
          DECODE(ra.total_project_revenue,
                 null, null,
                 0, 0,
                 DECODE(pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code,
                        'R', (ra.total_plan_revenue - ra.total_plan_raw_cost)/
                              ra.total_plan_revenue,
                        (ra.total_plan_revenue - ra.total_plan_burdened_cost)/
                         ra.total_plan_revenue))) as margin_percent
  from pa_resource_assignments ra,
       pa_resource_list_members rlm,
       pa_resources pr   -- Added for bug 3463685
  where ra.budget_version_id = p_both_version_id and
        ra.resource_assignment_type = 'USER_ENTERED' and
        ra.resource_list_member_id = rlm.resource_list_member_id and
	pr.resource_id = rlm.resource_id and    -- added for bug 3463685
        (p_filter_task_id = -1 or ra.task_id = p_filter_task_id) and
-- bug fix 2774764: there could be a mix of GROUPED and UNGROUPED resources
        (p_filter_resource_id = -1 or
            rlm.parent_member_id = p_filter_resource_id or
            (rlm.parent_member_id is null and
             rlm.resource_id = (select resource_id
                                from pa_resource_list_members
                                where resource_list_member_id = p_filter_resource_id))) and
/*
        (p_filter_resource_id = -1 or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id = p_filter_resource_id) or
            (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_resource_id)) and
*/
       (p_filter_rlm_id = -1 or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'NONGROUPED' and
             rlm.parent_member_id is null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id)) or
        (pa_fp_view_plans_txn_pub.Get_Cost_Version_Grouping = 'GROUPED' and
             rlm.parent_member_id is not null and
             rlm.resource_id = p_filter_rlm_id and
             (rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Cost_Resource_List_Id or
              rlm.resource_list_id = pa_fp_view_plans_txn_pub.Get_Revenue_Resource_List_Id))) and
        exists (select 1 from pa_budget_lines bl where bl.budget_version_id = ra.budget_version_id and
                bl.resource_assignment_id = ra.resource_assignment_id
                union
                select 1 from dual where p_page_mode = c_edit_mode); /* exists condition included for bug 2710844 */


-- PL/SQL tables

l_c_project_id_tab          pa_fp_view_plans_txn_pub.vptxn_project_id_tab;
l_c_task_id_tab             pa_fp_view_plans_txn_pub.vptxn_task_id_tab;
l_c_res_list_member_id_tab  pa_fp_view_plans_txn_pub.vptxn_res_list_member_id_tab;
l_c_res_assignment_id_tab   pa_fp_view_plans_txn_pub.vptxn_res_assignment_id_tab;
l_cr_res_assignment_id_tab  pa_fp_view_plans_txn_pub.vptxn_res_assignment_id_tab; -- for compl res_asignment_id
l_c_grouping_tab            pa_fp_view_plans_txn_pub.vptxn_grouping_type_tab;
l_c_txn_currency_code_tab   pa_fp_view_plans_txn_pub.vptxn_txn_currency_code_tab;
l_c_unit_of_measure_tab     pa_fp_view_plans_txn_pub.vptxn_unit_of_measure_tab;
l_c_quantity_tab            pa_fp_view_plans_txn_pub.vptxn_quantity_tab;
l_c_revenue_tab             pa_fp_view_plans_txn_pub.vptxn_txn_revenue_tab;
l_c_burdened_cost_tab       pa_fp_view_plans_txn_pub.vptxn_txn_burdened_cost_tab;
l_c_raw_cost_tab            pa_fp_view_plans_txn_pub.vptxn_txn_raw_cost_tab;
l_c_margin_tab              pa_fp_view_plans_txn_pub.vptxn_txn_raw_cost_tab;
l_c_margin_pct_tab          pa_fp_view_plans_txn_pub.vptxn_txn_raw_cost_tab;

l_r_project_id_tab          pa_fp_view_plans_txn_pub.vptxn_project_id_tab;
l_r_task_id_tab             pa_fp_view_plans_txn_pub.vptxn_task_id_tab;
l_r_res_list_member_id_tab  pa_fp_view_plans_txn_pub.vptxn_res_list_member_id_tab;
l_r_res_assignment_id_tab   pa_fp_view_plans_txn_pub.vptxn_res_assignment_id_tab;
l_r_grouping_tab            pa_fp_view_plans_txn_pub.vptxn_grouping_type_tab;
l_r_txn_currency_code_tab   pa_fp_view_plans_txn_pub.vptxn_txn_currency_code_tab;
l_r_unit_of_measure_tab     pa_fp_view_plans_txn_pub.vptxn_unit_of_measure_tab;
l_r_quantity_tab            pa_fp_view_plans_txn_pub.vptxn_quantity_tab;
l_r_revenue_tab             pa_fp_view_plans_txn_pub.vptxn_txn_revenue_tab;

l_cost_multi_curr_flag  pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_rev_multi_curr_flag   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_both_multi_curr_flag  pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_rec_counter           NUMBER;
l_compl_found           BOOLEAN;

BEGIN
  --hr_utility.trace_on(null, 'dlai');
  FND_MSG_PUB.initialize;
  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.init_err_stack('nonhgrid_view_initialize: ' || 'PA_FIN_PLAN_PUB.Submit_Current_Working');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  SAVEPOINT PA_FIN_PLAN_VIEWPLANS_TXN;
  -- flush out any existing data in PA_FP_TXN_LINES_TMP
  delete from PA_FP_TXN_LINES_TMP where project_id is not null;

  -- SINGLE BUDGET VERSION: both cost and revenue
  if p_get_display_from = 'ANY' then
  --hr_utility.trace('p_get_display_from = ANY');
    -- test to see if version is planned in multicurrency
    select nvl(plan_in_multi_curr_flag, 'N')
      into l_rev_multi_curr_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
                fin_plan_version_id = p_both_version_id and
            fin_plan_option_level_code = 'PLAN_VERSION';
    if l_rev_multi_curr_flag = 'Y' then
      open all_csr;
      fetch all_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close all_csr;
    else
      open all_ra_csr;
      fetch all_ra_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close all_ra_csr;
    end if; -- multi_curr_flag for ANY
    forall c in nvl(l_c_project_id_tab.first,0)..nvl(l_c_project_id_tab.last,-1)
        insert into PA_FP_TXN_LINES_TMP
            (project_id,
             task_id,
             resource_list_member_id,
             cost_resource_assignment_id,
             rev_resource_assignment_id,
             all_resource_assignment_id,
             grouping_type,
             txn_currency_code,
             unit_of_measure,
             quantity,
             revenue,
             burdened_cost,
             raw_cost,
             margin,
             margin_pct) values
            (l_c_project_id_tab(c),
             l_c_task_id_tab(c),
             l_c_res_list_member_id_tab(c),
             -1, -- cost_resource_assignment_id
             -1, -- rev_resource_assignment_id
             l_c_res_assignment_id_tab(c), -- all_resource_assignment_id
             l_c_grouping_tab(c),
             l_c_txn_currency_code_tab(c),
             l_c_unit_of_measure_tab(c),
             l_c_quantity_tab(c), -- always display the quantity from the version
             l_c_revenue_tab(c),
             l_c_burdened_cost_tab(c),
             l_c_raw_cost_tab(c),
             l_c_margin_tab(c),
             l_c_margin_pct_tab(c));

  -- SINGLE BUDGET VERSION: cost only
  elsif p_get_display_from = 'COST' then
      --hr_utility.trace('p_get_display_from = COST');
    -- test to see if version is planned in multicurrency
    select nvl(plan_in_multi_curr_flag, 'N')
      into l_cost_multi_curr_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
                fin_plan_version_id = p_cost_version_id and
            fin_plan_option_level_code = 'PLAN_VERSION';
    if l_cost_multi_curr_flag = 'Y' then
      open cost_csr;
      fetch cost_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_cr_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close cost_csr;
    else
      open cost_ra_csr;
      fetch cost_ra_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_cr_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close cost_ra_csr;
    end if; -- multicurrency test for COST
    forall c in nvl(l_c_project_id_tab.first,0)..nvl(l_c_project_id_tab.last,-1)
        insert into PA_FP_TXN_LINES_TMP
            (project_id,
             task_id,
             resource_list_member_id,
             cost_resource_assignment_id,
             rev_resource_assignment_id,
             all_resource_assignment_id,
             grouping_type,
             txn_currency_code,
             unit_of_measure,
             quantity,
             revenue,
             burdened_cost,
             raw_cost,
             margin,
             margin_pct) values
            (l_c_project_id_tab(c),
             l_c_task_id_tab(c),
             l_c_res_list_member_id_tab(c),
             l_c_res_assignment_id_tab(c), -- cost_resource_assignment_id
             l_cr_res_assignment_id_tab(c), -- revenue_resource_assignment_id = -1
             -1, -- all_resource_assignment_id
             l_c_grouping_tab(c),
             l_c_txn_currency_code_tab(c),
             l_c_unit_of_measure_tab(c),
             l_c_quantity_tab(c), -- always display the quantity from the version
             null, -- null for revenue
             l_c_burdened_cost_tab(c),
             l_c_raw_cost_tab(c),
             null, -- null for margin
             null); -- null for margin_pct

  -- SINGLE BUDGET VERSION: revenue only
  elsif p_get_display_from = 'REVENUE' then
      --hr_utility.trace('p_get_display_from = REVENUE');
    -- test to see if version is planned in multicurrency
    select nvl(plan_in_multi_curr_flag, 'N')
      into l_rev_multi_curr_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
                fin_plan_version_id = p_revenue_version_id and
            fin_plan_option_level_code = 'PLAN_VERSION';
    if l_rev_multi_curr_flag = 'Y' then
      open revenue_csr;
      fetch revenue_csr bulk collect into
          l_r_project_id_tab,
          l_r_task_id_tab,
          l_r_res_list_member_id_tab,
          l_r_res_assignment_id_tab,
          l_r_grouping_tab,
          l_r_txn_currency_code_tab,
          l_r_unit_of_measure_tab,
          l_r_quantity_tab,
          l_r_revenue_tab;
      close revenue_csr;
    else
      open revenue_ra_csr;
      fetch revenue_ra_csr bulk collect into
          l_r_project_id_tab,
          l_r_task_id_tab,
          l_r_res_list_member_id_tab,
          l_r_res_assignment_id_tab,
          l_r_grouping_tab,
          l_r_txn_currency_code_tab,
          l_r_unit_of_measure_tab,
          l_r_quantity_tab,
          l_r_revenue_tab;
      close revenue_ra_csr;
    end if; -- multicurrency test for REVENUE
    forall r in nvl(l_r_project_id_tab.first,0)..nvl(l_r_project_id_tab.last,-1)
        insert into PA_FP_TXN_LINES_TMP
            (project_id,
             task_id,
             resource_list_member_id,
             cost_resource_assignment_id,
             rev_resource_assignment_id,
             all_resource_assignment_id,
             grouping_type,
             txn_currency_code,
             unit_of_measure,
             quantity,
             revenue,
             burdened_cost,
             raw_cost,
             margin,
             margin_pct) values
            (l_r_project_id_tab(r),
             l_r_task_id_tab(r),
             l_r_res_list_member_id_tab(r),
             -1, -- cost_resource_assignment_id
             l_r_res_assignment_id_tab(r), -- rev_resource_assignment_id
             -1, -- all_resource_assignment_id
             l_r_grouping_tab(r),
             l_r_txn_currency_code_tab(r),
             l_r_unit_of_measure_tab(r),
             l_r_quantity_tab(r), -- always display the quantity from the version
             l_r_revenue_tab(r),
             null, -- null for burdened_cost
             null, -- null for raw cost
             null, -- null for margin
             null); -- null for margin_pct
  -- TWO BUDGET VERSIONS
  else
      --hr_utility.trace('p_get_display_from = BOTH');
    -- test to see if COST version is planned in multicurrency
    select nvl(plan_in_multi_curr_flag, 'N')
      into l_cost_multi_curr_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
                fin_plan_version_id = p_cost_version_id and
            fin_plan_option_level_code = 'PLAN_VERSION';
    --hr_utility.trace('l_cost_multi_curr_flag= ' || l_cost_multi_curr_flag);
    if l_cost_multi_curr_flag = 'Y' then
      open cost_csr;
      fetch cost_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_cr_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close cost_csr;
      --hr_utility.trace('opened/closed cost_csr');
    else
      open cost_ra_csr;
      fetch cost_ra_csr bulk collect into
          l_c_project_id_tab,
          l_c_task_id_tab,
          l_c_res_list_member_id_tab,
          l_c_res_assignment_id_tab,
          l_cr_res_assignment_id_tab,
          l_c_grouping_tab,
          l_c_txn_currency_code_tab,
          l_c_unit_of_measure_tab,
          l_c_quantity_tab,
          l_c_burdened_cost_tab,
          l_c_raw_cost_tab,
          l_c_revenue_tab,
          l_c_margin_tab,
          l_c_margin_pct_tab;
      close cost_ra_csr;
      --hr_utility.trace('opened/closed cost_ra_csr');
    end if; -- multicurrency test for COST
    -- test to see if REVENUE version is planned in multicurrency
    select nvl(plan_in_multi_curr_flag, 'N')
      into l_rev_multi_curr_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
                fin_plan_version_id = p_revenue_version_id and
            fin_plan_option_level_code = 'PLAN_VERSION';
    --hr_utility.trace('l_rev_multi_curr_flag= ' || l_rev_multi_curr_flag);
    if l_rev_multi_curr_flag = 'Y' then
      open revenue_csr;
      fetch revenue_csr bulk collect into
          l_r_project_id_tab,
          l_r_task_id_tab,
          l_r_res_list_member_id_tab,
          l_r_res_assignment_id_tab,
          l_r_grouping_tab,
          l_r_txn_currency_code_tab,
          l_r_unit_of_measure_tab,
          l_r_quantity_tab,
          l_r_revenue_tab;
      close revenue_csr;
      --hr_utility.trace('opened/closed revenue_csr');
    else
      open revenue_ra_csr;
      fetch revenue_ra_csr bulk collect into
          l_r_project_id_tab,
          l_r_task_id_tab,
          l_r_res_list_member_id_tab,
          l_r_res_assignment_id_tab,
          l_r_grouping_tab,
          l_r_txn_currency_code_tab,
          l_r_unit_of_measure_tab,
          l_r_quantity_tab,
          l_r_revenue_tab;
      close revenue_ra_csr;
      --hr_utility.trace('opened/closed revenue_ra_csr');
    end if; -- multicurrency test for REVENUE
    -- walk through cost table, and look for a match for each row
    for i in nvl(l_c_project_id_tab.first,0)..nvl(l_c_project_id_tab.last,-1) loop
      l_compl_found := false;
      --hr_utility.trace('outer i= ' || to_char(i));
      -- look for a row in revenue tables to complement current cost row
      --hr_utility.trace('j size= ' || to_char(l_r_project_id_tab.last));
      for j in nvl(l_r_project_id_tab.first,0)..nvl(l_r_project_id_tab.last,-1) loop
        ----hr_utility.trace('j = ' || to_char(j));
        if (l_r_project_id_tab(j) = l_c_project_id_tab(i)) and
           (l_r_task_id_tab(j) = l_c_task_id_tab(i)) and
           (l_r_res_list_member_id_tab(j) = l_c_res_list_member_id_tab(i)) and
           (l_r_txn_currency_code_tab(j) = l_c_txn_currency_code_tab(i)) and
            not l_compl_found then
          -- match has been found
          --hr_utility.trace('found match');
          --hr_utility.trace('jvalue= ' || to_char(j));
          l_compl_found := true;
          l_c_revenue_tab(i) := l_r_revenue_tab(j);
          l_cr_res_assignment_id_tab(i) := l_r_res_assignment_id_tab(j);
          -- use Get_Derive_Margin_From_Code to calculate margin
          if pa_fp_view_plans_txn_pub.Get_Derive_Margin_From_Code = 'R' then
            l_c_margin_tab(i) := l_c_revenue_tab(i) - l_c_raw_cost_tab(i);
          else
            l_c_margin_tab(i) := l_c_revenue_tab(i) - l_c_burdened_cost_tab(i);
          end if;
          -- divide by zero special case
          if l_r_revenue_tab(j) = 0 then
            l_c_margin_pct_tab(i) := 0;
          else
            l_c_margin_pct_tab(i) := l_c_margin_tab(i) / l_c_revenue_tab(i);
          end if;
          -- stamp QUANTITY and UNIT OF MEASURE based on the correct source
          if pa_fp_view_plans_txn_pub.Get_Report_Labor_Hrs_From_Code = 'REVENUE' then
            l_c_quantity_tab(i) := l_r_quantity_tab(j);
            l_c_unit_of_measure_tab(i) := l_r_unit_of_measure_tab(j);
          end if;
/*
          -- finally, delete the revenue row from the revenue table
          l_r_project_id_tab.delete(j);
          l_r_task_id_tab.delete(j);
          l_r_res_list_member_id_tab.delete(j);
          l_r_res_assignment_id_tab.delete(j);
          l_r_txn_currency_code_tab.delete(j);
          l_r_unit_of_measure_tab.delete(j);
          l_r_quantity_tab.delete(j);
          l_r_revenue_tab.delete(j);
*/
        end if; -- if complement found

         -- the following is part of the regular loop processing, because we need to start
         -- deleting IMMEDIATELY after the match has been found.
         if l_compl_found then
          -- WHEN WE DELETE ROW, WE NEED TO SHIFT ALL THE OTHER ROWS UP
          if j=l_r_project_id_tab.last then
            -- We've reached the last row; delete it
            l_r_project_id_tab.delete(j);
            l_r_task_id_tab.delete(j);
            l_r_res_list_member_id_tab.delete(j);
            l_r_res_assignment_id_tab.delete(j);
            l_r_txn_currency_code_tab.delete(j);
            l_r_unit_of_measure_tab.delete(j);
            l_r_quantity_tab.delete(j);
            l_r_revenue_tab.delete(j);
            --hr_utility.trace('deleted the last row');
          else
            -- shift up all rows after deleted row
            l_r_project_id_tab(j) := l_r_project_id_tab(j+1);
            l_r_task_id_tab(j) := l_r_task_id_tab(j+1);
            l_r_res_list_member_id_tab(j) := l_r_res_list_member_id_tab(j+1);
            l_r_res_assignment_id_tab(j) := l_r_res_assignment_id_tab(j+1);
            l_r_txn_currency_code_tab(j) := l_r_txn_currency_code_tab(j+1);
            l_r_unit_of_measure_tab(j) := l_r_unit_of_measure_tab(j+1);
            l_r_quantity_tab(j) := l_r_quantity_tab(j+1);
            l_r_revenue_tab(j) := l_r_revenue_tab(j+1);
            --hr_utility.trace('shifting to row ' || to_char(j));
          end if;
         end if;

      end loop; -- inner search loop
      -- IF COMPLEMENT NOT FOUND, null out the revenue, margin values
      if l_cr_res_assignment_id_tab(i) = -1 then
        l_c_revenue_tab(i) := null;
        l_c_margin_tab(i) := null;
        l_c_margin_pct_tab(i) := null;
      end if; -- complement not found
    end loop; -- outer loop: cost table
    --hr_utility.trace('finished first pass of match-making');
    -- now walk through revenue table, and add the unmatched rows to the cost table
    l_rec_counter := nvl(l_c_project_id_tab.last,0);  --Bug 2730209
    for k in nvl(l_r_project_id_tab.first,0)..nvl(l_r_project_id_tab.last,-1) loop
      l_rec_counter := l_rec_counter + 1;
      l_c_project_id_tab(l_rec_counter) := l_r_project_id_tab(k);
      l_c_task_id_tab(l_rec_counter) := l_r_task_id_tab(k);
      l_c_res_list_member_id_tab(l_rec_counter) := l_r_res_list_member_id_tab(k);
      l_c_res_assignment_id_tab(l_rec_counter) := -1; -- cost res_ass_id
      l_cr_res_assignment_id_tab(l_rec_counter) := l_r_res_assignment_id_tab(k); -- revenue res_ass_id
      l_c_grouping_tab(l_rec_counter) := l_r_grouping_tab(k);
      l_c_txn_currency_code_tab(l_rec_counter) := l_r_txn_currency_code_tab(k);
      l_c_unit_of_measure_tab(l_rec_counter) := l_r_unit_of_measure_tab(k);
      l_c_quantity_tab(l_rec_counter) := l_r_quantity_tab(k);
      l_c_burdened_cost_tab(l_rec_counter) := null;
      l_c_raw_cost_tab(l_rec_counter) := null;
      l_c_revenue_tab(l_rec_counter) := l_r_revenue_tab(k);
      l_c_margin_tab(l_rec_counter) := null;
      l_c_margin_pct_tab(l_rec_counter) := null;
    end loop; -- revenue table loop
    --hr_utility.trace('finished 2nd pass');
    -- FINALLY populate the global temporary table
    forall c in nvl(l_c_project_id_tab.first,0)..nvl(l_c_project_id_tab.last,-1)
        insert into PA_FP_TXN_LINES_TMP
            (project_id,
             task_id,
             resource_list_member_id,
             cost_resource_assignment_id,
             rev_resource_assignment_id,
             all_resource_assignment_id,
             grouping_type,
             txn_currency_code,
             unit_of_measure,
             quantity,
             revenue,
             burdened_cost,
             raw_cost,
             margin,
             margin_pct) values
            (l_c_project_id_tab(c),
             l_c_task_id_tab(c),
             l_c_res_list_member_id_tab(c),
             l_c_res_assignment_id_tab(c), -- cost_res_assignment_id
             l_cr_res_assignment_id_tab(c), -- rev_res_assignment_id
             -1, -- all_res_assignment_id
             l_c_grouping_tab(c),
             l_c_txn_currency_code_tab(c),
             l_c_unit_of_measure_tab(c),
             l_c_quantity_tab(c),
             l_c_revenue_tab(c), -- null values already present where needed
             l_c_burdened_cost_tab(c),  -- null values already present where needed
             l_c_raw_cost_tab(c),  -- null values already present where needed
             l_c_margin_tab(c),  -- null values already present where needed
             l_c_margin_pct_tab(c));  -- null values already present where needed
  end if; -- check bvId's
  commit;


  pa_debug.reset_err_stack;

exception
    when others then
      rollback to PA_FIN_PLAN_VIEWPLANS_TXN;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_fp_view_plans_txn_pub',
                               p_procedure_name   => 'view_plans_txn_populate_tmp');
      pa_debug.reset_err_stack;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END view_plans_txn_populate_tmp;

---------------------------------------------------------------
-----------  BEGIN OF CHANGE ORDER / CONTROL ITEM -------------
---------------------------------------------------------------
-- CHANGE HISTORY:
-- 10/28/02: make sure resource list global variables are populated
--           for resource query to work
-- 11/08/02: x_project_currency = project or projfunc currency, depending if
--           plan type = AR
--           populate G_DISPLAY_CURRENCY_TYPE
-- 05/30/03: x_project_currency can be AGREEMENT CURRENCY if ci_id is not null
-- 07/30/03: changed logic for populating x_planned_resources_flag and x_grouping_type
--           BUG 2813661
procedure nonhgrid_view_initialize_ci
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_ci_id                IN  pa_budget_versions.ci_id%TYPE,
     p_user_id              IN  NUMBER,
     x_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id      OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,     -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,     -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,     -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_labor_hrs_from_code  OUT NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_rv_number       OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_rev_rv_number        OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_cost_locked_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_rev_locked_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_ar_ac_flag           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id     OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_display_res_flag     OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ) is

l_fin_plan_type_id     pa_proj_fp_options.fin_plan_type_id%TYPE;
l_fin_plan_type_id2    pa_proj_fp_options.fin_plan_type_id%TYPE;
l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
l_proj_fp_options_id2  pa_proj_fp_options.proj_fp_options_id%TYPE;
l_working_or_baselined VARCHAR2(30);
l_cost_or_revenue      VARCHAR2(30);
l_ar_flag              pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_ac_flag              pa_budget_versions.approved_cost_plan_type_flag%TYPE;

cursor ci_csr is
  select bv.budget_version_id,
         po.proj_fp_options_id,
         NVL(po.plan_in_multi_curr_flag, 'N') as plan_in_multi_curr_flag
  from pa_budget_versions bv,
       pa_proj_fp_options po
  where bv.project_id = p_project_id and
        bv.ci_id = p_ci_id and
        bv.budget_version_id = po.fin_plan_version_id and
        po.fin_plan_option_level_code='PLAN_VERSION';
ci_rec ci_csr%ROWTYPE;


l_fp_preference_code         pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_report_labor_hrs_from_code pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_multi_curr_flag            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_margin_derived_code        pa_proj_fp_options.margin_derived_from_code%TYPE;
l_grouping_type              VARCHAR2(30);
l_compl_grouping_type        VARCHAR2(30);
l_cost_planning_level        pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_rev_planning_level         pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
l_compl_resource_list_id     pa_budget_versions.resource_list_id%TYPE;
l_rv_number                  pa_budget_versions.record_version_number%TYPE;
l_compl_rv_number            pa_budget_versions.record_version_number%TYPE;
l_uncategorized_flag         pa_resource_lists.uncategorized_flag%TYPE;
l_compl_uncategorized_flag   pa_resource_lists.uncategorized_flag%TYPE;
l_agreement_id           pa_agreements_all.agreement_id%TYPE; -- bug 2984679
l_agreement_currency_code    pa_agreements_all.agreement_currency_code%TYPE; -- bug 2984679

l_is_cost_locked_by_user        VARCHAR2(1);
l_is_rev_locked_by_user         VARCHAR2(1);
l_cost_locked_by_person_id      NUMBER;
l_rev_locked_by_person_id       NUMBER;
l_resource_level        VARCHAR2(1); -- bug 2813661
l_cost_resource_level       VARCHAR2(1); -- bug 2813661
l_revenue_resource_level    VARCHAR2(1); -- bug 2813661

l_ci_row_index                  NUMBER := 0;
l_ci_budget_version_id          pa_budget_versions.budget_version_id%TYPE;

-- local error handling variables
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out         NUMBER;

BEGIN
  --pa_debug.write('pa_fp_view_plans_txn_pub.nonhgrid_view_initialize', '100: entered procedure', 2);
  --hr_utility.trace_on(null, 'dlai');
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- GET AUTO BASELINED FLAG
  x_auto_baselined_flag :=
        Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id);

  -- get PROJECT CURRENCY
  select project_currency_code
    into x_project_currency
    from pa_projects_all
    where project_id = p_project_id;
  x_plan_type_name := 'CI STUFF';

  open ci_csr;
  loop
    fetch ci_csr into ci_rec;
    exit when ci_csr%NOTFOUND;
      l_ci_row_index := l_ci_row_index + 1;

      --- >>>> PROCESSING FOR FIRST ROW <<<< ---
      if l_ci_row_index = 1 then
        l_ci_budget_version_id := ci_rec.budget_version_id;
        pa_fp_view_plans_txn_pub.G_SINGLE_VERSION_ID := l_ci_budget_version_id;
        select fin_plan_type_id,
               proj_fp_options_id
        into l_fin_plan_type_id,
             l_proj_fp_options_id
        from pa_proj_fp_options
        where project_id = p_project_id and
              fin_plan_version_id = ci_rec.budget_version_id and
              fin_plan_option_level_code = 'PLAN_VERSION';

        select DECODE(rl.group_resource_type_id,
                      0, 'NONGROUPED',
                      'GROUPED'),
               nvl(bv.resource_list_id,0),
               nvl(bv.budget_status_code, 'W'),
               DECODE(bv.budget_status_code,
                      'B', 'B',
                      'W'),
               DECODE(bv.version_type,
                      'COST', 'C',
                      'REVENUE', 'R',
                      'N'),
               bv.record_version_number,
               nvl(bv.approved_cost_plan_type_flag, 'N'),
               nvl(bv.approved_rev_plan_type_flag, 'N'),
               nvl(rl.uncategorized_flag, 'N'),
           bv.agreement_id
           into l_grouping_type,
                l_resource_list_id,
                x_budget_status_code,
                l_working_or_baselined,
                l_cost_or_revenue,
                l_rv_number,
                l_ac_flag,
                l_ar_flag,
                l_uncategorized_flag,
        l_agreement_id
           from pa_budget_versions bv,
                pa_resource_lists_all_bg rl
           where bv.budget_version_id = ci_rec.budget_version_id and
                 bv.resource_list_id = rl.resource_list_id;

        -- >>>> BUG FIX 2650878: project or projfunc, depending on AR flag <<<<
          if l_ar_flag = 'Y' then
        -- bug fix 2984679: For APPROVED REVENUE, check for agreement currency
        -- before using Project Functional Currency
            x_ar_ac_flag := 'Y';

           if p_ci_id is not null and l_agreement_id is not null then
            select nvl (agreement_currency_code, 'ANY')
              into l_agreement_currency_code
              from pa_agreements_all
              where agreement_id = l_agreement_id;
                if l_agreement_currency_code <> 'ANY' then
            x_project_currency := l_agreement_currency_code;
                end if;

       else
            -- get PROJECT CURRENCY
            select projfunc_currency_code
              into x_project_currency
              from pa_projects_all
              where project_id = p_project_id;
            pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJFUNC';

           end if; -- ci_id is not null

          else
            -- NOT APPROVED REVENUE: go with Project Currency
            x_ar_ac_flag := 'N';
            -- get PROJECT CURRENCY
            select project_currency_code
              into x_project_currency
              from pa_projects_all
              where project_id = p_project_id;
            pa_fp_view_plans_txn_pub.G_DISPLAY_CURRENCY_TYPE := 'PROJECT';
          end if; -- approved revenue flag

        if l_uncategorized_flag = 'Y' then
          x_planned_resources_flag := 'N';
        else
          x_planned_resources_flag := 'Y';
        end if;

        select proj_fp_options_id,
               fin_plan_preference_code
          into x_plan_type_fp_options_id,
               l_fp_preference_code
          from pa_proj_fp_options
          where project_id = p_project_id and
                fin_plan_type_id = l_fin_plan_type_id and
                fin_plan_option_level_code = 'PLAN_TYPE';

        -- retrieve report_labor_hrs, margin_derived codes from PLAN TYPE entry
        select report_labor_hrs_from_code,
               margin_derived_from_code
          into l_report_labor_hrs_from_code,
               l_margin_derived_code
          from pa_proj_fp_options
          where project_id = p_project_id and
                fin_plan_type_id = l_fin_plan_type_id and
                fin_plan_option_level_code = 'PLAN_TYPE';
        pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := l_report_labor_hrs_from_code;
        pa_fp_view_plans_txn_pub.G_PLAN_TYPE_ID := l_fin_plan_type_id;
        pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := ci_rec.plan_in_multi_curr_flag;

        pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE := l_margin_derived_code;

        if l_fp_preference_code = 'COST_AND_REV_SAME' then
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'ANY';
          x_grouping_type := l_grouping_type;
          -- set planning level code for page: P, T, L, or M
          select all_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          x_planning_level := l_cost_planning_level;
          x_cost_rv_number := l_rv_number;
          x_rev_rv_number := l_rv_number;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := l_resource_list_id;

        elsif l_fp_preference_code = 'COST_ONLY' then
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := -1;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'COST';
          x_grouping_type := l_grouping_type;
          -- set planning level code for page: P, T, L, or M
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          x_planning_level := l_cost_planning_level;
          x_cost_rv_number := l_rv_number;
          x_rev_rv_number := -1;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := -1;

        elsif l_fp_preference_code = 'REVENUE_ONLY' then
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := -1;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'REVENUE';
          x_grouping_type := l_grouping_type;
          -- set planning level code for page: P, T, L, or M
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          x_planning_level := l_rev_planning_level;
          x_cost_rv_number := -1;
          x_rev_rv_number := l_rv_number;
          x_cost_rl_id := -1;
          x_rev_rl_id := l_resource_list_id;
        end if;

      --- >>>> PROCESSING FOR SECOND ROW <<<< ---
      else
        -- what we do w/second row depends on the PLAN PREFERENCE CODE
        -- NOTE: if COST_AND_REV_SAME, then we will NOT get a second row

        -- If the second record is using a different plan type, then we'll
        -- get a second REPORT_LABOR_HRS_FROM_CODE and
        -- MARGIN_DERIVED_FROM_CODE.  In this case, the one
        -- attached to the COST plan prevails.

        select fin_plan_type_id,
               proj_fp_options_id
        into l_fin_plan_type_id2,
             l_proj_fp_options_id2
        from pa_proj_fp_options
        where project_id = p_project_id and
              fin_plan_version_id = ci_rec.budget_version_id and
              fin_plan_option_level_code = 'PLAN_VERSION';
        select report_labor_hrs_from_code,
               margin_derived_from_code
          into l_report_labor_hrs_from_code,
               l_margin_derived_code
          from pa_proj_fp_options
          where project_id = p_project_id and
                fin_plan_type_id = l_fin_plan_type_id2 and
                fin_plan_option_level_code = 'PLAN_TYPE';

        if l_fp_preference_code = 'COST_ONLY' then
          -- this second row must be the complementary REVENUE version
          select DECODE(rl.group_resource_type_id,
                        0, 'NONGROUPED',
                        'GROUPED'),
                 rl.resource_list_id,
                 bv.record_version_number,
                 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
                 l_compl_resource_list_id,
                 l_compl_rv_number,
                 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := ci_rec.budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'BOTH';
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
          x_cost_rv_number := l_rv_number;
          x_rev_rv_number := l_compl_rv_number;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost version: P, T, L, or M
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- planning level code for revenue (compl) version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_cost_planning_level;
          end if;
          if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
            pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
          end if;

        elsif l_fp_preference_code = 'REVENUE_ONLY' then
          -- this second row must be the complementary COST version
          select DECODE(rl.group_resource_type_id,
                        0, 'NONGROUPED',
                        'GROUPED'),
                 rl.resource_list_id,
                 bv.record_version_number,
                 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
                 l_compl_resource_list_id,
                 l_compl_rv_number,
                 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := ci_rec.budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'BOTH';
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
          x_cost_rv_number := l_compl_rv_number;
          x_rev_rv_number := l_rv_number;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost (compl) version: P, T, L, or M
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- planning level code for revenue version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_rev_planning_level;
          end if;
          if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
            pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
          end if;
          -- ** if the second row is COST version, then its pref codes take precedence **
          if l_margin_derived_code is not null then
            pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE := l_margin_derived_code;
          end if;
          if l_fin_plan_type_id <> l_fin_plan_type_id2 then
            pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := 'COST';
          end if;


        elsif l_fp_preference_code = 'COST_AND_REV_SEP' then
          if l_cost_or_revenue = 'R' then
            -- this second row must be the complementary COST version
          select DECODE(rl.group_resource_type_id,
                        0, 'NONGROUPED',
                        'GROUPED'),
                 rl.resource_list_id,
                 bv.record_version_number,
                 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
                 l_compl_resource_list_id,
                 l_compl_rv_number,
                 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := ci_rec.budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'BOTH';
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
          x_cost_rv_number := l_compl_rv_number;
          x_rev_rv_number := l_rv_number;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost (compl) version: P, T, L, or M
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- planning level code for revenue version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_rev_planning_level;
          end if;
          if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
            pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
          end if;
          -- ** if the second row is COST version, then its pref codes take precedence **
          if l_margin_derived_code is not null then
            pa_fp_view_plans_txn_pub.G_DERIVE_MARGIN_FROM_CODE := l_margin_derived_code;
          end if;
          if l_fin_plan_type_id <> l_fin_plan_type_id2 then
            pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE := 'COST';
          end if;


          else
            -- this second row must be the complementary REVENUE version
          select DECODE(rl.group_resource_type_id,
                        0, 'NONGROUPED',
                        'GROUPED'),
                 rl.resource_list_id,
                 bv.record_version_number,
                 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
                 l_compl_resource_list_id,
                 l_compl_rv_number,
                 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_ID  := ci_rec.budget_version_id;
          pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_txn_pub.G_DISPLAY_FROM := 'BOTH';
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
          x_cost_rv_number := l_rv_number;
          x_rev_rv_number := l_compl_rv_number;
          x_cost_rl_id := l_resource_list_id;
          x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost version: P, T, L, or M
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- planning level code for revenue (compl) version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_cost_planning_level;
          end if;
          if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
            pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
          end if;
          end if;


        end if;
      end if;
  end loop;
  close ci_csr;


  x_fin_plan_type_id := l_fin_plan_type_id;
  x_display_from := pa_fp_view_plans_txn_pub.G_DISPLAY_FROM;
  x_multicurrency_flag := pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG;
  x_cost_version_id := pa_fp_view_plans_txn_pub.G_COST_VERSION_ID;
  x_rev_version_id := pa_fp_view_plans_txn_pub.G_REV_VERSION_ID;

  x_labor_hrs_from_code := pa_fp_view_plans_txn_pub.G_REPORT_LABOR_HRS_FROM_CODE;
  if ((pa_fp_view_plans_txn_pub.G_DISPLAY_FROM = 'BOTH') and
      ((l_uncategorized_flag = 'Y') and (l_compl_uncategorized_flag = 'Y'))) or
     ((pa_fp_view_plans_txn_pub.G_DISPLAY_FROM <> 'BOTH') and
     (l_uncategorized_flag = 'Y')) then
    x_planned_resources_flag := 'N';
  else
    x_planned_resources_flag := 'Y';
  end if;

  -- determine locked status of budget version(s)
  if x_display_from = 'ANY' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
        x_rev_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
      x_rev_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

      /***** BUG 2813661: use pa_fp_view_plans_util.get_plan_version_res_level to set
                  x_grouping_type and x_planned_resources_flag  *****/
      pa_fp_view_plans_util.get_plan_version_res_level
        (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         p_entered_amts_only_flag => 'Y',
         x_resource_level     => l_resource_level,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data       => l_msg_data);
          if l_return_status = FND_API.G_RET_STS_SUCCESS then
        if l_resource_level = 'R' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'N';
        elsif l_resource_level = 'G' then
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'Y';
        elsif l_resource_level = 'M' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'Y';
        else
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'N';
        end if;
          else
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_TRUE,
                             p_msg_index      => 1,
                             p_data           => x_msg_data,
                             p_msg_index_out  => l_msg_index_out);
            end if;
            return;
          end if;

  elsif x_display_from = 'COST' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

      pa_fp_view_plans_util.get_plan_version_res_level
        (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         p_entered_amts_only_flag => 'Y',
         x_resource_level     => l_resource_level,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data       => l_msg_data);
          if l_return_status = FND_API.G_RET_STS_SUCCESS then
        if l_resource_level = 'R' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'N';
        elsif l_resource_level = 'G' then
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'Y';
        elsif l_resource_level = 'M' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'Y';
        else
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'N';
        end if;
          else
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_TRUE,
                             p_msg_index      => 1,
                             p_data           => x_msg_data,
                             p_msg_index_out  => l_msg_index_out);
            end if;
            return;
          end if;

  elsif x_display_from = 'REVENUE' then
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         x_is_locked_by_userid  => l_is_rev_locked_by_user,
         x_locked_by_person_id  => l_rev_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_rev_locked_by_user

      pa_fp_view_plans_util.get_plan_version_res_level
        (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         p_entered_amts_only_flag => 'Y',
         x_resource_level     => l_resource_level,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data       => l_msg_data);
          if l_return_status = FND_API.G_RET_STS_SUCCESS then
        if l_resource_level = 'R' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'N';
        elsif l_resource_level = 'G' then
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'Y';
        elsif l_resource_level = 'M' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'Y';
        else
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'N';
        end if;
          else
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_TRUE,
                             p_msg_index      => 1,
                             p_data           => x_msg_data,
                             p_msg_index_out  => l_msg_index_out);
            end if;
            return;
          end if;

  elsif x_display_from = 'BOTH' then
   -- FOR COST VERSION
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         x_is_locked_by_userid  => l_is_cost_locked_by_user,
         x_locked_by_person_id  => l_cost_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user

      pa_fp_view_plans_util.get_plan_version_res_level
        (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_COST_VERSION_ID,
         p_entered_amts_only_flag => 'Y',
         x_resource_level     => l_cost_resource_level,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data       => l_msg_data);
          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_TRUE,
                             p_msg_index      => 1,
                             p_data           => x_msg_data,
                             p_msg_index_out  => l_msg_index_out);
            end if;
            return;
          end if;

    -- FOR REVENUE VERSION
        pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         x_is_locked_by_userid  => l_is_rev_locked_by_user,
         x_locked_by_person_id  => l_rev_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user
      pa_fp_view_plans_util.get_plan_version_res_level
        (p_budget_version_id      => pa_fp_view_plans_txn_pub.G_REV_VERSION_ID,
         p_entered_amts_only_flag => 'Y',
         x_resource_level     => l_revenue_resource_level,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data       => l_msg_data);
          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                    PA_INTERFACE_UTILS_PUB.get_messages
                            (p_encoded        => FND_API.G_TRUE,
                             p_msg_index      => 1,
                             p_data           => x_msg_data,
                             p_msg_index_out  => l_msg_index_out);
            end if;
            return;
          end if;
          if l_cost_resource_level = 'R' and l_revenue_resource_level = 'R' then
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'N';
          elsif l_cost_resource_level = 'G' and l_revenue_resource_level = 'G' then
            x_display_res_flag := 'N';
            x_display_resgp_flag := 'Y';
          else
            x_display_res_flag := 'Y';
            x_display_resgp_flag := 'Y';
          end if;
  end if;
  pa_fp_view_plans_txn_pub.G_COST_RESOURCE_LIST_ID := x_cost_rl_id;
  pa_fp_view_plans_txn_pub.G_REVENUE_RESOURCE_LIST_ID := x_rev_rl_id;

END nonhgrid_view_initialize_ci;


/*==========================================================================================
   This is the main API which will do the necessary actions for using the Client Extensions
   for calculating the raw_cost, burdened_cost and revenue for a complete version.
 =========================================================================================*/
PROCEDURE CALCULATE_AMOUNTS_FOR_VERSION
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
l_debug_mode                   VARCHAR2(1);
l_module_name                   VARCHAR2(50) := 'pa.plsql.PA_FP_VIEW_PLANS_TXN_PUB';

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_project_id                    pa_projects_all.project_id%TYPE             ;
l_task_id_tbl                   SYSTEM.pa_num_tbl_type                      := SYSTEM.pa_num_tbl_type();
l_res_list_member_id_tbl        SYSTEM.pa_num_tbl_type                      := SYSTEM.pa_num_tbl_type();
l_resource_list_id              pa_resource_lists.RESOURCE_LIST_ID%TYPE     ;
l_resource_id_tbl               SYSTEM.pa_num_tbl_type                      := SYSTEM.pa_num_tbl_type();
l_txn_currency_code_tbl         SYSTEM.pa_varchar2_30_tbl_type              ;
l_product_code_tbl              SYSTEM.pa_varchar2_30_tbl_type              ;
l_start_date_tbl                SYSTEM.pa_date_tbl_type                     ;
l_end_date_tbl                  SYSTEM.pa_date_tbl_type                     ;
l_period_name_tbl               SYSTEM.pa_varchar2_30_tbl_type              ;
l_quantity_tbl                  SYSTEM.pa_num_tbl_type                      ;
l_txn_raw_cost_tbl              SYSTEM.pa_num_tbl_type                      ;
l_txn_burdened_cost_tbl         SYSTEM.pa_num_tbl_type                      ;
l_txn_revenue_tbl               SYSTEM.pa_num_tbl_type                      ;

l_budget_line_id_tbl            SYSTEM.pa_num_tbl_type                      ;
l_ra_id_tbl                     SYSTEM.pa_num_tbl_type                      ;
l_task_id                       pa_tasks.task_id%TYPE;
l_rlm_id                        pa_resource_list_members.resource_list_member_id%TYPE;
l_resource_id                   pa_resource_list_members.resource_id%TYPE;
l_prev_res_assignment_id        pa_resource_assignments.resource_assignment_id%TYPE := -99;

CURSOR cur_sel_bud_line IS
SELECT budget_line_id,
      resource_assignment_id,
      start_date,
      end_date,
      period_name,
      txn_currency_code,
      pm_product_code,
      quantity,
      txn_raw_cost,
      txn_burdened_cost,
      txn_revenue
  FROM pa_budget_lines
 WHERE budget_version_id = p_budget_version_id
ORDER BY resource_assignment_id;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     pa_debug.set_curr_function( p_function   => 'CALCULATE_AMOUNTS_FOR_VERSION',
                            p_debug_mode => l_debug_mode );

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'In PA_FP_VIEW_PLANS_TXN.CALCULATE_AMTS_FOR_VERSION ';
         pa_debug.write('CALCULATE_AMTS_FOR_VERSION: ' || l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (p_budget_version_id IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Invalid parameter(budget version id)';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     /* Bulk fetch the cursor records into the PL/SQL tables. */
     OPEN cur_sel_bud_line;
     LOOP

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Fetching records from Budget Lines';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          END IF;

          FETCH cur_sel_bud_line BULK COLLECT INTO
                      l_budget_line_id_tbl,
                    l_ra_id_tbl,
                      l_start_date_tbl,
                      l_end_date_tbl,
                      l_period_name_tbl,
                      l_txn_currency_code_tbl,
                      l_product_code_tbl,
                      l_quantity_tbl,
                      l_txn_raw_cost_tbl,
                      l_txn_burdened_cost_tbl,
                      l_txn_revenue_tbl
          LIMIT g_plsql_max_array_size;


          /* Delete the PL/SQL tables which are being populated manually. */
          l_task_id_tbl.delete;
          l_res_list_member_id_tbl.delete;
          l_resource_id_tbl.delete;

          IF nvl(l_budget_line_id_tbl.last,0) >= 1 THEN /* only if something is fetched */

               l_task_id_tbl.extend(l_budget_line_id_tbl.last);
               l_res_list_member_id_tbl.extend(l_budget_line_id_tbl.last);
               l_resource_id_tbl.extend(l_budget_line_id_tbl.last);

               FOR i in l_budget_line_id_tbl.first..l_budget_line_id_tbl.last
               LOOP

                    /* Fetch the relevant details for the Res Assignment that are
                       required to call the CAll_Client_Extensions API. The select
                       has to be done only once for a RA ID and so caching the RA ID.

                       Since l_prev_res_assignment_id has been initialised to -99,
                       the below condition will be satisfied even for the first time we
                       enter into this loop. */

                    IF l_prev_res_assignment_id <> l_ra_id_tbl(i) THEN

                       /* Fetch the details of the Resource Assignment if not fetched
                          already. */
                          SELECT pra.task_id,
                                 pra.resource_list_member_id,
                                 pra.project_id,
                                 prlm.resource_id,
                                 prlm.resource_list_id
                            INTO l_task_id,
                                 l_rlm_id,
                                 l_project_id,
                                 l_resource_id,
                                 l_resource_list_id
                            FROM pa_resource_assignments pra,
                                 pa_resource_list_members prlm
                           WHERE pra.resource_assignment_id = l_ra_id_tbl(i)
                             AND prlm.resource_list_member_id = pra.resource_list_member_id;

                          l_prev_res_assignment_id := l_ra_id_tbl(i);

                    ELSE

                       /* Do not fetch the details of the RA once again. The local variables
                          already have the values.*/
                          NULL;

                    END IF;

                    /* Populate the record in the PL/SQL table with the local variables populated. */

                    l_task_id_tbl(i)              := l_task_id;
                    l_res_list_member_id_tbl(i)   := l_rlm_id;
                    l_resource_id_tbl(i)          := l_resource_id;

               END LOOP;

             /* By now all the required PL/SQL tables to call the API Call_Client_Extension are
                populated. Call the overloaded API which accepts the PL/SQL tables as parameters. */

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;

                PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS
                       (  p_project_id                 => l_project_id
                         ,p_budget_version_id          => p_budget_version_id
                         ,p_task_id_tbl                => l_task_id_tbl
                         ,p_res_list_member_id_tbl     => l_res_list_member_id_tbl
                         ,p_resource_list_id           => l_resource_list_id
                         ,p_resource_id_tbl            => l_resource_id_tbl
                         ,p_txn_currency_code_tbl      => l_txn_currency_code_tbl
                         ,p_product_code_tbl           => l_product_code_tbl
                         ,p_start_date_tbl             => l_start_date_tbl
                         ,p_end_date_tbl               => l_end_date_tbl
                         ,p_period_name_tbl            => l_period_name_tbl
                         ,p_quantity_tbl               => l_quantity_tbl
                         ,px_raw_cost_tbl              => l_txn_raw_cost_tbl
                         ,px_burdened_cost_tbl         => l_txn_burdened_cost_tbl
                         ,px_revenue_tbl               => l_txn_revenue_tbl
                         ,x_return_status              => x_return_status
                         ,x_msg_count                  => x_msg_count
                         ,x_msg_data                   => x_msg_data );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'Call to PA_FP_EDIT_LINE_PKG.CALL_CLIENT_EXTENSIONS errored... ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

             /* The client extensions would have populated the Raw Cost, Burdened Cost, Revenue
                and Quantity accordingly. Bulk update the amounts on the Budget Lines table. */

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Updating the Budget Line amounts';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;

                FORALL i in l_budget_line_id_tbl.first..l_budget_line_id_tbl.last
                     UPDATE pa_budget_lines
                        SET txn_raw_cost       = l_txn_raw_cost_tbl(i)
                           ,txn_burdened_cost  = l_txn_burdened_cost_tbl(i)
                           ,txn_revenue        = l_txn_revenue_tbl(i)
                           ,quantity           = l_quantity_tbl(i)
                           ,last_update_date   = SYSDATE
                           ,last_updated_by    = FND_GLOBAL.user_id
                           ,last_update_login  = FND_GLOBAL.login_id
                      WHERE budget_line_id = l_budget_line_id_tbl(i);

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Updated - '||sql%rowcount||' records';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;

          END IF;  /* end of only if something is fetched */

     EXIT WHEN nvl(l_budget_line_id_tbl.last,0) < g_plsql_max_array_size;

     END LOOP; -- End of main loop
     CLOSE cur_sel_bud_line; -- Close the main cursor.


     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := 'Calling PA_FP_EDIT_LINE_PKG.PROCESS_BDGTLINES_FOR_VERSION';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     PA_FP_EDIT_LINE_PKG.PROCESS_BDGTLINES_FOR_VERSION
           ( p_budget_version_id  => p_budget_version_id
            ,p_calling_context    => p_calling_context
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Call to PA_FP_EDIT_LINE_PKG.PROCESS_BDGTLINES_FOR_VERSION errored... ';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting CALCULATE_AMOUNTS_FOR_VERSION';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;
     pa_debug.reset_curr_function;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     /* Rollback in case of any exceptions in the process. */
     ROLLBACK;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF cur_sel_bud_line%ISOPEN THEN
          CLOSE cur_sel_bud_line;
     END IF;

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
     /* Rollback in case of any exceptions in the process. */
     ROLLBACK;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_sel_bud_line%ISOPEN THEN
          CLOSE cur_sel_bud_line;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fp_view_plans_txn_pub'
                    ,p_procedure_name  => 'CALCULATE_AMOUNTS_FOR_VERSION'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
     END IF;
     pa_debug.reset_curr_function;
     RAISE;
END CALCULATE_AMOUNTS_FOR_VERSION;

end pa_fp_view_plans_txn_pub;

/
