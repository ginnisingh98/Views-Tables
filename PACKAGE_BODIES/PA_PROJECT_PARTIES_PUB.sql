--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_PARTIES_PUB" as
/* $Header: PARPPPMB.pls 120.5.12010000.3 2009/09/08 07:25:19 anuragar ship $ */

PROCEDURE CREATE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER := FND_API.G_MISS_NUM,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_start_date_active     IN DATE := FND_API.G_MISS_DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE := FND_API.G_MISS_DATE,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_project_party_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_resource_id           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_error_occured      VARCHAR2(1) := 'N';
  x_assignment_action  VARCHAR2(20) := 'NOACTION';
  l_api_version        NUMBER := 1.0;
  l_api_name           VARCHAR2(30) := 'create_project_party';
  l_resource_id        NUMBER;
  l_project_id         NUMBER;
  l_project_party_id   NUMBER;
  l_resource_source_id NUMBER;
  l_resource_type_id   NUMBER;
  l_project_role_id    NUMBER;
  l_error_message_code      fnd_new_messages.message_name%TYPE;
  l_record_version_number  NUMBER := 1;
  l_project_start_date   DATE;
  l_project_end_date     DATE;
  l_start_date_active    DATE;
  l_msg_index_out        NUMBER;
  x_resource_type_id  pa_resources.resource_type_id%type; -- added for bug 2636791
  x_role_party_class    pa_project_role_types_b.role_party_class%type; /* Added for Bug 2876924 */
  l_key_member_start_date DATE; -- Added for bug 2686120
  l_check_id_flag      VARCHAR2(1); -- Added for bug 4947618
  l_end_date_active      DATE;--Bug 6935585
BEGIN

--dbms_output.put_line('Check1');

   SAVEPOINT create_project_party;

   --- Standard call to check for call compatibility
   if (p_debug_mode = 'Y') then
       pa_debug.debug('create_project_party: Checking the api version number.');
   end if;

    if NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'PA_PROJECT_PARTIES_PUB') then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

   ------dbms_output.put_line('Before initializing the stack');

   --- Initialize the message stack if required

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Create_project_party: Initializing message stack.');
   end if;
       pa_debug.init_err_stack('Create_project_party_pub');

    if FND_API.to_boolean(nvl(p_init_msg_list,FND_API.G_TRUE)) then
        fnd_msg_pub.initialize;
    end if;

   ------dbms_output.put_line('After initializing the stack');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_project_role_id is null or p_project_role_id = FND_API.G_MISS_NUM then
      l_project_role_id := pa_project_parties_utils.get_project_role_id(p_project_role_type,p_calling_module);
   else
      l_project_role_id := p_project_role_id;
   end if;
--dbms_output.put_line('Check2');
 /*  if p_resource_source_id is null or p_resource_source_id = FND_API.G_MISS_NUM then
      l_resource_source_id :=  pa_project_parties_utils.get_resource_source_id(p_resource_name);
   else
      l_resource_source_id := p_resource_source_id;
   end if; */


   if p_project_id is not null and p_project_id <> FND_API.G_MISS_NUM then
        PA_PROJECT_PARTIES_UTILS.GET_PROJECT_DATES(p_project_id => p_project_id,
                                              x_project_start_date => l_project_start_date,
                                              x_project_end_date => l_project_end_date,
                                              x_return_status => x_return_status);
   end if;
--dbms_output.put_line('Check3');
   if p_project_id is null or p_project_id = FND_API.G_MISS_NUM then
        l_project_id := null;
   else
        l_project_id := p_project_id;
   end if;

   /* Bug 2636791 - changes begin */

   /* Following code is added to implement the logic :-
      -> If project has a past start date, key member start date should
         default to the project start date.
      -> If project has a future start date, key member start date should
         default to the sysdate.
	 */

   if p_project_id is not null and p_project_id <> FND_API.G_MISS_NUM then
       if l_project_start_date is not NULL THEN
          if l_project_start_date <= trunc(sysdate) then
	     l_project_start_date := l_project_start_date;
	  else
	     l_project_start_date := trunc(sysdate);
	  end if;
       else
           l_project_start_date := trunc(sysdate);
       end if;
    end if;

   /* Following code commented to implement the new logic as mentioned above
   if p_start_date_active is null or p_start_date_active = FND_API.G_MISS_DATE then
     l_start_date_active := trunc(sysdate);
   else
     l_start_date_active := p_start_date_active;
   end if;
   */

    /* if p_resource_source_id is null or p_resource_source_id = FND_API.G_MISS_NUM then
      l_resource_source_id :=  pa_project_parties_utils.get_resource_source_id(p_resource_name);
   else
      l_resource_source_id := p_resource_source_id;
   end if;  */

/* Commented the code for the bug 2686120*/
   /*if p_start_date_active is null or p_start_date_active = FND_API.G_MISS_DATE then
      	 l_start_date_active := l_project_start_date;
    else
         l_start_date_active := p_start_date_active;
    end if;*/


   /* Modified for the bug 2686120 changed the parameter to get the values of start date.*/

   l_key_member_start_date  := PA_RESOURCE_UTILS.GET_PERSON_START_DATE(p_resource_source_id);

   /*Commented the below code for the bug 2910972*/

    /*IF p_start_date_active is null OR
       p_start_date_active = FND_API.G_MISS_DATE
    THEN
       IF l_key_member_start_date > sysdate THEN
          l_start_date_active := l_key_member_start_date;
        ELSE
      	  l_start_date_active := GET_KEY_MEMBER_START_DATE(p_project_id);
	END IF;
    ELSE
         l_start_date_active := p_start_date_active;
    END IF;*/

/*Added the below code for the bug 2910972*/

     IF p_start_date_active is null OR
       p_start_date_active = FND_API.G_MISS_DATE
    THEN
       IF l_key_member_start_date > sysdate THEN
          l_start_date_active := l_key_member_start_date;
        ELSE
      	  l_start_date_active := GET_KEY_MEMBER_START_DATE(p_project_id);
	    IF l_start_date_active < l_key_member_start_date THEN
	      l_start_date_active := l_key_member_start_date;
            END IF;
	END IF;
    ELSE
         l_start_date_active := p_start_date_active;
    END IF;

/*Added till here for bug 2910972*/

    /* Bug 2636791 - changes end */

    /* Bug 2636791 - changes for add organization start date.
                     On adding a new organization to a project
		     start date should be sysdate*/
/* Bug 3116962 : Added a IF clause to check if the project_role_id is valid or not. Accordingly the SELECT statement below will execute. */
 IF l_project_role_id <> -999 AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    SELECT resource_type_id into x_resource_type_id
    FROM pa_resource_types
    WHERE resource_type_code='HZ_PARTY';

    /* Bug 2876924 - For external people start date should not be defaulted to sysdate.
       resource type id of external people is same as that of org. ie 112.
       Hence including a check that role party class should not be 'PERSON'
       before start date is defaulted to sysdate */

    select role_party_class into x_role_party_class
    from pa_project_role_types_b
    where project_role_id = l_project_role_id;

END IF; /* Bug 3116962  */

    l_end_date_active := p_end_date_active; --Bug 6935585

    if 	p_resource_type_id = x_resource_type_id and x_role_party_class <> 'PERSON'  Then
      l_start_date_active := trunc(sysdate);
      --Changes done to set end_date_active to null when new organization gets added using copy
      -- project flow
      l_end_date_active   := null; --Bug 6935585
    end if;

/* Start of code for Bug 4947618 */

   IF p_calling_module = 'PROJECT_MEMBER' THEN
       l_check_id_flag := 'Y';
   ELSE
       l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
   END IF;

/* End of code for Bug 4947618 */

--dbms_output.put_line('Check4');
   PA_RESOURCE_UTILS.Check_ResourceName_Or_Id ( p_resource_id        => p_resource_source_id
                                                ,p_resource_type_id   => p_resource_type_id
                                                ,p_resource_name      => p_resource_name
                                                ,p_check_id_flag      => l_check_id_flag --Bug 4947618 PA_STARTUP.G_Check_ID_Flag
                                                ,p_date               => l_start_date_active
                                                ,x_resource_id        => l_resource_source_id
                                                ,x_resource_type_id   => l_resource_type_id
                                                ,x_return_status      => x_return_status
                                                ,x_error_message_code => l_error_message_code)
;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          fnd_message.set_name('PA',l_error_message_code);
          fnd_msg_pub.add;
    end if;

--dbms_output.put_line('Check5 role_id='||l_project_role_id||', resource_source_id='||l_resource_source_id);
   -- dbms_output.put_line('Return Status '||x_return_status);

   if l_project_role_id <> -999 and l_resource_source_id <> -999 and x_return_status = FND_API.G_RET_STS_SUCCESS then
--dbms_output.put_line('Check6');
   PA_PROJECT_PARTIES_PVT.CREATE_PROJECT_PARTY( p_commit => p_commit,
                                p_validate_only         => p_validate_only,
                                p_validation_level      => p_validation_level,
                                p_debug_mode            => p_debug_mode,
                                p_object_id             => p_object_id,
                                p_OBJECT_TYPE           => p_object_type,
                                p_RESOURCE_TYPE_ID      => l_resource_type_id,
                                p_project_role_id       => l_project_role_id,
                                p_resource_source_id    => l_resource_source_id,
                                p_start_date_active     => l_start_date_active,
                                p_scheduled_flag        => p_scheduled_flag,
                                p_calling_module        => p_calling_module,
                                p_project_id            => l_project_id,
                                p_project_end_date      => l_project_end_date,
                                p_end_date_active       => l_end_date_active, --Bug 6935585 p_end_date_active,
				p_mgr_validation_type   => p_mgr_validation_type,
                                x_project_party_id      => x_project_party_id,
                                x_resource_id           => x_resource_id,
                                x_assignment_id         => x_assignment_id,
                                x_wf_type               => x_wf_type,
                                x_wf_item_type          => x_wf_item_type,
                                x_wf_process            => x_wf_type,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data);
    else
        x_return_status := FND_API.G_RET_STS_ERROR;
    end if;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
--dbms_output.put_line('Check7');
    IF x_msg_count = 1 THEN
--dbms_output.put_line('Check8');
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    END IF;
--dbms_output.put_line('Check9');
  pa_debug.reset_err_stack;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--dbms_output.put_line('Check10');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','CREATE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;

 WHEN OTHERS THEN
    rollback to create_project_party;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.G_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_PROJECT_PARTY;

PROCEDURE UPDATE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_id           IN NUMBER := FND_API.G_MISS_NUM,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE :=  FND_API.G_MISS_DATE,
                                p_project_party_id      IN NUMBER,
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_error_occured        VARCHAR2(1) := 'N';
  x_assignment_action    VARCHAR2(20) := 'NOACTION';
  l_api_version          NUMBER := 1.0;
  l_api_name             VARCHAR2(30) := 'Update_project_party';
  l_record_version_number  NUMBER;
  l_project_party_id     NUMBER;
  l_project_id           NUMBER;
  l_resource_source_id   NUMBER;
  l_resource_type_id     NUMBER;
  l_project_role_id      NUMBER;
  l_project_start_date   DATE;
  l_project_end_date     DATE;
  l_start_date_active    DATE;
  l_msg_index_out        NUMBER;
  l_error_message_code      fnd_new_messages.message_name%TYPE;
  l_check_id_flag      VARCHAR2(1); -- Added for bug 4947618

BEGIN
   SAVEPOINT update_project_party;
   --- Standard call to check for call compatibility
   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_party: Checking he api version number.');
   end if;

    if NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'PA_PROJECT_PARTIES_PUB') then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

   ------dbms_output.put_line('Before initializing the stack');
    pa_debug.init_err_stack('Update_project_party_pub');

   --- Initialize the message stack if required

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Update_project_party: Initializing message stack.');
   end if;

    if FND_API.to_boolean(nvl(p_init_msg_list,FND_API.G_TRUE)) then
        fnd_msg_pub.initialize;
    end if;

   ------dbms_output.put_line('After initializing the stack');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_project_role_id is null or p_project_role_id = FND_API.G_MISS_NUM then
      l_project_role_id := pa_project_parties_utils.get_project_role_id(p_project_role_type,p_calling_module);
   else
      l_project_role_id := p_project_role_id;
   end if;

  /* if p_resource_source_id is null or p_resource_source_id = FND_API.G_MISS_NUM then
      l_resource_source_id :=  pa_project_parties_utils.get_resource_source_id(p_resource_name);
   else
      l_resource_source_id := p_resource_source_id;
   end if;  */

   if p_project_id is not null and p_project_id <> FND_API.G_MISS_NUM then
       PA_PROJECT_PARTIES_UTILS.GET_PROJECT_DATES(p_project_id => p_project_id,
                                              x_project_start_date => l_project_start_date,
                                              x_project_end_date => l_project_end_date,
                                              x_return_status => x_return_status);
   end if;

   if p_project_id is null or p_project_id = FND_API.G_MISS_NUM then
        l_project_id := null;
   else
        l_project_id := p_project_id;
   end if;


   if p_start_date_active is null or p_start_date_active = FND_API.G_MISS_DATE then
   ---     if l_project_start_date is not null then
   ---           l_start_date_active := l_project_start_date;
   ---     else
              l_start_date_active := trunc(sysdate);
   ---     end if;
   else
        l_start_date_active := p_start_date_active;
   end if;

   /* Start of code for Bug 4947618 */

    IF p_calling_module = 'PROJECT_MEMBER' THEN
       l_check_id_flag :='Y';
    ELSE
       l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
    END IF;

  /* End of code for Bug 4947618 */

   PA_RESOURCE_UTILS.Check_ResourceName_Or_Id ( p_resource_id      => p_resource_source_id
                                                ,p_resource_type_id   => p_resource_type_id
                                                ,p_resource_name   => p_resource_name
                                                ,p_check_id_flag   => l_check_id_flag --bug 4947618 PA_STARTUP.G_Check_ID_Flag
                                                ,p_date            => l_start_date_active
                                                ,x_resource_id     => l_resource_source_id
                                                ,x_resource_type_id  => l_resource_type_id
                                                ,x_return_status     => x_return_status
                                                ,x_error_message_code => l_error_message_code);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          fnd_message.set_name('PA',l_error_message_code);
          fnd_msg_pub.add;
    end if;

   if l_project_role_id <> -999 and l_resource_source_id <> -999 and x_return_status = FND_API.G_RET_STS_SUCCESS then
   PA_PROJECT_PARTIES_PVT.UPDATE_PROJECT_PARTY( p_commit => p_commit,
                                p_validate_only         => p_validate_only,
                                p_validation_level      => p_validation_level,
                                p_debug_mode            => p_debug_mode,
                                p_object_id             => p_object_id,
                                p_OBJECT_TYPE           => p_object_type,
                                p_project_role_id       => l_project_role_id,
                                p_resource_type_id      => l_resource_type_id,
                                p_resource_source_id    => l_resource_source_id,
                                p_resource_id           => p_resource_id,
                                p_start_date_active     => l_start_date_active,
                                p_scheduled_flag        => p_scheduled_flag,
                                p_record_version_number => p_record_version_number,
                                p_calling_module        => p_calling_module,
                                p_project_id            => l_project_id,
                                p_project_end_date      => l_project_end_date,
                                p_project_party_id      => p_project_party_id,
                                p_assignment_id         => p_assignment_id,
                                p_assign_record_version_number => p_assign_record_version_number,
                                p_end_date_active       => p_end_date_active,
				p_mgr_validation_type   => p_mgr_validation_type,
                                x_assignment_id         => x_assignment_id,
                                x_wf_type               => x_wf_type,
                                x_wf_item_type          => x_wf_item_type,
                                x_wf_process            => x_wf_type,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data);
    else
        x_return_status := FND_API.G_RET_STS_ERROR;
    end if;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    END IF;

    pa_debug.reset_err_stack;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','UPDATE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;


    WHEN OTHERS THEN
    rollback to update_project_party;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;

end update_project_party;


PROCEDURE DELETE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
/* modified the default value for p_init_msg_list from FND_API.G_TRUE to FND_API.G_FALSE, for
 the bug#1851096  */
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_party_id      IN NUMBER := FND_API.G_MISS_NUM,
                                p_scheduled_flag        IN VARCHAR2 default 'N',
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
                                p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_project_id          NUMBER := 0;
   API_ERROR             EXCEPTION;
   l_api_version        NUMBER := 1.0;
   l_api_name           VARCHAR2(30) := 'delete_project_party';
   l_msg_index_out      NUMBER;
   l_task_cnt           NUMBER := 0;
   --Changes for 8726175
   cursor task_cnt_crsr is
   select count(pt.task_id) from pa_tasks pt where project_id=p_project_id and task_manager_person_id =
			(select resource_source_id from pa_project_parties where project_party_id=p_project_party_id
						  and project_id=p_project_id)
			and exists
			(select 1 from pa_progress_rollup where project_id=pt.project_id and proj_element_id = pt.task_id
				and structure_version_id is null
			);
BEGIN
   --- Standard call to check for call compatibility
   if (p_debug_mode = 'Y') then
       pa_debug.debug('Delete_project_party: Checking he api version number.');
   end if;

    if NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'PA_PROJECT_PARTIES_PUB') then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

   ------dbms_output.put_line('Before initializing the stack');
   pa_debug.init_err_stack('Delete_project_party_pub');

   --- Initialize the message stack if required

   if (p_debug_mode = 'Y') then
       pa_debug.debug('Delete_project_party: Initializing message stack.');
   end if;

    if FND_API.to_boolean(nvl(p_init_msg_list,fnd_api.G_TRUE)) then
        fnd_msg_pub.initialize;
    end if;

   ------dbms_output.put_line('After initializing the stack');


   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --changes for 8726175 starts
   open task_cnt_crsr;
   fetch task_cnt_crsr into l_task_cnt;
   if l_task_cnt > 0
   then
   FND_MESSAGE.Set_Name('PA', 'PA_PARTY_PROGR_TASK');
        fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;

   else
   if (p_debug_mode = 'Y') then
       pa_debug.debug('Delete_project_party : Before delete from pa_project_players ');
   end if;

   if p_scheduled_flag = 'Y' and p_calling_module = 'PROJECT_MEMBER' then
       -- call delete assignment api
        PA_ASSIGNMENTS_PUB.Delete_Assignment
        ( p_assignment_id         => p_assignment_id
         ,p_assignment_type       => 'STAFFED_ASSIGNMENT'
         ,p_record_version_number => p_assign_record_version_number
         ,p_commit                => p_commit
         ,p_validate_only         => FND_API.G_FALSE
         ,p_init_msg_list         => FND_API.G_TRUE
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
        );
   else
   PA_PROJECT_PARTIES_PVT.DELETE_PROJECT_PARTY( p_commit => p_commit,
                                p_validate_only         => p_validate_only,
                                p_validation_level      => p_validation_level,
                                p_debug_mode            => p_debug_mode,
                                p_record_version_number => p_record_version_number,
                                p_calling_module        => p_calling_module,
                                p_project_id            => p_project_id,
                                p_project_party_id      => p_project_party_id,
                                p_scheduled_flag        => p_scheduled_flag,
                                p_assignment_id         => p_assignment_id,
                                p_assign_record_version_number => p_assign_record_version_number,
				p_mgr_validation_type   => p_mgr_validation_type,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data);
   end if;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    END IF;
	end if; --changes for 8726175 ends

  pa_debug.reset_err_stack;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','DELETE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;

   WHEN NO_DATA_FOUND THEN

     if (p_debug_mode = 'Y') then
         pa_debug.debug('Delete_project_party : Exception NO_DATA_FOUND  ');
     end if;

     fnd_message.set_name('PA', 'PA_XC_NO_DATA_FOUND');
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS then

     if (p_debug_mode = 'Y') then
         pa_debug.debug('Delete_project_party : Exception OTHERS  ');
     end if;

     if(SQLCODE = -54) then
        FND_MESSAGE.Set_Name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
        FND_MESSAGE.Set_token('ENTITY', 'PA_PROJECT_PARTIES');
        FND_MESSAGE.Set_token('PROJECT',to_char(P_PROJECT_ID));
        FND_MESSAGE.Set_token('TASK',NULL);
        x_msg_data := FND_MESSAGE.get;
        x_return_status := FND_API.G_RET_STS_ERROR;
      else
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

END DELETE_PROJECT_PARTY;


-- API name		: get_key_member_start_date
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id        IN NUMBER     REQUIRED
--
--  History
--
--           28-MAY-2002    anlee     Created
--
--
--  Purpose
--  This API is used to calculate the key member start date
--  based on the project start date.
--  It is called in CREATE_PROJECT_PARTY, and is used to
--  default key member start dates when a project is created.
--  The implemented functionality is as follows:
--
--  IF project_start date <= sysdate
--  return project start date
--
--  IF project start date > sysdate
--  return sysdate
--
--  This function may be modified if the logic for defaulting
--  key member start date at project creation time needs to
--  be changed.
-- Changes made for the bug 2686120
-- Added a new parameter p_person_id to the function to change the
-- defaulting mechanism.
-- If the project start date is greater than the sysdate
-- then default the key member start date to the employee start date.
FUNCTION GET_KEY_MEMBER_START_DATE (p_project_id IN NUMBER)




return DATE
IS

 /* Bug 2636791 - We will be selecting start date
    by calling PA_PROJECT_DATES_UTILS.GET_PROJECT_START_DATE API*/
  /*
  CURSOR date_csr IS
  SELECT start_date from pa_projects_all
  WHERE  project_id = p_project_id;
  */


  l_project_start_date DATE := NULL;

BEGIN
  /*
  OPEN date_csr;
  FETCH date_csr INTO l_project_start_date;
  CLOSE date_csr;
  */


  l_project_start_date := PA_PROJECT_DATES_UTILS.GET_PROJECT_START_DATE(p_project_id);

  if l_project_start_date is not NULL then
    if l_project_start_date <= trunc(sysdate) then
      return l_project_start_date;
    else
      return trunc(sysdate);
    end if;
  end if;

  return trunc(sysdate);

EXCEPTION
  WHEN OTHERS THEN
    return trunc(sysdate);

END GET_KEY_MEMBER_START_DATE;

/*=============================================================================
 This api is used as a wrapper API to CREATE_PROJECT_PARTY
==============================================================================*/

PROCEDURE CREATE_PROJECT_PARTY_WRP( p_api_version       IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER := FND_API.G_MISS_NUM,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_start_date_active     IN DATE := FND_API.G_MISS_DATE,/*Added for bug2774759*/
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE := FND_API.G_MISS_DATE,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE,
                                x_project_party_id      OUT NOCOPY NUMBER,
                                x_resource_id           OUT NOCOPY NUMBER,
                                x_assignment_id         OUT NOCOPY NUMBER,
                                x_wf_type               OUT NOCOPY VARCHAR2,
                                x_wf_item_type          OUT NOCOPY VARCHAR2,
                                x_wf_process            OUT NOCOPY VARCHAR2,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2) IS


  l_project_role_id		  NUMBER; --used here
  l_key_members			  pa_project_pub.project_role_tbl_type; --used here
  l_debug_mode    		  varchar2(1) := 'N';
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
BEGIN

   SAVEPOINT create_project_party_wrp;
   if p_debug_mode = 'Y' then
       l_debug_mode:='Y';
   end if;
   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');

   if (l_debug_mode = 'Y') then
       pa_debug.debug('create_project_party-wrp: Begin');
   end if;

   if (l_debug_mode = 'Y') then
       pa_debug.debug('Create_project_party: Initializing message stack.');
   end if;
   IF l_debug_mode = 'Y' THEN
       pa_debug.set_curr_function( p_function     => 'CREATE_PROJECT_PARTY_WRP'
                                  ,p_debug_mode   =>  l_debug_mode);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;

   /* get the project_role_id */
   if p_project_role_id is null or p_project_role_id = FND_API.G_MISS_NUM then
       l_project_role_id := pa_project_parties_utils.get_project_role_id(p_project_role_type,p_calling_module);
   else
       l_project_role_id := p_project_role_id;
   end if;

   IF l_project_role_id = 1 then

   /* call pa_project_check_pvt.check_for_one_manager_pvt */
   /*
   If a project manager is sought to be created, then check whether
   there is already a project manager for the project. If so, check
   whether this is the same person. If not,then check the start and
   end dates for the existing manager and update the end date of the existing manager to either
   (a) new manager's start date -1 or (b) sysdate -1
   (being done in check_for_one_manager);
   */


      l_key_members(1).project_role_type := 'PROJECT MANAGER';
      l_key_members(1).person_id := p_resource_source_id;
      l_key_members(1).start_date := p_start_date_active;
      l_key_members(1).end_date := p_end_date_active;

      pa_project_check_pvt.check_for_one_manager_pvt
      (p_project_id       => p_project_id
      ,p_person_id        => p_resource_source_id
      ,p_key_members      => l_key_members
      ,p_start_date       => p_start_date_active
      ,p_end_date         => p_end_date_active
      ,p_return_status    => x_return_status);

      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;
   End If; --If project_role_id = 1
 /* calling CREATE_PROJECT_PARTY unconditionally for all the key members
 This flow is similar to AMG API. Instead of calling add_key_members , we
 are directly calling create_project_party, after checking if a PM is being
 terminated */
PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
            p_validate_only =>  p_validate_only
           , p_object_id =>  p_object_id
          , p_OBJECT_TYPE =>  p_OBJECT_TYPE
          , p_project_role_id => p_project_role_id
          , p_project_role_type => p_project_role_type
          , p_RESOURCE_TYPE_ID => p_RESOURCE_TYPE_ID
          , p_resource_source_id =>  p_resource_source_id
          , p_resource_name => p_resource_name
          , p_start_date_active =>  p_start_date_active
          , p_scheduled_flag =>  p_scheduled_flag
          , p_calling_module =>  p_calling_module
          , p_project_id => p_project_id -- p_project_id
          , p_project_end_date =>  p_project_end_date
          , p_end_date_active =>  p_end_date_active
	  , p_mgr_validation_type => p_mgr_validation_type
          , x_project_party_id => x_project_party_id  -- x_project_party_id
          , x_resource_id => x_resource_id      -- x_resource_id
          , x_wf_item_type     => x_wf_item_type
          , x_wf_type          => x_wf_type
          , x_wf_process       => x_wf_process
          , x_assignment_id    => x_assignment_id
          , x_return_status => x_return_status  -- x_return_status
          , x_msg_count => x_msg_count          -- x_msg_count
          , x_msg_data => x_msg_data            -- x_msg_data
                             );
          IF    (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                x_return_status := x_return_status;
                x_msg_count := x_msg_count;
               raise  FND_API.G_EXC_ERROR;
          END IF;
 /* end if call create_project_party */
  IF l_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      rollback to create_project_party_wrp;

      --setting all the OUT and IN OUT parameters to null
				x_return_status	       :=	FND_API.G_RET_STS_ERROR;
				p_end_date_active      :=	null;
                                x_project_party_id     :=	null;
                                x_resource_id          :=	null;
                                x_assignment_id        :=	null;
                                x_wf_type              :=	null;
                                x_wf_item_type         :=	null;
                                x_wf_process           :=	null;
				x_msg_count	       :=	Fnd_Msg_Pub.count_msg;


				IF x_msg_count = 1 AND x_msg_data IS NULL
				THEN
				  Pa_Interface_Utils_Pub.get_messages
				      ( p_encoded        => Fnd_Api.G_TRUE
				      , p_msg_index      => 1
				      , p_msg_count      => x_msg_count
				      , p_msg_data       => l_msg_data
				      , p_data           => l_data
				      , p_msg_index_out  => l_msg_index_out);
				  x_msg_data := l_data;
				END IF;
 WHEN OTHERS THEN
    rollback to create_project_party_wrp;

    --setting all the OUT and IN OUT parameters to null
				x_return_status	       :=	fnd_api.g_ret_sts_unexp_error;
				p_end_date_active      :=	null;
                                x_project_party_id     :=	null;
                                x_resource_id          :=	null;
                                x_assignment_id        :=	null;
                                x_wf_type              :=	null;
                                x_wf_item_type         :=	null;
                                x_wf_process           :=	null;
				x_msg_count	       :=	1;
				x_msg_data	       :=	SUBSTRB(SQLERRM,1,240);

    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => 'CREATE_PROJECT_PARTY_WRP',
                            p_error_text => x_msg_data);

 END CREATE_PROJECT_PARTY_WRP;

end;


/
