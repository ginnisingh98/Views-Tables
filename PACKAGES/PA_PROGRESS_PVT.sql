--------------------------------------------------------
--  DDL for Package PA_PROGRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_PVT" AUTHID CURRENT_USER as
/* $Header: PAPCPVTS.pls 120.4 2007/02/06 10:21:27 dthakker ship $ */

-- Start of comments
--      API name        : ROLLUP_PROGRESS_PVT
--      Type            : Public
--      Pre-reqs        : For Program Rollup, the sub project buckets should be populated.
--      Purpose         : Rolls up the structure
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_process_whole_tree            To indicate if whole tree rollup is not required. It will
--                                              do just 2 level rollup if N
--              p_structure_version_id          Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_rollup_entire_wbs             To indicate if it requires the whole structure rollup, in this
--                                              case it will ignore the passed object and starts with the lowest
--                                              task
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093
-- End of comments

PROCEDURE ROLLUP_PROGRESS_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_calling_mode             IN      VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 4097710
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_progress_mode                        IN      VARCHAR2        := 'FUTURE'
,p_project_id                           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_type                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_object_id                            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_object_version_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_task_version_id                      IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_as_of_date                           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
,p_lowest_level_task            IN      VARCHAR2        := 'N'
,p_process_whole_tree           IN      VARCHAR2        := 'Y'
,p_structure_version_id         IN      NUMBER
,p_structure_type                       IN      VARCHAR2        := 'WORKPLAN'
,p_fin_rollup_method            IN      VARCHAR2        := 'COST'
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,p_rollup_entire_wbs            IN      VARCHAR2        := 'N'
,p_task_version_id_tbl                  IN      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() -- Bug 4218507
,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --maansari7/18  to be passed form apply lp progress to select regular planned amounts to send to schduling api for percent comnplete and earned value calculations.
,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, 3951024
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start of comments
--      API name        : UPDATE_ROLLUP_PROGRESS_PVT
--      Type            : Private
--      Pre-reqs        : ROLLUP_PROGRESS_PVT shd have been called.
--      Purpose         : Updates the Rolled up data
--      Parameters Desc :
--              P_OBJECT_TYPE                   Possible values PA_ASSIGNMENTS, PA_DELIVERABLES, PA_TASKS
--              P_OBJECT_ID                     For assignments, pass resource_assignment_id, otherwise
--                                              proj_element_id of the deliverable and task
--              p_object_version_id             For Assignments, pass task_version_id, otherwise
--                                              element_version_id of the deliverable and task
--              p_task_version_id               For tasks, assignments, deliverables pass the task version id
--                                              , for struture pass null
--              p_lowest_level_task             Does not seem to be required
--              p_structure_version_id      Structure version id of the publsihed or working structure version
--              p_structure_type                Possible values WORKPLAN, FINANCIAL
--              p_fin_rollup_method             Possible values are COST, EFFORT
--              p_wp_rollup_method              Possible values are COST, EFFORT, MANUAL, DURATION
--              p_published_structure       To indicate if the passed structure version is published
--      History         : 17-MAR-04  amksingh   Rewritten For FPM Development Tracking Bug 3420093
-- End of comments

PROCEDURE UPDATE_ROLLUP_PROGRESS_PVT(
  p_api_version             IN      NUMBER          :=1.0
 ,p_init_msg_list                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_commit                              IN      VARCHAR2                :=FND_API.G_FALSE
 ,p_validate_only                       IN      VARCHAR2                :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                      IN      VARCHAR2                :='SELF_SERVICE'
 ,p_calling_mode            IN      VARCHAR2                :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 4097710
 ,p_debug_mode                          IN      VARCHAR2                :='N'
 ,p_max_msg_count                       IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id              IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                          IN      DATE                    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_rollup_table                        IN      PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE
 ,p_lowest_level_task           IN      VARCHAR2                := 'N'
 ,p_task_version_id         IN      NUMBER
 ,p_structure_version_id                IN      NUMBER
 ,p_structure_type                      IN      VARCHAR2                := 'WORKPLAN'
 ,p_fin_rollup_method           IN      VARCHAR2                := 'COST'
 ,p_wp_rollup_method            IN      VARCHAR2                := 'COST'
 ,p_published_structure         IN      VARCHAR2
 ,p_rollup_entire_wbs                   IN      VARCHAR2        := 'N' -- FPM Dev CR 7
 ,p_working_wp_prog_flag                 IN      VARCHAR2        := 'N'  --bug 3829341
 ,p_upd_new_elem_ver_id_flag             IN      VARCHAR2        := 'Y'  -- rtarway, for BUG 3951024
 ,p_progress_mode           IN  VARCHAR2        := 'FUTURE'  -- 4091457
 ,x_return_status                       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                           OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE ROLLUP_FUTURE_PROGRESS_PVT(
 p_project_id              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,P_OBJECT_TYPE            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_OBJECT_ID              IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_object_version_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_lowest_level_task      IN VARCHAR2 := 'N'
 ,p_calling_module     IN VARCHAR2  :='SELF_SERVICE'
 ,p_calling_mode       IN VARCHAR2        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 4097710
 ,p_structure_type         IN   VARCHAR2        := 'WORKPLAN'
 ,p_structure_version_id   IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_rollup_method      IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_wp_rollup_method       IN   VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_rollup_entire_wbs      IN   VARCHAR2        := 'N' -- Bug 3606627
 ,x_return_status           OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE program_rollup_pvt(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_as_of_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_structure_type              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_structure_ver_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start of comments
--      API name        : ASGN_DLV_TO_TASK_ROLLUP_PVT
--      Type            : Private
--      Pre-reqs        : None.
--      Purpose         : This API is intdended to be called for Assignment, Deliverables in Task Progress Details page when user clicks Recalculate button
--                      : This does partial rollup of working progress records
--      History         : 15-JUNE-04  amksingh   Rewritten For FPM Development Bug 3614828
-- End of comments

PROCEDURE ASGN_DLV_TO_TASK_ROLLUP_PVT(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_FALSE -- Since it is a private API so false
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id                           IN      NUMBER
,p_task_id              IN      NUMBER
,p_task_version_id                      IN      NUMBER
,p_as_of_date                           IN      DATE
,p_structure_version_id                 IN      NUMBER
,p_wp_rollup_method                     IN      VARCHAR2        := 'COST'
,x_return_status                        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

 --bug 3935699
PROCEDURE convert_task_prog_to_assgn
(
 p_api_version                          IN      NUMBER          :=1.0
,p_init_msg_list                        IN      VARCHAR2        :=FND_API.G_FALSE -- Since it is a private API so false
,p_commit                               IN      VARCHAR2        :=FND_API.G_FALSE
,p_validate_only                        IN      VARCHAR2        :=FND_API.G_TRUE
,p_validation_level                     IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
,p_calling_module                       IN      VARCHAR2        :='SELF_SERVICE'
,p_debug_mode                           IN      VARCHAR2        :='N'
,p_max_msg_count                        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_resource_list_mem_id         IN      NUMBER
,p_project_id               IN      NUMBER
,p_task_id              IN      NUMBER
,p_structure_version_id         IN      NUMBER
,p_as_of_date               IN      DATE -- Bug 3958686
,p_action               IN      VARCHAR2 -- Bug 3958686
,p_subprj_actual_exists         IN      VARCHAR2 := 'N' -- Bug 4490532
,p_object_version_id            IN      NUMBER := null -- Bug 4490532
,x_return_status            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

--bug 4046422
/*=============================================================================
 This is a private api that copies progress/actuals from one workplan version
 to another with in the project. Functionally this is called to copy progress
 from last published version while publishing a new version

 p_calling_context will have values WP_PROGRESS and WP_APPLY_PROGRESS_TO_WORKING.
==============================================================================*/

PROCEDURE copy_actuals_for_workplan(
           p_calling_context            IN   VARCHAR2 DEFAULT 'WP_PROGRESS'
          ,p_project_id                 IN   pa_projects_all.project_id%TYPE
          ,p_source_struct_ver_id       IN   pa_proj_element_versions.element_version_id%TYPE
          ,p_target_struct_ver_id       IN   pa_proj_element_versions.element_version_id%TYPE
          ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Bug 4575855 : Added rollup_prog_from_subprojs
PROCEDURE ROLLUP_PROG_FROM_SUBPROJS(
  p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_commit                      IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module              IN      VARCHAR2        :='SELF_SERVICE'
 ,p_debug_mode                  IN      VARCHAR2        :='N'
 ,p_max_msg_count               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,x_return_status               OUT     NOCOPY VARCHAR2 -- 4565506 Added while merging
 ,x_msg_count                   OUT     NOCOPY NUMBER   -- 4565506 Added while merging
 ,x_msg_data                    OUT     NOCOPY VARCHAR2 -- 4565506 Added while merging
);

--Added following procedure for MRup3 merge
PROCEDURE UPD_PROG_RECS_STR_DELETE(p_project_id         IN  NUMBER,
                                   p_str_ver_id_to_del  IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2);

end PA_PROGRESS_PVT;

/
