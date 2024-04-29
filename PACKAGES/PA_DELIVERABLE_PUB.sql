--------------------------------------------------------
--  DDL for Package PA_DELIVERABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DELIVERABLE_PUB" AUTHID CURRENT_USER AS
/* $Header: PADLVPUS.pls 120.1 2005/08/19 16:21:28 mwasowic noship $ */

     l_err_message             Fnd_New_Messages.Message_text%TYPE;  -- for AMG message

PROCEDURE Create_Deliverable
    (
       p_api_version            IN   NUMBER := 1.0
     , p_init_msg_list          IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                 IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only          IN   VARCHAR2 := FND_API.G_TRUE
     , p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2 := 'N'
     , p_max_msg_count          IN   NUMBER   := NULL
     , p_record_version_number  IN   NUMBER   := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE  := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE    := NULL
     , p_dlvr_owner_name        IN  VARCHAR2   := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL
     , p_carrying_out_org_name  IN  VARCHAR2 := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE   := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE         := NULL
     , p_parent_structure_id    IN   PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE  := NULL
     , p_dlvr_type_id           IN   PA_PROJ_ELEMENTS.TYPE_ID%TYPE  := NULL
     , p_dlvr_type_name         IN   VARCHAR2   := NULL
     , p_progress_weight        IN   PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE  := NULL
     , p_scheduled_finish_date  IN   PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE   := NULL
     , p_actual_finish_date     IN   PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE  := NULL
     , p_task_id                IN   NUMBER     := NULL
     , p_task_version_id        IN   NUMBER     := NULL
     , p_task_name              IN   VARCHAR2   := NULL
     , p_deliverable_reference  IN  VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE := NULL
     , p_item_id                IN  NUMBER        := NULL
     , p_inventory_org_id       IN  NUMBER        := NULL
     , p_quantity               IN  NUMBER        := NULL
     , p_uom_code               IN  VARCHAR2      := NULL
     , p_item_description       IN  VARCHAR2      := NULL
     , p_unit_price             IN  NUMBER        := NULL
     , p_unit_number            IN  VARCHAR2      := NULL
     , p_currency_code          IN  VARCHAR2      := NULL
     , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
     , p_dlvr_item_id           OUT  NOCOPY PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE --File.Sql.39 bug 4440895
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

PROCEDURE Update_Deliverable
    (
       p_api_version            IN   NUMBER := 1.0
     , p_init_msg_list          IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                 IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only          IN   VARCHAR2 := FND_API.G_TRUE
     , p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module         IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2 := 'N'
     , p_max_msg_count          IN   NUMBER   := NULL
     , p_record_version_number  IN   NUMBER   := 1
     , p_object_type            IN  PA_PROJ_ELEMENTS.OBJECT_TYPE%TYPE := 'PA_DELIVERABLES'
     , p_project_id             IN  PA_PROJ_ELEMENTS.PROJECT_ID%TYPE
     , p_dlvr_number            IN  PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE
     , p_dlvr_name              IN  PA_PROJ_ELEMENTS.NAME%TYPE
     , p_dlvr_description       IN  PA_PROJ_ELEMENTS.DESCRIPTION%TYPE  := NULL
     , p_dlvr_owner_id          IN  PA_PROJ_ELEMENTS.MANAGER_PERSON_ID%TYPE    := NULL
     , p_dlvr_owner_name        IN  VARCHAR2   := NULL
     , p_carrying_out_org_id    IN  PA_PROJ_ELEMENTS.CARRYING_OUT_ORGANIZATION_ID%TYPE := NULL
     , p_carrying_out_org_name  IN  VARCHAR2 := NULL
     , p_dlvr_version_id        IN  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE   := NULL
     , p_status_code            IN  PA_PROJ_ELEMENTS.STATUS_CODE%TYPE         := NULL
     , p_parent_structure_id    IN   PA_PROJ_ELEMENTS.PARENT_STRUCTURE_ID%TYPE  := NULL
     , p_dlvr_type_id           IN   PA_PROJ_ELEMENTS.TYPE_ID%TYPE  := NULL
     , p_dlvr_type_name         IN   VARCHAR2   := NULL
     , p_progress_weight        IN   PA_PROJ_ELEMENTS.PROGRESS_WEIGHT%TYPE  := NULL
     , p_scheduled_finish_date  IN   PA_PROJ_ELEM_VER_SCHEDULE.SCHEDULED_FINISH_DATE%TYPE   := NULL
     , p_actual_finish_date     IN   PA_PROJ_ELEM_VER_SCHEDULE.ACTUAL_FINISH_DATE%TYPE  := NULL
     , p_task_id                IN   NUMBER     := NULL
     , p_task_version_id        IN   NUMBER     := NULL
     , p_task_name              IN   VARCHAR2   := NULL
     , p_deliverable_reference  IN  VARCHAR2   := NULL
     , p_attribute_category     IN  PA_PROJ_ELEMENTS.ATTRIBUTE_CATEGORY%TYPE := NULL
     , p_attribute1             IN  PA_PROJ_ELEMENTS.ATTRIBUTE1%TYPE := NULL
     , p_attribute2             IN  PA_PROJ_ELEMENTS.ATTRIBUTE2%TYPE := NULL
     , p_attribute3             IN  PA_PROJ_ELEMENTS.ATTRIBUTE3%TYPE := NULL
     , p_attribute4             IN  PA_PROJ_ELEMENTS.ATTRIBUTE4%TYPE := NULL
     , p_attribute5             IN  PA_PROJ_ELEMENTS.ATTRIBUTE5%TYPE := NULL
     , p_attribute6             IN  PA_PROJ_ELEMENTS.ATTRIBUTE6%TYPE := NULL
     , p_attribute7             IN  PA_PROJ_ELEMENTS.ATTRIBUTE7%TYPE := NULL
     , p_attribute8             IN  PA_PROJ_ELEMENTS.ATTRIBUTE8%TYPE := NULL
     , p_attribute9             IN  PA_PROJ_ELEMENTS.ATTRIBUTE9%TYPE := NULL
     , p_attribute10            IN  PA_PROJ_ELEMENTS.ATTRIBUTE10%TYPE := NULL
     , p_attribute11            IN  PA_PROJ_ELEMENTS.ATTRIBUTE11%TYPE := NULL
     , p_attribute12            IN  PA_PROJ_ELEMENTS.ATTRIBUTE12%TYPE := NULL
     , p_attribute13            IN  PA_PROJ_ELEMENTS.ATTRIBUTE13%TYPE := NULL
     , p_attribute14            IN  PA_PROJ_ELEMENTS.ATTRIBUTE14%TYPE := NULL
     , p_attribute15            IN  PA_PROJ_ELEMENTS.ATTRIBUTE15%TYPE := NULL
     , p_item_id                IN  NUMBER        := NULL
     , p_inventory_org_id       IN  NUMBER        := NULL
     , p_quantity               IN  NUMBER        := NULL
     , p_uom_code               IN  VARCHAR2      := NULL
     , p_item_description       IN  VARCHAR2      := NULL
     , p_unit_price             IN  NUMBER        := NULL
     , p_unit_number            IN  VARCHAR2      := NULL
     , p_currency_code          IN  VARCHAR2      := NULL
     , p_dlvr_item_id           IN   PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
     , p_pm_source_code         IN  VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR              /* Bug no. 3651113 */
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

PROCEDURE DELETE_DELIVERABLES_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_dlv_element_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_version_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_rec_ver_number_tbl  IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_name_tbl        IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_dlv_number_tbl      IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE DELETE_DLV_TASK_ASSOCIATION
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_dlv_element_id      IN pa_proj_elements.proj_element_id%TYPE
     ,p_dlv_version_id      IN pa_proj_element_versions.element_version_id%TYPE
     ,p_object_relationship_id IN pa_object_relationships.object_relationship_id%TYPE
     ,p_obj_rec_ver_number  IN pa_object_relationships.record_version_number%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_calling_context     IN  VARCHAR2 := 'TASKS'
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE CREATE_ASSOCIATIONS_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_element_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_version_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_element_name_tbl    IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_element_number_tbl  IN SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
     ,p_task_or_dlv_elt_id  IN NUMBER
     ,p_task_or_dlv_ver_id  IN NUMBER
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_task_or_dlv         IN VARCHAR2 := 'PA_TASKS'
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE DELETE_DELIVERABLE_STRUCTURE
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE DELETE_DLV_TASK_ASSCN_IN_BULK
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_calling_context     IN VARCHAR2 := 'PA_TASKS'
     ,p_task_element_id     IN pa_proj_elements.proj_element_id%TYPE
     ,p_task_version_id     IN pa_proj_element_versions.element_version_id%TYPE
     ,p_project_id          IN pa_projects_all.project_id%TYPE
     ,p_delete_or_validate  IN VARCHAR2 := 'B' -- 3955848 V- Validate , D - Delete, B - Validate and Delete
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE DELETE_DLV_ASSOCIATIONS
     (p_api_version         IN NUMBER   :=1.0
     ,p_init_msg_list       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit              IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only       IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level    IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module      IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode          IN VARCHAR2 :='N'
     ,p_max_msg_count       IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_project_id          IN NUMBER
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE COPY_DELIVERABLES
     (p_api_version          IN NUMBER   :=1.0
     ,p_init_msg_list        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit               IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only        IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level     IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module       IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode           IN VARCHAR2 :='N'
     ,p_max_msg_count        IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     ,p_source_project_id    IN NUMBER
     ,p_target_project_id    IN NUMBER
     ,p_dlv_element_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_dlv_version_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE()
     ,p_item_details_flag    IN VARCHAR2 := 'N'
     ,p_dlv_actions_flag     IN VARCHAR2 := 'N'
     ,p_dlv_attachments_flag IN VARCHAR2 := 'N'
     ,p_association_flag     IN VARCHAR2 := 'N'
     ,p_prefix               IN VARCHAR2 := null
     ,p_delta                IN NUMBER := null
     ,p_calling_context      IN VARCHAR2
     ,p_task_id              IN NUMBER :=null --Bug 3429393
     ,p_task_version_id      IN NUMBER :=null --Bug 3429393
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) ;

PROCEDURE COPY_ASSOCIATIONS
     (p_api_version             IN NUMBER   :=1.0
     ,p_init_msg_list           IN VARCHAR2 :=FND_API.G_TRUE
     ,p_commit                  IN VARCHAR2 :=FND_API.G_FALSE
     ,p_validate_only           IN VARCHAR2 :=FND_API.G_TRUE
     ,p_validation_level        IN NUMBER   :=FND_API.G_VALID_LEVEL_FULL
     ,p_calling_module          IN VARCHAR2 :='SELF_SERVICE'
     ,p_debug_mode              IN VARCHAR2 :='N'
     ,p_max_msg_count           IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     /* Bug #: 3305199 SMukka                                                         */
     /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
     /*,p_src_task_versions_tab   IN PA_PLSQL_DATATYPES.IdTabTyp                      */
     /*,p_dest_task_versions_tab  IN PA_PLSQL_DATATYPES.IdTabTyp                      */
     ,p_src_task_versions_tab   IN SYSTEM.pa_num_tbl_type
     ,p_dest_task_versions_tab  IN SYSTEM.pa_num_tbl_type
     ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )  ;

END PA_DELIVERABLE_PUB;


 

/
