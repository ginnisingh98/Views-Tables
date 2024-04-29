--------------------------------------------------------
--  DDL for Package Body PA_XC_PROJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_XC_PROJECT_PUB" AS
/*$Header: PAXCPR1B.pls 120.7.12010000.3 2009/06/15 09:59:49 kmaddi ship $*/

--
--Name:               import_task
--Type:                 Procedure
--Description: This procedure can be used to upload task information
--             into Global memory table.
--
--Called subprograms: Nil
--
--
--
--History:
--       31-MAR-2000  - Sakthi -    Created
--       03-APR-2003  - Amit   -    Bug 2873691 - In import_task, in the cursor
--                                  get_parent_id_csr, added a join of parent_structure_version_id
--       09-Feb-2004 - Sulkumar     Bug 3302732: Added functions
--                                           generate_new_task_reference
--                                           check_ref_unique
--                                  For Procedure fetch_task_idchanged parameter p_task_index type to VARCHAR2
--                                  from NUMBER. Changed the logic for populating task reference. It is now
--                                  used as VARCHAR2 instead of number. All changes are tagged by bug no.3302732
--       22-Jul-2004 - dthakker     3693934 Changed pa_proj_elements_csr cursor for performance fix
--                                          Changed pa_schedule_dates_csr cursor for performance fix
--                                          Commented l_get_working_version_csr existing cursor definition and added new definition
--                                              for the same
--       23-JUL-04     adarora      Bug 3627124 :
--                                  3696234 : Added the parameter, p_pass_entire_structure in the procedure call to
--                                  pa_project_pub.execute_update_project in the procedure Import_project.
--      15-MAR-2005 -- adarora      Bug 3601700:Modified check_ref_unique to handle split case.
--	23-May-2006    sliburd for amksingh        Bug 5233777 : Added new parameter p_resp_appl_id in import_project
--
--       09-OCT-2006   Ram Namburi      Bug 5465108: Added the parameter p_long_task_name in the procedure
--                                  call to PA_PROJECT_PUB.load_task
--       22-AUG-2008   rballamu     Bug 7245488: Passed Schedule start/finish dates to PA_PROJECT_PUB.load_task.

PROCEDURE import_task
( p_project_id                IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_reference            IN  PA_VC_1000_25
 ,p_task_name                 IN  PA_VC_1000_150
 ,p_task_start_date           IN  PA_VC_1000_10
 ,p_task_end_date             IN  PA_VC_1000_10
 ,p_parent_task_reference     IN  PA_VC_1000_25
 ,p_task_number               IN  PA_VC_1000_25
 ,p_wbs_level                 IN  PA_NUM_1000_NUM
 ,p_milestone                 IN  PA_VC_1000_150
 ,p_duration                  IN  PA_VC_1000_150
 ,p_duration_unit             IN  PA_VC_1000_150
 ,p_early_start_date          IN  PA_VC_1000_10
 ,p_early_finish_date         IN  PA_VC_1000_10
 ,p_late_start_date           IN  PA_VC_1000_10
 ,p_late_finish_date          IN  PA_VC_1000_10
 ,p_display_seq               IN  PA_VC_1000_150
 ,p_login_user_name           IN  PA_VC_1000_150:= PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_critical_path             IN  PA_VC_1000_150
 ,p_sub_project_id            IN  PA_VC_1000_150
 ,p_attribute7                IN  PA_VC_1000_150
 ,p_attribute8                IN  PA_VC_1000_150
 ,p_attribute9                IN  PA_VC_1000_150
 ,p_attribute10               IN  PA_VC_1000_150
 ,p_progress_report           IN  PA_VC_1000_4000
 ,p_progress_status           IN  PA_VC_1000_150
 ,p_progress_comments         IN  PA_VC_1000_150
 ,p_progress_asof_date        IN  PA_VC_1000_10
 ,p_predecessors              IN  PA_VC_1000_2000
 ,p_language                  IN  VARCHAR2 default 'US'
 ,p_delimiter                 IN  VARCHAR2 default ','
 ,p_structure_version_id      IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_calling_mode              IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 )

IS

l_api_name              CONSTANT    VARCHAR2(30):='Import_Task';
l_return_status                     VARCHAR2(1);
l_responsibility_id                 NUMBER;
i                                   NUMBER := 0;
l_task_reference                    NUMBER := 0;
l_count                             NUMBER := 0;

l_task_manager_flag                 VARCHAR2(1) := 'Y';
l_early_start_date          DATE := NULL;
l_early_finish_date         DATE := NULL;
l_late_start_date           DATE := NULL;
l_late_finish_date          DATE := NULL;

l_task_start_date           DATE := NULL;
l_task_finish_date          DATE := NULL;
l_sched_start_date          DATE;  /* 7245488 */
l_sched_fin_date            DATE; /* 7245488 */
l_long_task_name        pa_tasks.long_task_name%TYPE := null; -- Added for bug 5465108

l_task_id                       NUMBER :=NULL;
l_task_manager_id                   NUMBER :=NULL;

l_milestone                         VARCHAR2(1) := 'N';
l_critical_path                     VARCHAR2(1) := 'N';

CURSOR   l_get_employee_id (l_login_user_name  VARCHAR2)
IS
SELECT EMPLOYEE_ID
  FROM FND_USER
 WHERE UPPER(USER_NAME) = upper(l_login_user_name);


CURSOR   l_get_temp_record (c_project_id  NUMBER)
IS
SELECT   PROJECT_ID
FROM     PA_TEMP_IMPORT_TASKS
WHERE    PROJECT_ID = c_project_id;

-- Retrieve tasks from PA_PROJ_ELEMENTS table
CURSOR pa_proj_elements_csr(c_structure_version_id NUMBER, c_project_id NUMBER)
IS
SELECT ppe.proj_element_id, ppe.name, ppe.element_number, ppe.description, ppe.pm_source_reference, ppe.manager_person_id, ppe.carrying_out_organization_id
FROM   PA_PROJ_ELEMENTS ppe, PA_PROJ_ELEMENT_VERSIONS ppev
WHERE  ppe.project_id = c_project_id
AND    ppe.project_id = ppev.project_id  -- 3693934 added for peformance fix
AND    ppe.object_type = 'PA_TASKS'
AND    ppe.proj_element_id = ppev.proj_element_id
AND    ppev.parent_structure_version_id = c_structure_version_id
AND    ppev.financial_task_flag = 'Y'
ORDER BY ppev.display_sequence;

l_proj_elements_rec       pa_proj_elements_csr%ROWTYPE;

-- Retrieve task Scheduled Start and Scheduled End Date from PA_PROJ_ELEM_VER_SCHEDULE table
CURSOR  pa_schedule_dates_csr (c_structure_version_id NUMBER, c_proj_element_id NUMBER)
IS
SELECT  ppevs.scheduled_start_date, ppevs.scheduled_finish_date
FROM PA_PROJ_ELEMENT_VERSIONS ppev, PA_PROJ_ELEM_VER_SCHEDULE ppevs
WHERE  ppev.element_version_id = ppevs.element_version_id
AND    ppev.project_id = ppevs.project_id   -- 3693934 added for peformance fix
AND    ppev.object_type = 'PA_TASKS'
AND    ppev.proj_element_id = c_proj_element_id
AND    ppev.parent_structure_version_id = c_structure_version_id;

-- Retrieve task Start and End Date from PA_TASKS table
CURSOR  pa_tasks_dates_csr (c_task_id NUMBER)
IS
SELECT start_date, completion_date, long_task_name -- Modified for bug 5465108
FROM pa_tasks
WHERE task_id = c_task_id;

CURSOR get_parent_id_csr (c_proj_element_id NUMBER)
IS
  SELECT ppev2.proj_element_id
    FROM PA_OBJECT_RELATIONSHIPS por,
         PA_PROJ_ELEMENT_VERSIONS ppev,
         PA_PROJ_ELEMENT_VERSIONS ppev2
    WHERE por.relationship_type = 'S'
    AND por.object_id_to1 = ppev.element_version_id
    AND por.object_type_from = 'PA_TASKS'
    AND ppev.proj_element_id =  c_proj_element_id
    AND ppev.parent_structure_version_id = p_structure_version_id -- Bug 2873691
    AND ppev2.element_version_id = por.object_id_from1;

l_pa_parent_task_id        NUMBER;
l_pm_parent_task_reference VARCHAR2(25);
l_source_ref_count         NUMBER;
l_pm_source_reference      VARCHAR2(25);

TYPE SourceRefs IS TABLE OF VARCHAR2(25)
       INDEX BY BINARY_INTEGER;

l_source_ref_table         SourceRefs;

--hsiu added
--Bug 3302732: Commenting this cursor.
/*cursor l_pm_source_ref(c_structure_version_id NUMBER, c_project_id NUMBER) IS
   select  min(to_Number(ppe.pm_source_reference))
     FROM  PA_PROJ_ELEMENTS ppe, PA_PROJ_ELEMENT_VERSIONS ppev
    WHERE  ppe.project_id = c_project_id
      AND  ppe.object_type = 'PA_TASKS'
      AND  ppe.proj_element_id = ppev.proj_element_id
      AND  ppev.parent_structure_version_id = c_structure_version_id; */

--hyau added for debugging unhandled exception stage
  l_stage           VARCHAR2(250);
  l_counter           NUMBER;

--hsiu added for initializing pm_source_reference
 CURSOR get_pa_task(c_proj_element_id NUMBER) IS
    select task_id from pa_tasks
     where task_id = c_proj_element_id;
 l_exist_pa_task_id   NUMBER;

l_debug_mode VARCHAR2(1); -- Fix for Bug # 4513291.

BEGIN

-- Fix for Bug # 4513291. Added Debug write calls
l_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');
IF l_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_TASK', x_Msg => 'PA_XC_PROJECT_PUB.IMPORT_TASK Start : Passed Parameters :', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_TASK', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_TASK', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_TASK', x_Msg => 'p_calling_mode='||p_calling_mode, x_Log_Level=> 3);
END IF;

l_stage := '1';

if p_calling_mode = 'PUBLISH' then

   --bug 2738747 : The global task table should be initialized before adding any tasks in the pl/sql table.
   --From project connect after receiveing a project plan we can always add tasks and subsequently publish
   --the structure. Project connect will load the tasks to update(exisiting tasks) and add(new tasks) in
   --pl/sql table and then calls the publishing API. The publish_structure api calls this API to load tasks
   --in the same pl/sql table. If we dont flush out the tasks already loaded by project connect update
   --then this api will load the same tasks again and publish_structure will fail.

   pa_project_pub.G_tasks_in_tbl.delete;

  --dbms_output.put_line('Inside publish');

  -- Delete tasks from the temp database table

     OPEN l_get_temp_record (p_project_id);
     FETCH l_get_temp_record INTO l_count;

     IF l_get_temp_record%FOUND THEN
        CLOSE l_get_temp_record;
        delete from PA_TEMP_IMPORT_TASKS where project_id = p_project_id;
     ELSE
        CLOSE l_get_temp_record;
     END IF;

  l_stage := '2';

  -- Need to generate source reference numbers for those tasks that dont have one
  -- hsiu added

  -- Bug 3302732: Commenting this logic to get task_reference

  /*   open l_pm_source_ref(p_structure_version_id, p_project_id);
     FETCH l_pm_source_ref INTO l_source_ref_count;
     IF l_pm_source_ref%NOTFOUND THEN
       l_source_ref_count := -1;
     ELSE
       IF (l_source_ref_count IS NULL) THEN
         l_source_ref_count := -1;
       ELSE
         l_source_ref_count := l_source_ref_count - 1;
       END IF;
     END IF;
     close l_pm_source_ref; */

     l_stage := '3';
     l_counter :=0;

  -- Fetch task info from PA_PROJ_ELEMENTS table

  OPEN PA_PROJ_ELEMENTS_CSR(p_structure_version_id, p_project_id);
  LOOP

    FETCH PA_PROJ_ELEMENTS_CSR INTO l_proj_elements_rec;
    EXIT WHEN PA_PROJ_ELEMENTS_CSR%NOTFOUND;

    l_counter := l_counter+1;
    l_stage := '3.1 Loop '||to_char(l_counter);

    if l_proj_elements_rec.pm_source_reference is null then

       -- if the task has no source reference, create one
 -- Bug 3302732       l_pm_source_reference := l_source_ref_count;

      -- Bug 3302732: Now a new task reference is generated via new function generate_new_task_reference
      l_pm_source_reference := generate_new_task_reference(p_project_id, l_proj_elements_rec.proj_element_id);

       --hsiu added for initializing tasks

       OPEN get_pa_task(l_proj_elements_rec.proj_element_id);
       FETCH get_pa_task into l_exist_pa_task_id;

       IF (get_pa_task%FOUND) THEN

         update pa_tasks
            set pm_task_reference = l_pm_source_reference -- Bug 3302732 l_source_ref_count
          where task_id = l_exist_pa_task_id;

         update pa_proj_elements
            set pm_source_reference = l_pm_source_reference -- Bug 3302732 l_source_ref_count
          where proj_element_id = l_exist_pa_task_id;

       END IF;
       CLOSE get_pa_task;

       l_source_ref_table(l_proj_elements_rec.proj_element_id) := l_pm_source_reference;
    --   l_source_ref_count := l_source_ref_count - 1; -- Bug 3302732 : Commented this.
     else
       l_pm_source_reference := l_proj_elements_rec.pm_source_reference;
       l_source_ref_table(l_proj_elements_rec.proj_element_id) := l_proj_elements_rec.pm_source_reference;
     end if;

     l_stage := '3.2';

     -- fetch the task id from PA_TASKS based on the source reference

     PA_XC_PROJECT_PUB.fetch_task_id
      ( p_task_index        => l_pm_source_reference -- Bug 3302732 to_number(l_pm_source_reference)
       ,p_project_id        => p_project_id
       ,p_pm_task_reference => l_pm_source_reference
       ,x_task_id         => l_task_id);

     l_stage := '3.3';

     -- get the task id of the parent of this task

     OPEN get_parent_id_csr(l_proj_elements_rec.proj_element_id);
     FETCH get_parent_id_csr into l_pa_parent_task_id;
--hsiu
     IF get_parent_id_csr%NOTFOUND THEN
       l_pa_parent_task_id := NULL;
     END IF;
     CLOSE get_parent_id_csr;

     l_stage := '3.4';

     -- get the source reference of the parent task
     if(l_pa_parent_task_id is not null) then
       l_pm_parent_task_reference := l_source_ref_table(l_pa_parent_task_id);
     else
       l_pm_parent_task_reference := null;
     end if;

     l_stage := '3.5';

     OPEN pa_tasks_dates_csr (l_proj_elements_rec.proj_element_id);
     FETCH pa_tasks_dates_csr INTO l_task_start_date, l_task_finish_date, l_long_task_name; -- Modified for bug 5465108
     --bug 2858227  see update *** AAKASH  03/19/03 10:09 pm *** senario 3
     IF pa_tasks_dates_csr%NOTFOUND
     THEN
        --Commented and replpaced following for BUG 4278979, rtarway
    --l_task_start_date := null;
        --l_task_finish_date := null;

      l_task_start_date  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
          l_task_finish_date := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
      l_long_task_name   := null; -- Added for bug 5465108


     END IF;
     --bug 2858227
     CLOSE pa_tasks_dates_csr;

     --end if;

     l_stage := '3.6';

     -- populate the temp table
     -- note that we are populating with the proj_element_id from PA_PROJ_ELEMENTS,
     -- not the task_id from fetch_task_id
     -- this is because fetch_task_id will only return those task ids in PA_TASKS, but
     -- we need the proj_element_id to sync up with the task ids created by AMG later

     INSERT INTO PA_TEMP_IMPORT_TASKS
     ( PROJECT_ID
      ,TASK_REFERENCE
      ,TASK_ID)
     VALUES
     ( p_project_id
      ,l_pm_source_reference
      ,l_proj_elements_rec.proj_element_id);

     l_stage := '3.7';

     OPEN  pa_schedule_dates_csr(p_structure_version_id,l_proj_elements_rec.proj_element_id);  /* 7245488 */
     FETCH pa_schedule_dates_csr INTO l_sched_start_date,l_sched_fin_date;
     CLOSE pa_schedule_dates_csr;

     PA_PROJECT_PUB.load_task (
      p_api_version_number      => G_API_VERSION_NUMBER
     ,p_return_status               => l_return_status
     ,p_pm_task_reference       => l_pm_source_reference
     ,p_pa_task_id          => l_task_id
     ,p_task_name           => l_proj_elements_rec.name
     ,p_long_task_name      => nvl(l_long_task_name, l_proj_elements_rec.name)  -- Added for bug 5465108
     ,p_pa_task_number              => l_proj_elements_rec.element_number
     ,p_task_description        => l_proj_elements_rec.description
     ,p_task_start_date         => l_task_start_date
     ,p_task_completion_date            => l_task_finish_date
     ,p_scheduled_start_date        => l_sched_start_date  --7245488
     ,p_scheduled_finish_date           => l_sched_fin_date  --7245488
     ,p_pm_parent_task_reference    => l_pm_parent_task_reference
     ,p_pa_parent_task_id       => null
     ,p_carrying_out_organization_id    => l_proj_elements_rec.carrying_out_organization_id
     ,p_task_manager_person_id          => l_proj_elements_rec.manager_person_id
     ,p_attribute1          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute2          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute3          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute4          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute5          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute6          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute7          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute8          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute9          => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     ,p_attribute10         => PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    );

     l_stage := '3.8';

  END LOOP;
--hyau

  CLOSE PA_PROJ_ELEMENTS_CSR;

  l_stage := '4';

end if;  -- calling_mode

  l_stage := '6';

EXCEPTION
  WHEN OTHERS THEN

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_XC_PROJECT_PUB',
                            p_procedure_name => 'IMPORT_TASK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240)||' - stage '||l_stage);
    raise;

END Import_task;

--
-- ================================================
--
--
--Name:               import_project
--Type:                 Procedure
--Description: This procedure can be used to update a project on basis
--             of an existing project or template.
--
--Called subprograms: Nil
--
--
--
--History:
--       31-MAR-2000  - Sakthi -    Created
--


-- Procedure Import Project.

PROCEDURE import_project
( p_user_id                   IN  NUMBER
 ,p_commit                    IN  VARCHAR2 default 'N'
 ,p_debug_mode                IN  VARCHAR2 default 'N'
 ,p_project_id                IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_mpx_start_date    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_mpx_end_date      IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_task_mgr_override         IN  VARCHAR2 default 'N'
 ,p_task_pgs_override         IN  VARCHAR2 default 'N'
 ,p_process_id                IN  NUMBER default -1
 ,p_language                  IN  VARCHAR2 default 'US'
 ,p_delimiter                 IN  VARCHAR2 default ','
 ,p_responsibility_id         IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_id              IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id      IN  NUMBER
 ,p_calling_mode              IN  VARCHAR2
 ,p_resp_appl_id              IN  NUMBER default 275 --   5233777
 ,x_msg_count             IN OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              IN OUT  NOCOPY PA_VC_1000_2000 --File.Sql.39 bug 4440895
 ,x_return_status         IN OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

l_api_name              CONSTANT    VARCHAR2(30):='Import_Project';
l_project_name                      VARCHAR2(30);
l_pm_product_code       CONSTANT    VARCHAR2(30):='MSPROJECT';
l_return_status                     VARCHAR2(1) ;
l_workflow_started                  VARCHAR2(1) := 'N' ;
l_responsibility_id                 NUMBER;
l_task_reference                    VARCHAR2(25);
l_task_index                        NUMBER;
l_task_id                           NUMBER;
l_out_project_id                    NUMBER;
l_out_task_id                       NUMBER;
l_pm_product_code2                  VARCHAR2(30);

l_task_return_status                VARCHAR2(1);
l_pm_task_reference                 VARCHAR2(25);
l_project_reference                 VARCHAR2(25);
l_project_mpx_start_date            DATE;
l_project_mpx_end_date              DATE;

l_dummy                             pa_projects_all.name%TYPE;

l_err_code                          NUMBER := 0;
l_err_stage                         VARCHAR2(2000);
l_err_stack                         VARCHAR2(2000);

l_msg_count                         NUMBER := 0;
l_msg_data                          PA_VC_1000_2000 := PA_VC_1000_2000(1);

p_msg_count                         NUMBER;
p_msg_data                          VARCHAR2(2000);
l_text                              VARCHAR2(2000);
API_ERROR                           EXCEPTION;

l_task_start_date                   PA_VC_1000_10 := PA_VC_1000_10(1);
l_task_end_date                     PA_VC_1000_10 := PA_VC_1000_10(1);


   -- needed to get the field values associated to a particular Task_Id
   CURSOR   l_get_task_csr (p_project_id   NUMBER)
   IS
   SELECT   task_id
   FROM     pa_tasks
   WHERE    project_id = p_project_id;

   -- needed to get the field values associated to a particular Project_id
   CURSOR   l_get_project_csr (p_project_id   NUMBER)
   IS
   SELECT   name
   FROM     pa_projects
   WHERE    project_id = p_project_id;

   -- Fix for Bug # 4513291. Commented below cusror and added new
   /*
   -- needed to get the the set of tasks to be deleted
   CURSOR   l_get_temp_task_csr(l_project_id NUMBER)
   IS
   SELECT   PM_TASK_REFERENCE, task_id
   FROM     pa_tasks
   WHERE    project_id = l_project_id
   MINUS
   SELECT   TASK_REFERENCE, task_id
   FROM     pa_temp_import_tasks
   WHERE    project_id = l_project_id
   ORDER BY 1;
   */

   CURSOR   l_get_temp_task_csr(l_project_id NUMBER)
   IS
   SELECT   PM_TASK_REFERENCE, task_id
   FROM     pa_tasks ttask
   WHERE    project_id = l_project_id
   AND      task_id not in
        (
           SELECT   task_id
           FROM     pa_temp_import_tasks
           WHERE    project_id = l_project_id
           AND      task_id = ttask.task_id
         )
   ORDER BY ttask.wbs_level desc;

   l_msg_index_out          NUMBER;
   l_data                   VARCHAR2(2000);
   temp_msg_data            VARCHAR2(2000);
   l_rowid                  VARCHAR2(100);

  -- needed to lock the project so users cannot import plans for the same
  -- project simultaneously
  CURSOR lock_project_record (c_project_id NUMBER)
  IS
  SELECT  name
  FROM PA_PROJECTS_ALL
  WHERE project_id = c_project_id
  FOR UPDATE of name NOWAIT;

  l_org_id          NUMBER;

  -- checks whether the structure is a financial structure type
  CURSOR l_check_financial_purpose_csr(c_structure_id NUMBER)
  IS
  SELECT 'Y'
  FROM PA_PROJ_STRUCTURE_TYPES ppst,
       PA_STRUCTURE_TYPES pst
  WHERE ppst.proj_element_id = c_structure_id
  AND   ppst.structure_type_id = pst.structure_type_id
  AND   (pst.structure_type = 'FINANCIAL');

  -- checks whether the structure is a workplan structure type
  CURSOR l_check_workplan_purpose_csr(c_structure_id NUMBER)
  IS
  SELECT 'Y'
  FROM PA_PROJ_STRUCTURE_TYPES ppst,
       PA_STRUCTURE_TYPES pst
  WHERE ppst.proj_element_id = c_structure_id
  AND   ppst.structure_type_id = pst.structure_type_id
  AND   pst.structure_type = 'WORKPLAN';

  -- checks whethere there are any published versions
  CURSOR l_check_published_csr(c_structure_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE NOT EXISTS
        (SELECT 'Y'
         FROM PA_PROJ_ELEM_VER_STRUCTURE
         WHERE proj_element_id = c_structure_id
         AND   published_date is not null);

  l_temp            VARCHAR2(1);
  l_sync_import     boolean;

  -- cursor to get the number of structures in a project
  CURSOR l_get_structure_count_csr(c_project_id NUMBER)
  IS
  SELECT count(proj_element_id)
  FROM pa_proj_elements
  WHERE project_id = c_project_id
  and object_type = 'PA_STRUCTURES'
  GROUP BY proj_element_id;

  -- cursor to get the number of structures in a project
  CURSOR l_get_structure_id_csr(c_project_id NUMBER)
  IS
  SELECT proj_element_id
  FROM pa_proj_elements
  WHERE project_id = c_project_id
    and object_type = 'PA_STRUCTURES';

  -- 3693934 for performance bug fix commented below cursor definition

  -- get working structure version
  /*
  CURSOR l_get_working_version_csr(c_structure_id NUMBER)
  IS
  SELECT ppev.element_version_id
  FROM pa_proj_element_versions ppev, pa_proj_elem_ver_structure ppevs
  WHERE ppev.proj_element_id = c_structure_id
  AND   ppev.element_version_id = ppevs.element_version_id
  AND   ppevs.published_date is null;
*/

  -- 3693934 for performance bug fix , channged cursor definiton of the above

  CURSOR l_get_working_version_csr(c_structure_id NUMBER)
  IS
  SELECT ppevs.element_version_id
  FROM pa_proj_elements ppev, pa_proj_elem_ver_structure ppevs
  WHERE ppev.proj_element_id = c_structure_id
  AND  ppev.project_id  = ppevs.project_id
  AND  ppev.proj_element_id = ppevs.proj_element_id
  AND  ppevs.published_date is null;

  -- HY get structure id
  CURSOR l_get_struct_id_csr(c_structure__version_id NUMBER)
  IS
  SELECT proj_element_id
  FROM pa_proj_element_versions
  WHERE element_version_id = c_structure__version_id;

  -- HY check for valid project id, structure id, structure version id combination.
  CURSOR l_check_proj_struct_ver_id_csr(c_project_id NUMBER, c_structure_id NUMBER,
                                        c_structure_version_id NUMBER)
  IS
  SELECT 'Y'
  FROM pa_proj_element_versions
  WHERE project_id = c_project_id
    and proj_element_id = c_structure_id
    and element_version_id = c_structure_version_id;

  -- HY check for valid project id, structure id combination.
  CURSOR l_check_proj_struct_id_csr(c_project_id NUMBER, c_structure_id NUMBER)
  IS
  SELECT 'Y'
  FROM pa_proj_elements
  WHERE project_id = c_project_id
    and proj_element_id = c_structure_id;

  -- HY check for valid project id, structure version id combination.
  CURSOR l_check_proj_ver_id_csr(c_project_id NUMBER,
                                        c_structure_version_id NUMBER)
  IS
  SELECT 'Y'
  FROM pa_proj_element_versions
  WHERE project_id = c_project_id
    and element_version_id = c_structure_version_id;

  l_project_id            NUMBER;
  l_struct_count          NUMBER;
  l_structure_id          NUMBER;
  l_structure_version_id  NUMBER;
  l_financial_purpose     VARCHAR2(1);
  l_workplan_purpose      VARCHAR2(1);
  l_validate_flag         VARCHAR2(1);

  -- 4363092 MOAC Changes, Added cursor to retrieve
  -- operating unit id of the project
  CURSOR proj_ou_id_csr
  IS
  select org_id from pa_projects_all where project_id = p_project_id;

BEGIN
-- Fix for Bug # 4513291. Added Debug.write calls instead of debug.debug
IF p_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'PA_XC_PROJECT_PUB.IMPORT_PROJECT Start : Passed Parameters :', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_project_mpx_start_date='||p_project_mpx_start_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_project_mpx_end_date='||p_project_mpx_end_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_responsibility_id='||p_responsibility_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_calling_mode='||p_calling_mode, x_Log_Level=> 3);
END IF;

  SAVEPOINT import_project;
  x_return_status := 'S';

  -- HY Check to make sure that the project id, the structure id, and the structure version id passed
  -- in are a valid combination

  if (p_structure_id is not NULL and p_structure_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and p_structure_id <>0) then
    NULL;
/*
    -- Both Structure Id and Structure Version Id are not empty.
    if (p_structure_version_id is not NULL and p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and p_structure_version_id <>0) then
        OPEN l_check_proj_struct_ver_id_csr (p_project_id, p_structure_id, p_structure_version_id);
        FETCH l_check_proj_struct_ver_id_csr INTO l_validate_flag;
        if l_check_proj_struct_ver_id_csr%NOTFOUND then
          x_msg_count := x_msg_count + 1;
          x_msg_data.extend(1);
          x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_INVLD_PROJ_STRUCT_VER');
          x_return_status := 'E';
--  dbms_output.put_line('IMP_PROJECT: Raising ERROR PA_INVLD_PROJ_STRUCT_VER');
          raise API_ERROR;
        end if;
        CLOSE l_check_proj_struct_ver_id_csr;

    else  -- Structure Id is not empty, but Structure Version is empty.
        OPEN l_check_proj_struct_id_csr (p_project_id, p_structure_id);
        FETCH l_check_proj_struct_id_csr INTO l_validate_flag;
        if l_check_proj_struct_id_csr%NOTFOUND then
          x_msg_count := x_msg_count + 1;
          x_msg_data.extend(1);
          x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_INVLD_PROJ_STRUCT_PR');
          x_return_status := 'E';
--  dbms_output.put_line('IMP_PROJECT: Raising ERROR PA_INVLD_PROJ_STRUCT_PR');
          raise API_ERROR;
        end if;
        CLOSE l_check_proj_struct_id_csr;

    end if;
  else
    --Structure ID is empty and Structure Version ID is not empty
    if (p_structure_version_id is not NULL and p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and p_structure_version_id <>0) then
        OPEN l_check_proj_ver_id_csr (p_project_id, p_structure_version_id);
        FETCH l_check_proj_ver_id_csr INTO l_validate_flag;
        if l_check_proj_ver_id_csr%NOTFOUND then
--          fnd_message.set_name('PA', 'PA_INVLD_PROJ_VER_PR');
          x_msg_count := x_msg_count + 1;
          x_msg_data.extend(1);
--          fnd_msg_pub.add;
          x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_INVLD_PROJ_VER_PR');
--          x_msg_data(x_msg_count) := fnd_message.get;
          x_return_status := 'E';
          raise API_ERROR;
        end if;
        CLOSE l_check_proj_ver_id_csr;

    end if;
  end if;

  -- Get structure/structure version id as necessary
  if p_structure_version_id is NULL OR p_structure_version_id = 0 then
    if p_structure_id is NULL OR p_structure_version_id = 0 then
      OPEN l_get_structure_count_csr(p_project_id);
      FETCH l_get_structure_count_csr INTO l_struct_count;

      if l_struct_count <> 1 then
        CLOSE l_get_structure_count_csr;
--        fnd_message.set_name('PA', 'PA_NO_STRUCTURE_ID');
        x_msg_count := x_msg_count + 1;
        x_msg_data.extend(1);
--        fnd_msg_pub.add;
--        x_msg_data(x_msg_count) := fnd_message.get;
        x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_NO_STRUCTURE_ID');
        x_return_status := 'E';
        raise API_ERROR;
      else
        OPEN l_get_structure_id_csr(p_project_id);
        FETCH l_get_structure_id_csr INTO l_structure_id;
        CLOSE l_get_structure_id_csr;
      end if;
    else
      l_structure_id := p_structure_id;
    end if;

    OPEN l_check_financial_purpose_csr(l_structure_id);
    FETCH l_check_financial_purpose_csr INTO l_financial_purpose;
    if l_check_financial_purpose_csr%NOTFOUND then
      l_financial_purpose := 'N';
    end if;
    CLOSE l_check_financial_purpose_csr;

    OPEN l_check_workplan_purpose_csr(l_structure_id);
    FETCH l_check_workplan_purpose_csr INTO l_workplan_purpose;
    if l_check_workplan_purpose_csr%NOTFOUND then
      l_workplan_purpose := 'N';
    end if;
    CLOSE l_check_workplan_purpose_csr;

    if l_financial_purpose = 'Y' and l_workplan_purpose = 'Y' then
      OPEN l_get_working_version_csr(l_structure_id);
      FETCH l_get_working_version_csr INTO l_structure_version_id;
      -- bug fix 2358590: If it does not exist throw an error
      if l_get_working_version_csr%NOTFOUND then
          x_msg_count := x_msg_count + 1;
          x_msg_data.extend(1);
          x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_PS_WP_VERSION_NOT_EXIST');
          x_return_status := 'E';
          raise API_ERROR;
      end if;
      CLOSE l_get_working_version_csr;
    elsif l_financial_purpose = 'Y' then
      OPEN l_get_working_version_csr(l_structure_id);
      FETCH l_get_working_version_csr INTO l_structure_version_id;
      CLOSE l_get_working_version_csr;
    elsif l_workplan_purpose = 'Y' then
--      fnd_message.set_name('PA', 'PA_NO_STRUCTURE_VER_ID');
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
--      fnd_msg_pub.add;
--      x_msg_data(x_msg_count) := fnd_message.get;
      x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_NO_STRUCTURE_VER_ID');
      x_return_status := 'E';
      raise API_ERROR;
    end if;
*/
  else
    l_structure_version_id := p_structure_version_id;
    --HY Get the Structure ID if it's not passed in.
    if (p_structure_id is not null or p_structure_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) then
      l_structure_id := p_structure_id;
    else
      OPEN l_get_struct_id_csr (l_structure_version_id);
      FETCH l_get_struct_id_csr INTO l_structure_id;
      if l_get_struct_id_csr%NOTFOUND then
-- hyau          fnd_message.set_name('PA', 'PA_NO_STRUCTURE_VER_ID');
          x_msg_count := x_msg_count + 1;
          x_msg_data.extend(1);
-- hyau          fnd_msg_pub.add;
-- hyau          x_msg_data(x_msg_count) := fnd_message.get;
          x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_NO_STRUCTURE_VER_ID');
          x_return_status := 'E';
          raise API_ERROR;
      end if;
      CLOSE l_get_struct_id_csr;
    end if;

  end if;

  -- To Set global info like responsibility_id and user_id

  IF (p_responsibility_id is NULL) OR (p_responsibility_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        -- Fix for Bug # 4513291. There was an old fix done thru Bug 2358887, do not put msgs in stack
        -- This was wrong as the calling env. except MSP(I guess) does not look at the x_msg_data array.
        -- Other calling envs. rely on fnd_msg_pub.count_msg, for which we need to add msgs in stack

        IF p_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_XC_PROJECT_PUB.IMPORT_PROJECT', x_Msg => 'p_responsibility_id is not specified', x_Log_Level=> 3);
        END IF;

        x_msg_count := x_msg_count + 1;
        x_msg_data.extend(1);
        x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_FUNCTION_SECURITY_ENFORCED');
        --added for bug 2192242
        fnd_message.set_name('PA', 'PA_FUNCTION_SECURITY_ENFORCED'); -- Fix for Bug # 4513291. Uncommented and moved below.
        fnd_msg_pub.add; -- Fix for Bug # 4513291. Uncommented and moved below.

        --    x_msg_data(x_msg_count) := fnd_message.get;
        x_return_status := 'E';
        raise API_ERROR;
  END IF;

  -- 4363092 MOAC Changes, Added below code to retrieve org_id of the project
  -- and passing it to set_global_info procedure call

  OPEN proj_ou_id_csr;
  FETCH proj_ou_id_csr into l_org_id;
  CLOSE proj_ou_id_csr;

  -- 4363092 end

  PA_INTERFACE_UTILS_PUB.Set_Global_Info
  ( p_api_version_number => G_API_VERSION_NUMBER
   ,p_responsibility_id  => p_responsibility_id
   ,p_user_id            => p_user_id
   ,p_calling_mode       => p_calling_mode     --bug 2783845
   ,p_operating_unit_id  => l_org_id            -- 4363092 MOAC Changes
   ,p_resp_appl_id       => p_resp_appl_id -- 5233777
   ,p_msg_count          => p_msg_count
   ,p_msg_data           => p_msg_data
   ,p_return_status      => l_return_status);
--dbms_output.put_line('set global info: '||l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- 4363092 MOAC Changes, commented below code to call set_client_info procedure
  /*
  --Sakthi
  -- Need to remove after Omkar able to take care this portion of code in Java.
  BEGIN

  select org_id into l_org_id from pa_projects_all where project_id = p_project_id;
  dbms_application_info.set_client_info(l_org_id);

  EXCEPTION
    WHEN OTHERS THEN
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_INVALID_PROJECT_ID');
      --added for bug 2192242
      fnd_message.set_name('PA', 'PA_INVALID_PROJECT_ID');-- Fix for Bug # 4513291. Uncommented and moved below.
      fnd_msg_pub.add; -- Fix for Bug # 4513291. Uncommented and moved below.
      --      x_msg_data(x_msg_count) := fnd_message.get;
      x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_INVALID_PROJECT_ID');
      x_return_status := 'E';
      raise API_ERROR;
  END;
  --Sakthi
  */
  -- 4363092 end
-----------------------
--INIT_CREATE_PROJECT

  --dbms_output.put_line('Calling init project  ');

  if (p_debug_mode = 'Y') then
    pa_debug.debug('Import-Project : Calling init project Program Starts ');
  end if;

  -- pa_project_pub.init_project;

  -- Check project id

  if (p_project_id is null  or p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) then
    fnd_message.set_name('PA', 'PA_NO_PROJECT_ID');
    x_msg_count := x_msg_count + 1;
    x_msg_data.extend(1);
--added for bug 2192242
    fnd_msg_pub.add;
--    x_msg_data(x_msg_count) := fnd_message.get;
    x_msg_data(x_msg_count) := fnd_message.get_string('PA', 'PA_NO_PROJECT_ID');
    x_return_status := 'E';

    raise API_ERROR;
  end if ;

  -- Lock record
/*
  OPEN lock_project_record(p_project_id);
  FETCH lock_project_record into l_dummy;

  if (lock_project_record%NOTFOUND) then
    if (p_debug_mode = 'Y') then
      pa_debug.debug('Update Project Detals : Error PA_XC_NO_DATA_FOUND');
    end if;

    CLOSE lock_project_record;
    fnd_message.set_name('PA', 'PA_XC_NO_DATA_FOUND');
    FND_MESSAGE.Set_token('ENTITY', 'PA_PROJECTS_ALL');
    FND_MESSAGE.Set_token('PROJECT',to_char(p_project_id));
    FND_MESSAGE.Set_token('TASK',NULL);
    x_msg_count := x_msg_count + 1;
    x_msg_data.extend(1);
--added for bug 2192242
    fnd_msg_pub.add;
    x_msg_data(x_msg_count) := fnd_message.get;
    x_return_status := 'E';

    raise API_ERROR;
  end if;
*/

  if p_calling_mode = 'PUBLISH' then

    -- Sync pa_proj_elements with pa_tasks

    -- get the values associated to the project_id

    OPEN l_get_project_csr(p_project_id);
    FETCH l_get_project_csr INTO l_project_name;
    CLOSE l_get_project_csr;

    -- dbms_output.put_line('Getting Load Project here  ');

    l_project_mpx_start_date := fnd_date.canonical_to_date(p_project_mpx_start_date);
    l_project_mpx_end_date   := fnd_date.canonical_to_date(p_project_mpx_end_date);

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : pa_project_pub.load_project Program Starts ');
    end if;

    pa_project_pub.load_project
    ( p_api_version_number   => G_API_VERSION_NUMBER
     ,p_init_msg_list        => 'F'
     ,p_return_status        => l_return_status
     ,p_project_name         => l_project_name
     ,p_pa_project_id        => p_project_id
     ,p_start_date           => l_project_mpx_start_date
     ,p_completion_date      => l_project_mpx_end_date);

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF; -- IF l_return_status

    ------------------------
    --DELETE_TASK  (loop for multiple tasks)
    ------------------------

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : Deleting Task Program Starts ...');
    end if;

    OPEN l_get_temp_task_csr(p_project_id);
    LOOP

      FETCH l_get_temp_task_csr
      INTO  l_task_reference
           ,l_task_id;
      EXIT WHEN l_get_temp_task_csr%NOTFOUND;

      if (p_debug_mode = 'Y') then
        pa_debug.debug('Import-Project : Delete_Task Program Starts ...');
      end if;

      l_msg_count     := x_msg_count;
      l_msg_data      := x_msg_data;
      l_return_status := x_return_status;

      -- Call PA_TASK_UTILS.check_delete_task_ok,  if returns successful
      -- Continue, otherwise terminate.

      PA_PROJECT_CORE.delete_task
      ( x_task_id => l_task_id
--bug 3010538       ,x_validation_mode     => 'R'     -- Bug 2947492
       ,x_err_code   => l_err_code
       ,x_err_stage  => l_err_stage
       ,x_err_stack  => l_err_stack);

      if (l_err_code <> 0) then

           l_return_status := 'E';

    -- Need to add message to the message log.

           if (p_debug_mode = 'Y') then
              pa_debug.debug('Import-Project : Error occured in PA_task_Utils.CHECK_DELETE_TASK_OK Procedure ');
          end if;

        x_return_status := l_return_status;

        --dbms_output.put_line(l_return_status);

        -- Sakthi
        fnd_message.set_name('PA', l_err_stage);
        x_msg_count := x_msg_count + 1;
        x_msg_data.extend(1);
        --added for bug 2192242
        fnd_msg_pub.add;
        x_msg_data(x_msg_count) := fnd_message.get;
        -- Sakthi

        raise API_ERROR;
      end if;

    END LOOP;

    CLOSE l_get_temp_task_csr;

-----------------------
--EXECUTE_UPDATE_PROJECT
-----------------------
    --dbms_output.put_line('Calling Execute Update Project here  ');

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : Execute_Update_Project Program Starts ...');
    end if;

    IF p_calling_mode = 'PUBLISH' THEN
      l_pm_product_code2 := 'WORKPLAN';
    ELSE
      l_pm_product_code2 := l_pm_product_code;
    END IF;

    pa_project_pub.execute_update_project
    ( P_API_VERSION_NUMBER => G_API_VERSION_NUMBER
     ,p_commit             => FND_API.G_FALSE
     ,p_init_msg_list      => FND_API.G_FALSE
     ,p_msg_count          => p_msg_count
     ,p_msg_data           => p_msg_data
     ,p_return_status      => l_return_status
     ,p_workflow_started   => l_workflow_started
     ,p_pm_product_code    => l_pm_product_code2
     ,p_pass_entire_structure => 'Y'  );  -- Added for bug 3696234 : BUg 3627124

    --dbms_output.put_line('AFTER Calling Execute Update Project here  ');
    --dbms_output.put_line(l_return_status);
    --dbms_output.put_line(p_msg_data);

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF; -- IF l_return_status

  --hsiu added for publishing bug
  update PA_TASKS pt
  set pt.parent_task_id =
  (select a.task_id
     from pa_tasks b, pa_temp_import_tasks a
    where a.project_id = p_project_id
    and a.task_reference = b.pm_task_reference -- Bug 3302732: added this
--  Bug 3302732    and to_number(a.task_reference) = to_number(b.pm_task_reference) : Commented this line
      and b.task_id = pt.parent_task_id)
  where pt.project_id = p_project_id;

  --hsiu added for publishing bug
  update PA_TASKS pt
  set pt.top_task_id =
  (select a.task_id
     from pa_tasks b, pa_temp_import_tasks a
    where a.project_id = p_project_id
      and a.task_reference = b.pm_task_reference
      and b.task_id = pt.top_task_id)
  where pt.project_id = p_project_id;

    -- Need to update pa_tasks so that the newly created financial task have the same task_id
    -- as the tasks in pa_proj_elements
    UPDATE PA_TASKS pt
    SET pt.task_id =
    (select task_id
     from PA_TEMP_IMPORT_TASKS temp
     where temp.project_id = p_project_id
     and   temp.task_reference = pt.pm_task_reference)
    WHERE pt.project_id = p_project_id;

  UPDATE PA_PROJ_ELEMENTS e
  set e.pm_source_reference = (
   select PM_TASK_REFERENCE
     from PA_TASKS t
    where t.task_id = e.proj_element_id
  ) where e.project_id = p_project_id;

  end if; -- if p_calling_mode = 'PUBLISH' OR l_sync_import = true then

-----------------------
--Transactions Commit

  if (p_debug_mode = 'Y') then
    pa_debug.debug('Import-Project : Transactions Commit Program Starts ...');
  end if;

  if p_commit = 'Y' then
    commit;
  end if;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('Import-Project : Calling init project Program Starts ...');
  end if;

  pa_project_pub.init_project;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('Import-Project : Program Ends ...');
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_msg_count := fnd_msg_pub.count_msg;
    for i in 1..p_msg_count loop
      --dbms_output.put_line('INSIDE THE ERROR HANDLING PORTION  ');

      if (p_debug_mode = 'Y') then
        pa_debug.debug('Import-Project : Inside Error Handling Program ...');
      end if;

      -- Fix for Bug # 4513291. Ideally this call should use p_encoded as F
      -- So that it gets decoded messages. But not changing Right now.
      PA_INTERFACE_UTILS_PUB.get_messages (
       p_msg_count           => 1
      ,p_msg_index           => i
      ,p_msg_data            => p_msg_data
      ,p_data                => l_data
      ,p_msg_index_out       => l_msg_index_out);

      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := l_data;

    end loop;

    x_return_status := FND_API.G_RET_STS_ERROR ;

--hsiu added
    IF (p_calling_mode <> 'PUBLISH') THEN
    pa_project_pub.clear_project;
--hsiu added
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --dbms_output.put_line('UNHANDLED Exception Error Handling ');

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : Unhandled Expection  ...');
    end if;

    p_msg_count := fnd_msg_pub.count_msg;
    for i in 1..p_msg_count loop

      if (p_debug_mode = 'Y') then
        pa_debug.debug('Import-Project : Inside Error Handling Program ...');
      end if;

      PA_INTERFACE_UTILS_PUB.get_messages (
       p_msg_count           => 1
      ,p_msg_index           => i
      ,p_msg_data            => p_msg_data
      ,p_data                => l_data
      ,p_msg_index_out       => l_msg_index_out);

      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := l_data;

    end loop;

    x_return_status := FND_API.G_RET_STS_ERROR;
--hsiu added
    IF (p_calling_mode <> 'PUBLISH') THEN
    pa_project_pub.clear_project;
--hsiu added
    END IF;

  WHEN API_ERROR THEN

    IF (p_calling_mode <> 'PUBLISH') THEN
     pa_project_pub.clear_project;
    END IF;
  WHEN NO_DATA_FOUND THEN
    -- dbms_output.put_line('NO-DATA-FOUND : YOU ARE IN MAIN PROCEDURE ');

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : Inside No Data Found Exception  ...');
    end if;

    fnd_message.set_name('PA', 'PA_XC_NO_DATA_FOUND');
    x_msg_count := x_msg_count + 1;
    x_msg_data.extend(1);
--added for bug 2192242
    fnd_msg_pub.add;
    x_msg_data(x_msg_count) := fnd_message.get;
    x_return_status := 'E';

  WHEN ROW_ALREADY_LOCKED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    if (p_debug_mode = 'Y') then
      pa_debug.debug('Import-Project : Inside Row Already Locked Exception  ...');
    end if;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
      FND_MESSAGE.Set_token('ENTITY', 'PA_PROJECTS_ALL');
      FND_MESSAGE.Set_token('PROJECT',to_char(P_PROJECT_ID));
      FND_MESSAGE.Set_token('TASK',NULL);
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
--added for bug 2192242
      fnd_msg_pub.add;
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
    END IF;

  WHEN OTHERS THEN
    if (p_debug_mode = 'Y') then
     pa_debug.debug('Import-Project : Inside Other Exception  ...');
    end if;

    l_text := SQLCODE||SUBSTRB(SQLERRM,1,1000); -- 4537865 : Changed substr to substrb
    x_msg_count := x_msg_count + 1;
    x_msg_data.extend(1);
    x_msg_data(x_msg_count) := l_text;
    x_return_status := 'U';

END Import_project;

--Name:               fetch_task_id
--Type:               Procedure
--Description:        This procedure can be used to get the task_id from database
--                    for correspondening task reference.
--
--Called subprograms:
--

PROCEDURE fetch_task_id
( p_task_index             IN    VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3302732 : Changed type to varchar2
 ,p_project_id             IN    NUMBER
 ,p_pm_task_reference      IN    VARCHAR2
 ,x_task_id           OUT    NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

   l_task_id              NUMBER := 0;
   l_task_reference       NUMBER := 0;

--needed to get the field values associated to a particular Task_reference

   CURSOR   l_get_task_csr (c_project_id   NUMBER, c_pm_task_reference VARCHAR2)
   IS
   SELECT   task_id
   FROM     pa_tasks
   WHERE    project_id = c_project_id
   AND      pm_task_reference = c_pm_task_reference;

BEGIN

    OPEN  l_get_task_csr(p_project_id, p_pm_task_reference);
    FETCH l_get_task_csr INTO l_task_id;

    IF l_get_task_csr%NOTFOUND
    THEN

      CLOSE l_get_task_csr;
--hy      PA_PROJECT_PUB.G_tasks_in_tbl(to_number(p_pm_task_reference)).pa_task_id := NULL;
      x_task_id :=NULL;
      return;
    END IF;

    CLOSE l_get_task_csr;

--hy    PA_PROJECT_PUB.G_tasks_in_tbl(to_number(p_pm_task_reference)).pa_task_id := l_task_id;

    x_task_id := l_task_id;

EXCEPTION --4537865
WHEN OTHERS THEN
    x_task_id := NULL;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_XC_PROJECT_PUB'
                ,p_procedure_name => 'fetch_task_id'
                ,p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
END fetch_task_id;


--------------------------------------------------------------------------------
--Name:               fetch_proj_element_id
--Type:               Procedure
--Description:        This procedure can be used to get the proj_elememt_id from database
--                    for correspondening task reference.
--
--Called subprograms:
--

PROCEDURE fetch_proj_element_id
( p_task_index             IN    VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR -- Bug 3302732
 ,p_project_id             IN    NUMBER
 ,p_pm_task_reference      IN    VARCHAR2
 ,x_task_id           OUT    NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

   l_task_id              NUMBER := 0;
   l_task_reference       NUMBER := 0;

--needed to get the field values associated to a particular Task_reference

   CURSOR   l_get_task_csr (c_project_id   NUMBER, c_pm_task_reference VARCHAR2)
   IS
   SELECT   proj_element_id
   FROM     pa_proj_elements
   WHERE    project_id = c_project_id
   AND      pm_source_reference = c_pm_task_reference;

BEGIN

--dbms_output.put_line(p_pm_task_reference);

    OPEN  l_get_task_csr(p_project_id, p_pm_task_reference);
    FETCH l_get_task_csr INTO l_task_id;

    IF l_get_task_csr%NOTFOUND
    THEN
      CLOSE l_get_task_csr;
--hy      PA_PROJECT_PUB.G_tasks_in_tbl(to_number(p_pm_task_reference)).pa_task_id := NULL;
      x_task_id :=NULL;
      return;
    END IF;

    CLOSE l_get_task_csr;

--hy    PA_PROJECT_PUB.G_tasks_in_tbl(to_number(p_pm_task_reference)).pa_task_id := l_task_id;

    x_task_id := l_task_id;

EXCEPTION --4537865
WHEN OTHERS THEN
        x_task_id := NULL;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_XC_PROJECT_PUB'
                                ,p_procedure_name => 'fetch_proj_element_id'
                                ,p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END fetch_proj_element_id;

--
--  FUNCTION
--              is_number
--
--History:
--       13-DEC-2000  - anlee     Created.
--
FUNCTION is_number(value_in IN VARCHAR2) RETURN BOOLEAN
IS
  val           NUMBER;

BEGIN
  val := TO_NUMBER(value_in);
  return TRUE;
EXCEPTION
  WHEN OTHERS THEN
    return FALSE;
END is_number;


-- Bug 3302732: Added this function. This generates task reference for the passed in
--              project and proj_element_id

FUNCTION generate_new_task_reference(p_project_id in NUMBER, p_proj_element_id IN NUMBER)
RETURN VARCHAR2
IS

l_new_task_reference VARCHAR2(25);
is_unique VARCHAR2(1);
i number := 0;

BEGIN
l_new_task_reference := TO_CHAR(p_proj_element_id);

LOOP
i := i + 1;
is_unique := check_ref_unique(p_project_id, l_new_task_reference) ;
if is_unique = 'N' then
   l_new_task_reference := TO_CHAR(p_proj_element_id)||'_'||to_char(i);
else
   exit;
end if;

END LOOP;

RETURN l_new_task_reference;

END generate_new_task_reference;


-- Bug 3302732: Added this new function. This checks if the passed in task reference is
--              unique in context to a project.

FUNCTION check_ref_unique(p_project_id in NUMBER, p_new_task_reference IN VARCHAR2
                          )
RETURN VARCHAR2
IS
l_unique VARCHAR2(1) :='Y';
l_count  NUMBER := 0 ; --Bug 7615805

BEGIN
/* Bug 7615805
select 'N' into l_unique
from pa_proj_elements
where project_id = p_project_id
and pm_source_reference = p_new_task_reference
AND parent_structure_id = ( SELECT ppe.proj_element_id   --Added this subQry for bug# 3601700
                                FROM   pa_proj_elements ppe,
                                       pa_proj_structure_types ppst,
                                       pa_structure_types pst
                                WHERE  ppe.proj_element_id = ppst.proj_element_id
                                AND    ppe.project_id = p_project_id
                                AND    ppst.structure_type_id = pst.structure_type_id
                                AND    pst.structure_type = 'WORKPLAN' --specified as workplan as this will only called while publishing workplan strcuture
              )
AND OBJECT_TYPE = 'PA_TASKS'; */
-- and rownum = 1; --Commented for Bug 3601700

---------------------------------------------------------------
-- The above query is commented out as it can throw
-- ORA-01422: exact fetch returns more than requested number of rows
-- If the PA_PROJ_ELEMENTS is having multiple records for
-- same PM_SOURCE_REFERENCE or same PARENT_STRUCTURE_ID
---------------------------------------------------------------
		-- Bug # 7615805
		SELECT COUNT(*)
		INTO L_COUNT
		FROM PA_PROJ_ELEMENTS
		WHERE PROJECT_ID = P_PROJECT_ID
		AND PM_SOURCE_REFERENCE = P_NEW_TASK_REFERENCE
		AND PARENT_STRUCTURE_ID = ( SELECT PPE.PROJ_ELEMENT_ID
		                             FROM  PA_PROJ_ELEMENTS PPE,
		                                   PA_PROJ_STRUCTURE_TYPES PPST,
		                                   PA_STRUCTURE_TYPES PST
		                             WHERE PPE.PROJ_ELEMENT_ID = PPST.PROJ_ELEMENT_ID
		                               AND PPE.PROJECT_ID = P_PROJECT_ID
		                               AND PPST.STRUCTURE_TYPE_ID = PST.STRUCTURE_TYPE_ID
		                               AND PST.STRUCTURE_TYPE = 'WORKPLAN'
		                          )
		AND OBJECT_TYPE = 'PA_TASKS' ;

		IF ( L_COUNT > 0 ) THEN
			l_unique := 'N' ;
		END IF;

		return l_unique;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RETURN l_unique;

END check_ref_unique;

--------------------------------------------------------------------------------

end PA_XC_PROJECT_PUB;

/
