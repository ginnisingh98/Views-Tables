--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STAT_ACTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STAT_ACTSET" AS
--$Header: PAASPSB.pls 115.18 2003/04/08 18:46:59 mwasowic noship $


PROCEDURE process_action_set (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2
) IS

l_line_number_tbl       pa_action_set_utils.number_tbl_type;
l_line_id_tbl           pa_action_set_utils.number_tbl_type;
l_line_cond_id_tbl      pa_action_set_utils.number_tbl_type;
l_line_cond_date_tbl    pa_action_set_utils.date_tbl_type;
l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
l_loop_cnt              NUMBER;

BEGIN
   --initialize  error stack
  PA_DEBUG.init_err_stack('PA_PROJ_STAT_ACTSET.process_action_set');
  PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_APROJ_STAT_ACTSET.process_action_set.begin'
                    ,x_Msg          => 'in PA_PROJ_STAT_ACTSET.process_action_set'
                    ,x_Log_Level    => 6);


 --initialize  return status
  x_return_status := l_return_status;
--per Xiaoyuan: always return S because errors are ignored and action set
--is added - even without lines Aug 21,2002, bug 2521929
 IF p_action_set_id is NULL THEN
    --PA_UTILS.Add_Message (p_app_short_name => 'PA'
    --    ,p_msg_name => 'PA_NULL_ACTION_SET_ID');
    --x_return_status := 'E';
    --dbms_output.put_line('IN pa_proj_stat_actset.process_action_set, p_action_set_id is NULL');
    return;
 END IF;


  --dbms_output.put_line( 'PROJ_STAT_ACTSET process_action_set BEGIN'  );
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
        --dbms_output.put_line( 'Line Number '|| loop_cnt  );
       l_line_number_tbl(loop_cnt) := loop_cnt;
       END LOOP;

      --order lines for both template and project action set
      PA_ACTION_SETS_PVT.Bulk_Update_Line_Number(
        p_action_set_line_id_tbl     => l_line_id_tbl
       ,p_line_number_tbl            => l_line_number_tbl
       ,x_return_status              => x_return_status
       );
   END IF;

--Do not update condition date, it's null for repeating actions
--   if (p_action_set_template_flag = 'N')  then
--        FOR loop_cnt IN l_line_cond_id_tbl.FIRST .. l_line_cond_id_tbl.LAST LOOP
--            --dbms_output.put_line( loop_cnt ||' cond date '|| sysdate  );
--            l_line_cond_date_tbl(loop_cnt) := sysdate;
--        END LOOP;
--
--        PA_ACTION_SETS_PVT.Bulk_Update_Condition_Date(
--            p_action_line_condition_id_tbl  => l_line_cond_id_tbl
--            ,p_condition_date_tbl            => l_line_cond_date_tbl
--            ,x_return_status                 => l_return_status
--        );
--       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
--           x_return_status := FND_API.G_RET_STS_ERROR;
--       end if;
--   END IF;

  PA_DEBUG.RESET_ERR_STACK;

 -- Put any message text from message stack into the Message ARRAY
 EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJ_STAT_ACTSET.process_action_set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END process_action_set;

/*----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------*/
PROCEDURE perform_action_set_line(
    p_action_set_type_code          IN   pa_action_sets.action_set_type_code%TYPE := 'PA_PROJ_STATUS_REPORT'
    ,p_action_set_details_rec       IN   pa_action_sets%ROWTYPE
    ,p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE
    ,p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type
    ,x_action_line_audit_tbl       OUT NOCOPY   pa_action_set_utils.insert_audit_lines_tbl_type
    ,x_action_line_result_code     OUT NOCOPY   VARCHAR2)

IS
  CURSOR c_report_info(cp_layout_id NUMBER) IS
    SELECT l.NEXT_REPORTING_DATE    report_date
           ,l.object_id             project_id
           ,p.project_status_code   proj_status_code
           ,l.effective_from        effective_from
           ,l.effective_to          effective_to
   FROM    pa_object_page_layouts l
           ,pa_projects_all p
    WHERE l.object_page_layout_id = cp_layout_id
            AND l.object_id       = p.project_id;

  cp_rpt_info       c_report_info%ROWTYPE;

  l_api_name        VARCHAR2(30) := 'PA_PROJ_STAT_ACTSET';
  l_project_id      pa_projects_all.project_id%TYPE;
  l_report_type_id  pa_object_page_layouts.object_page_layout_id%TYPE;
  l_report_date     pa_object_page_layouts.next_reporting_date%TYPE;
  l_project_status  pa_projects_all.project_status_code%TYPE;
  l_action_performed VARCHAR2(1) := 'N';
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        fnd_new_messages.message_name%TYPE;
  l_action_is_repeating BOOLEAN := TRUE;
  l_msg_index_out   NUMBER;
  l_today DATE := TRUNC(sysdate);
  l_effective_from DATE;
  l_effective_to DATE;


BEGIN

  pa_debug.init_err_stack('PA_PROJ_STAT_ACTSET:perform_action_set_line');
  x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED ;
  g_action_line_audit_tbl.DELETE;

  if validate_action_type_code(p_action_set_type_code) = FALSE then
    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_token1	        => p_action_set_type_code
                          ,p_msg_name       => 'PA_INVALID_ACTION_TYPE');
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if;

 --per Xiouyuan,hard-coding statu code, bug 2383406
 if p_action_set_line_rec.status_code = 'REVERSE_PENDING' then
    x_action_line_result_code := pa_action_set_utils.G_REVERSED_DEFAULT_AUDIT;
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if;


  OPEN c_report_info(p_action_set_details_rec.object_id);
  FETCH c_report_info INTO cp_rpt_info;
  if c_report_info%NOTFOUND then
    CLOSE c_report_info;
    PA_ACTION_SET_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_msg_name  => 'PA_INVALID_PROJECT_ID'); --existing msg
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if ;

  CLOSE c_report_info;

  l_project_id      := cp_rpt_info.project_id;
  l_project_status  := cp_rpt_info.proj_status_code;
  l_report_date     := cp_rpt_info.report_date;
  l_effective_from  := cp_rpt_info.effective_from;
  l_effective_to    := cp_rpt_info.effective_to;

  -- report type effective date range check
  if  nvl(l_effective_from, l_today) > l_today or nvl(l_effective_to,l_today) < l_today then
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if;

  if (l_project_id is null  or l_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then
    PA_ACTION_SET_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_PROJECT_ID'); --existing message
    PA_DEBUG.RESET_ERR_STACK;
    return;
  end if ;


 if (project_dates_valid(l_project_id)= 'N') then
    PA_DEBUG.RESET_ERR_STACK;
    return;
 end if;

 if (action_allowed_for_status(l_project_id,l_project_status) = FALSE ) then
    PA_DEBUG.RESET_ERR_STACK;
    return;
 end if;


   if (ok_to_perform_action(
           l_report_date
          ,p_action_set_line_rec
          ,p_action_line_conditions_tbl)) then
        l_msg_count := 0;
        perform_selected_action(
           p_project_id                   => l_project_id
          ,p_report_type_id               => l_report_type_id
          ,p_layout_id                    => p_action_set_details_rec.object_id
          ,p_action_set_type_code         => p_action_set_type_code
          ,p_action_set_line_rec          => p_action_set_line_rec
          ,p_action_line_conditions_tbl   => p_action_line_conditions_tbl
          ,x_action_performed             => l_action_performed
          ,x_return_status                => l_return_status
          ,x_msg_count                    => l_msg_count
          ,x_msg_data                     => l_msg_data);
   end if;
   if (l_action_performed = 'Y') then
      l_action_is_repeating := is_action_repeating(p_action_line_conditions_tbl);
      if (l_action_is_repeating) then
          x_action_line_result_code := pa_action_set_utils.G_PERFORMED_ACTIVE;
      else
          x_action_line_result_code := pa_action_set_utils.G_PERFORMED_COMPLETE;
      end if;
      x_action_line_audit_tbl := PA_PROJ_STAT_ACTSET.g_action_line_audit_tbl;

   else
     if nvl(l_msg_count,0) > 0  then
        x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED ;
    end if;
   end if;


 PA_DEBUG.RESET_ERR_STACK;


 EXCEPTION
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJ_STAT_ACTSET.perform_action_set_line'
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

    if (p_action_set_type_code is NULL or p_action_set_type_code <>  'PA_PROJ_STATUS_REPORT' ) then
        return FALSE;
    else
        return TRUE;
    end if;

END validate_action_type_code;

FUNCTION action_allowed_for_status (
   p_project_id              IN  NUMBER
  ,p_project_status          IN  VARCHAR2
  ) return BOOLEAN

IS
  --l_project_status VARCHAR2(30);--mwxx REMOVE!!!
BEGIN
    --l_project_status := 'APPROVED'; --mwxx REMOVE!!!
    if PA_PROJECT_UTILS.check_prj_stus_action_allowed
        (p_project_status,'PA_PROJ_STATUS_REPORT') <> 'Y' then
        return FALSE;
    end if;
  return TRUE ;
END action_allowed_for_status;


FUNCTION project_dates_valid (
   p_project_id              IN  NUMBER
  ) return VARCHAR2
IS
  l_sysdate    DATE   := TRUNC(sysdate);
  l_start_date DATE   := NULL;
  l_end_date   DATE   := NULL;
BEGIN
  l_start_date := PA_PROJECT_DATES_UTILS.get_project_start_date(p_project_id);
  l_end_date   := PA_PROJECT_DATES_UTILS.get_project_finish_date(p_project_id);
  if (l_start_date is null or TRUNC(l_start_date) > l_sysdate) then
    return 'N';  --do not process this one, project not started
  end if;
  if (l_end_date is not null and  TRUNC(l_end_date) <=  l_sysdate) then
    return 'N'; --do not process this one, project is finished
  end if;

  return 'Y';

EXCEPTION
   when OTHERS then
     return 'N';
END project_dates_valid;


FUNCTION ok_to_perform_action (
   p_report_date                IN pa_object_page_layouts.next_reporting_date%TYPE
  ,p_action_set_line_rec        IN pa_action_set_lines%ROWTYPE
  ,p_action_line_conditions_tbl IN pa_action_set_utils.action_line_cond_tbl_type
  ) return BOOLEAN
IS
  l_condition_date DATE := TRUNC(sysdate);
  l_days NUMBER         := 0;
BEGIN
  -- valid action codes are:
  --PA_PROJ_STATUS_REPORT_MISS
  --PA_PROJ_STATUS_REPORT_NEXT
        if (p_action_line_conditions_tbl(p_action_line_conditions_tbl.COUNT).condition_code = 'PA_PROJ_STATUS_REPORT_BEFORE') then
            l_days := 0 - p_action_line_conditions_tbl(p_action_line_conditions_tbl.COUNT).condition_attribute1;
        else  if (p_action_line_conditions_tbl(p_action_line_conditions_tbl.COUNT).condition_code = 'PA_PROJ_STATUS_REPORT_AFTER') then
            l_days :=  p_action_line_conditions_tbl(p_action_line_conditions_tbl.COUNT).condition_attribute1;
        end if;
     end if;
    l_condition_date := TRUNC(p_report_date) + l_days;

    if (l_condition_date = TRUNC(SYSDATE)) then
        if (pa_action_set_utils.get_last_performed_date
                    (p_action_set_line_rec.action_set_line_id) = TRUNC(sysdate)) then
            return FALSE;
        else
            return TRUE;
        end if;
    else
        return FALSE;
    end if;

END ok_to_perform_action;



FUNCTION is_action_repeating(
        p_action_line_conditions_tbl pa_action_set_utils.action_line_cond_tbl_type) return BOOLEAN
IS
BEGIN
    --if (p_action_line_conditions_tbl(1).condition_attribute2 is NULL ) then
    --    return FALSE;
   -- end if;

    return TRUE;
END is_action_repeating;


PROCEDURE validate_action_set_line (
  p_action_set_type_code          IN  VARCHAR2    := 'PA_PROJ_STATUS_REPORT'
, p_action_set_line_rec           IN pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl    IN pa_action_set_utils.action_line_cond_tbl_type
, x_return_status                 OUT NOCOPY VARCHAR2
) IS

BEGIN
x_return_status := 'S';
END validate_action_set_line;

PROCEDURE validate_action_set (
  p_action_set_type_code           IN  VARCHAR2    := 'PA_PROJ_STATUS_REPORT'
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  VARCHAR2
, x_return_status                  OUT NOCOPY VARCHAR2
) IS
BEGIN
x_return_status := 'S';
END validate_action_set;

/*---------------------------------------------------------------------------------------------*/
PROCEDURE  perform_selected_action(
        p_project_id                     IN  NUMBER
       ,p_report_type_id                 IN  NUMBER
       ,p_layout_id                      IN  NUMBER
       ,p_action_set_type_code           IN  VARCHAR2
       ,p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
       ,p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
       ,x_action_performed               OUT NOCOPY VARCHAR2
       ,x_return_status                  OUT NOCOPY VARCHAR2
       ,x_msg_count                      OUT NOCOPY NUMBER
       ,x_msg_data                       OUT NOCOPY VARCHAR2)

IS
  l_return_status VARCHAR2(1)   := 'S';
  l_msg_count NUMBER            := 0;
  l_msg_data VARCHAR2(2000);
  l_sysdate DATE := TRUNC(sysdate);
  l_action_line_audit_tbl  pa_action_set_utils.insert_audit_lines_tbl_type;
  l_cnt NUMBER := 0;

BEGIN
/*Currently we are passing PA_OBJECT_PAGE_LAYOUT as object type so the
workflow API can use it to find distribution list.
This object type is required by the API that retrieves the distribution list */
 x_action_performed  := 'N'; --in case there are no reminders to be sent today
        PA_PROGRESS_REPORT_WORKFLOW.start_action_set_workflow(
        p_item_type                    => 'PAWFPPRA'
        , p_process_name               => p_action_set_line_rec.action_code
        , p_object_type                => 'PA_OBJECT_PAGE_LAYOUT'--'PA_PROJ_STATUS_REPORTS'
        , p_object_id                  => p_layout_id
        , p_action_set_line_rec        => p_action_set_line_rec
        , p_action_line_conditions_tbl => p_action_line_conditions_tbl
        , x_action_line_audit_tbl      => l_action_line_audit_tbl
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        );
     if (nvl(l_msg_count,0) = 0) then
            x_action_performed  := 'Y';
     end if;
     g_action_line_audit_tbl := l_action_line_audit_tbl;


     x_return_status   := l_return_status;
     x_msg_count       := l_msg_count;
     x_msg_data        := l_msg_data;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

        -- Set the exception Message and the stack
        --FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_proj_stat_actset.perform_selected_action'
        --                         ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       -- x_msg_count := 1;
       -- x_msg_data  := substr(SQLERRM,1,2000);
END perform_selected_action;

PROCEDURE copy_action_sets(
    p_project_id_from   IN  NUMBER
   ,p_project_id_to     IN  NUMBER
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2) IS

   Cursor c_action_set_ids
   is
/*
   SELECT  lt.object_page_layout_id object_page_layout_id
          ,ast.action_set_id        action_set_id
          ,lt.report_type_id        report_type_id
   FROM pa_object_page_layouts lt
        ,pa_action_sets ast
   WHERE ast.object_type = 'PA_PROJ_STATUS_REPORTS'
   AND lt.page_type_code = 'PPR'
   AND lt.object_id      = p_project_id_from  --c_proj_id_from
   AND ast.object_id     = lt.object_page_layout_id;
*/
  SELECT  lt.object_page_layout_id object_page_layout_id
         ,pa_action_set_utils.get_action_set_id
              ('PA_PROJ_STATUS_REPORT','PA_PROJ_STATUS_REPORTS',lt.object_page_layout_id) action_set_id
         ,lt.report_type_id        report_type_id
   FROM  pa_object_page_layouts lt
   WHERE lt.page_type_code = 'PPR'
   AND   lt.object_id      = p_project_id_from
   and pa_action_set_utils.get_action_set_id
         ('PA_PROJ_STATUS_REPORT','PA_PROJ_STATUS_REPORTS',lt.object_page_layout_id) is not null;


   Cursor c_new_proj_layout_ids(c_proj_id_to NUMBER, rep_type_id NUMBER)
   is
   SELECT object_page_layout_id
   FROM   pa_object_page_layouts
   WHERE object_id    = c_proj_id_to
   AND object_type    = 'PA_PROJECTS'
   AND report_type_id = rep_type_id
   AND page_type_code = 'PPR';

   cp_layout_id  c_new_proj_layout_ids%ROWTYPE;

   l_new_action_set_id        NUMBER;
   l_action_set_id            NUMBER;
   loop_cnt                   NUMBER;
   l_commit_flag              VARCHAR2(1) := 'Y';

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;
  PA_DEBUG.init_err_stack('PA_PROJ_STAT_ACTSET.copy_action_sets');
  savepoint copy_proj_action_sets;


  FOR c_action_set_rec in c_action_set_ids LOOP

      OPEN c_new_proj_layout_ids(p_project_id_to, c_action_set_rec.report_type_id);
      FETCH c_new_proj_layout_ids into cp_layout_id;
      if c_new_proj_layout_ids%FOUND then

          pa_action_sets_pub.apply_action_set
            (p_action_set_id         => c_action_set_rec.action_set_id
            ,p_object_type           => 'PA_PROJ_STATUS_REPORTS'
            ,p_object_id             => cp_layout_id.object_page_layout_id
            ,p_validate_only         => FND_API.G_FALSE
            ,x_new_action_set_id     => l_new_action_set_id
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data);

          close c_new_proj_layout_ids;
          if x_return_status <>  fnd_api.g_ret_sts_success then
               l_commit_flag := 'N';
          end if;
      else
          close c_new_proj_layout_ids;
      end if;

   END LOOP;


  if l_commit_flag = 'N' then
       ROLLBACK TO copy_proj_action_sets;
  end if;

  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK TO copy_proj_action_sets;
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_proj_stat_actset.copy_action_sets'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END copy_action_sets;

PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_PROJ_STATUS_REPORT'
 ,p_object_type            IN    pa_action_sets.object_type%TYPE             := 'PA_PROJ_STATUS_REPORTS'
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
/*
  CURSOR c_action_set_info(cp_object_id NUMBER, cp_type pa_action_sets.action_set_type_code%TYPE,
                           cp_obj  pa_action_sets.object_type%TYPE ) IS

       select action_set_id,record_version_number
         from pa_action_sets
         where object_id          = cp_object_id
         AND object_type          = cp_obj
         AND action_set_type_code = cp_type;
*/
  CURSOR c_action_set_info(cp_act_set_id NUMBER ) IS
       select record_version_number
         from pa_action_sets
         where action_set_id      = cp_act_set_id;


  l_record_version_number NUMBER;
  l_action_set_id NUMBER;
  cp_action_set_info c_action_set_info%ROWTYPE;

 BEGIN
   PA_DEBUG.init_err_stack('PA_PROJ_STAT_ACTSET.delete_action_set');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_PROJ_STAT_ACTSET.delete_action_set.begin'
                    ,x_Msg          => 'in PA_PROJ_STAT_ACTSET.delete_action_set'
                    ,x_Log_Level    => 6);

   x_return_status         := 'S';
   l_action_set_id         := p_action_set_id;
   l_record_version_number := p_record_version_number;

   IF l_action_set_id is NULL THEN
        l_action_set_id :=  pa_action_set_utils.get_action_set_id(p_action_set_type_code
                           ,p_object_type
                           ,p_object_id);
   END IF;

   IF l_record_version_number is NULL THEN
          OPEN c_action_set_info(l_action_set_id);
          FETCH c_action_set_info INTO cp_action_set_info;

          --Return success when action set not found since we're trying to delete it
          IF c_action_set_info%NOTFOUND THEN
             CLOSE c_action_set_info;
             RETURN;
          END IF;
          l_record_version_number := cp_action_set_info.record_version_number;
          CLOSE c_action_set_info;
   END IF;

   PA_ACTION_SETS_PUB.delete_action_set
     (p_action_set_id          => l_action_set_id
     ,p_action_set_type_code   => p_action_set_type_code
     ,p_object_type            => p_object_type
     ,p_object_id              => p_object_id
     ,p_init_msg_list          => FND_API.G_TRUE
     ,p_record_version_number  => l_record_version_number
     ,p_commit                 => p_commit
     ,p_validate_only          => p_validate_only
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data);


    PA_DEBUG.RESET_ERR_STACK;


 EXCEPTION

    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJ_STAT_ACTSET.delete_action_set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END delete_action_set;



PROCEDURE update_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code    IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_PROJ_STATUS_REPORT'
 ,p_object_type             IN    pa_action_sets.object_type%TYPE             := 'PA_PROJ_STATUS_REPORTS'
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


  CURSOR c_action_set_info(cp_act_set_id NUMBER ) IS
       select record_version_number
         from pa_action_sets
         where action_set_id      = cp_act_set_id;


  l_record_version_number NUMBER;
  l_curr_action_set_id NUMBER := NULL;
  cp_action_set_info c_action_set_info%ROWTYPE;
  l_new_action_set_id NUMBER := NULL;


 BEGIN
   PA_DEBUG.init_err_stack('PA_PROJ_STAT_ACTSET.update_action_set');
   PA_DEBUG.WRITE_LOG(x_Module        => 'pa.plsql.PA_PROJ_STAT_ACTSET.update_action_set.begin'
                    ,x_Msg          => 'in PA_PROJ_STAT_ACTSET.update_action_set'
                    ,x_Log_Level    => 6);

   x_return_status         := 'S';
   --l_record_version_number := p_record_version_number;
   l_curr_action_set_id :=  pa_action_set_utils.get_action_set_id(p_action_set_type_code
                           ,p_object_type
                           ,p_object_id);

   IF l_curr_action_set_id is NOT NULL THEN
       --Find an existing action set attached to this page layout id
       OPEN c_action_set_info(l_curr_action_set_id);
       FETCH c_action_set_info INTO cp_action_set_info;

       --Return success when action set not found when we're trying to delete it
       IF c_action_set_info%NOTFOUND THEN
            CLOSE c_action_set_info;
            l_curr_action_set_id := NULL;
       ELSE
            l_record_version_number := cp_action_set_info.record_version_number;
            CLOSE c_action_set_info;
       END IF;
   END IF;


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
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJ_STAT_ACTSET.update_action_set'
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
