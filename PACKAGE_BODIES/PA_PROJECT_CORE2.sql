--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CORE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CORE2" as
-- $Header: PAXPCO2B.pls 120.6.12010000.3 2010/01/20 11:54:05 rthumma ship $


--
--  PROCEDURE
--              copy_task
--  PURPOSE
--
--              The objective of this procedure is to create new
--              tasks for a project by copying the tasks of another project.
--		Task level information such as transaction controls, billing
--		assignment, project asset assignments,
--		burden schedules, and overrides will also be copied.
--
--              Users must pass in x_orig_project_id and x_new_project_id.
--
procedure copy_task (     x_orig_project_id   		IN        number
                        , x_new_project_id     		IN        number
                        , x_err_code            	IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage           	IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack           	IN OUT    NOCOPY varchar2)  --File.Sql.39 bug 4440895
is

--Below code added for selective copy project. Tracking Bug No. 3464332
--This cursor retrieves the values of various flags from the global temporary table
CURSOR cur_get_flag(p_flag_name IN VARCHAR2) IS
SELECT FLAG
FROM   PA_PROJECT_COPY_OPTIONS_TMP
WHERE  CONTEXT = p_flag_name ;

-- Bug 4188514
CURSOR cur_sel_ver_id IS
Select version_id
from PA_PROJECT_COPY_OPTIONS_TMP
where CONTEXT = 'WORKPLAN'
AND VERSION_ID IS NOT NULL;
-- Bug 4188514

l_fin_tasks_flag            VARCHAR2(1);
l_fn_dff_flag               VARCHAR2(1);
l_copy_dff_flag             VARCHAR2(1);
l_fin_txn_control_flag      VARCHAR2(1);
l_fn_cb_overrides_flag      VARCHAR2(1);
l_fn_asset_assignments_flag VARCHAR2(1);

	x_old_proj_start	date;
	x_new_proj_start	date;
	x_new_proj_completion	date;
        x_old_proj_org_id       Number;
        x_new_proj_org_id       Number;
	x_delta			number  default NULL;

        old_stack      varchar2(630);
l_wp_separate_from_fn  varchar2(1);
-- Bug 4104042
l_shared                VARCHAR2(1);
l_sel_version_id       Number := NULL;
l_template_flag        VARCHAR2(1);
l_versioning_enabled   VARCHAR2(1) := Null;
l_workplan_enabled      VARCHAR2(1) := 'N';
-- Bug 4104042
begin

        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->copy_task';
        savepoint copy_task;

	-- 1) get original and new project start and completion dates
	-- 2) calculate shift day x_delta
	-- 3) get burden flag for project type of new project
	declare

		cursor c1 is
		     select old.start_date,
		         new.start_date,
		         new.completion_date,
                         old.carrying_out_organization_id,
                         new.carrying_out_organization_id
		     from pa_projects old, pa_projects new
		     where old.project_id = x_orig_project_id
		     and new.project_id = x_new_project_id;

	         -- use min(start_date) as pseudo original project start
		 cursor c2 is
                        select min(start_date) min_start
                        from pa_tasks
                        where project_id = x_orig_project_id;

                 c2_rec  c2%rowtype;

	begin
		open c1;
		fetch c1 into
			x_old_proj_start,
			x_new_proj_start,
			x_new_proj_completion,
                        x_old_proj_org_id,
                        x_new_proj_org_id;
		close c1;

		if (x_new_proj_start is null) then
	                x_delta := 0;
	        elsif (x_old_proj_start is not null) then
	                --Changed by rtarway for BUG 3875746
                     --x_delta := x_new_proj_start - x_old_proj_start;
                     x_delta := trunc(x_new_proj_start) - trunc(x_old_proj_start);
		else
			open c2;
			fetch c2 into c2_rec;
			if c2%found then
                           --Changed by rtarway for BUG 3875746
                           --x_delta := x_new_proj_start - c2_rec.min_start;
                           x_delta := trunc(x_new_proj_start) - trunc(c2_rec.min_start);
                        end if;
                        close c2;
                end if;

	end;

	-- create new tasks for new project with dates adjusted
        -- if old task's org id = old project's org id and
        --    new project's org id != old project's org id then
        --    new task would have the new org id
        -- else new task would have the old task's org id
--Below code added for selective copy project. Tracking Bug No. 3464332
        --Check whether the Financial Tasks flag is checked or not
        OPEN  cur_get_flag('FN_FIN_TASKS_FLAG');
        FETCH cur_get_flag INTO l_fin_tasks_flag;
        CLOSE cur_get_flag;

        OPEN  cur_get_flag('FN_DFF_FLAG');
        FETCH cur_get_flag INTO l_fn_dff_flag;
        CLOSE cur_get_flag;

        IF 'Y' = l_fn_dff_flag AND 'Y' = l_fin_tasks_flag THEN
            l_copy_dff_flag := 'Y';
        ELSE
            l_copy_dff_flag := 'N';
        END IF;

         x_err_stage := 'copying tasks for project '|| x_new_project_id ||
                    ' by copying tasks from project '|| x_orig_project_id;

    -- Bug 4104042 - Begin

    l_workplan_enabled := PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( x_orig_project_id );

    IF NVL( l_workplan_enabled, 'N' ) = 'Y' THEN
        --Check whether the structures are shared or not in the source project
        l_shared := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled( x_orig_project_id );
    ELSE
        l_shared := 'N';
    END IF;

    l_versioning_enabled := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(x_orig_project_id);

       select template_flag into l_template_flag
       from pa_projects_all
       where project_id = x_orig_project_id;

    IF l_shared = 'Y' and
         l_versioning_enabled = 'Y' and -- Bug 4188514
           l_template_flag = 'N' -- Bug 4188514
    THEN
      -- Bug 4188514 : Used Below cursor instead of direct query to avoid no data found
      OPEN cur_sel_ver_id;
      FETCH cur_sel_ver_id INTO l_sel_version_id;
      CLOSE cur_sel_ver_id;
    END IF;


 -- Bug 4104042 - End

	l_wp_separate_from_fn := nvl ( PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN ( x_orig_project_id ), 'N' )  ;


	 INSERT INTO pa_tasks (
                task_id
             ,  project_id
             ,  task_number
             ,  task_name
	     ,  long_task_name  /* Bug#2638968  */
             ,  last_update_date
             ,  last_updated_by
             ,  creation_date
             ,  created_by
             ,  last_update_login
             ,  wbs_level
             ,  top_task_id
             ,  parent_task_id
             ,  ready_to_bill_flag
             ,  ready_to_distribute_flag
             ,  billable_flag
             ,  chargeable_flag
             ,  limit_to_txn_controls_flag
             ,  description
             ,  service_type_code
             ,  task_manager_person_id
             ,  carrying_out_organization_id
             ,  start_date
             ,  completion_date
             ,  labor_std_bill_rate_schdl
             ,  labor_bill_rate_org_id
             ,  labor_schedule_fixed_date
             ,  labor_schedule_discount
             ,  non_labor_std_bill_rate_schdl
             ,  non_labor_bill_rate_org_id
             ,  non_labor_schedule_fixed_date
             ,  non_labor_schedule_discount
             ,  attribute_category
             ,  attribute1
             ,  attribute2
             ,  attribute3
             ,  attribute4
             ,  attribute5
             ,  attribute6
             ,  attribute7
             ,  attribute8
             ,  attribute9
             ,  attribute10
             ,  cost_ind_rate_sch_id
             ,  rev_ind_rate_sch_id
             ,  inv_ind_rate_sch_id
             ,  cost_ind_sch_fixed_date
             ,  rev_ind_sch_fixed_date
             ,  inv_ind_sch_fixed_date
             ,  labor_sch_type
             ,  non_labor_sch_type
             ,  allow_cross_charge_flag
             ,  project_rate_date
             ,  project_rate_type
             ,  cc_process_labor_flag
             ,  labor_tp_schedule_id
             ,  labor_tp_fixed_date
             ,  cc_process_nl_flag
             ,  nl_tp_schedule_id
             ,  nl_tp_fixed_date
             ,  receive_project_invoice_flag
             ,  work_type_id
             ,  job_bill_rate_schedule_id
             ,  emp_bill_rate_schedule_id
             ,  taskfunc_cost_rate_type
             ,  taskfunc_cost_rate_date
             ,  non_lab_std_bill_rt_sch_id
             ,  labor_disc_reason_code
             ,  non_labor_disc_reason_code
--PA L Changes 2872708
             ,  retirement_cost_flag
             ,  cint_eligible_flag
--End PA L Changes 2872708
             ,  gen_etc_source_code    --Bug 3846768
)
 -- labor_cost_multiplier_name is deliberately NOT being copied to the new task
 -- See bug 402125 for details
 -- Bug 5034402: If the start/end date of the source task is NULL then copied
 -- start/end date of the target project to start/end date of target task.Added by sunkalya for porting fix from Bug#5014950 to R12
         SELECT
                pa_tasks_s.nextval
         ,      x_new_project_id
         ,      t.task_number
         ,      t.task_name
         ,      nvl(t.long_task_name, t.task_name)  /* Bug#2638968  */
         ,      sysdate
         ,      FND_GLOBAL.USER_ID
         ,      sysdate
         ,      FND_GLOBAL.USER_ID
         ,      FND_GLOBAL.LOGIN_ID
         ,      t.wbs_level
         ,      t.top_task_id
         ,      t.parent_task_id
         ,      t.ready_to_bill_flag
         ,      t.ready_to_distribute_flag
         ,      t.billable_flag
         ,      t.chargeable_flag
         ,      t.limit_to_txn_controls_flag
         ,      t.description
         ,      t.service_type_code
         ,      t.task_manager_person_id
         ,      decode(t.carrying_out_organization_id,x_old_proj_org_id,
                       x_new_proj_org_id,t.carrying_out_organization_id)
         ,      to_date(decode(x_delta, null, to_char(x_new_proj_start,'J'),
                decode(to_char(t.start_date,'J'), null, to_char(x_new_proj_start,'J'),-- Bug 5034402
                decode(to_char(x_new_proj_completion,'J'), null, to_char(t.start_date,'J')+x_delta,
                least(to_char(x_new_proj_completion,'J'), to_char(t.start_date,'J') + x_delta)))),'J')
         ,      to_date(decode(x_delta, null, to_char(x_new_proj_completion,'J'),
                decode(to_char(t.completion_date,'J'), null, to_char(x_new_proj_completion,'J'),-- Bug 5034402
                decode(to_char(x_new_proj_completion,'J'), null, to_char(t.completion_date,'J')+x_delta,
                least(to_char(x_new_proj_completion,'J'), to_char(t.completion_date,'J') + x_delta)))),'J')
         ,      t.labor_std_bill_rate_schdl
         ,      t.labor_bill_rate_org_id
         ,      t.labor_schedule_fixed_date
         ,      t.labor_schedule_discount
         ,      t.non_labor_std_bill_rate_schdl
         ,      t.non_labor_bill_rate_org_id
         ,      t.non_labor_schedule_fixed_date
         ,      t.non_labor_schedule_discount
         ,      decode(l_copy_dff_flag,'Y',t.attribute_category,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute1,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute2,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute3,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute4,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute5,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute6,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute7,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute8,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute9,null)
         ,      decode(l_copy_dff_flag,'Y',t.attribute10,null)
         ,      t.cost_ind_rate_sch_id
         ,      t.rev_ind_rate_sch_id
         ,      t.inv_ind_rate_sch_id
         ,      t.cost_ind_sch_fixed_date
         ,      t.rev_ind_sch_fixed_date
         ,      t.inv_ind_sch_fixed_date
         ,      t.labor_sch_type
         ,      t.non_labor_sch_type
         ,      t.allow_cross_charge_flag
         ,      t.project_rate_date
         ,      t.project_rate_type
         ,      t.cc_process_labor_flag
         ,      t.labor_tp_schedule_id
         ,      t.labor_tp_fixed_date
         ,      t.cc_process_nl_flag
         ,      t.nl_tp_schedule_id
         ,      t.nl_tp_fixed_date
         ,      t.receive_project_invoice_flag
         ,      t.work_type_id
         ,      t.job_bill_rate_schedule_id
         ,      t.emp_bill_rate_schedule_id
             ,  t.taskfunc_cost_rate_type
             ,  t.taskfunc_cost_rate_date
             ,  t.non_lab_std_bill_rt_sch_id
             ,  t.labor_disc_reason_code
             ,  t.non_labor_disc_reason_code
--PA L Changes 2872708
             ,  t.retirement_cost_flag
             ,  t.cint_eligible_flag
--End PA L Changes 2872708
             ,  gen_etc_source_code
             --commenting out the rest for bug 3924597
             --gen_etc_source_code column modified by rtarway for BUG 3924597
             --,  decode ( gen_etc_source_code, null ,
             --            decode (
             --                     l_wp_separate_from_fn,
	     --					    'N', 'WORKPLAN_RESOURCE',
	     --					    'FINANCIAL_PLAN'
	     --				       )
	     --		        )   --Bug 3846768
           FROM
                pa_tasks t
          WHERE
                t.project_id = x_orig_project_id;


	if (SQL%FOUND) then

-- Bug 4104042 - Begin
        x_err_stage := 'Delete extra tasks';

	IF l_template_flag = 'N' AND
         l_versioning_enabled = 'Y' AND
	   l_shared = 'Y' AND
	     l_sel_version_id is not NULL
         THEN
             Delete from pa_tasks t where
             t.project_id = x_new_project_id
             and not exists (select 1
	                     from pa_proj_element_versions v,
                                  pa_tasks old_tsk,
                                  pa_tasks new_tsk
                             where new_tsk.project_id = x_new_project_id
                             and old_tsk.project_id = x_orig_project_id
                             and old_tsk.task_number = new_tsk.task_number
                             and v.project_id = x_orig_project_id
                             and v.PARENT_STRUCTURE_VERSION_ID = l_sel_version_id
                             and v.object_type='PA_TASKS'
                             and v.proj_element_id = old_tsk.task_id
                             and t.task_id = new_tsk.task_id);
	  END IF;
-- Bug 4104042 - End

           x_err_stage := 'update CC Tax Task Id';

           UPDATE
                 pa_projects P
              SET
                   P.cc_tax_task_id = (
                       SELECT  new_tsk.task_id
                         FROM  pa_tasks old_tsk
                       ,       pa_tasks new_tsk
                        WHERE  new_tsk.project_id = x_new_project_id
                          AND  old_tsk.project_id = x_orig_project_id
                          AND  P.cc_tax_task_id   = old_tsk.task_id
                          AND  old_tsk.task_number = new_tsk.task_number )
            WHERE  P.project_id = x_new_project_id
            AND    P.cc_tax_task_id is not null;

	        x_err_stage := 'update parent task id';

	        UPDATE
        	        pa_tasks T
	           SET
	                T.parent_task_id = (
	                    SELECT  new_tsk.task_id
	                      FROM  pa_tasks old_tsk
	                    ,       pa_tasks new_tsk
	                     WHERE  new_tsk.project_id = x_new_project_id
	                       AND  old_tsk.project_id = x_orig_project_id
	                       AND  T.parent_task_id = old_tsk.task_id
	                       AND  old_tsk.task_number = new_tsk.task_number )
	         WHERE  T.project_id = x_new_project_id;

	        x_err_stage := 'update top task id';

        	UPDATE
	                pa_tasks T
	           SET
        	        T.top_task_id = (
	                    SELECT  new_tsk.task_id
	                      FROM  pa_tasks old_tsk
	                    ,       pa_tasks new_tsk
	                     WHERE  new_tsk.project_id = x_new_project_id
	                       AND  old_tsk.project_id = x_orig_project_id
	                       AND  T.top_task_id = old_tsk.task_id
	                       AND  old_tsk.task_number = new_tsk.task_number )
	         WHERE  T.project_id = x_new_project_id;

/* commenting out the following code and moving it in PA_PROJECT_CORE1.copy_project
   api with changes made in the cursor
   --bug 3068506
         -- This PLSQL block has been added for copying the attachments
         -- to all the tasks while copying a project

           Begin
             Declare
                  cursor c_attach_tasks is
                      select orig.task_id orig_task_id,
                             new.task_id new_task_id
                        from pa_tasks orig, pa_tasks new
                       where orig.project_id = x_orig_project_id
                         and new.task_number = orig.task_number
                         and new.project_id = x_new_project_id  ;

                   c_atch   c_attach_tasks%rowtype ;

             begin
                 open c_attach_tasks;
                 loop
                     fetch c_attach_tasks
                      into c_atch ;
                      if c_attach_tasks%notfound then
                         exit ;
                      end if;
                      fnd_attached_documents2_pkg.copy_attachments('PA_TASKS',
                                             c_atch.orig_task_id,
                                             null, null, null, null,
                                             'PA_TASKS',
                                             c_atch.new_task_id,
                                             null, null, null, null,
                                             FND_GLOBAL.USER_ID,
                                             FND_GLOBAL.LOGIN_ID,
                                             275, null, null);

                 end loop ;
                 close c_attach_tasks;
             exception
                 when NO_DATA_FOUND then
                      null;
                 when others then
                      null ;
             end ;
           end ;

       -- End of the attachment call
*/

	else
/*
		x_err_code := 10;
		x_err_stage := 'PA_NO_TASK_COPIED';
                rollback to copy_task;
		return;
*/ --bug 2883515
               null;
	end if;

   -- copying burden schedule for Task:

      x_err_stage := 'copying task level burden schedules ';

      INSERT INTO pa_ind_rate_schedules (
          IND_RATE_SCH_ID,
          IND_RATE_SCH_NAME,
          BUSINESS_GROUP_ID,
          DESCRIPTION,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          COST_PLUS_STRUCTURE,
          IND_RATE_SCHEDULE_TYPE,
          PROJECT_ID,
          TASK_ID,
          COST_OVR_SCH_FLAG,
          REV_OVR_SCH_FLAG,
          INV_OVR_SCH_FLAG,
	  ORGANIZATION_STRUCTURE_ID, --Added these 3 columns for the bug 2581491
	  ORG_STRUCTURE_VERSION_ID,
	  START_ORGANIZATION_ID,
          IND_RATE_SCH_USAGE       --bug 3053508
          )
        select
          pa_ind_rate_schedules_s.nextval,
          /*to_char(new_tsk.task_id) ||
          substr(s.ind_rate_sch_name,
          instr(s.ind_rate_sch_name, '-', -1)),*/
          SUBSTRB((TO_CHAR(new_tsk.task_id) || DECODE(INSTRB(s.ind_rate_sch_name, '-',
          -1),'0','-') || SUBSTRB(s.ind_rate_sch_name, INSTRB(s.ind_rate_sch_name, '-',
          -1))),1,30),  -- Added for Bug 8690508
          s.business_group_id,
          s.DESCRIPTION,
          decode(x_delta, null, sysdate,
                 s.start_date_active + x_delta),
          decode(x_delta, null, sysdate,
                 s.end_date_active + x_delta),
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.LOGIN_ID,
          s.COST_PLUS_STRUCTURE,
          s.IND_RATE_SCHEDULE_TYPE,
          x_new_project_id,
          new_tsk.task_id,
          s.COST_OVR_SCH_FLAG,
          s.REV_OVR_SCH_FLAG,
          s.INV_OVR_SCH_FLAG,
	  s.ORGANIZATION_STRUCTURE_ID, --Added these 3 columns for the bug 2581491
	  s.ORG_STRUCTURE_VERSION_ID,
	  s.START_ORGANIZATION_ID,
          s.IND_RATE_SCH_USAGE       --bug 3053508
        FROM  pa_ind_rate_schedules s
        ,      pa_tasks new_tsk
        ,      pa_tasks old_tsk
         WHERE
               s.project_id = x_orig_project_id
           AND s.task_id    = old_tsk.task_id
           AND new_tsk.project_id = x_new_project_id
           AND old_tsk.project_id = x_orig_project_id
           AND new_tsk.task_number = old_tsk.task_number;

        x_err_stage := 'copying burden schedule revisions - task ';

          insert into pa_ind_rate_sch_revisions (
             IND_RATE_SCH_REVISION_ID,
             IND_RATE_SCH_ID,
             IND_RATE_SCH_REVISION,
             IND_RATE_SCH_REVISION_TYPE,
             COMPILED_FLAG,
             COST_PLUS_STRUCTURE,
             START_DATE_ACTIVE,
             END_DATE_ACTIVE,
             COMPILED_DATE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             READY_TO_COMPILE_FLAG,
             ACTUAL_SCH_REVISION_ID,
	     ORGANIZATION_STRUCTURE_ID,  --Added these three columns for bug 2581491
	     ORG_STRUCTURE_VERSION_ID,
	     START_ORGANIZATION_ID)
          select
             pa_ind_rate_sch_revisions_s.nextval,
             new_sch.ind_rate_sch_id,
             rev.IND_RATE_SCH_REVISION,
             rev.IND_RATE_SCH_REVISION_TYPE,
             'N',
             rev.COST_PLUS_STRUCTURE,
             decode(x_delta, null, sysdate,
             rev.start_date_active + x_delta),
             decode(x_delta, null, sysdate,
             rev.end_date_active + x_delta),
             null,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.LOGIN_ID,
             rev.REQUEST_ID,
             NULL,
             NULL,
             NULL,
             'Y',
             NULL,
	     rev.ORGANIZATION_STRUCTURE_ID, --Added these three columns for bug 2581491
	     rev.ORG_STRUCTURE_VERSION_ID,
	     rev.START_ORGANIZATION_ID
          from pa_ind_rate_sch_revisions rev,
               pa_ind_rate_schedules old_sch,
               pa_ind_rate_schedules new_sch,
               pa_tasks old_task,
               pa_tasks new_task
          where old_sch.project_id      = x_orig_project_id
          and   old_sch.ind_rate_sch_id = rev.IND_RATE_SCH_ID
          and   old_sch.task_id = old_task.task_id
          and   new_sch.project_id      = x_new_project_id
          and   new_sch.task_id  = new_task.task_id
          and   old_task.project_id     = x_orig_project_id
          and   new_task.projecT_id     = x_new_project_id
          and   old_task.task_number    = new_task.task_number
          and   substr(new_sch.ind_rate_sch_name,
                instr(new_sch.ind_rate_sch_name, '-', -1))
                = substr(old_sch.ind_rate_sch_name,
                instr(old_sch.ind_rate_sch_name, '-', -1));

          insert into pa_ind_cost_multipliers (
             IND_RATE_SCH_REVISION_ID,
             ORGANIZATION_ID,
             IND_COST_CODE,
             MULTIPLIER,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN )
          select
             new_rev.IND_RATE_SCH_REVISION_ID,
             mult.ORGANIZATION_ID,
             mult.IND_COST_CODE,
             mult.MULTIPLIER,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.LOGIN_ID
          from pa_ind_cost_multipliers mult,
               pa_ind_rate_sch_revisions old_rev,
               pa_ind_rate_sch_revisions new_rev,
               pa_ind_rate_schedules old_sch,
               pa_ind_rate_schedules new_sch,
               pa_tasks old_task,
               pa_tasks new_task
          where old_rev.IND_RATE_SCH_REVISION_ID =
                mult.IND_RATE_SCH_REVISION_ID
          and   old_rev.IND_RATE_SCH_REVISION =
                new_rev.IND_RATE_SCH_REVISION
          and   old_sch.ind_rate_sch_id = old_rev.IND_RATE_SCH_ID
          and   new_sch.ind_rate_sch_id = new_rev.IND_RATE_SCH_ID
          and   old_sch.project_id      = x_orig_project_id
          and   old_sch.task_id  = old_task.task_id
          and   new_sch.project_id      = x_new_project_id
          and   new_sch.task_id   = new_task.task_id
          and   old_task.project_id     = x_orig_project_id
          and   new_task.projecT_id     = x_new_project_id
          and   old_task.task_number    = new_task.task_number
          and   substr(new_sch.ind_rate_sch_name,
                instr(new_sch.ind_rate_sch_name, '-', -1))
                = substr(old_sch.ind_rate_sch_name,
                instr(old_sch.ind_rate_sch_name, '-', -1));

         x_err_stage := 'copying txn controls for tasks ';
--Below code added for selective copy project. Tracking Bug No. 3464332
        --Check whether the Transaction Controls flag is checked or not
        OPEN  cur_get_flag('FN_TXN_CONTROL_FLAG');
        FETCH cur_get_flag INTO l_fin_txn_control_flag;
        CLOSE cur_get_flag;

        IF 'Y' = l_fin_txn_control_flag AND 'Y' = l_fin_tasks_flag THEN
            INSERT INTO pa_transaction_controls (
                   project_id
            ,      task_id
            ,      start_date_active
            ,      chargeable_flag
            ,      billable_indicator
            ,      creation_date
            ,      created_by
            ,      last_update_date
            ,      last_updated_by
            ,      last_update_login
            ,      person_id
            ,      expenditure_category
            ,      expenditure_type
            ,      non_labor_resource
            ,      scheduled_exp_only
            ,      end_date_active
            -- added for bug 4657420
            ,      workplan_res_only_flag
                    ,      employees_only_flag)
            SELECT
                   x_new_project_id
            ,      new_tsk.task_id
        /*,      nvl( decode(x_delta,
                null, x_new_proj_start,
                decode(new_tsk.start_date,
                    null, tc.start_date_active + x_delta,
                        tc.start_date_active +
                    (new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)
		      )          --added nvl here for bug#5452656 */
		    ,   nvl(decode(x_delta,null, x_new_proj_start,
		LEAST(GREATEST(NVL(TO_DATE((tc.start_date_active + x_delta)),NVL(TO_DATE((new_tsk.start_date)),trunc(SYSDATE))) ,
		NVL(TO_DATE((new_tsk.start_date)),
		NVL(TO_DATE((tc.start_date_active + x_delta)),trunc(SYSDATE))),x_new_proj_start),
		nvl(nvl(new_tsk.completion_date,x_new_proj_completion),trunc(SYSDATE)))),trunc(SYSDATE)) --Bug#6880617
            ,      tc.chargeable_flag
            ,      tc.billable_indicator
            ,      sysdate
            ,      FND_GLOBAL.USER_ID
            ,      sysdate
            ,      FND_GLOBAL.USER_ID
            ,      FND_GLOBAL.LOGIN_ID
            ,      tc.person_id
            ,      tc.expenditure_category
            ,      tc.expenditure_type
            ,      tc.non_labor_resource
            ,      tc.scheduled_exp_only
            ,      decode(tc.end_date_active, null, null,
                       decode(x_delta,
                                 null, tc.end_date_active +
                         (x_new_proj_start - tc.start_date_active),
                                 decode(new_tsk.start_date,
                                        null, tc.end_date_active + x_delta,
                                             tc.end_date_active +
                        (new_tsk.start_date - old_tsk.start_date))))
              -- added for bug 4657420
              ,      tc.workplan_res_only_flag
                    ,      tc.employees_only_flag
              FROM
                   pa_transaction_controls tc
            ,      pa_tasks new_tsk
            ,      pa_tasks old_tsk
             WHERE
                   tc.project_id = x_orig_project_id
               AND tc.task_id    = old_tsk.task_id
               AND new_tsk.project_id = x_new_project_id
               AND old_tsk.project_id = x_orig_project_id
               AND new_tsk.task_number = old_tsk.task_number;
        END IF;--IF 'Y' = l_fin_txn_control_flag THEN


        -- copy task level billing assignment
        x_err_stage := 'copying task level billing assignment ';

                INSERT INTO pa_billing_assignments (
                        BILLING_ASSIGNMENT_ID,
                        BILLING_EXTENSION_ID,
                        PROJECT_TYPE,
                        PROJECT_ID,
                        TOP_TASK_ID,
                        AMOUNT,
                        PERCENTAGE,
                        ACTIVE_FLAG,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        DISTRIBUTION_RULE,
/* Added columns for bug#2658340 */
                        ORG_ID,
                        RATE_OVERRIDE_CURRENCY_CODE,
                        PROJECT_CURRENCY_CODE,
                        PROJECT_RATE_TYPE,
                        PROJECT_RATE_DATE,
                        PROJECT_EXCHANGE_RATE,
                        PROJFUNC_CURRENCY_CODE,
                        PROJFUNC_RATE_TYPE,
                        PROJFUNC_RATE_DATE,
                        PROJFUNC_EXCHANGE_RATE,
                        FUNDING_RATE_TYPE,
                        FUNDING_RATE_DATE,
                        FUNDING_EXCHANGE_RATE,
			RECORD_VERSION_NUMBER)
                select
                        pa_billing_assignments_s.nextval,
                        a.BILLING_EXTENSION_ID,
                        NULL, --for bug 3539025
                        x_new_project_id, -- bug 4189010
                        new_tsk.task_id,
                        a.AMOUNT,
                        a.PERCENTAGE,
                        a.ACTIVE_FLAG,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        a.ATTRIBUTE_CATEGORY,
                        a.ATTRIBUTE1,
                        a.ATTRIBUTE2,
                        a.ATTRIBUTE3,
                        a.ATTRIBUTE4,
                        a.ATTRIBUTE5,
                        a.ATTRIBUTE6,
                        a.ATTRIBUTE7,
                        a.ATTRIBUTE8,
                        a.ATTRIBUTE9,
                        a.ATTRIBUTE10,
                        a.ATTRIBUTE11,
                        a.ATTRIBUTE12,
                        a.ATTRIBUTE13,
                        a.ATTRIBUTE14,
                        a.ATTRIBUTE15,
                        NULL,
                        /*new_proj.DISTRIBUTION_RULE */
/* Added columns for bug#2658340 */
                        a.ORG_ID,
                        a.RATE_OVERRIDE_CURRENCY_CODE,
                        a.PROJECT_CURRENCY_CODE,
                        a.PROJECT_RATE_TYPE,
                        a.PROJECT_RATE_DATE,
                        a.PROJECT_EXCHANGE_RATE,
                        a.PROJFUNC_CURRENCY_CODE,
                        a.PROJFUNC_RATE_TYPE,
                        a.PROJFUNC_RATE_DATE,
                        a.PROJFUNC_EXCHANGE_RATE,
                        a.FUNDING_RATE_TYPE,
                        a.FUNDING_RATE_DATE,
                        a.FUNDING_EXCHANGE_RATE,
			1
		from pa_billing_assignments a,
		     -- pa_projects new_proj, bug 4189010
		     pa_tasks old_tsk,
		     pa_tasks new_tsk
                where a.project_id = x_orig_project_id
                  and a.top_task_id is not null
		  and a.top_task_id = old_tsk.task_id
		  and old_tsk.task_number = new_tsk.task_number
		  and new_tsk.project_id = x_new_project_id -- new_proj.project_id bug 4189010
		  --and new_proj.project_id = x_new_project_id; -- bug 4189010
		  and old_tsk.project_id = x_orig_project_id; -- bug 4189010


        x_err_stage := 'copying task level project asset assignments';
--Below code added for selective copy project. Tracking Bug No. 3464332
        OPEN  cur_get_flag('FN_ASSET_ASSIGNMENTS_FLAG');
        FETCH cur_get_flag INTO l_fn_asset_assignments_flag;
        CLOSE cur_get_flag;

-- added UNION to remove bug#604496 : ashia bagai 30-dec-97
--       Common Cost asset assignments would have an asset id = 0
--  and hence would not have a relevant record in pa_project_assets
    IF 'Y' = l_fn_asset_assignments_flag AND 'Y' = l_fin_tasks_flag THEN
        INSERT INTO pa_project_asset_assignments (
            PROJECT_ASSET_ID,
                    TASK_ID,
                    PROJECT_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN)
        select
                    new_asset.PROJECT_ASSET_ID,
                    new_tsk.task_id,
                    new_asset.PROJECT_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID
        from pa_project_asset_assignments assign,
                 pa_project_assets  old_asset,
                 pa_project_assets  new_asset,
             pa_tasks old_tsk,
             pa_tasks new_tsk
           where old_asset.project_id = x_orig_project_id
             and old_asset.project_asset_id = assign.project_asset_id
             and assign.task_id = old_tsk.task_id
    /* Added the following conditions for bug#2530093 */
             and assign.project_id = old_tsk.project_id
             and old_tsk.project_id = old_asset.project_id /* End of conditions added for bug#2530093 */
         and old_tsk.task_number = new_tsk.task_number
         and new_tsk.project_id = new_asset.project_id
             and old_asset.asset_name = new_asset.asset_name
             and new_asset.project_id = x_new_project_id
           UNION
            select
                    assign.PROJECT_ASSET_ID,
                    new_tsk.task_id,
                    x_new_project_id,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID
            from pa_project_asset_assignments assign,
                 pa_tasks old_tsk,
                 pa_tasks new_tsk
           where assign.project_id = x_orig_project_id
             and assign.task_id = old_tsk.task_id
             and old_tsk.task_number = new_tsk.task_number
             and new_tsk.project_id = x_new_project_id
             and assign.project_asset_id = 0;
    END IF;--IF 'Y' = l_fn_asset_assignments_flag
-- end of addition for bug#604496

	x_err_stage := 'copying task level job bill rate overrides';

--Below code added for selective copy project. Tracking Bug No. 3464332
        OPEN  cur_get_flag('FN_COST_BILL_OVERRIDES_FLAG');
        FETCH cur_get_flag INTO l_fn_cb_overrides_flag;
        CLOSE cur_get_flag;

        IF 'Y' = l_fn_cb_overrides_flag THEN
            INSERT INTO pa_job_bill_rate_overrides (
                JOB_ID
                    ,       START_DATE_ACTIVE
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       RATE
                    ,       BILL_RATE_UNIT
                    ,       PROJECT_ID
                    ,       TASK_ID
                    ,       END_DATE_ACTIVE
            ,	JOB_BILL_RATE_OVERRIDE_ID -- added this column for bug 2476862
            ,       RATE_CURRENCY_CODE -- added this column for bug 2581491
    --  FP.K changes  msundare
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE )
                    SELECT
                            o.JOB_ID
                    ,       nvl(decode(x_delta,
                                    null, x_new_proj_start,
                                    decode(new_tsk.start_date,
                                            null, o.start_date_active + x_delta,
                                             o.start_date_active +
                         (new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)) -- Modified for bug# 5961484
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       o.RATE
                    ,       o.BILL_RATE_UNIT
                    ,       null
                    ,       new_tsk.task_id
                    ,       decode( o.end_date_active, null, null,
                               decode( x_delta,
                                          null, o.end_date_active +
                           (x_new_proj_start - o.start_date_active),
                                          decode(new_tsk.start_date,
                                               null, o.end_date_active + x_delta,
                                               o.end_date_active +
                            (new_tsk.start_date - old_tsk.start_date))))
            ,	pa_job_bill_rate_overrides_s.NEXTVAL  -- added this column for bug 2476862
            ,       o.RATE_CURRENCY_CODE                  -- added this column for bug 2581491
    --  FP.K changes  msundare
                    ,       o.DISCOUNT_PERCENTAGE
                    ,       o.RATE_DISC_REASON_CODE
                      FROM
                            pa_job_bill_rate_overrides o,
                pa_tasks old_tsk,
                pa_tasks new_tsk
                      WHERE old_tsk.project_id = x_orig_project_id
                        and o.task_id = old_tsk.task_id
                and old_tsk.task_number = new_tsk.task_number
                and new_tsk.project_id = x_new_project_id;
        END IF;

                x_err_stage := 'copying task level job bill title overrides';
--Below condition added for selective copy project. Tracking Bug No. 3464332
        IF 'Y' = l_fn_cb_overrides_flag THEN
                INSERT INTO pa_job_bill_title_overrides (
                        JOB_ID
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LAST_UPDATE_LOGIN
                ,       START_DATE_ACTIVE
                ,       BILLING_TITLE
                ,       PROJECT_ID
                ,       TASK_ID
                ,       END_DATE_ACTIVE
		,       JOB_BILL_TITLE_OVERRIDE_ID)  --Added the column for the bug 2581491
                SELECT
                        o.JOB_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       FND_GLOBAL.LOGIN_ID
                ,       nvl(decode(x_delta,
                                null, x_new_proj_start,
                                decode(new_tsk.start_date,
                                        null, o.start_date_active + x_delta,
                                         o.start_date_active +
 					(new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)) -- Modified for bug# 5961484
                ,       o.BILLING_TITLE
                ,       null
                ,       new_tsk.task_id
                ,       decode( o.end_date_active, null, null,
                           decode( x_delta,
                                      null, o.end_date_active +
				       (x_new_proj_start - o.start_date_active),
                                      decode(new_tsk.start_date,
                                           null, o.end_date_active + x_delta,
                                           o.end_date_active +
					(new_tsk.start_date - old_tsk.start_date))))
                ,       pa_job_bill_title_overrides_s.NEXTVAL  --Added the column for the bug 2581491
                  FROM
                       pa_job_bill_title_overrides o,
			pa_tasks old_tsk,
                        pa_tasks new_tsk
                  WHERE old_tsk.project_id = x_orig_project_id
                    and o.task_id = old_tsk.task_id
                    and old_tsk.task_number = new_tsk.task_number
                    and new_tsk.project_id = x_new_project_id;
        END IF;

                x_err_stage := 'copying task level job assignment overrides';
--Below condition added for selective copy project. Tracking Bug No. 3464332
        IF 'Y' = l_fn_cb_overrides_flag THEN
                INSERT INTO pa_job_assignment_overrides (
                        PERSON_ID
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LAST_UPDATE_LOGIN
                ,       START_DATE_ACTIVE
                ,       PROJECT_ID
                ,       TASK_ID
                ,       JOB_ID
                ,       BILLING_TITLE
                ,       END_DATE_ACTIVE
		,       JOB_ASSIGNMENT_OVERRIDE_ID) --Added the column for the bug 2581491
                SELECT
                        o.PERSON_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       FND_GLOBAL.LOGIN_ID
		,       nvl(decode(x_delta,
                                null, x_new_proj_start,
                                decode(new_tsk.start_date,
                                        null, o.start_date_active + x_delta,
                                         o.start_date_active +
					(new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)) -- Modified for bug# 5961484
                ,       null
                ,       new_tsk.task_id
                ,       o.JOB_ID
                ,       o.BILLING_TITLE
		,       decode( o.end_date_active, null, null,
			   decode( x_delta,
                                      null, o.end_date_active +
					(x_new_proj_start - o.start_date_active),
                                      decode(new_tsk.start_date,
                                           null, o.end_date_active + x_delta,
                                           o.end_date_active +
  				         (new_tsk.start_date - old_tsk.start_date))))
                ,       pa_job_assignment_overrides_s.NEXTVAL    --Added the column for the bug 2581491
                  FROM
                        pa_job_assignment_overrides o,
                        pa_tasks old_tsk,
                        pa_tasks new_tsk
                  WHERE old_tsk.project_id = x_orig_project_id
                    and o.task_id = old_tsk.task_id
                    and old_tsk.task_number = new_tsk.task_number
                    and new_tsk.project_id = x_new_project_id;
        END IF;

        x_err_stage := 'copying task level emp bill rate overrides';
--Below condition added for selective copy project. Tracking Bug No. 3464332
        IF 'Y' = l_fn_cb_overrides_flag THEN
		        INSERT into pa_emp_bill_rate_overrides (
                        PERSON_ID
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LAST_UPDATE_LOGIN
                ,       RATE
                ,       BILL_RATE_UNIT
                ,       START_DATE_ACTIVE
                ,       PROJECT_ID
                ,       TASK_ID
                ,       END_DATE_ACTIVE
		,	EMP_BILL_RATE_OVERRIDE_ID --added this column for bug 2476862
		,       RATE_CURRENCY_CODE  -- added this column for bug 2581491
-- Added for FP.K changes msundare
                ,       DISCOUNT_PERCENTAGE
                ,       RATE_DISC_REASON_CODE)
                SELECT
                        o.PERSON_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       FND_GLOBAL.LOGIN_ID
                ,       o.RATE
                ,       o.BILL_RATE_UNIT
                ,       nvl(decode(x_delta,
                                null, x_new_proj_start,
                                decode(new_tsk.start_date,
                                        null, o.start_date_active + x_delta,
                                         o.start_date_active +
					(new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)) -- Modified for bug# 5961484
                ,       null
                ,       new_tsk.task_id
                ,       decode( o.end_date_active, null, null,
                           decode( x_delta,
                                      null, o.end_date_active +
					(x_new_proj_start - o.start_date_active),
                                      decode(new_tsk.start_date,
                                           null, o.end_date_active + x_delta,
                                           o.end_date_active +
				         (new_tsk.start_date - old_tsk.start_date))))
		,	pa_emp_bill_rate_overrides_s.NEXTVAL   -- added this column for bug 2476862
		,       o.RATE_CURRENCY_CODE                   -- added this column for bug 2581491
-- Added for FP.K changes msundare
                ,       o.DISCOUNT_PERCENTAGE
                ,       o.RATE_DISC_REASON_CODE
                  FROM
                       pa_emp_bill_rate_overrides o,
		       pa_tasks old_tsk,
                       pa_tasks new_tsk
                  WHERE old_tsk.project_id = x_orig_project_id
                    and o.task_id = old_tsk.task_id
                    and old_tsk.task_number = new_tsk.task_number
                    and new_tsk.project_id = x_new_project_id;
        END IF;

         x_err_stage := 'copying task level nl bill rate overrides';
--Below condition added for selective copy project. Tracking Bug No. 3464332
        IF 'Y' = l_fn_cb_overrides_flag THEN
                INSERT INTO pa_nl_bill_rate_overrides (
                        EXPENDITURE_TYPE
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LAST_UPDATE_LOGIN
                ,       START_DATE_ACTIVE
                ,       NON_LABOR_RESOURCE
                ,       MARKUP_PERCENTAGE
                ,       BILL_RATE
                ,       PROJECT_ID
                ,       TASK_ID
                ,       END_DATE_ACTIVE
		,	NL_BILL_RATE_OVERRIDE_ID  -- added this column for bug 2476862
		,       RATE_CURRENCY_CODE   -- added this column for bug 2581491
--  FP.K changes msundare
               ,        DISCOUNT_PERCENTAGE
               ,        RATE_DISC_REASON_CODE )
                SELECT
                        o.EXPENDITURE_TYPE
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       FND_GLOBAL.LOGIN_ID
                ,       nvl(decode(x_delta,
                                null, x_new_proj_start,
                                decode(new_tsk.start_date,
                                        null, o.start_date_active + x_delta,
                                         o.start_date_active +
					(new_tsk.start_date - old_tsk.start_date))),trunc(o.start_date_active)) -- Modified for bug# 5961484
										-- Bug 6058655: overriding fix 5961484: replaced sysdate with o.start_date_active
                ,       o.NON_LABOR_RESOURCE
                ,       o.MARKUP_PERCENTAGE
                ,       o.BILL_RATE
                ,       null
                ,       new_tsk.task_id
                ,       decode( o.end_date_active, null, null,
                           decode( x_delta,
                                      null, o.end_date_active +
					(x_new_proj_start - o.start_date_active),
                                      decode(new_tsk.start_date,
                                           null, o.end_date_active + x_delta,
                                           o.end_date_active +
					(new_tsk.start_date - old_tsk.start_date))))
		,	pa_nl_bill_rate_overrides_s.NEXTVAL   -- added this column for bug 2476862
		,       o.RATE_CURRENCY_CODE                  -- added this column for bug 2581491
--  FP.K changes msundare
               ,        o.DISCOUNT_PERCENTAGE
               ,        o.RATE_DISC_REASON_CODE
                  FROM
                       pa_nl_bill_rate_overrides o,
                        pa_tasks old_tsk,
                        pa_tasks new_tsk
                  WHERE old_tsk.project_id = x_orig_project_id
                    and o.task_id = old_tsk.task_id
                    and old_tsk.task_number = new_tsk.task_number
                    and new_tsk.project_id = x_new_project_id;
        END IF;

      x_err_stage := 'copying task level labor multipliers ';

                INSERT INTO pa_labor_multipliers (
                        PROJECT_ID
                ,       TASK_ID
                ,       LABOR_MULTIPLIER
                ,       START_DATE_ACTIVE
                ,       END_DATE_ACTIVE
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LAST_UPDATE_LOGIN
		,       LABOR_MULTIPLIER_ID)  --Added this column for the bug 2581491
                SELECT
                        null
                ,       new_tsk.task_id
                ,       m.labor_multiplier
                ,       nvl(decode(x_delta,
                                null, x_new_proj_start,
                                decode(new_tsk.start_date,
                                        null, m.start_date_active + x_delta,
                                         m.start_date_active +
					(new_tsk.start_date - old_tsk.start_date))),trunc(sysdate)) -- Modified for bug# 5961484
                ,       decode( m.end_date_active, null, null,
                           decode( x_delta,
                                      null, m.end_date_active +
					(x_new_proj_start - m.start_date_active),
                                      decode(new_tsk.start_date,
                                           null, m.end_date_active + x_delta,
                                           m.end_date_active +
				      (new_tsk.start_date - old_tsk.start_date))))
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       FND_GLOBAL.LOGIN_ID
		,       pa_labor_multipliers_s.NEXTVAL  --Added this column for the bug 2581491
                  FROM  pa_labor_multipliers m,
                        pa_tasks old_tsk,
                        pa_tasks new_tsk
                  WHERE old_tsk.project_id = x_orig_project_id
                    and m.task_id = old_tsk.task_id
                    and old_tsk.task_number = new_tsk.task_number
                    and new_tsk.project_id = x_new_project_id;

        -- anlee
        -- Classification enhancement changes
        x_err_stage := 'copying task level classifications ';

        INSERT INTO pa_project_classes (
                       project_id
                ,      class_code
                ,      class_category
                ,      code_percentage
                ,      object_id
                ,      object_type
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      attribute_category
                ,      attribute1
                ,      attribute2
                ,      attribute3
                ,      attribute4
                ,      attribute5
                ,      attribute6
                ,      attribute7
                ,      attribute8
                ,      attribute9
                ,      attribute10
                ,      attribute11
                ,      attribute12
                ,      attribute13
                ,      attribute14
                ,      attribute15 )
                SELECT
                       NULL
                ,      pc.class_code
		,      pc.class_category
                ,      pc.code_percentage
                ,      new_tsk.task_id
                ,      'PA_TASKS'
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      pc.attribute_category
                ,      pc.attribute1
                ,      pc.attribute2
                ,      pc.attribute3
                ,      pc.attribute4
                ,      pc.attribute5
                ,      pc.attribute6
                ,      pc.attribute7
                ,      pc.attribute8
                ,      pc.attribute9
                ,      pc.attribute10
                ,      pc.attribute11
                ,      pc.attribute12
                ,      pc.attribute13
                ,      pc.attribute14
                ,      pc.attribute15
                  FROM
                       pa_project_classes pc,
                       pa_tasks new_tsk,
                       pa_tasks old_tsk
                 WHERE pc.object_id = old_tsk.task_id
                 AND   pc.object_type = 'PA_TASKS'
                 AND   new_tsk.project_id = x_new_project_id
                 AND   old_tsk.project_id = x_orig_project_id
                 AND   new_tsk.task_number = old_tsk.task_number;

        -- anlee
        -- End changes
	x_err_stack := old_stack;

exception
       when others then
           x_err_code := SQLCODE;
           --Added by rtarway for BUG 3875746
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_CORE2',
                          p_procedure_name => 'COPY_TASK',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
           rollback to copy_task;
           raise;
           --End Add by rtarway for BUG 3875746
end copy_task;



-- ------------------------------------------------------------
-- Create_Def_Prj_Stus_Controls
--   This procedure creates the default project status controls
--   for a new project status.  The defaults are created from
--   the system status of the new status being created.
--
--   This procedure should be called after inserting a new
--   project status.
-- ------------------------------------------------------------

PROCEDURE Create_Def_Prj_Stus_Controls(
			X_Project_Status_Code		IN	VARCHAR2,
			X_Project_System_Status_Code	IN	VARCHAR2,
			X_err_code			IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_err_stage			IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_err_stack			IN OUT  NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895


  l_old_stack      varchar2(630);
  CURSOR l_get_controls_csr IS
  SELECT 'x' FROM pa_project_status_controls
  WHERE project_status_code = X_Project_Status_Code
  AND project_system_status_code IS NULL;
  l_dummy      VARCHAR2(1);
  x_status_type      VARCHAR2(30);

BEGIN

  X_err_code := 0;
  l_old_stack := X_err_stack;
  X_err_stack := X_err_stack || '->Create_Def_Prj_Stus_Controls';

  Select status_type
  INTO   x_status_type
  From   pa_project_statuses
  Where  project_status_code=X_Project_Status_Code ;

    INSERT INTO pa_project_status_controls (
	PROJECT_STATUS_CODE,
	PROJECT_SYSTEM_STATUS_CODE,
	ACTION_CODE,
	SORT_ORDER,
	ALLOW_OVERRIDES_FLAG,
	ENABLED_FLAG,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	STATUS_TYPE,
	COPY_TO_USER_STATUS_FLAG  --Added column for bug 2581491
    ) SELECT
	X_Project_Status_Code,
	NULL,
	action_code,
	sort_order,
	allow_overrides_flag,
	enabled_flag,
	trunc(sysdate),
	NULL,
	sysdate,
	FND_GLOBAL.User_ID,
	sysdate,
	FND_GLOBAL.User_ID,
	FND_GLOBAL.Login_ID,
	x_status_type,
	COPY_TO_USER_STATUS_FLAG
      FROM  pa_project_status_controls pas1
      WHERE pas1.project_system_status_code = X_Project_System_Status_Code
      AND nvl(pas1.copy_to_user_status_flag,'Y') <> 'N'
      AND NOT EXISTS
          (SELECT 'x' FROM pa_project_status_controls
           WHERE project_status_code = X_Project_Status_Code
           AND action_code = pas1.action_code
           AND project_system_status_code IS NULL);
EXCEPTION
  WHEN OTHERS THEN
    X_err_code := SQLCODE;

END Create_Def_Prj_Stus_Controls;



END PA_PROJECT_CORE2 ;

/
