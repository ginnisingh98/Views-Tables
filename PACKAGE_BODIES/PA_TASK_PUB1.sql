--------------------------------------------------------
--  DDL for Package Body PA_TASK_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_PUB1" AS
/* $Header: PATSK1PB.pls 120.23.12010000.10 2009/12/17 21:44:58 nisinha ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_TASK_PUB1';


-- API name                      : Create_Task
-- Type                          : Public procedure
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
-- p_task_manager_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_carrying_out_org_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_priority_code  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
 --FP M development bug 3301192
-- p_structure_type        IN      VARCHAR2 := 'WORKPLAN',
-- p_financial_flag        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes
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
 p_task_manager_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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
 p_parent_structure_id        IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
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
 p_structure_type        IN      VARCHAR2 := 'WORKPLAN',
 p_financial_flag        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_Base_Perc_Comp_Deriv_Code     IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes bug 330119
 x_task_id              IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_TASK';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);

   l_carrying_out_org_id           NUMBER;
   -- added for Bug: 4537865
   l_new_carrying_out_org_id	   NUMBER;
   -- added for Bug: 4537865
   l_task_manager_id               NUMBER;
   l_task_progress_entry_page_id   NUMBER;

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

-- end hyau Bug 2852753

BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.CREATE_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.CREATE_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_Task;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

--Bug 2168170

--hsiu: bug 2669388
/*
--dbms_output.put_line('task number');
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

      IF PA_PROJ_ELEMENTS_UTILS.Check_element_number_Unique
             (
               p_element_number  => rtrim(p_task_number)
              ,p_element_id      => null
              ,p_project_id      => p_project_id
              ,p_structure_id    => p_parent_structure_id
              ,p_object_type     => 'PA_TASKS'
             ) = 'N'
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NOT_NUM_UNIQ');
          raise FND_API.G_EXC_ERROR;

      END IF;
*/
--end bug 2669388

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE'
      and p_link_task_flag = 'N' -- Bug # 5072032.
      THEN

        OPEN get_product_code(p_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );
          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;
      IF l_add_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_CANNOT_ADDTASK');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

-- end hyau Bug 2852753

--dbms_output.put_line( 'Before check_task_mgr_name_or_id' );
--my_error_msg( 'Before check_task_mgr_name_or_id' );

--The following check is required bcoz AMG passes only task manager id but not task manager
--name. So for AMG p_check_id_flag should always be 'Y' not 'A'.
--Confirmed with Selva.

    IF (p_calling_module = 'AMG')
    THEN
        --Check Task Manager and Task Manager Id
      IF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_task_manager_name IS NOT NULL)) OR
         ((p_task_manager_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_task_manager_id IS NOT NULL)) THEN
        --Call Check API.
          pa_tasks_maint_utils.check_task_mgr_name_or_id(
            p_task_mgr_name => p_task_manager_name,
            p_task_mgr_id => p_task_manager_id,
            p_project_id => p_project_id,
            p_check_id_flag => 'Y',
            x_task_mgr_id => l_task_manager_id,
            x_return_status => l_return_status,
            x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Name-Id Conversion
    END IF;

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
        --Check Task Manager and Task Manager Id

--dbms_output.put_line('task manager');
      IF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_task_manager_name IS NOT NULL)) OR
         ((p_task_manager_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_task_manager_id IS NOT NULL)) THEN
        --Call Check API.
          pa_tasks_maint_utils.check_task_mgr_name_or_id(
            p_task_mgr_name => p_task_manager_name,
            p_task_mgr_id => p_task_manager_id,
            p_project_id => p_project_id,
            --p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
            p_check_id_flag => 'A',             --bug fix 2646762
            x_task_mgr_id => l_task_manager_id,
            x_return_status => l_return_status,
            x_error_msg_code => l_error_msg_code);
--dbms_output.put_line( 'l_error_msg_code '||l_error_msg_code );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
        --dbms_output.put_line( 'Task manager id '||l_task_manager_id||'flag '||PA_STARTUP.G_Check_ID_Flag );
      END IF; --End Name-Id Conversion

--dbms_output.put_line('carrying out org');
    --Check Carrying out organization name and Carrying out organization Id
      IF ((p_carrying_out_org_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_carrying_out_org_name IS NOT NULL)) OR
         ((p_carrying_out_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_carrying_out_org_id IS NOT NULL)) THEN

--dbms_output.put_line( 'Before Check_OrgName_Or_Id' );

  IF p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  THEN
     l_carrying_out_org_id := FND_API.G_MISS_NUM;
  ELSE
     l_carrying_out_org_id := p_carrying_out_org_id;
  END IF;

        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => l_carrying_out_org_id
             ,p_organization_name   => p_carrying_out_org_name
             ,p_check_id_flag       => 'Y'
          -- ,x_organization_id     => l_carrying_out_org_id		* commented for Bug: 4537865
             ,x_organization_id	    => l_new_carrying_out_org_id		-- added for Bug: 4537865
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);

        -- added for Bug: 4537865
	IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_carrying_out_org_id := l_new_carrying_out_org_id;
	END IF;
        -- added for Bug: 4537865

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
      END IF; --End Name-Id Conversion
    ELSE
       l_task_manager_id     := p_task_manager_id;
       l_carrying_out_org_id := p_carrying_out_org_id;
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

    IF ((p_task_progress_entry_page <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
        (p_task_progress_entry_page IS NOT NULL)) OR
       ((p_task_progress_entry_page_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
        (p_task_progress_entry_page_id IS NOT NULL)) THEN

      IF (p_task_progress_entry_page_ID = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        l_task_progress_entry_page_id := FND_API.G_MISS_NUM;
      ELSE
        l_task_progress_entry_page_id := p_task_progress_entry_page_id;
      END IF;

      pa_page_layout_utils.Check_pagelayout_Name_Or_Id(
        p_pagelayout_name => p_task_progress_entry_page
       ,p_pagetype_code => 'AI'
       ,x_pagelayout_id => l_task_progress_entry_page_id
       ,x_return_status => l_return_status
       ,x_error_message_code => l_error_msg_code
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
      END IF;
    END IF;

    -- 3944597 Added code to validate task type , if it is not null and not G_PA_MISS_NUM
    -- check task type is valid and effective
    -- if it is not valid or not effective , throw error message

    IF ( p_TYPE_ID IS NOT NULL AND p_TYPE_ID  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN
       IF ('N' = PA_TASK_TYPE_UTILS.check_tk_type_effective(p_TYPE_ID)) THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_EFF_TASK_TYPE_ERR');
          l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    -- 3944597 end

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

--dbms_output.put_line( 'Inside CREATE_TASK API '||p_project_id );

--my_error_msg( 'Inside CREATE_TASK API '||p_project_id  );

--my_error_msg( 'Ref Task Id in create task'||p_ref_task_id );

--dbms_output.put_line('create task pvt');
    -- xxlu added task DFF attributes
    PA_TASK_PVT1.Create_Task(
              p_api_version       => p_api_version
             ,p_init_msg_list         => p_init_msg_list
             ,p_commit              => p_commit
             ,p_validate_only         => p_validate_only
             ,p_validation_level    => p_validation_level
             ,p_calling_module        => p_calling_module
             ,p_debug_mode        => p_debug_mode
             ,p_max_msg_count         => p_max_msg_count
             ,p_ref_task_id         => p_ref_task_id
             ,p_peer_or_sub         => p_peer_or_sub
             ,p_object_type       => p_object_type
             ,p_project_id        => p_project_id
             ,p_structure_id        => p_structure_id
             ,p_structure_version_id => p_structure_version_id
             ,p_task_number       => rtrim(p_task_number)
             ,p_task_name         => rtrim(p_task_name)
             ,p_task_description      => rtrim(p_task_description)
             ,p_location_id       => p_location_id
             ,p_country             => p_country
             ,p_territory_code        => p_territory_code
             ,p_state_region          => p_state_region
             ,p_city                => p_city
             ,p_task_manager_id => l_task_manager_id
             ,p_carrying_out_org_id => l_carrying_out_org_id
             ,p_priority_code         => p_priority_code
             ,p_TYPE_ID           => p_TYPE_ID
             ,p_status_code       => p_status_code
             ,p_inc_proj_progress_flag  => p_inc_proj_progress_flag
             ,p_pm_product_code => p_pm_product_code
             ,p_pm_task_reference   => p_pm_task_reference
             ,p_closed_date       => p_closed_date
             ,p_scheduled_start_date => p_scheduled_start_date
             ,p_scheduled_finish_date => p_scheduled_finish_date
             ,p_link_task_flag        => p_link_task_flag
             ,p_attribute_category   => p_attribute_category
             ,p_attribute1   => rtrim(p_attribute1)
             ,p_attribute2   => rtrim(p_attribute2)
             ,p_attribute3   => rtrim(p_attribute3)
             ,p_attribute4   => rtrim(p_attribute4)
             ,p_attribute5   => rtrim(p_attribute5)
             ,p_attribute6   => rtrim(p_attribute6)
             ,p_attribute7   => rtrim(p_attribute7)
             ,p_attribute8   => rtrim(p_attribute8)
             ,p_attribute9   => rtrim(p_attribute9)
             ,p_attribute10  => rtrim(p_attribute10)
             ,p_attribute11  => rtrim(p_attribute11)
             ,p_attribute12  => rtrim(p_attribute12)
             ,p_attribute13  => rtrim(p_attribute13)
             ,p_attribute14  => rtrim(p_attribute14)
             ,p_attribute15  => rtrim(p_attribute15)
                      ,p_address_id                        => p_address_id
                      ,p_address1                          => p_address1
                      ,p_work_type_id                      => p_work_type_id
                      ,p_service_type_code                 => p_service_type_code
                      ,p_chargeable_flag                   => p_chargeable_flag
                      ,p_billable_flag                     => p_billable_flag
                      ,p_receive_project_invoice_flag      => p_receive_project_invoice_flag
                   ,p_task_weighting_deriv_code => p_task_weighting_deriv_code
                   ,p_work_item_code => p_work_item_code
                   ,p_uom_code => p_uom_code
                   ,p_wq_actual_entry_code => p_wq_actual_entry_code
                   ,p_task_progress_entry_page_id => l_task_progress_entry_page_id
                   ,p_task_progress_entry_page => p_task_progress_entry_page
                   ,p_parent_structure_id      => p_parent_structure_id
                   ,p_phase_code               => p_phase_code
                   ,p_phase_version_id         => p_phase_version_id
             ,p_tk_attribute_category    => p_tk_attribute_category
             ,p_tk_attribute1    => p_tk_attribute1
             ,p_tk_attribute2    => p_tk_attribute2
             ,p_tk_attribute3    => p_tk_attribute3
             ,p_tk_attribute4    => p_tk_attribute4
             ,p_tk_attribute5    => p_tk_attribute5
             ,p_tk_attribute6    => p_tk_attribute6
             ,p_tk_attribute7    => p_tk_attribute7
             ,p_tk_attribute8    => p_tk_attribute8
             ,p_tk_attribute9    => p_tk_attribute9
             ,p_tk_attribute10 => p_tk_attribute10
                -- Begin : Added for FP_M changes Bug 3305199
        ,p_structure_type        => p_structure_type
        ,p_financial_flag        => p_financial_flag
        ,p_Base_Perc_Comp_Deriv_Code => p_Base_Perc_Comp_Deriv_Code
                -- End : Added for FP_M changes Bug 3305199
             ,x_task_id             => x_task_id
             ,x_return_status         => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             );
             -- end xxlu changes
--dbms_output.put_line( 'After CREATE_TASK API ' );

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

    --x_task_id := l_task_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.CREATE_TASK END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Create_Task;

-- API name                      : Update_Task
-- Type                          : Public procedure
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
-- p_TYPE_ID          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
 p_task_manager_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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

 p_task_weighting_deriv_code IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_parent_structure_id      IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code               IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id         IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,

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
 p_Base_Perc_Comp_Deriv_Code     IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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
 p_shared                IN      VARCHAR2 := 'X' -- Bug 3451073
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_TASK';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
   l_dummy                         VARCHAR2(1);

   l_carrying_out_org_id           NUMBER;
   -- added for bug 4537865
   l_new_carrying_out_org_id	   NUMBER;
   -- added for bug 4537865
   l_task_manager_id               NUMBER;
   l_task_progress_entry_page_id   NUMBER;

   --task manager changes;
   l_cur_task_mgr_person_id        NUMBER;
   l_cur_task_mgr_person           VARCHAR2(250);
   l_project_id                    NUMBER;

   CURSOR get_mgr_info IS
      select ppe.MANAGER_PERSON_ID, papf.FULL_NAME
        from pa_proj_elements ppe, per_all_people_f papf
       where ppe.proj_element_id = p_task_id
         AND ppe.manager_person_id = papf.person_id
         AND  trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1);      --Included by avaithia for Bug # 3448680
        --end task manager changes

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_cur_project_id      NUMBER;
   CURSOR cur_proj_id IS
     SELECT project_id
       FROM pa_proj_elements
      WHERE proj_element_id = p_task_id;

   CURSOR cur_trans_dates ( c_task_id NUMBER ) IS
     SELECT START_DATE, COMPLETION_DATE
     FROM pa_tasks
     WHERE task_id = c_task_id;

   CURSOR cur_task_attr IS
     SELECT pe.ELEMENT_NUMBER, pe.NAME, pe.DESCRIPTION, hou.name
       FROM pa_proj_elements pe, hr_all_organization_units hou
      WHERE pe.proj_element_id = p_task_id
        AND pe.carrying_out_organization_id = hou.organization_id;

   --Bug 3940203 avaithia <start>
   CURSOR cur_is_fin_task IS
     SELECT task_id
       FROM PA_TASKS
      WHERE task_id = p_task_id ;

   l_tsk_id           PA_TASKS.task_id%TYPE ;
   l_err_message       fnd_new_messages.message_text%TYPE  ;
   --Bug 3940203 avaithia <End>

   l_trans_start_date  DATE;
   l_trans_finish_date DATE;
   l_task_number       VARCHAR2(100);
   l_task_name         VARCHAR2(240);
   l_task_description  VARCHAR2(2000);
   l_organization_name VARCHAR2(240);

-- end hyau Bug 2852753
BEGIN

--dbms_output.put_line( 'Entered ' );

    pa_debug.init_err_stack ('PA_TASK_PUB1.UPDATE_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_Task;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Bug 3940203 avaithia <<Start>>
    -- From Forms and SelfService ,User should not be able to null out Organisation Field
    -- for Financial Tasks (because Organisation field is a NOT NULL Column in pa_tasks table)

    -- Actually ,If No Org. Value is passed from UI ,(If user explicitly nulls out the org. field)
    -- in PA_TASKS table , the Org. for the task is defaulted as the Project's Org.

    -- Current Behaviour is : Though it is populating default org.id (project's org.id) for task
    --                        in pa_tasks table,In UI it is showing Org. field as NULL

    -- We should not allow this (Org. field being nulled out )
    -- Note : Same should be the case with AMG also .Because ,AMG changes will be reflected in UI

       IF p_calling_module = 'SELF_SERVICE' OR
          p_calling_module = 'FORMS' OR
          p_calling_module = 'AMG'
       THEN
            OPEN cur_is_fin_task ;
            FETCH cur_is_fin_task INTO l_tsk_id ;

            IF cur_is_fin_task%FOUND THEN
                CLOSE cur_is_fin_task ;
                --The task is a financial task
                --So,If Organisation is passed as NULL
                --Then throw error message

                --In Self Service ,We pass Organisation Name anyway.So,If it is not passed throw error
                --In FORMS / AMG ,We may be getting the Org. ID .So,Check If any of name or id is available,it is ok.
                --        If both are not available then throw error.

                IF (p_carrying_out_org_name IS NULL)
                    OR (p_carrying_out_org_name =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

                    l_err_message := FND_MESSAGE.GET_STRING('PA','PA_SU_NO_ORG');
                    --Now,Organisation Name is not passed .
                    --If it is AMG /FORMS ,If Org.Id is not also there ,throw error
                    IF p_calling_module = 'AMG' OR p_calling_module = 'FORMS' THEN

                        IF (p_carrying_out_org_id IS NULL)
                        THEN /*We should not check for MISS_NUM In case of AMG/FORMS - Review Comment Incorporated :3940203 */

                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_PS_TASK_NAME_NUM_ERR',
                                                 p_token1         => 'TASK_NAME',
                                                 p_value1         => p_task_name,
                                                 p_token2         => 'TASK_NUMBER',
                                         p_value2         => p_task_number,
                                                 p_token3         => 'MESSAGE',
                                                 p_value3         => l_err_message);
                            RAISE FND_API.G_EXC_ERROR ;
                        END IF;

                    ELSE -- This is case of Self Service
                             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                 p_msg_name       => 'PA_PS_TASK_NAME_NUM_ERR',
                                                 p_token1         => 'TASK_NAME',
                                                 p_value1         => p_task_name,
                                                 p_token2         => 'TASK_NUMBER',
                                                 p_value2         => p_task_number,
                                                 p_token3         => 'MESSAGE',
                                                 p_value3         => l_err_message);
                            RAISE FND_API.G_EXC_ERROR ;
                    END IF ; --End If AMG Context
                END IF;      --End If Org.Name is NULL
            END IF;          --End If Financial Task

       END IF;

    --Bug 3940203 avaithia <<End>>

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN cur_proj_id;
        FETCH cur_proj_id INTO l_cur_project_id;
        CLOSE cur_proj_id;

        OPEN get_product_code(l_cur_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );

          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;

          OPEN cur_task_attr;
          FETCH cur_task_attr INTO l_task_number, l_task_name, l_task_description, l_organization_name;
          CLOSE cur_task_attr;

          -- Check Update Task number
          IF ( l_task_number <> p_task_number ) THEN
        IF l_update_task_num_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_NUM');
              raise FND_API.G_EXC_ERROR;
            END IF;
          END IF;

          -- Check Update Task Name
          IF ( l_task_name <> p_task_name ) THEN
        IF l_update_task_name_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_NAME');
              raise FND_API.G_EXC_ERROR;
            END IF;
          END IF;

          -- If financial task exists, Check Update Task Date
          IF ('Y' = PA_PROJECT_DATES_UTILS.CHECK_FINANCIAL_TASK_EXISTS(p_proj_element_id => p_task_id)) THEN
            OPEN cur_trans_dates(p_task_id);
            FETCH cur_trans_dates INTO l_trans_start_date, l_trans_finish_date;
            CLOSE cur_trans_dates;

            -- if dates are different then check the pm controls
            IF ( nvl(p_transaction_start_date, sysdate) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) OR
               ( nvl(p_transaction_finish_date, sysdate) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) THEN

              IF ( l_trans_start_date is not null and p_transaction_start_date is not null and l_trans_start_date - p_transaction_start_date <> 0) OR
                 ( l_trans_finish_date is not null and p_transaction_finish_date is not null and l_trans_finish_date - p_transaction_finish_date <> 0) OR
                 ( l_trans_start_date is null and p_transaction_start_date is not null) OR
                 ( l_trans_start_date is not null and p_transaction_start_date is null) OR
                 ( l_trans_finish_date is null and p_transaction_finish_date is not null) OR
                 ( l_trans_finish_date is not null and p_transaction_finish_date is null) THEN
              IF l_update_task_dates_allowed = 'N' THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_DATES');
                    raise FND_API.G_EXC_ERROR;
                  END IF;
              END IF;
            END IF;
          END IF;

          -- Check Update Task Description
          IF (l_task_description is not null and p_task_description is not null and l_task_description <> p_task_description ) OR
             (l_task_description is null and p_task_description is not null) OR
             (l_task_description is not null and p_task_description is null) THEN
           IF l_update_task_desc_allowed = 'N' THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_DESC');
                 raise FND_API.G_EXC_ERROR;
               END IF;
          END IF;

          -- Check Update Task Organization
          IF (l_organization_name is not null and p_carrying_out_org_name is not null and l_organization_name <> p_carrying_out_org_name ) OR
             (l_organization_name is null and p_carrying_out_org_name is not null) OR
             (l_organization_name is not null and p_carrying_out_org_name is null) THEN
           IF l_update_task_org_allowed = 'N' THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_ORG');
                 raise FND_API.G_EXC_ERROR;
               END IF;
          END IF;

        END IF;
      END IF;

-- end hyau Bug 2852753


--dbms_output.put_line( 'Lock row ' );

IF (p_calling_module <> 'FORMS')
THEN
    --Lock row
    IF( p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENTS
        where proj_element_id = p_task_id
        and record_version_number = p_record_version_number
        for update of record_version_number NOWAIT;
      EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          ELSE
             raise;
          END IF;
      END;
    ELSE
--dbms_output.put_line( 'check record_version_number ' );

      --check record_version_number
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENTS
        where proj_element_id = p_task_id
        and record_version_number = p_record_version_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
END IF;

--Bug 2168170
      IF p_task_number IS NULL
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NUMBER_NULL');
          raise FND_API.G_EXC_ERROR;
      END IF;

      IF p_task_name IS NULL
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NAME_NULL');
          raise FND_API.G_EXC_ERROR;
      END IF;

--Bug 2168170

--dbms_output.put_line( 'Before calling Name to Id conv ' );

--my_error_msg( 'Before calling Name to Id conv. ' );
--The following check is required bcoz AMG passes only task manager id but not task manager
--name. So for AMG p_check_id_flag should always be 'Y' not 'A'.
--Confirmed with Selva.

    IF (p_calling_module = 'AMG')
    THEN
        --Check Task Manager and Task Manager Id
      IF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_task_manager_name IS NOT NULL)) OR
         ((p_task_manager_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_task_manager_id IS NOT NULL)) THEN
        --Call Check API.
          select project_id into l_project_id
          from PA_PROJ_ELEMENTS
          where proj_element_id = p_task_id;

          select MANAGER_PERSON_ID into l_cur_task_mgr_person_id
          from pa_proj_elements
          where proj_element_id = p_task_id;

          If (p_task_manager_id <> l_cur_task_mgr_person_id)
             OR (l_cur_task_mgr_person_id IS NULL)
             OR (p_task_manager_id IS NULL) THEN
          --end changes for task manager

            pa_tasks_maint_utils.check_task_mgr_name_or_id(
             p_task_mgr_name => p_task_manager_name,
             p_task_mgr_id => p_task_manager_id,
             p_project_id => l_project_id,
             p_check_id_flag => 'Y',
             x_task_mgr_id => l_task_manager_id,
             x_return_status => l_return_status,
             x_error_msg_code => l_error_msg_code);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
	         raise FND_API.G_EXC_ERROR;                      -- bug 4165509
             END IF;
          ELSE
            l_task_manager_id := l_cur_task_mgr_person_id;
          END IF;
      END IF; --End Name-Id Conversion
    END IF;

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
      --Check Task Manager and Task Manager Id
      /* Bug 2769960 -- added check for task_manager is passed as null
         If task manager is passed as null it means user want to remove task manager.
     there is no way in self service, so that  mgr_id is passed but not mgr_name
      */
      IF p_task_manager_name IS NULL THEN
    l_task_manager_id := null;
      ELSIF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
             (p_task_manager_name IS NOT NULL)) THEN
        --Call Check API.
        --added for task manager changes
          select project_id into l_project_id
          from PA_PROJ_ELEMENTS
          where proj_element_id = p_task_id;

          OPEN get_mgr_info;
          FETCH get_mgr_info INTO l_cur_task_mgr_person_id, l_cur_task_mgr_person;
          CLOSE get_mgr_info;

          If (p_task_manager_id <> l_cur_task_mgr_person_id or p_task_manager_name <> l_cur_task_mgr_person)
             --hsiu: added for bug 2688475
             --need these validation for expired project members
             -- who are still task managers
             OR (l_cur_task_mgr_person_id IS NULL)
             OR (p_task_manager_id IS NULL)
             OR (l_cur_task_mgr_person IS NULL)
             OR (p_task_manager_name IS NULL) THEN
          --end changes for task manager

            pa_tasks_maint_utils.check_task_mgr_name_or_id(
              p_task_mgr_name => p_task_manager_name,
              p_task_mgr_id => p_task_manager_id,
              p_project_id => l_project_id,
              p_check_id_flag => 'A',        --bug fix 2646762
              x_task_mgr_id => l_task_manager_id,
              x_return_status => l_return_status,
              x_error_msg_code => l_error_msg_code);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => l_error_msg_code);
	        raise FND_API.G_EXC_ERROR;        -- bug 4165509
            END IF;

            --task manager changes
            --hsiu: added for bug 2688475
          ELSE
             l_task_manager_id := l_cur_task_mgr_person_id;
          END IF;
          --end task manager changes
      END IF; --End Name-Id Conversion

    --Check Carrying out organization name and Carrying out organization Id
      IF ((p_carrying_out_org_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_carrying_out_org_name IS NOT NULL)) OR
         ((p_carrying_out_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_carrying_out_org_id IS NOT NULL)) THEN
--dbms_output.put_line( 'Before calling Name to Id conv : Check_OrgName_Or_Id' );

--dbms_output.put_line( 'Before Id to name p_carrying_out_org_id '||p_carrying_out_org_id );
--dbms_output.put_line( 'Before Id to name p_carrying_out_org_name '||p_carrying_out_org_name );

--my_error_msg( 'p_carrying_out_org_id '||p_carrying_out_org_id );
--my_error_msg( 'p_carrying_out_org_name '||p_carrying_out_org_name );

        IF p_carrying_out_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_carrying_out_org_id := FND_API.G_MISS_NUM;
        ELSE
            l_carrying_out_org_id := p_carrying_out_org_id;
        END IF;

        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => l_carrying_out_org_id
             ,p_organization_name   => p_carrying_out_org_name
             ,p_check_id_flag       => 'A'
           --,x_organization_id     => l_carrying_out_org_id	  * commented for Bug: 4537865
             ,x_organization_id	    => l_new_carrying_out_org_id  -- added for bug 4537865
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);

        -- added for bug 4537865
	IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_carrying_out_org_id := l_new_carrying_out_org_id;
	END IF;
        -- added for bug 4537865
--dbms_output.put_line( 'After Id to name p_carrying_out_org_id '||p_carrying_out_org_id );
--dbms_output.put_line( 'After Id to name l_carrying_out_org_id '||l_carrying_out_org_id );


        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
      END IF; --End Name-Id Conversion
    ELSE
       l_task_manager_id     := p_task_manager_id;
       l_carrying_out_org_id := p_carrying_out_org_id;
    END IF;
--dbms_output.put_line( 'After calling Name to Id conv : Check_OrgName_Or_Id' );
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

    IF ((p_task_progress_entry_page <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
        (p_task_progress_entry_page IS NOT NULL)) OR
       ((p_task_progress_entry_page_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
        (p_task_progress_entry_page_id IS NOT NULL)) THEN

      IF (p_task_progress_entry_page_ID = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        l_task_progress_entry_page_id := FND_API.G_MISS_NUM;
      ELSE
        l_task_progress_entry_page_id := p_task_progress_entry_page_id;
      END IF;

      pa_page_layout_utils.Check_pagelayout_Name_Or_Id(
        p_pagelayout_name => p_task_progress_entry_page
       ,p_pagetype_code => 'AI'
       ,x_pagelayout_id => l_task_progress_entry_page_id
       ,x_return_status => l_return_status
       ,x_error_message_code => l_error_msg_code
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
      END IF;


    END IF;

    /*Bug 4089623 Lead Days Cannot be negative */
    IF  ( nvl(p_wf_lead_days,0) < 0 )
    THEN
         PA_UTILS.add_message('PA','PA_INVALID_LEAD_DAYS');
         l_return_status := FND_API.G_RET_STS_ERROR;
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

--my_error_msg( 'Before calling private API. ' );

--dbms_output.put_line( 'Before calling private API.' );
    PA_TASK_PVT1.Update_Task(
              p_api_version       => p_api_version
             ,p_init_msg_list         => p_init_msg_list
             ,p_commit              => p_commit
             ,p_validate_only         => p_validate_only
             ,p_validation_level    => p_validation_level
             ,p_calling_module  => p_calling_module
             ,p_debug_mode        => p_debug_mode
             ,p_max_msg_count         => p_max_msg_count
             ,p_ref_task_id         => p_ref_task_id
             ,p_peer_or_sub         => p_peer_or_sub
             ,p_task_id             => p_task_id
             ,p_task_number       => rtrim(p_task_number)
             ,p_task_name         => rtrim(p_task_name)
             ,p_task_description    => rtrim(p_task_description)
             ,p_location_id       => p_location_id
             ,p_country             => p_country
             ,p_territory_code  => p_territory_code
             ,p_state_region    => p_state_region
             ,p_city                => p_city
             ,p_task_manager_id => l_task_manager_id
             ,p_carrying_out_org_id => l_carrying_out_org_id
             ,p_priority_code         => p_priority_code
             ,p_TYPE_ID           => p_TYPE_ID
             ,p_status_code       => p_status_code
             ,p_inc_proj_progress_flag  => p_inc_proj_progress_flag
             ,p_pm_product_code => p_pm_product_code
             ,p_pm_task_reference   => p_pm_task_reference
             ,p_closed_date       => p_closed_date
             ,p_transaction_start_date => p_transaction_start_date
             ,p_transaction_finish_date => p_transaction_finish_date
             ,p_attribute_category  => p_attribute_category
             ,p_attribute1   => rtrim(p_attribute1)
             ,p_attribute2   => rtrim(p_attribute2)
             ,p_attribute3   => rtrim(p_attribute3)
             ,p_attribute4   => rtrim(p_attribute4)
             ,p_attribute5   => rtrim(p_attribute5)
             ,p_attribute6   => rtrim(p_attribute6)
             ,p_attribute7   => rtrim(p_attribute7)
             ,p_attribute8   => rtrim(p_attribute8)
             ,p_attribute9   => rtrim(p_attribute9)
             ,p_attribute10  => rtrim(p_attribute10)
             ,p_attribute11  => rtrim(p_attribute11)
             ,p_attribute12  => rtrim(p_attribute12)
             ,p_attribute13  => rtrim(p_attribute13)
             ,p_attribute14  => rtrim(p_attribute14)
             ,p_attribute15  => rtrim(p_attribute15)
                      ,p_address_id                        => p_address_id
                      ,p_address1                          => p_address1
                      ,p_work_type_id                      => p_work_type_id
                      ,p_service_type_code                 => p_service_type_code
                      ,p_chargeable_flag                   => p_chargeable_flag
                      ,p_billable_flag                     => p_billable_flag
                      ,p_receive_project_invoice_flag      => p_receive_project_invoice_flag
                   ,p_task_weighting_deriv_code => p_task_weighting_deriv_code
                   ,p_work_item_code => p_work_item_code
                   ,p_uom_code => p_uom_code
                   ,p_wq_actual_entry_code => p_wq_actual_entry_code
                   ,p_task_progress_entry_page_id => l_task_progress_entry_page_id
                   ,p_task_progress_entry_page => p_task_progress_entry_page
                   ,p_parent_structure_id        => p_parent_structure_id
                   ,p_phase_code                 => p_phase_code
                   ,p_phase_version_id           => p_phase_version_id

             ,p_record_version_number => p_record_version_number
             ,p_tk_attribute_category    => p_tk_attribute_category
             ,p_tk_attribute1    => p_tk_attribute1
             ,p_tk_attribute2    => p_tk_attribute2
             ,p_tk_attribute3    => p_tk_attribute3
             ,p_tk_attribute4    => p_tk_attribute4
             ,p_tk_attribute5    => p_tk_attribute5
             ,p_tk_attribute6    => p_tk_attribute6
             ,p_tk_attribute7    => p_tk_attribute7
             ,p_tk_attribute8    => p_tk_attribute8
             ,p_tk_attribute9    => p_tk_attribute9
             ,p_tk_attribute10 => p_tk_attribute10
                -- Begin : Added for FP_M changes Bug 3305199
        ,p_Base_Perc_Comp_Deriv_Code => p_Base_Perc_Comp_Deriv_Code
                -- End : Added for FP_M changes Bug 3305199
             ,p_gen_etc_src_code        => p_gen_etc_src_code
             ,p_wf_item_type    => p_wf_item_type
             ,p_wf_process      => p_wf_process
             ,p_wf_lead_days    => p_wf_lead_days
             ,p_wf_enabled_flag => p_wf_enabled_flag
             ,x_return_status           => l_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
         ,p_shared                  => p_shared       -- Bug 3451073
             );

--dbms_output.put_line( 'After calling private API.' );

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Update_Task;

-- API name                      : Create_Task_version
-- Type                          : Public procedure
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
   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_TASK_VERSION';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);

   l_carrying_out_org_id           NUMBER;
   l_task_manager_id               NUMBER;
BEGIN

    pa_debug.init_err_stack ('PA_TASK_PUB1.CREATE_TASK_VERSION');

    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_Task_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

--dbms_output.put_line( 'Before private API' );

    PA_TASK_PVT1.Create_Task_Version(
             p_api_version        => p_api_version
            ,p_init_msg_list          => p_init_msg_list
            ,p_commit               => p_commit
            ,p_validate_only          => p_validate_only
            ,p_validation_level => p_validation_level
            ,p_calling_module         => p_calling_module
            ,p_debug_mode         => p_debug_mode
            ,p_max_msg_count          => p_max_msg_count
            ,p_ref_task_version_id  => p_ref_task_version_id
            ,p_peer_or_sub        => p_peer_or_sub
            ,p_task_id              => p_task_id
            ,p_attribute_category   => p_attribute_category
            ,p_attribute1    => p_attribute1
            ,p_attribute2    => p_attribute2
            ,p_attribute3    => p_attribute3
            ,p_attribute4    => p_attribute4
            ,p_attribute5    => p_attribute5
            ,p_attribute6    => p_attribute6
            ,p_attribute7    => p_attribute7
            ,p_attribute8    => p_attribute8
            ,p_attribute9    => p_attribute9
            ,p_attribute10   => p_attribute10
            ,p_attribute11   => p_attribute11
            ,p_attribute12   => p_attribute12
            ,p_attribute13   => p_attribute13
            ,p_attribute14   => p_attribute14
            ,p_attribute15   => p_attribute15
        ,p_WEIGHTING_PERCENTAGE => p_WEIGHTING_PERCENTAGE
        ,p_TASK_UNPUB_VER_STATUS_CODE => p_TASK_UNPUB_VER_STATUS_CODE
        ,p_financial_task_flag  => p_financial_task_flag        -- FP_M changes : Bug 3305199 : Bhumesh
            ,x_task_version_id => x_task_version_id
            ,x_return_status   => x_return_status
            ,x_msg_count     => x_msg_count
            ,x_msg_data        => x_msg_data
            );

--dbms_output.put_line( 'Status after private call in public API '||x_return_status );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    --IF (x_return_status <> 'S' ) THEN
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
--dbms_output.put_line( 'raising exception '||x_return_status );

      raise FND_API.G_EXC_ERROR;
    END IF;

--dbms_output.put_line( 'Final status '||x_return_status );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line( 'Final status asasas'||x_return_status );

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PUB1.CREATE_TASK_VERSION END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
--dbms_output.put_line( 'Status in public API exception '||x_return_status );

    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Create_Task_Version;

-- API name                      : Update_Task_version
-- Type                          : Public procedure
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
   l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_TASK_VERSION';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
   l_dummy                         VARCHAR2(1);

   --l_carrying_out_org_id           NUMBER;
   --l_task_manager_id               NUMBER;
BEGIN

    pa_debug.init_err_stack ('PA_TASK_PUB1.UPDATE_TASK_VERSION');

    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_Task_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Lock row
    IF( p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENT_VERSIONS
        where element_version_id = p_task_version_id
        and record_version_number = p_record_version_number
        for update of record_version_number NOWAIT;
      EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          ELSE
             raise;
          END IF;
      END;
    ELSE
      --check record_version_number
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENT_VERSIONS
        where element_version_id = p_task_version_id
        and record_version_number = p_record_version_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;


--dbms_output.put_line('call update task version pvt');
   PA_TASK_PVT1.Update_Task_Version(
             p_api_version        => p_api_version
            ,p_init_msg_list          => p_init_msg_list
            ,p_commit               => p_commit
            ,p_validate_only          => p_validate_only
            ,p_validation_level => p_validation_level
            ,p_calling_module         => p_calling_module
            ,p_debug_mode         => p_debug_mode
            ,p_max_msg_count          => p_max_msg_count
            ,p_ref_task_version_id  => p_ref_task_version_id
            ,p_peer_or_sub        => p_peer_or_sub
            ,p_task_version_id  => p_task_version_id
            ,p_attribute_category    => p_attribute_category
            ,p_attribute1    => p_attribute1
            ,p_attribute2    => p_attribute2
            ,p_attribute3    => p_attribute3
            ,p_attribute4    => p_attribute4
            ,p_attribute5    => p_attribute5
            ,p_attribute6    => p_attribute6
            ,p_attribute7    => p_attribute7
            ,p_attribute8    => p_attribute8
            ,p_attribute9    => p_attribute9
            ,p_attribute10   => p_attribute10
            ,p_attribute11   => p_attribute11
            ,p_attribute12   => p_attribute12
            ,p_attribute13   => p_attribute13
            ,p_attribute14   => p_attribute14
            ,p_attribute15   => p_attribute15
            ,p_record_version_number => p_record_version_number
            ,p_action          => p_action
        ,p_WEIGHTING_PERCENTAGE => p_WEIGHTING_PERCENTAGE
        ,p_TASK_UNPUB_VER_STATUS_CODE => p_TASK_UNPUB_VER_STATUS_CODE
            ,x_return_status   => l_return_status
            ,x_msg_count     => x_msg_count
            ,x_msg_data        => x_msg_data
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_VERSION END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END update_task_version;

-- API name                      : Delete_Task_version
-- Type                          : Public procedure
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
--
--

PROCEDURE Delete_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id  IN  NUMBER,
 p_record_version_number    IN  NUMBER,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_structure_type       IN    VARCHAR2    := 'WORKPLAN',   --bug 3301192
 p_calling_from         IN    VARCHAR2    := 'XYZ',  -- Bug 6023347
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'DELETE_TASK_VERSION';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
   l_dummy                         VARCHAR2(1);
   l_err_code                      NUMBER := 0;
   l_err_stack                     VARCHAR2(630);
   l_err_stage                     VARCHAR2(80);
   --l_carrying_out_org_id         NUMBER;
   --l_task_manager_id             NUMBER;

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   x_err_code         NUMBER        := 0;
   x_err_stack        VARCHAR2(200) := NULL;
   x_err_stage        VARCHAR2(200) := NULL;
   l_error_occured                 VARCHAR2(1) := 'N' ; --Bug2929411

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_project_id      NUMBER;
   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_task_version_id;

-- end hyau Bug 2852753


--hsiu: added for task version status
   CURSOR get_task_info(c_task_version_id NUMBER) IS
     select a.project_id, b.proj_element_id, parent_structure_version_id,
            TASK_UNPUB_VER_STATUS_CODE, b.link_task_flag
       from pa_proj_element_versions a,
            pa_proj_elements b    --bug 4501280
      where element_version_id = c_task_version_id
    --bug 4501280
        AND a.proj_element_id = b.proj_element_id
        AND a.project_id = b.project_id
    --bug 4501280
      ;
   l_task_info_rec   get_task_info%ROWTYPE;
--end changes for task version status

  l_structure_version_id   pa_proj_element_versions.parent_structure_version_id%TYPE ;

-- Bug Fix 4576640
-- Adding a new check to stop users from deleting a linked task.
-- Example:
-- P1 - T1
--      T2-P2
-- In the above scenario we are not allowing the user to delete T2, as this is causing issues in PJI.
-- Though this is a corner case as this happens only in deleting a task in a program which already has a
-- published version.
-- As per the bug updates, we are now stopping user from deleting a linked task and now user has to delete
-- the link manually and then delete the task.

CURSOR is_linked_task(c_task_version_id NUMBER) IS
SELECT 'Y'
FROM DUAL
WHERE EXISTS(
   SELECT pors.object_relationship_id
     FROM pa_object_relationships pors,
          pa_object_relationships pors1
    WHERE pors1.object_id_from1 = c_task_version_id
      AND pors.object_id_from1 = pors1.object_id_to1
      AND pors1.relationship_type = 'S'
      AND pors.relationship_type IN ('LW','LF')
      AND pors.object_id_from2 <> pors.object_id_to2
      AND pors.object_type_from = 'PA_TASKS'
      AND pors.object_type_to = 'PA_STRUCTURES');

l_linked_task VARCHAR2(1);
--anurag
l_ntf_id NUMBER;

cursor task_ntf(c_task_id NUMBER,c_project_id NUMBER) IS
  SELECT max(notification_id) ntf_id
               FROM   WF_NOTIFICATIONS WFN
	           WHERE  message_type = 'PATASKWF'
               AND    status = 'OPEN'
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'TASK_NUMBER'
                          AND    text_value like (select element_number from pa_proj_elements
												  where proj_element_id = c_task_id)
                             )
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'PROJECT_NUMBER'
                          AND    text_value like (select segment1 from pa_projects_all
												  where project_id = c_project_id)
                             );


BEGIN

    pa_debug.init_err_stack ('PA_TASK_PUB1.DELETE_TASK_VERSION');

    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_TASK_PUB1.DELETE_TASK_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_Task_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

IF p_calling_module <> 'FORMS'
THEN
    --Lock row
    IF( p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENT_VERSIONS
        where element_version_id = p_task_version_id
        and record_version_number = p_record_version_number
        for update of record_version_number NOWAIT;
      EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          l_error_occured  := 'Y' ; --Bug2929411
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
          l_error_occured  := 'Y' ; --Bug2929411
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
             l_error_occured := 'Y' ; --Bug2929411
          ELSE
             raise;
          END IF;
      END;
    ELSE
      --check record_version_number
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEMENT_VERSIONS
        where element_version_id = p_task_version_id
        and record_version_number = p_record_version_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
          l_error_occured := 'Y' ; --Bug2929411
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 AND l_error_occured = 'Y' THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
END IF;  --<< p_calling module >>

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN cur_proj_id;
        FETCH cur_proj_id INTO l_project_id;
        CLOSE cur_proj_id;

        OPEN get_product_code(l_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => x_err_code,
         P_ERROR_STACK                    => x_err_stack,
         P_ERROR_STAGE                => x_err_stage );

          IF x_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => x_err_stage);
          END IF;
      IF l_delete_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_CANNOT_DELETE');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

-- end hyau Bug 2852753

    --hsiu: task version status changes
    --check delete task ok
    OPEN get_task_info(p_task_version_id);
    FETCH get_task_info into l_task_info_rec;
    CLOSE get_task_info;

    /* Bug 4068685 : If p_structure_version_id is not passed to this Delete_Task_Version API
                     then it will be defaulted to MISS_NUM .In that case ,Use the retrieved value of
                     parent_structure_version_id from l_task_info_rec
    */
	--anurag
	open task_ntf(l_task_info_rec.proj_element_id,l_task_info_rec.project_id);
	fetch task_ntf into l_ntf_id;
	close task_ntf;
	if(l_ntf_id is not null)
	then
	update  WF_NOTIFICATIONS
	set status = 'CLOSED'
	where notification_id = l_ntf_id ;
	end if;

    IF (p_structure_version_id IS NOT NULL)
       AND (p_structure_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
        l_structure_version_id := l_task_info_rec.parent_structure_version_id ;
    ELSE
        l_structure_version_id := p_structure_version_id ;
    END IF;

    /*In the following function call , changed value of p_parent_structure_ver_id parameter
      from p_structure_version_id to l_structure_version_id
      for Bug 4068685
    */
    --6023347: No need to check tasks if complete version is to be deleted from Workplan Version Disabling
    IF p_calling_from <> 'DEL_WP_STRUC_DISABLE_VERSION' THEN  -- 6023347
      --Check if it is okay to delete task version. Also checks financial task
      PA_PROJ_ELEMENTS_UTILS.Check_Del_all_task_Ver_Ok(p_project_id => l_task_info_rec.project_id
                            ,p_task_version_id => p_task_version_id
                            ,p_parent_structure_ver_id => l_structure_version_id -- 4068685
                            ,x_return_status => l_return_status
                            ,x_error_message_code => l_error_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_error_msg_code);
        l_msg_data := l_error_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; -- 6023347

    -- Bug Fix 4576640.
    -- Now stopping the user from deleting a linked task.

    OPEN is_linked_task(p_task_version_id);
    FETCH is_linked_task INTO l_linked_task;
    CLOSE is_linked_task;

    IF l_linked_task = 'Y' THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PS_CANT_DEL_LINKED_TASK');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

-- End of Bug Fix 4576640.

    --ok to delete. decide whether to delete or modify version status
    --Check if shared
--bug 4501280
   IF l_task_info_rec.link_task_flag = 'N'
   THEN
--bug 4501280
    IF (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(l_task_info_rec.project_id) = 'Y') THEN
      --sharing enabled
      IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_task_info_rec.project_id) = 'Y') THEN
        --versioning on
        IF (l_task_info_rec.task_unpub_ver_status_code = 'PUBLISHED' OR
            l_task_info_rec.task_unpub_ver_status_code = 'TO_BE_DELETED')
            AND p_called_from_api <> 'DELETE_STRUCTURE_VERSION' THEN          -- Bug 3056077. We need to delete the task versions
          --change status to TO_BE_DELETED                                    -- when the structure version is to be deleted.

            -- 3955848 Added following code to validate task to deliverable association deletion
            -- related validations , p_delete_or_validate is passed as 'V' because only validation will be done

            PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk
             (
                 p_task_element_id      => l_task_info_rec.proj_element_id
                ,p_project_id           => l_task_info_rec.project_id
                ,p_task_version_id      => p_task_version_id
                ,p_delete_or_validate   => 'V'
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
             );

             IF x_return_status = FND_API.G_RET_STS_ERROR then
                 RAISE FND_API.G_EXC_ERROR;
             End If;

            -- 3955848 end

          PA_TASK_PVT1.update_task_ver_delete_status(
                 p_task_version_id => p_task_version_id
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

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

          return; --only set the version status
        ELSE --not published
          NULL; --continue to delete
        END IF; --task version status
      ELSE -- versioning off
        NULL; --continue to delete
      END IF;
    ELSE --not shared
      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_task_info_rec.parent_structure_version_id, 'FINANCIAL') = 'Y') THEN
        --Financial structure
        NULL; --continue to delete
      ELSE --Workplan structure
        --check if versioning is on
        IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_task_info_rec.project_id) = 'Y') THEN
          --versioning on
          IF (l_task_info_rec.task_unpub_ver_status_code = 'PUBLISHED' OR
              l_task_info_rec.task_unpub_ver_status_code = 'TO_BE_DELETED')
              AND p_called_from_api <> 'DELETE_STRUCTURE_VERSION' THEN          -- Bug 3056077. We need to delete the task versions
            --change status to TO_BE_DELETED                                    -- when the structure version is to be deleted.

            -- 3955848 Added following code to validate task to deliverable association deletion
            -- related validations , p_delete_or_validate is passed as 'V' because only validation will be done

            PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk
             (
                 p_task_element_id      => l_task_info_rec.proj_element_id
                ,p_project_id           => l_task_info_rec.project_id
                ,p_task_version_id      => p_task_version_id
                ,p_delete_or_validate   => 'V'
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
             );

             IF x_return_status = FND_API.G_RET_STS_ERROR then
                 RAISE FND_API.G_EXC_ERROR;
             End If;

            -- 3955848 end

            PA_TASK_PVT1.update_task_ver_delete_status(
                 p_task_version_id => p_task_version_id
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

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

            return; --only set the status
          ELSE
            NULL; --delete task version
          END IF;
        ELSE
          --versioning off
          NULL; --delete task version
        END IF;
      END IF;
    END IF;
  END IF;   --bug 4501280
    --end task version status changes


--dbms_output.put_line('delete pvt');
    PA_TASK_PVT1.Delete_Task_Version(
             p_api_version        => p_api_version
            ,p_init_msg_list          => p_init_msg_list
            ,p_commit               => p_commit
            ,p_validate_only          => p_validate_only
            ,p_validation_level => p_validation_level
            ,p_calling_module         => p_calling_module
            ,p_debug_mode         => p_debug_mode
            ,p_max_msg_count          => p_max_msg_count
            ,p_structure_version_id => l_structure_version_id -- Old Value : p_structure_version_id : 4068685
            ,p_task_version_id  => p_task_version_id
            ,p_record_version_number => p_record_version_number
            ,p_called_from_api       => p_called_from_api
        ,p_structure_type        => p_structure_type     -- FP_M changes 3305199
            ,x_return_status        => l_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data             => x_msg_data
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.DELETE_TASK_VERSION END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'DELETE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_task_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'DELETE_TASK_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END delete_task_version;

-- API name                      : Create_Schedule_Version
-- Type                          : Public procedure
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
-- p_calendar_name  IN  VARCHAR2    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--  16-OCT-02   XXLU                     - Added DFF parameters.
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
 p_calendar_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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

 p_WQ_PLANNED_QUANTITY  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199
 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199
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
 x_pev_schedule_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_SCHEDULE_VERSION';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);
BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.create_schedule_VERSION');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.CREATE_SCHEDULE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_schedule_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_TASK_PVT1.Create_Schedule_Version(
             p_api_version        => p_api_version
            ,p_init_msg_list          => p_init_msg_list
            ,p_commit               => p_commit
            ,p_validate_only          => p_validate_only
            ,p_validation_level => p_validation_level
            ,p_calling_module         => p_calling_module
            ,p_debug_mode         => p_debug_mode
            ,p_max_msg_count          => p_max_msg_count
            ,p_element_version_id   => p_element_version_id
            ,p_calendar_id        => p_calendar_id
            ,p_scheduled_start_date => p_scheduled_start_date
            ,p_scheduled_end_date   => p_scheduled_end_date
            ,p_obligation_start_date => p_obligation_start_date
            ,p_obligation_end_date  => p_obligation_end_date
            ,p_actual_start_date    => p_actual_start_date
            ,p_actual_finish_date   => p_actual_finish_date
            ,p_estimate_start_date  => p_estimate_start_date
            ,p_estimate_finish_date => p_estimate_finish_date
            ,p_duration             => p_duration
            ,p_early_start_date => p_early_start_date
            ,p_early_end_date         => p_early_end_date
            ,p_late_start_date  => p_late_start_date
            ,p_late_end_date          => p_late_end_date
            ,p_milestone_flag         => p_milestone_flag
            ,p_critical_flag          => p_critical_flag
            ,x_pev_schedule_id  => x_pev_schedule_id
            ,p_wq_planned_quantity => p_wq_planned_quantity
            ,p_planned_effort      => p_planned_effort
            ,p_PLANNED_EQUIP_EFFORT => p_PLANNED_EQUIP_EFFORT
            ,p_def_sch_tool_tsk_type_code => p_def_sch_tool_tsk_type_code
            ,p_constraint_type_code       => p_constraint_type_code
            ,p_constraint_date            => p_constraint_date
            ,p_free_slack                 => p_free_slack
            ,p_total_slack                => p_total_slack
            ,p_effort_driven_flag         => p_effort_driven_flag
            ,p_level_assignments_flag     => p_level_assignments_flag
            ,p_ext_act_duration           => p_ext_act_duration
            ,p_ext_remain_duration        => p_ext_remain_duration
            ,p_ext_sch_duration           => p_ext_sch_duration
            ,p_attribute_category               => p_attribute_category
            ,p_attribute1                       => p_attribute1
            ,p_attribute2                       => p_attribute2
            ,p_attribute3                       => p_attribute3
            ,p_attribute4                       => p_attribute4
            ,p_attribute5                       => p_attribute5
            ,p_attribute6                       => p_attribute6
            ,p_attribute7                       => p_attribute7
            ,p_attribute8                       => p_attribute8
            ,p_attribute9                       => p_attribute9
            ,p_attribute10                    => p_attribute10
            ,p_attribute11                    => p_attribute11
            ,p_attribute12                    => p_attribute12
            ,p_attribute13                    => p_attribute13
            ,p_attribute14                    => p_attribute14
            ,p_attribute15                    => p_attribute15
            ,x_return_status          => l_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data             => x_msg_data
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.CREATE_SCHEDULE_VERSION END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_SCHEDULE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CREATE_SCHEDULE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Create_Schedule_Version;


-- API name                      : Update_Schedule_Version
-- Type                          : Public procedure
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
-- p_calendar_name  IN  VARCHAR2    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--  16-OCT-02   XXLU                     - Added DFF parameters.
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
 p_calendar_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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

 p_WQ_PLANNED_QUANTITY  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199
 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
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
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Schedule_Version';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
   l_dummy                         VARCHAR2(1);

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_project_id      NUMBER;

   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_elem_ver_schedule
      WHERE pev_schedule_id = p_pev_schedule_id;

   CURSOR cur_schedule_dates IS
   SELECT SCHEDULED_START_DATE, SCHEDULED_FINISH_DATE
   FROM pa_proj_elem_ver_schedule
   WHERE pev_schedule_id = p_pev_schedule_id;

   l_cur_sch_start_date  DATE;
   l_cur_sch_end_date    DATE;

   l_Structure_Version_ID   NUMBER;

-- end hyau Bug 2852753

BEGIN

    pa_debug.init_err_stack ('PA_TASK_PUB1.update_schedule_VERSION');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.update_SCHEDULE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_schedule_version;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Added for FP_M changes 3305199

    OPEN cur_proj_id;
    FETCH cur_proj_id INTO l_project_id;
    CLOSE cur_proj_id;

    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(l_Project_ID) = 'Y' Then

       Select a.Parent_Structure_Version_ID
       Into   l_Structure_Version_ID
       From   PA_Proj_Element_Versions a,  pa_proj_elem_ver_schedule b
       Where  a.Element_Version_ID = b.Element_Version_ID
       and    b.pev_schedule_id = p_pev_schedule_id;

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

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN cur_proj_id;
        FETCH cur_proj_id INTO l_project_id;
        CLOSE cur_proj_id;

        OPEN get_product_code(l_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          -- check to see if the schedule dates are actually different
          OPEN cur_schedule_dates;
          FETCH cur_schedule_dates INTO l_cur_sch_start_date, l_cur_sch_end_date;
          CLOSE cur_schedule_dates;

          --Bug 3736889
--          IF ((p_scheduled_start_date is not null) and  (p_scheduled_start_date - l_cur_sch_start_date <> 0 )) OR
--             ((p_scheduled_end_date is not null) and (p_scheduled_end_date - l_cur_sch_end_date <> 0)) THEN
          IF ((p_scheduled_start_date is not null) and
          (p_scheduled_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) and
          (p_scheduled_start_date - l_cur_sch_start_date <> 0 )) OR
             ((p_scheduled_end_date is not null) and
          (p_scheduled_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) and
          (p_scheduled_end_date - l_cur_sch_end_date <> 0)) THEN

            pa_pm_controls.Get_Project_actions_allowed
                  (P_PM_PRODUCT_CODE                => l_pm_product_code,
                   P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                   P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                   P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                   P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                   P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                   P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                   P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                   P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                   P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                   P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                   P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                   P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                   P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                   P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                   P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                   P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                   P_ERROR_CODE             => l_err_code,
               P_ERROR_STACK                    => l_err_stack,
           P_ERROR_STAGE                => l_err_stage );

            IF l_err_code <> 0 THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_err_stage);
            END IF;
        IF l_update_task_dates_allowed = 'N' THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_PR_PM_NO_CHG_TASK_DATES');
                raise FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END IF;
      END IF;

-- end hyau Bug 2852753


    --Lock row
    IF( p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEM_VER_SCHEDULE
        where pev_schedule_id = p_pev_schedule_id
        and record_version_number = p_record_version_number
        for update of record_version_number NOWAIT;
      EXCEPTION
        WHEN TIMEOUT_ON_RESOURCE THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
          l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          IF SQLCODE = -54 then
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
             l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
          ELSE
             raise;
          END IF;
      END;
    ELSE
      --check record_version_number
      BEGIN
        select 'x' into l_dummy
        from PA_PROJ_ELEM_VER_SCHEDULE
        where pev_schedule_id = p_pev_schedule_id
        and record_version_number = p_record_version_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          l_msg_data := 'PA_XC_RECORD_CHANGED';
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;


    PA_TASK_PVT1.Update_Schedule_Version(
             p_api_version        => p_api_version
            ,p_init_msg_list          => p_init_msg_list
            ,p_commit               => p_commit
            ,p_validate_only          => p_validate_only
            ,p_validation_level => p_validation_level
            ,p_calling_module         => p_calling_module
            ,p_debug_mode         => p_debug_mode
            ,p_max_msg_count          => p_max_msg_count
            ,p_pev_schedule_id  => p_pev_schedule_id
            ,p_calendar_id        => p_calendar_id
            ,p_scheduled_start_date => p_scheduled_start_date
            ,p_scheduled_end_date   => p_scheduled_end_date
            ,p_obligation_start_date => p_obligation_start_date
            ,p_obligation_end_date  => p_obligation_end_date
            ,p_actual_start_date    => p_actual_start_date
            ,p_actual_finish_date   => p_actual_finish_date
            ,p_estimate_start_date  => p_estimate_start_date
            ,p_estimate_finish_date => p_estimate_finish_date
            ,p_duration             => p_duration
            ,p_early_start_date => p_early_start_date
            ,p_early_end_date         => p_early_end_date
            ,p_late_start_date  => p_late_start_date
            ,p_late_end_date          => p_late_end_date
            ,p_milestone_flag         => p_milestone_flag
            ,p_critical_flag          => p_critical_flag
            ,p_WQ_PLANNED_QUANTITY    => p_WQ_PLANNED_QUANTITY
            ,p_PLANNED_EFFORT         => p_PLANNED_EFFORT
            ,p_PLANNED_EQUIP_EFFORT   => p_PLANNED_EQUIP_EFFORT
            ,p_def_sch_tool_tsk_type_code => p_def_sch_tool_tsk_type_code
            ,p_constraint_type_code       => p_constraint_type_code
            ,p_constraint_date            => p_constraint_date
            ,p_free_slack                 => p_free_slack
            ,p_total_slack                => p_total_slack
            ,p_effort_driven_flag         => p_effort_driven_flag
            ,p_level_assignments_flag     => p_level_assignments_flag
            ,p_record_version_number => p_record_version_number
            ,p_ext_act_duration           => p_ext_act_duration
            ,p_ext_remain_duration        => p_ext_remain_duration
            ,p_ext_sch_duration           => p_ext_sch_duration
            ,p_attribute_category               => p_attribute_category
            ,p_attribute1                       => p_attribute1
            ,p_attribute2                       => p_attribute2
            ,p_attribute3                       => p_attribute3
            ,p_attribute4                       => p_attribute4
            ,p_attribute5                       => p_attribute5
            ,p_attribute6                       => p_attribute6
            ,p_attribute7                       => p_attribute7
            ,p_attribute8                       => p_attribute8
            ,p_attribute9                       => p_attribute9
            ,p_attribute10                    => p_attribute10
            ,p_attribute11                    => p_attribute11
            ,p_attribute12                    => p_attribute12
            ,p_attribute13                    => p_attribute13
            ,p_attribute14                    => p_attribute14
            ,p_attribute15                    => p_attribute15
            ,x_return_status          => l_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data             => x_msg_data
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.UPDATE_SCHEDULE_VERSION END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_SCHEDULE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_schedule_version;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_SCHEDULE_VERSION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Schedule_Version;

-- API name                      : Copy_Task
-- Type                          : Public procedure
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
-- p_src_project_id IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_project_name   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structre_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_name IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structure_version_id   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_version_name IN  VARCHAR2    N   null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_task_version_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_task_name  IN  VARCHAR2    N   null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_dest_structure_id      IN NUMBER N null   PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_dest_structure_version_id  IN  NUMBER  N   NOT Null
-- p_dest_task_version_id   IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_dest_project_id        IN  NUMBER :=   PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_unpub_ver_status_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_fin_task_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_sharing_enabled      IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_versioning_enabled   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_copy_option    IN  VARCHAR2    N   NOT NULL
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- p_called_from_bulk_api IN VARCHAR2 N NULL
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created --
--

PROCEDURE Copy_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_id         IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_name IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_name   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_version_id IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_version_name   IN  VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_task_version_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_task_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_dest_structure_id      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- 4201927
 p_dest_structure_version_id    IN  NUMBER,
 p_dest_task_version_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_dest_project_id        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- 4201927
 p_task_unpub_ver_status_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- 4201927
 p_fin_task_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_sharing_enabled      IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_versioning_enabled   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_copy_external_flag   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_copy_option        IN    VARCHAR2,
 p_peer_or_sub        IN    VARCHAR2,
 p_prefix               IN    VARCHAR2,
 -- Added for FP_M changes. Refer to tracking Bug 3305199
 p_structure_type              IN              VARCHAR2        :='WORKPLAN',
 p_cp_dependency_flag          IN              VARCHAR2        :='N',
 p_cp_deliverable_asso_flag    IN              VARCHAR2        :='N',
 p_cp_tk_assignments_flag      IN              VARCHAR2        :='N',
 p_cp_people_flag              IN              VARCHAR2        :='N',
 p_cp_financial_elem_flag      IN              VARCHAR2        :='N',
 p_cp_material_items_flag      IN              VARCHAR2        :='N',
 p_cp_equipment_flag           IN              VARCHAR2        :='N',
 -- End of FP_M changes
 p_called_from_bulk_api        IN              VARCHAR2        :='N',  -- 4201927
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'COPY_TASK';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_task_id                       PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);   --bug 3637956
   l_data                          VARCHAR2(2000);   --bug 3637956
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);

   l_src_project_id       NUMBER;
   l_src_structure_id         NUMBER;
   l_src_structure_version_id   NUMBER;
   l_src_task_version_id    NUMBER;

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

  ----------------------------------- FP_M changes : Begin
  -- Refer to tracking bug 3305199
    /* Bug #: 3305199 SMukka                                                         */
    /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
    /* l_Old_Task_Versions_Tab        PA_PLSQL_DATATYPES.IdTabTyp;                   */
    /* l_New_Task_Versions_Tab        PA_PLSQL_DATATYPES.IdTabTyp;                   */
    l_Old_Task_Versions_Tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
    l_New_Task_Versions_Tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
    Rec_Count                      NUMBER;
  ----------------------------------- FP_M changes : End

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

 -- end hyau Bug 2852753

--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
--end changes

--hsiu
--added for task weighing
    CURSOR get_cur_task_ver_weighting(c_ver_id NUMBER) IS
     select WEIGHTING_PERCENTAGE
       from pa_object_relationships
      where object_id_to1 = c_ver_id
        and object_type_to = 'PA_TASKS'
        and relationship_type = 'S';
--end changes

/* Bug 2680486 -- Performance changes -- Selected project_id also in the following cursor, which will
                  be used in other cursors. Also  Restructured it to avoid  Non-mergable view issue */

   CURSOR cur_obj_rel( x_element_version_id NUMBER )
   IS
     SELECT b.element_version_id task_version_id, b.display_sequence display_sequence, b.proj_element_id,
            b.parent_Structure_version_id parent_Structure_version_id, b.wbs_level wbs_level,
        b.project_id,
            b.attribute_category,
            b.attribute1,
            b.attribute2,
            b.attribute3,
            b.attribute4,
            b.attribute5,
            b.attribute6,
            b.attribute7,
            b.attribute8,
            b.attribute9,
            b.attribute10,
            b.attribute11,
            b.attribute12,
            b.attribute13,
            b.attribute14,
            b.attribute15,
        Financial_Task_Flag     -- FP_M changes 3305199 Bhumesh
      FROM  pa_proj_element_versions b,
            pa_proj_elements c
     WHERE b.proj_element_id = c.proj_element_id
       AND c.link_task_flag = 'N'
       AND p_copy_option IN ( 'PA_TASK_SUBTASK', 'PA_ENTIRE_VERSION' )
/*
        -- Added for FP_M changes : Bug 3305199
    and ( p_structure_type = 'WORKPLAN' OR
          ( p_structure_type = 'FINANCIAL' and Financial_Task_Flag = 'Y')
        )
    -- End of FP_M changes : Bug 3305199
*/
       AND b.element_version_id IN ( SELECT object_id_to1
              FROM pa_object_relationships
             WHERE relationship_type = 'S'
        START WITH object_id_from1 = x_element_version_id AND relationship_type = 'S'
        CONNECT BY object_id_from1 = PRIOR object_id_to1 AND relationship_type = prior relationship_type AND relationship_type = 'S' )
     UNION
    SELECT  element_version_id task_version_id, display_sequence display_sequence, ppev.proj_element_id proj_element_id,
           parent_Structure_version_id parent_Structure_version_id, wbs_level wbs_level,
       project_id,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
        Financial_Task_Flag     -- FP_M changes 3305199 Bhumesh
      FROM pa_proj_element_versions ppev
     WHERE ppev.element_version_id = p_src_task_version_id
/* not required any more
        -- Added for FP_M changes : Bug 3305199
    and ( p_structure_type = 'WORKPLAN' OR
          ( p_structure_type = 'FINANCIAL' and Financial_Task_Flag = 'Y')
        )
    -- End of FP_M changes : Bug 3305199
*/
       AND p_copy_option IN( 'PA_TASK_ONLY', 'PA_TASK_SUBTASK' )  --here PA_TASK_SUBTASK is included in the in list to
                                                                  --include the task version id since it will not have any peer
                                                                  --relationship record in object rel table.
     ORDER BY 2;

  CURSOR cur_proj_elems( p_proj_element_id NUMBER )
  IS
    SELECT
          PROJ_ELEMENT_ID
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
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
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
         ,PARENT_STRUCTURE_ID
         ,PHASE_CODE
         ,PHASE_VERSION_ID
         ,WF_ITEM_TYPE
         ,WF_PROCESS
         ,WF_START_LEAD_DAYS
         ,BASE_PERCENT_COMP_DERIV_CODE
      FROM pa_proj_elements
     WHERE proj_element_id = p_proj_element_id;

cur_proj_elems_rec cur_proj_elems%ROWTYPE;


/* Bug 2680486 -- Performance changes -- Commented the following cursor definition. Restructured it to
                                        avoid  Non-mergable view issue*/

/* CURSOR cur_rev_parent_task( x_child_task_id NUMBER, x_wbs_level NUMBER )
 IS
   SELECT a.object_id_from1 parent_task_id
    FROM( SELECT object_id_from1
            FROM pa_object_relationships
           WHERE relationship_type = 'S'
      START WITH OBJECT_ID_TO1 = x_child_task_id
--hsiu: bug 2669388
--      START WITH object_id_from1 = x_child_task_id
      --traverse reverse
      CONNECT BY object_id_to1 = PRIOR object_id_from1 AND relationship_type = 'S' ) a, pa_proj_element_versions b
   WHERE a.object_id_from1 = b.element_version_id
     AND b.wbs_level = x_wbs_level;
*/

 CURSOR cur_rev_parent_task( x_child_task_id NUMBER, x_wbs_level NUMBER )
 IS
   SELECT b.element_version_id parent_task_id
    FROM  pa_proj_element_versions b
   WHERE  b.wbs_level = x_wbs_level
     AND b.element_version_id IN ( SELECT object_id_from1
            FROM pa_object_relationships
           WHERE relationship_type = 'S'
      START WITH OBJECT_ID_TO1 = x_child_task_id
--hsiu: bug 2669388
--      START WITH object_id_from1 = x_child_task_id
      --traverse reverse
      CONNECT BY object_id_to1 = PRIOR object_id_from1 AND relationship_type = 'S'
             AND relationship_type = PRIOR relationship_type) ;


/* Bug 2680486 -- Performance changes -- Passing project_id also to use the index in the following cursor */

 CURSOR cur_struc_id( x_structure_version_id NUMBER, x_project_id NUMBER )
 IS
   SELECT proj_element_id
     FROM pa_proj_elem_ver_structure
    WHERE element_version_id = x_structure_version_id
    AND project_id = x_project_id;


 CURSOR cur_struc_type( x_structure_id NUMBER )
 IS
   SELECT 'Y'
     FROM pa_proj_structure_types ppst
         ,pa_structure_types pst
    WHERE ppst.proj_element_id = x_structure_id
      AND ppst.structure_type_id = pst.structure_type_id
      AND pst.structure_type_class_code = 'WORKPLAN';

    CURSOR cur_struc_type2( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

/* Bug 2623999 -- Commented the following cursor def'n and added a new one below it.
                  We should check a structure version is and not structure id to
          find out a structure version is publised or not */
/*    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';
*/

    --bug 3074706
    --added project_id
    CURSOR cur_pub_versions( c_structure_version_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where element_version_id = c_structure_version_id
         and project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';
    --end bug 3074706

   CURSOR cur_dest_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_dest_task_version_id;

   /* Added the Cursor For Bug #3573143*/
   CURSOR cur_task_id (c_element_version_id IN NUMBER, c_project_id IN NUMBER) IS
     SELECT proj_element_id
     FROM pa_proj_element_versions
     where element_version_id = c_element_version_id
     AND project_id = c_project_id;
   l_cur_task_id cur_task_id%ROWTYPE;
   /* Ended Bug 3573143*/

   -- xxlu added task DFF attributes
   CURSOR cur_task_attr (c_task_id IN NUMBER) IS
     SELECT *
     FROM pa_tasks
     WHERE task_id = c_task_id;
   l_cur_task_attr cur_task_attr%ROWTYPE;
   -- end xxlu changes

 l_dest_project_id      NUMBER;

 l_dummy_char        VARCHAR2(1);
 l_task_number       VARCHAR2(100);
 l_task_name         VARCHAR2(240);
 l_structure_id      NUMBER;
 l_project_id        NUMBER;
 l_published_version VARCHAR2(1);
 l_copy_node_flag    VARCHAR2(1);
 l_ref_task_id       NUMBER;
 l_ref_project_id    NUMBER;

 l_old_wbs_level     NUMBER;

 l_ref_task_version_id  NUMBER;
 l_peer_or_sub          VARCHAR2(4);
 l_task_version_id      NUMBER;
 l_pev_schedule_id      NUMBER;
 l_element_version_id   NUMBER;

--Hsiu added for date rollup
--bug 3991067
--  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
  l_tasks_ver_ids PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
  l_task_cnt NUMBER := 0;
--end bug 3991067

--hsiu added for task weighting
  l_weighting           NUMBER(17,2);

--hsiu added for task status rollup
  l_rollup_task_id NUMBER;

  cursor sub_task_exists(l_parent_task_version_id NUMBER) IS
    select '1'
      from pa_object_relationships
     where object_id_from1 = l_parent_task_version_id
       and object_type_from IN ('PA_TASKS','PA_STRUCTURES')
       and object_type_to IN ('PA_TASKS','PA_STRUCTURES')
       and relationship_type = 'S';

--hsiu added for task version status
  CURSOR cur_proj_is_template(c_project_id NUMBER)
  IS     select 'Y'
           from pa_projects_all
          where project_id = c_project_id
            and template_flag = 'Y';
  l_template_flag VARCHAR2(1);

  l_task_unpub_ver_status_code PA_PROJ_ELEMENT_VERSIONS.TASK_UNPUB_VER_STATUS_CODE%TYPE;
--end hsiu changes

  -- xxlu added for DFF attributes for calling create_schedule_version
  CURSOR cur_proj_elem_ver_sch(c_element_version_id NUMBER, c_project_id NUMBER) IS
  SELECT * FROM pa_proj_elem_ver_schedule
  WHERE project_id = c_project_id
  AND element_version_id = c_element_version_id;

  v_cur_sch  cur_proj_elem_ver_sch%ROWTYPE;

  -- end xxlu changes

--hsiu added for task status
  CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_elem_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_ver_id NUMBER;

--hsiu added for bug 2669388
  CURSOR get_ref_tk_wbs(c_element_version_id NUMBER) IS
    select WBS_LEVEL
      from pa_proj_element_versions
     where element_version_id = c_element_version_id;

  l_ref_tk_wbs_level    NUMBER;
  l_src_tasks_found boolean := false; --Bug2741989

  --3035902: process update flag changes
  l_wp_process_flag VARCHAR2(1);
  l_wp_type         VARCHAR2(1);

  l_src_wp_type     VARCHAR2(1); -- 4223490

  l_weighting_basis_code VARCHAR2(30);
  --3035902: end process update flag changes

  /* Included for Bug 4201927*/
  l_ver_enabled   VARCHAR2(1);
  l_copy_external_flag  VARCHAR2(1);

--bug 3301192 fin plan
/* Bug #: 3305199 SMukka                                                         */
/* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
/* l_old_task_ver_ids          PA_PLSQL_DATATYPES.IdTabTyp;                      */
/* l_new_task_ver_ids          PA_PLSQL_DATATYPES.IdTabTyp;                      */
/* l_old_task_ids              PA_PLSQL_DATATYPES.IdTabTyp;                      */
/* l_new_task_ids              PA_PLSQL_DATATYPES.IdTabTyp;                      */

l_old_task_ver_ids          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
l_new_task_ver_ids          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */

l_old_task_ids              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
l_new_task_ids              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */

l_lowest_task_flag1         VARCHAR2(1);
l_lowest_task_flag2         VARCHAR2(1);
l_fin_task_flag             VARCHAR2(1);  -- fin html changes
--bug 3301192 fin plan


    -- for bug# 3905123 , added cursor and local variable

    CURSOR cur_is_top_task( task_ver_id NUMBER, struct_ver_id number)
    IS
           SELECT
                    'x'
           FROM
                    pa_object_relationships obj
           WHERE
                    obj.object_id_to1 = task_ver_id
                AND obj.object_id_from1 = struct_ver_id
                AND object_type_from = 'PA_STRUCTURES'
                AND object_type_to = 'PA_TASKS'
                AND relationship_type = 'S'
                AND relationship_subtype = 'STRUCTURE_TO_TASK';

    is_top_task_in_dest varchar2(1) := 'N';
    is_top_task   varchar2(1) := NULL;

    -- 3905123 end

BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.COPY_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.COPY_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint copy_task;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    --bug 4075697  copy_task
    PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
    --bug 4075697

    --3035902: process update flag changes
    l_wp_process_flag := 'N';
    --3035902: end process update flag changes

  -- Added for FP_M changes. Bug 3305199 : Bhumesh  xxx

   If p_called_from_bulk_api = 'N' THEN -- 4201927

  OPEN cur_dest_proj_id;
  FETCH cur_dest_proj_id INTO l_dest_project_id;
  CLOSE cur_dest_proj_id;

   ELSE --If called from Bulk API
        l_dest_project_id := p_dest_project_id ;
   END IF;
/*  If p_structure_type = 'WORKPLAN' and
     PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_dest_project_id)
        IN ('SHARE_PARTIAL')
  Then

    PA_TASKS_MAINT_UTILS.CHECK_MOVE_FINANCIAL_TASK_OK (
        p_task_version_id       =>
      , p_ref_task_version_id   => p_dest_task_version_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , x_error_msg_code        => l_error_msg_code);

    IF (x_return_status <> 'Y') THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    End If;
  End If;
*/  --moved below

  -- End of FP_M changes

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        --3035902: process update flag changes
        l_weighting_basis_code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(l_dest_project_id);
        l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_dest_structure_version_id, 'WORKPLAN');
        --3035902: end process update flag changes


        OPEN get_product_code(l_dest_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

      If p_called_from_bulk_api = 'N' THEN

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );

          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;
      IF l_add_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_CANNOT_COPY');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;

      End IF; -- End p_called_from_bulk_Api is N
      END IF;

-- end hyau Bug 2852753

----dbms_output.put_line( 'Before Id to name conv.' );

/* Performance Bug 4201927 : Commenting as this API not called in Move Task version Context
IF p_called_from_api <> 'MOVE_TASK_VERSION'
THEN
*/
 --do not do any validations if called from Move task version API.
    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN


     If p_called_from_bulk_api = 'N' THEN

      IF ((p_src_project_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_project_name IS NOT NULL)) OR
         ((p_src_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_project_id IS NOT NULL)) THEN
        --Call Check API.
          PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
            p_project_name   => p_src_project_name,
            p_project_id     => p_src_project_id,
            x_project_id     => l_src_project_id,
            x_return_status  => l_return_status,
            x_error_msg_code => l_error_msg_code);
           --dbms_output.put_line('after proj name 2 id conv: '||l_src_project_id);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;
       END IF;

      IF ((p_src_structure_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_structure_name IS NOT NULL)) OR
         ((p_src_structure_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_structure_id IS NOT NULL)) THEN
        --Call Check API.
          PA_PROJECT_STRUCTURE_UTILS.Structure_Name_Or_Id
                           (
                              p_project_id             => l_src_project_id
                             ,p_structure_name         => p_src_structure_name
                             ,p_structure_id           => p_src_structure_id
                             ,x_structure_id           => l_src_structure_id
                             ,x_return_status          => l_return_status
                             ,x_error_message_code     => l_error_msg_code
                            );
--dbms_output.put_line('after struct name 2 id conv: '||l_src_structure_id);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;
      END IF; --End Name-Id Conversion

--dbms_output.put_line( 'Before Id to name conv. Structure_Version_Name_Or_Id' );
      IF ((p_src_structure_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_structure_version_name IS NOT NULL)) OR
         ((p_src_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_structure_version_id IS NOT NULL)) THEN
        --Call Check API.
           l_src_structure_version_id := p_src_structure_version_id;
          PA_PROJECT_STRUCTURE_UTILS.Structure_Version_Name_Or_Id
                                (
                              p_structure_id            => l_src_structure_id
                             ,p_structure_version_name  => p_src_structure_version_name
                             ,p_structure_version_id    => p_src_structure_version_id
                             ,x_structure_version_id    => l_src_structure_version_id
                             ,x_return_status           => l_return_status
                             ,x_error_message_code      => l_error_msg_code
                            );
--dbms_output.put_line('after struct ver name 2 id conv: '||l_src_structure_version_id);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;

      END IF; --End Name-Id Conversion

       /*Task Name to ID Conversion : This is not needed in case of call from SS (i.e) Copy Bulk API */
       IF ((p_src_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_task_name IS NOT NULL)) OR
         ((p_src_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_task_version_id IS NOT NULL)) THEN
        --Call Check API.

--dbms_output.put_line( 'Before Id to name conv. task_Ver_Name_Or_Id' );

          PA_PROJ_ELEMENTS_UTILS.task_Ver_Name_Or_Id
                           (
                              p_task_name              => p_src_task_name
                             ,p_task_version_id        => p_src_task_version_id
                             ,p_structure_version_id   => l_src_structure_version_id
                             ,x_task_version_id        => l_src_task_version_id
                             ,x_return_status          => l_return_status
                             ,x_error_msg_code     => l_error_msg_code
                            );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;
      END IF; --End Name-Id Conversion

 /*4201927 : Moved this code outside the Loop*/
-- bug 3301192  financial HTML changes
        IF p_structure_type = 'WORKPLAN'
        THEN
           IF
PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_dest_project_id) =
'SHARE_FULL'
           THEN
              l_fin_task_flag := 'Y';
           ELSE
              l_fin_task_flag := 'N';
           END IF;
        ELSE
            l_fin_task_flag := 'Y';
        END IF;
  -- bug 3301192  financial HTML changes
  /*4201927 : Moved this code outside the Loop*/

      /*4201927 Start <<B>> */
       OPEN cur_struc_id(p_dest_structure_version_id , l_dest_project_id );
       FETCH cur_struc_id INTO l_structure_id;--This is Destination StructureID
       CLOSE cur_struc_id;


       OPEN cur_proj_is_template(l_dest_project_id);
       FETCH cur_proj_is_template into l_template_flag;
       IF cur_proj_is_template%NOTFOUND THEN
            l_template_flag := 'N';
       END IF;
       CLOSE cur_proj_is_template;

       /*4201927 : Moved this code outside the Loop*/
       l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_dest_project_id);
       /*4201927 : Moved this code outside the Loop*/

       /*4201927 : Deriving whether versioned or not only once*/
       l_ver_enabled :=
PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(l_dest_project_id);

       /*4201927 : <<C>> Value for Copy External Flag*/
       IF p_src_project_id = l_dest_project_id
       THEN
           l_copy_external_flag := 'N';
       ELSE
           l_copy_external_flag := 'Y';
       ENd IF;

       --hsiu added for task version status changes
       IF (l_template_flag = 'N') THEN
          --check if structure is shared
          --  if shared, check if versioned
          --    'WORKING' if versioned; 'PUBLISHED' if not
          --  if split, check if 'FINANCIAL'
          --    'PUBLISHED' if financial
          --    check if versioned
          --    'WORKING' if versioend; 'PUBLISHED' if not
          IF ('Y' = l_shared) THEN
            IF ('Y' = l_ver_enabled) THEN
              l_task_unpub_ver_status_code := 'WORKING';
            ELSE
              l_task_unpub_ver_status_code := 'PUBLISHED';
            END IF;
          ELSE --split
            IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id,'FINANCIAL') AND
                'N' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id,'WORKPLAN')) THEN
              l_task_unpub_ver_status_code := 'PUBLISHED';
            ELSE --workplan only
              IF ('Y' = l_ver_enabled) THEN
                l_task_unpub_ver_status_code := 'WORKING';
              ELSE
                l_task_unpub_ver_status_code := 'PUBLISHED';
              END IF;
            END IF;
          END IF;
        ELSE
          l_task_unpub_ver_status_code := 'WORKING';
        END IF;
--end task version status changes

      /*4201927 End <<B>> */
    Else -- If called from copy bulk APi
     l_src_structure_version_id := p_src_structure_version_id;
     l_src_project_id := p_src_project_id ;
     l_src_structure_id := p_src_structure_id ;
     l_src_task_version_id := p_src_task_version_id ;

     l_task_unpub_ver_status_code := p_task_unpub_ver_status_code;
     l_structure_id := p_dest_structure_id ;
     l_fin_task_flag := p_fin_task_flag;

     l_shared :=p_sharing_enabled ;
     l_ver_enabled := p_versioning_enabled;
     l_copy_external_flag := p_copy_external_flag;
     -- as we have already derived this value in copy bulk api

    End If ; --  If p_called_from_bulk_api = 'N'

    END IF;  -- End If Calling module is SS or Exchange


    IF l_src_project_id IS NULL OR l_src_structure_id IS NULL OR
       l_src_structure_version_id IS NULL OR (l_src_task_version_id IS NULL AND p_copy_option <> 'PA_ENTIRE_VERSION')
    THEN
        /* This Copy API not used in Move Task version context : Hence this check is not needed : 4201927
        IF p_called_from_api <> 'MOVE_TASK_VERSION'
        THEN
        */

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PS_NOT_ENOUGH_PARAMS' );
           x_msg_data := 'COPY TASK : PA_PS_NOT_ENOUGH_PARAMS';
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
        /*END IF;  : 4201927 */
    END IF;

/* 4201927 : Perf Fix : END IF;  --move_task_version check. */

    -- 4223490 Included for Copy External Flow
    IF l_copy_external_flag = 'Y' THEN
       l_src_wp_type :=  PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_src_structure_version_id,'WORKPLAN');
    ELSE
       l_src_wp_type := l_wp_type;
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
    --If source task is empty and user not selected copy PA_ENTIRE_VERSION
    IF ( l_src_task_version_id IS NULL AND
         l_src_structure_version_id IS NOT NULL AND
         p_copy_option <> 'PA_ENTIRE_VERSION' ) OR
       ( p_copy_option NOT IN( 'PA_ENTIRE_VERSION', 'PA_TASK_ONLY', 'PA_TASK_SUBTASK'  ) )
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_PS_WRONG_COPY_OPTION' );
        x_msg_data := 'PA_PS_WRONG_COPY_OPTION';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF p_copy_option = 'PA_TASK_ONLY' OR p_copy_option = 'PA_TASK_SUBTASK'
    THEN
       l_element_version_id := l_src_task_version_id;

       /*4201927 : This API not used in Move Task Version Context
       --If called from move_task versionsd then just copy parameter in l_element_verion_id var.
       IF p_called_from_api = 'MOVE_TASK_VERSION'
       THEN
          l_element_version_id := p_src_task_version_id;
       END IF;
       */

    ELSIF p_copy_option = 'PA_ENTIRE_VERSION'
    THEN
       l_element_version_id := l_src_structure_version_id;
    END IF;
    IF p_dest_structure_version_id = p_dest_task_version_id THEN
       --Copying under a structure;
       l_ref_task_version_id := p_dest_structure_version_id;

       --hsiu: bug 2669388
       l_ref_tk_wbs_level := 0;
       --end bug 2669388
    ELSE
       l_ref_task_version_id := p_dest_task_version_id;
       --hsiu: bug 2669388
       OPEN get_ref_tk_wbs(l_ref_task_version_id);
       FETCH get_ref_tk_wbs into l_ref_tk_wbs_level;
       CLOSE get_ref_tk_wbs;

       IF (p_peer_or_sub = 'SUB') THEN
         l_ref_tk_wbs_level := l_ref_tk_wbs_level;
       ELSE
         l_ref_tk_wbs_level := l_ref_tk_wbs_level-1;
       END IF;
       --end bug 2669388
    END IF;

    l_peer_or_sub := p_peer_or_sub;
    --hsiu task status changes
    --check if ok to create subtask
    IF (l_peer_or_sub = 'PEER') THEN
      OPEN get_parent_version_id(l_ref_task_version_id);
      FETCH get_parent_version_id into l_parent_ver_id;
      CLOSE get_parent_version_id;
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code);

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_ref_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );
      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --end task status changes
/* not required in the context of copy_task bcoz when a task is copied, copied as financial if copied under Fin tab and
   workplan if copied under WP tab for a partial share structures.
If p_structure_type = 'WORKPLAN' and
   PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_dest_project_id) = 'SHARE_PARTIAL'
Then
  IF p_dest_structure_version_id <> p_dest_task_version_id  -- reference should not be str ver
  THEN
    PA_TASKS_MAINT_UTILS.CHECK_MOVE_FINANCIAL_TASK_OK (
        p_task_version_id       => l_element_version_id
      , p_ref_task_version_id   => l_ref_task_version_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , x_error_msg_code        => l_error_msg_code);

    IF (x_return_status <> 'Y') THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    End If;
  END IF;
End If;
*/

  --check the task is a lowest task bug 3301192
  IF p_dest_structure_version_id <> p_dest_task_version_id  /* reference should not be str ver */
  THEN
      l_lowest_task_flag1 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_dest_task_version_id );
  END IF;

    --dbms_output.put_line( 'l_element_version_id '||l_element_version_id );

    ----------------------------------------------
    Rec_Count := 0;  -- <-- Added for FP_M changes
    -- Refer to tracking bug 3305199
    ----------------------------------------------
    FOR cur_obj_rel_rec IN cur_obj_rel(  l_element_version_id )  LOOP

    l_src_tasks_found := true; -- Bug2741989

        OPEN cur_proj_elems( cur_obj_rel_rec.proj_element_id );
        FETCH cur_proj_elems INTO cur_proj_elems_rec;
        CLOSE cur_proj_elems;

         IF   length( p_prefix||cur_proj_elems_rec.element_number ) > 100 OR
              length( p_prefix||cur_proj_elems_rec.name ) > 240
         THEN
             l_task_number := SUBSTR( p_prefix||cur_proj_elems_rec.element_number, 1, 100 );
             l_task_name   := SUBSTR( p_prefix||cur_proj_elems_rec.name, 1, 240 );
         ELSE
             l_task_number := p_prefix||cur_proj_elems_rec.element_number;
             l_task_name   := p_prefix||cur_proj_elems_rec.name;
         END IF;

      /*4201927 */
        IF cur_obj_rel%ROWCOUNT = 1
        THEN
      /* Bug 2680486 -- Performance changes -- Passed project_id also in the following statement */

          OPEN cur_struc_id( cur_obj_rel_rec.parent_structure_version_id, cur_obj_rel_rec.project_id );
          FETCH cur_struc_id INTO l_structure_id;
          CLOSE cur_struc_id;
        END IF;
        l_structure_id := p_dest_structure_id ;
        /*4201927 */

--dbms_output.put_line( 'Before PA_TASK_PUB1.Create_Task' );
--dbms_output.put_line( 'Org Id '||cur_proj_elems_rec.carrying_out_organization_id);

       /*4201927 : This Copy API not used in Move Task Version Context , Hence Commenting
        IF (p_called_from_api <> 'MOVE_TASK_VERSION') THEN */
--bug 2846700
--the rest has been moved above create_task_version

          /* 4201927 This l_structure_id correspond's to the destination project's structure id
             for the passed p_dest_structure_version_id.
             In Copy Bulk API we are already deriving this value and passing
             as p_dest_structure_id
             Also,This code need not be present inside FOR LOP for each and every task

             Hence moving it outside the loop
*/
         /* OPEN cur_struc_id(p_dest_structure_version_id , l_dest_project_id );
          FETCH cur_struc_id INTO l_structure_id;  -- (<<A>>)
          CLOSE cur_struc_id;
       */
             /*This code refers to finding whether the destination is a template or project
             It need not be present inside the loop
/*
          --hsiu: added for task version status
          OPEN cur_proj_is_template(l_dest_project_id);
          FETCH cur_proj_is_template into l_template_flag;
          IF cur_proj_is_template%NOTFOUND THEN
            l_template_flag := 'N';
          END IF;
          CLOSE cur_proj_is_template;
          4201927 */
          /* ============ Moved this block of code above the FOR LOOP tagged by <<B>> =====*/

--bug 2846700
        /* END IF; 4201927*/

--hsiu modified for calculating weighting.
        OPEN get_cur_task_ver_weighting(cur_obj_rel_rec.task_version_id);
        FETCH get_cur_task_ver_weighting into l_weighting;
        CLOSE get_cur_task_ver_weighting;

        IF  cur_obj_rel%ROWCOUNT > 1
        THEN
           IF l_old_wbs_level < cur_obj_rel_rec.wbs_level
           THEN
              l_peer_or_sub := 'SUB';
           ELSIF l_old_wbs_level = cur_obj_rel_rec.wbs_level
           THEN
              l_peer_or_sub := 'PEER';
           ELSE
              --if the new task being created is the lower level than the previous one.
              --write logic to find out the task at cur_obj_rel_rec.wbs_level
              -- t1
              --   t1.1
              --   t1.2
              --       t1.2.1
              --       t1.2.2
              --             t1.2.2.1
              --   t1.3 ( new task created here. For this task the ref is t1.2 )
              l_peer_or_sub := 'PEER';
--hsiu: bug 269388
--              OPEN cur_rev_parent_task( l_ref_task_version_id, cur_obj_rel_rec.wbs_level);
              OPEN cur_rev_parent_task( l_ref_task_version_id, cur_obj_rel_rec.wbs_level + l_ref_tk_wbs_level);
--end bug 2669388
              FETCH cur_rev_parent_task INTO l_ref_task_version_id;
          /** Code added for Bug 4046751 . **/
          -- While doing Copy Tasks of the structure below
              -- t1
              --   t1.1
              --       t1.1.1
              --             t1.1.1.1
          --       t1.1.2
          -- If we Copy t1.1, then task t1.1.2 was being created as a peer task of t1.1.1.1.
          -- The code below will ensure that its p_ref_task_id is set to t1.1.1 and not t1.1.1.1
          IF cur_rev_parent_task%NOTFOUND then
              CLOSE cur_rev_parent_task;
          OPEN cur_rev_parent_task( l_ref_task_version_id, cur_obj_rel_rec.wbs_level);
              FETCH cur_rev_parent_task INTO l_ref_task_version_id;
          END if;
          /** Code changes end for BUg 4046751 **/
              CLOSE cur_rev_parent_task;
           END IF;
--hsiu added, for task weighting
        ELSIF cur_obj_rel%ROWCOUNT = 1 THEN
          IF (l_peer_or_sub = 'PEER') THEN
            l_weighting := 0;
          ELSE --'SUB'
            OPEN sub_task_exists(l_ref_task_version_id);
            FETCH sub_task_exists into l_dummy_char;
            IF sub_task_exists%NOTFOUND THEN
              If (p_copy_option <> 'PA_ENTIRE_VERSION') THEN
                l_weighting := 100;
              END IF;
            ELSE
              l_weighting := 0;
            END IF;
          END IF;
--end task weighting modification
        END IF;

        /* This code need not execute for each and every task in LOOP
           4201927 : Moved this code to tagging marked by <<B>>
         -- Start of block moved

----dbms_output.put_line( 'Before PA_TASK_PUB1.Create_Task_Version' );
--hsiu added for task version status changes
        IF (l_template_flag = 'N') THEN
          --check if structure is shared
          --  if shared, check if versioned
          --    'WORKING' if versioned; 'PUBLISHED' if not
          --  if split, check if 'FINANCIAL'
          --    'PUBLISHED' if financial
          --    check if versioned
          --    'WORKING' if versioend; 'PUBLISHED' if not
          IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(l_dest_project_id)) THEN
            IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(l_dest_project_id)) THEN
              l_task_unpub_ver_status_code := 'WORKING';
            ELSE
              l_task_unpub_ver_status_code := 'PUBLISHED';
            END IF;
          ELSE --split
            IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id, 'FINANCIAL')  AND
                'N' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id, 'WORKPLAN')) THEN
              l_task_unpub_ver_status_code := 'PUBLISHED';
            ELSE --workplan only
              IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(l_dest_project_id)) THEN
                l_task_unpub_ver_status_code := 'WORKING';
              ELSE
                l_task_unpub_ver_status_code := 'PUBLISHED';
              END IF;
            END IF;
          END IF;
        ELSE
          l_task_unpub_ver_status_code := 'WORKING';
        END IF;
--end task version status changes

        End Moving Code to <<B>> for 4201927*/

--bug 2846700
--moved here from above to get correct referenct task id and peer_or_sub value
      /*  IF p_called_from_api <> 'MOVE_TASK_VERSION'
        THEN
       4201927 : This Copy API not used in Move Task version Context
       Hence Commented
      */
          --added for task version status

          /* Bug 3573143 */
          OPEN cur_task_id(p_src_task_version_id, p_src_project_id);
      FETCH cur_task_id INTO l_cur_task_id;
      CLOSE cur_task_id;
      /* Ended Bug 3573143 */
          -- xxlu added task DFF attributes

      /* Commented the following code Bug 3573143 */
          /* OPEN cur_task_attr(p_src_structure_id); */
      OPEN cur_task_attr(l_cur_task_id.proj_element_id); -- Added Bug 3573143
          FETCH cur_task_attr INTO l_cur_task_attr;
          CLOSE cur_task_attr;

          l_task_id := null;     --bug 2625556

          /* Bug 2623999 -- added the following select to get the ref_task_id*/
          --bug 2846700
          --modified sql to get correct reference task
    --mwasowic: handle a  case when we're copying the top task and
    -- l_ref_task_version_id is really a structure version id, bug 3587047

    IF p_dest_structure_version_id = p_dest_task_version_id THEN

          -- 3905123 added below code

          -- check whether source task is top task or not
          -- if source task is top task
          --    in destination structure, check the task is getting created as PEER or SUB
          --    if task is getting created as SUB
          --        pass l_ref_task_id as NULL
          --    else
          --        derive proj_element_id for the destination task and pass as l_ref_task_id
          --    end if
          -- else
          --    if copy_option is 'PA_TASK_ONLY' or 'PA_TASK_SUBTASK' and source task is not the top task
          --       and first task is getting created in destination structure then
          --        pass l_ref_task_id as NULL
          --        ( this code will be only called once while creating the first top task in dest struct,
          --          which is not the top task in source structure , copy option is PA_TASK_ONLY or PA_TASK_SUBTASK )
          --    else
          --        derive proj_element_id for the destination and pass as l_ref_task_id
          --    end if
          -- end if

          -- Exp : Copy Option is 'ENTIRE_STRUCTURE' and source structure is

          --        |_T1        ( l_ref_task_id will be passed as NULL )
          --        |  |_T1.1   ( l_ref_task_id will be passed as detn task T1's proj_element_id )
          --        |_T2        ( l_ref_task_id will be passed as detn task T1's proj_element_id )

          is_top_task := null;

          open cur_is_top_task(cur_obj_rel_rec.task_version_id, l_src_structure_version_id);
          fetch cur_is_top_task INTO is_top_task;
          CLOSE cur_is_top_task;

          IF is_top_task = 'x' THEN
            IF l_peer_or_sub = 'PEER' THEN
              SELECT proj_element_id
              INTO l_ref_task_id
              FROM pa_proj_element_versions
              WHERE element_version_id = l_ref_task_version_id;
            ELSE
              l_ref_task_id := null;
            END IF;
          ELSE
              IF is_top_task_in_dest = 'N' AND (p_copy_option IN ('PA_TASK_ONLY','PA_TASK_SUBTASK')) THEN
                  l_ref_task_id := NULL;
              ELSE
                  SELECT proj_element_id
                  INTO l_ref_task_id
                  FROM pa_proj_element_versions
                  WHERE element_version_id = l_ref_task_version_id;
              END IF;
          END IF;

          -- 3905123 end
    ELSE
          SELECT proj_element_id
          INTO l_ref_task_id
          FROM pa_proj_element_versions
          WHERE element_version_id = l_ref_task_version_id;
          --commented for bug 2846700
          --WHERE element_version_id = p_dest_task_version_id;
    END IF;

    -- 3905123 , once the first task is created in destination, change the value of is_top_task_in_dest var to 'Y'

    IF is_top_task_in_dest = 'N' AND p_dest_structure_version_id = p_dest_task_version_id THEN
        is_top_task_in_dest := 'Y';
    END IF;

    -- 3905123 end

          --3035902: process update flag changes
          --set update process flag if necessary;

          IF (l_wp_process_flag = 'N') THEN
            --may need to update process flag
            IF ((l_shared = 'N') AND
                (l_wp_type = 'Y') AND
                (pa_task_type_utils.check_tk_type_progressable(cur_proj_elems_rec.TYPE_ID)='Y') AND
                (l_weighting_basis_code <> 'MANUAL'))
            THEN
              --split and workplan; only update if progressable task added
              l_wp_process_flag := 'Y';
            ELSIF ((l_shared = 'N') AND
                   (l_wp_type = 'N')) THEN
              --split and financial; update
              l_wp_process_flag := 'Y';
            ELSIF (l_shared = 'Y') THEN
              l_wp_process_flag := 'Y';
            END IF;
          END IF;
          --3035902: end process update flag changes

          PA_TASK_PVT1.Create_Task(
                       p_api_version            => p_api_version
                       ,p_init_msg_list         => p_init_msg_list
                       ,p_commit                  => p_commit
                       ,p_validate_only         => p_validate_only
                       ,p_validation_level    => p_validation_level
                       ,p_calling_module            => p_calling_module
                       ,p_debug_mode            => p_debug_mode
                       ,p_max_msg_count         => p_max_msg_count
                       ,p_object_type           => cur_proj_elems_rec.object_type
                       ,p_project_id            => l_dest_project_id
                       ,p_structure_id            => l_structure_id
                       ,p_structure_version_id    => p_dest_structure_version_id
                       ,p_task_number           => l_task_number
               ,p_task_name               => l_task_name
                       ,p_task_description    => cur_proj_elems_rec.description
                       ,p_location_id           => cur_proj_elems_rec.location_id
                     --p_country                  => null
                     --p_territory_code         => null
                     --p_state_region           => null
                     --p_city                       => null
                       ,p_task_manager_id           => cur_proj_elems_rec.manager_person_id
                     --p_task_manager_name    => null
                      ,p_carrying_out_org_id      => cur_proj_elems_rec.carrying_out_organization_id
                     --p_carrying_out_org_name    => null
                       ,p_priority_code         => cur_proj_elems_rec.priority_code
                       ,p_TYPE_ID                 => cur_proj_elems_rec.TYPE_ID
                     --,p_status_code           => cur_proj_elems_rec.status_code
                       ,p_inc_proj_progress_flag  => cur_proj_elems_rec.inc_proj_progress_flag
                     --,p_pm_product_code           => cur_proj_elems_rec.pm_product_code
                     --,p_pm_task_reference   => cur_proj_elems_rec.pm_task_reference
                       ,p_closed_date           => cur_proj_elems_rec.closed_date
                     --p_scheduled_start_date     => null
                     --p_scheduled_finish_date    => null
                       ,p_attribute_category      => cur_proj_elems_rec.attribute_category
                       ,p_attribute1            => cur_proj_elems_rec.attribute1
                       ,p_attribute2            => cur_proj_elems_rec.attribute2
                       ,p_attribute3            => cur_proj_elems_rec.attribute3
                       ,p_attribute4            => cur_proj_elems_rec.attribute4
                       ,p_attribute5            => cur_proj_elems_rec.attribute5
                       ,p_attribute6            => cur_proj_elems_rec.attribute6
                       ,p_attribute7            => cur_proj_elems_rec.attribute7
                       ,p_attribute8            => cur_proj_elems_rec.attribute8
                       ,p_attribute9            => cur_proj_elems_rec.attribute9
                       ,p_attribute10           => cur_proj_elems_rec.attribute10
                       ,p_attribute11           => cur_proj_elems_rec.attribute11
                       ,p_attribute12           => cur_proj_elems_rec.attribute12
                       ,p_attribute13           => cur_proj_elems_rec.attribute13
                       ,p_attribute14           => cur_proj_elems_rec.attribute14
                       ,p_attribute15           => cur_proj_elems_rec.attribute15
                       ,p_task_weighting_deriv_code =>NULL
                       ,p_work_item_code        =>cur_proj_elems_rec.WQ_ITEM_CODE
                       ,p_uom_code              =>cur_proj_elems_rec.WQ_UOM_CODE
                       ,p_wq_actual_entry_code  =>cur_proj_elems_rec.WQ_ACTUAL_ENTRY_CODE
                       ,p_task_progress_entry_page_id =>cur_proj_elems_rec.TASK_PROGRESS_ENTRY_PAGE_ID
                       ,p_parent_structure_id     => cur_proj_elems_rec.parent_structure_id
/* hy Bug 2767403 Fix - Should not copy phase when copy task
                       ,p_phase_code              => cur_proj_elems_rec.phase_code
                       ,p_phase_version_id        => cur_proj_elems_rec.phase_version_id
 end hy Bug 2767403 Fix */
                       ,p_tk_attribute_category  => l_cur_task_attr.attribute_category
                       ,p_tk_attribute1  => l_cur_task_attr.attribute1
                       ,p_tk_attribute2  => l_cur_task_attr.attribute2
                       ,p_tk_attribute3  => l_cur_task_attr.attribute3
                       ,p_tk_attribute4  => l_cur_task_attr.attribute4
                       ,p_tk_attribute5  => l_cur_task_attr.attribute5
                       ,p_tk_attribute6  => l_cur_task_attr.attribute6
                       ,p_tk_attribute7  => l_cur_task_attr.attribute7
                       ,p_tk_attribute8  => l_cur_task_attr.attribute8
                       ,p_tk_attribute9  => l_cur_task_attr.attribute9
                       ,p_tk_attribute10 => l_cur_task_attr.attribute10
                       ,p_peer_or_sub    => l_peer_or_sub /* Bug 2623999 -- added this parameter*/ --bug 2846700: modified to use l_peer_or_sub
                       ,p_ref_task_id    => l_ref_task_id /* Bug 2623999 -- added this parameter*/
                       ,p_structure_type => p_structure_type
                        -- Bug#3811846 : added p_base_perc_comp_deriv_code
                       ,p_base_perc_comp_deriv_code     =>  cur_proj_elems_rec.base_percent_comp_deriv_code
                        -- Bug#3491609 : Workflow Chanegs FP M
                       ,p_wf_item_type   => cur_proj_elems_rec.wf_item_type
                       ,p_wf_process     => cur_proj_elems_rec.wf_process
                       ,p_wf_lead_days   => cur_proj_elems_rec.wf_start_lead_days
                        -- Bug#3491609 : Workflow Chanegs FP M
                       ,x_task_id         => l_task_id
                       ,x_return_status  => l_return_status
                       ,x_msg_count  => l_msg_count
                       ,x_msg_data        => l_msg_data );
           -- end xxlu changes
        /* 4201927 : THIS COPY API is not used in MOVE_TASK_VERSION context
           hence commenting
        ELSIF p_called_from_api = 'MOVE_TASK_VERSION'
        THEN
          l_task_id := cur_obj_rel_rec.proj_element_id;
        END IF;
        4201927*/

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
--end bug 2846700


        PA_TASK_PUB1.Create_Task_Version(
                  p_api_version       => p_api_version
                 ,p_init_msg_list         => p_init_msg_list
                 ,p_commit              => p_commit
                 ,p_validate_only         => p_validate_only
                 ,p_validation_level    => p_validation_level
                 ,p_calling_module        => p_calling_module
                 ,p_debug_mode        => p_debug_mode
                 ,p_max_msg_count         => p_max_msg_count
                 ,p_ref_task_version_id => l_ref_task_version_id
                 ,p_peer_or_sub       => l_peer_or_sub
                 ,p_task_id             => l_task_id
                 ,p_attribute_category  => cur_obj_rel_rec.attribute_category
                 ,p_attribute1        => cur_obj_rel_rec.attribute1
                 ,p_attribute2        => cur_obj_rel_rec.attribute2
                 ,p_attribute3        => cur_obj_rel_rec.attribute3
                 ,p_attribute4        => cur_obj_rel_rec.attribute4
                 ,p_attribute5        => cur_obj_rel_rec.attribute5
                 ,p_attribute6        => cur_obj_rel_rec.attribute6
                 ,p_attribute7        => cur_obj_rel_rec.attribute7
                 ,p_attribute8        => cur_obj_rel_rec.attribute8
                 ,p_attribute9        => cur_obj_rel_rec.attribute9
                 ,p_attribute10       => cur_obj_rel_rec.attribute10
                 ,p_attribute11       => cur_obj_rel_rec.attribute11
                 ,p_attribute12       => cur_obj_rel_rec.attribute12
                 ,p_attribute13       => cur_obj_rel_rec.attribute13
                 ,p_attribute14       => cur_obj_rel_rec.attribute14
                 ,p_attribute15       => cur_obj_rel_rec.attribute15
                 ,p_WEIGHTING_PERCENTAGE => l_weighting
                 ,p_TASK_UNPUB_VER_STATUS_CODE => l_task_unpub_ver_status_code
                 ,p_financial_task_flag        => l_fin_task_flag      --bug 3301192
                 ,x_task_version_id       => l_task_version_id
                 ,x_return_status         => l_return_status
                 ,x_msg_count               => l_msg_count
                 ,x_msg_data                => l_msg_data
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


        --------------------------------------------- FP_M changes: Begin
    -- Refer to tracking bug 3305199
        -- Populate the source and destination task version ID in
        -- PL/SQL tables

        Rec_Count := Rec_Count + 1;
        l_old_task_versions_tab.extend(1);
        l_new_task_versions_tab.extend(1);
        l_Old_Task_Versions_Tab(Rec_Count) := cur_obj_rel_rec.Task_Version_ID;
    l_New_Task_Versions_Tab(Rec_Count) := l_task_version_id;

        --bug 3301192 fin plan
        l_old_task_ver_ids.extend(1); /* Venky */
        l_new_task_ver_ids.extend(1); /* Venky */
        l_old_task_ids.extend(1); /* Venky */
        l_new_task_ids.extend(1); /* Venky */
        l_old_task_ver_ids(Rec_Count) := cur_obj_rel_rec.Task_Version_ID;
        l_old_task_ids(Rec_Count)     := cur_obj_rel_rec.proj_element_id;
        l_new_task_ver_ids(Rec_Count) := l_task_version_id;
        l_new_task_ids(Rec_Count)     := l_task_id;
        --bug 3301192 fin plan

        --------------------------------------------- FP_M changes: End

        --set the reference id.
        --l_ref_task_version_id := cur_obj_rel_rec.task_version_id;
        l_ref_task_version_id := l_task_version_id;
        l_old_wbs_level :=  cur_obj_rel_rec.wbs_level;

        --If structure type is workplan.
        OPEN cur_struc_type( l_structure_id );
        FETCH cur_struc_type INTO l_dummy_char;
        IF cur_struc_type%FOUND
        THEN

           --dbms_output.put_line( 'Before PA_TASK_PUB1.Create_Scheduele_version' );

          /*4201927 : This Copy API not called in Move Task Version Context.
            Hence Commenting
          IF p_called_from_api <> 'MOVE_TASK_VERSION'
          THEN
          */
--Hsiu added for date rollup; workplan only
--bug 3991067
            l_task_cnt := l_task_cnt + 1;
            l_tasks_ver_ids(l_task_cnt) := l_task_version_id;
--            l_tasks_ver_ids.extend;
--            l_tasks_ver_ids(l_tasks_ver_ids.count) := l_task_version_id;
--end bug 3991067
--hsiu added for task status rollup
            l_rollup_task_id := l_task_version_id;
--note: as long as one of the id of the new task is selected, the rollup will work.
            -- xxlu
            --bug 3074706
            --added src_project_id
--            OPEN cur_proj_elem_ver_sch(p_src_structure_version_id, l_src_project_id);  --Bug No 3609001
--            OPEN cur_proj_elem_ver_sch(p_src_task_version_id, l_src_project_id);         --Bug No 3609001
            OPEN cur_proj_elem_ver_sch(cur_obj_rel_rec.task_version_id, l_src_project_id);         --Bug No 3675385
            FETCH cur_proj_elem_ver_sch INTO v_cur_sch;
            CLOSE cur_proj_elem_ver_sch;

            PA_TASK_PVT1.Create_Schedule_Version(
                      p_api_version               => p_api_version
                     ,p_init_msg_list           => p_init_msg_list
                     ,p_commit                => p_commit
                     ,p_validate_only           => p_validate_only
                     ,p_validation_level            => p_validation_level
                     ,p_calling_module          => p_calling_module
                     ,p_debug_mode                => p_debug_mode
                     ,p_max_msg_count           => p_max_msg_count
                     ,p_element_version_id    => l_task_version_id
                     ,p_scheduled_start_date  => v_cur_sch.SCHEDULED_START_DATE
                     ,p_scheduled_end_date    => v_cur_sch.scheduled_finish_date
                     ,p_attribute_category            => v_cur_sch.attribute_category
                     ,p_attribute1                    => v_cur_sch.attribute1
                     ,p_attribute2                    => v_cur_sch.attribute2
                     ,p_attribute3                    => v_cur_sch.attribute3
                     ,p_attribute4                    => v_cur_sch.attribute4
                     ,p_attribute5                    => v_cur_sch.attribute5
                     ,p_attribute6                    => v_cur_sch.attribute6
                     ,p_attribute7                    => v_cur_sch.attribute7
                     ,p_attribute8                    => v_cur_sch.attribute8
                     ,p_attribute9                    => v_cur_sch.attribute9
                     ,p_attribute10                   => v_cur_sch.attribute10
                     ,p_attribute11                   => v_cur_sch.attribute11
                     ,p_attribute12                   => v_cur_sch.attribute12
                     ,p_attribute13                   => v_cur_sch.attribute13
                     ,p_attribute14                   => v_cur_sch.attribute14
                     ,p_attribute15                   => v_cur_sch.attribute15
                     ,p_def_sch_tool_tsk_type_code        => v_cur_sch.DEF_SCH_TOOL_TSK_TYPE_CODE
                     ,p_constraint_type_code              => v_cur_sch.CONSTRAINT_TYPE_CODE
                     ,p_constraint_date                   => v_cur_sch.CONSTRAINT_DATE
                     ,p_free_slack                        => v_cur_sch.FREE_SLACK
                     ,p_total_slack                       => v_cur_sch.TOTAL_SLACK
                     ,p_effort_driven_flag                => v_cur_sch.EFFORT_DRIVEN_FLAG
                     ,p_level_assignments_flag            => v_cur_sch.LEVEL_ASSIGNMENTS_FLAG
                     ,p_ext_act_duration                  => v_cur_sch.EXT_ACT_DURATION
                     ,p_ext_remain_duration               => v_cur_sch.EXT_REMAIN_DURATION
                     ,p_ext_sch_duration                  => v_cur_sch.EXT_SCH_DURATION
                     ,x_pev_schedule_id         => l_pev_schedule_id
                     ,x_return_status           => l_return_status
                     ,x_msg_count                 => l_msg_count
                     ,x_msg_data                  => l_msg_data
                 );
              -- end xxlu changes
          /*END IF; 4201927 : This Copy API not called in Move Task Version Context. */

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
        CLOSE cur_struc_type;

    END LOOP;


    -- Added for FP_M changes 3305199 : Bhumesh

    If P_cp_Dependency_Flag = 'Y' then
      PA_Relationship_Pvt.Copy_Intra_Dependency (
    P_Source_Ver_Tbl  => l_Old_Task_Versions_Tab,
    P_Destin_Ver_Tbl  => l_New_Task_Versions_Tab,
    X_Return_Status   => X_Return_Status,
    X_Msg_Count       => X_Msg_Count,
    X_Msg_Data        => X_Msg_Data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      PA_RELATIONSHIP_PVT.Copy_Inter_Project_Dependency (
    P_Source_Ver_Tbl     => l_Old_Task_Versions_Tab,
    P_Destin_Ver_Tbl     => l_New_Task_Versions_Tab,
    X_Return_Status      => X_Return_Status,
    X_Msg_Count          => X_Msg_Count,
    X_Msg_Data           => X_Msg_Data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    End If;
    -- End of FP_M changes

    /* Bug2741989 -- Following message is populated in stack */
    IF (NOT l_src_tasks_found  AND p_copy_option = 'PA_ENTIRE_VERSION')THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_CANT_COPY_EMPTY_STRUCT_VER' );
           x_msg_data := 'PA_CANT_COPY_EMPTY_STRUCT_VER';
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
    END IF;

/* Bug 2623999 coomnted out the code below. It is redundant and causing issues */
/*
  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  p_dest_structure_version_id
     AND object_type = 'PA_STRUCTURES';

  --Do financial task check
  --If financial
  OPEN cur_struc_type2( l_structure_id );
  FETCH cur_struc_type2 INTO l_dummy_char;
  IF cur_struc_type2%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;

--hsiu
--changes for versioning
      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);

      IF (NVL( l_published_version, 'N' ) = 'N') OR (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y') THEN
--      IF NVL( l_published_version, 'N' ) = 'N'
--      THEN
--end changes

          --get the reference task and project ids
          SELECT proj_element_id, project_id
            INTO l_ref_task_id, l_ref_project_id
            FROM pa_proj_element_versions
           WHERE element_version_id = p_dest_task_version_id;

          --get the task and project ids
          SELECT proj_element_id, project_id
            INTO l_task_id, l_project_id
            FROM pa_proj_element_versions
           WHERE element_version_id = p_src_task_version_id;

          IF p_copy_option = 'PA_TASK_ONLY'
          THEN
             l_copy_node_flag := 'S';  ---copy selected task only
          ELSIF p_copy_option = 'PA_TASK_SUBTASK'
          THEN
             l_copy_node_flag := 'T';  ---copy selected task and sub tasks
          ELSIF p_copy_option = 'PA_ENTIRE_VERSION'
          THEN
             l_copy_node_flag := 'P';  ---copy entire project
          END IF;

          PA_TASKS_MAINT_PUB.Copy_Task(
                         p_reference_project_id              => l_ref_project_id
                        ,p_reference_task_id                 => l_ref_task_id
                        ,p_project_id                        => l_project_id
                        ,p_task_id                           => l_task_id
                        ,p_project_name => NULL
                        ,p_task_name => NULL
                        ,p_peer_or_sub                       => p_peer_or_sub
                        ,p_copy_node_flag                    => l_copy_node_flag
                        ,p_task_prefix                       => p_prefix
                        ,p_wbs_record_version_number         => 1
                        ,x_return_status                     => l_return_status
                        ,x_msg_count                         => l_msg_count
                        ,x_msg_data                          => l_msg_data );

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
  END IF;
  CLOSE cur_struc_type2;
*/

  /* 4201927: This value is already derived as the variable l_wp_type */
  /*IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_dest_structure_version_id, 'WORKPLAN') = 'Y' then
   */
    IF l_wp_type = 'Y' then
    PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
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
       raise FND_API.G_EXC_ERROR;
     end if;

--hsiu added for task status
--if versioning is off, rollup.

      /* 4201927 : Replaced Call to Version ENabled with l_ver_enabled */
     /*IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_dest_project_id)) AND*/
       IF ('N' = l_ver_enabled) AND
        (l_rollup_task_id IS NOT NULL) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_dest_structure_version_id
                 ,p_element_version_id => l_rollup_task_id
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
         raise FND_API.G_EXC_ERROR;
       end if;

     END IF;

--end task status changes

  END IF;


--bug 3301192  fin plan changes
declare
/* Bug #: 3305199 SMukka                                                         */
/* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
/* l_task_ver_ids2              PA_PLSQL_DATATYPES.IdTabTyp;                     */
l_task_ver_ids2              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
/* 4201927 : This value is already derived l_wp_type                    VARCHAR2(1); */
/* 4201927 : This value is already derived l_copy_external_flag         VARCHAR2(1); */
begin

  /* 4201927 : This value is already derived
  l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_dest_structure_version_id, 'WORKPLAN');
   4201927 */
    --3305199: deliverable changes
    IF (p_cp_deliverable_asso_flag = 'Y' AND l_wp_type = 'Y') THEN
      PA_DELIVERABLE_PUB.COPY_ASSOCIATIONS
      (p_validate_only           => FND_API.G_FALSE
      ,p_src_task_versions_tab   => l_Old_Task_Versions_Tab
      ,p_dest_task_versions_tab  => l_New_Task_Versions_Tab
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data);

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
    END IF;
    --3305199: end deliverable changes

  /*=====================P1 BUG 4210796 ===================
   * COPY PLANNING TXNS MOVED BEFORE DELETE PLANNING TXNS CALL
   * =======================================================*/

   -- START OF BLOCK MOVED
   IF l_wp_type = 'Y' AND l_src_wp_type='Y'  -- 4223490 : Included  l_src_wp_type='Y' because both source and destination shud be WP
  THEN

    /* 4201927 : l_copy_external_flag is already derived as in <<C>>
    IF p_src_project_id = l_dest_project_id
    THEN
        l_copy_external_flag := 'N';
    ELSE
        l_copy_external_flag := 'Y';
    ENd IF;
    */

    /*Smukka Bug No. 3474141 Date 03/01/2004                                                  */
    /*moved pa_fp_planning_transaction_pub.copy_planning_transactions into plsql block        */
    BEGIN
        pa_fp_planning_transaction_pub.copy_planning_transactions(
          p_context                    => 'WORKPLAN'
         ,p_copy_external_flag         =>  l_copy_external_flag
         ,p_src_project_id             =>  p_src_project_id
         ,p_target_project_id          =>  l_dest_project_id
       --,p_src_element_id_tbl         =>  l_old_task_ids
         ,p_src_version_id_tbl        =>   l_old_task_ver_ids
       --,p_targ_element_id_tbl      =>    l_new_task_ids
         ,p_targ_version_id_tbl     =>     l_new_task_ver_ids
         ,p_copy_people_flag            => p_cp_people_flag
         ,p_copy_equip_flag             => p_cp_equipment_flag
         ,p_copy_mat_item_flag          => p_cp_material_items_flag
         ,p_copy_fin_elem_flag          => p_cp_financial_elem_flag
 --      ,p_maintain_reporting_lines    => 'Y'
         ,x_return_status               => l_return_status
         ,x_msg_count                   => l_msg_count
         ,x_msg_data                    => l_msg_data
        );
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                     p_procedure_name => 'COPY_TASK',
                                     p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.copy_planning_transactions:'||SQLERRM,1,240));
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
 END IF;

   -- END OF BLOCK MOVED FOR P1 BUG 4210796

  IF l_wp_type = 'Y' AND p_dest_structure_version_id <> p_dest_task_version_id
  THEN
       l_lowest_task_flag2 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_dest_task_version_id );

       IF l_lowest_task_flag1 = 'Y' AND
          l_lowest_task_flag2 = 'N'  /* reference task is no more a lowest task therefore call delete planning api */
       THEN
           l_task_ver_ids2.extend(1); /* Venky */
           l_task_ver_ids2(1) := p_dest_task_version_id;
           /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
           /*moved pa_fp_planning_transaction_pub.delete_planning_transactions into plsql block        */
           DECLARE
             --p1 bug 3888432
             l_assign_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
             CURSOR get_assignment_id(c_task_ver_id NUMBER) IS
               SELECT resource_assignment_id
                 FROM pa_resource_assignments
                WHERE wbs_element_Version_id = c_task_ver_id
                  AND ta_display_flag = 'N';
             l_assign_id    NUMBER := NULL;
           BEGIN
             OPEN get_assignment_id(p_dest_task_version_id);
             FETCH get_assignment_id into l_assign_id;
             CLOSE get_assignment_id;

             IF (l_assign_id IS NOT NULL) THEN
               l_assign_ids.extend(1);
               l_assign_ids(1) := l_assign_id;
               pa_fp_planning_transaction_pub.delete_planning_transactions
               (
                 p_context                      => 'WORKPLAN'
                ,p_task_or_res                  => 'ASSIGNMENT'
--                ,p_element_version_id_tbl       => l_task_ver_ids2
--              ,p_maintain_reporting_lines     => 'Y'
                ,p_resource_assignment_tbl => l_assign_ids
                ,x_return_status                => l_return_status
                ,x_msg_count                    => l_msg_count
                ,x_msg_data                     => l_msg_data
               );
             END IF;
           EXCEPTION
               WHEN OTHERS THEN
                    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                            p_procedure_name => 'COPY_TASK',
                                            p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.delete_planning_transactions:'||SQLERRM,1,240));
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
       END IF;
  END IF;

/*==========================================================================================
  MOVED THIS BLOCK OF CODE FOR COPYING PLANNING TRANSACTIONS before DELETING PLANNING TXNS .
  THIS FIX IS NEEDED FOR P1 BUG 4210796 . REFER *** MAANSARI  02/28/05 12:59 pm ***
  FOR THE SOLUTION STRATEGY

  IF l_wp_type = 'Y'
  THEN

    /* 4201927 : l_copy_external_flag is already derived as in <<C>>
    IF p_src_project_id = l_dest_project_id
    THEN
        l_copy_external_flag := 'N';
    ELSE
        l_copy_external_flag := 'Y';
    ENd IF;
    */

    /*Smukka Bug No. 3474141 Date 03/01/2004                                                  */
    /*moved pa_fp_planning_transaction_pub.copy_planning_transactions into plsql block        */
    /* P1 4210796
    BEGIN
        pa_fp_planning_transaction_pub.copy_planning_transactions(
          p_context                    => 'WORKPLAN'
         ,p_copy_external_flag         =>  l_copy_external_flag
         ,p_src_project_id             =>  p_src_project_id
         ,p_target_project_id          =>  l_dest_project_id
       --,p_src_element_id_tbl         =>  l_old_task_ids
         ,p_src_version_id_tbl        =>   l_old_task_ver_ids
       --,p_targ_element_id_tbl      =>    l_new_task_ids
         ,p_targ_version_id_tbl     =>     l_new_task_ver_ids
         ,p_copy_people_flag            => p_cp_people_flag
         ,p_copy_equip_flag             => p_cp_equipment_flag
         ,p_copy_mat_item_flag          => p_cp_material_items_flag
         ,p_copy_fin_elem_flag          => p_cp_financial_elem_flag
 --      ,p_maintain_reporting_lines    => 'Y'
         ,x_return_status               => l_return_status
         ,x_msg_count                   => l_msg_count
         ,x_msg_data                    => l_msg_data
        );
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                     p_procedure_name => 'COPY_TASK',
                                     p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.copy_planning_transactions:'||SQLERRM,1,240));
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
 END IF;

 END OF BLOCK MOVED FOR  P1 BUG 4210796
 ======================================================================*/
end;
--bug 3301192  fin plan changes

    --3035902: process update flag changes
    --set process flag
    --Bug No 3450684 SMukka Commented if condition
    --IF (l_wp_process_flag = 'Y') THEN
      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
      (
        p_calling_context       => 'SELF_SERVICE'
       ,p_project_id            => l_dest_project_id
       ,p_structure_version_id  => p_dest_structure_version_id
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
    --END IF;
    --3035902: process update flag changes

    --bug 4149392
    PA_TASK_PUB1.G_CALL_PJI_ROLLUP := NULL;
    --end bug 4149392

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.COPY_TASK END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Task;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'COPY_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Task;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'COPY_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Copy_Task;

-- API name                      : Move_Task
-- Type                          : Public procedure
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
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- p_ref_task_version_id    IN  NUMBER  N   Not Null
-- p_ref_project_id         IN  NUMBER  N Null
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- prefix   IN  VARCHAR2    N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE MOVE_TASK_VERSION (
 p_api_version           IN NUMBER   := 1.0,
 p_init_msg_list             IN VARCHAR2 := FND_API.G_TRUE,
 p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
 p_validate_only             IN VARCHAR2 := FND_API.G_TRUE,
 p_validation_level    IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module            IN VARCHAR2 := 'SELF_SERVICE',
 p_debug_mode            IN VARCHAR2 := 'N',
 p_max_msg_count             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id    IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id     IN   NUMBER,
 p_ref_task_version_id     IN   NUMBER,
/*4269830 : Performance Enhancements :  Start*/
 p_ref_project_id          IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_id            IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_published_version       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_shared                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_sharing_code            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_versioned		   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wp_type		   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_fin_type		   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_weighting_basis_code    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_check_third_party_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
/*4269830 : Performance Enhancements : End */
 p_peer_or_sub           IN VARCHAR2,
 p_record_version_number   IN NUMBER,
 p_called_from_bulk_api   IN VARCHAR2 := 'N' ,
 x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
  l_api_name                 CONSTANT VARCHAR(30) := 'MOVE_TASK_VERSION';
  l_api_version              CONSTANT NUMBER      := 1.0;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_ref_display_sequence     NUMBER;
  l_display_sequence         NUMBER;
  l_ref_parent_struct_ver_id NUMBER;
  l_parent_struct_ver_id     NUMBER;

  l_parent_id                NUMBER;
  l_parent_task_id           NUMBER;
  l_parent_object_type       PA_PROJ_ELEMENT_VERSIONS.object_type%TYPE;

  l_project_id                  NUMBER;
  l_ref_task_id                 NUMBER;
  l_task_id                     NUMBER;
  l_task_record_version_number  NUMBER;
  l_wbs_record_version_number   NUMBER;

  l_record_version_number       NUMBER;
  l_published_version  VARCHAR2(1);
  l_dummy_char        VARCHAR2(1);
  l_structure_id      NUMBER;
  l_structure_ver_id  NUMBER;
  --l_project_id        NUMBER;
  --l_ref_task_id       NUMBER;
  --l_task_id           NUMBER;

--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';

--end changes

--hyau
--added for lifecycle version
    l_proj_element_id  NUMBER;
-- end changes

    CURSOR cur_struc_type( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';

--hsiu added, for dates rollup
   CURSOR get_peer_tasks
   IS
     select b.object_id_to1 object_id_to1
       from pa_object_relationships a,
            pa_object_relationships b
      where a.object_id_to1 = p_task_version_id
        and a.object_type_to = 'PA_TASKS'
        and a.relationship_type = 'S' -- Bug # 4622939.
        and a.object_id_from1 = b.object_id_from1
        and a.object_type_from = b.object_type_from
        and b.object_type_to = 'PA_TASKS'
        and b.relationship_type = 'S' -- Bug # 4622939.
        and b.object_id_to1 <> p_task_version_id;
   c_get_peer_tasks get_peer_tasks%ROWTYPE;

--Hsiu added, for dates rollup
  /* Bug 5768425 Start*/
  --l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
  l_tasks_ver_ids        PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
  l_task_cnt NUMBER 			:= 0;
  /* Bug 5768425 End */

--hsiu added for task status rollup
  l_old_peer_task_id  NUMBER;

--hsiu added for task status
  CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_elem_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_ver_id NUMBER;
  l_error_msg_code VARCHAR2(30);

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_cur_project_id      NUMBER;
   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_structure_version_id;

-- Merged from 85
-- end hyau Bug 2852753

 l_old_top_task_id    NUMBER;   --bug 2967204

--Bug 2947492 ( move )

l_plannable_tasks_tbl        PA_FP_ELEMENTS_PUB.l_impacted_task_in_tbl_typ;
--l_parent_task_id             NUMBER;
l_old_parent_task_id             NUMBER;
l_top_task_id                NUMBER;

CURSOR get_parent_task_id( c_task_id NUMBER, c_project_id NUMBER ) IS
    SELECT parent_task_id, top_task_id FROM pa_tasks
     WHERE project_id = c_project_id and task_id = c_task_id;

--End Bug 2947492  ( move )
-- Merged from 85

--bug 3053281
  l_wp_type              VARCHAR2(1);
  l_weighting_basis_Code VARCHAR2(30);
  l_wp_process_flag      VARCHAR2(1);
--end bug 3053281
--3035902: process update flag changes
  cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
  l_task_type_id      NUMBER;
--3035902: end process update flag changes

--bug 3911698
--cursor to get all child
  cursor get_child_ver_id(c_task_ver_id NUMBER) IS
    select object_id_to1
      from pa_object_relationships
     where relationship_type = 'S'
       and object_type_to = 'PA_TASKS'
     start with object_id_from1 = c_task_ver_id
       and object_type_from = 'PA_TASKS'
     connect by prior object_id_to1 = object_id_from1
            and prior object_type_to = object_type_from
            and prior relationship_type = relationship_type
    UNION
    select element_version_id
      from pa_proj_element_versions
     where element_version_id = c_task_ver_id;
  l_child_ver_id NUMBER;
--end bug 3911698


--bug 3069306
  Cursor get_top_task_ver_id(c_task_ver_id NUMBER) IS
    select object_id_to1
      from pa_object_relationships
     where relationshiP_type = 'S'
       and object_type_to = 'PA_TASKS'
             start with object_id_to1 = c_task_ver_id
               and object_type_to = 'PA_TASKS'
           connect by prior object_id_from1 = object_id_to1
               and prior object_type_from = object_type_to
               and prior relationship_type = relationship_type
 intersect
    select a.object_id_to1
      from pa_object_relationships a, pa_proj_element_versions b
     where a.relationshiP_type = 'S'
       and a.object_id_from1 = b.parent_structure_version_id
       and b.element_version_id = c_task_ver_id
       and a.object_type_from = 'PA_STRUCTURES';
  l_old_par_ver_id NUMBER;
  l_new_par_ver_id NUMBER;
--end bug 3069306

--bug 3301192 fin plan changes
  l_lowest_task_flag1         VARCHAR2(1);
  l_lowest_task_flag2         VARCHAR2(1);
  l_fin_task_flag             VARCHAR2(1);
--bug 3301192
--
  l_ref_parent_task_ver_id    NUMBER;   --Bug 3475920

  /*4269830*/
  l_sharing_code VARCHAR2(30);
  l_fin_type     VARCHAR2(1);
  l_check_third_party_flag VARCHAR2(1);
  /*4269830*/

BEGIN


  pa_debug.init_err_stack ('PA_TASK_PUB1.MOVE_TASK_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.MOVE_TASK_VERSION begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint move_task_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --bug 4075697
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
  --bug 4075697

  IF p_called_from_bulk_api = 'Y'/*4269830*/
  THEN
      l_cur_project_id := p_ref_project_id;
      l_project_id := p_ref_project_id;
      l_structure_id   := p_structure_id  ;
      l_structure_ver_id := p_structure_version_id ;
      l_published_version := p_published_version;
      l_shared		  := p_shared;
      l_sharing_code	  := p_sharing_code;
      l_versioned	  := p_versioned;
      l_wp_type		  := p_wp_type;
      l_fin_type	  := p_fin_type;
      l_weighting_basis_code := p_weighting_basis_code;
      l_check_third_party_flag := p_check_third_party_flag;
  ELSE

  /* 4269830 <Existing Block> <<--A-->> */
  OPEN cur_proj_id;
  FETCH cur_proj_id INTO l_cur_project_id;
  CLOSE cur_proj_id;

  l_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_cur_project_id);
  l_fin_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL');
  l_wp_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id,'WORKPLAN');
  l_check_third_party_flag := PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(l_cur_project_id);
  l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(l_cur_project_id);
  l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(l_cur_project_id);
  l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_cur_project_id);

  END IF; /*4269830*/

  --bug 3911698
  --check if reference task is child of moving task
  OPEN get_child_ver_id(p_task_version_id);
  LOOP
    FETCH get_child_ver_id into l_child_ver_id;
    EXIT when get_child_ver_id%NOTFOUND;
    IF l_child_ver_id = p_ref_task_version_id THEN
      CLOSE get_child_ver_id;
      --add error PA_TSK_MV_BELOW_SELF
      PA_UTILS.ADD_MESSAGE('PA', 'PA_TSK_MV_BELOW_SELF');
      raise FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;
  CLOSE get_child_ver_id;
  --end bug 3911698

  -- Added for FP_M changes. Bug 3305199 : xxx
  If l_sharing_code = 'SHARE_PARTIAL' /*4269830 : Replaced function usage with l_sharing_code*/
  Then

    PA_TASKS_MAINT_UTILS.CHECK_MOVE_FINANCIAL_TASK_OK (
        p_task_version_id       => p_task_version_id
      , p_ref_task_version_id   => p_ref_task_version_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , x_error_msg_code        => l_error_msg_code);
    --Bug No 3491045
    --Replaced the return status value to 'S' from 'Y'
    IF (x_return_status <> 'S') THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    End If;
  End If;
  -- End of FP_M changes

  --3035902: process update flag changes
  l_wp_process_flag := 'N';
  --3035902: end process update flag changes
-- hyau Bug 2852753

    IF  p_called_from_bulk_api = 'N' THEN
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN get_product_code(l_cur_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );

          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;
      IF l_update_parent_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_MOVE_TASK');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;
  END IF ; -- Called From Bulk API is 'N'
-- end hyau Bug 2852753


  -- hyau
  -- Lifecycle Phase validation Changes. Check if task has phase associated with it
  IF (p_task_version_id IS NOT NULL) AND
       (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

  SELECT proj_element_id
  INTO l_proj_element_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;

    IF ('Y' = pa_proj_elements_utils.CHECK_ELEMENT_HAS_PHASE(
              l_proj_element_id)) THEN
      --Indenting a task with phase. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_LC_NO_MOVE_PHASE_TASK');
    END IF;

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
  END IF;
  -- end hyau. Lifecycle Phase validation Changes.

  -- get the display sequence of the reference task
  SELECT display_sequence, parent_structure_version_id
  INTO   l_ref_display_sequence, l_ref_parent_struct_ver_id
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  element_version_id = p_ref_task_version_id;

  -- get the display sequence of the task being moved
  SELECT display_sequence, parent_structure_version_id
  INTO   l_display_sequence, l_parent_struct_ver_id
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  element_version_id = p_task_version_id;

  -- get the parent of the task being moved
  SELECT object_id_from1, object_type_from
  INTO   l_parent_id, l_parent_object_type
  FROM   PA_OBJECT_RELATIONSHIPS
  WHERE  object_type_to = 'PA_TASKS'
  AND    object_id_to1 = p_task_version_id
  AND    relationship_type = 'S'
  AND    object_type_from in ('PA_STRUCTURES', 'PA_TASKS');

--hsiu added, for dates rollup
--need to get peer task before it has been moved.
  OPEN get_peer_tasks;
  LOOP
    FETCH get_peer_tasks INTO c_get_peer_tasks;
    EXIT WHEN get_peer_tasks%NOTFOUND;
    /* Bug 5768425 Start */
    --l_tasks_ver_ids.extend;
    --l_tasks_ver_ids(l_tasks_ver_ids.count) := c_get_peer_tasks.object_id_to1;
    l_task_cnt := l_task_cnt + 1;
    l_tasks_ver_ids(l_task_cnt) := c_get_peer_tasks.object_id_to1;
    /* Bug 5768425 End */
    l_old_peer_task_id := c_get_peer_tasks.object_id_to1;
  END LOOP;
  CLOSE get_peer_tasks;

  if l_parent_object_type = 'PA_STRUCTURES' then
    l_parent_task_id := NULL;
  else
    l_parent_task_id := l_parent_id;
  end if;

  --hsiu added for task status
    --check if ok to move this task
    PA_PROJ_ELEMENTS_UTILS.check_move_task_ok(
      p_task_ver_id => p_task_version_id
     ,x_return_status => l_return_status
     ,x_error_message_code => l_error_msg_code
    );
    IF (l_return_status <> 'Y') THEN
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    END IF;

    --check if ok to create subtask
    IF (p_peer_or_sub = 'PEER') THEN
      OPEN get_parent_version_id(p_ref_task_version_id);
      FETCH get_parent_version_id into l_parent_ver_id;
      CLOSE get_parent_version_id;

      --bug 3069306
      --if financial task, check if changing parent ok
      IF (l_fin_type = 'Y') THEN /*4269830 : replaced Function usage with l_fin_type*/
        OPEN get_top_task_ver_id(l_parent_ver_id);
        FETCH get_top_task_ver_id into l_new_par_ver_id;
        CLOSE get_top_task_ver_id;

        OPEN get_top_task_ver_id(p_task_version_id);
        FETCH get_top_task_ver_id into l_old_par_ver_id;
        CLOSE get_top_task_Ver_id;

        IF (NVL(l_new_par_ver_id, -99) <> NVL (l_old_par_ver_id, -99)) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_CANT_CHANGE_PARENT');
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --end bug 3069306

      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;

      --bug 4099488
      IF PA_RELATIONSHIP_UTILS.check_dependencies_valid(l_parent_ver_id, p_task_version_id) = 'N' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_INV_MOV_TSK_DEP_ERR');
        raise FND_API.G_EXC_ERROR;
      END IF;
      --end bug 4099488
    ELSE
      --bug 3069306
      --if financial task, check if changing parent ok
      IF (l_fin_type = 'Y') THEN /*	4269830: Replaced Function call with l_fin_type*/
        OPEN get_top_task_ver_id(p_ref_task_version_id);
        FETCH get_top_task_ver_id into l_new_par_ver_id;
        CLOSE get_top_task_ver_id;

        OPEN get_top_task_ver_id(p_task_version_id);
        FETCH get_top_task_ver_id into l_old_par_ver_id;
        CLOSE get_top_task_Ver_id;

        IF (NVL(l_new_par_ver_id, -99) <> NVL (l_old_par_ver_id, -99)) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_CANT_CHANGE_PARENT');
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --end bug 3069306

      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => p_ref_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;

      --bug 4099488
      IF PA_RELATIONSHIP_UTILS.check_dependencies_valid(p_ref_task_version_id, p_task_version_id) = 'N' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_INV_MOV_TSK_DEP_ERR');
        raise FND_API.G_EXC_ERROR;
      END IF;
      --end bug 4099488
    END IF;

  --end task status changes

  --bug 3301192 fin plan changes.
  --check whether the reference task was lowest task before
  --check the task is a lowest task bug 3301192

  IF l_ref_parent_struct_ver_id <> p_ref_task_version_id
  THEN
     l_lowest_task_flag1 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_ref_task_version_id );
  END IF;
--
  --Bug No 3475920
  IF p_peer_or_sub = 'PEER' THEN
     l_ref_parent_task_ver_id:=PA_PROJ_ELEMENTS_UTILS.GET_PARENT_TASK_VERSION_ID(p_ref_task_version_id);
  ELSE
     l_ref_parent_task_ver_id:=p_ref_task_version_id;
  END IF;
--
  IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id,l_ref_parent_task_ver_id) = 'Y' THEN
     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                          p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
     RAISE FND_API.G_EXC_ERROR;
  END IF;
--
  PA_TASK_PUB1.Update_Task_Version
  ( p_validate_only      => FND_API.G_FALSE,
    p_ref_task_version_id    => p_ref_task_version_id,
    p_peer_or_sub              => p_peer_or_sub,
    p_task_version_id        => p_task_version_id,
    p_record_version_number  => p_record_version_number,
    p_action                 => 'MOVE',
    x_return_status      => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data             => l_msg_data );

    x_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'Count '|| x_msg_count );

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


/*  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  p_structure_version_id
     AND object_type = 'PA_STRUCTURES';*/

  IF p_called_from_bulk_api = 'N' -- 4269830
  THEN

  SELECT proj_element_id, project_id, element_version_id INTO l_structure_id, l_project_id, l_structure_ver_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = p_task_version_id )
     AND object_type = 'PA_STRUCTURES';
  END IF;  -- 4269830

IF p_calling_module NOT in ( 'FORMS', 'AMG' )
THEN

  IF p_called_from_bulk_api ='N'  -- 4269830 : Already derived in BULK API
  then

  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;

  END IF; --4269830
  CLOSE cur_struc_type;--4269830

  END IF;--4269830

--hsiu
--changes for versioning
/*      4269830 :
        This code has been moved to block tagged by <<--A-->>

      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);
*/

      IF l_fin_type = 'Y'  -- 4269830 this is equivalent to  cur_struc_type%FOUND
      THEN

      l_fin_task_flag := PA_Proj_Elements_Utils.CHECK_IS_FINANCIAL_TASK(l_proj_element_id); --bug 3301192 move in pa_tasks also if it exists there.

      IF (NVL( l_published_version, 'N' ) = 'N' AND l_fin_task_flag = 'Y') OR
         (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y' AND l_fin_task_flag = 'Y' )
	OR ((l_published_version = 'Y') AND (l_shared = 'N') AND (l_fin_task_flag = 'Y')) -- Bug # 5064340. -- To accomodate split financial tasks.
	THEN
--      IF NVL( l_published_version, 'N' ) = 'N'
--      THEN
--end changes

            --hsiu  Fixed parent_structure_version_id condition
          SELECT ppev.proj_element_id, pt.record_version_number, ppa.wbs_record_version_number, ppev.project_id
            INTO l_task_id, l_task_record_version_number, l_wbs_record_version_number, l_project_id
            FROM PA_TASKS pt,
                 pa_proj_elem_ver_structure ppa,
                 PA_PROJ_ELEMENT_VERSIONS ppev
           WHERE ppev.element_version_id = p_task_version_id
             AND ppev.project_id = ppa.project_id
             AND ppev.parent_structure_version_id = ppa.element_version_id
             AND ppev.proj_element_id = pt.task_id;

          SELECT proj_element_id
            INTO l_ref_task_id
            FROM PA_PROJ_ELEMENT_VERSIONS
           WHERE element_version_id = p_ref_task_version_id;
-- merged from 85
           SELECT record_version_number, parent_task_id    --get old parent id for bug 2947492 (move )
                 ,top_task_id       --bug 2967204
            INTO l_record_version_number, l_old_parent_task_id
                 ,l_old_top_task_id --bug 2967204
            FROM pa_tasks
           WHERE task_id = l_task_id
             AND project_id = l_project_id;
-- merged from 85

    x_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'before move task old '|| x_msg_count );

          PA_TASKS_MAINT_PUB.Move_Task(
                   p_reference_project_id              => l_project_id
                  ,p_reference_task_id                 => l_ref_task_id
                  ,p_project_id                        => l_project_id
                  ,p_task_id                           => l_task_id
                  ,p_peer_or_sub                       => p_peer_or_sub
                  ,p_record_version_number             => l_record_version_number
                  ,p_wbs_record_version_number         => 1      --temporarily passing 1. Lock project is commented out in PA_TASKS_MAIN_PUB.Move_Task api.
                  ,x_return_status                     => l_return_status
                  ,x_msg_count                         => l_msg_count
                  ,x_msg_data                          => l_msg_data );

    x_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'After move task old '|| x_msg_count );


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

-- merged from 85
          --Bug 2947492   ( Move )
          --

            OPEN get_parent_task_id( l_task_id , l_project_id );
            FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id;
            CLOSE get_parent_task_id;

            --bug 2967204
            --Cannot move out of the current hierarchy
              IF NVL( l_top_task_id, -99 ) <> NVL( l_old_top_task_id, -99 )
              THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name => 'PA_CANT_CHANGE_PARENT');
                  raise FND_API.G_EXC_ERROR;
              END IF;
            --End bug 2967204

/*
            --First call the check_reparent ok
            --This should have been called in the beginning but due to lot of complexity involved in getting
            --new parent task id it is decided to call this later stage as long as  we rollback the whole operation
            --if there is any error occurred. This was decided in meeting with me , Hubert and Sakthi.

            PA_FIN_PLAN_UTILS.CHECK_REPARENT_TASK_OK(
                     p_task_id                    => l_task_id
                    ,p_old_parent_task_id         => l_old_parent_task_id
                    ,p_new_parent_task_id         => l_parent_task_id
                    ,x_return_status              => l_return_status
                    ,x_msg_count                  => l_msg_count
                    ,x_msg_data                   => l_msg_data
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
*/   --commenting out, please refer mails from venkatesh dates 22 jan 04

/* Commenting out the call to MAINTAIN_PLANNABLE_TASKS for bug 3010538
            l_plannable_tasks_tbl(1).impacted_task_id   := l_task_id;
            l_plannable_tasks_tbl(1).action             := 'REPARENT';
            l_plannable_tasks_tbl(1).old_parent_task_id := l_old_parent_task_id;
            l_plannable_tasks_tbl(1).New_parent_task_id := l_parent_task_id;
            l_plannable_tasks_tbl(1).top_task_id        := l_top_task_id;

            PA_FP_ELEMENTS_PUB.MAINTAIN_PLANNABLE_TASKS(
                    p_project_id         => l_project_id
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
bug 3010538 */

          --End Bug 2947492  ( Move )
      END IF;

   -- END IF; 4269830
   -- CLOSE cur_struc_type; 4269830

   END IF; -- 4269830 IF l_fin_type ='Y'
-- merged from 85
END IF; --<<p_calling_module >>

--bug 3010538 (move )
--bug 3053281 --set flag if not (manual and workplan only)

/*	4269830 :
        This code has been moved to block tagged by <<--A-->>
l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_parent_struct_ver_id, 'WORKPLAN');
l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(l_project_id);
*/
  --3035902: process update flag changes
  OPEN get_task_type_id(l_proj_element_id);
  FETCH get_task_type_id INTO l_task_type_id;
  CLOSE get_task_type_id;

  --set update process flag if necessary;
  IF (l_wp_process_flag = 'N') THEN
    --may need to update process flag
    IF ((l_shared = 'N') AND
        (l_wp_type = 'Y') AND
        (pa_task_type_utils.check_tk_type_progressable(l_task_type_id)='Y') AND
        (l_weighting_basis_code <> 'MANUAL'))
    THEN
      --split and workplan; only update if progressable task added
      l_wp_process_flag := 'Y';
    ELSIF ((l_shared = 'N') AND
           (l_wp_type = 'N')) THEN
      --split and financial; update
      l_wp_process_flag := 'Y';
    ELSIF (l_shared = 'Y') THEN
      l_wp_process_flag := 'Y';
    END IF;
  END IF;
  --3035902: end process update flag changes
/* commented for process update flag changes
IF (l_shared = 'N') AND
   (l_wp_type = 'Y') AND
   (l_weighting_basis_Code = 'MANUAL') THEN
  --do not set the flag to 'Y'
  NULL;
ELSE
*/
  --3035902: process update flag changes
  --Bug No 3450684 SMukka Commented if condition
--  IF (l_wp_process_flag = 'Y') THEN
  --set the flag
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => l_project_id
     ,p_structure_version_id  => l_parent_struct_ver_id
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
  --3035902: end process update flag changes
--END IF;


   IF l_fin_type = 'Y' /*     4269830: Replaced Function call with l_fin_type*/
   THEN
       IF ( l_versioned = 'N' ) OR ( l_versioned = 'Y' and l_shared = 'Y' and  l_published_version = 'N' ) THEN
   --Move
       pa_fp_refresh_elements_pub.set_process_flag_proj(
             p_project_id               => l_project_id
            ,p_request_id               => null
            ,p_process_code             => null
            ,p_refresh_required_flag    => 'Y'
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data );

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
      END IF;
   END IF;


--End bug 3010538 (move)


--Hsiu added for date rollup; workplan only
--dbms_output.put_line('check structure version type '||l_structure_ver_id);
  IF l_wp_type = 'Y' then /*4269830 Function call replaced by l_wp_type*/

    -- Added for FP_M changes Bug 3305199 : Bhumesh
    If l_check_third_party_flag  = 'Y' Then /*4269830 Function call replaced by l_check_third_party_flag*/

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

     /* Bug 5768425 Start */
    --l_tasks_ver_ids.extend;
    --l_tasks_ver_ids(l_tasks_ver_ids.count) := p_task_version_id;
    l_task_cnt := l_task_cnt + 1;
    l_tasks_ver_ids(l_task_cnt) := p_task_version_id;

    --PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
    PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP_UNLIMITED(
                       p_commit => FND_API.G_FALSE,
                       p_element_versions => l_tasks_ver_ids,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

    /* Bug 5768425 End */

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

--hsiu added for task status
--if versioning is off, rollup.
     IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => l_structure_ver_id
                 ,p_element_version_id => p_task_version_id
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
         raise FND_API.G_EXC_ERROR;
       end if;

       IF (l_old_peer_task_id IS NOT NULL) THEN
         PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => l_structure_ver_id
                 ,p_element_version_id => l_old_peer_task_id
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
           raise FND_API.G_EXC_ERROR;
         end if;
       END IF;

     END IF;

--end task status changes

  END IF;

--bug 3301192  fin plan changes
declare
/* Bug #: 3305199 SMukka                                                         */
/* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
/* l_task_ver_ids2              PA_PLSQL_DATATYPES.IdTabTyp;                     */
l_task_ver_ids2              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
/*l_wp_type                    VARCHAR2(1); Commented for 4269830 - This value is already derived*/
begin
  /*4269830 Commented for 4269830 - This value is already derived
  l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_structure_ver_id, 'WORKPLAN');
   */
  IF l_wp_type = 'Y'
     AND l_ref_parent_struct_ver_id <> p_ref_task_version_id /* make sure that the reference is not a str ver */
  THEN
      l_lowest_task_flag2 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_ref_task_version_id );
      IF l_lowest_task_flag1 = 'Y' AND
         l_lowest_task_flag2 = 'N'
      THEN
           l_task_ver_ids2.extend(1); /* Venky */
           l_task_ver_ids2(1) := p_ref_task_version_id;
           /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
           /*moved pa_fp_planning_transaction_pub.delete_planning_transactions into plsql block        */
           DECLARE
             --p1 bug 3888432
             l_assign_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
             CURSOR get_assignment_id(c_task_ver_id NUMBER) IS
               SELECT resource_assignment_id
                 FROM pa_resource_assignments
                WHERE wbs_element_Version_id = c_task_ver_id
                  AND ta_display_flag = 'N';
             l_assign_id    NUMBER := NULL;
           BEGIN
             OPEN get_assignment_id(p_ref_task_version_id);
             FETCH get_assignment_id into l_assign_id;
             CLOSE get_assignment_id;

             IF (l_assign_id IS NOT NULL) THEN
               l_assign_ids.extend(1);
               l_assign_ids(1) := l_assign_id;
               pa_fp_planning_transaction_pub.delete_planning_transactions
               (
                p_context                      => 'WORKPLAN'
               ,p_task_or_res                  => 'ASSIGNMENT'
--               ,p_element_version_id_tbl       => l_task_ver_ids2
--              ,p_maintain_reporting_lines     => 'Y'
               ,p_resource_assignment_tbl => l_assign_ids
               ,x_return_status                => l_return_status
               ,x_msg_count                    => l_msg_count
               ,x_msg_data                     => l_msg_data
               );
             END IF;
           EXCEPTION
              WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                           p_procedure_name => 'MOVE_TASK_VERSION',
                                           p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.delete_planning_transactions:'||SQLERRM,1,240));
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
      END IF;
  END IF;
end;

  --bug 4149392
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := NULL;
  --end bug 4149392

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.MOVE_TASK_VERSION END');
  END IF;
EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to move_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to move_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'MOVE_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to move_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'MOVE_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END Move_Task_version;

-- API name                      : Indent_Task_Version
-- Type                          : Public procedure
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
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE INDENT_TASK_VERSION (
 p_api_version            IN    NUMBER   :=1.0,
 p_init_msg_list            IN  VARCHAR2 :=FND_API.G_TRUE,
 p_commit                   IN  VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only            IN  VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level         IN  NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module           IN  VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count            IN  NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id     IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id          IN  NUMBER,
 p_record_version_number    IN      NUMBER,
 x_return_status            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


  l_api_name               CONSTANT VARCHAR(30) := 'INDENT_TASK_VERSION';
  l_api_version            CONSTANT NUMBER      := 1.0;

  l_wbs_level              NUMBER;
  l_display_sequence       NUMBER;
  l_prev_wbs_level         NUMBER;
  l_prev_display_sequence  NUMBER;
  l_ref_task_version_id    NUMBER;
  l_peer_or_sub            VARCHAR2(30);
  l_parent_structure_version_id NUMBER;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_project_id                  NUMBER;
  l_structure_id                NUMBER;
  l_ref_task_id                 NUMBER;
  l_task_id                     NUMBER;
  l_task_record_version_number  NUMBER;
  l_wbs_record_version_number   NUMBER;
  l_dummy_char                  VARCHAR2(1);
  l_published_version           VARCHAR2(1);

--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
--end changes

--hyau
--added for lifecycle version
    l_proj_element_id  NUMBER;
    src_proj_element_id       NUMBER; -- Bug 6881272
-- end changes

    CURSOR cur_struc_type( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';

--Hsiu added for date rollup
  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

--hsiu added for task status
  CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_elem_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_ver_id NUMBER;
  l_error_msg_code VARCHAR2(30);

BEGIN
  pa_debug.init_err_stack ('PA_TASK_PUB1.INDENT_TASK_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_TASK_VERSION begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint indent_task_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

----dbms_output.put_line( 'Indent Task Stage 1 ' );
--hsiu
--added on 08-JAN-2002
--check if task are linked task
-- Bug 6881272: ABLE TO INDENT THE TASK OF THE WBS WITH THE LINKED PROJECT

  BEGIN
      SELECT proj_element_id,project_id
      INTO src_proj_element_id,l_project_id
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE element_version_id = p_task_version_id
      AND parent_structure_version_id = p_structure_version_id;
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END;

  IF (p_structure_version_id IS NOT NULL) AND
       (p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
-- Bug 6881272: ABLE TO INDENT THE TASK OF THE WBS WITH THE LINKED PROJECT
      IF (Nvl(pa_relationship_utils.check_task_has_sub_proj(l_project_id
							          , src_proj_element_id
								        , p_task_version_id),'N') = 'Y') THEN
      --deleting linked task. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_IND_LINKED_TASK');
    END IF;

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
  END IF;

  -- hyau
  -- Lifecycle Phase validation Changes. Check if task has phase associated with it
  IF (p_task_version_id IS NOT NULL) AND
       (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

  SELECT proj_element_id, wbs_level, display_sequence, parent_structure_version_id
  INTO l_proj_element_id, l_wbs_level, l_display_sequence, l_parent_structure_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;

    IF ('Y' = pa_proj_elements_utils.CHECK_ELEMENT_HAS_PHASE(
              l_proj_element_id)) THEN
      --Indenting a task with phase. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_LC_NO_INDENT_PHASE_TASK');
    END IF;

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
  END IF;
  -- end hyau. Lifecycle Phase validation Changes.

--dbms_output.put_line( 'Indent Task Stage 2 ' );


/*   Moved up for performance bug 2832807
  SELECT wbs_level, display_sequence, parent_structure_version_id
  INTO l_wbs_level, l_display_sequence, l_parent_structure_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;
*/

--dbms_output.put_line( 'Indent Task Stage 3 ' );


  if l_display_sequence = 1 then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_INDENT');
  end if;

--dbms_output.put_line( 'Indent Task Stage 4 ' );

--need to specify parent structure version id
  SELECT wbs_level, element_version_id
  INTO l_prev_wbs_level, l_ref_task_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE display_sequence = l_display_sequence - 1
    AND parent_structure_version_id = l_parent_structure_version_id;

--dbms_output.put_line( 'Indent Task Stage 5 ' );


  if l_wbs_level > l_prev_wbs_level then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_INDENT');
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

--dbms_output.put_line( 'Indent Task Stage 6 ' );

  if l_wbs_level = l_prev_wbs_level then
    l_peer_or_sub := 'SUB';
  else
    l_peer_or_sub := 'PEER';

--dbms_output.put_line( 'Indent Task Stage 7 ' );

--need to specify which structure version
--need to specify parent in the inner select statement
    SELECT element_version_id
    INTO l_ref_task_version_id
    FROM PA_PROJ_ELEMENT_VERSIONS
    WHERE wbs_level = l_wbs_level + 1
    AND   object_type = 'PA_TASKS'
    AND   display_sequence < l_display_sequence
    AND   parent_structure_version_id = l_parent_structure_version_id
    AND   display_sequence =
          (SELECT max(display_sequence)
           FROM PA_PROJ_ELEMENT_VERSIONS
           WHERE wbs_level = l_wbs_level + 1
           AND   object_type = 'PA_TASKS'
           AND   display_sequence < l_display_sequence
           AND parent_structure_version_id = l_parent_structure_version_id);
--dbms_output.put_line( 'Indent Task Stage 8 ' );

  end if;


    --hsiu added for task status
    --Check if ok to indent this task
    PA_PROJ_ELEMENTS_UTILS.Check_move_task_ok(
         p_task_ver_id => p_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
    );

    IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
    END IF;

    --check if ok to create subtask
    IF (l_peer_or_sub = 'PEER') THEN
      OPEN get_parent_version_id(l_ref_task_version_id);
      FETCH get_parent_version_id into l_parent_ver_id;
      CLOSE get_parent_version_id;
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_ref_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  --end task status changes


--dbms_output.put_line( 'Indent Task Stage 9 ' );

  PA_TASK_PUB1.Update_Task_Version
  ( p_validate_only      => FND_API.G_FALSE,
    p_ref_task_version_id    => l_ref_task_version_id,
    p_peer_or_sub              => l_peer_or_sub,
    p_task_version_id        => p_task_version_id,
    p_record_version_number  => p_record_version_number,
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data );

--dbms_output.put_line( 'Indent Task Stage 10 ' );


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


--dbms_output.put_line( 'Indent Task Stage 11 ' );

  -- Update WBS numbers
  SELECT parent_structure_version_id
  INTO l_parent_structure_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;

--dbms_output.put_line( 'Indent Task Stage 12 ' );


  PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
  ( p_commit                   => p_commit
   ,p_debug_mode               => p_debug_mode
   ,p_parent_structure_ver_id  => l_parent_structure_version_id
   ,p_task_id                  => p_task_version_id
   ,p_display_seq              => l_display_sequence
   ,p_action                   => 'INDENT'
   ,p_parent_task_id           => NULL
   ,x_return_status            => l_return_status );


  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = p_task_version_id )
     AND object_type = 'PA_STRUCTURES';


  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;

--hsiu
--changes for versioning
      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);

      IF (NVL( l_published_version, 'N' ) = 'N') OR (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y')
      OR ((l_published_version = 'Y') AND (l_shared = 'N')) -- Bug # 5064340. -- To accomodate split financial tasks.
      THEN
--      IF NVL( l_published_version, 'N' ) = 'N'
--      THEN
--end changes

          SELECT ppev.proj_element_id, pt.record_version_number, ppa.wbs_record_version_number, ppev.project_id
            INTO l_task_id, l_task_record_version_number, l_wbs_record_version_number, l_project_id
            FROM PA_TASKS pt,
                 pa_proj_elem_ver_structure ppa,
                 PA_PROJ_ELEMENT_VERSIONS ppev
           WHERE ppev.element_version_id = p_task_version_id
             AND ppev.parent_structure_version_id = ppa.element_version_id
             AND ppev.project_id = ppa.project_id
             AND ppev.proj_element_id = pt.task_id;

          SELECT proj_element_id
            INTO l_ref_task_id
            FROM PA_PROJ_ELEMENT_VERSIONS
           WHERE element_version_id = l_ref_task_version_id;

          SELECT record_version_number INTO l_task_record_version_number
            FROM pa_tasks
           WHERE task_id = l_task_id
             AND project_id = l_project_id;


          PA_TASKS_MAINT_PUB.Edit_Task_Structure(
                         p_project_id                        => l_project_id
                        ,p_task_id                           => l_task_id
                        ,p_edit_mode                         => 'INDENT'
                        ,p_record_version_number             => l_task_record_version_number
                        ,p_wbs_record_version_number         => 1
                        ,x_return_status                     => l_return_status
                        ,x_msg_count                         => l_msg_count
                        ,x_msg_data                          => l_msg_data );

--dbms_output.put_line( 'Indent Task Stage 19 ' );

      END IF;
  END IF;
  CLOSE cur_struc_type;

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

--Hsiu added for date rollup; workplan only

  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(l_parent_structure_version_id, 'WORKPLAN') = 'Y' then
    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := p_task_version_id;

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
       raise FND_API.G_EXC_ERROR;
     end if;

--hsiu added for task status
--if versioning is off, rollup.
     IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,p_element_version_id => p_task_version_id
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
         raise FND_API.G_EXC_ERROR;
       end if;
     END IF;

--end task status changes

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_TASK_VERSION END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END Indent_Task_Version;


-- API name                      : Outdent_Task_Version
-- Type                          : Public procedure
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
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE OUTDENT_TASK_VERSION (
 p_api_version            IN    NUMBER   :=1.0,
 p_init_msg_list          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_record_version_number  IN    NUMBER,
 x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_api_name                      CONSTANT VARCHAR(30) := 'OUTDENT_TASK_VERSION';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_wbs_level                     NUMBER;
  l_display_sequence              NUMBER;
  l_ref_task_version_id           NUMBER;
  l_parent_structure_version_id   NUMBER;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_project_id                  NUMBER;
  l_ref_task_id                 NUMBER;
  l_task_id                     NUMBER;
  l_task_record_version_number  NUMBER;
  l_wbs_record_version_number   NUMBER;
  l_dummy_char                  VARCHAR2(1);
  l_published_version           VARCHAR2(1);
  l_structure_id                NUMBER;

--hsiu
--added for advanced structure - versioning
    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
--end changes

    CURSOR cur_struc_type( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code IN( 'FINANCIAL' );

    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';

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
        and b.object_id_to1 <> p_task_version_id;
   c_get_peer_tasks get_peer_tasks%ROWTYPE;

--Hsiu added, for dates rollup
  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
--hsiu added, for task status
  l_rollup_task_id NUMBER;

--hsiu added for task status
  CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_elem_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_ver_id NUMBER;
  l_error_msg_code VARCHAR2(30);
BEGIN
  pa_debug.init_err_stack ('PA_TASK_PUB1.OUTDENT_TASK_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_TASK_VERSION begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint outdent_task_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

--hsiu
--added on 08-JAN-2002
--check if task are linked task
  IF (p_structure_version_id IS NOT NULL) AND
       (p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
    IF ('N' = pa_proj_elements_utils.check_task_in_structure(
          p_structure_version_id,
          p_task_version_id)) THEN
      --deleting linked task. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_OUTD_LINKED_TASK');
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
        (p_encoded         => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
  END IF;

--hsiu added, for dates rollup
--need to get peer task before it has been outdented.
  OPEN get_peer_tasks;
  LOOP
    FETCH get_peer_tasks INTO c_get_peer_tasks;
    EXIT WHEN get_peer_tasks%NOTFOUND;
    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := c_get_peer_tasks.object_id_to1;
--added for task status rollup
    l_rollup_task_id := c_get_peer_tasks.object_id_to1;
  END LOOP;
  CLOSE get_peer_tasks;


  SELECT wbs_level, display_sequence, parent_structure_version_id
  INTO l_wbs_level, l_display_sequence, l_parent_structure_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;

  if l_wbs_level = 1 then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_OUTDENT');
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

  --get the reference task version of p_task_version_id
  SELECT element_version_id
  INTO l_ref_task_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE wbs_level = l_wbs_level - 1
  AND   object_type = 'PA_TASKS'
  AND   parent_structure_version_id = l_parent_structure_version_id
  AND   display_sequence < l_display_sequence
  AND   display_sequence =
        (SELECT max(display_sequence)
         FROM PA_PROJ_ELEMENT_VERSIONS
         WHERE wbs_level = l_wbs_level - 1
         AND   object_type = 'PA_TASKS'
         AND   parent_structure_version_id = l_parent_structure_version_id
         AND   display_sequence < l_display_sequence);

--hsiu added for task status
    --Check if ok to outdent this task
    PA_PROJ_ELEMENTS_UTILS.Check_move_task_ok(
         p_task_ver_id => p_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
    );

    IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
    END IF;

  OPEN get_parent_version_id(l_ref_task_version_id);
  FETCH get_parent_version_id into l_parent_ver_id;
  CLOSE get_parent_version_id;
  PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
  );

  IF (l_return_status <> 'Y') THEN
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name => l_error_msg_code);
    raise FND_API.G_EXC_ERROR;
  END IF;
--task status changes ends

--dbms_output.put_line( 'Before Update_Task_Version ' );

  PA_TASK_PUB1.Update_Task_Version
  ( p_validate_only      => FND_API.G_FALSE,
    p_ref_task_version_id    => l_ref_task_version_id,
    p_peer_or_sub        => 'PEER',
    p_task_version_id        => p_task_version_id,
    p_record_version_number  => p_record_version_number,
    p_action                 => 'OUTDENT',
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data );

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

--dbms_output.put_line( 'Before Update WBS numbers ' );

  -- Update WBS numbers
  SELECT parent_structure_version_id
  INTO l_parent_structure_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = p_task_version_id;

  PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
  ( p_commit                   => p_commit
   ,p_debug_mode               => p_debug_mode
   ,p_parent_structure_ver_id  => l_parent_structure_version_id
   ,p_task_id                  => p_task_version_id
   ,p_display_seq              => l_display_sequence
   ,p_action                   => 'OUTDENT'
   ,p_parent_task_id           => NULL
   ,x_return_status            => l_return_status );

/*  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  p_structure_version_id
     AND object_type = 'PA_STRUCTURES';*/

  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = p_task_version_id )
     AND object_type = 'PA_STRUCTURES';

  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;

--hsiu
--changes for versioning
      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);
      IF (NVL( l_published_version, 'N' ) = 'N') OR (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y')
      OR ((l_published_version = 'Y') AND (l_shared = 'N')) -- Bug # 5064340. -- To accomodate split financial tasks.
      THEN
--      IF NVL( l_published_version, 'N' ) = 'N'
--      THEN
--end changes

         SELECT ppev.proj_element_id, pt.record_version_number, ppa.wbs_record_version_number, ppev.project_id
           INTO l_task_id, l_task_record_version_number, l_wbs_record_version_number, l_project_id
           FROM PA_TASKS pt,
                pa_proj_elem_ver_structure ppa,
                PA_PROJ_ELEMENT_VERSIONS ppev
          WHERE ppev.element_version_id = p_task_version_id
            AND ppev.parent_structure_version_id = ppa.element_version_id
            AND ppev.project_id = ppa.project_id
            AND ppev.proj_element_id = pt.task_id;

         SELECT proj_element_id
           INTO l_ref_task_id
           FROM PA_PROJ_ELEMENT_VERSIONS
          WHERE element_version_id = l_ref_task_version_id;

          SELECT record_version_number INTO l_task_record_version_number
            FROM pa_tasks
           WHERE task_id = l_task_id
             AND project_id = l_project_id;

          PA_TASKS_MAINT_PUB.Edit_Task_Structure(
                         p_project_id                        => l_project_id
                        ,p_task_id                           => l_task_id
                        ,p_edit_mode                         => 'OUTDENT'
                        ,p_record_version_number             => l_task_record_version_number
                        ,p_wbs_record_version_number         => 1
                        ,x_return_status                     => l_return_status
                        ,x_msg_count                         => l_msg_count
                        ,x_msg_data                          => l_msg_data );
      END IF;
  END IF;
  CLOSE cur_struc_type;

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

--dbms_output.put_line( 'After Move task ' );

--Hsiu added for date rollup; workplan only

  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(l_parent_structure_version_id, 'WORKPLAN') = 'Y' then
    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := p_task_version_id;

--added for task status rollup
    IF (l_rollup_task_id IS NULL) THEN
      l_rollup_task_id := p_task_version_id;
    END IF;

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
       raise FND_API.G_EXC_ERROR;
     end if;

--hsiu added for task status
--if versioning is off, rollup.
     IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,p_element_version_id => l_rollup_task_id
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
         raise FND_API.G_EXC_ERROR;
       end if;
     END IF;

--end task status changes

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_TASK_VERSION END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END Outdent_Task_Version;

-- API name                      : Create_tasks
-- Type                          : Wrapper Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id            IN NUMBER
-- p_ref_task_version_id   IN NUMBER
-- p_structure_id          IN NUMBER
-- p_structure_version_id  IN NUMBER
-- p_outline_level         IN PA_NUM_1000_NUM
-- p_task_number           IN PA_VC_1000_150
-- p_task_name             IN PA_VC_1000_2000
-- p_scheduled_start_date  IN PA_DATE_1000_DATE
-- p_scheduled_finish_date IN PA_DATE_1000_DATE
-- p_task_manager_id       IN PA_NUM_1000_NUM
-- p_task_manager_name     IN PA_VC_1000_150
  --FP M Development Changes
-- p_planned_effort              IN              PA_NUM_1000_NUM
-- p_dependencies                IN              PA_VC_1000_4000
-- p_dependency_ids              IN              PA_NUM_1000_NUM
-- p_structure_type              IN              VARCHAR2        :='WORKPLAN'
-- p_financial_flag              IN              VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_resources                   IN              PA_VC_1000_4000
-- p_resource_ids                IN              PA_NUM_1000_NUM
-- p_mapped_task                 IN              PA_VC_1000_4000
-- p_mapped_task_id              IN              PA_NUM_1000_NUM
  --End FP M Development Changes
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE CREATE_TASKS
( p_project_id            IN NUMBER
 ,p_ref_task_version_id   IN NUMBER
 ,p_structure_id          IN NUMBER
 ,p_structure_version_id  IN NUMBER
 ,p_outline_level         IN PA_NUM_1000_NUM
 ,p_task_number           IN PA_VC_1000_150
 ,p_task_name             IN PA_VC_1000_2000
 ,p_scheduled_start_date  IN PA_DATE_1000_DATE
 ,p_scheduled_finish_date IN PA_DATE_1000_DATE
 ,p_task_manager_id       IN PA_NUM_1000_NUM
 ,p_task_manager_name     IN PA_VC_1000_150
 ,p_TYPE_ID               IN PA_NUM_1000_NUM
  --FP M Development Changes bug 330119
 ,p_planned_effort              IN              PA_NUM_1000_NUM
 ,p_planned_equip_effort        IN              PA_NUM_1000_NUM
 ,p_dependencies                IN              PA_VC_1000_4000
 ,p_dependency_ids              IN              PA_NUM_1000_NUM
 ,p_structure_type              IN              VARCHAR2        :='WORKPLAN'
 ,p_financial_flag              IN              VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_use_in_fin_plan             IN              PA_VC_1000_10
 ,p_resources                   IN              PA_VC_1000_4000
 ,p_resource_ids                IN              PA_NUM_1000_NUM
 ,p_mapped_task                 IN              PA_VC_1000_4000
 ,p_mapped_task_id              IN              PA_NUM_1000_NUM
  --End FP M Development Changes bug 330119
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  i                    NUMBER;
  l_msg_count          NUMBER;
  l_return_status      VARCHAR2(1);
  l_msg_data           VARCHAR2(2000);
  l_data               VARCHAR2(2000);
  l_msg_index_out      NUMBER;

  l_outline_level      NUMBER;
  l_prev_outline_level NUMBER;
  l_ref_task_ver_id    NUMBER;
  l_peer_or_sub        VARCHAR2(20);
  l_task_id            NUMBER;
  l_task_version_id    NUMBER;
  API_ERROR            EXCEPTION;

  TYPE reference_tasks IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  -- This table stores reference task version IDs for a particular outline
  -- level. This provides a lookup to find the last task version created
  -- at that level.
  l_outline_task_ref reference_tasks;
  l_pev_schedule_id  NUMBER;
  l_ref_proj_eleme_id NUMBER;

  CURSOR cur_ref_proj_elem_id( p_ref_task_ver_id NUMBER )
  IS
    SELECT proj_element_id
      FROM pa_proj_element_versions
     WHERE element_version_id = p_ref_task_ver_id
       AND object_type = 'PA_TASKS';

--Hsiu added for date rollup
  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

-- anlee task weighting
  l_top_sub_count NUMBER;
-- anlee End of changes

-- hsiu added for task version status
  CURSOR cur_proj_is_template(c_project_id NUMBER)
  IS     select 'Y'
           from pa_projects_all
          where project_id = c_project_id
            and template_flag = 'Y';
  l_template_flag VARCHAR2(1);

  l_task_unpub_ver_status_code PA_PROJ_ELEMENT_VERSIONS.TASK_UNPUB_VER_STATUS_CODE%TYPE;

  CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_elem_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_ver_id NUMBER;
  l_error_msg_code VARCHAR2(30);
--end task version status changes

    l_versioned    VARCHAR2(1) := 'N';
    l_shared       VARCHAR2(1) := 'N';
    l_published_ver_exists  VARCHAR2(1);
    l_wp_process_flag    VARCHAR2(1);
--bug 3053281
  l_wp_type              VARCHAR2(1);
  l_weighting_basis_Code VARCHAR2(30);
--end bug 3053281

  CURSOR get_base_ref_obj_type IS
    select object_type
      from pa_proj_element_versions
     where element_version_id = p_ref_task_version_id;
  l_ref_obj_type VARCHAR2(30);

  -- Added for FP_M changes : Bug 3305199 : Bhumesh
    l_Share_Code          VARCHAR2(30);
    l_Financial_Flag      VARCHAR2(1) := 'N';

--bug 3301192
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /* l_task_ver_ids              PA_PLSQL_DATATYPES.IdTabTyp;                      */
  l_task_ver_ids              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */

BEGIN

  --Clear Error Messages.
  FND_MSG_PUB.initialize;

  savepoint create_tasks;

  if p_project_id is null then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NO_PROJECT_ID');
  end if;

  if p_ref_task_version_id is null then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NO_TASK_VERSION_ID');
  end if;

  if p_structure_version_id is null then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NO_STRUCTURE_VERSION_ID');
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
    raise API_ERROR;
  end if;

--bug 3053281 --set flag if not (manual and workplan only)
  l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
  l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(p_project_id);

--bug 3010538
--Added the following lines to cache versioning and sharing information
  l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     p_project_id);
  l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  p_project_id);
  --check whether there exists any published version.
  l_published_ver_exists := PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS( p_project_id, p_structure_id );
--end bug 3010538
  --3035902: process update flag changes
  l_wp_process_flag := 'N';
  --3035902: end process update flag changes

  l_outline_task_ref(0) := p_ref_task_version_id;
  l_prev_outline_level := NULL;

  -- anlee task weighting
  l_top_sub_count := 0;
  -- anlee End of changes

  --hsiu: added for task version status
  OPEN cur_proj_is_template(p_project_id);
  FETCH cur_proj_is_template into l_template_flag;
  IF cur_proj_is_template%NOTFOUND THEN
    l_template_flag := 'N';
  END IF;
  CLOSE cur_proj_is_template;
  --added for task version status

  --added for bug 3125370
  OPEN get_base_ref_obj_type;
  FETCH get_base_ref_obj_type into l_ref_obj_type;
  CLOSE get_base_ref_obj_type;
  --bug 3125370

  -- Added for FP_M changes. Tracking Bug 3305199
    l_financial_flag := 'N';

  for i in 1..1000 LOOP
    if p_outline_level(i) is null AND p_task_name(i) IS NOT NULL AND p_task_number(i) IS NOT NULL then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_TSK_WBS_LVL_ERR');
      x_msg_count := 1;
      pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => l_msg_count,
           p_msg_data       => l_msg_data,
           p_data           => l_data,
           p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
      raise API_ERROR;
    end if;

    if p_outline_level(i) is null then
      exit;
    end if;

    l_Share_Code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_project_id);
    -- Added for FP_M changes. Tracking Bug 3305199 : Bhumesh
/*
    IF l_Share_Code IN ('SHARE_FULL', 'SHARE_PARTIAL') then
       If P_Structure_Type = 'FINANCIAL' THEN
      l_Financial_Flag := 'N';
       Else
      l_Financial_Flag := 'Y';
       End If;

       If P_Structure_Type = 'WORKPLAN' THEN
          IF l_Share_Code = 'SHARE_PARTIAL' then
         l_Financial_Flag := 'N';
          Else
         l_Financial_Flag := 'Y';
          End If;
       End If;
    End IF;
*/
   IF l_shared = 'Y'
   THEN
       If P_Structure_Type = 'WORKPLAN' AND
          l_Share_Code = 'SHARE_PARTIAL' then
          l_Financial_Flag := 'N';
       Else
         l_Financial_Flag := 'Y';
       End If;

   ELSE
       If P_Structure_Type = 'WORKPLAN' THEN
          l_Financial_Flag := 'N';
       Else
          l_Financial_Flag := 'Y';
       End If;
    End IF;
    -- End of FP_M changes

    --bug 3125370: add condition for reference object_type
    if (instr(to_char(p_outline_level(i)), '.') <> 0) OR
       (l_ref_obj_type = 'PA_STRUCTURES' and p_outline_level(i) = 0) then
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_OUTLINE_LEVEL_INVALID');

      x_msg_count := 1;
      pa_interface_utils_pub.get_messages
      (p_encoded        => FND_API.G_TRUE,
       p_msg_index      => 1,
       p_msg_count      => l_msg_count,
       p_msg_data       => l_msg_data,
       p_data           => l_data,
       p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
      raise API_ERROR;
    end if;

    l_outline_level := p_outline_level(i);

    if l_prev_outline_level is not null then
      if l_outline_level > l_prev_outline_level then
        if (l_outline_level - l_prev_outline_level) > 1 then
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PS_OUTLINE_LEVEL_INVALID');

          x_msg_count := 1;
          pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
           p_msg_index      => 1,
           p_msg_count      => l_msg_count,
           p_msg_data       => l_msg_data,
           p_data           => l_data,
           p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
          raise API_ERROR;
        end if;

        l_ref_task_ver_id := l_outline_task_ref(l_prev_outline_level);
        l_peer_or_sub := 'SUB';
      else
        l_ref_task_ver_id := l_outline_task_ref(l_outline_level);
        l_peer_or_sub := 'PEER';
      end if;
    else
      -- First task to insert
      if l_outline_level not in (0, 1) then
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_OUTLINE_LEVEL_INVALID');

        x_msg_count := 1;
        pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
        raise API_ERROR;
      end if;

      l_ref_task_ver_id := l_outline_task_ref(0);
      if l_outline_level = 0 then
        l_peer_or_sub := 'PEER';
      else
        l_peer_or_sub := 'SUB';
      end if;
    end if;

--my_error_msg( 'before PA_TASK_PUB1.CREATE_TASK' );

    OPEN cur_ref_proj_elem_id( l_ref_task_ver_id );
    FETCH cur_ref_proj_elem_id INTO l_ref_proj_eleme_id;   --For ref task id
    CLOSE cur_ref_proj_elem_id;

--my_error_msg( 'Ref Task Id in CREATE_TASKS'||l_ref_proj_eleme_id );

    --hsiu added for task status
    --check if ok to create subtask

/*  --commented; validation done in private api

    IF (l_peer_or_sub = 'PEER') THEN
      OPEN get_parent_version_id(l_ref_task_ver_id);
      FETCH get_parent_version_id into l_parent_ver_id;
      CLOSE get_parent_version_id;
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise API_ERROR;
      END IF;
    ELSE
      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_ref_task_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise API_ERROR;
      END IF;
    END IF;
*/
    --end task status changes

    -- CREATE_TASK
   l_task_id := NULL;

   --3035902: process update flag changes
   IF (l_wp_process_flag = 'N') THEN
     --may need to update process flag
     IF ((l_shared = 'N') AND
         (l_wp_type = 'Y')) THEN
       --split and workplan; only update if progressable task added
       l_wp_process_flag := 'Y';
     ELSIF ((l_shared = 'N') AND
            (l_wp_type = 'N')) THEN
       --split and financial; update
       l_wp_process_flag := 'Y';
     ELSIF (l_shared = 'Y') THEN
       l_wp_process_flag := 'Y';
     END IF;
   END IF;
   --3035902: end process update flag changes

   PA_TASK_PUB1.CREATE_TASK
   ( p_validate_only          => FND_API.G_FALSE
    ,p_object_type            => 'PA_TASKS'
    ,p_project_id             => p_project_id
    ,p_ref_task_id            => l_ref_proj_eleme_id
    ,p_peer_or_sub            => l_peer_or_sub
    ,p_structure_id           => p_structure_id
    ,p_structure_version_id    => p_structure_version_id
    ,p_task_number            => p_task_number(i)
    ,p_task_name              => p_task_name(i)
    ,p_task_manager_id        => p_task_manager_id(i)
    ,p_task_manager_name      => p_task_manager_name(i)
    ,p_scheduled_start_date   => p_scheduled_start_date(i)--Changed in BUG fix 3927343
    ,p_scheduled_finish_date  => p_scheduled_finish_date(i)--Changed in BUG fix 3927343
    ,p_TYPE_ID                => p_TYPE_ID  (i)
    ,p_structure_type         => p_structure_type
    ,x_task_id                => l_task_id
    ,x_return_status          => l_return_status
    ,x_msg_count              => l_msg_count
    ,x_msg_data               => l_msg_data);

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
     raise API_ERROR;
   end if;

--my_error_msg( 'before PA_TASK_PUB1.CREATE_TASK_VERSION' );

/* commented out because flag value is set before create task
--bug 3010538
IF (l_shared = 'N') AND
   (l_wp_type = 'Y') AND
   (l_weighting_basis_Code = 'MANUAL') THEN
  --do not set the flag to 'Y'
  NULL;
ELSE
*/
  --3035902: process update flag changes
  --set the flag if flag is Y; otherwise keep current value
  --Bug No 3450684 SMukka Commented if condition
  --IF l_wp_process_flag = 'Y' THEN
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => p_project_id
     ,p_structure_version_id  => p_structure_version_id
     ,p_update_wbs_flag       => l_wp_process_flag
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
  --END IF;
  --3035902: end process update flag changes

  --ideally the following calls should have been cached. but due to time constraints
  --we need to write the code this way in multiple places.
  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y'
   THEN
       IF ( l_versioned = 'N' ) OR
          ( l_shared = 'N' ) OR    --This wont happen bcoz for adding tasks to a financial structure we dont use this api
          ( l_versioned = 'Y' AND l_shared = 'Y' AND l_published_ver_exists = 'N' )THEN
       --create_tasks
       pa_fp_refresh_elements_pub.set_process_flag_proj(
             p_project_id               => p_project_id
            ,p_request_id               => null
            ,p_process_code             => null
            ,p_refresh_required_flag    => 'Y'
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data );

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
     END IF;
   END IF;


--End bug 3010538

--hsiu: task version status changes
   IF (l_template_flag = 'N') THEN
          --check if structure is shared
          --  if shared, check if versioned
          --    'WORKING' if versioned; 'PUBLISHED' if not
          --  if split, check if 'FINANCIAL'
          --    'PUBLISHED' if financial
          --    check if versioned
          --    'WORKING' if versioend; 'PUBLISHED' if not
--     IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id)) THEN
--       IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id)) THEN --Replaced these line with the following for performance.
--Code added for bug 3010538 also does the same check.
     IF ('Y' = l_shared) THEN
       IF ('Y' = l_versioned) THEN

         l_task_unpub_ver_status_code := 'WORKING';
       ELSE
         l_task_unpub_ver_status_code := 'PUBLISHED';
       END IF;
     ELSE --split
       IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(p_structure_id, 'FINANCIAL')  AND
           'N' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(p_structure_id, 'WORKPLAN')) THEN
         l_task_unpub_ver_status_code := 'PUBLISHED';
       ELSE --workplan only
          --IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id)) THEN  --Replaced these line with the following for performance. Code added for bug 3010538 also does the same check.
          IF ('Y' = l_versioned) THEN
           l_task_unpub_ver_status_code := 'WORKING';
         ELSE
           l_task_unpub_ver_status_code := 'PUBLISHED';
         END IF;
       END IF;
     END IF;
   ELSE
     l_task_unpub_ver_status_code := 'WORKING';
   END IF;
--end task version status changes


   --CREATE_TASK_VERSION
   PA_TASK_PUB1.CREATE_TASK_VERSION
   ( p_validate_only        => FND_API.G_FALSE
    ,p_ref_task_version_id  => l_ref_task_ver_id
    ,p_peer_or_sub          => l_peer_or_sub
    ,p_task_id              => l_task_id
    ,p_TASK_UNPUB_VER_STATUS_CODE => l_task_unpub_ver_status_code
    ,p_financial_task_flag  => l_Financial_Flag
    ,x_task_version_id      => l_task_version_id
    ,x_return_status        => l_return_status
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data);

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
     raise API_ERROR;
   end if;


--Hsiu added
--inherit task type
   PA_TASK_PVT1.Inherit_task_type_attr(
                p_task_id => l_task_id
               ,p_task_version_id => l_task_version_id
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
     raise API_ERROR;
   end if;
--end inherit task type

--my_error_msg( 'before PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION' );
--Changes for 8566495 anuragag
--We will create record in pa_proj_elem_ver_schedules now for tasks created via change management flow.
-- PA_TASK_PVT1.G_CHG_DOC_CNTXT will be equal to 1 only when the task is created via CD flow.
   if (PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y' OR PA_TASK_PVT1.G_CHG_DOC_CNTXT = 1) then
     PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
     ( p_validate_only           => FND_API.G_FALSE
      ,p_element_version_id      => l_task_version_id
      ,p_scheduled_start_date    => nvl(p_scheduled_start_date(i), sysdate)
      ,p_scheduled_end_date      => nvl(p_scheduled_finish_date(i),nvl(p_scheduled_start_date(i), sysdate))
      ,p_planned_effort          => p_planned_effort(i)
      ,p_Planned_Equip_Effort    => p_planned_equip_effort(i)
      ,x_pev_schedule_id         => l_pev_schedule_id
      ,x_return_status           => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data );

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
       raise API_ERROR;
     end if;

-- Hsiu added for date rollup; workplan only
     l_tasks_ver_ids.extend;
     l_tasks_ver_ids(l_tasks_ver_ids.count) := l_task_version_id;
	 --anuragag bug 8566495 - we will validate the task start and end date
	PA_TASKS_MAINT_UTILS.check_start_date(
											p_project_id =>  p_project_id,
											p_parent_task_id => NULL,
											p_task_id => l_task_id,
											p_start_date => p_scheduled_start_date(i),
											x_return_status =>l_return_status,
											x_msg_count =>l_msg_count,
											x_msg_data =>l_msg_data);


IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := 1;
	  x_msg_data := l_msg_data;
      if l_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
          --x_msg_data := l_data;
		  x_msg_count := 1;
		  FND_MESSAGE.SET_NAME('PA',x_msg_data);
		  --FND_MESSAGE.GET_ENCODED := x_msg_data;
		  FND_MSG_PUB.ADD;
       end if;


      raise API_ERROR;
    END IF;

	PA_TASKS_MAINT_UTILS.check_end_date(
											p_project_id =>  p_project_id,
											p_parent_task_id => NULL,
											p_task_id => l_task_id,
											p_end_date => p_scheduled_finish_date(i),
											x_return_status =>l_return_status,
											x_msg_count =>l_msg_count,
											x_msg_data =>l_msg_data);


IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_count := 1;
	  x_msg_data := l_msg_data;
      if l_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
          --x_msg_data := l_data;
		  x_msg_count:=1;
		  FND_MESSAGE.SET_NAME('PA',x_msg_data);
		  --FND_MESSAGE.GET_ENCODED := x_msg_data;
		  FND_MSG_PUB.ADD;
       end if;
      raise API_ERROR;
    END IF;

	--end anuragag changes for 8566495

   end if;


   -- anlee task weighting
   if l_outline_level = 1 then
     l_top_sub_count := l_top_sub_count + 1;
   end if;
   -- anlee End of changes

   l_outline_task_ref(l_outline_level) := l_task_version_id;
   l_prev_outline_level := l_outline_level;
  end LOOP;


  --bug 3301192 call the budgets apis
  if PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y' then /* this api called should have been cached but we dont have time now to do this. */
     PA_TASK_PUB1.call_add_planning_txns(
         p_tasks_ver_ids                  => l_tasks_ver_ids,
         p_planned_effort                 => p_planned_effort,
         p_project_id                     => p_project_id,
         p_structure_version_id           => p_structure_version_id,
         p_start_date                     => p_scheduled_start_date,
         p_end_date                       => p_scheduled_finish_date,
         x_return_status                  => l_return_status,
         x_msg_count                      => l_msg_count,
         x_msg_data                       => l_msg_data
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
       raise API_ERROR;
     end if;

     --now call call delete planning for reference task version id.
     IF (p_ref_task_version_id <> p_structure_version_id) AND
        (p_outline_level(1) > 0)
     THEN
       l_task_ver_ids.extend(1); /* Venky */
       l_task_ver_ids(1) := p_ref_task_version_id;
       /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
       /*moved pa_fp_planning_transaction_pub.delete_planning_transactions into plsql block        */
       DECLARE
           --p1 bug 3888432
           l_assign_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
           CURSOR get_assignment_id(c_task_ver_id NUMBER) IS
             SELECT resource_assignment_id
               FROM pa_resource_assignments
              WHERE wbs_element_Version_id = c_task_ver_id
                AND ta_display_flag = 'N';
           l_assign_id    NUMBER := NULL;
       BEGIN
           OPEN get_assignment_id(p_ref_task_version_id);
           FETCH get_assignment_id into l_assign_id;
           CLOSE get_assignment_id;

           IF (l_assign_id IS NOT NULL) THEN
             l_assign_ids.extend(1);
             l_assign_ids(1) := l_assign_id;
             pa_fp_planning_transaction_pub.delete_planning_transactions
             (
              p_context                      => 'WORKPLAN'
             ,p_task_or_res                  => 'ASSIGNMENT'
             --,p_element_version_id_tbl       => l_task_ver_ids
             ,p_resource_assignment_tbl => l_assign_ids
             ,x_return_status                => l_return_status
             ,x_msg_count                    => l_msg_count
             ,x_msg_data                     => l_msg_data
             );
           END IF;
       EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCTURE_TASK_PUB',
                                        p_procedure_name => 'CREATE_TASKS',
                                        p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.delete_planning_transactions:'||SQLERRM,1,240));
           RAISE API_ERROR;
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
       raise API_ERROR;
     end if;
     END IF;  --<<p_ref_task_version_id<>p_structure_version_id)

  end if;

  --bug 3301192 call the budgets apis

--Hsiu added for date rollup; workplan only

  if PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y' then
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
       raise API_ERROR;
     end if;

--    IF (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id) = 'Y') AND
--       (PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id) = 'N') THEN    --Replaced these line with the following for performance. Code added for bug 3010538 also does the same check.
    IF (l_shared = 'Y') AND
       (l_versioned = 'N')
THEN

      PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,x_return_status => l_return_status
                 ,x_msg_count => l_msg_count
                 ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> 'S') THEN
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE API_ERROR;
      END IF;
    END IF;

    -- anlee task weighting
    PA_TASK_PUB1.Calc_Task_Weights(
     p_element_versions => l_tasks_ver_ids
    ,p_outline_level    => p_outline_level
    ,p_top_sub_count    => l_top_sub_count
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data );

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
      raise API_ERROR;
    end if;
    -- anlee end of changes

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN API_ERROR THEN
  rollback to create_tasks;
  x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
  rollback to create_tasks;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCTURE_TASK_PUB',
                          p_procedure_name => 'CREATE_TASKS',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
  raise;
END CREATE_TASKS;


-- anlee task weighting
-- API name                  : Calc_Task_Weights
-- Type                      : Utility
-- Pre-reqs                  : None
-- Return Value              : N/A
-- Prameters
-- p_commit                IN  VARCHAR2 := FND_API.G_FALSE
-- p_element_versions      IN  PA_NUM_1000_NUM
-- p_outline_level         IN  PA_NUM_1000_NUM
-- p_top_peer_count        IN  NUMBER
-- p_top_sub_count         IN  NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  17-SEP-02   Andrew Lee             -Created
--
--

PROCEDURE CALC_TASK_WEIGHTS
( p_element_versions      IN PA_NUM_1000_NUM
 ,p_outline_level         IN PA_NUM_1000_NUM
 ,p_top_sub_count         IN NUMBER
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  CURSOR get_child_count(c_parent_element_version_id NUMBER)
  IS
  SELECT count(object_id_to1)
  FROM PA_OBJECT_RELATIONSHIPS
  WHERE object_id_from1 = c_parent_element_version_id
  AND   object_type_to = 'PA_TASKS'
  AND   relationship_type = 'S'
  AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');

  CURSOR get_summed_duration(c_parent_element_version_id NUMBER)
  IS
  SELECT sum(ppevs.duration)
  FROM pa_proj_elem_ver_schedule ppevs,
       pa_object_relationships por,
       pa_proj_element_versions ppev,
       pa_proj_elements ppe,
       pa_task_types ptt
  WHERE por.object_id_from1 = c_parent_element_version_id
  AND   por.object_type_to = 'PA_TASKS'
  AND   por.relationship_type = 'S'
  AND   por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
  AND   por.object_id_to1 = ppevs.element_version_id
  AND   por.object_id_to1 = ppev.element_version_id
  AND   ppev.proj_element_id = ppe.proj_element_id
  AND   ppe.project_id  = ppevs.project_id       /* for bug 2822963 */
  AND   ppe.TYPE_ID   = ptt.task_type_id
  AND   ptt.object_type = 'PA_TASKS'            /* for bug 3279978 FP M Enhancement */
  AND   ptt.prog_entry_enable_flag = 'Y';

  CURSOR get_task_duration(c_element_version_id NUMBER,c_project_id NUMBER)
  IS
  SELECT duration
  FROM pa_proj_elem_ver_schedule
  WHERE element_version_id = c_element_version_id
  AND   project_id = c_project_id;   /* for bug 2822963 */

  CURSOR get_parent(c_element_version_id NUMBER)
  IS
  SELECT object_id_from1
  FROM pa_object_relationships
  WHERE object_id_to1 = c_element_version_id
  AND   object_type_to = 'PA_TASKS'
  AND   relationship_type = 'S'
  AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');

  CURSOR check_progress_allowed(c_element_version_id NUMBER)
  IS
  SELECT ptt.prog_entry_enable_flag, ppe.project_id     /* for bug 2822963 */
  FROM   pa_task_types ptt,
         pa_proj_element_versions ppev,
         pa_proj_elements ppe
  WHERE  ppev.element_version_id = c_element_version_id
  AND    ppev.proj_element_id = ppe.proj_element_id
  AND    ptt.object_type = 'PA_TASKS'            /* for bug 3279978 FP M Enhancement */
  AND    ppe.TYPE_ID   = ptt.task_type_id;

  CURSOR get_existing_weights(c_parent_element_version_id NUMBER)
  IS
  SELECT sum(weighting_percentage)
  FROM   PA_OBJECT_RELATIONSHIPS
  WHERE  object_id_from1 = c_parent_element_version_id
  AND    object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
  AND    object_type_to = 'PA_TASKS'
  AND    relationship_type = 'S';

  -- Bug 3098574. This cursor gives the number of progressible tasks
  -- under a parent. This count will be used to pro-rate the task weightage
  -- on all the child tasks equally.
  CURSOR get_progressible_child_count(c_parent_element_version_id NUMBER)
  IS
  SELECT count(rel.object_id_to1)
  FROM PA_OBJECT_RELATIONSHIPS rel,pa_proj_element_versions ver,pa_proj_elements ele,pa_task_types tt
  WHERE rel.object_id_from1 = c_parent_element_version_id
  AND   rel.object_type_to = 'PA_TASKS'
  AND   rel.relationship_type = 'S'
  AND   rel.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
  AND   rel.object_id_to1 = ver.element_version_id
  AND   ver.proj_element_id = ele.proj_element_id
  AND   ele.type_id = tt.task_type_id
  AND   tt.object_type = 'PA_TASKS'            /* for bug 3279978 FP M Enhancement */
  AND   tt.prog_entry_enable_flag = 'Y';

  l_progressible_child_count NUMBER; -- Bug 3098574.

  -- Bug 3098574. This table will store the number of progressible tasks
  -- under a parent. This is used in order to cache the data.
  TYPE prog_child_count IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
  l_prog_child_count     prog_child_count;

  TYPE durations IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  -- This table stores the summed duration for all of the child tasks of a parent task/structure. The
  -- index is the parent element version id.
  l_durations durations;
  l_is_sub_new VARCHAR2(1);
  l_outline_level NUMBER;
  l_parent_element_version_id NUMBER;
  l_element_version_id NUMBER;
  l_total_sub_count NUMBER;
  l_total_duration NUMBER;
  l_progress_allowed VARCHAR2(1);
  l_task_duration NUMBER;
--  l_task_weight PA_OBJECT_RELATIONSHIPS.weighting_percentage%TYPE;
  l_task_weight NUMBER;
  l_existing_weight NUMBER;
  l_remaining_weight NUMBER;
  l_project_id NUMBER;

--Start Changes for bug 3083950
  l_debug_mode              VARCHAR2(1);
  l_module_name             VARCHAR2(100) := 'pa.plsql.PA_TASK_PUB1';
  l_temp_number             NUMBER(17,2);
  l_diff_number             NUMBER;
  l_sum_temp_number         NUMBER(17,4);
  l_constant_temp_number    NUMBER(17,4) := 0.0100;

  l_debug_level2                  CONSTANT NUMBER := 2;
  l_debug_level3                  CONSTANT NUMBER := 3;
  l_debug_level4                  CONSTANT NUMBER := 4;
  l_debug_level5                  CONSTANT NUMBER := 5;
  l_debug_level6                  CONSTANT NUMBER := 6;


  TYPE task_weightage_tbl IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;


  l_task_weightage_tbl     task_weightage_tbl;
  --End Changes for bug 3083950

BEGIN

    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entering CALC_TASK_WEIGHTS';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   l_debug_level2);


          pa_debug.set_curr_function( p_function   => 'PA_TASK_PUB1.CALC_TASK_WEIGHTS',
                                 p_debug_mode => l_debug_mode );

     END IF;


  l_is_sub_new := NULL;

  -- Loop through all of the newly created tasks from create_tasks
  for i in 1..1000 LOOP
    if p_outline_level(i) is null then
      exit;
    end if;

    OPEN get_parent(p_element_versions(i));
    FETCH get_parent INTO l_parent_element_version_id;
    CLOSE get_parent;

    l_element_version_id := p_element_versions(i);
    l_outline_level := p_outline_level(i);

    if l_outline_level = 0 then
      -- Automatically update task weighting as zero
      UPDATE PA_OBJECT_RELATIONSHIPS
      SET weighting_percentage = 0
      WHERE object_id_from1 = l_parent_element_version_id
      AND   object_id_to1 = l_element_version_id
      AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
      AND   object_type_to = 'PA_TASKS'
      AND   relationship_type = 'S';
    elsif l_outline_level = 1 then
      if l_is_sub_new is NULL then
        -- Determine whether there we any existing tasks for this level before
        -- create_tasks was called
        OPEN get_child_count(l_parent_element_version_id);
        FETCH get_child_count INTO l_total_sub_count;
        CLOSE get_child_count;

        if l_total_sub_count > p_top_sub_count then
          l_is_sub_new := 'N';
        else
          l_is_sub_new := 'Y';
        end if;
      end if;

      if l_is_sub_new = 'N' then
        -- There were existing tasks at this level, populate
        -- task weights of new tasks to 0
        UPDATE PA_OBJECT_RELATIONSHIPS
        SET weighting_percentage = 0
        WHERE object_id_from1 = l_parent_element_version_id
        AND   object_id_to1 = l_element_version_id
        AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
        AND   object_type_to = 'PA_TASKS'
        AND   relationship_type = 'S';
      else
        -- There were no existing tasks at this level, populate
        -- the correct task weight
        OPEN check_progress_allowed(l_element_version_id);
        FETCH check_progress_allowed INTO l_progress_allowed,l_project_id;  /* for bug 2822963 */
        CLOSE check_progress_allowed;

        if l_progress_allowed = 'N' then
          -- Populate task weight as zero
          UPDATE PA_OBJECT_RELATIONSHIPS
          SET weighting_percentage = 0
          WHERE object_id_from1 = l_parent_element_version_id
          AND   object_id_to1 = l_element_version_id
          AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND   object_type_to = 'PA_TASKS'
          AND   relationship_type = 'S';
        else

          if l_durations.exists(l_parent_element_version_id) then
            NULL;
          else
            OPEN get_summed_duration(l_parent_element_version_id);
            FETCH get_summed_duration INTO l_total_duration;
            CLOSE get_summed_duration;

            l_durations(l_parent_element_version_id) := l_total_duration;
          end if;

          OPEN get_task_duration(l_element_version_id,l_project_id); /* for bug 2822963 */
          FETCH get_task_duration INTO l_task_duration;
          CLOSE get_task_duration;

          -- Bug 3098574. When the summed duration of the child tasks
          -- of a parent is 0, get the number of child tasks and calculate
          -- the weighatage as 1 / number of tasks * 100.
/*          IF (l_durations(l_parent_element_version_id) IS NULL) OR
             (l_durations(l_parent_element_version_id) = 0) THEN
            l_task_weight := 0;
          ELSE*/

            IF (l_durations(l_parent_element_version_id) IS NULL) OR
             (l_durations(l_parent_element_version_id) = 0) THEN
               IF l_prog_child_count.exists(l_parent_element_version_id) THEN
                    l_progressible_child_count := l_prog_child_count(l_parent_element_version_id);
               ELSE
                    OPEN get_progressible_child_count(l_parent_element_version_id);
                    FETCH get_progressible_child_count into l_progressible_child_count;
                    CLOSE get_progressible_child_count;
                    l_prog_child_count(l_parent_element_version_id) := l_progressible_child_count;
               END IF;

               IF l_progressible_child_count  <> 0 THEN
                    l_task_weight := ( 1 / l_progressible_child_count ) * 100;
               ELSE -- This should never occur.
                    l_task_weight := 0;
               END IF;
            ELSE
               l_task_weight := (l_task_duration / l_durations(l_parent_element_version_id)) * 100;
            END IF;

            OPEN get_existing_weights(l_parent_element_version_id);
            FETCH get_existing_weights INTO l_existing_weight;
            CLOSE get_existing_weights;

            l_remaining_weight := 100 - l_existing_weight;
            -- l_task_weight := (l_task_duration / l_durations(l_parent_element_version_id)) * 100; Bug 3098574.

            --Start Changes for bug 3083950
            -- The Bug is that the final sum of wieghting percentage of all childs of a task does not summ to 100
            -- Is caused as while dtoring in the database the weighting % is rounding upto 2nd decimal
            -- Strategy here is to store the difference of weighting % we lose or gain while truncating to 2nd decimal
            -- against the parent task id in local table for all its child task and as the sum of difference goes above -0.01
            -- or below -0.01 just increase or decrease the task weightage of the child task being processed by 0.01
            -- SO in this way we will cover the weighting % which we have lost by rounding to 2nd decimal as the loss or gain reaches 0.1
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_task_weight' || l_task_weight;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            l_temp_number := l_task_weight;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_temp_number' || l_temp_number;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            l_diff_number := l_task_weight - l_temp_number;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_diff_number' || l_diff_number;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            IF(l_diff_number <> 0) THEN

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Value of l_parent_element_version_id' || l_parent_element_version_id;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

                 IF l_task_weightage_tbl.exists(l_parent_element_version_id) THEN
                      l_sum_temp_number := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number;

                      IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Value of l_sum_temp_number' || l_sum_temp_number;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                           pa_debug.g_err_stage:= 'Value of l_constant_temp_number' || l_constant_temp_number;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;
                      IF( l_sum_temp_number >= l_constant_temp_number ) THEN
                           l_task_weight := l_task_weight + 0.01;
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number - 0.01;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      ELSIF ( l_sum_temp_number <= -l_constant_temp_number ) THEN
                           l_task_weight := l_task_weight - 0.01;
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number + 0.01;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'In else IF Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      ELSE
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'in else Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      END IF;
                 ELSE
                      l_task_weightage_tbl(l_parent_element_version_id) := l_diff_number;
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Value of task_weightage_tbl' || l_task_weightage_tbl(l_parent_element_version_id);
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

            END IF;

            --End Changes for bug 3083950

            if(abs(l_remaining_weight - l_task_weight) <= .05) then
              l_task_weight := l_remaining_weight;
            end if;

          --END IF; Bug 3098574.
          UPDATE PA_OBJECT_RELATIONSHIPS
          SET weighting_percentage = l_task_weight
          WHERE object_id_from1 = l_parent_element_version_id
          AND   object_id_to1 = l_element_version_id
          AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND   object_type_to = 'PA_TASKS'
          AND   relationship_type = 'S';
        end if;
      end if;
    else
      -- In this case, outline level is > 1
      -- There will never be pre-existing tasks on these levels
      OPEN check_progress_allowed(l_element_version_id);
      FETCH check_progress_allowed INTO l_progress_allowed,l_project_id; /* for bug 2822963 */
      CLOSE check_progress_allowed;

      if l_progress_allowed = 'N' then
        -- Populate task weight as zero
        UPDATE PA_OBJECT_RELATIONSHIPS
        SET weighting_percentage = 0
        WHERE object_id_from1 = l_parent_element_version_id
        AND   object_id_to1 = l_element_version_id
        AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
        AND   object_type_to = 'PA_TASKS'
        AND   relationship_type = 'S';
      else

        if l_durations.exists(l_parent_element_version_id) then
          NULL;
        else
          OPEN get_summed_duration(l_parent_element_version_id);
          FETCH get_summed_duration INTO l_total_duration;
          CLOSE get_summed_duration;

          l_durations(l_parent_element_version_id) := l_total_duration;
        end if;

        OPEN get_task_duration(l_element_version_id,l_project_id);  /* for bug 2822963 */
        FETCH get_task_duration INTO l_task_duration;
        CLOSE get_task_duration;

         -- Bug 3098574. When the summed duration of the child tasks
         -- of a parent is 0, get the number of child tasks and calculate
         -- the weighatage as 1 / number of tasks * 100.
        /*IF (l_durations(l_parent_element_version_id) IS NULL) OR
           (l_durations(l_parent_element_version_id) = 0) THEN
          l_task_weight := 0;
        ELSE*/

         IF (l_durations(l_parent_element_version_id) IS NULL) OR
          (l_durations(l_parent_element_version_id) = 0) THEN
            IF l_prog_child_count.exists(l_parent_element_version_id) THEN
                 l_progressible_child_count := l_prog_child_count(l_parent_element_version_id);
            ELSE
                 OPEN get_progressible_child_count(l_parent_element_version_id);
                 FETCH get_progressible_child_count into l_progressible_child_count;
                 CLOSE get_progressible_child_count;
                 l_prog_child_count(l_parent_element_version_id) := l_progressible_child_count;
            END IF;
            IF l_progressible_child_count  <> 0 THEN
                 l_task_weight := ( 1 / l_progressible_child_count ) * 100;
            ELSE -- This should never occur.
                 l_task_weight := 0;
            END IF;

         ELSE
            l_task_weight := (l_task_duration / l_durations(l_parent_element_version_id)) * 100;
         END IF;

          OPEN get_existing_weights(l_parent_element_version_id);
          FETCH get_existing_weights INTO l_existing_weight;
          CLOSE get_existing_weights;

          l_remaining_weight := 100 - l_existing_weight;
          --l_task_weight := (l_task_duration / l_durations(l_parent_element_version_id)) * 100; Bug 3098574.

            --Start Changes for bug 3083950
            -- The Bug is that the final sum of wieghting percentage of all childs of a task does not summ to 100
            -- Is caused as while dtoring in the database the weighting % is rounding upto 2nd decimal
            -- Strategy here is to store the difference of weighting % we lose or gain while truncating to 2nd decimal
            -- against the parent task id in local table for all its child task and as the sum of difference goes above -0.01
            -- or below -0.01 just increase or decrease the task weightage of the child task being processed by 0.01
            -- SO in this way we will cover the weighting % which we have lost by rounding to 2nd decimal as the loss or gain reaches 0.1

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_task_weight' || l_task_weight;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            l_temp_number := l_task_weight;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_temp_number' || l_temp_number;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            l_diff_number := l_task_weight - l_temp_number;

            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Value of l_diff_number' || l_diff_number;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            IF(l_diff_number <> 0) THEN

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Value of l_parent_element_version_id' || l_parent_element_version_id;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

                 IF l_task_weightage_tbl.exists(l_parent_element_version_id) THEN

                      l_sum_temp_number := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number;

                      IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Value of l_sum_temp_number' || l_sum_temp_number;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

                           pa_debug.g_err_stage:= 'Value of l_constant_temp_number' || l_constant_temp_number;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;

                      IF( l_sum_temp_number >= l_constant_temp_number ) THEN
                           l_task_weight := l_task_weight + 0.01;
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number - 0.01;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      ELSIF ( l_sum_temp_number <= -l_constant_temp_number ) THEN
                           l_task_weight := l_task_weight - 0.01;
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number + 0.01;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'In else IF Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      ELSE
                           l_task_weightage_tbl(l_parent_element_version_id) := l_task_weightage_tbl(l_parent_element_version_id) + l_diff_number;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'in else Value of l_task_weight' || l_task_weight;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                      END IF;
                 ELSE
                      l_task_weightage_tbl(l_parent_element_version_id) := l_diff_number;
                 END IF;

                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Value of task_weightage_tbl' || l_task_weightage_tbl(l_parent_element_version_id);
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

            END IF;
            --End  Changes for bug 3083950

          if(abs(l_remaining_weight - l_task_weight) <= .05) then
            l_task_weight := l_remaining_weight;
          end if;
        --END IF; Bug 3098574.
        UPDATE PA_OBJECT_RELATIONSHIPS
        SET weighting_percentage = l_task_weight
        WHERE object_id_from1 = l_parent_element_version_id
        AND   object_id_to1 = l_element_version_id
        AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
        AND   object_type_to = 'PA_TASKS'
        AND   relationship_type = 'S';
      end if;
    end if;

  end LOOP;

     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                          p_procedure_name => 'CALC_TASK_WEIGHTS',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

  raise;
END CALC_TASK_WEIGHTS;

--   API name                      : Update_Task_Weighting
--   Type                          : Public Procedure
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

  BEGIN

    pa_debug.init_err_stack ('PA_TASK_PUB1.UPDATE_TASK_WEIGHTING');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_WEIGHTING begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_task_weighting;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    PA_TASK_PVT1.Update_Task_Weighting(
     p_object_relationship_id      => p_object_relationship_id
    ,p_weighting_percentage        => p_weighting_percentage
    ,p_record_version_number       => p_record_version_number
    ,x_return_status               => x_return_status
        ,x_msg_count                   => x_msg_count
    ,x_msg_data                    => x_msg_data
    );

EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_weighting;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_weighting;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK_WEIGHTING',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_task_weighting;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'UPDATE_TASK_WEIGHTING',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Update_Task_Weighting;

-- Amit : Following procedure added for Bug 2838700

PROCEDURE INDENT_TASK_VERSION_BULK (
 p_api_version                IN    NUMBER   :=1.0,
 p_init_msg_list              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id       IN    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_project_id             IN    NUMBER,
 p_record_version_number      IN    NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


CURSOR cur_struc_type( c_structure_id NUMBER ) IS
    SELECT 'Y'
    FROM pa_proj_structure_types ppst
        ,pa_structure_types pst
    WHERE ppst.proj_element_id = c_structure_id
    AND ppst.structure_type_id = pst.structure_type_id
    AND pst.structure_type_class_code IN( 'FINANCIAL' );

CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
     SELECT 'Y'
     FROM dual
     WHERE EXISTS(
    SELECT 'xyz'
    FROM pa_proj_elem_ver_structure
    WHERE proj_element_id = c_structure_id
    AND project_id = c_project_id
    AND STATUS_CODE = 'STRUCTURE_PUBLISHED'
        );

CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    SELECT object_id_from1
    FROM pa_object_relationships
    WHERE object_id_to1 = c_elem_ver_id
    AND object_type_to = 'PA_TASKS'
    AND relationship_type = 'S';

CURSOR cur_obj_rel( p_child_version_id NUMBER ) IS
    SELECT object_id_from1
     , object_relationship_id
     , record_version_number
     , relationship_subtype
    FROM pa_object_relationships
    WHERE object_id_to1 = p_child_version_id
    AND relationship_type = 'S';

v_cur_obj_rel_rec cur_obj_rel%ROWTYPE;

CURSOR get_task_weighting(c_task_version_id NUMBER) IS
   SELECT a.object_id_from1
    , a.weighting_percentage
   FROM pa_object_relationships a
   WHERE a.object_id_to1 = c_task_version_id
   AND a.object_type_to = 'PA_TASKS'
   AND a.relationship_type = 'S'
   AND a.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');

CURSOR get_sub_tasks(c_task_version_id NUMBER) IS
   SELECT '1'
   FROM dual
   WHERE EXISTS
       (SELECT  'xyz'
       FROM pa_object_relationships
       WHERE object_id_from1 = c_task_version_id
       AND object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
       AND relationship_type = 'S'
       );

CURSOR check_progress_allowed(c_element_version_id NUMBER) IS
  SELECT ptt.prog_entry_enable_flag
  FROM    pa_task_types ptt
    , pa_proj_element_versions ppev,
          pa_proj_elements ppe
  WHERE  ppev.element_version_id = c_element_version_id
  AND    ppev.proj_element_id = ppe.proj_element_id
  AND    ptt.object_type = 'PA_TASKS'            /* for bug 3279978 FP M Enhancement */
  AND    ppe.TYPE_ID   = ptt.task_type_id;



  l_api_name            CONSTANT VARCHAR(30) := 'INDENT_TASK_VERSION_BULK';
  l_api_version         CONSTANT NUMBER      := 1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(250);
  l_data            VARCHAR2(250);
  l_msg_index_out       NUMBER;

  l_peer_or_sub         VARCHAR2(30);
  l_project_id          NUMBER;
  l_structure_id        NUMBER;
  l_ref_task_id         NUMBER;
  l_task_id                     NUMBER;
  l_task_record_version_number  NUMBER;
  l_wbs_record_version_number   NUMBER;
  l_dummy_char                  VARCHAR2(1);
  l_published_version           VARCHAR2(1);
  l_relationship_subtype        VARCHAR2(20);
  l_struc_version_from          NUMBER;
  l_task_version_from           NUMBER;
  l_version_from        NUMBER;
  l_versioned           VARCHAR2(1) := 'N';
  l_shared          VARCHAR2(1) := 'N';

  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
  l_parent_ver_id       NUMBER;
  l_error_msg_code      VARCHAR2(30);

  src_elem_ver_id       NUMBER;
  src_proj_element_id       NUMBER;
  src_wbs_number        VARCHAR2(240);
  src_seq_number        NUMBER;
  src_wbs_level         NUMBER;
  src_parent_str_ver_id     NUMBER;
  src_object_type       VARCHAR2(30);

  ref_elem_ver_id       NUMBER;
  ref_proj_element_id       NUMBER;
  ref_wbs_number        VARCHAR2(240);
  ref_seq_number        NUMBER;
  ref_wbs_level         NUMBER;
  ref_parent_str_ver_id     NUMBER;
  ref_object_type       VARCHAR2(30);

  l_old_parent_id       NUMBER;
  l_dummy           VARCHAR2(1);

  l_new_weighting       NUMBER(17,2);
  l_old_weighting       NUMBER(17,2);
  l_progress_allowed        VARCHAR2(1);

  l_element_version_id_tab  PA_FORECAST_GLOB.NumberTabTyp;
  l_proj_element_id_tab     PA_FORECAST_GLOB.NumberTabTyp;
  l_object_type_tab     PA_FORECAST_GLOB.VCTabTyp;
  l_project_id_tab      PA_FORECAST_GLOB.NumberTabTyp;
  l_parent_str_version_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
  l_display_sequence_tab    PA_FORECAST_GLOB.NumberTabTyp;
  l_wbs_level_tab       PA_FORECAST_GLOB.NumberTabTyp;
  l_wbs_number_tab      PA_FORECAST_GLOB.VCTabTyp;
  l_record_version_tab      PA_FORECAST_GLOB.NumberTabTyp;
  l_changed_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;

  l_wbs_number          VARCHAR2(1000);
  src_branch_mask       VARCHAR2(1000);
  ref_branch_mask       VARCHAR2(1000);
  l_str1            VARCHAR2(1000);
  l_str2            VARCHAR2(1000);
  l_number          NUMBER;
  l_new_wbs_number      VARCHAR2(1000);
  l_user_id         NUMBER;
  l_login_id            NUMBER;

--bug 2843737
  CURSOR get_ref_parent_id(c_object_id_to1 NUMBER) is
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_object_id_to1
       and relationship_type = 'S';
  l_ref_parent_ver_id          NUMBER;
--end bug 2843737

   CURSOR get_wbs_number(c_elem_ver_id NUMBER) is
    select wbs_number
      from pa_proj_element_versions
     where element_version_id = c_elem_ver_id
     and object_type ='PA_TASKS';

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_cur_project_id      NUMBER;
   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_structure_version_id;

-- end hyau Bug 2852753

-- Merged from 85
--Bug 2947492 ( indent )

l_plannable_tasks_tbl        PA_FP_ELEMENTS_PUB.l_impacted_task_in_tbl_typ;
l_parent_task_id             NUMBER;
l_old_parent_task_id             NUMBER;
l_top_task_id                NUMBER;
l_old_top_task_id            NUMBER;  --bug 2967204

CURSOR get_parent_task_id( c_task_id NUMBER, c_project_id NUMBER ) IS
    SELECT parent_task_id, top_task_id FROM pa_tasks
     WHERE project_id = c_project_id and task_id = c_task_id;

--End Bug 2947492  ( indent )
-- Merged from 85

--bug 3053281
  l_wp_type              VARCHAR2(1);
  l_weighting_basis_Code VARCHAR2(30);
--end bug 3053281

  --3035902: process update flag changes
  cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
  l_task_type_id      NUMBER;
  l_wp_process_flag   VARCHAR2(1);
  --3035902: end process update flag changes

--bug 3069306
  Cursor get_top_task_ver_id(c_task_ver_id NUMBER) IS
    select object_id_to1
      from pa_object_relationships
     where relationshiP_type = 'S'
       and object_type_to = 'PA_TASKS'
             start with object_id_to1 = c_task_ver_id
               and object_type_to = 'PA_TASKS'
               and relationship_type = 'S'
           connect by prior object_id_from1 = object_id_to1
               and prior object_type_from = object_type_to
               and prior relationship_type = relationship_type
 intersect
    select a.object_id_to1
      from pa_object_relationships a, pa_proj_element_versions b
     where a.relationshiP_type = 'S'
       and a.object_id_from1 = b.parent_structure_version_id
       and b.element_version_id = c_task_ver_id
       and a.object_type_from = 'PA_STRUCTURES';
  l_old_par_ver_id NUMBER;
  l_new_par_ver_id NUMBER;
--end bug 3069306

--bug 3301192
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /* l_task_ver_ids2              PA_PLSQL_DATATYPES.IdTabTyp;                     */
  l_task_ver_ids2             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
  l_lowest_task_flag1         VARCHAR2(1);
  l_lowest_task_flag2         VARCHAR2(1);
  l_fin_task_flag             VARCHAR2(1);

  --bug 4214825, start
  l_ref_tsk_version_id      NUMBER;

  CURSOR cur_get_ref_tsk_ver_id(c_src_wbs_level NUMBER) IS
  SELECT element_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE parent_structure_version_id = p_structure_version_id
  AND project_id = p_project_id
  AND wbs_level = c_src_wbs_level
  AND object_type = 'PA_TASKS'
  AND display_sequence < src_seq_number
  AND display_sequence =
        (SELECT max (display_sequence)
         FROM pa_proj_element_versions
         WHERE project_id = p_project_id
         AND parent_structure_version_id = p_structure_version_id
         AND wbs_level = c_src_wbs_level
         AND display_sequence < src_seq_number
         AND object_type = 'PA_TASKS');
  --bug 4214825, end

BEGIN

  pa_debug.init_err_stack ('PA_TASK_PUB1.INDENT_TASK_VERSION_BULK');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_TASK_VERSION_BULK begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint indent_task_version_bulk;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --bug 4075697
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
  --bug 4075697

  --3035902: process update flag changes
  l_wp_process_flag := 'N';
  --3035902: end process update flag changes
-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN cur_proj_id;
        FETCH cur_proj_id INTO l_cur_project_id;
        CLOSE cur_proj_id;

        OPEN get_product_code(l_cur_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );

          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;
      IF l_update_parent_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_MOVE_TASK');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

-- end hyau Bug 2852753

-- Bug 6881272: ABLE TO INDENT THE TASK OF THE WBS WITH THE LINKED PROJECT

  BEGIN
      SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
      INTO src_elem_ver_id, src_proj_element_id, src_wbs_number, src_wbs_level, src_seq_number, src_parent_str_ver_id, src_object_type
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE element_version_id = p_task_version_id
      AND project_id = p_project_id
      AND parent_structure_version_id = p_structure_version_id;
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END;



  IF (p_structure_version_id IS NOT NULL) AND
       (p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
-- Bug 6881272: ABLE TO INDENT THE TASK OF THE WBS WITH THE LINKED PROJECT
    IF (Nvl(pa_relationship_utils.check_task_has_sub_proj(p_project_id
							          , src_proj_element_id
								        , p_task_version_id),'N') = 'Y') THEN
      --deleting linked task. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_IND_LINKED_TASK');
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Get Source Task Information
  BEGIN
      SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
      INTO src_elem_ver_id, src_proj_element_id, src_wbs_number, src_wbs_level, src_seq_number, src_parent_str_ver_id, src_object_type
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE element_version_id = p_task_version_id
      AND project_id = p_project_id
      AND parent_structure_version_id = p_structure_version_id;
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END;

-- Locking should be implemented here

  -- Lifecycle Phase validation Changes. Check if task has phase associated with it
  IF (p_task_version_id IS NOT NULL) AND
       (p_task_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

    IF ('Y' = pa_proj_elements_utils.CHECK_ELEMENT_HAS_PHASE(
              src_proj_element_id)) THEN
      --Indenting a task with phase. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_LC_NO_INDENT_PHASE_TASK');
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  IF src_seq_number = 1 then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_INDENT');
    raise FND_API.G_EXC_ERROR;
  END IF;

  /* Bug 2843737 Added logic to populate the error message when you try to indent lowest task
     Also restructured the logic to get the reference task */

 -- Get the previous task information. If its wbs_level is equal to src_wbs_level then this will become refernce task
 -- Otherwise we will again fetch the correct reference task

  SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
  INTO ref_elem_ver_id, ref_proj_element_id, ref_wbs_number, ref_wbs_level, ref_seq_number,  ref_parent_str_ver_id, ref_object_type
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE display_sequence = src_seq_number - 1
  AND parent_structure_version_id = p_structure_version_id
  AND project_id = p_project_id
  AND object_type = 'PA_TASKS';

  IF src_wbs_level > ref_wbs_level then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_INDENT');
    raise FND_API.G_EXC_ERROR;
  END IF;

  IF src_wbs_level = ref_wbs_level then
    l_peer_or_sub := 'SUB';
    --bug 4214825, start
    l_ref_tsk_version_id := ref_elem_ver_id;
    --bug 4214825, end
  ELSE
    l_peer_or_sub := 'PEER';

    SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
    INTO ref_elem_ver_id, ref_proj_element_id, ref_wbs_number, ref_wbs_level, ref_seq_number,  ref_parent_str_ver_id, ref_object_type
    FROM PA_PROJ_ELEMENT_VERSIONS
    WHERE parent_structure_version_id = p_structure_version_id
    AND project_id = p_project_id
    AND wbs_level = src_wbs_level+1
    AND object_type = 'PA_TASKS'
    AND display_sequence < src_seq_number
     AND display_sequence =
        (SELECT max (display_sequence)
         FROM pa_proj_element_versions
         WHERE project_id = p_project_id
         AND parent_structure_version_id = p_structure_version_id
         AND wbs_level = src_wbs_level+1
         AND display_sequence < src_seq_number
         AND object_type = 'PA_TASKS');

  --bug 4214825, start
  OPEN cur_get_ref_tsk_ver_id(src_wbs_level);
  FETCH cur_get_ref_tsk_ver_id INTO l_ref_tsk_version_id;
  CLOSE cur_get_ref_tsk_ver_id;
  --bug 4214825, end


  END IF;


/* Bug 2843737 -- Commented the code to get the refernec task. It is now being done above
  -- Get Refernce Task Information

  BEGIN
      SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
      INTO ref_elem_ver_id, ref_proj_element_id, ref_wbs_number, ref_wbs_level, ref_seq_number,  ref_parent_str_ver_id, ref_object_type
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE parent_structure_version_id = p_structure_version_id
      AND project_id = p_project_id
      AND (wbs_level = src_wbs_level OR wbs_level = src_wbs_level+1) -- Sub or Peer
          AND object_type = 'PA_TASKS'
      AND display_sequence < src_seq_number
      AND display_sequence =
        (SELECT max (display_sequence)
         FROM pa_proj_element_versions
         WHERE project_id = p_project_id
         AND parent_structure_version_id = p_structure_version_id
         AND (wbs_level = src_wbs_level OR wbs_level = src_wbs_level+1) -- Sub or Peer
         AND display_sequence < src_seq_number
         AND object_type = 'PA_TASKS');
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END;
*/

    --Bug No 3475920 Smukka 25/May/04 Checking for deliverable
    --bug 4214825, pass the correct ref_task_version
    --IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id,ref_elem_ver_id) = 'Y' THEN
    IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id, l_ref_tsk_version_id) = 'Y' THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
       raise FND_API.G_EXC_ERROR;
    END IF;

    --Check if ok to indent this task
    PA_PROJ_ELEMENTS_UTILS.Check_move_task_ok(
         p_task_ver_id => p_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
    );

    IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
    END IF;

    --check if ok to create subtask
    IF (l_peer_or_sub = 'PEER') THEN
      OPEN get_parent_version_id(ref_elem_ver_id);
      FETCH get_parent_version_id into l_parent_ver_id;
      CLOSE get_parent_version_id;

      --bug 3069306
      --if financial task, check if changing parent ok
      IF (PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y') THEN
        OPEN get_top_task_ver_id(l_parent_ver_id);
        FETCH get_top_task_ver_id into l_new_par_ver_id;
        CLOSE get_top_task_ver_id;

        OPEN get_top_task_ver_id(p_task_version_id);
        FETCH get_top_task_ver_id into l_old_par_ver_id;
        CLOSE get_top_task_Ver_id;

        IF (NVL(l_new_par_ver_id, -99) <> NVL (l_old_par_ver_id, -99)) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_CANT_CHANGE_PARENT');
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --end bug 3069306

      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;

      --bug 4099488
      IF PA_RELATIONSHIP_UTILS.check_dependencies_valid(l_parent_ver_id, p_task_version_id) = 'N' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_INV_MOV_TSK_DEP_ERR');
        raise FND_API.G_EXC_ERROR;
      END IF;
      --end bug 4099488
    ELSE
      --bug 3069306
      --if financial task, check if changing parent ok
      IF (PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y') THEN
        OPEN get_top_task_ver_id(ref_elem_ver_id);
        FETCH get_top_task_ver_id into l_new_par_ver_id;
        CLOSE get_top_task_ver_id;

        OPEN get_top_task_ver_id(p_task_version_id);
        FETCH get_top_task_ver_id into l_old_par_ver_id;
        CLOSE get_top_task_Ver_id;

        IF (NVL(l_new_par_ver_id, -99) <> NVL (l_old_par_ver_id, -99)) THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_CANT_CHANGE_PARENT');
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --end bug 3069306


      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => ref_elem_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;

      --bug 4099488
      IF PA_RELATIONSHIP_UTILS.check_dependencies_valid(ref_elem_ver_id, p_task_version_id) = 'N' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_INV_MOV_TSK_DEP_ERR');
        raise FND_API.G_EXC_ERROR;
      END IF;
      --end bug 4099488
    END IF;

  -- Added for FP_M changes. Bug 3305199 : Bhumesh  xxx

  If PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_project_id)
        IN ('SHARE_PARTIAL')
  Then

    PA_TASKS_MAINT_UTILS.CHECK_MOVE_FINANCIAL_TASK_OK (
        p_task_version_id       => p_task_version_id
      , p_ref_task_version_id   => ref_elem_ver_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , x_error_msg_code        => l_error_msg_code);

    IF (x_return_status <> 'S') THEN -- 4275757 : Changed from 'Y' to 'S'
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    End If;
  End If;

  --check the task is a lowest task bug 3301192
  l_lowest_task_flag1 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_version_id );

  -- End of FP_M changes
/*

 The processing done by the followig two calls is made now as plsql table bulk processing

  PA_TASK_PUB1.Update_Task_Version
  ( p_validate_only      => FND_API.G_FALSE,
    p_ref_task_version_id    => l_ref_task_version_id,
    p_peer_or_sub              => l_peer_or_sub,
    p_task_version_id        => p_task_version_id,
    p_record_version_number  => p_record_version_number,
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data );

  PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
  ( p_commit                   => p_commit
   ,p_debug_mode               => p_debug_mode
   ,p_parent_structure_ver_id  => l_parent_structure_version_id
   ,p_task_id                  => p_task_version_id
   ,p_display_seq              => l_display_sequence
   ,p_action                   => 'INDENT'
   ,p_parent_task_id           => NULL
   ,x_return_status            => l_return_status );

*/


/*** The following part should do the same task as done by PA_TASK_PUB1.Update_Task_Version and Update_wbs_numbers ***/

-- Logic Added for plsql table
-- Basically earlier this was done thru update_task_version and update_wbs_numbers

l_element_version_id_tab.delete;
l_proj_element_id_tab.delete;
l_object_type_tab.delete;
l_project_id_tab.delete;
l_parent_str_version_id_tab.delete;
l_display_sequence_tab.delete;
l_wbs_level_tab.delete;
l_wbs_number_tab.delete;
l_record_version_tab.delete;
l_changed_flag_tab.delete;

If (l_peer_or_sub = 'SUB') THEN
  OPEN get_ref_parent_id(ref_elem_ver_id);
  FETCH get_ref_parent_id into l_ref_parent_ver_id;
  CLOSE get_ref_parent_id;
ELSE
  OPEN get_ref_parent_id(p_task_version_id);
  FETCH get_ref_parent_id into l_ref_parent_ver_id;
  CLOSE get_ref_parent_id;
END IF;

  BEGIN
       -- Using OR is beneficial than using UNION here

            SELECT  element_version_id, proj_element_id, object_type,
            project_id, parent_structure_version_id,
            display_sequence, wbs_level, wbs_number,
            record_version_number, 'N' changed_flag
             BULK COLLECT INTO l_element_version_id_tab,
            l_proj_element_id_tab, l_object_type_tab,
            l_project_id_tab, l_parent_str_version_id_tab,
            l_display_sequence_tab, l_wbs_level_tab,
            l_wbs_number_tab, l_record_version_tab,
            l_changed_flag_tab
            FROM
        pa_proj_element_versions
        WHERE
                 project_id = p_project_id
        AND parent_structure_version_id = p_structure_version_id
        AND object_type = 'PA_TASKS'
        AND(
        element_version_id = p_task_version_id  -- Source task itself
        OR (element_version_id IN -- All tasks below the source task with wbs_level >= src_wbs_level-1
        (select object_id_to1
        from pa_object_relationships
        where relationship_type = 'S'
                and object_type_to = 'PA_TASKS'
        start with object_id_from1 = l_ref_parent_ver_id
        connect by object_id_from1 = PRIOR object_id_to1
                    and relationship_type = PRIOR relationship_type
                    and relationship_type = 'S')
        )
        and display_sequence > src_seq_number)
        ORDER BY display_sequence ;
  EXCEPTION
    WHEN OTHERS THEN
        raise;
  END;


-- For now we are updating wbs_level and wbs_number in seprate loops. It can be combined later on
-- Here we can also incorporate sequence number update. In indent sequence number does not change.

-- Update wbs level

 FOR j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST LOOP
        IF l_element_version_id_tab(j) = src_elem_ver_id THEN
            l_wbs_level_tab(j) := l_wbs_level_tab(j) + 1;
            l_changed_flag_tab(j) := 'Y';
        ELSIF (l_display_sequence_tab(j) > src_seq_number) AND (l_wbs_level_tab(j) > src_wbs_level) THEN
            -- Direct Childs of source
            l_wbs_level_tab(j) := l_wbs_level_tab(j) + 1;
            l_changed_flag_tab(j) := 'Y';
        ELSIF (l_display_sequence_tab(j) > src_seq_number) AND (l_wbs_level_tab(j) <= src_wbs_level) THEN
            -- Exit level changes, IT means no Direct childs are left
            EXIT;
        END IF;
 END LOOP;


-- Update wbs_number

 src_branch_mask := src_wbs_number;

 -- ref_branch_mask shd be the wbs_number of parent of source
 --ref_branch_mask := substr(ref_wbs_number, 1, instr(ref_wbs_number,'.', -1, 1)-1);

 OPEN get_wbs_number(l_ref_parent_ver_id);
 FETCH get_wbs_number into ref_branch_mask;
 CLOSE get_wbs_number;



 FOR j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST LOOP
        IF l_element_version_id_tab(j) = src_elem_ver_id THEN
        IF l_peer_or_sub = 'SUB' THEN
                l_wbs_number := ref_wbs_number || '.1';
            l_wbs_number_tab(j) := l_wbs_number;
            l_changed_flag_tab(j) := 'Y';
            l_new_wbs_number := l_wbs_number;
        ELSE
              l_number := instr(ref_wbs_number,'.', -1, 1);
              l_str1 := substr(ref_wbs_number, 1, l_number -1);
              l_str2 := substr(ref_wbs_number, l_number + 1);
              l_str2 := to_char(to_number(l_str2 + 1));
              l_wbs_number := l_str1 || '.' || l_str2;
              l_wbs_number_tab(j) := l_wbs_number;
              l_changed_flag_tab(j) := 'Y';
              l_new_wbs_number := l_wbs_number;
        END IF;
    ELSE -- IF l_element_version_id_tab(j) <> src_elem_ver_id AND l_display_sequence_tab(j) > src_seq_number THEN
        IF l_display_sequence_tab(j) > src_seq_number THEN
        IF src_wbs_level = 1 THEN -- This was top task
              IF((substr(l_wbs_number_tab(j), 1, length(src_branch_mask)) = src_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(src_branch_mask)+1, 1) = '.')) THEN
            -- Direct childs of source
                  l_number := instr(l_wbs_number_tab(j), src_branch_mask, 1, 1);
              l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                  l_str2 := substr(l_wbs_number_tab(j), length(src_branch_mask)+l_number);
              l_wbs_number := l_str1 || l_new_wbs_number || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              ELSIF(instr(l_wbs_number_tab(j), '.') <> 0) then
            -- Not in Direct Childs, But lower tasks
                  l_str1 := substr(l_wbs_number_tab(j), 1, instr(l_wbs_number_tab(j), '.') - 1);
                  l_str2 := substr(l_wbs_number_tab(j), instr(l_wbs_number_tab(j), '.'));
                  l_str1 := to_char(to_number(l_str1) - 1);
                  l_wbs_number := l_str1 || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              ELSIF (instr(l_wbs_number_tab(j), '.') = 0) then
                  l_wbs_number := to_char(to_number(l_wbs_number_tab(j)) - 1);
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              END IF;
        ELSE -- src_wbs_level <> 1 Source was not a Top Task
              IF((substr(l_wbs_number_tab(j), 1, length(src_branch_mask)) = src_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(src_branch_mask)+1, 1) = '.')) THEN
            -- Direct childs of source
                  l_number := instr(l_wbs_number_tab(j), src_branch_mask, 1, 1);
              l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                  l_str2 := substr(l_wbs_number_tab(j), length(src_branch_mask)+l_number);
              l_wbs_number := l_str1 || l_new_wbs_number || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              ELSE
                      l_str1 := substr(l_wbs_number_tab(j), length(ref_branch_mask) + 2);
                  IF(instr(l_str1, '.') <> 0) THEN
                    l_str2 := substr(l_str1, instr(l_str1, '.'));
                    l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
                    l_str1 := to_char(to_number(l_str1) - 1);
                    l_wbs_number := ref_branch_mask || '.' || l_str1 || l_str2;
                    l_wbs_number_tab(j) := l_wbs_number;
                    l_changed_flag_tab(j) := 'Y';
                  ELSE
                    l_str1:= to_char(to_number(l_str1) - 1);
                    l_wbs_number := ref_branch_mask || '.' || l_str1;
                    l_wbs_number_tab(j) := l_wbs_number;
                    l_changed_flag_tab(j) := 'Y';
             END IF;
              END IF;
        END IF; -- src_wbs_level = 1
        END IF; --   l_display_sequence_tab(j) > src_seq_number
    END IF; -- l_element_version_id_tab(j) = src_elem_ver_id
 END LOOP;
l_user_id := fnd_global.user_id;
l_login_id := fnd_global.login_id;

-- Locking should be implemnted here

 FORALL j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST
 UPDATE PA_PROJ_ELEMENT_VERSIONS
 SET
        wbs_level                = l_wbs_level_tab(j)           ,
        wbs_number                   = l_wbs_number_tab(j)          ,
        last_update_date                 = sysdate          ,
        last_updated_by                  = l_user_id            ,
        last_update_login                = l_login_id           ,
    record_version_number        = l_record_version_tab(j)+1
 WHERE  element_version_id         = l_element_version_id_tab(j)
 AND l_changed_flag_tab(j)='Y';


-- Update Relationship

      IF ref_object_type = 'PA_TASKS'
      THEN
         IF l_peer_or_sub = 'PEER'
         THEN
            OPEN cur_obj_rel( ref_elem_ver_id );
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
         ELSE -- l_peer_or_sub = 'SUB'
                --parent task is the reference task
            l_task_version_from  := ref_elem_ver_id;
            l_struc_version_from := null;
            l_relationship_subtype := 'TASK_TO_TASK';


         END IF;
      END IF; -- ref_object_type = 'PA_TASKS'
      -- No need to check for PA_STRUCTURES as this is indent and you can not indent below a structure


 --update relatonship of the task version p_task_version.
 --set structure_version_from and task_version_from accordingly.
 OPEN cur_obj_rel( p_task_version_id );
 FETCH cur_obj_rel INTO v_cur_obj_rel_rec;
 CLOSE cur_obj_rel;

--for task weighting
 OPEN get_task_weighting(p_task_version_id);
 FETCH get_task_weighting into l_old_parent_id, l_old_weighting;
 CLOSE get_task_weighting;


 IF(l_task_version_from is not null) THEN
   l_version_from := l_task_version_from;
 ELSE
   l_version_from := l_struc_version_from;
 END IF;

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


/*** End Update_task_version and Update_wbs_number code ***/

  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = p_task_version_id )
     AND object_type = 'PA_STRUCTURES';


  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;


      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);

      l_fin_task_flag := PA_Proj_Elements_Utils.CHECK_IS_FINANCIAL_TASK(src_proj_element_id); --indent in corresponding task in pa_tasks

      IF (NVL( l_published_version, 'N' ) = 'N' AND l_fin_task_flag = 'Y' ) OR
         (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y' AND l_fin_task_flag = 'Y' )
	OR ((l_published_version = 'Y') AND (l_shared = 'N') AND (l_fin_task_flag = 'Y')) -- Bug # 5064340. -- To accomodate split financial tasks.
        THEN

          SELECT ppev.proj_element_id, pt.record_version_number, ppa.wbs_record_version_number, ppev.project_id
            INTO l_task_id, l_task_record_version_number, l_wbs_record_version_number, l_project_id
            FROM PA_TASKS pt,
                 pa_proj_elem_ver_structure ppa,
                 PA_PROJ_ELEMENT_VERSIONS ppev
           WHERE ppev.element_version_id = p_task_version_id
             AND ppev.parent_structure_version_id = ppa.element_version_id
             AND ppev.project_id = ppa.project_id
             AND ppev.proj_element_id = pt.task_id;

-- Merged from 85
           SELECT record_version_number, parent_task_id    --get old parent id for bug 2947492 (indent )
                 ,top_task_id          --bug 2967204
            INTO l_task_record_version_number, l_old_parent_task_id
                 ,l_old_top_task_id    --bug 2967204
            FROM pa_tasks
           WHERE task_id = l_task_id
             AND project_id = l_project_id;
-- Merged from 85


          PA_TASKS_MAINT_PUB.Edit_Task_Structure(
                         p_project_id                        => l_project_id
                        ,p_task_id                           => l_task_id
                        ,p_edit_mode                         => 'INDENT'
                        ,p_record_version_number             => l_task_record_version_number
                        ,p_wbs_record_version_number         => 1
                        ,x_return_status                     => l_return_status
                        ,x_msg_count                         => l_msg_count
                        ,x_msg_data                          => l_msg_data );

-- Merged from 85
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

          --Bug 2947492   ( Indent )
          --

            OPEN get_parent_task_id( l_task_id , l_project_id );
            FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id;
            CLOSE get_parent_task_id;

            --bug 2967204
            --Cannot move out of the current hierarchy
              IF NVL( l_top_task_id, -99 ) <> NVL( l_old_top_task_id, -99 )
              THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name => 'PA_CANT_CHANGE_PARENT');
                  raise FND_API.G_EXC_ERROR;
              END IF;
            --End bug 2967204

            --First call the check_reparent ok
            --This should have been called in the beginning but due to lot of complexity involved in getting
            --new parent task id it is decided to call this later stage as long as  we rollback the whole operation
            --if there is any error occurred. This was decided in meeting with me , Hubert and Sakthi.

            /*PA_FIN_PLAN_UTILS.CHECK_REPARENT_TASK_OK(
                     p_task_id                    => l_task_id
                    ,p_old_parent_task_id         => l_old_parent_task_id
                    ,p_new_parent_task_id         => l_parent_task_id
                    ,x_return_status              => l_return_status
                    ,x_msg_count                  => l_msg_count
                    ,x_msg_data                   => l_msg_data
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
             */  --commenting out. check mails form Venkatesh Jayaraman dated 22 Jan 04

/* Commenting out the call to MAINTAIN_PLANNABLE_TASKS for bug 3010538
            l_plannable_tasks_tbl(1).impacted_task_id   := l_task_id;
            l_plannable_tasks_tbl(1).action             := 'REPARENT';
            l_plannable_tasks_tbl(1).old_parent_task_id := l_old_parent_task_id;
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
bug 3010538 */

          --End Bug 2947492  ( Indent )

      END IF;
  END IF;
  CLOSE cur_struc_type;
-- Merged from 85

  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y' then

    -- Added for FP_M changes Bug 3305199 : Bhumesh
    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(P_Project_ID) = 'Y' Then

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

    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := p_task_version_id;

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
       raise FND_API.G_EXC_ERROR;
     end if;

--hsiu added for task status
--if versioning is off, rollup.
     IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,p_element_version_id => p_task_version_id
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
         raise FND_API.G_EXC_ERROR;
       end if;
     END IF;

--end task status changes

  END IF;

--bug 3010538 (Indent)

--bug 3053281 --set flag if not (manual and workplan only)
l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(p_project_id);

/*
IF (l_shared = 'N') AND
   (l_wp_type = 'Y') AND
   (l_weighting_basis_Code = 'MANUAL') THEN
  --do not set the flag to 'Y'
  NULL;
ELSE
*/
  --3035902: process update flag changes
  OPEN get_task_type_id(src_proj_element_id);
  FETCH get_task_type_id INTO l_task_type_id;
  CLOSE get_task_type_id;

  --set update process flag if necessary;
  IF (l_wp_process_flag = 'N') THEN
    --may need to update process flag
    IF ((l_shared = 'N') AND
        (l_wp_type = 'Y') AND
        (pa_task_type_utils.check_tk_type_progressable(l_task_type_id)='Y') AND
        (l_weighting_basis_code <> 'MANUAL'))
    THEN
      --split and workplan; only update if progressable task added
      l_wp_process_flag := 'Y';
    ELSIF ((l_shared = 'N') AND
           (l_wp_type = 'N')) THEN
      --split and financial; update
      l_wp_process_flag := 'Y';
    ELSIF (l_shared = 'Y') THEN
      l_wp_process_flag := 'Y';
    END IF;
  END IF;

  IF (l_wp_process_flag = 'Y') THEN
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => p_project_id
     ,p_structure_version_id  => p_structure_version_id
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
END IF;
  --3035902: end process update flag changes

  --ideally the following calls should have been cached. but due to time constraints
  --we need to write the code this way in multiple places.
  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y'
   THEN
       IF ( l_versioned = 'N' ) OR ( l_versioned = 'Y' and l_shared = 'Y' and  l_published_version = 'N' ) THEN
       --Indent
       pa_fp_refresh_elements_pub.set_process_flag_proj(
             p_project_id               => p_project_id
            ,p_request_id               => null
            ,p_process_code             => null
            ,p_refresh_required_flag    => 'Y'
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data );

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
      END IF;
   END IF;

--End bug 3010538 (Indent )

--bug 3301192
   --check the task is a lowest task again and check whehter its no more a lowest task.
  l_lowest_task_flag2 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_version_id );

  IF l_lowest_task_flag1 = 'Y' AND
     l_lowest_task_flag2 = 'N'
  THEN
     IF l_wp_type = 'Y'
     THEN
     --now call call delete planning for task version id.
       l_task_ver_ids2.extend(1); /* Venky */
       l_task_ver_ids2(1) := p_task_version_id;
       /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
       /*moved pa_fp_planning_transaction_pub.delete_planning_transactions into plsql block        */
       DECLARE
           --p1 bug 3888432
           l_assign_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
           CURSOR get_assignment_id(c_task_ver_id NUMBER) IS
             SELECT resource_assignment_id
               FROM pa_resource_assignments
              WHERE wbs_element_Version_id = c_task_ver_id
                AND ta_display_flag = 'N';
           l_assign_id    NUMBER := NULL;
       BEGIN
           OPEN get_assignment_id(p_task_version_id);
           FETCH get_assignment_id into l_assign_id;
           CLOSE get_assignment_id;

           IF (l_assign_id IS NOT NULL) THEN
             l_assign_ids.extend(1);
             l_assign_ids(1) := l_assign_id;
             pa_fp_planning_transaction_pub.delete_planning_transactions
             (
               p_context                      => 'WORKPLAN'
              ,p_task_or_res                  => 'ASSIGNMENT'
---            ,p_element_version_id_tbl       => l_task_ver_ids2
---         ,p_maintain_reporting_lines     => 'Y'
              ,p_resource_assignment_tbl => l_assign_ids
              ,x_return_status                => l_return_status
              ,x_msg_count                    => l_msg_count
              ,x_msg_data                     => l_msg_data
             );
           END IF;
       EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                        p_procedure_name => 'INDENT_TASK_VERSION_BULK',
                                        p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.delete_planning_transactions:'||SQLERRM,1,240));
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
     END IF;  --<<l_wp_type>>
  END IF; --<<l_lowest_task_flag1>>

  --bug 4149392
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := NULL;
  --end bug 4149392

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_TASK_VERSION_BULK END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_TASK_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_TASK_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END Indent_Task_Version_Bulk;

-- Amit : Following procedure added for Bug 2838700

PROCEDURE OUTDENT_TASK_VERSION_BULK (
 p_api_version                IN    NUMBER   :=1.0,
 p_init_msg_list              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id       IN    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_project_id             IN    NUMBER,
 p_record_version_number      IN    NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


CURSOR cur_struc_type( c_structure_id NUMBER ) IS
    SELECT 'Y'
    FROM pa_proj_structure_types ppst
        ,pa_structure_types pst
    WHERE ppst.proj_element_id = c_structure_id
    AND ppst.structure_type_id = pst.structure_type_id
    AND pst.structure_type_class_code IN( 'FINANCIAL' );

CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
     SELECT 'Y'
     FROM dual
     WHERE EXISTS(
    SELECT 'xyz'
    FROM pa_proj_elem_ver_structure
    WHERE proj_element_id = c_structure_id
    AND project_id = c_project_id
    AND STATUS_CODE = 'STRUCTURE_PUBLISHED'
        );

CURSOR get_parent_version_id(c_elem_ver_id NUMBER) IS
    SELECT object_id_from1
    FROM pa_object_relationships
    WHERE object_id_to1 = c_elem_ver_id
    AND object_type_to = 'PA_TASKS'
    AND relationship_type = 'S';

CURSOR cur_obj_rel( p_child_version_id NUMBER ) IS
    SELECT object_id_from1
     , object_relationship_id
     , record_version_number
     , relationship_subtype
    FROM pa_object_relationships
    WHERE object_id_to1 = p_child_version_id
    AND relationship_type = 'S';

v_cur_obj_rel_rec cur_obj_rel%ROWTYPE;

CURSOR get_task_weighting(c_task_version_id NUMBER) IS
   SELECT a.object_id_from1
    , a.weighting_percentage
   FROM pa_object_relationships a
   WHERE a.object_id_to1 = c_task_version_id
   AND a.object_type_to = 'PA_TASKS'
   AND a.relationship_type = 'S'
   AND a.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');

CURSOR get_sub_tasks(c_task_version_id NUMBER) IS
   SELECT '1'
   FROM dual
   WHERE EXISTS
       (SELECT  'xyz'
       FROM pa_object_relationships
       WHERE object_id_from1 = c_task_version_id
       AND object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
       AND relationship_type = 'S'
       );

CURSOR check_progress_allowed(c_element_version_id NUMBER) IS
  SELECT ptt.prog_entry_enable_flag
  FROM    pa_task_types ptt
    , pa_proj_element_versions ppev,
          pa_proj_elements ppe
  WHERE  ppev.element_version_id = c_element_version_id
  AND    ppev.proj_element_id = ppe.proj_element_id
  AND    ppe.TYPE_ID   = ptt.task_type_id;

CURSOR get_peer_tasks IS
  SELECT b.object_id_to1 object_id_to1
  FROM    pa_object_relationships a
    , pa_object_relationships b
  WHERE a.object_id_to1 = p_task_version_id
  AND a.object_type_to = 'PA_TASKS'
  AND a.object_id_from1 = b.object_id_from1
  AND a.object_type_from = b.object_type_from
  AND b.object_type_to = 'PA_TASKS'
  AND b.object_id_to1 <> p_task_version_id
  AND a.relationship_type = 'S'
  AND b.relationship_type = 'S';

  c_get_peer_tasks get_peer_tasks%ROWTYPE;

  --This cursor fetches all tasks that are child of ref task but now become child of p_task_version
  -- This case should not be possible for Outdent/Indent
  CURSOR cur_new_child(c_ref_task_version_id NUMBER, c_display_sequence NUMBER) IS
    SELECT por.object_id_to1, ppev.display_sequence, por.record_version_number, por.object_relationship_id
    FROM pa_object_relationships por,
           pa_proj_element_versions ppev
    WHERE object_id_from1 = c_ref_task_version_id
    AND object_id_to1 = element_version_id
    AND display_sequence > c_display_sequence
    AND relationship_type = 'S'
     order by display_sequence;



  l_api_name            CONSTANT VARCHAR(30) := 'OUTDENT_TASK_VERSION_BULK';
  l_api_version         CONSTANT NUMBER      := 1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(250);
  l_data            VARCHAR2(250);
  l_msg_index_out       NUMBER;

  l_peer_or_sub         VARCHAR2(30);
  l_project_id          NUMBER;
  l_structure_id        NUMBER;
  l_ref_task_id         NUMBER;
  l_task_id                     NUMBER;
  l_task_record_version_number  NUMBER;
  l_wbs_record_version_number   NUMBER;
  l_dummy_char                  VARCHAR2(1);
  l_published_version           VARCHAR2(1);
  l_relationship_subtype        VARCHAR2(20);
  l_struc_version_from          NUMBER;
  l_task_version_from           NUMBER;
  l_version_from        NUMBER;
  l_versioned           VARCHAR2(1) := 'N';
  l_shared          VARCHAR2(1) := 'N';
  l_rollup_task_id      NUMBER;

  l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
  l_parent_ver_id       NUMBER;
  l_error_msg_code      VARCHAR2(30);

  src_elem_ver_id       NUMBER;
  src_proj_element_id       NUMBER;
  src_wbs_number        VARCHAR2(240);
  src_seq_number        NUMBER;
  src_wbs_level         NUMBER;
  src_parent_str_ver_id     NUMBER;
  src_object_type       VARCHAR2(30);

  ref_elem_ver_id       NUMBER;
  ref_proj_element_id       NUMBER;
  ref_wbs_number        VARCHAR2(240);
  ref_seq_number        NUMBER;
  ref_wbs_level         NUMBER;
  ref_parent_str_ver_id     NUMBER;
  ref_object_type       VARCHAR2(30);

  l_old_parent_id       NUMBER;
  l_dummy           VARCHAR2(1);

  l_new_weighting       NUMBER(17,2);
  l_old_weighting       NUMBER(17,2);
  l_progress_allowed        VARCHAR2(1);

  l_element_version_id_tab  PA_FORECAST_GLOB.NumberTabTyp;
  l_proj_element_id_tab     PA_FORECAST_GLOB.NumberTabTyp;
  l_object_type_tab     PA_FORECAST_GLOB.VCTabTyp;
  l_project_id_tab      PA_FORECAST_GLOB.NumberTabTyp;
  l_parent_str_version_id_tab   PA_FORECAST_GLOB.NumberTabTyp;
  l_display_sequence_tab    PA_FORECAST_GLOB.NumberTabTyp;
  l_wbs_level_tab       PA_FORECAST_GLOB.NumberTabTyp;
  l_old_wbs_level_tab       PA_FORECAST_GLOB.NumberTabTyp;
  l_wbs_number_tab      PA_FORECAST_GLOB.VCTabTyp;
  l_record_version_tab      PA_FORECAST_GLOB.NumberTabTyp;
  l_changed_flag_tab        PA_FORECAST_GLOB.VC1TabTyp;

  l_wbs_number          VARCHAR2(1000);
  src_branch_mask       VARCHAR2(1000);
  ref_branch_mask       VARCHAR2(1000);
  l_str1            VARCHAR2(1000);
  l_str2            VARCHAR2(1000);
  l_number          NUMBER;
  l_new_wbs_number      VARCHAR2(1000);
  l_user_id         NUMBER;
  l_login_id            NUMBER;
  l_update_new_child_rels   VARCHAR2(1) := 'N';
  first_sub_task_below_src_flag boolean;
  last_sub_task_below_src      VARCHAR2(1000);
  temp_old_branch_mask      VARCHAR2(1000);
  temp_new_branch_mask      VARCHAR2(1000);
  last_sub_task_number      VARCHAR2(1000);

  --bug 2843737
  CURSOR get_ref_parent_id(c_object_id_to1 NUMBER) is
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_object_id_to1
       and relationship_type = 'S';
  l_ref_parent_ver_id          NUMBER;
--end bug 2843737

  CURSOR get_wbs_number(c_elem_ver_id NUMBER) is
    select wbs_number
      from pa_proj_element_versions
     where element_version_id = c_elem_ver_id
     and object_type ='PA_TASKS';

  ref_parent_branch_mask        VARCHAR2(1000);

-- hyau Bug 2852753
   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   l_cur_project_id      NUMBER;
   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_structure_version_id;

-- end hyau Bug 2852753

-- Merged from 85
--Bug 2947492  ( outdent )

l_plannable_tasks_tbl        PA_FP_ELEMENTS_PUB.l_impacted_task_in_tbl_typ;
l_parent_task_id             NUMBER;
l_old_parent_task_id         NUMBER;
l_top_task_id                NUMBER;
l_old_top_task_id            NUMBER;
l_old_wbs_level              NUMBER;
i                            NUMBER;

    CURSOR get_parent_task_id( c_task_id NUMBER, c_project_id NUMBER )
    IS
      SELECT parent_task_id, top_task_id
        FROM pa_tasks
       WHERE project_id = c_project_id
         AND task_id = c_task_id;

    CURSOR cur_new_child_task( c_project_id NUMBER, c_wbs_level NUMBER,
                               c_task_id NUMBER , c_parent_task_id NUMBER )
    IS
      SELECT pt.task_id, pt.top_task_id, pt.parent_task_id
        FROM pa_tasks pt, pa_proj_element_versions ppev
       WHERE pt.wbs_level = c_wbs_level
         AND parent_task_id = c_parent_task_id
         AND pt.project_id = c_project_id
         AND pt.task_id = ppev.proj_element_id
         AND ppev.display_sequence > ( SELECT display_sequence FROM pa_proj_element_versions
                                        WHERE project_id = c_project_id
                                          AND object_type = 'PA_TASKS'
                                          AND proj_element_id = c_task_id );

   --For financial tasks we can directly join with pa_proj-element_version using proj_element_id
   --bcoz this api will be called as long as there is only one version for financial otherwise
   --publishing will take care.

--End Bug 2947492 ( outdent )
-- Merged from 85

--bug 3053281
  l_wp_type              VARCHAR2(1);
  l_weighting_basis_Code VARCHAR2(30);
--end bug 3053281

  --3035902: process update flag changes
  cursor get_task_type_id(c_proj_element_id NUMBER) IS
      select type_id
        from pa_proj_elements
       where proj_element_id = c_proj_element_id;
  l_task_type_id      NUMBER;
  l_wp_process_flag   VARCHAR2(1);
  --3035902: end process update flag changes

--bug 3069306
  Cursor get_top_task_ver_id(c_task_ver_id NUMBER) IS
    select object_id_to1
      from pa_object_relationships
     where relationshiP_type = 'S'
       and object_type_to = 'PA_TASKS'
             start with object_id_to1 = c_task_ver_id
               and object_type_to = 'PA_TASKS'
               and relationship_type = 'S'
           connect by prior object_id_from1 = object_id_to1
               and prior object_type_from = object_type_to
               and prior relationship_type = relationship_type
 intersect
    select a.object_id_to1
      from pa_object_relationships a, pa_proj_element_versions b
     where a.relationshiP_type = 'S'
       and a.object_id_from1 = b.parent_structure_version_id
       and b.element_version_id = c_task_ver_id
       and a.object_type_from = 'PA_STRUCTURES';
  l_old_par_ver_id NUMBER;
  l_new_par_ver_id NUMBER;
--end bug 3069306

--bug 3301192
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /* l_task_ver_ids2              PA_PLSQL_DATATYPES.IdTabTyp;                     */
  l_task_ver_ids2             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
  l_lowest_task_flag1         VARCHAR2(1);
  l_lowest_task_flag2         VARCHAR2(1);
  l_fin_task_flag             VARCHAR2(1);

BEGIN

  pa_debug.init_err_stack ('PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint OUTDENT_task_version_bulk;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --bug 4075697
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';
  --bug 4075697


  --3035902: process update flag changes
  l_wp_process_flag := 'N';
  --3035902: end process update flag changes

-- hyau Bug 2852753
      IF p_calling_module = 'SELF_SERVICE' THEN

        OPEN cur_proj_id;
        FETCH cur_proj_id INTO l_cur_project_id;
        CLOSE cur_proj_id;

        OPEN get_product_code(l_cur_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
         P_ERROR_STACK                    => l_err_stack,
         P_ERROR_STAGE                => l_err_stage );

          IF l_err_code <> 0 THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
          END IF;
      IF l_update_parent_task_allowed = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_MOVE_TASK');
              raise FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

-- end hyau Bug 2852753

  IF (p_structure_version_id IS NOT NULL) AND
       (p_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
    IF ('N' = pa_proj_elements_utils.check_task_in_structure(
          p_structure_version_id,
          p_task_version_id)) THEN
      --deleting linked task. Error
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_OUTD_LINKED_TASK');
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;

--hsiu added, for dates rollup
--need to get peer task before it has been outdented.
  OPEN get_peer_tasks;
  LOOP
    FETCH get_peer_tasks INTO c_get_peer_tasks;
    EXIT WHEN get_peer_tasks%NOTFOUND;
    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := c_get_peer_tasks.object_id_to1;
--added for task status rollup
    l_rollup_task_id := c_get_peer_tasks.object_id_to1;
  END LOOP;
  CLOSE get_peer_tasks;

  -- Get Source Task Information
  BEGIN
      SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
      INTO src_elem_ver_id, src_proj_element_id, src_wbs_number, src_wbs_level, src_seq_number, src_parent_str_ver_id, src_object_type
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE element_version_id = p_task_version_id
      AND project_id = p_project_id
      AND parent_structure_version_id = p_structure_version_id;
  EXCEPTION
    WHEN OTHERS THEN
    raise;
  END;


-- Lifecycle Phase validation Changes should be implemented here

  IF src_wbs_level = 1 then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_OUTDENT');
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- Get Refernce Task Information

  BEGIN
      SELECT element_version_id, proj_element_id, wbs_number, wbs_level, display_sequence, parent_structure_version_id, object_type
      INTO ref_elem_ver_id, ref_proj_element_id, ref_wbs_number, ref_wbs_level, ref_seq_number,  ref_parent_str_ver_id, ref_object_type
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE parent_structure_version_id = p_structure_version_id
      AND project_id = p_project_id
      AND (wbs_level = src_wbs_level-1)
          AND object_type = 'PA_TASKS'
      AND display_sequence =
        (SELECT max (display_sequence)
         FROM pa_proj_element_versions
         WHERE project_id = p_project_id
         AND parent_structure_version_id = p_structure_version_id
         AND (wbs_level = src_wbs_level-1)
         AND display_sequence < src_seq_number
         AND object_type = 'PA_TASKS');
  EXCEPTION
    WHEN OTHERS THEN
    raise;
    -- It will never return NO_DATA_FOUND as there will always at least one task with wbs_level-1
  END;

  IF src_wbs_level < ref_wbs_level then
    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PS_CANNOT_OUTDENT');
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- While Outdenting always the source task will become peer of reference task
  l_peer_or_sub := 'PEER';

  OPEN get_ref_parent_id(ref_elem_ver_id);
  FETCH get_ref_parent_id into l_ref_parent_ver_id;
  CLOSE get_ref_parent_id;

  OPEN get_wbs_number(l_ref_parent_ver_id);
  FETCH get_wbs_number into ref_parent_branch_mask;
  CLOSE get_wbs_number;


/*  IF src_wbs_level = ref_wbs_level then
    l_peer_or_sub := 'SUB';
  ELSE
    l_peer_or_sub := 'PEER';
  END IF;
*/

    -- Bug 8211519 :  Dissallowing 'Outdenting' of a task if the task has a subproject association.
    if (Nvl(pa_relationship_utils.check_task_has_sub_proj(p_project_id
							          , src_proj_element_id
								        , p_task_version_id),'N') = 'Y') then

    	IF (p_debug_mode = 'Y') THEN
         pa_debug.debug('ERROR !!! PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK ');
      END IF;

      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name => 'PA_PS_TASK_HAS_SUB_PROJ');
      raise FND_API.G_EXC_ERROR;

    end if;

    --Check if ok to OUTDENT this task
    PA_PROJ_ELEMENTS_UTILS.Check_move_task_ok(
         p_task_ver_id => p_task_version_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
    );

    IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
    END IF;

    --check if ok to create
    OPEN get_parent_version_id(ref_elem_ver_id);
    FETCH get_parent_version_id into l_parent_ver_id;
    CLOSE get_parent_version_id;

    --bug 3069306
    --if financial task, check if changing parent ok
    IF (PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y') THEN
      OPEN get_top_task_ver_id(l_parent_ver_id);
      FETCH get_top_task_ver_id into l_new_par_ver_id;
      CLOSE get_top_task_ver_id;

      OPEN get_top_task_ver_id(p_task_version_id);
      FETCH get_top_task_ver_id into l_old_par_ver_id;
      CLOSE get_top_task_Ver_id;

      IF (NVL(l_new_par_ver_id, -99) <> NVL (l_old_par_ver_id, -99)) THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_CANT_CHANGE_PARENT');
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --end bug 3069306

    PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
         p_parent_task_ver_id => l_parent_ver_id
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_msg_code
      );

      IF (l_return_status <> 'Y') THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => l_error_msg_code);
        raise FND_API.G_EXC_ERROR;
      END IF;

  -- Added for FP_M changes. Bug 3305199 : Bhumesh  xxx

  If PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_project_id)
        IN ('SHARE_PARTIAL')
  Then

    PA_TASKS_MAINT_UTILS.CHECK_MOVE_FINANCIAL_TASK_OK (
        p_task_version_id       => p_task_version_id
      , p_ref_task_version_id   => ref_elem_ver_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , x_error_msg_code        => l_error_msg_code);

--    IF (x_return_status <> 'Y') THEN  --Bug 3831786 Commented
    IF (x_return_status <> 'S') THEN    --Bug 3831786 Added
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => l_error_msg_code);
      raise FND_API.G_EXC_ERROR;
    End If;
  End If;

  --check the task is a lowest task bug 3301192
  l_lowest_task_flag1 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_version_id );

  -- End of FP_M changes

/*

 The processing done by the followig two calls is made now as plsql table bulk processing

  PA_TASK_PUB1.Update_Task_Version
  ( p_validate_only          => FND_API.G_FALSE,
    p_ref_task_version_id    => l_ref_task_version_id,
    p_peer_or_sub            => 'PEER',
    p_task_version_id        => p_task_version_id,
    p_record_version_number  => p_record_version_number,
    p_action                 => 'OUTDENT',
    x_return_status          => l_return_status,
    x_msg_count              => l_msg_count,
    x_msg_data               => l_msg_data );

  PA_PROJ_ELEMENTS_UTILS.UPDATE_WBS_NUMBERS
  ( p_commit                   => p_commit
   ,p_debug_mode               => p_debug_mode
   ,p_parent_structure_ver_id  => l_parent_structure_version_id
   ,p_task_id                  => p_task_version_id
   ,p_display_seq              => l_display_sequence
   ,p_action                   => 'OUTDENT'
   ,p_parent_task_id           => NULL
   ,x_return_status            => l_return_status );

*/


/*** The following part should do the same task as done by PA_TASK_PUB1.Update_Task_Version and Update_wbs_numbers ***/

-- Logic Added for plsql table
-- Basically earlier this was done thru update_task_version and update_wbs_numbers

l_element_version_id_tab.delete;
l_proj_element_id_tab.delete;
l_object_type_tab.delete;
l_project_id_tab.delete;
l_parent_str_version_id_tab.delete;
l_display_sequence_tab.delete;
l_wbs_level_tab.delete;
l_old_wbs_level_tab.delete;
l_wbs_number_tab.delete;
l_record_version_tab.delete;
l_changed_flag_tab.delete;

  BEGIN
            SELECT  distinct element_version_id, proj_element_id, object_type,
            project_id, parent_structure_version_id,
            display_sequence, wbs_level, wbs_number,
            record_version_number, 'N' changed_flag
             BULK COLLECT INTO l_element_version_id_tab,
            l_proj_element_id_tab, l_object_type_tab,
            l_project_id_tab, l_parent_str_version_id_tab,
            l_display_sequence_tab, l_wbs_level_tab,
            l_wbs_number_tab, l_record_version_tab,
            l_changed_flag_tab
            FROM
        pa_proj_element_versions
        WHERE
                 project_id = p_project_id
        AND parent_structure_version_id = p_structure_version_id
        AND object_type = 'PA_TASKS'
        AND(
        element_version_id = p_task_version_id  -- Source task itself
        OR element_version_id IN -- All tasks below the source task
        (select object_id_to1
        from pa_object_relationships
        where relationship_type = 'S'
                and object_type_to = 'PA_TASKS'
        start with object_id_from1 = l_ref_parent_ver_id
        connect by object_id_from1 = PRIOR object_id_to1
                    and relationship_type = prior relationship_type
                    and relationship_type = 'S')
        )
        ORDER BY display_sequence ;
            l_old_wbs_level_tab := l_wbs_level_tab;
  EXCEPTION
    WHEN OTHERS THEN
        raise;
  END;

--bug 4214825, commented out this code as this validation is not required in case of outdent
/*--bug 3475920
--Need loop to check all new subtasks and see if ok (for deliverable type task)
  FOR j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST LOOP
    --check if moving to subtask ok
    IF (l_element_version_id_tab(j) <> p_task_version_id) Then
      IF PA_PROJ_ELEMENTS_UTILS.check_deliv_in_hierarchy(p_task_version_id, l_element_version_id_tab(j)) = 'Y' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_PS_CHK_DELIV_UPDATE');
        raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;
--end bug 3475920*/


-- For now we are updating wbs_level and wbs_number in seprate loops. It can be combined later on
-- Here we can also incorporate sequence number update. In OUTDENT sequence number does not change.

-- Update wbs level

 FOR j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST LOOP
        IF l_element_version_id_tab(j) = src_elem_ver_id THEN
            l_wbs_level_tab(j) := l_wbs_level_tab(j) - 1;
            l_changed_flag_tab(j) := 'Y';
        ELSIF (l_display_sequence_tab(j) > src_seq_number) AND (l_wbs_level_tab(j) > src_wbs_level) THEN
            -- Direct Childs of source
            l_wbs_level_tab(j) := l_wbs_level_tab(j) - 1;
            l_changed_flag_tab(j) := 'Y';
        ELSIF (l_display_sequence_tab(j) > src_seq_number) AND (l_wbs_level_tab(j) <= src_wbs_level) THEN
            -- Exit level changes, IT means no Direct childs are left
            EXIT;
        END IF;
 END LOOP;


-- Update wbs_number


 src_branch_mask := src_wbs_number;
 ref_branch_mask := ref_wbs_number;
 first_sub_task_below_src_flag := false;


 FOR j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST LOOP
        IF l_element_version_id_tab(j) = src_elem_ver_id THEN
        IF src_wbs_level = 2 THEN -- This is going to be a top task
            l_wbs_number := to_char(to_number(ref_wbs_number)+1);
                l_wbs_number_tab(j) := l_wbs_number;
                l_changed_flag_tab(j) := 'Y';
                l_new_wbs_number := l_wbs_number;
        ELSE
              l_number := instr(ref_wbs_number,'.', -1, 1);
              l_str1 := substr(ref_wbs_number, 1, l_number -1);
              l_str2 := substr(ref_wbs_number, l_number + 1);
              l_str2 := to_char(to_number(l_str2 + 1));
              l_wbs_number := l_str1 || '.' || l_str2;
              l_wbs_number_tab(j) := l_wbs_number;
              l_changed_flag_tab(j) := 'Y';
              l_new_wbs_number := l_wbs_number;
        END IF;
    ELSE -- IF l_element_version_id_tab(j) <> src_elem_ver_id AND l_display_sequence_tab(j) > src_seq_number THEN
        IF l_display_sequence_tab(j) > src_seq_number THEN
        IF src_wbs_level = 2 THEN -- Source is going to be a top task
              IF((substr(l_wbs_number_tab(j), 1, length(src_branch_mask)) = src_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(src_branch_mask)+1, 1) = '.')) THEN
            -- Direct childs of source
                  l_number := instr(l_wbs_number_tab(j), src_branch_mask, 1, 1);
              l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                  l_str2 := substr(l_wbs_number_tab(j), length(src_branch_mask)+l_number);
              l_wbs_number := l_str1 || l_new_wbs_number || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              IF l_old_wbs_level_tab(j) = src_wbs_level+1 THEN
                first_sub_task_below_src_flag := true;
                last_sub_task_below_src := l_wbs_number;
              END IF;
              ELSIF((substr(l_wbs_number_tab(j), 1, length(ref_branch_mask)) = ref_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(ref_branch_mask)+1, 1) = '.')) THEN
              IF first_sub_task_below_src_flag = false THEN
                  l_wbs_number := l_new_wbs_number || '.1';
                  first_sub_task_below_src_flag := true;
                  last_sub_task_below_src := l_wbs_number;
                  temp_old_branch_mask := l_wbs_number_tab(j);
                  temp_new_branch_mask := l_wbs_number;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              ELSE
                IF (l_old_wbs_level_tab(j) = src_wbs_level) THEN
                      l_str1 := substr(last_sub_task_below_src, length(l_new_wbs_number) + 2);
                  l_str1 := to_char(to_number(l_str1 + 1));
                  l_wbs_number := l_new_wbs_number || '.' || l_str1;
                  temp_old_branch_mask := l_wbs_number_tab(j);
                  temp_new_branch_mask := l_wbs_number;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
                  last_sub_task_below_src := l_wbs_number;
                ELSE
                      l_number := instr(l_wbs_number_tab(j), temp_old_branch_mask, 1, 1);
                  l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                      l_str2 := substr(l_wbs_number_tab(j), length(temp_old_branch_mask)+l_number);
                  l_wbs_number := l_str1 || temp_new_branch_mask || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
                                END IF;
              END IF;
              ELSE
                 IF(instr(l_wbs_number_tab(j), '.') <> 0) then
                 l_str1 := substr(l_wbs_number_tab(j), 1, instr(l_wbs_number_tab(j), '.') - 1);
                 l_str2 := substr(l_wbs_number_tab(j), instr(l_wbs_number_tab(j), '.'));
                 l_str1 := to_char(to_number(l_str1) + 1);
                         l_wbs_number := l_str1 || l_str2;
                 l_wbs_number_tab(j) := l_wbs_number;
                 l_changed_flag_tab(j) := 'Y';
                 ELSE
                     l_wbs_number := to_char(to_number(l_wbs_number_tab(j)) + 1);
                 l_wbs_number_tab(j) := l_wbs_number;
                 l_changed_flag_tab(j) := 'Y';
             END IF;
              END IF;
        ELSE
              IF((substr(l_wbs_number_tab(j), 1, length(src_branch_mask)) = src_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(src_branch_mask)+1, 1) = '.')) THEN
            -- Direct childs of source
                  l_number := instr(l_wbs_number_tab(j), src_branch_mask, 1, 1);
              l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                  l_str2 := substr(l_wbs_number_tab(j), length(src_branch_mask)+l_number);
              l_wbs_number := l_str1 || l_new_wbs_number || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              IF (l_old_wbs_level_tab(j) = src_wbs_level+1) THEN
                first_sub_task_below_src_flag := true;
                last_sub_task_below_src := l_wbs_number;
              END IF;
              ELSIF((substr(l_wbs_number_tab(j), 1, length(ref_branch_mask)) = ref_branch_mask)
                 AND(substr(l_wbs_number_tab(j), length(ref_branch_mask)+1, 1) = '.')) THEN
              IF first_sub_task_below_src_flag = false THEN
                  l_wbs_number := l_new_wbs_number || '.1';
                  first_sub_task_below_src_flag := true;
                  last_sub_task_below_src := l_wbs_number;
                  temp_old_branch_mask := l_wbs_number_tab(j);
                  temp_new_branch_mask := l_wbs_number;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
              ELSE
                IF l_old_wbs_level_tab(j) = src_wbs_level THEN
                      l_str1 := substr(last_sub_task_below_src, length(l_new_wbs_number) + 2);
                  l_str1 := to_char(to_number(l_str1 + 1));
                  l_wbs_number := l_new_wbs_number || '.' || l_str1;
                  temp_old_branch_mask := l_wbs_number_tab(j);
                  temp_new_branch_mask := l_wbs_number;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
                  last_sub_task_below_src := l_wbs_number;
                ELSE
                      l_number := instr(l_wbs_number_tab(j), temp_old_branch_mask, 1, 1);
                  l_str1 := substr(l_wbs_number_tab(j), 1, l_number -1);
                      l_str2 := substr(l_wbs_number_tab(j), length(temp_old_branch_mask)+l_number);
                  l_wbs_number := l_str1 || temp_new_branch_mask || l_str2;
                  l_wbs_number_tab(j) := l_wbs_number;
                  l_changed_flag_tab(j) := 'Y';
                                END IF;
              END IF;
              ELSE
                  l_str1 := substr(l_wbs_number_tab(j), length(ref_parent_branch_mask) + 2);
              IF(instr(l_str1, '.') <> 0) THEN
                l_str2 := substr(l_str1, instr(l_str1, '.'));
                l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
                l_str1 := to_char(to_number(l_str1) + 1);
                l_wbs_number := ref_parent_branch_mask || '.' || l_str1 || l_str2;
                l_wbs_number_tab(j) := l_wbs_number;
                l_changed_flag_tab(j) := 'Y';
              ELSE
                l_str1:= to_char(to_number(l_str1) + 1);
                l_wbs_number := ref_parent_branch_mask || '.' || l_str1;
                l_wbs_number_tab(j) := l_wbs_number;
                l_changed_flag_tab(j) := 'Y';
              END IF;
              END IF;
        END IF;
          END IF;
    END IF;
     END LOOP;


l_user_id := fnd_global.user_id;
l_login_id := fnd_global.login_id;

-- Locking should be implemented here

 FORALL j IN l_element_version_id_tab.FIRST..l_element_version_id_tab.LAST
 UPDATE PA_PROJ_ELEMENT_VERSIONS
 SET
        wbs_level                = l_wbs_level_tab(j)           ,
        wbs_number                   = l_wbs_number_tab(j)          ,
        last_update_date                 = sysdate          ,
        last_updated_by                  = l_user_id            ,
        last_update_login                = l_login_id           ,
    record_version_number        = l_record_version_tab(j)+1
 WHERE  element_version_id         = l_element_version_id_tab(j)
 AND l_changed_flag_tab(j)='Y';


-- Update Relationship

      IF ref_object_type = 'PA_TASKS'
      THEN
         IF l_peer_or_sub = 'PEER'
         THEN
            OPEN cur_obj_rel( ref_elem_ver_id );
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
        -- I don't think so that this is needed. This is not possible in any case
            l_update_new_child_rels := 'Y';

         ELSE -- l_peer_or_sub = 'SUB' Basically this case will not be for OUTDENT
                --parent task is the reference task
            l_task_version_from  := ref_elem_ver_id;
            l_struc_version_from := null;
            l_relationship_subtype := 'TASK_TO_TASK';
         END IF;
     -- The following case is not possible for Indent/Outdent
      ELSIF ref_object_type = 'PA_STRUCTURES'
      THEN
         l_struc_version_from := ref_elem_ver_id;
         l_task_version_from  := null;
         l_relationship_subtype := 'STRUCTURE_TO_TASK';
      END IF; -- ref_object_type = 'PA_TASKS'


 --update relatonship of the task version p_task_version.
 --set structure_version_from and task_version_from accordingly.
 OPEN cur_obj_rel( p_task_version_id );
 FETCH cur_obj_rel INTO v_cur_obj_rel_rec;
 CLOSE cur_obj_rel;

--for task weighting
 OPEN get_task_weighting(p_task_version_id);
 FETCH get_task_weighting into l_old_parent_id, l_old_weighting;
 CLOSE get_task_weighting;


 IF(l_task_version_from is not null) THEN
   l_version_from := l_task_version_from;
 ELSE
   l_version_from := l_struc_version_from;
 END IF;

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

-- I don't think the following code is needed. This case is impossible in case of OUTDENT
     IF l_update_new_child_rels = 'Y' -- AND p_action IN( 'OUTDENT' )
     THEN
        FOR cur_new_child_rec in cur_new_child(ref_elem_ver_id, src_seq_number) LOOP
            OPEN get_sub_tasks(p_task_version_id);
            FETCH get_sub_tasks into l_dummy;
            IF (get_sub_tasks%NOTFOUND) THEN
              l_new_weighting := 100;
            ELSE
              l_new_weighting := 0;
            END IF;
            CLOSE get_sub_tasks;

            --bug 4099488
            IF PA_RELATIONSHIP_UTILS.check_dependencies_valid(p_task_version_id, cur_new_child_rec.object_id_to1) = 'N' THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => 'PA_INV_MOV_TSK_DEP_ERR');
              raise FND_API.G_EXC_ERROR;
            END IF;
            --end bug 4099488

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


/*** End Update_task_version and Update_wbs_number code ***/

  SELECT proj_element_id, project_id INTO l_structure_id, l_project_id
    FROM pa_proj_element_versions
   WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = p_task_version_id )
     AND object_type = 'PA_STRUCTURES';


  --Do financial task check
  --If financial
  OPEN cur_struc_type( l_structure_id );
  FETCH cur_struc_type INTO l_dummy_char;
  IF cur_struc_type%FOUND
  THEN
      --If structure has any published versions.
      l_published_version := 'N';
      OPEN cur_pub_versions( l_structure_id, l_project_id );
      FETCH cur_pub_versions INTO l_published_version;
      CLOSE cur_pub_versions;


      l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                     l_project_id);
      l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_project_id);

--o      IF (NVL( l_published_version, 'N' ) = 'N') OR (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y') THEN
      l_fin_task_flag := PA_Proj_Elements_Utils.CHECK_IS_FINANCIAL_TASK(src_proj_element_id); --outdent in corresponding task in pa_tasks

      IF (NVL( l_published_version, 'N' ) = 'N' AND l_fin_task_flag = 'Y' ) OR
         (l_published_version = 'Y' AND l_versioned = 'N' AND l_shared = 'Y' AND l_fin_task_flag = 'Y' )
	 OR ((l_published_version = 'Y') AND (l_shared = 'N') AND (l_fin_task_flag = 'Y')) -- Bug # 5064340. -- To accomodate split financial tasks.
	 THEN

          SELECT ppev.proj_element_id, pt.record_version_number, ppa.wbs_record_version_number, ppev.project_id
            INTO l_task_id, l_task_record_version_number, l_wbs_record_version_number, l_project_id
            FROM PA_TASKS pt,
                 pa_proj_elem_ver_structure ppa,
                 PA_PROJ_ELEMENT_VERSIONS ppev
           WHERE ppev.element_version_id = p_task_version_id
             AND ppev.parent_structure_version_id = ppa.element_version_id
             AND ppev.project_id = ppa.project_id
             AND ppev.proj_element_id = pt.task_id;

-- Merged from 85
          SELECT record_version_number, parent_task_id, wbs_level    --get old parent id for bug 2947492 (outdent )
                 ,top_task_id
            INTO l_task_record_version_number, l_old_parent_task_id, l_old_wbs_level
                 ,l_old_top_task_id
            FROM pa_tasks
           WHERE task_id = l_task_id
             AND project_id = l_project_id;
-- Merged from 85

-- Merged from 85
          --Bug 2947492 ( outdent )

          --The following cursor will pick those taks that become child tasks of outdenting task
          --which were initially at the same level with display sequence greater than the outdenting task.
/*
          i:= 0;
          FOR  cur_new_child_task_rec in cur_new_child_task( l_project_id, l_old_wbs_level,
                                                             l_task_id, l_old_parent_task_id ) LOOP

            i := i + 1;

            l_plannable_tasks_tbl(i).impacted_task_id   := cur_new_child_task_rec.task_id;
            l_plannable_tasks_tbl(i).action             := 'REPARENT';
            l_plannable_tasks_tbl(i).old_parent_task_id := cur_new_child_task_rec.parent_task_id;
            l_plannable_tasks_tbl(i).New_parent_task_id := l_task_id;
            l_plannable_tasks_tbl(i).top_task_id        := cur_new_child_task_rec.top_task_id;

            --First call the check_reparent ok
            --This should have been called in the beginning but due to lot of complexity involved in getting
            --new parent task id it is decided to call this later stage as long as  we rollback the whole operation
            --if there is any error occurred. This was decided in meeting with me , Hubert and Sakthi.

            PA_FIN_PLAN_UTILS.CHECK_REPARENT_TASK_OK(
                     p_task_id                    => cur_new_child_task_rec.task_id
                    ,p_old_parent_task_id         => cur_new_child_task_rec.parent_task_id
                    ,p_new_parent_task_id         => l_task_id
                    ,x_return_status              => l_return_status
                    ,x_msg_count                  => l_msg_count
                    ,x_msg_data                   => l_msg_data
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
          --End Bug 2947492 ( outdent )
*/  ---commenitng out, please check venkatesh mail dated 22 jan 04

-- Merged from 85

          PA_TASKS_MAINT_PUB.Edit_Task_Structure(
                         p_project_id                        => l_project_id
                        ,p_task_id                           => l_task_id
                        ,p_edit_mode                         => 'OUTDENT'
                        ,p_record_version_number             => l_task_record_version_number
                        ,p_wbs_record_version_number         => 1
                        ,x_return_status                     => l_return_status
                        ,x_msg_count                         => l_msg_count
                        ,x_msg_data                          => l_msg_data );

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

          --Bug 2947492 (outdent )
          --

            OPEN get_parent_task_id( l_task_id , l_project_id );
            FETCH get_parent_task_id INTO l_parent_task_id,l_top_task_id;
            CLOSE get_parent_task_id;

            --bug 2967204
            --Cannot move out of the current hierarchy
              IF NVL( l_top_task_id, -99 ) <> NVL( l_old_top_task_id, -99 )
              THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name => 'PA_CANT_CHANGE_PARENT');
                  raise FND_API.G_EXC_ERROR;
              END IF;
            --End bug 2967204

/*
            --First call the check_reparent ok
            --This should have been called in the beginning but due to lot of complexity involved in getting
            --new parent task id it is decided to call this later stage as long as  we rollback the whole operation
            --if there is any error occurred. This was decided in meeting with me , Hubert and Sakthi.
            PA_FIN_PLAN_UTILS.CHECK_REPARENT_TASK_OK(
                     p_task_id                    => l_task_id
                    ,p_old_parent_task_id         => l_old_parent_task_id
                    ,p_new_parent_task_id         => l_parent_task_id
                    ,x_return_status              => l_return_status
                    ,x_msg_count                  => l_msg_count
                    ,x_msg_data                   => l_msg_data
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
*/  --check venkatesh mail dated 22 jan 04

/* Commenting out the call to MAINTAIN_PLANNABLE_TASKS for bug 3010538
            i := NVL( l_plannable_tasks_tbl.last, 0 ) + 1;

            l_plannable_tasks_tbl(i).impacted_task_id   := l_task_id;
            l_plannable_tasks_tbl(i).action             := 'REPARENT';
            l_plannable_tasks_tbl(i).old_parent_task_id := l_old_parent_task_id;
            l_plannable_tasks_tbl(i).New_parent_task_id := l_parent_task_id;
            l_plannable_tasks_tbl(i).top_task_id        := l_top_task_id;


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
bug 3010538 */

          --End Bug 2947492 (outdent )

      END IF;
  END IF;
  CLOSE cur_struc_type;

-- Added for date rollup; workplan only

  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y' then

    -- Added for FP_M changes Bug 3305199 : Bhumesh
    If PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(P_Project_ID) = 'Y' Then

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

    l_tasks_ver_ids.extend;
    l_tasks_ver_ids(l_tasks_ver_ids.count) := p_task_version_id;

--added for task status rollup
    IF (l_rollup_task_id IS NULL) THEN
      l_rollup_task_id := p_task_version_id;
    END IF;

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
       raise FND_API.G_EXC_ERROR;
     end if;

--if versioning is off, rollup.
     IF ('N' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id)) THEN
       PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
                  p_structure_version_id => p_structure_version_id
                 ,p_element_version_id => l_rollup_task_id
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
         raise FND_API.G_EXC_ERROR;
       end if;
     END IF;

  END IF;

--bug 3010538  ( outdent )
--bug 3053281 --set flag if not (manual and workplan only)
l_wp_type := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(p_project_id);
/*
IF (l_shared = 'N') AND
   (l_wp_type = 'Y') AND
   (l_weighting_basis_Code = 'MANUAL') THEN
  --do not set the flag to 'Y'
  NULL;
ELSE
*/
  --3035902: process update flag changes
  OPEN get_task_type_id(src_proj_element_id);
  FETCH get_task_type_id INTO l_task_type_id;
  CLOSE get_task_type_id;

  --set update process flag if necessary;
  IF (l_wp_process_flag = 'N') THEN
    --may need to update process flag
    IF ((l_shared = 'N') AND
        (l_wp_type = 'Y') AND
        (pa_task_type_utils.check_tk_type_progressable(l_task_type_id)='Y') AND
        (l_weighting_basis_code <> 'MANUAL'))
    THEN
      --split and workplan; only update if progressable task added
      l_wp_process_flag := 'Y';
    ELSIF ((l_shared = 'N') AND
           (l_wp_type = 'N')) THEN
      --split and financial; update
      l_wp_process_flag := 'Y';
    ELSIF (l_shared = 'Y') THEN
      l_wp_process_flag := 'Y';
    END IF;
  END IF;

  --Bug No 3450684 SMukka Commented if condition
  --IF (l_wp_process_flag = 'Y') THEN
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => p_project_id
     ,p_structure_version_id  => p_structure_version_id
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

  --ideally the following calls should have been cached. but due to time constraints
  --we need to write the code this way in multiple places.
  IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y'
   THEN
       IF ( l_versioned = 'N' ) OR ( l_versioned = 'Y' and l_shared = 'Y' and  l_published_version = 'N' ) THEN

       --Outdent
       pa_fp_refresh_elements_pub.set_process_flag_proj(
             p_project_id               => p_project_id
            ,p_request_id               => null
            ,p_process_code             => null
            ,p_refresh_required_flag    => 'Y'
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data );

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
      END IF;
   END IF;

--End bug 3010538  ( outdent )

--bug 3301192
   --check the task is a lowest task again and check whehter its no more a lowest task.
  l_lowest_task_flag2 := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_version_id );

  IF l_lowest_task_flag1 = 'Y' AND
     l_lowest_task_flag2 = 'N'
  THEN
     IF l_wp_type = 'Y'
     THEN
     --now call call delete planning for task version id.
       l_task_ver_ids2.extend(1); /* Venky */
       l_task_ver_ids2(1) := p_task_version_id;
       /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
       /*moved pa_fp_planning_transaction_pub.delete_planning_transactions into plsql block        */
       DECLARE
           --p1 bug 3888432
           l_assign_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
           CURSOR get_assignment_id(c_task_ver_id NUMBER) IS
             SELECT resource_assignment_id
               FROM pa_resource_assignments
              WHERE wbs_element_Version_id = c_task_ver_id
                AND ta_display_flag = 'N';
           l_assign_id    NUMBER := NULL;
       BEGIN
           OPEN get_assignment_id(p_task_version_id);
           FETCH get_assignment_id into l_assign_id;
           CLOSE get_assignment_id;

           IF (l_assign_id IS NOT NULL) THEN
             l_assign_ids.extend(1);
             l_assign_ids(1) := l_assign_id;
             pa_fp_planning_transaction_pub.delete_planning_transactions
             (
             p_context                      => 'WORKPLAN'
            ,p_task_or_res                  => 'ASSIGNMENT'
--          ,p_element_version_id_tbl       => l_task_ver_ids2
--          ,p_maintain_reporting_lines     => 'Y'
            ,p_resource_assignment_tbl => l_assign_ids
            ,x_return_status                => l_return_status
            ,x_msg_count                    => l_msg_count
            ,x_msg_data                     => l_msg_data
             );
           END IF;
       EXCEPTION
           WHEN OTHERS then
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                        p_procedure_name => 'OUTDENT_TASK_VERSION_BULK',
                                        p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.delete_planning_transactions:'||SQLERRM,1,240));
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
     END IF;  --<<l_wp_type>>
  END IF; --<<l_lowest_task_flag1>>
--bug 3301192

  --bug 4149392
  PA_TASK_PUB1.G_CALL_PJI_ROLLUP := NULL;
  --end bug 4149392

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to OUTDENT_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to OUTDENT_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_TASK_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to OUTDENT_task_version_bulk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_TASK_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END OUTDENT_Task_Version_Bulk;

/*
   This API is called from Multiple Tasks Delete Page.
   The API expects the task version id in this fashion
   1. If both parent and child below it is selected for
      deletetion the only parent task id should be pass
      -ed

   2. If top task is selected and child below it is sel
      --ected, API expects only top task id as input

   3. If only child is selected then API expexts only
      child task  id.


 Note :
   Since the self service page expects the error message
   to be displayed in following order :

   Task name (task number) : Proper Error Message ..

   i.e Task name/number  and corresponding error
   message to that task version. in one line

   Both Task Name /Number and error message set as
   token for message PA_PS_TASK_NAME_NUM_ERR

*/

PROCEDURE DELETE_TASK_VERSION_IN_BULK
(p_task_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl   IN  SYSTEM.PA_NUM_TBL_TYPE
,p_structure_version_id        IN  NUMBER
,p_structure_type              IN  VARCHAR2        :='WORKPLAN'   -- 3305199
,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

)

IS
l_debug_mode        VARCHAR2(1) ;
l_element_number    pa_proj_elements.element_number%TYPE ;
l_element_name      pa_proj_elements.name%TYPE ;
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(1);
l_dummy_app_name    VARCHAR2(30);
l_enc_msg_data      VARCHAR2(2000);
l_msg_name          VARCHAR2(30);
l_msg_index_out     NUMBER ;

TYPE l_error_msg_name_tbl_type IS TABLE OF
          fnd_new_messages.message_text%TYPE INDEX BY BINARY_INTEGER ;
TYPE l_element_name_tbl_type IS TABLE OF
          pa_proj_elements.name%TYPE INDEX BY BINARY_INTEGER ;
TYPE l_element_number_tbl_type IS TABLE OF
          pa_proj_elements.element_number%TYPE INDEX BY BINARY_INTEGER ;

l_error_msg_name_tbl l_error_msg_name_tbl_type ;
l_element_name_tbl   l_element_name_tbl_type ;
l_element_number_tbl l_element_number_tbl_type ;
j                  NUMBER ;


BEGIN

    --hsiu: 3604086
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_msg_count := 0;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N') ; -- Bug # 4605505.
    j := 0 ;

--hsiu: commenting out due to p1 issue.
--      savepoint should be issued only when p_commit
--      is true, which is a missing parameter
--    savepoint delete_bulk;

    FOR i in reverse p_task_version_id_tbl.FIRST..p_task_version_id_tbl.LAST LOOP

         IF l_debug_mode = 'Y' THEN
              pa_debug.debug('task id is :'||p_task_version_id_tbl(i));
              pa_debug.debug('record version id is :'||p_record_version_number_tbl(i));
         END IF ;

         -- initialization is required for every loop
         l_return_status := FND_API.G_RET_STS_SUCCESS ;
         l_msg_count := 0 ;
         l_msg_data := null ;



         -- call delete_task_version API
         PA_TASK_PUB1.Delete_Task_Version(p_task_version_id   =>   p_task_version_id_tbl(i)
                                   ,p_record_version_number       =>   p_record_version_number_tbl(i)
                   ,p_structure_type              => p_structure_type
                                   ,x_return_status               =>   l_return_status
                                   ,x_msg_count                   =>   l_msg_count
                                   ,x_msg_data                    =>   l_msg_data
                                   ,p_structure_version_id        =>   p_structure_version_id
                                   );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              j := j+1 ;

              SELECT e.element_number
                    ,e.name
                INTO l_element_number
                    ,l_element_name
                FROM pa_proj_elements  e
                    ,pa_proj_element_versions v
               WHERE v.element_version_id = p_task_version_id_tbl(i)
                 AND e.proj_element_id = v.proj_element_id ;

               PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_FALSE,     -- Get the encoded message.
                        p_msg_index      => 1,                   -- Get the message at index 1.
                        p_data           => l_enc_msg_data,
                        p_msg_index_out  => l_msg_index_out);


               l_error_msg_name_tbl(j) := l_enc_msg_data ;
               l_element_name_tbl(j)   := l_element_name ;
               l_element_number_tbl(j) := l_element_number ;


         END IF ;

    END LOOP ;

    IF j > 0 THEN

         --bug: 3641049
         --comment out rollback because if there is an error, it will be rollback twice causing an exception
         --rollback to delete_bulk;

         FND_MSG_PUB.initialize;

         FOR k in reverse l_element_name_tbl.FIRST..l_element_name_tbl.LAST  LOOP

              PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name      => 'PA_PS_TASK_NAME_NUM_ERR',
                    p_token1        => 'TASK_NAME',
                    p_value1        =>  l_element_name_tbl(k),
                    p_token2        => 'TASK_NUMBER',
                    p_value2        =>  l_element_number_tbl(k),
                    p_token3        => 'MESSAGE',
                    p_value3        =>  l_error_msg_name_tbl(k)
                    );


         END LOOP ;

    END IF ;

    x_msg_count := FND_MSG_PUB.count_msg ;

    IF x_msg_count > 0 THEN
       x_return_status := 'E' ;
--hsiu: commenting out due to p1 issue.
--      savepoint should be issued only when p_commit
--      is true, which is a missing parameter
--       rollback to delete_bulk;
    END IF ;



    IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
    END IF ;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
--hsiu: commenting out due to p1 issue.
--      savepoint should be issued only when p_commit
--      is true, which is a missing parameter
--     rollback to delete_bulk;
     RETURN ;
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
--hsiu: commenting out due to p1 issue.
--      savepoint should be issued only when p_commit
--      is true, which is a missing parameter
--     rollback to delete_bulk;
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_TASK_PUB1'
              ,p_procedure_name => 'DELETE_TASK_VERSION_IN_BULK' );
     IF l_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_TASK_VERSION_IN_BULK' || G_PKG_NAME,SQLERRM,4);
             pa_debug.write('DELETE_TASK_VERSION_IN_BULK' || G_PKG_NAME,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
     END IF;
     RAISE ;

END DELETE_TASK_VERSION_IN_BULK ;

--margaret bug 3024607 add update task association
--when relationship ID is NULL both p_task_id and (either p_associated_project_id or
--p_associated_task_id) must be set - a new association is added.

--when  relationship ID is not NULL and either p_associated_project_id or
--p_associated_task_id are set, we just update the existing relationship
-- with the new "TO" object and type. p_task_id must also be NOT NULL in this case

--when relationship ID is not NULL and both p_associated_project_id and
--p_associated_task_id are NULL, we delete this particular association.

--This procedure was designed specifically to fit the flow of Self_Service Task Details page
--(or any page that uses TaskAssociationsVO).
 PROCEDURE Update_Task_Association (
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_associated_project_id          IN    NUMBER  := NULL,
 p_associated_task_id             IN    NUMBER  := NULL,
 p_associated_project_name        IN    VARCHAR2 :=NULL,
 p_associated_task_name           IN    VARCHAR2 :=NULL,
 p_task_id                        IN    NUMBER ,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id        IN    NUMBER  := NULL,
 p_record_version_number          IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_relationship_id                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
) IS

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_id_to                         NUMBER;
    l_type_to                       PA_OBJECT_RELATIONSHIPS.object_type_to%TYPE;

   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(30);

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_ASSOCIATION START');
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_task_association;
  END IF;

 l_type_to := 'PA_PROJECTS';
 l_id_to   := p_associated_project_id;

 IF p_associated_task_id is not NULL THEN
     l_type_to := 'PA_TASKS';
     l_id_to   := p_associated_task_id;
 END IF;

 -- when creating a new relationship check both ids and object types
 IF p_relationship_id is NULL THEN
    IF p_task_id is NULL or l_id_to is NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       l_error_msg_code:= 'PA_PS_TASK_NUMBER_NULL';
    ELSE
       IF p_task_id = l_id_to and l_type_to =  'PA_TASKS' then
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_msg_code:= 'PA_TASK_ID_INVALID';
       END IF;
    END IF;
 END IF;

 -- when updating an existing relationship check both ids and object types
 IF p_relationship_id is not null and l_id_to is not null  THEN
    IF p_task_id = l_id_to and l_type_to =  'PA_TASKS' then
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_error_msg_code:= 'PA_TASK_ID_INVALID';
    END IF;
 END IF;

  IF  x_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
  END IF;

 -- Create a new association row
 IF p_relationship_id is NULL and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
       p_user_id => FND_GLOBAL.USER_ID
      ,p_object_type_from => 'PA_TASKS'
      ,p_object_id_from1 => p_task_id
      ,p_object_id_from2 => NULL
      ,p_object_id_from3 => NULL
      ,p_object_id_from4 => NULL
      ,p_object_id_from5 => NULL
      ,p_object_type_to => l_type_to
      ,p_object_id_to1 => l_id_to
      ,p_object_id_to2 => NULL
      ,p_object_id_to3 => NULL
      ,p_object_id_to4 => NULL
     ,p_object_id_to5 => NULL
      ,p_relationship_type => p_relationship_type
      ,p_relationship_subtype => NULL
     ,p_lag_day => NULL
      ,p_imported_lag => NULL
      ,p_priority => NULL
      ,p_pm_product_code => NULL
      ,p_comments => NULL
      ,p_status_code => NULL
     ,x_object_relationship_id => x_relationship_id
     ,x_return_status => x_return_status
        );

  END IF;

   IF p_relationship_id is not null and l_id_to is not null  THEN
      UPDATE PA_OBJECT_RELATIONSHIPS
      SET object_id_to1   = l_id_to
          ,object_type_to = l_type_to
      WHERE object_relationship_id = p_relationship_id;
      --WHERE object_id_from1 = p_task_id
      --AND   object_type_from = 'PA_TASKS'
      --AND   relationship_type = 'A';
   END IF;

   IF p_relationship_id is not null and l_id_to is  null  THEN
       Delete_Association(p_relationship_id,p_record_version_number, x_return_status);
   END IF;


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => x_msg_count,
          p_msg_data       => x_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSE
       IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
       END IF;
   END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_ASSOCIATION END');
  END IF;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_task_association;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_task_association;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'update_task_association',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Update_Task_Association;



--margaret bug 3024607 delete task association
--if p_relationship_id is NOT NULL then only this ONE relationship is deleted
--if p_relationship_id is NULL, then ALL associations are deleted.
 PROCEDURE Delete_Task_Associations(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id                IN    NUMBER  := NULL,
 p_task_id                        IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


  CURSOR task_associations( p_task_id NUMBER )
   IS
     SELECT object_relationship_id
     FROM PA_OBJECT_RELATIONSHIPS
     WHERE relationship_type  = p_relationship_type
     AND (  (object_type_from = 'PA_TASKS' AND object_id_from1 = p_task_id)
          OR (object_type_to  = 'PA_TASKS' AND object_id_to1   = p_task_id));

   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.DELETE_TASK_ASSOCIATION START');
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_task_association;
  END IF;

--Delete just the requested relationship row
   IF p_relationship_id is not null THEN
       Delete_Association(p_relationship_id,null,x_return_status);
   ELSE
      IF p_task_id is not null THEN
         FOR task_associations_rec IN task_associations(p_task_id )  LOOP
            Delete_Association(task_associations_rec.object_relationship_id,null, x_return_status);
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              EXIT;
            END IF;
         END LOOP;
      END IF;
   END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => x_msg_count,
          p_msg_data       => x_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
  ELSE
       IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
       END IF;
  END IF;


 IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.DELETE_TASK_ASSOCIATIONS END');
  END IF;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_task_association;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_task_association;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'delete_all_task_associations',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Delete_Task_Associations;


--Delete a single association - relationship_id required
 PROCEDURE Delete_Association(
 p_relationship_id                IN    NUMBER,
 p_record_version_number          IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

   IF p_relationship_id is not null THEN
      PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
       p_object_relationship_id => p_relationship_id
      ,p_object_type_from => NULL
      ,p_object_id_from1 => NULL
      ,p_object_id_from2 => NULL
      ,p_object_id_from3 => NULL
      ,p_object_id_from4 => NULL
      ,p_object_id_from5 => NULL
      ,p_object_type_to => NULL
      ,p_object_id_to1 => NULL
      ,p_object_id_to2 => NULL
      ,p_object_id_to3 => NULL
      ,p_object_id_to4 => NULL
      ,p_object_id_to5 => NULL
      ,p_record_version_number =>NULL
      ,p_pm_product_code => NULL
      ,x_return_status => x_return_status
    );
  END IF;


EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'delete_association',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));

      RAISE;

END Delete_Association;


--margaret check if task has associations, returns Y/N
FUNCTION has_Associations(
 p_task_id                   IN    NUMBER
 ,p_relationship_type         IN    VARCHAR2 :='A'
)return VARCHAR2
IS
  cursor relationship_exists(p_task_id NUMBER) IS
    select '1'
      from pa_object_relationships
     WHERE relationship_type  = p_relationship_type
     AND (  (object_type_from = 'PA_TASKS' AND object_id_from1 = p_task_id
             AND object_type_to in ( 'PA_STRUCTURES', 'PA_TASKS'))   --bug 4091647
          OR (object_type_to  = 'PA_TASKS' AND object_id_to1   = p_task_id
             AND object_type_from = 'PA_TASKS')); --bug 4091647
   l_dummy_char        VARCHAR2(1);

  BEGIN
   OPEN relationship_exists(p_task_id);
   FETCH relationship_exists into l_dummy_char;
   IF relationship_exists%NOTFOUND THEN
      close  relationship_exists; -- 5349975
      return 'N';
   ELSE
      close  relationship_exists; -- 5349975
      return 'Y';
   END IF;
END has_Associations;


--margaret check if project is associated to tasks, returns Y/N
FUNCTION proj_has_task_associations(
 p_project_id                 IN    NUMBER
 ,p_relationship_type         IN    VARCHAR2 :='A'
)return VARCHAR2
IS
  cursor relationship_exists(p_project_id NUMBER) IS
    select '1'
      from pa_object_relationships
     WHERE relationship_type  = p_relationship_type
     AND  object_type_from = 'PA_TASKS'
     AND  object_type_to   = 'PA_PROJECTS' AND object_id_to1 = p_project_id;

   l_dummy_char        VARCHAR2(1);

  BEGIN
   OPEN relationship_exists(p_project_id);
   FETCH relationship_exists into l_dummy_char;
   IF relationship_exists%NOTFOUND THEN
      close  relationship_exists; -- 5349975
      return 'N';
   ELSE
      close  relationship_exists; -- 5349975
      return 'Y';
   END IF;
END proj_has_task_associations;


PROCEDURE Check_Task_Has_Association(
  p_task_id                  IN    NUMBER
 ,p_relationship_type        VARCHAR2 :='A'
 ,x_return_status            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

)IS
 l_ret_code  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_ret_code := has_Associations(p_task_id,p_relationship_type);
   IF l_ret_code = 'Y' THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         /*PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name     => 'PA_TASK_HAS_ASSOCIATIONS');*/  --Bug 3831786 commented
         x_msg_data:='PA_TASK_HAS_ASSOCIATIONS'; --Bug No 3491544 Smukka Apr 07 2004
   END IF;
END Check_Task_Has_Association;


PROCEDURE Check_Proj_Associated_To_Tasks(
  p_project_id               IN    NUMBER
 ,p_relationship_type        VARCHAR2 :='A'
 ,x_return_status            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

)IS
 l_ret_code  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_ret_code := proj_has_task_associations(p_project_id,p_relationship_type);
   IF l_ret_code = 'Y' THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name     => 'PA_PROJECT_HAS_ASSOCIATIONS');

   END IF;
END Check_Proj_Associated_to_Tasks;


--margaret bug 3024607 delete project to task associations
--if p_relationship_id is NOT NULL then only this ONE relationship is deleted
--if p_relationship_id is NULL, then ALL associations are deleted.
 PROCEDURE Delete_Proj_To_Task_Assoc(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id                IN    NUMBER  := NULL,
 p_project_id                     IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


  CURSOR task_associations( p_task_id NUMBER )
   IS
     SELECT object_relationship_id
     FROM PA_OBJECT_RELATIONSHIPS
     WHERE relationship_type  = p_relationship_type
     AND object_type_from = 'PA_TASKS'
     AND object_type_to   = 'PA_PROJECTS' AND object_id_to1   = p_project_id;

   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.Delete_Proj_To_Task_Assoc START');
  END IF;
  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_prj_to_task_assoc;
  END IF;

--Delete just the requested relationship row
   IF p_relationship_id is not null THEN
       Delete_Association(p_relationship_id,null,x_return_status);
   ELSE
      IF p_project_id is not null THEN
         FOR task_associations_rec IN task_associations(p_project_id )  LOOP
            Delete_Association(task_associations_rec.object_relationship_id,null, x_return_status);
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              EXIT;
            END IF;
         END LOOP;
      END IF;
   END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => x_msg_count,
          p_msg_data       => x_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
      raise FND_API.G_EXC_ERROR;
    END IF;
  ELSE
       IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
       END IF;
  END IF;

 IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.Delete_Proj_To_Task_Assoc END');
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_prj_to_task_assoc;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_prj_to_task_assoc;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'delete_proj_to_task_assoc',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Delete_Proj_To_Task_Assoc;


PROCEDURE Copy_Task_Associations(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_project_id_to                  IN    NUMBER   := NULL,
 p_project_id_from                IN    NUMBER   := NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

)IS
  --Bug#3693794 : Performance fix.
  --Replaced pa_structures_tasks_v from the from clause
  --for cursor task_list. Replaced it with pa_proj_elements
  --table which will siffice the current requirement of
  --getting source and destination proj_element_id of the task.

  CURSOR task_list( p_project_id_to NUMBER, p_project_id_from NUMBER )
   IS
     Select  source.proj_element_id old_task_id
            ,destination.proj_element_id new_task_id
     from pa_proj_elements source          --Bug#3693794
         ,pa_proj_elements destination     --Bug#3693794
     where source.project_id = p_project_id_from
     and source.element_number = destination.element_number
     and destination.project_id = p_project_id_to;

   CURSOR task_association( task_id NUMBER, p_relationship_type VARCHAR2 )
   IS
     Select  object_type_to, object_id_to1
     from pa_object_relationships
     where object_type_from = 'PA_TASKS'
     and object_id_from1    = task_id
     and relationship_type  = p_relationship_type;

   l_object_type_to  pa_object_relationships.object_type_to%Type;
   l_object_id_to1   pa_object_relationships.object_id_to1%Type;
   x_relationship_id pa_object_relationships.object_relationship_id%type;
   l_ret_code  VARCHAR2(1);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

BEGIN

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.Copy_Task_Associations START');
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      savepoint copy_task_associations;
  END IF;


  FOR task_list_rec IN task_list(p_project_id_to, p_project_id_from )  LOOP
    l_ret_code := has_Associations(task_list_rec.new_task_id,p_relationship_type);
    IF l_ret_code <>'Y' THEN
     open task_association(task_list_rec.old_task_id,p_relationship_type);
     fetch task_association  into l_object_type_to, l_object_id_to1;
     IF task_association%found THEN

        PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
          p_user_id => FND_GLOBAL.USER_ID
             ,p_object_type_from => 'PA_TASKS'
             ,p_object_id_from1 => task_list_rec.new_task_id
             ,p_object_id_from2 => NULL
            ,p_object_id_from3 => NULL
            ,p_object_id_from4 => NULL
            ,p_object_id_from5 => NULL
            ,p_object_type_to => l_object_type_to
            ,p_object_id_to1 =>  l_object_id_to1
            ,p_object_id_to2 => NULL
            ,p_object_id_to3 => NULL
            ,p_object_id_to4 => NULL
            ,p_object_id_to5 => NULL
            ,p_relationship_type => p_relationship_type
            ,p_relationship_subtype => NULL
            ,p_lag_day => NULL
            ,p_imported_lag => NULL
            ,p_priority => NULL
            ,p_pm_product_code => NULL
            ,p_comments => NULL
            ,p_status_code => NULL
            ,x_object_relationship_id => x_relationship_id
            ,x_return_status => x_return_status);

         END IF;
         close  task_association;
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            EXIT;
        END IF;
     END IF;
   END LOOP;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => x_msg_count,
          p_msg_data       => x_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
      raise FND_API.G_EXC_ERROR;
    END IF;
  ELSE
       IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
       END IF;
  END IF;

 IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.Copy_Task_Associations END');
  END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to copy_task_associations;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to copy_task_associations;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'Copy_Task_Associations',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Copy_Task_Associations;


--FPM  bug 3301192
--Planning and budget changes.
--This apis is called from CREATE_TASKS api and AMG create_project, update_prohject and add_task apis
PROCEDURE call_add_planning_txns(
 p_tasks_ver_ids                  IN    PA_NUM_1000_NUM,
 p_planned_effort                 IN    PA_NUM_1000_NUM,
 p_project_id                     IN    NUMBER,
 p_structure_version_id           IN    NUMBER,
 p_start_date                     IN    PA_DATE_1000_DATE,
 p_end_date                       IN    PA_DATE_1000_DATE,
 p_pm_product_code                IN    VARCHAR2  DEFAULT NULL, ---bug 3811243
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
/* Bug #: 3305199 SMukka                                                         */
/* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
/* l_task_ver_ids            PA_PLSQL_DATATYPES.IdTabTyp;                        */
l_task_ver_ids            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
l_planned_effort          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
l_start_dates             SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type(); /* Venky */
l_end_dates               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type(); /* Venky */
l_pm_product_code         SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();  ---bug 3811243

l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(1);
l_data              VARCHAR2(2000);
l_msg_index_out     NUMBER;
API_ERROR           EXCEPTION;

BEGIN

IF nvl(p_tasks_ver_ids.LAST,0) > 0 THEN --Condition added for bug #3569905
     FOR i in p_tasks_ver_ids.FIRST..p_tasks_ver_ids.LAST LOOP
           IF p_tasks_ver_ids(i) IS NOT NULL AND
             (p_planned_effort(i) IS NOT NULL AND
              p_planned_effort(i) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
														p_planned_effort(i) <> 0)  --bug 3802240: Added conditions to skip g_miss
           THEN
               IF PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_tasks_ver_ids(i) ) = 'Y'
               THEN
                    /* convert ids and planned effort to the called apis params types. */
                    l_task_ver_ids.extend(1); /* Venky */
                    l_task_ver_ids(l_task_ver_ids.count)     := p_tasks_ver_ids(i);
                    l_planned_effort.extend(1);
                    l_planned_effort(l_planned_effort.count)   := p_planned_effort(i);
                    l_start_dates.extend(1);
                    l_start_dates(l_start_dates.count)      := NVL( p_start_date(i), TRUNC(SYSDATE));
                    l_end_dates.extend(1);
                    l_end_dates(l_end_dates.count)        := NVL( p_end_date(i), TRUNC(SYSDATE));
                    ---bug 3811243
                    l_pm_product_code.extend();
                    l_pm_product_code(l_pm_product_code.count) := p_pm_product_code;
               END IF;
           END IF;
     END LOOP;
END IF;

 IF l_task_ver_ids.exists(1)
 THEN
     /*Smukka Bug No. 3474141 Date 03/01/2004                                                 */
     /*moved pa_fp_planning_transaction_pub.add_planning_transactions into plsql block        */
     BEGIN
         pa_fp_planning_transaction_pub.add_planning_transactions(
            p_context                      => 'WORKPLAN'
           ,p_project_id                   => p_project_id
           ,p_struct_elem_version_id       => p_structure_version_id
           ,p_task_elem_version_id_tbl     => l_task_ver_ids
           ,p_planned_people_effort_tbl    => l_planned_effort
           ,p_start_date_tbl               => l_start_dates
           ,p_end_date_tbl                 => l_end_dates
           ,p_pm_product_code              => l_pm_product_code   --bug 3811243
           ,x_return_status                => l_return_status
           ,x_msg_count                    => l_msg_count
           ,x_msg_data                     => l_msg_data
          );
     EXCEPTION
         WHEN OTHERS THEN
              fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                                      p_procedure_name => 'call_add_planning_txns',
                                      p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.add_planning_transactions:'||SQLERRM,1,240));
         raise API_ERROR;
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
     raise API_ERROR;
   end if;
 END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN API_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                          p_procedure_name => 'call_add_planning_txns',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
  raise;
END call_add_planning_txns;

PROCEDURE update_task_det_sch_info(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_task_ver_id                    IN    NUMBER,
 p_project_id                     IN    NUMBER,
 p_planned_effort                 IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ETC_effort                     IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id           IN    NUMBER,
 p_object_type                    IN    VARCHAR2 := 'PA_TASKS',
 p_etc_cost                       IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_actual_effort                  IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_percent_complete               IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_res_assign_id                  IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_return_status                VARCHAR2(2);
    l_error_message_code           VARCHAR2(250);

   CURSOR cur_sch
   IS
   SELECT scheduled_start_date, scheduled_finish_date
     FROM pa_proj_elem_ver_schedule
    WHERE element_version_id = p_task_ver_id
      AND project_id = p_project_id
    ;


    /*  Bug # 3755089. Modified the following cursor. */

    cursor cur_progress (p_project_id NUMBER, p_object_id NUMBER, p_object_version_id NUMBER,
                                p_structure_version_id NUMBER) is
    select *
    from pa_progress_rollup ppr
    where ppr.project_id = p_project_id
    and ppr.object_id = p_object_id
    and ppr.object_version_id = p_object_version_id
    and ppr.structure_version_id = p_structure_version_id
    and ppr.object_type in ('PA_TASKS','PA_ASSIGNMENTS','PA_STRUCTURES') -- 4498610 : Added PA_STRUCTURES also
    and ppr.current_flag = 'Y'
    and ppr.as_of_date = (select max(as_of_date) from pa_progress_rollup ppr2
                           where ppr2.project_id = p_project_id
                           and ppr2.object_id = p_object_id
                           and ppr2.object_version_id = p_object_version_id
                           and ppr2.structure_version_id = p_structure_version_id
                       and ppr2.object_type in ('PA_TASKS','PA_ASSIGNMENTS','PA_STRUCTURES'));

    cur_progress_rec cur_progress%rowtype;


    cursor cur_progress2 (p_project_id NUMBER, p_object_id NUMBER, p_object_version_id NUMBER,
                                p_structure_version_id NUMBER, p_current_flag VARCHAR2) is
    select *
    from pa_progress_rollup ppr
    where ppr.project_id = p_project_id
    and ppr.object_id = p_object_id
    and ppr.object_version_id = p_object_version_id
    and ppr.structure_version_id IS NULL
    and ppr.current_flag = p_current_flag
    and ppr.object_type in ('PA_TASKS','PA_ASSIGNMENTS','PA_STRUCTURES'); -- 4498610 : Added PA_STRUCTURES also
    --bug 3959087, following code is commented as it is not needed
    /*and ppr.as_of_date = (select max(as_of_date) from pa_progress_rollup ppr2
                           where ppr2.project_id = p_project_id
                           and ppr2.object_id = p_object_id
                           and ppr2.object_version_id = p_object_version_id
                           and ppr2.structure_version_id IS NULL
                           and ppr2.current_flag = p_current_flag   --bug 3708948
                           and ppr2.object_type in ('PA_TASKS','PA_ASSIGNMENTS'));*/

    cursor cur_prev_planned_task_effort(p_project_id NUMBER, p_proj_element_id NUMBER
                        , p_structure_version_id NUMBER) is
    select (labor_effort+equipment_effort)
    from  pji_xbs_plans_v
    where  project_id = p_project_id
    and structure_version_id = p_structure_version_id
    and proj_element_id = p_proj_element_id
    and structure_type = 'WORKPLAN';

    cursor cur_prev_planned_assgn_effort(p_project_id NUMBER, p_task_id NUMBER
                                         , p_structure_version_id NUMBER, p_res_assign_id NUMBER) is
    select planned_quantity
    from  pa_task_assignments_v
    where  project_id = p_project_id
    and structure_version_id = p_structure_version_id
    and resource_assignment_id = p_res_assign_id
    and task_id = p_task_id;

    l_prev_planned_effort NUMBER := null;

    cursor cur_prev_etc_effort (p_project_id NUMBER, p_object_id NUMBER
                                         , p_structure_version_id NUMBER) is
    select (nvl(estimated_remaining_effort,0)+nvl(eqpmt_etc_effort,0)
       +nvl(subprj_ppl_etc_effort,0)+nvl(subprj_eqpmt_etc_effort,0))
    from pa_progress_rollup
    where  project_id = p_project_id
    and object_id = p_object_id
    and structure_version_id = p_structure_version_id
    and structure_type = 'WORKPLAN';

--maansari5/9
    cursor cur_prev_etc_effort2 (p_project_id NUMBER, p_object_id NUMBER
                                         ) is
    select (nvl(estimated_remaining_effort,0)+nvl(eqpmt_etc_effort,0)
       +nvl(subprj_ppl_etc_effort,0)+nvl(subprj_eqpmt_etc_effort,0))
    from pa_progress_rollup
    where  project_id = p_project_id
    and object_id = p_object_id
    and structure_version_id is null
    and current_flag = 'Y'
    and structure_type = 'WORKPLAN';
--maansari5/9

   l_prev_etc_effort NUMBER := null;

  l_task_ver_ids2             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_planned_effort2           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_start_dates               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
  l_end_dates                 SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
  l_SCHEDULED_START_DATE      DATE;
  l_SCHEDULED_END_DATE        DATE;

  l_progress_rollup_id NUMBER;
  l_login_id NUMBER := fnd_global.login_id;
  l_user_id  NUMBER := fnd_global.user_id;

  l_task_id NUMBER;
  l_object_id NUMBER;
  l_next_prog_cycle_date DATE;
  l_as_of_date DATE;
  l_percent_complete NUMBER;
  l_etc_effort NUMBER;
  l_planned_effort NUMBER;
  l_override_pc NUMBER := null;
  l_eff_rollup_pc NUMBER := null;
  l_earned_value NUMBER := null;
  l_proj_element_id NUMBER := null;

  l_version_enabled VARCHAr2(1):= 'N';  --maansari5/9
  l_weighting_basis VARCHAR2(30); ---Bug 6144931

--maansari5/11
   CURSOR c_get_task_weight_method
   IS
   SELECT task_weight_basis_code
   FROM pa_proj_progress_attr
   WHERE project_id = p_project_id
   AND structure_type = 'WORKPLAN';

   CURSOR c_proj_element_id
   IS
   SELECT proj_element_id
   FROM pa_proj_element_versions
   WHERE project_id = p_project_id
   and parent_structure_version_id = p_structure_version_id
   and element_version_id = p_task_ver_id
   and object_type = decode(p_object_type, 'PA_ASSIGNMENTS','PA_TASKS', p_object_type); -- Bug 3856161 : Added Decode

   l_rollup_method    VARCHAR2(30);
   l_actual_finish_DATE DATE;
   l_actual_start_DATE  DATE;
   l_rollup_as_of_date  DATE;

   cursor c_max_as_of_date_wkg is
   select max(as_of_date)
   from pa_progress_rollup
   where project_id = p_project_id
--   and object_version_id = p_task_ver_id Bug 3856161 : It shd always do rollup if record exists
--   and object_type = p_object_type
   and structure_type = 'WORKPLAN'
   and structure_version_id = p_structure_version_id;

   l_debug_mode   VARCHAR2(1);
   l_dummy        NUMBER;

   -- Start modifications for Bug # 3879658.

   cursor cur_progress_status is
   select ptt.initial_progress_status_code
   from pa_task_types ptt, pa_proj_elements ppe, pa_proj_element_versions ppev
   where ppev.project_id = ppe.project_id
   and ppev.proj_element_id = ppe.proj_element_id
   and ppe.type_id = ptt.task_type_id
   and ppe.project_id = p_project_id
   and ppev.element_version_id = p_task_ver_id
   and ppev.parent_structure_version_id = p_structure_version_id;

   l_init_prog_status_code VARCHAR2(150) := NULL;

   -- End modifications for Bug # 3879658.

   --bug 3959087, start
   l_BASE_PERCENT_COMP_DERIV_CODE   VARCHAR2(30);
   l_lowest_level_task             VARCHAR2(1);
   l_assignment_exists             VARCHAR2(1);
   l_ppl_act_cost                  NUMBER;
   l_planned_cost                   NUMBER;
   l_actual_effort                  NUMBER;
   l_prj_currency_code VARCHAR2(15);

   CURSOR cur_proj_elements(c_proj_element_id NUMBER)
   IS
      SELECT decode( ppe.base_percent_comp_deriv_code, null, ptt.base_percent_comp_deriv_code, '^', ptt.base_percent_comp_deriv_code, ppe.base_percent_comp_deriv_code )
      from pa_proj_elements ppe
          ,pa_task_types ptt
      where ppe.project_id = p_project_id
      and ppe.proj_element_id = c_proj_element_id
      and ppe.type_id = ptt.task_type_id;


    cursor cur_get_costs(p_project_id NUMBER, p_object_id NUMBER, p_structure_version_id NUMBER) is
    select nvl(BRDN_COST, 0), nvl(ACT_LABOR_BRDN_COST, 0)
    from pji_xbs_plans_v
    where project_id = p_project_id
    and   proj_element_id = p_object_id
    and   structure_version_id = p_structure_version_id;

    cursor cur_rollup_percent (p_project_id NUMBER, p_object_id NUMBER, p_object_version_id NUMBER,
                                p_structure_version_id NUMBER) is
    select ppr.EFF_ROLLUP_PERCENT_COMP,ppr.completed_percentage, actual_start_date,  actual_finish_date -- 4498610 : Added completed_percentage, actual_start_date,  actual_finish_date
    from pa_progress_rollup ppr
    where ppr.project_id = p_project_id
    and ppr.object_id = p_object_id
    and ppr.object_version_id = p_object_version_id
    and ppr.structure_version_id = p_structure_version_id
    and ppr.object_type IN ('PA_TASKS','PA_STRUCTURES') -- -- Bug 4498610 : Added PA_STRUCTURES
    and ppr.current_flag = 'Y';


    cursor cur_rollup_percent2 (p_project_id NUMBER, p_object_id NUMBER, p_object_version_id NUMBER,
                                p_structure_version_id NUMBER) is
    select ppr.EFF_ROLLUP_PERCENT_COMP,ppr.completed_percentage, actual_start_date,  actual_finish_date -- 4498610 : Added completed_percentage, actual_start_date,  actual_finish_date
    from pa_progress_rollup ppr
    where ppr.project_id = p_project_id
    and ppr.object_id = p_object_id
    and ppr.object_version_id = p_object_version_id
    and ppr.structure_version_id IS NULL
    and ppr.current_flag = 'Y'
    and ppr.object_type IN ('PA_TASKS','PA_STRUCTURES') -- Bug 4498610 : Added PA_STRUCTURES
    ;

   --bug 3959087, end

    -- Bug 3976633 : Added cursor cur_progress_exists
    cursor cur_progress_exists (c_project_id NUMBER, c_object_id NUMBER, c_structure_version_id NUMBER, c_version_enabled_flag VARCHAR2) is
    select 'Y'
    from pa_progress_rollup ppr
    where ppr.project_id = c_project_id
    and ppr.object_id = c_object_id
    and ((c_version_enabled_flag = 'N' AND ppr.structure_version_id  IS NULL) OR (c_version_enabled_flag = 'Y' AND ppr.structure_version_id = p_structure_version_id))
    and ppr.object_type = 'PA_TASKS'
    and ppr.structure_type = 'WORKPLAN';

    l_progress_exists VARCHAR2(1):='N';

    --BUG 3919800, rtarway
    cursor cur_get_act_effort (p_project_id NUMBER, p_object_id NUMBER, p_structure_version_id NUMBER) is
    select nvl(ACT_LABOR_HRS, 0)+nvl(ACT_EQUIP_HRS,0)
    from pji_xbs_plans_v
    where project_id = p_project_id
    and   proj_element_id = p_object_id
    and   structure_version_id = p_structure_version_id ;

    l_curr_override_pc NUMBER; -- Bug 4498610

BEGIN

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO begin');
      END IF;

      IF (p_commit = FND_API.G_TRUE) THEN
        savepoint UPDATE_task_det_sch;
      END IF;

      l_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

      IF l_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO Start : Passed Parameters :', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_calling_module='||p_calling_module, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_task_ver_id='||p_task_ver_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_project_id='||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_planned_effort='||p_planned_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_ETC_effort='||p_ETC_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_structure_version_id='||p_structure_version_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_object_type='||p_object_type, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_etc_cost='||p_etc_cost, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_actual_effort='||p_actual_effort, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_percent_complete='||p_percent_complete, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_res_assign_id='||p_res_assign_id, x_Log_Level=> 3);
      END IF;

      l_version_enabled := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id);  --maansari5/9

      --The following actions are to be performed only when p_object_type = 'PA_TASKS'

      --IF (p_object_type = 'PA_TASKS') THEN --- Bug 4498610
      IF (p_object_type IN ('PA_TASKS','PA_STRUCTURES')) THEN --- Bug 4498610

        -- Bug Fix 5726773
 	-- Support negative quantities and amounts.
 	-- Commenting out the following validations.
 	/*
	-- BEGIN: Code to raise error if negative etc values or planned values are entered.
        IF ((p_planned_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
        AND (nvl(p_planned_effort,0) < 0))  THEN

            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                        ,p_msg_name       => 'PA_TP_NO_NEG_PLN');

            x_msg_data := 'PA_TP_NO_NEG_PLN';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

        IF (((p_etc_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (nvl(p_etc_cost,0) < 0))
        or ((p_etc_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) and (nvl(p_etc_effort,0) < 0))) THEN

            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                        ,p_msg_name       => 'PA_TP_NO_NEG_ETC');

            x_msg_data := 'PA_TP_NO_NEG_ETC';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
	*/
 	-- End of Bug Fix 5726773

        -- END: Code to raise error if negative etc values or planned values are entered.
        IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_version_enabled='||l_version_enabled, x_Log_Level=> 3);
        END IF;

        -- Get the task_id.

        select proj_element_id
        into l_task_id
        from pa_proj_element_versions
        where element_version_id = p_task_ver_id
        and parent_structure_version_id = p_structure_version_id;

        IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_task_id='||l_task_id, x_Log_Level=> 3);
        END IF;
        --bug 3959087
        SELECT project_currency_code  INTO  l_prj_currency_code  FROM pa_projects_all WHERE project_id = p_project_id;

        -- Bug 3856161 : This code will never excute for assignments, I don't know why has this written here
        -- Setting object_id for Tasks / Assignments.
        IF (p_object_type = 'PA_ASSIGNMENTS') THEN
            l_object_id := p_res_assign_id;
        ELSE
            l_object_id := l_task_id;
        END IF;

        IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_object_id='||l_object_id, x_Log_Level=> 3);
        END IF;


           -- Logic to make sure that planned value = etc value + actual value if etc is changed.
           -- If both planned value and etc value are changed, then planned value always takes precedence,
           -- set etc value as (planned value - actual value).
           -- Confirmed this logic with Clint Chow.

           IF ((nvl(p_planned_effort,0) > 0 and NVL( p_planned_effort,0) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           or (nvl(p_etc_effort,0) > 0 and NVL(p_etc_effort,0) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)) THEN

            -- Get previous planned value.
            -- Bug 3856161 : This code will never excute for assignments, I don't know why has this written here
            IF p_object_type ='PA_ASSIGNMENTS' THEN
                open cur_prev_planned_assgn_effort(p_project_id,l_task_id
                    ,p_structure_version_id,p_res_assign_id);
                fetch cur_prev_planned_assgn_effort into l_prev_planned_effort;
                close cur_prev_planned_assgn_effort;
            ELSE
                open cur_prev_planned_task_effort(p_project_id,l_task_id,p_structure_version_id);
                fetch cur_prev_planned_task_effort into l_prev_planned_effort;
                close cur_prev_planned_task_effort;
            END IF;

            IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_prev_planned_effort='||l_prev_planned_effort, x_Log_Level=> 3);
            END IF;

            -- Get previous etc value.
            --maansari5/9
            IF NVL(l_version_enabled,'N') = 'Y'
            THEN
                open cur_prev_etc_effort(p_project_id,l_object_id,p_structure_version_id);
                fetch cur_prev_etc_effort into l_prev_etc_effort;
                close cur_prev_etc_effort;
            ELSE
                open cur_prev_etc_effort2(p_project_id,l_object_id);
                fetch cur_prev_etc_effort2 into l_prev_etc_effort;
                close cur_prev_etc_effort2;
            END IF;

            IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_prev_etc_effort='||l_prev_etc_effort, x_Log_Level=> 3);
            END IF;

            --maansari5/9

            -- Initialize the variables for planned effort and etc effort.

            l_planned_effort := null;
            l_etc_effort := null;

            -- If planned value has been updated set etc value as (planned value - actual value).
            --bug 3959087, start
            IF (p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_actual_effort := round(p_actual_effort, 5);
            ELSE
                --BUG 3919800, rtarway
                    if p_calling_module <> 'AMG'
                    then
                         l_actual_effort := 0;
                    else
                         --BUG 3919800, rtarway
                         --get actual effort using cursor cur_get_act_effort
                         OPEN cur_get_act_effort(p_project_id,l_object_id,p_structure_version_id);
                         FETCH cur_get_act_effort into l_actual_effort;
                         CLOSE cur_get_act_effort;
                    end if;
            END IF;
            --bug 3959087, end

               IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_actual_effort='||l_actual_effort, x_Log_Level=> 3);
            END IF;

               --maansari5/9
            IF (p_planned_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
            --and (NVL(l_prev_planned_effort,0) <> NVL(p_planned_effort,0))) THEN  --bug 3959087
            THEN
                --l_planned_effort := p_planned_effort; --bug 3959087
                l_planned_effort := round(p_planned_effort, 5);
                    --BUG 3919800, rtarway
                    --IF (p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                    IF (l_actual_effort >= 0 ) THEN
                    --l_etc_effort := NVL(p_planned_effort,0) - NVL(p_actual_effort, 0); --bug 3959087
                    l_etc_effort := round((NVL(p_planned_effort,0) - NVL(l_actual_effort, 0)), 5);
                END IF;
            -- else set planned value as (etc vallue + actual value).
            ELSIF (p_etc_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
            --and (NVL(l_prev_etc_effort,0) <> nvl(p_etc_effort,0))) THEN --bug 3959087
            THEN
                --l_etc_effort := NVL(p_etc_effort,0); --bug 3959087
                l_etc_effort := NVL(round(p_etc_effort,5),0);
                    --BUG 3919800, rtarway
                    --IF (p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                    IF (l_actual_effort >= 0 ) THEN
                    -- l_planned_effort := NVL( p_etc_effort, 0) + NVL(p_actual_effort,0); --bug 3959087
                    l_planned_effort := round( (NVL( p_etc_effort, 0) + NVL(l_actual_effort,0)), 5);
                END IF;
            END IF;
            --maansari5/9
           END IF; --   IF ((nvl(p_planned_effort,0) > 0 and NVL( p_planned_effort,0) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)

	   --Bug#6144931 START

           l_weighting_basis := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(p_project_id);

	  IF l_weighting_basis = 'EFFORT' AND NVL(l_prev_planned_effort,0) <> NVL(l_planned_effort,0)
	  THEN
	      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => p_project_id,
                               p_structure_version_id =>  p_structure_version_id,
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

         --Bug#6144931 END

           IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_planned_effort='||l_planned_effort, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_etc_effort='||l_etc_effort, x_Log_Level=> 3);
           END IF;

           --bug 3959087,  start
           l_lowest_level_task := PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_ver_id );
           l_assignment_exists := PA_PROGRESS_UTILS.check_assignment_exists(p_project_id, p_task_ver_id, 'PA_TASKS');

           IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_lowest_level_task='||l_lowest_level_task, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_assignment_exists='||l_assignment_exists, x_Log_Level=> 3);
           END IF;
           --bug 3959087,  end

           -- Call: pa_fp_planning_transaction_pub.update_planning_transactions().

          --IF (PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id => p_task_ver_id )  = 'Y' AND
          IF (l_lowest_level_task  = 'Y' AND --bug 3959087
          PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN') = 'Y'
          -- Progress Management Changes, Bug # 3420093.
          --AND PA_PROGRESS_UTILS.check_assignment_exists(p_project_id,p_task_ver_id,p_object_type) = 'N'  --bug 3864543
          AND l_assignment_exists = 'N'  --bug 3959087
          AND p_object_type = 'PA_TASKS'
          AND p_calling_module <> 'AMG')
          THEN

            OPEN cur_sch;
            FETCH cur_sch INTO l_SCHEDULED_START_DATE, l_SCHEDULED_END_DATE;
            CLOSE cur_sch;
                IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_SCHEDULED_START_DATE='||l_SCHEDULED_START_DATE, x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_SCHEDULED_END_DATE='||l_SCHEDULED_END_DATE, x_Log_Level=> 3);
                END IF;

            l_task_ver_ids2.extend(1);
            l_planned_effort2.extend(1);
            l_start_dates.extend(1);
            l_end_dates.extend(1);

            l_task_ver_ids2(1)   := p_task_ver_id;

            /* Start Modifications to fix Bug # 3640498. */

            IF ((l_planned_effort = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) or  (nvl(l_planned_effort,0) = 0)) then
                l_planned_effort2(1) := FND_API.G_MISS_NUM;
            ELSE
                l_planned_effort2(1) := l_planned_effort;
            END IF;

            /* End Modifications to fix Bug # 3640498. */

            l_start_dates(1)     := l_SCHEDULED_START_DATE;
            l_end_dates(1)       := l_SCHEDULED_END_DATE;

            /*Smukka Bug No. 3474141 Date 03/01/2004                                                    */
            /*moved pa_fp_planning_transaction_pub.update_planning_transactions into plsql block        */
            BEGIN
                IF NVL(l_prev_planned_effort,0) <> NVL(l_planned_effort,0)
                THEN
                    IF l_debug_mode  = 'Y' THEN
                        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'Calling update_planning_transactions', x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_task_ver_ids2='||p_task_ver_id, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_planned_effort2='||l_planned_effort, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_start_dates='||l_SCHEDULED_START_DATE, x_Log_Level=> 3);
                        pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_end_dates='||l_SCHEDULED_END_DATE, x_Log_Level=> 3);
                    END IF;

                    pa_fp_planning_transaction_pub.update_planning_transactions
                    (
                        p_context                      => 'WORKPLAN'
                        ,p_struct_elem_version_id       => p_structure_version_id
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
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                        p_procedure_name => 'update_task_det_sch_info',
                        p_error_text     => SUBSTRB('pa_fp_planning_transaction_pub.update_planning_transactions:'||SQLERRM,1,240));
                RAISE FND_API.G_EXC_ERROR;
            END;
          --end 3301192 fp changes
          END IF;  --<< l_planned_effort >>

          -- Progress Management Changes, Bug # 3420093.

          -- The following code inserts progress records into the pa_progress_rollup_table.
              -- this is required if only any of: p_etc_effort, p_etc_cost and p_percent_complete is not null


              --if ((nvl(p_etc_effort,0) > 0 and p_etc_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
              --  or (nvl(p_etc_cost,0) > 0  and p_etc_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  --maansari5/9


          l_next_prog_cycle_date := pa_progress_utils.get_next_progress_cycle(p_project_id => p_project_id , p_task_id  => l_task_id);
          IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_next_prog_cycle_date='||l_next_prog_cycle_date, x_Log_Level=> 3);
          END IF;


          IF   (nvl(p_percent_complete,0) > 0 AND p_percent_complete <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
          THEN
            -- Progress Management Changes, Bug # 3420093.
            -- Begin logic to create pa_progress_rollup record for the Task / Assignment:
            -- Get the next progress cycle id.
            -- Bug 3856161 : Moving this code outside
            --l_next_prog_cycle_date := pa_progress_utils.get_next_progress_cycle(p_project_id => p_project_id
            --                              , p_task_id  => l_task_id);
            -- Progress Management Changes, Bug # 3420093.
            IF (p_percent_complete = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
                l_percent_complete := null;
            ELSE
                --l_percent_complete := p_percent_complete; --bug 3959087
                l_percent_complete := round(p_percent_complete, 8); --Bug 6854114
            END IF;

            -- Initializning the values for Override Percent Complete, Effective Rollup Percent Complete
            -- and Earned Value.
        -- Bug  3856161 : Reduced the scope of IF, now % cokplete should be rederived based on actual and etc too
              END IF;

          l_eff_rollup_pc := null;
          l_override_pc := null;
          l_earned_value := null;

              -- Setting values for Override Percent Complete, Effective Rollup Percent Complete
          -- and Earned Value.

          IF (p_percent_complete <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
            --l_override_pc := p_percent_complete; --bug 3959087
            l_override_pc := round(p_percent_complete, 8); --Bug 6854114
          END IF;


         --bug 3959087, calculate percent complete for lowest level tasks only, depending on derivation code, start

         /*IF (p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        IF ((nvl(l_etc_effort,0)+nvl(p_actual_effort,0)) <> 0) THEN
        -- Bug 3856161
        --l_eff_rollup_pc := (nvl(l_etc_effort,0))/
        --         (nvl(l_etc_effort,0)+nvl(p_actual_effort,0));
        l_eff_rollup_pc := (nvl(p_actual_effort,0))/ (nvl(l_etc_effort,0)+nvl(p_actual_effort,0))*100;
        ELSE
            -- Bug 3856161
        --l_eff_rollup_pc := (nvl(l_etc_effort,0))/1;
        l_eff_rollup_pc := 0;
        END IF;
          -- Bug 3856161 : Reduced the scope of IF
         END IF;*/

        -- 4498610 : Added PA_TASKS condition
        IF p_object_type = 'PA_TASKS' AND NVL( l_lowest_level_task, 'N' ) = 'Y' AND l_assignment_exists = 'N'
        THEN
            OPEN cur_proj_elements(l_task_id);
            FETCH cur_proj_elements INTO l_BASE_PERCENT_COMP_DERIV_CODE;
            CLOSE cur_proj_elements;
            IF l_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_BASE_PERCENT_COMP_DERIV_CODE='||l_BASE_PERCENT_COMP_DERIV_CODE, x_Log_Level=> 3);
            END IF;

            IF l_BASE_PERCENT_COMP_DERIV_CODE = 'EFFORT'
            THEN
                    --BUG 3919800, rtarway, commented IF
                   --IF (p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

                IF ((nvl(l_etc_effort,0)+nvl(l_actual_effort,0)) <> 0) THEN
                    l_eff_rollup_pc := round((nvl(l_actual_effort,0))/ (nvl(l_etc_effort,0)+nvl(l_actual_effort,0))*100, 2);
                ELSE
                    l_eff_rollup_pc := 0;
                END IF;
                --END IF;
            ELSIF l_BASE_PERCENT_COMP_DERIV_CODE = 'COST'
            THEN
               OPEN cur_get_costs(p_project_id, l_task_id, p_structure_version_id);
               FETCH cur_get_costs INTO l_planned_cost, l_ppl_act_cost;
               CLOSE cur_get_costs;

               IF l_debug_mode  = 'Y' THEN
                    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_ppl_act_cost='||l_ppl_act_cost, x_Log_Level=> 3);
                    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_planned_cost='||l_planned_cost, x_Log_Level=> 3);
               END IF;
               IF (l_planned_cost <> 0)
               THEN
                l_eff_rollup_pc := round((l_ppl_act_cost/l_planned_cost)*100, 2);
               ELSE
                l_eff_rollup_pc := 0;
               END IF;
            END IF;
        ELSE      -- for summary level task fetch the rolledup percent from progress table
           IF NVL(l_version_enabled,'N') = 'Y'
           THEN
               OPEN cur_rollup_percent(p_project_id, l_task_id, p_task_ver_id, p_structure_version_id);
               FETCH cur_rollup_percent INTO l_eff_rollup_pc, l_curr_override_pc,l_actual_start_date,l_actual_finish_date ;
	                   -- Bug 4498610 : Added l_curr_override_pc, l_actual_START_DATE, l_actual_FINISH_DATE
               CLOSE cur_rollup_percent;
           ELSE
               OPEN cur_rollup_percent2(p_project_id, l_task_id, p_task_ver_id, p_structure_version_id);
               FETCH cur_rollup_percent2 INTO l_eff_rollup_pc,l_curr_override_pc,l_actual_start_date,l_actual_finish_date ;
	            -- Bug 4498610 : Added l_curr_override_pc, l_actual_START_DATE, l_actual_FINISH_DATE
               CLOSE cur_rollup_percent2;
           END IF;
        END IF;

        --bug 3959087, calculate percent complete for lowest level tasks only, depending on derivation code, end

        IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_percent_complete='||l_percent_complete, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_override_pc='||l_override_pc, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_eff_rollup_pc='||l_eff_rollup_pc, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_curr_override_pc='||l_curr_override_pc, x_Log_Level=> 3);
        END IF;


         OPEN c_get_task_weight_method;
         FETCH c_get_task_weight_method INTO l_rollup_method;
         CLOSE c_get_task_weight_method;

         OPEN c_proj_element_id;
         FETCH c_proj_element_id INTO l_proj_element_id;
         CLOSE c_proj_element_id;

         l_earned_value := nvl(l_override_pc,l_eff_rollup_pc) *
              PA_PROGRESS_UTILS.Get_BAC_Value(p_project_id,l_rollup_method
                  ,l_proj_element_id,p_structure_version_id
                  ,'WORKPLAN');

          --bug 3959087, start
          IF l_rollup_method = 'EFFORT'
          THEN
            l_earned_value := nvl(round(l_earned_value, 5),0);
          ELSE
            l_earned_value := nvl(pa_currency.round_trans_currency_amt(l_earned_value, l_prj_currency_code),0);
          END IF;
         --bug 3959087, end

         IF l_debug_mode  = 'Y' THEN
            pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_earned_value='||l_earned_value, x_Log_Level=> 3);
         END IF;

    --END IF; Bug 3856161



    --maansari5/11
     -- Bug 3856161 : Using l_eff_rollup_pc also
     IF NVL(l_percent_complete,l_eff_rollup_pc) > 0  AND NVL(l_percent_complete,l_eff_rollup_pc) <100
     THEN
      -- Bug 4498610 : Added nvl actual_start_date
    l_actual_START_DATE := nvl(l_actual_start_date,l_SCHEDULED_START_DATE);
    l_actual_finish_DATE := null;
     ELSIF NVL(l_percent_complete,l_eff_rollup_pc) > 0 AND NVL(l_percent_complete,l_eff_rollup_pc) =100
     THEN
           -- Bug 4498610 : Added nvl actual_start_date and finish_date
    l_actual_START_DATE := nvl(l_actual_start_date,l_SCHEDULED_START_DATE);
    l_actual_finish_DATE :=  nvl(l_actual_finish_date,l_SCHEDULED_END_DATE);
     END IF;

     IF l_debug_mode  = 'Y' THEN
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_actual_START_DATE='||l_actual_START_DATE, x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_actual_finish_DATE='||l_actual_finish_DATE, x_Log_Level=> 3);
     END IF;

     -- Progress Management Changes, Bug # 3420093.
     -- If workplan versioning is disabled for the project.
     -- Bug 3856161 : Added this IF condition

     IF   ( (nvl(p_percent_complete,0) > 0 AND p_percent_complete <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)

        -- Start modifications for Bug # 3879658.

            -- OR
        --(p_actual_effort <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)

        -- End modifications for Bug # 3879658.
           )
     THEN
        -- Bug 4498610 : Added code below
        IF l_curr_override_pc IS NULL AND (l_percent_complete = l_eff_rollup_pc )THEN
		l_percent_complete := null;
	END IF;

     IF (l_version_enabled = 'N') THEN   --maansari5/9
         --- If progress exists, update the latest existing progress record
    open cur_progress2(p_project_id,l_object_id,p_task_ver_id,null,'Y');
    fetch cur_progress2 into cur_progress_rec;
    IF cur_progress2%found THEN

        update pa_progress_rollup set
        --as_of_date = l_next_prog_cycle_date,
        estimated_remaining_effort = null --l_etc_effort
        ,completed_percentage = l_percent_complete
        ,eff_rollup_percent_comp = l_eff_rollup_pc
        ,earned_value = l_earned_value
        ,actual_start_date    = l_actual_start_date
        ,actual_finish_date    = l_actual_finish_date
        ,last_update_date = sysdate
        ,last_updated_by = l_user_id
        --,creation_date = sysdate
        --,created_by = l_user_id
        ,last_update_login = l_login_id
        where progress_rollup_id = cur_progress_rec.progress_rollup_id;

        -- If progress does not exist, create a published progress record.
        l_rollup_as_of_date := cur_progress_rec.as_of_date;

        --bug no.3708948 start
        update pa_percent_completes set completed_percentage = l_percent_complete
        where project_id  = p_project_id
        and object_id = l_task_id
        and date_computed =l_rollup_as_of_date
        and current_flag = 'Y'
        and published_flag = 'Y';
        --bug no.3708948 end
    ELSE
         l_progress_rollup_id := null;

                    -- Start modifications for Bug # 3879658.

                    open cur_progress_status;
                    fetch cur_progress_status into l_init_prog_status_code;
                    close cur_progress_status;

                    -- End modifications for Bug # 3879658.

                      PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_progress_rollup_id
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => l_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => l_next_prog_cycle_date
                      ,X_OBJECT_VERSION_ID               => p_task_ver_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
               ,X_PROGRESS_STATUS_CODE            => l_init_prog_status_code -- Bug # 3879658 -- 'PROGRESS_STAT_ON_TRACK' --maansari5/11
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => null
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_eff_rollup_pc
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => l_actual_start_DATE
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_DATE
                      ,X_EST_REMAINING_EFFORT            => null  --l_etc_effort
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => null
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,x_percent_complete_id             => null
                    ,X_STRUCTURE_TYPE                    => 'WORKPLAN'
                    ,X_PROJ_ELEMENT_ID                   => l_task_id
                    ,X_STRUCTURE_VERSION_ID              => null
                    ,X_PPL_ACT_EFFORT_TO_DATE            => null
                    ,X_EQPMT_ACT_EFFORT_TO_DATE          => null
                    ,X_EQPMT_ETC_EFFORT                  => null
                    ,X_OTH_ACT_COST_TO_DATE_TC           => null
                    ,X_OTH_ACT_COST_TO_DATE_FC           => null
                    ,X_OTH_ACT_COST_TO_DATE_PC           => null
                    ,X_OTH_ETC_COST_TC                   => null
                    ,X_OTH_ETC_COST_FC                   => null
                    ,X_OTH_ETC_COST_PC                   => null
                    ,X_PPL_ACT_COST_TO_DATE_TC           => null
                    ,X_PPL_ACT_COST_TO_DATE_FC           => null
                    ,X_PPL_ACT_COST_TO_DATE_PC           => null
                    ,X_PPL_ETC_COST_TC                   => null
                    ,X_PPL_ETC_COST_FC                   => null
                    ,X_PPL_ETC_COST_PC                   => null
                    ,X_EQPMT_ACT_COST_TO_DATE_TC         => null
                    ,X_EQPMT_ACT_COST_TO_DATE_FC         => null
                    ,X_EQPMT_ACT_COST_TO_DATE_PC         => null
                    ,X_EQPMT_ETC_COST_TC                 => null
                    ,X_EQPMT_ETC_COST_FC                 => null
                    ,X_EQPMT_ETC_COST_PC                 => null
                    ,X_EARNED_VALUE                      => l_earned_value
                    ,X_TASK_WT_BASIS_CODE                => null
                    ,X_SUBPRJ_PPL_ACT_EFFORT             => null
                    ,X_SUBPRJ_EQPMT_ACT_EFFORT           => null
                    ,X_SUBPRJ_PPL_ETC_EFFORT             => null
                    ,X_SUBPRJ_EQPMT_ETC_EFFORT           => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC      => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC      => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC      => null
                    ,X_SUBPRJ_PPL_ACT_COST_TC            => null
                    ,X_SUBPRJ_PPL_ACT_COST_FC            => null
                    ,X_SUBPRJ_PPL_ACT_COST_PC            => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_TC          => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_FC          => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_PC          => null
                    ,X_SUBPRJ_OTH_ETC_COST_TC            => null
                    ,X_SUBPRJ_OTH_ETC_COST_FC            => null
                    ,X_SUBPRJ_OTH_ETC_COST_PC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_TC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_FC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_PC            => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_TC          => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_FC          => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_PC          => null
                    ,X_SUBPRJ_EARNED_VALUE               => null
                    ,X_CURRENT_FLAG                      => 'Y'
                ,X_PROJFUNC_COST_RATE_TYPE                   => null
                ,X_PROJFUNC_COST_EXCHANGE_RATE               => null
              --  ,X_PROJFUNC_COST_RATE_DATE_TYPE              => null
                ,X_PROJFUNC_COST_RATE_DATE                   => null
                ,X_PROJ_COST_RATE_TYPE                       => null
                ,X_PROJ_COST_EXCHANGE_RATE                   => null
              --  ,X_PROJ_COST_RATE_DATE_TYPE                  => null
                ,X_PROJ_COST_RATE_DATE                       => null
                ,X_TXN_CURRENCY_CODE                         => null
                ,X_PROG_PA_PERIOD_NAME                       => PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(l_next_prog_cycle_date)  --maansari5/11
                ,X_PROG_GL_PERIOD_NAME                       => PA_PROGRESS_UTILS.Prog_Get_gl_Period_Name(l_next_prog_cycle_date)  --maansari5/11
                ,X_OTH_QUANTITY_to_date              => null  --maansari5/9
                ,X_OTH_ETC_QUANTITY              => null
        --bug 3621404
                ,X_OTH_ACT_RAWCOST_TO_DATE_TC               => null
                ,X_OTH_ACT_RAWCOST_TO_DATE_FC               => null
                ,X_OTH_ACT_RAWCOST_TO_DATE_PC           => null
                ,X_OTH_ETC_RAWCOST_TC           => null
                ,X_OTH_ETC_RAWCOST_FC           => null
                ,X_OTH_ETC_RAWCOST_PC           => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_TC   => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_FC   => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_PC   => null
                ,X_PPL_ETC_RAWCOST_TC           => null
                ,X_PPL_ETC_RAWCOST_FC           => null
                ,X_PPL_ETC_RAWCOST_PC           => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC         => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC         => null
                ,X_EQPMT_ETC_RAWCOST_TC         => null
                ,X_EQPMT_ETC_RAWCOST_FC         => null
                ,X_EQPMT_ETC_RAWCOST_PC         => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_TC       => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_FC       => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_PC       => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_TC       => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_FC       => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_PC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_TC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_FC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_PC       => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
        );
                --bug 3708948

                l_rollup_as_of_date := l_next_prog_cycle_date;


    END IF; -- IF cur_progress2%found THEN
    CLOSE cur_progress2;
    --bug 3708948 commented as this is causing new record to be inserted, moved this code up  Satish
    --l_rollup_as_of_date := l_next_prog_cycle_date;
   -- If workplan versioning is enabled for the project.
    ELSE -- Version Enabled
        -- If working progress exists then update the working progress rec.

         /*  Bug # 3755089. Modified the following cursor. */

            open cur_progress(p_project_id,l_object_id,p_task_ver_id,p_structure_version_id);
            fetch cur_progress into cur_progress_rec;
            if cur_progress%found then

                update pa_progress_rollup set
                --as_of_date = l_next_prog_cycle_date,
                estimated_remaining_effort = null --l_etc_effort
                ,completed_percentage = l_percent_complete
                ,eff_rollup_percent_comp = l_eff_rollup_pc
                ,earned_value = l_earned_value
                ,actual_start_date    = l_actual_start_date
                ,actual_finish_date    = l_actual_finish_date
                ,last_update_date = sysdate
                ,last_updated_by = l_user_id
                --,creation_date = sysdate
                --,created_by = l_user_id
                ,last_update_login = l_login_id
                where progress_rollup_id = cur_progress_rec.progress_rollup_id;

                l_rollup_as_of_date := cur_progress_rec.as_of_date;

            -- If working progress record does not exist.
            else
                -- If published progress record exists, set the as_of_date for the progress record

                close cur_progress;
                open c_max_as_of_date_wkg;  ---4501133
                fetch c_max_as_of_date_wkg into l_as_of_date;
                close c_max_as_of_date_wkg;
                if l_as_of_date is null then

                   open cur_progress2(p_project_id,l_object_id,p_task_ver_id,null,'Y');
                   fetch cur_progress2 into cur_progress_rec;
                   if cur_progress2%found then

                    if (cur_progress_rec.as_of_date > l_next_prog_cycle_date) then
                        l_as_of_date := cur_progress_rec.as_of_date;
                    else
                        l_as_of_date := l_next_prog_cycle_date;
                    end if;

                   /* Start code to fix issue in bug # 3755089. */

                  else
                    l_as_of_date := l_next_prog_cycle_date;

                    /* End code to fix issue in bug # 3755089. */

                  end if;
                  close cur_progress2;
                end if;

                l_rollup_as_of_date := l_as_of_date;

                -- Create a working progress record for the Task / Assignment.

                    l_progress_rollup_id := null;


            -- Start modifications for Bug # 3879658.

            open cur_progress_status;
            fetch cur_progress_status into l_init_prog_status_code;
            close cur_progress_status;

            -- End modifications for Bug # 3879658.

                      PA_PROGRESS_ROLLUP_PKG.INSERT_ROW(
                       X_PROGRESS_ROLLUP_ID              => l_progress_rollup_id
                      ,X_PROJECT_ID                      => p_project_id
                      ,X_OBJECT_ID                       => l_object_id
                      ,X_OBJECT_TYPE                     => p_object_type
                      ,X_AS_OF_DATE                      => l_as_of_date
                      ,X_OBJECT_VERSION_ID               => p_task_ver_id
                      ,X_LAST_UPDATE_DATE                => SYSDATE
                      ,X_LAST_UPDATED_BY                 => l_user_id
                      ,X_CREATION_DATE                   => SYSDATE
                      ,X_CREATED_BY                      => l_user_id
                      ,X_PROGRESS_STATUS_CODE            => l_init_prog_status_code -- Bug # 3879658 -- 'PROGRESS_STAT_ON_TRACK'   --maansari5/11
                      ,X_LAST_UPDATE_LOGIN               => l_login_id
                      ,X_INCREMENTAL_WORK_QTY            => null
                      ,X_CUMULATIVE_WORK_QTY             => null
                      ,X_BASE_PERCENT_COMPLETE           => null
                      ,X_EFF_ROLLUP_PERCENT_COMP         => l_eff_rollup_pc
                      ,X_COMPLETED_PERCENTAGE            => l_percent_complete
                      ,X_ESTIMATED_START_DATE            => null
                      ,X_ESTIMATED_FINISH_DATE           => null
                      ,X_ACTUAL_START_DATE               => l_actual_start_DATE
                      ,X_ACTUAL_FINISH_DATE              => l_actual_finish_DATE
                      ,X_EST_REMAINING_EFFORT            => null --l_etc_effort
                      ,X_BASE_PERCENT_COMP_DERIV_CODE    => null
                      ,X_BASE_PROGRESS_STATUS_CODE       => null
                      ,X_EFF_ROLLUP_PROG_STAT_CODE       => null
                      ,x_percent_complete_id             => null
                    ,X_STRUCTURE_TYPE                    => 'WORKPLAN'
                    ,X_PROJ_ELEMENT_ID                   => l_task_id
                    ,X_STRUCTURE_VERSION_ID              => p_structure_version_id
                    ,X_PPL_ACT_EFFORT_TO_DATE            => null
                    ,X_EQPMT_ACT_EFFORT_TO_DATE          => null
                    ,X_EQPMT_ETC_EFFORT                  => null
                    ,X_OTH_ACT_COST_TO_DATE_TC           => null
                    ,X_OTH_ACT_COST_TO_DATE_FC           => null
                    ,X_OTH_ACT_COST_TO_DATE_PC           => null
                    ,X_OTH_ETC_COST_TC                   => null
                    ,X_OTH_ETC_COST_FC                   => null
                    ,X_OTH_ETC_COST_PC                   => null
                    ,X_PPL_ACT_COST_TO_DATE_TC           => null
                    ,X_PPL_ACT_COST_TO_DATE_FC           => null
                    ,X_PPL_ACT_COST_TO_DATE_PC           => null
                    ,X_PPL_ETC_COST_TC                   => null
                    ,X_PPL_ETC_COST_FC                   => null
                    ,X_PPL_ETC_COST_PC                   => null
                    ,X_EQPMT_ACT_COST_TO_DATE_TC         => null
                    ,X_EQPMT_ACT_COST_TO_DATE_FC         => null
                    ,X_EQPMT_ACT_COST_TO_DATE_PC         => null
                    ,X_EQPMT_ETC_COST_TC                 => null
                    ,X_EQPMT_ETC_COST_FC                 => null
                    ,X_EQPMT_ETC_COST_PC                 => null
                    ,X_EARNED_VALUE                      => l_earned_value
                    ,X_TASK_WT_BASIS_CODE                => null
                    ,X_SUBPRJ_PPL_ACT_EFFORT             => null
                    ,X_SUBPRJ_EQPMT_ACT_EFFORT           => null
                    ,X_SUBPRJ_PPL_ETC_EFFORT             => null
                    ,X_SUBPRJ_EQPMT_ETC_EFFORT           => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC      => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC      => null
                    ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC      => null
                    ,X_SUBPRJ_PPL_ACT_COST_TC            => null
                    ,X_SUBPRJ_PPL_ACT_COST_FC            => null
                    ,X_SUBPRJ_PPL_ACT_COST_PC            => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_TC          => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_FC          => null
                    ,X_SUBPRJ_EQPMT_ACT_COST_PC          => null
                    ,X_SUBPRJ_OTH_ETC_COST_TC            => null
                    ,X_SUBPRJ_OTH_ETC_COST_FC            => null
                    ,X_SUBPRJ_OTH_ETC_COST_PC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_TC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_FC            => null
                    ,X_SUBPRJ_PPL_ETC_COST_PC            => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_TC          => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_FC          => null
                    ,X_SUBPRJ_EQPMT_ETC_COST_PC          => null
                    ,X_SUBPRJ_EARNED_VALUE               => null
                    ,X_CURRENT_FLAG                      => 'Y' -- /*  Bug # 3755089. */
            ,X_PROJFUNC_COST_RATE_TYPE                   => null
            ,X_PROJFUNC_COST_EXCHANGE_RATE               => null
          --  ,X_PROJFUNC_COST_RATE_DATE_TYPE              => null
            ,X_PROJFUNC_COST_RATE_DATE                   => null
            ,X_PROJ_COST_RATE_TYPE                       => null
            ,X_PROJ_COST_EXCHANGE_RATE                   => null
          --  ,X_PROJ_COST_RATE_DATE_TYPE                  => null
            ,X_PROJ_COST_RATE_DATE                       => null
            ,X_TXN_CURRENCY_CODE                         => null
            ,X_PROG_PA_PERIOD_NAME                       => PA_PROGRESS_UTILS.Prog_Get_Pa_Period_Name(l_as_of_date)  --maansari5/11
            ,X_PROG_GL_PERIOD_NAME                       => PA_PROGRESS_UTILS.Prog_Get_gl_Period_Name(l_as_of_date)  --maansari5/11
            ,X_OTH_QUANTITY_to_date                              => null   --maansari5/9
            ,X_OTH_ETC_QUANTITY                          => null
--bug 3621404
                ,X_OTH_ACT_RAWCOST_TO_DATE_TC               => null
                ,X_OTH_ACT_RAWCOST_TO_DATE_FC               => null
                ,X_OTH_ACT_RAWCOST_TO_DATE_PC           => null
                ,X_OTH_ETC_RAWCOST_TC           => null
                ,X_OTH_ETC_RAWCOST_FC           => null
                ,X_OTH_ETC_RAWCOST_PC           => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_TC   => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_FC   => null
                ,X_PPL_ACT_RAWCOST_TO_DATE_PC   => null
                ,X_PPL_ETC_RAWCOST_TC           => null
                ,X_PPL_ETC_RAWCOST_FC           => null
                ,X_PPL_ETC_RAWCOST_PC           => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_TC   => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_FC         => null
                ,X_EQPMT_ACT_RAWCOST_TO_DATE_PC         => null
                ,X_EQPMT_ETC_RAWCOST_TC         => null
                ,X_EQPMT_ETC_RAWCOST_FC         => null
                ,X_EQPMT_ETC_RAWCOST_PC         => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_TC    => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_FC    => null
                ,X_SP_OTH_ACT_RAWCOST_TODATE_PC    => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_TC       => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_FC       => null
                ,X_SUBPRJ_PPL_ACT_RAWCOST_PC       => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC     => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC     => null
                ,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC     => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_TC       => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_FC       => null
                ,X_SUBPRJ_OTH_ETC_RAWCOST_PC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_TC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_FC       => null
                ,X_SUBPRJ_PPL_ETC_RAWCOST_PC       => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC     => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC     => null
                ,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC     => null
);

   end if; -- if cur_progress%found then
   -- If working progress record does not exist.

    /* Start code to fix issue in bug # 3755089. */

    if cur_progress%isopen then

    /* End code to fix issue in bug # 3755089. */

        close cur_progress;

    /* Start code to fix issue in bug # 3755089. */

    end if;

    /* End code to fix issue in bug # 3755089. */

  end if; -- If workplan versioning is enabled for the project.


  -- end if;--IF   Bug 3856161 (nvl(p_percent_complete,0) > 0 AND p_percent_complete <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  END IF; -- Bug 3856161  ( (nvl(p_percent_complete,0) > 0 AND p_percent_complete <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)


    IF p_object_type = 'PA_TASKS' THEN-- Bug 4498610 : Added IF
    -- Bug 3976633 : Added cursor cur_progress_exists
    OPEN cur_progress_exists (p_project_id, l_task_id, p_structure_version_id, l_version_enabled);
    FETCH cur_progress_exists INTO l_progress_exists;
    CLOSE cur_progress_exists;

    IF  NVL(l_progress_exists, 'N') = 'Y' THEN -- Bug 3976633

    --maansari5/11
   OPEN c_get_task_weight_method;
   FETCH c_get_task_weight_method INTO l_rollup_method;
   CLOSE c_get_task_weight_method;



   -- Call rollup_progress_pvt api for this task.
   IF l_debug_mode  = 'Y' THEN
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'Calling Rollup For Tasks', x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_task_id='||l_task_id, x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_task_ver_id='||p_task_ver_id, x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_method='||l_rollup_method, x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_as_of_date='||l_rollup_as_of_date, x_Log_Level=> 3);
    pa_debug.write(x_Module=>'PA_PROGRESS_PUB.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_as_of_date='||l_rollup_as_of_date, x_Log_Level=> 3);
   END IF;

   -- 4591321 : Always call populate_pji_tab_for_plan
                 pa_progress_pub.populate_pji_tab_for_plan(
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_project_id            => p_project_id,
                        p_structure_version_id  => p_structure_version_id,
                        p_baselined_str_ver_id  => PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(p_project_id),
                        p_structure_type        => 'WORKPLAN',
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data
                        );

                 IF  l_return_status <> 'S' THEN
                    RAISE  FND_API.G_EXC_ERROR;
                 END IF;

    -- Bug 3861259 End


                PA_PROGRESS_PUB.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list             => p_init_msg_list
                ,p_commit                    => p_commit
                ,p_validate_only             => p_validate_only
                ,p_project_id                => p_project_id
                ,p_structure_version_id      => p_structure_version_id
                ,p_calling_module            => p_calling_module --BUG 3919800, rtarway
           --maansari5/10
                ,p_object_type               => p_object_type
                ,p_object_id                 => l_task_id
                ,p_object_version_id         => p_task_ver_id
                ,p_task_version_id           => p_task_ver_id
           --maansari5/10
                ,p_wp_rollup_method          => l_rollup_method --maansari 5/11
                ,p_structure_type            => 'WORKPLAN'      --maansari 5/11
                ,p_as_of_date                => l_rollup_as_of_date
                ,x_return_status             => l_return_status
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);
    END IF ;--IF    NVL(l_progress_exists, 'N') = 'Y' THEN
    END IF;-- p_object_type = 'PA_TASKS' THEN-- Bug 4498610 : Added END IF
  END IF; -- if (p_object_type ='PA_TASKS') then

    -- Code to insert progress records nto the pa_progress_rollup_table.

    /* END: The above actions are to be performed only when p_object_type = 'PA_TASKS'. */


    /* BEGIN: The following actions are to be performed only when p_object_type = 'PA_ASSIGNMENTS'. */

   IF (p_object_type ='PA_ASSIGNMENTS') then

    -- Call rollup API only is there is a working progress for the given task_version and
        -- structure_version. The as_of_date will then be the max(as_of_date() of the working progress.
     IF l_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'Entered For Assignments', x_Log_Level=> 3);
    END IF;

        --bug 4105720,  get the task id
    OPEN c_proj_element_id;
    FETCH c_proj_element_id INTO l_task_id;
    CLOSE c_proj_element_id;

    -- Bug 3976633 : Added cursor cur_progress_exists
    OPEN cur_progress_exists (p_project_id, l_task_id, p_structure_version_id, l_version_enabled);
    FETCH cur_progress_exists INTO l_progress_exists;
    CLOSE cur_progress_exists;

     IF l_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_task_id '||l_task_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_progress_exists '||l_progress_exists, x_Log_Level=> 3);
    END IF;

    IF  NVL(l_progress_exists, 'N') = 'Y' THEN -- Bug 3976633


    open c_max_as_of_date_wkg;
    fetch c_max_as_of_date_wkg into l_rollup_as_of_date;
    --if (c_max_as_of_date_wkg%FOUND) then Bug 3856161
    IF l_rollup_as_of_date IS NOT NULL THEN

    --maansari5/11
            OPEN c_get_task_weight_method;
            FETCH c_get_task_weight_method INTO l_rollup_method;
            CLOSE c_get_task_weight_method;

                --bug 4105720, moved this code above
                /*OPEN c_proj_element_id;
                FETCH c_proj_element_id INTO l_task_id;
                CLOSE c_proj_element_id;*/

     IF l_debug_mode  = 'Y' THEN
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'Calling Rollup For Assignments', x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_task_id='||l_task_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'p_task_ver_id='||p_task_ver_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_method='||l_rollup_method, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_as_of_date='||l_rollup_as_of_date, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_TASK_PUB1.UPDATE_TASK_DET_SCH_INFO', x_Msg => 'l_rollup_as_of_date='||l_rollup_as_of_date, x_Log_Level=> 3);
    END IF;
   -- 4591321 : Always call populate_pji_tab_for_plan

            pa_progress_pub.populate_pji_tab_for_plan(
                        p_init_msg_list         => FND_API.G_FALSE,
                        --p_calling_module        => p_calling_module,
                        p_project_id            => p_project_id,
                        p_structure_version_id  => p_structure_version_id,
                        p_baselined_str_ver_id  => PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(p_project_id),
                        p_structure_type        => 'WORKPLAN',
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data
                        );
                 IF  l_return_status <> 'S' THEN
                    RAISE  FND_API.G_EXC_ERROR;
                 END IF;
    -- Bug 3861259 End



        -- Call rollup_progress_pvt api for this task or assignment.
                PA_PROGRESS_PUB.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list             => p_init_msg_list
                ,p_commit                    => p_commit
                ,p_validate_only             => p_validate_only
                ,p_project_id                => p_project_id
                ,p_structure_version_id      => p_structure_version_id
                ,p_calling_module            => p_calling_module--BUG 3919800, rtarway
           --maansari5/10
                ,p_object_type               => 'PA_TASKS' -- p_object_type Bug 3856161
                ,p_object_id                 => l_task_id
                ,p_object_version_id         => p_task_ver_id
                ,p_task_version_id           => p_task_ver_id
           --maansari5/10
            ,p_wp_rollup_method          => l_rollup_method --maansari 5/11
                ,p_structure_type            => 'WORKPLAN'      --maansari 5/11
                ,p_as_of_date                => l_rollup_as_of_date
                ,x_return_status             => l_return_status
                ,x_msg_count                 => l_msg_count
                ,x_msg_data                  => l_msg_data);
           -- Code to insert progress records nto the pa_progress_rollup_table.

    end if;
        close c_max_as_of_date_wkg;
    END IF; --   IF     NVL(l_progress_exists, 'N') = 'Y'
    end if;

    /* END: The above actions are to be performed only when p_object_type = 'PA_ASSIGNMENTS'. */

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

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_task_det_sch;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_task_det_sch;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'update_task_det_sch_info',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END update_task_det_sch_info;


-- API name                      : Copy_Tasks_In_Bulk
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER      N   Not Null    1.0
-- p_init_msg_list    IN    VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit               IN    VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only    IN    VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level     IN    NUMBER      N   Null        FND_API.G_VALID_LEVEL_FULL
-- p_calling_module   IN    VARCHAR2    N   Null        SELF_SERVICE
-- p_debug_mode           IN    VARCHAR2    N   Null        N
-- p_max_msg_count        IN    NUMBER      N   NULL        PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_project_id       IN  NUMBER        N   NULL        PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_project_name     IN  VARCHAR2      N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structre_id      IN  NUMBER        N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_name   IN  VARCHAR2      N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structure_version_id   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_version_name IN  VARCHAR2 N  NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_task_version_id        IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_task_name  IN  VARCHAR2    N   NULL            PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_dest_structure_version_id  IN  NUMBER  N   NOT NULL
-- p_dest_task_version_id   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_dest_project_id        IN NUMBER NULL PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_copy_option            IN  VARCHAR2    N   NOT NULL
-- p_peer_or_sub            IN  VARCHAR2    N   NOT NULL
-- x_return_status          OUT     VARCHAR2    N   NULL
-- x_msg_count              OUT     NUMBER      N   NULL
-- x_msg_data               OUT     VARCHAR2    N   NULL
--
--  History
--
--  22-FEB-05                Created   avaithia
--
--

PROCEDURE Copy_Tasks_In_Bulk
(
 p_api_version            IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit                 IN    VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level   IN    NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_id         IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_name       IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_id       IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_name     IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_version_id IN NUMBER       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_version_name   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_task_version_id_tbl  IN   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_src_task_name          IN    VARCHAR2     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_dest_structure_version_id    IN  NUMBER,
 p_dest_task_version_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_dest_project_id      IN  NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_copy_option        IN    VARCHAR2,
 p_peer_or_sub        IN    VARCHAR2,
 p_prefix             IN    VARCHAR2,
 p_structure_type              IN              VARCHAR2        :='WORKPLAN',
 p_cp_dependency_flag          IN              VARCHAR2        :='N',
 p_cp_deliverable_asso_flag    IN              VARCHAR2        :='N',
 p_cp_tk_assignments_flag      IN              VARCHAR2        :='N',
 p_cp_people_flag              IN              VARCHAR2        :='N',
 p_cp_financial_elem_flag      IN              VARCHAR2        :='N',
 p_cp_material_items_flag      IN              VARCHAR2        :='N',
 p_cp_equipment_flag           IN              VARCHAR2        :='N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'COPY_TASKS_IN_BULK';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_data                          VARCHAR2(2000);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);

   l_src_project_id       NUMBER;
   l_src_structure_id         NUMBER;
   l_src_structure_version_id   NUMBER;

   l_dest_project_id       NUMBER ;
   l_task_unpub_ver_status_code  PA_PROJ_ELEMENT_VERSIONS.TASK_UNPUB_VER_STATUS_CODE%TYPE;
   l_dest_structure_id    NUMBER;
   l_template_flag        VARCHAR2(1);
   l_fin_task_flag        VARCHAR2(1);

   l_shared               VARCHAR2(1);
   l_ver_enabled          VARCHAR2(1);
   l_copy_external_flag   VARCHAR2(1);

   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

  CURSOR cur_proj_is_template(c_project_id NUMBER)
  IS     select 'Y'
           from pa_projects_all
          where project_id = c_project_id
            and template_flag = 'Y';

   CURSOR cur_dest_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_dest_task_version_id;

    CURSOR cur_struc_id( x_structure_version_id NUMBER, x_project_id NUMBER )
    IS
    SELECT proj_element_id
     FROM pa_proj_elem_ver_structure
    WHERE element_version_id = x_structure_version_id
    AND project_id = x_project_id;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;
BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.COPY_TASKS_IN_BULK');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.COPY_TASKS_IN_BULK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint copy_tasks_in_bulk;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

IF p_calling_module = 'SELF_SERVICE' THEN

        /*Product Code related validation*/
        /* This is not needed as now we are passing
           Destination Project ID from Self Service (TaskLiteVORowImpl.java - copyTasks method)

    OPEN cur_dest_proj_id;
    FETCH cur_dest_proj_id into l_dest_project_id;
    CLOSE cur_dest_proj_id;
        */
        l_dest_project_id := p_dest_project_id ;

        OPEN cur_proj_is_template(l_dest_project_id) ;
        FETCH cur_proj_is_template into l_template_flag ;
        CLOSE cur_proj_is_template;

        OPEN get_product_code(l_dest_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN

          pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
                 P_ERROR_STACK                    => l_err_stack,
                 P_ERROR_STAGE                => l_err_stage );

           IF l_err_code <> 0 THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
           END IF;

           IF l_add_task_allowed = 'N' THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_CANNOT_COPY');
                raise FND_API.G_EXC_ERROR;
           END IF;

        END IF;

    /*Project Name to ID validation*/
/* All Name to ID validations can be skipped in case of SS
      IF ((p_src_project_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_project_name IS NOT NULL)) OR
         ((p_src_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_project_id IS NOT NULL)) THEN
        --Call Check API.
          PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
            p_project_name   => p_src_project_name,
            p_project_id     => p_src_project_id,
            x_project_id     => l_src_project_id,
            x_return_status  => l_return_status,
            x_error_msg_code => l_error_msg_code);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;
       END IF;
*/
      /*Structure Name to ID Validation*/
/*
      IF ((p_src_structure_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_structure_name IS NOT NULL)) OR
         ((p_src_structure_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_structure_id IS NOT NULL)) THEN
        --Call Check API.
          PA_PROJECT_STRUCTURE_UTILS.Structure_Name_Or_Id
                           (
                              p_project_id             => l_src_project_id
                             ,p_structure_name         => p_src_structure_name
                             ,p_structure_id           => p_src_structure_id
                             ,x_structure_id           => l_src_structure_id
                             ,x_return_status          => l_return_status
                             ,x_error_message_code     => l_error_msg_code
                            );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;
      END IF;
*/
      /*Structure Version Name to ID conversion*/
/*
      IF ((p_src_structure_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_src_structure_version_name IS NOT NULL)) OR
         ((p_src_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_src_structure_version_id IS NOT NULL)) THEN
        --Call Check API.
           l_src_structure_version_id := p_src_structure_version_id;
          PA_PROJECT_STRUCTURE_UTILS.Structure_Version_Name_Or_Id
                                (
                              p_structure_id            => l_src_structure_id
                             ,p_structure_version_name  => p_src_structure_version_name
                             ,p_structure_version_id    => p_src_structure_version_id
                             ,x_structure_version_id    => l_src_structure_version_id
                             ,x_return_status           => l_return_status
                             ,x_error_message_code      => l_error_msg_code
                            );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => l_error_msg_code);
           END IF;

      END IF;
*/
      /*Mandatory Params check*/
      IF (p_src_project_id IS NULL OR p_src_structure_id IS NULL OR
       p_src_structure_version_id IS NULL )
      THEN
--        dbms_output.put_line( 'Project Id '||l_src_project_id );
--        dbms_output.put_line( 'Structure Id '||l_src_structure_id );
--        dbms_output.put_line( 'Structure Ver Id '||l_src_structure_version_id );

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_PS_NOT_ENOUGH_PARAMS' );
           x_msg_data := ' BULK API : PA_PS_NOT_ENOUGH_PARAMS';
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE  FND_API.G_EXC_ERROR;
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

    IF p_copy_option NOT IN( 'PA_ENTIRE_VERSION', 'PA_TASK_ONLY', 'PA_TASK_SUBTASK'  )
    THEN

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_PS_WRONG_COPY_OPTION' );
        x_msg_data := 'PA_PS_WRONG_COPY_OPTION';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    /*====================================================================
     ALL BASIC VALIDATIONS COMPLETE RELEVANT TO VALIDITY OF PASSED PARAMS
     ====================================================================*/

   /* Derive the Destination Structure ID (ProjElementId) from the passed pa_dest_structure_version_id*/
   OPEN cur_struc_id(p_dest_structure_version_id , l_dest_project_id);
   FETCH cur_struc_id into l_dest_structure_id ;
   CLOSE cur_struc_id ;

   /*4201927 : Derive values for sharing enabled and Versioning Enabled */
       l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  l_dest_project_id);

       l_ver_enabled :=
PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(l_dest_project_id);

   /* Derive the value for Copy External Flag*/
    IF p_src_project_id = l_dest_project_id
    THEN
        l_copy_external_flag := 'N';
    ELSE
        l_copy_external_flag := 'Y';
    ENd IF;

   /* Copied from Copy_Task API : task version status changes
      This need not be executed for each and every task */


   IF (l_template_flag = 'N') THEN
          --check if structure is shared
          --  if shared, check if versioned
          --    'WORKING' if versioned; 'PUBLISHED' if not
          --  if split, check if 'FINANCIAL'
          --    'PUBLISHED' if financial
          --    check if versioned
          --    'WORKING' if versioend; 'PUBLISHED' if not
          IF ('Y' = l_shared) THEN
            IF ('Y' = l_ver_enabled) THEN
              l_task_unpub_ver_status_code := 'WORKING';
            ELSE
              l_task_unpub_ver_status_code := 'PUBLISHED';
            END IF;
          ELSE --split
            IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_dest_structure_id,'FINANCIAL') AND
                'N' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_dest_structure_id,'WORKPLAN')) THEN
              l_task_unpub_ver_status_code := 'PUBLISHED';
            ELSE --workplan only
              IF ('Y' = l_ver_enabled) THEN
                l_task_unpub_ver_status_code := 'WORKING';
              ELSE
                l_task_unpub_ver_status_code := 'PUBLISHED';
              END IF;
            END IF;
          END IF;
   ELSE
          l_task_unpub_ver_status_code := 'WORKING';
   END IF;

   /*Derive valie for the p_fin_task_flag*/
        IF p_structure_type = 'WORKPLAN'
        THEN
           IF
           PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_dest_project_id) =
           'SHARE_FULL'
           THEN
              l_fin_task_flag := 'Y';
           ELSE
              l_fin_task_flag := 'N';
           END IF;
        ELSE
            l_fin_task_flag := 'Y';
        END IF;

    /*Now retrieve the task version id's passed in the form of array table from the UI
    and call the Copy Task API (singular version)*/


IF nvl(p_src_task_version_id_tbl.LAST,0)>0 THEN
    FOR i IN p_src_task_version_id_tbl.FIRST..p_src_task_version_id_tbl.LAST LOOP
               PA_TASK_PUB1.Copy_Task(
           p_init_msg_list         => FND_API.G_FALSE,
               p_src_project_id                      => p_src_project_id,
               p_src_project_name                    => p_src_project_name,
               p_src_structure_id                    => p_src_structure_id ,
               p_src_structure_name                  => p_src_structure_name,
               p_src_structure_version_id            => p_src_structure_version_id ,
               p_src_structure_version_name          => p_src_structure_version_name,
               p_src_task_version_id                 => p_src_task_version_id_tbl(i),
               p_src_task_name                       => p_src_task_name,
               p_dest_structure_id           => l_dest_structure_id,
               p_dest_structure_version_id           => p_dest_structure_version_id,
               p_dest_task_version_id                => p_dest_task_version_id,
               p_dest_project_id                     => l_dest_project_id,
               p_task_unpub_ver_status_code          => l_task_unpub_ver_status_code,
               p_fin_task_flag                       => l_fin_task_flag,
               p_sharing_enabled                     => l_shared,
               p_versioning_enabled                  => l_ver_enabled,
               p_copy_external_flag                  => l_copy_external_flag,
               p_copy_option                         => p_copy_option,
               p_peer_or_sub                         => p_peer_or_sub,
               p_prefix                              => p_prefix,
               p_structure_type                      => p_structure_type,
               p_cp_dependency_flag                  => p_cp_dependency_flag,
               p_cp_deliverable_asso_flag            => p_cp_deliverable_asso_flag,
               p_cp_tk_assignments_flag              => p_cp_tk_assignments_flag,
               p_cp_people_flag                      => p_cp_people_flag,
               p_cp_financial_elem_flag              => p_cp_financial_elem_flag,
               p_cp_material_items_flag              => p_cp_material_items_flag,
               p_cp_equipment_flag                   => p_cp_equipment_flag,
               p_called_from_bulk_api                => 'Y',
               x_return_status                       => x_return_status,
               x_msg_count                           => x_msg_count,
               x_msg_data                            => x_msg_data
               );
               if(x_return_status <> FND_API.G_RET_STS_SUCCESS)
               then
           RAISE FND_API.G_EXC_ERROR ;
               End if;
    END LOOP;

 END IF;

END IF; /*End If Calling Module is self service*/
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Tasks_in_bulk;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := Fnd_Msg_Pub.count_msg;
     IF x_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
       END IF;
       x_msg_data := l_data;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Tasks_in_bulk;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'COPY_TASKS_IN_BULK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Copy_Tasks_in_bulk;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'COPY_TASKS_IN_BULK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Copy_Tasks_In_Bulk;

--- API name                      : MOVE_TASK_VERSIONS_IN_BULK
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER      N   Not Null    1.0
-- p_init_msg_list        IN    VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit               IN    VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only        IN    VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level     IN    NUMBER      N   Null        FND_API.G_VALID_LEVEL_FULL
-- p_calling_module       IN    VARCHAR2    N   Null        SELF_SERVICE
-- p_debug_mode           IN    VARCHAR2    N   Null        N
-- p_max_msg_count        IN    NUMBER      N   NULL        PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN    NUMBER      N   NULL        PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id_tbl  IN     SYSTEM.PA_NUM_TBL_TYPE N NOT NULL  SYSTEM.PA_NUM_TBL_TYPE()
-- p_ref_task_version_id  IN     NUMBER     N   Not Null
-- p_ref_project_id       IN     NUMBER     N   Not Null /*4269830*/
-- p_peer_or_sub          IN     VARCHAR2   N   Not Null
-- p_record_version_number_tbl  IN  SYSTEM.PA_NUM_TBL_TYPE N NOT NULL  SYSTEM.PA_NUM_TBL_TYPE()
-- x_return_status          OUT     VARCHAR2    N   NULL
-- x_msg_count              OUT     NUMBER      N   NULL
-- x_msg_data               OUT     VARCHAR2    N   NULL
--
--  History
--
--  23-FEB-05                Created   avaithia
--  29-MAR-05                Modified  avaithia   4269830 : Performance Tuning done
--
PROCEDURE MOVE_TASK_VERSIONS_IN_BULK
   (     p_api_version           IN     NUMBER   := 1.0,
     p_init_msg_list         IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
     p_validate_only         IN     VARCHAR2 := FND_API.G_TRUE,
     p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     p_calling_module        IN     VARCHAR2 := 'SELF_SERVICE',
     p_debug_mode            IN     VARCHAR2 := 'N',
     p_max_msg_count         IN     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
     p_structure_version_id  IN     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
     p_task_version_id_tbl   IN     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
     p_ref_task_version_id   IN     NUMBER,
     p_ref_project_id        IN     NUMBER, /*4269830*/
     p_peer_or_sub           IN     VARCHAR2,
     p_record_version_number_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
     x_return_status                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name                      CONSTANT VARCHAR(30) := 'MOVE_TASK_VERSIONS_IN_BULK';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_data                          VARCHAR2(2000);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                     VARCHAR2(250);

   l_delete_project_allowed      VARCHAR2(1);
   l_update_proj_num_allowed      VARCHAR2(1);
   l_update_proj_name_allowed    VARCHAR2(1);
   l_update_proj_desc_allowed    VARCHAR2(1);
   l_update_proj_dates_allowed    VARCHAR2(1);
   l_update_proj_status_allowed  VARCHAR2(1);
   l_update_proj_manager_allowed  VARCHAR2(1);
   l_update_proj_org_allowed      VARCHAR2(1);
   l_add_task_allowed            VARCHAR2(1);
   l_delete_task_allowed          VARCHAR2(1);
   l_update_task_num_allowed      VARCHAR2(1);
   l_update_task_name_allowed    VARCHAR2(1);
   l_update_task_dates_allowed    VARCHAR2(1);
   l_update_task_desc_allowed    VARCHAR2(1);
   l_update_parent_task_allowed  VARCHAR2(1);
   l_update_task_org_allowed      VARCHAR2(1);

   ref_task_temp_version_id       NUMBER; -- Added new variable for Bug 6628382

   l_err_code         NUMBER        := 0;
   l_err_stack        VARCHAR2(200) := NULL;
   l_err_stage        VARCHAR2(200) := NULL;

   l_pm_product_code pa_projects_all.pm_product_code%TYPE;

   l_cur_project_id      NUMBER;
   CURSOR cur_proj_id
   IS
     SELECT project_id
       FROM pa_proj_element_versions
      WHERE element_version_id = p_structure_version_id;

   CURSOR get_product_code ( c_project_id NUMBER ) IS
   SELECT pm_product_code
   FROM PA_PROJECTS_ALL
   WHERE project_id = c_project_id;

   /*4269830 : Performance Enhancements : Start */
    CURSOR cur_struc_type( c_structure_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppst.proj_element_id = c_structure_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = 'FINANCIAL' ;

    CURSOR cur_pub_versions( c_structure_id NUMBER, c_project_id NUMBER ) is
      select 'Y'
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         AND project_id = c_project_id
         and STATUS_CODE = 'STRUCTURE_PUBLISHED';

   l_versioned      VARCHAR2(1) := 'N';
   l_shared         VARCHAR2(1) := 'N';
   l_sharing_code   VARCHAR2(30);

   l_task_version_id            NUMBER;
   l_structure_id               NUMBER;
   l_published_version          VARCHAR2(1);
   l_wp_type                    VARCHAR2(1);
   l_fin_type			VARCHAR2(1);

   l_weighting_basis_code       VARCHAR2(30);
   l_check_third_party_flag     VARCHAR2(1);
   l_dummy_char        VARCHAR2(1);

   /*4269830 : Performance Enhancements : End*/

BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.MOVE_TASK_VERSIONS_IN_BULK');

    x_return_status :=  FND_API.G_RET_STS_SUCCESS ;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.MOVE_TASK_VERSIONS_IN_BULK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint MOVE_TASK_VERSIONS_IN_BULK ;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;
    IF p_calling_module = 'SELF_SERVICE' THEN

        /*Product Code related validation*/

        /* 4269830 : This is not needed as now we are passing
           Destination Project ID from Self Service (TaskLiteVORowImpl.java - moveTasks method)
        OPEN cur_proj_id ;
        FETCH cur_proj_id into l_cur_project_id;
        CLOSE cur_proj_id;
         */
        l_cur_project_id := p_ref_project_id;

        OPEN get_product_code(l_cur_project_id);
        FETCH get_product_code INTO l_pm_product_code;
        CLOSE get_product_code;

        If l_pm_product_code IS NOT NULL THEN
                pa_pm_controls.Get_Project_actions_allowed
                (P_PM_PRODUCT_CODE                => l_pm_product_code,
                 P_DELETE_PROJECT_ALLOWED         => l_delete_project_allowed,
                 P_UPDATE_PROJ_NUM_ALLOWED        => l_update_proj_num_allowed,
                 P_UPDATE_PROJ_NAME_ALLOWED       => l_update_proj_name_allowed,
                 P_UPDATE_PROJ_DESC_ALLOWED       => l_update_proj_desc_allowed,
                 P_UPDATE_PROJ_DATES_ALLOWED      => l_update_proj_dates_allowed,
                 P_UPDATE_PROJ_STATUS_ALLOWED     => l_update_proj_status_allowed,
                 P_UPDATE_PROJ_MANAGER_ALLOWED    => l_update_proj_manager_allowed,
                 P_UPDATE_PROJ_ORG_ALLOWED        => l_update_proj_org_allowed,
                 P_ADD_TASK_ALLOWED               => l_add_task_allowed,
                 P_DELETE_TASK_ALLOWED            => l_delete_task_allowed,
                 P_UPDATE_TASK_NUM_ALLOWED        => l_update_task_num_allowed,
                 P_UPDATE_TASK_NAME_ALLOWED       => l_update_task_name_allowed,
                 P_UPDATE_TASK_DATES_ALLOWED      => l_update_task_dates_allowed,
                 P_UPDATE_TASK_DESC_ALLOWED       => l_update_task_desc_allowed,
                 P_UPDATE_PARENT_TASK_ALLOWED     => l_update_parent_task_allowed,
                 P_UPDATE_TASK_ORG_ALLOWED        => l_update_task_org_allowed,
                 P_ERROR_CODE                 => l_err_code,
                 P_ERROR_STACK                    => l_err_stack,
                 P_ERROR_STAGE                => l_err_stage );

                 IF l_err_code <> 0 THEN
                     PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => l_err_stage);
                 END IF;
                 IF l_update_parent_task_allowed = 'N' THEN
                       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_PM_NO_MOVE_TASK');
                       raise FND_API.G_EXC_ERROR;
                 END IF;
        End If;

    End If; /* End if calling module is self service*/

    /*4269830 : Performance Enhancements
      1)Derive the variables l_shared , l_sharing_code ,l_wp_type,l_fin_type
        l_versioned,l_structure_id,l_published_version,l_weighting_basis_Code
        ONLY once in the BULK API and pass it as params to the Move Task Version API
     */

     l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(p_ref_project_id);
     l_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_ref_project_id);

     -- Bug Fix 4764891.
     -- The following lines have the structure types usage messed up.
     -- Correcting the structure types which are passed to the get_struct_type_for_version.
     -- l_wp_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL');
     -- l_fin_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN');

     l_wp_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'WORKPLAN');
     l_fin_type := PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL');

     -- End of Bug Fix 4764891.

     l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_ref_project_id);
     l_weighting_basis_Code := PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(p_ref_project_id);
     l_check_third_party_flag := PA_Project_Structure_Utils.Check_Third_Party_Sch_Flag(p_ref_project_id);

     IF nvl(p_task_version_id_tbl.LAST,0)>0 THEN
         l_task_version_id := p_task_version_id_tbl(1);

         SELECT proj_element_id INTO l_structure_id
         FROM pa_proj_element_versions
        WHERE element_version_id =  ( Select parent_structure_version_id
                                   from pa_proj_element_versions
                                  where element_version_id = l_task_version_id )
          AND object_type = 'PA_STRUCTURES';
        -----------------------------------------------------------
        OPEN cur_struc_type( l_structure_id );
        FETCH cur_struc_type INTO l_dummy_char;

        IF cur_struc_type%FOUND
        THEN
             --If structure has any published versions.
             l_published_version := 'N';
             OPEN cur_pub_versions( l_structure_id, p_ref_project_id );
             FETCH cur_pub_versions INTO l_published_version;
             CLOSE cur_pub_versions;
        END IF;

        CLOSE cur_struc_type;
        -----------------------------------------------------------
     END IF;  -- End If Atleast one task has been selected for moving

    /*4269830 : End*/

    /*Now retrieve the task version id's passed in the form of array table from the UI
    and call the Move Task API (singular version)*/

    ref_task_temp_version_id := p_ref_task_version_id; -- Bug 6628382

IF nvl(p_task_version_id_tbl.LAST,0)>0 THEN
    FOR i IN p_task_version_id_tbl.FIRST..p_task_version_id_tbl.LAST LOOP
               PA_TASK_PUB1.Move_Task_Version(
               p_init_msg_list                       => FND_API.G_FALSE,
               p_structure_version_id                => p_structure_version_id,
               p_task_version_id                     => p_task_version_id_tbl(i),
               p_ref_task_version_id                 => ref_task_temp_version_id, --p_ref_task_version_id, -- Bug 6628382
               p_peer_or_sub                         => p_peer_or_sub,
               p_record_version_number               => p_record_version_number_tbl(i),
               /*======================================================================
               4269830 : New params introduced for Perf Enhancement: Start
                *=====================================================================*/
               p_ref_project_id                      => p_ref_project_id,
	       p_structure_id			     => l_structure_id,
	       p_published_version		     => l_published_version,
	       p_shared 			     => l_shared ,
	       p_sharing_code 			     => l_sharing_code,
	       p_versioned			     => l_versioned,
               p_wp_type			     => l_wp_type,
	       p_fin_type			     => l_fin_type,
	       p_weighting_basis_code	             => l_weighting_basis_code,
	       p_check_third_party_flag              => l_check_third_party_flag,
               /*======================================================================
               4269830 : New params introduced for Perf Enhancement : End
               *======================================================================*/
               p_called_from_bulk_api                => 'Y',
               x_return_status                       => x_return_status,
               x_msg_count                           => x_msg_count,
               x_msg_data                            => x_msg_data
               );
               IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR ;
               END IF;
               ref_task_temp_version_id := p_task_version_id_tbl(i);   -- Bug 6628382
    END LOOP;

 END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to MOVE_TASK_VERSIONS_IN_BULK;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count  := Fnd_Msg_Pub.count_msg;

      IF x_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
      END IF;

    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to MOVE_TASK_VERSIONS_IN_BULK;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'MOVE_TASK_VERSIONS_IN_BULK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to MOVE_TASK_VERSIONS_IN_BULK;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'MOVE_TASK_VERSIONS_IN_BULK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END MOVE_TASK_VERSIONS_IN_BULK ;

-- 4218932 Added below update api for update task page for  bulk approach

PROCEDURE Update_Task_All_Info(
 p_api_version                      IN      NUMBER      :=1.0,
 p_init_msg_list                    IN      VARCHAR2    :=FND_API.G_TRUE,
 p_commit                           IN      VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only                    IN      VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level                 IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                   IN      VARCHAR2    :='SELF_SERVICE',
 p_debug_mode                       IN      VARCHAR2    :='N',
 p_max_msg_count                    IN      NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_id_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 --Begin:5867373:p_task_number_tbl's data-type has been changed to varchar2(100)
 p_task_number_tbl                  IN      SYSTEM.PA_VARCHAR2_100_TBL_TYPE  := SYSTEM.PA_VARCHAR2_100_TBL_TYPE(),
 --End:5867373:
 p_task_name_tbl                    IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_task_description_tbl             IN      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE(),
 p_task_manager_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_task_manager_name_tbl            IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_carrying_out_org_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_carrying_out_org_name_tbl        IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_priority_code_tbl                IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_TYPE_ID_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_status_code_tbl                  IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_inc_proj_progress_flag_tbl       IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_transaction_start_date_tbl       IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_transaction_finish_date_tbl      IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_work_type_id_tbl                 IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_service_type_code_tbl            IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_work_item_code_tbl               IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_uom_code_tbl                     IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_record_version_number_tbl        IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- Update_Schedule_Version
 p_scheduled_start_date_tbl         IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_scheduled_end_date_tbl           IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_pev_schedule_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_milestone_flag_tbl               IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
 p_critical_flag_tbl                IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
 p_WQ_PLANNED_QUANTITY_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_early_start_date_tbl             IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_early_end_date_tbl               IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_late_start_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_late_end_date_tbl                IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_constraint_type_code_tbl         IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_constraint_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_sch_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- update_task_det_sch_info
 p_task_version_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_percent_complete_tbl             IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_ETC_effort_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_structure_version_id_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_project_id_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_planned_effort_tbl               IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_actual_effort_tbl                IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- Update_Task_Weighting
 p_object_relationship_id_tbl       IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_weighting_percentage_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_obj_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_task_weight_method               IN      VARCHAR2,
 -- common
 x_return_status                    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Task_All_Info';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;

BEGIN
    pa_debug.init_err_stack ('PA_TASK_PUB1.Update_Task_All_Info');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.Update_Task_All_Info begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_Task_all_info;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF nvl(p_task_id_tbl.last,0) >= 1 THEN

        FOR i in p_task_id_tbl.FIRST .. p_task_id_tbl.LAST LOOP

            PA_TASK_PUB1.Update_Task
            (
                  p_task_id                              => p_task_id_tbl(i)
                 ,p_task_number                          => p_task_number_tbl(i)
                 ,p_task_name                            => p_task_name_tbl(i)
                 ,p_task_manager_id                      => p_task_manager_id_tbl(i)
                 ,p_task_manager_name                    => p_task_manager_name_tbl(i)
                 ,p_record_version_number                => p_record_version_number_tbl(i)
                 ,P_TASK_DESCRIPTION                     => P_TASK_DESCRIPTION_tbl(i)
                 ,P_CARRYING_OUT_ORG_NAME                => P_CARRYING_OUT_ORG_NAME_tbl(i)
                 ,P_PRIORITY_CODE                        => P_PRIORITY_CODE_tbl(i)
                 ,P_STATUS_CODE                          => P_STATUS_CODE_tbl(i)
                 ,P_INC_PROJ_PROGRESS_FLAG               => P_INC_PROJ_PROGRESS_FLAG_tbl(i)
                 ,p_transaction_start_date               => p_transaction_start_date_tbl(i)
                 ,p_transaction_finish_date              => p_transaction_finish_date_tbl(i)
                 ,p_service_type_code                    => p_service_type_code_tbl(i)
                 ,p_work_type_id                         => p_work_type_id_tbl(i)
                 ,p_work_item_code                       => p_work_item_code_tbl(i)
                 ,p_uom_code                             => p_uom_code_tbl(i)
                 ,p_type_id                              => p_type_id_tbl(i)
                 ,p_carrying_out_org_id                  => p_carrying_out_org_id_tbl(i)
                 ,x_return_status                        => l_return_status
                 ,x_msg_count                            => l_msg_count
                 ,x_msg_data                             => l_msg_data
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                    pa_interface_utils_pub.get_messages
                    (
                        p_encoded        => FND_API.G_FALSE,  /*Bug#9045404*/
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out
                    );
                    x_msg_data := l_data;
                END IF;
              raise FND_API.G_EXC_ERROR;
            END IF;

            PA_TASK_PUB1.Update_Schedule_Version
            (
                  p_scheduled_start_date                => p_scheduled_start_date_tbl(i)
                 ,p_scheduled_end_date                  => p_scheduled_end_date_tbl(i)
                 ,p_record_version_number               => p_sch_rec_ver_num_tbl(i)
                 ,p_pev_schedule_id                     => p_pev_schedule_id_tbl(i)
                 ,P_MILESTONE_FLAG                      => P_MILESTONE_FLAG_tbl(i)
                 ,P_CRITICAL_FLAG                       => P_CRITICAL_FLAG_tbl(i)
                 ,p_WQ_PLANNED_QUANTITY                 => p_WQ_PLANNED_QUANTITY_tbl(i)
                 ,p_early_start_date                    => p_early_start_date_tbl(i)
                 ,p_early_end_date                      => p_early_end_date_tbl(i)
                 ,p_late_start_date                     => p_late_start_date_tbl(i)
                 ,p_late_end_date                       => p_late_end_date_tbl(i)
                 ,p_constraint_date                     => p_constraint_date_tbl(i)
                 ,p_constraint_type_code                => p_constraint_type_code_tbl(i)
                 ,x_return_status                       => l_return_status
                 ,x_msg_count                           => l_msg_count
                 ,x_msg_data                            => l_msg_data
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                    pa_interface_utils_pub.get_messages
                    (
                        p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out
                    );
                    x_msg_data := l_data;
                END IF;
              raise FND_API.G_EXC_ERROR;
            END IF;

            PA_TASK_PUB1.update_task_det_sch_info
            (
                  p_task_ver_id                         => p_task_version_id_tbl(i)
                 ,p_percent_complete                    => p_percent_complete_tbl(i)
                 ,p_ETC_effort                          => p_ETC_effort_tbl(i)
                 ,p_structure_version_id                => p_structure_version_id_tbl(i)
                 ,p_project_id                          => p_project_id_tbl(i)
                 ,p_planned_effort                      => p_planned_effort_tbl(i)
                 ,p_actual_effort                       => p_actual_effort_tbl(i)
                 ,x_return_status                       => l_return_status
                 ,x_msg_count                           => l_msg_count
                 ,x_msg_data                            => l_msg_data
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 then
                    pa_interface_utils_pub.get_messages
                    (
                        p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out
                    );
                    x_msg_data := l_data;
                END IF;
              raise FND_API.G_EXC_ERROR;
            END IF;

            IF p_task_weight_method = 'MANUAL' THEN

                PA_TASK_PUB1.Update_Task_Weighting
                (
                      p_object_relationship_id              => p_object_relationship_id_tbl(i)
                     ,p_weighting_percentage                => p_weighting_percentage_tbl(i)
                     ,p_record_version_number               => p_obj_rec_ver_num_tbl(i)
                     ,x_return_status                       => l_return_status
                     ,x_msg_count                           => l_msg_count
                     ,x_msg_data                            => l_msg_data
                );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    x_msg_count := FND_MSG_PUB.count_msg;
                    IF x_msg_count = 1 then
                        pa_interface_utils_pub.get_messages
                        (
                            p_encoded        => FND_API.G_TRUE,
                            p_msg_index      => 1,
                            p_msg_count      => l_msg_count,
                            p_msg_data       => l_msg_data,
                            p_data           => l_data,
                            p_msg_index_out  => l_msg_index_out
                        );
                        x_msg_data := l_data;
                    END IF;
                  raise FND_API.G_EXC_ERROR;
                END IF;
            END IF;

        END LOOP;

    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASK_PUB1.Update_Task_All_Info END');
    END IF;

 EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_Task_all_info;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_Task_all_info;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'Update_Task_All_Info',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_Task_all_info;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'Update_Task_All_Info',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Update_Task_All_Info;

-- 4429929 : Added  CANCEL_TASK
PROCEDURE CANCEL_TASK(
  p_calling_module		IN      VARCHAR2        :='SELF_SERVICE'
 ,p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_mode		IN      VARCHAR2        :=null
 ,p_task_id			IN	NUMBER
 ,p_task_version_id		IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_cancel_status_code		IN	VARCHAR2
 ,x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_debug_mode		VARCHAR2(1);
l_module_name		VARCHAR2(100):= 'PA_TASK_PUB1.CANCEL_TASK';
l_error_message_code	VARCHAR2(32);

-- 4533534  : Included join of pa_proj_elem_ver_structure too
CURSOR c_get_all_task_versions(c_task_id NUMBER, c_project_id NUMBER) IS
SELECT ver.element_version_id, str.status_code
FROM pa_proj_element_versions ver
, pa_proj_elem_ver_structure str
WHERE ver.project_id = c_project_id
AND ver.proj_element_id = c_task_id
AND ver.project_id = str.project_id
and ver.parent_structure_version_id = str.element_version_id
;

-- 4533534  : Commnted this cusror and written new simplified cusror
/*
CURSOR c_get_links(c_task_version_id NUMBER, c_project_id NUMBER) IS
SELECT
  ppv2.project_id                     sub_project_id
 ,ppv2.element_version_id             sub_structure_ver_id
 ,ppv1.project_id                     parent_project_id
 ,ppv1.parent_structure_version_id    parent_structure_ver_id
 ,ppv1.element_version_id             parent_task_version_id
 ,ppv1.wbs_number		      parent_wbs_number
 ,por1.object_id_from1                link_task_ver_id
 ,por1.object_relationship_id         object_relationship_id
 ,por1.record_version_number	      record_version_number
 ,ppv1.task_unpub_ver_status_code     task_unpub_ver_status_code
FROM
     pa_proj_element_versions ppv1 -- linking task
    ,pa_proj_element_versions ppv2 -- linked project
    ,pa_object_relationships por1
    ,pa_object_relationships por2
    ,(SELECT object_id_from1, object_id_to1
       FROM pa_object_relationships
       START WITH object_id_from1 = c_task_version_id
       and relationship_type = 'S'
       CONNECT BY object_id_from1 = PRIOR  object_id_to1
       and relationship_type = 'S'
       UNION
       SELECT to_number(null) object_id_from1, c_task_version_id object_id_to1
       FROM DUAL
       ) pobj
WHERE
     ppv2.element_version_id = por1.object_id_to1
 AND por1.object_id_from1 = por2.object_id_to1
 AND por2.object_id_from1 = ppv1.element_version_id
 AND ppv1.element_version_id = pobj.object_id_to1
 AND ppv2.object_type = 'PA_STRUCTURES'
 AND por1.relationship_type in ( 'LW', 'LF' )
 AND ppv1.project_id=c_project_id
 ;
*/
CURSOR c_get_links(c_task_version_id NUMBER) IS
 SELECT
  ppv.project_id                     sub_project_id
 ,ppv.element_version_id             sub_structure_ver_id
 ,por.object_id_from1                link_task_ver_id
 ,por.object_relationship_id         object_relationship_id
 ,por.record_version_number	     record_version_number
 ,por.relationship_type              relationship_type
FROM
    pa_proj_element_versions ppv -- linked project
    ,pa_object_relationships por
    ,(SELECT object_id_from1, object_id_to1  -- Get all sub tasks including linking tasks
       FROM pa_object_relationships
       START WITH object_id_from1 = c_task_version_id
       and relationship_type = 'S'
       CONNECT BY object_id_from1 = PRIOR  object_id_to1
       and relationship_type = 'S'
       ) pobj
WHERE
pobj.object_id_to1 = por.object_id_from1
AND por.relationship_type = 'LW' -- 4533534 : It shd be LW only otherwsie it will give error PA_NO_RECORD_VERSION_NUMBER
AND por.object_id_to1 = ppv.element_version_id
AND ppv.object_type = 'PA_STRUCTURES'
 ;

 l_version_enabled	VARCHAR2(1);

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
	SAVEPOINT CANCEL_TASK_SP;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'Cancel Task Passed Parameters', 3);
		pa_debug.write(l_module_name,'p_task_id='||p_task_id, 3);
		pa_debug.write(l_module_name,'p_task_version_id='||p_task_version_id, 3);
		pa_debug.write(l_module_name,'p_project_id='||p_project_id, 3);
		pa_debug.write(l_module_name,'p_cancel_status_code='||p_cancel_status_code, 3);
	END IF;

	IF p_init_msg_list = 'T' THEN
		FND_MSG_PUB.initialize;
	END IF;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'Calling Check_chg_stat_cancel_ok', 3);
	END IF;

	PA_PROJ_ELEMENTS_UTILS.Check_chg_stat_cancel_ok
		(
		 p_task_id             => p_task_id
		,p_task_version_id     => p_task_version_id
		,p_new_task_status     => p_cancel_status_code
		,x_return_status       => x_return_status
		,x_error_message_code  => l_error_message_code
             );

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'After Call Check_chg_stat_cancel_ok x_return_status='||x_return_status, 3);
	END IF;

	IF (x_return_status <> 'S') THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
			p_msg_name => l_error_message_code);
                raise FND_API.G_EXC_ERROR;
	END IF;
	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'Calling set_new_tasks_to_TBD', 3);
	END IF;

	PA_TASK_PVT1.set_new_tasks_to_tbd(
                p_project_id               => p_project_id
               ,p_task_id                  => p_task_id
               ,p_task_status              => p_cancel_status_code
               ,x_return_status            => x_return_status
               ,x_msg_count                => x_msg_count
               ,x_msg_data                 => x_msg_data);

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'After Call set_new_tasks_to_TBD x_return_status='||x_return_status, 3);
	END IF;

	IF (x_return_status <> 'S') THEN
                raise FND_API.G_EXC_ERROR;
	END IF;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'Calling push_down_task_status', 3);
	END IF;

	PA_PROGRESS_PUB.push_down_task_status(
		p_calling_module		=> p_calling_module
		,p_task_status			=> p_cancel_status_code
		,p_project_id			=> p_project_id
		,p_object_id			=> p_task_id
		,p_object_version_id		=> p_task_version_id
		,p_object_type			=> 'PA_TASKS'
		,x_return_status		=> x_return_status
		,x_msg_count			=> x_msg_count
		,x_msg_data			=> x_msg_data
		);
	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'After Call push_down_task_status x_return_status='||x_return_status, 3);
	END IF;

	IF (x_return_status <> 'S') THEN
                raise FND_API.G_EXC_ERROR;
	END IF;

	l_version_enabled := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id);

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module_name,'Call Delete_SubProject_Association l_version_enabled='||l_version_enabled, 3);
	END IF;

	FOR l_all_tasks IN c_get_all_task_versions(p_task_id, p_project_id) LOOP
		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module_name,'l_all_tasks.element_version_id='||l_all_tasks.element_version_id, 3);
			pa_debug.write(l_module_name,'l_all_tasks.status_code='||l_all_tasks.status_code, 3);
		END IF;
		--4533534
		IF ((l_version_enabled = 'N') OR (l_version_enabled = 'Y' AND l_all_tasks.status_code = 'STRUCTURE_WORKING'))
		THEN
			--4533534
			--FOR l_all_links IN c_get_links(l_all_tasks.element_version_id, p_project_id) LOOP
			FOR l_all_links IN c_get_links(l_all_tasks.element_version_id) LOOP
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module_name,'l_all_links.sub_project_id='||l_all_links.sub_project_id, 3);
					pa_debug.write(l_module_name,'l_all_links.sub_structure_ver_id='||l_all_links.sub_structure_ver_id, 3);
					--pa_debug.write(l_module_name,'l_all_links.parent_project_id='||l_all_links.parent_project_id, 3);
					--pa_debug.write(l_module_name,'l_all_links.parent_structure_ver_id='||l_all_links.parent_structure_ver_id, 3);
					--pa_debug.write(l_module_name,'l_all_links.parent_task_version_id='||l_all_links.parent_task_version_id, 3);
					--pa_debug.write(l_module_name,'l_all_links.parent_wbs_number='||l_all_links.parent_wbs_number, 3);
					pa_debug.write(l_module_name,'l_all_links.link_task_ver_id='||l_all_links.link_task_ver_id, 3);
					pa_debug.write(l_module_name,'l_all_links.object_relationship_id='||l_all_links.object_relationship_id, 3);
					pa_debug.write(l_module_name,'l_all_links.record_version_number='||l_all_links.record_version_number, 3);
					--pa_debug.write(l_module_name,'l_all_links.task_unpub_ver_status_code='||l_all_links.task_unpub_ver_status_code, 3);
					pa_debug.write(l_module_name,'l_all_links.relationship_type='||l_all_links.relationship_type, 3);
				END IF;
				--4533534
				--IF ((l_version_enabled = 'N') OR (l_version_enabled = 'Y' AND NVL(l_all_links.task_unpub_ver_status_code,'WORKING') <> 'PUBLISHED'))

				PA_RELATIONSHIP_PUB.Delete_SubProject_Association
						( p_init_msg_list		=> FND_API.G_FALSE,
						p_calling_module		=> p_calling_module,
						p_object_relationships_id	=> l_all_links.object_relationship_id,
						p_record_version_number		=> l_all_links.record_version_number,
						x_return_status			=> x_return_status,
						x_msg_count			=> x_msg_count,
						x_msg_data			=> x_msg_data
						);
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module_name,'After Call Delete_SubProject_Association x_return_status='||x_return_status, 3);
				END IF;

				IF (x_return_status <> 'S') THEN
					raise FND_API.G_EXC_ERROR;
				END IF;
			END LOOP;
		END IF;
	END LOOP;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := fnd_msg_pub.count_msg;
      ROLLBACK to CANCEL_TASK_SP;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CANCEL_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_msg_count := fnd_msg_pub.count_msg;
      ROLLBACK to CANCEL_TASK_SP;
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                              p_procedure_name => 'CANCEL_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      x_msg_count := fnd_msg_pub.count_msg;
      ROLLBACK to CANCEL_TASK_SP;
      raise;
END CANCEL_TASK;

-- Bug Fix 5593736.

PROCEDURE INDENT_MULTI_TASK_VERSION
(p_api_version                  IN      NUMBER          := 1.0
,p_init_msg_list                IN      VARCHAR2        := FND_API.G_TRUE
,p_commit                       IN      VARCHAR2        := FND_API.G_FALSE
,p_validate_only                IN      VARCHAR2        := FND_API.G_TRUE
,p_validation_level             IN      NUMBER          := FND_API.G_VALID_LEVEL_FULL
,p_calling_module               IN      VARCHAR2        := 'SELF_SERVICE'
,p_debug_mode                   IN      VARCHAR2        := 'N'
,p_max_msg_count                IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id                   IN      NUMBER
,p_structure_version_id         IN      NUMBER
,p_structure_type               IN      VARCHAR2        :='WORKPLAN'
,p_task_version_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl    IN      SYSTEM.PA_NUM_TBL_TYPE
,p_display_sequence_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE
,x_return_status                OUT     NOCOPY VARCHAR2
,x_msg_count                    OUT     NOCOPY NUMBER
,x_msg_data                     OUT     NOCOPY VARCHAR2)
IS

l_api_name            	CONSTANT VARCHAR(30) := 'INDENT_MULTI_TASK_VERSION';
l_api_version         	CONSTANT NUMBER      := 1.0;
l_return_status       	VARCHAR2(1);
l_msg_count           	NUMBER;
l_msg_data            	VARCHAR2(250);
l_data              	VARCHAR2(250);
l_msg_index_out       	NUMBER;

h 		  	NUMBER := 0;
i 		  	NUMBER := 0;
j 			NUMBER := 0;
k 			NUMBER := 0;
l			NUMBER := 0;
m			NUMBER := 0;
l_count 		NUMBER := 0;
l_error_count 		NUMBER := 0;
l_msg_code		VARCHAR2(30) := null;

TYPE l_task_in_rec_type IS RECORD
(task_version_id        NUMBER      := null
,record_version_number  NUMBER      := null
,display_sequence       NUMBER      := null);

l_current l_task_in_rec_type;

TYPE l_task_in_tbl_type IS TABLE OF l_task_in_rec_type INDEX BY BINARY_INTEGER;

l_task_in_tbl l_task_in_tbl_type;

TYPE l_task_error_rec_type IS RECORD
(task_name           	VARCHAR2(300)   := null
,task_number     	VARCHAR2(300)   := null
,error_msg         	VARCHAR2(2000)  := null);

TYPE l_task_error_tbl_type IS TABLE OF l_task_error_rec_type INDEX BY BINARY_INTEGER;

l_task_error_tbl l_task_error_tbl_type;

cursor l_cur_task_attr(c_project_id NUMBER, c_element_version_id NUMBER) is
select ppe.name, ppev.wbs_number  --Bug 6878138
from pa_proj_elements ppe, pa_proj_element_versions ppev
where ppe.project_id = ppev.project_id
and ppe.proj_element_id = ppev.proj_element_id
and ppev.project_id = c_project_id
and ppev.element_version_id = c_element_version_id;

l_rec_task_attr l_cur_task_attr%rowtype;

BEGIN

  pa_debug.init_err_stack ('PA_TASK_PUB1.INDENT_MULTI_TASK_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_MULTI_TASK_VERSION BEGIN');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint indent_multi_task_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Copy the input paramters to the local pl/sql table.
  for h in p_task_version_id_tbl.FIRST..p_task_version_id_tbl.LAST
  loop
	  l_task_in_tbl(h).task_version_id  	   := p_task_version_id_tbl(h);
	  l_task_in_tbl(h).record_version_number   := p_record_version_number_tbl(h);
	  l_task_in_tbl(h).display_sequence 	   := p_display_sequence_tbl(h);
  end loop;

  -- Sort the tasks for indent in ascending order of display sequence.
  -- Assuming that the user will generally choose less than a thousand items
  -- we have implemeneted an insertion sort for good sorting efficiency.
   l_count := l_task_in_tbl.count;

   i := 1;

	while (i <= l_count)
	loop
    		l_current := l_task_in_tbl(i);
    		j := i;
		while ((j > 1) AND (l_task_in_tbl(j-1).display_sequence > l_current.display_sequence))
		loop
			l_task_in_tbl(j) := l_task_in_tbl(j-1);
			j :=  (j-1);
		end loop;
		l_task_in_tbl(j) := l_current;
	     	i := (i + 1);
	end loop;

  -- Loop through the sorted list and indent each task version.
  for k in 1..l_count
  loop
	   -- Clear the message stack.
  	   FND_MSG_PUB.initialize;

	   -- Call the API: PA_TASK_PUB1.INDENT_TASK_VERSION_BULK().
  	   PA_TASK_PUB1.INDENT_TASK_VERSION_BULK
  	   (p_api_version	     => p_api_version
   	   , p_init_msg_list 	     => p_init_msg_list
   	   , p_commit 		     => p_commit
   	   , p_validate_only	     => p_validate_only
   	   , p_validation_level      => p_validation_level
   	   , p_calling_module        => p_calling_module
   	   , p_debug_mode            => p_debug_mode
   	   , p_max_msg_count         => p_max_msg_count
   	   , p_structure_version_id  => p_structure_version_id
   	   , p_task_version_id       => l_task_in_tbl(k).task_version_id
   	   , p_project_id	     => p_project_id
   	   , p_record_version_number => l_task_in_tbl(k).record_version_number
   	   , x_return_status	     => l_return_status
   	   , x_msg_count             => l_msg_count
   	   , x_msg_data              => l_msg_data);

  	   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

		  -- Store the task name and task number in the local pl/sql error table.
	   	  open l_cur_task_attr(p_project_id, l_task_in_tbl(k).task_version_id);
  		  fetch l_cur_task_attr into l_task_error_tbl(k).task_name, l_task_error_tbl(k).task_number ;
		  close l_cur_task_attr;

		  -- Store the message code for the error message reported in the local pl/sql error table.
		  PA_INTERFACE_UTILS_PUB.get_messages
           	  (p_encoded          => FND_API.G_FALSE     -- Get the encoded message.
                   , p_msg_index      => 1                   -- Get the message at index 1.
                   , p_data           => l_task_error_tbl(k).error_msg
                   , p_msg_index_out  => l_msg_index_out);

  	   end if;

  end loop; -- loop k.

  -- Populate the tokenized error messages in the error stack:
  l_error_count := l_task_error_tbl.count;

  if (l_error_count > 0) then

	 -- Set the return status to error.
  	 x_return_status := FND_API.G_RET_STS_ERROR;

	 -- Clear all previous messages from the message stack.
  	 FND_MSG_PUB.initialize;

	 -- Populate the generic error message.
	 PA_UTILS.ADD_MESSAGE('PA','PA_PS_GENERIC_ERROR');

	 -- Loop through the local pl/sql error table to populate the tokenized error messages.
         -- Bug Fix 5920784
         -- Modified the following line to loop through the original task count rather than the error msg table count.

	 -- for l in 1..l_error_count
	 FOR l in 1..l_count
         -- End of Bug Fix 5920784

	 loop
	 	if (l_task_error_tbl.exists(l)) then
	 	 	PA_UTILS.ADD_MESSAGE('PA','PA_PS_TOKENIZED_ERROR'
	 				     ,'TASKNAME',l_task_error_tbl(l).task_name
					     ,'TASKNUMBER',l_task_error_tbl(l).task_number
					     ,'ERRORMSG', l_task_error_tbl(l).error_msg);
		end if;
	 end loop;

  	 raise FND_API.G_EXC_ERROR;

  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
  	 COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.INDENT_MULTI_TASK_VERSION END');
  END IF;

EXCEPTION

  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_MULTI_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to indent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'INDENT_MULTI_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    raise;

END INDENT_MULTI_TASK_VERSION;

PROCEDURE OUTDENT_MULTI_TASK_VERSION
(p_api_version                  IN      NUMBER          := 1.0
,p_init_msg_list                IN      VARCHAR2        := FND_API.G_TRUE
,p_commit                       IN      VARCHAR2        := FND_API.G_FALSE
,p_validate_only                IN      VARCHAR2        := FND_API.G_TRUE
,p_validation_level             IN      NUMBER          := FND_API.G_VALID_LEVEL_FULL
,p_calling_module               IN      VARCHAR2        := 'SELF_SERVICE'
,p_debug_mode                   IN      VARCHAR2        := 'N'
,p_max_msg_count                IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id                   IN      NUMBER
,p_structure_version_id         IN      NUMBER
,p_structure_type               IN      VARCHAR2        :='WORKPLAN'
,p_task_version_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl    IN      SYSTEM.PA_NUM_TBL_TYPE
,p_display_sequence_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE
,x_return_status                OUT     NOCOPY VARCHAR2
,x_msg_count                    OUT     NOCOPY NUMBER
,x_msg_data                     OUT     NOCOPY VARCHAR2)
IS

l_api_name            	CONSTANT VARCHAR(30) := 'OUTDENT_MULTI_TASK_VERSION';
l_api_version         	CONSTANT NUMBER      := 1.0;
l_return_status       	VARCHAR2(1);
l_msg_count           	NUMBER;
l_msg_data            	VARCHAR2(250);
l_data              	VARCHAR2(250);
l_msg_index_out       	NUMBER;

h 		  	NUMBER := 0;
i 		  	NUMBER := 0;
j 			NUMBER := 0;
k 			NUMBER := 0;
l			NUMBER := 0;
m			NUMBER := 0;
l_count 		NUMBER := 0;
l_error_count 		NUMBER := 0;
l_msg_code		VARCHAR2(30) := null;

TYPE l_task_in_rec_type IS RECORD
(task_version_id        NUMBER      := null
,record_version_number  NUMBER      := null
,display_sequence       NUMBER      := null);

l_current l_task_in_rec_type;

TYPE l_task_in_tbl_type IS TABLE OF l_task_in_rec_type INDEX BY BINARY_INTEGER;

l_task_in_tbl l_task_in_tbl_type;

TYPE l_task_error_rec_type IS RECORD
(task_name           	VARCHAR2(300)   := null
,task_number     	VARCHAR2(300)   := null
,error_msg         	VARCHAR2(2000)  := null);

TYPE l_task_error_tbl_type IS TABLE OF l_task_error_rec_type INDEX BY BINARY_INTEGER;

l_task_error_tbl l_task_error_tbl_type;

cursor l_cur_task_attr(c_project_id NUMBER, c_element_version_id NUMBER) is
select ppe.name, ppev.wbs_number  --Bug	6878138
from pa_proj_elements ppe, pa_proj_element_versions ppev
where ppe.project_id = ppev.project_id
and ppe.proj_element_id = ppev.proj_element_id
and ppev.project_id = c_project_id
and ppev.element_version_id = c_element_version_id;

l_rec_task_attr l_cur_task_attr%rowtype;

BEGIN

  pa_debug.init_err_stack ('PA_TASK_PUB1.OUTDENT_MULTI_TASK_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_MULTI_TASK_VERSION BEGIN');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint outdent_multi_task_version;
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE))  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Copy the input paramters to the local pl/sql table.
  for h in p_task_version_id_tbl.FIRST..p_task_version_id_tbl.LAST
  loop
	  l_task_in_tbl(h).task_version_id  	   := p_task_version_id_tbl(h);
	  l_task_in_tbl(h).record_version_number   := p_record_version_number_tbl(h);
	  l_task_in_tbl(h).display_sequence 	   := p_display_sequence_tbl(h);
  end loop;

  -- Sort the tasks for outdent in descending order of display sequence.
  -- Assuming that the user will generally choose less than a thousand items
  -- we have implemeneted an insertion sort for good sorting efficiency.
   l_count := l_task_in_tbl.count;

   i := 1;

	while (i <= l_count)
	loop
    		l_current := l_task_in_tbl(i);
    		j := i;
		while ((j > 1) AND (l_task_in_tbl(j-1).display_sequence < l_current.display_sequence))
		loop
			l_task_in_tbl(j) := l_task_in_tbl(j-1);
			j :=  (j-1);
		end loop;
		l_task_in_tbl(j) := l_current;
	     	i := (i + 1);
	end loop;

  -- Loop through the sorted list and outdent each task version.
  for k in 1..l_count
  loop
	   -- Clear the message stack.
  	   FND_MSG_PUB.initialize;

	   -- Call the API: PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK().
  	   PA_TASK_PUB1.OUTDENT_TASK_VERSION_BULK
  	   (p_api_version	     => p_api_version
   	   , p_init_msg_list 	     => p_init_msg_list
   	   , p_commit 		     => p_commit
   	   , p_validate_only	     => p_validate_only
   	   , p_validation_level      => p_validation_level
   	   , p_calling_module        => p_calling_module
   	   , p_debug_mode            => p_debug_mode
   	   , p_max_msg_count         => p_max_msg_count
   	   , p_structure_version_id  => p_structure_version_id
   	   , p_task_version_id       => l_task_in_tbl(k).task_version_id
   	   , p_project_id	     => p_project_id
   	   , p_record_version_number => l_task_in_tbl(k).record_version_number
   	   , x_return_status	     => l_return_status
   	   , x_msg_count             => l_msg_count
   	   , x_msg_data              => l_msg_data);

  	   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

		  -- Store the task name and task number in the local pl/sql error table.
	   	  open l_cur_task_attr(p_project_id, l_task_in_tbl(k).task_version_id);
  		  fetch l_cur_task_attr into l_task_error_tbl(k).task_name, l_task_error_tbl(k).task_number ;
		  close l_cur_task_attr;

		  -- Store the message code for the error message reported in the local pl/sql error table.
		  PA_INTERFACE_UTILS_PUB.get_messages
           	  (p_encoded          => FND_API.G_FALSE     -- Get the encoded message.
                   , p_msg_index      => 1                   -- Get the message at index 1.
                   , p_data           => l_task_error_tbl(k).error_msg
                   , p_msg_index_out  => l_msg_index_out);

  	   end if;

  end loop; -- loop k.

  -- Populate the tokenized error messages in the error stack:
  l_error_count := l_task_error_tbl.count;

  if (l_error_count > 0) then

	 -- Set the return status to error.
  	 x_return_status := FND_API.G_RET_STS_ERROR;

	 -- Clear all previous messages from the message stack.
  	 FND_MSG_PUB.initialize;

	 -- Populate the generic error message.
	 PA_UTILS.ADD_MESSAGE('PA','PA_PS_GENERIC_ERROR');

	 -- Loop through the local pl/sql error table to populate the tokenized error messages.
	 for l in 1..l_error_count
	 loop
		if (l_task_error_tbl.exists(l)) then
	 	 	PA_UTILS.ADD_MESSAGE('PA','PA_PS_TOKENIZED_ERROR'
	 				     ,'TASKNAME',l_task_error_tbl(l).task_name
					     ,'TASKNUMBER',l_task_error_tbl(l).task_number
					     ,'ERRORMSG', l_task_error_tbl(l).error_msg);
		end if;
	 end loop;

  	 raise FND_API.G_EXC_ERROR;

  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
  	 COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_TASK_PUB1.OUTDENT_MULTI_TASK_VERSION END');
  END IF;

EXCEPTION

  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_MULTI_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to outdent_multi_task_version;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'OUTDENT_MULTI_TASK_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    raise;

END OUTDENT_MULTI_TASK_VERSION;

--anuragag bug 8566495 E&C enhancement changes
PROCEDURE APPROVE_TASKS_IN_BULK
(p_task_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
,p_parent_task_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE
,p_task_name_tbl IN SYSTEM.PA_VARCHAR2_100_TBL_TYPE
,p_task_number_tbl IN   SYSTEM.PA_VARCHAR2_100_TBL_TYPE
,p_project_id        IN  NUMBER
,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
l_task_number    pa_tasks.task_number%TYPE ;
l_task_name      pa_tasks.task_name%TYPE ;
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(1);
l_msg_count2         NUMBER := 0;
l_msg_data2          VARCHAR2(2000);
l_return_status2     VARCHAR2(1);
l_dummy_app_name    VARCHAR2(30);
l_enc_msg_data      VARCHAR2(2000);
l_msg_name          VARCHAR2(30);
l_msg_index_out     NUMBER ;
l_task_id_tbl       SYSTEM.PA_NUM_TBL_TYPE;

l_project_id pa_proj_elements.project_id%TYPE;
l_task_start_date DATE;
l_task_finish_date DATE;
l_org_id NUMBER;

TYPE l_error_msg_name_tbl_type IS TABLE OF
          fnd_new_messages.message_text%TYPE INDEX BY BINARY_INTEGER ;
TYPE l_element_name_tbl_type IS TABLE OF
          pa_proj_elements.name%TYPE INDEX BY BINARY_INTEGER ;
TYPE l_element_number_tbl_type IS TABLE OF
          pa_proj_elements.element_number%TYPE INDEX BY BINARY_INTEGER ;

l_error_msg_name_tbl l_error_msg_name_tbl_type ;
l_element_name_tbl   l_element_name_tbl_type ;
l_element_number_tbl l_element_number_tbl_type ;
j                  NUMBER ;
l_ntf_id NUMBER;
l_parent_task_status VARCHAR2(20);
l_parent_id NUMBER;
l_item_key pa_wf_processes.item_key%TYPE;

cursor task_ntf(c_task_id NUMBER,c_project_id NUMBER) IS
  SELECT max(notification_id) ntf_id
               FROM   WF_NOTIFICATIONS WFN
	           WHERE  message_type = 'PATASKWF'
               AND    status = 'OPEN'
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'TASK_NUMBER'
                          AND    text_value like (select element_number from pa_proj_elements
												  where proj_element_id = c_task_id)
                             )
               AND    EXISTS (
                          SELECT 1
                          FROM   WF_NOTIFICATION_ATTRIBUTES
                          WHERE  notification_id = wfn.notification_id
                          AND    name = 'PROJECT_NUMBER'
                          AND    text_value like (select segment1 from pa_projects_all
												  where project_id = c_project_id)
                             );

cursor parent_task_status(c_task_id NUMBER) is
select task_status,ppe.proj_element_id from pa_proj_elements ppe where
ppe.proj_element_id =
(select ppev1.proj_element_id from pa_proj_element_versions ppev1,pa_object_relationships por
where por.object_id_to1 = (select element_version_id from pa_proj_element_versions ppev2
where proj_element_id = c_task_id)
and por.relationship_type = 'S'
and por.relationship_subtype = 'TASK_TO_TASK'
and ppev1.element_version_id = por.object_id_from1);
--Bug 8566495 Changes for E&C enhancement related to CR workflow

CURSOR C3(p_project_id NUMBER, p_task_id NUMBER) IS
       SELECT pci.ci_id,
              pcia.ci_action_id action_id
       FROM   pa_control_items pci, pa_ci_actions pcia
       WHERE  pci.project_id = p_project_id
       AND    pcia.ci_id = pci.ci_id
       AND    pcia.ci_action_number = pci.open_action_num
       AND EXISTS (SELECT 1 FROM pa_budget_versions pbv, pa_resource_assignments pra
                   WHERE  pbv.project_id = pci.project_Id
                   AND    pbv.ci_id = pci.ci_id
                   AND    pra.budget_version_id = pbv.budget_version_id
                   AND    pra.project_id = p_project_id
                   AND    pra.task_id = p_task_id)
       AND   pci.status_code in ('CI_SUBMITTED');

BEGIN
l_task_id_tbl := p_task_id_tbl;
l_project_id := p_project_id;
fnd_msg_pub.initialize;

select carrying_out_organization_id
into l_org_id
from pa_projects_all
where project_id = l_project_id;

   --hsiu: 3604086
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	j:=0;
    l_msg_count := 0;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

	for i in p_task_id_tbl.FIRST..p_task_id_tbl.LAST loop

		select ppvsch.scheduled_start_date,ppvsch.scheduled_finish_date
		into l_task_start_date,l_task_finish_date
		from pa_proj_elem_ver_schedule ppvsch,pa_proj_elements ppe,pa_proj_element_versions ppv
		where ppe.proj_element_id = ppv.proj_element_id
		and ppv.element_version_id = ppvsch.element_version_id
		and ppe.proj_element_id = p_task_id_tbl(i);

		 l_return_status := FND_API.G_RET_STS_SUCCESS ;
         l_msg_count := 0 ;
         l_msg_data := null ;

		 open parent_task_status(p_task_id_tbl(i));
		 fetch parent_task_status into l_parent_task_status,l_parent_id;

		 close parent_task_status;

		 if(l_parent_task_status is not null)
		 then
		 x_msg_count:=1;
		 raise FND_API.G_EXC_ERROR;
		 end if;



		 PA_TASKS_MAINT_PUB.CREATE_TASK
               (
                 p_calling_module         => 'SELF_SERVICE'
                ,p_init_msg_list          => FND_API.G_FALSE
                ,p_debug_mode             => 'N'
                ,p_project_id             => l_project_id
                ,p_reference_task_id      => l_parent_id
                ,p_peer_or_sub            => 'SUB'
                ,p_task_number            => p_task_number_tbl(i)
                ,p_task_name              => p_task_name_tbl(i)
                ,p_task_id                => l_task_id_tbl(i)
                ,p_task_start_date   => l_task_start_date
                ,p_task_completion_date  => l_task_finish_date
                ,p_wbs_record_version_number => 1
                ,p_carrying_out_organization_id => l_org_id
                ,x_return_status          =>l_return_status
                ,x_msg_count              =>l_msg_count
                ,x_msg_data               =>l_msg_data
            );

			if l_return_status = FND_API.G_RET_STS_SUCCESS THEN
				open task_ntf(p_task_id_tbl(i),l_project_id);
				fetch task_ntf into l_ntf_id;
				close task_ntf;
				if(l_ntf_id is not null)
				then
					update  WF_NOTIFICATIONS
					set status = 'CLOSED'
					where notification_id = l_ntf_id ;
				end if;

			    UPDATE PA_PROJ_ELEMENTS SET link_task_flag = 'N', task_status = ''
				WHERE proj_element_id = l_task_id_tbl(i);

				FOR ci_info IN C3(l_project_id, l_task_id_tbl(i)) LOOP

                  PA_TASK_APPROVAL_PKG.Check_UsedTask_Status
                           (ci_info.ci_id
                           ,l_msg_count2
                           ,l_msg_data2
                           ,l_return_status2);

                 IF x_return_status = 'S' THEN
                    /*PA_CONTROL_ITEMS_WORKFLOW.START_NOTIFICATION_WF
                       (  p_item_type		=> 'PAWFCISC'
	                     ,p_process_name	=> 'PA_CI_PROCESS_APPROVAL'
	                     ,p_ci_id		    => ci_info.ci_id
	                     ,p_action_id		=> ci_info.action_id
                         ,x_item_key		=> l_item_key
                         ,x_return_status   => l_return_status2
                         ,x_msg_count       => l_msg_count2
                         ,x_msg_data        => l_msg_data2    );*/
					    PA_CONTROL_ITEMS_WORKFLOW.start_workflow
	 (
						p_item_type         => 'PAWFCISC'
					  , p_process_name      => 'PA_CI_PROCESS_APPROVAL'
					  , p_ci_id             => ci_info.ci_id
					  , x_item_key          => l_item_key
					  ,x_return_status   => l_return_status2
					  ,x_msg_count       => l_msg_count2
	                  ,x_msg_data        => l_msg_data2    );
                 END IF;

				 END LOOP;

			else
			j:=j+1;
			end if;
			END LOOP;

		if j>0
		then
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_count     := 1;
		rollback;
		else
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		x_msg_count     := 0;
		commit;
		end if;
		x_msg_data:=l_msg_data;
EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	  rollback;
	  FND_MSG_PUB.initialize;

	 -- Populate the generic error message.
	 PA_UTILS.ADD_MESSAGE('PA','PA_PARENT_TASK_UNAPPROVED');
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_msg_count :=0;
	  x_msg_data := 'PA_PARENT_TASK_UNAPPROVED';

	  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'ANURAG';
	 RAISE ;

END APPROVE_TASKS_IN_BULK;
-- End of Bug Fix 5593736.

END PA_TASK_PUB1;

/
