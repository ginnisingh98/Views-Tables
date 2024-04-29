--------------------------------------------------------
--  DDL for Package PA_RELATIONSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RELATIONSHIP_PUB" AUTHID CURRENT_USER as
/*$Header: PAXRELPS.pls 120.2 2005/08/19 17:18:57 mwasowic noship $*/

-- API name                      : Create_Relationship
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
--   p_project_id_from                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_name_from                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_id_from                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_name_from               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_name_from       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_name_from                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_project_id_to                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_name_to                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_id_to                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_name_to                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_name_to         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_name_to                      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
   ,p_project_id_from                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_name_from                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_id_from                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_name_from               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_name_from       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_name_from                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_project_id_to                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_name_to                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_id_to                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_name_to                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_name_to         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_name_to                      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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


-- API name                      : Delete_Relationship
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
--   p_src_proj_id		         IN  NUMBER      := NULL
--   p_src_task_ver_id	                 IN  NUMBER      := NULL
--   p_dest_proj_name	                 IN  VARCHAR2    := NULL
--   p_dest_proj_id		         IN  NUMBER      := NULL
--   P_dest_task_name	                 IN  VARCHAR2    := NULL
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
   ,p_dest_proj_name                    IN  VARCHAR2    := NULL
   ,p_dest_proj_id                      IN  NUMBER      := NULL
   ,p_dest_task_name                    IN  VARCHAR2    := NULL
   ,p_dest_task_ver_id                  IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := 'FS'
   ,p_lag_days                          IN  NUMBER      := 0
   ,p_comments                          IN  VARCHAR2    := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Update_Dependency
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
--
-- API name                      : Create_Subproject_Association
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
--   p_src_proj_id                       IN  NUMBER
--   p_task_ver_id                       IN  NUMBER
--   p_dest_proj_id                      IN  NUMBER
--   p_dest_proj_name                    IN  VARCHAR2
--   p_comment                           IN  VARCHAR2
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka             -Created
--
--  FPM bug 3450684
--
PROCEDURE create_subproject_association(
                   p_api_version               IN  NUMBER      := 1.0
                  ,p_init_msg_list             IN  VARCHAR2    := FND_API.G_TRUE
                  ,p_commit                    IN  VARCHAR2    := FND_API.G_FALSE
                  ,p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
                  ,p_validation_level          IN  VARCHAR2    := 100
                  ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
                  ,p_debug_mode                IN  VARCHAR2    := 'N'
                  ,p_max_msg_count             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                  ,p_src_proj_id               IN  NUMBER
                  ,p_task_ver_id               IN  NUMBER
                  ,p_dest_proj_id              IN  NUMBER
                  ,p_dest_proj_name            IN  VARCHAR2    := NULL
                  ,p_comment                   IN  VARCHAR2
                  ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_msg_data                  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
-- API name                      : Update_Subproject_Association
-- Type                          : Public Procedure
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
Procedure Update_Subproject_Association(p_api_version            IN  NUMBER      := 1.0,
                                        p_init_msg_list          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validate_only          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level       IN  VARCHAR2    := 100,
                                        p_calling_module         IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_max_msg_count          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_commit                 IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_debug_mode             IN  VARCHAR2    := 'N',
                                        p_object_relationship_id IN  NUMBER,
                                        p_record_version_number  IN  NUMBER,
                                        p_comment                IN  VARCHAR2,
                                        x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
-- API name                      : Delete_SubProject_Association
-- Type                          : Public Procedure
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
Procedure Delete_SubProject_Association(p_api_version             IN  NUMBER      := 1.0,
                                        p_init_msg_list           IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_commit                  IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN  VARCHAR2    := 100,
                                        p_calling_module          IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN  VARCHAR2    := 'N',
                                        p_max_msg_count           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_object_relationships_id IN  NUMBER,
                                        p_record_version_number   IN  NUMBER,
                                        x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


  -- -----------------------------------------------------
  -- function UPDATE_PROGRAM_GROUPS
  --
  -- p_operation_type = 'ADD'  ==> This API must be called after the
  --                               association row has been added in
  --                               PA_OBJECT_RELATIONSHIPS
  --
  -- p_operation_type = 'DROP' ==> This API must be called before the
  --                               association row has been removed
  --                               from PA_OBJECT_RELATIONSHIPS
  --
  -- After this API looks up the association information it calls the
  -- other API UPDATE_PROGRAM_GROUPS with the relevant parameters.
  --
  --   History
  --   12-MAR-2004  SVERMETT  Created
  --
  -- -----------------------------------------------------
  function UPDATE_PROGRAM_GROUPS (p_object_relationship_id in number,
                                  p_operation_type in varchar2)
           return number;


  -- -----------------------------------------------------
  -- function UPDATE_PROGRAM_GROUPS
  --
  -- return:  0 = successful level / group propagation
  -- return: -1 = cycle exists during 'ADD' operation type
  -- return: -2 = association does not exist during 'DROP' operation
  --
  -- ***  This API assumes that initially no associations exist and
  -- ***  that associations are added one at a time in serial.
  --
  --   History
  --   12-MAR-2004  SVERMETT  Created
  --   24-JUN-2005  SVERMETT  Modified to support the relaxed acyclic rule
  --                          (old) acyclic rule:
  --                              No cycle may exist in a program hierarchy.
  --                          (new) relaxed acyclic rule:
  --                              A project may not roll up into a program
  --                              via more than one path.
  --
  -- -----------------------------------------------------
  function UPDATE_PROGRAM_GROUPS (p_parent_task_version_id     in number,
                                  p_parent_group               in number,
                                  p_parent_level               in number,
                                  p_parent_project             in number,
                                  p_child_structure_version_id in number,
                                  p_child_group                in number,
                                  p_child_level                in number,
                                  p_child_project              in number,
                                  p_relationship_type          in varchar2,
                                  p_operation_type             in varchar2)
           return number;

end PA_RELATIONSHIP_PUB;

 

/
