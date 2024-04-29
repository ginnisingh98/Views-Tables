--------------------------------------------------------
--  DDL for Package Body PA_TASK_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_MANAGER" as
/* $Header: PATMUPGB.pls 120.1 2005/08/08 04:25:58 avaithia noship $ */


/* Function to get the profile option value  */

 function get_profile_value (p_name IN VARCHAR2) return VARCHAR2 IS

    l_value   FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;

 begin

   /**    If the profile option cannot be found, the out buffer is set to NULL
    **    Since a profile value can never be set to NULL,
    **    if this returns a NULL you know the profile doesn't exist.  **/

    fnd_profile.get(p_name, l_value);
    return nvl(l_value, 'N');

 end get_profile_value;


/* Procedure to check the break periods if the task manager is existing as a project member */

procedure validate_member_exists ( p_project_id              IN  NUMBER,
                                   p_task_manager_person_id  IN  NUMBER,
				   p_proj_role_id            IN  NUMBER,
				   p_start_date_active       IN  DATE,
				   p_end_date_active         IN  DATE,
				   p_project_end_date        IN  DATE) IS

  CURSOR c_member_end_date (p_project_id              IN NUMBER,
                            p_task_manager_person_id  IN NUMBER) IS
   select 1
     from pa_project_parties pp
    where pp.project_id = p_project_id
      and resource_source_id = p_task_manager_person_id
      and project_role_id = p_proj_role_id
      and pp.end_date_active is NULL;

  CURSOR c_proj_member_exists (p_project_id              IN NUMBER,
                               p_task_manager_person_id  IN NUMBER) IS
   select start_date_active, end_date_active
     from pa_project_parties
    where project_id = p_project_id
      and resource_source_id = p_task_manager_person_id
      and project_role_id = p_proj_role_id
     order by start_date_active;   /* Important to process in order. Please do not remove. */



l_member_end_date_active       DATE;
l_dummy1                       NUMBER;

l_start_date_active            DATE;
l_end_date_active              DATE;
l_project_end_date             DATE;
l_create_project_member        VARCHAR2(1);
l_min_member_start_date        DATE;
l_end_date_active_tmp          DATE;
v_null_char                    VARCHAR2(1);
x_return_status                VARCHAR2(255);
x_msg_count                    NUMBER;
x_msg_data                     VARCHAR2(2000);
x_project_party_id             NUMBER;
x_resource_id                  NUMBER;
l_wf_item_type                 VARCHAR2(30);
l_wf_type                      VARCHAR2(30);
l_wf_party_process             VARCHAR2(30);
l_assignment_id                NUMBER;
l_msg_index_out                NUMBER;

l_debug_mode             VARCHAR2(1);
l_tmp_str                fnd_new_messages.message_text%TYPE;

begin

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');
  l_tmp_str := fnd_message.get_string('PA', 'PA_TM_CR_PROJ_MEMBER');

l_start_date_active   := p_start_date_active;
l_end_date_active     := p_end_date_active;
l_project_end_date    := p_project_end_date;

       	      select max(end_date_active)
                into l_member_end_date_active
                from pa_project_parties
               where project_id = p_project_id
	         and resource_source_id = p_task_manager_person_id
		 and project_role_id = p_proj_role_id;

	      open c_member_end_date(p_project_id, p_task_manager_person_id);
	      fetch c_member_end_date into l_dummy1;
	      if c_member_end_date%FOUND then
	         l_member_end_date_active := NULL;
		 close c_member_end_date;
              else
	         close c_member_end_date;
	      end if;

              if (l_member_end_date_active is NULL) then  /* l_end_date_active is NULL or NOT NULL both conditions are included  */

		  l_create_project_member := 'Y';
                  for l_proj_member_exists_rec in c_proj_member_exists (p_project_id, p_task_manager_person_id) LOOP
                     if l_proj_member_exists_rec.end_date_active is NULL then
		           if (l_start_date_active >= l_proj_member_exists_rec.start_date_active) then
                               l_create_project_member := 'N';

		                 if l_debug_mode = 'Y' then
			           tm_log('6 The person is existing as a project member and the period is overlapping');
			         end if;

			       EXIT;
                           elsif l_end_date_active is null then
                               l_end_date_active := l_proj_member_exists_rec.start_date_active - 1;
			   end if;
		     end if;
                  END LOOP;

                  if l_create_project_member = 'Y' then

                  select min(start_date_active)
                    into l_min_member_start_date
		    from pa_project_parties
                   where project_id = p_project_id
                     and resource_source_id = p_task_manager_person_id
		     and project_role_id = p_proj_role_id;

		  if (l_start_date_active < l_min_member_start_date) then

	               l_end_date_active_tmp := l_min_member_start_date - 1;

	                 if l_debug_mode = 'Y' then
		           tm_log('7 The person is existing as a project member. ');
                           tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
	                 end if;

                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
	  		    p_api_version        => 1.0
			  , p_init_msg_list      => FND_API.G_TRUE
			  , p_commit             => FND_API.G_FALSE
			  , p_validate_only      => FND_API.G_FALSE
			  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
			  , p_debug_mode         => 'Y'
			  , p_object_id          => p_project_id
			  , p_OBJECT_TYPE        => 'PA_PROJECTS'
			  , p_project_role_id    => p_proj_role_id
			  , p_project_role_type  => NULL
			  , p_RESOURCE_TYPE_ID   => 101
			  , p_resource_source_id => p_task_manager_person_id
			  , p_resource_name      => v_null_char
			  , p_start_date_active  => l_start_date_active
			  , p_scheduled_flag     => 'N'
			  , p_calling_module     => 'FORM'
			  , p_project_id         => p_project_id
			  , p_project_end_date   => l_project_end_date
			  , p_end_date_active    => l_end_date_active_tmp
			  , x_project_party_id   => x_project_party_id
			  , x_resource_id        => x_resource_id
			  , x_wf_item_type       => l_wf_item_type
			  , x_wf_type            => l_wf_type
			  , x_wf_process         => l_wf_party_process
			  , x_assignment_id      => l_assignment_id
			  , x_return_status      => x_return_status
			  , x_msg_count          => x_msg_count
			  , x_msg_data           => x_msg_data);
                    /* Code added for Bug#2701884, starts here */
                    IF l_debug_mode = 'Y' then
		        if x_msg_count = 0 then
			    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
			 end if;
	            END IF;
                    /* Code added for Bug#2701884, ends here */

		       l_start_date_active := l_min_member_start_date;

                    IF l_debug_mode = 'Y' then
			 FOR I IN 1 .. X_MSG_COUNT LOOP
	                    pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
		                                                 ,p_msg_index   =>  x_msg_count
			                                         ,p_data         => x_msg_data
				                                 ,p_msg_index_out => l_msg_index_out);
                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
                           tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
	                 END LOOP;
		    END IF;

		  end if;

		  for l_proj_member_exists_rec in c_proj_member_exists (p_project_id, p_task_manager_person_id) LOOP

                         if (l_start_date_active < l_proj_member_exists_rec.start_date_active) then
                            if (l_end_date_active = (l_proj_member_exists_rec.start_date_active - 1)) then
			      l_end_date_active_tmp := l_proj_member_exists_rec.start_date_active - 1;
                            else
			      l_end_date_active_tmp := l_end_date_active;
			    end if;

                            if l_debug_mode = 'Y' then
                                tm_log('8 The person is existing as a project member. ');
                                tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
                            end if;

	                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active_tmp
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);
                           /* Code added for Bug#2701884, starts here */
	                    IF l_debug_mode = 'Y' then
			        if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
				 end if;
			    END IF;
                         /* Code added for Bug#2701884, ends here */

			      l_start_date_active := l_proj_member_exists_rec.start_date_active;

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
			    END IF;

			 end if;

			 if (l_proj_member_exists_rec.start_date_active between l_start_date_active and l_end_date_active
                            or l_proj_member_exists_rec.end_date_active between l_start_date_active and l_end_date_active) then

		               l_start_date_active := l_proj_member_exists_rec.end_date_active + 1;

			 end if;
                  END LOOP;

		  if (l_end_date_active - l_start_date_active) >= 0 then

                             if l_debug_mode = 'Y' then
                                tm_log('9 The person is existing as a project member. ');
                                tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active);
                             end if;

      	                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
                                /* Code added for Bug#2701884, starts here */
   			         if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
				    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active);
				 end if;
                                /* Code added for Bug#2701884, ends here */
			    END IF;

		  end if;
	          end if;
	      elsif (l_member_end_date_active is NOT NULL and l_end_date_active is NOT NULL) then

                  select min(start_date_active)
                    into l_min_member_start_date
		    from pa_project_parties
                   where project_id = p_project_id
                     and resource_source_id = p_task_manager_person_id
		     and project_role_id = p_proj_role_id;

		  if (l_start_date_active < l_min_member_start_date) then

	               l_end_date_active_tmp := l_min_member_start_date - 1;

                       if l_debug_mode = 'Y' then
                          tm_log('10 The person is existing as a project member. ');
                          tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
                       end if;

                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
	  		    p_api_version        => 1.0
			  , p_init_msg_list      => FND_API.G_TRUE
			  , p_commit             => FND_API.G_FALSE
			  , p_validate_only      => FND_API.G_FALSE
			  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
			  , p_debug_mode         => 'Y'
			  , p_object_id          => p_project_id
			  , p_OBJECT_TYPE        => 'PA_PROJECTS'
			  , p_project_role_id    => p_proj_role_id
			  , p_project_role_type  => NULL
			  , p_RESOURCE_TYPE_ID   => 101
			  , p_resource_source_id => p_task_manager_person_id
			  , p_resource_name      => v_null_char
			  , p_start_date_active  => l_start_date_active
			  , p_scheduled_flag     => 'N'
			  , p_calling_module     => 'FORM'
			  , p_project_id         => p_project_id
			  , p_project_end_date   => l_project_end_date
			  , p_end_date_active    => l_end_date_active_tmp
			  , x_project_party_id   => x_project_party_id
			  , x_resource_id        => x_resource_id
			  , x_wf_item_type       => l_wf_item_type
			  , x_wf_type            => l_wf_type
			  , x_wf_process         => l_wf_party_process
			  , x_assignment_id      => l_assignment_id
			  , x_return_status      => x_return_status
			  , x_msg_count          => x_msg_count
			  , x_msg_data           => x_msg_data);

			 /* Code added for Bug#2701884, starts here */
                          IF l_debug_mode = 'Y' then
	          	        if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
		         	end if;
               		  END IF;
                         /* Code added for Bug#2701884, ends here */

  		       l_start_date_active := l_min_member_start_date;

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
			    END IF;

		  end if;

		  for l_proj_member_exists_rec in c_proj_member_exists (p_project_id,
		                                                        p_task_manager_person_id) LOOP

                         if (l_start_date_active < l_proj_member_exists_rec.start_date_active) then

			      l_end_date_active_tmp := l_proj_member_exists_rec.start_date_active - 1;

                              if l_debug_mode = 'Y' then
                                 tm_log('11 The person is existing as a project member. ');
                                 tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
                              end if;

	                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active_tmp
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);

			 /* Code added for Bug#2701884, starts here */
	                    IF l_debug_mode = 'Y' then
			        if x_msg_count = 0 then
  				   tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
	                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
				 end if;
			    END IF;
                         /* Code added for Bug#2701884, ends here */

			      l_start_date_active := l_proj_member_exists_rec.start_date_active;

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
			    END IF;

			 end if;

			 if (l_proj_member_exists_rec.start_date_active between l_start_date_active and l_end_date_active
                            or l_proj_member_exists_rec.end_date_active between l_start_date_active and l_end_date_active) then

		               l_start_date_active := l_proj_member_exists_rec.end_date_active + 1;

			 end if;
                  END LOOP;

		  if (l_end_date_active - l_start_date_active) >= 0 then

                              if l_debug_mode = 'Y' then
                                 tm_log('12 The person is existing as a project member. ');
                                 tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active);
                              end if;

      	                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
                                /* Code added for Bug#2701884, starts here */
			         if x_msg_count = 0 then
                	 	     tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
                                     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active);
				 end if;
                                /* Code added for Bug#2701884, ends here * /
			    END IF;

		  end if;

	      elsif (l_member_end_date_active is NOT NULL and l_end_date_active is NULL) then

                  select min(start_date_active)
                    into l_min_member_start_date
		    from pa_project_parties
                   where project_id = p_project_id
                     and resource_source_id = p_task_manager_person_id
		     and project_role_id = p_proj_role_id;

		  if (l_start_date_active < l_min_member_start_date) then

	               l_end_date_active_tmp := l_min_member_start_date - 1;

                       if l_debug_mode = 'Y' then
                           tm_log('13 The person is existing as a project member. ');
                           tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
                       end if;

                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
	  		    p_api_version        => 1.0
			  , p_init_msg_list      => FND_API.G_TRUE
			  , p_commit             => FND_API.G_FALSE
			  , p_validate_only      => FND_API.G_FALSE
			  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
			  , p_debug_mode         => 'Y'
			  , p_object_id          => p_project_id
			  , p_OBJECT_TYPE        => 'PA_PROJECTS'
			  , p_project_role_id    => p_proj_role_id
			  , p_project_role_type  => NULL
			  , p_RESOURCE_TYPE_ID   => 101
			  , p_resource_source_id => p_task_manager_person_id
			  , p_resource_name      => v_null_char
			  , p_start_date_active  => l_start_date_active
			  , p_scheduled_flag     => 'N'
			  , p_calling_module     => 'FORM'
			  , p_project_id         => p_project_id
			  , p_project_end_date   => l_project_end_date
			  , p_end_date_active    => l_end_date_active_tmp
			  , x_project_party_id   => x_project_party_id
			  , x_resource_id        => x_resource_id
			  , x_wf_item_type       => l_wf_item_type
			  , x_wf_type            => l_wf_type
			  , x_wf_process         => l_wf_party_process
			  , x_assignment_id      => l_assignment_id
			  , x_return_status      => x_return_status
			  , x_msg_count          => x_msg_count
			  , x_msg_data           => x_msg_data);

         		   /* Code added for Bug#2701884, starts here */
	                    IF l_debug_mode = 'Y' then
			        if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
			            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
				 end if;
			    END IF;
                           /* Code added for Bug#2701884, ends here */

		       l_start_date_active := l_min_member_start_date;

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
			    END IF;

		  end if;

		  for l_proj_member_exists_rec in c_proj_member_exists (p_project_id, p_task_manager_person_id) LOOP

                         if (l_start_date_active < l_proj_member_exists_rec.start_date_active) then

			      l_end_date_active_tmp := l_proj_member_exists_rec.start_date_active - 1;

                              if l_debug_mode = 'Y' then
                                 tm_log('14 The person is existing as a project member. ');
                                 tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active_tmp);
                              end if;

	                       PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active_tmp
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);

                         /* Code added for Bug#2701884, starts here */
	                    IF l_debug_mode = 'Y' then
			        if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active_tmp);
				 end if;
			    END IF;
                         /* Code added for Bug#2701884, ends here */

			      l_start_date_active := l_proj_member_exists_rec.start_date_active;

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
			    END IF;

			 end if;

			 if (l_proj_member_exists_rec.start_date_active >= l_start_date_active
                            or l_proj_member_exists_rec.end_date_active >= l_start_date_active) then

		               l_start_date_active := l_proj_member_exists_rec.end_date_active + 1;

			 end if;
                  END LOOP;

                  if l_debug_mode = 'Y' then
                      tm_log('15 The person is existing as a project member. ');
                      tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active);
                  end if;

                  PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
		  		    p_api_version        => 1.0
				  , p_init_msg_list      => FND_API.G_TRUE
				  , p_commit             => FND_API.G_FALSE
				  , p_validate_only      => FND_API.G_FALSE
				  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
				  , p_debug_mode         => 'Y'
				  , p_object_id          => p_project_id
				  , p_OBJECT_TYPE        => 'PA_PROJECTS'
				  , p_project_role_id    => p_proj_role_id
				  , p_project_role_type  => NULL
				  , p_RESOURCE_TYPE_ID   => 101
				  , p_resource_source_id => p_task_manager_person_id
				  , p_resource_name      => v_null_char
				  , p_start_date_active  => l_start_date_active
				  , p_scheduled_flag     => 'N'
				  , p_calling_module     => 'FORM'
				  , p_project_id         => p_project_id
				  , p_project_end_date   => l_project_end_date
				  , p_end_date_active    => l_end_date_active
				  , x_project_party_id   => x_project_party_id
				  , x_resource_id        => x_resource_id
				  , x_wf_item_type       => l_wf_item_type
				  , x_wf_type            => l_wf_type
				  , x_wf_process         => l_wf_party_process
				  , x_assignment_id      => l_assignment_id
				  , x_return_status      => x_return_status
				  , x_msg_count          => x_msg_count
				  , x_msg_data           => x_msg_data);

	                    IF l_debug_mode = 'Y' then
				 FOR I IN 1 .. X_MSG_COUNT LOOP
			            pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
				                                         ,p_msg_index   =>  x_msg_count
					                                 ,p_data         => x_msg_data
						                         ,p_msg_index_out => l_msg_index_out);
	                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
		                   tm_out(p_project_id, p_task_manager_person_id, x_msg_data);
			         END LOOP;
                                /* Code added for Bug#2701884, starts here */
			         if x_msg_count = 0 then
				    tm_out(p_project_id, p_task_manager_person_id, l_tmp_str);
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active);
				 end if;
                                /* Code added for Bug#2701884, ends here */
			    END IF;
	      end if;
           end if;
 end validate_member_exists;


/* Main Procedure to upgrade the task managers as project members */

 procedure upgrade_task_manager ( errbuf                OUT NOCOPY VARCHAR2, /*Added Nocopy for 4537865 */
                                  retcode               OUT NOCOPY VARCHAR2, /*Added Nocopy for 4537865 */
				  p_project_num_from    IN  VARCHAR2,
                                  p_project_num_to      IN  VARCHAR2,
                                  p_project_role        IN  VARCHAR2,
                                  p_project_org         IN  NUMBER,
                                  p_project_type        IN  VARCHAR2) IS

  CURSOR c_selprojs IS
    select p.project_id
      from pa_projects_all p
     where p.segment1 between p_project_num_from and p_project_num_to
       and p.carrying_out_organization_id = nvl(p_project_org, p.carrying_out_organization_id)
       and p.project_type = nvl(p_project_type, p.project_type);

  CURSOR c_seltaskmgrs (p_project_id IN NUMBER) IS
   select distinct t.task_manager_person_id
     from pa_tasks t
    where t.project_id = p_project_id
      and t.task_manager_person_id is not null;

  CURSOR c_task_end_date_active (p_project_id             IN NUMBER,
                                 p_task_manager_person_id IN NUMBER) IS
   select 1
     from pa_tasks t
    where t.project_id = p_project_id
      and t.task_manager_person_id = p_task_manager_person_id
      and t.completion_date is NULL;

  CURSOR c_proj_member (p_project_id             IN NUMBER,
			p_task_manager_person_id IN NUMBER) IS
   select 1
     from pa_project_parties
    where project_id = p_project_id
      and resource_source_id = p_task_manager_person_id
      and project_role_id = p_project_role;

  l_start_date             pa_tasks.start_date%TYPE;
  l_dummy                  NUMBER;
  l_dummy1                 NUMBER;
  l_mgr_start_date         DATE;
  l_mgr_end_date           DATE;
  v_null_char              VARCHAR2(1);
  x_return_status          VARCHAR2(255);
  x_msg_count              NUMBER;
  x_msg_data               VARCHAR2(2000);
  x_project_party_id       NUMBER;
  x_resource_id            NUMBER;
  l_wf_item_type           VARCHAR2(30);
  l_wf_type                VARCHAR2(30);
  l_wf_party_process       VARCHAR2(30);
  l_assignment_id          NUMBER;
  l_project_start_date     DATE;
  l_project_end_date       DATE;

  l_start_date_active	   DATE;
  l_end_date_active        DATE;
  l_mgr_end_date_active    DATE;
  l_create_project_member  VARCHAR2(1);
  l_member_end_date_active DATE;
  l_role_type              pa_project_role_types.project_role_type%TYPE;
  l_proj_counter           NUMBER;

  l_msg_index_out          NUMBER;

  l_debug_mode             VARCHAR2(1);
  l_tmp_str                fnd_new_messages.message_text%TYPE; /* Bug#2701884 */

BEGIN

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');

  l_tmp_str := fnd_message.get_string('PA', 'PA_TM_CR_PROJ_MEMBER');  /* Bug#2701884 */

--  if l_debug_mode = 'Y' then   /* Commented for the 2701884 */
       tm_log('l_debug_mode: '||l_debug_mode);
       tm_log('Profile PA_TM_PROJ_MEMBER value: '||get_profile_value('PA_TM_PROJ_MEMBER'));
--  end if;  /* Commented for the 2701884 */

   select project_role_type
     into l_role_type
     from pa_project_role_types
    where project_role_id = p_project_role;

  /* This program should run only if the profile
     'PA: Task Managers restricted to Project Members' is set to yes. */


  IF get_profile_value('PA_TM_PROJ_MEMBER') = 'Y' THEN

      print_output(p_project_num_from,
                   p_project_num_to,
                   l_role_type,
                   p_project_org,
                   p_project_type);

      l_proj_counter := 0;

    for l_selprojs_rec in c_selprojs LOOP

       l_proj_counter := l_proj_counter + 1;

      PA_PROJECT_PARTIES_UTILS.GET_PROJECT_DATES(p_project_id => l_selprojs_rec.project_id,
                                                 x_project_start_date => l_project_start_date,
                                                 x_project_end_date => l_project_end_date,
                                                 x_return_status => x_return_status);
      if l_debug_mode = 'Y' then
         tm_log('project_id: '||l_selprojs_rec.project_id);
      end if;

      for l_seltaskmgrs_rec in c_seltaskmgrs(l_selprojs_rec.project_id) LOOP

            /* can be converted as a sub procedure, starts here   */
	      select min(nvl(t.start_date,l_project_start_date)), max(completion_date)
                into l_start_date_active, l_end_date_active
	        from pa_tasks t
	       where t.project_id = l_selprojs_rec.project_id
	         and t.task_manager_person_id = l_seltaskmgrs_rec.task_manager_person_id;

              open c_task_end_date_active(l_selprojs_rec.project_id,
                                          l_seltaskmgrs_rec.task_manager_person_id);
              fetch c_task_end_date_active into l_dummy1;
              if c_task_end_date_active%FOUND then
                 l_end_date_active := NULL;
                 close c_task_end_date_active;
              else
                 close c_task_end_date_active;
              end if;
            /* can be converted as a sub procedure, ends here   */

	   if l_debug_mode = 'Y' then
             tm_log('task_manager_person_id: '||l_seltaskmgrs_rec.task_manager_person_id );
	     tm_log('Start Date Active : '||l_start_date_active);
             tm_log('End Date Active : '||l_end_date_active);
           end if;

        open c_proj_member(l_selprojs_rec.project_id, l_seltaskmgrs_rec.task_manager_person_id);
	fetch c_proj_member into l_dummy;

        if c_proj_member%NOTFOUND then
	   close c_proj_member;

      	      if l_debug_mode = 'Y' then
		   tm_log('5 The person is not existing as a project member.' );
                   tm_log('Creating the project member for the period '||l_start_date_active||' to '||l_end_date_active);
	      end if;


	      PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
	  		    p_api_version        => 1.0
			  , p_init_msg_list      => FND_API.G_TRUE
			  , p_commit             => FND_API.G_FALSE
			  , p_validate_only      => FND_API.G_FALSE
			  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
			  , p_debug_mode         => 'Y'
			  , p_object_id          => l_selprojs_rec.project_id
			  , p_OBJECT_TYPE        => 'PA_PROJECTS'
			  , p_project_role_id    => p_project_role
			  , p_project_role_type  => NULL
			  , p_RESOURCE_TYPE_ID   => 101
			  , p_resource_source_id => l_seltaskmgrs_rec.task_manager_person_id
			  , p_resource_name      => v_null_char
			  , p_start_date_active  => l_start_date_active
			  , p_scheduled_flag     => 'N'
			  , p_calling_module     => 'FORM'
			  , p_project_id         => l_selprojs_rec.project_id
			  , p_project_end_date   => l_project_end_date
			  , p_end_date_active    => l_end_date_active
			  , x_project_party_id   => x_project_party_id
			  , x_resource_id        => x_resource_id
			  , x_wf_item_type       => l_wf_item_type
			  , x_wf_type            => l_wf_type
			  , x_wf_process         => l_wf_party_process
			  , x_assignment_id      => l_assignment_id
			  , x_return_status      => x_return_status
			  , x_msg_count          => x_msg_count
			  , x_msg_data           => x_msg_data);

                    IF l_debug_mode = 'Y' then
			 FOR I IN 1 .. X_MSG_COUNT LOOP
	                    pa_interface_utils_pub.get_messages ( p_encoded   => FND_API.G_FALSE
		                                                 ,p_msg_index   =>  x_msg_count
			                                         ,p_data         => x_msg_data
				                                 ,p_msg_index_out => l_msg_index_out);
                           tm_log('*** ERROR MESSAGE ***: '||x_msg_data);
                           tm_out(l_selprojs_rec.project_id, l_seltaskmgrs_rec.task_manager_person_id, x_msg_data);
	                 END LOOP;
                         /* Code added for Bug#2701884, starts here */
			 if x_msg_count = 0 then
			    tm_out(l_selprojs_rec.project_id, l_seltaskmgrs_rec.task_manager_person_id, l_tmp_str);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||l_start_date_active||' to '||l_end_date_active);
			 end if;
                         /* Code added for Bug#2701884, ends here */
		     END IF;

        else  /* if c_proj_member%NOTFOUND   */
	   close c_proj_member;

                if l_debug_mode = 'Y' then
                   tm_log('The person is existing as a project member. Validating the periods.');
	        end if;

               validate_member_exists ( p_project_id              => l_selprojs_rec.project_id,
                                        p_task_manager_person_id  => l_seltaskmgrs_rec.task_manager_person_id,
	                                p_proj_role_id            => p_project_role,
				        p_start_date_active       => l_start_date_active,
				        p_end_date_active         => l_end_date_active,
				        p_project_end_date        => l_project_end_date);

	end if;

      END LOOP;     /* for l_seltaskmgrs_rec in c_seltaskmgrs(l_selprojs_rec.project_id) */

      if l_proj_counter = 100 then
         COMMIT;
      end if;

    END LOOP;    /* for l_selprojs_rec in c_selprojs  */
    COMMIT;

  END IF;  /* if get_profile_value('PA_TM_PROJ_MEMBER') = 'Y' */

EXCEPTION

  when no_data_found then
     tm_log('in exception, when no_data_found');
     tm_log('SQLCODE:'||SQLCODE);
     tm_log('SQLERRM:'||SQLERRM);

  when others then
     tm_log('in exception, when others');
     tm_log('SQLCODE:'||SQLCODE);
     tm_log('SQLERRM:'||SQLERRM);

 end upgrade_task_manager;


/* procedure to print the debug messages in the log file */

procedure tm_log (p_message      IN VARCHAR2) IS
begin
   FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'HH:MI:SS:   ')|| p_message);
exception
  when others then
     raise;
end tm_log;


/* procedure to print the data in the output report for the concurrent process */

procedure tm_out ( p_project_id              IN NUMBER,
                   p_task_manager_person_id  IN NUMBER,
                   p_message                 IN VARCHAR2) IS
  l_proj_num  pa_projects_all.segment1%TYPE;
  l_emp_name  pa_employees_res_v.employee_name%TYPE;
  len_msg     NUMBER;
  l_count_msg NUMBER;
  x           NUMBER;
  l_message   VARCHAR2(1000);

begin
  select segment1
    into l_proj_num
    from pa_projects_all
   where project_id = p_project_id;

  select employee_name
    into l_emp_name
    from pa_employees_res_v
   where person_id = p_task_manager_person_id;

  select length(p_message)
    into len_msg
    from dual;

    tm_log('len_msg:'||len_msg);

  if len_msg > 60 then
    x := 60;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(l_proj_num,30,' ')||'   '||rpad(l_emp_name,30,' ')||'   '||substr(p_message,1,x));
    l_count_msg := floor(len_msg/60);

    for i in 2..l_count_msg loop
     tm_log('i:'||i);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||substr(p_message, ((i-1)*60)+1, 60));
      x := i*60;
    end loop;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(' ',30,' ')||'   '||rpad(' ',30,' ')||'   '||substr(p_message,x+1,len_msg));
  else
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' '||rpad(l_proj_num,30,' ')||'   '||rpad(l_emp_name,30,' ')||'   '||p_message);
  end if;

end tm_out;


/* procedure to print the header info in the output report for the concurrent process */

procedure print_output (p_project_num_from    IN  VARCHAR2,
                        p_project_num_to      IN  VARCHAR2,
                        p_project_role        IN  VARCHAR2,
                        p_project_org         IN  NUMBER,
                        p_project_type        IN  VARCHAR2)  IS

  l_sob_id    NUMBER;
  l_sob_name  VARCHAR2(30);
  l_tmp_str   VARCHAR2(132);
  l_tmp_str2  VARCHAR2(132);
  l_tmp_str3  VARCHAR2(132);
  l_tblock    VARCHAR2(132);

begin

    SELECT IMP.Set_Of_Books_ID
    INTO   l_sob_id
    FROM   PA_Implementations IMP;

    SELECT SUBSTRB(GL.Name, 1, 30)
    INTO   l_sob_name
    FROM   GL_Sets_Of_Books GL
    WHERE  GL.Set_Of_Books_ID = l_sob_id;

    l_tmp_str := fnd_message.get_string('PA', 'PA_TM_DATE');

    SELECT  ' '||rpad(l_sob_name,30,' ')||lpad(l_tmp_str,75,' ')||sysdate
    INTO    l_tblock
    FROM    DUAL;
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_tblock);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);

    l_tmp_str := fnd_message.get_string('PA', 'PA_TM_RPT_HDR');

    SELECT lpad(l_tmp_str,66+length(l_tmp_str)/2,' ')
    INTO l_tblock
    FROM DUAL;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_tblock);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);


    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------------------------------------');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

    l_tmp_str := fnd_message.get_string('PA', 'PA_TM_PROJ_NUM');
    l_tmp_str := ' '||rpad(l_tmp_str, 30, ' ');

    l_tmp_str2 := fnd_message.get_string('PA', 'PA_TM_TASK_MGR');
    l_tmp_str2 := rpad(l_tmp_str2, 30, ' ');

    l_tmp_str3 := fnd_message.get_string('PA', 'PA_TM_REASON');
    l_tmp_str3 := rpad(l_tmp_str3, 60, ' ');

   SELECT l_tmp_str||'   '||l_tmp_str2||'   '||l_tmp_str3
     INTO l_tblock
     FROM DUAL;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_tblock);

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------------------------------------');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

end;


END PA_TASK_MANAGER;

/
