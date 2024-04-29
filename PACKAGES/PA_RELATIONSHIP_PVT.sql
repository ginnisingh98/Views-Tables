--------------------------------------------------------
--  DDL for Package PA_RELATIONSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RELATIONSHIP_PVT" AUTHID CURRENT_USER as
/*$Header: PAXRELVS.pls 120.1 2005/08/19 17:19:14 mwasowic noship $*/

-- API name                      : Create_Relationship
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
--   p_project_id_from                   IN  NUMBER
--   p_structure_id_from                 IN  NUMBER
--   p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id_to                     IN  NUMBER
--   p_structure_id_to                   IN  NUMBER
--   p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_type                    IN  VARCHAR2
--   p_initiating_element                IN  VARCHAR2
--   p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
--   p_relationship_type                 IN  VARCHAR2
--   p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_object_relationship_id            OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_from                   IN  NUMBER
   ,p_structure_id_from                 IN  NUMBER
   ,p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_to                     IN  NUMBER
   ,p_structure_id_to                   IN  NUMBER
   ,p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_type                    IN  VARCHAR2
   ,p_initiating_element                IN  VARCHAR2
   ,p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
   ,p_relationship_type                 IN  VARCHAR2
   ,p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_weighting_percentage              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_object_relationship_id            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



-- API name                      : Update_Relationship
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
--   p_object_relationship_id            IN  NUMBER
--   p_project_id_from                   IN  NUMBER
--   p_structure_id_from                 IN  NUMBER
--   p_structure_version_id_from         IN  NUMBER
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id_to                     IN  NUMBER
--   p_structure_id_to                   IN  NUMBER
--   p_structure_version_id_to           IN  NUMBER
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_relationship_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_project_id_from                   IN  NUMBER
   ,p_structure_id_from                 IN  NUMBER
   ,p_structure_version_id_from         IN  NUMBER
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_to                     IN  NUMBER
   ,p_structure_id_to                   IN  NUMBER
   ,p_structure_version_id_to           IN  NUMBER
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_relationship_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_weighting_percentage              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Delete_Relationship
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
--   p_object_relationship_id            IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : Create_Dependency
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
--   p_src_proj_id		         IN  NUMBER      := NULL
--   p_src_task_ver_id	                 IN  NUMBER      := NULL
--   p_dest_proj_id		         IN  NUMBER      := NULL
--   P_dest_task_id		         IN  NUMBER      := NULL
--   P_type		                 IN  VARCHAR2    := 'FS'
--   P_lag_days		                 IN  NUMBER      := 0
--   p_comments		                 IN  VARCHAR2	 := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--


  procedure Create_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_src_proj_id                       IN  NUMBER      := NULL
   ,p_src_task_ver_id                   IN  NUMBER      := NULL
   ,p_dest_proj_id                      IN  NUMBER      := NULL
   ,p_dest_task_ver_id                  IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := 'FS'
   ,p_lag_days                          IN  NUMBER      := 0
   ,p_comments                          IN  VARCHAR2    := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Update_Dependency
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
--   p_task_version_id                   IN  NUMBER      := NULL
--   p_type                              IN  VARCHAR2    := NULL
--   p_lag_days                          IN  NUMBER      := NULL
--   p_comments                          IN  VARCHAR2    := NULL
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Update_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER      := NULL
   ,p_src_task_version_id               IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := NULL
   ,p_lag_days                          IN  NUMBER      := NULL
   ,p_comments                          IN  VARCHAR2    := NULL
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : Delete_Dependency
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
--   p_object_relationship_id            IN  NUMBER      := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Delete_Dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER      := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- Added for FP_M changes 3305199
  Procedure Copy_Intra_Dependency (
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /*	P_Source_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
  /*    P_Destin_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
	P_Source_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	P_Destin_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
        P_source_struc_ver_id     IN      NUMBER := NULL,
        p_dest_struc_ver_id       IN      NUMBER := NULL,
	X_Return_Status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Msg_Count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_Msg_Data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  Procedure Copy_Inter_Project_Dependency (
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /*	P_Source_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
  /*    P_Destin_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
	P_Source_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	P_Destin_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	X_Return_Status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Msg_Count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_Msg_Data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  Procedure Publish_Inter_Proj_Dep (
	P_Publishing_Struc_Ver_ID   IN     NUMBER,
	P_Previous_Pub_Struc_Ver_ID IN     NUMBER,
	P_Published_Struc_Ver_ID    IN     NUMBER,
	X_Return_Status             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Msg_Count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_Msg_Data                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- End of FP_M changes
--
-- API name                      : Create_Subproject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_api_version                 IN   NUMBER      :=1.0
-- p_init_msg_list	         IN   VARCHAR2	:=FND_API.G_TRUE
-- p_validate_only	         IN   VARCHAR2	:=FND_API.G_TRUE
-- p_validation_level            IN   NUMBER      :=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module              IN   VARCHAR2	:='SELF_SERVICE'
-- p_commit	                 IN   VARCHAR2	:=FND_API.G_FALSE
-- p_debug_mode	                 IN   VARCHAR2	:='N'
-- p_max_msg_count               IN   NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_proj_id                 IN   pa_projects_all.project_id%type
-- p_task_ver_id                 IN   pa_proj_element_versions.element_version_id%type
-- p_dest_proj_id                IN   pa_projects_all.project_id%type
-- p_dest_proj_name              IN   pa_projects_all.name%type
-- p_comment                     IN   pa_object_relationships.comments%type
-- x_return_status               OUT  VARCHAR2
-- x_msg_count                   OUT  NUMBER
-- x_msg_data                    OUT  VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
--
Procedure Create_Subproject_Association(p_api_version	   IN	NUMBER	        :=1.0,
                                        p_init_msg_list	   IN	VARCHAR2	:=FND_API.G_TRUE,
                                        p_validate_only	   IN	VARCHAR2	:=FND_API.G_TRUE,
--                                        p_validation_level IN	NUMBER	        :=FND_API.G_VALID_LEVEL_FULL,
                                        p_validation_level IN  VARCHAR2         := 100,
                                        p_calling_module   IN	VARCHAR2	:='SELF_SERVICE',
                                        p_commit	   IN	VARCHAR2	:=FND_API.G_FALSE,
                                        p_debug_mode	   IN	VARCHAR2	:='N',
                                        p_max_msg_count	   IN	NUMBER	        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_proj_id      IN   pa_projects_all.project_id%type,
                                        p_task_ver_id      IN   pa_proj_element_versions.element_version_id%type,
                                        p_dest_proj_id     IN   pa_projects_all.project_id%type,
                                        p_dest_proj_name   IN   pa_projects_all.name%type,
                                        p_comment          IN   pa_object_relationships.comments%type,
                                        x_return_status    OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count        OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data         OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
-- API name                      : Create_Subproject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_proj_id                 IN  NUMBER
-- p_src_struc_wp_or_fin         IN  VARCHAR2
-- p_src_struc_elem_id           IN  NUMBER
-- p_src_struc_elem_ver_id       IN  NUMBER
-- p_dest_proj_id                IN  NUMBER
-- p_dest_struc_elem_id          IN  NUMBER
-- p_dest_struc_elem_ver_id      IN  NUMBER
-- p_src_task_elem_id            IN  NUMBER
-- p_src_task_elem_ver_id        IN  NUMBER
-- p_lnk_task_name_number        IN  NUMBER
-- p_relationship_type           IN VARCHAR2
-- x_lnk_task_elem_id            OUT NUMBER
-- x_lnk_task_elem_ver_id        OUT NUMBER
-- x_object_relationship_id      OUT NUMBER
-- x_pev_schedule_id             OUT NUMBER
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
/*PROCEDURE Insert_Subproject_Association(p_init_msg_list            IN  VARCHAR2    := FND_API.G_TRUE
                             ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
                             ,p_validate_only           IN  VARCHAR2    := FND_API.G_TRUE
                             ,p_validation_level        IN  VARCHAR2    := 100
                             ,p_calling_module          IN  VARCHAR2    := 'SELF_SERVICE'
                             ,p_debug_mode              IN  VARCHAR2    := 'N'
                             ,p_max_msg_count           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                             ,p_src_proj_id             IN  NUMBER
                             ,p_src_struc_wp_or_fin     IN  VARCHAR2
                             ,p_src_struc_elem_id       IN  NUMBER
                             ,p_src_struc_elem_ver_id   IN  NUMBER
                             ,p_dest_proj_id            IN  NUMBER
                             ,p_dest_struc_elem_id      IN  NUMBER
                             ,p_dest_struc_elem_ver_id  IN  NUMBER
                             ,p_src_task_elem_id        IN  NUMBER
                             ,p_src_task_elem_ver_id    IN  NUMBER
                             ,p_lnk_task_name_number    IN  NUMBER
                             ,p_relationship_type       IN VARCHAR2
                             ,x_lnk_task_elem_id        OUT NUMBER
                             ,x_lnk_task_elem_ver_id    OUT NUMBER
                             ,x_object_relationship_id  OUT NUMBER
                             ,x_pev_schedule_id         OUT NUMBER
                             ,x_return_status           OUT VARCHAR2
                             ,x_msg_count               OUT NUMBER
                             ,x_msg_data                OUT VARCHAR2
                             );*/
--
-- API name                      : Update_Subproject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
-- p_debug_mode                  IN  VARCHAR2 := 'N'
-- p_object_relationship_id      IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- p_comment                     IN  VARCHAR2
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
Procedure Update_Subproject_Association(p_api_version            IN  NUMBER      := 1.0,
                                        p_init_msg_list          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validate_only          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level       IN  VARCHAR2    := 100,
                                        p_calling_module         IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_max_msg_count          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                        p_debug_mode             IN  VARCHAR2 := 'N',
                                        p_object_relationship_id IN  NUMBER,
                                        p_record_version_number  IN  NUMBER,
                                        p_comment                IN  VARCHAR2,
                                        x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
-- API name                      : Delete_SubProject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_relationships_id     IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
Procedure Delete_SubProject_Association(p_commit                  IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN  VARCHAR2    := 100,
                                        p_calling_module          IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN  VARCHAR2    := 'N',
                                        p_max_msg_count           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_object_relationships_id IN NUMBER,
                                        p_record_version_number   IN  NUMBER,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--
Procedure Copy_OG_Lnk_For_Subproj_Ass(p_validate_only           IN   VARCHAR2    := FND_API.G_TRUE,
                                      p_validation_level        IN   VARCHAR2    := 100,
                                      p_calling_module          IN   VARCHAR2    := 'SELF_SERVICE',
                                      p_debug_mode              IN   VARCHAR2    := 'N',
                                      p_max_msg_count           IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                      p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
                                      p_src_str_version_id      IN   NUMBER,
                                      p_dest_str_version_id     IN   NUMBER,  -- Destination Str version id can be of published str also
                                      x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_msg_data                OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--
PROCEDURE Move_CI_Lnk_For_subproj_step1(p_api_version	   IN	NUMBER	        :=1.0,
                                        p_init_msg_list	   IN	VARCHAR2	:=FND_API.G_TRUE,
                                        p_validate_only	   IN	VARCHAR2	:=FND_API.G_TRUE,
--                                        p_validation_level IN	NUMBER	        :=FND_API.G_VALID_LEVEL_FULL,
                                        p_validation_level IN  VARCHAR2         := 100,
                                        p_calling_module   IN	VARCHAR2	:='SELF_SERVICE',
                                        p_commit	   IN	VARCHAR2	:=FND_API.G_FALSE,
                                        p_debug_mode	   IN	VARCHAR2	:='N',
                                        p_max_msg_count	   IN	NUMBER	        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_str_version_id      IN   NUMBER,
                                        p_pub_str_version_id      IN   NUMBER,     --published str, which is destination
                                        p_last_pub_str_version_id IN   NUMBER,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--
/*PROCEDURE Move_CI_Lnk_For_subproj_step2(p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN   VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN   VARCHAR2    := 100,
                                        p_calling_module          IN   VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN   VARCHAR2    := 'N',
                                        p_max_msg_count           IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_str_version_id      IN   NUMBER,
                                        p_dest_str_version_id     IN   NUMBER,  --publishing str
                                        p_publish_fl              IN   CHAR,
                                        x_return_status           OUT  VARCHAR2,
                                        x_msg_count               OUT  NUMBER,
                                        x_msg_data                OUT  VARCHAR2);*/
--
--
--
--

-- API name                      : update_parent_WBS_flag_dirty
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
--   p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  13-may-05   Maansari             -Created
--
--  Post FPM bug 4370533
--
-- Description
--
-- This API is used to update parent links working version flag to dirty. This is called from process_wbs_updates api in publish mode.

  procedure UPDATE_PARENT_WBS_FLAG_DIRTY
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
;
end PA_RELATIONSHIP_PVT;

 

/
