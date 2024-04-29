--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_DATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_DATES_PUB" AS
/* $Header: PARMPDPB.pls 120.5 2007/02/06 09:51:55 dthakker ship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECT_DATES_PUB';


-- API name		: Copy_Project_Dates
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_buffer                        IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE COPY_PROJECT_DATES
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Copy_Project_Dates';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   CURSOR task_csr
   IS
   SELECT task_id
   FROM PA_TASKS
   WHERE project_id = p_project_id
   ORDER BY wbs_level;

   CURSOR latest_published_ver_csr
   IS
   SELECT element_version_id
   FROM PA_PROJ_ELEM_VER_STRUCTURE
   WHERE project_id = p_project_id
   AND   latest_eff_published_flag = 'Y';

   CURSOR get_task_sch_dates_csr(c_structure_version_id NUMBER, c_task_id NUMBER)
   IS
   SELECT a.scheduled_start_date, a.scheduled_finish_date
   FROM PA_PROJ_ELEM_VER_SCHEDULE a,
        PA_PROJ_ELEMENT_VERSIONS b
   WHERE b.parent_structure_version_id = c_structure_version_id
   AND   b.project_id = p_project_id
   AND   b.proj_element_id = c_task_id
   -- Bug Fix 4868867
   -- Ram Namburi
   -- Added the following AND condition to eliminate Full table scan and Merge Join Cartesian.
   AND   b.element_version_id = a.element_version_id;


   CURSOR get_task_est_dates_csr(c_task_id NUMBER)
   IS
   SELECT estimated_start_date, estimated_finish_date
   FROM PA_PROGRESS_ROLLUP
   WHERE project_id = p_project_id
   AND   object_id = c_task_id
   AND   object_type = 'PA_TASKS'
   AND   as_of_date = (
     select max(as_of_date) from pa_progress_rollup
      where project_id = p_project_id
        and object_id = c_task_id
        and object_type = 'PA_TASKS'
   );

   CURSOR get_task_act_dates_csr(c_task_id NUMBER)
   IS
   SELECT actual_start_date, actual_finish_date
   FROM PA_PROGRESS_ROLLUP
   WHERE project_id = p_project_id
   AND   object_id = c_task_id
   AND   object_type = 'PA_TASKS'
   AND   as_of_date = (
     select max(as_of_date) from pa_progress_rollup
      where project_id = p_project_id
        and object_id = c_task_id
        and object_type = 'PA_TASKS'
   );

   CURSOR get_task_bas_dates_csr(c_task_id NUMBER)
   IS
   SELECT baseline_start_date, baseline_finish_date
   FROM PA_PROJ_ELEMENTS
   WHERE proj_element_id = c_task_id;

   CURSOR get_proj_sch_dates_csr
   IS
   SELECT scheduled_start_date, scheduled_finish_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

   CURSOR get_proj_act_dates_csr
   IS
   SELECT actual_start_date, actual_finish_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

/*
   CURSOR get_proj_est_dates_csr
   IS
   SELECT estimated_start_date, estimated_finish_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;
*/

   CURSOR get_proj_bas_dates_csr
   IS
   SELECT baseline_start_date, baseline_finish_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

   CURSOR get_proj_record_ver_number
   IS
   SELECT record_version_number
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

   CURSOR get_task_record_ver_number(c_task_id NUMBER)
   IS
   SELECT record_version_number
   FROM PA_TASKS
   WHERE task_id = c_task_id;

   CURSOR get_structure
   IS
   SELECT a.proj_element_id
   FROM pa_proj_elements a,
        pa_proj_structure_types b,
        pa_structure_types c
   WHERE a.proj_element_id = b.proj_element_id
   AND a.object_type = 'PA_STRUCTURES'
   AND a.project_id = p_project_id
   AND b.structure_type_id = c.structure_type_id
   AND c.structure_type = 'WORKPLAN';

   CURSOR get_latest_struct_ver(c_structure_id NUMBER)
   IS
   select element_version_id
   from pa_proj_elem_ver_structure
   where project_id = p_project_id
   and proj_element_id = c_structure_id
   and status_code = 'STRUCTURE_PUBLISHED'
   and latest_eff_published_flag = 'Y';

   CURSOR get_work_struct_ver(c_structure_id NUMBER)
   IS
   SELECT element_version_id
   from pa_proj_elem_ver_structure
   where project_id = p_project_id
   and proj_element_id = c_structure_id
   and status_code <> 'STRUCTURE_PUBLISHED';

   CURSOR get_tasks(c_structure_version_id NUMBER)
   IS
   SELECT a.proj_element_id,
          a.element_version_id,
          a.object_type,
          a.wbs_level,
          b.object_id_from1,
          b.object_type_from
   FROM pa_proj_element_versions a,
        pa_object_relationships b
        ,pa_proj_elements c       --bug 4606475
   WHERE a.parent_structure_version_id = c_structure_version_id
   AND a.project_id = p_project_id
   AND a.element_version_id = b.object_id_to1
   AND b.object_type_to = 'PA_TASKS'
   AND b.relationship_type(+) = 'S'
 --bug 4606475
   AND c.proj_element_id = a.proj_element_id
   AND c.project_id=a.project_id
   AND c.object_type = a.object_type
   AND c.link_task_flag = 'N'
 --bug 4606475
   UNION
   SELECT c.proj_element_id,
          c.element_version_id,
          c.object_type,
          0,
          to_number(NULL),
          NULL
   FROM pa_proj_element_versions c
   WHERE c.element_version_id = c_structure_version_id;

   CURSOR get_buffer(c_structure_id NUMBER) IS
     SELECT NVL(TXN_DATE_SYNC_BUF_DAYS,0)
     FROM PA_PROJ_WORKPLAN_ATTR
     WHERE PROJ_ELEMENT_ID = c_structure_id;

   l_process_number   NUMBER;
   l_cnt NUMBER;
   l_rollup_table     PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
   TYPE proj_elem_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_proj_elem_tbl    proj_elem_tbl_type;

   l_proj_element_id  NUMBER;
   l_element_version_id NUMBER;
   l_object_type      VARCHAR2(30);
   l_wbs_level        NUMBER;
   l_parent_id        NUMBER;
   l_parent_object_type VARCHAR2(30);

   l_structure_id                  NUMBER;
   l_structure_ver_id              NUMBER;
   l_buffer                        NUMBER;
   l_task_start_date               DATE;
   l_task_finish_date              DATE;
   l_proj_start_date               DATE;
   l_proj_finish_date              DATE;
   l_structure_version_id          NUMBER;
   l_task_id                       NUMBER;
   l_task_record_version_number    NUMBER;
   l_proj_record_version_number    NUMBER;

--bug 2831656
--modified the cursor for bug 3043580
   CURSOR cur_proj_elem_id( c_task_version_id NUMBER )
   IS
     SELECT ppev.proj_element_id,
            ppe.element_number
       FROM pa_proj_element_versions ppev,
            pa_proj_elements ppe
      WHERE ppev.element_version_id = c_task_version_id
        AND ppev.proj_element_id = ppe.proj_element_id
        AND ppe.link_task_flag = 'N'    --bug 4606475
        ;

   l_proj_element_id2    NUMBER;
   l_element_number      VARCHAR2(240);  --bug 3043580
--bug 2831656

  l_act_fin_date_flag   VARCHAR2(1) := 'Y';  --bug 4229865
 -- Start of addition for bug 5665772
 l_parent_task_id NUMBER;
 l_tstart_date DATE;
 l_tend_date DATE;
 l_tcnt NUMBER;

 TYPE TASK_DATES_REC_TYPE IS RECORD (
 TASK_ID                         NUMBER          := NULL,
 PARENT_TASK_ID                  NUMBER          := NULL,
 OLD_START_DATE                  DATE            := NULL,
 OLD_END_DATE                    DATE            := NULL,
 NEW_START_DATE                  DATE            := NULL,
 NEW_END_DATE                    DATE            := NULL
 );

 TYPE TASK_DATES_TBL_TYPE IS TABLE OF TASK_DATES_REC_TYPE
 INDEX BY BINARY_INTEGER;

 l_task_dates TASK_DATES_TBL_TYPE;
 -- End of addition for bug 5665772

BEGIN
   pa_debug.init_err_stack('PA_PROJECT_DATES_PUB.Copy_Project_Dates');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PUB.Copy_Project_Dates BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint copy_project_dates;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;

   --select structure version id
   OPEN get_structure;
   FETCH get_structure into l_structure_id;
   CLOSE get_structure;

   IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(
                              p_project_id, l_structure_id)) THEN
     --Get latest published version id
     OPEN get_latest_struct_ver(l_structure_id);
     FETCH get_latest_struct_ver into l_structure_ver_id;
     CLOSE get_latest_struct_ver;
   ELSE
     --Get working version id
     --this should only return 1 row because this is only called when
     --  when structure is of both workplan and financial type
     OPEN get_work_struct_ver(l_structure_id);
     FETCH get_work_struct_ver into l_structure_ver_id;
     CLOSE get_work_struct_ver;
   END IF;

   --Get buffer from workplan table
   OPEN get_buffer(l_structure_id);
   FETCH get_buffer into l_buffer;
   CLOSE get_buffer;

   --bug 4229865
   --do not consider actual finish dates if any of the task does not have act finish date.
   --The API returns 'N' if any of the tasks in the structure version does not have actual finish date.
   -- chek_one_task_has_act_st_date will make sure that it rollsup schedule finish date if there is no task
   -- with act start date.
 /* Commented for bug 5338208
   IF PA_PROJECT_DATES_UTILS.chek_one_task_has_act_st_date(p_project_id,l_structure_ver_id) = 'Y'
   THEN
      l_act_fin_date_flag :=  PA_PROJECT_DATES_UTILS.chek_all_tsk_have_act_fin_dt(p_project_id,l_structure_ver_id);
   END IF;

   --bug 4241863
   IF l_act_fin_date_flag = 'Y'
   THEN
      UPDATE pa_tasks
         set completion_date = NULL
       WHERE project_id=p_project_id;
   END IF;
   --end bug 4241863
Commented for bug 5338208*/
   --Get dates from all tasks
   OPEN get_tasks(l_structure_ver_id);
   l_cnt := 0;
   LOOP
     l_cnt := l_cnt + 1;
     FETCH get_tasks into l_proj_element_id,
                          l_element_version_id,
                          l_object_type,
                          l_wbs_level,
                          l_parent_id,
                          l_parent_object_type;
     EXIT WHEN get_tasks%NOTFOUND;

     --For each task, get the start and finish date
     PA_PROJECT_DATES_UTILS.GET_TASK_COPY_DATES(p_project_id                  => p_project_id,
                                                p_proj_element_id             => l_proj_element_id,
                                                p_parent_structure_version_id => l_structure_ver_id,
                                                x_task_start_date             => l_task_start_date,
                                                x_task_finish_date            => l_task_finish_date,
                                                p_act_fin_date_flag           => l_act_fin_date_flag --bug 4229865
                                                );

     --Add buffer
     l_task_start_date := l_task_start_date - l_buffer;
     l_task_finish_date := l_task_finish_date + l_buffer;

 -- Start of addition for bug 5338208
     -- changed IS_LOWEST_TASK() to IS_LOWEST_PROJ_TASK for bug 5698103
     -- If PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(l_element_version_id) <> 'Y' then
     If PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_PROJ_TASK(l_element_version_id, p_project_id) <> 'Y' then
 	    l_task_start_date := Null;
 	    l_task_finish_date:= Null;
 END if;
 -- End of addition for bug 5338208
     --Add to the rollup table
     l_proj_elem_tbl(l_cnt) := l_proj_element_id;
     l_rollup_table(l_cnt).object_id := l_element_version_id;
     l_rollup_table(l_cnt).object_type := l_object_type;
     l_rollup_table(l_cnt).wbs_level := l_wbs_level;
     l_rollup_table(l_cnt).start_date1 := trunc(l_task_start_date); --3961867, rtarway, added trunc
     l_rollup_table(l_cnt).finish_date1 := trunc(l_task_finish_date); --3961867, rtarway, added trunc
     l_rollup_table(l_cnt).parent_object_id := l_parent_id;
     l_rollup_table(l_cnt).parent_object_type := l_parent_object_type;
--bug 2868685: Removing because when actual dates at the project level
--             are different from the rollup values, the changes
--             will not be reflected
--     IF (l_buffer <> 0) OR (l_object_type = 'PA_STRUCTURES') THEN
--       l_rollup_table(l_cnt).dirty_flag1 := 'Y'; --all dates are modified with buffer
--     ELSE
--       l_rollup_table(l_cnt).dirty_flag1 := 'N'; --no modification
--     END IF;
   END LOOP;

   CLOSE get_tasks;  --Bug 3867426
   --Call rollup api
--bug 2868685: Changed p_partial_process_flag1 to 'N' because
--             when actual dates at the project level are
--             different from the rollup values, the changes
--             will not be reflected
   PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
          p_debug_mode => 'N',
          p_data_structure         => l_rollup_table,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          x_process_number         => l_process_number,
          p_process_flag1          => 'Y',
          p_partial_process_flag1  => 'N',
          p_process_rollup_flag1   => 'Y');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     x_msg_count := FND_MSG_PUB.count_msg;
       if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count,
             p_msg_data       => l_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
       end if;
     raise FND_API.G_EXC_ERROR;
   end if;

   --Bug 3919138 : Sort the rollup table by wbs_level in ascending order.
   --This is necessary because update_task api below must be called with the parent tasks
   --first. Else, PA_TASKS_MAINT_UTILS.CHECK_START_DATE results in an error when a buffer value
   --exists for adjusting task start dates
   DECLARE
   l_temp_object_id          NUMBER;
   l_temp_object_type        VARCHAR2(30);
   l_temp_wbs_level          NUMBER;
   l_temp_start_date1        DATE;
   l_temp_finish_date1       DATE;
   l_temp_parent_object_id   NUMBER;
   l_temp_parent_object_type VARCHAR2(30);
   BEGIN
        --Sort only if there are 2 or more records in the table
        IF nvl(l_rollup_table.LAST,0) > 1 THEN
             FOR i IN 1..(l_rollup_table.count-1) LOOP
                  FOR j IN 1..(l_rollup_table.LAST-i) LOOP
                       --Sort in ascending order
                       IF l_rollup_table(j).wbs_level > l_rollup_table(j+1).wbs_level THEN
                            --Swap the two table records
                            l_temp_object_id          := l_rollup_table(j).object_id         ;
                            l_temp_object_type        := l_rollup_table(j).object_type       ;
                            l_temp_wbs_level          := l_rollup_table(j).wbs_level         ;
                            l_temp_start_date1        := l_rollup_table(j).start_date1       ;
                            l_temp_finish_date1       := l_rollup_table(j).finish_date1      ;
                            l_temp_parent_object_id   := l_rollup_table(j).parent_object_id  ;
                            l_temp_parent_object_type := l_rollup_table(j).parent_object_type;

                            l_rollup_table(j).object_id          := l_rollup_table(j+1).object_id         ;
                            l_rollup_table(j).object_type        := l_rollup_table(j+1).object_type       ;
                            l_rollup_table(j).wbs_level          := l_rollup_table(j+1).wbs_level         ;
                            l_rollup_table(j).start_date1        := l_rollup_table(j+1).start_date1       ;
                            l_rollup_table(j).finish_date1       := l_rollup_table(j+1).finish_date1      ;
                            l_rollup_table(j).parent_object_id   := l_rollup_table(j+1).parent_object_id  ;
                            l_rollup_table(j).parent_object_type := l_rollup_table(j+1).parent_object_type;

                            l_rollup_table(j+1).object_id          := l_temp_object_id         ;
                            l_rollup_table(j+1).object_type        := l_temp_object_type       ;
                            l_rollup_table(j+1).wbs_level          := l_temp_wbs_level         ;
                            l_rollup_table(j+1).start_date1        := l_temp_start_date1       ;
                            l_rollup_table(j+1).finish_date1       := l_temp_finish_date1      ;
                            l_rollup_table(j+1).parent_object_id   := l_temp_parent_object_id  ;
                            l_rollup_table(j+1).parent_object_type := l_temp_parent_object_type;
                       END IF;
                  END LOOP;
             END LOOP;
        END IF;
   END;
   --Bug 3919138

   l_cnt := l_rollup_table.First;
   LOOP
     --bug 3716805
     exit when l_rollup_table.count = 0;
     --end bug 3716805
     IF (l_rollup_table(l_cnt).object_type = 'PA_STRUCTURES') THEN
       --Update project first; otherwise task dates might exceed project dates
       -- Now copy over project level dates
       OPEN get_proj_record_ver_number;
       FETCH get_proj_record_ver_number INTO l_proj_record_version_number;
       CLOSE get_proj_record_ver_number;

       PA_PROJECT_DATES_PUB.Update_Project_Dates (
          p_init_msg_list          => p_init_msg_list
         ,p_commit                 => FND_API.G_FALSE
         ,p_validate_only          => FND_API.G_FALSE -- Bug 2786525
         ,p_calling_module         => p_calling_module
         ,p_debug_mode             => p_debug_mode
         ,p_project_id             => p_project_id
         ,p_date_type              => 'TRANSACTION'
         ,p_start_date             => l_rollup_table(l_cnt).start_date1
         ,p_finish_date            => l_rollup_table(l_cnt).finish_date1
         ,p_record_version_number  => l_proj_record_version_number
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         x_msg_count := FND_MSG_PUB.count_msg;
         if x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_msg_count      => l_msg_count,
            p_msg_data       => l_msg_data,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
         end if;
         raise FND_API.G_EXC_ERROR;
       end if;

       EXIT;
     END IF;
     EXIT when l_cnt = l_rollup_table.Last;
     l_cnt := l_rollup_table.NEXT(l_cnt);
   END LOOP;

   --Update tasks
   l_cnt := l_rollup_table.First;
   l_tcnt := 0; -- added for bug 5665772

   LOOP
     --bug 3716805
     exit when l_rollup_table.count = 0;
     --end bug 3716805
     IF (l_rollup_table(l_cnt).object_type = 'PA_TASKS') THEN
/*  Not doing anything. Also I checked PA_TASK_MAINT_PUB and PVT.update_task. Its not using record version number
    so its useless here.
      OPEN get_task_record_ver_number(l_task_id);
      FETCH get_task_record_ver_number INTO l_task_record_version_number;
      CLOSE get_task_record_ver_number;
*/

--bug 2831656
      OPEN cur_proj_elem_id( l_rollup_table(l_cnt).object_id);
      FETCH cur_proj_elem_id INTO l_proj_element_id2,
                                  l_element_number;  --bug 3043580;
      CLOSE cur_proj_elem_id;
--bug 2831656

--bug 3974958
      IF ('Y' = PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_proj_element_id2)) THEN
--end bug 3974958
      /* Start of changes for bug 5665772 */

 	   SELECT pt.parent_task_id,
 	          pt.start_date,
 	          pt.completion_date
 	   INTO   l_parent_task_id,
 	          l_tstart_date,
 	          l_tend_date
 	   FROM pa_tasks pt
 	   WHERE pt.task_id = l_proj_element_id2;

 	   IF ((nvl(l_rollup_table(l_cnt).start_date1,sysdate) <> nvl(l_tstart_date,sysdate))
 	              OR (nvl(l_rollup_table(l_cnt).finish_date1,sysdate) <> nvl(l_tend_date,sysdate))) THEN

 	            l_tcnt := l_tcnt + 1;

 	            l_task_dates(l_tcnt).task_id := l_proj_element_id2;
 	            l_task_dates(l_tcnt).parent_task_id := l_parent_task_id;
 	            l_task_dates(l_tcnt).old_start_date := l_tstart_date;
 	            l_task_dates(l_tcnt).old_end_date := l_tend_date;
 	            l_task_dates(l_tcnt).new_start_date := l_rollup_table(l_cnt).start_date1;
 	            l_task_dates(l_tcnt).new_end_date := l_rollup_table(l_cnt).finish_date1;

 	   END IF;

      /* End of changes for bug 5665772 */
        PA_TASKS_MAINT_PUB.Update_Task (
         p_init_msg_list          => p_init_msg_list
        ,p_commit                 => FND_API.G_FALSE
        ,p_validate_only          => p_validate_only
        ,p_calling_module         => p_calling_module
        ,p_debug_mode             => p_debug_mode
        ,p_project_id             => p_project_id
--      ,p_task_id                => l_proj_elem_tbl(l_cnt)    --bug 2831656
        ,p_task_id                => l_proj_element_id2           --bug 2831656
        ,p_task_number            => l_element_number             --bug 3043580
        ,p_task_start_date        => l_rollup_table(l_cnt).start_date1
        ,p_task_completion_date   => l_rollup_table(l_cnt).finish_date1
        ,p_record_version_number  => l_task_record_version_number
        ,p_update_subtasks_end_dt => 'N'    --bug 4241863
	,p_dates_check            => 'N'    --bug 5665772
        ,x_return_status          => l_return_status
        ,x_msg_count              => l_msg_count
        ,x_msg_data               => l_msg_data );
--bug 3974958
      END IF;
--end bug 3974958

    END IF;

--bug 2868685
     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       x_msg_count := FND_MSG_PUB.count_msg;
       if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_msg_count      => l_msg_count,
            p_msg_data       => l_msg_data,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
       end if;
       raise FND_API.G_EXC_ERROR;
     end if;
--bug 2868685

     EXIT when l_cnt = l_rollup_table.Last;
     l_cnt := l_rollup_table.NEXT(l_cnt);
   END LOOP;

 /* Start of changes for bug 5665772 */

 -- Validate transaction dates

 IF l_task_dates.COUNT <> 0 THEN

 	  l_tcnt := l_task_dates.First;
 	  LOOP

 	  IF (nvl(l_task_dates(l_tcnt).old_start_date,sysdate) <>
 	             nvl(l_task_dates(l_tcnt).new_start_date,sysdate)) THEN

 	            PA_TASKS_MAINT_UTILS.Check_Start_Date(
 	              p_project_id => p_project_id,
 	              p_parent_task_id => l_task_dates(l_tcnt).parent_task_id,
 	              p_task_id => NULL,
 	              p_start_date => l_task_dates(l_tcnt).new_start_date,
 	              x_return_status => l_return_status,
 	              x_msg_count => l_msg_count,
 	              x_msg_data => l_msg_data);

 	            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
 	              PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
 	            END IF;

 	  END IF;

 	  IF (nvl(l_task_dates(l_tcnt).old_end_date,sysdate) <>
 	             nvl(l_task_dates(l_tcnt).new_end_date,sysdate)) THEN

 	            PA_TASKS_MAINT_UTILS.Check_End_Date(
 	              p_project_id => p_project_id,
 	              p_parent_task_id => l_task_dates(l_tcnt).parent_task_id,
 	              p_task_id => l_task_dates(l_tcnt).task_id,
 	              p_end_date => l_task_dates(l_tcnt).new_end_date,
 	              x_return_status => l_return_status,
 	              x_msg_count => l_msg_count,
 	              x_msg_data => l_msg_data);

 	            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
 	              PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
 	            END IF;

 	  END IF;

 	  l_msg_count := FND_MSG_PUB.count_msg;
 	  IF (l_msg_count > 0) THEN
 	           x_msg_count := l_msg_count;
 	           IF (x_msg_count = 1) THEN
 	             pa_interface_utils_pub.get_messages(
 	               p_encoded => FND_API.G_TRUE,
 	               p_msg_index => 1,
 	               p_data => l_data,
 	               p_msg_index_out => l_msg_index_out);
 	            x_msg_data := l_data;
 	           END IF;
 	           RAISE FND_API.G_EXC_ERROR;
 	  END IF;

 	  EXIT when l_tcnt = l_task_dates.Last;
 	  l_tcnt := l_task_dates.NEXT(l_tcnt);

 	  END LOOP;

 END IF;

 /* End of changes for bug 5665772 */

-- Commented out by hsiu
-- date_type is no longer an input
--   if p_date_type NOT IN ('ESTIMATED', 'ACTUAL', 'BASELINE', 'SCHEDULED') THEN
--      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                           p_msg_name => 'PA_INVALID_DATE_TYPE');
--   end if;

--   l_msg_count := FND_MSG_PUB.count_msg;
--   if l_msg_count > 0 then
--      x_msg_count := l_msg_count;
--      if x_msg_count = 1 then
--         pa_interface_utils_pub.get_messages
--         (p_encoded        => FND_API.G_TRUE,
--          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
--          p_data           => l_data,
--          p_msg_index_out  => l_msg_index_out);
--         x_msg_data := l_data;
--      end if;
--      raise FND_API.G_EXC_ERROR;
--   end if;

   -- Loop through all of the tasks in this project and copy the appropriate dates
--   OPEN task_csr;
--   LOOP
--      FETCH task_csr INTO l_task_id;
--      EXIT WHEN task_csr%NOTFOUND;

--      OPEN get_task_record_ver_number(l_task_id);
--      FETCH get_task_record_ver_number INTO l_task_record_version_number;
--      CLOSE get_task_record_ver_number;

-- Removed for new copy strategy
--
--      if p_date_type = 'SCHEDULED' then
--         OPEN latest_published_ver_csr;
--         FETCH latest_published_ver_csr INTO l_structure_version_id;
--         if latest_published_ver_csr%NOTFOUND then
--            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                           p_msg_name => 'PA_NO_PUBLISHED_VERSION');
--            CLOSE latest_published_ver_csr;
--
--            x_msg_count := FND_MSG_PUB.count_msg;
--
--            pa_interface_utils_pub.get_messages
--            (p_encoded        => FND_API.G_TRUE,
--             p_msg_index      => 1,
--             p_msg_count      => l_msg_count,
--             p_msg_data       => l_msg_data,
--             p_data           => l_data,
--             p_msg_index_out  => l_msg_index_out);
--            x_msg_data := l_data;
--
--            raise FND_API.G_EXC_ERROR;
--         else
--            CLOSE latest_published_ver_csr;
--
--            OPEN get_task_sch_dates_csr(l_structure_version_id, l_task_id);
--            FETCH get_task_sch_dates_csr INTO l_task_start_date, l_task_finish_date;
--            CLOSE get_task_sch_dates_csr;
--
--         end if;
--      elsif p_date_type = 'ACTUAL' then
--         OPEN get_task_act_dates_csr(l_task_id);
--         FETCH get_task_act_dates_csr INTO l_task_start_date, l_task_finish_date;
--         CLOSE get_task_act_dates_csr;
--      elsif p_date_type = 'ESTIMATED' then
--         OPEN get_task_est_dates_csr(l_task_id);
--         FETCH get_task_est_dates_csr INTO l_task_start_date, l_task_finish_date;
--         CLOSE get_task_est_dates_csr;
--      elsif p_date_type = 'BASELINE' then
--         OPEN get_task_bas_dates_csr(l_task_id);
--         FETCH get_task_bas_dates_csr INTO l_task_start_date, l_task_finish_date;
--         CLOSE get_task_bas_dates_csr;
--      end if;
--
--      if(p_buffer <> FND_API.G_MISS_NUM) AND (p_buffer IS NOT NULL) then
--         l_task_start_date := l_task_start_date + p_buffer;
--         l_task_finish_date := l_task_finish_date + p_buffer;
--      end if;
--
--      PA_TASKS_MAINT_PUB.Update_Task (
--       p_init_msg_list          => p_init_msg_list
--      ,p_commit                 => FND_API.G_FALSE
--      ,p_validate_only          => p_validate_only
--      ,p_calling_module         => p_calling_module
--      ,p_debug_mode             => p_debug_mode
--      ,p_project_id             => p_project_id
--      ,p_task_id                => l_task_id
--      ,p_task_start_date        => l_task_start_date
--      ,p_task_completion_date   => l_task_finish_date
--      ,p_record_version_number  => l_task_record_version_number
--      ,x_return_status          => l_return_status
--      ,x_msg_count              => l_msg_count
--      ,x_msg_data               => l_msg_data );
--
--      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
--         x_msg_count := FND_MSG_PUB.count_msg;
--         if x_msg_count = 1 then
--            pa_interface_utils_pub.get_messages
--            (p_encoded        => FND_API.G_TRUE,
--             p_msg_index      => 1,
--             p_msg_count      => l_msg_count,
--             p_msg_data       => l_msg_data,
--             p_data           => l_data,
--             p_msg_index_out  => l_msg_index_out);
--            x_msg_data := l_data;
--         end if;
--         raise FND_API.G_EXC_ERROR;
--      end if;
--   END LOOP;

   -- Now copy over project level dates
--   OPEN get_proj_record_ver_number;
--   FETCH get_proj_record_ver_number INTO l_proj_record_version_number;
--   CLOSE get_proj_record_ver_number;

--   if p_date_type = 'SCHEDULED' then
--      OPEN get_proj_sch_dates_csr;
--      FETCH get_proj_sch_dates_csr INTO l_proj_start_date, l_proj_finish_date;
--      CLOSE get_proj_sch_dates_csr;
--   elsif p_date_type = 'ACTUAL' then
--      OPEN get_proj_act_dates_csr;
--      FETCH get_proj_act_dates_csr INTO l_proj_start_date, l_proj_finish_date;
--      CLOSE get_proj_act_dates_csr;
--   elsif p_date_type = 'ESTIMATED' then
--      OPEN get_proj_est_dates_csr;
--      FETCH get_proj_est_dates_csr INTO l_proj_start_date, l_proj_finish_date;
--      CLOSE get_proj_est_dates_csr;
--   elsif p_date_type = 'BASELINE' then
--      OPEN get_proj_bas_dates_csr;
--      FETCH get_proj_bas_dates_csr INTO l_proj_start_date, l_proj_finish_date;
--      CLOSE get_proj_bas_dates_csr;
--   end if;

--   if(p_buffer <> FND_API.G_MISS_NUM) AND (p_buffer IS NOT NULL) then
--      l_proj_start_date := l_proj_start_date + p_buffer;
--      l_proj_finish_date := l_proj_finish_date + p_buffer;
--   end if;

--   PA_PROJECT_DATES_PUB.Update_Project_Dates (
--    p_init_msg_list          => p_init_msg_list
--   ,p_commit                 => FND_API.G_FALSE
--   ,p_validate_only          => p_validate_only
--   ,p_calling_module         => p_calling_module
--   ,p_debug_mode             => p_debug_mode
--   ,p_project_id             => p_project_id
--   ,p_date_type              => p_date_type
--   ,p_start_date             => l_proj_start_date
--   ,p_finish_date            => l_proj_finish_date
--   ,p_record_version_number  => l_proj_record_version_number
--   ,x_return_status          => l_return_status
--   ,x_msg_count              => l_msg_count
--   ,x_msg_data               => l_msg_data );

--   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
--      x_msg_count := FND_MSG_PUB.count_msg;
--      if x_msg_count = 1 then
--         pa_interface_utils_pub.get_messages
--         (p_encoded        => FND_API.G_TRUE,
--          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
--          p_data           => l_data,
--          p_msg_index_out  => l_msg_index_out);
--         x_msg_data := l_data;
--      end if;
--      raise FND_API.G_EXC_ERROR;
--   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PUB.Copy_Project_Dates END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PUB',
                              p_procedure_name => 'Copy_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PUB',
                              p_procedure_name => 'Copy_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END COPY_PROJECT_DATES;


-- API name		: Update_Project_Dates
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_api_version                   IN NUMBER     Required Default = 1.0
-- p_init_msg_list                 IN VARCHAR2   Optional Default = FND_API.G_TRUE
-- p_commit                        IN VARCHAR2   Required Default = FND_API.G_FALSE
-- p_validate_only                 IN VARCHAR2   Required Default = FND_API.G_TRUE
-- p_validation_level              IN NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
-- p_calling_module                IN VARCHAR2   Optional Default = 'SELF_SERVICE'
-- p_debug_mode                    IN VARCHAR2   Optional Default = 'N'
-- p_max_msg_count                 IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_project_id                    IN NUMBER     Required
-- p_date_type                     IN VARCHAR2   Required
-- p_start_date                    IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_finish_date                   IN DATE       Optional Default = FND_API.G_MISS_DATE
-- p_record_version_number         IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_return_status                 OUT VARCHAR2  Required
-- x_msg_count                     OUT NUMBER    Required
-- x_msg_data                      OUT VARCHAR2  Optional

PROCEDURE UPDATE_PROJECT_DATES
(  p_api_version                   IN NUMBER     := 1.0
  ,p_init_msg_list                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_commit                        IN VARCHAR2   := FND_API.G_FALSE
  ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
  ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
  ,p_debug_mode                    IN VARCHAR2   := 'N'
  ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
  ,p_project_id                    IN NUMBER
  ,p_date_type                     IN VARCHAR2
  ,p_start_date                    IN DATE       := FND_API.G_MISS_DATE
  ,p_finish_date                   IN DATE       := FND_API.G_MISS_DATE
  ,p_record_version_number         IN NUMBER     := FND_API.G_MISS_NUM
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                      OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Project_Dates';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

BEGIN
   pa_debug.init_err_stack('PA_PROJECT_DATES_PUB.Update_Project_Dates');

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PUB.Update_Project_Dates BEGIN');
   end if;

   if p_commit = FND_API.G_TRUE then
      savepoint update_project_dates;
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
      FND_MSG_PUB.initialize;
   end if;


   if p_date_type NOT IN ('PROJECT', 'TRANSACTION', 'ESTIMATED', 'ACTUAL', 'BASELINE', 'SCHEDULED') THEN
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name => 'PA_INVALID_DATE_TYPE');
   end if;

   l_msg_count := FND_MSG_PUB.count_msg;
   if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   PA_PROJECT_DATES_PVT.UPDATE_PROJECT_DATES
   ( p_commit                    => FND_API.G_FALSE
    ,p_validate_only             => p_validate_only
    ,p_validation_level          => p_validation_level
    ,p_calling_module            => p_calling_module
    ,p_debug_mode                => p_debug_mode
    ,p_max_msg_count             => p_max_msg_count
    ,p_project_id                => p_project_id
    ,p_date_type                 => p_date_type
    ,p_start_date                => p_start_date
    ,p_finish_date               => p_finish_date
    ,p_record_version_number     => p_record_version_number
    ,x_return_status             => l_return_status
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_commit = FND_API.G_TRUE then
      commit work;
   end if;

   if (p_debug_mode = 'Y') then
      pa_debug.debug('PA_PROJECT_DATES_PUB.Update_Project_Dates END');
   end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PUB',
                              p_procedure_name => 'Update_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_project_dates;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_DATES_PUB',
                              p_procedure_name => 'Update_Project_Dates',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END UPDATE_PROJECT_DATES;


END PA_PROJECT_DATES_PUB;

/
