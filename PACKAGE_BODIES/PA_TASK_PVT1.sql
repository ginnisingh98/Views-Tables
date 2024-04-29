--------------------------------------------------------
--  DDL for Package Body PA_TASK_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_PVT1" AS
/* $Header: PATSK1VB.pls 120.8.12010000.10 2009/07/21 14:31:40 anuragar ship $ */

-- API name                      : Create_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_type          IN    VARCHAR2    N   Not Null
-- p_project_id       IN    NUMBER  N   Not Null
-- p_task_number          IN    VARCHAR2    N   Not Null
-- p_task_name        IN    VARCHAR2    N   Not Null
-- p_task_description   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city               IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_priority_code  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code    IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_task_id          OUT   NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_object_type        IN    VARCHAR2,
 p_project_id         IN    NUMBER,
 p_structure_id         IN    NUMBER,
 p_structure_version_id IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_number        IN    VARCHAR2,
 p_task_name          IN    VARCHAR2,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :='PEER',
 p_task_description IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id        IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country              IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code         IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region           IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city             IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_priority_code          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID            IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code        IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code  IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date        IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_start_date IN    DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_finish_date IN   DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_link_task_flag        IN   VARCHAR2 := 'N',
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code              IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_parent_structure_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 -- xxlu added task DFF attributes
 p_tk_attribute_category     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
  --FP M development bug 330119
   p_structure_type      IN      VARCHAR2 := 'WORKPLAN',
   p_financial_flag      IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes bug 330119
 p_Base_Perc_Comp_Deriv_Code     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  -- This param added for FP_M changes 3305199
-- Bug#3491609 : Workflow Chanegs FP M
 p_wf_item_type          IN    pa_proj_elements.wf_item_type%TYPE       :=NULL,
 p_wf_process            IN    pa_proj_elements.wf_process%TYPE         :=NULL,
 p_wf_lead_days          IN    pa_proj_elements.wf_start_lead_days%TYPE :=NULL,
 p_wf_enabled_flag       IN    pa_proj_elements.enable_wf_flag%TYPE     :=NULL,
 -- Bug#3491609 : Workflow Chanegs FP M
 x_task_id            IN OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);
   l_return_status                 VARCHAR2(1);
    l_error_message_code           VARCHAR2(250);

    l_carrying_out_org_id          NUMBER;

    l_task_description             PA_PROJ_ELEMENTS.description%TYPE;
    l_location_id                    NUMBER;
    --l_country
    --l_territory_code
    --l_state_region
    --l_city
    l_task_manager_id              NUMBER;
    l_priority_code            PA_PROJ_ELEMENTS.priority_code%TYPE;
    l_TYPE_ID                    PA_PROJ_ELEMENTS.TYPE_ID  %TYPE;
    l_status_code                    PA_PROJ_ELEMENTS.status_code%TYPE;
    l_inc_proj_progress_flag         PA_PROJ_ELEMENTS.inc_proj_progress_flag%TYPE;
    l_pm_product_code              VARCHAR2(30); --PA_PROJ_ELEMENTS.pm_product_code%TYPE;
    l_pm_task_reference            VARCHAR2(30); --PA_PROJ_ELEMENTS.pm_task_reference%TYPE;
    l_closed_date                    PA_PROJ_ELEMENTS.closed_date%TYPE;
    --l_scheduled_start_date
    --l_scheduled_finish_date
    l_attribute_category         PA_PROJ_ELEMENTS.attribute_category%TYPE;
    l_attribute1                     PA_PROJ_ELEMENTS.attribute1%TYPE;
    l_attribute2                     PA_PROJ_ELEMENTS.attribute2%TYPE;
    l_attribute3                     PA_PROJ_ELEMENTS.attribute3%TYPE;
    l_attribute4                     PA_PROJ_ELEMENTS.attribute4%TYPE;
    l_attribute5                     PA_PROJ_ELEMENTS.attribute5%TYPE;
    l_attribute6                     PA_PROJ_ELEMENTS.attribute6%TYPE;
    l_attribute7                     PA_PROJ_ELEMENTS.attribute7%TYPE;
    l_attribute8                     PA_PROJ_ELEMENTS.attribute8%TYPE;
    l_attribute9                     PA_PROJ_ELEMENTS.attribute9%TYPE;
    l_attribute10                    PA_PROJ_ELEMENTS.attribute10%TYPE;
    l_attribute11                    PA_PROJ_ELEMENTS.attribute11%TYPE;
    l_attribute12                    PA_PROJ_ELEMENTS.attribute12%TYPE;
    l_attribute13                    PA_PROJ_ELEMENTS.attribute13%TYPE;
    l_attribute14                    PA_PROJ_ELEMENTS.attribute14%TYPE;
    l_attribute15                    PA_PROJ_ELEMENTS.attribute15%TYPE;
    l_phase_version_id                   PA_PROJ_ELEMENTS.phase_version_id%TYPE;
    l_phase_code                         PA_PROJ_ELEMENTS.phase_code%TYPE;
--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
    l_full_shared  VARCHAR2(30) := '';

--end changes

    X_ROW_ID                       VARCHAR2(255);

    -- xxlu added task DFF attributes
    l_tk_attribute_category          pa_tasks.attribute_category%TYPE;
    l_tk_attribute1                  pa_tasks.attribute1%TYPE;
    l_tk_attribute2                  pa_tasks.attribute2%TYPE;
    l_tk_attribute3                  pa_tasks.attribute3%TYPE;
    l_tk_attribute4                  pa_tasks.attribute4%TYPE;
    l_tk_attribute5                  pa_tasks.attribute5%TYPE;
    l_tk_attribute6                  pa_tasks.attribute6%TYPE;
    l_tk_attribute7                  pa_tasks.attribute7%TYPE;
    l_tk_attribute8                  pa_tasks.attribute8%TYPE;
    l_tk_attribute9                  pa_tasks.attribute9%TYPE;
    l_tk_attribute10                   pa_tasks.attribute10%TYPE;
    -- end xxlu changes

     -- Bug#3491609 : Workflow Chanegs FP M
l_wf_item_type    pa_proj_elements.wf_item_type%TYPE;
l_wf_process      pa_proj_elements.wf_process%TYPE;
l_wf_lead_days    pa_proj_elements.wf_start_lead_days%TYPE;
l_wf_enabled_flag pa_proj_elements.enable_wf_flag%TYPE;
 -- Bug#3491609 : Workflow Chanegs FP M

 --Modified pa_tasks to  pa_proj_elements in the following local variables Bug 3809523
 l_task_number    pa_proj_elements.element_number%TYPE := p_task_number; --ADDED FOR BUG 3705333
 la_task_name      pa_proj_elements.name%TYPE  := p_task_name; --ADDED FOR BUG 3705333

    cursor get_page_name(c_page_id NUMBER)
    IS
      SELECT page_name
        from pa_page_layouts
       where page_id = c_page_id
         and page_type_code = 'AI';
    l_page_name    pa_page_layouts.page_name%TYPE;

    CURSOR cur_projs
    IS
      SELECT carrying_out_organization_id
        FROM pa_projects_all
       WHERE project_id = p_project_id;

    CURSOR cur_struc_type
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = p_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

--HSIU
--fixed status code error
-- Bug 2827063 Tuned the following cursor to use exists
    CURSOR cur_pub_versions is
      select 'Y' from dual
      where EXISTS
       ( select 'xyz'
         from pa_proj_elem_ver_structure
         where proj_element_id = p_structure_id
         AND project_id = p_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED');

/* Bug 2623999 Added the following cursor. This cusror will be used if p_structure_version_id
              is not null. Otherwise the  cur_pub_versions will be used*/

    --bug 3074706
    --need to include project_id to use index
    CURSOR cur_pub_versions2 is
      select 'Y'
        from pa_proj_elem_ver_structure
       where element_version_id = p_structure_version_id
         and project_id = p_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';
    --end bug 3074706

-- should be checking for tasks in pa_proj_elements table.

    /*4156271 : Performance Fix - Commented the following Query for Performance reasons
    CURSOR cur_chk_pa_tasks
    IS
      SELECT 'x'
        FROM pa_tasks pt, pa_proj_elements ppe
       WHERE pt.project_id = p_project_id
         AND pt.task_id    = ppe.proj_element_id
         AND ppe.link_task_flag = 'N';
   */
   /* 4156271 : Same  Cursor cur_chk_pa_tasks with better performance follows */
   CURSOR cur_chk_pa_tasks
    IS
      SELECT 'x'
        FROM pa_tasks pt
       WHERE pt.project_id = p_project_id
         AND EXISTS(SELECT 1
                      FROM PA_PROJ_ELEMENTS ppe
                     WHERE ppe.link_task_flag = 'N'
                       AND ppe.project_id = p_project_id
                   );
   /*End : Fix for 4156271 */

    CURSOR cur_chk_ref_task
    IS
      SELECT 'x'
        FROM pa_proj_element_versions
       WHERE object_type = 'PA_STRUCTURES'
         AND element_version_id = p_ref_task_id;   --Just making sure ref_task_id does not contain
                                                   --structure version id.

    CURSOR cur_ref_loc_id
    IS
      SELECT location_id from pa_proj_elements where proj_element_id = p_ref_task_id;

l_publised_version  VARCHAR2(1);
l_dummy_char        VARCHAR2(1);
l_dummy_char2       VARCHAR2(1);
l_wbs_record_version_number NUMBER;
l_link_task_flag    VARCHAR2(1);

    CURSOR get_task_types_attr(c_task_type_id NUMBER) IS
      select WORK_ITEM_CODE, UOM_CODE,
             ACTUAL_WQ_ENTRY_CODE, TASK_PROGRESS_ENTRY_PAGE_ID,
             INITIAL_STATUS_CODE, BASE_PERCENT_COMP_DERIV_CODE,
             wf_item_type,wf_process,wf_start_lead_days
        from pa_task_types
       where task_type_id = c_task_type_id;
--l_task_weighting_deriv_code PA_PROJ_ELEMENTS.task_weighting_deriv_code%TYPE;
l_work_item_code PA_PROJ_ELEMENTS.wq_item_code%TYPE;
l_uom_code PA_PROJ_ELEMENTS.wq_uom_code%TYPE;
l_wq_actual_entry_code PA_PROJ_ELEMENTS.wq_actual_entry_code%TYPE;
l_task_progress_entry_page_id PA_PROJ_ELEMENTS.task_progress_entry_page_id%TYPE;
l_INITIAL_STATUS_CODE PA_PROJ_ELEMENTS.STATUS_CODE%TYPE;

--Bug 2947492

--Bug 3305199: commented out for M
--l_plannable_tasks_tbl        PA_FP_ELEMENTS_PUB.l_impacted_task_in_tbl_typ;
l_parent_task_id             NUMBER;
l_top_task_id                NUMBER;

CURSOR get_parent_task_id( c_task_id NUMBER ) IS
    SELECT parent_task_id, top_task_id FROM pa_tasks
     WHERE project_id = p_project_id and task_id = c_task_id;

--End Bug 2947492
--bug 3305199
l_Base_Perc_Comp_Deriv_Code VARCHAR2(30);

--Bug 3705333
CURSOR get_task_name_or_number(c_project_id NUMBER,c_task_id NUMBER )
    IS
      SELECT task_name, task_number
        FROM pa_tasks
        WHERE project_id = c_project_id
        AND task_id = c_task_id;
--end bug 3705333

l_task_trn_start_date    DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
l_task_trn_end_date      DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
--Changes for 8566495 anuragag
l_old_link_task_flag     VARCHAR2(1) := 'N';
l_task_status             VARCHAR2(20) := NULL;
BEGIN

--dbms_output.put_line(( 'Inside CREATE_TASK private API' );

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PVT1.CREATE_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_TASK_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF p_object_type <> 'PA_TASKS'
    THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NOT_TASK_OBJECT');
      l_msg_data := 'PA_PS_NOT_TASK_OBJECT';
    END IF;

--hsiu: bug 2669388
--dbms_output.put_line('task number');

 /* Added for Bug 3705333*/
If ((p_task_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
    (p_task_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
    THEN
          OPEN get_task_name_or_number( p_project_id,x_task_id );
          FETCH get_task_name_or_number INTO la_task_name,l_task_number;
          CLOSE  get_task_name_or_number;
END IF;
/* changes end for bug 3705333*/

      IF p_task_number IS NULL
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NUMBER_NULL');
          raise FND_API.G_EXC_ERROR;
      END IF;

--dbms_output.put_line('task name');
      IF p_task_name IS NULL
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NAME_NULL');
          raise FND_API.G_EXC_ERROR;
      END IF;

--Bug 2168170
--dbms_output.put_line('Inside private API');
--dbms_output.put_line( 'Check if the task name is unique within the project.'||l_task_number);
      IF PA_PROJ_ELEMENTS_UTILS.Check_element_number_Unique
             (
               p_element_number  => l_task_number    --Bug 3705333 Changed from p_task_number to l_task_number
              ,p_element_id      => null
              ,p_project_id      => p_project_id
              ,p_structure_id    => p_parent_structure_id
              ,p_object_type     => 'PA_TASKS'
             ) = 'N'
      THEN
        IF p_pm_product_code = 'MSPROJECT'
        THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_PS_TASK_NOT_NUM_UNIQ_MSP'  -- Bug 6497559
                              ,p_token1 => 'TASK_NAME'
                              ,p_value1 => la_task_name
                              ,p_token2 => 'TASK_NUMBER'
                              ,p_value2 => l_task_number
                              );
          raise FND_API.G_EXC_ERROR;
        ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_PS_TASK_NOT_NUM_UNIQ_AMG'  -- Bug 6497559
                              ,p_token1 => 'TASK_ID'
                              ,p_value1 => x_task_id
                              );
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
--end bug 2669388
--dbms_output.put_line( 'After Check if the task name is unique within the project.' );

    --Check if the task name is unique within the project
    If (PA_PROJ_ELEMENTS_UTILS.check_element_number_unique(l_task_number, --Bug 3705333 Changed from p_task_number to l_task_number
                                                           NULL,
                                                           p_project_id,
                                                           p_structure_id) <> 'Y') THEN
      --Name is not unique
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NUMBER_UNIQUE');
      l_msg_data := 'PA_PS_TASK_NUMBER_UNIQUE';
       /* bug 3459905    Check if there is any error. */
  l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    /*  end of 3458052*/
    END IF;

   /* bug 3459905    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      end of 3458052*/
   END IF;

    IF ( p_task_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_task_description IS NOT NULL )
    THEN
        l_task_description := null;
    ELSE
        l_task_description := p_task_description;
    END IF;

    IF ( p_PM_PRODUCT_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_PM_PRODUCT_CODE IS NOT NULL )
    THEN
        l_PM_PRODUCT_CODE := null;
    ELSE
        l_PM_PRODUCT_CODE := p_PM_PRODUCT_CODE;
    END IF;

    IF ( p_PM_TASK_REFERENCE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_PM_TASK_REFERENCE IS NOT NULL )
    THEN
        l_PM_TASK_REFERENCE := null;
    ELSE
        l_PM_TASK_REFERENCE := p_PM_TASK_REFERENCE;
    END IF;

    IF ( p_location_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_location_id IS NOT NULL )
    THEN
       l_location_id := null;
       OPEN cur_ref_loc_id;
       FETCH cur_ref_loc_id INTO l_location_id;
       CLOSE cur_ref_loc_id;
    ELSE
       l_location_id := p_location_id;
    END IF;

    /*IF ( p_country = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_country IS NOT NULL )
    THEN
       l_country := null;
    ELSE
       l_country := p_country;
    END IF;

    IF ( p_territory_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_territory_code IS NOT NULL )
    THEN
        l_territory_code := null;
    ELSE
        l_territory_code := p_territory_code;
    END IF;*/

    IF ( p_task_manager_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_manager_id IS NOT NULL )
    THEN
       l_task_manager_id := null;
    ELSE
       l_task_manager_id := p_task_manager_id;
    END IF;

    /*IF ( p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_carrying_out_org_id IS NOT NULL )
    THEN
       l_carrying_out_org_id := null;
    ELSE
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF; */

    IF ( ( p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) OR ( p_carrying_out_org_id IS NULL ) )
    THEN
       OPEN cur_projs;
       FETCH cur_projs INTO l_carrying_out_org_id;
       CLOSE cur_projs;
    ELSE
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF;

    IF ( p_priority_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_priority_code IS NOT NULL )
    THEN
       l_priority_code := NULL;
    ELSE
       l_priority_code := p_priority_code;
    END IF;

    IF ( p_TYPE_ID   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR  p_TYPE_ID   IS NULL )
    THEN
       --IF (p_TYPE_ID   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_object_type = 'PA_TASKS') THEN
       IF (p_object_type = 'PA_TASKS') THEN
         l_TYPE_ID   := PA_PROJ_ELEMENTS_UTILS.GET_DEFAULT_TASK_TYPE_ID;
       ELSE
         l_TYPE_ID   := NULL;
       END IF;
    ELSE
       l_TYPE_ID   := p_TYPE_ID  ;
    END IF;

    IF ( p_inc_proj_progress_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_inc_proj_progress_flag IS NOT NULL )
    THEN
       l_inc_proj_progress_flag := Null;
    ELSE
       l_inc_proj_progress_flag := p_inc_proj_progress_flag;
    END IF;

    IF ( p_closed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_closed_date IS NOT NULL )
    THEN
       l_closed_date := NULL;
    ELSE
       l_closed_date := p_closed_date;
    END IF;

    /*IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_start_date IS NOT NULL )
    THEN
       l_scheduled_start_date := NULL;
    ELSE
       l_scheduled_start_date := p_scheduled_start_date;
    END IF;

    IF ( p_scheduled_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_finish_date IS NOT NULL )
    THEN
       l_scheduled_finish_date := Null;
    ELSE
       l_scheduled_finish_date := p_scheduled_finish_date;
    END IF;*/

    IF ( p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL )
    THEN
       l_attribute_category := NULL;
    ELSE
       l_attribute_category := p_attribute_category;
    END IF;

    IF ( p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL )
    THEN
       l_attribute1 := null;
    ELSE
       l_attribute1 := p_attribute1;
    END IF;

    IF ( p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL )
    THEN
       l_attribute2 := null;
    ELSE
       l_attribute2 := p_attribute2;
    END IF;

    IF ( p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL )
    THEN
       l_attribute3 := null;
    ELSE
       l_attribute3 := p_attribute3;
    END IF;

    IF ( p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL )
    THEN
       l_attribute4 := null;
    ELSE
       l_attribute4 := p_attribute4;
    END IF;

    IF ( p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL )
    THEN
       l_attribute5 := null;
    ELSE
       l_attribute5 := p_attribute5;
    END IF;

    IF ( p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL )
    THEN
       l_attribute6 := null;
    ELSE
       l_attribute6 := p_attribute6;
    END IF;

    IF ( p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL )
    THEN
       l_attribute7 := null;
    ELSE
       l_attribute7 := p_attribute7;
    END IF;

    IF ( p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL )
    THEN
       l_attribute8 := null;
    ELSE
       l_attribute8 := p_attribute8;
    END IF;

    IF ( p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL )
    THEN
       l_attribute9 := null;
    ELSE
       l_attribute9 := p_attribute9;
    END IF;

    IF ( p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL )
    THEN
       l_attribute10 := null;
    ELSE
       l_attribute10 := p_attribute10;
    END IF;

    IF ( p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL )
    THEN
       l_attribute11 := null;
    ELSE
       l_attribute11 := p_attribute11;
    END IF;

    IF ( p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL )
    THEN
       l_attribute12 := null;
    ELSE
       l_attribute12 := p_attribute12;
    END IF;

    IF ( p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL )
    THEN
       l_attribute13 := null;
    ELSE
       l_attribute13 := p_attribute13;
    END IF;

    IF ( p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL )
    THEN
       l_attribute14 := null;
    ELSE
       l_attribute14 := p_attribute14;
    END IF;

    IF ( p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL )
    THEN
       l_attribute15 := null;
    ELSE
       l_attribute15 := p_attribute15;
    END IF;

    IF ( p_link_task_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_link_task_flag IS NOT NULL )
    THEN
       l_link_task_flag := 'N';
    ELSE
       l_link_task_flag := p_link_task_flag;
    END IF;

    IF (p_phase_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_phase_version_id IS NOT NULL)
    THEN
       l_phase_version_id := NULL;
    ELSE
       l_phase_version_id := p_phase_version_id;
    END IF;

    IF (p_phase_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_phase_code IS NOT NULL)
    THEN
       l_phase_code := NULL;
    ELSE
       l_phase_code := p_phase_code;
    END IF;

    -- xxlu added task DFF attributes
    IF ( p_tk_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute_category IS NOT NULL )
    THEN
       l_tk_attribute_category := NULL;
    ELSE
       l_tk_attribute_category := p_tk_attribute_category;
    END IF;

    IF ( p_tk_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute1 IS NOT NULL )
    THEN
       l_tk_attribute1 := null;
    ELSE
       l_tk_attribute1 := p_tk_attribute1;
    END IF;

    IF ( p_tk_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute2 IS NOT NULL )
    THEN
       l_tk_attribute2 := null;
    ELSE
       l_tk_attribute2 := p_tk_attribute2;
    END IF;

    IF ( p_tk_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute3 IS NOT NULL )
    THEN
       l_tk_attribute3 := null;
    ELSE
       l_tk_attribute3 := p_tk_attribute3;
    END IF;

    IF ( p_tk_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute4 IS NOT NULL )
    THEN
       l_tk_attribute4 := null;
    ELSE
       l_tk_attribute4 := p_tk_attribute4;
    END IF;

    IF ( p_tk_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute5 IS NOT NULL )
    THEN
       l_tk_attribute5 := null;
    ELSE
       l_tk_attribute5 := p_tk_attribute5;
    END IF;

    IF ( p_tk_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute6 IS NOT NULL )
    THEN
       l_tk_attribute6 := null;
    ELSE
       l_tk_attribute6 := p_tk_attribute6;
    END IF;

    IF ( p_tk_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute7 IS NOT NULL )
    THEN
       l_tk_attribute7 := null;
    ELSE
       l_tk_attribute7 := p_tk_attribute7;
    END IF;

    IF ( p_tk_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute8 IS NOT NULL )
    THEN
       l_tk_attribute8 := null;
    ELSE
       l_tk_attribute8 := p_tk_attribute8;
    END IF;

    IF ( p_tk_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute9 IS NOT NULL )
    THEN
       l_tk_attribute9 := null;
    ELSE
       l_tk_attribute9 := p_tk_attribute9;
    END IF;

    IF ( p_tk_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_tk_attribute10 IS NOT NULL )
    THEN
       l_tk_attribute10 := null;
    ELSE
       l_tk_attribute10 := p_attribute10;
    END IF;
    -- end xxlu changes

    --fetch task_types attributes
    OPEN get_task_types_attr(l_TYPE_ID  );
    FETCH get_task_types_attr into l_work_item_code,
                                   l_uom_code,
                                   l_wq_actual_entry_code,
                                   l_task_progress_entry_page_id,
                                   l_INITIAL_STATUS_CODE,
                                   l_Base_Perc_Comp_Deriv_Code,
                                   l_wf_item_type,
                                   l_wf_process,
                                   l_wf_lead_days  ;
    IF get_task_types_attr%NOTFOUND THEN
--      l_task_weighting_deriv_code := NULL;
      l_work_item_code := NULL;
      l_uom_code := NULL;
      l_wq_actual_entry_code := NULL;
      l_task_progress_entry_page_id := NULL;
      l_page_name := NULL;
      l_Base_Perc_Comp_Deriv_Code := NULL;
      l_wf_item_type  := NULL;
      l_wf_process := NULL;
      l_wf_lead_days   := NULL;
    END IF;
    CLOSE get_task_types_attr;
--
--
--bug 2789483
    l_publised_version := 'N';
    OPEN cur_pub_versions;
    FETCH cur_pub_versions INTO l_publised_version;
    CLOSE cur_pub_versions;
--bug 2789483

    --IF ( p_STATUS_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_STATUS_CODE IS NOT NULL )
    IF ( p_STATUS_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_STATUS_CODE IS NULL )   --bug 2734719
       OR l_publised_version = 'N'   --bug 2789483
    THEN
        l_STATUS_CODE := l_INITIAL_STATUS_CODE;
    ELSE
        l_STATUS_CODE := p_STATUS_CODE;
    END IF;


    --bug 3305199
    IF (p_Base_Perc_Comp_Deriv_Code IS NULL OR p_Base_Perc_Comp_Deriv_Code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      NULL;
    ELSE
      l_Base_Perc_Comp_Deriv_Code := p_Base_Perc_Comp_Deriv_Code;
    END IF;
    --end bug 3305199

/*
    IF (p_task_weighting_deriv_code IS NOT NULL AND p_task_weighting_deriv_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_task_weighting_deriv_code := p_task_weighting_deriv_code;
    END IF;

*/

    IF (p_work_item_code IS NOT NULL AND p_work_item_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_work_item_code := p_work_item_code;
    END IF;

    IF (p_uom_code IS NOT NULL and p_uom_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_uom_code := p_uom_code;
    END IF;

    IF (p_wq_actual_entry_code IS NOT NULL and p_wq_actual_entry_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_wq_actual_entry_code := p_wq_actual_entry_code;
    END IF;

    IF (p_task_progress_entry_page_id IS NOT NULL AND p_task_progress_entry_page_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_task_progress_entry_page_id := p_task_progress_entry_page_id;
      l_page_name := p_task_progress_entry_page;
    END IF;

--dbms_output.put_line( 'Before inser_row API' ||p_project_id  );
--dbms_output.put_line( 'p_task_man_id ' ||p_task_MANAGER_ID );
--dbms_output.put_line( 'l_task_man_id ' ||l_task_MANAGER_ID );

      -- 3491609 : FP M : Tracking bug : Workflow Excecution

      --This is required as during copy project the WF attributes
      --needs to be copied from source task and during simple task
      --creation it should be copied from task type which is already
      --stored in the local variable. In case during copy task WF
      --attributes are passed as null , in the target it will be
      --populated from task type .

      l_wf_item_type  := nvl(p_wf_item_type,l_wf_item_type);
      l_wf_process    := nvl(p_wf_process,l_wf_process);
      l_wf_lead_days  := nvl(p_wf_lead_days,l_wf_lead_days);
      -- 3491609 : FP M : Tracking bug : Workflow Excecution
--Changes for 8566495 anuragag
--Setting the link_task_flag to Y for creation in pa_proj_elements
l_old_link_task_flag := l_link_task_flag;
if(PA_TASK_PVT1.G_CHG_DOC_CNTXT = 1)
then
l_link_task_flag := 'Y';
l_task_status := 'NEW';
end if;
--end of changes 8566495
    PA_PROJ_ELEMENTS_PKG.Insert_Row(
                 X_ROW_ID                             => X_ROW_ID
                ,X_PROJ_ELEMENT_ID                    => x_task_id
                ,X_PROJECT_ID                           => p_project_id
                ,X_OBJECT_TYPE                    => p_OBJECT_TYPE
                ,X_ELEMENT_NUMBER                     => l_task_NUMBER --Bug 3705333 Changed from p_task_number to l_task_number
                ,X_NAME                               => la_task_NAME  --Bug 3705333 Changed from p_task_name to la_task_name
                ,X_DESCRIPTION                    => l_task_DESCRIPTION
                ,X_STATUS_CODE                    => l_STATUS_CODE
                ,X_WF_STATUS_CODE                     => null       --per Sakthi
                ,X_PM_PRODUCT_CODE                    => l_PM_PRODUCT_CODE
                ,X_PM_TASK_REFERENCE                  => l_PM_TASK_REFERENCE
                ,X_CLOSED_DATE                    => l_CLOSED_DATE
                ,X_LOCATION_ID                    => l_LOCATION_ID
                ,X_MANAGER_PERSON_ID                => l_task_MANAGER_ID
                ,X_CARRYING_OUT_ORGANIZATION_ID       => l_carrying_out_org_id
                ,X_TYPE_ID                              => l_TYPE_ID
                ,X_PRIORITY_CODE                      => l_PRIORITY_CODE
                ,X_INC_PROJ_PROGRESS_FLAG             => l_INC_PROJ_PROGRESS_FLAG
                ,X_REQUEST_ID                           => null --p_REQUEST_ID   --per Sakthi
                ,X_PROGRAM_APPLICATION_ID             => null --p_PROGRAM_APPLICATION_ID --per Sakthi
                ,X_PROGRAM_ID                           => null --p_PROGRAM_ID --per Sakthi
                ,X_PROGRAM_UPDATE_DATE              => null --p_PROGRAM_UPDATE_DATE --per Sakthi
                ,X_LINK_TASK_FLAG                     => NVL(l_link_task_flag,'N' )
                ,X_ATTRIBUTE_CATEGORY               => l_ATTRIBUTE_CATEGORY
                ,X_ATTRIBUTE1                           => l_ATTRIBUTE1
                ,X_ATTRIBUTE2                           => l_ATTRIBUTE2
                ,X_ATTRIBUTE3                           => l_ATTRIBUTE3
                ,X_ATTRIBUTE4                           => l_ATTRIBUTE4
                ,X_ATTRIBUTE5                           => l_ATTRIBUTE5
                ,X_ATTRIBUTE6                           => l_ATTRIBUTE6
                ,X_ATTRIBUTE7                           => l_ATTRIBUTE7
                ,X_ATTRIBUTE8                           => l_ATTRIBUTE8
                ,X_ATTRIBUTE9                           => l_ATTRIBUTE9
                ,X_ATTRIBUTE10                    => l_ATTRIBUTE10
                ,X_ATTRIBUTE11                    => l_ATTRIBUTE11
                ,X_ATTRIBUTE12                    => l_ATTRIBUTE12
                ,X_ATTRIBUTE13                    => l_ATTRIBUTE13
                ,X_ATTRIBUTE14                    => l_ATTRIBUTE14
                ,X_ATTRIBUTE15                    => l_ATTRIBUTE15
                ,X_TASK_WEIGHTING_DERIV_CODE       => NULL
                ,X_WORK_ITEM_CODE                  => l_work_item_code
                ,X_UOM_CODE                        => l_uom_code
                ,x_wq_actual_entry_code            => l_wq_actual_entry_code
                ,x_task_progress_entry_page_id  => l_task_progress_entry_page_id
                ,x_phase_version_id             => l_phase_version_id
                ,x_PARENT_STRUCTURE_ID          => p_STRUCTURE_ID
                ,x_phase_code                   => l_phase_code
        ,x_Base_Perc_Comp_Deriv_Code    => l_Base_Perc_Comp_Deriv_Code
            -- Added for FP_M changes : 3305199
               -- Bug#3491609 : Workflow Chanegs FP M
                 ,x_wf_item_type    => l_wf_item_type
                 ,x_wf_process      => l_wf_process
                 ,x_wf_lead_days    => l_wf_lead_days
                 ,x_wf_enabled_flag => 'N'
               -- Bug#3491609 : Workflow Chanegs FP M
                 ,X_SOURCE_OBJECT_ID      => p_project_id
                 ,X_SOURCE_OBJECT_TYPE    => 'PA_PROJECTS'
				 ,X_TASK_STATUS_CODE      => l_task_status --Changes for 8566495 anuragag
             );

l_link_task_flag := l_old_link_task_flag; --Changes for 8566495 anuragag
    IF (l_task_progress_entry_page_id IS NOT NULL) THEN
    -- need to include progress entry page
      OPEN get_page_name(l_task_progress_entry_page_id);
      FETCH get_page_name into l_page_name;
      CLOSE get_page_name;

      PA_PROGRESS_REPORT_PUB.DEFINE_PROGRESS_REPORT_SETUP(
        p_object_id => x_task_id
       ,p_object_type => 'PA_TASKS'
       ,p_page_type_code => 'AI'
       ,p_page_id => l_task_progress_entry_page_id
       ,p_page_name => l_page_name
       ,x_return_status => l_return_status
       ,x_msg_count => l_msg_count
       ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
      END IF;


    END IF;


IF p_calling_module NOT IN ( 'FORMS', 'AMG' )
THEN
         --Do financial task check
         --If financial

         OPEN cur_struc_type;
         FETCH cur_struc_type INTO l_dummy_char;
         IF cur_struc_type%FOUND
         THEN
           --If structure has any published versions.

--Moved up for --bug 2789483
           --l_publised_version := 'N';   --Moved up for --bug 2789483

           /* Bug 2623999 Added the following condition. This cusror cur_pub_versions will be used if
          p_structure_version_id is not null. Otherwise the  cur_pub_versions will be used*/

--maansari: This is a bug bcoz when we check published version we check any published version then dont add task in pa_task
--          if its versioned. So the requirement is to check for any published version
--          For more info please refer bug 2738747
       /*IF (p_structure_version_id is not null and p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
               OPEN cur_pub_versions2;
           FETCH cur_pub_versions2 INTO l_publised_version;
               CLOSE cur_pub_versions2;
       ELSE
              */
--Moved up for --bug 2789483
              /* OPEN cur_pub_versions;
           FETCH cur_pub_versions INTO l_publised_version;
               CLOSE cur_pub_versions;
                  */  --bug 2789483
--Moved up for --bug 2789483
--     END IF;

--hsiu
--changes for versioning
           l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     p_project_id);
           --hsiu: bug 3597226
           --versioning is only available when wp is shared with fin.
           --if fin alone, the value is NULL
           IF l_versioned IS NULL THEN
             l_versioned := 'N';
           END IF;
           --end bug 3597226

           l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  p_project_id);

       -- Modified for FP_M changes
       -- Tracking Bug 3305199
       l_full_shared := PA_PROJECT_STRUCTURE_UTILS.get_Structure_Sharing_Code( p_project_id);

/*  IF (NVL( l_publised_version, 'N' ) = 'N' and l_full_shared = 'SHARE_FULL') OR
     (l_publised_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y' AND l_full_shared = 'SHARE_FULL') OR
     p_structure_type = 'FINANCIAL'  -- Bug 3305199
*/
   IF l_link_task_flag = 'N' THEN  /* smukka Bug No. 3450684 Added for sub project association*/
     IF ( p_structure_type = 'FINANCIAL' AND l_versioned = 'N' ) OR
        ( p_structure_type = 'FINANCIAL' AND l_versioned = 'Y' AND NVL( l_publised_version, 'N' ) = 'N' ) OR  /* creating task under fin tab in shared or partial shared structures */
        ( p_structure_type = 'FINANCIAL' AND nvl(l_shared,'N') ='N' ) OR  /*This is Split Case : This had been missed out earlier.Patching this fix also as a part of 3935874 .This fix is not relevant to issue mentioned in the bug */
        ( p_structure_type = 'WORKPLAN' AND l_full_shared = 'SHARE_FULL'
          AND l_versioned = 'Y' AND NVL( l_publised_version, 'N' ) = 'N' ) OR
        ( p_structure_type = 'WORKPLAN' AND l_full_shared = 'SHARE_FULL'
          AND l_versioned = 'N')
       THEN
--end changes
--dbms_output.put_line( 'Before Existing Create_task API '||p_project_id );

             l_dummy_char := null;
             open cur_chk_pa_tasks;
             fetch cur_chk_pa_tasks INTO l_dummy_char;
             close cur_chk_pa_tasks;

--dbms_output.put_line('<'||l_dummy_char||'>, null = pa task is empty');

             l_dummy_char2 := null;
             open cur_chk_ref_task;
             fetch cur_chk_ref_task INTO l_dummy_char2;
             CLOSE cur_chk_ref_task;
--dbms_output.put_line('<'||l_dummy_char2||'>, null = ref task is a structure');



             IF ( p_ref_task_id IS NULL AND l_dummy_char IS NOT NULL ) OR
                ( p_ref_task_id IS NOT NULL AND l_dummy_char IS NULL )
                --( l_dummy_char2 IS NOT NULL ) --is a structure version id not a valid ref task id from pa_task
             THEN
                --Not a valid ref task. Tasks exists in pa_tasks
--dbms_output.put_line('error with ref tsk');
                PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INV_REF_TASK_ID');
                l_msg_data := 'PA_PS_INV_REF_TASK_ID';
        -- start of bug 3459905
             --Check if there is any error.
             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count > 0 THEN
                x_msg_count := l_msg_count;
                IF x_msg_count = 1 THEN
                   x_msg_data := l_msg_data;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       -- end of bug 3459905
             END IF;

           /* bug 3459905  --Check if there is any error.
             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count > 0 THEN
                x_msg_count := l_msg_count;
                IF x_msg_count = 1 THEN
                   x_msg_data := l_msg_data;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          end 3459905 */
             /*SELECT nvl( wbs_record_version_number, 1 )
               INTO l_wbs_record_version_number
            -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
             FROM pa_proj_elem_ver_structure
-- HY               FROM pa_projects_all
              WHERE project_id = p_project_id
                AND element_version_id = p_structure_version_id;*/
             l_wbs_record_version_number := 1;      --temporarily

--dbms_output.put_line( 'Reference task before calling existing create task API '||p_ref_task_id );
             -- xxlu added task DFF attributes
             -- xxlu added p_long_task_name
         -- Bug 3804265 Store p_scheduled_start_date and p_scheduled_start_date for transaction start
         -- date and transaction end date only for financial structures
             If p_structure_type = 'FINANCIAL' THEN
                IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_start_date IS NOT NULL )
                THEN
                   l_task_trn_start_date := NULL;
                ELSE
                   l_task_trn_start_date := p_scheduled_start_date;
                END IF;

                IF ( p_scheduled_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_finish_date IS NOT NULL )
                THEN
                   l_task_trn_end_date := Null;
                ELSE
                   l_task_trn_end_date := p_scheduled_finish_date;
                END IF;
             End If;
         -- Bug 3804265 Store p_scheduled_start_date and p_scheduled_start_date for transaction start
         -- date and transaction end date in case of financial tasks
         -- Bug 3810252 : Reverted the fix of Bug 3804265

             --Bug 3935874 : Changed SUBSTR to SUBSTRB for avoiding MLS problem
             --              Also ,Truncated Description to 250 chars as PA_TASKS can hold
             --              Only Description upto 250 chars (l_task_description can be upto 2000 chars)
             PA_TASKS_MAINT_PUB.CREATE_TASK
                                          (
                       p_api_version                       => p_api_version
                      ,p_init_msg_list                     => p_init_msg_list
                      ,p_commit                            => p_commit
                      ,p_validate_only                     => p_validate_only
                      ,p_validation_level                  => p_validation_level
                      ,p_calling_module                    => p_calling_module
                      ,p_debug_mode                        => p_debug_mode
                      ,p_project_id                        => p_project_id
                      ,p_reference_task_id                 => p_ref_task_id
                      --,p_reference_task_name               => 'TASK NAME'
                      ,p_peer_or_sub                       => p_peer_or_sub
                      ,p_task_number                       => SUBSTRB( l_task_number, 1, 25 ) --Bug 3705333 Changed from p_task_number to l_task_number
                      ,p_task_name                         => SUBSTRB( la_task_name, 1, 20 ) --Bug 3705333 Changed from p_task_name to la_task_namer
                      ,p_long_task_name                    => la_task_name --Bug 3705333 Changed from p_task_name to la_task_namer
		      -- Bug#5227374.Corrected the substrb syntax below which was introduced thru Bug#3935874
                      ,p_task_description                  => SUBSTRB(l_task_description,1,250) --Bug 3935874
                      ,p_task_manager_person_id            => l_task_manager_id
                      ,p_carrying_out_organization_id      => l_carrying_out_org_id
                      ,p_scheduled_start_date              => p_scheduled_start_date
                      ,p_scheduled_finish_date             => p_scheduled_finish_date
--  Bug 3810252Reverting the Fix                    ,p_task_start_date                   => p_scheduled_start_date   --Bug 3804265
--  Bug 3810252Reverting the Fix                    ,p_task_completion_date              => p_scheduled_finish_date  --Bug 3804265
                      ,p_task_start_date                   => l_task_trn_start_date   --Bug 3804265
                      ,p_task_completion_date              => l_task_trn_end_date  --Bug 3804265
                      ,p_inc_proj_progress_flag            => l_inc_proj_progress_flag
                      ,p_pm_product_code                   => l_pm_product_code
                      ,p_pm_task_reference                 => l_pm_task_reference
                      ,p_attribute_category                => l_tk_attribute_category
                      ,p_attribute1                        => l_tk_attribute1
                      ,p_attribute2                        => l_tk_attribute2
                      ,p_attribute3                        => l_tk_attribute3
                      ,p_attribute4                        => l_tk_attribute4
                      ,p_attribute5                        => l_tk_attribute5
                      ,p_attribute6                        => l_tk_attribute6
                      ,p_attribute7                        => l_tk_attribute7
                      ,p_attribute8                        => l_tk_attribute8
                      ,p_attribute9                        => l_tk_attribute9
                      ,p_attribute10                       => l_tk_attribute10
                      ,p_wbs_record_version_number         => l_wbs_record_version_number
                      ,p_address_id                        => p_address_id
                      ,p_work_type_id                      => p_work_type_id
                      ,p_service_type_code                 => p_service_type_code
                      ,p_chargeable_flag                   => p_chargeable_flag
                      ,p_billable_flag                     => p_billable_flag
                      ,p_receive_project_invoice_flag      => p_receive_project_invoice_flag
                      ,p_task_id                           => x_task_id
                      ,x_return_status                     => l_return_status
                      ,x_msg_count                         => l_msg_count
                      ,x_msg_data                          => l_msg_data
                              );
             -- end xxlu changes

--dbms_output.put_line( 'l_msg_data '||l_msg_data );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;

/* Commenting out for bug 3010538
            --Bug 2947492.
            --The following code will be executed if tasks are created from Self Service
            --Call plannable apis

            OPEN get_parent_task_id( x_task_id );
            FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id;
            CLOSE get_parent_task_id;

            l_plannable_tasks_tbl(1).impacted_task_id   := x_task_id;
            l_plannable_tasks_tbl(1).action             := 'INSERT';
            l_plannable_tasks_tbl(1).New_parent_task_id := l_parent_task_id;
            l_plannable_tasks_tbl(1).top_task_id        := l_top_task_id;


            PA_FP_ELEMENTS_PUB.MAINTAIN_PLANNABLE_TASKS(
                    p_project_id         => p_project_id
                  , p_impacted_tasks_tbl => l_plannable_tasks_tbl
                  , x_return_status      => l_return_status
                  , x_msg_data           => l_msg_data
                  , x_msg_count          => l_msg_count
                );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;
            --End Bug 2947492.
*/ --bug 3010538

           END IF; --structure has published versions check
         END IF;  --smukka end if for l_link_task_flag ='N' added for sub project association
       END IF;  --financial check
         CLOSE cur_struc_type;

END IF; --<<p_calling_module>>

/* Commenting out for bug 3010538
--Bug 2947492
--If a task is created from Forms then the following code will be executed.
--The reason to Split the code is to have performance.
--When a task is created from AMG its not made plannable from this api. The proposal is to make kick off a
--concurrent program from AMG
IF p_calling_module = 'FORMS'
THEN

         OPEN cur_struc_type;
         FETCH cur_struc_type INTO l_dummy_char;
         IF cur_struc_type%FOUND
         THEN
           l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     p_project_id);
           l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  p_project_id);

           IF (NVL( l_publised_version, 'N' ) = 'N') OR
              (l_publised_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y') THEN

              --Call plannable apis

              OPEN get_parent_task_id( x_task_id );
              FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id;
              CLOSE get_parent_task_id;

              l_plannable_tasks_tbl(1).impacted_task_id   := x_task_id;
              l_plannable_tasks_tbl(1).action             := 'INSERT';
              l_plannable_tasks_tbl(1).New_parent_task_id := l_parent_task_id;
              l_plannable_tasks_tbl(1).top_task_id        := l_top_task_id;


              PA_FP_ELEMENTS_PUB.MAINTAIN_PLANNABLE_TASKS(
                    p_project_id         => p_project_id
                  , p_impacted_tasks_tbl => l_plannable_tasks_tbl
                  , x_return_status      => l_return_status
                  , x_msg_data           => l_msg_data
                  , x_msg_count          => l_msg_count
                );

                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     x_msg_count := FND_MSG_PUB.count_msg;
                     IF x_msg_count = 1 then
                        pa_interface_utils_pub.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                         p_msg_index      => 1,
                         p_msg_count      => l_msg_count,
                         p_msg_data       => l_msg_data,
                         p_data           => l_data,
                         p_msg_index_out  => l_msg_index_out);
                       x_msg_data := l_data;
                     END IF;
                     raise FND_API.G_EXC_ERROR;
                 END IF;
           END IF; --<< l_publised_version >>
         END IF;  --<<cur_struc_type>>

END IF;  --<< p_calling_module >>
--Bug 2947492
*/ --bug 3010538

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'Create_Task',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Create_Task;

-- API name                      : Update_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_id          IN    NUMBER  N   Not Null
-- p_task_number          IN    VARCHAR2    N   Not Null
-- p_task_name        IN    VARCHAR2    N   Not Null
-- p_task_description   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city               IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_manager_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_carrying_out_org_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_priority_code  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code    IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_record_version_number  IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  31-JUL-02   H Siu                    -Added transaction dates
--

PROCEDURE Update_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_id              IN  NUMBER,
 p_task_number        IN    VARCHAR2,
 p_task_name          IN    VARCHAR2,
 p_task_description IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id        IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country              IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code         IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region           IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city             IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_priority_code          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID            IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code        IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code  IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date        IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_parent_structure_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code               IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_record_version_number    IN  NUMBER,
 -- xxlu added task DFF attributes
 p_tk_attribute_category     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
 p_Base_Perc_Comp_Deriv_Code     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  -- This param added for FP_M changes 3305199
 p_gen_etc_src_code      IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- Bug#3491609 : Workflow Chanegs FP M
 p_wf_item_type          IN    pa_proj_elements.wf_item_type%TYPE       :=NULL,
 p_wf_process            IN    pa_proj_elements.wf_process%TYPE         :=NULL,
 p_wf_lead_days          IN    pa_proj_elements.wf_start_lead_days%TYPE :=NULL,
 p_wf_enabled_flag       IN    pa_proj_elements.enable_wf_flag%TYPE     :=NULL,
  -- Bug#3491609 : Workflow Chanegs FP M
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_shared                 IN      VARCHAR2 := 'X' -- Bug 3451073
) IS

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_error_message_code           VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_change_allowed           VARCHAR2(1);

    l_carrying_out_org_id          NUMBER;

    l_task_description             PA_PROJ_ELEMENTS.description%TYPE;
    l_location_id                    NUMBER;
    --l_country
    --l_territory_code
    --l_state_region
    --l_city
    l_task_manager_id              NUMBER;
    l_task_name                  PA_PROJ_ELEMENTS.name%TYPE;
    l_priority_code            PA_PROJ_ELEMENTS.priority_code%TYPE;
    l_TYPE_ID                    PA_PROJ_ELEMENTS.TYPE_ID  %TYPE;
    l_status_code                    PA_PROJ_ELEMENTS.status_code%TYPE;
    l_wf_status_code               PA_PROJ_ELEMENTS.wf_status_code%TYPE;
    l_inc_proj_progress_flag         PA_PROJ_ELEMENTS.inc_proj_progress_flag%TYPE;
    l_pm_product_code              VARCHAR2(30); --PA_PROJ_ELEMENTS.pm_product_code%TYPE;
    l_pm_task_reference            VARCHAR2(30); --PA_PROJ_ELEMENTS.pm_task_reference%TYPE;
    l_closed_date                    PA_PROJ_ELEMENTS.closed_date%TYPE;
    --l_scheduled_start_date
    --l_scheduled_finish_date
    l_attribute_category         PA_PROJ_ELEMENTS.attribute_category%TYPE;
    l_attribute1                     PA_PROJ_ELEMENTS.attribute1%TYPE;
    l_attribute2                     PA_PROJ_ELEMENTS.attribute2%TYPE;
    l_attribute3                     PA_PROJ_ELEMENTS.attribute3%TYPE;
    l_attribute4                     PA_PROJ_ELEMENTS.attribute4%TYPE;
    l_attribute5                     PA_PROJ_ELEMENTS.attribute5%TYPE;
    l_attribute6                     PA_PROJ_ELEMENTS.attribute6%TYPE;
    l_attribute7                     PA_PROJ_ELEMENTS.attribute7%TYPE;
    l_attribute8                     PA_PROJ_ELEMENTS.attribute8%TYPE;
    l_attribute9                     PA_PROJ_ELEMENTS.attribute9%TYPE;
    l_attribute10                    PA_PROJ_ELEMENTS.attribute10%TYPE;
    l_attribute11                    PA_PROJ_ELEMENTS.attribute11%TYPE;
    l_attribute12                    PA_PROJ_ELEMENTS.attribute12%TYPE;
    l_attribute13                    PA_PROJ_ELEMENTS.attribute13%TYPE;
    l_attribute14                    PA_PROJ_ELEMENTS.attribute14%TYPE;
    l_attribute15                    PA_PROJ_ELEMENTS.attribute15%TYPE;
    l_phase_version_id                   PA_PROJ_ELEMENTS.phase_version_id%TYPE;
    l_phase_code                         PA_PROJ_ELEMENTS.phase_code%TYPE;

--l_task_weighting_deriv_code PA_PROJ_ELEMENTS.task_weighting_deriv_code%TYPE;
l_work_item_code PA_PROJ_ELEMENTS.wq_item_code%TYPE;
l_uom_code PA_PROJ_ELEMENTS.wq_uom_code%TYPE;
l_wq_actual_entry_code PA_PROJ_ELEMENTS.wq_actual_entry_code%TYPE;
l_task_progress_entry_page_id PA_PROJ_ELEMENTS.task_progress_entry_page_id%TYPE;

    -- xxlu added task DFF attributes
    l_tk_attribute_category          pa_tasks.attribute_category%TYPE;
    l_tk_attribute1                  pa_tasks.attribute1%TYPE;
    l_tk_attribute2                  pa_tasks.attribute2%TYPE;
    l_tk_attribute3                  pa_tasks.attribute3%TYPE;
    l_tk_attribute4                  pa_tasks.attribute4%TYPE;
    l_tk_attribute5                  pa_tasks.attribute5%TYPE;
    l_tk_attribute6                  pa_tasks.attribute6%TYPE;
    l_tk_attribute7                  pa_tasks.attribute7%TYPE;
    l_tk_attribute8                  pa_tasks.attribute8%TYPE;
    l_tk_attribute9                  pa_tasks.attribute9%TYPE;
    l_tk_attribute10                   pa_tasks.attribute10%TYPE;
    -- end xxlu changes

    --hsiu added for task status
    l_task_status_changed                varchar2(1);
    --end task status changes

   -- Changed Pa_tasks to pa_proj_elements for Bug 3809523
   l_task_number    pa_proj_elements.element_number%TYPE := p_task_number; --ADDED FOR BUG 3705333
   la_task_name      pa_proj_elements.name%TYPE  := p_task_name;  --ADDED FOR BUG 3705333
    cursor get_page_name(c_page_id NUMBER)
    IS
      SELECT page_name
        from pa_page_layouts
       where page_id = c_page_id
         and page_type_code = 'AI';

    cursor get_current_page(c_object_id NUMBER)
    IS
      SELECT object_page_layout_id, record_version_number
        from pa_object_page_layouts
       where object_id = c_object_id
         and object_type = 'PA_TASKS'
         and page_type_code = 'AI';

    l_opl_id       NUMBER;
    l_page_name    pa_page_layouts.page_name%TYPE;
    l_opl_rvn      NUMBER;

--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
--end changes
  --3035902: process update flag changes
    l_wp_type      VARCHAR2(1);
  --3035902: end process update flag changes

   CURSOR cur_proj_elems
   IS
     SELECT rowid
            --project_id, object_type, record_version_number
           ,PROJ_ELEMENT_ID
           ,PROJECT_ID
           ,OBJECT_TYPE
           ,ELEMENT_NUMBER
           ,NAME
           ,DESCRIPTION
           ,STATUS_CODE
           ,WF_STATUS_CODE
           ,PM_SOURCE_CODE
           ,PM_SOURCE_REFERENCE
           ,CLOSED_DATE
           ,LOCATION_ID
           ,MANAGER_PERSON_ID
           ,CARRYING_OUT_ORGANIZATION_ID
           ,TYPE_ID
           ,PRIORITY_CODE
           ,INC_PROJ_PROGRESS_FLAG
           ,RECORD_VERSION_NUMBER
           ,ATTRIBUTE_CATEGORY
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,WQ_ITEM_CODE
           ,WQ_UOM_CODE
           ,WQ_ACTUAL_ENTRY_CODE
           ,TASK_PROGRESS_ENTRY_PAGE_ID
           ,PHASE_VERSION_ID
           ,PHASE_CODE
           ,PARENT_STRUCTURE_ID
           ,BASE_PERCENT_COMP_DERIV_CODE
       FROM PA_PROJ_ELEMENTS
      WHERE proj_element_id = p_task_id;

   v_cur_proj_elems_rec cur_proj_elems%ROWTYPE;

  l_dummy_char                  VARCHAR2(1);
  l_published_version           VARCHAR2(1);
  l_structure_id                NUMBER;
  l_project_id                  NUMBER;
  l_parent_task_id              NUMBER;
  l_top_task_id                 NUMBER;
  l_wbs_level                   NUMBER;
  l_full_shared         VARCHAR2(30);

    CURSOR cur_struc_type( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

-- Bug 2827063 Tuned the following cursor to use exists
    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y' from dual
      where exists
    (select 'xyz'
     from pa_proj_elem_ver_structure
         where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED');

   CURSOR cur_struc_id
   IS
     SELECT a.proj_element_id
       FROM pa_proj_element_versions a, pa_proj_element_versions b
      WHERE a.element_version_id = b.parent_structure_version_id
        AND b.proj_element_id = p_task_id;

   CURSOR get_task_types_attr(c_task_type_id NUMBER) IS
      select WORK_ITEM_CODE, UOM_CODE,
             ACTUAL_WQ_ENTRY_CODE, TASK_PROGRESS_ENTRY_PAGE_ID,
             prog_entry_enable_flag,BASE_PERCENT_COMP_DERIV_CODE     --Jun 28th
        from pa_task_types
       where task_type_id = c_task_type_id;
   get_task_type_attr_rec  get_task_types_attr%ROWTYPE;
   get_task_type_attr_rec_old get_task_types_attr%ROWTYPE;

   --hsiu task status changes
   cursor get_latest_task_ver_id IS
     select b.parent_structure_version_id, b.element_version_id
       from pa_proj_elements a,
            pa_proj_element_versions b,
            pa_proj_elem_ver_structure c
      where a.proj_element_id = p_task_id
        and a.project_id = b.project_id
        and a.proj_element_id = b.proj_element_id
        and b.project_id = c.project_id
        and b.parent_structure_version_id = c.element_version_id
        and c.LATEST_EFF_PUBLISHED_FLAG = 'Y';
   l_latest_task_ver_rec    get_latest_task_ver_id%ROWTYPE;
--hsiu added for bug 2634195
   l_new_tt_wq_enabled  VARCHAR2(1);

--bug 3010538
l_update_WBS_flag    VARCHAR2(1) := 'N';
l_template_flag      VARCHAR2(1) := 'N';
CURSOR cur_proj_tmp(c_project_id NUMBER )
IS
  SELECT template_flag
    FROM pa_projects_all
   WHERE project_id = c_project_id;
--bug 3010538

-- Bug 3075609. If a task type is changed to a non progressible
-- one this flag is set to 'Y' so that the weightages can be
-- properly updated after updating the task details.
l_update_working_ver_weight   VARCHAR2(1);

--fpm changes
l_fin_task_flag   VARCHAR2(1);    --added to avoid multiple calls to check_fin_task_flag api
--
--Bug 3475920
CURSOR get_task_versions_id(cp_task_id NUMBER,cp_project_id NUMBER) IS
SELECT ppev.element_Version_id
  FROM pa_proj_element_versions ppev,
       pa_proj_elem_ver_structure ppevs
 WHERE ppev.project_id = cp_project_id
   and ppev.proj_element_id = cp_task_id
   and ppev.project_id = ppevs.project_id
   and ppevs.element_version_id = ppev.parent_structure_version_id
   and ppevs.status_code <> 'STRUCTURE_PUBLISHED';
--
CURSOR get_task_versions_id2(cp_task_id NUMBER,cp_project_id NUMBER) IS
SELECT ppev.element_Version_id
  FROM pa_proj_element_versions ppev,
       pa_proj_elem_ver_structure ppevs
 WHERE ppev.project_id = cp_project_id
   and ppev.proj_element_id = cp_task_id
   and ppev.project_id = ppevs.project_id
   and ppevs.element_version_id = ppev.parent_structure_version_id
   and ppevs.status_code = 'STRUCTURE_PUBLISHED';
   l_task_version_id  NUMBER;
   l_del_cnt          NUMBER:=0;
   l_parent_task_ver_id NUMBER;
   l_sub_task_ver_id    NUMBER;
--
--Bug 3705333 start
CURSOR get_task_name_or_number(c_project_id NUMBER,c_task_id NUMBER )
    IS
      SELECT task_name, task_number
        FROM pa_tasks
        WHERE project_id = c_project_id
        AND task_id = c_task_id;
--Bug 3705333 end
   l_base_perc_comp_deriv_code VARCHAR2(30);
      l_tt_base_perc_comp_der_cd  VARCHAR2(30);  --Jun 28th

--Bug 3957706
   l_prog_method_code PA_PROJ_ELEMENTS.BASE_PERCENT_COMP_DERIV_CODE%TYPE;

BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PVT1.UPDATE_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_TASK_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

--dbms_output.put_line(( 'Get the basic attributes of the task.' );

   --Get the basic attributes of the task
   OPEN cur_proj_elems;
   FETCH cur_proj_elems INTO v_cur_proj_elems_rec;
   IF cur_proj_elems%FOUND
   THEN
     -- Bug 2827063 Put the following assignment here instead of down in the code
     l_project_id := v_cur_proj_elems_rec.PROJECT_ID;

--moved from below to be used for bug 3010538 to improve performance.
      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      /* Commented the below statement and moved into the if condition for bug 3451073
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id); */
      /* Added the If conidtion for Bug 3451073 to improve performance*/
      IF p_shared = 'X'
      THEN
        l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                     l_project_id);
      ELSE
        l_shared := p_shared;
      END IF;

      --3035902: process update flag changes
      l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(v_cur_proj_elems_rec.PARENT_STRUCTURE_ID, 'WORKPLAN');
      --3035902: end process update flag changes

      --moving up for better performance by using the same code for bug 3010538
        -- Bug 2827063 Put the code to get structure id here instead of down.
     /* we dont need the following cursor to get the structure id
        we can as well get the parent structure id from the cursor above.
      OPEN cur_struc_id;
      FETCH cur_struc_id INTO l_structure_id;
      CLOSE cur_struc_id;
      */
      l_structure_id := v_cur_proj_elems_rec.parent_structure_id;

--bug 2789483

      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;
--bug 2789483
--end moving up for better performance by using the same code for bug 3010538



      if v_cur_proj_elems_rec.record_version_number <> p_record_version_number
      then
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
      end if;

      /* Added for Bug 3705333*/
      --dbms_output.put_line(('value of p_task_number'||p_task_number);
  If ((p_task_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR
    (p_task_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
    THEN
          OPEN get_task_name_or_number( l_project_id,p_task_id );
          FETCH get_task_name_or_number INTO la_task_name,l_task_number;
          CLOSE  get_task_name_or_number;
  END IF;
/* changes end for bug 3705333*/
--dbms_output.put_line('Value of l_task_number'||l_task_number);
--dbms_output.put_line( 'Check if the task name is unique within the project.' );
/** Commenting the code below for Bug 4120380. This check is same as the check implemented by
the constraint PA_PROJ_ELEMENTS_U2. This needs to commented to faciliate updation of task_number in the
case below:
Task 1.0 to be re-named to Taslk 1.1 and Task 1.1 to be renamed to Task 1.0 **/
      --Check if the task name is unique within the project
/* Code below is uncommented for bug 4218947 **/
     If (PA_PROJ_ELEMENTS_UTILS.check_element_number_unique(l_task_number, --Bug 3705333 changed from p_task_number to l_task_number
                                                           p_task_id,
                                                           v_cur_proj_elems_rec.project_id,
                                                           v_cur_proj_elems_rec.PARENT_STRUCTURE_ID) <> 'Y') THEN
        --Name is not unique
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NUMBER_UNIQUE');
        l_msg_data := 'PA_PS_TASK_NUMBER_UNIQUE';
    -- start of bug 3459905
     l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
           x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
        -- end of bug 3459905
      END IF;
/** End of Code Commenting for Bug 4120380 **/
/** Code above is uncommented for bug 4218947 **/
--dbms_output.put_line(( 'After Check if the task name is unique within the project.' );

        /* start of bug 3459905   --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
           x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
end of bug 3459905 */

-- hyau
-- Lifecycle Phase validation Changes. Check if task has phase associated with it
  IF ( p_phase_version_id IS NOT NULL) AND
       (p_phase_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

    -- check if it is top task
    IF ('N' = pa_proj_elements_utils.IS_TOP_TASK_ACROSS_ALL_VER(
              p_task_id)) THEN
      --Is not a top task across all versions. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_LC_NOT_ALL_TOP_TASKS');
      -- start of bug 3459905
      --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     -- end of bug 3459905
    END IF;

    -- check if the current phase is already used.
    IF ('Y' = pa_proj_elements_utils.CHECK_PHASE_IN_USE(
              p_task_id,
              p_phase_version_id)) THEN
      -- Phase already in use in the structure. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_LC_PHASE_IN_USE');
      -- start of bug 3459905
      --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     -- end of bug 3459905
    END IF;
/* start of bug 3459905
        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    end of bug 3459905 */
  END IF;
  -- end hyau. Lifecycle Phase validation Changes.

--Check if base percent derivation code can be modified if different
       /* <Start> Bug 3957706*/
  IF (p_TYPE_ID   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
          --Get the details of the Task Type
        OPEN get_task_types_attr(p_type_id);
        FETCH get_task_types_attr into get_task_type_attr_rec;
        CLOSE get_task_types_attr;
  END IF ;

        --If this p_base_perc_comp_deriv_code param is not passed
        --Retrieve its value from the DB (the tasks' base percent deriv.code)

        IF (p_base_perc_comp_deriv_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        THEN
             l_prog_method_code := v_cur_proj_elems_rec.BASE_PERCENT_COMP_DERIV_CODE;
        ELSE
             l_prog_method_code := p_base_perc_comp_deriv_code ;
        END IF ;

        --If This Value 'l_prog_method_code' is Still NULL or Miss_Char
        --Then we make it as the passed Task Type's BASE_PERCENT_COMP_DERIV_CODE

        IF(l_prog_method_code =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
           OR l_prog_method_code IS NULL)
        THEN
            IF (p_TYPE_ID   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                 l_prog_method_code := get_task_type_attr_rec.BASE_PERCENT_COMP_DERIV_CODE ;
            END IF;
        END IF;

        --If the BASE_PERCENT_COMP_DERIV_CODE of the task now is different
        --than that of the task's DB BASE_PERCENT_COMP_DERIV_CODE
        -- AND
        --If the task's new BASE_PERCENT_COMP_DERIV_CODE is DELIVERABLE
        --THEN
        --Place a Call to PA_DELIVERABLE_UTILS.CHECK_PROGRESS_MTH_CODE_VALID API
        --Which will validate that ,this task is not associated with any deliverable
        --that has already association with Deliverable based tasks

        IF ( nvl(l_prog_method_code,'Y') <> nvl(v_cur_proj_elems_rec.BASE_PERCENT_COMP_DERIV_CODE,'Y') )
           AND (l_prog_method_code = 'DELIVERABLE')
        THEN
              PA_DELIVERABLE_UTILS.CHECK_PROGRESS_MTH_CODE_VALID
              (
                 p_task_id => p_task_id,
                 p_prog_method_code => l_prog_method_code ,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data
                  );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
             END IF ;

        END IF ;
        /*<End> Bug 3957706*/

--check if task type can be modified if different
      l_new_tt_wq_enabled := NULL;
      IF (p_TYPE_ID   <> v_cur_proj_elems_rec.TYPE_ID   AND p_TYPE_ID   <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

         PA_TASK_TYPE_UTILS.change_task_type_allowed(
          p_task_id => p_task_id,
          p_from_task_type_id => v_cur_proj_elems_rec.TYPE_ID  ,
          p_to_task_type_id => p_TYPE_ID  ,
          x_change_allowed => l_change_allowed,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
          );

        IF (l_change_allowed = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CHG_TASK_TYPE_ERR');
          l_msg_data := 'PA_PS_CHG_TASK_TYPE_ERR';
       --Check if there is any error.
       -- start of bug 3459905
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    -- end of bug 3459905
        END IF;

        IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_effective(p_type_id)) THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_EFF_TASK_TYPE_ERR');
          l_msg_data := 'PA_PS_EFF_TASK_TYPE_ERR';
       -- start of bug 3459905
       --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    -- end of bug 3459905
        END IF;
/*   start of bug 3459905
        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
end of bug 3458052*/
        --new type; copy all attributes
/*      Moved this code above for Bug 3957706
        OPEN get_task_types_attr(p_type_id);
        FETCH get_task_types_attr into get_task_type_attr_rec;
        CLOSE get_task_types_attr;
*/
        l_work_item_code := get_task_type_attr_rec.WORK_ITEM_CODE;
        l_uom_code := get_task_type_attr_rec.UOM_CODE;
        l_wq_actual_entry_code := get_task_type_attr_rec.ACTUAL_WQ_ENTRY_CODE;
        l_TYPE_ID   := p_TYPE_ID;
        l_tt_base_perc_comp_der_cd:=get_task_type_attr_rec.BASE_PERCENT_COMP_DERIV_CODE;  --Jun 28th

        --hsiu: bug 2663532
        --check if progressable; if not, need to set weighting for
        --all working versions to 0.


        OPEN get_task_types_attr(v_cur_proj_elems_rec.TYPE_ID);
        FETCH get_task_types_attr into get_task_type_attr_rec_old;
        CLOSE get_task_types_attr;

        IF (get_task_type_attr_rec_old.prog_entry_enable_flag = 'Y' AND
            get_task_type_attr_rec.prog_entry_enable_flag = 'N') THEN
          -- Bug 3075609. We'll update after the task type id is updated for the task.
          l_update_working_ver_weight := 'Y';
          --set working versions weighting to 0
          --pro-rate peer tasks
/*          PA_TASK_PVT1.UPDATE_WORKING_VER_WEIGHT(
            p_task_id => p_task_id
           ,p_weighting => 0
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data);

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
             IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
*/
        END IF;
        --end bug 2663532

--bug 3010538
--bug 3058098
--for workplan structure or shared structure only
        --3035902: process update flag changes
        --added condition for sharing and split structures
        IF ((l_shared = 'Y') OR
            (l_shared = 'N' AND l_wp_type = 'Y')) THEN
          IF (get_task_type_attr_rec_old.prog_entry_enable_flag <>
            get_task_type_attr_rec.prog_entry_enable_flag) AND
            PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS( l_project_id ) in ( 'DURATION', 'EFFORT' )
          THEN
            OPEN cur_proj_tmp( l_project_id );
            FETCH cur_proj_tmp INTO l_template_flag;
            CLOSE cur_proj_tmp;
            IF NVL( l_versioned, 'N' ) = 'N' OR NVl( l_template_flag, 'N' ) = 'Y'
            THEN
               UPDATE pa_proj_elem_ver_structure
                  SET process_update_wbs_flag = 'Y'
                WHERE project_id = l_project_id
                  AND proj_element_id  = l_structure_id;
            ELSIF NVL( l_versioned, 'N' ) = 'Y'
            THEN
               UPDATE pa_proj_elem_ver_structure
                  SET process_update_wbs_flag = 'Y'
                WHERE project_id = l_project_id
                  AND proj_element_id  = l_structure_id
                  AND status_code = 'STRUCTURE_WORKING';
            END IF;
          END IF;
        END IF;
--end bug 3010538

      ELSE
        l_TYPE_ID   := v_cur_proj_elems_rec.TYPE_ID  ;

        --check change work item ok
        IF (p_work_item_code <> v_cur_proj_elems_rec.WQ_ITEM_CODE AND
            p_work_item_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

          PA_TASK_TYPE_UTILS.change_wi_allowed(
            p_task_id => p_task_id,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END IF;

        IF (p_work_item_code IS NOT NULL AND p_work_item_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          l_work_item_code := v_cur_proj_elems_rec.WQ_ITEM_CODE;
        ELSE
          IF (PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_TYPE_ID) = 'Y' AND
              PA_PROGRESS_UTILS.get_project_wq_flag(v_cur_proj_elems_rec.project_id) = 'Y') THEN
            l_work_item_code := p_work_item_code;
          ELSE
            l_work_item_code := null;
          END IF;
        END IF;

        --check change uom
        IF (p_UOM_code <> v_cur_proj_elems_rec.WQ_UOM_CODE AND
            p_UOM_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

          PA_TASK_TYPE_UTILS.change_uom_allowed(
            p_task_id => p_task_id,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
          );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                  x_msg_data := l_msg_data;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END IF;

        IF (p_uom_code IS NOT NULL and p_uom_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          l_uom_code := v_cur_proj_elems_rec.WQ_UOM_CODE;
        ELSE
          IF (PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_TYPE_ID) = 'Y' AND
              PA_PROGRESS_UTILS.get_project_wq_flag(v_cur_proj_elems_rec.project_id) = 'Y') THEN
            l_uom_code := p_uom_code;
          ELSE
            l_uom_code := NULL;
          END IF;
        END IF;

        IF (p_wq_actual_entry_code IS NOT NULL and p_wq_actual_entry_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          l_wq_actual_entry_code := v_cur_proj_elems_rec.WQ_ACTUAL_ENTRY_CODE;
        ELSE
          l_wq_actual_entry_code := p_wq_actual_entry_code;
        END IF;

      END IF;


      IF ( p_task_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_task_description IS NOT NULL )
      THEN
          l_task_description := v_cur_proj_elems_rec.description;
      ELSE
          l_task_description := p_task_description;
      END IF;

/* Move the following code up to have better performance so that the same code
  can be used for bug 3010538
    -- Bug 2827063 Put the code to get structure id here instead of down.
      OPEN cur_struc_id;
      FETCH cur_struc_id INTO l_structure_id;
      CLOSE cur_struc_id;

--bug 2789483

      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;
--bug 2789483
*/ --moving up for better performance by using the same code for bug 3010538

    --hsiu task status changes
    l_task_status_changed := 'N';

    -- Bug 4429929 : Now All task status excpet Cancal can be changed thru Progress Only

 --   IF ( p_STATUS_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_STATUS_CODE IS NOT NULL ) Bug 2827063
      IF ( p_STATUS_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_STATUS_CODE IS NULL )
       OR l_published_version = 'N' --bug 2789483
    THEN
        l_STATUS_CODE := v_cur_proj_elems_rec.STATUS_CODE;
    ELSE

        -- Amit : Code added so that task status can't be changed for a cancelled task
        IF (v_cur_proj_elems_rec.STATUS_CODE <> p_STATUS_CODE AND
            PA_PROGRESS_UTILS.get_system_task_status(v_cur_proj_elems_rec.STATUS_CODE)= 'CANCELLED')
        THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name => 'PA_TSK_STS_CANT_CHANGED');
           raise FND_API.G_EXC_ERROR;
        END IF;
        --marked as changed only if different
        l_status_code := p_status_code;

        If (v_cur_proj_elems_rec.status_code <> p_status_code AND PA_PROGRESS_UTILS.get_system_task_status(p_status_code)= 'CANCELLED') THEN
          l_task_status_changed := 'Y';
        ELSE -- Bug 4429929
      l_STATUS_CODE := v_cur_proj_elems_rec.STATUS_CODE;
        END IF;
    END IF;
--
        --Bug No 3475920
    IF l_versioned = 'Y' THEN
           OPEN get_task_versions_id(p_task_id,l_project_id);
           LOOP
              FETCH get_task_versions_id INTO l_task_version_id;
          EXIT WHEN get_task_versions_id%NOTFOUND;
          l_del_cnt:=PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hie_upd(l_task_version_id);
--              IF l_del_cnt >=1 AND p_Base_Perc_Comp_Deriv_Code LIKE 'DELIVERABLE'  THEN     --Jun 28th
              IF l_del_cnt >=1 AND (p_Base_Perc_Comp_Deriv_Code LIKE 'DELIVERABLE'
                                      OR  l_tt_base_perc_comp_der_cd  LIKE 'DELIVERABLE' ) THEN  --Jun 28th
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
                 raise FND_API.G_EXC_ERROR;
              END IF;
           END LOOP;
           CLOSE get_task_versions_id;
    ELSE
           OPEN get_task_versions_id2(p_task_id,l_project_id);
           LOOP
              FETCH get_task_versions_id2 INTO l_task_version_id;
          EXIT WHEN get_task_versions_id2%NOTFOUND;
          l_del_cnt:=PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hie_upd(l_task_version_id);
--              IF l_del_cnt >=1 AND p_Base_Perc_Comp_Deriv_Code LIKE 'DELIVERABLE'  THEN    --Jun 28th
              IF l_del_cnt >=1 AND (p_Base_Perc_Comp_Deriv_Code LIKE 'DELIVERABLE'
                                      OR  l_tt_base_perc_comp_der_cd  LIKE 'DELIVERABLE' ) THEN  --Jun 28th
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
                 raise FND_API.G_EXC_ERROR;
              END IF;
           END LOOP;
           CLOSE get_task_versions_id2;
    END IF;
--
    --end task status changes

    IF ( p_PM_PRODUCT_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_PM_PRODUCT_CODE IS NOT NULL )
    THEN
       l_PM_PRODUCT_CODE := v_cur_proj_elems_rec.PM_SOURCE_CODE;
    ELSE
        l_PM_PRODUCT_CODE := p_PM_PRODUCT_CODE;
    END IF;

    IF ( p_PM_TASK_REFERENCE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_PM_TASK_REFERENCE IS NOT NULL )
    THEN
        l_PM_TASK_REFERENCE := v_cur_proj_elems_rec.PM_SOURCE_REFERENCE;
    ELSE
        l_PM_TASK_REFERENCE := p_PM_TASK_REFERENCE;
    END IF;

    IF ( p_location_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_location_id IS NOT NULL )
    THEN
       l_location_id :=  v_cur_proj_elems_rec.location_id;
    ELSE
       l_location_id := p_location_id;
    END IF;

    /*IF ( p_country = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_country IS NOT NULL )
    THEN
       l_country := v_cur_proj_elems_rec.country;
    ELSE
       l_country := p_country;
    END IF;


    IF ( p_territory_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_territory_code IS NOT NULL )
    THEN
        l_territory_code := v_cur_proj_elems_rec.;
    ELSE
        l_territory_code := p_territory_code;
    END IF;*/

    IF ( p_task_manager_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_task_manager_id IS NOT NULL )
    THEN
       l_task_manager_id := v_cur_proj_elems_rec.manager_person_id;
    ELSE
       l_task_manager_id := p_task_manager_id;
    END IF;

--dbms_output.put_line( 'p_carrying_out_org_id '||p_carrying_out_org_id );
    IF ( p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_carrying_out_org_id IS NOT NULL )
    THEN
       l_carrying_out_org_id := v_cur_proj_elems_rec.carrying_out_organization_id;
    ELSE
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF;

    /*IF ( ( p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) OR ( p_carrying_out_org_id IS NULL ) )
    THEN
       OPEN cur_projs;
       FETCH cur_projs INTO l_carrying_out_org_id;
       CLOSE cur_projs;
    ELSE
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF;*/


    IF ( p_priority_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_priority_code IS NOT NULL )
    THEN
       l_priority_code := v_cur_proj_elems_rec.priority_code;
    ELSE
       l_priority_code := p_priority_code;
    END IF;

    IF ( p_inc_proj_progress_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_inc_proj_progress_flag IS NOT NULL )
    THEN
       l_inc_proj_progress_flag := v_cur_proj_elems_rec.inc_proj_progress_flag;
    ELSE
       l_inc_proj_progress_flag := p_inc_proj_progress_flag;
    END IF;

    IF ( p_closed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_closed_date IS NOT NULL )
    THEN
       l_closed_date := v_cur_proj_elems_rec.closed_date;
    ELSE
       l_closed_date := p_closed_date;
    END IF;

    /*IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_start_date IS NOT NULL )
    THEN
       l_scheduled_start_date := v_cur_proj_elems_rec.;
    ELSE
       l_scheduled_start_date := p_scheduled_start_date;
    END IF;

    IF ( p_scheduled_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_finish_date IS NOT NULL )
    THEN
       l_scheduled_finish_date := v_cur_proj_elems_rec.;
    ELSE
       l_scheduled_finish_date := p_scheduled_finish_date;
    END IF;*/

    IF (p_base_perc_comp_deriv_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_base_perc_comp_deriv_code IS NOT NULL) THEN
       l_base_perc_comp_deriv_code := v_cur_proj_elems_rec.BASE_PERCENT_COMP_DERIV_CODE;
    ELSE
       l_base_perc_comp_deriv_code := p_base_perc_comp_deriv_code;
    END IF;

    --In the update_task process PA_PROJ_ELEMENTS.BASE_PERCENT_COMP_DERIV_CODE columns
    --is populated, only if it is null. Task_types value is used to populate base_percent_comp_deriv_code
    IF (l_base_perc_comp_deriv_code= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  OR l_base_perc_comp_deriv_code IS NULL) THEN
       l_base_perc_comp_deriv_code:=l_tt_base_perc_comp_der_cd;
    END IF;

    IF ( p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL )
    THEN
       l_attribute_category := v_cur_proj_elems_rec.attribute_category;
    ELSE
       l_attribute_category := p_attribute_category;
    END IF;

    IF ( p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL )
    THEN
       l_attribute1 := v_cur_proj_elems_rec.attribute1;
    ELSE
       l_attribute1 := p_attribute1;
    END IF;

    IF ( p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL )
    THEN
       l_attribute2 := v_cur_proj_elems_rec.attribute2;
    ELSE
       l_attribute2 := p_attribute2;
    END IF;

    IF ( p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL )
    THEN
       l_attribute3 := v_cur_proj_elems_rec.attribute3;
    ELSE
       l_attribute3 := p_attribute3;
    END IF;

    IF ( p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL )
    THEN
       l_attribute4 := v_cur_proj_elems_rec.attribute4;
    ELSE
       l_attribute4 := p_attribute4;
    END IF;

    IF ( p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL )
    THEN
       l_attribute5 := v_cur_proj_elems_rec.attribute5;
    ELSE
       l_attribute5 := p_attribute5;
    END IF;

    IF ( p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL )
    THEN
       l_attribute6 := v_cur_proj_elems_rec.attribute6;
    ELSE
       l_attribute6 := p_attribute6;
    END IF;

    IF ( p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL )
    THEN
       l_attribute7 := v_cur_proj_elems_rec.attribute7;
    ELSE
       l_attribute7 := p_attribute7;
    END IF;

    IF ( p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL )
    THEN
       l_attribute8 := v_cur_proj_elems_rec.attribute8;
    ELSE
       l_attribute8 := p_attribute8;
    END IF;

    IF ( p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL )
    THEN
       l_attribute9 := v_cur_proj_elems_rec.attribute9;
    ELSE
       l_attribute9 := p_attribute9;
    END IF;

    IF ( p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL )
    THEN
       l_attribute10 := v_cur_proj_elems_rec.attribute10;
    ELSE
       l_attribute10 := p_attribute10;
    END IF;

    IF ( p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL )
    THEN
       l_attribute11 := v_cur_proj_elems_rec.attribute11;
    ELSE
       l_attribute11 := p_attribute11;
    END IF;

    IF ( p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL )
    THEN
       l_attribute12 := v_cur_proj_elems_rec.attribute12;
    ELSE
       l_attribute12 := p_attribute12;
    END IF;

    IF ( p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL )
    THEN
       l_attribute13 := v_cur_proj_elems_rec.attribute13;
    ELSE
       l_attribute13 := p_attribute13;
    END IF;

    IF ( p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL )
    THEN
       l_attribute14 := v_cur_proj_elems_rec.attribute14;
    ELSE
       l_attribute14 := p_attribute14;
    END IF;

      IF ( p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL )
      THEN
         l_attribute15 := v_cur_proj_elems_rec.attribute15;
      ELSE
         l_attribute15 := p_attribute15;
      END IF;

    IF (p_phase_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_phase_code IS NOT NULL) THEN
      l_phase_code := v_cur_proj_elems_rec.phase_code;
    ELSE
      l_phase_code := p_phase_code;
    END IF;

    IF (p_phase_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_phase_version_id IS NOT NULL) THEN
      l_phase_version_id := v_cur_proj_elems_rec.phase_version_id;
    ELSE
      l_phase_version_id := p_phase_version_id;
    END IF;

    -- xxlu added task DFF attributes
    -- Removed the If ..ELSE conditions as we need to keep the values in the DB intact in case not passed from SSA -- 6826010
    l_tk_attribute_category := p_tk_attribute_category;
    l_tk_attribute1 := p_tk_attribute1;
    l_tk_attribute2 := p_tk_attribute2;
    l_tk_attribute3 := p_tk_attribute3;
    l_tk_attribute4 := p_tk_attribute4;
    l_tk_attribute5 := p_tk_attribute5;
    l_tk_attribute6 := p_tk_attribute6;
    l_tk_attribute7 := p_tk_attribute7;
    l_tk_attribute8 := p_tk_attribute8;
    l_tk_attribute9 := p_tk_attribute9;
    --Changes for bug 3179423
    -- l_tk_attribute10 := p_attribute10;
    l_tk_attribute10 := p_tk_attribute10;
    --END IF; -- Commented in bug 7526270 to remove compilation error in previous version of file.
    -- end xxlu changes

/*
    IF (p_task_weighting_deriv_code IS NOT NULL AND p_task_weighting_deriv_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_task_weighting_deriv_code := v_cur_proj_elems_rec.TASK_WEIGHTING_DERIV_CODE;
    ELSE
      l_task_weighting_deriv_code := p_task_weighting_deriv_code;
    END IF;
*/


    IF (p_task_progress_entry_page_id IS NOT NULL AND p_task_progress_entry_page_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_task_progress_entry_page_id := v_cur_proj_elems_rec.TASK_PROGRESS_ENTRY_PAGE_ID;
    ELSE
      IF (v_cur_proj_elems_rec.TYPE_ID <> p_type_id) THEN
        OPEN get_task_types_attr(p_type_id);
        FETCH get_task_types_attr into get_task_type_attr_rec;
        CLOSE get_task_types_attr;
        l_task_progress_entry_page_id := get_task_type_attr_rec.TASK_PROGRESS_ENTRY_PAGE_ID;
      ELSE
        l_task_progress_entry_page_id := p_task_progress_entry_page_id;
      END IF;
      OPEN get_page_name(p_task_progress_entry_page_id);
      FETCH get_page_name into l_page_name;
      IF get_page_name%NOTFOUND THEN
        l_page_name := NULL;
      END IF;
      CLOSE get_page_name;

      OPEN get_current_page(p_task_id);
      FETCH get_current_page into l_opl_id, l_opl_rvn;
      CLOSE get_current_page;

      PA_PROGRESS_REPORT_PUB.DEFINE_PROGRESS_REPORT_SETUP(
        p_object_id => p_task_id
       ,p_object_type => 'PA_TASKS'
       ,p_page_type_code => 'AI'
       ,p_page_id => l_task_progress_entry_page_id
       ,p_page_name => l_page_name
       ,p_object_page_layout_id => l_opl_id
       ,p_record_version_number => l_opl_rvn
       ,x_return_status => l_return_status
       ,x_msg_count => l_msg_count
       ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;
-- Bug 2827063 This should be up in the code, as it is being accessed there
--      l_project_id := v_cur_proj_elems_rec.PROJECT_ID;
--dbms_output.put_line(( 'Before calling UPDATE_ROW API.' );
--dbms_output.put_line(('value of p_task_NUMBER passed'||l_task_NUMBER);
--dbms_output.put_line(('value of p_task_id passed'||p_task_id);
--dbms_output.put_line(('Value of p_task_NAME '||p_task_NAME);
--dbms_output.put_line( 'Before calling UPDATE_ROW API.' );
      PA_PROJ_ELEMENTS_PKG.Update_Row(
                 X_ROW_ID                     => v_cur_proj_elems_rec.rowid
                ,X_PROJ_ELEMENT_ID            => p_task_id
                ,X_PROJECT_ID                   => v_cur_proj_elems_rec.PROJECT_ID
                ,X_OBJECT_TYPE            => 'PA_TASKS'
                ,X_ELEMENT_NUMBER             => l_task_number --Bug 3705333 changed from p_task_number to l_task_number
                ,X_NAME                       => la_task_name  --Bug 3705333 changed from p_task_namer to la_task_name
                ,X_DESCRIPTION            => l_task_DESCRIPTION
                ,X_STATUS_CODE            => l_STATUS_CODE
                ,X_WF_STATUS_CODE             => l_wf_status_code
                ,X_PM_PRODUCT_CODE            => l_PM_PRODUCT_CODE
                ,X_PM_TASK_REFERENCE          => l_PM_TASK_REFERENCE
                ,X_CLOSED_DATE            => l_CLOSED_DATE
                ,X_LOCATION_ID            => l_LOCATION_ID
                ,X_MANAGER_PERSON_ID        => l_task_MANAGER_ID
                ,X_CARRYING_OUT_ORGANIZATION_ID => l_carrying_out_org_id
                ,X_TYPE_ID                      => l_TYPE_ID
                ,X_PRIORITY_CODE              => l_PRIORITY_CODE
                ,X_INC_PROJ_PROGRESS_FLAG     => l_INC_PROJ_PROGRESS_FLAG
                ,X_REQUEST_ID                   => null --p_REQUEST_ID
                ,X_PROGRAM_APPLICATION_ID     => null --p_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_ID                   => null --p_PROGRAM_ID
                ,X_PROGRAM_UPDATE_DATE      => null --p_PROGRAM_UPDATE_DATE
                ,X_ATTRIBUTE_CATEGORY       => l_ATTRIBUTE_CATEGORY
                ,X_ATTRIBUTE1                   => l_ATTRIBUTE1
                ,X_ATTRIBUTE2                   => l_ATTRIBUTE2
                ,X_ATTRIBUTE3                   => l_ATTRIBUTE3
                ,X_ATTRIBUTE4                   => l_ATTRIBUTE4
                ,X_ATTRIBUTE5                   => l_ATTRIBUTE5
                ,X_ATTRIBUTE6                   => l_ATTRIBUTE6
                ,X_ATTRIBUTE7                   => l_ATTRIBUTE7
                ,X_ATTRIBUTE8                   => l_ATTRIBUTE8
                ,X_ATTRIBUTE9                   => l_ATTRIBUTE9
                ,X_ATTRIBUTE10            => l_ATTRIBUTE10
                ,X_ATTRIBUTE11            => l_ATTRIBUTE11
                ,X_ATTRIBUTE12            => l_ATTRIBUTE12
                ,X_ATTRIBUTE13            => l_ATTRIBUTE13
                ,X_ATTRIBUTE14            => l_ATTRIBUTE14
                ,X_ATTRIBUTE15            => l_ATTRIBUTE15
                ,X_TASK_WEIGHTING_DERIV_CODE => NULL
                ,X_WORK_ITEM_CODE            => l_work_item_code
                ,X_UOM_CODE                  => l_uom_code
                ,X_WQ_ACTUAL_ENTRY_CODE      => l_wq_actual_entry_code
                ,X_TASK_PROGRESS_ENTRY_PAGE_ID => l_task_progress_entry_page_id
                ,X_PHASE_VERSION_ID            => l_phase_version_id
                ,X_PHASE_CODE                  => l_phase_code
                ,X_PARENT_STRUCTURE_ID         => v_cur_proj_elems_rec.PARENT_STRUCTURE_ID
                ,X_RECORD_VERSION_NUMBER       => p_record_version_number
             ,x_Base_Perc_Comp_Deriv_Code   => l_Base_Perc_Comp_Deriv_Code
            -- Added for FP_M changes : 3305199
               -- Bug#3491609 : Workflow Chanegs FP M
                 ,x_wf_item_type    => p_wf_item_type
                 ,x_wf_process      => p_wf_process
                 ,x_wf_lead_days    => p_wf_lead_days
                 ,x_wf_enabled_flag => p_wf_enabled_flag
               -- Bug#3491609 : Workflow Chanegs FP M
             );
   ELSE
      CLOSE cur_proj_elems;
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INVALID_TASK_ID');
      l_msg_data := 'PA_PS_INVALID_TASK_ID';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- anlee
   -- Ext Attribute changes
   -- Bug 2904327

   PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
    p_validate_only             => FND_API.G_FALSE
   ,p_project_id                => v_cur_proj_elems_rec.project_id
   ,p_old_classification_id     => v_cur_proj_elems_rec.type_id
   ,p_new_classification_id     => l_type_id
   ,p_classification_type       => 'TASK_TYPE'
   ,x_return_status             => l_return_status
   ,x_msg_count                 => l_msg_count
   ,x_msg_data                  => l_msg_data );

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
     x_msg_count := l_msg_count;
     x_return_status := 'E';
     RAISE  FND_API.G_EXC_ERROR;
   END IF;
   -- anlee end of changes

   -- Bug 3075609. Moved here so that the processing is done after the
   -- task type for the task is updated.
   IF nvl(l_update_working_ver_weight,'N') = 'Y' THEN
        PA_TASK_PVT1.UPDATE_WORKING_VER_WEIGHT(
          p_task_id => p_task_id
         ,p_weighting => 0
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data);

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
           IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

   CLOSE cur_proj_elems;

--Since FORMS and AMG env. update pa_tasks explicity we do not need to
--call this apis again.
IF p_calling_module NOT IN ( 'FORMS', 'AMG' )
THEN
  --Get the structure id
  -- Bug 2827063 Moved the code to get the structure id up in the code because it is being accessed there
/*  OPEN cur_struc_id;
  FETCH cur_struc_id INTO l_structure_id;
  CLOSE cur_struc_id;
*/

  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
/*--Moved up for --bug 2789483
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;
--Moved up for --bug 2789483  */

--hsiu
--changes for versioning
/* --moved for bug 3010538 for performance
      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);
*/ --moved for bug 3010538 for performance

      -- Modified for FP_M changes
      -- Tracking Bug 3305199

      l_fin_task_flag := PA_Proj_Elements_Utils.CHECK_IS_FINANCIAL_TASK(P_Task_ID);

      IF (NVL( l_published_version, 'N' ) = 'N' and l_fin_task_flag = 'Y') OR
     (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y'  and l_fin_task_flag = 'Y')  -- Bug 3305199
     THEN
--      IF NVL( l_published_version, 'N' ) = 'N'
--      THEN
--end changes
          --The followig logic is added to support hierarchy change in PA_TASKS
          IF p_ref_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ref_task_id IS NOT NULL
          THEN
              sELECT wbs_level, parent_task_id, top_task_id
                INTO l_wbs_level, l_parent_task_id, l_top_task_id
                FROM pa_tasks
               WHERE task_id = p_ref_task_id;

               IF p_peer_or_sub = 'SUB'
               THEN
                  l_wbs_level := l_wbs_level + 1;
                  l_parent_task_id := p_ref_task_id;
               ELSE
                  l_wbs_level := l_wbs_level;
               END IF;

          ELSE
             --do not update
             l_parent_task_id := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
             l_top_task_id    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
             l_wbs_level      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
          END IF;
          -- xxlu added task DFF attributes
          -- xxlu added p_long_task_name

          -- avaithia ,Changed SUBSTR to SUBSTRB as SUBSTR doesnt provide Multi Language Support
          --           Included SUBSTRB for Task Description also ,because Task Description size
          --           is only 250 char in PA_TASKS Table ,whereas it can be upto 2000 char in pa_proj_elements
          --           These changes have been done for Bug 3935874

          PA_TASKS_MAINT_PUB.UPDATE_TASK
                   (
                   p_project_id                        => l_project_id
                  ,p_task_id                           => p_task_id
                  ,p_task_number                       => SUBSTRB( l_task_number, 1, 25 ) --Bug 3705333 changed from p_task_number to l_task_number
                  ,p_task_name                         => SUBSTRB( la_task_name, 1, 20 )  --Bug 3705333 changed from p_task_name to la_task_name
                  ,p_long_task_name                    => la_task_name --Bug 3705333 changed from p_task_name to la_task_nam
		  -- Bug#5227374.Corrected the substrb syntax below which was introduced thru Bug#3935874
                  ,p_task_description                  => SUBSTRB(l_task_DESCRIPTION,1,250) -- Bug 3935874
                  ,p_task_manager_person_id            => l_task_MANAGER_ID
                  ,p_carrying_out_organization_id      => l_carrying_out_org_id
                  ,p_task_type_code                    => l_TYPE_ID
                  ,p_priority_code                     => l_PRIORITY_CODE
                  ,p_pm_product_code                   => l_PM_PRODUCT_CODE
                  ,p_pm_task_reference                 => l_PM_TASK_REFERENCE
                  ,p_task_start_date                   => p_transaction_start_date
                  ,p_task_completion_date              => p_transaction_finish_date
                  ,p_inc_proj_progress_flag            => l_INC_PROJ_PROGRESS_FLAG
                  ,p_record_version_number             => p_record_version_number
                  ,p_wbs_record_version_number         => 1
                  ,p_top_task_id                       => l_top_task_id
                  ,p_parent_task_id                    => l_parent_task_id
                  ,p_wbs_level                         => l_wbs_level
                      ,p_address_id                        => p_address_id
                      ,p_work_type_id                      => p_work_type_id
                      ,p_service_type_code                 => p_service_type_code
                      ,p_chargeable_flag                   => p_chargeable_flag
                      ,p_billable_flag                     => p_billable_flag
                      ,p_receive_project_invoice_flag      => p_receive_project_invoice_flag
                      ,p_attribute_category                => l_tk_attribute_category
                      ,p_attribute1                        => l_tk_attribute1
                      ,p_attribute2                        => l_tk_attribute2
                      ,p_attribute3                        => l_tk_attribute3
                      ,p_attribute4                        => l_tk_attribute4
                      ,p_attribute5                        => l_tk_attribute5
                      ,p_attribute6                        => l_tk_attribute6
                      ,p_attribute7                        => l_tk_attribute7
                      ,p_attribute8                        => l_tk_attribute8
                      ,p_attribute9                        => l_tk_attribute9
                      ,p_attribute10                       => l_tk_attribute10
                  ,p_gen_etc_src_code                  => p_gen_etc_src_code
                  ,x_return_status                     => l_return_status
                  ,x_msg_count                         => l_msg_count
                  ,x_msg_data                          => l_msg_data );
                  -- end xxlu changes
      ELSE  --Added for transaction dates update
        --there is a publish version; update task that have financial attribute
    -- This code will excecute for fully shared and versioning enabled case
        IF (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(p_task_id) = 'Y') THEN
          -- xxlu add task DFF attributes
          --bug 3690807

          -- Changed SUBSTR to SUBSTRB for 3935874
          -- Also Truncated Description  to 250 chars as PA_TASKS can hold only upto 250 char description
          -- whereas l_task_description can be upto 2000 chars
          PA_TASKS_MAINT_PUB.UPDATE_TASK
                   (
                   p_project_id                        => l_project_id
                  ,p_task_id                           => p_task_id
                  ,p_task_number                       => SUBSTRB( l_task_NUMBER, 1, 25 ) --Bug 3705333 changed from p_task_number to l_task_number
                  ,p_task_name                         => SUBSTRB( la_task_NAME, 1, 20 ) --Bug 3705333 changed from p_task_name to la_task_name
                  ,p_long_task_name                    => la_task_name --Bug 3705333 changed from p_task_name to la_task_name
		  -- Bug#5227374.Corrected the substrb syntax below which was introduced thru Bug#3935874
                  ,p_task_description                  => SUBSTRB(l_task_DESCRIPTION,1,250) -- Bug 3935874
                  ,p_task_manager_person_id            => l_task_MANAGER_ID
                  ,p_carrying_out_organization_id      => l_carrying_out_org_id
                  ,p_task_type_code                    => l_TYPE_ID
                  ,p_priority_code                     => l_PRIORITY_CODE
                  ,p_pm_product_code                   => l_PM_PRODUCT_CODE
                  ,p_pm_task_reference                 => l_PM_TASK_REFERENCE
                  ,p_task_start_date                   => p_transaction_start_date
                  ,p_task_completion_date              => p_transaction_finish_date
                  ,p_inc_proj_progress_flag            => l_INC_PROJ_PROGRESS_FLAG
                  ,p_record_version_number             => p_record_version_number
                  ,p_wbs_record_version_number         => 1
--Commented for Bug 3746669                  ,p_top_task_id                       => l_top_task_id
--Commented for Bug 3746669                  ,p_parent_task_id                    => l_parent_task_id
--Commented for Bug 3746669                  ,p_wbs_level                         => l_wbs_level
                      ,p_address_id                        => p_address_id
                      ,p_work_type_id                      => p_work_type_id
                      ,p_service_type_code                 => p_service_type_code
                      ,p_chargeable_flag                   => p_chargeable_flag
                      ,p_billable_flag                     => p_billable_flag
                      ,p_receive_project_invoice_flag      => p_receive_project_invoice_flag
                      ,p_attribute_category                => l_tk_attribute_category
                      ,p_attribute1                        => l_tk_attribute1
                      ,p_attribute2                        => l_tk_attribute2
                      ,p_attribute3                        => l_tk_attribute3
                      ,p_attribute4                        => l_tk_attribute4
                      ,p_attribute5                        => l_tk_attribute5
                      ,p_attribute6                        => l_tk_attribute6
                      ,p_attribute7                        => l_tk_attribute7
                      ,p_attribute8                        => l_tk_attribute8
                      ,p_attribute9                        => l_tk_attribute9
                      ,p_attribute10                       => l_tk_attribute10
                  ,p_gen_etc_src_code                  => p_gen_etc_src_code
                  ,x_return_status                     => l_return_status
                  ,x_msg_count                         => l_msg_count
                  ,x_msg_data                          => l_msg_data );
          -- end xxlu changes
        END IF;
      END IF;
  END IF;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count = 1 then
      pa_interface_utils_pub.get_messages
      (p_encoded        => FND_API.G_TRUE,
       p_msg_index      => 1,
       p_msg_count      => l_msg_count,
       p_msg_data       => l_msg_data,
       p_data           => l_data,
       p_msg_index_out  => l_msg_index_out);
      x_msg_data := l_data;
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

END IF;  --<< p_calling_module >

   --hsiu task status change
   IF (l_task_status_changed = 'Y') THEN
     --task status can only be modified in the latest published version
     OPEN get_latest_task_ver_id;
     FETCH get_latest_task_ver_id INTO l_latest_task_ver_rec;
     CLOSE get_latest_task_ver_id;

     PA_PROGRESS_PUB.push_down_task_status(
        p_task_status => p_STATUS_CODE
       ,p_project_id => l_project_id
       ,p_object_id => p_task_id
       ,p_object_version_id => l_latest_task_ver_rec.element_version_id
       ,p_object_type => 'PA_TASKS'
       ,x_return_status => l_return_status
       ,x_msg_count => l_msg_count
       ,x_msg_data => l_msg_data
     );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_msg_count      => l_msg_count,
            p_msg_data       => l_msg_data,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
       END IF;
       raise FND_API.G_EXC_ERROR;
     END IF;

    --maansari
    IF PA_PROGRESS_UTILS.get_system_task_status( l_STATUS_CODE ) = 'CANCELLED'
    THEN
        PA_PROJ_ELEMENTS_UTILS.Check_chg_stat_cancel_ok (
                   p_task_id             => p_task_id
                  ,p_task_version_id     => l_latest_task_ver_rec.element_version_id
                  ,p_new_task_status     => l_STATUS_CODE
                  ,x_return_status       => l_return_status
                  ,x_error_message_code  => l_error_message_code
             );
       IF (l_return_status <> 'S') THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name => l_error_message_code);
           raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    PA_TASK_PVT1.set_new_tasks_to_TBD(
                p_project_id               => l_project_id
               ,p_task_id                  => p_task_id
               ,p_task_status              => l_STATUS_CODE
               ,x_return_status            => l_return_status
               ,x_msg_count                => l_msg_count
               ,x_msg_data                 => l_msg_data
         );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_msg_count      => l_msg_count,
            p_msg_data       => l_msg_data,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
       END IF;
       raise FND_API.G_EXC_ERROR;
     END IF;
    --maansari

     PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => l_latest_task_ver_rec.parent_structure_version_id
                 ,p_element_version_id => l_latest_task_ver_rec.element_version_id
                 ,x_return_status => l_return_status
                 ,x_msg_count => l_msg_count
                 ,x_msg_data => l_msg_data
                );
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_msg_count      => l_msg_count,
            p_msg_data       => l_msg_data,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
       END IF;
       raise FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   --end task status change

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'update_Task',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Update_Task;

-- API name                      : Create_Task_version
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_ref_task_version_id    IN  NUMBER  N   Not Null
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- p_task_id    IN  NUMBER  N   Not Null
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_task_version_id    OUT NUMBER  N   Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id  IN  NUMBER,
 p_peer_or_sub        IN    VARCHAR2,
 p_task_id              IN  NUMBER,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,
--bug 3301192
 p_financial_task_flag                IN VARCHAR2 := 'N',
--bug 3301192
 x_task_version_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_msg_data2                    PA_VC_1000_2000;
    l_return_status                VARCHAR2(2);
    l_error_message_code           VARCHAR2(250);

    l_parent_struc_ver_id          NUMBER;
    l_wbs_level                    NUMBER;
    l_display_sequence             NUMBER;
    l_wbs_number                   NUMBER;
    l_struc_version_from           NUMBER;
    l_task_version_from            NUMBER;
    l_relationship_subtype         VARCHAR2(20);
    l_relationship_id              NUMBER;

    l_link_task_flag               VARCHAR2(1);

    l_attribute_category         PA_PROJ_ELEMENT_VERSIONS.attribute_category%TYPE;
    l_attribute1                     PA_PROJ_ELEMENT_VERSIONS.attribute1%TYPE;
    l_attribute2                     PA_PROJ_ELEMENT_VERSIONS.attribute2%TYPE;
    l_attribute3                     PA_PROJ_ELEMENT_VERSIONS.attribute3%TYPE;
    l_attribute4                     PA_PROJ_ELEMENT_VERSIONS.attribute4%TYPE;
    l_attribute5                     PA_PROJ_ELEMENT_VERSIONS.attribute5%TYPE;
    l_attribute6                     PA_PROJ_ELEMENT_VERSIONS.attribute6%TYPE;
    l_attribute7                     PA_PROJ_ELEMENT_VERSIONS.attribute7%TYPE;
    l_attribute8                     PA_PROJ_ELEMENT_VERSIONS.attribute8%TYPE;
    l_attribute9                     PA_PROJ_ELEMENT_VERSIONS.attribute9%TYPE;
    l_attribute10                    PA_PROJ_ELEMENT_VERSIONS.attribute10%TYPE;
    l_attribute11                    PA_PROJ_ELEMENT_VERSIONS.attribute11%TYPE;
    l_attribute12                    PA_PROJ_ELEMENT_VERSIONS.attribute12%TYPE;
    l_attribute13                    PA_PROJ_ELEMENT_VERSIONS.attribute13%TYPE;
    l_attribute14                    PA_PROJ_ELEMENT_VERSIONS.attribute14%TYPE;
    l_attribute15                    PA_PROJ_ELEMENT_VERSIONS.attribute15%TYPE;
    l_weighting_percentage               PA_OBJECT_RELATIONSHIPS.weighting_percentage%TYPE;

   CURSOR cur_proj_elems
   IS
     SELECT *
       FROM pa_proj_element_versions
      WHERE element_version_id = p_ref_task_version_id;

   --Pick the max display sequence in the heirarchy of the reference task id.
   CURSOR cur_proj_elem_ver
   IS

/*  Bug 2680486 -- Performance changes -- Commented the following cursor query. Restructured it to
                   avoid hash join issue */

/*    SELECT max( b.display_sequence )
      FROM( SELECT object_id_to1
              FROM pa_object_relationships
             WHERE relationship_type = 'S'
        START WITH object_id_from1 = p_ref_task_version_id
        CONNECT BY object_id_from1 = PRIOR object_id_to1
               AND relationship_type = 'S'  ) a, pa_proj_element_versions b
     WHERE a.object_id_to1 = b.element_version_id;
*/
SELECT max( b.display_sequence )
      FROM pa_proj_element_versions b
     WHERE b.element_version_id IN
       ( SELECT object_id_to1
         FROM pa_object_relationships
         WHERE relationship_type = 'S'
         START WITH object_id_from1 = p_ref_task_version_id
         CONNECT BY object_id_from1 = PRIOR object_id_to1
         AND relationship_type = PRIOR relationship_type --bug 3919266
         AND relationship_type = 'S'  ) ;

      --WHERE object_id_from1 = p_ref_task_version_id
        --AND a.object_id_to1 = b.element_version_id;

   CURSOR cur_parent
   IS
     SELECT object_id_from1, object_type_from
       FROM pa_object_relationships
      WHERE object_id_to1 = p_ref_task_version_id
        AND relationship_type = 'S';
   CURSOR get_task_detail(cp_task_id NUMBER)
   IS
     SELECT base_percent_comp_deriv_code
       FROM pa_proj_elements
      WHERE proj_element_id = cp_task_id;

   X_ROW_ID   VARCHAR2(255);
   v_cur_proj_elems_rec cur_proj_elems%ROWTYPE;
   l_ref_seq_no   NUMBER;
   l_parent_id    NUMBER;
   l_parent_type  VARCHAR2(20);
   l_structure_id_to   NUMBER;
   l_structure_id_from NUMBER;
   l_base_deriv_code   VARCHAR2(30);
   l_ref_parent_task_ver_id  NUMBER;   --Bug No 3475920
BEGIN

--my_error_msg( 'In create_task_version pvt API' );
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PVT1.CREATE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_TASK_VER_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF ( p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL )
    THEN
       l_attribute_category := null;
    ELSE
       l_attribute_category := p_attribute_category;
    END IF;

    IF ( p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL )
    THEN
       l_attribute1 := null;
    ELSE
       l_attribute1 := p_attribute1;
    END IF;

    IF ( p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL )
    THEN
       l_attribute2 := null;
    ELSE
       l_attribute2 := p_attribute2;
    END IF;

    IF ( p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL )
    THEN
       l_attribute3 := null;
    ELSE
       l_attribute3 := p_attribute3;
    END IF;

    IF ( p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL )
    THEN
       l_attribute4 := null;
    ELSE
       l_attribute4 := p_attribute4;
    END IF;

    IF ( p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL )
    THEN
       l_attribute5 := null;
    ELSE
       l_attribute5 := p_attribute5;
    END IF;

    IF ( p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL )
    THEN
       l_attribute6 := null;
    ELSE
       l_attribute6 := p_attribute6;
    END IF;

    IF ( p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL )
    THEN
       l_attribute7 := null;
    ELSE
       l_attribute7 := p_attribute7;
    END IF;

    IF ( p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL )
    THEN
       l_attribute8 := null;
    ELSE
       l_attribute8 := p_attribute8;
    END IF;

    IF ( p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL )
    THEN
       l_attribute9 := null;
    ELSE
       l_attribute9 := p_attribute9;
    END IF;

    IF ( p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL )
    THEN
       l_attribute10 := null;
    ELSE
       l_attribute10 := p_attribute10;
    END IF;

    IF ( p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL )
    THEN
       l_attribute11 := null;
    ELSE
       l_attribute11 := p_attribute11;
    END IF;

    IF ( p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL )
    THEN
       l_attribute12 := null;
    ELSE
       l_attribute12 := p_attribute12;
    END IF;

    IF ( p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL )
    THEN
       l_attribute13 := null;
    ELSE
       l_attribute13 := p_attribute13;
    END IF;

    IF ( p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL )
    THEN
       l_attribute14 := null;
    ELSE
       l_attribute14 := p_attribute14;
    END IF;

    IF ( p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL )
    THEN
       l_attribute15 := null;
    ELSE
       l_attribute15 := p_attribute15;
    END IF;

    IF ( p_weighting_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_weighting_percentage IS NULL )
    THEN
       l_weighting_percentage := null;
    ELSE
       l_weighting_percentage := p_weighting_percentage;
    END IF;

----dbms_output.put_line( 'In private API' );
--
--
   --Bug No 3450684 Smukka 04/Mar/04 Checking for deliverable
   --Bug No 3475920
   IF p_peer_or_sub = 'PEER' THEN
      l_ref_parent_task_ver_id:=PA_PROJ_ELEMENTS_UTILS.GET_PARENT_TASK_VERSION_ID(p_ref_task_version_id);
   ELSE
      l_ref_parent_task_ver_id:=p_ref_task_version_id;
   END IF;
   --Bug No 3475920
   OPEN get_task_detail(p_task_id);
   FETCH get_task_detail INTO l_base_deriv_code;
   CLOSE get_task_detail;
   IF l_base_deriv_code LIKE 'DELIVERABLE' THEN
      IF PA_PROJ_ELEMENTS_UTILS.check_task_parents_deliv(l_ref_parent_task_ver_id) = 'Y' THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name => 'PA_TASK_AND_PARENTTASK_DEL');
         raise FND_API.G_EXC_ERROR;
      END IF;
   END IF;
--
--
--my_error_msg( 'In create_task_version pvt API Stage 2' );
   OPEN cur_proj_elems;
   FETCH cur_proj_elems INTO v_cur_proj_elems_rec;
   IF cur_proj_elems%FOUND
   THEN

    /*As 4046026 code fix is not correct,Commenting the code fix and restoring the old code
      Actually this code fix is the cause of Bug 4057190*/
 /* Uncommenting the code below again as the issue was due a missing nvl **/
     /** Code added for Bug  4046026 **/
    OPEN cur_proj_elem_ver;
    FETCH cur_proj_elem_ver INTO l_display_sequence;
    CLOSE cur_proj_elem_ver;
    /** Code addition end for Bug  4046026 **/

    /*As 4046026 code fix is not correct,Commented it : Bug 4057190*/
    /* Uncommented the code again **/
      IF v_cur_proj_elems_rec.object_type = 'PA_STRUCTURES'
      THEN
          --Top level first task version under 'p_ref_task_version_id' structure version id
          l_parent_struc_ver_id := p_ref_task_version_id;
          l_wbs_level           := 1;
          /*  Commented for Bug 4057190 --Uncommented again*/
          l_ref_seq_no          := nvl(l_display_sequence,0); -- Added for Performace Bug 4046026

          l_display_sequence    :=   nvl(l_display_sequence,0) + 1; --  Restored to 1 4057190 --Modified for Performace Bug 4046026 from 1 to nvl(l_display_sequence,0) + 1
          l_wbs_number          := null;
          l_struc_version_from  := p_ref_task_version_id;
          l_task_version_from   := null;
          l_relationship_subtype := 'STRUCTURE_TO_TASK';
         -- l_ref_seq_no          := 0;  -- increment all task seq. numbers.Restored for 4057190 --Commented for BUg 4046026

          l_structure_id_from := v_cur_proj_elems_rec.proj_element_id;
          l_structure_id_to := v_cur_proj_elems_rec.proj_element_id;

--dbms_output.put_line( 'In IF condition' );

      ELSIF v_cur_proj_elems_rec.object_type = 'PA_TASKS'
      THEN
          --If the task version is not a top level within the structure version

          l_parent_struc_ver_id := v_cur_proj_elems_rec.parent_structure_version_id;

          SELECT proj_element_id INTO l_structure_id_from
            FROM pa_proj_element_versions
           WHERE element_version_id = v_cur_proj_elems_rec.parent_structure_version_id;

           l_structure_id_to := l_structure_id_from;

          IF p_peer_or_sub = 'PEER'
          THEN
             l_wbs_level           := v_cur_proj_elems_rec.wbs_level;
             --If a task is created as PEER then it should land after the child task of the reference.
             OPEN cur_proj_elem_ver;
             FETCH cur_proj_elem_ver INTO l_ref_seq_no;
             CLOSE cur_proj_elem_ver;

             IF l_ref_seq_no IS NULL
             THEN
                --If there are no child task for ref task then the new task should be created imm. after the ref task.
                l_ref_seq_no := v_cur_proj_elems_rec.display_sequence;
             END IF;

             l_display_sequence    := l_ref_seq_no + 1;

             --get the parent of the ref task id.
             OPEN cur_parent;
             FETCH cur_parent INTO l_parent_id, l_parent_type;
             CLOSE cur_parent;

             --hsiu: bug 2695631
             --copy structure version should not validate when creating tasks
             IF (p_validation_level <> 0) THEN
               PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
                 p_parent_task_ver_id => l_parent_id
                ,x_return_status      => l_return_status
                ,x_error_message_code => l_error_message_code
               );

               IF (l_return_status <> 'Y') THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name => l_error_message_code);
                 raise FND_API.G_EXC_ERROR;
               END IF;
             END IF;
             --end bug 2695631


          ELSE
    -- 4057190 : restored old code here and removed code fix for 4046026
     /** Changes begin for performance BUg 4046026 when subtask is added to a task with no child tasks
        In this l_display_sequenec will be null and hence should be set with refernce to the top task */
        /** restored the fix for BUg 4046026 **/
        IF l_display_sequence IS NULL then
        l_wbs_level           := v_cur_proj_elems_rec.wbs_level + 1;
        l_ref_seq_no            := v_cur_proj_elems_rec.display_sequence;
            l_display_sequence    := v_cur_proj_elems_rec.display_sequence + 1;
            Else
             l_wbs_level           := v_cur_proj_elems_rec.wbs_level + 1;
         l_ref_seq_no          := v_cur_proj_elems_rec.display_sequence;
             l_display_sequence    := v_cur_proj_elems_rec.display_sequence + 1;
            End if; /** Changes end for performance BUg 4046026  */
             --hsiu: bug 2695631
             --copy structure version should not validate when creating tasks
             IF (p_validation_level <> 0) THEN
               PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
                 p_parent_task_ver_id => p_ref_task_version_id
                ,x_return_status      => l_return_status
                ,x_error_message_code => l_error_message_code
               );

               IF (l_return_status <> 'Y') THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name => l_error_message_code);
                 raise FND_API.G_EXC_ERROR;
               END IF;
             END IF;
             --end bug 2695631
          END IF;

          l_wbs_number          := null;

          IF l_parent_id IS NOT NULL AND p_peer_or_sub = 'PEER'
          THEN
             IF l_parent_type = 'PA_STRUCTURES'
             THEN
                l_struc_version_from  := l_parent_id;
                l_task_version_from   := null;
                l_relationship_subtype := 'STRUCTURE_TO_TASK';
             ELSE
                l_struc_version_from  := null;
                l_task_version_from   := l_parent_id;
                l_relationship_subtype := 'TASK_TO_TASK';
             END IF;
          ELSE
             l_struc_version_from  := null;
             l_task_version_from   := p_ref_task_version_id;
             l_relationship_subtype := 'TASK_TO_TASK';
          END IF;
      END IF;

      --Display sequence is null if the task is a linking task.
      l_link_task_flag := PA_PROJ_ELEMENTS_UTILS.link_flag ( p_task_id );
      IF l_link_task_flag = 'Y'
      THEN
         l_DISPLAY_SEQUENCE := null;
      END IF;

--dbms_output.put_line( 'before Insert' );

--my_error_msg( 'In create_task_version pvt API Stage 3' );


      PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row(
            X_ROW_ID                   => X_row_id
           ,X_ELEMENT_VERSION_ID       => x_task_version_id
           ,X_PROJ_ELEMENT_ID            => p_task_id
           ,X_OBJECT_TYPE            => 'PA_TASKS'
           ,X_PROJECT_ID             => v_cur_proj_elems_rec.project_id
           ,X_PARENT_STRUCTURE_VERSION_ID   => l_parent_struc_ver_id
           ,X_DISPLAY_SEQUENCE     => l_DISPLAY_SEQUENCE
           ,X_WBS_LEVEL                => l_WBS_LEVEL
           ,X_WBS_NUMBER             => l_WBS_NUMBER
           ,X_ATTRIBUTE_CATEGORY       => l_ATTRIBUTE_CATEGORY
           ,X_ATTRIBUTE1             => l_ATTRIBUTE1
           ,X_ATTRIBUTE2             => l_ATTRIBUTE2
           ,X_ATTRIBUTE3             => l_ATTRIBUTE3
           ,X_ATTRIBUTE4             => l_ATTRIBUTE4
           ,X_ATTRIBUTE5             => l_ATTRIBUTE5
           ,X_ATTRIBUTE6             => l_ATTRIBUTE6
           ,X_ATTRIBUTE7             => l_ATTRIBUTE7
           ,X_ATTRIBUTE8             => l_ATTRIBUTE8
           ,X_ATTRIBUTE9             => l_ATTRIBUTE9
           ,X_ATTRIBUTE10            => l_ATTRIBUTE10
           ,X_ATTRIBUTE11            => l_ATTRIBUTE11
           ,X_ATTRIBUTE12            => l_ATTRIBUTE12
           ,X_ATTRIBUTE13            => l_ATTRIBUTE13
           ,X_ATTRIBUTE14            => l_ATTRIBUTE14
           ,X_ATTRIBUTE15            => l_ATTRIBUTE15
           ,X_TASK_UNPUB_VER_STATUS_CODE => p_task_unpub_ver_status_code
       ,p_financial_task_flag    => p_financial_task_flag   -- FP_M changes 3305199
           ,X_SOURCE_OBJECT_ID      => v_cur_proj_elems_rec.project_id
           ,X_SOURCE_OBJECT_TYPE    => 'PA_PROJECTS'
       );

--dbms_output.put_line( 'Before update sequence' );

--my_error_msg( 'In create_task_version pvt API Stage 4' );

/*Removed the following IF  Clause for Bug 4057190
  Actually ,This fix done for 4046026 is wrong .hence the commenting*/
  /** Uncommenting the code again **/

IF l_wbs_level <> 1 THEN

--This IF/ELSE condition is added for BUg 4046026.
           --update the sequnce number
      UPDATE pa_proj_element_versions
         SET display_sequence = display_sequence + 1
       WHERE display_sequence > l_ref_seq_no
         AND element_version_id <> x_task_version_id
         AND parent_structure_version_id = v_cur_proj_elems_rec.parent_structure_version_id
         AND object_type = 'PA_TASKS'
        -- AND PA_PROJ_ELEMENTS_UTILS.link_flag ( proj_element_id ) = 'N' commenitng out for bug 4180390
         ;
ELSE
 IF  p_peer_or_sub = 'PEER' --Bug 4046026
      THEN
       UPDATE pa_proj_element_versions
         SET display_sequence = display_sequence + 1
       WHERE display_sequence > l_ref_seq_no
         AND element_version_id <> x_task_version_id
         AND parent_structure_version_id = v_cur_proj_elems_rec.parent_structure_version_id
         AND object_type = 'PA_TASKS'
         --AND PA_PROJ_ELEMENTS_UTILS.link_flag ( proj_element_id ) = 'N' commenitng out for bug 4180390
         ;
END IF;
END IF; --Added for Bug 4046026 Commented for 4057190 /** Uncommented it again for BUg 4046026 **/

--dbms_output.put_line( 'Before create relationship' );

--dbms_output.put_line( 'l_struc_version_from '||l_struc_version_from );
--dbms_output.put_line( 'l_task_version_from '||l_task_version_from );
--dbms_output.put_line( 'x_task_version_id '||x_task_version_id );
--dbms_output.put_line( 'l_relationship_subtype '||l_relationship_subtype );

--my_error_msg( 'In create_task_version pvt API Stage 5' );


     --create new relationship
      PA_RELATIONSHIP_PUB.Create_Relationship
                       (
                     p_api_version                       => p_api_version
                    ,p_init_msg_list                     => p_init_msg_list
                    ,p_commit                            => p_commit
                    ,p_validate_only                     => p_validate_only
                    ,p_validation_level                  => p_validation_level
                    ,p_calling_module                    => p_calling_module
                    ,p_debug_mode                        => p_debug_mode
                    ,p_max_msg_count                     => p_max_msg_count
                    ,p_project_id_from                   => v_cur_proj_elems_rec.project_id
                    ,p_structure_id_from                 => l_structure_id_from
                    ,p_structure_version_id_from         => l_struc_version_from
                    ,p_task_version_id_from              => l_task_version_from
                    ,p_project_id_to                     => v_cur_proj_elems_rec.project_id
                    ,p_structure_id_to                   => l_structure_id_to
                    ,p_task_version_id_to                => x_task_version_id
                    ,p_structure_type                    => null
                    ,p_initiating_element                => null
                    ,p_relationship_type                 => 'S'
                    ,p_relationship_subtype              => l_relationship_subtype
                    ,p_weighting_percentage              => l_weighting_percentage
                    ,x_object_relationship_id            => l_relationship_id
                    ,x_return_status                     => x_return_status
                    ,x_msg_count                         => x_msg_count
                    ,x_msg_data                          => x_msg_data
                 );

--dbms_output.put_line( 'x_return_status from create rel '||x_return_status );

           IF x_return_status <> 'S'
           THEN
--dbms_output.put_line( 'raising exception' );
              CLOSE cur_proj_elems;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

--dbms_output.put_line( 'Before WBS_NUMBER' );

      --Do not update wbs_number if the task is a linking task.
      IF l_link_task_flag = 'N'
      THEN
--my_error_msg( 'In create_task_version pvt API Stage 6' );

          PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS (
                               p_commit                   => p_commit
                              ,p_debug_mode               => p_debug_mode
                              ,p_parent_structure_ver_id  => l_parent_struc_ver_id
                              ,p_task_id                  => x_task_version_id
                              ,p_display_seq              => l_display_sequence
                              ,p_action                   => 'INSERT'
                              ,p_parent_task_id           => l_task_version_from
                              ,x_return_status            => x_return_status );
      END IF;

           IF x_return_status <> 'S'
           THEN
              CLOSE cur_proj_elems;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

   ELSE
      CLOSE cur_proj_elems;
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INV_REF_TASK_ID');
      l_msg_data := 'PA_PS_INV_REF_TASK_ID';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE cur_proj_elems;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--my_error_msg( 'In create_task_version pvt API Stage 7' );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_VER_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;

--       --dbms_output.put_line( 'In exception ');
--       --dbms_output.put_line( 'Status In exception ' ||x_return_status);


    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_VER_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'create_Task_version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Create_Task_Version;

-- API name                      : Update_Task_version
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id    IN  NUMBER  N   Null
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_record_version_number  IN  NUMBER
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Update_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id  IN  NUMBER,
 p_peer_or_sub        IN    VARCHAR2,
 p_task_version_id  IN  NUMBER,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_record_version_number    IN  NUMBER,
 p_action          IN    VARCHAR2 := 'NULL',
 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                     VARCHAR2(250);

    l_error_message_code           VARCHAR2(250);

    l_parent_struc_ver_id          NUMBER;
    l_wbs_level                    NUMBER;
    l_display_sequence             NUMBER;
    l_wbs_number                   NUMBER;

    l_struc_version_from           NUMBER;
    l_task_version_from            NUMBER;
    l_relationship_subtype         VARCHAR2(20);
    l_relationship_id              NUMBER;

    l_wbs_level_diff               NUMBER;

    l_attribute_category         PA_PROJ_ELEMENT_VERSIONS.attribute_category%TYPE;
    l_attribute1                     PA_PROJ_ELEMENT_VERSIONS.attribute1%TYPE;
    l_attribute2                     PA_PROJ_ELEMENT_VERSIONS.attribute2%TYPE;
    l_attribute3                     PA_PROJ_ELEMENT_VERSIONS.attribute3%TYPE;
    l_attribute4                     PA_PROJ_ELEMENT_VERSIONS.attribute4%TYPE;
    l_attribute5                     PA_PROJ_ELEMENT_VERSIONS.attribute5%TYPE;
    l_attribute6                     PA_PROJ_ELEMENT_VERSIONS.attribute6%TYPE;
    l_attribute7                     PA_PROJ_ELEMENT_VERSIONS.attribute7%TYPE;
    l_attribute8                     PA_PROJ_ELEMENT_VERSIONS.attribute8%TYPE;
    l_attribute9                     PA_PROJ_ELEMENT_VERSIONS.attribute9%TYPE;
    l_attribute10                    PA_PROJ_ELEMENT_VERSIONS.attribute10%TYPE;
    l_attribute11                    PA_PROJ_ELEMENT_VERSIONS.attribute11%TYPE;
    l_attribute12                    PA_PROJ_ELEMENT_VERSIONS.attribute12%TYPE;
    l_attribute13                    PA_PROJ_ELEMENT_VERSIONS.attribute13%TYPE;
    l_attribute14                    PA_PROJ_ELEMENT_VERSIONS.attribute14%TYPE;
    l_attribute15                    PA_PROJ_ELEMENT_VERSIONS.attribute15%TYPE;
    l_task_unpub_ver_status_code         PA_PROJ_ELEMENT_VERSIONS.task_unpub_ver_status_code%TYPE;

   CURSOR cur_ref_task
   IS
     SELECT *
       FROM pa_proj_element_versions
      WHERE element_version_id = p_ref_task_version_id;


   CURSOR cur_proj_elems
   IS
     SELECT rowid, object_type, project_id, proj_element_id, record_version_number,
            display_sequence, wbs_number, wbs_level, parent_structure_version_id,
            attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5,
            attribute6, attribute7, attribute8, attribute9, attribute10, attribute11, attribute12,
            attribute13, attribute14, attribute15, TASK_UNPUB_VER_STATUS_CODE
       FROM pa_proj_element_versions
      WHERE element_version_id = p_task_version_id
        AND object_type = 'PA_TASKS';

    CURSOR cur_child_tasks( c_task_version_id NUMBER )
    IS SELECT a.object_id_from1, a.object_id_to1, b.parent_structure_version_id, b.display_sequence
         FROM
      ( SELECT object_id_from1, object_id_to1
          FROM pa_object_relationships
         WHERE relationship_type = 'S'
    START WITH object_id_from1 = c_task_version_id
    CONNECT BY object_id_from1 = PRIOR object_id_to1
           AND relationship_type = prior relationship_type --bug 3919266
           AND relationship_type = 'S' ) a, pa_proj_element_versions b
    WHERE a.object_id_to1 = b.element_version_id
    ORDER BY 4;

--bug 2832807
    CURSOR cur_child_tasks2( c_task_version_id NUMBER )
    IS SELECT max( display_sequence )
         FROM pa_proj_element_versions
    WHERE element_version_id in ( SELECT object_id_to1
                                    FROM pa_object_relationships
                                   WHERE relationship_type = 'S'
                                 START WITH object_id_from1 = c_task_version_id
                                  CONNECT BY object_id_from1 = PRIOR object_id_to1
                                         AND relationship_type = PRIOR relationship_type --bug 3919266
                                         AND relationship_type = 'S'  );
--bug 2832807

--bug 2836264
    CURSOR cur_child_tasks3( c_task_version_id NUMBER ,c_ref_task_disp_seq NUMBER)  -- Bug 6628382 modified existing cursor to restrict the tasks which are being moved to fall between the source and the destination task
    IS SELECT max( display_sequence )
         FROM pa_proj_element_versions
    WHERE element_version_id in ( SELECT object_id_to1
                                    FROM pa_object_relationships
                                   WHERE relationship_type = 'S'
                                     and object_id_to1 <> p_task_version_id
                                 START WITH object_id_from1 = c_task_version_id
                                  CONNECT BY object_id_from1 = PRIOR object_id_to1 --bug 3919266
                                         AND relationship_type = prior relationship_type
                                         AND relationship_type = 'S'  )
                                         AND display_sequence <= c_ref_task_disp_seq;    -- Bug 6628382
--bug 2836264

    --Added for Bug 6628382
    CURSOR cur_child_tasks4( c_task_version_id NUMBER)     -- Bug 6628382. Added another cursor to compute the last child task of any task.
    IS SELECT max( display_sequence)
         FROM pa_proj_element_versions
    WHERE element_version_id in ( SELECT object_id_to1
                                    FROM pa_object_relationships
                                   WHERE relationship_type = 'S'
                                     and object_id_to1 <> p_task_version_id
                                 START WITH object_id_from1 = c_task_version_id
                                  CONNECT BY object_id_from1 = PRIOR object_id_to1 --bug 3919266
                                         AND relationship_type = prior relationship_type
                                         AND relationship_type = 'S'  );


  --This cursor is used to find parent task version id of the reference task id or
  --to get the object rel id and record version number of the task version id.
  CURSOR cur_obj_rel( p_child_version_id NUMBER )
  IS
    SELECT object_id_from1, object_relationship_id, record_version_number, relationship_subtype
      FROM pa_object_relationships
     WHERE object_id_to1 = p_child_version_id
       AND relationship_type = 'S';

  --This cursor fetches all tasks that are child of ref task but now become child of p_task_version
  CURSOR cur_new_child
  IS
    SELECT por.object_id_to1, ppev.display_sequence, por.record_version_number, por.object_relationship_id
      FROM pa_object_relationships por,
           pa_proj_element_versions ppev
     WHERE object_id_from1 = p_ref_task_version_id
       AND object_id_to1 = element_version_id
       AND display_sequence > l_display_sequence
       AND relationship_type = 'S'
     order by display_sequence;

v_cur_proj_elems_rec cur_proj_elems%ROWTYPE;
v_cur_ref_task_rec cur_ref_task%ROWTYPE;
v_cur_obj_rel_rec cur_obj_rel%ROWTYPE;
l_update_new_child_rels  VARCHAR2(1) := 'N';

l_task_seq_num                           NUMBER;
l_ref_task_seq_num                       NUMBER;
l_task_last_child_seq_num                NUMBER;
l_ref_task_last_child_seq_num            NUMBER;
l_ref_task_last_child_seq_num2           NUMBER;  -- Bug 6628382


l_new_display_sequence         NUMBER;

l_move_direction             VARCHAR2(4);
l_no_of_tasks                NUMBER;
l_parent_of_task_version     NUMBER;

--hsiu added
--for task weighting
cursor get_task_weighting(c_task_version_id NUMBER) IS
  select a.object_id_from1, a.weighting_percentage
    from pa_object_relationships a
   where a.object_id_to1 = c_task_version_id
     and a.object_type_to = 'PA_TASKS'
     and a.relationship_type = 'S'
     and a.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');
l_old_parent_id   NUMBER;

-- anlee task weighting changes
cursor get_sub_tasks(c_task_version_id NUMBER) IS
  select '1'
    from pa_object_relationships
   where object_id_from1 = c_task_version_id
     and object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
     and relationship_type = 'S';
  l_dummy varchar2(1);

l_version_from NUMBER;
-- end anlee

l_new_weighting NUMBER(17,2);
l_old_weighting NUMBER(17,2);
--end task weighting changes

  --bug 2673570
  CURSOR check_progress_allowed(c_element_version_id NUMBER)
  IS
  SELECT ptt.prog_entry_enable_flag
  FROM   pa_task_types ptt,
         pa_proj_element_versions ppev,
         pa_proj_elements ppe
  WHERE  ppev.element_version_id = c_element_version_id
  AND    ppev.proj_element_id = ppe.proj_element_id
  AND    ppe.TYPE_ID   = ptt.task_type_id;

  l_progress_allowed  VARCHAR2(1);
  --bug 2673570

BEGIN
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PVT1.UPDATE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_TASK_VER_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --Bug No 3450684 Smukka 04/Mar/04 Checking for deliverable
    --Bug No 3475920 SMukka Commented out following logic to check for deliverable.
--    IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id,p_task_version_id) = 'Y' THEN
--    IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id,p_ref_task_version_id) = 'Y' THEN
--       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                            p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
--       raise FND_API.G_EXC_ERROR;
--    END IF;

 OPEN cur_ref_task;
 FETCH cur_ref_task INTO v_cur_ref_task_rec;

   OPEN cur_proj_elems;
   FETCH cur_proj_elems INTO v_cur_proj_elems_rec;
   IF cur_proj_elems%FOUND
   THEN
      if v_cur_proj_elems_rec.record_version_number <> p_record_version_number
      then
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.Raise_Exception;
      end if;

      IF ( p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL )
      THEN
         l_attribute_category := v_cur_proj_elems_rec.attribute_category;
      ELSE
         l_attribute_category := p_attribute_category;
      END IF;

      IF ( p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL )
      THEN
         l_attribute1 := v_cur_proj_elems_rec.attribute1;
      ELSE
         l_attribute1 := p_attribute1;
      END IF;

      IF ( p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL )
      THEN
         l_attribute2 := v_cur_proj_elems_rec.attribute2;
      ELSE
         l_attribute2 := p_attribute2;
      END IF;

      IF ( p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL )
      THEN
         l_attribute3 := v_cur_proj_elems_rec.attribute3;
      ELSE
         l_attribute3 := p_attribute3;
      END IF;

      IF ( p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL )
      THEN
         l_attribute4 := v_cur_proj_elems_rec.attribute4;
      ELSE
         l_attribute4 := p_attribute4;
      END IF;

      IF ( p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL )
      THEN
         l_attribute5 := v_cur_proj_elems_rec.attribute5;
      ELSE
         l_attribute5 := p_attribute5;
      END IF;

      IF ( p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL )
      THEN
         l_attribute6 := v_cur_proj_elems_rec.attribute6;
      ELSE
         l_attribute6 := p_attribute6;
      END IF;

      IF ( p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL )
      THEN
         l_attribute7 := v_cur_proj_elems_rec.attribute7;
      ELSE
         l_attribute7 := p_attribute7;
      END IF;

      IF ( p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL )
      THEN
         l_attribute8 := v_cur_proj_elems_rec.attribute8;
      ELSE
         l_attribute8 := p_attribute8;
      END IF;

      IF ( p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL )
      THEN
         l_attribute9 := v_cur_proj_elems_rec.attribute9;
      ELSE
         l_attribute9 := p_attribute9;
      END IF;

      IF ( p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL )
      THEN
         l_attribute10 := v_cur_proj_elems_rec.attribute10;
      ELSE
         l_attribute10 := p_attribute10;
      END IF;

      IF ( p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL )
      THEN
         l_attribute11 := v_cur_proj_elems_rec.attribute11;
      ELSE
         l_attribute11 := p_attribute11;
      END IF;

      IF ( p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL )
      THEN
         l_attribute12 := v_cur_proj_elems_rec.attribute12;
      ELSE
         l_attribute12 := p_attribute12;
      END IF;

      IF ( p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL )
      THEN
         l_attribute13 := v_cur_proj_elems_rec.attribute13;
      ELSE
         l_attribute13 := p_attribute13;
      END IF;

      IF ( p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL )
      THEN
         l_attribute14 := v_cur_proj_elems_rec.attribute14;
      ELSE
         l_attribute14 := p_attribute14;
      END IF;

      IF ( p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL )
      THEN
         l_attribute15 := v_cur_proj_elems_rec.attribute15;
      ELSE
         l_attribute15 := p_attribute15;
      END IF;

      IF (p_task_unpub_ver_status_code IS NULL) THEN
        l_task_unpub_ver_status_code := v_cur_proj_elems_rec.TASK_UNPUB_VER_STATUS_CODE;
      ELSE
        l_task_unpub_ver_status_code := p_task_unpub_ver_status_code;
      END IF;

      l_task_seq_num := v_cur_proj_elems_rec.display_sequence;
      l_ref_task_seq_num := v_cur_ref_task_rec.display_sequence;

      IF l_task_seq_num > l_ref_task_seq_num
      THEN
         l_move_direction := 'UP';
      ELSIF l_task_seq_num < l_ref_task_seq_num
      THEN
         l_move_direction := 'DOWN';
      END IF;

--dbms_output.put_line( 'p_action '|| p_action );


      IF v_cur_ref_task_rec.object_type = 'PA_TASKS'           --Moving under a task
      THEN
         IF p_peer_or_sub = 'PEER'
         THEN
            l_wbs_level := v_cur_ref_task_rec.wbs_level;  --wbs level of reference

            --parent task is the parent of the reference task
            OPEN cur_obj_rel( p_ref_task_version_id );
            FETCH cur_obj_rel INTO v_cur_obj_rel_rec;
            CLOSE cur_obj_rel;

            l_relationship_subtype := v_cur_obj_rel_rec.relationship_subtype;

            IF v_cur_obj_rel_rec.relationship_subtype = 'STRUCTURE_TO_TASK'
            THEN
                l_struc_version_from := v_cur_obj_rel_rec.object_id_from1;
                l_task_version_from := null;
            ELSE
                l_task_version_from  := v_cur_obj_rel_rec.object_id_from1;
                l_struc_version_from := null;
            END IF;

            --There could be some tasks with sequence number greater than the p_task_version that now become
            --children of p_task_version.
            l_update_new_child_rels := 'Y';

            IF p_action = 'MOVE'
            THEN
               --get the seq of the last child of ref task
--               FOR cur_child_tasks_rec2 IN cur_child_tasks( p_ref_task_version_id )  LOOP  --commented out for bug 2832807
                  /* IF l_move_direction = 'UP'
                   THEN
                       IF cur_child_tasks_rec2.display_sequence < l_task_seq_num
                       THEN
                          l_ref_task_last_child_seq_num := cur_child_tasks_rec2.display_sequence;
                       END IF;
                   ELSE*/
--                      l_ref_task_last_child_seq_num := cur_child_tasks_rec2.display_sequence; --commented out for bug 2832807
                  -- END IF;
--               END LOOP;   --commented out for bug 2832807

               --bug 2832807
               IF (p_peer_or_sub = 'SUB') THEN
                 OPEN cur_child_tasks2(p_ref_task_version_id);
                 FETCH cur_child_tasks2 INTO l_ref_task_last_child_seq_num;
                 CLOSE cur_child_tasks2;
               ELSE
                 --bug 2836364
                 OPEN cur_child_tasks4(p_ref_task_version_id);       -- Bug 6628382
                 FETCH cur_child_tasks4 INTO l_ref_task_last_child_seq_num2;
                 CLOSE cur_child_tasks4;

                 OPEN cur_child_tasks3(v_cur_obj_rel_rec.object_id_from1,nvl(l_ref_task_last_child_seq_num2, l_ref_task_seq_num));  -- Bug 6628382
                 FETCH cur_child_tasks3 INTO l_ref_task_last_child_seq_num;
                 CLOSE cur_child_tasks3;
                 --bug 2836364
               END IF;
               --bug 2832807

               --If the reference task does not have any child tasks then
               --l_ref_task_last_child_seq_num will be l_ref_task_seq_num;
               IF l_ref_task_last_child_seq_num IS NULL
               THEN
                   l_ref_task_last_child_seq_num := l_ref_task_seq_num;
               END IF;

               l_new_display_sequence := - ( ( l_ref_task_last_child_seq_num ) + 1 );
--dbms_output.put_line( 'l_new_display_sequence '|| l_new_display_sequence );
--dbms_output.put_line( 'l_ref_task_last_child_seq_num '|| l_ref_task_last_child_seq_num );

            ELSE
               l_new_display_sequence := v_cur_proj_elems_rec.display_sequence;
            END IF; --<< p_action = 'MOVE' >>

         ELSE
            l_wbs_level := v_cur_ref_task_rec.wbs_level + 1;
            --parent task is the reference task
            l_task_version_from  := p_ref_task_version_id;
            l_struc_version_from := null;
            l_relationship_subtype := 'TASK_TO_TASK';

            IF p_action = 'MOVE'
            THEN
               l_new_display_sequence := - ( l_ref_task_seq_num + 1 );
            ELSE
               l_new_display_sequence := v_cur_proj_elems_rec.display_sequence;
            END IF; --<< p_action = 'MOVE' >>

--dbms_output.put_line( 'l_new_display_sequence '|| l_new_display_sequence );
--dbms_output.put_line( 'l_ref_task_last_child_seq_num '|| l_ref_task_last_child_seq_num );

         END IF;
      ELSIF v_cur_ref_task_rec.object_type = 'PA_STRUCTURES'
      THEN
         l_struc_version_from := p_ref_task_version_id;
         l_task_version_from  := null;
         l_relationship_subtype := 'STRUCTURE_TO_TASK';
         l_wbs_level := v_cur_proj_elems_rec.wbs_level;     --no change in wbs level.
         l_new_display_sequence := v_cur_proj_elems_rec.display_sequence;
      END IF;

      --to update wbs_level of all child task of p_task_version.
      l_wbs_level_diff := ( l_wbs_level -  v_cur_proj_elems_rec.wbs_level ); --new minus old

      l_display_sequence := v_cur_proj_elems_rec.display_sequence;

      l_task_seq_num := v_cur_proj_elems_rec.display_sequence;

      l_no_of_tasks := 1;

      l_parent_struc_ver_id :=  v_cur_proj_elems_rec.parent_structure_version_id;

      PA_PROJ_ELEMENT_VERSIONS_PKG.Update_Row(
            X_ROW_ID                   => v_cur_proj_elems_rec.rowid
           ,X_ELEMENT_VERSION_ID       => p_task_version_id
           ,X_PROJ_ELEMENT_ID            => v_cur_proj_elems_rec.proj_element_id
           ,X_OBJECT_TYPE            => v_cur_proj_elems_rec.object_type
           ,X_PROJECT_ID             => v_cur_proj_elems_rec.project_id
           ,X_PARENT_STRUCTURE_VERSION_ID   => v_cur_proj_elems_rec.parent_structure_version_id
           ,X_DISPLAY_SEQUENCE     => l_new_display_sequence
           ,X_WBS_LEVEL                => l_wbs_level
           ,X_WBS_NUMBER             => v_cur_proj_elems_rec.wbs_number
           ,X_ATTRIBUTE_CATEGORY       => l_ATTRIBUTE_CATEGORY
           ,X_ATTRIBUTE1             => l_ATTRIBUTE1
           ,X_ATTRIBUTE2             => l_ATTRIBUTE2
           ,X_ATTRIBUTE3             => l_ATTRIBUTE3
           ,X_ATTRIBUTE4             => l_ATTRIBUTE4
           ,X_ATTRIBUTE5             => l_ATTRIBUTE5
           ,X_ATTRIBUTE6             => l_ATTRIBUTE6
           ,X_ATTRIBUTE7             => l_ATTRIBUTE7
           ,X_ATTRIBUTE8             => l_ATTRIBUTE8
           ,X_ATTRIBUTE9             => l_ATTRIBUTE9
           ,X_ATTRIBUTE10            => l_ATTRIBUTE10
           ,X_ATTRIBUTE11            => l_ATTRIBUTE11
           ,X_ATTRIBUTE12            => l_ATTRIBUTE12
           ,X_ATTRIBUTE13            => l_ATTRIBUTE13
           ,X_ATTRIBUTE14            => l_ATTRIBUTE14
           ,X_ATTRIBUTE15            => l_ATTRIBUTE15
           ,X_record_version_number    => p_record_version_number
           ,X_TASK_UNPUB_VER_STATUS_CODE => l_task_unpub_ver_status_code
       );

     IF p_action = 'MOVE'
     THEN
        -- Update WBS numbers
        -- Delete
        DECLARE
            CURSOR cur_parent_of_task_version
            IS
              SELECT object_id_from1
                FROM pa_object_relationships
               WHERE object_id_to1 = p_task_version_id
                 AND relationship_type = 'S';
        BEGIN
            open cur_parent_of_task_version;
            fetch cur_parent_of_task_version INTO l_parent_of_task_version;
            close cur_parent_of_task_version;
        END;
      END IF;  --<< p_action = MOVE >>;
   ELSE
      CLOSE cur_proj_elems;
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INVALID_TASK_ID');
      l_msg_data := 'PA_PS_INVALID_TASK_ID';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE cur_proj_elems;
-- ELSE
--    CLOSE cur_ref_task;
--    PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INV_REF_TASK_ID');
--    l_msg_data := 'PA_PS_INV_REF_TASK_ID';
--    RAISE FND_API.G_EXC_ERROR;
-- END IF;

 CLOSE cur_ref_task;

 --update wbs level of all the child task
 FOR cur_child_tasks_rec IN cur_child_tasks( p_task_version_id )  LOOP
     --get the seq number of the last child of p_task_version_id
     l_task_last_child_seq_num := cur_child_tasks_rec.display_sequence;

     --Incrementing a negative value by 1 and then making it again a negative value.
     l_new_display_sequence := -( -1 * ( l_new_display_sequence ) + 1 );

--dbms_output.put_line( 'Child task l_new_display_sequence '|| l_new_display_sequence );
--dbms_output.put_line( 'Child task l_task_last_child_seq_num '|| l_task_last_child_seq_num );


     l_no_of_tasks := l_no_of_tasks + 1;

     UPDATE pa_proj_element_versions
        SET wbs_level = wbs_level + l_wbs_level_diff,
            display_sequence = decode( p_action, 'MOVE', l_new_display_sequence, display_sequence )
      WHERE element_version_id = cur_child_tasks_rec.object_id_to1;

 END LOOP;

 IF p_action = 'MOVE'
 THEN
     DECLARE
         CURSOR cur_update_with_null
         IS
           SELECT element_version_id, display_sequence
             FROM pa_proj_element_versions
            WHERE parent_structure_version_id = l_parent_struc_ver_id
              AND display_sequence < 0;

         TYPE CurrTasks IS RECORD( task_version_id NUMBER(15), display_sequence NUMBER(15) );
         TYPE TaskTab IS TABLE OF CurrTasks INDEX BY BINARY_INTEGER;
         l_TaskTab            TaskTab;
         i                    NUMBER := 1;
     BEGIN

          --update display sequence of the tasks with NULL to update WBS_NUMBER.
          FOR cur_update_with_null_rec in cur_update_with_null LOOP

              UPDATE pa_proj_element_versions
                 SET display_sequence = null
               WHERE element_version_id = cur_update_with_null_rec.element_version_id;

              l_TaskTab(i).task_version_id := cur_update_with_null_rec.element_version_id;
              l_TaskTab(i).display_sequence := cur_update_with_null_rec.display_sequence;
              i := i + 1;

          END LOOP;

          --updating wbs number only once after making display seq null

          PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
             ( p_commit                   => p_commit
              ,p_debug_mode               => p_debug_mode
              ,p_parent_structure_ver_id  => l_parent_struc_ver_id
              ,p_task_id                  => NULL
              ,p_display_seq              => l_task_seq_num
              ,p_action                   => 'DELETE'
              ,p_parent_task_id           => l_parent_of_task_version
              ,x_return_status            => l_return_status );

          FOR k in 1..i-1 LOOP
              UPDATE pa_proj_element_versions
                 SET display_sequence = l_TaskTab(k).display_sequence
               WHERE element_version_id = l_TaskTab(k).task_version_id;
          END LOOP;

          --The following block is added for debugging.
          /*DECLARE
              CURSOR cur_print_wbs
              IS
                SELECT element_version_id, wbs_number
                   FROM pa_proj_element_versions
                  WHERE parent_structure_version_id = l_parent_struc_ver_id
                 ORDER BY display_sequence;
          BEGIN
              FOR cur_print_wbs_rec in cur_print_wbs LOOP
                  --dbms_output.put_line( ' Task Ver Id : '|| cur_print_wbs_rec.element_version_id||
                                        ' WBS NUMBER: '||cur_print_wbs_rec.wbs_number );
              END LOOP;
          END;*/
     END;
 END IF;


 --update relatonship of the task version p_task_version.
 --set structure_version_from and task_version_from accordingly.
 OPEN cur_obj_rel( p_task_version_id );
 FETCH cur_obj_rel INTO v_cur_obj_rel_rec;
 CLOSE cur_obj_rel;

--hsiu added
--for task weighting
 OPEN get_task_weighting(p_task_version_id);
 FETCH get_task_weighting into l_old_parent_id, l_old_weighting;
 CLOSE get_task_weighting;

 -- anlee task weighting changes
 if(l_task_version_from is not null) THEN
   l_version_from := l_task_version_from;
 else
   l_version_from := l_struc_version_from;
 end if;

 IF (l_version_from = p_task_version_id) THEN
   l_new_weighting := l_old_weighting;
 ELSE
   OPEN get_sub_tasks(l_version_from);
   FETCH get_sub_tasks into l_dummy;
   IF (get_sub_tasks%NOTFOUND) THEN
     l_new_weighting := 100;
     --bug 2673570
     OPEN check_progress_allowed(p_task_version_id);
     FETCH check_progress_allowed INTO l_progress_allowed;
     CLOSE check_progress_allowed;

     if l_progress_allowed = 'N' then
        l_new_weighting := 0;
     end if;
     --bug 2673570
   ELSE
     l_new_weighting := 0;
   END IF;
   CLOSE get_sub_tasks;
 END IF;
-- end anlee

--end task weighting changes

 PA_RELATIONSHIP_PVT.Update_Relationship
             (
              p_api_version                       => p_api_version
             ,p_init_msg_list                     => p_init_msg_list
             ,p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode
             ,p_max_msg_count                     => p_max_msg_count
             ,p_object_relationship_id            => v_cur_obj_rel_rec.object_relationship_id
             ,p_project_id_from                   => null
             ,p_structure_id_from                 => null
             ,p_structure_version_id_from         => l_struc_version_from
             ,p_task_version_id_from              => l_task_version_from
             ,p_project_id_to                     => null
             ,p_structure_id_to                   => null
             ,p_structure_version_id_to           => null
             ,p_task_version_id_to                => p_task_version_id
             ,p_relationship_type                 => 'S'
             ,p_relationship_subtype              => l_relationship_subtype
             ,p_weighting_percentage              => l_new_weighting
             ,p_record_version_number             => v_cur_obj_rel_rec.record_version_number
             ,x_return_status                     => l_return_status
             ,x_msg_count                         => l_msg_count
             ,x_msg_data                          => l_msg_data
            );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;

     IF l_update_new_child_rels = 'Y' AND p_action IN( 'OUTDENT' )
     THEN
        FOR cur_new_child_rec in cur_new_child LOOP
            OPEN get_sub_tasks(p_task_version_id);
            FETCH get_sub_tasks into l_dummy;
            IF (get_sub_tasks%NOTFOUND) THEN
              l_new_weighting := 100;
            ELSE
              l_new_weighting := 0;
            END IF;
            CLOSE get_sub_tasks;

            PA_RELATIONSHIP_PVT.Update_Relationship
              (
              p_api_version                       => p_api_version
             ,p_init_msg_list                     => p_init_msg_list
             ,p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode
             ,p_max_msg_count                     => p_max_msg_count
             ,p_object_relationship_id            => cur_new_child_rec.object_relationship_id
             ,p_project_id_from                   => null
             ,p_structure_id_from                 => null
             ,p_structure_version_id_from         => null
             ,p_task_version_id_from              => p_task_version_id
             ,p_project_id_to                     => null
             ,p_structure_id_to                   => null
             ,p_structure_version_id_to           => null
             ,p_task_version_id_to                => cur_new_child_rec.object_id_to1
             ,p_relationship_type                 => 'S'
             ,p_relationship_subtype              => 'TASK_TO_TASK'
             ,p_weighting_percentage              => l_new_weighting
             ,p_record_version_number             => cur_new_child_rec.record_version_number
             ,x_return_status                     => x_return_status
             ,x_msg_count                         => x_msg_count
             ,x_msg_data                          => x_msg_data
            );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;

        END LOOP;
     END IF;

--hsiu added
--for task weighting
     PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
       p_task_version_id => l_old_parent_id
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
     );

     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count = 1 then
       pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;

     --bug 2673570
     PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
       p_task_version_id => p_task_version_id
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
     );

     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count = 1 then
       pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
     --bug 2673570
--end changes for task weighting


IF p_action = 'MOVE'
THEN
     --Update the display sequence of the affected tasks other than
     --the p_task_version and p_task_version children.

          /*--The following block is added for debugging.
          DECLARE
              CURSOR cur_print_wbs
              IS
                SELECT element_version_id, wbs_number
                   FROM pa_proj_element_versions
                  WHERE parent_structure_version_id = l_parent_struc_ver_id
                 ORDER BY display_sequence;
          BEGIN
              FOR cur_print_wbs_rec in cur_print_wbs LOOP
                  dbms_output.put_line( ' Task Ver Id : '|| cur_print_wbs_rec.element_version_id||
                                        ' WBS NUMBER: '||cur_print_wbs_rec.wbs_number );
              END LOOP;
          END;     */

     DECLARE
        CURSOR cur_affected_tasks
        IS
          SELECT element_version_id, parent_structure_version_id, display_sequence
            FROM pa_proj_element_versions
           WHERE parent_structure_version_id = l_parent_struc_ver_id
             AND ( ( l_move_direction = 'DOWN' and p_peer_or_sub = 'SUB' and
                     display_sequence > nvl( l_task_last_child_seq_num, l_task_seq_num )  and display_sequence <= l_ref_task_seq_num ) OR
                   ( l_move_direction = 'DOWN' and p_peer_or_sub = 'PEER' and
                     display_sequence > nvl( l_task_last_child_seq_num, l_task_seq_num ) and display_sequence <= l_ref_task_last_child_seq_num ) OR
                   ( l_move_direction = 'UP' and p_peer_or_sub = 'SUB' and
                     display_sequence > l_ref_task_seq_num and display_sequence < l_task_seq_num ) OR
                   ( l_move_direction = 'UP' and p_peer_or_sub = 'PEER' and
                     display_sequence > l_ref_task_last_child_seq_num and display_sequence < l_task_seq_num ) OR
            --**
                   ( l_move_direction = 'UP' and l_ref_task_last_child_seq_num > l_task_seq_num and
                     display_sequence > l_task_seq_num and display_sequence <= l_ref_task_last_child_seq_num )
            --**
                  )
            ORDER BY display_sequence;
     BEGIN
     --dbms_output.put_line( 'l_task_last_child_seq_num '|| l_task_last_child_seq_num );
--     dbms_output.put_line( 'l_task_seq_num '|| l_task_seq_num );

--     dbms_output.put_line( 'l_ref_task_last_child_seq_num '|| l_ref_task_last_child_seq_num );
--     dbms_output.put_line( 'l_ref_task_seq_num '|| l_ref_task_seq_num );
        FOR cur_affected_tasks_rec IN cur_affected_tasks LOOP

            --Update the affcted tasks sequence numbers
            IF l_move_direction = 'UP'
            THEN
               l_new_display_sequence := cur_affected_tasks_rec.display_sequence + l_no_of_tasks;
            ELSE
               l_new_display_sequence := cur_affected_tasks_rec.display_sequence - l_no_of_tasks;
            END IF;
            --**
            IF l_move_direction = 'UP' AND l_ref_task_last_child_seq_num > l_task_seq_num
            THEN
               l_new_display_sequence := cur_affected_tasks_rec.display_sequence - l_no_of_tasks;
            END IF;
            --**

--        dbms_output.put_line( 'cur_affected_tasks_rec.element_version_id '|| cur_affected_tasks_rec.element_version_id );
--        dbms_output.put_line( 'l_new_display_sequence '|| l_new_display_sequence );
--        dbms_output.put_line( 'cur_affected_tasks_rec.parent_structure_version_id '|| cur_affected_tasks_rec.parent_structure_version_id );

   --dbms_output.put_line( 'No. of tasks moved   '|| l_no_of_tasks );

   --dbms_output.put_line( 'Affected tasks old display_sequence '|| cur_affected_tasks_rec.display_sequence );
   --dbms_output.put_line( 'Affected tasks l_new_display_sequence '|| l_new_display_sequence );

            UPDATE pa_proj_element_versions
               SET display_sequence = l_new_display_sequence
              WHERE element_version_id = cur_affected_tasks_rec.element_version_id;

             --update wbs number for affected tasks
             -- Insert
             --update WBS NUMBER properly now for the affected rows.
             PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
                ( p_commit                   => p_commit
                 ,p_debug_mode               => p_debug_mode
                 ,p_parent_structure_ver_id  => cur_affected_tasks_rec.parent_structure_version_id
                 ,p_task_id                  => cur_affected_tasks_rec.element_version_id
                 ,p_display_seq              => l_new_display_sequence
                 ,p_action                   => 'INSERT'
                 ,p_parent_task_id           => NULL
                 ,x_return_status            => l_return_status );

        END LOOP;
     END;

     --Update the sequence number and WBS number of the tasks ( p_task_version and its children ) being updated.

     DECLARE
         CURSOR cur_actual_tasks
         IS
           SELECT element_version_id, display_sequence, parent_structure_version_id
             FROM pa_proj_element_versions
            WHERE parent_structure_version_id = l_parent_struc_ver_id
              AND display_sequence < 0
           ORDER BY display_sequence desc;
     BEGIN
         FOR cur_actual_tasks_rec IN cur_actual_tasks LOOP

             l_new_display_sequence := -1 * cur_actual_tasks_rec.display_sequence;

             IF l_move_direction = 'DOWN'
             THEN
                l_new_display_sequence := l_new_display_sequence - l_no_of_tasks;
             END IF;

             --**
            IF l_move_direction = 'UP' AND l_ref_task_last_child_seq_num > l_task_seq_num
            THEN
                l_new_display_sequence := l_new_display_sequence - l_no_of_tasks;
            END IF;
            --**

       --dbms_output.put_line( 'TAsk sequence number '||l_new_display_sequence );

             UPDATE pa_proj_element_versions
                SET display_sequence = l_new_display_sequence
              WHERE element_version_id = cur_actual_tasks_rec.element_version_id;

             --update wbs number for actual tasks
             -- Insert
             --update WBS NUMBER properly now
             PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
                ( p_commit                   => p_commit
                 ,p_debug_mode               => p_debug_mode
                 ,p_parent_structure_ver_id  => cur_actual_tasks_rec.parent_structure_version_id
                 ,p_task_id                  => cur_actual_tasks_rec.element_version_id
                 ,p_display_seq              => l_new_display_sequence
                 ,p_action                   => 'INSERT'
                 ,p_parent_task_id           => NULL
                 ,x_return_status            => l_return_status );


         END LOOP;
     END;

      DECLARE
        CURSOR cur_affected_tasks
        IS
          SELECT element_version_id, parent_structure_version_id, display_sequence
            FROM pa_proj_element_versions
           WHERE parent_structure_version_id = l_parent_struc_ver_id
             AND display_sequence > nvl( l_ref_task_last_child_seq_num, l_ref_task_seq_num )
            ORDER BY display_sequence;
     BEGIN
        FOR cur_affected_tasks_rec IN cur_affected_tasks LOOP
--        dbms_output.put_line( 'cur_affected_tasks_rec.element_version_id '|| cur_affected_tasks_rec.element_version_id );
--      dbms_output.put_line( 'cur_affected_tasks_rec.display_sequence '|| cur_affected_tasks_rec.display_sequence );
             --update wbs number for affected tasks
             -- Insert
             --update WBS NUMBER properly now for the affected rows.
             PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
                ( p_commit                   => p_commit
                 ,p_debug_mode               => p_debug_mode
                 ,p_parent_structure_ver_id  => cur_affected_tasks_rec.parent_structure_version_id
                 ,p_task_id                  => cur_affected_tasks_rec.element_version_id
                 ,p_display_seq              => cur_affected_tasks_rec.display_sequence
                 ,p_action                   => 'INSERT'
                 ,p_parent_task_id           => NULL
                 ,x_return_status            => l_return_status );

        END LOOP;
     END;
END IF; --<< p_action = 'MOVE' >>

 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_VER_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_VER_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'update_Task_version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END update_task_version;
-- API name                      : Delete_Task_version
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id    IN  NUMBER  N   Null
-- p_record_version_number  IN  NUMBER
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  01-JUL-2004 Rakesh Raghavan          Modified.
--
--
PROCEDURE Delete_Task_Version(
 p_api_version              IN  NUMBER      :=1.0,
 p_init_msg_list            IN  VARCHAR2    :=FND_API.G_TRUE,
 p_commit                   IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only            IN  VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level         IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module           IN  VARCHAR2    :='SELF_SERVICE',
 p_debug_mode               IN  VARCHAR2    :='N',
 p_max_msg_count            IN  NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id          IN  NUMBER,
 p_record_version_number    IN  NUMBER,
 p_called_from_api          IN  VARCHAR2    := 'ABCD',
 p_structure_type           IN  VARCHAR2    := 'WORKPLAN', --bug 3301192
 x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                     VARCHAR2(250);

    l_error_message_code           VARCHAR2(250);

    l_parent_struc_ver_id          NUMBER;
    l_wbs_level                    NUMBER;
    l_display_sequence             NUMBER;
    l_wbs_number                   NUMBER;
    l_delete_flag                  VARCHAR2(1) := 'N';
    l_structure_id                 NUMBER;

    CURSOR cur_child_tasks
    IS
      SELECT a.object_relationship_id object_relationship_id, a.object_id_to1 object_id_to1,
             a.record_version_number record_version_number, b.wbs_level wbs_level, b.display_sequence
      FROM (
      SELECT object_relationship_id, object_id_to1, record_version_number
        FROM pa_object_relationships
       WHERE relationship_type = 'S'
  START WITH object_id_from1 = p_task_version_id
  CONNECT BY object_id_from1 = PRIOR object_id_to1
      AND relationship_type = prior relationship_type -- bug 3919266
      AND relationship_type = 'S' ) A, pa_proj_element_versions b
      ,pa_proj_elements c        --bug 4573340
     WHERE a.object_id_to1 = b.element_version_id
     --bug 4573340
        and b.proj_element_id = c.proj_element_id
        and b.project_id = c.project_id
        and c.link_task_flag = 'N'
      --bug 4573340
  UNION
     SELECT a.object_relationship_id, element_version_id  object_id_to1,
            a.record_version_number, wbs_level, b.display_sequence
       FROM pa_object_relationships a, pa_proj_element_versions b
      WHERE element_version_id = p_task_version_id
        AND object_id_to1 = p_task_version_id
        AND element_version_id = object_id_to1
        AND relationship_type = 'S'
   ORDER BY 4 desc;


   CURSOR cur_proj_elem_ver( p_task_id NUMBER )
   IS
     SELECT rowid,record_version_number, project_id, parent_structure_version_id, proj_element_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_task_id;

   CURSOR cur_sch_ver( p_task_id NUMBER, p_project_id NUMBER )
   IS
     SELECT rowid
       FROM pa_proj_elem_ver_schedule
      WHERE element_version_id = p_task_id
        and project_id = p_project_id;

   CURSOR cur_pa_projs( p_project_id NUMBER )
   IS
     SELECT wbs_record_version_number
            -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
             FROM pa_proj_elem_ver_structure
 -- HY      FROM pa_projects_all
      WHERE project_id = p_project_id;

   CURSOR cur_pa_tasks( p_task_id NUMBER )
   IS
     SELECT record_version_number
       FROM pa_tasks
      WHERE task_id = p_task_id;

   CURSOR cur_chk_vers( x_proj_element_id NUMBER, x_task_version NUMBER )
   IS
     SELECT 'X'
       FROM pa_proj_element_versions
      WHERE proj_element_id = x_proj_element_id
        AND element_version_id <> x_task_version;

  CURSOR cur_proj_elems( x_proj_element_id NUMBER )
  IS
    SELECT rowid
      FROM pa_proj_elements
     WHERE proj_element_id = x_proj_element_id;


--Ansari
  CURSOR cur_parent_ver_id( c_task_version_id NUMBER )
  IS
    SELECT object_id_from1
      FROM pa_object_relationships
     WHERE object_id_to1 = c_task_version_id
       AND relationship_type = 'S';
  l_parent_task_verion_id   NUMBER;
--Ansari


--hsiu added, for dates rollup
   CURSOR get_peer_tasks
   IS
     select b.object_id_to1 object_id_to1
       from pa_object_relationships a,
            pa_object_relationships b,
            pa_proj_element_versions c,
            pa_proj_elements d
      where a.object_id_to1 = p_task_version_id
        and a.object_type_to = 'PA_TASKS'
        and a.object_id_from1 = b.object_id_from1
        and a.object_type_from = b.object_type_from
        and b.object_type_to = 'PA_TASKS'
        and b.object_id_to1 <> p_task_version_id
        and a.relationship_type = 'S'
        and b.relationship_type = 'S'
        and b.object_id_to1 = c.element_version_id
        and c.project_id = d.project_id
        and c.proj_element_id = d.proj_element_id
        and d.link_task_flag <> 'Y';
   c_get_peer_tasks get_peer_tasks%ROWTYPE;
   l_peer_tasks_exist VARCHAR2(1) := 'Y';
   l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

--hsiu added, for task weighting
   CURSOR get_parent_version_id IS
     select object_id_from1
       from pa_object_relationships
      where object_id_to1 = p_task_version_id
        and object_type_to = 'PA_TASKS'
        and relationship_type = 'S'
        and object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');
   l_old_parent_ver_id    NUMBER;
--end task weighting changes

   x_row_id                  VARCHAR2(255);
   x_row_id_elem             VARCHAR2(255);
   x_sch_row_id              VARCHAR2(255);
   x_record_version_number   NUMBER;

   x_task_rec_version_number NUMBER;
   x_wbs_rec_version_number  NUMBER;
   x_parent_struc_ver_id     NUMBER;
   x_project_id              NUMBER;
   l_proj_element_id         NUMBER;
   l_dummy_char              VARCHAR2(1);
   l_task_cnt                NUMBER;
   l_selected_seq_num        NUMBER;

   --hsiu task status changes
   cursor get_latest_task_ver_id IS
     select b.parent_structure_version_id, b.element_version_id
       from pa_proj_element_versions b,
            pa_proj_elem_ver_structure c
      where b.element_version_id = p_task_version_id
        and b.project_id = c.project_id
        and b.parent_structure_version_id = c.element_version_id
        and c.LATEST_EFF_PUBLISHED_FLAG = 'Y';
   l_latest_task_ver_rec    get_latest_task_ver_id%ROWTYPE;
   --end task status changes

   --hsiu: bug 2800553: for performance changes
   l_calling_module VARCHAR2(30);

--Bug 2947492  ( delete )

--Bug 3305199: commented out for M
--l_plannable_tasks_tbl        PA_FP_ELEMENTS_PUB.l_impacted_task_in_tbl_typ;
l_parent_task_id             NUMBER;
l_top_task_id                NUMBER;
l_validation_mode               VARCHAR2(1);

l_Structure_Version_ID      NUMBER;     -- FP_M changes 3305199

CURSOR get_parent_task_id( c_project_id  NUMBER , c_task_id NUMBER ) IS
    SELECT parent_task_id, top_task_id, record_version_number FROM pa_tasks
     WHERE project_id = c_project_id and task_id = c_task_id;

--End Bug 2947492

--bug 3053281
  l_wp_type              VARCHAR2(1);
  l_weighting_basis_Code VARCHAR2(30);
  l_shared               VARCHAR2(1) := 'N';
--end bug 3053281

--3035902: process update flag changes
  cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
 l_task_type_id      NUMBER;
 l_progress_flag     VARCHAR2(1);
 l_Project_ID   number;
--3035902: end process update flag changes

  --Cursor to selct fp task version id to delete the mapping
  -- Added by Skannoji
  CURSOR cur_fp_tsk_ver_id( c_task_version_id NUMBER )
  IS
    SELECT object_id_to1
      FROM pa_object_relationships
     -- bug# 3766336 Satish 19/07/04
     --WHERE object_id_from1 = p_task_version_id
     WHERE object_id_from1 = c_task_version_id
       AND relationship_type = 'M';

      l_fp_task_version_id       PA_OBJECT_RELATIONSHIPS.object_id_to1%TYPE;
      /* Bug #: 3305199 SMukka                                                         */
      /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
      /* l_element_version_id_tbl   PA_PLSQL_DATATYPES.IdTabTyp;                       */
      l_element_version_id_tbl   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
      l_wp_str_exists            VARCHAR2(1);
 --skannoji
 --
   --Bug No 3450684 Smukka For Subproject Association
   CURSOR get_subproj_relation(cp_task_ver_id NUMBER) IS
   SELECT pors.object_relationship_id,pors.record_version_number
     FROM pa_object_relationships pors
--bug 4573340
     ,pa_object_relationships pors1
    WHERE
      --pors.object_id_from1= cp_task_ver_id
      pors1.object_id_from1 = cp_task_ver_id
      AND pors.object_id_from1 = pors1.object_id_to1
      AND pors1.relationship_type = 'S'
--bug 4573340
      AND pors.relationship_type IN ('LW','LF')
      AND pors.object_id_from2 <> pors.object_id_to2
      AND pors.object_type_from = 'PA_TASKS'
      AND pors.object_type_to = 'PA_STRUCTURES';
      get_subproj_relation_rec get_subproj_relation%ROWTYPE;

  l_task_id NUMBER; --bug 4006401

  --bug 4006401
  CURSOR get_all_subtasks(c_task_version_id NUMBER) IS
    select object_id_to1 task_ver_id
      from pa_object_relationships pors
     start with object_id_from1 = c_task_version_id
       and relationship_type = 'S'
       and object_type_from = 'PA_TASKS'
       and object_type_to = 'PA_TASKS'
    connect by relationship_type = prior relationship_type
       and prior object_type_to = object_type_from
       and prior object_id_to1 = object_id_from1
    UNION
    select element_version_id task_ver_id
      from pa_proj_element_versions
     where element_version_id = c_task_version_id;
  --end bug 4006401

  --bug 4110957
  CURSOR get_tsk_cnt(c_struc_ver_id NUMBER) IS
    select count(1) from pa_proj_element_versions
     where object_type = 'PA_TASKS'
       and parent_structure_version_id = c_struc_ver_id;
  l_tsk_ver_cnt  NUMBER;
  --end bug 4110957

  -- 4201927 Added following local variables , the values are derived once and
  -- used further , For performance fix
  l_structure_sharing_code varchar2(35);
  l_structure_type_wp      varchar2(1);
  l_structure_type_fin     varchar2(1);
  -- 4201927 end

  -- 4221374 Added following local variables for perf fix
  l_task_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  task_index NUMBER;
  -- 4221374 end

  -- Begin fix for Bug # 4506308.

  cursor l_cur_projects_all(c_project_id NUMBER) is
  select ppa.template_flag, ppa.record_version_number
  from pa_projects_all ppa
  where ppa.project_id = c_project_id;

  l_ver_enabled    VARCHAR2(1);
  l_template_flag  VARCHAR2(1);
  l_rec_ver_number NUMBER;

  -- End fix for Bug # 4506308.

     l_debug_mode             VARCHAR2(1);

BEGIN

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    -- Added for FP_M changes : Bhumesh
    -- 4201927 Removed following code for performance issue
    -- the same information ( project_id ) is already available in below select
    /*
    Begin
      SELECT project_id
      Into   l_Project_ID
      FROM   pa_proj_element_versions
      WHERE  element_version_id = p_task_version_id and rownum < 2;
    End;
    */
    -- 4201927 end

      -- 4201927 added project_id column selection
      select proj_element_id, project_id into l_task_id , l_Project_ID -- 4201927
        from pa_proj_element_versions
       where element_version_id = p_task_version_id;

    -- 4201927 Retrieving structure sharding code once and using it for further processing
    l_structure_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_Project_id); -- dthakker added

    -- 4201927 Commented below code as for PARTIALLY SHARED structure, Delete Button is not
    -- shown financial tab

    /*
    -- Tracking bug 3305199
    If p_Structure_Type = 'FINANCIAL' and
    PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_Project_id )= 'SHARE_PARTIAL'
    then
       PA_Tasks_Maint_Utils.Check_WorkPlan_Task_Exists (
        p_api_version         => p_api_version
        , p_calling_module    => p_calling_module
        , p_debug_mode        => p_debug_mode
        , p_task_version_id   => p_task_version_id
        , x_return_status     => x_return_status
        , x_msg_count         => x_msg_count
        , x_msg_data          => x_msg_data
        , x_error_msg_code    => l_error_msg_code );
    If x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
    End If;
    End If;
    -- End of FP_M changes
    */
    -- 4201927 end

    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PVT1.DELETE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_TASK_VER_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

--hsiu
--added for task weighting changes
    OPEN get_parent_version_id;
    FETCH get_parent_version_id INTO l_old_parent_ver_id;
    CLOSE get_parent_version_id;
--end task weighting changes


--hsiu
--added on 08-JAN-2002
--check if task is linked task
    IF (p_structure_version_id IS NOT NULL) AND
       (p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      IF ('N' = pa_proj_elements_utils.check_task_in_structure(
            p_structure_version_id,
            p_task_version_id)) THEN
        --deleting linked task. Error
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_DEL_LINKED_TASK');
        l_msg_data := 'PA_PS_NO_DEL_LINKED_TASK';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

--hsiu added, for dates rollup
    OPEN get_peer_tasks;
    FETCH get_peer_tasks INTO c_get_peer_tasks;
    IF get_peer_tasks%NOTFOUND THEN
      l_peer_tasks_exist := 'N';
    ELSE
      l_peer_tasks_exist := 'Y';
      l_tasks_ver_ids.extend;
      l_tasks_ver_ids(l_tasks_ver_ids.count) := c_get_peer_tasks.object_id_to1;
    END IF;
    CLOSE get_peer_tasks;
--dbms_output.put_line('del tsk pvt: '||l_tasks_ver_ids(l_tasks_ver_ids.count)||', '||l_peer_tasks_exist);

--bug 3301192


  l_wp_str_exists := PA_PROJ_TASK_STRUC_PUB.wp_str_exists(l_project_id);
  l_shared        := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(l_project_id);
--bug 3301192

--bug 4006401

  -- 4201927 Added one more IF condition p_called_from_api <> 'DELETE_STRUCTURE_VERSION'
  -- below code shuold not be called for delete structure version flow :: for performance fix

  --IF l_wp_str_exists = 'Y' OR l_shared = 'Y' THEN -- commented for 4201927
  IF p_called_from_api <> 'DELETE_STRUCTURE_VERSION' AND ( l_wp_str_exists = 'Y' OR l_shared = 'Y' ) THEN  -- 4201927 added
    FOR i IN get_all_subtasks(p_task_version_id) LOOP
      l_element_version_id_tbl.extend(1);
      l_element_version_id_tbl(l_element_version_id_tbl.count) := i.task_ver_id;
    END LOOP;

    BEGIN
      PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions(
             p_context                      => 'WORKPLAN'
            ,p_task_or_res                  => 'TASKS'
            ,p_element_version_id_tbl       => l_element_version_id_tbl
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                                p_procedure_name => 'delete_Task_version',
                                p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions:'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
    END;
    IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
    End If;
  END IF;
--end bug 4006401

  -- 4201927 For performance fix :: retrieve below values once and using it for further processing

  l_structure_type_fin := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => p_structure_version_id
                                           ,p_structure_type       => 'FINANCIAL' );

  l_structure_type_wp  := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => p_structure_version_id
                                           ,p_structure_type       => 'WORKPLAN' );

  -- 4201927 end

--added for bug 4006401
  -- 4201927 Using local values rather than calling api
  --IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => p_structure_version_id
  --                                         ,p_structure_type       => 'FINANCIAL' ) = 'Y') THEN --  4201927 commented
  IF l_structure_type_fin = 'Y' THEN -- 4201927 added
    IF nvl(l_shared,'N') = 'N' THEN
      l_delete_flag := 'Y';
    ELSE
      SELECT proj_element_id INTO l_structure_id
        FROM pa_proj_element_versions
       WHERE element_version_id = p_structure_version_id
         AND project_id = l_project_id;

      IF PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(
                            p_project_id   => l_project_id
                           ,p_structure_id => l_structure_id ) = 'N'
      THEN
        l_delete_flag := 'Y';
      ELSE
        -- 4201927 Using local values rather than calling api
        --IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => p_structure_version_id
        --                                                        ,p_structure_type       => 'WORKPLAN' ) = 'Y') THEN -- 4201927 commented
        IF  l_structure_type_wp = 'Y' THEN -- 4201927 added
          IF PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id) = 'N' THEN
            l_delete_flag := 'Y';
          END IF;
        END IF;
      END IF;
    END IF ; -- Bug#3834117
  END IF;

  IF l_delete_flag = 'Y' AND PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_task_id )= 'Y'
      -- Added for FP_M changes Bug 3305199 Bhumesh
  THEN

    -- Added for FP_M changes
    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(l_Project_ID) = 'Y' then

      PA_PROJECT_STRUCTURE_PVT1.update_sch_dirty_flag(
             p_structure_version_id => P_Structure_Version_ID
            ,p_dirty_flag           => 'Y'             --bug 3902282
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
        x_msg_count := FND_MSG_PUB.count_msg;
        If x_msg_count = 1 then
          pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
        End If;
        raise FND_API.G_EXC_ERROR;
      End If;
    End If;

    OPEN  cur_pa_projs( l_project_id );
    FETCH cur_pa_projs INTO x_wbs_rec_version_number;
    CLOSE cur_pa_projs;

    --call plannable tasks api here. This will be executed whenever a task is deleted regardless from
    --which environement FORMS, Self Service or AMG.
    OPEN get_parent_task_id( l_project_id, l_task_id );
    FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id, x_task_rec_version_number;
    CLOSE get_parent_task_id;

    IF  p_called_from_api <> 'MOVE_TASK_VERSION' AND
        p_calling_module NOT IN ( 'FORMS', 'AMG' )    --Added condition to call this api from forms and AMG apis.
                                             --Since forms and AMG already deletes from pa_tasks we do not have to call the following api again.
    THEN
      PA_TASKS_MAINT_PUB.DELETE_TASK(
                  p_api_version                       => p_api_version
                 ,p_init_msg_list                     => p_init_msg_list
                 ,p_commit                            => p_commit
                 ,p_validate_only                     => p_validate_only
                 ,p_validation_level                  => p_validation_level
                 ,p_calling_module                    => p_calling_module
                 ,p_debug_mode                        => p_debug_mode
                 ,p_project_id                        => l_project_id
                 ,p_task_id                           => l_task_id
                 ,p_record_version_number             => x_task_rec_version_number
                 ,p_wbs_record_version_number         => x_wbs_rec_version_number
                 ,p_called_from_api                   => p_called_from_api
                 -- 4201927 pass p_bulk_flag as 'Y' to avoid delete_task_ok api validation in
                 -- pa_proj_maint_pvt and pa_project_core.delete_task apis
                 ,p_bulk_flag                         => 'Y'
                 ,x_return_status                     => l_return_status
                 ,x_msg_count                         => l_msg_count
                 ,x_msg_data                          => l_msg_data);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
          pa_interface_utils_pub.get_messages(
                    p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF; --called_from_api chk.
  END IF; --delete flag chk
--end bug 4006401

-- 4221374  Initializing the task_index to 0 for delete_working_wp_progress api parameter
task_index := 0;

FOR cur_child_tasks_rec IN cur_child_tasks LOOP

----dbms_output.put_line( 'Task version deleted '||cur_child_tasks_rec.object_id_to1 );

   OPEN cur_proj_elem_ver( cur_child_tasks_rec.object_id_to1 );
   FETCH cur_proj_elem_ver INTO x_row_id, x_record_version_number, x_project_id, x_parent_struc_ver_id, l_proj_element_id;
   IF cur_proj_elem_ver%FOUND
   THEN
     IF cur_child_tasks_rec.object_id_to1 = p_task_version_id
     THEN
        IF x_record_version_number <> p_record_version_number
        THEN
           CLOSE cur_proj_elem_ver;
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.Raise_Exception;
        END IF;
     END IF;
     --check_delete_task ok

--dbms_output.put_line( 'before chk_delete ' );

--The following code is reqd. to pass calling mode to check api bcoz PA_PROJ_ELEMENTS_UTILS.check_delete_task_ver_ok again calls
--PA_TASK_UTILS.check_delete_task_ok api
--bug 2947492
--commenting out the 'R'estricted mode logic for bug 3010538
--     IF p_calling_module = 'AMG'
--     THEN
--         l_validation_mode   := 'R';
--     ELSE
         l_validation_mode   := 'U';
--     END IF;
--End bug 2947492

/*  bug 4006401--removed since it is called in PUB.
     IF  p_called_from_api <> 'MOVE_TASK_VERSION'
     THEN
         PA_PROJ_ELEMENTS_UTILS.check_delete_task_ver_ok(
                                    p_project_id                   => x_project_id
                                  ,p_task_version_id              => cur_child_tasks_rec.object_id_to1
                                  ,p_parent_structure_ver_id      => x_parent_struc_ver_id
--bug 3010538                     ,p_validation_mode                 => l_validation_mode   --bug 2947492
                                  ,x_return_status                => l_return_status
                                  ,x_error_message_code           => l_error_message_code );
     END IF;

--dbms_output.put_line('status  = '||l_return_status||','||l_error_message_code);
     IF (l_return_status <> 'S') THEN
       x_return_status := l_return_status;
       PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
       l_msg_data := l_error_message_code;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
*/

--dbms_output.put_line( 'before workplan test ' );

     --deleting schedule version if its a workplan
     --IF workplan_structure THEN
   IF  p_called_from_api <> 'MOVE_TASK_VERSION' THEN
     IF PA_PROJ_ELEMENTS_UTILS.structure_type(
                        p_structure_version_id => null
                       ,p_task_version_id      => cur_child_tasks_rec.object_id_to1
                       ,p_structure_type       => 'WORKPLAN' ) = 'Y' THEN

        -- 4201927 Commented below code for performance issue
        -- Using direct delete statement rather than deriving row_id and calling
        -- delete_row with row id
        /*
        OPEN cur_sch_ver( cur_child_tasks_rec.object_id_to1, x_project_id );
        FETCH cur_sch_ver INTO x_sch_row_id;
        IF  cur_sch_ver%FOUND
        THEN
               PA_PROJ_ELEMENT_SCH_PKG.Delete_row(  x_sch_row_id );
        END IF;
        CLOSE cur_sch_ver;
        */

        -- Added direct delete statement
        DELETE FROM PA_PROJ_ELEM_VER_SCHEDULE
        WHERE ELEMENT_VERSION_ID = cur_child_tasks_rec.object_id_to1
        AND PROJECT_ID = x_project_id;

        -- 4201927 end

     -- Added by skannoji
     -- Deleteing planning transactions for all given element version id
--     IF ( (PA_PROJ_TASK_STRUC_PUB.wp_str_exists(x_project_id) = 'Y') OR
--        (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(x_project_id) = 'Y') ) THEN
/*
       IF l_wp_str_exists = 'Y' OR
          l_shared        = 'Y'
       THEN
       l_element_version_id_tbl.extend(1);
       l_element_version_id_tbl(1) := cur_child_tasks_rec.object_id_to1;
       --Smukka Bug No. 3474141 Date 03/01/2004
       --moved PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions into plsql block
       BEGIN
           PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions(
             p_context                      => 'WORKPLAN'
            ,p_task_or_res                  => 'TASKS'
            ,p_element_version_id_tbl       => l_element_version_id_tbl
--          ,p_maintain_reporting_lines     => 'Y'
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data);
       EXCEPTION
          WHEN OTHERS THEN
               fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                                       p_procedure_name => 'delete_Task_version',
                                       p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions:'||SQLERRM,1,240));
          RAISE FND_API.G_EXC_ERROR;
       END;
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       End If;
     END IF;
*/
       -- till here by skannoji

     END IF;
   END IF;

    -- Added by skannoji
    -- While deletion of task, the task mapping should be deleted

    -- 4201927 Commented below code , Using local derived values rather than calling api
    /*
    IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                            p_structure_version_id => x_parent_struc_ver_id
                                           ,p_structure_type       => 'WORKPLAN' ) = 'Y') AND
    (PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(x_project_id )= 'SPLIT_MAPPING')
    */
    IF l_structure_type_wp = 'Y' AND l_structure_sharing_code = 'SPLIT_MAPPING'
    -- 4201927 end
    then

       --Get fp task version id to delete mapping.
       OPEN cur_fp_tsk_ver_id( cur_child_tasks_rec.object_id_to1 );
       FETCH cur_fp_tsk_ver_id INTO l_fp_task_version_id;
           IF cur_fp_tsk_ver_id%FOUND THEN
                PA_PROJ_STRUC_MAPPING_PUB.delete_mapping
                    (
                           p_wp_task_version_id    => cur_child_tasks_rec.object_id_to1
                         , p_fp_task_version_id    => l_fp_task_version_id
                         , x_return_status         => x_return_status
                         , x_msg_count             => x_msg_count
                         , x_msg_data              => x_msg_data);
           END IF;
       CLOSE cur_fp_tsk_ver_id;

       If x_return_status = FND_API.G_RET_STS_ERROR then
        RAISE FND_API.G_EXC_ERROR;
       End If;
    End If;
      -- till here

     --Do financial task check
     --If financial
     --enough to check first record.

--dbms_output.put_line( 'before financial test ' );

     -- 4201927 Commented below code for performance fix, the derived flag l_dlete_flag in below code is
     -- not used for further processing

     /*
     IF cur_child_tasks%ROWCOUNT = 1
     THEN
       IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => x_parent_struc_ver_id
                                           ,p_structure_type       => 'FINANCIAL' ) = 'Y')
         THEN
           --If structure has any published versions.
          -- IF ( PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published( p_project_id => x_project_id
            --                                                 ,p_structure_version_id => x_parent_struc_ver_id ) = 'N' )
           --THEN

           -- Bug#3834117
           -- For a split case if task is deleted from SS page
           -- the tasks were not getting deleted from PA_TASKS
           -- table. In SPLIT case fin tasks should always get deleted
           -- from PA_TASKS table
           IF nvl(l_shared,'N') = 'N' THEN
             l_delete_flag := 'Y';
           ELSE
                SELECT proj_element_id INTO l_structure_id
                  FROM pa_proj_element_versions
                 WHERE element_version_id = x_parent_struc_ver_id
                   AND project_id = x_project_id;

                IF PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(
                            p_project_id   => x_project_id
                           ,p_structure_id => l_structure_id ) = 'N'
                THEN
                  l_delete_flag := 'Y';
                ELSE
                  IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(   p_structure_version_id => x_parent_struc_ver_id
                                                                               ,p_structure_type       => 'WORKPLAN' ) = 'Y') THEN
                    IF PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(x_project_id) = 'N' THEN
                      l_delete_flag := 'Y';
                    END IF;
                  END IF;
                END IF;
           END IF ; -- Bug#3834117
       END IF;
     END IF;
     */
     -- 4201927 end

/*
     IF l_delete_flag = 'Y' AND PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_proj_element_id )= 'Y'
      -- Added for FP_M changes Bug 3305199 Bhumesh
     THEN

       -- Added for FP_M changes
       If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(x_Project_ID) = 'Y' then

          PA_PROJECT_STRUCTURE_PVT1.update_sch_dirty_flag(
             p_structure_version_id => P_Structure_Version_ID
            ,p_dirty_flag           => 'Y'             --bug 3902282
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            x_msg_count := FND_MSG_PUB.count_msg;
            If x_msg_count = 1 then
              pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
            End If;
            raise FND_API.G_EXC_ERROR;
          End If;
       End If;
       -- End of FP_M changes

          OPEN  cur_pa_projs( x_project_id );
          FETCH cur_pa_projs INTO x_wbs_rec_version_number;
          CLOSE cur_pa_projs;

         -- OPEN  cur_pa_tasks( l_proj_element_id );
         -- FETCH cur_pa_tasks INTO x_task_rec_version_number;
         -- CLOSE cur_pa_tasks; --commented out and merged with the cursor get_parent_task_id below for performance for bug 2947492

           --Bug 2947492
           --call plannable tasks api here. This will be executed whenever a task is deleted regardless from
           --which environement FORMS, Self Service or AMG.

            OPEN get_parent_task_id( x_project_id, l_proj_element_id );
            FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id, x_task_rec_version_number;
            CLOSE get_parent_task_id;
*/

--Bug 3305199: commented out for M
/*
            l_plannable_tasks_tbl(1).impacted_task_id   := l_proj_element_id;
            l_plannable_tasks_tbl(1).action             := 'DELETE';
            l_plannable_tasks_tbl(1).old_parent_task_id := l_parent_task_id;
            l_plannable_tasks_tbl(1).top_task_id        := l_top_task_id;

            IF  p_called_from_api <> 'MOVE_TASK_VERSION'   --Move will be taken care separately
                AND p_calling_module NOT IN ( 'FORMS', 'AMG' )
            THEN
                PA_FP_ELEMENTS_PUB.MAINTAIN_PLANNABLE_TASKS(
                    p_project_id         => x_project_id
                  , p_impacted_tasks_tbl => l_plannable_tasks_tbl
                  , x_return_status      => l_return_status
                  , x_msg_data           => l_msg_data
                  , x_msg_count          => l_msg_count
                );

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
                raise FND_API.G_EXC_ERROR;
                END IF;
             END If; --<< not calling if called from move_task_version api >
             --End Bug 2947492
*/
/*

--dbms_output.put_line( 'before delete_task ' );
          IF  p_called_from_api <> 'MOVE_TASK_VERSION' AND
              p_calling_module NOT IN ( 'FORMS', 'AMG' )    --Added condition to call this api from forms and AMG apis.
                                             --Since forms and AMG already deletes from pa_tasks we do not have to call the following api again.
          THEN
              PA_TASKS_MAINT_PUB.DELETE_TASK
               (
                  p_api_version                       => p_api_version
                 ,p_init_msg_list                     => p_init_msg_list
                 ,p_commit                            => p_commit
                 ,p_validate_only                     => p_validate_only
                 ,p_validation_level                  => p_validation_level
                 ,p_calling_module                    => p_calling_module
                 ,p_debug_mode                        => p_debug_mode
                 ,p_project_id                        => x_project_id
                 ,p_task_id                     => l_proj_element_id
                 ,p_record_version_number             => x_task_rec_version_number
                 ,p_wbs_record_version_number         => x_wbs_rec_version_number
                 ,p_called_from_api                   => p_called_from_api
                 ,x_return_status                     => l_return_status
                 ,x_msg_count                         => l_msg_count
                 ,x_msg_data                          => l_msg_data
                );
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;

           END IF; --called_from_api chk.
     END IF; --delete flag chk
*/

--dbms_output.put_line( 'Task Version Id '|| cur_child_tasks_rec.object_id_to1 );
--dbms_output.put_line( 'rel id '||cur_child_tasks_rec.object_relationship_id );

     --Ansari
     --Get parent of deleting task before its relationship gets deleted.
     OPEN cur_parent_ver_id( cur_child_tasks_rec.object_id_to1 );
     FETCH cur_parent_ver_id INTO l_parent_task_verion_id;
     CLOSE cur_parent_ver_id;
     --Ansari

--bug 4573340. First delete the sub-project association if it exists:
        --Bug No 3450684 Smukka 16-Mar-2004
        --Deleting subproject association
        OPEN get_subproj_relation(cur_child_tasks_rec.object_id_to1);
        FETCH get_subproj_relation INTO get_subproj_relation_rec;
        IF get_subproj_relation%FOUND   --bug 4573340
        THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VERSION', 'Before PA_RELATIONSHIP_PUB.Delete_SubProject_Association get_subproj_relation_rec.object_relationship_id='
                               ||get_subproj_relation_rec.object_relationship_id, 3);
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VERSION', 'Before PA_RELATIONSHIP_PUB.Delete_SubProject_Association get_subproj_relation_rec.record_version_number='
                               ||get_subproj_relation_rec.record_version_number, 3);

           END IF;

           PA_RELATIONSHIP_PUB.Delete_SubProject_Association    --bug 4573340  replaced the call with delete_subproject
                   (
                     p_init_msg_list                     => p_init_msg_list
                    ,p_commit                            => p_commit
                    ,p_validate_only                     => p_validate_only
                    ,p_validation_level                  => p_validation_level
                    ,p_calling_module                    => p_calling_module
                    ,p_debug_mode                        => p_debug_mode
                    ,p_max_msg_count                     => p_max_msg_count
                    ,p_object_relationships_id           => get_subproj_relation_rec.object_relationship_id
                    ,p_record_version_number             => get_subproj_relation_rec.record_version_number
                    ,x_return_status                     => l_return_status
                    ,x_msg_count                         => l_msg_count
                    ,x_msg_data                          => l_msg_data
                    );

           IF l_debug_mode = 'Y' THEN
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VERSION', 'After PA_RELATIONSHIP_PUB.Delete_SubProject_Association l_return_status='||l_return_status, 3);
           END IF;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE,
                 p_msg_index      => 1,
                 p_msg_count      => l_msg_count,
                 p_msg_data       => l_msg_data,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out);
                 x_msg_data := l_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        END IF; --4573340
        CLOSE get_subproj_relation;


     PA_RELATIONSHIP_PUB.Delete_Relationship
                   (
                     p_api_version                       => p_api_version
                    ,p_init_msg_list                     => p_init_msg_list
                    ,p_commit                            => p_commit
                    ,p_validate_only                     => p_validate_only
                    ,p_validation_level                  => p_validation_level
                    ,p_calling_module                    => p_calling_module
                    ,p_debug_mode                        => p_debug_mode
                    ,p_max_msg_count                     => p_max_msg_count
                    ,p_object_relationship_id            => cur_child_tasks_rec.object_relationship_id
                    ,p_record_version_number             => cur_child_tasks_rec.record_version_number
                    ,x_return_status                     => l_return_status
                    ,x_msg_count                         => l_msg_count
                    ,x_msg_data                          => l_msg_data
                    );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;

     PA_PROJ_ELEMENT_VERSIONS_PKG.Delete_Row( x_row_id );

     --Ansari
     --Call update wbs number
     PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS (
                               p_commit                   => p_commit
                              ,p_debug_mode               => p_debug_mode
                              ,p_parent_structure_ver_id  => x_parent_struc_ver_id
                              ,p_task_id                  => null
                              ,p_display_seq              => cur_child_tasks_rec.display_sequence
                              ,p_action                   => 'DELETE'
                              ,p_parent_task_id           => l_parent_task_verion_id
                              ,x_return_status            => l_return_status );

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                END IF;
             raise FND_API.G_EXC_ERROR;
             END IF;
     --Ansari

     IF  p_called_from_api <> 'MOVE_TASK_VERSION' THEN
        --Check if there are any versions exist
        OPEN cur_chk_vers( l_proj_element_id, cur_child_tasks_rec.object_id_to1 );
        FETCH cur_chk_vers INTO l_dummy_char;
        IF cur_chk_vers%NOTFOUND
        THEN

           -- 4201927 Performance Fix :: Commented below code to derive l_progress_flag , which is not
           -- used in further processing
           -- Also commented cursor usage to derive the row id as direct delete statement is used
           /*
           --3035902: process update flag changes
           --get progressable flag
           OPEN get_task_type_id(l_proj_element_id);
           FETCH get_task_type_id into l_task_type_id;
           CLOSE get_task_type_id;
           l_progress_flag := pa_task_type_utils.check_tk_type_progressable(l_task_type_id);
           --3035902: end process update flag changes

           OPEN cur_proj_elems( l_proj_element_id );
           FETCH cur_proj_elems INTO x_row_id_elem;
           CLOSE cur_proj_elems;
           */
           -- 4201927 end
           --dbms_output.put_line( 'Task Id '||l_proj_element_id );

           -- Added by skannoji
           -- Deleting deliverable task
           If (PA_PROJECT_STRUCTURE_UTILS.check_Deliverable_enabled(x_project_id) = 'Y' ) THEN
             PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk(
               p_task_element_id  => l_proj_element_id
              ,p_project_id       => x_project_id
              ,p_task_version_id  => cur_child_tasks_rec.object_id_to1
              , x_return_status   => x_return_status
              , x_msg_count       => x_msg_count
              , x_msg_data        => x_msg_data);
           End If;
           -- Added by skannoji end here

           IF x_return_status = FND_API.G_RET_STS_ERROR then
               RAISE FND_API.G_EXC_ERROR;
           End If;

           -- 4201927 Commented below code
           /*
           PA_PROJ_ELEMENTS_PKG.delete_row( x_row_id_elem );
           */

           -- USING direct delete statement on table
           DELETE FROM PA_PROJ_ELEMENTS WHERE PROJ_ELEMENT_ID = l_proj_element_id;

           -- 4201927 end
            -- anlee
            -- Ext Attribute changes
            -- Bug 2904327

            PA_USER_ATTR_PUB.DELETE_ALL_USER_ATTRS_DATA (
             p_validate_only             => FND_API.G_FALSE
            ,p_project_id                => x_project_id
            ,p_proj_element_id           => l_proj_element_id
            ,x_return_status             => l_return_status
            ,x_msg_count                 => l_msg_count
            ,x_msg_data                  => l_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              x_return_status := 'E';
              RAISE  FND_API.G_EXC_ERROR;
            END IF;
          -- anlee end of changes

--bug 3055766
            PA_TASK_PUB1.Delete_Task_Associations(
              p_task_id              => l_proj_element_id
             ,x_return_status        => l_return_status
             ,x_msg_count            => l_msg_count
             ,x_msg_data             => l_msg_data
              );
            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              x_return_status := 'E';
              RAISE  FND_API.G_EXC_ERROR;
            END IF;

--End bug 3055766


        END IF;
        CLOSE cur_chk_vers;
      END IF;  --p_called_from_api chk.

   END IF;  --cur_proj_elem_ver%FOUND check
   CLOSE cur_proj_elem_ver;
   --
   l_task_cnt := nvl( l_task_cnt, 0 ) + 1;
   IF cur_child_tasks_rec.object_id_to1 = p_task_version_id
   THEN
      l_selected_seq_num := cur_child_tasks_rec.display_sequence;
   END IF;

   -- 4221374 For each sub task poulating the plsql table l_task_vesion_id

   task_index := task_index + 1;
   l_task_version_id_tbl.extend;
   l_task_version_id_tbl(task_index) := cur_child_tasks_rec.object_id_to1;

   -- commented below code , as it was getting called in loop
   -- Shifted this api out of for loop and passing the l_task_version_id_tbl plsql table to
   -- progres api

   /* Code to delete records from tables: pa_progress_rollup and pa_precent_completes. */

   /*
      BEGIN

           PA_PROGRESS_PUB.delete_working_wp_progress (
                     p_project_id               => x_project_id  -- Included for Better Performance : 4046005
                    ,p_task_version_id          => cur_child_tasks_rec.object_id_to1
                    ,p_calling_context          => 'TASK_VERSION'
                    ,x_return_status            => x_return_status
                    ,x_msg_count                => x_msg_count
                    ,x_Msg_data                 => x_msg_data
                    );

       EXCEPTION

           WHEN OTHERS THEN

                fnd_msg_pub.add_exc_msg(
                   p_pkg_name       => 'PA_TASK_PVT1',
                   p_procedure_name => 'Delete_Task_Version',
                   p_error_text     => SUBSTRB('PA_PROGRESS_PUB.delete_working_wp_progress:'||SQLERRM,1,240));

           RAISE FND_API.G_EXC_ERROR;

       END;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         RAISE FND_API.G_EXC_ERROR;

      END IF;
   */

   -- 4221374 end

END LOOP;

  -- 4221374 If task table is populated , call progress api to delete progress records

  IF nvl(l_task_version_id_tbl.LAST,0) >= 1 THEN

      BEGIN

           PA_PROGRESS_PUB.delete_working_wp_progress (
                     p_project_id               => x_project_id  -- Included for Better Performance : 4046005
                    ,p_task_version_id          => l_task_version_id_tbl  -- cur_child_tasks_rec.object_id_to1
                    ,p_calling_context          => 'TASK_VERSION'
                    ,x_return_status            => x_return_status
                    ,x_msg_count                => x_msg_count
                    ,x_Msg_data                 => x_msg_data
                    );

       EXCEPTION

           WHEN OTHERS THEN

                fnd_msg_pub.add_exc_msg(
                   p_pkg_name       => 'PA_TASK_PVT1',
                   p_procedure_name => 'Delete_Task_Version',
                   p_error_text     => SUBSTRB('PA_PROGRESS_PUB.delete_working_wp_progress:'||SQLERRM,1,240));

           RAISE FND_API.G_EXC_ERROR;

       END;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         RAISE FND_API.G_EXC_ERROR;

      END IF;

  END IF;

  -- 4221374 end
  -- Bug Fix 5070454
  -- User is getting the record is modified error. This is happening due to the following update
  -- This is bumping up the rvns of all the records with higher display number than the one that is
  -- being deleted.
  -- Hence commenting out the update of RVN here.

  BEGIN
  UPDATE PA_PROJ_ELEMENT_VERSIONS
     SET display_sequence = PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, 0, l_task_cnt, 'DELETE', 'DOWN')
--         record_version_number = record_version_number + 1
   WHERE parent_structure_version_id = x_parent_struc_ver_id
     AND (display_sequence > l_selected_seq_num)
     AND PA_PROJ_ELEMENTS_UTILS.link_flag ( proj_element_id ) = 'N';
  EXCEPTION
    WHEN OTHERS THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
      raise FND_API.G_EXC_ERROR;
  END;

--hsiu added, for dates rollup
  IF (l_peer_tasks_exist = 'Y') THEN
    -- 4201927 Using local variable rather than calling api again
    --IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(x_parent_struc_ver_id, 'WORKPLAN') = 'Y' then -- 4201927 commented

    IF l_structure_type_wp = 'Y' then -- 4201927 Added
          PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
                         p_commit => FND_API.G_FALSE,
                         p_element_versions => l_tasks_ver_ids,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

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
         RAISE FND_API.G_EXC_ERROR;
       end if;
    END IF;

  ELSE

    --check if any task exists for this structure version (if this is last task)
    OPEN get_tsk_cnt(p_structure_version_id);
    FETCH get_tsk_cnt Into l_tsk_ver_cnt;
    CLOSE get_tsk_cnt;

    IF (l_tsk_ver_cnt = 0) THEN
      --set scheduled dates to sysdate
      update pa_proj_elem_ver_schedule
      set SCHEDULED_START_DATE = trunc(sysdate),
          SCHEDULED_FINISH_DATE = trunc(sysdate),
          DURATION = 1,
          RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      where project_id = l_project_id and element_version_id = p_structure_version_id;

     -- Begin fix for Bug # 4506308.

     -- Rollup scheduled dates to the project level if the project is version disabled or
     -- if it is a template.

     l_ver_enabled := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id);

     open l_cur_projects_all(l_project_id);
     fetch l_cur_projects_all into l_template_flag, l_rec_ver_number;
     close l_cur_projects_all;

     IF (l_template_flag = 'Y' OR l_ver_enabled = 'N') THEN

       PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
          p_validate_only          => FND_API.G_FALSE
         ,p_project_id             => l_project_id
         ,p_date_type              => 'SCHEDULED'
         ,p_start_date             => trunc(sysdate)
         ,p_finish_date            => trunc(sysdate)
         ,p_record_version_number  => l_rec_ver_number
         ,x_return_status          => x_return_status
         ,x_msg_count              => x_msg_count
         ,x_msg_data               => x_msg_data );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     -- End fix for Bug # 4506308.

    END IF;
  END IF;

--hsiu added for task status
  OPEN get_latest_task_ver_id;
  FETCH get_latest_task_ver_id into l_latest_task_ver_rec;
  IF (get_latest_task_ver_id%NOTFOUND) OR
     (l_latest_task_ver_rec.parent_structure_version_id <> p_structure_version_id) THEN
    --no rollup necessary
    NULL;
  ELSE
    --Rollup structure
    PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,x_return_status => l_return_status
                 ,x_msg_count => l_msg_count
                 ,x_msg_data => l_msg_data
    );

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
      RAISE FND_API.G_EXC_ERROR;
    end if;

  END IF;
  CLOSE get_latest_task_ver_id;
--end task status changes


--hsiu
--added for task weighting
--IF (PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS( x_project_id ) ='MANUAL') THEN    --bug 3051413   --commenting this line for bug 3058051 issue # 1.

  PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
    p_task_version_id => l_old_parent_ver_id
   ,x_return_status   => l_return_status
   ,x_msg_count       => l_msg_count
   ,x_msg_data        => l_msg_data
  );

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
    RAISE FND_API.G_EXC_ERROR;
  end if;
--END IF;  --bug 3051413 --commenting out this line for bug 3058051 issue # 1
--end task weighting changes

--bug 3010538 (delete )

--IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(
--              x_parent_struc_ver_id, 'WORKPLAN') = 'Y' then  --bug 3051413

--bug 3053281 --set flag if not (Workplan and Effort)
--l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(x_project_id);
l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(x_parent_struc_ver_id, 'WORKPLAN');
l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(x_project_id);
--3035902: process update flag changes
--Bug No 3450684 SMukka Commented if condition
--IF ((l_wp_type = 'Y') AND
--    (l_weighting_basis_Code = 'EFFORT') AND
--    (l_progress_flag = 'Y')) THEN
   --end 3035902: process update flag changes
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => p_calling_module
     ,p_project_id            => x_project_id
     ,p_structure_version_id  => x_parent_struc_ver_id
     ,p_update_wbs_flag       => 'Y'
     ,x_return_status         => l_return_status
     ,x_msg_count             => l_msg_count
     ,x_msg_data              => l_msg_data);

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
-- end if;
--END IF; --bug 3051413

--End bug 3010538 (delete)


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_VER_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_VER_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'delete_Task_version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END delete_task_version;

-- API name                      : Create_Schedule_Version
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id IN  NUMBER  N   Not Null
-- p_calendar_id    IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_scheduled_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag IN  VARCHAR2    N   NULL    N
-- p_critical_flag  IN  VARCHAR2    N   NULL    N
-- x_pev_schedule_id    OUT NUMBER  N   NULL
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Schedule_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_element_version_id   IN  NUMBER,
 p_calendar_id        IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_scheduled_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date   IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date    IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date   IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration             IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date         IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date          IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag         IN    VARCHAR2    :='N',
 p_critical_flag          IN    VARCHAR2    :='N',
 p_WQ_PLANNED_QUANTITY        IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT             IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199

 x_pev_schedule_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_error_message_code           VARCHAR2(250);
    l_duration_days                NUMBER;

   l_data                     VARCHAR2(250);
   l_msg_index_out                 NUMBER;

   CURSOR cur_proj_elem_ver
   IS
     SELECT rowid, object_type, project_id, proj_element_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_element_version_id;

   cur_proj_elem_ver_rec cur_proj_elem_ver%ROWTYPE;
   X_Row_id  VARCHAR2(255);

   cursor get_cal_id IS
     select a.calendar_id
       from pa_projects_all a, pa_proj_element_versions b
      where a.project_id = b.project_id
        and b.element_version_id = p_element_version_id;

/* Bug 2791413 Begin */
  CURSOR get_project_id
   IS
     SELECT project_id,proj_element_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_element_version_id;


  cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;

 l_task_type_id      NUMBER;
 l_project_id        NUMBER;
 l_proj_element_id   NUMBER;

 /* Bug 2791413 End */

 l_calendar_id         NUMBER;
 l_scheduled_start_date  DATE;
 l_scheduled_end_date    DATE;
 l_obligation_start_date DATE;
 l_obligation_end_date   DATE;
 l_actual_start_date     DATE;
 l_actual_finish_date    DATE;
 l_estimated_start_date  DATE;
 l_estimated_finish_date     DATE;
 l_duration              NUMBER;
 l_early_start_date  DATE;
 l_early_end_date          DATE;
 l_late_start_date   DATE;
 l_late_end_date           DATE;
 l_wq_planned_quantity   NUMBER;
 l_planned_effort        NUMBER;
 l_critical_flag         VARCHAR2(1);
 l_milestone_flag        VARCHAR2(1);
 -- xxlu
 l_attribute_category      pa_proj_elem_ver_schedule.attribute_category%TYPE    ;
 l_attribute1              pa_proj_elem_ver_schedule.attribute1%TYPE            ;
 l_attribute2              pa_proj_elem_ver_schedule.attribute2%TYPE            ;
 l_attribute3              pa_proj_elem_ver_schedule.attribute3%TYPE            ;
 l_attribute4              pa_proj_elem_ver_schedule.attribute4%TYPE            ;
 l_attribute5              pa_proj_elem_ver_schedule.attribute5%TYPE            ;
 l_attribute6              pa_proj_elem_ver_schedule.attribute6%TYPE            ;
 l_attribute7              pa_proj_elem_ver_schedule.attribute7%TYPE            ;
 l_attribute8              pa_proj_elem_ver_schedule.attribute8%TYPE            ;
 l_attribute9              pa_proj_elem_ver_schedule.attribute9%TYPE            ;
 l_attribute10             pa_proj_elem_ver_schedule.attribute10%TYPE           ;
 l_attribute11             pa_proj_elem_ver_schedule.attribute11%TYPE           ;
 l_attribute12             pa_proj_elem_ver_schedule.attribute12%TYPE           ;
 l_attribute13             pa_proj_elem_ver_schedule.attribute13%TYPE           ;
 l_attribute14             pa_proj_elem_ver_schedule.attribute14%TYPE           ;
 l_attribute15             pa_proj_elem_ver_schedule.attribute15%TYPE           ;
 -- end xxlu changes

--hsiu added for duration calculation
    l_act_duration_days            NUMBER;
    l_act_duration                 NUMBER;
    l_est_duration_days            NUMBER;
    l_est_duration                 NUMBER;

 --bug 3305199 schedule options
 l_def_sch_tool_tsk_type_code  VARCHAR2(30);
 l_constraint_type_code        VARCHAR2(30);
 l_constraint_date             DATE;
 l_free_slack                  NUMBER;
 l_total_slack                 NUMBER;
 l_effort_driven_flag          VARCHAR2(1);
 l_level_assignments_flag      VARCHAR2(1);
 --end bug 3305199

 l_Structure_Version_ID     NUMBER; -- FP_M changes 3305199
 l_ext_act_duration             NUMBER;
 l_ext_remain_duration          NUMBER;
 l_ext_sch_duration             NUMBER;
BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PVT1.CREATE_SCHEDULE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_SCH_VER_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;


    IF ( p_calendar_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_calendar_id IS NULL )
    THEN
       OPEN get_cal_id;
       FETCH get_cal_id INTO l_calendar_id;
       CLOSE get_cal_id;
    ELSE
       l_calendar_id := p_calendar_id;
    END IF;

    IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_start_date IS NOT NULL )
    THEN
       l_scheduled_start_date := null;
    ELSE
       l_scheduled_start_date := trunc(p_scheduled_start_date);
    END IF;

    IF ( p_scheduled_end_date   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_end_date IS NOT NULL )
    THEN
       l_scheduled_end_date := null;
    ELSE
       l_scheduled_end_date := trunc(p_scheduled_end_date);
    END IF;

    IF ( p_obligation_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_obligation_start_date IS NOT NULL )
    THEN
       l_obligation_start_date := null;
    ELSE
       l_obligation_start_date := p_obligation_start_date;
    END IF;

    IF ( p_obligation_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_obligation_end_date IS NOT NULL )
    THEN
       l_obligation_end_date := null;
    ELSE
       l_obligation_end_date := p_obligation_end_date;
    END IF;

    IF ( p_actual_start_date    = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_actual_start_date IS NOT NULL )
    THEN
       l_actual_start_date := null;
    ELSE
       l_actual_start_date := p_actual_start_date;
    END IF;

    IF ( p_actual_finish_date   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_actual_finish_date IS NOT NULL )
    THEN
       l_actual_finish_date := null;
    ELSE
       l_actual_finish_date := p_actual_finish_date;
    END IF;

    IF ( p_estimate_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_estimate_start_date IS NOT NULL )
    THEN
       l_estimated_start_date := null;
    ELSE
       l_estimated_start_date := p_estimate_start_date;
    END IF;

    IF ( p_estimate_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_estimate_finish_date IS NOT NULL )
    THEN
       l_estimated_finish_date := null;
    ELSE
       l_estimated_finish_date := p_estimate_finish_date;
    END IF;

    IF ( p_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_duration IS NOT NULL )
    THEN
       l_duration := null;
    ELSE
       l_duration := p_duration;
    END IF;

    IF ( p_early_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_early_start_date IS NOT NULL )
    THEN
       l_early_start_date := null;
    ELSE
       l_early_start_date := p_early_start_date;
    END IF;

    IF ( p_early_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_early_end_date IS NOT NULL )
    THEN
       l_early_end_date := null;
    ELSE
       l_early_end_date := p_early_end_date;
    END IF;

    IF ( p_late_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_late_start_date IS NOT NULL )
    THEN
       l_late_start_date := null;
    ELSE
       l_late_start_date := p_late_start_date;
    END IF;

    IF ( p_late_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_late_end_date IS NOT NULL )
    THEN
       l_late_end_date := null;
    ELSE
       l_late_end_date := p_late_end_date;
    END IF;

    IF (p_milestone_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_milestone_flag IS NOT NULL) THEN
      l_milestone_flag := 'N';
    ELSE
      l_milestone_flag := p_milestone_flag;
    END IF;

    IF (p_critical_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_critical_flag IS NOT NULL) THEN
      l_critical_flag := 'N';
    ELSE
      l_critical_flag := p_critical_flag;
    END IF;

    IF ( p_ext_act_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_act_duration IS NOT NULL )
    THEN
       l_ext_act_duration := null;
    ELSE
       l_ext_act_duration := p_ext_act_duration;
       --hsiu: bug 3638195
       IF l_ext_act_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_ACT_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF ( p_ext_remain_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_remain_duration IS NOT NULL )
    THEN
       l_ext_remain_duration := null;
    ELSE
       l_ext_remain_duration := p_ext_remain_duration;
       --hsiu: bug 3638195
       IF l_ext_remain_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_RMN_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF ( p_ext_sch_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_sch_duration IS NOT NULL )
    THEN
       l_ext_sch_duration := null;
    ELSE
       l_ext_sch_duration := p_ext_sch_duration;
       --hsiu: bug 3638195
       IF l_ext_sch_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_SCH_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- xxlu
    IF (p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL) THEN
      l_attribute_category := null;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;

    IF (p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL) THEN
      l_attribute1 := null;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;

    IF (p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL) THEN
      l_attribute2 := null;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;

    IF (p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL) THEN
      l_attribute3 := null;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;

    IF (p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL) THEN
      l_attribute4 := null;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;

    IF (p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL) THEN
      l_attribute5 := null;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;

    IF (p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL) THEN
      l_attribute6 := null;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;

    IF (p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL) THEN
      l_attribute7 := null;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;

    IF (p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL) THEN
      l_attribute8 := null;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;

    IF (p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL) THEN
      l_attribute9 := null;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;

    IF (p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL) THEN
      l_attribute10 := null;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;

    IF (p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL) THEN
      l_attribute11 := null;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;

    IF (p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL) THEN
      l_attribute12 := null;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;

    IF (p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL) THEN
      l_attribute13 := null;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;

    IF (p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL) THEN
      l_attribute14 := null;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;

    IF (p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL) THEN
      l_attribute15 := null;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;
    -- end xxlu changes.


    PA_PROJ_ELEMENTS_UTILS.Check_Date_range(
                    p_scheduled_start_date  => l_scheduled_start_date
                   ,p_scheduled_end_date          => l_scheduled_end_date
                   ,p_obligation_start_date     => l_obligation_start_date
                   ,p_obligation_end_date         => l_obligation_end_date
                   ,p_actual_start_date       => l_actual_start_date
                   ,p_actual_finish_date          => l_actual_finish_date
                   ,p_estimate_start_date         => l_estimated_start_date
                   ,p_estimate_finish_date  => l_estimated_finish_date
                   ,p_early_start_date        => l_early_start_date
                   ,p_early_end_date          => l_early_end_date
                   ,p_late_start_date         => l_late_start_date
                   ,p_late_end_date           => l_late_end_date
                   ,x_return_status             => l_return_status
                   ,x_error_message_code        => l_error_message_code );

    IF (l_return_status <> 'S') THEN
      PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
      l_msg_data := l_error_message_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

--3305199: Remove duration calculation using calendar
   l_duration := trunc(l_scheduled_end_date) - trunc(l_scheduled_start_date) + 1;
/* 3305199
   --removing duration calculation
    PA_DURATION_UTILS.GET_DURATION(
       p_calendar_id => l_calendar_id
      ,p_start_date => l_scheduled_start_date
      ,p_end_date => l_scheduled_end_date
      ,x_duration_days => l_duration_days
      ,x_duration_hours => l_duration
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
    );

    IF (l_return_status <> 'S') THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

/*
    IF ( l_scheduled_start_date IS NOT NULL AND l_duration IS NOT NULL )
    THEN
--Hsiu modified
       l_scheduled_end_date := l_scheduled_start_date + l_duration - 1;
    ELSIF ( l_scheduled_start_date IS NOT NULL AND l_scheduled_end_date IS NOT NULL AND l_duration IS NOT NULL )
    THEN
--Hsiu modified
       l_scheduled_end_date := l_scheduled_start_date + l_duration - 1;

    ELSIF ( l_scheduled_start_date IS NOT NULL AND l_scheduled_end_date IS NOT NULL )
    THEN
       IF l_duration is NULL
       THEN
--Hsiu modified
          l_duration :=  trunc(l_scheduled_end_date - l_scheduled_start_date) + 1;
       END IF;
    ELSIF ( l_scheduled_start_date IS NULL AND l_scheduled_end_date IS NULL AND l_duration IS NULL )
    THEN
       l_scheduled_start_date := trunc(SYSDATE);
       l_scheduled_end_date := trunc(SYSDATE);
       l_duration           := 1;
    END IF;
*/

--3305199: Remove duration calculation using calendar
   l_est_duration := trunc(l_estimated_finish_date) - trunc(l_estimated_start_date) + 1;
/* 3305199
   --removing duration calculation
    --hsiu modified for duration calculation using calendar
    IF (l_estimated_start_date IS NOT NULL AND
        l_estimated_finish_date IS NOT NULL) THEN

      --calculate duration
        pa_duration_utils.get_duration(
         p_calendar_id      => l_calendar_id
                ,p_start_date       => l_estimated_start_date
            ,p_end_date         => l_estimated_finish_date
                ,x_duration_days    => l_est_duration_days
                ,x_duration_hours   => l_est_duration
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

    END IF;
*/

--3305199: Remove duration calculation using calendar
--  This assignment was over writting the schedule duration value, replaced l_duration by l_act_duration variable
--   l_duration := trunc(l_actual_finish_date) - trunc(l_actual_start_date) + 1;   --Bug No 3615013
   l_act_duration := trunc(l_actual_finish_date) - trunc(l_actual_start_date) + 1;

/* 3305199
   --removing duration calculation
    IF (l_actual_start_date IS NOT NULL AND
        l_actual_finish_date IS NOT NULL) THEN
      --calculate duration
        pa_duration_utils.get_duration(
         p_calendar_id      => l_calendar_id
                ,p_start_date       => l_actual_start_date
            ,p_end_date         => l_actual_finish_date
                ,x_duration_days    => l_act_duration_days
                ,x_duration_hours   => l_act_duration
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

    END IF;
*/

--Changes for bug 2791413 Added check for work quantity enabled
    OPEN get_project_id;
    FETCH get_project_id into l_project_id,l_proj_element_id;
    CLOSE get_project_id;

    OPEN get_task_type_id(l_proj_element_id);
    FETCH get_task_type_id into l_task_type_id;
    CLOSE get_task_type_id;

/*    IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_task_type_id) OR
        'N' = PA_PROGRESS_UTILS.get_project_wq_flag(l_project_id)) THEN
       --error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_ENT_WQ_ATTR1');
        x_msg_data := 'PA_PS_CANT_ENT_WQ_ATTR1';
        RAISE FND_API.G_EXC_ERROR;
    ELSE  */
  -- Above code is commented and moved below to first check whether any value has been passed in p_wq_planned_quantity

      IF (p_wq_planned_quantity IS NULL OR p_wq_planned_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        l_wq_planned_quantity := NULL;
      ELSE
        l_wq_planned_quantity := p_wq_planned_quantity;
      END IF;


   -- Bug Fix 5726773
   -- Commenting out the following in order to allow
   -- negative amounts which are entered through Create Tasks page
   -- while creating a task.
   IF (l_wq_planned_quantity IS NOT NULL) THEN
   /*
      IF (l_wq_planned_quantity < 0) THEN
        --error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_PLAN_QTY_ERR');
        x_msg_data := 'PA_PS_NEG_PLAN_QTY_ERR';
        RAISE FND_API.G_EXC_ERROR;
  -- Else condition added for Bug No. : 2791413
      ELSE
      */
        IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_task_type_id) OR
            'N' = PA_PROGRESS_UTILS.get_project_wq_flag(l_project_id)) THEN
             --error message
             PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_ENT_WQ_ATTR1');
             x_msg_data := 'PA_PS_CANT_ENT_WQ_ATTR1';
             RAISE FND_API.G_EXC_ERROR;
     End IF;
     -- END IF;
    END IF;

    IF (p_planned_effort IS NULL OR p_planned_effort = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_planned_effort := NULL;
    ELSE
      l_planned_effort := p_planned_effort;
    END IF;

    -- Bug Fix 5726773
    -- Commenting out the following in order to allow
    -- negative amounts which are entered through Create Tasks page
    -- while creating a task.
    /*
    IF (l_planned_effort IS NOT NULL) THEN
      IF (l_planned_effort < 0) THEN
        --error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_PLAN_EFF_ERR');
        x_msg_data := 'PA_PS_NEG_PLAN_EFF_ERR';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    */
    -- END of Bug Fix 5726773

    --Bug 3305199: Added for M
    IF (p_def_sch_tool_tsk_type_code IS NULL OR p_def_sch_tool_tsk_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_def_sch_tool_tsk_type_code := NULL;
    ELSE
      l_def_sch_tool_tsk_type_code := p_def_sch_tool_tsk_type_code;
    END IF;

    IF (p_constraint_type_code IS NULL OR p_constraint_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_constraint_type_code := NULL;
    ELSE
      l_constraint_type_Code := p_constraint_type_code;
    END IF;

    IF (p_constraint_date IS NULL OR p_constraint_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      l_constraint_date := NULL;
    ELSE
      l_constraint_date := p_constraint_date;
    END IF;

    IF (p_free_slack IS NULL OR p_free_slack = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_free_slack := NULL;
    ELSE
      l_free_slack := p_free_slack;
    END IF;

    IF (p_total_slack IS NULL OR p_total_slack = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_total_slack := NULL;
    ELSE
      l_total_slack := p_total_slack;
    END IF;

    IF (p_effort_driven_flag IS NULL OR p_effort_driven_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_effort_driven_flag := 'N';
    ELSE
      l_effort_driven_flag := p_effort_driven_flag;
    END IF;

    IF (p_level_assignments_flag IS NULL OR p_level_assignments_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_level_assignments_flag := 'N';
    ELSE
      l_level_assignments_flag := p_level_assignments_flag;
    END IF;
    --end bug 3305199

    -- Added for FP_M changes 3305199 Bhumesh
    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(l_Project_ID)= 'Y' Then

       Select Parent_Structure_Version_ID INTO l_Structure_Version_ID
       From   PA_Proj_Element_Versions
       Where  Element_Version_ID = P_Element_Version_ID;

          PA_PROJECT_STRUCTURE_PVT1.update_sch_dirty_flag(
             p_structure_version_id => l_Structure_Version_ID
            ,p_dirty_flag           => 'Y'             --bug 3902282
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            x_msg_count := FND_MSG_PUB.count_msg;
            If x_msg_count = 1 then
              pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
            End If;
            raise FND_API.G_EXC_ERROR;
          End If;
    End If;
    -- End of FP_M changes

    OPEN cur_proj_elem_ver;
    FETCH cur_proj_elem_ver INTO cur_proj_elem_ver_rec;
    IF cur_proj_elem_ver%FOUND
    THEN
       PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID                => X_Row_Id
        ,X_PEV_SCHEDULE_ID     => x_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => p_ELEMENT_VERSION_ID
        ,X_PROJECT_ID            => cur_proj_elem_ver_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => cur_proj_elem_ver_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_SCHEDULED_END_DATE
        ,X_OBLIGATION_START_DATE => l_OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_OBLIGATION_end_DATE
        ,X_ACTUAL_START_DATE        => l_ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_DURATION
        ,X_EARLY_START_DATE     => l_EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_EARLY_end_DATE
        ,X_LATE_START_DATE      => l_LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_LATE_end_DATE
        ,X_CALENDAR_ID            => l_CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_planned_effort
        ,X_ACTUAL_DURATION          => l_act_duration
        ,X_ESTIMATED_DURATION       => l_est_duration
        ,X_def_sch_tool_tsk_type_code => l_def_sch_tool_tsk_type_code
        ,X_constraint_type_code     => l_constraint_type_code
        ,X_constraint_date          => l_constraint_date
        ,X_free_slack               => l_free_slack
        ,X_total_slack              => l_total_slack
        ,X_effort_driven_flag       => l_effort_driven_flag
        ,X_level_assignments_flag   => l_level_assignments_flag
        ,X_ext_act_duration         => l_ext_act_duration
        ,X_ext_remain_duration      => l_ext_remain_duration
        ,X_ext_sch_duration         => l_ext_sch_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ATTRIBUTE15
        ,X_SOURCE_OBJECT_ID               => cur_proj_elem_ver_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE             => 'PA_PROJECTS'
       );
    ELSE
      CLOSE cur_proj_elem_ver;
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INVALID_TASK_ID');
      l_msg_data := 'PA_PS_INVALID_TASK_ID';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_proj_elem_ver;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_SCH_VER_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_SCH_VER_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'create_schedule_version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Create_Schedule_Version;

-- API name                      : Update_Schedule_Version
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id IN  NUMBER  N   Not Null
-- p_calendar_id    IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_scheduled_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag IN  VARCHAR2    N   NULL    N
-- p_critical_flag  IN  VARCHAR2    N   NULL    N
-- x_pev_schedule_id    OUT NUMBER  N   NULL
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Update_Schedule_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pev_schedule_id  IN  NUMBER,
 p_calendar_id        IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_scheduled_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date   IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date    IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date   IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration             IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date         IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date          IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag         IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410
 p_critical_flag          IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410
 p_wq_planned_quantity        IN        NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_planned_effort             IN        NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  --bug 3305199
 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199
 p_record_version_number IN   NUMBER,
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   CURSOR cur_proj_elem_ver_sch
   IS
     SELECT rowid, element_version_id, project_id, proj_element_id, record_version_number
       FROM pa_proj_elem_ver_schedule
      WHERE pev_schedule_id = p_pev_schedule_id;
   cur_proj_elem_ver_sch_rec cur_proj_elem_ver_sch%ROWTYPE;

   CURSOR get_actual_wq(c_project_id NUMBER, c_element_id NUMBER) IS
     select ppru.CUMULATIVE_WORK_QUANTITY
       from pa_progress_rollup ppru, pa_percent_completes ppc
      where ppc.project_id = c_project_id
        and ppc.task_id = c_element_id
        and ppc.current_flag = 'Y'
        and ppc.project_Id = ppru.project_id
        and ppc.task_id = ppru.object_id
        and ppru.object_type = 'PA_TASKS';

    CURSOR get_info IS
      select proj_element_id, project_id
        from pa_proj_elem_ver_schedule
       where pev_schedule_id = p_pev_schedule_id;
    l_project_id NUMBER;
    l_proj_element_id NUMBER;

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_return_status                VARCHAR2(2);
    l_error_message_code           VARCHAR2(250);
--hsiu added for duration calculation
    l_act_duration_days            NUMBER;
    l_act_duration                 NUMBER;
    l_est_duration_days            NUMBER;
    l_est_duration                 NUMBER;
    l_critical_flag         VARCHAR2(1);
    l_milestone_flag        VARCHAR2(1);

    CURSOR cur_val IS
      select *
        from pa_proj_elem_ver_schedule
       where pev_schedule_id = p_pev_schedule_id;
    cur_val_rec   cur_val%ROWTYPE;
--end duration changes

--hsiu added for bug 2634195
    cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
    l_task_type_id      NUMBER;
--end bug 2634195

 l_calendar_id         NUMBER;
 l_scheduled_start_date  DATE;
 l_scheduled_end_date    DATE;
 l_obligation_start_date DATE;
 l_obligation_end_date   DATE;
 l_actual_start_date     DATE;
 l_actual_finish_date    DATE;
 l_estimated_start_date  DATE;
 l_estimated_finish_date     DATE;
 l_duration              NUMBER;
 l_duration_days         NUMBER;
 l_early_start_date  DATE;
 l_early_end_date          DATE;
 l_late_start_date   DATE;
 l_late_end_date           DATE;
 l_wq_planned_quantity   NUMBER;
 l_planned_effort        NUMBER;
 -- xxlu
 l_attribute_category      pa_proj_elem_ver_schedule.attribute_category%TYPE    ;
 l_attribute1              pa_proj_elem_ver_schedule.attribute1%TYPE            ;
 l_attribute2              pa_proj_elem_ver_schedule.attribute2%TYPE            ;
 l_attribute3              pa_proj_elem_ver_schedule.attribute3%TYPE            ;
 l_attribute4              pa_proj_elem_ver_schedule.attribute4%TYPE            ;
 l_attribute5              pa_proj_elem_ver_schedule.attribute5%TYPE            ;
 l_attribute6              pa_proj_elem_ver_schedule.attribute6%TYPE            ;
 l_attribute7              pa_proj_elem_ver_schedule.attribute7%TYPE            ;
 l_attribute8              pa_proj_elem_ver_schedule.attribute8%TYPE            ;
 l_attribute9              pa_proj_elem_ver_schedule.attribute9%TYPE            ;
 l_attribute10             pa_proj_elem_ver_schedule.attribute10%TYPE           ;
 l_attribute11             pa_proj_elem_ver_schedule.attribute11%TYPE           ;
 l_attribute12             pa_proj_elem_ver_schedule.attribute12%TYPE           ;
 l_attribute13             pa_proj_elem_ver_schedule.attribute13%TYPE           ;
 l_attribute14             pa_proj_elem_ver_schedule.attribute14%TYPE           ;
 l_attribute15             pa_proj_elem_ver_schedule.attribute15%TYPE           ;
 -- end xxlu changes

--hsiu added, for dates rollup
 l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
 l_actual_wq NUMBER;

--hsiu: bug 3035902
 l_update_flag VARCHAR2(1) := 'N';
 l_parent_struc_Ver_id NUMBER;
 cursor get_parent_struc_ver_id(c_elem_ver_id NUMBER) IS
   select parent_structure_version_id
     from pa_proj_element_versions
    where element_version_id = c_elem_ver_id;

 --3035902: process update flag changes
 l_weighting_basis         VARCHAR2(30);
 --3035902: end process update flag changes

 --bug 3305199 schedule options
 l_def_sch_tool_tsk_type_code  VARCHAR2(30);
 l_constraint_type_code        VARCHAR2(30);
 l_constraint_date             DATE;
 l_free_slack                  NUMBER;
 l_total_slack                 NUMBER;
 l_effort_driven_flag          VARCHAR2(1);
 l_level_assignments_flag      VARCHAR2(1);
 --end bug 3305199

 l_Structure_Version_ID     NUMBER;     -- FP_M changes 3305199

 --bug 3301192 fp changes
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /* l_task_ver_ids2             PA_PLSQL_DATATYPES.IdTabTyp;                      */
  l_task_ver_ids2             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
  l_planned_effort2           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
  l_start_dates               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type(); /* Venky */
  l_end_dates                 SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type(); /* Venky */

  --hsiu: 3453772
  l_old_sch_date DATE;
  l_res_asgmt_id_tbl SYSTEM.PA_NUM_TBL_TYPE;
  l_planning_start_tbl SYSTEM.pa_date_tbl_type;
  l_planning_end_tbl SYSTEM.pa_date_tbl_type;

  l_ext_act_duration             NUMBER;
  l_ext_remain_duration          NUMBER;
  l_ext_sch_duration             NUMBER;

  l_update_effort_flag            VARCHAR2(1) := 'N';
  l_schedule_update_flag          VARCHAR2(1) := 'N';

  l_assgn_context                 VARCHAR2(30);  --bug 4153366

  l_task_has_sub_proj_flag        VARCHAR2(1) := 'N'; --bug 4620492
  l_debug_mode                    VARCHAR2(1) := 'N';

  -- Added for Bug 8319801
  l_proj_element_id_temp          NUMBER;
  l_financial_task_flag_tmp       VARCHAR2(1);
  l_workplan_version_enable_flag  pa_proj_workplan_attr.wp_enable_version_flag%TYPE;

BEGIN

    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF (l_debug_mode = 'Y') THEN
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION begin',3);
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_SCH_VER_PRIVATE;
    END IF;

    IF (l_debug_mode = 'Y') THEN
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'Performing validations',3);
    END IF;

    OPEN cur_val;
    FETCH cur_val into cur_val_rec;
    CLOSE cur_val;

    --3035902: process update flag changes
    l_weighting_basis := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS( cur_val_rec.project_id);
    --3035902: end process update flag changes

    OPEN get_task_type_id(cur_val_rec.proj_element_id);
    FETCH get_task_type_id into l_task_type_id;
    CLOSE get_task_type_id;

/*    IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_task_type_id) OR
        'N' = PA_PROGRESS_UTILS.get_project_wq_flag(cur_val_rec.project_id)) THEN
       -- Bug 2791413 Added error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_ENT_WQ_ATTR1');
        x_msg_data := 'PA_PS_CANT_ENT_WQ_ATTR1';
        RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF (p_wq_planned_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        l_wq_planned_quantity := cur_val_rec.WQ_PLANNED_QUANTITY;
      ELSE
        l_wq_planned_quantity := p_wq_planned_quantity;
      END IF;
    END IF;  */

-- Above commented code is Changed to below to cheque if any value is being passed into work quantity or not

    IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_wq_enabled(l_task_type_id) OR
        'N' = PA_PROGRESS_UTILS.get_project_wq_flag(cur_val_rec.project_id)) THEN
  -- If condition added for Bug No. : 2791413
        IF (p_wq_planned_quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_wq_planned_quantity IS NOT NULL) THEN
                 -- Bug 2791413 Added error message
                 PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_ENT_WQ_ATTR1');
                 x_msg_data := 'PA_PS_CANT_ENT_WQ_ATTR1';
                 RAISE FND_API.G_EXC_ERROR;
        END IF;
      l_wq_planned_quantity := NULL;
    ELSE
      IF (p_wq_planned_quantity = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        l_wq_planned_quantity := cur_val_rec.WQ_PLANNED_QUANTITY;
      ELSE
        l_wq_planned_quantity := p_wq_planned_quantity;
      END IF;
    END IF;

    -- Bug Fix 5726773
    -- Commenting out the following in order to allow
    -- negative amounts which are entered through Create Tasks page
    -- while creating a task.
   /*
    IF (l_wq_planned_quantity IS NOT NULL) THEN
      IF (l_wq_planned_quantity < 0) THEN
        --error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_PLAN_QTY_ERR');
        x_msg_data := 'PA_PS_NEG_PLAN_QTY_ERR';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
*/
--hsiu: removing validation
--    IF (l_wq_planned_quantity IS NOT NULL) THEN
--      OPEN get_info;
--      FETCH get_info INTO l_project_id, l_proj_element_id;
--      CLOSE get_info;
--      OPEN get_actual_wq(l_project_id, l_proj_element_id);
--      FETCH get_actual_wq into l_actual_wq;
--      IF get_actual_wq%FOUND THEN
--        PA_TASK_TYPE_UTILS.check_planned_quantity(
--          p_planned_quantity => l_wq_planned_quantity,
--          p_actual_work_quantity => l_actual_wq,
--          x_return_status => l_return_status,
--          x_msg_count => l_msg_count,
--          x_msg_data => l_msg_data
--        );
--        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          l_msg_count := FND_MSG_PUB.count_msg;
--          IF l_msg_count > 0 THEN
--            x_msg_count := l_msg_count;
--              IF x_msg_count = 1 THEN
--                x_msg_data := l_msg_data;
--              END IF;
--            RAISE FND_API.G_EXC_ERROR;
--          END IF;
--        END IF;
--      END IF;
--    END IF;

    IF ( p_calendar_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_calendar_id IS NULL )
    THEN
       l_calendar_id := cur_val_rec.calendar_id;
    ELSE
       l_calendar_id := p_calendar_id;
    END IF;

    --hsiu: bug 3453772
    l_old_sch_date := cur_val_rec.scheduled_Start_Date;

    --bug 4620492 do not update sch dates and planned effort of a linked task if called from AMG.
    l_task_has_sub_proj_flag := PA_RELATIONSHIP_UTILS.check_task_has_sub_proj( cur_val_rec.project_id,
                                       cur_val_rec.proj_element_id, cur_val_rec.element_version_id);
    --end bug 4620492

    IF (l_debug_mode = 'Y') THEN
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'l_task_has_sub_proj_flag='||l_task_has_sub_proj_flag,3);
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'p_calling_module='||p_calling_module,3);
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'cur_val_rec.scheduled_START_DATE='|| cur_val_rec.scheduled_START_DATE,3);
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'cur_val_rec.scheduled_FINISH_DATE='||cur_val_rec.scheduled_FINISH_DATE,3);
      pa_debug.write('PA_TASK_PVT1.UPDATE_SCHEDULE_VERSION', 'cur_val_rec.PLANNED_EFFORT='||cur_val_rec.PLANNED_EFFORT,3);
    END IF;

--For bug 2638649
    IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_start_date IS NOT NULL )
    THEN
       l_scheduled_start_date := cur_val_rec.scheduled_START_DATE;
    ELSE
       l_scheduled_start_date := p_scheduled_start_date;

    --bug 4620492
       IF l_task_has_sub_proj_flag = 'Y' AND
          p_calling_module = 'AMG'
       THEN
          l_scheduled_start_date := cur_val_rec.scheduled_START_DATE;
       END IF;
    --end bug 4620492

       IF (l_scheduled_start_date <> cur_val_rec.scheduled_start_date) THEN
         l_schedule_update_flag := 'Y';
       END IF;
       /* Bug 3053846 - Rather than checking for dates, let us check for change in duration.
       --hsiu: bug 3035902
       IF (l_scheduled_start_date <> cur_val_rec.scheduled_start_date) THEN
         IF (l_weighting_basis ='DURATION') THEN
           --set the flag if the dates have changed
           l_update_flag := 'Y';
         END IF;
       END IF;
       --end bug 3035902
       Bug 3053846 */
    END IF;

    IF ( p_scheduled_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_scheduled_end_date IS NOT NULL )
    THEN
       l_scheduled_end_date := cur_val_rec.scheduled_FINISH_DATE;
    ELSE
       l_scheduled_end_date := p_scheduled_end_date;

    --bug 4620492
       IF l_task_has_sub_proj_flag = 'Y' AND
          p_calling_module = 'AMG'
       THEN
          l_scheduled_end_date := cur_val_rec.scheduled_FINISH_DATE;
       END IF;
    --end bug 4620492

       IF (l_scheduled_end_date <> cur_val_rec.scheduled_finish_date) THEN
         l_schedule_update_flag := 'Y';
       END IF;
       /* Bug 3053846 - Rather than checking for dates, let us check for change in duration.
       --hsiu: bug 3035902
       IF (l_scheduled_end_date <> cur_val_rec.scheduled_finish_date) THEN
         IF (l_weighting_basis ='DURATION') THEN
           --set the flag if the dates have changed
           l_update_flag := 'Y';
         END IF;
       END IF;
       --end bug 3035902
       Bug 3053846 */
    END IF;

--For bug 2638649
--    IF ( p_scheduled_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_scheduled_start_date IS NULL )
    IF l_scheduled_start_date IS NULL
    THEN
       -- For bug 2625650
       -- l_scheduled_start_date := cur_val_rec.SCHEDULED_START_DATE;
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_SCH_DATES_REQD');
      l_msg_data := 'PA_PS_SCH_DATES_REQD';
      RAISE FND_API.G_EXC_ERROR;
      -- End of bug fix
--    ELSE
--       l_scheduled_start_date := TRUNC(p_scheduled_start_date);
    END IF;

--    IF ( p_scheduled_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_scheduled_end_date IS NULL )
    IF l_scheduled_end_date IS NULL
    THEN
       -- For bug 2625650
       --l_scheduled_end_date := cur_val_rec.SCHEDULED_FINISH_DATE;
       PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_SCH_DATES_REQD');
       l_msg_data := 'PA_PS_SCH_DATES_REQD';
       RAISE FND_API.G_EXC_ERROR;
       -- End of bug fix
--    ELSE
--       l_scheduled_end_date := TRUNC(p_scheduled_end_date);
    END IF;

    IF ( p_obligation_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_obligation_start_date IS NOT NULL )
    THEN
       l_obligation_start_date := cur_val_rec.OBLIGATION_START_DATE;
    ELSE
       l_obligation_start_date := p_obligation_start_date;
    END IF;

    IF ( p_obligation_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_obligation_end_date IS NOT NULL )
    THEN
       l_obligation_end_date := cur_val_rec.OBLIGATION_FINISH_DATE;
    ELSE
       l_obligation_end_date := p_obligation_end_date;
    END IF;

    IF ( p_actual_start_date    = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_actual_start_date IS NOT NULL )
    THEN
       l_actual_start_date := cur_val_rec.actual_start_date;
    ELSE
       l_actual_start_date := p_actual_start_date;
    END IF;

    IF ( p_actual_finish_date   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_actual_finish_date IS NOT NULL )
    THEN
       l_actual_finish_date := cur_val_rec.actual_finish_date;
    ELSE
       l_actual_finish_date := p_actual_finish_date;
    END IF;

    IF ( p_estimate_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_estimate_start_date IS NOT NULL )
    THEN
       l_estimated_start_date := cur_val_rec.estimated_start_date;
    ELSE
       l_estimated_start_date := p_estimate_start_date;
    END IF;

    IF ( p_estimate_finish_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_estimate_finish_date IS NOT NULL )
    THEN
       l_estimated_finish_date := cur_val_rec.estimated_finish_date;
    ELSE
       l_estimated_finish_date := p_estimate_finish_date;
    END IF;

    IF ( p_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_duration IS NOT NULL )
    THEN
       l_duration := cur_val_rec.duration;
    ELSE
       l_duration := p_duration;
    END IF;

    IF ( p_early_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_early_start_date IS NOT NULL )
    THEN
       l_early_start_date := cur_val_rec.early_start_date;
    ELSE
       l_early_start_date := p_early_start_date;
    END IF;

    IF ( p_early_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_early_end_date IS NOT NULL )
    THEN
       l_early_end_date := cur_val_rec.early_finish_date;
    ELSE
       l_early_end_date := p_early_end_date;
    END IF;

    IF ( p_late_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_late_start_date IS NOT NULL )
    THEN
       l_late_start_date := cur_val_rec.late_start_date;
    ELSE
       l_late_start_date := p_late_start_date;
    END IF;

    IF ( p_late_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND p_late_end_date IS NOT NULL )
    THEN
       l_late_end_date := cur_val_rec.late_finish_date;
    ELSE
       l_late_end_date := p_late_end_date;
    END IF;

    IF (p_milestone_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_milestone_flag IS NOT NULL) THEN
       l_milestone_flag := cur_val_rec.milestone_flag;
    ELSE
      l_milestone_flag := p_milestone_flag;
    END IF;

    IF (p_critical_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_critical_flag IS NOT NULL) THEN
-- Changes for bug 2732713
--      l_critical_flag := cur_val_rec.milestone_flag;
        l_critical_flag := cur_val_rec.critical_flag;
    ELSE
      l_critical_flag := p_critical_flag;
    END IF;

    IF ( p_ext_act_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_act_duration IS NOT NULL )
    THEN
       l_ext_act_duration := cur_val_rec.ext_act_duration;
    ELSE
       l_ext_act_duration := p_ext_act_duration;
       IF l_ext_act_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_ACT_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF ( p_ext_remain_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_remain_duration IS NOT NULL )
    THEN
       l_ext_remain_duration := cur_val_rec.ext_remain_duration;
    ELSE
       l_ext_remain_duration := p_ext_remain_duration;
       IF l_ext_remain_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_RMN_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF ( p_ext_sch_duration = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_ext_sch_duration IS NOT NULL )
    THEN
       l_ext_sch_duration := cur_val_rec.ext_sch_duration;
    ELSE
       l_ext_sch_duration := p_ext_sch_duration;
       IF l_ext_sch_duration < 0 THEN
         PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_EXT_SCH_ERR');
         l_msg_data := l_error_message_code;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- xxlu
    IF (p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute_category IS NOT NULL) THEN
      l_attribute_category := cur_val_rec.attribute_category;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;

    IF (p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute1 IS NOT NULL) THEN
      l_attribute1 := cur_val_rec.attribute1;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;

    IF (p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute2 IS NOT NULL) THEN
      l_attribute2 := cur_val_rec.attribute2;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;

    IF (p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute3 IS NOT NULL) THEN
      l_attribute3 := cur_val_rec.attribute3;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;

    IF (p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute4 IS NOT NULL) THEN
      l_attribute4 := cur_val_rec.attribute4;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;

    IF (p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute5 IS NOT NULL) THEN
      l_attribute5 := cur_val_rec.attribute5;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;

    IF (p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute6 IS NOT NULL) THEN
      l_attribute6 := cur_val_rec.attribute6;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;

    IF (p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute7 IS NOT NULL) THEN
      l_attribute7 := cur_val_rec.attribute7;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;

    IF (p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute8 IS NOT NULL) THEN
      l_attribute8 := cur_val_rec.attribute8;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;

    IF (p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute9 IS NOT NULL) THEN
      l_attribute9 := cur_val_rec.attribute9;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;

    IF (p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute10 IS NOT NULL) THEN
      l_attribute10 := cur_val_rec.attribute10;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;

    IF (p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute11 IS NOT NULL) THEN
      l_attribute11 := cur_val_rec.attribute11;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;

    IF (p_attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute12 IS NOT NULL) THEN
      l_attribute12 := cur_val_rec.attribute12;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;

    IF (p_attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute13 IS NOT NULL) THEN
      l_attribute13 := cur_val_rec.attribute13;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;

    IF (p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute14 IS NOT NULL) THEN
      l_attribute14 := cur_val_rec.attribute14;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;

    IF (p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_attribute15 IS NOT NULL) THEN
      l_attribute15 := cur_val_rec.attribute15;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;
    -- end xxlu changes.

    --Bug 3305199: Added for M

    -- Bug 3953611 (if p_def_sch_tool_tsk_type_code is explicitly passed as NULL ,then its value should be taken as NULL Only.
    --              it should not be defaulted .If and Only if we dont pass the param (i.e)Miss_Char then only we have to default)

    IF (/* 3953611 p_def_sch_tool_tsk_type_code IS NULL OR <End Changes>*/ p_def_sch_tool_tsk_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_def_sch_tool_tsk_type_code := cur_val_rec.DEF_SCH_TOOL_TSK_TYPE_CODE;
    ELSE
      l_def_sch_tool_tsk_type_code := p_def_sch_tool_tsk_type_code;
    END IF;

    -- Bug 3762396
/*    IF (p_constraint_type_code IS NULL OR p_constraint_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_constraint_type_code := cur_val_rec.CONSTRAINT_TYPE_CODE;
    ELSE
      l_constraint_type_Code := p_constraint_type_code;
    END IF;*/
    -- Bug 3762396 Added following if block
    IF (p_constraint_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND p_constraint_type_code IS NOT NULL) THEN
      l_constraint_type_code := cur_val_rec.CONSTRAINT_TYPE_CODE;
    ELSE
      l_constraint_type_Code := p_constraint_type_code;
    END IF;

   IF (p_constraint_date IS NOT NULL AND p_constraint_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN  --bug 3874705: Add NOT condition and change to AND
      IF(p_constraint_type_code <> cur_val_rec.CONSTRAINT_TYPE_CODE) THEN --Bug#8574868
       l_constraint_date := NULL;
      ELSE
      l_constraint_date := cur_val_rec.CONSTRAINT_DATE;
      END IF;
    ELSE
      l_constraint_date := p_constraint_date;
    END IF;

    IF (p_free_slack IS NOT NULL AND p_free_slack = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN  --bug 3874705: Add NOT condition and change to AND
      l_free_slack := cur_val_rec.FREE_SLACK;
    ELSE
      l_free_slack := p_free_slack;
    END IF;

    IF (p_total_slack IS NOT NULL AND p_total_slack = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN  --bug 3874705: Add NOT condition and change to AND
      l_total_slack := cur_val_rec.TOTAL_SLACK;
    ELSE
      l_total_slack := p_total_slack;
    END IF;

    IF (p_effort_driven_flag IS NOT NULL AND p_effort_driven_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN  --bug 3874705: Add NOT condition and change to AND
      l_effort_driven_flag := cur_val_rec.EFFORT_DRIVEN_FLAG;
    ELSE
      l_effort_driven_flag := p_effort_driven_flag;
    END IF;

    IF (p_level_assignments_flag IS NOT NULL AND p_level_assignments_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN  --bug 3874705: Add NOT condition and change to AND
      l_level_assignments_flag := cur_val_rec.LEVEL_ASSIGNMENTS_FLAG;
    ELSE
      l_level_assignments_flag := p_level_assignments_flag;
    END IF;
    --end bug 3305199

    PA_PROJ_ELEMENTS_UTILS.Check_Date_range(
                    p_scheduled_start_date  => l_scheduled_start_date
                   ,p_scheduled_end_date          => l_scheduled_end_date
                   ,p_obligation_start_date     => l_obligation_start_date
                   ,p_obligation_end_date         => l_obligation_end_date
                   ,p_actual_start_date       => l_actual_start_date
                   ,p_actual_finish_date          => l_actual_finish_date
                   ,p_estimate_start_date         => l_estimated_start_date
                   ,p_estimate_finish_date  => l_estimated_finish_date
                   ,p_early_start_date        => l_early_start_date
                   ,p_early_end_date          => l_early_end_date
                   ,p_late_start_date         => l_late_start_date
                   ,p_late_end_date           => l_late_end_date
                   ,x_return_status             => l_return_status
                   ,x_error_message_code        => l_error_message_code );

    IF (l_return_status <> 'S') THEN
      PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
      l_msg_data := l_error_message_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --hsiu modified for new duration calculation
    --schedule duration is calculated and updated in rollup api.
/*
    IF ( l_scheduled_start_date IS NOT NULL AND l_duration IS NOT NULL )
    THEN
--Hsiu modified
       l_scheduled_end_date := l_scheduled_start_date + l_duration - 1;
    ELSIF ( l_scheduled_start_date IS NOT NULL AND l_scheduled_end_date IS NOT NULL AND l_duration IS NOT NULL )
    THEN
--Hsiu modified
       l_scheduled_end_date := l_scheduled_start_date + l_duration - 1;

    ELSIF ( l_scheduled_start_date IS NOT NULL AND l_scheduled_end_date IS NOT NULL )
    THEN
       IF l_duration is NULL
       THEN
--Hsiu modified
          l_duration :=  trunc(l_scheduled_end_date - l_scheduled_start_date) + 1;
       END IF;
    ELSIF ( l_scheduled_start_date IS NULL AND l_scheduled_end_date IS NULL AND l_duration IS NULL )
    THEN
       l_scheduled_start_date := TRUNC(SYSDATE);
       l_scheduled_end_date := TRUNC(SYSDATE);
       l_duration           := 1;
    END IF;
*/

    IF (l_scheduled_start_date IS NOT NULL AND
        l_scheduled_end_date IS NOT NULL) THEN
--3305199: Remove duration calculation using calendar
      l_duration := trunc(l_scheduled_end_date) - trunc(l_scheduled_start_date) + 1;

/* 3305199
   --removing duration calculation
      PA_DURATION_UTILS.GET_DURATION(
       p_calendar_id => l_calendar_id
      ,p_start_date => l_scheduled_start_date
      ,p_end_date => l_scheduled_end_date
      ,x_duration_days => l_duration_days
      ,x_duration_hours => l_duration
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
*/
          -- Bug 3053846. Check if duration for the task has changed. If yes then set the flag.
          -- This is more robust than checking if the dates have changed.
          -- This piece of code will always be executed as if the dates are null an error is thrown in the
          -- beginning of this API.
          IF (l_duration <> cur_val_rec.duration) THEN
            --3035902: process update flag changes
            IF (l_weighting_basis='DURATION') THEN
              --set the flag if the dates have changed
              l_update_flag := 'Y';
            END IF;
            --3035902: end process update flag changes
          END IF;
    END IF;

    --hsiu modified for duration calculation using calendar
    IF (l_estimated_start_date IS NOT NULL AND
        l_estimated_finish_date IS NOT NULL) THEN

--3305199: Remove duration calculation using calendar
      l_est_duration := trunc(l_estimated_finish_date) - trunc(l_estimated_start_date) + 1;

/* 3305199
   --removing duration calculation
      --calculate duration
        pa_duration_utils.get_duration(
         p_calendar_id      => l_calendar_id
                ,p_start_date       => l_estimated_start_date
            ,p_end_date         => l_estimated_finish_date
                ,x_duration_days    => l_est_duration_days
                ,x_duration_hours   => l_est_duration
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
*/

    END IF;

    IF (l_actual_start_date IS NOT NULL AND
        l_actual_finish_date IS NOT NULL) THEN
--3305199: Remove duration calculation using calendar
      l_act_duration := trunc(l_actual_finish_date) - trunc(l_actual_start_date) + 1;

/* 3305199
   --removing duration calculation
      --calculate duration
        pa_duration_utils.get_duration(
         p_calendar_id      => l_calendar_id
                ,p_start_date       => l_actual_start_date
            ,p_end_date         => l_actual_finish_date
                ,x_duration_days    => l_act_duration_days
                ,x_duration_hours   => l_act_duration
                ,x_return_status    => l_return_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
*/
    END IF;

    --end duration calculation modification


    IF (p_planned_effort IS NULL OR p_planned_effort = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      l_planned_effort := cur_val_rec.PLANNED_EFFORT;
    ELSE
      l_planned_effort := p_planned_effort;

    --bug 4620492
       IF l_task_has_sub_proj_flag = 'Y' AND
          p_calling_module = 'AMG'
       THEN
          l_planned_effort := cur_val_rec.PLANNED_EFFORT;
       END IF;
    --end bug 4620492

    -- Bug 7526270
    IF p_calling_module = 'AMG' THEN
      IF (NVL(l_planned_effort,0) <> nvl(cur_val_rec.planned_effort,0)) THEN
         l_update_effort_flag := 'Y';
         IF (l_weighting_basis='EFFORT') THEN
           l_update_flag := 'Y';
         END IF;
      END IF;
    ELSE
       --hsiu: bug 3035902
       -- added nvl for bug#3058114
--      IF (l_planned_effort <> nvl(cur_val_rec.planned_effort,-99)) THEN
      IF (NVL(l_planned_effort,-99) <> nvl(cur_val_rec.planned_effort,-99)) THEN
        l_update_effort_flag := 'Y';  --06/03
        IF (l_weighting_basis='EFFORT') THEN
          --set the flag if the dates have changed
          l_update_flag := 'Y';
        END IF;
      END IF;
      --end bug 3035902
    END IF; -- Bug 7526270
    END IF;

    -- Bug Fix 5726773
    -- Commenting out the following in order to allow
    -- negative amounts which are entered through Create Tasks page
    -- while creating a task.
    /*
    IF (l_planned_effort IS NOT NULL) THEN
      IF (l_planned_effort < 0) THEN
        --error message
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NEG_PLAN_EFF_ERR');
        x_msg_data := 'PA_PS_NEG_PLAN_EFF_ERR';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    */
    -- END of Bug Fix 5726773

    --hsiu: bug 3035902
    IF (l_update_flag = 'Y' OR l_update_effort_flag = 'Y' ) THEN  -- 4299499 Included OR l_update_effort_flag = 'Y'
      --update the process flag
      open get_parent_struc_ver_id(cur_val_rec.element_version_id);
      fetch get_parent_struc_ver_id INTO l_parent_struc_ver_id;
      close get_parent_struc_ver_id;
      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => cur_val_rec.project_id,
                               p_structure_version_id => l_parent_struc_ver_id,
                               p_update_wbs_flag => 'Y',
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data
                             );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
    --end bug 3035902

    -- Added for FP_M changes 3305199 Bhumesh
    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(l_Project_ID)= 'Y' Then

       PA_PROJECT_STRUCTURE_PVT1.update_sch_dirty_flag(
             p_structure_version_id => l_Structure_Version_ID
            ,p_dirty_flag           => 'Y'             --bug 3902282
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
          x_msg_count := FND_MSG_PUB.count_msg;
          If x_msg_count = 1 then
             pa_interface_utils_pub.get_messages
              (p_encoded        => FND_API.G_TRUE,
               p_msg_index      => 1,
               p_msg_count      => l_msg_count,
               p_msg_data       => l_msg_data,
               p_data           => l_data,
               p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
          End If;
          raise FND_API.G_EXC_ERROR;
       End If;

    End If;
    -- End of FP_M changes

    OPEN cur_proj_elem_ver_sch;
    FETCH cur_proj_elem_ver_sch INTO cur_proj_elem_ver_sch_rec;
    IF cur_proj_elem_ver_sch%FOUND
    THEN
       if cur_proj_elem_ver_sch_rec.record_version_number <> p_record_version_number
       then
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.Raise_Exception;
       end if;

       -- Added for Bug 8319801
       -- This code is added to validate the Scheduled Dates against the EI Dates
       -- if the 'Automatically Update Task Transaction Dates' flag is checked.
       -- As of now these checks are done only for Fully Shared and Partially Shared Structure Projects
       -- Later this needs to be implemented for Splt Mapping also by mapping the corresponding Financial Taks

      IF (PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(cur_proj_elem_ver_sch_rec.project_id) IN ('SHARE_FULL','SHARE_PARTIAL'))
      THEN

        SELECT financial_task_flag into l_financial_task_flag_tmp
         FROM pa_proj_element_versions
         WHERE element_version_id = cur_proj_elem_ver_sch_rec.element_version_id;

        IF (l_financial_task_flag_tmp = 'Y')
        THEN

      	   SELECT a.wp_enable_version_flag
           INTO l_workplan_version_enable_flag
           FROM pa_proj_workplan_attr a, pa_proj_structure_types b
           WHERE a.proj_element_id = b.proj_element_id
	   AND a.project_id = cur_proj_elem_ver_sch_rec.project_id
           AND structure_type_id = 1;

	 IF nvl(l_workplan_version_enable_flag,'N') = 'Y' THEN

            SELECT proj_element_id into l_proj_element_id_temp
            FROM pa_proj_element_versions
            WHERE element_version_id = PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(cur_proj_elem_ver_sch_rec.project_id);
         ELSE
            SELECT pev.proj_element_id
	    INTO l_proj_element_id_temp
	    FROM  pa_proj_element_versions pev, pa_proj_structure_types pst
	    WHERE pev.proj_element_id = pst.proj_element_id
	    AND pst.structure_type_id = 1
	    AND pev.project_id = cur_proj_elem_ver_sch_rec.project_id;
         END IF;


          IF (PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_proj_element_id_temp) = 'Y')
          THEN

            -- Check Scheduled Start Date against EI date
            PA_TASKS_MAINT_UTILS.Check_Start_Date_EI(
              p_project_id => cur_proj_elem_ver_sch_rec.project_id,
              p_task_id => cur_proj_elem_ver_sch_rec.proj_element_id,
              p_start_date => l_scheduled_start_date,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data);

            -- Check Scheduled Finish Date against EI date
            PA_TASKS_MAINT_UTILS.Check_End_Date_EI(
              p_project_id => cur_proj_elem_ver_sch_rec.project_id,
              p_task_id => cur_proj_elem_ver_sch_rec.proj_element_id,
              p_end_date => l_scheduled_end_date,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data);

            l_msg_count := FND_MSG_PUB.count_msg;
            IF (l_msg_count > 0) THEN
              pa_interface_utils_pub.get_messages(
                p_encoded => FND_API.G_TRUE,
                p_msg_index => 1,
                p_data => l_data,
                p_msg_index_out => l_msg_index_out);
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
        END IF;
      END IF;
      -- End of code changes for Bug 8319801

       PA_PROJ_ELEMENT_SCH_PKG.Update_Row(
         X_ROW_ID                => cur_proj_elem_ver_sch_rec.rowid
        ,X_PEV_SCHEDULE_ID     => p_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID
        ,X_PROJECT_ID            => cur_proj_elem_ver_sch_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => cur_proj_elem_ver_sch_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_SCHEDULED_END_DATE
        ,X_OBLIGATION_START_DATE => l_OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_OBLIGATION_end_DATE
        ,X_ACTUAL_START_DATE        => l_ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_DURATION
        ,X_EARLY_START_DATE     => l_EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_EARLY_end_DATE
        ,X_LATE_START_DATE      => l_LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_LATE_end_DATE
        ,X_CALENDAR_ID            => l_CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_wq_planned_quantity
        ,x_planned_effort           => l_planned_effort
        ,X_ACTUAL_DURATION          => l_act_duration
        ,X_ESTIMATED_DURATION       => l_est_duration
        ,X_def_sch_tool_tsk_type_code => l_def_sch_tool_tsk_type_code
        ,X_constraint_type_code     => l_constraint_type_code
        ,X_constraint_date          => l_constraint_date
        ,X_free_slack               => l_free_slack
        ,X_total_slack              => l_total_slack
        ,X_effort_driven_flag       => l_effort_driven_flag
        ,X_level_assignments_flag   => l_level_assignments_flag
        ,X_RECORD_VERSION_NUMBER  => P_RECORD_VERSION_NUMBER
        ,X_ext_act_duration         => l_ext_act_duration
        ,X_ext_remain_duration      => l_ext_remain_duration
        ,X_ext_sch_duration         => l_ext_sch_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ATTRIBUTE15
       );
     ELSE
        CLOSE cur_proj_elem_ver_sch;
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_INV_PEV_SCH_ID');
        l_msg_data := 'PA_PS_INV_PEV_SCH_ID';
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  OPEN get_parent_struc_Ver_id(cur_proj_elem_ver_sch_rec.element_version_id);
  FETCH get_parent_struc_Ver_id INTO l_parent_struc_Ver_id;
  CLOSE get_parent_struc_ver_id;

  IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_parent_struc_ver_id,'WORKPLAN') ) AND
     ('Y' = l_schedule_update_flag ) THEN

    --bug 4153366
     IF (p_calling_module = 'AMG')
     THEN
        l_assgn_context := 'INSERT_VALUES';
     ELSE
        l_assgn_context := 'UPDATE';
     END IF;
     --bug 4153366;

    PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates(
                                  p_element_version_id     => cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID,
                                  p_old_task_sch_start     => l_old_sch_date,
                                  p_new_task_sch_start     => l_SCHEDULED_START_DATE,
                                  p_new_task_sch_finish    => l_SCHEDULED_END_DATE,
                                  p_context                => l_assgn_context,    --bug 4153366
                                  x_res_assignment_id_tbl  => l_res_asgmt_id_tbl,
                                  x_planning_start_tbl     => l_planning_start_tbl,
                                  x_planning_end_tbl       => l_planning_end_tbl,
                                  x_return_status          => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;


--hsiu added for dates rollup
--  this should only be called from FORMS, since Self Service is calling the rollup
--  api in the middle tier.
  IF (p_calling_module = 'FORMS') THEN
    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID;
    PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
                         p_commit => FND_API.G_FALSE,
                         p_element_versions => l_tasks_ver_ids,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

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
      RAISE FND_API.G_EXC_ERROR;
    end if;

  END IF;

  --bug 3301192 fp changes
   IF PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID )  = 'Y'
   THEN

      open get_parent_struc_ver_id(cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID);
      fetch get_parent_struc_ver_id INTO l_parent_struc_ver_id;
      close get_parent_struc_ver_id;

       l_task_ver_ids2.extend(1); /* Venky */
       l_planned_effort2.extend(1); /* Venky */
       l_start_dates.extend(1); /* Venky */
       l_end_dates.extend(1); /* Venky */

       l_task_ver_ids2(1) := cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID;
       l_planned_effort2(1) := l_planned_effort;
       l_start_dates(1)      := l_SCHEDULED_START_DATE;
       l_end_dates(1)        := l_SCHEDULED_END_DATE;

       --bug 3802976
       if pa_task_assignment_utils.check_asgmt_exists_in_task(cur_proj_elem_ver_sch_rec.ELEMENT_VERSION_ID) = 'Y'
       then
           l_update_effort_flag := 'N';
       end if;
       --bug 3802976

       /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
       /*moved pa_fp_planning_transaction_pub.update_planning_transactions into plsql block        */
       BEGIN
         IF l_update_effort_flag = 'Y'
         THEN
           pa_fp_planning_transaction_pub.update_planning_transactions
           (
             p_context                      => 'WORKPLAN'
--          ,p_maintain_reporting_lines     => 'Y'
            ,p_struct_elem_version_id       => l_parent_struc_ver_id
            ,p_task_elem_version_id_tbl     => l_task_ver_ids2
            ,p_planned_people_effort_tbl    => l_planned_effort2
            ,p_start_date_tbl               => l_start_dates
            ,p_end_date_tbl                 => l_end_dates
            ,x_return_status                => l_return_status
            ,x_msg_count                    => l_msg_count
            ,x_msg_data                     => l_msg_data
           );
         END IF;
       EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                                        p_procedure_name => 'update_schedule_version',
                                        p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.update_planning_transactions:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;

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
     --end 3301192 fp changes
  END IF;  --<< l_planned_effort >>

     CLOSE cur_proj_elem_ver_sch;


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_SCH_VER_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_SCH_VER_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'update_schedule_version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Update_Schedule_Version;


PROCEDURE Inherit_task_type_attr(
 p_api_version            IN NUMBER :=1.0,
 p_init_msg_list          IN VARCHAR2   :=FND_API.G_TRUE,
 p_commit                 IN VARCHAR2   :=FND_API.G_FALSE,
 p_validate_only          IN VARCHAR2   :=FND_API.G_TRUE,
 p_validation_level       IN NUMBER :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN VARCHAR2   :='SELF_SERVICE',
 p_debug_mode             IN VARCHAR2   :='N',
 p_max_msg_count          IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_id                IN NUMBER,
 p_task_version_id        IN NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   CURSOR get_parent_task_type_attr IS
     select c.TYPE_ID  , c.WQ_ITEM_CODE, c.WQ_UOM_CODE, c.WQ_ACTUAL_ENTRY_CODE,
            c.TASK_PROGRESS_ENTRY_PAGE_ID
       from pa_proj_element_versions a,
            pa_object_relationships b,
            pa_proj_elements c
      where b.object_id_to1 = p_task_version_id
        and b.object_type_to = 'PA_TASKS'
        and b.relationship_type = 'S'
        and b.object_type_from = 'PA_TASKS'
        and b.object_id_from1 = a.element_version_id
        and a.project_id = c.project_id
        and a.proj_element_id = c.proj_element_id;
   l_parent_type_attr_rec  get_parent_task_type_attr%ROWTYPE;

   CURSOR get_current_task_type_attr IS
     select c.TYPE_ID  , c.WQ_ITEM_CODE, c.WQ_UOM_CODE, c.WQ_ACTUAL_ENTRY_CODE,
            c.TASK_PROGRESS_ENTRY_PAGE_ID
       from pa_proj_elements c
      where c.proj_element_id = p_task_id;
   l_type_attr_rec   get_current_task_type_attr%ROWTYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN get_parent_task_type_attr;
  FETCH get_parent_task_type_attr INTO l_parent_type_attr_rec;
  IF get_parent_task_type_attr%NOTFOUND THEN
    --it is a top task. no update necessary
    CLOSE get_parent_task_type_attr;
    return;
  END IF;
  CLOSE get_parent_task_type_attr;

  OPEN get_current_task_type_attr;
  FETCH get_current_task_type_attr into l_type_attr_rec;
  CLOSE get_current_task_type_attr;

  IF (l_parent_type_attr_rec.TYPE_ID   = l_type_attr_rec.TYPE_ID  ) THEN
    --same type as parent at creation time. inherit
    UPDATE pa_proj_elements set
--      task_weighting_deriv_code = l_parent_type_attr_rec.TASK_WEIGHTING_DERIV_CODE
      WQ_ITEM_CODE = l_parent_type_attr_rec.WQ_ITEM_CODE
     ,WQ_UOM_CODE = l_parent_type_attr_rec.WQ_UOM_CODE
     ,WQ_ACTUAL_ENTRY_CODE = l_parent_type_attr_rec.WQ_ACTUAL_ENTRY_CODE
     ,TASK_PROGRESS_ENTRY_PAGE_ID = l_parent_type_attr_rec.TASK_PROGRESS_ENTRY_PAGE_ID
    where proj_element_id = p_task_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'Inherit_task_type_attr',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END Inherit_task_type_attr;


--   API name                      : Update_Task_Weighting
--   Type                          : Private Procedure
--   Pre-reqs                      : None
--   Return Value                  : N/A
--   Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_object_relationship_id            IN  NUMBER
--   p_weighting_percentage              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  20-SEP-02   hyau             -Created
--
--
  procedure Update_Task_Weighting
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_weighting_percentage              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS

    l_weighting_percentage NUMBER;

        CURSOR cur_obj_relationships( c_object_relationship_id NUMBER )
        IS
          SELECT
                  OBJECT_RELATIONSHIP_ID
                 ,RELATIONSHIP_TYPE
                 ,RELATIONSHIP_SUBTYPE
                 ,LAG_DAY
                 ,PRIORITY
                 ,PM_PRODUCT_CODE
            FROM pa_object_relationships
           WHERE OBJECT_RELATIONSHIP_ID = c_object_relationship_id;

        cur_obj_relationships_rec cur_obj_relationships%ROWTYPE;


  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PVT1.Update_Task_Weighting begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_task_weighting_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF (p_weighting_percentage is null) THEN
      l_weighting_percentage := 0;
    ELSE
      l_weighting_percentage := p_weighting_percentage;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Querying up the row from the object relationship table.');
    END IF;

    OPEN cur_obj_relationships( p_object_relationship_id );
    FETCH cur_obj_relationships INTO cur_obj_relationships_rec;
    IF cur_obj_relationships%NOTFOUND THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_obj_relationships;

    PA_OBJECT_RELATIONSHIPS_PKG.UPDATE_ROW(
       p_user_id                => FND_GLOBAL.USER_ID
      ,p_object_relationship_id => p_object_relationship_id
      ,p_relationship_type      => cur_obj_relationships_rec.relationship_type
      ,p_relationship_subtype   => cur_obj_relationships_rec.relationship_subtype
      ,p_lag_day                => cur_obj_relationships_rec.lag_day
      ,p_priority               => cur_obj_relationships_rec.priority
      ,p_pm_product_code        => cur_obj_relationships_rec.pm_product_code
      ,p_weighting_percentage   => l_weighting_percentage
      ,p_comments => NULL
      ,p_status_code => NULL
      ,p_record_version_number  => p_record_version_number
      ,x_return_status => x_return_status
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_task_weighting_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_task_weighting_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'Update_Task_Weighting',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END UPDATE_TASK_WEIGHTING;

  PROCEDURE RECALC_TASKS_WEIGHTING(
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    CURSOR get_weighting_sum IS
      select sum(weighting_percentage)
        from pa_object_relationships
       where object_id_from1 = p_task_version_id
         and object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
         and relationship_type = 'S';

    CURSOR get_child_weighting IS
      select object_relationship_id, weighting_percentage,
             record_version_number, object_id_to1
        from pa_object_relationships
       where object_id_from1 = p_task_version_id
         and object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
         and relationship_type = 'S';

    l_sum           NUMBER(17,2);
    l_weighting     NUMBER(17,2);
    l_object_relationship_id NUMBER;
    l_record_version_number  NUMBER;
    l_cnt           NUMBER;

    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(250);
    l_data          VARCHAR2(250);
    l_msg_index_out NUMBER;

    -- anlee task weighting changes
    l_current_sum NUMBER(17,2);
    l_remainder NUMBER(17,2);
    l_current_obj_rel_id NUMBER;
    l_current_weighting NUMBER(17,2);
    l_current_rec_ver_number NUMBER;
    -- end anlee

  --bug 2673570
  CURSOR check_progress_allowed(c_element_version_id NUMBER)
  IS
  SELECT ptt.prog_entry_enable_flag
  FROM   pa_task_types ptt,
         pa_proj_element_versions ppev,
         pa_proj_elements ppe
  WHERE  ppev.element_version_id = c_element_version_id
  AND    ppev.proj_element_id = ppe.proj_element_id
  AND    ppe.TYPE_ID   = ptt.task_type_id;

  l_object_id_to1     NUMBER;
  l_progress_allowed  VARCHAR2(1);
  --bug 2673570

  BEGIN
    --hsiu: bug 3604086
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_weighting_sum;
    FETCH get_weighting_sum into l_sum;
    CLOSE get_weighting_sum;

    OPEN get_child_weighting;
    l_cnt := 1;
    LOOP
      FETCH get_child_weighting INTO l_object_relationship_id,
                                     l_weighting,
                                     l_record_version_number,
                                     l_object_id_to1;
      EXIT WHEN get_child_weighting%NOTFOUND;
      If (l_cnt = 1) and (l_sum = 0) THEN
        l_weighting := 100;
      ELSIF (l_cnt > 1) and (l_sum = 0) THEN
        l_weighting := 0;
      ELSE
        l_weighting := (l_weighting * 100) / l_sum;
      END IF;

     --bug 2673570
     OPEN check_progress_allowed(l_object_id_to1);
     FETCH check_progress_allowed INTO l_progress_allowed;
     CLOSE check_progress_allowed;

     if l_progress_allowed = 'N' then
        l_weighting := 0;
     end if;
     --bug 2673570

      -- anlee task weighting changes
      l_current_obj_rel_id := l_object_relationship_id;
      l_current_weighting := l_weighting;
      l_current_rec_ver_number := l_record_version_number;
      -- end anlee

      --update task weighting
      PA_TASK_PVT1.Update_Task_Weighting(
        p_object_relationship_id => l_object_relationship_id
       ,p_weighting_percentage => l_weighting
       ,p_record_version_number => l_record_version_number
       ,x_return_status => l_return_status
       ,x_msg_count => l_msg_count
       ,x_msg_data => l_msg_data
      );

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
        RAISE FND_API.G_EXC_ERROR;
      end if;

      l_cnt := l_cnt + 1;
    END LOOP;

    -- anlee task weighting changes
    OPEN get_weighting_sum;
    FETCH get_weighting_sum INTO l_current_sum;
    CLOSE get_weighting_sum;

    l_remainder := 100 - l_current_sum;
    if(l_remainder > 0) AND l_progress_allowed = 'Y' then
      --update task weighting
      PA_TASK_PVT1.Update_Task_Weighting(
        p_object_relationship_id => l_current_obj_rel_id
       ,p_weighting_percentage => l_current_weighting + l_remainder
       ,p_record_version_number => l_current_rec_ver_number + 1
       ,x_return_status => l_return_status
       ,x_msg_count => l_msg_count
       ,x_msg_data => l_msg_data
      );

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
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;
    -- end anlee

    CLOSE get_child_weighting;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'RECALC_TASKS_WEIGHTING',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END RECALC_TASKS_WEIGHTING;

  PROCEDURE update_task_ver_delete_status(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    CURSOR get_task_versions IS
      select object_id_to1
        from pa_object_relationships
       where relationship_type = 'S'
         and object_type_from = 'PA_TASKS'
         and object_type_to = 'PA_TASKS'
         and relationship_type = 'S'
       start with object_id_to1 = p_task_version_id
     connect by prior object_id_to1 = object_id_from1
             and relationship_type = prior relationship_type --bug 3919266
             and relationship_type = 'S'
             and prior object_type_to = object_type_from;

    l_task_version_id NUMBER;
  BEGIN
    UPDATE pa_proj_element_versions
       set TASK_UNPUB_VER_STATUS_CODE = 'TO_BE_DELETED',
           RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1,
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
     where element_version_id = p_task_version_id;

    OPEN get_task_versions;
    LOOP
      FETCH get_task_versions into l_task_version_id;
      EXIT WHEN get_task_versions%NOTFOUND;

      UPDATE pa_proj_element_versions
         set TASK_UNPUB_VER_STATUS_CODE = 'TO_BE_DELETED',
             RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       where element_version_id = l_task_version_id;

    END LOOP;
    CLOSE get_task_versions;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                          p_procedure_name => 'update_task_ver_delete_status',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END update_task_ver_delete_status;

  procedure delete_task_ver_wo_val
  (
    p_api_version           IN  NUMBER  :=1.0,
    p_init_msg_list         IN  VARCHAR2:=FND_API.G_TRUE,
    p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
    p_validate_only         IN  VARCHAR2:=FND_API.G_TRUE,
    p_validation_level      IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
    p_calling_module        IN  VARCHAR2:='SELF_SERVICE',
    p_debug_mode            IN  VARCHAR2:='N',
    p_max_msg_count         IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_structure_version_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_task_version_id       IN  NUMBER,
    p_record_version_number IN  NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                     VARCHAR2(250);

    l_error_message_code           VARCHAR2(250);

    l_parent_struc_ver_id          NUMBER;
    l_wbs_level                    NUMBER;
    l_display_sequence             NUMBER;
    l_wbs_number                   NUMBER;
    l_delete_flag                  VARCHAR2(1) := 'N';
    l_structure_id                 NUMBER;

    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80);

    CURSOR cur_child_tasks
    IS
      SELECT a.object_relationship_id object_relationship_id, a.object_id_to1 object_id_to1,
             a.record_version_number record_version_number, b.wbs_level wbs_level, b.display_sequence
      FROM (
      SELECT object_relationship_id, object_id_to1, record_version_number
        FROM pa_object_relationships
       WHERE relationship_type = 'S'
  START WITH object_id_from1 = p_task_version_id
  CONNECT BY object_id_from1 = PRIOR object_id_to1
      AND relationship_type = PRIOR relationship_type --bug 3919266
      AND relationship_type = 'S' ) A, pa_proj_element_versions b
      ,pa_proj_elements c        --bug 4573340
     WHERE a.object_id_to1 = b.element_version_id
     --bug 4573340
        and b.proj_element_id = c.proj_element_id
        and b.project_id = c.project_id
        and c.link_task_flag = 'N'
      --bug 4573340
  UNION
     SELECT a.object_relationship_id, element_version_id  object_id_to1,
            a.record_version_number, wbs_level, b.display_sequence
       FROM pa_object_relationships a, pa_proj_element_versions b
      WHERE element_version_id = p_task_version_id
        AND object_id_to1 = p_task_version_id
        AND element_version_id = object_id_to1
        AND relationship_type = 'S'
   ORDER BY 4 desc;


   CURSOR cur_proj_elem_ver( p_task_id NUMBER )
   IS
     SELECT rowid,record_version_number, project_id, parent_structure_version_id, proj_element_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_task_id;

   CURSOR cur_sch_ver( p_task_id NUMBER, p_project_id NUMBER )
   IS
     SELECT rowid
       FROM pa_proj_elem_ver_schedule
      WHERE element_version_id = p_task_id
        AND project_id = p_project_id;

   CURSOR cur_pa_projs( p_project_id NUMBER )
   IS
     SELECT wbs_record_version_number
            -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
             FROM pa_proj_elem_ver_structure
 -- HY      FROM pa_projects_all
      WHERE project_id = p_project_id;

   CURSOR cur_pa_tasks( p_task_id NUMBER )
   IS
     SELECT record_version_number
       FROM pa_tasks
      WHERE task_id = p_task_id;

   CURSOR cur_chk_vers( x_proj_element_id NUMBER, x_task_version NUMBER )
   IS
     SELECT 'X'
       FROM pa_proj_element_versions
      WHERE proj_element_id = x_proj_element_id
        AND element_version_id <> x_task_version;

  CURSOR cur_proj_elems( x_proj_element_id NUMBER )
  IS
    SELECT rowid
      FROM pa_proj_elements
     WHERE proj_element_id = x_proj_element_id;


--Ansari
  CURSOR cur_parent_ver_id( c_task_version_id NUMBER )
  IS
    SELECT object_id_from1
      FROM pa_object_relationships
     WHERE object_id_to1 = c_task_version_id
       AND relationship_type = 'S';
  l_parent_task_verion_id   NUMBER;
--Ansari


--hsiu added, for dates rollup
   CURSOR get_peer_tasks
   IS
     select b.object_id_to1 object_id_to1
       from pa_object_relationships a,
            pa_object_relationships b
      where a.object_id_to1 = p_task_version_id
        and a.object_type_to = 'PA_TASKS'
        and a.object_id_from1 = b.object_id_from1
        and a.object_type_from = b.object_type_from
        and b.object_type_to = 'PA_TASKS'
        and b.object_id_to1 <> p_task_version_id
        and a.relationship_type = 'S'
        and b.relationship_type = 'S';
   c_get_peer_tasks get_peer_tasks%ROWTYPE;
   l_peer_tasks_exist VARCHAR2(1) := 'Y';
   l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

--hsiu added, for task weighting
   CURSOR get_parent_version_id IS
     select object_id_from1
       from pa_object_relationships
      where object_id_to1 = p_task_version_id
        and object_type_to = 'PA_TASKS'
        and relationship_type = 'S'
        and object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');
   l_old_parent_ver_id    NUMBER;
--end task weighting changes

   x_row_id                  VARCHAR2(255);
   x_row_id_elem             VARCHAR2(255);
   x_sch_row_id              VARCHAR2(255);
   x_record_version_number   NUMBER;

   x_task_rec_version_number NUMBER;
   x_wbs_rec_version_number  NUMBER;
   x_parent_struc_ver_id     NUMBER;
   x_project_id              NUMBER;
   l_proj_element_id         NUMBER;
   l_dummy_char              VARCHAR2(1);
   l_task_cnt                NUMBER;
   l_selected_seq_num        NUMBER;

   --hsiu task status changes
   cursor get_latest_task_ver_id IS
     select b.parent_structure_version_id, b.element_version_id
       from pa_proj_element_versions b,
            pa_proj_elem_ver_structure c
      where b.element_version_id = p_task_version_id
        and b.project_id = c.project_id
        and b.parent_structure_version_id = c.element_version_id
        and c.LATEST_EFF_PUBLISHED_FLAG = 'Y';
   l_latest_task_ver_rec    get_latest_task_ver_id%ROWTYPE;
   --end task status changes

   l_calling_module VARCHAR2(30);

   --3035902: process update flag changes
   cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
   l_task_type_id      NUMBER;
   l_progress_flag     VARCHAR2(1);
   l_wp_type              VARCHAR2(1);
   l_weighting_basis_Code VARCHAR2(30);
   --3035902: end process update flag changes

  --Cursor to selct fp task version id to delete the mapping
  -- Added by Skannoji
  CURSOR cur_fp_tsk_ver_id( c_task_version_id NUMBER )
  IS
    SELECT object_id_to1
      FROM pa_object_relationships
     --WHERE object_id_from1 = p_task_version_id --4173785
     WHERE object_id_from1 = c_task_version_id
       AND relationship_type = 'M';

      l_fp_task_version_id       PA_OBJECT_RELATIONSHIPS.object_id_to1%TYPE;
      /* Bug #: 3305199 SMukka                                                         */
      /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
      /* l_element_version_id_tbl   PA_PLSQL_DATATYPES.IdTabTyp;                       */
      l_element_version_id_tbl   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
 --skannoji
--
   --Bug No 3450684 Smukka For Subproject Association
   CURSOR get_subproj_relation(cp_task_ver_id NUMBER) IS
   SELECT pors.object_relationship_id,pors.record_version_number
     FROM pa_object_relationships pors
--bug 4573340
     ,pa_object_relationships pors1
    WHERE
      --pors.object_id_from1= cp_task_ver_id
      pors1.object_id_from1 = cp_task_ver_id
      AND pors.object_id_from1 = pors1.object_id_to1
      AND pors1.relationship_type = 'S'
--bug 4573340
      AND pors.relationship_type IN ('LW','LF')
      AND pors.object_id_from2 <> pors.object_id_to2
      AND pors.object_type_from = 'PA_TASKS'
      AND pors.object_type_to = 'PA_STRUCTURES';
      get_subproj_relation_rec get_subproj_relation%ROWTYPE;
--
    l_call_del_plan_txn      VARCHAR2(1)  := 'N';  --bug 4172646

     l_debug_mode             VARCHAR2(1);
  BEGIN

    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PVT1.DELETE_TASK_VER_WO_VAL begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_TASK_VER_WO_VAL;
    END IF;

--hsiu
--added for task weighting changes
    OPEN get_parent_version_id;
    FETCH get_parent_version_id INTO l_old_parent_ver_id;
    CLOSE get_parent_version_id;
--end task weighting changes

--hsiu added, for dates rollup
    OPEN get_peer_tasks;
    FETCH get_peer_tasks INTO c_get_peer_tasks;
    IF get_peer_tasks%NOTFOUND THEN
      l_peer_tasks_exist := 'N';
    ELSE
      l_peer_tasks_exist := 'Y';
      l_tasks_ver_ids.extend;
      l_tasks_ver_ids(l_tasks_ver_ids.count) := c_get_peer_tasks.object_id_to1;
    END IF;
    CLOSE get_peer_tasks;


    FOR cur_child_tasks_rec IN cur_child_tasks LOOP

      OPEN cur_proj_elem_ver( cur_child_tasks_rec.object_id_to1 );
      FETCH cur_proj_elem_ver INTO x_row_id, x_record_version_number,
                                   x_project_id, x_parent_struc_ver_id,
                                   l_proj_element_id;
      IF cur_proj_elem_ver%FOUND THEN
        IF cur_child_tasks_rec.object_id_to1 = p_task_version_id THEN
          IF x_record_version_number <> p_record_version_number THEN
            CLOSE cur_proj_elem_ver;
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.Raise_Exception;
          END IF;
        END IF;

        --deleting schedule version if its a workplan
        --IF workplan_structure THEN
        --IF  p_called_from_api <> 'MOVE_TASK_VERSION' THEN
          IF PA_PROJ_ELEMENTS_UTILS.structure_type(
                        p_structure_version_id => null
                       ,p_task_version_id      => cur_child_tasks_rec.object_id_to1
                       ,p_structure_type       => 'WORKPLAN' ) = 'Y' THEN

            OPEN cur_sch_ver( cur_child_tasks_rec.object_id_to1, x_project_id );
            FETCH cur_sch_ver INTO x_sch_row_id;
            IF cur_sch_ver%FOUND THEN
              PA_PROJ_ELEMENT_SCH_PKG.Delete_row(  x_sch_row_id );
            END IF;
            CLOSE cur_sch_ver;

     -- Added by skannoji
     -- Deleteing planning transactions for all given element version id
     IF ( (PA_PROJ_TASK_STRUC_PUB.wp_str_exists(x_project_id) = 'Y') OR (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(x_project_id) = 'Y') ) THEN
       l_element_version_id_tbl.extend(1); /* Venky */
       l_element_version_id_tbl(1) := cur_child_tasks_rec.object_id_to1;

           /* 4317547 : The fix 4172646 has caused DHI bug 4317547
              Here,the call to delete planning txn has been moved out of the loop
              and is done after call to pa_project_core.delete_task .
              This is problematic as described in 4317547

           --bug Bug #       : 4172646
           -- Moved the call delete planning txn after the loop once for all tasks.
           l_call_del_plan_txn := 'Y';
           --end bug Bug #       : 4172646

            */
          /* 4317547 : Hence, Moved back the call inside loop
            when context is other than 'DEL_STRUCT'
           */
           IF (p_calling_module <> 'DEL_STRUCT') THEN
         BEGIN
                    PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions(
                     p_context                      => 'WORKPLAN'
                    ,p_task_or_res                  => 'TASKS'
                    ,p_element_version_id_tbl       => l_element_version_id_tbl
--                  ,p_maintain_reporting_lines     => 'Y'
                    ,x_return_status               => x_return_status
                    ,x_msg_count                   => x_msg_count
                    ,x_msg_data                    => x_msg_data);
            EXCEPTION
            WHEN OTHERS THEN
                    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                               p_procedure_name => 'delete_Task_ver_wo_val',
                               p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions:'||SQLERRM,1,240));
            RAISE FND_API.G_EXC_ERROR;
            END;
            IF x_return_status = FND_API.G_RET_STS_ERROR then
                RAISE FND_API.G_EXC_ERROR;
            End If;
           END IF;
     END IF;
       -- till here by skannoji
          END IF;
        --END IF;

    -- Added by skannoji
    -- While deletion of task, the task mapping should be deleted
    IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                            p_structure_version_id => x_parent_struc_ver_id
                                           ,p_structure_type       => 'WORKPLAN' ) = 'Y') AND
    (PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(x_project_id )= 'SPLIT_MAPPING')
    then
       --Get fp task version id to delete mapping.
       OPEN cur_fp_tsk_ver_id( cur_child_tasks_rec.object_id_to1 );
       FETCH cur_fp_tsk_ver_id INTO l_fp_task_version_id;
           IF cur_fp_tsk_ver_id%FOUND THEN
            PA_PROJ_STRUC_MAPPING_PUB.delete_mapping
              (
                           p_wp_task_version_id    => cur_child_tasks_rec.object_id_to1
                         , p_fp_task_version_id    => l_fp_task_version_id
                         , x_return_status         => x_return_status
                         , x_msg_count             => x_msg_count
                         , x_msg_data              => x_msg_data);
           END IF;
          CLOSE cur_fp_tsk_ver_id;

          If x_return_status = FND_API.G_RET_STS_ERROR then
             RAISE FND_API.G_EXC_ERROR;
          End If;
      End If;
      -- till here


        --Do financial task check
        --If financial

        IF cur_child_tasks%ROWCOUNT = 1 THEN
          IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                            p_structure_version_id => x_parent_struc_ver_id
                                           ,p_structure_type       => 'FINANCIAL' ) = 'Y') THEN

            SELECT proj_element_id INTO l_structure_id
              FROM pa_proj_element_versions
             WHERE element_version_id = x_parent_struc_ver_id
               AND project_id = x_project_id;

            IF (PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(
                       p_project_id   => x_project_id
                      ,p_structure_id => l_structure_id ) = 'N') OR
               (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                       x_project_id) = 'N') THEN
              l_delete_flag := 'Y';
            END IF;
          END IF;
        END IF;
        IF l_delete_flag = 'Y' THEN
          OPEN  cur_pa_projs( x_project_id );
          FETCH cur_pa_projs INTO x_wbs_rec_version_number;
          CLOSE cur_pa_projs;

          OPEN  cur_pa_tasks( l_proj_element_id );
          FETCH cur_pa_tasks INTO x_task_rec_version_number;
          IF p_calling_module NOT IN ( 'FORMS', 'AMG' ) AND cur_pa_tasks%FOUND THEN
            --Added condition to call this api from forms and AMG apis.
            --Since forms and AMG already deletes from pa_tasks
            --we do not have to call the following api again.

            --hsiu: bug 2800553: for deleteing structure performance improvement changes
            IF (p_calling_module = 'DEL_STRUCT') THEN
              l_calling_module :='SELF_SERVICE';
            ELSE
              l_calling_module :=p_calling_module;
            END IF;

-- hsiu: bug 2800553: added for performance improvement
--bug 2947492 : The following call is modified to pass parameters by notation
            PA_PROJECT_CORE.Delete_Task(
              x_task_id      => l_proj_element_id,
              x_err_code     => l_err_code,
              x_err_stage    => l_err_stage,
              x_err_stack    => l_err_stack);

            If (l_err_code <> 0) THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name => substrb(l_err_stage,1,30)); --3935874 : Changed Substr to Substrb
              CLOSE cur_pa_tasks;
              raise FND_API.G_EXC_ERROR;
            END IF;
          END IF; --called_from_api chk.
          CLOSE cur_pa_tasks;

-- hsiu: bug 2800553: commented for performance improvement
--            PA_TASKS_MAINT_PUB.DELETE_TASK(
--                  p_api_version                       => p_api_version
--                 ,p_init_msg_list                     => p_init_msg_list
--                 ,p_commit                            => p_commit
--                 ,p_validate_only                     => p_validate_only
--                 ,p_validation_level                  => p_validation_level
--                 ,p_calling_module                    => l_calling_module
--                 ,p_debug_mode                        => p_debug_mode
--                 ,p_project_id                        => x_project_id
--                 ,p_task_id                       => l_proj_element_id
--                 ,p_record_version_number             => x_task_rec_version_number
--                 ,p_wbs_record_version_number         => x_wbs_rec_version_number
--                 ,p_called_from_api                   => p_called_from_api
--                 ,x_return_status                     => l_return_status
--                 ,x_msg_count                         => l_msg_count
--                 ,x_msg_data                          => l_msg_data
--                );
--            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--              x_msg_count := FND_MSG_PUB.count_msg;
--              IF x_msg_count = 1 then
--                   pa_interface_utils_pub.get_messages
--                   (p_encoded        => FND_API.G_TRUE,
--                    p_msg_index      => 1,
--                    p_msg_count      => l_msg_count,
--                    p_msg_data       => l_msg_data,
--                    p_data           => l_data,
--                    p_msg_index_out  => l_msg_index_out);
--                    x_msg_data := l_data;
--              END IF;
--              raise FND_API.G_EXC_ERROR;
--            END IF;

        END IF; --delete flag chk

        --Ansari
        --Get parent of deleting task before its relationship gets deleted.
        OPEN cur_parent_ver_id( cur_child_tasks_rec.object_id_to1 );
        FETCH cur_parent_ver_id INTO l_parent_task_verion_id;
        CLOSE cur_parent_ver_id;
        --Ansari

--bug 4573340. First delete the sub-project association if it exists:
        --Bug No 3450684 Smukka 16-Mar-2004
        --Deleting subproject association
        OPEN get_subproj_relation(cur_child_tasks_rec.object_id_to1);
        FETCH get_subproj_relation INTO get_subproj_relation_rec;
        IF get_subproj_relation%FOUND   --bug 4573340
        THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VER_WO_VAL', 'Before PA_RELATIONSHIP_PUB.Delete_SubProject_Association get_subproj_relation_rec.object_relationship_id='
                               ||get_subproj_relation_rec.object_relationship_id, 3);
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VER_WO_VAL', 'Before PA_RELATIONSHIP_PUB.Delete_SubProject_Association get_subproj_relation_rec.record_version_number='
                               ||get_subproj_relation_rec.record_version_number, 3);

           END IF;

           PA_RELATIONSHIP_PUB.Delete_SubProject_Association    --bug 4573340  replaced the call with delete_subproject
                   (
                     p_init_msg_list                     => p_init_msg_list
                    ,p_commit                            => p_commit
                    ,p_validate_only                     => p_validate_only
                    ,p_validation_level                  => p_validation_level
                    ,p_calling_module                    => p_calling_module
                    ,p_debug_mode                        => p_debug_mode
                    ,p_max_msg_count                     => p_max_msg_count
                    ,p_object_relationships_id           => get_subproj_relation_rec.object_relationship_id
                    ,p_record_version_number             => get_subproj_relation_rec.record_version_number
                    ,x_return_status                     => l_return_status
                    ,x_msg_count                         => l_msg_count
                    ,x_msg_data                          => l_msg_data
                    );

           IF l_debug_mode = 'Y' THEN
                pa_debug.write('PA_TASK_PVT1.DELETE_TASK_VER_WO_VAL', 'After PA_RELATIONSHIP_PUB.Delete_SubProject_Association l_return_status='||l_return_status, 3);
           END IF;


          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE,
                 p_msg_index      => 1,
                 p_msg_count      => l_msg_count,
                 p_msg_data       => l_msg_data,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out);
                 x_msg_data := l_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        END IF; --4573340
        CLOSE get_subproj_relation;

        PA_RELATIONSHIP_PUB.Delete_Relationship (
                     p_api_version            => p_api_version
                    ,p_init_msg_list          => p_init_msg_list
                    ,p_commit                 => p_commit
                    ,p_validate_only          => p_validate_only
                    ,p_validation_level       => p_validation_level
                    ,p_calling_module         => p_calling_module
                    ,p_debug_mode             => p_debug_mode
                    ,p_max_msg_count          => p_max_msg_count
                    ,p_object_relationship_id => cur_child_tasks_rec.object_relationship_id
                    ,p_record_version_number  => cur_child_tasks_rec.record_version_number
                    ,x_return_status          => l_return_status
                    ,x_msg_count              => l_msg_count
                    ,x_msg_data               => l_msg_data
                    );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        PA_PROJ_ELEMENT_VERSIONS_PKG.Delete_Row( x_row_id );

        --Ansari
        --Call update wbs number
        --hsiu: bug 2800553: performance changes: not called when deleting structure
        IF (p_calling_module <> 'DEL_STRUCT') THEN
          PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS (
                               p_commit                   => p_commit
                              ,p_debug_mode               => p_debug_mode
                              ,p_parent_structure_ver_id  => x_parent_struc_ver_id
                              ,p_task_id                  => null
                              ,p_display_seq              => cur_child_tasks_rec.display_sequence
                              ,p_action                   => 'DELETE'
                              ,p_parent_task_id           => l_parent_task_verion_id
                              ,x_return_status            => l_return_status );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count = 1 then
                   pa_interface_utils_pub.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
            END IF;
            raise FND_API.G_EXC_ERROR;
          END IF; --hsiu: bug 2800553: for performance changes
        END IF;
     --Ansari

        --IF  p_called_from_api <> 'MOVE_TASK_VERSION' THEN
          --Check if there are any versions exist
          OPEN cur_chk_vers( l_proj_element_id, cur_child_tasks_rec.object_id_to1 );
          FETCH cur_chk_vers INTO l_dummy_char;
          IF cur_chk_vers%NOTFOUND THEN
           --get progressable flag
            --3035902: process update flag changes
            OPEN get_task_type_id(l_proj_element_id);
            FETCH get_task_type_id into l_task_type_id;
            CLOSE get_task_type_id;
            l_progress_flag := pa_task_type_utils.check_tk_type_progressable(l_task_type_id);
            --3035902: end process update flag changes

            OPEN cur_proj_elems( l_proj_element_id );
            FETCH cur_proj_elems INTO x_row_id_elem;
            CLOSE cur_proj_elems;

     -- Added by skannoji
     -- Deleting deliverable task
     If (PA_PROJECT_STRUCTURE_UTILS.check_Deliverable_enabled(x_project_id) = 'Y' ) THEN
       PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk(
         p_task_element_id  => l_proj_element_id
        ,p_project_id       => x_project_id
        ,p_task_version_id  => cur_child_tasks_rec.object_id_to1
        , x_return_status   => x_return_status
        , x_msg_count       => x_msg_count
        , x_msg_data        => x_msg_data);
     End If;
     -- Added by skannoji end here

     IF x_return_status = FND_API.G_RET_STS_ERROR then
         RAISE FND_API.G_EXC_ERROR;
     End If;

            PA_PROJ_ELEMENTS_PKG.delete_row( x_row_id_elem );

            -- anlee
            -- Ext Attribute changes
            -- Bug 2904327

            PA_USER_ATTR_PUB.DELETE_ALL_USER_ATTRS_DATA (
             p_validate_only             => FND_API.G_FALSE
            ,p_project_id                => x_project_id
            ,p_proj_element_id           => l_proj_element_id
            ,x_return_status             => l_return_status
            ,x_msg_count                 => l_msg_count
            ,x_msg_data                  => l_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              x_return_status := 'E';
              RAISE  FND_API.G_EXC_ERROR;
            END IF;
          -- anlee end of changes

          END IF;
          CLOSE cur_chk_vers;
        --END IF;  --p_called_from_api chk.

         IF (p_calling_module <> 'DEL_STRUCT') THEN
             --bug 3055766
             --delete association
             PA_TASK_PUB1.Delete_Task_Associations(
                 p_task_id              => l_proj_element_id
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
                 );

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
               RAISE FND_API.G_EXC_ERROR;
            end if;
         END IF;
         --End bug 3055766


      END IF;  --cur_proj_elem_ver%FOUND check
      CLOSE cur_proj_elem_ver;
      l_task_cnt := nvl( l_task_cnt, 0 ) + 1;
      IF cur_child_tasks_rec.object_id_to1 = p_task_version_id THEN
        l_selected_seq_num := cur_child_tasks_rec.display_sequence;
      END IF;
    END LOOP;

    IF (p_calling_module <> 'DEL_STRUCT') THEN
    /* Commented for Bug 4317547
           --bug Bug #       : 4172646
           -- 1) call the delete plan txn api once for all tasks.
           -- 2) do not call delete planning txn api when deleting entire structure version.
       IF  l_call_del_plan_txn = 'Y'
       THEN
       BEGIN
           PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions(
              p_context                      => 'WORKPLAN'
             ,p_task_or_res                  => 'TASKS'
             ,p_element_version_id_tbl       => l_element_version_id_tbl
             ,x_return_status               => x_return_status
             ,x_msg_count                   => x_msg_count
             ,x_msg_data                    => x_msg_data);
       EXCEPTION
          WHEN OTHERS THEN
               fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                                       p_procedure_name => 'delete_Task_ver_wo_val',
                                       p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.delete_planning_transactions:'||SQLERRM,1,240));
          RAISE FND_API.G_EXC_ERROR;
       END;
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       End If;
     END IF;
           --end bug Bug #       : 4172646
    */

  -- Bug Fix 5070454
  -- User is getting the record is modified error. This is happening due to the following update
  -- This is bumping up the rvns of all the records with higher display number than the one that is
  -- being deleted.
  -- Hence commenting out the update of RVN here.


      BEGIN
        UPDATE PA_PROJ_ELEMENT_VERSIONS
         SET display_sequence = PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, 0, l_task_cnt, 'DELETE', 'DOWN')
--             record_version_number = record_version_number + 1
         WHERE parent_structure_version_id = x_parent_struc_ver_id
         AND (display_sequence > l_selected_seq_num)
         AND PA_PROJ_ELEMENTS_UTILS.link_flag ( proj_element_id ) = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
          raise FND_API.G_EXC_ERROR;
      END;

--hsiu added, for dates rollup
      IF (l_peer_tasks_exist = 'Y') THEN
        IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(x_parent_struc_ver_id, 'WORKPLAN') = 'Y' then
          PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
                         p_commit => FND_API.G_FALSE,
                         p_element_versions => l_tasks_ver_ids,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

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
            RAISE FND_API.G_EXC_ERROR;
          end if;
        END IF;
      END IF;
    END IF;

--hsiu added for task status
    OPEN get_latest_task_ver_id;
    FETCH get_latest_task_ver_id into l_latest_task_ver_rec;
    IF (get_latest_task_ver_id%NOTFOUND) OR
       (l_latest_task_ver_rec.parent_structure_version_id <> p_structure_version_id) THEN
    --no rollup necessary
      NULL;
    ELSE
    --Rollup structure
      IF (p_calling_module <> 'DEL_STRUCT') THEN
        PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,x_return_status => l_return_status
                 ,x_msg_count => l_msg_count
                 ,x_msg_data => l_msg_data
        );

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
          RAISE FND_API.G_EXC_ERROR;
        end if;
      END IF;
    END IF;
    CLOSE get_latest_task_ver_id;
--end task status changes

--hsiu
--added for task weighting
    IF (p_calling_module <> 'DEL_STRUCT') THEN
      PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
        p_task_version_id => l_old_parent_ver_id
       ,x_return_status   => l_return_status
       ,x_msg_count       => l_msg_count
       ,x_msg_data        => l_msg_data
      );

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
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;
--end task weighting changes

--3035902: process update flag changes
l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(x_parent_struc_ver_id, 'WORKPLAN');
l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(x_project_id);
--Bug No 3450684 SMukka Commented if condition
--IF ((l_wp_type = 'Y') AND
--    (l_weighting_basis_Code = 'EFFORT') AND
--    (l_progress_flag = 'Y')) THEN
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => p_calling_module
     ,p_project_id            => x_project_id
     ,p_structure_version_id  => x_parent_struc_ver_id
     ,p_update_wbs_flag       => 'Y'
     ,x_return_status         => l_return_status
     ,x_msg_count             => l_msg_count
     ,x_msg_data              => l_msg_data);

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
--end if;
--3035902: end process update flag changes
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_VER_WO_VAL;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_VER_WO_VAL;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'delete_Task_ver_wo_val',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END delete_task_ver_wo_val;

  procedure UPDATE_WORKING_VER_WEIGHT(
    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_id                           IN  NUMBER
   ,p_weighting                         IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
   CURSOR get_working_ver(c_option NUMBER) IS
    select a.element_version_id, c.object_id_from1
      from pa_proj_element_versions a,
           pa_proj_elem_ver_structure b,
           pa_object_relationships c
     where a.parent_structure_version_id = b.element_version_id
       and a.project_id = b.project_id
       and a.proj_element_id = p_task_id
       and a.element_version_id = c.object_id_to1
       and c.object_type_to = 'PA_TASKS'
       and c.relationship_type = 'S'
       and b.status_code <> 'STRUCTURE_PUBLISHED'
       and 1 = c_option
     UNION
    select a.element_version_id, c.object_id_from1
      from pa_proj_element_versions a,
           pa_proj_elem_ver_structure b,
           pa_object_relationships c
     where a.parent_structure_version_id = b.element_version_id
       and a.project_id = b.project_id
       and a.proj_element_id = p_task_id
       and a.element_version_id = c.object_id_to1
       and c.object_type_to = 'PA_TASKS'
       and c.relationship_type = 'S'
       and b.status_code = 'STRUCTURE_PUBLISHED'
       and 2 = c_option;
    l_working_ver_id     NUMBER;
    l_working_parent_id  NUMBER;

   CURSOR get_proj_info IS                        -- Bug 3083997. Modified the cursor to obtain
     select proj.project_id,proj.template_flag    -- the project template flag also.
       from pa_proj_elements ele, pa_projects_all proj
      where ele.proj_element_id = p_task_id
        and ele.project_id = proj.project_id;
    l_project_id         NUMBER;
    l_opt                NUMBER;

    l_template_flag      pa_projects_all.template_flag%TYPE;

  BEGIN
    OPEN get_proj_info;
    FETCH get_proj_info INTO l_project_id,l_template_flag; -- Bug 3083997. To reflect the changed cursor.
    CLOSE get_proj_info;

    IF ('Y'=PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
      l_opt := 1;
    ELSE
      l_opt := 2;
    END IF;

    -- Bug 3083997. A template will not have a published version. So query accordingly.
    IF nvl(l_template_flag,'N') = 'Y' THEN
      l_opt := 1;
    END IF;

    OPEN get_working_ver(l_opt);
    LOOP
      FETCH get_working_ver into l_working_ver_id, l_working_parent_id;
      EXIT WHEN get_working_ver%NOTFOUND;
      --update selected tasks weighting
      update pa_object_relationships
         set WEIGHTING_PERCENTAGE = p_weighting
       where object_id_to1 = l_working_ver_id
         and relationship_type = 'S'
         and object_type_to = 'PA_TASKS';
      --pro-rate peer task weightings
      PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
        p_task_version_id => l_working_parent_id
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
      );
      IF (x_msg_count > 0) THEN
        CLOSE get_working_ver;
        raise FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE get_working_ver;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'UPDATE_WORKING_VER_WEIGHT',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END UPDATE_WORKING_VER_WEIGHT;


 procedure set_new_tasks_to_TBD(
    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_task_id                           IN  NUMBER
   ,p_task_status                       IN  VARCHAR2
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   CURSOR cur_task_hier( c_parent_structure_version_id NUMBER )
   IS
     SELECT proj_element_id, element_version_id
       FROM pa_proj_element_versions ppev,
            ( SELECT object_id_to1 from pa_object_relationships
               WHERE relationship_type = 'S'
               start with object_id_from1 = ( SELECT element_version_id
                                                FROM pa_proj_element_versions ppev
                                               WHERE ppev.proj_element_id = p_task_id
                                                 AND ppev.parent_structure_version_id = c_parent_structure_version_id
                                                 AND project_id = p_project_id
                                                 AND object_type = 'PA_TASKS')
               connect by object_id_from1 = prior object_id_to1
                      and relationship_type = prior relationship_type --bug 3919266
                      and relationship_type = 'S'
             )  pobj
    WHERE ppev.element_version_id = pobj.object_id_to1;

   CURSOR cur_all_wrkng_str_ver
   IS
     SELECT element_version_id
       FROM pa_proj_elem_ver_structure
      WHERE project_id = p_project_id
        AND status_code <> 'STRUCTURE_PUBLISHED';

   CURSOR cur_task_ver_ids( c_parent_structure_version_id NUMBER )
   IS
     SELECT element_version_id FROM pa_proj_element_versions WHERE parent_structure_version_id = c_parent_structure_version_id;

    TYPE task_id_rec_type IS RECORD
         (task_id                  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
          task_version_id          NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
          new_task_flag            VARCHAR2(1)     := 'Y'
          );
    TYPE task_id_tbl_type is TABLE OF task_id_rec_type
                    INDEX BY BINARY_INTEGER;
    pub_task_ids       task_id_tbl_type;
    wrk_task_ids       task_id_tbl_type;
    i                  NUMBER := 0;
    l_parent_struc_ver_id   NUMBER;
   /* Bug 2790703 Begin */
--    l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
    l_task_ver_ids_tbl PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
    l_index number :=0 ;
/* Bug 2790703 End */

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_return_status                VARCHAR2(2);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                     VARCHAR2(250);
    l_versioning_enabled            VARCHAR2(1);

  BEGIN
       IF PA_PROGRESS_UTILS.get_system_task_status( p_task_status ) = 'CANCELLED'
       THEN
          l_versioning_enabled := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED( p_project_id );
          l_parent_struc_ver_id := PA_PROJ_ELEMENTS_UTILS.latest_published_ver_id( p_project_id, 'WORKPLAN' );

          --Store the whole branch of published version under p_task_id in pl/sql table.
          FOR cur_task_hier_rec IN cur_task_hier(l_parent_struc_ver_id) LOOP
               i := i + 1;
               pub_task_ids(i).task_id := cur_task_hier_rec.proj_element_id;
          END LOOP;

          --For rollup
          --Rollup only published version if versioning is disabled.
          IF l_versioning_enabled = 'N'
          THEN
               FOR cur_task_ver_ids_rec IN cur_task_ver_ids( l_parent_struc_ver_id ) LOOP
            /*  Bug 2790703 Begin */
                 -- l_tasks_ver_ids.extend;
                 -- l_tasks_ver_ids(l_tasks_ver_ids.count) := cur_task_ver_ids_rec.element_version_id;
            l_index := l_index + 1;
            l_task_ver_ids_tbl(l_index) := cur_task_ver_ids_rec.element_version_id;
            /*  Bug 2790703 End */

               END LOOP;
          END IF;

          IF l_versioning_enabled = 'Y'
          THEN
             --Get all the working structure versions but NOT PUBLISHED
            i:= 0;
            FOR cur_all_wrkng_str_ver_rec in cur_all_wrkng_str_ver LOOP
                 --Store all the task ids from all working versions under p_task in a pl/sql table
                 FOR cur_task_hier_rec IN cur_task_hier(cur_all_wrkng_str_ver_rec.element_version_id) LOOP
                      i := i + 1;
                      wrk_task_ids(i).task_id := cur_task_hier_rec.proj_element_id;
                      wrk_task_ids(i).task_version_id := cur_task_hier_rec.element_version_id;
                 END LOOP;

                 --For rollup
                 --Rollup only working versions if versioning is enabled.
                 FOR cur_task_ver_ids_rec IN cur_task_ver_ids( cur_all_wrkng_str_ver_rec.element_version_id ) LOOP
            /*  Bug 2790703 Begin */
                     -- l_tasks_ver_ids.extend;
                     -- l_tasks_ver_ids(l_tasks_ver_ids.count) := cur_task_ver_ids_rec.element_version_id;
             l_index := l_index + 1;
             l_task_ver_ids_tbl(l_index) := cur_task_ver_ids_rec.element_version_id;
            /*  Bug 2790703 End */

                 END LOOP;
            END LOOP;

            --Now compare tasks from wrk_task_ids with tasks from pub_task_ids table.
            --If a task from wrk_task_ids pl/sql table does not exists in pub_task_ids then the task must be
            --marked as TO_BE_DELETED.
            --Store all such tasks in
            FOR j in 1..wrk_task_ids.COUNT LOOP
                FOR k in 1..pub_task_ids.COUNT LOOP
                    IF pub_task_ids(k).task_id = wrk_task_ids(j).task_id
                    THEN
                       wrk_task_ids(j).new_task_flag := 'N';
                       exit;
                    ELSE
                       wrk_task_ids(j).new_task_flag := 'Y';
                    END IF;
                END LOOP;
                IF wrk_task_ids(j).task_version_id IS NOT NULL AND
                   wrk_task_ids(j).task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                   wrk_task_ids(j).new_task_flag = 'Y'
                THEN
                    --Update version status for all those tasks that did not exist in the branch in latest pub ver.
                    UPDATE pa_proj_element_versions
                       SET TASK_UNPUB_VER_STATUS_CODE = 'TO_BE_DELETED'
                     WHERE element_version_id = wrk_task_ids(j).task_version_id
                     ;
                END IF;
            END LOOP;
          END IF;

            ---Call the rollup API to rollup schedule dates and effort
    /* Bug 2790703 Begin */
    /*
            PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
                         p_commit => FND_API.G_FALSE,
                         p_element_versions => l_tasks_ver_ids,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);
    */
    -- Bug 4429929 : No need to do Rollup while cancelling a task.
    -- This is decided after discussion with Majid
    /*
        PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
                       p_commit => FND_API.G_FALSE,
                       p_element_versions => l_task_ver_ids_tbl,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);
    */

    /* Bug 2790703 End */


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
            end if;
       END IF;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'set_new_tasks_to_TBD',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END set_new_tasks_to_TBD;


-- Bug 2812855 : Added following procedure to populate actual and estimated dates to all the task versions

PROCEDURE Update_Dates_To_All_Versions(
 p_api_version          IN  NUMBER      :=1.0,
 p_init_msg_list            IN  VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only            IN  VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level         IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module           IN  VARCHAR2    :='SELF_SERVICE',
 p_debug_mode           IN  VARCHAR2    :='N',
 p_max_msg_count            IN  NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id                   IN      NUMBER,
 p_element_version_id       IN  NUMBER,
 x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   CURSOR cur_proj_elem_ver_sch(c_elem_ver_id number, c_project_id NUMBER)
   IS
     SELECT element_version_id, project_id, proj_element_id, actual_start_date, actual_finish_date,
        estimated_start_date, estimated_finish_date, actual_duration, estimated_duration
       FROM pa_proj_elem_ver_schedule
      WHERE element_version_id = c_elem_ver_id
        and project_id = c_project_id;

   cur_proj_elem_ver_sch_rec cur_proj_elem_ver_sch%ROWTYPE;

   CURSOR cur_get_parent_tasks(c_elem_ver_id number)
   IS
    SELECT object_id_from1
        FROM pa_object_relationships
        WHERE object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
        AND object_type_to = 'PA_TASKS'
        AND relationship_type ='S'
        CONNECT BY  PRIOR OBJECT_ID_FROM1 = OBJECT_ID_TO1
               AND  PRIOR relationship_type = relationship_type --bug 3919266
               AND  relationship_type = 'S'
        START WITH OBJECT_ID_TO1 = c_elem_ver_id ;

BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PVT1.Update_Dates_To_All_Versions begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_SCH_VER_PRIVATE_DATES;
    END IF;

    -- Get all the info which needs to be updated to its all the versions
    OPEN cur_proj_elem_ver_sch(p_element_version_id, p_project_id);
    FETCH cur_proj_elem_ver_sch INTO cur_proj_elem_ver_sch_rec;
    CLOSE cur_proj_elem_ver_sch;
    -- Update schedule data for all the versions of the above task

    UPDATE pa_proj_elem_ver_schedule
      SET actual_start_date = cur_proj_elem_ver_sch_rec.actual_start_date
    , actual_finish_date = cur_proj_elem_ver_sch_rec.actual_finish_date
    , estimated_start_date = cur_proj_elem_ver_sch_rec.estimated_start_date
    , estimated_finish_date = cur_proj_elem_ver_sch_rec.estimated_finish_date
    , actual_duration = cur_proj_elem_ver_sch_rec.actual_duration
    , estimated_duration = cur_proj_elem_ver_sch_rec.estimated_duration
    WHERE proj_element_id = cur_proj_elem_ver_sch_rec.proj_element_id
      and project_id = cur_proj_elem_ver_sch_rec.project_id;

   FOR i IN cur_get_parent_tasks(p_element_version_id)
   LOOP
    -- Get all the info of the parent which needs to be updated to its all the versions
     OPEN cur_proj_elem_ver_sch(i.object_id_from1, p_project_id);
     FETCH cur_proj_elem_ver_sch INTO cur_proj_elem_ver_sch_rec;
     CLOSE cur_proj_elem_ver_sch;

    -- Update schedule data for all the versions of the above task

     UPDATE pa_proj_elem_ver_schedule
      SET actual_start_date = cur_proj_elem_ver_sch_rec.actual_start_date
    , actual_finish_date = cur_proj_elem_ver_sch_rec.actual_finish_date
    , estimated_start_date = cur_proj_elem_ver_sch_rec.estimated_start_date
    , estimated_finish_date = cur_proj_elem_ver_sch_rec.estimated_finish_date
    , actual_duration = cur_proj_elem_ver_sch_rec.actual_duration
    , estimated_duration = cur_proj_elem_ver_sch_rec.estimated_duration
     WHERE proj_element_id = cur_proj_elem_ver_sch_rec.proj_element_id
       and project_id = cur_proj_elem_ver_sch_rec.project_id;
   END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
      commit;
  END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_SCH_VER_PRIVATE_DATES;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_SCH_VER_PRIVATE_DATES;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PVT1',
                              p_procedure_name => 'Update_Dates_To_All_Versions',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Update_Dates_To_All_Versions;


/*  procedure rollup_all_working_ver(
    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_task_id                           IN  NUMBER
   ,p_task_status                       IN  NUMBER
   ,x_return_status                     OUT  VARCHAR2
   ,x_msg_count                         OUT  NUMBER
   ,x_msg_data                          OUT  VARCHAR2
) AS
BEGIN


END rollup_all_working_ver;
*/

END PA_TASK_PVT1;

/
