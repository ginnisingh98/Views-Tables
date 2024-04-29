--------------------------------------------------------
--  DDL for Package PA_USER_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_USER_ATTR_PVT" AUTHID CURRENT_USER AS
/* $Header: PAUATTVS.pls 115.2 2003/08/21 05:58:50 sacgupta noship $ */

-- API name		: DELETE_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE DELETE_USER_ATTRS_DATA
( p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
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


END PA_USER_ATTR_PVT;

 

/
