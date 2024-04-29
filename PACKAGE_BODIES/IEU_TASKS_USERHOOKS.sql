--------------------------------------------------------
--  DDL for Package Body IEU_TASKS_USERHOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_TASKS_USERHOOKS" AS
/* $Header: IEUVTUHB.pls 120.12 2006/04/28 05:19:56 nveerara ship $ */


l_task_source_obj_type_code VARCHAR2(500);
l_del_task_id NUMBER;

l_object_code VARCHAR2(5);
l_not_valid_flag varchar2(5);
l_workitem_obj_code VARCHAR2(30);
l_owner_type_actual VARCHAR2(30);

   PROCEDURE create_task_uwqm_pre ( x_return_status  OUT NOCOPY  VARCHAR2  ) As

    l_work_item_id NUMBER;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_return_status varchar2(5);
    l_assignee_id number := null;
    l_assignee_type varchar2(30) := null;
    l_due_date   date;
    l_priority_code varchar2(30);
    l_importance_level number;
    l_task_status varchar2(30);
    l_task_status_id number := null;
    l_ws_id1            NUMBER;
    l_ws_id2            NUMBER := null;
    l_association_ws_id NUMBER;
    l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
    l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
    l_tasks_rules_func VARCHAR2(500);

    l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
    l_def_data_list   SYSTEM.DEF_WR_DATA_NST;
    l_orig_grp_owner  NUMBER;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_workitem_comment_code2 varchar2(100) := null;
    l_workitem_comment_code3 varchar2(100) := null;
   begin

    l_priority_code := 'LOW';
    l_dist_from     := 'GROUP_OWNED';
    l_dist_to       := 'INDIVIDUAL_ASSIGNED';
       -- reset del task pkg lvl variable
	l_del_task_id := null;

       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

--     l_workitem_comment_code1 := 'GO_IA';
/***** Bookings End Date will be used as Due Date. This is available in Assignee hooks ***************
     if jtf_tasks_pub.p_task_user_hooks.date_selected = 'P' then
        l_due_date :=  jtf_tasks_pub.p_task_user_hooks.planned_end_date;
         l_workitem_comment_code2 := 'PLAN_DUE_DT';
     elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'A' then
        l_due_date :=  jtf_tasks_pub.p_task_user_hooks.actual_end_date;
         l_workitem_comment_code2 := 'ACTUAL_DUE_DT';
     elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'S' then
        l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
         l_workitem_comment_code2 := 'SCHD_DUE_DT';
     elsif jtf_tasks_pub.p_task_user_hooks.date_selected is null then
        -- Niraj Bug 4609285 Commented following 2 lines. Making default as Scheduled Date in case of Null value
	   -- l_due_date :=  null;
        -- l_workitem_comment_code2 := 'NULL_DUE_DT';
        l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
        l_workitem_comment_code2 := 'SCHD_DUE_DT';
     end if;
*****************************************************************************/
       begin
         select importance_level
         into l_importance_level
         from jtf_task_priorities_vl
         where task_priority_id = jtf_tasks_pub.p_task_user_hooks.task_priority_id;
         exception when others then null;
       end;

    if l_importance_level = 1 then
      l_workitem_comment_code3 := 'IMP_LEVEL_C';
    elsif l_importance_level = 2 then
      l_workitem_comment_code3 := 'IMP_LEVEL_H';
    elsif l_importance_level = 3 then
      l_workitem_comment_code3 := 'IMP_LEVEL_M';
    elsif l_importance_level = 4 then
      l_workitem_comment_code3 := 'IMP_LEVEL_L';
    elsif l_importance_level >=5 then
      l_workitem_comment_code3 := 'IMP_LEVEL_O';
    end if;

     if l_importance_level < 5 then

       begin
         select priority_code
         into l_priority_code
         from ieu_uwqm_priorities_b
         where priority_level = l_importance_level;
         exception when others then null;
       end;

     elsif l_importance_level >= 5 then

       begin
         select priority_code
         into l_priority_code
         from ieu_uwqm_priorities_b
         where priority_level = 4;
         exception when others then null;
       end;

     end if;

     begin
      select 'CLOSE' into l_task_status
      from jtf_task_statuses_vl
      where (nvl(closed_flag, 'N') = 'Y'
      or nvl(completed_flag, 'N') = 'Y'
      or nvl(cancelled_flag, 'N') = 'Y'
      or nvl(rejected_flag, 'N') = 'Y')
      and task_status_id = jtf_tasks_pub.p_task_user_hooks.task_status_id;
      EXCEPTION WHEN others THEN
        begin
          select 'SLEEP' into l_task_status
          from jtf_task_statuses_vl
          where nvl(on_hold_flag, 'N') = 'Y'
          and task_status_id = jtf_tasks_pub.p_task_user_hooks.task_status_id;
          EXCEPTION WHEN others THEN
            l_task_status := 'OPEN';
        end;
     end;

     if (jtf_tasks_pub.p_task_user_hooks.source_object_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
               --where  object_code = 'TASK'
	       --and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = jtf_tasks_pub.p_task_user_hooks.source_object_type_code
		-- and    nvl(not_valid_flag,'N') = 'N';
                 and  nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
		   AND    a.ws_id = b.ws_id
		 --AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;


              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

     end if; /* source_object_type_code is not null */

     if l_activation_status = 'Y' then

     if (l_tasks_rules_func is not null)
     then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            l_tasks_data_list.extend;

            l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'CREATE_TASK',
                jtf_tasks_pub.p_task_user_hooks.task_id,
                null,
                jtf_tasks_pub.p_task_user_hooks.task_number,
                jtf_tasks_pub.p_task_user_hooks.task_name,
                jtf_tasks_pub.p_task_user_hooks.task_type_id,
                jtf_tasks_pub.p_task_user_hooks.task_status_id,
                jtf_tasks_pub.p_task_user_hooks.task_priority_id,
                jtf_tasks_pub.p_task_user_hooks.owner_id,
                jtf_tasks_pub.p_task_user_hooks.owner_type_code,
                jtf_tasks_pub.p_task_user_hooks.source_object_id,
                jtf_tasks_pub.p_task_user_hooks.source_object_type_code,
                jtf_tasks_pub.p_task_user_hooks.customer_id,
                jtf_tasks_pub.p_task_user_hooks.date_selected,
                jtf_tasks_pub.p_task_user_hooks.planned_start_date,
                jtf_tasks_pub.p_task_user_hooks.planned_end_date,
                jtf_tasks_pub.p_task_user_hooks.scheduled_start_date,
                jtf_tasks_pub.p_task_user_hooks.scheduled_end_date,
                jtf_tasks_pub.p_task_user_hooks.actual_start_date,
                jtf_tasks_pub.p_task_user_hooks.actual_end_date,
                null,
                null,
                null);

             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = jtf_tasks_pub.p_task_user_hooks.task_id
--                and    workitem_obj_code = 'TASK'
                and    workitem_obj_code = l_workitem_obj_code
--                and    owner_type_actual = 'RS_GROUP';
                and    owner_type_actual = l_owner_type_actual;

             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                l_task_status,
                l_priority_code,
                l_due_date,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;

     else
            -- Create work item only when the task is in Open status else return success
	    If (l_task_status <> 'CLOSE')
	    then

            BEGIN

               l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

               l_audit_trail_rec.extend;

               l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
										('WORKITEM_CREATION',
										 'CREATE_WR_ITEM',
										 690,
										 'IEU_TASKS_USERHOOKS.CREATE_TASK_UWQM_PRE',
                                                             l_workitem_comment_code1,
                                                             l_workitem_comment_code2,
                                                             l_workitem_comment_code3,
                                                             null,
                                                             null);

                   if jtf_tasks_pub.p_task_user_hooks.entity = 'TASK' then

                      IEU_WR_PUB.CREATE_WR_ITEM(
                      p_api_version => 1.0,
                      p_init_msg_list => FND_API.G_TRUE,
                      p_commit => FND_API.G_FALSE,
                      p_workitem_obj_code => 'TASK',
                      p_workitem_pk_id => jtf_tasks_pub.p_task_user_hooks.task_id,
                      p_work_item_number => to_number(jtf_tasks_pub.p_task_user_hooks.task_number),
                      p_title => jtf_tasks_pub.p_task_user_hooks.task_name,
                      p_party_id => jtf_tasks_pub.p_task_user_hooks.customer_id,
                      p_priority_code => l_priority_code,
                      p_due_date => l_due_date,
                      p_owner_id => jtf_tasks_pub.p_task_user_hooks.owner_id,
                      p_owner_type => jtf_tasks_pub.p_task_user_hooks.owner_type_code,
                      p_assignee_id => l_assignee_id,
                      p_assignee_type => l_assignee_type,
                      p_source_object_id => jtf_tasks_pub.p_task_user_hooks.source_object_id,
                      p_source_object_type_code => jtf_tasks_pub.p_task_user_hooks.source_object_type_code,
                      p_application_id => 690,
                      p_ieu_enum_type_uuid => 'TASKS',
                      p_work_item_status => l_task_status,
                      p_user_id  => FND_GLOBAL.USER_ID,
                      p_login_id => FND_GLOBAL.LOGIN_ID,
                      p_audit_trail_rec => l_audit_trail_rec,
                      x_work_item_id => L_WORK_ITEM_ID,
                      x_msg_count => l_msg_count,
                      x_msg_data => L_MSG_DATA,
                      x_return_status => L_RETURN_STATUS);

                      x_return_status := l_return_status;

                   else
                     x_return_status := fnd_api.g_ret_sts_success;

                   end if;

          EXCEPTION
                   WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          END;

	  else   -- task is not in Open status, so return success
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	  end if;

       end if; /* Tasks Rules Func */

       elsif l_activation_status = 'N' then
          x_return_status := FND_API.G_RET_STS_SUCCESS;
       end if;
   end create_task_uwqm_pre;


   PROCEDURE update_task_uwqm_pre ( x_return_status  OUT NOCOPY VARCHAR2 ) As

    l_work_item_id NUMBER;    L_MSG_COUNT NUMBER;
    l_msg_data VARCHAR2(2000);
    l_return_status varchar2(5);
    l_assignee_id number := null;
    l_assignee_type varchar2(30) := null;
    l_task_status varchar2(20);
    l_due_date   date;
    l_priority_code varchar2(30);
    l_importance_level number;
    l_task_status_id number;
    l_cur_task_status varchar2(30);
    l_count number;
    l_task_type_id number;
    l_ws_id1            NUMBER;
    l_ws_id2            NUMBER := null;
    l_association_ws_id NUMBER;
    l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
    l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
    l_tasks_rules_func VARCHAR2(500);
    l_orig_grp_owner  NUMBER;

    l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
    l_def_data_list   SYSTEM.DEF_WR_DATA_NST;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_workitem_comment_code2 varchar2(100) := null;
    l_workitem_comment_code3 varchar2(100) := null;
    l_workitem_comment_code4 varchar2(100) := null;
    l_event_key varchar2(2000);

    l_wr_due_date   	date;
    l_wr_priority_id 	number := null;
    l_priority_id 	number;

    l_status_id			NUMBER;
    l_wr_status_id		ieu_uwqm_items.status_id%TYPE;
    l_wr_party_id		ieu_uwqm_items.party_id%TYPE;
    l_wr_owner_id		ieu_uwqm_items.owner_id%TYPE;
    l_wr_title			ieu_uwqm_items.title%TYPE;
    l_wr_owner_type_actual	ieu_uwqm_items.owner_type_actual%TYPE;
    l_wr_source_object_id	ieu_uwqm_items.source_object_id%TYPE;
    l_wr_source_object_type_code ieu_uwqm_items.source_object_type_code%TYPE;
    l_update_task_reqd_flag	VARCHAR2(1);


   begin


    l_update_task_reqd_flag := 'n';
    l_priority_code := 'LOW';
    l_dist_from := 'GROUP_OWNED';
    l_dist_to   := 'INDIVIDUAL_ASSIGNED';

	/*** This procedure will sync up any updates on the Task Work item
	**   First the Activation Status is checked
	**   If the Work Source is activated, then check if any Tasks Rules Function is registered
	**   If the task Rules function is present, then execute it
	**   If there is not Tasks Rules Function registered, update the work repository item
	**   In certain cases like Work items in 'Closed' status, the work item may not be present in the work repository
	**   If the work item does not exist then create them
	***/

       -- reset del task pkg lvl variable
	l_del_task_id := null;


       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

     -- Set this variable as we require this for Task Asg processing
     l_task_source_obj_type_code := jtf_tasks_pub.p_task_user_hooks.source_object_type_code;
	if jtf_tasks_pub.p_task_user_hooks.date_selected = 'P' then
	   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.planned_end_date;
	   l_workitem_comment_code2 := 'PLAN_DUE_DT';
	elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'A' then
	   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.actual_end_date;
	   l_workitem_comment_code2 := 'ACTUAL_DUE_DT';
	elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'S' then
	   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
	   l_workitem_comment_code2 := 'SCHD_DUE_DT';
	elsif jtf_tasks_pub.p_task_user_hooks.date_selected is null then
	   -- Niraj Bug 4609285 Commented following 2 lines. Making default as Scheduled Date in case of Null value
	-- l_due_date :=  null;
	   -- l_workitem_comment_code2 := 'NULL_DUE_DT';
	   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
	   l_workitem_comment_code2 := 'SCHD_DUE_DT';
	end if;

	begin
	  select importance_level
	  into l_importance_level
	  from jtf_task_priorities_vl
	  where task_priority_id = jtf_tasks_pub.p_task_user_hooks.task_priority_id;
	  exception when others then null;
       end;

       if l_importance_level < 5 then

	begin
	  select priority_code, priority_id
	  into l_priority_code, l_priority_id
	  from ieu_uwqm_priorities_b
	  where priority_level = l_importance_level;
	  exception when others then null;
	end;

      elsif l_importance_level >= 5 then

	begin
	  select priority_code, priority_id
	  into l_priority_code, l_priority_id
	  from ieu_uwqm_priorities_b
	  where priority_level = 4;
	  exception when others then null;
	end;

      end if;

      begin
	select task_status_id into l_task_status_id from jtf_tasks_b
	where task_id = jtf_tasks_pub.p_task_user_hooks.task_id;
      end;

      begin
       select 'CLOSE' into l_task_status
       from jtf_task_statuses_vl
       where (nvl(closed_flag, 'N') = 'Y'
       or nvl(completed_flag, 'N') = 'Y'
       or nvl(cancelled_flag, 'N') = 'Y'
       or nvl(rejected_flag, 'N') = 'Y')
       and task_status_id = jtf_tasks_pub.p_task_user_hooks.task_status_id;
       l_status_id := 3;
       EXCEPTION WHEN others THEN
	begin
	  select 'SLEEP' into l_task_status
	  from jtf_task_statuses_vl
	  where nvl(on_hold_flag, 'N') = 'Y'
	  and task_status_id = jtf_tasks_pub.p_task_user_hooks.task_status_id;
	  l_status_id := 5;
	  EXCEPTION WHEN others THEN
	     l_task_status := 'OPEN';
	     l_status_id := 0;
	end;
      end;

--     l_workitem_comment_code1 := 'GO_IA';

     if (jtf_tasks_pub.p_task_user_hooks.source_object_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
               --where  object_code = 'TASK'
	       --and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = jtf_tasks_pub.p_task_user_hooks.source_object_type_code
              	--and    nvl(not_valid_flag,'N') = 'N';
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
		 --AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;

              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

     end if; /* source_object_type_code is not null */

     if l_activation_status = 'Y' then


     if (l_tasks_rules_func is not null)
     then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            l_tasks_data_list.extend;

            l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'UPDATE_TASK',
                jtf_tasks_pub.p_task_user_hooks.task_id,
                null,
                jtf_tasks_pub.p_task_user_hooks.task_number,
                jtf_tasks_pub.p_task_user_hooks.task_name,
                jtf_tasks_pub.p_task_user_hooks.task_type_id,
                jtf_tasks_pub.p_task_user_hooks.task_status_id,
                jtf_tasks_pub.p_task_user_hooks.task_priority_id,
                jtf_tasks_pub.p_task_user_hooks.owner_id,
                jtf_tasks_pub.p_task_user_hooks.owner_type_code,
                jtf_tasks_pub.p_task_user_hooks.source_object_id,
                jtf_tasks_pub.p_task_user_hooks.source_object_type_code,
                jtf_tasks_pub.p_task_user_hooks.customer_id,
                jtf_tasks_pub.p_task_user_hooks.date_selected,
                jtf_tasks_pub.p_task_user_hooks.planned_start_date,
                jtf_tasks_pub.p_task_user_hooks.planned_end_date,
                jtf_tasks_pub.p_task_user_hooks.scheduled_start_date,
                jtf_tasks_pub.p_task_user_hooks.scheduled_end_date,
                jtf_tasks_pub.p_task_user_hooks.actual_start_date,
                jtf_tasks_pub.p_task_user_hooks.actual_end_date,
                null,
                null,
                null);


             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = jtf_tasks_pub.p_task_user_hooks.task_id
--                and    workitem_obj_code = 'TASK'
--                and    owner_type_actual = 'RS_GROUP';
                and    workitem_obj_code = l_workitem_obj_code
                and    owner_type_actual = l_owner_type_actual;

             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                l_task_status,
                l_priority_code,
                l_due_date,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;
     else

        BEGIN

/***** Bookings End Date will be used as Due Date. This is available in Assignee hooks ***************
		if jtf_tasks_pub.p_task_user_hooks.date_selected = 'P' then
		   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.planned_end_date;
		   l_workitem_comment_code2 := 'PLAN_DUE_DT';
		elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'A' then
		   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.actual_end_date;
		   l_workitem_comment_code2 := 'ACTUAL_DUE_DT';
		elsif jtf_tasks_pub.p_task_user_hooks.date_selected = 'S' then
		   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
		   l_workitem_comment_code2 := 'SCHD_DUE_DT';
		elsif jtf_tasks_pub.p_task_user_hooks.date_selected is null then
		   -- Niraj Bug 4609285 Commented following 2 lines. Making default as Scheduled Date in case of Null value
             -- l_due_date :=  null;
		   -- l_workitem_comment_code2 := 'NULL_DUE_DT';
		   l_due_date :=  jtf_tasks_pub.p_task_user_hooks.scheduled_end_date;
		   l_workitem_comment_code2 := 'SCHD_DUE_DT';
		end if;
*****************************/

	   BEGIN
	     l_workitem_obj_code := 'TASK';

	     select	assignee_id,
	     		assignee_type,
			due_date,
			priority_id,
			party_id,
			owner_id,
			title,
			status_id,
			owner_type_actual,
			source_object_id,
			source_object_type_code
	     into 	l_assignee_id,
	     		l_assignee_type,
			l_wr_due_date,
			l_wr_priority_id,
	     	 	l_wr_party_id,
			l_wr_owner_id,
			l_wr_title,
			l_wr_status_id,
			l_wr_owner_type_actual,
			l_wr_source_object_id,
			l_wr_source_object_type_code
	     from 	ieu_uwqm_items
	     where 	workitem_pk_id = jtf_tasks_pub.p_task_user_hooks.task_id
	--                     and workitem_obj_code = 'TASK';
	     and 	workitem_obj_code = l_workitem_obj_code;

	     l_count := 1;

	   EXCEPTION
	     	when no_data_found then     -- When no work item exists in Work Repository table, say by deleting it manually
			l_count := 0;  	    -- Used for Creating a new Work item
	     	when others then null;
	   END;

	  -- Niraj: Added for bug 4220060
     	  IF ((NVL(l_wr_party_id, -1) <> NVL(jtf_tasks_pub.p_task_user_hooks.customer_id, -1)) OR
   	      (NVL(l_wr_owner_id, -1) <> NVL(jtf_tasks_pub.p_task_user_hooks.owner_id, -1)) OR
   	      (NVL(l_wr_title, '$%&*@') <> NVL(jtf_tasks_pub.p_task_user_hooks.task_name, '$%&*@')) OR
   	      (NVL(l_wr_status_id, -1) <> NVL(l_status_id, -1)) OR
   	      (NVL(l_wr_priority_id, -1) <> NVL(l_priority_id, -1)) OR
	      (NVL(l_wr_owner_type_actual, '$%&*@') <> NVL(jtf_tasks_pub.p_task_user_hooks.owner_type_code, '$%&*@')) OR
	      (NVL(l_wr_source_object_id, -1) <> NVL(jtf_tasks_pub.p_task_user_hooks.source_object_id, -1)) OR
	      (NVL(l_wr_source_object_type_code, '$%&*@') <> NVL(jtf_tasks_pub.p_task_user_hooks.source_object_type_code, '$%&*@')) OR
	      (NVL(l_wr_due_date, to_date('30-12-1000', 'DD-MM-RRRR')) <> NVL(l_due_date, to_date('30-12-1000', 'DD-MM-RRRR'))))  THEN
   		l_update_task_reqd_flag := 'y';
   	  ELSE
	        l_update_task_reqd_flag := 'n';
   	  END IF;

	  -- Start IF-1
          if (l_update_task_reqd_flag = 'y') THEN
	  	  -- Start IF-2
		  if (jtf_tasks_pub.p_task_user_hooks.entity = 'TASK')
		  then
		  	 -- Start IF-3
			 if ((l_task_status = 'CLOSE') and (l_count = 0)) THEN
			 	x_return_status := fnd_api.g_ret_sts_success;
			 else
			    if trunc(nvl(l_due_date, FND_API.G_MISS_DATE)) <> trunc(nvl(l_wr_due_date, FND_API.G_MISS_DATE))
			    then
			    	l_workitem_comment_code2 := l_workitem_comment_code2;
			    else
			    	l_workitem_comment_code2 := null;
			    end if;

		   	    if l_priority_id <> l_wr_priority_id then
			      if l_importance_level = 1 then
				 l_workitem_comment_code3 := 'IMP_LEVEL_C';
			      elsif l_importance_level = 2 then
				 l_workitem_comment_code3 := 'IMP_LEVEL_H';
			      elsif l_importance_level = 3 then
				 l_workitem_comment_code3 := 'IMP_LEVEL_M';
			      elsif l_importance_level = 4 then
				 l_workitem_comment_code3 := 'IMP_LEVEL_L';
			      elsif l_importance_level >=5 then
				 l_workitem_comment_code3 := 'IMP_LEVEL_O';
			      end if;
		            else
			      l_workitem_comment_code3 := null;
		            end if;

			    if (l_dist_from = 'GROUP_OWNED') and
			     (l_dist_to = 'INDIVIDUAL_ASSIGNED')
			    then
			      if jtf_tasks_pub.p_task_user_hooks.owner_type_code = 'RS_GROUP' then
				     begin
					select c.resource_id, c.resource_type_code
					into l_assignee_id, l_assignee_type
					from jtf_task_assignments c
					where c.task_id = jtf_tasks_pub.p_task_user_hooks.task_id
					and c.assignee_role = 'ASSIGNEE'
					and c.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
					and c.resource_id in ( select resource_id
							from jtf_rs_group_members
							where group_id = jtf_tasks_pub.p_task_user_hooks.owner_id
							and nvl(delete_flag,'N') <> 'Y')
					and c.last_update_date = (select max(a.last_update_date)
								    from jtf_task_assignments a,jtf_task_statuses_vl b
								    where a.task_id = jtf_tasks_pub.p_task_user_hooks.task_id
								    and a.assignee_role = 'ASSIGNEE'
								    and a.assignment_status_id = b.task_status_id
								    and a.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
								    and a.resource_id in  ( select resource_id
											    from jtf_rs_group_members
												    where group_id = jtf_tasks_pub.p_task_user_hooks.owner_id
											    and nvl(delete_flag,'N') <> 'Y')
								    and (nvl(b.closed_flag, 'N') = 'N'
								    and nvl(b.completed_flag, 'N') = 'N'
								    and nvl(b.cancelled_flag, 'N') = 'N'
								    and nvl(b.rejected_flag, 'N') = 'N'
								    and b.task_status_id = c.assignment_status_id))
					and rownum < 2;
					exception when others then
					l_assignee_id := null;
					l_assignee_type := null;
					end;
			      else
				     l_assignee_id := null;
				     l_assignee_type := null;
			      end if;
			   end if;

			   if (l_count = 0) then
				l_event_key := 'CREATE_WR_ITEM';
			   else
				l_event_key := 'UPDATE_WR_ITEM';
			   end if;

			   l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

			   l_audit_trail_rec.extend;

			   l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
									('WORKITEM_UPDATE',
									 l_event_key,
									 690,
									 'IEU_TASKS_USERHOOKS.UPDATE_TASK_UWQM_PRE',
						     l_workitem_comment_code1,
						     l_workitem_comment_code2,
						     l_workitem_comment_code3,
						     l_workitem_comment_code4,
						     null);

   		   	   -- Start IF-4
		   	   if ((l_task_status <> 'CLOSE') and (l_count = 0)) then
		              IEU_WR_PUB.CREATE_WR_ITEM(
		              p_api_version => 1.0,
			      p_init_msg_list => FND_API.G_TRUE,
			      p_commit => FND_API.G_FALSE,
			      p_workitem_obj_code => 'TASK',
			      p_workitem_pk_id => jtf_tasks_pub.p_task_user_hooks.task_id,
			      p_work_item_number => to_number(jtf_tasks_pub.p_task_user_hooks.task_number),
			      p_title => jtf_tasks_pub.p_task_user_hooks.task_name,
			      p_party_id => jtf_tasks_pub.p_task_user_hooks.customer_id,
			      p_priority_code => l_priority_code,
			      p_due_date => l_due_date,
			      p_owner_id => jtf_tasks_pub.p_task_user_hooks.owner_id,
			      p_owner_type => jtf_tasks_pub.p_task_user_hooks.owner_type_code,
			      p_assignee_id => l_assignee_id,
			      p_assignee_type => l_assignee_type,
			      p_source_object_id => jtf_tasks_pub.p_task_user_hooks.source_object_id,
			      p_source_object_type_code => jtf_tasks_pub.p_task_user_hooks.source_object_type_code,
			      p_application_id => 690,
			      p_ieu_enum_type_uuid => 'TASKS',
			      p_work_item_status => l_task_status,
			      p_user_id  => FND_GLOBAL.USER_ID,
			      p_login_id => FND_GLOBAL.LOGIN_ID,
	        	      p_audit_trail_rec => l_audit_trail_rec,
			      x_work_item_id => L_WORK_ITEM_ID,
			      x_msg_count => l_msg_count,
			      x_msg_data => L_MSG_DATA,
			      x_return_status => L_RETURN_STATUS);

		   	      x_return_status := l_return_status;
		          else
		              IEU_WR_PUB.UPDATE_WR_ITEM(
			      p_api_version => 1.0,
			      p_init_msg_list => FND_API.G_TRUE,
			      p_commit => FND_API.G_FALSE,
			      p_workitem_obj_code => 'TASK',
			      p_workitem_pk_id => jtf_tasks_pub.p_task_user_hooks.task_id,
			      p_title => jtf_tasks_pub.p_task_user_hooks.task_name,
			      p_party_id => jtf_tasks_pub.p_task_user_hooks.customer_id,
			      p_priority_code => l_priority_code,
			      p_due_date => l_due_date,
			      p_owner_id => jtf_tasks_pub.p_task_user_hooks.owner_id,
			      p_owner_type => jtf_tasks_pub.p_task_user_hooks.owner_type_code,
			      p_assignee_id => l_assignee_id,
			      p_assignee_type => l_assignee_type,
			      p_source_object_id => jtf_tasks_pub.p_task_user_hooks.source_object_id,
			      p_source_object_type_code => jtf_tasks_pub.p_task_user_hooks.source_object_type_code,
			      p_application_id => 690,
			      p_work_item_status => l_task_status,
			      p_user_id  => FND_GLOBAL.USER_ID,
			      p_login_id => FND_GLOBAL.LOGIN_ID,
			      p_audit_trail_rec => l_audit_trail_rec,
			      x_msg_count => L_MSG_COUNT,
			      x_msg_data => L_MSG_DATA,
			      x_return_status => L_RETURN_STATUS);

			      x_return_status := l_return_status;
		          end if;
			  -- End IF-4

			  if (x_return_status <> fnd_api.g_ret_sts_success) then
	    	      --      x_return_status := fnd_api.g_ret_sts_unexp_error;
			  	raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     	  end if;
			End if;
			-- End IF-3
	  	  else
			x_return_status := fnd_api.g_ret_sts_success;
	  	  end if;
          	  -- End IF-2 (Task Check)
	  else	  -- ie if flag=n
	  	  x_return_status := fnd_api.g_ret_sts_success;
	  end if;
          -- End IF-1

          EXCEPTION
	     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	     WHEN OTHERS THEN
	   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          END;

     end if; /* Tasks Rules Func */

     elsif l_activation_status = 'N' then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
     end if;
  end update_task_uwqm_pre;


  PROCEDURE delete_task_uwqm_pre ( x_return_status  OUT NOCOPY VARCHAR2 ) As

   l_msg_count NUMBER;
   l_msg_data VARCHAR2(2000);
   l_return_status varchar2(5);
   l_task_type_id number;

   l_entity        varchar2(30);

    l_ws_id1            NUMBER;
    l_ws_id2            NUMBER := null;
    l_association_ws_id NUMBER;
    l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
    l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
    l_tasks_rules_func VARCHAR2(500);
    l_orig_grp_owner  NUMBER;

    l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
    l_def_data_list  SYSTEM.DEF_WR_DATA_NST;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_wi_exists VARCHAR2(10);
  begin


       l_dist_from := 'GROUP_OWNED';
       l_dist_to   := 'INDIVIDUAL_ASSIGNED';
       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

--     l_workitem_comment_code1 := 'GO_IA';

--     if  (l_task_source_obj_type_code is null)
--     then
         begin
             select source_object_type_code
             into   l_task_source_obj_type_code
             from   jtf_tasks_b
             where  task_id = jtf_tasks_pub.p_task_user_hooks.task_id;

         exception when others then
             l_task_source_obj_type_code := null;
         end;
--      end if;

     if (l_task_source_obj_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
              -- where  object_code = 'TASK'
               --and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = l_task_source_obj_type_code
               --and    nvl(not_valid_flag,'N') = 'N';
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
		 --AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;

              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

        end if; /* source_object_type_code is not null */

	--insert into p_temp values ('act sts: '||l_activation_status||' rules func: '||l_tasks_rules_func);

     if l_activation_status = 'Y' then

        if (l_tasks_rules_func is not null)
        then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            l_tasks_data_list.extend;

            l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'DELETE_TASK',
                jtf_tasks_pub.p_task_user_hooks.task_id,
                null,
                null,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                l_task_source_obj_type_code,
                FND_API.G_MISS_NUM,
                NULL,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                null,
                null,
                null);

             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = jtf_tasks_pub.p_task_user_hooks.task_id
--                and    workitem_obj_code = 'TASK'
--                and    owner_type_actual = 'RS_GROUP';
                and    workitem_obj_code = l_workitem_obj_code
                and    owner_type_actual = l_owner_type_actual;
             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                'DELETE',
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_DATE,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;
        else

              BEGIN

		   -- Check if the Work Item exists in UWQ Metaphor Table

		   begin
		      select 'Y'
		      into   l_wi_exists
		      from ieu_uwqm_items
		      where workitem_pk_id = jtf_tasks_pub.p_task_user_hooks.task_id
		      and workitem_obj_code = 'TASK';
		   exception
		     when others then
			l_wi_exists := 'N';
		   end;

		   --insert into p_temp(msg) values ('WI exists in table: '||l_wi_exists);

		   -- Closed Work Items are not currently migrated. No updates will be done to UWQ Metaphor table
		   -- if the Task is in closed/deleted status and the Work Item is not present in UWQ table.

		   if (l_wi_exists = 'Y')
		   then

			     begin
			       select task_type_id, entity into l_task_type_id, l_entity
			       from jtf_tasks_b
			       where task_id = jtf_tasks_pub.p_task_user_hooks.task_id;
			       exception when others then l_task_type_id := null;
			     end;

			     l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

			     l_audit_trail_rec.extend;

			     l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
											('WORKITEM_UPDATE',
											 'DELETE_WR_ITEM',
											 690,
											 'IEU_TASKS_USERHOOKS.DELETE_TASK_UWQM_PRE',
								     l_workitem_comment_code1,
								     null,
								     null,
								     null,
								     null);


			     if l_entity = 'TASK' then
				IEU_WR_PUB.UPDATE_WR_ITEM(
				p_api_version => 1.0,
				p_init_msg_list => FND_API.G_TRUE,
				p_commit => FND_API.G_FALSE,
				p_workitem_obj_code => 'TASK',
				p_workitem_pk_id => jtf_tasks_pub.p_task_user_hooks.task_id,
				p_title => FND_API.G_MISS_CHAR,
				p_party_id => FND_API.G_MISS_NUM,
				p_priority_code => FND_API.G_MISS_CHAR,
				p_due_date => FND_API.G_MISS_DATE,
				p_owner_id => FND_API.G_MISS_NUM,
				p_owner_type => FND_API.G_MISS_CHAR,
				p_assignee_id => FND_API.G_MISS_NUM,
				p_assignee_type => FND_API.G_MISS_CHAR,
				p_source_object_id => FND_API.G_MISS_NUM,
				p_source_object_type_code => FND_API.G_MISS_CHAR,
				p_application_id => 690,
				p_work_item_status => 'DELETE',
				p_user_id  => FND_GLOBAL.USER_ID,
				p_login_id => FND_GLOBAL.LOGIN_ID,
				p_audit_trail_rec => l_audit_trail_rec,
				x_msg_count => L_MSG_COUNT,
				x_msg_data => L_MSG_DATA,
				x_return_status => L_RETURN_STATUS);

				x_return_status := l_return_status;
			     else
				x_return_status := fnd_api.g_ret_sts_success;
			     end if;
		     else /* Work Item does not exist in Work Repository */

		        --insert into p_temp values('ret success');
			x_return_status := fnd_api.g_ret_sts_success;
		     end if;

		     if (x_return_status = fnd_api.g_ret_sts_success)
		     then
		        l_del_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
		        --insert into p_temp values ('del tsk id: '||l_del_task_id);
		     end if;

                EXCEPTION  WHEN OTHERS THEN
			--insert into p_temp values('excep');
                       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                END;

           end if; /* Tasks Rules Func */
         elsif l_activation_status = 'N' then
          x_return_status := FND_API.G_RET_STS_SUCCESS;
        end if;
  end delete_task_uwqm_pre;

  PROCEDURE create_task_assign_uwqm_pre ( x_return_status OUT NOCOPY VARCHAR2 ) As

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     l_return_status varchar2(5);
     l_owner_id      number;
     l_owner_type    varchar2(25);
     l_source_object_id  number;
     l_source_object_type_code   varchar2(30);
     l_count number := 0;
     l_importance_level number;
     l_assignee_id number;
     l_assignee_type varchar2(30);
     l_status varchar2(20);
     l_task_type_id  number;

     l_ws_id1            NUMBER;
     l_ws_id2            NUMBER := null;
     l_association_ws_id NUMBER;
     l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
     l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
     l_task_asg_count    number := 0;
     l_group_id          varchar2(5);

     l_tasks_rules_func VARCHAR2(500);
     l_orig_grp_owner   NUMBER;

     l_entity            varchar2(30);

    l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
    l_def_data_list  SYSTEM.DEF_WR_DATA_NST;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_workitem_comment_code2 varchar2(100) := null;
    l_wi_exists VARCHAR2(10);
    l_tsk_sts_id NUMBER;
    l_task_status VARCHAR2(500);
    l_del_flag VARCHAR2(10);

    l_ins_task_id   number;
    l_ins_task_number varchar2(30);
    l_ins_customer_id number;
    l_ins_owner_id  number;
    l_ins_owner_type_code varchar2(30);
    l_ins_source_object_id number;
    l_ins_source_object_type_code varchar2(30);
    l_ins_task_name varchar2(80);
    l_ins_assignee_id  number;
    l_ins_assignee_type varchar2(25);
    l_ins_task_priority_id number;
    l_ins_date_selected   varchar2(1);
    l_ins_due_date      date;
    l_ins_planned_end_date  date;
    l_ins_actual_ins_end_date   date;
    l_ins_scheduled_end_date date;
    l_ins_planned_start_date  date;
    l_ins_actual_ins_start_date   date;
    l_ins_scheduled_start_date date;
    l_ins_importance_level number;
    l_ins_priority_code  varchar2(30);
    l_ins_task_status varchar2(10);
    l_ins_task_status_id  number;
    l_ins_task_type_id number;
    l_ins_work_item_id NUMBER;
    l_wr_assignee_id		ieu_uwqm_items.assignee_id%TYPE;  -- Niraj, Bug 4220060, Added
    l_update_wr_item_call	varchar2(5);			  -- Niraj, Bug 4220060, Added

  begin

     l_ins_priority_code := 'LOW';
     l_dist_from := 'GROUP_OWNED';
     l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  /*** Create Task Assignee
   **   First the Activation Status is checked
   **   If the Work Source is activated, then check if any Tasks Rules Function is registered
   **   If the task Rules function is present, then execute it
   **   If the Task Rules function is not registered then the assignee will be created based on the following rules for Standard Tasks
   **   1. Create and assignee in UWQ if Owner is a Group and the assignee should be a member of the group
   **   2. If the Owner is not a group, then Assignee will not be created in UWQ
   **   3. If the Assignee is not a member of the Group, then UWQ Assignee will be the most recent Group member if it exists.
   **      If there are no group members present, then the assignee will be null
   ***/

       -- reset del task pkg lvl variable
	l_del_task_id := null;


       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

--     l_workitem_comment_code1 := 'GO_IA';


--     if  (l_task_source_obj_type_code is null)
--     then
         begin

             select source_object_type_code
             into   l_task_source_obj_type_code
             from   jtf_tasks_b
             where  task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;

         exception when others then
             l_task_source_obj_type_code := null;
         end;
--     end if;


     if (l_task_source_obj_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
              -- where  object_code = 'TASK'
              -- and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = l_task_source_obj_type_code
               --and    nvl(not_valid_flag,'N') = 'N';
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
		   AND    a.ws_id = b.ws_id
		-- AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;

              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

        end if; /* source_object_type_code is not null */

     if l_activation_status = 'Y' then

/*	 insert into p_temp(msg) values ('assignee_role: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role||
					 ' booking end date: '|| jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date); */
        if (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER')
        then
			 l_ins_due_date :=  jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date;
        else
	      -- Get the Bookings End Date from JTF_TASK_ASSIGNMENTS where assignee_role= owner
		  BEGIN

		    SELECT booking_end_date
		    INTO   l_ins_due_date
		    FROM   JTF_TASK_ALL_ASSIGNMENTS
		    WHERE  task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		    AND    assignee_role = 'OWNER';

		  EXCEPTION
		    WHEN OTHERS THEN
		      null;
		  END;
        end if;
		--insert into p_temp(msg) values ('due date: '||l_ins_due_date);

	if (l_tasks_rules_func is not null)
        then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

	    l_tasks_data_list.extend;

	    l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'CREATE_TASK_ASG',
		jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
                null,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                l_task_source_obj_type_code,
                FND_API.G_MISS_NUM,
                NULL,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id);

             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
--                and    workitem_obj_code = 'TASK'
--                and    owner_type_actual = 'RS_GROUP';
                and    workitem_obj_code = l_workitem_obj_code
                and    owner_type_actual = l_owner_type_actual;

             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                l_ins_due_date,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;
       else

          BEGIN

		   -- Get the Task Status Id
		   begin
		      select task_status_id, deleted_flag
		      into l_tsk_sts_id, l_del_flag
		      from jtf_tasks_b
		      where task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;
		   exception
		     when others then null;
		   end;

		   if (jtf_tasks_pub.p_task_user_hooks.task_status_id is not null)
		   then
		      l_tsk_sts_id := jtf_tasks_pub.p_task_user_hooks.task_status_id;
		    end if;

		   -- Get the Task Status based on task Status Id
		    begin
		      select 'CLOSE' into l_task_status
		      from jtf_task_statuses_vl
		      where (nvl(closed_flag, 'N') = 'Y'
		      or nvl(completed_flag, 'N') = 'Y'
		      or nvl(cancelled_flag, 'N') = 'Y'
		      or nvl(rejected_flag, 'N') = 'Y')
		      and task_status_id = l_tsk_sts_id;
		      EXCEPTION WHEN others THEN null;
		    end;

		   -- Check if the Work Item exists in UWQ Metaphor Table
		   begin
		      select 'Y'
		      into   l_wi_exists
		      from ieu_uwqm_items
		      where workitem_pk_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		      and workitem_obj_code = 'TASK';
		   exception
		     when others then
			l_wi_exists := 'N';
		   end;

		  -- insert into p_temp(msg) values ('Task Status Id from Tasks table: '||l_tsk_sts_id||' l_wi_exists: '||l_wi_exists||' l_del_flag: '||l_del_flag);

		   -- Closed Work Items are not currently migrated. No updates will be done to UWQ Metaphor table
		   -- if the Task is in closed/deleted status and the Work Item is not present in UWQ table return Success.

		   if ( ( (l_task_status = 'CLOSE') or (l_del_flag = 'Y') )
			and (l_wi_exists = 'N'))
		   then
		     --   insert into p_temp(msg) values ('close/del and rec does not exists.. ret success');
			x_return_status := fnd_api.g_ret_sts_success;
		   else
			--   insert into p_temp(msg) values (' else condn');
			   if (l_wi_exists = 'N')
			   then
				-- insert into p_temp(msg) values (' selecting data from tasks table');

				  begin

					  select tb.task_id, tb.task_number, tb.customer_id, tb.owner_id, tb.owner_type_code,
						 tb.source_object_id, tb.source_object_type_code,
						 tb.planned_start_date, tb.planned_end_date, tb.actual_start_date, tb.actual_end_date,
						 tb.scheduled_start_date, tb.scheduled_end_date,tb.task_type_id,
						 tb.task_status_id, tt.task_name, tp.importance_level, ip.priority_code
					  into l_ins_task_id, l_ins_task_number, l_ins_customer_id, l_ins_owner_id, l_ins_owner_type_code,
					       l_ins_source_object_id, l_ins_source_object_type_code, l_ins_planned_start_date, l_ins_planned_end_date,
					       l_ins_actual_ins_start_date, l_ins_actual_ins_end_date, l_ins_scheduled_start_date, l_ins_scheduled_end_date,
					       l_ins_task_type_id, l_ins_task_status_id, l_ins_task_name, l_ins_importance_level, l_ins_priority_code
					  from jtf_tasks_b tb, jtf_tasks_tl tt, jtf_task_priorities_vl tp, ieu_uwqm_priorities_b ip
					  where tb.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
					  and tb.entity = 'TASK'
					  and tb.task_id = tt.task_id
					  and tt.language = userenv('LANG')
					  and tp.task_priority_id = nvl(tb.task_priority_id, 4)
					  and least(tp.importance_level, 4) = ip.priority_level;
			          exception
				    when others then
				         null;
				         -- insert into p_temp(msg) values('raising err ');
				         -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					  --raise;
				  end;


				  l_owner_id := l_ins_owner_id;
				  l_owner_type := l_ins_owner_type_code;

				  begin
				       select 'CLOSE' into l_ins_task_status
				       from jtf_task_statuses_vl
				       where (nvl(closed_flag, 'N') = 'Y'
				       or nvl(completed_flag, 'N') = 'Y'
				       or nvl(cancelled_flag, 'N') = 'Y'
				       or nvl(rejected_flag, 'N') = 'Y')
				       and task_status_id = l_ins_task_status_id;
				  EXCEPTION WHEN others THEN
					begin
					  select 'SLEEP' into l_ins_task_status
					  from jtf_task_statuses_vl
					  where nvl(on_hold_flag, 'N') = 'Y'
					  and task_status_id = l_ins_task_status_id;
					  EXCEPTION WHEN others THEN
					     l_ins_task_status := 'OPEN';
					end;
				  end;


				  /****
					insert into p_temp(msg) values('1'||l_ins_task_id||' '|| l_ins_task_number||' '|| l_ins_customer_id||' '|| l_ins_owner_id||' '|| l_ins_owner_type_code);
					insert into p_temp(msg) values('2'||l_ins_source_object_id||' '|| l_ins_source_object_type_code||' '|| l_ins_due_date||' '|| l_ins_planned_start_date);
					insert into p_temp(msg) values('3'||l_ins_planned_end_date||' '|| l_ins_actual_ins_start_date||' '|| l_ins_actual_ins_end_date||' '|| l_ins_scheduled_start_date||' '|| l_ins_scheduled_end_date);
					insert into p_temp(msg) values('4'||l_ins_task_type_id||' '|| l_ins_task_status_id||' '|| l_ins_task_name||' '|| l_ins_importance_level||' '|| l_ins_priority_code);
				  *****/


			    else
				   begin
				     l_workitem_obj_code := 'TASK';
				     select owner_id, owner_type, source_object_id, source_object_type_code, assignee_id -- Niraj, 4220060, Added assignee_id
				     into  l_owner_id, l_owner_type, l_source_object_id, l_source_object_type_code, l_wr_assignee_id  -- Niraj, 4220060, Added
				     from ieu_uwqm_items
				     where workitem_pk_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		--                     and workitem_obj_code = 'TASK';
				     and workitem_obj_code = l_workitem_obj_code;
				     EXCEPTION WHEN others THEN
				       null;
				       --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				      -- l_msg_data := 'Work item does not exist in the WR ';
				       --raise;

				   end ;

			   end if;


			   -- Get the Task Assignment Status Id
			   begin
			    select 'OPEN' INTO l_status
			    from jtf_task_statuses_vl b
			    where nvl(b.closed_flag, 'N') = 'N'
				  and nvl(b.completed_flag, 'N') = 'N'
				  and nvl(b.cancelled_flag, 'N') = 'N'
				  and nvl(b.rejected_flag, 'N') = 'N'
				  and b.task_status_id =  jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id;
			    exception when others then l_status := 'CLOSED';
			  end;


			  if (jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code = 'RS_TEAM')
			     or (l_status = 'CLOSED')
			  then
				     l_assignee_id := null;
				     l_assignee_type := null;
				     -- insert into p_temp(msg) values('selecting asg id from jtf tsk asg table');
				     begin
					     select c.resource_id, c.resource_type_code
					     into l_assignee_id, l_assignee_type
					     from jtf_task_assignments c
					     where c.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
					     and c.last_update_date = (select max(a.last_update_date)
								      from jtf_task_assignments a,jtf_task_statuses_vl b
								      where a.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
								      and a.assignee_role = 'ASSIGNEE'
								     and a.resource_type_code <> 'RS_TEAM'
								     and a.assignment_status_id = b.task_status_id
								     and (nvl(b.closed_flag, 'N') = 'N'
									  and nvl(b.completed_flag, 'N') = 'N'
									  and nvl(b.cancelled_flag, 'N') = 'N'
									  and nvl(b.rejected_flag, 'N') = 'N'
									  and b.task_status_id = c.assignment_status_iD))
					     and assignee_role = 'ASSIGNEE'
					     and c.resource_type_code <> 'RS_TEAM'
					     and c.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
					     and rownum < 2;
					     exception when others then
					     l_assignee_id := null;
					     l_assignee_type := null;
				     end;

			  else
					--insert into p_temp(msg) values('setting asg id to hooks data');

				    l_assignee_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id;
				    l_assignee_type := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code;
			  end if;

			  begin
			    select task_type_id, entity into l_task_type_id, l_entity
			    from jtf_tasks_b
			    where task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;
			    exception when others then l_task_type_id := null;
			  end;


			  if (l_dist_from = 'GROUP_OWNED') and
			     (l_dist_to = 'INDIVIDUAL_ASSIGNED')
			  then
			      if l_owner_type = 'RS_GROUP'
			      then
				      begin
					select count(0) into l_task_asg_count
					from jtf_task_assignments
					where task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
					and assignee_role = 'ASSIGNEE';
					exception when others then l_task_asg_count := 0;
				      end;

					--insert into p_temp(msg) values('asg type: '||l_assignee_type||' asg id: '||l_assignee_id|| ' own id: '||l_owner_id);

				      -- Check if the assignee is grp member

				      if l_assignee_type not in ('RS_TEAM', 'RS_GROUP') then
					begin
					   select 'Y' into l_group_id
					   from jtf_rs_group_members
					   where resource_id = l_assignee_id
					   and group_id = l_owner_id
					   and nvl(delete_flag,'N') <> 'Y'
					   and rownum < 2;
					   exception when others then l_group_id := 'N';
					 end;
				      end if;


				     if l_task_asg_count = 0
				     then
				        ----- create a new assignee -----------

					-- If the new assignee is not a member of the grp then set the assignee to null in UWQ WR
					if nvl(l_group_id, 'N') = 'N' then
					   l_assignee_id := null;
					   l_assignee_type := null;
					end if;
				     elsif l_task_asg_count >= 1
				     then

				        --------- Add another assignee----------

				        -- If the new assignee created is not a member of the group,
					-- then get the assignee from UWQ WR if the record exists
					-- else get the most recent grp member assignee from JTF_TASK_ASSIGNMENTS.

					if nvl(l_group_id, 'N') = 'N'
					then

					    if (l_wi_exists = 'Y')
					    then
						   begin
						      l_workitem_obj_code := 'TASK';
						      select assignee_id, assignee_type_actual
						      into l_assignee_id, l_assignee_type
						      from ieu_uwqm_items
						      where workitem_pk_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		--                                       and workitem_obj_code = 'TASK';
						       and workitem_obj_code = l_workitem_obj_code;
						      exception when others then
							l_assignee_id := null;
							l_assignee_type := null;
						    end;
					    else
						   begin
						        select c.resource_id, c.resource_type_code
							into l_assignee_id, l_assignee_type
							from jtf_task_assignments c
							where c.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
							and c.assignee_role = 'ASSIGNEE'
							and c.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
							and c.resource_id in ( select resource_id
									from jtf_rs_group_members
									where group_id = l_owner_id
									and nvl(delete_flag,'N') <> 'Y')
							--and c.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
							and c.last_update_date = (select max(a.last_update_date)
										    from jtf_task_assignments a,jtf_task_statuses_vl b
										    where a.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
										    and a.assignee_role = 'ASSIGNEE'
										    and a.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
										    and a.assignment_status_id = b.task_status_id
										    and a.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
										    and a.resource_id in  ( select resource_id
													    from jtf_rs_group_members
													    where group_id = l_owner_id
													    and nvl(delete_flag,'N') <> 'Y')
										    and (nvl(b.closed_flag, 'N') = 'N'
										    and nvl(b.completed_flag, 'N') = 'N'
										    and nvl(b.cancelled_flag, 'N') = 'N'
										    and nvl(b.rejected_flag, 'N') = 'N'
										    and b.task_status_id = c.assignment_status_id)
										    )

							and rownum < 2;
						    exception when others then
							--l_sql_err := SQLERRM;
							--l_sql_code := SQLCODE;
							-- insert into p_temp(msg) values ('excep: '||l_SQL_ERR|| l_SQL_CODE);
							l_assignee_id := null;
							l_assignee_type := null;
						    end;
					    end if; /* l_wi_exists */
					end if; /*l_group_id */
				     end if; /* l_task_asg_count */
			      else
				     l_assignee_id := null;
				     l_assignee_type := null;
			      end if;
			   end if;

			   -- Niraj, Bug 4220060
			   -- Set the flag to Y if the assignee_role = OWNER
                           IF ( (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER') OR
			        ( (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'ASSIGNEE') AND
			          (NVL(l_wr_assignee_id, -1) <> NVL(l_assignee_id, -1))) )
		           THEN
				l_update_wr_item_call := 'Y';
			   ELSE
			     	l_update_wr_item_call := 'N';
			   END IF;

			  -- insert into p_temp(msg) values ('update flag: '||l_update_wr_item_call);

			   -- Start 'l_update_wr_item_call' check
			   IF (l_update_wr_item_call = 'Y') Then		-- Niraj, 4220060
			     l_workitem_comment_code2 := 'GRP_MAX_ASSGN';

			     l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

			     l_audit_trail_rec.extend;

			     l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
											('WORKITEM_UPDATE',
											 'UPDATE_WR_ITEM',
											 690,
											 'IEU_TASKS_USERHOOKS.CREATE_TASK_ASSIGN_UWQM_PRE',
								     l_workitem_comment_code1,
								     l_workitem_comment_code2,
								     null,
								     null,
								     null);
			 /*    insert into p_temp(msg) values ('asg role: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role ||
                             ' entity: '||l_entity|| ' group id: '||l_group_id); */

                       --  insert into p_temp(msg) values ('passign due date as: '||l_ins_due_date);
			   if (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'ASSIGNEE')
			      and (l_entity = 'TASK')
				 --and (nvl(l_group_id, 'N') = 'Y')
			   then
			          if (l_wi_exists = 'N')
				  then
					   -- insert into p_temp(msg) values (' calling insert ');

					   IEU_WR_PUB.CREATE_WR_ITEM(
					   p_api_version => 1.0,
					   p_init_msg_list => FND_API.G_TRUE,
					   p_commit => FND_API.G_true,
					   p_workitem_obj_code => 'TASK',
					   p_workitem_pk_id => l_ins_task_id,
					   p_work_item_number => l_ins_task_number,
					   p_title => l_ins_task_name,
					   p_party_id => l_ins_customer_id,
					   p_priority_code => l_ins_priority_code,
					   p_due_date => l_ins_due_date,
					   p_owner_id => l_ins_owner_id,
					   p_owner_type => l_ins_owner_type_code,
					   p_assignee_id => l_assignee_id,
					   p_assignee_type => l_assignee_type,
					   p_source_object_id => l_ins_source_object_id,
					   p_source_object_type_code => l_ins_source_object_type_code,
					   p_application_id => 690,
					   p_ieu_enum_type_uuid => 'TASKS',
					   p_work_item_status => l_ins_task_status,
					   p_user_id  => FND_GLOBAL.USER_ID,
					   p_login_id => FND_GLOBAL.LOGIN_ID,
					   x_work_item_id => l_ins_WORK_ITEM_ID,
					   x_msg_count => l_msg_count,
					   x_msg_data => l_MSG_DATA,
					   x_return_status => l_RETURN_STATUS);

				   else

					    --insert into p_temp(msg) values (' calling update ');
					    IEU_WR_PUB.UPDATE_WR_ITEM(
					    p_api_version => 1.0,
					    p_init_msg_list => FND_API.G_TRUE,
					    p_commit => FND_API.G_FALSE,
					    p_workitem_obj_code => 'TASK',
					    p_workitem_pk_id => jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
					    p_title => FND_API.G_MISS_CHAR,
					    p_party_id => FND_API.G_MISS_NUM,
					    p_priority_code => FND_API.G_MISS_CHAR,
					    p_due_date => l_ins_due_date,
					    p_owner_id => FND_API.G_MISS_NUM,
					    p_owner_type => FND_API.G_MISS_CHAR,
					    p_assignee_id => l_assignee_id,
					    p_assignee_type => l_assignee_type,
					    p_source_object_id => FND_API.G_MISS_NUM,
					    p_source_object_type_code => FND_API.G_MISS_CHAR,
					    p_application_id => 690,
					    p_user_id  => FND_GLOBAL.USER_ID,
					    p_login_id => FND_GLOBAL.LOGIN_ID,
					    p_work_item_status => FND_API.G_MISS_CHAR,
					    p_audit_trail_rec => l_audit_trail_rec,
					    x_msg_count => L_MSG_COUNT,
					    x_msg_data => L_MSG_DATA,
					    x_return_status => L_RETURN_STATUS);

				  end if;
 			          x_return_status := l_return_status;


			   elsif (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER')
			   then
			          -- Create or Update Task User Hook should have been invoked
				  -- before invoking Create/Update Task Assignment if the assignee role is owner.
				  -- So update the rec only if its present in IEU_UWQM_ITEMS
			          if (l_wi_exists <> 'N')
				  then

					    --insert into p_temp(msg) values (' calling update ');
					    IEU_WR_PUB.UPDATE_WR_ITEM(
					    p_api_version => 1.0,
					    p_init_msg_list => FND_API.G_TRUE,
					    p_commit => FND_API.G_FALSE,
					    p_workitem_obj_code => 'TASK',
					    p_workitem_pk_id => jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
					    p_title => FND_API.G_MISS_CHAR,
					    p_party_id => FND_API.G_MISS_NUM,
					    p_priority_code => FND_API.G_MISS_CHAR,
					    p_due_date => l_ins_due_date,
					    p_owner_id => FND_API.G_MISS_NUM,
					    p_owner_type => FND_API.G_MISS_CHAR,
					    p_assignee_id => l_assignee_id,
					    p_assignee_type => l_assignee_type,
					    p_source_object_id => FND_API.G_MISS_NUM,
					    p_source_object_type_code => FND_API.G_MISS_CHAR,
					    p_application_id => 690,
					    p_user_id  => FND_GLOBAL.USER_ID,
					    p_login_id => FND_GLOBAL.LOGIN_ID,
					    p_work_item_status => FND_API.G_MISS_CHAR,
					    p_audit_trail_rec => l_audit_trail_rec,
					    x_msg_count => L_MSG_COUNT,
					    x_msg_data => L_MSG_DATA,
					    x_return_status => L_RETURN_STATUS);

				  end if;
 			          x_return_status := l_return_status;

			   elsif (l_entity <> 'TASK')
				 --or (nvl(l_group_id, 'N') = 'N')
			   then
					-- insert into p_temp(msg) values (' wr proc was not called..returning success ');
				    x_return_status := fnd_api.g_ret_sts_success;
			   end if;
			ELSE							-- Niraj, 4220060
				 x_return_status := fnd_api.g_ret_sts_success;  -- Niraj, 4220060
			END IF;							-- Niraj, 4220060
			-- End 'l_update_wr_item_call' check

		end if; /* Work Item exists in UWQ Work Repository */

          EXCEPTION WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          END;

     end if; /* Tasks Rules Func */
     elsif l_activation_status = 'N' then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;
 end create_task_assign_uwqm_pre;


  PROCEDURE update_task_assign_uwqm_pre ( x_return_status OUT NOCOPY VARCHAR2 ) As

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     l_return_status varchar2(5);
     l_owner_id      number;
     l_owner_type    varchar2(25);
     l_source_object_id  number;
     l_source_object_type_code   varchar2(30);
     l_count number := 0;
     l_importance_level number;
     l_assignee_id number;
     l_assignee_type varchar2(30);
     l_status varchar2(20);
     l_task_type_id  number;

     l_ws_id1            NUMBER;
     l_ws_id2            NUMBER := null;
     l_association_ws_id NUMBER;
     l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
     l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
     l_uwq_assignee_id   number;
     l_uwq_assignee_type varchar2(30);
     l_group_id          varchar2(5);
     l_other_asg_update_flag varchar2(5);
     l_old_assignee_id   number;
     l_old_assignee_type varchar2(30);
     l_entity        varchar2(30);

     l_tasks_rules_func VARCHAR2(500);
     l_orig_grp_owner  NUMBER;

     l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
     l_def_data_list  SYSTEM.DEF_WR_DATA_NST;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_workitem_comment_code2 varchar2(100) := null;
    l_update_wr_item_call varchar2(5);
    l_wi_exists VARCHAR2(10);
    l_tsk_sts_id NUMBER;
    l_task_status VARCHAR2(500);
    l_del_flag VARCHAR2(10);
    l_sql_err VARCHAR2(50);
    l_sql_code VARCHAR2(100);

    l_ins_task_id   number;
    l_ins_task_number varchar2(30);
    l_ins_customer_id number;
    l_ins_owner_id  number;
    l_ins_owner_type_code varchar2(30);
    l_ins_source_object_id number;
    l_ins_source_object_type_code varchar2(30);
    l_ins_task_name varchar2(80);
    l_ins_assignee_id  number;
    l_ins_assignee_type varchar2(25);
    l_ins_task_priority_id number;
    l_ins_date_selected   varchar2(1);
    l_ins_due_date      date;
    l_ins_planned_end_date  date;
    l_ins_actual_ins_end_date   date;
    l_ins_scheduled_end_date date;
    l_ins_planned_start_date  date;
    l_ins_actual_ins_start_date   date;
    l_ins_scheduled_start_date date;
    l_ins_importance_level number;
    l_ins_priority_code  varchar2(30);
    l_ins_task_status varchar2(10);
    l_ins_task_status_id  number;
    l_ins_task_type_id number;
    l_ins_work_item_id NUMBER;
    l_wr_assignee_id	ieu_uwqm_items.assignee_id%TYPE;  -- Niraj, Bug 4220060, Added

  begin
--  insert into p_temp(msg) values('proc update asg task');


     l_ins_priority_code := 'LOW';
     --l_update_wr_item_call := 'Y';  -- Niraj, Bug 4220060, Commented
     l_dist_from := 'GROUP_OWNED';
     l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  /*** Update Task Assignee
   **   First the Activation Status is checked
   **   If the Work Source is activated, then check if any Tasks Rules Function is registered
   **   If the task Rules function is present, then execute it
   **   If the Task Rules function is not registered then the assignee will be created based on the following rules for Standard Tasks
   **   1. Update assignee in UWQ if Owner is a Group and the assignee should be a member of the group
   **   2. If the Owner is not a group, then Assignee will not be created in UWQ
   **   3. If the Assignee is not a member of the Group, then UWQ Assignee will be the most recent Group member if it exists.
   **      If there are no group members present, then the assignee will be null
   ***/

       -- reset del task pkg lvl variable
	l_del_task_id := null;

       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

--     l_workitem_comment_code1 := 'GO_IA';

--     if  (l_task_source_obj_type_code is null)
--     then
         begin

             select source_object_type_code
             into   l_task_source_obj_type_code
             from   jtf_tasks_b
             where  task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;

         exception when others then
             l_task_source_obj_type_code := null;
         end;
--     end if;

     if (l_task_source_obj_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
               --where  object_code = 'TASK'
	       --and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = l_task_source_obj_type_code
	       --and    nvl(not_valid_flag,'N') = 'N';
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
		   AND    a.ws_id = b.ws_id
		 --AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;

              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

        end if;

     if l_activation_status = 'Y' then

	/* insert into p_temp(msg) values ('assignee_role: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role||
					 ' booking end date: '|| jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date); */


	 if (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER')
	 then
		 l_ins_due_date :=  jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date;
	 else
	      -- Get the Bookings End Date from JTF_TASK_ASSIGNMENTS where assignee_role= owner
		  BEGIN

		    SELECT booking_end_date
		    INTO   l_ins_due_date
		    FROM   JTF_TASK_ALL_ASSIGNMENTS
		    WHERE  task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		    AND    assignee_role = 'OWNER';

		  EXCEPTION
		    WHEN OTHERS THEN
		      null;
		  END;
	  end if;


        if (l_tasks_rules_func is not null)
        then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            l_tasks_data_list.extend;

	    l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'UPDATE_TASK_ASG',
		jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
                null,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                l_task_source_obj_type_code,
                FND_API.G_MISS_NUM,
                NULL,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id,
                jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id);

             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
--                and    workitem_obj_code = 'TASK'
--                and    owner_type_actual = 'RS_GROUP';
                and    workitem_obj_code = l_workitem_obj_code
                and    owner_type_actual = l_owner_type_actual;

             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                l_ins_due_date,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;
        else

           BEGIN


	--       if (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'ASSIGNEE')
        --       then


		   -- Get the Task Status Id
		   begin
		      select task_status_id, deleted_flag
		      into l_tsk_sts_id, l_del_flag
		      from jtf_tasks_b
		      where task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;
		   exception
		     when others then null;
		   end;

		   if (jtf_tasks_pub.p_task_user_hooks.task_status_id is not null)
		   then
		      l_tsk_sts_id := jtf_tasks_pub.p_task_user_hooks.task_status_id;
		   end if;

		   -- Get the Task Status based on task Status Id
		    begin
		      select 'CLOSE' into l_task_status
		      from jtf_task_statuses_vl
		      where (nvl(closed_flag, 'N') = 'Y'
		      or nvl(completed_flag, 'N') = 'Y'
		      or nvl(cancelled_flag, 'N') = 'Y'
		      or nvl(rejected_flag, 'N') = 'Y')
		      and task_status_id = l_tsk_sts_id;
		      EXCEPTION WHEN others THEN null;
		    end;

		   -- Check if the Work Item exists in UWQ Metaphor Table
		   begin
		      select 'Y'
		      into   l_wi_exists
		      from ieu_uwqm_items
		      where workitem_pk_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		      and workitem_obj_code = 'TASK';
		   exception
		     when others then
			l_wi_exists := 'N';
		   end;

		 --  insert into p_temp(msg) values ('Task Status Id from Tasks table: '||l_tsk_sts_id||' l_wi_exists: '||l_wi_exists||' l_del_flag: '||l_del_flag);

		   -- Closed Work Items are not currently migrated. No updates will be done to UWQ Metaphor table
		   -- if the Task is in closed/deleted status and the Work Item is not present in UWQ table.

		   if ( ( (l_task_status = 'CLOSE') or (l_del_flag = 'Y') )
			and (l_wi_exists = 'N'))
		   then
		        --   insert into p_temp(msg) values ('close/del and rec does not exists.. ret success');
			x_return_status := fnd_api.g_ret_sts_success;
		   else
				  -- If the work item status is not closed or deleted and if the work item does not exist in Work Repository
				  -- then create the work item
				   if (l_wi_exists = 'N')
				   then
					--insert into p_temp values (' selecting data from tasks table');

					  begin

						  select tb.task_id, tb.task_number, tb.customer_id, tb.owner_id, tb.owner_type_code,
							 tb.source_object_id, tb.source_object_type_code,
							 tb.planned_start_date, tb.planned_end_date, tb.actual_start_date, tb.actual_end_date,
							 tb.scheduled_start_date, tb.scheduled_end_date,tb.task_type_id,
							 tb.task_status_id, tt.task_name, tp.importance_level, ip.priority_code
						  into l_ins_task_id, l_ins_task_number, l_ins_customer_id, l_ins_owner_id, l_ins_owner_type_code,
						       l_ins_source_object_id, l_ins_source_object_type_code,
						       l_ins_planned_start_date,
						       l_ins_planned_end_date, l_ins_actual_ins_start_date, l_ins_actual_ins_end_date, l_ins_scheduled_start_date, l_ins_scheduled_end_date,
						       l_ins_task_type_id, l_ins_task_status_id, l_ins_task_name, l_ins_importance_level, l_ins_priority_code
						  from jtf_tasks_b tb, jtf_tasks_tl tt, jtf_task_priorities_vl tp, ieu_uwqm_priorities_b ip
						  where tb.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
						  and tb.entity = 'TASK'
						  and tb.task_id = tt.task_id
						  and tt.language = userenv('LANG')
						  and tp.task_priority_id = nvl(tb.task_priority_id, 4)
						  and least(tp.importance_level, 4) = ip.priority_level;
					  exception
					    when others then
					         null;
					         -- insert into p_temp values('raising err ');
						 -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
						  --raise;
					  end;

					  l_owner_id := l_ins_owner_id;
					  l_owner_type := l_ins_owner_type_code;

					  begin
					       select 'CLOSE' into l_ins_task_status
					       from jtf_task_statuses_vl
					       where (nvl(closed_flag, 'N') = 'Y'
					       or nvl(completed_flag, 'N') = 'Y'
					       or nvl(cancelled_flag, 'N') = 'Y'
					       or nvl(rejected_flag, 'N') = 'Y')
					       and task_status_id = l_ins_task_status_id;
					  EXCEPTION WHEN others THEN
						begin
						  select 'SLEEP' into l_ins_task_status
						  from jtf_task_statuses_vl
						  where nvl(on_hold_flag, 'N') = 'Y'
						  and task_status_id = l_ins_task_status_id;
						  EXCEPTION WHEN others THEN
						     l_ins_task_status := 'OPEN';
						end;
					  end;


					  /******
						insert into p_temp values('1'||l_ins_task_id||' '|| l_ins_task_number||' '|| l_ins_customer_id||' '|| l_ins_owner_id||' '|| l_ins_owner_type_code);
						insert into p_temp values('2'||l_ins_source_object_id||' '|| l_ins_source_object_type_code||' '|| l_ins_due_date||' '|| l_ins_planned_start_date);
						insert into p_temp values('3'||l_ins_planned_end_date||' '|| l_ins_actual_ins_start_date||' '|| l_ins_actual_ins_end_date||' '|| l_ins_scheduled_start_date||' '|| l_ins_scheduled_end_date);
						insert into p_temp values('4'||l_ins_task_type_id||' '|| l_ins_task_status_id||' '|| l_ins_task_name||' '|| l_ins_importance_level||' '|| l_ins_priority_code);
					  ******/


				    else
					   begin
					     l_workitem_obj_code := 'TASK';
					     select owner_id, owner_type, source_object_id, source_object_type_code, assignee_id -- Niraj, 4220060, Added assignee_id
					     into  l_owner_id, l_owner_type, l_source_object_id, l_source_object_type_code, l_wr_assignee_id  -- Niraj, 4220060, Added
					     from ieu_uwqm_items
					     where workitem_pk_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
		--                             and workitem_obj_code = 'TASK';
					     and workitem_obj_code = l_workitem_obj_code;
					     EXCEPTION WHEN others THEN null;
					   end ;

				   end if;

				   begin
				    select 'OPEN' INTO l_status
				    from jtf_task_statuses_vl b
				    where nvl(b.closed_flag, 'N') = 'N'
					  and nvl(b.completed_flag, 'N') = 'N'
					  and nvl(b.cancelled_flag, 'N') = 'N'
					  and nvl(b.rejected_flag, 'N') = 'N'
					  and b.task_status_id =  jtf_task_assignments_pub.p_task_assignments_user_hooks.assignment_status_id;
				    exception when others then l_status := 'CLOSED';
				  end;


				  if (jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code = 'RS_TEAM')
				     or (l_status = 'CLOSED')
				  then
					   l_assignee_id := null;
					   l_assignee_type := null;

					   begin
					     select c.resource_id, c.resource_type_code
					     into l_assignee_id, l_assignee_type
					     from jtf_task_assignments c
					     where c.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
					     and c.last_update_date = (select max(a.last_update_date)
								      from jtf_task_assignments a,jtf_task_statuses_vl b
								      where a.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
								      and a.assignee_role = 'ASSIGNEE'
								     and a.resource_type_code <> 'RS_TEAM'
								     and a.assignment_status_id = b.task_status_id
								     and (nvl(b.closed_flag, 'N') = 'N'
									  and nvl(b.completed_flag, 'N') = 'N'
									  and nvl(b.cancelled_flag, 'N') = 'N'
									  and nvl(b.rejected_flag, 'N') = 'N'
									  and b.task_status_id = c.assignment_status_iD))
					     and assignee_role = 'ASSIGNEE'
					     and c.resource_type_code <> 'RS_TEAM'
					     and c.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
					     and rownum < 2;
					     exception when others then
					     l_assignee_id := null;
					     l_assignee_type := null;
					   end;

				  else
					    l_assignee_id := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_id;
					    l_assignee_type := jtf_task_assignments_pub.p_task_assignments_user_hooks.resource_type_code;
				  end if;

				  begin
				    select task_type_id, entity into l_task_type_id, l_entity
				    from jtf_tasks_b
				    where task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id;
				    exception when others then l_task_type_id := null;
				  end;

				  if (l_dist_from = 'GROUP_OWNED') and
				     (l_dist_to = 'INDIVIDUAL_ASSIGNED')
				  then
				      if l_owner_type = 'RS_GROUP'
				      then

						if l_assignee_type not in ('RS_TEAM', 'RS_GROUP') then
							   begin
							   select 'Y' into l_group_id
							   from jtf_rs_group_members
							   where resource_id = l_assignee_id
							   and group_id = l_owner_id
							   and nvl(delete_flag,'N') <> 'Y'
							   and rownum < 2;
							   exception when others then l_group_id := 'N';
							  end;
						end if;
						-- insert into p_temp values(' grp member: '||l_group_id);

						if (nvl(l_group_id, 'N') ='N')
						then
						   begin
						        select c.resource_id, c.resource_type_code
							into l_assignee_id, l_assignee_type
							from jtf_task_assignments c
							where c.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
							and c.assignee_role = 'ASSIGNEE'
							and c.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
							and c.resource_id in ( select resource_id
									from jtf_rs_group_members
									where group_id = l_owner_id
									and nvl(delete_flag,'N') <> 'Y')
							--and c.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
							and c.last_update_date = (select max(a.last_update_date)
										    from jtf_task_assignments a,jtf_task_statuses_vl b
										    where a.task_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id
										    and a.assignee_role = 'ASSIGNEE'
										    and a.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
										    and a.assignment_status_id = b.task_status_id
										    and a.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
										    and a.resource_id in  ( select resource_id
													    from jtf_rs_group_members
													    where group_id = l_owner_id
													    and nvl(delete_flag,'N') <> 'Y')
										    and (nvl(b.closed_flag, 'N') = 'N'
										    and nvl(b.completed_flag, 'N') = 'N'
										    and nvl(b.cancelled_flag, 'N') = 'N'
										    and nvl(b.rejected_flag, 'N') = 'N'
										    and b.task_status_id = c.assignment_status_id)
										    )

							and rownum < 2;
						    exception when others then
							l_sql_err := SQLERRM;
							l_sql_code := SQLCODE;
							-- insert into p_temp values ('excep: '||l_SQL_ERR|| l_SQL_CODE);
							l_assignee_id := null;
							l_assignee_type := null;
						    end;

							/** insert into p_temp values('task id: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id||
								  ' task asg id: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id||
								  ' owner id: '||l_owner_id ||
								  ' asg id: '||l_assignee_id||' asg type: '|| l_assignee_type); **/

					        end if;  /* l_group_id */

					    else

					      l_assignee_id := null;
						 l_assignee_type := null;

				         end if; /* owner_type = RS_GROUP */

				  end if; /* if dist_From */

				  if l_assignee_id is not null then
				      l_workitem_comment_code2 := 'GRP_MAX_ASSGN';
				  end if;

			   -- Niraj, Bug 4220060
                           IF ( ( (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'ASSIGNEE') AND
			         (NVL(l_wr_assignee_id, -1) <> NVL(l_assignee_id, -1) )
			      ) OR
			     (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER') )
		           THEN
				l_update_wr_item_call := 'Y';
			   ELSE
			     	l_update_wr_item_call := 'N';
			   END IF;

			   -- Start 'l_update_wr_item_call' check
			   IF (l_update_wr_item_call = 'Y') Then		-- Niraj, 4220060
			     l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

			     l_audit_trail_rec.extend;

			     l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
											('WORKITEM_UPDATE',
											 'UPDATE_WR_ITEM',
											 690,
											 'IEU_TASKS_USERHOOKS.UPDATE_TASK_ASSIGN_UWQM_PRE',
								     l_workitem_comment_code1,
								     l_workitem_comment_code2,
								     null,
								     null,
								     null);

                        -- insert into p_temp(msg) values ('passign due date as: '||l_ins_due_date);

			  if (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'ASSIGNEE')
			    and (l_entity = 'TASK')
--			    and (nvl(l_other_asg_update_flag, 'N') = 'N')
	--                    and (nvl(l_update_wr_item_call, 'Y') = 'Y')
			  then

			          if (l_wi_exists = 'N')
				  then
					-- insert into p_temp values (' calling insert ');

					   IEU_WR_PUB.CREATE_WR_ITEM(
					   p_api_version => 1.0,
					   p_init_msg_list => FND_API.G_TRUE,
					   p_commit => FND_API.G_true,
					   p_workitem_obj_code => 'TASK',
					   p_workitem_pk_id => l_ins_task_id,
					   p_work_item_number => l_ins_task_number,
					   p_title => l_ins_task_name,
					   p_party_id => l_ins_customer_id,
					   p_priority_code => l_ins_priority_code,
					   p_due_date => l_ins_due_date,
					   p_owner_id => l_ins_owner_id,
					   p_owner_type => l_ins_owner_type_code,
					   p_assignee_id => l_assignee_id,
					   p_assignee_type => l_assignee_type,
					   p_source_object_id => l_ins_source_object_id,
					   p_source_object_type_code => l_ins_source_object_type_code,
					   p_application_id => 690,
					   p_ieu_enum_type_uuid => 'TASKS',
					   p_work_item_status => l_ins_task_status,
					   p_user_id  => FND_GLOBAL.USER_ID,
					   p_login_id => FND_GLOBAL.LOGIN_ID,
					   x_work_item_id => l_ins_WORK_ITEM_ID,
					   x_msg_count => l_msg_count,
					   x_msg_data => l_MSG_DATA,
					   x_return_status => l_RETURN_STATUS);

				   else

						-- insert into p_temp values(' calling update wr item' );
					    IEU_WR_PUB.UPDATE_WR_ITEM(
					    p_api_version => 1.0,
					    p_init_msg_list => FND_API.G_TRUE,
					    p_commit => FND_API.G_FALSE,
					    p_workitem_obj_code => 'TASK',
					    p_workitem_pk_id => jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
					    p_title => FND_API.G_MISS_CHAR,
					    p_party_id => FND_API.G_MISS_NUM,
					    p_priority_code => FND_API.G_MISS_CHAR,
					    p_due_date => l_ins_due_date,
					    p_owner_id => FND_API.G_MISS_NUM,
					    p_owner_type => FND_API.G_MISS_CHAR,
					    p_assignee_id => l_assignee_id,
					    p_assignee_type => l_assignee_type,
					    p_source_object_id => FND_API.G_MISS_NUM,
					    p_source_object_type_code => FND_API.G_MISS_CHAR,
					    p_application_id => 690,
					    p_user_id  => FND_GLOBAL.USER_ID,
					    p_login_id => FND_GLOBAL.LOGIN_ID,
					    p_work_item_status => FND_API.G_MISS_CHAR,
					    p_audit_trail_rec => l_audit_trail_rec,
					    x_msg_count => L_MSG_COUNT,
					    x_msg_data => L_MSG_DATA,
					    x_return_status => L_RETURN_STATUS);

				    end if;

				    x_return_status := l_return_status;
					-- insert into p_temp values(' called update wr items.. ret sts: '||x_return_status);
			    elsif (jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role = 'OWNER')
			    then
			          -- Create or Update Task User Hook should have been invoked
				  -- before invoking Create/Update Task Assignment if the assignee role is owner.
				  -- So update the rec only if its present in IEU_UWQM_ITEMS
			          if (l_wi_exists <> 'N')
				  then

					-- insert into p_temp(msg) values(' calling update wr item' );
					    IEU_WR_PUB.UPDATE_WR_ITEM(
					    p_api_version => 1.0,
					    p_init_msg_list => FND_API.G_TRUE,
					    p_commit => FND_API.G_FALSE,
					    p_workitem_obj_code => 'TASK',
					    p_workitem_pk_id => jtf_task_assignments_pub.p_task_assignments_user_hooks.task_id,
					    p_title => FND_API.G_MISS_CHAR,
					    p_party_id => FND_API.G_MISS_NUM,
					    p_priority_code => FND_API.G_MISS_CHAR,
					    p_due_date => l_ins_due_date,
					    p_owner_id => FND_API.G_MISS_NUM,
					    p_owner_type => FND_API.G_MISS_CHAR,
					    p_assignee_id => l_assignee_id,
					    p_assignee_type => l_assignee_type,
					    p_source_object_id => FND_API.G_MISS_NUM,
					    p_source_object_type_code => FND_API.G_MISS_CHAR,
					    p_application_id => 690,
					    p_user_id  => FND_GLOBAL.USER_ID,
					    p_login_id => FND_GLOBAL.LOGIN_ID,
					    p_work_item_status => FND_API.G_MISS_CHAR,
					    p_audit_trail_rec => l_audit_trail_rec,
					    x_msg_count => L_MSG_COUNT,
					    x_msg_data => L_MSG_DATA,
  					    x_return_status => L_RETURN_STATUS);

				        x_return_status := l_return_status;

			            else

					x_return_status := fnd_api.g_ret_sts_success;

				    end if;

			    elsif (l_entity <> 'TASK')
			    then
				    x_return_status := fnd_api.g_ret_sts_success;
			    end if;
			ELSE							-- Niraj, 4220060
				 x_return_status := fnd_api.g_ret_sts_success;  -- Niraj, 4220060
			END IF;							-- Niraj, 4220060
		         -- End 'l_update_wr_item_call' check

		      end if; /* Task Work Item exists in UWQ Metaphor */

               -- else  /* assignee_role <> assingee */
               --       x_return_status := fnd_api.g_ret_sts_success;
               -- end if;

           EXCEPTION WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           END;

        end if; /* Tasks Rules Func */
       elsif l_activation_status = 'N' then
         x_return_status := fnd_api.g_ret_sts_success;
      end if;

 end update_task_assign_uwqm_pre;

 PROCEDURE delete_task_assign_uwqm_pre (x_return_status  OUT NOCOPY  VARCHAR2 ) As

    l_msg_count number;
    l_msg_data VARCHAR2(2000);
    l_return_status varchar2(5);
    l_assignee_id number;
    l_assignee_type varchar2(30);
    l_owner_id      number;
    l_owner_type    varchar2(25);
    l_source_object_id  number;
    l_source_object_type_code varchar2(30);
    l_task_id        number;
    l_task_type_id   number;

    l_ws_id1            NUMBER;
    l_ws_id2            NUMBER := null;
    l_association_ws_id NUMBER;
    l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
    l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
    l_uwq_assignee_id number;
    l_uwq_assignee_type varchar2(30);
    l_other_asg_deleted_flag varchar2(5);
    l_entity        varchar2(30);
    l_orig_grp_owner  NUMBER;

    l_tasks_rules_func VARCHAR2(500);

    l_tasks_data_list SYSTEM.WR_TASKS_DATA_NST;
    l_def_data_list  SYSTEM.DEF_WR_DATA_NST;

    l_association_ws_code varchar2(32);
    l_activation_status varchar2(5);

    l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
    l_workitem_comment_code1 varchar2(100) := null;
    l_workitem_comment_code2 varchar2(100) := null;
    l_wi_exists VARCHAR2(10);
    l_tsk_sts_id NUMBER;
    l_task_status VARCHAR2(500);
    l_del_flag VARCHAR2(10);

    l_ins_task_id   number;
    l_ins_task_number varchar2(30);
    l_ins_customer_id number;
    l_ins_owner_id  number;
    l_ins_owner_type_code varchar2(30);
    l_ins_source_object_id number;
    l_ins_source_object_type_code varchar2(30);
    l_ins_task_name varchar2(80);
    l_ins_assignee_id  number;
    l_ins_assignee_type varchar2(25);
    l_ins_task_priority_id number;
    l_ins_date_selected   varchar2(1);
    l_ins_due_date      date;
    l_ins_planned_end_date  date;
    l_ins_actual_ins_end_date   date;
    l_ins_scheduled_end_date date;
    l_ins_planned_start_date  date;
    l_ins_actual_ins_start_date   date;
    l_ins_scheduled_start_date date;
    l_ins_importance_level number;
    l_ins_priority_code  varchar2(30);
    l_ins_task_status varchar2(10);
    l_ins_task_status_id  number;
    l_ins_task_type_id number;
    l_ins_work_item_id NUMBER;
    l_task_asg_count NUMBER;

 begin


       l_ins_priority_code := 'LOW';
       l_dist_from :=  'GROUP_OWNED';
       l_dist_to  := 'INDIVIDUAL_ASSIGNED';
       l_object_code := 'TASK';
       l_not_valid_flag := 'N';

--     l_workitem_comment_code1 := 'GO_IA';

       begin
         select task_id
         into l_task_id
         from jtf_task_all_assignments
         where task_assignment_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;
         exception when others then null;
      end;


--     if  (l_task_source_obj_type_code is null)
--     then
         begin

             select source_object_type_code
             into   l_task_source_obj_type_code
             from   jtf_tasks_b
             where  task_id = l_task_id;
         exception when others then
             l_task_source_obj_type_code := null;
         end;
--     end if;

     if (l_task_source_obj_type_code is not null)
     then

             BEGIN

                 Select ws_id
                 into   l_ws_id1
                 from   ieu_uwqm_work_sources_b
               --where  object_code = 'TASK'
               --and    nvl(not_valid_flag,'N') = 'N';
                 where  object_code = l_object_code
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                  WHEN OTHERS THEN l_ws_id1 := null;
             END;

             BEGIN

                 Select ws_id
                 into   l_ws_id2
                 from   ieu_uwqm_work_sources_b
                 where  object_code = l_task_source_obj_type_code
               --and    nvl(not_valid_flag,'N') = 'N';
                 and    nvl(not_valid_flag,'N') = l_not_valid_flag;
             EXCEPTION
                WHEN OTHERS THEN

                 l_ws_id2 := null;
             END;

             if (l_ws_id2 is not null)
             then

                -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
                BEGIN

                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_association_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
		   AND    a.ws_id = b.ws_id
		 --AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_association_ws_id := null;
                END;

              else
                    l_association_ws_id := null;

              end if;

              if l_association_ws_id is not null then
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => l_association_ws_code,
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              else
                      IEU_WR_PUB.CHECK_WS_ACTIVATION_STATUS(
                         p_api_version => 1,
                         p_init_msg_list => 'T',
                         p_commit  => 'F',
                         p_ws_code => 'TASK',
                         x_ws_activation_status => l_activation_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);
              end if;

              -- Get the Tasks Rules Function

              if (l_association_ws_id is not null)
              then

                 BEGIN

                   SELECT ws_b.tasks_rules_function
                   INTO   l_tasks_rules_func
                   FROM   ieu_uwqm_ws_assct_props ws_b
                   WHERE  ws_b.ws_id = l_association_ws_id;

                 EXCEPTION
                   WHEN OTHERS THEN
                     l_tasks_rules_func := null;
                 END;

              end if;

        end if;

     if l_activation_status = 'Y' then

	/* insert into p_temp(msg) values ('assignee_role: '||jtf_task_assignments_pub.p_task_assignments_user_hooks.assignee_role||
					 ' booking end date: '|| jtf_task_assignments_pub.p_task_assignments_user_hooks.booking_end_date); */


      -- Get the Bookings End Date from JTF_TASK_ASSIGNMENTS where assignee_role= owner
	  BEGIN

	    SELECT booking_end_date
	    INTO   l_ins_due_date
	    FROM   JTF_TASK_ALL_ASSIGNMENTS
	    WHERE  task_id = (select task_id from jtf_task_all_assignments
			      where  task_assignment_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id)
	    AND    assignee_role = 'OWNER';

	  EXCEPTION
	    WHEN OTHERS THEN
	      null;
	  END;

	--insert into p_temp(msg) values (' selected due date: '||l_ins_due_date);
        if (l_tasks_rules_func is not null)
        then

            l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            l_tasks_data_list.extend;

	    l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                'DELETE_TASK_ASG',
		    l_task_id,
                null,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_NUM,
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_NUM,
                l_task_source_obj_type_code,
                FND_API.G_MISS_NUM,
                NULL,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                FND_API.G_MISS_DATE,
                null,
                null,
                null);

             l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

             l_def_data_list.extend;

             -- Get the Group Owner

             BEGIN
                l_workitem_obj_code := 'TASK';
                l_owner_type_actual := 'RS_GROUP';
                Select owner_id
                into   l_orig_grp_owner
                from   ieu_uwqm_items
                where  WORKITEM_PK_ID = l_task_id
--                and    workitem_obj_code = 'TASK'
--                and    owner_type_actual = 'RS_GROUP';
                and    workitem_obj_code = l_workitem_obj_code
                and    owner_type_actual = l_owner_type_actual;

             EXCEPTION
                when others then
                   l_orig_grp_owner := null;
             END;

             l_def_data_list(l_def_data_list.last) :=  SYSTEM.DEF_WR_DATA_OBJ(
                FND_API.G_MISS_CHAR,
                FND_API.G_MISS_CHAR,
                l_ins_due_date,
                'TASKS',
                l_orig_grp_owner
              );

              execute immediate
                'BEGIN '||l_tasks_rules_func ||
                ' ( :1, :2, :3, :4 , :5); END ; '
              USING
                IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

                x_return_status := l_return_status;
        else

           BEGIN


		   -- Get the Task Status Id
		   begin
		      select task_status_id, deleted_flag
		      into l_tsk_sts_id, l_del_flag
		      from jtf_tasks_b
		      where task_id = l_task_id;
		   exception
		     when others then null;
		   end;

		   if (jtf_tasks_pub.p_task_user_hooks.task_status_id is not null)
		   then
		      l_tsk_sts_id := jtf_tasks_pub.p_task_user_hooks.task_status_id;
		    end if;

		   -- Get the Task Status based on task Status Id
		    begin
		      select 'CLOSE' into l_task_status
		      from jtf_task_statuses_vl
		      where (nvl(closed_flag, 'N') = 'Y'
		      or nvl(completed_flag, 'N') = 'Y'
		      or nvl(cancelled_flag, 'N') = 'Y'
		      or nvl(rejected_flag, 'N') = 'Y')
		      and task_status_id = l_tsk_sts_id;
		      EXCEPTION WHEN others THEN null;
		    end;

		   -- Check if the Work Item exists in UWQ Metaphor Table
		   begin
		      select 'Y'
		      into   l_wi_exists
		      from ieu_uwqm_items
		      where workitem_pk_id =l_task_id
		      and workitem_obj_code = 'TASK';
		   exception
		     when others then
			l_wi_exists := 'N';
		   end;

		  -- insert into p_temp(msg) values ('del tsk asg..Task Status Id from Tasks table: '||l_tsk_sts_id||' l_wi_exists: '||l_wi_exists||' l_del_flag: '||l_del_flag);

		   -- Closed Work Items are not currently migrated. No updates will be done to UWQ Metaphor table
		   -- if the Task is in closed/deleted status and the Work Item is not present in UWQ table.

                   if (l_wi_exists = 'N')
		   then

			   if ( (l_task_status = 'CLOSE') or (l_del_flag = 'Y') )
			   then
				--insert into p_temp(msg) values ('close/del and rec does not exists.. ret success');
				x_return_status := fnd_api.g_ret_sts_success;

			   elsif (nvl(l_del_task_id, '-9') = l_task_id)
			   then
			        -- This work item is being deleted

				begin
					select count(0) into l_task_asg_count
					from jtf_task_assignments
					where task_id = l_task_id
					and assignee_role = 'ASSIGNEE';
				exception
				      when others then l_task_asg_count := 0;
				end;
				--insert into p_temp values ('del based on l_del_task_id.. task asg cnt: '||l_task_asg_count);

				-- Set the del_task_id to null if this is the last assignee being deleted.
				if (l_task_asg_count = 1)
				then
				   l_del_task_id := null;
				end if;
				x_return_status := fnd_api.g_ret_sts_success;

		           else
			    -- Create Work repository Item

				--insert into p_temp values (' selecting data from tasks table');

				  begin

					  select tb.task_id, tb.task_number, tb.customer_id, tb.owner_id, tb.owner_type_code,
						 tb.source_object_id, tb.source_object_type_code,
						-- decode(tb.date_selected, 'P', tb.planned_end_date,
						-- 'A', tb.actual_end_date, 'S', tb.scheduled_end_date, null, tb.scheduled_end_date) due_date,
						 tb.planned_start_date, tb.planned_end_date, tb.actual_start_date, tb.actual_end_date,
						 tb.scheduled_start_date, tb.scheduled_end_date,tb.task_type_id,
						 tb.task_status_id, tt.task_name, tp.importance_level, ip.priority_code, tb.entity
					  into l_ins_task_id, l_ins_task_number, l_ins_customer_id, l_ins_owner_id, l_ins_owner_type_code,
					       l_ins_source_object_id, l_ins_source_object_type_code,
					       l_ins_planned_start_date, l_ins_planned_end_date, l_ins_actual_ins_start_date, l_ins_actual_ins_end_date, l_ins_scheduled_start_date, l_ins_scheduled_end_date,
					       l_ins_task_type_id, l_ins_task_status_id, l_ins_task_name, l_ins_importance_level, l_ins_priority_code, l_entity
					  from jtf_tasks_b tb, jtf_tasks_tl tt, jtf_task_priorities_vl tp, ieu_uwqm_priorities_b ip
					  where tb.task_id = l_task_id
					  and tb.entity = 'TASK'
					  and tb.task_id = tt.task_id
					  and tt.language = userenv('LANG')
					  and tp.task_priority_id = nvl(tb.task_priority_id, 4)
					  and least(tp.importance_level, 4) = ip.priority_level;
				  exception
				    when others then
				         null;
				         -- insert into p_temp values('raising err ');
					 -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					  --raise;
				  end;

				  l_owner_id := l_ins_owner_id;
				  l_owner_type := l_ins_owner_type_code;

				  begin
				       select 'CLOSE' into l_ins_task_status
				       from jtf_task_statuses_vl
				       where (nvl(closed_flag, 'N') = 'Y'
				       or nvl(completed_flag, 'N') = 'Y'
				       or nvl(cancelled_flag, 'N') = 'Y'
				       or nvl(rejected_flag, 'N') = 'Y')
				       and task_status_id = l_ins_task_status_id;
				  EXCEPTION WHEN others THEN
					begin
					  select 'SLEEP' into l_ins_task_status
					  from jtf_task_statuses_vl
					  where nvl(on_hold_flag, 'N') = 'Y'
					  and task_status_id = l_ins_task_status_id;
					  EXCEPTION WHEN others THEN
					     l_ins_task_status := 'OPEN';
					end;
				  end;

				  /**********
					insert into p_temp values('1'||l_ins_task_id||' '|| l_ins_task_number||' '|| l_ins_customer_id||' '|| l_ins_owner_id||' '|| l_ins_owner_type_code);
					insert into p_temp values('2'||l_ins_source_object_id||' '|| l_ins_source_object_type_code||' '|| l_ins_due_date||' '|| l_ins_planned_start_date);
					insert into p_temp values('3'||l_ins_planned_end_date||' '|| l_ins_actual_ins_start_date||' '|| l_ins_actual_ins_end_date||' '|| l_ins_scheduled_start_date||' '|| l_ins_scheduled_end_date);
					insert into p_temp values('4'||l_ins_task_type_id||' '|| l_ins_task_status_id||' '|| l_ins_task_name||' '|| l_ins_importance_level||' '|| l_ins_priority_code);
				  ***********/

				   -- Get the most recent grp member assignee

				   begin
					select c.resource_id, c.resource_type_code
					into l_assignee_id, l_assignee_type
					from jtf_task_assignments c
					where c.task_id = l_task_id
					and c.assignee_role = 'ASSIGNEE'
					and c.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
					and c.resource_id in ( select resource_id
							from jtf_rs_group_members
							where group_id = l_owner_id
							and nvl(delete_flag,'N') <> 'Y')
					--and c.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
					and c.last_update_date = (select max(a.last_update_date)
								    from jtf_task_assignments a,jtf_task_statuses_vl b
								    where a.task_id = l_task_id
								    and a.assignee_role = 'ASSIGNEE'
								    and a.task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id
								    and a.assignment_status_id = b.task_status_id
								    and a.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
								    and a.resource_id in  ( select resource_id
											    from jtf_rs_group_members
											    where group_id = l_owner_id
											    and nvl(delete_flag,'N') <> 'Y')
								    and (nvl(b.closed_flag, 'N') = 'N'
								    and nvl(b.completed_flag, 'N') = 'N'
								    and nvl(b.cancelled_flag, 'N') = 'N'
								    and nvl(b.rejected_flag, 'N') = 'N'
								    and b.task_status_id = c.assignment_status_id)
								    )

					and rownum < 2;
				    exception when others then
					--l_sql_err := SQLERRM;
					--l_sql_code := SQLCODE;
					-- insert into p_temp values ('excep: '||l_SQL_ERR|| l_SQL_CODE);
					l_assignee_id := null;
					l_assignee_type := null;
				    end;

				     l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

				     l_audit_trail_rec.extend;

				     l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
												('WORKITEM_UPDATE',
												 'UPDATE_WR_ITEM',
												 690,
												 'IEU_TASKS_USERHOOKS.DELETE_TASK_ASSIGN_UWQM_PRE',
									     l_workitem_comment_code1,
									     l_workitem_comment_code2,
									     null,
									     null,
									     null);

                        -- insert into p_temp(msg) values ('passign due date as: '||l_ins_due_date);

				  --insert into p_temp values ('entity: '||l_entity);
				 if (l_entity = 'TASK')
				 then
				    --insert into p_temp values ('create wr item');
					   IEU_WR_PUB.CREATE_WR_ITEM(
					   p_api_version => 1.0,
					   p_init_msg_list => FND_API.G_TRUE,
					   p_commit => FND_API.G_true,
					   p_workitem_obj_code => 'TASK',
					   p_workitem_pk_id => l_ins_task_id,
					   p_work_item_number => l_ins_task_number,
					   p_title => l_ins_task_name,
					   p_party_id => l_ins_customer_id,
					   p_priority_code => l_ins_priority_code,
					   p_due_date => l_ins_due_date,
					   p_owner_id => l_ins_owner_id,
					   p_owner_type => l_ins_owner_type_code,
					   p_assignee_id => l_assignee_id,
					   p_assignee_type => l_assignee_type,
					   p_source_object_id => l_ins_source_object_id,
					   p_source_object_type_code => l_ins_source_object_type_code,
					   p_application_id => 690,
					   p_ieu_enum_type_uuid => 'TASKS',
					   p_work_item_status => l_ins_task_status,
					   p_user_id  => FND_GLOBAL.USER_ID,
					   p_login_id => FND_GLOBAL.LOGIN_ID,
					   p_audit_trail_rec => l_audit_trail_rec,
					   x_work_item_id => l_ins_WORK_ITEM_ID,
					   x_msg_count => l_msg_count,
					   x_msg_data => l_MSG_DATA,
					   x_return_status => l_RETURN_STATUS);

					   x_return_status := l_return_status;
				else
					   x_return_status := l_return_status;
				end if;

			   end if; /* create wr item */

		   else


			   begin
			     select resource_id, resource_type_code
			     into l_assignee_id, l_assignee_type
			     from jtf_task_assignments c
			     where c.task_id = l_task_id
			     and task_assignment_id = jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id;
			     EXCEPTION WHEN others THEN
			     l_assignee_id := null;
			     l_assignee_type := null;
			   end ;

			   begin
			     select task_type_id, entity into l_task_type_id, l_entity
			     from jtf_tasks_b
			     where task_id = l_task_id;
			     exception when others then l_task_type_id := null;
			   end;


			   begin
			     l_workitem_obj_code := 'TASK';
			     select owner_id, owner_type, source_object_id, source_object_type_code
			     into  l_owner_id, l_owner_type, l_source_object_id, l_source_object_type_code
			     from ieu_uwqm_items
			     where workitem_pk_id = l_task_id
	--                     and workitem_obj_code = 'TASK';
			     and workitem_obj_code = l_workitem_obj_code;
			     EXCEPTION WHEN others THEN null;
			   end ;

			   if (l_dist_from = 'GROUP_OWNED') and
			      (l_dist_to = 'INDIVIDUAL_ASSIGNED')
			   then
				if l_owner_type = 'RS_GROUP' then
					    begin
					      l_workitem_obj_code := 'TASK';
					      select assignee_id, assignee_type_actual
					      into l_uwq_assignee_id, l_uwq_assignee_type
					      from ieu_uwqm_items
					      where workitem_pk_id = l_task_id
	--                                      and workitem_obj_code = 'TASK';
					      and workitem_obj_code = l_workitem_obj_code;
					      exception when others then
						l_assignee_id := null;
						l_assignee_type := null;
					    end;
					    if ((nvl(l_uwq_assignee_id, '-1') = l_assignee_id) and (nvl(l_uwq_assignee_type,'X') = l_assignee_type))
					    then
						l_other_asg_deleted_flag := 'N';
						begin
						   select c.resource_id, c.resource_type_code
						 into l_assignee_id, l_assignee_type
						from jtf_task_assignments c
						where c.task_id = l_task_id
						and c.assignee_role = 'ASSIGNEE'
						and c.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
						and c.resource_id in ( select resource_id
								from jtf_rs_group_members
								where group_id = l_owner_id
								and nvl(delete_flag,'N') <> 'Y')
						and c.last_update_date = (select max(a.last_update_date)
									    from jtf_task_assignments a,jtf_task_statuses_vl b
									    where a.task_id = l_task_id
									    and a.assignee_role = 'ASSIGNEE'
									    and a.assignment_status_id = b.task_status_id
									    and a.resource_type_code not in ('RS_TEAM', 'RS_GROUP')
									    and a.resource_id in  ( select resource_id
												    from jtf_rs_group_members
												    where group_id = l_owner_id
												    and nvl(delete_flag,'N') <> 'Y')
									    and (nvl(b.closed_flag, 'N') = 'N'
									    and nvl(b.completed_flag, 'N') = 'N'
									    and nvl(b.cancelled_flag, 'N') = 'N'
									    and nvl(b.rejected_flag, 'N') = 'N'
									    and b.task_status_id = c.assignment_status_id)
									    and task_assignment_id <> jtf_task_assignments_pub.p_task_assignments_user_hooks.task_assignment_id)
						and rownum < 2;
						   exception when others then
							  l_assignee_id := null;
							  l_assignee_type := null;
						end;
					    else
						l_other_asg_deleted_flag := 'Y';
					    end if;

				else
				     l_assignee_id := null;
				     l_assignee_type := null;
				end if;
			   end if;

			    if l_assignee_id is not null then
				  l_workitem_comment_code2 := 'GRP_MAX_ASSGN';
			    end if;

			     l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();

			     l_audit_trail_rec.extend;

			     l_audit_trail_rec(l_audit_trail_rec.LAST):= SYSTEM.WR_AUDIT_TRAIL_OBJ
											('WORKITEM_UPDATE',
											 'UPDATE_WR_ITEM',
											 690,
											 'IEU_TASKS_USERHOOKS.DELETE_TASK_ASSIGN_UWQM_PRE',
								     l_workitem_comment_code1,
								     l_workitem_comment_code2,
								     null,
								     null,
								     null);

                       --  insert into p_temp(msg) values ('passign due date as: '||l_ins_due_date|| ' other asg delete flag: '||l_other_asg_deleted_flag);

			   if (l_entity = 'TASK') and (nvl(l_other_asg_deleted_flag, 'N') = 'N')then
			      IEU_WR_PUB.UPDATE_WR_ITEM(
			      p_api_version => 1.0,
			      p_init_msg_list => FND_API.G_TRUE,
			      p_commit => FND_API.G_FALSE,
			      p_workitem_obj_code => 'TASK',
			      p_workitem_pk_id => l_task_id,
			      p_title => FND_API.G_MISS_CHAR,
			      p_party_id => FND_API.G_MISS_NUM,
			      p_priority_code => FND_API.G_MISS_CHAR,
			      p_due_date => l_ins_due_date,
			      p_owner_id => FND_API.G_MISS_NUM,
			      p_owner_type => FND_API.G_MISS_CHAR,
			      p_assignee_id => l_assignee_id,
			      p_assignee_type => l_assignee_type,
			      p_source_object_id => FND_API.G_MISS_NUM,
			      p_source_object_type_code => FND_API.G_MISS_CHAR,
			      p_application_id => 690,
			      p_user_id  => FND_GLOBAL.USER_ID,
			      p_login_id => FND_GLOBAL.LOGIN_ID,
			      p_work_item_status => FND_API.G_MISS_CHAR,
			      p_audit_trail_rec => l_audit_trail_rec,
			      x_msg_data => L_MSG_DATA,
			      x_msg_count => l_msg_count,
			      x_return_status => L_RETURN_STATUS);

			      x_return_status := l_return_status;
			   elsif (l_entity <> 'TASK') or
				  (nvl(l_other_asg_deleted_flag, 'N') = 'Y') then
			      x_return_status := fnd_api.g_ret_sts_success;
			   end if;

		   end if; /* l_wi_exists */


           EXCEPTION WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           END;

         end if; /* Task Rules Func */
       elsif l_activation_status = 'N' then
         x_return_status := fnd_api.g_ret_sts_success;
      end if;
 end delete_task_assign_uwqm_pre;

END IEU_TASKS_USERHOOKS;

/
