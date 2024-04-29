--------------------------------------------------------
--  DDL for Package Body GMS_SWEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_SWEEPER" AS
-- $Header: gmsfcuab.pls 120.9.12010000.7 2009/12/02 06:11:59 abjacob ship $

 -- To check on, whether to print debug messages in log file or not
 L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

 Type Bal_rec is RECORD(Exp_item_id    pa_expenditure_items_all.expenditure_item_id%type,
                         adl            gms_award_distributions.adl_line_num%type,
                         award_id       gms_awards_all.award_id%type,
                         Project_id     gms_event_attribute.project_id%type,
                         Task_Id        gms_event_attribute.actual_task_id%type,
                         Amount         gms_event_attribute.bill_amount%type,
                         Reason Varchar2(200));

  Type Fail_Rec is RECORD(resource_list_id gms_bc_packets.resource_list_member_id%type,
                          person_id        pa_expenditures_all.incurred_by_person_id%type,
                          job_id           pa_expenditure_items_all.job_id%type,
                          org_id           pa_expenditures_all.incurred_by_organization_id%type,
                          expenditure_type pa_expenditure_items_all.expenditure_type%type,
                          nlr              pa_expenditure_items_all.non_labor_resource%type,
                          exp_category     pa_expenditure_types.expenditure_category%type,
                          rev_category     pa_expenditure_types.revenue_category_code%type,
                          nlr_org_id       pa_expenditure_items_all.organization_id%type,
                          sys_link         pa_expenditure_items_all.system_linkage_function%type,
                          exp_date         pa_expenditure_items_all.expenditure_item_date%type,
                          bvid             gms_bc_packets.budget_version_id%type,
                          bud_task         gms_bc_packets.bud_task_id%type,
                          cat_code         pa_budget_entry_methods.categorization_code%type,
                          tp_code          pa_budget_entry_methods.time_phased_type_code%type);

  Type Err_Bal_Tab is table of Bal_Rec
        INDEX BY BINARY_INTEGER;

  Type Fail_Tab is table of Fail_Rec
        INDEX BY BINARY_INTEGER;

  Upd_Error_Table Err_Bal_Tab;

  Upd_Reason_Table Fail_Tab;

  -- Variables used for recording burdenable raw cost and raw cost -- Bug 4053891
  TYPE Rec_Award_Exp is RECORD(award_id            gms_award_exp_type_act_cost.award_id%type,
                               expenditure_type    gms_award_exp_type_act_cost.expenditure_type%type,
                               exp_raw_cost        gms_award_exp_type_act_cost.exp_raw_cost%type,
                               exp_burdenable_cost gms_award_exp_type_act_cost.exp_raw_cost%type,
                               ap_raw_cost         gms_award_exp_type_act_cost.exp_raw_cost%type,
                               ap_burdenable_cost  gms_award_exp_type_act_cost.exp_raw_cost%type,
                               po_raw_cost         gms_award_exp_type_act_cost.exp_raw_cost%type,
                               po_burdenable_cost  gms_award_exp_type_act_cost.exp_raw_cost%type,
                               req_raw_cost        gms_award_exp_type_act_cost.exp_raw_cost%type,
                               req_burdenable_cost gms_award_exp_type_act_cost.exp_raw_cost%type,
                               enc_raw_cost        gms_award_exp_type_act_cost.exp_raw_cost%type,
                               enc_burdenable_cost gms_award_exp_type_act_cost.exp_raw_cost%type);

  --TYPE Tab_Award_exp is TABLE OF gms_award_exp_type_act_cost%ROWTYPE;
  TYPE Tab_Award_exp is TABLE OF Rec_Award_Exp INDEX by BINARY_INTEGER;
  Tab_Award_exp_burden  Tab_Award_exp;

/* -----------------------------------------------------------------------------------------------
   Procedure : lock_budget_versions (Bug 4053891)
   Purpose   : - This procedure will lock the budget version records for the budget versions
                 being posted.
               - This was reqd. to enforce incompatibility between sweeper and FC
                 for REQ/PO/AP/FAB/Interface.
-------------------------------------------------------------------------------------------------- */
Procedure Lock_budget_versions(p_budget_version_id number) is
 l_dummy number;
Begin
  Select 1 into l_dummy from gms_budget_versions
  where budget_version_id = p_budget_version_id
  for update;
End Lock_budget_versions;

/* -----------------------------------------------------------------------------------------------
   Procedure : Record_burden_amounts (Bug 4053891)
   Purpose   : This procedure will record the burdenable raw cost and the raw cost
               amounts that needs to be posted to gms_award_exp_type_act_cost
-------------------------------------------------------------------------------------------------- */
PROCEDURE Record_burden_amounts(p_award_id IN gms_award_exp_type_act_cost.award_id%type,
                    p_exp_type             IN gms_award_exp_type_act_cost.expenditure_type%type,
                    p_raw_cost             IN gms_award_exp_type_act_cost.exp_raw_cost%type,
                    p_burdenable_cost      IN gms_award_exp_type_act_cost.exp_raw_cost%type,
                    p_doc_type             IN VARCHAR2,
                    p_Tab_Award_exp_burden IN OUT NOCOPY Tab_Award_exp,
                    p_error_code           OUT NOCOPY Varchar2
                    ) IS
 l_plsql_counter number;
 l_posted_flag   varchar2(1);
  -- Variable to hold procedure name
 l_procedure_name varchar2(25);

Begin
 If p_Tab_Award_exp_burden.exists(1) then
    l_plsql_counter := p_Tab_Award_exp_burden.COUNT;
 End If;

 l_posted_flag   := 'N';
 p_error_code    := null;

 l_procedure_name := 'RECORD_BURDEN_AMOUNTS:';
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||'Start','C');
 END IF;

 If l_plsql_counter > 0 then    -- I
    For x in 1..l_plsql_counter
    Loop
       If (p_Tab_Award_exp_burden(x).award_id         = p_award_id  and
           p_Tab_Award_exp_burden(x).expenditure_type = p_exp_type) then -- II

            If p_doc_type = 'EXP' then
               p_Tab_Award_exp_burden(x).exp_raw_cost := nvl(p_Tab_Award_exp_burden(x).exp_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(x).exp_burdenable_cost := nvl(p_Tab_Award_exp_burden(x).exp_burdenable_cost,0) + p_burdenable_cost;
               l_posted_flag := 'Y';
               EXIT;
            End If;

            If p_doc_type = 'REQ' then
               p_Tab_Award_exp_burden(x).req_raw_cost := nvl(p_Tab_Award_exp_burden(x).req_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(x).req_burdenable_cost := nvl(p_Tab_Award_exp_burden(x).req_burdenable_cost,0) + p_burdenable_cost;
               l_posted_flag := 'Y';
               EXIT;
            End If;

            If p_doc_type = 'PO' then
               p_Tab_Award_exp_burden(x).po_raw_cost := nvl(p_Tab_Award_exp_burden(x).po_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(x).po_burdenable_cost := nvl(p_Tab_Award_exp_burden(x).po_burdenable_cost,0) + p_burdenable_cost;
               l_posted_flag := 'Y';
               EXIT;
            End If;

            If p_doc_type = 'AP' then
               p_Tab_Award_exp_burden(x).ap_raw_cost := nvl(p_Tab_Award_exp_burden(x).ap_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(x).ap_burdenable_cost := nvl(p_Tab_Award_exp_burden(x).ap_burdenable_cost,0) + p_burdenable_cost;
               l_posted_flag := 'Y';
               EXIT;
            End If;

            If p_doc_type = 'ENC' then
               p_Tab_Award_exp_burden(x).enc_raw_cost := nvl(p_Tab_Award_exp_burden(x).enc_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(x).enc_burdenable_cost := nvl(p_Tab_Award_exp_burden(x).enc_burdenable_cost,0) + p_burdenable_cost;
               l_posted_flag := 'Y';
               EXIT;
            End If;

       End If;    -- Award/Exp type comparison II
    End loop;
 End If; -- If l_plsql_counter > 0 then  -- I

 If l_posted_flag = 'N' then

     l_plsql_counter := nvl(l_plsql_counter,0) + 1;

     p_Tab_Award_exp_burden(l_plsql_counter).award_id         := p_award_id;
     p_Tab_Award_exp_burden(l_plsql_counter).expenditure_type := p_exp_type;

            If p_doc_type = 'EXP' then
               p_Tab_Award_exp_burden(l_plsql_counter).exp_raw_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).exp_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(l_plsql_counter).exp_burdenable_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).exp_burdenable_cost,0) + p_burdenable_cost;
               GOTO AMT_ACCOUNTED;
            End If;

            If p_doc_type = 'REQ' then
               p_Tab_Award_exp_burden(l_plsql_counter).req_raw_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).req_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(l_plsql_counter).req_burdenable_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).req_burdenable_cost,0) + p_burdenable_cost;
               GOTO AMT_ACCOUNTED;
            End If;

            If p_doc_type = 'PO' then
               p_Tab_Award_exp_burden(l_plsql_counter).po_raw_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).po_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(l_plsql_counter).po_burdenable_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).po_burdenable_cost,0) + p_burdenable_cost;
               GOTO AMT_ACCOUNTED;
            End If;

            If p_doc_type = 'AP' then
               p_Tab_Award_exp_burden(l_plsql_counter).ap_raw_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).ap_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(l_plsql_counter).ap_burdenable_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).ap_burdenable_cost,0) + p_burdenable_cost;
               GOTO AMT_ACCOUNTED;
            End If;

            If p_doc_type = 'ENC' then
               p_Tab_Award_exp_burden(l_plsql_counter).enc_raw_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).enc_raw_cost,0) + p_raw_cost;
               p_Tab_Award_exp_burden(l_plsql_counter).enc_burdenable_cost := nvl(p_Tab_Award_exp_burden(l_plsql_counter).enc_burdenable_cost,0) + p_burdenable_cost;
               GOTO AMT_ACCOUNTED;
            End If;

  <<AMT_ACCOUNTED>>
    null;
 End If; -- I
-- l_posted_flag := 'Y';
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||'End','C');
 END IF;

Exception
When others then
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||SQLERRM,'C');
 END IF;
 p_error_code := 'E';
End Record_burden_amounts;

/* -----------------------------------------------------------------------------------------------
   Procedure : Post_burden_amounts (Bug 4053891)
   Purpose   : This procedure will post the burdenable raw cost and the raw cost
               amounts to gms_award_exp_type_act_cost
-------------------------------------------------------------------------------------------------- */
PROCEDURE Post_burden_amounts (p_plsql_count          IN Number,
                               p_Tab_Award_exp_burden IN Tab_Award_exp,
                               p_error_code           OUT NOCOPY Varchar2)
                               IS
 -- Variable to hold procedure name
 l_procedure_name varchar2(25);
Begin
 p_error_code := null;
 l_procedure_name := 'POST_BURDEN_AMOUNTS:';
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||'Start','C');
 END IF;

 -- 1. Get gms_bc_packet records for burdne posting
 For x in 1..p_plsql_count
 loop
     -- 2.Update burden summary table: gms_award_exp_type_act_cost
      Update gms_award_exp_type_act_cost
      Set    exp_raw_cost		 = nvl(exp_raw_cost,0) 	     + nvl(p_Tab_Award_exp_burden(x).exp_raw_cost,0),
	         exp_burdenable_cost = nvl(exp_burdenable_cost,0)+ nvl(p_Tab_Award_exp_burden(x).exp_burdenable_cost,0),
 		     ap_raw_cost  		 = nvl(ap_raw_cost,0) 	     + nvl(p_Tab_Award_exp_burden(x).ap_raw_cost,0),
	 	     ap_burdenable_cost  = nvl(ap_burdenable_cost,0) + nvl(p_Tab_Award_exp_burden(x).ap_burdenable_cost,0),
		     po_raw_cost		 = nvl(po_raw_cost,0) 	     + nvl(p_Tab_Award_exp_burden(x).po_raw_cost,0),
		     po_burdenable_cost	 = nvl(po_burdenable_cost,0) + nvl(p_Tab_Award_exp_burden(x).po_burdenable_cost,0),
             req_raw_cost	     = nvl(req_raw_cost,0)       + nvl(p_Tab_Award_exp_burden(x).req_raw_cost,0),
 		     req_burdenable_cost = nvl(req_burdenable_cost,0)+ nvl(p_Tab_Award_exp_burden(x).req_burdenable_cost,0),
		     enc_raw_cost		 = nvl(enc_raw_cost,0) 	     + nvl(p_Tab_Award_exp_burden(x).enc_raw_cost,0),
		     enc_burdenable_cost = nvl(enc_burdenable_cost,0)+ nvl(p_Tab_Award_exp_burden(x).enc_burdenable_cost,0)
	   Where award_id	         = p_Tab_Award_exp_burden(x).award_id
       And   expenditure_type	 = p_Tab_Award_exp_burden(x).expenditure_type;

       -- 3. If burden summary record does not exist, create it
       IF SQL%NOTFOUND then
          INSERT INTO GMS_award_exp_type_act_cost (award_id,
                                                   expenditure_type,
                                                   exp_raw_cost,
                                                   exp_burdenable_cost,
                                                   ap_raw_cost,
                                                   ap_burdenable_cost,
                                                   po_raw_cost,
                                                   po_burdenable_cost,
                                                   req_raw_cost,
                                                   req_burdenable_cost,
                                                   enc_raw_cost,
                                                   enc_burdenable_cost,
                                                   created_by,
                                                   created_date,
                                                   last_updated_by,
                                                   last_update_date )
                                           Values  (p_Tab_Award_exp_burden(x).award_id,
                                                    p_Tab_Award_exp_burden(x).expenditure_type,
                                                    nvl(p_Tab_Award_exp_burden(x).exp_raw_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).exp_burdenable_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).ap_raw_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).ap_burdenable_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).po_raw_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).po_burdenable_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).req_raw_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).req_burdenable_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).enc_raw_cost,0),
                                                    nvl(p_Tab_Award_exp_burden(x).enc_burdenable_cost,0),
                                                    nvl(fnd_global.user_id,0),
                                                    sysdate,
                                                    nvl(fnd_global.user_id,0),
                                                    sysdate);
                        IF SQL%ROWCOUNT = 0 THEN
			   ROLLBACK TO SAVEPOINT A;
                           RAISE_APPLICATION_ERROR(-20002,SQLERRM);
                        END IF;



       END IF; -- IF SQL%NOTFOUND then

 End Loop;

 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||'End','C');
 END IF;
Exception
When others then
 IF L_DEBUG = 'Y' THEN
 	gms_error_pkg.gms_debug(l_procedure_name||SQLERRM,'C');
 END IF;
 p_error_code := 'E';
End Post_burden_amounts;
----------------------------------------------------------------------------------------

-- Procedure to intitalize revenue records  as a pre-process when sweeper called in
-- baseline mode

PROCEDURE intialize_revenue_records(p_award_id   in number,
                                    p_project_id in number,
                                    p_err_code   out NOCOPY number,
                                    p_err_buff   out NOCOPY varchar2) IS
l_award_project_id number(15);
l_stage            varchar2(60);
l_bvid             number(15);
Begin

   p_err_code := 0;

   l_stage := 'intialize_revenue_records: Get Award Project Id';

   Select award_project_id
   into   l_award_project_id
   from   gms_awards_all -- Bug 4732065
   where  award_id = p_award_id;

   l_stage := 'intialize_revenue_records: Delete gms_billing_cancellations';

   delete
   from   gms_billing_cancellations
   where  award_project_id = l_award_project_id
   and    actual_project_id = p_project_id;

   l_stage := 'intialize_revenue_records: Update Burden Records';

   Update gms_burden_components
   set    revenue_accumulated='N'
   where  award_project_id = l_award_project_id
   and    actual_project_id = p_project_id
   and    event_type = 'REVENUE';

  l_stage := 'intialize_revenue_records: Update raw records';

  Update gms_event_intersect
  set    revenue_accumulated='N'
  where  expenditure_item_id in
         (Select expenditure_item_id
          from   gms_award_distributions
          where  award_id = p_award_id
          and    project_id = p_project_id
	  and    adl_status = 'A'        -- added for bug 4108031
	  and    document_type = 'EXP')  -- added for bug 4108031
  and    event_type = 'REVENUE';


  l_stage := 'intialize_revenue_records: Get Bvid';

  Select budget_version_id
  into   l_bvid
  from   gms_budget_versions
  where  project_id = p_project_id
  and    award_id =   p_award_id
  and    budget_type_code ='AC'
  and    budget_status_code = 'B'
  and    current_flag='Y';

 l_stage := 'intialize_revenue_records: Clean balances';

 --## This deletion is reqd. as there can be a case when Sweeper is running in 'U' mode
 --## and another user baslines Award/Project. In this case, there may be a partial updation
 --## for the new budget version. As we're running baseline in 'B' mode for that award/projcet again
 --## we need to clean up and rebuild data.

  Delete
  from   gms_balances
  where  project_id = p_project_id
  and    award_id =   p_award_id
  and    budget_version_id = l_bvid
  and    balance_type='REV';

Exception

  When Others then

         gms_error_pkg.gms_message ( x_err_name=> 'GMS_UNEXPECTED_ERROR',
            x_token_name1              => 'PROGRAM_NAME',
            x_token_val1               => l_stage,
            x_token_name2              => 'SQLCODE',
            x_token_val2               => SQLCODE,
            x_token_name3              => 'SQLERRM',
            x_token_val3               => SQLERRM,
            x_exec_type                => 'C',
            x_err_code                 => p_err_code,
            x_err_buff                 => p_err_buff );

End intialize_revenue_records;
----------------------------------------------------------------------------------------
-- Procedure to calculate start and end date for all amount type and boundary code combinations

PROCEDURE setup_start_end_date (
      x_project_id               IN       gms_bc_packets.project_id%TYPE,
      x_award_id                 IN       gms_bc_packets.award_id%TYPE,
      x_bud_task_id              IN       gms_bc_packets.bud_task_id%TYPE,     -- Bug 2673200
      x_budget_version_id        IN       gms_bc_packets.budget_version_id%TYPE,
      x_time_phased_type_code    IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
      x_entry_level_code         IN       pa_budget_entry_methods.entry_level_code%TYPE, --Bug 2673200
      x_expenditure_item_date    IN       DATE,
      x_amount_type              IN       gms_awards.amount_type%TYPE,
      x_boundary_code            IN       gms_awards.boundary_code%TYPE,
      x_set_of_books_id          IN       gms_bc_packets.set_of_books_id%TYPE,
      x_start_date               OUT NOCOPY      DATE,
      x_end_date                 OUT NOCOPY      DATE,
      x_err_code                 OUT NOCOPY      NUMBER,
      x_err_buff                 OUT NOCOPY      VARCHAR2 ) IS

      project_start_date     DATE;
      project_end_date       DATE;
      x_award_start_date     DATE;
      x_award_end_date       DATE;
      x_task_start_date      DATE;
      x_task_end_date        DATE;
      x_check_task           VARCHAR2(1) := 'N';

      x_error_stage          VARCHAR2(40);
      x_error_procedure_name VARCHAR2(40) := 'gms_sweeper.setup_start_end_date_cal';

-- For date range budget start and end dates will never overlap for an award and project combination
-- For None all budget lines will have same start and end Dates for project,task and award combination

      CURSOR get_budget_dates(p_project_id NUMBER,
                              p_award_id NUMBER,
                              p_budget_version_id NUMBER,
                              p_bud_task_id NUMBER,
                              p_check_task  VARCHAR2,
                              p_expenditure_item_date DATE) IS
      SELECT MAX(TRUNC(gb.start_date)),MIN(TRUNC(gb.end_date))
        FROM gms_balances gb
       WHERE gb.project_id = p_project_id
         AND gb.award_id   = p_award_id
         AND gb.budget_version_id = p_budget_version_id
         AND gb.balance_type = 'BGT'
         AND ( (p_check_task = 'Y' AND gb.task_id = p_bud_task_id) OR
               (p_check_task = 'N'))
         AND TRUNC(p_expenditure_item_date) between gb.start_date and gb.end_date;

   BEGIN
      x_error_procedure_name := 'setup_start_end_date_cal';
      x_err_code := 0;  -- initialize error code

      IF x_entry_level_code <> 'P' AND x_time_phased_type_code = 'N' THEN
         x_check_task :='Y' ;
      ELSE
         x_check_task :='N' ;
      END IF;

      IF x_time_phased_type_code = 'N' THEN
         x_error_stage := 'Time Phase = N' ;

         OPEN  get_budget_dates(x_project_id,x_award_id,x_budget_version_id,x_bud_task_id,
                                x_check_task,x_expenditure_item_date);
         FETCH get_budget_dates INTO x_start_date,x_end_date;
         CLOSE get_budget_dates;

        IF (x_start_date IS NULL OR x_end_date IS NULL) THEN

             SELECT start_date,completion_date
             INTO   project_start_date,project_end_date
             FROM   pa_projects_all -- Bug 4732065 : modified to use _all
             WHERE  project_id = x_project_id;

             SELECT nvl(preaward_date,start_date_active), end_date_active
             INTO   x_award_start_date,x_award_end_date
             FROM   gms_awards_all -- Bug 4732065 : modified to use _all
             WHERE  award_id = x_award_id;

           IF (x_entry_level_code = 'P') THEN

              x_start_date := GREATEST(NVL(project_start_date,x_award_start_date),x_award_start_date);
              x_end_date   := LEAST(NVL(project_end_date,x_award_end_date),x_award_end_date);

           ELSE

             SELECT start_date,completion_date
             INTO   x_task_start_date,x_task_end_date
             FROM   pa_tasks
             WHERE  task_id = x_bud_task_id;

              x_start_date := GREATEST(NVL(project_start_date,x_award_start_date),x_award_start_date,NVL(x_task_start_date,x_award_start_date));
              x_end_date   := LEAST(NVL(project_end_date,x_award_end_date),x_award_end_date,NVL(x_task_end_date,x_award_end_date));

            END IF;
         END IF;

        END IF;

      IF x_time_phased_type_code = 'R' THEN

         x_error_stage := 'Time Phase = R' ;

         OPEN  get_budget_dates(x_project_id,x_award_id,x_budget_version_id,x_bud_task_id,
                                x_check_task,x_expenditure_item_date);
         FETCH get_budget_dates INTO x_start_date,x_end_date;
         CLOSE get_budget_dates;

         If x_start_date is NULL then

                select gps.start_date, gps.end_date
                into   x_start_date, x_end_date
                from   gl_period_statuses gps
                where  gps.application_id = 101
                and    gps.set_of_books_id = x_set_of_books_id
                and    trunc(x_expenditure_item_date) between gps.start_date and gps.end_date
                and    gps.adjustment_period_flag = 'N';

        End if ;

      End if; --IF x_time_phased_type_code = 'R' THEN

     EXCEPTION
      WHEN OTHERS THEN
         gms_error_pkg.gms_message ( x_err_name=> 'GMS_UNEXPECTED_ERROR',
            x_token_name1              => 'PROGRAM_NAME',
            x_token_val1               => x_error_procedure_name||'.'||x_error_stage,
            x_token_name2              => 'SQLCODE',
            x_token_val2               => SQLCODE,
            x_token_name3              => 'SQLERRM',
            x_token_val3               => SQLERRM,
            x_exec_type                => 'C',
            x_err_code                 => x_err_code,
            x_err_buff                 => x_err_buff );

            x_start_date := null;
            x_end_date := null;

END setup_start_end_date;

----------------------------------------------------------------------------------------

  PROCEDURE upd_act_enc_bal  (errbuf       OUT NOCOPY VARCHAR2
                              ,retcode     OUT NOCOPY NUMBER  -- Changed datatype to NUMBER for Bug:2464800
                              ,x_packet_id in  number default null
                              ,x_mode      in  varchar2 DEFAULT 'U',
                  x_project_id in number default null,
                  x_award_id in number default null ) IS
 cursor c_gms_packets (x_status_code varchar2) is --Bug 2138376 : Added x_status_code parameter
   select  gbc.budget_version_id
   ,       gbc.project_id
   ,       gbc.award_id
   ,       gbc.task_id
   ,       gbc.bud_task_id
   ,       gbc.top_task_id
   ,       gbc.document_type
   ,       gbc.period_name
   ,       gbc.resource_list_member_id
   ,       gbc.parent_resource_id
   ,       gbc.bud_resource_list_member_id
   ,       gbc.set_of_books_id
   ,       trunc(gbc.expenditure_item_date) expenditure_item_date
   ,       gbc.entered_dr
   ,       gbc.entered_cr
   ,       gbc.actual_flag
   ,       gbv.resource_list_id
   ,       pbm.time_phased_type_code
   ,       pbm.entry_level_code --2673200
   ,       gbc.document_header_id
   ,       gbc.document_distribution_id
   ,       gbc.bc_packet_id
   ,       ga.amount_type
   ,       ga.boundary_code
   ,       nvl(gbc.burdenable_raw_cost,0) burdenable_raw_cost -- this and next 4 added for bug 4053891
   ,       gbc.parent_bc_packet_id
   ,       gbc.expenditure_type
   ,       nvl(gbc.burden_adjustment_flag,'N') burden_adjustment_flag
   ,       gbc.rowid
   from    gms_budget_versions gbv
           , gms_bc_packets   gbc
           , pa_budget_entry_methods pbm
           , gms_awards_all ga
   where   gbc.status_code = x_status_code --Bug 2138376 : Replaced 'A' with x_status_code
   and     gbc.packet_id = nvl(x_packet_id, packet_id)
   and     gbv.budget_version_id = gbc.budget_version_id
   and     gbv.budget_entry_method_code = pbm.budget_entry_method_code
   and     ga.award_id = gbc.award_id
   and     gbc.project_id = nvl(x_project_id,gbc.project_id) /* Bug 3813928 */
   and     gbc.award_id   = nvl(x_award_id,gbc.award_id)     /* Bug 3813928 */
   --for     update of gbc.project_id; Bug4053891
  order by gbc.budget_version_id,gbc.expenditure_type;

   -- Bug 4053891 Start

   x_plsql_count number;
   x_loop_counter number;
   x_old_budget_version_id number;

   -- Bug 4053891 End


   x_err_code           varchar2(2):= null;
   x_err_stage          varchar2(255):= null;
   St_e_code            number;
   x_parent_member_id   number;
   x_entry_level_code   varchar2(30);
   x_st_date            date;
   x_ed_date            date;
   x_budget_task_id     number;
   x_bud_res_list_member_id     number;
   x_program_name      varchar2(30) := 'GMS_SWEEPER.UPD_ACT_ENC_BAL';
   x_stage             varchar2(10);
   temp_flag    number;
   l_counter number :=0;
   x_status_code varchar2(1) ; --Bug 2138376
   l_offset_days NUMBER; -- Bug 2155790
-------------------------------------------------------------------
/*
|| This Cursor is used in 'U' or non-baselining mode.
|| update_revenue_balance procedure is called in a loop
|| with in this cursor
*/

Cursor Cur_records is
       select distinct ga.award_id award_id, gspf.project_id project_id,imp.set_of_books_id
       from   gms_summary_project_fundings gspf,
              gms_installments gi,
              gms_awards_all ga, -- Bug 4732065 : To run the process across org
	      pa_implementations_all imp -- Bug 4732065 :
       where  gspf.installment_id = gi.installment_id
         and  gi.award_id = ga.award_id
         and  ga.revenue_distribution_rule='COST'
         and  ga.award_template_flag='DEFERRED'
	 and  ga.org_id = imp.org_id
         and (exists (select award_project_id
                     from   gms_event_intersect
                     where  award_project_id = ga.award_project_id
                     and    event_type = 'REVENUE')
                     OR exists
                      (select award_project_id
                       from   gms_billing_cancellations
                       where  award_project_id = ga.award_project_id
                       and    calling_process='Revenue')) ;

--Bug 4732065 : To fetch sob when called from baseline

Cursor c_get_sob (p_award_id IN NUMBER) IS
select set_of_books_id
  from gms_awards_all ga,
       pa_implementations_all imp
 where ga.award_id =  p_award_id
   and imp.org_id = ga.org_id;

l_sob_id   NUMBER;
-------------------------------------------------------------------

Procedure error_output(Err_table IN Err_Bal_Tab,
                        Res_table IN Fail_Tab)
IS
l_rec number :=0;
Begin

 l_rec := err_table.COUNT;

 --fnd_file.put_line(FND_FILE.OUTPUT,'---------- Records that Errored Out NOCOPY -----------');
 gms_error_pkg.gms_output('---------- Records that Errored Out NOCOPY -----------');

 for l_records in 1..l_rec
 loop

    gms_error_pkg.gms_output('----- Record Number: '||l_records||' ----');
    gms_error_pkg.gms_output('---- Record -----');

    gms_error_pkg.gms_output('Expenditure_item_id :'||Err_table(l_records).exp_item_id);
    gms_error_pkg.gms_output('Adl Line num :'||Err_table(l_records).adl);
    gms_error_pkg.gms_output('Award_id :'||Err_table(l_records).award_id);
    gms_error_pkg.gms_output('Project_Id :'||Err_table(l_records).project_id);
    gms_error_pkg.gms_output('Task_id :'||Err_table(l_records).task_id);
    gms_error_pkg.gms_output('Amount :'||Err_table(l_records).amount);
    gms_error_pkg.gms_output('Reason :'||Err_table(l_records).reason);

    gms_error_pkg.gms_output('---- Record Details ----');
    gms_error_pkg.gms_output('Person Id :'||Res_table(l_records).Person_Id);
    gms_error_pkg.gms_output('Job Id :'||Res_table(l_records).Job_id);
    gms_error_pkg.gms_output('Org_Id :'||Res_table(l_records).org_id);
    gms_error_pkg.gms_output('Expenditure_type :'||Res_table(l_records).expenditure_type);
    gms_error_pkg.gms_output('Non Labor resource :'||Res_table(l_records).nlr);
    gms_error_pkg.gms_output('Expenditure Category :'||Res_table(l_records).exp_category);
    gms_error_pkg.gms_output('Revenue Category :'||Res_table(l_records).rev_category);
    gms_error_pkg.gms_output('Non Labor resource Org Id  :'||Res_table(l_records).nlr_org_id);
    gms_error_pkg.gms_output('System Linkage :'||Res_table(l_records).sys_link);
    gms_error_pkg.gms_output('Expenditure Date :'||Res_table(l_records).exp_date);
    gms_error_pkg.gms_output('Budget Version :'||Res_table(l_records).bvid);
    gms_error_pkg.gms_output('Budgeted Task :'||Res_table(l_records).bud_task);
    gms_error_pkg.gms_output('Categorization Code :'||Res_table(l_records).cat_code);
    gms_error_pkg.gms_output('Time Phase code :'||Res_table(l_records).tp_code);
    gms_error_pkg.gms_output('--------------------------------------------------');
 end loop;

 gms_error_pkg.gms_output('---- End Report ----');

End;

--------------------------------------------------------------------
/* --------------------------------------------------------------
   *************  REVENUE UPDATION PROCEDURE STARTS *************
   -------------------------------------------------------------- */
 -- Procedure to update revenue amount  in GMS_BALANCE from Revenue
 -- related tables

Procedure update_revenue_balance(p_mode       IN varchar2 default 'U',
                                    p_award_id   IN number,
                                    p_project_id IN number,
                                    p_sob_id     IN number,
                                    error_table  IN OUT NOCOPY Err_Bal_Tab,
                                    reason_table IN OUT NOCOPY Fail_Tab) IS

l_count number := 0;
--Start of the bug 5481465
--5379433: Start
  TYPE  IdTabTyp      IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  TYPE  DateTabTyp    IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;
  TYPE  NumTabTyp     IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  TYPE  Char3TabTyp   IS TABLE OF VARCHAR2(3)
    INDEX BY BINARY_INTEGER;
  TYPE  Char30TabTyp  IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;
  TYPE  RowidTabTyp   IS TABLE OF ROWID
    INDEX BY BINARY_INTEGER;
  --5379433: End

  Cursor gms_rev1 is
      -- In this select RLMI has been derived, GEI.
        select  gad.project_id project_id,
                gad.award_id award_id,
                gad.adl_line_num adl_line_num,
                gad.cdl_line_num,
                gad.task_id task_id,
                gad.bud_task_id,
                trunc(item.expenditure_item_date) expenditure_item_date,
                gad.resource_list_member_id rlmi,
                prm.parent_member_id parent,
                gei.expenditure_item_id,
                gei.amount amount,
                'GEI' from_table,
                item.expenditure_type,
                to_number(NULL) org_id,
		gei.rowid
        from    gms_event_intersect gei,
                pa_expenditure_items_all item,
                gms_award_distributions gad ,
                pa_resource_list_members prm
        where   gei.expenditure_item_id  = gad.expenditure_item_id
        and     gei.adl_line_num         = gad.adl_line_num
        and     gei.event_type           = 'REVENUE'
--        and     gei.revenue_accumulated  = 'N'
        and     item.expenditure_item_id = gad.expenditure_item_id
        and     gad.resource_list_member_id = prm.resource_list_member_id
        and     gad.document_type='EXP'
        and     gad.adl_status='A'
        and     gad.project_id = p_project_id
        and     gad.award_id = p_award_id
	and     NVL(prm.migration_code,'M') ='M' -- Bug 3626671
        UNION ALL
        -- In this select RLMI has not been derived, GBC.
        select  gad.project_id project_id,
                gad.award_id award_id,
                gad.adl_line_num adl_line_num,
                gad.cdl_line_num,
                gad.task_id task_id,
                gad.bud_task_id,
                trunc(item.expenditure_item_date) expenditure_item_date,
                to_number(NULL) rlmi,
                prm.parent_member_id parent,
                gbc.expenditure_item_id,
                gbc.amount amount,
                'GBC' from_table,
                gbc.burden_exp_type,
                nvl(pea.incurred_by_organization_id ,item.override_to_organization_id) org_id,
		gbc.rowid
        from    gms_burden_components gbc,
                pa_expenditure_items_all item ,
                pa_expenditures_all pea,
                gms_award_distributions gad ,
                pa_resource_list_members prm
        where   gbc.expenditure_item_id  = gad.expenditure_item_id
        and     gbc.adl_line_num         = gad.adl_line_num
        and     gbc.event_type           = 'REVENUE'
 --       and     gbc.revenue_accumulated  = 'N'
        and     item.expenditure_item_id = gad.expenditure_item_id
        and     item.expenditure_id = pea.expenditure_id
        and     gad.resource_list_member_id = prm.resource_list_member_id
        and     gad.document_type='EXP'
        and     gad.adl_status='A'
        and     gad.project_id = p_project_id
        and     gad.award_id = p_award_id
	and     NVL(prm.migration_code,'M') ='M'; -- Bug 3626671
--        UNION ALL
--        select  gad.project_id project_id,
--                gad.award_id award_id,
--                gad.adl_line_num adl_line_num,
--                gad.cdl_line_num,
--                gad.task_id task_id,
--                gad.bud_task_id,
--                trunc(item.expenditure_item_date) expenditure_item_date,
--                gad.resource_list_member_id rlmi,
--                prm.parent_member_id parent,
--                gbi.expenditure_item_id,
--                gbi.bill_amount amount,
--                'GBI' from_table,
--                nvl(gbi.burden_exp_type,item.expenditure_type),
--                nvl(pea.incurred_by_organization_id,item.override_to_organization_id) org_id, gbi.rowid
--        from    gms_billing_cancellations gbi,
--                pa_expenditure_items_all item ,
--                pa_expenditures_all pea,
--                gms_award_distributions gad ,
--                pa_resource_list_members prm
--        where   gbi.expenditure_item_id = gad.expenditure_item_id
--        and     item.expenditure_item_id = gad.expenditure_item_id
--        and     gad.adl_line_num = gbi.adl_line_num
--        and     item.expenditure_id = pea.expenditure_id
--        and     gad.resource_list_member_id = prm.resource_list_member_id
--        and     gad.document_type='EXP'
--        and     gad.adl_status='A'
--        and     gad.project_id = p_project_id
--        and     gad.award_id = p_award_id
--	and     NVL(prm.migration_code,'M') ='M' -- Bug 3626671
--       ORDER BY 2,     -- award_id
--                1;     -- project_i d
--End of bug 5481465
  -- Bug 4732065: Modified below cursor to fetch org_id
  Cursor gms_rev2 is    --renamed gms_rev to gms_rev2 as pasrt of the bug 5481465
      -- In this select RLMI has been derived, GEI.
        select  gad.project_id project_id,
                gad.award_id award_id,
                gad.adl_line_num adl_line_num,
                gad.cdl_line_num,
                gad.task_id task_id,
                gad.bud_task_id,
                trunc(item.expenditure_item_date) expenditure_item_date,
                gad.resource_list_member_id rlmi,
                prm.parent_member_id parent,
                gei.expenditure_item_id,
                gei.amount amount,
                'GEI' from_table,
                item.expenditure_type,
                to_number(NULL) exp_org_id,
		gei.rowid
                --item.org_id  -- Bug 4732065  commented for the bug 5481465
        from    gms_event_intersect gei,
                pa_expenditure_items_all item,
                gms_award_distributions gad,
                pa_resource_list_members prm
        where   gei.expenditure_item_id  = gad.expenditure_item_id
        and     gei.adl_line_num         = gad.adl_line_num
        and     gei.event_type           = 'REVENUE'
        and     gei.revenue_accumulated  = 'N'
        and     item.expenditure_item_id = gad.expenditure_item_id
        and     gad.resource_list_member_id = prm.resource_list_member_id
        and     gad.document_type='EXP'
        and     gad.adl_status='A'
        --and     gad.project_id = p_project_id   /* commented for  the bug 5481465 */
        --and     gad.award_id = p_award_id   /* Commented for the bug 5481465 */
	and     NVL(prm.migration_code,'M') ='M' -- Bug 3626671
        UNION ALL
        -- In this select RLMI has not been derived, GBC.
        select  gad.project_id project_id,
                gad.award_id award_id,
                gad.adl_line_num adl_line_num,
                gad.cdl_line_num,
                gad.task_id task_id,
                gad.bud_task_id,
                trunc(item.expenditure_item_date) expenditure_item_date,
                to_number(NULL) rlmi,
                prm.parent_member_id parent,
                gbc.expenditure_item_id,
                gbc.amount amount,
                'GBC' from_table,
                gbc.burden_exp_type,
                nvl(pea.incurred_by_organization_id,item.override_to_organization_id) exp_org_id,
		gbc.rowid
		--item.org_id -- Bug 4732065 commented for  the bug 5481465
        from    gms_burden_components gbc,
                pa_expenditure_items_all item,
                pa_expenditures_all pea,
                gms_award_distributions gad,
                pa_resource_list_members prm
        where   gbc.expenditure_item_id  = gad.expenditure_item_id
        and     gbc.adl_line_num         = gad.adl_line_num
        and     gbc.event_type           = 'REVENUE'
        and     gbc.revenue_accumulated  = 'N'
        and     item.expenditure_item_id = gad.expenditure_item_id
        and     item.expenditure_id = pea.expenditure_id
        and     gad.resource_list_member_id = prm.resource_list_member_id
        and     gad.document_type='EXP'
        and     gad.adl_status='A'
--        and     gad.project_id = p_project_id  /* Commented for the bug 5481465 */
--        and     gad.award_id = p_award_id /* Commented for the bug 5481465 */
	and     NVL(prm.migration_code,'M') ='M' -- Bug 3626671
        UNION ALL
        select  gad.project_id project_id,
                gad.award_id award_id,
                gad.adl_line_num adl_line_num,
                gad.cdl_line_num,
                gad.task_id task_id,
                gad.bud_task_id,
                trunc(item.expenditure_item_date) expenditure_item_date,
                gad.resource_list_member_id rlmi,
                prm.parent_member_id parent,
                gbi.expenditure_item_id,
                gbi.bill_amount amount,
                'GBI' from_table,
                nvl(gbi.burden_exp_type,item.expenditure_type),
                nvl(pea.incurred_by_organization_id,item.override_to_organization_id) exp_org_id,
	        gbi.rowid
		--item.org_id -- Bug 4732065 commented for the bug 5481465
        from    gms_billing_cancellations gbi,
                pa_expenditure_items_all item,
                pa_expenditures_all pea,
                gms_award_distributions gad,
                pa_resource_list_members prm
        where   gbi.expenditure_item_id = gad.expenditure_item_id
        and     item.expenditure_item_id = gad.expenditure_item_id
        and     gad.adl_line_num = gbi.adl_line_num
        and     item.expenditure_id = pea.expenditure_id
        and     gad.resource_list_member_id = prm.resource_list_member_id
        and     gad.document_type='EXP'
        and     gad.adl_status='A'
--       and     gad.project_id = p_project_id /* Commented for the bug 5481465 */
--        and     gad.award_id = p_award_id  /* Commented for the bug 5481465 */
	and     NVL(prm.migration_code,'M') ='M' -- Bug 3626671
       ORDER BY 2,     -- award_id
                1;     -- project_id

  x_expenditure_type varchar2(60);

  x_start_date date;
  x_end_date date;

  x_set_of_books_id number;
  x_amount_type     gms_awards_all.amount_type%type := null;
  x_boundary_code   gms_awards_all.boundary_code%type := null;
  x_resource_list_member_id number(30);
  St_Err_Buff  varchar2(2000) := null;
  x_e_code    number;
  x_stage     varchar2(100);
  St_Err_Code varchar2(1);
  x_budget_version_id gms_budget_versions.budget_version_id%type;

  x_budget_entry_method   pa_budget_entry_methods.budget_entry_method%type;
  x_categorization_code   pa_budget_entry_methods.categorization_code%type;
  x_resource_list_id      gms_budget_versions.resource_list_id%type;
  x_time_phased_type_code pa_budget_entry_methods.time_phased_type_code%type;
  x_uncategorized_rlmi    pa_resource_list_members.resource_list_member_id%type;
  x_prev_list_processed         number(30);
  x_group_resource_type_id      number(15);
  x_group_resource_type_name    varchar2(60);
  x_resource_type_tab           gms_res_map.resource_type_table;
  x_entry_level_code            pa_budget_entry_methods.entry_level_code%type; --2673200

   --5481465: Start
  l_project_id_tbl      IdTabTyp;
  l_award_id_tbl        IdTabTyp;
  l_adl_ln_num_id_tbl   IdTabTyp;
  l_cdl_ln_num_id_tbl   IdTabTyp;
  l_task_id_tbl         IdTabTyp;
  l_bud_task_id_tbl     IdTabTyp;
  l_ei_date_tbl         DateTabTyp;
  l_rlmi_tbl            IdTabTyp;
  l_prnt_member_id_tbl  IdTabTyp;
  l_ei_id_tbl           IdTabTyp;
  l_amount_tbl          NumTabTyp;
  l_fr_tab_tbl          Char3TabTyp;
  l_exp_type_tbl        Char30TabTyp;
  l_org_id_tbl          IdTabTyp;
  l_rowid_tbl           RowidTabTyp;

  v_max_size NUMBER := 500;
  v_all_done NUMBER := 0;
  x_old_award_id NUMBER;
  x_old_project_id NUMBER;
  --5481465: End

 Begin

  -- 1. Update revenue amout in GMS_BALANCES for each record in gms_rev cursor.

        -- Bug 4732065: Shifted logic for deriving SOB inside LOOP
-- Start of the bug 5481465

          x_set_of_books_id := p_sob_id;

   If p_mode ='B' then
    OPEN gms_rev1;
   Else
    OPEN gms_rev2;
   end if;

  while(v_all_done = 0) loop
   If p_mode ='B' then
    FETCH gms_rev1 BULK COLLECT INTO
        l_project_id_tbl,
        l_award_id_tbl,
        l_adl_ln_num_id_tbl,
        l_cdl_ln_num_id_tbl,
        l_task_id_tbl,
        l_bud_task_id_tbl,
        l_ei_date_tbl,
        l_rlmi_tbl,
        l_prnt_member_id_tbl,
        l_ei_id_tbl,
        l_amount_tbl,
        l_fr_tab_tbl,
        l_exp_type_tbl,
        l_org_id_tbl,
        l_rowid_tbl
    LIMIT v_max_size;
   Else
    FETCH gms_rev2 BULK COLLECT INTO
        l_project_id_tbl,
        l_award_id_tbl,
        l_adl_ln_num_id_tbl,
        l_cdl_ln_num_id_tbl,
        l_task_id_tbl,
        l_bud_task_id_tbl,
        l_ei_date_tbl,
        l_rlmi_tbl,
        l_prnt_member_id_tbl,
        l_ei_id_tbl,
        l_amount_tbl,
        l_fr_tab_tbl,
        l_exp_type_tbl,
        l_org_id_tbl,
        l_rowid_tbl
    LIMIT v_max_size;
   END IF;

  If l_rowid_tbl.COUNT = 0 then
     exit;
  End If;

FOR i IN  l_rowid_tbl.FIRST..l_rowid_tbl.LAST  LOOP
/*  Commented and added new condtion with OR bug#7582155
if (nvl(x_old_award_id,-1) <> l_award_id_tbl(i)
             and nvl(x_old_project_id,-1) <> l_project_id_tbl(i)) then */
if (nvl(x_old_award_id,-1) <> l_award_id_tbl(i)
             OR nvl(x_old_project_id,-1) <> l_project_id_tbl(i)) then

--End of the bug 5481465

  -- 2. Get budget version id

      x_stage:='Get Budget Version Id';

      Begin

       select budget_version_id
       into x_budget_version_id
       from gms_budget_versions
       where project_id = l_project_id_tbl(i) -- p_project_id  as part of the bug 5481465
       and award_id = l_award_id_tbl(i) -- p_award_id  as part of the bug 5481465
       and budget_type_code ='AC'
       and budget_status_code = 'B'
       and current_flag='Y';
     Exception
       when others then

       x_budget_version_id := NULL;

     End;

     If x_budget_version_id is null then

        GOTO NO_PROCESS1;
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('No processing','C');
        END IF;

     End if;

     IF L_DEBUG = 'Y' THEN
     	   gms_error_pkg.gms_debug('Project_id, Award_id, Budget_version_id:'||l_project_id_tbl(i)||','||l_award_id_tbl(i)||','||x_budget_version_id,'C');
     END IF;

     -- 3. Initialize revenue records

     If p_mode ='B' then

       x_stage:='Initialize records in baseline mode';

       /*intialize_revenue_records(p_award_id,p_project_id,x_e_code,St_Err_Buff);  commented and added  below line as part of the bug 5481465 */
       intialize_revenue_records(l_award_id_tbl(i),l_project_id_tbl(i),x_e_code,St_Err_Buff);

     End if;

    -- 4. Get Amount type, Boundary Code

       x_stage:='Get Amount Type, Boundary Code';

       Begin
       if (nvl(x_old_award_id,-1) <> l_award_id_tbl(i)) then  --added for the bug 5481465
       Select amount_type, boundary_code
       Into   x_amount_type, x_boundary_code
       From   gms_awards_all
       Where  award_id = l_award_id_tbl(i); --p_award_id; for bug 5481465

      End If;  /* for bug 5481465 */
       Exception

       When others then
            RAISE;
            -- Will call main exception
       End;

       IF L_DEBUG = 'Y' THEN
       	gms_error_pkg.gms_debug('Amount_type,Boundary_code:'|| x_amount_type||','||x_boundary_code,'C');
       END IF;

    -- 5. Get Resource List Id and Categorization Code

       x_stage:='Get Resource_List_Id, Categorization,TPC';

       Begin

        Select a.resource_list_id,
               b.categorization_code,
               b.time_phased_type_code,
               b.entry_level_code --2673200
        into   x_resource_list_id,
               x_categorization_code,
               x_time_phased_type_code ,
               x_entry_level_code --2673200
        from   gms_budget_versions a,
               pa_budget_entry_methods b
        where  a.budget_version_id = x_budget_version_id
        and    b.budget_entry_method_code = a.budget_entry_method_code;

       Exception

         When Others then
              RAISE;

       End;

    -- 6. Get RLMI for Uncategorized resources.
       If  x_categorization_code <> 'R' then

           x_stage:='Get RLMI for Uncategorized';

           Begin

             select resource_list_member_id
             into   x_uncategorized_rlmi
             from   pa_resource_list_members
             where  resource_list_id = x_resource_list_id
     	       and  NVL(migration_code,'M') ='M'; -- Bug 3626671

           Exception

             When Others then
                  RAISE;
           End;

       End if; --If  x_categorization_code <> 'R' then
End If;  --if (nvl(x_old_award_id,-1) <> l_award_id_tbl(i) and nvl(x_old_project_id,-1) <> l_project_id_tbl(i))   for bug 5481465

    -- 4. Revenue Txns. processing

    /*for rev_gen in  gms_rev
    loop */  /* commented for the bug 5481465 */

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('Expenditure_item_id,Adl_line_Num:'||l_ei_id_tbl(i)||','||l_adl_ln_num_id_tbl(i),'C');
        gms_error_pkg.gms_debug('Amount,Table:'||l_amount_tbl(i)||','||l_fr_tab_tbl(i),'C');
    END IF;

    x_stage :='Get Set of Books Id';
    -- x_set_of_books_id := p_sob_id; /* Commented for bug 9134876*/

	/* Added for bug 9134876*/
	if p_mode <> 'B' and (nvl(x_old_award_id,-1) <> l_award_id_tbl(i)) then
		OPEN c_get_sob (l_award_id_tbl(i));
		FETCH  c_get_sob INTO x_set_of_books_id;
		CLOSE c_get_sob ;
	end if;


    -- 4a. Calculate RLMI

    x_stage:='Get RLMI';

    If  x_categorization_code <> 'R' then   -- Uncategorized value 'N'

        x_resource_list_member_id := x_uncategorized_rlmi;

    Elsif x_categorization_code = 'R' then

/*       x_resource_list_member_id:=rev_gen.rlmi;  as part of bug and added below line */
         x_resource_list_member_id:=l_rlmi_tbl(i);

       If x_resource_list_member_id is null then

          x_stage:='Get RLMI for Categorized';

          gms_res_map.map_resources('EXP',                         --x_document_type,
                                    l_ei_id_tbl(i),--rev_gen.expenditure_item_id,   --x_document_header_id /* changed parameter for the bug 5481465 */
                                    l_cdl_ln_num_id_tbl(i),--rev_gen.cdl_line_num,          --x_document_distribution_id /* changed parameter for the bug 5481465 */
                                    l_exp_type_tbl(i),--rev_gen.expenditure_type,      --x_expenditure_type /* changed parameter for the bug 5481465 */
                                    l_org_id_tbl(i),--rev_gen.exp_org_id,            --x_expenditure_org_id /* changed parameter for the bug 5481465 */
                                    'R',                           --x_categorization_code
                                    x_resource_list_id,            --x_resource_list_id
                                    NULL,                          --x_event_type
                                    x_prev_list_processed,
                                    x_group_resource_type_id,
                                    x_group_resource_type_name,
                                    x_resource_type_tab,
                                    x_resource_list_member_id,
                                    x_e_code,
                                    St_Err_Buff);


       End If;

    End if; --if x_categorization_code = .....

         IF L_DEBUG = 'Y' THEN
         	gms_error_pkg.gms_debug('RLMI :'||x_resource_list_member_id,'C');
         END IF;

                 if x_resource_list_member_id is null then

                                l_count:=error_table.COUNT;
                                l_count:=l_count+1;

                                error_table(l_count).exp_item_id :=l_ei_id_tbl(i);--rev_gen.expenditure_item_id;  /* As part of the bug 5481465 */
                                error_table(l_count).adl :=l_adl_ln_num_id_tbl(i);--rev_gen.adl_line_num;  /* As part of the bug 5481465 */
                                error_table(l_count).award_id := l_award_id_tbl(i);--rev_gen.award_id;  /* As part of the bug 5481465 */
                                error_table(l_count).project_id :=l_project_id_tbl(i);--rev_gen.project_id;  /* As part of the bug 5481465 */
                                error_table(l_count).task_id := l_task_id_tbl(i);--rev_gen.task_id;  /* As part of the bug 5481465 */
                                error_table(l_count).amount:=l_amount_tbl(i);--rev_gen.amount;  /* As part of the bug 5481465 */
                                error_table(l_count).reason:= 'Revenue Item: Resource mapping Failure';

                                reason_table(l_count).resource_list_id:=x_resource_list_id;
                                reason_table(l_count).org_id:=l_org_id_tbl(i);--rev_gen.exp_org_id;  /* As part of the bug 5481465 */
                                reason_table(l_count).expenditure_type:=l_exp_type_tbl(i);--rev_gen.expenditure_type; /* As part of the bug 5481465 */
                                reason_table(l_count).exp_date:=l_ei_date_tbl(i);--rev_gen.expenditure_item_date; /* As part of the bug 5481465 */
                                reason_table(l_count).bvid:=x_budget_version_id;
                                reason_table(l_count).bud_task:=l_bud_task_id_tbl(i);--rev_gen.bud_task_id; /* As part of the bug 5481465 */
                                reason_table(l_count).cat_code:=x_categorization_code;
                                reason_table(l_count).tp_code:=x_time_phased_type_code;

                                GOTO NO_PROCESS;

                 end if;

                        -- 4c. Update balance

                        x_stage:='Update balance';

                        UPDATE  gms_balances gb
                             set revenue_period_to_date = nvl(revenue_period_to_date,0) + nvl(l_amount_tbl(i),0) --nvl(rev_gen.amount,0) as part of the bug 5481465
                        WHERE   gb.project_id =  l_project_id_tbl(i) --rev_gen.project_id as part of the bug 5481465
                        AND     gb.award_id =  l_award_id_tbl(i)--rev_gen.award_id  as part of the bug 5481465
                        AND     (gb.task_id     = l_task_id_tbl(i) --rev_gen.task_id  as part of the bug 5481465
                             or  gb.task_id is null)
                        AND     (gb.resource_list_member_id = x_resource_list_member_id
                             or  gb.resource_list_member_id is null)
                        AND     gb.set_of_books_id = x_set_of_books_id
                        AND     gb.budget_version_id = x_budget_version_id
                        AND     gb.balance_type = 'REV'
                        AND     /*rev_gen.expenditure_item_date for bug 5481465*/l_ei_date_tbl(i)  between   gb.start_date and gb.end_date
                        AND     rownum = 1;



                        IF (SQL%NOTFOUND) THEN

                   IF L_DEBUG = 'Y' THEN
                   	gms_error_pkg.gms_debug('No Balance Line Updated','C');
                   END IF;

                        -- 4d. Calculate Start and End date.

                        x_stage:='Calculate Dates';

                                if x_time_phased_type_code = 'G' then
                                        select gps.start_date, gps.end_date
                                        into   x_start_date, x_end_date
                                        from   gl_period_statuses gps
                                        where  gps.application_id = 101
                                        and     gps.set_of_books_id = x_set_of_books_id
                                        and    /*rev_gen.expenditure_item_date for bug 5481465*/ l_ei_date_tbl(i) between gps.start_date and gps.end_date
                                        and     gps.adjustment_period_flag = 'N';

                                elsif x_time_phased_type_code = 'P' then
                                        select start_date , end_date
                                        into x_start_date , x_end_date
                                        from pa_periods gpa    /* Bug 6721990: Replaced pa_periods_all with pa_periods */
                                        where  /* rev_gen.expenditure_item_date for bug 5481465 */ l_ei_date_tbl(i) between gpa.start_date and gpa.end_date;

                                elsif x_time_phased_type_code in ('R','N') then

                                       -- get the dates for the period from balances. there should always be
                                       -- a record in balances as actuals are already posted. Bug 3487431

                                       select gb.start_date, gb.end_date
                                         into x_start_date, x_end_date
                                         from gms_balances gb
                                        where gb.budget_version_id = x_budget_version_id
                                          and /* rev_gen.expenditure_item_date for bug 5481465 */ l_ei_date_tbl(i) between
                                                      gb.start_date and gb.end_date
                                          and rownum = 1;

                               end if;

                        If x_start_date is null then

                                l_count:=error_table.COUNT;
                                l_count:=l_count+1;

                                error_table(l_count).exp_item_id :=l_ei_id_tbl(i);--rev_gen.expenditure_item_id; /* For bug 5481465 */
                                error_table(l_count).adl :=l_adl_ln_num_id_tbl(i);--rev_gen.adl_line_num; /* For bug 5481465 */
                                error_table(l_count).award_id := l_award_id_tbl(i);--rev_gen.award_id; /* For bug 5481465 */
                                error_table(l_count).project_id :=l_project_id_tbl(i);--rev_gen.project_id; /* For bug 5481465 */
                                error_table(l_count).task_id := l_task_id_tbl(i);--rev_gen.task_id; /* For bug 5481465 */
                                error_table(l_count).amount:=l_amount_tbl(i);--rev_gen.amount;  /* For bug 5481465 */
                                error_table(l_count).reason:= 'Revenue Item: Start Date Null';

                                reason_table(l_count).resource_list_id:=x_resource_list_id;
                                /*reason_table(l_count).org_id:=rev_gen.exp_org_id;
                                reason_table(l_count).expenditure_type:=rev_gen.expenditure_type;
                                reason_table(l_count).exp_date:=rev_gen.expenditure_item_date; commented and added below lines for bug 5481465*/
                                reason_table(l_count).org_id:=l_org_id_tbl(i);
                                reason_table(l_count).expenditure_type:=l_exp_type_tbl(i);
                                reason_table(l_count).exp_date:=l_ei_date_tbl(i);

                                reason_table(l_count).bvid:=x_budget_version_id;
                                reason_table(l_count).bud_task:=l_bud_task_id_tbl(i);--rev_gen.bud_task_id;  for bug 5481465
                                reason_table(l_count).cat_code:=x_categorization_code;
                                reason_table(l_count).tp_code:=x_time_phased_type_code;
                                GOTO NO_PROCESS;

                        END if;

                        If x_end_date is null then

                                l_count:=error_table.COUNT;
                                l_count:=l_count+1;

                                error_table(l_count).exp_item_id :=l_ei_id_tbl(i);--rev_gen.expenditure_item_id; /* For bug 5481465 */
                                error_table(l_count).adl :=l_adl_ln_num_id_tbl(i);--rev_gen.adl_line_num; /* For bug 5481465 */
                                error_table(l_count).award_id := l_award_id_tbl(i);--rev_gen.award_id; /* For bug 5481465 */
                                error_table(l_count).project_id :=l_project_id_tbl(i);--rev_gen.project_id; /* For bug 5481465 */
                                error_table(l_count).task_id :=l_task_id_tbl(i);-- rev_gen.task_id; /* For bug 5481465 */
                                error_table(l_count).amount:=l_amount_tbl(i);--rev_gen.amount;  /* For bug 5481465 */
                                error_table(l_count).reason:= 'Revenue Item: End Date Null';

                                reason_table(l_count).resource_list_id:=x_resource_list_id;
                                /*reason_table(l_count).org_id:=rev_gen.exp_org_id;
                                reason_table(l_count).expenditure_type:=rev_gen.expenditure_type;
                                reason_table(l_count).exp_date:=rev_gen.expenditure_item_date;  commented and added below lines for bug 5481465*/
                                reason_table(l_count).org_id:=l_org_id_tbl(i);
                                reason_table(l_count).expenditure_type:=l_exp_type_tbl(i);
                                reason_table(l_count).exp_date:=l_ei_date_tbl(i);


                                reason_table(l_count).bvid:=x_budget_version_id;
                                reason_table(l_count).bud_task:=l_bud_task_id_tbl(i);--rev_gen.bud_task_id; /* For bug 5481465 */
                                reason_table(l_count).cat_code:=x_categorization_code;
                                reason_table(l_count).tp_code:=x_time_phased_type_code;

                                GOTO NO_PROCESS;

                        END if;

                        x_stage:='Insert New Balance';

                                        insert into gms_balances (project_id
                                                                ,award_id
                                                                ,task_id
                                                                ,resource_list_member_id
                                                                ,set_of_books_id
                                                                ,budget_Version_id
                                                                ,balance_type
                                                                ,last_update_date
                                                                ,last_updated_by
                                                                ,created_by
                                                                ,creation_date
                                                                ,last_update_login
                                                                ,start_date
                                                                ,end_date
                                                                ,parent_member_id
                                                                ,revenue_period_to_date
                                                                )
                                                                values
                                                                (l_project_id_tbl(i)--rev_gen.project_id /* For bug 5481465 */
                                                                ,l_award_id_tbl(i)--rev_gen.award_id /* For bug 5481465 */
                                                                ,l_task_id_tbl(i)--rev_gen.task_id /* For bug 5481465 */
                                                                ,x_resource_list_member_id
                                                                ,x_set_of_books_id
                                                                ,x_budget_version_id
                                                                ,'REV'
                                                                ,sysdate
                                                                ,FND_GLOBAL.USER_ID
                                                                ,FND_GLOBAL.USER_ID
                                                                ,sysdate
                                                                ,FND_GLOBAL.LOGIN_ID
                                                                ,x_start_date
                                                                ,x_end_date
                                                                ,l_prnt_member_id_tbl(i) --rev_gen.parent
                                                                ,l_amount_tbl(i) --rev_gen.amount
                                                                );

                                IF L_DEBUG = 'Y' THEN
                                	gms_error_pkg.gms_debug('After Balance Line Insert','C');
                                END IF;
                        end if;

                        x_stage:='Updating revenue records';

                                --2. Update the resource_accumulated = 'Y'
                                /*if rev_gen.from_table = 'GEI' then commented and added below condition for bug 5481465*/
                                  if l_fr_tab_tbl(i) = 'GEI' then
                                        update gms_event_intersect
                                        set revenue_accumulated = 'Y'
                                        where rowid = l_rowid_tbl(i);--rev_gen.rowid; for bug 5481465
                                /*elsif   rev_gen.from_table = 'GBC' then commented and added below condition for bug 5481465*/
                                elsif   l_fr_tab_tbl(i) = 'GBC' then
                                        update gms_burden_components
                                        set revenue_accumulated = 'Y'
                                        where rowid = l_rowid_tbl(i);--rev_gen.rowid; for bug 5481465
                                /*elsif   rev_gen.from_table = 'GBI' then  commented and added below condition for bug 5481465*/
                                elsif   l_fr_tab_tbl(i) = 'GBI' then
                                        delete from gms_billing_cancellations
                                        where rowid = l_rowid_tbl(i);--rev_gen.rowid; for bug 5481465
                                end if;
        x_old_award_id :=  l_award_id_tbl(i) ;
        x_old_project_id  := l_project_id_tbl(i);

        <<NO_PROCESS>>
          NULL;
                end loop;
-- start of the bug 5481465
    l_project_id_tbl.delete;
    l_award_id_tbl.delete;
    l_adl_ln_num_id_tbl.delete;
    l_cdl_ln_num_id_tbl.delete;
    l_task_id_tbl.delete;
    l_bud_task_id_tbl.delete;
    l_ei_date_tbl.delete;
    l_rlmi_tbl.delete;
    l_prnt_member_id_tbl.delete;
    l_ei_id_tbl.delete;
    l_amount_tbl.delete;
    l_fr_tab_tbl.delete;
    l_exp_type_tbl.delete;
    l_org_id_tbl.delete;
  If (l_rowid_tbl.COUNT < v_max_size) then
    l_rowid_tbl.delete;
    exit;
  Else
    l_rowid_tbl.delete;
  End If;

--    End Loop; -- Cursor loop

  If p_mode ='B' then
   EXIT WHEN gms_rev1%NOTFOUND;
  Else
   EXIT WHEN gms_rev2%NOTFOUND;
  END IF;
end loop;

     If p_mode ='B' then
      CLOSE gms_rev1;
     Else
      CLOSE gms_rev2;
     End If;

--End of bug 5481465

        <<NO_PROCESS1>>
         NULL;
exception
        when others then
      gms_error_pkg.gms_message('GMS_UNEXPECTED_ERROR',
                                'SQLCODE',
                                SQLCODE,
                                'SQLERRM',
                                SQLERRM,
                                X_token_name5 => 'PROGRAM_NAME',
                                X_token_val5 => 'GMS_SWEEPER.update_revenue_balance, Stage: '|| X_Stage,
                                X_Exec_Type => 'C',
                                X_Err_Code => St_Err_Code,
                                X_Err_Buff => St_Err_Buff);
end update_revenue_balance;
/* -------------------------------------------------------------
   *************  REVENUE UPDATION PROCEDURE ENDS *************
   ------------------------------------------------------------- */
-------------------------------------------------------------------
-- MAIN BEGIN STARTS HERE ---

   BEGIN

   gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

   -- Initialize error tables
   upd_error_table.delete;
   upd_reason_table.delete;

   if x_mode = 'B' then  --> baseline calls with mode = 'B'
      x_status_code := 'B';
   else --> mode = 'U'
      x_status_code := 'A';
   end if;

      IF L_DEBUG = 'Y' THEN
   	gms_error_pkg.gms_debug('---------- Budget Balance Process Starts ----','C');

        gms_error_pkg.gms_debug('Baselining for Project_ID :'||x_project_id,'C');
        gms_error_pkg.gms_debug('Baselining for Award_ID :'||x_award_id,'C');

   END IF;

        --Bug 4732065 : Shifted the code to fetch set of books id as part of Main cursors

        -- Bug 2155790 : Added the following code to fetch the value for l_offset_days from
        --               from the profile GMS_PURGE_FUNDS_CHECK_RESULTS .

        BEGIN

           FND_PROFILE.GET('GMS_PURGE_FUNDS_CHECK_RESULTS', l_offset_days);

           IF l_offset_days IS NULL THEN
                IF L_DEBUG = 'Y' THEN
                	gms_error_pkg.gms_debug('Profile GMS_PURGE_FUNDS_CHECK_RESULTS cannot have NULL value','C');
                	gms_error_pkg.gms_debug('Defaulting the value of GMS_PURGE_FUNDS_CHECK_RESULTS profile to 3','C');
                END IF;
                l_offset_days :=3 ;
           ELSIF (l_offset_days < 1 ) THEN
                IF L_DEBUG = 'Y' THEN
                	gms_error_pkg.gms_debug('Profile GMS_PURGE_FUNDS_CHECK_RESULTS cannot have value '||l_offset_days||' which is less than 1','C');
                	gms_error_pkg.gms_debug('Defaulting the value of GMS_PURGE_FUNDS_CHECK_RESULTS profile to 3','C');
                END IF;
                l_offset_days :=3 ;

           END IF;

       Exception
        When value_error then
               IF L_DEBUG = 'Y' THEN
               	gms_error_pkg.gms_debug('Invalid character type value is assigned to Profile GMS_PURGE_FUNDS_CHECK_RESULTS',
'C');
               	gms_error_pkg.gms_debug('Defaulting the value of GMS_PURGE_FUNDS_CHECK_RESULTS profile to 3','C');
               END IF;
               l_offset_days :=3;
       END;

        -- End of code modifications done for bug 2155790


-- Bug 3487431... moved revenue posting from here to after actuals posting.

    --## Records would be deleted from gms_bc_packets only in normal 'U' mode
     If x_mode <> 'B' then


        ---------------------------------------------------------------------------------- +
        x_stage             := '100'; -- Delete old records from gms_bc_packets
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('Deleting old records from GMS','C');
        END IF;

         -- Bug 2155790 : Removed the trunc function and replaced 3 with l_offset_days
        delete from gms_bc_packets
        where  status_code IN ('R', 'T', 'S', 'F','C','I','P','E','X')
        and    (sysdate - creation_date) >= l_offset_days;

        --R12 Fundscheck Management uptake: Logic added to delete records in P status associated with inactive session.
	delete from gms_bc_packets gms
        where  status_code IN ('P')
        and    NOT EXISTS (SELECT 'x'
			     FROM v$session
			    WHERE audsid = gms.session_id
		              and Serial# = gms.serial_id);

        ---------------------------------------------------------------------------------- +
        x_stage             := '200'; -- Delete from gms_bc_packet_arrival_order
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('Deleting records from arrival order table','C');
        END IF;

        DELETE      gms_bc_packet_arrival_order ao
        WHERE NOT EXISTS (
                     SELECT 1
                       FROM gms_bc_packets
                      WHERE packet_id = ao.packet_id
                      );

        COMMIT;

        ---------------------------------------------------------------------------------- +
         x_stage             := '250'; -- delete transactions left in pending state
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('Deleting transactions left in pending state','C');
        END IF;

        gms_funds_control_pkg.delete_pending_txns(retcode,errbuf);
        -- Note: Above mentioned procedure will not handle exception , so if there is any error
        -- it will fall to when others ...

        COMMIT;

    End if; --  If x_mode <> 'B' then

    -- Bug 4053891 Starts

       x_plsql_count :=0;
       x_old_budget_version_id :=-999;
       x_loop_counter :=0;
       -- Do not add any more commits in the program then that is already present --K.Biju

    -- Bug 4053891  Ends

        x_stage             := '300'; -- Before loop of gms_bc_packet
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('Start Loop for Updation','C');
        	gms_error_pkg.gms_debug('----------------------------------------------','C');
        END IF;

     FOR rec_gms_packets  IN c_gms_packets(x_status_code) --Added parameter to fix bug 2138376
       LOOP
        BEGIN

           -- Bug 4053891 Starts
           ---------------------------------------------------------------------------------- +
           -- Code flow in the loop
           -- * Post burden and commit if 100 records have already been processed or
           --   budget version id changed. COMMIT after posting.
           --   Else
           --   * Record burden
           --   * Update balance (Not changed)
           --   * Update ADL     (Not changed)
           --   * Update gms_bc_packets
           ---------------------------------------------------------------------------------- +
         x_stage             := '325';
        IF L_DEBUG = 'Y' THEN
                gms_error_pkg.gms_debug('Check if burden to be posted','C');
        END IF;

        If x_mode <> 'B' then
         If (x_loop_counter = 100 or
             (x_old_budget_version_id <> -999 and
              x_old_budget_version_id <>  rec_gms_packets.budget_version_id)
             ) then
             -- Batch limit 100 reached or budget version changed:
             -- * Post Burden
             -- * Initalize variables
             -- * Commit
             If Tab_Award_exp_burden.exists(1) then
                x_plsql_count := Tab_Award_exp_burden.count;
             End If;

             -- * Post Burden
             If x_plsql_count > 0 then

                 x_stage             := '350';
                 IF L_DEBUG = 'Y' THEN
                    gms_error_pkg.gms_debug('Posting burden for bvid:'||x_old_budget_version_id,'C');
                 END IF;

                POST_BURDEN_AMOUNTS(x_plsql_count,Tab_Award_exp_burden,x_err_code);

                If  x_err_code = 'E' then

                    IF L_DEBUG = 'Y' THEN
                       gms_error_pkg.gms_debug('Error Code after posting burden(E->Failure):'||x_err_code,'C');
                    END IF;

                    ROLLBACK to SAVEPOINT A;
                    If Tab_Award_exp_burden.exists(1) then
                       Tab_Award_exp_burden.delete;
                    End If;
                    GOTO NO_PROCESS;

                End If;

                 IF L_DEBUG = 'Y' THEN
                    gms_error_pkg.gms_debug('Burden posted for bvid:'||x_old_budget_version_id,'C');
                 END IF;

             End If; --If x_plsql_count > 0 then

             -- * Initalize variables
             x_loop_counter := 0;
             x_plsql_count  := 0;
             x_old_budget_version_id :=  rec_gms_packets.budget_version_id;

             If Tab_Award_exp_burden.exists(1) then
                Tab_Award_exp_burden.delete;
             End If;

             -- * Commit
             Commit;

         End If; -- If burden posting reqd.

        SAVEPOINT A;

        -- Normal processing ..
        x_loop_counter := x_loop_counter + 1;

        x_stage             := '360';
        IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('Recording burden','C');
        END IF;

        -- Record Burden amounts
        If  ((rec_gms_packets.burden_adjustment_flag = 'N' and
              rec_gms_packets.parent_bc_packet_id is null)
              -- original raw line
              OR
             (rec_gms_packets.burden_adjustment_flag = 'Y' and
              rec_gms_packets.burdenable_raw_cost <> 0)
              -- Burden adjustment line (Raw portion)
             ) then

             -- Lock records ...
             If x_loop_counter = 1 then
                Lock_budget_versions(rec_gms_packets.budget_version_id);
                --Tab_Award_exp_burden := Tab_Award_exp();
             End If;

             -- Record Burden amounts
            Record_burden_amounts(rec_gms_packets.award_id,
                                  rec_gms_packets.expenditure_type,
                                  nvl(rec_gms_packets.entered_dr,0) -   nvl(rec_gms_packets.entered_cr,0),
                                  rec_gms_packets.burdenable_raw_cost,
                                  rec_gms_packets.document_type,
                                  Tab_Award_exp_burden,
                                  x_err_code);
            If  x_err_code = 'E' then
                IF L_DEBUG = 'Y' THEN
                   gms_error_pkg.gms_debug('Burden recording failed for bvid,award_id,expenditure type,doc_type:'||
                                           rec_gms_packets.budget_version_id||','||rec_gms_packets.award_id||
                                           ','||rec_gms_packets.expenditure_type||','||
                                           rec_gms_packets.document_type,'C');
                END IF;
                ROLLBACK to SAVEPOINT A;
                    GOTO NO_PROCESS;
            End If;
        End If;
      End If; -- If x_mode <> 'B' then

   ---------------------------------------------------------------------------------------------------+
   -- Bug 4053891 Ends


                x_stage             := '400';  -- Update GMS_BALANCES record
        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('----------------------------------------------','C');
                	gms_error_pkg.gms_debug('Expenditure --> '||to_char(rec_gms_packets.document_header_id),'C');
                	gms_error_pkg.gms_debug('Adl --> '||to_char(rec_gms_packets.document_distribution_id),'C');
                	gms_error_pkg.gms_debug('Award --> '||to_char(rec_gms_packets.award_id),'C');
                	gms_error_pkg.gms_debug('Project --> '||to_char(rec_gms_packets.project_id),'C');
                	gms_error_pkg.gms_debug('Task --> '||to_char(rec_gms_packets.task_id),'C');
                	gms_error_pkg.gms_debug('Budget Version --> '||to_char(rec_gms_packets.budget_version_id),'C');
                	gms_error_pkg.gms_debug('Document --> '||rec_gms_packets.document_type,'C');
                END IF;


	 /* Bug 5956576: Base Bug 5956576 - Changes start */
 	 /* UPDATE sql commented and rewritten into two separate queries
 	 inside IF..ELSE blocks based on rec_gms_packets.document_type */

/*
                UPDATE  gms_balances gb
                SET     gb.actual_period_to_date = nvl(gb.actual_period_to_date,0) +
                                (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
                                         decode(rec_gms_packets.document_type,'EXP',1,0),
                        gb.encumb_period_to_date = nvl(gb.encumb_period_to_date,0) +
                                (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
                                         decode(rec_gms_packets.document_type,'REQ',1,'PO',1,'AP',1,'ENC',1,0)
                WHERE   gb.project_id = rec_gms_packets.project_id
                AND     gb.award_id = rec_gms_packets.award_id
                AND     ((rec_gms_packets.document_type = 'BGT'
                     and gb.task_id     = rec_gms_packets.bud_task_id)
                   OR (rec_gms_packets.document_type <>'BGT' -- Bug 2138376 : changed to <> as per GSCC standards
                     and gb.task_id=rec_gms_packets.task_id))
                AND     gb.resource_list_member_id = rec_gms_packets.resource_list_member_id
                AND     gb.set_of_books_id = rec_gms_packets.set_of_books_id
                AND     gb.budget_version_id = rec_gms_packets.budget_version_id
                AND     gb.balance_type = rec_gms_packets.document_type
                AND     rec_gms_packets.expenditure_item_date between   gb.start_date and gb.end_date
                AND     rownum = 1;
*/
              IF (rec_gms_packets.document_type = 'BGT') THEN

 	                 UPDATE  gms_balances gb
 	                 SET     gb.actual_period_to_date = nvl(gb.actual_period_to_date,0) +
 	                                 (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
 	                                          decode(rec_gms_packets.document_type,'EXP',1,0),
 	                         gb.encumb_period_to_date = nvl(gb.encumb_period_to_date,0) +
 	                                 (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
 	                                          decode(rec_gms_packets.document_type,'REQ',1,'PO',1,'AP',1,'ENC',1,0)
 	                 WHERE   gb.project_id = rec_gms_packets.project_id
 	                 AND     gb.award_id = rec_gms_packets.award_id
 	                 AND     gb.task_id     = rec_gms_packets.bud_task_id --Bug5875538 for Perf. Fix
 	                 AND     gb.resource_list_member_id = rec_gms_packets.resource_list_member_id
 	                 AND     gb.set_of_books_id = rec_gms_packets.set_of_books_id
 	                 AND     gb.budget_version_id = rec_gms_packets.budget_version_id
 	                 AND     gb.balance_type = rec_gms_packets.document_type
 	                 AND     rec_gms_packets.expenditure_item_date between   gb.start_date and gb.end_date
 	                 AND     rownum = 1;

 	               ELSIF (rec_gms_packets.document_type <>'BGT') THEN

 	                 UPDATE  gms_balances gb
 	                 SET     gb.actual_period_to_date = nvl(gb.actual_period_to_date,0) +
 	                                 (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
 	                                          decode(rec_gms_packets.document_type,'EXP',1,0),
 	                         gb.encumb_period_to_date = nvl(gb.encumb_period_to_date,0) +
 	                                 (nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
 	                                          decode(rec_gms_packets.document_type,'REQ',1,'PO',1,'AP',1,'ENC',1,0)
 	                 WHERE   gb.project_id = rec_gms_packets.project_id
 	                 AND     gb.award_id = rec_gms_packets.award_id
 	                 AND     gb.task_id=rec_gms_packets.task_id  --Bug5875538 for Perf. Fix
 	                 AND     gb.resource_list_member_id = rec_gms_packets.resource_list_member_id
 	                 AND     gb.set_of_books_id = rec_gms_packets.set_of_books_id
 	                 AND     gb.budget_version_id = rec_gms_packets.budget_version_id
 	                 AND     gb.balance_type = rec_gms_packets.document_type
 	                 AND     rec_gms_packets.expenditure_item_date between   gb.start_date and gb.end_date
 	                 AND     rownum = 1;

 	               END IF;

 	 /* Bug 5956576: Base Bug 5955990 - Changes end   */

                IF (SQL%NOTFOUND) THEN

                        if rec_gms_packets.time_phased_type_code = 'G' then
                                select gps.start_date, gps.end_date
                                into   x_st_date, x_ed_date
                                from   gl_period_statuses gps
                                where  gps.application_id = 101
                                and     gps.set_of_books_id = rec_gms_packets.set_of_books_id
                                and    rec_gms_packets.expenditure_item_date between gps.start_date and gps.end_date
                                and     gps.adjustment_period_flag = 'N';

                        elsif rec_gms_packets.time_phased_type_code = 'P' then
                                select start_date , end_date
                                into x_st_date , x_ed_date
                                from pa_periods gpa --Bug 4732065 /*bug 6660289*/
                                where  rec_gms_packets.expenditure_item_date between gpa.start_date and gpa.end_date;

                        elsif rec_gms_packets.time_phased_type_code in ('R','N') then

                                setup_start_end_date(rec_gms_packets.project_id,
                                   rec_gms_packets.award_id,
                                   rec_gms_packets.bud_task_id, -- 2673200
                                   rec_gms_packets.budget_version_id,
                                   rec_gms_packets.time_phased_type_code,
                                   rec_gms_packets.entry_level_code, -- 2673200
                                   rec_gms_packets.expenditure_item_date,
                                   rec_gms_packets.amount_type,
                                   rec_gms_packets.boundary_code,
                                   rec_gms_packets.set_of_books_id,
                                   x_st_date,
                                   x_ed_date,
                                   St_e_code,
                                   x_err_stage);

                        end if;

                        If x_st_date is null or x_ed_date is null then

                            l_counter:=Upd_error_table.COUNT;
                            l_counter:=l_counter+1;

                                upd_error_table(l_counter).exp_item_id :=rec_gms_packets.document_header_id;
                                upd_error_table(l_counter).adl :=rec_gms_packets.document_distribution_id;
                                upd_error_table(l_counter).award_id := rec_gms_packets.award_id;
                                upd_error_table(l_counter).project_id :=rec_gms_packets.project_id;
                                upd_error_table(l_counter).task_id := rec_gms_packets.task_id;
                                upd_error_table(l_counter).amount:=rec_gms_packets.entered_dr - rec_gms_packets.entered_cr;

                                upd_reason_table(l_counter).resource_list_id:=rec_gms_packets.resource_list_id;
                                upd_reason_table(l_counter).person_id:=null;
                                upd_reason_table(l_counter).job_id:=null;
                                upd_reason_table(l_counter).org_id:=null;
                                upd_reason_table(l_counter).expenditure_type:=null;
                                upd_reason_table(l_counter).nlr:=null;
                                upd_reason_table(l_counter).exp_category:=null;
                                upd_reason_table(l_counter).rev_category:=null;
                                upd_reason_table(l_counter).org_id:=null;
                                upd_reason_table(l_counter).sys_link:=null;
                                upd_reason_table(l_counter).exp_date:=rec_gms_packets.expenditure_item_date;
                                upd_reason_table(l_counter).bvid:=rec_gms_packets.budget_version_id;
                                upd_reason_table(l_counter).bud_task:=rec_gms_packets.bud_task_id;
                                upd_reason_table(l_counter).cat_code:=null;
                                upd_reason_table(l_counter).tp_code:=rec_gms_packets.time_phased_type_code;

                                upd_error_table(l_counter).reason:= 'Transaction item:';

                                If x_st_date is null then
                                   upd_error_table(l_counter).reason:= upd_error_table(l_counter).reason||'Start Date Null';
                                End If;
                                If x_ed_date is null then
                                   upd_error_table(l_counter).reason:= upd_error_table(l_counter).reason||':End Date Null';
                                End If;

                                If x_mode <> 'B' then
                                   ROLLBACK TO SAVEPOINT A;
                                   GOTO NO_PROCESS;
                                Else
                                   RAISE_APPLICATION_ERROR(-20001,'Could not derive budget period date');
                                End If;

                        END if;

                           x_stage             := '800';

                        -- Insert GMS_BALANCES record where balance record not exist

                                insert into gms_balances (project_id
                                      ,award_id
                                      ,task_id
                                      ,top_task_id
                                      ,resource_list_member_id
                                      ,set_of_books_id
                                      ,budget_Version_id
                                      ,balance_type
                                      ,last_update_date
                                      ,last_updated_by
                                      ,created_by
                                      ,creation_date
                                      ,last_update_login
                                      ,start_date
                                      ,end_date
                                      ,parent_member_id
                                      ,budget_period_to_date
                                      ,actual_period_to_date
                                      ,encumb_period_to_date
                                     )
                               values
                                     (rec_gms_packets.project_id
                                      ,rec_gms_packets.award_id
                                      ,decode(rec_gms_packets.document_type,'BGT',rec_gms_packets.bud_task_id,
                                              rec_gms_packets.task_id)
                                      ,rec_gms_packets.top_task_id
                                      ,rec_gms_packets.resource_list_member_id
                                      ,rec_gms_packets.set_of_books_id
                                      ,rec_gms_packets.budget_Version_id
                                      ,rec_gms_packets.document_type
                                      ,sysdate
                                      ,FND_GLOBAL.USER_ID
                                      ,FND_GLOBAL.USER_ID
                                      ,sysdate
                                      ,FND_GLOBAL.LOGIN_ID
                                      ,x_st_date
                                      ,x_ed_date
                                      ,rec_gms_packets.parent_resource_id
                                      ,0
                                      ,(nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
                                         decode(rec_gms_packets.document_type,'EXP',1,0)
                                      ,(nvl(rec_gms_packets.entered_dr,0)- nvl(rec_gms_packets.entered_cr,0))  *
                                         decode(rec_gms_packets.document_type,'REQ',1,'PO',1,'AP',1,'ENC',1,0)
                                     );


                END IF; -- sql%notfound

                x_stage             := '900'; -- Update gms_bc_packet record status to 'X'
                update gms_bc_packets set status_code = 'X'
                WHERE rowid=rec_gms_packets.rowid;

                -- Changed to rowid criteria, bug 4053891

                        -------------------------------------------------------------------
                        --Update adl for accumulated_flag for mode <> B
                        -------------------------------------------------------------------

                        if x_mode <> 'B' then
                                if rec_gms_packets.document_type in ('EXP','ENC') then

                                        update gms_award_distributions
                                        set    accumulated_flag='Y'
                                        where  expenditure_item_id = rec_gms_packets.document_header_id
                                        and  rec_gms_packets.document_distribution_id = decode(rec_gms_packets.document_type, --Bug 5726575
                                                                                               'EXP', cdl_line_num,
                                                                                               'ENC', adl_line_num)
                                        and  nvl(reversed_flag, 'N') = 'N' --Bug 5726575
                                        and  line_num_reversed is null
                                        and  document_type=rec_gms_packets.document_type
                                        and  award_id=rec_gms_packets.award_id
                                        and  project_id =  rec_gms_packets.project_id
                                        and  task_id = rec_gms_packets.task_id
                                        and  adl_status='A'
                                        and  cost_distributed_flag='Y'
                                        and  fc_status='A';

                        elsif rec_gms_packets.document_type ='PO' then

                                        update gms_award_distributions
                                        set    accumulated_flag='Y'
                                        where  po_distribution_id = rec_gms_packets.document_distribution_id
                                        and  document_type=rec_gms_packets.document_type
                                        and  award_id=rec_gms_packets.award_id
                                        and  project_id =  rec_gms_packets.project_id
                                        and  task_id = rec_gms_packets.task_id
                                        and  adl_status='A'
                                        and  fc_status='A';

                        elsif rec_gms_packets.document_type ='REQ' then

                                        update gms_award_distributions
                                        set    accumulated_flag='Y'
                                        where  distribution_id = rec_gms_packets.document_distribution_id
                                        and  document_type=rec_gms_packets.document_type
                                        and  award_id=rec_gms_packets.award_id
                                        and  project_id =  rec_gms_packets.project_id
                                        and  task_id = rec_gms_packets.task_id
                                        and  adl_status='A'
                                        and  fc_status='A';

                        elsif rec_gms_packets.document_type ='AP' then

                                        update gms_award_distributions
                                        set    accumulated_flag='Y'
                                        where  invoice_id = rec_gms_packets.document_header_id
                                        -- AP Lines uptake: changed join from with distribution num to distribution id
                                        and  invoice_distribution_id =  rec_gms_packets.document_distribution_id
                                        and  document_type=rec_gms_packets.document_type
                                        and  award_id=rec_gms_packets.award_id
                                        and  project_id =  rec_gms_packets.project_id
                                        and  task_id = rec_gms_packets.task_id
                                        and  adl_status='A'
                                        and  fc_status='A';

                        end if;

                end if;


        EXCEPTION
                When others then
                     IF L_DEBUG = 'Y' THEN
                        gms_error_pkg.gms_debug('Stage:'||x_stage||';'||substr(sqlerrm,1,255),'C');
                     END IF;
                     If x_mode <> 'B' then
                        ROLLBACK TO SAVEPOINT A;
                        -- If Sweeper then rollback and continue
                     Else
                        RAISE;
                        -- If baseline then fail process ..
                     End if;
        END;

        <<NO_PROCESS>>
          NULL;


      END LOOP;

       -- Bug 4053891 .. for last set of data .. Start
       If x_mode <> 'B' then
         If x_loop_counter > 1 then
             -- * Post Burden
             -- * Initalize variables
             -- * Commit

             If Tab_Award_exp_burden.exists(1) then
                x_plsql_count := Tab_Award_exp_burden.count;
             End If;

             -- * Post Burden
             If x_plsql_count > 0 then

                post_burden_amounts(x_plsql_count,Tab_Award_exp_burden,x_err_code);

                If  x_err_code = 'E' then
                    ROLLBACK; -- not to savepoint
                End If;
             End If;

             -- * Initalize variables
             x_loop_counter := 0;
             x_plsql_count  := 0;
             -- * Commit
             Commit;
         End If;
       End if;

       -- Bug 4053891 .. for last set of data .. End

  -- Moved Revenue posting to after actuals ...bug 3487431

    -- Call  update_revenue_balance.
    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('Calling Revenue Updation','C');
    	gms_error_pkg.gms_debug('Mode passed for revenue updation '||x_mode,'C');
    END IF;

     -- Bug 2138376 : Modify the following code
     -- If called from Baselining process consider records with status 'B' else
     --consider records with status 'A'

     if x_mode ='B' then
         x_status_code :='B'; --Bug 2138376

        -- Bug 4732065 : if called from baselining derive value of SOB from x_award_id which will be NOT NULL

        OPEN c_get_sob (x_award_id);
	FETCH  c_get_sob INTO l_sob_id;
	CLOSE c_get_sob ;

        update_revenue_balance(x_mode,x_award_id,x_project_id,l_sob_id,upd_error_table,upd_reason_table);

        --Update adl accumulated_flag for mode = B
        update gms_award_distributions
        set    accumulated_flag='Y'
        where  award_id = x_award_id
        and  project_id = x_project_id
        and  adl_status='A'
        and  fc_status='A';

     else -- x_mode ='U'
       x_status_code :='A'; --Bug 2138376

/*        for records in cur_records
        loop
 Commented for the bug 5481465*/
/*	  update_revenue_balance(x_mode,records.award_id,records.project_id,records.set_of_books_id, commented and added below line for the bug 5481465*/
             update_revenue_balance(x_mode,-1,-1,l_sob_id,
                                 upd_error_table,upd_reason_table);

          commit;
           -- Added to improve performance ..

--        end loop; commented for the bug 5481465

     end if;

        IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_debug('Revenue Updation Completed','C');
        END IF;

  -- ...bug 3487431 end.



      error_output(upd_error_table,upd_reason_table);

      retcode := 0; -- Changed from 'S' to 0 (zero) for Bug:2464800
      commit;
    EXCEPTION
      when OTHERS then
        retcode := 2; -- Changed from 'E' to 2 for Bug:2464800
        errbuf := (x_stage||' '||SQLCODE||' '||SQLERRM);
        --dbms_output.put_line('failed at when others'||SQLCODE||SQLERRM);
    END upd_act_enc_bal;
END GMS_SWEEPER;

/
