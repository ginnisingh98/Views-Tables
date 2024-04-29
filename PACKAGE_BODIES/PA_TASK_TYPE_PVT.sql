--------------------------------------------------------
--  DDL for Package Body PA_TASK_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_TYPE_PVT" AS
/*$Header: PATTPVTB.pls 120.1 2005/08/19 17:06:31 mwasowic noship $*/

 g_module_name   VARCHAR2(100) := 'PA_TASK_TYPE_PVT';  --Bug 3279978 FPM Development

 INV_ARG_EXC EXCEPTION;

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
 ,p_task_prog_entry_page_name     IN    pa_page_layouts.page_name%TYPE               := NULL
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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'      -- 3279978 : Added Object Type and Progress Rollup Method
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_task_type_id          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_msg_index_out   NUMBER;

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPE_PVT.Create_Task_Type.begin'
                     ,x_msg         => 'Beginning of Create_Task_Type pvt'
                     ,x_log_level   => 5);


  PA_TASK_TYPE_PKG.insert_row
          (p_task_type                     => p_task_type
          ,p_start_date_active             => p_start_date_active
          ,p_end_date_active               => p_end_date_active
          ,p_description                   => p_description
          ,p_task_type_class_code          => p_task_type_class_code
          ,p_initial_status_code           => p_initial_status_code
          ,p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => p_task_prog_entry_page_id
          ,p_task_prog_entry_page_name     => p_task_prog_entry_page_name --this parameter was missing ,Hence inserted
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => p_task_weighting_deriv_code
          ,p_remain_effort_enable_flag     => p_remain_effort_enable_flag
          ,p_attribute_category     =>   p_attribute_category
          ,p_attribute1             =>   p_attribute1
          ,p_attribute2             =>   p_attribute2
          ,p_attribute3             =>   p_attribute3
          ,p_attribute4             =>   p_attribute4
          ,p_attribute5             =>   p_attribute5
          ,p_attribute6             =>   p_attribute6
          ,p_attribute7             =>   p_attribute7
          ,p_attribute8             =>   p_attribute8
          ,p_attribute9             =>   p_attribute9
          ,p_attribute10            =>   p_attribute10
          ,p_attribute11            =>   p_attribute11
          ,p_attribute12            =>   p_attribute12
          ,p_attribute13            =>   p_attribute13
          ,p_attribute14            =>   p_attribute14
          ,p_attribute15            =>   p_attribute15
          ,p_object_type            =>   p_object_type              -- 3279978 : Added Object Type and Progress Rollup Method
          ,p_wf_item_type           =>   p_wf_item_type
          ,p_wf_process             =>   p_wf_process
          ,p_wf_lead_days           =>   p_wf_lead_days
          ,x_task_type_id           =>   x_task_type_id
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);

  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PVT.Create_Task_Type'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Create_Task_Type;


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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'    -- 3279978 : Added Object Type and Progress Rollup Method
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

 l_msg_index_out          NUMBER;

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PVT.Update_Task_Type.begin'
                     ,x_msg         => 'Beginning of Update_Task_Type pvt'
                     ,x_log_level   => 5);


  PA_TASK_TYPE_PKG.update_row
          (p_task_type_id                  => p_task_type_id
          ,p_task_type                     => p_task_type
          ,p_start_date_active             => p_start_date_active
          ,p_end_date_active               => p_end_date_active
          ,p_description                   => p_description
          ,p_task_type_class_code          => p_task_type_class_code
          ,p_initial_status_code           => p_initial_status_code
          ,p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => p_task_prog_entry_page_id
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => p_task_weighting_deriv_code
          ,p_remain_effort_enable_flag     => p_remain_effort_enable_flag
          ,p_attribute_category     =>   p_attribute_category
          ,p_attribute1             =>   p_attribute1
          ,p_attribute2             =>   p_attribute2
          ,p_attribute3             =>   p_attribute3
          ,p_attribute4             =>   p_attribute4
          ,p_attribute5             =>   p_attribute5
          ,p_attribute6             =>   p_attribute6
          ,p_attribute7             =>   p_attribute7
          ,p_attribute8             =>   p_attribute8
          ,p_attribute9             =>   p_attribute9
          ,p_attribute10            =>   p_attribute10
          ,p_attribute11            =>   p_attribute11
          ,p_attribute12            =>   p_attribute12
          ,p_attribute13            =>   p_attribute13
          ,p_attribute14            =>   p_attribute14
          ,p_attribute15            =>   p_attribute15
          ,p_object_type            =>   p_object_type          -- 3279978 : Added Object Type and Progress Rollup Method
          ,p_wf_item_type           =>   p_wf_item_type
          ,p_wf_process             =>   p_wf_process
          ,p_wf_lead_days           =>   p_wf_lead_days
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);


  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PVT.Update_Task_Type'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Update_Task_Type;


PROCEDURE Delete_Task_Type
 (p_Task_Type_id           IN    pa_task_types.Task_Type_id%TYPE           := NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_msg_index_out          NUMBER;

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_task_types_PVT.Delete_Task_Type.begin'
                     ,x_msg         => 'Beginning of Delete_Task_Type pvt'
                     ,x_log_level   => 5);


  PA_TASK_TYPE_PKG.delete_row
          (p_task_type_id           =>   p_task_type_id
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);


  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PVT.Delete_Task_Type'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Delete_Task_Type;

-- Procedure            : CREATE_DELIVERABLE_TYPE
-- Type                 : private Procedure
-- Purpose              : This is the private API used to create the deliverable type .
-- Note                 : If the deliverable type name is unique and date range is valid then
--                        this API places call to the table handler insert_row in PA_TASK_TYPES_PKG
-- Assumptions          : None
-- List of parameters other than standard IN and OUT parameters
-- Parameters                            Type                                      Null?    Default Value          Description and Purpose
-- ---------------------------         ------------------------------------------  ------   --------------      ----------------------------
--P_deliverable_type_name		PA_TASK_TYPES.TASK_TYPE%TYPE		     N	                          Deliverable Type Name
--P_prog_entry_enable_flag              PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE    Y		'N'               Progress Entry Flag
--P_initial_deliverable_status_code	PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE	     N		'DLVR_NOT_STARTED'Initial Deliverable Status
--P_deliverable_type_class_code		PA_TASK_TYPES.TASK_TYPE_CLASS_CODE%TYPE      Y		'ITEM'            Deliverable Type Class
--P_enable_deliverable_actions		PA_TASK_TYPES.ENABLE_DLVR_ACTIONS%TYPE	     Y		'N'               Enable Deliverable Action
--P_effective_from              	PA_TASK_TYPES.START_DATE_ACTIVE%TYPE         N 				  Effective from date
--p_effective_to			PA_TASK_TYPES. END_DATE_ACTIVE %TYPE         Y	        NULL              Effective to date
--P_description				PA_TASK_TYPES.DESCRIPTION%TYPE		     Y		NULL              Description
--P_deliverable_type_id		        PA_TASK_TYPES.TASK_TYPE_ID%TPE		     Y          NULL


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
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
 l_msg_index_out                   NUMBER;
 l_debug_mode                      VARCHAR2(1);

 l_return_status                   VARCHAR2(1);
 l_msg_count                       NUMBER;
 l_data                            VARCHAR2(2000);
 l_msg_data                        VARCHAR2(2000);
 l_task_type_id_dummy              PA_TASK_TYPES.TASK_TYPE_ID%TYPE ;

 l_debug_level2                    CONSTANT NUMBER := 2;
 l_debug_level3                    CONSTANT NUMBER := 3;
 l_debug_level4                    CONSTANT NUMBER := 4;
 l_debug_level5                    CONSTANT NUMBER := 5;

 BEGIN
     -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Define the savepoint
     IF (p_commit = FND_API.G_TRUE)
     THEN
          SAVEPOINT CREATE_DELIVERABLE_TYPE;
     END IF;

     --Log message
     l_debug_mode  :=p_debug_mode;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'CREATE_DELIVERABLE_TYPE : Printing Input parameters';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_name'||':'||p_deliverable_type_name,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_prog_entry_enable_flag'||':'||p_prog_entry_enable_flag,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_initial_deliverable_status'||':'||p_initial_deliverable_status,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_class'||':'||p_deliverable_type_class,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_enable_dlvr_actions_flag'||':'||p_enable_dlvr_actions_flag,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_effective_from'||':'||p_effective_from,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_effective_to'||':'||p_effective_to,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_description'||':'||p_description,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_id'||':'||p_deliverable_type_id,
                                     l_debug_level3);
     END IF;

     -- Initialize the Message Stack
     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
          FND_MSG_PUB.initialize;
     END IF;

     --Check whether any of  p_deliverable_type_name,start date is null
     --If it is null,then raise Invalid parameter exception
     IF (p_deliverable_type_name IS NULL) OR (p_effective_from IS NULL)THEN
          RAISE INV_ARG_EXC;
     END IF;

     --Check if Deliverable Type name is unique
     l_return_status := PA_DELIVERABLE_UTILS.IS_DLV_TYPE_NAME_UNIQUE (p_deliverable_type_name);
     IF(l_return_status = 'N')
     THEN
          PA_UTILS.ADD_MESSAGE
          (p_app_short_name => 'PA',
           p_msg_name     => 'PA_DLV_TYPE_EXISTS');
           x_return_status :=FND_API.G_RET_STS_ERROR;
     END IF;

     PA_DEBUG.WRITE(g_module_name,'After Unique Chk',
                                     l_debug_level3);
     --Check if the date range is valid
     l_return_status :=PA_DELIVERABLE_UTILS.IS_EFF_FROM_TO_DATE_VALID(p_effective_from,p_effective_to);
     IF(l_return_status = 'N')
     THEN
          PA_UTILS.ADD_MESSAGE
          (p_app_short_name => 'PA',
          p_msg_name     => 'PA_TT_INVALID_DATES');
          x_return_status :=FND_API.G_RET_STS_ERROR;
     END IF;

     IF(x_return_status = FND_API.G_RET_STS_ERROR)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     PA_DEBUG.WRITE(g_module_name,'Before Insert',
                                   l_debug_level3);
     --Call the PA_TASK_TYPE_PKG.insert_row
     PA_TASK_TYPE_PKG.insert_row
     (p_task_type_id               => p_deliverable_type_id
     ,p_task_type                  => p_deliverable_type_name
     ,p_start_date_active          => p_effective_from
     ,p_end_date_active            => p_effective_to
     ,p_description                => p_description
     ,p_task_type_class_code       => p_deliverable_type_class
     ,p_initial_status_code        => p_initial_deliverable_status
     ,p_prog_entry_enable_flag     => p_prog_entry_enable_flag
     ,p_enable_dlvr_actions_flag   => p_enable_dlvr_actions_flag
     ,p_object_type                => 'PA_DLVR_TYPES'
     ,p_record_version_number      => p_record_version_number
     ,x_task_type_id               => l_task_type_id_dummy
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     );

      PA_DEBUG.WRITE(g_module_name,'After Insert',
                                     l_debug_level3);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

 EXCEPTION
  -- Set the exception Message and the stack
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_msg_count := FND_MSG_PUB.count_msg;

          --  Rollback to the savepoint defined
          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO CREATE_DELIVERABLE_TYPE;
          END IF;

          IF l_msg_count = 1 AND x_msg_data IS NULL
          THEN
               Pa_Interface_Utils_Pub.get_messages
               ( p_encoded        => Fnd_Api.G_TRUE
               , p_msg_index      => 1
               , p_msg_count      => l_msg_count
               , p_msg_data       => l_msg_data
               , p_data           => l_data
               , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.reset_curr_function;
          END IF;
          RETURN;

     WHEN INV_ARG_EXC THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_TASK_TYPE_PVT : CREATE_DELIVERABLE_TYPE : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO CREATE_DELIVERABLE_TYPE;
          END IF;


          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name        => 'PA_TASK_TYPE_PVT'
          , p_procedure_name  => 'CREATE_DELIVERABLE_TYPE'
          , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                           l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
     RAISE;

     WHEN OTHERS THEN
          -- Set the exception Message and the stack
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          --Rollback to the savepoint defined
          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO CREATE_DELIVERABLE_TYPE;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name        => 'PA_TASK_TYPE_PVT'
          , p_procedure_name  => 'CREATE_DELIVERABLE_TYPE'
          , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level5);
          Pa_Debug.reset_curr_function;
          END IF;
     RAISE;

 END CREATE_DELIVERABLE_TYPE;

-- Procedure            : UPDATE_DELIVERABLE_TYPE
-- Type                 : Private Procedure
-- Purpose              : This is the private API used to update the deliverable type .
-- Note                 : 1)If there is a change in the deliverable type name,check for uniqueness
--                        2)If there is a change in the date range,check for validity
--                        3)If the Deliverable Type Class has changed and it is in use,throw error
--                        4)If Enable Deliverable actions was previously checked and now unchecked
--                          check whether there exists any deliverable of this type which has actions
--                          associated with it.If Yes ,Throw Error.Else delete those actions
--                        5)If the Enable Progress Entry changes from Checked to UNCHECKED
--                          then check whether any deliverable of this type p_deliverable_type_id
--                          has been associated with a Deliverable-based task.If Yes,Throw error
-- Assumptions          : None
-- List of parameters other than standard IN and OUT parameters
-- Parameters                            Type                                      Null?       Default Value     Description and Purpose
-- ---------------------------         --------                                    ------     ---------------   ----------------------------
--P_deliverable_type_name	      PA_TASK_TYPES.TASK_TYPE%TYPE		   N			        Deliverable Type Name
--P_prog_entry_enable_flag            PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE	   Y		'N'	        Progress Entry Flag
--P_initial_deliverable_status_code   PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE       Y	        'DLVR_NOT_STARTED'Initial Deliverable Status
--P_enable_deliverable_actions        PA_TASK_TYPES.ENABLE_DLVR_ACTIONS%TYPE       Y		'N'		 Enable Deliverable Action
--P_effective_from		      PA_TASK_TYPES.START_DATE_ACTIVE%TYPE	   N				 Effective from date
--p_effective_to	              PA_TASK_TYPES. END_DATE_ACTIVE %TYPE         Y		NULL		 Effective to date
--P_description			      PA_TASK_TYPES.DESCRIPTION%TYPE		   Y		NULL		 Description
--P_deliverable_type_id		      PA_TASK_TYPES.TASK_TYPE_ID%TPE		   N

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
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
 l_msg_index_out                   NUMBER;
 l_debug_mode                      VARCHAR2(1);

 l_dummy                           VARCHAR2(1);
 l_return_status                   VARCHAR2(1);
 l_msg_count                       NUMBER;
 l_data                            VARCHAR2(2000);
 l_msg_data                        VARCHAR2(2000);

 l_debug_level2                    CONSTANT NUMBER := 2;
 l_debug_level3                    CONSTANT NUMBER := 3;
 l_debug_level4                    CONSTANT NUMBER := 4;
 l_debug_level5                    CONSTANT NUMBER := 5;

 l_allow_prog_entry_disable        VARCHAR2(1) := 'N' ; -- Bug 3627161
 --This cursor is defined to find existence of any progress related records
 -- for a deliverable of type p_deliverable_type_id

 Cursor c_progress_rec_exists IS
 SELECT 'X'
 FROM dual
 WHERE EXISTS
             (SELECT proj_element_id
             FROM pa_proj_elements
             WHERE TYPE_ID=p_deliverable_type_id
             AND OBJECT_TYPE='PA_DELIVERABLES'
             AND 'Y' = (pa_deliverable_utils.IS_DELIVERABLE_HAS_PROGRESS(PROJECT_ID,PROJ_ELEMENT_ID)));

 --The cursor takes the original values from the database

 Cursor c_original_value_rec IS
 SELECT TASK_TYPE
      ,START_DATE_ACTIVE
	 ,END_DATE_ACTIVE
	 ,INITIAL_STATUS_CODE
	 ,TASK_TYPE_CLASS_CODE
	 ,ENABLE_DLVR_ACTIONS_FLAG
	 ,PROG_ENTRY_ENABLE_FLAG
 FROM   PA_TASK_TYPES
 WHERE TASK_TYPE_ID = p_deliverable_type_id
 AND   OBJECT_TYPE = 'PA_DLVR_TYPES';

 l_original_value_rec  c_original_value_rec%ROWTYPE ;

BEGIN

     -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --Log message
     l_debug_mode  := p_debug_mode;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.set_curr_function( p_function   => 'UPDATE_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'PA_TASK_TYPES_PVT.UPDATE_DELIVERABLE_TYPE : Printing Input parameters';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_name'||':'||p_deliverable_type_name,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_prog_entry_enable_flag'||':'||p_prog_entry_enable_flag,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_initial_deliverable_status'||':'||p_initial_deliverable_status,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_class'||':'||p_deliverable_type_class,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_enable_dlvr_actions_flag'||':'||p_enable_dlvr_actions_flag,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_effective_from'||':'||p_effective_from,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_effective_to'||':'||p_effective_to,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_description'||':'||p_description,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_id'||':'||p_deliverable_type_id,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_record_version_number'||':'||p_record_version_number,
                                     l_debug_level3);

     END IF;

     -- Initialize the Message Stack
     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     -- Save point
     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint UPDATE_DELIVERABLE_TYPE;
     END IF;

     PA_DEBUG.WRITE(g_module_name,'After issuing save point in UPDATE_DLV_TYPE :PA_TASK_TYPES_PVT',
                                                                                    l_debug_level3);

     --the cursor contents into local variable
     OPEN c_original_value_rec;
     FETCH c_original_value_rec into l_original_value_rec ;
     CLOSE c_original_value_rec;

     PA_DEBUG.WRITE(g_module_name,'After fetching the cursor value in to local variable',
                                                                         l_debug_level3);

     --Check whether Deliverable Type Id or record version number or deliverable type name or start date is null.
     --If Yes,then due to some internal error it is lost,so throw error
     IF (p_deliverable_type_id IS NULL) OR (p_record_version_number IS NULL)
        OR (p_deliverable_type_name IS NULL) OR (p_effective_from IS NULL)
     THEN
          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'PA_TASK_TYPES_PVT : UPDATE_DELIVERABLE_TYPE : The DeliverableTypeID/NAME/Startdate/RecVersionNumber is null';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                                      l_debug_level3);
          END IF;
     RAISE INV_ARG_EXC;
     END IF;

     -- If the Deliverable Type Name has changed
     -- then check for unique name
	IF l_original_value_rec.TASK_TYPE <> p_deliverable_type_name
     THEN
	     l_return_status := PA_DELIVERABLE_UTILS.IS_DLV_TYPE_NAME_UNIQUE (p_deliverable_type_name);
          IF(l_return_status = 'N')
          THEN
               PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA'
               ,p_msg_name     => 'PA_DLV_TYPE_EXISTS');

               x_return_status :=FND_API.G_RET_STS_ERROR;
          END IF;
     END IF;
     PA_DEBUG.WRITE(g_module_name,'After Checking for unique name',
                                                  l_debug_level3);

     --If the date values have changed then check for valid dates

     IF TRUNC(p_effective_to) IS NOT NULL
     THEN
          IF (TRUNC(l_original_value_rec.START_DATE_ACTIVE) <> TRUNC(p_effective_from)) OR (l_original_value_rec.END_DATE_ACTIVE IS NULL)
              OR (l_original_value_rec.END_DATE_ACTIVE IS NOT NULL AND TRUNC(l_original_value_rec.END_DATE_ACTIVE) <> TRUNC(p_effective_to))
          THEN
               l_return_status :=PA_DELIVERABLE_UTILS.IS_EFF_FROM_TO_DATE_VALID(p_effective_from,p_effective_to);
               IF(l_return_status = 'N')
               THEN
                    PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA'
                    ,p_msg_name     => 'PA_TT_INVALID_DATES');

                    x_return_status :=FND_API.G_RET_STS_ERROR;
               END IF;
          END IF;
     END IF;
     PA_DEBUG.WRITE(g_module_name,'After checking for invalid dates',
                                                    l_debug_level3);

     --If the Deliverable Type Class has changed then check whether it is in use
     --If Yes,Throw Error
     If l_original_value_rec.TASK_TYPE_CLASS_CODE <> p_deliverable_type_class
     THEN
          l_return_status :=PA_DELIVERABLE_UTILS.IS_DLV_TYPE_IN_USE(p_deliverable_type_id);
          If  (l_return_status='Y' )
          THEN
               PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA'
               ,p_msg_name      => 'PA_DLV_TYPE_CLASS_IN_USE');

               x_return_status :=FND_API.G_RET_STS_ERROR;
          END IF;
     END IF;

     --If the Enable Progress Entry changes from Checked to UNCHECKED then
     --1) check whether any deliverable of this type p_deliverable_type_id
     --has been associated with a Deliverable-based task
     --If Yes,Throw error

     --2)check whether any deliverable of this type has progress records
     --If Yes,throw Error
     IF  p_prog_entry_enable_flag = 'N' AND l_original_value_rec.PROG_ENTRY_ENABLE_FLAG = 'Y'
     THEN
          -- Bug#3555460
          -- Relaxed the check that enable progress entry cannot
          -- cannot be unchecked if deliverbale type is used by
          -- deliverables which are associated to deliverable based task.

          -- l_return_status :=PA_DELIVERABLE_UTILS.IS_DLV_BASED_ASSCN_EXISTS(p_deliverable_type_id);
          -- IF(l_return_status='Y')
          -- THEN
          --      PA_UTILS.ADD_MESSAGE
          --      (p_app_short_name => 'PA'
          --     ,p_msg_name      => 'PA_DLV_BASED_ASSN_EXISTS');

          -- x_return_status :=FND_API.G_RET_STS_ERROR;
          -- END IF;

          OPEN c_progress_rec_exists;
          FETCH c_progress_rec_exists INTO l_dummy;

          IF c_progress_rec_exists%found
          THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name => 'PA_DLV_TYPE_PROG_ERR');
               x_return_status := FND_API.G_RET_STS_ERROR;

               IF l_debug_mode = 'Y'
               THEN
                    Pa_Debug.g_err_stage:= ' Error:PA_DLV_TYPE_PROG_ERR';
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                                       l_debug_level5);
               END IF;
          ELSE  -- Bug 3627161
               l_allow_prog_entry_disable := 'Y' ;
          END IF;

          CLOSE c_progress_rec_exists;

          -- Bug 3627161 If Unchecking the Enable Progress Entry Flag is allowed ,
	  -- (i.e) If no progress records exist for any of the deliverables of this type,then
          -- Null Out the Progress weight for all deliverables of this type

	  IF l_allow_prog_entry_disable = 'Y' THEN
               UPDATE PA_PROJ_ELEMENTS SET PROGRESS_WEIGHT = NULL
               WHERE type_id = p_deliverable_type_id
               AND OBJECT_TYPE = 'PA_DELIVERABLES'
               AND PROGRESS_WEIGHT IS NOT NULL ;
          END IF ;

     END IF;

     --If the Enable Deliverable Actions changes from CHECKED to UNCHECKED
     --then check whether there exists any deliverable of this type which has actions associated with it
     --If Yes ,Throw Error
     --Else delete those actions
	IF  p_enable_dlvr_actions_flag = 'N'  AND  l_original_value_rec.ENABLE_DLVR_ACTIONS_FLAG = 'Y'
     THEN
          l_return_status :=PA_DELIVERABLE_UTILS.IS_DLV_ACTIONS_EXISTS(p_deliverable_type_id);
          IF (l_return_status='Y')
          THEN
               PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA'
               ,p_msg_name      => 'PA_DLV_ACTION_EXISTS');

          x_return_status:=FND_API.G_RET_STS_ERROR;
          ELSE

               --before placing call to API check for any errors
               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
               THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

               --Place a Call to Delete Deliverable Actions
               PA_ACTIONS_PUB.DELETE_DLV_ACTIONS_IN_BULK
               (p_api_version      => p_api_version
               ,p_init_msg_list    => FND_API.G_FALSE
               ,p_commit           => p_commit
               ,p_validate_only    => p_validate_only
               ,p_validation_level => p_validation_level
               ,p_calling_module   => p_calling_module
               ,p_debug_mode       => l_debug_mode
               ,p_max_msg_count    => p_max_msg_count
               ,p_object_id        => p_deliverable_type_id
               ,p_object_type      => 'PA_DLVR_TYPES'
               ,x_return_status    => x_return_status
               ,x_msg_data         => x_msg_data
               ,x_msg_count        => x_msg_count);

               --After API execution check for errors
               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
               THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;
          END IF;
     END IF;

     IF(x_return_status=FND_API.G_RET_STS_ERROR)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     --Call PA_TASK_TYPE_PKG.update_row
     PA_TASK_TYPE_PKG.update_row
     (p_task_type_id               => p_deliverable_type_id
     ,p_task_type                  => p_deliverable_type_name
     ,p_start_date_active          => p_effective_from
     ,p_end_date_active            => p_effective_to
     ,p_description                => p_description
     ,p_task_type_class_code       => p_deliverable_type_class
     ,p_initial_status_code        => p_initial_deliverable_status
     ,p_prog_entry_enable_flag     => p_prog_entry_enable_flag
     ,p_enable_dlvr_actions_flag   => p_enable_dlvr_actions_flag
     ,p_object_type                => 'PA_DLVR_TYPES'
     ,p_record_version_number      => p_record_version_number
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_msg_count := FND_MSG_PUB.count_msg;

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE;
          END IF;

          IF c_original_value_rec%ISOPEN
          THEN
               CLOSE c_original_value_rec;
          END IF;

          IF c_progress_rec_exists%ISOPEN
          THEN
               CLOSE c_progress_rec_exists;
          END IF;

         IF l_msg_count = 1 AND x_msg_data IS NULL
         THEN
               Pa_Interface_Utils_Pub.get_messages
               ( p_encoded        => Fnd_Api.G_TRUE
               , p_msg_index      => 1
               , p_msg_count      => l_msg_count
               , p_msg_data       => l_msg_data
               , p_data           => l_data
               , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.reset_curr_function;
          END IF;

     WHEN INV_ARG_EXC THEN
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_TASK_TYPE_PVT : UPDATE_DELIVERABLE_TYPE : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE;
          END IF;

          IF c_original_value_rec%ISOPEN
          THEN
               CLOSE c_original_value_rec;
          END IF;

          IF c_progress_rec_exists%ISOPEN
          THEN
               CLOSE c_progress_rec_exists;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name        => 'PA_TASK_TYPE_PVT'
          , p_procedure_name  => 'UPDATE_DELIVERABLE_TYPE'
          , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                                  l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
     RAISE;

     WHEN OTHERS THEN
       -- Set the exception Message and the stack
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE;
          END IF;

          IF c_original_value_rec%ISOPEN
          THEN
               CLOSE c_original_value_rec;
          END IF;

          IF c_progress_rec_exists%ISOPEN
          THEN
               CLOSE c_progress_rec_exists;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
          (p_pkg_name          => 'PA_TASK_TYPE_PVT'
          , p_procedure_name  => 'UPDATE_DELIVERABLE_TYPE'
          , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                                  l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
     RAISE;

 END UPDATE_DELIVERABLE_TYPE;

-- Procedure            : DELETE_DELIVERABLE_TYPE
-- Type                 : Private Procedure
-- Purpose              : This is the private API used to delete the deliverable type .
-- Note                 : This procedure places call to delete deliverable actions API
--                        to delete the actions which are associated with the deliverable Type
--                        and then deletes the deliverable type by placing call to PA_TASK_TYPE_PKG.delete_row
-- Assumptions          : None
-- List of parameters other than standard IN and OUT parameters
-- Parameters                            Type                                      Null?        Description and Purpose
-- ---------------------------         -------------------------------            --------  -----------------------------------
--P_deliverable_type_id		        PA_TASK_TYPES.TASK_TYPE_ID%TYPE		     N  	Deliverable Type Id
--p_record_version_number            PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE     N          Record Version Number

 PROCEDURE DELETE_DELIVERABLE_TYPE
 (p_api_version                     IN       NUMBER                                      := 1.0
 ,p_init_msg_list                   IN       VARCHAR2                                    := FND_API.G_TRUE
 ,p_commit                          IN       VARCHAR2                                    := FND_API.G_FALSE
 ,p_validate_only                   IN       VARCHAR2                                    := FND_API.G_TRUE
 ,p_validation_level                IN       NUMBER                                      := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                  IN       VARCHAR2                                    := 'SELF_SERVICE'
 ,p_debug_mode                      IN       VARCHAR2                                    := 'N'
 ,p_max_msg_count                   IN       NUMBER                                      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_deliverable_type_id             IN       pa_task_types.Task_Type_id%TYPE
 ,p_record_version_number           IN       PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE
 ,x_return_status                   OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                       OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                        OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
 l_msg_index_out                    NUMBER;
 l_debug_mode                       VARCHAR2(1);

 l_msg_count                        NUMBER;
 l_data                             VARCHAR2(2000);
 l_msg_data                         VARCHAR2(2000);
 l_return_status                    VARCHAR2(1);

 l_debug_level2                     CONSTANT NUMBER := 2;
 l_debug_level3                     CONSTANT NUMBER := 3;
 l_debug_level4                     CONSTANT NUMBER := 4;
 l_debug_level5                     CONSTANT NUMBER := 5;
BEGIN
  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log message
     l_debug_mode  :=p_debug_mode;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;
     --savepoint
     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint DELETE_DELIVERABLE_TYPE;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'PA_TASK_TYPE_PVT.DELETE_DELIVERABLE_TYPE : Printing Input parameters';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_id'||':'||p_deliverable_type_id,
                                             l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_record_version_number'||':'||p_record_version_number,
                                             l_debug_level3);
     END IF;

     --Initialize the Message Stack
     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'BEFORE CALLING PA_ACTIONS_PUB.DELETE_DLV_ACTIONS';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level3);
     END IF;
     --Call Delete Deliverable Actions API
     PA_ACTIONS_PUB.DELETE_DLV_ACTIONS_IN_BULK
     (p_api_version      => p_api_version
     ,p_init_msg_list    => FND_API.G_FALSE
     ,p_commit           => p_commit
     ,p_validate_only    => p_validate_only
     ,p_validation_level => p_validation_level
     ,p_calling_module   => p_calling_module
     ,p_debug_mode       => l_debug_mode
     ,p_max_msg_count    => p_max_msg_count
     ,p_object_id        => p_deliverable_type_id
     ,p_object_type      => 'PA_DLVR_TYPES'
     ,x_return_status    => x_return_status
     ,x_msg_data         => x_msg_data
     ,x_msg_count        => x_msg_count);

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'AFTER RETURNING FROM PA_ACTIONS_PUB.DELETE_DLV_ACTIONS';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level3);
     END IF;

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     --Call PA_TASK_TYPE_PKG.DELETE_ROW(p_deliverable_type_id)
     PA_TASK_TYPE_PKG.delete_row
     (p_task_type_id  => p_deliverable_type_id
     ,p_record_version_number => p_record_version_number
     ,x_return_status => x_return_status
     ,x_msg_data     => x_msg_data
     ,x_msg_count     => x_msg_count);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;
     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_msg_count := FND_MSG_PUB.count_msg;

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO DELETE_DELIVERABLE_TYPE;
          END IF;

          IF l_msg_count = 1 AND x_msg_data IS NULL
          THEN
                    Pa_Interface_Utils_Pub.get_messages
                   ( p_encoded        => Fnd_Api.G_TRUE
                   , p_msg_index      => 1
                   , p_msg_count      => l_msg_count
                   , p_msg_data       => l_msg_data
                   , p_data           => l_data
                   , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.reset_curr_function;
          END IF;

     WHEN OTHERS THEN
       -- Set the exception Message and the stack
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO DELETE_DELIVERABLE_TYPE;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name         => 'PA_TASK_TYPE_PVT'
          , p_procedure_name  => 'DELETE_DELIVERABLE_TYPE'
          , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y'
          THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
     RAISE;
 END DELETE_DELIVERABLE_TYPE;
END PA_TASK_TYPE_PVT;

/
