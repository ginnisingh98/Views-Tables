--------------------------------------------------------
--  DDL for Package Body PA_TASK_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_TYPE_PUB" AS
/*$Header: PATTPUBB.pls 120.3 2006/01/09 05:38:43 vkadimes noship $*/

g_module_name   VARCHAR2(100) := 'PA_TASK_TYPE_PUB';  --Bug 3279978 FPM Enhancement

l_task_type_not_unique  EXCEPTION;
l_task_type_invalid_dates EXCEPTION;
l_prog_entry_enable_error EXCEPTION;
l_prog_entry_req_error EXCEPTION;
l_wq_enable_error  EXCEPTION;
l_remain_effort_enable_error EXCEPTION;
l_percent_comp_enable_error EXCEPTION;
l_delete_task_type_error EXCEPTION;
l_del_upg_task_type_error EXCEPTION;
l_upd_upg_task_type_error EXCEPTION;
l_pagelayout_name_invalid EXCEPTION;
PA_DLV_INV_PARAM_EXC EXCEPTION; --Bug 3279978 FP M Development
l_invalid_lead_day_exc EXCEPTION;
l_delete_delv_type_error EXCEPTION; -- Added for bug 4775641

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
 ,p_api_version            IN    NUMBER                                       := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'   -- 3279978 : Added Object Type and Progress Rollup Method
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
 --Bug: 4537865
 l_new_msg_data    VARCHAR2(2000);
 --Bug: 4537865
 l_error_message_code VARCHAR2(100);
 l_task_prog_entry_page_id pa_page_layouts.page_id%TYPE;
 l_task_weighting_deriv_code pa_task_types.task_weighting_deriv_code%TYPE;
 l_task_type_class_code pa_task_types.task_type_class_code%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_task_type_PUB.Create_Task_Type');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT CREATE_TASK_TYPE_PUB;
  END IF;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PUB.Create_Task_Type.begin'
                     ,x_msg         => 'Beginning of Create_Task_Type pub'
                     ,x_log_level   => 5);


  -- Check whether task_type is unique
  IF PA_TASK_TYPE_UTILS.is_task_type_unique(p_task_type => p_task_type) = 'N' THEN
    RAISE l_task_type_not_unique;
  END IF;

  -- Validate From/To dates
  IF p_end_date_active IS NOT NULL AND TRUNC(p_start_date_active) > TRUNC(p_end_date_active) THEN
    RAISE l_task_type_invalid_dates;
  END IF;

  -- Name/ID validation for task progress entry page layout
  l_task_prog_entry_page_id := p_task_prog_entry_page_id;
  PA_PAGE_LAYOUT_UTILS.check_pagelayout_name_or_id(
     p_pagelayout_name => p_task_prog_entry_page_name,
     p_pagetype_code   => 'AI',
     p_check_id_flag   => 'Y',
     x_pagelayout_id   => l_task_prog_entry_page_id,
     x_return_status   => x_return_status,
     x_error_message_code => l_error_message_code);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE l_pagelayout_name_invalid;
  END IF;

  -- Validate progress attributes.
  PA_TASK_TYPE_UTILS.validate_progress_attributes(
           p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => l_task_prog_entry_page_id
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => p_task_weighting_deriv_code
          ,p_remain_effort_enable_flag     => p_remain_effort_enable_flag
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);

  -- Default task_weighting_deriv_code to 'MANUAL' for all task types.
  IF p_task_weighting_deriv_code IS NULL THEN
    l_task_weighting_deriv_code := 'MANUAL';
  END IF;

  -- Default task_type_class_code to 'MANUAL' for all task types.
  IF p_task_type_class_code IS NULL THEN
    l_task_type_class_code := 'GENERAL';
  END IF;

  -- FP M : 3491609 : Project Execution Workflow Changes
  If nvl(p_wf_lead_days,0)<0 then
     Raise l_invalid_lead_day_exc ;
  end if ;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --Log Message
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PUB.Create_Task_Type.begin'
                     ,x_msg         => 'calling create_Task_Type pvt'
                     ,x_log_level   => 5);

        PA_TASK_TYPE_PVT.create_Task_Type
          (p_task_type                     => p_task_type
          ,p_start_date_active             => p_start_date_active
          ,p_end_date_active               => p_end_date_active
          ,p_description                   => p_description
          ,p_task_type_class_code          => l_task_type_class_code
          ,p_initial_status_code           => p_initial_status_code
          ,p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => l_task_prog_entry_page_id
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => l_task_weighting_deriv_code
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
          ,p_object_type            =>   p_object_type                  -- 3279978 : Added Object Type and Progress Rollup Method
          ,p_wf_item_type           =>   p_wf_item_type
          ,p_wf_process             =>   p_wf_process
          ,p_wf_lead_days           =>   p_wf_lead_days
          ,x_task_type_id           =>   x_task_type_id
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);
  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN l_task_type_not_unique THEN
      PA_UTILS.add_message('PA','PA_TASK_TYPE_NOT_UNIQUE');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_TASK_TYPE_NOT_UNIQUE';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data	         => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_task_type_invalid_dates THEN
      PA_UTILS.add_message('PA','PA_TT_INVALID_DATES');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_TT_INVALID_DATES';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_pagelayout_name_invalid THEN
      PA_UTILS.add_message('PA',l_error_message_code);
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := l_error_message_code;
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_invalid_lead_day_exc THEN
      PA_UTILS.add_message('PA','PA_INVALID_LEAD_DAYS');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := l_error_message_code;
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO CREATE_TASK_TYPE_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPES_PUB.Create_Task_Type'
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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'          -- 3279978 : Added Object Type and Progress Rollup Method
 ,p_api_version            IN    NUMBER                                      := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                    := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                    := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                    := FND_API.G_TRUE
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

 l_msg_index_out          NUMBER;
 --Bug: 4537865
 l_new_msg_data	 	  VARCHAR2(2000);
 --Bug: 4537865
 l_error_message_code VARCHAR2(100);
 l_task_prog_entry_page_id pa_page_layouts.page_id%TYPE;
 l_task_weighting_deriv_code pa_task_types.task_weighting_deriv_code%TYPE;
 l_is_task_type_used   VARCHAR2(1);
 l_task_type_class_code pa_task_types.task_type_class_code%TYPE;

 CURSOR c1 IS
   SELECT prog_entry_enable_flag, prog_entry_req_flag, wq_enable_flag, remain_effort_enable_flag, percent_comp_enable_flag, end_date_active
   FROM pa_task_types
   WHERE task_type_id = p_task_type_id;

 v_c1 c1%ROWTYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TASK_TYPES_PUB.Update_Task_Type');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_TASK_TYPE_PUB;
  END IF;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PUB.Update_Task_Type.begin'
                     ,x_msg         => 'Beginning of Update_Task_Type pub'
                     ,x_log_level   => 5);


  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;

  -- Check whether task_type is unique
  IF PA_TASK_TYPE_UTILS.is_task_type_unique(p_task_type => p_task_type,
                                            p_task_type_id => p_task_type_id) = 'N' THEN
    RAISE l_task_type_not_unique;
  END IF;

  -- Validate From/To dates
  IF p_end_date_active IS NOT NULL AND TRUNC(p_start_date_active) > TRUNC(p_end_date_active) THEN
    RAISE l_task_type_invalid_dates;
  END IF;

  -- Updating the end_date_active of the Upgraded Task Type is not allowed.
  -- The seeded end_date_actived is NULL.
  IF p_task_type_id = 1 AND p_end_date_active IS NOT NULL THEN

    RAISE l_upd_upg_task_type_error;
  END IF;

  -- Name/ID validation for task progress entry page layout
  l_task_prog_entry_page_id := p_task_prog_entry_page_id;
  PA_PAGE_LAYOUT_UTILS.check_pagelayout_name_or_id(
     p_pagelayout_name => p_task_prog_entry_page_name,
     p_pagetype_code   => 'AI',
     p_check_id_flag   => 'Y',
     x_pagelayout_id   => l_task_prog_entry_page_id,
     x_return_status   => x_return_status,
     x_error_message_code => l_error_message_code);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE l_pagelayout_name_invalid;
  END IF;

  -- Validate progress attributes.
  PA_TASK_TYPE_UTILS.validate_progress_attributes(
           p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => l_task_prog_entry_page_id
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => p_task_weighting_deriv_code
          ,p_remain_effort_enable_flag     => p_remain_effort_enable_flag
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);

  -- Default task_type_class_code to 'MANUAL' for all task types.
  IF p_task_type_class_code IS NULL THEN
    l_task_type_class_code := 'GENERAL';
  END IF;

  -- Check the five control flags
  IF PA_PROJ_ELEMENTS_UTILS.is_task_type_used(p_task_type_id) = 'Y' THEN

    IF (v_c1.prog_entry_enable_flag = 'Y' AND p_prog_entry_enable_flag = 'N') THEN
      RAISE l_prog_entry_enable_error;
    END IF;
    IF (v_c1.prog_entry_req_flag = 'N' AND p_prog_entry_req_flag = 'Y') THEN
      RAISE l_prog_entry_req_error;
    END IF;
    IF (v_c1.wq_enable_flag = 'Y' AND p_wq_enable_flag = 'N') THEN
      RAISE l_wq_enable_error;
    END IF;
    IF (v_c1.remain_effort_enable_flag = 'Y' AND p_remain_effort_enable_flag = 'N') THEN
      RAISE l_remain_effort_enable_error;
    END IF;
    IF (v_c1.percent_comp_enable_flag = 'Y' AND p_percent_comp_enable_flag = 'N') THEN
      RAISE l_percent_comp_enable_error;
    END IF;

  END IF;

  -- Default task_weighting_deriv_code to 'MANUAL' for all task types.
  IF p_task_weighting_deriv_code IS NULL THEN
    l_task_weighting_deriv_code := 'MANUAL';
  END IF;

  -- FP M : 3491609 : Project Execution Workflow Changes
  If nvl(p_wf_lead_days,0)<0 then
     Raise l_invalid_lead_day_exc ;
  end if ;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --Log Message
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PUB.Update_Task_Type.begin'
                     ,x_msg         => 'calling Update_Task_Type pvt'
                     ,x_log_level   => 5);

    PA_TASK_TYPE_PVT.Update_Task_Type
          (p_task_type_id                  => p_task_type_id
          ,p_task_type                     => p_task_type
          ,p_start_date_active             => p_start_date_active
          ,p_end_date_active               => p_end_date_active
          ,p_description                   => p_description
          ,p_task_type_class_code          => l_task_type_class_code
          ,p_initial_status_code           => p_initial_status_code
          ,p_prog_entry_enable_flag        => p_prog_entry_enable_flag
          ,p_prog_entry_req_flag           => p_prog_entry_req_flag
          ,p_initial_progress_status_code  => p_initial_progress_status_code
          ,p_task_prog_entry_page_id       => l_task_prog_entry_page_id
          ,p_wq_enable_flag                => p_wq_enable_flag
          ,p_work_item_code                => p_work_item_code
          ,p_uom_code                      => p_uom_code
          ,p_actual_wq_entry_code          => p_actual_wq_entry_code
          ,p_percent_comp_enable_flag      => p_percent_comp_enable_flag
          ,p_base_percent_comp_deriv_code  => p_base_percent_comp_deriv_code
          ,p_task_weighting_deriv_code     => l_task_weighting_deriv_code
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
  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN l_task_type_not_unique THEN
      PA_UTILS.add_message('PA','PA_TASK_TYPE_NOT_UNIQUE');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_TASK_TYPE_NOT_UNIQUE';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_task_type_invalid_dates THEN
      PA_UTILS.add_message('PA','PA_TT_INVALID_DATES');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_TT_INVALID_DATES';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_upd_upg_task_type_error THEN
      PA_UTILS.add_message('PA','PA_UPD_UPG_TASK_TYPE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_UPD_UPG_TASK_TYPE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_pagelayout_name_invalid THEN
      PA_UTILS.add_message('PA',l_error_message_code);
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := l_error_message_code;
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_prog_entry_enable_error THEN
      PA_UTILS.add_message('PA','PA_PROG_ENTRY_ENABLE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_PROG_ENTRY_ENABLE_FLAG_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_prog_entry_req_error THEN
      PA_UTILS.add_message('PA','PA_PROG_ENTRY_REQ_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_TASK_TYPE_NOT_UNIQUE';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_wq_enable_error THEN
      PA_UTILS.add_message('PA','PA_WQ_ENABLE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_WQ_ENABLE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data 		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_remain_effort_enable_error THEN
      PA_UTILS.add_message('PA','PA_REMAIN_EFFORT_ENABLE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_REMAIN_EFFORT_ENABLE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_percent_comp_enable_error THEN
      PA_UTILS.add_message('PA','PA_PERCENT_COMP_ENABLE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_PERCENT_COMP_ENABLE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_invalid_lead_day_exc THEN
      PA_UTILS.add_message('PA','PA_INVALID_LEAD_DAYS');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := l_error_message_code;
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO UPDATE_TASK_TYPE_PUB;
        END IF;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPES_PUB.Update_Task_Type'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Update_Task_Type;


PROCEDURE Delete_Task_Type
 (p_Task_Type_id           IN    pa_task_types.Task_Type_id%TYPE           := NULL
 ,p_api_version            IN    NUMBER                                    := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                  := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                  := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                  := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_msg_index_out          NUMBER;
 --Bug: 4537865
 l_new_msg_data		  VARCHAR2(2000);
 --Bug: 4537865

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_task_types_PUB.Delete_Task_Type');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT DELETE_TASK_TYPE_PUB;
  END IF;

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_task_types_PUB.Delete_Task_Type.begin'
                     ,x_msg         => 'Beginning of Delete_Task_Type pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TASK_TYPES_PUB.Delete_Task_Type.begin'
                     ,x_msg         => 'calling Delete_Task_Type pvt'
                     ,x_log_level   => 5);

  -- Check whether the task type is the seeded task type.
  IF p_task_type_id = 1 THEN
    RAISE l_del_upg_task_type_error;
  END IF;

  -- Check the task type has been used by any task.
  IF PA_PROJ_ELEMENTS_UTILS.is_task_type_used(p_task_type_id) = 'Y' THEN
    RAISE l_delete_task_type_error;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    PA_TASK_TYPE_PVT.Delete_Task_Type
          (p_task_type_id           =>   p_task_type_id
          ,x_return_status          =>   x_return_status
          ,x_msg_count              =>   x_msg_count
          ,x_msg_data               =>   x_msg_data);
  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN l_del_upg_task_type_error THEN
      PA_UTILS.add_message('PA','PA_DEL_UPG_TASK_TYPE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_DELETE_TASK_TYPE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN l_delete_task_type_error THEN
      PA_UTILS.add_message('PA','PA_DELETE_TASK_TYPE_ERROR');
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_data := 'PA_DELETE_TASK_TYPE_ERROR';
		  x_msg_count := FND_MSG_PUB.Count_Msg;
		  IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		  END IF;
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO Delete_TASK_TYPE_PUB;
        END IF;

       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPES_PUB.Delete_Task_Type'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Delete_Task_Type;

--Bug # 3279978 FP M Development
-- Procedure            : CREATE_DELIVERABLE_TYPE
-- Type                 : Public Procedure
-- Purpose              : This is the public API used to create the deliverable type .
-- Note                 : This API is called by the CR_UP_DELIVERABLE_TYPE Public API
--                        if the value of its parameter p_insert_or_update is "INSERT"
--                        This API places call to the private API CREATE_DELIVERABLE_TYPE
--                        where business validations are done and call to table handler is placed.
--Assumptions           : None
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
--P_deliverable_type_id		      PA_TASK_TYPES.TASK_TYPE_ID%TPE		   Y		NULL


 --28-Dec-2003      avaithia  Created

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
,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count                        NUMBER := 0;
l_data                             VARCHAR2(2000);
l_msg_data                         VARCHAR2(2000);
l_msg_index_out                    NUMBER;
l_debug_mode                       VARCHAR2(1);

l_debug_level2                     CONSTANT NUMBER := 2;
l_debug_level3                     CONSTANT NUMBER := 3;
l_debug_level4                     CONSTANT NUMBER := 4;
l_debug_level5                     CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := p_debug_mode;

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
          PA_DEBUG.WRITE(g_module_name,'p_record_version_number'||':'||p_record_version_number,
                                     l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint CREATE_DELIVERABLE_TYPE_PUB;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     --Check whether p_deliverable_type_name or effective start date is null
     --If it is null,then raise Invalid parameter exception
     IF (p_deliverable_type_name IS NULL) OR (p_effective_from IS NULL)
     THEN
          RAISE PA_DLV_INV_PARAM_EXC;
     END IF;

     --Place a call to PA_TASK_TYPE_PVT.CREATE_DELIVERABLE_TYPE
     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Calling PA_TASK_TYPE_PVT.CREATE_DELIVERABLE_TYPE';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

      PA_TASK_TYPE_PVT.CREATE_DELIVERABLE_TYPE
     (p_api_version                =>   p_api_version
     ,p_init_msg_list              =>   FND_API.G_FALSE
     ,p_commit                     =>   p_commit
     ,p_validate_only              =>   p_validate_only
     ,p_validation_level           =>   p_validation_level
     ,p_calling_module             =>   p_calling_module
     ,p_debug_mode                 =>   l_debug_mode
     ,p_max_msg_count              =>   p_max_msg_count
     ,p_deliverable_type_name      =>   p_deliverable_type_name
     ,p_prog_entry_enable_flag     =>   p_prog_entry_enable_flag
     ,p_initial_deliverable_status =>   p_initial_deliverable_status
     ,p_deliverable_type_class     =>   p_deliverable_type_class
     ,p_enable_dlvr_actions_flag   =>   p_enable_dlvr_actions_flag
     ,p_effective_from             =>   p_effective_from
     ,p_effective_to               =>   p_effective_to
     ,p_description                =>   p_description
     ,p_deliverable_type_id        =>   p_deliverable_type_id
     ,p_record_version_number      =>   p_record_version_number
     ,x_return_status              =>   x_return_status
     ,x_msg_count                  =>   x_msg_count
     ,x_msg_data                   =>   x_msg_data
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          COMMIT;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Successful Commit Done(In PATTPUBB.pls Create DlvType)!';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO CREATE_DELIVERABLE_TYPE_PUB;
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

WHEN PA_DLV_INV_PARAM_EXC THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_INV_PARAM_PASSED';

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO CREATE_DELIVERABLE_TYPE_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
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

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO CREATE_DELIVERABLE_TYPE_PUB;
     END IF;


     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
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
END CREATE_DELIVERABLE_TYPE ;

--Bug # 3279978 FP M  Development
-- Procedure            : UPDATE_DELIVERABLE_TYPE
-- Type                 : Public Procedure
-- Purpose              : This is the public API used to update the deliverable type .
-- Note                 : 1)This API is called by the CR_UP_DELIVERABLE_TYPE Public API
--                        if the value of its parameter p_insert_or_update is "UPDATE"

--                        2)It performs standard locking for API and
--
--                        3)This API places call to the private API UPDATE_DELIVERABLE_TYPE
--                        where business validations and call to table handler is placed.
-- Assumptions           : None

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
 --28-Dec-2003      avaithia       Created
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
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count                        NUMBER := 0;
l_data                             VARCHAR2(2000);
l_msg_data                         VARCHAR2(2000);
l_msg_index_out                    NUMBER;
l_debug_mode                       VARCHAR2(1);

l_dummy                            VARCHAR2(1);

l_debug_level2                     CONSTANT NUMBER := 2;
l_debug_level3                     CONSTANT NUMBER := 3;
l_debug_level4                     CONSTANT NUMBER := 4;
l_debug_level5                     CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := p_debug_mode;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.set_curr_function( p_function   => 'UPDATE_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'UPDATE_DELIVERABLE_TYPE : Printing Input parameters';
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
          PA_DEBUG.WRITE(g_module_name,'rec_ver_num is '||p_record_version_number,l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint UPDATE_DELIVERABLE_TYPE_PUB;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     --Check whether any of  p_deliverable_type_id or p_record_version_number or name or startdate is null
     --If it is null,then raise Invalid parameter exception
     IF (p_deliverable_type_id IS NULL) OR (p_record_version_number IS NULL)
         OR (p_deliverable_type_name IS NULL) OR (p_effective_from IS NULL)
     THEN
          RAISE PA_DLV_INV_PARAM_EXC;
     END IF;

     --Perform the standard Locking

     BEGIN
          select 'x' into l_dummy
          FROM   PA_TASK_TYPES
          WHERE TASK_TYPE_ID = p_deliverable_type_id
          AND OBJECT_TYPE = 'PA_DLVR_TYPES'
          AND record_version_number = p_record_version_number
          for UPDATE of record_version_number NOWAIT;

          EXCEPTION

          WHEN TIMEOUT_ON_RESOURCE THEN
               x_return_status := Fnd_Api.G_RET_STS_ERROR;
               x_msg_count     := 1;
               x_msg_data      :='PA_XC_ROW_ALREADY_LOCKED';

               IF p_commit = FND_API.G_TRUE THEN
                    ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
               END IF;

               PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                    ,p_msg_name => 'PA_XC_ROW_ALREADY_LOCKED');

               IF l_debug_mode = 'Y'
               THEN
                    Pa_Debug.g_err_stage:= ' Error'||x_msg_data;
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
                    Pa_Debug.reset_curr_function;
               END IF;
               RAISE;


          WHEN NO_DATA_FOUND THEN
               x_return_status := Fnd_Api.G_RET_STS_ERROR;
               x_msg_count     := 1;
               x_msg_data      :='PA_XC_RECORD_CHANGED';

               IF p_commit = FND_API.G_TRUE
               THEN
                    ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
               END IF;

               PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                    ,p_msg_name => 'PA_XC_RECORD_CHANGED');

               IF l_debug_mode = 'Y'
               THEN
                    Pa_Debug.g_err_stage:= ' Error'||x_msg_data;
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
                    Pa_Debug.reset_curr_function;
               END IF;
               RAISE;

          WHEN OTHERS THEN
               IF SQLCODE = -54 then
                    x_return_status := Fnd_Api.G_RET_STS_ERROR;
                    x_msg_count     := 1;
                    x_msg_data      :='PA_XC_ROW_ALREADY_LOCKED';

                    IF p_commit = FND_API.G_TRUE
                    THEN
                         ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
                    END IF;

                    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                         ,p_msg_name => 'PA_XC_ROW_ALREADY_LOCKED');

                    IF l_debug_mode = 'Y'
                    THEN
                         Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
                         Pa_Debug.reset_curr_function;
                    END IF;

               ELSE
                    RAISE;
               END IF;
     END;

     --Before placing call to Private API check in case if the message stack is populated;
     --If Yes,then set the return status to Error

     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0
     THEN
          x_msg_count :=l_msg_count;
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     --Before placing call to the API check for the return status
     --If it is Error,then raise it.

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;
     --Place a call to PA_TASK_TYPE_PVT.UPDATE_DELIVERABLE_TYPE
     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Calling PA_TASK_TYPE_PVT.UPDATE_DELIVERABLE_TYPE';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                             l_debug_level3);
     END IF;

     PA_TASK_TYPE_PVT.UPDATE_DELIVERABLE_TYPE
     (p_api_version                =>   p_api_version
     ,p_init_msg_list              =>   FND_API.G_FALSE
     ,p_commit                     =>   p_commit
     ,p_validate_only              =>   p_validate_only
     ,p_validation_level           =>   p_validation_level
     ,p_calling_module             =>   p_calling_module
     ,p_debug_mode                 =>   l_debug_mode
     ,p_max_msg_count              =>   p_max_msg_count
     ,p_deliverable_type_name      =>   p_deliverable_type_name
     ,p_prog_entry_enable_flag     =>   p_prog_entry_enable_flag
     ,p_initial_deliverable_status =>   p_initial_deliverable_status
     ,p_deliverable_type_class     =>   p_deliverable_type_class
     ,p_enable_dlvr_actions_flag   =>   p_enable_dlvr_actions_flag
     ,p_effective_from             =>   p_effective_from
     ,p_effective_to               =>   p_effective_to
     ,p_description                =>   p_description
     ,p_deliverable_type_id        =>   p_deliverable_type_id
     ,p_record_version_number      =>   p_record_version_number
     ,x_return_status              =>   x_return_status
     ,x_msg_count                  =>   x_msg_count
     ,x_msg_data                   =>   x_msg_data
     );
     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'After Calling PA_TASK_TYPE_PVT.UPDATE_DELIVERABLE_TYPE';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     --After returning from the API check for the return status

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          COMMIT;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Successful Commit Done(In PATTPUBB.pls UPDATE DlvType)!';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                             l_debug_level3);
     END IF;


     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          l_msg_count := Fnd_Msg_Pub.count_msg;

          IF p_commit = FND_API.G_TRUE THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
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
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.reset_curr_function;
          END IF;

     WHEN PA_DLV_INV_PARAM_EXC THEN

          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_INV_PARAM_PASSED';

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
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

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF p_commit = FND_API.G_TRUE
          THEN
               ROLLBACK TO UPDATE_DELIVERABLE_TYPE_PUB;
          END IF;


          Fnd_Msg_Pub.add_exc_msg
          ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
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
END UPDATE_DELIVERABLE_TYPE ;

--Bug # 3279978 FP M Development

-- Procedure            : DELETE_DELIVERABLE_TYPE
-- Type                 : Public Procedure
-- Purpose              : This is the public API used to delete the deliverable type.
-- Note                 : This API places call to the private API DELETE_DELIVERABLE_TYPE
--                        in which business logic validations are done and call to table handler is placed
-- List of parameters other than standard IN and OUT parameters
-- Parameters                            Type                                      Null?        Description and Purpose
-- ---------------------------         -------------------------------            --------  -----------------------------------
--P_deliverable_type_id		        PA_TASK_TYPES.TASK_TYPE_ID%TYPE		     N  	Deliverable Type Id
--p_record_version_number            PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE     N          Record Version Number

 --This API is called by SS pages
 --28-Dec-2003      avaithia       Created

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
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count                        NUMBER := 0;
l_data                             VARCHAR2(2000);
l_msg_data                         VARCHAR2(2000);
l_msg_index_out                    NUMBER;
l_debug_mode                       VARCHAR2(1);

l_debug_level2                     CONSTANT NUMBER := 2;
l_debug_level3                     CONSTANT NUMBER := 3;
l_debug_level4                     CONSTANT NUMBER := 4;
l_debug_level5                     CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'DELETE_DELIVERABLE_TYPE : Printing Input parameters';
          PA_DEBUG.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                             l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_deliverable_type_id'||':'||p_deliverable_type_id,
                                             l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_record_version_number'||':'||p_record_version_number,
                                             l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint DELETE_DELIVERABLE_TYPE_PUB;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     --Check whether p_deliverable_type_id  or p_record_version_number is null
     --If it is null,then raise Invalid parameter exception
     IF (p_deliverable_type_id IS NULL)  OR (p_record_version_number IS NULL)
     THEN
          RAISE PA_DLV_INV_PARAM_EXC;
     END IF;

	 /* Added for bug 4775641*/
     -- Check the deliverable type has been used by any deliverable.
     IF PA_DELIVERABLE_UTILS.IS_DLV_TYPE_IN_USE(p_deliverable_type_id) = 'Y' THEN
	  RAISE l_delete_delv_type_error;
     END IF;
     /* End for bug 4775641*/

     --Place a call to PA_TASK_TYPE_PVT.DELETE_DELIVERABLE_TYPE
     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Calling PA_TASK_TYPE_PVT.DELETE_DELIVERABLE_TYPE';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;
     PA_TASK_TYPE_PVT.DELETE_DELIVERABLE_TYPE
     (p_api_version                =>   p_api_version
     ,p_init_msg_list              =>   FND_API.G_FALSE
     ,p_commit                     =>   p_commit
     ,p_validate_only              =>   p_validate_only
     ,p_validation_level           =>   p_validation_level
     ,p_calling_module             =>   p_calling_module
     ,p_debug_mode                 =>   l_debug_mode
     ,p_max_msg_count              =>   p_max_msg_count
     ,p_deliverable_type_id        =>   p_deliverable_type_id
     ,p_record_version_number      =>   p_record_version_number
     ,x_return_status              =>   x_return_status
     ,x_msg_count                  =>   x_msg_count
     ,x_msg_data                   =>   x_msg_data
     );
     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'After coming from PA_TASK_TYPE_PVT.DELETE_DELIVERABLE_TYPE';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          COMMIT;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Successful Commit Done(In PATTPUBB.pls Deleted the DlvType)!';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;


EXCEPTION

WHEN l_delete_delv_type_error THEN      -- Added for bug 4775641
	PA_UTILS.add_message('PA','PA_DELETE_DELIV_TYPE_ERROR');
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_msg_data := 'PA_DELETE_DELIV_TYPE_ERROR';
	  x_msg_count := FND_MSG_PUB.Count_Msg;
	  IF x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count,
				p_msg_data       => x_msg_data,
				p_data           => x_msg_data,
				p_msg_index_out  => l_msg_index_out );
	  END IF;

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO DELETE_DELIVERABLE_TYPE_PUB;
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

WHEN PA_DLV_INV_PARAM_EXC THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_INV_PARAM_PASSED';

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO DELETE_DELIVERABLE_TYPE_PUB;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
      , p_procedure_name  => 'DELETE_DELIVERABLE_TYPE'
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

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO DELETE_DELIVERABLE_TYPE_PUB;
     END IF;


     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
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
END DELETE_DELIVERABLE_TYPE ;

--Bug # 3279978 FP M Development
-- Procedure            : CR_UP_DELIVERABLE_TYPE
-- Type                 : Public Procedure
-- Purpose              : This is the public API that will be called from SS pages.
-- Note                 : Based on the parameter p_insert_or_update mode
--                        it will either call CREATE or UPDATE deliverable API.
-- Assumptions          : None
-- List of parameters other than standard IN and OUT parameters
-- Parameters                        Type                                      Null?       Default Value           Description and Purpose
-- ---------------------------       -------                                 --------    --------------------     ---------------------------
--P_deliverable_type_name           PA_TASK_TYPES.TASK_TYPE%TYPE	           N		                 Deliverable Type Name
--P_prog_entry_enable_flag          PA_TASK_TYPES.PROG_ENTRY_ENABLE_FLAG%TYPE      Y	     'N'		 Progress Entrable Flag
--P_initial_deliverable_status_code PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE	   Y	     'DLVR_NOT_STARTED'  Initial Deliverable Status
--P_enable_deliverable_actions	    PA_TASK_TYPES.ENABLE_DLVR_ACTIONS%TYPE	   Y	      'N'	         Enable Deliverable Action
--P_effective_from		    PA_TASK_TYPES.START_DATE_ACTIVE%TYPE           N		                 Effective from date
--p_effective_to		    PA_TASK_TYPES. END_DATE_ACTIVE %TYPE           Y	      NULL               Effective to date
--P_description			    PA_TASK_TYPES.DESCRIPTION%TYPE		   Y          NULL               Description
--P_deliverable_type_id		    PA_TASK_TYPES.TASK_TYPE_ID%TPE		   Y	      NULL
--P_insert_or_update                 VARCHAR2                                     N         'INSERT'             Insert/Update

--28-Dec-2003      avaithia  Created

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
,p_record_version_number           IN   PA_TASK_TYPES.RECORD_VERSION_NUMBER%TYPE    := 1
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count                        NUMBER := 0;
l_data                             VARCHAR2(2000);
l_msg_data                         VARCHAR2(2000);
l_msg_index_out                    NUMBER;
l_debug_mode                       VARCHAR2(1);

l_debug_level2                     CONSTANT NUMBER := 2;
l_debug_level3                     CONSTANT NUMBER := 3;
l_debug_level4                     CONSTANT NUMBER := 4;
l_debug_level5                     CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CR_UP_DELIVERABLE_TYPE',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint CR_UP_DELIVERABLE_TYPE;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          PA_DEBUG.g_err_stage:= 'CR_UP_DELIVERABLE_TYPE : Printing Input parameters';
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
          PA_DEBUG.WRITE(g_module_name,'p_insert_or_update'||':'||p_insert_or_update,
                                     l_debug_level3);
          PA_DEBUG.WRITE(g_module_name,'p_record_version_number'||':'||p_record_version_number,
                                     l_debug_level3);

     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE))
     THEN
          FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE)
     THEN
          savepoint CR_UP_DELIVERABLE_TYPE;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                        l_debug_level3);
     END IF;

     --Check whether the Deliverable Type Name /Start date IS NULL
     --If Yes,then throw Invalid Param Error

     IF (p_deliverable_type_name IS NULL) OR (p_effective_from IS NULL)
     THEN
          RAISE PA_DLV_INV_PARAM_EXC;
     END IF;

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Calling insert/update';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                        l_debug_level3);
     END IF;

     IF (p_insert_or_update = 'INSERT')
     THEN
          PA_TASK_TYPE_PUB.CREATE_DELIVERABLE_TYPE
          (p_api_version                =>   p_api_version
          ,p_init_msg_list              =>   FND_API.G_FALSE
          ,p_commit                     =>   p_commit
          ,p_validate_only              =>   p_validate_only
          ,p_validation_level           =>   p_validation_level
          ,p_calling_module             =>   p_calling_module
          ,p_debug_mode                 =>   l_debug_mode
          ,p_max_msg_count              =>   p_max_msg_count
          ,p_deliverable_type_name      =>   p_deliverable_type_name
          ,p_prog_entry_enable_flag     =>   p_prog_entry_enable_flag
          ,p_initial_deliverable_status =>   p_initial_deliverable_status
          ,p_deliverable_type_class     =>   p_deliverable_type_class
          ,p_enable_dlvr_actions_flag   =>   p_enable_dlvr_actions_flag
          ,p_effective_from             =>   p_effective_from
          ,p_effective_to               =>   p_effective_to
          ,p_description                =>   p_description
          ,p_deliverable_type_id        =>   p_deliverable_type_id
          ,p_record_version_number      =>   p_record_version_number
          ,x_return_status              =>   x_return_status
          ,x_msg_count                  =>   x_msg_count
          ,x_msg_data                   =>   x_msg_data
          );
     ELSE
          PA_TASK_TYPE_PUB.UPDATE_DELIVERABLE_TYPE
          (p_api_version                =>   p_api_version
          ,p_init_msg_list              =>   FND_API.G_FALSE
          ,p_commit                     =>   p_commit
          ,p_validate_only              =>   p_validate_only
          ,p_validation_level           =>   p_validation_level
          ,p_calling_module             =>   p_calling_module
          ,p_debug_mode                 =>   l_debug_mode
          ,p_max_msg_count              =>   p_max_msg_count
          ,p_deliverable_type_name      =>   p_deliverable_type_name
          ,p_prog_entry_enable_flag     =>   p_prog_entry_enable_flag
          ,p_initial_deliverable_status =>   p_initial_deliverable_status
          ,p_deliverable_type_class     =>   p_deliverable_type_class
          ,p_enable_dlvr_actions_flag   =>   p_enable_dlvr_actions_flag
          ,p_effective_from             =>   p_effective_from
          ,p_effective_to               =>   p_effective_to
          ,p_description                =>   p_description
          ,p_deliverable_type_id        =>   p_deliverable_type_id
          ,p_record_version_number      =>   p_record_version_number
          ,x_return_status              =>   x_return_status
          ,x_msg_count                  =>   x_msg_count
          ,x_msg_data                   =>   x_msg_data
          );
     END IF;

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE
     THEN
        ROLLBACK TO CR_UP_DELIVERABLE_TYPE;
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

WHEN PA_DLV_INV_PARAM_EXC THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_INV_PARAM_PASSED';

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO CR_UP_DELIVERABLE_TYPE;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
      , p_procedure_name  => 'CR_UP_DELIVERABLE_TYPE'
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

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE
     THEN
          ROLLBACK TO CR_UP_DELIVERABLE_TYPE;
     END IF;


     Fnd_Msg_Pub.add_exc_msg
     ( p_pkg_name        => 'PA_TASK_TYPE_PUB'
     , p_procedure_name  => 'CR_UP_DELIVERABLE_TYPE'
     , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y'
     THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                        l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CR_UP_DELIVERABLE_TYPE ;

END PA_TASK_TYPE_PUB;

/
