--------------------------------------------------------
--  DDL for Package PA_TASK_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_TYPE_PUB" AUTHID CURRENT_USER AS
/*$Header: PATTPUBS.pls 120.1 2005/08/19 17:06:27 mwasowic noship $*/

PROCEDURE create_task_type
 (p_task_type                     IN    pa_task_types.task_type%TYPE
 ,p_start_date_active             IN    pa_task_types.start_date_active%TYPE
 ,p_end_date_active               IN    pa_task_types.end_date_active%TYPE          := NULL
 ,p_description                   IN    pa_task_types.description%TYPE              := NULL
 ,p_task_type_class_code          IN    pa_task_types.task_type_class_code%TYPE
 ,p_initial_status_code           IN    pa_task_types.initial_status_code%TYPE      := NULL
 ,p_prog_entry_enable_flag        IN    pa_task_types.prog_entry_enable_flag%TYPE   := NULL
 ,p_prog_entry_req_flag           IN    pa_task_types.prog_entry_req_flag%TYPE      := NULL
 ,p_initial_progress_status_code  IN    pa_task_types.initial_progress_status_code%TYPE  := NULL
 ,p_task_prog_entry_page_id       IN    pa_task_types.task_progress_entry_page_id%TYPE   := NULL
 ,p_task_prog_entry_page_name     IN    pa_page_layouts.page_name%TYPE                   := NULL
 ,p_wq_enable_flag                IN    pa_task_types.wq_enable_flag%TYPE            := NULL
 ,p_work_item_code                IN    pa_task_types.work_item_code%TYPE            := NULL
 ,p_uom_code                      IN    pa_task_types.uom_code%TYPE                  := NULL
 ,p_actual_wq_entry_code          IN    pa_task_types.actual_wq_entry_code%TYPE      := NULL
 ,p_percent_comp_enable_flag      IN    pa_task_types.percent_comp_enable_flag%TYPE  := NULL
 ,p_base_percent_comp_deriv_code  IN    pa_task_types.base_percent_comp_deriv_code%TYPE  := NULL
 ,p_task_weighting_deriv_code     IN    pa_task_types.task_weighting_deriv_code%TYPE     := NULL
 ,p_remain_effort_enable_flag     IN    pa_task_types.remain_effort_enable_flag%TYPE := NULL
 ,p_attribute_category     IN    pa_task_types.attribute_category%TYPE       := NULL
 ,p_attribute1             IN    pa_task_types.attribute1%TYPE               := NULL
 ,p_attribute2             IN    pa_task_types.attribute2%TYPE               := NULL
 ,p_attribute3             IN    pa_task_types.attribute3%TYPE               := NULL
 ,p_attribute4             IN    pa_task_types.attribute4%TYPE               := NULL
 ,p_attribute5             IN    pa_task_types.attribute5%TYPE               := NULL
 ,p_attribute6             IN    pa_task_types.attribute6%TYPE               := NULL
 ,p_attribute7             IN    pa_task_types.attribute7%TYPE               := NULL
 ,p_attribute8             IN    pa_task_types.attribute8%TYPE               := NULL
 ,p_attribute9             IN    pa_task_types.attribute9%TYPE               := NULL
 ,p_attribute10            IN    pa_task_types.attribute10%TYPE              := NULL
 ,p_attribute11            IN    pa_task_types.attribute11%TYPE              := NULL
 ,p_attribute12            IN    pa_task_types.attribute12%TYPE              := NULL
 ,p_attribute13            IN    pa_task_types.attribute13%TYPE              := NULL
 ,p_attribute14            IN    pa_task_types.attribute14%TYPE              := NULL
 ,p_attribute15            IN    pa_task_types.attribute15%TYPE              := NULL
 ,p_api_version            IN    NUMBER                                       := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'      -- 3279978 : Added Object Type and Progress Rollup Method
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_task_type_id          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Task_Type
( p_task_type_id                  IN    pa_task_types.task_type_id%TYPE
 ,p_task_type                     IN    pa_task_types.task_type%TYPE
 ,p_start_date_active             IN    pa_task_types.start_date_active%TYPE
 ,p_end_date_active               IN    pa_task_types.end_date_active%TYPE          := NULL
 ,p_description                   IN    pa_task_types.description%TYPE              := NULL
 ,p_task_type_class_code          IN    pa_task_types.task_type_class_code%TYPE
 ,p_initial_status_code           IN    pa_task_types.initial_status_code%TYPE      := NULL
 ,p_prog_entry_enable_flag        IN    pa_task_types.prog_entry_enable_flag%TYPE   := NULL
 ,p_prog_entry_req_flag           IN    pa_task_types.prog_entry_req_flag%TYPE      := NULL
 ,p_initial_progress_status_code  IN    pa_task_types.initial_progress_status_code%TYPE  := NULL
 ,p_task_prog_entry_page_id       IN    pa_task_types.task_progress_entry_page_id%TYPE   := NULL
 ,p_task_prog_entry_page_name     IN    pa_page_layouts.page_name%TYPE              := NULL
 ,p_wq_enable_flag                IN    pa_task_types.wq_enable_flag%TYPE           := NULL
 ,p_work_item_code                IN    pa_task_types.work_item_code%TYPE           := NULL
 ,p_uom_code                      IN    pa_task_types.uom_code%TYPE                 := NULL
 ,p_actual_wq_entry_code          IN    pa_task_types.actual_wq_entry_code%TYPE     := NULL
 ,p_percent_comp_enable_flag      IN    pa_task_types.percent_comp_enable_flag%TYPE := NULL
 ,p_base_percent_comp_deriv_code  IN    pa_task_types.base_percent_comp_deriv_code%TYPE  := NULL
 ,p_task_weighting_deriv_code     IN    pa_task_types.task_weighting_deriv_code%TYPE     := NULL
 ,p_remain_effort_enable_flag     IN    pa_task_types.remain_effort_enable_flag%TYPE     := NULL
 ,p_attribute_category     IN    pa_task_types.attribute_category%TYPE       := NULL
 ,p_attribute1             IN    pa_task_types.attribute1%TYPE               := NULL
 ,p_attribute2             IN    pa_task_types.attribute2%TYPE               := NULL
 ,p_attribute3             IN    pa_task_types.attribute3%TYPE               := NULL
 ,p_attribute4             IN    pa_task_types.attribute4%TYPE               := NULL
 ,p_attribute5             IN    pa_task_types.attribute5%TYPE               := NULL
 ,p_attribute6             IN    pa_task_types.attribute6%TYPE               := NULL
 ,p_attribute7             IN    pa_task_types.attribute7%TYPE               := NULL
 ,p_attribute8             IN    pa_task_types.attribute8%TYPE               := NULL
 ,p_attribute9             IN    pa_task_types.attribute9%TYPE               := NULL
 ,p_attribute10            IN    pa_task_types.attribute10%TYPE              := NULL
 ,p_attribute11            IN    pa_task_types.attribute11%TYPE              := NULL
 ,p_attribute12            IN    pa_task_types.attribute12%TYPE              := NULL
 ,p_attribute13            IN    pa_task_types.attribute13%TYPE              := NULL
 ,p_attribute14            IN    pa_task_types.attribute14%TYPE              := NULL
 ,p_attribute15            IN    pa_task_types.attribute15%TYPE              := NULL
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'         -- 3279978 : Added Object Type and Progress Rollup Method
 ,p_api_version            IN    NUMBER                                      := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                    := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                    := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                    := FND_API.G_TRUE
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE      :=NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Task_Type
 (p_Task_Type_id           IN    pa_task_types.Task_Type_id%TYPE           := NULL
 ,p_api_version            IN    NUMBER                                    := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                  := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                  := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                  := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE CREATE_DELIVERABLE_TYPE
(p_api_version                     IN   NUMBER                                      := 1.0
,p_init_msg_list                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN   VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_validation_level                IN   NUMBER                                      := FND_API.G_VALID_LEVEL_FULL
,p_calling_module                  IN   VARCHAR2                                    := 'SELF_SERVICE'
,p_debug_mode                      IN   VARCHAR2                                    := 'N'
,p_max_msg_count                   IN   NUMBER                                      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_deliverable_type_name           IN   PA_TASK_TYPES.TASK_TYPE%TYPE
,p_prog_entry_enable_flag          IN   PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE   := 'N'
,p_initial_deliverable_status      IN   PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE      := 'DLVR_NOT_STARTED'
,p_deliverable_type_class          IN   PA_TASK_TYPES.TASK_TYPE_CLASS_CODE%TYPE     := 'ITEM'
,p_enable_dlvr_actions_flag        IN   PA_TASK_TYPES.ENABLE_DLVR_ACTIONS_FLAG%TYPE := 'N'
,p_effective_from                  IN   PA_TASK_TYPES.START_DATE_ACTIVE%TYPE
,p_effective_to                    IN   PA_TASK_TYPES. END_DATE_ACTIVE %TYPE        := NULL
,p_description                     IN   PA_TASK_TYPES.DESCRIPTION%TYPE              := NULL
,p_deliverable_type_id             IN   PA_TASK_TYPES.TASK_TYPE_ID%TYPE             := NULL
,p_record_version_number           IN   PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE    := 1
,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE UPDATE_DELIVERABLE_TYPE
(p_api_version                     IN   NUMBER                                      := 1.0
,p_init_msg_list                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN   VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_validation_level                IN   NUMBER                                      := FND_API.G_VALID_LEVEL_FULL
,p_calling_module                  IN   VARCHAR2                                    := 'SELF_SERVICE'
,p_debug_mode                      IN   VARCHAR2                                    := 'N'
,p_max_msg_count                   IN   NUMBER                                      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_deliverable_type_name           IN   PA_TASK_TYPES.TASK_TYPE%TYPE
,p_prog_entry_enable_flag          IN   PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE   := 'N'
,p_initial_deliverable_status      IN   PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE      := 'DLVR_NOT_STARTED'
,p_deliverable_type_class          IN   PA_TASK_TYPES.TASK_TYPE_CLASS_CODE%TYPE     := 'ITEM'
,p_enable_dlvr_actions_flag        IN   PA_TASK_TYPES.ENABLE_DLVR_ACTIONS_FLAG%TYPE := 'N'
,p_effective_from                  IN   PA_TASK_TYPES.START_DATE_ACTIVE%TYPE
,p_effective_to                    IN   PA_TASK_TYPES. END_DATE_ACTIVE %TYPE        := NULL
,p_description                     IN   PA_TASK_TYPES.DESCRIPTION%TYPE              := NULL
,p_deliverable_type_id             IN   PA_TASK_TYPES.TASK_TYPE_ID%TYPE
,p_record_version_number           IN   PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE
,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE DELETE_DELIVERABLE_TYPE
(p_api_version                     IN   NUMBER                                      := 1.0
,p_init_msg_list                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN   VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_validation_level                IN   NUMBER                                      := FND_API.G_VALID_LEVEL_FULL
,p_calling_module                  IN   VARCHAR2                                    := 'SELF_SERVICE'
,p_debug_mode                      IN   VARCHAR2                                    := 'N'
,p_max_msg_count                   IN   NUMBER                                      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_deliverable_type_id             IN   PA_TASK_TYPES.TASK_TYPE_ID%TYPE
,p_record_version_number           IN   PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE
,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE CR_UP_DELIVERABLE_TYPE
(p_api_version                     IN   NUMBER                                      := 1.0
,p_init_msg_list                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN   VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN   VARCHAR2                                    := FND_API.G_TRUE
,p_validation_level                IN   NUMBER                                      := FND_API.G_VALID_LEVEL_FULL
,p_calling_module                  IN   VARCHAR2                                    := 'SELF_SERVICE'
,p_debug_mode                      IN   VARCHAR2                                    := 'N'
,p_max_msg_count                   IN   NUMBER                                      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_deliverable_type_name           IN   PA_TASK_TYPES.TASK_TYPE%TYPE
,p_prog_entry_enable_flag          IN   PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE   := 'N'
,p_initial_deliverable_status      IN   PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE      := 'DLVR_NOT_STARTED'
,p_deliverable_type_class          IN   PA_TASK_TYPES.TASK_TYPE_CLASS_CODE%TYPE     := 'ITEM'
,p_enable_dlvr_actions_flag        IN   PA_TASK_TYPES.ENABLE_DLVR_ACTIONS_FLAG%TYPE := 'N'
,p_effective_from                  IN   PA_TASK_TYPES.START_DATE_ACTIVE%TYPE
,p_effective_to                    IN   PA_TASK_TYPES. END_DATE_ACTIVE %TYPE        := NULL
,p_description                     IN   PA_TASK_TYPES.DESCRIPTION%TYPE              := NULL
,p_deliverable_type_id             IN   PA_TASK_TYPES.TASK_TYPE_ID%TYPE             := NULL
,p_insert_or_update                IN   VARCHAR2                                    := 'INSERT'
,p_record_version_number           IN   PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE    :=1
,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_TASK_TYPE_PUB;

 

/
