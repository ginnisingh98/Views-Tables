--------------------------------------------------------
--  DDL for Package Body PA_DELIVERABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DELIVERABLE_PVT" AS
/* $Header: PADLVPVB.pls 120.3 2006/01/27 04:39:32 vkadimes noship $ */

Invalid_Arg_Exc_Dlv EXCEPTION ;
g_module_name   VARCHAR2(100) := 'PA_DELIVERABLE_PVT';
g_deliverable_based CONSTANT pa_lookups.lookup_code%TYPE := 'DELIVERABLE' ;

-- Procedure            : Create_Deliverable
-- Type                 : PRIVATE
-- Purpose              : Create_Deliverable Procedure will be called for creation of deliverable
-- Note                 : Call insert_row method of pa_proj_elements, pa_proj_element_versions,
--                      : pa_proj_element_sch and pa_object_relationships packages
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_api_version                NUMBER      N           1.0
-- p_init_msg_list              VARCHAR2    N           := FND_API.G_TRUE
-- p_commit                     VARCHAR2    N           := FND_API.G_FALSE
-- p_validate_only              VARCHAR2    N           := FND_API.G_TRUE
-- p_validation_level           NUMBER      N           := FND_API.G_VALID_LEVEL_FULL
-- p_calling_module             VARCHAR2    N           := 'SELF_SERVICE'
-- p_debug_mode                 VARCHAR2    N           := 'N'
-- p_max_msg_count              NUMBER      N           := NULL
-- p_record_version_number      NUMBER      N           := 1
-- p_object_type                VARCHAR2    N           Object Type Default 'PA_DELIVERABLES'
-- p_project_id                 NUMBER      Y           Project Id
-- p_dlvr_number                VARCHAR2    Y           Deliverable Number
-- p_dlvr_name                  VARCHAR2    Y           Deliverable Name
-- p_dlvr_description           VARCHAR2    N           Description
-- p_dlvr_owner_id              NUMBER      N           Deliverable Owner Id
-- p_dlvr_owner_name            VARCHAR2    N           Delivearble Owner Name
-- p_carrying_out_org_id        NUMBER      N           Project Carrying Out Organization Id
-- p_carrying_out_org_name      VARCHAR2    N           Project Carrying Out Organization Name
-- p_dlvr_version_id            NUMBER      N           Deliverable Version Id
-- p_status_code                VARCHAR2    N           Delivearble Status
-- p_parent_structure_id        NUMBER      N           Deliverable Parent Structure Id
-- p_parent_struct_ver_id       NUMBER      N           Deliverable Parent Structure Version Id
-- p_dlvr_type_id               NUMBER      N           Deliverable Type Id
-- p_dlvr_type_name             VARCHAR2    N           Deliverable Type Name
-- p_progress_weight            NUMBER      N           Progress Weight
-- p_scheduled_finish_date      DATE        N           Scheduled Finish Date
-- p_actual_finish_date         DATE        N           Actual Finish Date
-- p_task_id                    NUMBER      N           task_id
-- p_task_version_id            NUMBER      N           task_version_id
-- p_task_name                  VARCHAR2    N           task_name
-- p_attribute_category         VARCHAR2    N           attribute_category
-- p_attribute1                 VARCHAR2    N           attribute1
-- p_attribute2                 VARCHAR2    N           attribute2
-- p_attribute3                 VARCHAR2    N           attribute3
-- p_attribute4                 VARCHAR2    N           attribute4
-- p_attribute5                 VARCHAR2    N           attribute5
-- p_attribute6                 VARCHAR2    N           attribute6
-- p_attribute7                 VARCHAR2    N           attribute7
-- p_attribute8                 VARCHAR2    N           attribute8
-- p_attribute9                 VARCHAR2    N           attribute9
-- p_attribute10                VARCHAR2    N           attribute10
-- p_attribute11                VARCHAR2    N           attribute11
-- p_attribute12                VARCHAR2    N           attribute12
-- p_attribute13                VARCHAR2    N           attribute13
-- p_attribute14                VARCHAR2    N           attribute14
-- p_attribute15                VARCHAR2    N           attribute15
-- p_dlvr_item_id               NUMBER      N           proj_element_id
-- x_return_status              VARCHAR2    N           Return Status
-- x_msg_count                  NUMBER      N           Message Count
-- x_msg_data                   VARCHAR2    N           Message Data

PROCEDURE Create_Deliverable
    (
       p_api_version            IN   NUMBER     := 1.0
     , p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE
     , p_commit                 IN   VARCHAR2   := FND_API.G_FALSE
     , p_validate_only          IN   VARCHAR2   := FND_API.G_TRUE
     , p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN   VARCHAR2   := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2   := 'N'
     , p_max_msg_count          IN   NUMBER     := NULL
     , p_record_version_number  IN   NUMBER     := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE                  := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE                  := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE            := NULL
     , p_dlvr_owner_name        IN  VARCHAR2   := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL
     , p_carrying_out_org_name  IN  VARCHAR2 := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE       := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE                  := NULL
     , p_parent_structure_id    IN   PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE
     , p_parent_struct_ver_id   IN   PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     , p_dlvr_type_id           IN   PA_PROJ_ELEMENTS.TYPE_ID%TYPE                          := NULL
     , p_dlvr_type_name         IN   VARCHAR2   := NULL
     , p_dlvr_reference          IN  VARCHAR2   := NULL  -- 3435905
     , p_progress_weight        IN   PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE                  := NULL
     , p_scheduled_finish_date  IN   PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE   := NULL
     , p_actual_finish_date     IN   PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE      := NULL
     , p_task_id                IN   NUMBER     := NULL
     , p_task_version_id        IN   NUMBER     := NULL
     , p_task_name              IN   VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE   := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE           := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE           := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE           := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE           := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE           := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE           := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE           := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE           := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE           := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE          := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE          := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE          := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE          := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE          := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE          := NULL
     , p_dlvr_item_id           OUT  NOCOPY PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE --File.Sql.39 bug 4440895
     , p_pm_source_code         IN  VARCHAR2   := NULL              /* Bug no. 3651113 */
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS

l_msg_count                     NUMBER := 0;
l_element_id                    NUMBER := NULL;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

X_ROW_ID                        VARCHAR2(18);
l_proj_element_id               PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE := NULL;
l_dlvr_version_id               PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE   := NULL;
l_new_pev_schedule_id           PA_PROJ_ELEM_VER_SCHEDULE.PEV_SCHEDULE_ID%TYPE := NULL;
l_new_obj_rel_id                PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE := NULL;
l_progress_weight               PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE := NULL;  -- 3570283 added
l_prog_rollup_method            VARCHAR2(30) := NULL;

l_dlvr_prg_flag                 VARCHAR2(1) := 'N';      -- 3570283 added
l_dlvr_act_flag                 VARCHAR2(1) := 'N';      -- 3570283 added
l_dlvr_dflt_status              VARCHAR2(30) := NULL;    -- 3570283 added

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'CREATE_DELIVERABLE',
                                     p_debug_mode => l_debug_mode );
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint CREATE_DLVR_PVT;
    END IF;

    -- Business Logic

    -- if create deliverable is done from task detail page,
    -- retrieve progress rollup method for task
    -- if it is deliveable_based and progress is enabled, check progress_weight is not null

    -- 3570283 added , to retrieve deliverable type information

    PA_DELIVERABLE_UTILS.get_dlvr_type_info
                (
                     p_dlvr_type_id                 =>  p_dlvr_type_id
                    ,x_dlvr_prg_enabled             =>  l_dlvr_prg_flag
                    ,x_dlvr_action_enabled          =>  l_dlvr_act_flag
                    ,x_dlvr_default_status_code     =>  l_dlvr_dflt_status
                );

    IF l_debug_mode = 'Y' THEN
        Pa_Debug.WRITE(g_module_name,' l_dlvr_prg_flag ' || l_dlvr_prg_flag, l_debug_level3);
    END IF;

    -- 3570283
    -- added one if contion l_dlvr_prg_flag = 'Y'
    -- if progress is enabled for deliverable type and task_id is not null, then check for
    -- manadatory progress weight parameter

    IF p_task_id IS NOT NULL AND l_dlvr_prg_flag = 'Y' THEN -- 3570283 added l_dlvr_prg_flag condition

        l_prog_rollup_method := PA_DELIVERABLE_UTILS.get_progress_rollup_method
                                    (
                                        p_task_id          => p_task_id
                                    );

        IF l_debug_mode = 'Y' THEN
            Pa_Debug.WRITE(g_module_name,' l_prog_rollup_method ' || l_prog_rollup_method, l_debug_level3);
        END IF;

        IF l_prog_rollup_method = g_deliverable_based THEN
            IF p_progress_weight IS NULL THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLVR_PROG_WEIGHT_MISSING');
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENTS_PKG.Insert_Row Called ',
                                    l_debug_level3);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 3570283 added
    -- if deliverable type is changed from progress enabled type to disabled type
    -- progress weight shuold be passed accordingly as user entered value or null

    IF l_dlvr_prg_flag = 'Y' THEN
        l_progress_weight := p_progress_weight;
    ELSE
        l_progress_weight := NULL;
    END IF;

    -- 3570283 added

    -- call insert_row of pa_proj_elements package

    PA_PROJ_ELEMENTS_PKG.Insert_Row
        (
             X_ROW_ID                           => X_ROW_ID
            ,X_PROJ_ELEMENT_ID                  => l_proj_element_id
            ,X_PROJECT_ID                       => p_project_id
            ,X_OBJECT_TYPE                      => p_object_type
            ,X_ELEMENT_NUMBER                   => p_dlvr_number
            ,X_NAME                             => p_dlvr_name
            ,X_DESCRIPTION                      => p_dlvr_description
            ,X_STATUS_CODE                      => p_status_code
            ,X_WF_STATUS_CODE                   => null
            ,X_PM_PRODUCT_CODE                  => p_pm_source_code         /* Bug no. 3651113 -- Passed p_pm_source_code instead of null*/
            ,X_PM_TASK_REFERENCE                => p_dlvr_reference
            ,X_CLOSED_DATE                      => NULL
            ,X_LOCATION_ID                      => NULL
            ,X_MANAGER_PERSON_ID                => p_dlvr_owner_id
            ,X_CARRYING_OUT_ORGANIZATION_ID     => p_carrying_out_org_id
            ,X_TYPE_ID                          => p_dlvr_type_id
            ,X_PRIORITY_CODE                    => NULL
            ,X_INC_PROJ_PROGRESS_FLAG           => NULL
            ,X_REQUEST_ID                       => NULL
            ,X_PROGRAM_APPLICATION_ID           => NULL
            ,X_PROGRAM_ID                       => NULL
            ,X_PROGRAM_UPDATE_DATE              => NULL
            ,X_LINK_TASK_FLAG                   => NULL
            ,X_ATTRIBUTE_CATEGORY               => p_attribute_category
            ,X_ATTRIBUTE1                       => p_attribute1
            ,X_ATTRIBUTE2                       => p_attribute2
            ,X_ATTRIBUTE3                       => p_attribute3
            ,X_ATTRIBUTE4                       => p_attribute4
            ,X_ATTRIBUTE5                       => p_attribute5
            ,X_ATTRIBUTE6                       => p_attribute6
            ,X_ATTRIBUTE7                       => p_attribute7
            ,X_ATTRIBUTE8                       => p_attribute8
            ,X_ATTRIBUTE9                       => p_attribute9
            ,X_ATTRIBUTE10                      => p_attribute10
            ,X_ATTRIBUTE11                      => p_attribute11
            ,X_ATTRIBUTE12                      => p_attribute12
            ,X_ATTRIBUTE13                      => p_attribute13
            ,X_ATTRIBUTE14                      => p_attribute14
            ,X_ATTRIBUTE15                      => p_attribute15
            ,X_TASK_WEIGHTING_DERIV_CODE        => NULL
            ,X_WORK_ITEM_CODE                   => NULL
            ,X_UOM_CODE                         => NULL
            ,X_WQ_ACTUAL_ENTRY_CODE             => NULL
            ,X_TASK_PROGRESS_ENTRY_PAGE_ID      => NULL
            ,X_PARENT_STRUCTURE_ID              => p_parent_structure_id
            ,X_PHASE_CODE                       => NULL
            ,X_PHASE_VERSION_ID                 => NULL
            ,X_PROGRESS_WEIGHT                  => l_progress_weight    -- 3570283 changed from p_progress_weight
--            ,X_PROG_ROLLUP_METHOD               => NULL
            ,X_FUNCTION_CODE                    => NULL
            ,X_SOURCE_OBJECT_ID                 => p_project_id
            ,X_SOURCE_OBJECT_TYPE               => 'PA_PROJECTS'
        );


    p_dlvr_item_id  := l_proj_element_id;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENTS_PKG.Insert_Row Element ['||p_dlvr_number||']['||p_dlvr_number||']',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row Called ',
                                    l_debug_level3);
    END IF;

    -- call insert_row of pa_proj_element_versions package

    l_dlvr_version_id := p_dlvr_version_id;

    PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row
        (
             X_ROW_ID                           => X_ROW_ID
            ,X_ELEMENT_VERSION_ID               => l_dlvr_version_id
            ,X_PROJ_ELEMENT_ID                  => l_proj_element_id
            ,X_OBJECT_TYPE                      => p_object_type
            ,X_PROJECT_ID                       => p_project_id
            ,X_PARENT_STRUCTURE_VERSION_ID      => p_parent_struct_ver_id
            ,X_DISPLAY_SEQUENCE                 => NULL
            ,X_WBS_LEVEL                        => NULL
            ,X_WBS_NUMBER                       => NULL
            ,X_ATTRIBUTE_CATEGORY               => p_attribute_category
            ,X_ATTRIBUTE1                       => p_attribute1
            ,X_ATTRIBUTE2                       => p_attribute2
            ,X_ATTRIBUTE3                       => p_attribute3
            ,X_ATTRIBUTE4                       => p_attribute4
            ,X_ATTRIBUTE5                       => p_attribute5
            ,X_ATTRIBUTE6                       => p_attribute6
            ,X_ATTRIBUTE7                       => p_attribute7
            ,X_ATTRIBUTE8                       => p_attribute8
            ,X_ATTRIBUTE9                       => p_attribute9
            ,X_ATTRIBUTE10                      => p_attribute10
            ,X_ATTRIBUTE11                      => p_attribute11
            ,X_ATTRIBUTE12                      => p_attribute12
            ,X_ATTRIBUTE13                      => p_attribute13
            ,X_ATTRIBUTE14                      => p_attribute14
            ,X_ATTRIBUTE15                      => p_attribute15
            ,X_TASK_UNPUB_VER_STATUS_CODE       => NULL
            ,X_SOURCE_OBJECT_ID                 => p_project_id
            ,X_SOURCE_OBJECT_TYPE               => 'PA_PROJECTS'
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row Element['||l_dlvr_version_id||']',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENT_SCH_PKG.Insert_Row Called ',
                                    l_debug_level3);
    END IF;

    -- call insert_row of pa_proj_element_sch package

    PA_PROJ_ELEMENT_SCH_PKG.Insert_Row
        (
             X_ROW_ID                   => X_Row_Id
            ,X_PEV_SCHEDULE_ID          => l_new_pev_schedule_id
            ,X_ELEMENT_VERSION_ID       => l_dlvr_version_id
            ,X_PROJECT_ID               => p_project_id
            ,X_PROJ_ELEMENT_ID          => l_proj_element_id
            ,X_SCHEDULED_START_DATE     => NULL
            ,X_SCHEDULED_FINISH_DATE    => p_scheduled_finish_date
            ,X_OBLIGATION_START_DATE    => NULL
            ,X_OBLIGATION_FINISH_DATE   => NULL
            ,X_ACTUAL_START_DATE        => NULL
            ,X_ACTUAL_FINISH_DATE       => p_actual_finish_date
            ,X_ESTIMATED_START_DATE     => NULL
            ,X_ESTIMATED_FINISH_DATE    => NULL
            ,X_DURATION                 => NULL
            ,X_EARLY_START_DATE         => NULL
            ,X_EARLY_FINISH_DATE        => NULL
            ,X_LATE_START_DATE          => NULL
            ,X_LATE_FINISH_DATE         => NULL
            ,X_CALENDAR_ID              => NULL
            ,X_MILESTONE_FLAG           => NULL
            ,X_CRITICAL_FLAG            => NULL
            ,X_WQ_PLANNED_QUANTITY      => NULL
            ,X_PLANNED_EFFORT           => NULL
            ,X_ACTUAL_DURATION          => NULL
            ,X_ESTIMATED_DURATION       => NULL
            ,X_ATTRIBUTE_CATEGORY       => p_attribute_category
            ,X_ATTRIBUTE1               => p_attribute1
            ,X_ATTRIBUTE2               => p_attribute2
            ,X_ATTRIBUTE3               => p_attribute3
            ,X_ATTRIBUTE4               => p_attribute4
            ,X_ATTRIBUTE5               => p_attribute5
            ,X_ATTRIBUTE6               => p_attribute6
            ,X_ATTRIBUTE7               => p_attribute7
            ,X_ATTRIBUTE8               => p_attribute8
            ,X_ATTRIBUTE9               => p_attribute9
            ,X_ATTRIBUTE10              => p_attribute10
            ,X_ATTRIBUTE11              => p_attribute11
            ,X_ATTRIBUTE12              => p_attribute12
            ,X_ATTRIBUTE13              => p_attribute13
            ,X_ATTRIBUTE14              => p_attribute14
            ,X_ATTRIBUTE15              => p_attribute15
            ,X_SOURCE_OBJECT_ID         => p_project_id
            ,X_SOURCE_OBJECT_TYPE       => 'PA_PROJECTS'
    );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENT_SCH_PKG.Insert_Row schedule ['||l_new_pev_schedule_id||']',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_OBJECT_RELATIONSHIPS_PKG.Insert_Row Called Structure-To-Deliverable',
                                    l_debug_level3);
    END IF;

    -- call insert_row of pa_object_relationships package
    -- it creates relationship from structure_to_deliverable

    PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW
        (
             p_user_id                  => FND_GLOBAL.USER_ID
            ,p_object_type_from         => 'PA_STRUCTURES'
            ,p_object_id_from1          => p_parent_struct_ver_id
            ,p_object_id_from2          => p_parent_structure_id
            ,p_object_id_from3          => NULL
            ,p_object_id_from4          => NULL
            ,p_object_id_from5          => NULL
            ,p_object_type_to           => 'PA_DELIVERABLES'
            ,p_object_id_to1            => p_dlvr_version_id
            ,p_object_id_to2            => l_proj_element_id
            ,p_object_id_to3            => NULL
            ,p_object_id_to4            => NULL
            ,p_object_id_to5            => NULL
            ,p_relationship_type        => 'S'
            ,p_relationship_subtype     => 'STRUCTURE_TO_DELIVERABLE'
            ,p_lag_day                  => NULL
            ,p_imported_lag             => NULL
            ,p_priority                 => NULL
            ,p_pm_product_code          => p_pm_source_code             /* Bug no. 3651113 -- Passed p_pm_source_code instead of null*/
            ,x_object_relationship_id   => l_new_obj_rel_id
            ,x_return_status            => x_return_status
        );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_OBJECT_RELATIONSHIPS_PKG.Insert_Row Structure-To-Deliverable str vers ['
                        ||p_parent_struct_ver_id||']str ['||p_parent_struct_ver_id||']' ,  l_debug_level3);
    END IF;

    IF (P_TASK_ID IS NOT NULL ) THEN

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_PVT.CREATE_DLV_TASK_ASSOCIATION Called Task-To-Deliverable',
                                        l_debug_level3);
        END IF;

        -- if task_id is not null , i.e. create_deliverable is called from task page
        -- call insert_row of pa_object_relationships package
        -- it creates relationship from task_to_deliverable
/*
        PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW
            (
                 p_user_id                  => FND_GLOBAL.USER_ID
                ,p_object_type_from         => 'PA_TASKS'
                ,p_object_id_from1          => p_task_version_id
                ,p_object_id_from2          => p_task_id
                ,p_object_id_from3          => NULL
                ,p_object_id_from4          => NULL
                ,p_object_id_from5          => NULL
                ,p_object_type_to           => 'PA_DELIVERABLES'
                ,p_object_id_to1            => p_dlvr_version_id
                ,p_object_id_to2            => l_proj_element_id
                ,p_object_id_to3            => NULL
                ,p_object_id_to4            => NULL
                ,p_object_id_to5            => NULL
                ,p_relationship_type        => 'A'
                ,p_relationship_subtype     => 'TASK_TO_DELIVERABLE'
                ,p_lag_day                  => NULL
                ,p_imported_lag             => NULL
                ,p_priority                 => NULL
                ,p_pm_product_code          => NULL
                ,x_object_relationship_id   => l_new_obj_rel_id
                ,x_return_status            => x_return_status
            );

*/
        PA_DELIVERABLE_PVT.CREATE_DLV_TASK_ASSOCIATION
            (     p_debug_mode              =>      l_debug_mode
                 ,p_task_element_id         =>      p_task_id
                 ,p_task_version_id         =>      p_task_version_id
                 ,p_dlv_element_id          =>      l_proj_element_id
                 ,p_dlv_version_id          =>      p_dlvr_version_id
                 ,p_project_id              =>      p_project_id
                 ,x_return_status           =>      x_return_status
                 ,x_msg_count               =>      x_msg_count
                 ,x_msg_data                =>      x_msg_data
            );


        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_PVT.CREATE_DLV_TASK_ASSOCIATION Task-To-Dlvr['||x_return_status||']',
                                        l_debug_level3);
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_ACTIONS_PUB.COPY_ACTIONS Called ',
                                    l_debug_level3);
    END IF;

    IF (p_calling_module <> 'AMG') THEN
        PA_ACTIONS_PUB.COPY_ACTIONS
        (
            p_init_msg_list                 => p_init_msg_list
           ,p_commit                        => p_commit
           ,p_debug_mode                    => l_debug_mode
           ,p_source_object_id              => p_dlvr_type_id
           ,p_source_object_type            => 'PA_DLVR_TYPES'
           ,p_target_object_id              => l_proj_element_id
           ,p_target_object_type            => 'PA_DELIVERABLES'
           ,p_source_project_id             => null
           ,p_target_project_id             => p_project_id
           ,p_task_id                       => p_task_id
           ,p_task_ver_id                   => p_task_version_id
           ,p_carrying_out_organization_id  => p_carrying_out_org_id
           ,p_pm_source_reference           => null
           ,p_pm_source_code                => null
           ,p_calling_mode                  => 'CREATE' -- Added for bug 3911050
           ,x_return_status                 => x_return_status
           ,x_msg_count                     => x_msg_count
           ,x_msg_data                      => x_msg_data
        ) ;


       IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Out of PA_ACTIONS_PUB.COPY_ACTIONS ['||x_return_status||']', l_debug_level3);
       END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF; --p_calling_module <> 'AMG'

     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO CREATE_DLVR_PVT;
     END IF;

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
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO CREATE_DLVR_PVT;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_PVT'
                    , p_procedure_name  => 'Create_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Create_Deliverable;


-- Procedure            : Update_Deliverable
-- Type                 : PRIVATE
-- Purpose              : Update_Deliverable Procedure will be called for creation of deliverable
-- Note                 : Call update_row method of pa_proj_elements, pa_proj_element_versions,
--                      : pa_proj_element_sch and pa_object_relationships packages
-- Assumptions          : None

-- Parameters                   Type     Required       Description and Purpose
-- ---------------------------  ------   --------       --------------------------------------------------------
-- p_api_version                NUMBER      N           1.0
-- p_init_msg_list              VARCHAR2    N           := FND_API.G_TRUE
-- p_commit                     VARCHAR2    N           := FND_API.G_FALSE
-- p_validate_only              VARCHAR2    N           := FND_API.G_TRUE
-- p_validation_level           NUMBER      N           := FND_API.G_VALID_LEVEL_FULL
-- p_calling_module             VARCHAR2    N           := 'SELF_SERVICE'
-- p_debug_mode                 VARCHAR2    N           := 'N'
-- p_max_msg_count              NUMBER      N           := NULL
-- p_record_version_number      NUMBER      N           := 1
-- p_object_type                VARCHAR2    N           Object Type Default 'PA_DELIVERABLES'
-- p_project_id                 NUMBER      Y           Project Id
-- p_dlvr_number                VARCHAR2    Y           Deliverable Number
-- p_dlvr_name                  VARCHAR2    Y           Deliverable Name
-- p_dlvr_description           VARCHAR2    N           Description
-- p_dlvr_owner_id              NUMBER      N           Deliverable Owner Id
-- p_dlvr_owner_name            VARCHAR2    N           Delivearble Owner Name
-- p_carrying_out_org_id        NUMBER      N           Project Carrying Out Organization Id
-- p_carrying_out_org_name      VARCHAR2    N           Project Carrying Out Organization Name
-- p_dlvr_version_id            NUMBER      N           Deliverable Version Id
-- p_status_code                VARCHAR2    N           Delivearble Status
-- p_parent_structure_id        NUMBER      N
-- p_parent_struct_ver_id       NUMBER      N
-- p_dlvr_type_id               NUMBER      N           Deliverable Type Id
-- p_dlvr_type_name             VARCHAR2    N           Deliverable Type Name
-- p_progress_weight            NUMBER      N           Progress Weight
-- p_scheduled_finish_date      DATE        N           Scheduled Finish Date
-- p_actual_finish_date         DATE        N           Actual Finish Date
-- p_task_id                    NUMBER      N
-- p_task_version_id            NUMBER      N
-- p_task_name                  VARCHAR2    N
-- p_attribute_category         VARCHAR2    N
-- p_attribute1                 VARCHAR2    N
-- p_attribute2                 VARCHAR2    N
-- p_attribute3                 VARCHAR2    N
-- p_attribute4                 VARCHAR2    N
-- p_attribute5                 VARCHAR2    N
-- p_attribute6                 VARCHAR2    N
-- p_attribute7                 VARCHAR2    N
-- p_attribute8                 VARCHAR2    N
-- p_attribute9                 VARCHAR2    N
-- p_attribute10                VARCHAR2    N
-- p_attribute11                VARCHAR2    N
-- p_attribute12                VARCHAR2    N
-- p_attribute13                VARCHAR2    N
-- p_attribute14                VARCHAR2    N
-- p_attribute15                VARCHAR2    N
-- p_dlvr_item_id               NUMBER      N           proj_element_id
-- x_return_status              VARCHAR2    N           Return Status
-- x_msg_count                  NUMBER      N           Message Count
-- x_msg_data                   VARCHAR2    N           Message Data

PROCEDURE Update_Deliverable
    (
       p_api_version            IN   NUMBER     := 1.0
     , p_init_msg_list          IN   VARCHAR2   := FND_API.G_TRUE
     , p_commit                 IN   VARCHAR2   := FND_API.G_FALSE
     , p_validate_only          IN   VARCHAR2   := FND_API.G_TRUE
     , p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN   VARCHAR2   := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2   := 'N'
     , p_max_msg_count          IN   NUMBER     := NULL
     , p_record_version_number  IN   NUMBER     := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE                       := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE                       := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE                 := NULL
     , p_dlvr_owner_name        IN  VARCHAR2    := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE      := NULL
     , p_carrying_out_org_name  IN  VARCHAR2    := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE        := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE                       := NULL
     , p_parent_structure_id    IN   PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE
     , p_parent_struct_ver_id   IN   PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE
     , p_dlvr_type_id           IN   PA_PROJ_ELEMENTS.TYPE_ID%TYPE                          := NULL
     , p_dlvr_type_name         IN   VARCHAR2   := NULL
     , p_progress_weight        IN   PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE                  := NULL
     , p_scheduled_finish_date  IN   PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE   := NULL
     , p_actual_finish_date     IN   PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE      := NULL
     , p_task_id                IN   NUMBER     := NULL
     , p_task_version_id        IN   NUMBER     := NULL
     , p_task_name              IN   VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE   := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE           := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE           := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE           := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE           := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE           := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE           := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE           := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE           := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE           := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE          := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE          := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE          := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE          := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE          := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE          := NULL
     , p_dlvr_item_id           IN   PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     , p_pm_source_code         IN  VARCHAR2   :=NULL              /* Bug no. 3651113 */
     , p_deliverable_reference  IN  VARCHAR2   := NULL             -- added for bug# 3749447
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
IS

l_msg_count                     NUMBER := 0;
l_element_id                    NUMBER := NULL;
l_dlvr_version_id               NUMBER := NULL;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);


l_utl_return_status             VARCHAR2(1);
l_utl_msg_count                 NUMBER := 0;
l_utl_msg_data                  VARCHAR2(2000);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_prog_rollup_method            VARCHAR2(30)    := NULL;
l_progress_weight               PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE := NULL; -- 3570283 added
l_calling_mode                  VARCHAR2(30)    := 'UPDATE_DUE_DATE';


l_ready_to_ship                 VARCHAR2(1)    := 'N';
l_ready_to_procure              VARCHAR2(1)    := 'N';
l_read_to_create_demand         VARCHAR2(1)    := 'N';
l_planning_initiated            VARCHAR2(1)    := 'N';
l_proc_initiated                VARCHAR2(1)    := 'N';
l_item_info_exists              VARCHAR2(1)    := 'N';
l_item_shippable                VARCHAR2(1)    := 'N';
l_item_billable                 VARCHAR2(1)    := 'N';
l_item_purchasable              VARCHAR2(1)    := 'N';
l_shipping_initiated            VARCHAR2(1)    := 'N';

l_object_type                   VARCHAR2(30)    := 'PA_DELIVERABLES';
l_function_call_done            VARCHAR2(1)     := 'N';
l_system_status_code            VARCHAR2(30)    := NULL;
l_complete_sys_status_code      VARCHAR2(30)    := 'DLVR_COMPLETED';
l_not_started_sys_status_code   VARCHAR2(30)    := 'DLVR_NOT_STARTED';
is_dlvr_actions_exists          VARCHAR2(1)     := 'N';

l_update_allowed                VARCHAR2(1)    := NULL;
l_change_allowed                VARCHAR2(1)    := NULL;
l_dlvr_prg_enabled              VARCHAR2(1)    := NULL;
l_dlvr_action_enabled           VARCHAR2(1)    := NULL;
l_dlvr_has_progress             VARCHAR2(1)    := NULL;
l_dlvr_based_assc_exists        VARCHAR2(1)    := NULL;
l_new_pev_schedule_id           NUMBER         := NULL;
l_cancel_status                 VARCHAR2(30)   := 'DLVR_ON_HOLD';
l_hold_status                   VARCHAR2(30)   := 'DLVR_CANCELLED';
l_dlvr_default_status_code      VARCHAR2(30)   := NULL;
l_ship_procure_flag_dlv         VARCHAR2(1)    := NULL;

CURSOR l_row_id_ppe_csr
IS
SELECT
         ROWID
        ,PM_SOURCE_REFERENCE
FROM
        PA_PROJ_ELEMENTS  PPE
WHERE
        PPE.PROJ_ELEMENT_ID       =   p_dlvr_item_id  AND
        PPE.PROJECT_ID            =   p_project_id    AND
        PPE.OBJECT_TYPE           =   l_object_type;

ppe_rec l_row_id_ppe_csr%ROWTYPE;

CURSOR l_row_id_pev_csr
IS
SELECT
       ROWID
FROM
       PA_PROJ_ELEMENT_VERSIONS  PEV
WHERE
       PEV.PROJ_ELEMENT_ID       =   p_dlvr_item_id        AND
       PEV.ELEMENT_VERSION_ID    =   p_dlvr_version_id     AND
       PEV.PROJECT_ID            =   p_project_id          AND
       PEV.OBJECT_TYPE           =   l_object_type;

pev_rec l_row_id_pev_csr%ROWTYPE;

CURSOR l_proj_system_status_csr
IS
SELECT
       PPS.PROJECT_SYSTEM_STATUS_CODE
FROM
       PA_PROJECT_STATUSES PPS
WHERE
       PPS.PROJECT_STATUS_CODE = p_status_code;

CURSOR l_proj_sch_ver_info_csr
IS
SELECT
       pev.pev_schedule_id,
       ROWID
FROM
       pa_proj_elem_ver_schedule pev
WHERE
      pev.proj_element_id       =   p_dlvr_item_id      AND
      pev.ELEMENT_VERSION_ID    =   p_dlvr_version_id   AND
      pev.PROJECT_ID            =   p_project_id;

pes_rec l_proj_sch_ver_info_csr%ROWTYPE;

CURSOR l_dlvr_info_csr
IS
Select
        ppe.element_number,
        ppe.name,
        ppe.description,
        ppe.status_code,
        ppe.manager_person_id,
        ppe.carrying_out_organization_id,
        ppe.record_version_number,
        ppe.parent_structure_id,
        ppe.type_id,
        ppe.progress_weight,
        ppe.base_percent_comp_deriv_code, --ppe.prog_rollup_method,
        pvs.scheduled_finish_date,
        pvs.actual_finish_date
From
    pa_proj_elements ppe,
    pa_proj_elem_ver_schedule pvs
Where
            ppe.project_id                  = p_project_id          and
            ppe.proj_element_id             = p_dlvr_item_id        and
            ppe.object_type                 = l_object_type         and
            pvs.project_id                  = p_project_id          and
            ppe.project_id                  = pvs.project_id        and
            ppe.proj_element_id             = pvs.proj_element_id;

l_dlvr_info_rec l_dlvr_info_csr%ROWTYPE;


BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
       PA_DEBUG.set_curr_function( p_function   => 'UPDATE_DELIVERABLE',
                                   p_debug_mode => l_debug_mode );
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint UPDATE_DLVR_PVT;
    END IF;

     IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Printing Input Params in UPDATE_DELIVERABLE : PADLVPVB.pls ####()',
                                        l_debug_level3);
            Pa_Debug.WRITE(g_module_name,' ####() p_project_id is '||p_project_id,
                                        l_debug_level3);
        Pa_Debug.WRITE(g_module_name,' ####()p_dlvr_item_id is '||p_dlvr_item_id,
                                        l_debug_level3);
             Pa_Debug.WRITE(g_module_name,' ###() p_dlvr_version_id is ' || p_dlvr_version_id,
                                        l_debug_level3);
             Pa_Debug.WRITE(g_module_name,' ####() p_status_code' || p_status_code,
                                        l_debug_level3);
        Pa_Debug.WRITE(g_module_name,' ####() p_dlvr_type_id ' || p_dlvr_type_id,
                                        l_debug_level3);
     END IF;

    -- Business Logic

    -- retrieve progress rollup method for task
    -- if it is deliveable_based, check progress_weight is not null

    -- 3570283 Progress Weight mandatory if deliverale is associated with deliverable based task

    -- removed the below code
    -- in case of deliverable list page, task id will be null, so the above check will fail
    -- though it should not fail

/*
    l_prog_rollup_method := PA_DELIVERABLE_UTILS.get_progress_rollup_method
                                (
                                    p_task_id          => p_task_id
                                );

    IF l_prog_rollup_method = g_deliverable_based THEN
        IF p_progress_weight IS NULL THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_DLVR_PROG_WEIGHT_MISSING');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    -- retrieve dlvr_progress_flag and enale_dlvr_action_flag for deliveable type

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.GET_DLVR_TYPE_INFO Called ',
                                    l_debug_level3);
    END IF;

    PA_DELIVERABLE_UTILS.GET_DLVR_TYPE_INFO
        (
            p_dlvr_type_id              =>  p_dlvr_type_id,
            x_dlvr_prg_enabled          =>  l_dlvr_prg_enabled,
            x_dlvr_action_enabled       =>  l_dlvr_action_enabled,
            x_dlvr_default_status_code  =>  l_dlvr_default_status_code
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of A_DELIVERABLE_UTILS.GET_DLVR_TYPE_INFO ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
        Pa_Debug.WRITE(g_module_name,' l_dlvr_prg_enabled ' || l_dlvr_prg_enabled, l_debug_level3);
    END IF;

    -- added the following code

    -- if progress is enabled, check for the deliverable, whether deliverable based task association is there or not
    -- if yes, check progress weight is entered or not

    IF l_dlvr_prg_enabled = 'Y' THEN

        l_dlvr_based_assc_exists := PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS
                                        (
                                            p_dlv_element_id => p_dlvr_item_id
                                        );

        IF l_dlvr_based_assc_exists = 'Y' THEN
            IF p_progress_weight IS NULL THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLVR_PROG_WEIGHT_MISSING');
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

    END IF;

    -- 3570283

    -- retrieving the old deliverable information

    OPEN l_dlvr_info_csr;
    FETCH l_dlvr_info_csr INTO l_dlvr_info_rec;
    CLOSE l_dlvr_info_csr;

    -- 3956982 Commented out below validation, deliverable due date change is allowed if "Ready to Ship" or
    -- "Ready to Procure" is checked

    /*

    -- if "Ready to Ship" or "Ready to Procure" is checked ( i.e. 'Y' THEN )
    -- then deliverable due date ( i.e. scheduled_finish_date ) update is not allowed
    -- add the error message and set return_status to errror
    -- To retrieve "Ready to Ship" or "Ready to Procure" statuses call
    -- PA_DELIVERABLE_UTILS.PA_DLVR_OKE_INTEGRATION and retrieve the required statuses


    IF trim(l_dlvr_info_rec.scheduled_finish_date) <> trim(p_scheduled_finish_date) THEN

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Scheduled_finish_date is changed in update dlvr',
                                        l_debug_level3);
        END IF;

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' PA_DELIVERABLE_UTILS.GET_OKE_FLAGS Called ',
                                        l_debug_level3);
        END IF;

        PA_DELIVERABLE_UTILS.GET_OKE_FLAGS
            (
                 P_PROJECT_ID                   =>  p_project_id
                ,P_DLVR_ITEM_ID                 =>  p_dlvr_item_id
                ,P_DLVR_VERSION_ID              =>  p_dlvr_version_id
                ,P_ACTION_ITEM_ID               =>  null
                ,P_ACTION_VERSION_ID            =>  null
                ,P_CALLING_MODULE               =>  l_calling_mode
                ,X_READY_TO_SHIP                =>  l_ready_to_ship
                ,X_READY_TO_PROCURE             =>  l_ready_to_procure
                ,X_PLANNING_INITIATED           =>  l_planning_initiated
                ,X_PROC_INITIATED               =>  l_proc_initiated
                ,X_ITEM_EXISTS                  =>  l_item_info_exists
                ,X_ITEM_SHIPPABLE               =>  l_item_shippable
                ,X_ITEM_BILLABLE                =>  l_item_billable
                ,X_ITEM_PURCHASABLE             =>  l_item_purchasable
                ,X_SHIPPING_INITIATED           =>  l_shipping_initiated
                ,X_SHIP_PROCURE_FLAG_DLV        =>  l_ship_procure_flag_dlv
                ,X_RETURN_STATUS                =>  l_utl_return_status
                ,X_MSG_COUNT                    =>  l_utl_msg_count
                ,X_MSG_DATA                     =>  l_utl_msg_data
            );

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Out of PA_DELIVERABLE_UTILS.GET_OKE_FLAGS ',
                                        l_debug_level3);
        END IF;

        -- set l_function_call_done to 'Y' if PA_DELIVERABLE_UTILS.PA_DLVR_OKE_INTEGRATION
        -- if l_function_call_done is set to 'Y' , the above function will not be called again
        l_function_call_done := 'Y';

        IF l_utl_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' l_ship_procure_flag_dlv ' || l_ship_procure_flag_dlv,
                                        l_debug_level3);
        END IF;

        IF l_ship_procure_flag_dlv = 'Y'  THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_DUEDATECHG_NOT_ALLOWED');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' 1st validation status ' || x_return_status,
                                    l_debug_level3);
    END IF;

    */

    -- 3956982 end

    -- retrieve project_system_status for the user entered deliverable status

    OPEN l_proj_system_status_csr;
    FETCH l_proj_system_status_csr INTO l_system_status_code;
    CLOSE l_proj_system_status_csr;


    -- 3661686 incorporated review comments
    -- moved the below two validation here

    -- 3661686 added following code to validate the following scenario
    -- if user has entered deliverable completion date and not changed status to completed
    -- error message should shown

    IF p_actual_finish_date IS NOT NULL AND l_system_status_code <> l_complete_sys_status_code THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_DLVR_STATUS_NOT_COMPLETED');
            x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- if user changes deliverable status to dlvr_completed , user must enter actual_finish_date ( i.e. completion date )
    -- if user doesn't enter completion date, set return status to error

    IF l_system_status_code = l_complete_sys_status_code AND p_actual_finish_date IS NULL THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_DLVR_COMPLT_DATE_MISSING');
            x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- if status is completed, check for the deliverable completion validations
    -- 1. document is defined or not ( if document based deliverable )
    -- 2. item information is defined or not ( if item based deliverable )
    -- 3. shipping/procurement is initiated or not
    -- 4. billing event is processed or not

    IF  l_complete_sys_status_code = l_system_status_code THEN

        PA_DELIVERABLE_UTILS.IS_DLV_STATUS_CHANGE_ALLOWED
            (
                 P_PROJECT_ID                   =>  p_project_id
                ,P_DLVR_ITEM_ID                 =>  p_dlvr_item_id
                ,P_DLVR_VERSION_ID              =>  p_dlvr_version_id
                ,P_DLV_TYPE_ID                  =>  p_dlvr_type_id
                ,P_DLVR_STATUS_CODE             =>  p_status_code
                ,x_return_status                =>  l_utl_return_status
                ,x_msg_count                    =>  l_utl_msg_count
                ,x_msg_data                     =>  l_utl_msg_data
            );

        IF l_utl_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' 3rd validation status ' || x_return_status,
                                    l_debug_level3);
    END IF;


    -- if dlvr status has changed, dlvr_progress_flag and dlvr_action_enabled_flag are set to 'Y'
    -- and deliveable has progress records does not exists
    -- deliverable status change should be the one, which is mapping to "Not Started" status
    -- if it is not mapping to "Not Started" status, set return status to error

    IF l_dlvr_info_rec.status_code <> p_status_code THEN

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' dlvr status is changed ',
                                        l_debug_level3);
        END IF;

        IF l_dlvr_prg_enabled = 'Y' THEN
        -- 3661686 commented l_dlvr_action_enabled condition ,
        -- according to latest FD, for l_dlvr_action_enabled condition should not be checked
        -- while checking for the progress record existance
--            IF l_dlvr_action_enabled = 'Y' THEN
                   l_dlvr_has_progress := PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS
                                            (
                                                p_project_id        =>  p_project_id,
                                                p_proj_element_id   =>  p_dlvr_item_id
                                            );
                   IF l_debug_mode = 'Y' THEN
                      Pa_Debug.WRITE(g_module_name,' For Deliverable progress and action is enabled ',
                                                    l_debug_level3);
                   END IF;

                   IF l_dlvr_has_progress = 'N' THEN
                        IF l_debug_mode = 'Y' THEN
                           Pa_Debug.WRITE(g_module_name,' Deliverable does not have progress records ',
                                                         l_debug_level3);
                        END IF;

                        IF l_system_status_code <> l_not_started_sys_status_code THEN
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_DLV_NOT_START_ONLY_ALLOWED');
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                   END IF;
--            END IF;
        END IF;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' 2nd validation status ' || x_return_status,
                                    l_debug_level3);
    END IF;

    -- if user changes status to 'cancelled' or 'on hold ', delivearble action functions needs to be validated
    -- call PA_DELIVERABLE_UTILS.IS_DLV_STATUS_CHANGE_ALLOWED for this validation
    -- if x_change_allowed is set to 'N', set return status to error

    IF l_dlvr_info_rec.status_code <> p_status_code THEN

          -- Bug 3499825  The following line is commented by avaithia on 02-Apr-2004
          -- The l_cancel_status / l_hold_status correspond to system statuses whereas p_system_code is the userdefined status
          --So,The following check is wrong .The  l_cancel_status / l_hold_status should be compared with l_system_status_code.

--        IF p_status_code = l_cancel_status or p_status_code = l_hold_status THEN

        IF l_system_status_code = l_cancel_status or l_system_status_code = l_hold_status THEN
            PA_DELIVERABLE_UTILS.IS_DLV_STATUS_CHANGE_ALLOWED
                (
                     P_PROJECT_ID                   =>  p_project_id
                    ,P_DLVR_ITEM_ID                 =>  p_dlvr_item_id
                    ,P_DLVR_VERSION_ID              =>  p_dlvr_version_id
                    ,P_DLV_TYPE_ID                  =>  p_dlvr_type_id
                    ,P_DLVR_STATUS_CODE             =>  p_status_code
                    ,x_return_status                =>  l_utl_return_status
                    ,x_msg_count                    =>  l_utl_msg_count
                    ,x_msg_data                     =>  l_utl_msg_data
                );

            -- 4229934 based on the return status , setting x_return_status
            IF l_utl_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- commented below code which populates error message
            -- because above api call takes care of populating it
            /*
            IF l_utl_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLV_STATUS_CHG_NOT_ALLOWED');
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            */
            -- 4229934 end
        END IF;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' 4th validation status ' || x_return_status,
                                    l_debug_level3);
    END IF;

    -- if user changes dlvr type, check wether deliverable actions for that delivearble exists or not
    -- if dlvr actions are existing, set return status to error

    IF l_dlvr_info_rec.type_id <> p_dlvr_type_id THEN
        is_dlvr_actions_exists := PA_DELIVERABLE_UTILS.IS_ACTIONS_EXISTS
                                        (
                                            p_project_id        =>  p_project_id,
                                            p_proj_element_id   =>  p_dlvr_item_id
                                        );
        IF is_dlvr_actions_exists  = 'Y' THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLVR_ACTION_EXISTS');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_dlvr_has_progress := PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS
                                    (
                                        p_project_id        =>  p_project_id,
                                        p_proj_element_id   =>  p_dlvr_item_id
                                    );

        -- if dlvr has progress and dlvr type is changes, set return status to error

        IF l_dlvr_has_progress  = 'Y' THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_DLVR_PROGRESS_EXISTS');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,'5th validation status ' || x_return_status,
                                    l_debug_level3);
    END IF;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' x_return_status ' || x_return_status,
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENTS_PKG.Update_Row Called ',
                                    l_debug_level3);
    END IF;

    -- call update_row of pa_proj_elements package

    l_element_id := p_dlvr_item_id;

    -- 3570283 added
    -- if deliverable type is changed from progress enabled one to disabled one
    -- progress weight should be set to null value

    IF l_dlvr_prg_enabled = 'Y' THEN
        l_progress_weight := p_progress_weight;
    ELSE
        l_progress_weight := NULL;
    END IF;

    -- 3570283 end

    OPEN l_row_id_ppe_csr;
    FETCH l_row_id_ppe_csr INTO ppe_rec;
    CLOSE l_row_id_ppe_csr;

    PA_PROJ_ELEMENTS_PKG.Update_Row
        (
             X_ROW_ID                           => ppe_rec.rowid
            ,X_PROJ_ELEMENT_ID                  => l_element_id
            ,X_PROJECT_ID                       => p_project_id
            ,X_OBJECT_TYPE                      => p_object_type
            ,X_ELEMENT_NUMBER                   => p_dlvr_number
            ,X_NAME                             => p_dlvr_name
            ,X_DESCRIPTION                      => p_dlvr_description
            ,X_STATUS_CODE                      => p_status_code
            ,X_WF_STATUS_CODE                   => NULL
            ,X_PM_PRODUCT_CODE                  => p_pm_source_code         /* Bug no. 3651113 -- Passed p_pm_source_code instead of null*/
            ,X_PM_TASK_REFERENCE                => p_deliverable_reference  -- 3749447 changed from NULL to retrieved value
            ,X_CLOSED_DATE                      => NULL
            ,X_LOCATION_ID                      => NULL
            ,X_MANAGER_PERSON_ID                => p_dlvr_owner_id
            ,X_CARRYING_OUT_ORGANIZATION_ID     => p_carrying_out_org_id
            ,X_TYPE_ID                          => p_dlvr_type_id
            ,X_PRIORITY_CODE                    => NULL
            ,X_INC_PROJ_PROGRESS_FLAG           => NULL
            ,X_RECORD_VERSION_NUMBER            => p_record_version_number
            ,X_REQUEST_ID                       => NULL
            ,X_PROGRAM_APPLICATION_ID           => NULL
            ,X_PROGRAM_ID                       => NULL
            ,X_PROGRAM_UPDATE_DATE              => NULL
            ,X_ATTRIBUTE_CATEGORY               => p_attribute_category
            ,X_ATTRIBUTE1                       => p_attribute1
            ,X_ATTRIBUTE2                       => p_attribute2
            ,X_ATTRIBUTE3                       => p_attribute3
            ,X_ATTRIBUTE4                       => p_attribute4
            ,X_ATTRIBUTE5                       => p_attribute5
            ,X_ATTRIBUTE6                       => p_attribute6
            ,X_ATTRIBUTE7                       => p_attribute7
            ,X_ATTRIBUTE8                       => p_attribute8
            ,X_ATTRIBUTE9                       => p_attribute9
            ,X_ATTRIBUTE10                      => p_attribute10
            ,X_ATTRIBUTE11                      => p_attribute11
            ,X_ATTRIBUTE12                      => p_attribute12
            ,X_ATTRIBUTE13                      => p_attribute13
            ,X_ATTRIBUTE14                      => p_attribute14
            ,X_ATTRIBUTE15                      => p_attribute15
            ,X_TASK_WEIGHTING_DERIV_CODE        => NULL
            ,X_WORK_ITEM_CODE                   => NULL
            ,X_UOM_CODE                         => NULL
            ,X_WQ_ACTUAL_ENTRY_CODE             => NULL
            ,X_TASK_PROGRESS_ENTRY_PAGE_ID      => NULL
            ,X_PARENT_STRUCTURE_ID              => p_parent_structure_id
            ,X_PHASE_CODE                       => NULL
            ,X_PHASE_VERSION_ID                 => NULL
            ,X_PROGRESS_WEIGHT                  => l_progress_weight  --  3570283 changed from p_progress_weight
--            ,X_PROG_ROLLUP_METHOD               => NULL
            ,X_FUNCTION_CODE                   => NULL
        );


    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENTS_PKG.Update_Row ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENT_VERSIONS_PKG.Update_Row Called ',
                                    l_debug_level3);
    END IF;

    -- call update_row of pa_proj_element_versions package

    OPEN l_row_id_pev_csr;
    FETCH l_row_id_pev_csr INTO pev_rec;
    CLOSE l_row_id_pev_csr;

    PA_PROJ_ELEMENT_VERSIONS_PKG.Update_Row
        (
             X_ROW_ID                           => pev_rec.rowid
            ,X_ELEMENT_VERSION_ID               => p_dlvr_version_id
            ,X_PROJ_ELEMENT_ID                  => p_dlvr_item_id
            ,X_OBJECT_TYPE                      => p_object_type
            ,X_PROJECT_ID                       => p_project_id
            ,X_PARENT_STRUCTURE_VERSION_ID      => p_parent_struct_ver_id
            ,X_DISPLAY_SEQUENCE                 => NULL
            ,X_WBS_LEVEL                        => NULL
            ,X_WBS_NUMBER                       => NULL
            ,X_RECORD_VERSION_NUMBER            => p_record_version_number
            ,X_ATTRIBUTE_CATEGORY               => p_attribute_category
            ,X_ATTRIBUTE1                       => p_attribute1
            ,X_ATTRIBUTE2                       => p_attribute2
            ,X_ATTRIBUTE3                       => p_attribute3
            ,X_ATTRIBUTE4                       => p_attribute4
            ,X_ATTRIBUTE5                       => p_attribute5
            ,X_ATTRIBUTE6                       => p_attribute6
            ,X_ATTRIBUTE7                       => p_attribute7
            ,X_ATTRIBUTE8                       => p_attribute8
            ,X_ATTRIBUTE9                       => p_attribute9
            ,X_ATTRIBUTE10                      => p_attribute10
            ,X_ATTRIBUTE11                      => p_attribute11
            ,X_ATTRIBUTE12                      => p_attribute12
            ,X_ATTRIBUTE13                      => p_attribute13
            ,X_ATTRIBUTE14                      => p_attribute14
            ,X_ATTRIBUTE15                      => p_attribute15
            ,X_TASK_UNPUB_VER_STATUS_CODE       => NULL
        );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENT_VERSIONS_PKG.Update_Row ',
                                    l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' PA_PROJ_ELEMENT_SCH_PKG.Update_Row Called ',
                                    l_debug_level3);
    END IF;

    -- call update_row of pa_proj_element_sch package


    OPEN l_proj_sch_ver_info_csr;
    FETCH l_proj_sch_ver_info_csr INTO pes_rec ;
    CLOSE l_proj_sch_ver_info_csr;



    PA_PROJ_ELEMENT_SCH_PKG.Update_Row
        (
             X_ROW_ID                   => pes_rec.rowid
            ,X_PEV_SCHEDULE_ID          => pes_rec.pev_schedule_id
            ,X_ELEMENT_VERSION_ID       => p_dlvr_version_id
            ,X_PROJECT_ID               => p_project_id
            ,X_PROJ_ELEMENT_ID          => p_dlvr_item_id
            ,X_SCHEDULED_START_DATE     => NULL
            ,X_SCHEDULED_FINISH_DATE    => p_scheduled_finish_date
            ,X_OBLIGATION_START_DATE    => NULL
            ,X_OBLIGATION_FINISH_DATE   => NULL
            ,X_ACTUAL_START_DATE        => NULL
            ,X_ACTUAL_FINISH_DATE       => p_actual_finish_date
            ,X_ESTIMATED_START_DATE     => NULL
            ,X_ESTIMATED_FINISH_DATE    => NULL
            ,X_DURATION                 => NULL
            ,X_EARLY_START_DATE         => NULL
            ,X_EARLY_FINISH_DATE        => NULL
            ,X_LATE_START_DATE          => NULL
            ,X_LATE_FINISH_DATE         => NULL
            ,X_CALENDAR_ID              => NULL
            ,X_MILESTONE_FLAG           => NULL
            ,X_CRITICAL_FLAG            => NULL
            ,X_WQ_PLANNED_QUANTITY      => NULL
            ,X_PLANNED_EFFORT           => NULL
            ,X_ACTUAL_DURATION          => NULL
            ,X_ESTIMATED_DURATION       => NULL
            ,X_RECORD_VERSION_NUMBER    => p_record_version_number
            ,X_ATTRIBUTE_CATEGORY       => p_attribute_category
            ,X_ATTRIBUTE1               => p_attribute1
            ,X_ATTRIBUTE2               => p_attribute2
            ,X_ATTRIBUTE3               => p_attribute3
            ,X_ATTRIBUTE4               => p_attribute4
            ,X_ATTRIBUTE5               => p_attribute5
            ,X_ATTRIBUTE6               => p_attribute6
            ,X_ATTRIBUTE7               => p_attribute7
            ,X_ATTRIBUTE8               => p_attribute8
            ,X_ATTRIBUTE9               => p_attribute9
            ,X_ATTRIBUTE10              => p_attribute10
            ,X_ATTRIBUTE11              => p_attribute11
            ,X_ATTRIBUTE12              => p_attribute12
            ,X_ATTRIBUTE13              => p_attribute13
            ,X_ATTRIBUTE14              => p_attribute14
            ,X_ATTRIBUTE15              => p_attribute15
    );

    IF l_debug_mode = 'Y' THEN
       Pa_Debug.WRITE(g_module_name,' Out of PA_PROJ_ELEMENT_SCH_PKG.Update_Row ',
                                    l_debug_level3);
    END IF;

    -- if deliverable type is changed , copy the actions of that deliverable type
    -- to that deliverable

    -- 3749447 in amg flow, if deliverable type is changed, defaulting of actions should not
    -- be done from deliverabel type

    IF p_calling_module <> 'AMG' AND l_dlvr_info_rec.type_id <> p_dlvr_type_id THEN

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' PA_ACTIONS_PUB.COPY_ACTIONS Called ',
                                        l_debug_level3);
        END IF;

        PA_ACTIONS_PUB.COPY_ACTIONS
            (
                p_init_msg_list                 => p_init_msg_list
               ,p_commit                        => p_commit
               ,p_debug_mode                    => l_debug_mode
               ,p_source_object_id              => p_dlvr_type_id
               ,p_source_object_type            => 'PA_DLVR_TYPES'
               ,p_target_object_id              => p_dlvr_item_id
               ,p_target_object_type            => 'PA_DELIVERABLES'
               ,p_source_project_id             => null
               ,p_target_project_id             => p_project_id
               ,p_task_id                       => p_task_id
               ,p_task_ver_id                   => p_task_version_id
               ,p_carrying_out_organization_id  => p_carrying_out_org_id
               ,p_pm_source_reference           => null
               ,p_pm_source_code                => null
               ,p_calling_mode                  => 'UPDATE' -- Added for bug 3911050
               ,x_return_status                 => x_return_status
               ,x_msg_count                     => x_msg_count
               ,x_msg_data                      => x_msg_data
            ) ;

        IF l_debug_mode = 'Y' THEN
           Pa_Debug.WRITE(g_module_name,' Out of PA_ACTIONS_PUB.COPY_ACTIONS ',
                                        l_debug_level3);
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- 3749447 added call to create deliverable to task association if task id is passed, in amg flow
    -- if task to deliverable association is already there, do nothing
    -- else create task to deliverable association

    IF p_calling_module = 'AMG' AND p_task_id IS NOT NULL THEN

        PA_DELIVERABLE_PVT.CREATE_DLV_TASK_ASSOCIATION
            (     p_debug_mode              =>      l_debug_mode
                 ,p_task_element_id         =>      p_task_id
                 ,p_task_version_id         =>      p_task_version_id
                 ,p_dlv_element_id          =>      p_dlvr_item_id
                 ,p_dlv_version_id          =>      p_dlvr_version_id
                 ,p_project_id              =>      p_project_id
                 ,x_return_status           =>      x_return_status
                 ,x_msg_count               =>      x_msg_count
                 ,x_msg_data                =>      x_msg_data
            );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF l_row_id_ppe_csr%ISOPEN THEN
          CLOSE l_row_id_ppe_csr;
     END IF;

     IF l_row_id_pev_csr%ISOPEN THEN
          CLOSE l_row_id_pev_csr;
     END IF;

     IF l_proj_system_status_csr%ISOPEN THEN
          CLOSE l_proj_system_status_csr;
     END IF;

     IF l_proj_sch_ver_info_csr%ISOPEN THEN
          CLOSE l_proj_sch_ver_info_csr;
     END IF;

     IF l_dlvr_info_csr%ISOPEN THEN
          CLOSE l_dlvr_info_csr;
     END IF;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO UPDATE_DLVR_PVT;
     END IF;

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
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF l_row_id_ppe_csr%ISOPEN THEN
          CLOSE l_row_id_ppe_csr;
     END IF;

     IF l_row_id_pev_csr%ISOPEN THEN
          CLOSE l_row_id_pev_csr;
     END IF;

     IF l_proj_system_status_csr%ISOPEN THEN
          CLOSE l_proj_system_status_csr;
     END IF;

     IF l_proj_sch_ver_info_csr%ISOPEN THEN
          CLOSE l_proj_sch_ver_info_csr;
     END IF;

     IF l_dlvr_info_csr%ISOPEN THEN
          CLOSE l_dlvr_info_csr;
     END IF;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO UPDATE_DLVR_PVT;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_DELIVERABLE_PVT'
                    , p_procedure_name  => 'Update_Deliverable'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Update_Deliverable;

-- SubProgram           : delete_deliverable
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Task - Deliverable Association
-- Note                 : Public API called from Task Detail and Deliverable Details Page
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_dlv_element_id                IN          NUMBER            N        Deliverable Element Id
-- p_dlv_version_id                IN          NUMBER            N        Deliverbale Version Id
-- p_rec_ver_number                IN          NUMBER            N        Record Version Number
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter


PROCEDURE delete_deliverable
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
     ,p_rec_ver_number      IN pa_proj_elements.record_version_number%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_disassociation_allowed     VARCHAR2(1);
     l_dummy                      VARCHAR2(1);
     l_action_element_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
     l_action_version_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
     l_dlv_rec                    oke_amg_grp.dlv_rec_type;
     l_item_dlv                   VARCHAR2(1) := NULL;
     i                            NUMBER;

     -- 3733321 added local variables

     l_master_inv_org_id         PA_PLAN_RES_DEFAULTS.item_master_id%TYPE;
     l_return_status             VARCHAR2(1);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLE',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DELIVERABLE ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Printing Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.write(g_module_name,'p_dlv_element_id  '||':'||p_dlv_element_id,3) ;
          pa_debug.write(g_module_name,'p_dlv_version_id'||':'||p_dlv_version_id,3) ;
          pa_debug.write(g_module_name,'p_project_id'||':'||p_project_id,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_DELIVERABLE_SP ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (  p_dlv_element_id IS NULL OR p_dlv_version_id IS NULL )
     THEN
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                             ,p_msg_name         => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF;

     -- Lock the record before performing deletion
     BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENTS
        where proj_element_id = p_dlv_element_id
        and record_version_number = decode(p_calling_module, 'AMG', record_version_number,p_rec_ver_number)
    for update of record_version_number NOWAIT;
     EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
        WHEN NO_DATA_FOUND THEN
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          ELSE
            raise;
          END IF ;
     END ;

     -- If locking is not successfull then
     -- its not worth going for further validation .
     IF l_msg_data IS NOT NULL THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                              ,p_msg_name       => l_msg_data) ;
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;


     IF nvl(PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(p_project_id,p_dlv_element_id),'N') = 'Y' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE('PA','PA_DLV_PROGRESS_NO_DLTN') ;
     END IF ;

    -- 3555460 added validation for checking shipping action is initiated or not
    -- if shipping is initiated, show error message for shipping initiation
    -- else check for ready to ship flags for shipping action
    -- if ready to ship flag is set for shipping action, throw error message for ready to ship

     IF nvl(PA_DELIVERABLE_UTILS.IS_SHIPPING_INITIATED(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DEL_DLVR_SHIP_INIT_ERR') ;
     ELSE
         IF nvl(PA_DELIVERABLE_UTILS.GET_READY_TO_SHIP_FLAG(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DLV_SHIP_ACTION_NO_DLTN') ;
         END IF ;
     END IF;

    -- 3555460 added validation for checking procurement action is initiated or not
    -- if procurement is initiated, show error message for procurement initiation
    -- else check for ready to procure flags for procurement action
    -- if ready to ship flag is set for procurement action, throw error message for ready to procure


     IF nvl(PA_DELIVERABLE_UTILS.IS_PROCUREMENT_INITIATED(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DEL_DLVR_PROC_INIT_ERR') ;
     ELSE
         IF nvl(PA_DELIVERABLE_UTILS.GET_READY_TO_PROC_FLAG(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DLV_PROC_ACTION_NO_DLTN') ;
         END IF ;
     END IF;

    -- 3555460 added validation for checking billing event processed
    -- if billing function exists,
    --    if billing event is processed, show error message for billing event process
    --    else show error message for billing function exists
    -- end if

     IF nvl(PA_DELIVERABLE_UTILS.IS_BILLING_FUNCTION_EXISTS(p_project_id,p_dlv_element_id),'N') = 'Y' THEN
          IF nvl(PA_DELIVERABLE_UTILS.IS_BILLING_EVENT_PROCESSED(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DEL_DLVR_BILL_PROC_ERR') ;
          ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
              PA_UTILS.ADD_MESSAGE('PA','PA_DLV_BILLING_FUNC_NO_DLTN') ;
          END IF;
     END IF ;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- 3733321 Added code to retrieve deliverable deliverable type

     IF (p_calling_module = 'AMG') THEN

         SELECT Pa_Deliverable_Utils.IS_Dlvr_Item_Based(element_version_id)
         INTO   l_item_dlv
         FROM   Pa_Proj_Element_Versions
         WHERE  proj_element_id = p_dlv_element_id
         AND    project_id   = p_project_id;

     END IF;

     --Here we are deleting the TASK TO DELIVERABLE Relationship
     DELETE FROM PA_OBJECT_RELATIONSHIPS
            WHERE OBJECT_ID_TO2 = p_dlv_element_id
          AND object_type_from = 'PA_TASKS'               /* Included these 4 additional Clauses for Performance Bug # 3614361*/
          AND object_type_to = 'PA_DELIVERABLES'
          AND relationship_type = 'A'
          AND RELATIONSHIP_SUBTYPE ='TASK_TO_DELIVERABLE';

     -- 3946997 Added code to delete task assingment to deliverable association

     DELETE FROM PA_OBJECT_RELATIONSHIPS
            WHERE OBJECT_ID_TO2     = p_dlv_element_id
          AND object_type_from      = 'PA_ASSIGNMENTS'
          AND object_type_to        = 'PA_DELIVERABLES'
          AND relationship_type     = 'A'
          AND RELATIONSHIP_SUBTYPE  ='ASSIGNMENT_TO_DELIVERABLE';

     -- 3946997 end

     -- 3749451 added below code to delete structure to deliverable association , when deliverable is deleted
     DELETE FROM PA_OBJECT_RELATIONSHIPS
            WHERE OBJECT_ID_TO2 = p_dlv_element_id
          AND object_type_from = 'PA_STRUCTURES'
          AND object_type_to = 'PA_DELIVERABLES'
          AND relationship_type = 'S'
          AND RELATIONSHIP_SUBTYPE ='STRUCTURE_TO_DELIVERABLE';

     --The following delete Statements remove the deliverable details
     DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
            WHERE ELEMENT_VERSION_ID  = p_dlv_version_id ;

     DELETE FROM PA_PROJ_ELEMENT_VERSIONS
            WHERE ELEMENT_VERSION_ID  = p_dlv_version_id ;

     DELETE FROM PA_PROJ_ELEMENTS
            WHERE PROJ_ELEMENT_ID  = p_dlv_element_id ;

     IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name,' After deleting records from Project table, deleting OKE records['||x_return_status||']', 3);
     END IF;

     --Start Bug 3538320 <<Included by avaithia on 29-Mar-2004>>
     --Delete the Attachment records of the deliverable

     IF nvl(PA_DELIVERABLE_UTILS.IS_DLV_DOC_DEFINED(p_dlv_element_id,p_dlv_version_id),'N')='Y' THEN
          fnd_attached_documents2_pkg.delete_attachments
               (X_entity_name             => 'PA_DLVR_DOC_ATTACH',
                X_pk1_value               => to_char(p_dlv_version_id),
                X_delete_document_flag    => 'Y');

     END IF ;

      fnd_attached_documents2_pkg.delete_attachments
               (X_entity_name             => 'PA_DVLR_ATTACH',
                X_pk1_value               => to_char(p_dlv_version_id),
                X_delete_document_flag    => 'Y');

     --End Bug 3538320

     --Start Bug 3431156
     -- delete the deliverable from OKE table
     IF (p_calling_module = 'AMG') THEN

       -- 3733321 added code to retrieve master inventory org id

       PA_RESOURCE_UTILS1.Return_Material_Class_Id
                                (
                                     x_material_class_id     =>  l_master_inv_org_id
                                    ,x_return_status         =>  l_return_status
                                    ,x_msg_data              =>  l_msg_data
                                    ,x_msg_count             =>  l_msg_count
                                );

        -- 3733321 changed from p_dlv_element_id to p_dlv_version_id
        -- because oke expects deliverable version id

        l_dlv_rec.pa_deliverable_id    :=    p_dlv_version_id  ;
        l_dlv_rec.project_id           :=    p_project_id      ;

        -- 3733321 passing l_item_dlv as p_item_dlv , earlier it was passed as null
        -- passing l_master_inv_org_id as p_master_inv_org_id , earlier it was passed as 0

        oke_amg_grp.manage_dlv
          (   p_api_version          =>  p_api_version
            , p_init_msg_list        =>  p_init_msg_list
            , p_commit               =>  FND_API.G_FALSE
            , p_action               =>  'DELETE'
            , p_item_dlv             =>  l_item_dlv
            , p_master_inv_org_id    =>  l_master_inv_org_id
            , p_dlv_rec              =>  l_dlv_rec
            , x_return_status        =>  x_return_status
            , x_msg_data             =>  x_msg_data
            , x_msg_count            =>  x_msg_count
        );

     ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        OKE_DELIVERABLE_UTILS_PUB.DELETE_DELIVERABLE
                  ( P_DELIVERABLE_ID => p_dlv_version_id
                   , X_Return_Status => x_return_status
                   , X_Msg_Count     => x_msg_count
                   , X_Msg_Data      => x_msg_data
                   ) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
         Pa_Debug.WRITE(g_module_name,' Returned from oke_amg_grp.manage_dlv['||x_return_status||']', 3);
     END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR      THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- delete the deliverable actions which are associated with this deliverable
     -- and delete the action's association with the deliverable

     --Included on 12-Feb-2004 by avaithia <<Start>>

     DELETE FROM PA_OBJECT_RELATIONSHIPS
           WHERE OBJECT_ID_FROM2 = p_dlv_element_id
     RETURNING object_id_to2,object_id_to1
          BULK COLLECT INTO l_action_element_id_tbl,l_action_version_id_tbl;

      --The nvl check has been included by avaithia on 29-Mar-2004
      IF  nvl(l_action_element_id_tbl.LAST,0) > 0 THEN
           FORALL i IN l_action_element_id_tbl.FIRST..l_action_element_id_tbl.LAST
                DELETE FROM PA_PROJ_ELEMENTS
                      WHERE PROJ_ELEMENT_ID = l_action_element_id_tbl(i);

           FORALL i IN l_action_version_id_tbl.FIRST..l_action_version_id_tbl.LAST
                DELETE FROM PA_PROJ_ELEMENT_VERSIONS
                      WHERE ELEMENT_VERSION_ID  = l_action_version_id_tbl(i) ;


           FORALL i IN l_action_version_id_tbl.FIRST..l_action_version_id_tbl.LAST
                DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
                      WHERE ELEMENT_VERSION_ID = l_action_version_id_tbl(i) ;
      END IF ;

     --<<End>>Included on 12-Feb-2004 by avaithia

     --End Bug 3431156

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DELIVERABLE' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_DELIVERABLE_SP;
     END IF;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DELIVERABLE';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_FALSE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;

WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_DELIVERABLE_SP;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
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

     IF l_debug_mode = 'Y' THEN
          pa_debug.write( g_module_name,'DELETE_DELIVERABLE: G_EXC_ERROR msg_count' ||l_msg_count ,5);
          Pa_Debug.reset_curr_function;
     END IF;

WHEN OTHERS THEN
     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_DELIVERABLE_SP;
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                     ,p_procedure_name  => 'DELETE_DELIVERABLE');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DELIVERABLE: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END delete_deliverable ;

-- SubProgram           : DELETE_DLV_TASK_ASSOCIATION
-- Type                 : PROCEDURE
-- Purpose              : Private API to Delete Task - Deliverable Association
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_task_element_id               IN          NUMBER            N        Task Element Id
-- p_task_version_id               IN          NUMBER            N        Task Version Id
-- p_dlv_element_id                IN          NUMBER            N        Deliverable Element Id
-- p_dlv_version_id                IN          NUMBER            N        Deliverable Version Id
-- p_object_relationship_id        IN          NUMBER            N        Object Relationship Id
-- p_obj_rec_ver_number            IN          NUMBER            N        Record Version NUmber
-- p_calling_context               IN          VARCHAR2          Y        Calling Context - TASKS Or DELIVERABLES
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE DELETE_DLV_TASK_ASSOCIATION
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
     ,p_object_relationship_id IN pa_object_relationships.object_relationship_id%TYPE
     ,p_obj_rec_ver_number  IN pa_object_relationships.record_version_number%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_calling_context     IN VARCHAR2                                                -- Bug 3555460
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_disassociation_allowed     VARCHAR2(1) := 'Y' ;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_TASK_ASSOCIATION',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DEL_DLV_TASK_ASSOCIATION_SP ;
     END IF;

     -- 3888280 start
     -- added existing code in new if condition , which checks for calling context
     -- IS_DISASSOCIATION_ALLOWED should not be called for deleting TA to DLVR association
     -- Calling above api if calling context is not TASK_ASSIGNMENT

     IF p_calling_context <> 'TASK_ASSIGNMENT' THEN

     -- Not doing any explicit locking as it is taken care
     -- by PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW

      -- Call VALIDATE_DISASSOCIATION_ALLOWED to check whether
      -- disassociation is allowed or not. This API will also
      -- populate the error stack with proper error message if
      -- disassociation is not allowed .

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Call IS_DISASSOCIATION_ALLOWED ';
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
         END IF ;

         PA_DELIVERABLE_PVT.IS_DISASSOCIATION_ALLOWED
               (p_api_version             => p_api_version
               ,p_init_msg_list           => FND_API.G_FALSE
               ,p_commit                  => p_commit
               ,p_validate_only           => p_validate_only
               ,p_validation_level        => p_validation_level
               ,p_calling_module          => p_calling_module
               ,p_debug_mode              => p_debug_mode
               ,p_max_msg_count           => p_max_msg_count
               ,p_task_element_id         => p_task_element_id
               ,p_task_version_id         => p_task_version_id
               ,p_dlv_element_id          => p_dlv_element_id
               ,p_dlv_version_id          => p_dlv_version_id
               ,p_project_id              => p_project_id
               ,p_calling_context         => p_calling_context  -- Bug 3555460
               ,x_disassociation_allowed  => l_disassociation_allowed
               ,x_return_status           => x_return_status
               ,x_msg_count               => x_msg_count
               ,x_msg_data                => x_msg_data
               ) ;

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'l_disassociation_allowed is'||l_disassociation_allowed;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
         END IF ;

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'x_return_status is'|| x_return_status;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
         END IF ;


         IF (nvl(l_disassociation_allowed,'Y') = 'N' OR x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
              RAISE Invalid_Arg_Exc_Dlv ;
         END IF ;
     ELSE

         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= ' No Validation Required For TA To Dlvr Deletion ' ;
              pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
         END IF ;

     END IF;

     -- 3888280 end

      PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW
          ( p_object_relationship_id => p_object_relationship_id
           ,p_object_type_from       => NULL
           ,p_object_id_from1        => NULL
           ,p_object_id_from2        => NULL
           ,p_object_id_from3        => NULL
           ,p_object_id_from4        => NULL
           ,p_object_id_from5        => NULL
           ,p_object_type_to         => NULL
           ,p_object_id_to1          => NULL
           ,p_object_id_to2          => NULL
           ,p_object_id_to3          => NULL
           ,p_object_id_to4          => NULL
           ,p_object_id_to5          => NULL
           ,p_record_version_number  => p_obj_rec_ver_number
           ,p_pm_product_code        => NULL
           ,x_return_status          => x_return_status
         );

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'x_return_status is'|| x_return_status;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_TASK_ASSOCIATION' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DEL_DLV_TASK_ASSOCIATION_SP;
     END IF ;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_TASK_ASSOCIATION';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO DEL_DLV_TASK_ASSOCIATION_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                     ,p_procedure_name  => 'DELETE_DLV_TASK_ASSOCIATION');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_TASK_ASSOCIATION: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_TASK_ASSOCIATION ;

-- SubProgram           : IS_DISASSOCIATION_ALLOWED
-- Type                 : PROCEDURE
-- Purpose              : This API will check whether disassociation is allowed
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- --------------------------   ---------    ----------      ---------    ------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_task_element_id               IN          NUMBER            N        Task Element Id
-- p_task_version_id               IN          NUMBER            N        Task Version Id
-- p_dlv_element_id                IN          NUMBER            N        Deliverable Element Id
-- p_dlv_version_id                IN          NUMBER            N        Deliverable Version Id
-- p_project_id                    IN          NUMBER            N        Project Id
-- p_calling_context               IN          VARCHAR2          Y        Calling Context -TASKS Or DELIVERABLES
-- x_disassociation_allowed        OUT         VARCHAR2
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE IS_DISASSOCIATION_ALLOWED
           (p_api_version         IN NUMBER   :=1.0
           ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
           ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
           ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
           ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
           ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
           ,p_debug_mode          IN VARCHAR2 :='N'
           ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
           ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
           ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
           ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
           ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
           ,p_project_id          IN pa_projects_all.project_id%TYPE
           ,p_calling_context     IN VARCHAR2                                         -- Bug 3555460
           ,x_disassociation_allowed OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           )
IS
BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'IS_DISASSOCIATION_ALLOWED',
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside IS_DISASSOCIATION_ALLOWED ,Calling Context is ' || p_calling_context;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;


     IF p_task_element_id IS NOT NULL THEN
          IF nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_element_id),'X') = g_deliverable_based THEN

       --   Bug 3651781 While deleting association between a deliverable based task and a deliverable ,we have to
       --   Look for 'PUBLISHED' progress records ,NOT mere existence of progress records

       --     IF nvl(PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(p_project_id,p_dlv_element_id),'N') = 'Y' THEN
            IF nvl(PA_PROGRESS_UTILS.published_dlv_prog_exists(p_project_id,p_dlv_element_id),'N') = 'Y' THEN
               IF p_calling_context = 'TASKS' THEN                            -- Bug 3555460 Calling context newly introduced
                    PA_UTILS.ADD_MESSAGE('PA','PA_TASK_PROGRESS_NO_DISASCN') ;
               ELSIF p_calling_context = 'DELIVERABLES' THEN
                     PA_UTILS.ADD_MESSAGE('PA','PA_DLV_PROGRESS_NO_DISASCN') ;
               END IF ;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_disassociation_allowed := 'N';
            END IF ;
          END IF ;
     END IF ;

     --Bug 3555460 While deleting a task to deliverable association,Only check that has to be made is
     --If the workplan task is deliverable based, and deliverable associated to the task has progress records
     --So,Rest of the validations need to be commented out .
     /*IF nvl(PA_DELIVERABLE_UTILS.GET_READY_TO_SHIP_FLAG(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_DLV_SHIP_ACTION_NO_DISASCN') ;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_disassociation_allowed := 'N';
     END IF ;

     IF nvl(PA_DELIVERABLE_UTILS.GET_READY_TO_PROC_FLAG(p_dlv_element_id,p_dlv_version_id),'N') = 'Y' THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_DLV_PROC_ACTION_NO_DISASCN') ;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_disassociation_allowed := 'N';
     END IF ;

     IF nvl(PA_DELIVERABLE_UTILS.IS_BILLING_FUNCTION_EXISTS(p_project_id,p_dlv_element_id),'N') = 'Y' THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_DLV_BILLING_FUNC_NO_DISASCN') ;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_disassociation_allowed := 'N';
     END IF ;*/

     IF p_debug_mode = 'Y' THEN       --Added for bug 4945876
       pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PUB'
                     ,p_procedure_name  => 'IS_DISASSOCIATION_ALLOWED');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('IS_DISASSOCIATION_ALLOWED: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END IS_DISASSOCIATION_ALLOWED;

-- SubProgram           : CREATE_ASSOCIATIONS_IN_BULK
-- Type                 : PROCEDURE
-- Purpose              : Private API to Create associations
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_element_id_tbl                IN          PLSQL Table       N        PLSQL table of Dlv Element Id
-- p_version_id_tbl                IN          PLSQL Table       N        PLSQL table of Dlv Version Id
-- p_element_name_tbl              IN          PLSQL Table       N        PLSQL Table of Dlv. Name
-- p_element_number_tbl            IN          PLSQL Table       N        PLSQL Table of Dlv. Number
-- p_task_or_dlv_elt_id            IN          NUMBER            Y        Task or deliverable element id
-- p_task_or_dlv_elt_id            IN          NUMBER            Y        Task or deliverable version id
-- p_project_id                    IN          NUMBER            N        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE CREATE_ASSOCIATIONS_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_element_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_version_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_element_name_tbl    IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_number_tbl  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_task_or_dlv_elt_id  IN NUMBER
     ,p_task_or_dlv_ver_id  IN NUMBER
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_task_or_dlv         IN VARCHAR2 := 'PA_TASKS'
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_msg_count              NUMBER ;
     l_data                   VARCHAR2(2000);
     l_msg_data               VARCHAR2(2000);
     l_msg_index_out          NUMBER;
     l_err_message            fnd_new_messages.message_text%TYPE  ;
     l_prog_enabled_dlv_count NUMBER ;
     l_dlv_based_task_count NUMBER ;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_ASSOCIATIONS_IN_BULK'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_ASSOCIATIONS_IN_BULK ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     -- Perform following validation

     -- This is required when coming from Associate Deliverables Page
     -- 1.  If task is is deliverable based then
     --   1.1  If deliverable is associated to Deliverable Based Task Then
     --        ASSOCIATION IS NOT POSSIBLE

     -- This is required when coming from Associate Tasks Page
     -- 2.  If deliverable is attached to deliverable based task then
     --      1.1.1  If tas kis deliverable based then
     --             ASSOCIATION IS NOT POSSIBLE
     -- 3. else
     --      1.2.1  If multiple Deliverables task is selected then
     --             ASSOCIATION IS NOT POSSIBLE
     -- Following validation has to be performed from ASSOCIATE TASK
     -- page as well as ASSOCIATE DELIVERABLE page

     IF p_task_or_dlv = 'PA_TASKS' THEN

          IF nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_or_dlv_elt_id),'X') = g_deliverable_based THEN
                    -- Initialize the error message beforehand so as to avoid unnecessary
                    -- call of FND_MESSAGE.GET_STRING API again and again in LOOP
                    l_err_message := FND_MESSAGE.GET_STRING('PA','PA_DLV_ASSCN_ERR') ;
                    IF nvl(p_element_id_tbl.LAST,0)>0 THEN
                          --3614361 Explicitly mentioned param name
                         FOR i in p_element_id_tbl.FIRST..p_element_id_tbl.LAST LOOP
                             IF nvl(PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(p_dlv_element_id => p_element_id_tbl(i)),'X') = 'Y' THEN
                                 PA_UTILS.ADD_MESSAGE
                                      (p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_PS_TASK_NAME_NUM_ERR',
                                       p_token1         => 'TASK_NAME',
                                       p_value1         =>  p_element_name_tbl(i),
                                       p_token2         => 'TASK_NUMBER',
                                       p_value2         =>  p_element_number_tbl(i),
                                       p_token3         => 'MESSAGE',
                                       p_value3         =>  l_err_message
                                       );

                             END IF ;
                         END LOOP ;
                    END IF ;
          END IF ;
     ELSE -- p_task_or_dlv = 'TASKS'
        --3614361 Explicitly mentioned param name
          IF nvl(PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(p_dlv_element_id=>p_task_or_dlv_elt_id),'X') = 'Y' THEN

              -- Initialize the error message beforehand so as to avoid unnecessary
              -- call of FND_MESSAGE.GET_STRING API again and again in LOOP
              l_err_message := FND_MESSAGE.GET_STRING('PA','PA_TASK_ASSCN_ERR') ;

              IF nvl(p_element_id_tbl.LAST,0) > 0 THEN
                   FOR i in p_element_id_tbl.FIRST..p_element_id_tbl.LAST LOOP
                       IF nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_element_id_tbl(i)),'X') = g_deliverable_based THEN
                           PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_PS_TASK_NAME_NUM_ERR',
                                 p_token1         => 'TASK_NAME',
                                 p_value1         =>  p_element_name_tbl(i),
                                 p_token2         => 'TASK_NUMBER',
                                 p_value2         =>  p_element_number_tbl(i),
                                 p_token3         => 'MESSAGE',
                                 p_value3         =>  l_err_message
                                 );

                       END IF ;
                   END LOOP ;
              END IF ;
          ELSE
              IF nvl(p_element_id_tbl.LAST,0)>0 THEN
                   l_prog_enabled_dlv_count := 0 ;
                   FOR i in p_element_id_tbl.FIRST..p_element_id_tbl.LAST LOOP
                       IF nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_element_id_tbl(i)),'X') = g_deliverable_based THEN
                           -- 3625019 changed variable , initialization was done one l_prog_enabled_dlv_count and
                           -- variable value increment is done on l_dlv_based_task_count and if condition checking is done on l_prog_enabled_dlv_count
                           -- IF l_prog_enabled_dlv_count > 1 THEN condition will always fail
                           l_prog_enabled_dlv_count := l_prog_enabled_dlv_count+1 ;
                       END IF ;
                       IF l_prog_enabled_dlv_count > 1 THEN
                            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                                                ,p_msg_name         => 'PA_MULTI_TASK_ASSCN_ERR');
                            EXIT ;
                       END IF ;
                   END LOOP ;
              END IF ;
          END IF ;
     END IF ;

     x_msg_count := FND_MSG_PUB.count_msg ;

     IF x_msg_count > 0 THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     FORALL i in p_element_id_tbl.FIRST..p_element_id_tbl.LAST
          INSERT INTO PA_OBJECT_RELATIONSHIPS (
                 object_relationship_id
                ,object_type_from
                ,object_id_from1
                ,object_type_to
                ,object_id_to1
                ,relationship_type
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date
                ,object_id_from2
                ,object_id_to2
                ,relationship_subtype
                ,record_version_number
                ,last_update_login
              )
            VALUES
              (
                pa_object_relationships_s.nextval
               ,'PA_TASKS'
               ,decode(p_task_or_dlv,'PA_TASKS',p_task_or_dlv_ver_id,p_version_id_tbl(i))
               ,'PA_DELIVERABLES'
               ,decode(p_task_or_dlv,'PA_TASKS',p_version_id_tbl(i),p_task_or_dlv_ver_id)
               ,'A'
               ,fnd_global.user_id
               ,SYSDATE
               ,fnd_global.user_id
               ,SYSDATE
               ,decode(p_task_or_dlv,'PA_TASKS',p_task_or_dlv_elt_id,p_element_id_tbl(i))
               ,decode(p_task_or_dlv,'PA_TASKS',p_element_id_tbl(i),p_task_or_dlv_elt_id)
               ,'TASK_TO_DELIVERABLE'
               ,1
               ,fnd_global.login_id
              ) ;


    IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
    END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CREATE_ASSOCIATIONS_IN_BULK';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_DELIVERABLE_PVT'
              ,p_procedure_name => 'CREATE_ASSOCIATIONS_IN_BULK' );
     IF p_debug_mode = 'Y' THEN
             pa_debug.write('CREATE_ASSOCIATIONS_IN_BULK' || g_module_name,SQLERRM,4);
             pa_debug.write('CREATE_ASSOCIATIONS_IN_BULK' || g_module_name,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
     END IF;
     RAISE ;
END CREATE_ASSOCIATIONS_IN_BULK ;


-- SubProgram           : CREATE_DLV_TASK_ASSOCIATION
-- Type                 : PROCEDURE
-- Purpose              : Private API to Create association between task and a deliverable
-- Note                 :
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_task_element_id               IN          NUMBER            Y        Task Element Id
-- p_task_version_id               IN          NUMBER            Y        Task Version Id
-- p_dlv_element_id                IN          NUMBER            Y        Deliverable Element Id
-- p_dlv_version_id                IN          NUMBER            Y        Deliverable Version Id
-- p_project_id                    IN          NUMBER            Y        Project Id
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter

PROCEDURE CREATE_DLV_TASK_ASSOCIATION
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_calling_context     IN VARCHAR2 := 'PA_TASKS'
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;

    -- 3651542 added below cursor and local variables

    CURSOR  c_dlvr_task_assgnt_asscn IS
    SELECT  obj.object_relationship_id
    FROM    PA_OBJECT_RELATIONSHIPS obj
    WHERE   OBJ.object_id_from2 = p_task_element_id
    AND     OBJ.object_id_to2 = p_dlv_element_id
    AND     OBJ.object_type_to = 'PA_DELIVERABLES'
    AND     OBJ.object_type_from = 'PA_ASSIGNMENTS'
    AND     OBJ.relationship_type = 'A'
    AND     OBJ.relationship_subtype = 'ASSIGNMENT_TO_DELIVERABLE';

    l_dummy          pa_object_relationships.object_relationship_Id%TYPE;

    is_asscn_exists       VARCHAR2(1) := 'N';

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_DLV_TASK_ASSOCIATION'
                                     ,p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside CREATE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
          SAVEPOINT CREATE_DLV_TASK_ASSOCIATION_SP ;
     END IF ;

    IF ((p_task_element_id IS NULL )OR --p_task_version_id IS NULL) OR
     (p_dlv_element_id IS NULL OR p_dlv_version_id IS NULL ))
     THEN
         IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'INVALID INPUT PARAMETER';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                              ,p_msg_name         => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_Dlv;
     END IF ;

     -- Perform following validation before creating association
     -- 1. If Deliverable is associated to deliverable based task then
     --    1.1 If Task is Deliverable based then
     --         ASSOCIATION IS NOT ALLOWED
 -- 3614361 Explicitly mentioned param names

    IF nvl(PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(p_dlv_element_id => p_dlv_element_id,p_dlv_version_id => p_dlv_version_id),'X') = 'Y'
     THEN
          IF nvl(PA_DELIVERABLE_UTILS.GET_PROGRESS_ROLLUP_METHOD(p_task_element_id),'X') = g_deliverable_based  THEN
                         PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                                             ,p_msg_name        => 'PA_DLV_ASSCN_ERR');
                         x_return_status :=  FND_API.G_RET_STS_ERROR;
          END IF ;
     END IF ;

     IF x_return_status <>FND_API.G_RET_STS_SUCCESS
     THEN
           RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     IF p_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Populating PA_OBJECT_RELATIONSHIPS';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

    -- 3651542 added below call to check whether task assignment to deliverable relation ship is
    -- existing or not
    -- check for calling module and calling context, if it is AMG and PA_ASSIGNMENTS resp,
    -- if c_dlvr_task_assgnt_asscn returns record, set is_asscn_exists lag to 'Y'

    IF p_calling_module = 'AMG' AND p_calling_context = 'PA_ASSIGNMENTS' THEN
       OPEN c_dlvr_task_assgnt_asscn;
       FETCH c_dlvr_task_assgnt_asscn into l_dummy ;
       IF c_dlvr_task_assgnt_asscn%FOUND THEN
            is_asscn_exists := 'Y';
       END IF;
       CLOSE c_dlvr_task_assgnt_asscn;
    END IF;

    -- 3651542 below if condition was used for checking task to deliverable asscn
    -- if it is there , do not create new association
    -- Moved that condition as separate code and setting is_asscn_exists flag to 'Y' if asscn is existing

    -- here GET_DLVR_TASK_ASSCN_ID returns object relationship id of the relationship
    -- if it is null, i.e. relationship is not existing, is_asscn_exists will be 'N'
    -- if it is not null, relationship is existing, and set is_asscn_exists to 'Y'

    -- 3651542 check association existance both in AMG and SS, removed p_calling_module = 'AMG' condition
    -- from below if

--    IF ( p_calling_module = 'AMG' AND p_calling_context = 'PA_TASKS' AND
      IF ( p_calling_context = 'PA_TASKS' AND
            (PA_DELIVERABLE_UTILS.GET_DLVR_TASK_ASSCN_ID(p_dlv_element_id,p_task_element_id) IS NOT NULL)) THEN
        is_asscn_exists := 'Y';
    END IF;


     -- 3744841 If it is AMG Context then if association doesnt exist already,then only do insert
     --         The Other context where this API is used is :- SELF_SERVICE
     --         On creating a deliverable in task details flow it should get associated
     --         automatically to that task (after validations)


     -- 3651542 only one of the IF condition will be satisfied and either task to dvlr association or
     -- task assgn to deliverable asscn existance will be checked and is_asscn_exists falg will be set to  'Y'

     -- moved below commented code from if condition, as separate code segment above
     -- insert will be called if calling module is SS or if calling module is AMG and asscn does not exists

     -- 3651542 incorporated review comments , the association existance will be checked for both AMG and SS
     -- removing p_calling_module = 'SELF_SERVICE' and p_calling_module = 'AMG' conditions from below if
     IF ( is_asscn_exists = 'N' )
--     IF (p_calling_module = 'SELF_SERVICE') OR ( p_calling_module = 'AMG' AND is_asscn_exists = 'N' ) --OR
--        ( p_calling_module = 'AMG' AND nvl(PA_DELIVERABLE_UTILS.GET_DLVR_TASK_ASSCN_ID(p_dlv_element_id,p_task_element_id),-99) = -99) -- 3749487 changed from 'X' to -99
     THEN
     -- Populate object relationship table
     INSERT INTO PA_OBJECT_RELATIONSHIPS (
                 object_relationship_id
                ,object_type_from
                ,object_id_from1
                ,object_type_to
                ,object_id_to1
                ,relationship_type
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date
                ,object_id_from2
                ,object_id_to2
                ,relationship_subtype
                ,record_version_number
                ,last_update_login
              )
           VALUES
              (
               pa_object_relationships_s.nextval
              ,decode(p_calling_context,'PA_TASKS','PA_TASKS','PA_ASSIGNMENTS')
              ,p_task_version_id
              ,'PA_DELIVERABLES'
              ,p_dlv_version_id
              ,'A'
              ,fnd_global.user_id
              ,SYSDATE
              ,fnd_global.user_id
              ,SYSDATE
              ,p_task_element_id
              ,p_dlv_element_id
              ,decode(p_calling_context,'PA_TASKS','TASK_TO_DELIVERABLE','ASSIGNMENT_TO_DELIVERABLE')
              ,1
              ,fnd_global.login_id
             ) ;
    END IF;

         IF p_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
         END IF ;
EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CREATE_DLV_TASK_ASSOCIATION_SP;
     END IF ;

     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of CREATE_DLV_TASK_ASSOCIATION';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK TO CREATE_DLV_TASK_ASSOCIATION_SP;
     END IF ;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_VT'
                     ,p_procedure_name  => 'CREATE_DLV_TASK_ASSOCIATION');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('CREATE_DLV_TASK_ASSOCIATION: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CREATE_DLV_TASK_ASSOCIATION ;

PROCEDURE DELETE_DELIVERABLE_STRUCTURE
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_msg_count          NUMBER := 0;
     l_msg_data           VARCHAR2(2000);
     l_data               VARCHAR2(2000);
     l_return_status      VARCHAR2(1);
     l_msg_index_out      NUMBER ;
     l_proj_element_id    NUMBER ;
     l_element_version_id NUMBER ;
     l_return_flag        VARCHAR2(1);
     l_dlv_based_task_exists VARCHAR2(1);

     --Bug # 3431156 Included by avaithia
     l_dlv_version_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
     l_object_type_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

     --Bug #3538320 Included by avaithia on 29-Mar-2004
     l_dlv_proj_elt_tbl  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

BEGIN
     l_msg_count := 0;
     l_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLE_STRUCTURE',
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DELIVERABLE_STRUCTURE ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     -- Validate mandatory input parameter
     PA_DELIVERABLE_UTILS.CHECK_DLVR_DISABLE_ALLOWED
         ( p_debug_mode    => p_debug_mode
          ,p_project_id    => p_project_id
          ,x_return_flag   => l_return_flag
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

/*  Bug 3597178 We can still go about Disabling Deliverable Structure ,Even If Deliverable Based Tasks Exist for that project
     l_dlv_based_task_exists := PA_DELIVERABLE_UTILS.IS_DLV_BASED_TASK_EXISTS (p_project_id);
     IF (l_dlv_based_task_exists = 'Y') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_DLV_BASED_TASK_EXISTS');
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF;
*/
    -- Delete the structure level record
     DELETE FROM PA_PROJ_ELEMENTS
           WHERE project_id = p_project_id
             AND object_type = 'PA_STRUCTURES'
             AND proj_element_id in (SELECT proj_element_id
                                       FROM pa_proj_structure_types
                                      WHERE structure_type_id = 8
                                    )
     RETURNING proj_element_id INTO l_proj_element_id ;

     DELETE FROM PA_PROJ_ELEMENT_VERSIONS
           WHERE proj_element_id = l_proj_element_id
             AND object_type = 'PA_STRUCTURES'
     RETURNING element_version_id INTO l_element_version_id ;

     DELETE FROM PA_PROJ_STRUCTURE_TYPES
           WHERE proj_element_id = l_proj_element_id ;

     DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
           WHERE proj_element_id = l_proj_element_id
             AND project_id = p_project_id ;/* Included project_id clause for Performance Bug Fix 3614361 */

    /*3614361 Included Delete from  PA_PROJ_ELEM_VER_STRUCTURE */
     DELETE FROM PA_PROJ_ELEM_VER_STRUCTURE
           WHERE proj_element_id = l_proj_element_id
             AND project_id = p_project_id ;

     /* Moved the following code to top for Performance Bug Fix 3614361
      BULK DELETE Approach is a better approach in this case */

    -- Delete the deliverables,actions and the relationships
     DELETE FROM PA_PROJ_ELEMENT_VERSIONS
           WHERE project_id = p_project_id
             AND object_type in ('PA_DELIVERABLES','PA_ACTIONS')
     RETURNING ELEMENT_VERSION_ID ,OBJECT_TYPE,PROJ_ELEMENT_ID --Included Proj_element_id for Bug 3538320
     BULK COLLECT INTO l_dlv_version_tbl,l_object_type_tbl,l_dlv_proj_elt_tbl;

     -- 3837025 , if there is no deliverable and action records , below code is failing and giving numeric or null value error
     -- Checking for the table's last value, if it is greater than zero i.e. there is deliverable or actions record in the db
     -- go ahead and delete the records

     IF nvl(l_dlv_version_tbl.LAST,0)>0 THEN

         FORALL j IN l_dlv_proj_elt_tbl.FIRST..l_dlv_proj_elt_tbl.LAST
              DELETE FROM PA_OBJECT_RELATIONSHIPS
               WHERE object_id_to2  =  l_dlv_proj_elt_tbl(j)
                 and object_type_to = 'PA_DELIVERABLES';                -- Added for perf bug# 3964586;

         -- 3986132 Added below code to delete DELIVERABLE to ACTION association from
         -- pa_object_relationships table

         FORALL j IN l_dlv_version_tbl.FIRST..l_dlv_version_tbl.LAST
              DELETE FROM PA_OBJECT_RELATIONSHIPS
               WHERE object_id_from1    =  l_dlv_version_tbl(j)
                and  object_type_from   =  'PA_DELIVERABLES'
                and  object_type_to     =  'PA_ACTIONS';

         -- 3986132 end

         FORALL j IN l_dlv_version_tbl.FIRST..l_dlv_version_tbl.LAST
               DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
                WHERE project_id = p_project_id
                  AND element_version_id = l_dlv_version_tbl(j);

         FORALL j IN l_dlv_proj_elt_tbl.FIRST..l_dlv_proj_elt_tbl.LAST
               DELETE FROM PA_PROJ_ELEMENTS
                WHERE proj_element_id = l_dlv_proj_elt_tbl(j);

     --The nvl check is needed because :Say suppose only deliverable structure has been
     --enabled and there are no deliverables created so far,
     --then nothing will be there in l_dlv_version_id_tbl

    -- 3837025 moved below IF clause above , i.e. before the for loop of deleting records from object relationship tables
    --IF nvl(l_dlv_version_tbl.LAST,0)>0 THEN
          FOR i IN l_dlv_version_tbl.FIRST..l_dlv_version_tbl.LAST LOOP

                 --Included by avaithia on 12-Feb-2004 <<Start>> Bug # 3431156
         --Whenever deliverable structure is disabled we need to delete the deliverable/action
         --related data from OKE tables.

                 -- OKE API internally takes care of deleting the actions associated with the deliverable

                 IF l_object_type_tbl(i)= 'PA_DELIVERABLES'
                 THEN

                    OKE_DELIVERABLE_UTILS_PUB.DELETE_DELIVERABLE
                            ( P_DELIVERABLE_ID => l_dlv_version_tbl(i)
                             , X_Return_Status => x_return_status
                             , X_Msg_Count     => x_msg_count
                             , X_Msg_Data      => x_msg_data
                             ) ;
                     IF  X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE Invalid_Arg_Exc_Dlv ;
                     END IF ;

                     --Start Bug 3538320 <<Included by avaithia on 29-Mar-2004>>
                     --Delete the Attachment records of the deliverable

                     IF nvl(PA_DELIVERABLE_UTILS.IS_DLV_DOC_DEFINED(l_dlv_proj_elt_tbl(i),l_dlv_version_tbl(i)),'N')='Y' THEN
                         fnd_attached_documents2_pkg.delete_attachments
                            (X_entity_name             => 'PA_DLVR_DOC_ATTACH',
                             X_pk1_value               => to_char(l_dlv_version_tbl(i)),
                             X_delete_document_flag    => 'Y');
                     END IF ;

                     fnd_attached_documents2_pkg.delete_attachments
                            (X_entity_name             => 'PA_DVLR_ATTACH',
                             X_pk1_value               => to_char(l_dlv_version_tbl(i)),
                             X_delete_document_flag    => 'Y');

                     --End Bug 3538320

                 END IF;

          END LOOP;
     END IF;

     -- <<End>> Included by avaithia on 12-Feb-2004 Bug # 3431156

     IF p_debug_mode = 'Y' THEN
         pa_debug.reset_curr_function;
     END IF ;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DELIVERABLE_STRUCTURE';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_DELIVERABLE_PVT'
              ,p_procedure_name => 'DELETE_DELIVERABLE_STRUCTURE' );
     IF p_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_DELIVERABLE_STRUCTURE' || g_module_name,SQLERRM,4);
             pa_debug.write('DELETE_DELIVERABLE_STRUCTURE' || g_module_name,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
     END IF;
     RAISE ;
END DELETE_DELIVERABLE_STRUCTURE ;

/* Proper Comments put for Bug 3906015 */
-- IMPORTANT :-
--  p_calling_context = 'PA_TASKS' case of this API is EXACTLY same as the contents of DELETE_DLV_ASSOCIATIONS API

--  What is the need for DELETE_DLV_ASSOCIATIONS API then ?
--    During task->deliverable association deletion (i.e) p_calling_context = 'PA_TASKS' case
--    This API DELETE_DLV_TASK_ASSCN_IN_BULK populates an error message :
--      "You cannot delete this task as task has association with deliverable which has transactions"
--
--    which is irrelevant error message when the operation is "Disabling Workplan" (Or) "SHARE -> SPLIT SETUP CHANGES"

--    Note that :- Disabling Workplan (Or) "SHARE -> SPLIT SETUP CHANGES" also ,deletes WP tasks and
--    which also means that the tasks' associations with the deliverables have to be deleted

--    So,In this case ,to throw an appropriate error message
--   (and) to avoid any impact (for DELETE_DLV_TASK_ASSCN_IN_BULK API being called from other places)
--   We are putting the same code in DELETE_DLV_ASSOCIATIONS API

--   *******************************************************************************************************************
--   FOR ANY FIX DONE FOR p_calling_context ='PA_TASKS' case ,SAME FIX HAS TO DONE FOR DELETE_DLV_ASSOCIATIONS API ALSO
--   *******************************************************************************************************************
PROCEDURE DELETE_DLV_TASK_ASSCN_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_calling_context     IN VARCHAR2 := 'PA_TASKS'
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_delete_or_validate  IN VARCHAR2 := 'B' -- 3955848 V- Validate , D - Delete, B - Validate and Delete ( default )
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS

     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_dummy                      VARCHAR2(1) ;

    -- 3899363 Commented below cursor select because shipping/procurement/mds and billing action related validations
    -- are not required for workplan task deletion
    -- Also, the below sql is passing deliverable action element id to check for deliverable publish progress record e
    -- existance
    -- The below validations should be done only for deliverale based task

    /*
       --   Bug 3651781 While deleting association between a deliverable based task and a deliverable ,we have to
       --   Look for 'PUBLISHED' progress records ,NOT mere existence of progress records
     CURSOR C(c_project_id IN NUMBER) IS
     SELECT 'Y'
       FROM DUAL
     WHERE EXISTS (SELECT 'Y'
            FROM pa_proj_element_versions pev
                ,pa_object_relationships obj1
                ,pa_object_relationships obj2
           WHERE obj1.object_id_from2 = p_task_element_id
             AND obj1.relationship_type = 'A'
             AND obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
             AND obj1.object_type_from = 'PA_TASKS'
             AND obj1.object_type_to = 'PA_DELIVERABLES'
             AND obj2.object_id_from2 = obj1.object_id_to2
             AND obj2.relationship_type = 'A'
             AND obj2.relationship_subtype = 'DELIVERABLE_TO_ACTION'
             AND obj2.object_type_from = 'PA_DELIVERABLES'
             AND obj2.object_type_to = 'PA_ACTIONS'
             AND obj2.object_id_to2 = pev.proj_element_id
             AND (nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(pev.element_version_id),'N') = 'Y'
             OR nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(pev.element_version_id),'N') = 'Y'
             OR nvl(OKE_DELIVERABLE_UTILS_PUB.MDS_Initiated_Yn(pev.element_version_id),'N') = 'Y'
             OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(pev.proj_element_id) = 'BILLING'
           --  OR nvl(PA_DELIVERABLE_UTILS.IS_DELIVERABLE_HAS_PROGRESS(c_project_id,pev.proj_element_id),'N') = 'Y' Commented for 3651781
             OR nvl(PA_PROGRESS_UTILS.published_dlv_prog_exists(c_project_id , pev.proj_element_id),'N') = 'Y'
             )
        );
    */

     -- Changed the above cursor select, it returns Y if deliverable based task is associated with deliverable, having
     -- published progress record
     -- if below cursor returns Y, workplan task to deliverable association deletion is not allowed, error message is populated

     CURSOR C(c_project_id IN NUMBER) IS
     SELECT 'Y'
       FROM DUAL
     WHERE EXISTS (SELECT 'Y'
            FROM pa_proj_elements ppe
                ,pa_object_relationships obj1
                ,pa_task_types ptt
           WHERE obj1.object_id_from2 = p_task_element_id
             AND obj1.relationship_type = 'A'
             AND obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
             AND obj1.object_type_from = 'PA_TASKS'
             AND obj1.object_type_to = 'PA_DELIVERABLES'
             AND obj1.object_id_from2 = ppe.proj_element_id
             and ppe.type_id = ptt.task_type_id
             and ppe.object_type = 'PA_TASKS'
             and nvl(ppe.base_percent_comp_deriv_code,ptt.base_percent_comp_deriv_code) =  'DELIVERABLE'
             and nvl(PA_PROGRESS_UTILS.published_dlv_prog_exists(c_project_id , obj1.object_id_to2),'N') = 'Y');

     -- 3899363 end

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_TASK_ASSOCIATION',
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Opening cursor ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

/*  Following Comment introduced for Bug 3906015*/
--   *******************************************************************************************************************
--   FOR ANY FIX DONE FOR p_calling_context ='PA_TASKS' case ,SAME FIX HAS TO DONE FOR DELETE_DLV_ASSOCIATIONS API ALSO
--   *******************************************************************************************************************

     IF p_calling_context = 'PA_TASKS' THEN

          -- 3955848 Added following if condition to check for p_delete_or_validate
          -- For this fix, there is no change required in DELETE_DLV_ASSOCIATIONS because in this
          -- fix there is no extra validation is done, just separated the validation and actual deletion
          -- for version enabled case, task deletion

          -- if p_delete_or_validate is B , do both validation and deletion ( default behaviour )
          -- if p_delete_or_validate is V , do only validation ( ver enabled case , task deletion flow )

          IF p_delete_or_validate IN ('B','V') THEN

              OPEN C(p_project_id) ;
              FETCH C into l_dummy ;
              IF C%FOUND THEN
                   PA_UTILS.ADD_MESSAGE('PA','PA_DLV_TASK_ASSCN_EXISTS') ;
                   RAISE Invalid_Arg_Exc_Dlv ;
              END IF ;
              CLOSE C;

              END IF;

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Delete the association';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF ;

          -- 3955848 Added following if condition to check for p_delete_or_validate
          -- if p_delete_or_validate is B , do both validation and deletion ( default behaviour )
          -- if p_delete_or_validate is D , do only deletion ( ver enabled case, publishing flow )

          IF p_delete_or_validate IN ('B','D') THEN

              DELETE FROM pa_object_relationships
                   WHERE object_id_from2 = p_task_element_id
                     AND object_type_from = 'PA_TASKS'
                     AND object_type_to = 'PA_DELIVERABLES'
                     AND relationship_type = 'A'
                     AND relationship_subtype = 'TASK_TO_DELIVERABLE' ;

          END IF;
     ELSE
     DELETE FROM pa_object_relationships
               WHERE object_id_from2 = p_task_element_id
                 AND object_type_from = 'PA_ASSIGNMENTS'
                 AND object_type_to = 'PA_DELIVERABLES'
                 AND relationship_type = 'A'
                 AND relationship_subtype = 'ASSIGNMENT_TO_DELIVERABLE' ;
     END IF ;

     IF p_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_TASK_ASSCN_IN_BULK' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_TASK_ASSCN_IN_BULK';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                             ,p_procedure_name  => 'DELETE_DLV_TASK_ASSCN_IN_BULK');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_TASK_ASSCN_IN_BULK: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_TASK_ASSCN_IN_BULK ;


/* Elaborative Comment explaining purpose of API included for Bug 3906015*/

-- This procedure is called ONLY under 2 cases
-- 1) While Structure Setup Change happens
-- from SHARED -> SPLIT
-- 2) While Workplan is Disabled

-- In this case ,the Workplan Tasks have to be deleted and hence their associations
-- with deliverables too .

-- So,While a WP Task is deleted ,the validations that have to happen from Deliverables Side are :-
-- 1) There should not be 'published' progress record for Deliverable associated to the WP Task
-- 2) There should not be any transaction for the deliverable associated to the WP task by means of
--    Initiating Shipping ,Procurement (Or) Billing
--******************************************************************************************************************
-- In Future whatever fix is done to DELETE_DLV_TASK_ASSCN_IN_BULK API (for p_calling_context = 'PA_TASKS' case)
-- care should be taken to see that whether same fix needs to be done here in DELETE_DLV_ASSOCIATIONS too .

-- The Vice versa also applies .
--******************************************************************************************************************
PROCEDURE DELETE_DLV_ASSOCIATIONS
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id          IN NUMBER
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode                 VARCHAR2(10);
     l_msg_count                  NUMBER ;
     l_data                       VARCHAR2(2000);
     l_msg_data                   VARCHAR2(2000);
     l_msg_index_out              NUMBER;
     l_dummy                      VARCHAR2(1) ;
     l_return_flag                VARCHAR2(1) ;

-- 3899363 Commented below cursor select because shipping/procurement/mds and billing action related validations
    -- are not required for workplan task deletion
    -- Also, the below sql is passing deliverable action element id to check for deliverable publish progress record e
    -- existance
    -- The below validations should be done only for deliverale based task

    /* This cursor is very much similar to the one (cursor c) in DELETE_DLV_TASK_ASSCN_IN_BULK API
       But with little modifications - bug 3906015*/
    /*
    CURSOR C (c_project_id IN NUMBER) IS
    SELECT 'Y'
    from dual
    WHERE EXISTS(
                 SELECT 'Y'
               FROM PA_PROJ_ELEMENT_VERSIONS pev1,
                PA_OBJECT_RELATIONSHIPS  obj1,
                PA_PROJ_ELEMENT_VERSIONS pev,
                PA_OBJECT_RELATIONSHIPS  obj2
             WHERE  obj1.object_id_from2 = pev1.proj_element_id
               AND  pev1.project_id      = c_project_id
               AND  pev1.object_type     = 'PA_TASKS'
               AND  obj1.relationship_type   = 'A'
                   AND  obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
                   AND  obj1.object_type_from     = 'PA_TASKS'
                   AND  obj1.object_type_to       = 'PA_DELIVERABLES'
                   AND  obj2.object_id_from2      = obj1.object_id_to2
                   AND  obj2.relationship_type    = 'A'
                   AND  obj2.relationship_subtype = 'DELIVERABLE_TO_ACTION'
                   AND  obj1.object_type_from     = 'PA_DELIVERABLES'
                   AND  obj1.object_type_to       = 'PA_ACTIONS'
               AND  obj2.object_id_to2        = pev.proj_element_id
                   AND  (nvl(OKE_DELIVERABLE_UTILS_PUB.WSH_Initiated_Yn(pev.element_version_id),'N') = 'Y'
                      OR nvl(OKE_DELIVERABLE_UTILS_PUB.REQ_Initiated_Yn(pev.element_version_id),'N') = 'Y'
                      OR nvl(OKE_DELIVERABLE_UTILS_PUB.MDS_Initiated_Yn(pev.element_version_id),'N') = 'Y'
                      OR PA_DELIVERABLE_UTILS.GET_FUNCTION_CODE(pev.proj_element_id) = 'BILLING'
                      OR nvl(PA_PROGRESS_UTILS.published_dlv_prog_exists(c_project_id , pev.proj_element_id),'N') = 'Y'
                        )
            );
    */

     -- Changed the above cursor select, it returns Y if deliverable based task is associated with deliverable, having
     -- published progress record
     -- if below cursor returns Y, workplan task to deliverable association deletion is not allowed, error message is populated

    CURSOR C (c_project_id IN NUMBER) IS
    SELECT 'Y'
    from dual
    WHERE EXISTS(
                SELECT 'Y'
                FROM pa_proj_elements ppe
                    ,pa_object_relationships obj1
                    ,pa_task_types ptt
                WHERE
                     ppe.project_id = c_project_id
                 and ppe.object_type = 'PA_TASKS'
                 and ppe.type_id = ptt.task_type_id
                 and nvl(ppe.base_percent_comp_deriv_code,ptt.base_percent_comp_deriv_code) =  'DELIVERABLE'
                 AND obj1.object_id_from2 = ppe.proj_element_id
                 AND obj1.relationship_type = 'A'
                 AND obj1.relationship_subtype = 'TASK_TO_DELIVERABLE'
                 AND obj1.object_type_from = 'PA_TASKS'
                 AND obj1.object_type_to = 'PA_DELIVERABLES'
                 and nvl(PA_PROGRESS_UTILS.published_dlv_prog_exists(c_project_id , obj1.object_id_to2),'N') = 'Y');

-- 3899363 end

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DLV_ASSOCIATIONS',
                                      p_debug_mode => p_debug_mode );
          pa_debug.g_err_stage:= 'Inside DELETE_DLV_TASK_ASSOCIATION ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

/*    Commented for Bug 3906015 : Incorrect Check was being performed
      -- Validate mandatory input parameter
     PA_DELIVERABLE_UTILS.CHECK_DLVR_DISABLE_ALLOWED
         ( p_debug_mode    => p_debug_mode
          ,p_project_id    => p_project_id
          ,x_return_flag   => l_return_flag
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ) ;

     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;
*/
     -- Bug 3906015 : Start
     OPEN C(p_project_id) ;
     FETCH C into l_dummy ;
     IF C%FOUND THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_TASK_DLV_ASSCN_EXISTS') ;
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;
     CLOSE C;
      -- Bug 3906015 : End

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Delete the associations';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     DELETE FROM pa_object_relationships
          WHERE object_type_from = 'PA_TASKS'
            AND object_type_to = 'PA_DELIVERABLES'
            AND relationship_type = 'A'
            AND relationship_subtype = 'TASK_TO_DELIVERABLE'
            AND object_id_from2 in (SELECT proj_element_id
                                      FROM pa_proj_elements
                                     WHERE project_id = p_project_id ) ;

     IF p_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting DELETE_DLV_ASSOCIATIONS' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF p_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of DELETE_DLV_ASSOCIATIONS';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF p_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                             ,p_procedure_name  => 'DELETE_DLV_ASSOCIATIONS');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('DELETE_DLV_ASSOCIATIONS: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_DLV_ASSOCIATIONS ;

-- SubProgram           : COPY_DELIVERABLES
-- Type                 : PROCEDURE
-- Purpose              : Public API to Delete Multiple Deliverables from Deliverable List Page
-- Note                 : This API is called from Deliverable List Page
-- Assumptions          : None
-- Parameter                      IN/OUT        Type         Required     Description and Purpose
-- ---------------------------  ---------    ----------      ---------    ---------------------------
-- p_api_version                   IN          NUMBER            N        Standard Parameter
-- p_init_msg_list                 IN          VARCHAR2          N        Standard Parameter
-- p_commit                        IN          VARCHAR2          N        Standard Parameter
-- p_validate_only                 IN          VARCHAR2          N        Standard Parameter
-- p_validation_level              IN          NUMBER            N        Standard Parameter
-- p_calling_module                IN          VARCHAR2          N        Standard Parameter
-- p_debug_mode                    IN          VARCHAR2          N        Standard Parameter
-- p_max_msg_count                 IN          NUMBER            N        Standard Parameter
-- p_source_project_id             IN          NUMBER            Y        Source Project Id
-- p_target_project_id             IN          NUMBER            Y        Target Project Id
-- p_dlv_element_id_tbl            IN          PLSQL table       N        Source Dlv. Element Id
-- p_dlv_version_id_tbl            IN          PLSQL table       N        Target Dlv. Element Id
-- p_item_details_flag             IN          VARCHAR2          N        Copy Item Flag
-- p_dlv_actions_flag              IN          VARCHAR2          N        Copy Actions Flag
-- p_dlv_attachments_flag          IN          VARCHAR2          N        Copy Attachment Flag
-- p_association_flag              IN          VARCHAR2          N        Copy Associations Flag
-- p_prefix                        IN          VARCHAR2          N        Prefix
-- p_delta                         IN          VARCHAR2          N        Passed during copy project
-- p_calling_context               IN          VARCHAR2          Y        Calling Context.
-- x_return_status                 OUT         VARCHAR2          N        Standard Out Parameter
-- x_msg_count                     OUT         NUMBER            N        Standard Out Parameter
-- x_msg_data                      OUT         VARCHAR2          N        Standard Out Parameter


-- This API is called from different flows :
--     1. CREATE PROJECT FROM TEMPLATE/PROJECT
--     2. COPY DELIVERABLES
--     3. COPY EXTERNAL
--     4. COPY TASKS
-- Any changes in this API might impact the above flows so all the impact analysis
-- is must .

-- Following bugs are fixed :
-- Note : Please update this sction with the bug no. and description
-- for any bug fixes .
-- Bug No.       Date           Technichal Description(In Brief)
-- ========     ========        ================================
-- 3515845      22-MAR-04       Progress weight not getting copied as
--                              l_progress_weigh_tbl was overwritten with
--                              function_code for deliverables which null.
--                              Hence always null is getting copied.
--                              Removed the function_code from the cursor
--                              l_proj_element_data and l_source_deliverables
--                              and from subsequent fetch statement removed the
--                              l_progress_weight_tbl

-- 3515852      13-MAR-04       While copying deliverables , status should be
--                              defaulted from deliverable type .

-- 3493612      13-MAR-04       During create project, dates are not adjusted
--                              based on quick entry dates.

PROCEDURE COPY_DELIVERABLES
     (p_api_version          IN NUMBER   :=1.0
     ,p_init_msg_list        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit               IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level     IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module       IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode           IN VARCHAR2 :='N'
     ,p_max_msg_count        IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_source_project_id    IN NUMBER
     ,p_target_project_id    IN NUMBER
     ,p_dlv_element_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_version_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_item_details_flag    IN VARCHAR2 := 'N'
     ,p_dlv_actions_flag     IN VARCHAR2 := 'N'
     ,p_dlv_attachments_flag IN VARCHAR2 := 'N'
     ,p_association_flag     IN VARCHAR2 := 'N'
     ,p_prefix               IN VARCHAR2 := null
     ,p_delta                IN NUMBER := null
     ,p_calling_context      IN VARCHAR2
     ,p_task_id              IN NUMBER :=null
     ,p_task_version_id      IN NUMBER :=null
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
     l_debug_mode     VARCHAR2(10)    ;
     l_msg_count      NUMBER          ;
     l_data           VARCHAR2(2000)  ;
     l_msg_data       VARCHAR2(2000)  ;
     l_msg_index_out  NUMBER          ;

-- This is the cursor which will be called during copy deliverables,copy external and copy tasks.
-- This cursor fetch the source deliverable info.

     CURSOR l_proj_element_data(c_proj_element_id IN pa_proj_elements.proj_element_id%TYPE)
         IS
     SELECT SUBSTR(p_prefix||ppe.element_number,1,100)
           ,SUBSTR(p_prefix||ppe.name,1,240)
           ,ppe.manager_person_id
           ,ppe.carrying_out_organization_id
           ,ppe.progress_weight
           ,ppe.pm_source_reference
           ,ppe.pm_source_code
           ,ppe.description
           ,ppe.attribute_category
           ,ppe.attribute1
           ,ppe.attribute2
           ,ppe.attribute3
           ,ppe.attribute4
           ,ppe.attribute5
           ,ppe.attribute6
           ,ppe.attribute7
           ,ppe.attribute8
           ,ppe.attribute9
           ,ppe.attribute10
           ,ppe.attribute11
           ,ppe.attribute12
           ,ppe.attribute13
           ,ppe.attribute14
           ,ppe.proj_element_id --source is maintianed in attribute15 column.
           ,ppe.proj_element_id --to populate the source
           ,pev.element_version_id -- Source element version id
           ,ppe.type_id
           ,pvs.scheduled_finish_date
           ,ptt.initial_status_code                  -- Bug#3515852
       FROM pa_proj_elements ppe
           ,pa_proj_elem_ver_schedule pvs
           ,pa_proj_element_versions pev
           ,pa_task_types ptt
      WHERE ppe.proj_element_id = c_proj_element_id
        AND ppe.object_type = 'PA_DELIVERABLES'
        AND pev.proj_element_id = c_proj_element_id
        AND pev.object_type = 'PA_DELIVERABLES'
        AND pvs.proj_element_id = c_proj_element_id
        AND pvs.project_id = ppe.project_id
        AND ptt.task_type_id = ppe.type_id           -- Bug#3515852
        AND ptt.object_type = 'PA_DLVR_TYPES';       -- Bug#3515852

-- This is the cursor which will be called during create project flow.
-- This cursor will fetch the source deliverable info.

     CURSOR l_source_deliverables
         IS
     SELECT ppe.element_number
           ,ppe.name
           ,ppe.manager_person_id
           ,ppe.carrying_out_organization_id
           ,ppe.progress_weight
           ,ppe.pm_source_reference
           ,ppe.pm_source_code
           ,ppe.description
           ,ppe.attribute_category
           ,ppe.attribute1
           ,ppe.attribute2
           ,ppe.attribute3
           ,ppe.attribute4
           ,ppe.attribute5
           ,ppe.attribute6
           ,ppe.attribute7
           ,ppe.attribute8
           ,ppe.attribute9
           ,ppe.attribute10
           ,ppe.attribute11
           ,ppe.attribute12
           ,ppe.attribute13
           ,ppe.attribute14
           ,ppe.proj_element_id --source is maintianed in attribute15 column.
           ,ppe.proj_element_id --to populate the source
           ,pev.element_version_id -- Source element version id
           ,ppe.type_id
           ,pvs.scheduled_finish_date
           ,ptt.initial_status_code       -- Bug#3515852
       FROM pa_proj_elements ppe
           ,pa_proj_elem_ver_schedule pvs
           ,pa_proj_element_versions pev
           ,pa_task_types ptt
      WHERE ppe.project_id = p_source_project_id
        AND ppe.object_type = 'PA_DELIVERABLES'
        AND pev.proj_element_id = ppe.proj_element_id
        AND pev.project_id = p_source_project_id
        AND ppe.project_id = pev.project_id                 -- Added for perf bug# 3964586
        AND pev.object_type = 'PA_DELIVERABLES'
        AND ppe.project_id=pvs.project_id                   -- Added for perf bug# 3964586
        AND ppe.proj_element_id = pvs.proj_element_id
        AND pev.element_version_id=pvs.element_version_id   -- Added for perf bug# 3964586
        AND pvs.project_id = p_source_project_id
        AND ptt.task_type_id = ppe.type_id             -- Bug#3515852
        AND ptt.object_type = 'PA_DLVR_TYPES';         -- Bug#3515852

     CURSOR c_structure_id IS
 SELECT ppe.proj_element_id
      ,ppe.element_version_id
  FROM pa_proj_elem_ver_structure ppe
      ,pa_proj_structure_types pst
      ,pa_structure_types sty
 WHERE ppe.project_id = p_target_project_id
   AND ppe.proj_element_id = pst.proj_element_id
   AND pst.structure_type_id = sty.structure_type_id
   AND sty.structure_type = 'DELIVERABLE'
   AND sty.structure_type_class_code = 'DELIVERABLE'
  ;

   /* Commented for Performance Bug 3614361
     SELECT ppe.proj_element_id
           ,pev.element_version_id
       FROM pa_proj_structure_types pst
           ,pa_structure_types sty
           ,pa_proj_elements ppe
           ,pa_proj_element_versions pev
      WHERE ppe.project_id = p_target_project_id
        AND ppe.object_type = 'PA_STRUCTURES'
        AND pev.proj_element_id = ppe.proj_element_id
        AND pev.project_id = ppe.project_id
        AND ppe.object_type = pev.object_type
        AND ppe.proj_element_id = pst.proj_element_id
        AND pst.structure_type_id = sty.structure_type_id
        AND sty.structure_type = 'DELIVERABLE'
        AND sty.structure_type_class_code = 'DELIVERABLE' ;
  */
     --Bug 3611598 Following Cursor and local variables have been included
     CURSOR c_project_details IS
     SELECT pa.project_type
           ,pa.project_status_code
           ,project_system_status_code
           ,segment1                -- 3671408 added column to retrieve project number
     FROM PA_PROJECT_STATUSES pps,
               PA_PROJECTS_ALL pa
     WHERE pa.PROJECT_ID = p_target_project_id
       AND pps.PROJECT_STATUS_CODE = pa.PROJECT_STATUS_CODE ;

     l_project_sys_status_code  PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
     l_status_code              PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
     l_project_type             PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;

     l_item_type             VARCHAR2(30);
     l_wf_process            VARCHAR2(30);
     l_wf_item_type          VARCHAR2(30);
     l_err_code         NUMBER  := 0;
     l_wf_enabled_flag       VARCHAR2(1);
     --Bug 3611598 <<End of Changes>>

     l_structure_id           NUMBER ;
     l_structure_version_id   NUMBER ;
     l_owner_id               NUMBER ;
     l_dummy                  PER_ALL_PEOPLE_F.FULL_NAME%TYPE ;
     l_due_date               DATE ;
     l_parent_structure_id    NUMBER ;
     l_parent_structure_version_id  NUMBER ;
     l_y_or_n                 VARCHAR2(1) ;
     l_project_name           pa_projects_all.name%TYPE ;
     l_suffix                 pa_lookups.meaning%TYPE ;
     l_name                   VARCHAR2(250);

     l_element_number_tbl          SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_name_tbl                    SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_manager_person_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_carrying_out_org_id_tbl     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_progress_weight_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_pm_source_reference_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_pm_source_code_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;

     l_due_date_tbl                SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()                   ;
     l_element_id_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_rec_ver_num_id_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_description_tbl             SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
     l_attribute_category_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;
     l_attribute1_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute2_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute3_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute4_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute5_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute6_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute7_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute8_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute9_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute10_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute11_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute12_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute13_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute14_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_attribute15_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()   ;
     l_type_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     -- Bug#3515852
     l_status_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()    ;

     l_proj_element_id_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_source_proj_element_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_source_element_ver_id_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_target_element_ver_id_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()                     ;
     l_date            DATE ;
     -- Bug#3515852 : This flag is no more required. Hence commenting.
     -- l_item_details_flag    VARCHAR2(1) := 'N' ;     -- 3469876 added the variable

     l_project_number              pa_projects_all.segment1%TYPE ; -- added for bug# 3671408

BEGIN

     l_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'COPY_DELIVERABLES',
                                      p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Inside COPY_DELIVERABLES ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'p_source_project_id is  '||p_source_project_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          pa_debug.g_err_stage:= 'p_target_project_id is  '||p_target_project_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF p_calling_context = 'COPY_PROJECT' THEN

     -- Below two selects are used for creating structure level
     -- element name .
          SELECT meaning
            INTO l_suffix
            FROM pa_lookups
           WHERE lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
             AND lookup_code = 'DELIVERABLE';

          SELECT name
            INTO l_project_name
            FROM pa_projects_all
            WHERE project_id = p_target_project_id ;




         l_name :=  substr(l_project_name||':'||l_suffix, 1, 240) ;

        -- Get the structure element id and version id before inserting .
           SELECT pa_tasks_s.nextval
                 ,pa_proj_element_versions_s.nextval
           INTO l_parent_structure_id
               ,l_parent_structure_version_id
           FROM dual ;


        -- If p_calling_context is COPY_PROJECT then first
        -- populate the structure level record .


        INSERT INTO PA_PROJ_ELEMENTS
               ( proj_element_id
                ,project_id
                ,object_type
                ,element_number
                ,name
                ,status_code
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,description
                ,pm_source_reference
                ,pm_source_code
                ,manager_person_id
                ,carrying_out_organization_id
                ,record_version_number
                ,last_update_login
                ,parent_structure_id
        ,source_object_id
        ,source_object_type
                )
        SELECT  l_parent_structure_id
               ,p_target_project_id
               ,ppe.object_type
               ,ppe.element_number
               ,l_name
               ,ppe.status_code
               ,sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,ppe.description
               ,ppe.pm_source_reference
               ,ppe.pm_source_code
               ,ppe.manager_person_id
               ,ppe.carrying_out_organization_id
               ,1
               ,fnd_global.login_id
               ,l_parent_structure_id
           ,p_target_project_id
           ,'PA_PROJECTS'
         FROM  pa_proj_elements ppe,
               pa_proj_structure_types pst
        WHERE ppe.object_type = 'PA_STRUCTURES'
          AND ppe.project_id = p_source_project_id
          AND pst.proj_element_id = ppe.proj_element_id
          AND pst.structure_type_id = 8 ;--For Deliverable


        INSERT INTO PA_PROJ_ELEMENT_VERSIONS
               ( element_version_id
                ,proj_element_id
                ,object_type
                ,project_id
                ,parent_structure_version_id
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,record_version_number
                ,last_update_login
        ,source_object_id
        ,source_object_type
                )
           VALUES
                (l_parent_structure_version_id
                ,l_parent_structure_id
                ,'PA_STRUCTURES'
                ,p_target_project_id
                ,l_parent_structure_version_id
                ,SYSDATE
                ,fnd_global.user_id
                ,SYSDATE
                ,fnd_global.user_id
                ,1
                ,fnd_global.login_id
        ,p_target_project_id,
        'PA_PROJECTS'
                )  ;

        INSERT INTO PA_PROJ_STRUCTURE_TYPES
               (  proj_structure_type_id
                 ,proj_element_id
                 ,structure_type_id
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login
                 ,record_version_number
                )
           VALUES
                (pa_proj_structure_types_s.nextval
                ,l_parent_structure_id
                ,8
                ,SYSDATE
                ,fnd_global.user_id
                ,SYSDATE
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,1
                ) ;

        INSERT INTO PA_PROJ_ELEM_VER_STRUCTURE
              ( pev_structure_id
               ,element_version_id
               ,version_number
               ,name
               ,project_id
               ,proj_element_id
               ,current_flag
               ,original_flag
               ,latest_eff_published_flag
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,record_version_number
               ,pm_source_code
               ,pm_source_reference
           ,source_object_id
           ,source_object_type)
           SELECT
                 pa_proj_elem_ver_structure_s.nextval
                ,l_parent_structure_version_id
                ,ppe.element_number
                ,l_name
                ,p_target_project_id
                ,l_parent_structure_id
                ,ver.current_flag
                ,ver.original_flag
                ,ver.latest_eff_published_flag
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,1
                ,ppe.pm_source_code
                ,ppe.pm_source_reference
        ,p_target_project_id
        ,'PA_PROJECTS'
           FROM pa_proj_elem_ver_structure ver
               ,pa_proj_elements ppe
               ,pa_proj_structure_types pst
          WHERE ver.project_id = p_source_project_id
            AND ppe.proj_element_id = ver.proj_element_id
            AND ppe.object_type = 'PA_STRUCTURES'
            AND ppe.proj_element_id = pst.proj_element_id
            AND pst.structure_type_id = 8 ;

     ELSE

          OPEN c_structure_id;
          FETCH c_structure_id INTO l_parent_structure_id ,l_parent_structure_version_id ;
          CLOSE c_structure_id ;

     END IF ;

     IF p_calling_context = 'COPY_PROJECT' THEN

          OPEN l_source_deliverables ;
          FETCH l_source_deliverables BULK COLLECT INTO
                 l_element_number_tbl
                ,l_name_tbl
                ,l_manager_person_id_tbl
                ,l_carrying_out_org_id_tbl
                ,l_progress_weight_tbl
                ,l_pm_source_reference_tbl
                ,l_pm_source_code_tbl
                ,l_description_tbl
                ,l_attribute_category_tbl
                ,l_attribute1_tbl
                ,l_attribute2_tbl
                ,l_attribute3_tbl
                ,l_attribute4_tbl
                ,l_attribute5_tbl
                ,l_attribute6_tbl
                ,l_attribute7_tbl
                ,l_attribute8_tbl
                ,l_attribute9_tbl
                ,l_attribute10_tbl
                ,l_attribute11_tbl
                ,l_attribute12_tbl
                ,l_attribute13_tbl
                ,l_attribute14_tbl
                ,l_attribute15_tbl
                ,l_source_proj_element_id_tbl
                ,l_source_element_ver_id_tbl
                ,l_type_id_tbl
                ,l_due_date_tbl
                ,l_status_code_tbl ;
          CLOSE l_source_deliverables ;

     ELSE

          IF nvl(p_dlv_element_id_tbl.LAST,0) > 0 THEN
               FOR i IN p_dlv_element_id_tbl.FIRST..p_dlv_element_id_tbl.LAST LOOP
                    l_element_number_tbl.extend ;
                    l_name_tbl.extend ;
                    l_manager_person_id_tbl.extend ;
                    l_carrying_out_org_id_tbl.extend ;
                    l_progress_weight_tbl.extend ;
                    l_pm_source_reference_tbl.extend ;
                    l_pm_source_code_tbl.extend ;
                    l_description_tbl.extend ;
                    l_attribute_category_tbl.extend ;
                    l_attribute1_tbl.extend ;
                    l_attribute2_tbl.extend ;
                    l_attribute3_tbl.extend ;
                    l_attribute4_tbl.extend ;
                    l_attribute5_tbl.extend ;
                    l_attribute6_tbl.extend ;
                    l_attribute7_tbl.extend ;
                    l_attribute8_tbl.extend ;
                    l_attribute9_tbl.extend ;
                    l_attribute10_tbl.extend ;
                    l_attribute11_tbl.extend ;
                    l_attribute12_tbl.extend ;
                    l_attribute13_tbl.extend ;
                    l_attribute14_tbl.extend ;
                    l_attribute15_tbl.extend ;
                    l_source_proj_element_id_tbl.extend ;
                    l_source_element_ver_id_tbl.extend ;
                    l_type_id_tbl.extend ;
                    l_due_date_tbl.extend ;
                    l_status_code_tbl.extend ;

                    OPEN  l_proj_element_data(p_dlv_element_id_tbl(i)) ;
                    FETCH l_proj_element_data INTO
                          l_element_number_tbl(i)
                         ,l_name_tbl(i)
                         ,l_manager_person_id_tbl(i)
                         ,l_carrying_out_org_id_tbl(i)
                         ,l_progress_weight_tbl(i)
                         ,l_pm_source_reference_tbl(i)
                         ,l_pm_source_code_tbl(i)
                         ,l_description_tbl(i)
                         ,l_attribute_category_tbl(i)
                         ,l_attribute1_tbl(i)
                         ,l_attribute2_tbl(i)
                         ,l_attribute3_tbl(i)
                         ,l_attribute4_tbl(i)
                         ,l_attribute5_tbl(i)
                         ,l_attribute6_tbl(i)
                         ,l_attribute7_tbl(i)
                         ,l_attribute8_tbl(i)
                         ,l_attribute9_tbl(i)
                         ,l_attribute10_tbl(i)
                         ,l_attribute11_tbl(i)
                         ,l_attribute12_tbl(i)
                         ,l_attribute13_tbl(i)
                         ,l_attribute14_tbl(i)
                         ,l_attribute15_tbl(i)
                         ,l_source_proj_element_id_tbl(i)
                         ,l_source_element_ver_id_tbl(i)
                         ,l_type_id_tbl(i)
                         ,l_due_date_tbl(i)
                         ,l_status_code_tbl(i);
                    CLOSE l_proj_element_data ;

               END LOOP ;

          END IF ;

     END IF ;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Populating PA_PROJ_ELEMENTS ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF;

     -- Validate unique deliverable number
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Check for Duplicate Deliverable Number ';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
     END IF ;

     IF p_calling_context <> 'COPY_PROJECT' THEN

	IF nvl(l_element_number_tbl.LAST,0)> 0 THEN -- Included for 4468344
          FOR i IN l_element_number_tbl.FIRST..l_element_number_tbl.LAST LOOP
               l_y_or_n := PA_PROJ_ELEMENTS_UTILS.Check_element_Number_Unique
                              (p_element_number   => l_element_number_tbl(i)
                              ,p_element_id       => null
                              ,p_project_id       => p_target_project_id
                              ,p_structure_id     => l_parent_structure_id
                              ,p_object_type      => 'PA_DELIVERABLES'
                              );

               IF nvl(l_y_or_n,'Y') = 'N' THEN
                    PA_UTILS.ADD_MESSAGE('PA','PA_ENTER_OTHER_PREFIX') ;
--                    IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE Invalid_Arg_Exc_Dlv ;
--                    END IF ;
                    pa_debug.g_err_stage := 'Duplicate Deliverable Number ';
                    pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
               END IF ;

          END LOOP ;
	END IF ; -- Included for 4468344
     END IF ;

     -- Proceed if only something is fetched.
     IF nvl(l_element_number_tbl.LAST,0)> 0 THEN
     -- If clause added for bug# 3429221

          -- Populate pa_proj_element table
          FORALL i IN l_element_number_tbl.FIRST..l_element_number_tbl.LAST
               INSERT INTO PA_PROJ_ELEMENTS
                    ( proj_element_id
                     ,project_id
                     ,object_type
                     ,element_number
                     ,name
                     ,status_code
                     ,creation_date
                     ,created_by
                     ,last_update_date
                     ,last_updated_by
                     ,description
                     ,pm_source_reference
                     ,pm_source_code
                     ,manager_person_id
                     ,carrying_out_organization_id
                     ,record_version_number
                     ,last_update_login
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
                     ,parent_structure_id
                     ,type_id
                     ,progress_weight
             ,source_object_id
             ,source_object_type
                     )
               VALUES
                    ( PA_TASKS_S.NEXTVAL
                     ,p_target_project_id
                     ,'PA_DELIVERABLES'
                     ,l_element_number_tbl(i)
                     ,l_name_tbl(i)
                     ,l_status_code_tbl(i)      -- Bug#3515852 'DLVR_NOT_STARTED'
                     ,sysdate
                     ,fnd_global.user_id
                     ,sysdate
                     ,fnd_global.user_id
                     ,l_description_tbl(i)
                     ,l_pm_source_reference_tbl(i)
                     ,l_pm_source_code_tbl(i)
                     ,l_manager_person_id_tbl(i)
                     ,l_carrying_out_org_id_tbl(i)
                     ,1
                     ,fnd_global.login_id
                     ,l_attribute_category_tbl(i)
                     ,l_attribute1_tbl(i)
                     ,l_attribute2_tbl(i)
                     ,l_attribute3_tbl(i)
                     ,l_attribute4_tbl(i)
                     ,l_attribute5_tbl(i)
                     ,l_attribute6_tbl(i)
                     ,l_attribute7_tbl(i)
                     ,l_attribute8_tbl(i)
                     ,l_attribute9_tbl(i)
                     ,l_attribute10_tbl(i)
                     ,l_attribute11_tbl(i)
                     ,l_attribute12_tbl(i)
                     ,l_attribute13_tbl(i)
                     ,l_attribute14_tbl(i)
                     ,l_attribute15_tbl(i)
                     ,l_parent_structure_id
                     ,l_type_id_tbl(i)
                     ,l_progress_weight_tbl(i)
             ,p_target_project_id
             ,'PA_PROJECTS'
                     )
                   RETURNING proj_element_id
                   BULK COLLECT INTO l_proj_element_id_tbl ;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Populating PA_PROJ_ELEMENT_VERSIONS ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF;

          -- Populate pa_proj_element_version table
          FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
              INSERT INTO PA_PROJ_ELEMENT_VERSIONS
                    ( element_version_id
                     ,proj_element_id
                     ,object_type
                     ,project_id
                     ,parent_structure_version_id
                     ,creation_date
                     ,created_by
                     ,last_update_date
                     ,last_updated_by
                     ,record_version_number
                     ,last_update_login
             ,source_object_id
             ,source_object_type
                     )
                VALUES
                     (pa_proj_element_versions_s.nextval
                     ,l_proj_element_id_tbl(i)
                     ,'PA_DELIVERABLES'
                     ,p_target_project_id
                     ,l_parent_structure_version_id
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,1
                     ,fnd_global.login_id
             ,p_target_project_id
             ,'PA_PROJECTS'
                     )
                   RETURNING element_version_id
                   BULK COLLECT INTO l_target_element_ver_id_tbl ;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Populating PA_PROJ_ELEM_VER_SCHEDULE ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF;


          -- Populate pa_proj_elem_ver_schedule table
          FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
                    INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
                          pev_schedule_id
                         ,element_version_id
                         ,project_id
                         ,proj_element_id
                         ,creation_date
                         ,created_by
                         ,last_update_date
                         ,last_updated_by
                         ,last_update_login
                         ,scheduled_finish_date
                         ,actual_finish_date
                         ,record_version_number
             ,source_object_id
             ,source_object_type
                         )
                      VALUES
                         (
                          pa_proj_elem_ver_schedule_s.nextval
                         ,l_target_element_ver_id_tbl(i)
                         ,p_target_project_id
                         ,l_proj_element_id_tbl(i)
                         ,SYSDATE
                         ,fnd_global.user_id
                         ,SYSDATE
                         ,fnd_global.user_id
                         ,fnd_global.login_id
                         ,decode(p_calling_context,'COPY_PROJECT',           -- 3493612
                                     PA_DELIVERABLE_UTILS.GET_ADJUSTED_DATES
                                        (p_target_project_id
                                        ,l_due_date_tbl(i)
                                        ,p_delta
                                        ), l_due_date_tbl(i))
                         ,null
                         ,1
             ,p_target_project_id
             ,'PA_PROJECTS'
                         ) ;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Populating PA_OBJECT_RELATIONSHIPS ';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
          END IF;


          -- populate the object relationships table  for  STRUCTURE_TO_DELIVERABLE
          FORALL i in l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST
                    INSERT INTO PA_OBJECT_RELATIONSHIPS(
                          object_relationship_id
                         ,object_type_from
                         ,object_id_from1
                         ,object_type_to
                         ,object_id_to1
                         ,relationship_type
                         ,created_by
                         ,creation_date
                         ,last_updated_by
                         ,last_update_date
                         ,object_id_from2
                         ,object_id_to2
                         ,relationship_subtype
                         ,record_version_number
                         ,last_update_login
                         )
                      VALUES
                         (
                          pa_object_relationships_s.nextval
                         ,'PA_STRUCTURES'
                         ,l_parent_structure_version_id
                         ,'PA_DELIVERABLES'
                         ,l_target_element_ver_id_tbl(i)
                         ,'S'
                         ,fnd_global.user_id
                         ,SYSDATE
                         ,fnd_global.user_id
                         ,SYSDATE
                         ,l_parent_structure_id
                         ,l_proj_element_id_tbl(i)
                         ,'STRUCTURE_TO_DELIVERABLE'
                         ,1
                         ,fnd_global.login_id
                         ) ;


          IF nvl(l_proj_element_id_tbl.LAST,0)>0 THEN
               IF  (nvl(p_association_flag,'N') = 'Y' AND p_calling_context  = 'COPY_PROJECT' ) THEN
                         INSERT INTO PA_OBJECT_RELATIONSHIPS(
                               object_relationship_id
                              ,object_type_from
                              ,object_id_from1
                              ,object_type_to
                              ,object_id_to1
                              ,relationship_type
                              ,created_by
                              ,creation_date
                              ,last_updated_by
                              ,last_update_date
                              ,object_id_from2
                              ,object_id_to2
                              ,relationship_subtype
                              ,record_version_number
                              ,last_update_login
                              )
                         SELECT
                               pa_object_relationships_s.nextval
                              ,'PA_TASKS'
                              ,null
                              ,'PA_DELIVERABLES'
                              ,dlv2.element_version_id
                              ,'A'
                              ,fnd_global.user_id
                              ,SYSDATE
                              ,fnd_global.user_id
                              ,SYSDATE
                              ,tsk1.proj_element_id
                              ,dlv1.proj_element_id
                              ,'TASK_TO_DELIVERABLE'
                              ,1
                              ,fnd_global.login_id
                          FROM pa_proj_elements tsk1
                              ,pa_proj_elements dlv1
                              ,pa_proj_element_versions dlv2
                              ,pa_object_relationships obj
                         WHERE dlv1.project_id = p_target_project_id
                           AND dlv1.object_type = 'PA_DELIVERABLES'
                           AND dlv1.attribute15 = obj.object_id_to2
                           AND obj.relationship_type = 'A'
                           AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE'
                           AND obj.object_type_from = 'PA_TASKS'
                           AND obj.object_type_to = 'PA_DELIVERABLES'
                           AND tsk1.project_id = p_target_project_id
                           AND tsk1.attribute15 = obj.object_id_from2
                           AND tsk1.object_type = 'PA_TASKS'
                           AND dlv1.proj_element_id = dlv2.proj_element_id ;
               END IF ;
          END IF ;

          FOR i IN l_proj_element_id_tbl.FIRST..l_proj_element_id_tbl.LAST LOOP

               IF (nvl(p_association_flag,'N') = 'Y' AND p_calling_context = 'COPY_DELIVERABLES' ) THEN

                   INSERT INTO PA_OBJECT_RELATIONSHIPS(
                          object_relationship_id
                         ,object_type_from
                         ,object_id_from1
                         ,object_type_to
                         ,object_id_to1
                         ,relationship_type
                         ,created_by
                         ,creation_date
                         ,last_updated_by
                         ,last_update_date
                         ,object_id_from2
                         ,object_id_to2
                         ,relationship_subtype
                         ,record_version_number
                         ,last_update_login
                         )
                    SELECT
                          pa_object_relationships_s.nextval
                         ,'PA_TASKS'
                         ,obj.object_id_from1
                         ,'PA_DELIVERABLES'
                         ,l_target_element_ver_id_tbl(i)
                         ,'A'
                         ,fnd_global.user_id
                         ,SYSDATE
                         ,fnd_global.user_id
                         ,SYSDATE
                         ,obj.object_id_from2
                         ,l_proj_element_id_tbl(i)
                         ,'TASK_TO_DELIVERABLE'
                         ,1
                         ,fnd_global.login_id
                     FROM pa_object_relationships obj
                    WHERE obj.object_id_to2 = p_dlv_element_id_tbl(i)
                      AND obj.object_type_to = 'PA_DELIVERABLES'
                      AND obj.object_type_from = 'PA_TASKS'
                      AND obj.relationship_type = 'A'
                      AND obj.relationship_subtype = 'TASK_TO_DELIVERABLE' ;

                    END IF ;

                    IF nvl(p_dlv_attachments_flag,'N') = 'Y' THEN

                             FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS
                                 (
                                  X_from_entity_name  => 'PA_DLVR_DOC_ATTACH'
                                 ,X_from_pk1_value    => l_source_element_ver_id_tbl(i)
                                 ,X_to_entity_name    => 'PA_DLVR_DOC_ATTACH'
                                 ,X_to_pk1_value      => l_target_element_ver_id_tbl(i)
                                 ,X_created_by        => fnd_global.user_id
                                 ,X_last_update_login => fnd_global.login_id
                                 );

                             FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS
                                 (
                                  X_from_entity_name  => 'PA_DVLR_ATTACH'
                                 ,X_from_pk1_value    => l_source_element_ver_id_tbl(i)
                                 ,X_to_entity_name    => 'PA_DVLR_ATTACH'
                                 ,X_to_pk1_value      => l_target_element_ver_id_tbl(i)
                                 ,X_created_by        => fnd_global.user_id
                                 ,X_last_update_login => fnd_global.login_id
                                 );

                    END IF ;

                      -- Commented the IF clause as OKE maintains entry for both Item Based
                      -- Deliverable and Non Item Based Deliverable in there table . On the basis
                      -- of p_copy_item_details_flag the OKE api will either populate 'NULL' for
                      -- item attributes OR it will copy from source deliverable.

--                    IF ( nvl(p_item_details_flag,'N') = 'Y' OR p_calling_context = 'COPY_PROJECT') THEN

              -- 3469876 added the following check

                       -- After selective copy project , item info. should not be copied
                       -- in default for deliverable. Hence commenting the below mentioned code.

             --IF p_calling_context = 'COPY_PROJECT' then
            --  l_item_details_flag := 'Y' ;
               --      ELSE
            --  l_item_details_flag := nvl(p_item_details_flag,'N');
             --END IF ;
              -- 3469876

                             OKE_DELIVERABLE_UTILS_PUB.COPY_ITEM
                                    (p_source_project_id         => p_source_project_id
                                    ,p_target_project_id         => p_target_project_id
                                    ,p_source_deliverable_id     => l_source_element_ver_id_tbl(i)
                                    ,p_target_deliverable_id     => l_target_element_ver_id_tbl(i)
                                    ,p_target_deliverable_number => l_element_number_tbl(i)
                                    ,p_copy_item_details_flag    => nvl(p_item_details_flag,'N') -- 3469876 changed the parameter
                                    ,x_return_status             => x_return_status
                                    ,x_msg_count                 => x_msg_count
                                    ,x_msg_data                  => x_msg_data
                                    );

                              IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   RAISE Invalid_Arg_Exc_Dlv ;
                              END IF ;

 --                   END IF  ;

               IF (nvl(p_dlv_actions_flag,'N') = 'Y' OR p_calling_context = 'COPY_PROJECT') THEN

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Calling PA_ACTIONS_PUB.COPY_ACTIONS';
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
                    END IF;
                              PA_ACTIONS_PUB.COPY_ACTIONS
                                   (p_api_version         => p_api_version
                                   ,p_init_msg_list       => p_init_msg_list
                                   ,p_commit              => p_commit
                                   ,p_validate_only       => p_validate_only
                                   ,p_validation_level    => p_validation_level
                                   ,p_calling_module      => p_calling_module
                                   ,p_debug_mode          => p_debug_mode
                                   ,p_max_msg_count       => p_max_msg_count
                                   ,p_source_object_id    => l_source_proj_element_id_tbl(i)
                                   ,p_source_object_type  => 'PA_DELIVERABLES'
                                   ,p_target_object_id    => l_proj_element_id_tbl(i)
                                   ,p_target_object_type  => 'PA_DELIVERABLES'
                                   ,p_source_project_id   => p_source_project_id
                                   ,p_target_project_id   => p_target_project_id
                                   ,p_task_id             => null
                                   ,p_task_ver_id         => null
                                   ,p_carrying_out_organization_id => l_carrying_out_org_id_tbl(i)
                                   ,p_pm_source_reference => l_pm_source_reference_tbl(i)
                                   ,p_pm_source_code      => l_pm_source_code_tbl(i)
                                   ,x_return_status       => x_return_status
                                   ,x_msg_count           => x_msg_count
                                   ,x_msg_data            => x_msg_data
                                   ) ;

                              IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   RAISE Invalid_Arg_Exc_Dlv ;
                              END IF ;
               END IF ;

          END LOOP ;

     END IF ;

     --Bug # 3429393
     --If the Calling context is Copy External then
     --We have to call create associations in bulk API
     --which will associate the selected deliverables
     --automatically to the task in which context the Copy External Page was called.
     IF p_task_id IS NOT NULL AND p_task_version_id IS NOT NULL AND p_calling_context='COPY_EXTERNAL'
     THEN
     PA_DELIVERABLE_PVT.CREATE_ASSOCIATIONS_IN_BULK
          (p_api_version         => p_api_version
          ,p_init_msg_list       => p_init_msg_list
          ,p_commit              => p_commit
          ,p_validate_only       => p_validate_only
          ,p_validation_level    => p_validation_level
          ,p_calling_module      => p_calling_module
          ,p_debug_mode          => p_debug_mode
          ,p_max_msg_count       => p_max_msg_count
          ,p_element_id_tbl      => l_proj_element_id_tbl
          ,p_version_id_tbl      => l_target_element_ver_id_tbl
          ,p_element_name_tbl    => l_name_tbl
          ,p_element_number_tbl  => l_element_number_tbl
          ,p_task_or_dlv_elt_id  => p_task_id
          ,p_task_or_dlv_ver_id  => p_task_version_id
          ,p_project_id          => p_target_project_id
          ,p_task_or_dlv         => 'PA_TASKS'
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          );
     END IF;


     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE Invalid_Arg_Exc_Dlv ;
     END IF ;

     /*Stubbed Out Auto Initiate Demand on Project Approval Functionality
       Bug 3819086

     --Bug  3611598 <<Start>>

     IF p_calling_context = 'COPY_PROJECT' THEN

          OPEN  c_project_details ;
          -- 3671408 added l_project_number
          FETCH c_project_details INTO l_project_type,l_status_code,l_project_sys_status_code, l_project_number ;
          CLOSE c_project_details;

          IF p_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Project Type is :'||l_project_type ;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               pa_debug.g_err_stage:= 'Project Status Code is :'||l_status_code ;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               -- added for bug# 3671408
               pa_debug.g_err_stage:= 'Project System Status Code is :'||l_project_sys_status_code ;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
          END IF;

          --Check whether the project's system status code is Approved
          IF nvl(l_project_sys_status_code,'-99') = 'APPROVED' THEN
               --If Yes,Find Whether Workflow is enabled for the project

               IF (l_project_type IS NOT NULL AND l_status_code IS NOT NULL) THEN
                    pa_project_stus_utils.check_wf_enabled
                           (x_project_status_code => l_status_code,
                            x_project_type        => l_project_type,
                            x_project_id          => p_target_project_id,
                            x_wf_item_type        => l_item_type,
                x_wf_process          => l_wf_process,
                            x_wf_enabled_flag     => l_wf_enabled_flag,
                            x_err_code            => l_err_code
                            );
                    --Workflow is NOT coupled to changing statues.
                    -- So, the x_err_code for the aforementioned Check_Wf_Enabled
                    --- is IGNORED if x_err_code > 0.
                    IF p_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'The Error Code is ' ||l_err_code ;
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                         pa_debug.g_err_stage:= 'The Workflow Enabled Flag is ' ||l_wf_enabled_flag ;
                         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    IF (l_err_code > 0) THEN
                l_err_code := 0;
                    END IF;

                    IF l_err_code = 0 THEN
                         IF nvl(l_wf_enabled_flag,'N') <> 'Y' THEN
                              --If Workflow is not enabled then Place call to wrapper API

                              -- 3671408 retrieving segment1 value for project and passing the retrieved
                              -- value to api

                              PA_ACTIONS_PUB.RUN_ACTION_CONC_PROCESS_WRP
                              (
                               p_project_id      => p_target_project_id
                              ,p_project_number  => l_project_number    -- added for bug# 3671408
                              ,x_msg_count       => x_msg_count
                              ,x_msg_data        => x_msg_data
                              ,x_return_status   => x_return_status
                              );
                              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                                   RAISE   FND_API.G_EXC_ERROR;
                              END IF;
                         END IF;
                    END IF;
               END IF;
          END IF;
     END IF;
     --End of Changes Bug 3611598

     End of Commenting for Bug 3819086 */

     IF p_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting COPY_DELIVERABLES' ;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           pa_debug.reset_curr_function;
     END IF;

EXCEPTION
WHEN Invalid_Arg_Exc_Dlv THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'inside invalid arg exception of COPY_DELIVERABLES';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,5);
     END IF;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF ;
     RETURN;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

    FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DELIVERABLES_PVT'
                     ,p_procedure_name  => 'COPY_DELIVERABLES');

     IF p_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('COPY_DELIVERABLES: ' || g_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END COPY_DELIVERABLES ;

END PA_DELIVERABLE_PVT;

/
