--------------------------------------------------------
--  DDL for Package PA_PROJECT_STRUCTURE_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_STRUCTURE_PVT1" AUTHID CURRENT_USER as
/*$Header: PAXSTCVS.pls 120.1 2005/08/19 17:20:08 mwasowic noship $*/

   TYPE PA_PUBLISH_ERR_TBL_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


-- API name                      : Create_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id	 IN	 NUMBER
--   p_structure_number	 IN	 VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name	 IN	 VARCHAR2
--   p_calling_flag	 IN	 VARCHAR2 := 'WORKPLAN'
--   p_structure_description	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_structure_id	 OUT	 NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_calling_flag                      IN  VARCHAR2 := 'WORKPLAN'
   ,p_structure_description             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_approval_reqd_flag            IN VARCHAR2 := 'N'
   ,p_auto_publish_flag             IN VARCHAR2 := 'N'
   ,p_approver_source_id            IN NUMBER   := FND_API.G_MISS_NUM
   ,p_approver_source_type          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_default_display_lvl           IN NUMBER   := 0
   ,p_enable_wp_version_flag        IN VARCHAR2 := 'N'
   ,p_auto_pub_upon_creation_flag   IN VARCHAR2 := 'N'
   ,p_auto_sync_txn_date_flag       IN VARCHAR2 := 'N'
   ,p_txn_date_sync_buf_days        IN NUMBER   := FND_API.G_MISS_NUM
   ,p_lifecycle_version_id          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_current_phase_version_id      IN NUMBER   := FND_API.G_MISS_NUM
   ,p_progress_cycle_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_wq_enable_flag                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_remain_effort_enable_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_percent_comp_enable_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_next_progress_update_date     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_action_set_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_weight_basis_code     IN VARCHAR2 := 'DURATION'
   ,x_structure_id                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Create_Structure_Version
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id                      IN  NUMBER
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_structure_version_id  OUT  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_structure_version_id              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Create_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id	IN	NUMBER
--   p_structure_version_name	IN	VARCHAR2
--   p_structure_version_desc	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date	IN	DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag	IN	VARCHAR2 := 'N'
--   p_published_flag	IN	VARCHAR2 := 'N'
--   p_locked_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag	IN	VARCHAR2 := 'N'
--   p_baseline_original_flag	IN	VARCHAR2 := 'N'
--   x_pev_structure_id	OUT	NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_desc            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag         IN  VARCHAR2 := 'N'
   ,p_published_flag                    IN  VARCHAR2 := 'N'
   ,p_locked_status_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag             IN  VARCHAR2 := 'N'
   ,p_baseline_original_flag	         IN  VARCHAR2 := 'N'
   ,p_change_reason_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_pev_structure_id                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Update_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id	 IN	 NUMBER
--   p_structure_number	 IN	 VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name	 IN	 VARCHAR2
--   p_description	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15	 IN	 VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number  IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_description                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Update_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pev_structure_id	      IN 	NUMBER
--   p_structure_version_name	IN	VARCHAR2
--   p_structure_version_desc	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date	IN	DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_locked_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_original_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number  IN    NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_pev_structure_id	      IN 	NUMBER
   ,p_structure_version_name	IN	VARCHAR2
   ,p_structure_version_desc	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date	IN	DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_locked_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_original_flag	IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_change_reason_code        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number  IN    NUMBER
    --FP M changes bug 3301192
   ,p_current_working_ver_flag          IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --end FP M changes bug 3301192
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Delete_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id                      IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



-- API name                      : Delete_Structure_Version
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Delete_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pev_structure_id                  IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_pev_structure_id                  IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



-- API name                      : Publish_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_responsibility_id                 IN  NUMBER      := 0
--   p_structure_version_id              IN  NUMBER
--   p_publish_structure_ver_name        IN  VARCHAR2
--   p_structure_ver_desc                IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_original_baseline_flag            IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_current_baseline_flag             IN  VARCHAR2	   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_published_struct_ver_id           OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--

    --maansari
    TYPE tasks_versions_record IS RECORD
        (src_task_version_id		   NUMBER		    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         src_parent_task_version_id	   NUMBER		    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         src_version_status		       VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         copy_flag                     VARCHAR2(1)      := 'Y'
      );
    TYPE l_src_task_versions IS TABLE OF tasks_versions_record
     	INDEX BY BINARY_INTEGER;
    l_src_tasks_versions_tbl  l_src_task_versions;
    --maansari


  procedure Publish_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_responsibility_id                 IN  NUMBER      := 0
   ,p_user_id                           IN  NUMBER      := NULL
   ,p_structure_version_id              IN  NUMBER
   ,p_publish_structure_ver_name        IN  VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_ver_desc                IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_original_baseline_flag            IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_current_baseline_flag             IN  VARCHAR2	  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_pub_prog_flag 			IN  VARCHAR2 DEFAULT 'Y'  -- Added for FP_M changes
   ,x_published_struct_ver_id           OUT  NOCOPY NUMBER	 --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : UPDATE_LATEST_PUB_LINKS
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_orig_project_id                   IN  NUMBER
--   p_orig_structure_id                 IN  NUMBER
--   p_orig_struc_ver_id                 IN  NUMBER
--   p_orig_task_ver_id                  IN  NUMBER
--   p_new_project_id                    IN  NUMBER
--   p_new_structure_id                  IN  NUMBER
--   p_new_struc_ver_id                  IN  NUMBER
--   p_new_task_ver_id                   IN  NUMBER
--   x_return_status	 OUT 	 VARCHAR2
--   x_msg_count	 OUT 	 NUMBER
--   x_msg_data	 OUT 	 VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure UPDATE_LATEST_PUB_LINKS
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_orig_project_id                   IN  NUMBER
   ,p_orig_structure_id                 IN  NUMBER
   ,p_orig_struc_ver_id                 IN  NUMBER
   ,p_orig_task_ver_id                  IN  NUMBER
   ,p_new_project_id                    IN  NUMBER
   ,p_new_structure_id                  IN  NUMBER
   ,p_new_struc_ver_id                  IN  NUMBER
   ,p_new_task_ver_id                   IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


PROCEDURE COPY_STRUCTURE_VERSION
( p_commit                        IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2   := 'N'
 ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,p_new_struct_ver_name           IN VARCHAR2
 ,p_new_struct_ver_desc           IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,x_new_struct_ver_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE COPY_STRUCTURE
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_src_project_id                IN NUMBER
 ,p_dest_project_id               IN NUMBER
-- anlee
-- Dates changes
 ,p_delta                         IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- End of changes
 ,p_copy_task_flag                IN VARCHAR2    := 'Y'
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE BASELINE_STRUCTURE_VERSION
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

PROCEDURE SPLIT_WORKPLAN
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                    IN NUMBER
 ,p_structure_name                IN VARCHAR2
 ,p_structure_number              IN VARCHAR2
 ,p_description                   IN VARCHAR2
 ,x_structure_id                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_structure_version_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

  procedure SUBMIT_WORKPLAN
  (
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_responsibility_id                 IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure CHANGE_WORKPLAN_STATUS
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_false,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
   p_project_id                  IN     NUMBER := NULL,
   p_structure_version_id        IN     NUMBER := NULL,
   p_status_code                 IN     VARCHAR2 := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
  );

  PROCEDURE rework_workplan
  (
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : update_structures_setup_attr
-- Type                             : Update API
-- Pre-reqs                       : None
-- Return Value                 : Update_structures_setup_attr
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_workplan_enabled_flag IN VARCHAR2
--  p_financial_enabled_flag IN VARCHAR2
--  p_sharing_enabled_flag IN VARCHAR2
--  x_return_status OUT VARCHAR2
--  x_msg_count OUT NUMBER
--  x_msg_data  OUT VARCHAR2
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  PROCEDURE update_structures_setup_old
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id IN NUMBER
    ,p_workplan_enabled_flag IN VARCHAR2
    ,p_financial_enabled_flag IN VARCHAR2
    ,p_sharing_enabled_flag IN VARCHAR2
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE update_workplan_versioning
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_proj_element_id  IN  NUMBER
    ,p_enable_wp_version_flag IN VARCHAR2
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE update_wp_calendar
  (
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id       IN  NUMBER
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API to update the workplan caledar for all the projects affeted by the
-- given calendar - msundare

  PROCEDURE update_all_wp_calendar
  (
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE RECALC_STRUC_VER_DURATION(
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id IN NUMBER
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  procedure Delete_Struc_Ver_Wo_Val
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  procedure Generate_Error_Page
  (
    p_api_version                      IN  NUMBER     := 1.0
   ,p_commit                           IN  VARCHAR2   := 'N'
   ,p_calling_module                   IN  VARCHAR2   := 'SELF_SERVICE'
   ,p_debug_mode                       IN  VARCHAR2   := 'N'
   ,p_max_msg_count                    IN  NUMBER     := NULL
   ,p_structure_version_id             IN  NUMBER
   ,p_error_tbl                        IN  PA_PUBLISH_ERR_TBL_TYPE
   ,x_page_content_id                  OUT NOCOPY NUMBER
   ,x_return_status                    OUT NOCOPY VARCHAR2
   ,x_msg_count                        OUT NOCOPY NUMBER
   ,x_msg_data                         OUT NOCOPY VARCHAR2
  );


  PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2,
                                   p_clob    IN OUT NOCOPY CLOB
  );

PROCEDURE RECALC_FIN_TASK_WEIGHTS
( p_structure_version_id IN NUMBER
 ,p_project_id           IN NUMBER
 ,x_msg_count            OUT NOCOPY NUMBER
 ,x_msg_data             OUT NOCOPY VARCHAR2
 ,x_return_status        OUT NOCOPY VARCHAR2 );


FUNCTION copy_task_version( p_structure_version_id NUMBER, p_task_version_id NUMBER ) RETURN VARCHAR2;


-- Performance changes : added this API. It is bulk version of COPY_STRUCTURE_VERSION

PROCEDURE COPY_STRUCTURE_VERSION_BULK
( p_commit                        IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2   := 'N'
 ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,p_new_struct_ver_name           IN VARCHAR2
 ,p_new_struct_ver_desc           IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,x_new_struct_ver_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
;

procedure update_sch_dirty_flag(
     p_project_id           IN NUMBER := NULL
    ,p_structure_version_id IN NUMBER
    ,p_dirty_flag           IN VARCHAR2 := 'N'
    ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

  PROCEDURE update_structures_setup_attr
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id IN NUMBER
    ,p_workplan_enabled_flag IN VARCHAR2
    ,p_financial_enabled_flag IN VARCHAR2
    ,p_sharing_enabled_flag IN VARCHAR2
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

end PA_PROJECT_STRUCTURE_PVT1;

 

/
