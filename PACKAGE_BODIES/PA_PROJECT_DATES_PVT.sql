--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_DATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_DATES_PVT" AS
/* $Header: PARMPDVB.pls 120.4 2008/06/26 09:55:37 jravisha ship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECT_DATES_PVT';


-- API name		: Update_Project_Dates
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_date_type                     IN VARCHAR2   Required
-- p_start_date                    IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_finish_date                   IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_PROJECT_DATES
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_date_type                     IN VARCHAR2
  ,p_start_date                    IN DATE       := FND_API.G_MISS_DATE
  ,p_finish_date                   IN DATE       := FND_API.G_MISS_DATE
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_dummy                         VARCHAR2(1);
   l_start_date                    DATE;
   l_finish_date                   DATE;
   l_duration_days                 NUMBER;
   l_duration                      NUMBER;
   l_calendar_id                   NUMBER;

   /*Bug 6860603*/
   l_validate 							 varchar(100);
   l_start_date_status	              	 varchar(100);
   l_end_date_status					 varchar(100);
   l_version_enabled                     varchar(100);
   validate							 varchar(100);
   l_alwd_start_date               DATE;
   l_alwd_end_date                 DATE;
   l_res_min_date          DATE;
   l_res_max_date          DATE;

   CURSOR get_cal_id IS
     select calendar_id
       from pa_projects_all
      where project_id = p_project_id;

BEGIN
   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PVT.Update_Project_Dates BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_project_dates_pvt;
   end if;

   if p_validate_only <> FND_API.G_TRUE then
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_projects_all
         WHERE project_id = p_project_id
         AND record_version_number = p_record_version_number
         FOR UPDATE OF record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';
            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            if SQLCODE = -54 then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
               raise;
            end if;
      END;
   else
      BEGIN
         SELECT 'x' INTO l_dummy
         FROM pa_projects_all
         WHERE project_id = p_project_id
         AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            if p_calling_module = 'FORM' then
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                    p_msg_name       => 'FORM_RECORD_CHANGED');
               l_msg_data := 'FORM_RECORD_CHANGED';            else
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_RECORD_CHANGED');
               l_msg_data := 'PA_XC_RECORD_CHANGED';
            end if;
         when OTHERS then
            raise;
      END;
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_start_date = FND_API.G_MISS_DATE then
      l_start_date := NULL;
   else
      l_start_date := p_start_date;
   end if;

   if p_finish_date = FND_API.G_MISS_DATE then
      l_finish_date := NULL;
   else
      l_finish_date := p_finish_date;
   end if;

   if(p_date_type IN ('BASELINE', 'ACTUAL', 'SCHEDULED')) then
     -- Bug 3657808 Remove duration calculation using calendar
     -- Duration is in days
--
     l_duration := trunc(l_finish_date) - trunc(l_start_date) + 1;
--
     -- Added to calculate duration
/*     OPEN get_cal_id;
     FETCH get_cal_id INTO l_calendar_id;
     CLOSE get_cal_id;

     PA_DURATION_UTILS.GET_DURATION(
      p_calendar_id =>     l_calendar_id
     ,p_start_date =>      l_start_date
     ,p_end_date =>        l_finish_date
     ,x_duration_days =>   l_duration_days
     ,x_duration_hours =>  l_duration
     ,x_return_status =>   l_return_status
     ,x_msg_count =>       l_msg_count
     ,x_msg_data =>        l_msg_data );

     IF (l_return_status <> 'S') THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         IF x_msg_count = 1 THEN
           x_msg_data := l_msg_data;
         END IF;
       END IF;

       RAISE FND_API.G_EXC_ERROR;
     END IF;*/

   END IF;

   if p_validate_only <> FND_API.G_TRUE then
      if p_date_type = 'TRANSACTION' then

      /*Bug 6860603 Begin*/

      /*Bug 7203870*/
       l_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');
       select Upper(PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_project_id))
       into l_version_enabled
       from dual;


      IF (l_validate='Y' AND l_version_enabled='Y') then
      PA_PROJECT_DATES_UTILS.WPP_Validate_Project_Dates	(p_project_id => p_project_id,
 														p_start_date => l_start_date,
 														p_end_date => l_finish_date,
 														p_alwd_start_date => l_alwd_start_date,
 														p_alwd_end_date => l_alwd_end_date,
 														p_res_min_date => l_res_min_date,
 														p_res_max_date=> l_res_max_date,
  														x_validate => validate,
  														x_start_date_status=>l_start_date_status,
  														x_end_date_status => l_end_date_status);

    IF (l_start_date_status='I') then
 			PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PJR_ASG_DATE_END_ERROR',
                               p_token1 => 'DATE1',
                               P_value1 => l_alwd_start_date,
                               p_token2 => 'DATE2',
                               P_value2 => l_res_min_date,
                               p_token3 => 'DATE3',
                               P_value3 => l_res_max_date
                              );

 	end if;

 	IF (l_end_date_status='I') then

 			PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PJR_ASG_DATE_START_ERROR',
                               p_token1 => 'DATE1',
                               P_value1 => l_alwd_end_date,
                               p_token2 => 'DATE2',
                               P_value2 => l_res_min_date,
                               p_token3 => 'DATE3',
                               P_value3 => l_res_max_date
                              );

   end if;

   IF(l_start_date_status='I' OR l_end_date_status='I') then
   Raise FND_API.G_EXC_ERROR;
   end if;

   End if;  -- PA_VALIDATE_ASSIGN_DATES='Y' and version_enabled='Y'
      /*Bug 6860603 End*/

         UPDATE PA_PROJECTS_ALL
         SET start_date                   = l_start_date,
             completion_date              = l_finish_date,
             last_update_date             = sysdate,
             record_version_number        = p_record_version_number + 1,
             last_updated_by              = fnd_global.user_id,
             last_update_login            = fnd_global.login_id
         WHERE project_id = p_project_id;
      elsif p_date_type = 'TARGET' then
         UPDATE PA_PROJECTS_ALL
         SET target_start_date           = l_start_date,
             target_finish_date          = l_finish_date,
             last_update_date             = sysdate,
             record_version_number        = p_record_version_number + 1,
             last_updated_by              = fnd_global.user_id,
             last_update_login            = fnd_global.login_id
         WHERE project_id = p_project_id;
      elsif p_date_type = 'ACTUAL' then
         UPDATE PA_PROJECTS_ALL
         SET actual_start_date            = l_start_date,
             actual_finish_date           = l_finish_date,
             actual_duration              = l_duration,
             last_update_date             = sysdate,
             record_version_number        = p_record_version_number + 1,
             last_updated_by              = fnd_global.user_id,
             last_update_login            = fnd_global.login_id
         WHERE project_id = p_project_id;
      elsif p_date_type = 'BASELINE' then
         UPDATE PA_PROJECTS_ALL
         SET baseline_start_date          = l_start_date,
             baseline_finish_date         = l_finish_date,
             baseline_duration            = l_duration,
             baseline_as_of_date          = sysdate,
             last_update_date             = sysdate,
             record_version_number        = p_record_version_number + 1,
             last_updated_by              = fnd_global.user_id,
             last_update_login            = fnd_global.login_id
         WHERE project_id = p_project_id;
      elsif p_date_type = 'SCHEDULED' then
         UPDATE PA_PROJECTS_ALL
         SET scheduled_start_date         = l_start_date,
             scheduled_finish_date        = l_finish_date,
             scheduled_duration           = l_duration,
             scheduled_as_of_date         = sysdate,
             last_update_date             = sysdate,
             record_version_number        = p_record_version_number + 1,
             last_updated_by              = fnd_global.user_id,
             last_update_login            = fnd_global.login_id
         WHERE project_id = p_project_id;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PVT.Update_Project_Dates END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PVT',
                              p_procedure_name => 'Update_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PVT',
                              p_procedure_name => 'Update_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJECT_DATES;


END PA_PROJECT_DATES_PVT;

/
