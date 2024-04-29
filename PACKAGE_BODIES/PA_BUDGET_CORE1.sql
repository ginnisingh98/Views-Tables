--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_CORE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_CORE1" as
-- $Header: PAXBUBDB.pls 120.6.12010000.7 2009/12/29 09:08:12 kmaddi ship $\

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception EXCEPTION;
--History
--      xx-xxx-xxxx     who?          - Created
--
--      14-FEB-2005     jwhite        Bug 4176179
--                                    Modifed a select statement in this procedure
--                                    to address some performance issues.
--

--Notes
--
--      For Copy_Actual, no modifications were made for
--      the FP model. Instead, the pa_budget_lines_v_pkg.insert_row
--      procedures, which is called often by Copy_Actual, was
--      modified to address new FP specs for budget lines.
--

  procedure copy_actual (x_project_id                in     number,
                         x_version_id                in     number,
                         x_budget_entry_method_code  in     varchar2,
                         x_resource_list_id          in     number,
                         x_start_period              in     varchar2,
                         x_end_period                in     varchar2,
                         x_err_code                  in out NOCOPY number, --File.Sql.39 bug 4440895
                         x_err_stage                 in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                         x_err_stack                 in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
    -- Standard who
    x_created_by                number(15);
    x_last_update_login         number(15);

    x_entry_level_code          varchar2(30);
    x_categorization_code       varchar2(30);
    x_time_phased_type_code     varchar2(30);
    x_start_period_start_date   date;
    x_end_period_end_date       date;
    x_task_id                   number;
    x_uncat_res_list_member_id  number;
    x_uncat_unit_of_measure     varchar2(30);
    x_uncat_track_as_labor_flag varchar2(2);
    x_raw_cost                  number;
    x_burdened_cost             number;
    x_revenue                   number;
    x_quantity                  number;
    /* Bug 6509313 Following 6 variables are added*/
    x_new_raw_cost              number;
    x_new_burdened_cost         number;
    x_new_revenue               number;
    x_new_quantity              number;
    x_new_assignment_id         number;
    x_new_row_id                rowid;
    x_labor_hours               number;
    x_unit_of_measure           varchar2(30);
    x_resource_assignment_id    number;
    x_raw_cost_total            number;
    x_burdened_cost_total       number;
    x_revenue_total             number;
    x_quantity_total            number;
    x_labor_hours_total         number;
    x_dummy1                    number;
    x_dummy2                    number;
    x_dummy3                    number;
    x_dummy4                    number;
    x_dummy5                    number;
    x_dummy6                    number;
    x_rowid                     rowid;
    old_stack                   varchar2(630);
    x_budget_amount_code        PA_BUDGET_TYPES.BUDGET_AMOUNT_CODE%TYPE;
    /*  Bug 2107130 Following 5 variables are added */
    x_cost_quantity_flag        pa_budget_entry_methods.cost_quantity_flag%TYPE;
    x_raw_cost_flag             pa_budget_entry_methods.raw_cost_flag%TYPE;
    x_burdened_cost_flag        pa_budget_entry_methods.burdened_cost_flag%TYPE;
    x_rev_quantity_flag         pa_budget_entry_methods.rev_quantity_flag%TYPE;
    x_revenue_flag              pa_budget_entry_methods.revenue_flag%TYPE;

    -- record definition
    type period_type is
    record (period_name varchar2(30),
            start_date  date,
            end_date    date);

    period_rec period_type;

    -- cursor definition

    cursor pa_cursor is
      select period_name,
             start_date,
             end_date
      from   pa_periods
      where  start_date between x_start_period_start_date
                        and x_end_period_end_date;

    cursor gl_cursor is
      select p.period_name,
             p.start_date,
             p.end_date
      from   gl_period_statuses p,
             pa_implementations i
      where  p.application_id = pa_period_process_pkg.application_id
      and    p.set_of_books_id = i.set_of_books_id
      and    p.adjustment_period_flag = 'N'  -- Added for bug 3688017
      and    p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

     cursor get_budget_amount_code is
        select budget_amount_code
        from pa_budget_versions b,pa_budget_types t
        where b.budget_version_id = x_version_id
        and   b.budget_type_code = t.budget_type_code;

    cursor c_period_pa(x_project_id NUMBER,
                   x_resource_list_id NUMBER,
		   x_start_period_start_date date,
		   x_end_period_end_date date) is
     select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      from   pa_periods p,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
      and  nvl(m.migration_code, 'M') = 'M'
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and not exists
                     (select 1
                        from   pa_tasks t1
                       where  t1.parent_task_id = t.task_id)
       and   p.start_date between x_start_period_start_date
			and x_end_period_end_date;

     cursor c_period_gl(x_project_id NUMBER,
                   x_resource_list_id NUMBER,
		   x_start_period_start_date date,
		   x_end_period_end_date date) is
 select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
     from   gl_period_statuses p,
             pa_implementations i,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and not exists
                     (select 1
                        from   pa_tasks t1
                       where  t1.parent_task_id = t.task_id)
       and   p.application_id = pa_period_process_pkg.application_id
       and   p.set_of_books_id = i.set_of_books_id
       and    p.adjustment_period_flag = 'N'
       and   p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  cursor c_cost_pa(x_project_id NUMBER,
                 x_task_id NUMBER,
		 x_resource_list_member_id NUMBER,
		 x_period_name varchar2) IS
SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = x_task_id
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id =  x_resource_list_member_id
		          or
			  PRLM.PARENT_MEMBER_ID =  x_resource_list_member_id  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = x_period_name;

  cursor c_cost_gl(x_project_id NUMBER,
                 x_task_id NUMBER,
		 x_resource_list_member_id NUMBER,
		 x_period_name varchar2) IS   SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
       FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = x_task_id
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = x_resource_list_member_id
		          or
			  PRLM.PARENT_MEMBER_ID = x_resource_list_member_id)
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =   x_period_name;

  -- Added for bug 3896747
  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');

  /* variables added for Bug 4889056 */
  l_period_name              PA_PLSQL_DATATYPES.Char240TabTyp;
  l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
  l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;

  l_resource_list_member_id  PA_PLSQL_DATATYPES.IdTabTyp;
  l_resource_id              PA_PLSQL_DATATYPES.IdTabTyp;
  l_track_as_labor_flag      PA_PLSQL_DATATYPES.Char1TabTyp;

  l_task_id                  PA_PLSQL_DATATYPES.IdTabTyp;
 x_billable_raw_cost      NUMBER;
  x_billable_burdened_cost NUMBER;
  x_billable_quantity      NUMBER;
  x_billable_labor_hours   NUMBER;
  x_cmt_raw_cost           NUMBER;
  x_cmt_burdened_cost      NUMBER;
  l_check_flag             NUMBER; /* Added for Bug 6509313*/

  TmpActTab    pa_budget_core1.CopyActualTabTyp;
/* variables added for Bug 4889056 */

  begin

     open get_budget_amount_code;
     fetch get_budget_amount_code into x_budget_amount_code;
     close get_budget_amount_code;

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_actual';

  -- Added for bug 3896747
    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1,x_err_stack);
    End if;

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     savepoint before_copy_actual;

     x_err_stage := 'get budget entry method <' || x_budget_entry_method_code
                    || '>';

  -- Added for bug 3896747
    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1,x_err_stage);
    End if;
     /* Bug# 2107130 Modified the following select statement */

     select entry_level_code, categorization_code,
            time_phased_type_code, cost_quantity_flag,
            raw_cost_flag, burdened_cost_flag,
            rev_quantity_flag, revenue_flag
     into   x_entry_level_code, x_categorization_code,
            x_time_phased_type_code, x_cost_quantity_flag,
            x_raw_cost_flag, x_burdened_cost_flag,
            x_rev_quantity_flag, x_revenue_flag
     from   pa_budget_entry_methods
     where  budget_entry_method_code = x_budget_entry_method_code;

     if (   (x_time_phased_type_code = 'N')
         or (x_time_phased_type_code = 'R')) then
        x_err_code := 10;
        x_err_stage := 'PA_BU_INVALID_TIME_PHASED';
        -- Added for bug 3896747
								If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
									fnd_file.put_line(1,x_err_stage);
								End if;
        return;
     end if;


     x_err_stage := 'get uncategorized resource list member id';

			-- Added for bug 3896747
					If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
						fnd_file.put_line(1,x_err_stage);
					End if;
 -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------

  -- Augmented original code with additional filter

/* -- Original Logic


     -- Added pa_implementations table and corr join for bug 1763100

     select m.resource_list_member_id,
            m.track_as_labor_flag,
            r.unit_of_measure
     into   x_uncat_res_list_member_id,
            x_uncat_track_as_labor_flag,
            x_uncat_unit_of_measure
     from   pa_resources r,
            pa_resource_list_members m,
            pa_implementations i,
            pa_resource_lists l
     where  l.uncategorized_flag = 'Y'
     and    l.resource_list_id = m.resource_list_id
     and    i.business_group_id = l.business_group_id
     and    m.resource_id = r.resource_id;

*/

   -- FP.M Data Model Logic


   -- bug 4176179, 14-FEB-2005, jwhite -----------------------------------
   -- Added two more FP.M financial element reletated filters to improve
   -- performance.

     select m.resource_list_member_id,
            m.track_as_labor_flag,
            r.unit_of_measure
     into   x_uncat_res_list_member_id,
            x_uncat_track_as_labor_flag,
            x_uncat_unit_of_measure
     from   pa_resources r,
            pa_resource_list_members m,
            pa_implementations i,
            pa_resource_lists l
     where  l.uncategorized_flag = 'Y'
     and    l.resource_list_id = m.resource_list_id
     and    i.business_group_id = l.business_group_id
     and    m.resource_id = r.resource_id
     and    m.resource_class_code = 'FINANCIAL_ELEMENTS'
     AND    m.resource_class_id = 4                      /* bug 4176179  */
     AND    m.resource_class_flag = 'Y';                 /* bug 4176179  */

   -- end bug 4176179, 14-FEB-2005, jwhite -----------------------------------

   -- End: FP.M Resource LIst Data Model Impact Changes -----------------------------






     x_err_stage := 'get start date of periods <' || x_start_period
                    || '><' || x_end_period
                    || '>';

			-- Added for bug 3896747
					If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
						fnd_file.put_line(1,x_err_stage);
					End if;

					if (x_time_phased_type_code = 'P') then

         select start_date
         into   x_start_period_start_date
         from   pa_periods
         where  period_name = x_start_period;

         select end_date
         into   x_end_period_end_date
         from   pa_periods
         where  period_name = x_end_period;

     else
         select start_date
         into   x_start_period_start_date
         from   gl_period_statuses p,
                pa_implementations i
         where  p.period_name = x_start_period
         and    p.application_id = pa_period_process_pkg.application_id
         and    p.set_of_books_id = i.set_of_books_id;

         select end_date
         into   x_end_period_end_date
         from   gl_period_statuses p,
                pa_implementations i
         where  p.period_name = x_end_period
         and    p.application_id = pa_period_process_pkg.application_id
         and    p.set_of_books_id = i.set_of_books_id;

     end if;

     x_err_stage := 'delete budget lines <' || to_char(x_version_id)
                    || '><' || x_start_period
                    || '><' || x_end_period
                    || '>';

			-- Added for bug 3896747
					If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
						fnd_file.put_line(1,x_err_stage);
					End if;
     -- Bug Fix: 4569365. Removed MRC code.
     -- pa_mrc_finplan.g_calling_module := PA_MRC_FINPLAN.G_COPY_ACTUALS; /* FPB2: MRC */

     for bl_rec in (
           select rowid
           from   pa_budget_lines l
           where  l.resource_assignment_id in
                  (select a.resource_assignment_id
                   from   pa_resource_assignments a
                   where  a.budget_version_id = x_version_id)
           and    l.start_date between x_start_period_start_date and
                                       x_end_period_end_date) loop

          pa_budget_lines_v_pkg.delete_row(X_Rowid => bl_rec.rowid);
          -- Bug Fix: 4569365. Removed MRC code.
		  --                                           ,X_mrc_flag => 'Y');  /* FPB2: Added x_mrc_flag for MRC changes */
     end loop;

     -- process every period between the starting period and ending period

 /* Code added for Bug 4889056 - Start Part 1 */

  if (x_entry_level_code = 'P') then

	      if (x_categorization_code = 'N') then

             -- project level, uncategorized
    if (x_time_phased_type_code = 'P') then
      select period_name,
             start_date,
	       end_date
      bulk collect into
             l_period_name,
	       l_start_date,
	       l_end_date
      from   pa_periods
      where  start_date between x_start_period_start_date
			and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period =  l_period_name(i);

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;

     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
	       p.start_date,
             p.end_date
      bulk collect into
             l_period_name,
	       l_start_date,
	       l_end_date
      from   gl_period_statuses p,
             pa_implementations i
      where  p.application_id = pa_period_process_pkg.application_id
      and    p.set_of_books_id = i.set_of_books_id
      and    p.adjustment_period_flag = 'N'
      and    p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i);
        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP
                 if x_budget_amount_code = 'C' then
                    TmpActTab(j).revenue := null;

                    if x_cost_quantity_flag = 'N' then
                       TmpActTab(j).labor_hours := null;
                       x_uncat_unit_of_measure := null;
                    end if;

                    if x_raw_cost_flag = 'N' then
                       TmpActTab(j).raw_cost := null;
                    end if;

                    if x_burdened_cost_flag = 'N' then
                       TmpActTab(j).burdened_cost := null;
                    end if;

                 else
                    TmpActTab(j).raw_cost := null;
                    TmpActTab(j).burdened_cost := null;

                    if x_rev_quantity_flag = 'N' then
                       TmpActTab(j).labor_hours := null;
                       x_uncat_unit_of_measure := null;
                    end if;

                    if x_revenue_flag = 'N' then
		       TmpActTab(j).revenue := null;
		    end if;

                 end if;

             if (   (nvl(TmpActTab(j).labor_hours,0) <> 0)
		     or (nvl(TmpActTab(j).raw_cost,0) <> 0)
		     or (nvl(TmpActTab(j).burdened_cost,0) <> 0)
		     or (nvl(TmpActTab(j).revenue,0) <> 0)) then

 /* Added for bug 6509313 */

 		 --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

         BEGIN
         l_check_flag := 0;
         select  (NVL(quantity, 0) + nvl(TmpActTab(j).labor_hours, 0))
               , (NVL(raw_cost,0) + nvl(TmpActTab(j).raw_cost, 0))
               , (NVL(burdened_cost,0)  + nvl(TmpActTab(j).burdened_cost, 0))
               , (NVL(revenue,0) + nvl(TmpActTab(j).revenue, 0))
               , pbl.resource_assignment_id
               , pbl.rowid
           into x_new_quantity,
                x_new_raw_cost,
                x_new_burdened_cost,
                x_new_revenue,
                x_new_assignment_id,
                x_new_row_id
           from pa_budget_lines pbl
         where pbl.resource_assignment_id in (
                select distinct pbl1.resource_assignment_id
                        from pa_budget_lines pbl1,
                             pa_resource_assignments pra,
                             pa_resource_list_members p1,
                             pa_resource_list_members p2
                where pra.resource_list_member_id = p2.resource_list_member_id
                  and p1.parent_member_id = p2.resource_list_member_id
                  and p1.resource_list_member_id = x_uncat_res_list_member_id
                  and pbl1.resource_assignment_id  = pra.resource_assignment_id
                  and pra.budget_version_id       = x_version_id
                  and pbl1.period_name = TmpActTab(j).period_name
               )
          and pbl.budget_version_id = x_version_id
          and pbl.period_name = TmpActTab(j).period_name ;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_check_flag := 1;
           WHEN OTHERS THEN
              l_check_flag := 2;
        END;

         -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687


        IF l_check_flag = 0 THEN

                   rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  0,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  x_labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );

        pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => 0,
                       X_Resource_List_Member_Id => x_uncat_res_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(j).start_date ,
                       X_End_Date                => TmpActTab(j).end_date,
                       X_Period_Name             => TmpActTab(j).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(j).labor_hours,
                       X_Unit_Of_Measure         => x_uncat_unit_of_measure,
                       X_Track_As_Labor_Flag     => x_uncat_track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(j).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(j).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(j).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );

END IF;
                          if (l_check_flag = 1)
                          THEN
                                   rollup_amounts_rg(
                                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                                    X_Budget_Version_Id        =>  x_version_id,
                                                    X_Project_Id               =>  x_project_id,
                                                    X_Task_Id                  =>  0,
                                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                                    X_Quantity                 =>  x_labor_hours,
                                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                                    X_Revenue                  =>  TmpActTab(j).revenue
                                                    );
                /* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  0,
               		            X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A' --,
                                    --X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
             );
                 end if; -- added for bug 6509313
		 end if;
		 END LOOP;
		 /* Code added  for Bug 4889056- End Part 1 */
/*
     if (x_time_phased_type_code = 'P') then
        open pa_cursor;
     else
        open gl_cursor;
     end if;

     loop  -- period

        if (x_time_phased_type_code = 'P') then
           fetch pa_cursor into period_rec ;
           exit when pa_cursor%NOTFOUND;
        else
           fetch gl_cursor into period_rec;
           exit when gl_cursor%NOTFOUND;
        end if;

        x_err_stage := 'process period <' || period_rec.period_name
                        || '><' || x_time_phased_type_code
                        || '>';

									-- Added for bug 3896747
											If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
												fnd_file.put_line(1,x_err_stage);
											End if;

											if (x_entry_level_code = 'P') then

              if (x_categorization_code = 'N') then
                 -- project level, uncategorized
                 x_quantity := 0;
                 x_raw_cost := 0;
                 x_burdened_cost := 0;
                 x_revenue := 0;
                 x_labor_hours := 0;
                 x_unit_of_measure := NULL;

                 pa_accum_api.get_proj_accum_actuals(x_project_id,
                                         NULL,
                                         NULL,
                                         x_time_phased_type_code,
                                         period_rec.period_name,
                                         period_rec.start_date,
                                         period_rec.end_date,
                                         x_revenue,
                                         x_raw_cost,
                                         x_burdened_cost,
                                         x_quantity,
                                         x_labor_hours,
                                         x_dummy1,
                                         x_dummy2,
                                         x_dummy3,
                                         x_dummy4,
                                         x_dummy5,
                                         x_dummy6,
                                         x_unit_of_measure,
                                         x_err_stage,
                                         x_err_code
                                         );

                 if (x_err_code <> 0) then
                     rollback to before_copy_actual;
                     return;
                 end if;

            -- Fix for Bug # 556131
                 if x_budget_amount_code = 'C' then
                    x_revenue := null;

                     -- Bug# 2107130 Following three if/end if statement are added
                    if x_cost_quantity_flag = 'N' then
                       x_labor_hours := null;
                       x_uncat_unit_of_measure := null;
                    end if;

                    if x_raw_cost_flag = 'N' then
                       x_raw_cost := null;
                    end if;

                    if x_burdened_cost_flag = 'N' then
                       x_burdened_cost := null;
                    end if;

                 else
                    x_raw_cost := null;
                    x_burdened_cost := null;

                    -- Bug# 2107130 Following two if/end if statement are added
                    if x_rev_quantity_flag = 'N' then
                       x_labor_hours := null;
                       x_uncat_unit_of_measure := null;
                    end if;

                    if x_revenue_flag = 'N' then
                       x_revenue := null;
                    end if;

                 end if;

                 if (   (nvl(x_labor_hours,0) <> 0)  -- Changed for bug 2107130
                     or (nvl(x_raw_cost,0) <> 0)
                     or (nvl(x_burdened_cost,0) <> 0)
                     or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  0,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_labor_hours,   -- Changed for bug# 2107130
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    --,X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
                                    --                                   );
--        *****  Bug # 2021295 - END   *****

                    if (x_err_code <> 0) then
                        rollback to before_copy_actual;
                        return;
                    end if;

                 end if;
                 */  -- End of commented code part 1
              else


 -- FP.M Resource LIst Data Model Impact Changes, 09-JUN-04, jwhite -----------------------------
 -- Augmented original LOOP SQL to filter out planning resource list members
 -- "  and  nvl(m.migration_code, 'M') = 'M'  "

                 -- project level, categorized
		 /* Begin of part 2 - for BUg 4889056  */
		  if (x_time_phased_type_code = 'P') then
      select p.period_name,
             p.start_date,
	     p.end_date,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_resource_list_member_id,
	     l_resource_id,
             l_track_as_labor_flag
      from   pa_periods p,
             pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
      and  nvl(m.migration_code, 'M') = 'M'
	and    not exists
		(select 1
		 from   pa_resource_list_members m1
		 where  m1.parent_member_id = m.resource_list_member_id)
	 and p.start_date between x_start_period_start_date
			and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = l_period_name(i) ;

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
             p.start_date,
	     p.end_date,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_resource_list_member_id,
	     l_resource_id,
             l_track_as_labor_flag
      from   gl_period_statuses p,
             pa_implementations i,
             pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
	and    not exists
		(select 1
		 from   pa_resource_list_members m1
		 where  m1.parent_member_id = m.resource_list_member_id)
      and    p.application_id = pa_period_process_pkg.application_id
      and    p.set_of_books_id = i.set_of_books_id
      and    p.adjustment_period_flag = 'N'
      and    p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i);

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP
		    if x_budget_amount_code = 'C' then
		       TmpActTab(j).revenue:= null;

                       if x_cost_quantity_flag = 'N' then
                          TmpActTab(j).quantity := null;
                          TmpActTab(j).unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          TmpActTab(j).raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          TmpActTab(j).burdened_cost := null;
                       end if;

		    else
		       TmpActTab(j).raw_cost := null;
		       TmpActTab(j).burdened_cost := null;

                       if x_rev_quantity_flag = 'N' then
                          TmpActTab(j).quantity := null;
                          TmpActTab(j).unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
	    	          TmpActTab(j).revenue := null;
		       end if;

		    end if;

		    if (   (nvl(TmpActTab(j).quantity,0) <> 0)
		        or (nvl(TmpActTab(j).raw_cost,0) <> 0)
		        or (nvl(TmpActTab(j).burdened_cost,0) <> 0)
		        or (nvl(TmpActTab(j).revenue,0) <> 0)) then

  /* Added for bug 6509313 */

         --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

         BEGIN
         l_check_flag :=0;
         select  (NVL(quantity, 0) + nvl(TmpActTab(j).quantity, 0))
               , (NVL(raw_cost,0) + nvl(TmpActTab(j).raw_cost, 0))
               , (NVL(burdened_cost,0)  + nvl(TmpActTab(j).burdened_cost, 0))
               , (NVL(revenue,0) + nvl(TmpActTab(j).revenue, 0))
               , pbl.resource_assignment_id
               , pbl.rowid
           into x_new_quantity,
                x_new_raw_cost,
                x_new_burdened_cost,
                x_new_revenue,
                x_new_assignment_id,
                x_new_row_id
          from pa_budget_lines pbl
         where pbl.resource_assignment_id in (
                 select distinct pbl1.resource_assignment_id
                        from pa_budget_lines pbl1,
                             pa_resource_assignments pra,
                             pa_resource_list_members p1,
                             pa_resource_list_members p2
                where pra.resource_list_member_id = p2.resource_list_member_id
                  and p1.parent_member_id = p2.resource_list_member_id
                  and p1.resource_list_member_id = TmpActTab(j).resource_list_member_id
                  and pbl1.resource_assignment_id  = pra.resource_assignment_id
                  and pra.budget_version_id       = x_version_id
                  and pbl1.period_name = TmpActTab(j).period_name
               )
          and pbl.budget_version_id = x_version_id
          and pbl.period_name = TmpActTab(j).period_name ;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_check_flag :=1;
            WHEN OTHERS THEN
               l_check_flag :=2;
          END;

           -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687

                  IF l_check_flag  =0 THEN

                                     rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  0,
                                    X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  x_new_quantity,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );

             pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => 0,
                       X_Resource_List_Member_Id => TmpActTab(j).resource_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(j).start_date,
                       X_End_Date                => TmpActTab(j).end_date,
                       X_Period_Name             => TmpActTab(j).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(j).quantity,
                       X_Unit_Of_Measure         => TmpActTab(j).unit_of_measure,
                       X_Track_As_Labor_Flag     => TmpActTab(j).track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(j).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(j).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(j).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );
END IF;

          if (l_check_flag = 1)
          THEN
                    rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  0,
                                    X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).quantity,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );
/* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  0,
               		            X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(j).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(j).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue,
                                    X_Change_Reason_Code       =>  NULL,
   				    X_Last_Update_Date         =>  sysdate,
   				    X_Last_Updated_By          =>  x_created_by,
    				    X_Creation_Date            =>  sysdate,
    				    X_Created_By               =>  x_created_by,
    			      	    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
   				                    X_raw_cost_source          =>  'A',
    				                X_burdened_cost_source     =>  'A',
    				                X_quantity_source          =>  'A',
    				                X_revenue_source           =>  'A'  --,
				                    --X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
			 );

                end if;-- added for bug 6509313
                end if;
                END LOOP;
	      end if;
	      /* End of part 2 for Bug 4889056-  */
          /* commenting part for  project level, categorized
                 for res_rec in (select m.resource_list_member_id,
                                        m.resource_id,
                                        m.track_as_labor_flag
                                 from   pa_resource_list_members m
                                 where  m.resource_list_id = x_resource_list_id
                                   and  nvl(m.migration_code, 'M') = 'M'
                                 and    not exists
                                        (select 1
                                         from   pa_resource_list_members m1
                                         where  m1.parent_member_id =
                                                  m.resource_list_member_id)
                                        ) loop

                    x_err_stage := 'process period and resource <'
                        || period_rec.period_name
                        || '><' || to_char(res_rec.resource_list_member_id)
                        || '>';

																		-- Added for bug 3896747
																				If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
																					fnd_file.put_line(1,x_err_stage);
																				End if;

																				x_quantity := 0;
                    x_raw_cost := 0;
                    x_burdened_cost := 0;
                    x_revenue := 0;
                    x_labor_hours := 0;
                    x_unit_of_measure := NULL;

                    pa_accum_api.get_proj_accum_actuals(x_project_id,
                                            NULL,
                                            res_rec.resource_list_member_id,
                                            x_time_phased_type_code,
                                            period_rec.period_name,
                                            period_rec.start_date,
                                            period_rec.end_date,
                                            x_revenue,
                                            x_raw_cost,
                                            x_burdened_cost,
                                            x_quantity,
                                            x_labor_hours,
                                            x_dummy1,
                                            x_dummy2,
                                            x_dummy3,
                                            x_dummy4,
                                            x_dummy5,
                                            x_dummy6,
                                            x_unit_of_measure,
                                            x_err_stage,
                                            x_err_code
                                            );

                    if (x_err_code <> 0) then
                        rollback to before_copy_actual;
                        return;
                    end if;

            -- Fix for Bug # 556131
                    if x_budget_amount_code = 'C' then
                       x_revenue := null;

                        -- Bug# 2107130 Following three if/end if statement are added
                       if x_cost_quantity_flag = 'N' then
                          x_quantity := null;
                          x_unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          x_raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          x_burdened_cost := null;
                       end if;

                    else
                       x_raw_cost := null;
                       x_burdened_cost := null;

                       -- Bug# 2107130 Following two if/end if statement are added
                       if x_rev_quantity_flag = 'N' then
                          x_quantity := null;
                          x_unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
                          x_revenue := null;
                       end if;

                    end if;

                    if (   (nvl(x_quantity,0) <> 0)
                        or (nvl(x_raw_cost,0) <> 0)
                        or (nvl(x_burdened_cost,0) <> 0)
                        or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  0,
                                    X_Resource_List_Member_Id  =>  res_rec.resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_quantity,
                                    X_Unit_Of_Measure          =>  x_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  res_rec.track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    --,X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
                                    --                                );
--        *****  Bug # 2021295 - END   *****

                       if (x_err_code <> 0) then
                           rollback to before_copy_actual;
                           return;
                       end if;

                    end if;

                 end loop;  -- resource

              end if;
                */
	      /* begin of part 3 - Bug 4889056*/
           elsif (x_entry_level_code = 'T') then

	         if (x_categorization_code = 'N') then

		       -- lowest level task, uncategorized
    if (x_time_phased_type_code = 'P') then
      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id
      from   pa_periods p,
             pa_tasks t
      where  t.project_id = x_project_id
       and   t.task_id = t.top_task_id
       and   p.start_date between x_start_period_start_date
			and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
			  CONNECT BY PRIOR task_id = parent_task_id
			  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = l_period_name(i) ;

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id
      from   gl_period_statuses p,
             pa_implementations i,
             pa_tasks t
      where  t.project_id = x_project_id
       and   t.task_id = t.top_task_id
       and   p.application_id = pa_period_process_pkg.application_id
       and   p.set_of_books_id = i.set_of_books_id
       and   p.adjustment_period_flag = 'N'
       and   p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i);

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP
		    if x_budget_amount_code = 'C' then
		       TmpActTab(j).revenue := null;

                       if x_cost_quantity_flag = 'N' then
                          TmpActTab(j).labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          TmpActTab(j).raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          TmpActTab(j).burdened_cost := null;
                       end if;

		    else
		       TmpActTab(j).raw_cost := null;
		       TmpActTab(j).burdened_cost := null;

                       if x_rev_quantity_flag = 'N' then
                          TmpActTab(j).labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
	    	          TmpActTab(j).revenue := null;
		       end if;

		    end if;

		    if (   (nvl(TmpActTab(j).labor_hours,0) <> 0)
		        or (nvl(TmpActTab(j).raw_cost,0) <> 0)
		        or (nvl(TmpActTab(j).burdened_cost,0) <> 0)
		        or (nvl(TmpActTab(j).revenue,0) <> 0)) then

        /* Added for bug 6509313 */

        --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

        BEGIN
        l_check_flag := 0;
        select   (NVL(quantity, 0) + nvl(TmpActTab(j).labor_hours, 0))
               , (NVL(raw_cost,0) + nvl(TmpActTab(j).raw_cost, 0))
               , (NVL(burdened_cost,0)  + nvl(TmpActTab(j).burdened_cost, 0))
               , (NVL(revenue,0) + nvl(TmpActTab(j).revenue, 0))
              , pbl.resource_assignment_id
               , pbl.rowid
          into  x_new_quantity,
                x_new_raw_cost,
                x_new_burdened_cost,
                x_new_revenue,
                x_new_assignment_id,
                x_new_row_id
          from pa_budget_lines pbl
         where pbl.resource_assignment_id in (
                 select distinct pbl1.resource_assignment_id
                        from pa_budget_lines pbl1,
                             pa_resource_assignments pra,
                             pa_resource_list_members p1,
                             pa_resource_list_members p2
                where pra.resource_list_member_id = p2.resource_list_member_id
                  and p1.parent_member_id = p2.resource_list_member_id
                  and p1.resource_list_member_id = x_uncat_res_list_member_id
                  and pbl1.resource_assignment_id  = pra.resource_assignment_id
                  and pra.budget_version_id       = x_version_id
                  and pra.task_id                 = TmpActTab(j).task_id
                  and pbl1.period_name = TmpActTab(j).period_name
               )
          and pbl.budget_version_id = x_version_id
          and pbl.period_name =TmpActTab(j).period_name ;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_check_flag:=1;
             WHEN OTHERS THEN
                l_check_flag:=2;
          END;

           -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687

          IF l_check_flag = 0 THEN

              rollup_amounts_rg(
                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                    X_Budget_Version_Id        =>  x_version_id,
                    X_Project_Id               =>  x_project_id,
                    X_Task_Id                  =>  TmpActTab(j).task_id,
                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                    X_Start_Date               =>  TmpActTab(j).start_date,
                    X_End_Date                 =>  TmpActTab(j).end_date,
                    X_Period_Name              =>  TmpActTab(j).period_name,
                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                    X_Revenue                  =>  TmpActTab(j).revenue
                    );

                pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => TmpActTab(j).task_id,
                       X_Resource_List_Member_Id => x_uncat_res_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(j).start_date,
                       X_End_Date                => TmpActTab(j).end_date,
                       X_Period_Name             => TmpActTab(j).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(j).labor_hours,
                       X_Unit_Of_Measure         => x_uncat_unit_of_measure,
                       X_Track_As_Labor_Flag     => x_uncat_track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(j).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(j).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(j).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );
          end if;

          if (l_check_flag = 1) THEN
                    rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(j).task_id,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );
/* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  TmpActTab(j).task_id,
               		            X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue,
                                    X_Change_Reason_Code       =>  NULL,
   				    X_Last_Update_Date         =>  sysdate,
   				    X_Last_Updated_By          =>  x_created_by,
    				    X_Creation_Date            =>  sysdate,
    				    X_Created_By               =>  x_created_by,
    			      	    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A' --,
                                    --X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
			 );

		    end if;
		    end if; -- added for bug 6509313
                End Loop;
	         else

	    -- top level task, categorized
    /*if (x_time_phased_type_code = 'P') then
      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id,
	     l_resource_list_member_id,
	     l_resource_id,
	     l_track_as_labor_flag
      from   pa_periods p,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
      and  nvl(m.migration_code, 'M') = 'M'
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and   t.task_id = t.top_task_id
       and   p.start_date between x_start_period_start_date
			and x_end_period_end_date;

x_err_stage := 'PA: Period Before Calling the For Loop';
  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
x_err_stage := 'PA: Period Inside the For Loop';
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = l_period_name(i) ;

x_err_stage := 'PA: Period Before inserting into TmpActTab';
        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
x_err_stage := 'PA: Period After inserting into TmpActTab';
     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id,
	     l_resource_list_member_id,
	     l_resource_id,
	     l_track_as_labor_flag
      from   gl_period_statuses p,
             pa_implementations i,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and   t.task_id = t.top_task_id
       and   p.application_id = pa_period_process_pkg.application_id
       and   p.set_of_books_id = i.set_of_books_id
       and    p.adjustment_period_flag = 'N'
       and   p.start_date between x_start_period_start_date
                          and x_end_period_end_date; */

  IF (x_time_phased_type_code = 'P') then
     OPEN  c_period_pa(x_project_id,
                   x_resource_list_id,
                   x_start_period_start_date,
                   x_end_period_end_date);
  ELSE
     OPEN c_period_gl(x_project_id,
                   x_resource_list_id,
                   x_start_period_start_date,
                   x_end_period_end_date);
  END IF;

  /*FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i); */

  LOOP
     if (x_time_phased_type_code = 'P') then
        fetch c_period_pa bulk collect into l_period_name,l_start_date,l_end_date,l_task_id,l_resource_list_member_id,l_resource_id, l_track_as_labor_flag limit 10000;
        EXIT WHEN c_period_pa%NOTFOUND;
     else
        fetch c_period_gl bulk collect into l_period_name,l_start_date,l_end_date,l_task_id,l_resource_list_member_id,l_resource_id, l_track_as_labor_flag limit 10000;
        EXIT WHEN c_period_gl%NOTFOUND;

--x_err_stage := 'Before inserting into TmpActTab';
     end if;
     for i in l_period_name.FIRST..l_period_name.LAST
     LOOP
        if (x_time_phased_type_code = 'P') then
           open c_cost_pa(x_project_id,l_task_id(i),l_RESOURCE_LIST_MEMBER_ID(i),l_period_name(i));
           fetch c_cost_pa into x_revenue,x_raw_cost,x_burdened_cost,x_quantity,x_labor_hours,x_billable_raw_cost, x_billable_burdened_cost, x_billable_quantity,x_billable_labor_hours,x_cmt_raw_cost,x_cmt_burdened_cost, x_unit_of_measure;
           close c_cost_pa;
        else
            open c_cost_gl(x_project_id,l_task_id(i),l_RESOURCE_LIST_MEMBER_ID(i),l_period_name(i));
            fetch c_cost_gl into x_revenue,x_raw_cost,x_burdened_cost,x_quantity,x_labor_hours,x_billable_raw_cost, x_billable_burdened_cost, x_billable_quantity,x_billable_labor_hours,x_cmt_raw_cost,x_cmt_burdened_cost, x_unit_of_measure;
            close c_cost_gl;
        end if;
        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
/*x_err_stage := 'After inserting into TmpActTab';
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP */
                    if x_budget_amount_code = 'C' then
			     TmpActTab(i).revenue := null;

                             if x_cost_quantity_flag = 'N' then
                                TmpActTab(i).quantity := null;
                                TmpActTab(i).unit_of_measure := null;
                             end if;

                             if x_raw_cost_flag = 'N' then
                                TmpActTab(i).raw_cost := null;
                             end if;

                             if x_burdened_cost_flag = 'N' then
                                TmpActTab(i).burdened_cost := null;
                             end if;

			  else
			     TmpActTab(i).raw_cost := null;
			     TmpActTab(i).burdened_cost := null;

                            if x_rev_quantity_flag = 'N' then
                               TmpActTab(i).quantity := null;
                               TmpActTab(i).unit_of_measure := null;
                            end if;

                            if x_revenue_flag = 'N' then
	    	               TmpActTab(i).revenue := null;
                            end if;

			  end if;

		          if (   (nvl(TmpActTab(i).quantity,0) <> 0)
		              or (nvl(TmpActTab(i).raw_cost,0) <> 0)
		              or (nvl(TmpActTab(i).burdened_cost,0) <> 0)
		              or (nvl(TmpActTab(i).revenue,0) <> 0)) then

        /* Added for bug 6509313 */

        --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

        BEGIN
           l_check_flag := 0;
                select   (NVL(quantity, 0) + nvl(TmpActTab(i).quantity, 0))
                       , (NVL(raw_cost,0) + nvl(TmpActTab(i).raw_cost, 0))
                       , (NVL(burdened_cost,0)  + nvl(TmpActTab(i).burdened_cost, 0))
                       , (NVL(revenue,0) + nvl(TmpActTab(i).revenue, 0))
                       , pbl.resource_assignment_id
                       , pbl.rowid
                   into x_new_quantity,
                        x_new_raw_cost,
                        x_new_burdened_cost,
                        x_new_revenue,
                        x_new_assignment_id,
                        x_new_row_id
                   from pa_budget_lines pbl
                 where pbl.resource_assignment_id in (
                        select distinct pbl1.resource_assignment_id
                                from pa_budget_lines pbl1,
                                     pa_resource_assignments pra,
                                     pa_resource_list_members p1,
                                     pa_resource_list_members p2
                        where pra.resource_list_member_id = p2.resource_list_member_id
                          and p1.parent_member_id = p2.resource_list_member_id
                          and p1.resource_list_member_id = TmpActTab(i).resource_list_member_id
                          and pbl1.resource_assignment_id  = pra.resource_assignment_id
                          and pra.budget_version_id       = x_version_id
                          and pra.task_id                 = TmpActTab(i).task_id
                          and pbl1.period_name = TmpActTab(i).period_name
                       )
                  and pbl.budget_version_id = x_version_id
                  and pbl.period_name = TmpActTab(i).period_name ;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_check_flag := 1;
            WHEN OTHERS THEN
               l_check_flag := 2;
         END;

          -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687


         IF l_check_flag = 0 then

                             rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(i).task_id,
                                    X_Resource_List_Member_Id  =>  TmpActTab(i).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(i).start_date,
                                    X_End_Date                 =>  TmpActTab(i).end_date,
                                    X_Period_Name              =>  TmpActTab(i).period_name,
                                    X_Quantity                 =>  TmpActTab(i).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(i).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(i).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(i).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(i).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(i).revenue
                                    );

                 pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => TmpActTab(i).task_id,
                       X_Resource_List_Member_Id => TmpActTab(i).resource_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(i).start_date,
                       X_End_Date                => TmpActTab(i).end_date,
                       X_Period_Name             => TmpActTab(i).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(i).quantity,
                       X_Unit_Of_Measure         => TmpActTab(i).unit_of_measure,
                       X_Track_As_Labor_Flag     => TmpActTab(i).track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(i).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(i).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(i).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );
            end if;

          if (l_check_flag = 1)
          then
                    rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(i).task_id,
                                    X_Resource_List_Member_Id  =>  TmpActTab(i).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(i).start_date,
                                    X_End_Date                 =>  TmpActTab(i).end_date,
                                    X_Period_Name              =>  TmpActTab(i).period_name,
                                    X_Quantity                 =>  TmpActTab(i).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(i).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(i).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(i).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(i).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(i).revenue
                                    );
/* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  TmpActTab(i).task_id,
               		            X_Resource_List_Member_Id  =>  TmpActTab(i).resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(i).start_date,
                                    X_End_Date                 =>  TmpActTab(i).end_date,
                                    X_Period_Name              =>  TmpActTab(i).period_name,
                                    X_Quantity                 =>  TmpActTab(i).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(i).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(i).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(i).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(i).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(i).revenue,
                                    X_Change_Reason_Code       =>  NULL,
   				    X_Last_Update_Date         =>  sysdate,
   				    X_Last_Updated_By          =>  x_created_by,
    				    X_Creation_Date            =>  sysdate,
    				    X_Created_By               =>  x_created_by,
    			      	    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A' --,
                                    --X_mrc_flag               =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
			 );

                         end if; -- added for bug 6509313
                         end if;
                     End Loop;
                    end loop;
                    IF (x_time_phased_type_code = 'P') then
                        close  c_period_pa;
                    ELSE
                    close c_period_gl;
                    END IF;
	            end if;  -- categorized
		    /* end of part 3 - Bug 4889056*/
            /*  elsif (x_entry_level_code = 'T') then

              -- go through every top level task
              for top_task_rec in (select t.task_id
                               from   pa_tasks t
                               where  t.project_id = x_project_id
                               and    t.task_id = t.top_task_id) loop

                 x_raw_cost:= 0;
                 x_burdened_cost:= 0;
                 x_revenue:= 0;
                 x_quantity := 0;
                 x_labor_hours:= 0;

                 if (x_categorization_code = 'N') then

                       -- lowest level task, uncategorized
                       x_quantity := 0;
                       x_raw_cost := 0;
                       x_burdened_cost := 0;
                       x_revenue := 0;
                       x_labor_hours := 0;
                       x_unit_of_measure := NULL;

                       pa_accum_api.get_proj_accum_actuals(x_project_id,
                                               top_task_rec.task_id,
                                               NULL,
                                               x_time_phased_type_code,
                                               period_rec.period_name,
                                               period_rec.start_date,
                                               period_rec.end_date,
                                               x_revenue,
                                               x_raw_cost,
                                               x_burdened_cost,
                                               x_quantity,
                                               x_labor_hours,
                                               x_dummy1,
                                               x_dummy2,
                                               x_dummy3,
                                               x_dummy4,
                                               x_dummy5,
                                               x_dummy6,
                                               x_unit_of_measure,
                                               x_err_stage,
                                               x_err_code
                                               );

                       if (x_err_code <> 0) then
                           rollback to before_copy_actual;
                           return;
                       end if;

            -- Fix for Bug # 556131
                    if x_budget_amount_code = 'C' then
                       x_revenue := null;

                       -- Bug# 2107130 Following three if/end if statement are added
                       if x_cost_quantity_flag = 'N' then
                          x_labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          x_raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          x_burdened_cost := null;
                       end if;

                    else
                       x_raw_cost := null;
                       x_burdened_cost := null;

                       -- Bug# 2107130 Following two if/end if statement are added
                       if x_rev_quantity_flag = 'N' then
                          x_labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
                          x_revenue := null;
                       end if;

                    end if;

                    if (   (nvl(x_labor_hours,0) <> 0)  -- Changed for bug# 2107130
                        or (nvl(x_raw_cost,0) <> 0)
                        or (nvl(x_burdened_cost,0) <> 0)
                        or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  top_task_rec.task_id,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_labor_hours,   -- Changed for bug# 2107130
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    --,X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
                                    --                                );
--        *****  Bug # 2021295 - END   *****

                          if (x_err_code <> 0) then
                              rollback to before_copy_actual;
                              return;
                          end if;

                    end if;

                 else

                    -- top level task, categorized
                    for res_rec in (select m.resource_list_member_id,
                                           m.resource_id,
                                           m.track_as_labor_flag
                                    from   pa_resource_list_members m
                                    where  m.resource_list_id =
                                                        x_resource_list_id
                                       and  nvl(m.migration_code, 'M') = 'M'
                                    and    not exists
                                           (select 1
                                            from   pa_resource_list_members m1
                                            where  m1.parent_member_id =
                                                     m.resource_list_member_id)
                                    )    loop

                       x_quantity:= 0;
                       x_raw_cost:= 0;
                       x_burdened_cost:= 0;
                       x_revenue:= 0;
                       x_labor_hours:= 0;
                       x_unit_of_measure := NULL;

                          x_err_stage := 'process period/task/resource <'
                              || period_rec.period_name
                              || '><' || to_char(top_task_rec.task_id)
                              || '><'
                              || to_char(res_rec.resource_list_member_id)
                              || '>';

																								-- Added for bug 3896747
																										If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
																											fnd_file.put_line(1,x_err_stage);
																										End if;
                          pa_accum_api.get_proj_accum_actuals(x_project_id,
                                                top_task_rec.task_id,
                                                res_rec.resource_list_member_id,
                                                x_time_phased_type_code,
                                                period_rec.period_name,
                                                period_rec.start_date,
                                                period_rec.end_date,
                                                x_revenue,
                                                x_raw_cost,
                                                x_burdened_cost,
                                                x_quantity,
                                                x_labor_hours,
                                                x_dummy1,
                                                x_dummy2,
                                                x_dummy3,
                                                x_dummy4,
                                                x_dummy5,
                                                x_dummy6,
                                                x_unit_of_measure,
                                                x_err_stage,
                                                x_err_code
                                                );

                             if (x_err_code <> 0) then
                                 rollback to before_copy_actual;
                                 return;
                             end if;

            -- Fix for Bug # 556131
                          if x_budget_amount_code = 'C' then
                             x_revenue := null;

                             -- Bug# 2107130 Following three if/end if statement are added
                             if x_cost_quantity_flag = 'N' then
                                x_quantity := null;
                                x_unit_of_measure := null;
                             end if;

                             if x_raw_cost_flag = 'N' then
                                x_raw_cost := null;
                             end if;

                             if x_burdened_cost_flag = 'N' then
                                x_burdened_cost := null;
                             end if;

                          else
                             x_raw_cost := null;
                             x_burdened_cost := null;

                             Bug# 2107130 Following two if/end if statement are added
                            if x_rev_quantity_flag = 'N' then
                               x_quantity := null;
                               x_unit_of_measure := null;
                            end if;

                            if x_revenue_flag = 'N' then
                               x_revenue := null;
                            end if;

                          end if;

                          if (   (nvl(x_quantity,0) <> 0)
                              or (nvl(x_raw_cost,0) <> 0)
                              or (nvl(x_burdened_cost,0) <> 0)
                              or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  top_task_rec.task_id,
                                    X_Resource_List_Member_Id  =>  res_rec.resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_quantity,
                                    X_Unit_Of_Measure          =>  x_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  res_rec.track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    -- X_mrc_flag                 =>  'Y'         FPB2: Added x_mrc_flag for MRC changes
                                    --                                );
        *****  Bug # 2021295 - END   *****

                             if (x_err_code <> 0) then
                                 rollback to before_copy_actual;
                                 return;
                             end if;

                         end if;

                       end loop; -- resource

                    end if;  -- categorized

              end loop;  -- top task
          */  -- End of commented code for Part 3 4889056

           else  -- 'L' or 'M'
              -- go through every lowest level task
	      /* Begin of part 4 - Bug 4889056 */
	       if (x_categorization_code = 'N') then
		    -- lowest level task, uncategorized
    if (x_time_phased_type_code = 'P') then
      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id
      from   pa_periods p,
             pa_tasks t
      where  t.project_id = x_project_id
       and    not exists
		      (select 1
		       from   pa_tasks t1
		       where  t1.parent_task_id = t.task_id)
       and   p.start_date between x_start_period_start_date
			and x_end_period_end_date;

x_err_stage := 'PA: Period Before Calling the For Loop';
  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
x_err_stage := 'PA: Period Inside the For Loop';
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = l_period_name(i) ;

x_err_stage := 'PA: Period Before inserting into tmp table';
        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
x_err_stage := 'PA: Period After inserting into tmp table';
     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id
      from   gl_period_statuses p,
             pa_implementations i,
             pa_tasks t
      where  t.project_id = x_project_id
       and    not exists
		      (select 1
		       from   pa_tasks t1
		       where  t1.parent_task_id = t.task_id)
       and   p.application_id = pa_period_process_pkg.application_id
       and   p.set_of_books_id = i.set_of_books_id
       and    p.adjustment_period_flag = 'N'
       and   p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i);

        TmpActTab(i).period_name             := l_period_name(i);
        TmpActTab(i).start_date              := l_start_date(i);
        TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
  /* Commented for Bug 6933201- This is uncategorized block and below field have no significance.
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
  */
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP
		    if x_budget_amount_code = 'C' then
		       TmpActTab(j).revenue := null;

                       if x_cost_quantity_flag = 'N' then
                          TmpActTab(j).labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          TmpActTab(j).raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          TmpActTab(j).burdened_cost := null;
                       end if;

		    else
		       TmpActTab(j).raw_cost := null;
		       TmpActTab(j).burdened_cost := null;

                       if x_rev_quantity_flag = 'N' then
                          TmpActTab(j).labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
	    	          TmpActTab(j).revenue := null;
		       end if;

		    end if;

		    if (   (nvl(TmpActTab(j).labor_hours,0) <> 0)
		        or (nvl(TmpActTab(j).raw_cost,0) <> 0)
		        or (nvl(TmpActTab(j).burdened_cost,0) <> 0)
		        or (nvl(TmpActTab(j).revenue,0) <> 0)) then

/* Added for bug 6509313 */

        --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

        BEGIN
        l_check_flag:=0;
        select   (NVL(quantity, 0) + nvl(TmpActTab(j).labor_hours, 0))
               , (NVL(raw_cost,0) + nvl(TmpActTab(j).raw_cost, 0))
               , (NVL(burdened_cost,0)  + nvl(TmpActTab(j).revenue, 0))
               , (NVL(revenue,0) + nvl(TmpActTab(j).revenue, 0))
               , pbl.resource_assignment_id
               , pbl.rowid
           into x_new_quantity,
                x_new_raw_cost,
                x_new_burdened_cost,
                x_new_revenue,
                x_new_assignment_id,
                x_new_row_id
           from pa_budget_lines pbl
         where pbl.resource_assignment_id in (
                 select distinct pbl1.resource_assignment_id
                        from pa_budget_lines pbl1,
                             pa_resource_assignments pra,
                             pa_resource_list_members p1,
                             pa_resource_list_members p2
                where pra.resource_list_member_id = p2.resource_list_member_id
                  and p1.parent_member_id = p2.resource_list_member_id
                  and p1.resource_list_member_id = x_uncat_res_list_member_id
                  and pbl1.resource_assignment_id  = pra.resource_assignment_id
                  and pra.budget_version_id       = x_version_id
                  and pra.task_id                 = TmpActTab(j).task_id
                  and pbl1.period_name = TmpActTab(j).period_name
               )
          and pbl.budget_version_id = x_version_id
          and pbl.period_name = TmpActTab(j).period_name ;
          EXCEPTION
             WHEN no_data_found THEN
                l_check_flag :=1;
             WHEN OTHERS THEN
                l_check_flag :=2;
          END;

           -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687

       if l_check_flag = 0 then

                           rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(j).task_id,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );

         pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => TmpActTab(j).task_id,
                       X_Resource_List_Member_Id => x_uncat_res_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(j).start_date,
                       X_End_Date                => TmpActTab(j).end_date,
                       X_Period_Name             => TmpActTab(j).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(j).labor_hours,
                       X_Unit_Of_Measure         => x_uncat_unit_of_measure,
                       X_Track_As_Labor_Flag     => x_uncat_track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(j).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(j).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(j).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );
          end if;

          if (l_check_flag = 1)          THEN

                    rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(j).task_id,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );
/* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  TmpActTab(j).task_id,
               		            X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).labor_hours,
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue,
                                    X_Change_Reason_Code       =>  NULL,
   				    X_Last_Update_Date         =>  sysdate,
   				    X_Last_Updated_By          =>  x_created_by,
    				    X_Creation_Date            =>  sysdate,
    				    X_Created_By               =>  x_created_by,
    			      	    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A' --,
                                    --X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
			 );
                    end if;-- added for bug 6509313
		    end if;
		    End Loop;
	         else

		    -- lowest level task, categorized
x_err_stage := 'lowest level task, categorized';
    if (x_time_phased_type_code = 'P') then
      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id,
	     l_resource_list_member_id,
	     l_resource_id,
	     l_track_as_labor_flag
      from   pa_periods p,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
      and  nvl(m.migration_code, 'M') = 'M'
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and not exists
                     (select 1
                        from   pa_tasks t1
                       where  t1.parent_task_id = t.task_id)
       and   p.start_date between x_start_period_start_date
			and x_end_period_end_date;

x_err_stage := 'lowest level task, categorized: Before For Loop';
  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
x_err_stage := 'lowest level task, categorized: Inside For Loop';
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.pa_period = l_period_name(i) ;

x_err_stage := 'lowest level task, categorized: Before inserting in Tmp table '||i;
      TmpActTab(i).period_name             := l_period_name(i);
      TmpActTab(i).start_date              := l_start_date(i);
      TmpActTab(i).end_date                := l_end_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
x_err_stage := 'lowest level task, categorized: After inserting in Tmp table';
     END LOOP;
    else -- x_time_phased_type_code = 'G'

      select p.period_name,
             p.start_date,
	     p.end_date,
	     t.task_id,
	     m.resource_list_member_id,
	     m.resource_id,
	     m.track_as_labor_flag
      bulk collect into
             l_period_name,
	     l_start_date,
	     l_end_date,
	     l_task_id,
	     l_resource_list_member_id,
	     l_resource_id,
	     l_track_as_labor_flag
      from   gl_period_statuses p,
             pa_implementations i,
             pa_tasks t,
	     pa_resource_list_members m
      where  m.resource_list_id = x_resource_list_id
        and    not exists
		   (select 1
		    from   pa_resource_list_members m1
		    where  m1.parent_member_id =
			     m.resource_list_member_id)
       and   t.project_id = x_project_id
       and not exists
                     (select 1
                        from   pa_tasks t1
                       where  t1.parent_task_id = t.task_id)
       and   p.application_id = pa_period_process_pkg.application_id
       and   p.set_of_books_id = i.set_of_books_id
       and    p.adjustment_period_flag = 'N'
       and   p.start_date between x_start_period_start_date
                          and x_end_period_end_date;

  FOR i in l_period_name.FIRST..l_period_name.LAST LOOP
      SELECT
          sum(tot_revenue),
          sum(tot_raw_cost),
          sum(tot_burdened_cost),
          sum(tot_quantity),
          sum(tot_labor_hours),
          sum(tot_billable_raw_cost),
          sum(tot_billable_burdened_cost),
          sum(tot_billable_quantity),
          sum(tot_billable_labor_hours),
          sum(tot_cmt_raw_cost),
          sum(tot_cmt_burdened_cost),
          Decode(sign(count(Distinct unit_of_measure)- 1), 0, max(unit_of_measure),null) unit_of_measure
      INTO
          x_revenue,
          x_raw_cost,
          x_burdened_cost,
          x_quantity,
          x_labor_hours,
          x_billable_raw_cost,
          x_billable_burdened_cost,
          x_billable_quantity,
          x_billable_labor_hours,
          x_cmt_raw_cost,
          x_cmt_burdened_cost,
          x_unit_of_measure
      FROM
	  pa_txn_accum pta
      WHERE
        pta.project_id = x_project_id
      AND pta.task_id IN
                 (SELECT
                       task_id
                  FROM
                       pa_tasks
                  CONNECT BY PRIOR task_id = parent_task_id
                  START WITH task_id = l_task_id(i)
	          )
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_RESOURCE_ACCUM_DETAILS PRAD
            WHERE  PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
            AND    PRAD.RESOURCE_LIST_MEMBER_ID IN
                (  -- Fetch both 2nd level and group level resource list member
                   SELECT PRLM.RESOURCE_LIST_MEMBER_ID
	             FROM  PA_RESOURCE_LIST_MEMBERS PRLM
                    WHERE (prlm.resource_list_member_id = l_RESOURCE_LIST_MEMBER_ID(i)
		          or
			  PRLM.PARENT_MEMBER_ID = l_RESOURCE_LIST_MEMBER_ID(i)  )
		)
	  )
      AND EXISTS
          ( SELECT 'Yes' FROM PA_TXN_ACCUM_DETAILS PTAD
            WHERE
                PTA.TXN_ACCUM_ID = PTAD.TXN_ACCUM_ID
          )
      AND pta.gl_period =  l_period_name(i);

      TmpActTab(i).period_name             := l_period_name(i);
      TmpActTab(i).start_date              := l_start_date(i);
      TmpActTab(i).end_date                := l_start_date(i);
	TmpActTab(i).task_id                 := l_task_id(i);
	TmpActTab(i).resource_list_member_id := l_resource_list_member_id(i);
	TmpActTab(i).resource_id             := l_resource_id(i);
	TmpActTab(i).track_as_labor_flag     := l_track_as_labor_flag(i);
	TmpActTab(i).REVENUE                 := x_revenue;
	TmpActTab(i).RAW_COST                := x_raw_cost;
	TmpActTab(i).BURDENED_COST           := x_burdened_cost;
	TmpActTab(i).QUANTITY                := x_quantity;
	TmpActTab(i).LABOR_HOURS             := x_labor_hours;
	TmpActTab(i).BILLABLE_RAW_COST       := x_billable_raw_cost;
	TmpActTab(i).BILLABLE_BURDENED_COST  := x_billable_burdened_cost;
	TmpActTab(i).BILLABLE_QUANTITY       := x_billable_quantity;
	TmpActTab(i).BILLABLE_LABOR_HOURS    := x_billable_labor_hours;
	TmpActTab(i).CMT_RAW_COST            := x_cmt_raw_cost;
	TmpActTab(i).CMT_BURDENED_COST       := x_cmt_burdened_cost;
	TmpActTab(i).UNIT_OF_MEASURE         := x_unit_of_measure;
     END LOOP;
    end if;

          For j in TmpActTab.FIRST..TmpActTab.LAST LOOP
		       if x_budget_amount_code = 'C' then
			  TmpActTab(j).revenue:= null;

			  /* Bug# 2107130 Following three if/end if statement are added */
                          if x_cost_quantity_flag = 'N' then
                             TmpActTab(j).quantity := null;
                             TmpActTab(j).unit_of_measure := null;
                          end if;

                          if x_raw_cost_flag = 'N' then
                             TmpActTab(j).raw_cost := null;
                          end if;

                          if x_burdened_cost_flag = 'N' then
                             TmpActTab(j).burdened_cost := null;
                          end if;

		       else
			  TmpActTab(j).raw_cost := null;
			  TmpActTab(j).burdened_cost := null;

                          /* Bug# 2107130 Following two if/end if statement are added */
                          if x_rev_quantity_flag = 'N' then
                             TmpActTab(j).quantity := null;
                             TmpActTab(j).unit_of_measure := null;
                          end if;

                          if x_revenue_flag = 'N' then
	    	             TmpActTab(j).revenue := null;
		          end if;

		       end if;

		       if (   (nvl(TmpActTab(j).quantity,0) <> 0)
		           or (nvl(TmpActTab(j).raw_cost,0) <> 0)
		           or (nvl(TmpActTab(j).burdened_cost,0) <> 0)
		           or (nvl(TmpActTab(j).revenue,0) <> 0)) then

         /* Added for bug 6509313 */

         --Bug 9080687
		 x_new_quantity       :=null;
		 x_new_raw_cost       :=null;
		 x_new_burdened_cost  :=null;
		 x_new_revenue        :=null;

          BEGIN
          l_check_flag :=0;
          select (NVL(quantity, 0) + nvl(TmpActTab(j).labor_hours, 0))
               , (NVL(raw_cost,0) + nvl(TmpActTab(j).raw_cost, 0))
               , (NVL(burdened_cost,0)  + nvl(TmpActTab(j).burdened_cost, 0))
               , (NVL(revenue,0) + nvl(TmpActTab(j).revenue, 0))
               , pbl.resource_assignment_id
               , pbl.rowid
            into x_new_quantity,
                x_new_raw_cost,
                x_new_burdened_cost,
                x_new_revenue,
                x_new_assignment_id,
                x_new_row_id
            from pa_budget_lines pbl
         where pbl.resource_assignment_id in (
                 select distinct pbl1.resource_assignment_id
                        from pa_budget_lines pbl1,
                             pa_resource_assignments pra,
                             pa_resource_list_members p1,
                             pa_resource_list_members p2
                where pra.resource_list_member_id = p2.resource_list_member_id
                  and p1.parent_member_id = p2.resource_list_member_id
                  and p1.resource_list_member_id = TmpActTab(j).resource_list_member_id
                  and pbl1.resource_assignment_id  = pra.resource_assignment_id
                  and pra.budget_version_id       = x_version_id
                  and pra.task_id                 = TmpActTab(j).task_id
                  and pbl1.period_name = TmpActTab(j).period_name
               )
          and pbl.budget_version_id = x_version_id
          and pbl.period_name = TmpActTab(j).period_name ;
          EXCEPTION
             WHEN no_data_found THEN
               l_check_flag:=1;
             WHEN OTHERS THEN
               l_check_flag:=2;
          END;

           -- Bug 9080687
		if x_budget_amount_code = 'C' then
			x_new_revenue := null;

			if x_cost_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_raw_cost_flag = 'N' then
			  x_new_raw_cost := null;
			end if;

			if x_burdened_cost_flag = 'N' then
			   x_new_burdened_cost := null;
			end if;

		else
			x_new_raw_cost := null;
			x_new_burdened_cost := null;

			if x_rev_quantity_flag = 'N' then
			   x_new_quantity := null;
			end if;

			if x_revenue_flag = 'N' then
				x_new_revenue := null;
			end if;

		end if;
		-- Bug 9080687

          if l_check_flag = 0 then


           rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(j).task_id,
                                    X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(j).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(j).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );


                  pa_budget_lines_v_pkg.update_Row(X_Rowid => x_new_row_id,
                       X_Resource_Assignment_Id  => x_new_assignment_id,
                       X_Budget_Version_Id       => x_version_id,
                       X_Project_Id              => x_project_id,
                       X_Task_Id                 => TmpActTab(j).task_id,
                       X_Resource_List_Member_Id => TmpActTab(j).resource_list_member_id,
                       X_Resource_Id             => NULL,
                       X_Resource_Id_Old         => NULL,
                       X_Description             => NULL,
                       X_Start_Date              => TmpActTab(j).start_date,
                       X_End_Date                => TmpActTab(j).end_date,
                       X_Period_Name             => TmpActTab(j).period_name,
                       X_Quantity                => x_new_quantity,
                       X_Quantity_Old            => TmpActTab(j).quantity,
                       X_Unit_Of_Measure         => TmpActTab(j).unit_of_measure,
                       X_Track_As_Labor_Flag     => TmpActTab(j).track_as_labor_flag,
                       X_Raw_Cost                => x_new_raw_cost,
                       X_Raw_Cost_Old            => TmpActTab(j).raw_cost,
                       X_Burdened_Cost           => x_new_burdened_cost,
                       X_Burdened_Cost_Old       => TmpActTab(j).burdened_cost,
                       X_Revenue                 => x_new_revenue,
                       X_Revenue_Old             => TmpActTab(j).revenue,
                       X_Change_Reason_Code      => NULL,
                       X_Last_Update_Date        => sysdate,
                       X_Last_Updated_By         => x_created_by,
                       X_Last_Update_Login       => x_last_update_login,
                       X_Attribute_Category      => NULL,
                       X_Attribute1              => NULL,
                       X_Attribute2              => NULL,
                       X_Attribute3              => NULL,
                       X_Attribute4              => NULL,
                       X_Attribute5              => NULL,
                       X_Attribute6              => NULL,
                       X_Attribute7              => NULL,
                       X_Attribute8              => NULL,
                       X_Attribute9              => NULL,
                       X_Attribute10             => NULL,
                       X_Attribute11             => NULL,
                       X_Attribute12             => NULL,
                       X_Attribute13             => NULL,
                       X_Attribute14             => NULL,
                       X_Attribute15             => NULL,
                       -- X_mrc_flag             => 'Y', -- Removed MRC code.
                       X_Calling_Process         => 'PR',
                       X_raw_cost_source         => 'A',
                       X_burdened_cost_source    => 'A',
                       X_quantity_source         => 'A',
                       X_revenue_source          => 'A' );

          end if;

          if (l_check_flag = 1)
          THEN
            rollup_amounts_rg(
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                      X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  TmpActTab(j).task_id,
                                    X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(j).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(j).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue
                                    );
/* Ends added for 6509313 */

		    pa_budget_lines_v_pkg.insert_row (
        			    X_Rowid                    =>  x_rowid,
    				    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
    			  	    X_Budget_Version_Id        =>  x_version_id,
    	                            X_Project_Id               =>  x_project_id,
       		                    X_Task_Id                  =>  TmpActTab(j).task_id,
               		            X_Resource_List_Member_Id  =>  TmpActTab(j).resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  TmpActTab(j).start_date,
                                    X_End_Date                 =>  TmpActTab(j).end_date,
                                    X_Period_Name              =>  TmpActTab(j).period_name,
                                    X_Quantity                 =>  TmpActTab(j).quantity,
                                    X_Unit_Of_Measure          =>  TmpActTab(j).unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  TmpActTab(j).track_as_labor_flag,
                                    X_Raw_Cost                 =>  TmpActTab(j).raw_cost,
                                    X_Burdened_Cost            =>  TmpActTab(j).burdened_cost,
                                    X_Revenue                  =>  TmpActTab(j).revenue,
                                    X_Change_Reason_Code       =>  NULL,
   				    X_Last_Update_Date         =>  sysdate,
   				    X_Last_Updated_By          =>  x_created_by,
    				    X_Creation_Date            =>  sysdate,
    				    X_Created_By               =>  x_created_by,
    			      	    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A'--,
                                    --X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
             );
                      end if;-- added for bug 6509313
                      end if;
                 End Loop;
             end if;

       end if;
       /* End of part 4 for BUg 4889056 */
       /* Begin of commented code
              for task_rec in (select t.task_id
                               from   pa_tasks t
                               where  t.project_id = x_project_id
                               and    not exists
                                      (select 1
                                       from   pa_tasks t1
                                       where  t1.parent_task_id = t.task_id)

                 ) loop

                 if (x_categorization_code = 'N') then
                    -- lowest level task, uncategorized
                    x_quantity := 0;
                    x_raw_cost := 0;
                    x_burdened_cost := 0;
                    x_revenue := 0;
                    x_labor_hours := 0;
                    x_unit_of_measure := NULL;

                    pa_accum_api.get_proj_accum_actuals(x_project_id,
                                            task_rec.task_id,
                                            NULL,
                                            x_time_phased_type_code,
                                            period_rec.period_name,
                                            period_rec.start_date,
                                            period_rec.end_date,
                                            x_revenue,
                                            x_raw_cost,
                                            x_burdened_cost,
                                            x_quantity,
                                            x_labor_hours,
                                            x_dummy1,
                                            x_dummy2,
                                            x_dummy3,
                                            x_dummy4,
                                            x_dummy5,
                                            x_dummy6,
                                            x_unit_of_measure,
                                            x_err_stage,
                                            x_err_code
                                            );

                    if (x_err_code <> 0) then
                        rollback to before_copy_actual;
                        return;
                    end if;

                    if x_budget_amount_code = 'C' then
                       x_revenue := null;

                       -- Bug# 2107130 Following three if/end if statement are added
                       if x_cost_quantity_flag = 'N' then
                          x_labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_raw_cost_flag = 'N' then
                          x_raw_cost := null;
                       end if;

                       if x_burdened_cost_flag = 'N' then
                          x_burdened_cost := null;
                       end if;

                    else
                       x_raw_cost := null;
                       x_burdened_cost := null;

                       -- Bug# 2107130 Following two if/end if statement are added
                       if x_rev_quantity_flag = 'N' then
                          x_labor_hours := null;
                          x_uncat_unit_of_measure := null;
                       end if;

                       if x_revenue_flag = 'N' then
                          x_revenue := null;
                       end if;

                    end if;

                    if (   (nvl(x_labor_hours,0) <> 0)   -- Changed for Bug 2107130
                        or (nvl(x_raw_cost,0) <> 0)
                        or (nvl(x_burdened_cost,0) <> 0)
                        or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  task_rec.task_id,
                                    X_Resource_List_Member_Id  =>  x_uncat_res_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_labor_hours,    -- Changed for bug# 2107130
                                    X_Unit_Of_Measure          =>  x_uncat_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  x_uncat_track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    -- X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
                                    --                                );
--        *****  Bug # 2021295 - END   ****

                       if (x_err_code <> 0) then
                           rollback to before_copy_actual;
                           return;
                       end if;

                    end if;

                 else

                    -- lowest level task, categorized
                    for res_rec in (select m.resource_list_member_id,
                                           m.resource_id,
                                           m.track_as_labor_flag
                                    from   pa_resource_list_members m
                                    where  m.resource_list_id =
                                                        x_resource_list_id
                                         and  nvl(m.migration_code, 'M') = 'M'
                                    and    not exists
                                           (select 1
                                            from   pa_resource_list_members m1
                                            where  m1.parent_member_id =
                                                     m.resource_list_member_id)
                                        ) loop

                       x_err_stage := 'process period/task/resource <'
                           || period_rec.period_name
                           || '><' || to_char(task_rec.task_id)
                           || '><' || to_char(res_rec.resource_list_member_id)
                           || '>';

																					-- Added for bug 3896747
																							If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
																								fnd_file.put_line(1,x_err_stage);
																							End if;

																							x_quantity := 0;
                       x_raw_cost := 0;
                       x_burdened_cost := 0;
                       x_revenue := 0;
                       x_labor_hours := 0;
                       x_unit_of_measure := NULL;

                       pa_accum_api.get_proj_accum_actuals(x_project_id,
                                               task_rec.task_id,
                                               res_rec.resource_list_member_id,
                                               x_time_phased_type_code,
                                               period_rec.period_name,
                                               period_rec.start_date,
                                               period_rec.end_date,
                                               x_revenue,
                                               x_raw_cost,
                                               x_burdened_cost,
                                               x_quantity,
                                               x_labor_hours,
                                               x_dummy1,
                                               x_dummy2,
                                               x_dummy3,
                                               x_dummy4,
                                               x_dummy5,
                                               x_dummy6,
                                               x_unit_of_measure,
                                               x_err_stage,
                                               x_err_code
                                               );

                       if (x_err_code <> 0) then
                           rollback to before_copy_actual;
                           return;
                       end if;

                       if x_budget_amount_code = 'C' then
                          x_revenue := null;

                          -- Bug# 2107130 Following three if/end if statement are added
                          if x_cost_quantity_flag = 'N' then
                             x_quantity := null;
                             x_unit_of_measure := null;
                          end if;

                          if x_raw_cost_flag = 'N' then
                             x_raw_cost := null;
                          end if;

                          if x_burdened_cost_flag = 'N' then
                             x_burdened_cost := null;
                          end if;

                       else
                          x_raw_cost := null;
                          x_burdened_cost := null;

                          -- Bug# 2107130 Following two if/end if statement are added
                          if x_rev_quantity_flag = 'N' then
                             x_quantity := null;
                             x_unit_of_measure := null;
                          end if;

                          if x_revenue_flag = 'N' then
                             x_revenue := null;
                          end if;

                       end if;

                       if (   (nvl(x_quantity,0) <> 0)
                           or (nvl(x_raw_cost,0) <> 0)
                           or (nvl(x_burdened_cost,0) <> 0)
                           or (nvl(x_revenue,0) <> 0)) then

--        *****  Bug # 2021295 - BEGIN   *****

          PAXBUEBU:COPY ACTUALS DOES NOT PICK UP ACTUAL REVENUE FOR WORK/EVENT BUDGET
                Changed the following call to the procedure pa_budget_lines_v_pkg.insert_row
                from "Positional Parameter Passing" to "Named Parameter Passing".


                    pa_budget_lines_v_pkg.insert_row (
                                    X_Rowid                    =>  x_rowid,
                                    X_Resource_Assignment_Id   =>  x_resource_assignment_id,
                                    X_Budget_Version_Id        =>  x_version_id,
                                    X_Project_Id               =>  x_project_id,
                                    X_Task_Id                  =>  task_rec.task_id,
                                    X_Resource_List_Member_Id  =>  res_rec.resource_list_member_id,
                                    X_Description              =>  NULL,
                                    X_Start_Date               =>  period_rec.start_date,
                                    X_End_Date                 =>  period_rec.end_date,
                                    X_Period_Name              =>  period_rec.period_name,
                                    X_Quantity                 =>  x_quantity,
                                    X_Unit_Of_Measure          =>  x_unit_of_measure,
                                    X_Track_As_Labor_Flag      =>  res_rec.track_as_labor_flag,
                                    X_Raw_Cost                 =>  x_raw_cost,
                                    X_Burdened_Cost            =>  x_burdened_cost,
                                    X_Revenue                  =>  x_revenue,
                                    X_Change_Reason_Code       =>  NULL,
                                    X_Last_Update_Date         =>  sysdate,
                                    X_Last_Updated_By          =>  x_created_by,
                                    X_Creation_Date            =>  sysdate,
                                    X_Created_By               =>  x_created_by,
                                    X_Last_Update_Login        =>  x_last_update_login,
                                    X_Attribute_Category       =>  NULL,
                                    X_Attribute1               =>  NULL,
                                    X_Attribute2               =>  NULL,
                                    X_Attribute3               =>  NULL,
                                    X_Attribute4               =>  NULL,
                                    X_Attribute5               =>  NULL,
                                    X_Attribute6               =>  NULL,
                                    X_Attribute7               =>  NULL,
                                    X_Attribute8               =>  NULL,
                                    X_Attribute9               =>  NULL,
                                    X_Attribute10              =>  NULL,
                                    X_Attribute11              =>  NULL,
                                    X_Attribute12              =>  NULL,
                                    X_Attribute13              =>  NULL,
                                    X_Attribute14              =>  NULL,
                                    X_Attribute15              =>  NULL,
                                    X_Calling_Process          =>  'PR',
                                    X_Pm_Product_Code          =>  NULL,
                                    X_Pm_Budget_Line_Reference  =>  NULL,
                                    X_raw_cost_source          =>  'A',
                                    X_burdened_cost_source     =>  'A',
                                    X_quantity_source          =>  'A',
                                    X_revenue_source           =>  'A');
                                    -- Bug Fix: 4569365. Removed MRC code.
                                    -- X_mrc_flag                 =>  'Y'        -- FPB2: Added x_mrc_flag for MRC changes
                                    --                                );
--        *****  Bug # 2021295 - END   ****

                          if (x_err_code <> 0) then
                              rollback to before_copy_actual;
                              return;
                          end if;

                      end if;

                    end loop; -- resource

                 end if;

              end loop;  -- task

           end if;

        end loop; -- period


     if (x_time_phased_type_code = 'P') then
        close pa_cursor;
     else
        close gl_cursor;
     end if;   */ --End of commented code
     -- Bug Fix: 4569365. Removed MRC code.
     -- pa_mrc_finplan.g_calling_module := null; /* FPB2: MRC */

     x_err_stack := old_stack;

  exception
      when others then
         x_err_code := SQLCODE;
         -- Bug Fix: 4569365. Removed MRC code.
         -- pa_mrc_finplan.g_calling_module := null; /* FPB2: MRC */
         return;
  end copy_actual;

/* Starts added for bug # 6509313 */

PROCEDURE rollup_amounts_rg(
                       X_Resource_Assignment_Id  IN OUT NOCOPY NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id IN OUT NOCOPY NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER
                       )
    IS
        --BUG 6509313 Start
        cursor get_parent_member(x_child_member_id number) is
            select p2.resource_list_member_id parent_member_id
              from pa_resource_list_members p1,
                   pa_resource_list_members p2
             where p1.parent_member_id = p2.resource_list_member_id
               and p1.resource_list_member_id = x_child_member_id; -- child id

        cursor parent_amounts(l_parent_id number,
                              x_budget_version_id number,
                              x_task_id number
                             )
        is
        select pbl.resource_assignment_id resource_assignment_id
          from pa_budget_lines pbl,
               pa_resource_assignments pra
         where pra.resource_list_member_id = l_parent_id
           and pbl.resource_assignment_id  = pra.resource_assignment_id
           and pra.budget_version_id       = x_budget_version_id
           and nvl(pra.task_id, 0)                 = nvl(x_task_id, 0) ;

         parent_rec parent_amounts%ROWTYPE;

        l_parent_id number;

  pragma autonomous_transaction;

BEGIN
   open get_parent_member(X_Resource_List_Member_Id);
   fetch get_parent_member INTO l_parent_id;

   open parent_amounts(l_parent_id,
                      X_Budget_Version_Id,
                      X_Task_Id);

   FETCH parent_amounts INTO parent_rec;

   if (parent_amounts%FOUND) Then
    X_Resource_Assignment_Id := parent_rec.resource_assignment_id;
    X_Resource_List_Member_Id := l_parent_id;
   end if;
   close parent_amounts;

   close get_parent_member;

EXCEPTION
   WHEN OTHERS THEN
     NULL;

END rollup_amounts_rg;

-------------------------------------------------------------------------------------
-- This procedure is used by the baseline procedure to copy budget lines and
-- resource assignments from a source (draft) budget version to the destination
-- (baselined) budget version for a single project
--
-- Notes
--              !!! This procedure does NOT copy lines for FP plan types !!!
--
--                  This procedure only supports r11.5.7 Budgets. Minimal modifications
--                  have been made to copy new FP currency codes and so on.
--
-- History
--
--      30-MAY-01       jwhite          As per Budget Integration development, added
--                                      the following columns to copy_draft_lines
--                                      procedure.
--                                      1. X_Code_Combination_Id
--                                      2. X_CCID_Gen_Status_Code
--                                      3. X_CCID_Gen_Rej_Message
--
--
--     27-JUN-2002      jwhite        Bug 1877119
--                                    For the Copy_Lines procedure, add new column
--                                    for insert into pa_resource_assignments:
--                                    project_assignment_id, default -1.
--
--      13-AUG-2002     jwhite        To prevent FP model queries from breaking,
--                                    added the following columns to the insert:
--                                    a.   projfunc_currency_code
--                                    b.   project_currency_code
--                                    c.   txn_currency_code
--
--                                    Additionally, the following filter was added for
--                                    pa_resource_assignments:
--                                      NVL(RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED'
--


  procedure copy_draft_lines  (x_src_version_id        in     number,
                               x_time_phased_type_code in     varchar2,
                               x_entry_level_code      in     varchar2,
                               x_dest_version_id       in     number,
                               x_err_code              in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage             in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack             in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_pm_flag               in     varchar2 )
  is
    -- Standard who
    x_created_by                 NUMBER(15);
    x_last_update_login          NUMBER(15);

    old_stack  varchar2(630);

    x_msg_count          NUMBER := 0;
    x_msg_data           VARCHAR2(2000);
    x_return_status      VARCHAR2(2000);

    l_target_is_baselined  VARCHAR2(1);

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_draft_lines';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     --     Bug 3266168: commented-out savepoint since this procedure is called from a procedure with a savepoint.
     --savepoint before_copy_draft_lines;

     begin
       select 'Y'
       into   l_target_is_baselined
       from   pa_budget_versions
       where  budget_status_code = 'B'
       and    budget_version_id = x_dest_version_id;
     exception
       when no_data_found then
         l_target_is_baselined := 'N';
     end;

     x_err_stage := 'copy resource assignment <' ||  to_char(x_src_version_id)
                    || '>' ;

        insert into pa_resource_assignments
            (resource_assignment_id,
             budget_version_id,
             project_id,
             task_id,
             resource_list_member_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             unit_of_measure,
             track_as_labor_flag,
             project_assignment_id,
             RESOURCE_ASSIGNMENT_TYPE
             )
           select pa_resource_assignments_s.nextval,
               x_dest_version_id,
               s.project_id,
               s.task_id,
               s.resource_list_member_id,
               SYSDATE,
               x_created_by,
               SYSDATE,
               x_created_by,
               x_last_update_login,
               s.unit_of_measure,
               s.track_as_labor_flag,
               -1,
               s.RESOURCE_ASSIGNMENT_TYPE
           from
               pa_resource_assignments s
           where  s.budget_version_id = x_src_version_id
           and    NVL(s.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED';

         -- Bug Fix: 4569365. Removed MRC code.
         x_err_stage := 'calling populate_bl_map_tmp <' ||to_char(x_src_version_id)
                    || '>' ;

         -- FPB2: MRC
         /* MRC Elimination changes: PA_MRC_FINPLAN.populate_bl_map_tmp */
         PA_FIN_PLAN_UTILS2.populate_bl_map_tmp
		(p_source_fin_plan_version_id  => x_src_version_id,
                                            x_return_status               => x_return_status,
                                            x_msg_count                   => x_msg_count,
                                            x_msg_data                    => x_msg_data);

             x_err_stage := 'copy budget lines <' ||to_char(x_src_version_id)
                            || '>' ;

             insert into pa_budget_lines
               (budget_line_id,           /* FPB2 during changes for MRC */
                budget_version_id,        /* FPB2 */
                resource_assignment_id,
                start_date,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                end_date,
                period_name,
                quantity,
                raw_cost,
                burdened_cost,
                revenue,
                change_reason_code,
                description,
                attribute_category,
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
                attribute15,
                pm_product_code,
                pm_budget_line_reference,
                raw_cost_source,
                burdened_cost_source,
                quantity_source,
                revenue_source,
                Code_Combination_Id,
                CCID_Gen_Status_Code,
                CCID_Gen_Rej_Message,
                projfunc_currency_code,
                project_currency_code,
                txn_currency_code
                )
              select
                bmt.target_budget_line_id,   /* FPB2 */
                da.budget_version_id,        /* FPB2 */
                da.resource_assignment_id,
                l.start_date,
                SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
                l.end_date,
                l.period_name,
                l.quantity,
                l.raw_cost,
                l.burdened_cost,
                l.revenue,
                l.change_reason_code,
                l.description,
                l.attribute_category,
                l.attribute1,
                l.attribute2,
                l.attribute3,
                l.attribute4,
                l.attribute5,
                l.attribute6,
                l.attribute7,
                l.attribute8,
                l.attribute9,
                l.attribute10,
                l.attribute11,
                l.attribute12,
                l.attribute13,
                l.attribute14,
                l.attribute15,
                decode(x_pm_flag,'Y',l.pm_product_code,NULL),
                decode(x_pm_flag,'Y',l.pm_budget_line_reference,NULL),
                'B',
                'B',
                'B',
                'B',
                l.Code_Combination_Id,
                l.CCID_Gen_Status_Code,
                l.CCID_Gen_Rej_Message,
                l.projfunc_currency_code,
                l.project_currency_code,
                l.txn_currency_code
              from  pa_budget_lines l,
                    pa_resource_assignments sa,
                    pa_resource_assignments da,
                    pa_fp_bl_map_tmp bmt  /* FPB2 */
             where  l.resource_assignment_id = sa.resource_assignment_id
             and    sa.budget_version_id = x_src_version_id
             and    sa.task_id = da.task_id
             and    sa.project_id = da.project_id
             and    sa.resource_list_member_id = da.resource_list_member_id
             and    da.budget_version_id = x_dest_version_id
             and    NVL(sa.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED'
             and    bmt.source_budget_line_id = l.budget_line_id /* FPB2: MRC */ ;
         -- Bug Fix: 4569365. Removed MRC code.
         /* FPB2: MRC */
         /*******************************
         BEGIN

            IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                 PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                   (x_return_status      => x_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data);
            END IF;

            -- Bug 2676494

              IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS THEN
               IF PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                -- This api is called only by baseline api
                  PA_MRC_FINPLAN.COPY_MC_BUDGET_LINES
                                   (p_source_fin_plan_version_id => x_src_version_id,
                                    p_target_fin_plan_version_id => x_dest_version_id,
                                    x_return_status              => x_return_status,
                                    x_msg_count                  => x_msg_count,
                                    x_msg_data                   => x_msg_data);
               ELSIF  (PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'B' AND l_target_is_baselined = 'Y') THEN
                    PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                               (p_fin_plan_version_id => x_dest_version_id, -- Target version should be passed
                                p_entire_version      => 'Y',
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);

              END IF;
             END IF;

            --Bug 2676494

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE g_mrc_exception;
            END IF;


         END;
         *************************************/


     x_err_stack := old_stack;


  exception
      when others then
         x_err_code := SQLCODE;
         --rollback to before_copy_draft_lines;
         return;

 end copy_draft_lines;

/*------------------------------------------------------------------------------------------------------------------
Added for performance issue
------------------------------------------------------------------------------------------------------------------*/
 function get_first_accum_period ( x_project_id       in number,
                                   x_budget_type_code in varchar2)
          return date is

     cursor get_info is
       select pbv.resource_list_id,
              pbem.time_phased_type_code,
              pbv.budget_version_id
         from pa_budget_versions pbv,
              pa_budget_entry_methods pbem
        where pbem.budget_entry_method_code = pbv.budget_entry_method_code
          and pbv.project_id         = x_project_id
          and pbv.budget_type_code   = x_budget_type_code
          and pbv.budget_status_code = 'W';

     cursor get_budget_amount_code(x_version_id  pa_budget_versions.budget_version_id%type) is
        select budget_amount_code
          from pa_budget_versions b,
               pa_budget_types t
         where b.budget_version_id = x_version_id
           and b.budget_type_code  = t.budget_type_code;

   l_resource_list_id       pa_resource_lists_all_bg.resource_list_id%type;
   l_time_phased_type_code  pa_budget_entry_methods.time_phased_type_code%type;
   l_start_period_name      pa_periods_all.period_name%type;
   l_start_period_date      pa_periods_all.start_date%type;
   l_budget_version_id      pa_budget_versions.budget_version_id%type;
   l_budget_amount_code     pa_budget_types.budget_amount_code%type;
   x_err_code               number;
   x_err_stage              varchar2(2000);
   x_err_stack              varchar2(2000);
   x_process_flag           varchar2(1);
 Begin
   x_process_flag := 'N';
    If g_project_id is not null and
       g_budget_type_code is not null then
        if x_project_id <> g_project_id or --changed the condition for bug 6134042
          x_budget_type_code <> g_budget_type_code then
          x_process_flag := 'Y';
       Else
          x_process_flag := 'N';
       End if;
    elsif
       g_project_id is null and
       g_budget_type_code is null then
       x_process_flag := 'Y';
    end if;

   If x_process_flag = 'Y' then
       g_project_id := x_project_id;
       g_budget_type_code := x_budget_type_code;

    Open get_info;
    Fetch get_info into l_resource_list_id, l_time_phased_type_code, l_budget_version_id;
    Close get_info;

    open get_budget_amount_code(l_budget_version_id);
    fetch get_budget_amount_code into l_budget_amount_code;
    close get_budget_amount_code;

   pa_accum_utils.get_first_accum_period(x_project_id,
                                         l_resource_list_id,
                                         l_budget_amount_code,
                                         l_time_phased_type_code,
                                         l_start_period_name,
                                         l_start_period_date,
                                         x_err_code,
                                         x_err_stage,
                                         x_err_stack);


    if (x_err_code <> 0) then
        g_project_id := NULL;
        g_budget_type_code := NULL;
        return null;
    end if;
    g_start_period_date := l_start_period_date;
   end if;

   Return g_start_period_date;

Exception
  When Others Then
    g_project_id := NULL;
    g_budget_type_code := NULL;
    Return NULL;
end get_first_accum_period;

/*********************************************************************************************
Autonomous transaction is used as the value should appear in the database. Based on this value
copy actuals is allowed or restricted through budget form and/or concurrent request
*********************************************************************************************/
procedure update_budget_version (x_request_id           number default null,
                                 x_budget_version_id    pa_budget_versions.budget_version_id%type)
is
pragma autonomous_transaction;
begin
      update pa_budget_versions
         set request_id = x_request_id
       where budget_version_id = x_budget_version_id;
   commit;
end;

/*********************************************************************************************
Wrapper over procedure copy actuals. It will be called from the concurrent request
PRC: Copy Actuals
*********************************************************************************************/
procedure copy_actuals1 ( errbuf                IN OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                         retcode                IN OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                         x_project_id           in     number,
                         x_budget_type_code     in     varchar2,
                         x_start_period         in     varchar2,
                         x_end_period           in     varchar2)
  is

  cursor get_budget_info is
    select pbv.resource_list_id,
           pbv.budget_entry_method_code,
           pbv.budget_version_id,
           pbv.request_id
      from pa_budget_versions pbv
     where pbv.project_id         = x_project_id
       and pbv.budget_type_code   = x_budget_type_code
       and pbv.budget_status_code = 'W';

  x_err_code                  number;
  x_err_stack                 varchar2(2000);
  x_err_stage                 varchar2(2000);
  l_resource_list_id          pa_resource_lists_all_bg.resource_list_id%type;
  l_budget_entry_method_code  pa_budget_entry_methods.time_phased_type_code%type;
  l_budget_version_id         pa_budget_versions.budget_version_id%type;


  l_start_period_date         pa_periods_all.start_date%type;
  l_end_period_date           pa_periods_all.end_date%type;
  l_time_phased_type_code     pa_budget_entry_methods.time_phased_type_code%TYPE; -- Bug 8682811

  l_request_id                number;

  exc_wrong_period_set        exception;
  exc_copy_actual             exception;
  incorrect_timephase         exception; -- Bug 8682811

  P_DEBUG_MODE varchar2(1) :=NVL(FND_PROFILE.VALUE('PA_DEBUG_MODE'),'N');

begin
  --Initializing global variable
  g_calling_mode := 'CONCURRENT REQUEST';

  -- Print the input parameter values
  fnd_file.put_line(1, 'x_project_id       :'||x_project_id);
  fnd_file.put_line(1, 'x_budget_type_code :'||x_budget_type_code);
  fnd_file.put_line(1, 'x_start_period     :'||x_start_period);
  fnd_file.put_line(1, 'x_end_period       :'||x_end_period);
  fnd_file.put_line(1, 'x_debug_mode       :'||p_debug_mode);

  If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
     fnd_file.put_line(1, 'Calling Copy Actuals');
  End if;

  -- Bug 8682811 changes start
    Open get_budget_info;
    Fetch get_budget_info into l_resource_list_id, l_budget_entry_method_code, l_budget_version_id, l_request_id;
    Close get_budget_info;

    If l_budget_version_id IS NOT NULL then

        If nvl(l_request_id,-1) = -99 then
           raise exc_copy_actual;
        else

            select time_phased_type_code
            into l_time_phased_type_code
            from pa_budget_entry_methods
            where budget_entry_method_code = l_budget_entry_method_code;

            If l_time_phased_type_code not in ('P','G') then
                fnd_file.put_line(1, 'Please choose a Budget Entry Method that has periodic time phasing.');
                raise incorrect_timephase;
            end if;

            select period_start_date
            into l_start_period_date
            from pa_budget_periods_v
            where period_name = x_start_period
            and period_type_code = l_time_phased_type_code;

            select period_start_date
            into l_end_period_date
            from pa_budget_periods_v
            where period_name = x_end_period
            and period_type_code = l_time_phased_type_code;

  -- Bug 8682811 changes end
/* Commented for Bug 8682811

    select request_id
      into l_request_id
      from pa_budget_versions
     where project_id = x_project_id
       and budget_type_code = x_budget_type_code
       and budget_status_code = 'W';

    If nvl(l_request_id,-1) = -99 then
       raise exc_copy_actual;
    else

      select period_start_date
        into l_start_period_date
        from pa_budget_periods_v
       where period_name = x_start_period;

      select period_start_date
        into l_end_period_date
        from pa_budget_periods_v
       where period_name = x_end_period;

Commented for Bug 8682811 */

      If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
         fnd_file.put_line(1, 'Start Period :'||l_start_period_date||' End Period :'||l_end_period_date);
      End if;

      If l_start_period_date <= l_end_period_date then

/* Commented for Bug 8682811
        Open get_budget_info;
        Fetch get_budget_info into l_resource_list_id, l_budget_entry_method_code, l_budget_version_id;
        Close get_budget_info;
 Commented for Bug 8682811 */

        update_budget_version( x_request_id => -99,
                               x_budget_version_id => l_budget_version_id);

	pa_budget_core1.copy_actual( x_project_id,
                                     l_budget_version_id,
                                     l_budget_entry_method_code,
                                     l_resource_list_id,
                                     x_start_period,
                                     x_end_period,
                                     x_err_code,
                                     x_err_stage,
                                     x_err_stack);
        retcode := x_err_code;
        errbuf  := x_err_stack;
        If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
          fnd_file.put_line(1, errbuf);
        End if;

      update pa_budget_versions
         set request_id = NULL
       where budget_version_id = l_budget_version_id;

      else
        raise exc_wrong_period_set;
      end if;

    end if;

    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
      fnd_file.put_line(1, 'After Copy Actuals');
    End if;

    ELSE -- Bug 8682811
        fnd_file.put_line(1, 'Please create a draft budget of the budget type ' || x_budget_type_code ||' for the project '|| x_project_id);
    END IF; -- Bug 8682811

  exception
    when exc_copy_actual then
    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
      fnd_file.put_line(1, 'Copy actual is not allowed. It is being performed by other program for this project and budget type');
    End if;
      null;
    when exc_wrong_period_set then
    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
      fnd_file.put_line(1, 'Copy actual is not allowed. Start period cannot be greater than the end period');
    End if;
      null;
    when others then
    If p_debug_mode = 'Y' and g_calling_mode = 'CONCURRENT REQUEST' then
      fnd_file.put_line(1, sqlerrm);
    End if;
      null;
  end copy_actuals1;


/*------------------------------------------------------------------------------------------------------------------
Added for performance issue
------------------------------------------------------------------------------------------------------------------*/

end pa_budget_core1 ;

/
