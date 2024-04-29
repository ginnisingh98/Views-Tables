--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_UTILS2" as
-- $Header: PAXBUTLB.pls 120.3 2006/04/04 00:55:46 psingara noship $

------------------------------------------------------------------------------
-- This function checks if a budget-at-completion exists at the task level
-- or at the project level (if task id is passed as null)
------------------------------------------------------------------------------
--
--
--History:
--   	xx-xxx-xx	who?	- Created
--
--      22-AUG-02       jwhite    Adapted procedure to support the new FP model.
--
--
--
function check_budget_at_compl_exists (x_project_id  in number,
                                       x_task_id     in number)
  return varchar2
  is
     l_return_code   varchar2(1) := 'N';
     l_entry_level   varchar2(1) := 'P';
     l_baseline_funding   pa_projects_all.baseline_funding_flag%TYPE := 'N';   --Bug 5098809.

/* Changes for FP.M, Tracking Bug No - 3354518, we have to split
   the cursor c_chk_bud below into two different cursors, in accord
   to the permissible values of _plan_level_code columns
   The Permissible values for plan level codes are
    For Project - 'P'
    and for Task - 'T','L' */

/* Commenting out code for FP.M, Tracking Bug No - 3354518 : Starts */
/*     cursor c_chk_bud(p_entry_level varchar2) is
                  select 'Y'
                  from   pa_budget_versions v,
                         pa_budget_entry_methods m,
                         pa_budget_types bt
                  where  v.project_id = x_project_id
                  and    v.budget_status_code = 'W'
                  and    m.entry_level_code = p_entry_level
                  and    m.time_phased_type_code='N'
                  and    v.budget_entry_method_code = m.budget_entry_method_code
                  and    v.budget_type_code = bt.budget_type_Code
                  and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
                  UNION ALL
                  select 'Y'
                  from   pa_budget_versions v
                         ,pa_proj_fp_options fo
                  where  v.project_id = x_project_id
                  and    v.budget_version_id = fo.fin_plan_version_id
                  and    (fo.all_time_phased_code = 'N'
                            OR fo.cost_time_phased_code = 'N'
                               OR fo.revenue_time_phased_code = 'N')
                  and    (fo.all_fin_plan_level_code = p_entry_level
                            OR fo.cost_fin_plan_level_code = p_entry_level
                              OR fo.revenue_fin_plan_level_code = p_entry_level); */

/* Commenting out code for FP.M, Tracking Bug No - 3354518 : Ends */

/* Defining cursor below for checking  if a budget-at-completion exists at the Project level */
/* Changes for FP.M, Tracking Bug No - 3354518 */
            cursor c_chk_bud_p is
                  select 'Y'
                  from   pa_budget_versions v,
                         pa_budget_entry_methods m,
                         pa_budget_types bt
                  where  v.project_id = x_project_id
                  and    v.budget_status_code = 'W'
                  and    m.entry_level_code = 'P'
                  and    m.time_phased_type_code='N'
                  and    v.budget_entry_method_code = m.budget_entry_method_code
                  and    v.budget_type_code = bt.budget_type_Code
                  and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
		  and    nvl(v.wp_version_flag,'N') = 'N'
                  and    'X' = DECODE(l_baseline_funding, 'Y', DECODE(v.budget_type_code, 'AR', 'Z', 'X'), 'X') --Bug 5098809.
                  UNION ALL
                  select 'Y'
                  from   pa_budget_versions v
                         ,pa_proj_fp_options fo
                  where  v.project_id = x_project_id
                  and    v.budget_version_id = fo.fin_plan_version_id
                  and    fo.project_id = v.project_id  -- raja perf bug 3683360
                  and    fo.fin_plan_type_id = v.fin_plan_type_id -- raja perf bug 3683360
                  and    (fo.all_time_phased_code = 'N'
                            OR fo.cost_time_phased_code = 'N'
                               OR fo.revenue_time_phased_code = 'N')
                  and    (fo.all_fin_plan_level_code = 'P'
                            OR fo.cost_fin_plan_level_code = 'P'
                              OR fo.revenue_fin_plan_level_code = 'P')
	              and    nvl(v.wp_version_flag,'N') = 'N'
                  and    'X' = DECODE(l_baseline_funding, 'Y', DECODE(v.approved_rev_plan_type_flag, 'Y', 'Z', 'X'), 'X'); --Bug 5098809.
/* Defining cursor below for checking  if a budget-at-completion exists at the Task level */
/* Changes for FP.M, Tracking Bug No - 3354518 */
           cursor c_chk_bud_t is
                  select 'Y'
                  from   pa_budget_versions v,
                         pa_budget_entry_methods m,
                         pa_budget_types bt
                  where  v.project_id = x_project_id
                  and    v.budget_status_code = 'W'
                  and    m.entry_level_code in ('T','L','M')
                  and    m.time_phased_type_code='N'
                  and    v.budget_entry_method_code = m.budget_entry_method_code
                  and    v.budget_type_code = bt.budget_type_Code
                  and    nvl(bt.plan_type,'BUDGET') = 'BUDGET'
  		  and    nvl(v.wp_version_flag,'N') = 'N'
                  and    'X' = DECODE(l_baseline_funding, 'Y', DECODE(v.budget_type_code, 'AR', 'Z', 'X'), 'X') --Bug 5098809.
                  UNION ALL
                  select 'Y'
                  from   pa_budget_versions v
                         ,pa_proj_fp_options fo
                  where  v.project_id = x_project_id
                  and    v.budget_version_id = fo.fin_plan_version_id
                  and    fo.project_id = v.project_id  -- raja perf bug 3683360
                  and    fo.fin_plan_type_id = v.fin_plan_type_id -- raja perf bug 3683360
                  and    (fo.all_time_phased_code = 'N'
                            OR fo.cost_time_phased_code = 'N'
                               OR fo.revenue_time_phased_code = 'N')
                  and    (fo.all_fin_plan_level_code in ('T','L')
                            OR fo.cost_fin_plan_level_code in ('T','L')
                              OR fo.revenue_fin_plan_level_code in ('T','L'))
		  and    nvl(v.wp_version_flag,'N') = 'N'
                 and     'X' = DECODE(l_baseline_funding, 'Y', DECODE(v.approved_rev_plan_type_flag, 'Y', 'Z', 'X'), 'X'); --Bug 5098809.
    begin

        if (x_project_id is null) then
            return null;
        end if;

-- Bug 5098809.
        SELECT nvl(baseline_funding_flag, 'N')
        INTO   l_baseline_funding
        FROM   pa_projects_all
        WHERE  project_id = x_project_id;

/* Changes for FP.M, Tracking Bug No - 3354518 ,
   Since we no longer have a single cursor definition
   such as c_chk_bud - and we have split the cursor into
   two different cursors, c_chk_bud_p for project check,
   and c_chk_bud_t for task check, we modify the logic
   to derive the value of l_return_code accordingly below*/

/* Commenting out code for FP.M, Tracking Bug No - 3354518 : Ends */
/*      if (x_task_id is null) then -- Find Project Level Budget
            l_entry_level := 'P';
        else
            l_entry_level := 'T';    -- Find Task Level Budgets
        end if;

        open c_chk_bud(l_entry_level);

        fetch c_chk_bud into l_return_code;

        if c_chk_bud%found then
               l_return_code := 'Y';
        else
               l_return_code := 'N';
        end if;

        close c_chk_bud; */
/* Commenting out code for FP.M, Tracking Bug No - 3354518 : Ends */

/* If x_task_id is null then we fetch value into l_return_code
   from cursor c_chk_bud_p else we fetch value from c_chk_bud_r */
     if (x_task_id is null) then -- Find Project Level Budget
        open c_chk_bud_p;
        fetch c_chk_bud_p into l_return_code;
         if c_chk_bud_p%notfound then
           l_return_code := 'N';
         end if;
        close c_chk_bud_p;

     else                     -- Find Task Level Budgets
        open c_chk_bud_t;
        fetch c_chk_bud_t into l_return_code;
         if c_chk_bud_t%notfound then    --Bug 5093908.
           l_return_code := 'N';
         end if;
        close c_chk_bud_t;
     end if;

        return l_return_code;

 exception
        when others then
             return NULL;

end check_budget_at_compl_exists;

------------------------------------------------------------------------------
-- This procedure changes the status of a budget to submitted
------------------------------------------------------------------------------
procedure submit_budget(x_budget_version_id  in      number,
                        x_err_code           in out  NOCOPY number, --File.Sql.39 bug 4440895
                        x_err_stage          in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_err_stack          in out  NOCOPY varchar2 ) --File.Sql.39 bug 4440895
is
   l_old_stack   varchar2(630);

   begin
        x_err_code := 0;
        l_old_stack := x_err_stack;
        x_err_stack := x_err_stack ||'->pa_budget_utils2.submit_budget';

       --  Set the budget_status_code to 'S' (Submit).

        UPDATE pa_budget_versions
        SET budget_status_code = 'S'
        WHERE budget_version_id = x_budget_version_id;

        x_err_stack := l_old_stack;

  exception
        when others then
             x_err_code := SQLCODE;
             x_err_stage := 'PA_SQL_ERROR';

  end submit_budget;

------------------------------------------------------------------------------
-- This procedure changes the status of a budget to working
------------------------------------------------------------------------------
procedure rework_budget(x_budget_version_id  in      number,
                        x_err_code           in out  NOCOPY number, --File.Sql.39 bug 4440895
                        x_err_stage          in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_err_stack          in out  NOCOPY varchar2 ) --File.Sql.39 bug 4440895
is
   l_old_stack   varchar2(630);

   begin
        x_err_code := 0;
        l_old_stack := x_err_stack;
        x_err_stack := x_err_stack ||'->pa_budget_utils2.rework_budget';

       --  Set the budget_status_code to 'W' (Working).

        UPDATE pa_budget_versions
        SET budget_status_code = 'W'
        WHERE budget_version_id = x_budget_version_id;

        x_err_stack := l_old_stack;

  exception
        when others then
             x_err_code := SQLCODE;
             x_err_stage := 'PA_SQL_ERROR';

  end rework_budget;

------------------------------------------------------------------------------
-- This procedure checks if task is a lowest-level task in budgets .
--
-- For the old budgets model and org fcst projects, the check should be based
-- upon the resource assignments.
-- Task is considered as a lowest-level task in a budget in the following cases:
-- 1. Task  exists in budgets with BEM "By lowest task".
-- 2. Task has a parent task in the WBS, and exists in budgets with BEM
--    "By top/lowest task"
--
-- For the fin-plan model, the check should be based upon the fp elements.
-- Subtask creation is not okay for a lowest task in the following cases:
-- When x_validation_mode is U (Unrestricted mode)
--   . The task has been referred to in any of the baselined budget versions.
--   . The option has been planned at lowest task level and amounts have been
--     entered against this task.
--   . The option has been planned at top and lowest task level, the top task
--     of this task is marked to be plannable at lowest task and amounts have
--     been entered against this task
-- When x_validation_mode is R (Restricted mode),
--   .  The task is a plannable element in any budget version.
--
-- Note: The api is called only for a task that has no children. So, the check
-- needn't be done again for looking at the child tasks.
------------------------------------------------------------------------------
--
--History:
--   	xx-xxx-xx	who?	- Created
--
--      22-AUG-02       jwhite    Adapted procedure to support the new FP model.
--      24-APR-03       vejayara  Bug 2920954- Post K changes to support finplan
--      05-MAY-03       vejayara  Bug 2920954- Added x_call_mode input paramter.
--      12-MAY-03       vejayara  Bug 2920954- Changed x_call_mode input paramter
--                                to x_valiation_mode
--      05-JUN-03       rravipat  Bug 2993894-
--                                In 'Restricted' mode Subtask creation is not okay
--                                for a lowest task if the task is referenced for
--                                any of the options(project/plantype/planversion)
--                                in pa_fp_elements table.
--                                Changed c_chk_tsk_bud_R_mode cursor
--                                so that in restricted mode the query is not
--                                restricted to plan_versions alone.
--
--

  function check_task_lowest_in_budgets (x_task_id     in number,
                                         x_top_task_id in number,
                                         x_validation_mode   in varchar2)
  return number
  is
     l_return_code   number;



     cursor c_chk_tsk_bud_R_mode is
                  select 1
                  from   dual
                  where  exists
                        (select 'x' /* Old budgets model */
                         from   pa_budget_versions v,
                                pa_budget_entry_methods m,
                                pa_resource_assignments r
                         where  r.task_id = x_task_id
                         and    ( (m.entry_level_code = 'L')
                                or
                                  (m.entry_level_code = 'M'
                                   and x_task_id <> x_top_task_id)
                                )
                         and    v.budget_entry_method_code = m.budget_entry_method_code
                         and    v.budget_version_id = r.budget_version_id
                         and    v.budget_type_code is not null
                         union all
                         select 'x' /* Org Forcast Versions */
                         from   pa_budget_versions v,
                                pa_resource_assignments r,
                                pa_fin_plan_types_b pft
                         where  r.task_id = x_task_id
                         and    v.budget_type_code is null
                         and    v.budget_version_id = r.budget_version_id
                         and    v.fin_plan_type_id = pft.fin_plan_type_id
                         and    pft.fin_plan_type_code = 'ORG_FORECAST');
/* Commenting out the check for New model. FPM Dev changes - Tracking Bug - 3354518 - Starts*/
/*                       union all
                         select 'x' --  Financial plan versions
                         from   pa_fp_elements  fe
                          -- Bug 2993894 ,pa_budget_versions bv
                         where  fe.task_id = x_task_id
                          -- Bug 2993894 and    fe.fin_plan_version_id = bv.budget_version_id
                         and    (x_task_id <> x_top_task_id OR fe.top_task_planning_level = 'LOWEST')); */
/* Commenting out the check for New model. FPM Dev changes - Tracking Bug - 3354518 - Ends*/

     cursor c_chk_tsk_bud_U_mode is
                  select 1
                  from   dual
                  where  exists
                        (select 'x' /* Old budgets model */
                         from   pa_budget_versions v,
                                pa_budget_entry_methods m,
                                pa_resource_assignments r
                         where  r.task_id = x_task_id
                         and    ( (m.entry_level_code = 'L')
                                or
                                  (m.entry_level_code = 'M'
                                   and x_task_id <> x_top_task_id)
                                )
                         and    v.budget_entry_method_code = m.budget_entry_method_code
                         and    v.budget_version_id = r.budget_version_id
                         and    v.budget_type_code is not null
                         union all
                         select 'x' /* Org Forcast Versions */
                         from   pa_budget_versions v,
                                pa_resource_assignments r,
                                pa_fin_plan_types_b pft
                         where  r.task_id = x_task_id
                         and    v.budget_type_code is null
                         and    v.budget_version_id = r.budget_version_id
                         and    v.fin_plan_type_id = pft.fin_plan_type_id
                         and    pft.fin_plan_type_code = 'ORG_FORECAST');
/* Commenting out the check for New model. FPM Dev changes - Tracking Bug - 3354518 - Starts*/
/*                         union all
                         select 'x'-- Financial plan versions
                         from   pa_fp_elements  fe,
                                pa_budget_versions bv
                         where  fe.task_id = x_task_id
                         and    fe.fin_plan_version_id = bv.budget_version_id
                         and    (fe.plan_amount_exists_flag = 'Y' or bv.budget_status_code = 'B')
                         and    (x_task_id <> x_top_task_id OR fe.top_task_planning_level = 'LOWEST'));*/
/* Commenting out the check for New model. FPM Dev changes - Tracking Bug - 3354518 - Ends*/


  begin
       if x_validation_mode = 'R' then

             open c_chk_tsk_bud_R_mode;

             fetch c_chk_tsk_bud_R_mode into l_return_code;

             if c_chk_tsk_bud_R_mode%found then
                    l_return_code := 1; /* Task budget exists */
             else
                    l_return_code := 0; /* Task budget doesnt exists */
             end if;

             close c_chk_tsk_bud_R_mode;

      elsif x_validation_mode = 'U' then

             open c_chk_tsk_bud_U_mode;

             fetch c_chk_tsk_bud_U_mode into l_return_code;

             if c_chk_tsk_bud_U_mode%found then
                    l_return_code := 1; /* Task budget exists */
             else
                    l_return_code := 0; /* Task budget doesnt exists */
             end if;

             close c_chk_tsk_bud_U_mode;

      else

            /* Invalid arguments passed */

            raise pa_fp_constants_pkg.invalid_arg_exc;

      end if;

      return l_return_code;

 exception
        when others then
             l_return_code := NULL;
             raise;

end check_task_lowest_in_budgets;


end pa_budget_utils2 ;

/
