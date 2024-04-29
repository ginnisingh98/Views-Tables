--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_DISTRIBUTE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_DISTRIBUTE_ITEMS" AS
/* $Header: IEUTKDFB.pls 115.14 2004/03/19 20:48:44 fsuthar noship $ */


  PROCEDURE DISTRIBUTE_TASKS
  (P_RESOURCE_ID		IN NUMBER,
   P_LANGUAGE            	IN VARCHAR2,
   P_SOURCE_LANG      	IN VARCHAR2,
   P_NUM_OF_ITEMS     	IN NUMBER,
   P_DIST_BUS_RULES  	IN SYSTEM.DIST_BUS_RULES_NST,
   P_WS_INPUT_DATA   	IN OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
   X_MSG_COUNT		OUT NOCOPY NUMBER,
   X_MSG_DATA		OUT NOCOPY VARCHAR2,
   X_RETURN_STATUS	            OUT NOCOPY VARCHAR2) IS

     l_distributed_from varchar2(100);
     l_distributed_to varchar2(100);
     l_dist_st_based_on_parent_flag varchar2(1);

     l_grp_owner number;
     l_group_id   varchar2(1);
     l_task_distributed_to  number;

     l_source_object_id number;
     l_source_object_code varchar2(30);
     l_distribution_status number;

     l_msg_count number;
     l_msg_data varchar2(2000);
     l_return_status varchar2(1);
     l_task_assignment_id  number;
     l_assignment_id       number;
     l_object_version_number number;

  BEGIN

    if p_dist_bus_rules.count <= 0 then
       x_return_status := 'E';
    end if;
    if p_ws_input_data.count <= 0 then
       x_return_status := 'E';
    end if;

     -- Loop thru the Business rules per Work Source

    For i  in P_DIST_BUS_RULES.first.. P_DIST_BUS_RULES.last
    Loop

      --insert into temp_f values('in the first loop');commit;

      l_distributed_from :=  P_DIST_BUS_RULES(i).DISTRIBUTE_FROM;
      l_distributed_to :=  P_DIST_BUS_RULES(i).DISTRIBUTE_TO;
      l_dist_st_based_on_parent_flag := P_DIST_BUS_RULES(i).DIST_ST_BASED_ON_PARENT_FLAG;

      -- For each Work Source, Get the Details of the Work Item to be distributed and the
      --   Distribution Rules. Try to Distribute the Work Item.

/* commented work_source = 'TASK' check so, this same distribution function can be used for TASK and SR-TASK work source */

--      if (P_DIST_BUS_RULES(i).work_source = 'TASK') then

          -- Loop thru Work Item Details
          For j in p_WS_INPUT_DATA .first.. p_WS_INPUT_DATA.last
          loop

--           	if (p_WS_INPUT_DATA(j).Work_source = 'TASK') then
        	  if (l_distributed_from = 'GROUP_OWNED')
              then
	     	     l_grp_owner := p_WS_INPUT_DATA(j).OWNER_ID;
	 	  else
		     l_grp_owner := p_WS_INPUT_DATA(j).ASSIGNEE_ID;
              end if;

           l_task_distributed_to := p_resource_id;

              begin
                select 'X' into l_group_id
                from jtf_rs_group_members
                where resource_id = p_resource_id
                and group_id = l_grp_owner
                and nvl(delete_flag, 'N') = 'N'
                and rownum < 2;
                exception when no_data_found then x_return_status := 'E';
             end;

              if l_group_id = 'X' then
                 if l_dist_st_based_on_parent_flag = 'Y' then


                    -- Code changes required. This will be required only for 'Association' work source like SR-TASK
                    -- The object code should be selected from ieu_uwqm_work_sources_b for parent work source

--                    if p_ws_input_data(j).source_object_type_code = 'SR'  then
                       l_source_object_code := p_ws_input_data(j).source_object_type_code;
                       l_source_object_id := p_ws_input_data(j).source_object_id;

                       begin
                         select distribution_status_id into l_distribution_status
                         from ieu_uwqm_items
                         where workitem_pk_id = l_source_object_id
                         and workitem_obj_code = l_source_object_code;
                         exception when no_data_found then l_distribution_status := 0;
                       end;
--                    end if;
                 end if;
                 if (l_distribution_status = 3 and l_dist_st_based_on_parent_flag = 'Y')
                    or (l_dist_st_based_on_parent_flag is null) then

                       If (l_distributed_to = 'INDIVIDUAL_ASSIGNED')
                       then
		            -- Distribute SR
                           /* in the following query we are doing rownum < 2 because we are ignoring assignment_status_id */
                           begin
                             select task_assignment_id, object_version_number
                             into l_assignment_id, l_object_version_number
                             from jtf_task_assignments
                             where resource_id = p_resource_id
                             and resource_type_code not in ('RS_TEAM', 'RS_GROUP')
                             and task_id = p_ws_input_data(j).workitem_pk_id
                             and rownum < 2;
                             exception when others then
                             l_assignment_id := null;
                           end;

                           if l_assignment_id is not null then

                              jtf_task_assignments_pub.update_task_assignment(
                               p_api_version                => 1.0,
                               p_object_version_number      => l_object_version_number,
                               p_init_msg_list              => fnd_api.g_false,
                               p_commit                     => fnd_api.g_true,
                               p_task_assignment_id         => l_assignment_id,
                               p_task_id                    => p_ws_input_data(j).workitem_pk_id,
                               p_resource_type_code         => 'RS_INDIVIDUAL',--l_resource_type_code,
                               p_resource_id                => l_task_distributed_to, --l_resource_id,
                               p_actual_effort              => null,
                               p_actual_effort_uom          => null,
                               p_schedule_flag              => null,
                               p_alarm_type_code            => null,
                               p_alarm_contact              => null,
                               p_sched_travel_distance      => null,
                               p_sched_travel_duration      => null,
                               p_sched_travel_duration_uom  => null,
                               p_actual_travel_distance     => null,
                               p_actual_travel_duration     => null,
                               p_actual_travel_duration_uom => null,
                               p_actual_start_date          => null,
                               p_actual_end_date            => null,
                               p_palm_flag                  => null,
                               p_wince_flag                 => null,
                               p_laptop_flag                => null,
                               p_device1_flag               => null,
                               p_device2_flag               => null,
                               p_device3_flag               => null,
                               p_resource_territory_id      => null,
                               p_shift_construct_id         => null,
                               x_return_status              => l_return_status,
                               x_msg_count                  => l_msg_count,
                               x_msg_data                   => l_msg_data
                               );
/*
                          IEU_WR_PUB.UPDATE_WR_ITEM(
                            p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_TRUE,
                            p_commit => FND_API.G_true,
                            p_workitem_obj_code => p_ws_input_data(j).workitem_obj_code,
                            p_workitem_pk_id => p_ws_input_data(j).workitem_pk_id,
                            p_title => p_ws_input_data(j).title,
                            p_party_id => p_ws_input_data(j).party_id,
                            p_priority_code => p_ws_input_data(j).priority_code,
                            p_due_date => p_ws_input_data(j).due_date,
                            p_owner_id => p_ws_input_data(j).owner_id,
                            p_owner_type => p_ws_input_data(j).owner_type,
                            p_assignee_id => l_task_distributed_to,
                            p_assignee_type => 'RS_INDIVIDUAL',
                            p_source_object_id => p_ws_input_data(j).source_object_id,
                            p_source_object_type_code => p_ws_input_data(j).source_object_type_code,
                            p_application_id => p_ws_input_data(j).application_id,
                            p_work_item_status => p_ws_input_data(j).work_item_status,
                            p_user_id  => FND_GLOBAL.USER_ID,
                            p_login_id => FND_GLOBAL.LOGIN_ID,
                            x_msg_count => l_msg_count,
                            x_msg_data => L_MSG_DATA,
                            x_return_status => L_RETURN_STATUS);
*/
                               x_return_status := l_return_status;
						 x_msg_count := l_msg_count;
						 x_msg_data := l_msg_data;

                           else
                               jtf_task_assignments_pub.create_task_assignment (
                               p_api_version                => 1.0,
                               p_init_msg_list              => fnd_api.g_false,
                               p_commit                     => fnd_api.g_true,
                               p_task_id                    => p_ws_input_data(j).workitem_pk_id,
                               p_resource_type_code         => 'RS_INDIVIDUAL',--l_resource_type_code,
                               p_resource_id                => l_task_distributed_to, --l_resource_id,
                               p_actual_effort              => null,
                               p_actual_effort_uom          => null,
                               p_schedule_flag              => null,
                               p_alarm_type_code            => null,
                               p_alarm_contact              => null,
                               p_sched_travel_distance      => null,
                               p_sched_travel_duration      => null,
                               p_sched_travel_duration_uom  => null,
                               p_actual_travel_distance     => null,
                               p_actual_travel_duration     => null,
                               p_actual_travel_duration_uom => null,
                               p_actual_start_date          => null,
                               p_actual_end_date            => null,
                               p_palm_flag                  => null,
                               p_wince_flag                 => null,
                               p_laptop_flag                => null,
                               p_device1_flag               => null,
                               p_device2_flag               => null,
                               p_device3_flag               => null,
                               p_resource_territory_id      => null,
                               p_assignment_status_id       => 14,
                               p_shift_construct_id         => null,
                               x_return_status              => l_return_status,
                               x_msg_count                  => l_msg_count,
                               x_msg_data                   => l_msg_data,
                               x_task_assignment_id         => l_task_assignment_id
                               );
                               x_return_status := l_return_status;
                               x_msg_count := l_msg_count;
						 x_msg_data := l_msg_data;
                            end if;
        /* commented out because SR is not going to use Tasks Distribution Function
     		 	        -- Update SR Item based on Business rules. This should
                          -- internally call Update UWQ Repository Item based on
                          -- Distribution rules. In this case, the Update should be done to
                          -- UWQ Assignee_id and Assignee_type

                      elsIf (l_distributed_to = 'INDIVIDUAL_OWNED')
                      Then
            		  -- Distribute SR

                             IEU_WR_PUB.UPDATE_WR_ITEM(
                              p_api_version => 1.0,
                              p_init_msg_list => FND_API.G_TRUE,
                              p_commit => FND_API.G_true,
                              p_workitem_obj_code => p_ws_input_data(j).workitem_obj_code,
                              p_workitem_pk_id => p_ws_input_data(j).workitem_pk_id,
                              p_title => p_ws_input_data(j).title,
                              p_party_id => p_ws_input_data(j).party_id,
                              p_priority_code => p_ws_input_data(j).priority_code,
                              p_due_date => p_ws_input_data(j).due_date,
                              p_owner_id => l_task_distributed_to,
                              p_owner_type => 'RS_INDIVIDUAL',
                              p_assignee_id => p_ws_input_data(j).assignee_id,
                              p_assignee_type => p_ws_input_data(j).assignee_type,
                              p_source_object_id => p_ws_input_data(j).source_object_id,
                              p_source_object_type_code => p_ws_input_data(j).source_object_type_code,
                              p_application_id => p_ws_input_data(j).application_id,
                              p_user_id  => FND_GLOBAL.USER_ID,
                              p_login_id => FND_GLOBAL.LOGIN_ID,
                              x_msg_count => l_msg_count,
                              x_msg_data => L_MSG_DATA,
                              x_return_status => L_RETURN_STATUS);

                             x_return_status := l_return_status;
					    x_msg_count := l_msg_count;
					    x_msg_data := l_msg_data;
                       *********************/
                         end if;
                     end if;
                 end if;
--             end if;
               If x_return_status = 'S'
               then
                 P_WS_INPUT_DATA(j).DISTRIBUTED := 'TRUE';
                 P_WS_INPUT_DATA(j).ASSIGNEE_ID := p_resource_id;
                 P_WS_INPUT_DATA(j).ASSIGNEE_TYPE := 'RS_INDIVIDUAL';
                 P_WS_INPUT_DATA(j).ITEM_INCLUDED_BY_APP := 'FALSE';
               Else
                 P_WS_INPUT_DATA(j).DISTRIBUTED := 'FALSE';
               End if;
          End loop;
--       End if;
    End loop;


 END DISTRIBUTE_TASKS;

END IEU_UWQ_DISTRIBUTE_ITEMS;


/
