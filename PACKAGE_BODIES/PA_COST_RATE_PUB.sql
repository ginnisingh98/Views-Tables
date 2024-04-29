--------------------------------------------------------
--  DDL for Package Body PA_COST_RATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_RATE_PUB" AS
/* $Header: PAXPCRTB.pls 120.5.12010000.5 2009/05/22 09:14:21 paljain ship $ */

-- Start of comments
--	API name 	: get_labor_rate
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Returns Labor Cost Rate for an Employee.
--	Parameters	: Person Id, Transaction Date. Organization Id and Job Id are optional.
--	IN		:	p_person_id           	IN NUMBER        Required
--                                      Id of the person for whom the rate is to be found.
--                              p_txn_date              IN DATE          Required
--                                      The Date on which the rate is required.
--                              x_organization_id       IN NUMBER        Optional
--                                      Organization to which the transaction is charged to.
--                              p_org_id                IN NUMBER        Optional
--                                      Expenditure Org Id of the transaction
--                              x_job_id                IN NUMBER        Optional
--                                      Job of the person.
--	Version	: Current version	1.0
--			  Initial version 	1.0
-- End of comments
procedure get_labor_rate ( p_person_id                  IN per_all_people_f.person_id%TYPE
                          ,p_txn_date                   IN date
                          ,p_calling_module             IN varchar2 default 'STAFFED'
                          ,p_org_id                     IN pa_expenditures_all.org_id%TYPE default NULL  /*2879644*/
                          ,x_job_id                     IN OUT NOCOPY pa_expenditure_items_all.job_id%TYPE
                          ,x_organization_id            IN OUT NOCOPY pa_expenditures_all.incurred_by_organization_id%TYPE
                          ,x_cost_rate                  OUT NOCOPY pa_bill_rates_all.rate%TYPE
                          ,x_start_date_active          OUT NOCOPY date
                          ,x_end_date_active            OUT NOCOPY date
                          ,x_org_labor_sch_rule_id      OUT NOCOPY pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE
                          ,x_costing_rule               OUT NOCOPY pa_compensation_rule_sets.compensation_rule_set%TYPE
                          ,x_rate_sch_id                OUT NOCOPY pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE
                          ,x_cost_rate_curr_code        OUT NOCOPY gl_sets_of_books.currency_code%TYPE
                          ,x_acct_rate_type             OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE
                          ,x_acct_rate_date_code        OUT NOCOPY pa_implementations_all.acct_rate_date_code%TYPE
                          ,x_acct_exch_rate             OUT NOCOPY pa_org_labor_sch_rule.acct_exchange_rate%TYPE
                          ,x_ot_project_id              OUT NOCOPY pa_projects_all.project_id%TYPE
                          ,x_ot_task_id                 OUT NOCOPY pa_tasks.task_id%TYPE
                          ,x_err_stage                  OUT NOCOPY number
                          ,x_err_code                   OUT NOCOPY varchar2
                          ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                         )
is

    USER_EXCEPTION EXCEPTION;

    l_debug_mode varchar2(1);
    l_stage varchar2(300);
    l_use_cache varchar2(1);
    l_num_dummy pa_expenditure_items_all.expenditure_item_id%TYPE;

    l_override_flag varchar2(1) := 'N' ;
    l_override_type            pa_compensation_details.override_type%TYPE;
    l_sch_type                 pa_std_bill_rate_schedules_all.schedule_type%TYPE;
    l_job_group_id             pa_std_bill_rate_schedules_all.job_group_id%TYPE;
    l_dest_job_id              pa_bill_rates_all.job_id%TYPE;
    l_costing_method           pa_compensation_rule_sets.costing_method%TYPE;
    l_curr_org_id              pa_expenditures_all.org_id%TYPE;		/* Added for bug 7365397 */

begin

----------------- initializaton ------------------------------
    if pa_cc_utils.g_debug_mode then
      l_debug_mode := 'Y';
    else
      l_debug_mode := 'N';
    end if;



	l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   IF ( l_debug_mode = 'Y' ) THEN
    pa_debug.set_process( x_process    => 'PLSQL'
                         ,x_debug_mode => l_debug_mode
                        );
    pa_cc_utils.set_curr_function('PA_COST_RATE_PUB.get_labor_rate');
    -- pa_cc_utils.log_message('Start ');
   END IF;

         l_stage := 'Input person_id [' || to_char(p_person_id) || '] job_id ['
                                  || to_char(x_job_id) || '] txn_date ['
                                  || to_char(p_txn_date) || '] organization_id [' || to_char(x_organization_id) || ']';
         if ( l_debug_mode = 'Y' )
         then
                  pa_cc_utils.log_message(l_stage);
         end if;
	 l_curr_org_id := pa_moac_utils.get_current_org_id;		/* Added for bug 7365397 */

        /*===================================================================+
         | If the calling module is 'REQUIREMENT' - both job id and          |
         | organization id should be provided.                               |
         +===================================================================*/
         if ( p_calling_module = 'REQUIREMENT' and
                     (x_job_id is null or x_organization_id is null ) )
         then
                   x_err_code := 'NO_JOB_ID' ;
		   /*Bug fix:3089560 Plsql numeric value error causes without resetting stack*/
		   pa_cc_utils.reset_curr_function;
                   return;
         end if;

        /*2879644 Commented for bug 7158405
         if p_org_id is not null then
              g_ou_id := p_org_id;
             end if ;
        2879644*/

         /*=============================+
          | Derive Functional Currency. |
          +=============================*/
         /*======================================================+
          | Bug 2879644. Added NVL() while selecting org_id.     |
          | g_func_curr is not used anywhere and hence selecting |
          | currency_code can be removed later.                  |
          +======================================================*/
         if ( g_func_curr is null or g_ou_id is null )		/* Reverted the fix done via 6908073 for bug 7365397 */
/* Removed the g_ou_id nul lcondition for bug 6908073 */
         then
                     l_stage := 'Selecting Functional Currency';
                     if ( l_debug_mode = 'Y' )
                     then
                              pa_cc_utils.log_message(l_stage);
                     end if;
                     select nvl(p_org_id, imp.org_id)
                           ,sob.currency_code
                       into g_ou_id
                           ,g_func_curr
                       from gl_sets_of_books        sob
                           ,pa_implementations      imp
                      where imp.set_of_books_id = sob.set_of_books_id and
                            imp.org_id = l_curr_org_id; 	/* Reverted the fix of 7191479 for bug 7365397 */
/* nvl(p_org_id, imp.org_id); /* Added the condition for bug 6908073 */
		/* Modified the above select for bug 7191479 */

                     l_stage := 'Org Id [' || to_char(g_ou_id) || '] Func Curr [' || g_func_curr || ']';
                     if ( l_debug_mode = 'Y' )
                     then
                              pa_cc_utils.log_message(l_stage);
                     end if;
         end if; /* g_func_curr is null */

        /*====================================================================+
         | If input organization_id is null, derive it based on the employee. |
         +====================================================================*/
         --if ( x_organization_id is null or x_job_id is null ) Commented for bug 5004080
         if ( p_person_id is not null and (x_organization_id is null or x_job_id is null) )
         then
                  l_stage := 'Selecting Organization and Job Ids';
                  if ( l_debug_mode = 'Y' )
                  then
                           pa_cc_utils.log_message(l_stage);
                  end if;

		  /* cwk changes : Modified stmt to derive the Organization Id, Job Id
				   for a Person Id of a contingent worker also*/
                  begin
                  select nvl(x_organization_id, per.organization_id)
                        ,nvl(x_job_id, per.job_id)
                    into x_organization_id
                        ,x_job_id
                    from per_assignments_f per
                        ,per_assignment_status_types type
                   where trunc(p_txn_date) between trunc(effective_start_date) and trunc(nvl(effective_end_date,p_txn_date))
                     and per.person_id = p_person_id
                     and per.primary_flag = 'Y'
                     and per.assignment_type in ('E', 'C')
                     and per.assignment_status_type_id = type.assignment_status_type_id
                     and type.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK')
                  ;
                  exception
                       when no_data_found then
                             l_stage := 'No records found while fetching job id';
                             if ( l_debug_mode = 'Y' ) then
                                 pa_cc_utils.log_message(l_stage);
                             end if;
                  end;

                  l_stage := 'Organization Id [' || to_char(x_organization_id) || '] Job Id [' || to_char(x_job_id) || ']';
                  if ( l_debug_mode = 'Y' )
                  then
                           pa_cc_utils.log_message(l_stage);
                  end if;
         end if; /* x_organization_id is null */
----------------- initializaton end ------------------------------
        /*======================================+
         | See whether the cache can be reused. |
         +======================================*/
         if (  (P_Called_From <> 'R') AND  /* Added for 3405326 */
                x_organization_id = g_rt_organization_id
                and p_calling_module = g_rt_calling_module
                and trunc(p_txn_date) between trunc(g_rt_start_date_active) and trunc(nvl(g_rt_end_date_active, p_txn_date))
            )
         then
                     if ( g_rt_sch_type = 'EMPLOYEE' and p_person_id = g_rt_person_id )
                     then
                             l_use_cache := 'Y';
                     end if;
                     if ( g_rt_sch_type = 'JOB' and x_job_id = g_rt_job_id )
                     then
                             l_use_cache := 'Y';
                     end if;
         end if;
         if ( l_use_cache = 'Y' )
         then
                          x_organization_id            := g_rt_organization_id ;
                          x_cost_rate                  := g_rt_cost_rate ;
                          x_start_date_active          := g_rt_start_date_active ;
                          x_end_date_active            := g_rt_end_date_active ;
                          x_org_labor_sch_rule_id      := g_rt_org_labor_sch_rule_id ;
                          x_costing_rule               := g_rt_costing_rule ;
                          x_rate_sch_id                := g_rt_rate_sch_id ;
                          x_cost_rate_curr_code        := g_rt_cost_rate_curr_code ;
                          x_acct_rate_type             := g_rt_acct_rate_type ;
                          x_acct_rate_date_code        := g_rt_acct_rate_date_code ;
                          x_acct_exch_rate             := g_rt_acct_exch_rate ;
                          x_ot_project_id              := g_rt_ot_project_id ;
                          x_ot_task_id                 := g_rt_ot_task_id ;
                          x_err_stage                  := g_rt_err_stage ;
                          x_err_code                   := g_rt_err_code ;
                     pa_cc_utils.reset_curr_function;
                     return;
         end if;

      if ( p_calling_module <> 'REQUIREMENT' )
      then
        /*================================================+
         | Check if there is an override for this person. |
         +================================================*/
         l_override_flag := 'Y' ;
         l_stage := 'Selecting Override';
         if ( l_debug_mode = 'Y' )
         then
                  pa_cc_utils.log_message(l_stage);
         end if;
         begin
            select detail.compensation_rule_set
                  ,detail.hourly_cost_rate
                  ,detail.rate_schedule_id
                  ,detail.override_type
                  ,detail.cost_rate_currency_code
                  ,detail.acct_rate_type
                  ,detail.acct_rate_date_code
                  ,detail.acct_exchange_rate
                  ,detail.start_date_active
                  ,detail.end_date_active
              into x_costing_rule
                  ,x_cost_rate
                  ,x_rate_sch_id
                  ,l_override_type
                  ,x_cost_rate_curr_code
                  ,x_acct_rate_type
                  ,x_acct_rate_date_code
                  ,x_acct_exch_rate
                  ,x_start_date_active
                  ,x_end_date_active
              from pa_compensation_details_all detail                 /*2879644:Added ALL*/
             where trunc(p_txn_date) between trunc(detail.start_date_active)
                                         and trunc(nvl(detail.end_date_active,p_txn_date))
               and NVL(detail.org_id,-99) = NVL(NVL(p_org_id, g_ou_id),-99)         /*2879644 :Added org_id join  7158405 */
               and detail.person_id = p_person_id;
         exception
             when no_data_found then
                 l_override_flag := 'N';
             when too_many_rows then
                 x_err_code := 'DUP_REC';
         end;
         if ( x_err_code is not null )
         then
                     raise USER_EXCEPTION;
         end if;
         if ( l_override_type = 'COST_RATE' and x_cost_rate is null )
         then
                     x_err_code := 'NO_COST_RATE';
                     raise USER_EXCEPTION;
         end if;
         if ( l_override_type = 'COST_RATE_SCHEDULE' and x_rate_sch_id is null )
         then
                     x_err_code := 'NO_COST_RATE_SCH';
                     raise USER_EXCEPTION;
         end if;

         if ( l_override_flag = 'Y' )
         then
                  l_stage := 'comp rule [' || x_costing_rule
                                              || '] rate  [' || to_char( x_cost_rate)
                                              || '] x_rate_sch_id [' || to_char( x_rate_sch_id)
                                              || '] override type [' || l_override_type
                                              || '] override flag [' || l_override_flag
                                              || '] crcc type [' || x_cost_rate_curr_code
                                              || '] art [' || x_acct_rate_type
                                              || '] ardc [' || x_acct_rate_date_code
                                              || '] aer [' || to_char(x_acct_exch_rate)
                                              || '] start [' || to_char(x_start_date_active)
                                              || '] end [' || to_char(x_end_date_active)
                                              || ']';
                 if ( l_debug_mode = 'Y' )
                 then
                          pa_cc_utils.log_message(l_stage);
                 end if;
                 /*
                  * If the compensation rule available at the override level
                  * and if the costing method id 'Extension', set rate to null
                  * and return.
                  */
                 if ( x_costing_rule is not null )
                 then
                          l_stage := 'selecting costing method from rule [' || x_costing_rule || ']';
					 if ( l_debug_mode = 'Y' ) then
                          pa_cc_utils.log_message(l_stage);
					 end if;
                          select rule.costing_method
                            into l_costing_method
                            from pa_compensation_rule_sets rule
                           where rule.compensation_rule_set = x_costing_rule
                          ;
			                    if ( l_debug_mode = 'Y' ) then
                             pa_cc_utils.log_message('l_costing_method '||l_costing_method);
			                    end if;

                          if ( l_costing_method = 'LABOR_COST_EXTN' )
                          then
                                 x_cost_rate := null ;
                                 raise USER_EXCEPTION;
                          end if; /*costing method is 'extension'*/
                 end if; /* costing rule is not null */
         end if; /* override_flag  */
      end if; /* calling module */

      /*=================================================+
       | If cost rate is obtained, return to the caller. |
       +=================================================*/
      if ( l_override_flag = 'Y' and x_cost_rate is not null )
      then
             raise USER_EXCEPTION;
      end if;

        /*==========================================================+
         | In the absense of an override, traverse the hierarchy.   |
         +==========================================================*/
         if ( l_override_flag <> 'Y' or x_costing_rule is null)
         then
                       l_stage := 'Calling get_orgn_level_costing_info with g_ou_id [' || to_char(g_ou_id) ||
                                               '] x_organization_id [' || to_char(x_organization_id) ||
                                               '] p_person_id [' || to_char(p_person_id) ||
                                               '] x_job_id [' || to_char(x_job_id) || ']';
                       if ( l_debug_mode = 'Y' )
                       then
                                 pa_cc_utils.log_message(l_stage);
                       end if;
                       begin
                       pa_cost_rate_pub.get_orgn_level_costing_info
                                                ( p_org_id                 => nvl(p_org_id, g_ou_id)   --7158405
                                                 ,p_organization_id        => x_organization_id
                                                 ,p_person_id              => p_person_id
                                                 ,p_job_id                 => x_job_id
                                                 ,p_txn_date               => p_txn_date
                                                 ,p_calling_module         => p_calling_module
                                                 ,x_org_labor_sch_rule_id  => l_num_dummy
                                                 ,x_costing_rule           => x_costing_rule
                                                 ,x_rate_sch_id            => x_rate_sch_id
                                                 ,x_ot_project_id          => x_ot_project_id
                                                 ,x_ot_task_id             => x_ot_task_id
                                                 ,x_cost_rate_curr_code    => x_cost_rate_curr_code
                                                 ,x_acct_rate_type         => x_acct_rate_type
                                                 ,x_acct_rate_date_code    => x_acct_rate_date_code
                                                 ,x_acct_exch_rate         => x_acct_exch_rate
                                                 ,x_err_stage              => x_err_stage
                                                 ,x_err_code               => x_err_code
                                                 ,p_called_from            => P_Called_from      /*3405326*/
                                                );
                        exception
                             when others then
                                     if ( l_debug_mode = 'Y' ) then
                                        pa_cc_utils.log_message('when others error '||substr(SQLERRM,1,300));
                                     end if;
                        end;

                            if ( x_err_code is not null )
                            then
                                       raise USER_EXCEPTION;
                            end if;

         end if;

        /*===============================================================+
         | At this point, if any of the vital attributes                 |
         | (costing rule, schedule/rate) are not found its an exception. |
         | costing rule, (schedule or rate)                              |
         +===============================================================*/
         if ( x_costing_rule is null )
         then
                     x_err_code := 'NO_COSTING_RULE';
                     raise USER_EXCEPTION;
         end if;
         if ( x_rate_sch_id is null )
         then
                     x_err_code := 'NO_COST_RATE_SCH';
                     raise USER_EXCEPTION;
         end if;

         l_stage := 'selecting costing method from rule [' || x_costing_rule || ']';
         pa_cc_utils.log_message(l_stage);
         select rule.costing_method
           into l_costing_method
           from pa_compensation_rule_sets rule
          where rule.compensation_rule_set = x_costing_rule
         ;
         if ( l_debug_mode = 'Y' ) then
             pa_cc_utils.log_message('l_costing_method    '||l_costing_method);
         end if;
         if ( l_costing_method = 'LABOR_COST_EXTN' )
         then
                      x_cost_rate := null ;
                      raise USER_EXCEPTION;
         end if; /*costing method is 'extension'*/

         /*
          * Find what Type the schedule is.
          */
         l_stage := 'Reading Rate Schedule information for [' || to_char(x_rate_sch_id) || ']';
         if ( l_debug_mode = 'Y' )
         then
                  pa_cc_utils.log_message(l_stage);
         end if;
         select rate_sch.schedule_type
               ,rate_sch.rate_sch_currency_code
               ,rate_sch.job_group_id
           into l_sch_type
               ,x_cost_rate_curr_code
               ,l_job_group_id
           from pa_std_bill_rate_schedules_all rate_sch
          where rate_sch.bill_rate_sch_id = x_rate_sch_id;

         l_stage := 'sch type [' || l_sch_type || '] crcc [' || x_cost_rate_curr_code || '] job group [' ||
                                       to_char(l_job_group_id) || ']';
         if ( l_debug_mode = 'Y' )
         then
                  pa_cc_utils.log_message(l_stage);
         end if;

      if ( l_sch_type = 'EMPLOYEE')
      then
              l_stage := 'Getting rate from this employee type schedule';
              if ( l_debug_mode = 'Y' )
              then
                       pa_cc_utils.log_message(l_stage);
              end if;

          begin
              select bill_rates.rate
                    ,bill_rates.start_date_active
                    ,bill_rates.end_date_active
                into x_cost_rate
                    ,x_start_date_active
                    ,x_end_date_active
                from pa_bill_rates_all                bill_rates
               where trunc(p_txn_date) between trunc(bill_rates.start_date_active)
                                                  and trunc(nvl(bill_rates.end_date_active,p_txn_date))
                 and bill_rates.person_id = p_person_id
                 and bill_rates.bill_rate_sch_id = x_rate_sch_id
              ;
          exception
          when no_data_found then
                    x_err_code := 'NO_RATE_PERSON';
          end;
      else
                 l_stage := 'Job mapping for [' || to_char(x_job_id) || ']';
                 if ( l_debug_mode = 'Y' )
                 then
                          pa_cc_utils.log_message(l_stage);
                 end if;
                 l_dest_job_id := pa_cross_business_grp.IsMappedToJob(x_job_id, l_job_group_id);

                 l_stage := 'Getting rate for job id [' || to_char(l_dest_job_id) || ']';
                if ( l_debug_mode = 'Y' )
                then
                         pa_cc_utils.log_message(l_stage);
                end if;
             begin
                 select bill_rates.rate
                       ,bill_rates.start_date_active
                       ,bill_rates.end_date_active
                   into x_cost_rate
                       ,x_start_date_active
                       ,x_end_date_active
                   from pa_bill_rates_all                bill_rates
                  where trunc(p_txn_date) between trunc(bill_rates.start_date_active)
                                                     and trunc(nvl(bill_rates.end_date_active, p_txn_date))
                    and bill_rates.job_id = l_dest_job_id
                    and bill_rates.bill_rate_sch_id = x_rate_sch_id
                  ;
            exception
            when others then
                     x_err_code := 'NO_RATE_JOB';
            end;
      end if;
      if ( x_err_code is not null )
      then
                raise USER_EXCEPTION;
      end if;

      l_stage := 'Rate is [' || to_char(x_cost_rate) || ']';
      if ( l_debug_mode = 'Y' )
      then
               pa_cc_utils.log_message(l_stage);
      end if;

/* commented for bug 7423839

      if ( l_debug_mode = 'Y' )
      then
            pa_cc_utils.log_message('END');
      end if;
*/
      pa_cc_utils.reset_curr_function;
exception
    when USER_EXCEPTION
    then
      g_rt_calling_module          := p_calling_module;
      g_rt_organization_id         := x_organization_id;
      g_rt_cost_rate               := x_cost_rate;
      g_rt_start_date_active       := x_start_date_active;
      g_rt_end_date_active         := x_end_date_active;
      g_rt_costing_rule            := x_costing_rule ;
      g_rt_rate_sch_id             := x_rate_sch_id;
      g_rt_cost_rate_curr_code     := x_cost_rate_curr_code;
      g_rt_acct_rate_type          := x_acct_rate_type;
      g_rt_acct_rate_date_code     := x_acct_rate_date_code;
      g_rt_acct_exch_rate          := x_acct_exch_rate;
      g_rt_ot_project_id           := x_ot_project_id ;
      g_rt_ot_task_id              := x_ot_task_id;
      g_rt_err_stage               := x_err_stage;
      g_rt_err_code                := x_err_code;
      if ( l_debug_mode = 'Y' ) --skkoppul
      then
/*
      pa_cc_utils.log_message('p_calling_module '||p_calling_module);
      pa_cc_utils.log_message('x_organization_id '||x_organization_id);
      pa_cc_utils.log_message('x_cost_rate '||x_cost_rate);
      pa_cc_utils.log_message('x_start_date_active '||to_char(x_start_date_active));
      pa_cc_utils.log_message('x_end_date_active '||to_char(x_end_date_active));
      pa_cc_utils.log_message('x_costing_rule '||x_costing_rule);
      pa_cc_utils.log_message('x_rate_sch_id '||x_rate_sch_id);
      pa_cc_utils.log_message('x_cost_rate_curr_code '||x_cost_rate_curr_code);
      pa_cc_utils.log_message('x_acct_rate_type '||x_acct_rate_type);
      pa_cc_utils.log_message('x_acct_rate_date_code '||x_acct_rate_date_code);
      pa_cc_utils.log_message('x_acct_exch_rate '||x_acct_exch_rate);
      pa_cc_utils.log_message('x_ot_project_id  '||x_ot_project_id);
      pa_cc_utils.log_message('x_ot_task_id '||x_ot_task_id);
      pa_cc_utils.log_message('x_err_stage '||x_err_stage);
      pa_cc_utils.log_message('x_err_code '||x_err_code);
      pa_cc_utils.log_message('Error '||substr(SQLERRM,1,300));
*/
      pa_cc_utils.log_message('x_err_stage '||x_err_stage||' x_err_code '||x_err_code||' Error '||substr(SQLERRM,1,300));
      end if;
      pa_cc_utils.reset_curr_function;
   when others then
      if ( l_debug_mode = 'Y' )
      then
         pa_cc_utils.log_message('In when others exception '||substr(SQLERRM,1,300));
      end if;
	/*Bug fix:3089560 Plsql numeric value error causes without resetting stack*/
         pa_cc_utils.reset_curr_function;
            raise;
end get_labor_rate;
---------------------------------------------------------------------------------------------
PROCEDURE get_orgn_level_costing_info
                     ( p_org_id                 IN     pa_implementations_all.org_id%TYPE
                      ,p_organization_id        IN     pa_expenditures_all.incurred_by_organization_id%TYPE
                      ,p_person_id              IN     pa_expenditures_all.incurred_by_person_id%TYPE
                      ,p_job_id                 IN     pa_expenditure_items_all.job_id%TYPE
                      ,p_txn_date               IN     pa_expenditure_items_all.expenditure_item_date%TYPE
                      ,p_calling_module         IN     varchar2 default 'STAFFED'
                      ,x_org_labor_sch_rule_id  IN OUT NOCOPY pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE
                      ,x_costing_rule           IN OUT NOCOPY pa_compensation_rule_sets.compensation_rule_set%TYPE
                      ,x_rate_sch_id            IN OUT NOCOPY pa_std_bill_rate_schedules.bill_rate_sch_id%TYPE
                      ,x_ot_project_id          IN OUT NOCOPY pa_projects_all.project_id%TYPE
                      ,x_ot_task_id             IN OUT NOCOPY pa_tasks.task_id%TYPE
                      ,x_cost_rate_curr_code    IN OUT NOCOPY pa_expenditure_items_all.denom_currency_code%TYPE
                      ,x_acct_rate_type         IN OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE
                      ,x_acct_rate_date_code    IN OUT NOCOPY pa_implementations_all.acct_rate_date_code%TYPE
                      ,x_acct_exch_rate         IN OUT NOCOPY pa_compensation_details_all.acct_exchange_rate%TYPE
                      ,x_err_stage              IN OUT NOCOPY number
                      ,x_err_code               IN OUT NOCOPY varchar2
                      ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                     )
is

          l_debug_mode VARCHAR2(1) := 'Y';
          l_stage      VARCHAR2(500);

          l_org_labor_sch_rule_id               pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE;
          l_rate_sch_id                         pa_std_bill_rate_schedules.bill_rate_sch_id%TYPE;
          l_costing_rule                        pa_compensation_rule_sets.compensation_rule_set%TYPE;
          l_ot_project_id                       pa_projects_all.project_id%TYPE;
          l_ot_task_id                          pa_tasks.task_id%TYPE;
          l_acct_rate_date_code                 pa_org_labor_sch_rule.acct_rate_date_code%TYPE;
          l_acct_rate_type                      pa_org_labor_sch_rule.acct_rate_type%TYPE;
          l_acct_exch_rate                      pa_org_labor_sch_rule.acct_exchange_rate%TYPE;

cursor assignment( p_org_id              IN pa_implementations_all.org_id%TYPE
                  ,p_organization_id     IN pa_expenditures_all.incurred_by_organization_id%TYPE
                  ,p_person_id           IN pa_expenditures_all.incurred_by_person_id%TYPE
                  ,p_job_id              IN pa_expenditure_items_all.job_id%TYPE
                  ,p_txn_date            IN pa_expenditure_items_all.expenditure_item_date%TYPE
                  ,p_calling_module      IN varchar2
                 )
    is
       select assign.org_labor_sch_rule_id
             ,decode(p_calling_module ,'REQUIREMENT'
                       ,assign.forecast_cost_rate_sch_id,assign.cost_rate_sch_id)
             ,assign.labor_costing_rule
             ,assign.overtime_project_id
             ,assign.overtime_task_id
             ,assign.acct_rate_date_code
             ,assign.acct_rate_type
             ,assign.acct_exchange_rate
         from pa_org_labor_sch_rule      assign
             ,pa_org_hierarchy_denorm    hier
             ,pa_implementations         imp
        where hier.child_organization_id = p_organization_id
          and imp.exp_org_structure_version_id=hier.org_hierarchy_version_id
          and hier.pa_org_use_type = 'TP_SCHEDULE'
          and assign.organization_id = hier.parent_organization_id
          and (assign.org_id = p_org_id or assign.org_id is null)
          and trunc(p_txn_date) between trunc(assign.start_date_active)
		                               and trunc(nvl(assign.end_date_active,p_txn_date))
		  and (exists( select null
		                from pa_std_bill_rate_schedules_all rate_sch
                                    ,pa_bill_rates_all              bill_rates
                               where rate_sch.bill_rate_sch_id =
                                         decode(p_calling_module ,'REQUIREMENT'
                                     ,assign.forecast_cost_rate_sch_id,assign.cost_rate_sch_id)
                                 and bill_rates.bill_rate_sch_id = rate_sch.bill_rate_sch_id
                                 and rate_sch.schedule_type = 'EMPLOYEE'
                                 and bill_rates.person_id = p_person_id
                                 and trunc(p_txn_date) between trunc(bill_rates.start_date_active) and
                                                    trunc(nvl(bill_rates.end_date_active,p_txn_date))
                           )
                       or
                       exists( select null
                                from pa_std_bill_rate_schedules_all rate_sch
                                    ,pa_bill_rates_all              bill_rates
                               where rate_sch.bill_rate_sch_id =
                                         decode(p_calling_module ,'REQUIREMENT'
                                 ,assign.forecast_cost_rate_sch_id,assign.cost_rate_sch_id)
                                 and bill_rates.bill_rate_sch_id = rate_sch.bill_rate_sch_id
                                 and rate_sch.schedule_type = 'JOB'
                                 and bill_rates.job_id =
                                              pa_cross_business_grp.IsMappedToJob(p_job_id, rate_sch.job_group_id)
                                 and trunc(p_txn_date) between trunc(bill_rates.start_date_active) and
                                                    trunc(nvl(bill_rates.end_date_active,p_txn_date))
                           )
                      )
        order by hier.parent_level desc
                ,assign.organization_id
                ,assign.org_id;

begin
    if pa_cc_utils.g_debug_mode then
      l_debug_mode := 'Y';
    else
      l_debug_mode := 'N';
    end if;
    	l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- skkoppul
   IF ( l_debug_mode = 'Y' ) THEN
    pa_debug.set_process( x_process    => 'PLSQL'
                         ,x_debug_mode => l_debug_mode
                        );
    pa_cc_utils.set_curr_function('get_orgn_level_costing_info');
    --pa_cc_utils.log_message('Start ');
   END IF;

    l_stage := 'org_id [' || to_char(p_org_id) || '] organization_id [' || to_char(p_organization_id) || ']';
    if ( l_debug_mode = 'Y' )
    then
         pa_cc_utils.log_message(l_stage);
    end if;

/* commented for bug 7423839

    l_stage := 'opening assignment';
    if ( l_debug_mode = 'Y' )
    then
          pa_cc_utils.log_message(l_stage);
    end if;
*/

    open assignment (p_org_id,p_organization_id,p_person_id,p_job_id,p_txn_date,p_calling_module);

  /* commented for bug 7423839

    l_stage := 'fetching assignment';
    if ( l_debug_mode = 'Y' )
    then
         pa_cc_utils.log_message(l_stage);
    end if;

  */
   fetch assignment
   into l_org_labor_sch_rule_id
       ,l_rate_sch_id
       ,l_costing_rule
       ,l_ot_project_id
       ,l_ot_task_id
       ,l_acct_rate_date_code
       ,l_acct_rate_type
       ,l_acct_exch_rate;

        if ( assignment%NOTFOUND )
        then
                 l_stage := 'assignment not found for organization ';
                 if ( l_debug_mode = 'Y' )
                 then
                          pa_cc_utils.log_message(l_stage);
                 end if;
                 /*
                  * This means - neither this organization nor any of its parent
                  * organizations have an assignment. See if there is any assigmnent
                  * at the OU level.
                  */
                 if (  P_Called_From <> 'R' and  /* Added for 3405326 */
                       g_ou_org_labor_sch_rule_id is not null and  nvl(g_ou_id,-99) = nvl(p_org_id,-99) )
                 then
                            /*
                             * Reuse global - OU level cache.
                             */
                            l_org_labor_sch_rule_id := g_ou_org_labor_sch_rule_id ;
                            l_rate_sch_id := g_ou_cost_rate_sch_id ;
                            l_costing_rule := g_ou_labor_costing_rule ;
                            l_ot_project_id := g_ou_ot_project_id ;
                            l_ot_task_id := g_ou_ot_task_id ;
                            l_acct_rate_date_code := g_ou_acct_rate_date_code ;
                            l_acct_rate_type := g_ou_acct_rate_type ;
                            l_acct_exch_rate := g_ou_acct_exch_rate ;
                 else
                     /*
                      * Unable to reuse cache.
                      */
                     begin
                        l_stage := 'Getting OU level assignment for [' || to_char(p_org_id) || ']';
                        if ( l_debug_mode = 'Y' )
                        then
                                 pa_cc_utils.log_message(l_stage);
                        end if;
                        select assign.org_id
                              ,assign.org_labor_sch_rule_id
                              ,decode(p_calling_module ,'REQUIREMENT'
                                ,assign.forecast_cost_rate_sch_id,assign.cost_rate_sch_id)
                              ,assign.labor_costing_rule
                              ,assign.overtime_project_id
                              ,assign.overtime_task_id
                              ,assign.acct_rate_date_code
                              ,assign.acct_rate_type
                              ,assign.acct_exchange_rate
                         into g_ou_id
                             ,g_ou_org_labor_sch_rule_id
                             ,g_ou_cost_rate_sch_id
                             ,g_ou_labor_costing_rule
                             ,g_ou_ot_project_id
                             ,g_ou_ot_task_id
                             ,g_ou_acct_rate_date_code
                             ,g_ou_acct_rate_type
                             ,g_ou_acct_exch_rate
                          from pa_org_labor_sch_rule assign
                         where assign.organization_id is null
                           and trunc(p_txn_date) between trunc(assign.start_date_active)
                                          and trunc(nvl(assign.end_date_active,p_txn_date))
                           and nvl(assign.org_id,-99) = nvl(p_org_id, -99);
                     exception
                     when no_data_found then
                             l_stage := 'assignment not found at the OU level !!!!!!';
					    if ( l_debug_mode = 'Y' ) then
			                             pa_cc_utils.log_message(l_stage);
					    end if;
                             x_err_code := 'NO_RATE';
                     when others then
                             raise;
                     end;
                     /*
                      * Copying global values to local.
                      */
                            l_org_labor_sch_rule_id := g_ou_org_labor_sch_rule_id ;
                            l_rate_sch_id := g_ou_cost_rate_sch_id ;
                            l_costing_rule := g_ou_labor_costing_rule ;
                            l_ot_project_id := g_ou_ot_project_id ;
                            l_ot_task_id := g_ou_ot_task_id ;
                            l_acct_rate_date_code := g_ou_acct_rate_date_code ;
                            l_acct_rate_type := g_ou_acct_rate_type ;
                            l_acct_exch_rate := g_ou_acct_exch_rate ;
                 end if; /* reuse cache ? */
        end if; /* organization level assignment not found */

        l_stage := 'l_org_labor_sch_rule_id [' || to_char(l_org_labor_sch_rule_id) ||
                                            '] l_rate_sch_id [' || to_char( l_rate_sch_id) ||
                                            '] l_costing_rule [' || l_costing_rule ||
                                            '] l_ot_project_id [' || to_char( l_ot_project_id) ||
                                            '] l_ot_task_id [' || to_char( l_ot_task_id) ||
                                            '] l_acct_rate_date_code [' || l_acct_rate_date_code ||
                                            '] l_acct_rate_type [' ||  l_acct_rate_type ||
                                            '] l_acct_exch_rate [' || to_char( l_acct_exch_rate) ||
                                            '] x_err_code [' || x_err_code || ']';
        if ( l_debug_mode = 'Y' )
        then
                 pa_cc_utils.log_message(l_stage);
        end if;

        /*
         * Move local variables to out parameters.
         */
        x_org_labor_sch_rule_id := nvl(x_org_labor_sch_rule_id ,l_org_labor_sch_rule_id);
        x_rate_sch_id := nvl(x_rate_sch_id ,l_rate_sch_id);
        x_costing_rule := nvl(x_costing_rule ,l_costing_rule);
        x_ot_project_id := l_ot_project_id;
        x_ot_task_id := l_ot_task_id;
        x_acct_rate_date_code := nvl(x_acct_rate_date_code ,l_acct_rate_date_code);
        x_acct_rate_type := nvl(x_acct_rate_type ,l_acct_rate_type);
        x_acct_exch_rate := nvl(x_acct_exch_rate ,l_acct_exch_rate);

  /* commented for bug 7423839
        l_stage := 'Closing Cursor';
        if ( l_debug_mode = 'Y' )
        then
                 pa_cc_utils.log_message(l_stage);
        end if;

        */
        close assignment;

  /* commented for bug 7423839
        l_stage := 'END';
        if ( l_debug_mode = 'Y' )
        then
                 pa_cc_utils.log_message(l_stage);
        end if;
        */
  pa_cc_utils.reset_curr_function;

exception
when others
then
        if ( l_debug_mode = 'Y' )
        then
           pa_cc_utils.log_message('inside others excpn get_orgn_level_costing_info');
        end if;
        pa_cc_utils.reset_curr_function;
        RAISE;
end get_orgn_level_costing_info;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : GetEmpCostRate
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To get the emp cost rate.
-- Return Value                  : NUMBER
-- Prameters
-- P_Person_Id            IN    NUMBER  REQUIRED
-- P_Job_Id               IN    NUMBER  OPTIONAL
-- P_Organization_Id      IN    NUMBER  OPTIONAL
-- P_Effective_Date       IN    DATE    OPTIONAL DEFAULT SYSDATE
-- P_Rate_Type            IN    VARCHAR2 REQUIRED
--                              -- FUNC for Rate in Functional Currency
--                              -- DENOM for Rate in Denom Currency
-- P_Called_From      IN varchar2 DEFAULT 'O' Added for 3405326. 'O'--Others
--                                        'R' -- Reports
--  History
--  03-OCT-02   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/

Function GetEmpCostRate( P_Person_Id        IN per_all_people_f.person_id%type
                        ,P_Job_Id           IN pa_expenditure_items_all.job_id%type
                        ,P_Organization_Id  IN pa_expenditures_all.incurred_by_organization_id%type
                        ,P_Effective_Date   IN date
                        ,P_Rate_Type        IN varchar2
                        ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                       )
      RETURN pa_bill_rates_all.rate%type IS
            l_job_id                   pa_expenditure_items_all.job_id%type;
            l_organization_id          pa_expenditures_all.incurred_by_organization_id%type;
            l_org_id                   pa_expenditures_all.org_id%type;      /*2879644*/
            l_costing_rule             pa_compensation_details_all.compensation_rule_set%type;
            l_cost_rate                pa_bill_rates_all.rate%type;
            l_acct_cost_rate           pa_bill_rates_all.rate%type;
            l_start_date_active        date;
            l_end_date_active          date;
            l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%type;
            l_rate_sch_id              pa_std_bill_rate_schedules.bill_rate_sch_id%type;
            l_override_type            pa_compensation_details.override_type%type;
            l_cost_rate_curr_code      pa_compensation_details.cost_rate_currency_code%type;
            l_acct_rate_type           pa_compensation_details.acct_rate_type%type;
            l_acct_rate_date_code      pa_compensation_details.acct_rate_date_code%type;
            l_acct_exch_rate           pa_compensation_details.acct_exchange_rate%type;
            l_ot_project_id            pa_projects_all.project_id%type;
            l_ot_task_id               pa_tasks.task_id%type;
            l_err_code                 varchar2(200) default null; /* Default null added for bug 2931397 */
            l_err_stage                number;
            l_return_rate              pa_bill_rates_all.rate%type;
            l_acct_currency_code       varchar2(15);
            l_conversion_date          date;
            l_numerator                number;
            l_denominator              number;
 Begin

     --pa_cc_utils.log_message('In Getempcost rate');
   IF   (P_Called_From <> 'R') AND  /* Added for 3405326 */
       P_person_id    = nvl(G_EMP_PERSON_ID,-99) AND
       nvl(P_job_id,-99)  = nvl(G_EMP_JOB_ID,-99)    AND
       nvl(P_organization_id,-99) = nvl(G_EMP_ORGANIZATION_ID,-99) AND
           P_effective_date BETWEEN G_EMP_RATE_START_DATE AND nvl(G_EMP_RATE_END_DATE,SYSDATE) THEN
     NULL;  --Do nothing. Values are in the Cache.
    -- pa_cc_utils.log_message('Getting the Rate from Cache');
   ELSE

     --pa_cc_utils.log_message('Deriving the Rate');
   --- Call the api to derive rate and attributes.

      l_job_id          := P_job_id; --IN OUT parameter
      l_organization_id := P_organization_id; --IN OUT parameter.

  Begin
    PA_COST_RATE_PUB.get_labor_rate ( p_person_id             =>P_person_id
                                     ,x_job_id                =>l_job_id
                                     ,p_txn_date              =>P_effective_date
                                     ,p_org_id                =>l_org_id           /*2879644*/
                                     ,x_organization_id       =>l_organization_id
                                     ,x_cost_rate             =>l_cost_rate
                                     ,x_start_date_active     =>l_start_date_active
                                     ,x_end_date_active       =>l_end_date_active
                                     ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                     ,x_costing_rule          =>l_costing_rule
                                     ,x_rate_sch_id           =>l_rate_sch_id
                                     ,x_cost_rate_curr_code   =>l_cost_rate_curr_code
                                     ,x_acct_rate_type        =>l_acct_rate_type
                                     ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                     ,x_acct_exch_rate        =>l_acct_exch_rate
                                     ,x_ot_project_id         =>l_ot_project_id
                                     ,x_ot_task_id            =>l_ot_task_id
                                     ,x_err_stage             =>l_err_stage
                                     ,x_err_code              =>l_err_code
                                     ,p_called_from           =>P_called_from           /*3405326*/
                                     );
  Exception
   When OTHERS Then
    NULL;
  End;

  /* Following code added for bug 2931397 */
  If l_err_code is not null
  then return NULL;
  End if;
  /* bug 2931397 */

      -- Cache the Emp Details
        G_EMP_PERSON_ID       := P_person_id;
        G_EMP_JOB_ID          := P_job_id;
        G_EMP_ORGANIZATION_ID := P_organization_id;

       -- Cache the rate  and the attributes
        G_EMP_COST_RATE       := l_cost_rate;
        G_EMP_RATE_RULE       := l_costing_rule;
        G_EMP_RATE_CURR       := l_cost_rate_curr_code;
        G_EMP_RATE_START_DATE := l_start_date_active;
        G_EMP_RATE_END_DATE   := l_end_date_active;

      IF P_Rate_Type = 'FUNC' THEN --Return the Functional Rate

         -- pa_cc_utils.log_message('Deriving the Functional Rate');
         -- Get the Functional Currency code
           l_acct_currency_code := PA_CURRENCY.get_currency_code;

           --Check if the denom and functional currencies are different

       IF l_acct_currency_code <> l_cost_rate_curr_code THEN

          l_conversion_date := P_Effective_Date;

         pa_multi_currency.convert_amount( P_from_currency =>l_cost_rate_curr_code,
                                  P_to_currency =>l_acct_currency_code,
                                  P_conversion_date =>l_conversion_date,
                                  P_conversion_type =>l_acct_rate_type,
                                  P_amount =>l_cost_rate,
                                  P_user_validate_flag =>'N',
                                  P_handle_exception_flag =>'Y', /* changed to 'Y' from 'N' for bug 2931397 */
                                  P_converted_amount =>l_acct_cost_rate,
                                  P_denominator =>l_denominator,
                                  P_numerator =>l_numerator,
                                  P_rate =>l_acct_exch_rate,
                                  X_status =>l_err_code ) ;

		/* Following code added for bug 2931397 */
			If l_err_code is not null
			then return NULL;
			End if;
		/* bug 2931397 */

           --Cache the Acct cost rate.
           G_EMP_ACCT_COST_RATE := l_acct_cost_rate;
       ELSE
           --If the call is in FUNC Mode, and the currencies are same
           G_EMP_ACCT_COST_RATE := l_cost_rate;
       END IF;
    END IF;
   END IF;

     IF P_Rate_Type = 'FUNC' THEN
       --Return the Functional Rate
       l_return_rate := G_EMP_ACCT_COST_RATE;
     ELSE
       --Return the Transaction Rate
       l_return_rate := G_EMP_COST_RATE;
     END IF;

     --pa_cc_utils.log_message('before  return rate = '||l_return_rate);
    Return  l_return_rate;

End GetEmpCostRate;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : GetEmpCostRateInfo
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To get the emp cost rate attributes; COMPENSATION RULE,CURRENCY
--                                 CODE, RATE EFFECTIVE START DATE, and RATE EFFECTIVE  END DATE.
-- Return Value                  : VARCHAR2
-- Prameters
-- P_person_id            IN    NUMBER  REQUIRED
-- P_job_id               IN    NUMBER  OPTIONAL
-- P_organization_id      IN    NUMBER  OPTIONAL
-- P_effective_date       IN    DATE    OPTIONAL DEFAULT SYSDATE
-- P_Rate_Attribute       IN    VARCHAR2 REQUIRED
                                -- Valid Values
                                -- RULE for Employee Compensation Rule
                                -- CURR for Rate Currency Code
                                -- START for Rate Effective Start Date.
                                -- END  for Rate Effective End Date.
--  History
--  03-OCT-02   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/
Function GetEmpCostRateInfo( P_Person_Id        IN per_all_people_f.person_id%type
                            ,P_Job_Id           IN pa_expenditure_items_all.job_id%type
                            ,P_Organization_Id  IN pa_expenditures_all.incurred_by_organization_id%type
                            ,P_Effective_Date   IN date
                            ,P_Rate_Attribute   IN varchar2
                            ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                           )
      RETURN VARCHAR2 IS
            l_job_id                   pa_expenditure_items_all.job_id%type;
            l_organization_id          pa_expenditures_all.incurred_by_organization_id%type;
            l_org_id                   pa_expenditures_all.org_id%TYPE ;            /*2879644*/
            l_costing_rule             pa_compensation_details_all.compensation_rule_set%type;
            l_cost_rate                pa_bill_rates_all.rate%type;
            l_start_date_active        date;
            l_end_date_active          date;
            l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%type;
            l_rate_sch_id              pa_std_bill_rate_schedules.bill_rate_sch_id%type;
            l_override_type            pa_compensation_details.override_type%type;
            l_cost_rate_curr_code      pa_compensation_details.cost_rate_currency_code%type;
            l_acct_rate_type           pa_compensation_details.acct_rate_type%type;
            l_acct_rate_date_code      pa_compensation_details.acct_rate_date_code%type;
            l_acct_exch_rate           pa_compensation_details.acct_exchange_rate%type;
            l_ot_project_id            pa_projects_all.project_id%type;
            l_ot_task_id               pa_tasks.task_id%type;
            l_err_code                 varchar2(200);
            l_err_stage                number;
            l_return_value             varchar2(100);
 Begin

     --pa_cc_utils.log_message('In Getempcostrateinfo...');
  IF   (P_Called_From <> 'R') AND  /* Added for 3405326 */
       P_person_id    = nvl(G_EMP_PERSON_ID,-99) AND
       nvl(P_job_id,-99)  = nvl(G_EMP_JOB_ID,-99)    AND
       nvl(P_organization_id,-99) = nvl(G_EMP_ORGANIZATION_ID,-99) AND
       P_effective_date BETWEEN G_EMP_RATE_START_DATE AND nvl(G_EMP_RATE_END_DATE,SYSDATE) THEN
       NULL; --Don't do anything. The values are cached already.
     --pa_cc_utils.log_message('Getting the Rate Attributes from Cache');
  ELSE

      --pa_cc_utils.log_message('Deriving the Rate Attributes');
       --- Call the api to derive rate and attributes.

      l_job_id          := P_job_id; --IN OUT parameter
      l_organization_id := P_organization_id; --IN OUT parameter.

  Begin
    PA_COST_RATE_PUB.get_labor_rate ( p_person_id             =>P_person_id
                                     ,x_job_id                =>l_job_id
                                     ,p_txn_date              =>P_effective_date
                                     ,p_org_id                =>l_org_id            /*2879644*/
                                     ,x_organization_id       =>l_organization_id
                                     ,x_cost_rate             =>l_cost_rate
                                     ,x_start_date_active     =>l_start_date_active
                                     ,x_end_date_active       =>l_end_date_active
                                     ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                     ,x_costing_rule          =>l_costing_rule
                                     ,x_rate_sch_id           =>l_rate_sch_id
                                     ,x_cost_rate_curr_code   =>l_cost_rate_curr_code
                                     ,x_acct_rate_type        =>l_acct_rate_type
                                     ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                     ,x_acct_exch_rate        =>l_acct_exch_rate
                                     ,x_ot_project_id         =>l_ot_project_id
                                     ,x_ot_task_id            =>l_ot_task_id
                                     ,x_err_stage             =>l_err_stage
                                     ,x_err_code              =>l_err_code
                                     ,p_called_from           =>P_called_from           /*3405326*/
                                     );
  Exception
   When OTHERS Then
    NULL;
  End;


      -- Cache the Emp Details
        G_EMP_PERSON_ID       := P_person_id;
        G_EMP_JOB_ID          := P_job_id;
        G_EMP_ORGANIZATION_ID := P_organization_id;

       -- Cache the rate  attributes
        G_EMP_COST_RATE       := l_cost_rate;  /* Added for bug 3624357 */
        G_EMP_RATE_RULE       := l_costing_rule;
        G_EMP_RATE_CURR       := l_cost_rate_curr_code;
        G_EMP_RATE_START_DATE := l_start_date_active;
        G_EMP_RATE_END_DATE   := l_end_date_active;
  END IF;

  IF P_Rate_Attribute = 'RULE' Then
     l_return_value := G_EMP_RATE_RULE;
  ELSIF P_Rate_Attribute = 'CURR' Then
     l_return_value := G_EMP_RATE_CURR;
  ELSIF P_Rate_Attribute = 'START' Then
     l_return_value := G_EMP_RATE_START_DATE;
  ELSIF P_Rate_Attribute = 'END' Then
     l_return_value := G_EMP_RATE_END_DATE;
  END IF;

      Return l_return_value;

End GetEmpCostRateInfo;

--------------------------------
PROCEDURE get_orgn_lvl_cst_info_set
                     ( p_org_id_tab                 IN            pa_plsql_datatypes.IdTabTyp
                      ,p_organization_id_tab        IN            pa_plsql_datatypes.IdTabTyp
                      ,p_person_id_tab              IN            pa_plsql_datatypes.IdTabTyp
                      ,p_job_id_tab                 IN            pa_plsql_datatypes.IdTabTyp
                      ,p_txn_date_tab               IN            pa_plsql_datatypes.Char30TabTyp
                      ,p_override_type_tab          IN            pa_plsql_datatypes.Char150TabTyp
                      ,p_calling_module             IN            varchar2 default 'STAFFED'
                      ,P_Called_From                IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                      ,x_org_labor_sch_rule_id_tab  IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_costing_rule_tab           IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_rate_sch_id_tab            IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_ot_project_id_tab          IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_ot_task_id_tab             IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_cost_rate_curr_code_tab    IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_rate_type_tab         IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_rate_date_code_tab    IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_exch_rate_tab         IN OUT NOCOPY pa_plsql_datatypes.Char30TabTyp
                      ,x_err_stage_tab              IN OUT NOCOPY pa_plsql_datatypes.NumTabTyp
                      ,x_err_code_tab               IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp)
is
         l_count number := 0;
         l_stage varchar2(500);
         l_debug_mode varchar2(1) := 'Y';
begin

    if pa_cc_utils.g_debug_mode then
      l_debug_mode := 'Y';
    else
      l_debug_mode := 'N';
    end if;
   IF ( l_debug_mode = 'Y' ) THEN
    pa_debug.set_process( x_process    => 'PLSQL'
                         ,x_debug_mode => l_debug_mode
                        );
    pa_cc_utils.set_curr_function('get_orgn_lvl_cst_info_set');
    pa_cc_utils.log_message('Start ');
   END IF;

         l_count := p_organization_id_tab.count ;
         l_stage := 'count [' || to_char(l_count) || ']';
         if ( l_debug_mode = 'Y')
         then
                     pa_cc_utils.log_message(l_stage);
         end if;
         for i in 1 .. l_count
         loop
                if ( p_override_type_tab(i) is null or x_costing_rule_tab(i) is null )
                then
                         l_stage := 'Calling get_orgn_level_costing_info with Org Id [' || to_char( p_org_id_tab(i) ) ||
                                               '] orgn Id [' || to_char( p_organization_id_tab(i) ) ||
                                               '] person Id [' || to_char( p_person_id_tab(i) ) ||
                                               '] job Id [' || to_char( p_job_id_tab(i) ) ||
                                               '] txn date [' || p_txn_date_tab(i) ||
                                               '] cost rule [' || x_costing_rule_tab(i) ||
                                               '] sch id [' || to_char( x_rate_sch_id_tab(i) ) ||
                                               '] ot prj Id [' || to_char( x_ot_project_id_tab(i) ) ||
                                               '] ot tsk Id [' || to_char( x_ot_task_id_tab(i) ) ||
                                               '] crcc [' || x_cost_rate_curr_code_tab(i) ||
                                               '] art [' || x_acct_rate_type_tab(i) ||
                                               '] ardc [' || x_acct_rate_date_code_tab(i) ||
                                               '] aer [' ||  x_acct_exch_rate_tab(i) ||
                                               ']';
                        if ( l_debug_mode = 'Y' )
                        then
                                       pa_cc_utils.log_message(l_stage);
                        end if;

                 /*
		  * GSCC: Handled File.Date.5 for p_txn_date_tab(i).
		  */
                 begin
                 pa_cost_rate_pub.get_orgn_level_costing_info
                                      (p_org_id                  => p_org_id_tab(i)
                                      ,p_organization_id         => p_organization_id_tab(i)
                                      ,p_person_id               => p_person_id_tab(i)
                                      ,p_job_id                  => p_job_id_tab(i)
                                      ,p_txn_date                => to_date(p_txn_date_tab(i),'YYYY/MM/DD')
                                      ,p_calling_module          => p_calling_module
                                      ,x_org_labor_sch_rule_id   => x_org_labor_sch_rule_id_tab(i)
                                      ,x_costing_rule            => x_costing_rule_tab(i)
                                      ,x_rate_sch_id             => x_rate_sch_id_tab(i)
                                      ,x_ot_project_id           => x_ot_project_id_tab(i)
                                      ,x_ot_task_id              => x_ot_task_id_tab(i)
                                      ,x_cost_rate_curr_code     => x_cost_rate_curr_code_tab(i)
                                      ,x_acct_rate_type          => x_acct_rate_type_tab(i)
                                      ,x_acct_rate_date_code     => x_acct_rate_date_code_tab(i)
                                      ,x_acct_exch_rate          => x_acct_exch_rate_tab(i)
                                      ,x_err_stage               => x_err_stage_tab(i)
                                      ,x_err_code                => x_err_code_tab(i)
                                      ,p_called_from             => p_Called_from           /*3405326*/
                                      );
                    exception
                        when others then
                             if ( l_debug_mode = 'Y' ) then
                                 pa_cc_utils.log_message('others err in get_orgn_lvl_cst_info_set '||substr(SQLERRM,1,300));
                             end if;
                   end;


                         l_stage := 'After Call to get_orgn_level_costing_info, org labor id ['
                                            || to_char(x_org_labor_sch_rule_id_tab(i)) ||
                                               '] cost rule [' ||  x_costing_rule_tab(i) ||
                                               '] sch Id [' || to_char( x_rate_sch_id_tab(i) ) ||
                                               '] crcc [' || x_costing_rule_tab(i) ||
                                               '] ot proj Id [' || to_char( x_ot_project_id_tab(i) ) ||
                                               '] ot task Id [' || to_char( x_ot_task_id_tab(i) ) ||
                                               '] crcc [' || x_cost_rate_curr_code_tab(i) ||
                                               '] art [' || x_acct_rate_type_tab(i) ||
                                               '] ardc [' || x_acct_rate_date_code_tab(i) ||
                                               '] aer [' || x_acct_exch_rate_tab(i) ||
                                               '] err stg [' || to_char( x_err_stage_tab(i) ) ||
                                               '] err code [' || x_err_code_tab(i) ||
                                               ']';
                        if ( l_debug_mode = 'Y' )
                        then
                                       pa_cc_utils.log_message(l_stage);
                        end if;
             end if; /* override type */
         end loop;
         pa_cc_utils.reset_curr_function;
exception
        when others
            then
                      if ( l_debug_mode = 'Y' ) then
                          pa_cc_utils.log_message('final others err '||substr(SQLERRM,1,300));
                      end if;
                      pa_cc_utils.reset_curr_function;
                      raise;
end get_orgn_lvl_cst_info_set;
--------------------------------


END PA_COST_RATE_PUB;

/
