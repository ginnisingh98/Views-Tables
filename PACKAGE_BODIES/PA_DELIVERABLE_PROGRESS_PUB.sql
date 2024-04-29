--------------------------------------------------------
--  DDL for Package Body PA_DELIVERABLE_PROGRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DELIVERABLE_PROGRESS_PUB" AS
/* $Header: PAPRDLPB.pls 120.2.12010000.2 2009/05/19 08:10:07 rthumma ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_DELIVERABLE_PROGRESS_PUB';

PROCEDURE UPDATE_DELIVERABLE_PROGRESS(
 p_api_version                          IN      NUMBER       := 1.0                                  ,
 p_init_msg_list                        IN      VARCHAR2     := FND_API.G_TRUE                       ,
 p_commit                               IN      VARCHAR2     := FND_API.G_FALSE                      ,
 p_validate_only                        IN      VARCHAR2     := FND_API.G_TRUE                       ,
 p_validation_level                     IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL           ,
 p_calling_module                       IN      VARCHAR2     := 'SELF_SERVICE'                       ,
 p_action                               IN      VARCHAR2     := 'SAVE'                               ,
 p_bulk_load_flag                       IN      VARCHAR2     := 'N'                                  ,
 p_progress_mode                        IN      VARCHAR2     := 'FUTURE'                             ,
 p_percent_complete_id                  IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_project_id                           IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_id                            IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_type                          IN      VARCHAR2     := 'PA_DELIVERABLES'                    ,
 p_object_version_id                    IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_del_status                           IN      VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_id                              IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_as_of_date                           IN      DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_percent_complete                     IN      NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_progress_status_code                 IN      VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_progress_comment                     IN      VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_brief_overview                       IN      VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_actual_finish_date                   IN      DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_deliverable_due_date                 IN      DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_record_version_number                IN      NUMBER                                               ,
 p_pm_product_code                      IN      VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_structure_type                       IN      VARCHAR2     := 'WORKPLAN'                           ,
 x_return_status                        OUT     NOCOPY VARCHAR2                                             , --File.Sql.39 bug 4440895
 x_msg_count                            OUT     NOCOPY NUMBER                                               , --File.Sql.39 bug 4440895
 x_msg_data                             OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   l_api_name                           CONSTANT VARCHAR(30) := 'UPDATE_DELIVERABLE_PROGRESS'   ;
   l_api_version                        CONSTANT NUMBER      := 1.0                             ;

   l_return_status                      VARCHAR2(1)                                             ;
   l_msg_count                          NUMBER                                                  ;
   l_msg_data                           VARCHAR2(250)                                           ;
   l_data                               VARCHAR2(250)                                           ;
   l_msg_index_out                      NUMBER                                                  ;
   l_error_msg_code                     VARCHAR2(250)                                           ;
   l_user_id                            NUMBER               := FND_GLOBAL.USER_ID              ;
   l_login_id                           NUMBER               := FND_GLOBAL.LOGIN_ID             ;

   l_task_id                            NUMBER                                                  ;
   l_project_id                         NUMBER                                                  ;

   l_att_pc_id                          NUMBER                                                  ;
   l_percent_complete_id                NUMBER                                                  ;
   l_PROGRESS_ROLLUP_ID                 NUMBER                                                  ;


   l_last_progress_date                 DATE                                                    ;
   l_progress_exists_on_aod             VARCHAR2(15)                                            ;
   l_db_action                          VARCHAR2(10)                                            ;
   l_BASE_PERCENT_COMPLETE              NUMBER                                                  ;
   l_published_flag                     VARCHAR2(1)                                             ;
   l_current_flag                       VARCHAR2(1)                                             ;
   l_actual_finish_date                 DATE                                                    ;
   l_BASE_PROGRESS_STATUS_CODE          VARCHAR2(30)                                            ;
   l_proj_element_id                    NUMBER                                                  ;
   l_percent_complete                   NUMBER                                                  ;

   l_percent_complete_flag              VARCHAR2(1)                                             ;
   l_rollup_rec_ver_number              NUMBER                                                  ;
   l_published_by_party_id              NUMBER            := PA_UTILS.get_party_id( l_user_id ) ;
   l_del_status                         VARCHAR2(150)                                           ;
   l_del_status2                        VARCHAR2(150)                                           ;
   l_working_aod                        DATE                                                    ;
   l_aod                                DATE                                                    ;
   l_progress_entry_enable_flag         VARCHAR2(1)                                             ;
   l_msg                                VARCHAR2(30)                                            ;
   l_EFF_ROLLUP_PERCENT_COMP            NUMBER                                                  ;
   l_EFF_ROLLUP_PROG_STAT_CODE          VARCHAR2(150)                                           ;
   l_rollup_progress_status             VARCHAR2(150)                                           ;
   l_rollup_completed_percentage        NUMBER                                                  ;
   l_pev_schedule_id                    NUMBER                                                  ;
   l_sch_rec_ver_number                 NUMBER                                                  ;
   l_del_type_prog_enabled              VARCHAR2(1)                                             ;
   l_task_type_prog_enabled             VARCHAR2(1)                                             ;
   g1_debug_mode                        VARCHAR2(1)                                             ;
   L_WQ_ENABLED_FLAG                    VARCHAR2(1)                                             ;
   l_del_name                           VARCHAR2(240); -- Bug 6497559
   L_EST_REMAINING_EFF_FLAG             VARCHAR2(1)                                             ;
   l_estimated_start_date               DATE                                                    ;
   l_estimated_finish_date              DATE                                                    ;
   l_actual_start_date                  DATE                                                    ;
   L_TASK_WEIGHT_BASIS_CODE             VARCHAR2(20)                                            ;
   L_ALLOW_COLLAB_PROG_ENTRY            VARCHAR2(1)                                             ;
   L_ALLW_PHY_PRCNT_CMP_OVERRIDES       VARCHAR2(1)                                             ;



   CURSOR cur_sch_id( c_object_version_id NUMBER )
   IS
     SELECT pev_schedule_id, record_version_number, actual_start_date, estimated_start_date, estimated_finish_date
     FROM pa_proj_elem_ver_schedule
     WHERE project_id = p_project_id
     AND element_version_id = c_object_version_id;


   CURSOR cur_get_del_type_prog_attr
   IS
     SELECT nvl(ptt.PROG_ENTRY_ENABLE_FLAG, 'N'), elem.type_id, elem.status_code, elem.NAME  -- Bug 6497559
     FROM pa_proj_elements elem, pa_task_types ptt
     WHERE project_id = p_project_id
     AND proj_element_id = p_object_id
     AND elem.object_type ='PA_DELIVERABLES'
     AND elem.type_id = ptt.task_type_id(+)
     AND ptt.object_type = 'PA_DLVR_TYPES' ;

   CURSOR cur_get_task_type_prog_attr
   IS
     SELECT nvl(ptt.PROG_ENTRY_ENABLE_FLAG, 'N')
     FROM pa_proj_elements elem, pa_task_types ptt
     WHERE project_id = p_project_id
     AND proj_element_id = p_task_id
     AND elem.object_type ='PA_TASKS'
     AND elem.type_id = ptt.task_type_id(+)
     AND ptt.object_type = 'PA_TASKS' ;




   l_prog_pa_period_name    VARCHAR2(30)                                   ;
   l_prog_gl_period_name    VARCHAR2(30)                                   ;
   l_deliverable_status     VARCHAR2(30)                                   ;
   l_deliverable_existing_status VARCHAR2(30)                              ;
   l_dlvr_type_id           NUMBER                                         ;
   l_pm_product_code        pa_percent_completes.pm_product_code%TYPE      ; -- FPM Dev CR 1
   l_PROGRESS_COMMENT        pa_percent_completes.progress_comment%TYPE     ; -- FPM Dev CR 1
   l_brief_overview     pa_percent_completes.description%TYPE          ; -- FPM Dev CR 1
   l_progress_status_code   pa_progress_rollup.progress_status_code%TYPE   ; -- FPM Dev CR 3
   l_record_version_number  NUMBER                        ; -- FPM Dev CR 3
   --3632883
   l_dummy VARCHAR2(3);
   l_rollup_current_flag VARCHAR2(1); -- Bug 3879461

   temp_task_id   number;  --5194985

BEGIN

    g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF g1_debug_mode  = 'Y' THEN
       pa_debug.init_err_stack ('PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS');
    END IF;

   IF g1_debug_mode  = 'Y' THEN
        -- FPM Dev CR 1 : Printed All Parameters
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS Passed Parameters Are..', x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_api_version='||p_api_version, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_init_msg_list='||p_init_msg_list, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_commit='||p_commit, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_validate_only='||p_validate_only, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_validation_level='||p_validation_level, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_calling_module='||p_calling_module, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_action='||p_action, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_bulk_load_flag='||p_bulk_load_flag, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_progress_mode='||p_progress_mode, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_percent_complete_id='||p_percent_complete_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_object_id='||p_object_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_object_type='||p_object_type, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_object_version_id='||p_object_version_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_del_status='||p_del_status, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_percent_complete='||p_percent_complete, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_progress_status_code='||p_progress_status_code, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_progress_comment='||p_progress_comment, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_brief_overview='||p_brief_overview, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_actual_finish_date='||p_actual_finish_date, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_deliverable_due_date='||p_deliverable_due_date, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_record_version_number='||p_record_version_number, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_pm_product_code='||p_pm_product_code, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'p_structure_type='||p_structure_type, x_Log_Level=> 3);
   END IF;


    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_DELIVERABLE_PROGRESS;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  --bug 4185364, start
  -- if action is SAVE then delete al the present and future working records.
  --there shud be only one working record.
    if  p_action = 'SAVE'
    THEN
       delete from pa_percent_completes
       where project_id= p_project_id
         and object_id = p_object_id
         and published_flag = 'N'
         and task_id = p_task_id
         and structure_type = p_structure_type
         ;

       delete from pa_progress_rollup
       where project_id= p_project_id
         and object_id = p_object_id
         and current_flag = 'W'
         and proj_element_id = p_task_id
         and structure_type = p_structure_type
         and structure_version_id is null
         ;
    end if;
  --bug 4185364, end


  --bug 3879461
    --This code is required is PUBLISH mode  to delete working progress records on previous dates
    if  p_action = 'PUBLISH' and p_structure_type = 'WORKPLAN'
    then
       delete from pa_percent_completes
       where project_id= p_project_id
         and object_id = p_object_id
         and published_flag = 'N'
         and date_computed <= p_as_of_date   --bug 4247839, modified so that two records are not created for same as of date
         and structure_type = p_structure_type
         ;

       delete from pa_progress_rollup
       where project_id= p_project_id
         and object_id = p_object_id
         and current_flag = 'W'
         and as_of_date < p_as_of_date
         and structure_type = p_structure_type
         and structure_version_id is null
         ;
    end if;
  --bug 3879461


     -- It is possible to enter deliverable progress records even if it is not associated to a task

     IF p_task_id IS NULL or p_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        l_task_id := 0;
     ELSE
        l_task_id := p_task_id;
     END IF;
     --- 5194985 either task_id should be 0 or that of the task whose % comp deriv method is deliverable.
     begin
        SELECT ppe.proj_element_id
          into temp_task_id
          FROM pa_proj_elements ppe,
               pa_object_relationships por,
               pa_task_types ttype
          WHERE
             ppe.object_type = 'PA_TASKS'
          and por.object_id_to2 = p_object_id
          and ppe.proj_element_id = por.object_id_from2
          and por.object_type_to = 'PA_DELIVERABLES'
          and por.relationship_type = 'A'
          and por.relationship_subtype = 'TASK_TO_DELIVERABLE'
          and decode(ppe.base_percent_comp_deriv_code,null, ttype.base_percent_comp_deriv_code, '^', ttype.base_percent_comp_deriv_code, ppe.base_percent_comp_deriv_code)='DELIVERABLE'
          AND ppe.object_type ='PA_TASKS'
          AND ppe.type_id = ttype.task_type_id;
     exception when others then
        temp_task_id := 0;
     end;
     if nvl(temp_task_id,0) <> 0 then
        l_task_id := temp_task_id;
     end if;

     --- end 5194985
         -- Bug 3957792 : Commenting this check, deliverable is a separete entity and progress can be entered even if associated task is cancelled
     /*
         --Added for BUG 3762650, by rtarway, added check for task's cancelled status
         --if associated task status is CANCELLED, dlvr progress cant be entered
        IF PA_PROGRESS_UTILS.get_system_task_status(PA_PROGRESS_UTILS.get_task_status( p_project_id, l_task_id)) = 'CANCELLED'
        THEN
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_DLVR_CANT_NTER_PRG_CANCEL');
             x_msg_data := 'PA_TP_DLVR_CANT_NTER_PRG_CANCEL';
             x_return_status := 'E';
             RAISE  FND_API.G_EXC_ERROR;
        END IF;
    */

     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_task_id='||l_task_id, x_Log_Level=> 3);
     END IF;

     -- If deliverable is cancelled then progress can not be entered
     l_deliverable_status := PA_PROGRESS_UTILS.get_system_task_status(PA_PROGRESS_UTILS.get_task_status( p_project_id, p_object_id, 'PA_DELIVERABLES'),'PA_DELIVERABLES');

     -- Bug 6497559
     OPEN cur_get_del_type_prog_attr;
     FETCH cur_get_del_type_prog_attr INTO l_del_type_prog_enabled , l_dlvr_type_id , l_deliverable_existing_status, l_del_name ; --MSP Messages Change(changed position)
     CLOSE cur_get_del_type_prog_attr;

    --IF  ( l_deliverable_status = 'CANCELLED' OR l_deliverable_status = 'ON_HOLD' )
    -- rtarway Changed If condition, during BUG fix, 3668168 status comparison was wrong
    --IF  ( l_deliverable_status = 'DLVR_CANCELLED' OR l_deliverable_status = 'DLVR_ON_HOLD' )
    --Changed for BUG 3762650, by rtarway, removed check for DLVR_ON_HOLD status
    IF  ( l_deliverable_status = 'DLVR_CANCELLED')
    THEN
              PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_TP_CANT_NTER_DEL_CANCEL_AMG'
                                   ,p_token1 => 'DEL_NAME'   -- Bug 6497559
                                   ,p_value1 => l_del_name
                                  );
              x_msg_data := 'PA_TP_CANT_NTER_DEL_CANCEL_AMG';
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After Checking Deliverable Cancelled/On Hold Status', x_Log_Level=> 3);
    END IF;

     PA_PROGRESS_UTILS.get_project_progress_defaults(
             p_project_id                   => p_project_id
            ,p_structure_type               => 'WORKPLAN'
            ,x_WQ_ENABLED_FLAG              => l_wq_enabled_flag
            ,x_EFFORT_ENABLED_FLAG          => l_est_remaining_eff_flag
            ,x_PERCENT_COMP_ENABLED_FLAG    => l_percent_complete_flag
            ,x_task_weight_basis_code       => l_task_weight_basis_code
            ,X_ALLOW_COLLAB_PROG_ENTRY      => l_ALLOW_COLLAB_PROG_ENTRY
            ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES => l_ALLW_PHY_PRCNT_CMP_OVERRIDES
         );

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After getting the progress defaults from project level', x_Log_Level=> 3);
    END IF;


     --OPEN cur_get_del_type_prog_attr;
     --FETCH cur_get_del_type_prog_attr INTO l_del_type_prog_enabled , l_dlvr_type_id , l_deliverable_existing_status;
     --CLOSE cur_get_del_type_prog_attr;


     --OPEN cur_get_task_type_prog_attr;
     --FETCH cur_get_task_type_prog_attr INTO l_task_type_prog_enabled;
     --CLOSE cur_get_task_type_prog_attr;

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_del_type_prog_enabled='||l_del_type_prog_enabled, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_task_type_prog_enabled='||l_task_type_prog_enabled, x_Log_Level=> 3);
    END IF;

     IF (nvl(l_del_type_prog_enabled,'N') = 'N')
     THEN
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_TP_CANT_ENTER_DEL_PROG_AMG'
                               ,p_token1 => 'DEL_NAME'   -- Bug 6497559
                               ,p_value1 => l_del_name);
          x_msg_data := 'PA_TP_CANT_ENTER_DEL_PROG_AMG';
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_progress_mode <> 'FUTURE'
     THEN
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_TP_WRONG_PRG_MODE4');
          x_msg_data := 'PA_TP_WRONG_PRG_MODE4';
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_as_of_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_as_of_date IS NULL
     THEN
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_TP_INV_AOD_AMG'
                               ,p_token1 => 'DEL_NAME'   -- Bug 6497559
                               ,p_value1 => l_del_name);
          x_msg_data := 'PA_TP_INV_AOD';
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE  FND_API.G_EXC_ERROR;
     END IF;

/* FPM Dev CR 3
     IF p_progress_status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_progress_status_code IS NULL
     THEN
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_TP_INV_PRG_STAT');
           x_msg_data := 'PA_TP_INV_PRG_STAT';
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
     END IF;
*/
     -- FPM Dev CR 3 : Defaulting Progress Status
     IF p_progress_status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_progress_status_code IS NULL
     THEN
     l_progress_status_code := 'PROGRESS_STAT_ON_TRACK';
     ELSE
     l_progress_status_code := p_progress_status_code;
     END IF;

     IF p_del_status = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_del_status IS NULL
     THEN
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_INV_DLV_STAT_AMG'  -- Bug 6497559
                                  ,p_token1  => 'DEL_NAME'
                                  ,p_value1  => l_del_name
                                ); -- FPM Dev CR 1 : Changed message
             x_msg_data := 'PA_TP_INV_DLV_STAT_AMG';
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE  FND_API.G_EXC_ERROR;
     END IF;

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After mode, status, as of date check', x_Log_Level=> 3);
    END IF;

    -- 3982374 moved below deliverable status change validation after the code to change
    -- deliverable status based on physical % complete value

    -- changed the location of this api call because
    -- changing of deliverable status from the existing value to completed is done after this validation and becuase of
    -- this validation api was not getting the changed deliverable status ( completed status ) as parameter
    -- and user was able to complete the deliverable by entering physical % as 100 and completion date though deliverable
    -- completion validations are not satisfied

    /*
    IF (p_del_status <> l_deliverable_existing_status) THEN
         -- Check if the Deliverable Status can be changed
         PA_DELIVERABLE_UTILS.IS_DLV_STATUS_CHANGE_ALLOWED
            ( p_project_id             => p_project_id
             ,p_dlvr_item_id           => p_object_id
             ,p_dlvr_version_id        => p_object_version_id
             ,p_dlv_type_id            => l_dlvr_type_id
             ,p_dlvr_status_code       => p_del_status
             ,x_return_status          => l_return_status
             ,x_msg_count              => l_msg_count
             ,x_msg_data               => l_msg_data
            );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE  FND_API.G_EXC_ERROR;
         END IF;
         IF g1_debug_mode  = 'Y' THEN
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After Checking Deliverable Status Change allowed', x_Log_Level=> 3);
         END IF;
    END IF;
    */

    -- 3982374 end

    IF p_percent_complete = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
       l_percent_complete := 0;
    ELSE
       l_percent_complete := nvl(p_percent_complete,0);
    END IF;

    IF p_actual_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    THEN
       l_actual_finish_date := null;
    ELSE
       l_actual_finish_date := p_actual_finish_date;
    END IF;


    IF p_del_status = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_del_status := null;
    ELSE
       l_del_status := p_del_status;
    END IF;

    IF p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_pm_product_code := null;
    ELSE
       l_pm_product_code := p_pm_product_code;
    END IF;

    IF p_PROGRESS_COMMENT = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_PROGRESS_COMMENT := null;
    ELSE
       l_PROGRESS_COMMENT := p_PROGRESS_COMMENT;
    END IF;

    IF p_brief_overview = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
       l_brief_overview := null;
    ELSE
       l_brief_overview := p_brief_overview;
    END IF;

    IF (l_percent_complete < 0 or l_percent_complete > 100) THEN
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_PERC_COMP_INV_DLV_AMG'  -- Bug 6497559
                            ,p_token1  => 'DEL_NAME'
                            ,p_value1  => l_del_name
                          );
       x_msg_data := 'PA_PERC_COMP_INV_DLV_AMG';
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;


/*    IF (l_percent_complete < 100 AND l_percent_complete_flag = 'Y') THEN
         l_actual_finish_date := to_date(null);
    END IF; */ --- 3804420 ,instead throw an error

    -- Changed by rtarway for BUG 3668168
    --Moved from below , while fixing for 3668168
    -- Bug 3606627 : AMG Validation
    IF p_calling_module = 'AMG' THEN
    BEGIN
        SELECT 'x' INTO l_dummy
        FROM pa_project_statuses
        WHERE status_type = 'DELIVERABLE'
        AND project_status_code = l_del_status;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_TP_INV_DEL_STATUS',
                 P_TOKEN1         => 'OBJECT_ID',
                 P_VALUE1         => p_object_id);
            x_msg_data := 'PA_TP_INV_DEL_STATUS';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
    END;

    --l_task_id is validated in pa_status_pub itself
    --l_as_of_date is validated in pa_status_pub

    BEGIN
        SELECT 'xyz' INTO l_dummy
        FROM pa_project_statuses
        WHERE status_type = 'PROGRESS'
        AND project_status_code = l_progress_status_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_PROG_STATUS',
                 P_TOKEN1         => 'OBJECT_ID',
                 P_VALUE1         => p_object_id);
            x_msg_data := 'PA_INVALID_PROG_STATUS';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
    END;
    END IF; --p_calling_module = 'AMG'
    -- Moved this from below while fixing for 3668168
    -- Changed by rtarway for BUG 3668168

    -- Changed by rtarway for BUG 3668168, should use l_del_status
    --l_del_status2 := PA_PROGRESS_UTILS.get_system_task_status( p_del_status, 'PA_DELIVERABLES' );
    l_del_status2 := PA_PROGRESS_UTILS.get_system_task_status( l_del_status, 'PA_DELIVERABLES' );

    --Added by rtarway for BUG 3668168, if condition
    IF l_percent_complete_flag = 'Y' THEN
         /* Bug 3606627 Deleiverable Status Should be defaulted as done for tasks*/
         IF (
                 (l_percent_complete > 0 AND l_percent_complete < 100)
                      AND
                      ( l_del_status2 IS NULL
                           OR
                           --Added by rtarway for BUG 366168
                           (l_del_status2 = 'DLVR_NOT_STARTED')
                      )
                 --Commented by rtarway for BUG 366168
                 --(l_del_status2 IS NULL OR l_del_status2 <> 'DLVR_IN_PROGRESS')
            )
         THEN
          l_del_status2 := 'DLVR_IN_PROGRESS';
          l_del_status := 'DLVR_IN_PROGRESS';

         --Commented by rtarway, 3668168, this defaulting is not requird, user will get an error in this case
         /*ELSIF ( l_percent_complete = 0
                 AND
                 (
                   l_del_status2 IS NULL
                   OR
                  --Added by rtarway for BUG 366168
                  (l_del_status2 <> 'DLVR_NOT_STARTED' AND l_del_status2 <> 'DLVR_ON_HOLD' AND l_del_status2 <> 'DLVR_CANCELLED')
                  --Commented by rtarway for BUG 366168
                  --(l_del_status2 <> 'DLVR_NOT_STARTED')
                 )
               )
         THEN
          l_del_status2 := 'DLVR_NOT_STARTED';
          l_del_status := 'DLVR_NOT_STARTED';
          */
         -- Changed after BUG review 3668168
         ELSIF ( l_percent_complete = 100 AND (l_del_status2 IS NULL OR l_del_status2 <> 'DLVR_COMPLETED'))
         THEN
          l_del_status2 := 'DLVR_COMPLETED';
          l_del_status := 'DLVR_COMPLETED';
         END IF;


         IF g1_debug_mode  = 'Y' THEN
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Status and Date Combination check', x_Log_Level=> 3);
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_del_status2='||l_del_status2, x_Log_Level=> 3);
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_percent_complete='||l_percent_complete, x_Log_Level=> 3);
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_actual_finish_date='||l_actual_finish_date, x_Log_Level=> 3);
         END IF;


        IF l_del_status2 = 'DLVR_NOT_STARTED' AND NOT( l_actual_finish_date IS NULL AND l_percent_complete = 0) OR
           l_del_status2 = 'DLVR_IN_PROGRESS' AND NOT ( l_actual_finish_date IS NULL AND l_percent_complete > 0 AND l_percent_complete < 100 ) OR
           l_del_status2 = 'DLVR_COMPLETED' AND NOT ( l_actual_finish_date IS NOT NULL AND l_percent_complete = 100 ) OR
           (l_del_status2 is NULL) OR (l_del_status2 = '')
        THEN
         --Commented by rtarway for BUG 3668168, if condition
         --IF l_percent_complete_flag = 'Y'
         --THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_DELP_STAT_DTES_PC_COMB_AMG'
                                 ,p_token1  => 'DEL_NAME'  -- Bug 6497559
                                 ,p_value1  => l_del_name);
            x_msg_data := 'PA_DELP_STAT_DTES_PC_COMB_AMG';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
         --END IF;
        END IF;
    --Added by rtarway for BUG 3668168, Else if
    ELSIF l_percent_complete_flag = 'N'
    THEN
        IF l_percent_complete > 0
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_TP_PCC_DISABL_AMG'
                                ,p_token1 => 'TASK_NAME'  -- Bug 6497559
                                ,p_value1 => PA_TASK_UTILS.get_task_name(p_task_id)
                                ,p_token2 => 'TASK_NUMBER'
                                ,p_value2 => PA_TASK_UTILS.get_task_number(p_task_id)
                                ,p_token3 => 'PROJECT_NAME'
                                ,p_value3 => PA_TASK_UTILS.get_project_name(p_project_id)
                                ,p_token4 => 'PROJECT_NUMBER'
                                ,p_value4 => PA_TASK_UTILS.get_project_number(p_project_id));
            x_msg_data := 'PA_TP_PCC_DISABL_AMG';
            x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- Added by rtarway , date validation check
        IF l_del_status2 = 'DLVR_NOT_STARTED' AND NOT( l_actual_finish_date IS NULL ) OR
           l_del_status2 = 'DLVR_IN_PROGRESS' AND NOT ( l_actual_finish_date IS NULL ) OR
           l_del_status2 = 'DLVR_COMPLETED' AND NOT ( l_actual_finish_date IS NOT NULL ) OR
           (l_del_status2 is NULL) OR (l_del_status2 = '')
        THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_DELP_STAT_DTES_PC_COMB_AMG'
                                 ,p_token1  => 'DEL_NAME'  -- Bug 6497559
                                 ,p_value1  => l_del_name);
            x_msg_data := 'PA_DELP_STAT_DTES_PC_COMB_AMG';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- 3982374 Calling deliverable status change validation to check deliverable status
    -- change is allowed or not

    IF (l_del_status <> l_deliverable_existing_status) THEN
         -- Check if the Deliverable Status can be changed
         PA_DELIVERABLE_UTILS.IS_DLV_STATUS_CHANGE_ALLOWED
            ( p_project_id             => p_project_id
             ,p_dlvr_item_id           => p_object_id
             ,p_dlvr_version_id        => p_object_version_id
             ,p_dlv_type_id            => l_dlvr_type_id
             ,p_dlvr_status_code       => l_del_status
             ,x_return_status          => l_return_status
             ,x_msg_count              => l_msg_count
             ,x_msg_data               => l_msg_data
            );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE  FND_API.G_EXC_ERROR;
         END IF;
         IF g1_debug_mode  = 'Y' THEN
              pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After Checking Deliverable Status Change allowed', x_Log_Level=> 3);
         END IF;
    END IF;

    -- 3982374 end

    --Commented by rtarway, 3668168
    --Moved this code up while fixing for BUG 3668168
    /*
    -- Bug 3606627 : AMG Validation
    IF p_calling_module = 'AMG' THEN
    BEGIN
        SELECT 'x' INTO l_dummy
        FROM pa_project_statuses
        WHERE status_type = 'DELIVERABLE'
        AND project_status_code = l_del_status;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_TP_INV_DEL_STATUS',
                 P_TOKEN1         => 'OBJECT_ID',
                 P_VALUE1         => p_object_id);
            x_msg_data := 'PA_TP_INV_DEL_STATUS';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
    END;

    --l_task_id is validated in pa_status_pub itself
    --l_as_of_date is validated in pa_status_pub

    BEGIN
        SELECT 'xyz' INTO l_dummy
        FROM pa_project_statuses
        WHERE status_type = 'PROGRESS'
        AND project_status_code = l_progress_status_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_PROG_STATUS',
                 P_TOKEN1         => 'OBJECT_ID',
                 P_VALUE1         => p_object_id);
            x_msg_data := 'PA_INVALID_PROG_STATUS';
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE  FND_API.G_EXC_ERROR;
    END;
    END IF; --p_calling_module = 'AMG'
    */
    --Commented by rtarway, 3668168

     l_BASE_PERCENT_COMPLETE := l_percent_complete;
     l_BASE_PROGRESS_STATUS_CODE := l_progress_status_code;

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating progress outdated flag', x_Log_Level=> 3);
    END IF;

        --Update outdated flag back to 'N'
     UPDATE pa_proj_elements
     SET progress_outdated_flag = 'N'
     WHERE proj_element_id = p_object_id
     AND project_id = p_project_id
     AND object_type = p_object_type;

     -- FPM Dev CR 1 : Passed more parameters in the following call
     l_last_progress_date := PA_PROGRESS_UTILS.GET_LATEST_AS_OF_DATE(p_task_id => null, p_project_id=> p_project_id,p_object_id=> p_object_id, p_object_type=>p_object_type, p_structure_type=> p_structure_type );

     l_working_aod := PA_PROGRESS_UTILS.Working_version_exist(
                                      --p_task_id          => p_object_id        --bug# 3764224 Changes for RLM
                                      p_task_id          => null
                                     ,p_project_id         => p_project_id
                                     ,p_object_type        => p_object_type
                     ,p_object_id          => p_object_id        --bug# 3764224 Added for RLM
		     ,p_as_of_date       => p_as_of_date  --bug 4185364  get working records upto passed as of date as we dont want to
                     );                                    -- update future working records

     l_progress_exists_on_aod := PA_PROGRESS_UTILS.check_prog_exists_on_aod(
                                      --p_task_id          => p_object_id   --bug# 3764224 Changes for RLM
                                      p_task_id          => null
                                     ,p_as_of_date         => p_as_of_date
                                     ,p_project_id         => p_project_id
                                     ,p_object_version_id  => p_object_version_id
                                     ,p_object_type        => p_object_type
                     ,p_object_id          => p_object_id        --bug# 3764224 Added for RLM
                                    );

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_last_progress_date='||l_last_progress_date, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_working_aod='||l_working_aod, x_Log_Level=> 3);
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_progress_exists_on_aod='||l_progress_exists_on_aod, x_Log_Level=> 3);
    END IF;

        -- Percent Complete          Progress Rollup     Possible         Comments
        -- Insert                    Update              No               Applicable for summary level
        -- Insert                    Insert              Yes              Normal Case
        -- Update                    Insert              Yes              When You save on 1st March and Then publish on 8th March
        -- Update                    Update              Yes              Normal Case

     IF trunc(p_as_of_date) < trunc(NVL( l_last_progress_date, p_as_of_date ))
     --Commented by rtarway for Correction flow
     --AND l_working_aod IS NULL  -- progress exists after as of date
     THEN
           --You cannot create a future progress when there exists a progress
           --after AS_OF_DATE for this deliverable.
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TP_INV_AOD2');

           x_msg_data := 'PA_TP_WRONG_DEL_PRG_MODE3';
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        --Commented by rtarway for Correction flow
        -- FPM Dev CR 1 : Added the following IF condition
      /*ELSIF trunc(p_as_of_date) <= trunc(NVL( l_last_progress_date, p_as_of_date-1)) AND l_progress_exists_on_aod = 'PUBLISHED' THEN
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_INV_AOD2');
             x_msg_data := 'PA_TP_INV_AOD2';
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE  FND_API.G_EXC_ERROR;*/
       --End Commented by rtarway for Correction flow
      ELSE
           --Validate as of date
          -- Bug 3627315 : Check valid as of date should not be called from AMG or Task Progress Details page
      -- Beacuse from both the places we submit progress for all objects against one cycle date

           --bug 3994165, commmenting as as of date validation is not required
           /*IF p_calling_module <> 'AMG' -- Bug 3627315
              AND p_calling_module <> 'TASK_PROG_DET_PAGE' -- Bug 3627315
              AND PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE( p_as_of_date, p_project_id, p_object_id, 'PA_DELIVERABLES' ) = 'N'
              AND trunc(nvl(l_last_progress_date,p_as_of_date + 1 )) <> trunc(p_as_of_date)
           THEN
             --Add message
             --Invalid as of date
             --Message Changed by rtarway during Correction flow changes
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_INV_AOD2');
             x_msg_data := 'PA_TP_INV_AOD2';
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE  FND_API.G_EXC_ERROR;

           END IF;*/
           --
            --bug 4185364, not needed
	   /* Begin: Fix for Bug # 3958892. */

	   /*IF (p_as_of_date = NVL(l_last_progress_date, p_as_of_date + 1 ) AND  p_action = 'SAVE') THEN

       	   	if (l_working_aod = p_as_of_date) then
          		l_db_action := 'UPDATE';
       	   	else
          	 	l_db_action := 'CREATE';
       	   	end if;

	   ELSIF (p_as_of_date = NVL(l_last_progress_date, p_as_of_date + 1 ) AND  p_action = 'PUBLISH') THEN

           	 l_db_action := 'CREATE';

	   ELSE */

	   /* End: Fix for Bug # 3958892. */


           	IF l_progress_exists_on_aod = 'WORKING'
           	THEN
              	--update the existing working progress record ( publish and roll it only when p_action = 'PUBLISH' )
              		l_db_action := 'UPDATE';
           	ELSIF l_progress_exists_on_aod = 'PUBLISHED'
           	THEN
		    --bug 4185364, if correcting published record then action shud be update as we dont want to maintain history
		    -- of corrected records , if save then we will create new record.
		    IF p_action = 'PUBLISH' THEN
			l_db_action := 'UPDATE';
		    ELSE
			l_db_action := 'CREATE';
		    END IF;
               ELSIF l_progress_exists_on_aod = 'N'
           	THEN
              	--End Add 3595585
              	--Create a new working progress record.  ( publish and roll it only when p_action = 'PUBLISH' )
              	--1. if l_progress_exists_on_aod = 'PUBLISHED' then we create new record in ppc
              	--2. if l_progress_exists_on_aod = 'N' then new record in PR otherwise its an update to Progress Rollup
              		l_db_action := 'CREATE';
              		IF  l_working_aod IS NOT NULL  --now this case will never come
              		THEN
                		l_db_action := 'UPDATE';
              		END IF;
           	END IF;

	   /* Begin: Fix for Bug # 3958892. */

	   --END IF;

	   /* End: Fix for Bug # 3958892. */


      END IF;

    IF g1_debug_mode  = 'Y' THEN
         pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_db_action='||l_db_action, x_Log_Level=> 3);
    END IF;


    IF ( p_action = 'PUBLISH')
    THEN

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Action is Publish', x_Log_Level=> 3);
       END IF;

       l_published_flag        := 'Y';
       ----
       l_rollup_progress_status := l_progress_status_code;
       l_rollup_completed_percentage := l_percent_complete;
       l_rollup_current_flag := 'Y'; -- Bug 3879461

       l_current_flag          := 'Y';
        UPDATE pa_percent_completes
           SET current_flag = 'N'
          WHERE project_id = p_project_id
           AND object_id = p_object_id
           AND current_flag = 'Y'
           AND object_type = p_object_type
           AND structure_type = p_structure_type;

        UPDATE pa_progress_rollup
           SET current_flag = 'N'
          WHERE project_id = p_project_id
           AND object_id = p_object_id
           AND current_flag = 'Y'
           AND object_type = p_object_type
           AND structure_type = p_structure_type
           AND structure_version_id is NULL;

        -- Bug 3879461 Begin
    -- This case would not be possible for Deliverable, but still code is there to make it in sycn with Assignments Case
    -- IF l_db_action = 'UPDATE' THEN -- Commented to fix Bug # 3958892.
        /*
        -- Delete the published progress record on the same as of date
        DELETE FROM pa_progress_rollup
        where project_id = p_project_id
        and object_id = p_object_id
        and object_type = p_object_type
        and structure_version_id is null
        and structure_type = 'WORKPLAN'
        and current_flag = 'Y'
        and trunc(as_of_date) = trunc(p_as_of_date)
        and exists(select 1
                from pa_progress_rollup
                where project_id = p_project_id
                and object_id = p_object_id
                and object_type = p_object_type
                and structure_version_id is null
                and structure_type = 'WORKPLAN'
                and current_flag = 'W'
                and trunc(as_of_date) = trunc(p_as_of_date)
               );
        -- Update the  working progress record on the same as of date as published progress
        -- so that while updating rollup record its values can be considered
        -- Basically this is done so get_prog_rollup_id can return this row for update mode

        Update pa_progress_rollup
        set current_flag = 'Y'
        where project_id = p_project_id
        and object_id = p_object_id
        and object_type = p_object_type
        and structure_version_id is null
        and structure_type = 'WORKPLAN'
        and current_flag = 'W'
        and trunc(as_of_date) = trunc(p_as_of_date);
        */
        Delete from pa_progress_rollup
        where project_id = p_project_id
        and object_id = p_object_id
        and object_type = p_object_type
        and structure_version_id is null
        and structure_type = 'WORKPLAN'
        and current_flag = 'W'
        and trunc(as_of_date) <= trunc(p_as_of_date); -- Fix for Bug # 3958892.

    -- END IF; -- Commented to fix Bug # 3958892.
        -- Bug 3879461 End

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After updating percent complete and progress rollup current flag to N', x_Log_Level=> 3);
       END IF;

    ELSE
       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Action is Save', x_Log_Level=> 3);
       END IF;
       l_rollup_progress_status := null;
       l_rollup_completed_percentage := null;
       l_published_flag := 'N';
       l_current_flag := 'N'; -- FPM Dev CR 1
       l_rollup_current_flag := 'W'; -- Bug 3879461
    END IF;

    l_prog_pa_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(p_as_of_date),null);
    l_prog_gl_period_name := nvl(PA_PROGRESS_UTILS.Prog_Get_GL_Period_Name(p_as_of_date),null);


    IF l_db_action = 'CREATE'
    THEN

      -- IF p_percent_complete_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_percent_complete_id IS NULL
       --THEN
           l_percent_complete_id := null;
       --ELSE
        --   l_percent_complete_id := p_percent_complete_id;
       --END IF;


       l_att_pc_id := p_percent_complete_id;

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'DB Action is Create', x_Log_Level=> 3);
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Going to Insert in percent complete table', x_Log_Level=> 3);
       END IF;

             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Going to Insert in percent complete tables l_percent_complete_id='||l_percent_complete_id, x_Log_Level=> 3);

       PA_PERCENT_COMPLETES_PKG.INSERT_ROW(
                      p_TASK_ID                 => l_task_id
                      ,p_DATE_COMPUTED           => p_as_of_date
                      ,p_LAST_UPDATE_DATE        => SYSDATE
                      ,p_LAST_UPDATED_BY         => l_user_id
                      ,p_CREATION_DATE           => SYSDATE
                      ,p_CREATED_BY              => l_user_id
                      ,p_LAST_UPDATE_LOGIN       => l_login_id
                      ,p_COMPLETED_PERCENTAGE    => l_percent_complete
                      ,p_DESCRIPTION             => l_brief_overview
                      ,p_PROJECT_ID              => p_project_id
                      ,p_PM_PRODUCT_CODE         => l_pm_product_code
                      ,p_CURRENT_FLAG            => l_current_flag
                      ,p_OBJECT_TYPE             => p_object_type
                      ,p_OBJECT_ID               => p_object_id
                      ,p_OBJECT_VERSION_ID       => p_object_version_id
                      ,p_PROGRESS_STATUS_CODE    => l_progress_status_code
                      ,p_ACTUAL_START_DATE       => null
                      ,p_ACTUAL_FINISH_DATE      => l_actual_finish_date
                      ,p_ESTIMATED_START_DATE    => null
                      ,p_ESTIMATED_FINISH_DATE   => null
                      ,p_PUBLISHED_FLAG          => l_published_flag
                      ,p_PUBLISHED_BY_PARTY_ID   => l_published_by_party_id
                      ,p_PROGRESS_COMMENT        => l_PROGRESS_COMMENT
                      ,p_HISTORY_FLAG            => 'N'
                      ,p_status_code             => l_del_status
                      ,x_PERCENT_COMPLETE_ID     => l_percent_complete_id
                      ,p_ATTRIBUTE_CATEGORY              => null
                      ,p_ATTRIBUTE1                      => null
                      ,p_ATTRIBUTE2                      => null
                      ,p_ATTRIBUTE3                      => null
                      ,p_ATTRIBUTE4                      => null
                      ,p_ATTRIBUTE5                      => null
                      ,p_ATTRIBUTE6                      => null
                      ,p_ATTRIBUTE7                      => null
                      ,p_ATTRIBUTE8                      => null
                      ,p_ATTRIBUTE9                      => null
                      ,p_ATTRIBUTE10                     => null
                      ,p_ATTRIBUTE11                     => null
                      ,p_ATTRIBUTE12                     => null
                      ,p_ATTRIBUTE13                     => null
                      ,p_ATTRIBUTE14                     => null
                      ,p_ATTRIBUTE15                     => null
                      ,p_structure_type                  => p_structure_type
                    );

        -- FPM Dev CR 3 : Raising Error
     IF Fnd_Msg_Pub.count_msg > 0 THEN
          RAISE  FND_API.G_EXC_ERROR;
     END IF;



            pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Going to Insert in percent complete tablessaasasas', x_Log_Level=> 3);

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'After perrcent complete', x_Log_Level=> 3);
       END IF;


       l_PROGRESS_ROLLUP_ID := null;
       --Create record in progress rollup

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Getting rollup id', x_Log_Level=> 3);
       END IF;

       l_PROGRESS_ROLLUP_ID := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                   p_project_id   => p_project_id
                                  ,p_object_id    => p_object_id
                                  ,p_object_type  => p_object_type
                                  ,p_object_version_id => p_object_version_id
                                  ,p_as_of_date   => p_as_of_date
                  ,p_action       => p_action -- Bug 3879461
                                  ,x_record_version_number => l_rollup_rec_ver_number
                                );

       IF g1_debug_mode  = 'Y' THEN
             pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_PROGRESS_ROLLUP_ID='||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
       END IF;


       IF l_PROGRESS_ROLLUP_ID IS NULL
       THEN
              l_EFF_ROLLUP_PERCENT_COMP       := null;
              l_EFF_ROLLUP_PROG_STAT_CODE     := null;

               IF g1_debug_mode  = 'Y' THEN
                     pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'INserting in progress rollup table', x_Log_Level=> 3);
               END IF;


                  PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => p_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                      ,X_OBJECT_VERSION_ID               => p_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
                      ,X_PROGRESS_STATUS_CODE            => l_progress_status_code
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_EFF_ROLLUP_PERCENT_COMP
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => null
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_date
                      ,X_EST_REMAINING_EFFORT            => null
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,x_percent_complete_id              => l_percent_complete_id
                      ,X_STRUCTURE_TYPE                   => p_structure_type
                      --,X_PROJ_ELEMENT_ID                  => null  --bug# 3799060 For deliverables proj_element_id should be populated. It is a must.
                      ,X_PROJ_ELEMENT_ID                  => l_task_id
                      ,X_STRUCTURE_VERSION_ID            => null
                      ,X_PPL_ACT_EFFORT_TO_DATE          => null
                      ,X_EQPMT_ACT_EFFORT_TO_DATE        => null
                      ,X_EQPMT_ETC_EFFORT                => null
                      ,X_OTH_ACT_COST_TO_DATE_TC        => null
                      ,X_OTH_ACT_COST_TO_DATE_FC        => null
                      ,X_OTH_ACT_COST_TO_DATE_PC        => null
                      ,X_OTH_ETC_COST_TC                     => null
                      ,X_OTH_ETC_COST_FC                     => null
                      ,X_OTH_ETC_COST_PC                     => null
                      ,X_PPL_ACT_COST_TO_DATE_TC   => null
                      ,X_PPL_ACT_COST_TO_DATE_FC   => null
                      ,X_PPL_ACT_COST_TO_DATE_PC   => null
                      ,X_PPL_ETC_COST_TC                 => null
                      ,X_PPL_ETC_COST_FC                 => null
                      ,X_PPL_ETC_COST_PC                 => null
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => null
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => null
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => null
                      ,X_EQPMT_ETC_COST_TC               => null
                      ,X_EQPMT_ETC_COST_FC               => null
                      ,X_EQPMT_ETC_COST_PC               => null
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC              => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC              => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC              => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                     ,X_SUBPRJ_EARNED_VALUE             => null
                     ,X_CURRENT_FLAG               =>  l_rollup_current_flag -- Bug 3879461 l_current_flag
                     ,X_PROJFUNC_COST_RATE_TYPE        => null
                     ,X_PROJFUNC_COST_EXCHANGE_RATE        => null
                     ,X_PROJFUNC_COST_RATE_DATE        => null
                     ,X_PROJ_COST_RATE_TYPE        => null
                     ,X_PROJ_COST_EXCHANGE_RATE        => null
                     ,X_PROJ_COST_RATE_DATE        => null
                     ,X_TXN_CURRENCY_CODE      => null
                     ,X_PROG_PA_PERIOD_NAME    => l_prog_pa_period_name
                     ,X_PROG_GL_PERIOD_NAME    => l_prog_gl_period_name
                     --Added by rtarway BUG 3608801
                     ,X_OTH_QUANTITY_TO_DATE   => null
                     ,X_OTH_ETC_QUANTITY       => null
                     --End Added by rtarway BUG 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_OTH_ETC_RAWCOST_TC  => null
                      ,X_OTH_ETC_RAWCOST_FC  => null
                      ,X_OTH_ETC_RAWCOST_PC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_PPL_ETC_RAWCOST_TC  => null
                      ,X_PPL_ETC_RAWCOST_FC  => null
                      ,X_PPL_ETC_RAWCOST_PC  => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => null
                      ,X_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_EQPMT_ETC_RAWCOST_PC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
                  );


          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;


       ELSE
       ---update progress rollup
       -- This is not possible at lowest level that is delievrable and assignments. But still let code be there.

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating in progress rollup table', x_Log_Level=> 3);
            END IF;


           PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => p_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                      ,X_OBJECT_VERSION_ID               => p_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_PROGRESS_STATUS_CODE            => l_progress_status_code
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => null
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => null
                      ,X_ACTUAL_FINISH_DATE              => l_ACTUAL_FINISH_DATE
                      ,X_EST_REMAINING_EFFORT            => null
                      ,X_RECORD_VERSION_NUMBER           => l_rollup_rec_ver_number
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,X_PERCENT_COMPLETE_ID             => l_percent_complete_id
                      ,X_STRUCTURE_TYPE                  => p_structure_type
                      --,X_PROJ_ELEMENT_ID                 => null --bug# 3799060 For deliverables proj_element_id should be populated. It is a must.
                      ,X_PROJ_ELEMENT_ID                  => l_task_id
                      ,X_STRUCTURE_VERSION_ID            => null
                      ,X_PPL_ACT_EFFORT_TO_DATE         => null
                      ,X_EQPMT_ACT_EFFORT_TO_DATE     => null
                      ,X_EQPMT_ETC_EFFORT                => null
                      ,X_OTH_ACT_COST_TO_DATE_TC          => null
                      ,X_OTH_ACT_COST_TO_DATE_FC          => null
                      ,X_OTH_ACT_COST_TO_DATE_PC         => null
                      ,X_OTH_ETC_COST_TC                     => null
                      ,X_OTH_ETC_COST_FC                     => null
                      ,X_OTH_ETC_COST_PC                     => null
                      ,X_PPL_ACT_COST_TO_DATE_TC     => null
                      ,X_PPL_ACT_COST_TO_DATE_FC     => null
                      ,X_PPL_ACT_COST_TO_DATE_PC    => null
                      ,X_PPL_ETC_COST_TC                 => null
                      ,X_PPL_ETC_COST_FC                 => null
                      ,X_PPL_ETC_COST_PC                 => null
                      ,X_EQPMT_ACT_COST_TO_DATE_TC     => null
                      ,X_EQPMT_ACT_COST_TO_DATE_FC     => null
                      ,X_EQPMT_ACT_COST_TO_DATE_PC     => null
                      ,X_EQPMT_ETC_COST_TC               => null
                      ,X_EQPMT_ETC_COST_FC               => null
                      ,X_EQPMT_ETC_COST_PC               => null
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT          => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT        => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT          => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT        => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC                => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC                => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC                => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC            => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC            => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC            => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC          => null
                      ,X_SUBPRJ_EARNED_VALUE            => null
                     ,X_CURRENT_FLAG               =>  l_rollup_current_flag -- Bug 3879461 l_current_flag
                     ,X_PROJFUNC_COST_RATE_TYPE        => null
                     ,X_PROJFUNC_COST_EXCHANGE_RATE        => null
                     ,X_PROJFUNC_COST_RATE_DATE        => null
                     ,X_PROJ_COST_RATE_TYPE        => null
                     ,X_PROJ_COST_EXCHANGE_RATE        => null
                     ,X_PROJ_COST_RATE_DATE        => null
                     ,X_TXN_CURRENCY_CODE    => null
                     ,X_PROG_PA_PERIOD_NAME    => l_prog_pa_period_name
                     ,X_PROG_GL_PERIOD_NAME    => l_prog_gl_period_name
                      --Added by rtarway BUG 3608801
                     ,X_OTH_QUANTITY_TO_DATE           => null
                     ,X_OTH_ETC_QUANTITY       => null
                      --End Added by rtarway BUG 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_OTH_ETC_RAWCOST_TC  => null
                      ,X_OTH_ETC_RAWCOST_FC  => null
                      ,X_OTH_ETC_RAWCOST_PC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_PPL_ETC_RAWCOST_TC  => null
                      ,X_PPL_ETC_RAWCOST_FC  => null
                      ,X_PPL_ETC_RAWCOST_PC  => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => null
                      ,X_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_EQPMT_ETC_RAWCOST_PC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
                  );

          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

        END IF;


    ELSIF l_db_action = 'UPDATE'
    THEN

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'DB Action is Update', x_Log_Level=> 3);
            END IF;

        IF  l_working_aod IS NOT NULL
        THEN
            l_aod := l_working_aod;
        ELSE
            l_aod := p_as_of_date;
        END IF;

       IF p_percent_complete_id IS NULL OR p_percent_complete_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       THEN
           l_percent_complete_id := PA_PROGRESS_UTILS.get_ppc_id(
                                   p_project_id   => p_project_id
                                  ,p_object_id    => p_object_id
                                  ,p_object_type  => p_object_type
                                  ,p_object_version_id => p_object_version_id
                                  ,p_as_of_date   => l_aod
                                );
           -- FPM Dev CR 3 Getting Record Version Number too
        BEGIN
          SELECT record_version_number into l_record_version_number
          FROM pa_percent_completes
          where percent_complete_id = l_percent_complete_id;
        END;
       ELSE
          l_percent_complete_id := p_percent_complete_id;
       l_record_version_number := p_record_version_number;
       END IF;

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating Percent Complete l_percent_complete_id='||l_percent_complete_id, x_Log_Level=> 3);
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating Percent Completel_record_version_number='||l_record_version_number, x_Log_Level=> 3);
            END IF;

        PA_PERCENT_COMPLETES_PKG.UPDATE_ROW(
                       p_TASK_ID                 => l_task_id
                      ,p_DATE_COMPUTED           => p_as_of_date
                      ,p_LAST_UPDATE_DATE        => SYSDATE
                      ,p_LAST_UPDATED_BY         => l_user_id
                      ,p_LAST_UPDATE_LOGIN       => l_login_id
                      ,p_COMPLETED_PERCENTAGE    => l_percent_complete
                      ,p_DESCRIPTION             => l_brief_overview
                      ,p_PROJECT_ID              => p_project_id
                      ,p_PM_PRODUCT_CODE         => l_pm_product_code
                      ,p_CURRENT_FLAG            => l_current_flag
                      ,p_OBJECT_TYPE             => p_object_type
                      ,p_OBJECT_ID               => p_object_id
                      ,p_OBJECT_VERSION_ID       => p_object_version_id
                      ,p_PROGRESS_STATUS_CODE    => l_progress_status_code
                      ,p_ACTUAL_START_DATE       => null
                      ,p_ACTUAL_FINISH_DATE      => l_actual_finish_date
                      ,p_ESTIMATED_START_DATE    => null
                      ,p_ESTIMATED_FINISH_DATE   => null
                      ,p_PUBLISHED_FLAG          => l_published_flag
                      ,p_PUBLISHED_BY_PARTY_ID   => l_published_by_party_id
                      ,p_PROGRESS_COMMENT        => l_PROGRESS_COMMENT
                      ,p_HISTORY_FLAG            => 'N'
                      ,p_status_code             => l_del_status
                      ,p_RECORD_VERSION_NUMBER    => l_record_version_number
                      ,p_PERCENT_COMPLETE_ID     => l_percent_complete_id
                      ,p_ATTRIBUTE_CATEGORY              => null
                      ,p_ATTRIBUTE1                      => null
                      ,p_ATTRIBUTE2                      => null
                      ,p_ATTRIBUTE3                      => null
                      ,p_ATTRIBUTE4                      => null
                      ,p_ATTRIBUTE5                      => null
                      ,p_ATTRIBUTE6                      => null
                      ,p_ATTRIBUTE7                      => null
                      ,p_ATTRIBUTE8                      => null
                      ,p_ATTRIBUTE9                      => null
                      ,p_ATTRIBUTE10                     => null
                      ,p_ATTRIBUTE11                     => null
                      ,p_ATTRIBUTE12                     => null
                      ,p_ATTRIBUTE13                     => null
                      ,p_ATTRIBUTE14                     => null
                      ,p_ATTRIBUTE15                     => null
                      ,p_structure_type                  => p_structure_type

               );

          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

        l_PROGRESS_ROLLUP_ID := PA_PROGRESS_UTILS.get_prog_rollup_id(
                                   p_project_id   => p_project_id
                                  ,p_object_id    => p_object_id
                                  ,p_object_type  => p_object_type
                                  ,p_object_version_id => p_object_version_id
                                  ,p_as_of_date   => l_aod -- FPM Dev CR 3 : Using l_aod instead of p_as_of_date
                  ,p_action                 => p_action -- Bug 3879461
                                  ,x_record_version_number => l_rollup_rec_ver_number
                                );


            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'l_PROGRESS_ROLLUP_ID='||l_PROGRESS_ROLLUP_ID, x_Log_Level=> 3);
            END IF;

           IF l_PROGRESS_ROLLUP_ID IS NOT NULL
           THEN

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating progress rollup table', x_Log_Level=> 3);
            END IF;

               PA_PROGRESS_ROLLUP_PKG.UPDATE_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => p_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                      ,X_OBJECT_VERSION_ID               => p_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_PROGRESS_STATUS_CODE            => l_progress_status_code
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => null
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => null
                      ,X_ACTUAL_FINISH_DATE              => l_ACTUAL_FINISH_DATE
                      ,X_EST_REMAINING_EFFORT            => null
                      ,X_RECORD_VERSION_NUMBER           => l_rollup_rec_ver_number
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,X_PERCENT_COMPLETE_ID             => l_percent_complete_id
                      ,X_STRUCTURE_TYPE                  => p_structure_type
                      --,X_PROJ_ELEMENT_ID                 => null --bug# 3799060 For deliverables proj_element_id should be populated. It is a must.
              ,X_PROJ_ELEMENT_ID                 => l_task_id
                      ,X_STRUCTURE_VERSION_ID            => null
                      ,X_PPL_ACT_EFFORT_TO_DATE         => null
                      ,X_EQPMT_ACT_EFFORT_TO_DATE     => null
                      ,X_EQPMT_ETC_EFFORT                => null
                      ,X_OTH_ACT_COST_TO_DATE_TC          => null
                      ,X_OTH_ACT_COST_TO_DATE_FC          => null
                      ,X_OTH_ACT_COST_TO_DATE_PC         => null
                      ,X_OTH_ETC_COST_TC                     => null
                      ,X_OTH_ETC_COST_FC                     => null
                      ,X_OTH_ETC_COST_PC                     => null
                      ,X_PPL_ACT_COST_TO_DATE_TC     => null
                      ,X_PPL_ACT_COST_TO_DATE_FC     => null
                      ,X_PPL_ACT_COST_TO_DATE_PC    => null
                      ,X_PPL_ETC_COST_TC                 => null
                      ,X_PPL_ETC_COST_FC                 => null
                      ,X_PPL_ETC_COST_PC                 => null
                      ,X_EQPMT_ACT_COST_TO_DATE_TC     => null
                      ,X_EQPMT_ACT_COST_TO_DATE_FC     => null
                      ,X_EQPMT_ACT_COST_TO_DATE_PC     => null
                      ,X_EQPMT_ETC_COST_TC               => null
                      ,X_EQPMT_ETC_COST_FC               => null
                      ,X_EQPMT_ETC_COST_PC               => null
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT          => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT        => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT          => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT        => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC                => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC                => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC                => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC            => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC            => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC            => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC          => null
                      ,X_SUBPRJ_EARNED_VALUE            => null
                     ,X_CURRENT_FLAG               =>  l_rollup_current_flag -- Bug 3879461 l_current_flag
                     ,X_PROJFUNC_COST_RATE_TYPE        => null
                     ,X_PROJFUNC_COST_EXCHANGE_RATE        => null
                     ,X_PROJFUNC_COST_RATE_DATE        => null
                     ,X_PROJ_COST_RATE_TYPE        => null
                     ,X_PROJ_COST_EXCHANGE_RATE        => null
                     ,X_PROJ_COST_RATE_DATE        => null
                     ,X_TXN_CURRENCY_CODE    => null
                     ,X_PROG_PA_PERIOD_NAME    => l_prog_pa_period_name
                     ,X_PROG_GL_PERIOD_NAME    => l_prog_gl_period_name
                      --Added by rtarway BUG 3608801
                     ,X_OTH_QUANTITY_TO_DATE           => null
                     ,X_OTH_ETC_QUANTITY       => null
                     --End Added by rtarway BUG 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_OTH_ETC_RAWCOST_TC  => null
                      ,X_OTH_ETC_RAWCOST_FC  => null
                      ,X_OTH_ETC_RAWCOST_PC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_PPL_ETC_RAWCOST_TC  => null
                      ,X_PPL_ETC_RAWCOST_FC  => null
                      ,X_PPL_ETC_RAWCOST_PC  => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => null
                      ,X_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_EQPMT_ETC_RAWCOST_PC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
                  );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

              ELSE

                      l_EFF_ROLLUP_PERCENT_COMP       := null;
                      l_EFF_ROLLUP_PROG_STAT_CODE     := null;

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Inserting progress rollup table', x_Log_Level=> 3);
            END IF;

                  PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_PROGRESS_ROLLUP_ID
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => p_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => p_as_of_date
                      ,X_OBJECT_VERSION_ID               => p_object_version_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
                      ,X_PROGRESS_STATUS_CODE            => l_progress_status_code
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => l_BASE_PERCENT_COMPLETE
                      ,X_EFF_ROLLUP_PERCENT_COMP         => null
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => null
                      ,X_ACTUAL_FINISH_DATE              => l_ACTUAL_FINISH_DATE
                      ,X_EST_REMAINING_EFFORT            => null
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => l_BASE_PROGRESS_STATUS_CODE
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,x_percent_complete_id             => l_percent_complete_id  ---bug.3927389
                      ,X_STRUCTURE_TYPE                  => p_structure_type
                      --,X_PROJ_ELEMENT_ID                  => null --bug# 3799060 For deliverables proj_element_id should be populated. It is a must.
              ,X_PROJ_ELEMENT_ID                  => l_task_id
                      ,X_STRUCTURE_VERSION_ID            => null
                      ,X_PPL_ACT_EFFORT_TO_DATE          => null
                      ,X_EQPMT_ACT_EFFORT_TO_DATE        => null
                      ,X_EQPMT_ETC_EFFORT                => null
                      ,X_OTH_ACT_COST_TO_DATE_TC        => null
                      ,X_OTH_ACT_COST_TO_DATE_FC        => null
                      ,X_OTH_ACT_COST_TO_DATE_PC        => null
                      ,X_OTH_ETC_COST_TC                     => null
                      ,X_OTH_ETC_COST_FC                     => null
                      ,X_OTH_ETC_COST_PC                     => null
                      ,X_PPL_ACT_COST_TO_DATE_TC   => null
                      ,X_PPL_ACT_COST_TO_DATE_FC   => null
                      ,X_PPL_ACT_COST_TO_DATE_PC   => null
                      ,X_PPL_ETC_COST_TC                 => null
                      ,X_PPL_ETC_COST_FC                 => null
                      ,X_PPL_ETC_COST_PC                 => null
                      ,X_EQPMT_ACT_COST_TO_DATE_TC      => null
                      ,X_EQPMT_ACT_COST_TO_DATE_FC      => null
                      ,X_EQPMT_ACT_COST_TO_DATE_PC      => null
                      ,X_EQPMT_ETC_COST_TC               => null
                      ,X_EQPMT_ETC_COST_FC               => null
                      ,X_EQPMT_ETC_COST_PC               => null
                      ,X_EARNED_VALUE                    => null
                      ,X_TASK_WT_BASIS_CODE              => null
                      ,X_SUBPRJ_PPL_ACT_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ACT_EFFORT         => null
                      ,X_SUBPRJ_PPL_ETC_EFFORT           => null
                      ,X_SUBPRJ_EQPMT_ETC_EFFORT         => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC    => null
                      ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_COST_TC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_FC          => null
                      ,X_SUBPRJ_PPL_ACT_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ACT_COST_PC        => null
                      ,X_SUBPRJ_OTH_ETC_COST_TC              => null
                      ,X_SUBPRJ_OTH_ETC_COST_FC              => null
                      ,X_SUBPRJ_OTH_ETC_COST_PC              => null
                      ,X_SUBPRJ_PPL_ETC_COST_TC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_FC          => null
                      ,X_SUBPRJ_PPL_ETC_COST_PC          => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_TC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_FC        => null
                      ,X_SUBPRJ_EQPMT_ETC_COST_PC        => null
                     ,X_SUBPRJ_EARNED_VALUE             => null
                     ,X_CURRENT_FLAG               =>  l_rollup_current_flag -- Bug 3879461 l_current_flag
                     ,X_PROJFUNC_COST_RATE_TYPE        => null
                     ,X_PROJFUNC_COST_EXCHANGE_RATE        => null
                     ,X_PROJFUNC_COST_RATE_DATE        => null
                     ,X_PROJ_COST_RATE_TYPE        => null
                     ,X_PROJ_COST_EXCHANGE_RATE        => null
                     ,X_PROJ_COST_RATE_DATE        => null
                     ,X_TXN_CURRENCY_CODE    => null
                     ,X_PROG_PA_PERIOD_NAME    => l_prog_pa_period_name
                     ,X_PROG_GL_PERIOD_NAME    => l_prog_gl_period_name
                      --Added by rtarway BUG 3608801
                     ,X_OTH_QUANTITY_TO_DATE           => null
                     ,X_OTH_ETC_QUANTITY       => null
                     --End Added by rtarway BUG 3608801
                      ,X_OTH_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_OTH_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_OTH_ETC_RAWCOST_TC  => null
                      ,X_OTH_ETC_RAWCOST_FC  => null
                      ,X_OTH_ETC_RAWCOST_PC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_TC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_FC  => null
                      ,X_PPL_ACT_RAWCOST_TO_DATE_PC  => null
                      ,X_PPL_ETC_RAWCOST_TC  => null
                      ,X_PPL_ETC_RAWCOST_FC  => null
                      ,X_PPL_ETC_RAWCOST_PC  => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC    => null
                      ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC    => null
                      ,X_EQPMT_ETC_RAWCOST_TC    => null
                      ,X_EQPMT_ETC_RAWCOST_FC    => null
                      ,X_EQPMT_ETC_RAWCOST_PC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                      ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ACT_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_OTH_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_TC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_FC   => null
                      ,X_SUBPRJ_PPL_ETC_RAWCOST_PC   => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                      ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
                  );
          IF Fnd_Msg_Pub.count_msg > 0 THEN
               RAISE  FND_API.G_EXC_ERROR;
          END IF;

                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Inserting progress rollup table', x_Log_Level=> 3);
              END IF;
    END IF;  --<l_db_action>

    IF p_action = 'PUBLISH'
    THEN

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating Deliverable status', x_Log_Level=> 3);
            END IF;

      --Update pa_proj_elements with the status
         UPDATE pa_proj_elements
            SET status_code = l_del_status
          WHERE proj_element_id = p_object_id
            AND project_id = p_project_id
            AND object_type = p_object_type;

      -- FPM Dev CR 1 : Added the following update
         UPDATE pa_proj_elem_ver_schedule
            SET actual_finish_date = l_actual_finish_date
          WHERE project_id = p_project_id
            AND proj_element_id = p_object_id
            AND element_version_id = p_object_version_id ;


        /* -- FPM Dev CR 1 : Commented the code
     OPEN cur_sch_id( p_object_version_id );
        FETCH cur_sch_id INTO l_pev_schedule_id, l_sch_rec_ver_number, l_actual_start_date, l_estimated_start_date, l_estimated_finish_date ;
        CLOSE cur_sch_id;

        IF g1_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'Updating Schedule version', x_Log_Level=> 3);
        END IF;

        PA_TASK_PUB1.Update_Schedule_Version(
                                  p_pev_schedule_id             => l_pev_schedule_id
                                 ,p_calling_module              => p_calling_module
                                 ,p_actual_start_date           => l_actual_start_date
                                 ,p_actual_finish_date          => l_actual_finish_date
                                 ,p_estimate_start_date         => l_estimated_start_date
                                 ,p_estimate_finish_date        => l_estimated_finish_date
                                 ,p_record_version_number       => l_sch_rec_ver_number
                                 ,x_return_status               => l_return_status
                                 ,x_msg_count                   => l_msg_count
                                 ,x_msg_data                    => l_msg_data );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_msg_data
                  );
           x_msg_data := l_msg_data;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
     */

    END IF;

            IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write(x_Module=>'PA_DELIVERABLE_PROGRESS_PUB.UPDATE_DELIVERABLE_PROGRESS', x_Msg => 'End', x_Log_Level=> 3);
            END IF;


EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := Fnd_Msg_Pub.count_msg;

      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_DELIVERABLE_PROGRESS;
      end if;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;


    when FND_API.G_EXC_UNEXPECTED_ERROR then
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_DELIVERABLE_PROGRESS;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DELIVERABLE_PROGRESS_PUB',
                              p_procedure_name => 'UPDATE_DELIVERABLE_PROGRESS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SUBSTRB(SQLERRM,1,240);
      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_DELIVERABLE_PROGRESS;
      end if;

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DELIVERABLE_PROGRESS_PUB',
                              p_procedure_name => 'UPDATE_DELIVERABLE_PROGRESS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;


END UPDATE_DELIVERABLE_PROGRESS;


end PA_DELIVERABLE_PROGRESS_PUB;

/
