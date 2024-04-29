--------------------------------------------------------
--  DDL for Package Body PA_BILLING_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_CORE" as
-- $Header: PAXINBCB.pls 120.5.12010000.4 2009/07/15 09:32:49 dbudhwar ship $

-- This is the main billing procedure to verify baseline funding.
--
-- History
--	10-SEP-97	jwhite	Added code for mulitple messaging
--
--
-- 02.26.1999  Partha   Comment corrected for dbms_output as per adchkdrv log.

-- 01-MAR-99   Tianyi   Change != to <>
-- 07-SEP-01   modified to use _all tables
--             Changed to use projfunc amounts (MCB2)
  r_amount number;   /* Added for bug 2913524 */
  procedure verify_baseline_funding(
		      x_project_id  	  in     number,
		      x_draft_version_id  in     number,
		      x_entry_level_code  in     varchar2,
		      x_proj_bu_revenue   in     number,
		      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
		      x_err_stage	  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
		      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is

    x_funding_level             varchar2(2);
    x_task_id                   number(15) default 0;
    dummy                       number;
    cost_rule_flag              varchar2(2) default 'N';
    x_revenue                   number default 0;
    x_raw_cost                  number default 0;
    x_burdened_cost             number default 0;
    x_labor_quantity            number default 0;
    funding_total               number default 0;
    old_stack                   varchar2(630);
    cost_rec			number;
    amt_over_rec		number;
    proj_event_rec		number;
    agr_rec             number;         /* Bug#2303396 */
    l_fin_plan_type_id          number(15) default null; --Bug#2668857
    l_version_type              varchar2(30) default null; --Bug#2668857


    cursor cost is
        select 1
        from   pa_projects_all
        where  project_id = x_project_id
        and    substr(distribution_rule, 1, 5) =  'COST/';

/*  Commented for bug 2744993
    cursor amt_over is
	select 1
	from   sys.dual
        where  not exists
                     (select 1
                      from   pa_agreements_all a,
                             pa_summary_project_fundings f
                      where  f.project_id  = x_project_id
		      and    nvl(f.task_id, 0) = x_task_id
                      and    (  (  nvl(f.total_baselined_amount, 0)
                                 + f.total_unbaselined_amount
                                )
                              < greatest(nvl(f.total_accrued_amount, 0),
                                         nvl(f.total_billed_amount, 0))
                             )
                      and    f.agreement_id = a.agreement_id
                      and    a.revenue_limit_flag = 'Y');
*/
    cursor amt_over is
	select 1
	from   sys.dual
        where  not exists
                     (select 1
                      from   pa_agreements_all a,
                             pa_summary_project_fundings f
                      where  f.project_id  = x_project_id
		      and    nvl(f.task_id, 0) = x_task_id
                      and    (  (  nvl(f.projfunc_baselined_amount, 0)
                                 + f.projfunc_unbaselined_amount
                                )
                              < nvl(f.projfunc_accrued_amount, 0)
                             )
                      and    f.agreement_id = a.agreement_id
                      and    a.revenue_limit_flag = 'Y')
        and not exists
                     (select 1
                      from   pa_agreements_all a,
                             pa_summary_project_fundings f
                      where  f.project_id  = x_project_id
		      and    nvl(f.task_id, 0) = x_task_id
                      and    (  (  nvl(f.invproc_baselined_amount, 0)
                                 + f.invproc_unbaselined_amount
                                )
                              < nvl(f.invproc_billed_amount, 0)
                             )
                      and    f.agreement_id = a.agreement_id
                      and    a.invoice_limit_flag = 'Y');


    cursor proj_event is
	select 1
	from   pa_events
	where  project_id = x_project_id
	and    task_id is null;
    -- Bug 748105 (In task level baselining every task level funding
    --              should have corresponding task level budget entry
    --              and vice versa)
	--Bug 2668245  Added a Or condition ( Approved_rev_plan_type_flag=Y) in budget_type_code
    cursor budget_task is
       SELECT t.top_task_id , sum(l.revenue) revenue
       FROM   pa_budget_lines l,
              pa_resource_assignments a,
              pa_tasks t,
              pa_budget_versions v
       WHERE  v.project_id = x_project_id
       AND    (v.budget_type_code = 'AR'
	           OR v.approved_rev_plan_type_flag ='Y')
       AND    v.budget_status_code IN ('S','W') /* Fix for Bug # 1206240*/
       AND    decode(v.budget_type_code,null,v.current_working_flag,'Y')='Y' /* Added for bug 2834104 */
       and    a.budget_version_id = v.budget_version_id
       and    a.project_id = v.project_id
       and    t.project_id = v.project_id
       and    t.task_id = a.task_id
       and    a.task_id is not null
       AND    l.resource_assignment_id = a.resource_assignment_id
       group by t.top_task_id
       having  nvl(sum(l.revenue),0) <> 0            /* Fix for Bug 4735399 */
       order by t.top_task_id;
/*
       Commented and changed for the below cursor (MCB2)
       select task_id, sum(nvl(allocated_amount,0)) funding_total
*/
    -- Following cursor is modified for bux fix 3763133
    cursor funding_task is
       select task_id, sum(nvl(projfunc_allocated_amount,0)) funding_total
      from   pa_project_fundings
       where  project_id = x_project_id
	AND ( (budget_type_code IN ('DRAFT', 'BASELINE') AND PA_FUND_REVAL_PVT.G_REVAL_FLAG ='N'
		AND PA_Funding_Core.G_Fund_Baseline_Flag = 'N')
               OR (PA_FUND_REVAL_PVT.G_REVAL_FLAG ='Y' AND (
                                               ( (budget_type_code ='BASELINE') OR
                                                 (budget_type_code ='DRAFT' AND funding_category=
                                                'REVALUATION') )))
	       OR (PA_Funding_Core.G_Fund_Baseline_Flag = 'Y' AND
		    ( Budget_Type_Code = 'BASELINE' ) OR    -- Modified for bug 4057927
		    ( Budget_Type_Code = 'DRAFT' AND NVL(Submit_Baseline_Flag,'N') = 'Y') )
	    )
       and    task_id is not null
       group by task_id
       having nvl(sum(nvl(projfunc_allocated_amount,0)),0) <> 0    /* Fix for Bug 4710749 */
       order by task_id;

/*  Code for Bug#2303396 */

    cursor agreements is
                    select 1 from dual where not exists
                    (
                      select PPC.customer_id from pa_project_customers PPC
                      where PPC.project_id= x_project_id
                      and PPC.customer_bill_split > 0  /* Added for Bug2453912 */
                      and not exists
                      (
                        select 1 from pa_summary_project_fundings PSPF,
                                      pa_agreements_all PAA
                        where PPC.customer_id = PAA.customer_id
                        and PAA.agreement_id = PSPF.agreement_id
                        and PPC.project_id= PSPF.project_id
                      )
                     );

/* End of Code Fix Bug#2303396 */


    b_task_id    number;
    f_task_id    number;
    b_revenue    number;
    b_end_flag   varchar2(1) := 'F';
    f_end_flag   varchar2(1) := 'F';

-- END 748105 (code continues below)

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := 'pa_billing_core->check_funding_for_baseline';

	-- check project funding level flag properly
	check_funding_level(x_project_id,
                            x_funding_level,
                            x_err_code,
                            x_err_stage,
                            x_err_stack);

	if x_err_code <> 0 then

	   return;

	end if;

	-- Check if it is a COST/ based project.
	open cost;
	fetch cost into cost_rec;
	if cost%notfound then
	   cost_rule_flag := 'N';
	else
	   cost_rule_flag := 'Y';
	end if;

	close cost;

	if (x_funding_level = 'P') then

           -- check the sum of revenue budget equals the sum of
           -- draft and baseline funding
           x_err_stage := 'check if budget equals funding <'
                          || to_char(x_draft_version_id) || '>';

/*
       Commented and changed for the below sql (MCB2)
           select sum(nvl(allocated_amount,0))
*/
           -- Following select is modified for bux fix 3763133
           select sum(nvl(projfunc_allocated_amount,0))
           into   funding_total
           from   pa_project_fundings
           where  project_id = x_project_id
	     AND ( (budget_type_code IN ('DRAFT', 'BASELINE') AND PA_FUND_REVAL_PVT.G_REVAL_FLAG ='N'
	            AND PA_Funding_Core.G_Fund_Baseline_Flag = 'N')
               	OR (PA_FUND_REVAL_PVT.G_REVAL_FLAG ='Y' AND (
                                               ( (budget_type_code ='BASELINE') OR
                                                 (budget_type_code ='DRAFT' AND funding_category=
                                                'REVALUATION') )))
		OR (PA_Funding_Core.G_Fund_Baseline_Flag = 'Y' AND
		    ( Budget_Type_Code = 'BASELINE') OR    -- Modified for bug 4057927
		    ( Budget_Type_Code = 'DRAFT' AND NVL(Submit_Baseline_Flag,'N') = 'Y') )
		);

           if (x_proj_bu_revenue <> funding_total) then
               x_err_code := 50;
               x_err_stage := 'PA_BU_UNBALANCED_PROJ_BUDGET';

-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );

           end if;

           -- total amount allocated cannot be less than amount accrued
           -- or billed
	   open amt_over;
	   fetch amt_over into amt_over_rec;
	   if amt_over%notfound then
	       x_err_code := 40;
                     x_err_stage := 'PA_BU_AMT_ALLOC_LT_AMT_ACCRUED';

-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );



	   elsif sqlcode < 0 then

	       x_err_code := SQLCODE;
-- 10-SEP-97, jwhite: multiple messaging
	       FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_BILLING_CORE'
			,  p_procedure_name	=> 'VERIFY_BASELINE_FUNDING'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
			 );

               return;

	   end if;
	   close amt_over;

           if cost_rule_flag = 'Y' then
             /* Code Changes starts for Bug#2668857*/
	     BEGIN
                select fin_plan_type_id,
                       version_type
                into   l_fin_plan_type_id,l_version_type
                from   pa_budget_versions
                where  budget_version_id =  x_draft_version_id;

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                         l_fin_plan_type_id := NULL;
                         l_version_type := NULL;
             END;

             IF l_fin_plan_type_id is NOT NULL THEN
                  dummy := pa_fin_plan_utils.check_proj_fin_plan_exists (x_project_id          =>  x_project_id     ,
                                                                         x_budget_version_id   =>  x_draft_version_id  ,
                                                                         x_budget_status_code  => 'B'  ,
                                                                         x_plan_type_code      => 'AC', -- Approved Cost Budget Plan
                                                                         x_fin_plan_type_id    => l_fin_plan_type_id  ,
                                                                         x_version_type        => l_version_type  );
             ELSE


		      /* Code Changes ends here for Bug#2668857*/

                  dummy := pa_budget_utils.check_proj_budget_exists(
                                x_project_id,
                                'B',    -- budget status code
                                'AC');  -- budget type code
             END IF;    /* End if for l_fin_plan_type_id is NOT NULL THEN  for Bug#2668857*/
             if dummy = 0 then

                     x_err_code := 80;
                     x_err_stage := 'PA_BU_NO_BASE_COST_BUDGET';
                  -- 10-SEP-97, jwhite: multiple messaging
         	      PA_UTILS.Add_Message
        	      ( p_app_short_name	=> 'PA'
       	           , p_msg_name	=> x_err_stage
           	        );



             elsif dummy <> 1 then

                     x_err_code := dummy;
                     return;

             end if;

           end if;  -- cost_rule_flag = 'Y'

	else	-- x_funding_level = 'T'

	   -- Cannot have project level budget.
	   if x_entry_level_code = 'P' then
		x_err_code := 60;
                x_err_stage := 'PA_BU_TASK_FUND_PROJ_BUDGET';
-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );
	   end if;

	   -- Cannot have project level events.
	   open proj_event;
	   fetch proj_event into proj_event_rec;
	   if proj_event%found then
	      x_err_code := 65;
	      x_err_stage := 'PA_TASK_FUND_NO_PROJ_EVENTS';
-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );
	   end if;
	  CLOSE proj_event; --For Bug3936620

/*
	   -- for each top task
           for fund_rec in (select task_id,
                                   sum(nvl(allocated_amount,0)) funding_total
                            from   pa_project_fundings
                            where  project_id = x_project_id
                            and    budget_type_code in ('BASELINE', 'DRAFT')
                            group by task_id) loop

               x_revenue :=0;
               if fund_rec.task_id is not null then

                   x_task_id := fund_rec.task_id;
                   pa_budget_utils.get_task_budget_amount(
                        x_project_id,
                        x_task_id,
			'AR',		-- x_budget_type
			'DRAFT',	-- x_which_version
                        x_revenue,
                        x_raw_cost,
			x_burdened_cost,
			x_labor_quantity);

               end if;
*/
           -- BEGIN 748105
           -- for each top task there should be an equal funding and
           --  vice versa

           open budget_task;
           open funding_task;

           LOOP

             b_task_id := 0;
             b_revenue := 0;
             f_task_id := 0;
             funding_total := 0;

             fetch budget_task into b_task_id, b_revenue;
             if budget_task%NOTFOUND then
                b_end_flag := 'T';
             end if;

             fetch funding_task into f_task_id, funding_total;
             if funding_task%NOTFOUND then
                f_end_flag := 'T';
             end if;

             if ((b_end_flag <> f_end_flag) OR
                        (nvl(b_task_id,0) <> nvl(f_task_id,0) ) OR
                        (nvl(b_revenue,0) <> nvl(funding_total,0))) THEN
                   x_err_code := 70;
                   x_err_stage := 'PA_BU_UNBALANCED_TASK_BUDGET';
-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );
                 return;
             end if;
             exit when b_end_flag = 'T';
             -- END 748105

             -- total amount allocated cannot be less than amount accrued
             -- or billed
             x_task_id := b_task_id;
               open amt_over;
               fetch amt_over into amt_over_rec;
               if amt_over%notfound then
               	  x_err_code := 40;
                  x_err_stage := 'PA_BU_AMT_ALLOC_LT_AMT_ACCRUED';
-- 10-SEP-97, jwhite: multiple messaging
  	          PA_UTILS.Add_Message
	          ( p_app_short_name	=> 'PA'
	            , p_msg_name	=> x_err_stage
	           );

               elsif sqlcode < 0 then
                  x_err_code := SQLCODE;
-- 10-SEP-97, jwhite: multiple messaging
	       FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_BILLING_CORE'
			,  p_procedure_name	=> 'VERIFY_BASELINE_FUNDING'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
			 );

                  return;

               end if;
               close amt_over;

         if cost_rule_flag = 'Y' then
	    /* Code Changes starts for Bug#2668857*/
	     BEGIN
                select fin_plan_type_id,
                       version_type
                into   l_fin_plan_type_id,
					       l_version_type
                from  pa_budget_versions
                where budget_version_id =  x_draft_version_id;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                         l_fin_plan_type_id := NULL;
                         l_version_type := NULL;
              END;

              IF l_fin_plan_type_id is NOT NULL THEN
                 dummy := pa_fin_plan_utils.check_task_fin_plan_exists (x_task_id            =>  x_task_id     ,
                                                                        x_budget_version_id  =>  x_draft_version_id  ,
                                                                        x_budget_status_code => 'B'  ,
                                                                        x_plan_type_code     => 'AC', -- Approved Cost Budget Plan
                                                                        x_fin_plan_type_id   => l_fin_plan_type_id  ,
                                                                        x_version_type       => l_version_type  );
              ELSE
                  /* Code Changes ends  here for Bug#2668857*/
                  dummy := pa_budget_utils.check_task_budget_exists(
                                x_task_id,
                                'B',    -- budget status code
                                'AC');  -- budget type code
              END IF;-- End if of l_fin_plan_type_id is NOT NULL Bug#2668857
              if dummy = 0 then

                     x_err_code := 80;
                     x_err_stage := 'PA_BU_NO_TASK_COST_BUDGET';
                -- 10-SEP-97, jwhite: multiple messaging
        	      PA_UTILS.Add_Message
      	          ( p_app_short_name	=> 'PA'
        	        , p_msg_name	=> x_err_stage
        	       );



              elsif dummy <> 1 then

                     x_err_code := dummy;
                     return;

              end if;

	       end if;	-- cost_rule_flag = 'Y'

	   end loop;
--Introducing the Close statement after the loops For Bug 3936620
CLOSE budget_task;
CLOSE funding_task;
	end if;

/* code fix for Bug#2303396 */

        open agreements;
        fetch agreements into agr_rec;
        If ( agreements%notfound ) then
               -- data not exists
                   x_err_code := 1000;
                   x_err_stage := 'PA_MULTI_CUST_AGR_CHECK';
               -- multiple messaging
              PA_UTILS.Add_Message
              ( p_app_short_name        => 'PA',
                p_msg_name    => x_err_stage
               );
         end if;
       CLOSE agreements; --For Bug 3936620
/*  End of Code fix for Bug#2303396 */


	-- Comment out call to update_funding to use as verify only.
	-- (ckh 09/04/97)
	--
	-- change DRAFT funding to BASELINE
	-- update_funding( x_project_id,
	--		x_funding_level,
	--		x_err_code,
	--		x_err_stage,
	--		x_err_stack);
	--     if (x_err_code <> 0) then
        	--	return;
     	--    end if;
 	--

     x_err_stack := old_stack;

  exception
      when others then
	 x_err_code := SQLCODE;
-- 10-SEP-97, jwhite: multiple messaging
	       FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_BILLING_CORE'
			,  p_procedure_name	=> 'VERIFY_BASELINE_FUNDING'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
			 );
	 return;
  end verify_baseline_funding;

-- This procedure is to do funding related update statments.
-- 07-SEP-01   updated all use project/projfunc amounts (MCB2)

  procedure update_funding(
                      x_project_id        in     number,
		      x_funding_level	  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
    -- Standard who
    x_created_by                number(15);
    x_last_update_login         number(15);

    old_stack                   varchar2(630);
    non_contract		number := 0;
    l_funding_level varchar2(1) := x_funding_level;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := 'pa_billing_core->update_funding';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     -- set project level funding flag
     x_err_stage := 'set project level funding flag <'
			|| to_char(x_project_id) || '>';

     if x_funding_level is null then

	-- Only project level funding is allowed for the non-contract project.
        x_funding_level := 'P';
	non_contract := 1;

     end if;


	/*----------------------------------------------------
	-- Funding revaluation changes:
        --
        -- If action is not from revaluation process,
        --    baseline all the funding records
        --    update all the amount in summary project funding
	--    update the all currency columns
        -- elseif action is from revaluation process
        --    baseline only the revaluation funding line amount
        --    update only the revaluation funding line amount
        --    update only the projfunc, revproc and invproc columns
        -- End if
	--------------------------------------------------------*/

	IF PA_FUND_REVAL_PVT.G_REVAL_FLAG='N' THEN

     		x_err_stage := 'Not Revaluation: change draft to baseline <' || to_char(x_project_id)
                        || '>';

     		update pa_project_fundings

                  set   /* PJI_SUMMARIZED_FLAG  = 'N'  -- For Bug 2244796 and bug 2440676 */
     		        PJI_SUMMARIZED_FLAG  = decode(budget_type_code, 'BASELINE', pji_summarized_flag, 'N'),  -- For Bug 3821126
                        budget_type_code = 'BASELINE',
            		last_update_date = SYSDATE,
            		last_updated_by = x_created_by,
                  	last_update_login = x_last_update_login
     		where  project_id = x_project_id
		   and budget_type_code IN('DRAFT','BASELINE');

     		-- update summary funding
     		x_err_stage := 'update summary funding <' || to_char(x_project_id)
                        || '>';

     		update pa_summary_project_fundings
     		set    total_baselined_amount = total_unbaselined_amount +
                                     nvl(total_baselined_amount, 0),
            		total_unbaselined_amount = 0,
		/* MCB2 code begins */
            		project_baselined_amount = project_unbaselined_amount +
                                     nvl(project_baselined_amount, 0),
            		project_unbaselined_amount = 0,
            		projfunc_baselined_amount = projfunc_unbaselined_amount +
                                     nvl(projfunc_baselined_amount, 0),
            		projfunc_unbaselined_amount = 0,
            		invproc_baselined_amount = invproc_unbaselined_amount +
                                     nvl(invproc_baselined_amount, 0),
            		invproc_unbaselined_amount = 0,
            		revproc_baselined_amount = revproc_unbaselined_amount +
                                     nvl(revproc_baselined_amount, 0),
            		revproc_unbaselined_amount = 0,
		/* MCB2 code ends */
            		last_update_date = SYSDATE,
            		last_updated_by = x_created_by,
	            last_update_login = x_last_update_login
     		 where  project_id = x_project_id;

	ELSIF PA_FUND_REVAL_PVT.G_REVAL_FLAG='Y' THEN


     		-- update summary funding
     		x_err_stage := 'update summary funding <' || to_char(x_project_id)
                        || '>';

                /* Bug 2602874 Added agreement_id as join fields for pa_project_funding and
                   pa_summary_project_funding are agreement_id, project_id, task_id */

		FOR reval_rec IN (SELECT project_funding_id, agreement_id, project_id,task_id, projfunc_allocated_amount,
					 invproc_allocated_amount,revproc_allocated_amount
				  FROM pa_project_fundings
				  WHERE project_id = x_project_id
				    AND budget_type_code ='DRAFT'
				    AND funding_category ='REVALUATION') LOOP

                         /* Bug 2670854 Since pa_mc_sum_proj_fundings updates its baselined, unbaselined amount
                            based on the budget_type_code, before updating summary project fundings in primary
                            this is being done as trigger on summary project fundings will update mc summary project
                             fundings based on this col value */

                                UPDATE pa_project_fundings
     		                set   /* PJI_SUMMARIZED_FLAG  = 'N'  -- For Bug 2244796 and bug 2440676 */
     		                    PJI_SUMMARIZED_FLAG  = decode(budget_type_code, 'BASELINE', pji_summarized_flag, 'N'),  -- For Bug 3821126
                                    budget_type_code = 'BASELINE',
            		            last_update_date = SYSDATE,
            		            last_updated_by = x_created_by,
            		            last_update_login = x_last_update_login
                                WHERE project_funding_id = reval_rec.project_funding_id;

     				UPDATE pa_summary_project_fundings
     				   SET projfunc_baselined_amount = projfunc_baselined_amount +
                                     		NVL(reval_rec.projfunc_allocated_amount, 0),
            			       projfunc_unbaselined_amount = projfunc_unbaselined_amount -
						 NVL(reval_rec.projfunc_allocated_amount,0),
     				       invproc_baselined_amount = invproc_baselined_amount +
                                     		NVL(reval_rec.invproc_allocated_amount, 0),
            			       invproc_unbaselined_amount = invproc_unbaselined_amount -
						 NVL(reval_rec.invproc_allocated_amount,0),
     				       revproc_baselined_amount = revproc_baselined_amount +
                                     		NVL(reval_rec.revproc_allocated_amount, 0),
            			       revproc_unbaselined_amount = revproc_unbaselined_amount -
						 NVL(reval_rec.revproc_allocated_amount,0),
            		 	       last_update_date = SYSDATE,
            			       last_updated_by = x_created_by,
	            		       last_update_login = x_last_update_login
     		 		WHERE  project_id = x_project_id
                                AND    agreement_id = reval_rec.agreement_id
                                AND    nvl(task_id,0) = nvl(reval_rec.task_id,0);

                       /* Bug 2602874 Added agreement_id and task_id in where clause as join fields
                          for pa_project_funding and
                          pa_summary_project_funding are agreement_id, project_id, task_id */

		END LOOP;

                /* Moved this code after the updation of spf as otherwise the spf rec will not fetch any record
                   Bug 2547696 */
		 --  baseline funding
     		x_err_stage := 'Revaluation: change draft to baseline <' || to_char(x_project_id)
                        || '>';

               /* Bug 2670854 commented this and moved in the loop above after reading
                  spf but before updating spf

     		UPDATE 	pa_project_fundings
     		  SET  	budget_type_code = 'BASELINE',
            		last_update_date = SYSDATE,
            		last_updated_by = x_created_by,
            		last_update_login = x_last_update_login,
            		pji_summarized_flag  = 'N'  -- For Bug 2244796 and bug 2440676
     		WHERE   project_id = x_project_id
     		  AND   budget_type_code = 'DRAFT'
		  AND   funding_category='REVALUATION';
               */

	-----------------------------------------------------------------------
	-- FP_M Changes
	-- Following IF clause is used only for baselining only required
	-- Project's agreements funding lines
	-----------------------------------------------------------------------
	ELSIF PA_Funding_Core.G_FUND_BASELINE_FLAG = 'Y' THEN
     	  -- update summary funding
     	  x_err_stage := 'update summary funding <' || to_char(x_project_id) || '>';

	  FOR Agreement_rec IN ( SELECT project_funding_id, agreement_id,
	  			        project_id,task_id, projfunc_allocated_amount,
				        invproc_allocated_amount, revproc_allocated_amount
				  FROM  pa_project_fundings
				  WHERE project_id = x_project_id
				    AND budget_type_code ='DRAFT'
				    AND NVL(Submit_Baseline_Flag,'N') = 'Y' )
	  LOOP
		 -- Update the Project fundings for the baselined lines
                 UPDATE pa_project_fundings
                 SET budget_type_code     = 'BASELINE',
                     last_update_date     = SYSDATE,
                     last_updated_by      = x_created_by,
                     last_update_login    = x_last_update_login,
                     pji_summarized_flag  = 'N',  -- For Bug 2244796 and bug 2440676
		     Submit_Baseline_Flag = 'N'
                 WHERE project_funding_id = Agreement_rec.project_funding_id;

		 -- Update the Project summary fundings of  PFC, Invoice and revenue
		 -- baselined and unbaselined amounts
     		 UPDATE pa_summary_project_fundings
     		 SET projfunc_baselined_amount = projfunc_baselined_amount +
                                     NVL(Agreement_rec.projfunc_allocated_amount, 0),
            	     projfunc_unbaselined_amount = projfunc_unbaselined_amount -
		                     NVL(Agreement_rec.projfunc_allocated_amount,0),
     		     invproc_baselined_amount = invproc_baselined_amount +
                                     NVL(Agreement_rec.invproc_allocated_amount, 0),
            	     invproc_unbaselined_amount = invproc_unbaselined_amount -
				     NVL(Agreement_rec.invproc_allocated_amount,0),
     		     revproc_baselined_amount = revproc_baselined_amount +
                                     NVL(Agreement_rec.revproc_allocated_amount, 0),
            	     revproc_unbaselined_amount = revproc_unbaselined_amount -
				     NVL(Agreement_rec.revproc_allocated_amount,0),
            	     last_update_date = SYSDATE,
            	     last_updated_by = x_created_by,
	             last_update_login = x_last_update_login
     		 WHERE  project_id     = x_project_id
                 AND    agreement_id   = Agreement_rec.agreement_id
                 AND    nvl(task_id,0) = nvl(Agreement_rec.task_id,0);

		 -- Unset the global fund baseline flag back to 'N'
		 PA_Funding_Core.G_FUND_BASELINE_FLAG := 'N';

	  END LOOP;

	END IF;
	-- End of FP_M changes
	-----------------------------------------------------------------------

	/*    Release the revenue hold from the realized gains and losses events */

		UPDATE pa_events evt
		   SET evt.revenue_hold_flag ='N'
		WHERE  evt.project_id = x_project_id
		  AND  evt.project_funding_id IS NOT NULL;

     -- update project level funding flag
     update pa_projects_all
     set    project_level_funding_flag = decode(x_funding_level,'P','Y','N'),
            last_update_date = SYSDATE,
            last_updated_by = x_created_by,
            last_update_login = x_last_update_login
     where  project_id = x_project_id;

     x_err_stack := old_stack;
     return;

  exception
      when NO_DATA_FOUND then
	 if non_contract = 0 then
            x_funding_level := l_funding_level; -- NOCOPY
	    x_err_code := sqlcode;
	    return;
	 end if;

      when others then
         x_funding_level := l_funding_level; -- NOCOPY
         x_err_code := SQLCODE;
         return;

  end update_funding;

-----------------------------------------------------------------------------
--
-- History
--	10-SEP-97	jwhite	Added code to
--				address multiple messaging
--

  procedure check_funding_level(
                      x_project_id        in     number,
                      x_funding_level     in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is

     cursor proj is
	select 1
	from   pa_summary_project_fundings
	where  project_id = x_project_id
	and    task_id is null
	and    nvl(total_baselined_amount, 0) + total_unbaselined_amount > 0;

     cursor task is
	select 1
	from   pa_summary_project_fundings
	where  project_id = x_project_id
	and    task_id is not null
	and    nvl(total_baselined_amount, 0) + total_unbaselined_amount > 0;

     cursor proj_zero is

	select 1 from pa_project_fundings
	where  project_id = x_project_id
	and    task_id is null
	having    sum(allocated_amount) = 0;

     cursor task_zero is
	select 1 from pa_project_fundings
        where  project_id = x_project_id
        and    task_id is not null
        having    sum(allocated_amount) = 0;

-- Added cursors project_negation and task_negation for bug 1286536
     cursor project_negation is
        select 1 from pa_summary_project_fundings
         where project_id = x_project_id
           and  task_id is null
           and  total_unbaselined_amount = nvl(total_baselined_amount,0)*(-1)
           and  total_unbaselined_amount <> 0;

     cursor task_negation is
        select 1 from pa_summary_project_fundings
         where project_id = x_project_id
           and  task_id is not null
           and  total_unbaselined_amount = nvl(total_baselined_amount,0)*(-1)
           and  total_unbaselined_amount <> 0;

     old_stack                   varchar2(630);
     proj_rec		number;
     task_rec   	number;
     proj_zero_rec	number;
     task_zero_rec	number;

/* Added recs project_negation_rec and task_negation_rec for bug 1286536 */
     project_negation_rec  number;
     task_negation_rec  number;
     l_funding_level varchar2(1) := x_funding_level;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := 'pa_billing_core->check_funding_level';

     -- set project level funding flag
     x_err_stage := 'Check project level funding flag <'
                        || to_char(x_project_id) || '>';

     open proj;
     fetch proj into proj_rec;
     if proj%notfound then

	close proj;
	open task;
	fetch task into task_rec;
	if task%notfound then

	   close task;
	   open proj_zero;
	   open task_zero;
	   fetch proj_zero into proj_zero_rec;
	   fetch task_zero into task_zero_rec;

	   if proj_zero%found and task_zero%found then
      -- Begin - Addition for bug 1286536
              open project_negation;
              open task_negation;
              fetch project_negation into project_negation_rec;
              fetch task_negation into task_negation_rec;

              if project_negation%found then
                  x_funding_level := 'P';
              elsif task_negation%found then
                  x_funding_level := 'T';
              else
       --  End- Addition for bug 1286536
	      x_err_code := 30;
	      x_err_stage := 'PA_ZERO_PROJ_TASK_DRAFT';

-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );
              end if;
              close project_negation;                       /* Added for bug 1286536 */
              close task_negation;                          /* Added for bug 1286536 */

	   elsif proj_zero%found then
	      x_funding_level := 'P';

	   elsif task_zero%found then
	      x_funding_level := 'T';

	   else
	      -- No positive or zero funding for this project
	      x_err_code := 20;
	      x_err_stage := 'PA_BU_NO_PROJECT_FUNDING';

-- 10-SEP-97, jwhite: multiple messaging
	      PA_UTILS.Add_Message
	      ( p_app_short_name	=> 'PA'
	        , p_msg_name	=> x_err_stage
	       );


	   end if;

	   close proj_zero;
	   close task_zero;

	else
	   x_funding_level := 'T';
           close task;

	end if;

     else
	-- x_funding_level := 'P'; -- FP_M changes
	-- If the Project is implemented with Top Task Customer enabled or
	-- implemented with Top Task invoice method flag then
	-- the default fundling level should be Task level funding
	BEGIN
	  Select 'T' INTO x_funding_level
	  FROM   PA_Projects_All
	  Where  Project_ID = X_Project_ID
	  AND    (ENABLE_TOP_TASK_CUSTOMER_FLAG = 'Y' OR
	          ENABLE_TOP_TASK_INV_MTH_FLAG  = 'Y' );
          Exception When NO_Data_Found then
	       x_funding_level := 'P';
	END;
	close proj;

     end if;

  exception
     when others then
	x_err_code := sqlcode;
        x_funding_level := l_funding_level;
-- 10-SEP-97, jwhite: multiple messaging
	FND_MSG_PUB.Add_Exc_Msg
		(  p_pkg_name		=> 'PA_BILLING_CORE'
		,  p_procedure_name	=> 'CHECK_FUNDING_LEVEL'
		,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                             );
	return;

  end check_funding_level;

-----------------------------------------------------------------------------

/* Modified to include MCB2 columns
   owning_organization_id, agreement_currency_code */
  procedure copy_agreement(
                      x_orig_project_id   in     number,
                      x_new_project_id    in     number,
		      x_customer_id	  in	 number,
		      x_owning_organization_id	  in	 number default null,
		      x_agreement_currency_code	  in	 varchar2 default null,
		      x_amount	          in	 number default null,
		      x_template_flag	  in	 varchar2,
		      x_delta		  in	 number,
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack		varchar2(630);
     x_agreement_id	number;
     l_funding_level    varchar2(1);
    l_amount    number;

     l_fund_exists varchar2(1) := 'N';
     l_err_code NUMBER := null;
     l_err_stage varchar2(250) := null;
     l_err_stack varchar2(250) := null;
     l_funding_count NUMBER := 0;

  begin

     x_err_code := 0;
     old_stack := x_err_stack;
     x_err_stack := 'pa_billing_core->copy_agreement';

     x_err_stage := 'check proj/task level funding ';


   /* Check if any funding exists at all */

        begin
            select 'Y' into l_fund_exists
            from   pa_summary_project_fundings
            where  project_id = x_orig_project_id
            and    nvl(total_baselined_amount, 0) + total_unbaselined_amount > 0;

        exception

             when no_data_found then

                 l_fund_exists := 'N';
             when others then null;
        end;


        if l_fund_exists = 'N' then

           return;

        end if;

/* MCB2 code begins  check proj/task level funding */

     check_funding_level(
          x_project_id  => x_orig_project_id ,
          x_funding_level => l_funding_level ,
          x_err_code      => l_err_code,
          x_err_stage     => l_err_stage,
          x_err_stack     => l_err_stack );


     r_amount := NULL;   /* Added for bug 2913524 */

     if l_err_code = 0 then

        if l_funding_level = 'P' THEN
           l_amount := x_amount; /* if proj level funding use input amount */

           /* Code fix for bug 2913524 starts here*/

	   r_amount := x_amount;

	   SELECT count(*)
	   INTO	  l_funding_count
	   FROM	  pa_project_fundings
           WHERE  project_id = x_orig_project_id;

           /* Code fix for bug 2913524 ends here*/
        elsif l_funding_level = 'T' THEN
           l_amount := null;  /* if task level funding use amount from template project */
        end if;
     else

        if (l_err_code <> 20 AND l_err_code <> 30) then

            x_err_code  :=  l_err_code;
            x_err_stage :=  l_err_stage;
            x_err_stack :=  l_err_stack ;

        end if;

        return;

     end if;


/* MCB2 code ends  */

     x_err_stage := 'Get next agreement id.';

     select pa_agreements_s.nextval
     into   x_agreement_id
     from   dual;

     -- dbms_output.put_line('x_agreement_id = '||to_char(x_agreement_id));
     x_err_stage := 'Insert into pa_agreements.';

     INSERT INTO PA_AGREEMENTS_ALL(
              agreement_id,
              customer_id,
              agreement_num,
              agreement_type,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              owned_by_person_id,
              term_id,
              revenue_limit_flag,
              amount,
              description,
              expiration_date,
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
              template_flag,
              agreement_currency_code, /* MCB2 column begins */
              owning_organization_id,
              invoice_limit_flag, /* MCB2 column ends */
	      org_id)
     SELECT   x_agreement_id,
	      nvl(x_customer_id, a.customer_id),
	      p.segment1,
	      a.agreement_type,
	      sysdate,
	      fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
	      fnd_global.login_id,
	      a.owned_by_person_id,
              a.term_id,
              a.revenue_limit_flag,
              nvl(l_amount, a.amount), /* MCB2 change */
              a.description,
              decode(a.expiration_date, null, null,
			a.expiration_date + nvl(x_delta, 0)),
              a.attribute_category,
              a.attribute1,
              a.attribute2,
              a.attribute3,
              a.attribute4,
              a.attribute5,
              a.attribute6,
              a.attribute7,
              a.attribute8,
              a.attribute9,
              a.attribute10,
	      x_template_flag,
/* MCB2 columns begin */
              nvl(x_agreement_currency_code,a.agreement_currency_code),
              nvl(x_owning_organization_id,a.owning_organization_id),
              a.invoice_limit_flag,
	      mo_global.get_current_org_id
/* MCB2 columns end */
       FROM   pa_agreements_all a, pa_projects_all p
      WHERE   p.project_id = x_new_project_id
/* Bug 727421 Performance Issue
	AND exists
	   (select null
	    from pa_project_customers c2, pa_project_fundings f
	    where f.project_id = x_orig_project_id
	    and f.agreement_id = a.agreement_id
	    and c2.project_id = x_orig_project_id
	    and c2.customer_bill_split = 100
	    and c2.customer_id = a.customer_id);
*/
      AND     A.agreement_id IN
              (SELECT F.agreement_id from pa_summary_project_fundings F
              WHERE F.project_id = x_orig_project_id)
      AND exists
           (select null
            from pa_project_customers c2
            where c2.project_id = x_orig_project_id
            -- and nvl(c2.customer_bill_split,0) = 100
	    -- FP_M changes
	    -- If the project is implemented with Top Task Customer then
	    -- assume the bill split is 100%
            and nvl(c2.customer_bill_split,0) =
	      Decode(c2.Default_Top_Task_Cust_Flag, 'Y', 0, 100)
            and c2.customer_id = A.customer_id);

     x_err_stage := 'Call pa_billing_core.copy_funding.';

/* Code fix for bug 2913524 Starts Here */
	IF (l_funding_level = 'P' AND x_amount IS NOT NULL AND l_funding_count <> 1 ) THEN
	     NULL;
	ELSE
/* Code fix for bug 2913524 Ends Here */
	     pa_billing_core.copy_funding(
			x_orig_project_id,
			x_new_project_id,
			x_agreement_id,
			x_delta,
			x_err_code,
			x_err_stage,
			x_err_stack);
	END IF;      -- Added for bug 2913524

     if x_err_code <> 0 then
	return;
     end if;

     x_err_stack := old_stack;

  exception
    when NO_DATA_FOUND then
	x_err_code := 100;
	return;

    when others then
        x_err_code := sqlcode;
	return;

  end copy_agreement;

-----------------------------------------------------------------------------

  procedure copy_funding(
                      x_orig_project_id   in     number,
                      x_new_project_id    in     number,
		      x_agreement_id	  in	 number,
                      x_delta             in     number,
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
     old_stack	varchar2(630);
     proj	number := 0;

/* MCB2 code begins */
        l_funding_currency_code         VARCHAR2(15);
        l_allocated_amount              number;

        l_project_currency_code         VARCHAR2(15);
        l_project_rate_type             VARCHAR2(30);
        l_project_rate_date             DATE;
        l_project_exchange_rate         NUMBER;
        l_project_allocated_amount      NUMBER;

        l_projfunc_currency_code        VARCHAR2(15);
        l_projfunc_rate_type            VARCHAR2(30);
        l_projfunc_rate_date            DATE;
        l_projfunc_exchange_rate        NUMBER;
        l_projfunc_allocated_amount     NUMBER;

        l_invproc_currency_code         VARCHAR2(15);
        l_invproc_rate_type             VARCHAR2(30);
        l_invproc_rate_date             DATE;
        l_invproc_exchange_rate         NUMBER;
        l_invproc_allocated_amount      NUMBER;

        l_revproc_currency_code         VARCHAR2(15);
        l_revproc_rate_type             VARCHAR2(30);
        l_revproc_rate_date             DATE;
        l_revproc_exchange_rate         NUMBER;
        l_revproc_allocated_amount      NUMBER;

        l_err_stage                        VARCHAR2(50);
        l_err_code                      NUMBER;

/* MCB2 code ends  */

/* Commented for bug 5140179
     cursor c is
	select 1
	from   pa_project_fundings
	where  project_id = x_orig_project_id
	and    task_id is null;*/

/* MCB2 code begins  */
     cursor tmp_proj_funding is
       SELECT pa_project_fundings_s.nextval project_funding_id ,
	      sysdate last_update_date, fnd_global.user_id last_updated_by,
              sysdate creation_date, fnd_global.user_id created_by,
              fnd_global.login_id last_update_login,
	      x_agreement_id agreement_id, x_new_project_id project_id,
	      NULL task_id, 'DRAFT' budget_type_code,
/*               l_allocated_amount allocated_amount, Commented code for bug 2793120 */
	      NVL(r_amount,f.allocated_amount) allocated_amount, /* Added for bug 2793120 */ /* Modified for bug 2913524 */
              f.date_allocated + nvl(x_delta, 0) date_allocated,
              f.attribute_category attribute_category,
              f.attribute1 attribute1,
              f.attribute2 attribute2,
              f.attribute3 attribute3,
              f.attribute4 attribute4,
              f.attribute5 attribute5,
              f.attribute6 attribute6,
              f.attribute7 attribute7,
              f.attribute8 attribute8,
              f.attribute9 attribute9,
              f.attribute10 attribute10,
              l_funding_currency_code funding_currency_code,
              f.funding_category     /* For Bug 2244796 */
         FROM pa_project_fundings f
        WHERE f.project_id = x_orig_project_id
	  AND f.task_id is null ;/*Added for bug 5140179*/
/*
	  AND exists(
		select null
		from pa_agreements
		where agreement_id = x_agreement_id);
*/

      proj_rec tmp_proj_funding%ROWTYPE;

     cursor tmp_task_funding is
       SELECT pa_project_fundings_s.nextval project_funding_id ,
              sysdate last_update_date, fnd_global.user_id last_updated_by,
              sysdate creation_date, fnd_global.user_id created_by,
              fnd_global.login_id last_update_login,
              x_agreement_id agreement_id, x_new_project_id project_id,
              t2.task_id task_id,  'DRAFT' budget_type_code,
              f.allocated_amount allocated_amount,
              f.date_allocated + nvl(x_delta, 0) date_allocated,
              f.attribute_category attribute_category,
              f.attribute1 attribute1,
              f.attribute2 attribute2,
              f.attribute3 attribute3,
              f.attribute4 attribute4,
              f.attribute5 attribute5,
              f.attribute6 attribute6,
              f.attribute7 attribute7,
              f.attribute8 attribute8,
              f.attribute9 attribute9,
              f.attribute10 attribute10,
              l_funding_currency_code funding_currency_code,
              f.funding_category   /*  For Bug 2244796 */
         FROM pa_tasks t2, pa_tasks t, pa_project_fundings f
        WHERE f.project_id = x_orig_project_id
	  AND t.project_id = f.project_id
	  AND t.task_id = f.task_id
	  AND t2.task_number = t.task_number
	  AND t2.project_id = x_new_project_id;
/*
	  AND exists(
                select null
                from pa_agreements
                where agreement_id = x_agreement_id);
*/
      task_rec tmp_task_funding%ROWTYPE;

/* MCB2 code ends  */
  begin

     old_stack := x_err_stack;
     x_err_stack := 'pa_billing_core->copy_funding';

     x_err_code := 0;
     x_err_stage := 'Get agreement currency ';

     /* dbms_output.put_line(' in copy fund x_agreement_id = '||
                               to_char(x_agreement_id));
     */

     select agreement_currency_code, amount
     into l_funding_currency_code, l_allocated_amount
     from pa_agreements_all
     where agreement_id = x_agreement_id;

     /*
     dbms_output.put_line(' in copy fund agreement_curr = '||
                            l_funding_currency_code);
     */

     /* Commented for bug 5140179
     open c;
     fetch c into proj;
     close c;

     if proj = 1 then */

       x_err_stage := 'Get funding template values PROJ ';

       OPEN tmp_proj_funding;

       LOOP
          FETCH tmp_proj_funding into proj_rec;
          EXIT when tmp_proj_funding%NOTFOUND or x_err_code <> 0;

          x_err_stage := 'Get values for MCB2 columns ';

          pa_funding_core.get_MCB2_attributes(
            p_project_id                   =>   proj_rec.project_id,
            p_agreement_id                 =>   proj_rec.agreement_id,
            p_date_allocated               =>   proj_rec.date_allocated,
            p_allocated_amount             =>   proj_rec.allocated_amount,
            p_funding_currency_code        =>   proj_rec.funding_currency_code,
            p_project_currency_code        =>   l_project_currency_code,
            p_project_rate_type            =>   l_project_rate_type,
            p_project_rate_date            =>   l_project_rate_date,
            p_project_exchange_rate        =>   l_project_exchange_rate,
            p_project_allocated_amount     =>   l_project_allocated_amount,
            p_projfunc_currency_code       =>   l_projfunc_currency_code,
            p_projfunc_rate_type           =>   l_projfunc_rate_type,
            p_projfunc_rate_date           =>   l_projfunc_rate_date,
            p_projfunc_exchange_rate       =>   l_projfunc_exchange_rate,
            p_projfunc_allocated_amount    =>   l_projfunc_allocated_amount,
            p_invproc_currency_code        =>   l_invproc_currency_code,
            p_invproc_rate_type            =>   l_invproc_rate_type,
            p_invproc_rate_date            =>   l_invproc_rate_date,
            p_invproc_exchange_rate        =>   l_invproc_exchange_rate,
            p_invproc_allocated_amount     =>   l_invproc_allocated_amount,
            p_revproc_currency_code        =>   l_revproc_currency_code,
            p_revproc_rate_type            =>   l_revproc_rate_type,
            p_revproc_rate_date            =>   l_revproc_rate_date,
            p_revproc_exchange_rate        =>   l_revproc_exchange_rate,
            p_revproc_allocated_amount     =>   l_revproc_allocated_amount,
            p_validate_parameters          =>   'N',
            x_err_code                     =>   l_err_code,
            x_err_msg                      =>   l_err_stage
            );

          x_err_code :=  l_err_code;
          x_err_stage := l_err_stage;

          if x_err_code = 0 then

             x_err_stage := 'Insert into pa_project_fundings';

             INSERT INTO pa_project_fundings(
                           project_funding_id,
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by,
                           last_update_login,
                           agreement_id,
                           project_id,
                           task_id,
                           budget_type_code,
                           allocated_amount,
                           date_allocated,
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
                           funding_currency_code,
                           project_currency_code,
                           project_rate_type,
                           project_rate_date,
                           project_exchange_rate,
                           project_allocated_amount,
                           projfunc_currency_code,
                           projfunc_rate_type,
                           projfunc_rate_date,
                           projfunc_exchange_rate,
                           projfunc_allocated_amount,
                           invproc_currency_code,
                           invproc_rate_type,
                           invproc_rate_date,
                           invproc_exchange_rate,
                           invproc_allocated_amount,
                           revproc_currency_code,
                           revproc_rate_type,
                           revproc_rate_date,
                           revproc_exchange_rate,
                           revproc_allocated_amount,
                           funding_category    /* For Bug2244796 */
                           )
          VALUES
             ( proj_rec.project_funding_id,
               proj_rec.last_update_date,
               proj_rec.last_updated_by,
               proj_rec.creation_date,
               proj_rec.created_by,
               proj_rec.last_update_login,
               proj_rec.agreement_id,
               proj_rec.project_id,
               proj_rec.task_id,
               proj_rec.budget_type_code,
               proj_rec.allocated_amount,
               proj_rec.date_allocated,
               proj_rec.attribute_category,
               proj_rec.attribute1,
               proj_rec.attribute2,
               proj_rec.attribute3,
               proj_rec.attribute4,
               proj_rec.attribute5,
               proj_rec.attribute6,
               proj_rec.attribute7,
               proj_rec.attribute8,
               proj_rec.attribute9,
               proj_rec.attribute10,
               proj_rec.funding_currency_code,
               l_project_currency_code,
               l_project_rate_type,
               l_project_rate_date,
               l_project_exchange_rate,
               l_project_allocated_amount,
               l_projfunc_currency_code,
               l_projfunc_rate_type,
               l_projfunc_rate_date,
               l_projfunc_exchange_rate,
               l_projfunc_allocated_amount,
               l_invproc_currency_code,
               l_invproc_rate_type,
               l_invproc_rate_date,
               l_invproc_exchange_rate,
               l_invproc_allocated_amount,
               l_revproc_currency_code,
               l_revproc_rate_type,
               l_revproc_rate_date,
               l_revproc_exchange_rate,
               l_revproc_allocated_amount,
               proj_rec.funding_category    /* For Bug 2244796  */
              );

           end if;

       END LOOP;
       CLOSE tmp_proj_funding;

     /* else-- Task level funding Commented for bug 5140179*/

       x_err_stage := 'Get funding template values TASK ';

       OPEN tmp_task_funding;

       LOOP

          FETCH tmp_task_funding into task_rec;
          EXIT when tmp_task_funding%NOTFOUND or x_err_code <> 0;

          x_err_stage := 'Get values for MCB2 columns ';

          pa_funding_core.get_MCB2_attributes(
            p_project_id                   =>   task_rec.project_id,
            p_agreement_id                 =>   task_rec.agreement_id,
            p_date_allocated               =>   task_rec.date_allocated,
            p_allocated_amount             =>   task_rec.allocated_amount,
            p_funding_currency_code        =>   task_rec.funding_currency_code,
            p_project_currency_code        =>   l_project_currency_code,
            p_project_rate_type            =>   l_project_rate_type,
            p_project_rate_date            =>   l_project_rate_date,
            p_project_exchange_rate        =>   l_project_exchange_rate,
            p_project_allocated_amount     =>   l_project_allocated_amount,
            p_projfunc_currency_code       =>   l_projfunc_currency_code,
            p_projfunc_rate_type           =>   l_projfunc_rate_type,
            p_projfunc_rate_date           =>   l_projfunc_rate_date,
            p_projfunc_exchange_rate       =>   l_projfunc_exchange_rate,
            p_projfunc_allocated_amount    =>   l_projfunc_allocated_amount,
            p_invproc_currency_code        =>   l_invproc_currency_code,
            p_invproc_rate_type            =>   l_invproc_rate_type,
            p_invproc_rate_date            =>   l_invproc_rate_date,
            p_invproc_exchange_rate        =>   l_invproc_exchange_rate,
            p_invproc_allocated_amount     =>   l_invproc_allocated_amount,
            p_revproc_currency_code        =>   l_revproc_currency_code,
            p_revproc_rate_type            =>   l_revproc_rate_type,
            p_revproc_rate_date            =>   l_revproc_rate_date,
            p_revproc_exchange_rate        =>   l_revproc_exchange_rate,
            p_revproc_allocated_amount     =>   l_revproc_allocated_amount,
            p_validate_parameters          =>   'N',
            x_err_code                     =>   l_err_code,
            x_err_msg                      =>   l_err_stage
            );

          x_err_code :=  l_err_code;
          x_err_stage := l_err_stage;

          if x_err_code = 0 then

             x_err_stage := 'Insert into pa_project_fundings';

             INSERT INTO pa_project_fundings(
              project_funding_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              agreement_id,
              project_id,
              task_id,
              budget_type_code,
              allocated_amount,
              date_allocated,
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
              funding_currency_code,
              project_currency_code,
              project_rate_type,
              project_rate_date,
              project_exchange_rate,
              project_allocated_amount,
              projfunc_currency_code,
              projfunc_rate_type,
              projfunc_rate_date,
              projfunc_exchange_rate,
              projfunc_allocated_amount,
              invproc_currency_code,
              invproc_rate_type,
              invproc_rate_date,
              invproc_exchange_rate,
              invproc_allocated_amount,
              revproc_currency_code,
              revproc_rate_type,
              revproc_rate_date,
              revproc_exchange_rate,
              revproc_allocated_amount,
              funding_category     /*  For Bug2244796 */
              )
          VALUES
             ( task_rec.project_funding_id,
               task_rec.last_update_date,
               task_rec.last_updated_by,
               task_rec.creation_date,
               task_rec.created_by,
               task_rec.last_update_login,
               task_rec.agreement_id,
               task_rec.project_id,
               task_rec.task_id,
               task_rec.budget_type_code,
               task_rec.allocated_amount,
               task_rec.date_allocated,
               task_rec.attribute_category,
               task_rec.attribute1,
               task_rec.attribute2,
               task_rec.attribute3,
               task_rec.attribute4,
               task_rec.attribute5,
               task_rec.attribute6,
               task_rec.attribute7,
               task_rec.attribute8,
               task_rec.attribute9,
               task_rec.attribute10,
               task_rec.funding_currency_code,
               l_project_currency_code,
               l_project_rate_type,
               l_project_rate_date,
               l_project_exchange_rate,
               l_project_allocated_amount,
               l_projfunc_currency_code,
               l_projfunc_rate_type,
               l_projfunc_rate_date,
               l_projfunc_exchange_rate,
               l_projfunc_allocated_amount,
               l_invproc_currency_code,
               l_invproc_rate_type,
               l_invproc_rate_date,
               l_invproc_exchange_rate,
               l_invproc_allocated_amount,
               l_revproc_currency_code,
               l_revproc_rate_type,
               l_revproc_rate_date,
               l_revproc_exchange_rate,
               l_revproc_allocated_amount,
               task_rec.funding_category   /* For Bug 2244796  */
              );

          end if;

       END LOOP;
       CLOSE tmp_task_funding;

     /*end if; Commented for bug 5140179*/

     if x_err_code = 0 then

        x_err_stage := 'Insert or update pa_summary_project_fundings';

        INSERT INTO pa_summary_project_fundings(
	      agreement_id,
	      project_id,
	      task_id,
	      total_baselined_amount,
	      total_unbaselined_amount,
	      total_accrued_amount,
	      total_billed_amount,
	      last_update_login,
	      last_update_date,
	      last_updated_by,
	      creation_date,
	      created_by,
              funding_currency_code,
              project_currency_code, project_baselined_amount,
              project_unbaselined_amount, project_accrued_amount,
              project_billed_amount,
              projfunc_currency_code, projfunc_baselined_amount,
              projfunc_unbaselined_amount, projfunc_accrued_amount,
              projfunc_billed_amount,
              invproc_currency_code, invproc_baselined_amount,
              invproc_unbaselined_amount,
              invproc_billed_amount,
              revproc_currency_code, revproc_baselined_amount,
              revproc_unbaselined_amount, revproc_accrued_amount)
     SELECT   agreement_id,
	      project_id,
	      task_id,
	      0,
	      nvl(sum(nvl(allocated_amount, 0)), 0),
	      0, 0,
              fnd_global.login_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              funding_currency_code,
              project_currency_code,
              0,
	      nvl(sum(nvl(project_allocated_amount, 0)), 0),
	      0, 0,
              projfunc_currency_code,
              0,
	      nvl(sum(nvl(projfunc_allocated_amount, 0)), 0),
	      0, 0,
              invproc_currency_code,
              0,
	      nvl(sum(nvl(invproc_allocated_amount, 0)), 0),
	      0,
              revproc_currency_code,
              0,
	      nvl(sum(nvl(revproc_allocated_amount, 0)), 0),
	      0
       FROM   pa_project_fundings
      WHERE   project_id = x_new_project_id
      GROUP BY agreement_id, project_id, task_id, funding_currency_code,
               project_currency_code, projfunc_currency_code,
               invproc_currency_code, revproc_currency_code ;

     end if;

     x_err_stack := old_stack;

  exception
    when others then
        -- dbms_output.put_line ( 'in copy funding' || x_err_stage);
	x_err_code := sqlcode;
        x_err_stage := sqlerrm;
        return;

  end copy_funding;
-----------------------------------------------------------------------------
--
-- History
--      10-Nov-02       johnson  Added code
-- This function to check the funding exists or not
-- while create projects
-- This will be called only if project creation creates agreements

Function check_funding_exists( x_project_id        in     number) return varchar2 IS

l_fund_exists  	varchar2(2):='N';

  BEGIN

	BEGIN
            select 'Y' into l_fund_exists
            from  dual
	    where exists(select null
			   from  pa_summary_project_fundings spf
                          where  spf.project_id = x_project_id);

  	EXCEPTION
    	WHEN no_data_found THEN
	 	l_fund_exists := 'N';

    	WHEN others THEN
	 	l_fund_exists := 'N';

        END;

	RETURN l_fund_exists;

  END check_funding_exists;

  -- These changes are made for FP_M
   -- Function to check whether Top Task Customer Flag at project level
   -- can be updateable
  Function Update_Top_Task_Cust_Flag (
		      P_Project_ID	IN	Number
  ) Return Varchar2 IS
       l_Exist_Flag 		VARCHAR2(1);
       l_Funding_Level_Flag	VARCHAR2(1);
       l_Check_Next_Condition	VARCHAR2(1) :='N'; /*bug 3638361 */

  BEGIN
    -- Get the funding level value
    BEGIN
      Select Project_Level_Funding_Flag
      INTO  l_Funding_Level_Flag
      FROM   PA_Projects_All
      Where  Project_ID = P_Project_ID;
      Exception When NO_Data_Found then
        l_Funding_Level_Flag := 'P';
    END;

    begin
      Select 'N'
      Into   l_Exist_Flag
      from dual
      where exists ( select null
                     From   PA_Project_Fundings
                     Where  Project_ID = P_Project_ID
                     and budget_type_code = 'DRAFT');

      Return l_Exist_Flag;

    Exception
        When Others then
             l_Check_Next_Condition := 'Y';
    end;

    begin
      Select 'N'
      Into   l_Exist_Flag
      From   PA_summary_Project_Fundings
      Where  Project_ID = P_Project_ID
      HAVING ( sum(nvl(Total_Baselined_Amount,0)) > 0 OR sum(nvl(Total_Unbaselined_Amount,0)) > 0 );

      Return l_Exist_Flag;

    Exception
        When Others then
              l_Check_Next_Condition := 'Y';
    end;

    -- If the project funding level is "Project".
    If l_Check_Next_Condition = 'Y' AND l_Funding_Level_Flag = 'P' Then
       Return 'N';
    Else
       Return 'Y';
    END IF;

  END Update_Top_Task_Cust_Flag;

  -- Function to check whether Top Task Invoice Method Flag at project level
  -- can be updateable
  Function Update_Top_Task_Inv_Mthd_Flag (
		      P_Project_ID	IN	Number
  ) Return Varchar2
  IS
  l_Exist_Flag 		VARCHAR2(1);
  l_Funding_Level_Flag	VARCHAR2(1);
  l_Check_Next_Condition	VARCHAR2(1) :='N'; /*bug 3638361 */
  BEGIN
    -- Get the funding level value
    BEGIN

      Select Project_Level_Funding_Flag
      INTO   l_Funding_Level_Flag
      FROM   PA_Projects_All
      Where  Project_ID = P_Project_ID;

    Exception When NO_Data_Found then
        l_Funding_Level_Flag := 'P';
    END;


    begin
    -- Case 1 : If it has any project level unbaselined funding
      Select 'N'
      Into   l_Exist_Flag
      from dual
      where exists ( select null
                     From   PA_Project_Fundings
                     Where  Project_ID = P_Project_ID
                     and    Task_ID IS NULL
                     and budget_type_code = 'DRAFT');

      Return l_Exist_Flag;

    Exception
        When Others then
             l_Check_Next_Condition := 'Y';
    end;


    -- Fix for bug 3601308
    -- Case 1 : If it has any project level funding (baselined or unbaselined)
    begin
      Select 'N'
      Into   l_Exist_Flag
      From   PA_Summary_Project_Fundings
      Where  Project_ID = P_Project_ID
      and    Task_ID IS NULL
      HAVING ( sum(Total_Baselined_Amount) > 0 OR sum(Total_Unbaselined_Amount) > 0 );

      Return l_Exist_Flag;

      Exception When Others then
	l_Check_Next_Condition := 'Y';
    end;


    -- Case 2 : If it has task level funding and it's billed
    IF l_Check_Next_Condition = 'Y' THEN
      begin

	l_Check_Next_Condition := 'N'; --Added for bug3703094
        Select 'N'
        Into   l_Exist_Flag
        From   PA_Summary_Project_Fundings
        Where  Project_ID = P_Project_ID
        and    Task_ID IS NOT NULL
        HAVING sum(Total_Billed_Amount) > 0;

        Return l_Exist_Flag;

      Exception When Others then
	  l_Check_Next_Condition := 'Y';
      end;
    END IF;

    -- Case 3 : If the project funding level is "Project".
    If l_Check_Next_Condition = 'Y' AND l_Funding_Level_Flag = 'P' Then
       Return 'N';
    Else
       Return 'Y';
    END IF;

  END Update_Top_Task_Inv_Mthd_Flag;

  -- Function to check whether the combination of Invoice and Revenue
  -- methods are existing in Project Type distribution rules or not
  Function Check_Revenue_Invoice_Methods (
		      P_Project_ID	IN	Number
  ) Return Varchar2
  IS
  l_Exist_Flag varchar2(1);
  BEGIN

    begin
     /* Select 'N'
      Into   l_Exist_Flag
      From   PA_Summary_Project_Fundings
      Where  Project_ID = P_Project_ID
      HAVING ( sum(Total_Billed_Amount) > 0 OR
               sum(Total_Accrued_Amount) > 0 ); --Added for Bug3729634 */
      /* commented above and added below for bug 8683074  */
      Select 'N'
      Into   l_Exist_Flag
      From   dual
      Where  exists
      ( select 1 from pa_draft_revenue_items
        where project_id = P_Project_ID
        group by nvl(task_id,-99)
        having sum(Amount) <> 0
        Union all
        select 1 from pa_draft_invoice_items
        where project_id = P_Project_ID
        group by nvl(task_id,-99)
        having sum(Amount) <> 0 );

      Exception When Others then
	l_Exist_Flag := 'Y';
    end;
    Return l_Exist_Flag;

  END Check_Revenue_Invoice_Methods;

  -- Check required at Top Task level
  -- Function to check whether Top Task Customer can be updateable
  -- at Task level window
  Function Update_Top_Task_Customer (
		      P_Project_ID	IN	Number,
		      P_Task_ID		IN	Number
  ) Return Varchar2
  IS
  l_Exist_Flag varchar2(1);
  BEGIN

    begin
      Select 'N'
      Into   l_Exist_Flag
      from dual
      where exists ( select null
                     From   PA_Project_Fundings
                     Where  Project_ID = P_Project_ID
                     AND    Task_ID    = P_Task_ID
                     and budget_type_code = 'DRAFT');

      Return l_Exist_Flag;

    Exception
        When Others then
             null;
    end;


    begin
      Select 'N'
      Into   l_Exist_Flag
      From   PA_Summary_Project_Fundings
      Where  Project_ID = P_Project_ID
      AND    Task_ID    = P_Task_ID
      HAVING (sum(Total_Baselined_Amount) <> 0
             OR sum(Total_UnBaselined_Amount) <> 0
             OR sum(Total_Accrued_Amount)<>0     /* added for bug 7291160 */
	           OR sum(Total_Billed_Amount)<>0     /* added for bug 7291160 */
	         )
      ;
      Return l_Exist_Flag;

      Exception When Others then
	NULL; /* Modified fix for bug 7437739 */
    end;

    /* Fix for bug 7437739  starts here*/
    begin
	select 'N'
	into   l_Exist_Flag
	from dual
	where exists (select 1
	from pa_expenditure_items_all ei, pa_tasks pt
	where ei.task_id = pt.task_id
	and pt.top_task_id = P_Task_ID
	and pt.project_id = P_Project_ID
	and (NVL(accrued_revenue,0) <> 0 or NVL(bill_amount,0) <> 0)
	and ei.net_zero_adjustment_flag = 'N');

      Return l_Exist_Flag;
    Exception
        When Others then
             NULL;
    end;

    begin

	select 'N'
	into   l_Exist_Flag
	from dual where exists (select 1
	from pa_expenditure_items_all ei, pa_tasks pt
	where ei.task_id = pt.task_id
	and pt.top_task_id = P_Task_ID
	and pt.project_id = P_Project_ID
	and (( NVL(ei.accrued_revenue,0) + NVL((select ei1.accrued_revenue
		from pa_expenditure_items_all ei1 where ei1.expenditure_item_id = ei.adjusted_expenditure_item_id),0) <> 0)
              or
	      ( NVL(ei.bill_amount,0) + NVL((select ei2.bill_amount
		from pa_expenditure_items_all ei2 where ei2.expenditure_item_id = ei.adjusted_expenditure_item_id),0) <> 0))
	and   ei.adjusted_expenditure_item_id IS NOT NULL
	and ei.net_zero_adjustment_flag = 'Y');

      Return l_Exist_Flag;

    Exception
	When Others then
		NULL;
    end;

 /* Fix for bug 7437739  ends here*/

   Return 'Y'; --Modified for bug 7437739


  END Update_Top_Task_Customer;

  -- Function to check whether Top Task Invoice Method can be updateable
  -- at Task level window
  Function Update_Top_Task_Invoice_Method (
		      P_Project_ID	IN	Number,
		      P_Task_ID		IN	Number
  ) Return Varchar2
  IS
  l_Exist_Flag varchar2(1);
  BEGIN
    begin
      Select 'N'
      Into   l_Exist_Flag
      From   PA_Summary_Project_Fundings
      Where  Project_ID = P_Project_ID
      AND    Task_ID    = P_Task_ID
      HAVING sum(Total_Billed_Amount) > 0;
      Exception When Others then
	l_Exist_Flag := 'Y';
    end;
    Return l_Exist_Flag;

  END Update_Top_Task_Invoice_Method;

end pa_billing_core ;

/
