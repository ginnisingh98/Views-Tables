--------------------------------------------------------
--  DDL for Package Body PA_TASK_PROG_ACTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_PROG_ACTSET" AS
--$Header: PAASTPB.pls 115.15 2003/04/08 18:46:36 mwasowic noship $



PROCEDURE process_action_set (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE := 'PA_TASK_PROGRESS'
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2
) IS
l_line_number_tbl       pa_action_set_utils.number_tbl_type;
l_line_id_tbl           pa_action_set_utils.number_tbl_type;
l_line_cond_id_tbl      pa_action_set_utils.number_tbl_type;
l_line_cond_date_tbl    pa_action_set_utils.date_tbl_type;
l_return_status         VARCHAR2(1):= 'S';
l_loop_cnt              NUMBER;

BEGIN
   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.process_action_set');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_TASK_PROG_ACTSET.process_action_set.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.process_action_set'
                    ,x_Log_Level    => 6);

 --initialize  return status
  x_return_status := l_return_status;
--per Xiaoyuan: always return S because errors are ignored and action set
--is added - even without lines Aug 21,2002, bug 2521929
 IF p_action_set_id is NULL THEN
    --PA_UTILS.Add_Message (p_app_short_name => 'PA'
    --    ,p_msg_name => 'PA_NULL_ACTION_SET_ID');
    --x_return_status := 'E';
    --dbms_output.put_line('IN pa_task_prog_actset.process_action_set, p_action_set_id is NULL');
    return;
 END IF;

     -- get all action lines and conditions of the object
   SELECT line.action_set_line_id,
          cond.action_set_line_condition_id
   BULK COLLECT INTO l_line_id_tbl,
          l_line_cond_id_tbl
   FROM pa_action_set_lines line,
        pa_action_set_line_cond cond
   WHERE line.action_set_id = p_action_set_id
     AND line.action_set_line_id = cond.action_set_line_id;
   --FORALL loop_cnt IN l_line_id_tbl.FIRST .. l_line_id_tbl.LAST

   IF l_line_id_tbl.count > 0 THEN
       FOR loop_cnt IN l_line_id_tbl.FIRST .. l_line_id_tbl.LAST LOOP
         l_line_number_tbl(loop_cnt) := loop_cnt;
       END LOOP;

      --order lines for both template and project action set
      PA_ACTION_SETS_PVT.Bulk_Update_Line_Number(
        p_action_set_line_id_tbl     => l_line_id_tbl
       ,p_line_number_tbl            => l_line_number_tbl
       ,x_return_status              => x_return_status
       );

   END IF;

   --if (p_action_set_template_flag = 'N')  then
   --     FOR loop_cnt IN l_line_cond_id_tbl.FIRST .. l_line_cond_id_tbl.LAST LOOP
   --         l_line_cond_date_tbl(loop_cnt) := sysdate;
   --     END LOOP;
   --
  --      PA_ACTION_SETS_PVT.Bulk_Update_Condition_Date(
  --          p_action_line_condition_id_tbl   => l_line_cond_id_tbl
  --          ,p_condition_date_tbl            => l_line_cond_date_tbl
  --          ,x_return_status                 => l_return_status
  --      );
  -- END IF;

  PA_DEBUG.RESET_ERR_STACK;
  return;

 -- Put any message text from message stack into the Message ARRAY
 EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.process_action_set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END process_action_set;
/*===================================================================================*/
PROCEDURE perform_action_set_line(
    p_action_set_type_code          IN   VARCHAR2 := 'PA_TASK_PROGRESS'
    ,p_action_set_details_rec       IN   pa_action_sets%ROWTYPE
    ,p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE
    ,p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type
    ,x_action_line_audit_tbl       OUT NOCOPY   pa_action_set_utils.insert_audit_lines_tbl_type
    ,x_action_line_result_code     OUT NOCOPY   VARCHAR2)
IS
  CURSOR c_proj_info(cp_project_id NUMBER) IS
    SELECT p.start_date proj_start_date,
           p.project_status_code proj_status_code
    FROM  pa_projects_all p
    WHERE p.project_id = cp_project_id;

  cp_proj_info c_proj_info%ROWTYPE;
  l_api_name VARCHAR2(30) := 'PA_TASK_PROG_ACTSET';
  l_project_id NUMBER;
  l_proj_start_date DATE;
  l_project_status VARCHAR2(30);
  l_action_is_repeating BOOLEAN := TRUE;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER := 0;
  l_msg_data VARCHAR2(2000);

BEGIN
   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.process_action_set');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_TASK_PROG_ACTSET.perform_action_set_line.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.perform_action_set_line'
                    ,x_Log_Level    => 6);

  x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED ;

  if validate_action_type_code(p_action_set_type_code) = FALSE then
         PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
                      ,p_msg_name       => 'PA_AS_INVALID_ACTION_TYPE');
      PA_DEBUG.RESET_ERR_STACK;
      return;
  end if;
  l_project_id := p_action_set_details_rec.object_id; --2643
  --get_project_id(p_action_set_type_code,p_action_set_line_rec);
  if (l_project_id is null  or l_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then
    PA_ACTION_SET_UTILS.Add_Message(
        p_app_short_name => 'PA'
       ,p_msg_name       => 'PA_NO_PROJECT_ID');
     PA_DEBUG.RESET_ERR_STACK;
     return;
  end if ;

  OPEN c_proj_info(l_project_id);
  FETCH c_proj_info INTO cp_proj_info;
  if c_proj_info%NOTFOUND then
    close c_proj_info;
    PA_ACTION_SET_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_NO_PROJECT_ID');
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if ;
  l_project_status  := cp_proj_info.proj_status_code;
  l_proj_start_date := cp_proj_info.proj_start_date;


 if (action_allowed_for_status(l_project_id,l_project_status) = FALSE) then
    PA_DEBUG.RESET_ERR_STACK;
    return;
 end if;

 --When task prog reminder date is in the past, bring it up to date
 PA_PROGRESS_UTILS.ADJUST_REMINDER_DATE(p_commit  => FND_API.G_TRUE,
                                  p_project_id      => l_project_id,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data);

 --per Xiouyuan,hard-coding statu code, bug 2383406
 if p_action_set_line_rec.status_code = 'REVERSE_PENDING' then
    x_action_line_result_code := pa_action_set_utils.G_REVERSED_DEFAULT_AUDIT;
 else
    if ok_to_perform_action(l_project_id,l_proj_start_date) then
       l_msg_count := 0;
       PA_TASK_PROG_INQUIRY_PKG.request_all_tasks_in_project(
                p_commit                => fnd_api.g_true,
                p_validate_only         => fnd_api.g_false,
                p_project_id            => l_project_id,
                x_action_line_audit_tbl => x_action_line_audit_tbl,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);
       --x_action_line_audit_tbl := PA_TASK_PROG_ACTSET.g_action_line_audit_tbl;
       l_action_is_repeating := is_action_repeating(p_action_line_conditions_tbl);
       if (l_action_is_repeating) then
         /*Don't set the staus to "Complete", it's a repeating action */
          x_action_line_result_code := pa_action_set_utils.G_PERFORMED_ACTIVE;
       else
          x_action_line_result_code := pa_action_set_utils.G_PERFORMED_COMPLETE;
       end if;
     end if;
 end if;
PA_DEBUG.RESET_ERR_STACK;
return;
 EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.peform_action_set_line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED;
       RAISE;

END perform_action_set_line;
/*-----------------------------------------------------------------------------------*/
FUNCTION validate_action_type_code (
  p_action_set_type_code           IN  VARCHAR2
  ) return BOOLEAN
IS
BEGIN
if (p_action_set_type_code is NULL) then
   return FALSE;
end if;

if (p_action_set_type_code   = 'PA_TASK_PROGRESS') then
   return TRUE;
else
   return FALSE;
end if;

END validate_action_type_code;


/*-----------------------------------------------------------------------------------*/
FUNCTION action_allowed_for_status (
   p_project_id              IN  NUMBER
  ,p_project_status          IN  VARCHAR2
  ) return BOOLEAN

IS
  --l_project_status VARCHAR2(30);--mwxx REMOVE!!!
BEGIN

   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.action_allowed_for_status');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_TASK_PROG_ACTSET.action_allowed_for_status.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.action_allowed_for_status'
                    ,x_Log_Level    => 6);

    --l_project_status := 'APPROVED'; --mwxx REMOVE!!!
    if PA_PROJECT_UTILS.check_prj_stus_action_allowed
        (p_project_status,'PA_TASK_PROGRESS') <> 'Y' then
         PA_DEBUG.RESET_ERR_STACK;
         return FALSE;
         --return TRUE; --mwx REMOVE!!

    end if;
   PA_DEBUG.RESET_ERR_STACK;
   return TRUE ;
 EXCEPTION
    WHEN OTHERS THEN
    RAISE;

     --  FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.action_allowed_for_status'
     --                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );

END action_allowed_for_status;
/*----------------------------------------------------------------------------------*/
FUNCTION ok_to_perform_action (
   p_project_id              IN  NUMBER
  ,p_proj_start_date         IN  DATE
  ) return BOOLEAN
IS
  l_sysdate DATE := TRUNC(sysdate);

  CURSOR c_proj_date(cp_project_id NUMBER) IS
    SELECT next_reporting_date report_date
    FROM pa_object_page_layouts
    WHERE TRUNC(next_reporting_date) = l_sysdate
      AND object_id      = cp_project_id
      AND object_type    = 'PA_PROJECTS'
      AND page_type_code = 'TPR';

  cp_proj_date c_proj_date%ROWTYPE;
BEGIN

   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.ok_to_perform_action');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_TASK_PROG_ACTSET.ok_to_perform_action.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.ok_to_perform_action'
                    ,x_Log_Level    => 6);


  if (TRUNC(p_proj_start_date) > l_sysdate) then
    return FALSE;
  end if;

  OPEN c_proj_date(p_project_id);
  FETCH c_proj_date INTO cp_proj_date;
  if c_proj_date%NOTFOUND then
    close c_proj_date;
    PA_DEBUG.RESET_ERR_STACK;
    return FALSE;
  else
    PA_DEBUG.RESET_ERR_STACK;
    return TRUE ;
  end if ;

 EXCEPTION
    WHEN OTHERS THEN
    RAISE;

        -- Set the excetption Message and the stack
       --FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.ok_to_perform_action'
       --                         ,p_procedure_name => PA_DEBUG.G_Err_Stack );

END ok_to_perform_action;
/*-----------------------------------------------------------------------------*/
FUNCTION is_action_repeating(
        p_action_line_conditions_tbl pa_action_set_utils.action_line_cond_tbl_type) return BOOLEAN
IS
BEGIN
      --if (p_action_line_conditions_tbl(0).condition_attribute2  is NULL) then
      --     return FALSE;
     --end if;
    return TRUE;
END is_action_repeating;


PROCEDURE copy_action_sets(
    p_project_id_from   IN  NUMBER
   ,p_project_id_to     IN  NUMBER
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2) IS

   Cursor task_reminder_action_set
   is
/*
   Select action_set_id
   from pa_action_sets
   where object_type = 'PA_PROJECTS'
   and object_id = p_project_id_from;
*/
   SELECT
         pa_action_set_utils.get_action_set_id
              ('PA_TASK_PROGRESS','PA_PROJECTS',p_project_id_from) action_set_id
   FROM  dual
   WHERE pa_action_set_utils.get_action_set_id
         ('PA_TASK_PROGRESS','PA_PROJECTS',p_project_id_from) is not null;

   l_action_set_id NUMBER;
   l_new_action_set_id NUMBER;


BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.copy_action_sets');
   savepoint copy_task_action_sets;


   OPEN task_reminder_action_set;
   FETCH task_reminder_action_set INTO l_action_set_id;

   if task_reminder_action_set%NOTFOUND then
       CLOSE task_reminder_action_set;
       PA_DEBUG.Reset_Err_Stack;
       return ;
   end if ;

   pa_action_sets_pub.apply_action_set
      (p_action_set_id         => l_action_set_id
       ,p_object_type           => 'PA_PROJECTS'
       ,p_object_id             => p_project_id_to
       ,p_validate_only         => FND_API.G_FALSE
       ,x_new_action_set_id     => l_new_action_set_id
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);

  if x_return_status <> fnd_api.g_ret_sts_success then
       ROLLBACK TO copy_task_action_sets;
  end if;

  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
   WHEN TOO_MANY_ROWS THEN
                  ROLLBACK TO copy_task_action_sets;
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_task_prog_actset.copy_action_sets'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

    WHEN OTHERS THEN
          ROLLBACK TO copy_task_action_sets;
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_task_prog_actset.copy_action_sets'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END copy_action_sets;


PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE        := NULL
 ,p_action_set_type_code   IN   pa_action_sets.action_set_type_code%TYPE := 'PA_TASK_PROGRESS'
 ,p_object_type            IN    pa_action_sets.object_type%TYPE             := 'PA_PROJECTS'
 ,p_object_id              IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,p_api_version            IN    NUMBER               := 1.0
 ,p_commit                 IN    VARCHAR2             := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2             := FND_API.G_TRUE
 ,p_init_msg_list          IN    VARCHAR2             := FND_API.G_TRUE
 ,x_return_status         OUT NOCOPY    VARCHAR2
 ,x_msg_count             OUT NOCOPY    NUMBER
 ,x_msg_data              OUT NOCOPY    VARCHAR2
   ) IS

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER := 0;
  l_msg_data VARCHAR2(2000);
  l_record_version_number NUMBER;

 BEGIN
   PA_DEBUG.init_err_stack('PA_TASK_PROG_ACTSET.delete_action_set');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_TASK_PROG_ACTSET.delete_action_set.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.delete_action_set'
                    ,x_Log_Level    => 6);

   l_record_version_number := p_record_version_number;
   IF l_record_version_number is NULL THEN
       select record_version_number
         into l_record_version_number
         from pa_action_sets
         where action_set_id = p_action_set_id;
   END IF;
   PA_ACTION_SETS_PUB.delete_action_set
     (p_action_set_id          => p_action_set_id
     ,p_action_set_type_code   => p_action_set_type_code
     ,p_object_type            => p_object_type
     ,p_object_id              => p_object_id
     ,p_init_msg_list          => p_init_msg_list
     ,p_record_version_number  => l_record_version_number
     ,p_commit                 => p_commit
     ,p_validate_only          => p_validate_only
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data);


     --x_return_status          =: l_return_status;
     --x_msg_count              =: l_msg_count;
     --x_msg_data               =: l_msg_data;


    PA_DEBUG.RESET_ERR_STACK;


 EXCEPTION

    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.delete_action_set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;

END delete_action_set;

PROCEDURE update_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code    IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_TASK_PROGRESS'
 ,p_object_type             IN    pa_action_sets.object_type%TYPE             := 'PA_PROJECTS'
 ,p_object_id               IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_perform_action_set_flag IN    VARCHAR2             := 'N'
 ,p_record_version_number   IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,p_api_version             IN    NUMBER               := 1.0
 ,p_commit                  IN    VARCHAR2             := FND_API.G_FALSE
 ,p_validate_only           IN    VARCHAR2             := FND_API.G_TRUE
 ,p_init_msg_list           IN    VARCHAR2             := FND_API.G_TRUE
 ,x_new_action_set_id      OUT NOCOPY    NUMBER
 ,x_return_status          OUT NOCOPY    VARCHAR2
 ,x_msg_count              OUT NOCOPY    NUMBER
 ,x_msg_data               OUT NOCOPY    VARCHAR2
) IS
/*
  CURSOR c_action_set_info(cp_object_id NUMBER, cp_type pa_action_sets.action_set_type_code%TYPE,
                           cp_obj  pa_action_sets.object_type%TYPE ) IS
       select action_set_id,record_version_number
         from pa_action_sets
         where object_id          = cp_object_id
         AND object_type          = cp_obj
         AND action_set_type_code = cp_type;
*/
  CURSOR c_action_set_info(cp_action_set_id NUMBER
                            ) IS
       select action_set_id,record_version_number
         from pa_action_sets
         where action_set_id      = cp_action_set_id;

  l_record_version_number NUMBER;
  l_curr_action_set_id NUMBER := NULL;
  cp_action_set_info c_action_set_info%ROWTYPE;
  l_new_action_set_id NUMBER := NULL;


 BEGIN
   PA_DEBUG.init_err_stack('PA_PROJ_STAT_ACTSET.update_action_set');
   PA_DEBUG.WRITE_LOG(x_Module  => 'pa.plsql.PA_TASK_PROG_ACTSET.update_action_set.begin'
                    ,x_Msg          => 'in PA_TASK_PROG_ACTSET.update_action_set'
                    ,x_Log_Level    => 6);

   x_return_status         := 'S';
   l_record_version_number := p_record_version_number;

   l_curr_action_set_id :=  pa_action_set_utils.get_action_set_id(p_action_set_type_code
                           ,p_object_type
                           ,p_object_id);
   if l_curr_action_set_id is not NULL then
        OPEN c_action_set_info(l_curr_action_set_id);
        FETCH c_action_set_info INTO cp_action_set_info;
        IF c_action_set_info%NOTFOUND THEN
             CLOSE c_action_set_info;
             PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_CI_XX_DUPLICATE_NUMBER');
             x_return_status := FND_API.G_RET_STS_ERROR;
             PA_DEBUG.RESET_ERR_STACK;
             return;
        end if;
        l_record_version_number := cp_action_set_info.record_version_number;
        CLOSE c_action_set_info;
   end if;

/*
   --Find an existing action set attached to this page layout id
   OPEN c_action_set_info(p_object_id, p_action_set_type_code,p_object_type);
   FETCH c_action_set_info INTO cp_action_set_info;

   --Return success when action set not found when we're trying to delete it
   IF c_action_set_info%NOTFOUND THEN
        CLOSE c_action_set_info;
        IF p_action_set_id is NULL THEN
             RETURN;
        END IF;
   ELSE
        l_curr_action_set_id    := cp_action_set_info.action_set_id;
        l_record_version_number := cp_action_set_info.record_version_number;
        CLOSE c_action_set_info;
   END IF;
*/
   IF p_action_set_id is NULL AND l_curr_action_set_id is NOT NULL THEN
        PA_ACTION_SETS_PUB.delete_action_set
            (p_action_set_id          => l_curr_action_set_id
            ,p_action_set_type_code   => p_action_set_type_code
            ,p_object_type            => p_object_type
            ,p_object_id              => p_object_id
            ,p_init_msg_list          => p_init_msg_list
            ,p_record_version_number  => l_record_version_number
            ,p_commit                 => p_commit
            ,p_validate_only          => p_validate_only
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data);
   ELSE
        IF p_action_set_id is NOT NULL AND l_curr_action_set_id is NULL THEN
        PA_ACTION_SETS_PUB.apply_action_set
            (p_action_set_id           => p_action_set_id
            ,p_object_type             => p_object_type
            ,p_object_id               => p_object_id
            ,p_perform_action_set_flag => p_perform_action_set_flag
            ,p_init_msg_list           => p_init_msg_list
            ,p_commit                  => p_commit
            ,p_validate_only           => p_validate_only
            ,x_new_action_set_id       => x_new_action_set_id
            ,x_return_status           => x_return_status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data);

        ELSE
             IF p_action_set_id is NOT NULL AND l_curr_action_set_id is NOT NULL THEN
                 IF l_curr_action_set_id = p_action_set_id THEN
                      RETURN;
                 END IF;
                 PA_ACTION_SETS_PUB.replace_action_set
                      (p_current_action_set_id  => l_curr_action_set_id
                      ,p_action_set_type_code   => p_action_set_type_code
                      ,p_object_type            => p_object_type
                      ,p_object_id              => p_object_id
                      ,p_record_version_number  => l_record_version_number
                      ,p_new_action_set_id      => p_action_set_id
                      ,p_init_msg_list          => p_init_msg_list
                      ,p_commit                 => p_commit
                      ,p_validate_only          => p_validate_only
                      ,x_new_action_set_id      => x_new_action_set_id
                      ,x_return_status          => x_return_status
                      ,x_msg_count              => x_msg_count
                      ,x_msg_data               => x_msg_data);

             END IF;
        END IF;
   END IF;



    PA_DEBUG.RESET_ERR_STACK;


 EXCEPTION

    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_PROG_ACTSET.update_action_set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END update_action_set;


 /*
 select billing_cycle_id,billing_cycle_name
  2  from pa_billing_cycles;
BILLING_CYCLE_ID BILLING_CYCLE_NAME
---------------- ------------------------------
               1 Billing cycle days : 28
               2 Billing cycle days : 35
              21 First Day
              22 Last Weekday of Month
              23 Weekday Each Week

 */


END;

/
