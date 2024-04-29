--------------------------------------------------------
--  DDL for Package PA_PROJECT_STRUCTURE_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_STRUCTURE_PUB1" AUTHID CURRENT_USER as
/*$Header: PAXSTCPS.pls 120.4 2007/07/10 05:57:34 kkorada ship $*/

-- Global variable to store user_id
Global_User_Id   NUMBER := NULL;

FUNCTION CHECK_ACTION_ALLOWED
( p_action           IN VARCHAR2
 ,p_version_id       IN NUMBER
 ,p_status_code      IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE SetGlobalUserId ( p_user_id NUMBER );

FUNCTION GetGlobalUserId RETURN NUMBER;


-- API name                      : Create_Structure
-- Type                          : Public Procedure
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
--LDENG
   ,p_lifecycle_version_id          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_current_phase_version_id      IN NUMBER   := FND_API.G_MISS_NUM
--END LDENG
   ,p_progress_cycle_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_wq_enable_flag                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_remain_effort_enable_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_percent_comp_enable_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_next_progress_update_date     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_action_set_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_structure_id                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Create_Structure_Version
-- Type                          : Public Procedure
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
-- Type                          : Public Procedure
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
--  21-JUN-02   HSIU             Added change_reason_code
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
-- Type                          : Public Procedure
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
-- Type                          : Public Procedure
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
--   p_current_working_ver_flag          IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
   ,p_change_reason_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number  IN    NUMBER
    --FP M changes bug 3301192
   ,p_current_working_ver_flag          IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --end FP M changes bug 3301192
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Delete_Structure_Version
-- Type                          : Public Procedure
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
   ,p_calling_from                      IN  VARCHAR2    := 'XYZ' ---Added for bug 6023347
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



-- API name                      : Publish_Structure
-- Type                          : Public Procedure
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
   ,p_pub_prog_flag                     IN  VARCHAR2 DEFAULT 'Y'  -- Added for FP_M changes 3420093
   ,x_published_struct_ver_id           OUT  NOCOPY NUMBER	 --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Copy_Structure
-- Type                          : Public Procedure
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
--   p_src_project_id                    IN  NUMBER
--   p_dest_project_id                   IN  NUMBER
--   p_delta                             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Copy_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_src_project_id                    IN  NUMBER
   ,p_dest_project_id                   IN  NUMBER
-- anlee
-- Dates changes
   ,p_delta                             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- End of changes
   ,p_copy_task_flag                    IN  VARCHAR2    := 'Y'
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Copy_Structure_Version
-- Type                          : Public Procedure
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
--   p_new_struct_ver_name               IN  VARCHAR2
--   p_new_struct_ver_desc               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_new_struct_ver_id                 OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Copy_Structure_Version
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
   ,p_new_struct_ver_name               IN  VARCHAR2
   ,p_new_struct_ver_desc               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_change_reason_code                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_new_struct_ver_id                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
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
    --FP M changes bug 3301192
--    p_deliverables_enabled_flag       IN VARCHAR2
--    p_sharing_option_code             IN VARCHAR2
    --End FP M changes bug 3301192
--  x_return_status OUT VARCHAR2
--  x_msg_count OUT NUMBER
--  x_msg_data  OUT VARCHAR2
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
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
    ,p_workplan_enabled_flag           IN VARCHAR2
    ,p_financial_enabled_flag          IN VARCHAR2
    ,p_sharing_enabled_flag            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

  PROCEDURE update_workplan_versioning
  ( p_api_version      IN  NUMBER     := 1.0
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

-- API name                      : Delete_Working_Struc_Ver
-- Type                          : Public Procedure
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
--  17-DEC-02   HSIU             -Created
--
--


  procedure Delete_Working_Struc_Ver
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

-- API name                      : Enable_Financial_Structure
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   p_proj_element_id                   IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--  02-JAN-04      Rakesh Raghavan        - Created
--  04-MAR-2004    Rakesh Raghavan        - Modified for Progress Management Changes. Bug # 3420093.
--
--

 procedure ENABLE_FINANCIAL_STRUCTURE
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_proj_element_id                   IN  NUMBER
   ,p_approval_reqd_flag                IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_publish_flag                 IN  VARCHAR2 DEFAULT 'N'
   ,p_approver_source_id                IN  NUMBER DEFAULT NULL
   ,p_approver_source_type              IN  NUMBER DEFAULT NULL
   ,p_default_display_lvl               IN  NUMBER DEFAULT 0
   ,p_enable_wp_version_flag            IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_pub_upon_creation_flag       IN  VARCHAR2 DEFAULT 'N'
   ,p_auto_sync_txn_date_flag           IN  VARCHAR2 DEFAULT 'N'
   ,p_txn_date_sync_buf_days            IN  NUMBER DEFAULT NULL
   ,p_lifecycle_version_id              IN  NUMBER DEFAULT NULL
   ,p_current_phase_version_id          IN  NUMBER DEFAULT NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Disable_Financial_Structure
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--  02-JAN-04     Rakesh Raghavan        - Created
--  04-MAR-2004   Rakesh Raghavan        - Modified for Progress Management Changes. Bug # 3420093.
--
--

 procedure DISABLE_FINANCIAL_STRUCTURE
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Clear_Financial_Flag
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   p_task_version_id                   IN  NUMBER
--   p_structure_version_id              IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--  02-JAN-04   Rakesh Raghavan             - Created
--
--

 procedure CLEAR_FINANCIAL_FLAG
  (
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : Update_Sch_Dirty_Flag
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id                        IN  NUMBER
--   p_structure_version_id              IN  NUMBER
--   p_dirty_flag                        IN  VARCHAR2
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--  23-MAR-04   Srikanth Mukka           - Created
--
--
PROCEDURE Update_Sch_Dirty_Flag(
    p_api_version                       IN  NUMBER   := 1.0
   ,p_init_msg_list                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2 := FND_API.G_TRUE
   ,p_validation_level                  IN  NUMBER   := 100
   ,p_calling_module                    IN  VARCHAR2 := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2 := 'N'
   ,p_max_msg_count                     IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_dirty_flag                        IN  VARCHAR2 := 'N'
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
--
--  History
--  03-May-06   Ram Namburi             - Created
--  Purpose:
--     This is used to enable the program on a project. In forms we are not allowing the user to create a link
--     all the times, and if the program is not enabled then we enable that on the fly so the link creation is
--     possible. This is needed otherwise users need to go to SS page to enable program on the project and come
--     back to forms to create links. In order to remove this dependency we are now calling this API from forms
--     as we couldnt directly call the update_structures_setup_attr.
--     This wrapper will call the update_structures_setup_attr with other parameters.
--
PROCEDURE enable_program_flag(
    p_project_id                       IN  NUMBER
   ,x_return_status                    OUT NOCOPY VARCHAR2
   ,x_msg_count                        OUT NOCOPY NUMBER
   ,x_msg_data                         OUT NOCOPY VARCHAR2

                             );

-- API name                      : 	DELETE_PUBLISHED_STRUCTURE_VERSION
-- Tracking Bug                  : 4925192
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_api_version                      IN  NUMBER      := 1.0
--   ,p_init_msg_list                    IN  VARCHAR2    := FND_API.G_TRUE
--   ,p_project_id                       IN  NUMBER
--   ,p_structure_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
--   ,p_record_version_number_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE
--   ,x_return_status                    OUT  NOCOPY VARCHAR2
--   ,x_msg_count                        OUT  NOCOPY NUMBER
--   ,x_msg_data                         OUT  NOCOPY VARCHAR2
--
--  History
--
--  20-Oct-06   Ram Namburi             -Created
--
--  Purpose:
--
--  This API will delete a published structure version
--    1. It calls the delete validation API to see if deletion is okay.
--    2. Then it calls the Progress API to roll up the progress to the next higher
--       later versions
--    3. Then it calls the actual delete API.
--


procedure DELETE_PUBLISHED_STRUCTURE_VER
  (
    p_api_version                      IN  NUMBER      := 1.0
   ,p_init_msg_list                    IN  VARCHAR2    := FND_API.G_TRUE
   ,p_project_id                       IN  NUMBER
   ,p_structure_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
   ,p_record_version_number_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE
   ,x_return_status                    OUT  NOCOPY VARCHAR2
   ,x_msg_count                        OUT  NOCOPY NUMBER
   ,x_msg_data                         OUT  NOCOPY VARCHAR2
  );


end PA_PROJECT_STRUCTURE_PUB1;

/
