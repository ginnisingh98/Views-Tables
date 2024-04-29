--------------------------------------------------------
--  DDL for Package Body PA_TEAM_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TEAM_TEMPLATES_PUB" AS
/*$Header: PARTPUBB.pls 120.2 2005/08/23 04:31:40 sunkalya noship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
PROCEDURE Execute_Apply_Team_Template
(p_team_template_id                IN     pa_team_templates.team_template_id%TYPE
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_apply                           IN     VARCHAR2                                    := 'Y'
,p_api_version                     IN     NUMBER                                      := 1.0
,p_init_msg_list                   IN     VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_count             NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Execute_Apply_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_EXEC_APPLY_TEAM_TEMP;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_apply_team_template'
                     ,x_msg         => 'Beginning of Execute_Apply_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  --assign team template ids to be applied to the global pl/sql table.
  l_count := g_team_template_id_tbl.COUNT;

  g_team_template_id_tbl(l_count+1).team_template_id := p_team_template_id;

  --If p_apply = Y then all of the team_template_ids to be copied have been
  --loaded into the pl/sql table, so call Apply_Team_Template

  IF p_apply = 'Y' THEN

     --Log Message
     IF (P_DEBUG_MODE = 'Y') THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_apply_team_template'
                        ,x_msg         => 'Calling Apply_Team_Template'
                        ,x_log_level   => 5);
     END IF;

     PA_TEAM_TEMPLATES_PUB.Apply_Team_Template(
                                 p_team_template_id_tbl => g_team_template_id_tbl
                                ,p_project_id => p_project_id
                                ,p_project_start_date => p_project_start_date
                                ,p_team_start_date => p_team_start_date
                                ,p_use_project_location => p_use_project_location
                                ,p_project_location_id => p_project_location_id
                                ,p_use_project_calendar => p_use_project_calendar
                                ,p_project_calendar_id => p_project_calendar_id
                                ,x_return_status => x_return_status
                                ,x_msg_count => x_msg_count
                                ,x_msg_data => x_msg_data);

   --clear global pl/sql table
   g_team_template_id_tbl.DELETE;

   END IF;  --p_apply='Y'

   -- Reset the error stack when returning to the calling program
   PA_DEBUG.Reset_Err_Stack;

   EXCEPTION
     WHEN OTHERS THEN

         --clear global pl/sql table
          g_team_template_id_tbl.DELETE;

         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO ASG_PUB_EXEC_APPLY_TEAM_TEMP;
         END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PUB.Execute_Apply_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Execute_Apply_Team_Template;

PROCEDURE Apply_Team_Template
(p_team_template_id_tbl            IN     team_template_id_tbl
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_api_version                     IN     NUMBER                                      := 1.0
,p_init_msg_list                   IN     VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_index_out             NUMBER;

l_project_calendar_id       pa_projects_all.calendar_id%TYPE;
l_project_location_id       pa_projects_all.location_id%TYPE;
l_unassigned_time_proj      VARCHAR2(1);
l_admin_proj                VARCHAR2(1);

-- cursor to get location and calendar for validation
CURSOR get_project_location_and_cal IS
SELECT calendar_id, location_id
  FROM pa_projects_all
 WHERE project_id = p_project_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Apply_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_APPLY_TEAM_TEMPLATE;
  END IF;

  --clear globals used to put the team template name / role name in error messages.
  pa_assignment_utils.g_team_template_id := NULL;
  pa_assignment_utils.g_team_template_name_token := NULL;
  pa_assignment_utils.g_team_role_name_token := NULL;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.apply_team_template'
                     ,x_msg         => 'Beginning of Apply_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  --call private API to apply the team template
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.apply_team_template'
                     ,x_msg         => 'calling PA_TEAM_TEMPLATES_PVT.Apply_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  --validate that the project is not an unassigned time project.
  --assignments are not allowed on unassigned time projects
  l_unassigned_time_proj := PA_PROJECT_UTILS.is_unassigned_time_project(p_project_id);
  IF l_unassigned_time_proj = 'Y' THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NO_TEMPLATE_UNASGN_TIME_PRJ');
  END IF;

  --validate that the project is not an admin project.
  --only admin assigments are allowed on admin projects
  l_admin_proj := PA_PROJECT_UTILS.Is_Admin_Project(p_project_id);
  IF l_admin_proj = 'Y' THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NO_TEMPLATE_ADMIN_PRJ');
  END IF;

  -- validate project location id and calendar id
  l_project_calendar_id := p_project_calendar_id;
  l_project_location_id := p_project_location_id;

  --if p_use_project_location = Y or p_use_project_calendar='Y' and the values are not
  --passed in to the API then get the project calendar/location.
  IF (p_use_project_location ='Y' AND p_project_location_id IS NULL) OR
     (p_use_project_calendar='Y' AND p_project_calendar_id IS NULL) THEN

     OPEN  get_project_location_and_cal;
     FETCH  get_project_location_and_cal INTO l_project_calendar_id, l_project_location_id;
     CLOSE  get_project_location_and_cal;

  END IF;

  --validate that a project calendar is defined if p_use_project_calendar='Y'
  IF p_use_project_calendar ='Y' AND l_project_calendar_id IS NULL THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_CAL_NOT_DEFINED');

  END IF;

  --validate that a project location is defined if p_use_project_location='Y'
  IF p_use_project_location ='Y' AND l_project_location_id IS NULL THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_LOC_NOT_DEFINED');

  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 0 THEN

    PA_TEAM_TEMPLATES_PVT.Start_Apply_Team_Template_WF(p_team_template_id_tbl => p_team_template_id_tbl
                                                    ,p_project_id => p_project_id
                                                    ,p_project_start_date => p_project_start_date
                                                    ,p_team_start_date => p_team_start_date
                                                    ,p_use_project_location => p_use_project_location
                                                    ,p_project_location_id => p_project_location_id
                                                    ,p_use_project_calendar => p_use_project_calendar
                                                    ,p_project_calendar_id => p_project_calendar_id
                                                    ,x_return_status => x_return_status);

  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If errors exist then set the x_return_status to 'E'

  IF x_msg_count >0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  --clear globals used to put the team template name / role name in error messages.
  pa_assignment_utils.g_team_template_id := NULL;
  pa_assignment_utils.g_team_template_name_token := NULL;
  pa_assignment_utils.g_team_role_name_token := NULL;

  EXCEPTION
    WHEN OTHERS THEN

      --clear globals used to put the team template name / role name in error messages.
      pa_assignment_utils.g_team_template_id := NULL;
      pa_assignment_utils.g_team_template_name_token := NULL;
      pa_assignment_utils.g_team_role_name_token := NULL;

      IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_APPLY_TEAM_TEMPLATE;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PUB.Apply_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Apply_Team_Template;


PROCEDURE Execute_Create_Team_Template
(p_team_template_name              IN     pa_team_templates.team_template_name%TYPE
 ,p_description                    IN     pa_team_templates.description%TYPE           := FND_API.G_MISS_CHAR
 ,p_start_date_active              IN     pa_team_templates.start_date_active%TYPE
 ,p_end_date_active                IN     pa_team_templates.end_date_active%TYPE       := FND_API.G_MISS_DATE
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_calendar_id                    IN     pa_team_templates.calendar_id%TYPE           := FND_API.G_MISS_NUM
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_work_type_id                   IN     pa_team_templates.work_type_id%TYPE          := FND_API.G_MISS_NUM
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                   IN     pa_team_templates.role_list_id%TYPE          := FND_API.G_MISS_NUM
 ,p_team_start_date                IN     pa_team_templates.team_start_date%TYPE
 ,p_attribute_category             IN     pa_team_templates.attribute_category%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute1                     IN     pa_team_templates.attribute1%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute2                     IN     pa_team_templates.attribute2%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute3                     IN     pa_team_templates.attribute3%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute4                     IN     pa_team_templates.attribute4%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute5                     IN     pa_team_templates.attribute5%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute6                     IN     pa_team_templates.attribute6%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute7                     IN     pa_team_templates.attribute7%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute8                     IN     pa_team_templates.attribute8%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute9                     IN     pa_team_templates.attribute9%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute10                    IN     pa_team_templates.attribute10%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute11                    IN     pa_team_templates.attribute11%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute12                    IN     pa_team_templates.attribute12%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute13                    IN     pa_team_templates.attribute13%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute14                    IN     pa_team_templates.attribute14%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute15                    IN     pa_team_templates.attribute15%TYPE           := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_team_template_rec   team_template_rec;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Execute_Create_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_EXEC_CREATE_TEAM_TEMP;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_create_team_template.begin'
                     ,x_msg         => 'Beginning of Execute_Create_Team_Template'
                     ,x_log_level   => 5);
  END IF;


  --Assign scalar parameters to the team template record.

  l_team_template_rec.team_template_name        := p_team_template_name;
  l_team_template_rec.description               := p_description;
  l_team_template_rec.start_date_active         := p_start_date_active;
  l_team_template_rec.end_date_active           := p_end_date_active;
  l_team_template_rec.calendar_id               := p_calendar_id;
  l_team_template_rec.work_type_id              := p_work_type_id;
  l_team_template_rec.role_list_id              := p_role_list_id;
  l_team_template_rec.team_start_date           := p_team_start_date;
  l_team_template_rec.attribute_category        := p_attribute_category;
  l_team_template_rec.attribute1                := p_attribute1;
  l_team_template_rec.attribute2                := p_attribute2;
  l_team_template_rec.attribute3                := p_attribute3;
  l_team_template_rec.attribute4                := p_attribute4;
  l_team_template_rec.attribute5                := p_attribute5;
  l_team_template_rec.attribute6                := p_attribute6;
  l_team_template_rec.attribute7                := p_attribute7;
  l_team_template_rec.attribute8                := p_attribute8;
  l_team_template_rec.attribute9                := p_attribute9;
  l_team_template_rec.attribute10               := p_attribute10;
  l_team_template_rec.attribute11               := p_attribute11;
  l_team_template_rec.attribute12               := p_attribute12;
  l_team_template_rec.attribute13               := p_attribute13;
  l_team_template_rec.attribute14               := p_attribute14;
  l_team_template_rec.attribute15               := p_attribute15;

 --Log Message
 IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_create_team_template.begin'
                     ,x_msg         => 'Calling Create_Team_Template'
                     ,x_log_level   => 5);
  END IF;


  PA_TEAM_TEMPLATES_PUB.Create_Team_Template
     (p_team_template_rec           => l_team_template_rec
     ,p_calendar_name               => p_calendar_name
     ,p_work_type_name              => p_work_type_name
     ,p_role_list_name              => p_role_list_name
     ,p_api_version                 => p_api_version
     ,p_init_msg_list               => p_init_msg_list
     ,p_commit                      => p_commit
     ,p_max_msg_count               => p_max_msg_count
     ,x_team_template_id            => x_team_template_id
     ,x_return_status               => x_return_status
     ,x_msg_count                   => x_msg_count
     ,x_msg_data                    => x_msg_data);


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_EXEC_CREATE_TEAM_TEMP;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PUB.Execute_Create_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Execute_Create_Team_Template;


PROCEDURE Create_Team_Template
( p_team_template_rec              IN     team_template_rec
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FAlSE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_team_template_rec     team_template_rec;
-- added for bug: 4537865
l_new_calendar_id  pa_team_templates.calendar_id%TYPE;
l_new_work_type_id  pa_team_templates.work_type_id%TYPE;
l_new_role_list_id pa_team_templates.role_list_id%TYPE;
-- added for bug: 4537865
l_return_status         VARCHAR2(1);
l_error_message_code    fnd_new_messages.message_name%TYPE;
l_msg_index_out         NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Create_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_CREATE_TEAM_TEMPLATE;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.Create_Team_Template.begin'
                     ,x_msg         => 'Beginning of Create_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  -- Assign the record to the local variable
  l_team_template_rec := p_team_template_rec;

  --validate calendar
  IF (l_team_template_rec.calendar_id IS NOT NULL AND l_team_template_rec.calendar_id <> FND_API.G_MISS_NUM) OR (p_calendar_name IS NOT NULL and p_calendar_name <> FND_API.G_MISS_CHAR) THEN

     PA_CALENDAR_UTILS.Check_Calendar_Name_Or_Id( p_calendar_id        => l_team_template_rec.calendar_id
                                                 ,p_calendar_name      => p_calendar_name
                                                 ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                               --,x_calendar_id        => l_team_template_rec.calendar_id	* Bug: 4537865
						 ,x_calendar_id	       => l_new_calendar_id			-- Bug: 4537865
                                                 ,x_return_status      => l_return_status
                                                 ,x_error_message_code => l_error_message_code );
     -- added for Bug fix: 4537865
     IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_team_template_rec.calendar_id := l_new_calendar_id;
     END IF;
     -- added for Bug fix: 4537865
     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
     END IF;

  END IF; -- validate calendar



  --validate work type
  IF (l_team_template_rec.work_type_id IS NOT NULL AND l_team_template_rec.work_type_id <> FND_API.G_MISS_NUM) OR (p_work_type_name IS NOT NULL AND p_work_type_name <> FND_API.G_MISS_CHAR) THEN

     PA_WORK_TYPE_UTILS.Check_Work_Type_Name_Or_Id( p_work_type_id       => l_team_template_rec.work_type_id
                                                   ,p_name               => p_work_type_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                 --,x_work_type_id       => l_team_template_rec.work_type_id	* Bug: 4537865
						   ,x_work_type_id	 => l_new_work_type_id			-- Bug: 4537865
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
      -- added for Bug: 4537865
      IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      l_team_template_rec.work_type_id := l_new_work_type_id;
      END IF;
      -- added for Bug: 4537865

      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
      END IF;

   END IF; --validate work type

  --validate role list
  IF (l_team_template_rec.role_list_id IS NOT NULL AND l_team_template_rec.role_list_id <> FND_API.G_MISS_NUM) OR (p_role_list_name IS NOT NULL AND p_role_list_name <> FND_API.G_MISS_CHAR) THEN

     PA_ROLE_LIST_UTILS.Check_Role_List_Name_Or_Id( p_role_list_id       => l_team_template_rec.role_list_id
                                                   ,p_role_list_name     => p_role_list_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                 --,x_role_list_id       => l_team_template_rec.role_list_id	* Bug: 4537865
						   ,x_role_list_id	 => l_new_role_list_id			--Bug: 4537865
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
      -- added for Bug: 4537865
      IF  l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
	l_team_template_rec.role_list_id := l_new_role_list_id;
      END IF;
       -- added for Bug: 4537865
      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
      END IF;

  END IF;  --validate role list

  PA_TEAM_TEMPLATES_PVT.Create_Team_Template( p_team_template_rec => l_team_template_rec
                                             ,p_commit => p_commit
                                             ,p_validate_only => p_validate_only
                                             ,x_team_template_id => x_team_template_id
                                             ,x_return_status => x_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If errors exist then set the x_return_status to 'E'

  IF x_msg_count >0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;


  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_CREATE_TEAM_TEMPLATE;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATES_PUB.Create_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
--
END Create_Team_Template;



PROCEDURE Execute_Update_Team_Template
( p_team_template_id               IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number          IN     pa_team_templates.record_version_number%TYPE
 ,p_team_template_name             IN     pa_team_templates.team_template_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_description                    IN     pa_team_templates.description%TYPE           := FND_API.G_MISS_CHAR
 ,p_start_date_active              IN     pa_team_templates.start_date_active%TYPE  := FND_API.G_MISS_DATE
 ,p_end_date_active                IN     pa_team_templates.end_date_active%TYPE    := FND_API.G_MISS_DATE
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_calendar_id                    IN     pa_team_templates.calendar_id%TYPE           := FND_API.G_MISS_NUM
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_work_type_id                   IN     pa_team_templates.work_type_id%TYPE          := FND_API.G_MISS_NUM
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                   IN     pa_team_templates.role_list_id%TYPE          := FND_API.G_MISS_NUM
 ,p_team_start_date            IN     pa_team_templates.team_start_date%TYPE       := FND_API.G_MISS_DATE
 ,p_workflow_in_progress_flag      IN     pa_team_templates.workflow_in_progress_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_attribute_category             IN     pa_team_templates.attribute_category%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute1                     IN     pa_team_templates.attribute1%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute2                     IN     pa_team_templates.attribute2%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute3                     IN     pa_team_templates.attribute3%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute4                     IN     pa_team_templates.attribute4%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute5                     IN     pa_team_templates.attribute5%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute6                     IN     pa_team_templates.attribute6%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute7                     IN     pa_team_templates.attribute7%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute8                     IN     pa_team_templates.attribute8%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute9                     IN     pa_team_templates.attribute9%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute10                    IN     pa_team_templates.attribute10%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute11                    IN     pa_team_templates.attribute11%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute12                    IN     pa_team_templates.attribute12%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute13                    IN     pa_team_templates.attribute13%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute14                    IN     pa_team_templates.attribute14%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute15                    IN     pa_team_templates.attribute15%TYPE           := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status                  OUT    NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

l_team_template_rec   team_template_rec;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Execute_Update_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_EXEC_UPDATE_TEAM_TEMP;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_update_team_template.begin'
                     ,x_msg         => 'Beginning of Execute_Update_Team_Template'
                     ,x_log_level   => 5);
  END IF;


  --Assign scalar parameters to the team template record.

  l_team_template_rec.team_template_id          := p_team_template_id;
  l_team_template_rec.record_version_number     := p_record_version_number;
  l_team_template_rec.team_template_name        := p_team_template_name;
  l_team_template_rec.description               := p_description;
  l_team_template_rec.start_date_active         := p_start_date_active;
  l_team_template_rec.end_date_active           := p_end_date_active;
  l_team_template_rec.calendar_id               := p_calendar_id;
  l_team_template_rec.work_type_id              := p_work_type_id;
  l_team_template_rec.role_list_id              := p_role_list_id;
  l_team_template_rec.team_start_date           := p_team_start_date;
  l_team_template_rec.workflow_in_progress_flag := p_workflow_in_progress_flag;
  l_team_template_rec.attribute_category        := p_attribute_category;
  l_team_template_rec.attribute1                := p_attribute1;
  l_team_template_rec.attribute2                := p_attribute2;
  l_team_template_rec.attribute3                := p_attribute3;
  l_team_template_rec.attribute4                := p_attribute4;
  l_team_template_rec.attribute5                := p_attribute5;
  l_team_template_rec.attribute6                := p_attribute6;
  l_team_template_rec.attribute7                := p_attribute7;
  l_team_template_rec.attribute8                := p_attribute8;
  l_team_template_rec.attribute9                := p_attribute9;
  l_team_template_rec.attribute10               := p_attribute10;
  l_team_template_rec.attribute11               := p_attribute11;
  l_team_template_rec.attribute12               := p_attribute12;
  l_team_template_rec.attribute13               := p_attribute13;
  l_team_template_rec.attribute14               := p_attribute14;
  l_team_template_rec.attribute15               := p_attribute15;

 --Log Message
 IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PUB.execute_create_team_template.before_calling_update_team_template'
                     ,x_msg         => 'Calling Update_Team_Template'
                     ,x_log_level   => 5);
 END IF;


  PA_TEAM_TEMPLATES_PUB.Update_Team_Template
     (p_team_template_rec           => l_team_template_rec
     ,p_calendar_name               => p_calendar_name
     ,p_work_type_name              => p_work_type_name
     ,p_role_list_name              => p_role_list_name
     ,p_api_version                 => p_api_version
     ,p_init_msg_list               => p_init_msg_list
     ,p_commit                      => p_commit
     ,p_max_msg_count               => p_max_msg_count
     ,x_return_status               => x_return_status
     ,x_msg_count                   => x_msg_count
     ,x_msg_data                    => x_msg_data);


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_EXEC_UPDATE_TEAM_TEMP;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PUB.Execute_Update_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Execute_Update_Team_Template;


PROCEDURE Update_Team_Template
( p_team_template_rec              IN     team_template_rec
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_team_template_rec          team_template_rec;
-- added for Bug: 4537865
l_new_calendar_id	     pa_team_templates.calendar_id%TYPE;
l_new_work_type_id	     pa_team_templates.work_type_id%TYPE;
l_new_role_list_id	     pa_team_templates.role_list_id%TYPE;
-- added for Bug: 4537865
l_return_status              VARCHAR2(1);
l_error_message_code         fnd_new_messages.message_name%TYPE;
l_msg_index_out              NUMBER;
l_workflow_in_progress_flag  pa_team_templates.workflow_in_progress_flag%TYPE;


CURSOR check_record_version_and_wf IS
SELECT workflow_in_progress_flag
FROM   pa_team_templates
WHERE  team_template_id = p_team_template_rec.team_template_id
AND    record_version_number = p_team_template_rec.record_version_number;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Update_Team_Templates');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_UPDATE_TEAM_TEMPLATE;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_Team_Teamplates_PUB.Update_Team_Template.begin'
                     ,x_msg         => 'Beginning of Update_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  -- Assign the record to the local variable
  l_team_template_rec := p_team_template_rec;

  --check the record version number and workflow in progress flag

  OPEN check_record_version_and_wf;

  FETCH check_record_version_and_wf INTO l_workflow_in_progress_flag;

  IF check_record_version_and_wf%NOTFOUND THEN

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

  ELSIF l_workflow_in_progress_flag = 'Y' THEN

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_TEAM_TEMPLATE_WORKFLOW');

  ELSE

     --validate calendar
     IF (l_team_template_rec.calendar_id IS NOT NULL AND l_team_template_rec.calendar_id <> FND_API.G_MISS_NUM) OR (p_calendar_name IS NOT NULL and p_calendar_name <> FND_API.G_MISS_CHAR) THEN

        PA_CALENDAR_UTILS.Check_Calendar_Name_Or_Id( p_calendar_id        => l_team_template_rec.calendar_id
                                                    ,p_calendar_name      => p_calendar_name
                                                    ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                  --,x_calendar_id        => l_team_template_rec.calendar_id		* Bug: 4537865
						    ,x_calendar_id	  => l_new_calendar_id				--Bug: 4537865
                                                    ,x_return_status      => l_return_status
                                                    ,x_error_message_code => l_error_message_code );
	-- added for Bug Fix: 4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_team_template_rec.calendar_id := l_new_calendar_id;
	END IF;
	-- added for Bug Fix: 4537865

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => l_error_message_code );
        END IF;

     END IF; -- validate calendar

     --validate work type
     IF (l_team_template_rec.work_type_id IS NOT NULL AND l_team_template_rec.work_type_id <> FND_API.G_MISS_NUM) OR (p_work_type_name IS NOT NULL AND p_work_type_name <> FND_API.G_MISS_CHAR) THEN

        PA_WORK_TYPE_UTILS.Check_Work_Type_Name_Or_Id( p_work_type_id       => l_team_template_rec.work_type_id
                                                      ,p_name               => p_work_type_name
                                                      ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                    --,x_work_type_id       => l_team_template_rec.work_type_id		* Bug: 4537865
						      ,x_work_type_id	    => l_new_work_type_id			--Bug: 4537865
                                                      ,x_return_status      => l_return_status
                                                      ,x_error_message_code => l_error_message_code );

	 -- added for bug: 4537865
	 IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	 l_team_template_rec.work_type_id := l_new_work_type_id;
	 END IF;
	 -- added for bug: 4537865
         IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => l_error_message_code );
         END IF;

      END IF; --validate work type

     --validate role list
     IF (l_team_template_rec.role_list_id IS NOT NULL AND l_team_template_rec.role_list_id <> FND_API.G_MISS_NUM) OR (p_role_list_name IS NOT NULL AND p_role_list_name <> FND_API.G_MISS_CHAR) THEN

            PA_ROLE_LIST_UTILS.Check_Role_List_Name_Or_Id( p_role_list_id       => l_team_template_rec.role_list_id
                                                   ,p_role_list_name     => p_role_list_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                 --,x_role_list_id       => l_team_template_rec.role_list_id		* Bug: 4537865
						   ,x_role_list_id       => l_new_role_list_id				--Bug: 4537865
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
	-- added for Bug:4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_team_template_rec.role_list_id := l_new_role_list_id;
	END IF;
        -- added for Bug:4537865
	IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
        END IF;

     END IF;  --validate role list

  END IF;  --record version number and workflow flag check

  CLOSE check_record_version_and_wf;

  PA_TEAM_TEMPLATES_PVT.Update_Team_Template(p_team_template_rec => l_team_template_rec
                                            ,p_commit => p_commit
                                            ,p_validate_only => p_validate_only
                                            ,x_return_status => x_return_status);


  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If errors exist then set the x_return_status to 'E'

  IF x_msg_count >0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_UPDATE_TEAM_TEMPLATE;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATES_PUB.Update_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
--
END Update_Team_Template;


PROCEDURE Delete_Team_Template
( p_team_template_id            IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN     NUMBER
 ,p_api_version                 IN     NUMBER                                          := 1
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 )
IS

l_msg_index_out                 NUMBER;
l_workflow_in_progress_flag     VARCHAR2(1);
l_check_team_template_in_use    VARCHAR2(1);

CURSOR check_record_version_and_wf IS
SELECT workflow_in_progress_flag
  FROM pa_team_templates
 WHERE team_template_id = p_team_template_id
   AND record_version_number = p_record_version_number;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PUB.Delete_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_DELETE_TEAM_TEMPLATE;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_Team_Teamplates_PUB.Delete_Team_Template.begin'
                     ,x_msg         => 'Beginning of Delete_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  --check the record version number and workflow in progress flag

  OPEN check_record_version_and_wf;

  FETCH check_record_version_and_wf INTO l_workflow_in_progress_flag;

  IF check_record_version_and_wf%NOTFOUND THEN

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

  ELSIF l_workflow_in_progress_flag = 'Y' THEN

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_TEAM_TEMPLATE_WORKFLOW');

  ELSE

     --Log Message
     IF (P_DEBUG_MODE = 'Y') THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_Team_Teamplates_PUB.Delete_Team_Template.calling_pvt'
                        ,x_msg         => 'Calling delete team template pvt'
                        ,x_log_level   => 5);
     END IF;

     PA_TEAM_TEMPLATES_PVT.Delete_Team_Template
                               (p_team_template_id => p_team_template_id
                               ,p_record_version_number => p_record_version_number
                               ,x_return_status => x_return_status);

  END IF;

  CLOSE check_record_version_and_wf;

  --
  -- IF the number of messages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

   -- Put any message text from message stack into the Message ARRAY
   --
   EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO ASG_PUB_DELETE_TEAM_TEMPLATE;
         END IF;
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATES_PUB.Delete_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
--
END Delete_Team_Template;

END pa_team_templates_pub;

/
