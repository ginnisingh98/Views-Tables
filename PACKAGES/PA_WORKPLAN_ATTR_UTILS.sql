--------------------------------------------------------
--  DDL for Package PA_WORKPLAN_ATTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKPLAN_ATTR_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPRWPUS.pls 120.1 2005/08/19 16:46:02 mwasowic noship $ */

-- API name		: CHECK_LIFECYCLE_PHASE_NAME_ID
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id	           IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase_id    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_current_lifecycle_phase_id    OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_LIFECYCLE_PHASE_NAME_ID
(  p_lifecycle_id	           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase_id    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase       IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_current_lifecycle_phase_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name		: CHECK_LIFECYCLE_NAME_OR_ID
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id	           IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_lifecycle_id	           OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_LIFECYCLE_NAME_OR_ID
(  p_lifecycle_id	           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_lifecycle_id	           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name		: Check_Approver_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_approver_source_id            OUT NUMBER    Required
-- x_approver_source_type          OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_APPROVER_NAME_OR_ID
(  p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_approver_source_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_approver_source_type          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name		: Check_Wp_Versioning_Enabled
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id            IN NUMBER     Required

FUNCTION CHECK_WP_VERSIONING_ENABLED
(  p_project_id            IN NUMBER
) RETURN VARCHAR2;


-- API name		: Check_DATE_SYNC_ENABLED
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id       IN NUMBER     Required

FUNCTION CHECK_AUTO_DATE_SYNC_ENABLED
(  p_proj_element_id            IN NUMBER
) RETURN VARCHAR2;


-- API name		: GET_SYNC_BUF_DAYS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id       IN NUMBER     Required

FUNCTION GET_SYNC_BUF_DAYS
( p_proj_element_id              IN NUMBER
) RETURN NUMBER;


-- API name		: CHECK_WP_PROJECT_EXISTS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id       IN NUMBER     Required

PROCEDURE CHECK_WP_PROJECT_EXISTS
(     p_lifecycle_id                  IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name		: CHECK_WP_TASK_EXISTS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_phase_id       IN NUMBER     Required

PROCEDURE CHECK_WP_TASK_EXISTS
(     p_lifecycle_phase_id            IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_CURRENT_PHASE
(
      p_lifecycle_phase_id            IN NUMBER
     ,p_proj_element_id               IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION CHECK_APPROVAL_REQUIRED
(     p_project_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION CHECK_AUTO_PUB_ENABLED
(     p_project_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION CHECK_AUTO_PUB_AT_CREATION
(     p_template_id                    IN  NUMBER
) RETURN VARCHAR2;

END PA_WORKPLAN_ATTR_UTILS;
 

/
