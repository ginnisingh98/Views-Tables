--------------------------------------------------------
--  DDL for Package PA_TASK_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_TYPE_PKG" AUTHID CURRENT_USER AS
/*$Header: PATTPKGS.pls 120.1 2005/08/19 17:06:18 mwasowic noship $*/

PROCEDURE insert_row
 (p_task_type_id                  IN    pa_task_types.task_type_id%TYPE             :=0 --3279978 FP M Development avaithia 29-Dec-2003
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
 ,p_task_prog_entry_page_name     IN    pa_page_layouts.page_name%TYPE                   := NULL
 ,p_wq_enable_flag                IN    pa_task_types.wq_enable_flag%TYPE            := NULL
 ,p_work_item_code                IN    pa_task_types.work_item_code%TYPE            := NULL
 ,p_uom_code                      IN    pa_task_types.uom_code%TYPE                  := NULL
 ,p_actual_wq_entry_code          IN    pa_task_types.actual_wq_entry_code%TYPE      := NULL
 ,p_percent_comp_enable_flag      IN    pa_task_types.percent_comp_enable_flag%TYPE  := NULL
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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'    -- 3279978 : Added Object Type, Progress Rollup Method,
 ,p_enable_dlvr_actions_flag    IN    pa_task_types.enable_dlvr_actions_flag%TYPE      :=NULL           --  Method code columns--modified avaithia 28-dec-2003
 ,p_record_version_number  IN    pa_task_types.record_version_number%TYPE    := 1             -- 3279978 inserted avaithia 28-dec-2003
 ,p_wf_item_type            IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process              IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days            IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_task_type_id          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE update_row
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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'    -- 3279978 : Added Object Type, Progress Rollup Method,
 ,p_enable_dlvr_actions_flag    IN    pa_task_types.enable_dlvr_actions_flag%TYPE      :=NULL           --           Method code columns --modified avaithia 28-dec-2003
 ,p_record_version_number  IN    pa_task_types.record_version_number%TYPE    := 1  -- 3279978 inserted avaithia 28-dec-2003
 ,p_wf_item_type            IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process              IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days            IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE delete_row
 (p_task_type_id           IN    pa_task_types.task_type_id%TYPE
 ,p_record_version_number  IN    pa_task_types.record_version_number%TYPE  :=0 --3279978 inserted avaithia 07-Jan-2004
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END PA_TASK_TYPE_PKG;

 

/
