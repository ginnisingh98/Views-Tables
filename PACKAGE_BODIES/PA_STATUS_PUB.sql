--------------------------------------------------------
--  DDL for Package Body PA_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_PUB" AS
/* $Header: PAPMSTPB.pls 120.11.12010000.6 2010/06/24 00:03:29 rbruno ship $*/
-- =========================================================================
--
-- Name:                Update_Progress
-- Type:                PL/SQL Procedure
-- Decscription:        This procedure updates the PA_CUR_WBS_PERCENT_COMPLETE table.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--                      , Convert_Pm_Taskref_To_Id
-- History:     08-AUG-96       Created jwhite
--              29-AUG-96       Update  jwhite  Applied latest messaging standards.
--              27-SEP-96       Update  jwhite  As per Ashwani's direction, if Update_Progress
--                                              can't find a row to update, it inserts it.
--              01-MAY-97       Updated jwhite  Gutted/Rewrote api as per jlowel's
--                                              specification changes.
--

g_task_version_id_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); -- Bug 4218507

PROCEDURE UPDATE_PROGRESS
( p_api_version_number          IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id                     IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_as_of_date                  IN      DATE
, p_percent_complete            IN      NUMBER
, p_pm_product_code             IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_description                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_object_id                   IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_object_version_id           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_object_type                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_progress_status_code        IN      VARCHAR2        := 'PROGRESS_STAT_ON_TRACK'
, p_progress_comment            IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_actual_start_date           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_actual_finish_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_estimated_start_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_estimated_finish_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_scheduled_start_date        IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_scheduled_finish_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, p_task_status                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
, p_est_remaining_effort        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_actual_work_quantity        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_etc_cost                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  /* FP M Task Progress 3420093*/
, p_pm_deliverable_reference    IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3606627
, p_pm_task_assgn_reference     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3606627
, p_actual_cost_to_date         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3606627
, p_actual_effort_to_date       IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  -- Bug 3606627
, p_populate_pji_tables         IN      VARCHAR2        := 'Y'  -- Bug 3606627
, p_rollup_entire_wbs         IN      VARCHAR2          := 'N'  -- Bug 3606627
, p_txn_currency_code           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                                                        -- Fix for Bug # 3988457.
)
IS

l_api_version_number            CONSTANT        NUMBER                          := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT        VARCHAR2(30)                    := 'UPDATE_PROGRESS';
l_value_conversion_error        BOOLEAN                                         := FALSE;
l_return_status                 VARCHAR2(1);
l_msg_count                     INTEGER;

l_err_code                      NUMBER                                          :=  -1;
l_err_stage                     VARCHAR2(2000)                                  := NULL;
l_err_stack                     VARCHAR2(2000)                                  := NULL;

l_project_id_out                NUMBER                                          := 0;
l_task_id_out                   NUMBER                                          := 0;
l_msg_data                      VARCHAR2(2000);
l_function_allowed              VARCHAR2(1);
l_resp_id                       NUMBER                                          := 0;
l_pm_product_code               pa_percent_completes.pm_product_code%TYPE       := NULL;
l_description                   pa_percent_completes.description%TYPE           := NULL;
l_as_of_date                    DATE;
l_current_flag                  VARCHAR2(1);
l_dummy                         VARCHAR2(1);
l_module_name                   VARCHAR2(80);
l_user_id                       NUMBER                                          := 0;
l_date_computed                 DATE;

l_object_type                   VARCHAR2(30);
l_object_id                     NUMBER;
l_object_version_id             NUMBER;
l_progress_status_code          pa_percent_completes.progress_status_code%TYPE;
l_progress_comment              pa_percent_completes.progress_comment%TYPE;
l_actual_start_date             pa_percent_completes.actual_start_date%TYPE;
l_actual_finish_date            pa_percent_completes.actual_finish_date%TYPE;
l_estimated_start_date          pa_percent_completes.estimated_start_date%TYPE;
l_estimated_finish_date         pa_percent_completes.estimated_finish_date%TYPE;
l_scheduled_start_date          pa_tasks.scheduled_start_date%TYPE;
l_scheduled_finish_date         pa_tasks.scheduled_finish_date%TYPE;
l_est_remaining_effort          NUMBER;
l_ETC_cost                      NUMBER;
l_actual_work_quantity          NUMBER;


-- ROW LOCKING
--Bug 3606627 : Unnecessary Cursor : Commenting
/*CURSOR        l_percent_complete_csr (l_task_id_out NUMBER, l_as_of_date DATE)
IS
SELECT  trunc(date_computed)
FROM            pa_percent_completes pc
WHERE           pc.project_id = l_project_id_out
AND             pc.task_id = l_task_id_out
AND             pc.current_flag  = 'Y';*/



l_progress_mode                 VARCHAR2(10); --Bug 2736387
l_latest_as_of_date             DATE; -- Bug 2758319
l_task_status                   VARCHAR2(150); --Bug 2751159

    CURSOR c_get_structure_information(c_project_id NUMBER, c_structure_type VARCHAR2) IS
      select ppevs.proj_element_id, ppevs.element_version_id
        from pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where ppevs.project_id = c_project_id
         and ppevs.proj_element_id = ppst.proj_element_id
         and ppevs.status_code = 'STRUCTURE_PUBLISHED'
         and ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = c_structure_type;

    CURSOR c_get_element_information(c_project_id NUMBER, c_proj_element_id NUMBER, c_object_type VARCHAR2, c_structure_type VARCHAR2) IS
      select elev.element_version_id, elev.parent_structure_version_id
        from pa_proj_element_versions elev,
             pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where elev.project_id = c_project_id
         and elev.object_type = c_object_type
         and elev.proj_element_id = c_proj_element_id
         and elev.parent_structure_version_id = ppevs.element_version_id
         and ppevs.project_id = c_project_id
         and ppevs.proj_element_id = ppst.proj_element_id
         and ppevs.status_code = 'STRUCTURE_PUBLISHED'
         and ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = c_structure_type;

    CURSOR c_get_del_associated_task(c_project_id NUMBER, c_del_proj_element_id NUMBER, c_object_type VARCHAR2) IS
         SELECT ppe.proj_element_id  --, por.object_id_to1 (commented by rtarway for BUG 3746647)
          FROM pa_proj_elements ppe,
               pa_object_relationships por
          WHERE
              ppe.object_type = 'PA_TASKS'
          and ppe.proj_element_id = por.object_id_from2
          and por.object_id_to2 = c_del_proj_element_id
          and por.object_type_to = c_object_type
          and por.relationship_type = 'A'
          and por.relationship_subtype = 'TASK_TO_DELIVERABLE'
          and ppe.base_percent_comp_deriv_code='DELIVERABLE';

    --Begin Add by rtarway for BUG 3746647
    CURSOR c_get_del_ver_id(c_project_id NUMBER, c_del_proj_element_id NUMBER) IS
    SELECT ppev.element_version_id
    FROM   pa_proj_element_versions ppev
    WHERE  ppev.proj_element_id = c_del_proj_element_id
    AND    ppev.project_id = c_project_id
    AND    ppev.object_type = 'PA_DELIVERABLES' ;
    --End Add by rtarway for BUG 3746647

    -- Bug 3799841 Begin
    CURSOR c_get_rlm_id(c_project_id NUMBER, c_object_id NUMBER, c_structure_version_id NUMBER, c_task_version_id NUMBER) IS
        SELECT resource_list_member_id
        FROM pa_task_assignments_v
        WHERE project_id = c_project_id
        AND resource_assignment_id = c_object_id
        AND structure_version_id = c_structure_version_id
        AND task_version_id = c_task_version_id;

    CURSOR c_verify_rlm_id(c_project_id NUMBER, c_object_id NUMBER, c_structure_version_id NUMBER, c_task_version_id NUMBER) IS
        SELECT 'Y', ta_display_flag
        FROM pa_task_assignments_v
        WHERE project_id = c_project_id
        AND resource_list_member_id = c_object_id
        AND structure_version_id = c_structure_version_id
        AND task_version_id = c_task_version_id;

l_rlm_id                        NUMBER;
l_valid_rlm_id                  VARCHAR2(1):= 'N';
l_ta_display_flag               VARCHAR2(1):= 'X';
-- Bug 3799841 End

l_task_id                       NUMBER;
l_structure_version_id          NUMBER;
l_task_version_id               NUMBER;
l_actual_cost_to_date           NUMBER;
l_actual_effort_to_date         NUMBER;
l_txn_currency_code             VARCHAR2(15);
l_system_task_status            pa_project_statuses.project_system_status_code%TYPE;
g1_debug_mode                   VARCHAR2(1);

l_populate_pji_tables           VARCHAR2(1);
l_rollup_entire_wbs             VARCHAR2(1);
l_str_id                        NUMBER;
l_str_version_id                NUMBER;

l_baselined_str_ver_id NUMBER; --maansari6/28  bug 3673618
--Added by rtarway for BUG 3872176
l_published_version_flag VARCHAR2(1);
l_version_enabled   VARCHAR2(1);
l_unique_record     VARCHAR2(1);

BEGIN

        g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PUB.UPDATE_PROGRESS');
        END IF;

        SAVEPOINT Update_Progress_Pub;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'PA_STATUS_PUB.UPDATE_PROGRESS Start : Passed Parameters :', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_api_version_number='||p_api_version_number, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_init_msg_list='||p_init_msg_list, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_commit='||p_commit, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_pm_project_reference='||p_pm_project_reference, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_task_id='||p_task_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_pm_task_reference='||p_pm_task_reference, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_as_of_date='||p_as_of_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_percent_complete='||p_percent_complete, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_pm_product_code='||p_pm_product_code, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_description='||p_description, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_object_id='||p_object_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_object_version_id='||p_object_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_object_type='||p_object_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_progress_status_code='||p_progress_status_code, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_progress_comment='||p_progress_comment, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_actual_start_date='||p_actual_start_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_actual_finish_date='||p_actual_finish_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_estimated_start_date='||p_estimated_start_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_estimated_finish_date='||p_estimated_finish_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_scheduled_start_date='||p_scheduled_start_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_scheduled_finish_date='||p_scheduled_finish_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_task_status='||p_task_status, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_structure_type='||p_structure_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_est_remaining_effort='||p_est_remaining_effort, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_actual_work_quantity='||p_actual_work_quantity, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_etc_cost='||p_etc_cost, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_pm_deliverable_reference='||p_pm_deliverable_reference, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_pm_task_assgn_reference='||p_pm_task_assgn_reference, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_actual_cost_to_date='||p_actual_cost_to_date, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'p_actual_effort_to_date='||p_actual_effort_to_date, x_Log_Level=> 3);
        END IF;


        p_return_status := FND_API.G_RET_STS_SUCCESS;
        -- We have p_populate_pji_tables as paramter because we can not populate PJI tables in Execute update_task_progress
        -- as we do not have structure version id there.
        -- If user passes intentionally as N and calls singule update_progress then we will set it as Y
        IF(G_bulk_load_flag = 'Y') THEN
                l_project_id_out := p_project_id;
                IF  FND_API.to_boolean(p_init_msg_list) THEN
                        FND_MSG_PUB.initialize;
                END IF;
                l_populate_pji_tables := p_populate_pji_tables;
                l_rollup_entire_wbs  := p_rollup_entire_wbs;
        ELSE
                l_populate_pji_tables := 'Y';
                l_rollup_entire_wbs  := 'N';

                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'G_bulk_load_flag is N, Calling Project_Level_Validations', x_Log_Level=> 3);
                END IF;

                PA_STATUS_PUB.Project_Level_Validations
                        ( p_api_version_number          => p_api_version_number
                        , p_commit                      => FND_API.G_FALSE --Bug 3754134
                        , p_init_msg_list               => p_init_msg_list
                        , p_msg_count                   => p_msg_count
                        , p_msg_data                    => p_msg_data
                        , p_return_status               => l_return_status
                        , p_project_id                  => p_project_id
                        , p_pm_project_reference        => p_pm_project_reference
                        , p_project_id_out              => l_project_id_out
                        );
                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'After Project_Level_Validations l_return_status='||l_return_status, x_Log_Level=> 3);
                END IF;

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- Bug 3627315 : Added code to validate date against the project structure
                -- it won't be validated for each object
                OPEN c_get_structure_information(l_project_id_out, p_structure_type);
                FETCH c_get_structure_information INTO l_str_id, l_str_version_id;
                CLOSE c_get_structure_information;

                /*IF PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE(TRUNC(p_as_of_date), l_project_id_out, l_str_id, 'PA_STRUCTURES', l_str_id ) = 'N'
                THEN
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_INV_AOD2');
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RAISE  FND_API.G_EXC_ERROR;
                END IF;*/
        END IF;

    -- User can pass task_id or task reference
    -- User can pass object_type and object_id or object_reference
    -- User can pass task _id as 0 and object_type and object_id as miss char

        IF (p_task_id = 0 AND p_object_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_object_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  THEN
                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'Case 1 : task_id is passed as 0 and object_type and object_id is not passed', x_Log_Level=> 3);
                END IF;
                -- Must be Project-Level Progress Data
                l_task_id_out := 0;
                l_object_type := 'PA_STRUCTURES';
                OPEN c_get_structure_information(l_project_id_out, p_structure_type);
                FETCH c_get_structure_information INTO l_object_id, l_object_version_id;
                CLOSE c_get_structure_information;
                l_task_id := null;
                l_structure_version_id := l_object_version_id;
        ELSIF (((p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_id <> 0) OR (p_pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_pm_task_reference IS NOT NULL))
                AND p_object_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_object_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  THEN

                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'Case 2 : task_id is passed or task_ref is passed and object_type and object_id is not passed', x_Log_Level=> 3);
                END IF;

                PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                         (         p_pa_project_id      =>      l_project_id_out
                                ,  p_structure_type     =>      p_structure_type
                                ,  p_pa_task_id         =>      p_task_id
                                ,  p_pm_task_reference  =>      p_pm_task_reference
                                ,  p_out_task_id        =>      l_task_id_out
                                ,  p_return_status      =>      l_return_status
                         );
                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE  FND_API.G_EXC_ERROR;
                END IF;
                l_object_type := 'PA_TASKS';
                l_object_id := l_task_id_out;
                OPEN c_get_element_information(p_project_id, l_object_id, l_object_type, p_structure_type);
                FETCH c_get_element_information INTO l_object_version_id, l_structure_version_id;
                CLOSE c_get_element_information;
                l_task_id := l_task_id_out;
        ELSIF (p_object_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_object_type IS NOT NULL) THEN
                IF g1_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'Case 3 : object_type is passed', x_Log_Level=> 3);
                END IF;

                IF p_object_type <> 'PA_ASSIGNMENTS' AND p_object_type <> 'PA_DELIVERABLES' AND p_object_type <> 'PA_TASKS' AND p_object_type <> 'PA_STRUCTURES' THEN
                        FND_MESSAGE.SET_NAME('PA','PA_PROG_WRONG_OBJ_TYPE');
                        FND_MSG_PUB.add;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                ELSE
                        l_object_type := p_object_type;
                END IF;

                IF ((l_object_type = 'PA_ASSIGNMENTS' OR l_object_type = 'PA_DELIVERABLES') AND p_structure_type = 'FINANCIAL') THEN
                        FND_MESSAGE.SET_NAME('PA','PA_PROG_ASGN_DEL_NOT_ALLOW_STR');
                        FND_MSG_PUB.add;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF p_object_type = 'PA_TASKS' THEN
                        IF ((p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_id IS NOT NULL)
                                OR (p_pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_pm_task_reference IS NOT NULL))  THEN

                                PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                                        (  p_pa_project_id      =>      l_project_id_out
                                        ,  p_structure_type     =>      p_structure_type
                                        ,  p_pa_task_id         =>      p_task_id
                                        ,  p_pm_task_reference  =>      p_pm_task_reference
                                        ,  p_out_task_id        =>      l_task_id_out
                                        ,  p_return_status      =>      l_return_status
                                        );
                                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                        RAISE  FND_API.G_EXC_ERROR;
                                END IF;
                        END IF;
                        IF ((p_object_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_object_id IS NOT NULL)
                                OR (p_pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_pm_task_reference IS NOT NULL)) THEN

                                PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                                        (  p_pa_project_id      =>      l_project_id_out
                                        ,  p_structure_type     =>      p_structure_type
                                        ,  p_pa_task_id         =>      p_object_id
                                        ,  p_pm_task_reference  =>      p_pm_task_reference
                                        ,  p_out_task_id        =>      l_task_id_out
                                        ,  p_return_status      =>      l_return_status
                                        );
                                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                        RAISE  FND_API.G_EXC_ERROR;
                                END IF;
                        END IF;

                        l_object_type := p_object_type;
                        l_object_id := l_task_id_out;
                        l_task_id := l_task_id_out;
                        OPEN c_get_element_information(p_project_id, l_object_id, l_object_type, p_structure_type);
                        FETCH c_get_element_information INTO l_object_version_id, l_structure_version_id;
                        CLOSE c_get_element_information;
                ELSIF p_object_type = 'PA_DELIVERABLES' THEN
                        PA_DELIVERABLE_UTILS.Convert_pm_dlvrref_to_id
                                (p_deliverable_reference => p_PM_DELIVERABLE_REFERENCE
                                ,p_deliverable_id      => p_object_id
                                ,p_project_id          => l_project_id_out
                                ,p_out_deliverable_id  => l_object_id
                                ,p_return_status       => l_return_status);
                        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                RAISE  FND_API.G_EXC_ERROR;
                        END IF;
                        --Begin add for BUG 3746647, rtarway
                        OPEN  c_get_del_ver_id(p_project_id, l_object_id);
                        FETCH c_get_del_ver_id into l_object_version_id;
                        CLOSE c_get_del_ver_id;
                        --End Add for BUG 3746647, rtarway
                        l_object_type := p_object_type;
                        OPEN c_get_del_associated_task(p_project_id, l_object_id, l_object_type);
                        --BUG 3746647, rtarway, get only task id.
                        --FETCH c_get_del_associated_task INTO l_task_id, l_object_version_id;
                        FETCH c_get_del_associated_task INTO l_task_id;
                        CLOSE c_get_del_associated_task;
                        -- 20 May : Structure version_id shd also be got from here
                        IF l_task_id is not NULL THEN
                                OPEN c_get_element_information(p_project_id, l_task_id, 'PA_TASKS', 'WORKPLAN');
                                FETCH c_get_element_information INTO l_task_version_id, l_structure_version_id;
                                CLOSE c_get_element_information;
                        END IF;
                ELSIF p_object_type = 'PA_ASSIGNMENTS' THEN

                --Added by rtarway for BUG 3872176
                IF ((p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_id IS NOT NULL)
                                OR (p_pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_pm_task_reference IS NOT NULL)) THEN

                                PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                                        (  p_pa_project_id      =>      l_project_id_out
                                        ,  p_structure_type     =>      p_structure_type
                                        ,  p_pa_task_id         =>      p_task_id
                                        ,  p_pm_task_reference  =>      p_pm_task_reference
                                        ,  p_out_task_id        =>      l_task_id_out
                                        ,  p_return_status      =>      l_return_status
                                        );
                                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                        RAISE  FND_API.G_EXC_ERROR;
                                END IF;
                        END IF;
                --end Added by rtarway for BUG 3872176

                        OPEN c_get_element_information(p_project_id, l_task_id_out, 'PA_TASKS', p_structure_type);
                        FETCH c_get_element_information INTO l_task_version_id, l_structure_version_id;
                        CLOSE c_get_element_information;

                        -- Bug 3799841, If Object_id(RLM ID is passed, then no need to call Convert_PM_TARef_To_ID
                        -- Addionally when Convert_PM_TARef_To_ID return resource_assignment_id, we need to convert this
                        -- to RLM id.

               -- Added by rtarway for BUG 3872176
               --1. Check if project is version enabled.
                l_version_enabled := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED( p_project_id );
                if   (l_version_enabled = 'N')
                then
                      l_published_version_flag := 'N';
                else
                      -- the derived structure version id will always be from published structure version
                      -- please see cursor c_get_element_information
                      l_published_version_flag := 'Y';
                end if;
                --end add by rtarway BUG 3872176


                        IF p_object_id IS NOT NULL AND p_object_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                                l_valid_rlm_id := 'N';
                                l_ta_display_flag := 'X';
                                OPEN c_verify_rlm_id(l_project_id_out, p_object_id, l_structure_version_id, l_task_version_id);
                                FETCH c_verify_rlm_id INTO l_valid_rlm_id, l_ta_display_flag;
                                CLOSE c_verify_rlm_id;

                                IF l_valid_rlm_id = 'N' THEN
                                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                p_msg_name       => 'PA_TP_INV_ASSGN_AMG',
                                                P_TOKEN1         => 'OBJECT_ID',
                                                P_VALUE1         => p_object_id);
                                        p_return_status := FND_API.G_RET_STS_ERROR;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                                -- Here if hidden assignment, then we are just returning
                                -- We could have even thrown an erroe message of Invalid Assignment
                                -- But we are not doing this right now as MSP is sending all assignments
                                -- including hidden ones
                                IF l_ta_display_flag = 'N' THEN
                                        return;
                                END IF;
                                l_object_id := p_object_id;
                        ELSE
                                PA_TASK_ASSIGNMENTS_PUB.Convert_PM_TARef_To_ID
                                        ( p_pm_product_code        => p_pm_product_code
                                        ,p_pa_project_id           => l_project_id_out
                                        ,p_pa_structure_version_id => l_structure_version_id
                                        --,p_pa_task_id              => p_task_id
                         --BUG  3872176, rtarway
                         ,p_pa_task_id              => l_task_id_out
                                        ,p_pa_task_elem_ver_id     => l_task_version_id
                                        ,p_pa_task_assignment_id   => p_object_id
                                        ,p_pm_task_asgmt_reference => p_PM_TASK_ASSGN_REFERENCE
                                        ,x_pa_task_assignment_id   => l_object_id
                         --Added by rtarway for BUG 3872176
                         ,p_published_version_flag  => l_published_version_flag
                                        ,x_return_status           => l_return_status );
                                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                        RAISE  FND_API.G_EXC_ERROR;
                                END IF;
                                -- Bug 3799841 Returned l_object_id would be resource_assignment_id, we nned to change this to RLM id
                                OPEN c_get_rlm_id(l_project_id_out, l_object_id, l_structure_version_id, l_task_version_id);
                                FETCH c_get_rlm_id INTO l_rlm_id;
                                CLOSE c_get_rlm_id;
                                l_object_id := l_rlm_id;
                        END IF;
                        l_object_type := p_object_type;
			l_task_id := l_task_id_out; --rtarway, BUG 3872716
                        l_object_version_id := l_task_version_id;
                ELSIF p_object_type = 'PA_STRUCTURES' THEN
                        l_object_type := 'PA_STRUCTURES';
                        OPEN c_get_structure_information(l_project_id_out, p_structure_type);
                        FETCH c_get_structure_information INTO l_object_id, l_object_version_id;
                        CLOSE c_get_structure_information;
                        l_task_id := null;
                        l_structure_version_id := l_object_version_id;
                END IF; --  p_object_type = 'PA_TASKS'
        END IF; --(p_task_id = 0 AND p_object_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_object_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'l_object_type='||l_object_type, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'l_object_id='||l_object_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'l_object_version_id='||l_object_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'l_structure_version_id='||l_structure_version_id, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'l_task_id='||l_task_id, x_Log_Level=> 3);
        END IF;

        IF (l_object_type is null or l_object_id is null
         --BUG3632883
         --or ( l_object_version_id is null AND l_object_type <> 'PA_DELIVERABLES')--BUG 3746647
         or ( l_object_version_id is null)
         or ( l_structure_version_id is null AND l_object_type <> 'PA_DELIVERABLES' )
         ) THEN
                FND_MESSAGE.SET_NAME('PA','PA_TP_INV_PROJ_STRUC_INFO');
                FND_MSG_PUB.add;
                p_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
	-- Bug 4218507 Added g_task_version_id_tbl
	IF l_object_type = 'PA_DELIVERABLES' AND l_task_version_id IS NOT NULL THEN
		l_unique_record := 'Y';
		FOR i in 1..g_task_version_id_tbl.count LOOP
			IF g_task_version_id_tbl(i) = l_task_version_id THEN
				l_unique_record := 'N';
				exit;
			END IF;
		END LOOP;
		IF l_unique_record = 'Y' THEN
			g_task_version_id_tbl.extend(1);
			g_task_version_id_tbl(g_task_version_id_tbl.count):= l_task_version_id;
		END IF;
	ELSIF  l_object_version_id IS NOT NULL THEN
		l_unique_record := 'Y';
		FOR i in 1..g_task_version_id_tbl.count LOOP
			IF g_task_version_id_tbl(i) = l_object_version_id THEN
				l_unique_record := 'N';
				exit;
			END IF;
		END LOOP;
		IF l_unique_record = 'Y' THEN
			g_task_version_id_tbl.extend(1);
			g_task_version_id_tbl(g_task_version_id_tbl.count):= l_object_version_id;
		END IF;
	END IF;

        IF l_populate_pji_tables = 'Y' AND l_structure_version_id IS NOT NULL THEN
        l_baselined_str_ver_id := PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(l_project_id_out);  --maansari6/28 bug 3673618
        --maansari7/6 bug 3742356
        if l_baselined_str_ver_id = -1
        then
           l_baselined_str_ver_id := l_structure_version_id;
        end if;

                PA_PROGRESS_PUB.populate_pji_tab_for_plan(
                    p_api_version               =>      p_api_version_number
                    ,p_init_msg_list            =>      p_init_msg_list
                    ,p_commit                   =>      FND_API.G_FALSE --Bug 3754134
                    ,p_calling_module           =>      'AMG'
                    ,p_project_id               =>      l_project_id_out
                    ,p_structure_version_id     =>      l_structure_version_id
                    ,p_baselined_str_ver_id     =>      l_baselined_str_ver_id   --maansari6/28 bug 3673618
                    ,x_return_status            =>      l_return_status
                    ,x_msg_count                =>      l_msg_count
                    ,x_msg_data                 =>      l_msg_data
                    );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;

        IF (p_pm_product_code   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
                l_pm_product_code := NULL;
        ELSE
                l_pm_product_code := p_pm_product_code;
        END IF;

        IF (p_description       = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
                l_description := NULL;
        ELSE
                l_description := p_description;
        END IF;

        l_as_of_date    :=      TRUNC(p_as_of_date);

        IF (p_progress_status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                l_progress_status_code := null;
        ELSE
                l_progress_status_code := p_progress_status_code;
        END IF;

        IF (p_progress_comment = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                l_progress_comment := null;
        ELSE
                l_progress_comment := p_progress_comment;
        END IF;

        IF (p_actual_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_actual_start_date := null;
        ELSE
                l_actual_start_date := p_actual_start_date;
        END IF;

        IF (p_actual_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_actual_finish_date := null;
        ELSE
                l_actual_finish_date := p_actual_finish_date;
        END IF;

        IF (p_estimated_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_estimated_start_date := null;
        ELSE
                l_estimated_start_date := p_estimated_start_date;
        END IF;

        IF (p_estimated_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_estimated_finish_date := null;
        ELSE
                l_estimated_finish_date := p_estimated_finish_date;
        END IF;

        IF (p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_scheduled_start_date := null;
        ELSE
                l_scheduled_start_date := p_scheduled_start_date;
        END IF;

        IF (p_scheduled_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
                l_scheduled_finish_date := null;
        ELSE
                l_scheduled_finish_date := p_scheduled_finish_date;
        END IF;

        IF (p_est_remaining_effort = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_est_remaining_effort := null;
        ELSE
                l_est_remaining_effort := p_est_remaining_effort;
        END IF;

        IF (p_etc_cost = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_etc_cost := null;
        ELSE
                l_etc_cost := p_etc_cost;
        END IF;

        IF (p_ACTUAL_COST_TO_DATE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_ACTUAL_COST_TO_DATE := null;
        ELSE
                l_ACTUAL_COST_TO_DATE := p_ACTUAL_COST_TO_DATE;
        END IF;

        IF (p_ACTUAL_EFFORT_TO_DATE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_ACTUAL_EFFORT_TO_DATE := null;
        ELSE
                l_ACTUAL_EFFORT_TO_DATE := p_ACTUAL_EFFORT_TO_DATE;
        END IF;


        -- Bug 2736387 added check for 0 also in beflow if condition
        IF (p_actual_work_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_actual_work_quantity = 0) THEN
                l_actual_work_quantity := null;
        ELSE
                l_actual_work_quantity := p_actual_work_quantity;
        END IF;

    l_latest_as_of_date := PA_PROGRESS_UTILS.GET_LATEST_AS_OF_DATE(p_task_id => null
                                , p_project_id => l_project_id_out
                                , p_object_id => l_object_id
                                , p_object_type => l_object_type
                                , p_structure_type => p_STRUCTURE_TYPE
                                );

        IF  l_latest_as_of_date is NOT NULL THEN
              IF l_as_of_date >= l_latest_as_of_date THEN
                l_progress_mode := 'FUTURE';
              ELSE
                IF (l_object_type = 'PA_ASSIGNMENTS' OR l_object_type = 'PA_DELIVERABLES')
                THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_PROG_BACKDATE_NOT_ALLOW',
                                                'OBJECT_ID', l_object_id);
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                l_progress_mode := 'BACKDATED';
              END IF;
        ELSE
             l_progress_mode := 'FUTURE';
        END IF;

        /* Bug 2758319 -- Added the null handling after getting the l_latest_as_of_date */

        /* Bug2736387 -- Added the following IF condition to pass the appropriate p_progress_mode
                       to PA_PROGRESS_PUB.UPDATE_PROGRESS call */

     -- Bug 3606627 : Using new signature of  GET_LATEST_AS_OF_DATE
     --BUG 4133128, rtarway
     -- bug 4868792  added progress mode check, latest_as_of_date check
     ---- the reason we have to check valid as_of_date for each record is because  this can only be done after finding out it is future or backdated record
     ----if (G_bulk_load_flag <> 'Y'  and l_progress_mode = 'FUTURE') then
    if p_structure_type <> 'FINANCIAL' then  -- added for bug 5398704
     if (l_progress_mode = 'FUTURE') then
          if (l_object_type = 'PA_DELIVERABLES' OR l_object_type = 'PA_TASKS' OR l_object_type = 'PA_STRUCTURES')then
               IF PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE(TRUNC(l_as_of_date), l_project_id_out, l_object_id, l_object_type ) = 'N'
               AND  trunc(nvl(l_latest_as_of_date,l_as_of_date + 1 )) <>  TRUNC(l_as_of_date)
               THEN
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_TP_INV_AOD2'
                                         ,p_token1 => 'AS_OF_DATE'
                                         ,p_value1 => l_as_of_date);
                    p_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE  FND_API.G_EXC_ERROR;
               END IF;
          END IF;
          if (l_object_type = 'PA_ASSIGNMENTS')then
               IF PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE(TRUNC(l_as_of_date), l_project_id_out, l_object_id, l_object_type, l_task_id ) = 'N'
               AND  trunc(nvl(l_latest_as_of_date,l_as_of_date + 1 )) <>  TRUNC(l_as_of_date)
               THEN
                    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_TP_INV_AOD2'
                                         ,p_token1 => 'AS_OF_DATE'
                                         ,p_value1 => l_as_of_date);
                    p_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE  FND_API.G_EXC_ERROR;
               END IF;
          END IF;
     end if;
    end if;
     -- Bug 3606627 : Now p_task_status column is being used for deliverable status too
     -- So we can not default values here. Defaulting is happening in update_task_progress and
     -- update_deliverable_progress
     /* Bug2751159 -- Added following IF condition to get the appropriate task_status */
      IF p_task_status = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_task_status IS NULL  --bug 2791395
      THEN
/*          IF p_percent_complete = 100 THEN
              l_task_status  := '127';           ---COMPLETED  -- 127   bug 2826235
          ELSIF p_percent_complete > 0 THEN
              l_task_status  := '125';           --IN_PROGRESS -- 125   bug 2826235
          ELSIF p_percent_complete is null or p_percent_complete = 0 THEN
              l_task_status  := '124';           --NOT_STARTED -- 124   bug 2826235
          END IF;   */
        l_task_status := null;
      ELSE
         l_task_status := p_task_status;
      END IF;
     -- Bug 3606627 : Cancelled Status check is modified
    /*  --Bug 2792857
      IF PA_PROGRESS_UTILS.get_task_status( l_project_id_out, l_object_id ) = '128' AND    --CANCELLED --128 bug 2826235
         PA_PROGRESS_UTILS.get_system_task_status( l_task_status ) = 'CANCELLED' AND
         l_progress_mode = 'FUTURE'
      THEN
          RETURN;
      END IF;
      --Bug 2792857*/

      l_system_task_status := PA_PROGRESS_UTILS.get_system_task_status(l_task_status, l_object_type) ;

      IF ((l_system_task_status = 'CANCELLED' OR l_system_task_status = 'DLVR_CANCELLED')
         AND  l_progress_mode = 'FUTURE') THEN
         return;
      END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'Calling PA_PROGRESS_PUB.UPDATE_PROGRESS', x_Log_Level=> 3);
        END IF;

   if (l_progress_mode = 'FUTURE') then
      PA_PROGRESS_PUB.UPDATE_PROGRESS(
        p_api_version            => p_api_version_number,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => FND_API.G_FALSE, --Bug 3754134 instead passing p_commit pass false
        p_action                 => 'PUBLISH',
        P_rollup_entire_wbs_flag => l_rollup_entire_wbs,
        p_progress_mode          => l_progress_mode,
        p_calling_module         => 'AMG',
        p_project_id             => l_project_id_out,
        p_object_id              => l_object_id,
        p_object_version_id      => l_object_version_id,
        p_object_type            => l_object_type,
        p_as_of_date             => trunc(l_as_of_date), -- 5294838
        p_percent_complete       => p_percent_complete,
        p_progress_status_code   => l_progress_status_code,
        p_progress_comment       => l_progress_comment,
        p_brief_overview         => l_description,
        p_actual_start_date      => l_actual_start_date,
        p_actual_finish_date     => l_actual_finish_date,
        p_estimated_start_date   => l_estimated_start_date,
        p_estimated_finish_date  => l_estimated_finish_date,
        p_scheduled_start_date   => l_scheduled_start_date,
        p_scheduled_finish_date  => l_scheduled_finish_date,
        p_pm_product_code        => l_pm_product_code,
        p_record_version_number  => 1,
        p_task_status            => l_task_status,
        p_est_remaining_effort   => l_est_remaining_effort,
        p_actual_work_quantity   => l_actual_work_quantity,
        p_ETC_cost               => l_etc_cost,
        p_structure_type         => p_structure_type,
        p_actual_effort          => l_ACTUAL_EFFORT_TO_DATE, -- Bug 3799841 : there was swap b/w cost and effort
        p_actual_cost            => l_ACTUAL_COST_TO_DATE,
        p_task_id                => l_task_id,
        p_structure_version_id   => l_structure_version_id,
        p_prog_fom_wp_flag       => 'N',
        p_txn_currency_code      => p_txn_currency_code, -- Fix for Bug #  3988457.
        x_return_status          => p_return_status,
        x_msg_count              => p_msg_count,
        x_msg_data               => p_msg_data );
     elsif (l_progress_mode = 'BACKDATED') then
        PA_PROGRESS_PUB.UPDATE_PROGRESS(
        p_api_version            => p_api_version_number,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => FND_API.G_FALSE,
        p_action                 => 'PUBLISH',
        P_rollup_entire_wbs_flag => l_rollup_entire_wbs,
        p_progress_mode          => l_progress_mode,
        p_calling_module         => 'AMG',
        p_project_id             => l_project_id_out,
        p_object_id              => l_object_id,
        p_object_version_id      => l_object_version_id,
        p_object_type            => l_object_type,
        p_as_of_date             => trunc(l_as_of_date), -- 5294838
        p_percent_complete       => p_percent_complete,
        p_progress_status_code   => l_progress_status_code,
        p_progress_comment       => l_progress_comment,
        p_brief_overview         => l_description,
        p_scheduled_start_date   => l_scheduled_start_date,
        p_scheduled_finish_date  => l_scheduled_finish_date,
        p_pm_product_code        => l_pm_product_code,
        p_record_version_number  => 1,
        p_task_status            => l_task_status,
        p_structure_type         => p_structure_type,
        p_task_id                => l_task_id,
        p_structure_version_id   => l_structure_version_id,
        p_prog_fom_wp_flag       => 'N',
        p_txn_currency_code      => p_txn_currency_code,
        x_return_status          => p_return_status,
        x_msg_count              => p_msg_count,
        x_msg_data               => p_msg_data );

      end if;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_STATUS_PUB.UPDATE_PROGRESS', x_Msg => 'After call of PA_PROGRESS_PUB.UPDATE_PROGRESS p_return_status='||p_return_status, x_Log_Level=> 3);
        END IF;


        IF (p_return_status = FND_API.G_RET_STS_SUCCESS )
        then
           IF FND_API.to_boolean(p_commit)
           THEN
                COMMIT;
           END IF;
        ELSE
           ROLLBACK TO Update_Progress_Pub;
           FND_MSG_PUB.Count_And_Get
                        ( p_count  => p_msg_count
                         ,p_data   => p_msg_data
                        );
        END IF;

        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN

                        p_return_status := FND_API.G_RET_STS_ERROR;
                        ROLLBACK TO Update_Progress_Pub;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                , p_data                        =>      p_msg_data
                        );

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Update_Progress_Pub;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                , p_data                        =>      p_msg_data
                        );


                WHEN ROW_ALREADY_LOCKED THEN

                     p_return_status := FND_API.G_RET_STS_ERROR ;
                     IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
                        FND_MESSAGE.SET_TOKEN('ENTITY', 'PERCENT_COMPLETE');
                        FND_MSG_PUB.Add;
                     END IF;
                     ROLLBACK TO Update_Progress_Pub;
                     FND_MSG_PUB.Count_And_Get
                        (p_count                        =>      p_msg_count
                        , p_data                        =>      p_msg_data
                        );

                WHEN OTHERS THEN

                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Update_Progress_Pub;

                        IF FND_MSG_PUB.Check_Msg_level                                                                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                , p_data                        =>      p_msg_data
                        );


END Update_Progress;
-- =========================================================================

--
-- Name:                Update_Earned_Value
-- Type:                PL/SQL Procedure
-- Decscription:        This procedure updates the PA_EARNED_VALUES table.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--                      , Convert_Pm_Taskref_To_Id
--                      , Convert_List_Name_To_Id
--                      , Convert_Alias_To_Id
--
-- History:     08-AUG-1996     Created jwhite
--              29-AUG-1996     Update  jwhite  Applied latest messaging standards.
--              29-OCT-1996     Update  jwhite  Replaced resource list member
--                                              conversion code with API call
--                                              to PA_RESOURCE_PUB.
--              13-DEC-1996     Update  jwhite  Applied lastest standards.
--

PROCEDURE Update_Earned_Value
(p_api_version_number           IN      NUMBER
, p_init_msg_list                       IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status                       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id                  IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference                IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id                     IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_resource_list_member_id     IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_resource_alias              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_resource_list_name          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_as_of_date                  IN      DATE
, p_bcws_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_acwp_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bcwp_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bac_current                 IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bcws_itd                    IN      NUMBER
, p_acwp_itd                    IN      NUMBER
, p_bcwp_itd                    IN      NUMBER
, p_bac_itd                     IN      NUMBER
, p_bqws_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_aqwp_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bqwp_current                        IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_baq_current                 IN      NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_bqws_itd                    IN      NUMBER
, p_aqwp_itd                    IN      NUMBER
, p_bqwp_itd                    IN      NUMBER
, p_baq_itd                     IN      NUMBER
)

IS

l_api_version_number            CONSTANT        NUMBER  := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT        VARCHAR2(30)    := 'Update_Earned_Value';
l_value_conversion_error                BOOLEAN                 := FALSE;
l_return_status                 VARCHAR2(1);
l_msg_count                     INTEGER;

l_err_code                      NUMBER                  :=  -1;
l_err_stage                     VARCHAR2(2000)          := NULL;
l_err_stack                     VARCHAR2(2000)          := NULL;

l_project_id_out                        NUMBER  := 0;
l_task_id_out                   NUMBER  := 0;
l_resource_list_member_id_out   NUMBER  := 0;
l_resource_list_id_out          NUMBER  := 0;

l_bcws_current                  NUMBER  := 0;
l_acwp_current                  NUMBER  := 0;
l_bcwp_current                  NUMBER  := 0;
l_bac_current                   NUMBER  := 0;

l_bqws_current                  NUMBER  := 0;
l_aqwp_current                  NUMBER  := 0;
l_bqwp_current                  NUMBER  := 0;
l_baq_current                   NUMBER  := 0;
l_msg_data                      VARCHAR2(2000);
l_function_allowed              VARCHAR2(1);
l_resp_id                       NUMBER := 0;
l_current_flag                  VARCHAR2(1);
l_dummy                         VARCHAR2(1);
l_module_name                   VARCHAR2(80);
l_user_id                       NUMBER                                   := 0;
l_date_computed                 DATE;


-- ROW LOCKING

CURSOR  l_earned_values_csr (l_project_id_out NUMBER
                           , l_task_id_out NUMBER
                           , l_resource_list_member_id_out NUMBER)
IS
SELECT  trunc(as_of_date)
FROM            pa_earned_values ev
WHERE ev.project_id = l_project_id_out
AND ev.task_id = l_task_id_out
AND ev.resource_list_member_id = l_resource_list_member_id_out
AND ev.current_flag = 'Y'
FOR UPDATE NOWAIT;



BEGIN

        SAVEPOINT Update_Earned_Value_Pub;

        p_return_status := FND_API.G_RET_STS_SUCCESS;

        IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number  ,
                                         l_api_name,
                                         G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Uncommented the following code as the fix of Bug 5632178
/* Moved from below for Advanced Project Security Changes. Bug 2471668*/

        PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_project_id
                 ,  p_out_project_id    =>      l_project_id_out
                 ,  p_return_status     =>      l_return_status
        );


        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
--End of changes for bug 5632178

    l_user_id := FND_GLOBAL.User_id;
    l_resp_id := FND_GLOBAL.Resp_id;
    --l_module_name := p_pm_product_code||'.'||'PA_PM_UPDATE_EARNED_VALUE';

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    --Bug 2471668
    PA_INTERFACE_UTILS_PUB.g_project_id := l_project_id_out;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_EARNED_VALUE',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
           FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;


-- VALUE LAYER -----------------------------------------------------------------------

/* Moved up for Advanced project security changes . Bug 2471668
        PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_project_id
                 ,  p_out_project_id    =>      l_project_id_out
                 ,  p_return_status     =>      l_return_status
        );


        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
*/

      IF pa_security.allow_query (x_project_id => l_project_id_out ) = 'N' THEN

         -- The user does not have query privileges on this project
         -- Hence, cannot update the project.Raise error

           FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF pa_security.allow_update (x_project_id => l_project_id_out ) = 'N'
            THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

           FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

        IF (p_task_id = 0) THEN
-- Must Be Project-Level Earned Value Data

                l_task_id_out := 0;

        ELSE
	-- 5262740 Converted PA_PROJECT_PVT.Convert_pm_taskref_to_id to PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                 (       p_pa_project_id                =>      l_project_id_out
                          ,  p_pa_task_id               =>      p_task_id
                          ,  p_pm_task_reference        =>      p_pm_task_reference
                          ,  p_out_task_id              =>      l_task_id_out
                           ,  p_return_status   =>      l_return_status
                );


                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE  FND_API.G_EXC_ERROR;
                END IF;
        END IF;

-- ---------------------------------------------------------------
--  Convert Resource List Member Values to Id
-- ---------------------------------------------------------------

        IF (p_resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

             IF (p_resource_list_member_id = 0) THEN
-- Must be Task-Level Earned Value Data

                l_resource_list_member_id_out := 0;

            ELSE

                PA_RESOURCE_PUB.Convert_alias_to_id
                (        p_resource_list_id             => l_resource_list_id_out
                        , p_resource_list_member_id     => p_resource_list_member_id
                        , p_out_resource_list_member_id => l_resource_list_member_id_out
                        , p_return_status                       => l_return_status
                );


                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        ELSE
                PA_RESOURCE_PUB.Convert_List_name_to_id
                (       p_resource_list_name    =>  p_resource_list_name,
                        p_out_resource_list_id  =>  l_resource_list_id_out,
                        p_return_status         =>  l_return_status
                );

                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                RAISE FND_API.G_EXC_ERROR;
                END IF;

                PA_RESOURCE_PUB.Convert_alias_to_id
                (        p_resource_list_id             => l_resource_list_id_out
                        , p_alias                               => p_resource_alias
                        , p_out_resource_list_member_id => l_resource_list_member_id_out
                        , p_return_status                       => l_return_status
                );

                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                                RAISE FND_API.G_EXC_ERROR;
                END IF;

        END IF;

-- ------------------------------------------------------------------------------
-- Set Defaults
-- ------------------------------------------------------------------------------

        IF (p_bcws_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_bcws_current := 0;
        ELSE
                l_bcws_current := p_bcws_current;
        END IF;
        IF (p_acwp_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_acwp_current := 0;
        ELSE
                l_acwp_current :=  p_acwp_current ;
        END IF;
        IF (p_bcwp_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_bcwp_current := 0;
        ELSE
                l_bcwp_current := p_bcwp_current;
        END IF;
        IF (p_bac_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_bac_current := 0;
        ELSE
                l_bac_current :=  p_bac_current;
        END IF;

        IF (p_bqws_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_bqws_current := 0;
        ELSE
                l_bqws_current := p_bqws_current;
        END IF;
        IF (p_aqwp_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_aqwp_current := 0;
        ELSE
                l_aqwp_current := p_aqwp_current;
        END IF;
        IF (p_bqwp_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_bqwp_current := 0;
        ELSE
                l_bqwp_current := p_bqwp_current;
        END IF;
        IF (p_baq_current = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_baq_current := 0;
        ELSE
                l_baq_current := p_baq_current;
        END IF;

-- ------------------------------------------------------------------------------
-- UPDATE Current Flag in PA_EARNED_VALUES
-- ------------------------------------------------------------------------------

-- Locking
        l_date_computed := NULL;

        OPEN l_earned_values_csr (l_project_id_out, l_task_id_out
                                , l_resource_list_member_id_out );
        FETCH l_earned_values_csr INTO l_date_computed;
        IF l_earned_values_csr%NOTFOUND THEN
           l_current_flag := 'Y';  -- means there was no existing record
                                   -- with current flag = 'Y'.This could be
                                   -- the first time the record is coming in
        END IF;
        IF l_date_computed IS NOT NULL THEN
           IF TRUNC(p_as_of_date) >= l_date_computed THEN -- If the
                                        -- incoming date is >= to the
                                        -- one existing then set the old
                                        -- current to 'N' and insert new
                                        -- record with current_flag = 'Y'
                l_current_flag := 'Y';  -- means the current flag is to be
           ELSE
                l_current_flag := 'N';
           END IF;
        END IF;
        CLOSE l_earned_values_csr;

        IF l_current_flag = 'Y' AND l_date_computed IS NOT NULL THEN
           UPDATE pa_earned_values ev
           SET ev.current_flag = 'N'
           WHERE ev.project_id = l_project_id_out
           AND   ev.task_id = l_task_id_out
           AND   ev.resource_list_member_id = l_resource_list_member_id_out
           AND   ev.current_flag = 'Y';
        END IF;


-- ------------------------------------------------------------------------------
-- INSERT VALUES INTO PA_EARNED_VALUES
-- ------------------------------------------------------------------------------

        INSERT INTO pa_earned_values (
                PROJECT_ID
                , TASK_ID
                , RESOURCE_LIST_MEMBER_ID
                , AS_OF_DATE
                , CURRENT_FLAG
                , BCWS
                , ACWP
                , BCWP
                , BAC
                , BCWS_ITD
                , ACWP_ITD
                , BCWP_ITD
                , BAC_ITD
                , BQWS
                , AQWP
                , BQWP
                , BAQ
                , BQWS_ITD
                , AQWP_ITD
                , BQWP_ITD
                , BAQ_ITD
                , LAST_UPDATE_DATE
                , LAST_UPDATED_BY
                , CREATION_DATE
                , CREATED_BY
                , LAST_UPDATE_LOGIN)
        VALUES (
        l_project_id_out
        , l_task_id_out
        , l_resource_list_member_id_out
        , p_as_of_date
        , l_current_flag
        , pa_currency.round_currency_amt(l_bcws_current)
        , pa_currency.round_currency_amt(l_acwp_current)
        , pa_currency.round_currency_amt(l_bcwp_current)
        , pa_currency.round_currency_amt(l_bac_current)
        , pa_currency.round_currency_amt(p_bcws_itd)
        , pa_currency.round_currency_amt(p_acwp_itd)
        , pa_currency.round_currency_amt(p_bcwp_itd)
        , pa_currency.round_currency_amt(p_bac_itd)
        , l_bqws_current
        , l_aqwp_current
        , l_bqwp_current
        , l_baq_current
        , p_bqws_itd
        , p_aqwp_itd
        , p_bqwp_itd
        , p_baq_itd
        , g_last_update_date
        , g_last_updated_by
        , g_creation_date
        , g_created_by
        , g_last_update_login);


        IF (SQL%ROWCOUNT = 0)
         THEN
                IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.SET_NAME('PA','PA_EV_INSERT_ERROR');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF FND_API.to_boolean(p_commit)
        THEN
                COMMIT;
        END IF;


        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        ROLLBACK TO Update_Earned_Value_Pub;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Update_Earned_Value_Pub;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );

                WHEN ROW_ALREADY_LOCKED THEN

                         p_return_status := FND_API.G_RET_STS_ERROR ;

                        IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                           FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
                           FND_MESSAGE.SET_TOKEN('ENTITY', 'EARNED_VALUE');
                           FND_MSG_PUB.Add;
                        END IF;

                        ROLLBACK TO Update_Progress_Pub;


                WHEN OTHERS THEN

                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Update_Earned_Value_Pub;

                        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;

                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );


END Update_Earned_Value;

PROCEDURE Init_Update_Task_Progress
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_api_name                      CONSTANT        VARCHAR2(30)    := 'Init_Update_Task_Progress';

BEGIN
        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    G_TASK_PROGRESS_in_tbl.delete;
    G_TASK_PROGRESS_tbl_count   := 0;

        IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           FND_MSG_PUB.Count_And_Get
                        ( p_count  => p_msg_count
                         ,p_data   => p_msg_data
                        );
        END IF;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN OTHERS THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );

END Init_Update_Task_Progress;

PROCEDURE Load_Task_Progress
(p_api_version_number           IN      NUMBER
,p_init_msg_list                IN      VARCHAR2                := FND_API.G_FALSE
,p_commit                       IN      VARCHAR2                := FND_API.G_FALSE
,p_project_id                   IN      NUMBER                  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_pm_project_reference         IN      VARCHAR2                := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_pm_product_code              IN      VARCHAR2                := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_structure_type               IN      VARCHAR2                := 'FINANCIAL'
,p_as_of_date                   IN      DATE
,p_task_id                      IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_task_name                    IN      PA_VC_1000_240          := PA_VC_1000_240(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_task_number                  IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_pm_task_reference            IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_percent_complete             IN      PA_NUM_1000_NUM
,p_description                  IN      PA_VC_1000_2000         := PA_VC_1000_2000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_object_id                    IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_object_version_id            IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_object_type                  IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_progress_status_code         IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_progress_comment             IN      PA_VC_1000_4000         := PA_VC_1000_4000(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_actual_start_date            IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_actual_finish_date           IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_estimated_start_date         IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_estimated_finish_date        IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_scheduled_start_date         IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_scheduled_finish_date        IN      PA_DATE_1000_DATE       := PA_DATE_1000_DATE(PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
,p_task_status                  IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
,p_est_remaining_effort         IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_actual_work_quantity         IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
,p_etc_cost                     IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) /* FP M Task Progress 3420093*/
,p_pm_deliverable_reference     IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- Bug 3606627
,p_pm_task_assgn_reference      IN      PA_VC_1000_150          := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- Bug 3606627
,p_actual_cost_to_date          IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) -- Bug 3606627
,p_actual_effort_to_date        IN      PA_NUM_1000_NUM         := PA_NUM_1000_NUM(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) -- Bug 3606627
,p_return_status                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_msg_count                    OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_api_version_number            CONSTANT        NUMBER  := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT        VARCHAR2(30)    := 'Load_Task_Progress';
l_progress_mode                                 VARCHAR2(10);
l_latest_as_of_date                             Date;
G1_DEBUG_MODE                                   VARCHAR2(1);

l_TASK_ID                       NUMBER;
l_TASK_NAME                     VARCHAR2(240);
l_TASK_NUMBER                   VARCHAR2(150);
l_PM_TASK_REFERENCE             VARCHAR2(150);
l_PERCENT_COMPLETE              NUMBER;
l_DESCRIPTION                   VARCHAR2(2000);
l_OBJECT_ID                     NUMBER;
l_OBJECT_VERSION_ID             NUMBER;
l_OBJECT_TYPE                   VARCHAR2(150);
l_PROGRESS_STATUS_CODE          VARCHAR2(150);
l_PROGRESS_COMMENT              VARCHAR2(4000);
l_ACTUAL_START_DATE             DATE;
l_ACTUAL_FINISH_DATE            DATE;
l_ESTIMATED_START_DATE          DATE;
l_ESTIMATED_FINISH_DATE         DATE;
l_SCHEDULED_START_DATE          DATE;
l_SCHEDULED_FINISH_DATE         DATE;
l_TASK_STATUS                   VARCHAR2(150);
l_EST_REMAINING_EFFORT          NUMBER;
l_ACTUAL_WORK_QUANTITY          NUMBER;
l_ETC_COST                      NUMBER;
l_PM_DELIVERABLE_REFERENCE      VARCHAR2(150);
l_PM_TASK_ASSGN_REFERENCE       VARCHAR2(150);
l_ACTUAL_COST_TO_DATE           NUMBER;
l_ACTUAL_EFFORT_TO_DATE         NUMBER;

BEGIN

        g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.init_err_stack ('PA_PROGRESS_PUB.LOAD_TASK_PROGRESS');
        END IF;

        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;

        IF(G_TASK_PROGRESS_tbl_count = 0) THEN
                G_PROJECT_ID            := P_PROJECT_ID;
                G_pm_project_reference  := P_pm_project_reference;
                G_PM_PRODUCT_CODE       := P_PM_PRODUCT_CODE;
                G_STRUCTURE_TYPE        := P_STRUCTURE_TYPE;
                G_AS_OF_DATE            := TRUNC(P_AS_OF_DATE);
        END IF;

        IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'P_TASK_ID.count='||P_TASK_ID.count, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'P_TASK_ID.count='||P_TASK_ID.count, x_Log_Level=> 3);
        END IF;

        FOR i in 1..1000 LOOP
            -- Bug 3606627 : Commented the code which return if task_id is null. Now task_id can be null for Deleiverable.
            -- if (((P_TASK_ID(i) is null) or (P_TASK_ID(i) =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)) and ((P_PM_TASK_REFERENCE(i) is null) or (P_PM_TASK_REFERENCE(i) =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))) then
            --    return;
            --else

                -- Bug 3673618 : Introduced local variables to store the value first.
                -- This is done to ensure that if any parameter is not passed it does not give error subscript out of bound

                IF P_TASK_ID.count = 1 AND P_TASK_ID(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_TASK_ID := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_TASK_ID := P_TASK_ID(i);
                END IF;



                IF P_TASK_NAME.count = 1 AND P_TASK_NAME(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_TASK_NAME := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_TASK_NAME := P_TASK_NAME(i);
                END IF;


                IF P_TASK_NUMBER.count = 1 AND P_TASK_NUMBER(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_TASK_NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_TASK_NUMBER := P_TASK_NUMBER(i);
                END IF;

            --end if;

                IF p_PM_TASK_REFERENCE.count = 1 AND p_PM_TASK_REFERENCE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_PM_TASK_REFERENCE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_PM_TASK_REFERENCE := p_PM_TASK_REFERENCE(i);
                END IF;


                IF p_PERCENT_COMPLETE.count = 1 AND p_PERCENT_COMPLETE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_PERCENT_COMPLETE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_PERCENT_COMPLETE := p_PERCENT_COMPLETE(i);
                END IF;

                IF p_DESCRIPTION.count = 1 AND p_DESCRIPTION(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_DESCRIPTION := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_DESCRIPTION := p_DESCRIPTION(i);
                END IF;

                IF p_OBJECT_ID.count = 1 AND p_OBJECT_ID(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_OBJECT_ID := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_OBJECT_ID := p_OBJECT_ID(i);
                END IF;

                IF p_OBJECT_VERSION_ID.count = 1 AND p_OBJECT_VERSION_ID(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_OBJECT_VERSION_ID := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_OBJECT_VERSION_ID := p_OBJECT_VERSION_ID(i);
                END IF;

                IF p_OBJECT_TYPE.count = 1 AND p_OBJECT_TYPE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_OBJECT_TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_OBJECT_TYPE := p_OBJECT_TYPE(i);
                END IF;

                IF p_PROGRESS_STATUS_CODE.count = 1 AND p_PROGRESS_STATUS_CODE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_PROGRESS_STATUS_CODE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_PROGRESS_STATUS_CODE := p_PROGRESS_STATUS_CODE(i);
                END IF;

                IF p_PROGRESS_COMMENT.count = 1 AND p_PROGRESS_COMMENT(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_PROGRESS_COMMENT := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_PROGRESS_COMMENT := p_PROGRESS_COMMENT(i);
                END IF;

                IF p_ACTUAL_START_DATE.count = 1 AND p_ACTUAL_START_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_ACTUAL_START_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_ACTUAL_START_DATE := p_ACTUAL_START_DATE(i);
                END IF;

                IF p_ACTUAL_FINISH_DATE.count = 1 AND p_ACTUAL_FINISH_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_ACTUAL_FINISH_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_ACTUAL_FINISH_DATE := p_ACTUAL_FINISH_DATE(i);
                END IF;

                IF p_ESTIMATED_START_DATE.count = 1 AND p_ESTIMATED_START_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_ESTIMATED_START_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_ESTIMATED_START_DATE := p_ESTIMATED_START_DATE(i);
                END IF;

                IF p_ESTIMATED_FINISH_DATE.count = 1 AND p_ESTIMATED_FINISH_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_ESTIMATED_FINISH_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_ESTIMATED_FINISH_DATE := p_ESTIMATED_FINISH_DATE(i);
                END IF;

                IF p_SCHEDULED_START_DATE.count = 1 AND p_SCHEDULED_START_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_SCHEDULED_START_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_SCHEDULED_START_DATE := p_SCHEDULED_START_DATE(i);
                END IF;

                IF p_SCHEDULED_FINISH_DATE.count = 1 AND p_SCHEDULED_FINISH_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_SCHEDULED_FINISH_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
                ELSE
                        l_SCHEDULED_FINISH_DATE := p_SCHEDULED_FINISH_DATE(i);
                END IF;

                IF p_TASK_STATUS.count = 1 AND p_TASK_STATUS(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_TASK_STATUS := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_TASK_STATUS := p_TASK_STATUS(i);
                END IF;

                IF p_EST_REMAINING_EFFORT.count = 1 AND p_EST_REMAINING_EFFORT(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_EST_REMAINING_EFFORT := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_EST_REMAINING_EFFORT := p_EST_REMAINING_EFFORT(i);
                END IF;

                IF p_ACTUAL_WORK_QUANTITY.count = 1 AND p_ACTUAL_WORK_QUANTITY(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_ACTUAL_WORK_QUANTITY := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_ACTUAL_WORK_QUANTITY := p_ACTUAL_WORK_QUANTITY(i);
                END IF;

                IF p_ETC_COST.count = 1 AND p_ETC_COST(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_ETC_COST := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_ETC_COST := p_ETC_COST(i);
                END IF;

                --Bug 3606627 : Assign new variables Start
                IF p_PM_DELIVERABLE_REFERENCE.count = 1 AND p_PM_DELIVERABLE_REFERENCE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_PM_DELIVERABLE_REFERENCE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_PM_DELIVERABLE_REFERENCE := p_PM_DELIVERABLE_REFERENCE(i);
                END IF;

                IF p_PM_TASK_ASSGN_REFERENCE.count = 1 AND p_PM_TASK_ASSGN_REFERENCE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_PM_TASK_ASSGN_REFERENCE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
                ELSE
                        l_PM_TASK_ASSGN_REFERENCE := p_PM_TASK_ASSGN_REFERENCE(i);
                END IF;

                IF p_ACTUAL_COST_TO_DATE.count = 1 AND p_ACTUAL_COST_TO_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_ACTUAL_COST_TO_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_ACTUAL_COST_TO_DATE := p_ACTUAL_COST_TO_DATE(i);
                END IF;

                IF p_ACTUAL_EFFORT_TO_DATE.count = 1 AND p_ACTUAL_EFFORT_TO_DATE(1) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_ACTUAL_EFFORT_TO_DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
                ELSE
                        l_ACTUAL_EFFORT_TO_DATE := p_ACTUAL_EFFORT_TO_DATE(i);
                END IF;

          IF g1_debug_mode  = 'Y' THEN
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'Values passed at count i='||i, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_TASK_ID :'||l_TASK_ID, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_TASK_NAME :'||l_TASK_NAME, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_TASK_NUMBER :'||l_TASK_NUMBER, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PM_TASK_REFERENCE :'||l_PM_TASK_REFERENCE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PERCENT_COMPLETE :'||l_PERCENT_COMPLETE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_DESCRIPTION :'||l_DESCRIPTION, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_OBJECT_ID :'||l_OBJECT_ID, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_OBJECT_VERSION_ID :'||l_OBJECT_VERSION_ID, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_OBJECT_TYPE :'||l_OBJECT_TYPE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PROGRESS_STATUS_CODE :'||l_PROGRESS_STATUS_CODE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PROGRESS_COMMENT :'||l_PROGRESS_COMMENT, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ACTUAL_START_DATE :'||l_ACTUAL_START_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ACTUAL_FINISH_DATE :'||l_ACTUAL_FINISH_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ESTIMATED_START_DATE :'||l_ESTIMATED_START_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ESTIMATED_FINISH_DATE :'||l_ESTIMATED_FINISH_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_SCHEDULED_START_DATE :'||l_SCHEDULED_START_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_SCHEDULED_FINISH_DATE :'||l_SCHEDULED_FINISH_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_TASK_STATUS :'||l_TASK_STATUS, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ACTUAL_WORK_QUANTITY :'||l_ACTUAL_WORK_QUANTITY, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ETC_COST :'||l_ETC_COST, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PM_DELIVERABLE_REFERENCE :'||l_PM_DELIVERABLE_REFERENCE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_PM_TASK_ASSGN_REFERENCE :'||l_PM_TASK_ASSGN_REFERENCE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ACTUAL_COST_TO_DATE :'||l_ACTUAL_COST_TO_DATE, x_Log_Level=> 3);
               pa_debug.write(x_Module=>'PA_STATUS_PUB.LOAD_TASK_PROGRESS', x_Msg => 'l_ACTUAL_EFFORT_TO_DATE :'||l_ACTUAL_EFFORT_TO_DATE, x_Log_Level=> 3);
          END IF;

                -- Bug 3673618 : Added this condition to do not process blank records.
                IF(((l_TASK_ID is null) or (l_TASK_ID =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
                     and ((l_PM_TASK_REFERENCE is null) or (l_PM_TASK_REFERENCE =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
                     and ((l_OBJECT_ID is null) or (l_OBJECT_ID =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
                     and ((l_PM_DELIVERABLE_REFERENCE is null) or (l_PM_DELIVERABLE_REFERENCE =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
                     and ((l_PM_TASK_ASSGN_REFERENCE is null) or (l_PM_TASK_ASSGN_REFERENCE =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
                     )
                THEN
                        return;
                END IF;
                -- Bug 3673618 : Moved assignment to global table later at the code.

                G_TASK_PROGRESS_tbl_count       := G_TASK_PROGRESS_tbl_count + 1;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_ID := l_TASK_ID;
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_ID := P_TASK_ID(i);

                --IF(P_TASK_NAME(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NAME := substr(P_TASK_NAME(i), 1, 20);
                --ELSE
                --        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NAME := P_TASK_NAME(i);
                --END IF;

                IF(l_TASK_NAME <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NAME := substrb(l_TASK_NAME, 1, 20); --5458363
                ELSE
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NAME := l_TASK_NAME;
                END IF;

                --IF(P_TASK_NUMBER(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NUMBER := substr(P_TASK_NUMBER(i), 1, 25);
                --ELSE
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NUMBER := P_TASK_NUMBER(i);
                --END IF;

                IF(l_TASK_NUMBER <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NUMBER := substrb(l_TASK_NUMBER, 1, 25); --5458363
                ELSE
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_NUMBER := l_TASK_NUMBER;
                END IF;

                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_TASK_REFERENCE := l_PM_TASK_REFERENCE;
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_TASK_REFERENCE := p_PM_TASK_REFERENCE(i);

                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PERCENT_COMPLETE := l_PERCENT_COMPLETE;
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PERCENT_COMPLETE := p_PERCENT_COMPLETE(i);

                --IF(p_DESCRIPTION(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).DESCRIPTION := substr(p_DESCRIPTION(i), 1, 250);
                --ELSE
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).DESCRIPTION := p_DESCRIPTION(i);
                --END IF;

                IF(l_DESCRIPTION <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).DESCRIPTION := substrb(l_DESCRIPTION, 1, 250);   --5458363
                ELSE
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).DESCRIPTION := l_DESCRIPTION;
                END IF;

                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_ID := l_OBJECT_ID;
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_ID := p_OBJECT_ID(i);

                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_VERSION_ID := p_OBJECT_VERSION_ID(i);
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_VERSION_ID := l_OBJECT_VERSION_ID;

                --IF(p_OBJECT_TYPE(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE := substr(p_OBJECT_TYPE(i), 1, 30);
                --ELSE
                --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE := p_OBJECT_TYPE(i);
                --END IF;

                IF(l_OBJECT_TYPE <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE := substrb(l_OBJECT_TYPE, 1, 30);    --5458363
                ELSE
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE := l_OBJECT_TYPE;
                END IF;

                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PROGRESS_STATUS_CODE := p_PROGRESS_STATUS_CODE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PROGRESS_COMMENT := p_PROGRESS_COMMENT(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_START_DATE := p_ACTUAL_START_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_FINISH_DATE := p_ACTUAL_FINISH_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ESTIMATED_START_DATE := p_ESTIMATED_START_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ESTIMATED_FINISH_DATE       := p_ESTIMATED_FINISH_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).SCHEDULED_START_DATE := p_SCHEDULED_START_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).SCHEDULED_FINISH_DATE := p_SCHEDULED_FINISH_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_STATUS := p_TASK_STATUS(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).EST_REMAINING_EFFORT := p_EST_REMAINING_EFFORT(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_WORK_QUANTITY := p_ACTUAL_WORK_QUANTITY(i);

                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PROGRESS_STATUS_CODE := l_PROGRESS_STATUS_CODE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PROGRESS_COMMENT := l_PROGRESS_COMMENT;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_START_DATE := l_ACTUAL_START_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_FINISH_DATE := l_ACTUAL_FINISH_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ESTIMATED_START_DATE := l_ESTIMATED_START_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ESTIMATED_FINISH_DATE := l_ESTIMATED_FINISH_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).SCHEDULED_START_DATE := l_SCHEDULED_START_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).SCHEDULED_FINISH_DATE := l_SCHEDULED_FINISH_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).TASK_STATUS := l_TASK_STATUS;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).EST_REMAINING_EFFORT := l_EST_REMAINING_EFFORT;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_WORK_QUANTITY := l_ACTUAL_WORK_QUANTITY;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ETC_COST := l_ETC_COST;

                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_DELIVERABLE_REFERENCE := p_PM_DELIVERABLE_REFERENCE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_TASK_ASSGN_REFERENCE := p_PM_TASK_ASSGN_REFERENCE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_COST_TO_DATE := p_ACTUAL_COST_TO_DATE(i);
                --G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_EFFORT_TO_DATE       := p_ACTUAL_EFFORT_TO_DATE(i);

                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_DELIVERABLE_REFERENCE := l_PM_DELIVERABLE_REFERENCE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PM_TASK_ASSGN_REFERENCE := l_PM_TASK_ASSGN_REFERENCE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_COST_TO_DATE := l_ACTUAL_COST_TO_DATE;
                G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).ACTUAL_EFFORT_TO_DATE := l_ACTUAL_EFFORT_TO_DATE;

                IF G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE = 'PA_TASKS'
                THEN
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).LOWEST_LEVEL_TASK := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => l_OBJECT_VERSION_ID);
                ELSE
                        G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).LOWEST_LEVEL_TASK := 'N';
                END IF;

                --Bug 3606627 : Assign new variables End

                --Bug 3606627
                -- This code to determine l_latest_as_of_date should be there in pa_status_pub.update_progress
                -- as here we may not be having object_id. We may need to derive it from ref fields.
        /*        l_latest_as_of_date := PA_PROGRESS_UTILS.GET_LATEST_AS_OF_DATE(p_task_id => null
                                        , p_project_id => G_PROJECT_ID
                                        , p_object_id => G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_ID
                                        , p_object_type => G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE
                                        , p_structure_type => G_STRUCTURE_TYPE
                                        );

                IF  l_latest_as_of_date is NOT NULL THEN
                      IF P_AS_OF_DATE >= l_latest_as_of_date THEN
                        l_progress_mode := 'FUTURE';
                      ELSE
        --              IF (G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE = 'PA_ASSIGNMENTS' OR
        --                      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).OBJECT_TYPE = 'PA_DELIVERABLES')
        --              THEN
        --                      PA_UTILS.ADD_MESSAGE('PA', 'PA_PROG_WRONG_OBJ_TYPE',
        --                                                      'OBJECT_ID', G_TASK_PROGRESS_in_tbl(i).OBJECT_ID);
        --
        --              END IF;
                        l_progress_mode := 'BACKDATED';
                      END IF;
                ELSE
                     l_progress_mode := 'FUTURE';
                END IF;*/

        --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).LATEST_AS_OF_DATE     := l_latest_as_of_date;
        --      G_TASK_PROGRESS_in_tbl(G_TASK_PROGRESS_tbl_count).PROGRESS_MODE         := l_progress_mode;

  END LOOP;

        IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           FND_MSG_PUB.Count_And_Get
                        ( p_count  => p_msg_count
                         ,p_data   => p_msg_data
                        );
        END IF;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN OTHERS THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
END Load_Task_Progress;

PROCEDURE Execute_Update_Task_Progress
( p_api_version_number          IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_api_version_number            CONSTANT        NUMBER  := G_API_VERSION_NUMBER;
l_api_name                      CONSTANT        VARCHAR2(30)    := 'EXECUTE_UPDATE_TASK_PROGRESS';
l_return_status                 VARCHAR2(1):= 'S';
l_msg_count                     INTEGER;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 INTEGER;
i                               INTEGER;
l_application_short_name        VARCHAR2(50) :='PA';

l_TASK_ID               NUMBER;
l_PM_TASK_REFERENCE     VARCHAR2(150);
l_PERCENT_COMPLETE      NUMBER;
l_DESCRIPTION           VARCHAR2(250);
l_OBJECT_ID             NUMBER;
l_OBJECT_VERSION_ID     NUMBER;
l_OBJECT_TYPE           VARCHAR2(30);
l_PROGRESS_STATUS_CODE  VARCHAR2(150);
l_PROGRESS_COMMENT      VARCHAR2(4000);
l_ACTUAL_START_DATE     Date;
l_ACTUAL_FINISH_DATE    Date;
l_ESTIMATED_START_DATE  Date;
l_ESTIMATED_FINISH_DATE Date;
l_SCHEDULED_START_DATE  Date;
l_SCHEDULED_FINISH_DATE Date;
l_TASK_STATUS           VARCHAR2(150);
l_EST_REMAINING_EFFORT  NUMBER;
l_ACTUAL_WORK_QUANTITY  NUMBER;

l_project_id_out        NUMBER;
l_structure_id          NUMBER;
l_structure_version_id  NUMBER;
l_project_validation_flag       VARCHAR2(1);
l_rollup_flag           VARCHAR2(1);
l_bulk_load_flag        VARCHAR2(1);
l_progress_mode         varchar2(10);
l_latest_as_of_date     Date;
l_lowest_level_task     VARCHAR2(1);
-- Bug 3606627 : Added following 6 parameters
l_etc_cost              NUMBER;
l_PM_DELIVERABLE_REFERENCE      VARCHAR2(150);
l_PM_TASK_ASSGN_REFERENCE       VARCHAR2(150);
l_ACTUAL_COST_TO_DATE   NUMBER;
l_ACTUAL_EFFORT_TO_DATE NUMBER;
l_populate_pji_tables   VARCHAR2(1) :='Y';
l_rollup_table          PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
l_max_as_of_date Date ;                     -- Bug 6917961

l_rollup varchar2(1);  --bug 6717386

-- Bug 3606627 : Added curosrs c_get_structure_information, c_get_task_weight_method
    CURSOR c_get_structure_information(c_project_id NUMBER, c_structure_type VARCHAR2) IS
      select ppevs.proj_element_id, ppevs.element_version_id
        from pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where ppevs.project_id = c_project_id
         and ppevs.proj_element_id = ppst.proj_element_id
         and ppevs.status_code = 'STRUCTURE_PUBLISHED'
         and ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = c_structure_type;

   CURSOR c_get_task_weight_method(c_project_id NUMBER, c_structure_type VARCHAR2)
   IS
   SELECT task_weight_basis_code
   FROM pa_proj_progress_attr
   WHERE project_id = c_project_id
   AND structure_type = c_structure_type;

   l_rollup_method         pa_proj_progress_attr.task_weight_basis_code%TYPE; -- Bug 3606627
   l_wp_rollup_method      pa_proj_progress_attr.task_weight_basis_code%TYPE; -- Bug 3606627
   l_fin_rollup_method     pa_proj_progress_attr.task_weight_basis_code%TYPE; -- Bug 3606627

   --maansari6/28 bug 3673618
   l_progress_updated_flag  VARCHAR2(1) := 'N';
   l_raise_exception        VARCHAR2(1) := 'N';
   l_baselined_str_ver_id   NUMBER;

   -- rtarway, BUG 3964278
   l_is_progress_status_null varchar2(1) := 'Y';
   G1_DEBUG_MODE                                   VARCHAR2(1);

   -- Bug 4186007 Begin
   l_msg_code             VARCHAR2(32);
   l_base_struct_ver_id   NUMBER;
   -- Bug 4186007 End

   -- Bug 3994165 : Added variables below
   l_structure_sharing_code    pa_projects_all.structure_sharing_code%TYPE;
   l_sharing_enabled          varchar2(1)                                               ;
   l_split_workplan           varchar2(1)                                               ;
   l_project_ids              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type()        ;
   l_struture_version_ids     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type()        ;
   l_proj_thru_dates_tbl      SYSTEM.pa_date_tbl_type:= SYSTEM.pa_date_tbl_type()       ;

-- Bug 8472681
TYPE progress_err_rec_type IS RECORD (
  row_number  VARCHAR2(25),
  task_name   VARCHAR2(20),
  task_number VARCHAR2(25),
  data        VARCHAR2(2000)
);

TYPE progress_err_tbl_type IS TABLE OF progress_err_rec_type INDEX BY BINARY_INTEGER;

l_progress_err_tbl      progress_err_tbl_type;
l_progress_err_index    NUMBER := 0;

BEGIN

        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;
        g1_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
     savepoint Execute_Update_Task_Progress;


        p_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Bug 3606627 : Added call of PA_STATUS_PUB.Project_Level_Validations
        PA_STATUS_PUB.Project_Level_Validations
                (p_api_version_number           => p_api_version_number
                ,p_msg_count                    => p_msg_count
                ,p_msg_data                     => p_msg_data
                ,p_return_status                => l_return_status
                , p_project_id                  => G_PROJECT_ID
                , p_pm_project_reference        => G_pm_project_reference
                , p_project_id_out              => l_project_id_out
                );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           p_return_status := l_return_status;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        G_PROJECT_ID := l_project_id_out;


        IF(G_TASK_PROGRESS_tbl_count = 0) THEN
                FND_MESSAGE.SET_NAME('PA','PA_NO_TASK_PROGRESS_UPDATE');
                FND_MSG_PUB.add;
                p_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        -- Bug 3606627 : Changed the following if condition to >=1 from =1
        ELSIF(G_TASK_PROGRESS_tbl_count >= 1) THEN
                --G_bulk_load_flag := 'N'; Bug 3606627
                G_bulk_load_flag := 'Y'; -- Bug 3606627
                --l_project_id_out := G_PROJECT_ID;     Bug 3606627
                -- Bug 3606627
                OPEN c_get_structure_information(l_project_id_out, g_structure_type);
                FETCH c_get_structure_information INTO l_structure_id, l_structure_version_id;
                CLOSE c_get_structure_information;

                -- Bug 3627315 : Added code to validate date against the project structure
                -- it won't be validated for each object

                -- it has to be validated for each task for backdate and correct progress flows
                /* IF PA_PROGRESS_UTILS.CHECK_VALID_AS_OF_DATE( TRUNC(g_as_of_date), l_project_id_out, l_structure_id, 'PA_STRUCTURES', l_structure_id --Bug 3764224 ) = 'N'
                THEN
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TP_INV_AOD2');
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RAISE  FND_API.G_EXC_ERROR;
                END IF;  */

        l_baselined_str_ver_id := PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(l_project_id_out); --maansari6/28 bug 3673618

        --maansari7/6   bug 3742356
        if l_baselined_str_ver_id = -1
        then
           l_baselined_str_ver_id := l_structure_version_id;
        end if;

                IF l_structure_version_id IS NOT NULL
           AND l_baselined_str_ver_id IS NOT NULL THEN --maansari6/28 bug 3673618
                        PA_PROGRESS_PUB.populate_pji_tab_for_plan(
                            p_api_version               =>      p_api_version_number
                            ,p_init_msg_list            =>      p_init_msg_list
                            ,p_commit                   =>      FND_API.G_FALSE --Bug 3754134
                            ,p_calling_module           =>      'AMG'
                            ,p_project_id               =>      l_project_id_out
                            ,p_structure_version_id     =>      l_structure_version_id
                            ,p_baselined_str_ver_id     =>      l_baselined_str_ver_id  --maansari6/28 bug 3673618
                            ,x_return_status            =>      l_return_status
                            ,x_msg_count                =>      l_msg_count
                            ,x_msg_data                 =>      l_msg_data
                            );

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;
		g_task_version_id_tbl.delete; -- Bug 4218507
                i := G_TASK_PROGRESS_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        l_TASK_ID                       := G_TASK_PROGRESS_in_tbl(i).TASK_ID;
                        l_PM_TASK_REFERENCE             := G_TASK_PROGRESS_in_tbl(i).PM_TASK_REFERENCE;
                        l_PERCENT_COMPLETE              := G_TASK_PROGRESS_in_tbl(i).PERCENT_COMPLETE;
                        l_DESCRIPTION                   := G_TASK_PROGRESS_in_tbl(i).DESCRIPTION;
                        l_OBJECT_ID                     := G_TASK_PROGRESS_in_tbl(i).OBJECT_ID;
                        l_OBJECT_VERSION_ID             := G_TASK_PROGRESS_in_tbl(i).OBJECT_VERSION_ID;
                        l_OBJECT_TYPE                   := G_TASK_PROGRESS_in_tbl(i).OBJECT_TYPE;
                        l_PROGRESS_STATUS_CODE          := G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE;
                        l_PROGRESS_COMMENT              := G_TASK_PROGRESS_in_tbl(i).PROGRESS_COMMENT;
                        l_ACTUAL_START_DATE             := G_TASK_PROGRESS_in_tbl(i).ACTUAL_START_DATE;
                        l_ACTUAL_FINISH_DATE            := G_TASK_PROGRESS_in_tbl(i).ACTUAL_FINISH_DATE;
                        l_ESTIMATED_START_DATE          := G_TASK_PROGRESS_in_tbl(i).ESTIMATED_START_DATE;
                        l_ESTIMATED_FINISH_DATE         := G_TASK_PROGRESS_in_tbl(i).ESTIMATED_FINISH_DATE;
                        l_SCHEDULED_START_DATE          := G_TASK_PROGRESS_in_tbl(i).SCHEDULED_START_DATE;
                        l_SCHEDULED_FINISH_DATE         := G_TASK_PROGRESS_in_tbl(i).SCHEDULED_FINISH_DATE;
                        l_TASK_STATUS                   := G_TASK_PROGRESS_in_tbl(i).TASK_STATUS;
                        l_EST_REMAINING_EFFORT          := G_TASK_PROGRESS_in_tbl(i).EST_REMAINING_EFFORT;
                        l_ACTUAL_WORK_QUANTITY          := G_TASK_PROGRESS_in_tbl(i).ACTUAL_WORK_QUANTITY;
                        -- Bug 3606627 : Added following 6 new parms assignment
                        l_etc_cost                      := G_TASK_PROGRESS_in_tbl(i).etc_cost;
                        l_PM_DELIVERABLE_REFERENCE      := G_TASK_PROGRESS_in_tbl(i).PM_DELIVERABLE_REFERENCE;
                        l_PM_TASK_ASSGN_REFERENCE       := G_TASK_PROGRESS_in_tbl(i).PM_TASK_ASSGN_REFERENCE;
                        l_ACTUAL_COST_TO_DATE           := G_TASK_PROGRESS_in_tbl(i).ACTUAL_COST_TO_DATE;
                        l_ACTUAL_EFFORT_TO_DATE         := G_TASK_PROGRESS_in_tbl(i).ACTUAL_EFFORT_TO_DATE;



--                      IF i = G_TASK_PROGRESS_in_tbl.first THEN
--                              l_populate_pji_tables := 'Y';
--                      ELSE
--                              l_populate_pji_tables := 'N';
--                      END IF;

-- Start of changes for bug 6717386

IF G_TASK_PROGRESS_in_tbl(i).OBJECT_TYPE = 'PA_ASSIGNMENTS'
THEN
    begin
        select 'Y' into l_rollup from dual
	where exists (select 1 from pa_percent_completes
	               where task_id = l_TASK_ID
		       AND PROJECT_ID = l_project_id_out
		       and object_type = 'PA_TASKS'
		       and PROGRESS_STATUS_CODE is not null);
	G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE := 'PROGRESS_STAT_ON_TRACK';
	l_PROGRESS_STATUS_CODE := G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE; -- Bug 3754134
 	exception WHEN NO_DATA_FOUND THEN
 	null;

   end;

END IF;

-- End of changes for bug 6717386
/* Commented for bug  6717386
IF G_TASK_PROGRESS_in_tbl(i).OBJECT_TYPE = 'PA_ASSIGNMENTS'
THEN
   G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE := 'PROGRESS_STAT_ON_TRACK';
   l_PROGRESS_STATUS_CODE := G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE; -- Bug 3754134
END IF;  */

--Commented by rtarway for BUG 3901982
  --maansari6/28 bug 3673618
  /*IF G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE IS NOT NULL AND
     G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  THEN*/

  l_is_progress_status_null := 'Y'; -- Bug 6497559

--Added by rtarway for BUG 3901982
  IF  (
       ( G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE IS NOT NULL AND
         G_TASK_PROGRESS_in_tbl(i).PROGRESS_STATUS_CODE <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
         AND G_STRUCTURE_TYPE = 'WORKPLAN'
       ) OR
       ( l_PERCENT_COMPLETE IS NOT NULL AND
         l_PERCENT_COMPLETE <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND G_STRUCTURE_TYPE = 'FINANCIAL'
       )
      )
  THEN
            --rtarway, 3964278
            if G_STRUCTURE_TYPE = 'WORKPLAN' then
                 l_is_progress_status_null := 'N';
            end if;

            l_progress_updated_flag := 'Y';  --maansari6/28 bug 3673618


                        PA_STATUS_PUB.UPDATE_PROGRESS
                                (p_api_version_number           => p_api_version_number
                                ,p_msg_count                    => l_msg_count
                                ,p_msg_data                     => l_msg_data
                                ,p_commit                       => FND_API.G_FALSE -- Bug 3754134 Added this
                                ,p_return_status                => l_return_status
                                , p_project_id                  => l_project_id_out
                                , p_pm_project_reference        => g_pm_project_reference
                                , p_task_id                     => l_task_id
                                , p_pm_task_reference           => l_pm_task_reference
                                , p_as_of_date                  => g_as_of_date
                                , p_percent_complete            => l_percent_complete
                                , p_pm_product_code             => g_pm_product_code
                                , p_description                 => l_description
                                , p_object_id                   => l_object_id
                                , p_object_version_id           => l_object_version_id
                                , p_object_type                 => l_object_type
                                , p_progress_status_code        => l_progress_status_code
                                , p_progress_comment            => l_progress_comment
                                , p_actual_start_date           => l_actual_start_date
                                , p_actual_finish_date          => l_actual_finish_date
                                , p_estimated_start_date        => l_estimated_start_date
                                , p_estimated_finish_date       => l_estimated_finish_date
                                , p_scheduled_start_date        => l_scheduled_start_date
                                , p_scheduled_finish_date       => l_scheduled_finish_date
                                , p_task_status                 => l_task_status
                                , p_structure_type              => g_structure_type
                                , p_est_remaining_effort        => l_est_remaining_effort
                                , p_actual_work_quantity        => l_actual_work_quantity
                                , p_etc_cost                    => l_etc_cost -- bug 3606627
                                , p_pm_deliverable_reference    => l_pm_deliverable_reference -- bug 3606627
                                , p_pm_task_assgn_reference     => l_pm_task_assgn_reference -- bug 3606627
                                , p_actual_cost_to_date         => l_actual_cost_to_date -- bug 3606627
                                , p_actual_effort_to_date       => l_actual_effort_to_date -- bug 3606627
                                , p_populate_pji_tables         => 'N' -- bug 3606627
                                , p_rollup_entire_wbs           => 'Y' -- bug 3606627
                                );

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                p_return_status := l_return_status;

                                FND_MSG_PUB.get (
                                p_msg_index      => l_msg_count,
                                p_encoded        => FND_API.G_FALSE,
                                p_data           => l_data,
                                p_msg_index_out  => l_msg_index_out );

                                IF l_data IS NOT NULL THEN
                                        FND_MSG_PUB.DELETE_MSG(p_msg_index => l_msg_count);

                                        /* Commenting for bug 8472681
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NAME_NUM_ERR',
                                                'ROWNUM', 'ROW# '||i,--Added by rtarway for bug 4293075
						'TASK_NAME', G_TASK_PROGRESS_in_tbl(i).TASK_NAME,
                                                'TASK_NUMBER', G_TASK_PROGRESS_in_tbl(i).TASK_NUMBER,
                                                'MESSAGE', l_data);
					*/

					-- Bug 8472681
                                        l_progress_err_index := l_progress_err_index + 1;
                                        l_progress_err_tbl(l_progress_err_index).row_number  := 'ROW# '||i;
                                        l_progress_err_tbl(l_progress_err_index).task_name   := G_TASK_PROGRESS_in_tbl(i).TASK_NAME;
                                        l_progress_err_tbl(l_progress_err_index).task_number := G_TASK_PROGRESS_in_tbl(i).TASK_NUMBER;
                                        l_progress_err_tbl(l_progress_err_index).data        := l_data;

                                END IF;
                                l_raise_exception := l_return_status;  --maansari6/28 bug 3673618

                        END IF;
         END IF;


--added for bug 9839893

  i:= G_TASK_PROGRESS_in_tbl.next(i);				-- Bug 6497559
  END LOOP;


  FOR z IN 1..l_progress_err_tbl.COUNT LOOP
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NAME_NUM_ERR',
                           'ROWNUM', 'ROW# '||l_progress_err_tbl(z).row_number,
                           'TASK_NAME', l_progress_err_tbl(z).task_name,
                           'TASK_NUMBER', l_progress_err_tbl(z).task_number,
                           'MESSAGE', l_progress_err_tbl(z).data);
  END LOOP;
  --rbruno


-- rtarway, BUG 3964278
  IF G_STRUCTURE_TYPE = 'WORKPLAN' and l_is_progress_status_null = 'Y'
  THEN
    IF g_pm_product_code = 'MSPROJECT'
    THEN
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_TP_STATUS_NOT_DEFINED_MSP'
                           ,p_token1 => 'TASK_NAME'
                           ,p_value1 => G_TASK_PROGRESS_in_tbl(i).TASK_NAME
                           ,p_token2 => 'TASK_NUMBER'
                           ,p_value2 => G_TASK_PROGRESS_in_tbl(i).TASK_NUMBER);
      p_return_status := FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
    ELSE
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_TP_STATUS_NOT_DEFINED_AMG'
                           ,p_token1 => 'TASK_ID'
                           ,p_value1 => G_TASK_PROGRESS_in_tbl(i).TASK_ID
                          );
      p_return_status := FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
  END IF;

/* commenting for bug 9839893
  i := G_TASK_PROGRESS_in_tbl.next(i);				-- Bug 6497559
  END LOOP;

  -- Bug 8472681 - Add messages back to the message stack
  FOR z IN 1..l_progress_err_tbl.COUNT LOOP
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NAME_NUM_ERR',
                           'ROWNUM', 'ROW# '||l_progress_err_tbl(z).row_number,
                           'TASK_NAME', l_progress_err_tbl(z).task_name,
                           'TASK_NUMBER', l_progress_err_tbl(z).task_number,
                           'MESSAGE', l_progress_err_tbl(z).data);

  END LOOP;
*/

--maansari6/28 bug 3673618
  IF l_progress_updated_flag = 'N'
  THEN
      return;
  END IF;

                IF (l_raise_exception = 'E' )
                THEN
                        RAISE FND_API.G_EXC_ERROR;
        ELSIF l_raise_exception = 'U'
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
--maansari6/28           bug 3673618


                -- Bug  3606627 Begin
                OPEN c_get_task_weight_method(l_project_id_out, g_structure_type);
                FETCH c_get_task_weight_method INTO l_rollup_method;
                CLOSE c_get_task_weight_method;

                IF g_structure_type = 'WORKPLAN' THEN
                        l_wp_rollup_method := l_rollup_method;
                ELSE
                        l_fin_rollup_method := l_rollup_method;
                END IF;
                -- Bug 3994165 : Moved call of MAINTAIN_ACTUAL_AMT_WRP here

                l_structure_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_project_id_out);
                l_sharing_Enabled := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(l_project_id_out);
                IF (l_sharing_Enabled = 'N' OR (l_sharing_Enabled = 'Y' AND l_structure_sharing_code <> 'SHARE_FULL')) AND g_structure_type = 'WORKPLAN' THEN
                        l_split_workplan := 'Y';
                ELSE
                        l_split_workplan := 'N';
                END IF;

                IF l_split_workplan = 'Y' AND l_structure_version_id IS NOT NULL THEN
                      BEGIN
                             Pa_Task_Pub1.G_CALL_PJI_ROLLUP := 'N';
                             -- This flag is set so that plan_update from MAINTAIN_ACTUAL_AMT_WRP
                             -- is not called. Actually it gets called but PJI code does not do anything.

                             l_project_ids.extend(1);
                             l_project_ids(1) := l_project_id_out;
                             l_struture_version_ids.extend(1);
                             l_struture_version_ids(1) := l_structure_version_id;
                             l_proj_thru_dates_tbl.extend(1);
                             l_proj_thru_dates_tbl(1) := trunc(g_as_of_date); -- 5294838
                             PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP
                               (P_PROJECT_ID_TAB                   => l_project_ids,
                                P_WP_STR_VERSION_ID_TAB            => l_struture_version_ids,
                                P_ACTUALS_THRU_DATE                => l_proj_thru_dates_tbl,
                                P_CALLING_CONTEXT                  => 'WP_PROGRESS',
                                P_EXTRACTION_TYPE                  => 'INCREMENTAL',
                                X_RETURN_STATUS                    => l_return_status,
                                X_MSG_COUNT                        => l_msg_count,
                                X_MSG_DATA                         => l_msg_data
                             );


                            Pa_Task_Pub1.G_CALL_PJI_ROLLUP := null ;

                            delete from PA_PROG_ACT_BY_PERIOD_TEMP where project_id = l_project_id_out
                            AND structure_version_id = l_structure_version_id;
                       EXCEPTION
                         WHEN OTHERS THEN
                             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STATUS_PUB',
                                           p_procedure_name => 'execute_update_progress',
                             p_error_text     => SUBSTRB('PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP:'||SQLERRM,1,120));
                             RAISE FND_API.G_EXC_ERROR;
                       END;
                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                      p_msg_name       => l_msg_data);
                                 p_return_status := 'E';
                                 RAISE  FND_API.G_EXC_ERROR;
                       END IF;
                END IF;
                -- Bug 4186007 Begin
                BEGIN
                        PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE (x_msg_code => l_msg_code,
                                                  x_return_status => l_return_status);
                EXCEPTION
                WHEN OTHERS THEN
                        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STATUS_PUB',
                            p_procedure_name => 'EXECUTE_UPDATE_TASK_PROGRESS',
                            p_error_text     => SUBSTRB('Call of PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE Failed:'||SQLERRM,1,120));
                        RAISE FND_API.G_EXC_ERROR;
                END;

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        p_return_status := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


                l_base_struct_ver_id := pa_project_structure_utils.get_baseline_struct_ver(l_project_id_out);

                IF (l_base_struct_ver_id = -1) THEN
                        l_base_struct_ver_id := l_structure_version_id;
                END IF;

		-- 4392189 : Changed call of populate_workplan_data to populate_pji_tab_for_plan
		PA_PROGRESS_PUB.POPULATE_PJI_TAB_FOR_PLAN(
				p_calling_module	=> 'AMG'
				,p_project_id           => l_project_id_out
				,p_structure_version_id => l_structure_version_id
				,p_baselined_str_ver_id => l_base_struct_ver_id
				,p_program_rollup_flag	=> 'Y'
				,p_calling_context	=> 'SUMMARIZE'
				,p_as_of_date		=> trunc(g_as_of_date) -- 5294838
				,x_return_status        => l_return_status
				,x_msg_count            => l_msg_count
				,x_msg_data             => l_msg_data
				);
		/*
                BEGIN
                        PJI_FM_XBS_ACCUM_UTILS.populate_workplan_data(
                            p_project_id        => l_project_id_out,
                            p_struct_ver_id     => l_structure_version_id,
                            p_base_struct_ver_id => l_base_struct_ver_id,
                            x_return_status     => l_return_status,
                            x_msg_code          => l_msg_code
                            );
                EXCEPTION
                WHEN OTHERS THEN
                        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STATUS_PUB',
                            p_procedure_name => 'EXECUTE_UPDATE_TASK_PROGRESS',
                            p_error_text     => SUBSTRB('Call of PJI_FM_XBS_ACCUM_UTILS.populate_workplan_data: failed'||SQLERRM,1,120));
                        RAISE FND_API.G_EXC_ERROR;
                END;
		*/

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        p_return_status := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Bug 4186007 End


                PA_PROGRESS_PVT.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list             => p_init_msg_list
                ,p_commit                    => FND_API.G_FALSE -- Bug 3754134 instead of passing p_commit passing fasle
                ,p_calling_module            => 'AMG'    --bug 3673618
                ,p_project_id                => l_project_id_out
                ,p_structure_version_id      => l_structure_version_id
                ,p_as_of_date                => trunc(g_as_of_date)  -- 5294838
                ,p_wp_rollup_method          => l_wp_rollup_method
                ,p_fin_rollup_method         => l_fin_rollup_method
                ,p_rollup_entire_wbs         => 'Y'
                ,p_structure_type            => g_structure_type
		,p_task_version_id_tbl       => g_task_version_id_tbl -- Bug 4218507
                ,x_return_status             => l_return_status
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        p_return_status := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                PA_PROGRESS_PUB.ROLLUP_FUTURE_PROGRESS_PVT(
                      p_project_id               => l_project_id_out
                     --,P_OBJECT_TYPE              => l_object_type
                     --,P_OBJECT_ID                => l_task_id -- p_task_id 3603636
                     --,p_object_version_id        => l_task_version_id
                     ,p_as_of_date               => trunc(g_as_of_date)  -- 5294838
                     --,p_lowest_level_task        => NVL( l_lowest_level_task, 'N' )
                     ,p_calling_module           => 'AMG'
                     ,p_structure_type           => g_structure_type
                     ,p_structure_version_id     => l_structure_version_id
                     ,p_fin_rollup_method        => l_fin_rollup_method
                     ,p_wp_rollup_method         => l_wp_rollup_method
                     ,p_rollup_entire_wbs        => 'Y'
                     ,x_return_status            => l_return_status
                     ,x_msg_count                => l_msg_count
                     ,x_msg_data                 => l_msg_data
                   );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                        p_return_status := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- Bug  3606627 End
        END IF; --(G_TASK_PROGRESS_tbl_count >= 1) THEN Bug 3606627 : Added Ebd IF here itself
     -- BUG 4080922 Adding Program Rollup Code : rtarway
	IF  g_structure_type = 'WORKPLAN' AND l_structure_version_id IS NOT NULL
        THEN
		IF g1_debug_mode  = 'Y' THEN
			pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_PROGRESS', x_Msg => 'Calling program_rollup_pvt', x_Log_Level=> 3);
		END IF;

		pa_progress_pvt.program_rollup_pvt(
		 p_init_msg_list        => 'F'
		,p_commit               => 'F'
		,p_calling_module       => 'AMG'
		,p_validate_only        => 'F'
		,p_project_id           => l_project_id_out
		,p_as_of_date           => trunc(g_as_of_date)  -- 5294838
		,p_structure_type       => g_structure_type
		,p_structure_ver_id     => l_structure_version_id
		,x_return_status        => l_return_status
		,x_msg_count            => l_msg_count
		,x_msg_data             => l_msg_data);

		IF g1_debug_mode  = 'Y' THEN
			pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_PROGRESS', x_Msg => 'After Calling program_rollup_pvt l_return_status='||l_return_status, x_Log_Level=> 3);
		END IF;

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
			p_return_status := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

        END IF;
     -- End Add 4080922

-- Bug 3606627 : Commenthing the below complete code
/* Bug 3606627
        ELSE
        G_bulk_load_flag := 'N';
        PA_STATUS_PUB.Project_Level_Validations
                (p_api_version_number           => p_api_version_number
                ,p_msg_count                    => p_msg_count
                ,p_msg_data                     => p_msg_data
                ,p_return_status                => l_return_status
                , p_project_id                  => G_PROJECT_ID
                , p_pm_project_reference        => G_pm_project_reference
                , p_project_id_out              => l_project_id_out
                );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           p_return_status := l_return_status;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        G_PROJECT_ID := l_project_id_out;

        l_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.get_latest_wp_version(l_project_id_out);
*/
/*
        select STRUCTURE_TYPE into G_STRUCTURE_TYPE
                from PA_STRUCT_VERSIONS_LOV_AMG_V where STRUCTURE_VERSION_ID = l_structure_version_id;
*/
/*Bug 3606627
        IF(G_STRUCTURE_TYPE = 'FINANCIAL') then
                IF(PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(l_project_id_out) = 'Y') THEN
                        l_rollup_flag := 'Y';
                        G_STRUCTURE_TYPE := 'WORKPLAN';
                ELSE
                        l_rollup_flag := 'N';
                END IF;
          else
                l_rollup_flag := 'Y';
          end if;


        PA_PROGRESS_PUB.INSERT_TASK_PROGRESSES(
                p_api_version            => p_api_version_number,
                p_calling_module         => 'AMG',
                p_project_id             => l_project_id_out,
                p_pm_product_code        => G_PM_PRODUCT_CODE,
                p_structure_version_id   => l_structure_version_id,
                p_structure_type         => G_STRUCTURE_TYPE,
                p_as_of_date             => G_AS_OF_DATE,
                p_task_progress_list_table    => G_TASK_PROGRESS_in_tbl,
                p_return_status          => l_return_status,
                p_msg_count              => p_msg_count,
                p_msg_data               => p_msg_data
         );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                p_return_status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

          IF(l_rollup_flag = 'Y') then
              PA_PROGRESS_PUB.ROLLUP_TASK_PROGRESSES(
                p_api_version            => p_api_version_number,
                p_calling_module         => 'AMG',
                p_progress_mode          => l_progress_mode,
                p_project_id             => l_project_id_out,
                p_structure_version_id   => l_structure_version_id,
                p_as_of_date             => G_AS_OF_DATE,
                p_rollup_table           => l_rollup_table,
                p_return_status          => l_return_status,
                p_msg_count              => p_msg_count,
                p_msg_data               => p_msg_data
              );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                p_return_status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
*/


             /* Commented out for Progress Management Changes. Bug # 3420093.

              PA_PROGRESS_PUB.UPDATE_ROLLUP_PROGRESSES(
                p_api_version            => p_api_version_number,
                p_calling_module         => 'AMG',
                p_progress_mode          => l_progress_mode,
                p_project_id             => l_project_id_out,
                p_structure_version_id   => l_structure_version_id,
                p_structure_type         => G_STRUCTURE_TYPE,
                p_as_of_date             => G_AS_OF_DATE,
                p_rollup_table           => l_rollup_table,
                p_task_progress_list_table    => G_TASK_PROGRESS_in_tbl,
                p_return_status          => l_return_status,
                p_msg_count              => p_msg_count,
                p_msg_data               => p_msg_data
              );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                p_return_status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             Commented out for Progress Management Changes. Bug # 3420093. */

             /* Progress Management Changes. Bug # 3420093. */

  /*Bug 3606627
            pa_status_pub.update_task_progress_amg(
                p_api_version                   => p_api_version_number,
                p_calling_module                => 'AMG',
                p_progress_mode                 => l_progress_mode,
                p_project_id                    => l_project_id_out,
                p_structure_version_id          => l_structure_version_id,
                p_structure_type                => G_STRUCTURE_TYPE,
                p_as_of_date                    => G_AS_OF_DATE,
                p_task_progress_list_table      => G_TASK_PROGRESS_in_tbl,
                x_return_status                 => l_return_status,
                x_msg_count                     => p_msg_count,
                x_msg_data                      => p_msg_data
              );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                p_return_status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
*/

             /* Progress Management Changes. Bug # 3420093. */

/*Bug 3606627
             i := G_TASK_PROGRESS_in_tbl.first;

             WHILE i IS NOT NULL LOOP
                l_TASK_ID               := G_TASK_PROGRESS_in_tbl(i).TASK_ID;
                l_PM_TASK_REFERENCE      := G_TASK_PROGRESS_in_tbl(i).PM_TASK_REFERENCE;
                l_PERCENT_COMPLETE       := G_TASK_PROGRESS_in_tbl(i).PERCENT_COMPLETE;
                l_DESCRIPTION            := G_TASK_PROGRESS_in_tbl(i).DESCRIPTION;
                l_OBJECT_ID              := G_TASK_PROGRESS_in_tbl(i).OBJECT_ID;
                l_OBJECT_VERSION_ID      := G_TASK_PROGRESS_in_tbl(i).OBJECT_VERSION_ID;
                l_OBJECT_TYPE            := G_TASK_PROGRESS_in_tbl(i).OBJECT_TYPE;
                l_progress_mode          := G_TASK_PROGRESS_in_tbl(i).PROGRESS_MODE;
*/
/*
                l_latest_as_of_date := PA_PROGRESS_UTILS.GET_LATEST_AS_OF_DATE(l_object_id);
                IF  l_latest_as_of_date is NOT NULL THEN
                        IF G_AS_OF_DATE >= l_latest_as_of_date THEN
                                l_progress_mode := 'FUTURE';
                        ELSE
                                l_progress_mode := 'BACKDATED';
                        END IF;
                ELSE
                        l_progress_mode := 'FUTURE';
                END IF;
*/

/* Bug 3606627
                if l_progress_mode <> 'BACKDATED' then
                        IF l_object_type = 'PA_TASKS'
                        THEN
                                l_lowest_level_task := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => l_OBJECT_VERSION_ID);
                        ELSE
                                l_lowest_level_task := 'N';
                        END IF;

                        PA_PROGRESS_PUB.ROLLUP_FUTURE_PROGRESS_PVT(
                                p_project_id                => l_project_id_out
                                ,P_OBJECT_TYPE               => L_OBJECT_TYPE
                                ,P_OBJECT_ID                 => L_OBJECT_ID
                                ,p_object_version_id         => L_object_version_id
                                ,p_as_of_date                => G_AS_OF_DATE
                                ,p_lowest_level_task            => NVL( l_lowest_level_task, 'N' )
                                ,x_return_status               => l_return_status
                                ,x_msg_count                 => l_msg_count
                                ,x_msg_data                  => l_msg_data
                        );
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                                p_return_status := l_return_status;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF ( NVL( l_lowest_level_task, 'N' ) = 'Y' )
                        THEN
                                PA_TASK_PVT1.Update_Dates_To_All_Versions(
                                        p_project_id           => l_project_id_out
                                        ,p_element_version_id   => l_object_version_id
                                        ,x_return_status               => l_return_status
                                        ,x_msg_count                   => l_msg_count
                                        ,x_msg_data                    => l_msg_data );
                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                                THEN
                                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                p_msg_name       => l_msg_data
                                        );
                                        p_msg_data := l_msg_data;
                                        p_return_status := 'E';
                                        RAISE  FND_API.G_EXC_ERROR;
                                END IF;
                                begin
                                        Select ppev1.proj_element_id
                                        into l_structure_id
                                        from pa_proj_element_versions ppev1, pa_proj_element_versions ppev2
                                        where ppev2.element_version_id = l_object_version_id
                                        and ppev2.project_id = ppev1.project_id
                                        and ppev2.parent_structure_version_id = ppev1.element_version_id;
                                exception when others then
                                        l_structure_id := -999;
                                end;
                                IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'Y')
                                        AND
                                        (PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(l_project_id_out) = 'Y')) THEN
                                        --copy to transaction dates
                                        PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES(
                                                p_validate_only => FND_API.G_FALSE
                                                ,p_project_id => l_project_id_out
                                                ,x_return_status => l_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data => l_msg_data);
                                END IF;
                        END IF;
                end if; ------ p_progress_mode <> backdated
                i := G_TASK_PROGRESS_in_tbl.next(i);
          END LOOP;
          end if;       -------l_rollup_flag = 'Y'
  end if;
*/

/* bug 6917961 */

select nvl(max(as_of_date),sysdate) into l_max_as_of_date
from pa_progress_rollup where project_id= l_project_id_out;



update pa_progress_rollup
set COMPLETED_PERCENTAGE  =  null
where project_id = l_project_id_out
AND OBJECT_TYPE ='PA_TASKS'
AND CURRENT_FLAG='Y'
AND  as_of_date=l_max_as_of_date
and nvl(COMPLETED_PERCENTAGE,0) = nvl(eff_rollup_percent_comp, -1);

/* bug 6917961 */

        IF (p_return_status = FND_API.G_RET_STS_SUCCESS )
        then
           IF FND_API.to_boolean(p_commit)
           THEN
                COMMIT;
           END IF;
        ELSE
           ROLLBACK TO Execute_Update_Task_Progress;
           FND_MSG_PUB.Count_And_Get
                        ( p_count  => p_msg_count
                         ,p_data   => p_msg_data
                        );
        END IF;
        G_bulk_load_flag :='N';
        G_TASK_PROGRESS_in_tbl.delete;
        G_TASK_PROGRESS_tbl_count       := 0;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        ROLLBACK TO Execute_Update_Task_Progress;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                        G_bulk_load_flag :='N';
                        G_TASK_PROGRESS_in_tbl.delete;
                        G_TASK_PROGRESS_tbl_count       := 0;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Execute_Update_Task_Progress;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                        G_bulk_load_flag :='N';
                        G_TASK_PROGRESS_in_tbl.delete;
                        G_TASK_PROGRESS_tbl_count       := 0;
                WHEN OTHERS THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        ROLLBACK TO Execute_Update_Task_Progress;
                        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                        G_bulk_load_flag :='N';
                        G_TASK_PROGRESS_in_tbl.delete;
                        G_TASK_PROGRESS_tbl_count       := 0;
END Execute_Update_Task_Progress;


PROCEDURE Project_Level_Validations
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE
, p_commit                      IN      VARCHAR2        := FND_API.G_FALSE
, p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id                  IN      NUMBER
, p_pm_project_reference        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_project_id_out              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
)
IS
l_api_name                      CONSTANT        VARCHAR2(30)    := 'Project_Level_Validations';
l_api_version_number            CONSTANT        NUMBER  := G_API_VERSION_NUMBER;
l_msg_count                     INTEGER;
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(1):= 'S';
l_project_id_out                        NUMBER                  := 0;
l_function_allowed              VARCHAR2(1);
l_resp_id                       NUMBER                                   := 0;
l_pm_product_code               pa_percent_completes.pm_product_code%TYPE       := NULL;
l_description                   pa_percent_completes.description%TYPE           := NULL;
l_as_of_date                    DATE;
l_current_flag                  VARCHAR2(1);
l_dummy                         VARCHAR2(1);
l_module_name                   VARCHAR2(80);
l_user_id                       NUMBER                                   := 0;
l_date_computed                 DATE;


BEGIN
        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;


        IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number  ,
                                         l_api_name,
                                         G_PKG_NAME)

        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Moved from below for project security changes. --Bug 2471668

        PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_project_id
                 ,  p_out_project_id    =>      l_project_id_out
                 ,  p_return_status     =>      l_return_status
        );


        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
        p_project_id_out := l_project_id_out;

--Bug 2471668

    l_user_id := FND_GLOBAL.User_id;
    l_resp_id := FND_GLOBAL.Resp_id;
    --l_module_name := p_pm_product_code||'.'||'PA_PM_UPDATE_PROJ_PROGRESS';

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    --Bug 2471668
    PA_INTERFACE_UTILS_PUB.g_project_id := l_project_id_out;

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_PROJ_PROGRESS',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed );


        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
           FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF  FND_API.to_boolean(p_init_msg_list)
        THEN
                FND_MSG_PUB.initialize;
        END IF;

-- VALUE LAYER -----------------------------------------------------------------------

      IF pa_security.allow_query (x_project_id => l_project_id_out ) = 'N' THEN

         -- The user does not have query privileges on this project
         -- Hence, cannot update the project.Raise error

           FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF pa_security.allow_update (x_project_id => l_project_id_out ) = 'N'
            THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

           FND_MESSAGE.SET_NAME('PA','PA_PROJECT_SECURITY_ENFORCED');
           FND_MSG_PUB.add;
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

        IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           FND_MSG_PUB.Count_And_Get
                        ( p_count  => p_msg_count
                         ,p_data   => p_msg_data
                        );
        END IF;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );
                WHEN OTHERS THEN
                        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                (       G_PKG_NAME
                                        , l_api_name
                                );
                        END IF;
                        FND_MSG_PUB.Count_And_Get
                        (       p_count                 =>      p_msg_count
                                ,p_data                 =>      p_msg_data
                        );

END Project_Level_Validations;

/* Progress Management Changes. Bug # 3420093. */

PROCEDURE update_task_progress_amg
( p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_progress_mode               IN      VARCHAR2        := 'FUTURE'
 ,p_project_id                  IN      NUMBER
 ,p_structure_version_id        IN      NUMBER
 ,p_structure_type              IN      VARCHAR2
 ,p_as_of_date                  IN      DATE
 ,p_task_progress_list_table    IN      PA_PROGRESS_PUB.PA_TASK_PROGRESS_LIST_TBL_TYPE
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
) is

    l_task_progress_rec             PA_PROGRESS_PUB.PA_TASK_PROGRESS_LIST_REC_TYPE;
    l_return_status                 VARCHAR2(1);
    l_api_name                      VARCHAR2(30)    := 'update_task_progress_amg';
begin
    IF  FND_API.to_boolean(p_init_msg_list)
    THEN
             FND_MSG_PUB.initialize;
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Setting context for the temporary fin_plan table.

    PA_PROGRESS_PUB.populate_pji_tab_for_plan(
    p_api_version               =>      p_api_version
    ,p_init_msg_list            =>      p_init_msg_list
    ,p_commit                   =>      p_commit
    ,p_calling_module           =>      'AMG'
    ,p_debug_mode               =>      p_debug_mode
    ,p_max_msg_count            =>      p_max_msg_count
    ,p_project_id               =>      p_project_id
    ,p_structure_version_id     =>      p_structure_version_id
    --,p_baselined_str_ver_id   =>      p_baselined_str_ver_id
    ,x_return_status            =>      x_return_status
    ,x_msg_count                =>      x_msg_count
    ,x_msg_data                 =>      x_msg_data
    );

   -- 4537865 : Included check for x_return_status
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call Update progress for each task with P_rollup_entire_wbs_flag = 'N' and p_calling_module = 'AMG'.

    for l_loop_count in  1 .. p_task_progress_list_table.count
    loop
        l_task_progress_rec := p_task_progress_list_table(l_loop_count);

        PA_PROGRESS_PUB.UPDATE_PROGRESS(
        p_api_version                   =>      p_api_version
        ,p_init_msg_list                =>      p_init_msg_list
        ,p_commit                       =>      p_commit
        ,p_validate_only                =>      p_validate_only
        ,p_validation_level             =>      p_validation_level
        ,p_calling_module               =>      'AMG'
        ,p_debug_mode                   =>      p_debug_mode
        ,p_max_msg_count                =>      p_max_msg_count
        ,P_rollup_entire_wbs_flag       =>      'N'
        ,p_progress_mode                =>      p_progress_mode
        --,p_percent_complete_id        =>      l_task_progress_rec.percent_complete_id
        ,p_project_id                   =>      p_project_id
        ,p_object_id                    =>      l_task_progress_rec.object_id
        ,p_object_version_id            =>      l_task_progress_rec.object_version_id
        ,p_object_type                  =>      l_task_progress_rec.object_type
        ,p_as_of_date                   =>      p_as_of_date
        ,p_percent_complete             =>      l_task_progress_rec.percent_complete
        ,p_progress_status_code         =>      l_task_progress_rec.progress_status_code
        ,p_progress_comment             =>      l_task_progress_rec.progress_comment
        --,p_brief_overview             =>      l_task_progress_rec.brief_overview
        ,p_actual_start_date            =>      l_task_progress_rec.actual_start_date
        ,p_actual_finish_date           =>      l_task_progress_rec.actual_finish_date
        ,p_estimated_start_date         =>      l_task_progress_rec.estimated_start_date
        ,p_estimated_finish_date        =>      l_task_progress_rec.estimated_finish_date
        ,p_scheduled_start_date         =>      l_task_progress_rec.scheduled_start_date
        ,p_scheduled_finish_date        =>      l_task_progress_rec.scheduled_finish_date
        --,p_record_version_number      =>      l_task_progress_rec.record_version_number
        ,p_task_status                  =>      l_task_progress_rec.task_status
        ,p_est_remaining_effort         =>      l_task_progress_rec.est_remaining_effort
        ,p_ETC_cost                     =>      l_task_progress_rec.ETC_cost
        ,p_actual_work_quantity         =>      l_task_progress_rec.actual_work_quantity
        --,p_pm_product_code            =>      l_task_progress_rec.pm_product_code
        ,p_structure_type               =>      p_structure_type
        --,p_actual_effort              =>      l_task_progress_rec.actual_effort
        --,p_actual_cost                =>      l_task_progress_rec.actual_cost
        --,p_actual_effort_this_period  =>      l_task_progress_rec.actual_effort_this_period
        --,p_actual_cost_this_period    =>      l_task_progress_rec.actual_cost_this_period
        --,p_object_sub_type            =>      l_task_progress_rec.object_sub_type
        ,p_task_id                      =>      l_task_progress_rec.task_id
        ,p_structure_version_id         =>      p_structure_version_id
        --,p_prog_fom_wp_flag           =>      l_task_progress_rec.prog_fom_wp_flag
        --,p_rollup_reporting_lines_flag=>      l_task_progress_rec.rollup_reporting_lines_flag
        --,p_planned_cost               =>      l_task_progress_rec.planned_cost
        --,p_planned_effort             =>      l_task_progress_rec.planned_effort
        --,p_rate_based_flag            =>      l_task_progress_rec.rate_based_flag
        --,p_resource_class_code        =>      l_task_progress_rec.resource_class_code
        --,p_transfer_wp_pc_flag        =>      l_task_progress_rec.transfer_wp_pc_flag
        --,p_rbs_element_id             =>      l_task_progress_rec.rbs_element_id
        --,p_resource_list_member_id    =>      l_task_progress_rec.resource_list_member_id
        ,x_return_status                =>      x_return_status
        ,x_msg_count                    =>      x_msg_count
        ,x_msg_data                     =>      x_msg_data
        );
    -- 4537865 : Included check for x_return_status
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    end loop;

        -- Call rollup_progress_pvt api for the entire structure.

                PA_PROGRESS_PUB.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list             => p_init_msg_list
                ,p_commit                    => p_commit
                ,p_validate_only             => p_validate_only
                ,p_project_id                => p_project_id
                ,p_structure_version_id      => p_structure_version_id
                ,p_as_of_date                => trunc(p_as_of_date) -- 5294838
                ,x_return_status             => x_return_status
                ,x_msg_count                 => x_msg_count
                ,x_msg_data                  => x_msg_data);

        if (x_return_status <> fnd_api.g_ret_sts_success ) then
           fnd_msg_pub.count_and_get
                        (p_count   => x_msg_count
                         ,p_data   => x_msg_data);
        end if;

exception

                when fnd_api.g_exc_error then
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_msg_pub.count_and_get
                        (p_count => x_msg_count
                         ,p_data => x_msg_data);
                when fnd_api.g_exc_unexpected_error then
                        x_return_status := fnd_api.g_ret_sts_unexp_error;
                        fnd_msg_pub.count_and_get
                        (p_count => x_msg_count
                         ,p_data => x_msg_data);
                when others then
                        x_return_status := fnd_api.g_ret_sts_unexp_error;
                        if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) then
                                fnd_msg_pub.add_exc_msg(g_pkg_name,l_api_name);
                        end if;
                        fnd_msg_pub.count_and_get
                        (p_count => x_msg_count
                         ,p_data => x_msg_data);

end update_task_progress_amg;

/* Progress Management Changes. Bug # 3420093. */

-- =================================================================

END pa_Status_Pub;

/
