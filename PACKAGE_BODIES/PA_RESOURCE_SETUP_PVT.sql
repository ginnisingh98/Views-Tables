--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_SETUP_PVT" AS
/* $Header: PARESTVB.pls 120.2 2006/06/30 21:51:02 ramurthy noship $ */


-- API name                      : update_addition_staff_info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
li_message_level NUMBER := 1;


PROCEDURE UPDATE_ADDITIONAL_STAFF_INFO
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_adv_action_set_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_adv_action_set_flag    IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_initial_team_template_id     IN NUMBER     := FND_API.G_MISS_NUM    , -- added for bug 2607631
 p_proj_req_res_format_id       IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_proj_asgmt_res_format_id     IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS


l_error_msg_code           VARCHAR2(250);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(250);
l_data                     VARCHAR2(250);
l_msg_index_out            NUMBER;
l_record_version_number    PA_PROJECTS_ALL.RECORD_VERSION_NUMBER%TYPE;
l_dummy                    VARCHAR2(1);
l_debug_mode               VARCHAR2(10);

BEGIN

l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

--pr_msg('Begin '||p_initial_team_template_id);
--pr_msg('Begin '||p_role_list_id);

IF l_debug_mode = 'Y' THEN
   pa_debug.write(x_module => 'pa.plsql.PA_RESOURCE_SETUP_PVT.update_addition_staff_info'
		 ,x_msg    => 'adv_id='||p_adv_action_set_id||
			      ' req_format='||p_proj_req_res_format_id||
			      ' asgmt_format='||p_proj_asgmt_res_format_id
	         ,x_log_level   => li_message_level);
END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_addition_staff_info;
   END IF;

   if p_validate_only <> FND_API.G_TRUE then
     BEGIN

         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number
           FOR UPDATE OF record_version_number NOWAIT;

         EXCEPTION WHEN TIMEOUT_ON_RESOURCE THEN

               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;

           WHEN NO_DATA_FOUND THEN

               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
               x_return_status := 'E' ;

            WHEN OTHERS THEN

              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              ELSE
                 RAISE;
              END IF;

      END;
   else

     BEGIN
         SELECT 'x' INTO l_dummy
         FROM  pa_projects
         WHERE project_id             = p_project_id
           AND record_version_number  = p_record_version_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               x_msg_data := 'PA_XC_RECORD_CHANGED';
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              Else
                 raise;
              END IF;
        END;
    end if;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

-- write your program logic from here


  IF NOT FND_API.TO_BOOLEAN(p_validate_only) THEN

    -- update the project table
      UPDATE pa_projects_all
      SET record_version_number = record_version_number + 1
         ,calendar_id           = decode(p_calendar_id, FND_API.G_MISS_NUM, calendar_id, p_calendar_id)
         ,role_list_id          = decode(p_role_list_id, FND_API.G_MISS_NUM, role_list_id, p_role_list_id)
         ,adv_action_set_id     = decode(p_adv_action_set_id, FND_API.G_MISS_NUM, adv_action_set_id, p_adv_action_set_id)
         ,start_adv_action_set_flag = decode(p_start_adv_action_set_flag, FND_API.G_MISS_CHAR, start_adv_action_set_flag, p_start_adv_action_set_flag)
	 ,initial_team_template_id  = DECODE(p_initial_team_template_id, FND_API.G_MISS_NUM, initial_team_template_id, p_initial_team_template_id) -- added for bug 2607631
         ,proj_req_res_format_id    = DECODE(p_proj_req_res_format_id, FND_API.G_MISS_NUM, proj_req_res_format_id, p_proj_req_res_format_id)
         ,proj_asgmt_res_format_id  = DECODE(p_proj_asgmt_res_format_id, FND_API.G_MISS_NUM, proj_asgmt_res_format_id, p_proj_asgmt_res_format_id)
      WHERE project_id = p_project_id;
  END IF;

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

END PA_RESOURCE_SETUP_PVT;

/
