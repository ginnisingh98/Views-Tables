--------------------------------------------------------
--  DDL for Package PA_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTIONS_PUB" AUTHID DEFINER as
/* $Header: PAACTNPS.pls 120.1 2005/08/19 16:14:41 mwasowic noship $ */

l_event_in_tbl    PA_EVENT_PUB.event_in_tbl_type;
l_event_out_tbl   PA_EVENT_PUB.event_out_tbl_type;

l_dlv_ship_action_rec   oke_amg_grp.dlv_ship_action_rec_type;
l_dlv_req_action_rec    oke_amg_grp.dlv_req_action_rec_type;
l_dlv_ship_action_rec_b   oke_amg_grp.dlv_ship_action_rec_type;
l_dlv_req_action_rec_b    oke_amg_grp.dlv_req_action_rec_type;

TYPE dlv_ship_action_tbl_type   IS TABLE OF  oke_amg_grp.dlv_ship_action_rec_type INDEX BY BINARY_INTEGER;
TYPE dlv_req_action_tbl_type    IS TABLE OF  oke_amg_grp.dlv_req_action_rec_type  INDEX BY BINARY_INTEGER;

--Package constant used for package version validation

G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PA_ACTIONS_PUB';

PROCEDURE  Create_Dlvr_Actions_Wrapper
    ( p_api_version            IN NUMBER    :=1.0
    , p_init_msg_list          IN VARCHAR2  :=FND_API.G_TRUE
    , p_commit                 IN VARCHAR2  :=FND_API.G_FALSE
    , p_validate_only          IN VARCHAR2  :=FND_API.G_TRUE
    , p_validation_level       IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
    , p_calling_module         IN VARCHAR2  :='AMG'
    , p_debug_mode             IN VARCHAR2  :='N'
    , p_insert_or_update       IN VARCHAR2 := 'INSERT'
    , p_action_in_tbl          IN  PA_PROJECT_PUB.action_in_tbl_type
    , x_action_out_tbl         OUT NOCOPY PA_PROJECT_PUB.action_out_tbl_type --File.Sql.39 bug 4440895
    , x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    , x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    , x_msg_data               OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895


PROCEDURE CREATE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() -- added 3435905
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE UPDATE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null -- 3578694, added default value
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

PROCEDURE DELETE_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

PROCEDURE VALIDATE_ACTIONS
     (p_api_version            IN NUMBER    :=1.0
     ,p_init_msg_list          IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                 IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only          IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level       IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module         IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode             IN VARCHAR2  :='N'
     ,p_max_msg_count          IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl               IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_completed_flag_tbl     IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl    IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl        IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_function_code_tbl      IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl           IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_element_version_id_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_user_action_tbl        IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_object_id              IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_object_version_id      IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type            IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_action_owner_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_carrying_out_org_id   IN NUMBER := null
     ,p_action_reference_tbl  IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_deliverable_id        IN  PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE := null
     ,p_insert_or_update       IN VARCHAR2 := 'INSERT'
     ,p_project_id         IN pa_projects_all.project_id%TYPE   --Included by avaithia for Bug 3512346
     ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data               OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE CR_UP_DLV_ACTIONS_IN_BULK
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_user_action_tbl           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE  := null
     ,p_object_id                 IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE
     ,p_object_version_id         IN PA_OBJECT_RELATIONSHIPS.OBJECT_ID_TO1%TYPE := null
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE() -- added 3435905
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,p_insert_or_update          IN VARCHAR2 := 'INSERT'
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

PROCEDURE DELETE_DLV_ACTION
     (p_api_version      IN NUMBER   :=1.0
     ,p_init_msg_list    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit           IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only    IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module   IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode       IN VARCHAR2 :='N'
     ,p_max_msg_count    IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_action_id        IN pa_proj_elements.proj_element_id%TYPE
     ,p_action_ver_id    IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id   IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id   IN pa_proj_element_versions.element_version_id%TYPE
     ,p_function_code    IN pa_proj_elements.function_code%TYPE
     ,p_project_id       IN pa_projects_all.project_id%TYPE
     ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;


PROCEDURE COPY_ACTIONS
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_source_object_id    IN pa_object_relationships.object_id_from2%TYPE
     ,p_source_object_type  IN pa_object_relationships.object_type_from%TYPE
     ,p_target_object_id    IN pa_object_relationships.object_id_from2%TYPE
     ,p_target_object_type  IN pa_object_relationships.object_type_from%TYPE
     ,p_source_project_id   IN pa_projects_all.project_id%TYPE
     ,p_target_project_id   IN pa_projects_all.project_id%TYPE
     ,p_task_id             IN pa_proj_elements.proj_element_id%TYPE := null
     ,p_task_ver_id         IN pa_proj_element_versions.element_version_id%TYPE := null
     ,p_carrying_out_organization_id IN pa_proj_elements.carrying_out_organization_id%TYPE := null
     ,p_pm_source_reference IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_code      IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_calling_mode        IN VARCHAR2 := NULL  -- Added for bug# 3911050
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE RUN_ACTION_CONC_PROCESS
(
 errbuf             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,retcode                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_function              IN     pa_lookups.lookup_code%TYPE
,p_project_number_from   IN     pa_projects_all.segment1%TYPE  :=NULL
,p_project_number_to     IN     pa_projects_all.segment1%TYPE  :=NULL
);

-- 3578694 added
PROCEDURE UPD_DLV_ACTIONS_IN_BULK_TM
     (p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_name_tbl                  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_manager_person_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_function_code_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_due_date_tbl              IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_completed_flag_tbl        IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE()
     ,p_completion_date_tbl       IN SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE()
     ,p_description_tbl           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()
     ,p_attribute_category_tbl    IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_attribute1_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute2_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute3_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute4_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute5_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute6_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute7_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute8_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute9_tbl            IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute10_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute11_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute12_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute13_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute14_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_attribute15_tbl           IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_version_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_proj_element_id_tbl       IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_record_version_number_tbl IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_project_id_tbl            IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_id_tbl             IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_version_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_object_type               IN PA_LOOKUPS.LOOKUP_CODE%TYPE
     ,p_pm_source_code            IN pa_proj_elements.pm_source_code%TYPE := null
     ,p_pm_source_reference       IN pa_proj_elements.pm_source_reference%TYPE := null
     ,p_pm_source_reference_tbl   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     ,p_insert_or_update          IN VARCHAR2 := 'UPDATE'
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

PROCEDURE RUN_ACTION_CONC_PROCESS_WRP
     (
      p_api_version               IN NUMBER    :=1.0
     ,p_init_msg_list             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_commit                    IN VARCHAR2  :=FND_API.G_FALSE
     ,p_validate_only             IN VARCHAR2  :=FND_API.G_TRUE
     ,p_validation_level          IN NUMBER    :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module            IN VARCHAR2  :='SELF_SERVICE'
     ,p_debug_mode                IN VARCHAR2  :='N'
     ,p_max_msg_count             IN NUMBER    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE
     ,p_project_number            IN PA_PROJECTS_ALL.SEGMENT1%TYPE  -- 3671408 added IN parameter
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

PROCEDURE RUN_ACTION_CONC_FRM_WRP
     (
      p_project_id                IN PA_PROJECTS_ALL.PROJECT_ID%TYPE
     ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

END PA_ACTIONS_PUB;

 

/
