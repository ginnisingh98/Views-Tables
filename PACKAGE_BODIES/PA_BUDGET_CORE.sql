--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_CORE" AS
-- $Header: PAXBUBCB.pls 120.15.12010000.3 2008/12/19 08:04:14 amehrotr ship $

  -- Bug Fix: 4569365. Removed MRC code.
  -- g_mrc_exception EXCEPTION;
  p_pa_debug_mode       Varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  g_module_name varchar2(100) := 'pa_budget_core';

  PROCEDURE PRINT_MSG(P_MSG  VARCHAR2) is
  BEGIN
        --dbms_output.put_line(P_MSG);
        IF P_PA_DEBUG_MODE = 'Y' Then
            pa_debug.g_err_stage := substr('LOG:'||p_msg,1,240);
            PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
        END IF;
        Return;
  END PRINT_MSG;

  procedure shift_periods(x_start_period_date in date,
                          x_periods      in  number,
                          x_period_name  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_period_type  in varchar2,
                          x_start_date   in out NOCOPY date, --File.Sql.39 bug 4440895
                          x_end_date     in out NOCOPY date, --File.Sql.39 bug 4440895
                          x_err_code     in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage    in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack    in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
  cursor c is
  select period_name, start_date , end_date
  from PA_periods
  where   start_date > x_start_period_date
  order by  start_date ;

  cursor c1 is
  select period_name, start_date , end_date
  from PA_periods
  where     start_date < x_start_period_date
  order by  start_date  desc;

cursor c2 is
  select period_name, start_date , end_date
  from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
  where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
  AND P.APPLICATION_ID = pa_period_process_pkg.application_id
  AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
  and   start_date > x_start_period_date
  order by start_date ;


  cursor c3 is
  select period_name, start_date , end_date
  from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
  where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
  AND P.APPLICATION_ID = pa_period_process_pkg.application_id
  AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
  and   start_date < x_start_period_date
  order by start_date  desc;




  old_stack                     varchar2(630);
  number_period   number(10);

  begin
    x_err_code := 0;
    old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->shift_periods';

    if x_periods > 0 then

        IF  NVL(x_period_type ,'X') = 'P' THEN

          select count(*)
          into   number_period
          from pa_periods
          where start_date > x_start_period_date;

        ELSIF  NVL(x_period_type ,'X') = 'G' THEN

          select count(*)
          into   number_period
          from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
          where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
          AND P.APPLICATION_ID = pa_period_process_pkg.application_id
          AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
          AND   start_date > x_start_period_date;
        END IF ;


      if number_period < abs(x_periods) then

          -- x_err_code := 20;  -- Removed error being thrown for Bug 7556248
          -- x_err_stage := 'PA_BU_INVALID_NEW_PERIOD';
          return;
      end if;

        IF NVL(x_period_type,'X') = 'P' THEN
          open c;
          for i in 1..abs(x_periods)
          loop
          fetch c into x_period_name, x_start_date, x_end_date;
          exit when c%notfound;
          end loop;
          close c;
        ELSIF NVL(x_period_type,'X') = 'G' THEN
          open c2;
          for i in 1..abs(x_periods)
          loop
          fetch c2 into x_period_name, x_start_date, x_end_date;
          exit when c2%notfound;
          end loop;
          close c2;
        END IF;

    elsif x_periods < 0 then

        IF  NVL(x_period_type ,'X') = 'P' THEN

          select count(*)
          into   number_period
          from pa_periods
          where   start_date < x_start_period_date;
        ELSIF  NVL(x_period_type ,'X') = 'G' THEN
          select count(*)
          into   number_period
          from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
          where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
          AND P.APPLICATION_ID = pa_period_process_pkg.application_id
          AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
          AND start_date < x_start_period_date;
        END IF ;

      if number_period < abs(x_periods) then

          -- x_err_code := 20;  -- Removed error being thrown for Bug 7556248
          -- x_err_stage := 'PA_BU_INVALID_NEW_PERIOD';
          return;
      end if;

        IF NVL(x_period_type,'X') = 'P' THEN
          open c1;
          for i in 1..abs(x_periods)
          loop
          fetch c1 into x_period_name, x_start_date, x_end_date;
          exit when c1%notfound;
          end loop;
          close c1;
        ELSIF  NVL(x_period_type ,'X') = 'G' THEN
          open c3;
          for i in 1..abs(x_periods)
          loop
          fetch c3 into x_period_name, x_start_date, x_end_date;
          exit when c3%notfound;
          end loop;
          close c3;
        END IF;

    end if;

    x_err_stack := old_stack;

 exception
   when NO_DATA_FOUND then
      x_err_code := 20;
      x_err_stage := 'PA_BU_INVALID_NEW_PERIOD';
      return;
   when others then
      x_err_code := SQLCODE;
      return;
 end;

 procedure get_periods(x_start_date1 in date,
                       x_start_date2 in date,
                       x_period_type  in varchar2,
                       x_periods   in out  NOCOPY number, --File.Sql.39 bug 4440895
                       x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                       x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                       x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
 is
 x_period_start_date1 date;
 x_period_start_date2 date;
 cursor c is
 select count(1) -1
 from pa_periods
 where  start_date between least(x_period_start_date1,x_period_start_date2) and greatest(x_period_start_date1,x_period_start_date2);

 cursor c1 is
 select count(1) -1
 from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
 where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
 AND P.APPLICATION_ID = pa_period_process_pkg.application_id
 AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
 and   start_date between least(x_period_start_date1,x_period_start_date2) and greatest(x_period_start_date1,x_period_start_date2);




 old_stack                      varchar2(630);
 begin
   x_err_code := 0;
   old_stack := x_err_stack;
   x_err_stack := x_err_stack || '->get_periods';

    IF  NVL(x_period_type ,'X') = 'P' THEN
       select start_date
       into   x_period_start_date1
       from pa_periods
       where  x_start_date1 between start_date and end_date;
    ELSIF  NVL(x_period_type ,'X') = 'G' THEN
       select start_date
       into   x_period_start_date1
       from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
       where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
       AND P.APPLICATION_ID = pa_period_process_pkg.application_id
       AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
       AND  x_start_date1 between start_date and end_date;

    END IF;


    IF  NVL(x_period_type ,'X') = 'P' THEN

       select start_date
       into   x_period_start_date2
       from pa_periods
       where  x_start_date2 between start_date and end_date;

    ELSIF  NVL(x_period_type ,'X') = 'G' THEN


       select start_date
       into   x_period_start_date2
       from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
       where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
       AND P.APPLICATION_ID = pa_period_process_pkg.application_id
       AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
       AND  x_start_date2 between start_date and end_date;

    END IF;



    IF NVL(x_period_type ,'X') = 'P' THEN

       open c;
       fetch c into x_periods;
       close c;
    ELSIF NVL(x_period_type ,'X') = 'G' THEN
       open c1;
       fetch c1 into x_periods;
       close c1;
    END IF;


   if x_start_date1 > x_start_date2 then
     x_periods := -1* x_periods;
   end if;

   x_err_stack := old_stack;
 exception
   when NO_DATA_FOUND then
      x_err_code := 20;
      x_err_stage := 'PA_BU_INVALID_NEW_PERIOD';
      return;
   when others then
      x_err_code := SQLCODE;
      return;
 end;

-- ===================================================
--
-- History
--
--      12-AUG-97       jwhite  Updated to latest specifications the baseline
--                              procedure for workflow implementation.
--
--      10-SEP-97       Rkrishna Added default value for x_verify_budget_rules
--                               in baseline procedure
--
--      10-SEP-97       jwhite  As per latest specs, supplemented modifications
--                              made by chk for call to Verify_Budget_Rules
--                              (added two new OUT-parameters, changed
--                               error handling code); added new code
--                              for update_funding calls.
--
--      12-AUG-02       jwhite  For the new FP model, made minor modifications
--                              so the package would compile and new FP queries
--                              would fire successfully. Otherwise, this procedure
--                              does NOT support the FP Model.
--
--                              Modifications:
--                              1) Modified pa_budget_versions-INSERT to populate the
--                                 new FP approved_cost/rev_plan_type columns.
--
-- NOTE:
--
--           !!! This Baseline Procedure does NOT support the FP Model !!!
--
--               This procedure only creates r11.5.7 budgets. You cannot use
--               this procedure to create FP plans.
--
--

  procedure baseline (x_draft_version_id  in     number,
                      x_mark_as_original  in     varchar2,
                      x_verify_budget_rules in   varchar2 default 'Y',
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895

  IS
    -- Standard who
    x_created_by                number(15);
    x_last_update_login         number(15);

    x_project_id                number(15);
    x_budget_type_code          varchar2(30);
    max_version                 number(15);
    x_dest_version_id           number(15);
    x_entry_level_code          varchar2(30);
    x_project_type_class_code   varchar2(30);
    dummy                       number;
    budget_total                number default 0;
    old_stack                   varchar2(630);
    x_resource_list_assgmt_id   number;
    x_resource_list_id          number;
    x_baselined_version_id      number;
    x_funding_level             varchar2(2) default NULL;
    x_time_phased_type_code     varchar2(30);

    l_warnings_only_flag        VARCHAR2(1)     := 'Y';
    l_err_msg_count     NUMBER  := 0;
    v_project_start_date        date;
    v_project_completion_date   date;
    v_emp_id                    number;
    v_baselined_by_person_id    number;
    l_workflow_is_used          VARCHAR2(1);
    x_pm_product_code           VARCHAR2(100);

    x_msg_count          NUMBER := 0;
    x_msg_data           VARCHAR2(2000);
    x_return_status      VARCHAR2(2000);

BEGIN

	print_msg('PA_BUDGET_CORE.BASELINE- Inside');

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->baseline';

     x_created_by := FND_GLOBAL.USER_ID;
    --x_created_by := ( to_number(fnd_profile.value('USER_ID')));
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

-- This call is repeated in  PA_BUDGET_UTILS.Verify_Budget_Rules
-- as the APIs call that procedure. Using v_emp_id eliminates join
-- to fnd_user while inserting record in pa_budget_versions

     v_emp_id := PA_UTILS.GetEmpIdFromUser(x_created_by );

     if v_emp_id IS NULL then
        x_err_code := 10;
        x_err_stage := 'PA_ALL_WARN_NO_EMPL_REC';
        return;
     end if;


     savepoint before_baseline;

     x_err_stage := 'get draft budget info <' || to_char(x_draft_version_id)
                    || '>';
	print_msg(x_err_stage);

/* Modified the following query for the bug 6320792 */
    select v.project_id, v.budget_type_code, v.resource_list_id,
            t.project_type_class_code,time_phased_type_code,
            entry_level_code,v.pm_product_code
     into   x_project_id, x_budget_type_code, x_resource_list_id,
            x_project_type_class_code,x_time_phased_type_code,
            x_entry_level_code, x_pm_product_code
     from   pa_project_types_all t,
            pa_projects_all p,
            pa_budget_versions v,
            pa_budget_entry_methods b
     where  v.budget_version_id = x_draft_version_id
     and    v.project_id = p.project_id
     and    b.budget_entry_method_code = v.budget_entry_method_code
     and    p.project_type = t.project_type
     and    nvl(p.org_id, -99) = nvl(t.org_id, -99);


/***** Code added for bug 2162949 */
     --Check whether workflow is being used for this project budget
        x_err_stage := 'Calling PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used';
        print_msg(x_err_stage);
     PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used
                ( p_draft_version_id            =>      x_draft_version_id
                , p_project_id                  =>      x_project_id
                , p_budget_type_code            =>      x_budget_type_code
                , p_pm_product_code             =>      x_pm_product_code
                , p_result                      =>      l_workflow_is_used
                , p_err_code                    =>      x_err_code
                , p_err_stage                   =>      x_err_stage
                , p_err_stack                   =>      x_err_stack
                );
	print_msg('End of Budget_Wf_Is_Used:['||l_workflow_is_used||']');

     If l_workflow_is_used =  'T' Then
        v_emp_id := pa_utils.GetEmpIdFromUser(pa_budget_wf.g_baselined_by_user_id);
    end if;

/*Code fix ends for bug 2162949 */
-- -------------------------------------------------------------------------------------
-- During R11 development, this section was
-- rewritten to call verify_budget_rules, etc.
--
-- Need to check if call is for verification purpose only
-- (chk 09/04/97)
--

     IF ( x_verify_budget_rules = 'Y' )
     THEN
	x_err_stage := 'Calling PA_BUDGET_UTILS.Verify_Budget_Rules';
        print_msg(x_err_stage);
       PA_BUDGET_UTILS.Verify_Budget_Rules
         (p_draft_version_id            =>      x_draft_version_id
        , p_mark_as_original    =>      x_mark_as_original
        , p_event                       =>      'BASELINE'
        , p_project_id          =>      x_project_id
        , p_budget_type_code    =>      x_budget_type_code
        , p_resource_list_id            =>      x_resource_list_id
        , p_project_type_class_code     =>      x_project_type_class_code
        , p_created_by          =>      x_created_by
        , p_calling_module              =>      'PAXBUBCB'
        , p_warnings_only_flag  =>      l_warnings_only_flag
        , p_err_msg_count               =>      l_err_msg_count
        , p_err_code                    =>      x_err_code
        , p_err_stage           =>      x_err_stage
        , p_err_stack           =>      x_err_stack
          );
	 print_msg('end of Verify_Budget_Rules :errCode['||x_err_code||']ErrStage['||x_err_stage||']');

         IF (l_err_msg_count > 0 )
         THEN
        IF (l_warnings_only_flag = 'N') THEN
                RETURN;
        END IF;
         END IF;
    END IF;  -- x_verify_budget_rules = 'Y'


       -- Updates for Selected Revenue and Cost Budgets

    IF (    (x_budget_type_code = 'AR')
         AND (x_project_type_class_code = 'CONTRACT'))
     THEN

        -- call pa_billing_core.update_funding to update funding tables if
        -- necessary.
        -- check project funding level flag properly
	x_err_stage := 'Calling pa_billing_core.check_funding_level for AR budget';
        print_msg(x_err_stage);
        pa_billing_core.check_funding_level(
                            x_project_id,
                            x_funding_level,
                            x_err_code,
                            x_err_stage,
                            x_err_stack);
	print_msg('End of check_funding_level:errCode['||x_err_code||']ErrStage['||x_err_stage||']');
        if (x_err_code <> 0) then
           return;
        end if;

	x_err_stage := 'Calling pa_billing_core.update_funding';
        print_msg(x_err_stage);
        pa_billing_core.update_funding(
                x_project_id,
                x_funding_level,        -- Funding level
                x_err_code,
                x_err_stage,
                x_err_stack);
	print_msg('End of update_funding:errCode['||x_err_code||']ErrStage['||x_err_stage||']');
                if (x_err_code <> 0) then
                rollback to before_baseline;
                        RETURN;
                end if;

           ELSIF (    (x_budget_type_code = 'AC')
           AND (x_project_type_class_code <> 'CONTRACT'))
            THEN

        -- call pa_billing_core.update_funding to update funding tables if
        -- necessary.
	x_err_stage := 'Calling pa_billing_core.update_funding for AC budget';
        print_msg(x_err_stage);
        pa_billing_core.update_funding(
                x_project_id,
                x_funding_level,        -- Funding level
                x_err_code,
                x_err_stage,
                        x_err_stack);
	print_msg('End of update_funding:errCode['||x_err_code||']ErrStage['||x_err_stage||']');

         if ( x_err_code <> 0) then
                rollback to before_baseline;
                        return;
                end if;

    END IF;  -- of AR revenue budget

-- End R11 rewrite
-- ----------------------------------------------------------------------------------


    	x_err_stage := 'Calling pa_budget_utils.get_baselined_version_id';
        print_msg(x_err_stage);
      pa_budget_utils.get_baselined_version_id(
                                  x_project_id        => x_project_id,
                                  x_budget_type_code  => x_budget_type_code,
                                  x_budget_version_id => x_baselined_version_id,
                                  x_err_code          => x_err_code,
                                  x_err_stage         => x_err_stage,
                                  x_err_stack         => x_err_stack
                                  );
	print_msg('End of get_baselined_version_id:errCode['||x_err_code||']ErrStage['||x_err_stage||']');


     if (x_err_code < 0) then
         rollback to before_baseline;
         return;

     elsif (x_err_code > 0) then

        -- baseline budget does not exist

        x_err_stage := 'create resource list assignment <'
                       || to_char(x_project_id) || '><'
                       || to_char(x_resource_list_id) || '>';
	print_msg(x_err_stage);

        -- create resource list assignment if necessary
        pa_res_list_assignments.create_rl_assgmt(x_project_id,
                         x_resource_list_id,
                         x_resource_list_assgmt_id,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);
	print_msg('End of create_rl_assgmt:errCode['||x_err_code||']ErrStage['||x_err_stage||']');

        -- if oracle or application error, return
        if (x_err_code <> 0) then
        rollback    to before_baseline;
           return;
        end if;

        x_err_stage := 'create resource list usage <'
                       || to_char(x_project_id) || '><'
                       || to_char(x_resource_list_assgmt_id) || '><'
                       || x_budget_type_code || '>';
	print_msg(x_err_stage);

        -- create resource list usage if necessary
        pa_res_list_assignments.create_rl_uses(x_project_id,
                         x_resource_list_assgmt_id,
                         x_budget_type_code,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);
	print_msg('End of create_rl_uses:errCode['||x_err_code||']ErrStage['||x_err_stage||']');

        -- if oracle or application error, return.

        if (x_err_code <> 0) then
        rollback    to before_baseline;
           return;
        end if;

     end if;

     x_err_stage := 'update current version <' || to_char(x_project_id) || '><'
                    || x_budget_type_code || '>';
	print_msg(x_err_stage);

     if (x_mark_as_original = 'Y') then

          -- reset current budget version to non-current
          update pa_budget_versions
          set    original_flag = 'Y',
                 current_original_flag = 'N',
                 last_update_date = SYSDATE,
                 last_updated_by = x_created_by,
                 last_update_login = x_last_update_login
          where  project_id = x_project_id
          and    budget_type_code = x_budget_type_code
          and    current_original_flag = 'Y';

     end if;

     update pa_budget_versions
     set    current_flag = 'N',
            last_update_date = SYSDATE,
            last_updated_by = x_created_by,
            last_update_login = x_last_update_login
     where  project_id = x_project_id
     and    budget_type_code = x_budget_type_code
     and    current_flag = 'Y';


     -- get the maximun number of existing versions
     x_err_stage := 'get maximum baseline number <' || to_char(x_project_id)
                    || '><' || x_budget_type_code || '>';
	print_msg(x_err_stage);

     select nvl(max(version_number), 0)
     into   max_version
     from   pa_budget_versions
     where  project_id = x_project_id
     and    budget_type_code = x_budget_type_code
     and    budget_status_code = 'B';

     -- get the dest version id
     select pa_budget_versions_s.nextval
     into   x_dest_version_id
     from   sys.dual;

     -- populate pa_budget_versions
     x_err_stage := 'create baselined version <' || to_char(x_dest_version_id)
                    || '><' || to_char(max_version)
                    || '><' || to_char(x_created_by) || '>';
	print_msg(x_err_stage);

     insert into pa_budget_versions(
            budget_version_id,
            project_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
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
            first_budget_period,
            pm_product_code,
            pm_budget_reference,
            wf_status_code,
            approved_cost_plan_type_flag,
            approved_rev_plan_type_flag
        )
         select
            x_dest_version_id,
            v.project_id,
            v.budget_type_code,
            max_version + 1,
            'B',
            SYSDATE,
            x_created_by,
            SYSDATE,
            x_created_by,
            x_last_update_login,
            'Y',
            'N',
            x_mark_as_original,
            'N',
            v.resource_list_id,
            v.version_name,
            v.budget_entry_method_code,
            v_emp_id,
            SYSDATE,
            v.change_reason_code,
            (v.labor_quantity),
            v.labor_unit_of_measure,
--          pa_currency.round_currency_amt(v.raw_cost),
--          pa_currency.round_currency_amt(v.burdened_cost),
--          pa_currency.round_currency_amt(v.revenue),
            v.raw_cost,
            v.burdened_cost,
            v.revenue,
            v.description,
            v.attribute_category,
            v.attribute1,
            v.attribute2,
            v.attribute3,
            v.attribute4,
            v.attribute5,
            v.attribute6,
            v.attribute7,
            v.attribute8,
            v.attribute9,
            v.attribute10,
            v.attribute11,
            v.attribute12,
            v.attribute13,
            v.attribute14,
            v.attribute15,
            first_budget_period,
            pm_product_code,
            pm_budget_reference,
            NULL,
            decode(v.budget_type_code,'AC','Y','N'),
            decode(v.budget_type_code,'AR','Y','N')
         from   pa_budget_versions v
         where  budget_version_id = x_draft_version_id;

     x_err_stage := 'create budget lines <' || to_char(x_draft_version_id)
                    || '><' || to_char(x_dest_version_id)
                    || '>';
	print_msg(x_err_stage);

/* FPB2: MRC - sep 2002

   Fix 876456 copy_lines is a generic procedure that copies budget lines
   and resource assignments from a source project's budget to a destination
   project's budget
   This procedure has been replaced with a procedure copy_draft_lines defined
   in pa_budget_core1 which copies budget lines and resource assignments  from
   the draft budget of a project to the baselined version of the same project

     pa_budget_core.copy_lines(x_draft_version_id,
                               1,
                               5,
                               0,
                               x_dest_version_id,
                               x_err_code,
                               x_err_stage,
                               x_err_stack,
                               'Y');
*/

	x_err_stage:= 'Calling pa_budget_core1.copy_draft_lines';
        print_msg(x_err_stage);
     pa_budget_core1.copy_draft_lines(x_src_version_id        => x_draft_version_id,
                                      x_time_phased_type_code => x_time_phased_type_code,
                                      x_entry_level_code      => x_entry_level_code,
                                      x_dest_version_id       => x_dest_version_id,
                                      x_err_code              => x_err_code,
                                      x_err_stage             => x_err_stage,
                                      x_err_stack             => x_err_stack,
                                      x_pm_flag               => 'Y');
	print_msg('End of copy_draft_lines:errCode['||x_err_code||']ErrStage['||x_err_stage||']');


     if (x_err_code <> 0) then
        rollback to before_baseline;
        return;
     end if;

    -- Fix for Bug #561420 - If the effective dates on Project/Tasks
    -- has changed for Non Time phased budgets, then update the
    -- start and end dates on the budget lines.

   -- gp_msg('TIME:'||x_time_phased_type_code||':ENTRY:'||x_entry_level_code);
    if (x_time_phased_type_code = 'N')
       and (x_entry_level_code = 'P') then -- Project Level
--
	x_err_stage:= 'Non-Time Phase: Project Level update';
        print_msg(x_err_stage);
      select start_date,completion_date
      into v_project_start_date,
           v_project_completion_date
      from pa_projects_all
      where project_id = x_project_id;

      if (v_project_start_date is null ) or (v_project_completion_date
          is null) then
          x_err_code := 20;
          x_err_stage :='PA_BU_NO_PROJ_END_DATE';
         return;
      end if;

      update pa_budget_lines
      set start_date= v_project_start_date,
          end_date = v_project_completion_date
      where resource_assignment_id in
          (select resource_assignment_id
           from pa_resource_assignments
           where budget_version_id = x_dest_version_id)
      and ((start_date <> v_project_start_date) OR (end_date <> v_project_completion_date));

-- fix 876456: Added check that rows should be updated only if the project start or end
-- dates are different from the budget start and end dates

    elsif (x_time_phased_type_code = 'N') then -- Task Level
	x_err_stage:= 'Non-Time Phase: Task Level update';
        print_msg(x_err_stage);
      select start_date,completion_date
      into v_project_start_date,
           v_project_completion_date
      from pa_projects_all
      where project_id = x_project_id;

      for bl_rec in (select start_date,
                            completion_date ,
                            resource_assignment_id
                     from pa_tasks t ,pa_resource_assignments r
                     where t.task_id = r.task_id
                     and  r.budget_version_id = x_dest_version_id) loop
          bl_rec.start_date := nvl(bl_rec.start_date,v_project_start_date);
          bl_rec.completion_date := nvl(bl_rec.completion_date
                                       ,v_project_completion_date);

-- fix 876456: Added check that rows should be updated only if the task start or end
-- dates are different from the budget start and end dates

          IF (bl_rec.start_date is null) or (bl_rec.completion_date is null)
            THEN
            x_err_code := 20;
            x_err_stage :='PA_BU_NO_TASK_PROJ_DATE';
            exit;
          ELSE
             UPDATE pa_budget_lines
               SET start_date = bl_rec.start_date,
                   end_date   = bl_rec.completion_date
             WHERE resource_assignment_id = bl_rec.resource_assignment_id
               AND ((start_date <> bl_rec.start_date) or (end_date <> bl_rec.completion_date));

          END IF;

      end loop;

      if x_err_code <> 0 then
        return;
      end if;

--
    end if;

      /* Bug fix:5246812: When this API raises unexpected error, the baseline process
        * shows ORA-01400: cannot insert NULL into (PA."PA_WF_PROCESSES.ENTITY_KEY2)
        * error. so execute this api in a begin , end block and set the error status
        */
        BEGIN
                -- Copy attachments for every draft budget copied
                x_err_stage:= 'Calling fnd_attached_documents2_pkg.copy_attachments';
                print_msg(x_err_stage);
                fnd_attached_documents2_pkg.copy_attachments('PA_BUDGET_VERSIONS',
                                                   x_draft_version_id,
                                                   null,null,null,null,
                                                   'PA_BUDGET_VERSIONS',
                                                   x_dest_version_id,
                                                   null,null,null,null,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.LOGIN_ID,
                                                   275, null, null) ;
                print_msg('End of copy_attachments');
                -- End copying attachments
        EXCEPTION
                WHEN OTHERS THEN
                        print_msg('Errored in fnd_attached_documents2_pkg: ERRMSG:['||sqlcode||sqlerrm);
                        x_err_code := SQLCODE;
                        x_err_stack := substr(SQLERRM,630);
                        rollback to before_baseline;
                        RETURN;
                        NULL;
        END;

      	x_err_stage:= 'Calling PA_BUDGET_UTILS.summerize_project_totals';
        print_msg(x_err_stage);
     	PA_BUDGET_UTILS.summerize_project_totals(x_dest_version_id,
                                             x_err_code,
                                             x_err_stage,
                                             x_err_stack);
	print_msg('End of summerize_project_totals:errCode['||x_err_code||']ErrStage['||x_err_stage||']');

     if (x_err_code <> 0) then
        rollback to before_baseline;
        return;
     end if;

     x_err_stack := old_stack;
	x_err_stage:= 'End of baseline';
        print_msg(x_err_stage);

  exception
      when others then
	print_msg('ErrStage:'||x_err_stage||']ErrCode['||SQLCODE||']');
         x_err_code := SQLCODE;
         rollback to before_baseline;
         return;
  end baseline;

-----------------------------------------------------------------------------
-- History
-- 26-Dec-2006 kchaitan created
-- Following api will copy a non integrated budget version to destination
-- gl integrated budget without overriding the closed gl period budget lines
-- in destination and without copying the closed gl period budget lines in
-- source.
-----------------------------------------------------------------------------

procedure copy_without_delete (p_src_version_id      in     number,
                               p_amount_change_pct   in     number,
                               p_rounding_precision  in     number,
                               p_dest_project_id     in     number,
                               p_dest_budget_type_code    in     varchar2,
                               x_err_code            in out NOCOPY number,   -- added NOCOPY to pass GSCC errors for bug 5838587
                               x_err_stage           in out NOCOPY varchar2, -- added NOCOPY to pass GSCC errors for bug 5838587
                               x_err_stack           in out NOCOPY varchar2) -- added NOCOPY to pass GSCC errors for bug 5838587
  is
     old_stack varchar2(630);

     l_created_by  number;
     l_last_update_login number;

     l_dest_version_id number;
     l_baselined_version_id number;
     l_baselined_resource_list_id number;

     l_src_resource_list_id number;
     l_dest_resource_list_id number;
     l_draft_exists boolean;
     l_cls_prds_exists varchar2(1);
     l_src_time_phased_type_code varchar2(30);
     l_dest_time_phased_type_code varchar2(30);
     l_src_entry_level_code varchar2(30);
     l_dest_entry_level_code varchar2(30);

     l_version_is_baselined varchar2(1);

     x_return_status      VARCHAR2(2000);
     x_msg_count          NUMBER        := 0;
     x_msg_data           VARCHAR2(2000);

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_without_delete';

     l_created_by := FND_GLOBAL.USER_ID;
     l_last_update_login := FND_GLOBAL.LOGIN_ID;

     savepoint before_copy1;


     x_err_stage := 'Getting Budget Entry Method Parameters for Source <'||  to_char(p_src_version_id);
     select m.time_phased_type_code,
            m.entry_level_code,
            v.resource_list_id
     into   l_src_time_phased_type_code,
            l_src_entry_level_code,
            l_src_resource_list_id
     from   pa_budget_entry_methods m,
            pa_budget_versions v
     where  v.budget_version_id = p_src_version_id
     and    v.budget_entry_method_code = m.budget_entry_method_code;

     x_err_stage := 'getting baselined budget <' ||  to_char(p_dest_project_id)
                    || '><' ||  p_dest_budget_type_code || '>' ;

     pa_budget_utils.get_baselined_version_id(
                                  x_project_id        => p_dest_project_id,
                                  x_budget_type_code  => p_dest_budget_type_code,
                                  x_budget_version_id => l_baselined_version_id,
                                  x_err_code          => x_err_code,
                                  x_err_stage         => x_err_stage,
                                  x_err_stack         => x_err_stack
                                  );

     if (x_err_code = 0) then
        -- baseliend budget exists, verify if resource lists are the same
        -- resource list used in accumulation
        select resource_list_id
        into   l_baselined_resource_list_id
        from   pa_budget_versions
        where  budget_version_id = l_baselined_version_id;

        if (l_src_resource_list_id <> l_baselined_resource_list_id) then
            x_err_code := 10;
            x_err_stage := 'PA_BU_BASE_RES_LIST_EXISTS';
            rollback to before_copy1;
            return;
        end if;

        l_version_is_baselined := 'Y';
     elsif (x_err_code < 0) then
        x_err_stage := 'Unexpected error while trying to get baselined budget version id';
        rollback to before_copy1;
        return;
     end if;


     x_err_stage := 'getting old draft budget <' ||  to_char(p_dest_project_id)
                    || '><' ||  p_dest_budget_type_code || '>' ;

     -- check if destination draft budget exists
     pa_budget_utils.get_draft_version_id(
                                  x_project_id        => p_dest_project_id,
                                  x_budget_type_code  => p_dest_budget_type_code,
                                  x_budget_version_id => l_dest_version_id,
                                  x_err_code          => x_err_code,
                                  x_err_stage         => x_err_stage,
                                  x_err_stack         => x_err_stack
                                  );


     if (x_err_code = 0) then
        -- draft budget exists, update it
         x_err_stage := 'draft budget exists <' ||  to_char(l_dest_version_id)||'>';
        l_draft_exists := TRUE;
     elsif (x_err_code < 0) then
        x_err_stage := 'Unexpected error while trying to get draft budget version id';
        rollback to before_copy1;
        return;
     else
        --insert into pa_budget_versions
        select pa_budget_versions_s.nextval
        into   l_dest_version_id
        from   sys.dual;

        insert into pa_budget_versions(
            budget_version_id,
            project_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
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
            first_budget_period,
            wf_status_code,
            approved_cost_plan_type_flag,
            approved_rev_plan_type_flag
                )
         select
            l_dest_version_id,
            p_dest_project_id,
            p_dest_budget_type_code,
            1,
            'W',
            SYSDATE,
            l_created_by,
            SYSDATE,
            l_created_by,
            l_last_update_login,
            'N',
            'N',
            'N',
            'N',
            v.resource_list_id,
            v.version_name,
            v.budget_entry_method_code,
            NULL,
            NULL,
            v.change_reason_code,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            v.description,
            v.attribute_category,
            v.attribute1,
            v.attribute2,
            v.attribute3,
            v.attribute4,
            v.attribute5,
            v.attribute6,
            v.attribute7,
            v.attribute8,
            v.attribute9,
            v.attribute10,
            v.attribute11,
            v.attribute12,
            v.attribute13,
            v.attribute14,
            v.attribute15,
            v.first_budget_period,
            NULL,
            decode(p_dest_budget_type_code,'AC','Y','N'), /* Bug 5076424 */
            decode(p_dest_budget_type_code,'AR','Y','N')  /* Bug 5076424 */
         from   pa_budget_versions v
         where  v.budget_version_id = p_src_version_id;

         l_draft_exists := FALSE;
         x_err_stage := 'Created new draft version '||to_char(p_src_version_id);
     end if;

     if l_draft_exists then

            begin
                l_cls_prds_exists := 'N';
                SELECT 'Y' into l_cls_prds_exists
                FROM   pa_budget_lines l
                , gl_period_statuses s
                , pa_implementations i
                , pa_budget_versions v
                where s.application_id = pa_period_process_pkg.application_id
                and   i.set_of_books_id = s.set_of_books_id
                and   l.budget_version_id=v.budget_version_id
                and   s.closing_status in ('C','P')
                and   l.period_name = s.period_name
                and   v.budget_version_id = l_dest_version_id
                and   rownum < 2;
            exception when no_data_found then
                l_cls_prds_exists := 'N';
            end;

            if l_cls_prds_exists = 'Y' then
                 x_err_stage := 'Budget lines in closed periods exists. About to perform validations';
                 select m.time_phased_type_code,
                        m.entry_level_code,
                        v.resource_list_id
                 into   l_dest_time_phased_type_code,
                        l_dest_entry_level_code,
                        l_dest_resource_list_id
                 from   pa_budget_entry_methods m,
                        pa_budget_versions v
                 where  v.budget_version_id = l_dest_version_id
                 and    v.budget_entry_method_code = m.budget_entry_method_code;

                 if (l_src_resource_list_id <> l_dest_resource_list_id)
                    or (l_src_entry_level_code <> l_dest_entry_level_code)
                    or (l_src_time_phased_type_code <> l_dest_time_phased_type_code) then
                     x_err_code := 20;
                     x_err_stage := 'PA_BUDG_PARAM_MISMATCH';
                     --x_err_stage := 'Mismatch in entry level or resource list or time phase';
                     rollback to before_copy1;
                     return;
                 end if;
            end if;
     end if;

     if l_draft_exists then
        x_err_stage := 'Updating the existing budget version';
        update pa_budget_versions
        set (version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
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
            first_budget_period,
            wf_status_code,
            approved_cost_plan_type_flag,
            approved_rev_plan_type_flag
             )=(
                select
                    1,
                    'W',
                    SYSDATE,
                    l_created_by,
                    l_last_update_login,
                    'N',
                    'N',
                    'N',
                    'N',
                    v.resource_list_id,
                    v.version_name,
                    v.budget_entry_method_code,
                    NULL,
                    NULL,
                    v.change_reason_code,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    v.description,
                    v.attribute_category,
                    v.attribute1,
                    v.attribute2,
                    v.attribute3,
                    v.attribute4,
                    v.attribute5,
                    v.attribute6,
                    v.attribute7,
                    v.attribute8,
                    v.attribute9,
                    v.attribute10,
                    v.attribute11,
                    v.attribute12,
                    v.attribute13,
                    v.attribute14,
                    v.attribute15,
                    v.first_budget_period,
                    NULL,
                    decode(p_dest_budget_type_code,'AC','Y','N'),
                    decode(p_dest_budget_type_code,'AR','Y','N')
                from   pa_budget_versions v
                where  v.budget_version_id = p_src_version_id
             )
        where budget_version_id = l_dest_version_id;

        fnd_attached_documents2_pkg.delete_attachments('PA_BUDGET_VERSIONS',
                                                     l_dest_version_id,
                                                     null, null, null, null,
                                                     'Y') ;
        end if;

     --copy resource assignments
    if l_draft_exists then
         x_err_stage := 'About to delete budget lines in closed gl periods in dest';
         delete from pa_budget_lines
         where budget_version_id=l_dest_version_id
         and period_name not in (select s.period_name
                             from gl_period_statuses s
                                , pa_implementations i
                             where s.application_id = pa_period_process_pkg.application_id
                             and   i.set_of_books_id = s.set_of_books_id
                             and   s.closing_status in ('C','P'));
    end if;

    x_err_stage := 'About to create new resource assignments in dest';
    INSERT INTO pa_resource_assignments
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
           SELECT  pa_resource_assignments_s.nextval,
                   l_dest_version_id,
                   sa.project_id,
                   sa.task_id,
                   sa.resource_list_member_id,
                   SYSDATE,
                   l_created_by,
                   SYSDATE,
                   l_created_by,
                   l_last_update_login,
                   sa.unit_of_measure,
                   sa.track_as_labor_flag,
                   -1,
                   sa.RESOURCE_ASSIGNMENT_TYPE
            FROM
                   pa_resource_assignments sa,
                   pa_resource_assignments da
           WHERE   sa.budget_version_id = p_src_version_id
           AND     da.budget_version_id(+) = l_dest_version_id
           AND sa.project_assignment_id=-1
           AND da.project_assignment_id(+)=-1
           AND sa.project_id=p_dest_project_id
           AND da.project_id(+)=p_dest_project_id
           AND sa.task_id=da.task_id(+)
           AND sa.resource_list_member_id=da.resource_list_member_id(+)
           AND da.resource_assignment_id IS NULL;
     x_err_stage := 'About to insert budget lines to dest';
     INSERT INTO pa_budget_lines
             (budget_line_id,
              budget_version_id,
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
              projfunc_currency_code,
              project_currency_code,
              txn_currency_code
              )
           select
                 pa_budget_lines_s.nextval,
                 l_dest_version_id,
                 dra.resource_assignment_id,
                 pbl.start_date,
                 sysdate,
                 l_created_by,
                 sysdate,
                 l_created_by,
                 l_last_update_login,
                 pbl.end_date,
                 pbl.period_name,
                 pbl.quantity,
                 round(pbl.raw_cost * p_amount_change_pct, p_rounding_precision),
                 round(pbl.burdened_cost * p_amount_change_pct, p_rounding_precision),
                 round(pbl.revenue * p_amount_change_pct, p_rounding_precision),
                 pbl.change_reason_code,
                 pbl.description,
                 pbl.attribute_category,
                 pbl.attribute1,
                 pbl.attribute2,
                 pbl.attribute3,
                 pbl.attribute4,
                 pbl.attribute5,
                 pbl.attribute6,
                 pbl.attribute7,
                 pbl.attribute8,
                 pbl.attribute9,
                 pbl.attribute10,
                 pbl.attribute11,
                 pbl.attribute12,
                 pbl.attribute13,
                 pbl.attribute14,
                 pbl.attribute15,
                 pbl.pm_product_code,
                 pbl.pm_budget_line_reference,
                 'B',
                 'B',
                 'B',
                 'B',
                 pbl.projfunc_currency_code,
                 pbl.project_currency_code,
                 pbl.txn_currency_code
           from pa_budget_lines pbl,
                pa_resource_assignments sra,
                pa_resource_assignments dra
           where dra.budget_version_id = l_dest_version_id
           and   sra.budget_version_id = p_src_version_id
           and pbl.budget_version_id = p_src_version_id
           and sra.resource_assignment_id=pbl.resource_assignment_id
           and sra.resource_list_member_id=dra.resource_list_member_id
           and sra.task_id=dra.task_id
           and pbl.period_name not in (select s.period_name
                                        from gl_period_statuses s
                                      , pa_implementations_all i
                                        where s.application_id = pa_period_process_pkg.application_id
                                        and   i.set_of_books_id = s.set_of_books_id
                                        and   s.closing_status in ('C','P'));
           x_err_stage := 'About to delete unused resource assignments from dest';
           delete from pa_resource_assignments
           where budget_version_id = l_dest_version_id
           and resource_assignment_id not in
                (select distinct resource_assignment_id
                 from pa_budget_lines
                 where budget_version_id = l_dest_version_id);
    x_err_stage := 'About to begin mrc processing';

-- Commented below  MRC code for Bug  5838587
   /*
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
                  PA_MRC_FINPLAN.COPY_MC_BUDGET_LINES
                                   (p_source_fin_plan_version_id => p_src_version_id,
                                    p_target_fin_plan_version_id => l_dest_version_id,
                                    x_return_status              => x_return_status,
                                    x_msg_count                  => x_msg_count,
                                    x_msg_data                   => x_msg_data);
               ELSIF  (PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'B' AND l_version_is_baselined = 'Y') THEN
                    PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                               (p_fin_plan_version_id => l_dest_version_id, -- Target version should be passed
                                p_entire_version      => 'Y',
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
               -- Bug 2676494
              END IF;

            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE g_mrc_exception;
            END IF;

         END;
*/
     -- Copy attachments for every draft budget copied

     fnd_attached_documents2_pkg.copy_attachments('PA_BUDGET_VERSIONS',
                                                   p_src_version_id,
                                                   null,null,null,null,
                                                   'PA_BUDGET_VERSIONS',
                                                   l_dest_version_id,
                                                   null,null,null,null,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.LOGIN_ID,
                                                   275, null, null) ;

     -- End copying attachments

     PA_BUDGET_UTILS.summerize_project_totals(l_dest_version_id,
                                             x_err_code,
                                             x_err_stage,
                                             x_err_stack);

     if (x_err_code <> 0) then
        rollback to before_copy1;
        return;
     end if;

     x_err_stack := old_stack;
exception
      when others then
         rollback to before_copy1;
         x_err_code := SQLCODE;
         return;
  end copy_without_delete;

-----------------------------------------------------------------------------
-- History
--
--
--      12-AUG-02       jwhite  For the new FP model, made minor modifications
--                              so the package would compile and new FP queries
--                              would fire successfully. Otherwise, this procedure
--                              does NOT support the FP Model.
--
--                              Modifications:
--                              1) Modified pa_budget_versions-INSERT to populate the
--                                 new FP approved_cost/rev_plan_type columns.
--
-- NOTE:
--
--           !!! This Copy Procedure does NOT support the FP Model !!!
--
--               This procedure only creates r11.5.7 budgets. You cannot use
--               this procedure to create FP plans.
--

  procedure copy (x_src_version_id      in     number,
                  x_amount_change_pct   in     number,
                  x_rounding_precision  in     number,
                  x_shift_days          in     number,
                  x_dest_project_id     in     number,
                  x_dest_budget_type_code    in     varchar2,
                  x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                  x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                  x_err_stack           in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack varchar2(630);
     x_dest_version_id number;
     x_created_by  number;
     x_last_update_login number;
     x_baselined_version_id number;
     x_baselined_resource_list_id number;
     x_src_resource_list_id number;
     x_resource_list_assgmt_id number;
     x_baselined_exists boolean;
     x_first_budget_period   varchar2(30);
     x_time_phased_type_code varchar2(30);
     x_entry_level_code varchar2(30);
     x_fbp_start_date   date;
     x_periods   number;
     x_start_date date;
     x_end_date   date;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     x_err_stage := 'get project start date <'
                    ||  to_char(x_src_version_id) || '>';

     select start_date
     into g_project_start_date
     from pa_projects_all a,pa_budget_versions b /*Modified for 6320792 */
     where b.budget_version_id = x_src_version_id
     and   a.project_id = b.project_id;

     savepoint before_copy;

     x_err_stage := 'get source resource list id <'
                    ||  to_char(x_src_version_id) || '>';

     select resource_list_id,first_budget_period
     into   x_src_resource_list_id, x_first_budget_period
     from   pa_budget_versions
     where  budget_version_id = x_src_version_id;

     x_err_stage := 'get baselined budget <' ||  to_char(x_dest_project_id)
                    || '><' ||  x_dest_budget_type_code || '>' ;



     pa_budget_utils.get_baselined_version_id(
                                  x_project_id        => x_dest_project_id,
                                  x_budget_type_code  => x_dest_budget_type_code,
                                  x_budget_version_id => x_baselined_version_id,
                                  x_err_code          => x_err_code,
                                  x_err_stage         => x_err_stage,
                                  x_err_stack         => x_err_stack
                                  );

     if (x_err_code > 0) then
         x_baselined_exists := FALSE;

     elsif (x_err_code = 0) then
        -- baseliend budget exists, verify if resource lists are the same
        -- resource list used in accumulation

        select resource_list_id
        into   x_baselined_resource_list_id
        from   pa_budget_versions
        where  budget_version_id = x_baselined_version_id;

        if (x_src_resource_list_id <> x_baselined_resource_list_id) then
            x_err_code := 10;
            x_err_stage := 'PA_BU_BASE_RES_LIST_EXISTS';
            rollback to before_copy;
            return;
        end if;

        x_baselined_exists := TRUE;

     else
        -- x_err_code < 0
        rollback to before_copy;
        return;
     end if;

     x_err_stage := 'delete old draft budget <' ||  to_char(x_dest_project_id)
                    || '><' ||  x_dest_budget_type_code || '>' ;

     -- check if destination draft budget exists

     pa_budget_utils.get_draft_version_id(
                                  x_project_id        => x_dest_project_id,
                                  x_budget_type_code  => x_dest_budget_type_code,
                                  x_budget_version_id => x_dest_version_id,
                                  x_err_code          => x_err_code,
                                  x_err_stage         => x_err_stage,
                                  x_err_stack         => x_err_stack
                                  );


     if (x_err_code = 0) then
        -- draft budget exists, delete it
        PA_BUDGET_UTILS.delete_draft(x_dest_version_id,
                                    x_err_code,
                                    x_err_stage,
                                    x_err_stack);
     end if;

     if (x_err_code < 0) then
        rollback to before_copy;
        return;
     end if;

/* Only check at baseline
     if (x_baselined_exists = FALSE) then

        -- create resource list assignment if necessary
        x_err_stage := 'create resource list assignment <'
                       || to_char(x_dest_project_id) || '><'
                       || to_char(x_src_resource_list_id) || '>';

        pa_res_list_assignments.create_rl_assgmt(x_dest_project_id,
                         x_src_resource_list_id,
                         x_resource_list_assgmt_id,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return
        if (x_err_code <> 0) then
              rollback to before_copy;
           return;
        end if;

        x_err_stage := 'create resource list usage <'
                       || to_char(x_dest_project_id) || '><'
                       || to_char(x_resource_list_assgmt_id) || '><'
                       || x_dest_budget_type_code || '>';

        -- create resource list usage if necessary
        pa_res_list_assignments.create_rl_uses(x_dest_project_id,
                         x_resource_list_assgmt_id,
                         x_dest_budget_type_code,
                         x_err_code,
                         x_err_stage,
                         x_err_stack);

        -- if oracle or application error, return.

        if (x_err_code <> 0) then
           rollback to before_copy;
           return;
        end if;

     end if;
*/



    x_err_stage := 'Getting Budget Entry Method Parameters <'||  to_char(x_src_version_id);
    select m.time_phased_type_code,
           m.entry_level_code
    into   x_time_phased_type_code,
           x_entry_level_code
    from   pa_budget_entry_methods m,
           pa_budget_versions v
    where  v.budget_version_id = x_src_version_id
    and    v.budget_entry_method_code = m.budget_entry_method_code;

-- Shifting the First Budget Period
    if ( (nvl(x_shift_days,0) <> 0) and (x_first_budget_period is not null) and (
       x_time_phased_type_code not in ('R','N') )  ) then

        x_err_stage := 'Getting First Budget Period Start Date <'||  to_char(x_src_version_id);

        IF  NVL(x_time_phased_type_code ,'X') = 'P' THEN
          select start_date
          into x_fbp_start_date
          from pa_periods
          where  period_name = x_first_budget_period;
        ELSIF  NVL(x_time_phased_type_code ,'X') = 'G' THEN
          select start_date
          into x_fbp_start_date
          from GL_PERIOD_STATUSES P, PA_IMPLEMENTATIONS I
          where I.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
          AND P.APPLICATION_ID = pa_period_process_pkg.application_id
          AND P.ADJUSTMENT_PERIOD_FLAG = 'N'
          AND  period_name = x_first_budget_period;
        END IF ;


        x_err_stage := 'Getting no of periods by which first budget period needs to be shifted<'||  to_char(x_src_version_id);
        get_periods(nvl(g_project_start_date,x_fbp_start_date),
                  nvl(g_project_start_date, x_fbp_start_date)+ x_shift_days,
                  x_time_phased_type_code  ,
                  x_periods  ,
                  x_err_code ,
                  x_err_stage,
                  x_err_stack );

        if (x_err_code <> 0) then
          rollback to before_copy;
          return;
        end if;



        x_err_stage := 'Shifting first budget period <'||  to_char(x_src_version_id);
        shift_periods(x_fbp_start_date,
                      x_periods ,
                      x_first_budget_period ,
                      x_time_phased_type_code,
                      x_start_date ,
                      x_end_date,
                      x_err_code,
                      x_err_stage ,
                      x_err_stack );

         if (x_err_code <> 0) then
           rollback to before_copy;
           return;
         end if;

      end if;


     x_err_stage := 'create budget version <' ||  to_char(x_dest_project_id)
                    || '><' ||  x_dest_budget_type_code || '>' ;

     select pa_budget_versions_s.nextval
     into   x_dest_version_id
     from   sys.dual;
     insert into pa_budget_versions(
            budget_version_id,
            project_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            revenue,
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
            first_budget_period,
                wf_status_code,
           approved_cost_plan_type_flag,
            approved_rev_plan_type_flag
                )
         select
            x_dest_version_id,
            x_dest_project_id,
            x_dest_budget_type_code,
            1,
            'W',
            SYSDATE,
            x_created_by,
            SYSDATE,
            x_created_by,
            x_last_update_login,
            'N',
            'N',
            'N',
            'N',
            v.resource_list_id,
            v.version_name,
            v.budget_entry_method_code,
            NULL,
            NULL,
            v.change_reason_code,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            v.description,
            v.attribute_category,
            v.attribute1,
            v.attribute2,
            v.attribute3,
            v.attribute4,
            v.attribute5,
            v.attribute6,
            v.attribute7,
            v.attribute8,
            v.attribute9,
            v.attribute10,
            v.attribute11,
            v.attribute12,
            v.attribute13,
            v.attribute14,
            v.attribute15,
            x_first_budget_period,
            NULL,
            decode(x_dest_budget_type_code, 'AC', 'Y', 'N'), --Bug 5081715.
            decode(x_dest_budget_type_code, 'AR', 'Y', 'N')  --Bug 5081715.
         from   pa_budget_versions v
         where  v.budget_version_id = x_src_version_id;

     pa_budget_core.copy_lines(x_src_version_id,
                               x_amount_change_pct,
                               x_rounding_precision,
                               x_shift_days,
                               x_dest_version_id,
                               x_err_code,
                               x_err_stage,
                               x_err_stack);

     if (x_err_code <> 0) then
        rollback to before_copy;
        return;
     end if;

     -- Copy attachments for every draft budget copied

     fnd_attached_documents2_pkg.copy_attachments('PA_BUDGET_VERSIONS',
                                                   x_src_version_id,
                                                   null,null,null,null,
                                                   'PA_BUDGET_VERSIONS',
                                                   x_dest_version_id,
                                                   null,null,null,null,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.LOGIN_ID,
                                                   275, null, null) ;

     -- End copying attachments

     PA_BUDGET_UTILS.summerize_project_totals(x_dest_version_id,
                                             x_err_code,
                                             x_err_stage,
                                             x_err_stack);

     if (x_err_code <> 0) then
        rollback to before_copy;
        return;
     end if;

     x_err_stack := old_stack;

  exception
      when others then
         rollback to before_copy;
         x_err_code := SQLCODE;
         return;
  end copy;

-----------------------------------------------------------------------------

  procedure verify (x_budget_version_id   in     number,
                    x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                    x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                    x_err_stack           in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
  begin
     null;
  exception
      when others then
         x_err_code := SQLCODE;
  end verify;


-----------------------------------------------------------------------------

-- Name:   copy_lines
--
-- History
--         27-JUN-2002  jwhite        Bug 1877119
--                                    For the Copy_Lines procedure, add new column
--                                    for insert into pa_resource_assignments:
--                                    project_assignment_id, default -1.
--
--                                  - MOdified to support the new FP model:
--                                    a. added NVL(a.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED'
--                                       to the budget_line loop.
--                                    b. added three new columns to budget line inserts:
--                                       1.     projfunc_currency_code
--                                       2.     project_currency_code
--                                       3.     txn_currency_code
--
--
--

--         23-feb-2006  prachand      Bug 4914055: Copy Project failing in copy_lines due to performance issues
--                                    Replace the insert statement into pa_budget_lines with a bulk insert.

  procedure copy_lines (x_src_version_id      in     number,
                        x_amount_change_pct   in     number,
                        x_rounding_precision  in     number,
                        x_shift_days          in     number,
                        x_dest_version_id     in     number,
                        x_err_code            in out    NOCOPY number, --File.Sql.39 bug 4440895
                        x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_err_stack           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_pm_flag             in varchar2 default 'N')
  is
    -- Standard who
    x_created_by                 NUMBER(15);
    x_last_update_login          NUMBER(15);

    old_stack  varchar2(630);
    x_start_date date;
    x_end_date date;
    x_period_name varchar2(30);
    amount_change_pct number;
    rounding_precision number;
    x_time_phased_type_code varchar2(30);
    x_entry_level_code varchar2(30);
    x_task_start_date date;
    x_periods   number;

    x_return_status      VARCHAR2(2000);
    x_msg_count          NUMBER        := 0;
    x_msg_data           VARCHAR2(2000);

    l_version_is_baselined VARCHAR2(1);

     -- bug 4914055: added the followings:
     l_budget_line_id_tbl                            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_budget_version_id_tbl                         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_resource_assignment_id_tbl                    SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_start_date_tbl                                SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_last_update_date_tbl                          SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_last_updated_by_tbl                           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_creation_date_tbl                             SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_created_by_tbl                                SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_last_update_login_tbl                         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_end_date_tbl                                  SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
     l_period_name_tbl                               SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_quantity_tbl                                  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_raw_cost_tbl                                  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_burdened_cost_tbl                             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_revenue_tbl                                   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
     l_change_reason_code_tbl                        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_description_tbl                               SYSTEM.pa_varchar2_2000_tbl_type:=SYSTEM.pa_varchar2_2000_tbl_type();
     l_attribute_category_tbl                        SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_attribute1_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute2_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute3_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute4_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute5_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute6_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute7_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute8_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute9_tbl                                SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute10_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute11_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute12_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute13_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute14_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_attribute15_tbl                               SYSTEM.pa_varchar2_150_tbl_type:=SYSTEM.pa_varchar2_150_tbl_type();
     l_pm_product_code_tbl                           SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_pm_budget_line_reference_tbl                  SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
     l_raw_cost_source_tbl                           SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_burdened_cost_source_tbl                      SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_quantity_source_tbl                           SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_revenue_source_tbl                            SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_projfunc_currency_code_tbl                    SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_project_currency_code_tbl                     SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
     l_txn_currency_code_tbl                         SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();


     TYPE period_info_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(60);

     l_period_info_tbl     period_info_tab;

     l_project_id              pa_projects_all.project_id%TYPE;
     l_min_start_date          DATE;

     -- end bug 4914055

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->copy_lines';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     begin
       select 'Y'
       into   l_version_is_baselined
       from   pa_budget_versions
       where  budget_status_code = 'B'
       and    budget_version_id = x_dest_version_id;
     exception
       when no_data_found then
         l_version_is_baselined := 'N';
     end;

     if (x_amount_change_pct is not null) then
         amount_change_pct := x_amount_change_pct;
     else
         amount_change_pct := 1;
     end if;

     if (x_rounding_precision is not null) then
         rounding_precision := x_rounding_precision;
     else
         rounding_precision := 5;
     end if;

     x_err_stage := 'get time phased type <' ||  to_char(x_src_version_id)
                    || '>' ;
     SELECT m.time_phased_type_code,
                 m.entry_level_code
     INTO   x_time_phased_type_code,
              x_entry_level_code
     FROM   pa_budget_entry_methods m,
              pa_budget_versions v
     WHERE  v.budget_version_id = x_src_version_id
     AND    v.budget_entry_method_code = m.budget_entry_method_code;

     x_err_stage := 'copy resource assignment <' ||  to_char(x_src_version_id)
                    || '>' ;

     IF (x_entry_level_code <> 'P') THEN

        INSERT INTO pa_resource_assignments
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
           SELECT  pa_resource_assignments_s.nextval,
                   x_dest_version_id,
                   dt.project_id,
                   dt.task_id,
                   sa.resource_list_member_id,
                   SYSDATE,
                   x_created_by,
                   SYSDATE,
                   x_created_by,
                   x_last_update_login,
                   sa.unit_of_measure,
                   sa.track_as_labor_flag,
                   -1,
                   sa.RESOURCE_ASSIGNMENT_TYPE
            FROM
                   pa_resource_assignments sa,
                   pa_tasks st,
                   pa_tasks dt,
                   pa_budget_versions dv
           WHERE   sa.budget_version_id = x_src_version_id
           AND     sa.project_id = st.project_id
           AND     sa.task_id = st.task_id
           AND     st.task_number = dt.task_number
           AND     dt.project_id = dv.project_id
           AND     dv.budget_version_id = x_dest_version_id
           AND     NVL(sa.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED';

     ELSE

        INSERT INTO pa_resource_assignments
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
           SELECT  pa_resource_assignments_s.nextval,
                   x_dest_version_id,
                   dv.project_id,
                   0,
                   sa.resource_list_member_id,
                   SYSDATE,
                   x_created_by,
                   SYSDATE,
                   x_created_by,
                   x_last_update_login,
                   sa.unit_of_measure,
                   sa.track_as_labor_flag,
                   -1,
                   sa.RESOURCE_ASSIGNMENT_TYPE
           FROM
                  pa_resource_assignments sa,
                  pa_budget_versions dv
           WHERE  sa.budget_version_id = x_src_version_id
           AND    sa.task_id = 0
           AND    dv.budget_version_id = x_dest_version_id
           AND    NVL(sa.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED';

     END IF;
        -- Bug Fix: 4569365. Removed MRC code.
        /* FPB2: MRC */
        x_err_stage := 'calling populate_bl_map_tmp <' ||to_char(x_src_version_id)
                    || '>' ;

        /** MRC Elimination Changes: PA_MRC_FINPLAN.populate_bl_map_tmp **/
        PA_FIN_PLAN_UTILS2.populate_bl_map_tmp
		(p_source_fin_plan_version_id  => x_src_version_id,
                                                    x_return_status      => x_return_status,
                                                    x_msg_count          => x_msg_count,
                                                    x_msg_data           => x_msg_data);


     -- bug 4914055: we are mimicing the logic used in finplan model to derive the number of periods
     -- to be shifted due to performance reason.

     select project_id
     into   l_project_id
     from   pa_budget_versions
     where  budget_version_id = x_src_version_id;

     DELETE FROM pa_fp_cpy_periods_tmp;

     if (nvl(x_shift_days,0) <> 0) then
          if (   (x_time_phased_type_code = 'G')
              or (x_time_phased_type_code = 'P')) then
               SELECT p.start_date
               INTO   l_min_start_date
               FROM   pa_projects_all p /*Modified for bug 6320792 */
               WHERE  p.project_id = l_project_id;

               IF l_min_start_date IS NULL THEN
                    SELECt min(t.start_date)
                    INTO   l_min_start_date
                    FROM   pa_tasks t
                    WHERE  t.project_id = l_project_id;

                    IF l_min_start_date is NULL THEN

                         SELECT min(bl.start_date)
                         INTO   l_min_start_Date
                         FROM   pa_budget_lines bl
                         WHERE  bl.budget_version_id = x_src_version_id;

                         -- If l_start_date is null after the above select it implies
                         -- there are no budget lines. So return immediately as nothing
                         -- needs to be copied
                         IF l_min_start_Date IS NULL THEN
                            RETURN;
                         END IF;
                    END IF;  /* Mininum Task start date is null */
               END IF; /* Minimum Project start date is null */

               --Based on the shift_days check how much shift is required period wise
               pa_budget_core.get_periods(
                             x_start_date1 => l_min_start_date,
                             x_start_date2 => l_min_start_date + x_shift_days,
                             x_period_type => x_time_phased_type_code,
                             x_periods     => x_periods,
                             x_err_code    => x_err_code,
                             x_err_stage   => x_err_stage,
                             x_err_stack   => x_err_stack);
               IF x_err_code <> 0 THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                         p_msg_name      => x_err_stage);
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
          end if; -- g/p time phase
     end if; -- shift days non zero

        for budget_line_row in
          (select l.resource_assignment_id, l.start_date, l.end_date,a.task_id, l.period_name
           from   pa_budget_lines l,
                  pa_resource_assignments a
           where  a.budget_version_id = x_src_version_id
                and    a.resource_assignment_id = l.resource_assignment_id
           and    NVL(a.RESOURCE_ASSIGNMENT_TYPE,'USER_ENTERED') = 'USER_ENTERED'
          ) loop

            x_period_name := NULL;
            x_start_date := NULL;
            x_end_date := NULL;

-- Shifting Periods for Budget Lines
     if (nvl(x_shift_days,0) <> 0) then
              if (   (x_time_phased_type_code = 'R')
                       or (x_time_phased_type_code = 'N')) then
                 -- time-phased by date range or non-time-phased
             x_start_date :=  budget_line_row.start_date + x_shift_days;
             x_end_date :=  budget_line_row.end_date + x_shift_days;
        else

                 -- Bug 4772773: commenting the following for perf reason to pass only a single number of
                 -- periods to be passed to be shifted same for all the lines.
            /*
                if (x_entry_level_code <> 'P') then
              x_err_stage := 'Getting Task Start Date <'|| to_char(x_src_version_id);
              select start_date
              into x_task_start_date
              from pa_tasks
              where task_id =  budget_line_row.task_id;
           end if;

                x_err_stage := 'Getting no of periods by which line budget period needs to be shifted<'||
                                to_char(x_src_version_id);
                get_periods(nvl(x_task_start_date, nvl(g_project_start_date, budget_line_row.start_date) ),
                          nvl(x_task_start_date, nvl(g_project_start_date, budget_line_row.start_date) )
                               + x_shift_days,
                          x_time_phased_type_code  ,
                          x_periods  ,
                          x_err_code ,
                          x_err_stage,
                          x_err_stack );

                  if (x_err_code <> 0) then
                   return;
             end if;
              */
              if (x_periods <> 0) then --Bug 5151476
                x_err_stage := 'Shifting line budget period <'||  to_char(x_src_version_id);
                shift_periods(budget_line_row.start_date,
                              x_periods ,
                              x_period_name ,
                              x_time_phased_type_code,
                              x_start_date ,
                              x_end_date,
                              x_err_code,
                              x_err_stage,
                              x_err_stack );

                 if (x_err_code <> 0) then
                   return;
                 end if;
                   /* Bug 4772773: Populating a temp table with the new shifted period name, start date and end date */
                       IF NOT (l_period_info_tbl.EXISTS(x_period_name)) THEN
                           INSERT INTO pa_fp_cpy_periods_tmp
                                   (PA_PERIOD_NAME
                                   ,GL_PERIOD_NAME
                                   ,PERIOD_NAME
                                   ,START_DATE
                                   ,END_DATE)
                           VALUES
                                   (decode(x_time_phased_type_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,budget_line_row.period_name,'-99')
                                   ,decode(x_time_phased_type_code,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,budget_line_row.period_name,'-99')
                                   ,x_period_name
                                   ,x_start_date
                                   ,x_end_date);
                           l_period_info_tbl(x_period_name ) := budget_line_row.resource_assignment_id;
                       END IF;
                end if;
               end if;
             end if;
     end loop; -- bug 4772773: moved up here.

-- bug 4772773: Commented out the following code block for performance reasons.
/*
            if (x_entry_level_code <> 'P') then

         INSERT INTO pa_budget_lines
               (budget_line_id,           /* FPB2
                budget_version_id,        /* FPB2
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
                projfunc_currency_code,
                project_currency_code,
                txn_currency_code
                )
              select
                bmt.target_budget_line_id,       /* FPB2
                x_dest_version_id,               /* FPB2
                da.resource_assignment_id,
                decode(x_start_date, NULL, l.start_date, x_start_date),
                SYSDATE,
                x_created_by,
                SYSDATE,
                x_created_by,
                x_last_update_login,
                decode(x_end_date, NULL, l.end_date, x_end_date),
                decode(x_period_name, NULL, l.period_name, x_period_name),
                l.quantity,
                round(l.raw_cost * amount_change_pct, rounding_precision),
                round(l.burdened_cost * amount_change_pct, rounding_precision),
                round(l.revenue * amount_change_pct, rounding_precision),
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
                l.projfunc_currency_code,
                l.project_currency_code,
                l.txn_currency_code
         from   pa_budget_lines l,
                pa_resource_assignments sa,
                pa_tasks st,
                pa_tasks dt,
                pa_resource_assignments da,
                pa_fp_bl_map_tmp bmt            /* FPB2
         where  l.resource_assignment_id =
                budget_line_row.resource_assignment_id
         and    l.start_date = budget_line_row.start_date
         and    l.resource_assignment_id = sa.resource_assignment_id
         and    sa.budget_version_id = x_src_version_id
         and    sa.task_id = st.task_id
         and    sa.project_id = st.project_id
         and    sa.resource_list_member_id = da.resource_list_member_id
         and    st.task_number = dt.task_number
         and    dt.task_id = da.task_id
         and    dt.project_id = da.project_id
         and    da.budget_version_id = x_dest_version_id
         and    l.budget_line_id = bmt.source_budget_line_id      /* FPB2
        ;

          else

             insert into pa_budget_lines
               (budget_line_id,           /* FPB2
                budget_version_id,        /* FPB2
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
                projfunc_currency_code,
                project_currency_code,
                txn_currency_code
                )
              select
               bmt.target_budget_line_id,       /* FPB2
               x_dest_version_id,               /* FPB2
               da.resource_assignment_id,
               decode(x_start_date, NULL, l.start_date, x_start_date),
               SYSDATE,
               x_created_by,
               SYSDATE,
               x_created_by,
               x_last_update_login,
               decode(x_end_date, NULL, l.end_date, x_end_date),
               decode(x_period_name, NULL, l.period_name, x_period_name),
               l.quantity,
               round(l.raw_cost * amount_change_pct, rounding_precision),
               round(l.burdened_cost * amount_change_pct, rounding_precision),
               round(l.revenue * amount_change_pct, rounding_precision),
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
               l.projfunc_currency_code,
               l.project_currency_code,
               l.txn_currency_code
         from  pa_budget_lines l,
               pa_resource_assignments sa,
               pa_resource_assignments da,
               pa_fp_bl_map_tmp bmt            /* FPB2
         where l.resource_assignment_id =
               budget_line_row.resource_assignment_id
         and   l.start_date = budget_line_row.start_date
         and   l.resource_assignment_id = sa.resource_assignment_id
         and   sa.budget_version_id = x_src_version_id
         and   sa.task_id = 0
         and   sa.resource_list_member_id = da.resource_list_member_id
         and   da.task_id = 0
         and   da.budget_version_id = x_dest_version_id
         and   l.budget_line_id = bmt.source_budget_line_id      /* FPB2
         ;

        end if; */

      -- bug 4772773: Splitted the above select and insert as following
      -- individual processing block due to performance reason so that
      -- we can make use of bulk processing logic wherever possible and required.
      --Bug 5151476
      if Nvl(x_shift_days, 0) = 0 OR (nvl(x_periods,0)=0 AND
(x_time_phased_type_code='P' OR x_time_phased_type_code='G')) then
        if (x_entry_level_code <> 'P') then
                select
                    bmt.target_budget_line_id,       /* FPB2 */
                    x_dest_version_id,               /* FPB2 */
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
                    round(l.raw_cost * amount_change_pct, rounding_precision),
                    round(l.burdened_cost * amount_change_pct, rounding_precision),
                    round(l.revenue * amount_change_pct, rounding_precision),
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
                    l.projfunc_currency_code,
                    l.project_currency_code,
                    l.txn_currency_code
                bulk collect into
                    l_budget_line_id_tbl,
                    l_budget_version_id_tbl,
                    l_resource_assignment_id_tbl,
                    l_start_date_tbl,
                    l_last_update_date_tbl,
                    l_last_updated_by_tbl,
                    l_creation_date_tbl,
                    l_created_by_tbl,
                    l_last_update_login_tbl,
                    l_end_date_tbl,
                    l_period_name_tbl,
                    l_quantity_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_change_reason_code_tbl,
                    l_description_tbl,
                    l_attribute_category_tbl,
                    l_attribute1_tbl,
                    l_attribute2_tbl,
                    l_attribute3_tbl,
                    l_attribute4_tbl,
                    l_attribute5_tbl,
                    l_attribute6_tbl,
                    l_attribute7_tbl,
                    l_attribute8_tbl,
                    l_attribute9_tbl,
                    l_attribute10_tbl,
                    l_attribute11_tbl,
                    l_attribute12_tbl,
                    l_attribute13_tbl,
                    l_attribute14_tbl,
                    l_attribute15_tbl,
                    l_pm_product_code_tbl,
                    l_pm_budget_line_reference_tbl,
                    l_raw_cost_source_tbl,
                    l_burdened_cost_source_tbl,
                    l_quantity_source_tbl,
                    l_revenue_source_tbl,
                    l_projfunc_currency_code_tbl,
                    l_project_currency_code_tbl,
                    l_txn_currency_code_tbl
             from   pa_budget_lines l,
                    pa_resource_assignments sa,
                    pa_tasks st,
                    pa_tasks dt,
                    pa_resource_assignments da,
                    pa_fp_bl_map_tmp bmt            /* FPB2 */
             where  l.budget_version_id = x_src_version_id
             and    l.resource_assignment_id = sa.resource_assignment_id
             and    sa.budget_version_id = x_src_version_id
             and    sa.task_id = st.task_id
             and    sa.project_id = st.project_id
             and    sa.resource_list_member_id = da.resource_list_member_id
             and    st.task_number = dt.task_number
             and    dt.task_id = da.task_id
             and    dt.project_id = da.project_id
             and    da.budget_version_id = x_dest_version_id
             and    l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */

        else -- project level planning
                select
                   bmt.target_budget_line_id,       /* FPB2 */
                   x_dest_version_id,               /* FPB2 */
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
                   round(l.raw_cost * amount_change_pct, rounding_precision),
                   round(l.burdened_cost * amount_change_pct, rounding_precision),
                   round(l.revenue * amount_change_pct, rounding_precision),
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
                   l.projfunc_currency_code,
                   l.project_currency_code,
                   l.txn_currency_code
                bulk collect into
                    l_budget_line_id_tbl,
                    l_budget_version_id_tbl,
                    l_resource_assignment_id_tbl,
                    l_start_date_tbl,
                    l_last_update_date_tbl,
                    l_last_updated_by_tbl,
                    l_creation_date_tbl,
                    l_created_by_tbl,
                    l_last_update_login_tbl,
                    l_end_date_tbl,
                    l_period_name_tbl,
                    l_quantity_tbl,
                    l_raw_cost_tbl,
                    l_burdened_cost_tbl,
                    l_revenue_tbl,
                    l_change_reason_code_tbl,
                    l_description_tbl,
                    l_attribute_category_tbl,
                    l_attribute1_tbl,
                    l_attribute2_tbl,
                    l_attribute3_tbl,
                    l_attribute4_tbl,
                    l_attribute5_tbl,
                    l_attribute6_tbl,
                    l_attribute7_tbl,
                    l_attribute8_tbl,
                    l_attribute9_tbl,
                    l_attribute10_tbl,
                    l_attribute11_tbl,
                    l_attribute12_tbl,
                    l_attribute13_tbl,
                    l_attribute14_tbl,
                    l_attribute15_tbl,
                    l_pm_product_code_tbl,
                    l_pm_budget_line_reference_tbl,
                    l_raw_cost_source_tbl,
                    l_burdened_cost_source_tbl,
                    l_quantity_source_tbl,
                    l_revenue_source_tbl,
                    l_projfunc_currency_code_tbl,
                    l_project_currency_code_tbl,
                    l_txn_currency_code_tbl
             from  pa_budget_lines l,
                   pa_resource_assignments sa,
                   pa_resource_assignments da,
                   pa_fp_bl_map_tmp bmt            /* FPB2 */
             where l.budget_version_id = x_src_version_id
             and   l.resource_assignment_id = sa.resource_assignment_id
             and   sa.budget_version_id = x_src_version_id
             and   sa.task_id = 0
             and   sa.resource_list_member_id = da.resource_list_member_id
             and   da.task_id = 0
             and   da.budget_version_id = x_dest_version_id
             and   l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */
        end if;
      else -- shift date non zero
          if x_time_phased_type_code not in ('N', 'R') then
              if (x_entry_level_code <> 'P') then
                      select
                          bmt.target_budget_line_id,       /* FPB2 */
                          x_dest_version_id,               /* FPB2 */
                          da.resource_assignment_id,
                          pptmp.start_date,
                          SYSDATE,
                          x_created_by,
                          SYSDATE,
                          x_created_by,
                          x_last_update_login,
                          pptmp.end_date,
                          pptmp.period_name,
                          l.quantity,
                          round(l.raw_cost * amount_change_pct, rounding_precision),
                          round(l.burdened_cost * amount_change_pct, rounding_precision),
                          round(l.revenue * amount_change_pct, rounding_precision),
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
                          l.projfunc_currency_code,
                          l.project_currency_code,
                          l.txn_currency_code
                      bulk collect into
                          l_budget_line_id_tbl,
                          l_budget_version_id_tbl,
                          l_resource_assignment_id_tbl,
                          l_start_date_tbl,
                          l_last_update_date_tbl,
                          l_last_updated_by_tbl,
                          l_creation_date_tbl,
                          l_created_by_tbl,
                          l_last_update_login_tbl,
                          l_end_date_tbl,
                          l_period_name_tbl,
                          l_quantity_tbl,
                          l_raw_cost_tbl,
                          l_burdened_cost_tbl,
                          l_revenue_tbl,
                          l_change_reason_code_tbl,
                          l_description_tbl,
                          l_attribute_category_tbl,
                          l_attribute1_tbl,
                          l_attribute2_tbl,
                          l_attribute3_tbl,
                          l_attribute4_tbl,
                          l_attribute5_tbl,
                          l_attribute6_tbl,
                          l_attribute7_tbl,
                          l_attribute8_tbl,
                          l_attribute9_tbl,
                          l_attribute10_tbl,
                          l_attribute11_tbl,
                          l_attribute12_tbl,
                          l_attribute13_tbl,
                          l_attribute14_tbl,
                          l_attribute15_tbl,
                          l_pm_product_code_tbl,
                          l_pm_budget_line_reference_tbl,
                          l_raw_cost_source_tbl,
                          l_burdened_cost_source_tbl,
                          l_quantity_source_tbl,
                          l_revenue_source_tbl,
                          l_projfunc_currency_code_tbl,
                          l_project_currency_code_tbl,
                          l_txn_currency_code_tbl
                   from   pa_budget_lines l,
                          pa_resource_assignments sa,
                          pa_tasks st,
                          pa_tasks dt,
                          pa_resource_assignments da,
                          pa_fp_bl_map_tmp bmt,            /* FPB2 */
                          PA_FP_CPY_PERIODS_TMP pptmp
                   where  l.budget_version_id = x_src_version_id
                   and    l.resource_assignment_id = sa.resource_assignment_id
                   and    decode(x_time_phased_type_code,
                                 PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P, pptmp.pa_period_name,
                                 PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G, pptmp.gl_period_name) = l.period_name
                   and    sa.budget_version_id = x_src_version_id
                   and    sa.task_id = st.task_id
                   and    sa.project_id = st.project_id
                   and    sa.resource_list_member_id = da.resource_list_member_id
                   and    st.task_number = dt.task_number
                   and    dt.task_id = da.task_id
                   and    dt.project_id = da.project_id
                   and    da.budget_version_id = x_dest_version_id
                   and    l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */
                else -- project level planning

                      select
                         bmt.target_budget_line_id,       /* FPB2 */
                         x_dest_version_id,               /* FPB2 */
                         da.resource_assignment_id,
                         pptmp.start_date,
                         SYSDATE,
                         x_created_by,
                         SYSDATE,
                         x_created_by,
                         x_last_update_login,
                         pptmp.end_date,
                         pptmp.period_name,
                         l.quantity,
                         round(l.raw_cost * amount_change_pct, rounding_precision),
                         round(l.burdened_cost * amount_change_pct, rounding_precision),
                         round(l.revenue * amount_change_pct, rounding_precision),
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
                         l.projfunc_currency_code,
                         l.project_currency_code,
                         l.txn_currency_code
                      bulk collect into
                          l_budget_line_id_tbl,
                          l_budget_version_id_tbl,
                          l_resource_assignment_id_tbl,
                          l_start_date_tbl,
                          l_last_update_date_tbl,
                          l_last_updated_by_tbl,
                          l_creation_date_tbl,
                          l_created_by_tbl,
                          l_last_update_login_tbl,
                          l_end_date_tbl,
                          l_period_name_tbl,
                          l_quantity_tbl,
                          l_raw_cost_tbl,
                          l_burdened_cost_tbl,
                          l_revenue_tbl,
                          l_change_reason_code_tbl,
                          l_description_tbl,
                          l_attribute_category_tbl,
                          l_attribute1_tbl,
                          l_attribute2_tbl,
                          l_attribute3_tbl,
                          l_attribute4_tbl,
                          l_attribute5_tbl,
                          l_attribute6_tbl,
                          l_attribute7_tbl,
                          l_attribute8_tbl,
                          l_attribute9_tbl,
                          l_attribute10_tbl,
                          l_attribute11_tbl,
                          l_attribute12_tbl,
                          l_attribute13_tbl,
                          l_attribute14_tbl,
                          l_attribute15_tbl,
                          l_pm_product_code_tbl,
                          l_pm_budget_line_reference_tbl,
                          l_raw_cost_source_tbl,
                          l_burdened_cost_source_tbl,
                          l_quantity_source_tbl,
                          l_revenue_source_tbl,
                          l_projfunc_currency_code_tbl,
                          l_project_currency_code_tbl,
                          l_txn_currency_code_tbl
                   from  pa_budget_lines l,
                         pa_resource_assignments sa,
                         pa_resource_assignments da,
                         pa_fp_bl_map_tmp bmt,            /* FPB2 */
                         PA_FP_CPY_PERIODS_TMP pptmp
                   where l.budget_version_id = x_src_version_id
                   and   l.resource_assignment_id = sa.resource_assignment_id
                   and   decode(x_time_phased_type_code,
                                PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P, pptmp.pa_period_name,
                                PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G, pptmp.gl_period_name) = l.period_name
                   and   sa.budget_version_id = x_src_version_id
                   and   sa.task_id = 0
                   and   sa.resource_list_member_id = da.resource_list_member_id
                   and   da.task_id = 0
                   and   da.budget_version_id = x_dest_version_id
                   and   l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */
            end if;

          else -- non time phased
            if (x_entry_level_code <> 'P') then
                  select
                      bmt.target_budget_line_id,       /* FPB2 */
                      x_dest_version_id,               /* FPB2 */
                      da.resource_assignment_id,
                      (l.start_date + Nvl(x_shift_days, 0)),
                      SYSDATE,
                      x_created_by,
                      SYSDATE,
                      x_created_by,
                      x_last_update_login,
                      (l.end_date + Nvl(x_shift_days, 0)),
                      l.period_name, -- would be null
                      l.quantity,
                      round(l.raw_cost * amount_change_pct, rounding_precision),
                      round(l.burdened_cost * amount_change_pct, rounding_precision),
                      round(l.revenue * amount_change_pct, rounding_precision),
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
                      l.projfunc_currency_code,
                      l.project_currency_code,
                      l.txn_currency_code
                  bulk collect into
                      l_budget_line_id_tbl,
                      l_budget_version_id_tbl,
                      l_resource_assignment_id_tbl,
                      l_start_date_tbl,
                      l_last_update_date_tbl,
                      l_last_updated_by_tbl,
                      l_creation_date_tbl,
                      l_created_by_tbl,
                      l_last_update_login_tbl,
                      l_end_date_tbl,
                      l_period_name_tbl,
                      l_quantity_tbl,
                      l_raw_cost_tbl,
                      l_burdened_cost_tbl,
                      l_revenue_tbl,
                      l_change_reason_code_tbl,
                      l_description_tbl,
                      l_attribute_category_tbl,
                      l_attribute1_tbl,
                      l_attribute2_tbl,
                      l_attribute3_tbl,
                      l_attribute4_tbl,
                      l_attribute5_tbl,
                      l_attribute6_tbl,
                      l_attribute7_tbl,
                      l_attribute8_tbl,
                      l_attribute9_tbl,
                      l_attribute10_tbl,
                      l_attribute11_tbl,
                      l_attribute12_tbl,
                      l_attribute13_tbl,
                      l_attribute14_tbl,
                      l_attribute15_tbl,
                      l_pm_product_code_tbl,
                      l_pm_budget_line_reference_tbl,
                      l_raw_cost_source_tbl,
                      l_burdened_cost_source_tbl,
                      l_quantity_source_tbl,
                      l_revenue_source_tbl,
                      l_projfunc_currency_code_tbl,
                      l_project_currency_code_tbl,
                      l_txn_currency_code_tbl
               from   pa_budget_lines l,
                      pa_resource_assignments sa,
                      pa_tasks st,
                      pa_tasks dt,
                      pa_resource_assignments da,
                      pa_fp_bl_map_tmp bmt            /* FPB2 */
               where  l.budget_version_id = x_src_version_id
               and    l.resource_assignment_id = sa.resource_assignment_id
               and    sa.budget_version_id = x_src_version_id
               and    sa.task_id = st.task_id
               and    sa.project_id = st.project_id
               and    sa.resource_list_member_id = da.resource_list_member_id
               and    st.task_number = dt.task_number
               and    dt.task_id = da.task_id
               and    dt.project_id = da.project_id
               and    da.budget_version_id = x_dest_version_id
               and    l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */

           else -- project level planning

                  select
                     bmt.target_budget_line_id,       /* FPB2 */
                     x_dest_version_id,               /* FPB2 */
                     da.resource_assignment_id,
                     (l.start_date + Nvl(x_shift_days, 0)),
                     SYSDATE,
                     x_created_by,
                     SYSDATE,
                     x_created_by,
                     x_last_update_login,
                     (l.end_date + Nvl(x_shift_days, 0)),
                     l.period_name, -- would be null
                     l.quantity,
                     round(l.raw_cost * amount_change_pct, rounding_precision),
                     round(l.burdened_cost * amount_change_pct, rounding_precision),
                     round(l.revenue * amount_change_pct, rounding_precision),
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
                     l.projfunc_currency_code,
                     l.project_currency_code,
                     l.txn_currency_code
                  bulk collect into
                      l_budget_line_id_tbl,
                      l_budget_version_id_tbl,
                      l_resource_assignment_id_tbl,
                      l_start_date_tbl,
                      l_last_update_date_tbl,
                      l_last_updated_by_tbl,
                      l_creation_date_tbl,
                      l_created_by_tbl,
                      l_last_update_login_tbl,
                      l_end_date_tbl,
                      l_period_name_tbl,
                      l_quantity_tbl,
                      l_raw_cost_tbl,
                      l_burdened_cost_tbl,
                      l_revenue_tbl,
                      l_change_reason_code_tbl,
                      l_description_tbl,
                      l_attribute_category_tbl,
                      l_attribute1_tbl,
                      l_attribute2_tbl,
                      l_attribute3_tbl,
                      l_attribute4_tbl,
                      l_attribute5_tbl,
                      l_attribute6_tbl,
                      l_attribute7_tbl,
                      l_attribute8_tbl,
                      l_attribute9_tbl,
                      l_attribute10_tbl,
                      l_attribute11_tbl,
                      l_attribute12_tbl,
                      l_attribute13_tbl,
                      l_attribute14_tbl,
                      l_attribute15_tbl,
                      l_pm_product_code_tbl,
                      l_pm_budget_line_reference_tbl,
                      l_raw_cost_source_tbl,
                      l_burdened_cost_source_tbl,
                      l_quantity_source_tbl,
                      l_revenue_source_tbl,
                      l_projfunc_currency_code_tbl,
                      l_project_currency_code_tbl,
                      l_txn_currency_code_tbl
               from  pa_budget_lines l,
                     pa_resource_assignments sa,
                     pa_resource_assignments da,
                     pa_fp_bl_map_tmp bmt            /* FPB2 */
               where l.budget_version_id = x_src_version_id
               and   l.resource_assignment_id = sa.resource_assignment_id
               and   sa.budget_version_id = x_src_version_id
               and   sa.task_id = 0
               and   sa.resource_list_member_id = da.resource_list_member_id
               and   da.task_id = 0
               and   da.budget_version_id = x_dest_version_id
               and   l.budget_line_id = bmt.source_budget_line_id; /* FPB2 */

            end if; -- project level
          end if; -- time phase R, N
      end if; -- shift date 0

      -- inserting bulk into pa_budget_lines bug 4772773
      FORALL i IN l_budget_line_id_tbl.FIRST .. l_budget_line_id_tbl.LAST

        INSERT INTO pa_budget_lines
             (budget_line_id,           /* FPB2 */
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
              projfunc_currency_code,
              project_currency_code,
              txn_currency_code
              )
        VALUES
             (l_budget_line_id_tbl(i),
              l_budget_version_id_tbl(i),
              l_resource_assignment_id_tbl(i),
              l_start_date_tbl(i),
              l_last_update_date_tbl(i),
              l_last_updated_by_tbl(i),
              l_creation_date_tbl(i),
              l_created_by_tbl(i),
              l_last_update_login_tbl(i),
              l_end_date_tbl(i),
              l_period_name_tbl(i),
              l_quantity_tbl(i),
              l_raw_cost_tbl(i),
              l_burdened_cost_tbl(i),
              l_revenue_tbl(i),
              l_change_reason_code_tbl(i),
              l_description_tbl(i),
              l_attribute_category_tbl(i),
              l_attribute1_tbl(i),
              l_attribute2_tbl(i),
              l_attribute3_tbl(i),
              l_attribute4_tbl(i),
              l_attribute5_tbl(i),
              l_attribute6_tbl(i),
              l_attribute7_tbl(i),
              l_attribute8_tbl(i),
              l_attribute9_tbl(i),
              l_attribute10_tbl(i),
              l_attribute11_tbl(i),
              l_attribute12_tbl(i),
              l_attribute13_tbl(i),
              l_attribute14_tbl(i),
              l_attribute15_tbl(i),
              l_pm_product_code_tbl(i),
              l_pm_budget_line_reference_tbl(i),
              l_raw_cost_source_tbl(i),
              l_burdened_cost_source_tbl(i),
              l_quantity_source_tbl(i),
              l_revenue_source_tbl(i),
              l_projfunc_currency_code_tbl(i),
              l_project_currency_code_tbl(i),
              l_txn_currency_code_tbl(i));


              l_budget_line_id_tbl.DELETE;
              l_budget_version_id_tbl.DELETE;
              l_resource_assignment_id_tbl.DELETE;
              l_start_date_tbl.DELETE;
              l_last_update_date_tbl.DELETE;
              l_last_updated_by_tbl.DELETE;
              l_creation_date_tbl.DELETE;
              l_created_by_tbl.DELETE;
              l_last_update_login_tbl.DELETE;
              l_end_date_tbl.DELETE;
              l_period_name_tbl.DELETE;
              l_quantity_tbl.DELETE;
              l_raw_cost_tbl.DELETE;
              l_burdened_cost_tbl.DELETE;
              l_revenue_tbl.DELETE;
              l_change_reason_code_tbl.DELETE;
              l_description_tbl.DELETE;
              l_attribute_category_tbl.DELETE;
              l_attribute1_tbl.DELETE;
              l_attribute2_tbl.DELETE;
              l_attribute3_tbl.DELETE;
              l_attribute4_tbl.DELETE;
              l_attribute5_tbl.DELETE;
              l_attribute6_tbl.DELETE;
              l_attribute7_tbl.DELETE;
              l_attribute8_tbl.DELETE;
              l_attribute9_tbl.DELETE;
              l_attribute10_tbl.DELETE;
              l_attribute11_tbl.DELETE;
              l_attribute12_tbl.DELETE;
              l_attribute13_tbl.DELETE;
              l_attribute14_tbl.DELETE;
              l_attribute15_tbl.DELETE;
              l_pm_product_code_tbl.DELETE;
              l_pm_budget_line_reference_tbl.DELETE;
              l_raw_cost_source_tbl.DELETE;
              l_burdened_cost_source_tbl.DELETE;
              l_quantity_source_tbl.DELETE;
              l_revenue_source_tbl.DELETE;
              l_projfunc_currency_code_tbl.DELETE;
              l_project_currency_code_tbl.DELETE;
              l_txn_currency_code_tbl.DELETE;
        -- bug 4772773: ends

         -- Bug Fix: 4569365. Removed MRC code.
         /* FPB2 */
         /*
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
                  PA_MRC_FINPLAN.COPY_MC_BUDGET_LINES
                                   (p_source_fin_plan_version_id => x_src_version_id,
                                    p_target_fin_plan_version_id => x_dest_version_id,
                                    x_return_status              => x_return_status,
                                    x_msg_count                  => x_msg_count,
                                    x_msg_data                   => x_msg_data);
               ELSIF  (PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'B' AND l_version_is_baselined = 'Y') THEN
                    PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                               (p_fin_plan_version_id => x_dest_version_id, -- Target version should be passed
                                p_entire_version      => 'Y',
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);
               -- Bug 2676494
              END IF;

         END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE g_mrc_exception;
            END IF;

         END;
         */


  exception
      when others then
         x_err_code := SQLCODE;
         return;
  end copy_lines;


END pa_budget_core;

/
