--------------------------------------------------------
--  DDL for Package Body PA_FP_VIEW_PLANS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_VIEW_PLANS_UTIL" as
/* $Header: PAFPVPUB.pls 120.1.12010000.2 2009/07/22 00:54:15 snizam ship $
   Start of Comments
   Package name     : pa_fin_plan_maint_ver_global
   Purpose          : API's for Financial Planning: View Plans Page
   History          :
   NOTE             :
   End of Comments
*/

FUNCTION calculate_gl_total
       (p_amount_code               IN pa_amount_types_b.amount_type_code%TYPE,
        p_project_id                IN pa_resource_assignments.project_id%TYPE,
        p_task_id                   IN pa_resource_assignments.task_id%TYPE,
        p_resource_list_member_id   IN pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER
is
  l_burdened_cost     NUMBER := 0;
  l_revenue           NUMBER := 0;
  l_margin            NUMBER := 0;
  l_margin_percent    NUMBER := 0;
begin
  select SUM(DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
	     'R', DECODE(amount_subtype,
                	 'RAW_COST', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                                     nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                                     nvl(period_amount5, 0) + nvl(period_amount6, 0) +
				     DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
					    'Y', nvl(preceding_periods_amount,0),
					    0) +
				     DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
					    'Y', nvl(succeeding_periods_amount,0),
					    0),
                                     0),
		  DECODE(amount_subtype,
                	 'BURDENED_COST', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                                     nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                                     nvl(period_amount5, 0) + nvl(period_amount6, 0) +
				     DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
					    'Y', nvl(preceding_periods_amount,0),
					    0) +
				     DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
					    'Y', nvl(succeeding_periods_amount,0),
					    0),
                                     0))),
         SUM(DECODE(amount_subtype,
             'REVENUE', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                        nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                        nvl(period_amount5, 0) + nvl(period_amount6, 0) +
			DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
			       'Y', nvl(preceding_periods_amount,0),
			       0) +
			DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
			       'Y', nvl(succeeding_periods_amount,0),
			       0),
             0))
    into l_burdened_cost,
         l_revenue
    from PA_FIN_VP_PDS_VIEW_TMP
    where project_id = p_project_id and
          task_id = p_task_id and
          resource_list_member_id = p_resource_list_member_id and
          amount_type in ('COST', 'REVENUE');
  l_margin := l_revenue - l_burdened_cost;
  if ((l_revenue = 0) or (l_burdened_cost = 0)) then      -- Added for bug 3651389
    l_margin_percent := 0;
  else
    l_margin_percent := (l_revenue - l_burdened_cost) / l_revenue;
  end if;

  if p_amount_code = 'MARGIN_PERCENT' then
    return l_margin_percent;
  else
    return 0;
  end if;
end calculate_gl_total;
/* ------------------------------------------------------------------ */

FUNCTION calculate_pa_total
       (p_amount_code               IN pa_amount_types_b.amount_type_code%TYPE,
        p_project_id                IN pa_resource_assignments.project_id%TYPE,
        p_task_id                   IN pa_resource_assignments.task_id%TYPE,
        p_resource_list_member_id   IN pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER
is
  l_burdened_cost     NUMBER := 0;
  l_revenue           NUMBER := 0;
  l_margin            NUMBER := 0;
  l_margin_percent    NUMBER := 0;
begin
  -- bug fix 2746025: calculate margin from RAW_COST or BURDENED_COST based
  -- on margin_derived_from_code
  select SUM(DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
	     'R', DECODE(amount_subtype,
                	 'RAW_COST', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                                     nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                                     nvl(period_amount5, 0) + nvl(period_amount6, 0) +
                                     nvl(period_amount7, 0) + nvl(period_amount8, 0) +
                                     nvl(period_amount9, 0) + nvl(period_amount10, 0) +
                                     nvl(period_amount11, 0) + nvl(period_amount12, 0) +
                                     nvl(period_amount13, 0) +
				     DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
					    'Y', nvl(preceding_periods_amount,0),
					    0) +
				     DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
					    'Y', nvl(succeeding_periods_amount,0),
					    0),
                                     0),
		  DECODE(amount_subtype,
                	 'BURDENED_COST', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                                     nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                                     nvl(period_amount5, 0) + nvl(period_amount6, 0) +
                                     nvl(period_amount7, 0) + nvl(period_amount8, 0) +
                                     nvl(period_amount9, 0) + nvl(period_amount10, 0) +
                                     nvl(period_amount11, 0) + nvl(period_amount12, 0) +
                                     nvl(period_amount13, 0) +
				     DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
					    'Y', nvl(preceding_periods_amount,0),
					    0) +
				     DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
					    'Y', nvl(succeeding_periods_amount,0),
					    0),
                                     0))),
         SUM(DECODE(amount_subtype,
             'REVENUE', nvl(period_amount1, 0) + nvl(period_amount2, 0) +
                        nvl(period_amount3, 0) + nvl(period_amount4, 0) +
                        nvl(period_amount5, 0) + nvl(period_amount6, 0) +
                        nvl(period_amount7, 0) + nvl(period_amount8, 0) +
                        nvl(period_amount9, 0) + nvl(period_amount10, 0) +
                        nvl(period_amount11, 0) + nvl(period_amount12, 0) +
                        nvl(period_amount13, 0) +
			DECODE(pa_fp_view_plans_pub.Get_Prec_Pds_Flag,
			       'Y', nvl(preceding_periods_amount,0),
			       0) +
			DECODE(pa_fp_view_plans_pub.Get_Succ_Pds_Flag,
			       'Y', nvl(succeeding_periods_amount,0),
			       0),
             0))
    into l_burdened_cost,
         l_revenue
    from PA_FIN_VP_PDS_VIEW_TMP
    where project_id = p_project_id and
          task_id = p_task_id and
          resource_list_member_id = p_resource_list_member_id and
          amount_type in ('COST', 'REVENUE');
  l_margin := l_revenue - l_burdened_cost;
   if ((l_revenue = 0) or (l_burdened_cost = 0)) then      -- Added for bug 3651389
    l_margin_percent := 0;
  else
    l_margin_percent := (l_revenue - l_burdened_cost) / l_revenue;
  end if;

  if p_amount_code = 'MARGIN_PERCENT' then
    return l_margin_percent;
  else
    return 0;
  end if;
end calculate_pa_total;

/* ------------------------------------------------------------------ */
-- This procedure checks to see if two period profiles are compatible
-- Period profiles are compatible if at least one of the following is true:
-- 1. They have the same period_profile_id
-- 2. They have different period_profile_id's, but have the same
-- period type (PA or GL), span the same number of periods, and begin on the
-- same date.
FUNCTION check_compatible_pd_profiles
    (p_period_profile_id1   IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_period_profile_id2   IN  pa_proj_period_profiles.period_profile_id%TYPE)
  return VARCHAR2
is
l_return_value  VARCHAR2(1);
l_plan_period_type1     pa_proj_period_profiles.plan_period_type%TYPE;
l_plan_period_type2     pa_proj_period_profiles.plan_period_type%TYPE;
l_number_of_periods1   pa_proj_period_profiles.number_of_periods%TYPE;
l_number_of_periods2   pa_proj_period_profiles.number_of_periods%TYPE;
l_plan_start_date1      pa_proj_period_profiles.period1_start_date%TYPE;
l_plan_start_date2      pa_proj_period_profiles.period1_start_date%TYPE;
begin
  if (p_period_profile_id1 is null) or (p_period_profile_id2 is null) then return 'N';
  elsif p_period_profile_id1 = p_period_profile_id2 then return 'Y';
  else
    l_return_value := 'N';
    select plan_period_type,
           number_of_periods,
           period1_start_date
      into l_plan_period_type1,
           l_number_of_periods1,
           l_plan_start_date1
      from pa_proj_period_profiles
      where period_profile_id = p_period_profile_id1;
    select plan_period_type,
           number_of_periods,
           period1_start_date
      into l_plan_period_type2,
           l_number_of_periods2,
           l_plan_start_date2
      from pa_proj_period_profiles
      where period_profile_id = p_period_profile_id2;
    if (l_plan_period_type1 = l_plan_period_type2) and
       (l_number_of_periods1 = l_number_of_periods2) and
       (l_plan_start_date1 = l_plan_start_date2) then
       l_return_value := 'Y';
    end if;
    return l_return_value;
  end if;
end check_compatible_pd_profiles;
/* -------------------------------------------------------------------- */

FUNCTION assign_row_level
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER
is
/* local variables */
l_return_value          NUMBER;
l_parent_task_id        pa_tasks.parent_task_id%TYPE;
l_parent_wbs_level      pa_tasks.wbs_level%TYPE;
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
BEGIN
  l_return_value := -1;
-- NEED TO ACCOUNT FOR PROJECT AND TASK LEVEL ROWS THAT ARE USER-ENTERED
 if p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id then
    if p_task_id = 0 then
      -- this is a PROJECT row
      l_return_value := 1;
    else
      -- this is a TASK row
      select nvl(parent_task_id, -99)
        into l_parent_task_id
        from pa_tasks
        where task_id = p_task_id and project_id = p_project_id;
      if l_parent_task_id = -99 then
        -- this task has no parent; so it must be a top-level task
        l_return_value := 2;
      else
        -- this task has a parent; so the level is one more than the parent
        select wbs_level
          into l_parent_wbs_level
          from pa_tasks
          where task_id = l_parent_task_id;
        l_return_value := 1 + l_parent_wbs_level + 1;  -- 1 for project, wbs_level, and 1 for child
      end if; -- parent_task_id is null
    end if;

 else  -- proceed as normal
  if p_resource_list_member_id = 0 then
    if p_task_id = 0 then
      -- if both task and rlm id are 0, then this row is a PROJECT row
      l_return_value := 1;
    else
      -- p_resource_list_member_id is 0, but p_task_id is not 0 --> TASK row
      select nvl(parent_task_id, -99)
        into l_parent_task_id
        from pa_tasks
        where task_id = p_task_id and project_id = p_project_id;
      if l_parent_task_id = -99 then
        -- this task has no parent; so it must be a top-level task
        l_return_value := 2;
      else
        -- this task has a parent; so the level is one more than the parent
        select wbs_level
          into l_parent_wbs_level
          from pa_tasks
          where task_id = l_parent_task_id;
        l_return_value := 1 + l_parent_wbs_level + 1;  -- 1 for project, wbs_level, and 1 for child
      end if; -- parent_task_id is null
    end if; -- p_task_id=0
  else
    -- p_resource_list_member_id is not 0 here
    select nvl(parent_member_id, -99)
      into l_res_parent_member_id
      from pa_resource_list_members
      where resource_list_member_id = p_resource_list_member_id;
    l_res_parent_member_id := -99; /* Added for 7514054 */
    if p_task_id = 0 then
      -- resource is direct descendant of the project
      if l_res_parent_member_id = -99 then
        -- resource is RESOURCE PARENT: level = project_level (1) + 1
        l_return_value := 2;
      else
        -- resource is RESOURCE CHILD: level = project_level (1) + 2
        l_return_value := 3;
      end if; -- res_parent_member_id is null
    else
      -- task_id is not 0, so see if it has a parent
      select nvl(parent_task_id, -99)
        into l_parent_task_id
        from pa_tasks
        where task_id = p_task_id and project_id = p_project_id;
      if l_parent_task_id = -99 then
        if l_res_parent_member_id = -99 then
          -- this resource is RESOURCE PARENT: assign level to top_task_level (2) + 1
          l_return_value := 1 + 1 + 1;
        else
          -- this resource is a RESOURCE CHILD: assign level to top_task_level (2) + 2
          l_return_value := 1 + 1 + 2;
        end if; -- res_parent_member_id is null
      else
        select wbs_level
          into l_parent_wbs_level
          from pa_tasks
          where task_id = l_parent_task_id;
        if l_res_parent_member_id = -99 then
          -- this resource is RESOURCE PARENT: assign level to parent_task_level + 1 + 1 + 1
          l_return_value := 1 + l_parent_wbs_level + 1 + 1;
        else
          -- this resource is a RESOURCE CHILD: assign level to parent_task_level + 1 + 2 + 1
          l_return_value := 1 + l_parent_wbs_level + 2 + 1;
        end if; -- res_parent_member_id is null
      end if; -- parent_task_id is null
    end if; -- p_task_id=0
  end if; -- p_resource_list_member_id=0
 end if;
  return l_return_value;
END assign_row_level;
/* -------------------------------------------------------------------- */

FUNCTION assign_parent_element
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2
as
/* local variables */
l_return_value          VARCHAR2(2000);
l_parent_task_id        pa_tasks.parent_task_id%TYPE;
l_parent_wbs_level      pa_tasks.wbs_level%TYPE;
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
l_resource_list_id      pa_resource_list_members.resource_list_id%TYPE;

BEGIN
  l_return_value := -1;
-- NEED TO ACCOUNT FOR PROJECT AND TASK LEVEL ROWS THAT ARE USER-ENTERED
 if p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id then
    if p_task_id = 0 then
	-- this is a PROJECT ROW
        l_return_value := 'NONE';
    else
	-- this is a TASK ROW
        select nvl(parent_task_id, -99)
          into l_parent_task_id
          from pa_tasks
          where task_id = p_task_id and project_id = p_project_id;
        if l_parent_task_id = -99 then
          -- this task has no parent; so it must be a top-level task, so PARENT = PROJECT
          select name || ' (' || segment1 || ')'
            into l_return_value
            from pa_projects_all
            where project_id = p_project_id;
        else
          -- this task has a parent; so PARENT = TASK NAME
          select task_name || ' (' || task_number || ')'
            into l_return_value
            from pa_tasks
            where task_id = l_parent_task_id;
        end if; -- parent_task_id is null
    end if;

 else -- proceed as normal
  if p_resource_list_member_id = 0 then
    if p_task_id = 0 then
      -- if both task and rlm id are 0, then this row is a PROJECT row, so has no parent
      l_return_value := 'NONE';
    else
      -- p_resource_list_member_id is 0, but p_task_id is not 0 --> TASK row
      select nvl(parent_task_id, -99)
        into l_parent_task_id
        from pa_tasks
        where task_id = p_task_id and project_id = p_project_id;
      if l_parent_task_id = -99 then
        -- this task has no parent; so it must be a top-level task, so PARENT = PROJECT
        select name || ' (' || segment1 || ')'
          into l_return_value
          from pa_projects_all
          where project_id = p_project_id;
      else
        -- this task has a parent; so PARENT = TASK NAME
        select task_name || ' (' || task_number || ')'
          into l_return_value
          from pa_tasks
          where task_id = l_parent_task_id;
      end if; -- parent_task_id is null
    end if; -- p_task_id=0
  else
    -- p_resource_list_member_id is not 0 here
    select nvl(parent_member_id, -99),
           resource_list_id
      into l_res_parent_member_id,
           l_resource_list_id
      from pa_resource_list_members
      where resource_list_member_id = p_resource_list_member_id;
    l_res_parent_member_id := -99; /* Added for 7514054 */
    if p_task_id = 0 then
      -- resource is direct descendant of the project
      if l_res_parent_member_id = -99 then
        -- resource is RESOURCE PARENT: PARENT = PROJECT
        select name || ' (' || segment1 || ')'
          into l_return_value
          from pa_projects_all
          where project_id = p_project_id;
      else
        -- resource is RESOURCE CHILD: PARENT = RESOURCE GROUP NAME
	/*
        select name
          into l_return_value
          from pa_resource_lists
          where resource_list_id = l_resource_list_id;
	*/
	select alias
	  into l_return_value
	  from pa_resource_list_members
	  where resource_list_member_id = l_res_parent_member_id;
      end if; -- res_parent_member_id is null
    else
      -- task_id is not 0, so see if it has a parent
      select nvl(parent_task_id, -99)
        into l_parent_task_id
        from pa_tasks
        where task_id = p_task_id and project_id = p_project_id;
      if l_parent_task_id = -99 then
        if l_res_parent_member_id = -99 then
          -- this resource is RESOURCE PARENT of a top-level task: so PARENT = PROJECT
	  -- updated 11/5/02: PARENT should be TOP-LEVEL-TASK
	  /*
          select name || ' (' || segment1 || ')'
            into l_return_value
            from pa_projects_all
            where project_id = p_project_id;
	  */
	  select task_name || ' (' || task_number || ')'
	    into l_return_value
	    from pa_tasks
	    where task_id=p_task_id;
        else
          -- this resource is a RESOURCE CHILD: so PARENT = RESOURCE GROUP NAME
	  /*
          select name
            into l_return_value
            from pa_resource_lists
            where resource_list_id = l_resource_list_id;
	  */
	  select alias
	    into l_return_value
	    from pa_resource_list_members
	    where resource_list_member_id = l_res_parent_member_id;
        end if; -- res_parent_member_id is null
      else
        if l_res_parent_member_id = -99 then
          -- this resource is RESOURCE PARENT: PARENT = PARENT TASK
          select task_name || ' (' || task_number || ')'
            into l_return_value
            from pa_tasks
	    where task_id = p_task_id;
--            where task_id = l_parent_task_id;
        else
          -- this resource is a RESOURCE CHILD: PARENT = RESOURCE GROUP NAME
	  /*
          select name
            into l_return_value
            from pa_resource_lists
            where resource_list_id = l_resource_list_id;
	  */
	  select alias
	    into l_return_value
	    from pa_resource_list_members
	    where resource_list_member_id = l_res_parent_member_id;
        end if; -- res_parent_member_id is null
      end if; -- parent_task_id is null
    end if; -- p_task_id=0
  end if; -- p_resource_list_member_id=0
 end if;
  return l_return_value;
END assign_parent_element;
/* --------------------------------------------------------------------- */

FUNCTION assign_element_name
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2
is
/* local variables */
l_return_value          VARCHAR2(2000);
l_parent_task_id        pa_tasks.parent_task_id%TYPE;
l_parent_wbs_level      pa_tasks.wbs_level%TYPE;
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
l_resource_list_id      pa_resource_list_members.resource_list_id%TYPE;

BEGIN
  l_return_value := 'dummy element name';
-- NEED TO ACCOUNT FOR PROJECT AND TASK LEVEL ROWS THAT ARE USER-ENTERED
 if p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id then
    if p_task_id = 0 then
      -- retrieve PROJECT NAME
      select name || ' (' || segment1 || ')'
        into l_return_value
        from pa_projects_all
        where project_id = p_project_id;
    else
      -- get TASK NAME
      select task_name || ' (' || task_number || ')'
        into l_return_value
        from pa_tasks
        where project_id = p_project_id and
              task_id = p_task_id;
    end if;

 else -- proceed as normal
  if p_resource_list_member_id = 0 then
    if p_task_id = 0 then
      -- if both task and rlm id are 0, then this row is a PROJECT row
      -- retrieve PROJECT NAME
      select name || ' (' || segment1 || ')'
        into l_return_value
        from pa_projects_all
        where project_id = p_project_id;
    else
      -- p_resource_list_member_id is 0, but p_task_id is not 0 --> TASK row
      -- get TASK NAME
      select task_name || ' (' || task_number || ')'
        into l_return_value
        from pa_tasks
        where project_id = p_project_id and
              task_id = p_task_id;
    end if;
  else
    -- check to see if this is a resource list or a resource
    select nvl(parent_member_id, -99),
           resource_list_id
      into l_res_parent_member_id,
           l_resource_list_id
      from pa_resource_list_members
      where resource_list_member_id = p_resource_list_member_id;
    if l_res_parent_member_id = -99 then
      -- resource is RESOURCE list
      -- get RESOURCE GROUP NAME
	/*
        select name
          into l_return_value
          from pa_resource_lists
          where resource_list_id = l_resource_list_id;
	*/
	select alias
	  into l_return_value
	  from pa_resource_list_members
	  where resource_list_member_id = p_resource_list_member_id;
    else
      -- resource is RESOURCE child
      -- get RESOURCE CHILD NAME
      select alias
        into l_return_value
        from pa_resource_list_members
        where resource_list_member_id = p_resource_list_member_id;
    end if; -- res_parent_member_id is null
  end if; -- p_resource_list_member_id=0
 end if;
  return l_return_value;
END assign_element_name;
/* --------------------------------------------------------------------- */

FUNCTION assign_element_level
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_budget_version_id	IN  pa_resource_assignments.budget_version_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2
is
/* local variables */
l_return_value          VARCHAR2(2000);
l_parent_task_id        pa_tasks.parent_task_id%TYPE;
l_parent_wbs_level      pa_tasks.wbs_level%TYPE;
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
l_resource_list_id      pa_resource_list_members.resource_list_id%TYPE;
l_labor_res_flag	pa_resource_assignments.track_as_labor_flag%TYPE;

BEGIN
  l_return_value := 'dummy element level';

-- NEED TO ACCOUNT FOR PROJECT AND TASK LEVEL ROWS THAT ARE USER-ENTERED
 if p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id then
    if p_task_id = 0 then
	l_return_value := 'PROJECT';
    else
	l_return_value := 'TASK';
    end if;
 else -- proceed as normal
  if p_resource_list_member_id = 0 then
    if p_task_id = 0 then
      -- if both task and rlm id are 0, then this row is a PROJECT row
      l_return_value := 'PROJECT';
    else
      -- p_resource_list_member_id is 0, but p_task_id is not 0 --> TASK row
      l_return_value := 'TASK';
    end if;
  else
    -- check to see if this is a resource list or a resource
    select nvl(parent_member_id, -99),
           resource_list_id
      into l_res_parent_member_id,
           l_resource_list_id
      from pa_resource_list_members
      where resource_list_member_id = p_resource_list_member_id;
    if l_res_parent_member_id = -99 then
      -- resource is RESOURCE list
        l_return_value := 'RESOURCE_LIST';
    else
      -- resource is RESOURCE child; need to determine if LABOR or NON_LABOR
      select nvl(track_as_labor_flag, 'N')
        into l_labor_res_flag
        from pa_resource_assignments
        where project_id = p_project_id and
	      budget_version_id = p_budget_version_id and
              task_id = p_task_id and
              resource_list_member_id = p_resource_list_member_id;
      if l_labor_res_flag = 'Y' then
        l_return_value := 'LABOR_RESOURCE';
      else
        l_return_value := 'NON_LABOR_RESOURCE';
      end if;
    end if; -- res_parent_member_id is null
  end if; -- p_resource_list_member_id=0
 end if;
  return l_return_value;
END assign_element_level;
/* --------------------------------------------------------------------- */
-- this procedure populates task, resource_group, or resource field for the
-- user_entered view (flat hierarchy; no HGrid)

FUNCTION assign_flat_element_names
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE,
     p_element_type             IN  VARCHAR2)
  return VARCHAR2
is
l_return_value          VARCHAR2(80);
l_resource_name         pa_resource_list_members.alias%TYPE;
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
l_resource_list_id      pa_resource_list_members.resource_list_id%TYPE;
BEGIN
  l_return_value := '';
  if p_element_type = 'TASK' then
    if p_task_id > 0 then
      select task_name || ' (' || task_number || ')'
        into l_return_value
        from pa_tasks
        where task_id = p_task_id;
    end if;
  else
    if p_resource_list_member_id > 0 then
      select alias,
             nvl(parent_member_id, -99),
             resource_list_id
      into l_resource_name,
           l_res_parent_member_id,
           l_resource_list_id
      from pa_resource_list_members
      where resource_list_member_id = p_resource_list_member_id;
      if p_element_type = 'RESOURCE' then
        -- make sure that the element is a resource (ie. has a parent member)
        if l_res_parent_member_id > 0 then
          l_return_value := l_resource_name;
        end if;
      else
        -- make sure that the element is a resource group (ie. does not have parent member)
        if l_res_parent_member_id = -99 then
          select name
            into l_return_value
            from pa_resource_lists
            where resource_list_id = l_resource_list_id;
        end if;
      end if; -- p_element_type = 'RESOURCE'
    end if;
  end if; -- p_element_type
  return l_return_value;
END assign_flat_element_names;
/* --------------------------------------------------------------------- */

procedure assign_default_amount
    (p_budget_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     x_default_amount_type_code    OUT NOCOPY pa_proj_periods_denorm.amount_type_code%TYPE, --File.Sql.39 bug 4440895
     x_default_amount_subtype_code OUT NOCOPY pa_proj_periods_denorm.amount_subtype_code%TYPE, --File.Sql.39 bug 4440895
     x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_amount_set_id         pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_budget_version_type   VARCHAR2(30);  -- used for determining how to rank the amount types
l_raw_cost_flag         pa_fin_plan_amount_sets.raw_cost_flag%TYPE;
l_burdened_cost_flag    pa_fin_plan_amount_sets.burdened_cost_flag%TYPE;
l_cost_qty_flag         pa_fin_plan_amount_sets.cost_qty_flag%TYPE;
l_revenue_flag          pa_fin_plan_amount_sets.revenue_flag%TYPE;
l_revenue_qty_flag      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE;

l_default_amount_type_code    pa_proj_periods_denorm.amount_type_code%TYPE;
l_default_amount_subtype_code pa_proj_periods_denorm.amount_subtype_code%TYPE;
l_msg_count             NUMBER := 0;
BEGIN
  select DECODE(fin_plan_preference_code,
                'COST_ONLY', cost_amount_set_id,
                'REVENUE_ONLY', revenue_amount_set_id,
                'COST_AND_REV_SAME', all_amount_set_id,
                DECODE(nvl(cost_amount_set_id,-1),
                       -1, DECODE(nvl(revenue_amount_set_id, -1),
                                  -1, nvl(all_amount_set_id, -1),
                                  revenue_amount_set_id),
                       cost_amount_set_id)),
         DECODE(fin_plan_preference_code,
                'COST_ONLY', 'COST',
                'REVENUE_ONLY', 'REVENUE',
                'COST_AND_REV_SAME', 'BOTH',
                DECODE(nvl(cost_amount_set_id,-1),
                       -1, DECODE(nvl(revenue_amount_set_id, -1),
                                  -1, 'NEITHER',
                                  'REVENUE'),
                       'COST'))
    into l_amount_set_id,
         l_budget_version_type
    from pa_proj_fp_options
    where fin_plan_version_id = p_budget_version_id and
          fin_plan_option_level_code = 'PLAN_VERSION';
  -- IF WE FIND NO AMOUNT SET, then we cannot query amount sets table, so throw error
  if l_amount_set_id = -1 then
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_NO_AMOUNT_SET_ID');
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := l_msg_count + 1;
    x_msg_count := l_msg_count;
    return;
  else
    -- retrieve ALL the relevent flags
    select raw_cost_flag,
           burdened_cost_flag,
           cost_qty_flag,
           revenue_flag,
           revenue_qty_flag
      into l_raw_cost_flag,
           l_burdened_cost_flag,
           l_cost_qty_flag,
           l_revenue_flag,
           l_revenue_qty_flag
      from pa_fin_plan_amount_sets
      where fin_plan_amount_set_id = l_amount_set_id;
    -- determine the top_ranking amount type, based on the budget version type
    if l_budget_version_type = 'COST' then
      if l_raw_cost_flag = 'Y' then
        l_default_amount_type_code := 'COST';
        l_default_amount_subtype_code := 'RAW_COST';
      elsif l_burdened_cost_flag = 'Y' then
        l_default_amount_type_code := 'COST';
        l_default_amount_subtype_code := 'BURDENED_COST';
      elsif l_cost_qty_flag = 'Y' then
        l_default_amount_type_code := 'COST';
        l_default_amount_subtype_code := 'QUANTITY';
      else
        l_default_amount_type_code := 'NONE';
        l_default_amount_subtype_code := 'NONE';
      end if; -- l_budget_version_type = 'COST'
    elsif l_budget_version_type = 'REVENUE' then
      if l_revenue_flag = 'Y' then
        l_default_amount_type_code := 'REVENUE';
        l_default_amount_subtype_code := 'REVENUE';
      elsif l_revenue_qty_flag = 'Y' then
        l_default_amount_type_code := 'QUANTITY';
        l_default_amount_subtype_code := 'QUANTITY';
      else
        l_default_amount_type_code := 'NONE';
        l_default_amount_subtype_code := 'NONE';
      end if; -- l_budget_version_type = 'REVENUE'
    else
      if l_revenue_flag = 'Y' then
        l_default_amount_type_code := 'REVENUE';
        l_default_amount_subtype_code := 'REVENUE';
      elsif l_raw_cost_flag = 'Y' then
        l_default_amount_type_code := 'COST';
        l_default_amount_subtype_code := 'RAW_COST';
      elsif l_burdened_cost_flag = 'Y' then
        l_default_amount_type_code := 'COST';
        l_default_amount_subtype_code := 'BURDENED_COST';
      elsif (l_cost_qty_flag = 'Y') or (l_revenue_qty_flag = 'Y') then
        l_default_amount_type_code := 'QUANTITY';
        l_default_amount_subtype_code := 'QUANTITY';
      else
        l_default_amount_type_code := 'NONE';
        l_default_amount_subtype_code := 'NONE';
      end if; -- l_budget_version_type = 'BOTH' or 'NEITHER'
    end if; -- l_budget_version_type
  end if;
  x_default_amount_type_code := l_default_amount_type_code;
  x_default_amount_subtype_code := l_default_amount_subtype_code;
EXCEPTION
when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
                               p_procedure_name   => 'Assign_Default_Amount');
      pa_debug.reset_err_stack;
      return;
END assign_default_amount;

/* Added this new function as part of the changes done for View Plan Enhancement 7514054 */

function get_period_n_value
    (p_period_profile_id    IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_budget_version_id    IN 	pa_budget_versions.budget_version_id%TYPE,
     p_resource_assignment_id IN pa_proj_periods_denorm.resource_assignment_id%TYPE,
     p_project_currency_type IN VARCHAR2,
     p_amount_type_id       IN  pa_proj_periods_denorm.amount_type_id%TYPE,
     p_period_number        IN  NUMBER) return NUMBER
is
l_return_value      NUMBER;

begin

  if p_period_number = 1 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date1();

  elsif p_period_number = 2 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date2();

  elsif p_period_number = 3 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date3();

  elsif p_period_number = 4 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date4();

  elsif p_period_number = 5 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date5();

  elsif p_period_number = 6 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date6();

  elsif p_period_number = 7 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date7();

  elsif p_period_number = 8 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date8();

  elsif p_period_number = 9 then

 	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date9();

  elsif p_period_number = 10 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date10();

  elsif p_period_number = 11 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date11();

  elsif p_period_number = 12 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date12();

  elsif p_period_number = 13 then

	select sum(decode(p_amount_type_id, 215, bl.quantity, 160, decode(p_project_currency_type, 'PROJECT', bl.project_raw_cost, bl.raw_cost),
	            165, decode(p_project_currency_type, 'PROJECT', bl.project_burdened_cost, bl.burdened_cost), 100, bl.revenue, null))
    into l_return_value
    from pa_budget_lines bl
	where bl.resource_assignment_id = p_resource_assignment_id
	and bl.budget_version_id = p_budget_version_id
	and trunc(bl.start_date) = pa_fp_view_plans_pub.Get_Period_Start_Date13();
  end if;

  return l_return_value;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	return null;
  WHEN TOO_MANY_ROWS THEN
      pa_debug.write_file('get_period_n_value: p_period_profile_id= ' ||
		to_char(p_period_profile_id));
      pa_debug.write_file('get_period_n_value: p_amount_type_id= ' ||
		to_char(p_amount_type_id));
      pa_debug.write_file('get_period_n_value: p_resource_assignment_id= ' ||
		to_char(p_resource_assignment_id));
      FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fp_view_plans_util',
                              p_procedure_name   => 'get_period_n_value: TOO_MANY_ROWS');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end get_period_n_value;

/* Ends changes for 7514054 */

/* --------------------------------------------------------------------- Commented this function for 7514054 as the above new function is active in M.
-- CHANGE HISTORY:
-- 12/26/02	dlai	added two new conditions:
--			p_period_number=0  --> preceding_periods_amount
--			p_period_number=14 --> succeeding_periods_amount
function get_period_n_value
    (p_period_profile_id    IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_budget_version_id    IN 	pa_budget_versions.budget_version_id%TYPE,
     p_resource_assignment_id IN pa_proj_periods_denorm.resource_assignment_id%TYPE,
     p_project_currency_type IN VARCHAR2,
     p_amount_type_id       IN  pa_proj_periods_denorm.amount_type_id%TYPE,
     p_period_number        IN  NUMBER) return NUMBER
is
l_return_value      NUMBER;

begin
--hr_utility.trace('entering');
--hr_utility.trace('date= ' || pa_fp_view_plans_pub.Get_Period_Start_Date1());
-- *** PERFORMANCE ISSUE 2773408: get budget_version_id to use index
--     PA_PROJECT_PERIODS_DENORM_N1

  if p_period_number = 1 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date1(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 2 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date2(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 3 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date3(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 4 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date4(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 5 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date5(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 6 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date6(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 7 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date7(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 8 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date8(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 9 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date9(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 10 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date10(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 11 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date11(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 12 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date12(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;

  elsif p_period_number = 13 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date13(),
                  pppp.period1_start_Date, nvl(pppd.period_amount1,0),
                  pppp.period2_start_Date, nvl(pppd.period_amount2,0),
                  pppp.period3_start_Date, nvl(pppd.period_amount3,0),
                  pppp.period4_start_Date, nvl(pppd.period_amount4,0),
                  pppp.period5_start_Date, nvl(pppd.period_amount5,0),
                  pppp.period6_start_Date, nvl(pppd.period_amount6,0),
                  pppp.period7_start_Date, nvl(pppd.period_amount7,0),
                  pppp.period8_start_Date, nvl(pppd.period_amount8,0),
                  pppp.period9_start_Date, nvl(pppd.period_amount9,0),
                  pppp.period10_start_Date, nvl(pppd.period_amount10,0),
                  pppp.period11_start_Date, nvl(pppd.period_amount11,0),
                  pppp.period12_start_Date, nvl(pppd.period_amount12,0),
                  pppp.period13_start_Date, nvl(pppd.period_amount13,0),
                  pppp.period14_start_Date, nvl(pppd.period_amount14,0),
                  pppp.period15_start_Date, nvl(pppd.period_amount15,0),
                  pppp.period16_start_Date, nvl(pppd.period_amount16,0),
                  pppp.period17_start_Date, nvl(pppd.period_amount17,0),
                  pppp.period18_start_Date, nvl(pppd.period_amount18,0),
                  pppp.period19_start_Date, nvl(pppd.period_amount19,0),
                  pppp.period20_start_Date, nvl(pppd.period_amount20,0),
                  pppp.period21_start_Date, nvl(pppd.period_amount21,0),
                  pppp.period22_start_Date, nvl(pppd.period_amount22,0),
                  pppp.period23_start_Date, nvl(pppd.period_amount23,0),
                  pppp.period24_start_Date, nvl(pppd.period_amount24,0),
                  pppp.period25_start_Date, nvl(pppd.period_amount25,0),
                  pppp.period26_start_Date, nvl(pppd.period_amount26,0),
                  pppp.period27_start_Date, nvl(pppd.period_amount27,0),
                  pppp.period28_start_Date, nvl(pppd.period_amount28,0),
                  pppp.period29_start_Date, nvl(pppd.period_amount29,0),
                  pppp.period30_start_Date, nvl(pppd.period_amount30,0),
                  pppp.period31_start_Date, nvl(pppd.period_amount31,0),
                  pppp.period32_start_Date, nvl(pppd.period_amount32,0),
                  pppp.period33_start_Date, nvl(pppd.period_amount33,0),
                  pppp.period34_start_Date, nvl(pppd.period_amount34,0),
                  pppp.period35_start_Date, nvl(pppd.period_amount35,0),
                  pppp.period36_start_Date, nvl(pppd.period_amount36,0),
                  pppp.period37_start_Date, nvl(pppd.period_amount37,0),
                  pppp.period38_start_Date, nvl(pppd.period_amount38,0),
                  pppp.period39_start_Date, nvl(pppd.period_amount39,0),
                  pppp.period40_start_Date, nvl(pppd.period_amount40,0),
                  pppp.period41_start_Date, nvl(pppd.period_amount41,0),
                  pppp.period42_start_Date, nvl(pppd.period_amount42,0),
                  pppp.period43_start_Date, nvl(pppd.period_amount43,0),
                  pppp.period44_start_Date, nvl(pppd.period_amount44,0),
                  pppp.period45_start_Date, nvl(pppd.period_amount45,0),
                  pppp.period46_start_Date, nvl(pppd.period_amount46,0),
                  pppp.period47_start_Date, nvl(pppd.period_amount47,0),
                  pppp.period48_start_Date, nvl(pppd.period_amount48,0),
                  pppp.period49_start_Date, nvl(pppd.period_amount49,0),
                  pppp.period50_start_Date, nvl(pppd.period_amount50,0),
                  pppp.period51_start_Date, nvl(pppd.period_amount51,0),
                  pppp.period52_start_Date, nvl(pppd.period_amount52,0),
		  null))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;
  elsif p_period_number = 0 then
    select SUM(nvl(pppd.preceding_periods_amount,0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;
  elsif p_period_number = 14 then
    select SUM(nvl(pppd.succeeding_periods_amount,0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
	  pppd.budget_version_id = p_budget_version_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
          pppd.amount_subtype_id = p_amount_type_id and
	  ((p_amount_type_id=215 and pppd.currency_type='TRANSACTION') or
	   (p_amount_type_id <> 215 and pppd.currency_type = p_project_currency_type));
    --group by pppd.amount_subtype_id;
  end if;
  return l_return_value;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	return null;
  WHEN TOO_MANY_ROWS THEN
      pa_debug.write_file('get_period_n_value: p_period_profile_id= ' ||
		to_char(p_period_profile_id));
      pa_debug.write_file('get_period_n_value: p_amount_type_id= ' ||
		to_char(p_amount_type_id));
      pa_debug.write_file('get_period_n_value: p_resource_assignment_id= ' ||
		to_char(p_resource_assignment_id));
      FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fp_view_plans_util',
                              p_procedure_name   => 'get_period_n_value: TOO_MANY_ROWS');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end get_period_n_value;

Ends commented for 7514054 */

/* THIS IMPLEMENTATION IS INCORRECT BECAUSE WE'RE TRYING TO INCORPORATE
 * ORG FORECASTING VALUES

function get_period_n_value
    (p_period_profile_id    IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_resource_assignment_id IN pa_proj_periods_denorm.resource_assignment_id%TYPE,
     p_project_currency_type IN VARCHAR2,
     p_amount_type_id       IN  pa_proj_periods_denorm.amount_type_id%TYPE,
     p_period_number        IN  NUMBER) return NUMBER
is
l_return_value      NUMBER;

begin
  -- we use SUM(DECODE) because for COST or REVENUE amount type, there's
  -- one AMOUNT_SUBTYPE_ID which will require us to subtract instead of add
  -- COST: TP_COST_OUT (185)
  -- REVENUE: TP_REVENUE_OUT (120)
--hr_utility.trace('pa_fp_view_plans_pub.Get_Period_Start_Date1()= ' ||
	to_char(pa_fp_view_plans_pub.Get_Period_Start_Date1()));
  if p_period_number = 1 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date1(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 2 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date2(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 3 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date3(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 4 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date4(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 5 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date5(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 6 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date6(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 7 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date7(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 8 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date8(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 9 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date9(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 10 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date10(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 11 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date11(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 12 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date12(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;

  elsif p_period_number = 13 then
    select SUM(DECODE(pa_fp_view_plans_pub.Get_Period_Start_Date13(),
                pppp.period1_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount1,
                                            120, -pppd.period_amount1,
                                            pppd.period_amount1),
                pppp.period2_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount2,
                                            120, -pppd.period_amount2,
                                            pppd.period_amount2),
		        pppp.period3_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount3,
                                            120, -pppd.period_amount3,
                                            pppd.period_amount3),
                pppp.period4_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount4,
                                            120, -pppd.period_amount4,
                                            pppd.period_amount4),
                pppp.period5_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount5,
                                            120, -pppd.period_amount5,
                                            pppd.period_amount5),
                pppp.period6_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount6,
                                            120, -pppd.period_amount6,
                                            pppd.period_amount6),
                pppp.period7_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount7,
                                            120, -pppd.period_amount7,
                                            pppd.period_amount7),
                pppp.period8_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount8,
                                            120, -pppd.period_amount8,
                                            pppd.period_amount8),
                pppp.period9_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount9,
                                            120, -pppd.period_amount9,
                                            pppd.period_amount9),
                pppp.period10_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount10,
                                            120, -pppd.period_amount10,
                                            pppd.period_amount10),
                pppp.period11_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount11,
                                            120, -pppd.period_amount11,
                                            pppd.period_amount11),
                pppp.period12_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount12,
                                            120, -pppd.period_amount12,
                                            pppd.period_amount12),
                pppp.period13_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount13,
                                            120, -pppd.period_amount13,
                                            pppd.period_amount13),
                pppp.period14_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount14,
                                            120, -pppd.period_amount14,
                                            pppd.period_amount14),
                pppp.period15_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount15,
                                            120, -pppd.period_amount15,
                                            pppd.period_amount15),
                pppp.period16_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount16,
                                            120, -pppd.period_amount16,
                                            pppd.period_amount16),
                pppp.period17_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount17,
                                            120, -pppd.period_amount17,
                                            pppd.period_amount17),
                pppp.period18_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount18,
                                            120, -pppd.period_amount18,
                                            pppd.period_amount18),
                pppp.period19_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount19,
                                            120, -pppd.period_amount19,
                                            pppd.period_amount19),
                pppp.period20_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount20,
                                            120, -pppd.period_amount20,
                                            pppd.period_amount20),
                pppp.period21_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount21,
                                            120, -pppd.period_amount21,
                                            pppd.period_amount21),
                pppp.period22_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount22,
                                            120, -pppd.period_amount22,
                                            pppd.period_amount22),
                pppp.period23_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount23,
                                            120, -pppd.period_amount23,
                                            pppd.period_amount23),
                pppp.period24_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount24,
                                            120, -pppd.period_amount24,
                                            pppd.period_amount24),
                pppp.period25_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount25,
                                            120, -pppd.period_amount25,
                                            pppd.period_amount25),
                pppp.period26_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount26,
                                            120, -pppd.period_amount26,
                                            pppd.period_amount26),
                pppp.period27_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount27,
                                            120, -pppd.period_amount27,
                                            pppd.period_amount27),
                pppp.period28_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount28,
                                            120, -pppd.period_amount28,
                                            pppd.period_amount28),
                pppp.period29_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount29,
                                            120, -pppd.period_amount29,
                                            pppd.period_amount29),
                pppp.period30_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount30,
                                            120, -pppd.period_amount30,
                                            pppd.period_amount30),
                pppp.period31_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount31,
                                            120, -pppd.period_amount31,
                                            pppd.period_amount31),
                pppp.period32_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount32,
                                            120, -pppd.period_amount32,
                                            pppd.period_amount32),
                pppp.period33_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount33,
                                            120, -pppd.period_amount33,
                                            pppd.period_amount33),
                pppp.period34_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount34,
                                            120, -pppd.period_amount34,
                                            pppd.period_amount34),
                pppp.period35_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount35,
                                            120, -pppd.period_amount35,
                                            pppd.period_amount35),
                pppp.period36_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount36,
                                            120, -pppd.period_amount36,
                                            pppd.period_amount36),
                pppp.period37_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount37,
                                            120, -pppd.period_amount37,
                                            pppd.period_amount37),
                pppp.period38_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount38,
                                            120, -pppd.period_amount38,
                                            pppd.period_amount38),
                pppp.period39_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount39,
                                            120, -pppd.period_amount39,
                                            pppd.period_amount39),
                pppp.period40_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount40,
                                            120, -pppd.period_amount40,
                                            pppd.period_amount40),
                pppp.period41_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount41,
                                            120, -pppd.period_amount41,
                                            pppd.period_amount41),
                pppp.period42_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount42,
                                            120, -pppd.period_amount42,
                                            pppd.period_amount42),
                pppp.period43_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount43,
                                            120, -pppd.period_amount43,
                                            pppd.period_amount43),
                pppp.period44_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount44,
                                            120, -pppd.period_amount44,
                                            pppd.period_amount44),
                pppp.period45_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount45,
                                            120, -pppd.period_amount45,
                                            pppd.period_amount45),
                pppp.period46_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount46,
                                            120, -pppd.period_amount46,
                                            pppd.period_amount46),
                pppp.period47_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount47,
                                            120, -pppd.period_amount47,
                                            pppd.period_amount47),
                pppp.period48_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount48,
                                            120, -pppd.period_amount48,
                                            pppd.period_amount48),
                pppp.period49_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount49,
                                            120, -pppd.period_amount49,
                                            pppd.period_amount49),
                pppp.period50_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount50,
                                            120, -pppd.period_amount50,
                                            pppd.period_amount50),
                pppp.period51_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount51,
                                            120, -pppd.period_amount51,
                                            pppd.period_amount51),
                pppp.period52_start_Date, DECODE(pppd.amount_subtype_id,
                                            185, -pppd.period_amount52,
                                            120, -pppd.period_amount52,
                                            pppd.period_amount52),0))
    into l_return_value
    from pa_proj_period_profiles pppp,
         pa_proj_periods_denorm pppd
    where pppp.period_profile_id = p_period_profile_id and
          pppp.period_profile_id=pppd.period_profile_id and
          pppd.amount_type_id = p_amount_type_id and
	  pppd.resource_assignment_id = p_resource_assignment_id and
	  pppd.currency_type = p_project_currency_type
    group by pppd.amount_type_id;
  end if;
  return l_return_value;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	return null;
end get_period_n_value;
*/

/* --------------------------------------------------------------------- */

FUNCTION calc_margin_percent
        (p_cost_value       IN NUMBER,
         p_rev_value        IN NUMBER) return NUMBER
is
BEGIN
    if (p_rev_value is null) or (p_cost_value is null) then
      return null;
    elsif (p_rev_value = 0) or ( p_cost_value = 0) then  -- Added the OR condition for bug 3651389
      return 0;
     else
      return (p_rev_value-p_cost_value)/p_rev_value;
    end if;
END calc_margin_percent;
/* --------------------------------------------------------------------- */

PROCEDURE refresh_period_profile
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_budget_version_id1	IN	pa_budget_versions.budget_version_id%TYPE,
	 p_budget_version_id2	IN	pa_budget_versions.budget_version_id%TYPE,
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT 	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_gl_pd_profile_id	pa_proj_period_profiles.period_profile_id%TYPE;
l_pa_pd_profile_id	pa_proj_period_profiles.period_profile_id%TYPE;
l_rpt_request_id	NUMBER;
x_conc_req_id		NUMBER;

-- error-handling variables
l_debug_mode		VARCHAR2(1) := 'Y';

cursor GL_ppId is
select period_profile_id
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'GL' and
	current_flag ='Y';
GL_ppId_rec GL_ppId%ROWTYPE;

cursor PA_ppId is
select period_profile_id
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'PA' and
	current_flag ='Y';
PA_ppId_rec GL_ppId%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- RETRIEVE the current period_profile_id's for GL
  open GL_ppId;
  fetch GL_ppId into GL_ppId_rec;
  if GL_ppId%NOTFOUND then
    pa_debug.write('pa_fp_view_plans_util.refresh_period_profile', 'no ppid for GL', 2);
  else
    l_gl_pd_profile_id := GL_ppId_rec.period_profile_id;
  end if;
  close GL_ppId;
  -- RETRIEVE the current period_profile_id's for PA
  open PA_ppId;
  fetch PA_ppId into PA_ppId_rec;
  if PA_ppId%NOTFOUND then
    pa_debug.write('pa_fp_view_plans_util.refresh_period_profile', 'no ppid for PA', 2);
  else
    l_pa_pd_profile_id := PA_ppId_rec.period_profile_id;
  end if;
  close PA_ppId;

  l_rpt_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAPDPROF',
                description                =>   'PRC: Refresh Plan Versions Period Profile',
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   p_budget_version_id1,
                argument2                  =>   p_budget_version_id2,
                argument3                  =>   p_project_id,
                argument4                  =>   NULL,
                argument5                  =>   l_gl_pd_profile_id,
                argument6                  =>   l_pa_pd_profile_id,
                argument7                  =>   l_debug_mode);
  IF l_rpt_request_id = 0 then
               PA_DEBUG.g_err_stage := 'Error while submitting Report [PAFPEXRP]';
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_FP_PP_CONC_PGM_ERR');
               x_return_status := FND_API.G_RET_STS_ERROR;
               ROLLBACK;
               RETURN;
  ELSE
               PA_DEBUG.g_err_stage := 'Exception Report Request Id : ' ||
                                        LTRIM(TO_CHAR(l_rpt_request_id )) ;
               PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                     p_write_file => 'OUT',
                                     p_write_mode => 1);
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
  END IF;
  x_conc_req_id := LTRIM(RTRIM(TO_CHAR(l_rpt_request_id)));

  -- bug 2740907: stamp request_id into pa_budget_versions
  --              set locked_by_person_id=-99: locked by processing
  update pa_budget_versions
    set plan_processing_code = 'PPP',
	record_version_number = record_version_number + 1,
	request_id = x_conc_req_id,
	locked_by_person_id = -98
    where budget_version_id = p_budget_version_id1;
  update pa_budget_versions
    set plan_processing_code = 'PPP',
	record_version_number = record_version_number + 1,
	request_id = x_conc_req_id,
	locked_by_person_id = -98
    where budget_version_id = p_budget_version_id2;
  IF x_return_Status = FND_API.G_RET_STS_SUCCESS THEN
      COMMIT;
  ELSE
      ROLLBACK;
  END IF;

END refresh_period_profile;
/* --------------------------------------------------------------------- */

FUNCTION has_period_profile_id
	(p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2 is
  l_return_value 	VARCHAR2(1);
BEGIN
  l_return_value := 'N';
  select 'Y'
    into l_return_value
    from pa_budget_versions
    where budget_version_id = p_budget_version_id and
	  period_profile_id is not null;
  return l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return l_return_value;
END has_period_profile_id;

/*************************************************************/
procedure roll_up_budget_lines
    (p_budget_version_id        in  pa_budget_versions.budget_version_id%TYPE,
     p_cost_or_rev              in  VARCHAR2)
is

cursor l_ra_csr is
select resource_assignment_id
  from pa_resource_assignments
  where budget_version_id = p_budget_version_id;
l_ra_rec l_ra_csr%ROWTYPE;

/* local variables */
l_resource_assignment_id        pa_resource_assignments.resource_assignment_id%TYPE;
l_line_costrev_total            pa_resource_assignments.total_plan_revenue%TYPE;
l_line_quantity_total           pa_resource_assignments.total_plan_quantity%TYPE;
begin
  open l_ra_csr;
  if p_cost_or_rev = 'REVENUE' then
    -- roll up the revenue budget version
    loop
      fetch l_ra_csr into l_ra_rec;
      exit when l_ra_csr%NOTFOUND;
      select SUM(nvl(quantity,0)),
             SUM(nvl(revenue,0))
        into l_line_quantity_total,
             l_line_costrev_total
        from pa_budget_lines
        where resource_assignment_id = l_ra_rec.resource_assignment_id
        group by resource_assignment_id;
      update pa_resource_assignments
        set total_plan_revenue = l_line_costrev_total,
            total_utilization_hours = l_line_quantity_total
        where
            resource_assignment_id = l_ra_rec.resource_assignment_id;
    end loop;
  else
    -- roll up the cost budget version
    loop
      fetch l_ra_csr into l_ra_rec;
      exit when l_ra_csr%NOTFOUND;
      select SUM(nvl(quantity,0)),
             SUM(nvl(burdened_cost,0))
        into l_line_quantity_total,
             l_line_costrev_total
        from pa_budget_lines
        where resource_assignment_id = l_ra_rec.resource_assignment_id
        group by resource_assignment_id;
      update pa_resource_assignments
        set total_plan_burdened_cost = l_line_costrev_total,
            total_utilization_hours = l_line_quantity_total
        where
            resource_assignment_id = l_ra_rec.resource_assignment_id;
    end loop;
  end if;
  commit;
  close l_ra_csr;
end roll_up_budget_lines;


FUNCTION get_amttype_id
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE) RETURN NUMBER
is
    l_amount_type_id pa_amount_types_b.amount_type_id%TYPE;
    l_amt_code pa_fp_view_plans_util.char240_data_type_table;
    l_amt_id   pa_fp_view_plans_util.number_data_type_table;

    l_debug_mode VARCHAR2(30);

    CURSOR get_amt_det IS
    SELECT atb.amount_type_id
          ,atb.amount_type_code
      FROM pa_amount_types_b atb
     WHERE atb.amount_type_class = 'R';

    l_stage number := 0;

BEGIN
     pa_debug.init_err_stack('PA_FP_ORG_FCST_GEN_PUB.get_amttype_id');

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       l_amount_type_id := -99;

       IF l_amt_code.last IS NULL THEN
          OPEN get_amt_det;
          LOOP
              FETCH get_amt_det into l_amt_id(nvl(l_amt_id.last+1,1))
                                    ,l_amt_code(nvl(l_amt_code.last+1,1));
              EXIT WHEN get_amt_det%NOTFOUND;
          END LOOP;
       END IF;

       IF l_amt_code.last IS NOT NULL THEN
          FOR i in l_amt_id.first..l_amt_id.last LOOP
              IF l_amt_code(i) = p_amt_typ_code THEN
                 l_amount_type_id := l_amt_id(i);
              END IF;
          END LOOP;
       END IF;
       IF l_amount_type_id = -99 THEN
                 pa_debug.g_err_stage := 'p_amt_typ_code         ['||p_amt_typ_code          ||']';
                 pa_debug.write_file(pa_debug.g_err_stage);
       END IF;
       pa_debug.reset_err_stack;
       RETURN(l_amount_type_id);

EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_GEN_PUB.get_amttype_id'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              pa_debug.write_file(SQLERRM);
              pa_debug.reset_err_stack;
              RAISE;
END get_amttype_id;


-- FP L: used in View/Edit Plan page whenever navigation option to View/Edit
-- Plan Line page is chosen.  If the resource assignment has been deleted by
-- WBS, an error needs to be displayed
procedure check_res_assignment_exists
    (p_resource_assignment_id   IN   pa_resource_assignments.resource_assignment_id%TYPE,
     x_res_assignment_exists    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status            OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
l_res_assignment_exists       VARCHAR2(1);
l_msg_index_out	              NUMBER(30);
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    select 'Y'
      into l_res_assignment_exists
      from dual
      where exists
	(select resource_assignment_id
           from pa_resource_assignments
	   where resource_assignment_id = p_resource_assignment_id);
    if l_res_assignment_exists = 'Y' then
      x_res_assignment_exists := 'Y';
    else
      x_res_assignment_exists := 'N';
    end if;
    return;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	    x_res_assignment_exists := 'N';
/*
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_EPL_TASK_UPDATED',
				 p_token1         => 'TASK_NAME',
				 p_value1         => p_task_name,
				 p_token2         => 'TASK_NUMBER',
				 p_value2	  => p_task_number);
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.Count_Msg;
            if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
            end if;
            return;
*/
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fp_view_plans_util',
                                    p_procedure_name   => 'check_res_assignment_exists');
            pa_debug.reset_err_stack;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
END check_res_assignment_exists;


-- FP L: used in View/Edit Plan page to determine if a plan version is planned
--       at a resource or resource group level (bug 2813661)
-- NOTE: THIS PROCEDURE IS USED ONLY FOR COLUMN DISPLAY PURPOSES: IT CONTAINS LOGIC
--       THAT IS USED TO HIDE/SHOW THE RESOURCE AND/OR RESOURCE GROUP COLUMNS.  IT
--       CONTAINS DISPLAY LOGIC THAT MAY NOT BE DIRECTLY RELEVANT TO THE ACTUAL
--       PLANNING LEVEL OF THE VERSION.
--       ** p_entered_amts_only_flag = 'Y' if this is used by the View Plan page
--          (query only rows with entered amts), and 'N' if used by Edit Plan page

-- Bug 3081511 After the bug fix, the logic to display 'Resource' and
--             'Resource Group' columns in edit/view plan pages stands as follows:
--     Case 1: If the resource list is a uncategorized, value 'N' is returned.
--             So, neither 'Resource Group' column nor 'Resource' column would
--             be rendered.
--     Case 2: If the resource list is 'Ungrouped' value 'R' is returned. Only
--             'Resource' column is shown.
--     Case 3: If the resource list is 'Grouped' and if the entire version is
--             planned at 'Resource Group' level, value 'G' is returned.
--             Only 'Resource Group'  columns would be shown
--     Case 4: If the resource list is 'Grouped' and if any of the resources
--             have been planned for value 'M' is returned.
--             Both resource group and resource columns are rendered.

procedure get_plan_version_res_level
  (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
   p_entered_amts_only_flag  IN VARCHAR2,
   x_resource_level          OUT NOCOPY VARCHAR2,  -- 'R' = resource, 'G' = resource group,  --File.Sql.39 bug 4440895
                                            -- 'M' = mixed, -- 'N' = not applicable (NONE resource list)
   x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

   l_group_resource_type_id pa_resource_lists.group_resource_type_id%TYPE;
   l_uncategorized_flag     pa_resource_lists.uncategorized_flag%TYPE; -- bug 3081511
   l_fin_plan_level_code    pa_proj_fp_options.all_fin_plan_level_code%TYPE;
   l_prj_rlm_id             pa_resource_list_members.resource_list_member_id%TYPE;
   l_proj_fp_options_id     pa_proj_fp_options.proj_fp_options_id%TYPE;
   l_version_type           pa_budget_versions.version_type%TYPE;
   l_resource_level         VARCHAR2(1); -- used to store temp value of return variable
   l_resource_list_id       pa_resource_lists_all_bg.resource_list_id%TYPE;

   cursor c1(c_fp_opt_id number,
             c_ver_type varchar2) is
             select fpe.task_id,
                    fpe.resource_planning_level
             from
                 pa_fp_elements fpe,
                 pa_tasks t
             where
                 fpe.proj_fp_options_id = c_fp_opt_id and
                 fpe.element_type = c_ver_type and
                 fpe.task_id = t.task_id and
                 fpe.resource_list_member_id = 0 and
                 fpe.plannable_flag = 'Y';
   c1_rec c1%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  /* If group_resource_type_id is 0, then version could be planned by Resources,
     or the resource list could be None.  Therefore, we need to check the
     uncategorized_flag as well (uncategorized_flag='Y' means resource list is None)
  */
  select nvl(rl.group_resource_type_id,0),
         nvl(rl.uncategorized_flag, 'N'),
         rl.resource_list_id
  into   l_group_resource_type_id,
         l_uncategorized_flag,
         l_resource_list_id
  from   pa_budget_versions bv,
         pa_resource_lists_all_bg rl
  where  bv.budget_version_id = p_budget_version_id
  and    bv.resource_list_id = rl.resource_list_id;

  if l_group_resource_type_id = 0 then
      if l_uncategorized_flag = 'N' then
          x_resource_level := 'R';
      else
          x_resource_level := 'N';
      end if;
      -- for an ungrouped resource list only these are the possible values.
      -- no further processing is required
      pa_debug.reset_err_stack;
      return;
  end if; -- l_group_resource_type_id = 0

  -- fetch proj_fp_options_id and planning level of the version

  select po.proj_fp_options_id,
         DECODE(po.fin_plan_preference_code,
                'COST_ONLY', po.cost_fin_plan_level_code,
                'REVENUE_ONLY', po.revenue_fin_plan_level_code,
                po.all_fin_plan_level_code),
         bv.version_type
    into l_proj_fp_options_id,
         l_fin_plan_level_code,
         l_version_type
    from pa_proj_fp_options po,
         pa_budget_versions bv
   where bv.budget_version_id = p_budget_version_id and
         bv.budget_version_id = po.fin_plan_version_id and
         po.fin_plan_option_level_code = 'PLAN_VERSION';

   -- Processing is different if the verison is planned at 'project' level or task level
   if l_fin_plan_level_code = 'P' then
       /*** PROJECT-LEVEL PLANNING ***/
       begin
          select ra.resource_list_member_id
            into l_prj_rlm_id
            from pa_resource_assignments ra
            where ra.budget_version_id = p_budget_version_id and
                  nvl(ra.resource_assignment_type,'USER_ENTERED') = 'USER_ENTERED' and
                  rownum < 2;
       exception
           when no_data_found then
               -- no planning elements returned: return 'N'
               x_resource_level := 'N';
               l_prj_rlm_id := null;
               pa_debug.reset_err_stack;
               return;
       end;
       if nvl(l_prj_rlm_id,0) > 0 then
            select decode(parent_member_id,null,'G','R')
              into x_resource_level
              from pa_resource_list_members
              where resource_list_member_id = l_prj_rlm_id;
       end if;
   else
       /*** NOT PROJECT-LEVEL PLANNING ***/
       open c1(l_proj_fp_options_id, l_version_type);
       fetch c1 into c1_rec;
       if c1%NOTFOUND then
           -- no planning elements returned: return 'N'
           x_resource_level := 'N';
           pa_debug.reset_err_stack;
           return;
       else
           /* loop through the records, checking the 'resource_planning_level' attribute
            * if they are ALL 'R', then x_resource_level := 'R'
            * if they are ALL 'G', then x_resource_level := 'G'
            * otherwise, x_resource_level = 'M'
            */
           l_resource_level := nvl(c1_rec.resource_planning_level, 'M');
           loop
           fetch c1 into c1_rec;
           exit when c1%NOTFOUND;
           if nvl(c1_rec.resource_planning_level, 'M') <> l_resource_level then
               l_resource_level := 'M';
               exit;
           end if;
           end loop;
           x_resource_level := l_resource_level;
       end if;
       close c1;
   end if;

   -- If the resource list is grouped and all the resources have been planned
   -- at 'R'level, we need to show the 'resource group' column also in edit
   -- and view plan pages for clarity purposes.

   if x_resource_level = 'R' and l_group_resource_type_id <> 0 then
         x_resource_level := 'M';
   end if;
   pa_debug.reset_err_stack;
EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fp_view_plans_util',
                                    p_procedure_name   => 'get_plan_version_res_level');
            pa_debug.reset_err_stack;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
END get_plan_version_res_level;

end pa_fp_view_plans_util;

/
