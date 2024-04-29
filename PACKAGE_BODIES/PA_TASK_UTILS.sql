--------------------------------------------------------
--  DDL for Package Body PA_TASK_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_UTILS" as
-- $Header: PAXTUTLB.pls 120.11.12010000.6 2009/07/21 14:33:40 anuragar ship $


--
--  FUNCTION
--              get_wbs_level
--  PURPOSE
--		This function retrieves the wbs level of a task.
--              If no wbs level id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   16-OCT-95      R. Chiu       Created
--
function get_wbs_level (x_task_id  IN number) return number
is
    cursor c1 is
	select wbs_level
	from pa_tasks
	where task_id = x_task_id;

    c1_rec c1%rowtype;

begin
	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
	   close c1;
	   return null;
	else
	   close c1;
	   return c1_rec.wbs_level ;
        end if;

exception
   when others then
	return SQLCODE ;

end get_wbs_level;


--
--  FUNCTION
--              get_top_task_id
--  PURPOSE
--		This function retrieves the top task id of a task.
--              If no top task id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   16-OCT-95      R. Chiu       Created
--
function get_top_task_id (x_task_id  IN number) return number
is
    cursor c1 is
	select top_task_id
	from pa_tasks
	where task_id = x_task_id;

    c1_rec c1%rowtype;

begin
	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( c1_rec.top_task_id );
        end if;

exception
   when others then
	return(SQLCODE);

end get_top_task_id;


--
--  FUNCTION
--              get_parent_task_id
--  PURPOSE
--              This function retrieves the parent task id of a task.
--              If no parent task id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   16-OCT-95      R. Chiu       Created
--
function get_parent_task_id (x_task_id  IN number) return number
is
    cursor c1 is
	select parent_task_id
	from pa_tasks
	where task_id = x_task_id;

    c1_rec c1%rowtype;

begin
	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
           close c1;
	   return( null);
	else
           close c1;
	   return( c1_rec.parent_task_id );
        end if;

exception
   when others then
	return(SQLCODE);

end get_parent_task_id;


/* Start of Bug 6497559 */

--
--  FUNCTION
--              get_resource_name
--  PURPOSE
--              This functions returns the resource name for a corresponding resource_list_member_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_resource_name (x_rlm_id  IN number) return varchar2
is
    cursor c1 is
	select alias
	from pa_resource_list_members
	where resource_list_member_id = x_rlm_id;

    l_rlm_name pa_resource_list_members.alias%type ;

begin
	open c1;
	fetch c1 into l_rlm_name;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( l_rlm_name );
        end if;

exception
   when others then
	return(SQLCODE);

end get_resource_name;

--
--  FUNCTION
--              get_task_name
--  PURPOSE
--              This functions returns the task name for a corresponding task_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_task_name (x_task_id  IN number) return varchar2
is
    cursor c1 is
	select name
	from pa_proj_elements
	where proj_element_id = x_task_id;

    l_task_name pa_proj_elements.name%type;

begin
	open c1;
	fetch c1 into l_task_name;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( l_task_name );
        end if;

exception
   when others then
	return(SQLCODE);

end get_task_name;

--
--  FUNCTION
--              get_task_number
--  PURPOSE
--              This functions returns the task number for a corresponding task_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_task_number (x_task_id  IN number) return varchar2
is
    cursor c1 is
	select element_number
	from pa_proj_elements
	where proj_element_id = x_task_id;

    l_task_number pa_proj_elements.element_number%type;

begin
	open c1;
	fetch c1 into l_task_number;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( l_task_number );
        end if;

exception
   when others then
	return(SQLCODE);

end get_task_number;

--
--  FUNCTION
--              get_project_name
--  PURPOSE
--              This functions returns the project name for a corresponding project_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_project_name (x_project_id  IN number) return varchar2
is
    cursor c1 is
	select name
	from pa_projects_all
	where project_id = x_project_id;

    l_project_name pa_projects_all.name%type;

begin
	open c1;
	fetch c1 into l_project_name;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( l_project_name );
        end if;

exception
   when others then
	return(SQLCODE);

end get_project_name;

--
--  FUNCTION
--              get_project_number
--  PURPOSE
--              This functions returns the project number for a corresponding project_id
--
--  HISTORY
--   19-May-2009      rthumma  Created
--

function get_project_number (x_project_id  IN number) return varchar2
is
    cursor c1 is
	select segment1
	from pa_projects_all
	where project_id = x_project_id;

    l_project_number pa_projects_all.segment1%type;

begin
	open c1;
	fetch c1 into l_project_number;
	if c1%notfound then
           close c1;
	   return(null);
	else
           close c1;
	   return( l_project_number );
        end if;

exception
   when others then
	return(SQLCODE);

end get_project_number;

/* End of Bug 6497559 */


--
--  FUNCTION
--              check_unique_task_number
--  PURPOSE
--              This function returns 1 if a task number is not already
--              used in PA system for a specific project id and returns 0
--              if number is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_unique_task_number (x_project_id  IN number
                                   , x_task_number  IN varchar2
                                   , x_rowid      IN varchar2 ) return number
is
    cursor c1 is
                select task_id from pa_tasks
                where project_id = x_project_id
                and task_number = substrb(x_task_number,1,25)  -- bug 5733285 added substrb
                and (x_ROWID IS NULL OR x_rowid <> PA_TASKS.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_project_id is null or x_task_number is null) then
            return (null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           close c1;
           return(1);
        else
           close c1;
           return(0);
        end if;

exception
   when others then
        return(SQLCODE);

end check_unique_task_number;


--
--  FUNCTION
--              check_last_task
--  PURPOSE
--		This function returns 1 if a task is the last task
--              and returns 0 otherwise.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_last_task (x_task_id  IN number ) return number
is
    x_project_id number;

    cursor c1 is
              select 1
                from sys.dual
                where exists (SELECT null
                        FROM   PA_TASKS
                        WHERE  PROJECT_ID = x_project_id
                        and    task_id <> x_task_id
			and    task_id = top_task_id);

    c1_rec 	c1%rowtype;

begin
	if (x_task_id is null) then
		return(null);
	end if;

	x_project_id := pa_proj_tsk_utils.get_task_project_id(x_task_id);

	if (x_project_id is null) then
		return(null);
	end if ;

	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
           close c1;
	   return(1);
	else
           close c1;
	   return(0);
        end if;

exception
   when others then
	return(SQLCODE);
end check_last_task;

--
--  FUNCTION
--              check_last_child
--  PURPOSE
--              This function returns 1 if a task is the last child of branch
--              and returns 0 otherwise.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_last_child (x_task_id  IN number ) return number
is
    x_parent_task_id number;

    cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT null
                        FROM   PA_TASKS
                        WHERE  TASK_ID <> x_TASK_ID
                        AND    PARENT_TASK_ID = x_PARENT_TASK_ID);

    c1_rec 	c1%rowtype;

begin
	if (x_task_id is null) then
		return(null);
	end if;

	x_parent_task_id := pa_task_utils.get_parent_task_id(x_task_id);

	open c1;
	fetch c1 into c1_rec;
	if c1%notfound then
           close c1;
	   return(1);
	else
           close c1;
	   return(0);
        end if;

exception
   when others then
	return(SQLCODE);
end check_last_child;


--  FUNCTION
--	 	check_pct_complete_exists
--  PURPOSE
--		This function returns 1 if percent complete exists for a
--		specific task and returns 0 if no percent complete is found
--		for that task.
--
--		If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_pct_complete_exists (x_task_id  IN number ) return number
is

        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT null
                        FROM pa_percent_completes
                        where  TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_TASK_ID));

        c1_rec c1%rowtype;

begin
	if (x_task_id is null) then
		return(null);
	end if;

	open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
             close c1;
             return(0);
        else
             close c1;
             return(1);
        end if;

exception
	when others then
		return(SQLCODE);
end check_pct_complete_exists;


--  FUNCTION
--              check_labor_cost_multiplier
--  PURPOSE
--              This function returns 1 if a task has labor cost multiplier
--              and returns 0 otherwise.
--
--              If Oracle error occured, Oracle error code is returned.
--
--  HISTORY
--   20-OCT-95      R. Chiu       Created
--
function check_labor_cost_multiplier
                        (x_task_id  IN number ) return number
is
        cursor c1 is
                select LABOR_COST_MULTIPLIER_NAME
                from pa_tasks
                where task_id = x_task_id
		and LABOR_COST_MULTIPLIER_NAME is not null;

        c1_rec c1%rowtype;
begin
        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
             close c1;
             return(0);
        else
             close c1;
             return(1);
        end if;

exception
	when others then
		return(SQLCODE);
end check_labor_cost_multiplier;


--
--  PROCEDURE
--              check_create_subtask_ok
--  PURPOSE
--		This API checks if a specific task has any transaction
--              control, burden schedule override, budget, billing,allocations
--              and other transaction information.  If task has any of
--              these information, then it's not ok to create subtask for
--              that task.  Specific reason will be returned.
--              If it's ok to create subtask, the x_err_code will be 0.
--  14-AUG-2002 If the task is plannable then we cannot add subtasks.
--
--  HISTORY
--   25-FEB-05      djoseph      Bug 409938: Added the api pjm_projtask_deletion.CheckUse_ProjectTask
--                               to check against PJM. Also changed the value of x_err_stage
--                               for pa_proj_tsk_utils.check_ap_inv_dist_exists
--   14-AUG-2002    Vejayara     Bug# 2331201 - Financial planning development
--                               related changes. If a task is present in
--                               pa_fp_elements, then a sub-task cannot be added
--                               to the task - check_create_subtask_ok
--   06-APR-99      Ri. Singh     Replaced call to pa_budget_utils.check_budget_exists
--                                with pa_budget_utils2.check_task_lowest_in_budgets
--                                Ref bug# 860607
--   16-FEB-99      Ri. Singh     Removed call to check_pct_complete_exists
--   10-FEB-99      Ri. Singh     Modified as explained below
--   20-OCT-95      R. Chiu       Created
--
procedure check_create_subtask_ok ( x_task_id 	IN  number
                                  , x_validation_mode    IN VARCHAR2   DEFAULT 'U'    --bug 2947492
                                  , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                  , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    old_stack	   varchar2(630);
    status_code	   number;
    x_top_task_id  number;
    x_project_id  number;
    x_proj_type_class_code	varchar2(30);
    dummy_null	   varchar2(30) default NULL;
    l_OTL_timecard_exists boolean; -- Added for bug 3870364
/* Commented the cursor for bug#3512486
    cursor p1 is select 1 from pa_project_types
                 where burden_sum_dest_task_id = x_task_id;*/
/* Added the below cursor for bug#3512486*/
    cursor p1 is select 1 from pa_project_types_all
                 where burden_sum_dest_task_id = x_task_id
		 and org_id = (SELECT org_id --MOAC Changes: Bug 4363092: removed nvl usage with org_id
                        FROM   pa_projects_all
                        where  project_id = (select project_id from pa_tasks where task_id=x_task_id));

    temp          number;
    l_return_val  varchar2(1);

    l_return_status  varchar2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);

begin

        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->check_create_subtask_ok';

	if (x_task_id is null) then
		x_err_code := 10;
		x_err_stage := 'PA_NO_TASK_ID';
		return;
	end if ;

-- Modified 02/10/99 Ri. Singh
-- all the following  checks are applicable to lowest level tasks.
-- If the task for which subtask is being created is not the lowest level
-- task, these checks need not be performed. Ref Bug#: 773604

        if(check_child_exists(x_task_id)=1) then
           x_err_stack := old_stack;
           return;
        end if;

-- End of fix
        x_project_id :=  pa_proj_tsk_utils.get_task_project_id(x_task_id);

		--anuragag Bug 8566495 - No validation on task_id if the task is created through change management
		if x_project_id is null then
		select project_id into x_project_id
		from pa_proj_elements
		where proj_element_id = x_task_id
		and task_status is not null;
		end if;

   open p1;
   fetch p1 into temp;
   if p1%notfound then null;
   else
      x_err_code := 250;
      x_err_stage := 'PA_TASK_BURDEN_SUM_DEST';
      return;
   end if;

   --anuragag Bug 8566495 - No validation on task_id if the task is created through change management
   if PA_TASK_PVT1.G_CHG_DOC_CNTXT <> 1
   then
	-- Get top task id
	x_err_stage := 'get top task id of '|| x_task_id;
	x_top_task_id := get_top_task_id(x_task_id);
	if (x_top_task_id is null) then
		x_err_code := 20;
		x_err_stage := 'PA_NO_TOP_TASK_ID';
		return;
	elsif ( x_top_task_id < 0 ) then
		x_err_code := x_top_task_id;
		return;
	end if;
    end if;
	-- Check if task has transaction control.
        x_err_stage := 'check txn control for '|| x_task_id;
	status_code :=
		pa_proj_tsk_utils.check_transaction_control(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 30;
	    x_err_stage := 'PA_TSK_TXN_CONT_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has burden schedule override
        x_err_stage := 'check burden schedule override for '|| x_task_id;
	status_code :=
	     pa_proj_tsk_utils.check_burden_sched_override(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 40;
	    x_err_stage := 'PA_TSK_BURDEN_SCH_OVRIDE_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;
/****
        Bug# 2331201 - Subtask cannot be added if this task has been included in
        the financial planning options for the project
***/

/*     Bug 2947492
       Removed the code from here. Please refer the HLD

        x_err_stage := 'check finplan options existence for ' || x_task_id;

        -- Check if task has been selected for planning.
        -- Subtask will not be allowed if task exists in pa_fp_elements with
        -- planning level as "L" or "M".
        -- In case of "M", the task should not be a single top task with no subtasks.
        x_err_stage := 'check pa_fp_elements for task '|| x_task_id;
        declare
           cursor c1 is
                         select 1
                         from   pa_fp_elements r,
                                pa_proj_fp_options m
                         where  r.task_id = x_task_id
                         and    (decode(r.element_type,
                                      'COST',cost_fin_plan_level_code,
                                      'REVENUE',revenue_fin_plan_level_code,
                                      'ALL',all_fin_plan_level_code) = 'L'
                                  or
                                  (decode(r.element_type,
                                      'COST',cost_fin_plan_level_code,
                                      'REVENUE',revenue_fin_plan_level_code,
                                      'ALL',all_fin_plan_level_code) = 'M'
                                   and x_task_id <> x_top_task_id))
                         and     m.proj_fp_options_id = r.proj_fp_options_id;

            c1_rec c1%rowtype;
        begin
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;    -- this task is not part of the planning options
                else
                   close c1;
                   x_err_code := 45;
                   x_err_stage := 'PA_FP_TSK_ELEMENTS_EXISTS';
                   return;
                end if;
        exception
                when others then
                   close c1;
                   x_err_code := SQLCODE;
                   return;
        end;
*/ -- Bug 2947492.  Not required anymore. Please see the HLD.

--      Begin Fix 860607 : Modified 04/03/99
--      Subtask will not be allowed if task exists in budgets with a budget entry method
--      as "L" or "M".
--      In case of "M", the task should not be a single top task with no subtasks.

          -- Check if task has budget

           x_err_stage := 'check task budget for '|| x_task_id;
           status_code := pa_budget_utils2.check_task_lowest_in_budgets
                          (  x_task_id       => x_task_id
                           , x_top_task_id   => x_top_task_id
                           , x_validation_mode  => x_validation_mode );    --bug 2947492

           if ( status_code = 1 ) then
               x_err_code := 50;
               x_err_stage := 'PA_TSK_BUDGET_EXIST';
               return;
           elsif ( status_code < 0 ) then
               x_err_code := status_code;
               return;
           end if;

--      End Fix 860607

       /* if (x_task_id <> x_top_task_id) then   ------------Commented for Bug 6063643*/

--         Begin Fix 860607
/*	   -- Check if task has budget
           x_err_stage := 'check task budget for '|| x_task_id;
	   status_code := pa_budget_utils.check_task_budget_exists(x_task_id,
				'A', dummy_null);
           if ( status_code = 1 ) then
               x_err_code := 50;
	       x_err_stage := 'PA_TSK_BUDGET_EXIST';
	       return;
	   elsif ( status_code < 0 ) then
	       x_err_code := status_code;
	       return;
	   end if;
*/
--         End Fix 860607

--         Bug Fix# 773604 02/16/99 Ri. Singh
--         Removed check.  Percent Complete can exist at any task level.
--         Subtask can be created for a task for which pct_complete exists .

/*
	   -- Check if task has percent complete
           x_err_stage := 'check percent complete for '|| x_task_id;
	   status_code := check_pct_complete_exists(x_task_id);
           if ( status_code = 1 ) then
               x_err_code := 70;
	       x_err_stage := 'PA_TSK_PCT_COMPL_EXIST';
	       return;
	   elsif ( status_code < 0 ) then
	       x_err_code := status_code;
	       return;
	   end if;
*/
-- End of bug fix 773604

           -- Check if task has project asset assignment
           x_err_stage := 'check asset assignment for '|| x_task_id;
	   status_code :=
	     pa_proj_tsk_utils.check_asset_assignmt_exists(null, x_task_id);
           if ( status_code = 1 ) then
               x_err_code := 100;
	       x_err_stage := 'PA_TSK_ASSET_ASSIGNMT_EXIST';
	       return;
	   elsif ( status_code < 0 ) then
	       x_err_code := status_code;
	       return;
	   end if;
	/* end if; -------Commented for Bug 6063643 */

	-- Get project id
	x_err_stage := 'get project id of '|| x_task_id;
	if (x_project_id is null) then
		x_err_code := 160;
		x_err_stage := 'PA_NO_PROJECT_ID';
		return;
	elsif ( x_top_task_id < 0 ) then
		x_err_code := x_project_id;
		return;
	end if;

	-- get project type class code
	pa_project_utils.get_proj_type_class_code(null,
				       x_project_id,
				       x_proj_type_class_code,
				       x_err_code,
				       x_err_stage,
				       x_err_stack);
        if (x_err_code <> 0) then -- Added the if block for bug bug#3512486
	   return;
        end if;

	if (x_proj_type_class_code = 'CONTRACT' ) then

		-- Check if task has labor cost multiplier
	        x_err_stage := 'check labor cost multiplier for '|| x_task_id;
		status_code := check_labor_cost_multiplier(x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 170;
		    x_err_stage := 'PA_TSK_LABOR_COST_MUL_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has job bill rate override
	        x_err_stage := 'check job bill rate override for '|| x_task_id;
		status_code :=
	        pa_proj_tsk_utils.check_job_bill_rate_override(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 180;
		    x_err_stage := 'PA_TSK_JOB_BILL_RATE_O_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has emp bill rate override
	        x_err_stage := 'check emp bill rate override for '|| x_task_id;
		status_code :=
		pa_proj_tsk_utils.check_emp_bill_rate_override(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 190;
		    x_err_stage := 'PA_TSK_EMP_BILL_RATE_O_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has labor multiplier
	        x_err_stage := 'check labor multiplier for '|| x_task_id;
		status_code :=
		pa_proj_tsk_utils.check_labor_multiplier(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 200;
		    x_err_stage := 'PA_TSK_LABOR_MULTIPLIER_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has nl bill rate override
	        x_err_stage := 'check nl bill rate override for '|| x_task_id;
		status_code :=
		pa_proj_tsk_utils.check_nl_bill_rate_override(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 210;
		    x_err_stage := 'PA_TSK_NL_BILL_RATE_O_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has job bill title override
	        x_err_stage := 'check job bill title override for '|| x_task_id;
		status_code :=
	       pa_proj_tsk_utils.check_job_bill_title_override(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 230;
		    x_err_stage := 'PA_TSK_JOB_BILL_TITLE_O_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;

		-- Check if task has job assignment override
	        x_err_stage := 'check job assignment override for '|| x_task_id;
		status_code :=
		pa_proj_tsk_utils.check_job_assignmt_override(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 240;
		    x_err_stage := 'PA_TSK_JOB_ASSIGNMENT_O_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;
        end if;

	-- Check if task has expenditure item
        x_err_stage := 'check expenditure item for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_exp_item_exists(x_project_id, x_task_id, FALSE);
        if ( status_code = 1 ) then
            x_err_code := 110;
	    x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has purchase order distribution
        x_err_stage := 'check purchase order for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_dist_exists(x_project_id, x_task_id, FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 120;
	    x_err_stage := 'PA_TSK_PO_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has purchase order requisition
        x_err_stage := 'check purchase order req for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_req_dist_exists(x_project_id, x_task_id, FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 130;
	    x_err_stage := 'PA_TSK_PO_REQ_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has ap invoice
        x_err_stage := 'check ap invoice for '|| x_task_id;
	status_code :=
  	  pa_proj_tsk_utils.check_ap_invoice_exists(x_project_id, x_task_id, FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 140;
	    x_err_stage := 'PA_TSK_AP_INV_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has ap invoice distribution
        x_err_stage := 'check ap inv distribution for '|| x_task_id;
	status_code :=
   	  pa_proj_tsk_utils.check_ap_inv_dist_exists(x_project_id, x_task_id, FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 150;
	/*Changed for bug 4069938*/
	 --   x_err_stage := 'PA_TSK_AP_INV_DIST_EXIST';
	    x_err_stage := 'PA_TSK_AP_INV_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

        -- Check if task is considered lowest level task in allocations
       x_err_stage := 'check if task is lowest in allocations for '|| x_task_id;
        l_return_val :=
          pa_alloc_utils.Is_Task_Lowest_In_Allocations(x_task_id);
        if ( l_return_val = 'Y' ) then
            x_err_code := 160;
            x_err_stage := 'PA_TASK_LOW_IN_AllOC';
            return;
        end if;

        -- Check if task has draft invoices
        x_err_stage := 'check draft invoice for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_draft_inv_details_exists(x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 170;
            x_err_stage := 'PA_TSK_CC_DINV_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has Project_customers
        x_err_stage := 'check Project Customers for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_project_customer_exists(X_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 180;
            x_err_stage := 'PA_TSK_CC_CUST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task assign to projects table as a cc_tax_task_id
        x_err_stage := 'check task assign to projects table as a cc_tax_task_id '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_projects_exists(x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 190;
            x_err_stage := 'PA_TSK_CC_PROJ_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

	-- Added for bug 3870364

        -- Check if task has an OTL timecard entered against it or not
        x_err_stage := 'Check if task has an OTL timecard entered against it or not ,task_id = '|| x_task_id;

        PA_OTC_API.ProjectTaskUsed ('TASK', x_task_id, l_OTL_timecard_exists);

        if ( l_OTL_timecard_exists ) then
            x_err_code := 193;
            x_err_stage := 'PA_TSK_OTL_TIMECARD_EXIST';
            return;
        end if;

	-- End of code added for bug 3870364

/* Start of code added for bug 4069938*/

        -- Check if task is in used in PJM
        x_err_stage := 'check for task used in PJM for'|| x_task_id;
        status_code :=
             pjm_projtask_deletion.CheckUse_ProjectTask(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 195;
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_MFG';
            return;
        elsif ( status_code = 2 ) THEN
            x_err_code := 195;
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_AUTO';
	    return;
	elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        elsif ( status_code <> 0) then        -- Added else condition to display a generic error message.
            x_err_code := 195;
            x_err_stage := 'PA_PROJ_TASK_IN_USE_EXTERNAL';
            return;
	end if;

/*End of code added for bug 4069938*/

--Bug 3024607

        BEGIN
             x_err_stage := 'PA_TASK_PUB1.Check_Task_Has_Association'||x_task_id;

             PA_TASK_PUB1.Check_Task_Has_Association(
                   p_task_id                => x_task_id
                  ,x_return_status          => l_return_status
                  ,x_msg_count              => l_msg_count
                  ,x_msg_data               => l_msg_data

               );

             IF (l_return_status <> 'S') Then
                x_err_code := 260;
                x_err_stage   := pa_project_core1.get_message_from_stack( l_msg_data );
                return;
             END IF;
        EXCEPTION  WHEN OTHERS THEN
             x_err_stage   := 'API PA_TASK_PUB1.Check_Task_Has_Association FAILED';
        END;

--End Bug 3024607 changes

--bug 3301192
        BEGIN
             x_err_stage := 'PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping'||x_task_id;

             l_return_val := PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping(
                     p_project_id             => x_project_id
                   , p_proj_element_id        => x_task_id );

             IF (l_return_val = 'Y') Then
                x_err_code := 265;
                x_err_stage   :='PA_TSK_HAS_MAPPINGS';
                return;
             END IF;
        EXCEPTION  WHEN OTHERS THEN
             x_err_stage   := 'PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping FAILED';
        END;
--end bug 3301192

-- Begin fix for Bug # 4266540.

        BEGIN

                x_err_stage := 'pa_relationship_utils.check_task_has_sub_proj'||x_task_id;

                l_return_val := pa_relationship_utils.check_task_has_sub_proj(x_project_id
									      , x_task_id
									      , null);

                if (l_return_val = 'Y') then

                        x_err_code := 270;
                        x_err_stage := 'PA_PS_TASK_HAS_SUB_PROJ';
                        return;

                end if;

        EXCEPTION WHEN OTHERS THEN

                x_err_stage := 'pa_task_utils.check_task_has_sub_proj FAILED';

        END;

-- End fix for Bug # 4266540.

	x_err_stack := old_stack;

exception
	when others then
		x_err_code := SQLCODE;
		return;
end check_create_subtask_ok;

--
--  PROCEDURE
--              change_lowest_task_num_ok
--  PURPOSE
--              This procedure checks if a specific task has expenditure items,
--              Po req distributions,po distributions,ap invoices and ap
--              invoice distributions. If task has any of
--              these information, then it's not ok to change the task number
--              and specific reason will be returned.
--		If it's ok to change task number, the x_err_code will be 0.
--
--  HISTORY
--   24-FEB-05      djoseph          Bug 409938: Changed the value of x_err_stage for
--                                   pa_proj_tsk_utils.check_ap_inv_dist_exists
--   10-FEB-99      Ri. Singh        Modified as explained below
--   29-DEC-95      R.Krishnamurthy  Created
--
procedure change_lowest_task_num_ok ( x_task_id           IN  number
                                    , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                    , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
 IS
    old_stack	   varchar2(630);
    status_code	   number;
    x_top_task_id  number;
    x_project_id  number;
BEGIN
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->change_lowest_task_num_ok';

	if (x_task_id is null) then
		x_err_code := 10;
		x_err_stage := 'PA_NO_TASK_ID';
		return;
	end if ;

-- Modified 02/10/99 Ri. Singh
-- all the following  checks are applicable to lowest level tasks.
-- If the task for which subtask is being created is not the lowest level
-- task, these checks need not be performed. Ref Bug#: 773604

        if(check_child_exists(x_task_id)=1) then
           x_err_stack := old_stack;
           return;
        end if;

-- End of fix

       x_project_id :=  pa_proj_tsk_utils.get_task_project_id(x_task_id); -- 4903460
-- Check if task has expenditure item
        x_err_stage := 'check expenditure item for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_exp_item_exists(x_project_id, x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 20;
	    x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has purchase order distribution

        x_err_stage := 'check purchase order for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_dist_exists(x_project_id, x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 30;
	    x_err_stage := 'PA_TSK_PO_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has purchase order requisition
        x_err_stage := 'check purchase order req for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_req_dist_exists(x_project_id, x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 40;
	    x_err_stage := 'PA_TSK_PO_REQ_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has ap invoice
        x_err_stage := 'check ap invoice for '|| x_task_id;
	status_code :=
  	  pa_proj_tsk_utils.check_ap_invoice_exists(x_project_id, x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 50;
	    x_err_stage := 'PA_TSK_AP_INV_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has ap invoice distribution
        x_err_stage := 'check ap inv distribution for '|| x_task_id;
	status_code :=
   	  pa_proj_tsk_utils.check_ap_inv_dist_exists(x_project_id, x_task_id,FALSE); -- 4903460
        if ( status_code = 1 ) then
            x_err_code := 60;
          /*Changed for bug 4069938*/
	  --  x_err_stage := 'PA_TSK_AP_INV_DIST_EXIST';
	    x_err_stage := 'PA_TSK_AP_INV_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	x_err_stack := old_stack;

exception
	when others then
		x_err_code := SQLCODE;
		return;
end change_lowest_task_num_ok;

/*
--
--  PROCEDURE
--              change_task_org_ok
--  PURPOSE
--              This procedure checks if a specific task has CDLs,RDLs or
--              Draft invoices.If task has any of
--              these information, then it's not ok to change the task org
--              and specific reason will be returned.
--		If it's ok to change task org, the x_err_code will be 0.
--
--  HISTORY
--   29-DEC-95      R.Krishnamurthy  Created
--
procedure change_task_org_ok        ( x_task_id           IN  number
                                    , x_err_code          IN OUT    number
                                    , x_err_stage         IN OUT    varchar2
                                    , x_err_stack         IN OUT    varchar2)
IS

CURSOR  Cdl_Cur IS
SELECT NULL
FROM
SYS.DUAL
WHERE EXISTS
     (SELECT NULL
      FROM
          pa_expenditure_items_all paei,
          pa_cost_distribution_lines_all cdl
      WHERE
          paei.expenditure_item_id = cdl.expenditure_item_id
      AND paei.task_id             = x_task_id );

CURSOR  Rdl_Cur IS
SELECT NULL
FROM
SYS.DUAL
WHERE EXISTS
      (SELECT NULL
      FROM
          pa_expenditure_items_all paei,
          pa_cust_rev_dist_lines rdl
      WHERE
          paei.expenditure_item_id = rdl.expenditure_item_id
      AND paei.task_id             = x_task_id );

CURSOR Draft_Inv_Cur IS
SELECT NULL
FROM
SYS.DUAL
WHERE EXISTS
      (SELECT NULL
       FROM
          pa_draft_invoice_items dii
       WHERE dii.Task_id           = x_task_id );

V_ret_val          Varchar2(1);
old_stack	   Varchar2(630);

BEGIN
    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stage := 'Check CDLs for '||x_task_id;

    OPEN Cdl_Cur;
    FETCH Cdl_Cur INTO V_ret_val;
    IF Cdl_Cur%FOUND THEN
       x_err_code   := 10;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       CLOSE Cdl_Cur;
       return;
    ELSE
       CLOSE Cdl_Cur;
    END IF;

    OPEN Rdl_Cur;
    FETCH Rdl_Cur INTO V_ret_val;
    IF Rdl_Cur%FOUND THEN
       x_err_code   := 20;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       CLOSE Rdl_Cur;
       return;
    ELSE
       CLOSE Rdl_Cur;
    END IF;

    OPEN Draft_Inv_Cur;
    FETCH Draft_Inv_Cur INTO V_ret_val;
    IF Draft_Inv_Cur%FOUND THEN
       x_err_code   := 30;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       CLOSE Draft_Inv_Cur;
       return;
    ELSE
       CLOSE Draft_Inv_Cur;
    END IF;

    x_err_stack := old_stack;

Exception
    WHEN others then
      x_err_code := SQLCODE;
      return;

End change_task_org_ok;

*/


--
--  PROCEDURE
--              change_task_org_ok
--  PURPOSE
--              This procedure checks if a specific task has CDLs,RDLs or
--              ERDLs.If task has any of
--              these information, then it's not ok to change the task org
--              and specific reason will be returned.
--		If it's ok to change task org, the x_err_code will be 0.
--
--  HISTORY
--   29-DEC-95      R.Krishnamurthy  Created
--   07-MAY-97      Rewrite this whole api to call other exsiting APIs and
--                  include erdl....    Charles Fong
--
procedure change_task_org_ok        ( x_task_id           IN  number
                                    , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                    , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
IS

old_stack	   Varchar2(630);
status_code    number;

BEGIN
    x_err_code := 0;
    old_stack := x_err_stack;

    x_err_stage := 'Check CDLs for Task '||x_task_id;

    status_code := pa_proj_tsk_utils.check_cdl_exists
                       (Null, x_task_id);

    if status_code <> 0 Then
       x_err_code   := 10;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       return;
    END IF;

        -- Check RDLs for the Task

        x_err_stage := 'check RDLs for Task '||x_task_id;
    status_code := pa_proj_tsk_utils.check_rdl_exists
                       (Null, x_task_id);

    if status_code <> 0 Then
       x_err_code   := 20;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       return;
    END IF;

        -- Check ERDLs for the Task

        x_err_stage := 'check ERDLs for Task '||x_task_id;
    status_code := pa_proj_tsk_utils.check_erdl_exists
                       (Null, x_task_id, null);

    if status_code <> 0 Then
       x_err_code   := 30;
       x_err_stage  := 'PA_TK_CANT_CHG_TASK_ORG';
       return;
    END IF;


    x_err_stack := old_stack;

Exception
    WHEN others then
      x_err_code := SQLCODE;
      return;

End change_task_org_ok;


--
--  PROCEDURE
--              change_task_org_ok2
--  PURPOSE
--              This procedure receives a table of task Ids and org Ids along with other,
--              other parameters , then in turn calls Procedure pa_task_utils.change_task_org_ok1
--              for each set of task Id and org Id.
--
--
--  HISTORY
--   26-DEC-07     Pallavi Jain  Created
--
procedure change_task_org_ok2 (  p_task_id_tbl       IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
                                ,p_project_id        IN  number
				,p_org_id_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
                                ,p_commit            IN  varchar2
				,x_err_stage         IN  OUT NOCOPY varchar2) --File.Sql.39 GSCC Standard


IS

BEGIN

     IF p_task_id_tbl IS NOT NULL AND p_org_id_tbl IS NOT NULL THEN

	FOR i IN p_task_id_tbl.FIRST .. p_task_id_tbl.LAST
	LOOP
	   pa_task_utils.change_task_org_ok1(p_task_id_tbl(i),
	                                     p_project_id,
					     p_org_id_tbl(i),
					     p_commit,
					     x_err_stage);

	END LOOP;

     END IF;

Exception
    WHEN others then
     x_err_stage := 'Error Before Calling Expenditure Items Recalculation';
     return;

End change_task_org_ok2;

--
--  PROCEDURE
--              change_task_org_ok1
--  PURPOSE
--              This procedure checks if a specific task has CDLs,RDLs or
--              ERDLs AND IF the user chooses to recalculate the future dated
--              expenditure items for that task, it performs the recalculation.
--
--
--  HISTORY
--   26-DEC-07     Pallavi Jain  Created
--
procedure change_task_org_ok1 (  p_task_id           IN  number
                                ,p_project_id        IN  number
				,p_new_org_id        IN  number
                                ,p_commit            IN  varchar2
				,x_err_stage         IN OUT NOCOPY varchar2) --File.Sql.39 GSCC Standard


IS

status_code_cdl           NUMBER;
status_code_rdl           NUMBER;
status_code_erdl          NUMBER;
l_mass_adj_outcome        VARCHAR2(30) := NULL;
l_dummy1                  NUMBER;
l_dummy2                  NUMBER;
l_batch_name              VARCHAR2(100);
l_description             VARCHAR2(100);
l_batch_id                NUMBER(25);
l_row_id                  VARCHAR2(25);
l_line_id                 NUMBER;
l_project_currency_code   VARCHAR2(15);
l_project_rate_type       VARCHAR2(30);
l_project_rate_date       DATE;
l_last_update_date        DATE;
l_last_updated_by         NUMBER(15);
l_last_update_login       NUMBER(15);
l_old_org_id              NUMBER(15);


cursor c1
is
select project_currency_code,project_rate_type,project_rate_date
from pa_projects_all
where project_id = p_project_id;

 cursor c2
 is
 select meaning
 from   pa_lookups
 where  lookup_type = 'TRANSLATION'
 and    lookup_code = 'MASS_UPDATE_BATCH_DESC';

 cursor c3
 is
 select meaning
 from   pa_lookups
 where  lookup_type = 'TRANSLATION'
 and    lookup_code = 'MANUAL';

 cursor c4
 is
 select last_update_date,last_updated_by,last_update_login,carrying_out_organization_id
 from pa_tasks
 where task_id = p_task_id
 and project_id = p_project_id;

 BEGIN

     status_code_cdl := pa_proj_tsk_utils.check_cdl_exists
                       (Null, p_task_id);
     status_code_rdl := pa_proj_tsk_utils.check_rdl_exists
                       (Null, p_task_id);
     status_code_erdl := pa_proj_tsk_utils.check_erdl_exists
                       (Null, p_task_id, null);


     OPEN c1;
     FETCH c1 INTO l_project_currency_code,l_project_rate_type,l_project_rate_date;
     CLOSE c1;

     IF (status_code_cdl <> 0 or status_code_rdl <> 0 or status_code_erdl <> 0) THEN
	PA_ADJUSTMENTS.MassAdjust(
		X_adj_action   =>  'COST AND REV RECALC',
		X_module       =>  'PAXTUTLB',
		X_user         =>  fnd_global.user_id,
		X_login        =>  fnd_global.login_id,
		X_project_id   =>  p_project_id,
		X_dest_prj_id  =>  null,
		X_dest_task_id =>  null,
		X_PROJECT_CURRENCY_CODE => l_project_currency_code,
		X_PROJECT_RATE_TYPE     => l_project_rate_type,
		X_PROJECT_RATE_DATE     => l_project_rate_date,
		X_PROJECT_EXCHANGE_RATE => NULL,
		X_task_id      =>  null,
		X_inc_by_person_id => null,
		X_inc_by_org_id    => null,
		X_ei_date_low  =>  trunc(sysdate),
		X_ei_date_high =>  null,
		X_ex_end_date_low   => null,
		X_ex_end_date_high  => null,
		X_system_linkage    => null,
		X_expenditure_type  => null,
		X_expenditure_catg  => null,
		X_expenditure_group => null,
		X_vendor_id         => null,
		X_job_id            => null,
		X_nl_resource_org_id => null,
		X_nl_resource        => null,
		X_transaction_source => null,
		X_cost_distributed_flag    => null,
		X_revenue_distributed_flag => null,
		X_grouped_cip_flag         => null,
		X_bill_status              => null,
		X_hold_flag                => null,
		X_billable_flag            => null,
		X_capitalizable_flag       => null,
		X_net_zero_adjust_flag     => null,
		X_inv_num                  => null,
		X_inv_line_num             => null,
		X_outcome	  =>  l_mass_adj_outcome,
		X_num_processed   =>  l_dummy1,
		X_num_rejected    =>  l_dummy2 );


     OPEN c2;
     FETCH c2 INTO l_description;
     CLOSE c2;

     OPEN c3;
     FETCH c3 INTO l_batch_name;
     CLOSE c3;

     OPEN c4;
     FETCH c4 INTO l_last_update_date,l_last_updated_by,l_last_update_login,l_old_org_id;
     CLOSE c4;

      pa_mu_batches_v_pkg.insert_row (
		X_ROWID                  => l_row_id,
		X_BATCH_ID               => l_batch_id,
		X_CREATION_DATE          => l_last_update_date,
		X_CREATED_BY             => l_last_updated_by,
		X_LAST_UPDATED_BY        => l_last_updated_by,
		X_LAST_UPDATE_DATE       => l_last_update_date,
		X_LAST_UPDATE_LOGIN      => l_last_update_login,
		X_BATCH_NAME             => l_batch_name,
		X_BATCH_STATUS_CODE      => 'C',
		X_DESCRIPTION            => l_description,
		X_PROJECT_ATTRIBUTE      => 'ORGANIZATION',
		X_EFFECTIVE_DATE         => trunc(sysdate),
		X_ATTRIBUTE_CATEGORY     => null,
		X_ATTRIBUTE1             => null,
		X_ATTRIBUTE2             => null,
		X_ATTRIBUTE3             => null,
		X_ATTRIBUTE4             => null,
		X_ATTRIBUTE5             => null,
		X_ATTRIBUTE6             => null,
		X_ATTRIBUTE7             => null,
		X_ATTRIBUTE8             => null,
		X_ATTRIBUTE9             => null,
		X_ATTRIBUTE10            => null,
		X_ATTRIBUTE11            => null,
		X_ATTRIBUTE12            => null,
		X_ATTRIBUTE13            => null,
		X_ATTRIBUTE14            => null,
		X_ATTRIBUTE15            => null
		);

 update PA_MASS_UPDATE_BATCHES
 set batch_name = substr(l_batch_name,1,20)||'-'||to_char(l_batch_id)
 where rowid = l_row_id;

  pa_mu_details_v_pkg.insert_row
  (
   X_ROWID                  => l_row_id,
   X_LINE_ID                => l_line_id,
   X_BATCH_ID               => l_batch_id,
   X_CREATION_DATE          => l_last_update_date,
   X_CREATED_BY             => l_last_updated_by,
   X_LAST_UPDATED_BY        => l_last_updated_by,
   X_LAST_UPDATE_DATE       => l_last_update_date,
   X_LAST_UPDATE_LOGIN      => l_last_update_login,
   X_PROJECT_ID             => p_project_id,
   X_TASK_ID                => p_task_id,
   X_OLD_ATTRIBUTE_VALUE    => l_old_org_id,
   X_NEW_ATTRIBUTE_VALUE    => p_new_org_id,
   X_UPDATE_FLAG            => 'Y',
   X_RECALCULATE_FLAG       => 'Y'
  );

 END IF;

 IF ( p_commit = 'Y')
  THEN
   COMMIT;
  END IF;

 return ;

  Exception
    WHEN others then
      x_err_stage := 'Error on Expenditure Items Recalculation for Task: '||p_task_id;
     return;

End change_task_org_ok1;

 -- Added below for the fix of Bug 7291217
 --  FUNCTION
 --              get_resource_list_name
 --  PURPOSE
 --              This function retrieves the resource list name
 --              If no resource_list_id found, null is returned.
 --              If Oracle error occurs, Oracle error number is returned.
 --  HISTORY
 --   24-JUL-08     Sugupta       Created
 --

 function get_resource_list_name (p_resource_list_id  IN number) return
 varchar2
 is
     cursor c1 is
 select description
 from pa_resource_lists_all_bg
 where resource_list_id = p_resource_list_id;

 l_rl_name pa_resource_lists_all_bg.description%type ;

 begin
 open c1;
 fetch c1 into l_rl_name;
 if c1%notfound then
	    close c1;
    return(null);
 else
	    close c1;
    return( l_rl_name );
	 end if;

 exception
    when others then
 return(SQLCODE);

 end get_resource_list_name;

--
--  PROCEDURE
--              check_delete_task_ok
--  PURPOSE
--              This objective of this API is to check if the task is
--		referenced by other tables.
--
--              To delete a top task and its subtasks, the following
--              requirements must be met:
--                   * No event at top level task
--                   * No funding at top level tasks
--                   * No budget at top level task
--                   * Meet the following requirements for its children
--
--              To delete a mid level task, it involves checking its
--              children and meeting the following requirements for
--              its lowest level task.
--
--              To delete a lowest level task, the following requirements
--              must be met:
--                   * No expenditure item at lowest level task
--                   * No puchase order line at lowest level task
--                   * No requisition line at lowest level task
--                   * No supplier invoice (ap invoice) at lowest level task
--                   * No budget at lowest level task
--
--             A task cannot be deleted  if it is used in Allocations
--
--  HISTORY
--   14-AUG-02     vejayara    Bug# 2331201 - Financial planning development
--                             changes - Added pa_fp_elements in the existence check
--                             in check_delete_task_ok
--   29-MAY-02	    gjain       added a call to pa_proj_tsk_utils.check_iex_task_charged
--				for bug 2367945
--   22-JAN-02      bvarnasi    After all the checks for EI,PO etc. are done,we
--                              need not check for the existance of cc_tax_task_id
--                              as there can not be any cross charge transactions
--                              for tasks that do not have any other transactions.
--   16-FEB-99      Ri. Singh   Added call to check_pct_complete_exists
--   04-JAN-96      S. Lee	Created
--
procedure check_delete_task_ok (x_task_id             IN        number
                        , x_validation_mode    IN VARCHAR2   DEFAULT 'U'    --bug 2947492
                        , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack           IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
is

    old_stack      	varchar2(630);
    status_code    	number;
    l_return_val    	varchar2(1);
    x_top_task_id   	number;

----Bug 2947492
    l_return_status  varchar2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
----Bug 2947492

    cursor p1 is select 1 from pa_project_types
                 where burden_sum_dest_task_id = x_task_id;
    temp             number;
--Ansari
    x_used_in_OTL         BOOLEAN;   --To pass to OTL API.
--Ansari
--local variable Is_IEX_Installed added for bug 2367945
    Is_IEX_Installed      BOOLEAN;
    x_project_id  number;

-- Progress Management Changes. Bug # 3420093.
    l_project_id 	PA_PROJECTS_ALL.PROJECT_ID%TYPE;
-- Progress Management Changes. Bug # 3420093.

-- Bug 3662930

  l_exists             NUMBER;
  l_ship_exists        VARCHAR2(1);
  l_proc_exists        VARCHAR2(1);

  CURSOR c_bill_event_exists(x_project_id IN NUMBER)
  IS
  SELECT count(1) from pa_events ev
   WHERE ev.project_id = x_project_id
     AND nvl(ev.task_id, -1) = x_task_id ;
-- Bug 3662930

begin
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->check_delete_task_ok';

        -- Check task id
        if (x_task_id is null) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_TASK_ID';
                return;
        end if ;

        open p1;
        fetch p1 into temp;
        if p1%notfound then null;
        else
           x_err_code := 260;
           x_err_stage := 'PA_TASK_BURDEN_SUM_DEST';
           return;
        end if;

	-- get top task id
	x_err_stage := 'get top task id for task '|| x_task_id;
        x_top_task_id := pa_task_utils.get_top_task_id(x_task_id);

	if ( x_top_task_id < 0 ) then        -- Oracle error
		x_err_code := x_top_task_id;
		return;
	end if;

       if (x_task_id = x_top_task_id) then
	        -- x_task_id is a top task
	        -- Check if task has event
	        x_err_stage := 'check event for '|| x_task_id;
	        status_code :=
        	        pa_proj_tsk_utils.check_event_exists(null, x_task_id);
	        if ( status_code = 1 ) then
        	    x_err_code := 30;
	            x_err_stage := 'PA_TSK_EVENT_EXIST';
	            return;
	        elsif ( status_code < 0 ) then
	            x_err_code := status_code;
	            return;
	        end if;

	        -- Check if task has funding
	        x_err_stage := 'check funding for '|| x_task_id;
	        status_code :=
	             pa_proj_tsk_utils.check_funding_exists(null, x_task_id);
	        if ( status_code = 1 ) then
	            x_err_code := 40;
	            x_err_stage := 'PA_TSK_FUND_EXIST';
	            return;
	        elsif ( status_code < 0 ) then
	            x_err_code := status_code;
	            return;
	        end if;
	end if;


/*      bug 2947492
        Commented out the code out of here. Please see HLD for budgeting and Forecasting.

        -- Check if task has been selected for planning at any level
        x_err_stage := 'check pa_fp_elements for task '|| x_task_id;
        declare
            cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM  pa_fp_elements r
                        where r.TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_task_id));

            c1_rec c1%rowtype;
        begin
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;    -- this task is not part of the planning options
                else
                   close c1;
                   x_err_code := 90;
                   x_err_stage := 'PA_FP_TSK_ELEMENTS_EXISTS';
                   return;
                end if;
        exception
                when others then
                   close c1;
                   x_err_code := SQLCODE;
                   return;
        end;

        -- Check if task has any budget;  both top and lowest level tasks
        x_err_stage := 'check budget for task '|| x_task_id;
	declare
	    cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM  pa_resource_assignments r
                        where r.TASK_ID IN
                               (SELECT TASK_ID
                                FROM   PA_TASKS
                                CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
                                START WITH TASK_ID = x_task_id));

	    c1_rec c1%rowtype;
	begin
                open c1;
                fetch c1 into c1_rec;
                if c1%notfound then
                   close c1;	-- no budget.  continue
                else
		   close c1;
                   x_err_code := 100;
		   x_err_stage := 'PA_TSK_BUDGET_EXIST';
		   return;
                end if;
	exception
		when others then
		   close c1;
		   x_err_code := SQLCODE;
		   return;
	end;
*/
-- Start of code for Performance Fix 4903460
-- All commented validations in this API for this perf fix are done in
-- the following API : PA_PROJ_ELEMENTS_UTILS.perform_task_validations

     -- Added the following api call to get the project_id and pass it to perform_task_validations. Done for Bug#4964992
      		l_project_id :=  pa_proj_tsk_utils.get_task_project_id(x_task_id);
     -- End of changes for Bug#4964992

     PA_PROJ_ELEMENTS_UTILS.perform_task_validations
     (
      p_project_id => l_project_id
     ,p_task_id    => x_task_id
     ,x_error_code => x_err_code
     ,x_error_msg_code => x_err_stage
     );

     IF x_err_code <> 0 THEN
         IF x_err_code < 0 THEN
                -- this is Unexpected error case
                -- Hence ,Get the x_err_stage from Pa_Debug.g_err_stage to know exact cause
                x_err_stage := Pa_Debug.g_err_stage ;
         END IF;
         -- Other case is > 0 case for which proper message code would have
         -- been populated in x_err_stage ,from x_error_msg_code OUT param of above API
         return;
     END IF;
-- End of new code for Performance fix 4903460

     -- Start of commenting for Performance Fix 4903460
     -- Check if task has expenditure item
        /*x_err_stage := 'check expenditure item for '|| x_task_id;
        status_code :=
                pa_proj_tsk_utils.check_exp_item_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 50;
            x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has purchase order distribution
        x_err_stage := 'check purchase order for '|| x_task_id;
        status_code :=
                pa_proj_tsk_utils.check_po_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 60;
            x_err_stage := 'PA_TSK_PO_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has purchase order requisition
        x_err_stage := 'check purchase order requisition for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_po_req_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 70;
            x_err_stage := 'PA_TSK_PO_REQ_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has supplier invoices
        x_err_stage := 'check supplier invoice for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_ap_invoice_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 80;
            x_err_stage := 'PA_TSK_AP_INV_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has supplier invoice distribution
        x_err_stage := 'check supplier inv distribution for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_ap_inv_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 90;
            x_err_stage := 'PA_TSK_AP_INV_DIST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has commitment transaction
        x_err_stage := 'check commitment transaction for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_commitment_txn_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 110;
            x_err_stage := 'PA_TSK_CMT_TXN_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has compensation rule set
        x_err_stage := 'check compensation rule set for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_comp_rule_set_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 120;
            x_err_stage := 'PA_TSK_COMP_RULE_SET_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;
	-- ENd of commenting for Performance Fix 4903460
*/
        -- Check if task is in use in an external system
        x_err_stage := 'check for task used in external system for'|| x_task_id;
        status_code :=
             pjm_projtask_deletion.CheckUse_ProjectTask(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 130;
            /* Commented the existing error message and modified it to 'PA_PROJ_TASK_IN_USE_MFG' as below for bug 3600806
	    x_err_stage := 'PA_PROJ_IN_USE_EXTERNAL'; */
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_MFG';
            return;
        elsif ( status_code = 2 ) THEN         -- Added elseif condition for bug 3600806.
            x_err_code := 130;
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_AUTO';
	    return;
	elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        elsif ( status_code <> 0) then        -- Added else condition for bug 3600806 to display a generic error message.
            x_err_code := 130;
            x_err_stage := 'PA_PROJ_TASK_IN_USE_EXTERNAL';
            return;
	end if;

        -- Check if task is used in allocations
        x_err_stage := 'check if project allocations uses task '|| x_task_id;
        l_return_val :=
             pa_alloc_utils.Is_Task_In_Allocations(x_task_id);
        if ( l_return_val = 'Y' ) then
            x_err_code := 140;
            x_err_stage := 'PA_TASK_IN_ALLOC';
            return;
        end if;

--         Bug Fix# 773604 02/16/99 Ri. Singh
--         Task cannot be deleted if percent complete exists for any
--         task in the WBS below the task being deleted.

        -- Progress Management Changes. Bug # 3420093.

	-- Check if task has progress
           x_err_stage := 'check object has progress for '|| x_task_id;

	   --l_project_id :=  pa_proj_tsk_utils.get_task_project_id(x_task_id);  Commented this line as we have already retrieved the project_id of the task above for Bug#4964992

           if (pa_progress_utils.check_object_has_prog(p_project_id => l_project_id
						    --  ,p_proj_element_id => x_task_id
                                                      , p_object_id => x_task_id
						      ,p_structure_type => 'FINANCIAL') = 'Y') then
               x_err_code := 150;
               x_err_stage := 'PA_TSK_PCT_COMPL_EXIST';
               return;
           end if;

	-- Progress Management Changes. Bug # 3420093.

--        End of fix 773604

/* Start of Commenting for Performance Fix 4903460
        -- Check if task has draft invoices
        x_err_stage := 'check draft invoice for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_draft_inv_details_exists(x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 160;
            x_err_stage := 'PA_TSK_CC_DINV_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;

        -- Check if task has Project_customers
        x_err_stage := 'check Project Customers for '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_project_customer_exists(x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 170;
            x_err_stage := 'PA_TSK_CC_CUST_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;
-- End of Commenting for Performance Fix 4903460
*/

/*  Commented for Bug # 2185521.
        -- Check if task assign to projects table as a cc_tax_task_id
        x_err_stage := 'check task assign to projects table as a cc_tax_task_id '|| x_task_id;
        status_code :=
             pa_proj_tsk_utils.check_projects_exists(x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 180;
            x_err_stage := 'PA_TSK_CC_PROJ_EXIST';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;
Comment ends : Bug # 2185521 .*/

        -- HSIU added.
        -- Check if project contract is installed
         IF (pa_install.is_product_installed('OKE')) THEN
          x_err_stage := 'Check contract association for task '||x_task_id;
          IF (PA_PROJ_STRUCTURE_PUB.CHECK_TASK_CONTRACT_ASSO(x_task_id) <>
              FND_API.G_RET_STS_SUCCESS) THEN
            x_err_code := 190;
            x_err_stage := 'PA_STRUCT_TK_HAS_CONTRACT';
            return;
          END IF;
        END IF;
        -- Finished checking if project contract is installed.
--Ansari
        --Check to see if the task has been used in OTL--Added by Ansari
          x_err_stage := 'Check OTL task exception';
          PA_OTC_API.ProjectTaskUsed( p_search_attribute => 'TASK',
                                      p_search_value     => x_task_id,
                                      x_used             => x_used_in_OTL );
          --If exists in OTL
          IF x_used_in_OTL
          THEN
            x_err_code := 200;
            x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
            return;
          END IF;

        --end of OTL check.
--Ansari

--fix for bug2367945 starts
	Is_IEX_Installed := pa_install.is_product_installed('IEX');
	If Is_IEX_Installed then
		x_err_stage := 'check if task '|| x_task_id || ' is charged in iexpense';
		status_code := pa_proj_tsk_utils.check_iex_task_charged(x_task_id);
		if ( status_code = 1 ) then
		    x_err_code := 210;
		    x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
		    return;
		elsif ( status_code < 0 ) then
		    x_err_code := status_code;
		    return;
		end if;
	end if;
--fix for bug2367945 ends

--Bug 2947492

        BEGIN
             x_err_stage := 'PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK'||x_task_id;

             PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK(
                   p_task_id                => x_task_id
                  ,p_validation_mode        => x_validation_mode
                  ,x_return_status          => l_return_status
                  ,x_msg_count              => l_msg_count
                  ,x_msg_data               => l_msg_data

               );

             IF (l_return_status <> 'S') Then
                x_err_code := 220;
                x_err_stage   := pa_project_core1.get_message_from_stack( l_msg_data );
                return;
             END IF;
        EXCEPTION  WHEN OTHERS THEN
             x_err_stage   := 'API PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK FAILED';
        END;

--End Bug 2947492 changes

--bug 3301192
        --Bug 3617393
        DECLARE
             CURSOR get_task_project_id(c_task_id IN NUMBER) IS
             SELECT project_id
             FROM   pa_proj_elements
             WHERE  proj_element_id = c_task_id;
        BEGIN

             x_err_stage := 'PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping'||x_task_id;

              -- Get project id
              x_err_stage := 'get project id of '|| x_task_id;
              --Bug 3617393 : Retrieve project id from pa_proj_elements rather than pa_tasks since
              --the data has already been deleted from pa_tasks in delete_project flow
              /*x_project_id :=
                 pa_proj_tsk_utils.get_task_project_id(x_task_id);*/
              OPEN  get_task_project_id(x_task_id);
              FETCH get_task_project_id INTO x_project_id;
              CLOSE get_task_project_id;
              --Bug 3617393 end

              if (x_project_id is null) then
                  x_err_code := 160;
                  x_err_stage := 'PA_NO_PROJECT_ID';
                  return;
              elsif ( x_top_task_id < 0 ) then
                  x_err_code := x_project_id;
                  return;
              end if;

             l_return_val := PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping(
                     p_project_id             => x_project_id
                   , p_proj_element_id        => x_task_id );

             IF (l_return_val = 'Y') Then
                x_err_code := 230;
                x_err_stage   :='PA_TSK_HAS_MAPPINGS';
                return;
             END IF;

             --Bug 3662930 Deletion of Financial Task should not be allowed
             -- If it has transactions through billing events ,initiated shipping transactions,initiated procurement transactions etc

             -- Check (1)
             -- Check for Existence of transactions through Billing Events

	     x_err_stage := 'Check for Transactions through Billing Events for ' || x_task_id ;
             OPEN c_bill_event_exists(x_project_id) ;
	     FETCH c_bill_event_exists INTO l_exists ;
	     CLOSE c_bill_event_exists ;

             IF (l_exists > 0) THEN
		x_err_code := 250 ;
		x_err_stage := 'PA_FIN_TASK_BILL_TXN_EXISTS' ;
                return;
             END IF ;


             --Check (2)
             -- Check for Existence of transactions through initiated shipping transactions,initiated procurement transactions

 	      x_err_stage := 'Check for initiated shipping transactions for ' ||x_task_id ;
              l_ship_exists := OKE_DELIVERABLE_UTILS_PUB.Task_Used_In_Wsh(
                              		                 	          P_Task_ID => x_task_id
									 ) ;
              IF (l_ship_exists = 'Y') THEN
		 x_err_code := 260 ;
		 x_err_stage := 'PA_FIN_TASK_SHIP_TXN_EXISTS' ;
                return;
              END IF ;

              x_err_stage := 'Check for initiated procurement transactions for ' ||x_task_id ;
	      l_proc_exists :=OKE_DELIVERABLE_UTILS_PUB.Task_Used_In_Req(
                                                                          P_Task_ID => x_task_id
                                                                         ) ;
	      IF (l_proc_exists = 'Y') THEN
                 x_err_code := 270 ;
                 x_err_stage := 'PA_FIN_TASK_PROC_TXN_EXISTS' ;
                 return;
              END IF ;
             --End Bug 3662930
        EXCEPTION  WHEN OTHERS THEN
             x_err_stage   := 'PA_PROJ_STRUC_MAPPING_UTILS.Check_Task_Has_Mapping FAILED';
        END;
--end bug 3301192

        x_err_stack := old_stack;

exception
        when others then
                x_err_code := SQLCODE;
--hsiu: commenting out rollback because this API should only be checking for
--      errors. Rollback causes P1s with savepoint issues
--                rollback;
                return;
end check_delete_task_ok;

--
--  FUNCTION
--              sort_order_tree_walk
--  PURPOSE
--              This function does a reverse tree walk in the pa_task table
--              to set up a sort order using input parent_task_id and
--              task_number.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   12-DEC-96      Charles Fong  Created
--
function sort_order_tree_walk(x_parent_id  IN number, x_sort_order_col IN varchar2) return varchar2
is

        cursor c1 (inid number) is
                select task_number parent_task_number
                from pa_tasks
                connect by prior parent_task_id = task_id
                start with task_id = c1.inid;

        rv varchar2(2000) := x_sort_order_col;

begin
        for c1rec in c1(x_parent_id) loop

       -- String length should not exceed 2000
          if 2000-length(rv) - length(c1rec.parent_task_number) >0 then
            rv :=  c1rec.parent_task_number||rv;
          else
            return rv;
          end if;

        end loop;
        return rv;
exception
   when others then
     return(SQLCODE);

end sort_order_tree_walk;


--
--  FUNCTION
--              check_child_exists
--  PURPOSE
--              This function checks whether the task has any child or not and
--              return 1 or 0 accordingly.
--              If Oracle error occurs, Oracle error number is returned.
--
--  HISTORY
--   12-DEC-96      Charles Fong  Created
--
function check_child_exists(x_task_id  IN number) return number
is

        cursor c1 is
                select 1
                from sys.dual
                where exists (SELECT null
                        FROM pa_tasks
                        where parent_task_id = x_task_id);

        c1_rec c1%rowtype;

begin
        if (x_task_id is null) then
                return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        IF c1%notfound THEN
             close c1;
             return(0);
        ELSE
             close c1;
             return(1);
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                RETURN(SQLCODE);
END check_child_exists;

--rtarway, 3908013, procedure to validate flex fields

PROCEDURE validate_flex_fields(
                  p_desc_flex_name        IN     VARCHAR2
                 ,p_attribute_category    IN     VARCHAR2 := null
                 ,p_attribute1            IN     VARCHAR2 := null
                 ,p_attribute2            IN     VARCHAR2 := null
                 ,p_attribute3            IN     VARCHAR2 := null
                 ,p_attribute4            IN     VARCHAR2 := null
                 ,p_attribute5            IN     VARCHAR2 := null
                 ,p_attribute6            IN     VARCHAR2 := null
                 ,p_attribute7            IN     VARCHAR2 := null
                 ,p_attribute8            IN     VARCHAR2 := null
                 ,p_attribute9            IN     VARCHAR2 := null
                 ,p_attribute10           IN     VARCHAR2 := null
                 ,p_attribute11           IN     VARCHAR2 := null
                 ,p_attribute12           IN     VARCHAR2 := null
                 ,p_attribute13           IN     VARCHAR2 := null
                 ,p_attribute14           IN     VARCHAR2 := null
                 ,p_attribute15           IN     VARCHAR2 := null
                 ,p_RETURN_msg            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,p_validate_status       OUT NOCOPY VARCHAR2)                 --File.Sql.39 bug 4440895
IS
        l_dummy VARCHAR2(1);
        l_r VARCHAR2(2000);
BEGIN

        -- DEFINE ID COLUMNS
        fnd_flex_descval.set_context_value(p_attribute_category);
        fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
        fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2);
        fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3);
        fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4);
        fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5);
        fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6);
        fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7);
        fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8);
        fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9);
        fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10);
        fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attribute11);
        fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attribute12);
        fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attribute13);
        fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attribute14);
        fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attribute15);

        -- VALIDATE
        IF (fnd_flex_descval.validate_desccols( 'PA',p_desc_flex_name)) then
              p_RETURN_msg := 'VALID: ' || fnd_flex_descval.concatenated_ids;
              p_validate_status := 'Y';
        ELSE
              p_RETURN_msg := 'INVALID: ' || fnd_flex_descval.error_message;
              p_validate_status := 'N';
        END IF;
EXCEPTION -- 4537865
WHEN OTHERS THEN
	p_validate_status := 'N';
	Fnd_Msg_Pub.add_exc_msg
        ( p_pkg_name         => 'PA_TASK_UTILS'
        , p_procedure_name  => 'validate_flex_fields'
        , p_error_text      => substrb(sqlerrm,1,100));
	RAISE ;
END validate_flex_fields;
--End rtarway, 3908013, procedure to validate flex fields


--
--  PROCEDURE
--              check_set_nonchargeable_ok
--  PURPOSE
--              This procedure checks if a specific task has PO distributions,
--              PO requisition distributions, AP invoice distributions
--              and also if it is referenced in PJM. If the task has any of
--              these information, then it's not ok to make the task nonchargeable
--              and the specific reason will be returned.
--		If it's ok to make the task nonchargeable, the x_err_code will be 0.
--
--  HISTORY
--
--   24-FEB-05      Derrin Joseph  Created for bug 4069938
--
procedure check_set_nonchargeable_ok ( x_task_id           IN  number
                                     , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                                     , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                                     , x_err_stack         IN OUT    NOCOPY varchar2) --File.Sql.39 bug 4440895
IS
    old_stack	   varchar2(630);
    status_code	   number;
    x_top_task_id  number;
    x_project_id   number;
BEGIN
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->check_set_nonchargeable_ok';

	if (x_task_id is null) then
		x_err_code := 10;
		x_err_stage := 'PA_NO_TASK_ID';
		return;
	end if ;


-- All the following checks are applicable only to lowest level tasks.
-- Hence if this is not a lowest level task these checks need not be performed.

        if(check_child_exists(x_task_id)=1) then
           x_err_stack := old_stack;
           return;
        end if;

	-- Check if the task has purchase order distributions

        x_err_stage := 'check purchase order for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 30;
	    x_err_stage := 'PA_TSK_PO_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if the task has purchase order requisitions
        x_err_stage := 'check purchase order req for '|| x_task_id;
	status_code :=
	  pa_proj_tsk_utils.check_po_req_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 40;
	    x_err_stage := 'PA_TSK_PO_REQ_DIST_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

	-- Check if task has ap invoice distributions
        x_err_stage := 'check ap inv distribution for '|| x_task_id;
	status_code :=
   	  pa_proj_tsk_utils.check_ap_inv_dist_exists(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 60;
	    x_err_stage := 'PA_TSK_AP_INV_EXIST';
	    return;
	elsif ( status_code < 0 ) then
	    x_err_code := status_code;
	    return;
	end if;

        -- Check if task is in used in PJM
        x_err_stage := 'check for task used in PJM for'|| x_task_id;
        status_code :=
             pjm_projtask_deletion.CheckUse_ProjectTask(null, x_task_id);
        if ( status_code = 1 ) then
            x_err_code := 195;
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_MFG';
            return;
        elsif ( status_code = 2 ) THEN
            x_err_code := 195;
	    x_err_stage := 'PA_PROJ_TASK_IN_USE_AUTO';
	    return;
	elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        elsif ( status_code <> 0) then        -- Added else condition to display a generic error message.
            x_err_code := 195;
            x_err_stage := 'PA_PROJ_TASK_IN_USE_EXTERNAL';
            return;
	end if;

	x_err_stack := old_stack;

exception
	when others then
		x_err_code := SQLCODE;
		return;
end check_set_nonchargeable_ok;

END PA_TASK_UTILS;

/
