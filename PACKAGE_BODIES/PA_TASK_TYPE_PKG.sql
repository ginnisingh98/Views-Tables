--------------------------------------------------------
--  DDL for Package Body PA_TASK_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_TYPE_PKG" AS
/*$Header: PATTPKGB.pls 120.1 2005/08/19 17:06:14 mwasowic noship $*/

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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'    -- 3279987 : Added Object Type, Progress Rollup Method,
 ,p_enable_dlvr_actions_flag IN    pa_task_types.enable_dlvr_actions_flag%TYPE      :=NULL           --           Method code columns--3279978 modified avaithia 28-dec-2003
 ,p_record_version_number   IN   pa_task_types.record_version_number%TYPE     :=1 -- 3279978 inserted avaithia 28-dec-2003
 ,p_wf_item_type            IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process              IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days            IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_task_type_id          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
------------------------------------------------------------------------------------------------------------
--3279978 FP M Development avaithia 29-Dec-2003
l_task_type_id pa_task_types.task_type_id%TYPE :=p_task_type_id;

CURSOR c_task_type_id IS
SELECT pa_task_types_s.nextval FROM sys.dual;
 ---end of insert by avaithia
------------------------------------------------------------------------------------------------------------
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 -----------------------------------------------------------------------------------------------------------
  --3279978 FP M Development avaithia 29-Dec-2003
  --If p_task_type_id is zero then take the value from sequence
  IF (p_task_type_id =0)
  THEN
  OPEN c_task_type_id;
  FETCH c_task_type_id into l_task_type_id;
  CLOSE c_task_type_id;
  END IF;
     PA_DEBUG.WRITE('Inside Table handler','Before Insert',3);
     PA_DEBUG.WRITE('Inside Table handler','Task Type Id'||l_task_type_id,3);
     PA_DEBUG.WRITE('Inside Table handler','pa_task_type '||p_task_type,3);
     PA_DEBUG.WRITE('Inside Table handler','eff from '||p_start_date_active,3);
     PA_DEBUG.WRITE('Inside Table handler','eff to '||p_end_date_active,3);
     PA_DEBUG.WRITE('Inside Table handler','p_task_type_class_code '||p_task_type_class_code,3);
     PA_DEBUG.WRITE('Inside Table handler','p_initial_status_code '||p_initial_status_code,3);
     PA_DEBUG.WRITE('Inside Table handler','p_prog_entry_enable_flag '||p_prog_entry_enable_flag,3);
     PA_DEBUG.WRITE('Inside Table handler','p_record_version_number '||p_record_version_number,3);
 ---end of insert by avaithia
-------------------------------------------------------------------------------------------------------------

  INSERT INTO pa_task_types
             (task_type_id                  --3279978 :Inserted avaithia 29-Dec-2003 FP M
             ,task_type
             ,start_date_active
             ,end_date_active
             ,description
             ,task_type_class_code
             ,initial_status_code
             ,prog_entry_enable_flag
             ,prog_entry_req_flag
             ,initial_progress_status_code
             ,task_progress_entry_page_id
             ,wq_enable_flag
             ,work_item_code
             ,uom_code
             ,actual_wq_entry_code
             ,percent_comp_enable_flag
             ,base_percent_comp_deriv_code
             ,task_weighting_deriv_code
             ,remain_effort_enable_flag
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,object_type                   -- 3279978 : Added Object Type, Progress Rollup Method,
             ,enable_dlvr_actions_flag      -- Method code columns--3279978 commented avaithia 28-dec-2003
             ,record_version_number         -- 3279978 inserted avaithia 28-dec-2003 FP M
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login
             ,wf_item_type
             ,wf_process
             ,wf_start_lead_days
             )
       VALUES
            ( l_task_type_id                -- 3279978 inserted avaithia 28-dec-2003 FP M
             ,p_task_type
             ,p_start_date_active
             ,p_end_date_active
             ,p_description
             ,p_task_type_class_code
             ,p_initial_status_code
             ,p_prog_entry_enable_flag
             ,p_prog_entry_req_flag
             ,p_initial_progress_status_code
             ,p_task_prog_entry_page_id
             ,p_wq_enable_flag
             ,p_work_item_code
             ,p_uom_code
             ,p_actual_wq_entry_code
             ,p_percent_comp_enable_flag
             ,p_base_percent_comp_deriv_code
             ,p_task_weighting_deriv_code
             ,p_remain_effort_enable_flag
             ,p_attribute_category
             ,p_attribute1
             ,p_attribute2
             ,p_attribute3
             ,p_attribute4
             ,p_attribute5
             ,p_attribute6
             ,p_attribute7
             ,p_attribute8
             ,p_attribute9
             ,p_attribute10
             ,p_attribute11
             ,p_attribute12
             ,p_attribute13
             ,p_attribute14
             ,p_attribute15
             ,p_object_type
             ,p_enable_dlvr_actions_flag
             ,p_record_version_number      -- 3279978 inserted avaithia 28-dec-2003 FP M
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
             ,p_wf_item_type
             ,p_wf_process
             ,p_wf_lead_days
            )
            RETURNING l_task_type_id INTO x_task_type_id;


   PA_DEBUG.WRITE('Inside Table handler','After Insert'||l_task_type_id,
                                     3);


  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PKG.insert_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END insert_row;


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
 ,p_object_type            IN    pa_task_types.object_type%TYPE              := 'PA_TASKS'    -- 3279987 : Added Object Type, Progress Rollup Method,
 ,p_enable_dlvr_actions_flag    IN    pa_task_types.enable_dlvr_actions_flag%TYPE :=NULL           --           Method code columns--modified 3279978 avaithia 28-dec-2003
 ,p_record_version_number   IN   pa_task_types.record_version_number%TYPE    := 1
 ,p_wf_item_type           IN    pa_task_types.wf_item_type%TYPE           :=NULL
 ,p_wf_process             IN    pa_task_types.wf_process%TYPE             :=NULL
 ,p_wf_lead_days           IN    pa_task_types.wf_start_lead_days%TYPE     :=NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE pa_task_types
  SET
             task_type                        = p_task_type
             ,start_date_active               = p_start_date_active
             ,end_date_active                 = p_end_date_active
             ,description                     = p_description
             ,task_type_class_code            = p_task_type_class_code
             ,initial_status_code             = p_initial_status_code
             ,prog_entry_enable_flag          = p_prog_entry_enable_flag
             ,prog_entry_req_flag             = p_prog_entry_req_flag
             ,initial_progress_status_code    = p_initial_progress_status_code
             ,task_progress_entry_page_id     = p_task_prog_entry_page_id
             ,wq_enable_flag                  = p_wq_enable_flag
             ,work_item_code                  = p_work_item_code
             ,uom_code                        = p_uom_code
             ,actual_wq_entry_code            = p_actual_wq_entry_code
             ,percent_comp_enable_flag        = p_percent_comp_enable_flag
             ,base_percent_comp_deriv_code    = p_base_percent_comp_deriv_code
             ,task_weighting_deriv_code       = p_task_weighting_deriv_code
             ,remain_effort_enable_flag       = p_remain_effort_enable_flag
             ,attribute_category              = p_attribute_category
             ,attribute1                      = p_attribute1
             ,attribute2                      = p_attribute2
             ,attribute3                      = p_attribute3
             ,attribute4                      = p_attribute4
             ,attribute5                      = p_attribute5
             ,attribute6                      = p_attribute6
             ,attribute7                      = p_attribute7
             ,attribute8                      = p_attribute8
             ,attribute9                      = p_attribute9
             ,attribute10                     = p_attribute10
             ,attribute11                     = p_attribute11
             ,attribute12                     = p_attribute12
             ,attribute13                     = p_attribute13
             ,attribute14                     = p_attribute14
             ,attribute15                     = p_attribute15
             ,object_type                     = p_object_type               -- 3279978 : Added Object Type, Progress Rollup Method,
             ,enable_dlvr_actions_flag        = p_enable_dlvr_actions_flag       --           Method code columns  -3279978 avaithia 28-dec-2003
             ,record_version_number           = p_record_version_number + 1  -- 3279978 inserted avaithia 28-dec-2003
             ,wf_item_type                    = p_wf_item_type
             ,wf_process                      = p_wf_process
             ,wf_start_lead_days              = p_wf_lead_days
             ,last_update_date                = sysdate
             ,last_updated_by                 = fnd_global.user_id
             ,last_update_login               = fnd_global.login_id
    WHERE    task_type_id = p_task_type_id;

  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PKG.update_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END update_row;


PROCEDURE delete_row
 (p_task_type_id           IN    pa_task_types.task_type_id%TYPE
 ,p_record_version_number  IN    pa_task_types.record_version_number%TYPE  :=0 -- 3279978 inserted avaithia 7-Jan-2004
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_record_version_number =0) THEN
       DELETE FROM  pa_task_types
               WHERE  task_type_id = p_task_type_id;
  ELSE
       DELETE FROM  pa_task_types
               WHERE  task_type_id = p_task_type_id
               AND    record_version_number=p_record_version_number;
  END IF;

  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_TYPE_PKG.delete_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

 END delete_row;


END PA_TASK_TYPE_PKG;

/
