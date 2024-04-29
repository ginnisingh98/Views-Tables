--------------------------------------------------------
--  DDL for Package PA_WORKPLAN_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKPLAN_ATTR_PVT" AUTHID CURRENT_USER AS
/* $Header: PAPRWPVS.pls 120.1.12010000.2 2009/07/22 12:27:59 gboomina ship $ */



-- API name		: Create_Proj_Workplan_Attrs
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_proj_element_id               IN NUMBER     Required
-- p_approval_reqd_flag            IN VARCHAR2   Required
-- p_auto_publish_flag             IN VARCHAR2   Required
-- p_approver_source_id            IN NUMBER     Required
-- p_approver_source_type          IN NUMBER     Required
-- p_default_display_lvl           IN NUMBER     Required
-- p_enable_wp_version_flag        IN VARCHAR2   Required
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
-- p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
-- p_use_task_schedule_flag        IN VARCHAR2   Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE CREATE_PROJ_WORKPLAN_ATTRS
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_approval_reqd_flag            IN VARCHAR2
  ,p_auto_publish_flag             IN VARCHAR2
  ,p_approver_source_id            IN NUMBER
  ,p_approver_source_type          IN NUMBER
  ,p_default_display_lvl           IN NUMBER
  ,p_enable_wp_version_flag        IN VARCHAR2
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2
  ,p_auto_sync_txn_date_flag       IN VARCHAR2
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
  -- gboomina bug 8586393 - start
  ,p_use_task_schedule_flag        IN  VARCHAR2  := FND_API.G_MISS_CHAR
  -- gboomina bug 8586393 - end
--bug 3325803: FP M
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


-- API name		: Update_Proj_Workplan_Attrs
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_proj_element_id               IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_approval_reqd_flag            IN VARCHAR2   Required Default = FND_API.G_MISS_NUM
-- p_auto_publish_flag             IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_default_display_lvl           IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- p_enable_wp_version_flag        IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_auto_pub_upon_creation_flag   IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_auto_sync_txn_date_flag       IN VARCHAR2   Required Default = FND_API.G_MISS_CHAR
-- p_txn_date_sync_buf_days        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
-- p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_use_task_schedule_flag        IN NUMBER     Optional
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_PROJ_WORKPLAN_ATTRS
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_proj_element_id               IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_approval_reqd_flag            IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_publish_flag             IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_default_display_lvl           IN NUMBER     := FND_API.G_MISS_NUM /* Added for Progress impact bug 3420093 */
  ,p_enable_wp_version_flag        IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_pub_upon_creation_flag   IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_auto_sync_txn_date_flag       IN VARCHAR2   := FND_API.G_MISS_CHAR /* Added for Progress impact bug 3420093 */
  ,p_txn_date_sync_buf_days        IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_version_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_phase_version_id      IN NUMBER     := FND_API.G_MISS_NUM
--bug 3325803: FP M
  ,p_allow_lowest_tsk_dep_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_schedule_third_party_flag     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_third_party_schedule_code     IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_auto_rollup_subproj_flag      IN VARCHAR2   := FND_API.G_MISS_CHAR
--bug 3325803: FP M
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  -- gboomina bug 8586393 - start
  ,p_use_task_schedule_flag        IN  VARCHAR2  := FND_API.G_MISS_CHAR
  -- gboomina bug 8586393 - end
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


-- API name		: Update_Structure_Name
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_proj_element_id               IN NUMBER     Required
-- p_structure_name                IN VARCHAR2   Required
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_STRUCTURE_NAME
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_proj_element_id               IN NUMBER
  ,p_structure_name                IN VARCHAR2
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


-- API name		: Delete_Proj_Workplan_Attrs
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_proj_element_id               IN NUMBER     Required
-- p_record_version_number         IN NUMBER     Required Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE DELETE_PROJ_WORKPLAN_ATTRS
(  p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END PA_WORKPLAN_ATTR_PVT;

/
