--------------------------------------------------------
--  DDL for Package Body PA_TEAM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TEAM_TEMPLATES_PKG" AS
/*$Header: PARTPKGB.pls 120.1 2005/08/19 17:01:03 mwasowic noship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
PROCEDURE Insert_Row
 (p_team_template_name          IN   pa_team_templates.team_template_name%TYPE
 ,p_description                 IN   pa_team_templates.description%TYPE                  := FND_API.G_MISS_CHAR
 ,p_start_date_active           IN   pa_team_templates.start_date_active%TYPE
 ,p_end_date_active             IN   pa_team_templates.end_date_active%TYPE              := FND_API.G_MISS_DATE
 ,p_calendar_id                 IN   pa_team_templates.calendar_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_work_type_id                IN   pa_team_templates.work_type_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_role_list_id                IN   pa_team_templates.role_list_id%TYPE                := FND_API.G_MISS_NUM
 ,p_team_start_date             IN   pa_team_templates.team_start_date%TYPE
 ,p_attribute_category          IN   pa_team_templates.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_team_templates.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_team_templates.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_team_templates.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_team_templates.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_team_templates.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_team_templates.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_team_templates.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_team_templates.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_team_templates.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_team_templates.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_team_templates.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_team_templates.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_team_templates.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_team_templates.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_team_templates.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,x_team_template_id            OUT        NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status               OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_team_template_id    PA_TEAM_TEMPLATES.team_template_id%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_PKG.Insert_Row');

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PKG.insert_row'
                     ,x_msg         => 'Beginning of the Team Template insert row'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Fetch the next sequence number for team template
  SELECT pa_team_templates_s.NEXTVAL
  INTO   x_team_template_id
  FROM   dual;

  INSERT INTO pa_team_templates
     (team_template_id
     ,record_version_number
     ,team_template_name
     ,start_date_active
     ,end_date_active
     ,description
     ,role_list_id
     ,calendar_id
     ,work_type_id
     ,team_start_date
     ,workflow_in_progress_flag
     ,attribute_category
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login )
  VALUES(
      x_team_template_id
     ,1
     ,p_team_template_name
     ,p_start_date_active
     ,DECODE(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active)
     ,DECODE(p_description, FND_API.G_MISS_CHAR, NULL, p_description)
     ,DECODE(p_role_list_id, FND_API.G_MISS_NUM, NULL, p_role_list_id)
     ,DECODE(p_calendar_id, FND_API.G_MISS_NUM, NULL, p_calendar_id)
     ,DECODE(p_work_type_id, FND_API.G_MISS_NUM, NULL, p_work_type_id)
     ,p_team_start_date
     ,'N'
     ,DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category)
     ,DECODE(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1)
     ,DECODE(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2)
     ,DECODE(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3)
     ,DECODE(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4)
     ,DECODE(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5)
     ,DECODE(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6)
     ,DECODE(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7)
     ,DECODE(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8)
     ,DECODE(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9)
     ,DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10)
     ,DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11)
     ,DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12)
     ,DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13)
     ,DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14)
     ,DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15)
     ,sysdate
     ,fnd_global.user_id
     ,sysdate
     ,fnd_global.user_id
     ,fnd_global.login_id
     );

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATES_PKG.Insert_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Insert_Row;



PROCEDURE Update_Row
 (p_team_template_id            IN   pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN   pa_team_templates.record_version_number%TYPE
 ,p_team_template_name          IN   pa_team_templates.team_template_name%TYPE           := FND_API.G_MISS_CHAR
 ,p_description                 IN   pa_team_templates.description%TYPE                  := FND_API.G_MISS_CHAR
 ,p_start_date_active           IN   pa_team_templates.start_date_active%TYPE            := FND_API.G_MISS_DATE
 ,p_end_date_active             IN   pa_team_templates.end_date_active%TYPE              := FND_API.G_MISS_DATE
 ,p_calendar_id                 IN   pa_team_templates.calendar_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_work_type_id                IN   pa_team_templates.work_type_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_role_list_id                IN   pa_team_templates.role_list_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_team_start_date             IN   pa_team_templates.team_start_date%TYPE              := FND_API.G_MISS_DATE
 ,p_workflow_in_progress_flag   IN   pa_team_templates.workflow_in_progress_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN   pa_team_templates.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_team_templates.attribute1%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_team_templates.attribute2%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_team_templates.attribute3%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_team_templates.attribute4%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_team_templates.attribute5%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_team_templates.attribute6%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_team_templates.attribute7%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_team_templates.attribute8%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_team_templates.attribute9%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_team_templates.attribute10%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_team_templates.attribute11%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_team_templates.attribute12%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_team_templates.attribute13%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_team_templates.attribute14%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_team_templates.attribute15%TYPE                  := FND_API.G_MISS_CHAR
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_record_version_number         pa_team_templates.record_version_number%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_PKG.Update_Row');

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PKG.Update_Row'
                     ,x_msg         => 'Beginning of the Team Template update row'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_record_version_number := p_record_version_number +1;

  UPDATE pa_team_templates
  SET team_template_name      = DECODE(p_team_template_name, FND_API.G_MISS_CHAR, team_template_name, p_team_template_name)
     ,record_version_number   = l_record_version_number
     ,start_date_active       = DECODE(p_start_date_active, FND_API.G_MISS_DATE, start_date_active, p_start_date_active)
     ,end_date_active         = DECODE(p_end_date_active, FND_API.G_MISS_DATE, end_date_active, p_end_date_active)
     ,description             = DECODE(p_description, FND_API.G_MISS_CHAR, description, p_description)
     ,role_list_id            = DECODE(p_role_list_id, FND_API.G_MISS_NUM, role_list_id, p_role_list_id)
     ,calendar_id             = DECODE(p_calendar_id, FND_API.G_MISS_NUM, calendar_id, p_calendar_id)
     ,work_type_id            = DECODE(p_work_type_id, FND_API.G_MISS_NUM, work_type_id, p_work_type_id)
     ,team_start_date         = DECODE(p_team_start_date, FND_API.G_MISS_DATE, team_start_date, p_team_start_date)
     ,workflow_in_progress_flag = DECODE(p_workflow_in_progress_flag, FND_API.G_MISS_CHAR, workflow_in_progress_flag, p_workflow_in_progress_flag)
     ,attribute_category          = DECODE(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category)
     ,attribute1                  = DECODE(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1)
     ,attribute2                  = DECODE(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2)
     ,attribute3                  = DECODE(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3)
     ,attribute4                  = DECODE(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4)
     ,attribute5                  = DECODE(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5)
     ,attribute6                  = DECODE(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6)
     ,attribute7                  = DECODE(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7)
     ,attribute8                  = DECODE(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8)
     ,attribute9                  = DECODE(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9)
     ,attribute10                 = DECODE(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10)
     ,attribute11                 = DECODE(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11)
     ,attribute12                 = DECODE(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12)
     ,attribute13                 = DECODE(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13)
     ,attribute14                 = DECODE(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14)
     ,attribute15                 = DECODE(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15)
     ,last_update_date            = sysdate
     ,last_updated_by             = fnd_global.user_id
     ,last_update_login           = fnd_global.login_id
 WHERE team_template_id = p_team_template_id
   AND record_version_number = p_record_version_number
   AND nvl(workflow_in_progress_flag, 'N') <> 'Y';

  IF (SQL%NOTFOUND) THEN
       --give generic message b/c don't know exactly which reason
       --is preventing the update.  We need to do the check AGAIN in the actual update
       --statement or we can't be completely sure that one of the conditions
       --doesn't exist - due to timing issue.
       --The user will get the specific message from the public API the next time they try to delete
       --the team template.
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_COULD_NOT_DEL_TEAM_TEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATES_PKG.Update_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Update_Row;


PROCEDURE Delete_Row
( p_team_template_id               IN    pa_team_templates.team_template_id%TYPE
 ,p_record_version_number          IN    NUMBER
 ,x_return_status                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PKG.delete_row'
                     ,x_msg         => 'Beginning of the Team Template delete row'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --check the record version number, workflow in progress, and template in use
  --AGAIN before allowing delete.

  DELETE FROM pa_team_templates
  WHERE  team_template_id = p_team_template_id
    AND  record_version_number = p_record_version_number
    AND  nvl(workflow_in_progress_flag, 'N') <> 'Y'
    AND  NOT EXISTS
         (SELECT 'X'
            FROM pa_project_assignments
           WHERE assignment_template_id = p_team_template_id
             AND template_flag <> 'Y');

  IF (SQL%NOTFOUND) THEN
       --give generic message b/c don't know exactly which reason out of 3
       --is preventing the delete.  We need to do the check AGAIN in the actual delete
       --statement or we can't be completely sure that one of the 3 conditions
       --doesn't exist - due to timing issue.
       --The user will get the specific message from the public API the next time they try to delete
       --the team template.
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_COULD_NOT_DEL_TEAM_TEM');
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TEAM_TEMPLATE_PKG.Delete_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;

END pa_team_templates_pkg;

/
