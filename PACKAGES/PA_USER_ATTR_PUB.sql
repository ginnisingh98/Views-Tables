--------------------------------------------------------
--  DDL for Package PA_USER_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_USER_ATTR_PUB" AUTHID DEFINER AS
/* $Header: PAUATTPS.pls 115.9 2003/08/20 06:14:45 bchandra noship $ */


-- API name		: COPY_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE COPY_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_object_id_from                IN NUMBER
 ,p_object_id_to                  IN NUMBER
 ,p_object_type                   IN VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_errorcode                     OUT NOCOPY NUMBER
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
);


-- API name		: DELETE_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE DELETE_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2 := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_project_id                    IN NUMBER
 ,p_proj_element_id               IN NUMBER DEFAULT NULL
 ,p_old_classification_id         IN NUMBER
 ,p_new_classification_id         IN NUMBER DEFAULT NULL
 ,p_classification_type           IN VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
);


-- API name		: CHECK_DELETE_ASSOC_OK
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE CHECK_DELETE_ASSOC_OK
( p_api_version                   IN NUMBER   := 1.0
 ,p_association_id                IN NUMBER
 ,p_classification_code           IN VARCHAR2
 ,p_data_level                    IN VARCHAR2
 ,p_attr_group_id                 IN NUMBER
 ,p_application_id                IN NUMBER
 ,p_attr_group_type               IN VARCHAR2
 ,p_attr_group_name               IN VARCHAR2
 ,p_enabled_code                  IN VARCHAR2
 ,x_ok_to_delete                  OUT NOCOPY VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_errorcode                     OUT NOCOPY NUMBER
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
);


-- API name		: DELETE_ALL_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE DELETE_ALL_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2 := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_project_id                    IN NUMBER
 ,p_proj_element_id               IN NUMBER DEFAULT NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- API name     : Process_User_Attrs_Data
-- Type         : Public
-- Pre-reqs     : None.
-- Description  : This API is a wrapper for the EGO API
--                EGO_USER_ATTRS_DATA_PUB.Process_User_Attr_Data
--                It performs the following operations:
--                1. transpose data from the PA data structure
--                to a format that is understood by the EGO API
--                2. Call the EGO api and return the results
PROCEDURE Process_User_Attrs_Data
(  p_api_version   	 IN   NUMBER := 1.0
   , p_object_name	 IN   VARCHAR2 := 'PA_PROJECTS'
   , p_ext_attr_data_table IN   PA_PROJECT_PUB.PA_EXT_ATTR_TABLE_TYPE
   , p_project_id     IN   NUMBER  := 0
   , p_structure_type IN   VARCHAR2 := 'FINANCIAL'
   , p_entity_id      IN   NUMBER  := NULL
   , p_entity_index   IN   NUMBER  := NULL
   , p_entity_code    IN   VARCHAR2   := NULL
   , p_debug_mode      IN   VARCHAR2 := 'N'
   , p_debug_level    IN   NUMBER     := 0
   , p_init_error_handler        IN   VARCHAR2   := FND_API.G_FALSE
   , p_write_to_concurrent_log   IN   VARCHAR2   := FND_API.G_FALSE
   , p_init_msg_list  IN   VARCHAR2   := FND_API.G_FALSE
   , p_log_errors     IN   VARCHAR2   := FND_API.G_FALSE
   , p_commit         IN   VARCHAR2   := FND_API.G_FALSE
   , x_failed_row_id_list OUT NOCOPY VARCHAR2
   , x_return_status  OUT NOCOPY VARCHAR2
   , x_errorcode      OUT NOCOPY NUMBER
   , x_msg_count      OUT NOCOPY NUMBER
   , x_msg_data       OUT NOCOPY VARCHAR2);


-- API name     : Check_Class_Assoc_Exists
-- Type         : Public
-- Pre-reqs     : None.

PROCEDURE CHECK_CLASS_ASSOC_EXISTS
(  P_ROW_ID               IN VARCHAR2
  ,P_NEW_CLASS_CATEGORY   IN VARCHAR2 DEFAULT NULL
  ,P_NEW_CLASS_CODE       IN VARCHAR2 DEFAULT NULL
  ,P_MODE                 IN VARCHAR2
  ,X_ASSOC_EXISTS         OUT NOCOPY VARCHAR2 );


-- API name     : Check_PT_Assoc_Exists
-- Type         : Public
-- Pre-reqs     : None.

PROCEDURE CHECK_PT_ASSOC_EXISTS
(  P_PROJECT_ID           IN NUMBER
  ,P_NEW_PROJECT_TYPE     IN VARCHAR2
  ,X_ASSOC_EXISTS         OUT NOCOPY VARCHAR2 );

END PA_USER_ATTR_PUB;

 

/
