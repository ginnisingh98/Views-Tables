--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUC_MAPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUC_MAPPING_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPSMPPS.pls 120.1 2005/08/19 16:46:20 mwasowic noship $ */

-- This table type can be used for version id of any kind of project element version.
TYPE  OBJECT_VERSION_ID_TABLE_TYPE IS TABLE OF pa_proj_element_versions.element_version_id%TYPE
INDEX BY BINARY_INTEGER;

-- This table type can be used for id of any kind of project element.
TYPE  OBJECT_ID_TABLE_TYPE IS TABLE OF pa_proj_element_versions.proj_element_id%TYPE
INDEX BY BINARY_INTEGER;

-- This table type can be used for name of any kind of project element.
TYPE  OBJECT_NAME_TABLE_TYPE IS TABLE OF PA_PROJ_ELEMENTS.NAME%TYPE INDEX BY BINARY_INTEGER;

-- This table type can be used for stroring object_relationship_id
TYPE  OBJ_REL_ID_TABLE_TYPE IS TABLE OF PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE INDEX BY BINARY_INTEGER;

PROCEDURE DELETE_MAPPING
    (
       p_api_version           IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_record_version_number IN   NUMBER   := FND_API.G_MISS_NUM
     , p_wp_from_task_name     IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_task_version_id    IN   NUMBER := FND_API.G_MISS_NUM
     , p_fp_task_version_id    IN   NUMBER := FND_API.G_MISS_NUM
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2        --File.Sql.39 bug 4440895

   );

 PROCEDURE CREATE_MAPPING
   (
        p_api_version           IN   NUMBER := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_wp_task_name          IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_task_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_parent_str_version_id IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_name          IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_project_id            IN   NUMBER
     , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT  NOCOPY VARCHAR2         --File.Sql.39 bug 4440895
  );

PROCEDURE UPDATE_MAPPING
   (
       p_api_version               IN   NUMBER := 1.0
     , p_init_msg_list             IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                    IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only             IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module            IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode                IN   VARCHAR2 := 'N'
     , p_record_version_number     IN   NUMBER   := FND_API.G_MISS_NUM
     , p_structure_type            IN   VARCHAR2 := 'WORKPLAN'
     , p_project_id                IN   NUMBER
     , p_wp_task_name              IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_prnt_str_ver_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_wp_task_version_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_name              IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_fp_task_version_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_object_relationship_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data                  OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
  );

PROCEDURE COPY_MAPPING
    (
       p_api_version           IN   NUMBER := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_record_version_number IN   NUMBER   := FND_API.G_MISS_NUM
     , p_context               IN   VARCHAR2
     , p_src_project_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_dest_project_id       IN   NUMBER   := FND_API.G_MISS_NUM
     , p_src_str_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_dest_str_version_id   IN   NUMBER   := FND_API.G_MISS_NUM
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2     --File.Sql.39 bug 4440895
   );
   PROCEDURE DELETE_ALL_MAPPING
    (
       p_api_version           IN       NUMBER   := 1.0
     , p_init_msg_list         IN       VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN       VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN       VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN       VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN       VARCHAR2 := 'N'
     , p_project_id            IN       NUMBER
     , x_return_status         OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT      NOCOPY VARCHAR2        --File.Sql.39 bug 4440895
   );
END PA_PROJ_STRUC_MAPPING_PUB;

 

/
