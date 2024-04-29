--------------------------------------------------------
--  DDL for Package PA_PROJECTS_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECTS_MAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: PARMPRVS.pls 120.1 2005/08/19 16:57:21 mwasowic noship $ */
-- API name		: create_project
-- Type			: Private
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_orig_project_id    IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_distribution_rule   IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_public_sector_flag  IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_start_date          IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_probability_member_id IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE    Optional Default = FND_API.G_MISS_DATE
-- p_team_template_id       IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_country_code           IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_region                 IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_city                   IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_customer_id            IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- p_agreement_currency     IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_agreement_amount       IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_agreement_org_id       IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   \
-- p_bill_to_customer_id    IN NUMBER   Optional Default = NULL
-- p_ship_to_customer_id    IN NUMBER   Optional Default = NULL
-- p_long_name              IN VARCHAR2 Optional Default = NULL
-- p_project_id             OUT NUMBER Required
-- p_new_project_number     OUT VARCHAR2 Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_PROJECT
( p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE       ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_orig_project_id              IN NUMBER                              ,
 p_project_name                 IN VARCHAR2                            ,
 p_project_number               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_distribution_rule            IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_public_sector_flag           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_date                   IN DATE       := FND_API.G_MISS_DATE   ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE       := FND_API.G_MISS_DATE   ,
 p_team_template_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_country_code                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_region                       IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_currency           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_agreement_amount             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_agreement_org_id             IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_opp_value_currency_code      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_priority_code                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_template_flag                IN VARCHAR2   := 'N',
 p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- Customer Account Relationship
 p_bill_to_customer_id          IN NUMBER     := NULL                  ,
 p_ship_to_customer_id          IN NUMBER     := NULL                  ,
--Customer Account Relationship
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL             ,
-- end of changes
 p_project_id                  OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 p_new_project_number          OUT NOCOPY VARCHAR2                            , --File.Sql.39 bug 4440895
 x_return_status               OUT NOCOPY VARCHAR2                            ,   --File.Sql.39 bug 4440895
 x_msg_count                   OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 x_msg_data                    OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

--G_PROJECT_NUMBER_GEN_MODE  VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumMode;
--G_PROJECT_NUMBER_TYPE      VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumType;

-- API name		: create_customer
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_customer_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_relationship_type  IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status      OUT VARCHAR2  REQUIRED
-- x_msg_count          OUT NUMBER    REQUIRED
-- x_msg_data           OUT VARCHAR2  REQUIRED
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_CUSTOMER
( p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_customer_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_relationship_type            IN VARCHAR2   := FND_API.G_MISS_CHAR  ,
--Customer Account Relationships
 p_bill_to_customer_id          IN NUMBER     := NULL                  ,
 p_ship_to_customer_id          IN NUMBER     := NULL                  ,
--Customer Account Relationships
 x_return_status               OUT NOCOPY VARCHAR2                            ,   --File.Sql.39 bug 4440895
 x_msg_count                   OUT NOCOPY NUMBER                              , --File.Sql.39 bug 4440895
 x_msg_data                    OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

-- API name		: Update_project_basic_info
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Required
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Required
-- p_public_sector_flag  IN VARCHAR2  Required
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_start_date          IN DATE      Required
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_territory_code      IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_country             IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_location_id         IN NUMBER    Optional Default = FND_API.G_MISS_NUM
-- p_state_region        IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_city                IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
-- p_recalculate_flag   IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_target_start_date IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_target_finish_dateIN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- p_long_name          IN VARCHAR2   Optional Default = NULL
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE UPDATE_PROJECT_BASIC_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_project_name                 IN VARCHAR2                            ,
 p_project_number               IN VARCHAR2                            ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2                            ,
 p_public_sector_flag           IN VARCHAR2                            ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_date                   IN DATE                                ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_territory_code               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country                      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_location_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_state_region                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_priority_code                IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_recalculate_flag             IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_target_start_date           IN DATE       := FND_API.G_MISS_DATE   ,
 p_target_finish_date          IN DATE       := FND_API.G_MISS_DATE   ,
 p_security_level               IN NUMBER     := FND_API.G_MISS_NUM    ,
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL             ,
-- end of changes
 p_funding_approval_status      IN VARCHAR2   DEFAULT NULL             , -- added for 4055319
 x_return_status                OUT NOCOPY VARCHAR2                           ,   --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

-- API name		: Update_project_additional_info
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_type_id       IN NUMBER
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number  IN NUMBER Required
-- p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE UPDATE_PROJECT_ADDITIONAL_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_work_type_id                 IN NUMBER                              ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_cost_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_bill_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_split_cost_from_wokplan_flag IN VARCHAR2  := FND_API.G_MISS_CHAR   ,
 p_split_cost_from_bill_flag    IN VARCHAR2  := FND_API.G_MISS_CHAR   ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_sys_program_flag             IN varchar2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_allow_multi_prog_rollup      IN varchar2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status                OUT NOCOPY VARCHAR2                           ,   --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2)  ; --File.Sql.39 bug 4440895

-- API name		: Update_project_pipeline_info
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE   Required
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE UPDATE_PROJECT_PIPELINE_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE                                ,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           ,   --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name		: Create_classifications
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute11        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute12        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute13        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute14        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute15        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CREATE_CLASSIFICATIONS
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER,
 p_object_type                  IN VARCHAR2,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                           ,
 p_code_percentage              IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute11                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute12                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute13                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute14                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute15                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name		: Update_Classifications
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_attribute_category IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute1         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute2         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute3         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute4         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute5         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute6         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute7         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute8         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute9         IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute10        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute11        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute12        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute13        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute14        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_attribute15        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_rowid              IN VARCHAR2   Required
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           12-OCT-2001 --   anlee     created.
--
--
PROCEDURE UPDATE_CLASSIFICATIONS
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER,
 p_object_type                  IN VARCHAR2,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                            ,
 p_code_percentage              IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_attribute_category           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute1                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute2                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute3                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute4                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute5                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute6                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute7                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute8                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute9                   IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute10                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute11                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute12                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute13                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute14                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_attribute15                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_rowid                        IN VARCHAR2                            ,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name		: delete_classifications
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_record_version_number IN NUMBER  Optional Default = FND_API.G_MISS_NUM
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE DELETE_CLASSIFICATIONS
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER                              ,
 p_object_type                  IN VARCHAR2                            ,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2                            ,
 p_record_version_number        IN NUMBER     := FND_API.G_MISS_NUM    ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*
-- API name    : Validate_Basic_Info
-- Type        : Validation
-- Pre-reqs    : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_action             IN VARCHAR2   Optional Default =  'INSERT', 'UPDATE', 'DELETE'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Required
-- p_project_number     IN VARCHAR2   Required
-- p_project_type       IN VARCHAR2   Required
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Required
-- p_public_sector_flag  IN VARCHAR2  Required
-- p_carrying_out_organization_id IN NUMBER Required
-- p_start_date          IN DATE      Required
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_territory_code      IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_country             IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_location_id         IN NUMBER    Optional Default = FND_API.G_MISS_NUM
-- p_state_region        IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_city                IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE Validate_Basic_Info
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_action                       IN VARCHAR2   := 'UPDATE',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM,
 p_project_id                   IN NUMBER,
 p_project_name                 IN VARCHAR2,
 p_project_number               IN VARCHAR2,
 p_project_type                 IN VARCHAR2,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR,
 p_project_status_code          IN VARCHAR2                            ,
 p_public_sector_flag           IN VARCHAR2                            ,
 p_carrying_out_organization_id IN NUMBER         ,
 p_start_date                   IN DATE                                ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_territory_code               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country                      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_location_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_state_region                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER);

-- API name    : Validate_additional_info
-- Type        : Validation
-- Pre-reqs    : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Required
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_type_id       IN NUMBER
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_record_version_number  IN NUMBER Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE VALIDATE_ADDITIONAL_INFO
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2                            ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_work_type_id                 IN NUMBER                              ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_cost_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_bill_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_record_version_number        IN NUMBER );

-- API name    : Validate_pipeline_info
-- Type        : Validation
-- Pre-reqs    : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Required
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE   Required
-- p_record_version_number IN NUMBER  Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE VALIDATE_PIPELINE_INFO
( p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2                            ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE                                ,
 p_record_version_number        IN NUMBER  );
*/

-- API name             : validate_classifications
-- Type                 : Validation
-- Pre-reqs             : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Optional Default = 'INSERT'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_object_id          IN NUMBER     Required
-- p_object_type        IN VARCHAR2   Required
-- p_class_category     IN VARCHAR2   Required
-- p_class_code         IN VARCHAR2   Required
-- p_code_percentage IN OUT VARCHAR2  Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE VALIDATE_CLASSIFICATIONS
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2   := 'INSERT'  ,
 p_debug_mode                   IN VARCHAR2   := 'N',
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_object_id                    IN NUMBER                              ,
 p_object_type                  IN VARCHAR2                            ,
 p_class_category               IN VARCHAR2                            ,
 p_class_code                   IN VARCHAR2,
 p_code_percentage          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_rowid                        IN VARCHAR2   := FND_API.G_MISS_CHAR);


-- API name    : Validate_Project_Info
-- Type        : Validation
-- Pre-reqs    : None.
-- Parameters           :
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_action             IN VARCHAR2   Optional Default = 'INSERT', 'UPDATE', 'DELETE'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_project_name       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_number     IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_type       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_description        IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_project_status_code IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_public_sector_flag  IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_carrying_out_organization_id IN NUMBER Optional
--                                   Default = FND_API.G_MISS_NUM
-- p_start_date          IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_completion_date     IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_territory_code      IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_country             IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_location_id         IN NUMBER    Optional Default = FND_API.G_MISS_NUM
-- p_state_region        IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_city                IN VARCHAR2  Optional Default = FND_API.G_MISS_CHAR
-- p_calendar_id        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_work_type_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_role_list_id       IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_cost_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_bill_job_group_id  IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_probability_member_id  IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_project_value          IN NUMBER Optional Default = FND_API.G_MISS_NUM
-- p_expected_approval_date IN DATE   Optional Default = FND_API.G_MISS_DATE
-- p_record_version_number IN NUMBER  Required
-- p_target_start_date  IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_target_finish_date IN DATE      Optional Default = FND_API.G_MISS_DATE
-- p_long_name          IN VARCHAR2  Optional Default = NULL
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE Validate_Project_Info
(
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_action                       IN VARCHAR2   := 'UPDATE'                   ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_project_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_number               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_type                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_description                  IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_project_status_code          IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_public_sector_flag           IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_carrying_out_organization_id IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_date                   IN DATE       := FND_API.G_MISS_DATE   ,
 p_completion_date              IN DATE       := FND_API.G_MISS_DATE   ,
 p_territory_code               IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_country                      IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_location_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_state_region                 IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_city                         IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_work_type_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_cost_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_bill_job_group_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_probability_member_id        IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_value                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_expected_approval_date       IN DATE       := FND_API.G_MISS_DATE   ,
 p_record_version_number        IN NUMBER ,
 p_target_start_date           IN DATE       := FND_API.G_MISS_DATE   ,
 p_target_finish_date          IN DATE       := FND_API.G_MISS_DATE   ,
-- anlee
-- Project Long Name changes
 p_long_name                    IN VARCHAR2   DEFAULT NULL
-- end of changes
 );


-- API name		: Update_project_staffing_info
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_commit             IN VARCHAR2   Optional Default = FND_API.G_FALSE
-- p_validate_only      IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_validation_level   IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module     IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode         IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count      IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id         IN NUMBER     Required
-- p_comp_match_weighting        IN    pa_projects_all.COMPETENCE_MATCH_WT%TYPE    Optional Default = FND_API.G_MISS_NUM
-- p_avail_match_weighting       IN    pa_projects_all.availability_match_wt%TYPE  Optional Default = FND_API.G_MISS_NUM
-- p_job_level_match_weighting   IN    pa_projects_all.job_level_match_wt%TYPE     Optional Default = FND_API.G_MISS_NUM
-- p_search_min_availability     IN    pa_projects_all.search_min_availability%TYPE       Optional Default = FND_API.G_MISS_NUM
-- p_search_country_code         IN    pa_projects_all.search_country_code%TYPE           Optional Default = FND_API.G_MISS_CHAR
-- p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE       Optional Default = FND_API.G_MISS_CHAR,
-- p_search_exp_org_struct_ver_id IN   pa_projects_all.search_org_hier_id%TYPE  Optional Default = FND_API.G_MISS_NUM
-- p_search_exp_org_hier_name     IN per_organization_structures.name%TYPE       Optional Default = FND_API.G_MISS_CHAR,
-- p_search_exp_start_org_id     IN   pa_projects_all.search_starting_org_id%TYPE        Optional Default = FND_API.G_MISS_NUM
-- p_search_exp_start_org_name    IN hr_organization_units.name%TYPE                     Optional Default = FND_API.G_MISS_CHAR,
-- p_search_min_candidate_score  IN   pa_projects_all.min_cand_score_reqd_for_nom%TYPE     Optional Default = FND_API.G_MISS_NUM
-- p_enable_auto_cand_nom_flag    IN  pa_projects_all.enable_automated_search%TYPE      Optional Default = FND_API.G_MISS_CHAR
-- p_record_version_number IN NUMBER  Required
-- x_return_status     OUT VARCHAR2   Required
-- x_msg_count         OUT NUMBER     Required
-- x_msg_data          OUT VARCHAR2   Required
--
--  History
--
--           28-SEP-2000 --   hyau    - Created.
--
--
PROCEDURE UPDATE_PROJECT_STAFFING_INFO
(
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2     := FND_API.G_TRUE        ,
 p_validation_level             IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module               IN VARCHAR2   := 'SELF_SERVICE'        ,
 p_debug_mode                   IN VARCHAR2   := 'N'                   ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_project_id                   IN NUMBER                              ,
 p_comp_match_weighting         IN pa_projects_all.COMPETENCE_MATCH_WT%TYPE    := FND_API.G_MISS_NUM,
 p_avail_match_weighting        IN pa_projects_all.availability_match_wt%TYPE  := FND_API.G_MISS_NUM,
 p_job_level_match_weighting    IN pa_projects_all.job_level_match_wt%TYPE     := FND_API.G_MISS_NUM,
 p_search_min_availability      IN pa_projects_all.search_min_availability%TYPE       := FND_API.G_MISS_NUM,
 p_search_country_code          IN pa_projects_all.search_country_code%TYPE           := FND_API.G_MISS_CHAR,
 p_search_exp_org_struct_ver_id IN pa_projects_all.search_org_hier_id%TYPE  := FND_API.G_MISS_NUM,
 p_search_exp_start_org_id      IN pa_projects_all.search_starting_org_id%TYPE       := FND_API.G_MISS_NUM,
 p_search_min_candidate_score   IN pa_projects_all.min_cand_score_reqd_for_nom%TYPE    := FND_API.G_MISS_NUM,
 p_enable_auto_cand_nom_flag    IN pa_projects_all.enable_automated_search%TYPE     := FND_API.G_MISS_CHAR,
 p_record_version_number        IN NUMBER                              ,
 x_return_status                OUT NOCOPY VARCHAR2                           ,   --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END PA_PROJECTS_MAINT_PVT;

 

/
