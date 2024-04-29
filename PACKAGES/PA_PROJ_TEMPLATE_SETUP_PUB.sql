--------------------------------------------------------
--  DDL for Package PA_PROJ_TEMPLATE_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_TEMPLATE_SETUP_PUB" AUTHID CURRENT_USER AS
/* $Header: PATMSTPS.pls 120.2 2005/08/19 17:04:15 mwasowic noship $ */

-- API name                      : Create_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2

PROCEDURE Create_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_number       IN    VARCHAR2,
 p_project_name       IN    VARCHAR2,
 p_project_type       IN    VARCHAR2,
 p_organization_id  IN    NUMBER      := -9999,
 p_organization_name    IN    VARCHAR2    := 'JUNK_CHARS',
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER      := 0,
-- anlee
-- Project Long Name changes
 p_long_name          IN    VARCHAR2  DEFAULT NULL,
-- End of changes
 p_operating_unit_id  IN    NUMBER, -- 4363092 MOAC changes
 x_template_id        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Update_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Update_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_project_number       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_name       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_type       IN    VARCHAR2    := 'JUNK_CHARS',
 p_organization_id  IN    NUMBER      := -9999,
 p_organization_name    IN    VARCHAR2    := 'JUNK_CHARS',
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER      := 0,
-- anlee
-- Project Long Name changes
 p_long_name          IN    VARCHAR2  DEFAULT NULL,
-- End of changes
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Delete_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name                      : Add_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_code          IN    VARCHAR
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Add_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 p_action               IN    VARCHAR2 := 'ENABLE',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Delete_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Add_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_id  IN  NUMBER  No  Not Null
--p_sort_order  IN  NUMBER  No  Not null
--p_field_name  IN  VARCHAR2    No  Not null
--p_specification   IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_prompt  IN  VARCHAR2    No  not null
--p_required_flag   IN  VARCHAR2    No  not null    'N'
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Add_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_sort_order         IN    NUMBER  ,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_field_meaning          IN    VARCHAR2    := 'JUNK_CHARS',
 p_specification          IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2    ,
 p_required_flag          IN    VARCHAR2    := 'N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name                      : Update_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_id  IN  NUMBER  No  Not Null
--p_sort_order  IN  NUMBER  No      FND_API.G_MISS_NUM
--p_field_name  IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_specification   IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_prompt  IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_required_flag   IN  VARCHAR2    No  not null    'N'
--p_record_version_number   IN  NUMBER  No  not null
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Update_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER,
 p_row_id               IN    VARCHAR2,
 p_sort_order         IN    NUMBER,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_field_meaning          IN    VARCHAR2    := 'JUNK_CHARS',
 p_specification          IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2,
 p_required_flag          IN    VARCHAR2        :=  'N',  /* Default value N added for bug#2463257 */
 p_record_version_number IN NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Delete_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_id  IN  NUMBER  No  Not Null
--p_field_name  IN  VARCHAR2    No      FND_API.G_MISS_CHAR
--p_record_version_number   IN  NUMBER  No  not null
--
--  History
--
--  15-FEB-02   Majid Ansari             -Created
--
--

PROCEDURE Delete_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER,
 p_row_id               IN    VARCHAR2,
 p_record_version_number IN NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_PROJ_TEMPLATE_SETUP_PUB;

 

/
