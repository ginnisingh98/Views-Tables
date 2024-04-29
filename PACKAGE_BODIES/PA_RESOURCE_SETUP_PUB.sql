--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_SETUP_PUB" AS
/* $Header: PARESTPB.pls 120.2 2006/06/30 21:50:31 ramurthy noship $ */


-- API name                      : update_addition_staff_info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
li_message_level NUMBER := 1;

PROCEDURE UPDATE_ADDITIONAL_STAFF_INFO
( p_api_version                  IN NUMBER     := 1.0
 ,p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE
 ,p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 ,p_project_id                   IN NUMBER
 ,p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM
 ,p_calendar_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
 ,p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM
 ,p_adv_action_set_id            IN NUMBER     := FND_API.G_MISS_NUM
 ,p_adv_action_set_name          IN VARCHAR2   := FND_API.G_MISS_CHAR
 ,p_start_adv_action_set_flag    IN VARCHAR2   := FND_API.G_MISS_CHAR
 ,p_record_version_number        IN NUMBER
 ,p_initial_team_template_id     IN NUMBER     := FND_API.G_MISS_NUM  -- added for bug 2607631
 ,p_proj_req_res_format_id       IN NUMBER     := FND_API.G_MISS_NUM
 ,p_proj_asgmt_res_format_id     IN NUMBER     := FND_API.G_MISS_NUM
 ,p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_api_name           CONSTANT VARCHAR(30) := 'update_addition_staff_info';
l_api_version        CONSTANT NUMBER      := 1.0;
l_calendar_id              NUMBER := FND_API.G_MISS_NUM;
l_return_status            VARCHAR2(250);
l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_adv_action_set_id        NUMBER := FND_API.G_MISS_NUM;
l_debug_mode               VARCHAR2(10);

BEGIN
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_addition_staff_info;
   END IF;

IF l_debug_mode = 'Y' THEN
   pa_debug.init_err_stack('PA_RESOURCE_SETUP_PUB.update_addition_staff_info');
   PA_DEBUG.write_log (x_module => 'pa.plsql.PA_RESOURCE_SETUP_PUB.update_addition_staff_info.begin'
       ,x_msg => 'Beginning of PA_RESOURCE_SETUP_PUB.update_addition_staff_info'
       ,x_log_level   => 5);
END IF;

   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_mode = 'Y' THEN
   pa_debug.write(x_module => 'pa.plsql.PA_RESOURCE_SETUP_PUB.update_addition_staff_info'
		 ,x_msg         => 'adv_id='||p_adv_action_set_id||
				   ' adv_name='||p_adv_action_set_name||
				   ' req_format='||p_proj_req_res_format_id||
				   ' asgmt_format='||p_proj_asgmt_res_format_id
   	         ,x_log_level   => li_message_level);
END IF;


   -- Validate Calendar
   IF (p_calendar_id is not null AND p_calendar_id <> FND_API.G_MISS_NUM) OR
      (p_calendar_name is not null AND p_calendar_name <> FND_API.G_MISS_CHAR)
   THEN

     PA_CALENDAR_UTILS.CHECK_CALENDAR_NAME_OR_ID
      ( p_calendar_id         => p_calendar_id
       ,p_calendar_name       => p_calendar_name
       ,p_check_id_flag       => PA_STARTUP.G_Check_ID_Flag
       ,x_calendar_id         => l_calendar_id
       ,x_return_status       => l_return_status
       ,x_error_message_code  => l_error_msg_code);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_return_status := l_return_status;
     END IF;

    END IF;

   -- Validate Advertisement Action Set
   IF (p_adv_action_set_id is not null AND p_adv_action_set_id <> FND_API.G_MISS_NUM) OR
      (p_adv_action_set_name is not null AND p_adv_action_set_name <> FND_API.G_MISS_CHAR)
   THEN

       PA_ACTION_SET_UTILS.Check_Action_Set_Name_or_Id(
         p_action_set_id        => p_adv_action_set_id
        ,p_action_set_name      => p_adv_action_set_name
        ,p_action_set_type_code => 'ADVERTISEMENT'
        ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
        ,p_date                 => sysdate
        ,x_action_set_id        => l_adv_action_set_id
        ,x_return_status        => l_return_status
        ,x_error_message_code   => l_error_msg_code
       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_return_status := l_return_status;
     END IF;

   END IF;


   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     PA_RESOURCE_SETUP_PVT.UPDATE_ADDITIONAL_STAFF_INFO
     (
      p_commit                       => FND_API.G_FALSE,
      p_validate_only                => p_validate_only,
      p_project_id                   => p_project_id,
      p_calendar_id                  => l_calendar_id,
      p_role_list_id                 => p_role_list_id,
      p_adv_action_set_id            => l_adv_action_set_id,
      p_start_adv_action_set_flag    => p_start_adv_action_set_flag,
      p_record_version_number        => p_record_version_number,
      p_initial_team_template_id     => p_initial_team_template_id, -- added for bug 2607631
      p_proj_req_res_format_id       => p_proj_req_res_format_id,
      p_proj_asgmt_res_format_id     => p_proj_asgmt_res_format_id,
      p_max_msg_count                => p_max_msg_count,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data);

   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   If l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     If l_msg_count = 1 THEN
       pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count ,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );
        x_msg_data := l_data;
     End if;
     RAISE  FND_API.G_EXC_ERROR;
   End if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO update_addition_staff_info;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO update_addition_staff_info;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RESOURCE_SETUP_PUB',
                              p_procedure_name => 'UPDATE_ADDITIONAL_STAFF_INFO',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));

    raise;

END UPDATE_ADDITIONAL_STAFF_INFO;


END PA_RESOURCE_SETUP_PUB;

/
